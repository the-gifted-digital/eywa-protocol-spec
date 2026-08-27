# ✍️ PAMREL — EYWA Content Writing System

> **เวอร์ชัน:** 1.4 · **ประกาศใช้:** 2026-07-31 · **v1.5:** แก้ P16 — เกณฑ์ `NOT NULL`+ไม่มี default ให้ false positive · ที่ถูกคือ input/output ของ trigger (แก้โดย eywa-deezy 2026-08-27) · **v1.4:** เพิ่ม P16 · **v1.3:** เพิ่ม P15 (ตารางแชร์ — ใครชนะตอนชื่อซ้ำ) + ขยาย P5 (layout render ฟิลด์ที่ schema ไม่ประกาศ) + ขยาย P13 (ปิดโดเมน status) — จาก VTH 2026-08-03 · **v1.2:** เพิ่ม P14 (เอกสาร ≠ การบังคับใช้ — จาก cutover VTH) · **v1.1:** เพิ่ม P13 (stamp:live) + ขั้น deploy ใน pipeline · **สถานะ:** 🔒 Locked
> **ขอบเขต:** **UNIVERSAL** — ทุกแบรนด์ที่ใช้ `seo_website_page_master` + `seo_x_ads_keywords_contextual_master` + `seo_citations`
> **ที่มา:** field-tested กับ VTH BioDent — 16 หน้า / 4 รอบทดลองแบบมีตัวควบคุม (2026-07-29 → 07-31)
> **Companion:** DR-045 (ฉบับนี้) · DR-043 Keyword Assignment · DR-044 Citation Pool · DR-020 Content Templates
>
> **Pamrel** [pam.ˈrɛl] — Na'vi แปลว่า "การเขียน" (`pamrel si` = เขียน) เข้าชุดกับ **EYWA** (เครือข่ายความรู้) และ **Tsaheylu** (ชั้นสัญญาณ conversion)

---

## 0. PAMREL คืออะไร — และทำไมต้องมีชื่อ

เขียนคอนเทนต์ 1 หน้าให้ถูกต้อง ต้องใช้เอกสาร 3 ฉบับ + สคริปต์ 7 ตัว + ตาราง 8 ตาราง เวลาสั่งงานจึงกลายเป็นการไล่ชื่อไฟล์ทีละอัน **PAMREL คือชื่อเรียกรวมของทั้งชุด**

```
"เขียนหน้า <fp> ตาม PAMREL"
```

### ชุดประกอบ

| ชั้น | สิ่งที่มี | อยู่ที่ |
|---|---|---|
| **สเปกกลาง** | ฉบับนี้ (กระบวนการ + กติกา + สัญญาของเกต) | `eywa-protocol-spec/` |
| | `Keyword_Assignment_SOP_v1_0.md` — B-rule §4 · intent matrix §5 | `eywa-protocol-spec/` |
| | `Citation_Pool_SOP_v1_0.md` — G1–G15 + locator round-trip *(corrected 2026-08-24: G12–G15 มีจริงและรันใน `run-citation-qa-gates.py`)* | `eywa-protocol-spec/` |
| | `Content_Templates_EYWA_v1_0.md` — T1–T19 + T2a–T2e + T6a · โค้ดเทมเพลตตรวจกับทะเบียนของแบรนด์ ไม่ใช่รายการ T-code กลาง (DR-057 §5) *(corrected 2026-08-24 against live schema)* | `eywa-protocol-spec/` |
| **ของแบรนด์** | `docs/CONTENT-WRITING-SOP.md` — ขั้นตอนพร้อมคิวรีจริงของแบรนด์ | `<brand>/docs/` |
| | `docs/template-block-standards.md` — §A สภาพข้อมูล · §B block ต่อ template · exemplar | `<brand>/docs/` |
| **เครื่องมือ** | `brief` · `check:keywords` · `check:density` · `scan:headings` · `check:links` · `gen:links` · `stamp:live` | `<brand>/web/scripts/` |
| **ใบสั่งงาน** | ผลลัพธ์ของ `npm run brief -- <fp>` — ใช้แล้วทิ้ง | ไม่ commit |

> 🔴 **สเปกคือกฎ · เอกสารแบรนด์คือวิธีทำกับข้อมูลจริง · สคริปต์คือตัวบังคับ** ขาดชั้นใดชั้นหนึ่งแล้วอีกสองชั้นจะเน่าเงียบ ๆ

---

## 1. Pipeline — 7 ขั้น

```
1. brief      npm run brief -- <fp>        ใบสั่งงานจาก DB + ธงเตือนที่คำนวณได้เอง
2. veto?      ถ้า brief ขึ้น 🛑 → หยุด แจ้ง operator (§3)  ห้ามเขียนอ้อม
3. write      .yaml ตาม §B ของ template นั้น
4. gates      รันทุกตัวที่ brief ระบุ
5. write-back เขียนกลับ DB — junction · title/meta · paa_checked_at · anchor_text
6. deploy     push → CI build + deploy → stamp:live flip status Planned→Live อัตโนมัติ
7. report     ช่องโหว่ของเอกสารที่เจอ + contentGaps ที่ลง
```

**ขั้น 7 ไม่ใช่พิธีกรรม** — เอกสารแน่นขึ้นจากรอบการเขียนจริงเท่านั้น ไม่ใช่จากการวางแผน VTH เจอช่องโหว่ 4 → 8 → 3 → 5 ข้อ ตลอด 4 รอบ ทุกข้อกลายเป็นกฎในสเปก

---

## 2. หลักการที่ไม่ขึ้นกับแบรนด์

### P1 · กฎที่ไม่มีตัวบังคับ = กฎที่ไม่มีอยู่จริง

B10 (ห้ามคีย์เวิร์ดฟอรัมเป็น primary) ถูกเขียนไว้ตั้งแต่ต้น เคยถูกใช้จริงตอนวางผัง แต่ถูกจัดเป็น "กลยุทธ์" ไม่ใช่ "compliance" จึงไม่มี unit test เหมือน B1/B9

**ผล: VTH 4 หน้า · Deezy 5 หน้า** หลุดถึงคิวเขียนพร้อม target ที่ใช้ไม่ได้ ไม่มีอะไรฟ้องเลยจนกว่าจะมีคนเขียนสคริปต์

> **ทุกกฎที่ประกาศ ต้องมีคิวรีหรือสคริปต์ที่ทำให้มันล้มได้** ถ้าเขียนกฎแล้วไม่มีตัวตรวจ ให้ถือว่ายังไม่ได้ประกาศ

### P2 · ตามหาอาการ อย่าตามหาอักขระ

ตอน audit คอลัมน์ `authors` ใน `seo_citations` — จับด้วย `[*]` และ `et al` ได้ 9 แถว ยิงเสร็จยังเหลือ เพราะนั่นคือ**เศษ**ที่ความเสียหายทิ้งไว้ ไม่ใช่ตัวความเสียหาย

รูปจริงคือสตริง `Author. Title. Year.` ถูก ETL ตัดที่จุดแรก จับด้วย `title like authors[1] || '.%'` **ทีเดียวเจอครบ** — เจอเพิ่ม 2 แถวและเปิดโปง placeholder อีก 23 ที่ pattern เดิมมองไม่เห็นเลย

### P3 · `is not null` ≠ มีข้อมูล

`seo_x_ads_keyword_serp_competitors.related_searches` ฝั่ง VTH เป็น `not null` ครบ 1,509 แถว **แต่ว่างทั้งหมด** เอกสารเวอร์ชันแรกเช็คแค่ null แล้วเขียนว่า "มีครบ" ส่งคนเขียนไปหาคอลัมน์ว่าง *(corrected 2026-08-24 against live schema: คอลัมน์นี้ไม่ได้อยู่บน page master · ยังจริงอยู่ — VTH BioDent 1,509 แถว ว่าง 1,509 · ทั้งตาราง 13,666 แถว ไม่ว่างแค่ 522)*

```sql
btrim(col::text) not in ('','[]','{}','null','""')
```

เช็คเนื้อจริงเสมอ · ตารางลูกที่มีแถวแต่ทุกคอลัมน์ null ก็นับว่าไม่มีข้อมูล

### P4 · ตัวเลขในเอกสารเน่า คิวรีคือความจริง

`competitors_content_json` ขยับ **729 → 1,044 ภายในวันเดียว** เพราะ ETL ยังโหลดอยู่ เอกสารที่ระบุจำนวนแถวจะผิดเสมอในที่สุด — เลขคู่นั้นเป็น**สไลซ์ของ VTH** (จาก 1,509 แถว) ณ 2026-08-24 กลายเป็น **1,504 จาก 1,509** ส่วนทั้งตารางคือ **13,644 จาก 13,666** ยิงเอาเองด้วย `select count(*) from seo_x_ads_keyword_serp_competitors where competitors_content_json is not null` (เติม `and brand='VTH BioDent'` ถ้าจะเอาสไลซ์แบรนด์) อย่าอ่านตัวเลขนี้ *(corrected 2026-08-24 against live schema · แก้รอบสอง: รอบแรกเอาเลขทั้งตารางมาสวมเป็น "ตัวเลขเดียวกัน" กับเลขสไลซ์แบรนด์)*

> เขียนตัวเลขได้ **แต่ต้องมีวันที่กำกับและคิวรีอยู่ข้าง ๆ** และต้องบอกว่าให้ยิงคิวรีแทนการอ่านตัวเลข

### P5 · Zod ผ่าน ≠ layout render

`baseFields` ยอมรับทุก field บนทุก template แต่ layout อาจไม่ render — **build เขียว ไม่มี error ไม่มี warning block หายเงียบ**

ตัวอย่างจริง: `crisis` อยู่ใน baseFields ทั้ง 21 template ต่อสายจริง 2 (VTH) / 3 (Deezy) — **ต่างกันระหว่างแบรนด์ ห้ามลอกข้าม**

```bash
grep -rl "<ComponentName>" web/src/layouts/templates/    # โค้ดคือความจริง เอกสารคือภาพถ่าย
```

§B ของทุก template ต้องมีบรรทัด "block ที่ layout นี้ไม่ render"

**และมันเกิดกลับทางได้ด้วย — layout render ฟิลด์ที่ schema ไม่เคยประกาศ** Zod ตัด key ที่ไม่รู้จักทิ้งก่อนที่ layout จะได้เห็น ผลคือ `<section>` ที่มีอยู่ในโค้ดและมีใน ToC แต่ไม่มีวันมีเนื้อ

VTH 2026-08-03: `Service.astro` render `<section id="definition">` เป็นบล็อกแรกของ body และใส่ใน ToC มาตลอด แต่ collection `service` ไม่เคยประกาศ `definition` — หน้า `ขูดหินปูน` ถูก push ทั้งที่ 6 ย่อหน้าซึ่งเป็นแกนทั้งหมดของหน้าไม่เคยขึ้น หน้าเปิดมาชนหัวข้อกลางเรื่อง **density · scan:headings · check:links · check:keywords · astro check ผ่านหมดทุกตัว** เพราะไม่มีเกตไหนเทียบสิ่งที่เขียนกับสิ่งที่ขึ้น operator เป็นคนเห็นเอง

```bash
# ทั้งสองทางตรวจด้วยคำถามเดียว: ทุก key ที่เขียนในไฟล์ ขึ้นบน HTML จริงไหม
node -e 'const h=require("fs").readFileSync("dist/<slug>/index.html","utf8");
  for(const [k,v] of Object.entries({definition:"<ประโยคจริง>", causes:"<หัวข้อจริง>"}))
    console.log((h.includes(v)?"✅ ":"❌ ")+k)'
```

เกตที่มีอยู่ตรวจ "หน้าถูกต้องไหม" ไม่มีตัวไหนตรวจ "หน้าครบไหม" — **build เขียวคือคำตอบของคำถามที่ไม่ได้ถาม**

### P6 · เขียนกลับ DB ทุกครั้ง ไม่งั้นได้ความจริงสองชุด

หน้าแรกที่ VTH เขียนตัด citation 2 ตัวและเพิ่ม 4 ตัว **แต่ junction ไม่ถูกแตะเลย** — DB บอกว่าหน้านี้อ้างงานที่ไม่มีบนหน้า และไม่รู้จักงานที่หน้าใช้จริง

บังคับเขียนกลับ: `seo_page_citations` (เรียง `inline_position` ตาม References) · `seo_title`/`meta_description` · `paa_checked_at` · `anchor_text` ของลิงก์ขาเข้า

### P7 · `anchor_text` เป็นสำเนาแช่แข็งของ `seo_title`

เขียน title ใหม่เมื่อไหร่ ลิงก์ขาเข้าทุกเส้นยังโฆษณาชื่อเก่า **ไม่มี build ไหนเตือน**

```sql
select count(*) from seo_page_internal_links l
join seo_website_page_master p on p.page_fingerprint = l.to_page_fp
where l.anchor_text <> p.seo_title;     -- ต้องได้ 0
```

🔴 **เกตนี้ยังยิงไม่ออก** — คิวรีข้างบนตามที่เขียน วัด 2026-08-24 ได้ **9,754 จาก 16,564 แถว** (deezy 5,794 · smilescape 2,804 · vth 1,156) เพราะ `seo_page_internal_links.anchor_variant_type` เป็นคำศัพท์ 4 ค่าที่**ตั้งใจ**ให้ anchor ต่างจาก title (`partial` 9,402 · `topical` 4,430 · `branded` 2,066 · `exact` 524 · NULL 142) — ขาดคำตัดสินของ operator ว่าเกตนี้ครอบลิงก์ชุดไหน (ต่อให้จำกัดที่ `exact` ก็ยังไม่ตรง 419 จาก 524 แถว) · และ `<>` เองยังนับไม่ครบซ้ำอีกชั้น: deezy มี **95 แถวที่ `seo_title` เป็น NULL** ซึ่ง `<>` คืน NULL แล้วหล่นออกจากผลเงียบ ๆ — เขียนเป็น `is distinct from` ได้ **9,849** *(corrected 2026-08-24 against live schema · แก้รอบสอง: รอบแรกลง 9,849 ให้คิวรีที่เขียนด้วย `<>` ซึ่งคืน 9,754)*

### P8 · แถวที่ขาด locator ตัวใดตัวหนึ่ง คือแถวที่จะถูกสร้างซ้ำ

AAOMS position paper อยู่ในสระมาตลอด มี DOI แต่ `pubmed_pmid` เป็น null → คนที่ค้นด้วย PMID หาไม่เจอ **สร้างใหม่ซ้ำสองใบ** และใบนั้นทำ migration ล้มที่ unique constraint

เติม locator ให้ครบทุกช่องที่หาได้ ไม่ใช่แค่ช่องที่ตัวเองใช้

### P9 · volume 0 ไม่ใช่เหตุผลที่จะไม่ใช้คำนั้น

เครื่องมือไม่มีข้อมูล ≠ ไม่มีคนค้น long-tail ทางการแพทย์หายจากทุกเครื่องมือเป็นปกติ (ตรวจ DFS: `ฝังเข็ม ลดปวดขากรรไกร` · `ฝังเข็มลดปวด` · `ฝังเข็ม กราม` **ไม่มีสักคำ**)

**เลือกคำที่ตรงเจตนาการสื่อสารของหน้าไว้ก่อน แล้ว optimize เมื่อมี GSC** ซึ่งเป็นข้อมูลจริงของเราเอง

เงื่อนไขเดียว: ต้องเป็น**คำที่คนไข้พิมพ์จริง** ไม่ใช่ศัพท์วิชาการที่เราชอบ

### P10 · ห้ามบิดภาษาเพื่อ exact match

`ฟันเกในเด็ก` เป็นภาษาไทยธรรมชาติของ target `ฟันเก เด็ก` — บังคับให้ตรงตัวอักษรจะได้ string ตรงแลกกับประโยคที่อ่านไม่ออก **placement contract แพ้ความอ่านรู้เรื่องเสมอ**

### P11 · guard คือขอบบน ไม่ใช่เป้า

stuffing guard เป็น**สัญญาณให้กลับไปอ่านทวน** เขียน → วัด → ตัด คือ loop ที่ออกแบบไว้ ไม่ใช่ความล้มเหลว · **ห้ามคำนวณ density ด้วยมือ** (วัดมือพลาดมาแล้ว 3 แบบใน 2 หน้าแรก)

### P12 · exemplar เป็นตัวเร่ง ไม่ใช่เงื่อนไข

VTH เขียน T6 สำเร็จโดยไม่มี exemplar เลย **ตราบใดที่ §B ของ template นั้นระบุ silent-drop ครบ** — template ที่ยังไม่มี exemplar ให้เผื่อเวลาตรวจ P5 มากกว่าปกติ แล้วจดลง §B ทันที

### P13 · หน้าที่ ship แล้ว ต้องมีอะไรเขียน status กลับ ไม่งั้นแผนกับเว็บจะไม่ตรงกัน

VTH มี 17 หน้าอยู่บน production ขณะที่ `page_master` ยังบอกว่า `Planned` ทั้งหมด — สองวันโดยไม่มีอะไรฟ้อง จับได้เพราะ operator สังเกตเอง

**อ่านจาก `dist/` ไม่ใช่จาก YAML** — `published: true` ในไฟล์คือ*เจตนา* หน้าใน `dist/` คือ*ข้อเท็จจริง* และหน้าที่เขียนเป็น `.astro` route ไม่มี YAML ให้สแกนเลย (Deezy เจอหน้าพวกนี้ค้าง `Planned` ตลอดกาลทั้งที่รับ traffic · VTH เจอ 2 หน้าคือ home กับหน้าโปรไฟล์หมอ)

**`canonical_url` ใช้ host production เสมอ ไม่ใช่ host ที่ hosting อยู่ตอนนี้** — staging/preview เป็นการจัดการรอบปล่อยภายใน ไม่ใช่ตัวตนของหน้า DB ควรตรงกับ canonical ที่ HTML ประกาศ · การเขียนกลับจาก path ที่ build ออกมาจริงยังจับ path ที่ผิดได้ด้วย (VTH เจอ trailing slash หายทุกแถว และหน้าหมอถูกบันทึกเป็น `/dr-amornpong` ทั้งที่อยู่ที่ `/team/dr-amornpong/`)

**คอลัมน์ `status` ต้องปิดโดเมนด้วย ไม่ใช่แค่มีคนเขียนกลับ** — สคริปต์พลิกเฉพาะ `Planned → Live` ค่าอื่นจึงมองไม่เห็นถาวร VTH 2026-08-03: มีคนพิมพ์ `Published` ลง 4 แถวด้วยมือ คอลัมน์เป็น free text ไม่มี CHECK จึงรับเข้าเงียบ ๆ ทั้งสี่หน้าหลุดออกจาก `stamp:live` จนกว่าจะซ่อม — จะเสิร์ฟทราฟฟิกโดยไม่มี canonical และมี `published_date` ที่พิมพ์เอาไม่ใช่ที่สังเกตได้

```sql
alter table seo_website_page_master add constraint chk_page_status
  check (status is null or status in ('Planned','Live','Merged','Dropped'));
```

ยิง UPDATE ค่าผิดเข้าไปจริงหลังใส่ constraint เพื่อพิสูจน์ว่ามันกันได้ (P14) — อย่าอ่าน definition แล้วสรุป

constraint นี้ **ใส่ไปแล้ว** — `chk_page_status` อยู่บน `seo_website_page_master.status` และโดเมนปิดจริง วัด 2026-08-24: 2,358 แถวมีแค่ `Planned` 1,513 · `Live` 742 · `Merged` 102 · `Dropped` 1 ไม่เหลือ `Published` สักแถว *(corrected 2026-08-24 against live schema)*

### P14 · เอกสารบอกกฎ ระบบบังคับอีกอย่าง — ต้องยิงของจริงถึงจะรู้

P1 บอกว่ากฎต้องมีตัวบังคับ **P14 คืออีกด้านของเหรียญ: ตัวบังคับที่มีอยู่ อาจทำมากกว่าหรือน้อยกว่าที่เอกสารเขียนไว้**

ตอน cutover ของ VTH: `robots.txt` ที่ Cloudflare เสิร์ฟ ลิสต์ Disallow แค่ crawler สำหรับ**เทรน** (`GPTBot` `ClaudeBot` `CCBot`…) แต่ WAF rule กลับ **403 ใส่ crawler สำหรับ*อ้างอิง*ด้วย** (`OAI-SearchBot` `ChatGPT-User` `Claude-User` `PerplexityBot`) ซึ่งไม่มีชื่ออยู่ในไฟล์นั้นเลย — และ `Googlebot` ผ่านปกติ การเช็คแบบทั่วไปจึงไม่เห็นอะไรผิด

**อ่านไฟล์ config แล้วสรุปว่าระบบทำอะไร = เดา** — สรุปผิดไป 2 รอบก่อนจะมีใครยิง UA จริง

> เกตทุกตัวที่เขียนใน §4 มีเหตุผลเดียวกัน: มันยิงของจริงแล้ววัดผลลัพธ์ ไม่ได้อ่านว่าใครประกาศอะไรไว้
>
> ก่อนสรุปว่า "ตั้งค่าถูกแล้ว" — ยิงคำขอที่เหมือนของจริงที่สุดเข้าไป แล้วดูว่าได้อะไรกลับมา

### P15 · ตารางที่แชร์ข้ามแบรนด์ ต้องมีกฎว่าใครชนะตอนชื่อซ้ำ

`seo_topic_cluster_master` · `seo_citations` · `seo_entity_graph` ใช้ร่วมกันทุกแบรนด์ แถวที่ `brand_scope = ['*']` **ไม่ใช่ของแบรนด์ที่สร้างมัน** แต่เป็นของทุกแบรนด์ที่ใช้ตารางเดียวกัน

เมื่อสองแถวอธิบายสิ่งเดียวกัน ต้องยุบ และกฎคือ:

| ข้อ | กฎ |
|---|---|
| 1 | ไม่มี brand scope จำกัด = แชร์ทั้งตาราง ไม่ใช่ของแบรนด์ต้นทาง |
| 2 | แถวที่รอดคือแถวที่มาจาก**แบรนด์ที่ไปไกลที่สุด** (`load_from`) — ไม่ใช่แถวที่มีหน้ามากกว่า |
| 3 | slug ที่ปลดระวางเก็บไว้เป็น `aliases.merged_from` บนแถวที่รอด · แถวเดิม `status='merged'` **ห้ามลบ** |
| 4 | แบรนด์ที่ตามหลังต้อง dedupe คลัสเตอร์ตัวเองกับแบรนด์ที่นำหน้า **ก่อน**เริ่มใช้ |

🔴 **ข้อ 3 รันได้แค่ตารางเดียว** — `aliases.merged_from` (jsonb) + `status='merged'` มีจริงเฉพาะ `seo_topic_cluster_master` (merged 7 จาก 58 แถว) · `seo_entity_graph` ไม่มีคอลัมน์ `status` ต้องใช้ `entity_lifecycle='merged'` แทน (23 จาก 732 แถว) และ `aliases` ที่นั่นเป็น text ธรรมดา ไม่ใช่ jsonb · `seo_citations` ไม่มีทั้งสองคอลัมน์ — ยังไม่มีที่บันทึกการยุบเลย ข้อ 1/2 (`brand_scope` · `load_from`) รันได้ครบทั้งสามตาราง *(corrected 2026-08-24 against live schema)*

🔴 **ตรวจข้อมูลบนแถวที่กำลังจะแพ้ก่อนเสมอ** VTH 2026-08-03: แถวที่ปลดระวางถือ `descriptions` ทั้ง en+th อยู่แถวเดียว ส่วนแถวที่จะรอดไม่มีเลย ยุบตรง ๆ = ทำลาย prose ชุดเดียวที่มีของหัวข้อนั้นแบบเงียบ ๆ ต้องย้ายมาก่อนปลดระวาง

หลังยุบต้อง regen สิ่งที่ฝัง `cluster_id` ไว้ (เช่น `gen:page-context` → tracking payload) และอัปเดตเอกสารแผนที่อ้าง slug เดิม **ยกเว้นบันทึก audit ที่ลงวันที่ไว้** ซึ่งเป็นบันทึกของสิ่งที่เคยจริง ไม่ใช่ของที่ต้องแก้ย้อนหลัง

### P16 · `fingerprint` เป็น output · `slug` เป็น input ของการ derive — ชื่อคอลัมน์หลอก

`seo_entity_graph` · `seo_citations` · `seo_entity_relationships` — ทั้งสามตารางมี `NOT NULL` โดยไม่มี `column_default` อยู่หลายคอลัมน์ และ **`fingerprint` กับ `fingerprint_display_name` ก็อยู่ในกลุ่มนั้นด้วย ทั้งที่ trigger เติมให้จริง**

```
seo_citations             fn_set_fingerprint_generic('cite', 'citation_slug', 'title')
seo_entity_relationships  fn_set_fingerprint_generic('erel', 'edge_type', 'edge_type')
seo_entity_graph          fn_set_fingerprint_entity_graph()
```

```sql
IF NEW.fingerprint IS NULL THEN  NEW.fingerprint := 'ent_' || generate_ulid16();  END IF;
IF NEW.fingerprint_display_name IS NULL THEN
   NEW.fingerprint_display_name := right(fingerprint,6) || '::' ||
        COALESCE(NEW.entity_slug, slugify(NEW.entity_name), 'unknown');
END IF;
```

**อาร์กิวเมนต์ตัวที่สองคือ `citation_slug` — trigger *อ่าน* มันเพื่อประกอบ display name ไม่มีบรรทัดไหนเขียน slug เลย**

> `citation_slug` และ `entity_slug` ไม่ใช่ derived field ที่ระบบเติม **มันคือ input ของการ derive** ชื่อคอลัมน์คือสิ่งที่หลอก เพราะอ่านเหมือน output

#### วิธีตรวจ

`NOT NULL` + ไม่มี `column_default` **ยังไม่ใช่คำตอบ** — `information_schema` มองไม่เห็น trigger จึงแยก "ระบบเติมให้" กับ "ต้องส่งเอง" ไม่ออก

อ่าน `pg_get_triggerdef` ของ BEFORE INSERT trigger บนตารางนั้น แล้วแบ่ง:

| | |
|---|---|
| คอลัมน์ที่ trigger **เขียน** (`fingerprint` · `fingerprint_display_name`) | **output — ห้ามส่ง** · `trg_prevent_fingerprint_change` รออยู่ตอน UPDATE |
| คอลัมน์ที่ trigger **อ่าน** (ตัวที่ถูกส่งเป็นอาร์กิวเมนต์ slug) | **input — ต้องส่งเอง** ไม่งั้น `23502` |

`trg_normalize_entity_slug BEFORE INSERT/UPDATE **OF entity_slug**` เข้ากันพอดี — normalize ยิงเมื่อมีค่าแล้ว · generate ไม่เคยแตะ slug เลย **เส้นแบ่งไม่ได้อยู่ที่ตาราง แต่อยู่ที่ว่าคอลัมน์นั้นเป็น input หรือ output ของ fingerprint**

#### ที่มา — และบทเรียนซ้อนอยู่ในนั้น

รายงานจาก `eywa-deezy` 2026-08-27 (`23502` บน `entity_slug` · รูปเดียวกับ `citation_slug` วันก่อนหน้า)

ฉบับแรกของ P16 เขียนเกณฑ์ว่า *"หา `NOT NULL` ที่ไม่มี `column_default` นั่นคือของที่ต้องส่งเอง"* — เขียนจากตาราง trigger ในเอกสารโดยไม่ได้ทดสอบ `eywa-deezy` ยิง insert จริงแล้วชี้ว่าเกณฑ์นั้นจะสั่งให้คนส่ง `fingerprint` เอง ซึ่งไม่จำเป็นและชน `trg_prevent_fingerprint_change` ตอน UPDATE

**P16 ฉบับแรกละเมิด P14 ในเนื้อของตัวเอง** — อ่าน schema doc แล้วสรุปพฤติกรรมระบบ แทนที่จะยิงของจริง กฎที่บอกว่า "อย่าเชื่อเอกสาร" ถูกเขียนขึ้นจากเอกสาร และผิดด้วยเหตุผลที่ตัวมันเองเตือนไว้

---

## 3. Keyword veto — เมื่อ target ใช้ไม่ได้ ให้หยุด

target ที่ผ่าน gate ตอน assign ยัง**ใช้ไม่ได้จริงตอนเขียน**ได้

| อาการ | ตัวอย่างจริง |
|---|---|
| ชน B-rule §4 ของ Keyword Assignment SOP | `… pantip` (B10) · `ใกล้ฉัน` บนหน้าที่ไม่ใช่ Local (B11) · เลขปี (B3) · `ราคาถูก` (B6) |
| คำนั้นเขียนลงเนื้อหาไม่ได้ | ชื่อฟอรัมในเนื้อหาการแพทย์ |
| SERP ของคำเป็นคนละเรื่องกับหน้า | `ฝังเข็ม dry needling` 216/mo — คู่แข่งทั้ง 7 รายพูดเรื่อง "นิยาม + เทียบฝังเข็มจีน" ไม่มีใครพูดถึงขากรรไกร |
| intent ขัดกับ page-type ตาราง §5 | คำ Transactional บนหน้า Knowledge |

### ห้าม 3 อย่าง

1. **ห้ามยัดคำลงเนื้อหาให้ได้ exact match**
2. **ห้ามเขียนหน้าให้เข้ากับคำที่ผิด** — เสียทั้งคำนั้นและเสียคำที่หน้านี้ควรได้
3. **ห้ามเปลี่ยน target เองเงียบ ๆ** — keyword map เป็นของทั้งคลัสเตอร์ เปลี่ยนหน้าเดียวทำให้สองหน้าแย่งคำกัน

### ขั้นตอน

```
1. หยุดเขียนหน้านั้น           ← ไม่ใช่เขียนอ้อม ไม่ใช่ข้ามเงียบ ๆ
2. แจ้ง operator + เสนอคำแทน    พร้อมเหตุผล (อ้าง B-rule หรือหลักฐาน SERP)
3. รอ operator อนุมัติ         ← จบรอบตรงนี้ ทำหน้าอื่นต่อ
4. insert คำใหม่ → ยิง DFS เก็บ volume/SERP
5. เขียนหน้านั้นรอบถัดไป ด้วยคำที่มีข้อมูลครบ
```

รายงานที่แจ้งกลับต้องมี: คำเดิม + เหตุผล · คำที่เสนอ + volume (**ไม่มีให้บอกตรง ๆ ห้ามเดา**) · เช็คแล้วว่าไม่ถูกจอง · ผลกระทบกับคลัสเตอร์

---

## 4. สัญญาของเกต — แบรนด์ต้องมีครบ

| เกต | ต้องทำอะไร | exit 1 เมื่อ |
|---|---|---|
| `brief` | พ่นสัญญาของหน้า + สภาพข้อมูลรายคอลัมน์ + ธง veto + คำสั่งเกตที่กรอก slug/keyword ให้แล้ว | — (เป็น generator) |
| `check:keywords` | audit target ทุกหน้าเทียบ B-rule §4 | มีหน้าชน |
| `check:density` | นับ hit จาก HTML ที่ render จริง **ตัด ToC / กล่อง debt / navigation ออกก่อนวัด** | เกิน guard หรือ 0 hit |
| `scan:headings` | H1 เดียวต่อหน้า · ไม่ข้ามระดับ · aside มีชื่อ | มี issue |
| `check:content-citations` | ทุก `label`+`url` ใน `references:` — locator resolve ได้ · label ระบุเปเปอร์ถูก · มีแถวใน `seo_page_citations` หนุน | locator ชี้ไปคนละเปเปอร์ |
| `check:keyword-collisions` | หาหน้าที่แย่ง query เดียวกัน (normalize · containment · edit distance · seo_title) แล้ว **เสนอ** ว่าใครควรเป็น target | มีหน้าถือ target_keyword_fp ซ้ำกัน |
| `check:links` | canonical tie-breaker + related block ตรงแผน | assertion ล้ม |
| `gen:links` | export แผนลิงก์ → JSON ที่ commit | — |
| `stamp:live` | อ่าน `dist/` → flip `status` Planned→Live · `published_date` ครั้งแรกครั้งเดียว · `canonical_url` จาก path ที่ ship จริง | — (idempotent · exit 0 ถ้าไม่มี key) |

### 4.1 `references[].label` — เขียนได้สองแบบ แต่ต้องระบุเปเปอร์ได้ (DR-061)

จนถึง 2026-08-24 ไม่มีเอกสารไหนเขียนว่า `label` ต้องมีอะไร ผลคือ vth-biodent เขียนเป็น
ชื่อเปเปอร์ ส่วน deezy เขียนเป็นข้อสรุปภาษาคนไข้ ทั้งสองฝั่งไม่รู้ว่าอีกฝั่งทำคนละแบบ และ
เกตบล็อกฝั่งหลังทั้งที่ไม่ได้ผิดอะไร

**กติกา** — `label` เป็นข้อความอะไรก็ได้ที่อ่านรู้เรื่อง แต่ต้องระบุได้ว่าหมายถึงเปเปอร์ไหน
ผ่านทางใดทางหนึ่ง:

```yaml
# แบบ ก — ชื่อเปเปอร์ (เกตเทียบกับชื่อเรื่องที่ resolve ได้)
- label: "Efficacy of occlusal splints in the treatment of temporomandibular disorders. Acta Odontol Scand. 2020."
  url: "https://pubmed.ncbi.nlm.nih.gov/32421379/"

# แบบ ข — ข้อสรุปภาษาคนไข้ + นามสกุลผู้เขียนคนแรก + ปี
- label: "เฝือกสบฟันช่วยลดอาการปวดข้อต่อขากรรไกรได้จริง (Alkhutari 2020)"
  url: "https://pubmed.ncbi.nlm.nih.gov/32421379/"
```

**ที่ห้ามคือแบบที่สาม** — ข้อสรุปล้วนไม่มีตัวระบุเลย ไม่ได้ห้ามเพราะเขียนไม่สวย แต่เพราะ
ไม่มีอะไรบอกได้ว่ามันหมายถึงเปเปอร์ไหน ซึ่งเป็นคำถามเดียวที่เกตนี้มีไว้ตอบ

เกตแยกเป็นสอง finding: **`wrong`** (locator ชี้ไปคนละเปเปอร์) บล็อก · **`label_form`**
(เขียนเป็นข้อสรุป แต่ระบุเปเปอร์ถูก) เตือนอย่างเดียว

> `label` เรนเดอร์ในลิสต์ References ที่พับปิดไว้ท้ายหน้า ไม่ใช่ในเนื้อความ — การใส่
> `(Surname ปี)` จึงไม่ทำให้บทความอ่านเหมือนรายงานวิจัย

> **`stamp:live` ต้องต่อเข้า CI หลังขั้น deploy** ไม่ใช่ให้คนรันมือ — รันกับสิ่งที่ ship จริง ไม่รันเมื่อ build ล้ม และไม่มี key ก็ต้อง exit 0 เพื่อไม่ให้ deploy ที่สำเร็จแล้วล้มเพราะ secret หาย · ต้องมีโหมด dry-run เพราะมัน PATCH แถว production

> **`check:density` มีกับดัก 3 ชั้นที่ทุกแบรนด์จะเจอ:** นับ hit จาก YAML แล้วหารด้วยฐานของ prose fields (คนละฐาน) · นับ `<main>` ทั้งก้อนโดยลืมว่ากล่อง debt อยู่ใน main · ToC ทวน H2 คำต่อคำ ทำให้ H2 ที่มี target ถูกนับสองครั้ง
>
> **ภาษาที่ไม่เว้นวรรค:** target เก็บแบบ space-tokenized แต่ prose เขียนติดกัน → ต้อง match แบบไม่สน space และไม่สนตัวพิมพ์ **ทั้งสองทางทำให้ hit เพิ่มขึ้นเท่านั้น guard จึงแน่นขึ้น ไม่มีทางหลวมลง**

---

## 5. ปรับใช้กับแบรนด์ใหม่

1. คัดลอก `CONTENT-WRITING-SOP.md` + `template-block-standards.md` จากแบรนด์ reference → เปลี่ยน `brand_id` / fingerprint prefix / ชื่อ section
2. **§A ต้องยิงคิวรีเองใหม่ทั้งหมด** — สภาพข้อมูลของแต่ละแบรนด์ไม่เหมือนกัน (ห้ามลอกตัวเลข P4)
3. **§B ต้องตรวจ layout ของแบรนด์เองว่า block ไหนไม่ render** (P5 — VTH กับ Deezy ต่างกันจริง)
4. คัดลอกสคริปต์เกต → ปรับ brand filter + exempt pattern ของ B11 ให้ตรงผัง section ของแบรนด์
5. รัน `check:keywords` **ก่อนเขียนหน้าแรก** — Deezy รันครั้งแรกเจอ 5 หน้าทันที
6. หน้าแรกของแต่ละ template = exemplar ทำอย่างประณีตแล้วเติมชื่อไฟล์ใน §B

> ⚠️ **สิ่งที่ห้ามลอกข้ามแบรนด์:** ตัวเลขสภาพข้อมูล (§A) · block ที่ไม่ render (§B) · นโยบาย medical review · รายชื่อคู่แข่งใน blacklist

---

## 6. สิ่งที่ PAMREL ไม่ทำ

สคริปต์ให้**วัตถุดิบ** ไม่ได้ให้**คำตอบ** — มุมของเรื่อง · โครง `body[]` · citation ตัวไหนรองรับประโยคไหน · ภาษาไทยที่อ่านลื่น **ยังเป็นงานคน** และตั้งใจให้เป็นอย่างนั้น

---

## 7. บันทึกการพิสูจน์

| รอบ | หน้า | template | ช่องโหว่ที่เจอ | หมายเหตุ |
|---|---|---|---|---|
| 1 | jaw-lock | T1 | 4 | หน้าแรกของแบรนด์ |
| 2 | tinnitus-tmj | T1 | 8 | |
| 3 | tinnitus-tmj เขียนใหม่ | T1 | 3 | **พลาด 0 จาก 12 กับดักเดิม** — session ที่ไม่เคยเห็นฉบับแรก |
| 4 | tmj-guide | T6 | 5 | **ไม่มี exemplar เลย** — ตัวชี้ขาดว่าเอกสารพาได้เอง |
| batch | 13 หน้า | T1·T5·T6 | — | เกตเขียวครบ ไม่มีคนรีวิวตามแก้ |

รอบ 1–3 ยังเถียงได้ว่าลอก exemplar ข้าง ๆ **รอบ 4 เถียงไม่ได้**

---

**References:** DR-045 · DR-057 · `Keyword_Assignment_SOP_v1_0.md` §4/§5 · `Citation_Pool_SOP_v1_0.md` G1–G15 · `Content_Templates_EYWA_v1_0.md` T1–T19 + T2a–T2e + T6a *(corrected 2026-08-24 against live schema)* · reference implementation `eywa-vth-biodent/docs/` + `eywa-vth-biodent/web/scripts/`
