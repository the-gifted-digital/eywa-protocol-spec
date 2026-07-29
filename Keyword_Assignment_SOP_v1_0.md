# 📌 EYWA Protocol — Keyword Assignment SOP

> **เวอร์ชัน:** 1.1 (universal) · **ประกาศใช้:** 2026-07-28 · **สถานะ:** 🔒 Locked
> **v1.2:** เพิ่มบทเรียน L17–L19 (convention ของ seo_title/meta_description · baseline vs final · การคุมถ้อยคำ meta บนหน้า legal_review)
> **v1.1:** เพิ่ม §8.5 ตำแหน่งหมวดราคาในผัง · §13 โครงสร้าง & ลำดับเนื้อหา + วิธี renumber · บทเรียน L13–L16
> **ขอบเขต:** **UNIVERSAL** — ทุกแบรนด์ที่ใช้ `seo_website_page_master` + `seo_x_ads_keywords_contextual_master`
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
ให้ผูก `cluster_id` แทน + ตั้ง `intent_source_tier='brand'` — VTH มี 63 หน้าในกลุ่มนี้ (เช่น 5.1 Sleep & Airway, 6.3.x Glossary, 8.x Contact, 9.1 Local hub) การบังคับ tag entity จะได้ mapping มั่ว

หน้าเชิงเนื้อหาที่ยังไม่ผ่าน P2 → **ปล่อย `target_keyword_fp` ว่างไว้** ห้าม assign มั่ว

---

## 3. Relevance ladder (เกณฑ์ hard gate — ไม่ใช่คะแนน)

| Tier | เงื่อนไข | ใช้ได้ไหม |
|---|---|---|
| **R1** | `keyword.primary_entity_fp = page.primary_entity_fp` | ✅ ใช้ก่อนเสมอ |
| **R2** | entity ของคีย์เป็น parent/child ของ entity หน้า (`seo_entity_relationships`: is_a / part_of / subtype_of) | ✅ ใช้เมื่อ R1 หมด |
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

### 6.4 ข้อจำกัดเชิงโครงสร้าง (บังคับที่ DB)

1. **1 primary : 1 หน้า ทั่วทั้งแบรนด์** — unique index บน `(brand_id, kw_norm(keyword))`
2. คีย์ที่เป็น primary ของหน้าใดแล้ว **ห้ามเป็น semantic ของหน้าอื่น**
3. คีย์เดียวกันเป็น semantic ได้หลายหน้า — แต่ไม่เกิน 3 หน้า
4. หน้าที่ยังไม่มี primary ต้องมี `flag_review` เสมอ (ไม่มีสถานะ "ว่างเงียบ")

---

## 7. หน้า concept / brand-nav (volume = 0)

หน้าเชิงคอนเซปต์ (§2 ปรัชญา, §3.1–3.4 signature MBM/ABM/BFB, §4.9, §6.1.1) **กำหนด target keyword ที่ volume 0 ได้** — แต่ต้อง:

1. ตั้ง `keywords.keyword_use_as = 'brand_nav'`
2. ตั้ง `page_master.intent_source_tier = 'brand'`
3. **ไม่นับหน้าเหล่านี้ใน KPI organic ranking/traffic** — วัดด้วย branded search + assisted conversion แทน

ปัจจุบัน VTH มี 26 หน้าในกลุ่มนี้ ถ้าไม่ติดธง รายงานจะอ่านเหมือนหน้าพัง 26 หน้า

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
- primary = `อัตราค่าบริการ ทันตกรรม` (50/mo) ตั้ง `intent_source_tier='brand'` — **ไม่นับใน KPI organic ranking**
- มูลค่า organic จริงของหน้านี้มาจาก **section ระดับบริการ** (passage/anchor) ไม่ใช่จากหัวหน้า

### 8.3 ใครเป็นเจ้าของคีย์ `X ราคา` — ตัดสินด้วย SERP รายคำ

```
overlap = |urls(X) ∩ urls(X ราคา)| / N      โดย N = min(จำนวน url ที่เก็บได้ของทั้งสองคำ)
```

**แหล่งข้อมูล:** `seo_x_ads_keyword_serp_competitors.competitor_url_list` (12,157 แถว) — SERP ไม่ผูกกับแบรนด์ ใช้แถวของแบรนด์พี่น้อง (Deezy Dental 3,568 คีย์) เทียบได้เลยเมื่อ keyword ตรงกัน
**ความครอบคลุมปัจจุบัน:** คีย์ VTH 260/1,694 ตัว (15%) มี SERP แล้ว · ในจำนวน target ที่ assign ไปแล้ว 73/230 ตัวมี SERP
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

> ยังไม่มี SERP ของ `ตัด เหงือก ราคา` และ `เคลือบฟลูออไรด์` (คำเปล่า) ในตาราง — ต้อง pull ก่อนยืนยัน 2 แถวล่าง

### 8.4 ข้อบังคับเชิงเทคนิค

1. **Single source of truth**: ราคาทั้งหมดเก็บที่เดียว (DB หรือ `pricing.json`) — หน้ารวม render ทั้งชุด · หน้าบริการ filter ตาม slug **ห้ามพิมพ์ตัวเลขซ้ำสองที่**
2. **Schema**: หน้ารวม = `OfferCatalog` (itemListElement = Service + priceSpecification) · หน้าบริการ = `Service` + `offers` ค่าต้องตรงกับหน้ารวมเป๊ะ
3. **Anchor**: heading จริง + `id` = slug ของบริการ · URL pattern `/pricing/#<slug>` เพื่อ migrate เป็น `/pricing/<slug>/` ได้ภายหลังโดยไม่รื้อ
4. **§9 Local**: หน้าสาขาไม่ทำตารางราคาซ้ำ ให้ลิงก์เข้าหน้ารวม (ยกเว้นราคาต่างกันจริงตามสาขา)
5. แสดง **"เริ่มต้น X" + ช่วงราคา + เงื่อนไข** แทนราคาตายตัวรายเคส

**ข้อมูลปัจจุบัน (VTH):** คีย์กลุ่มราคา 107 ตัว มี v ≥ 500 เพียง 8 ตัว · มี 34 คีย์ราคาเป็น primary ของหน้า §3 อยู่แล้ว — ชุด 34 ตัวนี้เข้า audit ก่อนเป็นลำดับแรก
คีย์ราคา 106 ตัวมี `primary_entity_fp` แล้ว 95 ตัว (ขาด 11) — **ไม่ใช่ตัวบล็อก** ส่วนคอลัมน์ `primary_entity_name` เป็น null ทั้งตาราง (denormalized ไม่เคย backfill) ให้ backfill ใน step 0 ส่วน C3

> ⚠️ **Compliance:** การโฆษณาราคาสถานพยาบาลอยู่ภายใต้ พ.ร.บ.สถานพยาบาล พ.ศ. 2541 ม.38 (โฆษณาสถานพยาบาลต้องได้รับอนุมัติจากผู้อนุญาต) — ครอบคลุมทั้งหน้ารวม **และ price block ที่ฝังในหน้าบริการ** ต้องยื่นในคำขอเดียวกัน ตั้ง `legal_review_required = true` ทุกหน้าที่แสดงราคา

---


### 8.5 หมวดราคาอยู่ตรงไหนในผังไซต์

**ให้อยู่ใต้ §8 (Contact & Support) เป็น `8.10` + ลูก `8.10.x` — ไม่ตั้งเป็น section ใหม่**

| เหตุผล | รายละเอียด |
|---|---|
| รักษาโครง 8-section | Bible §4.2 กำหนด 8-section universal · การเพิ่ม section ใหม่ให้หมวดราคา (7–10 หน้า) ทำให้โครงหลุดมาตรฐานและแบรนด์อื่นลอกตาม |
| อยู่กลุ่มเดียวกับหน้าสิทธิ/เบิกจ่าย | "เท่าไหร่ · จ่ายยังไง · เบิกได้ไหม" เป็น job เดียวกันของคนไข้ ต้องลิงก์ถึงกันสองทาง |
| §8 คือ utility / pre-visit cluster | อยู่ร่วมกับ First Visit · Self-Assessment · International Patients ได้ตามธรรมชาติ |
| ระดับความสำคัญตรงกับข้อมูล | head term ของหมวด (`อัตราค่าบริการ ทันตกรรม` ระดับ 50/mo ในตลาดไทย) ไม่ใช่ pillar — มูลค่าอยู่ที่ section ระดับบริการ |

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

ตอนนี้ 9.8–9.15 ถือคำ near-me อยู่ (`ขูดหินปูน ใกล้ฉัน` → 9.10 · `ฟอกสีฟัน ใกล้ฉัน` → 9.9 ฯลฯ) เพราะยังไม่มีคีย์ geo ของ พระราม 3 / Park 11 ในคลัง (ยิง DFS แล้ว `จัดฟัน พระราม 3` / `หมอฟัน พระราม 3` ไม่มีข้อมูล)

> ⚠️ **Migration trigger:** เมื่อเปิด**สาขาที่ 3** ให้ย้ายคำ near-me ทั้งหมดขึ้นไปที่ 9.1 hub ทันที แล้วให้หน้าสาขาทั้งหมดถือคีย์ geo แทน — บันทึกไว้ใน `note_brief` ของหน้า 9.8–9.15 แล้ว

---

## 9. เกณฑ์สร้างหน้าใหม่ (คีย์เหลือจากคลัง)

เสนอหน้าใหม่เมื่อครบทั้ง 3 ข้อ:

1. entity นั้นมีคีย์เหลือ (ยังไม่ถูกใช้เป็น primary/semantic) **≥ 5 ตัว**
2. volume รวมของคีย์เหลือ **≥ 300/เดือน**
3. SERP overlap กับหน้าเดิมของ entity **< 0.6**

**backlog ที่คำนวณได้แล้วจากข้อมูลจริง (VTH — 36 entity ผ่านเกณฑ์ข้อ 1):**

| entity | หน้าปัจจุบัน | คีย์ในคลัง | volume รวม |
|---|--:|--:|--:|
| Dental Scaling & Cleaning | 1 | 52 | 49,172 |
| Gingival Swelling | 1 | 45 | 27,781 |
| Enamel Remineralization | 1 | 37 | 10,680 |
| Snoring | 1 | 51 | 9,803 |
| Tooth Discoloration | 1 | 35 | 9,702 |
| Dental Filling | 1 | 59 | 8,650 |
| Loose Tooth | 1 | 25 | 8,137 |
| Toothache | 1 | 68 | 7,296 |

หน้าใหม่ต้องระบุ intent ที่ **ต่างจาก pillar เดิมชัดเจน** ในช่อง `page_purpose` ก่อนอนุมัติ

---

## 10. QA gates (รันทุกครั้งหลัง assign — ต้องผ่านทั้ง 8 ข้อ)

| # | เช็ค | เกณฑ์ผ่าน |
|---|---|---|
| Q1 | primary ซ้ำหลังnormalize | 0 แถว |
| Q2 | primary ที่ติด blacklist ข้อ 4 (B1/B7/B9) | 0 แถว |
| Q3 | intent ขัด matrix ข้อ 5 | 0 แถว |
| Q4 | หน้า §9 ที่ primary ไม่มี geo/near-me | 0 แถว |
| Q5 | หน้าลูกถือคีย์กว้างกว่าหน้าแม่ | 0 แถว |
| Q6 | primary v=0 ที่ไม่ได้ติดธง `brand_nav` | 0 แถว |
| Q7 | คีย์ที่เป็น primary แล้วไปโผล่เป็น semantic ที่อื่น | 0 แถว |
| Q8 | entity เดียวกันมี primary >1 หน้า โดย SERP overlap ≥0.6 | 0 แถว (ไม่งั้น = cannibalization) |

```sql
-- Q1
with p as (
  select brand_id, sitemap_node_id, kw_norm(k.keyword) n
  from seo_website_page_master pm
  join seo_x_ads_keywords_contextual_master k on k.fingerprint = pm.target_keyword_fp
)
select brand_id, n, count(*), string_agg(sitemap_node_id, ',')
from p group by 1, 2 having count(*) > 1;
```

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
| L11 | **constraint ของ schema ไม่ตรงกับที่คิด** | `intent_source_tier` รับแค่ `paa/derived/template_only` — ธง "ไม่นับ KPI organic" ต้องใช้ `page_purpose='utility'` แทน · `compliance_max_tier` เป็น generated column | อ่าน `pg_constraint` ก่อนออกแบบ field mapping |
| L12 | **DB มี constraint ที่ช่วยเราอยู่แล้ว** | insert หน้าราคาไม่ผ่านเพราะคีย์ยังผูกกับหน้าเดิม — 1 keyword : 1 page ถูกบังคับที่ DB จริง | อย่ามองว่าเป็น error ให้มองว่าเป็น gate ที่ทำงาน แล้วปลดคีย์เดิมก่อน |
| L13 | **`kw_norm()` จับคำไทยที่ไม่เว้นวรรคไม่ได้** | `ฟันปลอม ทั้งปาก` กับ `ฟันปลอมทั้งปาก` เป็นคำเดียวกันในสายตาผู้ค้น แต่ normalize ออกมาคนละค่า (token เดียว vs สอง token) → QA Q1 ไม่จับ | เสริม gate: เทียบเวอร์ชัน **ลบช่องว่างทั้งหมด** (`replace(kw,' ','')`) ควบคู่กับ token-sort · เจอคู่แบบนี้ให้ตัวหนึ่งเป็น semantic |
| L14 | **QA gate ที่ผูกกับเลข section จะพังเมื่อย้ายหมวด** | ย้ายหมวดราคา §10 → §8.10 แล้ว gate Q4c (`section <> '10'`) รายงาน false positive 6 หน้า | เขียน gate ให้ผูกกับ **คุณสมบัติของหน้า** (slug prefix / page_purpose) ไม่ใช่เลข section |
| L15 | **renumber node ต้องทำ 2-phase** | สลับเลขในหมวด (5.3.22 → 5.3.1 ขณะที่ 5.3.1 ยังอยู่) ทำตรง ๆ จะชน unique key ทันที | เขียน `page_fingerprint` เป็นค่าชั่วคราว (`zzz-<new>`) ก่อน แล้วค่อยลงค่าจริง · อัปเดต 4 จุดเสมอ: `page_fingerprint` · `parent_page_fp` · `links.from` · `links.to` |
| L16 | **`link_priority` มี CHECK 1–10** | จะใช้เก็บลำดับการอ่าน 1–26 ไม่ได้ | ใช้ priority ระดับ**กลุ่ม** + เก็บลำดับย่อยใน `section_context` / `surrounding_text_snippet` |
| L17 | **title/meta ของหน้าใหม่ต้องเดินตาม convention ของหน้าเดิม ไม่ใช่ best practice ทั่วไป** | จะเขียนตามสูตรสากล (ใส่ brand suffix, title ≤60 ตัวอักษรละติน) แต่ 698 หน้าเดิมของแบรนด์ไม่มี suffix เลย (3/698) และวัดเป็นตัวอักษรไทย | ก่อนเขียน ให้ query หาค่า min/max/avg ความยาว + นับสัดส่วนที่มี brand suffix จากหน้าที่มีอยู่แล้ว แล้วยึดค่านั้นเป็นเกณฑ์ |
| L18 | **title/meta ที่เขียนตอนวางแผน = baseline ไม่ใช่ final** | ตอนวางแผนยังไม่ได้ดู SERP ของคู่แข่งที่ครองอันดับรายหน้า | เขียนให้ครบเป็น baseline (กัน field ว่างตอน build) แล้ว **ทบทวนอีกรอบตอนเขียนเนื้อหาจริง** พร้อมเทียบ SERP · บันทึกสถานะไว้ที่ `reconciliation_notes` |
| L19 | **หน้าที่ `legal_review_required=true` ต้องคุมถ้อยคำถึงระดับ meta** | meta ของหน้าราคาถ้าเขียนแบบชวนซื้อ/เทียบราคา = โฆษณาสถานพยาบาลตาม ม.38 · หน้ายาถ้าอ้างสรรพคุณ = พ.ร.บ.ยา ม.88 | หน้าราคา: meta อธิบาย**ปัจจัยที่ทำให้ราคาต่าง** ไม่ใส่ตัวเลข ไม่มีคำเชิญชวน · หน้ายา: ไม่อ้างสรรพคุณ ไม่ระบุขนาดยาใน meta · ทุกหน้าอาการ: ห้ามคำรับประกันผล |

**สรุปหลักการเดียวที่ครอบทุกข้อ:** *เติมหน้าให้ครบไม่ใช่เป้าหมาย — เป้าหมายคือทุกคำที่ลงไปต้องมีเหตุผลที่ตรวจสอบย้อนหลังได้*


---

## 12. Change control

- แก้ SOP นี้ = bump version + บันทึกเหตุผลท้ายไฟล์
- ข้อ 4 (B1, B9) และข้อ 8 (compliance) แก้ไม่ได้โดยฝ่าย SEO ต้องผ่านผู้รับอนุญาตสถานพยาบาล
- เนื้อหาการแพทย์บนหน้าที่เกิดจาก SOP นี้ยังต้องผ่าน sign-off ของ ทพ.ดร. อมรพงษ์ ตามกระบวนการเดิม (`seo_editorial_reviews`)

---

## ภาคผนวก — ลำดับงานหลัง SOP อนุมัติ

0. tag `primary_entity_fp` ให้คีย์ 230 ตัวที่ค้าง + หน้า 63 หน้าที่ไม่มี entity
1. สร้าง view `entity → keywords` (volume/intent/SERP/KD) = คลังตั้งต้น
2. รัน rule engine ตาม SOP นี้ → เขียนผลลง staging ก่อน
3. รัน QA gates ข้อ 10 → แก้ → merge
4. ส่วนเกิน → ข้อเสนอหน้าใหม่ตามข้อ 9
5. §9 Local — **ไม่ต้อง pull ใหม่** ตรวจแล้วคลังมีคีย์ near-me อยู่ 27 ตัว ติด entity ครบ (ขูดหินปูน ใกล้ฉัน 4,808 · ฟอกสีฟัน ใกล้ฉัน 1,125 · คลินิก ขูดหินปูน ใกล้ฉัน 1,057 ฯลฯ) แต่ **assign ไปแล้วแค่ 3 ตัว และ 2 ใน 3 ผิดหน้า** (6.4.7 หน้า evidence, 6.2.3.4 หน้าเปรียบเทียบ) — ปัญหาอยู่ที่การ assign ไม่ใช่ supply
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

**ต้องอัปเดต 4 จุดทุกครั้ง:** `page_fingerprint` · `parent_page_fp` · `internal_links.from_page_fp` · `internal_links.to_page_fp`
`fingerprint` (`page_XXXX`) **ห้ามแตะ** — เป็น canonical ID ตาม DR-008 และมี trigger ป้องกันอยู่

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
```

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
