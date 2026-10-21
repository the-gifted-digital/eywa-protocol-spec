// Local validation for the DR-076 migration in Postgres-in-WASM (PGlite).
// Stubs the prod objects the migration depends on, applies the migration twice
// (idempotency), runs the self-test and checks it ends with 'ALL PASS'.
// Usage: npm install && node run.mjs
import { PGlite } from '@electric-sql/pglite';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const here = (p) => fileURLToPath(new URL(p, import.meta.url));
const MIGRATION = here('../../2026-10-21_eywa_w12_01_dr076_page_change_history.sql');
const SELFTEST = here('../2026-10-21_w12_01_page_change_history.test.sql');
const FIXTURE = here('../../../scripts/page-history/fixtures/url-cases.json');

// Minimal stand-ins for prod (Supabase GTGT). Only the columns the migration
// and the self-test touch. Default privileges mimic Supabase, which grants
// table privileges to the API roles, so the REVOKE is actually exercised.
const STUBS = `
create role anon; create role authenticated; create role service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
create table seo_website_page_master (
  id uuid primary key default gen_random_uuid(),
  fingerprint text unique not null default ('page_' || substr(md5(random()::text), 1, 16)),
  page_fingerprint text not null unique, fingerprint_display_name text not null,
  brand_id text, status text, canonical_url text, slug text
);
create table seo_gsc_query_daily (
  brand_id text not null, snapshot_date date not null, search_type text, query text not null, page_url text not null,
  page_slug text, clicks int, impressions int, ctr numeric, position numeric,
  loaded_at timestamptz default now(), query_norm text
);`;

const db = new PGlite();
const notices = [];
const onNotice = (n) => notices.push(n.message);
let failed = false;
const step = async (name, fn) => {
  try { await fn(); console.log(`ok   ${name}`); }
  catch (e) { failed = true; console.log(`FAIL ${name}: ${e.message}`); }
};

await step('stubs', () => db.exec(STUBS));
await step('migration (1st run)', () => db.exec(readFileSync(MIGRATION, 'utf8')));
await step('migration (2nd run, idempotent)', () => db.exec(readFileSync(MIGRATION, 'utf8')));
await step('fixture matches seo_norm_url', async () => {
  for (const c of JSON.parse(readFileSync(FIXTURE, 'utf8'))) {
    const { rows } = await db.query('select seo_norm_url($1) as out', [c.in]);
    if (rows[0].out !== c.out) throw new Error(`${c.in} -> ${rows[0].out}, want ${c.out}`);
  }
});
await step('self-test', async () => {
  try { await db.exec(readFileSync(SELFTEST, 'utf8'), { onNotice }); }
  catch (e) { await db.exec('rollback'); throw e; }
});
await step("self-test raised 'ALL PASS'", async () => {
  if (!notices.includes('ALL PASS')) throw new Error(`notices: ${JSON.stringify(notices)}`);
});
await step('self-test rolled back', async () => {
  const { rows } = await db.query('select count(*)::int n from seo_page_change_log');
  if (rows[0].n !== 0) throw new Error(`${rows[0].n} rows left`);
});

console.log(failed ? 'RESULT: FAIL' : 'RESULT: PASS');
process.exit(failed ? 1 : 0);
