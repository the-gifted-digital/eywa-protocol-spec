# review-kit — how a brand fills or re-verifies the contraindication lists (DR-069 §6)

The table is the store; this is how you put verified text into it. vth-biodent ran it twice on
2026-09-17/18 (16 empty entities → 117 items; 24 existing lists → 153 items) — the files here are the
protocol copies of what was used, with brand/date as arguments.

## Steps

1. **Queue** — `node ../clinical-gates/check-clinical.mjs --brand <id>` lists `MISSING <slug> · primaryEntity=<fp>`:
   these are the entities with no list (round 1). Entities that already have a list and render are round 2.
2. **Briefs** — one markdown per cluster (4–5 entities), containing per entity: `ai_entity_summary`, the
   existing table row (if any), any DR-013 `contraindicates` edges, and per page: the writer's hand-typed
   items (from YAML or git history), the page's `safety` items and `whoFor` (context), and every citation
   bound to the page with its `key_findings`. Pull with PostgREST; the vth session's pull is in
   `eywa-vth-biodent` chat history, not scripted — 40 lines of python, brand-specific joins.
3. **Reviewers** — one agent per cluster, model with clinical judgement, PubMed tool access, given
   `REVIEW-INSTRUCTIONS-round1-backfill.md` (empty entities) or `REVIEW-INSTRUCTIONS-round2-existing.md`
   (live lists). Output: `out-<cluster>.json` in the shape the instructions define.
4. **Judge** — read every item yourself before it goes near the table (brand names, doses, page-specific
   phrasing on an entity-level list, "not a contraindication" inside a contraindication list).
5. **SQL** — `python3 gen-backfill-sql.py --brand <id> --date YYYY-MM-DD` (round 1: inserts guarded by
   `not exists` + updates) or `python3 gen-review-sql.py --brand <id> --date YYYY-MM-DD` (round 2: updates only,
   needs `round2-scope.json` = `{entity_fp: {table: procedures|devices}}`). Both take a backup of the touched rows,
   append PMIDs to `load_source`, cap at 8, order strength 3→2→1, and write `review.md` / `review-r2.md`.
6. **Run** — the operator pastes the SQL into the Supabase SQL editor (cheap, reviewable, no MCP permission
   prompts), then `npm run gen:entity-clinical`, commit the bridge, `check:clinical --strict --no-yaml`, push.

## Approval

DR-069 §5: an item is approved when it rests on a recognised guideline / SR-MA / universal absolute and the
source is in `load_source`. No per-item signature. Clinic-specific facts (which product, in-house or referred)
are the operator's — put them in the review copy as questions, apply the answers with a small follow-up SQL.
