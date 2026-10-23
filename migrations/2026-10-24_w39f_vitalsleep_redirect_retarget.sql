-- W39f · VitalSleep: two merged slugs now 301 to the causes pillar (DRAFT, not applied) · 2026-10-24
-- Source: brand session "การเชื่อมต่อ WordPress", user-approved there 2026-10-24. Reason: SERP snapshot 2026-10-24
-- (vitalsleepclinic.com-audit/serp-snapshot-2026-10-24.md) shows Google still ranking these old URLs for the head terms
-- นอนกรน (#4) and สาเหตุการนอนกรน (#6), which belong to /sleep-snoring-treatment/ (rewritten as the causes pillar).
-- W39e has already run; this only changes redirect_target. Run in the Supabase SQL editor.

begin;

update public.seo_website_page_master
   set redirect_target = 'https://www.vitalsleepclinic.com/sleep-snoring-treatment/',
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39f 2026-10-24: 301 re-pointed to causes pillar /sleep-snoring-treatment/'
 where brand_id = 'vitalsleep-clinic' and status = 'Merged'
   and ((slug = 'snoring-disease-sleep' and redirect_target = 'https://www.vitalsleepclinic.com/sleep-apnea-inap-snoring/')
     or (slug = 'congenital-disease-snoring-sleep' and redirect_target = 'https://www.vitalsleepclinic.com/snoring-sleep-health/')); -- 2 rows

do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master
   where brand_id = 'vitalsleep-clinic' and slug in ('snoring-disease-sleep','congenital-disease-snoring-sleep')
     and redirect_target = 'https://www.vitalsleepclinic.com/sleep-snoring-treatment/';
  if n <> 2 then raise exception 'W39f: expected 2 re-pointed rows, got %', n; end if;
end $$;

commit;
