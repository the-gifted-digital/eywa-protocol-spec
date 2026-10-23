# 🕸️ Entity Identity SOP — ICD · Wikidata · Wikipedia → schema markup

**Version:** 1.0
**Status:** 🔒 Locked 2026-08-07
**Scope:** **UNIVERSAL** — ทุกแบรนด์ที่ใช้ `seo_entity_graph` และตาราง subtype
**Decision record:** DR-050 · แก้ไขโดย **DR-079** (2026-10-23: MeSH สำหรับ procedure/treatment/device, residual-code rule, ห้าม `--apply` แบบไม่อ่านผล) และ **DR-080** (2026-10-23: กฎตัดสิน `entity_type` §1.2, checklist merge/retype ฝั่ง brand repo §6.2)
**Reference implementation:** `eywa-vth-biodent/web/scripts/{verify-entity-ids,harvest-entity-codes,map-icd10-to-icd11,gen-entity-schema}.mjs`

---

## 0. ทำไมต้องมี SOP นี้

`name` บอกว่าเราเรียกสิ่งนั้นว่าอะไร — `code` กับ `sameAs` บอกว่ามัน **คือสิ่งไหน**

นั่นคือสัญญาณ disambiguation ที่ทั้ง Google และโมเดลที่ค้นข้อมูลใช้ตัดสินว่าหน้านี้พูดเรื่องอะไร แต่ด้วยเหตุผลเดียวกัน **identifier ที่ผิดแย่กว่าไม่มี** — มันไม่เงียบ มันประกาศว่าหน้านี้พูดเรื่องอื่น ในรูปแบบที่เครื่องอ่านได้

หน้าโปรแกรมลดการอักเสบที่มี `sameAs` ชี้ไป **Persona 4** ไม่ใช่ข้อมูลขาด แต่เป็นข้อมูลผิดที่ประกาศออกไปแล้ว

---

## 1. One store per fact

| entity_type | เจ้าของรหัส | คอลัมน์ |
|---|---|---|
| **condition** | `seo_entity_condition` | `icd10_code` (WHO) · `icd10_cm_code` (CM) · `icd11_code` (MMS) · `mesh_id` · `umls_cui` · `snomed_ct_id` |
| **symptom** | `seo_entity_symptom` | `icd10_code` · `icd11_code` · `mesh_id` · `umls_cui` · `snomed_ct_id` |
| **anatomy** | `seo_entity_anatomy` | `fma_id` · `uberon_id` · `mesh_id` |
| **lab_test** | `seo_entity_lab_test` | `loinc_code` · `snomed_ct_id` · `mesh_id` — 🔴 **กฎนี้ยังยิงไม่ออก:** ตารางมี 0 แถว และ `seo_entity_graph` ไม่มี entity ชนิด `lab_test` เลยสักตัว *(corrected 2026-08-24 against live schema)* |
| **drug** | `seo_entity_drug` | `rxnorm_code` · `atc_code` · `mesh_id` |
| **procedure · treatment** | `seo_entity_procedures` | `mesh_id` เท่านั้น — **ไม่มีรหัส ICD** (DR-079) |
| **device** | `seo_entity_devices` | `mesh_id` เท่านั้น — **ไม่มีรหัส ICD** (DR-079) |

`seo_entity_graph` เก็บได้เฉพาะ `wikidata_id` · `wikipedia_url` · `schema_org_type`
คอลัมน์ `seo_entity_graph.icd_10_code` **ปลดระวางแล้ว** (เคยเก็บค่า ICD-10-CM ปนกับ WHO ICD-10 ที่อยู่อีกตาราง)
คอลัมน์ยังไม่ถูก drop — ยังอยู่ในตารางและ NULL ครบ 732/732 แถว ส่วน **คอมเมนต์ของคอลัมน์ใน DB ยังบรรยายว่าใช้งานอยู่** ("Emitted in MedicalCondition.code[]") ยังไม่ได้อัปเดตตาม DR-050 — คนอ่าน `\d+` จะเข้าใจผิด *(corrected 2026-08-24 against live schema)*

### 1.1 ทำไม procedure / treatment / device ห้ามมี ICD (และ MeSH ใช้แทน — DR-079)

รหัสที่มักไปติดอยู่คือรหัสของ **โรคที่รักษา** ไม่ใช่ตัวตนของหัตถการ ตัวอย่างจริง:

| entity | รหัสที่ติดอยู่ | ที่จริงคือ |
|---|---|---|
| Dental Scaling | K03.6 | คราบหินปูน (โรค) |
| Wisdom Tooth Removal | K01.1 | ฟันคุด (โรค) |
| Dental Filling | K02.9 | ฟันผุ (โรค) |
| Bisphosphonates | Z79.83 | รหัส**สถานะผู้ป่วย**ที่ใช้ยานั้น |

ถ้าปล่อยไว้แล้วต่อเข้า schema หน้าบริการจะประกาศ `MedicalCondition.code` ของโรคที่หน้านั้นไม่ได้พูดถึง
ให้ย้ายเป็นความสัมพันธ์: `seo_entity_procedures.treats_conditions_fps`

> **DR-079 (2026-10-23): MeSH เป็น identifier ของ procedure / treatment / device** — คอลัมน์ `mesh_id` บน `seo_entity_procedures` และ `seo_entity_devices` (CHECK `^[DC][0-9]{6,9}$`, descriptor `D…` หรือ supplementary concept `C…`, ไม่มี prefix). `mesh_id` ต้องระบุ **ตัวหัตถการ/อุปกรณ์เอง ไม่ใช่โรคที่รักษา** (กฎเดียวกับตารางข้างบน); ชื่อแบรนด์/ผลิตภัณฑ์ไม่มี MeSH. เลือก MeSH เพราะ ICD-11 ไม่มี chapter ของหัตถการ.
> **รหัสยังอยู่ใน store เดิมของ DR-050** — ข้อเสนอตาราง `seo_entity_codes` ใหม่ถูกปฏิเสธเพราะซ้ำกับ "one store per fact".
> ตัวเลข "1 จาก 741 entity มี ICD" ใน handover วัดคอลัมน์ `seo_entity_graph.icd_10_code` ที่ปลดระวางแล้ว ไม่ใช่ความครอบคลุมจริง (จริง: ICD-10 91/118 conditions ก่อนรอบ DR-079; หลังรอบ: active conditions ICD-10 (WHO) 78/115 · ICD-11 71 · MeSH 87; procedures MeSH 69 · devices 15).
> คอลัมน์ `icd10_code` (WHO) ต้องเป็น **WHO ICD-10 เท่านั้น ยาวไม่เกิน 4 ตัวอักษร** — รหัส CM-only (G47.63, R06.83, K08.89, Z91.041 ...) อยู่ใน `icd10_cm_code` (DR-079)

### 1.2 กฎตัดสิน `entity_type` — act หรือ object? (DR-080)

`entity_type` กำหนดว่า entity ผูกกับตาราง ext ไหน (และ MeSH/ICD ใช้ช่องไหน) จึงต้องตัดสินให้ตรงตัวตนจริง ไม่ใช่ตามที่ keyword พูดถึง

| ถ้า entity คือ | ใช้ type | ตาราง ext |
|---|---|---|
| **การกระทำที่ทำ** (หัตถการ/การรักษา) | `procedure` หรือ `treatment` | `seo_entity_procedures` |
| **วัตถุจับต้องได้** — อุปกรณ์ เครื่อง เครื่องมือ วัสดุ หรือ implant/prosthesis ที่เป็น variant ตามวัสดุ/ยี่ห้อ | `device` | `seo_entity_devices` |
| **วัสดุ** (เซรามิก ทองคำ ฯลฯ) | `device` (ไม่มี type วัสดุ; `ingredient` คือสารออกฤทธิ์ของ skincare เท่านั้น) | `seo_entity_devices` |
| **ซอฟต์แวร์ที่เป็น medical device ตามกฎหมาย** (FDA/CE-cleared เช่น nemostudio, dental-monitoring-ai) | `device` — เพราะ `technology` ไม่มีตาราง ext | `seo_entity_devices` |
| ชื่อชุดบริการ/โปรแกรม/แดชบอร์ดของแบรนด์ | `concept` (ดู §8: ไม่มี identifier) | ไม่มี |

**เมื่อชื่อเดียวมีสองความหมาย** (เช่น `mad` = Mandibular Advancement Device เป็นทั้งเครื่องมือและการรักษา): ถ้ามี entity อื่นถือความหมายด้านหนึ่งอยู่แล้ว (เช่น `oral-appliance-therapy` ถือด้านการรักษา) ให้ entity นี้เป็นด้านที่เหลือ — **umbrella ไม่ถูกตั้ง type ผิดเพียงเพราะมีลูกเป็นอีกประเภท**

**ข้อยกเว้นที่ตัดสินแล้ว (operator, 2026-10-23 — เลื่อนไว้ทบทวน):**
- umbrella service entities (`dental-implant`, `dental-crown`, `dental-veneer`, `denture`, `clear-aligner` ...) คงเป็น `treatment` แม้ MeSH/Wikidata id ของมันจะชี้ที่ตัววัตถุ
- lab test ที่เก็บเป็น `procedure` (inflammation-panel, genetic-testing, microbiome-testing ...) รอ rollout ของ `lab_test`
- `space-maintainer` คงเป็น `treatment` (MeSH D013027 คือหัตถการ)

**รอบแรกที่ใช้กฎนี้ (W3.6, 12 entity):** mad, gold-crown, ssc-pedo, orthodontic-retainer, thermoformed-aligner, dental-autoclave, opg-machine, intraoral-scanner, dental-laser → `device`; dental-photography → `procedure`; pncl-dashboard → `concept`; dental-anxiety-child → `condition`. แถว ext ย้ายตาม type (คง `mesh_id` / `contraindications`)

**เศษที่ยังไม่แก้:** cbct-scan (procedure) มีแถว device ext หลงอยู่; gum-swelling (symptom) มีแถว condition ext หลงอยู่; device 9 ตัวยังไม่มีแถว device ext (3d-printer-aligner, acteon-cbct, cool-light-whitening-unit, densah-bur, endodontic-microscope, ptfe-membrane, rotary-endodontic-system, rpm-membrane, trios-intraoral-scanner)

ผลข้างเคียงของการเปลี่ยน type: ไม่มี DB constraint ใดอ่าน `entity_type` นอกจาก `chk_concept_subtype` แต่ output เหล่านี้เปลี่ยน — `v_seo_keyword_pool`, `v_seo_entity_inventory`, `dz_dash_graph()`; SmileScape derive `page_type` จาก primary entity type; Deezy `src/lib/schema.ts` เทียบ @type กับ `entity_type`. entity ส่วนใหญ่ shared (`brand_scope` `*`) จึงต้อง broadcast (DR-046)

---

## 2. สามด่านก่อนเขียน `wikidata_id`

> Q-number คือข้อความสี่ตัวอักษรที่ดูน่าเชื่อเสมอ ไม่มี schema ไหนกันค่าผิดได้

### ด่าน 1 — label ต้องตรง

label หรือ alias ภาษาอังกฤษของ item ต้องตรงกับชื่อ entity (ถอดวงเล็บออกแล้ว)

**ห้ามค้นด้วยชิ้นส่วนสั้น** — ตัวย่อและคำเดี่ยวทั่วไปคือทางที่พาไปผิด:

| ชิ้นส่วนที่ใช้ค้น | ไปเจอ |
|---|---|
| `MBM` | meat and bone meal |
| `TMJ` | Termez Airport (รหัสสนามบิน) |
| `umbrella` (จาก "Denture (umbrella)") | Umbrella |
| `senior` | senior |
| `EMax` | ห้างสรรพสินค้าในฮ่องกง |

เกณฑ์ที่ใช้จริง: variant ต้องมีอย่างน้อยสองคำ หรือยาวอย่างน้อย 9 ตัวอักษร

### ด่าน 2 — item ต้องเป็นของทางการแพทย์จริง

สำหรับ entity ชนิด `condition` `symptom` `procedure` `treatment` `drug` `anatomy` `lab_test`
item ต้องมี identifier ทางการแพทย์อย่างน้อยหนึ่งตัว:

```
P494 (ICD-10) · P4229 (ICD-10-CM) · P7807 (ICD-11 Foundation) · P486 (MeSH)
P2892 (UMLS CUI) · P5806 (SNOMED CT) · P1550 (Orphanet) · P667 (ICPC) · P672 (MeSH tree) · P3345 (RxNorm)
```

ด่านนี้ปัดตก 63 ตัวในรอบแรกของ VTH รวมถึง Persona 4 และสนามบิน Termez

### ด่าน 3 — Q-id หนึ่งตัว ต่อ entity เดียว

สอง entity อ้าง item เดียวกัน = ความขัดแย้งในตัวเอง เพราะ `sameAs` แปลว่า "คือสิ่งเดียวกัน"
และเป็น **สัญญาณว่า entity ซ้ำกัน** ให้เข้าคิว merge ตาม DR-042

ตัดสินว่าใครเก็บ id ไว้ด้วย **จำนวนหน้าที่ใช้ entity นั้นจริง** ไม่ใช่ลำดับการสร้าง

### 2.1 สิ่งที่ห้ามทำอัตโนมัติ

**ตัวที่ผ่านด่าน 1 แต่ตกด่านอื่น ห้าม auto-clear** — ส่วนใหญ่คือกรณีที่ชื่อของเราเป็นเวอร์ชันขยายของ Wikidata ซึ่ง **ถูกต้อง**:

| ของเรา | Wikidata | ตัดสิน |
|---|---|---|
| Deep Cleaning (Scaling & Root Planing) | scaling and root planing | ✅ เก็บ |
| Mandibular Advancement Device | Mandibular advancement splint (alias "Oral appliance") | ✅ เก็บ |
| Chronic Nasal Obstruction | nasal congestion (alias "nasal obstruction") | ✅ เก็บ |
| Pacemaker & Implanted Devices | artificial pacemaker | ❌ ตัด — เราคือขั้นตอนคัดกรอง ไม่ใช่ตัวเครื่อง |
| Multiple Missing Teeth | edentulism | ❌ ตัด — edentulism คือฟันหายทั้งปาก |
| Forward Head Posture Correction | iHunch (ภาวะ) | ❌ ตัด — treatment ไม่ใช่ condition ที่มันรักษา |

**บันทึกคำตัดสินไว้ในสคริปต์** (`ADJUDICATED_KEEP`) เพื่อไม่ให้รอบหน้าถกซ้ำ

---

## 3. เก็บรหัสจากต้นทาง ไม่ใช่เดา

### 3.1 จาก Wikidata (เมื่อ Q-id ผ่านสามด่านแล้ว)

รหัสบน item เป็น sourced statement อยู่แล้ว → copy ได้

| property | ปลายทาง |
|---|---|
| P4229 | `icd10_cm_code` |
| P494 | `icd10_code` |
| **P7329 (ICD-11 MMS)** → fallback **P7807 (Foundation)** | `icd11_code` |
| P486 · P2892 · P5806 | `mesh_id` · `umls_cui` · `snomed_ct_id` |
| P1402 · P1554 | `fma_id` · `uberon_id` |
| P4338 · P267 · P3345 | `loinc_code` · `atc_code` · `rxnorm_code` |

> ⚠️ P7329 คือ **MMS** ซึ่งเป็นรหัสที่คนอ้างจริง (`DA0E.3`) · P7807 คือ **Foundation** ซึ่งเป็นเลขยาว (`1109546957`) ใช้เป็น fallback เท่านั้น — ตรวจ property กับ API ก่อนใช้เสมอ อย่าจำเอา
> fallback นี้ **ลงจริงแล้ว 7 แถว** (condition 5 · symptom 2 เป็นเลขล้วน) ทั้งที่คอมเมนต์ของคอลัมน์ `icd11_code` ใน DB ระบุว่าเป็น `ICD-11-MMS stem code` และ JSON-LD จะประกาศ `codingSystem="ICD-11-MMS"` — ยังไม่มีคำตัดสินว่าจะย้ายหรือทิ้ง *(corrected 2026-08-24 against live schema)*

**ความครอบคลุมจริงของแต่ละ mapping — วัด 2026-08-24** (รันใหม่ได้ด้วย `count(*) filter (where <col> is not null)` ต่อตาราง):

| ตาราง (แถว) | ค่าที่เติมแล้ว |
|---|---|
| `seo_entity_graph` (732) | `wikidata_id` 158 · `wikipedia_url` 128 |
| `seo_entity_condition` (125) | `icd10_code` 97 · `icd10_cm_code` 109 · `icd11_code` 73 · `mesh_id` 41 · `umls_cui` 43 · `snomed_ct_id` 5 |
| `seo_entity_symptom` (21) | `icd10_code` 19 · `icd11_code` 8 · `mesh_id` 7 · `umls_cui` 6 · `snomed_ct_id` 1 |
| `seo_entity_anatomy` (21) | `fma_id` 15 · `uberon_id` 18 · `mesh_id` 16 |
| `seo_entity_drug` (9) | `rxnorm_code` 2 · `atc_code` 4 · `mesh_id` 5 |
| `seo_entity_lab_test` (0) | 🔴 ไม่มีแถว — แถว P4338 → `loinc_code` ในตารางข้างบนจึงไม่เคยทำงาน |

### 3.2 จาก WHO — ICD-10 → ICD-11

**WHO ICD API ต้องมี OAuth credentials** (คืน 401 ถ้าไม่มี)
แต่ WHO เผยแพร่ตารางเทียบสาธารณะ **ไม่ต้อง auth**:

```
https://icdcdn.who.int/static/releasefiles/<release>/mapping.zip
  → 10To11MapToOneCategory.txt   (2024-01 = 12,301 รหัส)
```

เป็นการ **แปลระหว่างสองรุ่นของการจำแนกเดียวกัน โดยผู้ออกมาตรฐานเอง** ไม่ใช่การเดา

**CM → WHO:** ICD-10-CM มีหลักมากกว่า WHO (`K05.30` vs `K05.3`) ให้ตัดลงหา WHO parent

### 3.3 ห้ามทับค่าเดิม

ค่าที่มีอยู่ชนะเสมอ ความขัดแย้งให้ **รายงาน** ไม่ใช่เขียนทับ — กฎนี้พิสูจน์ตัวเองทันทีที่รันครั้งแรก:

| entity | ของเรา | Wikidata |
|---|---|---|
| periodontitis | K05.30 | `K05.205.2,K05.305.3` ← สตริงพังจากการต่อค่า |
| dental caries | K02.9 | `K0202.` ← พังเหมือนกัน |
| nickel allergy | Z91.041 (สถานะแพ้) | L23.0 (ผื่นสัมผัส) |

**ข้อยกเว้นเรื่อง notation:** FMA/UBERON ของเราเก็บพร้อม prefix (`FMA:54832`) ส่วน Wikidata เก็บเลขเปล่า — เป็นคนละ notation ของข้อมูลเดียวกัน ให้เทียบแบบไม่สนใจ prefix ไม่งั้นจะได้ conflict ปลอม

---

## 4. ห้ามใช้ residual code

ICD-10 ที่ลงท้าย `.8 other specified` / `.9 unspecified` จะแมปไปถังเศษของ ICD-11:

| entity | ICD-10 | ICD-11 ที่ได้ | ปัญหา |
|---|---|---|---|
| snoring | R06.8 | MD11.Z "Abnormalities of breathing, **unspecified**" | ประกาศรหัสวินิจฉัยแต่ไม่บอกอะไร |
| brain fog (oral) | R41.8 | MB21.0 "Age-associated cognitive decline" | เจาะจง แต่**เจาะจงผิด** |
| orofacial paresthesia | R20.2 | MB40.4 "Tingling **fingers or feet or toes**" | คนละส่วนของร่างกาย |

**กฎ:**
1. ปฏิเสธทุกผลที่ title ตรงกับ `/unspecified|other specified|not elsewhere classified/i`
   - **ข้อยกเว้น (DR-079, operator 2026-10-22):** ICD-10 "other" (`.8`) ใช้ได้เมื่อ **WHO ระบุ concept ของ entity ตามชื่อเป็น inclusion term** — F45.8 "Teeth-grinding" (bruxism) · F98.8 "Thumb-sucking" (oral habits) · K08.8 "Toothache NOS" · K03.8 "Sensitive dentine". ส่วน "unspecified" / `.Z` / `.Y` ยังห้ามเหมือนเดิม
2. **ห้ามแมประดับ category สามหลัก** — `G47 → "Sleep-wake disorders, unspecified"` จริงกับทั้ง insomnia · apnea · bruxism พร้อมกัน ใส่เป็นรหัสของหน้าใดหน้าหนึ่งคือคำกล่าวที่ไม่มีเนื้อหา
3. ตัวที่ title เจาะจงแต่ผิดเรื่อง ตัวกรองอัตโนมัติมองไม่เห็น → ต้องมีรายการ `REFUSED` ที่คนตัดสิน

---

## 5. ต้องไปถึงหน้าเว็บ

รหัสที่นอนอยู่ใน DB ไม่มีค่าจนกว่าจะออกใน JSON-LD

**สัญญา:** export เป็น JSON ที่ **commit ไว้** แล้ว build อ่านอย่างเดียว — รูปแบบเดียวกับ `internal-links.json` (build ไม่แตะเน็ตเวิร์ก)

```json
"code":   { "@type": "MedicalCode", "code": "M26.69", "codingSystem": "ICD-10" },
"sameAs": ["https://www.wikidata.org/wiki/Q936070", "https://en.wikipedia.org/wiki/Trismus"]
```

**การ์ดสองชั้นตอน render:**

1. `code` ออกเฉพาะ node ชนิดที่รหัสมีความหมาย: `MedicalCondition` · `MedicalProcedure` · `Service` · `MedicalDevice`
   — Offer · quiz · หน้าสาขา · หน้าหมอ **ไม่ใช่การวินิจฉัย** การใส่ `code` ลงไปคือการประกาศเท็จว่าหน้านั้นคืออะไร
2. `sameAs` ข้าม `Person` (หน้าหมอมี profile ของตัวเองอยู่แล้ว) และ **ห้ามทับ** ค่าที่เทมเพลตตั้งไว้

---

## 6. ลำดับงาน (บังคับตามนี้)

```
1.  verify:entity-ids            ← สามด่าน · report ก่อน · **ห้าม --apply proposal โดยไม่มีคนอ่าน** (ดู 6.1)
2.  (คนตัดสิน)                   ← label mismatch + Q-id ชนกัน → บันทึกลง ADJUDICATED_KEEP
3.  harvest:entity-codes         ← เก็บรหัสจาก item ที่ verify แล้ว · never-overwrite
4.  map:icd11                    ← เติม ICD-11 ที่ยังว่างจากตารางเทียบ WHO
5.  gen:entity-schema            ← export JSON ที่ commit
6.  build + ตรวจหน้าจริง          ← ยืนยันว่า code/sameAs ออกใน JSON-LD
```

ลำดับ 1 ต้องมาก่อน 3 เสมอ — **ทุกรหัสในขั้น 3 สืบทอดความถูกต้องของ Q-id ในขั้น 1**

### 6.1 ห้าม `verify-entity-ids --apply` โดยไม่อ่านผล (DR-079 · W3.2b, 2026-10-22)

`--apply` เขียน **ทุก** "proposed" id. รอบ `--all` 2026-10-22 มี proposal 21 รายการ **ผิด 12** — ห้างสรรพสินค้าฮ่องกง (emax-material), วารสาร (pediatric-dentistry, implantologist), "osteoporosis" สำหรับ alveolar-bone-loss, "anatomy" สำหรับ tooth-anatomy, บทความปี 1991 สำหรับ omfs. ให้ตัดสิน id ด้วยมือตามสามด่านใน §2 (อ่าน label + description) แล้วเขียนผ่าน migration ที่ **ไม่ทับค่าเดิม** (`wikidata_id` ต้องว่าง) — ดู `migrations/2026-10-22_w32b_wikidata_adjudicated.sql`. id เดิมที่ชี้ผิดต้อง clear (เช่น periodontal-surgery → "pedicled flap"). สคริปต์ harvest/verify ข้าม entity ที่เป็น `Merged`/`Dropped` และ harvest ปฏิเสธ Wikidata code ที่ผิดรูป

### 6.2 Checklist เมื่อ merge / retype entity — ต้องจบในรอบเดียวกัน (DR-080)

บทเรียนจาก DR-079 W3.1: merge entity ใน Supabase แล้ว deploy gate ของ vth-biodent แดง เพราะ brand repo ยังชี้ entity เดิม. ทุกครั้งที่ **merge หรือ retype** entity ต้องทำครบก่อนถือว่าเสร็จ:

```
1.  แก้ YAML entity bindings / bridge files ใน brand repo ให้ชี้ fp ของ winner (merge) หรือ type ใหม่ (retype)
2.  regenerate JSON ที่ brand สร้างจาก graph: entity-labels · entity-schema · entity-clinical · entity-codes
3.  รัน gate ของ brand (เช่น vth `check:clinical`) ให้ผ่านก่อน push
4.  broadcast ถึงทุก brand ที่ entity อยู่ใน scope (entity shared → DR-046)
```

อย่าทิ้ง "regenerate ทีหลัง" — ถ้า graph เปลี่ยนแล้ว brand ยังไม่ regenerate gate จะแดงตอน deploy ครั้งถัดไป ไม่ใช่ตอนที่เปลี่ยน

---

## 7. QA gates (ต้องได้ 0 ทุกข้อ)

```sql
-- Q-id ซ้ำข้าม entity (ด่าน 3)
select count(*) from (select wikidata_id from seo_entity_graph
  where wikidata_id is not null group by 1 having count(*)>1) x;

-- รหัสอยู่ผิดชนิด
select count(*) from seo_entity_graph where icd_10_code is not null;   -- คอลัมน์ปลดระวางแล้ว

-- subtype row ที่ไม่มี entity รองรับ
select count(*) from seo_entity_condition c
  where not exists (select 1 from seo_entity_graph e where e.entity_fingerprint=c.entity_fp);
-- (ทำซ้ำกับ symptom · anatomy · drug · lab_test · organization · procedures · devices
--  · product · ingredients — สองตารางท้ายมีจริงในสคีมาแต่ยัง 0 แถว วัด 2026-08-24)

-- Q-id ที่ไม่ใช่รูปแบบ Q<ตัวเลข>
select count(*) from seo_entity_graph where wikidata_id is not null and wikidata_id !~ '^Q[0-9]+$';

-- residual code หลุดเข้ามา
select count(*) from seo_entity_condition where icd11_code ~ '\.Z$';
-- ^ backslash เดียว: `standard_conforming_strings = on` บนฐานนี้ ทำให้ '\\.Z$' กลายเป็น regex
--   ที่หา backslash จริง → คืน 0 เสมอ เกตผ่านทั้งที่ไม่ได้ตรวจอะไร
--   ตรวจสดแล้ว: 'MD11.Z' ~ '\.Z$' = true · 'MD11.Z' ~ '\\.Z$' = false
--   *(corrected 2026-08-24 against live schema)*
```

วัดจริง 2026-08-24 — ทั้งห้าเกตคืน **0** ครบ (`seo_entity_graph` 732 แถว · Q-id ซ้ำ 0 · Q-id ผิดรูป 0 · `icd_10_code` not null 0 · orphan subtype 0 ทุกตาราง · residual `.Z` 0 เมื่อรันด้วย regex ที่แก้แล้ว) *(corrected 2026-08-24 against live schema)*

---

## 8. สิ่งที่ **ไม่ควร** มี identifier

| กลุ่ม | ตัวอย่าง | เหตุผล |
|---|---|---|
| ชื่อโปรแกรมของแบรนด์ | `mbm-*` · `breath-face-brain-*` · `pncl-*` · `structural-facial-longevity-program` | ไม่มีในสารานุกรม (slug `bfb` ไม่มีอยู่จริง แต่ตระกูลนี้มี **สองแถว** ไม่ใช่แถวเดียว: `breath-face-brain-method` "Breath·Face·Brain Method" และ `breath-face-brain-stages` "BFB 4-Stage Sequence" — ทั้งคู่ `brand_scope={vth-biodent}` *(corrected 2026-08-24 against live schema)*) |
| ชื่อรุ่น/ยี่ห้อเครื่องมือ | `nemostudio` · `x-guide-dynamic-navigation` · `fotona-lightwalker` · `aoralscan` | เดียวกัน (ยกเว้นบริษัทผู้ผลิตซึ่งมี item จริง — slug `x-guide` เปล่า ๆ ก็ไม่มีอยู่จริงเหมือน `bfb` ตัวที่มีคือ `x-guide-dynamic-navigation` *(corrected 2026-08-24 against live schema)*) |
| concept ทางการตลาด | `retest-protocol` · `pncl-dashboard` | เดียวกัน |
| `person` | ทีมแพทย์ของแบรนด์ | ใช้ `sameAs` ของหน้าโปรไฟล์แทน |

`seo_entity_graph` เป็นตาราง **ที่ใช้ร่วมกันทุกแบรนด์ ไม่ใช่ของ VTH** — วัด 2026-08-24 มี 732 แถว (665 แถว `brand_scope = '{*}'` · เฉพาะ vth-biodent 38 · smile-scape-clinic 25 · deezy-dental 4) และ **574 แถวไม่มี `wikidata_id`**

ตัวเลขนี้ขยับทุกรอบ harvest → ให้รันเอา ไม่ต้องอ้างค่าคงที่:
`select count(*) from seo_entity_graph where wikidata_id is null;`

ส่วน "306 จาก 715" ของ 2026-08-07 คือ **ส่วนย่อยที่คนตัดสินแล้วว่าว่างถูกแล้ว** ซึ่งไม่มี query ไหนคืนค่าได้เอง (ต้องอ่านชื่อทีละตัวว่าเข้ากลุ่มไหนในตารางข้างบน) จึงตรวจซ้ำอัตโนมัติไม่ได้ *(corrected 2026-08-24 against live schema)*

ที่เหลือยังเหมือนเดิม: entity กลุ่มนี้ **ถูกต้องแล้วที่ว่าง** — การบังคับให้มีคือทางที่ทำให้โปรแกรมลดการอักเสบไปชี้ Persona 4

---

## 9. Change control

แก้ SOP นี้ได้เมื่อมี DR ใหม่อ้างถึงเท่านั้น · เพิ่มบทเรียนจากการรันจริงได้โดยไม่ต้องมี DR แต่ต้องระบุแบรนด์ + วันที่ + หลักฐาน

- **2026-10-23 · DR-080:** §1.2 กฎตัดสิน `entity_type` (act = procedure/treatment, object = device, วัสดุ/software medical device = device, umbrella ไม่ตั้งผิด) + ข้อยกเว้นที่เลื่อน · §6.2 checklist merge/retype ต้อง update brand repo bindings + regenerate entity JSON + รัน brand gate ในรอบเดียวกัน
- **2026-10-23 · DR-079:** §1 procedure/treatment/device → `mesh_id` (ตาราง ext ของตน) · §1.1 note รหัสคง store เดิม + ความครอบคลุมจริง · §4 residual-code rule (".8" ที่ WHO ระบุตามชื่อ) + `icd10_code` = WHO ≤ 4 ตัวอักษร · §6.1 ห้าม `--apply` แบบไม่อ่านผล. (header ของ migration เรียก DR นี้ว่า DR-078 = renumbered)
