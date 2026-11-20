# ทุกแบรนด์: Ayrel — การ์ด og ใน page_master และทะเบียนภาพกลาง (2026-11-21)

จาก vth-biodent (นำร่อง) · DR-084 + DR-085 · Schema v1.31–v1.32 · **สถานะ: apply กับ GTGT แล้ว 2026-11-20 · ใช้จริงที่ vth แล้ว · แบรนด์อื่นไม่ต้องทำอะไรทันที**

**สรุปสั้น:** ตารางแชร์ 2 ตัวได้ของใหม่แบบ "เพิ่มอย่างเดียว" — ไม่มีแถวเดิมของใครเปลี่ยน ไม่มีโค้ดแบรนด์ไหนพัง · มี **1 เรื่องที่ต้องรู้ถ้า ETL ของคุณจะเขียน `seo_media_assets`** (หัวข้อ 3) · วิธีทำทั้งหมดอยู่ใน `Ayrel_Image_System_SOP_v1_0.md` v1.2

---

## 1. Ayrel คืออะไร

**Ayrel** [aj.ˈrɛl] (Na'vi "ภาพหลายภาพ") — ระบบภาพของ EYWA เข้าชุดกับ Tsaheylu และ Pamrel

1. **ภาพเดียวใช้ได้ทุกช่อง** — ภาพ AI หนึ่งภาพต่อหน้า วางจุดเด่นตาม safe zone ของ template ให้ใช้ได้ทั้ง hero เดสก์ท็อป · การ์ดมือถือ · การ์ด og · ทุกภาษา
2. **การ์ด og ที่ออกแบบแล้ว** 1200×630 ต่อหน้าต่อภาษา (บรรทัด 1 ภาษาอังกฤษ ฟอนต์ display · บรรทัด 2 ภาษาของหน้า · แถบกระจกฝ้า · โลโก้) — แทนการครอปภาพ hero เฉย ๆ
3. **ทะเบียนภาพกลาง** — ทุกไฟล์ภาพ/วิดีโอมีที่มา ชนิด alt ต่อภาษา หน้าที่ใช้ และ (ถ้ามีคนจริงในภาพ) วงจรความยินยอมที่ปลดภาพอัตโนมัติ

---

## 2. `seo_website_page_master` — คอลัมน์การ์ด og (DR-084)

| คอลัมน์ | NULL = |
|---|---|
| `og_display` | ชื่อ entity ภาษาอังกฤษ (`seo_entity_graph.entity_name` ของ `primary_entity_fp`) |
| `og_tagline` | `seo_title` ก่อน ` \| ` |
| `og_style` (jsonb) | ค่าตั้งต้นของแบรนด์ (`band`, `display_color`, `grain`, `logo`, `focus`) |
| `og_image_alt` | ข้อความบนการ์ด (`บรรทัด 1 — บรรทัด 2`) |
| `og_image_url` · `og_image_generated_at` | ตัวสร้างการ์ดเขียนเอง |

- อ่านผ่าน **`v_page_og_card`** (resolve ค่าเริ่มต้นให้แล้ว + `og_needs_build`)
- แก้ `og_display` / `og_tagline` / `og_style` / `primary_entity_fp` → trigger ล้าง `og_image_generated_at` (= ต้องสร้างการ์ดใหม่) แต่การ์ดเดิมยังใช้ได้
- CHECK: ข้อความห้ามว่าง/ช่องว่างล้วน · `og_style` ต้องเป็นค่าที่รู้จัก · URL ต้องเป็น https
- **1,198 แถว (ทุกแบรนด์) ไม่มี `primary_entity_fp`** → ไม่มีบรรทัด 1 อัตโนมัติ · ถ้าจะทำการ์ดให้หน้าพวกนี้ ต้องใส่ `og_display` เอง

**ผลต่อแบรนด์อื่น:** ไม่มี — คอลัมน์ว่างทั้งหมด ถ้าไม่ใช้ เว็บของคุณก็ทำงานเหมือนเดิม

---

## 3. `seo_media_assets` — ทะเบียนภาพ (DR-085)

ตารางเดิมของ DR-038 (ยังไม่เคยมีแถวจนถึง 2026-11-20) ได้ **+17 คอลัมน์ · 3 ตารางลูก · 6 view · trigger กันไหลย้อน · pg_cron รายวัน**

### ⚠️ ถ้า ETL / n8n ของคุณจะ INSERT ลงตารางนี้ — ต้องรู้ก่อน

| กฎใหม่ | ผลถ้าไม่ทำตาม |
|---|---|
| **`kind` NOT NULL ไม่มี default** (hero · illustration · diagram · icon · equipment · clinic_space · portrait · case_before_after · review_photo · testimonial · result_simulation · og_card · logo · video_hero_loop · video_explainer · video_testimonial) | INSERT ล้ม |
| `is_patient_image` ต้องตรงกับ `consent_subject = 'patient'` | CHECK ล้ม |
| มีคนจริงในภาพ (`consent_subject` ≠ none) ⇒ `delivery = 'gated_worker'` + Obtained + (`use_forever` หรือ `use_until`) ก่อน Active | CHECK ล้ม |
| kind ที่เป็นคนจริง (portrait · case_before_after · review_photo · testimonial · video_testimonial) ห้าม `consent_subject = 'none'` | CHECK ล้ม |
| ภาพ AI (`origin` ai_generated/ai_edited) ต้องมี `generation_model` · ห้ามเป็นเคส/รีวิว/testimonial · `result_simulation` ต้องเป็น AI | CHECK ล้ม |
| `source` เพิ่มค่า `'ayrel'` (เดิม notion / batch-upload / wp-migration ใช้ได้เหมือนเดิม) | — |
| key (`r2_bucket` + `r2_object_key`) ใช้ได้ครั้งเดียวตลอดกาล · ไฟล์ใหม่ = แถวใหม่ | unique ล้ม |
| แถวที่ Expired / Revoked กลับเป็น Active ไม่ได้ | trigger ปฏิเสธ |

ตรวจ 2026-11-21 (repo vth-biodent + smile-scape ทุก branch · ตารางมี 0 แถวก่อน vth): ไม่มีโค้ดที่เขียนตารางนี้จริง · n8n flow ของ SmileScape (`docs/n8n/wf1-media-sync.json`, `wf2-media-expiry-sweep.json`) เป็นร่าง ยังไม่เคยรัน · repo แบรนด์อื่นไม่ได้ตรวจ — ถ้ามี flow ที่เขียนตารางนี้ แจ้งกลับ — **ถ้าจะเปิดใช้ flow นั้น ต้องแก้ให้ตรงตารางนี้ก่อน** (ชื่อคอลัมน์ในร่างเป็นสเปกเดิม `usage_expires_at` / `usage_perpetual` → ของจริงคือ `use_until` / `use_forever`)

### ของใหม่
- `seo_media_asset_texts` — alt / caption / transcript **ต่อภาษา** (แทน `alt_th` / `alt_en` ซึ่งคงไว้ให้ Notion mirror)
- `seo_media_asset_usages` — ภาพไหนใช้หน้าไหนช่องไหน · ภาพเดียวใช้ซ้ำได้หลายหน้า
- `seo_media_asset_events` — บันทึกเหตุการณ์ แก้/ลบไม่ได้
- view: `seo_servable_media` (ทางเดียวที่เว็บควรอ่าน) · `v_media_expiry_alerts` · `v_media_due_takedown` · `v_media_quarantine` · `v_media_usage_blocked` · `v_media_text_issues`
- pg_cron **`eywa-media-daily-sweep`** 00:05 เวลาไทย (ทุกแบรนด์): เตือน 15/7/3 วัน · ภาพคนจริงที่ถึงวันปลด (`use_until − 1`) หรือถูกเพิกถอนความยินยอม → Expired / Revoked — **มีผลกับแถวของทุกแบรนด์** แต่ตอนนี้ไม่มีแถวของแบรนด์อื่น

### ภาพคนจริงในแบรนด์ของคุณตอนนี้
DR-085 กำหนดให้ภาพคนจริงไม่อยู่บน CDN public · แต่ละแบรนด์ยังไม่ต้องย้ายทันที — ทำตอนติดตั้ง Ayrel (SOP §10) · ที่รู้แล้ว:
- **Deezy Dental**: `seo_authors_reviewers.photo_url` ของ ทพญ. ธัญพร พงษ์ขจรกิจการ ชี้ไปที่ WordPress (`deezydental.com/wp-content/...`) — ยังไม่อยู่ในทะเบียน เพราะ Deezy ยังไม่มีประตู `/media` · ย้ายตอนติดตั้ง Ayrel
- **vth-biodent**: รูปแพทย์ใน `web/src/lib/team.ts` ยังอยู่บน `cdn.vthbiodent.com` (public) — กำลังย้ายเข้าทะเบียนเป็นภาพบุคคลแรก

---

## 4. ฝั่งแบรนด์ (vth ทำเป็นต้นแบบ)

| ชิ้น | ที่ vth |
|---|---|
| bucket ส่วนตัว 2 ตัว: `<brand>-gated` (ภาพคนจริง) · `<brand>-quarantine` | `vth-biodent-gated` · `vth-biodent-quarantine` |
| ประตู `/media/<key>` ใน Worker ของเว็บ (เสิร์ฟเมื่ออยู่ใน manifest เท่านั้น) | `web/worker/media-gate.ts` |
| งานรายวัน 00:20 ICT: quarantine · purge cache · manifest · ตรวจ 404 · ลบถาวรหลัง 90 วัน · สั่ง deploy | `web/scripts/ayrel/media-sweep.mjs` + `.github/workflows/media-sweep.yml` **(ต้องอยู่บน `main`)** |
| ด่านตอน build | `web/scripts/ayrel/check-media.mjs` |
| การ์ด og | `web/scripts/ayrel/build-og-cards.mjs` (`npm run ayrel:build`) |
| ค่าแบรนด์ | `design/hero-slots.json` · `design/og-card.json` · `design/media.json` |
| token Cloudflare ตัวเดียว: R2 Edit + Cache Purge · secret `CLOUDFLARE_MEDIA_TOKEN` | — |

**ทดสอบแล้ว (vth, 2026-11-21):** ภาพสังเคราะห์ลงทะเบียน → ประตูเสิร์ฟ 200 → ถึงวันปลด → ระบบเปลี่ยนเป็น Expired เอง → งานรายวันย้ายเข้า quarantine + purge → 404 ครบ 3 host (ยืนยันจาก GitHub Actions) → พยายามเปิดกลับถูกปฏิเสธ

---

## 5. ต้องทำอะไร

| ใคร | ทำอะไร | เมื่อไร |
|---|---|---|
| ทุกแบรนด์ | อ่านหัวข้อ 3 ถ้ามีแผนเขียน `seo_media_assets` | ก่อนเปิด flow ใด ๆ ที่เขียนตารางนี้ |
| แบรนด์ที่มีภาพคนจริงบนเว็บ (แพทย์ เคส รีวิว) | วางแผนติดตั้ง Ayrel ส่วนที่ 2 (SOP §10 ข้อ 5–11) | ก่อนลงภาพคนจริงเพิ่ม |
| SmileScape | `wf1/wf2` n8n เป็นร่างตามสเปกเดิม — อย่าเปิดใช้โดยไม่แก้ | — |
| ทุกแบรนด์ | ไม่ต้องทำอะไรกับคอลัมน์ `og_*` จนกว่าจะเริ่มทำการ์ด og | — |

**อ้างอิง:** `Ayrel_Image_System_SOP_v1_0.md` v1.2 · DR-084 · DR-085 · `migrations/2026-11-20_page_master_og_card.sql` · `2026-11-20b_page_master_og_image_alt.sql` · `2026-11-20c_media_registry_ayrel.sql`
