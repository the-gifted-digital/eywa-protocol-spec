// gen-entity-schema.mjs — export the identity of every entity a VTH page uses (ICD code, Wikidata,
// Wikipedia) as a static JSON the site inlines, so the page's @graph can say WHICH thing it is about
// and not just what it is called.
//
//   Output: src/data/entity-schema.json  →  { [entitySlug]: { code?, codingSystem?, sameAs?[] } }
//   npm run gen:entity-schema     (reads ../.secrets/supabase.env for the service key)
//
// WHY THIS EXISTS: "name" alone leaves an entity ambiguous. `code` + `sameAs` are what tie a page to
// ICD-10-CM and to the Wikidata/Wikipedia node for the same concept — the disambiguation signal both
// Google and retrieval-based models use to decide what a page is about. The identifiers were already
// in Supabase; nothing carried them to a rendered page.
//
// Same contract as gen-internal-links.mjs: the JSON is COMMITTED, the Astro build only reads it.
// Re-run after verify:entity-ids or any change to the identifier columns.
//
// ONE STORE PER FACT (the fork this repo keeps paying for): ICD lives on the subtype row —
// seo_entity_condition for conditions, seo_entity_symptom for symptoms — never on seo_entity_graph.
// Procedures and drugs deliberately carry NO ICD: the code that used to sit on them was the code of
// the condition they treat, which is a relationship, not this page's identity.

import { createClient } from '@supabase/supabase-js';
import { writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const OUT = resolve(HERE, '../src/data/entity-schema.json');
const SUPABASE_URL = 'https://lffcbeszjqzioobqfdav.supabase.co';
const KEY = process.env.SUPABASE_SERVICE_KEY || process.env.PUBLIC_SUPABASE_ANON_KEY;
if (!KEY) {
  console.error('\n⚠️  No key. Re-run with the SERVICE_ROLE key:\n    SUPABASE_SERVICE_KEY=<key> npm run gen:entity-schema\n');
  process.exit(1);
}
const db = createClient(SUPABASE_URL, KEY);

async function fetchAll(table, cols, apply = (q) => q) {
  const out = [];
  for (let from = 0; ; from += 1000) {
    const { data, error } = await apply(db.from(table).select(cols)).range(from, from + 999);
    if (error) throw new Error(`${table}: ${error.message}`);
    out.push(...data);
    if (data.length < 1000) break;
  }
  return out;
}

// Only entities VTH actually renders — no reason to ship the other brands' half of a shared table.
const pages = await fetchAll('seo_website_page_master', 'primary_entity_fp',
  (q) => q.eq('brand_id', 'vth-biodent').neq('status', 'Merged').not('primary_entity_fp', 'is', null));
const used = new Set(pages.map((p) => p.primary_entity_fp));

const entities = (await fetchAll('seo_entity_graph', 'entity_fingerprint, entity_name, wikidata_id, wikipedia_url'))
  .filter((e) => used.has(e.entity_fingerprint));
const conditions = await fetchAll('seo_entity_condition', 'entity_fp, icd10_code, icd10_cm_code');
const symptoms = await fetchAll('seo_entity_symptom', 'entity_fp, icd10_code');

const icd = new Map();
// ICD-10-CM is the more specific of the two and the one our conditions were resolved against in
// Phase F; fall back to the WHO code when no CM value exists.
for (const c of conditions) {
  const code = c.icd10_cm_code || c.icd10_code;
  if (code) icd.set(c.entity_fp, { code, system: c.icd10_cm_code ? 'ICD-10-CM' : 'ICD-10' });
}
for (const s of symptoms) if (s.icd10_code && !icd.has(s.entity_fp)) icd.set(s.entity_fp, { code: s.icd10_code, system: 'ICD-10' });

const out = {};
for (const e of entities) {
  const node = {};
  const c = icd.get(e.entity_fingerprint);
  if (c) { node.code = c.code; node.codingSystem = c.system; }
  const sameAs = [
    e.wikidata_id ? `https://www.wikidata.org/wiki/${e.wikidata_id}` : null,
    e.wikipedia_url || null,
  ].filter(Boolean);
  if (sameAs.length) node.sameAs = sameAs;
  if (Object.keys(node).length) out[e.entity_fingerprint] = node;
}

mkdirSync(dirname(OUT), { recursive: true });
writeFileSync(OUT, JSON.stringify(out, null, 2) + '\n');

const withCode = Object.values(out).filter((v) => v.code).length;
const withSameAs = Object.values(out).filter((v) => v.sameAs).length;
console.log(`entity-schema: ${Object.keys(out).length}/${entities.length} entities carry identity · ${withCode} with an ICD code · ${withSameAs} with sameAs → src/data/entity-schema.json`);
