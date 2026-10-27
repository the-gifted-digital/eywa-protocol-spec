-- K0c · Kameie console read API v1 (DRAFT, not applied) · 2026-10-28
-- Kameie Phase 0, step 3 of 3. Run after K0b.
-- Contract: the Kameie UI reads ONLY schema console_api. Views run as owner (postgres) and filter every row by
-- console.readable_brands(), so base seo_* tables stay service_role-only. When the protocol schema changes,
-- fix the view here — the UI does not move. Heavy GSC aggregates are MVs in schema console, refreshed daily.
-- After running: Dashboard → Project Settings → Data API → Exposed schemas: add `console` and `console_api`.
-- Run in the Supabase SQL editor as one transaction.

begin;

-- ── aggregates (schema console, not exposed) ─────────────────────────────────────────────
create materialized view console.mv_brand_gsc_daily as
select brand_id,
       snapshot_date,
       search_type,
       sum(clicks)::bigint                                          as clicks,
       sum(impressions)::bigint                                     as impressions,
       round(sum(position * impressions) / nullif(sum(impressions), 0), 2) as avg_position,
       count(distinct query_norm)                                   as queries,
       count(distinct page_slug)                                    as pages
  from public.seo_gsc_query_daily
 group by 1, 2, 3;
create unique index mv_brand_gsc_daily_uq on console.mv_brand_gsc_daily (brand_id, snapshot_date, search_type);

-- per page: last 28 days of each brand's own data (not current_date — GSC lags) vs the 28 days before
create materialized view console.mv_page_gsc_28d as
with bounds as (
  select brand_id, max(snapshot_date) as last_day from public.seo_gsc_query_daily group by 1
), agg as (
  select g.brand_id, g.page_slug,
         sum(g.clicks)      filter (where g.snapshot_date >  b.last_day - 28) as clicks_28d,
         sum(g.impressions) filter (where g.snapshot_date >  b.last_day - 28) as impressions_28d,
         sum(g.position * g.impressions) filter (where g.snapshot_date > b.last_day - 28)
           / nullif(sum(g.impressions) filter (where g.snapshot_date > b.last_day - 28), 0) as position_28d,
         sum(g.clicks)      filter (where g.snapshot_date <= b.last_day - 28) as clicks_prev_28d,
         sum(g.impressions) filter (where g.snapshot_date <= b.last_day - 28) as impressions_prev_28d,
         max(b.last_day) as last_day
    from public.seo_gsc_query_daily g
    join bounds b using (brand_id)
   where g.search_type = 'web' and g.snapshot_date > b.last_day - 56
   group by 1, 2
)
select brand_id, page_slug,
       coalesce(clicks_28d, 0)::bigint           as clicks_28d,
       coalesce(impressions_28d, 0)::bigint      as impressions_28d,
       round(position_28d, 2)                    as position_28d,
       coalesce(clicks_prev_28d, 0)::bigint      as clicks_prev_28d,
       coalesce(impressions_prev_28d, 0)::bigint as impressions_prev_28d,
       last_day
  from agg;
create unique index mv_page_gsc_28d_uq on console.mv_page_gsc_28d (brand_id, page_slug);

-- ── read API (schema console_api, exposed) ───────────────────────────────────────────────
create schema console_api;
revoke all on schema console_api from public, anon;
grant usage on schema console_api to authenticated;

create view console_api.my_workspaces as
select w.id, w.slug, w.name,
       case when console.is_platform_admin() then coalesce(m.role, 'platform_admin') else m.role end as role,
       console.is_platform_admin() as is_platform_admin
  from console.workspaces w
  left join console.workspace_members m on m.workspace_id = w.id and m.user_id = auth.uid()
 where m.user_id is not null or console.is_platform_admin();

create view console_api.brands as
select b.brand_slug, b.brand_name, b.brand_web_url, nullif(trim(b.status), '') as status,
       (select count(*) from public.seo_website_page_master p where p.brand_id = b.brand_slug)                     as pages_total,
       (select count(*) from public.seo_website_page_master p where p.brand_id = b.brand_slug and p.status = 'Live') as pages_live,
       (select max(d.snapshot_date) from console.mv_brand_gsc_daily d where d.brand_id = b.brand_slug)            as gsc_last_day
  from public.brands b
 where b.brand_slug in (select console.readable_brands());

create view console_api.brand_gsc_daily as
select brand_id as brand_slug, snapshot_date, search_type, clicks, impressions, avg_position, queries, pages
  from console.mv_brand_gsc_daily
 where brand_id in (select console.readable_brands());

create view console_api.page_inventory as
select p.fingerprint                                as page_fp,
       p.page_fingerprint                           as page_code,
       p.brand_id                                   as brand_slug,
       p.slug,
       p.page_name,
       p.status,
       p.page_type,
       p.page_role,
       p.cluster_id,
       p.priority,
       p.primary_entity_name,
       split_part(p.target_keyword_fp, '::', 4)     as target_keyword,
       p.seo_title,
       p.redirect_target,
       p.updated_at,
       ls.http_status,
       ls.title                                     as live_title,
       ls.canonical                                 as live_canonical,
       ls.robots                                    as live_robots,
       ls.consecutive_failures,
       ls.last_checked_at,
       g.clicks_28d, g.impressions_28d, g.position_28d,
       g.clicks_prev_28d, g.impressions_prev_28d,
       g.last_day                                   as gsc_last_day
  from public.seo_website_page_master p
  left join public.seo_page_live_state ls on ls.page_fp = p.fingerprint
  left join console.mv_page_gsc_28d g on g.brand_id = p.brand_id and g.page_slug = p.slug
 where p.brand_id in (select console.readable_brands());

-- data freshness per brand: the dashboard shows this so nobody trusts stale numbers
create view console_api.data_freshness as
select b.brand_slug,
       (select max(snapshot_date) from console.mv_brand_gsc_daily d where d.brand_id = b.brand_slug)        as gsc_last_day,
       (select max(last_checked_at) from public.seo_page_live_state s where s.brand_id = b.brand_slug)       as crawl_last_at,
       (select max(snapshot_date) from public.seo_clarity_daily c where c.brand_id = b.brand_slug)          as clarity_last_day
  from public.brands b
 where b.brand_slug in (select console.readable_brands());

revoke all on all tables in schema console_api from public, anon;
grant select on all tables in schema console_api to authenticated;
revoke all on console.mv_brand_gsc_daily, console.mv_page_gsc_28d from public, anon, authenticated;

-- daily refresh, after the 06:00 (Asia/Bangkok) GSC load → 00:30 UTC = 07:30 BKK
create function console.refresh_gsc_mvs() returns void
language sql security definer set search_path = '' as $$
  refresh materialized view concurrently console.mv_brand_gsc_daily;
  refresh materialized view concurrently console.mv_page_gsc_28d;
$$;
revoke all on function console.refresh_gsc_mvs() from public, anon, authenticated;
select cron.schedule('kameie-refresh-gsc-mvs', '30 0 * * *', 'select console.refresh_gsc_mvs()');

commit;

-- Verify (read-only, after commit):
-- select count(*) from console.mv_brand_gsc_daily;          -- > 0
-- select count(*) from console.mv_page_gsc_28d;             -- > 0
-- select jobname, schedule from cron.job;                   -- 2 jobs
