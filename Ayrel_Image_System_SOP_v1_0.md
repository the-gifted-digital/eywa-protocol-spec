# 🖼️ AYREL — EYWA Image System

> **เวอร์ชัน:** 1.1 · **ประกาศใช้:** 2026-11-20 (นำร่อง) · **v1.1:** A10 แยกภาพ AI ทั่วไป (ไม่ติดป้าย) กับภาพผลลัพธ์ (ติดป้ายบนภาพ)
> **ขอบเขต:** **UNIVERSAL** (คอลัมน์ `og_*` ในตารางแชร์) · ตัวสร้างการ์ดยังอยู่ใน repo ของแบรนด์นำร่อง — ย้ายเป็นของกลางเมื่อใช้ครบหลายหน้าแล้วนิ่ง
> **ที่มา:** field-tested กับ VTH BioDent — หน้า `/teeth-whitening/` (hero → การ์ดมือถือ → og card ขึ้นเว็บจริง 2026-11-20)
> **Companion:** DR-084 (ฉบับนี้) · DR-035 / DR-040 R2 · DR-038 `seo_media_assets` · BROADCAST-2026-11-17 แถวต่อภาษา · `templates/folder-skeleton/design/brand-foundation/imagery.md`
>
> **Ayrel** [aj.ˈrɛl] — Na'vi แปลว่า "ภาพ (หลายภาพ)" (*ay-* พหูพจน์ + *rel* ภาพ) เข้าชุดกับ **EYWA** (เครือข่ายความรู้) · **Tsaheylu** (สัญญาณ conversion) · **Pamrel** (การเขียน — *pam* เสียง + *rel* ภาพ)
> *ความหมายยังไม่ได้ตรวจกับพจนานุกรม Na'vi ฉบับทางการ — ตรวจก่อนใช้ในเอกสารเผยแพร่*

---

## 0. AYREL คืออะไร

ภาพจาก AI **หนึ่งภาพต่อหนึ่งหน้า** ที่ถูกออกแบบมาตั้งแต่ตอนสั่งสร้างให้ใช้ได้ทุกช่องของ template นั้น — hero เดสก์ท็อป · การ์ดมือถือ · การ์ด og — และ**ทุกภาษา** (ภาษาที่เพิ่มเปลี่ยนแค่ข้อความบนการ์ด ไม่เสียเครดิต AI)

```
"ทำภาพหน้า <slug> ตาม AYREL"
```

### ชุดประกอบ

| ชั้น | สิ่งที่มี | อยู่ที่ |
|---|---|---|
| **สเปกกลาง** | ฉบับนี้ · DR-084 | `eywa-protocol-spec/` |
| | คอลัมน์ `og_display` · `og_tagline` · `og_style` · `og_image_url` · `og_image_generated_at` + view `v_page_og_card` | `seo_website_page_master` (Schema v1.31) |
| **ของแบรนด์** | **Ayrel slot spec** — สัดส่วน · ครอปต่อช่อง · สิ่งที่ทับ · safe zone ต่อ template | `<brand>/design/hero-slots.json` |
| | ค่าตั้งต้นการ์ด og — ฟอนต์ต่อภาษา · แถบสว่าง/เข้ม · เกรน · โลโก้ · ปลายทาง R2 | `<brand>/design/og-card.json` |
| **เครื่องมือ** | `npm run ayrel:build` — render การ์ด → R2 → เขียนกลับ DB → `og-cards.json` | `<brand>/web/scripts/ayrel/` |
| | สร้างภาพ: Higgsfield MCP `generate_image` (`gpt_image_2_6`) | connector ของ session |
| **ผลลัพธ์** | ภาพ hero ใน R2 `services/<slug>/hero-v<n>.webp` · การ์ด `og/<slug>-v<n>.jpg` · `src/data/og-cards.json` | R2 + brand repo |

> 🔴 **slot spec คือกฎของภาพ · `v_page_og_card` คือข้อความ · สคริปต์คือตัวบังคับ** — ภาพที่ไม่ได้วางจุดเด่นตาม safe zone จะเสียอย่างน้อยหนึ่งช่องเสมอ

---

## 1. Pipeline — 9 ขั้น

```
1. slot       อ่าน design/hero-slots.json ของ template หน้านั้น      → สัดส่วน + safe zone
2. prompt     เขียน prompt ตาม §3 (จุดเด่นใน safe zone · สีจาก tokens)
3. generate   Higgsfield gpt_image_2_6 · 2K · count 2 (เลือก 1)        → ~5.5 เครดิต
4. preview    สลับภาพบนหน้าเว็บจริงในเบราว์เซอร์ (เดสก์ท็อป 1440 + iPhone DPR 3)
5. approve    operator เลือกภาพ — ก่อนแตะ R2 หรือ repo
6. upload     R2 <prefix>/<slug>/hero-v<n>.webp (2160x900 สำหรับ 2.4:1, WebP q82, < 200 KB)
7. content    hero.image.src + alt ใน src/content/<template>/<locale>/<slug>.yaml → push → ตรวจหน้าจริง
8. og         og_tagline / og_display (ถ้าต้อง override) → npm run ayrel:build -- --slug <slug> --dry-run
              → ดู out/*.jpg → รันจริง → commit og-cards.json → push → ตรวจ og:image บนหน้าจริง
9. refresh    Facebook Sharing Debugger → Scrape Again (LINE อัปเดตเองภายในไม่กี่วัน)
```

ขั้น 4–5 ห้ามข้าม: ไฟล์ภาพที่สวยไม่ได้แปลว่าครอปบนเว็บสวย (§2 A1, A11)

---

## 2. หลักการ

### A1 · ภาพเดียว ต้องจัดองค์ประกอบเพื่อ "ส่วนที่ทุกครอปเห็นร่วมกัน"
ภาพ hero ของ Service (vth) ถูกเห็นสามแบบ: เดสก์ท็อปครึ่งซ้ายมีหัวข้อทับ · มือถือครอปสี่เหลี่ยมที่ `78% 40%` และครึ่งล่างมีกระจกฝ้าทับ · og ครึ่งล่างมีแถบข้อความ → จุดเด่นต้องอยู่ช่วง **x 0.50–0.87, y 0.15–0.60** ของภาพ ถึงจะรอดทั้งสามช่อง · ภาพแรก (teeth-whitening) จุดเด่นเริ่มที่ x ≈ 0.42 — แผ่นเทียบสีด้านซ้ายจึงจมใต้หัวข้อบนการ์ด og · safe zone ของทุก template อยู่ใน slot spec

### A2 · ครอปที่ขอบ (edge) ให้เป็นรูปกรอบ ห้ามขอแค่ความกว้าง
`srcset` แบบ `640w` บอกความกว้างของภาพ**ทั้งภาพ** ถ้ากรอบโชว์แค่ส่วนกลาง (สี่เหลี่ยมจากภาพ 2.4:1) เบราว์เซอร์จะยืดไฟล์เล็กให้เต็มกรอบ — การ์ดมือถือ vth เบลอ ~4 เท่าบน iPhone (ไฟล์ 640x267 ในกรอบ 350x350 CSS ที่ DPR 3) · แก้ด้วย Cloudflare `width=N,height=N,fit=cover,gravity=X×Y` + `sizes` = ขนาดกรอบจริง · ใช้กับทุก component ที่ภาพต้นฉบับสัดส่วนไม่ตรงกรอบ (`ui/Image.astro` ยังค้าง — §6)

### A3 · Cloudflare `gravity=X×Y` = CSS `object-position X% Y%`
วัดแล้ว: `gravity=0.78x0.4` ต่างจาก `object-[78%_40%]` เฉลี่ย 1.75/255 · การตีความว่าเป็น "จุดกึ่งกลางของครอป" (0.663) พลาด 36.75 → ใช้ค่าเดียวกับ CSS ได้ตรง ๆ ทั้งใน slot spec และ `og_style.focus`

### A4 · key ใน R2 มีเวอร์ชันเสมอ และห้ามยิงทดสอบ URL ก่อนอัปโหลด
CDN จำผล 404 ของ key ที่เคยถูกเรียกก่อนมีไฟล์ (เจอจริง: `hero.webp` ค้าง 404 หลังอัปโหลดแล้ว) · ใช้ `-v<n>` ทุกครั้ง เปลี่ยนภาพ = เวอร์ชันใหม่ ไม่เขียนทับ

### A5 · 1 แถว page_master = 1 หน้า 1 ภาษา = 1 การ์ด og
ภาพถ่ายใช้ร่วมทุกภาษา · ข้อความเป็นของแต่ละแถว · ไฟล์ `og/<slug>-v<n>.jpg` (slug ของแถวคำแปลมี `-<locale>` อยู่แล้ว) · `og-cards.json` ผูกด้วย URL path

### A6 · ค่าเริ่มต้นมาจากข้อมูลที่มีอยู่ — เขียนเฉพาะเมื่อ override
`og_display` NULL = ชื่อ entity ภาษาอังกฤษ (`seo_entity_graph.entity_name`) · `og_tagline` NULL = `seo_title` ก่อน ` | ` · ไม่คัดลอกมาเก็บ · override เมื่ออ่านแล้วไม่ดี — กรณีที่เจอบ่อย: **seo_title ขึ้นต้นด้วยชื่อบริการ** ทำให้บรรทัด 2 ซ้ำบรรทัด 1 ("Teeth Whitening / ฟอกสีฟัน เลือก…") → ตั้ง `og_tagline` ตัดชื่อบริการออก · แถวที่ไม่มี `primary_entity_fp` (1,198 แถวตอน apply) ต้องมี `og_display` ก่อนสร้างการ์ด

### A7 · สองบรรทัด ห้ามตัดบรรทัด — ไม่พอให้ล้ม
บรรทัด 1 Fraunces (ฟอนต์ display ของแบรนด์) 84 → ขั้นต่ำ 56px · บรรทัด 2 ฟอนต์ของภาษา 36 → 26px · ต่ำกว่าขั้นต่ำแล้วยังไม่พอ = FAIL ให้แก้ข้อความ · การตัดบรรทัดภาษาไทยอัตโนมัติตัดกลางวลี ("…อย่างไร ควร / เลือก…") จึงไม่ยอมให้ wrap · ฟอนต์ ja/ko ถูก subset ตามข้อความที่เว็บใช้ — สคริปต์เช็ก glyph ทุกตัว

### A8 · สีบรรทัด 1 = สีหลักของแบรนด์ โทนแถบเลือกให้ contrast ≥ 3:1
สีหลักน้ำเงินบนแถบน้ำเงินอ่านไม่ออก (vth `#3F60B2` บนแถบน้ำเงิน 1.5:1) → สีหลักเข้มใช้แถบสว่าง สีหลักอ่อนใช้แถบเข้ม · override ได้ (`og_style.band`, `display_color`) แต่ต่ำกว่า 3:1 สคริปต์เตือน

### A9 · เกรนต้องแรง
ฟีด Facebook / LINE บีบอัดภาพซ้ำ เกรนอ่อนหายหมด · ค่าตั้งต้น 0.85 (operator เลือก "มาก" 2026-11-20)

### A10 · ภาพ AI ทั่วไปไม่ติดป้าย · ภาพที่แสดงผลลัพธ์การรักษาต้องติดป้ายบนภาพ
(operator 2026-11-20)
- **ภาพประกอบทั่วไป** — มือในถุงมือ อุปกรณ์ โมเดลฟัน บรรยากาศ ภาพอธิบายกลไก → **ไม่ต้องบอกว่าเป็นภาพ AI**
- **ภาพที่แสดงหรือสื่อถึงผลการรักษา** — ภาพจำลองผลลัพธ์ · ก่อน/หลัง · "หลังทำจะเป็นแบบนี้" → **ต้องมีป้ายที่มองเห็นบนตัวภาพ** และประโยคเดียวกันใน alt
  - ไทย: **"ภาพจำลองผลลัพธ์ที่สร้างด้วย AI ไม่ใช่ผลการรักษาจริง ผลลัพธ์ของแต่ละคนแตกต่างกัน"**
  - อังกฤษ: **"AI-generated simulation — not an actual treatment result. Results vary."**
  - ภาษาอื่นแปลตามแถวของภาษานั้น · ป้ายอยู่**บนภาพ** (ไม่ใช่แค่ใต้ภาพ) เพราะภาพถูกแชร์หรือครอปแยกจากหน้าได้ — รวมถึงการ์ด og ที่สร้างจากภาพแบบนี้
  - ตรวจกับข้อกำหนดโฆษณาสถานพยาบาลของแบรนด์ก่อนเผยแพร่ทุกครั้ง: ภาพจำลองผลลัพธ์อาจถูกมองว่าเป็นการโฆษณาผลการรักษา แม้มีป้ายแล้ว
- **ห้ามเสมอ** — ใบหน้า AI ที่ดูเป็นแพทย์หรือผู้ป่วยจริง · ภาพ AI ที่อ้างว่าเป็นเคสจริง
- template ที่ต้องเป็นภาพจริง (Doctor, CaseStudy) ตั้ง `realPhotoOnly` ใน slot spec — สคริปต์ไม่สร้างการ์ดให้ · ภาพเคสจริงต้องมี consent ตาม PDPA (`imagery.md`)

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

ตัวอย่างที่ใช้จริง (teeth-whitening, Service 2.4:1): มือในถุงมือถือแผ่นเทียบสีข้างโมเดลฟัน · พื้น `#F6FAFE`→`#EAF4FF` · accent `#375172` / `#3F60B2`

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

## 5. ติดตั้ง Ayrel ให้แบรนด์ใหม่

1. **วัด slot spec**: เปิด `*Hero.astro` ทุกตัว จดสัดส่วนกรอบ · `object-position` · สิ่งที่ทับ · template ไหนไม่แสดงภาพ → `design/hero-slots.json` (โครงเดียวกับ vth ต่างแค่ตัวเลข)
2. **ค่าการ์ด**: `design/og-card.json` — ฟอนต์ display + ฟอนต์ต่อ locale (ไฟล์ใน `public/fonts`) · สีหลัก · สีแถบสองโทน · โลโก้สี/ขาว (trimmed PNG) · R2 account/bucket/cdn
3. **R2 token**: สร้าง token ใหม่สิทธิ์ **Workers R2 Storage: Edit** อย่างเดียว — ห้ามใช้ token deploy (roll ทีหลังแล้ว CI พัง) · ใส่เป็น network secret / env `CLOUDFLARE_R2_TOKEN` เท่านั้น ห้ามวางในแชทหรือ commit
4. **โค้ด**: คัดลอก `web/scripts/ayrel/` · `og-cards.json` = `{}` · `Base.astro` อ่าน `og-cards.json` ก่อน `socialCard()` · `socialCard()` ครอปภาพของหน้าเองตาม focus ของ template (vth: `gravity=1x0.5`)
5. **ครอปที่ขอบ**: ทุก component ที่โชว์ภาพในกรอบต่างสัดส่วน ใช้ srcset แบบ width+height+fit+gravity (A2) ก่อนใส่ภาพจริง
6. **นำร่องหนึ่งหน้า** ตาม §1 แล้วตรวจ A11 ก่อนขยาย

---

## 6. ค้าง / รู้แล้วยังไม่แก้

| เรื่อง | ผลกระทบ | ที่ |
|---|---|---|
| `ui/Image.astro` ขอแค่ความกว้าง | ภาพที่สัดส่วนไม่ตรงกรอบจะเบลอ (Concern 48 · Technology 9 · Branch · LocalService · Quiz) — ยังไม่เห็นเพราะเป็น placeholder | vth `web/src/components/ui/Image.astro` |
| ป้ายภาพจำลองผลลัพธ์ยังไม่มีตัวบังคับ | ภาพผลลัพธ์จาก AI ขึ้นเว็บได้โดยไม่มีป้าย ถ้าคนลืม | เพิ่ม `image.kind: result-simulation` ใน content → component วางป้ายบนภาพ + alt · Ayrel builder ใส่ป้ายบนการ์ด og ด้วย |
| ตัวสร้างการ์ดอยู่ใน vth | แบรนด์อื่นต้องคัดลอก | ย้ายเป็นของกลางเมื่อนิ่ง (DR-084 ข้อ 9) |
| `og_tagline` ซ้ำชื่อบริการ | ต้อง override รายหน้า | พิจารณาตัดชื่อ entity ภาษาไทยออกจาก default ใน `v_page_og_card` เมื่อเห็นรูปแบบครบ |
| Bible ยังไม่มีหัวข้อ og image | — | เพิ่มเมื่อนำร่องนิ่ง |

---

## 7. ประวัติ

| เวอร์ชัน | วันที่ | อะไร |
|---|---|---|
| 1.1 | 2026-11-20 | A10: ภาพ AI ทั่วไปไม่ติดป้าย · ภาพผลลัพธ์/ก่อน-หลังจาก AI ติดป้ายบนภาพ (operator) · `imagery.md` แก้ตาม |
| 1.0 | 2026-11-20 | ฉบับแรก จากนำร่อง vth `/teeth-whitening/`: hero `4f8159e` · การ์ดมือถือคม `0e10fb0` · og ชิดขวา `28e3f49` · Ayrel builder `fc0f2e2` · การ์ดแรก `e82e412` · ตั้งชื่อ `05b2e17` |
