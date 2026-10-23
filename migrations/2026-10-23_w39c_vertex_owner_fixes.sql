-- W39c · The Face by Vertex owner-keyword fixes from the W39 site triage (DRAFT, not applied) · 2026-10-23
-- Plan: repos/brands/eywa-vertex-clinic/reports/W39-quickwin-triage-2026-10-23.md §4
-- GSC 2026-09-21 → 10-20 (page × query) decides each owner:
--   1. รากฟันเทียม : dental-center/dental-implant-digital (no impressions for the query) → implant-dental-promotion (237 impr p11.6;
--      brand session already retitled it to รากฟันเทียม on 10-20). The promo page's old target ทํารากฟันเทียม ราคา is released.
--   2. วีเนียร์ swap: dental-center/veneer-teeth-dental ranks วีเนียร์คือ 114 impr p10 (retitled วีเนียร์ คือ on 10-19);
--      ceramic-composite-veneer ranks ทำวีเนียร์ 117 impr p6.8. Swap the two targets.
--   3. กรามค้าง (unheld; 1,260 impr p7.4 on jaw-look-how-to, now 301'd into tmj-locked-jaw) → tmj-locked-jaw,
--      replacing ขากรรไกรค้าง (same page, smaller variant).
-- Every move unbinds before it binds, so trg_page_keyword_no_reuse never sees two holders.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39c_20261023_vertex_owner as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'the-face-by-vertex'
   and p.slug in ('dental-center/dental-implant-digital','implant-dental-promotion','dental-center/veneer-teeth-dental','ceramic-composite-veneer','tmj-locked-jaw'); -- 5 rows expected

-- 1 · รากฟันเทียม
update public.seo_website_page_master
   set target_keyword_fp = null,
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('decided_by','w39c-migration','decided_at','2026-10-23','note','รากฟันเทียม moved to implant-dental-promotion; retarget or merge pending')
 where brand_id = 'the-face-by-vertex' and slug = 'dental-center/dental-implant-digital'
   and target_keyword_fp = 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::รากฟันเทียม'; -- 1 row

update public.seo_website_page_master
   set target_keyword_fp = 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::รากฟันเทียม',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39c-migration','decided_at','2026-10-23')
 where brand_id = 'the-face-by-vertex' and slug = 'implant-dental-promotion'
   and target_keyword_fp = 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::ทํารากฟันเทียม ราคา'; -- 1 row

-- 2 · วีเนียร์ swap (park both, then set both)
update public.seo_website_page_master
   set target_keyword_fp = null
 where brand_id = 'the-face-by-vertex'
   and ((slug = 'dental-center/veneer-teeth-dental' and target_keyword_fp = 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::ทำวีเนียร์')
     or (slug = 'ceramic-composite-veneer' and target_keyword_fp = 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::วีเนียร์ คือ')); -- 2 rows

update public.seo_website_page_master
   set target_keyword_fp = case slug when 'dental-center/veneer-teeth-dental' then 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::วีเนียร์ คือ'
                                     else 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::ทำวีเนียร์' end,
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39c-migration','decided_at','2026-10-23')
 where brand_id = 'the-face-by-vertex' and slug in ('dental-center/veneer-teeth-dental','ceramic-composite-veneer')
   and target_keyword_fp is null; -- 2 rows

-- 3 · กรามค้าง
update public.seo_website_page_master
   set target_keyword_fp = 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::กรามค้าง',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39c-migration','decided_at','2026-10-23')
 where brand_id = 'the-face-by-vertex' and slug = 'tmj-locked-jaw'
   and target_keyword_fp = 'the face by vertex::🇹🇭 th – thailand::🇹🇭 th – thai::ขากรรไกรค้าง'; -- 1 row

-- 4 · keyword_use_as for the touched keywords (excluded never overwritten)
update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.brand = 'The Face by Vertex'
   and k.keyword in ('รากฟันเทียม','ทํารากฟันเทียม ราคา','ทำวีเนียร์','วีเนียร์ คือ','กรามค้าง','ขากรรไกรค้าง')
   and k.keyword_use_as is distinct from 'excluded'; -- 6 rows

-- 5 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master
   where brand_id = 'the-face-by-vertex'
     and ((slug = 'implant-dental-promotion' and target_keyword_fp like '%::รากฟันเทียม')
       or (slug = 'dental-center/dental-implant-digital' and target_keyword_fp is null)
       or (slug = 'dental-center/veneer-teeth-dental' and target_keyword_fp like '%::วีเนียร์ คือ')
       or (slug = 'ceramic-composite-veneer' and target_keyword_fp like '%::ทำวีเนียร์')
       or (slug = 'tmj-locked-jaw' and target_keyword_fp like '%::กรามค้าง'));
  if n <> 5 then raise exception 'W39c: expected 5 pages in final state, got %', n; end if;
end $$;

commit;
