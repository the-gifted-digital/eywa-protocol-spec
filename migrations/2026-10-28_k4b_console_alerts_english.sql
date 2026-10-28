-- K4b · Kameie alerts: English titles (applied 2026-10-28) · 2026-10-28
-- Owner switched the console UI to English. Same functions as K4a with English text, plus a one-off rewrite of the
-- titles/bodies already generated (56 rows on 2026-10-28). No schema change, no rows deleted.
-- Run in the Supabase SQL editor as one transaction.

begin;

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
create or replace function console.alert_on_assign() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.assignee is not null and new.assignee is distinct from auth.uid()
     and (tg_op = 'INSERT' or new.assignee is distinct from old.assignee) then
    insert into console.alerts (brand_slug, kind, severity, title, link, dedupe_key, recipient)
    values (new.brand_slug, 'assigned', 'info', 'Assigned to you: ' || left(coalesce(new.title, new.action_key, ''), 80),
            '/actions', 'assigned:' || new.id || ':' || extract(epoch from now()), new.assignee);
  end if;
  return null;
end $$;

-- existing rows
update console.alerts set title = case split_part(dedupe_key, ':', 3)
    when 'http_error' then 'HTTP error' when 'unreachable' then 'Unreachable'
    when 'redirect_missing' then 'Redirect missing' when 'redirect_wrong_target' then 'Redirect to wrong page'
    when 'noindex' then 'noindex on a live page' else 'Live page redirects' end
    || ': ' || substring(title from position(': ' in title) + 2)
 where kind = 'health';

update console.alerts
   set title = regexp_replace(title, '^คลิกลดลง ', 'Clicks down '),
       body  = replace(body, ' คลิก (28 วัน)', ' clicks (28 days)')
 where kind = 'drop';

update console.alerts
   set title = regexp_replace(title, '^มีการแก้ไขหน้าเว็บ ([0-9]+) หน้า$', '\1 pages edited'),
       body  = replace(replace(body, ' การเปลี่ยนแปลง ', ' changes '), ' วันที่ ', ' on ')
 where kind = 'changes';
update console.alerts set title = '1 page edited' where kind = 'changes' and title = '1 pages edited';

update console.alerts set title = replace(title, 'วัดผลงานได้แล้ว: ', 'Impact measured: '),
                          body = replace(replace(body, 'ผล: ', 'Result: '), ' · คลิก ', ' · clicks ')
 where kind = 'impact';
update console.alerts set title = replace(title, 'คุณได้รับมอบหมายงาน: ', 'Assigned to you: ') where kind = 'assigned';

commit;

-- Verify (read-only): select kind, title, body from console.alerts order by id limit 20;
--   expect no Thai in title/body except page slugs.
