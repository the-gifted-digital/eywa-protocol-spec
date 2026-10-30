-- W39h · VitalSleep: 1 re-pointed 301 + 1 owner change from the brand session (DRAFT, not applied) · 2026-10-24
-- Source: brand session "การเชื่อมต่อ WordPress" (user-approved there).
--   1. update-snoring-treatment-2021 now 301s to /antisnoringappliance/ (owner of อุปกรณ์แก้นอนกรน since W39g; the old URL
--      still ranks อุปกรณ์แก้นอนกรน 104 impr p5.8). Was → devices page.
--   2. osa-brugada-syndrome-sads (25396, rewritten): target หัวใจหยุดเต้นขณะหลับ → หยุดหายใจขณะหลับ อันตรายไหม (new registry row,
--      GSC query discovery). หัวใจหยุดเต้นขณะหลับ stays on the page as content and goes back to the pool for the semantic round.
--      sleep-apnea-inap-snoring keeps หยุดหายใจขณะหลับ; sleepdead keeps ใหลตาย.
-- home-sleep-test-osa-snoring already holds นอนกรน หยุดหายใจ — no change.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39h_20261024_vitalsleep as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic'
   and p.slug in ('update-snoring-treatment-2021','osa-brugada-syndrome-sads'); -- 2 rows expected

-- 1 · re-point the merged slug
update public.seo_website_page_master
   set redirect_target = 'https://www.vitalsleepclinic.com/antisnoringappliance/',
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39h 2026-10-24: 301 re-pointed to /antisnoringappliance/'
 where brand_id = 'vitalsleep-clinic' and slug = 'update-snoring-treatment-2021' and status = 'Merged'
   and redirect_target = 'https://www.vitalsleepclinic.com/snoring-solutions-anti-snoring-devices-products-for-snoring/'; -- 1 row

-- 2 · new keyword + owner
insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::หยุดหายใจขณะหลับ อันตรายไหม'), 'หยุดหายใจขณะหลับ อันตรายไหม', 'VitalSleep Clinic',
       '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai', 'Informational',
       'Added 2026-10-24 W39h owner fix from GSC query discovery (DR-076); no volume inferred.'
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k
                    where k.brand = 'VitalSleep Clinic' and kw_norm(k.keyword) = kw_norm('หยุดหายใจขณะหลับ อันตรายไหม'))
on conflict (fingerprint) do nothing; -- 1 row

update public.seo_website_page_master
   set target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::หยุดหายใจขณะหลับ อันตรายไหม',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39h-migration','decided_at','2026-10-24','note','spoke of OSA + ใหลตาย; rewritten by brand session')
 where brand_id = 'vitalsleep-clinic' and slug = 'osa-brugada-syndrome-sads'
   and target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::หัวใจหยุดเต้นขณะหลับ'; -- 1 row

update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.brand = 'VitalSleep Clinic'
   and k.keyword in ('หยุดหายใจขณะหลับ อันตรายไหม','หัวใจหยุดเต้นขณะหลับ')
   and k.keyword_use_as is distinct from 'excluded'; -- 2 rows

-- 3 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master
   where brand_id = 'vitalsleep-clinic'
     and ((slug = 'update-snoring-treatment-2021' and redirect_target = 'https://www.vitalsleepclinic.com/antisnoringappliance/')
       or (slug = 'osa-brugada-syndrome-sads' and target_keyword_fp like '%::หยุดหายใจขณะหลับ อันตรายไหม'));
  if n <> 2 then raise exception 'W39h: expected 2 rows in final state, got %', n; end if;
end $$;

commit;
