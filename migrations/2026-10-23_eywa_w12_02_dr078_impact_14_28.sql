-- 2026-10-23 · DR-078 amendment · v_page_change_impact: two read points (14-day early read + 28-day final)
--
-- Adds columns to v_page_change_impact; every existing column keeps its name, type and position,
-- so CREATE OR REPLACE VIEW is legal and nothing reading the view breaks. Re-runnable.
--   * 28-day (final) gains: d_impr, pct_clicks, pct_impr, pct_ctr
--   * 14-day (early read) block: before [change_date-14, change_date), after [change_date+3, change_date+17)
--       clicks/impr/ctr/pos _b14/_a14, d_* 14, pct_* 14, ctr_delta_vs_brand14, status14, confidence14
-- Both 14-day windows sit inside the 28-day ones, so the existing GSC scan already covers them.
-- Windows are whole weeks (14 / 28 days) so weekday mix is equal on both sides.

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
  join page_urls u on u.page_fp = e.page_fp
  join gurl gu on gu.brand_id = e.brand_id and gu.nurl = u.nurl
  join public.seo_gsc_query_daily g
    on g.brand_id = gu.brand_id and g.page_url = gu.page_url and g.search_type = 'web'
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

comment on view public.v_page_change_impact is
'One row per change event (page_fp, change_date) with GSC before/after windows read at TWO points. '
'FINAL (28-day): before = [change_date-28, change_date), after = [change_date+3, change_date+31); status=''ready'' once brand GSC reaches change_date+30; confidence low if either window < 100 impressions, another event on the page within ±31 days, or brand GSC starts after change_date-28; else medium for url_change; else high. '
'EARLY READ (14-day, columns *14): before = [change_date-14, change_date), after = [change_date+3, change_date+17); status14=''ready'' once brand GSC reaches change_date+16; confidence14 low if either window < 50 impressions, another event within ±17 days, or brand GSC starts after change_date-14. Use the early read for CTR on higher-traffic pages (quick rollback calls); judge position and the final verdict on the 28-day columns. '
'Windows are whole weeks so weekday mix is equal. GSC rows are matched by seo_norm_url against every URL the page has had (canonical_url + all url/final_url log values), so slug changes keep their before traffic. pos = impression-weighted average position. d_* are absolute deltas; pct_* are relative changes (fractions, 0.1 = +10%); ctr_delta_vs_brand* are absolute CTR deltas minus the brand''s; clicks_delta_vs_brand is the page''s relative click change minus the brand''s. '
'CAVEAT: totals are summed from seo_gsc_query_daily (query x page x day), and GSC drops anonymised queries, so page totals UNDERCOUNT. Comparisons within one page are valid; absolute numbers are a lower bound. Only search_type=''web'' rows are read. '
'CAVEAT: final_url values join the page''s URL set, so if this page redirects to another page or to the home page, that target''s GSC traffic is attributed to this page from then on.';
