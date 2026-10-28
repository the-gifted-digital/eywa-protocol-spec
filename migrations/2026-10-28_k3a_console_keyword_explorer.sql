-- K3a · Kameie Phase 4: keyword explorer, query opportunities, entity planner, cannibalization (applied 2026-10-28) · 2026-10-28
-- The sources are security_invoker views (v_seo_keyword_pool, v_seo_entity_inventory) or heavy aggregates over
-- seo_gsc_query_daily (1.7M rows), so they are snapshotted into console MVs (owned by postgres, refreshed daily
-- after the GSC MVs) and exposed through console_api views filtered by console.readable_brands().
-- GSC window = the last 28 days of each brand's own data (same rule as K0c; freshness is out of scope).
-- Run in the Supabase SQL editor as one transaction.

begin;

-- ── 1. GSC queries, last 28d per brand (web), flagged against the brand's keyword pool
create materialized view console.mv_query_28d as
with last as (
  select brand_id, max(snapshot_date) as d from public.seo_gsc_query_daily group by 1
), q as (
  select q.brand_id, q.query_norm, min(q.query) as query,
         sum(q.clicks)::bigint as clicks, sum(q.impressions)::bigint as impressions,
         round(sum(q.position * q.impressions) / nullif(sum(q.impressions), 0), 1) as position,
         count(distinct q.page_slug)::int as pages,
         (array_agg(q.page_slug order by q.impressions desc))[1] as top_page_slug
    from public.seo_gsc_query_daily q
    join last l on l.brand_id = q.brand_id
   where q.search_type = 'web' and q.snapshot_date > l.d - 28 and q.query_norm is not null
   group by 1, 2
), pool as materialized (
  select distinct b.brand_slug, p.keyword_norm
    from public.v_seo_keyword_pool p
    join public.brands b on b.brand_name = p.brand
)
select q.*, k.keyword_norm is not null as in_pool
  from q left join pool k on k.brand_slug = q.brand_id and k.keyword_norm = q.query_norm;
create unique index on console.mv_query_28d (brand_id, query_norm);

-- ── 2. keyword pool per brand + its own GSC 28d (by normalized keyword)
create materialized view console.mv_keyword_pool as
select b.brand_slug, p.fingerprint as keyword_fp, p.keyword, p.keyword_norm, p.seo_active, p.keyword_use_as,
       p.search_intent, p.funnel_stage, p.primary_entity_fp, p.entity_name, p.entity_type, p.topic_cluster_id,
       p.volume, p.kd, p.cpc_avg, p.competition_index, p.trend_slope_12m_status as trend_12m,
       p.primary_of_nodes, p.primary_of_count, p.semantic_of_count, p.is_unused, p.is_price_intent,
       q.clicks as clicks_28d, q.impressions as impressions_28d, q.position as position_28d, q.top_page_slug
  from public.v_seo_keyword_pool p
  join public.brands b on b.brand_name = p.brand
  left join console.mv_query_28d q on q.brand_id = b.brand_slug and q.query_norm = p.keyword_norm;
create unique index on console.mv_keyword_pool (brand_slug, keyword_fp);

-- ── 3. entity planner (supply/page gaps, new-page candidates)
create materialized view console.mv_entity_plan as
select * from public.v_seo_entity_inventory;
create unique index on console.mv_entity_plan (brand_id, entity_fp);

-- ── 4. keyword cannibalization (same keyword targeted by several pages)
create materialized view console.mv_keyword_conflicts as
select * from public.v_page_keyword_conflicts;
create unique index on console.mv_keyword_conflicts (brand_id, keyword_fp);

create function console.refresh_explorer_mvs() returns void
language plpgsql security definer set search_path = '' as $$
begin
  refresh materialized view concurrently console.mv_query_28d;      -- before mv_keyword_pool (it joins this)
  refresh materialized view concurrently console.mv_keyword_pool;
  refresh materialized view concurrently console.mv_entity_plan;
  refresh materialized view concurrently console.mv_keyword_conflicts;
end $$;
revoke all on function console.refresh_explorer_mvs() from public, anon, authenticated;

select cron.schedule('kameie-refresh-explorer-mvs', '45 0 * * *', 'select console.refresh_explorer_mvs()');

-- ── read API
create view console_api.keywords as
select * from console.mv_keyword_pool where brand_slug in (select console.readable_brands());

create view console_api.query_opportunities as
select brand_id as brand_slug, query_norm, query, clicks, impressions, position, pages, top_page_slug, in_pool
  from console.mv_query_28d
 where brand_id in (select console.readable_brands());

create view console_api.entity_plan as
select brand_id as brand_slug, entity_fp, entity_name, entity_type, topic_cluster_id, pages, pages_without_primary,
       kw_total, kw_active, kw_free, vol_total, vol_free, vol_max, kw_missing_serp, top_free_keyword, top_free_volume,
       supply_gap, page_gap, undersupplied, new_page_candidate
  from console.mv_entity_plan
 where brand_id in (select console.readable_brands());

create view console_api.keyword_conflicts as
select brand_id as brand_slug, keyword_fp, keyword, page_count, conflict_type, suggested_owner_fp, pages
  from console.mv_keyword_conflicts
 where brand_id in (select console.readable_brands());

create view console_api.explorer_freshness as
select max(c.end_time) as refreshed_at
  from cron.job_run_details c join cron.job j on j.jobid = c.jobid
 where j.jobname = 'kameie-refresh-explorer-mvs' and c.status = 'succeeded';

revoke all on console_api.keywords, console_api.query_opportunities, console_api.entity_plan,
              console_api.keyword_conflicts, console_api.explorer_freshness from public, anon;
grant select on console_api.keywords, console_api.query_opportunities, console_api.entity_plan,
                console_api.keyword_conflicts, console_api.explorer_freshness to authenticated;

commit;

-- Verify (read-only, signed-in user):
-- select brand_slug, count(*) filter (where not in_pool and impressions >= 20) from console_api.query_opportunities group by 1;
--   (2026-10-28: vitalsleep-clinic 523, vth-biodent 5)
