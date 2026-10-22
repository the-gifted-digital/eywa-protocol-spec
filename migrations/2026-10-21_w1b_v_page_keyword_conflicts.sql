-- W1b (handover data-quality #8, step 1): v_page_keyword_conflicts
-- Rule: one intent = one URL. Per brand, a keyword may be the target OR a
-- semantic keyword of exactly one page. Only the target is enforced today
-- (uq_page_master_target_keyword_fp); semantic_keywords_fps is unchecked.
-- One row per (brand, keyword) found on 2+ active pages, or listed as a page's
-- own target AND in its own semantic list. Merged/Dropped pages are ignored
-- (they redirect away). GSC clicks/impressions are for that keyword on that
-- page (28d), to pick the owner. Read-only; cleanup is step 2, trigger step 3.

create or replace view public.v_page_keyword_conflicts as
with uses as (
  select p.brand_id, p.page_fingerprint, p.slug, p.status, p.page_type,
         p.target_keyword_fp as keyword_fp, 'target'::text as role
  from seo_website_page_master p
  where p.target_keyword_fp is not null
    and p.status not in ('Merged', 'Dropped')
  union all
  select p.brand_id, p.page_fingerprint, p.slug, p.status, p.page_type,
         s.fp, 'semantic'
  from seo_website_page_master p
  cross join lateral unnest(p.semantic_keywords_fps) as s(fp)
  where p.status not in ('Merged', 'Dropped')
), gsc as (
  select q.brand_id, q.page_slug, q.query_norm,
         sum(q.clicks) as clicks, sum(q.impressions) as impressions
  from seo_gsc_query_daily q
  where q.search_type = 'web'
    and q.snapshot_date >= current_date - 28
  group by q.brand_id, q.page_slug, q.query_norm
), enriched as (
  select u.*, km.keyword,
         coalesce(g.clicks, 0) as gsc_clicks_28d,
         coalesce(g.impressions, 0) as gsc_impressions_28d
  from uses u
  left join seo_x_ads_keywords_contextual_master km on km.fingerprint = u.keyword_fp
  left join gsc g on g.brand_id = u.brand_id and g.page_slug = u.slug
                 and g.query_norm = seo_kw_norm(km.keyword)
)
select e.brand_id,
       e.keyword_fp,
       max(e.keyword) as keyword,
       count(distinct e.page_fingerprint) as page_count,
       case
         when count(distinct e.page_fingerprint) = 1 and bool_or(e.role = 'target') then 'own_target_in_own_semantic'
         when count(distinct e.page_fingerprint) = 1 then 'duplicate_in_semantic_list'
         when bool_or(e.role = 'target') then 'target_vs_semantic'
         else 'semantic_reuse'
       end as conflict_type,
       -- suggested owner: most GSC clicks, then impressions, then the target page
       (array_agg(e.page_fingerprint order by e.gsc_clicks_28d desc,
                  e.gsc_impressions_28d desc, (e.role = 'target') desc))[1] as suggested_owner_fp,
       jsonb_agg(jsonb_build_object(
         'page_fp', e.page_fingerprint, 'slug', e.slug, 'status', e.status,
         'page_type', e.page_type, 'role', e.role,
         'gsc_clicks_28d', e.gsc_clicks_28d, 'gsc_impressions_28d', e.gsc_impressions_28d)
         order by e.gsc_clicks_28d desc, e.gsc_impressions_28d desc) as pages
from enriched e
group by e.brand_id, e.keyword_fp
having count(*) > 1;

comment on view public.v_page_keyword_conflicts is
  'Keywords used on 2+ active pages per brand (target or semantic), or a page''s own target repeated in its semantic list. conflict_type target_vs_semantic = direct cannibalization, fix first. Handover data-quality #8, 2026-10-21.';
