// Nightly live-page crawler: node crawl.mjs --brand <brand_id> [--dry-run] [--limit N]
import { createClient } from '@supabase/supabase-js';
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';
import { extractFields } from './extract.mjs';
import { decide } from './diff.mjs';
import { loadTargets, loadStates, saveResult, saveLinks } from './db.mjs';

const SUPABASE_URL = 'https://lffcbeszjqzioobqfdav.supabase.co';
const UA = 'EYWA-PageHistory/1.0 (+https://eywaintelligence.com)';
const TIMEOUT_MS = 20000;
const SAVE_EVERY = 100;
const here = dirname(fileURLToPath(import.meta.url));

function fail(url, http_status, error) {
  console.warn(`fetch fail ${url}: ${error}`); // visible so a parse bug isn't mistaken for a network failure
  return { kind: 'fail', http_status, error };
}

// merged: a Merged page checked only for its redirect: unconditional GET, body not parsed, no links.
export async function fetchPage(url, prev, { timeoutMs = TIMEOUT_MS, ua = UA, cfg = {}, merged = false } = {}) {
  const headers = { 'user-agent': ua, accept: 'text/html,application/xhtml+xml' };
  // Conditional GET only against a healthy previous observation of this exact url.
  if (!merged && prev && prev.url === url && prev.last_ok_at && prev.consecutive_failures === 0 &&
      prev.http_status >= 200 && prev.http_status <= 299) {
    if (prev.etag) headers['if-none-match'] = prev.etag;
    if (prev.last_modified) headers['if-modified-since'] = prev.last_modified;
  }
  try {
    const res = await fetch(url, { headers, redirect: 'follow', signal: AbortSignal.timeout(timeoutMs) });
    if (res.status === 304) return { kind: 'not_modified', http_status: 304 };
    if (res.status < 200 || res.status > 299) { await res.body?.cancel(); return fail(url, res.status, `HTTP ${res.status}`); }
    const meta = { kind: 'ok', http_status: res.status, final_url: res.url,
      etag: res.headers.get('etag'), last_modified: res.headers.get('last-modified') };
    if (merged) { await res.body?.cancel(); return { ...meta, fields: {}, links: null }; }
    const { links, ...fields } = extractFields(await res.text(), cfg, res.url);
    // links: null = don't touch stored links (non-HTML body)
    return { ...meta, fields, links: /html/i.test(res.headers.get('content-type') ?? '') ? links : null };
  } catch (e) {
    return fail(url, null, e?.name === 'TimeoutError' ? 'timeout' : String(e?.cause?.code ?? e?.message ?? e));
  }
}

const readJson = (p) => (existsSync(p) ? JSON.parse(readFileSync(p, 'utf8')) : {});
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const excluded = (url, paths) => { try { const p = new URL(url).pathname; return paths.some((x) => p.startsWith(x)); } catch { return false; } };

function parseArgs(argv) {
  const a = { brand: null, dry: argv.includes('--dry-run'), limit: Infinity, brandsDir: join(here, 'brands') };
  const b = argv.indexOf('--brands-dir'); if (b >= 0) a.brandsDir = resolve(argv[b + 1]); // test hook
  const i = argv.indexOf('--brand'); if (i >= 0) a.brand = argv[i + 1];
  const l = argv.indexOf('--limit'); if (l >= 0) a.limit = Number(argv[l + 1]);
  return a;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.brand || args.brand.startsWith('--') || !(args.limit > 0)) {
    console.error('usage: node crawl.mjs --brand <brand_id> [--dry-run] [--limit N]'); process.exit(1);
  }
  let cfg;
  try {
    cfg = { ...readJson(join(here, 'brands/_default.json')), ...readJson(join(args.brandsDir, `${args.brand}.json`)) };
    extractFields('<html><body></body></html>', cfg); // surfaces a bad selector before any IO
  } catch (e) { console.error(`config error for brand ${args.brand}: ${e.message}`); process.exit(1); }

  const key = process.env.SUPABASE_SERVICE_KEY;
  if (!key) { console.error('\n⚠️  No SUPABASE_SERVICE_KEY. Load .secrets/supabase.env first.\n'); process.exit(1); }

  const db = createClient(SUPABASE_URL, key);
  const runId = `${args.brand}-${new Date().toISOString()}`;
  const runStartedAt = new Date().toISOString();
  const summary = { checked: 0, ok: 0, not_modified: 0, failed: 0, log_rows: 0, merged: 0, link_pages: 0, link_rows: 0, link_errors: 0 };
  let log = []; let states = [];
  const flush = async () => {
    if (!args.dry) await saveResult(db, { log, states });
    log = []; states = [];
  };

  try {
    const targets = (await loadTargets(db, args.brand)).filter((t) => !excluded(t.url, cfg.exclude_paths ?? [])).slice(0, args.limit);
    const prevStates = await loadStates(db, args.brand);
    for (const t of targets) {
      const prev = prevStates.get(t.page_fp) ?? null;
      const obs = await fetchPage(t.url, prev, { cfg, merged: !!t.merged });
      const r = decide(prev, obs, t.url, new Date(), runId, { page_fp: t.page_fp, brand_id: t.brand_id, merged: !!t.merged });
      if (t.merged) summary.merged++;
      if (obs.links) {
        summary.link_pages++; summary.link_rows += obs.links.length;
        if (args.dry) console.log(JSON.stringify({ links: t.page_fp, url: t.url, total: obs.links.length, in_main: obs.links.filter((l) => l.in_main).length }));
        // A links failure must not stop the change log: warn, count, keep crawling.
        else await saveLinks(db, t.page_fp, t.brand_id, obs.links, runStartedAt).catch((e) => { summary.link_errors++; console.warn(`links: ${e.message}`); });
      }
      log.push(...r.log); states.push(r.state);
      summary.checked++; summary.log_rows += r.log.length;
      summary[obs.kind === 'ok' ? 'ok' : obs.kind === 'fail' ? 'failed' : 'not_modified']++;
      if (args.dry) for (const row of r.log) console.log(JSON.stringify(row));
      if (states.length >= SAVE_EVERY) await flush();
      await sleep(1000 / (cfg.rps || 2));
    }
    await flush();
  } catch (e) {
    console.error(`run aborted: ${e.message}`); console.log(JSON.stringify(summary)); process.exit(1);
  }
  console.log(JSON.stringify(summary));
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
