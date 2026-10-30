-- W39n · VitalSleep: record 1 merge (DRAFT, not applied) · 2026-10-25
-- Source: brand session "การเชื่อมต่อ WordPress" follow-up batch 2026-10-25 (live: 301 checked → /myofuction-therapy/, post drafted).
-- clinic-snore-therapy (26386, myofunctional content, old "2024" title) → myofuction-therapy. Releases คลินิกนอนกรนใกล้ฉัน
-- (21 impr p9.3 here vs home 21 p6.3; home already holds คลินิกนอนกรน as a semantic, so ใกล้ฉัน is a home seed for the semantic round).
-- Same batch, no DB change: antisnoringappliance keeps อุปกรณ์แก้นอนกรน; the ฟันยางกันกรน family is queued as its semantics (~11-10).
-- Same convention as W39e. Run in the Supabase SQL editor as one transaction.

begin;

create table public.bak_w39n_20261025_vitalsleep as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic' and p.slug = 'clinic-snore-therapy'; -- 1 row expected

update public.seo_website_page_master
   set status = 'Merged',
       redirect_target = 'https://www.vitalsleepclinic.com/myofuction-therapy/',
       target_keyword_fp = null,
       semantic_keywords_fps = null,
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39 merge 2026-10-25 → /myofuction-therapy/'
 where brand_id = 'vitalsleep-clinic' and slug = 'clinic-snore-therapy' and status = 'Live'; -- 1 row

update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.fingerprint in (select jsonb_array_elements_text(b.row_data->'semantic_keywords_fps') from public.bak_w39n_20261025_vitalsleep b where jsonb_typeof(b.row_data->'semantic_keywords_fps') = 'array'
                         union select b.row_data->>'target_keyword_fp' from public.bak_w39n_20261025_vitalsleep b where b.row_data->>'target_keyword_fp' is not null)
   and k.keyword_use_as is distinct from 'excluded';

do $$
begin
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'clinic-snore-therapy'
                  and status = 'Merged' and redirect_target = 'https://www.vitalsleepclinic.com/myofuction-therapy/') then
    raise exception 'W39n: merge not recorded';
  end if;
end $$;

commit;
