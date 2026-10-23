-- W39d · Clearisma owner-keyword fixes from the W39 site triage (DRAFT, not applied) · 2026-10-23
-- Plan: repos/brands/eywa-clearisma/reports/W39-quickwin-triage-2026-10-23.md §4
-- Clinic-finder cluster ("ที่ไหนดี"):
--   1. clear-aligner-bkk : จัดฟันใส กรุงเทพ → จัดฟันใส ที่ไหนดี (brand session retitled the live page to this on 10-20)
--   2. where-aligner-good : release จัดฟันแบบ clear aligner ที่ไหนดี (same intent; page is to be merged into clear-aligner-bkk)
--   3. clinic-bangkok-dental (no target, W38 cannibal) : จัดฟันที่ไหนดี (general orthodontics; GSC 76 impr p8, page 384 impr / 28d)
-- New keywords come from GSC query discovery, using the registry fingerprint convention.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39d_20261023_clearisma_owner as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'clearisma'
   and p.slug in ('clear-aligner-bkk','where-aligner-good','clinic-bangkok-dental'); -- 3 rows expected

insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('Clearisma::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::'||v.kw), v.kw, 'Clearisma', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai', 'Commercial',
       'Added 2026-10-23 W39d owner fix from GSC query discovery (DR-076); no volume inferred.'
  from (values ('จัดฟันใส ที่ไหนดี'), ('จัดฟันที่ไหนดี')) v(kw)
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'Clearisma' and kw_norm(k.keyword) = kw_norm(v.kw))
on conflict (fingerprint) do nothing; -- 2 rows

-- 1+2 · release where-aligner-good first, then retarget clear-aligner-bkk
update public.seo_website_page_master
   set target_keyword_fp = null,
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('decided_by','w39d-migration','decided_at','2026-10-23','note','to be merged into clear-aligner-bkk')
 where brand_id = 'clearisma' and slug = 'where-aligner-good'
   and target_keyword_fp = 'clearisma::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันแบบ clear aligner ที่ไหนดี'; -- 1 row

update public.seo_website_page_master
   set target_keyword_fp = 'clearisma::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันใส ที่ไหนดี',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39d-migration','decided_at','2026-10-23')
 where brand_id = 'clearisma' and slug = 'clear-aligner-bkk'
   and target_keyword_fp = 'clearisma::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันใส กรุงเทพ'; -- 1 row

-- 3 · clinic-bangkok-dental
update public.seo_website_page_master
   set target_keyword_fp = 'clearisma::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันที่ไหนดี',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39d-migration','decided_at','2026-10-23')
 where brand_id = 'clearisma' and slug = 'clinic-bangkok-dental'
   and target_keyword_fp is null; -- 1 row

-- 4 · keyword_use_as (excluded never overwritten)
update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.brand = 'Clearisma'
   and k.keyword in ('จัดฟันใส ที่ไหนดี','จัดฟันที่ไหนดี','จัดฟันใส กรุงเทพ','จัดฟันแบบ clear aligner ที่ไหนดี')
   and k.keyword_use_as is distinct from 'excluded'; -- 4 rows

-- 5 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master
   where brand_id = 'clearisma'
     and ((slug = 'clear-aligner-bkk' and target_keyword_fp like '%::จัดฟันใส ที่ไหนดี')
       or (slug = 'clinic-bangkok-dental' and target_keyword_fp like '%::จัดฟันที่ไหนดี')
       or (slug = 'where-aligner-good' and target_keyword_fp is null));
  if n <> 3 then raise exception 'W39d: expected 3 pages in final state, got %', n; end if;
end $$;

commit;
