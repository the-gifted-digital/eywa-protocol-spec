// check-clinical.mjs — the committed contraindications bridge (src/data/entity-clinical.json) must
// never lag seo_entity_procedures/devices/drug, every Live service/procedure/diagnostic page whose
// primaryEntity is a procedure/treatment/device/drug should have a list, and the lists a brand's
// site actually renders must stay inside the protocol's size caps. Brand-agnostic port of
// eywa-vth-biodent/web/scripts/check-clinical.mjs (2026-09 original) — see the VTH original's
// DR-VTH-012 for why the bridge exists and why the legacy hand-typed YAML `contraindication:` array
// is dead (nothing renders it).
//
//   node check-clinical.mjs --brand <brand_id>
//   node check-clinical.mjs --brand <brand_id> --strict   coverage gaps (check 2) FAIL instead of WARN
//   node check-clinical.mjs --brand <brand_id> --no-yaml  legacy YAML copies (check 4) FAIL instead of WARN
//   node check-clinical.mjs --brand <brand_id> --self-test
//     injects one fake freshness diff + one fake duplicate-item quality fail into the real
//     in-memory results, then asserts that forces exit 1 — proof the gate bites, without touching
//     real data.
//   optional: --content <dir> (default src/content) --bridge <path> (default src/data/entity-clinical.json)
//             --collections <csv> (default service,procedure,diagnostic)
//
// Four checks:
//   1. freshness   (FAIL)  — buildClinicalMap() (live DB) must deep-equal the committed JSON. A
//                            bridge file that does not exist yet counts as empty, not as a reason
//                            to abort — the gate still reports it as a freshness FAIL, plus every
//                            other check below, rather than stopping before the verdict line.
//   2. coverage    (WARN, --strict → FAIL) — every Live service/procedure/diagnostic page whose
//                            primaryEntity is a procedure/treatment/device/drug must have >=1 item
//                            in the committed JSON.
//   3. quality     (WARN/FAIL) — per committed entity: >8 items warn, >15 FAIL (protocol cap);
//                            any item >220 chars warns; duplicate items (trimmed, exact) FAIL.
//   4. legacy YAML (WARN, --no-yaml → FAIL) — pages still carrying the old hand-typed
//                            `contraindication:` array; the bridge is what renders, not this.
//
// WHY THIS COPY DROPS THE `yaml` PACKAGE: this repo has no node_modules (same reason
// writer-brief/page-brief.mjs uses plain `fetch` instead of `@supabase/supabase-js`). scanYamlLite()
// below is a minimal line scanner, not a YAML parser — it reads exactly the three signals this gate
// needs (top-level `primaryEntity:`, top-level `published: false`, a top-level `contraindication:`
// block's item count) and nothing else. Real content has both zero-indent (`- item`) and indented
// (`  - item`) list styles under `contraindication:` — both count.
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs';
import { basename, join, relative } from 'node:path';
import assert from 'node:assert/strict';
import { buildClinicalMap, findKey } from './gen-entity-clinical.mjs';

const SUPABASE_URL = 'https://lffcbeszjqzioobqfdav.supabase.co';
const WARN_CAP = 8;
const HARD_CAP = 15;
const ITEM_LEN_WARN = 220;
const DIFF_CAP = 20;
const QUALIFYING_TYPES = new Set(['procedure', 'treatment', 'device', 'drug']);

// ── CLI ──────────────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
const enc = encodeURIComponent;
const flagValue = (name) => {
  const i = argv.indexOf(`--${name}`);
  return i !== -1 ? argv[i + 1] : undefined;
};
const BRAND = flagValue('brand');
const CONTENT_DIR = flagValue('content') || 'src/content';
const BRIDGE_PATH = flagValue('bridge') || 'src/data/entity-clinical.json';
const COLLECTIONS = (flagValue('collections') || 'service,procedure,diagnostic')
  .split(',').map((s) => s.trim()).filter(Boolean);
const STRICT = argv.includes('--strict');
const NO_YAML = argv.includes('--no-yaml');
const SELF_TEST = argv.includes('--self-test');

if (!BRAND) {
  console.error(
    '\nusage: node check-clinical.mjs --brand <brand_id> [--content <dir>] [--bridge <path>]' +
    '\n       [--collections <csv>] [--strict] [--no-yaml] [--self-test]\n',
  );
  process.exit(2);
}

const KEY = findKey();
if (!KEY) {
  console.error('check:clinical — no SUPABASE_SERVICE_KEY. A gate that cannot run is not a gate that passed.');
  process.exit(2);
}
const headers = { apikey: KEY, Authorization: `Bearer ${KEY}` };

const walk = (dir) => readdirSync(dir).flatMap((e) => {
  const p = join(dir, e);
  return statSync(p).isDirectory() ? walk(p) : p.endsWith('.yaml') ? [p] : [];
});

// ── minimal line scanner (see header) ─────────────────────────────────────────
function scanYamlLite(raw) {
  const lines = raw.split('\n');
  let primaryEntity;
  let publishedFalse = false;
  let contraCount = 0;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (line.trim().startsWith('#')) continue;

    const peMatch = line.match(/^primaryEntity:\s*(.*)$/);
    if (peMatch) {
      const v = peMatch[1].trim().replace(/^['"]|['"]$/g, '');
      if (v) primaryEntity = v;
      continue;
    }
    if (/^published:\s*false\s*$/.test(line)) {
      publishedFalse = true;
      continue;
    }
    if (/^contraindication:\s*$/.test(line)) {
      let j = i + 1;
      for (; j < lines.length; j++) {
        const t = lines[j].trim();
        if (t === '' || t.startsWith('#')) continue;
        if (/^-\s/.test(t)) { contraCount++; continue; }
        break; // next top-level key (or unexpected content) ends the block
      }
      i = j - 1;
    }
  }
  return { primaryEntity, publishedFalse, contraCount };
}

let dbMap;
try {
  dbMap = await buildClinicalMap();
} catch (e) {
  console.error(`check:clinical — ${e.message}`);
  process.exit(2);
}

// A bridge that has never been generated is a freshness FAIL to report, not a reason to abort
// before the coverage/quality/legacy checks — a brand's very first run has no bridge file yet.
let committed;
let bridgeMissing = false;
try {
  committed = JSON.parse(readFileSync(BRIDGE_PATH, 'utf8'));
} catch (e) {
  if (e.code === 'ENOENT') {
    bridgeMissing = true;
    committed = {};
  } else {
    console.error(`check:clinical — ${e.message}`);
    process.exit(2);
  }
}

// ── check 1: freshness — committed JSON vs a fresh rebuild from the DB ───────────────────────
const freshnessDiffs = [];
if (bridgeMissing) freshnessDiffs.push(`bridge file missing at ${BRIDGE_PATH} — run gen-entity-clinical.mjs`);
{
  const keys = new Set([...Object.keys(dbMap), ...Object.keys(committed)]);
  for (const key of [...keys].sort()) {
    const have = committed[key];
    const want = dbMap[key];
    if (!want) { freshnessDiffs.push(`${key} · removed (committed has it, DB no longer does)`); continue; }
    if (!have) { freshnessDiffs.push(`${key} · added (DB has it, committed does not)`); continue; }
    if (have.table !== want.table || JSON.stringify(have.contraindications) !== JSON.stringify(want.contraindications)) {
      freshnessDiffs.push(`${key} · changed`);
    }
  }
}

// ── page_master: every slug this brand has Live ──────────────────────────────────────────────
const liveSlugs = new Set();
for (let offset = 0; ; offset += 1000) {
  const res = await fetch(
    `${SUPABASE_URL}/rest/v1/seo_website_page_master?select=slug&brand_id=eq.${enc(BRAND)}&status=eq.Live&limit=1000&offset=${offset}`,
    { headers },
  );
  if (!res.ok) { console.error(`check:clinical — page_master query failed: ${res.status}`); process.exit(2); }
  const page = await res.json();
  for (const r of page) if (r.slug) liveSlugs.add(r.slug);
  if (page.length < 1000) break;
}

// ── walk the configured collections once: check 2 candidates + check 4 legacy copies ─────────
const files = COLLECTIONS.flatMap((c) => {
  const dir = join(CONTENT_DIR, c);
  return existsSync(dir) ? walk(dir) : [];
});
const candidates = []; // {file, slug, primaryEntity} — Live, not demo/unpublished, has a primaryEntity
const legacy = [];     // {file, count} — non-empty hand-typed `contraindication:` array

for (const filePath of files) {
  const file = relative(CONTENT_DIR, filePath);
  const slug = basename(filePath, '.yaml');
  const raw = readFileSync(filePath, 'utf8');
  const { primaryEntity, publishedFalse, contraCount } = scanYamlLite(raw);

  if (slug === 'demo' || publishedFalse) continue;

  if (contraCount > 0) legacy.push({ file, count: contraCount });
  if (liveSlugs.has(slug) && primaryEntity) candidates.push({ file, slug, primaryEntity });
}

// entity_type for every candidate's primaryEntity, chunked for the URL length limit
const entityTypeOf = new Map();
{
  const fps = [...new Set(candidates.map((c) => c.primaryEntity))];
  const CHUNK = 150;
  for (let i = 0; i < fps.length; i += CHUNK) {
    const chunk = fps.slice(i, i + CHUNK);
    const res = await fetch(
      `${SUPABASE_URL}/rest/v1/seo_entity_graph?select=entity_fingerprint,entity_type&entity_fingerprint=in.(${chunk.map(enc).join(',')})`,
      { headers },
    );
    if (!res.ok) { console.error(`check:clinical — entity_graph query failed: ${res.status}`); process.exit(2); }
    for (const row of await res.json()) entityTypeOf.set(row.entity_fingerprint, row.entity_type);
  }
}

// ── check 2: coverage — Live page, qualifying entity_type, bridge must have >=1 item ─────────
const missing = [];
let liveCheckedCount = 0;
for (const c of candidates) {
  const type = entityTypeOf.get(c.primaryEntity);
  if (!QUALIFYING_TYPES.has(type)) continue;
  liveCheckedCount += 1;
  const entry = committed[c.primaryEntity];
  if (!entry || !entry.contraindications?.length) {
    missing.push(`MISSING ${c.slug} · primaryEntity=${c.primaryEntity} (${type})`);
  }
}

// ── check 3: quality — every entity already in the committed bridge ──────────────────────────
const qualityFails = [];
const qualityWarns = [];
for (const [fp, entry] of Object.entries(committed)) {
  const items = entry.contraindications ?? [];
  if (items.length > HARD_CAP) qualityFails.push(`${fp} · ${items.length} items (> ${HARD_CAP} hard cap)`);
  else if (items.length > WARN_CAP) qualityWarns.push(`${fp} · ${items.length} items (> ${WARN_CAP} warn cap)`);

  const seen = new Set();
  items.forEach((item, i) => {
    if (item.length > ITEM_LEN_WARN) qualityWarns.push(`${fp} · item ${i + 1} is ${item.length} chars (> ${ITEM_LEN_WARN})`);
    const t = item.trim();
    if (seen.has(t)) qualityFails.push(`${fp} · duplicate item: "${t.slice(0, 80)}${t.length > 80 ? '…' : ''}"`);
    seen.add(t);
  });
}

if (SELF_TEST) {
  freshnessDiffs.push('[self-test] fake-entity-fp · changed');
  qualityFails.push('[self-test] fake-entity-fp · duplicate item: "fake item"');
}

// ── print ──────────────────────────────────────────────────────────────────────────────────
freshnessDiffs.slice(0, DIFF_CAP).forEach((l) => console.error(`FAIL entity-clinical stale · ${l}`));
if (freshnessDiffs.length > DIFF_CAP) console.error(`FAIL entity-clinical stale · …and ${freshnessDiffs.length - DIFF_CAP} more`);
if (freshnessDiffs.length) console.error(`run: gen-entity-clinical.mjs --brand ${BRAND} && commit ${BRIDGE_PATH}`);

qualityFails.forEach((l) => console.error(`FAIL clinical-quality ${l}`));
qualityWarns.forEach((l) => console.log(`⚠ clinical-quality ${l}`));

missing.forEach((l) => console.log(l));

if (legacy.length) {
  console.log(`⚠ ${legacy.length} legacy YAML \`contraindication:\` cop${legacy.length === 1 ? 'y' : 'ies'} found (showing up to 10) — legacy copy: the bridge is what renders; delete once every page below has migrated`);
  legacy.slice(0, 10).forEach((l) => console.log(`  ${l.file} (${l.count} items)`));
}

const freshLabel = freshnessDiffs.length
  ? `bridge STALE (${freshnessDiffs.length} diff${freshnessDiffs.length === 1 ? '' : 's'})`
  : 'bridge fresh';
const missingLabel = `${missing.length} without a list${missing.length ? (STRICT ? ' (FAIL — --strict)' : ' (warn)') : ''}`;
const legacyLabel = `${legacy.length} legacy YAML copies${legacy.length ? (NO_YAML ? ' (FAIL — --no-yaml)' : ' (warn)') : ''}`;
console.log(`clinical: ${freshLabel} · ${liveCheckedCount} Live procedure pages checked · ${missingLabel} · ${legacyLabel} · ${qualityWarns.length} quality warnings`);

const hardFail = freshnessDiffs.length > 0
  || qualityFails.length > 0
  || (STRICT && missing.length > 0)
  || (NO_YAML && legacy.length > 0);
const exitCode = hardFail ? 1 : 0;

if (SELF_TEST) {
  assert.equal(exitCode, 1, 'self-test: the injected fake freshness diff + fake duplicate item must force exit 1');
  console.log('self-test: OK — fake freshness diff + fake duplicate item forced exit 1');
}
process.exit(exitCode);
