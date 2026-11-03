-- K10a · Kameie: webmaster tasks from missing planned links, UX + conversion alerts, redirect check fix · 2026-11-03
-- 1) console.mv_link_gaps — per source page: planned links (K6c 'missing': both pages Live, source crawled) not on the
--    live page. Refreshed 00:40 UTC (after the ~23:00 page-history crawl). console_api.actions shows one task per page,
--    action_key 'add planned links' (role: webmaster). When the crawler finds the links, the page leaves the feed and an
--    open / in-progress task is closed automatically with a note.
-- 2) console.generate_alerts gains kinds 'ux' (Clarity: ≥ 20% of a page's sessions hit a script error, ≥ 30 sessions in
--    28 days) and 'conversion' (Tsaheylu: last 7 full days ≤ 50% of the 4-week average before, average ≥ 10 a week).
--    Both resolve on their own when the condition clears. redirect_missing was already a critical 'health' alert (K4a).
-- 3) console.page_health_all: redirect_wrong_target compared the landed URL with redirect_target as text, but VTH /
--    Deezy store the target as a slug or path ('mad', '/why-deezy/'), so every correct redirect there was flagged
--    (6 false alerts on 2026-11-03). Now both sides go through console.url_slug.
-- Run in the Supabase SQL editor as one transaction.

begin;

-- ── 1. link gaps
create materialized view console.mv_link_gaps as
select l.brand_slug, p.page_fingerprint as page_code, l.from_page_fp,
       count(*)::int as missing,
       (array_agg('→ /' || l.to_slug order by l.link_priority nulls last, l.to_slug))[1:8] as targets,
       now() as refreshed_at
  from console.page_links_all l
  join public.seo_website_page_master p on p.fingerprint = l.from_page_fp
 where l.state = 'missing'
 group by 1, 2, 3;
create unique index on console.mv_link_gaps (brand_slug, page_code);

create function console.refresh_link_gaps() returns void
language plpgsql security definer set search_path = '' as $$
begin
  refresh materialized view concurrently console.mv_link_gaps;
  update console.actions a
     set status = 'done',
         note = coalesce(a.note || E'\n', '') || 'Closed automatically ' || current_date || ': the crawler found the planned links on the live page.'
   where a.action_key = 'add planned links' and a.status in ('open', 'in_progress')
     and not exists (select 1 from console.mv_link_gaps g where g.brand_slug = a.brand_slug and g.page_code = a.page_code);
end $$;
revoke all on function console.refresh_link_gaps() from public, anon, authenticated;
select cron.schedule('kameie-refresh-link-gaps', '40 0 * * *', 'select console.refresh_link_gaps()');

-- same as K1b plus the linkfeed branch; output columns unchanged
create or replace view console_api.actions as
with page as (
  select p.brand_id, p.page_fingerprint as page_code, p.fingerprint as page_fp, p.slug, p.page_name, p.page_type
    from public.seo_website_page_master p
   where p.brand_id in (select console.readable_brands())
), feed as (
  select a.id as action_id, v.brand_id as brand_slug, 'priority'::text as source,
         v.page_fingerprint as page_code, v.suggested_action as title, v.score, v.top_signals, v.refreshed_at,
         a.status, a.assignee, a.note, a.due_date, a.created_at, a.updated_at, a.done_at, a.done_by
    from public.v_page_priority v
    left join console.actions a
      on a.brand_slug = v.brand_id and a.page_code = v.page_fingerprint and a.action_key = v.suggested_action
   where v.brand_id in (select console.readable_brands())
), linkfeed as (                 -- one task per page with planned links missing on the live page
  -- ponytail: score = 5 per missing link, capped at 50 (feed scores run 0–85); weight by link_priority if it starts to matter
  select a.id as action_id, g.brand_slug, 'priority'::text as source, g.page_code, 'add planned links'::text as title,
         least(50, 5 * g.missing)::numeric as score, array[g.missing || ' planned links missing'] || g.targets as top_signals,
         g.refreshed_at, a.status, a.assignee, a.note, a.due_date, a.created_at, a.updated_at, a.done_at, a.done_by
    from console.mv_link_gaps g
    left join console.actions a
      on a.brand_slug = g.brand_slug and a.page_code = g.page_code and a.action_key = 'add planned links'
   where g.brand_slug in (select console.readable_brands())
), kept as (
  select a.id as action_id, a.brand_slug, a.source, a.page_code, coalesce(a.title, a.action_key) as title,
         null::numeric as score, null::text[] as top_signals, null::timestamptz as refreshed_at,
         a.status, a.assignee, a.note, a.due_date, a.created_at, a.updated_at, a.done_at, a.done_by
    from console.actions a
   where a.brand_slug in (select console.readable_brands())
     and (a.source = 'manual'
          or (a.action_key = 'add planned links'
              and not exists (select 1 from console.mv_link_gaps g where g.brand_slug = a.brand_slug and g.page_code = a.page_code))
          or (a.action_key <> 'add planned links'
              and not exists (select 1 from public.v_page_priority v
                               where v.brand_id = a.brand_slug and v.page_fingerprint = a.page_code and v.suggested_action = a.action_key)))
), allx as (
  select * from feed union all select * from linkfeed union all select * from kept
)
select x.action_id, x.brand_slug, x.source, x.page_code, pg.page_fp, pg.slug, pg.page_name, pg.page_type,
       x.title, x.score, x.top_signals,
       case
         when x.title ilike 'add internal links%' or x.title ilike 'add planned links%' or x.title ilike 'fix landing UX%' then 'webmaster'
         when x.source = 'manual' then null
         else 'seo_specialist'
       end                                         as role_hint,
       coalesce(x.status, 'open')                  as status,
       x.assignee, u.email as assignee_email, x.note, x.due_date, x.created_at, x.updated_at, x.done_at,
       g.clicks_28d, g.clicks_prev_28d, g.impressions_28d, g.position_28d,
       imp.change_date as impact_change_date, imp.status as impact_status, imp.confidence as impact_confidence,
       imp.d_clicks as impact_d_clicks, imp.pct_clicks as impact_pct_clicks, imp.d_pos as impact_d_pos,
       x.refreshed_at as feed_refreshed_at
  from allx x
  left join page pg on pg.brand_id = x.brand_slug and pg.page_code = x.page_code
  left join auth.users u on u.id = x.assignee
  left join console.mv_page_gsc_28d g on g.brand_id = x.brand_slug and g.page_slug = pg.slug
  left join lateral console.first_impact_after(pg.page_fp, x.done_at::date - 1) imp(change_date, status, confidence, d_clicks, pct_clicks, d_pos)
    on x.done_at is not null;

-- ── 3. redirect target compared as slugs (definition otherwise identical to the live one)
create or replace view console.page_health_all as
with p as (
  select p.fingerprint as page_fp, p.page_fingerprint as page_code, p.brand_id as brand_slug, p.slug, p.page_name,
         p.page_type, p.status, p.redirect_target
    from public.seo_website_page_master p
   where p.status = 'Live' or (p.status = 'Merged' and p.redirect_target is not null)
), j as (
  select p.*, (ls.page_fp is not null) as monitored, ls.url, ls.final_url, ls.http_status, ls.title, ls.meta_description,
         ls.h1, ls.canonical, ls.robots, ls.schema_types, ls.last_checked_at, ls.last_ok_at, ls.consecutive_failures,
         rtrim(coalesce(ls.final_url, ls.url), '/') as landed,
         coalesce(ls.last_checked_at < now() - interval '3 days', false) as stale
    from p left join public.seo_page_live_state ls on ls.page_fp = p.page_fp
)
select page_fp, page_code, brand_slug, slug, page_name, page_type, status, redirect_target, url, final_url, http_status,
       title, char_length(title) as title_len, meta_description, char_length(meta_description) as meta_len, h1, canonical,
       robots, schema_types, last_checked_at, last_ok_at, consecutive_failures,
       array_remove(array[
         case when status = 'Live' and not monitored then 'not_monitored' end,
         case when status = 'Live' and stale then 'stale_check' end,
         case when monitored and http_status is null and not stale then 'unreachable' end,
         case when http_status >= 400 and not stale then 'http_error' end,
         case when status = 'Merged' and (not monitored or stale) then 'redirect_unverified' end,
         case when status = 'Merged' and monitored and not stale and landed = rtrim(url, '/') then 'redirect_missing' end,
         case when status = 'Merged' and monitored and not stale and landed <> rtrim(url, '/')
               and console.url_slug(landed) <> console.url_slug(redirect_target) then 'redirect_wrong_target' end,
         case when status = 'Live' and landed <> rtrim(url, '/') then 'live_redirected' end,
         case when status = 'Live' and monitored and coalesce(trim(title), '') = '' then 'missing_title' end,
         case when status = 'Live' and char_length(title) > 70 then 'title_long' end,
         case when status = 'Live' and monitored and coalesce(trim(meta_description), '') = '' then 'missing_meta' end,
         case when status = 'Live' and char_length(meta_description) > 160 then 'meta_long' end,
         case when status = 'Live' and monitored and coalesce(trim(h1), '') = '' then 'missing_h1' end,
         case when status = 'Live' and canonical is not null and rtrim(canonical, '/') <> landed then 'canonical_other' end,
         case when status = 'Live' and robots ilike '%noindex%' then 'noindex' end,
         case when status = 'Live' and monitored and coalesce(cardinality(schema_types), 0) = 0 then 'no_schema' end
       ], null) as issues
  from j;

-- ── 2. alerts: new kinds
alter table console.alerts drop constraint alerts_kind_check;
alter table console.alerts add constraint alerts_kind_check
  check (kind in ('health','drop','changes','impact','assigned','ux','conversion'));

create or replace function console.generate_alerts() returns integer
language plpgsql security definer set search_path = '' as $$
declare n integer := 0; k integer;
begin
  -- health: open new critical issues, resolve cleared ones
  with cur as (
    select h.brand_slug, h.page_fp, h.slug, i as issue, 'health:' || h.page_fp || ':' || i as key
      from console.page_health_all h, unnest(h.issues) i
     where i in ('http_error','unreachable','redirect_missing','redirect_wrong_target','noindex','live_redirected')
  ), ins as (
    insert into console.alerts (brand_slug, kind, severity, title, body, link, dedupe_key)
    select c.brand_slug, 'health', 'critical',
           case c.issue when 'http_error' then 'HTTP error' when 'unreachable' then 'Unreachable'
                        when 'redirect_missing' then 'Redirect missing' when 'redirect_wrong_target' then 'Redirect to wrong page'
                        when 'noindex' then 'noindex on a live page' else 'Live page redirects' end || ': /' || coalesce(c.slug, ''),
           null, '/health?brand=' || c.brand_slug || '&issue=' || c.issue, c.key
      from cur c
     where not exists (select 1 from console.alerts a where a.dedupe_key = c.key and a.resolved_at is null)
    returning 1
  ) select count(*) into k from ins; n := n + k;
  update console.alerts a set resolved_at = now()
   where a.kind = 'health' and a.resolved_at is null
     and not exists (select 1 from console.page_health_all h, unnest(h.issues) i
                      where a.dedupe_key = 'health:' || h.page_fp || ':' || i);

  -- drop: clicks 28d <= 60% of previous 28d
  with cur as (
    select g.brand_id as brand_slug, g.page_slug, g.clicks_28d, g.clicks_prev_28d,
           'drop:' || g.brand_id || ':' || g.page_slug as key
      from console.mv_page_gsc_28d g
     where g.clicks_prev_28d >= 20 and g.clicks_28d <= g.clicks_prev_28d * 0.6
  ), ins as (
    insert into console.alerts (brand_slug, kind, severity, title, body, link, dedupe_key)
    select c.brand_slug, 'drop', 'warning', 'Clicks down ' || round(100 - 100.0 * c.clicks_28d / c.clicks_prev_28d) || '%: /' || c.page_slug,
           c.clicks_prev_28d || ' → ' || c.clicks_28d || ' clicks (28 days)', '/brands/' || c.brand_slug, c.key
      from cur c
     where not exists (select 1 from console.alerts a where a.dedupe_key = c.key and a.resolved_at is null)
    returning 1
  ) select count(*) into k from ins; n := n + k;
  update console.alerts a set resolved_at = now()
   where a.kind = 'drop' and a.resolved_at is null
     and not exists (select 1 from console.mv_page_gsc_28d g
                      where a.dedupe_key = 'drop:' || g.brand_id || ':' || g.page_slug
                        and g.clicks_prev_28d >= 20 and g.clicks_28d <= g.clicks_prev_28d * 0.6);

  -- ux: Clarity script errors in >= 20% of a page's sessions (>= 30 sessions, 28 days)
  with cur as (
    select c.brand_slug, c.page_slug, c.sessions_28d, c.script_error_sessions,
           'ux:js:' || c.brand_slug || ':' || c.page_slug as key
      from console.mv_clarity_page_28d c
     where c.device = 'All' and c.sessions_28d >= 30 and c.script_error_sessions >= 0.2 * c.sessions_28d
  ), ins as (
    insert into console.alerts (brand_slug, kind, severity, title, body, link, dedupe_key)
    select c.brand_slug, 'ux', 'warning',
           'JavaScript errors in ' || round(100.0 * c.script_error_sessions / c.sessions_28d) || '% of sessions: /' || c.page_slug,
           c.script_error_sessions || ' of ' || c.sessions_28d || ' Clarity sessions hit a script error (28 days)',
           '/brands/' || c.brand_slug || '?tab=insights', c.key
      from cur c
     where not exists (select 1 from console.alerts a where a.dedupe_key = c.key and a.resolved_at is null)
    returning 1
  ) select count(*) into k from ins; n := n + k;
  update console.alerts a set resolved_at = now()
   where a.kind = 'ux' and a.resolved_at is null
     and not exists (select 1 from console.mv_clarity_page_28d c
                      where a.dedupe_key = 'ux:js:' || c.brand_slug || ':' || c.page_slug
                        and c.device = 'All' and c.sessions_28d >= 30 and c.script_error_sessions >= 0.2 * c.sessions_28d);

  -- conversion: last 7 full days (Bangkok) <= 50% of the weekly average over the 4 weeks before, average >= 10
  with t as (select (now() at time zone 'Asia/Bangkok')::date as d
  ), w as (
    select e.brand_slug,
           count(*) filter (where e.day >= t.d - 7 and e.day < t.d) as cur7,
           count(*) filter (where e.day >= t.d - 35 and e.day < t.d - 7) / 4.0 as base7
      from console.mv_conv_events e cross join t
     where e.day >= t.d - 35 and e.day < t.d
     group by 1
  ), cur as (
    select w.*, 'conv:' || w.brand_slug as key from w where w.base7 >= 10 and w.cur7 <= w.base7 * 0.5
  ), ins as (
    insert into console.alerts (brand_slug, kind, severity, title, body, link, dedupe_key)
    select c.brand_slug, 'conversion', 'warning', 'Conversions down ' || round(100 - 100.0 * c.cur7 / c.base7) || '% this week',
           c.cur7 || ' conversions in the last 7 days vs ' || round(c.base7) || ' a week on average over the 4 weeks before',
           '/brands/' || c.brand_slug || '?tab=conversions', c.key
      from cur c
     where not exists (select 1 from console.alerts a where a.dedupe_key = c.key and a.resolved_at is null)
    returning 1
  ) select count(*) into k from ins; n := n + k;
  with t as (select (now() at time zone 'Asia/Bangkok')::date as d
  ), w as (
    select e.brand_slug,
           count(*) filter (where e.day >= t.d - 7 and e.day < t.d) as cur7,
           count(*) filter (where e.day >= t.d - 35 and e.day < t.d - 7) / 4.0 as base7
      from console.mv_conv_events e cross join t
     where e.day >= t.d - 35 and e.day < t.d
     group by 1
  )
  update console.alerts a set resolved_at = now()
   where a.kind = 'conversion' and a.resolved_at is null
     and not exists (select 1 from w where a.dedupe_key = 'conv:' || w.brand_slug and w.base7 >= 10 and w.cur7 <= w.base7 * 0.5);

  -- changes: one alert per brand per change day (last 3 days), never re-sent
  with cur as (
    select c.brand_id as brand_slug, c.change_date, count(*) as cnt, count(distinct c.page_fp) as pages,
           'changes:' || c.brand_id || ':' || c.change_date as key
      from public.seo_page_change_log c
     where c.field in ('title','h1','meta_description','http_status') and c.change_date >= current_date - 3
     group by 1, 2
  ), ins as (
    insert into console.alerts (brand_slug, kind, severity, title, body, link, dedupe_key)
    select c.brand_slug, 'changes', 'info', c.pages || case when c.pages = 1 then ' page edited' else ' pages edited' end,
           c.cnt || ' changes (title / H1 / meta / HTTP) on ' || to_char(c.change_date, 'YYYY-MM-DD'),
           '/health?brand=' || c.brand_slug, c.key
      from cur c
     where not exists (select 1 from console.alerts a where a.dedupe_key = c.key)
    returning 1
  ) select count(*) into k from ins; n := n + k;

  -- impact: done tasks whose first change has been measured (not pending), once per task
  with cur as (
    select a.id, a.brand_slug, coalesce(a.title, a.action_key) as title, imp.status, imp.pct_clicks
      from console.actions a
      join public.seo_website_page_master p on p.brand_id = a.brand_slug and p.page_fingerprint = a.page_code
      cross join lateral console.first_impact_after(p.fingerprint, a.done_at::date - 1) imp
     where a.status = 'done' and a.done_at is not null and imp.status is distinct from 'pending'
  ), ins as (
    insert into console.alerts (brand_slug, kind, severity, title, body, link, dedupe_key)
    select c.brand_slug, 'impact', 'info', 'Impact measured: ' || left(c.title, 80),
           'Result: ' || coalesce(c.status, '-') || coalesce(' · clicks ' || round(c.pct_clicks) || '%', ''),
           '/actions', 'impact:' || c.id
      from cur c
     where not exists (select 1 from console.alerts a where a.dedupe_key = 'impact:' || c.id)
    returning 1
  ) select count(*) into k from ins; n := n + k;

  return n;
end $$;

select console.generate_alerts();   -- resolves the false 'Redirect to wrong page' alerts, opens the first ux / conversion ones

commit;

-- Verify (read-only):
-- select brand_slug, count(*), sum(missing) from console.mv_link_gaps group by 1;          -- vth-biodent 121 pages / 471
-- select kind, brand_slug, title from console.alerts where resolved_at is null and kind in ('ux','conversion');
-- select count(*) from console.page_health_all where 'redirect_wrong_target' = any(issues);  -- 0
