-- W39s · VitalSleep: sleep-cycle-sleep-schedule Planned → Live (DRAFT, not applied) · 2026-11-01
-- Source: brand session "การเชื่อมต่อ WordPress": post 29194 published 2026-11-01 (live check 200 re-run here 2026-11-01).
-- Target ตาราง นอน was set in W39p and the 7 citation bindings in W39r; only status and published_date change.
-- Run in the Supabase SQL editor as one transaction.

begin;

update public.seo_website_page_master
   set status = 'Live',
       published_date = '2026-11-01',
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39s 2026-11-01: published (WP post 29194), Planned → Live'
 where brand_id = 'vitalsleep-clinic' and slug = 'sleep-cycle-sleep-schedule' and status = 'Planned'; -- 1 row

do $$
begin
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'sleep-cycle-sleep-schedule'
                  and status = 'Live' and target_keyword_fp like '%::ตาราง นอน') then
    raise exception 'W39s: page not Live';
  end if;
end $$;

commit;
