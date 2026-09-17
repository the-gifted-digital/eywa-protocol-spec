// page-brief.mjs — generate a writer's brief for ONE page, straight from the database.
// Brand-agnostic port of eywa-vth-biodent/web/scripts/page-brief.mjs (2026-08 original).
//
//   node page-brief.mjs --brand vth-biodent vth-6.1.3            # by page_fingerprint
//   node page-brief.mjs --brand smile-scape-clinic tmj-guide     # or by slug
//   node page-brief.mjs --brand deezy-dental 3.4 --write         # or by sitemap_node_id, + write file
//
// WHY THIS EXISTS (unchanged from the VTH original): the first briefs were assembled BY HAND —
// run the queries, paste the results, remember which warnings apply. That works for four pages
// and fails for hundreds, and the failure is silent: the one query you forget is the one trap you
// walk into. Everything in here comes from deterministic lookups, so it belongs in a script. What
// is left for a person — the angle, which citation supports which sentence, Thai that reads well —
// this script deliberately does not touch.
//
// WHY THIS COPY IS BRAND-AGNOSTIC: the VTH original hardcoded BRAND_ID, a `%VTH%` SERP filter and
// a `^vth-9` local-section carve-out. Three brands now share this schema, so the brand-specific
// bits move to `brands/<brand_id>.json` (all keys optional — see README.md) and everything else
// is derived at runtime from the resolved page row (brand_name, keyword fingerprint prefix). This
// file also drops the `@supabase/supabase-js` dependency (plain `fetch` instead) so it can run
// from the protocol repo, which has no node_modules of its own.
//
// It reads and never writes to the database. The page YAML is still authored by hand.
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { dirname, resolve, join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const PROTOCOL_ROOT = resolve(HERE, '..', '..');
const GATES_DIR = resolve(PROTOCOL_ROOT, 'scripts', 'citation-gates');
const SB = 'https://lffcbeszjqzioobqfdav.supabase.co/rest/v1/';

// ── CLI ──────────────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
const FLAGS_WITH_VALUE = new Set(['--brand', '--web', '--out']);
const flagValue = (name) => {
  const i = argv.indexOf(`--${name}`);
  return i !== -1 ? argv[i + 1] : undefined;
};
let target;
for (let i = 0; i < argv.length; i++) {
  const a = argv[i];
  if (a === '--write') continue;
  if (FLAGS_WITH_VALUE.has(a)) { i++; continue; }
  if (a.startsWith('--')) continue;
  if (target === undefined) target = a;
}
const WRITE = argv.includes('--write');
const BRAND = flagValue('brand');
const WEB_ARG = flagValue('web');
const OUT_ARG = flagValue('out');

if (!BRAND || !target) {
  console.error(
    '\nusage: node page-brief.mjs --brand <brand_id> <page_fingerprint|slug|sitemap_node_id> [--write] [--web <path>] [--out <dir>]\n',
  );
  process.exit(1);
}

// ── brand config (brands/<brand_id>.json — all keys optional, see README.md) ─
const cfgPath = resolve(HERE, 'brands', `${BRAND}.json`);
const cfg = existsSync(cfgPath) ? JSON.parse(readFileSync(cfgPath, 'utf8')) : {};

// ── key lookup — mirrors citation-gates/eywa_supabase.py's key(), same order ─
//   1. SUPABASE_SERVICE_KEY in the environment
//   2. EYWA_SECRETS_ENV pointing at a file holding SUPABASE_SERVICE_KEY=...
//   3. .secrets/supabase.env walking up from the working directory
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
function findKey() {
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
  console.error(
    '\n⚠️  ไม่มีคีย์ Supabase — ตั้ง SUPABASE_SERVICE_KEY ใน env, หรือชี้ EYWA_SECRETS_ENV ไปที่ไฟล์ที่มีคีย์,' +
    '\n    หรือรันจากในโฟลเดอร์ของแบรนด์ที่มี .secrets/supabase.env\n',
  );
  process.exit(1);
}
const KEY = findKey();

// ── PostgREST helpers — plain fetch, zero deps (this is why the script cannot use supabase-js:
// the protocol repo has no node_modules, and this file needs to run from inside it) ────────────
const enc = encodeURIComponent;
// PostgREST's select= grammar rejects whitespace outright (not just newlines) — PAGE_COLS below
// is written as an indented multi-line template literal for readability, so every select= string
// needs stripping before it goes on the wire.
const cleanSelect = (s) => s.replace(/\s+/g, '');
const eq = (col, val) => `${col}=eq.${enc(val)}`;
const neq = (col, val) => `${col}=neq.${enc(val)}`;
const inList = (col, vals) => `${col}=in.(${vals.map(enc).join(',')})`;

async function pgGet(qs) {
  const res = await fetch(`${SB}${qs}`, { headers: { apikey: KEY, Authorization: `Bearer ${KEY}` } });
  if (!res.ok) throw new Error(`GET ${qs} → ${res.status}: ${(await res.text().catch(() => '')).slice(0, 300)}`);
  return res.json();
}
async function one(table, select, filters = [], { order } = {}) {
  const qs = `${table}?select=${enc(cleanSelect(select))}${filters.length ? '&' + filters.join('&') : ''}${order ? `&order=${enc(order)}` : ''}&limit=1`;
  const rows = await pgGet(qs);
  return rows[0] ?? null;
}
// ponytail: pagination loop has no ORDER BY, so a table that grows past 1000 rows for a single
// filter has no stability guarantee across pages (see eywa_supabase.py's fetch() for why that
// matters). Not expected here — every call site below is scoped to one page or one small id
// list — pass `order` and add one if that ever changes.
async function many(table, select, filters = [], { order } = {}) {
  const base = `${table}?select=${enc(cleanSelect(select))}${filters.length ? '&' + filters.join('&') : ''}${order ? `&order=${enc(order)}` : ''}`;
  const PAGE = 1000;
  let out = [], offset = 0;
  for (;;) {
    const batch = await pgGet(`${base}&limit=${PAGE}&offset=${offset}`);
    out = out.concat(batch);
    if (batch.length < PAGE) return out;
    offset += PAGE;
  }
}
async function count(table, filters = []) {
  const qs = `${table}?select=*${filters.length ? '&' + filters.join('&') : ''}`;
  const res = await fetch(`${SB}${qs}`, {
    method: 'HEAD',
    headers: { apikey: KEY, Authorization: `Bearer ${KEY}`, Prefer: 'count=exact' },
  });
  if (!res.ok) throw new Error(`HEAD ${qs} → ${res.status}`);
  const range = res.headers.get('content-range');
  if (!range) return 0;
  const total = range.split('/')[1];
  return total === '*' ? 0 : parseInt(total, 10);
}

// `is not null` is not the same as `has content` — the lesson that cost a whole rewrite when
// related_searches turned out to be 1,509 non-null empty arrays. Always look at the value.
const filled = (v) => {
  if (v === null || v === undefined) return false;
  const s = typeof v === 'string' ? v : JSON.stringify(v);
  return !['', '[]', '{}', 'null', '""'].includes(s.trim());
};
const yn = (b) => (b ? '✅ มี' : '❌ ว่าง');
const withMore = (arr, max) => ({ shown: arr.slice(0, max), more: Math.max(0, arr.length - max) });

// ── web/ auto-detect — needed for the render report and for gating brand npm scripts ─────────
function findWebDir(explicit) {
  if (explicit) return resolve(explicit);
  let d = resolve(process.cwd());
  for (;;) {
    if (existsSync(join(d, 'src', 'lib', 'template-keys.ts'))) return d; // cwd is already web/
    if (existsSync(join(d, 'web', 'src', 'lib', 'template-keys.ts'))) return join(d, 'web');
    const parent = dirname(d);
    if (parent === d) return null;
    d = parent;
  }
}
const WEB = findWebDir(WEB_ARG);
const BRAND_REPO_ROOT = WEB ? dirname(WEB) : resolve(process.cwd());

// ── page ────────────────────────────────────────────────────────────────────
const PAGE_COLS = `page_fingerprint, slug, page_name, brand_id, brand_name, content_format, content_format_name,
  node_tier, funnel_stage, primary_entity_fp, primary_entity_name, auto_suggested_word_count_target,
  compliance_max_tier, legal_review_required, sensitive_topic_flag, robots_directive, index_directive,
  review_cycle, status, seo_title, meta_description, target_keyword_fp, semantic_keywords_fps,
  paa_checked_at, has_medical_review, page_language, flag_review, reconciliation_notes,
  page_category, page_role, content_topic_tier, intent_source_tier, parent_page_fp, canonical_url,
  related_entities_fps`;

const page =
  (await one('seo_website_page_master', PAGE_COLS, [eq('page_fingerprint', target)])) ??
  (await one('seo_website_page_master', PAGE_COLS, [eq('brand_id', BRAND), eq('slug', target)])) ??
  (await one('seo_website_page_master', PAGE_COLS, [eq('brand_id', BRAND), eq('sitemap_node_id', target)]));

if (!page) {
  console.error(
    `\n❌ ไม่พบหน้า "${target}" ในแบรนด์ "${BRAND}" — ลองใส่ page_fingerprint, slug หรือ sitemap_node_id\n`,
  );
  process.exit(1);
}

// funnel_stage is the source of truth for `funnel:` — never derive it from search intent
// (protocol Keyword_Assignment_SOP §2.6). Retired top/mid/bottom stay mapped so a row written
// by an ETL that has not caught up still resolves.
const FUNNEL = {
  awareness: 'awareness', consideration: 'consideration', decision: 'decision', retention: 'retention',
  top: 'awareness', mid: 'consideration', bottom: 'decision',
};

// keyword fingerprint prefix: derive from the page's OWN target keyword when it has one — that's
// always correct for this exact brand/locale. When it doesn't (the one case that needs this: the
// "no target keyword yet" flag, which fires precisely when there is no keyword to derive from),
// fall back to config, then to the brand's own naming convention (verified 2026-09-17 against all
// three brands: `<brand_name lowercased>::🇹🇭 th – thailand::🇹🇭 th – thai::`).
const fpPrefix = (fp) => { const i = fp.lastIndexOf('::'); return i === -1 ? null : fp.slice(0, i + 2); };
const kwPrefix = (page.target_keyword_fp && fpPrefix(page.target_keyword_fp)) || cfg.keyword_fp_prefix ||
  `${(page.brand_name ?? '').toLowerCase()}::🇹🇭 th – thailand::🇹🇭 th – thai::`;

// ── keyword + SERP ──────────────────────────────────────────────────────────
const kw = page.target_keyword_fp
  ? await one('seo_x_ads_keywords_contextual_master', 'keyword, search_intent, fingerprint', [eq('fingerprint', page.target_keyword_fp)])
  : null;

const serpCols = `snapshot_date, top_competitors_meta, competitors_content_json, people_also_ask_json, related_searches`;
// Exact brand_name match, never ILIKE — a `%smile%`-style filter matches another brand's SERP
// rows too (e.g. "TC Smile Dental"), which is exactly the bug this port has to not reintroduce.
const serpRows = page.target_keyword_fp
  ? await many('seo_x_ads_keyword_serp_competitors', serpCols, [eq('fingerprint', page.target_keyword_fp), eq('brand', page.brand_name)], { order: 'snapshot_date.desc' })
  : [];
const serp = serpRows[0] ?? null;

// When the target has no SERP row, fall back to a same-topic semantic keyword as a proxy — but
// only as a proxy, and the brief has to say which one so the writer can count the title overlap.
let proxy = null;
if (!serp && Array.isArray(page.semantic_keywords_fps) && page.semantic_keywords_fps.length) {
  for (const fp of page.semantic_keywords_fps) {
    const row = await one('seo_x_ads_keyword_serp_competitors', `fingerprint, ${serpCols}`,
      [eq('fingerprint', fp), eq('brand', page.brand_name)], { order: 'snapshot_date.desc' });
    if (row) {
      const k = await one('seo_x_ads_keywords_contextual_master', 'keyword', [eq('fingerprint', fp)]);
      proxy = { keyword: k?.keyword ?? fp, ...row };
      break;
    }
  }
}
const nCompetitors = (r) => (Array.isArray(r?.top_competitors_meta) ? r.top_competitors_meta.length : 0);

// NEW: semantic_keywords_fps resolved to keyword text.
let semanticKeywords = [];
if (Array.isArray(page.semantic_keywords_fps) && page.semantic_keywords_fps.length) {
  const rows = await many('seo_x_ads_keywords_contextual_master', 'fingerprint, keyword', [inList('fingerprint', page.semantic_keywords_fps)]);
  const byFp = new Map(rows.map((r) => [r.fingerprint, r.keyword]));
  semanticKeywords = page.semantic_keywords_fps.map((fp) => byFp.get(fp) ?? fp);
}

// ── entity ──────────────────────────────────────────────────────────────────
// seo_entity_graph lookup uses entity_fingerprint, NOT entity_slug — both exist and are equal
// for all but 2 rows, and entity_fingerprint is the one that actually matches primary_entity_fp.
const entity = page.primary_entity_fp
  ? await one('seo_entity_graph', 'entity_fingerprint, entity_slug, entity_type, entity_name, ai_entity_summary', [eq('entity_fingerprint', page.primary_entity_fp)])
  : null;

// 142+ entities still have no summary in the pool — "backfill is complete" has been stale before.
const CHILD = ['seo_entity_symptom', 'seo_entity_condition', 'seo_entity_procedures',
  'seo_entity_anatomy', 'seo_entity_drug', 'seo_entity_devices', 'seo_entity_lab_test'];
// The child tables key on `entity_fp`, NOT `entity_slug`/`entity_fingerprint` — only
// seo_entity_graph has those. Counting rows is not enough either — a row can exist with every
// column null — so count the fields that actually hold something.
const childRows = [];
for (const t of CHILD) {
  try {
    const n = await count(t, [eq('entity_fp', page.primary_entity_fp)]);
    if (n > 0) {
      const row = await one(t, '*', [eq('entity_fp', page.primary_entity_fp)]);
      const skip = new Set(['entity_fp', 'id', 'created_at', 'updated_at', 'brand_id', 'notion_id',
        'fingerprint', 'notion_synced_at', 'sync_state']);
      const populated = row ? Object.entries(row).filter(([k, v]) => filled(v) && !skip.has(k)).map(([k]) => k) : [];
      childRows.push({ table: t, rows: n, populated });
    }
  } catch { /* table may not exist for this brand — skip quietly */ }
}
const hasMaterial = childRows.some((c) => c.populated.length > 0);

// NEW: related_entities_fps resolved to names.
let relatedEntityNames = [];
if (Array.isArray(page.related_entities_fps) && page.related_entities_fps.length) {
  const rows = await many('seo_entity_graph', 'entity_fingerprint, entity_name', [inList('entity_fingerprint', page.related_entities_fps)]);
  const byFp = new Map(rows.map((r) => [r.entity_fingerprint, r.entity_name]));
  relatedEntityNames = page.related_entities_fps.map((fp) => byFp.get(fp) ?? fp);
}

// ── citations ───────────────────────────────────────────────────────────────
const bound = await many('seo_page_citations', 'citation_fp, inline_position, citation_purpose, supports_claim',
  [eq('page_fp', page.page_fingerprint), eq('status', 'active')], { order: 'inline_position' });
const boundCites = bound.length
  ? await many('seo_citations',
      'fingerprint, title, authors, publication_year, pubmed_pmid, doi, isbn, citation_tier, verification_status, key_findings',
      [inList('fingerprint', bound.map((b) => b.citation_fp))])
  : [];
const byFp = new Map(boundCites.map((c) => [c.fingerprint, c]));

// ── internal links ──────────────────────────────────────────────────────────
// Inbound anchors (any link_type) — one fetch doubles as the count AND the distinct-anchor tally.
const inboundLinks = await many('seo_page_internal_links', 'anchor_text',
  [eq('to_page_fp', page.page_fingerprint), eq('planned', true), neq('status', 'deprecated')]);
const inbound = inboundLinks.length;
const anchorCounts = new Map();
for (const l of inboundLinks) {
  const a = l.anchor_text ?? '—';
  anchorCounts.set(a, (anchorCounts.get(a) ?? 0) + 1);
}
const outbound = await count('seo_page_internal_links',
  [eq('from_page_fp', page.page_fingerprint), eq('planned', true), neq('status', 'deprecated')]);

// NEW: planned contextual outbound links, resolved to slug.
const contextualOutbound = await many('seo_page_internal_links', 'to_page_fp, to_external_url, anchor_text, anchor_variant_type, section_context',
  [eq('from_page_fp', page.page_fingerprint), eq('link_type', 'contextual'), neq('status', 'deprecated')]);
const toFps = [...new Set(contextualOutbound.map((l) => l.to_page_fp).filter(Boolean))];
const toSlugs = toFps.length
  ? await many('seo_website_page_master', 'page_fingerprint, slug', [inList('page_fingerprint', toFps)])
  : [];
const slugByFp = new Map(toSlugs.map((r) => [r.page_fingerprint, r.slug]));

// Anchor text is a frozen copy of seo_title. Rewrite the title and every inbound anchor still
// advertises the old one — and no build warns. This is step 4b of the writing SOP.
const drift = await many('seo_page_internal_links', 'from_page_fp, anchor_text',
  [eq('to_page_fp', page.page_fingerprint), neq('anchor_text', page.seo_title ?? '')]);

// ── which blocks does this template actually render? ─────────────────────────
// Zod accepts every baseFields key on every template, so a field can be valid and still be
// dropped in silence. The layout file is the only honest answer, so read it. Skipped entirely
// when no web/ was found — same content_format→layout convention for every brand, so nothing
// here needs a brand parameter.
const tplKey = (() => {
  if (!WEB) return null;
  const src = readFileSync(resolve(WEB, 'src/lib/template-keys.ts'), 'utf8');
  const rows = [...src.matchAll(/code:\s*'([^']+)',\s*key:\s*'([^']+)'/g)].map((m) => ({ code: m[1], key: m[2] }));
  return rows.find((r) => r.code === page.content_format)?.key ?? null;
})();

let renderReport = null;
if (WEB && tplKey) {
  const cap = tplKey[0].toUpperCase() + tplKey.slice(1);
  const layout = resolve(WEB, `src/layouts/templates/${cap}.astro`);
  const shell = resolve(WEB, 'src/layouts/templates/TemplateShell.astro');
  if (existsSync(layout)) {
    const text = readFileSync(layout, 'utf8') + '\n' + (existsSync(shell) ? readFileSync(shell, 'utf8') : '');
    const shared = readFileSync(resolve(WEB, 'src/content/_shared.ts'), 'utf8');
    const base = (shared.match(/export const baseFields[\s\S]*?\n\};/) ?? [''])[0];
    // Only CONTENT blocks can be "silently dropped" in the sense that matters. The rest of
    // baseFields is metadata the layout never touches by design.
    const CONTROL = new Set(['meta', 'template', 'primaryEntity', 'section', 'layer', 'tier', 'funnel',
      'pageType', 'sidebarRelatedEdge', 'showToc', 'schemaType', 'canonical', 'published', 'updatedAt']);
    const fields = [...base.matchAll(/^\s{2}([a-zA-Z]+):/gm)].map((m) => m[1]).filter((f) => !CONTROL.has(f));
    // Case-insensitive: some blocks render through a component named after the field.
    const rendered = fields.filter((f) => new RegExp(`\\b${f}\\b`, 'i').test(text));
    renderReport = { layout: `${cap}.astro`, dropped: fields.filter((f) => !rendered.includes(f)) };
  }
}

// ── B-rule eligibility check (keyword-assignment-sop §4) — same six rules on every brand; only
// B11's "where near-me is allowed" carve-out is brand data (config `local_sections`). ───────────
const B_RULES = [
  { id: 'B1',  re: /metronidazole|ibuprofen|amoxicillin|metrolex|ยาแก้อักเสบ|ยาฆ่าเชื้อ/i,
    why: 'ชื่อยา — YMYL + พ.ร.บ.ยา ม.88', semanticOk: false },
  { id: 'B3',  re: /25[6-7]\d|20[2-3]\d/,
    why: 'มีเลขปี — หมดอายุทุกปี ขัดหน้า evergreen', semanticOk: true },
  { id: 'B6',  re: /ราคาถูก|ที่ไหนถูก|ถูกที่สุด/i,
    why: 'ขัด positioning premium + สงครามราคา', semanticOk: true },
  { id: 'B9',  re: /โบราณ|ภูมิปัญญา|ทำนาย|ของขลัง|กอเอี๊ยะ/i,
    why: 'ความเชื่อ/ภูมิปัญญาพื้นบ้าน — ขัด E-E-A-T / YMYL', semanticOk: false },
  { id: 'B10', re: /pantip|กระทู้|reddit/i,
    why: 'forum qualifier — SERP เป็น UGC หน้าคลินิกชนะยาก และคำนี้ใส่ในเนื้อหาจริงไม่ได้', semanticOk: true },
  { id: 'B11', re: /ใกล้ฉัน/i,
    why: '`ใกล้ฉัน` สงวนให้เฉพาะหน้าที่ config `local_sections` อนุญาตเท่านั้น', semanticOk: true,
    onlySection: cfg.local_sections ? new RegExp(cfg.local_sections) : undefined },
];
const bHits = kw
  ? B_RULES.filter((r) => r.re.test(kw.keyword) && !(r.onlySection && r.onlySection.test(page.page_fingerprint)))
  : [];

// NEW: operator forbidden topics (config `forbidden_topics`) — checked against page_name,
// seo_title, meta_description, the target keyword, and related entity names.
const forbiddenHaystack = [page.page_name, page.seo_title, page.meta_description, kw?.keyword, ...relatedEntityNames]
  .filter(Boolean).join('\n');
const forbiddenHits = (cfg.forbidden_topics ?? []).filter((t) => new RegExp(t.pattern, 'i').test(forbiddenHaystack));

// notes: delimited by either " | " or a newline — split on both (2026-09-17 data check: real
// calibration notes use bare "\n" between dated entries, not just " | ").
const rawNotes = page.reconciliation_notes ?? '';
const notes = rawNotes.split(/ \| |\n/).map((s) => s.trim()).filter(Boolean);
const hasCitationExemption = /CITATION EXEMPTION/.test(rawNotes);
const hasOpenEntityGap = /ENTITY GAP/.test(rawNotes) && !/ENTITY GAP ปิด/.test(rawNotes);
const noTargetNote = rawNotes.match(/\[no-target:[^\]]*\]/)?.[0];
const flagReviewList = (page.flag_review ?? '').split(',').map((s) => s.trim()).filter(Boolean);

// ── flags — the part a person forgets and a script cannot ───────────────────
const flags = [];
for (const r of bHits) {
  flags.push(`🛑 **${r.id} VETO — target "${kw.keyword}" ใช้เป็น primary ไม่ได้** (${r.why})\n     → **หยุดเขียนหน้านี้** แจ้ง operator พร้อมคำที่เสนอแทน รออนุมัติ แล้วเขียนรอบถัดไป` +
    (r.semanticOk ? '\n     → คำเดิมเก็บเป็น semantic ได้ ไม่ต้องลบ' : '\n     → คำเดิมใช้ไม่ได้เลย แม้แต่เป็น semantic'));
}
for (const t of forbiddenHits) {
  flags.push(`🔴 **หัวข้อต้องห้าม** — ชนกฎ \`${t.pattern}\` (${t.why})`);
}
if (!kw && flagReviewList.includes('brand-nav')) {
  flags.push('🔵 หน้านี้เป็น **brand-nav** ตั้งใจไม่มี target keyword — ไม่ต้อง assign · ไม่นับใน KPI organic');
} else if (!kw && noTargetNote) {
  flags.push(`🔵 ${noTargetNote} — ไม่ต้อง assign target keyword (เหตุผลบันทึกไว้แล้ว เหมือน brand-nav)`);
} else if (!kw) {
  flags.push(
    '🟠 หน้านี้ยังไม่มี target keyword — **เสนอคำเองได้เลยตอนเขียน อย่ารอ pass แยก**\n' +
    '     ลำดับการเลือก: **ความเกี่ยวข้อง > intent > volume** — ยอม volume 0 ได้ถ้าคำตรงเจตนาหน้าจริง\n' +
    '     ขั้นตอน: คิดคำที่คนจะพิมพ์จริงเพื่อมาเจอหน้านี้ → เช็คว่าไม่ชน B1–B11 และไม่มีหน้าอื่นจองอยู่ →\n' +
    `     insert เข้า \`seo_x_ads_keywords_contextual_master\` (fingerprint = \`${kwPrefix}<คำ>\`)\n` +
    '     → UPDATE `target_keyword_fp` + `intent_source_tier=\'brand\'` + เคลียร์ `flag_review` → เขียนเหตุผลลง `reconciliation_notes`\n' +
    '     ถ้าคิดแล้วไม่มีคำไหนตรงจริง ให้ติด `flag_review=\'brand-nav\'` แทน แล้วบอก operator ว่าทำไม',
  );
}
// A near-me term is only ours if the SERP says so — volume is not evidence of relevance, the
// ranking set is.
if (kw && /ใกล้ฉัน/.test(kw.keyword)) {
  flags.push(
    `🟠 target "${kw.keyword}" เป็นคำ near-me — **ดู SERP จริงก่อนเขียนบรรทัดแรก**`,
    '     ถ้าอันดับ 1–10 ไม่มีคลินิกทันตกรรมเลย แปลว่า Google ตัดสินแล้วว่าคำนี้เป็นของสาขาอื่น',
    '     → veto คำนั้น (`keyword_use_as=\'excluded\'` + เหตุผล) แล้วยุบหน้า อย่าฝืนเขียน',
  );
}
if (kw && !serp && !proxy) flags.push(`🔴 target "${kw.keyword}" ไม่มีแถว SERP และหา semantic proxy ไม่ได้ — ดูตาราง 3 ระดับในคู่มือเขียนคอนเทนต์`);
if (kw && !serp && proxy) flags.push(`🟠 target ไม่มี SERP → ใช้ proxy "${proxy.keyword}" · **นับเองว่า title คู่แข่งมีคำ target กี่ราย แล้วบันทึกเป็น x/${nCompetitors(proxy)}**`);
if (serp && !filled(serp.competitors_content_json)) flags.push('🟠 มี SERP แต่ไม่มี competitors_content_json → ใช้ top_competitors_meta เป็น coverage proxy');
if (serp && filled(serp.competitors_content_json)) flags.push('✅ มี competitors_content_json → เดินตามคู่มือได้เต็มรูป ไม่ต้องใช้ proxy');
if (!filled(serp?.people_also_ask_json) && !filled(proxy?.people_also_ask_json)) flags.push('🟠 PAA ว่าง → FAQ floor ≥8 intent types จาก competitor meta + entity child tables');
if (!entity?.ai_entity_summary) flags.push(`🔴 primary entity "${page.primary_entity_fp}" ไม่มี ai_entity_summary — อย่าเชื่อคำว่า "backfill ครบ" ใช้ตารางลูกที่มีข้อมูลจริงแทน + ลง contentGaps`);
if (!hasMaterial) flags.push(`🔴 entity child table ไม่มีเนื้อใช้ได้เลย${childRows.length ? ' (มีแถวแต่ทุก field เป็น null)' : ' (ไม่มีแถว)'} — material ต้องมาจาก citation + competitor ล้วน`);
if (inbound > 0) flags.push(`🔴 มีลิงก์ขาเข้า ${inbound} เส้น — เขียน seo_title ใหม่เมื่อไหร่ ต้อง UPDATE anchor_text ทั้งหมด → gen:links → commit JSON ไม่มี build ไหนเตือน`);
if (drift.length) flags.push(`⚠️ anchor drift อยู่แล้ว ${drift.length} เส้น (anchor ไม่ตรง seo_title ปัจจุบัน) — แก้ให้ตรงก่อนเริ่ม`);
if (renderReport?.dropped.length) flags.push(`🔴 ${renderReport.layout} ไม่ render: ${renderReport.dropped.join(' · ')} — Zod รับเข้าแล้วทิ้งเงียบ อย่าใส่`);
if (WEB && tplKey && !renderReport) flags.push(`ℹ️ ไม่พบไฟล์ layout สำหรับ template key "${tplKey}" — ข้ามรายงาน render`);
if (!WEB) flags.push('ℹ️ ไม่พบ web/ (ไม่ได้ส่ง --web และหาไม่เจอจาก cwd) — ข้ามรายงาน "block ที่ layout ไม่ render" และเกตของแบรนด์');
if (page.legal_review_required) flags.push('🔴 legal_review_required = true — ต้องผ่านผู้รับอนุญาตสถานพยาบาลก่อน published: true');
if (page.sensitive_topic_flag && page.sensitive_topic_flag !== 'none') flags.push(`🔴 sensitive_topic_flag = ${page.sensitive_topic_flag}`);
if (page.paa_checked_at) flags.push(`ℹ️ paa_checked_at = ${String(page.paa_checked_at).slice(0, 10)} — หน้านี้เคยผ่านขั้นตอนนี้มาแล้ว`);
if (hasCitationExemption) flags.push('🔓 CITATION EXEMPTION — operator ยกเว้นไม่ต้องมี citation ไว้แล้วในรอบ calibrate (ดูรายละเอียดใน "คำสั่งจากรอบ calibrate")');
if (bound.length === 0 && !hasCitationExemption) flags.push('🟠 ยังไม่มี citation ผูกไว้เลย — คัดจาก pool (`verification_status = verified` เท่านั้น) แล้วเขียนกลับ `seo_page_citations`');
if (hasOpenEntityGap) flags.push('⚠️ ENTITY GAP — entity ที่ต้องใช้ยังไม่มีในกราฟ (ดูรายละเอียดใน "คำสั่งจากรอบ calibrate")');
if (page.intent_source_tier === 'brand') flags.push('ℹ️ intent_source_tier = brand — target keyword นี้ operator กำหนดเอง ไม่ได้มาจาก DataForSEO/volume data');

// ── render ──────────────────────────────────────────────────────────────────
const L = [];
const p = (s = '') => L.push(s);
const stamp = new Date().toISOString().slice(0, 10);
const docsSop = cfg.docs?.sop ?? 'docs/CONTENT-WRITING-SOP.md';
const docsBlocks = cfg.docs?.blocks ?? 'docs/template-block-standards.md';

p(`# Brief — \`${page.page_fingerprint}\` ${page.slug}`);
p();
p(`> สร้างจาก DB เมื่อ ${stamp} โดย \`node page-brief.mjs --brand ${BRAND} ${page.page_fingerprint}\``);
p(`> ไฟล์นี้เป็น**ใบสั่งงาน ไม่ใช่คู่มือ** — กฎอยู่ใน \`${docsSop}\` + \`${docsBlocks}\``);
p('> ตัวเลขในนี้สดตอนรัน ถ้าเว้นไว้หลายวันให้รันใหม่ ETL ยังโหลดอยู่');
p();
if (bHits.length) {
  p('# 🛑 หยุด — target keyword ของหน้านี้ใช้ไม่ได้');
  p();
  p(`ชน **${bHits.map((r) => r.id).join(' + ')}** ของ [keyword-assignment-sop §4](../content-plan/keyword-assignment-sop.md)`);
  p();
  p('**อย่าเขียนหน้านี้** และอย่าเขียนอ้อมคำนี้ — แจ้ง operator พร้อมคำที่เสนอแทน + เหตุผล/หลักฐาน รออนุมัติ แล้วหน้านี้จะกลับเข้าคิวรอบถัดไปพร้อมคำใหม่ · ระหว่างนี้ทำหน้าอื่นในลิสต์ต่อได้');
  p();
  p('---');
  p();
}
p('## ธงที่ต้องอ่านก่อน');
p();
flags.length ? flags.forEach((f) => p(`- ${f}`)) : p('- ไม่มีธงพิเศษ');
p();

const CALIBRATION = [
  ['ABSORBS', '📥 ต้องกลืนเนื้อหาจากหน้าที่ถูกยุบ'],
  ['ANGLE SPLIT', '🎯 หน้าคู่ที่เก็บไว้ทั้งคู่ — ห้ามเขียนซ้ำกัน'],
  ['BLEND INTO', '⚠️ หน้านี้ถูกยุบไปแล้ว — เนื้อหาต้องไปอยู่ที่หน้าอื่น'],
  ['ANGLE (format rule', '📐 กติกา angle ระดับหมวด'],
  ['INTENT EXEMPTION', '🔓 ยกเว้น intent matrix ไว้ พร้อมเหตุผล'],
  ['KEYWORD GAP', '🔑 ช่องว่างเรื่องคีย์เวิร์ดที่บันทึกไว้'],
  ['CITATION EXEMPTION', '🔓 ข้อยกเว้น citation จาก operator'],
  ['ENTITY GAP', '⚠️ entity ที่ต้องใช้ยังไม่มีในกราฟ'],
  ['[no-target:', '🔵 เหตุผลที่หน้านี้ไม่ต้องมี target keyword'],
  ['ยุบเข้า', '📥 ถูกยุบรวมเข้าหน้าอื่น'],
  ['MERGED', '🔀 บันทึกการ merge'],
  ['DROPPED', '🗑️ หน้า/entity ถูกดรอปแล้ว'],
  // A bare 'ห้าม' matches half the notes on a page (it is the ordinary word for "must not").
  // Only the phrasings operators actually use for a standing prohibition count.
  [/ห้ามพูด|ห้ามใช้|ห้ามเขียน|ห้ามใส่|ห้ามอ้าง/, '🚫 ข้อห้ามจาก operator'],
];
const hit = (n, marker) => (marker instanceof RegExp ? marker.test(n) : n.includes(marker));
const calls = CALIBRATION.flatMap(([marker, label]) =>
  notes.filter((n) => hit(n, marker)).map((n) => ({ label, text: n })));
if (calls.length) {
  p('## คำสั่งจากรอบ calibrate — อ่านก่อนลงมือ');
  p();
  calls.forEach((c) => p(`- **${c.label}**\n     ${c.text}`));
  p();
}

p('## หน้าที่จะเขียน');
p();
p('```');
p(`page_fingerprint    ${page.page_fingerprint}`);
p(`slug                ${page.slug}`);
p(`brand               ${page.brand_id ?? BRAND} · ${page.brand_name ?? '—'}`);
p(`page_name           ${page.page_name ?? '—'}`);
p(`template            ${page.content_format} · ${page.content_format_name ?? '—'}${tplKey ? ` · key=${tplKey}` : ''}`);
p(`ไฟล์                src/content/${tplKey ?? '<template>'}/${page.page_language ?? 'th'}/${page.slug}.yaml`);
p(`node_tier           ${page.node_tier ?? '—'}       funnel_stage ${page.funnel_stage ?? '—'} → funnel: ${FUNNEL[page.funnel_stage] ?? '—'}`);
p(`page_category       ${page.page_category ?? '—'}       page_role ${page.page_role ?? '—'}`);
p(`content_topic_tier  ${page.content_topic_tier ?? '—'}       intent_source_tier ${page.intent_source_tier ?? '—'}`);
p(`parent_page_fp      ${page.parent_page_fp ?? '—'}`);
p(`canonical_url       ${page.canonical_url ?? '—'}`);
p(`primaryEntity       ${page.primary_entity_fp ?? '—'}${page.primary_entity_name ? ` (${page.primary_entity_name})` : ''}`);
p(`word floor          ${page.auto_suggested_word_count_target ?? '—'}  (พื้น ไม่ใช่เพดาน · วัดด้วย lib/wordcount.ts)`);
p(`compliance          max_tier ${page.compliance_max_tier ?? '—'} · sensitive ${page.sensitive_topic_flag ?? '—'} · legal_review ${page.legal_review_required}`);
p(`robots              ${page.robots_directive ?? '—'} · index_directive ${page.index_directive ?? '—'}`);
p(`review_cycle        ${page.review_cycle ?? '—'} · status ${page.status ?? '—'} · has_medical_review ${page.has_medical_review}`);
p('```');
p();
p('`layer:` ไม่ต้องใส่ · `funnel:` แม็ปจาก `funnel_stage` ตามตารางข้างบน (ห้ามเดาจาก intent)');
p();
p('**baseline title/meta ตอนวางแผน:**');
p();
p(`- title \`${page.seo_title ?? '—'}\``);
p(`- meta  \`${page.meta_description ?? '—'}\``);
p();
p('## keyword + SERP');
p();
if (kw) {
  p(`- **target** \`${kw.keyword}\` · intent ${kw.search_intent ?? '—'}`);
  if (serp) {
    p(`- snapshot ${String(serp.snapshot_date).slice(0, 10)} · คู่แข่ง ${nCompetitors(serp)} ราย`);
    p(`- \`competitors_content_json\` ${yn(filled(serp.competitors_content_json))} · \`people_also_ask_json\` ${yn(filled(serp.people_also_ask_json))} · \`related_searches\` ${yn(filled(serp.related_searches))}`);
  } else if (proxy) {
    p(`- ❌ target ไม่มีแถว SERP`);
    p(`- proxy \`${proxy.keyword}\` · snapshot ${String(proxy.snapshot_date).slice(0, 10)} · คู่แข่ง ${nCompetitors(proxy)} ราย · content ${yn(filled(proxy.competitors_content_json))}`);
  } else {
    p('- ❌ ไม่มีแถว SERP ทั้ง target และ semantic');
  }
} else {
  p('- ❌ ยังไม่มี target keyword');
}
if (semanticKeywords.length) {
  const { shown, more } = withMore(semanticKeywords, 12);
  p(`- semantic keywords ที่ผูกไว้ (${semanticKeywords.length}):`);
  shown.forEach((k) => p(`     · ${k}`));
  if (more) p(`     · …และอีก ${more} คำ`);
}
p();
p('## entity');
p();
p(`- \`${page.primary_entity_fp ?? '—'}\`${entity?.entity_name ? ` (${entity.entity_name})` : ''} · ai_entity_summary ${yn(!!entity?.ai_entity_summary)}`);
if (childRows.length) childRows.forEach((c) => p(`- \`${c.table}\` ${c.rows} แถว · field ที่มีเนื้อจริง ${c.populated.length}${c.populated.length ? ': ' + c.populated.join(' · ') : ' — **มีแถวแต่ว่างทั้งหมด**'}`));
else p('- ไม่มีตารางลูกที่มีแถวเลย');
if (relatedEntityNames.length) {
  const { shown, more } = withMore(relatedEntityNames, 10);
  p(`- related entities (${relatedEntityNames.length}): ${shown.join(' · ')}${more ? ` · …และอีก ${more}` : ''}`);
}
p();
p('> ข้อความที่มี**ขนาดของผล** (`หลายเท่า` · `ส่วนใหญ่` · %) ต้องมี citation รองรับ · `key_findings` เป็น null ≠ รองรับ · **กวาดทั้งแถว อย่าหยุดที่จุดแรก**');
p();
p('## citation ที่ผูกไว้');
p();
if (bound.length) {
  p('| # | locator | tier | ปี | title |');
  p('|---|---|---|---|---|');
  bound.forEach((b, i) => {
    const c = byFp.get(b.citation_fp);
    const loc = c?.pubmed_pmid || c?.doi || c?.isbn || '—';
    p(`| ${i + 1} | ${loc} | ${c?.citation_tier ?? '—'} | ${c?.publication_year ?? '—'} | ${(c?.title ?? '—').slice(0, 70)} |`);
  });
  p();
  p('**backbone ไม่ใช่คำตอบสุดท้าย** — ระบบจับคู่ตาม cluster ไม่ได้อ่านเนื้อหารายหน้า คัดเฉพาะตัวที่รองรับข้ออ้างจริง แล้ว**เขียนกลับ junction (บังคับ)**');
  p();
  p('**แต่ละรายการรองรับอะไรจริง (`supports_claim`) — นี่คือขอบเขตที่หน้าเขียนได้ ห้ามเขียนเกินนี้:**');
  p();
  // A claim is only a boundary when someone wrote one. 2026-09-17 count for smile-scape: 59 rows
  // still carry the wave16e binding note as their claim and 130 are empty or under 40 chars —
  // printing those as "the boundary" would tell the writer the page may say nothing, or anything.
  const isPlaceholder = (t) => !t || t.trim().length < 40 || /^wave16[a-z]/i.test(t.trim());
  let placeholders = 0;
  bound.forEach((b, i) => {
    p(`**[${i + 1}]** _purpose: ${b.citation_purpose ?? '—'}_`);
    if (isPlaceholder(b.supports_claim)) {
      placeholders++;
      p('> ⚠️ **ยังไม่มี claim ที่ตรวจแล้ว** (ว่าง/สั้น/เป็นโน้ตตอนผูก) — ห้ามใช้เป็นขอบเขต: อ่าน `key_findings` ของเปเปอร์นี้ เขียนประโยคที่หน้าจะอ้างจริง แล้ว UPDATE `supports_claim` ก่อน published');
      const c = byFp.get(b.citation_fp);
      if (Array.isArray(c?.key_findings) && c.key_findings.length) p(`> key_findings: ${c.key_findings.slice(0, 2).join(' / ').slice(0, 300)}`);
    } else {
      p(`> ${b.supports_claim.replace(/\n/g, '\n> ')}`);
    }
    p();
  });
  if (placeholders) p(`> 🟠 ${placeholders}/${bound.length} รายการยังไม่มี claim — งานเขียนกลับ (write-back) ของหน้านี้ใหญ่กว่าปกติ`), p();
} else {
  p('ยังไม่มี — คัดจาก pool (`verification_status = verified` เท่านั้น) แล้วเขียนกลับ `seo_page_citations`');
  p();
}
p('## internal links — ห้ามเขียนมือ');
p();
p(`- inbound ${inbound} · outbound ${outbound} · anchor drift ปัจจุบัน ${drift.length}`);
p('- `relatedCluster` / `sidebarRelated` สร้างโดย `planRelated()` ตอน build — **ห้ามเขียนสองบล็อกนี้ในไฟล์**');
p('- inline ใช้ `[คำ](entity:<slug>)` — **entity slug เท่านั้น** · `hero.secondaryCta` เขียนเอง ห้ามชี้โปรไฟล์หมอ');
p();
if (contextualOutbound.length) {
  p('**outbound แบบ contextual ที่วางแผนไว้:**');
  p();
  p('| to (node/slug) | anchor_text | variant | section_context |');
  p('|---|---|---|---|');
  contextualOutbound.forEach((l) => {
    const to = l.to_page_fp ? `${l.to_page_fp} → ${slugByFp.get(l.to_page_fp) ?? '—'}` : (l.to_external_url ?? '—');
    p(`| ${to} | ${l.anchor_text ?? '—'} | ${l.anchor_variant_type ?? '—'} | ${l.section_context ?? '—'} |`);
  });
  p();
}
if (anchorCounts.size) {
  p('**anchor ขาเข้าที่มีอยู่แล้ว (distinct, ทุก link_type):**');
  p();
  [...anchorCounts.entries()].forEach(([a, n]) => p(`- \`${a}\` × ${n}`));
  p();
}
if (renderReport) {
  p(`## block ที่ \`${renderReport.layout}\` ไม่ render`);
  p();
  p(renderReport.dropped.length
    ? '```\n' + renderReport.dropped.join(' · ') + '\n```\n\nอยู่ใน `baseFields` ทั้งหมด Zod รับเข้าแล้วทิ้งเงียบ ไม่มี error ไม่มี warning'
    : 'ไม่มี — layout นี้ render ทุก field ใน `baseFields`');
  p();
} else if (!WEB) {
  p('## block ที่ layout ไม่ render');
  p();
  p('_ข้ามส่วนนี้ — ไม่พบ web/ (ดูธง ℹ️ ด้านบน)_');
  p();
}
p('## เกตที่ต้องรัน');
p();
p('เกตของ protocol (มีทุกแบรนด์ — path แสดงตามที่รันได้จริงจาก brand repo root):');
p();
const gatesRel = relative(BRAND_REPO_ROOT, GATES_DIR);
p('```bash');
p(`cd ${BRAND_REPO_ROOT}`);
p(`python3 ${gatesRel}/run-citation-qa-gates.py --brand ${BRAND}`);
p(`python3 ${gatesRel}/check-keyword-collisions.py --brand ${BRAND}`);
p(`python3 ${gatesRel}/audit-anchor-text.py --brand ${BRAND}`);
p('```');
p();
if (WEB) {
  let scripts = {};
  try { scripts = JSON.parse(readFileSync(resolve(WEB, 'package.json'), 'utf8')).scripts ?? {}; } catch { /* no package.json — skip */ }
  const cmds = [];
  if (scripts.build) cmds.push('npm run build');
  if (scripts['scan:headings']) cmds.push('npm run scan:headings');
  if (scripts['check:links']) cmds.push('npm run check:links');
  if (kw && scripts['check:density']) cmds.push(`npm run check:density -- ${page.slug} "${kw.keyword}"`);
  if (scripts.check) cmds.push('npm run check              # ห้ามเพิ่ม error จาก baseline');
  if (inbound > 0 && scripts['gen:links']) cmds.push('npm run gen:links          # หลังแก้ anchor');
  if (cmds.length) {
    p('เกตของแบรนด์ (พบใน `web/package.json` scripts):');
    p();
    p('```bash');
    p('cd web');
    cmds.forEach((c) => p(c));
    p('```');
    p();
  }
}
p('เสร็จแล้วเขียนกลับ DB: `seo_page_citations` · `seo_title`/`meta_description` · `paa_checked_at` · `anchor_text` ของลิงก์ขาเข้า');

const out = L.join('\n') + '\n';
console.log(out);

if (WRITE) {
  const dir = OUT_ARG ? resolve(OUT_ARG) : resolve(BRAND_REPO_ROOT, 'docs', 'briefs');
  mkdirSync(dir, { recursive: true });
  const file = resolve(dir, `${page.slug}.md`);
  writeFileSync(file, out);
  console.error(`\n📝 เขียนไฟล์: ${file}\n`);
}
