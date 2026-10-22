-- W1a (handover data-quality #4): v_tsa_keyword_conversion
-- Before: conversions/line/call were page totals from ALL channels, copied onto
--         every keyword ranking for that page (e.g. 1-impression keyword showed
--         the homepage's 34 LINE clicks).
-- After:  only tsa bonds with entry_channel = 'organic_search' count, and each
--         page's organic conversions are apportioned to keywords by their share
--         of the page's GSC clicks over the same 28-day window.
--         Page totals stay visible (page_organic_*), attribution_method says
--         the keyword numbers are modelled.
-- Column types change (bigint -> numeric), so DROP + CREATE. No dependent views.

drop view if exists public.v_tsa_keyword_conversion;

create view public.v_tsa_keyword_conversion as
with latest as (
  select distinct on (l.brand, l.fingerprint)
         l.brand, l.fingerprint, l.keyword, l.gsc_clicks, l.gsc_impressions,
         l.gsc_ctr, l.gsc_actual_ranking_url, l.gsc_actual_ranking_url_position,
         l.gsc_last_update
  from seo_x_ads_keywords_x_url_daily_logs l
  where l.gsc_actual_ranking_url is not null
  order by l.brand, l.fingerprint, l.gsc_last_update desc
), conv as (
  select e.brand_id, e.entry_slug,
         count(*) as conversions,
         count(distinct e.ga_session_id) as sessions,
         count(*) filter (where e.channel_type = 'line') as line_clicks,
         count(*) filter (where e.channel_type = 'tel')  as call_clicks
  from v_tsa_bond_enriched e
  where e.created_at >= now() - interval '28 days'
    and e.entry_slug is not null
    and e.entry_channel = 'organic_search'
  group by e.brand_id, e.entry_slug
), gsc as (
  -- GSC clicks per (page, query), same 28-day window
  select q.brand_id, q.page_slug, q.query_norm, sum(q.clicks) as q_clicks
  from seo_gsc_query_daily q
  where q.search_type = 'web'
    and q.snapshot_date >= current_date - 28
  group by q.brand_id, q.page_slug, q.query_norm
), gsc_page as (
  select brand_id, page_slug, sum(q_clicks) as page_clicks
  from gsc group by brand_id, page_slug
), base as (
  select br.brand_slug as brand_id, l.*, km.search_intent,
         tsa_page_slug(regexp_replace(l.gsc_actual_ranking_url, '^https?://[^/]+', '')) as slug
  from latest l
  join brands br on br.brand_name = l.brand
  left join seo_x_ads_keywords_contextual_master km on km.fingerprint = l.fingerprint
)
select b.brand_id,
       b.keyword,
       b.search_intent,
       b.gsc_clicks as clicks_roster,
       b.gsc_impressions as impressions_roster,
       round(b.gsc_ctr::numeric, 4) as ctr,
       round(b.gsc_actual_ranking_url_position, 1) as "position",
       b.gsc_last_update::date as measured_on,
       b.gsc_actual_ranking_url as ranking_url,
       b.slug,
       pm.page_fingerprint,
       pm.page_type,
       pm.cluster_id,
       -- 0 when the page had no organic conversions; null when they exist but cannot be attributed
       case when c.conversions is null then 0 else round(c.conversions * s.share, 2) end as conversions_28d,
       case when c.conversions is null then 0 else round(c.sessions    * s.share, 2) end as sessions_28d,
       case when c.conversions is null then 0 else round(c.line_clicks * s.share, 2) end as line_clicks_28d,
       case when c.conversions is null then 0 else round(c.call_clicks * s.share, 2) end as call_clicks_28d,
       coalesce(g.q_clicks, 0) as gsc_clicks_28d,
       round(s.share, 4) as gsc_click_share_28d,
       coalesce(c.conversions, 0) as page_organic_conversions_28d,
       coalesce(c.line_clicks, 0) as page_organic_line_clicks_28d,
       coalesce(c.call_clicks, 0) as page_organic_call_clicks_28d,
       case when c.conversions is null then 'none'
            when s.share is null then 'unattributed_no_gsc_clicks'
            else 'gsc_click_share_28d' end as attribution_method
from base b
left join seo_website_page_master pm on pm.brand_id = b.brand_id and pm.slug = b.slug
left join conv c on c.brand_id = b.brand_id and c.entry_slug = b.slug
left join gsc g on g.brand_id = b.brand_id and g.page_slug = b.slug
               and g.query_norm = seo_kw_norm(b.keyword)
left join gsc_page gp on gp.brand_id = b.brand_id and gp.page_slug = b.slug
cross join lateral (
  -- null when the page had no GSC clicks at all: conversions stay unattributed
  select case when gp.page_clicks > 0 then coalesce(g.q_clicks, 0)::numeric / gp.page_clicks end as share
) s;

comment on view public.v_tsa_keyword_conversion is
  'Keyword-level organic conversions (28d). Page organic conversions (tsa_bond entry_channel=organic_search) apportioned by GSC click share; see attribution_method. Page totals in page_organic_*. Handover data-quality #4, 2026-10-21.';
