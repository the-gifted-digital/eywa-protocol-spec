# review-kit — how a brand fills or re-verifies the contraindication lists (DR-069 §6)

The table is the store; this is how you put verified text into it. vth-biodent ran it twice on
2026-09-17/18 (16 empty entities → 117 items; 24 existing lists → 153 items) — the files here are the
protocol copies of what was used, with brand/date as arguments.

## Steps

1. **Queue** — `node ../clinical-gates/check-clinical.mjs --brand <id>` lists `MISSING <slug> · primaryEntity=<fp>`:
   these are the entities with no list (round 1). Entities that already have a list and render are round 2.
2. **Briefs** — `python3 build-briefs.py --brand <id> --clusters clusters.json --content web/src/content --out <dir>`
   (from deezy, `c4b107f`; read-only; credentials via `../citation-gates/eywa_supabase.py` `key()`; needs PyYAML).
   One markdown per cluster (4–5 entities): `ai_entity_summary`, the existing table row, DR-013 edges, and per
   page the writer's hand-typed items, `safety` / `whoFor` context and every bound citation with `key_findings`.
   `clusters.json` = `{cluster: [entity_fp, …]}` — `clusters-example-deezy-2026-09-18.json` shows the shape.
3. **Reviewers** — one agent per cluster, model with clinical judgement, PubMed tool access, given
   `REVIEW-INSTRUCTIONS-round1-backfill.md` (empty entities) or `REVIEW-INSTRUCTIONS-round2-existing.md`
   (live lists). Output: `out-<cluster>.json` in the shape the instructions define.
4. **Judge** — read every item yourself before it goes near the table (brand names, doses, page-specific
   phrasing on an entity-level list, "not a contraindication" inside a contraindication list).
5. **SQL** — `python3 gen-backfill-sql.py --brand <id> --date YYYY-MM-DD` (round 1: inserts guarded by
   `not exists` + updates) or `python3 gen-review-sql.py --brand <id> --date YYYY-MM-DD` (round 2: updates only,
   needs `round2-scope.json` = `{entity_fp: {table: procedures|devices}}`). Both take a backup of the touched rows,
   append PMIDs to `load_source`, cap at 8, order strength 3→2→1, and write `review.md` / `review-r2.md`.
6. **Strip the YAML copies** — `python3 strip-contraindication-yaml.py [--apply] [--only slugs.txt] web/src/content`
   (from deezy): dry-run by default, byte-preserving, refuses a file whose parsed YAML would change beyond the
   removed key. Run after the bridge covers every Live page, before flipping the gate to `--no-yaml`.
7. **Run** — the operator pastes the SQL into the Supabase SQL editor (cheap, reviewable, no MCP permission
   prompts), then `npm run gen:entity-clinical`, commit the bridge, `check:clinical --strict --no-yaml`, push.

## Approval

DR-069 §5: an item is approved when it rests on a recognised guideline / SR-MA / universal absolute and the
source is in `load_source`. No per-item signature. Clinic-specific facts (which product, in-house or referred)
are the operator's — put them in the review copy as questions, apply the answers with a small follow-up SQL.
