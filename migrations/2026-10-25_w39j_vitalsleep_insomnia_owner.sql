-- W39j · VitalSleep: insomnia page owner follows the 2026-10-25 rewrite (DRAFT, not applied) · 2026-10-25
-- Source: brand session "การเชื่อมต่อ WordPress" owner update 2026-10-25 (9 pages). Checked against page_master:
--   7 already match (นอนกรนอันตรายไหม, หยุดหายใจขณะหลับ อันตรายไหม, bipap คือ, ลูกนอนหายใจติดขัด, นอนกรน หยุดหายใจ,
--   หลับๆ ตื่นๆ = same keyword with spacing, หยุดหายใจขณะหลับ kept as the head over ภาวะหยุดหายใจขณะหลับ which is a variant
--   on the same page; cpap ยี่ห้อไหนดี kept, เครื่อง cpap ยี่ห้อไหนดี is the same intent on the same page).
--   1 change: insomnia-sleep-test-health นอนไม่หลับ → ทำยังไงให้นอนหลับ (its own semantic; the page is now a how-to and
--   this is its top striking query, 55 impr p19). นอนไม่หลับ stays on the page as content and goes back to the pool.
-- Run in the Supabase SQL editor as one transaction.

begin;

create table public.bak_w39j_20261025_vitalsleep as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic' and p.slug = 'insomnia-sleep-test-health'; -- 1 row expected

update public.seo_website_page_master
   set semantic_keywords_fps = array_remove(semantic_keywords_fps, 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ทำยังไงให้นอนหลับ'),
       target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ทำยังไงให้นอนหลับ',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39j-migration','decided_at','2026-10-25')
 where brand_id = 'vitalsleep-clinic' and slug = 'insomnia-sleep-test-health'
   and target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::นอนไม่หลับ'; -- 1 row

update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.brand = 'VitalSleep Clinic' and k.keyword in ('ทำยังไงให้นอนหลับ','นอนไม่หลับ')
   and k.keyword_use_as is distinct from 'excluded'; -- 2 rows

do $$
begin
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'insomnia-sleep-test-health'
                  and target_keyword_fp like '%::ทำยังไงให้นอนหลับ') then
    raise exception 'W39j: insomnia-sleep-test-health not retargeted';
  end if;
end $$;

commit;
