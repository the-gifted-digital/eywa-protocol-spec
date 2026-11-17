# ทุกเว็บ: แถวภาษาอื่นใน page_master — ข้อตกลงเดียวกันทุกแบรนด์ (ร่าง)

จาก vth-biodent · แจ้งเพราะตารางแชร์ + deezy ทำไปแล้ว 39 หน้า × 3 ภาษาด้วยข้อตกลงที่ไม่อยู่ใน protocol · DR เลขรอจัด · **สถานะ: operator เคาะแล้ว 2026-11-17 · ข้อมูลในตารางแชร์ปรับแล้ว (ดูหัวข้อ "แก้ไปแล้ว") · vth ขึ้นเว็บแล้ว 10 ภาษา**

---

## เกิดอะไรขึ้น

operator สั่งนำร่องแปลหน้าแรก vth (2026-11-17) เริ่มที่อังกฤษ แล้วขยายเป็น 10 ภาษา ระหว่างเตรียมพบว่า DR-009 (Two-Tier) เขียนสิ่งที่ไม่เคยสร้าง และ deezy ลงแถวจริงไปก่อนด้วยข้อตกลงของตัวเอง เอกสารกับข้อมูลจึงไม่ตรงกัน 5 จุด

```
deezy   39 หน้า × th/en/zh-cn = 117 แถว · translation_status='published' · รหัสแถวเติมท้าย
vth    763 แถว th ล้วน · translation_status='pending' ทุกแถว (รวมแถวที่ไม่มีคำแปล)
อื่น ๆ  th ล้วน · translation_status เป็น NULL
```

## ข้อตกลง (operator เคาะ 2026-11-17)

1. **หนึ่งแถว = หนึ่งหน้า หนึ่งภาษา** — ไม่มีคอลัมน์รหัสกลุ่ม กลุ่มเกิดจาก `source_translation_fp` (บนแถวคำแปล ชี้ต้นฉบับ) + `translations_versions_fps` (บนแถวต้นฉบับ รายชื่อคำแปล) · `translation_group_id` / `tg_…` ใน DR-009 และ skeleton ตัวอย่าง **ไม่เคยสร้าง ให้ถือว่ายกเลิก**
2. **รหัสแถวเติมท้าย**: `page_fingerprint` = `<fp ต้นฉบับ>-<locale>` เช่น `vth-1-en` · `slug` = `<slug ต้นฉบับ>-<locale>` เช่น `home-en` — ตามที่ deezy ใช้ (`59_locale_rows_expansion.sql`) · ห้ามเติมหน้า (`en-vth-1`) เพราะ `LIKE '<brand>-%'` ในสคริปต์จะมองไม่เห็นแถวเงียบ ๆ · slug ต้องไม่ซ้ำ เพราะสคริปต์หลายตัว PATCH ด้วย `slug=eq.`
3. **รหัสภาษาจีน = `zh-cn`** (ตัวย่อ แผ่นดินใหญ่) ทั้ง `page_language` · โฟลเดอร์เนื้อหา · URL `/zh-cn/` · vth จะย้ายจาก `/zh/` ตอนเริ่มภาษาจีน
4. **`translation_status` มี 4 ค่า**: `pending` (มีแถว ยังไม่แปล) · `in_progress` (กำลังแปล/ตรวจกันเอง) · `live` (ขึ้นเว็บแล้ว) · `stale` (ต้นฉบับถูกแก้หลังแปล ต้องแปลตาม) · **แถวต้นฉบับ = NULL** คอลัมน์นี้บอกสถานะของแถวที่เป็นคำแปลเท่านั้น
5. **ตรวจคำแปล**: ระยะเริ่มแรกร่างและตรวจกันเองก่อน live · รอบตรวจหลัง live ใช้ `review_cycle` + `seo_editorial_reviews` ที่มีอยู่ ไม่เพิ่มค่าสถานะ

## แถวคำแปลต่างจากต้นฉบับตรงไหน

| ต้องต่าง | คัดลอกจากต้นฉบับ |
|---|---|
| `page_fingerprint` · `slug` · `canonical_url` (`/<locale>/…`) | `page_type` · `page_category` · `page_role` · `content_format` |
| `page_language` · `source_translation_fp` · `translation_status` | `cluster_id` · `primary_entity_fp` · `related_entities_fps` |
| `seo_title` · `meta_description` · `page_name` (เติม `[EN]`) | `schema_markup_type` · `sitemap_section` · `node_tier` · `priority` |
| `target_keyword_fp` · `semantic_keywords_fps` (คำของภาษานั้น หรือ NULL) | `funnel_stage` · `page_intent_type` · `conversion_event_*` |
| `published_date` · `status` (เริ่มที่ Planned) | `has_medical_review` · tier/compliance ทั้งชุด |
| `nav_label` = NULL (unique ต่อแบรนด์) · `sitemap_node_id` = NULL | `parent_page_fp` (ชี้แถวต้นฉบับของหน้าแม่ จนกว่าหน้าแม่จะมีคำแปล) |

**คีย์เวิร์ด**: `uq_page_master_target_keyword_fp` บังคับหนึ่งคำหนึ่งหน้าทั้งระบบ แถวคำแปลจึงต้องมีคำของตัวเอง เพิ่มเป็น**แถวใหม่**ในคลังพร้อมป้ายภาษา (`…::🇬🇧 en – english::…`) ห้าม re-tag แถวไทยเดิม · ยังไม่มีคำ = NULL ได้ (หน้าเขียนแบบไม่มีคีย์เวิร์ด รอ GSC ตาม DR-048)

## ฝั่งเว็บ — สิ่งที่ vth ทำเป็นต้นแบบ

1. **รายการเดียวบอกว่าหน้าไหนแปลแล้ว**: `web/src/data/translated-pages.json` (`{ "/": ["en"] }`) — hreflang · ตัวสลับภาษา · ตัวกรอง sitemap · `check:indexable` · `stamp-live` อ่านไฟล์เดียวกัน · หน้า locale ที่ไม่อยู่ในรายการต้อง noindex
2. **`check:indexable`** เดิมข้ามทั้งต้นไม้ locale ("noindex by design") แถว `home-en` ที่ Live จึงจะ FAIL ว่า "/home-en/ ไม่ indexable" — แก้ให้แมปแถวที่ `page_language != th` ไปที่ `/<locale>/<url ต้นฉบับ>/`
3. **`stamp-live`** เดิมข้าม locale ทั้งหมด — แก้ให้ stamp หน้าที่อยู่ในรายการด้วย slug เติมท้าย
4. hreflang ต้องครบและชี้กลับกันก่อนถอด noindex — vth เคยโดน `/en/` (โครงเปล่า) ขึ้นเหนือหน้าไทยในคำค้นชื่อแบรนด์ (GSC 2026-08)

## ⚠️ ข้อมูลในตารางแชร์ที่แก้ไปแล้ว — 2026-11-17 (operator สั่ง)

`migrations/2026-11-17_translation_status_vocab.sql` · 2,010 แถว

| อะไร | ใคร | จำนวน |
|---|---|---|
| `translation_status` `published` → `live` บนแถวคำแปล | deezy | 78 |
| `translation_status` → NULL บนแถวต้นฉบับ | deezy 696 · tc-smile 474 · vth 762 | 1,932 |
| `CHECK (translation_status IS NULL OR IN ('pending','in_progress','live','stale'))` | ตารางแชร์ | `chk_page_master_translation_status` |
| คำอธิบายคอลัมน์ `translation_status` + `page_language` | ตารางแชร์ | เขียนใหม่ |

หลังแก้: แถวต้นฉบับ 3,787 แถว NULL · แถวคำแปล 87 แถว `live` (deezy 78 + vth 9) · ไม่มีโค้ดของแบรนด์ไหนกรองด้วยค่านี้ (grep แล้ว มีแต่ SQL โหลดที่เขียนค่า) · `updated_at` ของ 2,010 แถวขยับ (trigger) · วิธีคืนค่าเดิมอยู่ในหัวไฟล์ migration

**ผลต่อ ETL ของคุณ:** INSERT/UPDATE ที่เขียน `'published'` หรือค่าอื่นนอก 4 คำ จะล้มที่ CHECK · `'pending'` ยังเขียนได้ แต่อย่าใส่บนแถวต้นฉบับ (deezy `24_lifecycle_defaults.sql` ทำอยู่ — แก้ก่อนรันซ้ำ)

## เอกสารที่ขัดกันเอง — เสนอแก้

- **`is_source_page`**: คำอธิบายคอลัมน์ = "cluster authority hub" · DR-009 = "ต้นฉบับของคำแปล" · deezy ตั้ง TRUE บนแถวไทยที่มีคำแปล → เสนอ: ต้นฉบับของคำแปลดูจาก `source_translation_fp IS NULL` + `translations_versions_fps` ไม่ต้องใช้คอลัมน์นี้ คืนความหมาย hub ให้มัน
- **README L26** "8 languages (…FR, ES)" — เก่า · ภาษาเป็นของแต่ละแบรนด์ใน `brand-config.json` (`active_languages` = build ไว้ · `live_languages` = มีหน้าจริง)
- **DR-009 Tier 2** — แก้ตามข้อ 1 ข้างบน

## ทำอะไรในเว็บของคุณ

- **ยังไม่มีภาษาอื่น**: ไม่ต้องทำอะไร · อย่าใส่ `translation_status='pending'` บนแถวไทย
- **deezy**: รอคำสั่งเปลี่ยน `published` → `live` · ตรวจว่า `availableLocales()` กับแถวในตารางตรงกัน (ตอนนี้อ่านจาก file tree ไม่ได้อ่านตาราง)
- **จะเริ่มภาษาอื่น**: ทำตามตารางข้างบน · เริ่มทีละภาษา · เกตต้องรู้จักแถวภาษาอื่นก่อนลงแถว ไม่งั้นเกตจะ FAIL หรือแย่กว่านั้นคือผ่านเพราะมองไม่เห็น

---

## ผล pilot — vth `/en/` ขึ้นเว็บ 2026-11-17 (eywa-vth-biodent `ccb3f03`)

```
แถว        vth-1-en · slug home-en · page_language en · source_translation_fp vth-1
เว็บ       /en/ index,follow · canonical /en/ · hreflang th+en+x-default ชี้กลับกันทั้งสองหน้า · อยู่ใน sitemap
stamp-live Planned → Live + published_date + canonical_url ถูกต้อง โดยไม่ต้องแตะมือ
เกต        18 ตัวผ่าน · check:indexable 215 หน้า / 0 error
อีก 8 ภาษา ยัง noindex และไม่ถูกประกาศใน hreflang
```

สิ่งที่เจอระหว่างทำ — แบรนด์อื่นจะเจอเหมือนกัน:

1. **`compliance_max_tier` เป็น generated column** — INSERT…SELECT ที่คัดลอกทุกคอลัมน์จากแถวต้นฉบับจะล้ม ต้องเว้นคอลัมน์นี้
2. **ลงแถวเป็น `Planned` ก่อน deploy** — เกตรุ่นเก่าของ session อื่นไม่ล้ม (Planned = shipping now) แล้ว `stamp-live` พลิกเป็น Live เอง · ถ้าลงเป็น Live ก่อนโค้ดขึ้น `check:indexable` ของทุก session จะ FAIL
3. **`stamp-live` เดิมไม่แตะ `translation_status`** — แถวเป็น Live แล้วแต่คอลัมน์ค้าง `in_progress` · vth แก้แล้ว: `stamp-live` ตั้ง `live` บนแถว Live ที่ `source_translation_fp IS NOT NULL` และค่าเดิมเป็น NULL/pending/in_progress · **ไม่แตะ `stale`** เพราะการขึ้นเว็บไม่ได้ทำให้คำแปลที่ล้าหลังกลับมาทันต้นฉบับ
4. **ข้อความหน้าแรกฝังอยู่ในไฟล์หน้า** — ต้องแยกเป็น copy module รายภาษาก่อน (vth: `web/src/lib/home-copy/{th,en}.ts` พิมพ์ชนิดเป็น `typeof th` → key ขาด/เกิน build ไม่ผ่าน) · ตรวจว่าหน้าต้นฉบับไม่เปลี่ยนด้วยการ diff HTML ที่ build ก่อน/หลัง
5. **ชื่อบุคคลในภาษาอื่น** — ไม่มีคำสะกดทางการใน repo ต้องให้ operator ยืนยัน อย่าถอดเสียงเองแล้วปล่อยขึ้นเว็บเงียบ ๆ
6. **หน้าแรกไม่มีคีย์เวิร์ด** — pilot นี้จึงไม่ได้ทดสอบการหาคีย์เวิร์ดรายภาษา ต้องทดสอบกับหน้าบริการ

---

## ระยะ 2 — อีก 8 ภาษา + ฟอนต์ + RTL (vth, 2026-11-17)

```
แถว        vth-1-{zh-cn,ar,de,ru,ja,ko,my,mn} · ลงเป็น Planned · stamp-live พลิก Live + translation_status live เอง (ทำงานจริงครั้งแรก ถูกต้อง 8/8)
เว็บ       10 ภาษา · hreflang 10 + x-default ทุกหน้า · sitemap ครบ · /zh/ 301 → /zh-cn/
คำแปล      ร่างด้วยเครื่อง ตรวจกันเอง · ยังไม่มีเจ้าของภาษาอ่าน
```

กับดักเพิ่มจากระยะ 2:

7. **ช่องว่างระหว่างท่อนข้อความ** — หัวข้อที่แบ่งสองท่อนด้วย `<br>` ที่ซ่อนบางความกว้าง ภาษาไทย/จีน/ญี่ปุ่นต่อกันได้เลย ภาษาอื่นคำติดกัน ("Remote orthodonticmonitoring" ขึ้นเว็บจริงไปแล้วหนึ่งรอบ) → ใส่ช่องว่างที่ template ตามภาษา ไม่ใช่ในข้อความ
8. **คลาสหัวข้อชื่อ `font-display-th`** ผูกกับฟอนต์ไทย → หัวข้อของภาษาที่ไม่ใช่ละติน/ไทย ตกไปใช้ฟอนต์ของเครื่องผู้ใช้เงียบ ๆ · ตรวจ `getComputedStyle(h1).fontFamily` ทุกภาษา
9. **ฟอนต์จาก CDN** — Google Fonts ของญี่ปุ่น = CSS 344 KB บล็อกการวาดหน้า · Pretendard static ไม่มี unicode-range = โหลดฟอนต์เต็มทุกน้ำหนัก → โฮสต์เองแบบตัดชุดตัวอักษร (`scripts/subset-locale-fonts.py`) + เกต `check:fonts` สำหรับภาษาที่ตัดตามข้อความจริง (ja, ko)
10. **อย่า preload ฟอนต์ของ locale** — วัดแล้ว FCP 1.9s เทียบ 1.1s เมื่อไม่ preload (PageSpeed mobile) ฟอนต์ไปแย่งแบนด์วิดท์กับ HTML และรูป hero
11. **RTL (อาหรับ) พังบน desktop แม้ผ่านบนมือถือ** — ตรวจทั้งสองความกว้างเสมอ · สาเหตุ: คลาสซ้าย/ขวาแบบตายตัว (`ml-`, `right-[3%]`, `text-left`, `border-l`) → ใช้แบบรู้ทิศทาง (`ms-`, `end-`, `text-start`, `border-s`) · องค์ประกอบภาพที่วาดด้วย mask ซ้ายไปขวา (hero) ให้ล็อกกรอบเป็น `dir="ltr"` แล้วให้เฉพาะข้อความเป็น rtl
12. **bidi** — ลูกศร `→` ไม่ถูกกลับด้านเอง · `®` กระโดดไปหน้าชื่อละติน (ต่อท้ายด้วย U+200E) · เบอร์โทรที่มีช่องว่างสลับกลุ่ม (`9920 109 02`) · `2M+` เป็น `+2M` · ช่วงเวลา `09:00–20:00` กลับหัว → `dir="ltr"` บนตัวเลข/เบอร์โทร และ U+2066…U+2069 ในข้อความ
13. **deploy ซ้อน** — session อื่น push ทับ ทำให้รอบ CI ของเราถูกยกเลิก แต่ commit ของเขาต่อจากของเรา รอบถัดไปจึงพาขึ้นไปด้วย · เฝ้าด้วย marker ที่มีเฉพาะใน build ใหม่ ไม่ใช่สถานะรอบ CI ของตัวเอง

---

_vth-biodent session 2026-11-17 · operator อนุมัติข้อตกลง 5 ข้อ, การปรับข้อมูล และให้ commit_
