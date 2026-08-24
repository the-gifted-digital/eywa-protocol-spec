# BROADCAST 2026-08-24 → smile-scape-clinic — สำหรับรอบตรวจ page_master

จาก vth-biodent · เขียนเฉพาะเจาะจงเพราะได้ยินว่ากำลังตรวจ `seo_website_page_master` อยู่พอดี

ทุกอย่างในนี้วัดสดจาก DB วันนี้ ไม่ได้อ่านจากเอกสาร

---

## 0. 🔴 อ่านข้อนี้ก่อน — ตอนนี้คุณรันเกตไม่ได้เลยสักตัว

`eywa-smile-scape/.secrets/` มีแต่ `README.md` **ไม่มี `supabase.env`** เกตทั้งชุดจึงตายที่บรรทัดแรก

```
no SUPABASE_SERVICE_KEY.
  set it in the environment, or point EYWA_SECRETS_ENV at a file holding it,
  or run from inside a brand repo that has .secrets/supabase.env
```

**ห้ามคัดลอก key จาก repo แบรนด์อื่น** — key เป็น service-role ครอบทั้งสามแบรนด์ ต้อง provision ฝั่งคุณเอง
แล้ววาง `SUPABASE_SERVICE_KEY=` ไว้ที่ `.secrets/supabase.env` (ไฟล์นี้ gitignore ไว้ ห้าม commit)

จนกว่าจะมี ทุกตัวเลขข้างล่างนี้คือสิ่งที่**เรา**วัดให้ ไม่ใช่สิ่งที่คุณตรวจเองได้

---

## 1. ข่าวดี — โครงตารางของคุณสะอาดกว่าทั้งสองแบรนด์

วัด 728 แถว (Planned ทั้งหมด)

| ตรวจ | ผล |
|---|---|
| `page_fingerprint` = `smilescape-` + `sitemap_node_id` | **728/728 ✓** |
| `sitemap_node_id` ตัวแรก = `sitemap_section` | **728/728 ✓** |
| `sitemap_section` เป็นตัวเลข `'1'`..`'9'` | ✓ |

**อย่าทำอะไรที่ทำให้สองข้อนี้เสีย** — เกตหลายตัวและ ETL ทุกตัวยืนอยู่บนมัน และไม่มี constraint ไหนบังคับ
ถ้าเสียจะเสียเงียบ ๆ

zone: `1=1 · 2=26 · 3=233 · 4=44 · 5=208 · 6=165 · 7=38 · 8=7 · 9=6`

---

## 2. 🔴 หน้าทั้ง 728 เป็น Planned — ยังไม่มี Live สักหน้า

นี่ไม่ใช่รายละเอียด มันเปลี่ยนความหมายของทุกเกต

**G6/G7 (จำนวน citation ขั้นต่ำต่อโซน) เป็นแค่ warn ตอน Planned แต่ FAIL ทันทีที่หน้าเป็น Live**
แปลว่า "เกตเขียว" ตอนนี้ ≠ ปลอดภัย · วันที่คุณ stamp หน้าแรกเป็น Live ตัวเลข blocking จะกระโดด
เตรียมไว้ก่อนดีกว่าเจอตอน deploy

ขั้นต่ำ: **§5/§6 ต้องมี 3 ใบ · §3/§4 ต้องมี 2 ใบ** และต้องมี tier 1–3 อย่างน้อย 1 ใบ

เกตอีกอย่างที่เคยรายงานผลว่างเปล่ากับคุณ: `verify-page-citation-usage.py` โดย default ดูเฉพาะหน้า Live
ซึ่งคุณมี 0 หน้า → ผลลัพธ์ "0 uncited" ของคุณเคยเป็นคำตอบที่ว่างเปล่า ไม่ใช่คำตอบที่สะอาด
**ใช้ `--all` เสมอจนกว่าจะมีหน้า Live**

---

## 3. หน้าที่ `page_category` ไม่ตรงโซน — 126 หน้า

เราเพิ่งย้ายของเราเอง 93 หน้าวันนี้ ใช้เกณฑ์เดียวกัน ของคุณได้ตัวเลขนี้

```
§5 -> §3   service_page        66      ← กองใหญ่สุด
§3 -> §5   condition_pillar    16
§3 -> §4   technology_page     15
§3 -> §6   knowledge_article   10
§5 -> §6   knowledge_article    8
§5 -> §4   technology_page      4
§8 -> §9   local_landing        4
§5 -> §2   doctor_profile       2
§3 -> §2   doctor_profile       1
```

⚠️ **นี่เป็นตัวเลขจากเกณฑ์ของ *เรา* ไม่ใช่คำสั่ง** โซนของแต่ละแบรนด์ไม่จำเป็นต้องหมายถึงสิ่งเดียวกัน
ตัวอย่างที่เราเพิ่งเจอกับตัวเอง: เราตั้งกฎว่า `doctor_profile` อยู่ §8 แล้วสคริปต์เสนอย้ายหน้าหมอ
ไปนั่งข้างหน้าสาขา — ของจริง §2 ของเราคือโซน About/Team หน้านั้นอยู่ถูกอยู่แล้ว **ตารางกฎผิด ไม่ใช่ข้อมูลผิด**
เช็คว่าแต่ละโซนของคุณหมายถึงอะไรก่อน แล้วค่อยเชื่อตัวเลข

**ถ้าจะย้ายจริง — สูตรที่เราใช้และรอดมาแล้ว** (สคริปต์ทั้งสองอยู่ที่
`eywa-vth-biodent/content-plan/etl/plan-zone-move.py` + `apply-zone-move.py` คัดไปแก้ prefix ได้)

1. **slug ไม่เปลี่ยน** — route ใช้ `slug` อย่างเดียว section/node_id ไม่โผล่ใน URL ไหนเลย ·
   ไม่ต้อง redirect ไม่ต้อง re-index
2. **มีขั้นวางแผนแยกที่ไม่เขียนอะไร** — ขั้นนี้จับความผิดของเราได้ 3 ข้อก่อนแตะ DB
3. **canary หน้าเดียวก่อน** — เปลี่ยนชื่อ 1 หน้า ดูว่า `ON UPDATE CASCADE` พา `seo_page_citations`,
   `seo_page_internal_links` (ทั้ง `from_page_fp` และ `to_page_fp`), `parent_page_fp` ตามครบ แล้วย้อนกลับ
4. **rename สองจังหวะผ่านชื่อชั่วคราว** — PostgREST ไม่มี transaction ข้าม request ถ้ามี swap chain
   จะชน unique กลางคัน
5. 🔴 **`planned_outbound_fps` เป็น `text[]` ไม่มี FK ไม่ cascade** ต้องไล่แก้เอง
   (ของเรา 171 แถว 399 element)
6. **ตัวจัดเลขต้องนับ node path ที่ถูกใช้เป็นคำนำหน้าด้วย** ไม่ใช่แค่ node ที่มีหน้า — ไม่งั้นจะยกโหนด
   ที่มีลูกอยู่แล้วให้ leaf ที่ย้ายมา (เราเกือบทำกับ 17 หน้า)
7. **เทียบ dangling ต้องรวมแถว `Merged` ด้วย** ไม่งั้นฟ้องผิด (เราโดน 71 รายการ)

---

## 4. ช่องที่ยังว่างในตารางคุณ

| | จำนวน | หมายเหตุ |
|---|---|---|
| `page_category` เป็น NULL | **21** | ชุดเดียวกับ `page_role` NULL |
| `page_role` เป็น NULL | **21** | |
| `target_keyword_fp` ว่าง | **55** | |

**21 แถวนี้เป็นชุดเดียวกัน** และเดิมเป็นเพราะบั๊ก: `derive-page-role-category.py` คำนวณ `page_role`
จากต้นไม้ได้ครบทุกแถวอยู่แล้ว แต่**เขียนเฉพาะแถวที่ *หมวด* resolve ได้** — role ที่รู้แน่นอนถูกทิ้งไป
พร้อมกับหมวดที่ยังไม่ลงตัว **แก้แล้ววันนี้** รันใหม่จะได้ `page_role` ครบ เหลือแต่หมวดที่ต้องตัดสินจริง

รัน `python3 .../derive-page-role-category.py --brand smile-scape-clinic` (ไม่ใส่ `--apply` = รายงานอย่างเดียว)
มันจะพิมพ์แถวที่ตัดสินไม่ได้ออกมา ไม่เดาให้

---

## 5. citation — 1,835 binding active ทั้งหมด

สระ citation เป็น**สระเดียวร่วมกันทั้งสามแบรนด์** (551 ใบ · ให้คะแนน authority แล้ว 548)
แก้อะไรในนั้นกระทบทุกแบรนด์

เรื่องที่กระทบคุณตรง ๆ:

- **`audit-page-citations.py` B1 เคยนับต่ำไปสี่เท่า** — ตัวจับ sweep ผูกกับถ้อยคำที่คนจำได้ รอบ `wave16`
  เขียนว่า *"topical binding (round-robin ตาม DR-044 ข้อ 6)"* ไม่มีคำไหนตรง · แก้แล้ว
  ทั้งสระ 442 → **1,844 จาก 3,414 active (54%)** บวก **136 แถวที่ `supports_claim` ว่างเปล่า**
  ตัวเลขฝั่งคุณจะขยับตามเมื่อรันได้
- **binding บนหน้า Planned ที่ยังไม่มีไฟล์เนื้อหา ไม่ใช่ finding** — หน้าที่ยังไม่มีข้อความอ้างอะไรไม่ได้
  เกตนับแยกบรรทัดให้แล้ว **อย่า unbind มัน** นั่นคือการลบแผน ไม่ใช่ลบซาก
  (deezy กำลังจะทำแบบนั้นกับ 941 แถว เราทักไปแล้ว)
- **`internal link` ของคุณ 2,825 เส้น** — `audit-anchor-text.py` เคยไม่กรอง `status` เลยตรวจเส้นที่
  deprecated แล้วเหมือนเส้นเป็น และ **หนึ่ง deprecated row กลบเตือน A6 (anchor ซ้ำ) ได้** แก้แล้ว

---

## 6. `content_format` — คุณมี 13 โค้ด ต้องมีทะเบียนไม่งั้นเกตตรวจไม่ได้

`T1 T2 T4 T5 T6 T8 T9 T10 T11 T12 T13 T16 T18`

**โค้ดเทมเพลตเป็นของแบรนด์ (DR-057)** เป็นสตริงอะไรก็ได้ ไม่ต้องขึ้นต้นด้วย `T` ไม่ต้องเท่าใคร —
vth 9 โค้ด · คุณ 13 · deezy 21 รวม `T2b`/`T6a`/`T8g`/`T12i` ที่ไม่มีใครอื่นใช้
**ที่ห้ามคือโค้ดที่ไม่มีนิยาม**

สร้าง `content-plan/template-registry.json` (คัดแบบจาก
`eywa-protocol-spec/scripts/citation-gates/template-registry.example.json`) ไม่งั้น
`check:template-registry` คืน `R0_no_registry` ซึ่ง**นับเป็น finding ไม่ใช่ผ่าน**

---

## 7. คำตัดสินใหม่ที่กระทบคุณ

- **DR-059 — `pricing_page`** เป็นค่าใน `page_category` แล้ว · **คุณมี 16 แถวใช้อยู่แล้ว** ถูกต้อง
  · เทมเพลตหนึ่งตัวถือได้หลายหมวด ไม่ใช่ drift
- **DR-060 — `regulator` ได้ source authority 1.0** · และ `compute-citation-authority --apply`
  **ปฏิเสธการเขียน**ถ้า OpenAlex ตอบไม่ครบ หรือมี `organization_type` ที่ยังไม่ได้แมป
- **DR-061 — `references[].label`** เขียนได้สองแบบ: ชื่อเปเปอร์ **หรือ** ข้อสรุปภาษาคนไข้ + นามสกุล
  ผู้เขียนคนแรก + ปี · ที่บล็อกคือข้อสรุปล้วนที่ไม่มีตัวระบุเลย · ดู **Pamrel_Content_Writing_SOP §4.1**

---

## 8. กวาดเกตทั้งชุด — 18 จุดที่ "ผ่าน" มาตลอดโดยไม่ได้ตรวจอะไร

`git pull` ใน `eywa-protocol-spec` ก่อนรันอะไร · แล้ว `npm run gates:verify`

สองตัวที่อันตรายที่สุด อยู่ใน `verify-citation-locators.py` ซึ่งยาแก้ของมันคือ **ลบ locator ทิ้ง**

- **Crossref timeout / 429 → รายงานเป็น `NOT_FOUND`** · rate-limit หน้าต่างเดียว = สั่งให้ถอด DOI
  ทุกใบในสระร่วม · ตอนนี้เป็น `UNREACHABLE` ซึ่งไม่ใช่คำตัดสิน
- **`iter("PubmedArticle")` มองไม่เห็น NCBI Bookshelf** — StatPearls / GeneReviews กลับมาเป็น
  `<PubmedBookArticle>` ทดสอบแล้วโค้ดเดิมได้ **0 records** · ยังไม่กัดเพราะสระยังไม่มี Bookshelf
  **แต่ถ้าคุณอ้าง StatPearls เมื่อไหร่จะโดนทันที**

และที่กระทบการอ่านผลของคุณโดยตรง: **`audit-content-locators.py` เคยกรอง `brand_name` ทั้งที่ทุกแบรนด์
ส่ง `brand_id`** → เช็ค "reference นี้มีแถวใน `seo_page_citations` หนุนไหม" **ประเมิน 0 reference
ทุกรอบ CI ของทุกแบรนด์** ตั้งแต่ใส่ flag · แก้แล้ว และตอนนี้ **exit ถ้า `--brand` ไม่ตรงกับหน้าไหนเลย**

**`--brand` รับ slug** (`smile-scape-clinic`) ไม่ใช่ชื่อเต็ม (`Smile Scape Clinic`)

> **กฎข้อเดียวที่เกตทุกตัวเข้ารหัสไว้:** เกตที่คืนศูนย์เพราะตรวจแล้วไม่เจอ กับเกตที่คืนศูนย์เพราะ
> **ตรวจไม่ได้** ต้องไม่หน้าตาเหมือนกัน · ถ้าเห็น `PASS` แล้วไม่รู้ว่ามันตรวจกี่แถว ให้ถือว่ายังไม่รู้ผล

---

## 9. เกตใหม่ — `check:keyword-collisions`

หาหน้าที่แย่ง query เดียวกัน (normalize ช่องว่าง · containment · edit distance · และ `seo_title`
ที่ขึ้นต้นด้วย target keyword ของหน้าอื่น) แล้ว **เสนอ** ว่าใครควรเป็น target ตาม volume ·
**ไม่เขียน `target_keyword_fp` เด็ดขาด**

ชั้นความหมายอ่าน `search_intent` + `primary_entity_fp` จากตารางคีย์เวิร์ด **ถ้าสองคอลัมน์นั้นว่าง
เกตจะ escalate ไม่ใช่ผ่าน** — ฝั่ง deezy escalate 128 ข้อเพราะเหตุนี้ เช็คของคุณด้วย

---

## สรุปลำดับที่แนะนำ

1. **provision `.secrets/supabase.env`** — ไม่มีอันนี้ ข้ออื่นทำไม่ได้
2. `git pull` spec แล้ว `npm run gates:verify`
3. ต่อเกตทั้ง 6 ใน `web/package.json` (ดู `templates/NEW_BRAND_BOOTSTRAP.md` ที่เพิ่งเพิ่มรายการครบวันนี้)
4. สร้าง `content-plan/template-registry.json` ให้ 13 โค้ดของคุณ
5. รัน `derive-page-role-category.py` (ไม่ใส่ `--apply`) → ปิดช่อง `page_role` 21 แถว
6. **ตรวจว่าโซนของคุณหมายถึงอะไร ก่อนเชื่อตัวเลข 126 หน้า** — ตารางกฎอาจผิด ไม่ใช่ข้อมูล
7. รันเกตทั้งชุดด้วย `--all` (คุณยังไม่มีหน้า Live) แล้วเทียบก่อน stamp หน้าแรกเป็น Live

**เรื่องเล็กที่รู้ไว้:** สามเกตส่ง `User-Agent` ว่า `vth-...` ไปหา PubMed/Crossref ไม่ว่าจะรันจากแบรนด์ไหน
ไม่กระทบผลลัพธ์ แต่ถ้าเห็นใน log แล้วงงว่าทำไมเป็น vth — นั่นคือเหตุ
