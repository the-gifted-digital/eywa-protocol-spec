-- K4a · Kameie Phase 5: in-app alerts (applied 2026-10-28) · 2026-10-28
-- Bell + /alerts in the console. No LINE / push yet (user 2026-10-28: in-app only).
-- Sources, all derived from data the console already has:
--   health    critical page issue (http_error, unreachable, redirect_missing, redirect_wrong_target, noindex,
--             live_redirected) - auto-resolves when the issue clears
--   drop      page clicks 28d <= 60% of the previous 28d (prev >= 20) - auto-resolves on recovery
--   changes   the monitor saw title/H1/meta/HTTP changes on a brand that day (one alert per brand per day)
--   impact    a done task got its first measured before/after result
--   assigned  a task was assigned to you (personal, sent instantly by trigger)
-- Generated daily 01:00 UTC by pg_cron (after the GSC 00:30 and explorer 00:45 MVs), and once at the end of this file.
-- resolved_at is set only for condition alerts (health, drop) when the condition clears; events stay open.
-- Read state is one "seen up to" timestamp per user (mark-all-read), not per alert.
-- Also refactors console_api.page_health onto an unfiltered internal view so the generator can read every brand.
-- Run in the Supabase SQL editor as one transaction.

begin;

-- ── page health, unfiltered (internal: no grants). console_api.page_health now filters this.
create view console.page_health_all as
with p as (
  select p.fingerprint as page_fp, p.page_fingerprint as page_code, p.brand_id as brand_slug, p.slug, p.page_name,
         p.page_type, p.status, p.redirect_target
    from public.seo_website_page_master p
   where (p.status = 'Live' or (p.status = 'Merged' and p.redirect_target is not null))
), j as (
  select p.*, ls.page_fp is not null as monitored,
         ls.url, ls.final_url, ls.http_status, ls.title, ls.meta_description, ls.h1, ls.canonical, ls.robots,
         ls.schema_types, ls.last_checked_at, ls.last_ok_at, ls.consecutive_failures,
         rtrim(coalesce(ls.final_url, ls.url), '/') as landed,
         coalesce(ls.last_checked_at < now() - interval '3 days', false) as stale
    from p left join public.seo_page_live_state ls on ls.page_fp = p.page_fp
)
select j.page_fp, j.page_code, j.brand_slug, j.slug, j.page_name, j.page_type, j.status, j.redirect_target,
       j.url, j.final_url, j.http_status, j.title, char_length(j.title) as title_len,
       j.meta_description, char_length(j.meta_description) as meta_len, j.h1, j.canonical, j.robots, j.schema_types,
       j.last_checked_at, j.last_ok_at, j.consecutive_failures,
       array_remove(array[
         -- Live: is the page reachable and monitored?
         case when j.status = 'Live' and not j.monitored then 'not_monitored' end,
         case when j.status = 'Live' and j.stale then 'stale_check' end,
         case when j.monitored and j.http_status is null and not j.stale then 'unreachable' end,
         case when j.http_status >= 400 and not j.stale then 'http_error' end,
         -- Merged: is the 301 in place? (the monitor stops re-checking merged pages, so old evidence = unverified)
         case when j.status = 'Merged' and (not j.monitored or j.stale) then 'redirect_unverified' end,
         case when j.status = 'Merged' and j.monitored and not j.stale and j.landed = rtrim(j.url, '/') then 'redirect_missing' end,
         case when j.status = 'Merged' and j.monitored and not j.stale and j.landed <> rtrim(j.url, '/')
                   and j.landed <> rtrim(j.redirect_target, '/') then 'redirect_wrong_target' end,
         case when j.status = 'Live' and j.landed <> rtrim(j.url, '/') then 'live_redirected' end,
         case when j.status = 'Live' and j.monitored and coalesce(trim(j.title), '') = '' then 'missing_title' end,
         case when j.status = 'Live' and char_length(j.title) > 70 then 'title_long' end,
         case when j.status = 'Live' and j.monitored and coalesce(trim(j.meta_description), '') = '' then 'missing_meta' end,
         case when j.status = 'Live' and char_length(j.meta_description) > 160 then 'meta_long' end,
         case when j.status = 'Live' and j.monitored and coalesce(trim(j.h1), '') = '' then 'missing_h1' end,
         case when j.status = 'Live' and j.canonical is not null and rtrim(j.canonical, '/') <> j.landed then 'canonical_other' end,
         case when j.status = 'Live' and j.robots ilike '%noindex%' then 'noindex' end,
         case when j.status = 'Live' and j.monitored and coalesce(cardinality(j.schema_types), 0) = 0 then 'no_schema' end
       ], null) as issues
  from j;


create or replace view console_api.page_health as
select * from console.page_health_all where brand_slug in (select console.readable_brands());

-- ── alerts
create table console.alerts (
  id          bigint generated always as identity primary key,
  brand_slug  text not null references public.brands(brand_slug) on update cascade,
  kind        text not null check (kind in ('health','drop','changes','impact','assigned')),
  severity    text not null check (severity in ('critical','warning','info')),
  title       text not null,
  body        text,
  link        text,                                   -- in-app route, e.g. /health?brand=x&issue=y
  dedupe_key  text not null,
  recipient   uuid references auth.users(id) on delete cascade,   -- null = everyone who can read the brand
  created_at  timestamptz not null default now(),
  resolved_at timestamptz
);
create unique index alerts_open_key on console.alerts (dedupe_key) where resolved_at is null;
create index alerts_brand_created on console.alerts (brand_slug, created_at desc);

create table console.alert_seen (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  seen_at timestamptz not null default now()
);

alter table console.alerts     enable row level security;
alter table console.alert_seen enable row level security;
create policy al_select on console.alerts for select to authenticated
  using (brand_slug in (select console.readable_brands()) and (recipient is null or recipient = auth.uid()));
create policy as_all on console.alert_seen for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
grant select on console.alerts to authenticated;
grant select, insert, update on console.alert_seen to authenticated;
grant all on console.alerts, console.alert_seen to service_role;

-- ── generator
create function console.generate_alerts() returns integer
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
           case c.issue when 'http_error' then 'HTTP error' when 'unreachable' then 'เข้าไม่ได้'
                        when 'redirect_missing' then 'ไม่มี redirect' when 'redirect_wrong_target' then 'redirect ผิดหน้า'
                        when 'noindex' then 'noindex บนหน้า Live' else 'หน้า Live ถูก redirect' end || ': /' || coalesce(c.slug, ''),
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
    select c.brand_slug, 'drop', 'warning', 'คลิกลดลง ' || round(100 - 100.0 * c.clicks_28d / c.clicks_prev_28d) || '%: /' || c.page_slug,
           c.clicks_prev_28d || ' → ' || c.clicks_28d || ' คลิก (28 วัน)', '/brands/' || c.brand_slug, c.key
      from cur c
     where not exists (select 1 from console.alerts a where a.dedupe_key = c.key and a.resolved_at is null)
    returning 1
  ) select count(*) into k from ins; n := n + k;
  update console.alerts a set resolved_at = now()
   where a.kind = 'drop' and a.resolved_at is null
     and not exists (select 1 from console.mv_page_gsc_28d g
                      where a.dedupe_key = 'drop:' || g.brand_id || ':' || g.page_slug
                        and g.clicks_prev_28d >= 20 and g.clicks_28d <= g.clicks_prev_28d * 0.6);

  -- changes: one alert per brand per change day (last 3 days), never re-sent
  with cur as (
    select c.brand_id as brand_slug, c.change_date, count(*) as cnt, count(distinct c.page_fp) as pages,
           'changes:' || c.brand_id || ':' || c.change_date as key
      from public.seo_page_change_log c
     where c.field in ('title','h1','meta_description','http_status') and c.change_date >= current_date - 3
     group by 1, 2
  ), ins as (
    insert into console.alerts (brand_slug, kind, severity, title, body, link, dedupe_key)
    select c.brand_slug, 'changes', 'info', 'มีการแก้ไขหน้าเว็บ ' || c.pages || ' หน้า',
           c.cnt || ' การเปลี่ยนแปลง (title / H1 / meta / HTTP) วันที่ ' || to_char(c.change_date, 'YYYY-MM-DD'),
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
    select c.brand_slug, 'impact', 'info', 'วัดผลงานได้แล้ว: ' || left(c.title, 80),
           'ผล: ' || coalesce(c.status, '-') || coalesce(' · คลิก ' || round(c.pct_clicks) || '%', ''),
           '/actions', 'impact:' || c.id
      from cur c
     where not exists (select 1 from console.alerts a where a.dedupe_key = 'impact:' || c.id)
    returning 1
  ) select count(*) into k from ins; n := n + k;

  return n;
end $$;
revoke all on function console.generate_alerts() from public, anon, authenticated;

-- assigned: instant, personal (skip self-assignment)
create function console.alert_on_assign() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.assignee is not null and new.assignee is distinct from auth.uid()
     and (tg_op = 'INSERT' or new.assignee is distinct from old.assignee) then
    insert into console.alerts (brand_slug, kind, severity, title, link, dedupe_key, recipient)
    values (new.brand_slug, 'assigned', 'info', 'คุณได้รับมอบหมายงาน: ' || left(coalesce(new.title, new.action_key, ''), 80),
            '/actions', 'assigned:' || new.id || ':' || extract(epoch from now()), new.assignee);
  end if;
  return null;
end $$;
create trigger actions_alert_assign after insert or update of assignee on console.actions
  for each row execute function console.alert_on_assign();

select cron.schedule('kameie-generate-alerts', '0 1 * * *', 'select console.generate_alerts()');

-- ── read API (last 60 days; unread = newer than the caller's seen_at)
create view console_api.alerts as
select a.id, a.brand_slug, a.kind, a.severity, a.title, a.body, a.link, a.created_at, a.resolved_at,
       (a.recipient is not null) as personal,
       a.created_at > coalesce((select s.seen_at from console.alert_seen s where s.user_id = auth.uid()), '-infinity') as unread
  from console.alerts a
 where a.brand_slug in (select console.readable_brands())
   and (a.recipient is null or a.recipient = auth.uid())
   and a.created_at > now() - interval '60 days';
revoke all on console_api.alerts from public, anon;
grant select on console_api.alerts to authenticated;

select console.generate_alerts();

commit;

-- Verify (read-only): select kind, severity, count(*), count(*) filter (where resolved_at is null) open from console.alerts group by 1,2;
-- Mark all read (client): upsert into console.alert_seen (user_id, seen_at) values (auth.uid(), now()) on conflict (user_id).
