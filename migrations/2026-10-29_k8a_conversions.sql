-- K8a · Kameie: conversions from Tsaheylu (public.tsa_bond / tsa_call) · 2026-10-29
-- 1) console.mv_conv_events — one row per Tsaheylu bond (LINE / tel click), PII stripped, with both attributions
--    resolved against the plan: "convert" (page where the CTA was clicked) and "entry" (landing page of the visit).
--    Internal only (no grants). Refreshed hourly.
-- 2) console_api views — aggregates only:
--    conversion_status        per readable brand: is Tsaheylu installed, first / last event
--    conversions_daily        per day x channel (line/tel) x entry channel (organic_search, direct, ai_referral, …)
--    conversion_groups        28d vs previous 28d per cluster / product line / entity / page, for either attribution
--    conversion_keywords_est  estimated conversions per GSC query (organic entry conversions x query click share)
--    conversion_calls_daily   inbound calls per day (total / answered) — not attributable to pages yet
-- No visitor ids, GA ids, LINE user hashes, caller hashes, referrers or user agents leave the base tables.
-- Run in the Supabase SQL editor as one transaction.

begin;

-- ── 1. events (internal)
create materialized view console.mv_conv_events as
with b as (
  select t.bond_id, t.brand_id as brand_slug, t.created_at,
         (t.created_at at time zone 'Asia/Bangkok')::date as day,
         coalesce(t.channel_type, 'unknown') as channel, (t.outcome = 'added') as confirmed,
         coalesce(t.entry_channel, 'unknown') as entry_channel,
         t.page_fingerprint, t.cluster_id, t.product_line, t.primary_entity,
         console.url_slug(regexp_replace(t.page_path, '[?#].*$', ''))  as convert_slug,
         console.url_slug(regexp_replace(t.entry_page, '[?#].*$', '')) as entry_slug
    from public.tsa_bond t
   where t.created_at > now() - interval '200 days'
)
select b.bond_id, b.brand_slug, b.day, b.channel, b.confirmed, b.entry_channel,
       -- convert attribution: what the bond recorded at click time, plan as fallback
       cp.fingerprint                                              as convert_page_fp,
       coalesce(b.convert_slug, 'home')                            as convert_slug,
       coalesce(b.cluster_id, cp.cluster_id)                       as convert_cluster,
       coalesce(b.product_line, cpm.product_line)                  as convert_product_line,
       coalesce(b.primary_entity, cp.primary_entity_name)          as convert_entity,
       -- entry attribution: the landing page as planned
       ep.fingerprint                                              as entry_page_fp,
       b.entry_slug,
       ep.cluster_id                                               as entry_cluster,
       epm.product_line                                            as entry_product_line,
       ep.primary_entity_name                                      as entry_entity
  from b
  left join lateral (select p.fingerprint, p.cluster_id, p.primary_entity_name
                       from public.seo_website_page_master p
                      where p.brand_id = b.brand_slug
                        and (p.page_fingerprint = b.page_fingerprint or coalesce(nullif(p.slug, ''), 'home') = b.convert_slug)
                      order by (p.page_fingerprint = b.page_fingerprint) desc limit 1) cp on true
  left join public.tsa_product_map cpm on cpm.brand_id = b.brand_slug and cpm.cluster_id = coalesce(b.cluster_id, cp.cluster_id)
  left join public.seo_website_page_master ep on ep.brand_id = b.brand_slug and coalesce(nullif(ep.slug, ''), 'home') = b.entry_slug
  left join public.tsa_product_map epm on epm.brand_id = b.brand_slug and epm.cluster_id = ep.cluster_id;
create unique index on console.mv_conv_events (bond_id);
create index on console.mv_conv_events (brand_slug, day);

create function console.refresh_conv_mvs() returns void
language plpgsql security definer set search_path = '' as $$
begin
  refresh materialized view concurrently console.mv_conv_events;
end $$;
revoke all on function console.refresh_conv_mvs() from public, anon, authenticated;
select cron.schedule('kameie-refresh-conv-mvs', '7 * * * *', 'select console.refresh_conv_mvs()');

-- ── 2. read API
create view console_api.conversion_status as
select r.brand_slug, (s.first_event is not null) as installed, s.first_event, s.last_event,
       coalesce(s.events_28d, 0) as events_28d
  from (select console.readable_brands() as brand_slug) r
  left join (select brand_id, min(created_at) as first_event, max(created_at) as last_event,
                    count(*) filter (where created_at > now() - interval '28 days') as events_28d
               from public.tsa_bond group by 1) s on s.brand_id = r.brand_slug;

create view console_api.conversions_daily as
select brand_slug, day, channel, entry_channel,
       count(*)::int as conversions, count(*) filter (where confirmed)::int as confirmed
  from console.mv_conv_events
 where brand_slug in (select console.readable_brands())
 group by 1, 2, 3, 4;

-- one row per brand x attribution x dimension x key; windows end today (Bangkok)
create view console_api.conversion_groups as
with t as (select (now() at time zone 'Asia/Bangkok')::date as today
), x as (
  select e.brand_slug, e.day, e.channel, e.confirmed, e.entry_channel, a.attribution, a.dim, a.key, a.page_fp
    from console.mv_conv_events e
    cross join lateral (values
      ('convert', 'cluster',      e.convert_cluster,      null::text),
      ('convert', 'product_line', e.convert_product_line, null),
      ('convert', 'entity',       e.convert_entity,       null),
      ('convert', 'page',         e.convert_slug,         e.convert_page_fp),
      ('entry',   'cluster',      e.entry_cluster,        null),
      ('entry',   'product_line', e.entry_product_line,   null),
      ('entry',   'entity',       e.entry_entity,         null),
      ('entry',   'page',         e.entry_slug,           e.entry_page_fp)
    ) a(attribution, dim, key, page_fp)
   where e.brand_slug in (select console.readable_brands())
), g as (
  select x.brand_slug, x.attribution, x.dim, coalesce(x.key, '(none)') as key, max(x.page_fp) as page_fp,
         count(*) filter (where x.day > t.today - 28)::int                                       as conv_28d,
         count(*) filter (where x.day <= t.today - 28 and x.day > t.today - 56)::int             as conv_prev_28d,
         count(*) filter (where x.day > t.today - 28 and x.confirmed)::int                       as confirmed_28d,
         count(*) filter (where x.day > t.today - 28 and x.channel = 'line')::int                as line_28d,
         count(*) filter (where x.day > t.today - 28 and x.channel = 'tel')::int                 as tel_28d,
         count(*) filter (where x.day > t.today - 28 and x.entry_channel = 'organic_search')::int as organic_28d,
         count(*) filter (where x.day > t.today - 28 and x.entry_channel = 'ai_referral')::int   as ai_28d
    from x cross join t
   where x.day > t.today - 56
   group by 1, 2, 3, 4
)
select g.*,
       case g.dim when 'cluster' then coalesce(c.cluster_name, g.key)
                  when 'page'    then coalesce(p.page_name, '/' || g.key)
                  else g.key end as label,
       case when g.dim = 'page' then ga.organic_sessions_28d end as organic_sessions_28d
  from g
  left join public.seo_topic_cluster_master c on g.dim = 'cluster' and c.cluster_slug = g.key
  left join public.seo_website_page_master p on g.dim = 'page' and p.fingerprint = g.page_fp
  left join console.mv_page_ga4_28d ga on g.dim = 'page' and ga.brand_slug = g.brand_slug and ga.page_slug = g.key;

-- estimated conversions per query: organic entry conversions of a landing page (≥ 3 in 28d) split by the
-- query's share of that page's GSC clicks. GSC's 28d window ends at its last import, so windows differ by its lag.
create view console_api.conversion_keywords_est as
with pc as (
  select brand_slug, entry_slug as page_slug, count(*)::numeric as conv
    from console.mv_conv_events
   where brand_slug in (select console.readable_brands())
     and entry_channel = 'organic_search'
     and day > (now() at time zone 'Asia/Bangkok')::date - 28
   group by 1, 2
  having count(*) >= 3
), q as (
  select q.brand_slug, q.page_slug, q.query_norm, q.query, q.clicks,
         q.clicks::numeric / nullif(sum(q.clicks) over (partition by q.brand_slug, q.page_slug), 0) as share
    from console.mv_page_query_28d q
    join pc on pc.brand_slug = q.brand_slug and pc.page_slug = q.page_slug
   where q.clicks > 0
)
select q.brand_slug, q.query_norm, min(q.query) as query, sum(q.clicks)::int as clicks_28d,
       round(sum(pc.conv * q.share), 1) as est_conversions_28d, count(*)::int as pages,
       (array_agg(q.page_slug order by pc.conv * q.share desc))[1] as top_page_slug
  from q join pc on pc.brand_slug = q.brand_slug and pc.page_slug = q.page_slug
 group by 1, 2;

create view console_api.conversion_calls_daily as
select brand_id as brand_slug, (started_at at time zone 'Asia/Bangkok')::date as day,
       count(*)::int as calls, count(*) filter (where answered)::int as answered,
       round(avg(talk_seconds) filter (where answered))::int as avg_talk_seconds
  from public.tsa_call
 where direction = 'inbound' and started_at > now() - interval '200 days'
   and brand_id in (select console.readable_brands())
 group by 1, 2;

revoke all on console_api.conversion_status, console_api.conversions_daily, console_api.conversion_groups,
              console_api.conversion_keywords_est, console_api.conversion_calls_daily from public, anon;
grant select on console_api.conversion_status, console_api.conversions_daily, console_api.conversion_groups,
                console_api.conversion_keywords_est, console_api.conversion_calls_daily to authenticated;

commit;

-- Verify (read-only, signed-in user):
-- select * from console_api.conversion_status;
-- select dim, count(*), sum(conv_28d) from console_api.conversion_groups where brand_slug = 'vth-biodent' and attribution = 'entry' group by 1;
-- select * from console_api.conversion_keywords_est where brand_slug = 'vth-biodent' order by est_conversions_28d desc limit 10;
