<!--
═══════════════════════════════════════════════════════════════════════
  Section 2 Pattern Reference — All 25 Templates
  
  Companion to: Content_Templates_EYWA_v1_0.md (B02 spec)
  Purpose: Concrete render examples of Section 2 across every template type
  Status: Approved 2026-05-10 (operator review)
  
  Pattern principle:
  - 5 essentials always visible (reader-centric hooks)
  - Toggle "▶ ข้อมูลทางเทคนิค (สำหรับผู้สนใจเชิงลึก)" for codes/specs
  - Template-specific icons + question labels
  - Some templates use alternative blocks (not Quick Facts)
  - Some templates skip Section 2 entirely
═══════════════════════════════════════════════════════════════════════
-->

# Section 2 — Pattern Reference (All 25 Templates)

> **For content writers + designers + dev:** Concrete render examples ของ Section 2 ในทุก template type. ใช้เป็น visual reference ตอนเขียน content + implement ACF field groups.

**Version:** v1.0 (2026-05-10)
**Companion to:** Content_Templates_EYWA_v1_0.md §2.1 B02 spec
**Status:** Approved — locked in DR-020 review cycle

---

## 📋 Quick Index

| Group | Templates | Section 2 Pattern |
|-------|-----------|-------------------|
| **A. Quick Facts (5+toggle)** | T1, T2, T2a, T2b, T2c, T2d, T2e, T3, T4, T6 (optional), T6a, T7, T12, T14, T15, T17 | Standard 5-essential + toggle |
| **B. Alternative Block** | T8, T9, T10, T18 | Different block (patient/credentials/address/branch) |
| **C. Skip Section 2** | T11, T13, T19 | No Quick Facts (different page structure) |

---

## 🅰️ Group A — Quick Facts Pattern (5-essential + toggle)

### T1 — Medical Condition (โรค/ภาวะ)

```
**โรคหยุดหายใจขณะหลับชนิดอุดกั้น** | Obstructive Sleep Apnea (OSA)

| 👤 ใครเสี่ยง?     | ชาย 30-60 ปี, BMI ≥ 25, retrognathia                    |
| 🔍 รู้ได้อย่างไร? | PSG หรือ Home Sleep Test + CBCT airway analysis        |
| 💊 รักษาได้ไหม?   | Oral Appliance, CPAP, ผ่าตัด, ปรับพฤติกรรม              |
| ✅ ตรวจสอบโดย    | ทพ. ดร. อมรพงษ์ — ABDSM Certified                       |

▶ ข้อมูลทางเทคนิค (ICD/SNOMED/MeSH/ความชุก/Specialty)
```

### T2 — Medical Procedure (Generic)

Example: Shockwave Therapy for ED at Trin Wellness

```
**Shockwave Therapy สำหรับ ED** | Low-Intensity Shockwave (LiSWT)

| 👤 ใครเหมาะ?         | ชาย 40+ ที่มี ED แบบ vascular cause / ไม่ตอบสนองยา PDE5i |
| ⏱️ ใช้เวลานานแค่ไหน? | 20-30 นาที/ครั้ง — total 6-8 ครั้ง (~6 สัปดาห์)             |
| 🩹 พักฟื้นนานแค่ไหน? | ไม่ต้องพักฟื้น — กลับกิจวัตรได้ทันที                         |
| ✅ ตรวจสอบโดย       | ดร.นพ. ตฤณ กระแสสังข์ — ABRAM, 20+ ปี                    |

▶ ข้อมูลทางเทคนิค (procedure type, anesthesia, contraindications, อัตราตอบสนอง)
```

### T2a — Aesthetic Procedure

Example: EMFACE at TC Smile / Estique

```
**EMFACE — ไฟฟ้ากระตุ้นยกกระชับใบหน้า** | EMFACE by BTL

| 👤 ใครเหมาะ?          | อายุ 30+ ต้องการกระชับใบหน้าโดยไม่ผ่าตัด, ไม่กลัวเข็ม         |
| ⏱️ ใช้เวลานานแค่ไหน?  | 20 นาที/ครั้ง — total 4 ครั้ง (1/สัปดาห์)                    |
| 😊 มี downtime ไหม?  | ไม่มี — กลับเข้าสังคมได้ทันที                                 |
| 📅 ผลเห็นเมื่อไหร่?    | เริ่มเห็นหลัง session 2, peak 3 เดือนหลังครบ                 |
| ✅ ตรวจสอบโดย         | นพ. ___ — Diplomate of Aesthetic Medicine                   |

▶ ข้อมูลทางเทคนิค (FDA, maintenance schedule, contraindications)
```

**Note:** T2a มี 5 essentials (เพิ่ม "ผลเห็นเมื่อไหร่?") เพราะ aesthetic patients ต้องการรู้ timeline ก่อนตัดสินใจ

### T2b — Dental Procedure

Example: Dental Implant Blue Diamond at SmileScape

```
**รากฟันเทียม Blue Diamond** | Dental Implant (Blue Diamond Korea)

| 👤 ใครเหมาะ?       | ผู้สูญเสียฟัน 1+ ซี่, มีกระดูกเพียงพอ (หรือเสริมได้)             |
| 🦷 กี่ครั้งกี่นัด?    | 3-5 visits ใน 3-6 เดือน                                     |
| 🔧 วัสดุ           | ไทเทเนียมเกรด 4 (Blue Diamond) + ครอบ Zirconia              |
| 🛡️ การรับประกัน    | ตลอดชีพ — เปลี่ยนรากใหม่ฟรีถ้ามีปัญหา                       |
| ✅ ตรวจสอบโดย     | ทพ. วรภัทร จรางกุล (หมอแฮม) — M.Sc. Implantology              |

▶ ข้อมูลทางเทคนิค (ADA code, anesthesia, อัตราสำเร็จ, แบรนด์ทางเลือก)
```

### T2c — Wellness Program

Example: Men's Vitality 12-Week at Trin Wellness

```
**Men's Vitality Holistic Program** | 12-Week Men's Health Reset

| 👤 ใครเหมาะ?           | ชาย 35+ มี ED, fatigue, low libido, brain fog                |
| 📅 โปรแกรมนานแค่ไหน?   | 12 สัปดาห์ — 4 phase (Diagnostic → Reset → Build → Maintain) |
| 🎯 ผลลัพธ์ที่คาดหวัง    | Hormonal balance, vascular function, recovery ED, energy boost |
| 🔄 ดูแลต่อเนื่อง       | Quarterly checkup ปีที่ 1, ทุก 6 เดือนหลังจากนั้น              |
| ✅ ตรวจสอบโดย         | ดร.นพ. ตฤณ กระแสสังข์ — ABRAM Certified                       |

▶ ข้อมูลทางเทคนิค (services bundled, exclusions, eligibility, total cost range)
```

### T2d — Physiotherapy / Rehab

Example: PRP for Knee OA at Trin Wellness

```
**PRP สำหรับข้อเข่าเสื่อม** | Platelet-Rich Plasma for Knee OA

| 👤 ใครเหมาะ?          | อายุ 50+, OA grade 1-3, ไม่ต้องการผ่าตัด                      |
| 🎯 เป้าหมาย           | ลดปวด 50-70%, เพิ่ม ROM, ชะลอการเสื่อม, เลื่อนผ่าตัด           |
| 🔁 ความถี่             | 2-3 sessions ห่างกัน 4-6 สัปดาห์ + booster ทุก 6-12 เดือน     |
| 🏃 กลับเดินได้เมื่อไหร่? | เดินได้ทันที, ออกกำลังเบาภายใน 24-48 ชม.                     |
| ✅ ตรวจสอบโดย         | ดร.นพ. ตฤณ — Vascular & Regenerative Medicine                |

▶ ข้อมูลทางเทคนิค (PRP concentration, technique, contraindications, อัตราตอบสนอง)
```

### T2e — Genomic / Precision Test

Example: Cardiovascular Genomic Panel at Genowell

```
**Cardiovascular Genomic Panel** | DNA-Based Heart Disease Risk Assessment

| 👤 ใครเหมาะ?          | อายุ 30+, มีประวัติครอบครัว CV disease, proactive screener  |
| 🧬 ตรวจอะไรบ้าง?      | 25+ genes — lipid metabolism, BP regulation, clotting        |
| 💉 เก็บตัวอย่างยังไง?   | น้ำลาย (saliva) — เก็บที่บ้าน, ส่ง lab ทาง logistics          |
| 📊 ได้ผลเมื่อไหร่?      | 4-6 สัปดาห์ — รายงาน 30 หน้า + counseling 60 นาที           |
| ✅ ตรวจสอบโดย         | นพ. ___ — Genetic Medicine + Cardiologist                    |

▶ ข้อมูลทางเทคนิค (gene list, methodology, accuracy, lifestyle prescription)
```

### T3 — Diagnostic Procedure

Example: Polysomnography at VTH BioDent

```
**Polysomnography (PSG) — Gold Standard** | Sleep Lab Test

| 👤 ใครควรตรวจ?     | ผู้สงสัย OSA, insomnia ซับซ้อน, narcolepsy, RBD          |
| 🎯 ตรวจอะไรได้?    | AHI, oxygen, EEG sleep staging, EMG, ECG, snoring       |
| 💉 ตรวจอย่างไร?    | ติดสาย sensors นอน 1 คืนใน sleep lab (ไม่ใช่ blood test) |
| 📊 แม่นยำแค่ไหน?    | Gold standard — 100% reference (HST 89-94% เทียบ)        |
| ✅ ตรวจสอบโดย     | ทพ. ดร. อมรพงษ์ — ABDSM (interpret report)              |

▶ ข้อมูลทางเทคนิค (LOINC, contraindications, ความยาว tracing, alternative tests)
```

### T4 — Medical Device / Technology

Example: Fotona LightWalker MAX at VTH BioDent

```
**Fotona LightWalker MAX** | Dual-Wavelength Er:YAG + Nd:YAG Dental Laser

| 👤 ใครได้ประโยชน์?  | ปริทันต์, ฟันสึก/ผุน้อย, snoring/mild OSA, intraoral aesthetic  |
| 🎯 ใช้ทำอะไรได้?    | 10 protocols — TwinLight, SWEEPS, NightLase, ComfortLase ฯลฯ  |
| 🏥 มีให้บริการที่   | VTH BioDent ทั้ง 2 สาขา (King Square Rama 3 + Park11)       |
| 🛡️ มาตรฐาน        | FDA-cleared (USA) + CE Mark (EU) — Class IV laser              |
| ✅ ตรวจสอบโดย    | ทพ. ดร. อมรพงษ์ — Laser Dentistry Certified                  |

▶ ข้อมูลทางเทคนิค (wavelengths, power output, model spec, manufacturer)
```

### T5 — Service / Money Page

Example: Mouth BioMapping® Signature Service at VTH BioDent

```
**Mouth BioMapping® — Signature Diagnostic Service** | VTH Comprehensive Airway + Oral Health Assessment

| 👤 ใครเหมาะ?      | ผู้สงสัย OSA/bruxism/TMJ + คนต้องการ proactive airway screening    |
| 📋 ครอบคลุมอะไร?  | CBCT 3D airway + Occlusal scan + EMG + Sleep questionnaire + Photo |
| ⏱️ ใช้เวลาประเมิน | ~90 นาที — รายงาน comprehensive ภายใน 7 วัน                       |
| 💰 ค่าใช้จ่าย      | 25,000-35,000 บาท (รวมรายงาน + consultation 2 ครั้ง)              |
| ✅ ตรวจสอบโดย    | ทพ. ดร. อมรพงษ์ — ABDSM Certified                                  |

▶ ข้อมูลทางเทคนิค (services breakdown, exclusions, eligibility, follow-up plan)
```

### T6 — Concept / Knowledge (OPTIONAL)

**Decision rule:**
- YMYL adjacent (e.g., "Oral-Systemic Health") → มี Section 2
- Non-YMYL (e.g., "What is implantology — overview") → SKIP Section 2, เริ่มเนื้อหาทันที

**YMYL adjacent example:**

```
**Oral-Systemic Health** | ความเชื่อมโยงช่องปากกับสุขภาพทั่วร่างกาย

| 👤 ทำไมเรื่องนี้สำคัญ? | ทุกคน — สุขภาพช่องปากกระทบหัวใจ, สมอง, เบาหวาน, การคลอด |
| 📚 สาขาที่เกี่ยวข้อง  | Periodontology, Cardiology, Endocrinology, Sleep Med, OB-GYN  |
| 🔗 หัวข้อที่เชื่อมโยง  | Periodontitis, OSA, Atherosclerosis, Diabetes, Pregnancy   |
| ✅ ตรวจสอบโดย       | ทพ. ดร. อมรพงษ์ (YMYL adjacent)                            |

▶ ข้อมูลทางเทคนิค (terminology, key research papers, professional bodies)
```

### T6a — Guide (Long-form actionable)

Example: Complete Implant Guide at Deezy / SmileScape

```
**คู่มือรากเทียมฉบับสมบูรณ์** | Complete Guide to Dental Implants

| 👤 ใครควรอ่าน?     | ผู้กำลังพิจารณารากฟันเทียม + ครอบครัวที่ดูแลผู้สูงอายุ      |
| ⏱️ ใช้เวลาอ่าน      | 25-30 นาที (4,500 คำ — ครบจบในหน้าเดียว)                 |
| 📋 ครอบคลุมอะไร?   | 8 ขั้นตอน: ตัดสินใจ → ปรึกษา → planning → surgery → maintenance |
| 🎯 เป้าหมาย        | ตัดสินใจอย่างมีข้อมูลครบ + เตรียมตัวก่อน-ระหว่าง-หลัง       |
| ✅ ตรวจสอบโดย     | ทพ. วรภัทร จรางกุล — Lead Implantologist                    |

▶ ข้อมูลทางเทคนิค (sections list, related guides, glossary)
```

### T7 — Comparison

Example: CPAP vs Oral Appliance vs Surgery vs Lifestyle

```
**เปรียบเทียบวิธีรักษา OSA** | CPAP vs Oral Appliance vs Surgery vs Lifestyle

| ⚖️ ตัวเลือกไหน?    | CPAP (severe), Oral Appliance (mild-mod), Surgery (anatomy), Lifestyle (เสริม) |
| 🎯 เกณฑ์ตัดสินใจ   | ระดับ AHI, anatomy, CPAP tolerance, ความสะดวก, ค่าใช้จ่าย         |
| 👤 แนะนำใคร?      | Mild-Mod → Oral Appliance / Severe → CPAP / Anatomy → Surgery     |
| 🎯 จุดยืน VTH      | Oral Appliance first สำหรับ mild-moderate + CPAP-intolerant         |
| ✅ ตรวจสอบโดย     | ทพ. ดร. อมรพงษ์ — ABDSM Certified                                 |

▶ ข้อมูลทางเทคนิค (เปรียบเทียบ AHI/ราคา/adherence — ดู §7.5 Comparison Table ในเนื้อหา)
```

### T12 — Hub Page

Example: Sleep & Airway Hub at VTH

```
**Sleep & Airway Hub** | All Resources for Sleep + Breathing Health

| 📚 ครอบคลุม         | 24 บทความ — Conditions, Treatments, Diagnostics, Patient Stories |
| 👥 เหมาะสำหรับใคร?  | ผู้สงสัย OSA, คู่นอนของผู้กรน, ผู้ที่กำลังตัดสินใจรักษา                |
| 🎯 จะได้อะไร?        | เข้าใจอาการ → รู้ว่าควรตรวจ → เลือกรักษา → ดูแลตัวเอง               |
| 🔄 อัพเดทล่าสุด     | พฤษภาคม 2026 (ตรวจทุก 3 เดือน)                                 |
| ✅ ตรวจสอบโดย       | ทพ. ดร. อมรพงษ์ (clinical accuracy)                              |

▶ ข้อมูลทางเทคนิค (article list by category, related hubs, glossary)
```

### T14 — Trending / News Update

Example: Google March 2026 Update news article

```
**Google March 2026 Core Update — ผลกระทบเว็บการแพทย์** | News Update

| 📅 วันที่เผยแพร่   | 14 มีนาคม 2026 (อัพเดทล่าสุด: 18 มี.ค.)                   |
| 🔥 ทำไมสำคัญ?    | Google ปรับ ranking factors สำหรับ YMYL — กระทบเว็บการแพทย์ |
| 📊 ผู้เกี่ยวข้อง  | Healthcare websites, content writers, SEO specialists       |
| 📡 แหล่งข่าว      | Google Search Central Blog, Search Engine Land             |
| ✅ ตรวจสอบโดย    | [SEO Lead] — Field-tested impact                            |

▶ ข้อมูลทางเทคนิค (impact metrics, recovery strategies, related Google updates timeline)
```

### T15 — Quiz / Self-Assessment

Example: STOP-BANG OSA Risk Quiz

```
**แบบประเมินความเสี่ยง OSA — STOP-BANG** | OSA Risk Quiz

| 👤 ใครควรทำ?     | ผู้นอนกรน หรือมีอาการง่วงนอนกลางวันผิดปกติ + อายุ 18+    |
| ⏱️ ใช้เวลาทำ      | 2 นาที — 8 คำถามสั้น                                     |
| 📊 จะได้อะไร?     | คะแนน 0-8 + ระดับความเสี่ยง + แนะนำขั้นตอนต่อ           |
| ⚠️ ข้อจำกัด       | screening เบื้องต้น — ไม่ทดแทน Sleep Study (แม่นยำ 80-85%)|
| ✅ ตรวจสอบโดย     | ทพ. ดร. อมรพงษ์ — based on Chung et al. 2008 (validated)|

▶ ข้อมูลทางเทคนิค (scoring algorithm, validation data, sensitivity/specificity)
```

### T16 — Insurance / Coverage Explainer

Example: ประกันสังคมทันตกรรม at Deezy Dental

```
**สิทธิ์ประกันสังคม — ทันตกรรม** | Social Security Dental Coverage Guide

| 👤 ใครใช้สิทธิ์ได้?    | ผู้ประกันตน ม.33, ม.39, ม.40 ที่จ่ายสมทบครบเกณฑ์         |
| ✅ ครอบคลุมอะไร?     | อุดฟัน, ขูดหินปูน, ถอนฟัน, ผ่าฟันคุด — วงเงิน 900 บ./ปี |
| ❌ ไม่ครอบคลุม        | จัดฟัน, รากฟันเทียม, ฟอกสีฟัน, วีเนียร์, ฟันปลอม         |
| 📋 ขั้นตอนเบิก         | นำบัตร ปชช. + บัตรประกัน → คลินิกเบิกตรงไม่ต้องสำรอง   |
| 📅 ข้อมูลล่าสุด        | พฤษภาคม 2026 (ตรวจสอบกับ สปส. ทุก 3 เดือน)               |

▶ ข้อมูลทางเทคนิค (กฎหมายอ้างอิง, อัตราเปลี่ยนแปลง, ขั้นตอนกรณีพิเศษ)
```

**Note:** T16 ไม่มี ✅ Reviewer row (operational page, ไม่ใช่ medical content) — ใช้ "ข้อมูลล่าสุด" เป็น row 5 แทนเพื่อ trust signal (date freshness)

### T17 — Care Instructions

Example: Post-Implant Care

```
**คู่มือดูแลรากเทียมหลังผ่าตัด** | Post-Implant Care

| 👤 ใครควรอ่าน?    | ผู้เพิ่งผ่าตัดรากเทียมภายใน 6 เดือน                        |
| 📅 ระยะการดูแล    | Phase 1: 7 วันแรก / Phase 2: 1-3 เดือน / Phase 3: ตลอดชีพ |
| ⏱️ ใช้เวลาอ่าน     | 8-10 นาที                                                 |
| 🚨 สัญญาณเตือน    | ปวดเพิ่มขึ้นหลัง 48 ชม., บวมไม่ลด 5 วัน, มีหนอง → ติดต่อทันที |
| ✅ ตรวจสอบโดย    | ทพ. วรภัทร จรางกุล — Lead Implantologist                   |

▶ ข้อมูลทางเทคนิค (medication schedule, diet restrictions, อนุญาต/ห้าม activities)
```

---

## 🅱️ Group B — Alternative Block Pattern

### T8 — Case Study → Patient Profile Box

```
**Case คุณ A — ผลรักษา OSA ระดับปานกลางด้วย Oral Appliance**

| 👤 ผู้ป่วย         | ชาย 42 ปี (นามสมมติ — โดยได้รับความยินยอม)              |
| 🩺 อาการที่มา      | bruxism + ฟันสึก + ปวดศีรษะตอนเช้าเรื้อรัง                 |
| 🔍 การวินิจฉัย     | OSA ระดับปานกลาง (AHI 28) + retrognathia (CBCT confirm) |
| 💊 การรักษา       | Custom-titrated Oral Appliance + NightLase + ปรับพฤติกรรม |
| ✅ แพทย์ผู้รักษา   | ทพ. ดร. อมรพงษ์ — ABDSM Certified                       |

ผลลัพธ์ →  AHI 28 → 5 / ปวดหัวเช้าหายไป / ฟันสึกหยุดดำเนิน
```

→ Format ใกล้เคียง Quick Facts แต่ context เน้น patient story

### T9 — Author Profile → Credentials Box

```
[ ภาพถ่ายแพทย์ ]

**ทพ. ดร. อมรพงษ์ วชิรมน**
Executive Medical Director, VTH BioDent

| 🎓 การศึกษา       | DDS Chulalongkorn / DBA Stanford / PhD Harvard / LLD MIT |
| 🏆 Specialties    | Dental Sleep Medicine, Occlusion, TMJ Disorders          |
| 🌟 Certifications | ABDSM Diplomate, AAID Fellow, ITI Implant Member         |
| 📅 ประสบการณ์     | 20+ ปี ด้าน airway-aware dentistry                         |
| 🌐 ภาษา           | ไทย (native), English (fluent), Mandarin (basic)         |
```

→ Page IS the EEAT signal — ไม่ต้องมี "ตรวจสอบโดย" row (self)

### T10 — Branch → Address & Hours Box

```
**VTH BioDent — King Square Community Mall (พระราม 3)**

| 📍 ที่อยู่         | ชั้น 2, King Square, Rama III, ยานนาวา, กรุงเทพ 10120  |
| 🕒 เวลาทำการ     | จ-ศ 9:00-19:00 / ส-อา 9:00-17:00                         |
| 🚇 การเดินทาง    | BTS สุรศักดิ์ + รถ feeder / ที่จอดรถฟรี 2 ชม.            |
| 📞 ติดต่อ          | 02-XXX-XXXX | LINE: @vthbiodent | นัดออนไลน์            |
| 👨‍⚕️ ทีมแพทย์ที่สาขา | ทพ. ดร. อมรพงษ์ + ทพญ. ___ + อีก 4 ท่าน                  |
```

→ Hooks: location-first (ไม่ใช่ disease-first)

### T18 — Programmatic Local → Branch Hero

Example: จัดฟัน รัตนาธิเบศร์ — Deezy Dental

```
**จัดฟัน รัตนาธิเบศร์ — Deezy Dental** | Orthodontics at Rattanathibet Branch

| 📍 ที่ตั้ง         | ติด MRT สีม่วง สถานีรัตนาธิเบศร์ (เดิน 3 นาที)              |
| 👨‍⚕️ ทีมแพทย์ที่สาขา | 4 ทันตแพทย์เฉพาะทางจัดฟัน (รวม ทพ. ___ M.Sc. Ortho)       |
| 🦷 บริการที่มี     | Damon System / Self-Ligating / Invisalign / TrioClear / โลหะ |
| 🕒 เวลาทำการ     | จ-ศ 10:00-20:00 / ส-อา 10:00-19:00                         |
| 📞 นัดที่สาขานี้    | 02-XXX-XXXX | LINE: @deezydental                          |
```

→ Service+Branch combo — local-first hooks

---

## 🅾️ Group C — No Section 2 (skip)

### T11 — Institutional (Home / About / Contact / Privacy)

**SKIP Section 2** — เริ่มต้นด้วย:
- Home → Brand pillars / Hero CTA
- About → Brand origin story / Mission
- Contact → Address Hours Block (ใช้ B42 จาก T10)
- Privacy/Terms → Legal text body

### T13 — Pricing List Page

**SKIP Section 2** — Section 1 = Pricing Grid Hero (B79 pricing_table_grid IS the page content)

### T19 — Promotion / Offer

**SKIP Section 2** — Section 1 = Offer Hero (validity, price, eligibility) ที่ render ใน hero แล้ว

---

## 🎨 Universal Icon Taxonomy

ใช้ icon ตรงกัน across templates เพื่อ visual consistency:

| Icon | Meaning | Used In |
|------|---------|---------|
| 👤 | Who (audience/patient) | All templates with Quick Facts |
| ✅ | Reviewer / Trust | All YMYL templates |
| 🔍 | Diagnosis / Detection | T1, T3 |
| 💊 | Treatment / Medication | T1, T2, T8 |
| ⏱️ | Duration / Time | T2, T2a, T6a, T15, T17 |
| 🩹 | Recovery (medical) | T2 |
| 😊 | Downtime (aesthetic context) | T2a |
| 📅 | Timeline / Schedule / Date | T2a, T2c, T14, T17 |
| 🦷 | Dental-specific | T2b, T18 |
| 🔧 | Materials / Tools | T2b |
| 🛡️ | Warranty / Standards / Safety | T2b, T4 |
| 🎯 | Goal / Outcome / Stance | T2c, T2d, T6, T6a, T7, T12 |
| 🔁 | Frequency / Recurrence | T2d |
| 🏃 | Functional recovery | T2d |
| 🧬 | Genetics | T2e |
| 💉 | Sample collection / Method | T2e, T3 |
| 📊 | Output / Accuracy / Data | T2e, T3, T14, T15 |
| 🏥 | Branch / Hospital location | T4, T10, T18 |
| 📋 | Coverage / Sections | T6a |
| ⚖️ | Comparison | T7 |
| 📚 | Library / Articles | T6, T12 |
| 👥 | Audience group | T12 |
| 🔄 | Update / Refresh | T12 |
| 🔥 | Importance / Trending | T14 |
| 📡 | Source | T14 |
| ⚠️ | Limitations / Caution | T15 |
| 🚨 | Red flags / Emergency | T17 |
| 📍 | Location / Address | T10, T18 |
| 🕒 | Hours | T10, T18 |
| 🚇 | Transit | T10 |
| 📞 | Booking / Contact | T10, T18 |
| 👨‍⚕️ | Doctor team | T10, T18 |
| 🎓 | Education | T9 |
| 🏆 | Specialties | T9 |
| 🌟 | Certifications | T9 |
| 🌐 | Languages | T9 |
| 🩺 | Symptoms | T8 |
| 🔗 | Connected topics | T6 |

**35+ icons** — แต่ละ template ใช้ 4-5 icons ที่เกี่ยวกับ hook factor ของตัวเอง

---

## 📐 Universal Pattern Rules

```yaml
all_templates_with_section_2:
  format: 5-essential rows always visible + toggle for technical details
  toggle_label: "▶ ข้อมูลทางเทคนิค (สำหรับผู้สนใจเชิงลึก)"
  toggle_default: collapsed
  reviewer_position: row 5 (last) — visual EEAT hook anchor

universal_essentials_pattern:
  row_1_or_title:    Disease/Topic/Page name (TH + EN)
  row_2:             Who? (audience self-identification)
  row_3:             What? (the procedure/test/process)
  row_4:             How? (timeline/method/outcome)
  row_5:             Reviewer (✅ EEAT visual hook)

content_marketing_principle:
  - All essentials answer "What's in it for me?"
  - Technical codes (ICD/SNOMED/MeSH/CPT/LOINC) → toggle
  - Reduce time-to-value (= reduce bounce rate = SEO win)
  - Question labels stronger hook than statement labels
  - Icons enable 2-second skim

seo_benefits_preserved_with_toggle:
  - Google indexes <details> content fully (since 2019)
  - All schema fields populate (toggle doesn't affect crawl)
  - Featured Snippet capture from essentials
  - AI citation friendliness (structured table)
  - Voice search (codes accessible via toggle expansion)

never_in_section_2:
  - Multiple paragraphs of prose
  - Long lists (>5 items per cell)
  - Inline citations (those go in body content)
  - Editorial annotations (📖 Annotation:)
  - CSS hints (those go in Part 2)
```

---

## ✅ Validation Checklist (Per Template)

ตอน implement Section 2 สำหรับ template ใดก็ตาม:

- [ ] Title row: bold disease/topic/page name (TH + EN)
- [ ] 4 hook rows with icons + question/label format
- [ ] Reviewer row (✅) — last row, visual EEAT anchor (skip for T9/T10/T11/T13/T18/T19 per Group rules)
- [ ] Toggle "▶ ข้อมูลทางเทคนิค (สำหรับผู้สนใจเชิงลึก)" — collapsed default
- [ ] Technical codes/data inside toggle (NOT visible by default)
- [ ] Icons match Universal Icon Taxonomy
- [ ] Each cell ≤ 1 line (no paragraphs, no long lists)
- [ ] CSS classes per Part 2 spec (`.quick-facts-table`, `.quick-facts-essential`, `.quick-facts-detailed`)
- [ ] Schema feeds verified (codes still indexed even when collapsed)
- [ ] Brand voice consistent (TH primary, EN as alternate label)

---

<!--
END OF SECTION 2 PATTERN REFERENCE v1.0
Locked 2026-05-10 by operator approval

Next steps:
1. Reference this file from Content_Templates B02 spec
2. Apply pattern when creating skeletons for T2-T19 (currently only T1 done)
3. Update if content writers find new edge cases during real production work
-->
