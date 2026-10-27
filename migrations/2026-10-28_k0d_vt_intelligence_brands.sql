-- K0d · VT Intelligence workspace: first brands (DRAFT, not applied) · 2026-10-28
-- User-confirmed: vth-biodent + vitalsleep-clinic (not vitalsleep-and-wellness — the pages live under vitalsleep-clinic).
-- More brands later: add slugs to the array and re-run (idempotent).

insert into console.workspace_brands (workspace_id, brand_slug)
select w.id, b
  from console.workspaces w, unnest(array['vth-biodent', 'vitalsleep-clinic']) as b
 where w.slug = 'vt-intelligence'
on conflict do nothing; -- 2 rows
