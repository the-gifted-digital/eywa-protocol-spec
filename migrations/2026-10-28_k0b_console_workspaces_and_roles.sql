-- K0b · Kameie console: workspaces, members, roles, brand scoping (DRAFT, not applied) · 2026-10-28
-- Kameie Phase 0, step 2 of 3. Run after K0a.
-- Model:
--   platform_admins  : super-admins (operator) — create workspaces, assign brands, manage anyone
--   workspaces       : tenant (first one: "VT Intelligence")
--   workspace_members: user × workspace × role (workspace_admin | seo_specialist | webmaster | viewer)
--   workspace_brands : which brands (brands.brand_slug — the key every seo_* table uses as brand_id) a workspace sees
-- Brand assignment is platform-admin only; workspace_admin manages people inside their workspace.
-- console.* tables are written by the Kameie UI under RLS; seo_* base tables stay service_role-only (K0a).
-- Run in the Supabase SQL editor as one transaction.

begin;

create schema console;
revoke all on schema console from public, anon;
grant usage on schema console to authenticated, service_role;

create table console.platform_admins (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table console.workspaces (
  id         uuid primary key default gen_random_uuid(),
  slug       text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  name       text not null,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);

create table console.workspace_members (
  workspace_id uuid not null references console.workspaces(id) on delete cascade,
  user_id      uuid not null references auth.users(id) on delete cascade,
  role         text not null check (role in ('workspace_admin','seo_specialist','webmaster','viewer')),
  created_at   timestamptz not null default now(),
  added_by     uuid references auth.users(id) on delete set null,
  primary key (workspace_id, user_id)
);
create index workspace_members_user_idx on console.workspace_members (user_id);

create table console.workspace_brands (
  workspace_id uuid not null references console.workspaces(id) on delete cascade,
  brand_slug   text not null references public.brands(brand_slug) on update cascade,
  added_at     timestamptz not null default now(),
  primary key (workspace_id, brand_slug)
);

-- helpers: security definer so policies can read membership without recursing into RLS
create function console.is_platform_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from console.platform_admins where user_id = auth.uid())
$$;

create function console.workspace_role(p_workspace uuid) returns text
language sql stable security definer set search_path = '' as $$
  select role from console.workspace_members where workspace_id = p_workspace and user_id = auth.uid()
$$;

create function console.readable_brands() returns setof text
language sql stable security definer set search_path = '' as $$
  select b.brand_slug from public.brands b where console.is_platform_admin()
  union
  select wb.brand_slug
    from console.workspace_brands wb
    join console.workspace_members m on m.workspace_id = wb.workspace_id
   where m.user_id = auth.uid()
$$;

revoke all on function console.is_platform_admin(), console.workspace_role(uuid), console.readable_brands() from public, anon;
grant execute on function console.is_platform_admin(), console.workspace_role(uuid), console.readable_brands() to authenticated, service_role;

alter table console.platform_admins   enable row level security;
alter table console.workspaces        enable row level security;
alter table console.workspace_members enable row level security;
alter table console.workspace_brands  enable row level security;

-- platform_admins: read-only from the app (bootstrap via SQL editor / service_role)
create policy pa_select on console.platform_admins for select to authenticated
  using (user_id = auth.uid() or console.is_platform_admin());

-- workspaces: members see theirs; platform admin creates/deletes; workspace_admin may rename
create policy ws_select on console.workspaces for select to authenticated
  using (console.is_platform_admin() or console.workspace_role(id) is not null);
create policy ws_insert on console.workspaces for insert to authenticated
  with check (console.is_platform_admin());
create policy ws_update on console.workspaces for update to authenticated
  using (console.is_platform_admin() or console.workspace_role(id) = 'workspace_admin')
  with check (console.is_platform_admin() or console.workspace_role(id) = 'workspace_admin');
create policy ws_delete on console.workspaces for delete to authenticated
  using (console.is_platform_admin());

-- members: co-members see each other; platform admin or workspace_admin manage
-- ponytail: no "keep at least one workspace_admin" guard — add a trigger if admins start locking themselves out
create policy wm_select on console.workspace_members for select to authenticated
  using (console.is_platform_admin() or console.workspace_role(workspace_id) is not null);
create policy wm_write on console.workspace_members for all to authenticated
  using (console.is_platform_admin() or console.workspace_role(workspace_id) = 'workspace_admin')
  with check (console.is_platform_admin() or console.workspace_role(workspace_id) = 'workspace_admin');

-- brands in a workspace: members read; platform admin only writes
create policy wb_select on console.workspace_brands for select to authenticated
  using (console.is_platform_admin() or console.workspace_role(workspace_id) is not null);
create policy wb_write on console.workspace_brands for all to authenticated
  using (console.is_platform_admin()) with check (console.is_platform_admin());

grant select on console.platform_admins to authenticated;
grant select, insert, update, delete on console.workspaces, console.workspace_members, console.workspace_brands to authenticated;
grant all on all tables in schema console to service_role;

-- first workspace (brands are added once the user confirms the list)
insert into console.workspaces (slug, name) values ('vt-intelligence', 'VT Intelligence');

commit;

-- Bootstrap after the operator's first sign-in to Kameie (replace the email):
-- insert into console.platform_admins (user_id) select id from auth.users where email = '<operator email>';
-- Add brands to VT Intelligence:
-- insert into console.workspace_brands (workspace_id, brand_slug)
-- select w.id, b from console.workspaces w, unnest(array['vth-biodent','vitalsleep-and-wellness']) b where w.slug = 'vt-intelligence';
