-- W39u · VitalSleep: melatonin Planned → Live (DRAFT, not applied) · 2026-11-01
-- Source: brand session "การเชื่อมต่อ WordPress": post 29200 published 2026-11-01 (live check 200 re-run here 2026-11-01).
-- Target เมลาโทนิน and the 9 citation bindings were set in W39t; only status and published_date change.
-- Run in the Supabase SQL editor as one transaction.

begin;

update public.seo_website_page_master
   set status = 'Live',
       published_date = '2026-11-01',
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39u 2026-11-01: published (WP post 29200), Planned → Live'
 where brand_id = 'vitalsleep-clinic' and slug = 'melatonin' and status = 'Planned'; -- 1 row

do $$
begin
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'melatonin'
                  and status = 'Live' and target_keyword_fp like '%::เมลาโทนิน') then
    raise exception 'W39u: page not Live';
  end if;
end $$;

commit;
