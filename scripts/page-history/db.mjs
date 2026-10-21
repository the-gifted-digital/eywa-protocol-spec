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
    out.push(...rows);
    if (rows.length < PAGE) return out;
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

// Order matters: log first, state second. If the log insert fails we must not advance state,
// or the change would never be re-detected.
export async function saveResult(db, { log = [], states = [] }) {
  for (let i = 0; i < log.length; i += CHUNK) must(await db.from('seo_page_change_log').insert(log.slice(i, i + CHUNK)));
  for (let i = 0; i < states.length; i += CHUNK)
    must(await db.from('seo_page_live_state').upsert(states.slice(i, i + CHUNK), { onConflict: 'page_fp' }));
}
