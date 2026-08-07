# scripts/entity-identity — universal entity identity toolkit

สคริปต์ชุดนี้ทำให้ entity ของทุกแบรนด์มี **ตัวตนที่ตรวจสอบได้** (ICD · Wikidata · Wikipedia) และพาไปถึง JSON-LD ของหน้าเว็บ

**อ่านก่อน:** `Entity_Identity_SOP_v1_0.md` · **Decision record:** DR-050

ต้นฉบับที่ยังพัฒนาอยู่: `eywa-vth-biodent/web/scripts/` — สำเนาในโฟลเดอร์นี้คือรุ่นที่ประกาศเป็นมาตรฐาน

---

## ลำดับการรัน (บังคับ)

```bash
# 0. ต้องมี service key ก่อน
export SUPABASE_SERVICE_KEY=<service-role-key>

# 1. ยืนยัน / หา Wikidata Q-id — report ก่อนเสมอ
node verify-entity-ids.mjs                 # แบรนด์ปัจจุบันเท่านั้น
node verify-entity-ids.mjs --all           # ทั้งตาราง (ทุกแบรนด์)
node verify-entity-ids.mjs --all --apply

# 2. คนตัดสิน label mismatch + Q-id ที่ชนกัน แล้วบันทึกลง ADJUDICATED_KEEP ในสคริปต์

# 3. เก็บรหัสจาก item ที่ verify แล้ว (never-overwrite)
node harvest-entity-codes.mjs
node harvest-entity-codes.mjs --apply

# 4. เติม ICD-11 ที่ยังว่าง จากตารางเทียบของ WHO
node map-icd10-to-icd11.mjs
node map-icd10-to-icd11.mjs --apply

# 5. export JSON ที่ commit ให้เว็บอ่าน
node gen-entity-schema.mjs

# (เสริม) embedding สำหรับหา entity ซ้ำเชิงความหมาย — ต้องมี OPENAI_API_KEY
node embed-entities.mjs
```

**ขั้น 1 ต้องมาก่อนขั้น 3 เสมอ** — ทุกรหัสที่เก็บในขั้น 3 สืบทอดความถูกต้องของ Q-id จากขั้น 1

ทุกตัว **ไม่เขียนอะไรถ้าไม่ใส่ `--apply`**

---

## สิ่งที่ต้องแก้เมื่อย้ายไปแบรนด์อื่น

| ไฟล์ | ต้องเปลี่ยน |
|---|---|
| ทุกไฟล์ | `SUPABASE_URL` ถ้าคนละ project |
| `verify-entity-ids.mjs` | `brand_name` ใน query ตอนไม่ใส่ `--all` · `UA` (contact) · `ADJUDICATED_KEEP` เริ่มจากว่าง |
| `gen-entity-schema.mjs` | `brand_id` ที่ใช้กรองหน้า · path ปลายทาง |
| `map-icd10-to-icd11.mjs` | `REFUSED` เริ่มจากว่าง · เปลี่ยน release ของ WHO ได้ที่ `ZIP_URL` |
| `harvest-entity-codes.mjs` | `ROUTES` ถ้า schema ของแบรนด์ต่าง (ปกติไม่ต่าง — เป็นตารางร่วม) |

`ADJUDICATED_KEEP` และ `REFUSED` เป็น **บันทึกคำตัดสินของคน** ไม่ใช่ config — ห้าม copy ข้ามแบรนด์โดยไม่ตรวจ เพราะชื่อ entity ของแต่ละแบรนด์ไม่เหมือนกัน

---

## ผลที่ได้จริง (VTH BioDent · 2026-08-07 · 715 entity ทั้งตาราง)

| | ก่อน | หลัง |
|---|--:|--:|
| entity มี `wikidata_id` | 88 | **148** |
| entity มี `wikipedia_url` | 83 | **130** |
| Q-id ซ้ำข้าม entity | 8 | **0** |
| condition มี ICD-11 | 9 | **73 / 125** |
| condition มี MeSH / UMLS | 0 / 0 | **41 / 43** |
| anatomy มี FMA / UBERON | 8 / 12 | **15 / 18** |

ปัดตกระหว่างทาง: **63** ตัวที่ label ตรงแต่ไม่ใช่ของการแพทย์ · **8** ตัวที่ชนกันเอง · **29** residual code · **2** ที่คนปฏิเสธ

ของที่กันไว้ได้ ตัวอย่าง: `mbm-bruxism-evaluation → meat and bone meal` · `corticosteroid-injection-tmj → Termez Airport` · `oral-inflammation-reset-program → Persona 4` · `emax-material → ห้างในฮ่องกง` · `emax-crown → บทความวิชาการปี 2004`
