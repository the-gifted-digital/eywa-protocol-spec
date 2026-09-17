# ทุกเว็บ: ข้อห้ามทางคลินิกที่คนเขียนพิมพ์ใน YAML ไม่เคยขึ้นจอ — ตอนนี้มาจากตารางแล้ว และมีเกต

จาก vth-biodent · แจ้งเพราะเป็นเทมเพลตร่วม + ตารางแชร์ · DR-069 · Pamrel P18

---

## เกิดอะไรขึ้น

`contraindication:` ที่ทุกแบรนด์พิมพ์ไว้ใน YAML ของหน้า service/procedure ไปแค่ที่เดียว — JSON-LD `MedicalProcedure.contraindication` · **ไม่มี template ไหน render** (`SafetyDisclosures` โค้ดเดียวกันทุกแบรนด์ รับแค่ `safety`) · ตารางลูก `seo_entity_procedures.contraindications` ที่ backfill ไว้ตั้งแต่ ก.ค. ไม่มีใครเปิด · ผล: คนไข้ไม่เห็นสิ่งที่ควรเห็นก่อนจอง และ structured data บรรยายสิ่งที่ไม่มีบนจอ

```
vth     43 หน้ามี contraindication: ใน YAML · 174 ข้อ · render 0 หน้า
deezy  155 หน้ามี contraindication: ใน YAML · render 0 หน้า · เกตรันจริงจาก web/ ของ deezy 2026-09-18: 123 หน้า Live ไม่มีรายการในตาราง   ← คิวคุณ
smile    0 หน้า                                              ← port ได้ทันที
```

## สิ่งที่ vth ทำแล้ว (17–18 ก.ย.) — ใช้เป็นต้นแบบ

1. **ตาราง = store เดียว** · หน้าไม่เก็บสำเนา · ไซต์อ่านผ่าน bridge ที่ commit `src/data/entity-clinical.json`
2. **render** "ใครควรประเมินก่อน" ใต้ Safety บนหน้าที่ "เป็น" หัตถการ/อุปกรณ์เท่านั้น (Service · Procedure · Diagnostic · Technology) — ไม่ใส่บทความ · `schema.ts` ปล่อย array เดียวกัน → จอ == JSON-LD
3. **เกต `check:clinical`** ใน CI: bridge ล้าหลัง DB = FAIL · หน้า Live ที่ primary เป็น procedure/treatment/device/drug ไม่มีรายการ = FAIL (`--strict`) · YAML ยังมี `contraindication:` = FAIL (`--no-yaml`) · >15 ข้อ / ซ้ำ = FAIL
4. **เติม/ตรวจตาราง 2 รอบ**: 16 entity ที่ว่าง (117 ข้อ) + 24 entity ที่มีอยู่แล้ว (153 ข้อ: reword 70 · drop 5 · add 78) — reviewer อ่าน abstract จาก PubMed ทุกข้อ · SQL ให้ operator รันเอง
5. **มาตรฐานอนุมัติ = หลักฐานสากล** (operator): guideline องค์กรที่ยอมรับ / SR-MA / ข้อห้ามสัมบูรณ์สากล → อนุมัติเมื่อที่มาอยู่ใน `load_source` · ไม่ต้องเซ็นรายข้อ

ผล: 144 entity / 568 ข้อในตาราง · 57 หน้า render · 0 mismatch

## ⚠️ แถวแชร์ที่ vth แก้ — deezy/smile ตรวจว่ารับได้

| แถว | ใครโหลด | ทำอะไร |
|---|---|---|
| `deep-scaling` | deezy | 3 ข้อเดิม reword (ใส่ "ต้องทำอะไร") + เพิ่ม 3 |
| `scaling-polishing` | deezy | 2 ข้อเดิม reword + เพิ่ม 2 |
| `frenectomy` | smile (Planned page) | ยุบ `frenectomy-adult` ของ vth เข้า · รายการ 6 ข้อ · wikidata Q1953919 · summary ยาวกว่า |
| `cbct-scan` | deezy | ไม่แตะ — แต่มี list ทั้งใน procedures และ devices (bridge ใช้ procedures) |

**Addendum 18 ก.ย. (จาก deezy ผ่าน vth — session ของ smile ปิดอยู่ตอนแจ้ง):** deezy adopt แล้วในวันเดียว (eywa-deezy `1c9a226`, DZ-DR-072: 47 entity · 233 ข้อ · YAML 161 ไฟล์ลบ · เกต strict 0/0/0) และแตะแถวแชร์อีก 4: `full-mouth-rehab` (vth โหลดว่างไว้ → 6 ข้อ · vth รับ) · **`peri-implantitis-treatment` (smile โหลด → update)** · **`periodontal-treatment` (graph ของ smile ยังไม่มี ext row → insert)** · `dental-filling` (ไม่มีเจ้าของ → insert) — review copy `eywa-deezy/content-plan/contraindication-backfill-2026-09-18.md` · **smile-scape: ตรวจ 2 แถวของคุณ** ไม่เห็นด้วยข้อไหนแก้ที่ตารางแล้วแจ้ง

ข้อเท็จจริงเดิมอยู่ครบทุกแถว · review copy รายข้อ: `eywa-vth-biodent/content-plan/contraindication-backfill-2026-09-17.md` + `contraindication-review-r2-2026-09-18.md` · ไม่เห็นด้วยข้อไหน แก้ที่ตารางแล้วแจ้ง

## ทำอะไรในเว็บของคุณ

```bash
cd <brand>/web
node ../../eywa-protocol-spec/scripts/clinical-gates/check-clinical.mjs --brand <brand_id>
```
บรรทัดสุดท้ายบอกครบ: bridge (ยังไม่มี = FAIL) · หน้า Live ที่ไม่มีรายการ · สำเนา YAML

แล้วตาม checklist 6 ข้อใน `scripts/clinical-gates/README.md`: gen bridge → port `SafetyDisclosures` + 4 template + `schema.ts` (ต้นแบบ `eywa-vth-biodent/web/src/components/blocks/SafetyDisclosures.astro`, commit `4322f89` + `c6f4b77`) → ลบ `contraindication:` ใน YAML (+ ตัด safety ที่ซ้ำ) → เกตเข้า CI `--strict --no-yaml` → entity ที่เกตชี้ MISSING ใช้ `review-kit/`

## สิ่งที่ยังไม่ทำ (ทุกแบรนด์)

- `indication` — ตารางลูกไม่มีคอลัมน์ ยัง YAML + schema-only
- ชื่อคอลัมน์ drug (`contraindications_text`) ต่างจาก procedures/devices — bridge ซ่อนไว้ ไม่แก้ schema รอบนี้
- entity ชนิด condition/concept/specialty ไม่มีคอลัมน์ — หน้า service ที่ผูกไว้แบบนั้นต้องแก้ Page Master (vth เจอ 2)
