# Page Change History Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Record every SEO-relevant change on every live brand page, observed from the live site, and compare each change with GSC 28 days before and after.

**Architecture:** The central objects live in `eywa-protocol-spec`:
- One SQL migration: 3 tables, an immutability trigger and 2 views in the shared GTGT DB.
- A brand-agnostic Node crawler `scripts/page-history/` (pure core + thin IO shell).
- A reusable GitHub Actions workflow.

Each brand repo adds a 10-line caller workflow that runs nightly for its own `brand_id`.

**Tech Stack:**
- Postgres (Supabase GTGT `lffcbeszjqzioobqfdav`)
- Node 22 ESM (`.mjs`), `node --test`
- `node-html-parser`, `@supabase/supabase-js`
- GitHub Actions (`workflow_call`)

**Spec:** `proposals/2026-10-21-page-change-history.md`. Read it first; this plan argues from it.

## Global Constraints

- **Running SQL:** the user runs all SQL against GTGT in the Supabase SQL editor. Claude writes the SQL and verifies afterwards with read-only `execute_sql`. Never call `apply_migration` or write to prod yourself.
- **page_master is read-only for this work:** do not alter `seo_website_page_master`, do not add triggers to it, and do not reuse `seo_schema_changes`.
- **Page key:** `seo_website_page_master.fingerprint` (DR-008 `page_{ULID16}`). Never use `page_fingerprint`.
- **Crawl set:** `status = 'Live' and canonical_url is not null`.
- **Tracked fields:** exactly `title, meta_description, h1, canonical, robots, schema_types, content_hash, http_status, final_url, url`.
- **Failure threshold:** `3` consecutive failures (network error, timeout, 5xx, 404, 410) before one `http_status` log row.
- **Impact windows:** before = `[change_date − 28, change_date)`; after = `[change_date + 3, change_date + 31)`.
- **Confidence:** low impressions = `< 100` in either window; overlap = another event on the same page within `±31` days.
- **Note-link window:** a note links to an event when `note.created_at` falls within `14` days before `change_date`.
- **`change_date`:** `(detected_at at time zone 'Asia/Bangkok')::date`.
- **Politeness:** default `rps: 2` per brand job; fetch timeout `20 s`; User-Agent `EYWA-PageHistory/1.0 (+https://eywaintelligence.com)`.
- **Secrets:** `SUPABASE_SERVICE_KEY` (org secret) and `EYWA_SPEC_READ_TOKEN` (org secret, read-only Contents on `eywa-protocol-spec`).
- **Repo conventions:** script reads `process.env.SUPABASE_SERVICE_KEY` and has `SUPABASE_URL = 'https://lffcbeszjqzioobqfdav.supabase.co'`; every CLI takes `--brand <brand_id>` (slug); a `MANIFEST.sha256` sits beside the scripts (pattern from `scripts/citation-gates/`).
- **Shared URL normalisation:** the same rules in JS and SQL, pinned by one shared fixture file.

## Review Focus

1. **Noisy content hash.** WP pages carry nonces, "x minutes ago" stamps and rotating widgets. Two fetches of an unchanged page must hash equal. Test: Task 2 `content_hash ignores script/style/nav/footer and ignore_selectors`, plus the live double-run check in Task 6.
2. **Write ordering.** If the log insert fails after the state upsert succeeds, a real change is lost forever. Expected: insert log rows first, upsert state second, so a failed run re-detects tomorrow. Test: Task 4 `saveResult inserts log before upserting state and does not upsert when log insert throws`.
3. **Failure then recovery.** A page fails three nights (one `http_status` row), then comes back. Expected: one more `http_status` row back to `200` and no false burst of field changes. Test: Task 3 `recovery after logged failure logs http_status back and diffs fields normally`.
4. **A page that never fetched OK.** Its first successful fetch must be a baseline, not ten "changes from null". Test: Task 3 `first ok after only failures is a baseline`.
5. **GSC URL variants** (`www`, trailing slash, `?utm=`). Same page, same totals in the impact view. Test: Task 1 shared fixture `url-cases.json` run in both SQL and JS.

---

## File Structure

```
eywa-protocol-spec/
  migrations/2026-10-21_eywa_w12_01_dr076_page_change_history.sql       # DDL + views (user runs)
  migrations/tests/2026-10-21_w12_01_page_change_history.test.sql       # BEGIN…ROLLBACK self-test (user runs)
  scripts/page-history/
    package.json                # deps + "test": "node --test"
    normalize.mjs               # normText, normUrl
    extract.mjs                 # extractFields(html, cfg)
    diff.mjs                    # decide(prev, obs, targetUrl, now, runId)  (pure)
    db.mjs                      # loadTargets, loadStates, saveResult
    crawl.mjs                   # CLI: --brand, --dry-run, --limit
    brands/_default.json        # default config
    fixtures/url-cases.json     # shared with SQL test
    fixtures/*.html
    test/*.test.mjs
    README.md
    MANIFEST.sha256
  .github/workflows/page-history.yml                                    # reusable (workflow_call)
  templates/brand-workflows/page-history.caller.yml                     # copy into brand repos
  DECISION_RECORDS.md, Schema_Overview_EYWA_v1_23.md, EYWA_PROTOCOL_v3_33.md, README.md, templates/*   # DR-076 fan-out
```

---

### Task 1: Migration — tables, immutability, URL function, views

**Files:**
- Create: `migrations/2026-10-21_eywa_w12_01_dr076_page_change_history.sql`
- Create: `migrations/tests/2026-10-21_w12_01_page_change_history.test.sql`
- Create: `scripts/page-history/fixtures/url-cases.json`

**Interfaces:**
- **Produces, tables:**
  - `seo_page_live_state(page_fp text PK FK→seo_website_page_master(fingerprint), brand_id text not null, url text not null, http_status int, final_url text, title text, meta_description text, h1 text, canonical text, robots text, schema_types text[], content_hash text, etag text, last_modified text, first_seen_at timestamptz, last_checked_at timestamptz, last_ok_at timestamptz, consecutive_failures int not null default 0)`
  - `seo_page_change_log(id uuid PK default gen_random_uuid(), page_fp text not null FK→fingerprint, brand_id text not null, field text not null check (field in (<the 10 tracked fields>)), old_value jsonb, new_value jsonb, detected_at timestamptz not null, prev_ok_at timestamptz, change_date date generated always as ((detected_at at time zone 'Asia/Bangkok')::date) stored, run_id text not null)`
    - Indexes: `(page_fp, detected_at desc)`, `(brand_id, change_date)`.
  - `seo_page_change_note(id uuid PK, brand_id text not null, page_fp text not null FK, batch_id text null, note text not null, author text, created_at timestamptz not null default now())`. A bulk change is many note rows that share a `batch_id`; `batch_id` is only a label.
- **Produces, function:** `seo_norm_url(u text) returns text`, immutable. Rules:
  - lowercase scheme and host
  - drop a leading `www.`
  - drop query and fragment
  - drop a trailing `/` unless the path is just `/`
  - decode nothing else
- **Produces, views:**
  - `v_page_change_events`: one row per `(page_fp, change_date)`. Columns: `brand_id, fields text[], event_kind` (`'url_change'` if `url` or `final_url` in fields; else `'seo_meta'` if any of title/meta_description/h1/canonical/robots/schema_types; else `'content'` if content_hash; else `'health'`), plus `notes text[]`.
  - `v_page_change_impact`: one row per event. Columns:
    - before window: `clicks_b, impr_b, ctr_b, pos_b`
    - after window: `clicks_a, impr_a, ctr_a, pos_a`
    - deltas: `d_clicks, d_ctr, d_pos`
    - brand-relative: `ctr_delta_vs_brand, clicks_delta_vs_brand`
    - `status` (`'pending'|'ready'`), `confidence` (`'low'|'medium'|'high'`)
  - `v_page_field_history`: one row per `(page_fp, field, value)` with `live_from`, `live_to` and the `change_date` that introduced it.
- **Immutability:**
  - `revoke update, delete on seo_page_change_log from anon, authenticated, service_role;`
  - plus a `before update or delete` row trigger `trg_page_change_log_immutable` that raises `'seo_page_change_log is append-only'`.
  - RLS enabled on all three tables with policy `eywa_authenticated_full_access`, the repo convention.

**Notes for the implementer:**
- GSC page totals come from `seo_gsc_query_daily` summed over `query`.
- Match rows where `seo_norm_url(page_url)` is in the page's URL set. The set is `seo_norm_url(canonical_url)` from page_master, union every `old_value->>0` / `new_value->>0` (jsonb strings) of `field in ('url','final_url')` for that page.
- `pos` is impression-weighted.
- Brand baseline: the same windows over all of the brand's GSC rows.
- `status='ready'` only when `max(snapshot_date)` for the brand ≥ `change_date + 30`.
- Confidence:
  - `low` when `impr_b < 100` or `impr_a < 100`, or another event on the same page falls within ±31 days, or the brand's `min(snapshot_date) > change_date − 28`
  - otherwise `medium` when `event_kind='url_change'`
  - otherwise `high`

- [ ] **Step 1: Write the shared URL fixture** `fixtures/url-cases.json` as `[{ "in": ..., "out": ... }]`, including at least:
  - `https://WWW.VthBiodent.com/team/dr-a/?utm_source=x#top` → `https://vthbiodent.com/team/dr-a`
  - `https://deezydental.com/` → `https://deezydental.com/`
  - `http://www.clearisma.com/a/b/` → `http://clearisma.com/a/b`
  - `https://tcsmiledental.com/%E0%B8%9F%E0%B8%B1%E0%B8%99` → unchanged

- [ ] **Step 2: Write the self-test** `migrations/tests/…test.sql`. Structure: `BEGIN;` → `\i`-free inline copy guard (the test assumes the migration is already applied) → `DO $$ … $$` assertion blocks that `raise exception` on failure → `ROLLBACK;`. Assertions:
  - each url-cases pair: `seo_norm_url(in) = out` (paste the fixture as a `values` list)
  - `update seo_page_change_log …` raises `append-only` (insert one row first, using an existing Live `fingerprint`)
  - **impact math:** insert a page_master row under `brand_id='w-test-brand'`, `status='Live'`, `canonical_url='https://test.invalid/p'` (trigger sets `fingerprint`). Insert a `url` log row with `detected_at = '2026-08-01 03:00+07'`. Insert GSC rows for brand `w-test-brand`:
    - 28 days before, each with 10 impressions and 1 click, `page_url='https://www.test.invalid/p/'`
    - 28 after days, each with 10 impressions and 2 clicks, `page_url='https://test.invalid/p?x=1'`
    - Assert `impr_b=280, clicks_b=28, impr_a=280, clicks_a=56, d_clicks=28, status='ready', event_kind='url_change', confidence='medium'`.
  - **pending:** an event with `detected_at = now()` has `status='pending'`.
  - **overlap:** two events on the same page 10 days apart both have `confidence='low'`.
  - Last line: `raise notice 'ALL PASS'`.

- [ ] **Step 3: Write the migration SQL.** Order: function → tables → indexes → RLS + policy → revoke → trigger → views → `comment on view v_page_change_impact` stating the anonymised-query undercount caveat. Make it idempotent (`if not exists` / `create or replace`) so a re-run is safe.

- [ ] **Step 4: USER runs the migration.** Hand the user the file path. They paste it into the Supabase SQL editor and run it. Wait for them to confirm.

- [ ] **Step 5: Claude verifies the migration (read-only):**
  ```sql
  select to_regclass('public.seo_page_live_state') s, to_regclass('public.seo_page_change_log') l, to_regclass('public.seo_page_change_note') n,
         to_regclass('public.v_page_change_impact') vi, to_regclass('public.v_page_field_history') vh,
         (select count(*) from pg_trigger where tgname='trg_page_change_log_immutable') trg,
         has_table_privilege('service_role','public.seo_page_change_log','UPDATE') svc_upd;
  ```
  Expected: all regclasses non-null, `trg=1`, `svc_upd=false`.

- [ ] **Step 6: USER runs the self-test file.** Expected: the output contains `ALL PASS`, and nothing persists because of the `ROLLBACK`. Claude re-checks `select count(*) from seo_page_change_log` = 0.

- [ ] **Step 7: Commit**
  ```bash
  git add migrations/2026-10-21_eywa_w12_01_dr076_page_change_history.sql migrations/tests scripts/page-history/fixtures/url-cases.json
  git commit -m "feat(schema): DR-076 page change history tables, immutability, impact views"
  ```

---

### Task 2: Crawler core — normalize + extract

**Files:**
- Create: `scripts/page-history/package.json`, `normalize.mjs`, `extract.mjs`, `brands/_default.json`, `fixtures/page-a.html`, `fixtures/page-a-noise.html`, `test/normalize.test.mjs`, `test/extract.test.mjs`

**Interfaces:**
- **Produces:**
  - `normText(s: string|null|undefined): string|null`: decode HTML entities, collapse whitespace to a single space, trim; `''` → `null`.
  - `normUrl(u: string): string`: same rules as `seo_norm_url`.
  - `extractFields(html: string, cfg: BrandCfg): Fields`
    - `Fields = { title, meta_description, h1, canonical, robots, schema_types: string[], content_hash: string }`
    - text fields pass through `normText`
    - `schema_types`: every JSON-LD `@type` (arrays flattened, `@graph` walked), de-duplicated and sorted; invalid JSON-LD is skipped
    - `content_hash`: sha256 hex of `normText` of the text in `cfg.main_selector` (first match, falling back to `main`, then `article`, then `body`), after removing `script, style, noscript, nav, header, footer, svg, iframe` and every `cfg.ignore_selectors`
  - `BrandCfg = { main_selector?: string, ignore_selectors?: string[], rps?: number, exclude_paths?: string[] }`, defaults in `brands/_default.json`: `{ "rps": 2, "ignore_selectors": [], "exclude_paths": [] }`
- `package.json`: `"type": "module"`, deps `node-html-parser`, `@supabase/supabase-js`, script `"test": "node --test"`.

- [ ] **Step 1: Write failing tests.**
  - `test/normalize.test.mjs`: loads `fixtures/url-cases.json` and asserts `normUrl(in) === out` for every case. Also `normText('  a&amp;b \n c ') === 'a&b c'` and `normText('  ') === null`.
  - `test/extract.test.mjs`:
    - `extractFields(pageA, {})` returns the fixture's exact title, meta description, first h1, canonical href and robots content.
    - `schema_types` deep-equals `['FAQPage','MedicalClinic','WebPage']` (the fixture has a `@graph` plus one array `@type`).
    - **content_hash ignores script/style/nav/footer and ignore_selectors:** `page-a-noise.html` is page-a plus a different `<script>` nonce, a different footer year and a `<div class="ago">5 minutes ago</div>`. With `{ ignore_selectors: ['.ago'] }` both hashes are equal. Changing one word inside `<main>` changes the hash.
    - Missing tags give `null`, never a throw.

- [ ] **Step 2: Run** `cd scripts/page-history && npm install && npm test`. Expected: FAIL (modules missing).

- [ ] **Step 3: Implement** `normalize.mjs` and `extract.mjs` with the signatures above. Use `node-html-parser` `parse`, and `node:crypto` `createHash('sha256')` for the hash.

- [ ] **Step 4: Run** `npm test`. Expected: all PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add scripts/page-history
  git commit -m "feat(page-history): field extraction and URL/text normalisation"
  ```

---

### Task 3: Crawler core — `decide()` diff rules

**Files:**
- Create: `scripts/page-history/diff.mjs`, `test/diff.test.mjs`

**Interfaces:**
- **Consumes:** `Fields` from Task 2.
- **Produces:** `decide(prev: State|null, obs: Obs, targetUrl: string, now: Date, runId: string): { log: LogRow[], state: State }`. Pure function, no IO.
  - `Obs` is one of:
    - `{kind:'ok', http_status:number, final_url:string, etag:string|null, last_modified:string|null, fields:Fields}`
    - `{kind:'not_modified'}`
    - `{kind:'fail', http_status:number|null, error:string}`
  - `State`: the columns of `seo_page_live_state`, with snake_case names exactly as in the table, plus `page_fp` and `brand_id` carried from the target.
  - `LogRow = { page_fp, brand_id, field, old_value, new_value, detected_at: ISOString, prev_ok_at: ISOString|null, run_id }`, values JSON-ready.
  - Export `FAIL_THRESHOLD = 3`.
- **Rules**, in order:
  1. **URL changed:** `prev && prev.url !== targetUrl` → log `url` (old → new) and set `state.url = targetUrl`. Applies whatever `obs` is.
  2. **fail:**
     - `consecutive_failures += 1`
     - if it now equals `FAIL_THRESHOLD`, log `http_status` (old `prev.http_status` → new `obs.http_status ?? 'fetch_error'`) and set `state.http_status` to that value
     - fields unchanged; `last_checked_at = now`
  3. **not_modified:** `consecutive_failures = 0`; `last_checked_at = last_ok_at = now`; no log.
  4. **ok and the page was never OK before** (`!prev || !prev.last_ok_at`): baseline, meaning set all fields, `first_seen_at` (when unset) and `last_ok_at`, and write **no log**, not even `url`.
  5. **ok otherwise:**
     - if `prev.http_status !== obs.http_status`, log `http_status`
     - if `final_url` differs, log `final_url`
     - for each tracked field where the value differs (arrays compared after sorting), log it
     - reset failures; update everything
  - `prev_ok_at` on every log row = `prev?.last_ok_at ?? null`.

- [ ] **Step 1: Write failing tests** in `test/diff.test.mjs`, one per case:
  - `first ok is baseline`: `prev=null`, obs ok → `log.length===0`, state has fields.
  - `unchanged ok writes nothing`.
  - `title change logs exactly one title row` with the exact old and new values and `prev_ok_at === prev.last_ok_at`.
  - `schema_types order-insensitive`: `['B','A']` vs `['A','B']` → no log.
  - `two failures write nothing; third writes one http_status row; fourth writes nothing`.
  - `first ok after only failures is a baseline` (prev exists, `last_ok_at` null).
  - `recovery after logged failure logs http_status back and diffs fields normally`: prev `http_status=503` after the threshold, obs ok `200` with a changed title → exactly 2 rows (`http_status`, `title`).
  - `url change logs url and diffs other fields`: `targetUrl` differs, same fields → exactly 1 `url` row.
  - `redirect logs final_url`.
  - `not_modified resets failures and logs nothing`.

- [ ] **Step 2: Run** `npm test`. Expected: the diff tests FAIL.

- [ ] **Step 3: Implement** `decide` in `diff.mjs`.

- [ ] **Step 4: Run** `npm test`. Expected: all PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add scripts/page-history
  git commit -m "feat(page-history): pure diff rules for live-page observations"
  ```

---

### Task 4: Crawler shell — DB IO, fetch, CLI

**Files:**
- Create: `scripts/page-history/db.mjs`, `crawl.mjs`, `test/db.test.mjs`, `test/crawl.test.mjs`

**Interfaces:**
- **Consumes:** `extractFields`, `normText` (Task 2); `decide`, `FAIL_THRESHOLD` (Task 3).
- **Produces:**
  - `loadTargets(db, brandId): Promise<{page_fp, brand_id, url}[]>`: page_master rows with `status='Live'`, non-null `canonical_url`, `fingerprint` as `page_fp`, de-duplicated by `normUrl(url)`. A collision prints a warning and keeps the first row.
  - `loadStates(db, brandId): Promise<Map<page_fp, State>>`.
  - `saveResult(db, {log: LogRow[], states: State[]}): Promise<void>`: inserts `log` into `seo_page_change_log` **first**, then upserts `states` into `seo_page_live_state`, each in chunks of 200. If the log insert throws, it rethrows **without** upserting states.
  - `fetchPage(url, prev, {timeoutMs, ua}): Promise<Obs>`:
    - sends `If-None-Match` / `If-Modified-Since` only when `prev?.url === url`
    - follows redirects
    - a 304 gives `not_modified`
    - 2xx gives `ok`, with `final_url = response.url`
    - 404, 410, 5xx, timeouts and network errors give `fail`
  - CLI `node crawl.mjs --brand <brand_id> [--dry-run] [--limit N]`:
    - loads `brands/_default.json` merged with `brands/<brand_id>.json` if present
    - skips targets matching `exclude_paths`
    - fetches sequentially at `cfg.rps`
    - `decide`s each page; saves every 100 pages and at the end
    - prints a summary `{checked, ok, not_modified, failed, log_rows}`
    - exits non-zero only on a DB error
    - `--dry-run` prints the log rows and saves nothing
  - `db` = `createClient(SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY)`; a missing key exits 1 with the repo's standard message.

- [ ] **Step 1: Write failing tests.**
  - `test/db.test.mjs`, with a fake `db` object that records calls:
    - `saveResult inserts log before upserting state`
    - `saveResult does not upsert when log insert throws`
    - `loadTargets dedups by normalised url and warns`
  - `test/crawl.test.mjs`, with a local `node:http` server serving the fixtures:
    - `fetchPage returns ok with final_url after 301`
    - `returns not_modified on 304 when etag sent`
    - `does not send If-None-Match when url changed`
    - `returns fail on 404 and on timeout` (server delays longer than `timeoutMs: 200`)

- [ ] **Step 2: Run** `npm test`. Expected: the new tests FAIL.

- [ ] **Step 3: Implement** `db.mjs` and `crawl.mjs`. Use global `fetch` with `AbortSignal.timeout(timeoutMs)` and `redirect:'follow'`. Wait `1000/rps` ms between requests.

- [ ] **Step 4: Run** `npm test`. Expected: all PASS.

- [ ] **Step 5: Dry run against prod (read-only).** Run `SUPABASE_SERVICE_KEY=… node crawl.mjs --brand vth-biodent --dry-run --limit 20`. Expected: the summary shows `checked: 20` and 0 log rows (no state exists yet, so everything is a baseline), and nothing is written.

- [ ] **Step 6: Commit**
  ```bash
  git add scripts/page-history
  git commit -m "feat(page-history): fetch with conditional GET, DB IO, brand CLI"
  ```

---

### Task 5: Packaging — README, manifest, reusable workflow, caller template

**Files:**
- Create: `scripts/page-history/README.md`, `scripts/page-history/MANIFEST.sha256`, `.github/workflows/page-history.yml`, `templates/brand-workflows/page-history.caller.yml`

**Interfaces:**
- **Produces:**
  - **Reusable workflow** `.github/workflows/page-history.yml`:
    - trigger `on: workflow_call`
    - inputs: `brand_id` (string, required), `spec_ref` (string, default `main`)
    - secrets: `SUPABASE_SERVICE_KEY`, `EYWA_SPEC_READ_TOKEN`
    - steps: `actions/checkout@v4` with `repository: the-gifted-digital/eywa-protocol-spec`, `ref: ${{ inputs.spec_ref }}`, `token: ${{ secrets.EYWA_SPEC_READ_TOKEN }}`, `path: spec` → `actions/setup-node@v4` (node 22) → `npm ci` in `spec/scripts/page-history` → `node crawl.mjs --brand ${{ inputs.brand_id }}`
    - `timeout-minutes: 120`
  - **Caller template**: `on: schedule: - cron: '0 19 * * *'` (02:00 Bangkok) plus `workflow_dispatch`, and a single job `uses: the-gifted-digital/eywa-protocol-spec/.github/workflows/page-history.yml@main` with `brand_id: <BRAND_ID>` and `secrets: inherit`.
  - **README** sections:
    - what it records
    - running locally
    - brand config keys
    - "If your brand vendors a copy" (copy the wording pattern from `scripts/citation-gates/README.md`)
    - the 3 handover scenarios from spec §7
- **Manifest:** generate with `cd scripts/page-history && shasum -a 256 *.mjs brands/_default.json > MANIFEST.sha256`.

- [ ] **Step 1: Write** the 4 files.
- [ ] **Step 2: Verify** with `cd scripts/page-history && shasum -a 256 -c MANIFEST.sha256` (expected: all `OK`) and `npx --yes yaml-lint ../../.github/workflows/page-history.yml ../../templates/brand-workflows/page-history.caller.yml` (expected: no errors).
- [ ] **Step 3: Commit**
  ```bash
  git add scripts/page-history/README.md scripts/page-history/MANIFEST.sha256 .github/workflows/page-history.yml templates/brand-workflows
  git commit -m "feat(page-history): reusable workflow, brand caller template, manifest"
  ```

---

### Task 6: Rollout — GitHub setup, first brand, baseline, acceptance

**Files:**
- Create in brand repo `brands/eywa-vth-biodent`: `.github/workflows/page-history.yml` (from the caller template, `brand_id: vth-biodent`)

**Interfaces:**
- **Consumes:** everything above.

- [ ] **Step 1: USER does the GitHub setup.** This is security config, so the user does it:
  - (a) set `eywa-protocol-spec` to private
  - (b) Settings → Actions → General → Access: "Accessible from repositories in the organization"
  - (c) add org secrets `SUPABASE_SERVICE_KEY` and `EYWA_SPEC_READ_TOKEN` (fine-grained PAT, Contents read-only, repo `eywa-protocol-spec` only), shared with selected repos
  - Confirm the org plan allows org secrets on private repos. If it does not, add them per repo.
- [ ] **Step 2: Push** the spec commits, and push the caller workflow to `eywa-vth-biodent`. Ask the user before pushing, per the repo rules.
- [ ] **Step 3: Run the baseline.** `workflow_dispatch` the brand workflow. Claude verifies:
  ```sql
  select count(*) state_rows, (select count(*) from seo_page_change_log where brand_id='vth-biodent') log_rows
  from seo_page_live_state where brand_id='vth-biodent';
  ```
  Expected: `state_rows` = the Live vth-biodent pages with a canonical (194 on 2026-10-21) minus fetch failures, and `log_rows = 0`.
- [ ] **Step 4: Stability.** Dispatch a second run immediately. Expected: `log_rows` is still `0`. If `content_hash` rows appear, add `ignore_selectors` to `brands/vth-biodent.json`, regenerate the manifest, commit, and repeat until 0.
- [ ] **Step 5: Acceptance on a real edit.** The user changes one vth-biodent page title and deploys; next run. Expected: exactly one `field='title'` row for that page with the correct old and new values.
- [ ] **Step 6: Other brands.** Add the caller to deezy-dental, the-face-by-vertex, tc-smile-dental, vitalsleep-clinic and clearisma (repos `eywa-deezy`, `eywa-vertex-clinic`, `eywa-tc-smile`, `eywa-vitalsleep-wellness`, `eywa-clearisma`; confirm each repo ↔ brand_id with the user). Repeat Steps 3–4 for each.
- [ ] **Step 7: Commit** each brand's config tweaks in spec, and each caller file in its brand repo.

---

### Task 7: DR-076 and spec version fan-out

**Files:**
- Modify:
  - `DECISION_RECORDS.md`: Document Version 1.42 → 1.43, plus new `### [DR-076]` at the top of the Decisions Log
  - `Schema_Overview_EYWA_v1_23.md`: v1.24 → v1.25, Group 3 Page System +3 tables, §5 entries, Group table row
  - `EYWA_PROTOCOL_v3_33.md`: Version 3.35 → 3.36, plus a changelog entry
  - `README.md`: badges, file-status rows, Latest Update block
  - `templates/brand-config.template.json`, `templates/README.md`, `templates/NEW_BRAND_BOOTSTRAP.md`: spec snapshot and `drs_locked_at_snapshot`
  - `migrations/README.md`: Wave 12 entry
- Move: `proposals/2026-10-21-page-change-history.md` stays where it is; the DR links to it.

- [ ] **Step 1:** Write DR-076 following the Format Template in `DECISION_RECORDS.md`, with `Scope: UNIVERSAL`. Content: the decision (live-crawl history, GitHub Actions, protocol-central / brand-caller ownership), the alternatives rejected (page_master trigger, n8n, Edge Function, per-brand vendored code by default), and the handover scenarios.
- [ ] **Step 2:** Apply every version bump listed above. Do not rename files.
- [ ] **Step 3: Verify residual versions.** Run `grep -rn "v1\.24\b\|1\.42\b\|3\.35\b" --include=*.md --include=*.json . | grep -v -i changelog`. Expected: only legitimate historical rows remain.
- [ ] **Step 4: Commit**
  ```bash
  git add -A DECISION_RECORDS.md Schema_Overview_EYWA_v1_23.md EYWA_PROTOCOL_v3_33.md README.md templates migrations/README.md
  git commit -m "protocol: v3.36 / schema v1.25 / DR v1.43 - DR-076 page change history"
  ```
