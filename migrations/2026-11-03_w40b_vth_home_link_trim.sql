-- W40b · VTH BioDent: trim home's planned outbound links to its direct children (DRAFT, not applied) · 2026-11-03
-- Source: BROADCAST-2026-11-03-vth-link-data-audit.md §2.5. OPTIONAL — run only after the VTH brand session agrees,
-- and only after W40a (W40a retargets two home links that this file then trims).
--
-- Findings (2026-11-03): home (vth-1) has 140 planned outbound links. The live homepage (curl https://vthbiodent.com/)
-- links to 35 URLs in total: nav + footer + 9 language switchers + a handful of hubs. Of the 38 planned links to Live pages,
-- 7 are on the page and 31 are not. 26 of those 31 are leaf articles or near-me pages (e.g. child-snoring-warning-signs,
-- choosing-a-night-guard, tmj-and-stress, scaling-near-me) whose parent is a section hub, not home. 52 more planned links
-- go to leaf pages that are not built yet. A homepage that links to ~140 pages dilutes every link on it and is not how
-- the live site is built; the hub-and-spoke rule is home → section hubs → leaves.
-- Recommendation: keep home → its direct children (parent_page_fp = 'vth-1') and smile-makeover (already on the page);
-- deprecate the rest. Leaves keep their inbound links from their own hubs.
--
-- Kept (60): 11 Live children (core-programs, jaw-pain, mbm, precision-clinical-dentistry, precision-diagnostics,
--   team/dr-amornpong on the page; fotona-lightwalker, kids-dental-problems, myofunctional-breathing-therapy, oral-health,
--   sleep-airway still to add), 48 Planned children (about, contact, faq, glossary, locations, pricing, …), smile-makeover.
--
-- Expected counts (after W40a)                                            before → after
--   home planned outbound links                                              140 → 60
--   home planned links to Live pages that are missing on the page              33 → 5
--   home planned links to non-child pages                                     81 → 1 (smile-makeover)
-- Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w40b_20261103_vth_home_links as
select l.fingerprint as fp, to_jsonb(l) as row_data, now() as backed_up_at
  from public.seo_page_internal_links l
  join public.seo_website_page_master t on t.page_fingerprint = l.to_page_fp
 where l.from_page_fp = 'vth-1' and l.status = 'planned'
   and t.parent_page_fp is distinct from 'vth-1' and t.slug <> 'smile-makeover'; -- 80 rows

update public.seo_page_internal_links l
   set status = 'deprecated', updated_at = now()
  from public.bak_w40b_20261103_vth_home_links b
 where b.fp = l.fingerprint; -- 80 rows

commit;

-- ── verify (read-only)
-- select count(*) from seo_page_internal_links where from_page_fp = 'vth-1' and status = 'planned';  -- 60
--
-- ── rollback
-- update seo_page_internal_links l set status = 'planned', updated_at = now()
--   from bak_w40b_20261103_vth_home_links b where b.fp = l.fingerprint;
