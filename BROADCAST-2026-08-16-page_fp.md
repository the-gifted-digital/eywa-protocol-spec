# 🔴 แจ้งทุกแบรนด์ — `seo_website_page_master` มี FK จริงแล้วตั้งแต่ 2026-08-16 (L28)

ก๊อปข้อความข้างล่างส่งให้เซสชันของแต่ละแบรนด์ได้เลย · **เรื่องนี้เปลี่ยนพฤติกรรม ETL ต้องอ่านก่อนรันรอบต่อไป**

---

## สิ่งที่เปลี่ยน

เดิมตารางบริวารผูก `seo_website_page_master` แบบ **soft FK** — ไม่มีอะไรบังคับ ใส่คีย์ผิดตัวแล้ว**หลุดเงียบ** หน้ายังอยู่ ของที่ผูกยังอยู่ แต่ join ไม่ติด หน้าจึงกลายเป็น "ไม่มีหลักฐาน" ทั้งที่ผูกไว้แล้ว

**ตอนนี้เป็น FK จริง 7 ตัว** ใส่ผิดจะ **error ทันที** ไม่หลุดเงียบอีก

| ตาราง / คอลัมน์ | ON UPDATE | ON DELETE |
|---|---|---|
| `seo_page_citations.page_fp` | CASCADE | CASCADE |
| `seo_editorial_reviews.page_fp` | CASCADE | CASCADE |
| `seo_page_internal_links.from_page_fp` | CASCADE | CASCADE |
| `seo_page_internal_links.to_page_fp` | CASCADE | CASCADE |
| `seo_website_page_master.parent_page_fp` (self) | CASCADE | **SET NULL** |
| `seo_x_ads_keywords_contextual_master.ad_landing_page_fp` | CASCADE | **SET NULL** |
| `seo_x_voice_search.optimized_for_page_fp` | CASCADE | **SET NULL** |

`ON DELETE` ต่างกันตามความหมาย: **CASCADE** = แถวลูกแท้ ๆ ไม่มีความหมายถ้าหน้าหาย · **SET NULL** = แถวที่มีชีวิตของตัวเอง หน้าหายก็ยังอยู่
⚠️ `parent_page_fp` เป็น SET NULL **โดยตั้งใจ ห้ามเปลี่ยนเป็น CASCADE** — ไม่งั้นลบหน้า hub เดียวจะลบลูกหลานทั้งกิ่ง

## คีย์ที่ถูก

**ใช้ `page_fingerprint`** รูป `{brand_prefix}-{sitemap_node_id}` เช่น `vth-4.4.4` · `smilescape-3.13`
**ห้ามใช้ `fingerprint`** รูป `page_{ULID16}` — ตัวนั้นไว้อ้าง identity ที่ไม่เปลี่ยน (audit / ข้ามเซสชัน) เท่านั้น

⚠️ COMMENT เดิมของ `fingerprint` เขียนว่า *"IMMUTABLE machine ID … Do NOT treat page_fingerprint as stable identity; use fingerprint for that"* ซึ่งอ่านแล้วชวนให้เอาไปผูก — **ประโยคนั้นพูดถึงการอ้าง identity ไม่ใช่การ join** · แก้ COMMENT ให้ชัดแล้ว

## 2 อย่างที่ ETL ต้องเช็กก่อนรันรอบต่อไป

1. **ลำดับการเขียน** — ต้อง insert หน้าใน `seo_website_page_master` **ก่อน** insert citation / review / link ของหน้านั้น · ถ้า ETL เดิมเขียนสลับลำดับ รอบหน้าจะ error (`foreign_key_violation`) ตรงจุดนั้นทันที · **นี่คือเรื่องดี** ของที่เคยหลุดเงียบจะโผล่มาให้เห็น แต่ต้องรู้ล่วงหน้าว่าจะเจอ
2. **หยิบคอลัมน์ไหนมาใส่** — ถ้าโค้ดหยิบ `fingerprint` มาใส่ `page_fp` จะ error ทันที · เช็กว่าใช้ `page_fingerprint` อยู่

## ผลพลอยได้ที่ดีกับ renumber (§13.3)

`ON UPDATE CASCADE` ทำให้เขียน `page_fingerprint` ที่เดียว **บริวารตามเองทั้งหมด** — ขั้นตอน renumber 7 จุดยุบเหลือไล่มือเฉพาะ **`planned_outbound_fps`** ตัวเดียว (เป็น `text[]` Postgres ทำ FK กับสมาชิกใน array ไม่ได้)

ยังต้องทำ 2-phase (`zzz-<new>` ก่อน) เหมือนเดิม เพราะ `page_fingerprint` เป็น UNIQUE

ทดสอบแล้วบนของจริง: renumber หน้าที่มี citation → บริวารย้ายตามครบ · ยอดแถวไม่ขยับ (6,309 / 2,095 / 16,564) · ใส่คีย์ผิดตัวถูกปฏิเสธด้วย `foreign_key_violation`

## เกตที่ยังต้องรัน

FK กันของใหม่ได้ แต่ **`planned_outbound_fps` ไม่มี FK** ต้องเช็กเอง

```sql
select p.brand_id, p.page_fingerprint, f as dangling_target
from seo_website_page_master p, unnest(p.planned_outbound_fps) f
where not exists (select 1 from seo_website_page_master q where q.page_fingerprint = f);
```

## สถานะตอนนี้

ทั้งฐานสะอาด orphan **0** ทุกคอลัมน์ก่อนใส่ FK · เซสชัน smile-scape แก้ให้ **3 แถวของ vth-biodent** (หน้า `vth-4.4.4` NightLase ผูกด้วย `page_942B5270A0314DAB`) — backup `_xbrand_pagefp_fix_20260816`
และแก้ `ad_landing_page_fp` ของ smile-scape 2 แถวที่ชี้หน้าที่ถูกยุบไปแล้ว

**ฝาก vth-biodent เช็ก ETL/สคริปต์ที่สร้าง 3 แถวนั้น** ว่ายังหยิบ `fingerprint` มาใส่อยู่หรือเปล่า — รอบหน้าจะ error แทนที่จะหลุดเงียบ

อ้างอิง: `Keyword_Assignment_SOP_v1_0.md` **L28** · `Citation_Pool_SOP_v1_0.md` เกต **G12** · migration `add_real_fks_to_page_master`
