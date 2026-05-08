# 📋 EYWA Protocol — Decision Records

> **Append-only architectural decision log.** Each record explains WHY a decision was made — not just WHAT.

**Document Version:** 1.1  
**Last Updated:** 2026-05-08  
**Format:** Reverse chronological (newest first)

---

## Format Template

```markdown
## [DR-NNN] — Title (YYYY-MM-DD)

**Status:** Proposed | Accepted | Locked | Superseded by DR-XXX  
**Bible Reference:** Part X.Y (if applicable)  
**Schema Reference:** v1.X (if applicable)

**Context:** What problem are we solving?

**Decision:** What did we choose?

**Rationale:** Why this option vs alternatives?

**Consequences:** Trade-offs, follow-ups, known limitations.

**References:** Related Bible sections, related DRs, external sources.
```

---

## Decisions Log

### [DR-010] — Brand Scope Architecture (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 2.4, Part 28.13  
**Schema Reference:** v1.8

**Context:**  
EYWA federation ใช้ 1 shared Supabase + N Notion workspaces (DR-001) แต่ schema เดิมมี 3 รูปแบบของการเก็บ brand reference ที่ขัดแย้งกัน:
- `seo_entity_graph.brand_scope` = `text[]` (notion_ids without dashes)
- `seo_website_page_master.brand_id` = `text` (UUID format)
- `seo_x_ads_keywords_contextual_master.brand` = `text` (FK to brands.brand_name)

ทำให้ cross-table queries ยาก, federation pattern ใช้จริงไม่ได้, และ shared entities ต้องบอกได้ว่าใช้ใน brand ไหนบ้าง

**Decision:**  
Standardize brand association ผ่าน 2 patterns:

**Pattern A — `brand_scope text[]` (สำหรับตารางที่ shared ระหว่าง brands):**
- Single brand: `['vth-biodent']`
- Universal: `['*']`
- Shared: `['vth-biodent', 'vitalsleep', 'the-face-hospital']`

Tables: `seo_entity_graph`, `seo_topic_cluster_master`, `seo_authors`, `seo_citations`

**Pattern B — `brand_slug text NOT NULL` (สำหรับตารางที่ผูก 1 brand):**
- Single value only
- FK to `brands.brand_slug`

Tables: `seo_website_page_master`, `seo_brand_doctors`, `seo_brand_branches`, `seo_x_ads_keywords_contextual_master`

**`brand_slug`** = canonical brand identifier:
- Lowercase, kebab-case, immutable
- Examples: `vth-biodent`, `vitalsleep`, `the-face-by-vertex`
- Replaces inconsistent UUID/notion_id usage

**Rationale:**  
- **Pattern A**: Entities/clusters/authors อาจ shared หลาย brand → array makes sense
- **Pattern B**: Pages/doctors/branches ผูก 1 brand เสมอ → scalar simpler + FK enforceable
- **brand_slug**: Stable, human-readable, ไม่ผูก Notion IDs, ใช้ใน URL/file naming ได้
- ลด JOIN complexity (no UUID lookups, no notion_id stripping)
- Federation queries ทำได้ง่าย: `WHERE 'vth-biodent' = ANY(brand_scope)`

**Consequences:**
- ✅ Federation pattern (DR-001) implementable in queries
- ✅ Cross-brand entity sharing (DR-003) supported via array
- ✅ GIN index on `brand_scope[]` for fast lookup
- ⚠️ Migration: rename `brand_id` → `brand_slug` in page_master
- ⚠️ Migration: rename `brand` → `brand_slug` in keywords_master (kept FK)
- ⚠️ Backfill needed: notion_id → brand_slug mapping

**Implementation:**
- New column `brand_slug` on `brands` table (UNIQUE, immutable)
- 15 brand slugs locked: vth-biodent, vitalsleep-and-wellness, the-face-by-vertex, etc.
- All references migrate to `brand_slug` in Phase 1

**References:**
- DR-001 (Multi-Brand Federation Pattern)
- DR-003 (Single Entity, Multilingual Labels)
- Bible Part 2.4 (Multi-Brand Sharing)
- Schema v1.8 §3.1, §4.1, §5.1

---

### [DR-009] — Multilingual Strategy v2 (Two-Tier Pattern) (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 28 (entire)  
**Schema Reference:** v1.8

**Context:**  
EYWA targets 8 languages (TH, EN immediate; ZH, JA, KO, AR, FR, ES phased). Bible v3.9 introduced "Single Entity, Multilingual Labels" pattern (DR-003) but didn't differentiate between:
- **Concept tables** (entity, brand, author): same concept, multiple language labels
- **Content tables** (page, keyword, review): each language is separate content asset

Without this differentiation, applying single-row jsonb pattern to all tables would break content-level workflows (separate URL slugs, distinct SEO metadata, independent translation status per language).

**Decision:**  
Adopt **Two-Tier Multilingual Strategy**:

**Tier 1 — Concept Tables (1 row + jsonb translations):**

Used for entities where the concept is universal but has multiple language labels.

```jsonb
canonical_names: {"en": "Sleep Apnea", "th": "ภาวะหยุดหายใจขณะหลับ"}
aliases: {
  "en": ["sleep apnea syndrome", "OSA"],
  "th": ["หยุดหายใจตอนนอน", "นอนกรนแบบรุนแรง"]
}
descriptions: {"en": "...", "th": "..."}
```

Tables:
- `seo_entity_graph` (ent)
- `seo_topic_cluster_master` (clus)
- `brands` (brnd)
- `seo_authors` (auth)
- `seo_brand_doctors` (doc)
- `seo_brand_branches` (brch)
- `seo_citations` (cite)

**Tier 2 — Content Tables (1 row per language + translation_group_id):**

Used for content where each language version is a separate asset with unique SEO properties.

```yaml
schema:
  fingerprint: "page_01HZP5K2A"  # unique per row
  translation_group_id: "tg_01HZP5K2X"  # shared across translations
  page_language: "th"
  is_source_page: true  # exactly 1 per group
  source_translation_fp: "page_01HZP5K2A"  # NULL if is_source
```

Tables:
- `seo_website_page_master` (page)
- `seo_x_ads_keywords_contextual_master` (kw) — already has `translation_group`
- `seo_editorial_reviews` (rev)

**Translation Group ID Format:** `tg_{ULID16}` (separate namespace from row fingerprints)

**Rationale:**  
- **Concept** = "entity is the same, only label changes" → 1 row, jsonb is right
- **Content** = "each language is unique content with its own URL, slug, metadata" → separate rows
- jsonb keeps concept tables DRY (Wikidata link / ICD-10 / parent_fp shared across languages)
- translation_group_id enables consolidated performance queries:
  ```sql
  SELECT translation_group_id, sum(views) 
  FROM page_analytics 
  GROUP BY translation_group_id;
  ```
- Pattern matches existing keyword table's `translation_group` column (already production-tested)
- Source page flag enables canonical reference for hreflang generation

**Consequences:**
- ✅ Each table has clear multilingual semantics
- ✅ Content workflows (status per language, due dates per translation) supported
- ✅ Consolidated analytics across language versions possible
- ✅ hreflang generation has canonical source
- ⚠️ Pages: 1 entity = N pages (4 languages = 4 rows)
- ⚠️ Migration: existing page rows need `translation_group_id` backfill
- ⚠️ Constraint: only 1 `is_source_page = true` per group (UNIQUE INDEX with WHERE clause)

**Edge Cases:**
- Entity adds language: just add key to `canonical_names` jsonb (no new row)
- Page adds language: new row with same `translation_group_id`, `is_source_page = false`
- Translation removed: delete row, group still valid
- All translations of group deleted: orphaned group_id (cleanup periodically)

**References:**
- DR-003 (Single Entity, Multilingual Labels) — extended by this DR
- Bible Part 28 (Multilingual Architecture)
- Schema v1.8 §3-5 (table definitions per tier)

---

### [DR-008] — Two-Column Identity Pattern (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 18.9 (NEW)  
**Schema Reference:** v1.8

**Context:**  
Existing fingerprint patterns use composite of business fields:
- `page:vth-biodent:tmj-treatment`
- `entity:sleep-apnea`
- `vth-biodent::th::th::tmj รักษา` (keyword)

This works for **immutable** fields (keyword text never changes) but breaks for **mutable** fields (entity slug renames, page slug restructures, ICD-10 corrections by AI/expert review).

When a slug changes:
- All `parent_fp` references break
- All `related_fps[]` references break
- n8n sync loses match between Notion + Supabase
- Cross-table joins fail silently

Operator (เพื่อน) reported **real cases**: ICD-10 codes corrected after AI initial assignment, entity names refined after research, page slugs restructured during sitemap reorganization.

**Decision:**  
Adopt **Two-Column Identity Pattern** for all tables (except `seo_x_ads_keywords_contextual_master` which keeps existing format):

**Column 1 — `fingerprint text UNIQUE NOT NULL`:**
- **Purpose:** Machine identity, used for FK/joins/relations
- **Mutability:** IMMUTABLE (enforced by trigger)
- **Format:** `{tablecode}_{ULID16}` — e.g., `ent_01HZP5K2XQR7N3MF`
- **Generation:** Auto-generated by `generate_ulid()` PostgreSQL function on INSERT
- **Properties:**
  - 16 chars after prefix (Crockford Base32, time-encoded)
  - Lexicographically sortable by creation time
  - 80-bit entropy (collision-safe forever)
  - ~19 chars total (compact)

**Column 2 — `fingerprint_display_name text NOT NULL`:**
- **Purpose:** Human-readable label for debugging, admin UI, eyeball validation
- **Mutability:** MUTABLE (auto-refreshed by trigger when source data changes)
- **Format:** `{fp_last_6}::{type}::{slug_or_name}::{key_data}`
  - First segment = last 6 chars of fingerprint (cross-check)
  - `::` (double colon) separator
  - Per-table composition (entity uses ICD-10, page uses language+brand, etc.)
- **Examples:**
  - `N3MF::condition::sleep-apnea::G47.3`
  - `MFQR::pillar::airway-optimization::th::vth-biodent`
  - `ZX5N::vth-biodent::VTH BioDent`

**Exception — Keyword Table:**
`seo_x_ads_keywords_contextual_master` keeps existing format `{brand}::{market}::{language}::{keyword}` because:
- Keyword text is **immutable** (search terms don't change after entry)
- 12,526 rows in production with active n8n flows depending on this format
- Self-documenting (keyword visible in fingerprint enables debug)
- No display column needed — fingerprint already serves both purposes

**Table Codes (3-4 letters, mnemonic):**
| Code | Table | Code | Table |
|------|-------|------|-------|
| `ent` | seo_entity_graph | `auth` | seo_authors |
| `page` | seo_website_page_master | `doc` | seo_brand_doctors |
| `clus` | seo_topic_cluster_master | `brch` | seo_brand_branches |
| `kw` | (existing keywords, no migration) | `cite` | seo_citations |
| `brnd` | brands | `tg` | (translation_group namespace) |

**Rationale:**  
- **Stability**: ULID never changes → relations never break
- **Readability**: display_name reflects current data → debug-friendly
- **Cross-check**: last-6 of fingerprint embedded in display creates double validation
- **Industry standard**: ULID is widely supported, time-sortable, future-proof
- **Pure SQL**: No PostgreSQL extensions needed (Postgres 17 compatible)
- **Compact**: 19 chars vs UUID's 36 chars
- **Mutability boundaries clear**: machine column locked, human column refreshable

**Consequences:**
- ✅ Slug renames don't break any references
- ✅ Entity merges/redirects are clean (just change row, fingerprint stays)
- ✅ Two-Phase Hierarchy Sync (DR-006) more robust
- ✅ Debug detection: fingerprint vs display mismatch = data integrity issue
- ⚠️ Schema migration: add 2 columns to existing 12+ tables
- ⚠️ Triggers needed: auto-generate, prevent mutation, refresh display
- ⚠️ n8n workflows: must populate both columns on INSERT (or rely on triggers)
- ⚠️ Notion sync: send `fingerprint_display_name` to Notion as formula text

**Implementation Order:**
1. Create `generate_ulid()` function
2. Create `generate_*_display_name()` functions per table
3. ALTER existing tables: add columns (NULLable initially)
4. Backfill existing rows
5. Add triggers (insert, update, immutability)
6. Set NOT NULL constraint after backfill complete
7. Update n8n workflows to use new column

**References:**
- Bible Part 18.9 (NEW — Two-Column Identity Pattern)
- DR-006 (Two-Phase Hierarchy Sync) — strengthened by this pattern
- Schema v1.8 Appendix B (Fingerprint Patterns — rewritten)
- Helper functions: `generate_ulid()`, `generate_fingerprint_v2()`, per-table display generators

---

### [DR-007] — In-Place GTGT Schema Upgrade (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 5 (Database Schema Architecture)  
**Schema Reference:** v1.7 → v1.8

**Context:**  
Existing GTGT Supabase project (lffcbeszjqzioobqfdav, ap-northeast-1) contains:
- 13 production tables (brands, entity_graph, page_master, keyword pipeline, logs, etc.)
- 30 tracked migrations (2026-03-10 to 2026-03-23)
- 6 active n8n workflows (Notion ↔ Supabase sync)
- 25K+ keyword analytics rows (active feed: 5K-7K/day from 5 brands)
- 466 entities (287 VTH BioDent + 179 VitalSleep)
- 1,376 planned pages (all VitalSleep)

Bible v3.11 + Schema v1.7 specify ~17 additional tables and require schema changes (sync_state, parent_notion_id, multilingual jsonb, fingerprint normalization).

**Options Considered:**

| Option | Approach | Cost | Risk | Verdict |
|--------|----------|------|------|---------|
| A | New project (clean slate) | $25/mo | 🟢 LOW | ❌ Loses sweat equity |
| B | In-place upgrade GTGT | $0 | 🟡 MED | ✅ Chosen |
| C | 2 environments (GTGT+new) | $25/mo | 🟢 LOW | ❌ Over-engineering |
| D | Branch test first | $10/mo | 🟢 LOW | ⚠️ Optional add-on |
| E | Split DBs (keywords vs core) | $25/mo | 🟡 MED | ❌ Premature optimization |

**Decision:**  
**Option B — In-Place Upgrade** of GTGT to align with Schema v1.8.

**Strategy:**
- ALTER existing tables: add columns (idempotent IF NOT EXISTS)
- CREATE missing v1.8 tables (~17 new tables)
- Add triggers, functions, indexes
- **Data migration is OUT of scope** (existing entity/page data may be discarded — operator confirmed)
- **n8n workflow changes** deferred to later phase (compatibility maintained where possible)

**Rationale:**  
- 30 existing migrations show working in-place evolution discipline
- Solo developer scale (15 brands) doesn't justify multi-project overhead
- Cost-effective ($0 additional infrastructure)
- Existing keyword pipeline preserved without disruption
- Operator explicitly accepted that schema-first work doesn't require data preservation
- Notion FDW + sync infrastructure already in place

**Consequences:**
- ✅ Zero downtime migration possible (all changes additive)
- ✅ Existing n8n workflows continue running
- ✅ 30 historical migrations preserved as baseline
- ✅ No data export/import gymnastics
- ⚠️ Some legacy columns coexist with new pattern (graceful coexistence period)
- ⚠️ Migration must be careful with FK constraints
- ⚠️ Trigger overhead measured before production load

**Out of Scope (Phase 1):**
- Data migration (entity/page rebuild = future project responsibility)
- n8n workflow rewrites (will adapt later if needed)
- Notion database restructure (separate phase)
- WordPress integration (Phase 3+)
- Performance dashboards (Phase 4+)

**References:**
- Schema v1.8 (entire)
- Bible Part 5 (Database Schema Architecture)
- DR-008, DR-009, DR-010 (companion decisions for this upgrade)
- 30 GTGT historical migrations (in `supabase_migrations.schema_migrations`)

---

### [DR-006] — Two-Phase Hierarchy Sync Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Part 18.8  
**Schema Reference:** v1.7

**Context:**  
Hierarchical data (entities with parents, sitemap pages with parent pages, nested clusters) ต้องอยู่ใน 2 ระบบที่มี ID system ต่างกัน:
- **Supabase:** ใช้ text-based references (entity_fingerprint, sitemap_node_id) — portable, human-readable, planning-friendly
- **Notion:** ต้องใช้ native relations (UUID-based) สำหรับ tree UI rendering, rollups, expand/collapse

ที่ planning phase (markdown files), เรายังไม่มี Notion ID เลย — ต้องใช้ text references. แต่ที่ implementation phase, Notion ต้อง native relations เพื่อ render hierarchy บน UI.

**Decision:**  
Implement **Two-Phase Hierarchy Sync Pattern**:
- **Phase 1 (Flat Load):** Sync entities/pages/clusters เข้า Supabase + Notion ด้วย text-based parent references — ไม่มี relations ตอนนี้
- **Phase 2 (Backfill):** หลังทุก row มี notion_id แล้ว, backfill `parent_notion_id` ใน Supabase และ set `parent_relation` property บน Notion

**Required Schema Fields (v1.7):**
- `parent_notion_id` (text) — Phase 2 target
- `sync_state` (text) — tracks: flat_loaded / notion_synced / relations_backfilled / live

**Applies to All Hierarchical Tables:**
- seo_entity_graph
- seo_topic_cluster_master
- seo_website_page_master
- Future tables with parent relationships

**Rationale:**  
- ✅ Markdown planning ใช้ human-readable text refs (slug, sitemap_node_id)
- ✅ Editors ใน Notion เห็น tree UI (native relations)
- ✅ Pattern industry-standard (PostgreSQL deferred constraints + Notion API workflows)
- ✅ Failure recovery built-in (sync_state ทำให้ resume ได้)
- ✅ Idempotent (UPSERT-based, safe to retry)

**Alternatives Considered:**
- **Skip text parent, only use Notion relations:** ❌ ไม่สามารถวางแผนใน markdown ได้
- **Use UUID everywhere (markdown too):** ❌ Lose human readability, manual relation management hell
- **Skip Notion, use Supabase only:** ❌ Lose editorial UI benefits (tree view, expand/collapse)

**Consequences:**  
- ✅ Operators get planning flexibility (markdown) AND visual hierarchy (Notion)
- ✅ Same pattern reusable across all hierarchical tables
- ⚠️ n8n flows must implement 4-flow architecture (load, sync, backfill, ongoing)
- ⚠️ sync_state lifecycle requires monitoring/alerting
- ⚠️ Reconciliation jobs needed to detect drift

**References:**
- Bible Part 18.8 — Two-Phase Hierarchy Sync Pattern (full pattern doc)
- Schema_Overview v1.7 — adds parent_notion_id + sync_state to 3 tables
- EYWA_HANDOVER v1.1 Section 5.8 — explains for brand teams
- Industry: PostgreSQL deferred constraint loading pattern
- Industry: Notion API hierarchical data sync best practices

---

### [DR-005] — GitHub Distribution Strategy (2026-05-07)

**Status:** Locked  
**Bible Reference:** N/A (operational decision)

**Context:**  
EYWA Protocol ecosystem ต้อง distribute code, specs, per-brand content ในรูปแบบที่:
- ทีม access ได้ (cross-team collaboration)
- Version controlled (history + rollback)
- Permission-managed (private repos for proprietary content)
- Scalable (10+ brands)

**Decision:**  
3-level GitHub structure:

**Level 1 — Organization:** `the-gifted-digital`

**Level 2 — Universal Shared Repos (eywa-* prefix):**
- `eywa-protocol-spec` — Bible, Schema, Handover, DECISION_RECORDS
- `eywa-core` — Foundation plugin
- `eywa-cpt-activation` — CPT registration plugin
- `eywa-acf-fields` — ACF field group JSONs
- `eywa-schema-pipeline` — Schema generator plugin
- `eywa-elementor-templates` — Theme Builder JSON exports
- `eywa-db-migrations` — SQL migration scripts
- `eywa-n8n-flows` — n8n workflow exports
- `eywa-docs` — Public documentation (if needed)

**Level 3 — Per-Brand Repos (eywa-{brand} pattern):**
- `eywa-vth-biodent` — VTH BioDent content + config
- `eywa-vitalsleep` — VitalSleep content + config
- ... (one per brand)

**Visibility:** All repos Private by default.

**Rationale:**  
- Universal code in shared repos = deploy once, all brands benefit
- Brand-specific content separated = privacy + team isolation
- Federation pattern reflected at code level (mirror of database brand_scope concept)
- Easy team permission management (per-repo)
- Scales to 20+ brands without restructuring

**Consequences:**  
- ✅ Clear separation of universal vs brand-specific
- ✅ Permission boundaries match operational boundaries
- ⚠️ Bible/Schema updates require notification to all brand teams
- ⚠️ Cross-repo dependencies must be documented

**References:**  
- Bible Section 10.7 — Federation Pattern
- EYWA_HANDOVER Section 3 — Source of Truth Hierarchy

---

### [DR-004] — URL Structure: Subdirectory + Thai Default (2026-05-07)

**Status:** Locked  
**Bible Reference:** Part 28.2

**Context:**  
EYWA brands serve Thai-first audience (medical/dental clinics in Thailand). Multilingual support needed for:
- Medical tourism (English, Chinese, Japanese, Korean)
- Future expansion (Arabic, French, Spanish)

URL strategy options for multilingual:
- **A. Subdirectory:** `/en/`, `/zh/`, `/`(Thai default)
- **B. Subdomain:** `en.example.com`, `zh.example.com`
- **C. ccTLD:** `.co.th`, `.com`, `.cn`

**Decision:**  
Subdirectory pattern with Thai as default (no prefix), other languages prefixed:
- Default Thai: `https://example.com/services/dental-implants`
- English: `https://example.com/en/services/dental-implants`
- Chinese: `https://example.com/zh/services/dental-implants`

**Rationale:**  
- ✅ Single domain = cumulative SEO authority (vs spreading across subdomains/ccTLDs)
- ✅ Simpler hosting + SSL (one cert, one server config)
- ✅ Easier Google Search Console management (one property)
- ✅ Thai default reflects primary market reality
- ✅ WPML default + recommended pattern
- ✅ Easier hreflang implementation
- ✅ Shared backlink authority across languages

**Alternatives Rejected:**
- **Subdomain:** Splits authority across subdomains, complex hosting, separate GSC properties
- **ccTLD:** Highest cost, complex management, only justified for very large markets

**Consequences:**  
- ✅ Best SEO authority concentration
- ✅ Operationally simple
- ⚠️ Requires hreflang implementation (not optional)
- ⚠️ WPML must be configured correctly per brand

**References:**  
- Bible Part 28.2 — URL Structure for Multilingual
- Bible Section 28.7 — Schema Per Language
- Google: hreflang implementation guidelines
- WPML: subdirectory configuration docs

---

### [DR-003] — Single Entity, Multilingual Labels Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Part 28.3, Schema_Overview v1.6 Section 4.1

**Context:**  
Multilingual entity strategy options:
- **A. One entity per language with sameAs links** (e.g., separate "TMJ Disorder" + "โรค TMJ" + "顳下頜關節紊亂" entities)
- **B. Single entity with multilingual labels jsonb** (one entity, name varies per language)

**Decision:**  
Option B — single entity record per concept, with `canonical_names jsonb` field containing per-language values. Universal entity ID (entity_fingerprint) across all 8 supported languages.

**Schema Implementation:**
```sql
canonical_names jsonb DEFAULT '{}'
-- Structure: {"th": "...", "en": "...", "zh": "...", "ja": "...", ...}
```

**Rationale:**  
- ✅ Knowledge graph stays unified (1 concept = 1 entity)
- ✅ Edges defined once, not duplicated per language
- ✅ Wikidata mapping cleaner (1 Q-ID per entity)
- ✅ Scoring computed at entity level (cross-language signals consolidate)
- ✅ Schema generation simpler (entity → schema in target language)
- ✅ Translation workflow more straightforward

**Alternatives Rejected:**
- **One entity per language:** ❌ Graph fragmentation, edge duplication, unclear authority distribution

**Consequences:**  
- ✅ Simpler graph queries
- ✅ Cleaner schema
- ⚠️ Per-language scoring requires GREATEST() aggregation across languages
- ⚠️ Translation workflow must populate jsonb fields per language
- ⚠️ Missing translations need fallback strategy (default to Thai)

**References:**  
- Bible Part 28.3 — Multilingual Entity Strategy
- Schema_Overview v1.6 Section 4.1 — `canonical_names` field spec
- Wikidata: multilingual label pattern

---

### [DR-002] — Elementor Pro + Hello Theme Stack (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 25.11

**Context:**  
WordPress frontend stack choice for EYWA brand sites. Options:
- **A. Custom Gutenberg blocks** — full programmatic control
- **B. Page Builder (visual)** — designer-friendly
- **C. Hybrid** — combination

**Decision:**  
Hello Elementor theme + Elementor Pro + ACF Pro + RankMath Pro + WPML stack.

Specifically:
- **Hello Elementor** — minimal theme (no built-in styles, fast)
- **Elementor Pro** — Theme Builder + Loop Builder + Dynamic Tags
- **ACF Pro** — custom fields + JSON sync + WPML compat
- **RankMath Pro** — SEO + hreflang + breadcrumbs
- **WPML** — multilingual

**Plugin count reduced:** 5 → 4 EYWA custom plugins (Loop Builder replaces eywa-related-blocks)

**Rationale:**  
- ✅ Designer-friendly (zero-PHP layouts via Elementor UI)
- ✅ Theme Builder = single template per CPT, conditional logic native
- ✅ Loop Builder replaces custom Gutenberg blocks
- ✅ Dynamic Tags pull ACF data automatically
- ✅ Industry-standard, extensive community + docs
- ✅ Reduced custom plugin count = less maintenance
- ✅ Designer can iterate without dev intervention

**Alternatives Rejected:**
- **Pure Gutenberg:** Too programmatic, designers can't iterate
- **Bricks Builder:** Smaller community, fewer integrations
- **Divi:** Bundled theme too opinionated, harder to customize

**Consequences:**  
- ✅ 80% of design work in Elementor UI (designer autonomy)
- ✅ Reduced custom plugin count
- ⚠️ Elementor Pro license cost ($59-399/site/year)
- ⚠️ Hello theme has no built-in schema → EYWA Schema Pipeline plugin handles
- ⚠️ Performance must be monitored (Elementor + WPML can be heavy)

**References:**  
- Bible Section 25.11 — Elementor Pro Integration
- Bible Section 25.8 — Template Hierarchy
- Industry: Hello Elementor + ACF + WPML pattern

---

### [DR-001] — Multi-Brand Federation Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 10.7

**Context:**  
EYWA system needs to support managing 5-20 healthcare/wellness brands. Architectural choice:
- **A. Fully separate per-brand systems** — 1 Supabase + 1 Notion + 1 WP per brand
- **B. Single mega-system** — Everything merged
- **C. Federation pattern** — Shared backend, isolated frontends

**Decision:**  
**Option C — Federation pattern:**

**Shared (Federation Backend):**
- 1 Supabase database (with brand_scope[] column on relevant tables)
- N Notion workspaces (per editorial team)
- 1 n8n instance (for sync orchestration)

**Isolated (Per-Brand Frontend):**
- N WordPress sites (one per brand)
- Each pulls only its brand's data via brand_scope filter
- Independent domains, themes, content

**Rationale:**  
- ✅ Schema upgrade once for all brands (vs N migrations)
- ✅ Citations/entities sharable when relevant (`brand_scope=['*']`)
- ✅ Generic medical entities (TMJ, sleep apnea) defined once
- ✅ Cross-brand visibility for operators
- ✅ Resource sharing (citations researched once benefit all)
- ✅ Brand isolation enforced via `brand_scope` filter
- ✅ Frontend autonomy preserved (per-brand WordPress)
- ✅ Cross-brand referrals = native feature
- ✅ Onboarding new brand = data, not architecture

**Alternatives Rejected:**
- **Full separation:** Schema migrations exponential, citation duplication, no cross-brand visibility
- **Full merger:** Permission nightmare, brand isolation hard, frontend coupling

**Decision Evolution:**
- Original draft included `teams` table — REMOVED (over-engineering)
- Team management via Notion ACL + n8n flow ENV vars (lighter)

**Consequences:**  
- ✅ Efficient cross-brand operations
- ✅ Right-sized for portfolio operators (5-20 brands)
- ⚠️ Notion workspace topology requires manual setup per team
- ⚠️ brand_scope validation must happen in n8n flow config (not DB-level)
- ⚠️ Editorial isolation via Notion permissions (not DB-level RLS)

**References:**  
- Bible Section 10.7 — Operational Multi-Brand Federation Pattern
- Bible Section 4.12 — Cross-Brand External Link Tracking
- Bible Section 18.7 — Multi-Workspace Sync Strategy
- Schema_Overview v1.6 — brand_scope[] field on all relevant tables

---

## Future Decision Topics

Decisions to be documented as they emerge:

- [ ] **DR-011:** WordPress hosting strategy (per-brand or shared?)
- [ ] **DR-012:** Supabase project tier + scaling strategy
- [ ] **DR-013:** n8n hosting strategy (self-hosted vs cloud)
- [ ] **DR-014:** Translation provider selection (Claude vs GPT-4 vs DeepL)
- [ ] **DR-015:** Editorial review workflow tooling
- [ ] **DR-016:** CDN strategy (Cloudflare, BunnyCDN, etc.)
- [ ] **DR-017:** Image optimization pipeline
- [ ] **DR-018:** Analytics stack (GA4 + custom + ?)
- [ ] **DR-019:** Backup + disaster recovery strategy
- [ ] **DR-020:** Migration repo strategy (separate vs subfolder)
- [ ] **DR-021:** Notion database sync scope (which tables sync)
- [ ] **DR-022:** Branch testing protocol for migrations

---

## Maintenance Rules

```yaml
decision_record_governance:
  
  who_can_add:
    - Operator (final authority)
    - Claude/AI (proposes — operator approves)
    - Tech leads (with operator sign-off)
  
  what_must_be_documented:
    - Architectural choices (database design, framework selection)
    - Strategic patterns (federation, multilingual, sync)
    - Trade-off decisions (cost vs features, speed vs quality)
    - Anything that future developers/AI will ask "WHY did we do it this way?"
  
  what_does_NOT_belong:
    - Implementation details (use code comments)
    - Bug fixes (use commit messages)
    - Daily operational decisions (use issue tracker)
  
  format_discipline:
    - Sequential numbering (never reuse numbers)
    - Append-only (don't delete — supersede instead)
    - Cross-reference Bible sections + related DRs
    - Date stamp every entry
  
  review_cadence:
    - Quarterly: review all DRs for relevance
    - When superseded: mark old DR + reference new DR
    - When implemented: update Status to "Locked"
```

---

*This document is part of the EYWA Protocol governance suite. For updates, see GitHub: `the-gifted-digital/eywa-protocol-spec/DECISION_RECORDS.md`*
