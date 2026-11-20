# ทุกแบรนด์: `citation_tier` ถูกบังคับตาม `citation_type` ตั้งแต่ตอนเขียนแล้ว (2026-11-21)

DR-086 · Schema v1.33 · **สถานะ: apply กับ GTGT แล้ว 2026-11-20** · migration `migrations/2026-11-20d_citation_tier_by_type.sql`

**สรุปสั้น:** คลัง `seo_citations` ที่ทุกแบรนด์ใช้ร่วมกัน **ปฏิเสธแถวที่ tier ไม่ตรงกับชนิดงานวิจัย** แล้ว ถ้า ETL / n8n / session ของคุณเขียนคลังนี้ ให้ **ไม่ต้องส่ง `citation_tier`** (ระบบเติมให้) หรือส่งค่าที่ตรงตารางข้างล่างเท่านั้น

---

## 1. เกิดอะไรขึ้น

- 2026-11-20 มีแบรนด์ลง citation 20 แถวด้วย**สเกลระดับหลักฐานอีกแบบ** (guideline = 1, SR/MA = 2, cohort = 3 …)
- gate G5 ตรวจทั้งคลังกลาง → **deploy ของแบรนด์อื่น (vth-biodent) ล้ม 3 รอบ** ส่วนแบรนด์ที่เขียนไม่รู้ตัว
- สาเหตุเชิงระบบ: กฎอยู่แค่ใน COMMENT ของคอลัมน์ + CI · ตารางเองรับ tier 1–6 อะไรก็ได้
- แก้ข้อมูลแล้วทั้ง 21 แถว (ค่าเดิมอยู่ใน `maintenance_log`) · ตอนนี้ทั้งคลัง 0 แถวขัดกฎ

## 2. สเกลเดียวของ EYWA (Bible §23.1)

| tier | `citation_type` |
|---|---|
| **1** | systematic_review · meta_analysis |
| **2** | rct |
| **3** | clinical_guideline (สมาคมวิชาชีพ — รวม position statement / คำแนะนำของสมาคม) |
| **4** | regulatory_document |
| **5** | cohort_study · case_control · cross_sectional · case_series |
| **6** | textbook · expert_opinion · case_report · editorial · industry_publication · patient_resource |
| ใส่เอง | other · news_article |

⚠️ **ห้ามใช้พีระมิดที่ให้ guideline อยู่บนสุด** — ใน EYWA guideline = 3

## 3. ระบบทำอะไรตอนนี้ (`trg_citation_tier_by_type`)

| คุณเขียน | ผล |
|---|---|
| INSERT ไม่ใส่ `citation_tier` | เติมจาก type ให้ |
| INSERT / UPDATE tier ไม่ตรง type | **ล้ม** `23514 check_violation` + บอก tier ที่ถูก |
| UPDATE เปลี่ยน type อย่างเดียว | tier ตามให้เอง |
| type = other / news_article | ใส่ tier เองได้ (1–6) |

## 4. ต้องทำอะไร

| ใคร | ทำอะไร |
|---|---|
| ทุกแบรนด์ที่เขียน `seo_citations` | เลิกคำนวณ tier เองใน ETL (ส่ง NULL ได้) หรือใช้ตารางข้อ 2 · ถ้า INSERT ล้มด้วย 23514 → แก้ที่ type หรือ ETL **ห้ามขอปิด trigger** |
| ทุกแบรนด์ | `study_type` ใช้ค่ามาตรฐาน (ดู `STUDY_TYPE_SYNONYM` ใน `scripts/citation-gates/run-citation-qa-gates.py`) — รายละเอียดอย่าง n= หรือ retrospective เขียนใน `key_findings` (ยังไม่บังคับที่ฐานข้อมูล แต่ G14 เตือน) |
| myobrace-center | 20 แถวที่ลง 2026-11-20 ถูกปรับแล้ว (อ่าน `maintenance_log`) · repo `eywa-myobrace-center` ยังว่าง — ไฟล์/สคริปต์ที่ใช้โหลดควร commit ขึ้น repo และแก้สเกลก่อนโหลดรอบต่อไป · 3 แถวยังไม่มี locator (AAPD, AAO, เอกสารศิริราช) |

**อ้างอิง:** DR-086 · `Citation_Pool_SOP_v1_0.md` §2 · COMMENT ของ `seo_citations.citation_tier` · gate G5 (`run-citation-qa-gates.py` / `citation-qa-gates.sql`)
