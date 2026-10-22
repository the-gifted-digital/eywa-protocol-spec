-- W3.4-prep (DR-079 follow-ups)
-- 1. v_keyword_near_duplicates timed out: the trigram self-join over 22.7k Thai keywords takes ~45 s
--    even with the index, and it ran on every read. The pair finding moves into a materialized view
--    (mv_keyword_near_pairs); v_keyword_near_duplicates keeps its name and columns and joins the
--    pairs to the LIVE keyword and page tables, so keyword_use_as / page_a / page_b are always current.
--    Only the pairs go stale: refresh with  select refresh_keyword_near_pairs();  after keyword imports
--    (takes about a minute). refreshed_at on every row says when.
-- 2. v_page_keyword_orphans: seo_website_page_master holds keyword and entity fingerprints with no
--    foreign key (target_keyword_fp, semantic_keywords_fps, primary_entity_fp, related_entities_fps).
--    The view lists every reference that points at nothing, or at a Merged/Dropped entity. Expected: 0 rows.
--    (Suggested by the SEO-roadmap session, 2026-10-23.)

begin;

set local pg_trgm.similarity_threshold = 0.72;   -- lets the % operator prune with the index
set local statement_timeout = '10min';

drop view if exists public.v_keyword_near_duplicates;

create materialized view public.mv_keyword_near_pairs as
with entity_names as (
  select e.entity_fingerprint as entity_fp, seo_kw_norm(n) as name_norm
  from seo_entity_graph e
  cross join lateral unnest(seo_entity_name_list(e.entity_name, e.aliases)) n
  where lower(coalesce(e.entity_lifecycle, '')) not in ('merged', 'dropped')
), alias_hits as (
  select distinct k.brand, k.fingerprint, en.entity_fp
  from seo_x_ads_keywords_contextual_master k
  join entity_names en on en.name_norm = seo_kw_norm(k.keyword)
), pairs as (
  select a.brand, a.fingerprint as kw_a, b.fingerprint as kw_b, 'trigram'::text as reason, null::text as entity_fp
  from seo_x_ads_keywords_contextual_master a
  join seo_x_ads_keywords_contextual_master b
    on a.brand = b.brand and a.fingerprint < b.fingerprint and a.keyword % b.keyword
  where similarity(a.keyword, b.keyword) > 0.72
  union all
  select a.brand, a.fingerprint, b.fingerprint, 'entity_alias', a.entity_fp
  from alias_hits a
  join alias_hits b on a.brand = b.brand and a.entity_fp = b.entity_fp and a.fingerprint < b.fingerprint
)
select brand, kw_a, kw_b,
       string_agg(distinct reason, '+') as match_reason,
       max(entity_fp) as entity_fp,
       now() as refreshed_at
from pairs
group by brand, kw_a, kw_b;

create unique index uq_mv_keyword_near_pairs on public.mv_keyword_near_pairs (brand, kw_a, kw_b);

create view public.v_keyword_near_duplicates as
select g.brand,
       g.kw_a,
       a.keyword as keyword_a,
       a.keyword_use_as as use_a,
       g.kw_b,
       b.keyword as keyword_b,
       b.keyword_use_as as use_b,
       round(similarity(a.keyword, b.keyword)::numeric, 3) as kw_similarity,
       (select p.sitemap_node_id from seo_website_page_master p where p.target_keyword_fp = g.kw_a) as page_a,
       (select p.sitemap_node_id from seo_website_page_master p where p.target_keyword_fp = g.kw_b) as page_b,
       g.match_reason,
       g.entity_fp,
       g.refreshed_at
from mv_keyword_near_pairs g
join seo_x_ads_keywords_contextual_master a on a.fingerprint = g.kw_a
join seo_x_ads_keywords_contextual_master b on b.fingerprint = g.kw_b;

comment on view public.v_keyword_near_duplicates is
  'Keyword pairs per brand that are near-duplicates by spelling (trigram > 0.72) and/or name the same entity (entity_alias). Pairs come from mv_keyword_near_pairs (see refreshed_at; refresh with refresh_keyword_near_pairs()); keyword/page columns are live.';

create or replace function public.refresh_keyword_near_pairs()
returns void
language plpgsql
set pg_trgm.similarity_threshold = 0.72
set statement_timeout = '10min'
as $$
begin
  refresh materialized view concurrently public.mv_keyword_near_pairs;
end;
$$;

comment on function public.refresh_keyword_near_pairs() is
  'Rebuilds mv_keyword_near_pairs (~1 min). Run after keyword imports or alias edits.';

-- Found by the first run of the view: 8 smile-scape pages carry a NULL element inside
-- related_entities_fps. Removed here so the view starts at 0.
update public.seo_website_page_master
set related_entities_fps = array_remove(related_entities_fps, null)
where array_position(related_entities_fps, null) is not null;

-- Merged/Dropped pages are redirects and are skipped (5 of them still point at Dropped entities; harmless).
create view public.v_page_keyword_orphans as
with live as (
  select * from seo_website_page_master where status not in ('Merged', 'Dropped')
), refs as (
  select p.brand_id, p.page_fingerprint, p.slug, p.status, 'target_keyword_fp'::text as col, p.target_keyword_fp as fp
  from live p where p.target_keyword_fp is not null
  union all
  select p.brand_id, p.page_fingerprint, p.slug, p.status, 'semantic_keywords_fps', s.fp
  from live p cross join lateral unnest(p.semantic_keywords_fps) s(fp)
  union all
  select p.brand_id, p.page_fingerprint, p.slug, p.status, 'primary_entity_fp', p.primary_entity_fp
  from live p where p.primary_entity_fp is not null
  union all
  select p.brand_id, p.page_fingerprint, p.slug, p.status, 'related_entities_fps', r.fp
  from live p cross join lateral unnest(p.related_entities_fps) r(fp)
)
select r.brand_id, r.page_fingerprint, r.slug, r.status, r.col, r.fp,
       case
         when r.fp is null then 'null_in_array'
         when r.col in ('target_keyword_fp', 'semantic_keywords_fps') then 'keyword_missing'
         when g.entity_fingerprint is null then 'entity_missing'
         else 'entity_' || lower(g.entity_lifecycle)
       end as problem
from refs r
left join seo_entity_graph g on g.entity_fingerprint = r.fp and r.col in ('primary_entity_fp', 'related_entities_fps')
where r.fp is null
   or (r.col in ('target_keyword_fp', 'semantic_keywords_fps')
       and not exists (select 1 from seo_x_ads_keywords_contextual_master k where k.fingerprint = r.fp))
   or (r.col in ('primary_entity_fp', 'related_entities_fps')
       and (g.entity_fingerprint is null or lower(coalesce(g.entity_lifecycle, '')) in ('merged', 'dropped')));

comment on view public.v_page_keyword_orphans is
  'Page-master references (keyword or entity fingerprints, no FK) that point at nothing or at a Merged/Dropped entity. Expected 0 rows. 2026-10-23.';

commit;
