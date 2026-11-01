-- W39w · VitalSleep: bmi-calculator-snoring Planned → Live (DRAFT, not applied) · 2026-11-01
-- Source: brand session "การเชื่อมต่อ WordPress": post 29204 published 2026-11-01 (live check 200 + H1 re-run here 2026-11-01).
-- Target คำนวณ bmi and the 7 citation bindings were set in W39v; only status and published_date change.
-- Run in the Supabase SQL editor as one transaction.

begin;

update public.seo_website_page_master
   set status = 'Live',
       published_date = '2026-11-01',
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39w 2026-11-01: published (WP post 29204), Planned → Live'
 where brand_id = 'vitalsleep-clinic' and slug = 'bmi-calculator-snoring' and status = 'Planned'; -- 1 row

do $$
begin
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'bmi-calculator-snoring'
                  and status = 'Live' and target_keyword_fp like '%::คำนวณ bmi') then
    raise exception 'W39w: page not Live';
  end if;
end $$;

commit;
