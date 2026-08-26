// embed-entities.mjs — fill seo_entity_embeddings so entity dedupe can be done by meaning,
// not just by spelling.
//
//   set -a; . .secrets/supabase.env; . .secrets/embeddings.env; set +a
//   node content-plan/etl/embed-entities.mjs            # embed what is missing or stale
//   node content-plan/etl/embed-entities.mjs --all      # re-embed everything (model change)
//   node content-plan/etl/embed-entities.mjs --dry-run  # show what would be sent, send nothing
//
// WHY THIS EXISTS: pg_trgm catches entities that are spelled alike ("Diabetes & Oral Health" vs
// "Diabetes and Oral Health"). It cannot catch entities that mean the same thing in different
// words — นอนกัดฟัน vs bruxism vs teeth grinding — and that is exactly the class of duplicate that
// survived three brand-level audits. Embeddings close that gap.
//
// Two schema facts this script must respect, both learned the hard way from the page tables:
//   • seo_entity_embeddings.entity_fp is a FK to seo_entity_graph.entity_fingerprint — the SLUG
//     ("malocclusion"), not the ent_XXXX hash in .fingerprint. Pages join on the slug too.
//   • embedding_model is a CHECK-constrained vocabulary; the value is 'openai-text-embedding-3-small',
//     not the bare OpenAI model id. The column is vector(1536), which is that model's native width,
//     so switching provider means altering a table shared by three brands.
//
// Re-runs are cheap by design: source_text_hash is compared first and unchanged rows are skipped.

import { createClient } from '@supabase/supabase-js';
import { createHash } from 'node:crypto';

const SUPABASE_URL = 'https://lffcbeszjqzioobqfdav.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_KEY;
const OPENAI_KEY = process.env.OPENAI_API_KEY;

const API_MODEL = 'text-embedding-3-small';              // what OpenAI is asked for
const DB_MODEL = 'openai-text-embedding-3-small';        // what chk_ee_model allows
const DIMENSIONS = 1536;
const BATCH = 100;
const ALL = process.argv.includes('--all');
const DRY = process.argv.includes('--dry-run');

if (!SUPABASE_KEY) {
  console.error('\n⚠️  No SUPABASE_SERVICE_KEY. Load .secrets/supabase.env first (see header).\n');
  process.exit(1);
}
if (!OPENAI_KEY || OPENAI_KEY === 'PASTE_KEY_HERE') {
  console.error('\n⚠️  No OPENAI_API_KEY. Put the key in .secrets/embeddings.env — never paste it into a chat.\n');
  process.exit(1);
}

const db = createClient(SUPABASE_URL, SUPABASE_KEY);

// The text decides what "similar" means. The name alone is too thin: "Peak Performance" and
// "Peak Brain Performance" are near-identical without context. Cluster + type + the Thai summary
// give the vector enough to separate them — and the Thai summary is why a multilingual model
// matters, since it is the only part of the record written the way patients actually search.
const sourceText = (e) => [
  e.entity_name,
  e.entity_type,
  e.topic_cluster_id,
  e.ai_entity_summary?.slice(0, 400),
].filter(Boolean).join(' | ');

const hash = (s) => createHash('sha256').update(s).digest('hex').slice(0, 32);

async function embedBatch(texts) {
  for (let attempt = 1; attempt <= 3; attempt++) {
    const res = await fetch('https://api.openai.com/v1/embeddings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${OPENAI_KEY}` },
      body: JSON.stringify({ model: API_MODEL, input: texts, dimensions: DIMENSIONS }),
    });
    if (res.ok) return (await res.json()).data.map((d) => d.embedding);
    if (res.status === 429 || res.status >= 500) {
      const wait = attempt * 2000;
      console.warn(`  ${res.status} — retrying in ${wait / 1000}s`);
      await new Promise((r) => setTimeout(r, wait));
      continue;
    }
    throw new Error(`OpenAI ${res.status}: ${await res.text()}`);
  }
  throw new Error('OpenAI: still failing after 3 attempts');
}

// Fetch every row, then decide what to skip in JS. The filter used to be
// `.neq('entity_lifecycle', 'merged')`, which had two faults on one line, both found
// by eywa-deezy on 2026-08-26 and both confirmed against the live table:
//
//   1. It is case-sensitive, and the column is not. 359 of 732 rows (49%) are not
//      lower case — Mature 299, Growing 59, Emerging 1 alongside mature 124,
//      growing 203, emerging 16. The 23 merged rows happen to be lower case today, so
//      the filter works right now by luck. The next merge that writes 'Merged' slips
//      straight through and the tombstone gets embedded into the semantic index.
//   2. `entity_lifecycle <> 'merged'` is NULL, not TRUE, when the column is NULL, so
//      PostgREST silently dropped the 7 rows with no lifecycle. 732 rows in, 702 out,
//      and nothing said where the other 30 went.
//
// Paginated for the same reason the shared PostgREST helper is: the table is at 732
// and the default response cap is 1000, so this is one growth spurt away from
// embedding a subset and reporting on it as though it were the graph.
const entities = [];
for (let from = 0; ; from += 1000) {
  const { data, error } = await db
    .from('seo_entity_graph')
    .select('entity_fingerprint, entity_name, entity_type, topic_cluster_id, ai_entity_summary, entity_lifecycle')
    .order('entity_fingerprint')
    .range(from, from + 999);
  if (error) { console.error(error); process.exit(1); }
  entities.push(...(data ?? []));
  if (!data || data.length < 1000) break;
}
const merged = entities.filter((e) => (e.entity_lifecycle ?? '').trim().toLowerCase() === 'merged');
const live = entities.filter((e) => (e.entity_lifecycle ?? '').trim().toLowerCase() !== 'merged');
console.log(`entities ${entities.length} · merged skipped ${merged.length} · to consider ${live.length}` +
            ` · no lifecycle ${entities.filter((e) => !e.entity_lifecycle).length} (kept — absent is not merged)`);

const { data: existing } = await db
  .from('seo_entity_embeddings')
  .select('entity_fp, source_text_hash, embedding_model');
const known = new Map((existing ?? []).map((r) => [r.entity_fp, r]));

const work = [];
for (const e of live) {
  if (!e.entity_fingerprint) continue;              // no slug = nothing the FK can point at
  const text = sourceText(e);
  const h = hash(text);
  const prev = known.get(e.entity_fingerprint);
  const current = prev && prev.source_text_hash === h && prev.embedding_model === DB_MODEL;
  if (current && !ALL) continue;
  work.push({ fp: e.entity_fingerprint, text, h });
}

console.log(`entities: ${entities.length} · already current: ${entities.length - work.length} · to embed: ${work.length}`);
if (DRY || work.length === 0) {
  work.slice(0, 5).forEach((w) => console.log(`  ${w.fp}  ${w.text.slice(0, 90)}`));
  process.exit(0);
}

let done = 0;
for (let i = 0; i < work.length; i += BATCH) {
  const chunk = work.slice(i, i + BATCH);
  const vectors = await embedBatch(chunk.map((c) => c.text));
  const rows = chunk.map((c, j) => ({
    entity_fp: c.fp,
    embedding: vectors[j],
    embedding_model: DB_MODEL,
    embedding_dimensions: DIMENSIONS,
    source_text: c.text,
    source_text_hash: c.h,
    computed_at: new Date().toISOString(),
    is_stale: false,
  }));
  const { error: upErr } = await db.from('seo_entity_embeddings').upsert(rows, { onConflict: 'entity_fp' });
  if (upErr) { console.error(upErr); process.exit(1); }
  done += chunk.length;
  console.log(`  embedded ${done}/${work.length}`);
}

console.log(`\n✅ ${done} entity embeddings written (${DB_MODEL}, ${DIMENSIONS}d).`);
console.log('   Next: select * from v_entity_semantic_duplicates limit 40;');
