-- W39k · VitalSleep: record 1 merge (DRAFT, not applied) · 2026-10-25
-- Source: brand session "การเชื่อมต่อ WordPress" push round 2026-10-25 (live: Yoast 301, post drafted; pulled forward from 11-04,
-- page had ~0 impressions). Same convention as W39e. Owners in the same round were checked and need no change:
-- how-and-where-to-stop-snoring-in-children = วิธีแก้ลูกนอนกรน (103 impr p7.2, best page for it), uvulopalatopharyngoplasty
-- keeps ลิ้นไก่ (2,396 impr p1.4 vs ผ่าตัดลิ้นไก่ 28 p4.6), snore-surgery-septum-nose keeps จมูกคด (284 p2 vs ผ่าตัดจมูกคด 101 p3).
-- Run in the Supabase SQL editor as one transaction.

begin;

create table public.bak_w39k_20261025_vitalsleep as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic' and p.slug = 'snoring-sleep-test-myofunctional-therapy'; -- 1 row expected

update public.seo_website_page_master
   set status = 'Merged',
       redirect_target = 'https://www.vitalsleepclinic.com/how-to-stop-snoring/',
       target_keyword_fp = null,
       semantic_keywords_fps = null,
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39 merge 2026-10-25 → /how-to-stop-snoring/'
 where brand_id = 'vitalsleep-clinic' and slug = 'snoring-sleep-test-myofunctional-therapy' and status = 'Live'; -- 1 row

update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.fingerprint in (select jsonb_array_elements_text(b.row_data->'semantic_keywords_fps') from public.bak_w39k_20261025_vitalsleep b where jsonb_typeof(b.row_data->'semantic_keywords_fps') = 'array'
                         union select b.row_data->>'target_keyword_fp' from public.bak_w39k_20261025_vitalsleep b where b.row_data->>'target_keyword_fp' is not null)
   and k.keyword_use_as is distinct from 'excluded';

do $$
begin
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'snoring-sleep-test-myofunctional-therapy'
                  and status = 'Merged' and redirect_target = 'https://www.vitalsleepclinic.com/how-to-stop-snoring/') then
    raise exception 'W39k: merge not recorded';
  end if;
end $$;

commit;
