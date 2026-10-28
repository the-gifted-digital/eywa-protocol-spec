-- K5a · Kameie Phase 6: brand Overview (Semrush-style rank distribution, movers) + Plan vs Result (applied 2026-10-28) · 2026-10-28
-- Sources already loaded daily outside Kameie:
--   public.seo_x_ads_keywords_x_url_daily_logs  tracked keyword x URL, one row per keyword per day (rank, GSC, GA4 page metrics)
--   public.seo_gsc_query_daily                  every GSC query x page per day
--   public.seo_website_page_master              the plan (status, cluster, entity, category, tier, parent, target keyword)
--   public.tsa_product_map                      cluster -> product line (config only, no PII)
-- Heavy aggregates are console MVs refreshed nightly; console_api views filter by console.readable_brands().
-- Windows are relative to each brand's own latest data day (freshness is handled outside Kameie).
-- URL -> slug follows seo_gsc_query_daily.page_slug: path without leading/trailing '/', site root = 'home'.
-- Run in the Supabase SQL editor as one transaction.

begin;

create function console.url_slug(p_url text) returns text
language sql immutable set search_path = '' as $$
  select coalesce(nullif(regexp_replace(regexp_replace(p_url, '^https?://[^/]+', ''), '^/+|/+$', '', 'g'), ''), 'home')
$$;

-- ── 1. rank distribution per brand per day, two lenses
--   tracked: keywords in the pool (daily logs, GSC position of the keyword)
--   gsc:     every query GSC reports (best position of the query that day)
create materialized view console.mv_rank_dist_daily as
with logs as (
  select b.brand_slug, l.snapshot_at::date as day, l.ranking as pos
    from public.seo_x_ads_keywords_x_url_daily_logs l
    join public.brands b on b.brand_name = l.brand
   where l.snapshot_at > now() - interval '200 days'
), q as (
  select brand_id as brand_slug, snapshot_date as day, query_norm, min(position) as pos
    from public.seo_gsc_query_daily
   where search_type = 'web' and snapshot_date > current_date - 200 and query_norm is not null
   group by 1, 2, 3
), u as (
  select 'tracked'::text as lens, brand_slug, day, pos from logs
  union all
  select 'gsc', brand_slug, day, pos from q
)
select lens, brand_slug, day,
       count(*) filter (where pos <= 3)               as b1_3,
       count(*) filter (where pos > 3  and pos <= 10) as b4_10,
       count(*) filter (where pos > 10 and pos <= 20) as b11_20,
       count(*) filter (where pos > 20 and pos <= 40) as b21_40,
       count(*) filter (where pos > 40 and pos <= 100) as b41_100,
       count(*) filter (where pos is not null)        as ranked,
       count(*)                                       as total
  from u
 group by 1, 2, 3;
create unique index on console.mv_rank_dist_daily (brand_slug, lens, day);

-- ── 2. tracked keyword: rank now vs ~28 days earlier (movers, target-keyword rank in the plan)
create materialized view console.mv_keyword_rank_28d as
with l as (
  select b.brand_slug, l.fingerprint, l.keyword, l.snapshot_at::date as day, l.ranking,
         console.url_slug(l.gsc_actual_ranking_url) as page_slug
    from public.seo_x_ads_keywords_x_url_daily_logs l
    join public.brands b on b.brand_name = l.brand
   where l.snapshot_at > now() - interval '120 days'
), last as (
  select brand_slug, max(day) as d from l group by 1
), now_ as (
  select distinct on (l.brand_slug, l.fingerprint) l.brand_slug, l.fingerprint, l.keyword, l.day, l.ranking, l.page_slug
    from l join last on last.brand_slug = l.brand_slug
   where l.day > last.d - 7
   order by l.brand_slug, l.fingerprint, l.day desc
), prev as (
  select distinct on (l.brand_slug, l.fingerprint) l.brand_slug, l.fingerprint, l.day, l.ranking
    from l join last on last.brand_slug = l.brand_slug
   where l.day <= last.d - 28 and l.day > last.d - 42
   order by l.brand_slug, l.fingerprint, l.day desc
)
select n.brand_slug, n.fingerprint as keyword_fp, n.keyword, n.page_slug,
       n.ranking as rank_now, n.day as day_now, p.ranking as rank_prev, p.day as day_prev
  from now_ n left join prev p on p.brand_slug = n.brand_slug and p.fingerprint = n.fingerprint;
create unique index on console.mv_keyword_rank_28d (brand_slug, keyword_fp);

-- ── 3. GSC queries per page, last 28 days
create materialized view console.mv_page_query_28d as
with last as (
  select brand_id, max(snapshot_date) as d from public.seo_gsc_query_daily group by 1
)
select q.brand_id as brand_slug, q.page_slug, q.query_norm, min(q.query) as query,
       sum(q.clicks)::bigint as clicks, sum(q.impressions)::bigint as impressions,
       round(sum(q.position * q.impressions) / nullif(sum(q.impressions), 0), 1) as position
  from public.seo_gsc_query_daily q join last on last.brand_id = q.brand_id
 where q.search_type = 'web' and q.snapshot_date > last.d - 28 and q.query_norm is not null and q.page_slug is not null
 group by 1, 2, 3;
create unique index on console.mv_page_query_28d (brand_slug, page_slug, query_norm);

-- ── 4. GA4 per page, last 28d vs previous 28d (page-level metrics repeat on every keyword row: take max per url per day)
create materialized view console.mv_page_ga4_28d as
with d as (
  select b.brand_slug, console.url_slug(l.gsc_actual_ranking_url) as page_slug, l.snapshot_at::date as day,
         max(l.ga4_organic_sessions) as org, max(l.ga4_total_sessions) as tot,
         max(l.ga4_organic_key_event) as kev, max(l.ga4_organic_engagement_rate) as eng
    from public.seo_x_ads_keywords_x_url_daily_logs l
    join public.brands b on b.brand_name = l.brand
   where l.snapshot_at > now() - interval '90 days' and l.gsc_actual_ranking_url is not null
   group by 1, 2, 3
), last as (select brand_slug, max(day) as d from d group by 1)
select d.brand_slug, d.page_slug,
       sum(d.org) filter (where d.day > last.d - 28)                      as organic_sessions_28d,
       sum(d.org) filter (where d.day <= last.d - 28 and d.day > last.d - 56) as organic_sessions_prev_28d,
       sum(d.tot) filter (where d.day > last.d - 28)                      as total_sessions_28d,
       sum(d.kev) filter (where d.day > last.d - 28)                      as organic_key_events_28d,
       round(avg(d.eng) filter (where d.day > last.d - 28), 3)           as organic_engagement_rate,
       last.d as last_day
  from d join last on last.brand_slug = d.brand_slug
 group by d.brand_slug, d.page_slug, last.d;
create unique index on console.mv_page_ga4_28d (brand_slug, page_slug);

create function console.refresh_plan_mvs() returns void
language plpgsql security definer set search_path = '' as $$
begin
  refresh materialized view concurrently console.mv_rank_dist_daily;
  refresh materialized view concurrently console.mv_keyword_rank_28d;
  refresh materialized view concurrently console.mv_page_query_28d;
  refresh materialized view concurrently console.mv_page_ga4_28d;
end $$;
revoke all on function console.refresh_plan_mvs() from public, anon, authenticated;
select cron.schedule('kameie-refresh-plan-mvs', '50 0 * * *', 'select console.refresh_plan_mvs()');

-- ── read API
create view console_api.rank_distribution as
select brand_slug, lens, day, b1_3, b4_10, b11_20, b21_40, b41_100, ranked, total
  from console.mv_rank_dist_daily
 where brand_slug in (select console.readable_brands());

create view console_api.keyword_movers as
select r.brand_slug, r.keyword_fp, r.keyword, r.page_slug, r.rank_now, r.day_now, r.rank_prev, r.day_prev,
       r.rank_prev - r.rank_now as delta,            -- positive = moved up
       k.volume, k.search_intent, k.entity_name
  from console.mv_keyword_rank_28d r
  left join console.mv_keyword_pool k on k.brand_slug = r.brand_slug and k.keyword_fp = r.keyword_fp
 where r.brand_slug in (select console.readable_brands());

-- daily rank history of one tracked keyword (filter keyword_fp=eq.… in the client; indexed on fingerprint)
create view console_api.keyword_rank_history as
select b.brand_slug, l.fingerprint as keyword_fp, l.snapshot_at::date as day, l.ranking,
       l.gsc_clicks as clicks, l.gsc_impressions as impressions, console.url_slug(l.gsc_actual_ranking_url) as page_slug
  from public.seo_x_ads_keywords_x_url_daily_logs l
  join public.brands b on b.brand_name = l.brand
 where b.brand_slug in (select console.readable_brands())
   and l.snapshot_at > now() - interval '180 days';

-- the plan, every page (Planned / Live / Merged), with its results
create view console_api.plan_pages as
with pg as (
  select p.*, coalesce(nullif(p.slug, ''), 'home') as slug_n
    from public.seo_website_page_master p
   where p.brand_id in (select console.readable_brands())
), qb as (
  select brand_slug, page_slug, count(*) as queries,
         count(*) filter (where position <= 3) as q1_3, count(*) filter (where position > 3 and position <= 10) as q4_10,
         count(*) filter (where position > 10 and position <= 20) as q11_20, count(*) filter (where position > 20) as q21p
    from console.mv_page_query_28d
   where brand_slug in (select console.readable_brands())
   group by 1, 2
)
select pg.fingerprint as page_fp, pg.page_fingerprint as page_code, pg.brand_id as brand_slug, pg.slug, pg.page_name,
       pg.status, pg.page_category, pg.page_type, pg.node_tier, pg.page_role, pg.funnel_stage, pg.priority,
       pg.parent_page_fp as parent_code, pg.cluster_id, coalesce(c.cluster_name, pg.cluster_id) as cluster_name,
       pm.product_line, pg.primary_entity_fp, pg.primary_entity_name, pg.published_date,
       pg.target_keyword_fp, split_part(pg.target_keyword_fp, '::', 4) as target_keyword,
       coalesce(cardinality(pg.semantic_keywords_fps), 0) as semantic_kw_count,
       kp.volume as target_volume, kr.rank_now as target_rank, kr.rank_prev as target_rank_prev,
       kr.page_slug as target_ranking_slug,
       g.clicks_28d, g.clicks_prev_28d, g.impressions_28d, g.impressions_prev_28d, g.position_28d,
       qb.queries, qb.q1_3, qb.q4_10, qb.q11_20, qb.q21p,
       ga.organic_sessions_28d, ga.organic_sessions_prev_28d, ga.organic_key_events_28d, ga.organic_engagement_rate,
       h.issues
  from pg
  left join public.seo_topic_cluster_master c on c.cluster_slug = pg.cluster_id
  left join public.tsa_product_map pm on pm.brand_id = pg.brand_id and pm.cluster_id = pg.cluster_id
  left join console.mv_keyword_pool kp on kp.brand_slug = pg.brand_id and kp.keyword_fp = pg.target_keyword_fp
  left join console.mv_keyword_rank_28d kr on kr.brand_slug = pg.brand_id and kr.keyword_fp = pg.target_keyword_fp
  left join console.mv_page_gsc_28d g on g.brand_id = pg.brand_id and g.page_slug = pg.slug_n
  left join qb on qb.brand_slug = pg.brand_id and qb.page_slug = pg.slug_n
  left join console.mv_page_ga4_28d ga on ga.brand_slug = pg.brand_id and ga.page_slug = pg.slug_n
  left join console.page_health_all h on h.page_fp = pg.fingerprint;

-- GSC queries landing on one page (filter brand_slug + page_slug in the client); in_plan = the page's target/semantic keyword
create view console_api.page_queries as
select q.brand_slug, q.page_slug, q.query_norm, q.query, q.clicks, q.impressions, q.position,
       exists (
         select 1
           from public.seo_website_page_master p
           join console.mv_keyword_pool k on k.brand_slug = p.brand_id
            and (k.keyword_fp = p.target_keyword_fp or k.keyword_fp = any (p.semantic_keywords_fps))
          where p.brand_id = q.brand_slug and coalesce(nullif(p.slug, ''), 'home') = q.page_slug
            and k.keyword_norm = q.query_norm
       ) as in_plan
  from console.mv_page_query_28d q
 where q.brand_slug in (select console.readable_brands());

revoke all on console_api.rank_distribution, console_api.keyword_movers, console_api.keyword_rank_history,
              console_api.plan_pages, console_api.page_queries from public, anon;
grant select on console_api.rank_distribution, console_api.keyword_movers, console_api.keyword_rank_history,
                console_api.plan_pages, console_api.page_queries to authenticated;

commit;

-- Verify (read-only, signed-in user):
-- select lens, day, b1_3, b4_10, b11_20, b21_40, b41_100 from console_api.rank_distribution where brand_slug='vitalsleep-clinic' order by day desc limit 4;
-- select status, count(*), count(clicks_28d) from console_api.plan_pages where brand_slug='vth-biodent' group by 1;
