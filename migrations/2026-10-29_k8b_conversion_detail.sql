-- K8b · Kameie: conversion detail — CTA, page type, branch, locale, campaign, behaviour, journeys, call lines (applied 2026-10-29) · 2026-10-29
-- Builds on K8a. Every new dimension is optional: the UI shows a switch / card only when the brand has data for it.
-- 1) console.mv_conv_detail — per Tsaheylu bond: CTA, page type, branch, locale, campaign name, scroll / time / pages
--    before converting, journey (query strings stripped), and calls Tsaheylu matched to the bond (none matched yet).
--    Internal only; refreshed with K8a's hourly job.
-- 2) console_api.conversion_groups — same rows as K8a plus dims cta_location, cta, page_type, branch, locale, campaign;
--    columns appended: matched calls and behaviour medians.
-- 3) console_api.conversion_paths — multi-page journeys that converted (≥ 2 times in 56 days).
-- 4) console_api.conversion_call_lines — calls per tracking number / destination; conversion_calls_daily gains
--    quality calls (answered and talked ≥ 60 s) and average ring time.
-- Click ids (gclid, gbraid, fbclid), visitor / GA / LINE ids and caller hashes stay out.
-- Run in the Supabase SQL editor as one transaction.

begin;

-- ── 1. detail (internal)
create materialized view console.mv_conv_detail as
select t.bond_id, t.brand_id as brand_slug,
       t.cta_location, t.cta_id, t.page_type, t.branch_slug, t.content_locale,
       coalesce(nullif(t.utm ->> 'utm_campaign', ''), nullif(t.entry_campaign, '(none)')) as campaign,
       t.scroll_at_click, t.seconds_to_click, t.pages_before_convert,
       nullif(regexp_replace(t.journey_path, '[?#][^,]*', '', 'g'), '') as journey,
       coalesce(c.calls, 0) as calls, coalesce(c.answered, 0) as calls_answered, coalesce(c.quality, 0) as calls_quality
  from public.tsa_bond t
  left join (select matched_bond_id, count(*)::int as calls, count(*) filter (where answered)::int as answered,
                    count(*) filter (where answered and talk_seconds >= 60)::int as quality
               from public.tsa_call where matched_bond_id is not null group by 1) c on c.matched_bond_id = t.bond_id
 where t.created_at > now() - interval '200 days';
create unique index on console.mv_conv_detail (bond_id);

create or replace function console.refresh_conv_mvs() returns void
language plpgsql security definer set search_path = '' as $$
begin
  refresh materialized view concurrently console.mv_conv_events;
  refresh materialized view concurrently console.mv_conv_detail;
end $$;

-- ── 2. groups: K8a dims + detail dims, appended columns
create or replace view console_api.conversion_groups as
with t as (select (now() at time zone 'Asia/Bangkok')::date as today
), x as (
  select e.brand_slug, e.day, e.channel, e.confirmed, e.entry_channel, a.attribution, a.dim, a.key, a.page_fp,
         d.calls, d.calls_answered, d.calls_quality, d.scroll_at_click, d.seconds_to_click, d.pages_before_convert
    from console.mv_conv_events e
    left join console.mv_conv_detail d on d.bond_id = e.bond_id
    cross join lateral (values
      ('convert', 'cluster', e.convert_cluster, null::text), ('convert', 'product_line', e.convert_product_line, null),
      ('convert', 'entity', e.convert_entity, null), ('convert', 'page', e.convert_slug, e.convert_page_fp),
      ('entry', 'cluster', e.entry_cluster, null), ('entry', 'product_line', e.entry_product_line, null),
      ('entry', 'entity', e.entry_entity, null), ('entry', 'page', e.entry_slug, e.entry_page_fp)
    ) a(attribution, dim, key, page_fp)
   where e.brand_slug in (select console.readable_brands())
  union all
  -- properties of the conversion itself: identical under both attributions so the toggle never empties them
  select e.brand_slug, e.day, e.channel, e.confirmed, e.entry_channel, at.attribution, a.dim, a.key, null,
         d.calls, d.calls_answered, d.calls_quality, d.scroll_at_click, d.seconds_to_click, d.pages_before_convert
    from console.mv_conv_events e
    join console.mv_conv_detail d on d.bond_id = e.bond_id
    cross join (values ('convert'), ('entry')) at(attribution)
    cross join lateral (values
      ('cta_location', d.cta_location), ('cta', d.cta_id), ('page_type', d.page_type),
      ('branch', d.branch_slug), ('locale', d.content_locale), ('campaign', d.campaign)
    ) a(dim, key)
   where e.brand_slug in (select console.readable_brands())
), g as (
  select x.brand_slug, x.attribution, x.dim, coalesce(x.key, '(none)') as key, max(x.page_fp) as page_fp,
         count(*) filter (where x.day > t.today - 28)::int as conv_28d,
         count(*) filter (where x.day <= t.today - 28 and x.day > t.today - 56)::int as conv_prev_28d,
         count(*) filter (where x.day > t.today - 28 and x.confirmed)::int as confirmed_28d,
         count(*) filter (where x.day > t.today - 28 and x.channel = 'line')::int as line_28d,
         count(*) filter (where x.day > t.today - 28 and x.channel = 'tel')::int as tel_28d,
         count(*) filter (where x.day > t.today - 28 and x.entry_channel = 'organic_search')::int as organic_28d,
         count(*) filter (where x.day > t.today - 28 and x.entry_channel = 'ai_referral')::int as ai_28d,
         coalesce(sum(x.calls) filter (where x.day > t.today - 28), 0)::int as calls_28d,
         coalesce(sum(x.calls_answered) filter (where x.day > t.today - 28), 0)::int as calls_answered_28d,
         coalesce(sum(x.calls_quality) filter (where x.day > t.today - 28), 0)::int as calls_quality_28d,
         percentile_cont(0.5) within group (order by x.scroll_at_click) filter (where x.day > t.today - 28) as scroll_p50,
         percentile_cont(0.5) within group (order by x.seconds_to_click) filter (where x.day > t.today - 28) as seconds_p50,
         round(avg(x.pages_before_convert) filter (where x.day > t.today - 28), 1) as pages_before_avg
    from x cross join t where x.day > t.today - 56 group by 1, 2, 3, 4
)
select g.brand_slug, g.attribution, g.dim, g.key, g.page_fp, g.conv_28d, g.conv_prev_28d, g.confirmed_28d,
       g.line_28d, g.tel_28d, g.organic_28d, g.ai_28d,
       case g.dim when 'cluster' then coalesce(c.cluster_name, g.key) when 'page' then coalesce(p.page_name, '/' || g.key) else g.key end as label,
       case when g.dim = 'page' then ga.organic_sessions_28d end as organic_sessions_28d,
       g.calls_28d, g.calls_answered_28d, g.calls_quality_28d, g.scroll_p50, g.seconds_p50, g.pages_before_avg
  from g
  left join public.seo_topic_cluster_master c on g.dim = 'cluster' and c.cluster_slug = g.key
  left join public.seo_website_page_master p on g.dim = 'page' and p.fingerprint = g.page_fp
  left join console.mv_page_ga4_28d ga on g.dim = 'page' and ga.brand_slug = g.brand_slug and ga.page_slug = g.key;

-- ── 3. journeys that converted
create view console_api.conversion_paths as
with t as (select (now() at time zone 'Asia/Bangkok')::date as today)
select e.brand_slug, d.journey,
       cardinality(string_to_array(d.journey, ','))::int as steps,
       count(*) filter (where e.day > t.today - 28)::int as conv_28d,
       count(*)::int as conv_56d,
       count(*) filter (where e.entry_channel = 'organic_search')::int as organic_56d
  from console.mv_conv_events e
  join console.mv_conv_detail d on d.bond_id = e.bond_id
  cross join t
 where e.brand_slug in (select console.readable_brands())
   and d.journey like '%,%' and e.day > t.today - 56          -- multi-page journeys only; single pages are in groups
 group by 1, 2, 3
having count(*) >= 2;

-- ── 4. calls: per tracking line, and quality per day
create view console_api.conversion_call_lines as
with t as (select (now() at time zone 'Asia/Bangkok')::date as today)
select c.brand_id as brand_slug, c.did as line_number, coalesce(c.destination, '(none)') as destination,
       count(*) filter (where (c.started_at at time zone 'Asia/Bangkok')::date > t.today - 28)::int as calls_28d,
       count(*) filter (where (c.started_at at time zone 'Asia/Bangkok')::date <= t.today - 28)::int as calls_prev_28d,
       count(*) filter (where (c.started_at at time zone 'Asia/Bangkok')::date > t.today - 28 and c.answered)::int as answered_28d,
       count(*) filter (where (c.started_at at time zone 'Asia/Bangkok')::date > t.today - 28 and c.answered and c.talk_seconds >= 60)::int as quality_28d,
       round(avg(c.ring_seconds) filter (where (c.started_at at time zone 'Asia/Bangkok')::date > t.today - 28))::int as avg_ring_seconds
  from public.tsa_call c cross join t
 where c.direction = 'inbound' and c.started_at > now() - interval '57 days'
   and c.brand_id in (select console.readable_brands())
 group by 1, 2, 3;

create or replace view console_api.conversion_calls_daily as
select brand_id as brand_slug, (started_at at time zone 'Asia/Bangkok')::date as day,
       count(*)::int as calls, count(*) filter (where answered)::int as answered,
       round(avg(talk_seconds) filter (where answered))::int as avg_talk_seconds,
       count(*) filter (where answered and talk_seconds >= 60)::int as quality,
       round(avg(ring_seconds))::int as avg_ring_seconds
  from public.tsa_call
 where direction = 'inbound' and started_at > now() - interval '200 days'
   and brand_id in (select console.readable_brands())
 group by 1, 2;

revoke all on console_api.conversion_paths, console_api.conversion_call_lines from public, anon;
grant select on console_api.conversion_paths, console_api.conversion_call_lines to authenticated;

commit;

-- Verify (read-only, signed-in user):
-- select dim, count(*), sum(conv_28d) from console_api.conversion_groups where brand_slug = 'vth-biodent' and attribution = 'entry' group by 1 order by 1;
-- select * from console_api.conversion_paths where brand_slug = 'vth-biodent' order by conv_56d desc limit 10;
-- select * from console_api.conversion_call_lines where brand_slug = 'vth-biodent' order by calls_28d desc;
