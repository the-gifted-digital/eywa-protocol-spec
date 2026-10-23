-- W39b · TC Smile owner-keyword moves from the W39 site triage (DRAFT, not applied) · 2026-10-23
-- Plan: repos/brands/eywa-tc-smile/content-plan/W39-quickwin-triage-2026-10-23.md §5
-- The merge survivor of each "cheap" cluster takes the keyword W38 bound to a page that is about to be merged into it.
--   1. รากฟันเทียมราคาถูก : dental-implant-cheap → implant-cheap-risk (222 impr / 28d, 5 top-10 queries; map survivor)
--   2. ทําวีเนียร์ราคาถูก : veneer-cheap-price → veneer-cheap-risk (366 impr p7.5 vs 157 impr p45; override of the map)
-- Each move unbinds the source first, then binds the survivor, so the no-reuse trigger never sees two holders.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39b_20261023_tcsmile_owner as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'tc-smile-dental'
   and p.slug in ('dental-implant-cheap','implant-cheap-risk','veneer-cheap-price','veneer-cheap-risk'); -- 4 rows expected

-- 1 · รากฟันเทียมราคาถูก
update public.seo_website_page_master
   set target_keyword_fp = null,
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('decided_by','w39b-migration','decided_at','2026-10-23','note','to be merged into implant-cheap-risk')
 where brand_id = 'tc-smile-dental' and slug = 'dental-implant-cheap'
   and target_keyword_fp = 'tc smile dental::🇹🇭 th – thailand::🇹🇭 th – thai::รากฟันเทียมราคาถูก'; -- 1 row

update public.seo_website_page_master
   set target_keyword_fp = 'tc smile dental::🇹🇭 th – thailand::🇹🇭 th – thai::รากฟันเทียมราคาถูก',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39b-migration','decided_at','2026-10-23')
 where brand_id = 'tc-smile-dental' and slug = 'implant-cheap-risk'
   and target_keyword_fp is null; -- 1 row

-- 2 · ทําวีเนียร์ราคาถูก
update public.seo_website_page_master
   set target_keyword_fp = null,
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('decided_by','w39b-migration','decided_at','2026-10-23','note','to be merged into veneer-cheap-risk')
 where brand_id = 'tc-smile-dental' and slug = 'veneer-cheap-price'
   and target_keyword_fp = 'tc smile dental::🇹🇭 th – thailand::🇹🇭 th – thai::ทําวีเนียร์ราคาถูก'; -- 1 row

update public.seo_website_page_master
   set target_keyword_fp = 'tc smile dental::🇹🇭 th – thailand::🇹🇭 th – thai::ทําวีเนียร์ราคาถูก',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39b-migration','decided_at','2026-10-23')
 where brand_id = 'tc-smile-dental' and slug = 'veneer-cheap-risk'
   and target_keyword_fp is null; -- 1 row

-- 3 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master
   where brand_id = 'tc-smile-dental'
     and ((slug = 'implant-cheap-risk' and target_keyword_fp like '%::รากฟันเทียมราคาถูก')
       or (slug = 'veneer-cheap-risk' and target_keyword_fp like '%::ทําวีเนียร์ราคาถูก')
       or (slug in ('dental-implant-cheap','veneer-cheap-price') and target_keyword_fp is null));
  if n <> 4 then raise exception 'W39b: expected 4 pages in final state, got %', n; end if;
end $$;

commit;
