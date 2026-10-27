-- K0e · console_api.workspace_brands — scope the Portfolio to the selected workspace (DRAFT, not applied) · 2026-10-28
-- Why: console_api.brands returns every brand the user may read; a platform admin may read all 19, so the
-- Portfolio showed brands outside "VT Intelligence". The UI joins brands to this view by the chosen workspace_id.
-- Rows: (workspace, brand) pairs the caller can see — members see their workspaces, platform admin sees all.

begin;

create view console_api.workspace_brands as
select wb.workspace_id, wb.brand_slug, wb.added_at
  from console.workspace_brands wb
 where console.is_platform_admin() or console.workspace_role(wb.workspace_id) is not null;

revoke all on console_api.workspace_brands from public, anon;
grant select on console_api.workspace_brands to authenticated;

commit;
