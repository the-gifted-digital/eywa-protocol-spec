-- W39a · VitalSleep owner-keyword fixes from the W39 site triage (DRAFT, not applied) · 2026-10-23
-- Plan: repos/brands/eywa-vitalsleep-wellness/content/consolidation/W39-quickwin-triage-2026-10-23.md §5
-- 1. snoring-non-surgery takes "รักษานอนกรน" as target (it holds it as its own semantic; GSC 90d 8,382 impr, p5).
--    Its old target "แก้นอนกรน แบบไม่ผ่าตัด" is released.
-- 2. snoringclinc-osa loses the W38 target "รักษาโรคนอนกรน" (33 impr / 90d): hub page, no target.
-- 3. snoring-surgery takes "ผ่าตัดนอนกรน" (surgery overview owner, page to be rewritten); the keyword leaves
--    snore-surgery-septum-nose's semantic list first. W38 target "ผ่าตัดแก้กรน" is released.
-- Semantic lists are only reduced here (operator rule: a semantic that equals a target is removed); nothing is added.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39a_20261023_vitalsleep_owner as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic'
   and p.slug in ('snoring-treatment-cpap/snoring-non-surgery','snoringclinc-osa','snoring-treatment-cpap/snoring-surgery','snore-surgery-septum-nose'); -- 4 rows expected

-- 1 · snoring-non-surgery: semantic → target (both columns in one statement so the no-reuse trigger sees the final state)
update public.seo_website_page_master
   set semantic_keywords_fps = array_remove(semantic_keywords_fps, 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::รักษานอนกรน'),
       target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::รักษานอนกรน',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39a-migration','decided_at','2026-10-23')
 where brand_id = 'vitalsleep-clinic' and slug = 'snoring-treatment-cpap/snoring-non-surgery'
   and target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::แก้นอนกรน แบบไม่ผ่าตัด'; -- 1 row

-- 2 · snoringclinc-osa: revert W38
update public.seo_website_page_master
   set target_keyword_fp = null,
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('decided_by','w39a-migration','decided_at','2026-10-23','note','hub, no target (W38 reverted)')
 where brand_id = 'vitalsleep-clinic' and slug = 'snoringclinc-osa'
   and target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::รักษาโรคนอนกรน'; -- 1 row

-- 3a · free ผ่าตัดนอนกรน from the septum page's semantics
update public.seo_website_page_master
   set semantic_keywords_fps = array_remove(semantic_keywords_fps, 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ผ่าตัดนอนกรน')
 where brand_id = 'vitalsleep-clinic' and slug = 'snore-surgery-septum-nose'
   and 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ผ่าตัดนอนกรน' = any(semantic_keywords_fps); -- 1 row

-- 3b · snoring-surgery takes it
update public.seo_website_page_master
   set target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ผ่าตัดนอนกรน',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39a-migration','decided_at','2026-10-23','note','owner pending rewrite as surgery overview')
 where brand_id = 'vitalsleep-clinic' and slug = 'snoring-treatment-cpap/snoring-surgery'
   and target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ผ่าตัดแก้กรน'; -- 1 row

-- 4 · keyword_use_as for the 5 touched keywords (excluded never overwritten)
update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.brand = 'VitalSleep Clinic'
   and k.keyword in ('รักษานอนกรน','แก้นอนกรน แบบไม่ผ่าตัด','รักษาโรคนอนกรน','ผ่าตัดนอนกรน','ผ่าตัดแก้กรน')
   and k.keyword_use_as is distinct from 'excluded'; -- 5 rows

-- 5 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master
   where brand_id = 'vitalsleep-clinic'
     and ((slug = 'snoring-treatment-cpap/snoring-non-surgery' and target_keyword_fp like '%::รักษานอนกรน')
       or (slug = 'snoringclinc-osa' and target_keyword_fp is null)
       or (slug = 'snoring-treatment-cpap/snoring-surgery' and target_keyword_fp like '%::ผ่าตัดนอนกรน'));
  if n <> 3 then raise exception 'W39a: expected 3 pages in final state, got %', n; end if;
end $$;

commit;
