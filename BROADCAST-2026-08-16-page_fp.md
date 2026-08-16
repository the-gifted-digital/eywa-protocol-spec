# แจ้งทุกแบรนด์ — คีย์ผูกของตารางบริวารใช้ `page_fingerprint` เท่านั้น (L28)

ก๊อปข้อความข้างล่างส่งให้เซสชันของแต่ละแบรนด์ได้เลย

---

`seo_website_page_master` มีคีย์ 2 ตัวที่เรียกว่า "fingerprint" ได้ทั้งคู่ และตารางบริวารตั้งชื่อคอลัมน์ว่า `page_fp` เฉย ๆ ทำให้ใส่ผิดตัวได้ง่าย และ**ไม่มี FK จริงบังคับ ใส่ผิดแล้วแถวหลุดเงียบ** — หน้ายังอยู่ครบ ของที่ผูกยังอยู่ครบ แต่ join ไม่ติด หน้าจึงกลายเป็น "ไม่มีหลักฐาน" ทั้งที่ผูกไว้แล้ว

**ตัวที่ถูก:** `page_fingerprint` รูป `{brand_prefix}-{sitemap_node_id}` เช่น `vth-4.4.4` · `smilescape-3.13`
**ตัวที่ห้ามเอาไปผูก:** `fingerprint` รูป `page_{ULID16}` — ใช้เป็น identity ที่ไม่เปลี่ยนสำหรับ audit / อ้างข้ามเซสชันเท่านั้น

ใช้ `page_fingerprint` กับทุกจุดนี้: `seo_page_citations.page_fp` · `seo_editorial_reviews.page_fp` · `seo_page_internal_links.from_page_fp` / `to_page_fp` · `parent_page_fp` · `planned_outbound_fps`

⚠️ COMMENT ของคอลัมน์ `fingerprint` เขียนว่า *"IMMUTABLE machine ID … Do NOT treat page_fingerprint as stable identity; use fingerprint for that"* ซึ่งอ่านแล้วชวนให้เอาไปผูก — **อย่าทำตาม** ประโยคนั้นพูดถึงการอ้าง identity ไม่ใช่การ join · เหตุผลเชิงกลไก: §13.3 renumber ออกแบบให้ไล่อัปเดต 7 จุดที่ถือ `page_fingerprint` อยู่แล้ว ถ้าบางแถวแอบใช้ `fingerprint` มันจะรอด renumber ไปเงียบ ๆ แล้วโผล่เป็น orphan ทีหลัง

**รันเกตนี้ก่อนปิดงานทุกรอบ — ต้องได้ 0**

```sql
select 'citations' as tbl, pc.id, pc.page_fp, p.brand_id, p.page_fingerprint as should_be
from seo_page_citations pc
left join seo_website_page_master p on p.fingerprint = pc.page_fp
where not exists (select 1 from seo_website_page_master q where q.page_fingerprint = pc.page_fp)
union all
select 'reviews', r.id, r.page_fp, p.brand_id, p.page_fingerprint
from seo_editorial_reviews r
left join seo_website_page_master p on p.fingerprint = r.page_fp
where not exists (select 1 from seo_website_page_master q where q.page_fingerprint = r.page_fp);
```

**เจอแล้วให้เขียนคีย์ใหม่ ห้ามลบแถว** — ของที่ผูกไว้ถูกต้องอยู่แล้ว ผิดแค่รูปคีย์

```sql
update seo_page_citations pc
set page_fp = p.page_fingerprint, updated_at = now()
from seo_website_page_master p
where p.fingerprint = pc.page_fp
  and not exists (select 1 from seo_website_page_master q where q.page_fingerprint = pc.page_fp);
```

**สถานะตอนนี้ (2026-08-16):** ทั้งฐานสะอาดแล้ว — orphan 0 ทั้ง `seo_page_citations` และ `seo_editorial_reviews`
เซสชัน smile-scape ตรวจเจอและแก้ให้ **3 แถวของ vth-biodent** (หน้า `vth-4.4.4` NightLase) ที่สร้างวันเดียวกัน · backup อยู่ที่ `_xbrand_pagefp_fix_20260816`
**ฝาก vth-biodent เช็ก ETL/สคริปต์ที่สร้างแถวเหล่านั้นว่ายังหยิบ `fingerprint` มาใส่อยู่หรือเปล่า** ไม่งั้นรอบหน้าจะพลาดซ้ำ

สัดส่วนที่ยืนยันว่า `page_fingerprint` คือมาตรฐานที่ใช้จริง: `seo_page_citations` 6,306/6,309 · `seo_editorial_reviews` 2,095/2,095

อ้างอิง: `Keyword_Assignment_SOP_v1_0.md` บทเรียน **L28** · `Citation_Pool_SOP_v1_0.md` เกต **G12**
