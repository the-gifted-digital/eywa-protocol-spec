# ทุกเว็บ: กฎ `entity_type` + retype 12 entity · `v_page_priority` (คะแนนจัดลำดับหน้า) · MV refresh ทุกวัน 07:00 Bangkok · checklist merge/retype ฝั่ง brand repo

จาก eywa-protocol-spec · apply บน production (GTGT `lffcbeszjqzioobqfdav`) 2026-10-23 · Bible **v3.40** · Schema **v1.28** · Decision Records **v1.47** (DR-080) · ต่อจาก [`BROADCAST-2026-10-23-knowledge-graph-quality.md`](./BROADCAST-2026-10-23-knowledge-graph-quality.md) (DR-079)

> header ของ migration `2026-10-23_w34 / w35` เรียกงานนี้ว่า "DR-079 follow-ups" — เอกสารบันทึกเป็น **DR-080** (ไฟล์ migration ไม่ถูกแก้)

---

## ทำไมต้องมีฉบับนี้

DR-079 ทิ้ง follow-up ไว้: ~22 entity ที่ `entity_type` ผิด, `v_keyword_near_duplicates` timeout, และยังไม่มีวิธีจัดลำดับว่าหน้าไหนควรแก้ก่อน (handover data-quality #7). รอบนี้ปิดทั้งสามเรื่อง และเพิ่มกฎที่เรียนมาจาก DR-079 W3.1 — merge entity แล้ว deploy gate ของ vth-biodent แดง เพราะ brand repo ยังชี้ entity เดิม

## สิ่งที่เปลี่ยนสำหรับ brand sessions

1. **`entity_type` ของ 12 entity เปลี่ยน** (ตารางข้างล่าง) — entity เหล่านี้ shared (`brand_scope` `*`) ทุกแบรนด์ที่ใช้ต้อง regenerate (DR-046)
2. **กฎตัดสิน `entity_type` ใหม่** (Entity_Identity_SOP §1.2): procedure/treatment = การกระทำที่ทำ · device = วัตถุ/อุปกรณ์/เครื่อง/วัสดุ หรือ implant/prosthesis variant ตามวัสดุ-ยี่ห้อ · วัสดุคง `device` · ซอฟต์แวร์ที่เป็น medical device ตามกฎหมาย (FDA/CE-cleared เช่น nemostudio, dental-monitoring-ai) คง `device` เพราะ `technology` ไม่มีตาราง ext
3. **`v_page_priority` ใช้ได้แล้ว** — คะแนน 0–100 ต่อหน้า Live (signal 8 ตัว, น้ำหนักอยู่ที่ `seo_priority_weights`) ดู `top_signals` / `suggested_action` เพื่อรู้ว่าควรแก้อะไรก่อน
4. **`v_page_priority` และ `v_keyword_near_duplicates` refresh ทุกวัน 07:00 Asia/Bangkok** (pg_cron job `eywa-refresh-quality-mvs`, หลัง GSC load 06:01 หนึ่งชั่วโมง) — ถ้า import keyword ก้อนใหญ่ระหว่างวัน ให้ `select refresh_keyword_near_pairs();` เอง (~1 นาที)
5. **`v_keyword_near_duplicates` ไม่ timeout แล้ว** — ชื่อและคอลัมน์เดิม อ่านจาก `mv_keyword_near_pairs` ผสมข้อมูลสด; ใช้แทนของเดิมได้เลย
6. **`v_page_keyword_orphans`** — ควรได้ 0 แถว; ถ้าแบรนด์ของคุณมีแถว แปลว่าหน้านั้นชี้ keyword/entity ที่ไม่มีอยู่หรือถูก Merged/Dropped
7. **Checklist ใหม่ (merge / retype):** ในรอบเดียวกับที่ merge หรือ retype entity ต้อง (ก) แก้ YAML entity bindings / bridge files ใน brand repo, (ข) regenerate JSON ที่ brand สร้าง — entity-labels / entity-schema / entity-clinical / entity-codes, (ค) รัน gate ของ brand (เช่น vth `check:clinical`) ก่อน push — Entity_Identity_SOP §6.2

## 12 entity ที่ retype

| entity | จาก | เป็น | หมายเหตุ |
|---|---|---|---|
| `mad` | treatment | **device** | Mandibular Advancement Device; ด้านการรักษาอยู่ที่ `oral-appliance-therapy` · ext row ย้าย procedures → devices |
| `gold-crown` | treatment | **device** | variant ตามวัสดุของ crown |
| `ssc-pedo` | treatment | **device** | stainless steel crown สำเร็จรูป · ext row ย้ายไป devices |
| `orthodontic-retainer` | treatment | **device** | appliance · ext row ย้ายไป devices |
| `thermoformed-aligner` | concept | **device** | aligner vacuum-formed เป็นวัตถุ |
| `dental-autoclave` | technology | **device** | เครื่องนึ่งฆ่าเชื้อ |
| `opg-machine` | technology | **device** | เครื่อง panoramic X-ray (การถ่ายคือ `opg-xray` = procedure) |
| `intraoral-scanner` | technology | **device** | ตัวเครื่องสแกน |
| `dental-laser` | technology | **device** | เครื่องเลเซอร์ (การรักษาคือ `laser-dentistry`) |
| `dental-photography` | technology | **procedure** | การถ่ายภาพคลินิก (MeSH D010781) |
| `pncl-dashboard` | device | **concept** | แดชบอร์ดของแบรนด์ (SOP §8) · แถว device ถูกลบ |
| `dental-anxiety-child` | concept | **condition** | ตรงกับ `dental-anxiety-adult` ที่เป็น condition |

backup: `bak_w36_20261023_entity_type` (17 แถว = 12 graph + 3 procedures + 2 devices) · แถว ext ที่ย้ายคง `mesh_id` / `contraindications`; เพิ่ม stub ext row ที่จำเป็น

**ยังไม่ได้ retype (operator ตัดสิน 2026-10-23 — เลื่อน):** umbrella service entities (`dental-implant`, `dental-crown`, `dental-veneer`, `denture`, `clear-aligner` ...) คงเป็น `treatment` · lab test ที่เก็บเป็น procedure (inflammation-panel, genetic-testing, microbiome-testing ...) รอ rollout `lab_test` · `space-maintainer` คง treatment (MeSH D013027 คือหัตถการ)

## แต่ละ brand ต้อง regenerate อะไร

| Brand | ทำ |
|---|---|
| **Deezy** | `node scripts/gen-entity-codes.mjs` → commit `src/data/entity-codes.json` · ตรวจ `src/lib/schema.ts` (เทียบ @type กับ `entity_type` — entity ที่ type เปลี่ยนจะได้ @type ใหม่) |
| **vth-biodent** | `harvest-entity-codes.mjs` route `mad` / `orthodontic-retainer` / `ssc-pedo` ไปที่ devices แล้ว (pull ล่าสุด) · regenerate entity JSON + รัน `check:clinical` ก่อน push |
| **SmileScape** | `page_type` derive จาก primary entity type — ตรวจหน้าที่ primary entity คือ 12 ตัวข้างบน |
| **ทุกแบรนด์ที่ใช้ `v_seo_keyword_pool` / `v_seo_entity_inventory` / `dz_dash_graph()`** | ผลลัพธ์เปลี่ยนตาม type ใหม่ — เช็คว่า filter ตาม `entity_type` ยังตรงกับที่ต้องการ |

ไม่มี DB constraint ใดอ่าน `entity_type` นอกจาก `chk_concept_subtype` — การเปลี่ยนไม่ทำให้ write พัง แต่ output ข้างบนเปลี่ยน

## สิ่งที่เปลี่ยนใน DB

| Migration | สิ่งที่ทำ |
|---|---|
| w34 (W3.4-prep) | `mv_keyword_near_pairs` (brand, kw_a, kw_b, match_reason, entity_fp, refreshed_at; unique index `uq_mv_keyword_near_pairs`) · `v_keyword_near_duplicates` สร้างใหม่บน MV (ชื่อ/คอลัมน์เดิม) · `refresh_keyword_near_pairs()` (`pg_trgm.similarity_threshold` 0.72, timeout 10 นาที) · `v_page_keyword_orphans` · ลบ NULL 8 ตัวจาก `related_entities_fps` ของ smile-scape |
| w4 | ตาราง `seo_priority_weights` + น้ำหนัก v1 (striking_impressions 25 · ctr_gap 20 · organic_contacts 20 · duplication 10 · orphan_risk 10 · weak_evidence 5 · ux_friction 5 · ai_visits 5) · `mv_page_priority` · `v_page_priority` · `refresh_page_priority()` |
| w35 | extension `pg_cron` · job `eywa-refresh-quality-mvs` `0 0 * * *` (UTC) = 07:00 Bangkok: `refresh_keyword_near_pairs()` แล้ว `refresh_page_priority()` (~2 นาที; test run: 6,682 pairs, 1,468 pages) |
| w36 | retype 12 entity + ย้าย/เพิ่ม/ลบแถว ext · backup `bak_w36_20261023_entity_type` |

ตรวจ cron: `select * from cron.job_run_details order by start_time desc limit 5;`

## `v_page_priority` อ่านอย่างไร

- หนึ่งแถวต่อหน้า Live: `brand_id, page_fingerprint, sitemap_node_id, slug, page_type, score, top_signals, suggested_action, signals (jsonb), refreshed_at`
- แต่ละ signal เป็น percentile ภายใน brand เดียวกัน (outlier ตัวเดียวไม่ครอบงำ); signal ที่ brand ไม่มีข้อมูลเลยถูกตัดออกและ rescale น้ำหนักให้รวม 100 — **ข้อมูลที่ไม่มีไม่ทำให้คะแนนต่ำลง**; `weak_evidence` เป็น binary (หน้าไม่อ้าง source tier 1–3)
- signals: `striking_impressions` (อันดับ 4–20 → ดันขึ้นหน้า 1) · `ctr_gap` (คลิกที่คาดตามเส้น CTR ของ brand เทียบจริง → เขียน title/meta ใหม่) · `organic_contacts` (หน้าทำเงิน → แก้ก่อน) · `duplication` (merge/แยกให้ชัด) · `orphan_risk` (เพิ่ม internal link) · `weak_evidence` (อัปเกรด citation) · `ux_friction` (Clarity) · `ai_visits` (candidate ทำ template, อัปเดตให้สด)
- แบรนด์ override น้ำหนักได้ด้วยแถว `seo_priority_weights` ของตน (version active สูงสุดชนะ); **ถ่วงน้ำหนักตามมูลค่าสินค้ายังไม่ทำ** จนกว่า `tsa_product_value` จะมีค่าจริง

## ทุก session ต้องทำ

1. **Pull spec ล่าสุด** แล้ว bump snapshot เป็น Bible v3.40 / Schema v1.28 / DR v1.47
2. **Regenerate entity JSON ของ brand** ตามตารางด้านบน แล้วรัน gate ก่อน push (checklist ข้อ 7)
3. **ตั้งแต่นี้เมื่อ merge/retype entity ใด ๆ**: update bindings + regenerate + รัน gate ใน PR/รอบเดียวกัน — อย่าทิ้งไว้ทีหลัง
4. **ตัดสิน `entity_type` ของ entity ใหม่ด้วยกฎ §1.2** — act → procedure/treatment, object/วัสดุ/software medical device → device; ดูความหมายจริง ไม่ใช่ตามที่ keyword พูดถึง
5. **ใช้ `v_page_priority` วางลำดับงานแก้หน้า** — และอย่าอ่าน `score` ข้าม brand (percentile ต่อ brand)
6. ข้อกำหนด DR-079 (lower() ของ lifecycle, aliases comma list, MeSH, `flagged_review`) ยังมีผลเหมือนเดิม

## เศษที่ยังเหลือ (ไม่ได้แก้รอบนี้)

- `cbct-scan` (procedure) มีแถว `seo_entity_devices` หลงอยู่ · `gum-swelling` (symptom) มีแถว `seo_entity_condition` หลงอยู่
- device 9 ตัวไม่มีแถว device ext: `3d-printer-aligner`, `acteon-cbct`, `cool-light-whitening-unit`, `densah-bur`, `endodontic-microscope`, `ptfe-membrane`, `rotary-endodontic-system`, `rpm-membrane`, `trios-intraoral-scanner`
- ต่อจาก DR-079: W3.4 keyword→entity mislink review · retype `related_to` (426) · 85 edge `flagged_review` รอ MD แบรนด์

## Rollback (ถ้าจำเป็น)

retype: คืนจาก `bak_w36_20261023_entity_type` (`row_data` เป็น jsonb ของแถวเดิมทั้งแถว; ไฟล์ migration ไม่มี statement คืนค่าสำเร็จรูป) · ปิด refresh: `select cron.unschedule('eywa-refresh-quality-mvs');` · ลบ backup เมื่อ operator ยืนยันข้อมูลแล้ว

อ้างอิง: DR-080 (`DECISION_RECORDS.md`) · Entity_Identity_SOP §1.2 / §6.2 · Schema v1.28 §10.3, F.12, Appendix L
