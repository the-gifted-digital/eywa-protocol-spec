// map-icd10-to-icd11.mjs — fill ICD-11 from ICD-10 using WHO's own published mapping table.
// Writes nothing without --apply.
//
//   npm run map:icd11              # report only
//   npm run map:icd11 -- --apply   # write the codes it can map
//
// WHY THIS EXISTS: harvest-entity-codes gets ICD-11 only where the Wikidata item happens to carry a
// P7329 statement, which covered 37 of our 125 conditions. WHO publishes the authoritative
// ICD-10 → ICD-11 MMS correspondence as a public file, so the rest can be derived from the ICD-10
// codes we already hold — a translation between two editions of the same classification, not a guess.
//
// The WHO ICD API itself needs OAuth credentials we do not have; this file needs none.
// Source: https://icdcdn.who.int/static/releasefiles/2024-01/mapping.zip → 10To11MapToOneCategory.txt
//
// CM → WHO: our conditions mostly store ICD-10-CM, the US clinical modification, which adds digits
// WHO ICD-10 does not have (K05.30 vs K05.3, K08.409 vs K08.4). The map is keyed on WHO codes, so a
// CM code is trimmed to its WHO parent and, failing that, to the three-character category. Each
// result records which rung matched, because a category-level hit is a coarser claim than an exact one.

import { createClient } from '@supabase/supabase-js';
import { execSync } from 'node:child_process';
import { readFileSync, existsSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const SUPABASE_URL = 'https://lffcbeszjqzioobqfdav.supabase.co';
const KEY = process.env.SUPABASE_SERVICE_KEY;
if (!KEY) { console.error('\n⚠️  No SUPABASE_SERVICE_KEY. Load .secrets/supabase.env first.\n'); process.exit(1); }
const db = createClient(SUPABASE_URL, KEY);
const APPLY = process.argv.includes('--apply');

const CACHE = join(process.env.TMPDIR || tmpdir(), 'who-icd-map');
const MAP_TXT = join(CACHE, '10To11MapToOneCategory.txt');
const ZIP_URL = 'https://icdcdn.who.int/static/releasefiles/2024-01/mapping.zip';

if (!existsSync(MAP_TXT)) {
  mkdirSync(CACHE, { recursive: true });
  console.log('downloading WHO mapping release…');
  execSync(`curl -sL -o "${CACHE}/mapping.zip" "${ZIP_URL}" && unzip -o -q "${CACHE}/mapping.zip" -d "${CACHE}"`, { stdio: 'inherit' });
}

// icd10Code → { code, title }, keeping the first (most specific) row for each key.
const map = new Map();
for (const line of readFileSync(MAP_TXT, 'utf8').split('\n').slice(1)) {
  const f = line.split('\t');
  const [icd10, icd11, title] = [f[2], f[9], f[11]];
  if (!icd10 || !icd11 || icd11 === 'No Mapping') continue;
  if (!map.has(icd10)) map.set(icd10, { code: icd11, title });
}
console.log(`WHO map: ${map.size} ICD-10 codes → ICD-11 MMS\n`);

/** Try the code as given, then its WHO parent, then the three-character category. */
function lookup(code) {
  if (!code) return null;
  const c = code.trim().toUpperCase();
  // The three-character category rung is deliberately absent. "G47 → Sleep-wake disorders,
  // unspecified" is true of insomnia, apnoea and bruxism alike; emitting it as this page's
  // diagnosis code would be a claim with no content.
  const rungs = [
    [c, 'exact'],
    [c.replace(/^([A-Z]\d{2})\.(\d).*$/, '$1.$2'), 'who-parent'],
  ];
  for (const [key, rung] of rungs) {
    const hit = map.get(key);
    if (hit) return { ...hit, via: rung, from: key };
  }
  return null;
}

const TARGETS = [
  { table: 'seo_entity_condition', cols: 'entity_fp, icd10_code, icd10_cm_code, icd11_code' },
  { table: 'seo_entity_symptom', cols: 'entity_fp, icd10_code, icd11_code' },
];

// An ICD-10 ".8 other specified" or ".9 unspecified" code maps to the ICD-11 residual bucket of its
// block. Those titles are the giveaway, and the result is either empty ("Abnormalities of breathing,
// unspecified" for snoring) or wrong ("Age-associated cognitive decline" for brain fog, "Tingling
// fingers or toes" for orofacial paresthesia). A residual code in schema markup asserts a diagnosis
// while carrying no diagnostic content, so it is rejected and reported instead.
const isResidual = (title) => /unspecified|other specified|not elsewhere classified/i.test(title ?? '');

// Reviewed 2026-08-07 and refused: the ICD-11 target is specific, but specific about the wrong
// thing. Both come from an ICD-10 ".8 other" code whose ICD-11 correspondence happens to land on a
// named condition rather than a residual bucket, so the residual filter cannot see them.
const REFUSED = new Map([
  ['brain-fog-oral', 'R41.8 lands on MB21.0 Age-associated cognitive decline; oral-origin brain fog is not an ageing diagnosis.'],
  ['orofacial-paresthesia', 'R20.2 lands on MB40.4 Tingling fingers or feet or toes — the wrong part of the body.'],
]);

const fills = [], unmapped = [], residual = [], refused = [];
for (const t of TARGETS) {
  const { data, error } = await db.from(t.table).select(t.cols).is('icd11_code', null);
  if (error) { console.error(`${t.table}: ${error.message}`); continue; }
  for (const row of data) {
    // Prefer the WHO code when we have one — it is the map's own key space. CM is the fallback.
    const hit = lookup(row.icd10_code) ?? lookup(row.icd10_cm_code);
    if (!hit) { if (row.icd10_code || row.icd10_cm_code) unmapped.push({ ...row, table: t.table }); continue; }
    const rec = { table: t.table, fp: row.entity_fp, from: hit.from, via: hit.via, icd11: hit.code, title: hit.title };
    if (REFUSED.has(row.entity_fp)) { refused.push({ ...rec, why: REFUSED.get(row.entity_fp) }); continue; }
    (isResidual(hit.title) ? residual : fills).push(rec);
  }
}

const byRung = fills.reduce((a, f) => ({ ...a, [f.via]: (a[f.via] ?? 0) + 1 }), {});
console.log(`mappable: ${fills.length}  (${Object.entries(byRung).map(([k, v]) => `${k} ${v}`).join(' · ')})`);
for (const f of fills) console.log(`  ${f.fp.padEnd(30)} ${f.from.padEnd(8)} → ${f.icd11.padEnd(9)} ${f.title}${f.via === 'category' ? '   ⚠️ category-level' : ''}`);
console.log(`\nrefused by review: ${refused.length}`);
for (const r of refused) console.log(`  ${r.fp.padEnd(30)} ${r.why}`);
console.log(`\nresidual, rejected: ${residual.length}  (ICD-11 target is an "unspecified" bucket — no diagnostic content)`);
for (const r of residual) console.log(`  ${r.fp.padEnd(30)} ${r.from.padEnd(8)} → ${r.icd11.padEnd(9)} ${r.title}`);
console.log(`\nno ICD-11 available: ${unmapped.length}` + (unmapped.length ? ` — ${unmapped.map((u) => u.entity_fp).join(', ')}` : ''));

if (!APPLY) { console.log('\n(report only — re-run with --apply to write)\n'); process.exit(0); }

let wrote = 0;
for (const f of fills) {
  const { error } = await db.from(f.table).update({ icd11_code: f.icd11, updated_at: new Date().toISOString() }).eq('entity_fp', f.fp);
  if (error) { console.error(f.fp, error.message); continue; }
  wrote++;
}
console.log(`\n✅ ${wrote} ICD-11 codes written from the WHO correspondence table.`);
