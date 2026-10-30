-- W39g · VitalSleep: 1 more merge + 2 owner changes from the brand session (DRAFT, not applied) · 2026-10-24
-- Source: brand session "การเชื่อมต่อ WordPress" (user-approved there),
--   repos/brands/eywa-vitalsleep-wellness/content/consolidation/keyword-session-handoff-2026-10-24.md
--   1. sleep-sleep-apnea-sunds → 301 to sleepdead-sleeptest-healthcare (live, one hop). Releases หลับไม่ตื่น (162 impr p4.2 / 60d).
--   2. antisnoringappliance : oral appliance → อุปกรณ์แก้นอนกรน (page ranks อุปกรณ์แก้นอนกรน 120 impr p7.3 and อุปกรณ์แก้กรน 83 p5;
--      oral appliance 208 p6.3 stays on the page as content, keyword released to the pool).
--   3. snoring-solutions-… (devices page) : แก้นอนกรน → เครื่องแก้นอนกรน (it was this page's own semantic; promoted).
--      แก้นอนกรน is released — it is the page's biggest query today (743 impr p7.7), so watch it at the next read.
-- ผ่าตัดนอนกรน → snoring-surgery and ใหลตาย → sleepdead are already in place (W39a, W39e). osa-brugada-syndrome-sads keeps
-- หัวใจหยุดเต้นขณะหลับ (spoke; no ไหลตาย head terms).
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39g_20261024_vitalsleep as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic'
   and p.slug in ('sleep-sleep-apnea-sunds','antisnoringappliance','snoring-solutions-anti-snoring-devices-products-for-snoring'); -- 3 rows expected

-- 1 · merge
update public.seo_website_page_master
   set status = 'Merged',
       redirect_target = 'https://www.vitalsleepclinic.com/sleepdead-sleeptest-healthcare/',
       target_keyword_fp = null,
       semantic_keywords_fps = null,
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39 merge 2026-10-24 → /sleepdead-sleeptest-healthcare/'
 where brand_id = 'vitalsleep-clinic' and slug = 'sleep-sleep-apnea-sunds' and status = 'Live'; -- 1 row

-- 2 · antisnoringappliance
update public.seo_website_page_master
   set target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::อุปกรณ์แก้นอนกรน',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39g-migration','decided_at','2026-10-24')
 where brand_id = 'vitalsleep-clinic' and slug = 'antisnoringappliance'
   and target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::oral appliance'; -- 1 row

-- 3 · devices page: own semantic → target (one statement, so the no-reuse trigger sees the final state)
update public.seo_website_page_master
   set semantic_keywords_fps = array_remove(semantic_keywords_fps, 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::เครื่องแก้นอนกรน'),
       target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::เครื่องแก้นอนกรน',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39g-migration','decided_at','2026-10-24','note','devices page refocus (W39 plan)')
 where brand_id = 'vitalsleep-clinic' and slug = 'snoring-solutions-anti-snoring-devices-products-for-snoring'
   and target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::แก้นอนกรน'; -- 1 row

-- 4 · keyword_use_as for every keyword the 3 pages held (excluded never overwritten)
update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where (k.fingerprint in (select b.row_data->>'target_keyword_fp' from public.bak_w39g_20261024_vitalsleep b where b.row_data->>'target_keyword_fp' is not null)
     or k.fingerprint in (select jsonb_array_elements_text(b.row_data->'semantic_keywords_fps') from public.bak_w39g_20261024_vitalsleep b where jsonb_typeof(b.row_data->'semantic_keywords_fps') = 'array')
     or k.fingerprint = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::อุปกรณ์แก้นอนกรน')
   and k.keyword_use_as is distinct from 'excluded';

-- 5 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master
   where brand_id = 'vitalsleep-clinic'
     and ((slug = 'sleep-sleep-apnea-sunds' and status = 'Merged' and target_keyword_fp is null)
       or (slug = 'antisnoringappliance' and target_keyword_fp like '%::อุปกรณ์แก้นอนกรน')
       or (slug = 'snoring-solutions-anti-snoring-devices-products-for-snoring' and target_keyword_fp like '%::เครื่องแก้นอนกรน'));
  if n <> 3 then raise exception 'W39g: expected 3 pages in final state, got %', n; end if;
end $$;

commit;
