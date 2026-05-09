# 🧠 EYWA™ PROTOCOL — Project Memory

> **Purpose:** Single context file. Read this first to understand the entire project in 5 minutes.  
> **Audience:** Claude/AI sessions, new team members, future-self after a break  
> **Last updated:** 2026-05-09  
> **Maintained by:** The Gifted Digital Marketing Co., Ltd.

---

## 🌿 Quick Identity

**EYWA™ PROTOCOL** is a Universal Knowledge Graph SEO Specification managing 15 brands across healthcare, wellness, and media verticals. It treats SEO as a knowledge graph problem — every page anchors to entities, every entity participates in typed relationships, every relationship maps to schema.org markup for AI engine citation (LLMO).

```yaml
trademark: EYWA™ (filed 2026-04-20, Class 35+42, DIP Thailand)
operator: The Gifted Digital Marketing Co., Ltd.
flagship_brand: VTH BioDent (founder: Naphannop S.)
total_brands: 15 (healthcare + wellness + media)
primary_market: Thailand (TH default, EN secondary, expanding to JA/CN)
git_repo: the-gifted-digital/eywa-protocol-spec
session_environment: 1 Supabase + n8n + Notion + WordPress shared backend
```

**Why this exists:** Traditional SEO treats pages as standalone documents. EYWA treats them as nodes in a knowledge graph — when AI engines (ChatGPT, Claude, Perplexity, Gemini) cite content, they prefer entity-anchored, schema.org-rich, citation-tier-evidenced material. EYWA codifies this into a reproducible protocol across 15 brands.

---

## 🏗️ Stack & Infrastructure

```yaml
supabase:
  project: GTGT (single project, in-place schema upgrade — per DR-007)
  project_id: lffcbeszjqzioobqfdav
  region: ap-northeast-1
  postgres_version: 17.6.1
  required_extensions:
    - pgcrypto, uuid-ossp (UUID generation)
    - pg_trgm (fuzzy search + EUG Layer 3b)
    - vector / pgvector (embeddings + EUG v2.0 future)
    - postgis (geo queries — branches, local rankings)
  tables: 28 organized into 9 groups
  
n8n:
  role: "Workflow automation (Notion ↔ Supabase sync, DataForSEO, GSC, GA4)"
  active_workflows: 6
  
notion:
  role: "Human-facing planning + editorial collaboration"
  sync_pattern: "N↔S for editorial concept tables; S-only for high-volume facts"
  
wordpress:
  per_brand: yes (multi-site, federation pattern)
  page_builder: Elementor Pro (per DR-002)
  schema_generator: eywa-schema-pipeline (custom plugin)
  acf_field_groups: eywa-acf-fields (custom)
  rank_math: SEO meta + schema fallback
  
data_sources:
  - DataForSEO (keyword volume, SERP, backlinks)
  - Google Search Console (GSC API)
  - Google Analytics 4 (GA4 API)
  - PubMed (medical citation enrichment)
  - Wikidata (entity linking)
```

---

## 🌐 Multi-Brand Portfolio (15 brands)

```yaml
healthcare_vertical:
  vth-biodent:
    full_name: "VTH BioDent"
    format: "dental + integrative medicine"
    founder: Naphannop S.
    role: "Flagship brand — Stream B proposer, EGP testbed"
    methodologies: ["Mouth Bio Mapping", "PNCL Medicine", "BJGML Axis"]
  
  vitalsleep-and-wellness:
    full_name: "VitalSleep and Wellness"
    format: "sleep_medicine + wellness"
  
  the-face-by-vertex:
    format: "aesthetic + dermatology"
  
  the-face-hospital:
    format: "hospital (multi-specialty)"
  
  # ... + 11 more brands across wellness, media verticals

federation_pattern:
  brand_scope:
    universal: ['*']
    single_brand: ['vth-biodent']
    shared_2_or_more: ['vth-biodent', 'vitalsleep']
  rule: "Entity is universal by default; brand_scope[] limits visibility"
```

---

## 🧩 Core Concepts (Memorize These)

### 1. Knowledge Graph Architecture (Bible Part 2)

```yaml
entities:
  count_target: "500-2,000 entities per brand portfolio"
  types: 15 (condition, symptom, procedure, treatment, device, concept, product, drug, ingredient, anatomy, specialty, lab_test, biomarker, person, organization)
  storage: seo_entity_graph
  
edges:
  count: 10 (LOCKED — per DR-012)
  vocabulary:
    - parent_of / child_of (composition)
    - subtype_of (is-a)
    - treats / treated_by (therapeutic)
    - symptom_of (manifestation)
    - uses / used_by (operational)
    - alternative_to (preference)
    - part_of / contains (containment)
    - requires_assessment (diagnostic dependency)
    - evidenced_by (research)
    - related_to (catch-all bidirectional)
  storage: seo_entity_relationships
  expansion_in_review: "+causes/caused_by, +contraindicates (DR-013 Proposed)"
  
clusters:
  hub_spoke_pattern: "1 pillar (L5) + 8-25 supporting pages"
  storage: seo_topic_cluster_master
  governance: "SKOS lifecycle (pending_review → active → deprecated → merged)"
```

### 2. Two-Column Identity Pattern (Bible §18.9, DR-008)

Every table (except `seo_x_ads_keywords_contextual_master`) has:

```sql
fingerprint              text UNIQUE NOT NULL  -- IMMUTABLE machine ID (e.g., ent_01HZP5K2XQR7N3MF)
fingerprint_display_name text NOT NULL          -- MUTABLE human label (e.g., n3mf::condition::sleep-apnea::g47.3)
```

- `fingerprint` format: `{tablecode}_{ULID16}` (Crockford Base32)
- Used for ALL FK references (replaces natural IDs)
- Auto-generated by `trg_set_fingerprint_*()` triggers
- Display name auto-refreshed when source data changes

### 3. Entity Uniqueness Guard (EUG, Bible §2.6.6.1, DR-011)

3-layer protection against duplicate entities:

```yaml
layer_1_unique_constraint:
  rule: UNIQUE (entity_slug, brand_scope_primary)
  enforcement: PostgreSQL native CHECK
  
layer_2_normalize:
  function: normalize_entity_slug(text)
  trigger: BEFORE INSERT/UPDATE
  effect: "TMJ_Therapy / tmj_therapy / TMJ-therapy → all become 'tmj-therapy'"
  
layer_3a_alias_collision:
  function: check_alias_collision(slug, aliases, brand_scope)
  scans: canonical_names + aliases jsonb
  blocks: synonym duplicates across languages
  
layer_3b_trigram_similarity:
  function: find_similar_entities(slug, threshold, brand_scope)
  thresholds:
    - ≥0.90 → BLOCK_likely_typo
    - 0.75-0.90 → WARN_high_similarity
    - 0.60-0.75 → INFO_moderate

coverage_v1: "~85% of duplicate scenarios"
v2_roadmap: "Layer 4 (vector similarity) when pgvector + embeddings live"
implementation: "Schema v1.9 Appendix G (full SQL ~450 lines)"
```

### 4. Multilingual Strategy v2 (Bible Part 28, DR-009)

Two-tier pattern based on data semantics:

```yaml
tier_1_concept_tables:
  pattern: "1 row + jsonb translations"
  used_for: entity_graph, topic_cluster, brands, authors, branches, citations
  columns: "canonical_names jsonb, aliases jsonb, descriptions jsonb"
  example: '{"en": "Sleep Apnea", "th": "ภาวะหยุดหายใจขณะหลับ"}'
  
tier_2_content_tables:
  pattern: "1 row per language + translation_group_id"
  used_for: page_master, keywords, editorial_reviews
  columns: "translation_group_id text, page_language text, is_source_page boolean"
  rule: "Exactly 1 source per group (enforced by partial unique index)"
```

### 5. Page Three-Dimensional Tagging (Bible Part 3)

Every page has 3 orthogonal classifications:

```yaml
seo_layer: "L1..L7 (Home → Money Pages → Service Pages → Concern Pillars → Knowledge Hub → Local → Evidence)"
seo_tier: "A (Pillar) / B (Supporting) / C (Peripheral) / D (Tagged)"
funnel_stage: "top / mid / bottom / retention"
page_type: "A (Standard) / B (Branch Landing) / C (Programmatic) / D (Tagged)"
```

### 6. Citation Tier System (Bible Part 23.1)

6-tier evidence hierarchy for citations (used by AI engines as authority signal):

```yaml
tier_1: "Cochrane reviews, meta-analyses (highest authority)"
tier_2: "Randomized controlled trials, clinical guidelines"
tier_3: "Cohort studies, observational research"
tier_4: "Case studies, expert opinion"
tier_5: "Textbooks, encyclopedias"
tier_6: "Press releases, marketing content (lowest)"

required_for: "All medical content (Bible Part 23.4 Stage 1 review)"
storage: "seo_citations.evidence_tier + schema_evidence_level"
```

---

## 📋 Decision Records (DR-001..DR-014)

### Locked Decisions

```yaml
DR-001: Multi-Brand Federation Pattern (brand_scope[] columns everywhere)
DR-002: Elementor Pro Page Builder + WordPress stack
DR-003: Single Entity Multilingual (Tier 1 jsonb pattern)
DR-004: URL Subdirectory + Thai Default (e.g., site.com/ for TH, site.com/en/ for EN)
DR-005: GitHub 3-Level Structure (eywa-protocol-spec + brand-skeleton + per-brand-data)
DR-006: Two-Phase Hierarchy Sync (Notion-first planning → Supabase relations → live)
DR-007: In-Place GTGT Schema Upgrade (single Supabase project, in-place migrations)
DR-008: Two-Column Identity Pattern (fingerprint + fingerprint_display_name)
DR-009: Multilingual Strategy v2 (Tier 1 jsonb + Tier 2 translation_group)
DR-010: Brand Scope Architecture (canonical brand_slug, kebab-case, immutable)
DR-011: Entity Uniqueness Guard (Two-Wave: v1.0 now, v2.0 vector future)
DR-012: Edge Vocabulary Evolution Policy (10 LOCKED, 4-criteria + 2-week review for additions)
```

### Proposed Decisions (Pending 2026-05-15 Review)

```yaml
DR-013_proposed:
  title: "Edge Vocabulary v3.5 Expansion"
  proposes: "Add causes/caused_by + contraindicates edges (10 → 12)"
  source: "Stream B work order from VTH BioDent EGP work (Naphannop S.)"
  governance_status:
    C1_real_cases: "⏳ In Collection (Notion governance database)"
    C2_cross_brand: "⏳ PENDING canvass (critical blocker — deadline 2026-05-13)"
    C3_schema_org: "✅ Documented (causeOf, riskFactor, contraindication)"
    C4_orthogonal: "✅ Architect verified"
  schema_review_board: 2026-05-15
  lock_target: 2026-05-20
  if_locked: "Triggers Bible v3.14 + Schema v1.10 + 5 SQL migrations build"
  if_rejected: "VTH BioDent uses related_to + notes + brand_scope workaround"

DR-014_proposed:
  title: "Concept Entity Subtype Lock"
  proposes: "Lock 'framework' + 'axis' as controlled vocabulary for concept entity_subtype"
  paired_with: DR-013
  examples: "framework: pncl-medicine | axis: bjgml-axis (VTH BioDent)"
```

### Future Placeholders

```yaml
DR-015..DR-026:
  - WordPress hosting strategy (per-brand or shared)
  - Supabase project tier + scaling
  - n8n hosting strategy
  - Translation provider (Claude vs GPT-4 vs DeepL)
  - Editorial review workflow tooling
  - CDN strategy (Cloudflare, BunnyCDN)
  - Image optimization pipeline
  - Analytics stack
  - Backup + disaster recovery
  - Migration repo strategy
  - Notion sync scope
  - Branch testing protocol
```

---

## 📚 Documentation Hierarchy (What's Canonical)

```yaml
source_of_truth_chain:
  
  EYWA_PROTOCOL_v3_13.md:
    role: "THE BIBLE — full specification (canonical)"
    version: 3.13 (2026-05-08)
    size: "936 KB / 25,269 lines"
    contains:
      - "Part 1-28 + Appendices A-G"
      - "Section 2.6.6.1 EUG v1.0 (NEW v3.13)"
      - "Section 2.6.6.2 EUG v2.0 Roadmap (NEW v3.13)"
      - "Section 2.7.10 Edge Vocabulary Evolution Policy (NEW v3.13)"
    rule: "Only LOCKED content. Proposed decisions go in DECISION_RECORDS."
  
  Schema_Overview_EYWA_v1_9.md:
    role: "Database schema companion"
    version: 1.9 (2026-05-08)
    size: "104 KB / 2,522 lines"
    contains:
      - "28 tables across 9 groups"
      - "DDL specifications + indexes + triggers"
      - "Appendix G: EUG SQL implementation (~450 lines, NEW v1.9)"
  
  EYWA_HANDOVER.md:
    role: "Operating manual for Claude/AI sessions"
    version: 1.5 (2026-05-09)
    size: "70 KB / 1,782 lines"
    contains:
      - "Section 6: Phase 1 status + open items"
      - "Section 6.7: Session history (chronological log)"
      - "Section 10: Pre-Flight checklist"
  
  DECISION_RECORDS.md:
    role: "Decision history + rationale (Locked + Proposed)"
    version: 1.3 (2026-05-09)
    size: "65 KB / 1,521 lines"
    contains:
      - "DR-001 through DR-014"
      - "Reverse chronological (newest first)"
      - "Rationale, alternatives, consequences for each DR"
  
  PHASE_1_DECISIONS.md:
    role: "Phase 1 execution quick reference"
    version: 1.2 (2026-05-09)
    size: "12 KB / 343 lines"
    contains:
      - "Phase 1A migration plan"
      - "Open operational items (DR-022, DR-024, DR-025)"
  
  README.md:
    role: "Repo entry point + governance overview"
    version: 1.5 (2026-05-09)
    contains:
      - "Documents table"
      - "Decision Records Status"
      - "Latest Update v3.13 highlights"
      - "Governance Update (DR-013/014 Proposed)"

archived (historical reference only):
  - EYWA_PROTOCOL_v3_11.md (2026-05-07)
  - EYWA_PROTOCOL_v3_12.md (2026-05-08)
  - Schema_Overview_EYWA_v1_7.md
  - Schema_Overview_EYWA_v1_8.md
```

---

## 🚀 Phase 1 Status

```yaml
phase_1A_specs_locked:
  status: "✅ Specifications complete, ready to write SQL migrations"
  
  migrations_to_write: 6 files (15-20h dev effort)
  
  001_create_extensions.sql:
    - "pgcrypto, uuid-ossp, pg_trgm, vector, postgis"
  
  002_create_helper_functions.sql:
    - "generate_ulid()"
    - "generate_fingerprint_v2(prefix)"
    - "Per-table display_name generators"
    - "trg_set_fingerprint_*() triggers"
    - "trg_prevent_fingerprint_change() trigger"
    - "trg_refresh_display_name_*() triggers"
  
  003_alter_existing_tables_two_column.sql:
    - "Add fingerprint + fingerprint_display_name to brands, entity_graph, page_master, etc."
    - "Migration step: backfill existing records"
  
  004_add_multilingual_columns.sql:
    - "canonical_names jsonb, aliases jsonb, descriptions jsonb"
    - "translation_group_id on content tables"
  
  005_add_brand_slug.sql:
    - "Per DR-010 brand_scope architecture"
    - "Add CHECK constraint for kebab-case validation"
  
  006_create_entity_uniqueness_guard.sql:
    - "Per DR-011 EUG implementation"
    - "Reference: Schema v1.9 Appendix G"
    - "4 functions + 4 indexes + 1 constraint + 1 trigger"

phase_1A_blockers: NONE — all specs ready

phase_1B_C_D_planning:
  total_files: ~21 additional SQL files
  estimated_effort: ~50-70 hours total
  
phase_1E_conditional:
  trigger: "DR-013/014 LOCKED on 2026-05-20"
  files: 5 additional SQL migrations
  scope:
    - Extend edge_type CHECK to 16 enum values
    - Add edge_evidence_citation field
    - Add medical_reviewer_signoff fields
    - Add concept_subtype CHECK constraint
    - Add edge validation triggers
  if_DR_013_rejected: "Phase 1E cancelled, VTH uses workaround"
```

---

## 🌊 Active Workstreams

### Stream A — Locked v3.13/v1.9 (Completed 2026-05-08/09)

```yaml
status: ✅ Locked and uploaded to Git
deliverables:
  - Bible v3.11 → v3.13
  - Schema v1.8 → v1.9
  - Handover v1.3 → v1.5
  - DECISION_RECORDS v1.1 → v1.3
  - 6 canonical files in Git
new_decisions: DR-011 (EUG) + DR-012 (Edge Evolution Policy)
```

### Stream B — Proposed, Pending Review (Active)

```yaml
status: 🌱 Proposed (DR-013 + DR-014)
proposer: Naphannop S. (VTH BioDent founder)
origin: "Field-tested feedback from real EGP work — not speculative proposal"
governance: "First test of DR-012 (Edge Vocabulary Evolution Policy)"

action_items_this_week:
  
  2026_05_10_to_05_13:
    architect_tasks:
      ☐ Canvass 14 other brands for cross-brand evidence (Criterion 2)
      ☐ Create Notion governance database to track responses
    naphannop_tasks:
      ☐ Document 3+ VTH BioDent cases (Criterion 1)
      ☐ Provide entity pairs + why existing 10 edges insufficient
  
  2026_05_15_schema_review_board:
    duration: ~1 hour
    participants:
      - Operator (final authority)
      - Naphannop S. (proposer)
      - Architect
      - ≥1 cross-brand representative (if C2 confirmed)
    decision_options:
      A_LOCK: "All 4 criteria met → trigger Bible v3.14 + Schema v1.10 build"
      B_REJECT: "C2 fails → VTH uses workaround pattern"
      C_REVISE: "Partial pass → revise scope (e.g., causes only)"
  
  2026_05_16_to_05_20_if_locked:
    estimated_effort: "58-64 hours (Architect + Tech Lead)"
    deliverables:
      - Bible v3.14 (6 sections updated)
      - Schema v1.10 (3 sections + new fields)
      - 5 SQL migrations (Phase 1E)
      - eywa-schema-pipeline plugin updates
      - eywa-acf-fields field group updates
```

### VTH BioDent Workaround Pattern (Active Now)

If immediate work needed before DR-013/014 lock:

```yaml
for_etiological_relationships:
  edge_type: related_to
  edge_note: "etiological-direct" / "etiological-contributing" / "etiological-developmental"
  brand_scope: ['vth-biodent']
  example:
    from: bruxism
    to: tmj-disorder
    edge_type: related_to
    edge_note: "etiological-direct (bruxism causes mechanical-stress on TMJ)"
  
for_safety_contraindications:
  edge_type: alternative_to
  edge_note: "safety-contraindication-absolute" / "safety-contraindication-relative"
  brand_scope: ['vth-biodent']
  example:
    from: dental-implant-surgery
    to: bisphosphonate-therapy
    edge_type: alternative_to
    edge_note: "safety-contraindication-absolute (BRONJ risk)"
  
for_concept_subtypes:
  entity_type: concept
  entity_subtype: "framework" or "axis" (manually applied, not yet enforced)
  brand_scope: ['vth-biodent']

if_DR_013_locks:
  migration: "Mechanical relabel script — edge_note → edge_type conversion"
  effort: "~5 minutes per brand to migrate"
```

---

## 🗓️ Critical Path Timeline

```yaml
2026_05_07: 
  - Bible v3.11 published
  - DR-001..DR-006 locked
  - Schema v1.7 published

2026_05_08:
  - Bible v3.12 published (Two-Column Identity)
  - Schema v1.8 published
  - DR-007..DR-010 locked
  - Stream A architect work started

2026_05_09 (TODAY):
  morning: 
    - Bible v3.12 → v3.13 (EUG + Edge Evolution Policy)
    - Schema v1.8 → v1.9 (EUG implementation)
    - DR-011 + DR-012 locked
    - 5 canonical files delivered
  afternoon:
    - Stream B work order arrived (Naphannop, VTH BioDent)
    - DR collision resolved (rename Stream B → DR-013/014)
    - DR-013 + DR-014 set to Proposed status
    - Hybrid governance strategy applied
    - 6 canonical files in Git + project memory created

2026_05_10_to_05_13:
  - Architect canvasses 14 brands for cross-brand evidence
  - Naphannop documents 3+ VTH BioDent cases

2026_05_15:
  - Schema Review Board meeting
  - Decision: LOCK / REJECT / REVISE on DR-013/014

2026_05_16_to_05_20_if_locked:
  - Build Bible v3.14 + Schema v1.10
  - Write 5 SQL migrations (Phase 1E)
  - Update plugins (schema-pipeline + acf-fields)

2026_05_20_target:
  - If locked: Stream B v3.5 release
  - If rejected: Workaround documented, v3.13 stays canonical

parallel_track_phase_1A:
  any_time_independent_of_DR_013_014:
    - Write 6 SQL migrations (001-006)
    - Test on Supabase dev branch
    - Deploy to GTGT production
    - n8n workflow integration tests
```

---

## 🛠️ Working Conventions

### Naming Standards

```yaml
tables:
  prefix: "seo_" (except brands)
  naming: snake_case, plural noun
  modifiers:
    _master: "primary canonical table"
    _x_: "junction/cross-reference"
    _data: "aggregate stats"
    _links: "individual records"
    _history: "time-series archive (deprecated)"

columns:
  identifiers:
    id: "uuid primary surrogate key"
    fingerprint: "canonical machine ID (v1.8+)"
    fingerprint_display_name: "human label (v1.8+)"
    *_fp: "fingerprint reference in arrays"
    *_id: "FK uuid"
    notion_id: "Notion page ID for sync"
  
  timestamps:
    created_at, updated_at, *_synced_at, *_at
  
  booleans:
    is_*, has_*, *_required
  
  arrays:
    *s (plural): "medical_specialty, accreditations"
    *_fps: "arrays of fingerprints"
```

### Fingerprint Format

```yaml
pattern: "{tablecode}_{ULID16}"
encoding: "Crockford Base32 (no I, L, O, U)"
length: ~20 chars total

table_codes:
  ent: entity
  page: page_master
  clus: topic_cluster
  brnd: brands
  auth: authors
  doc: doctor_assignments
  brch: branches
  cite: citations
  pcit: page_citations
  rel: entity_relationships
  rev: editorial_reviews
  tg: translation_group

display_name_formula:
  brand: "{fp_last_6}::{brand_slug}::{brand_name}"
  entity: "{fp_last_6}::{entity_type}::{entity_slug}::{icd_10_code}"
  page: "{fp_last_6}::{layer}::{slug}::{language}::{brand_slug}"
  # ... per-table specific
```

### Brand Scope Rules (DR-001 + DR-010)

```yaml
brand_scope_pattern:
  universal: ['*']  # All brands
  single: ['vth-biodent']  # One brand only
  shared: ['vth-biodent', 'vitalsleep']  # Specific brands
  
default: ['*'] (universal)

semantics:
  - "Entity is universal by default"
  - "brand_scope[] LIMITS visibility, doesn't grant"
  - "Healthcare-specific entities likely brand_scope=['*'] within healthcare brands"
  - "Brand IP (e.g., 'Mouth Bio Mapping') uses brand_scope=['vth-biodent']"
```

### Sync Patterns

```yaml
N↔S (Notion ↔ Supabase bidirectional):
  - brands, branches, authors, doctor_assignments
  - entity_graph, topic_cluster, citations, entity_relationships
  - page_master, editorial_reviews
  - keywords_master (master only — snapshots are S-only)

S only (Supabase only, high-volume):
  - Performance fact tables (daily_logs, local_rankings)
  - Backlinks (data + links)
  - AI operations (mentions, citations, simulations)
  - Embeddings (vector storage)
  - Data quality metrics
  - Schema changes (audit trail)
```

---

## 🤖 AI Operator Quick Reference

### Pre-Flight Checklist (Read Before Any Work)

```yaml
context_gathering:
  ☐ This file (PROJECT_MEMORY.md)
  ☐ EYWA_HANDOVER.md Section 6 (Phase 1 status + open items)
  ☐ DECISION_RECORDS.md (DR-001..DR-014 — what's locked, what's proposed)
  ☐ Bible v3.13 sections relevant to task
  ☐ Schema v1.9 sections relevant to task

before_writing_code:
  ☐ Verify brand_scope for entities
  ☐ Use fingerprint for FK relations (not natural IDs)
  ☐ Check EUG before INSERT entities (pre-flight check)
  ☐ Use 10 locked edges only (no causes/contraindicates yet)
  ☐ Apply Two-Column Identity to any new tables

before_proposing_changes:
  ☐ Check if change is Locked or requires DR
  ☐ Read DR-012 governance for edge vocabulary changes
  ☐ Read DR-007 governance for schema migration changes
  ☐ Reference Bible section for "why" each design choice exists
```

### When to Read Which File

```yaml
working_on_entity_creation_EGP:
  primary: Bible §2.6 (Entity Genesis Protocol)
  also: Bible §2.6.6.1 (EUG), Schema §4.1, Schema Appendix G

working_on_relationships_edges:
  primary: Bible §2.7 (Edge Vocabulary)
  also: Bible §2.7.10 (Evolution Policy), Schema §4.5
  
working_on_pages_sitemap:
  primary: Bible Part 3 + Part 4 (Sitemap Architecture)
  also: Bible §9 (Template Anatomy), Schema §5.1

working_on_schema_markup:
  primary: Bible Part 26 (Schema Generation Pipeline)
  also: Bible §6 (Citation Patterns), Bible §13 (LLMO)

working_on_multilingual:
  primary: Bible Part 28 (Multilingual Strategy)
  also: Schema Appendix E, DR-009

working_on_database_migrations:
  primary: Schema v1.9 + PHASE_1_DECISIONS.md
  also: Bible Part 5 (Database Schema), Bible §15 (Schema Governance)
  reference: Schema Appendix F (helper functions), Appendix G (EUG)

working_on_n8n_workflows:
  primary: Bible Part 17 (n8n Flow Library)
  also: Bible §18 (Notion sync architecture)

working_on_scoring:
  primary: Bible Part 27 (Scoring Framework)
  fields: All *_score columns in Schema (entity_authority, page_e_e_a_t, etc.)

working_on_VTH_BioDent_specific:
  primary: brand-config + brand-concept files (per-brand repo)
  also: This memory file (workaround pattern section)
  watch: DR-013/014 status (might unblock if locked 2026-05-20)
```

### Common Mistakes to Avoid

```yaml
mistake_1_using_old_natural_keys:
  wrong: "Use brand_name as FK reference"
  right: "Use brands.fingerprint as FK reference (v1.8+ standard)"

mistake_2_proposing_new_edges_without_DR:
  wrong: "Just add 'measures' edge to entity_graph"
  right: "Read DR-012, satisfy 4 criteria, propose via DR, await review"

mistake_3_skipping_EUG_preflight:
  wrong: "Direct INSERT into seo_entity_graph"
  right: "Call eug_preflight_check() first, handle BLOCK/WARN/CLEAN response"

mistake_4_brand_scoping_universal_concepts:
  wrong: "brand_scope=['vth-biodent'] for 'sleep apnea' entity"
  right: "brand_scope=['*'] (universal medical concept), use brand_display_names jsonb for marketing variations"

mistake_5_putting_proposed_in_Bible:
  wrong: "Add DR-013 causes edge to Bible §2.7.2"
  right: "DR-013 stays in DECISION_RECORDS until lock; Bible only has LOCKED content"

mistake_6_breaking_two_column_identity:
  wrong: "Update fingerprint when entity_slug changes"
  right: "fingerprint is IMMUTABLE; trg_prevent_fingerprint_change() blocks this"

mistake_7_forgetting_brand_scope_primary:
  wrong: "Plain UNIQUE on entity_slug"
  right: "UNIQUE on (entity_slug, brand_scope_primary) — allows same slug across brands"
```

---

## 🎯 Mental Models for AI Sessions

### "Why Three Documents Instead of One Bible?"

```yaml
separation:
  Bible (WHAT):
    - Current rules of the system
    - Only LOCKED content
    - Like a constitution
  
  DECISION_RECORDS (WHY):
    - History + rationale of decisions
    - Both Locked + Proposed
    - Like congressional records
  
  HANDOVER (HOW):
    - Operating manual for AI sessions
    - Phase status + checklists
    - Like an employee onboarding doc

result: "Each file has clear role, no overlap, easy to update without conflicts"
```

### "Why Governance Matters at 15 Brands"

```yaml
without_governance:
  - 15 brands × 5 architects = 75 ad-hoc decisions per year
  - Ontology drift (same concept, different edges per brand)
  - Schema markup inconsistency (AI engines see fragmented data)
  - New brand onboarding = "figure it out"
  - Future Claude/AI sessions can't trust spec consistency

with_DR_governance:
  - All decisions traceable to DR-NNN
  - 4-criteria + review process catches premature additions
  - Bible stays canonical (no drift)
  - New brand onboards by reading 5 files
  - AI sessions can trust spec is current
```

### "When in Doubt, Search Before Create"

```yaml
golden_rule_from_DR_011_EUG:
  
  before_creating_entity:
    1. Call eug_preflight_check(slug, aliases, brand_scope)
    2. If BLOCK → adopt existing or add as alias
    3. If WARN → review similar entities, confirm distinct
    4. If CLEAN → proceed with INSERT
  
  before_creating_DR:
    1. Read DECISION_RECORDS.md (DR-001..current)
    2. Check if existing DR addresses your concern
    3. If similar exists → reference + extend, don't duplicate
    4. If new → follow DR template + 2-week review
  
  before_creating_documentation:
    1. Read existing Bible/Schema/Handover sections
    2. Check if content fits existing section
    3. If yes → add to existing (don't fork)
    4. If no → propose new section via DR
```

---

## 📦 Repo Structure

```
the-gifted-digital/eywa-protocol-spec/
├── EYWA_PROTOCOL_v3_13.md         # Bible (canonical)
├── Schema_Overview_EYWA_v1_9.md   # Schema (canonical)
├── EYWA_HANDOVER.md               # Operating manual v1.5
├── DECISION_RECORDS.md            # Decision log v1.3
├── PHASE_1_DECISIONS.md           # Phase 1 quick ref v1.2
├── README.md                      # Repo entry point v1.5
├── PROJECT_MEMORY.md              # THIS FILE — project context for AI/onboarding
└── archive/
    ├── EYWA_PROTOCOL_v3_11.md     # Older Bible
    ├── EYWA_PROTOCOL_v3_12.md     # Previous Bible
    ├── Schema_Overview_EYWA_v1_7.md
    └── Schema_Overview_EYWA_v1_8.md

related_repos:
  - eywa-supabase-migrations (TBD per DR-024)
  - brand-skeleton (template for new brands)
  - per-brand repos (vth-biodent, vitalsleep, etc.)
  - eywa-schema-pipeline (WordPress plugin)
  - eywa-acf-fields (WordPress field groups)
```

---

## 🌿 Closing Notes for Future Sessions

When picking up this project after a break, read in this order:

1. **This file (PROJECT_MEMORY.md)** — 5 minutes to get full context
2. **EYWA_HANDOVER.md Section 6** — current Phase status + open items
3. **DECISION_RECORDS.md** — newest 2-3 decisions to see latest changes
4. **Specific Bible/Schema sections** relevant to the task at hand

If you find yourself:
- About to add a new edge → READ DR-012 first
- About to migrate schema → READ DR-007 + Phase 1 decisions
- About to create entity → USE eug_preflight_check()
- About to propose new pattern → CHECK if existing DR addresses it
- Confused about version → THIS FILE is current; check Last Updated date

**The protocol is alive.** Every decision is traceable. Every entity has a story. Every edge connects two ideas. Every page anchors to knowledge.

That's EYWA — ระบบที่หายใจได้ 🌿

---

*🌿 EYWA™ PROTOCOL Project Memory*  
*Bible v3.13 + Schema v1.9 + Handover v1.5 + DR v1.3 + Phase 1 v1.2*  
*DR-013/014 Proposed — Schema Review Board 2026-05-15*  
*Last updated: 2026-05-09*  
*EYWA™ is a registered service mark — Class 35+42, DIP Thailand*
