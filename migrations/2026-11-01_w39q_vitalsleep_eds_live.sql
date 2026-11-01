-- W39q · VitalSleep: excessive-daytime-sleepiness Planned → Live (DRAFT, not applied) · 2026-11-01
-- Source: brand session "การเชื่อมต่อ WordPress": post 29184 published 2026-11-01 (live check 200 re-run here 2026-11-01).
-- Target ง่วงนอนตลอดเวลา and the 4 citation bindings were set in W39p; only status and published_date change.
-- Run in the Supabase SQL editor as one transaction.

begin;

update public.seo_website_page_master
   set status = 'Live',
       published_date = '2026-11-01',
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39q 2026-11-01: published (WP post 29184), Planned → Live'
 where brand_id = 'vitalsleep-clinic' and slug = 'excessive-daytime-sleepiness' and status = 'Planned'; -- 1 row

do $$
begin
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'excessive-daytime-sleepiness'
                  and status = 'Live' and target_keyword_fp like '%::ง่วงนอนตลอดเวลา') then
    raise exception 'W39q: page not Live';
  end if;
end $$;

commit;
