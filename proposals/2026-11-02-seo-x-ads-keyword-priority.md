# Proposal — SEO × Google Ads Keyword Priority (Paid–Organic Arbitration)

**Status:** Draft for operator decision · 2026-11-02
**Scope:** UNIVERSAL (all brands) · activates the dormant DR-026 Ads track on `seo_x_ads_keywords_contextual_master`
**Would become:** DR-084 (if accepted)

---

## 1. คำถามที่ต้องตอบ

"คีย์เวิร์ดไหนควรซื้อโฆษณา และคีย์ไหนปล่อยให้ SEO ทำงาน" — โดยใช้ตารางคีย์เวิร์ดตัวเดียวกันคุมทั้งสองฝั่ง แล้วต่อไปให้ระบบเปิด/ปิดคีย์บน Google Ads เองได้

## 2. ของที่มีอยู่แล้ว (สำรวจ 2026-11-02)

| ของที่มี | ทำอะไร | ใช้กับ Ads ได้ไหม |
|---|---|---|
| Keyword_Assignment_SOP §6.2 — ลำดับตัดสิน 7 ชั้น (relevance → intent → SERP-type → volume → KD → token → CPC) | เลือกว่าคีย์ไหนเป็น **target ของหน้าไหน** | ❌ ไม่ใช่การจัดลำดับความสำคัญ — เป็นการจับคู่คีย์↔หน้า |
| DR-080 `v_page_priority` (8 signal, น้ำหนักใน `seo_priority_weights`) | จัดลำดับ **หน้า** ที่ควรแก้ก่อน | ❌ ระดับหน้า ไม่ใช่ระดับคีย์ |
| `monthly_market_snapshot.seo_ads_priority_score` (Volume 40 · Low competition 35 · Intent 25) | "ทำหรือไม่ทำ" ระดับคีย์ | ⚠️ ใช้ไม่ได้ตรง ๆ — "competition ต่ำ = ดี" เป็นตรรกะ SEO; ฝั่ง Ads competition คือ **ต้นทุน** ไม่ใช่มูลค่า และไม่ได้ดูว่าเราติดอันดับ organic อยู่แล้วหรือยัง |
| DR-026 คอลัมน์ Ads บนตารางคีย์ (`ad_active`, `ad_priority_tier` t1/t2/t3/none, `ad_intent_score`, `ad_match_type_preferred`, `ad_landing_page_fp`) | ที่เก็บผลการตัดสิน | ✅ มีครบ แต่ **dormant**: `ad_active` false ทั้ง 22,798 แถว · tier = none ทั้งหมด · `ad_intent_score` ว่างทั้งหมด |
| `seo_gsc_query_daily` | อันดับ organic รายวันต่อ query | ✅ แกนหลักของฝั่ง "organic coverage" |
| `v_tsa_keyword_conversion` / `tsa_bond` | conversion ระดับคีย์ (organic เท่านั้น) | ✅ ใช้เป็น "proven value" — VTH มี bond `paid_search` 118 รายการ = ยิง Ads อยู่จริง |

**สรุป:** ฝั่ง SEO มี rubric "จับคู่" และ rubric "หน้า" แต่ **ยังไม่มี rubric ระดับคีย์ที่ตอบคำถาม paid vs organic** — ต้องสร้างใหม่ แต่ใช้ข้อมูลและคอลัมน์ที่มีอยู่เกือบทั้งหมด

### ช่องโหว่ข้อมูลที่เจอ (ต้องแก้ก่อนใช้จริง)

1. **CPC ใช้ไม่ได้** — median `cpc_avg` ของคีย์ที่ active = 0.00 (Deezy) / 0.19 (VTH) → น่าจะยังไม่ได้เทียบสกุลเงิน หรือ DataForSEO คืนค่าว่าง ต้องตรวจก่อนใช้ CPC เป็นสัญญาณ
2. **Snapshot เก่า** — 5 จาก 8 แบรนด์ snapshot ล่าสุด 2026-02-19 · VTH 2026-08-09
3. **ไม่มีข้อมูล Google Ads ใน Supabase เลย** — ไม่มีตาราง keyword/search-term/cost จาก Ads ทั้งที่ VTH ยิงอยู่
4. **GSC จับคู่กับคีย์ได้น้อย** — VTH มีคีย์ target/semantic 1,075 ตัว แต่ match กับ query ใน GSC (35 วัน) ได้ 16 ตัว · Deezy match ได้ ~593 / 2,310 · ต้อง join ด้วย `kw_norm()` ทั้งสองฝั่ง (`query_norm` ของ GSC เป็น normalization คนละแบบ ไม่เรียงคำ)
5. `ads_intent` ปนกันหลายรูปแบบ (`Transactional_Exact` กับ `Transactional – Exact`, `Mixed Intent`, `Low Intent / Irrelevant`) — ต้อง map เป็นชุดปิดก่อน

## 3. หลักการสากล + หลักฐาน

### 3.1 "ติด SEO แล้วไม่ต้องซื้อ" — ถูกครึ่งเดียว

งานวิจัยของ Google (Search Ads Pause studies) วัดว่าถ้าหยุดโฆษณา คลิกที่หายไป organic ชดเชยได้แค่ไหน:

| อันดับ organic ของเราบนคีย์นั้น | % คลิกโฆษณาที่ "เพิ่มจริง" (incremental) |
|---|---|
| ไม่มีผล organic | ~100% (ภาพรวมทุก vertical 89%) |
| อันดับ 1 | **50%** |
| อันดับ 2–4 | **82%** |
| อันดับ 5 ลงไป | **96%** |

แปลว่า: ถ้าติดอันดับ 1 แล้วหยุดโฆษณา คลิกที่ได้จาก Ads ครึ่งหนึ่งจะกลับมาทาง organic ฟรี ๆ — แต่ถ้าอยู่อันดับ 4–10 หยุด Ads แล้วเสียคลิกไปเกือบทั้งหมด
→ **เกณฑ์ "top 10 = ไม่ซื้อ" หลวมเกินไป** · หลักฐานรองรับแค่ **อันดับ 1 ที่นิ่ง** (อันดับ 2–4 ยังเสียคลิก 82%) แล้วค่อย **ทดสอบหยุด** ไม่ใช่หยุดทันที

อีกเหตุผล: SERP คีย์คลินิกในไทยมัก มี Ads 3–4 ช่อง + Local pack + AI Overview อยู่บน organic อันดับ 1 — "อันดับ 1" ใน GSC อาจอยู่ครึ่งล่างของจอมือถือ (คอลัมน์ `serp_features_list` / `total_ads_count` ใน `seo_x_ads_keyword_serp_competitors` ใช้ตรวจได้)

### 3.2 คีย์แบรนด์เป็นกรณีพิเศษ

- eBay field experiment: โฆษณาบนคีย์ชื่อแบรนด์ **แทบไม่มี incremental benefit** เพราะคนหาชื่อเราจะคลิก organic อยู่แล้ว (Blake, Nosko, Tadelis 2015)
- แต่ Bing experiment: ถ้า **มีคู่แข่งยิงโฆษณาบนชื่อเรา** แล้วเราไม่ยิง คู่แข่ง "ขโมย" คลิกไป 18–42% → การยิงป้องกันคุ้ม (Simonov, Nosko, Rao 2018)
→ กฎ: คีย์แบรนด์ = ปิดเป็นค่าเริ่มต้น · เปิดเฉพาะเมื่อตรวจเจอคู่แข่งยิงบนชื่อเรา (Auction Insights / `total_ads_count` > 0 บน SERP คีย์แบรนด์)

### 3.3 จัดตาม search term ไม่ใช่ keyword

ด้วย broad match / Smart Bidding / Performance Max คำค้นจริงถูก match จากหลาย keyword — **การ pause keyword หนึ่งตัวไม่ได้หยุดการจ่ายเงินบน query นั้น** วิธีที่ได้ผลจริงคือใส่ **negative keyword (exact)** ระดับ campaign สำหรับ query ที่ตัดสินว่า "organic ดูแลได้" และ pause/enable เฉพาะ keyword ที่เราสร้างเป็น exact/phrase เอง

### 3.4 ต้องวัด ไม่ใช่เชื่อ

Google Ads มี **Paid & organic report** (ต้อง link Search Console เข้ากับ Google Ads) ที่แสดง query เดียวกันว่าได้คลิกจากทั้งสองฝั่งเท่าไร — ใช้คู่กับการทดสอบหยุด (pause test) เพื่อวัด incrementality ของเราเอง แทนการใช้ค่าเฉลี่ยจากงานวิจัย

## 4. Rubric ที่เสนอ — 2 แกน + gate

### 4.0 Hard gates (ตัดก่อนให้คะแนน — ไม่ผ่าน = ไม่ซื้อ Ads ไม่ว่าคะแนนเท่าไร)

| Gate | เงื่อนไขตัดออก |
|---|---|
| G1 Compliance | ยา/หัตถการที่ Google Healthcare policy ห้าม · ข้อความโฆษณาสถานพยาบาลที่ยังไม่ได้อนุมัติ สบส. · `brands.compliance_profile.ads_strategy` บอก no-paid · `keyword_use_as = 'excluded'` |
| G2 Intent | `ads_intent` ∈ Informational / Low Intent / Irrelevant (คีย์ความรู้ → SEO only) |
| G3 Landing page | ไม่มีหน้า Live ที่ตอบคีย์นี้ (ไม่มี `target`/`ad_landing_page_fp`) → ซื้อไม่ได้ เพราะ Quality Score จะต่ำ |
| G4 Geo | คีย์ local ที่อยู่นอกรัศมีสาขา |

### 4.1 แกน A — Business Value Score (0–100, ภายในแบรนด์ใช้ percentile เหมือน DR-080)

| Signal | น้ำหนัก v1 | ที่มา |
|---|--:|---|
| Commercial intent | 35 | `ads_intent` (map: Transactional/Local = 1.0 · Commercial = 0.7 · Mixed = 0.4 · Navigational-brand = แยกไปกฎแบรนด์) |
| Proven conversion | 25 | `v_tsa_keyword_conversion` + conversion จาก Google Ads (เมื่อ ingest แล้ว) |
| Service value | 20 | `tsa_product_value` ผ่าน entity → product_line · ใช้ราคาจริง (exact) เท่านั้น · **ไม่ fallback เป็น CPC** (CPC สะท้อนการแข่งขัน ไม่ใช่มูลค่าเรา และข้อมูลยังไม่เสถียร) · ยังเป็น placeholder → ต้องกรอกก่อน ไม่มีราคา = ตัดตัวชี้วัดนี้แล้ว rescale |
| Demand | 20 | `volume_recent_12m` percentile + `momentum_index` |

signal ที่แบรนด์ไม่มีข้อมูล → ตัดออกแล้ว rescale (ตรรกะเดียวกับ DR-080) · **High = ≥ 60 หรือมี conversion จริง ≥ 2 ใน 90 วัน**

> ไม่ใช้ `seo_ads_priority_score` เดิมเป็นแกนนี้ เพราะให้คะแนนบวกกับ "competition ต่ำ" ซึ่งเป็นตัวแปรต้นทุน ไม่ใช่มูลค่า — เก็บไว้ใช้ฝั่ง SEO ต่อได้

### 4.2 แกน B — Organic Coverage State (จาก GSC 28 วัน, weighted position)

| State | เงื่อนไข |
|---|---|
| `dominant` | weighted pos ≤ 1.5 (= อันดับ 1) **ติดต่อกัน 28 วัน**, URL ที่ติด = หน้าที่ assign (ไม่ cannibalize), impressions ≥ เกณฑ์ขั้นต่ำ |
| `page1` | pos 1.5–10 (อันดับ 2–10) |
| `striking` | pos 11–20 |
| `weak` | pos > 20 หรือไม่มี impression ใน GSC |

### 4.3 Decision matrix

| | `dominant` (อันดับ 1) | `page1` (2–10) | `striking` (11–20) | `weak` |
|---|---|---|---|---|
| **High value** | **TEST_PAUSE** — เข้าคิวทดสอบหยุด 4 สัปดาห์; ถ้าคลิกรวม+conversion ไม่ลด → `PAUSE` (negative exact) · ถ้ามีคู่แข่งยิงหนัก → `DEFEND` bid ต่ำ | **ADS_ON** (82% ของคลิกเป็น incremental) | **ADS_ON + SEO_PUSH** (ส่งเข้าคิว striking ของ DR-080) | **ADS_ON** = ช่องทางหลักระหว่างรอ SEO |
| **Low value** | NO_ADS | NO_ADS | NO_ADS (SEO only) | NO_ADS |
| **Brand term** | NO_ADS ยกเว้นมีคู่แข่งยิง → `DEFEND` | ← เหมือนกัน | ← | ADS_ON (หน้าแบรนด์ควรติด 1 — ถ้าไม่ติดคือปัญหา SEO ด่วน) |

**Hysteresis** (กันเปิด-ปิดไปมา): ปิดเมื่อ `dominant` 28 วัน · เปิดกลับเมื่อ pos > 5 ติดกัน 14 วัน

### 4.4 Map เข้าคอลัมน์ DR-026 ที่มีอยู่

| ผลตัดสิน | `ad_active` | `ad_priority_tier` |
|---|---|---|
| ADS_ON (High + weak/striking) | true | `t1` |
| ADS_ON (High + page1) | true | `t2` |
| DEFEND / TEST_PAUSE | true | `t3` |
| PAUSE / NO_ADS | false | `none` |

`ad_intent_score` (1–10) = Business Value / 10 ปัดลง · เพิ่มเพียง 3 คอลัมน์: `ad_decision text`, `ad_decision_reason text`, `ad_decision_at timestamptz`

## 5. แผนทำ (phased)

| Phase | งาน | ส่งมอบ | Done when |
|---|---|---|---|
| **P0 ข้อมูล** (~1 สัปดาห์) | (a) กรอก `tsa_product_value` ราคาต่อเคสจริงทุกบริการ แล้ว refresh market snapshot ทุกแบรนด์ · (b) map `ads_intent` เป็นชุดปิด + CHECK · (c) n8n ดึง Google Ads API (GAQL: `keyword_view`, `search_term_view`, `paid_organic_search_term_view`) ลงตาราง `ads_search_term_daily` · (d) link Search Console ↔ Google Ads | ตาราง 1 ตัว + migration intent | VTH มี cost/clicks/conv รายวันใน Supabase; ทุกบริการที่มีคีย์ Ads มีราคาต่อเคส |
| **P1 Rubric** (~1–2 สัปดาห์) | view `v_keyword_ads_decision` (gate → แกน A → แกน B → matrix) + น้ำหนักในตาราง weights (ตาม pattern `seo_priority_weights`) · หน้าใน EYWA Console | view + รายการรายสัปดาห์ | operator เห็นรายการ "เปิด/ปิด/ทดสอบ" พร้อมเหตุผลต่อคีย์ |
| **P2 Human-in-loop** (4–6 สัปดาห์) | ทุกสัปดาห์ export รายการเป็น CSV สำหรับ Google Ads Editor · operator อนุมัติเอง · รัน **pause test** กับคีย์ `dominant + High` 5–10 ตัวของ VTH | ผลทดสอบ incrementality ของเราเอง | รู้ว่า threshold อันดับ 1 ถูกไหม หรือขยายเป็น 1–3 ได้สำหรับ dental TH |
| **P3 Automation** | n8n รายสัปดาห์ → Google Ads API mutate (`ad_group_criterion.status`, campaign negative keyword) | flow + decision log | ทำงาน dry-run 2 สัปดาห์ตรงกับที่ operator อนุมัติ ≥ 95% |

### Guardrails ของ P3 (บังคับ)

- dry-run mode เป็นค่าเริ่มต้น · เปลี่ยนได้สูงสุด N คีย์/สัปดาห์/แบรนด์
- ห้ามแตะ: คีย์แบรนด์, คีย์ใน compliance list, campaign ที่ไม่ได้ tag ให้ระบบคุม
- ทุกการเปลี่ยนเขียน log (ก่อน/หลัง/เหตุผล) + แจ้ง LINE · rollback ได้ด้วยคำสั่งเดียว
- Developer token มีแล้ว (ยืนยัน 2026-11-02) → ใช้ Google Ads API ตรงทั้ง P0 (ดึงข้อมูล) และ P3 (mutate) · เช็คระดับ access ก่อน: Test access ใช้ได้แค่ test account, บัญชีจริงต้อง Basic ขึ้นไป

## 6. Open questions (operator ตัดสิน)

1. ยอมรับเกณฑ์ **อันดับ 1 + ทดสอบก่อนหยุด** แทน "top 10 = ไม่ซื้อ" ไหม
2. Pilot ที่ VTH แบรนด์เดียวก่อน (แบรนด์เดียวที่ยิง Ads อยู่) ใช่ไหม
3. ~~มี developer token หรือยัง~~ มีแล้ว — เหลือยืนยันว่าเป็นระดับ Basic/Standard access และบัญชี VTH อยู่ใต้ MCC เดียวกัน

## 7. แหล่งอ้างอิง

1. Chan, D. et al. (2011). *Incremental Clicks Impact of Search Advertising.* Google Research — https://research.google/pubs/incremental-clicks-impact-of-search-advertising/
2. Chan, D. & Van Alstine, L. (2012). *Impact of Organic Ranking on Ad Click Incrementality.* Google Research — https://research.google/blog/impact-of-organic-ranking-on-ad-click-incrementality/ · PDF: https://www.thinkwithgoogle.com/_qs/documents/678/impact-of-ranking-of-organic-search-results-on-the-incrementality-of-search-ad_mIAayTX.pdf
3. Blake, T., Nosko, C., Tadelis, S. (2015). *Consumer Heterogeneity and Paid Search Effectiveness: A Large-Scale Field Experiment.* Econometrica 83(1) — https://doi.org/10.3982/ECTA12423
4. Simonov, A., Nosko, C., Rao, J. (2018). *Competition and Crowd-Out for Brand Keywords in Sponsored Search.* Marketing Science 37(2) — https://doi.org/10.1287/mksc.2017.1065
5. Google Ads Help — *About measuring paid and organic search results* — https://support.google.com/google-ads/answer/3097241
6. Google Ads API — *Pause ad* sample (mutate status) — https://developers.google.com/google-ads/api/samples/pause-ad
7. Internal: Keyword_Assignment_SOP §6.2 · DR-026 · DR-080 · Schema_Overview §6.1/§6.2
