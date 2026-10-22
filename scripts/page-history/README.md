# Page history — live-page change crawler

Brand-agnostic nightly crawler. Every `Live` page of a brand is fetched, its SEO fields are compared with
the last observation, and each real change is appended to `seo_page_change_log`. Design and rationale:
`proposals/2026-10-21-page-change-history.md`.

## What it records

State goes to `seo_page_live_state` (one row per page); changes go to `seo_page_change_log` (append-only,
one row per changed field). A field is logged only when its normalised value differs. The first
observation of a page is a baseline and writes no log rows.

| `field` | meaning |
|---|---|
| `title` | `<title>` text |
| `meta_description` | `meta[name=description]` |
| `h1` | first `<h1>` text |
| `canonical` | `link[rel=canonical]` |
| `robots` | `meta[name=robots]` |
| `schema_types` | JSON-LD `@type` values, flattened, sorted, de-duplicated |
| `content_hash` | SHA-256 of the normalised visible text of the main content |
| `http_status` | the page went bad (see below) or recovered |
| `final_url` | where redirects end; logged immediately, because redirects are deliberate |
| `url` | the crawl target (`canonical_url` in page_master) changed; one event, not a burst |

Each row carries `old_value`, `new_value`, `detected_at`, `prev_ok_at` (the change went live between
`prev_ok_at` and `detected_at`), `change_date` (Asia/Bangkok) and `run_id`.

**Failures.** Every response that is not 2xx and not 304 (including 403, 429 and any 3xx that is not
followed) and every network error or timeout counts as a failure: it only increments
`consecutive_failures`; nothing is logged. After **3 consecutive failures** one `http_status` row is logged. A single blip never becomes a
change. In state, `http_status` `0` means a fetch error (no HTTP response); it is logged as `'fetch_error'`.

**Conditional GET.** If the previous observation of the same URL was healthy (2xx, no failures), the crawler
sends `If-None-Match` / `If-Modified-Since` from the stored `etag` / `last_modified`. A `304` costs no
parsing and logs nothing. After a failure or a URL change it fetches unconditionally.

## Running locally

**Do not run it for a brand during that brand's nightly window (02:00 Asia/Bangkok).** Log ids are
deterministic (`ON CONFLICT (id) DO NOTHING`), so an overlapping run cannot duplicate rows, but it wastes the
scheduled run.

```bash
cd scripts/page-history && npm ci
export SUPABASE_SERVICE_KEY=...                 # service key, never commit it
node crawl.mjs --brand vth-biodent --dry-run --limit 20   # prints would-be log rows, writes nothing
node crawl.mjs --brand vth-biodent                        # real run
npm test
```

Flags: `--brand <brand_id>` (slug, required), `--dry-run` (no DB writes), `--limit N` (first N pages).
`--brands-dir <dir>` is a test hook that swaps the config directory. The last line of output is a JSON
summary (`checked`, `ok`, `not_modified`, `failed`, `log_rows`).

**Deleting pages.** A page with change-log rows (or notes) cannot be hard-deleted from
`seo_website_page_master` (FK, NO ACTION). Archive it via `status` instead. Its `seo_page_live_state` row is
disposable and is removed automatically if the page row is deleted (ON DELETE CASCADE).

## Brand config

`brands/_default.json` holds the defaults; `brands/<brand_id>.json` overrides key by key. Keys:

| key | meaning |
|---|---|
| `main_selector` | CSS selector for the main content used by `content_hash`. Unset = first of `main`, `article`, `body` |
| `ignore_selectors` | CSS selectors removed before hashing (cookie banners, related posts, dates, counters) |
| `rps` | requests per second (default 2); lower it for fragile hosts |
| `exclude_paths` | URL-pathname **prefixes** to skip, e.g. `["/tag/", "/wp-admin"]`; a prefix match, not a glob |

**Tuning `ignore_selectors`.** The acceptance test is that two runs on an unchanged site log zero rows. Run
the crawler twice back to back; if the second run logs `content_hash` rows, something in the page changes on
every load. Find it (view-source twice and diff), add its selector to `ignore_selectors` in the brand file,
and repeat until the second run is clean.

## Running in GitHub Actions

Brands call the reusable workflow `.github/workflows/page-history.yml`; copy
`templates/brand-workflows/page-history.caller.yml` into the brand repo and fill in `<BRAND_ID>`. Runs for
one brand never overlap (`concurrency`).

Prerequisites checklist:

- [ ] Repository secret `SUPABASE_SERVICE_KEY` in the brand repo: writes to the GTGT database. (Org secrets
  are only usable by public repos on the org's current GitHub plan, and brand repos are private, so this
  is a per-repo secret. Several brand repos already have it for their deploy workflow.)
- [ ] Nothing else while `eywa-protocol-spec` is **public** (current state, decided 2026-10-23): the default
  `GITHUB_TOKEN` can check it out. Brand deploy workflows (`eywa-vth-biodent`, `eywa-deezy`,
  `eywa-deezy-pricing-redesign`) also rely on it being public.
- If `eywa-protocol-spec` is ever made private: (a) set its Settings → Actions → General → Access to
  "Accessible from repositories in the 'the-gifted-digital' organization", or `uses:` fails with "workflow
  not found"; (b) add a repository secret `EYWA_SPEC_READ_TOKEN` (fine-grained token, read-only Contents on
  `eywa-protocol-spec` only) to every brand repo — the workflow uses it when present; (c) give the brand
  deploy workflows above the same token, or they stop deploying.

## Releases (version pinning)

Brand repos call a **pinned tag**, not `main`: `uses: …/page-history.yml@page-history-vN` together with
`spec_ref: page-history-vN` (the tag picks the workflow file, `spec_ref` picks the crawler code it checks out;
always move both). A push to `main` here therefore reaches no brand until it is released:

1. Merge and test the change on `main` (both test harnesses, manifest).
2. Tag it: `git tag -a page-history-vN <sha> -m "…"` and `git push origin page-history-vN`. Never move an
   existing tag — cut a new N.
3. Bump the tag in each brand's `.github/workflows/page-history.yml` (both places), one brand first, check its
   next run, then the rest. Rolling back = point the brand back at the previous tag.

Released: `page-history-v1` = 15802e3 (DR-078 first production release, accepted 2026-10-22).

## If your brand vendors a copy

Vendoring is fine. Silent divergence is not. After copying, run:

```bash
shasum -a 256 -c MANIFEST.sha256
```

A mismatch means your copy and the canonical one have parted ways. That is a decision to make on purpose:
either push your change up here so every brand gets it, or record why your brand needs to differ.

Regenerate the manifest whenever you change a script here:

```bash
shasum -a 256 *.mjs brands/_default.json package.json package-lock.json > MANIFEST.sha256
```

## Handover scenarios

1. **We keep maintaining the brand.** Everything runs as above.
2. **We stop and hand over the static site only.** Delete the brand's workflow file, or remove the
   brand repo's `SUPABASE_SERVICE_KEY` secret. The site build is untouched (the crawler only reads the public site). History stays in our DB.
3. **We hand over the system too.** Replace the `uses:` reference with a vendored copy (verify with the
   manifest). First a brand-scoped credential must exist, because the shared service key can read and write every
   brand; also export that brand's rows, or point the copy at its own DB. Deliberately not built in v1.
