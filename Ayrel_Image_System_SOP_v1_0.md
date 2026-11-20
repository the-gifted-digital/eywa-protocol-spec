# 🖼️ AYREL — EYWA Image System

> **เวอร์ชัน:** 1.2 · **ประกาศใช้:** 2026-11-20 (นำร่อง) · **v1.2:** ส่วนที่ 2 ทะเบียนภาพ (DR-085) — ลงทะเบียน · alt ต่อภาษา · ใช้ซ้ำข้ามหน้า · ภาพบุคคลปลดอัตโนมัติ · quarantine 90 วัน · กันไหลย้อน · runbook
> **ขอบเขต:** **UNIVERSAL** (คอลัมน์ `og_*` + ทะเบียนภาพในตารางแชร์) · เครื่องมือฝั่งแบรนด์ยังอยู่ใน repo แบรนด์นำร่อง (vth) — ย้ายเป็นของกลางเมื่อนิ่ง
> **ที่มา:** field-tested กับ VTH BioDent — `/teeth-whitening/` (hero → การ์ดมือถือ → og card, 2026-11-20) · ทดสอบปลดภาพครบวงจรบนเว็บจริง (2026-11-21)
> **Companion:** DR-084 (การ์ด og) · DR-085 (ทะเบียนภาพ) · DR-038 `seo_media_assets` · DR-035 / DR-040 R2 · BROADCAST-2026-11-17 แถวต่อภาษา · SmileScape SS-DR-015/016 · `templates/folder-skeleton/design/brand-foundation/imagery.md`
>
> **Ayrel** [aj.ˈrɛl] — Na'vi แปลว่า "ภาพ (หลายภาพ)" (*ay-* พหูพจน์ + *rel* ภาพ) เข้าชุดกับ **EYWA** (เครือข่ายความรู้) · **Tsaheylu** (สัญญาณ conversion) · **Pamrel** (การเขียน — *pam* เสียง + *rel* ภาพ)
> *ความหมายยังไม่ได้ตรวจกับพจนานุกรม Na'vi ฉบับทางการ — ตรวจก่อนใช้ในเอกสารเผยแพร่*

---

## 0. AYREL คืออะไร

1. **ภาพเดียว ใช้ได้มากที่สุด** — ภาพจาก AI หนึ่งภาพต่อหน้า ออกแบบตั้งแต่ตอนสั่งสร้างให้ใช้ได้ทุกช่องของ template (hero เดสก์ท็อป · การ์ดมือถือ · การ์ด og) และ**ทุกภาษา**
2. **ทะเบียนภาพเดียว** — ทุกไฟล์ภาพ/วิดีโอมีแถวใน `seo_media_assets`: ที่มา · ชนิด · alt ต่อภาษา · ใช้ที่หน้าไหน · ใครอยู่ในภาพ · ใช้ได้ถึงวันไหน
3. **ภาพบุคคลจริงไม่เคยค้างเกินสัญญา** — ปลดอัตโนมัติก่อนวันหมดอายุ 1 วัน · ย้ายเข้า quarantine 90 วัน · ไม่มีทางไหลกลับขึ้นเว็บเอง

```
"ทำภาพหน้า <slug> ตาม AYREL"
```

### ชุดประกอบ

| ชั้น | สิ่งที่มี | อยู่ที่ |
|---|---|---|
| **สเปกกลาง** | ฉบับนี้ · DR-084 · DR-085 | `eywa-protocol-spec/` |
| | การ์ด og: `og_display` · `og_tagline` · `og_style` · `og_image_url` · `og_image_generated_at` · `og_image_alt` + `v_page_og_card` | `seo_website_page_master` (Schema v1.31) |
| | ทะเบียนภาพ: `seo_media_assets` (+17 คอลัมน์) · `seo_media_asset_texts` · `seo_media_asset_usages` · `seo_media_asset_events` + 6 view + pg_cron `eywa-media-daily-sweep` | Schema v1.32 |
| **ของแบรนด์** | **Ayrel slot spec** — สัดส่วน · ครอปต่อช่อง · สิ่งที่ทับ · safe zone ต่อ template | `<brand>/design/hero-slots.json` |
| | ค่าตั้งต้นการ์ด og | `<brand>/design/og-card.json` |
| | ค่าทะเบียน: brand_id · account/zone · 3 bucket (public / gated / quarantine) · host · 90 วัน | `<brand>/design/media.json` |
| **เครื่องมือ** | `npm run ayrel:build` — การ์ด og | `<brand>/web/scripts/ayrel/` |
| | `npm run ayrel:sweep` — ปลดภาพ · quarantine · manifest · ตรวจ 404 · ลบถาวร | `<brand>/web/scripts/ayrel/media-sweep.mjs` |
| | `npm run check:media` — ด่านตอน build | `<brand>/web/scripts/ayrel/check-media.mjs` |
| | ประตูภาพบุคคล `/media/<key>` | `<brand>/web/worker/media-gate.ts` |
| | Action รายวัน 00:20 ICT | `<brand>/.github/workflows/media-sweep.yml` (ต้องอยู่บน `main`) |
| | สร้างภาพ: Higgsfield MCP `generate_image` (`gpt_image_2_6`) | connector ของ session |

> 🔴 **slot spec คือกฎของภาพ · ทะเบียนคือความจริง · `seo_servable_media` คือทางเดียวที่ภาพขึ้นเว็บ · สคริปต์และ trigger คือตัวบังคับ**

---

# ส่วนที่ 1 — ภาพของหน้า และการ์ด og

## 1. Pipeline — 10 ขั้น

```
 1. slot       อ่าน design/hero-slots.json ของ template หน้านั้น      → สัดส่วน + safe zone
 2. prompt     เขียน prompt ตาม §3 (จุดเด่นใน safe zone · สีจาก tokens)
 3. generate   Higgsfield gpt_image_2_6 · 2K · count 2 (เลือก 1)        → ~5.5 เครดิต
 4. preview    สลับภาพบนหน้าเว็บจริงในเบราว์เซอร์ (เดสก์ท็อป 1440 + iPhone DPR 3)
 5. approve    operator เลือกภาพ — ก่อนแตะ R2 หรือ repo
 6. upload     R2 <prefix>/<slug>/hero-v<n>.webp (2160x900 สำหรับ 2.4:1, WebP q82, < 200 KB)
 7. register   แถวใน seo_media_assets (origin, kind, generation_model/job/prompt, key) + alt ทุกภาษาที่หน้ามี
               (seo_media_asset_texts, written_for_key = key) + usage ต่อช่อง (hero, mobile_card, og) — §8
 8. content    hero.image.src + alt ใน src/content/<template>/<locale>/<slug>.yaml → push → ตรวจหน้าจริง
 9. og         og_tagline / og_display (ถ้าต้อง override) → npm run ayrel:build -- --slug <slug> --dry-run
               → ดู out/*.jpg → รันจริง → ลงทะเบียนการ์ด (kind og_card, origin render) → commit og-cards.json
               → push → ตรวจ og:image + og:image:alt บนหน้าจริง
10. refresh    Facebook Sharing Debugger → Scrape Again (LINE อัปเดตเองภายในไม่กี่วัน)
```

ขั้น 4–5 ห้ามข้าม: ไฟล์ภาพที่สวยไม่ได้แปลว่าครอปบนเว็บสวย (A1, A11) · ขั้น 7 ห้ามข้าม: ภาพที่ไม่อยู่ในทะเบียนไม่มี alt ต่อภาษา ไม่มีใครรู้ว่าใช้ที่ไหน และไม่มีวันหมดอายุ

---

## 2. หลักการ — ภาพและการ์ด (A)

### A1 · ภาพเดียว ต้องจัดองค์ประกอบเพื่อ "ส่วนที่ทุกครอปเห็นร่วมกัน"
ภาพ hero ของ Service (vth) ถูกเห็นสามแบบ: เดสก์ท็อปครึ่งซ้ายมีหัวข้อทับ · มือถือครอปสี่เหลี่ยมที่ `78% 40%` และครึ่งล่างมีกระจกฝ้าทับ · og ครึ่งล่างมีแถบข้อความ → จุดเด่นต้องอยู่ช่วง **x 0.50–0.87, y 0.15–0.60** ของภาพ ถึงจะรอดทั้งสามช่อง · ภาพแรก (teeth-whitening) จุดเด่นเริ่มที่ x ≈ 0.42 — แผ่นเทียบสีด้านซ้ายจึงจมใต้หัวข้อบนการ์ด og · safe zone ของทุก template อยู่ใน slot spec

### A2 · ครอปที่ขอบ (edge) ให้เป็นรูปกรอบ ห้ามขอแค่ความกว้าง
`srcset` แบบ `640w` บอกความกว้างของภาพ**ทั้งภาพ** ถ้ากรอบโชว์แค่ส่วนกลาง (สี่เหลี่ยมจากภาพ 2.4:1) เบราว์เซอร์จะยืดไฟล์เล็กให้เต็มกรอบ — การ์ดมือถือ vth เบลอ ~4 เท่าบน iPhone (ไฟล์ 640x267 ในกรอบ 350x350 CSS ที่ DPR 3) · แก้ด้วย Cloudflare `width=N,height=N,fit=cover,gravity=X×Y` + `sizes` = ขนาดกรอบจริง · ใช้กับทุก component ที่ภาพต้นฉบับสัดส่วนไม่ตรงกรอบ (`ui/Image.astro` ยังค้าง — §12)

### A3 · Cloudflare `gravity=X×Y` = CSS `object-position X% Y%`
วัดแล้ว: `gravity=0.78x0.4` ต่างจาก `object-[78%_40%]` เฉลี่ย 1.75/255 · การตีความว่าเป็น "จุดกึ่งกลางของครอป" (0.663) พลาด 36.75 → ใช้ค่าเดียวกับ CSS ได้ตรง ๆ ทั้งใน slot spec และ `og_style.focus`

### A4 · key ใน R2 มีเวอร์ชันเสมอ และห้ามยิงทดสอบ URL ก่อนอัปโหลด
CDN จำผล 404 ของ key ที่เคยถูกเรียกก่อนมีไฟล์ (เจอจริง: `hero.webp` ค้าง 404 หลังอัปโหลดแล้ว) · ใช้ `-v<n>` ทุกครั้ง เปลี่ยนภาพ = เวอร์ชันใหม่ ไม่เขียนทับ · ทะเบียนบังคับซ้ำ: key ใช้ได้ครั้งเดียวตลอดกาล (B5)

### A5 · 1 แถว page_master = 1 หน้า 1 ภาษา = 1 การ์ด og
ภาพถ่ายใช้ร่วมทุกภาษา · ข้อความเป็นของแต่ละแถว · ไฟล์ `og/<slug>-v<n>.jpg` (slug ของแถวคำแปลมี `-<locale>` อยู่แล้ว) · `og-cards.json` ผูกด้วย URL path เก็บ `{ url, alt }`

### A6 · ค่าเริ่มต้นมาจากข้อมูลที่มีอยู่ — เขียนเฉพาะเมื่อ override
`og_display` NULL = ชื่อ entity ภาษาอังกฤษ (`seo_entity_graph.entity_name`) · `og_tagline` NULL = `seo_title` ก่อน ` | ` · ไม่คัดลอกมาเก็บ · override เมื่ออ่านแล้วไม่ดี — กรณีที่เจอบ่อย: **seo_title ขึ้นต้นด้วยชื่อบริการ** ทำให้บรรทัด 2 ซ้ำบรรทัด 1 ("Teeth Whitening / ฟอกสีฟัน เลือก…") → ตั้ง `og_tagline` ตัดชื่อบริการออก · แถวที่ไม่มี `primary_entity_fp` (1,198 แถวตอน apply) ต้องมี `og_display` ก่อนสร้างการ์ด

### A6a · alt: ภาษาเดียวกับหน้า ภาษาเดียวต่อ alt
- **ภาพบนหน้า** (hero, ภาพประกอบ) — อธิบายสิ่งที่เห็นจริง ≤ ~125 ตัวอักษร ภาษาเดียวกับหน้า · เก็บใน `seo_media_asset_texts` (ภาพ × ภาษา) ผูก `written_for_key` · usage ที่ไม่ระบุ locale = ต้องมี alt ทุกภาษาที่หน้านั้นมี (`v_media_text_issues` รายงานที่ขาด)
- **การ์ด og** (`og:image:alt`, `twitter:image:alt`) = **ข้อความบนการ์ด** (`บรรทัด 1 — บรรทัด 2`) จาก `og_image_alt_resolved` · override ด้วย `og_image_alt` เมื่อต้องเพิ่มประโยค (A10) · ผลต่อ SEO น้อย แต่ไม่ปล่อยว่าง

### A7 · สองบรรทัด ห้ามตัดบรรทัด — ไม่พอให้ล้ม
บรรทัด 1 Fraunces (ฟอนต์ display ของแบรนด์) 84 → ขั้นต่ำ 56px · บรรทัด 2 ฟอนต์ของภาษา 36 → 26px · ต่ำกว่าขั้นต่ำแล้วยังไม่พอ = FAIL ให้แก้ข้อความ · การตัดบรรทัดภาษาไทยอัตโนมัติตัดกลางวลี ("…อย่างไร ควร / เลือก…") จึงไม่ยอมให้ wrap · ฟอนต์ ja/ko ถูก subset ตามข้อความที่เว็บใช้ — สคริปต์เช็ก glyph ทุกตัว

### A8 · สีบรรทัด 1 = สีหลักของแบรนด์ โทนแถบเลือกให้ contrast ≥ 3:1
สีหลักน้ำเงินบนแถบน้ำเงินอ่านไม่ออก (vth `#3F60B2` บนแถบน้ำเงิน 1.5:1) → สีหลักเข้มใช้แถบสว่าง สีหลักอ่อนใช้แถบเข้ม · override ได้ (`og_style.band`, `display_color`) แต่ต่ำกว่า 3:1 สคริปต์เตือน

### A9 · เกรนต้องแรง
ฟีด Facebook / LINE บีบอัดภาพซ้ำ เกรนอ่อนหายหมด · ค่าตั้งต้น 0.85 (operator เลือก "มาก" 2026-11-20)

### A10 · ภาพ AI ทั่วไปไม่ติดป้าย · ภาพที่แสดงผลลัพธ์การรักษาต้องติดป้ายบนภาพ
(operator 2026-11-20)
- **ภาพประกอบทั่วไป** — มือในถุงมือ อุปกรณ์ โมเดลฟัน บรรยากาศ ภาพอธิบายกลไก → **ไม่ต้องบอกว่าเป็นภาพ AI**
- **ภาพที่แสดงหรือสื่อถึงผลการรักษา** — ภาพจำลองผลลัพธ์ · ก่อน/หลัง · "หลังทำจะเป็นแบบนี้" → `kind = result_simulation` · **ต้องมีป้ายที่มองเห็นบนตัวภาพ** และประโยคเดียวกันใน alt (`v_media_text_issues` = `simulation_label_missing` ถ้าขาด)
  - ไทย: **"ภาพจำลองผลลัพธ์ที่สร้างด้วย AI ไม่ใช่ผลการรักษาจริง ผลลัพธ์ของแต่ละคนแตกต่างกัน"**
  - อังกฤษ: **"AI-generated simulation — not an actual treatment result. Results vary."**
  - ภาษาอื่นแปลตามแถวของภาษานั้น · ป้ายอยู่**บนภาพ** (ไม่ใช่แค่ใต้ภาพ) เพราะภาพถูกแชร์หรือครอปแยกจากหน้าได้ — รวมถึงการ์ด og ที่สร้างจากภาพแบบนี้
  - ตรวจกับข้อกำหนดโฆษณาสถานพยาบาลของแบรนด์ก่อนเผยแพร่ทุกครั้ง: ภาพจำลองผลลัพธ์อาจถูกมองว่าเป็นการโฆษณาผลการรักษา แม้มีป้ายแล้ว
- **ห้ามเสมอ** (ฐานข้อมูลบังคับ) — ภาพ AI เป็นเคส/รีวิว/testimonial ไม่ได้ (`chk_media_ai_not_real_evidence`) · `result_simulation` ต้องเป็นภาพ AI · ใบหน้า AI ที่ดูเป็นแพทย์หรือผู้ป่วยจริง
- template ที่ต้องเป็นภาพจริง (Doctor, CaseStudy) ตั้ง `realPhotoOnly` ใน slot spec — สคริปต์ไม่สร้างการ์ดให้

### A11 · ตรวจบนหน้าจริงที่ DPR จริง ไม่ใช่ที่ไฟล์
ความเบลอของ A2 มองไม่เห็นจากไฟล์ และไม่เห็นบนเดสก์ท็อป — เห็นเฉพาะมือถือ DPR 3 · ตรวจด้วย Playwright `devices['iPhone 14']` + `currentSrc` / `naturalWidth` ของ `<img>` ทุกครั้งที่เปลี่ยนภาพหรือ component

### A12 · 2K พอ
CDN ส่งภาพ hero กว้างสุด 1600px · สร้างที่ 2K (2.75 เครดิต) ไม่ใช่ 4K (4.25) · ภาพที่ไม่แสดงบนหน้า (Knowledge, Procedure) สร้างที่รูป og ตรง ๆ

---

## 3. Prompt — แม่แบบ

```
Ultra-wide photorealistic website hero banner, <aspect>. <brand mood: calm, trustworthy, premium clinic>.

COMPOSITION (strict): main subject centred at about <safeZone x-centre>% from the left and between
<y0>% and <y1>% of the height. The <area covered by text> is clean, empty, softly out-of-focus
background — no objects, no text. Nothing important in the top or bottom 15%.

SUBJECT: <topic as objects/hands/equipment — no face, no identifiable person, no patient>.
Hands natural, five fingers each.

LIGHT & COLOUR: bright, airy daylight, high-key. Background <paper/ice token hexes>.
Accents only in small details: <primary + anchor token hexes>. Shallow depth of field.

AVOID: text, letters, logos, watermarks, faces, patients, before/after, blood, sharp instruments,
clutter, harsh light, colour casts, extra fingers.
```

ตัวอย่างที่ใช้จริง (teeth-whitening, Service 2.4:1): มือในถุงมือถือแผ่นเทียบสีข้างโมเดลฟัน · พื้น `#F6FAFE`→`#EAF4FF` · accent `#375172` / `#3F60B2` · เก็บ prompt ฉบับใช้จริงไว้ใน `seo_media_assets.generation_prompt`

---

## 4. ค่าใช้จ่าย (Higgsfield, วัด 2026-11-20)

| งาน | ค่าตั้ง | เครดิต |
|---|---|---|
| hero 2.4:1 / 16:9 / 21:9 | high · 2K | **2.75** |
| hero ใดก็ได้ | high · 4K | 4.25 |
| ภาพประกอบ | medium · 1K | 0.5 |
| ภาพประกอบ | high · 1K | 1.5 |
| การ์ด og ต่อภาษา | HTML render | **0** |
| วิดีโอ 5 วิ (ภายหลัง) | Grok 1.5 Lite 720p / premium 1080p | 5 / 35–40 |

ต่อหน้า (hero 2 ตัวเลือก + การ์ดทุกภาษา) ≈ **5.5 เครดิต** · Plus 1,000 เครดิต ≈ 180 หน้า · ผ่าน MCP ใช้เครดิตเสมอ (สิทธิ์ unlimited ของแพ็กเกจใช้ได้เฉพาะบนเว็บ Higgsfield — ห้ามขับเบราว์เซอร์ไปใช้แทน ขัดเงื่อนไขของผู้ให้บริการ)

---

# ส่วนที่ 2 — ทะเบียนภาพ (DR-085)

## 5. ทะเบียนเก็บอะไร

**หนึ่งแถว `seo_media_assets` = หนึ่งไฟล์** (ภาพ หรือวิดีโอ) ของแบรนด์เดียว (DR-040) · ไฟล์ใหม่ = แถวใหม่เสมอ

| มิติ | คอลัมน์ | ค่า |
|---|---|---|
| ภาพของอะไร | `media_type` | doctor · branch · brand · treatment · procedure · condition · tech · case · clinic · brand_asset · other |
| รูปแบบไฟล์ | `asset_format` | image · video · animated_image · vector |
| ที่มา | `origin` | photo · ai_generated · ai_edited · illustration · render · screenshot (AI ต้องมี `generation_model`; เก็บ `generation_job_id`, `generation_prompt`) |
| ใช้ทำอะไร | `kind` | hero · illustration · diagram · icon · equipment · clinic_space · **portrait** · **case_before_after** · **review_photo** · **testimonial** · **result_simulation** · og_card · logo · video_hero_loop · video_explainer · **video_testimonial** |
| ใครอยู่ในภาพ | `consent_subject` | none · patient · staff · customer · model (ตัวหนาใน `kind` ห้ามเป็น none) |
| บุคคลที่เป็นภาพ | `person_fp` | → `seo_authors_reviewers` (แพทย์/ทีมงาน) |
| ส่งอย่างไร | `delivery` | public_cdn · **gated_worker** (บังคับเมื่อมีบุคคล) |
| วิดีโอ | `duration_seconds` · `has_audio` · `poster_asset_id` | ภาพปกเป็นแถวในตารางเดียวกัน |
| ความยินยอม | `consent_status` (Obtained/Pending/Revoked) · `consent_date` · `consent_doc_url` · `patient_ref` (รหัสแทน **ห้ามใส่ชื่อ**) · `use_forever` · `use_until` | ไม่ใช่ none ⇒ Active ได้เมื่อ Obtained + (use_forever หรือ use_until) |
| วันปลด | `remove_on` (generated) | `use_until − 1` |
| หลังปลด | `quarantined_at` · `quarantine_key` · `purged_at` | ระบบเขียนเอง |

**ตารางลูก**
- `seo_media_asset_texts` — alt (≤ 250) · caption · transcript ต่อภาษา · `written_for_key` = key ที่ข้อความนั้นอธิบาย (ไม่ตรง = เก่า)
- `seo_media_asset_usages` — ภาพ × หน้า (`page_fingerprint`) × ช่อง (hero · mobile_card · og · inline · gallery · portrait · reviewer_badge · poster · background · other) × ภาษา (NULL = ทุกภาษา) · **ภาพเดียวใช้ได้หลายหน้าที่เกี่ยวข้อง** · ลบภาพที่ยังมีหน้าใช้ไม่ได้
- `seo_media_asset_events` — บันทึกทุกเหตุการณ์ **แก้/ลบไม่ได้** (registered · status_changed · warning_15d/7d/3d · takedown_due · quarantined · cache_purged · gate_manifest_updated · rebuild_requested · cdn_verified_404 · leak_detected · re_consented · purged · text_written · note)

**ภาพแพทย์** — อยู่ในทะเบียนนี้ (`kind = portrait`, `consent_subject = staff`, `person_fp`) · "แพทย์ทั่วไป" กับ "แพทย์ผู้ review เนื้อหา" เป็น**บทบาทของคน** (`seo_doctor_assignments`, reviewer scope DR-083) ไม่ใช่ชนิดภาพ — ช่องที่วางบอกด้วย usage (`portrait`, `reviewer_badge`)

---

## 6. หลักการ — ทะเบียนภาพ (B)

### B1 · ภาพบุคคลจริงไม่อยู่บน CDN public เลย
`consent_subject ≠ none` ⇒ `delivery = gated_worker` (CHECK) · ไฟล์อยู่ใน bucket ส่วนตัว `<brand>-gated` · ขึ้นเว็บผ่าน `/media/<key>` ของ Worker เท่านั้น · Worker เสิร์ฟเมื่อ key อยู่ใน `manifest.json` · กรณีอื่นตอบ 404 (ไม่มี binding / ไม่มี manifest / manifest เสีย) · `Cache-Control: private` (Cloudflare ไม่เก็บ) · `noindex, noimageindex` · **ไม่มี Image Transformations บน path นี้** (สำเนาที่แปลงแล้วจะค้างใน edge cache ที่ purge ไม่ได้) — อัปโหลดภาพบุคคลในขนาดที่ใช้จริง

### B2 · ปลดก่อนวันหมดอายุ 1 วัน ตามเวลาไทย
`remove_on = use_until − 1` · "วันนี้" = `fn_media_today()` (Asia/Bangkok) · ตัดข้อพิพาทเรื่องชั่วโมง/นาที/timezone และครอบช่องว่างระหว่าง DB sweep (00:05) กับงานของแบรนด์ (00:20) (operator 2026-11-20)

### B3 · เตือน 15 / 7 / 3 วันก่อนวันปลด
event ครั้งเดียวต่อระดับต่อภาพ (unique index) · dashboard แบรนด์อ่าน `v_media_expiry_alerts` · ต่ออายุทันได้ด้วยการอัปเดต `use_until` (ก่อนวันปลด ไม่ใช่หลัง)

### B4 · ปลดแล้วไม่มีทางกลับ — ต่อความยินยอม = แถวใหม่ + key ใหม่
`trg_media_guard` ปฏิเสธ Expired/Revoked → Active/Pending · ปฏิเสธ Active ขณะอยู่ใน quarantine · แถวที่ purge แล้วแก้ไม่ได้ · ภาพ Active ที่เลยวันปลด ถูกเปลี่ยนเป็น Expired ทันทีที่มีคนแก้แถวนั้น · ยินยอมถูกเพิกถอน (`consent_status = Revoked`) → สถานะเป็น Revoked ในคำสั่งเดียวกัน · ต่อความยินยอม: อัปโหลดเป็น key ใหม่ (`-v2`) · แถวใหม่ `supersedes_asset_id` = แถวเดิม · event `re_consented`

### B5 · key ใช้ได้ครั้งเดียวตลอดกาล
`uq_media_r2_key` นับแถวที่ปลดแล้วด้วย · ไฟล์ที่เคยเสิร์ฟแล้วเปลี่ยน key ไม่ได้ (guard) · URL เก่าที่ค้างใน cache/bookmark จึงไม่มีวันชี้กลับไปที่ภาพใหม่

### B6 · quarantine คือ bucket ส่วนตัวแยก ไม่ใช่ prefix
SmileScape เดิมใช้ `_quarantine/` ใน bucket public — รู้ key ก็เปิดได้ · Ayrel ย้ายไป `<brand>-quarantine` (ไม่มี custom domain · r2.dev ปิด) · key ใน quarantine = `<วันที่ปลด>/<bucket เดิม>/<key เดิม>` · อ่านสำเนากลับมาเทียบขนาดก่อนลบต้นฉบับ · เก็บ **90 วัน** แล้วลบถาวร (`purged_at`) · ประวัติในทะเบียนอยู่ตลอด

### B7 · ตรวจซ้ำทุกคืน — HTTP ที่ไม่ใช่ 404 = รั่ว · เชื่อมต่อไม่ได้ = ยังไม่ยืนยัน
ทุก key ที่อยู่ใน quarantine ถูกยิงตรวจทุก host (`public_cdn` + `gate_hosts`) ทุกคืน · 404/410 → `cdn_verified_404` · สถานะอื่น → `leak_detected` + Action แดง · network error → `note` (unverified) + Action แดง — อย่าบันทึกว่ารั่วเพราะเครื่องที่ตรวจเข้า host ไม่ได้ (เจอจริงในการทดสอบแรก)

### B8 · หน้าเว็บอ่านภาพจาก `seo_servable_media` เท่านั้น
ด่านตอน build (`check-media.mjs`): usage ที่ยังไม่ถูกถอด ชี้ไปที่ภาพที่ใช้ไม่ได้ → deploy ล้ม · งานปลดภาพถอด usage ให้เอง (`removed_at`) ด่านจึงจับเฉพาะคนที่ใส่ภาพที่ปลดแล้วกลับเข้าหน้า · ไม่มี service key → เตือนแล้วผ่าน (เหมือนขั้น DB อื่นของ deploy) · มี key → เข้มงวด

### B9 · CHECK ต้องกัน NULL เอง
CHECK ของ Postgres ผ่านเมื่อผลเป็น NULL — `consent_status = 'Obtained'` กับค่า NULL เคยปล่อยภาพบุคคลที่ไม่มีความยินยอมเป็น Active ได้ (เจอตอนทดสอบ) · ใช้ `coalesce(consent_status, '') = 'Obtained'` · trigger แบบ BEFORE มองไม่เห็นค่าใหม่ของ generated column (`remove_on`) → คำนวณจาก `use_until − 1` ในตัว trigger

### B10 · งานตั้งเวลาของ GitHub รันจาก default branch เท่านั้น
`media-sweep.yml` ต้องอยู่บน `main` · ตัว job checkout branch ที่มีโค้ดเว็บ (vth: `feat/content-templates`) · ถ้าไฟล์อยู่แค่บน branch deploy, schedule จะไม่เคยรัน

---

## 7. วงจรรายวัน

```
00:05 ICT  pg_cron eywa-media-daily-sweep → fn_media_daily_sweep()          (DB กลาง ทุกแบรนด์)
           · event warning_15d / 7d / 3d
           · consent Revoked → status Revoked · remove_on ≤ วันนี้ → status Expired
           · event takedown_due ทุกแถวใน v_media_due_takedown
00:20 ICT  GitHub Action media-sweep (repo แบรนด์)                          → node scripts/ayrel/media-sweep.mjs
           1. ทุกแถวใน v_media_due_takedown: copy → <brand>-quarantine, อ่านกลับเทียบ, ลบต้นฉบับ,
              purge cache ทุก URL, ถอด usage, quarantined_at + quarantine_key, events
           2. เขียน manifest.json ใหม่จาก seo_servable_media (gated) — ทุกคืน แม้ไม่มีอะไรปลด
           3. ตรวจ 404 ทุก key ใน quarantine บนทุก host (B7)
           4. ครบ 90 วัน → ลบไฟล์ใน quarantine, purged_at
           5. มีภาพถูกปลด → dispatch deploy (HTML ทิ้ง <img> ที่ตายแล้ว)
```

Action แดง = อาจมีสิ่งที่ยังเปิดได้ → อ่าน log ก่อน **ห้ามกด re-run เฉย ๆ**

---

## 8. ขั้นตอนงาน (runbook)

**ลงทะเบียนภาพ AI ของหน้า** (pipeline ขั้น 7)
```sql
insert into seo_media_assets (asset_name, media_type, brand_id, entity_fp, source, origin, kind,
  generation_model, generation_job_id, generation_prompt, width, height, mime_type,
  r2_bucket, r2_object_key, cdn_url, status)
values ('<slug> hero v1', 'treatment', '<brand uuid>', '<entity fp>', 'ayrel', 'ai_generated', 'hero',
  'gpt_image_2_6 (Higgsfield)', '<job id>', '<prompt>', 2160, 900, 'image/webp',
  '<brand>-media', 'services/<slug>/hero-v1.webp', 'https://cdn.<brand>/services/<slug>/hero-v1.webp', 'Active');
-- แล้ว: seo_media_asset_texts (asset, locale, alt, written_for_key = key) ทุกภาษาที่หน้ามี
--       seo_media_asset_usages (asset, page_fingerprint, slot) ต่อช่อง
```

**ลงทะเบียนภาพบุคคล** (แพทย์ / เคส / รีวิว)
1. เอกสารยินยอมเก็บนอก git และนอก bucket public · `consent_doc_url` ชี้ไปที่เก็บส่วนตัว · `patient_ref` เป็นรหัส ไม่ใช่ชื่อ
2. อัปโหลดไปที่ `<brand>-gated` ในขนาดที่ใช้จริง (B1)
3. แถว: `consent_subject` · `delivery = 'gated_worker'` · `consent_status = 'Obtained'` · `use_until` หรือ `use_forever` · `person_fp` (แพทย์)
4. รัน `npm run ayrel:sweep` (หรือรอคืนนี้) ให้ manifest มี key → หน้าใช้ `/media/<key>`
5. ตรวจ: `/media/<key>` = 200 · `cdn.<brand>/<key>` = 404

**ความยินยอมถูกเพิกถอนวันนี้** — `update seo_media_assets set consent_status = 'Revoked' where id = …` → status เป็น Revoked ทันที · รัน Action **media-sweep** เอง (ไม่ติ๊ก dry_run) ไม่ต้องรอคืนนี้ · ตรวจ `v_media_quarantine` ว่ามีแถว และ `open_leak = false`

**ต่ออายุก่อนวันปลด** — อัปเดต `use_until` (+ `consent_date`) บนแถวเดิม ขณะยัง Active · หลังวันปลดแล้วทำไม่ได้ → แถวใหม่ + key ใหม่ (B4)

**ดูสถานะโดยไม่แก้อะไร** — Actions → media-sweep → Run workflow → ติ๊ก **dry_run** (ไม่ติ๊ก = รันจริง)

**`leak_detected`** — เปิด URL ใน event ด้วยตัวเอง · ถ้ายังเปิดได้: ลบไฟล์ต้นทางด้วยมือ + purge URL นั้น · หาว่าภาพกลับมาจากไหน (cache ที่ไม่ได้ purge · key ซ้ำนอกทะเบียน · โค้ดที่ไม่ได้อ่านผ่าน servable) · บันทึก `note` อธิบาย · รัน sweep ใหม่ให้ได้ `cdn_verified_404`

---

## 9. view สำหรับ dashboard ของแบรนด์

| view | ใช้ทำอะไร |
|---|---|
| `seo_servable_media` | ภาพที่ขึ้นเว็บได้ตอนนี้ — ทางเดียวที่ build และ Worker อ่าน |
| `v_media_expiry_alerts` | ภาพบุคคลที่จะถูกปลดใน 15 วัน (`alert_level` 15d/7d/3d, `live_usages`) |
| `v_media_due_takedown` | ต้องออกจาก CDN ตอนนี้ (งานรายวันอ่าน) |
| `v_media_quarantine` | อยู่ใน quarantine · `purge_on` · `last_verified_404` · `open_leak` |
| `v_media_usage_blocked` | หน้าที่อ้างภาพที่ใช้ไม่ได้ (ด่านตอน build) |
| `v_media_text_issues` | alt ขาด / เก่า / ภาพจำลองผลลัพธ์ไม่มีป้าย |

---

## 10. ติดตั้ง Ayrel ให้แบรนด์ใหม่

**การ์ด og (ส่วนที่ 1)**
1. **slot spec**: เปิด `*Hero.astro` ทุกตัว จดสัดส่วนกรอบ · `object-position` · สิ่งที่ทับ · template ไหนไม่แสดงภาพ → `design/hero-slots.json`
2. **ค่าการ์ด**: `design/og-card.json` — ฟอนต์ display + ฟอนต์ต่อ locale · สีหลัก · สีแถบสองโทน · โลโก้สี/ขาว · R2
3. **โค้ด**: คัดลอก `web/scripts/ayrel/` · `og-cards.json` = `{}` · `Base.astro` อ่าน `og-cards.json` ก่อน `socialCard()` · `socialCard()` ครอปตาม focus ของ template
4. **ครอปที่ขอบ**: ทุก component ที่โชว์ภาพในกรอบต่างสัดส่วน ใช้ width+height+fit+gravity (A2) ก่อนใส่ภาพจริง

**ทะเบียนภาพ (ส่วนที่ 2)**
5. **bucket 2 ตัว** (Dashboard → R2, ไม่ผูก domain, ไม่เปิด public): `<brand>-gated` และ `<brand>-quarantine` · ตรวจผ่าน API: `domains/custom` ว่าง · `domains/managed.enabled = false`
6. **token เดียว** (ระบบส่ง header ไป `api.cloudflare.com` ได้ทีละตัว): **Workers R2 Storage: Edit** + **Zone → Cache Purge** ของโดเมนแบรนด์ · ห้ามใช้ token deploy · เก็บค่าไว้ใน password manager ตอนสร้าง (Cloudflare แสดงครั้งเดียว — ลืมแล้วต้อง Roll)
7. **secret** ใน repo แบรนด์: `CLOUDFLARE_MEDIA_TOKEN` (+ `SUPABASE_SERVICE_KEY` ที่ deploy ใช้อยู่)
8. **`design/media.json`**: brand_id · account_id · zone_id · ชื่อ 3 bucket · public_cdn · gate_hosts · quarantine_days
9. **Worker**: `worker/media-gate.ts` + route `/media/*` ก่อน `ASSETS` · binding `GATED_MEDIA` ใน `wrangler.jsonc` และ `wrangler.preview.jsonc` · token deploy ต้องผูก R2 binding ได้
10. **workflow**: `media-sweep.yml` บน `main` (B10) + ขั้น `check-media.mjs` ใน deploy ก่อน build
11. **ทดสอบครบวงจร** ก่อนลงภาพบุคคลจริง: ภาพสังเคราะห์ → ลงทะเบียน Active → `/media` 200 → เลื่อน `use_until` เป็นพรุ่งนี้ → guard เปลี่ยนเป็น Expired → sweep → `/media` 404 + quarantine + events ครบ → ลองเปลี่ยนกลับเป็น Active ต้องถูกปฏิเสธ · ตั้งชื่อแถวให้รู้ว่าเป็นการทดสอบ (แถวและ events อยู่ถาวร)

---

## 11. ผลนำร่อง (vth, 2026-11-20/21)

- ทะเบียน: `mda_B6F9C02130644397` hero AI ของ `/teeth-whitening/` · `mda_3D3856E6C01843B9` การ์ด og th · usage 3 · alt th ครบ
- ทดสอบปลดภาพบนเว็บจริงด้วยภาพสังเคราะห์ `mda_DCC402F7072B4D0D`: `/media` 200 → Expired อัตโนมัติ → quarantine (สำเนาตรงทุก byte) → `/media` 404 → ตรวจ 404 ครบ 3 host จาก GitHub Actions → พยายามเปลี่ยนกลับเป็น Active ถูกปฏิเสธ · ลบถาวรตามกำหนด 2027-02-18
- migration DR-085 ทดสอบ 53/53 บน Postgres 16 ก่อน apply · Worker gate 5 test + Worker เดิม 48 test ผ่าน

---

## 12. ค้าง / รู้แล้วยังไม่แก้

| เรื่อง | ผลกระทบ | ที่ |
|---|---|---|
| `ui/Image.astro` ขอแค่ความกว้าง | ภาพที่สัดส่วนไม่ตรงกรอบจะเบลอ (Concern 48 · Technology 9 · Branch · LocalService · Quiz) | vth `web/src/components/ui/Image.astro` |
| component ยังอ่าน `src` จาก YAML | ภาพบุคคลต้องชี้ `/media/<key>` เอง · ยังไม่มี helper ที่ดึงจากทะเบียน + `seo_servable_media` ตอน build | vth — ทำพร้อมภาพบุคคลภาพแรก |
| รูปแพทย์ใน `seo_authors_reviewers.photo_url` (1 แถว) | ยังไม่อยู่ในทะเบียน ไม่มีวันหมดอายุ | รอข้อมูลความยินยอมของแพทย์ |
| `seo_reviews.review_photos` | ภาพรีวิวคนจริงอยู่นอกทะเบียน (ตอนนี้ 0 แถว) | ย้ายเข้าทะเบียนก่อนมีข้อมูลจริง |
| ป้ายภาพจำลองผลลัพธ์บนตัวภาพ | ทะเบียนเตือนที่ alt แล้ว แต่ component ยังไม่วางป้ายบนภาพอัตโนมัติ | component + Ayrel builder |
| bucket gated ของ vth อยู่ ENAM | ภาพบุคคลช้าขึ้น ~0.1–0.2 วิ | สร้างใหม่ที่ APAC ผ่าน Dashboard ถ้าต้องการ |
| Notion Media Library sync | ทะเบียนยังไม่ sync กับ Notion (`alt_th`/`alt_en` คงไว้ให้ mirror) | หลังระบบนิ่ง |
| เครื่องมืออยู่ใน vth | แบรนด์อื่นต้องคัดลอก | ย้ายเป็นของกลางเมื่อนิ่ง |
| `og_tagline` ซ้ำชื่อบริการ | ต้อง override รายหน้า | พิจารณาตัดชื่อ entity ภาษาไทยออกจาก default |
| Bible ยังไม่มีหัวข้อภาพ/og | — | เพิ่มเมื่อนำร่องนิ่ง |

---

## 13. ประวัติ

| เวอร์ชัน | วันที่ | อะไร |
|---|---|---|
| 1.2 | 2026-11-21 | ส่วนที่ 2 ทะเบียนภาพ (DR-085): §5–§9 · หลักการ B1–B10 · วงจรรายวัน · runbook · view · ติดตั้ง ข้อ 5–11 · ผลนำร่อง · pipeline เพิ่มขั้น register · vth: `83e9c93` (gate/sweep/build gate) · `ccb784d` (workflow บน main) · `6a6273e` (unverified ≠ leak) |
| 1.1 | 2026-11-20 | A6a alt การ์ด og (`og_image_alt` + `og_image_alt_resolved`, migration `2026-11-20b`) · A10: ภาพ AI ทั่วไปไม่ติดป้าย · ภาพผลลัพธ์/ก่อน-หลังจาก AI ติดป้ายบนภาพ (operator) · `imagery.md` แก้ตาม |
| 1.0 | 2026-11-20 | ฉบับแรก จากนำร่อง vth `/teeth-whitening/`: hero `4f8159e` · การ์ดมือถือคม `0e10fb0` · og ชิดขวา `28e3f49` · Ayrel builder `fc0f2e2` · การ์ดแรก `e82e412` · ตั้งชื่อ `05b2e17` |
