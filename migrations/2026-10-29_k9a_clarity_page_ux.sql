-- K9a · Kameie: page UX from Microsoft Clarity (public.seo_clarity_daily via v_clarity_page_daily) (applied 2026-10-29) · 2026-10-29
-- Clarity is pulled once a day per brand (numOfDays=1, URL x Device), so days add up without double counting.
-- 1) console.mv_clarity_daily   — per brand x day x device: sessions and friction sessions (trend).
-- 2) console.mv_clarity_page_28d — per brand x page x device ('All' = every device): last 28 days of Clarity data vs the
--    28 before, ending at the brand's latest Clarity day.
-- 3) console_api views: clarity_status, clarity_daily, clarity_pages (with Tsaheylu conversions on the same page, so
--    conversion rate uses Clarity sessions as the denominator).
-- Aggregates only; Clarity carries no personal data. Refreshed with the insight MVs (00:55 UTC, after the 23:15 pull).
-- ponytail: page_slug comes from public.tsa_page_slug (strips en/ zh-cn/ locations/), unlike console.url_slug which
-- keeps them — EN and TH traffic of a page are merged here; switch to console.url_slug if per-locale UX matters.
-- Run in the Supabase SQL editor as one transaction.

begin;

create materialized view console.mv_clarity_daily as
select brand_id as brand_slug, snapshot_date as day, device,
       sum(sessions)::int as sessions, sum(users)::int as users,
       sum(rage_click_sessions)::int as rage_sessions, sum(dead_click_sessions)::int as dead_sessions,
       sum(quickback_sessions)::int as quickback_sessions, sum(excessive_scroll_sessions)::int as excessive_scroll_sessions,
       sum(script_error_sessions)::int as script_error_sessions, sum(error_click_sessions)::int as error_click_sessions
  from public.v_clarity_page_daily
 group by 1, 2, 3;
create unique index on console.mv_clarity_daily (brand_slug, day, device);

create materialized view console.mv_clarity_page_28d as
with last as (select brand_id, max(snapshot_date) as d from public.seo_clarity_daily group by 1
), v as (
  select v.*, (v.snapshot_date > l.d - 28) as cur, (v.snapshot_date <= l.d - 28 and v.snapshot_date > l.d - 56) as prev
    from public.v_clarity_page_daily v join last l on l.brand_id = v.brand_id
   where v.snapshot_date > l.d - 56 and v.page_slug is not null
)
select brand_id as brand_slug, page_slug, coalesce(device, 'All') as device,
       count(distinct snapshot_date) filter (where cur)::int as days,
       coalesce(sum(sessions) filter (where cur), 0)::int as sessions_28d,
       sum(sessions) filter (where prev)::int as sessions_prev_28d,
       coalesce(sum(users) filter (where cur), 0)::int as users_28d,
       coalesce(sum(bot_sessions) filter (where cur), 0)::int as bot_sessions_28d,
       round(sum(avg_scroll_depth * sessions) filter (where cur) / nullif(sum(sessions) filter (where cur and avg_scroll_depth is not null), 0), 1) as avg_scroll,
       round(sum(active_time_s) filter (where cur) / nullif(sum(sessions) filter (where cur), 0))::int as active_s_per_session,
       coalesce(sum(rage_click_sessions) filter (where cur), 0)::int as rage_sessions,
       coalesce(sum(dead_click_sessions) filter (where cur), 0)::int as dead_sessions,
       coalesce(sum(quickback_sessions) filter (where cur), 0)::int as quickback_sessions,
       coalesce(sum(excessive_scroll_sessions) filter (where cur), 0)::int as excessive_scroll_sessions,
       coalesce(sum(script_error_sessions) filter (where cur), 0)::int as script_error_sessions,
       coalesce(sum(error_click_sessions) filter (where cur), 0)::int as error_click_sessions,
       sum(coalesce(rage_click_sessions, 0) + coalesce(dead_click_sessions, 0) + coalesce(quickback_sessions, 0)
           + coalesce(error_click_sessions, 0)) filter (where prev)::int as friction_prev_28d
  from v
 group by grouping sets ((brand_id, page_slug, device), (brand_id, page_slug));
create unique index on console.mv_clarity_page_28d (brand_slug, page_slug, device);

create or replace function console.refresh_insight_mvs() returns void
language plpgsql security definer set search_path = '' as $$
begin
  refresh materialized view concurrently console.mv_ai_visits_daily;
  refresh materialized view concurrently console.mv_ai_visits_page_28d;
  refresh materialized view concurrently console.mv_page_tech;
  refresh materialized view concurrently console.mv_clarity_daily;
  refresh materialized view concurrently console.mv_clarity_page_28d;
end $$;

-- ── read API
create view console_api.clarity_status as
select r.brand_slug, (s.first_day is not null) as installed, s.first_day, s.last_day, coalesce(s.days, 0) as days
  from (select console.readable_brands() as brand_slug) r
  left join (select brand_slug, min(day) as first_day, max(day) as last_day, count(distinct day)::int as days
               from console.mv_clarity_daily group by 1) s on s.brand_slug = r.brand_slug;

create view console_api.clarity_daily as
select * from console.mv_clarity_daily where brand_slug in (select console.readable_brands());

-- per page x device; friction = sessions with rage / dead / quickback / error clicks (a session can count in several)
create view console_api.clarity_pages as
with conv as (   -- Tsaheylu clicks made on the page, over the same 28 days as the page's Clarity window
  select e.brand_slug, e.convert_slug as page_slug, count(*)::int as conv_28d
    from console.mv_conv_events e
    join (select brand_slug, max(day) as d from console.mv_clarity_daily group by 1) l on l.brand_slug = e.brand_slug
   where e.day > l.d - 28 and e.day <= l.d
   group by 1, 2
)
select c.brand_slug, c.page_slug, c.device, p.fingerprint as page_fp, p.page_name,
       c.days, c.sessions_28d, c.sessions_prev_28d, c.users_28d, c.bot_sessions_28d, c.avg_scroll, c.active_s_per_session,
       c.rage_sessions, c.dead_sessions, c.quickback_sessions, c.excessive_scroll_sessions,
       c.script_error_sessions, c.error_click_sessions,
       (c.rage_sessions + c.dead_sessions + c.quickback_sessions + c.error_click_sessions) as friction_28d,
       c.friction_prev_28d,
       round(100.0 * (c.rage_sessions + c.dead_sessions + c.quickback_sessions + c.error_click_sessions)
             / nullif(c.sessions_28d, 0), 1) as friction_per_100,
       case when c.device = 'All' then cv.conv_28d end as conv_28d,
       case when c.device = 'All' then round(100.0 * cv.conv_28d / nullif(c.sessions_28d, 0), 2) end as conv_rate_pct
  from console.mv_clarity_page_28d c
  left join public.seo_website_page_master p on p.brand_id = c.brand_slug and coalesce(nullif(p.slug, ''), 'home') = c.page_slug
  left join conv cv on cv.brand_slug = c.brand_slug and cv.page_slug = c.page_slug
 where c.brand_slug in (select console.readable_brands());

revoke all on console_api.clarity_status, console_api.clarity_daily, console_api.clarity_pages from public, anon;
grant select on console_api.clarity_status, console_api.clarity_daily, console_api.clarity_pages to authenticated;

commit;

-- Verify (read-only, signed-in user):
-- select * from console_api.clarity_status where brand_slug = 'vth-biodent';
-- select page_slug, sessions_28d, friction_per_100, conv_28d, conv_rate_pct from console_api.clarity_pages
--  where brand_slug = 'vth-biodent' and device = 'All' order by sessions_28d desc limit 10;
