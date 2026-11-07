-- 2026-11-07 · DR-078 W12_03 · v_page_change_impact: make the whole view readable (perf only, no logic change)
--
-- Problem: `select ... from v_page_change_impact` (no page_fp filter) hit the 2-min statement timeout.
-- seo_gsc_query_daily (~1.9M rows) had no index on page_url, and the planner matched page URLs
-- (seo_norm_url) only after joining GSC rows to events, so each event scanned its whole brand.
-- Per-page reads (where page_fp = ...) took ~3 s; the console reads it per page.
--
-- Fix:
--   1. index seo_gsc_query_daily (brand_id, page_url, snapshot_date)
--   2. view: new CTE `pmap` (page_fp -> GSC page_url), MATERIALIZED, joined before the GSC rows.
-- Same columns, names, types, order and numbers; CREATE OR REPLACE VIEW keeps grants and the comment.
-- Re-runnable. Run in the Supabase SQL editor (plain CREATE INDEX: it briefly blocks writes to the
-- GSC table, ~seconds; don't run during the GSC import). Verify queries at the bottom.

create index if not exists idx_gsc_query_daily_brand_page_date
  on public.seo_gsc_query_daily (brand_id, page_url, snapshot_date);

create or replace view public.v_page_change_impact
with (security_invoker = true) as
with ev as (
  select page_fp, change_date, brand_id, fields, event_kind, notes
  from public.v_page_change_events
), lo as (
  select min(ev.change_date) - 28 as d from ev
), gurl as (
  select d.brand_id, d.page_url, public.seo_norm_url(d.page_url) as nurl
  from (
    select distinct g.brand_id, g.page_url
    from public.seo_gsc_query_daily g
    where g.brand_id in (select ev.brand_id from ev)
      and g.search_type = 'web'
      and g.snapshot_date >= (select lo.d from lo)
  ) d
), page_urls as (
  select pm.fingerprint as page_fp, public.seo_norm_url(pm.canonical_url) as nurl
  from public.seo_website_page_master pm
  where pm.canonical_url is not null and pm.fingerprint in (select ev.page_fp from ev)
  union
  select l.page_fp, public.seo_norm_url(l.old_value #>> '{}')
  from public.seo_page_change_log l
  where l.field in ('url', 'final_url') and jsonb_typeof(l.old_value) = 'string'
  union
  select l.page_fp, public.seo_norm_url(l.new_value #>> '{}')
  from public.seo_page_change_log l
  where l.field in ('url', 'final_url') and jsonb_typeof(l.new_value) = 'string'
), pmap as materialized (
  -- W12_03: resolve each page to its GSC page_url(s) first (a few hundred rows), behind a
  -- MATERIALIZED fence, so the GSC read below is an index lookup on (brand_id, page_url, snapshot_date)
  select distinct u.page_fp, gu.brand_id, gu.page_url
  from (select distinct ev.page_fp, ev.brand_id from ev) e
  join page_urls u on u.page_fp = e.page_fp
  join gurl gu on gu.brand_id = e.brand_id and gu.nurl = u.nurl
), page_win as (
  select e.page_fp, e.change_date,
    -- 28-day windows
    sum(g.clicks)                       filter (where g.snapshot_date <  e.change_date)     as clicks_b,
    sum(g.impressions)                  filter (where g.snapshot_date <  e.change_date)     as impr_b,
    sum(g.position * g.impressions)     filter (where g.snapshot_date <  e.change_date)     as posw_b,
    sum(g.clicks)                       filter (where g.snapshot_date >= e.change_date + 3) as clicks_a,
    sum(g.impressions)                  filter (where g.snapshot_date >= e.change_date + 3) as impr_a,
    sum(g.position * g.impressions)     filter (where g.snapshot_date >= e.change_date + 3) as posw_a,
    -- 14-day windows (subsets of the above)
    sum(g.clicks)                   filter (where g.snapshot_date >= e.change_date - 14 and g.snapshot_date < e.change_date)      as clicks_b14,
    sum(g.impressions)              filter (where g.snapshot_date >= e.change_date - 14 and g.snapshot_date < e.change_date)      as impr_b14,
    sum(g.position * g.impressions) filter (where g.snapshot_date >= e.change_date - 14 and g.snapshot_date < e.change_date)      as posw_b14,
    sum(g.clicks)                   filter (where g.snapshot_date >= e.change_date + 3  and g.snapshot_date < e.change_date + 17) as clicks_a14,
    sum(g.impressions)              filter (where g.snapshot_date >= e.change_date + 3  and g.snapshot_date < e.change_date + 17) as impr_a14,
    sum(g.position * g.impressions) filter (where g.snapshot_date >= e.change_date + 3  and g.snapshot_date < e.change_date + 17) as posw_a14
  from ev e
  join pmap pm on pm.page_fp = e.page_fp and pm.brand_id = e.brand_id
  join public.seo_gsc_query_daily g
    on g.brand_id = pm.brand_id and g.page_url = pm.page_url and g.search_type = 'web'
   and (   (g.snapshot_date >= e.change_date - 28 and g.snapshot_date < e.change_date)
        or (g.snapshot_date >= e.change_date + 3  and g.snapshot_date < e.change_date + 31))
  group by e.page_fp, e.change_date
), brand_daily as (
  select g.brand_id, g.snapshot_date, sum(g.clicks) as clicks, sum(g.impressions) as impr
  from public.seo_gsc_query_daily g
  where g.brand_id in (select ev.brand_id from ev)
    and g.search_type = 'web'
    and g.snapshot_date >= (select lo.d from lo)
  group by g.brand_id, g.snapshot_date
), brand_cov as (
  select g.brand_id, min(g.snapshot_date) as min_d, max(g.snapshot_date) as max_d
  from public.seo_gsc_query_daily g
  where g.brand_id in (select ev.brand_id from ev) and g.search_type = 'web'
  group by g.brand_id
), brand_win as (
  select e.page_fp, e.change_date,
    sum(b.clicks) filter (where b.snapshot_date <  e.change_date)     as clicks_b,
    sum(b.impr)   filter (where b.snapshot_date <  e.change_date)     as impr_b,
    sum(b.clicks) filter (where b.snapshot_date >= e.change_date + 3) as clicks_a,
    sum(b.impr)   filter (where b.snapshot_date >= e.change_date + 3) as impr_a,
    sum(b.clicks) filter (where b.snapshot_date >= e.change_date - 14 and b.snapshot_date < e.change_date)      as clicks_b14,
    sum(b.impr)   filter (where b.snapshot_date >= e.change_date - 14 and b.snapshot_date < e.change_date)      as impr_b14,
    sum(b.clicks) filter (where b.snapshot_date >= e.change_date + 3  and b.snapshot_date < e.change_date + 17) as clicks_a14,
    sum(b.impr)   filter (where b.snapshot_date >= e.change_date + 3  and b.snapshot_date < e.change_date + 17) as impr_a14
  from ev e
  join brand_daily b
    on b.brand_id = e.brand_id
   and (   (b.snapshot_date >= e.change_date - 28 and b.snapshot_date < e.change_date)
        or (b.snapshot_date >= e.change_date + 3  and b.snapshot_date < e.change_date + 31))
  group by e.page_fp, e.change_date
), m as (
  select e.page_fp, e.change_date, e.brand_id, e.event_kind, e.fields, e.notes,
    coalesce(p.clicks_b, 0) as clicks_b,
    coalesce(p.impr_b, 0)   as impr_b,
    p.clicks_b::numeric / nullif(p.impr_b, 0) as ctr_b,
    p.posw_b / nullif(p.impr_b, 0)            as pos_b,
    coalesce(p.clicks_a, 0) as clicks_a,
    coalesce(p.impr_a, 0)   as impr_a,
    p.clicks_a::numeric / nullif(p.impr_a, 0) as ctr_a,
    p.posw_a / nullif(p.impr_a, 0)            as pos_a,
    bw.clicks_b / nullif(bw.impr_b, 0) as brand_ctr_b,
    bw.clicks_a / nullif(bw.impr_a, 0) as brand_ctr_a,
    bw.clicks_b as brand_clicks_b,
    bw.clicks_a as brand_clicks_a,
    coalesce(p.clicks_b14, 0) as clicks_b14,
    coalesce(p.impr_b14, 0)   as impr_b14,
    p.clicks_b14::numeric / nullif(p.impr_b14, 0) as ctr_b14,
    p.posw_b14 / nullif(p.impr_b14, 0)            as pos_b14,
    coalesce(p.clicks_a14, 0) as clicks_a14,
    coalesce(p.impr_a14, 0)   as impr_a14,
    p.clicks_a14::numeric / nullif(p.impr_a14, 0) as ctr_a14,
    p.posw_a14 / nullif(p.impr_a14, 0)            as pos_a14,
    bw.clicks_b14 / nullif(bw.impr_b14, 0) as brand_ctr_b14,
    bw.clicks_a14 / nullif(bw.impr_a14, 0) as brand_ctr_a14,
    c.min_d, c.max_d,
    exists (select 1 from ev o
            where o.page_fp = e.page_fp and o.change_date <> e.change_date
              and abs(o.change_date - e.change_date) <= 31) as has_overlap,
    exists (select 1 from ev o
            where o.page_fp = e.page_fp and o.change_date <> e.change_date
              and abs(o.change_date - e.change_date) <= 17) as has_overlap14
  from ev e
  left join page_win  p  on p.page_fp  = e.page_fp and p.change_date  = e.change_date
  left join brand_win bw on bw.page_fp = e.page_fp and bw.change_date = e.change_date
  left join brand_cov c  on c.brand_id = e.brand_id
)
select
  -- ===== existing columns: names, types and order unchanged =====
  page_fp, change_date, brand_id, event_kind, fields, notes,
  clicks_b, impr_b, ctr_b, pos_b,
  clicks_a, impr_a, ctr_a, pos_a,
  clicks_a - clicks_b as d_clicks,
  ctr_a - ctr_b       as d_ctr,
  pos_a - pos_b       as d_pos,
  ctr_a - ctr_b - (brand_ctr_a - brand_ctr_b) as ctr_delta_vs_brand,
  clicks_a::numeric / nullif(clicks_b, 0) - 1 - (brand_clicks_a / nullif(brand_clicks_b, 0) - 1) as clicks_delta_vs_brand,
  case when max_d >= change_date + 30 then 'ready' else 'pending' end as status,
  case
    when impr_b < 100 or impr_a < 100 or has_overlap or min_d is null or min_d > change_date - 28 then 'low'
    when event_kind = 'url_change' then 'medium'
    else 'high'
  end as confidence,
  -- ===== new: 28-day impressions + relative (%) deltas; fractions, 0.1 = +10% =====
  impr_a - impr_b as d_impr,
  clicks_a::numeric / nullif(clicks_b, 0) - 1 as pct_clicks,
  impr_a::numeric   / nullif(impr_b, 0)   - 1 as pct_impr,
  ctr_a / nullif(ctr_b, 0) - 1                as pct_ctr,
  -- ===== new: 14-day early read =====
  clicks_b14, impr_b14, ctr_b14, pos_b14,
  clicks_a14, impr_a14, ctr_a14, pos_a14,
  clicks_a14 - clicks_b14 as d_clicks14,
  impr_a14 - impr_b14     as d_impr14,
  ctr_a14 - ctr_b14       as d_ctr14,
  pos_a14 - pos_b14       as d_pos14,
  clicks_a14::numeric / nullif(clicks_b14, 0) - 1 as pct_clicks14,
  ctr_a14 / nullif(ctr_b14, 0) - 1               as pct_ctr14,
  ctr_a14 - ctr_b14 - (brand_ctr_a14 - brand_ctr_b14) as ctr_delta_vs_brand14,
  case when max_d >= change_date + 16 then 'ready' else 'pending' end as status14,
  case
    when impr_b14 < 50 or impr_a14 < 50 or has_overlap14 or min_d is null or min_d > change_date - 14 then 'low'
    when event_kind = 'url_change' then 'medium'
    else 'high'
  end as confidence14
from m;

revoke all on public.v_page_change_impact from anon;

analyze public.seo_gsc_query_daily;

-- verify (read-only):
-- select count(*) n, count(*) filter (where impr_b14 >= 50) with_baseline from public.v_page_change_impact;  -- should finish, not time out
-- select page_fp, change_date, impr_b14, impr_a14, status14 from public.v_page_change_impact where page_fp = 'page_35E39D11161546B6';
