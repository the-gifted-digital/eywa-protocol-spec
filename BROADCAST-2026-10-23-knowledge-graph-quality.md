# ทุกเว็บ: knowledge-graph data quality (W3.0–W3.3) — รหัส ICD/MeSH, dedupe entity, edge verification · `entity_lifecycle` เป็น Title case · MeSH บน procedure/device

จาก eywa-protocol-spec · apply บน production (GTGT `lffcbeszjqzioobqfdav`) 2026-10-22/23 · Bible **v3.39** · Schema **v1.27** · Decision Records **v1.46** (DR-079)

> header ของไฟล์ migration (`migrations/2026-10-22_w30 … w33b`) เขียนว่า "DR-078" — เลขนั้นถูก DR page change history ใช้ไปก่อน จึง renumber เป็น **DR-079** ในเอกสาร (ไฟล์ migration ไม่ถูกแก้)

---

## ทำไมต้องมีฉบับนี้

ตัวเลข "1 จาก 741 entity มี ICD" ใน handover วัดคอลัมน์ `seo_entity_graph.icd_10_code` ที่ปลดระวางแล้ว (DR-050) ไม่ใช่ความครอบคลุมจริง (จริงคือ ICD-10 91/118 conditions และหลายตัวเป็นรหัส CM ที่ไปอยู่ในคอลัมน์ WHO) และ graph มีปัญหาที่ทำให้ edge/หน้าผิดเงียบ ๆ: `aliases` 3 รูปแบบ, `entity_lifecycle` ปนตัวพิมพ์เล็ก/ใหญ่, entity ซ้ำ 21 ตัว, alias ผิด 106 รายการ, Wikidata id ผิด, edge `treats`/`symptom_of`/`is_a` ที่ไม่เคยถูกตรวจกับแหล่งจริง

## การตัดสินใจหลัก (DR-079)

- **รหัสอยู่ใน store เดิมของ DR-050** (`seo_entity_condition` / `_symptom` / `_drug` ...) — ข้อเสนอตาราง `seo_entity_codes` ใหม่ถูกปฏิเสธ (ซ้ำกับ one store per fact)
- **MeSH เป็น identifier ของ procedure / treatment / device:** คอลัมน์ใหม่ `mesh_id` บน `seo_entity_procedures` และ `seo_entity_devices` (CHECK `^[DC][0-9]{6,9}$`) ระบุตัวหัตถการ/อุปกรณ์เอง ไม่ใช่โรคที่รักษา · ชื่อแบรนด์/ผลิตภัณฑ์ไม่มี MeSH
- **Residual-code rule ปรับ:** ICD-10 ".8" ใช้ได้เมื่อ WHO ระบุ concept ตามชื่อเป็น inclusion term (F45.8 "Teeth-grinding", F98.8 "Thumb-sucking", K08.8 "Toothache NOS", K03.8 "Sensitive dentine") · "unspecified" / .Z / .Y ยังห้าม · คอลัมน์ `icd10_code` (WHO) ยาวไม่เกิน 4 ตัวอักษร รหัส CM-only (G47.63, R06.83, K08.89, Z91.041 ...) ไป `icd10_cm_code`
- **`aliases`** คง TEXT เป็น comma list ธรรมดา + CHECK `chk_entity_aliases_plain_list`
- **`entity_lifecycle`** เป็น Title case (Emerging / Growing / Mature / Merged / Dropped) + CHECK + trigger `trg_normalise_entity_lifecycle` (script ที่เขียน `'merged'` ยังทำงาน)
- **Edge verification แยกจาก MD sign-off:** `evidence_verified_at` / `evidence_verified_by` (`agent:<source>` หรือ `human:<fp>`) — `medical_reviewer_signoff_*` ยังสงวนไว้ให้แพทย์ที่ระบุชื่อ ห้ามนำเสนอ agent-verified เป็น MD sign-off

## สิ่งที่เปลี่ยนใน DB

| Migration | สิ่งที่ทำ |
|---|---|
| w30 | `aliases` เป็น comma list เดียว + `chk_entity_aliases_plain_list` · `entity_lifecycle` Title case + `chk_entity_lifecycle` + `trg_normalise_entity_lifecycle` · edge `related_to` 2 เส้นที่ชี้ entity Dropped → `deprecated` · backup `bak_entity_graph_w30_20261022` |
| w31 | merge entity ซ้ำ **21** ตัว (DR-042; repoint reference **16 คอลัมน์** รวม `seo_media_assets`, `seo_reviews.mentioned_entities_fps`, `condition.symptom_entities_fps`, `procedures.contraindication_entities_fps`, llm simulations — `tsa_bond.primary_entity` **ไม่แตะโดยตั้งใจ** เป็น event history) · ลบ alias ผิด **106** · สร้าง `is_a` parent/child **50** · view `v_entity_near_duplicates` / `v_entity_semantic_duplicates` แก้ให้เทียบ lifecycle ด้วย `lower()` · backup `bak_w31_20261022_{graph,rels,pages,kw,ext}` |
| w32a | `mesh_id` บน procedures + devices |
| w32b | Wikidata id ที่ตัดสินด้วยมือ (ไม่ทับค่าเดิม) · ล้าง id ผิด 1 ตัว (periodontal-surgery → "pedicled flap") |
| w32c | ยก list columns ของ 7 คู่ที่ merge ไปไว้ที่ winner · `root-canal-treatment` `anesthesia_required` / `requires_followup` → true · backup `bak_w32c_20261022` |
| w32d | เติม/แก้ ICD/MeSH **183** รายการ (condition/symptom) + MeSH **43** id (procedure/device) จากแหล่งทางการเท่านั้น (WHO ICD-10 2019 + 10To11 map, ICD-11 MMS 2025-01, ICD-10-CM, NLM MeSH) · ICD-11 7 ค่าเป็น Foundation numeric id ไม่ใช่ MMS → แก้ · nickel-allergy Z91.041 (แพ้สีย้อมรังสี) → L23.0 · backup `bak_w32d_20261022` |
| w33a | คอลัมน์ `evidence_verified_at/_by` + CHECK · ปรับ residual-code rule (คืน K08.8 / K03.8) |
| w33b | ตรวจ edge **293** เส้น เปิดทุกลิงก์ที่อ้าง (**112 จาก 209** ต้องเปลี่ยน: หน้า search, ลิงก์ตาย, paper ผิด) · backup `bak_w33b_20261022` |

## ตัวเลข

| เรื่อง | ผล |
|---|---|
| entity ซ้ำที่ merge | 21 (เหลือ 2 cluster ให้คนตัดสิน: airway-biomapping vs mbm-airway-analysis; muscle- vs tmj-posture-recovery) |
| alias ผิดที่ลบ | 106 |
| `is_a` ใหม่ | 50 |
| ICD-10 (WHO) ของ condition active | 78/115 · ICD-11 71 · MeSH 87 |
| MeSH | procedures 69 · devices 15 |
| Wikidata proposals ที่ผิดจาก `verify-entity-ids` | 12 จาก 21 |
| edge ที่ตรวจ | 293 → **verified 164** · retype/กลับทิศ **29** (ส่วนมาก `symptom_of` → `caused_by`/`causes`) · **deprecated 15** (ผิดทางคลินิก เช่น apicoectomy treats peri-implantitis, Neodent is_a Straumann implant, awake/pediatric/stress bruxism is_a sleep bruxism → `is_a bruxism` ตาม 2018 international consensus) · **flagged_review 85** (ส่วนมากเป็น programme ของแบรนด์) |

edge ไม่ถูกลบ — ใช้ status `deprecated`

## ทุก session ต้องทำ

1. **โค้ด/SQL ที่เทียบ `entity_lifecycle`:** ใช้ `lower(entity_lifecycle) = 'merged'` (ค่าใน DB เป็น Title case แล้ว) · script ที่เขียน `'merged'` / `'dropped'` ยังทำงานได้เพราะ trigger normalise ให้
2. **ห้ามเขียน `aliases` เป็น array format** (`{a,"b c"}`) — เขียน `a, b, c` เท่านั้น ไม่งั้น CHECK ปฏิเสธ · อ่านด้วย `string_to_array(aliases, ',')` หรือ `seo_entity_name_list(name, aliases)`
3. **MeSH ตอนนี้อยู่บน procedure/device:** อ่าน `seo_entity_procedures.mesh_id` / `seo_entity_devices.mesh_id` ไปทำ schema markup/`sameAs` ได้ · อย่าใส่ ICD ให้ procedure/device · ชื่อแบรนด์/ผลิตภัณฑ์ไม่ต้องมี MeSH
4. **icd10_code (WHO) ห้ามใส่รหัส CM** — CM-only ไป `icd10_cm_code` · re-run export JSON-LD (`gen-entity-schema`) เพราะรหัสหลายตัวถูกแก้
5. **edge `flagged_review` ต้องรอ MD ของแบรนด์** — อย่าใช้เป็นข้อเท็จจริงบนหน้า/ใน schema จนกว่า MD ยืนยัน · edge `deprecated` ห้ามใช้ · `evidence_verified_*` ไม่ใช่ MD sign-off ห้ามอ้างว่าแพทย์รับรอง
6. **vth MBM:** แถว module ของ MBM คงเป็น entity แยก ผูกกับ concept ร่วมด้วย `is_a` (ไม่ merge) — อย่า merge เอง
7. **อย่ารัน `verify-entity-ids.mjs --apply` แบบไม่อ่านผล** — เขียนทุก proposal และ 12 จาก 21 ผิด (ห้างสรรพสินค้า, วารสาร, 'osteoporosis' แทน alveolar bone loss) · ให้คนอ่าน label + description ตามสามด่านใน Entity_Identity_SOP §2 · harvest/verify ข้าม entity ที่ Merged/Dropped แล้ว (pull scripts ล่าสุด)
8. **ถ้า repoint/อ้าง entity fp ที่ถูก merge:** ใช้ fp ของ winner (ดู `bak_w31_20261022_graph` ถ้าต้องหา mapping) · `tsa_bond.primary_entity` ยังเป็นค่าเดิมของ event

## Rollback (ถ้าจำเป็น)

backup อยู่ที่ `bak_entity_graph_w30_20261022`, `bak_w31_20261022_{graph,rels,pages,kw,ext}`, `bak_w32c_20261022`, `bak_w32d_20261022`, `bak_w33b_20261022` — statement คืนค่าอยู่ใน comment หัวไฟล์ migration/table comment · ลบ backup เมื่อ operator ยืนยันข้อมูลแล้ว

## ถัดไป (ยังไม่ทำ)

- **W3.4** keyword→entity mislink review — รอให้ legacy brands ผูก target keyword ครบก่อน (session อื่นกำลังผูก target-only ให้ the-face-by-vertex, tc-smile-dental, clearisma) · operator: semantic binding รอ re-allocation pass เต็มรอบ
- ~22 entity ที่ `entity_type` ผิด (device/prosthesis เก็บเป็น procedure, material เป็น device, software เป็น device)
- retype `related_to` (426 เส้น)
- 85 edge `flagged_review` ต้องให้ MD ของแต่ละแบรนด์ตรวจ
- `v_keyword_near_duplicates` ช้า (timeout) — ตัวเลือก materialized view
