-- K0f · console_api.workspace_members — member list with email for the Workspace admin screen (DRAFT, not applied) · 2026-10-28
-- auth.users is not readable by the client; this view exposes only email + sign-in state of people who share a
-- workspace with the caller (platform admin: everyone in every workspace). Role changes / removals still go
-- through console.workspace_members under RLS; inviting new people goes through the `invite-member` edge function.

begin;

create view console_api.workspace_members as
select m.workspace_id,
       m.user_id,
       u.email,
       m.role,
       m.created_at,
       u.last_sign_in_at,
       (u.email_confirmed_at is null) as invite_pending
  from console.workspace_members m
  join auth.users u on u.id = m.user_id
 where console.is_platform_admin() or console.workspace_role(m.workspace_id) is not null;

revoke all on console_api.workspace_members from public, anon;
grant select on console_api.workspace_members to authenticated;

commit;
