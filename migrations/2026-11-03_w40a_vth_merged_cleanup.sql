-- W40a · VTH BioDent: Merged pages without redirect_target + planned links that touch Merged pages (DRAFT, not applied) · 2026-11-03
-- Source: BROADCAST-2026-11-03-vth-link-data-audit.md §2.2–2.3. Run in the Supabase SQL editor as one transaction.
--
-- Findings (checked 2026-11-03):
--   * 81 vth-biodent rows status='Merged' with redirect_target null. curl https://vthbiodent.com/<slug> and /<slug>/:
--     80 → 404, 1 → 301 (pediatric-airway → /pediatric-snoring/). GSC sc-domain:vthbiodent.com 2025-07-01..2026-11-01:
--     0 impressions on all 81. No crawled live page links to any of them (seo_page_live_links).
--     → only pediatric-airway was ever live (written by accident, published_date 2026-08-12; see the "vth-5.6.9 defect" notes).
--   * The 80 never-live rows stay 'Merged', NOT 'Dropped':
--       - Schema §5.1: Merged = "folded into another page, row kept for provenance" — it says nothing about having been live.
--       - Every row records its survivor in reconciliation_notes ("MERGED … into vth-X" / "BLEND INTO vth-X") and most carry
--         flag_review='merged-blend-pending' — content still to be blended into the survivor. Dropped would lose that.
--       - The brand session already uses this convention: "หน้านี้ไม่เคยถูกเขียน ไม่มีไฟล์ จึงไม่ต้อง 301" (2026-10-27 rulings).
--       - redirect_target means "a 301 must exist": console.page_health_all checks every Merged row that has one and would raise
--         'Redirect missing' for 80 URLs that never existed. So null is correct for them.
--     Exception: pediatric-breathing (vth-5.6.15) has no merge note at all → survivor recorded here as pediatric-snoring (vth-5.6.8),
--     same child snoring/mouth-breathing intent as pediatric-airway.
--   * Planned links: the 54 in the broadcast = 38 from non-Merged sources + 16 whose source is also Merged (counted in the 79).
--     Convention of earlier cleanups (1,063 VTH rows): links that touch a Merged page get status 'deprecated'.
--
-- Changes:
--   1. pediatric-airway: redirect_target = 'pediatric-snoring' (VTH stores slugs, e.g. 'mad'). Matches the live 301.
--   2. Audit note appended to all 81 rows (pediatric-breathing also gets its survivor).
--   3. 79 planned links FROM a Merged page → deprecated (the page does not exist; its survivor already has its own plan).
--   4. 38 planned links from a non-Merged page TO a Merged page, survivor resolved through merge chains:
--        6 retargeted to the survivor:
--          myofunctional-breathing-therapy → guided-growth-orthodontics   (was myobrace)
--          oxygen-cognitive-performance    → guided-growth-orthodontics   (was myobrace)
--          home                            → adenoid-face                 (was mouth-breathing-facial-development)
--          home                            → adhd-airway                  (was adhd-airway-guide)
--          kids-dental-problems            → myofunctional-therapy-child-learning (was myofunctional-therapy-school-performance)
--          airway-sleep-optimization-program → frenectomy                 (was adult-tongue-tie-release)
--       30 deprecated: the source already has a planned/live link to the survivor (e.g. 8 of 9 Live → oral-appliance-therapy
--          sources already link to mad; all airway-monitoring sources already link to volumetric-airway-analysis)
--        2 deprecated: survivor = source (mad → oral-appliance-therapy, guided-growth-orthodontics → myobrace-treatment-journey)
--     Myobrace family (Ruling B 2026-10-01): myobrace, -myofunctional-protocol, -breathing-training, -for-adults,
--     -treatment-journey, -overview, -with-* all → vth-3.7.21.2 guided-growth-orthodontics.
--     Anchor text is kept; the Myobrace anchors still describe the guided-growth page.
--
-- Expected counts (vth-biodent)                                           before → after
--   page_master status='Merged' and redirect_target is null                    81 → 80
--   planned links whose source page is Merged                                  79 → 0
--   planned links from a non-Merged page to a Merged page                      38 → 0
--   planned links (all, by source brand)                                     6787 → 6676
--   deprecated links (all, by source brand)                                  1063 → 1174
-- Side effect in Kameie: 4 of the 6 retargets go from a Live page to a Live page, so they become 'missing' links and
-- join the K10a "Add planned internal links" tasks (home 31 → 33, myofunctional-breathing-therapy +1, kids-dental-problems +1).
-- Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w40a_20261103_vth_merged as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vth-biodent' and p.status = 'Merged' and p.redirect_target is null -- 81 rows
union all
select 'seo_page_internal_links', l.fingerprint, to_jsonb(l), now()
  from public.seo_page_internal_links l
  join public.seo_website_page_master s on s.page_fingerprint = l.from_page_fp and s.brand_id = 'vth-biodent'
  join public.seo_website_page_master t on t.page_fingerprint = l.to_page_fp
 where l.status = 'planned' and (s.status = 'Merged' or t.status = 'Merged'); -- 117 rows (198 total)

-- ── 1–2. page_master
update public.seo_website_page_master
   set redirect_target = 'pediatric-snoring'
 where brand_id = 'vth-biodent' and slug = 'pediatric-airway' and status = 'Merged' and redirect_target is null; -- 1 row

update public.seo_website_page_master
   set reconciliation_notes = coalesce(reconciliation_notes || E'\n', '') ||
       case slug
         when 'pediatric-airway' then 'AUDIT 2026-11-03 (W40a): was live (written by accident) · /pediatric-airway 301 → /pediatric-snoring/ · redirect_target set to pediatric-snoring.'
         when 'pediatric-breathing' then 'AUDIT 2026-11-03 (W40a): never live (404, GSC 0 impressions since 2025-07) · no merge target was recorded; survivor taken as vth-5.6.8 pediatric-snoring for link retargeting · no 301 needed.'
         else 'AUDIT 2026-11-03 (W40a): never live (404, GSC 0 impressions since 2025-07) · stays Merged with redirect_target null on purpose: no 301 needed.'
       end
 where brand_id = 'vth-biodent' and status = 'Merged'
   and page_fingerprint in (select fp from public.bak_w40a_20261103_vth_merged where src = 'seo_website_page_master'); -- 81 rows

-- ── 3. links from a Merged page
update public.seo_page_internal_links l
   set status = 'deprecated', updated_at = now()
  from public.seo_website_page_master s
 where s.page_fingerprint = l.from_page_fp and s.brand_id = 'vth-biodent' and s.status = 'Merged'
   and l.status = 'planned'; -- 79 rows

-- ── 4. links to a Merged page: survivor map (final non-Merged page after following merge chains)
create temp table w40a_map (old_fp text primary key, new_fp text not null) on commit drop;
insert into w40a_map (old_fp, new_fp) values
('vth-3.4.2.12',   'vth-3.4.2.2'),  -- oral-appliance-therapy → mad (redirect_target)
('vth-3.4.2.6',    'vth-3.5.2'),    -- airway-monitoring → volumetric-airway-analysis (redirect_target)
('vth-3.4.2.1',    'vth-3.5.2'),    -- airway-assessment-3d → volumetric-airway-analysis (redirect_target)
('vth-3.6.5',      'vth-3.7.21.2'), -- myobrace → guided-growth-orthodontics (Ruling B)
('vth-3.6.5.1',    'vth-3.7.21.2'), -- myobrace-myofunctional-protocol
('vth-3.6.5.2',    'vth-3.7.21.2'), -- myobrace-breathing-training
('vth-3.6.5.3',    'vth-3.7.21.2'), -- myobrace-for-adults
('vth-3.7.21.2.5', 'vth-3.7.21.2'), -- myobrace-treatment-journey
('vth-6.2.8.2',    'vth-5.6.13'),   -- mouth-breathing-facial-development → adenoid-face (Ruling C)
('vth-6.2.8.4',    'vth-5.6.23'),   -- adhd-airway-guide → adhd-airway
('vth-6.2.49',     'vth-5.6.23'),   -- school-performance-breathing → adhd-airway
('vth-6.2.52',     'vth-6.2.8.9'),  -- myofunctional-therapy-school-performance → myofunctional-therapy-child-learning
('vth-5.6.9',      'vth-5.6.8'),    -- pediatric-airway → pediatric-snoring (live 301)
('vth-5.6.15',     'vth-5.6.8'),    -- pediatric-breathing → pediatric-snoring (no recorded target, see header)
('vth-3.4.2.10',   'vth-3.7.8.3');  -- adult-tongue-tie-release → frenectomy

create temp table w40a_links on commit drop as
select l.id, l.from_page_fp, m.new_fp,
       m.new_fp = l.from_page_fp as is_self,
       exists (select 1 from public.seo_page_internal_links x
                where x.from_page_fp = l.from_page_fp and x.to_page_fp = m.new_fp and x.status in ('planned','live')) as has_existing,
       row_number() over (partition by l.from_page_fp, m.new_fp order by l.link_priority nulls last, l.created_at, l.id) as rn
  from public.seo_page_internal_links l
  join public.seo_website_page_master s on s.page_fingerprint = l.from_page_fp and s.brand_id = 'vth-biodent' and s.status <> 'Merged'
  join public.seo_website_page_master t on t.page_fingerprint = l.to_page_fp and t.status = 'Merged'
  left join w40a_map m on m.old_fp = l.to_page_fp
 where l.status = 'planned'; -- 38 rows

do $$ begin
  if exists (select 1 from w40a_links where new_fp is null) then
    raise exception 'W40a: planned link to a Merged page with no survivor in w40a_map — abort';
  end if;
end $$;

update public.seo_page_internal_links l
   set status = 'deprecated', updated_at = now()
  from w40a_links w
 where w.id = l.id and (w.is_self or w.has_existing or w.rn > 1); -- 32 rows

update public.seo_page_internal_links l
   set to_page_fp = w.new_fp, updated_at = now()
  from w40a_links w
 where w.id = l.id and not (w.is_self or w.has_existing or w.rn > 1); -- 6 rows

-- ── guard: nothing planned may still touch a Merged VTH page
do $$ begin
  if exists (select 1 from public.seo_page_internal_links l
               join public.seo_website_page_master s on s.page_fingerprint = l.from_page_fp and s.brand_id = 'vth-biodent'
               join public.seo_website_page_master t on t.page_fingerprint = l.to_page_fp
              where l.status = 'planned' and (s.status = 'Merged' or t.status = 'Merged')) then
    raise exception 'W40a: planned links still touch Merged pages — abort';
  end if;
end $$;

commit;

-- ── verify (read-only)
-- select count(*) from seo_website_page_master where brand_id = 'vth-biodent' and status = 'Merged' and redirect_target is null;  -- 80
-- select redirect_target from seo_website_page_master where brand_id = 'vth-biodent' and slug = 'pediatric-airway';             -- pediatric-snoring
-- select l.status, count(*) from seo_page_internal_links l join seo_website_page_master s on s.page_fingerprint = l.from_page_fp
--  where s.brand_id = 'vth-biodent' group by 1;                                                                                  -- planned 6676 · deprecated 1174
-- select count(*) from console.page_health_all where slug = 'pediatric-airway';  -- 1 (now checked; expect no redirect issue after next crawl)
--
-- ── rollback
-- update seo_website_page_master p set redirect_target = b.row_data->>'redirect_target', reconciliation_notes = b.row_data->>'reconciliation_notes'
--   from bak_w40a_20261103_vth_merged b where b.src = 'seo_website_page_master' and b.fp = p.page_fingerprint;
-- update seo_page_internal_links l set status = b.row_data->>'status', to_page_fp = b.row_data->>'to_page_fp', updated_at = now()
--   from bak_w40a_20261103_vth_merged b where b.src = 'seo_page_internal_links' and b.fp = l.fingerprint;
