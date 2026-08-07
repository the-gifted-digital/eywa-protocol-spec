// harvest-entity-codes.mjs — read the clinical identifiers off each entity's VERIFIED Wikidata item
// and write them into the subtype row that owns that fact. Writes nothing without --apply.
//
//   npm run harvest:entity-codes              # report only
//   npm run harvest:entity-codes -- --apply   # fill the empty columns
//
// WHY THIS EXISTS: ICD-10-CM, ICD-11, MeSH, UMLS and SNOMED are all already sitting on the Wikidata
// item as sourced statements (P4229, P7329/P7807, P486, P2892, P5806). Once verify-entity-ids.mjs
// has proved the Q-id points at the right concept, those codes can be copied rather than looked up
// by hand — which is the difference between a sourced identifier and a plausible-looking guess.
// This is why the Q-id has to be verified FIRST: every code here inherits that item's correctness.
//
// NEVER OVERWRITES. A stored value wins, always — VTH's conditions were resolved against ICD-10-CM
// in Phase F with a clinician in the loop, and Wikidata is a wiki. Where the two disagree the row is
// printed as a conflict for a human and left exactly as it was.
//
// Routing follows the same one-store-per-fact rule as the rest of the graph: conditions and symptoms
// own ICD, anatomy owns FMA/UBERON, lab tests own LOINC, and a table without the column simply does
// not receive that fact.

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://lffcbeszjqzioobqfdav.supabase.co';
const KEY = process.env.SUPABASE_SERVICE_KEY;
if (!KEY) { console.error('\n⚠️  No SUPABASE_SERVICE_KEY. Load .secrets/supabase.env first.\n'); process.exit(1); }
const db = createClient(SUPABASE_URL, KEY);

const APPLY = process.argv.includes('--apply');
const API = 'https://www.wikidata.org/w/api.php';
const UA = 'eywa-vth-biodent/1.0 (entity code harvest; contact: naphannop.n@gmail.com)';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function api(params) {
  const url = `${API}?${new URLSearchParams({ ...params, format: 'json', origin: '*' })}`;
  for (let attempt = 1; attempt <= 3; attempt++) {
    const res = await fetch(url, { headers: { 'User-Agent': UA } });
    if (res.ok) return res.json();
    if (res.status === 429 || res.status >= 500) { await sleep(attempt * 2000); continue; }
    throw new Error(`wikidata ${res.status}: ${await res.text()}`);
  }
  throw new Error('wikidata: still failing after 3 attempts');
}

const val = (claims, prop) => {
  const c = claims?.[prop]?.find((x) => x.mainsnak?.datavalue?.value);
  const v = c?.mainsnak?.datavalue?.value;
  return typeof v === 'string' ? v : null;
};
const allVals = (claims, prop) =>
  (claims?.[prop] ?? []).map((x) => x.mainsnak?.datavalue?.value).filter((v) => typeof v === 'string');

// Which subtype table owns which fact. A fact with no column here is not stored — it is not lost,
// it is simply not ours to keep in that shape.
const ROUTES = {
  condition: { table: 'seo_entity_condition', map: {
    icd10_code: (c) => val(c, 'P494'), icd10_cm_code: (c) => val(c, 'P4229'),
    icd11_code: (c) => val(c, 'P7329') ?? val(c, 'P7807'),
    mesh_id: (c) => val(c, 'P486'), umls_cui: (c) => val(c, 'P2892'),
    snomed_ct_id: (c) => val(c, 'P5806'), wikidata_qid: (_c, qid) => qid,
  } },
  symptom: { table: 'seo_entity_symptom', map: {
    icd10_code: (c) => val(c, 'P4229') ?? val(c, 'P494'),
    icd11_code: (c) => val(c, 'P7329') ?? val(c, 'P7807'),
    mesh_id: (c) => val(c, 'P486'), umls_cui: (c) => val(c, 'P2892'),
    snomed_ct_id: (c) => val(c, 'P5806'), wikidata_qid: (_c, qid) => qid,
  } },
  anatomy: { table: 'seo_entity_anatomy', map: {
    fma_id: (c) => val(c, 'P1402'), uberon_id: (c) => val(c, 'P1554'),
    mesh_id: (c) => val(c, 'P486'), wikidata_qid: (_c, qid) => qid,
  } },
  lab_test: { table: 'seo_entity_lab_test', map: {
    loinc_code: (c) => val(c, 'P4338'), mesh_id: (c) => val(c, 'P486'),
    snomed_ct_id: (c) => val(c, 'P5806'), wikidata_qid: (_c, qid) => qid,
  } },
  drug: { table: 'seo_entity_drug', map: {
    rxnorm_code: (c) => val(c, 'P3345'), atc_code: (c) => val(c, 'P267'),
    mesh_id: (c) => val(c, 'P486'), wikidata_qid: (_c, qid) => qid,
  } },
  organization: { table: 'seo_entity_organization', map: { wikidata_qid: (_c, qid) => qid } },
};

// ── load every entity that carries a verified Q-id ───────────────────────────
const rows = [];
for (let from = 0; ; from += 1000) {
  const { data, error } = await db.from('seo_entity_graph')
    .select('entity_fingerprint, entity_name, entity_type, wikidata_id')
    .not('wikidata_id', 'is', null).range(from, from + 999);
  if (error) { console.error(error); process.exit(1); }
  rows.push(...data);
  if (data.length < 1000) break;
}
const inScope = rows.filter((r) => ROUTES[r.entity_type]);
console.log(`${rows.length} entities carry a Q-id · ${inScope.length} have a subtype table that can hold codes\n`);

// ── pull the claims ──────────────────────────────────────────────────────────
const claimsById = {};
for (let i = 0; i < inScope.length; i += 40) {
  const chunk = inScope.slice(i, i + 40);
  const j = await api({ action: 'wbgetentities', ids: chunk.map((c) => c.wikidata_id).join('|'), props: 'claims' });
  for (const [qid, ent] of Object.entries(j.entities ?? {})) claimsById[qid] = ent.claims ?? {};
  await sleep(300);
}

// ── load what we already store, so nothing is overwritten ────────────────────
const existing = {};
for (const [type, { table, map }] of Object.entries(ROUTES)) {
  const cols = ['entity_fp', ...Object.keys(map)].join(', ');
  const { data, error } = await db.from(table).select(cols);
  if (error) { console.error(`${table}: ${error.message}`); continue; }
  existing[table] = new Map(data.map((d) => [d.entity_fp, d]));
}

const fills = [];        // { table, fp, patch, filled: [col] }
const conflicts = [];    // stored value disagrees with Wikidata
for (const e of inScope) {
  const { table, map } = ROUTES[e.entity_type];
  const claims = claimsById[e.wikidata_id];
  if (!claims) continue;
  const have = existing[table]?.get(e.entity_fingerprint) ?? null;
  const patch = {}, filled = [];
  for (const [col, get] of Object.entries(map)) {
    const fresh = get(claims, e.wikidata_id);
    if (!fresh) continue;
    const stored = have?.[col] ?? null;
    // We store FMA/UBERON with their namespace prefix ("FMA:54832"); Wikidata stores the bare id.
    // Same fact, different notation — not a conflict.
    const same = (a, b) => String(a).trim().replace(/^(FMA|UBERON|SNOMEDCT|MESH):/i, '') === String(b).trim().replace(/^(FMA|UBERON|SNOMEDCT|MESH):/i, '');
    if (stored == null) { patch[col] = fresh; filled.push(col); }
    else if (!same(stored, fresh)) {
      conflicts.push({ fp: e.entity_fingerprint, name: e.entity_name, col, stored, wikidata: fresh, qid: e.wikidata_id });
    }
  }
  // ICD-10 related codes are a list on Wikidata; keep the extras beside the primary where the column exists.
  if (e.entity_type === 'condition') {
    const related = [...new Set([...allVals(claims, 'P494'), ...allVals(claims, 'P4229')])];
    const primary = new Set([patch.icd10_code ?? have?.icd10_code, patch.icd10_cm_code ?? have?.icd10_cm_code].filter(Boolean));
    const extra = related.filter((r) => !primary.has(r));
    const merged = [...new Set([...(have?.icd10_codes_related ?? []), ...extra])];
    if (extra.length && merged.length !== (have?.icd10_codes_related ?? []).length) { patch.icd10_codes_related = merged; filled.push('icd10_codes_related'); }
  }
  if (filled.length) fills.push({ table, fp: e.entity_fingerprint, name: e.entity_name, patch, filled, hasRow: !!have });
}

// ── report ───────────────────────────────────────────────────────────────────
const byTable = {};
for (const f of fills) (byTable[f.table] ??= []).push(f);
for (const [t, list] of Object.entries(byTable)) {
  const cols = {};
  for (const f of list) for (const c of f.filled) cols[c] = (cols[c] ?? 0) + 1;
  console.log(`${t}: ${list.length} rows to fill — ${Object.entries(cols).map(([c, n]) => `${c} ${n}`).join(' · ')}`);
}
console.log(`\n⚠️  ${conflicts.length} conflicts (stored value kept, Wikidata differs):`);
for (const c of conflicts) console.log(`  ${c.fp.padEnd(32)} ${c.col.padEnd(16)} ours=${String(c.stored).padEnd(12)} wikidata=${c.wikidata}  (${c.qid})`);

if (!APPLY) { console.log('\n(report only — re-run with --apply to write)\n'); process.exit(0); }

let wrote = 0, made = 0;
for (const f of fills) {
  if (f.hasRow) {
    const { error } = await db.from(f.table).update({ ...f.patch, updated_at: new Date().toISOString() }).eq('entity_fp', f.fp);
    if (error) { console.error(f.fp, error.message); continue; }
  } else {
    const { error } = await db.from(f.table).insert({ entity_fp: f.fp, ...f.patch });
    if (error) { console.error(f.fp, error.message); continue; }
    made++;
  }
  wrote++;
}
console.log(`\n✅ ${wrote} rows written (${made} subtype rows created) · ${conflicts.length} conflicts left untouched.`);
