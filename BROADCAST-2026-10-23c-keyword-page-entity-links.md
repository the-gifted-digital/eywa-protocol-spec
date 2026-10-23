# ทุกเว็บ: ซ่อม + review link keyword/หน้า → entity (W3.4) · `primary_entity_name` ของ keyword ห้ามเขียนมือ · checklist brand-repo ต้องครบทุก repo

จาก eywa-protocol-spec · apply บน production (GTGT `lffcbeszjqzioobqfdav`) 2026-10-23 · Bible **v3.41** · Schema **v1.29** · Decision Records **v1.48** (DR-081) · ต่อจาก [`BROADCAST-2026-10-23b-entity-type-and-priority.md`](./BROADCAST-2026-10-23b-entity-type-and-priority.md) (DR-080)

---

## ทำไมต้องมีฉบับนี้

DR-080 ทิ้ง follow-up "W3.4 keyword→entity mislink review". รอบนี้ซ่อม link ที่เสีย, ผูก keyword ที่ยังไม่ผูก, review เคสที่ต้องใช้วิจารณญาณ และ review หน้าที่ entity ไม่ตรงกับ target keyword. ระหว่างทางพบว่า checklist merge/retype ของ DR-080 ครอบแค่ vth — **Deezy แดงเงียบ ๆ ตั้งแต่ W3.1** — จึงขยาย checklist ให้ครอบทุก brand repo

## สิ่งที่เปลี่ยนใน DB (ทุกแบรนด์ยกเว้น 1 แบรนด์นอกขอบเขต)

| Migration | สิ่งที่ทำ |
|---|---|
| w37a (W3.4a) | 14 link เสียซ่อมแล้ว (Merged/ไม่มี → entity ที่รอด; Dropped → NULL) · ผูก 194 keyword ที่ normalised keyword ตรงกับชื่อ/alias ของ entity live เพียงตัวเดียวใน `brand_scope` · sync `primary_entity_name` ~1.4k แถว · trigger ใหม่ (ด้านล่าง) · backup `bak_w37a_20261023` |
| w37b (W3.4b) | review 145 เคส (queue C: keyword ระบุ entity X แต่ผูก Y · queue D: target keyword entity ≠ page entity) → relink keyword 98 · relink หน้า 3 · ถอด alias ผิด 5 (ฟันหลุด · ฟันหักจากอุบัติเหตุ · ผ่าฟันคุดซับซ้อน · ลูกกลัวหมอฟัน · สมองล้า) · backup `bak_w37b_20261023` (106 แถว) |
| w37c (W3.4c) | review 65 หน้า Live ที่ page entity ≠ keyword entity → relink หน้า 36 (entity เดิมต่อท้าย `related_entities_fps` เมื่อยังเกี่ยวข้อง; `primary_entity_name` ของหน้า refresh) · relink keyword 2 · keep_both 21 · retarget 5 · human 3 · backup `bak_w37c_20261023` (38 แถว) |

ผล: link เสีย 0 · ชื่อเพี้ยน 0 · `v_page_keyword_orphans` 0 · หน้า Live บน entity ที่เลิกใช้ 0 · page/keyword entity ต่างกัน **29 หน้าโดยตั้งใจ** (keep_both 21 + retarget 5 + human 3)

## `primary_entity_name` ของ keyword — ห้ามเขียนด้วยมือ

ตอนนี้เป็นสำเนาของ `seo_entity_graph.entity_name` ที่ DB ดูแลเอง:

- `trg_keyword_entity_name` (BEFORE INSERT OR UPDATE OF `primary_entity_fp`, `primary_entity_name` บน keyword table) — **เขียนทับชื่อจาก graph เสมอ** ค่าที่ส่งมาจะถูกทิ้ง
- `trg_entity_name_to_keywords` (AFTER UPDATE OF `entity_name` บน `seo_entity_graph`) — เปลี่ยนชื่อ entity แล้ว keyword ตามทันที

→ **ตั้งแค่ `primary_entity_fp`** แล้วปล่อยให้ trigger ใส่ชื่อ. Notion sync / SQL ของ brand ที่เคยเขียน `primary_entity_name` ยังไม่พัง แต่ค่าจะถูกเขียนทับเงียบ ๆ

## กฎที่ใช้ตัดสิน (Keyword_Assignment_SOP §3.1)

- primary entity ของ keyword = **สิ่งหลักที่ผู้ค้นหาต้องการ** · modifier ราคา/ค่าใช้จ่าย/รีวิว/ก่อน-หลัง ไม่เปลี่ยน entity · entity แบรนด์/แพทย์ใช้เฉพาะเมื่อ keyword ระบุชื่อ · มี entity ลูกที่เฉพาะเจาะจงกว่า → เลือกลูก
- primary entity ของหน้า = สิ่งที่ schema.org `about`/`mainEntity` ควรระบุ · entity องค์กร/แพทย์ใช้เฉพาะหน้าที่พูดถึงคลินิก/แพทย์
- keyword brand-name 4 ตัว (nobel biocare, osstem, straumann) จะขึ้น queue C ต่อไป **โดยตั้งใจ**

## สถานะ brand repos (รอบเดียวกัน — push แล้ว)

| Brand / branch | ทำอะไร |
|---|---|
| **Deezy** (`feat/web-template-system-port`) | YAML `primaryEntity` 8 ไฟล์ (รวม 3 ตัวตกค้างจาก W3.1: cbct-technology→cbct-scan ×2, cosmetic-bonding→dental-bonding) · regenerate page-master / entity-codes / page-context + `entity-clinical.json` (stale ตั้งแต่ W3.1/W3.6 → `check:clinical` แดงมาตลอด) · token `(entity:…)` 39 จุดใน 35 ไฟล์เนื้อหา เปลี่ยนจาก entity ที่ถูก merge เป็นตัวที่รอด: dental-scaling→scaling-polishing 13 · cbct-technology→cbct-scan 7 · bone-graft-implant→bone-grafting 4 · emergency-toothache→toothache 4 · cosmetic-bonding→dental-bonding 3 · acute-pulpitis→pulpitis 2 · broken-tooth-emergency→tooth-fracture 2 · crowded-teeth→crowding · full-mouth-restoration→full-mouth-rehab · periapical-abscess→dental-abscess · root-canal-retreatment→rct-retreatment |
| **vth-biodent** (`feat/content-templates`) | YAML `primaryEntity` 4 ไฟล์ · regenerate page-context / entity-labels / entity-schema / internal-links / entity-clinical |
| **SmileScape** | ไม่มีอะไรต้องแก้ (ยังไม่มีไฟล์หน้าที่ bind entity) — แต่ retarget `preventing-tooth-decay` ยังค้าง (ดูข้างล่าง) |

## ทุก session ต้องทำ — checklist รอบเดียวกัน ทุก brand repo (Entity_Identity_SOP §6.2)

เมื่อเปลี่ยน identity ของ entity ใด ๆ — **merge, retype, relink หน้าหรือ keyword** — ในรอบเดียวกัน สำหรับ **ทุก brand repo ที่ bind entity (วันนี้ Deezy และ vth)**:

1. แก้ YAML `primaryEntity` **และ** token `(entity:…)` ในเนื้อหา
2. regenerate JSON entity ของ brand รวม `entity-clinical.json`
3. รัน gate: `check:sync` / `check:entity-binding` และ `check:clinical` ก่อน push

**Ops note:** หลัง bulk update entity/keyword ให้ `analyze` ตาราง `seo_x_ads_keywords_contextual_master`, `seo_entity_graph`, `seo_website_page_master` แล้ว `notify pgrst, 'reload schema';` — รอบนี้ PostgREST เรียก `v_seo_entity_inventory` timeout (8 วินาที) ทั้งที่ query เดียวกันรันตรง <2 วินาที; `ANALYZE` + reload schema แก้ได้

อย่าลืม: pull spec ล่าสุดแล้ว bump snapshot เป็น Bible v3.41 / Schema v1.29 / DR v1.48

## ยังเปิดอยู่ (ไม่ได้แก้รอบนี้)

- **retarget 5 หน้า:** Deezy `deep-scaling`, `dental-laser-soft-tissue-surgery` · SmileScape `preventing-tooth-decay` · vth `oral-systemic-aging`, `posture-brain-o2`
- **human:** 3 หน้า + 7 keyword รอ operator ตัดสิน
- **Deezy:** device entity 7 ตัวยังไม่มีรายการ contraindication (`dental-laser`, `intraoral-scanner`, `opg-machine`, `dental-autoclave` — หน้าเหล่านี้เตือนใน `check:clinical`)
- **entity ที่อาจซ้ำ:** `overdenture` vs `implant-denture` · `heart-disease-oral` vs "Gum Disease & Heart Disease" · `o2-cognitive` vs "Oxygen and Brain Performance" · `ambulatory-anesthesia` vs `ga-dentistry`
- **vth cannibal pair:** `mouth-breathing-in-children` / `pediatric-mouth-breathing`
- ต่อจาก DR-080: retype `related_to` (426) · 85 edge `flagged_review` รอ MD แบรนด์ · umbrella-service typing / `lab_test`

## Rollback (ถ้าจำเป็น)

คืนจาก `bak_w37a_20261023` / `bak_w37b_20261023` / `bak_w37c_20261023` (ไฟล์ migration ไม่มี statement คืนค่าสำเร็จรูป) · ปิด trigger: `drop trigger trg_keyword_entity_name on public.seo_x_ads_keywords_contextual_master; drop trigger trg_entity_name_to_keywords on public.seo_entity_graph;`

อ้างอิง: DR-081 (`DECISION_RECORDS.md`) · Keyword_Assignment_SOP §3.1 · Entity_Identity_SOP §6.2/§9 · Schema v1.29 F.13, Appendix I · `migrations/2026-10-23_w37a…w37c`
