# Clinical gates — `gen-entity-clinical.mjs` / `check-clinical.mjs`

The contraindication bridge: a committed JSON map from entity to the list of people who should NOT
get that procedure/device/drug, built from `seo_entity_procedures` / `seo_entity_devices` /
`seo_entity_drug`, so a brand's site (and its schema.org `MedicalProcedure.contraindication`) never
hand-types a list that can drift from the table a clinician actually verified. Brand-agnostic port
of `eywa-vth-biodent/web/scripts/{gen-entity-clinical,check-clinical}.mjs` — see "What differs from
the VTH original" below for the exact delta.

`gen-entity-clinical.mjs` is read-only against the database and only writes the bridge JSON.
`check-clinical.mjs` never writes anything — it is a gate.

## Running it

```bash
cd <brand>/web    # so relative --content/--bridge paths and .secrets/supabase.env resolve
node ../../eywa-protocol-spec/scripts/clinical-gates/gen-entity-clinical.mjs --brand <brand_id> [--out <path>]
node ../../eywa-protocol-spec/scripts/clinical-gates/check-clinical.mjs --brand <brand_id> \
  [--content <dir>] [--bridge <path>] [--collections <csv>] [--strict] [--no-yaml] [--self-test]
```

- `--brand <brand_id>` (required on both) — `vth-biodent` · `deezy-dental` · `smile-scape-clinic` (or
  a future brand's own id). `gen-entity-clinical.mjs` only prints it in the summary line — the map
  it builds is brand-independent (see below). `check-clinical.mjs` uses it to filter
  `seo_website_page_master` down to that brand's Live pages.
- `gen-entity-clinical.mjs --out <path>` — where the JSON is written; default
  `src/data/entity-clinical.json` relative to the working directory.
- `check-clinical.mjs --content <dir>` — default `src/content`.
- `check-clinical.mjs --bridge <path>` — default `src/data/entity-clinical.json`; the committed file
  this gate checks freshness and quality against.
- `check-clinical.mjs --collections <csv>` — default `service,procedure,diagnostic`; a collection
  directory that does not exist for a brand is skipped rather than raised as an error.
- `check-clinical.mjs --strict` — coverage gaps (check 2) FAIL instead of WARN.
- `check-clinical.mjs --no-yaml` — legacy YAML `contraindication:` copies (check 4) FAIL instead of WARN.
- `check-clinical.mjs --self-test` — runs every real check against real data, then injects one fake
  freshness diff and one fake duplicate-item quality fail into the in-memory results and asserts
  that forces exit 1. Proof the gate bites, without touching real data. Exits 1 on success (that IS
  the passing outcome for this mode) with a trailing `self-test: OK` line.

Credential lookup (same order as `scripts/writer-brief/page-brief.mjs`'s `findKey()`, exported from
`gen-entity-clinical.mjs` and shared by both scripts):
1. `SUPABASE_SERVICE_KEY` in the environment
2. `EYWA_SECRETS_ENV` pointing at a file holding `SUPABASE_SERVICE_KEY=...`
3. `.secrets/supabase.env`, walking up from the working directory

Zero npm dependencies — plain `fetch` against PostgREST
(`https://lffcbeszjqzioobqfdav.supabase.co/rest/v1/`). That is the whole reason this lives here as
its own file rather than an import: this repo has no `node_modules`, and the VTH originals'
`@supabase/supabase-js` (gen) and `yaml` (check) imports cannot run from it.

## Exit codes (`check-clinical.mjs`)

- `0` — clean pass.
- `1` — the gate ran and found a problem: the bridge is stale, a quality cap is exceeded, a
  duplicate item exists, or (with the matching flag) a coverage gap or legacy YAML copy exists.
- `2` — the gate could not run at all: no `--brand`, no Supabase key, or a live query failed. A gate
  that cannot run is not a gate that passed — never conflate this with `0`.

## What each check does

1. **freshness** (always FAIL-capable) — rebuilds the map live from the database
   (`buildClinicalMap()`) and deep-equals it against the committed bridge file. A bridge that does
   not exist yet (a brand's first run) is treated as `{}`, not as a reason to abort — every DB entry
   then reports as `added`, the rest of the checks still run, and the verdict line still prints.
2. **coverage** (WARN, `--strict` → FAIL) — every Live page in `--collections` whose `primaryEntity`
   resolves to a `seo_entity_graph.entity_type` of `procedure` / `treatment` / `device` / `drug`
   must have `>=1` item in the committed bridge.
3. **quality** (WARN/FAIL, on every entity already in the bridge, independent of coverage) — more
   than 8 items warns, more than 15 FAILs (protocol cap); any item over 220 characters warns;
   duplicate items (trimmed, exact string match) FAIL.
4. **legacy YAML** (WARN, `--no-yaml` → FAIL) — a page still carrying a non-empty hand-typed
   `contraindication:` array. Nothing renders it; it is dead weight left over from before the bridge
   existed.

## What differs from the VTH original

The VTH originals hardcoded `BRAND = 'vth-biodent'`, `CONTENT_DIR`, `BRIDGE_PATH` and `COLLECTIONS`,
used `@supabase/supabase-js` (gen) and the `yaml` npm package (check), and — because VTH always has
a generated bridge already — never had to handle a brand running the gate before its first bridge
exists. This port:

- Takes `--brand <brand_id>` (required on both scripts) instead of a hardcoded id, plus
  `--content` / `--bridge` / `--collections` on `check-clinical.mjs` instead of hardcoded paths.
- Uses plain `fetch` against PostgREST instead of `@supabase/supabase-js` (gen) — this repo has no
  `node_modules`. The PostgREST filters are the literal equivalents of the original's supabase-js
  calls: `.not(column, 'is', null)` → `${column}=not.is.null`,
  `.or('entity_lifecycle.ilike.merged,entity_lifecycle.ilike.dropped')` →
  `or=(entity_lifecycle.ilike.merged,entity_lifecycle.ilike.dropped)`.
- Replaces the `yaml` npm package with `scanYamlLite()`, a minimal line scanner — not a YAML parser
  — built for exactly the three signals this gate needs: a top-level `primaryEntity:` value (quotes
  stripped), a top-level `published: false`, and a top-level `contraindication:` block's item count
  (items may be indented or at column 0 — the VTH data has both: 37 zero-indent lists and 6 indented
  ones the day the legacy copies were deleted). Comment lines (`#`) are ignored. Because it is a line
  scanner rather than a parser, the old "YAML parse error" failure mode no longer applies —
  malformed YAML elsewhere in the file simply does not affect what this gate reads.
- Treats a missing bridge file as `committed = {}` (a reportable freshness FAIL) instead of a hard
  `process.exit(2)` — the VTH original never needed this because VTH's bridge already exists; a
  brand running this gate for the first time has no bridge yet, and the gate should still report
  coverage/quality/legacy for that brand rather than stopping before the verdict line.
- Skips a `--collections` directory that does not exist for a brand instead of throwing `ENOENT`.
- Drops the `parseErrors` counter — it existed only to catch `yaml` parse exceptions, which
  `scanYamlLite()` cannot throw.
- `findKey()` is exported from `gen-entity-clinical.mjs` and imported by `check-clinical.mjs`, so
  both scripts share one credential-lookup implementation instead of `check-clinical.mjs` reading
  `process.env.SUPABASE_SERVICE_KEY` directly (which would skip the `EYWA_SECRETS_ENV` / walk-up
  fallback that running this gate without a brand's own npm wrapper — e.g. straight from another
  brand's checkout, as a sanity check — depends on).
- Everything else — the four checks, the WARN/FAIL caps, the verdict-line wording, the
  `--strict` / `--no-yaml` / `--self-test` semantics, the 0/1/2 exit contract — is unchanged.

## Adopting in a brand

1. Add `gen:entity-clinical` and `check:clinical` npm scripts pointing at this directory (see
   `eywa-vth-biodent/web/package.json` for the exact `--env-file-if-exists` + `${EYWA_SPEC:-...}`
   pattern used by every other protocol-repo script), run `npm run gen:entity-clinical`, and commit
   the resulting `src/data/entity-clinical.json`.
2. Render the list somewhere: a block component reads the bridge for the page's `primaryEntity` and
   renders it on the templates that ARE the procedure/device (Service · Procedure · Diagnostic ·
   Technology) — reference implementation
   `eywa-vth-biodent/web/src/components/blocks/SafetyDisclosures.astro`.
3. Wire the same bridge into `schema.ts` so it emits the identical array into
   `MedicalProcedure.contraindication` — the screen and the JSON-LD must not be able to disagree.
4. Delete the YAML `contraindication:` copies once every page has migrated onto the bridge.
5. Wire `check:clinical -- --strict --no-yaml` into CI, after the other DB-backed gates (so a
   missing `SUPABASE_SERVICE_KEY` in a fork/PR context skips it the same way the other gates do).
6. For every entity this gate lists as `MISSING`, run the reviewer pipeline to source and verify its
   contraindications before backfilling the extension table — this gate checks that a list exists,
   never that one is clinically correct.

## Filling the table

Entities the gate lists as `MISSING`, and lists that exist but were never verified, go through `review-kit/` (briefs → PubMed-reading reviewers → generated SQL the operator runs). See `review-kit/README.md`.
