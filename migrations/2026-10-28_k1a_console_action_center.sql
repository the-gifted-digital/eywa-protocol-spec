-- K1a · Kameie Action Center: triage state over the existing priority engine + manual tasks (DRAFT, not applied) · 2026-10-28
-- Kameie Phase 2. Run after K0a–K0f.
-- Design: no new generator. public.v_page_priority (daily, scored, one suggested_action per page) IS the system's
-- recommendation feed. console.actions only stores what people DO with it — status, assignee, note, due date —
-- plus manual tasks a specialist adds. A recommendation with no row here is implicitly 'open'.
-- Closed loop: when an action is marked done, console_api.actions shows the first detected page change on/after
-- done_at with its before/after GSC deltas from public.v_page_change_impact (status 'pending' until 28d pass).
-- Run in the Supabase SQL editor as one transaction.

begin;

-- ── who may write for a brand: platform admin, or workspace_admin / seo_specialist / webmaster of a workspace
--    that contains the brand (viewers read only)
create function console.writable_brands() returns setof text
language sql stable security definer set search_path = '' as $$
  select b.brand_slug from public.brands b where console.is_platform_admin()
  union
  select wb.brand_slug
    from console.workspace_brands wb
    join console.workspace_members m on m.workspace_id = wb.workspace_id
   where m.user_id = auth.uid() and m.role in ('workspace_admin','seo_specialist','webmaster')
$$;
revoke all on function console.writable_brands() from public, anon;
grant execute on function console.writable_brands() to authenticated, service_role;

-- ── triage state + manual tasks
create table console.actions (
  id          uuid primary key default gen_random_uuid(),
  brand_slug  text not null references public.brands(brand_slug) on update cascade,
  source      text not null check (source in ('priority','manual')),
  page_code   text,                -- seo_website_page_master.page_fingerprint (v_page_priority.page_fingerprint)
  action_key  text,                -- priority: v_page_priority.suggested_action; manual: null
  title       text,                -- manual: required; priority: null (taken from the feed)
  status      text not null default 'open' check (status in ('open','in_progress','done','dismissed')),
  assignee    uuid references auth.users(id) on delete set null,
  note        text,
  due_date    date,
  created_by  uuid references auth.users(id) on delete set null default auth.uid(),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  done_at     timestamptz,
  done_by     uuid references auth.users(id) on delete set null,
  constraint actions_priority_uq unique (brand_slug, page_code, action_key),   -- upsert target (manual rows have nulls → distinct)
  constraint actions_shape check (
    (source = 'priority' and page_code is not null and action_key is not null)
 or (source = 'manual'   and title is not null and length(trim(title)) > 0))
);
create index actions_brand_status_idx on console.actions (brand_slug, status);

create table console.action_events (
  id         bigint generated always as identity primary key,
  action_id  uuid not null references console.actions(id) on delete cascade,
  actor      uuid references auth.users(id) on delete set null,
  event      text not null,          -- created | status | assignee | note | due_date
  old_value  text,
  new_value  text,
  at         timestamptz not null default now()
);
create index action_events_action_idx on console.action_events (action_id, at);

-- stamps + audit trail (one function, both timings)
create function console.actions_audit() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    new.created_by := coalesce(new.created_by, auth.uid());
    if new.status = 'done' then new.done_at := now(); new.done_by := auth.uid(); end if;
    return new;
  end if;
  -- UPDATE
  new.updated_at := now();
  new.created_by := old.created_by; new.created_at := old.created_at;            -- immutable
  new.brand_slug := old.brand_slug; new.source := old.source;
  new.page_code := old.page_code;   new.action_key := old.action_key;
  if new.status is distinct from old.status then
    if new.status = 'done' then new.done_at := now(); new.done_by := auth.uid();
    else new.done_at := null; new.done_by := null; end if;
  end if;
  return new;
end $$;

create function console.actions_log() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    insert into console.action_events (action_id, actor, event, new_value) values (new.id, auth.uid(), 'created', new.status);
    return null;
  end if;
  if new.status   is distinct from old.status   then insert into console.action_events (action_id, actor, event, old_value, new_value) values (new.id, auth.uid(), 'status',   old.status, new.status); end if;
  if new.assignee is distinct from old.assignee then insert into console.action_events (action_id, actor, event, old_value, new_value) values (new.id, auth.uid(), 'assignee', old.assignee::text, new.assignee::text); end if;
  if new.note     is distinct from old.note     then insert into console.action_events (action_id, actor, event, old_value, new_value) values (new.id, auth.uid(), 'note',     left(old.note, 200), left(new.note, 200)); end if;
  if new.due_date is distinct from old.due_date then insert into console.action_events (action_id, actor, event, old_value, new_value) values (new.id, auth.uid(), 'due_date', old.due_date::text, new.due_date::text); end if;
  return null;
end $$;

create trigger actions_audit before insert or update on console.actions for each row execute function console.actions_audit();
create trigger actions_log   after  insert or update on console.actions for each row execute function console.actions_log();

alter table console.actions       enable row level security;
alter table console.action_events enable row level security;

create policy act_select on console.actions for select to authenticated
  using (brand_slug in (select console.readable_brands()));
create policy act_insert on console.actions for insert to authenticated
  with check (brand_slug in (select console.writable_brands()));
create policy act_update on console.actions for update to authenticated
  using (brand_slug in (select console.writable_brands()))
  with check (brand_slug in (select console.writable_brands()));
create policy act_delete on console.actions for delete to authenticated            -- manual tasks only
  using (source = 'manual' and brand_slug in (select console.writable_brands()));

create policy ae_select on console.action_events for select to authenticated
  using (exists (select 1 from console.actions a where a.id = action_id and a.brand_slug in (select console.readable_brands())));

grant select, insert, update, delete on console.actions to authenticated;
grant select on console.action_events to authenticated;
grant all on console.actions, console.action_events to service_role;

-- ── read API
create view console_api.actions as
with page as (
  select p.brand_id, p.page_fingerprint as page_code, p.fingerprint as page_fp, p.slug, p.page_name, p.page_type
    from public.seo_website_page_master p
   where p.brand_id in (select console.readable_brands())
), feed as (                     -- system recommendations (+ their triage state, if any)
  select a.id as action_id, v.brand_id as brand_slug, 'priority'::text as source,
         v.page_fingerprint as page_code, v.suggested_action as title, v.score, v.top_signals, v.refreshed_at,
         a.status, a.assignee, a.note, a.due_date, a.created_at, a.updated_at, a.done_at, a.done_by
    from public.v_page_priority v
    left join console.actions a
      on a.brand_slug = v.brand_id and a.page_code = v.page_fingerprint and a.action_key = v.suggested_action
   where v.brand_id in (select console.readable_brands())
), kept as (                     -- triaged rows whose recommendation has since changed/disappeared (history stays visible)
  select a.id, a.brand_slug, a.source, a.page_code, coalesce(a.title, a.action_key), null::numeric, null::text[], null::timestamptz,
         a.status, a.assignee, a.note, a.due_date, a.created_at, a.updated_at, a.done_at, a.done_by
    from console.actions a
   where a.brand_slug in (select console.readable_brands())
     and (a.source = 'manual'
          or not exists (select 1 from public.v_page_priority v
                          where v.brand_id = a.brand_slug and v.page_fingerprint = a.page_code and v.suggested_action = a.action_key))
), allx as (
  select * from feed union all select * from kept
)
select x.action_id,
       x.brand_slug,
       x.source,
       x.page_code,
       pg.page_fp,
       pg.slug,
       pg.page_name,
       pg.page_type,
       x.title,
       x.score,
       x.top_signals,
       case
         when x.title ilike 'add internal links%' or x.title ilike 'fix landing UX%' then 'webmaster'
         when x.source = 'manual' then null
         else 'seo_specialist'
       end                                         as role_hint,
       coalesce(x.status, 'open')                  as status,
       x.assignee,
       u.email                                     as assignee_email,
       x.note,
       x.due_date,
       x.created_at, x.updated_at, x.done_at,
       g.clicks_28d, g.clicks_prev_28d, g.impressions_28d, g.position_28d,
       imp.change_date                             as impact_change_date,
       imp.status                                  as impact_status,       -- pending until 28d after the change
       imp.confidence                              as impact_confidence,
       imp.d_clicks                                as impact_d_clicks,
       imp.pct_clicks                              as impact_pct_clicks,
       imp.d_pos                                   as impact_d_pos,
       x.refreshed_at                              as feed_refreshed_at
  from allx x
  left join page pg on pg.brand_id = x.brand_slug and pg.page_code = x.page_code
  left join auth.users u on u.id = x.assignee
  left join console.mv_page_gsc_28d g on g.brand_id = x.brand_slug and g.page_slug = pg.slug
  left join lateral (
    select i.change_date, i.status, i.confidence, i.d_clicks, i.pct_clicks, i.d_pos
      from public.v_page_change_impact i
     where x.done_at is not null and i.page_fp = pg.page_fp and i.change_date >= x.done_at::date - 1
     order by i.change_date
     limit 1
  ) imp on true;

create view console_api.action_events as
select e.id, e.action_id, e.event, e.old_value, e.new_value, e.at, e.actor, u.email as actor_email
  from console.action_events e
  join console.actions a on a.id = e.action_id
  left join auth.users u on u.id = e.actor
 where a.brand_slug in (select console.readable_brands());

-- assignable people for a brand: members of any workspace holding it (for the assignee picker)
create view console_api.brand_people as
select distinct wb.brand_slug, m.user_id, u.email, m.role
  from console.workspace_brands wb
  join console.workspace_members m on m.workspace_id = wb.workspace_id
  join auth.users u on u.id = m.user_id
 where wb.brand_slug in (select console.readable_brands());

revoke all on console_api.actions, console_api.action_events, console_api.brand_people from public, anon;
grant select on console_api.actions, console_api.action_events, console_api.brand_people to authenticated;

commit;

-- Verify (read-only):
-- select brand_slug, status, count(*) from console_api.actions group by 1,2;   -- as service role: 0 rows (no auth.uid) — test via the app
-- select count(*) from public.v_page_priority where brand_id in ('vth-biodent','vitalsleep-clinic');  -- feed size (288 on 2026-10-28)
