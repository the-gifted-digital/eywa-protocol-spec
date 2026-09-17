# Contraindication review — round 2 instructions (entities whose list ALREADY exists and is live)

Protocol copy of the brief used by vth-biodent on 2026-09-18 (DR-069).

Round 1 (yesterday) built lists for entities that had none. Round 2 reviews the lists that ALREADY exist in
the shared clinical table and are already rendered on the live site as "ใครควรประเมินก่อน" — so every
item you keep or drop changes a live page. Same output contract as round 1, plus a per-item verdict on
the existing list.

Read `REVIEW-INSTRUCTIONS-round1-backfill.md` (round 1) first — the evidence
rules, wording rules, strength scale, cap of 8, ordering and the output JSON shape all still apply.
Differences for round 2:

## Inputs
Your brief lists, per entity: the EXISTING table list (live now), the row's other columns and
`load_source`, any DR-013 edges, and per page: the writer's former hand-typed items (deleted from YAML
yesterday, citation-backed on the page), the page's safety items (shown under the list), whoFor, and the
bound citations with key_findings. Lines beginning 🔴 inside key_findings are pool orders — obey them.

## What to do
1. **Verdict on every existing item** — `keep` (verbatim), `reword` (same clinical fact, better
   patient wording, or a bilingual / terse / jargon fix), or `drop` (unverifiable, not a contraindication
   — e.g. a limitation of the test, an aftercare note, an indication boundary — duplicate, over-claim).
   A limitation ("ภาพถ่ายขณะตื่นจึงไม่สะท้อน…") is NOT a contraindication: drop it and say so; the page's
   safety block already carries limitations.
2. **Add** what the former hand-typed items, the bound citations or a guideline you verify on PubMed
   establish and the existing list lacks. Same evidence rules: a PMID you actually read, or `consensus`
   for universally accepted absolutes. Never invent a PMID.
3. Entities of type **device** (`night-guard`, `zygomatic-system`): the list is the device's, not a
   procedure's — allergy to the material, conditions in which the device must not be worn/placed,
   IFU-level exclusions. Keep it short.
4. `tmj-non-surgical`, `tmj-assessment`, `frenectomy-adult` have one-item lists: decide honestly whether
   the entity really has only one, or whether the row was never finished.
5. Everything else as round 1: patient Thai, one condition per item, ≤ 160 chars, no brand names, no
   doses, no link markup, strength 3 → 2 → 1, cap 8, strength-3 items listed under `signoff_required`.

## Output — write ONE file: `<same folder>/out-<cluster>.json`
Same shape as round 1, with one extra array per entity:
```json
"existing_verdicts": [ { "text": "…existing item verbatim…", "verdict": "keep|reword|drop", "why": "…" } ]
```
`insert_row` is always false in round 2 (every entity already has a row).

## Return to the caller
Only: the output file path; per entity: items kept / reworded / dropped / added, strength-3 count,
confidence. No item text in the return message.

## Constraints
Work only from your brief, the PubMed tools and your clinical knowledge; no database access. Temp files
only under `<your work folder>/`. Do not edit any repository file.
