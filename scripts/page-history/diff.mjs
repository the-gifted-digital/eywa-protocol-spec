// Pure diff rules: one live-page observation -> change-log rows + next state. No IO.
import { createHash } from 'node:crypto';

export const FAIL_THRESHOLD = 3;

const TEXT_FIELDS = ['title', 'meta_description', 'h1', 'canonical', 'robots', 'content_hash'];
const sorted = (a) => (Array.isArray(a) ? [...a].sort() : a ?? null);
// DB column is int: fetch_error is stored as 0 in state, logged as 'fetch_error'.
const logStatus = (v) => (v === 0 ? 'fetch_error' : v ?? null);
const same = (a, b) => JSON.stringify(a ?? null) === JSON.stringify(b ?? null);

// Deterministic log id: the same transition re-detected (overlapping or re-run crawl) gets the same id,
// so INSERT ... ON CONFLICT (id) DO NOTHING drops it. UUIDv5-shaped (version 5, RFC 4122 variant).
export function logId(page_fp, field, prev_ok_at, old_value, new_value) {
  const h = createHash('sha256')
    .update(`${page_fp}|${field}|${prev_ok_at}|${JSON.stringify(old_value)}|${JSON.stringify(new_value)}`)
    .digest('hex').slice(0, 32).split('');
  h[12] = '5';
  h[16] = ((parseInt(h[16], 16) & 0x3) | 0x8).toString(16);
  const x = h.join('');
  return `${x.slice(0, 8)}-${x.slice(8, 12)}-${x.slice(12, 16)}-${x.slice(16, 20)}-${x.slice(20)}`;
}

// ids: {page_fp, brand_id} for the target; only needed when prev is null (defaults to prev's).
// ids.merged: a Merged page crawled to verify its redirect; only http_status / final_url are tracked.
export function decide(prev, obs, targetUrl, now, runId, ids = {}) {
  const at = now.toISOString();
  const wasOk = !!prev?.last_ok_at;
  const page_fp = ids.page_fp ?? prev?.page_fp;
  const brand_id = ids.brand_id ?? prev?.brand_id;
  const log = [];
  const prev_ok_at = prev?.last_ok_at ?? null;
  const row = (field, old_value = null, new_value = null) =>
    log.push({ id: logId(page_fp, field, prev_ok_at, old_value, new_value), page_fp, brand_id, field,
      old_value, new_value, detected_at: at, prev_ok_at, run_id: runId });

  const state = {
    page_fp, brand_id,
    url: targetUrl, http_status: null, final_url: null, title: null, meta_description: null, h1: null,
    canonical: null, robots: null, schema_types: null, content_hash: null, etag: null, last_modified: null,
    first_seen_at: null, last_ok_at: null, consecutive_failures: 0,
    ...prev, page_fp, brand_id, url: targetUrl, last_checked_at: at,
    schema_types: prev?.schema_types ? [...prev.schema_types] : null,
  };

  // Rule 1 (only once the page has been OK before; never-OK pages have no history to change).
  if (wasOk && prev.url !== targetUrl) row('url', prev.url, targetUrl);

  if (obs.kind === 'fail') {
    state.consecutive_failures = (prev?.consecutive_failures ?? 0) + 1;
    if (state.consecutive_failures === FAIL_THRESHOLD && wasOk) {
      const v = obs.http_status ?? 0;
      if (!same(logStatus(prev.http_status), logStatus(v))) row('http_status', logStatus(prev.http_status), logStatus(v));
      state.http_status = v;
    }
    return { log, state };
  }

  if (obs.kind === 'not_modified' && !wasOk) return { log, state }; // never-OK: stay a baseline candidate
  state.consecutive_failures = 0;
  state.last_ok_at = at;
  if (obs.kind === 'not_modified') return { log, state };

  const f = ids.merged ? {} : obs.fields; // merged: content fields stay null, never logged
  if (wasOk) {
    if (!same(prev.http_status, obs.http_status)) row('http_status', logStatus(prev.http_status), obs.http_status);
    if (!same(prev.final_url, obs.final_url)) row('final_url', prev.final_url, obs.final_url);
    if (!ids.merged) {
      for (const k of TEXT_FIELDS) if (!same(prev[k], f[k])) row(k, prev[k], f[k]);
      if (!same(sorted(prev.schema_types), sorted(f.schema_types))) row('schema_types', sorted(prev.schema_types), sorted(f.schema_types));
    }
  }
  Object.assign(state, {
    http_status: obs.http_status, final_url: obs.final_url, etag: obs.etag, last_modified: obs.last_modified,
    schema_types: sorted(f.schema_types), first_seen_at: prev?.first_seen_at ?? at, // first OK observation; stays null while a page only fails
    
  });
  for (const k of TEXT_FIELDS) state[k] = f[k] ?? null;
  return { log, state };
}
