// verify-entity-ids.mjs — check every Wikidata Q-id we store against Wikidata itself, and propose
// ids for the entities that have none. Writes nothing without --apply.
//
//   npm run verify:entity-ids              # report only
//   npm run verify:entity-ids -- --apply   # write the verified + confidently matched ids back
//   npm run verify:entity-ids -- --all     # every entity, not just the ones VTH pages use
//
// WHY THIS EXISTS: a Q-number is four characters of plausible-looking text. Nothing in the schema
// stops "Q4797646" from being wrong, and a wrong sameAs is worse than no sameAs — it tells Google
// and every LLM that this page is about a different thing. So: every stored id gets fetched and
// its label compared, and every proposed id must clear a label match, not a search ranking.
//
// The match rule is deliberately strict. wbsearchentities will happily return something for any
// string; accepting its top hit is how you end up telling the world your bruxism page is about a
// Brazilian footballer. A candidate is accepted only when the normalised English label equals the
// normalised entity name (after stripping our parenthetical glosses), or equals one of the item's
// aliases. Everything else is printed for a human and left alone.

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://lffcbeszjqzioobqfdav.supabase.co';
const KEY = process.env.SUPABASE_SERVICE_KEY;
if (!KEY) {
  console.error('\n⚠️  No SUPABASE_SERVICE_KEY. Load .secrets/supabase.env first.\n');
  process.exit(1);
}
const db = createClient(SUPABASE_URL, KEY);

const APPLY = process.argv.includes('--apply');
const ALL = process.argv.includes('--all');
const API = 'https://www.wikidata.org/w/api.php';
const UA = 'eywa-vth-biodent/1.0 (entity id verification; contact: naphannop.n@gmail.com)';

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

// "Dental Caries (Tooth Decay)" → ["dental caries", "tooth decay"]; the gloss in brackets is often
// the term Wikidata actually uses as its label, so both halves are legitimate match candidates.
//
// But a fragment is also how you match the wrong thing: "MBM Bruxism Evaluation" reduced to "MBM"
// hits meat and bone meal, "…(TMJ)" hits Termez Airport, "Denture (umbrella)" hits Umbrella. So a
// variant is only usable if it is at least two words or a long single word — acronyms and generic
// one-worders are dropped, and the medical-identifier gate below catches whatever slips past.
const norm = (s) => (s ?? '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
const usableVariant = (v) => v.split(' ').length >= 2 || v.length >= 9;
function nameVariants(name) {
  const out = new Set();
  const bare = name.replace(/\s*\([^)]*\)/g, '').trim();
  out.add(norm(bare));
  for (const m of name.matchAll(/\(([^)]*)\)/g)) if (m[1]) out.add(norm(m[1]));
  out.add(norm(name));
  return [...out].filter(Boolean);
}
const searchVariants = (name) => nameVariants(name).filter(usableVariant);

// A real medical item on Wikidata carries at least one medical identifier. Requiring one is the
// cheapest way to reject a plausible-looking label that belongs to an airport or a video game.
const MEDICAL_PROPS = ['P494', 'P4229', 'P7807', 'P486', 'P2892', 'P5806', 'P1550', 'P667', 'P672', 'P3345'];
const MEDICAL_TYPES = new Set(['condition', 'symptom', 'procedure', 'treatment', 'drug', 'anatomy', 'lab_test']);

// Reviewed by a human on 2026-08-07 and kept: our name is a qualified or synonymous form of the same
// concept, which the mechanical label rule cannot see ("Deep Cleaning (Scaling & Root Planing)" →
// "scaling and root planing", MAD → "Mandibular advancement splint", ceramic implant → zirconia).
// Ten others were cut in the same pass for pointing at a broader or different concept; they are gone
// from the table, so absence here is not approval — it just means nothing was decided.
const ADJUDICATED_KEEP = new Set([
  'arthrocentesis', 'buteyko', 'ceramic-implant-system', 'deep-cleaning', 'dental-phobia',
  'diagnostic-ultrasound', 'dry-needling', 'frenectomy-adult', 'mad', 'mouth-taping',
  'nasal-obstruction', 'nitrous-oxide', 'prf-technology', 'remineralization', 'sedation-dentistry',
  'senior-dental', 'sleep-hygiene', 'tongue-posture', 'tongue-thrust', 'zygomatic-system',
]);

/** Fetch labels, aliases and sitelinks for up to 50 Q-ids at a time. */
async function getEntities(ids) {
  const out = {};
  for (let i = 0; i < ids.length; i += 50) {
    const chunk = ids.slice(i, i + 50);
    const j = await api({
      action: 'wbgetentities', ids: chunk.join('|'),
      props: 'labels|aliases|sitelinks|descriptions|claims', languages: 'en|th', sitefilter: 'enwiki|thwiki',
    });
    Object.assign(out, j.entities ?? {});
    await sleep(300);
  }
  return out;
}

async function search(term) {
  const j = await api({ action: 'wbsearchentities', search: term, language: 'en', uselang: 'en', limit: 8, type: 'item' });
  return j.search ?? [];
}

const wikiUrl = (ent) =>
  ent?.sitelinks?.enwiki?.title ? `https://en.wikipedia.org/wiki/${encodeURIComponent(ent.sitelinks.enwiki.title.replace(/ /g, '_'))}` : null;

// ── load the entities in scope ───────────────────────────────────────────────
let scope;
if (ALL) {
  const { data, error } = await db.from('seo_entity_graph')
    .select('entity_fingerprint, entity_name, entity_type, wikidata_id, wikipedia_url');
  if (error) { console.error(error); process.exit(1); }
  scope = data;
} else {
  const { data: pages, error: pe } = await db.from('seo_website_page_master')
    .select('primary_entity_fp').eq('brand_name', 'VTH BioDent').neq('status', 'Merged').not('primary_entity_fp', 'is', null);
  if (pe) { console.error(pe); process.exit(1); }
  const used = [...new Set(pages.map((p) => p.primary_entity_fp))];
  const rows = [];
  for (let i = 0; i < used.length; i += 200) {
    const { data, error } = await db.from('seo_entity_graph')
      .select('entity_fingerprint, entity_name, entity_type, wikidata_id, wikipedia_url')
      .in('entity_fingerprint', used.slice(i, i + 200));
    if (error) { console.error(error); process.exit(1); }
    rows.push(...data);
  }
  scope = rows;
}

console.log(`scope: ${scope.length} entities · ${scope.filter((e) => e.wikidata_id).length} already carry a Q-id\n`);

// ── 1. verify what we already store ──────────────────────────────────────────
const stored = scope.filter((e) => e.wikidata_id);
const fetched = stored.length ? await getEntities(stored.map((e) => e.wikidata_id)) : {};

const confirmed = [], mismatched = [], missing = [], reviewed = [];
for (const e of stored) {
  const ent = fetched[e.wikidata_id];
  if (!ent || ent.missing !== undefined) { missing.push({ ...e, why: 'Q-id does not exist on Wikidata' }); continue; }
  const label = ent.labels?.en?.value ?? '';
  const aliases = (ent.aliases?.en ?? []).map((a) => a.value);
  const targets = new Set([norm(label), ...aliases.map(norm)]);
  const hit = nameVariants(e.entity_name).some((v) => targets.has(v));
  const hasMedicalId = MEDICAL_PROPS.some((prop) => ent.claims?.[prop]?.length);
  const row = { ...e, label, desc: ent.descriptions?.en?.value ?? '', wiki: wikiUrl(ent) };
  if (ADJUDICATED_KEEP.has(e.entity_fingerprint)) { reviewed.push(row); continue; }
  if (!hit) { mismatched.push(row); continue; }
  // Label agrees, but for a clinical entity the item must also be clinical on Wikidata's own terms.
  if (MEDICAL_TYPES.has(e.entity_type) && !hasMedicalId) { row.why = 'no medical identifier on the item'; mismatched.push(row); continue; }
  confirmed.push(row);
}

// ── 2. propose ids for the entities that have none ───────────────────────────
// Only entity types where a Wikidata item is a meaningful sameAs. Brand programmes and marketing
// concepts have no encyclopaedic counterpart, and forcing one is how you get a wrong link.
// 'specialty' is included: orthodontics and periodontics are encyclopaedic concepts with real items.
// 'concept', 'technology', 'product' and 'person' are NOT: those are VTH's own programme names
// (MBM, BFB, PNCL), vendor product names, and staff — nothing in an encyclopaedia corresponds, and
// forcing a match is how the inflammation programme ended up pointing at Persona 4.
const PROPOSABLE = new Set(['condition', 'symptom', 'procedure', 'treatment', 'drug', 'anatomy', 'device', 'lab_test', 'organization', 'specialty']);
const gaps = scope.filter((e) => !e.wikidata_id && PROPOSABLE.has(e.entity_type));

const proposed = [], ambiguous = [];
for (const e of gaps) {
  const variants = nameVariants(e.entity_name);
  const terms = searchVariants(e.entity_name);
  let pick = null;
  for (const term of terms) {
    const hits = await search(term);
    await sleep(250);
    if (!hits.length) continue;
    const exact = hits.find((h) => variants.includes(norm(h.label)) || (h.aliases ?? []).some((a) => variants.includes(norm(a))));
    if (exact) { pick = exact; break; }
  }
  if (pick) proposed.push({ ...e, qid: pick.id, label: pick.label, desc: pick.description ?? '' });
  else ambiguous.push({ ...e, why: terms.length ? 'no exact label match' : 'name too short/ambiguous to search' });
}

// Second gate: a clinical entity must map to an item Wikidata itself treats as clinical.
// Third gate: a Q-id may belong to exactly ONE entity. Two entities claiming the same item is a
// contradiction — either one is the narrower case or the pair are duplicates of each other — and
// shipping both means two pages telling Google they are the same thing.
const taken = new Map(scope.filter((e) => e.wikidata_id).map((e) => [e.wikidata_id, e.entity_fingerprint]));
const collided = [];
for (let i = proposed.length - 1; i >= 0; i--) {
  const p = proposed[i];
  const owner = taken.get(p.qid);
  if (owner && owner !== p.entity_fingerprint) { collided.push({ ...p, owner }); proposed.splice(i, 1); continue; }
  taken.set(p.qid, p.entity_fingerprint);
}

const proposedFull = proposed.length ? await getEntities(proposed.map((p) => p.qid)) : {};
const rejected = [];
for (let i = proposed.length - 1; i >= 0; i--) {
  const p = proposed[i];
  const claims = proposedFull[p.qid]?.claims ?? {};
  const hasMedicalId = MEDICAL_PROPS.some((prop) => claims[prop]?.length);
  if (MEDICAL_TYPES.has(p.entity_type) && !hasMedicalId) {
    rejected.push({ ...p, why: 'no medical identifier on the Wikidata item' });
    proposed.splice(i, 1);
    continue;
  }
  p.wiki = wikiUrl(proposedFull[p.qid]);
}

// ── report ───────────────────────────────────────────────────────────────────
const line = (r) => `  ${r.entity_fingerprint.padEnd(34)} ${(r.wikidata_id ?? r.qid).padEnd(11)} ${r.label ?? ''}`;
console.log(`✅ confirmed        ${confirmed.length}`);
console.log(`👤 reviewed & kept  ${reviewed.length}  (human call 2026-08-07 — our name is a qualified form of the same concept)`);
console.log(`❌ label mismatch   ${mismatched.length}`); mismatched.forEach((r) => console.log(line(r) + `   ← we call it "${r.entity_name}"`));
console.log(`❌ Q-id not found   ${missing.length}`); missing.forEach((r) => console.log(line(r)));
console.log(`➕ proposed         ${proposed.length}`); proposed.forEach((r) => console.log(line(r) + `   (${r.desc})`));
console.log(`🔁 Q-id already used by another entity  ${collided.length}  (not written — one id, one entity)`);
collided.forEach((r) => console.log(line(r) + `   ← already on ${r.owner}`));
console.log(`🚫 label matched but not clinical  ${rejected.length}`);
rejected.forEach((r) => console.log(line(r) + `   ← "${r.desc}"`));
console.log(`🤷 no confident match ${ambiguous.length}  (left alone — needs a human)`);
if (ambiguous.length) console.log('  ' + ambiguous.map((a) => a.entity_fingerprint).join(', '));

if (!APPLY) { console.log('\n(report only — re-run with --apply to write)\n'); process.exit(0); }

// ── apply ────────────────────────────────────────────────────────────────────
// Only rows that cleared BOTH gates are written. A Q-id that points at nothing is cleared, because
// it can only be wrong. A label mismatch is NOT cleared automatically: most of them are our name
// being a qualified version of Wikidata's ("Buteyko Breathing Method" → "Buteyko method"), which is
// correct, while a few are genuinely the wrong target ("Pacemaker & Implanted Devices" → the
// pacemaker device itself). Telling those apart is a judgement call, so they are reported and left.
let wrote = 0;
for (const r of [...confirmed, ...reviewed, ...proposed]) {
  const patch = { wikidata_id: r.wikidata_id ?? r.qid, updated_at: new Date().toISOString() };
  if (r.wiki && !r.wikipedia_url) patch.wikipedia_url = r.wiki;
  const { error } = await db.from('seo_entity_graph').update(patch).eq('entity_fingerprint', r.entity_fingerprint);
  if (error) { console.error(r.entity_fingerprint, error.message); continue; }
  wrote++;
}
for (const r of missing) {
  const { error } = await db.from('seo_entity_graph')
    .update({ wikidata_id: null, wikipedia_url: null, updated_at: new Date().toISOString() })
    .eq('entity_fingerprint', r.entity_fingerprint);
  if (error) { console.error(r.entity_fingerprint, error.message); continue; }
  wrote++;
}
console.log(`\n✅ ${wrote} rows written · ${missing.length} cleared (Q-id did not exist) · ${mismatched.length} left for review.`);
