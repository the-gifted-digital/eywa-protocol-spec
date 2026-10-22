# Proposal: Page-level SEO change history (live-crawl based)

**Status:** Design. Approved direction 2026-10-21; nothing built yet.
**Supersedes:** handover brief "Page-level change history (SEO Master Data)" (2026-10-21). This design keeps that brief's goals and replaces its capture mechanism.
**Target DB:** GTGT production `lffcbeszjqzioobqfdav`. Ship through a reviewed migration in `migrations/`. No ad-hoc SQL.

## 1. Intent

Each page should carry a lab notebook: what we changed on it, when the change went live, and whether search performance improved afterwards. With that record we can learn which kinds of edits work and roll back the ones that did not.

Measurement is only as good as the change date. GSC sees the **live page**, not our database. So the system records changes **as observed on the live site**, not as written to `seo_website_page_master`.

## 2. Goals, non-goals, anti-goals

**Goals (v1)**
1. Every SEO-relevant change on a live page produces one immutable history row per changed field. No one has to remember to log it.
2. One code path covers both Astro and WordPress sites.
3. Each change event can be compared against GSC for 28 days before and 28 days after.
4. The previous value of any field can always be read back, so a rollback is possible.

**Non-goals (v1)**
- No backfill. History starts on the day the crawler first runs. Earlier changes, including the October round-1 fixes, are out of scope.
- No full body diff. Body changes are recorded as a content hash only.
- No automated rollback push to WordPress. v1 shows the old value; a person applies it.
- No UI beyond SQL views. A Notion or dashboard view can come later.

**Anti-goals: these would make v1 a failure even if it runs**
- Capture that depends on people or agents tagging their edits. Notes are optional extras; history must be complete without them.
- Logging a "change" that is really a fetch error, a redirect blip or render noise. False changes poison the impact numbers.
- Altering `seo_website_page_master` columns, or reusing `seo_schema_changes`. That table is the DDL/migration log (70 rows, columns `change_type`, `migration_version`, …), so it is the wrong home.

## 3. Facts from the live DB (checked 2026-10-21)

- `seo_website_page_master`: 3,106 rows. **1,468 have `status='Live'`** across 6 brands: deezy-dental 593, the-face-by-vertex 278, vth-biodent 194, tc-smile-dental 171, vitalsleep-clinic 126, clearisma 106. smile-scape-clinic has 0 Live.
- Every Live page has `canonical_url` set, so this is the crawl target. `slug` can be nested (`facial-surgery/v-line-…`).
- page_master has no `h1` column and no platform (Astro/WP) column. The crawler does not need either.
- Existing triggers on page_master (`trg_sync_keyword_use_as`, fingerprint triggers, `update_wpm_updated_at`, …) are not touched. This design adds no trigger to page_master, so recursion cannot happen.
- `seo_gsc_query_daily` is **query × page × day** (`brand_id, snapshot_date, search_type, query, page_url, page_slug, clicks, impressions, ctr, position`). Data covers all brands through 2026-10-17. Some brands only start on 2026-10-08.
- GSC already holds brands that page_master does not yet have (alyss, vitalsleep-and-wellness: legacy WP). Once they are imported with `status='Live'` and `canonical_url`, the crawler picks them up with no extra work.
- `brands.brand_web_url` holds each site root.

## 4. Design

### 4.1 Data model (new objects only)

**`seo_page_live_state`**: the last observed state, one row per page.
| column | notes |
|---|---|
| `page_fp` PK | FK → `seo_website_page_master(fingerprint)`, the DR-008 immutable `page_{ULID16}` (NOT NULL, UNIQUE). Not the legacy `page_fingerprint`, which is Transition State and slated for migration. No cascade is needed. On delete: no action, because history outlives the page row. |
| `brand_id` | copied from page_master |
| `url` | the URL actually fetched (canonical_url at fetch time) |
| `http_status`, `final_url` | after redirects |
| `title`, `meta_description`, `h1`, `canonical`, `robots`, `schema_types` (text[], sorted), `content_hash` | the tracked fields |
| `first_seen_at`, `last_checked_at`, `last_ok_at`, `consecutive_failures` | |

**`seo_page_change_log`**: append-only, one row per changed field.
| column | notes |
|---|---|
| `id` uuid PK | |
| `page_fp`, `brand_id` | |
| `field` | one of: `title, meta_description, h1, canonical, robots, schema_types, content_hash, http_status, final_url` |
| `old_value`, `new_value` | jsonb |
| `detected_at` | timestamptz of the crawl that saw the new value |
| `prev_ok_at` | last crawl that still saw the old value. The change went live between `prev_ok_at` and `detected_at` |
| `change_date` | `date`, Asia/Bangkok, of `detected_at`. This is the event date used for impact |
| `run_id` | the crawl run |

Indexes: `(page_fp, detected_at desc)`, `(brand_id, change_date)`.

**`seo_page_change_note`**: optional intent annotations. Any number per page; can be added before or after the change.
| column | notes |
|---|---|
| `id`, `brand_id`, `page_fp` (required), `batch_id` (optional label; a bulk change = many note rows sharing one `batch_id`) | |
| `note` | e.g. "CTR fix round 2: add price to title" |
| `author` | person, agent or workflow id |
| `created_at` | |

A note links to change events by `page_fp` when the note's `created_at` falls within 14 days before the event's `change_date`. A note that matches nothing is still kept.

**Permissions (my call):** keep the house convention, which is RLS enabled with the `eywa_authenticated_full_access` policy on all three tables. The DB has only the stock roles (`anon`, `authenticated`, `service_role`), and this design adds no new role. Append-only is enforced in two ways:
- `REVOKE UPDATE, DELETE ON seo_page_change_log FROM anon, authenticated, service_role`.
- A `BEFORE UPDATE OR DELETE` trigger on `seo_page_change_log` that raises an exception. The trigger also stops `service_role`, which bypasses RLS but not triggers. "Admin delete" means the `postgres` owner temporarily disabling the trigger inside a reviewed migration.

The crawler runs in GitHub Actions and writes with the Supabase service key, held as a repository secret in each brand repo (see §7). `seo_page_live_state` and `seo_page_change_note` need no extra restriction.

### 4.2 Crawler (daily)

- Input: `seo_website_page_master` where `status='Live'` and `canonical_url is not null`.
- Fetch each URL with a fixed user agent, follow redirects and record `final_url`.
- Extract:
  - `<title>`
  - `meta[name=description]`
  - first `<h1>` text
  - `link[rel=canonical]`
  - `meta[name=robots]`
  - JSON-LD `@type` values (flattened, sorted, de-duplicated)
  - `content_hash`: SHA-256 of the normalised visible text of the main content. Normalise whitespace and strip scripts, styles, nav, header and footer.
- Text normalisation for every field: trim and collapse whitespace, decode entities. Compare the normalised values.
- Diff rules:
  - **First observation** of a page: insert into `seo_page_live_state` as the baseline. Write no log rows.
  - **Fetch failure** (network error, timeout or 5xx): increment `consecutive_failures` and write nothing to the log. After 3 consecutive failures, log one `http_status` change. A single blip never becomes a change.
  - **Successful fetch**: for each tracked field where normalised old ≠ new, insert one log row, then update state.
  - **Crawl target changed** (page_master `canonical_url` ≠ `seo_page_live_state.url`): log one row with `field='url'`, then diff the other fields normally against the stored state. A URL edit becomes one honest event, not a false burst of changes.
  - **Redirect** (3xx followed to a different `final_url`): log `final_url` immediately, because redirects are deliberate.
  - **404/410**: handled like a fetch failure. After 3 consecutive runs, log one `http_status` row. No re-baseline.
  - **Page leaves `status='Live'`**: stop crawling it and keep its state row. Write no log row, because the status change is already visible in page_master. If it comes back to Live, diff against the kept state.
  - **Duplicate URLs**: checked 2026-10-21, no two Live pages share a `canonical_url` (only 3 rows with null canonical, which are excluded). The crawler still de-duplicates by URL and reports any collision instead of fetching twice. The impact view must not double-count GSC rows across pages.
- Volume: about 1.5k pages a day now, maybe 2–3k once legacy sites are imported. Rate-limit per host (for example 2 requests/s) so the WP sites are not hammered.

### 4.3 Impact view: `v_page_change_impact`

- **Change event** = all log rows for one `page_fp` on one `change_date`. Body-only events (only `content_hash` changed) are kept but marked `event_kind='content'`. Events touching title, meta, h1, schema or canonical are `event_kind='seo_meta'`.
- **GSC join**: page-level totals from `seo_gsc_query_daily`, summed over queries, matched to the page by **normalised URL**: lowercase host, strip `www.`, strip trailing slash, strip query and fragment.
  - Match against **every URL the page has ever had**: its current `canonical_url`, plus every `old_value`/`new_value` of `field in ('url','final_url')` in the log. Normalise all of them the same way.
  - Reason: after a slug change, GSC reports the "before" traffic on the old URL and the "after" traffic on the new URL. Joining on the current URL alone would show an empty before window.
- **Slug / URL change events**: an event that includes `url` or `final_url` gets `event_kind='url_change'`. Its confidence is capped at `medium`, because Google needs time to consolidate signals onto the new URL and the 3-day gap is often too short.
- **Windows**: before = `[change_date − 28, change_date)`; after = `[change_date + 3, change_date + 31)`. The 3-day gap allows for recrawl.
- **Per window**: clicks, impressions, CTR = clicks / impressions, and average position weighted by impressions.
- **Deltas**: absolute and % for each metric.
- **Brand baseline** (seasonality control): the same windows summed over all of the brand's pages. Output `ctr_delta_vs_brand` and `clicks_delta_vs_brand`, which are the page delta minus the brand delta.
- **Status / confidence**:
  - `status='pending'` until `change_date + 31` is covered by GSC data, which lags about 3 days.
  - `confidence='low'` when impressions < 100 in either window, when another event on the same page falls within ±31 days, or when the before window is not fully covered by GSC data (for brands whose GSC history starts late).
  - Overlapping events: each event still gets a row, and the overlap is flagged. Attribution is left to the reader.
- **Caveat** (documented in the view comment): summing query rows undercounts page totals because GSC drops anonymised queries. Comparisons within one page are still valid; absolute numbers are a lower bound.
- **Notes**: joined in as `notes text[]`.

### 4.4 Rollback

- `v_page_field_history`: every value a field has had on a page, with the date range it was live and the impact row of the event that introduced it. This is how you answer "which title performed better?".
- **Astro**: write the chosen old value back into `seo_website_page_master` and deploy. The next crawl logs it as a new change, so a rollback is just another event and history stays append-only.
- **WordPress (v1)**: a person pastes the old value in WP admin; the crawler logs it the next day. An automated push through the Yoast or RankMath REST API is a later step.
- **Slug rollback**: more than writing a value back. The 301 must be reversed (new → old) and `canonical_url` in page_master updated. v1 records the history and shows the old URL; the redirect work stays manual.

## 5. Acceptance criteria

- [ ] After the first run, every Live page with a `canonical_url` has a `seo_page_live_state` row, and `seo_page_change_log` is empty (baseline only).
- [ ] Changing one page's title on the live site produces exactly one `field='title'` log row on the next run, with correct old and new values, and nothing else for that page.
- [ ] A forced timeout on one page for 1–2 runs writes no log rows. 3 consecutive failures write exactly one `http_status` row.
- [ ] Running the crawler twice on an unchanged site writes zero log rows on the second run. This includes `content_hash`, so the hash must be stable.
- [ ] App roles cannot UPDATE or DELETE `seo_page_change_log`.
- [ ] `v_page_change_impact` returns `status='pending'` for recent events and filled before/after metrics, deltas, brand-relative deltas and confidence for events older than 31 days plus the GSC lag.
- [ ] A WP page edited in WP admin shows up in the log within 24 h, with no WP-specific code.
- [ ] Slug change: change a page's slug and `canonical_url` and add a 301 from old to new. The next run logs one `url` row under the same `page_fp`. Once the windows are complete, `v_page_change_impact` shows the before window with the old URL's GSC data and the after window with the new URL's, with `event_kind='url_change'`.

## 6. Decided (my calls; reviewer check welcome)

- Crawl the live page; do not trigger on page_master. Reasons: one path for both platforms, an accurate go-live date, and no dependence on discipline.
- Tracked fields: title, meta_description, h1, canonical, robots, schema_types, content_hash, plus http_status and final_url as health signals. `slug` is not tracked separately: a slug change shows up as a new canonical or final_url.
- One baseline run with no backfill.
- Note-linking window: 14 days.
- Failure threshold before logging a status change: 3 runs, including 404/410.
- Page key is `fingerprint` (DR-008), not legacy `page_fingerprint`.
- No new DB role. Append-only is enforced by REVOKE plus a blocking trigger, and the crawler uses the service key.
- URL edits, redirects and pages leaving Live follow the rules in §4.2.

## 7. Where it runs and who owns what (decided 2026-10-21)

**Principle.** The protocol repo is the prototype and the development centre. Each brand repo uses the tool, can tune it to its own context, and sends use cases back up. This is the same model as `scripts/citation-gates/` (brand-agnostic, `--brand <id>`, `MANIFEST.sha256` against silent drift) and `scripts/writer-brief/` (per-brand `brands/<id>.json`).

**Split (option C):**
| Lives in | What |
|---|---|
| `eywa-protocol-spec` (central) | Migration: the three tables, the immutability trigger and the views. These are shared because every brand's data sits in the one GTGT database next to GSC. Also the crawler module `scripts/page-history/` (Node or Deno, brand-agnostic, `--brand <brand_id>`), `scripts/page-history/brands/<brand_id>.json` (main-content selector, rate limit, excluded paths), `MANIFEST.sha256`, and a **reusable workflow** `.github/workflows/page-history.yml` (`on: workflow_call`, input `brand_id`). |
| each brand repo | `.github/workflows/page-history.yml`: about 10 lines, a nightly `schedule` plus `workflow_dispatch`, calling `the-gifted-digital/eywa-protocol-spec/.github/workflows/page-history.yml@<tag>` with its `brand_id`. The brand owns its own schedule and on/off switch, and can pin a version. |

**Runner: GitHub Actions** (not n8n, not a Supabase Edge Function).
- One job per brand loops over all of its pages, so there is no chunking, cursor or CPU cap.
- Failed runs email the owner, and the script runs the same way locally.
- No new Postgres extensions are needed on production.
- Edge Function plus pg_cron was considered and rejected: its CPU-per-request limit forces chunking, cursor state and frequent cron, with more moving parts and silent failures.

**Repo prerequisites**
- ~~`eywa-protocol-spec` must be private.~~ Amended 2026-10-23: it stays **public** (brand deploy workflows depend on it). The Actions access setting is only needed if it is ever made private.

**Secret** (amended 2026-10-23: org secrets are usable only by public repos on the org's GitHub plan, so the service key is a per-brand-repo secret; `eywa-protocol-spec` stays **public**, so `EYWA_SPEC_READ_TOKEN` is optional and only needed if it is ever made private — brand deploy workflows in `eywa-vth-biodent`/`eywa-deezy` also check out the spec without a token)
- The Supabase key is an **organization secret** shared with selected brand repos. There is one place to rotate it, and a repo that leaves the org loses it automatically.
- Builder: confirm the org plan supports org secrets for private repos. If it does not, use a per-repo secret.
- A second org secret, `EYWA_SPEC_READ_TOKEN`, is needed: a fine-grained token with **read-only Contents on `eywa-protocol-spec` only**. Reason: a reusable workflow runs with the *caller's* `GITHUB_TOKEN`, which cannot check out another private repo, so the called workflow cannot fetch the crawler code without it.
- **SQL execution:** the user runs migrations in the Supabase SQL editor. Claude writes the SQL and verifies the result afterwards with read-only queries.

**Volume**
- Per-host politeness is about 1–2 requests/s.
- Conditional GET (`If-None-Match` / `If-Modified-Since`, with `etag` and `last_modified` columns on `seo_page_live_state`) means unchanged pages cost no parsing.
- Actions minutes are pooled across the org (2,000/month on Free for private repos) and each job rounds up to a whole minute. About 8 live brands ≈ 1,000 min/month; watch this as brands grow.

**Handover scenarios** (the user is not sure which will happen; the design must allow all three)
1. *We keep maintaining the brand*: everything runs as above.
2. *We stop and hand over the static site only*: delete the brand's workflow file, or just remove the repo from the org secret. The site build is untouched, because the crawler only reads the public site and never touches web code. History stays in our DB.
3. *We hand over the system too*: replace the `uses:` reference with a vendored copy (check with the manifest). Before that, a **brand-scoped credential** must exist, because the org key can read and write every brand. Also export that brand's rows, or point it at its own DB. This is deliberately not built in v1; build it when the first such handover is real.

## 7a. Left to the builder

- The HTML parsing library and the exact main-content selector per site, as long as the "twice on an unchanged site → zero rows" criterion holds.
- Whether the impact view needs to be materialised. Start as a plain view; materialise only if it is slow.
- Migration file naming, following `migrations/README.md`, plus the spec version-bump fan-out if this becomes a DR.
- Tag/versioning scheme for the reusable workflow.

## 8. Later (not v1)

- Drift report: live value ≠ page_master value. This catches WP sites whose page_master is stale.
- WP rollback push through REST.
- Notion or dashboard surface; feeding the impact view into priority scoring.
