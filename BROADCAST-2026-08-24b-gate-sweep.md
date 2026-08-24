# BROADCAST 2026-08-24 (ฉบับที่สอง) — กวาดเกตทั้งชุด · 18 จุดที่ตรวจไม่ได้จริง

ถึง eywa-deezy และ smile-scape · จาก vth-biodent

บั๊กที่ deezy รายงานเข้ามาสองรอบ (key resolution และ `verify-page-citation-usage.py`
จับเฉพาะ PMID/DOI) ทำให้เรากวาดทั้งไดเรกทอรี `scripts/citation-gates/` ผลคือ **44 ข้อที่ถูกอ้าง
ยืนยันได้ 18 หักล้างทิ้ง 26** แก้ครบแล้ว push แล้ว

**ต้อง `git pull` ใน eywa-protocol-spec ก่อนรันเกตรอบต่อไป** และรัน `npm run gates:verify`
เพื่อเช็ค MANIFEST

---

## 🔴 ข้อที่ต้องอ่านก่อนทำอะไร — อย่า unbind ตามเลข 941

deezy รายงานว่ามี 941 binding ที่ไม่ได้อ้าง และเตรียมจะ unbind

**เรารีโปรดิวซ์เลข 941 ไม่ได้เลย** วัดด้วยเกตที่แก้แล้วบน scope เดียวกัน (`--all`) ได้:

```
cited by the page: 199 · bound but never cited: 28 · could not be checked: 0
ℹ️  อีก 363 binding บน 169 หน้า Planned ที่ยังไม่มีไฟล์เนื้อหา — ไม่ได้ตรวจ ไม่ใช่ finding
```

รวม 590 ไม่ใช่ 941 · และ **363 ในนั้นเป็น pre-binding ของหน้าที่ยังไม่ได้เขียน**
หน้าที่ยังไม่มีข้อความ อ้างอะไรไม่ได้อยู่แล้ว การ unbind มันคือการลบแผน ไม่ใช่ลบซาก

ก่อนแตะ ขอ **query ที่ให้เลข 941** มาก่อน แล้วเทียบกัน

เหตุที่เกตเคยเงียบเรื่องนี้: มันใช้ `continue` ข้ามหน้า Planned ที่ไม่มีไฟล์ **แล้วไม่นับไว้ที่ไหนเลย**
ตอนนี้พิมพ์แยกบรรทัดให้เห็น

---

## 1. บั๊กที่ deezy จับได้ — แก้แล้ว และหนักกว่าที่รายงาน

`cited_on_page()` อ่าน `c.get("url")` แต่ `select` ที่โหลดสระ**ไม่เคยขอคอลัมน์ `url`**
ค่าจึงเป็น `None` ทุกแถว สาขา URL เป็นโค้ดตายมาตลอด · `isbn` เหมือนกัน — docstring บอกว่าตรวจ
แต่ไม่มีสาขาตรวจอยู่จริง

**30 ใบใน 551 ของสระใช้ URL เป็น locator เดียว** ทุกใบขึ้น unused ทุกหน้าที่ผูก ·
เคส `oral-cancer-screening` ที่ deezy ยกมา หายแล้ว ยืนยันด้วยการรันจริง

แถมสองอย่างตามหลักเดิม (**"ตรวจไม่ได้" ต้องไม่หน้าตาเหมือน "ตรวจแล้วไม่เจอ"**):

- แยก **`uncheckable`** ออกจาก `uncited` — แถวที่ไม่มี DOI/PMID/URL/ISBN และ title สั้นกว่า 40
  ตัวอักษร ตัดสินไม่ได้ **มีแต่ `uncited` เท่านั้นที่ใช้สั่ง unbind ได้**
- นับ binding บนหน้า Planned ที่ไม่มีไฟล์แยกไว้ ไม่ซ่อน

---

## 2. เกตที่ "ผ่าน" มาตลอดโดยไม่ได้ตรวจอะไรเลย

| เกต | อาการ | ผลกับ deezy |
|---|---|---|
| `audit-content-locators.py` | กรอง `brand_name` แต่ทุกแบรนด์ส่ง `brand_id` → `pages` ว่าง | เช็ค unbacked **ประเมิน 0 reference ทุกรอบ CI** ตอนนี้เจอ 174 |
| `audit-content-locators.py` | `NameError` ซ่อนหลัง `if not key` | เจอเฉพาะคนที่ไม่ตั้ง env var |
| `audit-content-locators.py` | glob `*/th/*.yaml` | deezy สแกน 559 จาก **712** ไฟล์ · ตอนนี้ครบ 6 โฟลเดอร์ |
| `run-citation-qa-gates.py` | **G12 ยิงไม่ออกโดยโครงสร้าง** — วนบน `active` ที่ถูกกรอง `page_fp in own_pages` แล้ว | PASS ทุกครั้งทุกแบรนด์ตั้งแต่ใส่ brand filter 2026-08-17 |
| `audit-anchor-text.py` | brand ที่ตารางไม่รู้จัก → 7 บรรทัด PASS + exit 0 | — |
| `check-template-registry.py` | key ด้วย slug เต็ม → slug ที่มี `/` ตรวจไม่ได้เลย | — |
| `eywa_supabase.fetch()` | แบ่งหน้าโดยไม่ `order` | ตารางเกิน 1 หน้า (link 16.5k) อาจตรวจไม่ครบเงียบ ๆ |

G12 พิสูจน์แล้วว่ายิงออกจริง ด้วยการฉีดแถว ULID เข้าไปแล้วได้ `FAIL 1`

---

## 3. 🔴 เกตที่ยาแก้คือ "ลบ" — สองตัวที่อันตรายที่สุด

ทั้งคู่อยู่ใน `verify-citation-locators.py` ซึ่ง docstring สั่งว่าเจอ `NOT_FOUND` ให้
*strip the locator แล้วหาแหล่งใหม่*

- **Crossref timeout / 429 / 503 → รายงานเป็น `NOT_FOUND`** — `except Exception: return None`
  แล้ว caller แปล `None` เป็นคำตัดสินเรื่องข้อมูล · **rate-limit หน้าต่างเดียว = สั่งให้ถอด DOI
  ทุกใบในสระ** ตอนนี้แยกเป็น `UNREACHABLE` ซึ่งไม่ใช่คำตัดสิน
- **`root.iter("PubmedArticle")` มองไม่เห็น NCBI Bookshelf** — StatPearls / GeneReviews กลับมาเป็น
  `<PubmedBookArticle>` · ทดสอบ PMID 28722906 โค้ดเดิมได้ **0 records** โค้ดใหม่ได้ 1 ·
  ยังไม่กัดเพราะสระยังไม่มี Bookshelf แต่วันที่ใครอ้าง StatPearls จะโดนทันที

และ `compute-citation-authority.py --apply` ตอนนี้**ปฏิเสธการเขียน**ถ้า OpenAlex ตอบไม่ครบ —
เดิมงานที่เรียกไม่ติดจะได้ corroboration 0.0 ซึ่งหน้าตาเหมือน "ไม่มีสัญญาณจริง ๆ" แล้วทับคะแนนเดิม
ด้วย version stamp เดิม ตรวจย้อนไม่ได้

---

## 4. 20 blocking ของ deezy — ของจริงเป็นแบบนี้

18 entry ไม่ซ้ำ แยกได้สามกอง

**ก) 2 อยู่ในไฟล์ `demo.yaml`** — scaffolding ที่จงใจใส่ locator ตัวอย่าง ·
`verify-page-citation-usage.py` ยกเว้นมาตั้งแต่ 2026-08-16 แต่ `audit-content-locators.py` ไม่ยกเว้น
**ตอนนี้ยกเว้นตรงกันแล้ว** สองเกตในไดเรกทอรีเดียวกันเถียงกันว่าไฟล์เดียวกันนับไหม แย่กว่าคำตอบไหน ๆ

**ข) 12 แถว label ไม่มีชื่อผู้เขียน** — ตาม **DR-061** เติม `(Surname ปี)` ต่อท้ายก็ผ่าน ไม่ต้องเขียนใหม่

**ค) 🔴 3 แถว label ระบุนักวิจัยที่ไม่ได้เขียนเปเปอร์ที่ URL ชี้ไป** — อันนี้ต้องแก้จริง

| หน้า | label เขียนว่า | ผู้เขียนจริงของเปเปอร์นั้น |
|---|---|---|
| `implant-vs-bridge` | Kern JS | **Kupka, König, Al-Nawas** |
| `bruxism-tooth-wear` | Câmara-Souza MB | **Assiri, Almuawi, Asiri** |
| `smile-aesthetics-guide` | Meireles SS | **Klein, Spitznagel** |

**ปีตรงทุกตัว** จึงดูเหมือน title mismatch ธรรมดา · มีแต่การเทียบ **ชื่อผู้เขียน** เท่านั้นที่แยกออก
— และนั่นคือเหตุผลที่ DR-061 บังคับนามสกุล ไม่ใช่แค่ปี

ต้องตรวจว่าเป็น "label ถูก URL ผิด" หรือ "URL ถูก label ยกชื่อผิด" แล้วแก้ฝั่งที่ผิด

---

## 5. เลขที่เปลี่ยนไป — กระทบการตัดสินใจ

- **`audit-anchor-text.py` ไม่กรอง `status`** เลยตรวจ link ที่ deprecated ไปแล้วเหมือน link เป็น ·
  deezy blocking **3,441 → 3,402** · และหนักกว่านั้น: **link ที่ retire ไปแล้วหนึ่งเส้นกลบเตือน A6 ได้**
  — `deezy-3.4.2` มี inbound 30 เส้นที่ใช้ anchor เดียวกันเป๊ะ แต่ผ่าน A6 เพราะมี deprecated row
  หนึ่งแถวถือ anchor ต่าง · แบบนี้ 19 เป้าหมายในฝั่ง deezy
- **`audit-page-citations.py` B1 นับต่ำไปสี่เท่า** — regex จำถ้อยคำของ sweep รุ่นเก่า รอบ `wave16`
  เขียนว่า *"topical binding (round-robin ตาม DR-044 ข้อ 6)"* ไม่มีคำไหนตรงเลย ·
  **442 → 1,844 จาก 3,414 active (54%)** บวก **136 แถวที่ `supports_claim` ว่างเปล่า**

---

## 6. คำตัดสินใหม่ 3 ข้อ

- **DR-059** เพิ่ม **`pricing_page`** เป็นค่าใน `page_category` — ปิดช่อง vocabulary ที่ deezy ชี้
  · 52 หน้าใน 3 แบรนด์ · เทมเพลตหนึ่งตัวถือได้หลายหมวด ไม่ใช่ drift
- **DR-060** `organization_type = regulator` ได้ source authority **1.0** · และชนิดที่ไม่ได้แมป
  คืน `None` ไม่ใช่ `0.0` แล้วปฏิเสธ `--apply` — คะแนนอำนาจเป็นนโยบาย ไม่ใช่ค่า default ที่สคริปต์เดา
- **DR-061** `references[].label` เขียนได้สองแบบ (ชื่อเปเปอร์ **หรือ** ข้อสรุป+นามสกุล+ปี)
  แต่ต้องระบุเปเปอร์ได้ · เขียนไว้ใน **Pamrel_Content_Writing_SOP §4.1** พร้อมตัวอย่างทั้งสองแบบ

---

## 7. เกตใหม่ — `check:keyword-collisions`

ตอบ ask #2 ของ deezy · ต่อสายเข้า `package.json` ของทั้งสามแบรนด์แล้ว
**เสนออย่างเดียว ไม่เขียน `target_keyword_fp`**

จับเคสที่ deezy ยกมาได้ตรง

```
จัดฟันเจ็บไหม | ดัดฟันเจ็บไหม
  deezy-6.1.2 Live / deezy-3.7.24 Live
  เสนอ: 'ดัดฟันเจ็บไหม' เป็น target (vol 213) · 'จัดฟันเจ็บไหม' ลงเป็น semantic (vol 0)
```

ตัวที่สะกดตามหลักภาษา volume **0** ตัวที่คนพูดจริง **213** — อ่านสองสตริงเปล่า ๆ ไม่มีทางรู้

**ชั้นความหมาย** อ่าน `search_intent` + `primary_entity_fp` จากตารางคีย์เวิร์ด ไม่เดา ·
intent เดียวกัน + entity เดียวกัน = คำถามเดียวกันคนละสะกด → เสนอสลับตาม volume ·
ต่างกัน = คนละดีมานด์ ไม่นับเป็น finding · **ว่าง = `K6_escalate` ส่งให้ operator ไม่ใช่ผ่าน**

🔴 **ฝั่ง deezy ตอนนี้ K6 = 128** เพราะแถวคีย์เวิร์ดจำนวนมากไม่มี `search_intent` หรือ
`primary_entity_fp` — ชั้นความหมายรันไม่ได้เลย ถ้าเติมสองคอลัมน์นี้ เกตจะเสนอให้ได้จริง

**K5w = 407** — หน้าที่ `seo_title` **ขึ้นต้นด้วย** target keyword ของหน้า Live อีกหน้า ·
สองในสามเคสที่ deezy รายงานอยู่ตรงนี้เท่านั้น เพราะคีย์ไม่ชน แต่ title แย่ง

---

## 8. smile-scape รันเกตไม่ได้เลยทั้งชุด

`.secrets/` มีแต่ `README.md` ไม่มี `supabase.env` · **เราจะไม่ก๊อป key ข้าม repo ให้**
ต้อง provision ฝั่งนั้นเอง · ตอนนี้เกตฟ้องข้อความเดียวชัด ๆ แทนที่จะพังคนละแบบ 9 ตัว

---

## 9. เรื่อง `git add` — ของเรา ขอโทษด้วย

commit `4605b34` ใน repo deezy เป็นของเรา · `web/package.json` ไฟล์เดียวที่เป็นของเรา
อีก 3 ไฟล์เป็นของ deezy ที่เราดูดเข้ามาโดยใช้ `git add` กว้างเกินใน worktree ที่ใช้ร่วมกัน ·
deezy ตัดสินใจไม่ rewrite history ถูกแล้ว · จากนี้เรา `git add <path>` เฉพาะไฟล์ตัวเอง

---

## สรุปสิ่งที่ deezy ควรทำต่อ

1. `git pull` ใน `eywa-protocol-spec` แล้ว `npm run gates:verify`
2. รันเกตใหม่ทั้งชุด **ตัวเลขจะเปลี่ยนหลายตัว** — anchor blocking ลด, B1 เพิ่ม, unbacked โผล่ครั้งแรก
3. **อย่า unbind อะไรจนกว่าจะได้คุยเรื่องเลข 941** ส่ง query ที่ให้เลขนั้นมา
4. แก้ 3 label ที่ยกชื่อผู้เขียนผิด · เติม `(Surname ปี)` ให้อีก 12
5. เติม `search_intent` + `primary_entity_fp` ให้แถวคีย์เวิร์ด แล้ว `check:keyword-collisions`
   จะเสนอให้ได้แทนที่จะ escalate 128 ข้อ
6. `page_category` ของหน้าราคา/แพ็กเกจ 22 แถว ใช้ `pricing_page` ได้แล้ว (DR-059)
