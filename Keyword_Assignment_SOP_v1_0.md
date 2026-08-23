# 📌 EYWA Protocol — Keyword Assignment SOP

> **เวอร์ชัน:** 1.1 (universal) · **ประกาศใช้:** 2026-07-28 · **สถานะ:** 🔒 Locked
> **v2.1 (2026-08-24):** ตรวจชื่อตาราง/ชื่อคอลัมน์และตัวเลขทุกตัวกับฐานจริง แล้วแก้ในที่ — ทุกจุดที่แก้ติดป้าย *(corrected 2026-08-24 against live schema)* · ไม่แตะโครงเรื่องและไม่แตะประวัติเวอร์ชัน · **รอบตรวจซ้ำวันเดียวกัน** สุ่ม re-query ตัวเลขที่แก้ไปแล้วกับฐานจริง พบผิด 3 จุดและแก้ทับ: §6.4 ข้อ 2 (นับ 13 คู่ทั้งที่ของจริง 4 คู่ — ลืมตัดกรณีหน้าเดียวกัน) · §8b Migration trigger (อ้างว่า note อยู่ที่ 9.1/9.10 ของจริงอยู่ที่ 9.8/9.11 ซึ่ง Merged ไปแล้ว) · §7 รายการค่าจริงของ `keyword_use_as`
>
> **v2.0 (2026-08-23):** 🔴 **back-port ruling ที่ตกค้างอยู่ในสำเนาของ VTH เท่านั้น 5 ข้อ** — §4.1 veto ของคนเขียน · §5.0 ตารางคีย์เวิร์ดเป็น time-series ต้องอ่านแถว `snapshot_date` ล่าสุด · §5.1 intent 3 ชั้น (snapshot=hard · contextual=soft · ไม่มี=soft เข้าคิว backfill) · §5.2 ข้อยกเว้นระดับหมวด · §5.3 ชื่อยาคุมที่การเขียนไม่ใช่ที่คีย์ · ruling ออกเมื่อ 2026-08-09 แต่ไม่เคยเข้าฉบับ universal ทั้งที่ไฟล์นี้ถูกแก้อีก 3 ครั้งหลังจากนั้น (v1.6/v1.7/v1.9) — deezy และ smile-scape จึงไม่เคยเห็นกฎเหล่านี้
>
> **v1.9 (2026-08-16):** เพิ่มบทเรียน **L30** — FK จับ *เขียน* ผิดคีย์ได้ แต่จับ *อ่าน* ผิดคีย์ไม่ได้ · query ที่คืน 0 เพราะถามผิดคีย์ หน้าตาเหมือน "ไม่มีของเดิม" แล้ว unbind ก็ no-op เงียบ ๆ · **เกตที่ผ่านได้ทั้งจาก "สะอาดจริง" และจาก "ไม่ได้ตรวจ" ไม่ใช่เกต** (จาก vth-biodent ตอบกลับ broadcast L28)
>
> **v1.8 (2026-08-16):** 🔴 **`seo_website_page_master` มี FK จริงแล้ว 7 ตัว** (migration `add_real_fks_to_page_master`) — ตารางบริวารใส่คีย์ผิดจะ error ทันที ไม่หลุดเงียบอีก · **ETL ทุกแบรนด์ต้อง insert หน้าก่อนบริวาร** · `ON UPDATE CASCADE` ทำให้ renumber §13.3 เหลือไล่มือแค่ `planned_outbound_fps` · ดู `BROADCAST-2026-08-16-page_fp.md`
>
> **v1.7 (2026-08-16):** เพิ่มบทเรียน **L28** — ตารางบริวารผูกด้วย `page_fingerprint` เท่านั้น ห้ามใช้ `fingerprint` · ไม่มี FK จริงบังคับ ใส่ผิดแล้วหลุดเงียบ · เพิ่มเกต orphan ที่ต้องรัน **ข้ามทุกแบรนด์** · และ **L29** — พูล citation เล็กเกินจำนวนหน้าทำให้ citation ถูกละเลงข้ามหัวข้อ ต้องตรวจด้วยบทคัดย่อ+MeSH จริง (G13)
>
> **v1.6 (2026-08-09):** เพิ่มบทเรียน **L27** — COMMENT บอกเจตนา ไม่การันตีของจริง ต้อง select ตัวอย่าง + เทียบข้ามแบรนด์ก่อนประกาศว่าข้อมูลเสีย
>
> **v1.5 (2026-08-09):** เพิ่มบทเรียน **L26** — similarity ใช้ตั้งผู้สมัครได้ แต่ห้าม auto-assign คีย์ด้วยคะแนน และห้ามชี้ `target_keyword_fp` ไปที่คำของแบรนด์อื่นในตารางร่วม
>
> **v1.4 (2026-08-09):** เพิ่ม **Q9** ใน §10 (Q1 ชั้นที่ 3 ด้วย `pg_trgm`) + บทเรียน **L24–L25** จากรอบ Smile Scape — สองชั้นเดิมของ L13 จับการสลับลำดับคำไทยไม่ได้ · และ dedupe ที่ใช้แต่การเทียบสตริงประกาศ "สะอาด" ทั้งที่ยังซ้ำ
> **v1.2:** เพิ่มบทเรียน L17–L19 (convention ของ seo_title/meta_description · baseline vs final · การคุมถ้อยคำ meta บนหน้า legal_review)
> **v1.1:** เพิ่ม §8.5 ตำแหน่งหมวดราคาในผัง · §13 โครงสร้าง & ลำดับเนื้อหา + วิธี renumber · บทเรียน L13–L16
> **ขอบเขต:** **UNIVERSAL** — ทุกแบรนด์ที่ใช้ `seo_website_page_master` + `seo_x_ads_keywords_contextual_master`
> ⚠️ ตารางร่วมทั้งสองไม่ได้มีแค่ 3 แบรนด์: `seo_website_page_master` มี **2,358 แถว / 3 แบรนด์** (deezy-dental 869 · vth-biodent 761 · smile-scape-clinic 728) แต่ `seo_x_ads_keywords_contextual_master` มี **22,710 แถว / 8 แบรนด์** (VTH BioDent 2,129) — ทุก query ต้องกรองแบรนด์เสมอ และคอลัมน์ที่ใช้กรองคนละชื่อกัน (`brand_id` slug บนหน้า · `brand` ชื่อเต็มบนคีย์) *(corrected 2026-08-24 against live schema)*
> **ที่มา:** field-tested กับ VTH BioDent (726 หน้า / 1,509 คีย์, 2026-07-27→28) — reference implementation + ETL ที่รันจริงอยู่ที่ `eywa-vth-biodent/content-plan/`
> **Companion:** DR-042 (Entity Reuse-First) · Bible §2.6 EGP · Schema v1.23 §5.1
>
> **อ่านหัวข้อ 11b ก่อนเริ่มทุกครั้ง** — เป็นบทเรียนจากการรันจริง 12 ข้อ ที่ทำให้รอบแรกล้มเหลว
>
> ### ปรับใช้กับแบรนด์ใหม่ยังไง
> 1. เปลี่ยน `brand='<Brand Name>'` / `brand_id='<brand-slug>'` ในทุก query
> 2. §4 blacklist — ปรับรายการชื่อคู่แข่ง / ยี่ห้อ third-party / ย่านนอกพื้นที่ให้ตรงแบรนด์
> 3. §5 intent matrix — ปรับตามผัง section ของแบรนด์ (ถ้าไม่ใช่ 8-section universal)
> 4. §8 หมวดราคา + §8b local — ใช้ได้ทันทีถ้าเป็นธุรกิจสถานพยาบาลหลายสาขา
> 5. §10 QA gates — ใช้เหมือนกันทุกแบรนด์ ห้ามลดข้อ
>
> ตัวเลขทั้งหมดที่ยกมาเป็นตัวอย่างเป็นของ VTH BioDent ใช้เพื่ออธิบายเกณฑ์ ไม่ใช่ค่าคงที่
---

## 1. นิยาม

| คำ | ความหมาย | คอลัมน์ |
|---|---|---|
| **Primary keyword** (คีย์หลัก) | คีย์เวิร์ดเดียวที่หน้านั้น "เป็นเจ้าของ" ทั่วทั้งไซต์ ใช้กำหนด H1/title/slug intent | `page_master.target_keyword_fp` |
| **Semantic keywords** (คีย์รอง) | คีย์เวิร์ดที่หน้าครอบคลุมในเนื้อหา แต่ไม่ใช่เจ้าของ ใช้ทำ H2/FAQ/entity coverage | `page_master.semantic_keywords_fps[]` |
| **Entity** | หน่วยความหมายที่หน้าและคีย์เวิร์ดสังกัดร่วมกัน | `page_master.primary_entity_fp` ↔ `keywords.primary_entity_fp` |
| **Relevance tier (R)** | ระดับความเกี่ยวข้องระหว่างคีย์เวิร์ดกับหน้า (R1–R4) | คำนวณ |
| **v** | `volume_recent_12m` จาก snapshot ล่าสุด | `monthly_market_snapshot` |

**หลักการสูงสุด:** ความเกี่ยวข้อง > ความตรง intent > ปริมาณค้นหา
คีย์เวิร์ดที่ volume สูงแต่เกี่ยวน้อย **ไม่ยัดเข้าหน้าเดิม** — ส่งเข้าคิวสร้างหน้าใหม่ (ข้อ 7)

---

## 2. Precondition (ต้องผ่านก่อนเริ่ม assign)

| # | เงื่อนไข | ตรวจด้วย |
|---|---|---|
| P1 | คีย์เวิร์ดทุกตัวในคลังมี `primary_entity_fp` | `count(*) where primary_entity_fp is null` = 0 |
| P2 | หน้า **เชิงเนื้อหา** มี `primary_entity_fp` (ยกเว้นหน้าโครงสร้าง — ดูหมายเหตุ) | `count(*) where primary_entity_fp is null and page_type not in (…)` = 0 |
| P3 | มี snapshot volume ครบทุกคีย์ที่จะใช้ | left join snapshot ไม่มี null |
| P4 | มีคอลัมน์/ฟังก์ชัน normalize คีย์เวิร์ด (ข้อ 6.1) | function `kw_norm()` มีอยู่ |
| P5 | ไม่มี entity ซ้ำ concept เดียวกันในกราฟ (**DR-042**) | ค้น `seo_entity_graph` ด้วยชื่อ/alias/ICD ก่อนสร้างใหม่ทุกครั้ง |

> **DR-042 Reuse-First (Locked 2026-07-28):** `seo_entity_graph` ใช้ร่วมข้ามแบรนด์ — 1 concept = 1 แถว
> เจอของเดิมแล้ว → **เติม `aliases` เท่านั้น ห้ามสร้างแถวใหม่** · ต่าง granularity จริง → เก็บ 2 แถวแต่ผูก edge ทันที
> **ห้ามแก้ปัญหา entity ซ้ำด้วยการ remap คีย์เวิร์ดของแบรนด์ตัวเอง** — จะทำให้ cross-brand rollup แตก ต้อง merge ที่กราฟเสมอ

**หมายเหตุ P2 — entity ไม่บังคับสำหรับหน้าโครงสร้าง**
`page_type ∈ {home, about, pillar (hub ระดับหมวด), knowledge_article ที่เป็น index/glossary, evidence_case index, contact, branch_landing, local_landing}` ไม่ต้องมี entity
ให้ผูก `cluster_id` แทน + ตั้ง `intent_source_tier='brand'` — VTH มี **57 หน้า**ในกลุ่มนี้ (`brand_id='vth-biodent' and status not in ('Merged','Dropped') and primary_entity_fp is null`) *(corrected 2026-08-24 against live schema — เดิมเขียน 63)* (เช่น 5.1 Sleep & Airway, 6.3.x Glossary, 8.x Contact, 9.1 Local hub) การบังคับ tag entity จะได้ mapping มั่ว

หน้าเชิงเนื้อหาที่ยังไม่ผ่าน P2 → **ปล่อย `target_keyword_fp` ว่างไว้** ห้าม assign มั่ว

---

## 3. Relevance ladder (เกณฑ์ hard gate — ไม่ใช่คะแนน)

| Tier | เงื่อนไข | ใช้ได้ไหม |
|---|---|---|
| **R1** | `keyword.primary_entity_fp = page.primary_entity_fp` | ✅ ใช้ก่อนเสมอ |
| **R2** | entity ของคีย์เป็น parent/child ของ entity หน้า (`seo_entity_relationships.edge_type` ∈ `broader_than` / `part_of` / `is_a`) *(corrected 2026-08-24 against live schema — `subtype_of` ไม่มีในฐาน 0 แถว ส่วน `broader_than` คือขอบลำดับชั้นตัวหลัก 271 แถว ตกหล่นจากรายการเดิม)* | ✅ ใช้เมื่อ R1 หมด |
| **R3** | อยู่ `cluster_id` เดียวกับหน้า | ⚠️ ใช้ได้ แต่ต้องติด `flag_review='kw-r3'` ให้คนตรวจ |
| **R4** | นอกเหนือจากนั้น | ❌ ห้าม ทั้ง primary และ semantic |

> ลำดับนี้แก้ปัญหาที่เจอในรอบ audit: 154/295 entity ของหน้า VTH ไม่มีคีย์เวิร์ดสังกัดเลย (325 หน้า) — ถ้าไม่มี R2/R3 fallback หน้าเหล่านี้จะตันทั้งหมด
> **ถ้าไม่มีผู้สมัครใน R1–R3 → ปล่อยว่าง + `flag_review='kw-none'`** ห้ามหยิบคีย์ R4 มายัด (นี่คือต้นเหตุของ §9 ที่พังทั้งหมวด)

---

## 4. Eligibility filter (ตัดออกก่อนให้คะแนน)

คีย์เวิร์ดที่เข้าข่ายด้านล่าง **ห้ามเป็น primary** (เป็น semantic ได้ตามที่ระบุ)

| # | รูปแบบ | เหตุผล | เป็น semantic ได้? |
|---|---|---|---|
| B1 | มีชื่อยา / ชื่อสามัญทางยา (`metronidazole`, `ibuprofen`, `metrolex`, `amoxicillin`…) | YMYL + พ.ร.บ.ยา ม.88 ห้ามโฆษณาสรรพคุณยา | ❌ ไม่ได้เลย |
| B2 | `ภาษาอังกฤษ`, `แปลว่า`, `คำศัพท์` | ไม่มี intent รักษา ไม่แปลงเป็นคนไข้ | ✅ |
| B3 | มีเลขปี (2565–2570 / 2022–2027) | หมดอายุทุกปี ขัดหน้า evergreen | ✅ |
| B4 | `โรงพยาบาลรัฐ`, `บัตรทอง`, `ประกันสังคม`, `รัฐบาล` (เมื่อแบรนด์ไม่ได้ให้สิทธิ์นั้น) | คนละกลุ่มผู้ซื้อ ไม่มีทางปิดการขาย | ✅ (หน้า FAQ สิทธิ์) |
| B5 | ประเทศ/เมืองคู่แข่ง (`เกาหลี`, `ฮังการี`, `เวียดนาม`…) | intent ไปต่างประเทศ | ✅ |
| B6 | `ราคาถูก`, `ที่ไหนถูก`, `ถูกที่สุด` | ขัด positioning premium + สงครามราคา | ✅ |
| B7 | ชื่อคลินิก/แบรนด์คู่แข่ง | ไม่ควรสร้างหน้ารับ traffic ให้คู่แข่ง | ❌ |
| B8 | ยี่ห้ออุปกรณ์ third-party (`neodent`, `damon`, `invisalign`…) | ใช้ได้เฉพาะหน้า §4 Technology ของยี่ห้อนั้นโดยตรง | ✅ |
| B9 | ความเชื่อ/ภูมิปัญญาพื้นบ้าน (`โบราณ` **ทุกรูปแบบ**, `ภูมิปัญญา`, `ทำนาย`, `ลาง`, `ของขลัง`, `กอเอี๊ยะ`, `สมุนไพรพื้นบ้าน`) บนหน้าเนื้อหาการแพทย์ | ขัด E-E-A-T / YMYL · **regex เดิมจับแค่ `โบราณว่า` ทำให้ `วิธีแก้ นอนกัดฟัน โบราณ` 374/mo หลุดเข้ามา — รัดแล้ว 2026-07-28** | ❌ |
| B10 | มีคำ forum (`pantip`, `กระทู้`, `รีวิว pantip`) | SERP เป็น UGC หน้าคลินิกชนะยาก | ✅ |
| B11 | `ใกล้ฉัน` / ชื่อย่าน / ชื่อสาขา | สงวนไว้ให้หน้า §9 Local เท่านั้น | ✅ (เฉพาะหน้าบริการ) |

> B1/B9 = hard block ระดับ compliance ต้องมี unit test ใน ETL
> คีย์ที่ token เพี้ยน (`โปร ไบ โอ ติก`, `ต่อ ม ไขมัน`) **ไม่ใช่เหตุให้ตัดทิ้ง** — normalize ก่อน (ข้อ 6.1) แล้วค่อยพิจารณา

---

### 4.1 เมื่อคนเขียนไม่เห็นด้วยกับ target ที่ assign ไว้ (veto)

target ที่ผ่าน gate ตอน assign ยัง**ใช้ไม่ได้จริงตอนเขียน**ได้ เช่น SERP ของคำนั้นเป็นคนละเรื่องกับหน้า (`ฝังเข็ม dry needling` — คู่แข่งทั้ง 7 รายพูดเรื่องนิยาม/เทียบฝังเข็มจีน ไม่มีใครพูดถึงขากรรไกร) หรือคำนั้นใส่ในเนื้อหาการแพทย์ไม่ได้

**คนเขียนต้องหยุด แจ้งกลับ operator พร้อมคำที่เสนอแทน แล้วรออนุมัติ — ห้ามเขียนอ้อม ห้ามเปลี่ยนเอง** ขั้นตอนเต็มอยู่ที่ [`docs/CONTENT-WRITING-SOP.md`](../docs/CONTENT-WRITING-SOP.md) §3.2.9

**ฝั่ง assignment ต้องทำเมื่อ operator อนุมัติแล้ว:**

1. insert คำใหม่เข้า `seo_x_ads_keywords_contextual_master` (คำที่ไม่มีใน DFS ก็ insert ได้ — ดูหมายเหตุข้างล่าง)
2. ยิง DFS เก็บ volume + SERP snapshot
3. UPDATE `target_keyword_fp` ของหน้านั้น · คำเดิมย้ายไปเป็น semantic ถ้า B-rule อนุญาต (B10 อนุญาต)
4. เช็คว่าคำใหม่ไม่ถูกหน้าอื่นจอง และไม่ทำให้หน้าข้างเคียง cannibalize
5. คืนหน้านั้นเข้าคิวเขียนรอบถัดไป

> **คำที่ DFS ไม่มีข้อมูล ใช้เป็น primary ได้** — DFS ไม่มี ≠ ไม่มีคนค้น long-tail ทางการแพทย์หายจากทุกเครื่องมือเป็นปกติ (ตรวจ 2026-07-30: `ฝังเข็ม ลดปวดขากรรไกร` · `ฝังเข็มลดปวด` · `ฝังเข็ม กราม` **ไม่มีสักคำใน DFS** ขณะที่ `ปวดขากรรไกร` มีและ avg backlinks ของหน้าที่ติดอันดับ = 1.6 คือแทบไม่มีกำแพง)
>
> เลือกคำที่ตรงเจตนาการสื่อสารของหน้าไว้ก่อน ตั้ง `intent_source_tier='brand'` แล้ว **optimize รอบหน้าเมื่อมี GSC** ซึ่งเป็นข้อมูลจริงของเราเอง ไม่ใช่ค่าประมาณของเครื่องมือ
> คีย์ที่ token เพี้ยน (`โปร ไบ โอ ติก`, `ต่อ ม ไขมัน`) **ไม่ใช่เหตุให้ตัดทิ้ง** — normalize ก่อน (ข้อ 6.1) แล้วค่อยพิจารณา

---

## 5. Intent × page-type matrix (gate ชั้นที่ 2)

| page_type / section | search_intent ที่รับได้ | ห้าม |
|---|---|---|
| §2 Brand / About / Team | Navigational, Informational | Transactional |
| §3 Service & Program (hub) | **Commercial**, Informational (head term เปล่า) | Transactional-ราคา (→ ข้อ 8), Navigational |
| §3 Service (sub-page ขั้นตอน) | Informational, Commercial | — |
| §4 Technology / Device | Informational, Navigational (ชื่อยี่ห้อ) | Transactional |
| §5 Concern / Symptom | **Informational** (อาการ/สาเหตุ/วิธีแก้) | Navigational |
| §6 Knowledge / Guide / FAQ | **Informational** ล้วน | Commercial, Transactional |
| §7 Case study | Informational | Commercial, Navigational |
| §9 Local (สาขา) | **ต้องมี geo modifier หรือ `ใกล้ฉัน`** เท่านั้น | ทุกอย่างที่ไม่มี geo |

**กฎลำดับชั้น (hierarchy monotonicity):**
หน้าแม่ต้องได้คีย์ที่กว้างกว่าหรือเท่ากับหน้าลูกเสมอ
- ห้ามหน้าลูกถือ head term ขณะหน้าแม่ถือ long-tail (พบ 4 เคสในรอบ audit เช่น `ตรวจพันธุกรรม` อยู่หน้า guide แต่หน้าบริการได้ `ตรวจพันธุกรรม ราคา`)
- ตรวจอัตโนมัติ: ถ้า `kw_norm(child)` เป็น substring ของ `kw_norm(parent)` → ผิด ต้องสลับ

---

### 5.0 ทุกตารางคีย์เวิร์ดเป็น time-series — อ่านแถวล่าสุดเสมอ (operator ruling 2026-08-09)

**ตารางที่แตะคีย์เวิร์ดทั้งหมดเป็น time-series** ยกเว้น `seo_x_ads_keywords_contextual_master`
ตัวเดียวที่นิ่ง (1 fingerprint = 1 แถว ตลอดไป)

ที่เหลือ — `..._monthly_market_snapshot`, `..._keyword_serp_competitors` และตารางอนาคตที่เก็บ
ค่าจาก DFS — จะมีหลายแถวต่อ 1 fingerprint ตาม `snapshot_date`

🔴 **อ่านเมื่อไหร่ต้องหยิบแถวที่ `snapshot_date` ล่าสุดของ fingerprint นั้นเสมอ**
ห้าม `select ... limit 1` ลอย ๆ ห้าม `forEach` แล้วให้ใครมาทีหลังชนะ

วิธีที่ถูก เลือกอย่างใดอย่างหนึ่ง:

```sql
-- ก) อ่านผ่าน view (แนะนำ — กฎบังคับตัวเอง ไม่ต้องหวังให้คนจำ)
select * from public.v_keyword_market_latest where brand = 'VTH BioDent';

-- ข) ถ้าต้องอ่านตารางดิบ
select distinct on (fingerprint, brand) *
from public.seo_x_ads_keywords_monthly_market_snapshot
order by fingerprint, brand, snapshot_date desc nulls last;
```

```js
// ค) ฝั่ง JS — เทียบวันที่เสมอ
const latest = new Map();
for (const r of rows) {
  const prev = latest.get(r.fingerprint);
  if (!prev || String(r.snapshot_date ?? '') > String(prev.snapshot_date ?? '')) latest.set(r.fingerprint, r);
}
```

**ที่มาของกฎนี้:** `check-plan.mjs` อ่าน snapshot ด้วย `forEach(s => map.set(s.fingerprint, ...))`
มาตลอด คือใครมาทีหลังชนะโดยไม่ดูวันที่เลย ตอนตรวจ 2026-08-09 ยังไม่พังเพราะบังเอิญ
1 fingerprint มีแถวเดียว (1,754/1,754) — แต่มันคือบั๊กที่รออยู่ พอ ETL เริ่มเก็บย้อนหลังจริง
กฎ §5 จะเริ่มตัดสินด้วยแถวที่หยิบมาแบบสุ่ม โดยไม่มีอะไรส่งเสียง
🔴 **บั๊กที่รออยู่มาถึงแล้ว** — `seo_x_ads_keywords_monthly_market_snapshot` มี 24,610 แถวต่อ 22,807 คู่ (fingerprint, brand)
คือ **1,803 คู่ที่มีมากกว่า 1 แถว** วัด 2026-08-24 · เงื่อนไข "บังเอิญปลอดภัย" หมดอายุแล้ว ต้องอ่านแถวล่าสุดจริงเท่านั้น *(corrected 2026-08-24 against live schema)*
`page-brief.mjs` ทำถูกอยู่แล้ว (`.order('snapshot_date', { ascending: false })`) จึงเป็นที่เดียวที่ต้องแก้

---

> **⚠️ เขียน SQL ให้ SQL editor ของ Supabase — ห้ามใช้ temp table**
> editor ต่อผ่าน connection pool แบบ transaction mode แต่ละ statement อาจไปลงคนละ session
> temp table เป็นของ session ใครของมัน statement ถัดไปจึงหาไม่เจอ (เจอจริง 2026-08-09:
> `ERROR 42P01 relation "_dfs_intent" does not exist`)
> ให้ใช้ **CTE ใน statement เดียว** แทน — ได้ atomicity มาฟรีโดยไม่ต้อง `begin/commit` ด้วย
> data-modifying CTE ของ Postgres ทำงานทุกตัวแม้ไม่ถูกอ้างถึง จึงใส่ `update` กับ `insert`
> ไว้ใน statement เดียวกันได้ ตัวอย่างใช้งานจริงอยู่ที่ `content-plan/etl/sql/2026-08-09-load-dfs-intent.sql`

---

### 5.1 intent มาจากไหน — กฎ 3 ชั้น (operator ruling 2026-08-09)

`search_intent` มีอยู่สองที่และ**ไม่ตรงกัน** — `seo_x_ads_keywords_monthly_market_snapshot` มาจาก DFS
ส่วน `seo_x_ads_keywords_contextual_master` มาจากการวิเคราะห์ของ Gemini เดิมตกลงกันว่าใช้ของ snapshot
เพราะเป็นค่าที่วัดมา ข้อนั้นยังใช้อยู่ แต่ต้องมีทางลงเมื่อ snapshot ไม่มีข้อมูล

| ชั้น | แหล่ง | ชน §5 แล้วเป็นอะไร |
|---|---|---|
| 1 | `market_snapshot` (DFS) | 🔴 **hard** — บล็อก |
| 2 | `contextual_master` (LLM) | 🟡 **soft** — เตือน ต้องยืนยันกับ DFS ก่อนลงมือ |
| 3 | ไม่มีทั้งสองที่ | 🟡 **soft** — ขึ้นรายการรอ backfill |

**ทำไมชั้น 2 ไม่ใช่ hard** — วัดจริงเมื่อ 2026-08-09: label ของ LLM ผิด**ทั้งสองทิศทาง**
`นอนกัดฟัน แก้ยังไง` และ `ข้อต่อ ขากรรไกร อักเสบ วิธีรักษา` ถูกป้ายเป็น commercial ทั้งที่ DFS ว่า informational ·
`อาการ กัดฟัน ตลอดเวลา` ถูกป้ายเป็น informational ทั้งที่ DFS ว่า transactional
จาก 80 หน้าที่ label ของ LLM ยกธง มี **56 หน้า (70%) ที่ DFS เคลียร์ให้** — ถ้าให้ชั้นนี้บล็อก deploy
จะได้แต่ความเสียหาย ไม่ได้ความถูกต้อง

**ชั้น 3 ต้องไม่เงียบ** — ก่อน 2026-08-09 `check-plan.mjs` อ่าน intent จาก snapshot อย่างเดียว
คำที่ไม่มีแถวจะได้ `undefined` แล้ว §5 **ข้ามไปเฉย ๆ** วันที่ตรวจพบคือ 338 จาก 562 หน้า
(60% ของคลัง) เดินผ่าน matrix โดยไม่ถูกตรวจ ขณะที่รายงานขึ้นว่าไม่มีปัญหา
กฎที่ไม่มีข้อมูลให้ตรวจ ต้องรายงานว่า "ตรวจไม่ได้" ไม่ใช่ "ผ่าน"

**เมื่อไม่มั่นใจ ให้คนตัดสิน แล้วเขียนไว้** — กลไกคือ `INTENT EXEMPTION` ใน `reconciliation_notes`
ซึ่งมีใช้อยู่แล้ว **14 หน้าของ VTH · 26 หน้าทั้งฐาน** (`reconciliation_notes ilike '%INTENT EXEMPTION%'`) *(corrected 2026-08-24 against live schema — เดิมเขียน 11)* ตัวอย่างที่เขียนไว้ดีคือ `vth-6.2.8.1`:
*"ลูก 4 ขวบ นอนกรน is labelled transactional but it is a question a parent types, and the page
answers it. DFS intent labels are unreliable for Thai question-shaped queries; the page type is right."*
คำตัดสินของคนต้องเขียนเหตุผลไว้เสมอ — exemption ที่ไม่บอกว่าทำไม คือการเปลี่ยนกฎแบบเงียบ ๆ

**probability** — เก็บที่ `market_snapshot.search_intent_probability` (เพิ่ม 2026-08-09)
พร้อม `search_intent_secondary` และ `search_intent_fetched_at` · เกณฑ์ที่ `check-plan.mjs` บังคับแล้ว: **≥0.8 เชื่อ · 0.5–0.8 ให้คนดู · <0.5 ถือว่าไม่มีข้อมูล**
เพราะหลายคำคู่คี่จริง เช่น `prf ข้อต่อขากรรไกร` navigational 0.426 / informational 0.259 /
transactional 0.218 — ค่าแบบนี้ไม่ควรบล็อกอะไรทั้งนั้น

**รอบ optimize ทับได้** — ค่าที่ตัดสินวันนี้ไม่ใช่คำตอบสุดท้าย เมื่อ GSC มีข้อมูลจริงของเราเอง
ให้ override ได้เลย นี่คือ production รอบแรก ตกที่ชั้น 2 ได้

---

### 5.2 ข้อยกเว้นระดับหมวด (operator ruling 2026-08-09)

สองหมวดนี้ **คำค้นเป็น commercial/transactional โดยธรรมชาติ แต่ตัวหน้าเป็นหน้าความรู้**
เป็นความไม่ตรงกันเชิงโครงสร้าง ไม่ใช่การจับคู่ผิดรายหน้า จึงยกเว้นทั้งหมวด ไม่ใช่ไล่แปะทีละหน้า

| หมวด | ยกเว้น intent | เหตุผล |
|---|---|---|
| **§6.8** comparison hub | `commercial` · `transactional` | "เลือกอันไหนดี" เป็นคำถามเชิงซื้อโดยธรรมชาติ · เดิมยกเว้นแค่ commercial · เพิ่ม transactional 2026-08-09 หลัง DFS ให้ `ครอบฟัน อุดฟัน inlay onlay` = transactional p=0.89 — คำเปรียบเทียบการรักษาอยู่คาบเกี่ยวสองป้าย DFS ตัดไปทางไหนก็ได้ แต่หน้าเป็นหน้าเดียวกัน |
| **§6.9** medical screening | `transactional` | ทุก target ในหมวดคือ "ทำฟัน + เงื่อนไขทางการแพทย์" · DFS อ่านเป็น transactional เพราะคนค้นอยากได้รับการรักษา แต่หน้าตอบว่า**ทำได้ปลอดภัยไหมเมื่อมีภาวะนั้น** ซึ่งคือหน้าที่ของหน้าความรู้ |

ตัวอย่างที่ทำให้เห็นว่าเป็นรูปแบบ ไม่ใช่เรื่องบังเอิญ — §6.9 โดนพร้อมกัน 6 หน้าในวันเดียว
ด้วยรูปประโยคเดียวกัน: `แพ้ยาชา ทำฟัน` p=1.00 · `ท้อง จะ 8 เดือน ปวดฟัน` p=1.00 ·
`ทำฟันช่วงเคมีบำบัด` p=0.92 · `เบาหวาน ทำฟัน เตรียมตัว` p=1.00 · `เคลียร์ช่องปากก่อนผ่าตัด` p=1.00 ·
`แพ้วัสดุทำฟัน` p=0.96

⚠️ **ยกเว้นเฉพาะ intent ที่ระบุ** — §6.9 ยังห้าม `commercial` · §6.8 ยังห้าม `navigational`

---

### 5.3 ชื่อยาในคีย์เวิร์ด — คุมที่การเขียน ไม่ใช่ที่คีย์ (operator ruling 2026-08-09)

**ถ้าชื่อยาเป็นคำค้นจริง ใช้เป็น target ได้** B1 ยังห้ามเฉพาะรายการที่ระบุไว้ในตาราง §4
ไม่ขยายไปครอบชื่อกลุ่มยา (`ยาชา` · `ยาปฏิชีวนะ` · `ยาละลายลิ่มเลือด` · `ยากระดูกพรุน`) หรือ
ชื่อสามัญที่คนพิมพ์จริง (`ยาพารา`)

**เหตุผล** คนไข้ค้นด้วยคำเหล่านี้จริง การไม่มีหน้ารองรับไม่ได้ทำให้คำถามหายไป แค่ทำให้เขาไปเจอ
คำตอบที่แย่กว่าที่อื่น

🔴 **แต่ย้ายภาระไปที่การเขียนเต็ม ๆ** — พ.ร.บ.ยา ม.88 ห้ามโฆษณาสรรพคุณยา และ §4.5.1 บังคับให้
target อยู่ใน title/meta/H1 สองข้อนี้ชนกันเมื่อคีย์มีชื่อยา ทางออกคือ:

- **เอ่ยชื่อยาได้เท่าที่คำค้นบังคับ** (title/H1/100 คำแรก) แต่**ห้ามเขียนสรรพคุณ ขนาดยา วิธีใช้
  หรือแนะนำให้ใช้** ในเนื้อหา
- ตอบด้วย**หลักการและการส่งต่อ** เช่น "เรื่องนี้เป็นการตัดสินใจของแพทย์ผู้สั่งยา" แทนคำแนะนำตรง
- ห้ามเปรียบเทียบยาว่าตัวไหนดีกว่า ห้ามระบุขนาด ห้ามบอกว่ากินเมื่อไหร่เท่าไหร่

หน้าที่กระทบ (target ที่มีคำเกี่ยวกับยา 10 หน้า · semantic 5): `6.10.10` ปวดฟัน กินยาไรดี ·
`6.9.2` ยาละลายลิ่มเลือด ถอนฟัน · `6.9.3` ยากระดูกพรุน รากฟันเทียม · `6.9.10` ยาปฏิชีวนะก่อนทำฟัน ·
`6.9.12` แพ้ยาชา ทำฟัน · `6.5.13` faq sedation ยาชา · `6.5.16` อุดฟัน ฉีดยาชาไหม (Live) ·
`6.2.8.5` ยาสงบประสาทเด็ก ทำฟัน · `3.4.1.17` โบท็อกกัดฟัน (Live) ·
`3.4.1.3.2` ฉีดสเตียรอยด์ ข้อต่อขากรรไกร (Live)
*(corrected 2026-08-24 against live schema — target ของ 6.10.10 ในฐานคือ `ปวดฟัน กินยาไรดี` ไม่ใช่ `ปวดฟัน กินยาพารา ได้ไหม` · 6.5.16 เป็น Live แล้ว รวมเป็น 3 หน้า Live ที่กฎนี้บังคับอยู่จริง)*

---

**กฎลำดับชั้น (hierarchy monotonicity):**
หน้าแม่ต้องได้คีย์ที่กว้างกว่าหรือเท่ากับหน้าลูกเสมอ
- ห้ามหน้าลูกถือ head term ขณะหน้าแม่ถือ long-tail (พบ 4 เคสในรอบ audit เช่น `ตรวจพันธุกรรม` อยู่หน้า guide แต่หน้าบริการได้ `ตรวจพันธุกรรม ราคา`)
- ตรวจอัตโนมัติ: ถ้า `kw_norm(child)` เป็น substring ของ `kw_norm(parent)` → ผิด ต้องสลับ

---


## 6. การให้คะแนนและตัดสิน (เมื่อผ่าน gate ข้อ 3–5 แล้ว)

### 6.1 Normalize ก่อนเทียบทุกครั้ง

```sql
create or replace function kw_norm(t text) returns text language sql immutable as $$
  select (
    select string_agg(w, ' ' order by w)
    from unnest(string_to_array(regexp_replace(lower(trim(t)), '[-–—[:space:]]+', ' ', 'g'), ' ')) w
    where w <> ''
  );
$$;
```

ใช้ตัดคำซ้ำที่ต่างแค่เว้นวรรค/ขีด/ลำดับคำ (รอบ audit เจอ 7 คู่ที่ fingerprint จับไม่ได้ เช่น `เลเซอร์เหงือก` vs `เลเซอร์ เหงือก`, `neodent รากเทียม` vs `รากเทียม neodent`)

### 6.2 ลำดับการตัดสิน (ใช้ทีละชั้น หยุดเมื่อเหลือผู้ชนะเดียว)

| ชั้น | เกณฑ์ | ทิศทาง |
|---|---|---|
| 1 | Relevance tier | R1 > R2 > R3 |
| 2 | Intent ตรง matrix ข้อ 5 | ตรงชนะ |
| 3 | **SERP-type compatibility** — `serp_features` ของคีย์เข้ากับ page_type (เช่น หน้าบริการ vs SERP ที่มีแต่ video/forum = ไม่เข้า) | เข้ากันชนะ |
| 4 | `volume_recent_12m` | สูงชนะ |
| 5 | `keyword_difficulty` | ต่ำชนะ |
| 6 | จำนวน token น้อยกว่า (head-ier) | สั้นชนะ |
| 7 | `cpc_avg` | สูงชนะ (proxy มูลค่าเชิงพาณิชย์) |

> ชั้น 3 คือส่วนที่เพิ่มจากตรรกะเดิม: relevancy สูงแต่ SERP เป็น UGC/วิดีโอล้วน หน้าคลินิกลงทุนไปก็ไม่ติด — ส่งเข้า §6 knowledge แทน

### 6.3 เพดานปริมาณ

| ประเภทหน้า | primary | semantic |
|---|--:|--:|
| Pillar / hub | 1 | 8–15 |
| หน้าลูก / concern / guide | 1 | 5–10 |
| Local §9 | 1 (ต้องมี geo) | 3–6 |
| Concept / brand-nav | 1 (อนุญาต v=0) | 0–5 |

### 6.4 ข้อจำกัดเชิงโครงสร้าง (🔴 ข้อ 2–3 **ไม่ได้บังคับที่ DB** ต้องรันเป็นเกต)

1. **1 primary : 1 หน้า ทั่วทั้งแบรนด์** — normalize ด้วย `kw_norm()` แล้วเทียบ · คอลัมน์แบรนด์ของ `seo_x_ads_keywords_contextual_master` ชื่อ **`brand`** (ค่าเป็นชื่อเต็ม เช่น `VTH BioDent`) ส่วน `brand_id` (slug) อยู่บน `seo_website_page_master` — เขียน gate ให้ตรงตาราง *(corrected 2026-08-24 against live schema)* · วัด 2026-08-24: ไม่มี target ซ้ำหลัง normalize ทั้ง 3 แบรนด์ (0/0/0)
2. คีย์ที่เป็น primary ของหน้าใดแล้ว **ห้ามเป็น semantic ของหน้าอื่น** — 🔴 **ไม่มี constraint บังคับ** ต้องพึ่ง Q7 ใน §10 เท่านั้น · วัด 2026-08-24: ละเมิดจริง **4 คู่ (ทุกสถานะ)** — vth-biodent 1 คู่ (`อุปกรณ์ นอนกรน` primary ของ 3.4.2.12/Merged ไปโผล่เป็น semantic ที่ 3.4.2.2/Live) · deezy-dental 3 คู่ — และเหลือ **2 คู่ที่ทั้งสองฝั่งยัง active** (deezy-dental ทั้งคู่ · vth-biodent 0) *(corrected 2026-08-24 — รอบตรวจซ้ำ: ตัวเลข "13 คู่ (vth 8 · deezy 5)" ที่ลงไว้ก่อนหน้าในวันเดียวกันนับรวมหน้าที่ใส่ primary ของ**ตัวเอง**ลงใน `semantic_keywords_fps[]` ของตัวเอง 11 แถว (vth 8 · deezy 3) ซึ่งไม่ใช่ "หน้าอื่น" จึงไม่เข้าข้อนี้ · query ต้องมีเงื่อนไข `sem.page_fingerprint <> tgt.page_fingerprint` เสมอ)*
3. คีย์เดียวกันเป็น semantic ได้หลายหน้า — แต่ไม่เกิน 3 หน้า · 🔴 **ไม่มี constraint บังคับ** วัด 2026-08-24 มี 3 คีย์ของ deezy-dental เกินเพดาน *(corrected 2026-08-24 against live schema)*
4. หน้าที่ยังไม่มี primary ต้องมี `flag_review` เสมอ (ไม่มีสถานะ "ว่างเงียบ") — วัด 2026-08-24: VTH ผ่าน 0 แถว

---

## 7. หน้า concept / brand-nav (volume = 0)

หน้าเชิงคอนเซปต์ (§2 ปรัชญา, §3.1–3.4 signature MBM/ABM/BFB, §4.9, §6.1.1) **กำหนด target keyword ที่ volume 0 ได้** — แต่ต้อง:

1. 🔴 ติดธงที่ **`page_master.flag_review`** ให้มีคำว่า `brand-nav` (ขีดกลาง) *(corrected 2026-08-24 against live schema — เดิมสั่งเขียน `keywords.keyword_use_as = 'brand_nav'` ซึ่ง **ไม่เคยมีสักแถวในฐาน**: ค่าที่คอลัมน์นั้นถืออยู่จริงคือ target_keyword 1,967 · semantic_keyword 3,550 · excluded 212 แถว · NULL 16,979 แถว และมีค่าหลงเหลืออีก 2 แถว (`seo` · `🟡 Used as Semantic`) ที่ไม่ใช่ค่าใช้งาน)*
2. ตั้ง `page_master.intent_source_tier = 'brand'` — ค่านี้มีอยู่จริง 88 แถว (VTH 87) วัด 2026-08-24
3. **ไม่นับหน้าเหล่านี้ใน KPI organic ranking/traffic** — วัดด้วย branded search + assisted conversion แทน

ปัจจุบัน VTH มี **27 หน้า**ในกลุ่มนี้ (`flag_review ilike '%brand-nav%'`, active) *(corrected 2026-08-24 against live schema — เดิมเขียน 26)* ถ้าไม่ติดธง รายงานจะอ่านเหมือนหน้าพัง 27 หน้า

---

## 8. คีย์เวิร์ดกลุ่มราคา — โมเดล Hub & Spoke

### 8.1 โครงสร้าง

```
/pricing/            หน้ารวมราคา (hub) — 1 หน้าเท่านั้น
  ├─ #scaling        section ราคาขูดหินปูน   ←→ 3.7.6.1
  ├─ #whitening      section ราคาฟอกสีฟัน    ←→ 3.7.4
  ├─ #denture        section ราคาฟันปลอม     ←→ 3.7.11
  └─ …               1 section ต่อ 1 บริการ

หน้าบริการ §3 แต่ละหน้า: ตารางราคาย่อ 3–5 บรรทัด + ลิงก์ "ดูราคาเต็ม" → /pricing/#<slug>
หน้ารวม: ทุก section ลิงก์กลับหน้าบริการที่เกี่ยวข้อง (สองทาง เข้า seo_page_internal_links)
```

**เหตุผลที่เลือกโมเดลนี้แทนการแตกหน้าราคาย่อยหลายหน้า**
ขออนุมัติโฆษณาจุดเดียว · ราคาอัปเดตที่เดียว · ไม่เกิด thin pages · intent เทียบราคาข้ามบริการมีที่อยู่ · หน้าบริการไม่ต้องเสีย primary ให้คำราคา

### 8.2 หน้ารวมไม่มี head term เชิงพาณิชย์ — ยืนยันด้วยข้อมูล

DFS pull (Thailand/th, 2026-07-27):

| keyword | volume |
|---|--:|
| อัตราค่าบริการ ทันตกรรม | 50 |
| ค่ารักษาฟัน | 40 |
| ทำฟัน ราคาเท่าไหร่ | 10 |
| ราคาทำฟัน · ทำฟัน ราคา · ค่าทำฟัน · ราคา ทันตกรรม · คลินิกทันตกรรม ราคา | ไม่มีข้อมูล (<10) |

ดีมานด์ "ราคาทำฟันแบบรวม" ในไทยวิ่งไปหา**สถาบัน** ไม่ใช่คำกลาง (`ทันตกรรม จุฬา ราคา` 110 · `ทันตกรรม จุฬา นอกเวลา ราคา` 390 · `อัตราค่าบริการ ทันตกรรม โรงพยาบาลรัฐ 2566` 170) — ทั้งหมดติด B3/B4 ใช้ไม่ได้

**ข้อสรุปเชิงนโยบาย:**
- หน้า `/pricing/` **มีไว้เพื่อ UX + conversion + เป็น single source of truth ของราคา** ไม่ใช่หน้าล่า organic head term
- primary = `อัตราค่าบริการ ทันตกรรม` ตั้ง `intent_source_tier='brand'` — **ไม่นับใน KPI organic ranking** · *(corrected 2026-08-24 against live schema — snapshot ล่าสุดใน `v_keyword_market_latest` ให้ `volume_recent_12m = 0` และ `volume_avg_48m = 0` ไม่ใช่ 50/mo ตามที่ pull ได้ 2026-07-27 · ข้อสรุปเชิงนโยบายไม่เปลี่ยน มีแต่แน่นขึ้น)*
- มูลค่า organic จริงของหน้านี้มาจาก **section ระดับบริการ** (passage/anchor) ไม่ใช่จากหัวหน้า

### 8.3 ใครเป็นเจ้าของคีย์ `X ราคา` — ตัดสินด้วย SERP รายคำ

```
overlap = |urls(X) ∩ urls(X ราคา)| / N      โดย N = min(จำนวน url ที่เก็บได้ของทั้งสองคำ)
```

**แหล่งข้อมูล:** `seo_x_ads_keyword_serp_competitors.competitor_url_list` (**13,666 แถว** วัด 2026-08-24) — SERP ไม่ผูกกับแบรนด์ ใช้แถวของแบรนด์พี่น้อง (Deezy Dental 3,568 คีย์) เทียบได้เลยเมื่อ keyword ตรงกัน *(corrected 2026-08-24 against live schema — เดิมเขียน 12,157 แถว)*
**ความครอบคลุมปัจจุบัน (วัด 2026-08-24 — ตัวเลขนี้ไหลตลอด ให้ query ใหม่ทุกครั้ง):** คีย์ VTH **1,509/2,129 ตัว (71%)** มี SERP แล้ว · ในจำนวน target ที่ assign ไปแล้ว **221/623 ตัว**มี SERP
> query: นับ `distinct fingerprint` ใน `seo_x_ads_keyword_serp_competitors where brand='VTH BioDent'` เทียบกับ `seo_x_ads_keywords_contextual_master where brand='VTH BioDent'` · ฝั่ง target นับ `distinct target_keyword_fp` ของ `seo_website_page_master where brand_id='vth-biodent' and status not in ('Merged','Dropped')` *(corrected 2026-08-24 against live schema — เดิมเขียน 260/1,694 และ 73/230)*
**ข้อควรระวัง:** แต่ละแถวเก็บ url ไว้ 7 รายการ (ไม่ใช่ top10) และ snapshot ต่างวันกันได้ถึง 2 เดือน — ผลที่ก้ำกึ่ง (0.5–0.7) ให้ pull SERP ใหม่ก่อนตัดสิน

| overlap | เจ้าของ (primary/semantic) | สร้างหน้าใหม่? |
|---|---|---|
| ≥ 0.6 | **หน้าบริการ** own เป็น semantic (primary ของหน้า = head เปล่า เช่น `ขูดหินปูน`) · หน้ารวมมี section แต่ไม่ optimize | ❌ |
| < 0.6 **และ** v ≥ 300 | **หน้ารวม** own ที่ section นั้น (H2 = คีย์, anchor id = slug) | ❌ — ใช้ section ในหน้ารวม |
| < 0.6 **และ** v ≥ 1,000 **และ** คีย์เหลือใน entity ≥ 5 | promote section เป็นหน้าลูก `/pricing/<slug>/` | ✅ |
| < 0.6 **และ** v < 300 | semantic เฉย ๆ | ❌ |

**กฎเหล็ก:** หน้ารวมห้ามตั้ง `X ราคา` ตัวใดตัวหนึ่งเป็น `target_keyword_fp` ของทั้งหน้า — primary ของหน้ารวมต้องเป็น head รวมเสมอ ไม่งั้นชนหน้าบริการซ้ำรอยเดิม

**ผลวัดจริง (คำนวณ 2026-07-27 จาก snapshot ล่าสุดของแต่ละคำ):**

| คู่ | url ซ้ำ /7 | domain ซ้ำ /7 | overlap | คำตัดสิน |
|---|--:|--:|--:|---|
| ขูดหินปูน ↔ ขูดหินปูน ราคา | 0 | 1 | **0.00** | SERP คนละชุด → คำราคาไปหน้ารวม |
| ฟอกสีฟัน ↔ ฟอกสีฟัน ราคา | 1 | 1 | **0.14** | SERP คนละชุด → คำราคาไปหน้ารวม |
| ฟันปลอม ↔ ฟันปลอม ราคา | 1 | 2 | **0.14** | SERP คนละชุด → คำราคาไปหน้ารวม |
| วีเนียร์ ↔ วีเนียร์ ราคา | 0 | 1 | **0.00** | SERP คนละชุด → คำราคาไปหน้ารวม |

**ข้อสรุป:** ทั้ง 4 คู่ overlap ≈ 0 ห่างจากเกณฑ์ 0.6 มาก → Google ถือ `X` กับ `X ราคา` เป็นคนละ intent ชัดเจน
⇒ **หน้าบริการ §3 ถือ head เปล่า · คำ `X ราคา` ทั้งหมดเป็นของหน้ารวม** และตัวที่ v ≥ 1,000 เข้าเกณฑ์ promote เป็นหน้าลูก

| คีย์ | v | primary ปัจจุบัน | ปลายทางใหม่ |
|---|--:|---|---|
| ขูดหินปูน ราคา | 15,350 | 3.7.6.1 | `/pricing/scaling/` (promote — v ≥ 1,000) · 3.7.6.1 เปลี่ยนไปถือ `ขูดหินปูน` (12,325) |
| ฟอกสีฟัน ราคา | 5,417 | 3.7.23.4 (หน้าเลเซอร์) | `/pricing/whitening/` · 3.7.4 ถือ `ฟอกสีฟัน` (3,933) |
| ฟันปลอม ราคา + 4 คำร่วม | ~2,860 | กระจาย 2 หน้า | `/pricing/denture/` |
| เคลือบฟลูออไรด์ ราคา (3 คำ) | ~1,430 | 3.7.2.2 | `/pricing/fluoride/` · 3.7.2.2 ถือ `เคลือบฟลูออไรด์` (5,650) |
| ตัด เหงือก ราคา | 995 | 3.7.6.6 | section `#gingivectomy` ในหน้ารวม (ยังไม่ถึงเกณฑ์ promote) |

> ~~ยังไม่มี SERP ของ `ตัด เหงือก ราคา` และ `เคลือบฟลูออไรด์` (คำเปล่า) ในตาราง — ต้อง pull ก่อนยืนยัน 2 แถวล่าง~~
> ✅ **pull แล้ว** ทั้งสองคำมีแถวใน `seo_x_ads_keyword_serp_competitors` ของ VTH BioDent *(corrected 2026-08-24 against live schema)*
>
> 🔴 **คอลัมน์ "primary ปัจจุบัน" ในตารางข้างบนตกรุ่นแล้ว — แผนถูกรันไปแล้ว** วัด 2026-08-24: คำราคาทั้งชุดย้ายไปหน้าลูกของ hub จริง
> `ขูดหินปูน ราคา`→`8.4.1` /pricing/scaling · `ฟอกสีฟัน ราคา`→`8.4.2` · `ฟันปลอม ราคา`→`8.4.3` · `เคลือบฟลูออไรด์ ราคา`→`8.4.4` · `ตัด เหงือก ราคา`→`8.4.6` (ได้หน้าเต็ม ไม่ใช่ section) · และ `3.7.6.1` ถือ `ขูดหินปูน` · `3.7.4` ถือ `ฟอกสีฟัน` ตามที่วางไว้ *(corrected 2026-08-24 against live schema)*

### 8.4 ข้อบังคับเชิงเทคนิค

1. **Single source of truth**: ราคาทั้งหมดเก็บที่เดียว (DB หรือ `pricing.json`) — หน้ารวม render ทั้งชุด · หน้าบริการ filter ตาม slug **ห้ามพิมพ์ตัวเลขซ้ำสองที่**
2. **Schema**: หน้ารวม = `OfferCatalog` (itemListElement = Service + priceSpecification) · หน้าบริการ = `Service` + `offers` ค่าต้องตรงกับหน้ารวมเป๊ะ
3. **Anchor**: heading จริง + `id` = slug ของบริการ · URL pattern `/pricing/#<slug>` เพื่อ migrate เป็น `/pricing/<slug>/` ได้ภายหลังโดยไม่รื้อ
4. **§9 Local**: หน้าสาขาไม่ทำตารางราคาซ้ำ ให้ลิงก์เข้าหน้ารวม (ยกเว้นราคาต่างกันจริงตามสาขา)
5. แสดง **"เริ่มต้น X" + ช่วงราคา + เงื่อนไข** แทนราคาตายตัวรายเคส

**ข้อมูลปัจจุบัน (VTH — วัด 2026-08-24 ตัวเลขไหลตลอด ให้ query ใหม่):** คีย์กลุ่มราคา **103 ตัว** (`brand='VTH BioDent' and keyword like '%ราคา%'`) มี v ≥ 500 เพียง **7 ตัว** · มี **11 คีย์ราคาเป็น primary ของหน้าใดหน้าหนึ่ง** และเหลือเพียง **1 ตัวที่ยังนั่งอยู่บนหน้า §3** — ชุดนี้เข้า audit ก่อนเป็นลำดับแรก *(corrected 2026-08-24 against live schema — เดิมเขียน 107 / 8 / 34 ตัวบนหน้า §3 ซึ่งย้ายไป §8.4.x เกือบหมดแล้ว)*
คีย์ราคา 103 ตัวมี `primary_entity_fp` แล้ว **92 ตัว (ขาด 11)** — **ไม่ใช่ตัวบล็อก** ส่วนคอลัมน์ `primary_entity_name` **backfill แล้ว ไม่ได้ null ทั้งตาราง**: VTH 1,532/2,129 แถวมีค่า (ทั้งฐาน 7,854/22,710) *(corrected 2026-08-24 against live schema — เดิมเขียน 106/95 และ "null ทั้งตาราง")*

> ⚠️ **Compliance:** การโฆษณาราคาสถานพยาบาลอยู่ภายใต้ พ.ร.บ.สถานพยาบาล พ.ศ. 2541 ม.38 (โฆษณาสถานพยาบาลต้องได้รับอนุมัติจากผู้อนุญาต) — ครอบคลุมทั้งหน้ารวม **และ price block ที่ฝังในหน้าบริการ** ต้องยื่นในคำขอเดียวกัน ตั้ง `legal_review_required = true` ทุกหน้าที่แสดงราคา

---


### 8.5 หมวดราคาอยู่ตรงไหนในผังไซต์

**ให้อยู่ใต้ §8 (Contact & Support) เป็น sub-section + ลูกของมัน — ไม่ตั้งเป็น section ใหม่**
🔴 *(corrected 2026-08-24 against live schema — เลข node จริงคือ **`8.4` + ลูก `8.4.1`–`8.4.11`** (slug `/pricing`, `/pricing/<service>`) ส่วน `8.10` ที่เอกสารเดิมระบุไว้ถูกใช้โดยหน้า **International Patients** อยู่แล้ว · ยึดเลขจาก DB ตาม §13.5 ข้อ 1 ไม่ใช่จากเอกสาร)*

| เหตุผล | รายละเอียด |
|---|---|
| รักษาโครง 8-section | Bible §4.2 กำหนด 8-section universal · การเพิ่ม section ใหม่ให้หมวดราคา (7–10 หน้า) ทำให้โครงหลุดมาตรฐานและแบรนด์อื่นลอกตาม |
| อยู่กลุ่มเดียวกับหน้าสิทธิ/เบิกจ่าย | "เท่าไหร่ · จ่ายยังไง · เบิกได้ไหม" เป็น job เดียวกันของคนไข้ ต้องลิงก์ถึงกันสองทาง |
| §8 คือ utility / pre-visit cluster | อยู่ร่วมกับ First Visit · Self-Assessment · International Patients ได้ตามธรรมชาติ |
| ระดับความสำคัญตรงกับข้อมูล | head term ของหมวด (`อัตราค่าบริการ ทันตกรรม` — snapshot ล่าสุดให้ `volume_recent_12m = 0` วัด 2026-08-24 *(corrected 2026-08-24 against live schema — เดิมเขียน 50/mo)*) ไม่ใช่ pillar — มูลค่าอยู่ที่ section ระดับบริการ |

**URL แยกจากผัง** — slug ยังเป็น `/pricing/...` ที่ root ได้ตามปกติ · `sitemap_section` เป็นเรื่องผังข้อมูล/nav ไม่ใช่ path
**nav:** footer / utility nav เท่านั้น ไม่ขึ้น main nav แข่งกับ Services
**เกณฑ์เลื่อนขึ้นเป็น top-level section:** เมื่อ GSC ยืนยันว่ากลุ่มคีย์ `<บริการ> ราคา` รวมกันเกิน ~10,000/เดือน และหน้าราคาสร้าง conversion ได้จริง — เลื่อนขึ้นง่ายกว่าดึงลง

## 8b. §9 Local — สถาปัตยกรรมคีย์เวิร์ดแบบขยายสาขาได้ (Multi-Branch)

> เพิ่ม 2026-07-28 — ตอบโจทย์ "ถ้ามีมากกว่า 2 สาขาจะใช้คีย์อะไร"

**ปัญหา:** `<บริการ> ใกล้ฉัน` เป็นคำเดียวระดับประเทศ Google เลือกผลตามพิกัดผู้ค้นเอง — **1 คำนี้เป็นของได้แค่หน้าเดียว** ถ้ายกให้หน้าสาขา พอมีสาขาที่ 3–4–5 จะไม่มีคำเหลือให้ และสาขาเดิมจะแย่งกันเอง

### โครง 3 ชั้น (ขยายได้ไม่จำกัดสาขา)

| ชั้น | หน้า | คีย์หลัก | ตัวอย่าง |
|---|---|---|---|
| **L1 บริการ** | §3 service page | head term เปล่า | `ขูดหินปูน` 12,325 |
| **L2 Local hub** | **9.1 `local-services`** | **near-me family (ทั้งแบรนด์ถือที่นี่ที่เดียว)** | `ขูดหินปูน ใกล้ฉัน` 4,808 |
| **L3 หน้าสาขา** | 9.x `<service>-<branch>` | **geo modifier ที่ระบุย่านชัดเจน** | `ขูดหินปูน พระราม 3` · `ขูดหินปูน ยานนาวา` |

**กฎ:**
1. **ห้ามให้หน้าสาขาถือคำ `ใกล้ฉัน`** — ไม่ scale เกิน 1 สาขา
2. หน้าสาขาถือ `<บริการ> <ย่าน>` เท่านั้น · ย่าน = ชื่อที่คนไข้ใช้จริง (ถนน/ย่าน/ห้าง) ไม่ใช่ชื่อเขตราชการ
3. **ถ้า `<บริการ> <ย่าน>` volume = 0 (พบบ่อยมากในไทย) ยังตั้งเป็น primary ได้** แล้วตั้ง `page_purpose='utility'` — หน้านี้มีไว้เพื่อ GBP / local pack / conversion **ไม่นับ KPI organic**
4. Local pack ไม่ได้ชนะด้วยหน้าเว็บ แต่ชนะด้วย **GBP + NAP + รีวิว + proximity** — หน้าสาขาคือ landing page ของ GBP ไม่ใช่ตัวไล่อันดับ

### Checklist ตอนเปิดสาขาใหม่

1. ยิง DFS `<บริการหลัก 5 ตัว> <ย่านใหม่>` เช็ค volume
2. สร้างหน้า 9.x ต่อจากเลขล่าสุด · primary = `<บริการ> <ย่าน>` (แม้ volume 0)
3. ลิงก์จาก 9.1 hub → หน้าสาขาใหม่ และจาก §3 service → 9.1
4. **ไม่ต้องแตะคีย์ near-me** ของ 9.1 เลย

### สถานะปัจจุบัน (2 สาขา — interim)

หน้าที่ถือคำ near-me อยู่จริง (วัด 2026-08-24): **9.1 · 9.7 · 9.9 · 9.10 · 9.15 · 9.18 · 9.20 — 7 หน้า** และ **9.1 hub ถือ head term `ทําฟัน ใกล้ฉัน` แล้วตามกฎ L2** ส่วน 9.2–9.6 / 9.8 / 9.11–9.14 / 9.16–9.17 / 9.19 / 9.21 เป็น `Merged` ไปแล้ว (14 หน้า) *(corrected 2026-08-24 against live schema — เดิมเขียนช่วง "9.8–9.15" ซึ่งกินหน้า Merged และตกหน้าที่ถือคำจริงไปหลายหน้า)* เพราะยังไม่มีคีย์ geo ของ พระราม 3 / Park 11 ในคลัง (ยิง DFS แล้ว `จัดฟัน พระราม 3` / `หมอฟัน พระราม 3` ไม่มีข้อมูล)

คลังคำ near-me ของ VTH มี **23 คำ** และ **assign เป็น primary ไปแล้ว 7 คำ** (`brand='VTH BioDent' and keyword like '%ใกล้ฉัน%'`) *(corrected 2026-08-24 against live schema)*

> ⚠️ **Migration trigger:** เมื่อเปิด**สาขาที่ 3** ให้ย้ายคำ near-me ทั้งหมดขึ้นไปที่ 9.1 hub ทันที แล้วให้หน้าสาขาทั้งหมดถือคีย์ geo แทน — 🔴 ตรวจ 2026-08-24 (รอบซ้ำ): ข้อความนี้อยู่ใน `note_brief` ของ **9.8 และ 9.11 เท่านั้น ซึ่งทั้งคู่เป็น `Merged` ไปแล้ว** ส่วนหน้าที่ถือคำ near-me อยู่จริงตอนนี้ (9.1 · 9.7 · 9.9 · 9.10 · 9.15 · 9.18 · 9.20) **ไม่มีหน้าไหนบันทึกไว้เลย** — ต้องย้ายข้อความนี้ลง `note_brief` ของหน้า active ก่อน ไม่งั้น trigger ตายไปพร้อมหน้าที่ถูกยุบ *(corrected 2026-08-24 — ฉบับก่อนหน้าในวันเดียวกันเขียนว่า 9.1 และ 9.10 มีข้อความนี้อยู่จริง ซึ่งไม่ตรงกับฐาน: query `note_brief ilike '%สาขาที่ 3%'` คืน 9.8 · 9.11 เท่านั้น)*

---

## 9. เกณฑ์สร้างหน้าใหม่ (คีย์เหลือจากคลัง)

เสนอหน้าใหม่เมื่อครบทั้ง 3 ข้อ:

1. entity นั้นมีคีย์เหลือ (ยังไม่ถูกใช้เป็น primary/semantic) **≥ 5 ตัว**
2. volume รวมของคีย์เหลือ **≥ 300/เดือน**
3. SERP overlap กับหน้าเดิมของ entity **< 0.6**

**backlog ที่คำนวณได้จากข้อมูลจริง (VTH — วัด 2026-08-24: **26 entity** ผ่านเกณฑ์ข้อ 1 · ในนั้น **20 entity** ผ่านเกณฑ์ข้อ 2 ด้วย):**

> ตัวเลขชุดนี้ไหลทุกครั้งที่ assign คีย์ — **อย่าอ่านเป็นค่าคงที่ ให้คำนวณใหม่**: คีย์ของ `brand='VTH BioDent'` ที่ไม่ปรากฏใน `target_keyword_fp` และไม่อยู่ใน `semantic_keywords_fps[]` ของหน้า active ใด ๆ · group by `primary_entity_fp` · volume จาก `v_keyword_market_latest.volume_recent_12m`
> *(corrected 2026-08-24 against live schema — เดิมเขียน 36 entity พร้อมตารางที่ค่าเคลื่อนไปทุกช่อง เช่น Dental Scaling & Cleaning ที่เคยขึ้นว่า 1 หน้า / 52 คีย์ / 49,172 ตอนนี้เป็น 4 หน้า / 13 คีย์ / 813)*

| entity | หน้าปัจจุบัน | คีย์เหลือในคลัง | volume รวม |
|---|--:|--:|--:|
| Canker Sore (Aphthous Ulcer) | 1 | 18 | 4,702 |
| Impacted Tooth | 2 | 26 | 3,309 |
| Insomnia | 2 | 5 | 2,235 |
| Toothache | 1 | 60 | 2,087 |
| Halitosis (Bad Breath) | 1 | 35 | 2,070 |
| Dental Filling | 3 | 36 | 1,969 |
| Gingival Swelling | 1 | 29 | 1,906 |
| Over-the-Counter Pain Relief | 1 | 7 | 1,291 |

หน้าใหม่ต้องระบุ intent ที่ **ต่างจาก pillar เดิมชัดเจน** ในช่อง `page_purpose` ก่อนอนุมัติ

---

## 10. QA gates (รันทุกครั้งหลัง assign — ต้องผ่านทั้ง 9 ข้อ) *(corrected 2026-08-24 — ตารางมี Q1–Q9 ตั้งแต่ v1.4 แต่หัวข้อยังเขียน 8)*

| # | เช็ค | เกณฑ์ผ่าน |
|---|---|---|
| Q1 | primary ซ้ำหลังnormalize | 0 แถว |
| Q2 | primary ที่ติด blacklist ข้อ 4 (B1/B7/B9) | 0 แถว |
| Q3 | intent ขัด matrix ข้อ 5 | 0 แถว |
| Q4 | หน้า §9 ที่ primary ไม่มี geo/near-me | 0 แถว |
| Q5 | หน้าลูกถือคีย์กว้างกว่าหน้าแม่ | 0 แถว |
| Q6 | primary v=0 ที่ไม่ได้ติดธง `brand-nav` ใน `page_master.flag_review` *(corrected 2026-08-24 against live schema — ธงจริงเขียนด้วยขีดกลาง ไม่ใช่ `brand_nav`)* | 0 แถว |
| Q7 | คีย์ที่เป็น primary แล้วไปโผล่เป็น semantic ที่อื่น | 0 แถว |
| Q8 | entity เดียวกันมี primary >1 หน้า โดย SERP overlap ≥0.6 | 0 แถว (ไม่งั้น = cannibalization) |
| **Q9** | **คีย์ใกล้ซ้ำระดับ trigram ที่ทั้งสองฝั่งเป็น primary** (L24) | 0 แถว หรือมีคำอธิบายรายคู่ |

**Q1 มีสามชั้น ไม่ใช่สองชั้น** — L13 ให้ token-sort + strip-เว้นวรรค · **L24 เพิ่มชั้น trigram** เพราะสองชั้นแรกจับการสลับลำดับคำไทยที่ไม่เว้นวรรคไม่ได้

```sql
-- Q1 ชั้นที่ 1 · token-sort
with p as (
  select brand_id, sitemap_node_id, kw_norm(k.keyword) n
  from seo_website_page_master pm
  join seo_x_ads_keywords_contextual_master k on k.fingerprint = pm.target_keyword_fp
)
select brand_id, n, count(*), string_agg(sitemap_node_id, ',')
from p group by 1, 2 having count(*) > 1;

-- Q1 ชั้นที่ 2 · strip เว้นวรรค (L13)  → เปลี่ยน kw_norm(k.keyword) เป็น replace(lower(k.keyword),' ','')

-- Q9 / Q1 ชั้นที่ 3 · trigram (L24) — ตัดคู่ substring ออกเพราะนั่นคือ "หัวคำ vs คำมุม" ที่ถูกตาม DR-048
select keyword_a, page_a, keyword_b, page_b, kw_similarity
from v_keyword_near_duplicates
where brand = :brand and page_a is not null and page_b is not null and kw_similarity >= 0.70
  and position(replace(lower(keyword_a),' ','') in replace(lower(keyword_b),' ','')) = 0
  and position(replace(lower(keyword_b),' ','') in replace(lower(keyword_a),' ','')) = 0;
```

> ⚠️ ชั้นที่ 3 มี false positive — `ค่ารากฟันเทียม` ⟷ `ผ่ารากฟันเทียม` (0.765) ต่างกันอักษรเดียวแต่คนละความหมายสิ้นเชิง · **ห้าม auto-fix** เหมือนตัวตรวจชั้นสองของ DR-051

---

## 11. บันทึกและตรวจสอบย้อนหลัง

ทุกการ assign ต้องเขียน `page_master.viability_assessment` (jsonb):

```json
{
  "kw_rule_version": "1.0",
  "relevance_tier": "R1",
  "intent_match": true,
  "serp_compat": 0.72,
  "volume_12m": 1275,
  "kd": 12,
  "runner_up": "ฟันโยก หายเองได้ไหม",
  "decided_by": "etl",
  "decided_at": "2026-07-27"
}
```

ห้าม assign ด้วยมือลง production — ทุกการเปลี่ยนแปลงผ่าน ETL ที่ log ได้ (สอดคล้องกับข้อตกลง "Supabase load = ETL only")

---

## 11b. บทเรียนจากการรันจริง — กับดักที่เจอและวิธีกัน

> รวบรวมจากการ overhaul VTH BioDent 2026-07-27→28 · **อ่านก่อนรันแบรนด์ถัดไป** · ฉบับ universal อยู่ที่ `eywa-protocol-spec/Keyword_Assignment_SOP.md`

| # | กับดัก | สิ่งที่เกิดขึ้นจริง | วิธีกัน |
|---|---|---|---|
| L1 | **เขียนกฎแล้วไม่ implement** | SOP §5 มีกฎ hierarchy monotonicity ตั้งแต่วันแรก แต่ rule engine รอบแรกไม่ได้ใส่ → หน้า `brava-ai-*` ได้คำ `จัดฟัน แปรงฟันยังไง`, `sweeps-endodontic` ได้ `fotona 4d` | ทุกกฎใน SOP ต้องมี **บรรทัด SQL ที่บังคับใช้จริง** + QA gate คู่กัน ไม่ใช่แค่ข้อความ |
| L2 | **ปล่อย loop ไล่จนคีย์หมด** | engine ไล่ 40 รอบเพื่อเติมหน้าให้ครบ ได้ 201 ข้อเสนอ แต่ยัดคีย์อ่อนให้หน้าที่ว่าง (`nitrous-oxide` ← "ฟันคุด มีกี่แบบ") | loop ต้อง `exit when no new match` **ไม่ใช่** `exit when pages full` · หน้าที่ไม่มีผู้สมัคร = ปล่อยว่าง |
| L3 | **R3 (cluster เดียวกัน) คือ noise** | ผู้สมัคร R3 มี 10,190 คู่ ผ่าน lexical-anchor gate เหลือ **4 คู่** | R3 ต้องมี alias ของ entity หน้านั้นอยู่ในตัวคำเสมอ ไม่งั้นห้ามใช้ |
| L4 | **fingerprint จับคำซ้ำไม่ได้** | `เลเซอร์เหงือก` vs `เลเซอร์ เหงือก` · `neodent รากเทียม` vs `รากเทียม neodent` — 7 คู่หลุดเป็น primary ของคนละหน้า | `kw_norm()` (lower + ยุบช่องว่าง/ขีด + เรียง token) + unique index ตั้งแต่วันแรก |
| L5 | **entity ซ้ำ → อย่าแก้ที่คีย์** | ครั้งแรก remap คีย์ของแบรนด์ตัวเองไปอีก entity → **ทำลาย cross-brand rollup** (VTH ชี้ `endodontic-treatment`, Deezy ชี้ `root-canal-treatment` = concept เดียวกันแต่คนละถัง) | แก้ที่กราฟเสมอ (DR-042) · canonical = แถวที่แบรนด์ซึ่ง data สมบูรณ์ที่สุดใช้อยู่ |
| L6 | **"ไม่มีคีย์" ≠ "seed ไม่ครบ"** | สมมติว่า 313 หน้าที่ว่างเกิดจาก research ไม่ครบ · ยิง DFS 6 รอบพิสูจน์ว่าดีมานด์ไทยบางจริง (`ยาสลบ ทำฟัน` 0 · `รากเทียม เซรามิก` 0) | ยิงทดสอบ 3–5 seed ก่อนตัดสินใจลงทุน expansion ทั้งชุด |
| L7 | **`keyword_ideas` ของ DFS ใช้กับงานนี้ไม่ได้** | เป็น category-based → seed "ใกล้ฉัน" คืน ปั๊มน้ำมัน/หม่าล่า · seed คลินิก คืน "นิวเคลียส หน้าที่" | ใช้ `keyword_suggestions` (full-text ต้องมี seed อยู่ในคำ) หรือ `google_ads_search_volume` กับรายการที่คัดแล้ว |
| L8 | **Google Ads ไม่คืน volume ≠ ไม่มีคนค้น** | `รีเทนเนอร์` / `คอมโพสิต วีเนียร์` ไม่มีข้อมูล แต่ **SERP มีจริงและเป็น service-type** (`รีเทนเนอร์` มีหน้าบริการ 3/7 ผล) | เจอ volume ว่าง ให้ดู SERP ก่อนตัดทิ้ง · ตั้งเป็น primary ได้ + โน้ตว่ารอ GSC |
| L9 | **คำพ้องรูปปนเข้ามาเงียบ ๆ** | `วีเนียร์ หิน/ลายไม้/พลายวู้ด` = วัสดุก่อสร้าง · `เหงือก ฉลาม/ปลาทอง` = เหงือกปลา · `ลิฟท์ ขากรรไกร` = แม่แรงยกรถ — รวม 18 คำ | triage รอบแรกต้องดูตาเปล่าเสมอ อย่าเชื่อ entity tagging อย่างเดียว |
| L10 | **เลข node ชนของเดิม** | เสนอ 5.6.20 / 6.9.10 / 8.7 โดยดูจากรายการที่ filter มา — ชนหน้าที่มีอยู่จริงทั้ง 4 | ก่อนจอง node ใหม่ ให้ `select max(...)` จาก DB เสมอ ไม่ใช่จากเอกสาร |
| L11 | **constraint ของ schema ไม่ตรงกับที่คิด** | `intent_source_tier` รับแค่ `paa/derived/template_only` — ธง "ไม่นับ KPI organic" ต้องใช้ `page_purpose='utility'` แทน · `compliance_max_tier` เป็น generated column · 🔴 *(corrected 2026-08-24 against live schema — ทุกวันนี้ `intent_source_tier` รับค่าที่ **4 คือ `brand`** และมีใช้จริง 88 แถว (VTH 87) ส่วน `paa` **0 แถว ไม่เคยถูกเขียนเลย** · §2 / §4.1 / §7 ที่สั่งให้ตั้ง `'brand'` จึงรันได้จริง ไม่ใช่ข้อขัดแย้ง · `page_purpose='utility'` ยังมีอยู่ 82 แถว ใช้คู่กันได้)* | อ่าน `pg_constraint` ก่อนออกแบบ field mapping |
| L12 | **DB มี constraint ที่ช่วยเราอยู่แล้ว** | insert หน้าราคาไม่ผ่านเพราะคีย์ยังผูกกับหน้าเดิม — 1 keyword : 1 page ถูกบังคับที่ DB จริง | อย่ามองว่าเป็น error ให้มองว่าเป็น gate ที่ทำงาน แล้วปลดคีย์เดิมก่อน |
| L13 | **`kw_norm()` จับคำไทยที่ไม่เว้นวรรคไม่ได้** | `ฟันปลอม ทั้งปาก` กับ `ฟันปลอมทั้งปาก` เป็นคำเดียวกันในสายตาผู้ค้น แต่ normalize ออกมาคนละค่า (token เดียว vs สอง token) → QA Q1 ไม่จับ | เสริม gate: เทียบเวอร์ชัน **ลบช่องว่างทั้งหมด** (`replace(kw,' ','')`) ควบคู่กับ token-sort · เจอคู่แบบนี้ให้ตัวหนึ่งเป็น semantic |
| L14 | **QA gate ที่ผูกกับเลข section จะพังเมื่อย้ายหมวด** | ย้ายหมวดราคา §10 → §8.10 แล้ว gate Q4c (`section <> '10'`) รายงาน false positive 6 หน้า | เขียน gate ให้ผูกกับ **คุณสมบัติของหน้า** (slug prefix / page_purpose) ไม่ใช่เลข section |
| L15 | **renumber node ต้องทำ 2-phase** | สลับเลขในหมวด (5.3.22 → 5.3.1 ขณะที่ 5.3.1 ยังอยู่) ทำตรง ๆ จะชน unique key ทันที | เขียน `page_fingerprint` เป็นค่าชั่วคราว (`zzz-<new>`) ก่อน แล้วค่อยลงค่าจริง · อัปเดต **7 จุด** เสมอ (ดู §13.3) — สามจุดหลังไม่มี FK คุม: `page_citations.page_fp` · `editorial_reviews.page_fp` · `planned_outbound_fps` |
| L16 | **`link_priority` มี CHECK 1–10** | จะใช้เก็บลำดับการอ่าน 1–26 ไม่ได้ | ใช้ priority ระดับ**กลุ่ม** + เก็บลำดับย่อยใน `section_context` / `surrounding_text_snippet` |
| L17 | **title/meta ของหน้าใหม่ต้องเดินตาม convention ของหน้าเดิม ไม่ใช่ best practice ทั่วไป** | จะเขียนตามสูตรสากล (ใส่ brand suffix, title ≤60 ตัวอักษรละติน) แต่ 698 หน้าเดิมของแบรนด์ไม่มี suffix เลย (3/698) และวัดเป็นตัวอักษรไทย | ก่อนเขียน ให้ query หาค่า min/max/avg ความยาว + นับสัดส่วนที่มี brand suffix จากหน้าที่มีอยู่แล้ว แล้วยึดค่านั้นเป็นเกณฑ์ |
| L18 | **title/meta ที่เขียนตอนวางแผน = baseline ไม่ใช่ final** | ตอนวางแผนยังไม่ได้ดู SERP ของคู่แข่งที่ครองอันดับรายหน้า | เขียนให้ครบเป็น baseline (กัน field ว่างตอน build) แล้ว **ทบทวนอีกรอบตอนเขียนเนื้อหาจริง** พร้อมเทียบ SERP · บันทึกสถานะไว้ที่ `reconciliation_notes` |
| L19 | **หน้าที่ `legal_review_required=true` ต้องคุมถ้อยคำถึงระดับ meta** | meta ของหน้าราคาถ้าเขียนแบบชวนซื้อ/เทียบราคา = โฆษณาสถานพยาบาลตาม ม.38 · หน้ายาถ้าอ้างสรรพคุณ = พ.ร.บ.ยา ม.88 | หน้าราคา: meta อธิบาย**ปัจจัยที่ทำให้ราคาต่าง** ไม่ใส่ตัวเลข ไม่มีคำเชิญชวน · หน้ายา: ไม่อ้างสรรพคุณ ไม่ระบุขนาดยาใน meta · ทุกหน้าอาการ: ห้ามคำรับประกันผล |
| L20 | **DFS ไม่คืน volume ให้หัวคำไทยตัวใหญ่ — absence ≠ zero** | `ครอบฟัน` `อุดฟัน` `รักษารากฟัน` `ฟันคุด` `จัดฟัน` `จัดฟันใส` `รากฟันเทียม` `หยุดหายใจขณะหลับ` คืนค่าว่างทั้งหมด ขณะที่ `ขูดหินปูน` รูปประโยคเดียวกันเป๊ะคืน **12,100/mo** · DFS ยังคืน backlink profile ของคำเหล่านั้นมาด้วย และมันชี้ว่า SERP แข่งดุ (`จัดฟัน` avg 13.3 backlinks · rank 71.3) | เก็บ snapshot เป็น **`NULL` ไม่ใช่ `0`** + ตั้ง `data_signal_quality=0` · L8 ยังใช้ได้แต่ขยายผล: ตัวเลขว่างของ DFS เป็นช่องว่างของ**ข้อมูล** ไม่ใช่ของ**ดีมานด์** |
| L21 | **§3 ถือคำถามแทนหัวบริการ — ผ่านทุกเกตเพราะไม่มีอะไรผิดกติกา** | `3.7.16 Clear Aligner (hub)` ถือ `ข้อเสีย จัดฟันใส` ขณะที่ `จัดฟันใส` เปล่า ๆ ไม่มีในคลังเลย · รวม 22 หน้าผิดบทบาท และหัวบริการหายจากคลัง 9 คำ | รัน detector ตาม DR-051 ก่อนประกาศว่าคีย์ครบ — ทั้งชั้น "หัวหาย" และชั้น "คำผิดบทบาท" · ผลชั้นสองมี false positive สูง (33 hit จริง 10) ต้องอ่านด้วยคน |
| L22 | **byline บนเทมเพลต ≠ editorial review record** | VTH โชว์ชื่อหมอครบทุกหน้า EEAT แต่ `seo_editorial_reviews` มี **0 แถว** ของแบรนด์ ขณะที่ Deezy มี 666 | ผูก reviewer ให้ครบทุกหน้าตั้งแต่แผน · และ **ห้ามบันทึก `approved=true` ให้หน้าที่ยังไม่มีเนื้อหา** — หน้า Planned ได้แค่ `pending` เพราะ field นี้เป็นสิ่งที่ผู้ตรวจอ่านตามตัวอักษร |
| L23 | **เจอข้อบกพร่องแบบมีทิศทาง ให้ตรวจทิศตรงข้ามทันที** | ปิดลิงก์ที่ *ชี้เข้า* หน้า Merged 373 เส้นแล้วประกาศจบ — อีกสามรอบถัดมาถึงพบว่ามี 595 เส้น *วิ่งออกจาก* หน้าเดียวกันนั้น รวม 968 เส้นกำลังออกเว็บจริง | เกตทุกข้อที่ถามความสัมพันธ์ ต้องถามทั้งสองปลาย (DR-049) · และเทียบตัวเลขปลายทาง: from-page ใน export ต้องเท่ากับจำนวนหน้า active พอดี |
| L24 | **Q1 สองชั้นของ L13 จับ "การสลับลำดับคำไทยที่ไม่เว้นวรรค" ไม่ได้** | Smile Scape ผ่าน Q1 ทั้ง token-sort และ strip-เว้นวรรค แล้วประกาศ 0 — ชั้น `pg_trgm` พบ **13 คู่ที่ทั้งสองฝั่งเป็น primary ของคนละหน้า**: `รักษาโรคเหงือก` ⟷ `โรคเหงือก รักษา` (0.72) · `ผ่าตัดรากฟันเทียม` ⟷ `รากฟันเทียม ผ่าตัด` (0.76) · `คลินิกสไมล์สเคป` ⟷ `สไมล์สเคป คลินิก` (0.78) · เหตุผลเชิงกลไก: token-sort ต้องมีช่องว่างถึงจะตัดคำได้ ส่วน strip-เว้นวรรคเทียบสตริงตรงตัวจึงแพ้ทันทีเมื่อลำดับคำต่าง | **Q1 ต้องมีชั้นที่ 3** (= Q9 ใน §10) — `v_keyword_near_duplicates` sim ≥ 0.70 โดยตัดคู่ที่ฝั่งหนึ่งเป็น substring ของอีกฝั่งออก · **ห้าม auto-fix** มี false positive (`ค่ารากฟันเทียม` ⟷ `ผ่ารากฟันเทียม` 0.765 ต่างอักษรเดียวแต่คนละความหมาย) |
| L25 | **dedupe ที่ใช้แต่การเทียบสตริงจะประกาศ "สะอาด" ทั้งที่ยังซ้ำ** | Smile Scape ยุบ entity/cluster ด้วยชื่อ · token-sort · ICD จนเกตขึ้น 0 ทุกข้อ — พอรันชั้น embedding ทีหลังเจอของจริงอีก 4 รายการ: `social-security-dental-benefit "(TH)"` (17 หน้า · 9 คีย์) · `bone-graft-implant` (deezy ซ้ำกับตัวเอง) · `tmj-disorder` ที่ loader รอบหลังเขียนทับให้ไปนั่งผิดคลัสเตอร์ · และคู่ subtype ที่ต้องผูก edge แทนยุบ | รัน **ทั้ง 4 view ก่อน**เริ่ม dedupe ทุกรอบ · เกตปิดงานเพิ่ม 3 ข้อ: trigram-pair = 0 · semantic `cluster_conflict` = 0 · **embedding ที่ยังชี้ entity `seo_entity_graph.entity_lifecycle='merged'` = 0** *(corrected 2026-08-24 against live schema — ชื่อคอลัมน์คือ `entity_lifecycle` ไม่ใช่ `lifecycle` · ค่า `merged` มีอยู่จริง 23 แถว)* (ยุบ entity ต้อง `delete from seo_entity_embeddings` ด้วย ไม่งั้น view ชูซากขึ้นมาซ้ำทุกรอบ) |
| L26 | **similarity เป็นตัวกรองผู้ต้องสงสัย ไม่ใช่ตัวตัดสิน assign — ห้าม auto-assign คีย์ด้วยคะแนน** | Smile Scape (Wave 16g) จะปิดช่องว่าง 259 หน้าโดยยืมคำที่ "วัดแล้ว" ซึ่งผูก `primary_entity_fp` เดียวกัน (186 หน้าเข้าเงื่อนไข 8,334 คู่) แต่พังสองชั้น: (ก) **มีแค่ 1,401 คู่ที่เป็นคำของแบรนด์ตัวเอง** ที่เหลือเป็นของอีก 2 แบรนด์ในตารางร่วม — assign ไปคือทำ brand scope พัง (ข) แม้กรองเหลือคำของตัวเอง + guard 3 ชั้น + ตัด substring + ล็อก intent ตามหมวดแล้ว เหลือ 14 คู่ และคุณภาพยังไม่ผ่าน เพราะ trigram จับ *สตริง* ไม่จับ *ความหมาย*: `รากฟันเทียมหลุด` ← `รากฟันเทียม ดีไหม` · `รากฟันเทียมทำจากอะไร` ← `รากฟันเทียม กินอะไรไม่ได้` · `ปลูกกระดูกล้มเหลว` ← `ปลูกกระดูก เจ็บไหม` · `All-on-4 คืออะไร` ← `all on 4 ราคา` | ใช้ similarity ตั้ง *ผู้สมัคร* ได้ แต่ **ต้องมีคนอ่านยืนยันว่าตรงหัวข้อจริงก่อน assign ทุกคู่** · การยืมคำข้ามแบรนด์ในตารางร่วมต้องสร้างแถวของแบรนด์ตัวเอง + วัดเอง (`borrowed_from_fp`) ห้ามชี้ `target_keyword_fp` ไปที่แถวของแบรนด์อื่น · กฎเดียวกับ citation: ขยาย matcher ให้ครอบคลุมขึ้นเมื่อพูล "ดูบาง" คือทางที่ผูกของผิดเข้าหน้า |
| L27 | **`COMMENT ON COLUMN` บอก *เจตนา* ไม่ได้การันตี *ของที่อยู่จริง* — ก่อนประกาศว่าข้อมูลเสีย ให้ select ตัวอย่างจริงมาดูและเทียบข้ามแบรนด์ก่อน** | Smile Scape (Wave 16k) ตรวจ route-back โดยอ่าน COMMENT ของ `seo_website_page_master.planned_outbound_fps` ที่เขียนว่าเก็บ *"text[] of page_fingerprint values"* แล้ว join กับคอลัมน์ `fingerprint` (ฟอร์แมต `page_{ULID16}`) → ได้ 0 ทุกช่อง เกือบสรุปว่าเป็นดาต้าเสีย 535 แถวและเกือบเขียนทับ · ของจริงคือทั้ง `planned_outbound_fps` และ `seo_page_internal_links.from_page_fp/to_page_fp` ใช้ id แบบ **`<brand>-<sitemap_node_id>`** (`smilescape-3.13` · `vth-6.2.12.1`) เหมือนกันทั้ง 2 แบรนด์ ทั้ง 2 ตาราง **16,457 ลิงก์ ไม่มีสักแถวที่ใช้ `page_`** — COMMENT ล้าสมัย ไม่ใช่ข้อมูลผิด | กฎ "อ่าน COMMENT ก่อนเขียนค่า" ยังคงอยู่ แต่เพิ่มขาที่สอง: **ก่อน `update`/ประกาศ defect เพราะข้อมูลไม่ตรง COMMENT ให้ (1) select ตัวอย่างจริง (2) นับสัดส่วนฟอร์แมตทั้งตาราง (3) เทียบกับแบรนด์อื่นในตารางร่วม** · ถ้าทุกแบรนด์ทำเหมือนกันหมด = convention ที่ COMMENT ตามไม่ทัน การ "แก้ให้ตรง COMMENT" คือการทำพัง · แจ้ง operator ให้อัปเดต COMMENT แทน |
| L28 | **`seo_website_page_master` มีคีย์ 2 ตัวที่เรียกว่า "fingerprint" ได้ทั้งคู่ และตารางบริวารตั้งชื่อคอลัมน์ว่า `page_fp` เฉย ๆ — ใส่ผิดตัวแล้วแถวหลุดเงียบ เพราะไม่มี FK จริงบังคับ** | Smile Scape (Wave 16y) รัน orphan gate เจอ `seo_page_citations` 3 แถวของ **vth-biodent** ผูก `page_fp = 'page_942B5270A0314DAB'` (= คอลัมน์ `fingerprint` ฟอร์แมต `page_{ULID16}`) แทน `'vth-4.4.4'` (= `page_fingerprint`) · แถวสร้างวันเดียวกับที่ตรวจเจอ แปลว่าเซสชันที่กำลังทำแบรนด์นั้นเพิ่งพลาด และไม่มีอะไรเตือน — หน้ายังอยู่ครบ citation ยังอยู่ครบ แต่ join ไม่ติด หน้าจึงกลายเป็น "ไม่มีหลักฐาน" ทั้งที่ผูกไว้แล้ว · นับทั้งฐาน: `seo_page_citations` 6,306/6,309 และ `seo_editorial_reviews` 2,095/2,095 ใช้ `page_fingerprint` = **นั่นคือมาตรฐานที่ใช้จริง** ส่วน 3 แถวนั้นคือของผิด ไม่ใช่ของถูกที่มาก่อนกาล · น่าสับสนเป็นพิเศษเพราะ COMMENT ของ `fingerprint` เขียนว่า *"IMMUTABLE machine ID … Do NOT treat page_fingerprint as stable identity; use fingerprint for that"* ซึ่งอ่านแล้วชวนให้เอา `fingerprint` ไปผูก | **คีย์ผูกของตารางบริวารทุกตัวคือ `page_fingerprint`** (`{brand_prefix}-{sitemap_node_id}`) — `seo_page_citations.page_fp` · `seo_editorial_reviews.page_fp` · `seo_page_internal_links.from_page_fp/to_page_fp` · `parent_page_fp` · `planned_outbound_fps` · ส่วน `fingerprint` (`page_{ULID16}`) ใช้เป็น identity ที่ไม่เปลี่ยนสำหรับ audit / อ้างข้ามเซสชัน **เท่านั้น ห้ามเอาไปผูก** · เหตุผลที่ต้องเป็นแบบนี้: §13.3 renumber ออกแบบมาให้ไล่อัปเดต 7 จุดที่ถือ `page_fingerprint` อยู่แล้ว ถ้าบางแถวแอบใช้ `fingerprint` มันจะรอด renumber ไปเงียบ ๆ แล้วไปโผล่เป็น orphan ทีหลัง · **เกตบังคับก่อนปิดงานทุกรอบ:** `select count(*) from <satellite> s where not exists (select 1 from seo_website_page_master p where p.page_fingerprint = s.page_fp)` ต้องเป็น **0 ทุกแบรนด์ ไม่ใช่แค่แบรนด์ตัวเอง** (ตารางร่วม แบรนด์อื่นพังก็เห็นจากที่นี่) · ถ้าเจอ **ให้แก้ด้วยการเขียนคีย์ใหม่ ห้ามลบแถว** — ของที่ผูกไว้ถูกต้องอยู่แล้ว ผิดแค่รูปคีย์ · **✅ 2026-08-16 แก้ที่รากแล้ว: ใส่ FK จริง 7 ตัว** (migration `add_real_fks_to_page_master`) ทุกตัว `ON UPDATE CASCADE` · `ON DELETE` = CASCADE สำหรับแถวลูกแท้ (citations · reviews · links) และ **SET NULL** สำหรับแถวที่มีชีวิตของตัวเอง (`parent_page_fp` · `ad_landing_page_fp` · `optimized_for_page_fp`) — ⚠️ `parent_page_fp` ห้ามเป็น CASCADE เด็ดขาด ลบ hub เดียวจะลบทั้งกิ่ง · **บทเรียนซ้อน: คำถามที่ควรถามตั้งแต่แรกคือ "ทำไมไม่เป็น FK" ไม่ใช่ "จะเขียนเกตจับ orphan ยังไง"** — ในตารางเดียวกันนั้น `citation_fp` มี FK ครบมาตลอด มีแต่ฝั่ง `page_fp` ที่ไม่มี = ช่องโหว่ ไม่ใช่การตัดสินใจ · เหตุผลเชิงประวัติที่ทำให้เลี่ยง FK คือ `page_fingerprint` เปลี่ยนค่าตอน renumber ซึ่ง **`ON UPDATE CASCADE` แก้ได้และทำให้ §13.3 ดีขึ้น** (เขียนที่เดียว บริวารตามเอง เหลือไล่มือแค่ `planned_outbound_fps` เพราะ `text[]` ทำ FK กับสมาชิกใน array ไม่ได้) · **ผลที่ ETL ทุกแบรนด์ต้องรู้: ต้อง insert หน้าก่อนบริวารเสมอ ไม่งั้น `foreign_key_violation`** — พังดัง ๆ ดีกว่าหลุดเงียบ |
| L29 | **พูล citation เล็กเกินจำนวนหน้า → citation ถูกละเลงข้ามหัวข้อ และเกตเดิมจับไม่ได้เลย เพราะไม่มีข้อไหนถามว่า "เปเปอร์นี้พูดเรื่องเดียวกับหน้านี้จริงไหม"** | Smile Scape (Wave 16x/16y) มี citation 257 ชิ้นต่อ 728 หน้า → **170/257 ถูกผูกข้าม 4+ entity · 125 ข้าม 6+ · เฉลี่ยชิ้นละ 8.5 หน้า สูงสุด 30** · ของจริงที่หลุด: *Loading Protocols for Single-Implant Crowns* ไปนั่งบนหน้า **อุดฟัน · วีเนียร์ · ขูดหินปูน · ครอบฟันทอง** · *Screening programmes for early detection of oral cancer* ไปนั่งบน **3Shape TRIOS · CBCT · Airflow · CAD/CAM** · *implant-supported fixed prostheses* ไปนั่งบน **Pregnancy Gingivitis** · G1–G11 ผ่านหมดทุกข้อ เพราะทุกแถวมี PMID ครบ tier ตรง ไม่ retracted ไม่ซ้ำ | **เพิ่ม G13** — ตรวจความตรงหัวข้อด้วย **บทคัดย่อ + MeSH จริง** ดึงสดจาก NCBI E-utilities **ไม่ใช่ชื่อเรื่อง** · ชั้นบทคัดย่อไม่ใช่ของฟุ่มเฟือย มันช่วยของถูกไว้ได้จริง: *Complications of third molar surgery* ผ่านสำหรับหน้า Dry Socket และ *Coronectomy in Lower Third Molar Surgery* ผ่านสำหรับหน้าถอนฟัน ทั้งที่ชั้นชื่อเรื่องแฟล็กว่าไม่ผ่านทั้งคู่ · ทำตัวเทียบ **entity → ศัพท์คลินิก** แล้ว **ตั้งให้ผ่านง่ายไว้ก่อน** (ตัดผิดแพงกว่าปล่อยผ่าน) · ⚠️ กับดักซ้อน: ตัวเทียบที่แคบเกินจะตัดของถูกทิ้ง — หน้าตระกูลรากเทียมอ้างเปเปอร์ osseointegration/surface/survival ทั่วไปได้ตามธรรมเนียมคลินิก การบังคับให้เจอคำว่า `all-on-4` เท่านั้นทำให้ยอดตัดพองจาก 244 เป็น 470 · **ถอดของผิดออกแล้วต้องติดธง `citation-gap` ไว้ ไม่ใช่ปล่อยเงียบ** — หน้าที่เหลือหลักฐาน < ขั้นต่ำคือหนี้ที่เปิดไว้ ไม่ใช่งานที่เสร็จ · และ **ธงต้องไม่นับเทมเพลตที่ไม่ต้องมีหลักฐานคลินิก** (T9 โปรไฟล์แพทย์ · T10/T18 สาขา · T11 องค์กร · T12 FAQ hub · T13 ราคา · T16 ประกัน · T19 โปรโมชัน) ไม่งั้นตัวเลขหนี้พองเกินจริง (268 → 214) |
| L30 | **🔴 FK จับ *เขียน* ผิดคีย์ได้ แต่จับ *อ่าน* ผิดคีย์ไม่ได้ — query ที่คืน 0 เพราะคีย์ผิด หน้าตาเหมือน "ไม่มีของเดิม" เป๊ะ ๆ แล้วขั้นตอนถัดไปก็ no-op ไปเงียบ ๆ** | vth-biodent (2026-08-16) รายงานกลับหลัง broadcast L28: ขั้นตอน *"ปลด citation เดิมก่อนผูกใหม่"* ค้นด้วย ULID (คีย์ผิด) เลยได้ 0 แถว แล้วสรุปว่า "หน้านี้ไม่มี citation เดิม" — ความจริงหน้า `vth-4.4.4` มี backbone sweep ค้างอยู่ **3 แถวที่เป็นคนละการรักษาเลย** (myofunctional therapy · แนวทาง AASM/AADSM เครื่องมือในช่องปาก · MMA meta-analysis อยู่บนหน้าเลเซอร์) · **ผลกระทบร้ายกว่าตัวคีย์ที่ผิดเอง** เพราะคีย์ผิดคือ 3 แถวที่เห็นได้ด้วย orphan gate แต่ unbind ที่ no-op คือของผิดที่ยัง active อยู่บนเว็บโดยไม่มีเกตไหนเห็น · ตัว `added_by_fp` ก็ค้าง ULID ด้วย และ SQL repair ที่แก้แค่ `page_fp` ไม่ครอบ — ⚠️ คอลัมน์นั้นไม่ใช่คีย์หน้าเสมอไป (ของ vth 144 แถวเป็น `page_fingerprint` แต่ 92 แถวเป็น **ชื่อผู้กระทำ** เช่น `codex-content-etl` ซึ่งถูกอยู่แล้ว ห้ามไปแก้) | **ทุก query ที่ผลลัพธ์ 0 จะทำให้ข้ามงาน ต้องพิสูจน์ว่า 0 นั้นจริง ไม่ใช่ 0 เพราะถามผิด** — วิธีที่ถูกคือ **ตั้ง baseline ที่คาดหวังไว้ก่อนถาม**: ถ้าเชื่อว่า "หน้านี้ไม่มี citation เดิม" ให้ยิงอีกช็อตที่ไม่ผูกกับคีย์ที่สงสัย (นับจากฝั่งหน้า / นับรวมทั้งแบรนด์ / ถามด้วยคีย์อีกตัว) แล้วเทียบกัน ถ้าสองช็อตไม่ตรงกันแปลว่าคีย์พัง · **หลักการทั่วไป: เกตที่ผ่านได้ทั้งจาก "สะอาดจริง" และจาก "ไม่ได้ตรวจ" ไม่ใช่เกต** · Smile Scape โดนแบบเดียวกันจากอีกทาง — รายงานว่า "ออดิต citation เสร็จ" ทั้งที่ตัวเทียบ entity ครอบแค่ 78/155 entity เหลือ **188 การผูกใน 44 entity ที่ไม่เคยถูกตรวจเลย** (ปิดใน Wave 16ac: ครอบ 1,620/1,623 ตัดเพิ่ม 85) · และตอนทำตัวเทียบชุดที่ 3 เกือบพลาดซ้ำอีก เพราะตั้งคำกว้างเกิน (`age` ไปแมตช์ `average`/`percentage`) จนอนุมัติเกือบทุกเปเปอร์ = เกตที่ไม่ได้ตรวจอะไรเลย · **เวลารายงานความคืบหน้า ให้บอก "ตรวจไปกี่ชิ้นจากทั้งหมดกี่ชิ้น" เสมอ ไม่ใช่แค่ "เจอปัญหากี่ชิ้น"** |


**สรุปหลักการเดียวที่ครอบทุกข้อ:** *เติมหน้าให้ครบไม่ใช่เป้าหมาย — เป้าหมายคือทุกคำที่ลงไปต้องมีเหตุผลที่ตรวจสอบย้อนหลังได้*


---

## 12. Change control

- แก้ SOP นี้ = bump version + บันทึกเหตุผลท้ายไฟล์
- ข้อ 4 (B1, B9) และข้อ 8 (compliance) แก้ไม่ได้โดยฝ่าย SEO ต้องผ่านผู้รับอนุญาตสถานพยาบาล
- เนื้อหาการแพทย์บนหน้าที่เกิดจาก SOP นี้ยังต้องผ่าน sign-off ของ ทพ.ดร. อมรพงษ์ ตามกระบวนการเดิม (`seo_editorial_reviews`)

---

## ภาคผนวก — ลำดับงานหลัง SOP อนุมัติ

0. tag `primary_entity_fp` ให้คีย์ **196 ตัว**ที่ค้าง + หน้า **57 หน้า**ที่ไม่มี entity (VTH, active) *(corrected 2026-08-24 against live schema — เดิมเขียน 230 / 63)*
1. สร้าง view `entity → keywords` (volume/intent/SERP/KD) = คลังตั้งต้น
2. รัน rule engine ตาม SOP นี้ → เขียนผลลง staging ก่อน
3. รัน QA gates ข้อ 10 → แก้ → merge
4. ส่วนเกิน → ข้อเสนอหน้าใหม่ตามข้อ 9
5. §9 Local — **ไม่ต้อง pull ใหม่** ตรวจแล้วคลังมีคีย์ near-me อยู่ **23 ตัว** (ขูดหินปูน ใกล้ฉัน 4,808 ฯลฯ) และ **assign เป็น primary ไปแล้ว 7 ตัว** ลงหน้า 9.x ทั้งหมด *(corrected 2026-08-24 against live schema — เดิมเขียน 27 ตัว / assign 3 ตัวและ 2 ใน 3 ผิดหน้า ซึ่งแก้ไปแล้ว)* — ปัญหาอยู่ที่การ assign ไม่ใช่ supply
   เพิ่มจาก DFS pull 2026-07-27: `ทําฟัน ใกล้ฉัน` (18,100 · KD 1) — head term ของ near-me ที่ไม่มีในคลังเดิม

## 13. โครงสร้างและลำดับเนื้อหาในไซต์แมป (Sitemap Structure & Reading Flow)

> เพิ่ม 2026-07-28 หลังรอบ Reading-Flow Pass ของ VTH BioDent (735 หน้า)
> ทุกครั้งที่ **เพิ่ม/ลบ/ย้ายหน้า** ต้องกลับมาตรวจข้อนี้ ไม่ใช่แค่ตอนวางผังครั้งแรก

### 13.1 กฎโครงสร้าง

| # | กฎ | เหตุผล |
|---|---|---|
| S1 | **ยึด 8-section universal** (Bible §4.2) · ต้องการหมวดใหม่ให้ทำเป็น **sub-section** (`8.10`, `6.10`) ไม่ใช่ section ใหม่ | ทุก section ที่เพิ่มคือข้อยกเว้นที่แบรนด์อื่นจะลอกตาม · §9 Local เป็นข้อยกเว้นเดียวที่รับได้ (programmatic + `nav: no`) |
| S2 | **`sitemap_node_id` ≠ URL** · slug/URL เป็นอิสระจากเลข node | ย้ายหมวดได้โดยไม่ต้อง redirect · แต่ต้อง remap `page_fingerprint` + ลิงก์ให้ครบ |
| S3 | **1 sub-section = 1 ชั้นเนื้อหา** ห้ามปน pillar กับ how-to ในหัวเดียวกัน | เจอจริง: §6.1 มี Complete Guide 1,500–2,500 คำ ปนกับ how-to 1,200 คำ → แยกเป็น §6.10 |
| S4 | **ชื่อหน้าห้ามซ้ำทั้งไซต์** แม้ slug ต่างกัน | เจอจริง: `Follow-up & Outcomes` 3 หน้า · `เหงือกอักเสบ` 2 หน้า — ผู้อ่านและ Google แยกไม่ออก |
| S5 | **หน้าโครงสร้างต้องมี `cluster_id`** (แทน entity ที่ไม่บังคับตาม P2) | เจอจริง: 63 หน้า hub/index ไม่มีทั้ง entity และ cluster = หลุดจากทุก query ที่จัดกลุ่ม |

### 13.2 หลักการเรียงลำดับในแต่ละหมวด

เรียงตาม **เส้นทางของผู้อ่าน** ไม่ใช่ลำดับที่สร้างหน้า

| ประเภทหมวด | หลักการเรียง | ตัวอย่าง (VTH) |
|---|---|---|
| **อาการ / โรค** (§5) | จัดกลุ่มตามอวัยวะ/ระบบ → ในกลุ่มไล่จาก **พบบ่อย & กลับคืนได้ → รุนแรง → เชื่อมโยงโรคระบบ** | §5.3: เหงือก(1–9) → ฟัน(10–17) → เนื้อเยื่ออ่อน(18–22) → ระบบร่างกาย(23–26) |
| **เด็ก / กลุ่มวัย** | ตาม **ช่วงวัย/พัฒนาการ** | §5.6: พัฒนาการฟัน(1–7) → ทางเดินหายใจ(8–15) → พฤติกรรม(16–21) → ผลต่อการเรียน(22–25) |
| **บริการ** (§3) | hub → ชนิด/ทางเลือก → ขั้นตอน → หลังทำ | ฟันปลอม: hub → ถอดได้ → ทั้งปาก → ยืดหยุ่น → โครงโลหะ |
| **ความรู้** (§6) | ตาม **คลัสเตอร์หัวข้อ** ไม่ใช่ตามวันที่สร้าง | §6.10: ปริทันต์ → ความงาม → จัดฟัน → ทางเดินหายใจ → ฉุกเฉิน |
| **ติดต่อ/สนับสนุน** (§8) | ตาม **customer journey** | ทำไมที่นี่ → ประเมินตัวเอง → จะเจออะไร → ราคา → สิทธิ → จอง → ติดต่อ → สาขา |

**ห้าม**: วางหน้าใหม่ต่อท้ายเลขล่าสุดโดยไม่ดู flow — เจอจริง `ฟันขึ้น` (พื้นฐานที่สุด อายุ 6 เดือน) ไปอยู่ 5.6.24 ท้ายสุดหลังเรื่องสมาธิสั้น

### 13.3 วิธี renumber ที่ปลอดภัย (บังคับ)

`page_fingerprint` เป็น FK ของ `parent_page_fp` และ `internal_links` 2 ทิศ → renumber ตรง ๆ จะชน unique key

```
PHASE 1  page_fingerprint → 'zzz-<new_node>'   (+ parent_page_fp, links.from, links.to)
PHASE 2  'zzz-<new_node>' → 'vth-<new_node>'   (+ sitemap_node_id)
```

**ต้องอัปเดต 7 จุดทุกครั้ง** — 🔴 *(corrected 2026-08-24 against live schema — ตั้งแต่ migration `add_real_fks_to_page_master` (2026-08-16) จุด 1–6 มี **FK จริงพร้อม `ON UPDATE CASCADE`** แล้ว: `seo_page_citations.page_fp` · `seo_editorial_reviews.page_fp` · `seo_page_internal_links.from_page_fp/to_page_fp` · `parent_page_fp` (self, ON DELETE SET NULL) — บริวารตามเองตอน rename · **เหลือจุดเดียวที่ยังไม่มี FK คุมคือจุด 7 `planned_outbound_fps`** เพราะเป็น `text[]` ทำ FK กับสมาชิกใน array ไม่ได้ · ตรวจ 2026-08-24: orphan ของ `seo_page_citations` = 0 และ `seo_editorial_reviews` = 0)*:

| # | จุด | เจอพลาดจริง |
|---|---|---|
| 1 | `page_fingerprint` | |
| 2 | `parent_page_fp` | |
| 3 | `internal_links.from_page_fp` | |
| 4 | `internal_links.to_page_fp` | |
| 5 | **`seo_page_citations.page_fp`** | Deezy 26 แถวลอย (2026-08-06) |
| 6 | **`seo_editorial_reviews.page_fp`** | Deezy 11 แถวลอย (2026-08-06) |
| 7 | **`planned_outbound_fps`** (array) | VTH 7 ตัวยังชี้ fingerprint ก่อน rename (2026-08-07) |

`fingerprint` (`page_XXXX`) **ห้ามแตะ** — เป็น canonical ID ตาม DR-008 และมี trigger ป้องกันอยู่

> ⚠️ **กับดัก DR-008 สองคอลัมน์** — ตอนเขียน binding ต้องใช้ `page_fingerprint` (`vth-6.1.3`) เสมอ ไม่ใช่ `fingerprint` (`page_XXXX`) เจอมาแล้วสามรอบ รอบล่าสุดอยู่ที่ `seo_doctor_assignments.author_fp` ซึ่งเก็บ slug แทน `auth_XXXX` → ทุกคอลัมน์ที่ลงท้าย `_fp` และไม่มี FK ต้องอยู่ในชุดตรวจ

**ตรวจหลัง renumber (ต้องได้ 0 ทุกข้อ):**

```sql
-- temp เหลือค้าง
select count(*) from seo_website_page_master where page_fingerprint like 'zzz-%';
-- fp ไม่ตรง node
select count(*) from seo_website_page_master where brand_id=:b and page_fingerprint <> :prefix||sitemap_node_id;
-- ลิงก์/parent ชี้หน้าที่ไม่มีจริง
select count(*) from seo_page_internal_links l where not exists (select 1 from seo_website_page_master p where p.page_fingerprint=l.from_page_fp);
select count(*) from seo_website_page_master p where p.parent_page_fp is not null and not exists (select 1 from seo_website_page_master q where q.page_fingerprint=p.parent_page_fp);
-- ซ้ำ / orphan
select count(*) from (select page_fingerprint from seo_website_page_master where brand_id=:b group by 1 having count(*)>1) x;
select count(*) from seo_website_page_master p where p.brand_id=:b and not exists (select 1 from seo_page_internal_links l where l.to_page_fp=p.page_fingerprint);

-- binding 3 จุดที่ไม่มี FK (จุด 5–7)
select count(*) from seo_page_citations c   where not exists (select 1 from seo_website_page_master p where p.page_fingerprint=c.page_fp);
select count(*) from seo_editorial_reviews r where not exists (select 1 from seo_website_page_master p where p.page_fingerprint=r.page_fp);
select count(*) from seo_website_page_master p
  where p.brand_id=:b and exists (select 1 from unnest(p.planned_outbound_fps) x
                                  where not exists (select 1 from seo_website_page_master q where q.page_fingerprint=x));

-- DR-049 · ลิงก์ที่แตะหน้า Merged ต้องถูก deprecate ทั้งสองทิศ (ถามทิศเดียวไม่พอ)
select count(*) from seo_page_internal_links l join seo_website_page_master p
  on p.page_fingerprint=l.to_page_fp   where p.status='Merged' and l.status<>'deprecated';
select count(*) from seo_page_internal_links l join seo_website_page_master p
  on p.page_fingerprint=l.from_page_fp where p.status='Merged' and l.status<>'deprecated';
```

**หลัง export ต้องเช็คตัวเลขด้วย:** จำนวน from-page ใน `internal-links.json` ต้อง **เท่ากับ** จำนวนหน้า active พอดี ถ้ามากกว่า แปลว่ามีหน้าที่ยุบไปแล้วยังส่งลิงก์อยู่ (DR-049 — VTH เจอ 968 เส้น)

### 13.4 คุมลำดับการอ่านโดยไม่ renumber

`link_priority` มี CHECK **1–10** → เก็บลำดับ 1–26 ไม่ได้
ให้ใช้ **priority ระดับกลุ่ม** + `section_context` เป็นชื่อกลุ่ม + ลำดับย่อยใน `surrounding_text_snippet`

```
group_gum  pri 9  ·  group_tooth pri 7  ·  group_soft_tissue pri 5  ·  group_systemic pri 3
surrounding_text_snippet = 'reading-order group_gum #3'
```

ใช้เมื่อ: ต้องการ flow การอ่านแต่ไม่คุ้มที่จะ renumber (หมวดใหญ่ / หน้าเผยแพร่แล้ว)

### 13.5 Checklist ทุกครั้งที่เพิ่มหรือย้ายหน้า

1. `select max(...)` เลข node จาก **DB** ไม่ใช่จากเอกสาร (เลขในเอกสารตกรุ่นได้)
2. หน้าใหม่ตกอยู่ในตำแหน่งที่ flow ถูกต้องไหม — ถ้าไม่ ให้ renumber ตาม §13.3 ทันที **ก่อนเขียน content**
3. ชื่อหน้าซ้ำกับของเดิมไหม (S4)
4. มี `cluster_id` ไหม (S5)
5. ลิงก์เข้า/ออกครบ `required_min_inbound`/`outbound` · ไม่มี orphan
6. รัน QA gates §10 ใหม่ทั้งชุด

---
