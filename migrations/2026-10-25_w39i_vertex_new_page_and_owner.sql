-- W39i · The Face by Vertex: register the new forehead page + 1 owner change (DRAFT, not applied) · 2026-10-25
-- Source: brand session "แผนการปรับปรุง SEO Vertexclinic" (Wave 1c, doctor-reviewed, live 2026-10-25 00:00–00:15 ICT).
-- Proposed owners were checked against GSC page×query 2026-09-21→10-20 (DR-082: owner = what the page already ranks for):
--   1. NEW /forehead-shape-flat-narrow-high-hairline/ (post 17082) → page_master row, target หน้าผากแบน (new registry row;
--      no page owns it; today 48 impr p29 land on face-surgery/forehead-augmentation-surgery). หน้าผากเถิก = later semantic.
--   2. cheekbone-reduction-zygoma : วิธีลดโหนกแก้ม (44 impr p1.9) → โหนกแก้มสูง (108 impr p20.5; only this page ranks for it,
--      more demand, the Wave 1c sections target it). วิธีลดโหนกแก้ม stays on the page and goes back to the pool.
-- Proposals kept as they are in the DB (current target is what the page ranks for; proposal has little or no GSC):
--   facial-asymmetry-braces (จัดฟันคางเบี้ยว 38 p1.9 vs ขากรรไกรเบี้ยว ไม่ผ่าตัด ~5 impr) · square-face… (หน้าเหลี่ยม 186 p9.4 vs
--   หน้าบาน 26 p78) · v-line-chin… (วีไลน์ 373 p4.1 vs ศัลยกรรม วี ไลน์ 54 p6.6) · hairline-forehead-reduction (ตัดหน้าผาก 46 p7
--   vs หน้าผากแคบ 23 p15). Re-check at the 11-07/11-17 reads. ซิลิโคนจมูก, ถอนฟัน, วีเนียร์เซรามิก already match.
-- page_fingerprint follows the brand convention 'vtx-wp-' || left(md5(slug), 8).
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39i_20261025_vertex as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'the-face-by-vertex' and p.slug = 'cheekbone-reduction-zygoma'; -- 1 row expected

insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('The Face by Vertex::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::'||v.kw), v.kw, 'The Face by Vertex', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai', v.intent,
       'Added 2026-10-25 W39i owner fix from GSC query discovery (DR-076); no volume inferred.'
  from (values ('หน้าผากแบน','Informational'), ('โหนกแก้มสูง','Informational')) v(kw, intent)
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'The Face by Vertex' and kw_norm(k.keyword) = kw_norm(v.kw))
on conflict (fingerprint) do nothing; -- 2 rows

-- 1 · new page row
insert into public.seo_website_page_master (page_fingerprint, brand_id, brand_name, slug, canonical_url, status, page_type, page_language,
                                            target_keyword_fp, published_date, viability_assessment, reconciliation_notes)
select 'vtx-wp-' || left(md5('forehead-shape-flat-narrow-high-hairline'), 8), 'the-face-by-vertex', 'The Face by Vertex',
       'forehead-shape-flat-narrow-high-hairline', 'https://www.vertexclinic.com/forehead-shape-flat-narrow-high-hairline/',
       'Live', 'knowledge_article', 'th',
       'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::หน้าผากแบน', '2026-10-25',
       jsonb_build_object('kw_rule_version','1.0','keyword_source','brand_session','decided_by','w39i-migration','decided_at','2026-10-25'),
       'W39i 2026-10-25: new page (WP post 17082, facial contouring), created by brand session Wave 1c'
 where not exists (select 1 from public.seo_website_page_master p where p.brand_id = 'the-face-by-vertex' and p.slug = 'forehead-shape-flat-narrow-high-hairline'); -- 1 row

-- 2 · cheekbone-reduction-zygoma
update public.seo_website_page_master
   set target_keyword_fp = 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::โหนกแก้มสูง',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39i-migration','decided_at','2026-10-25')
 where brand_id = 'the-face-by-vertex' and slug = 'cheekbone-reduction-zygoma'
   and target_keyword_fp = 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::วิธีลดโหนกแก้ม'; -- 1 row

update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.brand = 'The Face by Vertex'
   and k.keyword in ('หน้าผากแบน','โหนกแก้มสูง','วิธีลดโหนกแก้ม')
   and k.keyword_use_as is distinct from 'excluded'; -- 3 rows

-- 3 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master
   where brand_id = 'the-face-by-vertex'
     and ((slug = 'forehead-shape-flat-narrow-high-hairline' and status = 'Live' and target_keyword_fp like '%::หน้าผากแบน')
       or (slug = 'cheekbone-reduction-zygoma' and target_keyword_fp like '%::โหนกแก้มสูง'));
  if n <> 2 then raise exception 'W39i: expected 2 pages in final state, got %', n; end if;
end $$;

commit;
