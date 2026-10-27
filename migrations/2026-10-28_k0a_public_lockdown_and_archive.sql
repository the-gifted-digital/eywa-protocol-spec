-- K0a · Public-schema lockdown + backup tables to `archive` (DRAFT, not applied) · 2026-10-28
-- Kameie Phase 0, step 1 of 3. Prerequisite for any team login (Kameie console).
-- Findings (survey 2026-10-28, project GTGT):
--   1. 15 views/MVs in public run as owner (security definer) and are SELECT-able by `anon` — anyone holding the
--      anon key can read them through PostgREST, RLS of the base tables does not apply. Includes v_tsa_bond_enriched
--      and v_tsa_call_freshness (pseudonymous visitor/call data → PDPA).
--   2. 254 backup / scratch tables (`_ss_*`, `_vth_*`, `bak_*`, `*_bak_*`, `*_backup_*`, `*ssbak*`) sit in public,
--      no RLS, readable by anon. No view or function depends on them; no script reads them.
--   3. seo_service_prices, seo_payer_schemes: live, no RLS, readable by anon.
--   4. Every seo_*/brands/logs table carries `eywa_authenticated_full_access` = FOR ALL USING (true):
--      any future logged-in user could edit/delete everything. auth.users = 0 today, so dropping them breaks nobody.
-- Who uses the API today (edge logs, 24h): service_role only (scripts, n8n, edge functions) + one anon GET on
-- seo_branches (already RLS-blocked) + rpc/tsa_ingest_calls (function — not touched here). service_role bypasses
-- RLS and keeps all grants, so pipelines are unaffected.
-- Run in the Supabase SQL editor as one transaction.

begin;

-- 1 · views + MVs: no direct access for anon/authenticated (service_role / postgres unchanged)
do $$
declare r record;
begin
  for r in
    select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'public' and c.relkind in ('v','m')
  loop
    execute format('revoke all on public.%I from anon, authenticated', r.relname);
  end loop;
end $$;

-- 2 · backup / scratch tables → schema archive (moved, not deleted; postgres/service_role still read them via SQL)
create schema if not exists archive;
revoke all on schema archive from public, anon, authenticated;

do $$
declare r record; n int := 0;
begin
  for r in
    select c.relname from pg_class c join pg_namespace ns on ns.oid = c.relnamespace
     where ns.nspname = 'public' and c.relkind = 'r'
       and (   c.relname like '\_%'
            or c.relname like 'bak\_%'
            or c.relname ~ '(_bak|bak_|_backup|ssbak|_dr0\d+bak|w39bak)'
            or c.relname = 'ss_kw_seed_wave16_20260806')
  loop
    execute format('alter table public.%I set schema archive', r.relname);
    execute format('revoke all on archive.%I from anon, authenticated', r.relname);
    n := n + 1;
  end loop;
  raise notice 'K0a: moved % tables to archive', n;
  if n < 254 or n > 280 then
    raise exception 'K0a: expected ~254 tables, got % — stop and re-check the pattern', n;
  end if;
end $$;

-- 3 · the two live tables without RLS
alter table public.seo_service_prices enable row level security;
alter table public.seo_payer_schemes  enable row level security;
revoke all on public.seo_service_prices, public.seo_payer_schemes from anon, authenticated;

-- 4 · drop the blanket "authenticated can do anything" policies (RLS stays ON → deny for anon/authenticated)
do $$
declare r record; n int := 0;
begin
  for r in
    select tablename, policyname from pg_policies
     where schemaname = 'public'
       and policyname in ('eywa_authenticated_full_access', 'authenticated_full_access')
       and qual = 'true'
  loop
    execute format('drop policy %I on public.%I', r.policyname, r.tablename);
    n := n + 1;
  end loop;
  raise notice 'K0a: dropped % blanket policies', n; -- ~50 expected
end $$;

-- 5 · future tables/views in public: no automatic grants to anon/authenticated
--     (the console reads only through schema console_api; pipelines use service_role)
alter default privileges for role postgres in schema public revoke all on tables from anon, authenticated;

-- 6 · legacy dashboard RPCs (security definer → bypass RLS) callable by anon; no caller in the 24h edge logs.
--     tsa_ingest_calls stays callable: it is the call-ingest endpoint used by the Tsaheylu edge function.
do $$
declare r record;
begin
  for r in
    select p.oid::regprocedure as sig from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.prosecdef and p.proname like 'get\_%'
  loop
    execute format('revoke execute on function %s from public, anon, authenticated', r.sig);
  end loop;
end $$;

commit;

-- Verify (read-only, after commit):
-- select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace
--  where n.nspname='public' and c.relkind in ('r','v','m','p') and has_table_privilege('anon', c.oid, 'SELECT')
--    and (c.relkind <> 'r' or not c.relrowsecurity);                                   -- expect 0
-- select count(*) from pg_policies where schemaname='public' and qual='true';          -- expect 0
-- select count(*) from pg_tables where schemaname='archive';                           -- expect ~254
