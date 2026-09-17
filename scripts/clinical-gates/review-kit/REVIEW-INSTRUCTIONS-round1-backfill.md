# Contraindication backfill — reviewer instructions (round 1: entities with NO list yet)

Protocol copy of the brief used by vth-biodent on 2026-09-17 (DR-069). Replace `<brand>` and the folder paths with yours.

You are producing the patient-facing "who must be assessed before / who should not have this" list for
each ENTITY in your cluster brief. The list goes into the shared clinical table
`seo_entity_procedures.contraindications` and is rendered verbatim on the treatment page and emitted
in JSON-LD. It is read by patients, by Google (YMYL), and later by a dentist who signs off. Wrong or
over-claimed items are worse than missing items.

## Inputs (all in your brief file)
- `ai_entity_summary`, ICD, parent, any existing table row, any existing `contraindicates` edges.
- Per page: the writer's hand-typed `contraindication` items (citation-backed on the page but never
  checked against the table), the page's `safety` items and `whoFor` cards (context only), and the
  citations bound to the page with their `key_findings`. Lines starting with 🔴 inside key_findings are
  standing orders from the pool (e.g. "do not name drugs", "do not present as a service") — obey them.

## What to produce for EACH entity
1. **Candidate set** = union of all hand-typed items across its pages + existing table/edge items +
   anything the bound citations clearly establish + well-known contraindications from guidelines you
   can verify (see evidence rules). De-duplicate by meaning.
2. **Verify each candidate**: keep it only if at least one of
   - a bound citation's key_findings / abstract supports it (cite its PMID), or
   - a PubMed search finds a guideline, systematic review or position paper that supports it — use the
     PubMed tools available to you, read the abstract, and cite the PMID you actually read, or
   - it is a universally accepted absolute contraindication (e.g. active acute infection at the site,
     documented allergy to the material) — mark `evidence: ["consensus"]` and `strength` accordingly.
   Never invent a PMID. If you cannot verify, drop it and say why in `dropped`.
3. **Write the kept items** in patient-readable Thai, one condition per item, ≤ 160 characters,
   pattern `<ภาวะ> — <สิ่งที่ต้องทำ: ประเมินก่อน / ควบคุมก่อน / ไม่ควรทำ>`. No drug brand names, no
   doses (พ.ร.บ.ยา ม.88). Generic drug classes are fine ("ยาต้านการสลายกระดูก"). No `[label](entity:slug)`
   link markup — plain text only. No marketing, no reassurance, no "ปลอดภัย 100%".
4. **Classify** `strength`: 3 = absolute (never do it while this holds), 2 = relative (assess / control
   first, may proceed), 1 = caution (inform, monitor). Strength 3 items require a dentist's sign-off
   before they go live — list them again under `signoff_required`.
5. **Cap**: at most 8 items per entity (protocol cap). If you have more, keep the 8 with the strongest
   evidence and highest patient relevance and put the rest in `dropped` with reason `cap`.
6. Order the kept list: strength 3 first, then 2, then 1.

## Output — write ONE file: `<same folder>/out-<cluster>.json`
```json
{
  "cluster": "<name>",
  "entities": [
    {
      "entity_fp": "dental-implant",
      "insert_row": true,
      "items": [
        { "text_th": "…", "strength": 2, "evidence": ["PMID:12345678", "guideline: AAOMS MRONJ 2022"], "source": "yaml|table|edge|citation|guideline", "note": "…optional…" }
      ],
      "dropped": [ { "text": "…", "why": "unverifiable | duplicate | cap | over-claim | out of scope" } ],
      "signoff_required": [ "…text_th of every strength-3 item…" ],
      "confidence": "high|medium|low",
      "reviewer_note": "one or two sentences: what was hard, what a dentist must check"
    }
  ]
}
```
`insert_row` = true when the brief says the entity has NO existing `seo_entity_procedures` row.

## Return to the caller
Only: the output file path, then per entity the item count, the number of strength-3 items, and the
confidence. No item text in the return message — it is in the file.

## Constraints
- Work only from your brief file, the PubMed tools, and your own clinical knowledge; you have no
  database access and must not try to obtain any.
- Temp files, if any, go under `<your work folder>/` — never `/tmp`, never `/Users`.
- Do not edit any repository file.
