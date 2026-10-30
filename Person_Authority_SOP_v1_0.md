# Person Authority SOP — v1.0 (universal)

> ขอบเขต: การสร้าง authority ระดับบุคคลให้แพทย์/ทันตแพทย์ที่ทำงานกับหลายแบรนด์ในเครือ EYWA โดยให้แบรนด์แข็งแรงไปพร้อมกัน
> Decision: **DR-083** · amends Bible **§10.5** (§10.5.1 ใหม่)
> Schema: `seo_authors_reviewers` · `seo_doctor_assignments` · `seo_reviewer_scope` · `seo_person_profiles` · `seo_referral_pathways` (Schema v1.30 — migration P1a)
> คู่กับ: [Entity_Identity_SOP_v1_0.md](Entity_Identity_SOP_v1_0.md) (one store per fact) · DR-021 (cross-brand links) · DR-076 (one intent = one URL)
> ใช้ครั้งแรก: ทพ.ดร. อมรพงษ์ วชิรมน (`auth_E964C7C14EED40E4`) — entity home `https://dr-amornpong.com/`

---

## 1. หลักการ

> **Authority ของคนมาจากความสม่ำเสมอของตัวตน ไม่ใช่จำนวนลิงก์**

1. **แพทย์คือ entity ที่เชื่อมแบรนด์ แบรนด์ไม่ได้เชื่อมกันเองด้วยลิงก์** — ทุกแบรนด์พูดถึงคนเดียวกัน ด้วยข้อมูลชุดเดียวกัน ในหัวข้อที่เขาเชี่ยวชาญจริง
2. **ทุกการปรากฏของชื่อแพทย์ต้องมีความจริงรองรับ** — บทบาทจริง (`seo_doctor_assignments`), การ review จริง (`seo_editorial_reviews` approved), ขอบเขตความเชี่ยวชาญจริง (`seo_reviewer_scope`)
3. **ไม่ใช่ PBN** — ลิงก์ข้ามแบรนด์เกิดเฉพาะจุดที่เนื้อหาพูดถึงการส่งต่อคนไข้จริง และต้องผูกกับ referral pathway
4. **แบรนด์เป็นเจ้าของ topic ของตัวเอง** — แพทย์คนเดียวกัน review ได้หลายแบรนด์ แต่หัวข้อหนึ่งมีแบรนด์เจ้าของเดียว (DR-076 ขยายข้ามโดเมนในเครือ)
5. **One store per fact** — `sameAs` อยู่ที่ `seo_person_profiles` ที่เดียว คุณวุฒิอยู่ที่ `seo_authors_reviewers` ที่เดียว ทุกเว็บดึงไปเรนเดอร์

## 2. Identity — canonical Person + node ต่อแบรนด์ (hybrid)

| ที่ | `@id` | หน้าที่ |
|---|---|---|
| Entity home (โดเมนของแพทย์) | `person_iri` เช่น `https://dr-amornpong.com/#person` | ตัวตนกลาง · `knowsAbout` ครบทุกสาขา · `sameAs` = ทุก URL ใน registry · `worksFor` = ทุกแบรนด์ที่ active |
| หน้าโปรไฟล์ในแบรนด์ | `${profile_url}#entity` (คงเดิมตาม §10.5) | บทบาทและ `worksFor` ของแบรนด์นั้น · `sameAs` **ต้องมี** entity home URL |
| บทความในแบรนด์ | `reviewedBy` → `@id` ของโปรไฟล์ในแบรนด์เดียวกัน | ไม่ชี้ข้ามโดเมน · `lastReviewed` = `completed_at` ของ review ที่ approved |

เส้นทางลิงก์ในแต่ละเว็บ: `บทความ → byline → หน้าโปรไฟล์ในเว็บนี้ → entity home`
Entity home ลิงก์กลับไปหน้าโปรไฟล์ของทุกแบรนด์ในบริบท "ออกตรวจที่ / บทบาท"

**ชื่อ:** ใช้ `seo_authors_reviewers.canonical_names` (th/en) ทุกที่ — `v_person_same_as.name_mismatches` ต้องเป็น 0 ก่อนเปิด `sameAs`

## 3. Reviewer scope — เกตก่อนแสดงชื่อ

| ระดับ | ความหมาย | ผลบนหน้า |
|---|---|---|
| `primary` | อยู่ในบอร์ด/การฝึกอบรม/ขอบเขตใบอนุญาต (`basis` บังคับ) | แสดง byline + `reviewedBy` ได้เมื่อ review approved |
| `co_review` | คาบเกี่ยวสาขาอื่น ต้องมี reviewer คนที่สอง (`co_reviewer_fp` บังคับ) | แสดงทั้งสองคน |
| `excluded` / ไม่มีแถว | นอกขอบเขต | **ห้าม**แสดงชื่อแพทย์และห้ามยิง `reviewedBy` |

- หน่วยของ scope คือ แพทย์ × แบรนด์ × cluster. cluster แบบผสม (เช่น `cross-cutting`) ตัดสินรายหน้า หรือ map หน้าเข้า cluster จริงก่อน
- หน้าโปรไฟล์แพทย์ไม่ใช้ `reviewedBy` (self-EEAT)
- เนื้อหาที่กล่าวอ้างผลเกินขอบเขตวิชาชีพ: **ปรับเนื้อหาให้อยู่ในขอบเขต** (แล้วเปลี่ยนเป็น `primary`) หรือหา co-reviewer — ไม่ขยาย scope ให้ตรงกับเนื้อหา
- เกต: `v_review_scope_violations` = 0 แถว สำหรับแพทย์ที่ `authority_program = 'active'`
- **ปริมาณต้องสมจริง** — จำนวน review ต่อเดือนต้องอยู่ในกำลังของแพทย์จริง review log เป็นหลักฐานเมื่อมีข้อร้องเรียน

## 4. sameAs registry (`seo_person_profiles`)

| `profile_type` | ตัวอย่าง | หมายเหตุ |
|---|---|---|
| `entity_home` | dr-amornpong.com | หนึ่งแถวต่อแพทย์ |
| `brand_profile` | หน้าแพทย์ในแต่ละแบรนด์ | ต้องมี `brand_id` |
| `license_registry` | หน้าทะเบียนทันตแพทยสภา/แพทยสภา | ตั้ง `medical_license_verified_at` เมื่อคนตรวจแล้วเท่านั้น |
| `professional_network` / `academic` | LinkedIn, ORCID, Google Scholar, PubMed | |
| `media` / `social` | บทสัมภาษณ์, YouTube | `include_in_same_as` เฉพาะที่เป็นตัวตนของแพทย์ ไม่ใช่บทความที่พูดถึง |

- URL ที่ตอบ 4xx/5xx หลุดจาก `sameAs` อัตโนมัติ (`last_http_status`)
- Wikidata: สร้างเมื่อมี notability ที่อ้างอิงได้จริงเท่านั้น (Entity_Identity_SOP สามด่าน)

## 5. ลิงก์ข้ามแบรนด์ (`seo_referral_pathways`)

1. เขียน pathway ก่อน: cluster ต้นทาง → ปลายทาง + เหตุผลทางคลินิก + แพทย์ผู้รับรอง (`status = approved`)
2. ลิงก์ที่ `is_cross_brand = true` ต้องมี `referral_pathway_fp` — `v_cross_brand_links_without_pathway` = 0
3. ลิงก์ไปหน้าที่ตอบเรื่องนั้นโดยตรง ไม่ใช่หน้าแรก · anchor บอกสิ่งที่คนไข้จะได้ · บอกผู้อ่านว่าเป็นคลินิกเครือข่าย
4. ไม่มี pathway = ไม่มีลิงก์ จำนวนลิงก์ไม่ใช่เป้าหมาย

## 6. วัดผล

| ฝั่ง | ตัวชี้วัด | ที่เก็บ |
|---|---|---|
| แพทย์ | branded search ของชื่อ (th/en/คำนำหน้า) | `seo_gsc_query_daily` + `seo_brand_query_terms` |
| แพทย์ | Knowledge Panel · branded SERP ที่ควบคุมได้ (เป้า 7–8/10) | ตรวจรายเดือน |
| แพทย์ | AI ตอบถูกไหมว่าแพทย์เชี่ยวชาญอะไร ทำงานที่ไหน | `seo_llm_query_simulations` / `seo_llm_citations` (`subject_author_fp`) |
| แพทย์ | การถูกกล่าวถึงนอกเว็บ | `seo_brand_mentions` (`subject_author_fp`, `brand_id` ว่างได้) |
| แบรนด์ | อันดับ topic ที่แบรนด์เป็นเจ้าของ ไม่มีเว็บในเครือแย่งกัน | `v_page_keyword_conflicts` |
| แบรนด์ | referral ตาม pathway · conversion จากหน้าโปรไฟล์แพทย์ | `tsa_bond` |

## 7. Compliance

- ข้อบังคับแพทยสภา/ทันตแพทยสภาเรื่องการโฆษณา: ไม่อวดอ้างเกินจริง ไม่ใช้ "ดีที่สุด/อันดับ 1" ไม่รับประกันผล — เช็กฉบับล่าสุดก่อนเขียน guideline
- การปรากฏชื่อแพทย์ในหลายแบรนด์ต้องเป็นเชิงวิชาการ/ให้ความรู้ ไม่ใช่การรับรองสินค้า
- PDPA: เคสและรูปก่อน-หลังต้องมี consent (`seo_media_assets` gate)
- Single point of failure: ระยะยาวทุก specialty ควรมี reviewer คนที่สอง

## 8. Onboarding checklist (ต่อแพทย์หนึ่งคน)

1. `seo_authors_reviewers`: `canonical_names`, คุณวุฒิ, board, `alumni_of`, `memberships`, `knows_about_entity_fps`
2. ตัดสิน entity home → `entity_home_url` + `person_iri`
3. `seo_doctor_assignments` ทุกแบรนด์ที่ active + `profile_url` + `display_title`
4. `seo_person_profiles` ทุก URL + `name_as_displayed`
5. `seo_reviewer_scope` จาก matrix ที่แพทย์ยืนยัน
6. `authority_program = 'active'` → เกตเริ่มทำงาน
7. แต่ละแบรนด์: ตรวจ `v_reviewed_flag_without_record` ของตัวเอง แก้ `reviewedBy` ให้มาจาก review ที่ approved เท่านั้น
8. แต่ละแบรนด์: เติม `sameAs` บนหน้าโปรไฟล์จาก `v_person_same_as`
9. เปิด entity home · ตั้ง prompt monitoring · เพิ่มชื่อแพทย์ใน `seo_brand_query_terms`
