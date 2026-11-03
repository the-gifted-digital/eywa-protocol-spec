# VTH BioDent: ตรวจข้อมูล internal links / redirects / JS errors (2026-11-03)

จาก eywa-protocol-spec (Kameie command center) · ข้อมูลจาก GTGT `lffcbeszjqzioobqfdav` + curl หน้าเว็บจริง 2026-11-03

**สรุปสั้น:** ตาราง (`seo_page_internal_links`, `seo_page_live_links`, `seo_website_page_master`) เก็บข้อมูลถูกต้อง สิ่งที่ผิดคือ view ฝั่ง Kameie ที่เอาตารางมาเทียบกัน แก้ไปแล้ว 2 รอบ (K6c, K10a) ที่เหลือเป็น**แผนที่ไม่อัปเดตหลังเปลี่ยนโครงสร้างเว็บ** กับ**ปัญหาบนหน้าเว็บจริง** ซึ่งทีม VTH ต้องตัดสินใจ

---

## 1. ฝั่ง Kameie แก้แล้ว (ไม่ต้องทำอะไร)

| เรื่อง | เดิม | หลังแก้ |
|---|---|---|
| link "missing" (K6c, รันแล้ว 2026-10-31) | 1,350 · รวม link ไปหน้าที่ยังไม่สร้าง 856 และหน้าที่ Merge แล้ว | **471** · หน้าต้นทางและปลายทาง Live ทั้งคู่ |
| "Redirect to wrong page" (K10a, รอรัน) | 3 หน้า VTH ขึ้นเตือนทั้งที่ redirect ถูก: `/airway-monitoring` และ `/airway-assessment-3d` ไป `/volumetric-airway-analysis/`, `/oral-appliance-therapy` ไป `/mad/` | 0 · เดิมเทียบ URL เต็มกับ `redirect_target` ที่เก็บเป็น slug (`mad`) ตอนนี้เทียบเป็น slug ทั้งสองฝั่ง |

**K10a (รอรันใน SQL editor):**
- สร้างงาน webmaster "Add planned internal links" 1 งานต่อหน้าต้นทาง: VTH 121 หน้า / 473 link · Deezy 315 หน้า / 544 link
- งานปิดเองเมื่อ crawler เจอ link นั้นบนเว็บ
- เพิ่มแจ้งเตือน "Page UX" (JS error) กับ "Conversion drop"

## 2. ให้ทีม VTH ตรวจ / ตัดสินใจ

### 2.1 JavaScript error สูงมากบน 5 หน้า: **แก้แล้ว 2026-11-03**

> **อัปเดต:** VTH session ยืนยันว่า error มาจากหน้าที่ capture จาก WordPress ตอนนี้ URL เดิมทั้ง 8 ตัว 301 ไปหน้า `/lp/` แล้ว โดยเก็บ query string ไว้ (Kameie ตรวจด้วย curl `?gclid=x` แล้ว) ลบ `wp-content` และ `wp-includes` แล้ว (commit 27d0c5b) `scan:tracking` ผ่านครบ 7 หน้า `/lp/` ส่วน redirect ของ `/airway-*` กับ `/oral-appliance-therapy` ขึ้นแล้ว (8655304) แจ้งเตือน UX ใน K10a เตือนเฉพาะหน้าที่ยังเจอ error ใน 7 วันล่าสุด แจ้งเตือนของ URL เดิมจึงจะปิดเองภายในประมาณ 7 วัน

ข้อมูลจาก Clarity 28 วัน (ทุกอุปกรณ์):

| หน้า | session | session ที่เจอ script error | สัดส่วน |
|---|---|---|---|
| `/bmb-chronic` | 67 | 55 | 82% |
| `/ceramic-implant` | 64 | 50 | 78% |
| `/child-snoring-treatment` | 192 | 149 | 78% |
| `/tmj-ad` | 205 | 155 | 76% |
| `/brava-ai-invisible-brace` | 186 | 111 | 60% |

- **ลักษณะหน้า:** 3 หน้าแรกในตารางที่เป็น LP โฆษณา (`/tmj-ad`, `/bmb-chronic`, `/child-snoring-treatment`) คือหน้าที่กำลัง rebuild เป็น Astro `/lp/` (session lp-tmj-ad, lp-bmb-chronic, port-child-snoring-treat) แปลว่า error น่าจะมาจาก template / plugin ของ WordPress เดิม
- **แนวโน้ม:** error ทั้งเว็บลดลง จาก 57 session ต่อวัน (17 ต.ค.) เหลือ 8 (2 พ.ย.) แต่จำนวน session ทั้งเว็บก็ลดด้วย
- **สิ่งที่ขอ:**
  1. เปิด Clarity > JavaScript errors ของ 5 หน้านี้ แล้วระบุว่า script ตัวไหน error
  2. ตรวจว่าปุ่ม LINE / โทร (Tsaheylu) ยังทำงานบนหน้าเหล่านี้ไหม
  3. ถ้าหน้า Astro ใหม่ขึ้นแล้ว ตรวจว่า URL เดิม 301 ไปหน้าใหม่ และ error หายไป
- K10a จะเปิดแจ้งเตือน 5 ตัวนี้ใน Kameie และปิดเองเมื่อสัดส่วน error ต่ำกว่า 20%

### 2.2 หน้าที่ Merge แล้ว 81 หน้า ไม่มี `redirect_target`

- **ที่เจอ:** `seo_website_page_master` มีหน้าของ VTH ที่สถานะ `Merged` แต่ `redirect_target` เป็น null อยู่ 81 หน้า
- **ผลบนเว็บ:** ที่ curl ดูแล้ว ส่วนใหญ่ตอบ **404**:
  - `/myobrace`, `/myobrace-for-adults`, `/myobrace-myofunctional-protocol`, `/myobrace-breathing-training`, `/myobrace-treatment-journey`
  - `/mouth-breathing-facial-development`, `/adhd-airway-guide`, `/school-performance-breathing`, `/adult-tongue-tie-release`, `/myofunctional-therapy-school-performance`, `/pediatric-breathing`
- **ยกเว้น:** `/pediatric-airway` ตอบ 301 ไป `/pediatric-snoring/` (redirect มีอยู่จริง แต่ไม่ได้บันทึก target ใน DB)
- **GSC 28 วัน:** ทั้ง 81 หน้าไม่มีคลิกหรือ impression เลย น่าจะ Merge ตั้งแต่ตอนวางแผนก่อนหน้าขึ้นเว็บจริง จึงไม่เสีย traffic
- **ผลข้างเคียง:** health check ข้ามหน้าพวกนี้ทั้งหมด (`page_health_all` ตรวจเฉพาะหน้า Merged ที่มี `redirect_target`)
- **สิ่งที่ขอ:**
  1. ยืนยันว่า 81 หน้านี้ไม่เคยขึ้นเว็บจริง โดยเช็ก WordPress, GA4 ย้อนหลัง หรือ backlink ภายนอก
  2. หน้าที่เคยขึ้นเว็บจริง ให้ใส่ `redirect_target` แล้วทำ 301 บนเว็บ
  3. หน้าที่ไม่เคยขึ้น พิจารณาเปลี่ยนสถานะเป็น `Dropped` แทน `Merged` (ตาม Bible ถ้าทีมใช้ความหมายนี้)
  4. `/pediatric-airway` ใส่ `redirect_target = pediatric-snoring`

### 2.3 Internal link ในแผนชี้ไปหน้าที่ Merge แล้ว (54 link)

`seo_page_internal_links` (status `planned`) ยังมี link ที่ปลายทางเป็นหน้า Merged:

| ปลายทาง (Merged) | `redirect_target` | link | link ที่มาจากหน้า Live |
|---|---|---|---|
| `oral-appliance-therapy` | `mad` | 14 | 9 |
| `myobrace` | null | 9 | 1 |
| `airway-monitoring` | `volumetric-airway-analysis` | 8 | 6 |
| `myobrace-myofunctional-protocol` / `-breathing-training` / `-for-adults` | null | 4 / 4 / 4 | 0 |
| `myobrace-treatment-journey` | null | 3 | 1 |
| `mouth-breathing-facial-development` | null | 2 | 2 |
| อื่นๆ อีก 6 หน้า (`pediatric-airway`, `adhd-airway-guide`, …) | ส่วนใหญ่ null | อย่างละ 1 | |

และยังมี planned link ที่**ต้นทาง**เป็นหน้า Merged อีก 79 link (`oral-appliance-therapy` 10, `pediatric-airway` 8, `pediatric-breathing` 8, `myofunctional-therapy-school-performance` 8, `airway-monitoring` 8, …) เป็นแถวที่ใช้ไม่ได้แล้ว เพราะหน้าต้นทางไม่มีอยู่

**สิ่งที่ขอ:**
1. link ที่ชี้ไปหน้า Merged ที่มี target แล้ว ให้เปลี่ยน `to_page_fp` ไปหน้าปลายทาง (`mad`, `volumetric-airway-analysis`) และลบแถวที่ซ้ำ
2. link ที่ชี้ไปหน้า Merged ที่ไม่มี target ให้เลือกปลายทางใหม่ หรือเปลี่ยน status เป็นอย่างอื่นที่ไม่ใช่ `planned`
3. link ที่มาจากหน้า Merged ให้ปิด (status ไม่ใช่ `planned`) หรือย้ายไปใส่ในหน้าปลายทาง

Kameie นับ link ทั้งหมดในข้อนี้เป็น Pending แล้ว (ไม่นับเป็น missing) จึงไม่รบกวนงาน webmaster แต่แผนจะสะอาดขึ้นถ้าแก้

### 2.4 Link ไปหน้าที่ยังไม่ได้สร้าง

- **หน้าพื้นฐานยังเป็น `Planned`:** มี planned link 48 ตัวรอหน้า `faq` (21), `glossary` (21), `contact` (4), `about` (2) ทั้ง 4 หน้ายังไม่ได้สร้าง
  - ตรวจว่า `contact` และ `about` มีอยู่บนเว็บจริงแล้วภายใต้ slug อื่นไหม (ถ้ามี ให้แก้ slug หรือสถานะใน page_master)
  - ส่วน `faq` / `glossary` ตั้งใจให้เป็นหน้ารวมจริง หรือควรชี้ไปหน้า FAQ ของแต่ละหัวข้อ เช่น `sleep-apnea-faq`
- **ภาพรวม:** มี link อีก 3,291 ตัวรอหน้าที่สถานะ Planned (รวมข้างบน) และ 1,604 ตัวรอให้หน้าต้นทางที่ยังเป็น Planned ขึ้นเว็บ เป็นงานตามแผนปกติ ไม่ใช่ปัญหา

### 2.5 Home page: link ในแผนยังขาด 31 ตัว

- **ที่เจอ:** หน้า `home` เป็นงาน "Add planned internal links" ที่ใหญ่ที่สุด มี link ในแผนที่ยังไม่อยู่บนหน้าจริง 31 ตัว ไปหน้าที่ Live แล้ว เช่น `/child-snoring-warning-signs`, `/choosing-a-night-guard`, `/chronic-tmj-pain-brain`, `/cpap-not-working-options`
- **สิ่งที่ขอ:** ตรวจว่าแผนตั้งใจให้หน้าแรกลิงก์ออกไปขนาดนี้จริงไหม ถ้าไม่ใช่ ให้ลด planned link ของหน้าแรกลง

## 3. ตรวจแล้ว ไม่ใช่ปัญหา

- **slug `de`, `en`, `zh` ฯลฯ ในข้อมูล crawler:** มาจากเมนูเปลี่ยนภาษา 9 ภาษา (ar, de, en, ja, ko, mn, my, ru, zh) อยู่ใน nav ของทั้ง 204 หน้า ทุกภาษาตอบ 200 และ `<html lang>` ถูกต้อง
  - หน้าแรกของแต่ละภาษาไม่ได้ลงทะเบียนใน page_master จึงขึ้นเป็น "unplanned" ใน Kameie (ไม่กระทบตัวเลข missing)
  - ข้อสังเกตเล็กๆ: `/de/` มี `<title>` แค่ "VTH BioDent" ควรเป็น title ภาษาเยอรมันที่บอกว่าหน้านี้เกี่ยวกับอะไร
- **link ในแผนที่หาหน้าต้นทางหรือปลายทางไม่เจอ:** ไม่มี planned link ของ VTH ที่หาหน้าไม่เจอเลย (6,787 แถว join ได้ครบ)

---

**ติดต่อกลับ:** แก้ข้อมูลแผนหรือ page_master เสร็จแล้ว แจ้ง session Kameie command center ได้ ตัวเลขใน Kameie จะอัปเดตเองหลังรอบ crawl คืนถัดไป (~23:00 UTC) และ refresh 00:40 UTC
