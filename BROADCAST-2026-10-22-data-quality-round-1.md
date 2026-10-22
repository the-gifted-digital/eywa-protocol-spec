# ทุกเว็บ: data-quality round 1 — "หนึ่ง intent = หนึ่ง URL" บังคับที่ DB แล้ว · view conversion เปลี่ยนความหมาย · semantic list ถูกล้าง

จาก eywa-protocol-spec · apply บน production (GTGT `lffcbeszjqzioobqfdav`) 2026-10-21/22 ตรวจแล้ว · Bible **v3.36** · Schema **v1.25** · Decision Records **v1.43** (DR-076)

---

## ทำไมต้องมีฉบับนี้

ตรวจคุณภาพข้อมูลทั้ง DB แล้วเจอ 4 เรื่องที่ทำให้ตัวเลขผิดเงียบ ๆ: (1) `v_tsa_keyword_conversion` เอายอดของ**หน้า**ไปแปะทุกคีย์ที่ติดหน้านั้น (คีย์ที่มี 1 impression โชว์ LINE click 34 ของหน้าแรก) (2) semantic keyword ซ้ำข้ามหน้า/ชน target ได้โดยไม่มีอะไรกัน (3) `keyword_use_as` ไม่ตรงกับหน้า (4) ไม่มี view ไว้ตรวจ keyword ชนกัน / citation ที่ tier ไม่ตรง study_type — ทั้งหมดแก้แล้ว migration อยู่ใน `migrations/` (final ห้ามแก้)

## สิ่งที่เปลี่ยนใน DB

| Migration | สิ่งที่ทำ |
|---|---|
| w1a | `v_tsa_keyword_conversion` **นิยามใหม่**: นับเฉพาะ `entry_channel='organic_search'` · `conversions_28d` / `sessions_28d` / `line_clicks_28d` / `call_clicks_28d` เป็นตัวเลข**ระดับคีย์** = ยอด organic ของหน้า × สัดส่วน GSC click ของคีย์ในหน้านั้น 28 วัน · คอลัมน์ใหม่ `gsc_clicks_28d` `gsc_click_share_28d` `page_organic_conversions_28d` `page_organic_line_clicks_28d` `page_organic_call_clicks_28d` `attribution_method` (`gsc_click_share_28d` / `none` / `unattributed_no_gsc_clicks`) |
| w1b | view ใหม่ `v_page_keyword_conflicts` — คีย์ที่ใช้บน 2+ หน้า active (target หรือ semantic) · ควรได้ 0 แถว |
| w1c | view `v_citation_type_mismatch` ถูกสร้าง 2026-10-21 แต่ถูกแทนที่ด้วย gate G14 (`scripts/citation-gates/run-citation-qa-gates.py`) — จะถูก drop · อย่าใช้ |
| w1d | ฟังก์ชัน `seo_entity_name_list(name, aliases)` (อ่าน alias ทั้ง 2 รูปแบบ) · `v_keyword_near_duplicates` จับคู่คีย์ที่เท่ากับชื่อ/alias ของ entity เดียวกันเพิ่ม (+223 คู่) · คอลัมน์ใหม่ `match_reason` `entity_fp` |
| w5a | ล้าง semantic keyword ที่อยู่บน 2+ หน้า active ของแบรนด์ หรือเท่ากับ target ของหน้าใด (รวมของตัวเอง) **ออกจากทุกหน้าที่ลิสต์** · dedupe ในอาร์เรย์ · หน้า Merged/Dropped ว่าง · 807 คีย์ที่ชน |
| w5b | trigger `trg_page_keyword_no_reuse` บน `seo_website_page_master` + GIN index `idx_page_master_semantic_fps` |
| w5c | `keyword_use_as` ปรับตามหน้า 452 แถว (420 `semantic_keyword` ที่ไม่อยู่หน้าไหน → null · 29 target null → `target_keyword` · 2 → `semantic_keyword` · 1 legacy → null) · `excluded` (212) ของ operator ไม่แตะ · trigger ใหม่ `trg_release_keyword_use_as_on_delete` (ลบหน้าแล้วคืนคีย์) |

## ตัวเลขต่อแบรนด์ (semantic entries ก่อน→หลัง)

| แบรนด์ | ก่อน | หลัง | หมายเหตุ |
|---|---|---|---|
| deezy-dental | 1,897 | 1,631 | |
| smile-scape-clinic | 1,052 | 215 | ชนหนักสุด |
| vth-biodent | 1,291 | 455 | + ล้าง 89 entries บน 24 หน้า Merged |
| vitalsleep-clinic | 294 | 294 | ไม่เปลี่ยน (importer ใช้กฎ no-reuse อยู่แล้ว) |

รวมสำรองก่อนล้างที่ตาราง `bak_page_semantic_20261022` (1,039 หน้า / 4,625 entries)

trigger `trg_page_keyword_no_reuse` ปฏิเสธเมื่อ: target อยู่ใน semantic ของหน้าตัวเอง · semantic ซ้ำกันเอง · semantic = target ของหน้าอื่น · target/semantic เป็น semantic ของหน้า active อื่นในแบรนด์เดียวกัน · หน้า Merged/Dropped ถือ semantic · **ไม่มี lock** — เขียนพร้อมกันอาจลอด ให้รัน `v_page_keyword_conflicts` หลัง bulk import

## ทุก session ต้องทำ

1. **importer / สคริปต์เขียน page master:** เขียนลง `target_keyword_fp` / `semantic_keywords_fps` แล้วอาจเจอ `raise exception` ขึ้นต้น `page <fp>: …` (บอกคีย์ที่ชนและหน้าที่ถือ) · dedupe ก่อนเขียน, catch error ต่อแถว, รายงาน — อย่าให้ bulk upsert ล้มทั้ง statement เงียบ ๆ · มีแค่ importer ของ vitalsleep ที่ใช้กฎนี้อยู่แล้ว
2. **ใครอ่าน `v_tsa_keyword_conversion`:** **เลิก** SUM `conversions_28d` ต่อ slug ตามคำแนะนำของ `DR-EYWA-TSA-003` — คอลัมน์ระดับคีย์ตอนนี้ apportion แล้ว (SUM ข้ามคีย์ของหน้าเดียวกันได้) · ยอดระดับหน้าอยู่ที่ `page_organic_*` · ยอดทุก channel ไม่อยู่ใน view นี้แล้ว ให้ query `tsa_bond` ตรง · `DR-EYWA-TSA-003` ในแต่ละแบรนด์ให้เพิ่มหมายเหตุว่าถูกแก้โดย DR-076
3. **semantic list บางมากชั่วคราว:** จะมีรอบ re-allocate ทั้งชุดตามมา — ระหว่างนี้อย่าเติม semantic keyword ด้วยมือเพื่อ "ให้เต็ม" และอย่าถือว่ารายการที่หายคือบั๊ก
4. **deezy:** แก้ไฟล์ `deployment/supabase-load/43_tsaheylu_keyword_conversion.sql` ใน repo ของ deezy ให้ตรงกับนิยามใหม่ (ไฟล์ยังเป็นนิยามเก่า — รันซ้ำจะทับของใหม่ใน DB) โดยคัดจาก `migrations/2026-10-21_w1a_…sql`
5. ใครเขียนคีย์ใหม่: ดู Keyword_Assignment_SOP §10.1 (วิธีอ่าน error, `match_reason`)

## Rollback (ถ้าจำเป็น)

- **semantic list (w5a):** คืนจาก `bak_page_semantic_20261022` — statement อยู่ใน comment หัวไฟล์ migration w5a · ต้อง drop/disable `trg_page_keyword_no_reuse` ก่อน (ไม่งั้น trigger จะปฏิเสธข้อมูลเก่าที่ชนกัน) แล้วค่อยเปิดกลับ
- **trigger (w5b / w5c):** `drop trigger trg_page_keyword_no_reuse` / `trg_release_keyword_use_as_on_delete` + drop function ที่เกี่ยวข้อง · index `idx_page_master_semantic_fps` ปลอดภัยที่จะคงไว้
- **view (w1a–w1d):** นิยามเดิมไม่ใช่ปลายทางที่ต้องการ — ถ้าต้องถอยให้ใช้นิยามจากไฟล์ deezy `43_…sql` (เก่า) · `v_keyword_near_duplicates` ถอยได้โดยสร้างใหม่ไม่มี 2 คอลัมน์ท้าย · `keyword_use_as` (w5c) ไม่มี backup แยก ถอยจาก backup รายวันของ Supabase
- ทุกอย่างถูกตรวจบน production หลัง apply: conflicts = 0, use_as drift = 0, trigger test บล็อก 4 เคสเขียนผิด และปล่อยการเขียนปกติ

## ถัดไป (ยังไม่ทำ)

W3 knowledge graph (ตาราง ICD/MeSH code · dedupe entity — alias 283 ชื่อชี้ 2+ entity ทำให้ edge ผิด) · แก้ citation ผ่าน gate G14 · `v_page_priority` · รอบ re-allocate semantic keyword · แก้ importer ต่อแบรนด์ให้จัดการ trigger error
