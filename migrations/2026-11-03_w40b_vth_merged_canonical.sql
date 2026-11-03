-- W40b · VTH BioDent: point canonical_url of 4 Merged pages at their live 301 target · 2026-11-03
-- The 301s are live (vthbiodent.com commit 8655304, plus the older pediatric-airway 301); canonical_url still held the
-- old slug. Convention of the other Merged rows: canonical_url = https://vthbiodent.com/<redirect_target>/.
-- Run in the Supabase SQL editor. Expect 4 rows updated.

begin;

update public.seo_website_page_master
   set canonical_url = 'https://vthbiodent.com/' || redirect_target || '/'
 where brand_id = 'vth-biodent' and status = 'Merged'
   and page_fingerprint in ('vth-3.4.2.1', 'vth-3.4.2.6', 'vth-3.4.2.12', 'vth-5.6.9')
   and redirect_target is not null; -- 4 rows

do $$ begin
  if exists (select 1 from public.seo_website_page_master
              where brand_id = 'vth-biodent' and status = 'Merged' and redirect_target is not null
                and canonical_url is distinct from 'https://vthbiodent.com/' || redirect_target || '/') then
    raise exception 'W40b: a Merged vth row still has canonical_url not equal to its redirect target — abort';
  end if;
end $$;

commit;

-- verify (read-only)
-- select page_fingerprint, canonical_url from seo_website_page_master
--  where page_fingerprint in ('vth-3.4.2.1','vth-3.4.2.6','vth-3.4.2.12','vth-5.6.9');
-- expected: .../volumetric-airway-analysis/ (x2), .../mad/, .../pediatric-snoring/
