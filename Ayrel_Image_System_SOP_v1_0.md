# 🖼️ AYREL — EYWA Image System

> **เวอร์ชัน:** 1.7 · **ประกาศใช้:** 2026-11-20 (นำร่อง) · **v1.7:** hero ใช้ high 1K เป็นค่าเริ่ม (A19) · ราคาเครดิตใหม่ของ Higgsfield (§4) · **v1.6:** ชุดภาพหลายภาพ (A17) · ครอปห้ามเติมขอบ (A18) · เลือกผู้ให้บริการ + เทียบต้นทุน (§4) · ผล PNCL หน้าแรก · **v1.5:** ภาพประกอบ medium 1K เป็นค่าเริ่ม (operator ยืนยัน) · รูปทีมงาน 5 คนเข้าประตู · inventory แก้ตามการดูภาพจริง · **v1.4:** ส่วนที่ 0 Bootstrap — โปรไฟล์แบรนด์ `design/ayrel.json` · สำรวจภาพทุกไฟล์ · `ayrel:doctor` · ข้อความบนภาพประกอบเป็น overlay (A15) · ผลตรวจขั้นสุดท้าย · **v1.3:** ภาพประกอบในเนื้อหา (สูงสุด 3 ช่องต่อหน้า Service) · ทำภาพครบทั้งหน้า (hero + ภาพประกอบ + og) · ย้ายภาพบุคคลออกจาก CDN public · **v1.2:** ส่วนที่ 2 ทะเบียนภาพ (DR-085) — ลงทะเบียน · alt ต่อภาษา · ใช้ซ้ำข้ามหน้า · ภาพบุคคลปลดอัตโนมัติ · quarantine 90 วัน · กันไหลย้อน · runbook
> **ขอบเขต:** **UNIVERSAL** (คอลัมน์ `og_*` + ทะเบียนภาพในตารางแชร์) · เครื่องมือฝั่งแบรนด์ยังอยู่ใน repo แบรนด์นำร่อง (vth) — ย้ายเป็นของกลางเมื่อนิ่ง
> **ที่มา:** field-tested กับ VTH BioDent — `/teeth-whitening/` (hero → การ์ดมือถือ → og card, 2026-11-20) · ทดสอบปลดภาพครบวงจรบนเว็บจริง (2026-11-21) · `/dental-veneers/` ทำภาพครบทั้งหน้า + ย้ายรูปแพทย์เข้าประตู `/media` (2026-11-21)
> **Companion:** DR-084 (การ์ด og) · DR-085 (ทะเบียนภาพ) · DR-038 `seo_media_assets` · DR-035 / DR-040 R2 · BROADCAST-2026-11-17 แถวต่อภาษา · SmileScape SS-DR-015/016 · `templates/folder-skeleton/design/brand-foundation/imagery.md`
>
> **Ayrel** [aj.ˈrɛl] — Na'vi แปลว่า "ภาพ (หลายภาพ)" (*ay-* พหูพจน์ + *rel* ภาพ) เข้าชุดกับ **EYWA** (เครือข่ายความรู้) · **Tsaheylu** (สัญญาณ conversion) · **Pamrel** (การเขียน — *pam* เสียง + *rel* ภาพ)
> *ความหมายยังไม่ได้ตรวจกับพจนานุกรม Na'vi ฉบับทางการ — ตรวจก่อนใช้ในเอกสารเผยแพร่*

---

## 0. AYREL คืออะไร

1. **ภาพเดียว ใช้ได้มากที่สุด** — ภาพ hero จาก AI หนึ่งภาพต่อหน้า ออกแบบตั้งแต่ตอนสั่งสร้างให้ใช้ได้ทุกช่องของ template (hero เดสก์ท็อป · การ์ดมือถือ · การ์ด og) และ**ทุกภาษา** · บวก**ภาพประกอบในเนื้อหา**ได้สูงสุด 3 ภาพ (A13)
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
| **ของแบรนด์** | **Ayrel slot spec** — สัดส่วน · ครอปต่อช่อง · สิ่งที่ทับ · safe zone ต่อ template · ช่องภาพประกอบ (`templates.service.illustrations`) | `<brand>/design/hero-slots.json` |
| | **โปรไฟล์แบรนด์** — การตัดสินใจเรื่องภาพทั้งหมด + inventory (ส่วนที่ 0) | `<brand>/design/ayrel.json` |
| | ค่าตั้งต้นการ์ด og | `<brand>/design/og-card.json` |
| | ค่าทะเบียน: brand_id · account/zone · 3 bucket (public / gated / quarantine) · host · 90 วัน | `<brand>/design/media.json` |
| **เครื่องมือ** | `npm run ayrel:build` — การ์ด og | `<brand>/web/scripts/ayrel/` |
| | `npm run ayrel:sweep` — ปลดภาพ · quarantine · manifest · ตรวจ 404 · ลบถาวร | `<brand>/web/scripts/ayrel/media-sweep.mjs` |
| | `npm run check:media` — ด่านตอน build | `<brand>/web/scripts/ayrel/check-media.mjs` |
| | `npm run ayrel:doctor` — ตรวจความพร้อม (ส่วนที่ 0) | `<brand>/web/scripts/ayrel/doctor.mjs` |
| | ภาพประกอบในเนื้อหา: field `illustrations` (Zod) + `SectionFigure` | `<brand>/web/src/content.config.ts` · `web/src/components/blocks/SectionFigure.astro` · `layouts/templates/Service.astro` |
| | ประตูภาพบุคคล `/media/<key>` | `<brand>/web/worker/media-gate.ts` |
| | Action รายวัน 00:20 ICT | `<brand>/.github/workflows/media-sweep.yml` (ต้องอยู่บน `main`) |
| | สร้างภาพ: Higgsfield MCP `generate_image` (`gpt_image_2_6`) | connector ของ session |

> 🔴 **slot spec คือกฎของภาพ · ทะเบียนคือความจริง · `seo_servable_media` คือทางเดียวที่ภาพขึ้นเว็บ · สคริปต์และ trigger คือตัวบังคับ**

---

# ส่วนที่ 0 — Bootstrap: เตรียมความพร้อมก่อนใช้ Ayrel

> ทำ**ครั้งเดียวต่อแบรนด์** ก่อนสร้างภาพแรก · จบเมื่อ `npm run ayrel:doctor` ไม่มี FAIL · WARN ที่เหลือต้องเขียนไว้ในโปรไฟล์ว่ารับไว้เพราะอะไร

## P1. ทำไมต้องมี

vth สร้าง Ayrel ไปพร้อมกับใช้ ไม่มีขั้นเตรียม — ตรวจขั้นสุดท้าย (2026-11-21) จึงพบสิ่งที่ควรรู้ตั้งแต่วันแรก:
- **ภาพคนจริง 7 ไฟล์อยู่นอกทะเบียน** — รูปแพทย์ไฟล์ที่สอง (ตัดพื้นหลัง) บน CDN public · `founder.webp` ที่ไม่มีโค้ดใช้แล้วแต่ยังเสิร์ฟอยู่ · รูปทีมงาน 5 คนใน `public/` ของ repo — ระบบปลดภาพปลดได้เฉพาะภาพที่รู้จัก
- **ภาพคนอีก 22 ไฟล์ไม่รู้ที่มา** (AI หรือ stock) — สองแบบนี้ต้องทำต่างกันตามกฎหมาย · ตอนแรกจัดกลุ่มจากชื่อไฟล์ได้ 25 ไฟล์ — ดูภาพจริงแล้ว 3 ไฟล์ไม่มีคน (`mbm-dashboard`, `slide-mbm`, `sq-slide-mbm`) → ยืนยันว่าต้องดูทีละไฟล์
- แบรนด์แต่ละแบรนด์ template ต่างกัน · ภาพเก่าอาจยังอยู่ที่ระบบเดิม (เช่น รูปแพทย์ Deezy ยังชี้ไป WordPress เดิม แม้เว็บใหม่เป็น Astro) · บางแบรนด์อยากมีข้อความบนภาพ

## P2. แบบสอบถาม → `design/ayrel.json`

คัดลอก `templates/folder-skeleton/design/ayrel.json` แล้วตอบทุกข้อกับ operator ของแบรนด์:

| หัวข้อ | คำถาม | ตัวเลือก / ค่าเริ่ม |
|---|---|---|
| `brand.stack` | เว็บสร้างด้วยอะไร | `astro-worker` (เครื่องมือชุดนี้ใช้ได้เลย) · `wordpress` · `other` → P4 |
| `brand.locales` / `content_locales` | ภาษาที่เว็บมี / ภาษาที่มีเนื้อหาของตัวเอง | alt ต้องครบทุก `locales` สำหรับภาพที่โชว์ในทุกภาษา |
| `imagery.mood` · `palette` | อารมณ์ภาพ · สีพื้น/สีเน้น | จาก brand tokens |
| `imagery.people` | ภาพ AI มีคนได้แค่ไหน | **`hands_only`** (ค่าเริ่ม) · `ai_people_allowed` · `no_people` |
| `hero.quality` / `resolution` | คุณภาพ hero | **high · 1k** (1.25 เครดิต) — ค่าเริ่ม ยืนยันแล้ว (A19) · high · 2k เฉพาะ hero ที่มีรายละเอียดเล็กมาก |
| `inline.enabled` · `templates` | template ไหนมีภาพประกอบ · กี่ภาพ · ช่องไหน · สัดส่วน | Service: 3 · 16:9 (A13) |
| `inline.quality` / `resolution` | คุณภาพภาพประกอบ | **medium · 1k** (1 เครดิต) — ค่าเริ่ม ยืนยันแล้ว (A16) · high · 2k เฉพาะภาพที่มีรายละเอียดเล็กมาก |
| `inline.text.mode` | อยากมีข้อความบนภาพประกอบไหม | `none` · **`overlay`** + `max_chars` (A15) — ไม่มีตัวเลือกให้ AI วาดตัวอักษร |
| `labels.result_simulation` | ป้ายภาพจำลองผลลัพธ์ต่อภาษา | ข้อความตาม A10 — แปลให้ครบ `locales` ที่จะใช้ภาพแบบนี้ |
| `persons.require_gate` | ภาพคนจริงต้องผ่านประตูไหม | **true** เสมอ (B1) |

## P3. สำรวจ template → `design/hero-slots.json`

เปิด component hero ทุกตัว จดต่อ template: สัดส่วนกรอบแต่ละจอ · `object-position` · สิ่งที่ทับภาพ (หัวข้อ · แถบกระจก) · template ไหนไม่โชว์ภาพ · template ไหนต้องเป็นภาพจริง (`realPhotoOnly`) · ความกว้างคอลัมน์เนื้อหา (กำหนดขนาดภาพประกอบ) — แล้วคำนวณ safe zone (A1) · ทุก collection ที่มีหน้าจริงต้องมี entry (doctor เช็ก)

## P4. stack และ adapter

| stack | การ์ด og | ภาพในหน้า | ประตูภาพบุคคล `/media` | งานรายวัน |
|---|---|---|---|---|
| `astro-worker` | `ayrel:build` → `og-cards.json` → `Base.astro` | YAML + component (vth) | `worker/media-gate.ts` | `media-sweep.yml` |
| `wordpress` | **ยังไม่มี adapter** — ต้องเขียน: ใส่ og:image จาก `og_image_url` (theme หรือ SEO plugin) | Media Library → ต้องเชื่อมกับทะเบียน | Cloudflare Worker แยกที่ route `/media/*` บนโซนเดียวกัน (โค้ดเดียวกับ vth) | ใช้สคริปต์เดิมได้ — เปลี่ยนแค่ขั้นสั่ง deploy |
| `other` | ประเมินก่อน | — | Worker route แยกได้เสมอถ้าโดเมนอยู่บน Cloudflare | — |

stack ที่ไม่ใช่ `astro-worker` = เขียน adapter และทดสอบก่อนถือว่า bootstrap ผ่าน

## P5. สำรวจภาพทุกไฟล์ (inventory)

ทุกไฟล์ภาพใน repo (`public/`, `src/`) ทุก `cdn('…')` และทุกไฟล์ใน bucket public ต้อง**ลงทะเบียนแล้ว** หรือ**ถูกจัดกลุ่ม**ใน `inventory` ของโปรไฟล์ — **ดูภาพทีละไฟล์** ห้ามเดาจากชื่อ (`pain-jaw.webp` มีคน · `hero.webp` ไม่มี)

| กลุ่ม | คืออะไร | ต้องทำก่อน go-live |
|---|---|---|
| `no_person` | ไม่มีคน หรือคนเล็กจนระบุตัวไม่ได้ | — (ลงทะเบียนเมื่อแตะภาพครั้งต่อไป) |
| `person_origin_unknown` | มีคน ยังไม่รู้ว่า AI หรือ stock | หาที่มา: **AI** → ลงทะเบียน `ai_generated` (ไม่ต้องผ่านประตู) · **stock มีนายแบบ/นางแบบ** → `consent_subject = 'model'` + วันหมดสิทธิ์ตาม license → ผ่านประตู |
| `real_person_pending_consent` | คนจริง (แพทย์ ทีมงาน คนไข้) รอข้อมูลความยินยอม | ได้ข้อมูล → ลงทะเบียน → ประตู → ลบไฟล์ public (runbook §8) |

ไฟล์ที่ไม่มีโค้ดใช้แล้วแต่ยังเสิร์ฟอยู่ (เช่น `founder.webp`) — ลบออกจาก repo/bucket · ไม่ใช่ปล่อยไว้

## P6. โครงสร้างพื้นฐาน

ตาม §10 ข้อ 1–10: migration DR-084/085/086 อยู่ในฐานข้อมูลแล้ว (ใช้ร่วมทุกแบรนด์) · bucket 3 ตัว (public / gated / quarantine) · token เดียว (R2 Edit + Cache Purge) · secret · Image Transformations เปิดบนโซน · Worker gate · workflow บน default branch · ขั้น `check-media` ใน deploy

## P7. `npm run ayrel:doctor`

```bash
cd web
CLOUDFLARE_MEDIA_TOKEN=… SUPABASE_SERVICE_KEY=… npm run ayrel:doctor      # --json สำหรับเครื่อง
```

| ส่วน | ตรวจอะไร |
|---|---|
| config | ไฟล์ทั้ง 4 อยู่และอ่านได้ · โปรไฟล์ตอบครบ · stack · `inline.text.mode` |
| templates | ทุก collection ที่มีหน้ามี slot spec · หน้าที่ยังเป็น placeholder · template ที่เปิดภาพประกอบรับ field `illustrations` |
| inventory | ทุกภาพถูกจัดกลุ่ม (**FAIL** ถ้ามีที่ยังไม่จัด) · คนจริงที่ยัง public · คนที่ไม่รู้ที่มา (WARN) |
| site | Worker route `/media/*` · binding · `check-media` ใน deploy · `og-cards.json` + `Base.astro` · `media-sweep.yml` บน default branch |
| cloudflare | bucket ครบและ gated/quarantine เป็นส่วนตัว · manifest · Image Transformations |
| database | คอลัมน์ og + view · ทะเบียน · view servable · หน้า Live · หน้า Live ที่ไม่มีบรรทัด 1 ของการ์ด |

ไม่มี key ตัวไหน → ส่วนนั้นเป็น SKIP ไม่ใช่ PASS · **ผ่าน = ไม่มี FAIL** · ใส่วันที่ใน `bootstrap.completed`

## P8. นำร่องก่อนเปิดใช้

1 หน้าครบชุด (hero + ภาพประกอบ + og) ตาม pipeline §1 → ตรวจบนหน้าจริงที่ DPR จริง (A11) · ทดสอบปลดภาพครบวงจรด้วยภาพสังเคราะห์ (§10 ข้อ 11) · แล้วจึงทำหน้าอื่น

---

# ส่วนที่ 1 — ภาพของหน้า และการ์ด og

## 1. Pipeline — 10 ขั้น

```
 1. slot       อ่าน design/hero-slots.json ของ template หน้านั้น      → สัดส่วน + safe zone
               + เลือกหัวข้อสำหรับภาพประกอบ (ไม่เกิน 3 · หัวข้อละ 1 · A13) จากเนื้อหาจริงของหัวข้อนั้น
 2. prompt     เขียน prompt ตาม §3 (จุดเด่นใน safe zone · สีจาก tokens) — hero 1 + ภาพประกอบทีละหัวข้อ
 3. generate   Higgsfield gpt_image_2_6 — ส่งทั้งชุดใน generate_image_batch ครั้งเดียว
               hero: high · 1k (1.25 เครดิต · 12:5 → ได้ 21:9 1344x576 แล้วครอปกลางเป็น 2.4:1 = 1344x560 ห้ามขยาย — A14, A19)
               ภาพประกอบ: medium · 1k (1 เครดิต · 1344x752 → ครอปเป็น 1337x752 — A16)
 4. preview    ฉีดภาพลงหน้าเว็บจริงในเบราว์เซอร์ (Playwright: แทน <source>/<img> ของ hero ·
               แทรก <figure> ท้ายหัวข้อ) เดสก์ท็อป 1440 + มือถือ 390 · ส่งภาพหน้าจอให้ operator
 5. approve    operator เลือกภาพ — ก่อนแตะ R2 หรือ repo
 6. upload     R2 <prefix>/<slug>/hero-v<n>.webp (2160x900 สำหรับ 2.4:1, WebP q82–86, < 200 KB)
               + <prefix>/<slug>/<section>-v<n>.webp (2048x1152 สำหรับ 16:9) → ตรวจ CDN 200 ทุกไฟล์
 7. register   แถวใน seo_media_assets (origin, kind, generation_model/job/prompt, key) + alt ทุกภาษาที่หน้ามี
               (seo_media_asset_texts, written_for_key = key) + usage ต่อช่อง (hero, mobile_card, og ·
               ภาพประกอบ = slot 'inline', position 1–3 ตามลำดับบนหน้า) — §8
 8. content    hero.image.src + alt · `illustrations:` (after / src / alt) ใน src/content/<template>/<locale>/<slug>.yaml
               → build ในเครื่อง → push → ตรวจหน้าจริงว่ามีทุก key
 9. og         og_tagline / og_display (ถ้าต้อง override) → npm run ayrel:build -- --slug <slug> --dry-run
               (ไม่มี SUPABASE_SERVICE_KEY ในเครื่อง: dump แถว v_page_og_card เป็น JSON → --rows <file> --no-db
               แล้วรัน UPDATE ที่สคริปต์พิมพ์ออกมาเอง)
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

### A12 · 2K พอ (แทนที่ด้วย A19 สำหรับ hero)
CDN ส่งภาพ hero กว้างสุด 1600px · ไม่สร้าง 4K · ภาพที่ไม่แสดงบนหน้า (Knowledge, Procedure) สร้างที่รูป og ตรง ๆ

### A19 · hero ใช้ high 1K
ทดสอบบนหน้า `/myofunction-tmj/` (2026-11-21): ขอ 12:5 ได้ 21:9 1344x576 → ครอปกลาง 2.4:1 = **1344x560** · ส่งขนาดตามที่ได้ ห้ามขยายเองก่อนอัปโหลด · เหตุผลที่พอ: CDN ส่ง hero ให้จอเดสก์ท็อป 1440 DPR 2 กว้างสุดแค่ **1600px** อยู่แล้ว (ไฟล์ 2K 2160px ถูกย่อเหลือ 1600 ก่อนถึงผู้ชมเสมอ) ความต่างจริงจึงเป็น 1344 กับ 1600 · มือถือ (ผู้ชมส่วนใหญ่) ไม่ต่าง · เดสก์ท็อป retina นุ่มกว่าเล็กน้อยที่เส้นผมและขนตา · operator ประเมินบนเว็บจริง: "มือถือชัดปกติ เดสก์ท็อปคมราว 90%" → **ค่าเริ่มของทุกแบรนด์** · ใช้ high 2K (2 เครดิต) เฉพาะ hero ที่ต้องอ่านรายละเอียดเล็ก · หน้าที่ทำไปแล้วที่ 2K ไม่ต้องทำใหม่

### A17 · ชุดภาพหลายภาพ (เช่น 5 แกนของหน้าแรก) — ทำทั้งชุดพร้อมกัน
บทเรียนจาก section PNCL ของ vth (2026-11-21, 5 รอบ ~64 เครดิต กว่าจะได้แนว):
1. **ทำใหม่ทั้งชุด ไม่ผสมของเก่า** — ภาพเดิม 1 ภาพที่ "ชอบที่สุด" ใช้เป็นต้นแบบสไตล์ได้ แต่ถ้าเก็บไว้ในชุด สีและวิธีเรนเดอร์จะไม่เข้ากับภาพที่สร้างใหม่เสมอ
2. **อ่านคำถามของแต่ละข้อก่อนเขียน prompt** — ภาพต้องตอบสิ่งที่ข้อนั้นถาม (เช่น "กระดูกและการสบฟันรองรับการเคี้ยวและรูปหน้า" → โหนกแก้ม + ขากรรไกร + ฟันที่สบ ไม่ใช่ฟันซี่เดียว)
3. **ภาพกายวิภาคล้วน (กะโหลก/กล้ามเนื้อเปลือย) ดูเหมือนผี** บนหน้าแรกของคลินิก → ใช้ **คนที่ดูมีชีวิต + โปร่งแสงเฉพาะส่วนที่เกี่ยวกับข้อนั้น** (ต้องตั้ง `imagery.people = ai_people_allowed`)
4. **พื้นจาก design system ของแบรนด์** (vth: Calm Gray `#EFEFEF` ← `#F7F9FC`) ส่วนโปร่งแสงใช้สีหลัก/สีรองของแบรนด์ — ไม่ใช้พื้นน้ำเงินเข้มหรือหมอก ถ้าแบรนด์ไม่ได้ใช้
5. **สเกลเดียวกันทุกภาพ** — เขียนในทุก prompt ("head-and-shoulders, head ~55% of frame height") ภาพฉากกว้าง (เช่น คนนอนบนเตียง) จะเล็กกว่าภาพอื่นเมื่อครอป
6. **ใบหน้า** — ระบุช่วงอายุ สภาพผิว ("fresh, healthy") และเชื้อชาติที่ operator ต้องการตรง ๆ · ใช้คนซ้ำในชุดได้ แต่บอก operator
7. **ต้นแบบสไตล์ทำได้สองทาง** — `media_import_url` จาก URL สาธารณะของภาพ (sandbox ไม่ต้องอัปโหลดเอง) หรือ `job_id` ของภาพที่สร้างไปแล้ว · ห้ามขยายสิทธิ์เครือข่ายเพื่ออัปโหลดถ้าใช้สองทางนี้ได้
8. **กรอบที่สัดส่วนต่างกันมากต่อจอ** (vth: 0.81 / 0.43 / 1.6) → ตั้ง `object-position` รายภาพ และตรวจครบทุกจอทุกภาพก่อนอัปโหลด

### A18 · ครอปห้ามเติมขอบ — ตัดด้านที่ยาวเกินเสมอ
Higgsfield ส่ง 3:2 มาเป็น 2048x1360 (เตี้ยกว่า 3:2 เล็กน้อย) — สคริปต์ที่คำนวณ "ความสูงจากความกว้าง" ได้ 1365 > 1360 แล้วครอปเกินภาพ Pillow เติมส่วนเกินเป็น**สีดำ 2–3 แถว**ที่ขอบบน เห็นเป็นเส้นดำเหนือภาพบนเว็บ (PNCL v1, แก้ใน v2) · ฟังก์ชันครอปต้องเลือกตัดความกว้างหรือความสูงตามสัดส่วนจริง และยืนยันว่าผลไม่ใหญ่กว่าต้นฉบับ · ตรวจค่าสีแถว/คอลัมน์ขอบทั้ง 4 ด้านก่อนอัปโหลด

### A16 · ภาพประกอบใช้ medium 1K
ทดสอบบนหน้า `/scaling/` (2026-11-21): ไฟล์ 1337x752 · มือถือ DPR 3 ต้องการ 1074 → พอ · เดสก์ท็อป DPR 2 ต้องการ 1544 → ขยาย ~15% · เทียบพิกเซลต่อพิกเซลกับ 2K แล้วขีดบนเครื่องมือและผิวหินปูนยังคม · operator ประเมินบนเว็บจริงแล้ว "เพียงพอ" → **ค่าเริ่มของทุกแบรนด์** · ส่งไฟล์ตามขนาดที่ได้ ห้ามขยายเองก่อนอัปโหลด (CDN ไม่ขยายเกินต้นฉบับ) · ใช้ 2K เมื่อภาพต้องอ่านรายละเอียดเล็ก (ตัวเลขบนเครื่องมือขนาดเล็ก ลายเส้นละเอียด)

### A13 · ภาพประกอบ: ท้ายหัวข้อ · หัวข้อละ 1 · ไม่เกิน 3 · ไม่ครอป
- วาง**ท้าย**หัวข้อเท่านั้น ห้ามแทรกกลางย่อหน้า — ภาพไม่ตัดเหตุผลที่กำลังอ่าน · ช่องที่ Service รองรับ: `definition` · `whoFor` · `process` · `comparison` · `clinicalInsight` · ลำดับบนหน้าตามลำดับหัวข้อ ไม่ใช่ลำดับใน YAML
- ภาพเต็มคอลัมน์เนื้อหา (772px เดสก์ท็อป · จอ − 2rem มือถือ) **สัดส่วนเดียวทุกจอ ไม่มีครอป** → ไม่มี safe zone · จัดองค์ประกอบทั้งเฟรม ให้วัตถุหลักอยู่ใน 90% กลาง · ค่าเริ่ม 16:9 (มี 3:2 · 4:3)
- ภาพต้อง**ตอบเรื่องของหัวข้อนั้น** ไม่ใช่ภาพสวยทั่วไป: วัสดุ → เทียบวัสดุ · ขั้นตอน → สิ่งที่เกิดก่อนเริ่มทำ · ความเชื่อผิด → สิ่งที่หักล้าง (เช่น วีเนียร์แก้แรงกัดไม่ได้ → ภาพเช็กการสบฟัน)
- schema ปฏิเสธ: placeholder · ไฟล์ที่ไม่อยู่บน CDN ของแบรนด์ · 2 ภาพในหัวข้อเดียว · เกิน 3 · alt สั้นกว่า 10 ตัวอักษร
- kind ในทะเบียน: `illustration` (ค่าเริ่ม) · `diagram` · `equipment` · `clinic_space` · ห้ามคนจริง · ห้ามข้อความในภาพ · ภาพจำลองผลลัพธ์ต้องมีป้าย (A10)

### A15 · AI ไม่วาดตัวอักษร — ข้อความบนภาพเป็น overlay
AI สะกดภาษาไทยผิดบ่อย · ข้อความที่ฝังในภาพแปลไม่ได้ แก้ไม่ได้ และ screen reader อ่านไม่ได้ → prompt ห้ามข้อความเสมอ · แบรนด์ที่อยากมีข้อความ เปิด `inline.text.mode = "overlay"` แล้วเขียน `overlay:` ใน YAML ของภาพนั้น — `SectionFigure` วางเป็นข้อความจริงบนภาพ (แถบกระจกมุมล่าง) ยาวไม่เกิน `max_chars` (schema ปฏิเสธเมื่อเกิน หรือเมื่อแบรนด์ปิดไว้) · ป้ายภาพจำลองผลลัพธ์ (A10) ใช้กลไกเดียวกัน: `simulation: true` → ป้ายจาก `labels.result_simulation` ตามภาษาของหน้า + ต่อท้าย alt · ข้อความ overlay ต่อภาษาเก็บที่ `seo_media_asset_texts.caption`

### A14 · สัดส่วนที่ขอ ≠ สัดส่วนที่ได้
Higgsfield ปัดไปสัดส่วนที่รองรับที่ใกล้สุด และบอกใน `adjustments` (12:5 → 21:9 = 2688x1152) · ขอให้กว้างกว่าหรือเท่ากรอบเสมอ แล้ว**ครอปกลาง**ให้ได้สัดส่วนจริงก่อนอัปโหลด · 16:9 ได้ 2688x1520 (1.768) → ครอปบน-ล่างเล็กน้อยเป็น 16:9 · เขียนขนาดที่สร้างและที่ส่งจริงไว้ใน `generation_prompt`

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

**ภาพประกอบ (16:9):**
```
Photorealistic <macro still life | photograph | close-up>, 16:9, <light clinical surface/room>.
<what the section is about, as objects: materials / models / equipment / hands in gloves>.
Soft daylight, neutral white and pale blue-grey palette, shallow depth of field,
subject centred within the middle 90% of the frame, no face, no patient, no text, no labels,
no logos, no watermark.
```

ตัวอย่างที่ใช้จริง (dental-veneers, 2026-11-21): hero = มือคีบแผ่นวีเนียร์เหนือโมเดลฟัน + ถาดวีเนียร์ + แผ่นเทียบสี · `definition` = แผ่นเซรามิกบางใส vs หลอดคอมโพสิต · `process` = โมเดลแว็กซ์จำลอง + หน้าจอสแกน 3 มิติ · `clinicalInsight` = กระดาษเช็กการสบฟันบน articulator

ตัวอย่างที่ใช้จริง (teeth-whitening, Service 2.4:1): มือในถุงมือถือแผ่นเทียบสีข้างโมเดลฟัน · พื้น `#F6FAFE`→`#EAF4FF` · accent `#375172` / `#3F60B2` · เก็บ prompt ฉบับใช้จริงไว้ใน `seo_media_assets.generation_prompt`

---

## 4. ค่าใช้จ่าย (Higgsfield, วัดจากบิล 2026-11-21)

ราคา GPT Image 2.6 เปลี่ยนระหว่าง 2026-11-20 20:01 กับ 2026-11-21 03:51 UTC (บิลจริง): medium 1K 0.5 → **1** · high 2K 2.75 → **2** · ตรวจราคาด้วย `estimate_image_cost` ก่อนสั่งชุดใหญ่ทุกครั้ง

| งาน | ค่าตั้ง | เครดิต (ราคาเดิม) |
|---|---|---|
| hero 2.4:1 / 16:9 / 21:9 | **high · 1K** (ค่าเริ่ม A19) | **1.25** |
| hero ที่ต้องอ่านรายละเอียดเล็ก | high · 2K | 2 (2.75) |
| hero ใดก็ได้ | high · 4K | 4.25 (ไม่ใช้) |
| ภาพประกอบ | medium · 1K | **1** (0.5) |
| ภาพประกอบ | high · 1K | 1.25 (1.5) |
| การ์ด og ต่อภาษา | HTML render | **0** |
| วิดีโอ 5 วิ (ภายหลัง) | Grok 1.5 Lite 720p / premium 1080p | 5 / 35–40 |

ต่อหน้า (hero 2 ตัวเลือก + การ์ดทุกภาษา) ≈ **5.5 เครดิต** · Plus 1,000 เครดิต ≈ 180 หน้า
ต่อหน้าแบบครบ (hero 1 ที่ **high 1K** + ภาพประกอบ 3 ที่ **medium 1K** + การ์ด) ≈ **4.25 เครดิต** ราคาใหม่ (วัดจริง myofunction-tmj · ถ้า hero 2K = 5) · ทำภาพใหม่ 1 ภาพ +1 เครดิต · Plus 1,000 เครดิต ≈ **235 หน้า** · (ภาพประกอบ 2K high ทั้งชุด ≈ 11 เครดิต ≈ 90 หน้า — dental-veneers) · ผ่าน MCP ใช้เครดิตเสมอ (สิทธิ์ unlimited ของแพ็กเกจใช้ได้เฉพาะบนเว็บ Higgsfield — ห้ามขับเบราว์เซอร์ไปใช้แทน ขัดเงื่อนไขของผู้ให้บริการ)

---

### ผู้ให้บริการ — เลือกต่อแบรนด์ แล้วเทียบด้วยข้อมูลจริง

ตั้งใน `design/ayrel.json` → `imagery.provider` (`higgsfield` · `openai_api`) และเขียนผู้ให้บริการไว้ใน `generation_model` ของทุกแถว เช่น `gpt_image_2_6 (Higgsfield)` / `gpt-image-2.6 (OpenAI API)`

| | Higgsfield Plus | OpenAI API | Codex (ChatGPT Plus) |
|---|---|---|---|
| ค่าคงที่ | $49/เดือน (1,000 เครดิต) | ไม่มี | ฿699/เดือน |
| hero 1K high (ค่าเริ่ม) | 1.25 เครดิต ≈ $0.06 | ยังไม่ประเมิน | หักโควตา Codex |
| hero 2K high | 2 เครดิต ≈ $0.10 | ≈ $0.17 (Batch ≈ $0.085) | หักโควตา Codex |
| ภาพประกอบ 1K medium | 1 เครดิต ≈ $0.05 | ≈ $0.03–0.04 | หักโควตา Codex |
| ต่อหน้า (ไม่ทำใหม่ / เผื่อ 1.5×) | ≈ $0.21 / $0.31 | ≈ $0.28 / $0.42 (hero 2K) | ไม่ประกาศเพดาน |
| ใช้จาก cloud session | ได้ (MCP) | ต้อง key + เปิดโฮสต์ `api.openai.com` | ต้องรันบนเครื่อง operator |

ตัวเลข OpenAI เป็นค่าประมาณจากราคา token ($30/ล้าน output token, Batch $15) — ยืนยันกับบิลจริงก่อนตัดสิน · จุดคุ้มทุน Higgsfield vs OpenAI Standard ≈ 115–120 หน้า/เดือน · **ตัดสินใจ 2026-11-21: ใช้ Higgsfield ไปก่อน ลอง OpenAI API กับบางแบรนด์ แล้วเทียบ** · แนวทางรายเดือน (operator): **เดือนที่ทำภาพจำนวนมาก** (หน้าใหม่ทั้งหมวด, ชุดภาพ) → ซื้อ Higgsfield เดือนนั้น · **เดือนเก็บตก / optimize** (แก้ทีละภาพ, เติมภาพประกอบ) → OpenAI API จ่ายตามที่ใช้ · ทั้งสองทางใช้โมเดลตระกูลเดียวกัน prompt และ pipeline ส่วนอื่นใช้ร่วมกันได้ · ก่อนเดือนแรกที่ใช้ OpenAI API ต้องเตรียม: key ผ่านแบบฟอร์ม credential ของ environment + อนุญาตโฮสต์ `api.openai.com` + สคริปต์สร้างภาพที่เขียนผลลง `generation_model` เป็น `… (OpenAI API)` · เทียบด้วย query นี้:

```sql
select brand_id, generation_model, count(*) filter (where status = 'Active') as accepted,
       count(*) as registered, sum(file_size_bytes) / 1e6 as mb
from seo_media_assets where origin = 'ai_generated' group by 1, 2 order by 1, 2;
-- ภาพที่สร้างแต่ไม่ได้ใช้ไม่อยู่ในทะเบียน — จดจำนวนครั้งที่สั่งสร้างจริงจากบิลของผู้ให้บริการ แล้วหารด้วย accepted
```

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

### B11 · ลบไฟล์ public แล้ว edge ยังเสิร์ฟได้อีกหลายนาที — ตรวจจนเป็น 404 จริง
purge URL ต้นฉบับสำเร็จแล้ว edge ยังส่งสำเนาเดิมได้ราว 5 นาที (วัดจริง 2026-11-21) · ภาพย่อ `/cdn-cgi/image/...` **purge ทีละ URL ไม่ได้** (Cloudflare error 1132) — หายตามต้นฉบับเอง · **อย่ายิงทดสอบ URL ย่อทันทีหลัง purge** การเรียกนั้นเองจะสร้างสำเนาใหม่จาก cache ต้นฉบับที่ยังไม่หมด · ตรวจซ้ำทุก 15 วินาทีจนทั้ง URL ตรงและ URL ย่อเป็น 404 แล้วจึงบันทึกว่าเสร็จ

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

**ย้ายภาพบุคคลที่อยู่บน CDN public อยู่แล้ว** (เช่น รูปแพทย์เดิม)
1. ลงทะเบียน + อัปโหลดเข้า gated ตามหัวข้อก่อนหน้า · ใส่ alt ทุกภาษา · usage ต่อหน้าที่ใช้ (slot `portrait`)
2. แก้โค้ด/ข้อมูลให้ชี้ `/media/<key>` → push → **รอ deploy ขึ้นจริง** แล้วตรวจทุกหน้าที่ใช้: มี URL ใหม่ · ไม่เหลือชื่อไฟล์เดิม
3. ค้นชื่อไฟล์เดิมทั้ง repo · build output · `seo_authors_reviewers` · `seo_media_assets` — ต้องไม่เหลือ
4. ลบ object เดิมจาก bucket public + purge URL เดิม → ตรวจจน 404 ทั้ง URL ตรงและ URL ย่อ (B11)
5. บันทึก event `note` บนแถวของภาพ (ลบอะไร · purge อะไร · ตรวจอะไร)
ห้ามลบไฟล์เดิมก่อนข้อ 2 — หน้าเว็บจะขึ้นภาพแตกระหว่างรอ deploy

**deploy ล้มที่ด่านที่ไม่เกี่ยวกับภาพ** — ภาพที่อัปโหลดแล้วยังไม่ขึ้นหน้า แต่ไฟล์ public อยู่บน CDN แล้ว (ไม่เป็นไรสำหรับภาพ AI) · **ห้ามลบไฟล์ภาพบุคคลเดิมจนกว่า deploy ใหม่จะขึ้น** · ตัวอย่าง 2026-11-20: ด่าน citation G5 ล้มเพราะอีกแบรนด์ลงข้อมูลผิดสเกล → แก้ต้นเหตุด้วย DR-086

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

**เริ่มจากส่วนที่ 0 (Bootstrap) เสมอ** — ข้อด้านล่างคือรายละเอียดของ P6 · ติดตั้งเสร็จเมื่อ `ayrel:doctor` ไม่มี FAIL

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
- **ภาพครบทั้งหน้า `/dental-veneers/`** (vth-3.7.10, 2026-11-21, deploy run 458 `29a9f84`): hero `mda_6C6680E898E94A93` (hero + mobile_card) · ภาพประกอบ `definition` `mda_0AA2C33EA43C4A6D` · `process` `mda_4A047FC1DFAD4301` · `clinicalInsight` `mda_FDA6B40D7C644502` · การ์ด og `mda_6DBA1B173FFA47DE` (`og_tagline` = "เลือกวัสดุแบบไหนดี และควรตรวจอะไรก่อนทำ") · ~11 เครดิต · preview บนหน้าจริงก่อนอัปโหลด → operator อนุมัติ → ตรวจหน้าจริงครบทุก key
- **ช่องภาพประกอบ** ใน Service template: `635d9a2` (schema + `SectionFigure` + slot spec)
- **หน้า `/scaling/` ภาพประกอบ medium 1K** (vth-3.7.6.1, `1fe2c7f` + `e2a09c8`): hero `mda_115BDE82A70D4D7E` · ภาพประกอบ `mda_275BCFEB5370411F` `mda_D4333222EBBE4409` `mda_E3E0DDFB35A54C81` (1337x752, 0.5 เครดิต/ภาพ) · การ์ด og v2 `mda_01EF0659EDFA4387` (operator เปลี่ยน tagline → key ใหม่ แถวใหม่ supersedes v1) · ทั้งหน้า ~4.25 เครดิต · บนจอ 2x เดสก์ท็อปขยาย ~15% — ดูขนาดปกติไม่ต่าง · **operator ยืนยัน 2026-11-21: เพียงพอ → ค่าเริ่ม (A16)**
- **ตรวจขั้นสุดท้าย (2026-11-21):** ทะเบียน 17 แถวของ vth · view เตือน/ปลด/บล็อกว่าง · quarantine 1 (ทดสอบ, ไม่รั่ว) · pg_cron รันสำเร็จ · ทุกหน้าที่ใช้ Ayrel โหลดภาพครบที่ iPhone DPR 3 และเดสก์ท็อป DPR 2 · og:image + og:image:alt ถูกทุกหน้า · พบภาพคนนอกทะเบียน (P1) → รูปแพทย์ไฟล์ที่สองย้ายเข้าประตูแล้ว (`1c51dd2`: `mda_678421CF2C044B20` 1080w · `mda_9EE74AB51EA1432B` 600w · alt 10 ภาษา) · `founder.webp` ลบ · alt ภาษาที่ขาดของรูปแพทย์ภาพแรกเติมครบ 10 ภาษา
- **รูปทีมงาน 5 คนเข้าประตู** (`6018e7a`, operator ยืนยันความยินยอม 2026-11-21 · ไม่มีวันสิ้นสุด → `use_forever`): `mda_46E307CB06E4468D` `mda_9F93CD4122634CC8` `mda_9169451E78824D54` `mda_3987F4797CD640B6` `mda_BE2B75AFACDD4CE7` · alt 10 ภาษาจาก home-copy · ไฟล์ใน `public/images/live/team-*` ลบ · manifest 8 key = `seo_servable_media` 8 แถว · ยังไม่มีแถวใน `seo_authors_reviewers` → `person_fp` ว่าง
- **ชุดภาพ PNCL หน้าแรก** (`c24a8a4` + `dc2b111`): 5 ภาพคน AI + โปร่งแสง บนพื้น Calm Gray · v2 `mda_9741371620CC4AEA` `mda_01582550CAB94C0F` `mda_9C3A48872BCD46D2` `mda_BE258E6A043E4914` `mda_ABE0364A904F4724` (แทน v1 ที่มีแถบดำ — A18) · alt 10 ภาษา · usage หน้าแรก 10 ภาษา · `object-position` รายภาพ · 5 รอบ ~64 เครดิตกว่าจะได้แนว (A17) · `framework-*` เดิม 4 ไฟล์ลบ (`framework-microbiome` เก็บไว้ให้ landing page 2 หน้า)
- **หน้า `/composite-veneer/`** (vth-3.7.10.1, `6508b55`): hero 2K `mda_412238B7F63A4ED1` · ภาพประกอบ `mda_85C42FC6C3F14FF3` `mda_11CC97E0730F4314` `mda_CFE58A22B1DB44E3` · og `mda_24334C81038A47D5` · thumb rev4 `mda_FB86B3E0A6AD4EE2` · tagline ตั้งโดย agent (operator อนุญาต)
- **หน้า `/myofunction-tmj/` — hero high 1K ครั้งแรก** (vth-3.4.1.16, `e3f8af7`): hero 1344x560 `mda_72CDD5D853574AFC` · ภาพประกอบ `mda_ADDCF3C91AF0451B` (คนโปร่งแสงแบบ PNCL ลิ้นแนบเพดาน — รอบแรกได้กล้ามเนื้อคอ ทำใหม่ 1 ครั้ง) `mda_FB1F32B8469948C8` `mda_A04EDA62AEF640B0` · og `mda_549263322E7B43B1` · thumb `mda_4B68A1E4CDA045B7` · คน AI ทั้งหน้าเพราะเนื้อหาเป็นกล้ามเนื้อใบหน้าและนิสัยการใช้ลิ้น · ทั้งหน้า 5.25 เครดิต (รวมทำใหม่) · **operator ยืนยัน 2026-11-21: hero 1K พอ → ค่าเริ่ม (A19)**
- **Bootstrap ย้อนหลังให้ vth** (`58fb2c4`): `design/ayrel.json` + inventory 71 ไฟล์ + 8 cdn() · `ayrel:doctor` = 40 pass · 2 warn · 0 fail (database SKIP ใน sandbox — ไม่มี key)
- **รูปแพทย์ภาพแรกเข้าประตู** `mda_1DB10A8FC0104217` (ทพ. อมรพงศ์ · staff · use_forever · usage vth-2.3): หน้าแพทย์ + หน้าที่มี reviewer ใช้ `/media/doctors/dr-amornpong/portrait-v1.webp` (200) · ไฟล์ public เดิม `dr-amornpong-vachiramon.webp` ลบ + purge → 404 ทั้ง URL ตรงและ URL ย่อหลัง ~5 นาที (B11)

---

## 12. ค้าง / รู้แล้วยังไม่แก้

| เรื่อง | ผลกระทบ | ที่ |
|---|---|---|
| `ui/Image.astro` ขอแค่ความกว้าง | ภาพที่สัดส่วนไม่ตรงกรอบจะเบลอ (Concern 48 · Technology 9 · Branch · LocalService · Quiz) | vth `web/src/components/ui/Image.astro` |
| component ยังอ่าน `src` จาก YAML / `team.ts` | alt ใน YAML กับทะเบียนอาจเพี้ยนกัน · ภาพบุคคลต้องชี้ `/media/<key>` เอง · ยังไม่มี helper ที่ดึงจากทะเบียน + `seo_servable_media` ตอน build | vth |
| ช่องภาพประกอบมีแค่ Service | Concern · Technology · Knowledge ฯลฯ ยังไม่มี `illustrations` | เพิ่มทีละ template ตาม A13 |
| ภาพคน 22 ไฟล์ไม่รู้ที่มา (vth) | ถ้าเป็น stock ต้องมีวันหมด license + ผ่านประตู · ถ้า AI ต้องลงทะเบียน | หาที่มาแล้วย้ายออกจาก `person_origin_unknown` |
| usage ของภาพบุคคลลงมือเอง | รูปแพทย์โชว์ใน byline ~500 หน้า แต่ usage มีแค่หน้าแพทย์/หน้าแรก · ถ้าหมดอายุ ประตูตอบ 404 (ไม่รั่ว) แต่ด่าน build ไม่รู้ว่าหน้าไหนจะภาพแตก | บันทึก usage อัตโนมัติจาก HTML ที่ build ได้ (แบบเดียวกับขั้นบันทึก internal links) |
| ส่วน database ของ `ayrel:doctor` | ยังไม่ได้รันจริง (sandbox ไม่มี key) | รันใน CI หรือเครื่องที่มี key ครั้งแรก |
| รูปแพทย์ Deezy ใน `seo_authors_reviewers.photo_url` (1 แถว, ชี้ไป WordPress เดิม) | ยังไม่อยู่ในทะเบียน ไม่มีวันหมดอายุ | Deezy (Astro) ติดตั้ง Ayrel เองที่ repo — เริ่มจากส่วนที่ 0 |
| ไฟล์ใน `public/` ที่ไม่มีโค้ดใช้แต่ยังเสิร์ฟ | เช่น `mbm-dashboard.webp` · ไม่ใช่ภาพคนจึงไม่เร่ง แต่ทำให้ inventory ยาวโดยไม่จำเป็น | ลบตอนเก็บกวาด |
| `og_display` เป็นเอกพจน์ตามชื่อ entity | "Dental Veneer" ขณะหน้าเป็นบริการ (พหูพจน์อ่านธรรมชาติกว่า) | override รายหน้าถ้า operator ต้องการ |
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
| 1.7 | 2026-11-21 | A19 hero ใช้ high 1K เป็นค่าเริ่ม (operator ยืนยันบน `/myofunction-tmj/`) · ราคาเครดิตใหม่จากบิล (medium 1K = 1, high 1K = 1.25, high 2K = 2) · ตารางค่าใช้จ่ายและผู้ให้บริการปรับตาม · ผล composite-veneer + myofunction-tmj |
| 1.6 | 2026-11-21 | A17 ชุดภาพหลายภาพ (บทเรียน PNCL) · A18 ครอปห้ามเติมขอบ · ผู้ให้บริการต่อแบรนด์ + ตารางเทียบ Higgsfield / OpenAI API / Codex + query เทียบ · ผล PNCL · `imagery.provider` ในโปรไฟล์ · vth: `c24a8a4` `dc2b111` `547d297` |
| 1.5 | 2026-11-21 | A16 ภาพประกอบ medium 1K เป็นค่าเริ่ม (operator ยืนยัน) · ค่าใช้จ่ายต่อหน้า 4.25 เครดิต · รูปทีมงาน 5 คนเข้าประตู · inventory ภาพคนไม่รู้ที่มา 25 → 22 หลังดูภาพจริง · แก้ข้อมูล Deezy (Astro) · vth: `6018e7a` |
| 1.4 | 2026-11-21 | **ส่วนที่ 0 Bootstrap** (P1–P8): แบบสอบถาม → `design/ayrel.json` · สำรวจ template · stack/adapter · inventory ภาพทุกไฟล์ · `ayrel:doctor` · นำร่อง · A15 overlay แทนตัวอักษรจาก AI · ผลตรวจขั้นสุดท้าย + scaling (medium 1K) · ค้างใหม่ (ทีมงาน 5 · ภาพคนไม่รู้ที่มา 25 · usage อัตโนมัติ) · vth: `1fe2c7f` `e2a09c8` `1c51dd2` `58fb2c4` · ต้นแบบโปรไฟล์ `templates/folder-skeleton/design/ayrel.json` |
| 1.3 | 2026-11-21 | ภาพประกอบในเนื้อหา (A13) · สัดส่วนที่ได้จาก Higgsfield (A14) · edge cache หลังลบ (B11) · pipeline ครบทั้งหน้า (batch · preview แบบฉีดภาพ · register slot `inline` · `--rows/--no-db`) · prompt ภาพประกอบ · ค่าใช้จ่ายต่อหน้าแบบครบ · runbook ย้ายภาพบุคคลออกจาก public + deploy ล้มที่ด่านอื่น · ผลนำร่อง dental-veneers + รูปแพทย์ภาพแรก · vth: `635d9a2` (ช่องภาพประกอบ) · `814e721` (รูปแพทย์) · `29a9f84` (dental-veneers) |
| 1.2 | 2026-11-21 | ส่วนที่ 2 ทะเบียนภาพ (DR-085): §5–§9 · หลักการ B1–B10 · วงจรรายวัน · runbook · view · ติดตั้ง ข้อ 5–11 · ผลนำร่อง · pipeline เพิ่มขั้น register · vth: `83e9c93` (gate/sweep/build gate) · `ccb784d` (workflow บน main) · `6a6273e` (unverified ≠ leak) |
| 1.1 | 2026-11-20 | A6a alt การ์ด og (`og_image_alt` + `og_image_alt_resolved`, migration `2026-11-20b`) · A10: ภาพ AI ทั่วไปไม่ติดป้าย · ภาพผลลัพธ์/ก่อน-หลังจาก AI ติดป้ายบนภาพ (operator) · `imagery.md` แก้ตาม |
| 1.0 | 2026-11-20 | ฉบับแรก จากนำร่อง vth `/teeth-whitening/`: hero `4f8159e` · การ์ดมือถือคม `0e10fb0` · og ชิดขวา `28e3f49` · Ayrel builder `fc0f2e2` · การ์ดแรก `e82e412` · ตั้งชื่อ `05b2e17` |
