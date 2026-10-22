-- W5a (handover data-quality #8, step 2): clear conflicting semantic keywords
-- Rule (operator decision 2026-10-22): one intent = one URL per brand.
--   * target_keyword_fp is already unique (uq_page_master_target_keyword_fp) -> untouched.
--   * A semantic keyword is REMOVED from every page that lists it when it
--       - sits on 2+ active pages of the same brand, or
--       - is any page's target keyword (incl. the page's own target), and
--     duplicates inside one array are collapsed.
--   * Merged/Dropped pages redirect away: their semantic lists are emptied.
-- Semantic lists are rebuilt later in a full re-allocation pass, under the
-- no-reuse trigger (W5b). Nothing is deleted: arrays are backed up first.
-- Dry run 2026-10-22: 807 keywords; entries deezy 1897->1631, smile-scape
-- 1052->215, vth 1291->455 (+89 on 24 Merged vth pages); vitalsleep unchanged.
-- Rollback:
--   update seo_website_page_master p set semantic_keywords_fps = b.semantic_keywords_fps
--   from bak_page_semantic_20261022 b where b.id = p.id;

create table if not exists public.bak_page_semantic_20261022 as
select id, page_fingerprint, brand_id, status, semantic_keywords_fps, now() as backed_up_at
from public.seo_website_page_master
where cardinality(coalesce(semantic_keywords_fps, '{}')) > 0;

alter table public.bak_page_semantic_20261022 enable row level security;

comment on table public.bak_page_semantic_20261022 is
  'Backup of semantic_keywords_fps before the W5a conflict cleanup (2026-10-22). Drop once the re-allocation pass is done.';

-- 1. Merged/Dropped pages hold no semantic keywords.
update public.seo_website_page_master
set semantic_keywords_fps = '{}'
where status in ('Merged', 'Dropped')
  and cardinality(coalesce(semantic_keywords_fps, '{}')) > 0;

-- 2. Active pages: drop reused and target-colliding keywords, collapse duplicates.
with uses as (
  select p.brand_id, p.id, s.fp
  from public.seo_website_page_master p
  cross join lateral unnest(p.semantic_keywords_fps) as s(fp)
  where p.status not in ('Merged', 'Dropped')
), bad as (
  select brand_id, fp from uses group by brand_id, fp having count(distinct id) > 1
  union
  select u.brand_id, u.fp
  from uses u
  join public.seo_website_page_master t on t.target_keyword_fp = u.fp
), cleaned as (
  select p.id,
         coalesce((
           select array_agg(x.fp order by x.first_pos)
           from (
             select s.fp, min(s.pos) as first_pos
             from unnest(p.semantic_keywords_fps) with ordinality as s(fp, pos)
             where not exists (select 1 from bad b where b.brand_id = p.brand_id and b.fp = s.fp)
             group by s.fp
           ) x
         ), '{}') as new_fps
  from public.seo_website_page_master p
  where p.status not in ('Merged', 'Dropped')
    and cardinality(coalesce(p.semantic_keywords_fps, '{}')) > 0
)
update public.seo_website_page_master p
set semantic_keywords_fps = c.new_fps
from cleaned c
where c.id = p.id
  and c.new_fps is distinct from p.semantic_keywords_fps;
