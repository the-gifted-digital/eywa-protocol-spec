// gen-entity-clinical.mjs — the contraindication list of every entity, as a static map.
// Brand-agnostic port of eywa-vth-biodent/web/scripts/gen-entity-clinical.mjs (2026-09 original).
//
//   node gen-entity-clinical.mjs --brand vth-biodent                        # → src/data/entity-clinical.json (relative to cwd)
//   node gen-entity-clinical.mjs --brand smile-scape-clinic --out other.json
//
// WHY THIS EXISTS (unchanged from the VTH original): "who must be assessed before this procedure"
// used to live in three places nothing tied together — the extension tables, a hand-typed
// `contraindication:` array in each page's YAML, and the JSON-LD built from that array. The table
// is the one store (DR-VTH-012); this bridge is how a brand's site reads it. A block component
// renders the list for the page's primaryEntity and schema.ts emits the same list into
// MedicalProcedure, so the screen and the JSON-LD cannot disagree. Writers never type it: change
// the table, regenerate.
//
// Three tables hold the column under two names (procedures/devices `contraindications`, drug
// `contraindications_text`); this map hides that. Entities the graph has retired (merged/dropped,
// case-insensitive) are skipped so a stale binding cannot borrow a list.
//
// WHY THIS COPY IS BRAND-AGNOSTIC AND ZERO-DEPENDENCY: like writer-brief/page-brief.mjs, this drops
// `@supabase/supabase-js` for plain `fetch` against PostgREST, because this repo has no
// node_modules of its own. NOTE: the map itself is brand-INDEPENDENT — the three source tables are
// shared across every brand on this schema, so `--brand` filters nothing here; it is accepted only
// for symmetry with the rest of this repo's `--brand`-taking scripts and is printed in the summary
// line.
//
// The JSON this writes is meant to be COMMITTED in the brand's repo; the brand's build only reads
// it. check-clinical.mjs fails the build when the committed copy is behind the database.
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, resolve, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const SB = 'https://lffcbeszjqzioobqfdav.supabase.co/rest/v1/';
const SOURCES = [
  { table: 'seo_entity_procedures', column: 'contraindications' },
  { table: 'seo_entity_devices', column: 'contraindications' },
  { table: 'seo_entity_drug', column: 'contraindications_text' },
];

// ── CLI ──────────────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
const flagValue = (name) => {
  const i = argv.indexOf(`--${name}`);
  return i !== -1 ? argv[i + 1] : undefined;
};
const BRAND = flagValue('brand');
const OUT_ARG = flagValue('out');
const IS_MAIN = process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (IS_MAIN && !BRAND) {
  console.error('\nusage: node gen-entity-clinical.mjs --brand <brand_id> [--out <path>]\n');
  process.exit(1);
}
const OUT = resolve(process.cwd(), OUT_ARG || 'src/data/entity-clinical.json');

// ── key lookup — same order as writer-brief/page-brief.mjs's findKey() ───────
//   1. SUPABASE_SERVICE_KEY in the environment
//   2. EYWA_SECRETS_ENV pointing at a file holding SUPABASE_SERVICE_KEY=...
//   3. .secrets/supabase.env, walking up from the working directory
// Pure — returns the key or null, never prints or exits, so check-clinical.mjs can import it and
// decide its own error handling (a gate that cannot run needs its own exit code, not this one's).
function keyFromEnvFile(path) {
  if (!existsSync(path)) return null;
  for (const line of readFileSync(path, 'utf8').split('\n')) {
    if (line.startsWith('SUPABASE_SERVICE_KEY=')) {
      const v = line.slice('SUPABASE_SERVICE_KEY='.length).trim();
      if (v) return v;
    }
  }
  return null;
}
export function findKey() {
  if (process.env.SUPABASE_SERVICE_KEY) return process.env.SUPABASE_SERVICE_KEY;
  if (process.env.EYWA_SECRETS_ENV) {
    const k = keyFromEnvFile(process.env.EYWA_SECRETS_ENV);
    if (k) return k;
  }
  let d = resolve(process.cwd());
  for (;;) {
    const k = keyFromEnvFile(resolve(d, '.secrets', 'supabase.env'));
    if (k) return k;
    const parent = dirname(d);
    if (parent === d) break;
    d = parent;
  }
  return null;
}

async function pgGet(qs, key) {
  const res = await fetch(`${SB}${qs}`, { headers: { apikey: key, Authorization: `Bearer ${key}` } });
  if (!res.ok) throw new Error(`GET ${qs} → ${res.status}: ${(await res.text().catch(() => '')).slice(0, 300)}`);
  return res.json();
}

/** Build the map from the database. Exported so check-clinical.mjs can compare against the committed copy. */
export async function buildClinicalMap() {
  const key = findKey();
  if (!key) {
    throw new Error(
      'SUPABASE_SERVICE_KEY missing — set it in the environment, point EYWA_SECRETS_ENV at a file ' +
      'that has it, or run from a directory with .secrets/supabase.env above it',
    );
  }

  const retired = await pgGet(
    'seo_entity_graph?select=entity_fingerprint&or=(entity_lifecycle.ilike.merged,entity_lifecycle.ilike.dropped)',
    key,
  );
  const gone = new Set(retired.map((r) => r.entity_fingerprint));

  const out = {};
  for (const { table, column } of SOURCES) {
    const rows = await pgGet(`${table}?select=entity_fp,${column}&${column}=not.is.null`, key);
    for (const row of rows) {
      const items = (row[column] ?? []).map((s) => String(s).trim()).filter(Boolean);
      if (!items.length || gone.has(row.entity_fp)) continue;
      if (out[row.entity_fp]) {
        // The same entity in two extension tables — keep the first, say so, and let a human decide.
        console.warn(`entity-clinical: ${row.entity_fp} has a list in ${out[row.entity_fp].table} and ${table} — using ${out[row.entity_fp].table}`);
        continue;
      }
      out[row.entity_fp] = { contraindications: items, table: table.replace('seo_entity_', '') };
    }
  }
  return Object.fromEntries(Object.entries(out).sort(([a], [b]) => a.localeCompare(b)));
}

if (IS_MAIN) {
  try {
    const map = await buildClinicalMap();
    mkdirSync(dirname(OUT), { recursive: true });
    writeFileSync(OUT, JSON.stringify(map, null, 2) + '\n');
    const n = Object.keys(map).length;
    const items = Object.values(map).reduce((s, v) => s + v.contraindications.length, 0);
    console.log(`entity-clinical (--brand ${BRAND}): ${n} entities · ${items} contraindication items → ${relative(process.cwd(), OUT)}`);
  } catch (e) {
    console.error(`gen-entity-clinical: ${e.message}`);
    process.exit(1);
  }
}
