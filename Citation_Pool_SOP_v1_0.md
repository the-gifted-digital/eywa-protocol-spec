# Citation Pool SOP — v1.5 (universal)

> ขอบเขต: การสร้าง ตรวจสอบ และผูก citation เข้าหน้าเว็บ สำหรับทุกแบรนด์ที่ใช้ EYWA Protocol
> อ้างอิงบังคับ: Bible Part 23.1 (Citation Tier System) · Schema `seo_citations` / `seo_page_citations`
> คู่กับ: [Keyword_Assignment_SOP_v1_0.md](Keyword_Assignment_SOP_v1_0.md) — คนละเรื่อง อย่าปนกัน
> คู่กับ: Authority_Scoring_SOP_v1_0.md — สูตรคะแนน authority ทั้ง 3 ชั้น (`authority_formula_version = 'eywa-authority-1.0'` ในฐานจริง) ·
> 🔴 **ยังไม่มีไฟล์นี้ในรีโปนี้** ฉบับเดียวที่มีอยู่คือ `eywa-vth-biodent/content-plan/etl/Authority_Scoring_SOP_v1_0.md` — ลิงก์ในรีโปนี้จึงยังชี้ไม่ได้ *(corrected 2026-08-24 against live schema)*
>
> **เกิดจากอะไร:** 2026-07-29 รื้อสระ citation ของ VTH BioDent พบว่าใน 115 แถวที่มี PMID หรือ DOI
> มี **13 แถวชี้ไปงานวิจัยคนละสาขา** — งานนิเวศวิทยาทางทะเล, การถ่ายยีนมะเขือเทศ, การวิเคราะห์เชิงพื้นที่ผู้ป่วย ALS,
> การทำงานของปอดนักดับเพลิงหลัง 9/11 ทั้งหมดถูกบันทึกด้วยชื่อเรื่องทางทันตกรรมที่ฟังดูสมเหตุสมผล
> อ่านสระเปล่า ๆ ไม่มีวันจับได้ ต้องถามต้นทางเท่านั้น
>
> **v1.3 เกิดจากอะไร:** 2026-08-09 รันชุด gate 11 ข้อ**เป็นครั้งแรก** แล้วพบว่ามันไม่เคยรันได้เลยตั้งแต่เขียนมา
> — ไฟล์เป็น psql แต่โปรเจกต์เปิดแค่ PostgREST ทั้งไฟล์จึงนั่งอยู่ในรีโปเหมือนมี coverage มาทั้งปี
> รันจริงครั้งแรกเจอ **55 แถวบล็อก** และเจอความล้มเหลวรูปแบบใหม่ที่ C1–C20 ยังไม่ครอบ:
> citation ที่ตัวระบุถูกต้อง ลิงก์คืน 200 แต่**อ้างเอกสารกับองค์กรที่ไม่ได้เป็นคนออกเอกสารนั้น** (C24)

---

## 1. หลักการเดียวที่ครอบทุกข้อ

> **ตัวระบุ (PMID / DOI / URL) ต้องถูกยิงกลับไปถามต้นทางก่อนเสมอ — ชื่อเรื่องที่บันทึกไว้ไม่ใช่หลักฐาน**

เหตุผล: ชื่อเรื่องเป็นข้อความที่ใครก็เขียนได้ ตัวระบุเป็นสิ่งที่ต้นทางเป็นคนตอบ
ถ้าสองอย่างนี้ไม่ตรงกัน แปลว่ามีอย่างน้อยหนึ่งอย่างผิด และเราไม่รู้ว่าอันไหน จนกว่าจะไปถาม

---

## 2. Tier — ตัดสินจาก publication type ไม่ใช่จากชื่อเรื่อง

**ฉบับจริงของสเกลคือ COMMENT ของคอลัมน์ `seo_citations.citation_tier`** (DR-057 §4 — เพราะ G5 ที่รันใน CI ยึดอันนั้น)
เอกสารไหนให้สเกลอื่นคือผิด · COMMENT นั้นบอกเองว่า "อนุมานจากการกระจายตัวของข้อมูลจริงเมื่อ 2026-08-18 ไม่มีเอกสารต้นทางที่ไหนระบุไว้"
ยังห้าม regex บนชื่อเรื่องเหมือนเดิม — ต้องอ่านบทคัดย่อจริงหรือ `article_types` จาก PubMed ก่อนตั้งค่า (ชื่อเรื่องที่ขึ้นต้นว่า "A Systematic Review" อาจเป็น SR ที่รวมแต่งานในสัตว์) *(corrected 2026-08-24 against live schema)*

🔴 **เมื่อบทคัดย่อกับ `article_types` ขัดกัน — conduct ชนะ (DR-063, 2026-08-27)**

`Review` เป็น**แท็ก index** ไม่ใช่ข้อเท็จจริงว่างานทำอะไร · MEDLINE ติดให้ทั้ง narrative review และ
systematic review ที่มันไม่ได้แท็ก `Systematic Review` แยกไว้ · deezy พบสี่แถวที่ `['Journal Article','Review']`
เหมือนกันหมด แต่บทคัดย่อมี PROSPERO/PRISMA/random-effects pooling ครบ

**กติกา**

```
pubtypes มี Systematic Review / Meta-Analysis   -> tier ตามนั้น
pubtypes มีแค่ Review                            -> เกตคืน None + PUBTYPE_UNDERTAGGED
                                                    คนอ่านบทคัดย่อแล้วตั้ง tier เอง
ไม่มี type ใช้ได้เลย                              -> UNCLASSIFIED (คนละธง มีขั้นตอนถัดไปคนละแบบ)
```

**เกตจะไม่เดา tier จาก `Review` อีกต่อไป** เดิมคืน `T6/expert_opinion` ซึ่งอ่านเหมือนข้อเท็จจริงที่ derive มา
และทำให้ G7 (หน้าที่ไม่มีหลักฐาน tier 1–3) แดงบนหน้าที่หลักฐานดีจริง

⚠️ **regex จับ conduct เป็นตัวชูธง ห้ามใช้ขับการตัดสิน** — รอบที่ผลิตรายการข้างบนพลาดหนึ่งแถว
เพราะคำว่า `databases` กับ `were used` มีคำคั่น · **ยังไม่มีตัวตรวจอัตโนมัติที่เชื่อถือได้พอจะกด tier**

⚠️ **"ไม่มีบทคัดย่อ" ต้องพิสูจน์ ไม่ใช่อนุมานจากค่าว่าง** — `.text` ของ ElementTree คืนเฉพาะข้อความ
ก่อน child ตัวแรก บทคัดย่อที่ขึ้นต้นด้วย `<b>Background:</b>` จึงอ่านได้ 0 ตัวอักษรทั้งที่มี 1,948 ·
ค่าว่างมีสองสาเหตุ และหนึ่งในนั้นคือโค้ดเรา ยืนยันด้วยการดึงซ้ำคนละทางก่อนสรุป

**สองคอลัมน์ ไม่ใช่คอลัมน์เดียว:** COMMENT แจกแจง tier ด้วยค่า **`study_type`** (ซึ่งไม่มี constraint) ส่วน **G5 อ่านแต่ `citation_type`** (ซึ่งมี `chk_citation_type` 17 ค่า)
ตารางนี้จึงมีสองช่อง อย่าเอาไปปนกัน — G14/G15 (§4) มีอยู่เพราะช่องว่างระหว่างสองคอลัมน์นี้พอดี *(corrected 2026-08-24 against live schema)*

| Tier | คือ | `study_type` (ตาม COMMENT — ฉบับจริง) | `citation_type` ที่ G5 บังคับ |
|---|---|---|---|
| 1 | Cochrane / SR / meta-analysis | `systematic_review` `meta_analysis` `systematic_review_and_meta_analysis` `cochrane_review` | `systematic_review` `meta_analysis` |
| 2 | RCT | `rct` `randomized_controlled_trial` `cohort_study` | `rct` |
| 3 | แนวปฏิบัติของสมาคมวิชาชีพ | `clinical_guideline` `consensus_guideline` `clinical_practice_guideline` | `clinical_guideline` |
| 4 | หน่วยงานรัฐ / กำกับดูแล (WHO, NICE, FDA, อย., สปสช.) | `law` `regulation` `regulatory_document` `report` `fact_sheet` `survey_report` `genetic_association` | `regulatory_document` |
| 5 | cohort / case-control / cross-sectional / in vitro | `cross_sectional` `in_vitro` `retrospective_cohort` `prospective_cohort` `case_series` `clinical_study` `pilot_study` | `cohort_study` `case_control` `cross_sectional` `case_series` |
| 6 | ตำรา / narrative review / ความเห็นผู้เชี่ยวชาญ / เอกสารผู้ผลิต | `narrative_review` `textbook` `manufacturer_document` `expert_opinion` `consensus_statement` | `textbook` `expert_opinion` `case_report` `editorial` `industry_publication` `patient_resource` |

- 🔴 **คำเดียวกัน คนละคอลัมน์ คนละ tier — ต้องให้คนตัดสิน ห้ามแก้ฝ่ายเดียว:** `cohort_study` ที่เป็น `study_type` = **T2** ตาม COMMENT (1 แถว อยู่ T2 จริง) แต่ที่เป็น `citation_type` = **T5** ตาม `TIER_BY_TYPE` ใน `run-citation-qa-gates.py` (40 แถวอยู่ T5 และ G5 ผ่านหมด) วัด 2026-08-24 *(corrected 2026-08-24 against live schema)*
- `consensus_statement` = **T6** ไม่ใช่ T3 — ตัวที่เป็น T3 คือ `consensus_guideline` *(corrected 2026-08-24 against live schema)*
- `other` **ยังไม่มีคำตัดสิน ไม่ใช่ T6** — และเป็นค่าที่อยู่ใน**ทั้งสองคอลัมน์** ต้องแยกกันนับ วัด 2026-08-24: `citation_type='other'` **25 แถว** กระจาย T1(2) T2(1) T3(1) T4(2) T5(5) T6(14) (`select citation_tier, count(*) from seo_citations where citation_type='other' group by 1`) · `study_type='other'` **45 แถว** กระจาย T1(16) T3(10) T5(9) T6(10) — ตัวนี้คือตัวที่ COMMENT หมายถึงตอนเขียนว่า "กระจายทั้ง 1/3/5/6" · `scoping_review` มีเฉพาะฝั่ง `study_type` (`chk_citation_type` ไม่รับค่านี้ ถามด้วย `citation_type` จะได้ 0 แถวเสมอ) — **3 แถว** อยู่ T1/T5/T6 อย่างละใบ ส่วน COMMENT ยังจดไว้ 2 แถว เพราะนับเมื่อ 2026-08-18 *(corrected 2026-08-24 against live schema)*
- `study_type` ไม่มี constraint จึงมีตัวสะกดซ้ำซ้อนปนอยู่จริง (`rct` กับ `randomized_controlled_trial`, `Systematic Review` ตัวใหญ่) — **33 ค่าที่ต่างกัน + NULL 82 แถว จาก 551** วัด 2026-08-24 · G15 คือตัวที่รายงาน NULL *(corrected 2026-08-24 against live schema)*
- ข้อจำกัดของหลักฐาน (เช่น meta-analysis ที่รวมแต่งานในสัตว์) เขียนลง `key_findings` — **ห้ามกด tier แทน** *(corrected 2026-08-24 against live schema)*

**ลำดับความสำคัญเมื่อชนกัน:** เอกสารที่เป็นทั้ง guideline และ SR ให้เป็น **T1** (Bible: "Highest Tier available for the claim type")
⚠️ ข้อมูลยังไม่ตามกฎนี้: `study_type='systematic_review_guideline'` 2 แถวนั่งอยู่ **T3** ไม่ใช่ T1 — วัด 2026-08-24 ยังไม่ได้แก้ *(corrected 2026-08-24 against live schema)*

**ข้อมูล first-party ของคลินิก** = T6 + `citation_type='other'` — ไม่มีตัวระบุภายนอกโดยธรรมชาติ ต้องยกเว้นใน gate G1
⚠️ `brand_scope` แคบ **ไม่ได้แปลว่า first-party** — 85 แถวที่ scope แคบ มีแค่ 14 แถวที่เป็น T6+`other` ส่วนที่เหลือเป็น meta-analysis 31 · SR 12 · RCT 6 · guideline 3 ซึ่งไม่ใช่ของแบรนด์ใครทั้งนั้น (COMMENT ของ `brand_scope` บันทึกเคส guideline TMD ที่ถูก scope ผิดไว้เมื่อ 2026-08-24) วัด 2026-08-24 *(corrected 2026-08-24 against live schema)*

---

## 3. ขั้นตอนรับ citation เข้าสระ (บังคับ)

```
1. หา → PubMed / Crossref / เว็บหน่วยงาน       ห้ามเขียนจากความจำ
2. ยิงกลับ → efetch หรือ api.crossref.org      ต้องได้ record จริง
3. เทียบชื่อ → token overlap >= 0.34
4. เขียนทับ → title/journal/year เอาจากต้นทาง   ไม่ใช่คำสรุปที่เขียนเอง
5. ตั้ง tier → ตั้ง study_type จาก article_types แล้ว map ตามข้อ 2
6. archive → Wayback ถ้ามี snapshot จริงเท่านั้น
7. verification_status='verified'
```

เครื่องมือ: `content-plan/etl/verify-citation-locators.py` (รับ TSV `fingerprint|pmid|doi|title` คืน verdict `PASS` / `TITLE_MISMATCH` / `NOT_FOUND` / `NO_LOCATOR` · threshold ข้อ 3 อยู่ที่ `main(path, threshold=0.34)`)
รีโค้ด tier ทั้งสระใช้ `content-plan/etl/reconcile-citation-tiers.py --apply` ซึ่ง derive ทั้ง tier และ type จากค่าจริง ไม่ใช่จากดุลพินิจ *(corrected 2026-08-24 against live schema)*

**verdict `TITLE_MISMATCH` ไม่ได้แปลว่าปลอมเสมอไป** ต้องอ่านทุกอัน:
- record ต้นทาง**อยู่ในหัวข้อเดียวกัน** → ชื่อที่บันทึกเป็นคำสรุป ให้เขียนทับด้วยชื่อจริง เก็บแถวไว้
- record ต้นทาง**คนละสาขา** → ถอดตัวระบุ ตั้ง `broken_link` บันทึกว่าเลขนั้นชี้ไปอะไร แล้วหาแหล่งใหม่ให้ข้ออ้างนั้น

---

## 4. QA gates

`content-plan/etl/citation-qa-gates.sql` เป็น **สเปก** และมี 11 gate (G1–G11) · ตัวที่ **รันจริง** คือ `content-plan/etl/run-citation-qa-gates.py`
ซึ่งชิป **G1–G15** พร้อมเกตย่อยอีก 4 ตัว (`G1w` `G6u` `G6w` `G7w`) — เกณฑ์ผ่านคือบรรทัดสุดท้าย **`blocking rows: 0`**
ไม่ใช่ "ทุก gate คืน 0 แถว": G8/G13/G14/G15 และทุกตัวที่ลงท้ายด้วย `w` เป็นระดับเตือน คืนแถวได้โดยไม่บล็อก *(corrected 2026-08-24 against live schema)*

| Gate | จับอะไร |
|---|---|
| G1 | ไม่มีตัวระบุเลย (ยกเว้น textbook = ISBN, other = first-party) |
| G2 | citation ที่ยัง `unverified` ไปโผล่บนหน้า |
| G3 | retracted / broken_link ยัง active บนหน้า |
| G4 | URL PubMed ไม่ตรงกับ PMID ที่บันทึก |
| G5 | tier ไม่ตรงกับ citation_type — **อ่านแต่ `citation_type` เท่านั้น** ไม่เคยอ่าน `study_type` (§2) *(corrected 2026-08-24 against live schema)* |
| G6 | หน้าได้ citation ไม่ถึงขั้นต่ำตาม `page_category` (§5) *(rewritten 2026-08-23 — `layer` column does not exist; see the reconciliation report)* |
| G7 | หน้าที่มีข้ออ้างทางการแพทย์ไม่มี Tier 1-3 เลย |
| G8 | freshness (T1>5ปี, T2/T5>7ปี) — ระดับเตือน ไม่บล็อก |
| G9 | เอกสารเชิงพาณิชย์ที่ไม่ได้ติดป้าย |
| G10 | DOI/PMID ซ้ำในสระเดียวกัน |
| G11 | citation เดียวกันซ้ำในหน้าเดียวกัน |
| **G12** | **`page_fp` ผูกด้วยคีย์ผิดตัว → orphan เงียบ** (L28) — รัน **ข้ามทุกแบรนด์** ไม่ใช่แค่แบรนด์ตัวเอง · 🔴 **ยิงไม่ออกอีกแล้ว** ตั้งแต่ 2026-08-16 มี FK จริง `fk_page_citations_page` (ON UPDATE/DELETE CASCADE) บังคับ `page_fp` → `seo_website_page_master.page_fingerprint` ใส่ผิดจะ error ทันที · **เก็บ gate ไว้** เป็นตัวจับถอยหลังถ้า FK ถูกถอด *(corrected 2026-08-24 against live schema)* |
| **G13** | **citation ตัวเดียวถูกผูกข้ามคลัสเตอร์เกินเกณฑ์** (`CLUSTER_SPREAD_WARN = 5`) — ระดับเตือน · เดิมข้อนี้เขียนไว้ว่า "citation ที่บทคัดย่อจริงไม่รองรับหัวข้อของหน้า (L29) ตรวจด้วย abstract+MeSH" 🔴 **อันนั้นไม่เคยถูกสร้าง** และ C30 บันทึกว่าลองแล้วพังสองวิธี — ต้องเจอด้วยการอ่านตอนวางแผน wave (C26) *(corrected 2026-08-24 against live schema)* |
| **G14** | **`citation_type` กับ `study_type` ให้ tier คนละค่า** — ระดับเตือน · G5 อ่านแต่ `citation_type` ของที่ผิดจึงลอดได้ (SR ที่ติดป้าย `expert_opinion` นั่งอยู่ T6) *(corrected 2026-08-24 against live schema)* |
| **G15** | **ไม่มี `study_type` เลย** — ระดับเตือน · ไม่มีฟิลด์ที่สองมาค้าน `citation_type` ได้ RCT จึงนั่งเป็น cohort ที่ T5 ได้โดย G5 ไม่ติดใจ *(corrected 2026-08-24 against live schema)* |
| G1w · G6w · G7w | ตัวแปร**ระดับเตือน**ของ G1/G6/G7 — `G6w`/`G7w` คือหน้าสถานะ `Planned` (Live บล็อก Planned เตือน) *(corrected 2026-08-24 against live schema)* |
| **G6u** | **หน้าที่ gate จำแนกโซนไม่ได้** ซึ่ง**ไม่ใช่**หน้าที่โควตาเป็น 0 · 🔴 **ตัวนี้ไม่ใช่ระดับเตือน มันบล็อก** — ชื่อไม่ลงท้ายด้วย `w` และไม่อยู่ในลิสต์ `("G8","G13","G14","G15")` ตัวจำแนกใน `run-citation-qa-gates.py` จึงนับเข้า `blocking rows` · รันจริง 2026-08-24 (vth-biodent) คืน 0 แถว จึงยังไม่เคยหยุด deploy ใคร *(corrected 2026-08-24 against live schema)* |

```sql
-- G12 · คีย์ผูกของตารางบริวารคือ page_fingerprint ({brand}-{node}) เท่านั้น
-- ไม่ใช่ fingerprint (page_{ULID16}) · เดิมเป็น soft FK ใส่ผิดแล้วหลุดเงียบ
-- 2026-08-24: มี FK จริง fk_page_citations_page แล้วตั้งแต่ 2026-08-16 คิวรีนี้จึงคืน 0 แถวเสมอ
-- เก็บไว้เป็น regression check ถ้า FK ถูกถอด ไม่ใช่ของที่ต้องไล่ซ่อมประจำอีกต่อไป
-- เจอแล้วให้ "เขียนคีย์ใหม่" ห้ามลบแถว — ของที่ผูกไว้ถูก ผิดแค่รูปคีย์
select pc.id, pc.page_fp, p.brand_id, p.page_fingerprint as should_be
from seo_page_citations pc
left join seo_website_page_master p on p.fingerprint = pc.page_fp   -- ใส่ผิดเป็นตัวนี้
where not exists (select 1 from seo_website_page_master q where q.page_fingerprint = pc.page_fp);
```

---

## 5. ขั้นต่ำต่อหน้า (Bible 23.1 minimum_per_layer)

| `page_category` (fallback `page_type`) | ขั้นต่ำ |
|---|---|
| `condition_pillar` หน้าอาการ · `knowledge_article` หน้าความรู้ | ≥ 3 (≥1 ใน Tier 1-3) |
| `service_page` · `procedure_pillar` หน้าบริการ · `technology_page` หน้าเทคโนโลยี | ≥ 2 |
| `evidence_case` หน้าเคส | ≥ 1 |
| `home` · `about` · `doctor_profile` · `contact` · `branch_landing` · `local_*` — utility, local, brand | 0 — **ยกเว้น** หน้าราคา/สิทธิเบิกจ่าย ต้องมีแหล่งกฎหมาย/สิทธิประโยชน์ของประเทศนั้น |

*(rewritten 2026-08-23 — `layer` column does not exist; see the reconciliation report)*
- predicate จริง = `coalesce(page_category, page_type) in (…)` — ตารางแปลงอยู่ที่ Bible §3.2 "Layer → Live Column Mapping" (L4 Concern → `condition_pillar` แปลงสะอาด · L1/L2/L3/L5 เป็นการประมาณ · L6 Protocol ไม่มีคู่)
- **`page_category` ไม่ได้ว่าง 100% แล้ว** — backfill ลงแล้วทุกแบรนด์: NULL เหลือ deezy-dental 93/869 · vth-biodent 75/761 · smile-scape-clinic 21/728 (รวม 189/2,358) วัด 2026-08-24 · ยังต้อง coalesce อยู่เพราะ 189 แถวนั้นแขวนกับ `page_type` ล้วน ๆ — `coalesce(page_category, page_type)` เป็น NULL **0 แถว** *(corrected 2026-08-24 against live schema)*
- **map แบบประมาณ ไม่ใช่ 1:1 กับ §-number เดิม** — category บอกว่าหน้า*คืออะไร* ส่วน sitemap_section บอกว่าอยู่*โซนไหน* และสองอย่างขัดกันจริงในข้อมูล (vth `technology_page` 17 แถวอยู่ §3 · smile-scape `service_page` 80 แถวอยู่ §5 — ทั้งสองตัวเลขยืนยันแล้วเมื่อ 2026-08-24) · G6 ที่ shipped **ยังคีย์ที่โซนเหมือนเดิม**: `MIN_PER_LAYER = {"5":3,"6":3,"3":2,"4":2,"7":1}` อ่านจาก `sitemap_node_id.split('.')[0]` แล้ว fallback ไป `sitemap_section` (เพิ่ม 2026-08-23) — ย้ายคีย์มาที่ `page_category` ต้องแก้ทั้ง `.sql` และ `run-citation-qa-gates.py` *(corrected 2026-08-24 against live schema)*
- 🔴 **UNIMPLEMENTABLE as written — see mapping note**: โควตาเฉพาะหน้า protocol/aftercare (Bible Layer 6) รันไม่ได้ เพราะไม่มีค่าใดของ `page_category` `page_type` `node_tier` หรือ `sitemap_section` แยกมันออกจาก `service_page` (Bible §3.2 ลงคำตัดสินเดียวกัน) — มันจึงตกไปกินโควตาแถว ≥ 2 เงียบ ๆ *(corrected 2026-08-24 against live schema)*
- **ยกเว้นหน้าที่ไม่มีข้ออ้างให้อ้าง** ประกาศ **ในข้อมูล** ด้วยสตริง `CITATION EXEMPTION` ใน `reconciliation_notes` ของหน้านั้น (กลไกเดียวกับ `INTENT EXEMPTION`) ไม่ใช่ลิสต์ fingerprint ในสคริปต์ · `reconciliation_notes` เป็น log ต่อท้ายคั่นด้วย `" | "` — **เขียนทับ = ลบข้อยกเว้นของคนอื่นทิ้งเงียบ ๆ** *(corrected 2026-08-24 against live schema)*

สระคือ **backbone** ไม่ใช่คำตอบสุดท้าย — ตอนเขียนเนื้อหาจริงต้องหา citation เฉพาะหน้าเพิ่ม แล้วผูกเข้า `seo_page_citations` ทีละข้ออ้าง
**และแถวใน `seo_page_citations` ไม่ได้แปลว่าหน้าอ้างจริง** — เกตนับจำนวนพอใจได้ด้วยการผูกอะไรก็ได้ · ตัวที่เทียบกับ references ในไฟล์จริงคือ `verify-page-citation-usage.py` (`npm run check:citation-usage`) *(corrected 2026-08-24 against live schema)*

---

## 6. การกระจาย citation ข้ามหน้า

อย่าใช้ "top-N ของ cluster" ตรง ๆ — ทุกหน้าใน cluster เดียวกันจะได้ชุดเดียวกันหมด
(รอบแรกที่ VTH: ใช้ไปแค่ 58 จาก 227 ตัว อีก 169 ตัวไม่ถูกแตะเลย)

ใช้ **anchor + round-robin**:
- slot 1 = anchor หมุนไปตามลิสต์ Tier 1-3 ของ cluster → การันตี G7
- slot 2..n = หมุนทั้งลิสต์ โดย offset = `(page_index × quota + slot) % pool_size`
- ตามด้วย top-up pass เก็บหน้าที่ยังไม่ถึง quota

ผลที่ VTH: ใช้ 203 จาก 227 ตัว, 0 หน้าต่ำกว่า quota, 0 หน้าไม่มี Tier 1-3

ตัวเลขบรรทัดบนเป็นผลของรอบนั้น สระโตขึ้นตลอด — อย่าอ้างเป็นขนาดปัจจุบัน · ขนาดสด ณ 2026-08-24: สระ **551 แถว** · ผูกแล้ว **6,626 แถว** ลง **2,009 หน้า**
แยกตามแบรนด์ (distinct citation ที่ถูกใช้): vth-biodent 388 · smile-scape-clinic 362 · deezy-dental 235
นับใหม่เมื่อไหร่ก็ได้ด้วย `select p.brand_id, count(*), count(distinct pc.citation_fp) from seo_page_citations pc join seo_website_page_master p on p.page_fingerprint=pc.page_fp group by 1` *(corrected 2026-08-24 against live schema)*

---

## 7. บทเรียน — กับดักที่เจอจริง

| # | กับดัก | เกิดอะไร | กันยังไง |
|---|---|---|---|
| C1 | **ตัวระบุปลอมดูเหมือนของจริง** | PMID `18371090` ผูกกับ "Titanium Allergy & Implant Loss" แต่จริง ๆ คืองานนิเวศวิทยาทางทะเล — 13 แถวเป็นแบบนี้ | ยิงกลับต้นทางทุกแถวก่อนรับเข้าสระ ไม่มีข้อยกเว้น |
| C2 | **เลขผิดนิดเดียว ≠ ปลอม** | `15078732` ผิด แต่ `15078734` คืองาน MAD 630 คนที่ถูกต้อง ห่างกัน 2 | เจอ mismatch อย่าเพิ่งลบ ค้นหัวข้อนั้นใน PubMed ก่อน มักเจอตัวจริงอยู่ใกล้ ๆ |
| C3 | **ชื่อเรื่องที่เขียนเองกลายเป็นชื่อจริง** | บันทึกว่า "Schwarz peri-implantitis SR" จริง ๆ คือ EFP S3 clinical practice guideline — เป็นแหล่งที่ **ดีกว่า** ที่จดไว้ | เก็บชื่อจริงลง DB เสมอ คนเขียนเนื้อหาจะ copy ไปใส่ References ตรง ๆ |
| C4 | **tier ที่กรอกมือไม่ตรงสเปกและไม่ตรงกันเอง** | Cochrane 14/15 แถวถูกใส่ T2 · guideline กระจาย 4 tier · เอกสารเดียวกันมี 2 แถวคนละ tier | map จาก `PublicationType` เท่านั้น + gate G5 |
| C5 | **ถอด PMID แล้วลืมถอด URL** | ถอด PMID ปลอมออกแล้ว แต่ `url` ยังเป็น `pubmed.../<เลขปลอม>/` | gate G4 · หรือ generate URL จาก PMID เสมอ อย่าเก็บสองที่ |
| C6 | **เกือบกรอก archive_url ที่ไม่มีจริง** | จะ `'https://web.archive.org/web/2026/'\|\|url` ให้ทุกแถวรวดเดียว — นั่นคือปลอมตัวระบุแบบเดียวกับที่กำลังแก้ | เช็ค `archive.org/wayback/available` ก่อนเสมอ ไม่มี snapshot = ปล่อย null |
| C7 | **regex ไม่ใส่ word boundary** | G9 ใช้ `graphy` ไปจับ "radio**graphy**" และ "photogram­metry" → flag แนวปฏิบัติ AAOMR ผิด 2 ตัว | `\y...\y` เสมอเวลา match ชื่อยี่ห้อ |
| C8 | **"Various authors" ไม่ใช่ citation** | 18 แถวเป็น `"Various authors. Osseodensification SR. 2023."` ไม่มีผู้แต่ง ไม่มีตัวระบุ | ถ้าอ้างอิงไม่ได้จริง = ไม่ใช่ citation ตัดทิ้ง อย่าเก็บไว้ให้ดูจำนวนเยอะ |
| C9 | **หน้าแรกของวารสาร ≠ ตัวบทความ** | `aap.onlinelibrary.wiley.com/journal/19433670` ถูกใช้เป็นแหล่งของข้ออ้างหนึ่ง — นั่นคือหน้าแรกของ Journal of Periodontology | URL ต้องชี้ไป **ชิ้นงาน** ไม่ใช่ผู้จัดพิมพ์ |
| C10 | **สระเอียงไปทางสิ่งที่ทีมถนัด** | implant 45 ตัว / periodontal 25 ตัว แต่ฟันปลอม 0, เลเซอร์ 0, myofunction 1 ทั้งที่เป็นจุดขายของแบรนด์ | นับ citation ต่อ cluster เทียบกับจำนวนหน้าต่อ cluster ก่อนเริ่มเขียน |
| C11 | **ไม่มีแหล่งของประเทศตัวเอง** | `is_thai_specific` = 0/196 ทั้งที่มีหน้าราคา หน้าสิทธิเบิกจ่าย และหน้าที่ต้องอ้างสถิติไทย | ทุกแบรนด์ต้องมีชุดแหล่งประจำประเทศ: สำรวจสุขภาพระดับชาติ, สิทธิประโยชน์รัฐ, สภาวิชาชีพ, ตัวบทกฎหมายโฆษณา |
| C12 | **ข้อมูล first-party ของแบรนด์อื่นปนอยู่ในสระ** | 13 แถว "SmileScape Clinic internal" — `brand_scope` กันไว้ถูกแล้ว แต่ query ที่ลืมกรองจะดึงมาใช้ | query สระต้องกรอง `brand_scope @> array['*'] or brand_scope @> array['<brand>']` เสมอ |
| C13 | **สระซ้ำโดยที่ DOI/PMID ไม่ซ้ำ** | Cochrane sealants มี 2 แถว ชื่อต่างกันเล็กน้อย เลยรอด unique constraint | ตรวจซ้ำหลัง resolve ตัวระบุแล้ว (G10) ไม่ใช่ก่อน |
| C14 | **Cochrane review ถูกถอนได้** | `CD002778` (splint therapy for TMD) ถูก Cochrane ประกาศ **WITHDRAWN** ตั้งแต่ 2016 แต่ยังนั่งอยู่ในสระเป็น T1 | ทุก Cochrane DOI ต้องเช็ค `.pubN+1` ผ่าน Crossref · ถ้าชื่อฉบับใหม่ขึ้นต้นด้วย `WITHDRAWN:` = ห้ามใช้อ้างอิง ต้องหาตัวแทน |
| C15 | **เก็บ .pubN เก่าไว้คู่กับ .pubN ใหม่** | มีทั้ง `CD003879.pub4` (2016) และ `.pub5` (2020) เป็นคนละแถว — เป็นรีวิวเดียวกันคนละเวอร์ชัน G10 จับไม่ได้เพราะ DOI ต่างกันจริง | เทียบ DOI ที่ตัด `.pubN` ออกแล้ว เก็บเฉพาะเวอร์ชันล่าสุด |
| C16 | **สระ `brand_scope='*'` เป็นของกลาง** | สระเดียวถูกอ่านโดย 3 แบรนด์พร้อมกัน — citation ปลอม 13 ตัวจึงกระทบทั้งสามแบรนด์ ไม่ใช่แค่แบรนด์ที่ตรวจเจอ | locator round-trip เป็น gate **ระดับสระ** ไม่ใช่ระดับแบรนด์ · ซ่อมครั้งเดียวได้ทุกแบรนด์ แต่ปล่อยเน่าครั้งเดียวก็พังทุกแบรนด์เช่นกัน |
| C18 | **availability API ของ Wayback มองข้าม snapshot ที่มีจริง** | `archive.org/wayback/available` บอกว่าไม่มี snapshot 8 URL — พอเช็คด้วย **CDX API** พบว่า 4 ใน 8 มี capture อยู่จริง รวมถึงตัวที่เพิ่งถูกบันทึกไปเมื่อครู่ | ใช้ `web.archive.org/cdx/search/cdx?url=…&output=json&filter=statuscode:200` เป็นตัวตัดสิน · Save-Page-Now ตอนนี้ต้องมีบัญชี archive.org (คืน 429/520) แต่บางครั้งบันทึกสำเร็จแม้จะคืน error — ต้องเช็ค CDX ซ้ำก่อนสรุปว่าล้มเหลว |
| C19 | **freshness ต้องถามว่า "มีรีวิวใหม่ที่ตอบคำถามเดียวกันไหม" ไม่ใช่ "เก่ากว่ากี่ปี"** | 55 แถวเกิน window · ไล่ด้วย PubMed related-articles แล้วพบว่ามีแค่ **7 แถว** ที่มีรีวิวใหม่กว่าตอบคำถามเดียวกัน อีก 48 แถวยังเป็นหลักฐานที่ดีที่สุดของคำถามนั้น | `elink` related-articles + กรอง `PublicationType` เป็น SR/MA/Guideline + ปี ≥ cutoff · **อ่านผลทุกอัน** — related-articles คืนของนอกเรื่องปนมา (งานมาลาเรีย, granulomatosis) ห้ามรับอัตโนมัติ |
| C20 | **เนื้อหาที่เขียนไปแล้วอาจอ้างงานที่ไม่มีอยู่จริง แม้สระจะสะอาด** | ร่าง Deezy 9 หน้าเขียน References เป็นข้อความล้วน ไม่ผูกสระเลย — ตรวจแล้วพบแต่งขึ้น 1 รายการ (ใช้ 2 หน้า, ชื่อเรื่องคนละอันแต่ วารสาร/เล่ม/หน้า เดียวกัน) + อ้าง Cochrane แล้ว**สรุปตรงข้ามกับที่รีวิวสรุป** | ตรวจ References ในไฟล์เนื้อหาด้วยวิธีเดียวกับสระ · สัญญาณอันตราย: รายการสองอันที่มีพิกัดวารสารเดียวกันเป๊ะแต่ชื่อเรื่องต่างกัน = อย่างน้อยหนึ่งอันแต่ง · ตรวจด้วยว่า**ข้อสรุปในเนื้อหาตรงกับที่แหล่งสรุปจริง** ไม่ใช่แค่ว่าแหล่งมีอยู่ |
| C17 | **`not like` บนคอลัมน์ที่เป็น NULL คืน NULL** | UPDATE ที่มี `abstract not like '%…%'` อัปเดตได้แค่ 16 จาก 68 แถว เพราะแถวที่ `abstract IS NULL` ถูกตัดออกเงียบ ๆ | ใช้ `coalesce(col,'') not like …` เสมอ · เช็คจำนวนแถวที่โดนอัปเดตทุกครั้งเทียบกับที่คาด |
| C21 | **gate ที่รันไม่ได้ = ไม่มี gate แต่ดูเหมือนมี** | `citation-qa-gates.sql` เขียนเป็น psql ตั้งแต่ 2026-07 แต่โปรเจกต์เปิดแค่ PostgREST — **ไม่เคยรันเลยสักครั้ง** ทั้งปี พอรันจริงครั้งแรกเจอ 55 แถวบล็อก | gate ต้องรันได้ด้วยคำสั่งเดียวจากที่ที่ CI รันจริง · `run-citation-qa-gates.py` เป็นตัวรัน ส่วน `.sql` ยังเป็นสเปก · ต่อเข้า CI ทันที ไม่งั้นมันเน่าอีก |
| C22 | **gate ฟ้องหน้าที่แก้ไม่ได้** | G6/G7 ฟ้อง 2 หน้าที่ citation = 0 แต่ทั้งคู่ `status='Merged'` — ถูกยุบเข้า URL อื่นแล้ว ไม่มีเนื้อหาจะอ้างอิง เป็นบั๊กของ gate ไม่ใช่ของข้อมูล | gate ที่นับต่อหน้าต้องจำกัดขอบเขตที่ `status in ('Planned','Live')` เสมอ · ตัวเลขที่แก้ไม่ได้จะสอนให้คนเมินทั้ง gate |
| C23 | **ผลอันดับหนึ่งของ registry ไม่ใช่การยืนยัน** | ROR fuzzy search คืน**องค์กรผิด 7 จาก 14** ชื่อองค์กรทันตกรรม — EFP ได้ "Federation of European Publishers", AAPD ได้ "American Academy of Cosmetic Dentistry", ราชวิทยาลัยทันตแพทย์ไทยได้ Royal College of Surgeons of England | กรองด้วยความคล้ายของชื่อก่อนรับ · ตรวจ label ของ Wikidata QID ก่อนเก็บทุกครั้ง · ถ้า registry ไม่ตรง **ปล่อย `ror_id` เป็น null** ดีกว่าเก็บเลขผิด — เลขผิดคือตัวระบุปลอมในอีกรูปแบบ |
| C24 | **อ้างเอกสารกับองค์กรที่ไม่ได้ออกเอกสารนั้น** | 2 แถวอ้าง "แนวทางเวชปฏิบัติทันตกรรม — ราชวิทยาลัยทันตแพทย์แห่งประเทศไทย" · URL คืน 200 · แต่สแกนเว็บทั้งไซต์แล้วราชวิทยาลัยฯ เป็นองค์กรฝึกอบรมและสอบวุฒิบัตร ไม่ได้เผยแพร่เอกสารชื่อนั้น | **ความล้มเหลวคนละแบบกับ C1 และ C9** — ตัวระบุไม่ปลอม ลิงก์ไม่เสีย แต่การอ้างผิด · URL ที่เป็นหน้าแรกขององค์กรคือสัญญาณ: ต้องเปิดดูว่าองค์กรนั้นออกเอกสารชื่อนั้นจริงไหม ไม่ใช่แค่ว่าเว็บยังอยู่ |
| C25 | **ดัก exception เงียบ = ตัวเลขสวยแต่ผิด** | ดึง FWCI จาก OpenAlex ด้วย filter `ids.doi:` ซึ่งคืน HTTP 400 · โค้ดดักไว้แล้ว `continue` จับได้ **19 จาก 390** แต่รายงานว่าทำงานปกติ · key ที่ถูกคือ `doi:` และ `pmid:` | ทุก except ที่ครอบการเรียก API ต้อง**พิมพ์บอก** และรายงานจำนวนที่พลาด · ถ้าอัตราจับคู่ต่ำผิดปกติ ให้ถือว่าเป็นบั๊กจนกว่าจะพิสูจน์ได้ว่าไม่ใช่ |
| C26 | **จำนวน citation บนหน้า ≠ ความตรงหัวข้อ** | หน้า zygomatic 3 หน้าผ่านทุก gate และมี citation 3–5 ตัว แต่ไม่มีตัวไหนเกี่ยว zygomatic เลย — เป็นงานปลูกกระดูก/อัตรารอดรากเทียมทั่วไป · `vth-4.8.3` ยังแปะงานเลเซอร์กำจัดฟันผุกับยาต้านจุลชีพปริทันต์ | ก่อนจัดคลัสเตอร์เข้า wave การเขียน ต้อง**อ่านชื่อเรื่อง** ที่ผูกอยู่ ไม่ใช่นับจำนวน · G6 นับได้อย่างเดียว มันไม่รู้ว่าเรื่องตรงไหม |
| C27 | **คอลัมน์ว่างไม่ได้แปลว่าข้อมูลขาด** | `citation_authority_weight` ว่าง 0/390, `entity_authority_score` 0/715, `cluster_health_score` 0/58 — ไม่ใช่ข้อมูลหาย แต่เป็นฟีเจอร์ที่ยังไม่ได้สร้าง · **ตอนนี้สร้างแล้ว** วัด 2026-08-24: `citation_authority_weight` เติมแล้ว 529/551 (`authority_formula_version='eywa-authority-1.0'`) · `entity_authority_score` 730/732 · `cluster_health_score` 58/58 · `cluster_topical_authority` 58/58 — บทเรียนยังใช้ได้ แต่ตัวเลขชุดนี้เป็นของ 2026-08-09 *(corrected 2026-08-24 against live schema)* · `isbn` ว่างเพราะเป็น journal article · `archive_url` ว่างเพราะไม่มี snapshot จริง | แยกให้ออกก่อนเติม: **คำนวณ** (ห้ามกรอกมือ ดู Authority_Scoring_SOP) · **มีเงื่อนไข** (isbn, retracted_at) · **ห้ามเดา** (archive_url, ror_id) · **เติมได้จากต้นทาง** (abstract, publication_date, publisher_name, country_of_origin) |
| C28 | **ตัวระบุในเนื้อหาเป็นคนละด่านกับตัวระบุในสระ** | สระผ่าน gate ครบ 11 ข้อ แต่ references block ในไฟล์ YAML มี DOI/PMID ผิด **11 ตัวบนหน้า Live** — ป้ายว่า "Global burden of severe periodontitis" แต่ resolve ไปงานมานุษยวิทยาเรื่องศิลปะ · ป้ายว่ารีวิวเฝือกสบฟันแต่ resolve ไปงาน COVID-19 · **สระมีตัวถูกครบทุกตัว** เป็นความผิดพลาดตอนคัดลอกล้วน ๆ | gate ที่อ่านแต่ DB มองไม่เห็นด่านนี้ตลอดกาล · ต้องมี `audit-content-locators.py` (`npm run check:content-citations`) ยิงทุก label+url ในไฟล์กลับ Crossref/PubMed ทุก build |
| C29 | **audit ที่ join กับ page_master มองไม่เห็น fixture** | รอบเช้าเทียบ YAML กับ `seo_website_page_master` ผ่าน slug จึงข้าม `demo.yaml` ทั้งหมด · พอสแกนทุกไฟล์จริงเจอ **PMID ปลอมอีก 3 ตัว** (resolve ไป ubiquitin ligase, "Navigating Knowledge Landscapes", วิวัฒนาการ snoRNA) กระจายอยู่ 10 ภาษา | `published:false` ไม่ได้แปลว่าไม่สำคัญ — **fixture คือของที่หน้าถัดไปก๊อปไปใช้** ตัวระบุปลอมใน fixture จึงแพร่ต่อ · audit ต้อง scope ที่ไฟล์ ไม่ใช่ที่ตาราง |
| C30 | **"citation ไม่ตรงหัวข้อ" ตรวจอัตโนมัติไม่ได้ด้วยสัญญาณที่มี** | ลอง 2 วิธี พังทั้งคู่ · เทียบชื่อ citation กับชื่อ entity ของหน้า → flag 1,409/2,679 รวม "Intra-articular injections in temporomandibular arthralgia" บนหน้า HA-injection ที่ตรงหัวข้อชัด · ดูการกระจายข้ามคลัสเตอร์ → DC/TMD อยู่ 8 คลัสเตอร์เพราะเป็นเกณฑ์วินิจฉัยที่ใช้กว้างจริง | อย่าส่งลิสต์ที่ผิดครึ่งหนึ่ง · สัญญาณคุณภาพที่ใช้ได้จริงคือ `supports_claim` — เติมแล้ว 96% และแต่ละอันระบุ finding เจาะจง แปลว่าลิงก์ถูกเลือกมา ไม่ใช่แจกสุ่ม · ตัวไม่ตรงหัวข้อต้องเจอด้วยการอ่านตอนวางแผน wave (C26) |
| C31 | **อย่าลบแถวที่ถูกปฏิเสธออกจากสระ** | อยากลบ citation ที่อ้างองค์กรผิดทิ้งเพื่อกันพลาดซ้ำ | แถวที่ถูกปฏิเสธคือ**บันทึกว่าอะไรเคยผิด** ลบแล้วคนถัดไปเติมกลับได้โดยไม่รู้ · G2/G3 กันไม่ให้ขึ้นหน้าอยู่แล้ว ซึ่งคือผลลัพธ์ที่การลบต้องการ · ใช้ `verification_status` + `abstract` บันทึกเหตุผลแทน (เทียบ C2 เลขผิดนิดเดียวไม่ใช่ปลอมเสมอ) |

---

## 8. ปรับใช้กับแบรนด์ใหม่

1. export สระเป็น TSV → รัน `verify-citation-locators.py` → อ่าน verdict ทุกแถว
2. แก้ตาม §3 (เขียนทับ / re-source / ตัดทิ้ง)
3. recode tier ตาม §2 — ใช้ `reconcile-citation-tiers.py --apply` ซึ่ง derive ทั้ง tier และ type จากค่าจริง ไม่ใช่จากดุลพินิจ
4. นับ citation ต่อ cluster เทียบจำนวนหน้า → เติมช่องว่าง (§7 C10) → แล้ว**อ่านชื่อเรื่องที่ผูกอยู่** ว่าตรงหัวข้อไหม (§7 C26)
5. เพิ่มชุดแหล่งประจำประเทศ (§7 C11) และผูก `source_org_fp` เข้าองค์กรที่ออกเอกสาร (§10)
6. ผูก `seo_page_citations` ด้วย anchor + round-robin (§6)
7. รัน `run-citation-qa-gates.py --brand <slug>` ให้ **`blocking rows: 0`** — `.sql` เป็นสเปก (G1–G11) `.py` เป็นตัวรัน (G1–G15) *(corrected 2026-08-24 against live schema)*
8. รัน `audit-content-locators.py` ให้ **blocking: 0** — ตรวจตัวระบุที่เขียนอยู่ในไฟล์เนื้อหา ซึ่งเป็นคนละด่านกับสระ (§7 C28) และต้อง scope ที่ไฟล์ทุกไฟล์รวม fixture ไม่ใช่เฉพาะหน้าใน page_master (§7 C29)
9. รัน `verify-page-citation-usage.py --brand <slug>` — แถวใน `seo_page_citations` ไม่ได้แปลว่าหน้าอ้างจริง ตัวนี้เทียบกับ references ใน YAML จริง *(corrected 2026-08-24 against live schema)*
10. **ต่อ gate ทั้งชุดเข้า CI ทันที** (§7 C21) — `npm run check:citations` · `npm run check:content-citations` · `npm run check:citation-usage` ใน workflow ที่ deploy จริง · ⚠️ ของ VTH (`.github/workflows/deploy-preview.yml`) ต่อไว้แค่ **2 ใน 3**: `check:citations` กับ `check:content-citations` — `check:citation-usage` มีใน `web/package.json` แต่**ไม่มีใน workflow** ต้องรันมือ (ตรวจไฟล์ workflow 2026-08-24) *(corrected 2026-08-24 against live schema)*
11. คำนวณคะแนน authority ทั้ง 3 ชั้น ตาม Authority_Scoring_SOP_v1_0.md (`compute-citation-authority.py` · `compute-entity-cluster-authority.py`)
12. ก่อน publish: รันซ้ำทั้งชุด — ตัวระบุเน่าได้ตามเวลา

**เวลาเทียบ references ในไฟล์กับ `seo_page_citations`:** เทียบด้วย **PMID และ DOI พร้อมกัน** และเทียบ DOI แบบไม่สนตัวพิมพ์ · รอบแรกที่เทียบแต่ DOI รายงาน "เกิน" ปลอม 38 รายการ เพราะ reference ที่เขียนเป็น URL แบบ pubmed ไม่มีทางแมตช์ DOI ในสระ และมีอีกตัวซ่อนอยู่หลัง `BOR` ตัวใหญ่

---

## 9. Change control

- แก้ SOP นี้ = bump version + บันทึกเหตุผลท้ายไฟล์
- §2 (tier mapping) และ §5 (ขั้นต่ำต่อหน้า) ผูกกับ Bible 23.1 โดยตรง แก้ที่นี่ฝ่ายเดียวไม่ได้ · §5 เปลี่ยน**คีย์**จาก layer → `page_category` แล้ว (ค่าขั้นต่ำเท่าเดิม) แต่ Bible 23.1 `minimum_per_layer` ยังคีย์ด้วย layer อยู่ — ต้องตามมาปรับ *(rewritten 2026-08-23 — `layer` column does not exist; see the reconciliation report)*
- **แต่ §2 ไม่ได้ขึ้นกับ Bible อีกแล้ว** — DR-057 §4 ตัดสินว่า COMMENT ของ `seo_citations.citation_tier` เป็นฉบับจริง เพราะ G5 ที่รันใน CI ยึดอันนั้น · ถ้า Bible 23.1 กับ COMMENT ขัดกัน **COMMENT ชนะ** และให้ตามไปแก้ Bible *(corrected 2026-08-24 against live schema)*
- เนื้อหาการแพทย์ยังต้องผ่าน sign-off ของผู้ประกอบวิชาชีพตามกระบวนการเดิม · **แต่ห้ามเขียนกฎที่ gate `has_medical_review` ด้วยแถวใน `seo_editorial_reviews`** — DR-057 §6 ตัดสินว่าหน้าที่ operator อนุมัติให้ `Live` = ผ่านการรีวิวแล้ว ตั้งธงเป็น true แล้วฝังผู้รีวิวลง schema ได้เลย (ตารางรีวิวมี 2,095 แถว ณ 2026-08-24 และมี FK `fk_editorial_reviews_page` จริง แต่มันเป็นบันทึก ไม่ใช่เงื่อนไขของธง) *(corrected 2026-08-24 against live schema)*

---

## 10. แหล่งเชิงองค์กร (`source_org_fp`)

Guideline ของสมาคมวิชาชีพและเอกสารของหน่วยงานรัฐไม่มี PMID — ตัวระบุของมันคือ **องค์กรที่ออกเอกสาร** คอลัมน์ `seo_citations.source_org_fp` มีไว้เพื่อการนี้ ก่อน 2026-08-09 ใช้อยู่ 0 แถว · ล่าสุด **31 จาก 551 แถว** และ `seo_entity_organization` มี **21 แถว** วัด 2026-08-24 (`select count(*) from seo_citations where source_org_fp is not null`) *(corrected 2026-08-24 against live schema)*

**โครงสร้าง:** `seo_entity_organization.entity_fp` เป็น **FK จริงไป `seo_entity_graph.entity_fingerprint`** (`seo_entity_organization_entity_fp_fkey` · ON DELETE CASCADE · **ไม่มี ON UPDATE CASCADE** เปลี่ยน `entity_fingerprint` ต้องไล่แก้เอง) *(corrected 2026-08-24 against live schema)* — ต้องสร้าง entity ฐาน (`entity_type='organization'`) ก่อน แล้วค่อยใส่แถวรายละเอียด ถ้าข้ามขั้นแรกจะได้ error 23503 ที่อ่านเหมือนปัญหาอื่น

**ค่าที่ constraint ยอมรับจริง** (ตรวจด้วยการยิงจริง ไม่ใช่เดาจากชื่อ):
- `organization_type` (`chk_org_type`) — 12 ค่า: `clinic` `hospital` `professional_association` `regulator` `manufacturer` `accreditation_body` `university` `research_institute` `NGO` `government_agency` `media_publisher` `company` · ลิสต์เดิมตกไป 3 ตัว (`NGO` `media_publisher` `company`) *(corrected 2026-08-24 against live schema)*
- `authority_tier` (`chk_org_authority_tier`) — **7 ค่า** ไม่ใช่ 2: `tier_1_regulatory` `tier_2_professional_assoc` `tier_3_accreditation` `tier_4_university` `tier_5_industry` `tier_6_media` `tier_7_other` หรือ null · ลิสต์เดิมบันทึก "ค่าที่เห็นในข้อมูล" มาเป็น "ค่าที่ constraint ยอมรับ" — คนละเรื่อง *(corrected 2026-08-24 against live schema)*
  ⚠️ ผลข้างเคียง: `professional_association` 9 แถวยัง `authority_tier = null` ทั้งที่มี `tier_2_professional_assoc` ให้ใช้ — วัด 2026-08-24

**การยืนยันตัวตน** — ตามลำดับความน่าเชื่อ:
1. ROR ที่ชื่อตรงเกือบสนิท (similarity ≥ 0.8)
2. Wikidata QID ที่**เปิดดู label แล้วตรงจริง** — ห้ามเชื่อผลค้นหาเฉย ๆ (§7 C23) และระวังชื่อพ้อง เช่น `Q2824618` คือ Social Security Administration ของสหรัฐ ส่วนของไทยคือ `Q121288154`
3. เว็บทางการที่ยิงแล้วคืน 200 — พอสำหรับองค์กรระดับประเทศที่ไม่มีใน registry สากล
4. ถ้าไม่ได้ทั้งสามอย่าง → **อย่าสร้าง** ส่งให้คนตัดสิน

องค์กรใช้ร่วมกันทุกแบรนด์เหมือนสระ — reuse อย่า fork (ดู antipattern เรื่อง cluster/entity ที่ถูก fork มาแล้ว) · ยืนยันแล้ว: entity ขององค์กรทั้ง 21 แถวเป็น `brand_scope = {*}` ทั้งหมด วัด 2026-08-24 *(corrected 2026-08-24 against live schema)*

---

## 11. วินัยการเติมคอลัมน์

ก่อนเติมคอลัมน์ที่ว่าง จัดกลุ่มมันก่อน (§7 C27):

| กลุ่ม | คอลัมน์ | ทำยังไง |
|---|---|---|
| **คำนวณ** | `citation_authority_weight` `authority_breakdown` `authority_computed_at` `entity_authority_score` `cluster_health_score` `cluster_topical_authority` | รันสคริปต์ ห้ามกรอกมือ — เขียนได้ไม่ได้แปลว่าควรเขียน · **สคริปต์รันไปแล้ว** วัด 2026-08-24: weight 529/551 · breakdown 551/551 · entity 730/732 · cluster ทั้งสองตัว 58/58 · `authority_formula_version` มีค่าเดียวคือ `eywa-authority-1.0` *(corrected 2026-08-24 against live schema)* |
| **มีเงื่อนไข** | `isbn` (เฉพาะ textbook) `retracted_at` (เฉพาะที่ถูกถอน) `archive_url` (เฉพาะที่มี snapshot จริง) | ว่างคือถูกแล้ว · วัด 2026-08-24: `isbn` 3/551 · `retracted_at` 0/551 (`is_retracted` false ทุกแถว) · `archive_url` 64/551 *(corrected 2026-08-24 against live schema)* |
| **เติมได้จากต้นทาง** | `abstract` `publication_date` (efetch) · `publisher_name` (Crossref ตาม DOI) · `country_of_origin` (affiliation ผู้แต่งคนแรก) | ดึงด้วยสคริปต์ อย่าพิมพ์มือ · ยังไม่ครบ วัด 2026-08-24: abstract 190/551 · publication_date 89 · publisher_name 106 · country_of_origin 70 · ⚠️ `maintenance_log` แยกออกจาก `abstract` แล้วตั้งแต่ 2026-08-17 — **ห้ามเขียนบทคัดย่อทับ log** *(corrected 2026-08-24 against live schema)* |
| **ต้องมี** | `title` `authors` `journal_name` `publication_year` `citation_tier` `citation_type` `verification_status` `url` | จากต้นทางเท่านั้น (§1) · 🔴 **ยังไม่ครบจริง** วัด 2026-08-24: `url` ว่าง 59 · `authors` ว่าง 52 · `publication_year` ว่าง 32 · `journal_name` ว่าง 24 · (`title` `citation_tier` `citation_type` ครบ 551/551) — "ต้องมี" เป็นกฎ ไม่ใช่คำบรรยายสภาพปัจจุบัน *(corrected 2026-08-24 against live schema)* |

`citation_authority_weight` เป็น `numeric(4,3)` เพดาน 9.999 — สคีมากำหนดสเกล 0–10 ไว้แล้ว อย่าออกแบบสูตรเป็น 0–100 แล้วมาหารทีหลัง (ยืนยันชนิดคอลัมน์แล้ว 2026-08-24) *(corrected 2026-08-24 against live schema)*

`verification_status` รับแค่ 5 ค่า (`chk_verification_status`): `unverified` `verified` `broken_link` `paywalled` `retracted` · **INSERT ที่ไม่ระบุคอลัมน์นี้ตกไปที่ `unverified`** แล้วไปบล็อก G2 ของ *ทุกแบรนด์* ที่หยิบพูลกลางไปใช้ — ตั้งค่าให้ชัดเสมอตอน insert · สถานะจริง 2026-08-24: verified 522 · unverified 26 · broken_link 3 *(corrected 2026-08-24 against live schema)*

---

### Changelog
- **v1.5** (2026-08-24) — เทียบทุกข้ออ้างที่ตรวจได้กับฐานจริง แล้วรวมฉบับ v1.3/v1.4 ที่แตกไปอยู่ในรีโปแบรนด์กลับเข้าฉบับกลาง · §2 เปลี่ยนไปยึด COMMENT ของ `citation_tier` ตาม DR-057 §4 และแยก `study_type` ออกจาก `citation_type` · §4 แก้จำนวน gate (สเปก 11 · ตัวรัน 15) และแก้ความหมาย G13 · G12 กลายเป็น regression check เพราะมี FK จริงแล้ว · §5 แก้ข้ออ้าง "`page_category` ว่าง 100%" · §9 แก้เรื่อง `has_medical_review` ตาม DR-057 §6 · §10 แก้ลิสต์ค่าที่ constraint ยอมรับ · §11 อัปเดตสถานะคอลัมน์ที่คำนวณแล้ว
  - **audit รอบสอง (วันเดียวกัน)** — รันเกตจริงและอ่าน workflow แล้วแก้อีก 4 จุดของรอบแรก: `G6u` ถูกจัดเป็นระดับเตือนทั้งที่โค้ดนับมันเข้า `blocking rows` · `other`/`scoping_review` ใน §2 ถูกอ้างด้วยคิวรีของ `citation_type` ทั้งที่ COMMENT พูดถึง `study_type` (และ `scoping_review` ไม่มีในฝั่ง `citation_type` เลย) · §8 ข้อ 10 บอกว่าเกตทั้งสามต่อ CI แล้ว ทั้งที่ `check:citation-usage` ไม่มีใน `deploy-preview.yml` · escape `||` ใน C6 ที่ทำให้แถวนั้นแตกเป็น 6 ช่อง
- **v1.4** (2026-08-09) — ตรวจตัวระบุใน**ไฟล์เนื้อหา** เป็นครั้งแรก เจอผิด 11 ตัวบนหน้า Live + ปลอมอีก 3 ใน fixture · เพิ่ม C28–C31 · §8 เพิ่มขั้นตรวจ content locator และวิธีเทียบ references ที่ถูกต้อง (PMID+DOI, case-insensitive) · เพิ่ม `audit-content-locators.py` เข้า CI
- **v1.3** (2026-08-09) — รัน gate 11 ข้อเป็นครั้งแรก (ก่อนหน้านี้รันไม่ได้เลยเพราะเป็น psql) เจอ 55 แถวบล็อก · เพิ่ม C21–C27 · เพิ่ม §10 แหล่งเชิงองค์กร และ §11 วินัยการเติมคอลัมน์ · §8 เพิ่มขั้นต่อ CI และขั้นคำนวณ authority · แยกสูตรคะแนนออกเป็น Authority_Scoring_SOP_v1_0.md
- **v1.2** (2026-07-29) — เพิ่ม C18–C20 หลังผูก Deezy + ไล่ freshness ครบ + ตรวจ References ในไฟล์เนื้อหาที่เขียนไปแล้ว
- **v1.1** (2026-07-29) — เพิ่ม C14–C17 หลังตรวจ Cochrane version + พบว่าสระเป็นของกลางร่วม 3 แบรนด์
- **v1.0** (2026-07-29) — ตั้งต้นจากการรื้อสระ VTH BioDent: ตรวจ 115 ตัวระบุ พบปลอม 13 · recode tier ทั้งสระ · เพิ่ม 63 ตัวใน 12 cluster ที่ว่าง · เพิ่มแหล่งไทย 9 · ผูก 1,730 แถวเข้า 691 หน้า · บทเรียน C1–C20
