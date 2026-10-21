import { normUrl } from './normalize.mjs';

const CHUNK = 200;
const PAGE = 1000; // supabase-js default row cap

const must = ({ data, error }) => {
  if (error) throw new Error(error.message ?? String(error)); // supabase-js returns errors, it does not throw
  return data;
};

async function selectAll(build) {
  const out = [];
  for (let from = 0; ; from += PAGE) {
    const rows = must(await build().range(from, from + PAGE - 1));
    if (!rows.length) return out; // loop until an empty page; don't trust the server's row cap
    out.push(...rows);
  }
}

export async function loadTargets(db, brandId) {
  const rows = await selectAll(() => db.from('seo_website_page_master')
    .select('fingerprint, brand_id, canonical_url').eq('brand_id', brandId).eq('status', 'Live')
    .not('canonical_url', 'is', null).order('fingerprint'));
  const seen = new Map(); const out = [];
  for (const r of rows) {
    const k = normUrl(r.canonical_url);
    if (seen.has(k)) { console.warn(`url collision: ${r.fingerprint} (${r.canonical_url}) duplicates ${seen.get(k)}; keeping first`); continue; }
    seen.set(k, r.fingerprint);
    out.push({ page_fp: r.fingerprint, brand_id: r.brand_id, url: r.canonical_url });
  }
  return out;
}

export async function loadStates(db, brandId) {
  const rows = await selectAll(() => db.from('seo_page_live_state').select('*').eq('brand_id', brandId).order('page_fp'));
  return new Map(rows.map((r) => [r.page_fp, r]));
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// One retry after a wait; the final error names the page and step.
async function step(label, wait, fn) {
  try { must(await fn()); } catch {
    await wait(2000);
    try { must(await fn()); } catch (e) { throw new Error(`${label}: ${e.message}`); }
  }
}

// Each changed page: its log rows in ONE insert (atomic), then its state upsert, so a failure can only
// leave a page "logged but state stale" for at most the one page that failed; a page whose log insert
// failed never has its state advanced (so the change is re-detected next run).
export async function saveResult(db, { log = [], states = [] }, { wait = sleep } = {}) {
  const byPage = new Map();
  for (const r of log) (byPage.get(r.page_fp) ?? byPage.set(r.page_fp, []).get(r.page_fp)).push(r);
  const stateOf = new Map(states.map((s) => [s.page_fp, s]));
  for (const [fp, rows] of byPage) {
    await step(`${fp} log insert`, wait, () => db.from('seo_page_change_log').insert(rows));
    const st = stateOf.get(fp);
    if (st) await step(`${fp} state upsert`, wait, () => db.from('seo_page_live_state').upsert([st], { onConflict: 'page_fp' }));
    stateOf.delete(fp);
  }
  const rest = [...stateOf.values()];
  for (let i = 0; i < rest.length; i += CHUNK)
    await step('batch state upsert', wait, () => db.from('seo_page_live_state').upsert(rest.slice(i, i + CHUNK), { onConflict: 'page_fp' }));
}
