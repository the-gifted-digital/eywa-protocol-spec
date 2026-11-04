-- W39zz · VitalSleep: how-to-fall-asleep-fast Planned → Live (DRAFT, not applied) · 2026-11-03
-- Source: brand session "การเชื่อมต่อ WordPress": post 29255 published 2026-11-03 (live check 200 + H1 re-run here 2026-11-03).
-- Target วิธีนอนให้หลับเร็ว and the 11 citation bindings were set in W39y; only status and published_date change.
-- Run in the Supabase SQL editor as one transaction.

begin;

update public.seo_website_page_master
   set status = 'Live',
       published_date = '2026-11-03',
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39zz 2026-11-03: published (WP post 29255), Planned → Live'
 where brand_id = 'vitalsleep-clinic' and slug = 'how-to-fall-asleep-fast' and status = 'Planned'; -- 1 row

do $$
begin
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'how-to-fall-asleep-fast'
                  and status = 'Live' and target_keyword_fp like '%::วิธีนอนให้หลับเร็ว') then
    raise exception 'W39zz: page not Live';
  end if;
end $$;

commit;
