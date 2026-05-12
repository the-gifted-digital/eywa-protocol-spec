# 📊 Schema Overview — EYWA™ PROTOCOL Database

> **Companion document to** คัมภีร์ EYWA™ PROTOCOL v3.16  
> **Reference for full DDL + column descriptions of all 37 tables + Ads Track Phase 0 column extensions**

**Version:** v1.12  
**Date:** 2026-05-12  
**Status:** Day 1 Specification (production roadmap reference)  
**Total Tables:** 37 organized into 9 groups + Group 10 (column additions only, no new tables in v1.12)  
**Companion to:** Bible v3.16

---

## Changelog

### v1.12 (2026-05-12) — Ads Landing Page Track Phase 0 (DR-026 Proposed) 🌱📣

Additive-only release per **DR-026 (Proposed 2026-05-12)** — no new tables, only nullable column additions on `seo_website_page_master` (5 cols) and `seo_x_ads_keywords_contextual_master` (6 cols). Phase 1 (`seo_campaigns` Universal Master Table per DR-027) is hinted in §12.3 for migration-friendly Phase 0 adoption but DOES NOT SHIP in v1.12.

**Headline Changes:**

- ➕ **§12 NEW — Group 10 Ads Landing Page Track**:
  - 📌 §12.1 — `seo_website_page_master` adds: `page_purpose` (enum), `ads_template_id` (text), `index_directive` (enum), `conversion_event_primary` (enum), `conversion_event_secondary` (text[]), `campaign_id` (TEXT stub — transitional, becomes FK in v1.13+ per DR-027)
  - 📌 §12.2 — `seo_x_ads_keywords_contextual_master` adds: `seo_active` (bool, default true), `ad_active` (bool, default false), `ad_intent_score` (smallint 1-10), `ad_match_type_preferred` (enum), `ad_landing_page_fp` (text FK → page_master), `ad_priority_tier` (enum)
  - 📌 §12.3 — NON-NORMATIVE architecture sketch for future `seo_campaigns` + 3 junction tables (`seo_campaign_pages`, `seo_campaign_keywords`, `seo_campaign_performance_snapshot`) — Phase 1 reference only
  - 📌 §12.4 — Phase 0 → Phase 1 migration path documented (when DR-027 ships)
  - 📌 §12.5 — Cross-references to Bible Part 29 + Content_Templates v1.4 §3.4

- ⚠️ **Migration files needed:**
  - `020_dr026_ads_lp_page_columns.sql` — page_master column additions + partial indexes
  - `021_dr026_ads_lp_keyword_columns.sql` — keyword_master column additions + partial indexes

- ✅ **Zero downtime, fully backward compatible** — all new columns nullable or DEFAULT'd; existing rows auto-set `page_purpose='seo_organic'`, `seo_active=true`, `ad_active=false`, `index_directive='index'`, `ad_priority_tier='none'`

- 🔄 Schema v1.11 → v1.12 ships paired with Bible v3.16 + Content_Templates v1.4 + DECISION_RECORDS v1.10 + EYWA_HANDOVER v1.10

- 📣 DR-026 Status: **Proposed** — review window 2026-05-12, target lock 2026-06-21 after VTH BioDent Ads pilot validation
- 📣 DR-027 reserved: Campaign Universal Master Table (Phase 1, future Schema v1.13+)

### v1.11 (2026-05-12) — Restore Forgotten Schema (DR-024 + DR-025) 🔒🧬🏥

Schema catch-up release per **DR-024 + DR-025 (Locked 2026-05-12)**. Restores 9 tables that were specified in Bible Appendix B (current since v2.0 / 2026-04-30 and v2.3 / 2026-05-01 respectively) but silently dropped from Schema between v1.0 and v1.10. Strategy unchanged; no Proposed soak (restore of forgotten spec, not new design). Ships paired with Bible v3.15 (rename `seo_locations` → `seo_branches`) + EYWA_HANDOVER v1.9.

**Headline Changes:**

- ➕ **Section 3 — Group 1 (Brand & Organization): 4 → 7 tables**
  - 🔄 §3.2 `seo_branches` — enhanced from ~25 cols to ~40 cols (DR-025). Added: `business_name_legal`, `business_name_brand`, `district`, `formatted_address`, `plus_code`, `line_id`, `special_hours jsonb`, `doctors_at_branch_fps text[]` (→ seo_authors_reviewers), `equipment_at_branch_fps text[]`, `specialties_at_branch text[]`, `gbp_account_id`, `gbp_categories text[]`, `gbp_review_count int`, `gbp_avg_rating numeric(3,2)`, `gbp_last_synced_at timestamptz`, `apple_maps_id`, `facebook_page_url`, `wongnai_url`, `wongnai_id`, `local_business_schema_type`, `primary_photo_url`, `exterior_photos text[]`, `interior_photos text[]`, `status` (active/closed/temp-closed), `opened_date`, `closed_date`, `business_registration_no`, `medical_license_no`, `organization_entity_id uuid FK→seo_entity_graph(id)`
  - 🆕 §3.5 `seo_reviews` (NEW) — Multi-platform review aggregation + PDPA-safe response workflow
  - 🆕 §3.6 `seo_directory_listings` (NEW) — NAP citations across ~50 directories + auto-detect inconsistency
  - 🆕 §3.7 `seo_gbp_posts` (NEW) — GBP Posts management + local archive (posts disappear after 6 months)

- ➕ **Section 11 — Group 9 (Entity Extensions & Templates): 4 → 10 tables (DR-024)**
  - 🆕 §11.4 `seo_entity_product` — Commercial product (skincare/supplement/device); FK to ingredients via `ingredients_fps[]`
  - 🆕 §11.5 `seo_entity_condition` — Diseases & medical conditions; ICD-10 + SNOMED + MeSH codes; **primary binding for T1 medical-condition template**
  - 🆕 §11.6 `seo_entity_drug` — Rx/OTC pharmaceuticals; RxNorm + ATC codes + Thai FDA reg
  - 🆕 §11.7 `seo_entity_anatomy` — Body anatomy; FMA + UBERON codes; self-FK hierarchy
  - 🆕 §11.8 `seo_entity_organization` — External orgs (Thai FDA, ADA, manufacturers, accreditation bodies); separate from `brands` (own brands)
  - 🆕 §11.9 `seo_entity_lab_test` — Lab tests, imaging, biopsies; LOINC + CPT codes
  - 🔄 §11.10 `seo_programmatic_templates` (was §11.4) — renumbered; reclassified as template registry (not entity extension)

- 🔄 **Section 7 — Group 5 Performance Facts:**
  - 🔄 §7.2 `seo_local_rankings` — FK rename `location_id` → `branch_id` (DR-025 alignment)

- 🔄 **Section 2 — Architecture Overview:**
  - Group counts updated: 9-group organization 28 → **37 tables**
  - Group 1: 4 → 7; Group 9: 4 → 10; others unchanged

- 🎯 **Why this matters:**
  - **T1 medical-condition template (Bible Part 4.1.1)** gains its schema binding — was implementable-on-paper but not in DB
  - **Clinic vertical Phase 5 (Local SEO)** unblocked — Bible Part 17.6 n8n GROUP E flows (E1/E2/E3/E4) become implementable
  - **Knowledge graph typed FKs** (condition ↔ anatomy ↔ drug ↔ procedure) instead of text matches
  - **NAP consistency monitoring + PDPA-safe review responses** operational at Day 1 (Bible Part 10.5 promise honored)
  - **External org citations** gain proper entity store (was conflating with `brands` or generic `entity_graph`)

- 📦 **Phase 1A migrations to author (11 new files):**
  - `009_enhance_seo_branches.sql` (DR-025)
  - `010_create_seo_reviews.sql` (DR-025)
  - `011_create_seo_directory_listings.sql` (DR-025)
  - `012_create_seo_gbp_posts.sql` (DR-025)
  - `013_rename_local_rankings_fk.sql` (DR-025)
  - `014_restore_entity_product.sql` (DR-024)
  - `015_restore_entity_condition.sql` (DR-024)
  - `016_restore_entity_drug.sql` (DR-024)
  - `017_restore_entity_anatomy.sql` (DR-024)
  - `018_restore_entity_organization.sql` (DR-024)
  - `019_restore_entity_lab_test.sql` (DR-024)

- ✅ **Backward compatible (within EYWA spec stack):**
  - Existing `seo_branches` rows preserved — new columns NULL-allowed for backfill
  - Existing 3 extensions (`ingredients`, `procedures`, `devices`) preserved
  - Existing `seo_programmatic_templates` preserved (only renumbered §11.4 → §11.10)
  - Existing brand snapshots (`schema_version: 1.10`) remain valid at their snapshot point; brands refresh at next Stage gate per Handover §9.3

- 🔗 **Related Decision Records:**
  - DR-024 (Restore 9 Entity Extension Tables — Locked 2026-05-12)
  - DR-025 (Restore Local SEO Tables + Consolidate `seo_locations` → `seo_branches` — Locked 2026-05-12)

### v1.10 (2026-05-10) — Sitemap Design Refinements + Page Brief 🗺️📝

Companion update to Bible v3.14. Implements 4 new columns in `seo_website_page_master` to support sitemap design refinements (DR-015, DR-016, DR-017). No new tables — all changes additive to existing page_master.

**Headline Changes:**

- ➕ **Section 5.1 — `seo_website_page_master` adds 4 columns** (DR-015, DR-016, DR-017):
  - `content_brief text NULL` — REQUIRED for collapsed pages, recommended for all (DR-017)
  - `marketplace_proposal_status text` — tracks reconciliation status with CHECK constraint (DR-015)
  - `reconciliation_notes text NULL` — operator's repackaging notes (DR-015)
  - `viability_assessment jsonb NULL` — audit trail for §4.14 quality gate (DR-016, optional)

- 🚧 **Phase 1A migrations added (2 new files):**
  - `007_add_content_brief.sql` (DR-017)
  - `008_add_marketplace_reconciliation.sql` (DR-015 + DR-016 viability column)

- 📋 **Decision Records reference:**
  - DR-015 (Brand Scope Market Reconciliation Pattern)
  - DR-016 (Thin Page Risk Detection)
  - DR-017 (Page Content Brief Field)
  - DR-018 (Page Content Length Standards) — process only, no schema change

- 🎯 **Why this matters:**
  - VTH BioDent unblocked — can serve general dentistry under premium positioning
  - Thin-page penalties prevented before publish (Bible §4.14)
  - Content briefs preserve editorial intent across sessions/writers
  - Word count standards (Bible §9.8) — no DDL change needed; standards live in spec, enforced via `viability_assessment.predicted_volume` audit trail (added below) and editorial review checks (Bible Part 23.4)

### v1.9 (2026-05-08) — Entity Uniqueness Guard + brands Two-Column Compliance 🛡️🆔

Companion update to Bible v3.13. Implements **Entity Uniqueness Guard (EUG) v1.0** at the database level + brings `brands` table into **Two-Column Identity Pattern** compliance.

**Headline Changes:**

- ➕ **Appendix G — Entity Uniqueness Guard (EUG) Implementation** (NEW, ~450 lines):
  - Full SQL implementation of 3-layer EUG architecture
  - 4 helper functions: `normalize_entity_slug`, `check_alias_collision`, `find_similar_entities`, `eug_preflight_check`
  - Layer 1: UNIQUE constraint (entity_slug + brand_scope_primary)
  - Layer 2: Normalize trigger (auto-format on INSERT/UPDATE)
  - Layer 3a: Alias collision check (jsonb scan)
  - Layer 3b: Trigram similarity warning (pg_trgm)
  - Performance benchmarks (10-120ms preflight depending on scale)
  - Phase 1A activation plan (additive, non-breaking)
  - EUG v2.0 schema provisions (no new tables — leverages existing seo_entity_embeddings)

- 🔄 **Section 3.1 — `brands` table** (UPDATE):
  - **NEW columns:** `fingerprint text UNIQUE NOT NULL` (Two-Column Identity machine ID, format: `brnd_{ULID16}`)
  - **NEW columns:** `fingerprint_display_name text NOT NULL` (auto-refreshed human label)
  - **NEW columns:** `brand_slug text UNIQUE NOT NULL` (per DR-010 — URL-safe canonical)
  - **DEPRECATED:** `brand_name text PRIMARY KEY` constraint removed (now mutable display name)
  - Added 3 triggers: `trg_set_fingerprint_brand`, `trg_prevent_fingerprint_change`, `trg_refresh_display_name_brand`
  - Added CHECK constraint: `valid_brand_slug` (kebab-case validation)
  - **Rationale:** Per DR-008 "Two-Column Identity for every table EXCEPT keywords" — brands now compliant

- 🔄 **Section 4.1 — `seo_entity_graph` legacy clarification** (UPDATE):
  - Added explicit `**v1.9 NOTE — Two Identity Columns (Transition State)**` block
  - `fingerprint` (v1.8+ canonical, format: `ent_{ULID16}`) — USE THIS for new code
  - `entity_fingerprint` (legacy, format: `entity:{slug}`) — preserved for n8n compat ONLY, will drop in v2.0
  - Closes confusion noted in v1.8 review (entity_fingerprint format ambiguity)

- 🔄 **Appendix A — Extensions update:**
  - `pg_trgm` now also documented as required for EUG v1.0 Layer 3b
  - Adds `seo_entity_graph` to pg_trgm dependents list

- 🔗 **Related Decision Records (NEW):**
  - DR-011: Entity Uniqueness Guard (Two-Wave approach)
  - DR-012: Edge Vocabulary Evolution Policy (referenced from Bible)

- ✅ **Backward compatible:**
  - All EUG additions are additive (new functions, new constraints, new triggers)
  - Legacy `entity_fingerprint` column preserved
  - brands `brand_name` column kept (just no longer PK)
  - No breaking changes to existing FK references

- 🎯 **Migration impact:**
  - Phase 1A migrations: +1 file (06-entity-uniqueness-guard.sql)
  - brands table backfill: required (populate fingerprint + brand_slug + display_name)
  - Existing FK references to brands.brand_name should migrate to brands.fingerprint over Phase 1B
  - n8n workflow integration: ~2 hours dev time

### v1.8 (2026-05-08) — Two-Column Identity + Multilingual v2 🆔🌐

Major refinement based on production audit + operator feedback. Companion to Bible v3.12.

**Headline Changes:**

- ➕ **Appendix B (REWRITTEN):** Two-Column Identity Pattern — every table has `fingerprint` (immutable machine ID) + `fingerprint_display_name` (mutable human label)
- ➕ **Appendix E (NEW):** Multilingual Strategy — Two-Tier pattern (concept tables vs content tables)
- ➕ **Appendix F (NEW):** Helper Functions Reference — generate_ulid(), trg_set_fingerprint_*(), trg_prevent_fingerprint_change(), trg_refresh_display_name_*()
- 🔄 All 9 group sections updated with new identity columns
- 🔄 Multilingual jsonb columns added to concept tables (canonical_names, aliases, descriptions)
- 🔄 translation_group_id added to content tables (page, keyword, review)
- 🔄 brand_scope[] standardization across all tables
- 🔗 Related: DR-007, DR-008, DR-009, DR-010

### v1.7 (2026-05-07) — Two-Phase Hierarchy Sync 🌳

- ➕ **`parent_notion_id`** + **`sync_state`** columns on hierarchical tables
- 🔗 Bible Part 18.8 — Two-Phase Hierarchy Sync Pattern
- 🎯 Enables planning in markdown (text refs) → Notion sync (UUID refs) workflow

### v1.6 (2026-05-07) — Sync with Bible v3.9 (Multilingual) 🌐

Aligned with Bible v3.9 multilingual strategy:
- ➕ **`canonical_names jsonb`** + **`aliases jsonb`** + **`descriptions jsonb`** on entity_graph
- ➕ **`brand_scope[]`** clarification across tables
- 🔄 Knowledge graph fully multilingual ready

### v1.5 (2026-05-07) — Sync with Bible v3.7 (Federation Pattern) 🌐

- 🌐 Federation pattern formalized — `brand_scope text[]` standardized across tables
- 🎯 Schema v1.5 = federation-pattern ready

### v1.4 (2026-05-07) — Federation Lean (No teams table)

- 📜 No breaking changes — all federation features additive
- 🎯 Schema v1.4 = federation-pattern ready (lean — no team registry overhead)

### v1.3 (2026-05-07) — Sync with Bible v3.6 (Scoring Framework) 📊

Added scoring/computed fields to align with Bible Part 27 (EYWA Scoring Framework):
- ➕ **`seo_entity_graph`:** Added `entity_authority_score` + `entity_authority_breakdown` + `entity_freshness_score` + `entity_completeness_score` + formula version metadata
- ➕ **`seo_entity_relationships`:** `edge_strength` and `edge_evidence_score` (formulas defined in Bible Part 27.3)
- ➕ **`seo_website_page_master`:** Added `e_e_a_t_score` + `content_quality_score` + `page_freshness_score` + breakdowns
- ➕ **`seo_topic_cluster_master`:** Added `cluster_health_score` + `cluster_topical_authority`
- ➕ **`seo_citations`:** Added `citation_authority_weight` (computed)
- ➕ **`brands`:** Added `brand_authority_score` + `ai_citation_readiness`
- 🔄 Cross-references to Bible Part 27 (formula specifications)
- 🔄 All score columns include `_breakdown` (jsonb) + `_formula_version` + `_computed_at`
- 🎯 Schema_Overview v1.3 = production-ready with full scoring support

### v1.2 (2026-05-07) — Documentation Cleanup Pass ✨

Final cleanup pass — make Schema_Overview feel fresh & ready-to-use:
- 🧹 Stripped all inline version markers from headers + tables
- 🔗 Synced companion reference to Bible v3.5
- 🎯 Schema_Overview v1.2 = production-ready companion document

### v1.1 (2026-05-07) — Sync with Bible v3.4 🌿

Aligned with Bible v3.4 "Universal Framework Codification":
- ➕ **NEW table:** `seo_entity_relationships` (Section 4.5) — typed edge junction table
- 🔄 **`brands` table:** Added `cpt_activation_flags jsonb` field
- 🔄 **`seo_entity_graph.entity_type`:** Reconciled to **15-type master list**
- ✅ Backward compatible — all changes additive

### v1.0 (2026-05-05) — Initial Specification

Initial release of Database Schema companion document.

---

## 1. How to Read This Document

This document describes the **complete EYWA™ PROTOCOL data architecture** as a unified system. It is designed to be read as a unified Day 1 system — every table here serves a specific role in the protocol's neural network.

### Document Status

```yaml
version: v1.11
date: 2026-05-12
status: Day 1 Specification (production roadmap reference)
total_tables: 37
total_groups: 9
companion_to: คัมภีร์ EYWA™ PROTOCOL v3.15
maintenance:
  - Update when tables added/changed (sync with Bible Part 5)
  - Cross-reference Bible sections always
  - Schema_changes table tracks DDL evolution
```

### How To Use This Document

```
1. As reference: Look up specific table → see full schema + descriptions
2. As migration guide: Use as DDL specification for production deployment
3. As onboarding: New team member reads to understand data architecture
4. As enrichment input: Use existing operational data to enrich design
5. As decision aid: Cross-reference Bible Parts for "why" each table exists
```

---

## 2. System Architecture Overview

### The 9-Group Organization

```
┌────────────────────────────────────────────────────────────────┐
│                  EYWA™ PROTOCOL DATA SYSTEM                     │
│                  ─────────────────────────                      │
│                                                                 │
│  Group 1: Brand & Organization        (7 tables) — Tier 1       │
│  Group 2: Knowledge Architecture      (5 tables) — Tier 1       │
│  Group 3: Page System                 (2 tables) — Tier 1       │
│  Group 4: Keyword & Search            (4 tables) — Tier 1       │
│  Group 5: Performance Fact Tables     (2 tables) — Tier 1       │
│  Group 6: Backlinks & Off-Page        (2 tables) — Tier 2       │
│  Group 7: AI Operations & Embeddings  (4 tables) — Tier 1/2     │
│  Group 8: Data Quality & Governance   (2 tables) — Tier 1/3     │
│  Group 9: Entity Extensions & Tmpls   (9 ext + 1 tmpl = 10)     │
│                                       ─────────                 │
│                                       37 tables                 │
└────────────────────────────────────────────────────────────────┘
```

### Notion ↔ Supabase Sync Architecture

```
              ┌─────────────────┐
              │     NOTION      │  ← Humans plan + edit here
              │   (planning)    │
              └────────┬────────┘
                       │ n8n bidirectional sync
                       ↓
              ┌─────────────────┐
              │    SUPABASE     │  ← Machines query + analyze here
              │  (operational)  │
              └────────┬────────┘
                       │ ETL processes
                       ↓
              ┌─────────────────┐
              │  WordPress +    │  ← Public renders here
              │   RankMath      │
              └─────────────────┘
```

### Sync Direction by Group

| Group | Tables | Sync Pattern |
|-------|--------|--------------|
| 1. Brand & Organization | brands, branches, authors_reviewers, doctor_assignments, **reviews, directory_listings, gbp_posts** 🆕 v1.11 | N↔S (master), S only (reviews/gbp_posts via API ingest) |
| 2. Knowledge Architecture | entity_graph, topic_cluster, citations, page_citations, entity_relationships | N↔S |
| 3. Page System | page_master, editorial_reviews | N↔S |
| 4. Keyword & Search | keywords_master, market_snapshot, serp_competitors, voice_search | N↔S (master), S only (snapshots) |
| 5. Performance Facts | daily_logs, local_rankings *(FK: branch_id 🔄 v1.11)* | S only (high volume) |
| 6. Backlinks | backlinks_data, backlinks_links | S only (DataForSEO ingest) |
| 7. AI Operations | brand_mentions, llm_citations, query_sims, embeddings | S only |
| 8. Data Quality | quality_metrics, schema_changes | S only (system-generated) |
| 9. Entity Extensions & Templates | ingredients, **product** 🆕, procedures, **condition** 🆕, **drug** 🆕, **anatomy** 🆕, **organization** 🆕, **lab_test** 🆕, devices, programmatic_templates | N↔S |

### Required PostgreSQL Extensions

| Extension | Required For | Status |
|-----------|--------------|--------|
| `pgcrypto` | UUID generation | Required |
| `uuid-ossp` | UUID functions | Required |
| `pg_trgm` | Fuzzy text search + **EUG v1.0 Layer 3b** 🆕 v1.9 | Required |
| `pgvector` (`vector`) | Group 7 — Entity Embeddings (vector similarity search) + EUG v2.0 Roadmap | Required |
| `postgis` | Group 1 — Branches (geo coordinates) | Recommended |
| `pg_cron` | Scheduled jobs (refresh, archival) | Optional |
| `pgmq` | Async job queue (n8n integration) | Optional |
| `wrappers` | Foreign Data Wrappers | Optional |

→ See Appendix A for installation order and version compatibility

---

## 3. Group 1 — Brand & Organization (7 tables)

> **Role:** กำหนดตัวตนของ brand, สาขา, แพทย์/ผู้ตรวจสอบ, รีวิว, NAP citations, GBP posts  
> **Bible Reference:** Part 1 (Core Philosophy), Part 10 (Multi-Brand Strategy), Part 10.5 (Local SEO), Part 17.6 GROUP E (n8n Local SEO Flows), Part 23.3 (Authority Validation)

### 3.1 `brands`

> **Purpose:** ตารางหลักของแบรนด์ทุกแบรนด์ในเครือข่าย — กำหนด vertical, format, accreditations และ identity บน knowledge graph ระดับสากล (Wikidata)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S (Notion master ↔ Supabase mirror)  
> **Bible Reference:** Part 1 (Multi-brand identity), Part 10 (Multi-Vertical), Part 14 (Vertical Profiles), Part 23.3 (Authority), **Part 18.9 (Two-Column Identity)** 🆕 v1.9  
> **Volume:** ~10-50 records (one per brand)

> **v1.9 NOTE — Two-Column Identity Compliance:**
> Per DR-008 (Two-Column Identity Pattern), the `brands` table now includes:
> - `fingerprint text UNIQUE NOT NULL` — IMMUTABLE machine ID for FK relations (`brnd_{ULID16}`)
> - `fingerprint_display_name text` — MUTABLE human label (auto-refreshed)
> - `brand_slug text UNIQUE` — URL-safe canonical identifier (per DR-010)
> 
> The legacy `brand_name PRIMARY KEY` constraint is REMOVED in v1.9 — use `fingerprint` for all relations.
> See Bible Section 18.9 for full Two-Column Identity Pattern specification.
> See Schema v1.9 Appendix F for `trg_set_fingerprint_brand()` and helper functions.

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid` | Primary surrogate key, auto-generated |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.9 NEW** — Two-Column Identity machine ID. Format: `brnd_{ULID16}` (e.g., `brnd_01HZP5K2XQR7N3MF`). IMMUTABLE. Auto-generated by `trg_set_fingerprint_brand()` trigger. Used for ALL FK references to brands (replaces `brand_name` for relations). |
| `fingerprint_display_name` | `text NOT NULL` | **v1.9 NEW** — Two-Column Identity human label. Format: `{fp_last_6}::{brand_slug}::{brand_name}`. Auto-refreshed by trigger when source data changes. Used for admin UI, debug, audit logs. Example: `n3mf::vth-biodent::VTH BioDent` |
| `brand_slug` | `text UNIQUE NOT NULL` | **v1.9 NEW (per DR-010)** — URL-safe canonical brand identifier (kebab-case, lowercase, immutable). Example: `vth-biodent`, `vitalsleep`. Used for URL paths, brand_scope[] arrays, file/folder naming. |
| `brand_name` | `text NOT NULL` | ชื่อ brand display name (mutable — supports rebranding). No longer PRIMARY KEY (use `fingerprint` for relations, `brand_slug` for URLs). |
| `notion_id` | `text UNIQUE` | Notion page ID สำหรับ sync ↔ Notion workspace |
| `notion_workspace` | `text` | Notion workspace identifier (สำหรับ multi-workspace setup) |
| `notion_database_id` | `text` | Notion DB ID ที่ brand ใช้สำหรับ content planning |
| `workspace_id` | `text` | Internal workspace tracking (group of brands under same org) |
| `company` | `text` | บริษัทเจ้าของ brand (legal entity) |
| `status` | `text DEFAULT 'active'` | สถานะ: 'active' / 'inactive' / 'paused' / 'archived' |
| `brand_description` | `text` | คำอธิบาย brand เชิงสั้น สำหรับ schema.org markup |
| `brand_web_url` | `text` | URL หลักของ brand (canonical homepage) |
| `gsc_property_url` | `text` | Google Search Console property URL (สำหรับ API integration) |
| `ga4_property_id` | `text` | Google Analytics 4 property ID |
| `vertical_family` | `text` | กลุ่ม vertical: 'healthcare' / 'media' / 'wellness' / 'mixed' (Bible Part 14) |
| `healthcare_format` | `text` | format ย่อย: 'single_specialty' / 'multi_specialty' / 'dental' / 'sleep_medicine' / 'aesthetic' / 'wellness' / 'hospital' (Bible Part 14) |
| `medical_specialty` | `text[]` | array รายการ specialty ที่ brand ครอบคลุม |
| `primary_branch_id` | `uuid` | สาขาหลัก (computed FK to seo_branches — สำหรับ Type B page rendering) |
| `accreditations` | `jsonb DEFAULT '[]'` | array รายการ accreditation: `[{"name": "JCI", "accredited_at": "...", "expires_at": "...", "verification_url": "..."}]` (Bible Part 23.3) |
| `medical_advisory_board_url` | `text` | URL หน้า Medical Advisory Board (Bible Part 23.3) |
| `wikidata_id` | `text` | Wikidata Q-number ของ brand (เช่น `Q123456789`) (Bible Part 13.X) |
| `wikidata_verified_at` | `timestamptz` | Timestamp ยืนยันว่า Wikidata entity ของ brand ยัง valid |
| `knowledge_panel_status` | `text` | สถานะ Google Knowledge Panel: 'not_yet' / 'pending_claim' / 'claimed' / 'verified' |
| `cpt_activation_flags` | `jsonb DEFAULT '{}'` | Derived flags ที่ขับ WordPress CPT auto-activation (Bible Part 25.6) |
| `signature_offerings` | `text[] DEFAULT '{}'` | Array ของ branded methodologies (e.g., `['Mouth Bio Mapping', 'EmSmile']`) |
| `brand_profile` | `jsonb DEFAULT '{}'` | Free-form brand-specific config keys |
| `active_languages` | `text[] DEFAULT ARRAY['th']` | ISO 639-1 codes of active languages (Bible Part 28.1) |
| `canonical_names` | `jsonb DEFAULT '{}'` | **v1.8** — Multilingual brand display names per language. Schema: `{"en": "VTH BioDent", "th": "วี ที เอช ไบโอเดนท์"}` |
| `descriptions` | `jsonb DEFAULT '{}'` | **v1.8** — Multilingual brand descriptions for schema.org per language |
| `brand_authority_score` | `integer` | **v1.3** — Computed brand authority score (0-100, formula in Bible Part 27.5) |
| `brand_authority_breakdown` | `jsonb` | **v1.3** — Score component breakdown |
| `ai_citation_readiness` | `integer` | **v1.3** — Score 0-100 for AI citation readiness (formula Bible Part 27.6) |
| `score_formula_version` | `text` | **v1.3** — Formula version (e.g., 'v1.0') |
| `score_computed_at` | `timestamptz` | **v1.3** — Last score computation timestamp |
| `created_at` | `timestamptz DEFAULT now()` | Timestamp สร้าง record |
| `updated_at` | `timestamptz DEFAULT now()` | Timestamp อัพเดทล่าสุด (auto-trigger) |
| `notion_synced_at` | `timestamptz` | Timestamp sync กับ Notion ล่าสุด |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_brands_fingerprint (fingerprint);                    -- v1.9 NEW
UNIQUE INDEX idx_brands_brand_slug (brand_slug);                       -- v1.9 NEW
UNIQUE INDEX idx_brands_notion_id (notion_id) WHERE notion_id IS NOT NULL;
INDEX idx_brands_status ON brands(status) WHERE status = 'active';
INDEX idx_brands_vertical ON brands(vertical_family, healthcare_format);
INDEX idx_brands_canonical_names_gin ON brands USING gin(canonical_names);  -- v1.8

-- Two-Column Identity triggers (per DR-008) — v1.9 NEW
CREATE TRIGGER set_fp_before_insert_brand
  BEFORE INSERT ON brands
  FOR EACH ROW EXECUTE FUNCTION trg_set_fingerprint_brand();

CREATE TRIGGER prevent_fp_update_brand
  BEFORE UPDATE ON brands
  FOR EACH ROW EXECUTE FUNCTION trg_prevent_fingerprint_change();

CREATE TRIGGER refresh_display_name_brand
  BEFORE UPDATE OF brand_slug, brand_name ON brands
  FOR EACH ROW EXECUTE FUNCTION trg_refresh_display_name_brand();

-- Constraint: brand_slug must match canonical format (v1.9 NEW)
CONSTRAINT valid_brand_slug CHECK (
  brand_slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'
);

-- Note: brand_name is NO LONGER PRIMARY KEY in v1.9
-- Migration step: ALTER TABLE brands DROP CONSTRAINT brands_brand_name_pkey;
-- All existing FK references to brand_name should migrate to fingerprint over Phase 1B
```

#### Used By
- All brand-scoped tables (FK to `brands.fingerprint` — v1.9, was `brand_name` in v1.8)
- WordPress sites (per-brand deployment)
- n8n workflows (federation routing)

---

### 3.2 `seo_branches`

> **Purpose:** สาขาทางกายภาพของแบรนด์ — Local SEO master, Google Business Profile integration, NAP canonical source, schema:LocalBusiness markup  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Bible Reference:** Part 4.4 (Type B Branch Landing), Part 10.5 (Local SEO), Part 14.6 (Hospital format), Part 17.6 GROUP E (n8n Local SEO Flows E1-E4), Appendix B.5 (formerly `seo_locations` — renamed per DR-025)  
> **Volume:** ~50-200 records (multiple branches per brand)

> **v1.11 NOTE (DR-025 Locked 2026-05-12):**
> `seo_branches` is the **canonical Local SEO master** (replaces what Bible Appendix B.5 v2.3 originally called `seo_locations`). Per DR-025, the consolidated naming is `seo_branches` — Bible v3.15 renames all `seo_locations` references throughout. Schema expanded from ~25 cols (v1.10) → ~40 cols (v1.11) to match full Bible Table 24 spec. All 4 Local SEO child tables (`seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`, `seo_local_rankings`) FK to `seo_branches.id` via `branch_id`.

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.8** — Format: `brch_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8** — Format: `{fp_last_6}::{brand_slug}::{branch_slug}` |
| `branch_fingerprint` | `text UNIQUE` | Legacy field (slug-based) — preserved for backward compat |
| `branch_slug` | `text` | URL-safe branch identifier |
| `brand_id` | `uuid FK→brands.id` | Brand owner |
| `brand_slug` | `text NOT NULL` | **v1.8** — Denormalized brand_slug |
| `branch_name` | `text NOT NULL` | Display name (operational name, e.g., "VTH BioDent Asoke") |
| `organization_entity_id` | `uuid FK→seo_entity_graph(id)` | 🆕 **v1.11 DR-025** — Links to the org's entity in knowledge graph (Schema.org `Organization`/`MedicalOrganization`). Enables Wikidata Q-number + sameAs cross-ref |
| `is_primary` | `boolean DEFAULT false` | 🆕 **v1.11** — Primary/HQ branch flag for the brand |
| **— NAP (Bible Part 10.5 NAP Canonical) —** | | |
| `business_name_legal` | `text` | 🆕 **v1.11** — Legal registered business name (Thai DBD registration) |
| `business_name_brand` | `text` | 🆕 **v1.11** — Brand/marketing name (may differ from legal) |
| `address` | `text` | Full street address (free-form) |
| `street_address` | `text` | 🆕 **v1.11** — Structured street + number (Schema.org streetAddress) |
| `district` | `text` | 🆕 **v1.11** — แขวง/ตำบล (Schema.org `addressDistrict`) |
| `city` | `text` | จังหวัด/อำเภอ (Schema.org addressLocality) |
| `region` | `text` | 🆕 **v1.11** — Province/region (Schema.org addressRegion) |
| `country_code` | `text` | ISO 3166-1 alpha-2 |
| `postal_code` | `text` | |
| `formatted_address` | `text` | 🆕 **v1.11** — Single-line full formatted address (Google geocoding result) |
| **— Geo —** | | |
| `latitude` | `numeric(10,7)` | GPS latitude |
| `longitude` | `numeric(10,7)` | GPS longitude |
| `geo_point` | `geography(POINT)` | PostGIS computed point (PostGIS extension required) |
| `plus_code` | `text` | 🆕 **v1.11** — Google Plus Code (open location code) |
| **— Contact —** | | |
| `phone` | `text` | Primary contact (E.164 format recommended) |
| `email` | `text` | Branch email |
| `line_id` | `text` | 🆕 **v1.11** — LINE Official Account ID (TH market critical) |
| `website_url` | `text` | 🆕 **v1.11** — Branch-specific landing URL (FK alternative for page_master integration) |
| **— Hours —** | | |
| `opening_hours` | `jsonb` | OpeningHoursSpecification format (regular weekly hours) |
| `special_hours` | `jsonb` | 🆕 **v1.11** — Holiday/exception hours (Schema.org specialOpeningHoursSpecification) |
| **— Services / Staff / Equipment —** | | |
| `services_at_branch` | `text[]` | Array of services available (text, deprecated in favor of fps[] when entities ready) |
| `services_offered_fps` | `text[]` | 🆕 **v1.11** — FK array → `seo_entity_graph.fingerprint` (entities of type='procedure' or 'service') |
| `specialties_at_branch` | `text[]` | 🆕 **v1.11** — Medical specialty codes (general / ortho / OMS / etc.) |
| `doctors_at_branch_fps` | `text[]` | 🆕 **v1.11** — FK array → `seo_authors_reviewers.fingerprint` (resident doctors at this branch) |
| `equipment_at_branch_fps` | `text[]` | 🆕 **v1.11** — FK array → `seo_entity_graph.fingerprint` (entities of type='device') |
| **— GBP (Google Business Profile) —** | | |
| `gbp_place_id` | `text` | Google Business Profile place ID |
| `gbp_account_id` | `text` | 🆕 **v1.11** — GBP account ID (for API access via Flow E1/E2/E4) |
| `gbp_categories` | `text[]` | 🆕 **v1.11** — Primary + additional GBP categories |
| `gbp_review_count` | `integer DEFAULT 0` | 🆕 **v1.11** — Cached review count (updated by Flow E1) |
| `gbp_avg_rating` | `numeric(3,2)` | 🆕 **v1.11** — Cached avg rating 1.00-5.00 (updated by Flow E1) |
| `gbp_last_synced_at` | `timestamptz` | 🆕 **v1.11** — Last GBP API sync (Flow E1/E2/E4) |
| **— Other Directories —** | | |
| `apple_maps_id` | `text` | 🆕 **v1.11** — Apple Business Connect ID |
| `facebook_page_url` | `text` | 🆕 **v1.11** — Facebook Page URL |
| `wongnai_url` | `text` | 🆕 **v1.11** — Wongnai listing URL (TH critical) |
| `wongnai_id` | `text` | 🆕 **v1.11** — Wongnai venue ID |
| **— Schema.org —** | | |
| `local_business_schema_type` | `text` | 🆕 **v1.11** — Schema.org subtype: 'MedicalClinic' / 'DentalClinic' / 'Hospital' / 'BeautySalon' / 'HealthAndBeautyBusiness' |
| **— Photos —** | | |
| `primary_photo_url` | `text` | 🆕 **v1.11** — Primary branch photo (used in Schema.org image) |
| `exterior_photos` | `text[]` | 🆕 **v1.11** — Exterior photo URLs |
| `interior_photos` | `text[]` | 🆕 **v1.11** — Interior photo URLs |
| **— Status / Compliance —** | | |
| `status` | `text DEFAULT 'active'` | 🆕 **v1.11** — CHECK: 'active' / 'closed' / 'temp_closed' / 'pending_opening' |
| `opened_date` | `date` | 🆕 **v1.11** — Branch opening date |
| `closed_date` | `date` | 🆕 **v1.11** — Branch closure date (NULL if active) |
| `business_registration_no` | `text` | 🆕 **v1.11** — เลขทะเบียนนิติบุคคล (Thai DBD reg) |
| `medical_license_no` | `text` | 🆕 **v1.11** — เลขใบอนุญาตประกอบกิจการสถานพยาบาล (กรมสนับสนุนบริการสุขภาพ) |
| **— Multilingual / Sync —** | | |
| `canonical_names` | `jsonb DEFAULT '{}'` | **v1.8** — Multilingual branch names per language code |
| `parent_notion_id` | `text` | **v1.7** — Notion page ID of parent (hierarchy) |
| `sync_state` | `text DEFAULT 'flat_loaded'` | **v1.7** — Two-Phase Sync state |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
CREATE INDEX idx_branches_brand ON seo_branches(brand_id);
CREATE INDEX idx_branches_org_entity ON seo_branches(organization_entity_id);
CREATE INDEX idx_branches_geo ON seo_branches USING GIST(geo_point);
CREATE INDEX idx_branches_gbp_place_id ON seo_branches(gbp_place_id) WHERE gbp_place_id IS NOT NULL;
CREATE INDEX idx_branches_status ON seo_branches(status) WHERE status != 'active';
CREATE UNIQUE INDEX idx_branches_brand_primary ON seo_branches(brand_id) WHERE is_primary = true;

ALTER TABLE seo_branches ADD CONSTRAINT check_status CHECK (status IN ('active', 'closed', 'temp_closed', 'pending_opening'));
ALTER TABLE seo_branches ADD CONSTRAINT check_schema_type CHECK (local_business_schema_type IN ('LocalBusiness', 'MedicalClinic', 'DentalClinic', 'Hospital', 'BeautySalon', 'HealthAndBeautyBusiness', 'MedicalBusiness', 'Physician'));
```

#### Used By

- `seo_reviews` (FK `branch_id`) — multi-platform review aggregation (Flow E1)
- `seo_directory_listings` (FK `branch_id`) — NAP citation tracking (Flow E3)
- `seo_gbp_posts` (FK `branch_id`) — GBP Posts management (Flow E2/E4)
- `seo_local_rankings` (FK `branch_id`) — Local Pack rank tracking
- `seo_website_page_master` — branch landing pages reference `seo_branches.fingerprint`
- `seo_doctor_assignments` — author × brand × branch junction

#### Migration Files

- `009_enhance_seo_branches.sql` (DR-025 — adds 23 new columns + indexes)

---

### 3.3 `seo_authors_reviewers` (renamed `seo_authors` in v1.9)

> **Purpose:** ทะเบียนแพทย์/ผู้เขียน — license verification, board cert, advisory board membership (Bible Part 23.3)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Bible Reference:** Part 23.3 (Authority Validation), Part 23.4 (Editorial Review)  
> **Volume:** ~50-500 records

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.8** — Format: `auth_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8** — Format: `{fp_last_6}::{role}::{full_name}` |
| `full_name` | `text NOT NULL` | Display name |
| `canonical_names` | `jsonb DEFAULT '{}'` | **v1.8** — Multilingual names per language |
| `photo_url` | `text` | Profile photo |
| `credential_types` | `text[]` | Array: ['MD', 'DDS', 'PhD'] |
| `medical_license_number` | `text` | License number |
| `medical_license_country` | `text` | Country code |
| `medical_license_verified_at` | `timestamptz` | Last verification |
| `board_certifications` | `jsonb DEFAULT '[]'` | Array: [{board, cert_year, expires}] |
| `is_advisory_board_member` | `boolean DEFAULT false` | Bible Part 23.3 |
| `brand_scope` | `text[]` | Brands this author serves |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

→ **Full schema** : preserved from v1.8

---

### 3.4 `seo_doctor_assignments` (renamed `seo_brand_doctors` in v1.9)

> **Purpose:** Junction (author × brand × branch) — รองรับการแชร์แพทย์ข้าม brand  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Volume:** ~100-1000 records

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.8** — Format: `doc_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8** — Format: `{fp_last_6}::{brand_slug}::{author_name}::{branch}` |
| `author_id` | `uuid FK→seo_authors.id` | Author reference |
| `brand_id` | `uuid FK→brands.id` | Brand reference |
| `branch_id` | `uuid FK→seo_branches.id` | Branch reference (optional) |
| `role_at_brand` | `text` | 'reviewer' / 'author' / 'consultant' / 'medical_director' |
| `is_primary_role` | `boolean DEFAULT false` | true = primary brand affiliation |
| `started_at` | `date` | Assignment start |
| `ended_at` | `date` | Assignment end (NULL = active) |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

→ **Full schema** : preserved from v1.8

---

### 3.5 `seo_reviews` 🆕 v1.11

> **Purpose:** Multi-platform review aggregation + PDPA-safe response workflow. Centralizes reviews from GBP, Wongnai, Facebook, Google Maps, Pantip mentions into a single store for sentiment analysis, response coordination, and quality monitoring.
> **Tier:** 1 (Critical Operational — clinic Day 1)
> **Sync:** S only (API ingest via n8n Flow E1 every 6h); Notion notifications optional
> **Bible Reference:** Part 10.5 (Local SEO), Part 17.6 GROUP E Flow E1 (GBP Reviews Sync), Part 23.4 (Editorial Review), Appendix B.5 Table 25
> **Volume:** ~100-1000 records per branch per year (TH clinic avg ~50-200/yr)
> **PDPA Critical:** Reviews may contain personal data (names, medical conditions) — `pdpa_risk_flag` + legal review required before public response per PDPA B.E. 2562 (2019)

> **DR Reference:** DR-025 Locked 2026-05-12 (Restore Local SEO Tables). Originally specified in Bible Appendix B.5 Table 25 (v2.3 / 2026-05-01); dropped from Schema_Overview v1.0→v1.10 silently; restored in v1.11.

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `fingerprint` | `text UNIQUE NOT NULL` | Format: `rev_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | Format: `{fp_last_6}::{source_platform}::{rating}::{date}` |
| `branch_id` | `uuid FK→seo_branches(id) ON DELETE CASCADE` | Branch being reviewed |
| `brand_id` | `uuid FK→brands(id)` | Denormalized for query speed |
| **— Source —** | | |
| `source_platform` | `text NOT NULL` | CHECK: 'gbp' / 'wongnai' / 'facebook' / 'google_maps' / 'pantip' / 'apple_maps' / 'tripadvisor' / 'manual' |
| `source_review_id` | `text` | Platform-native review ID (for dedupe) |
| `source_url` | `text` | Direct URL to review on source platform |
| **— Reviewer —** | | |
| `reviewer_name` | `text` | Raw name from platform (for internal use) |
| `reviewer_anonymized` | `text` | Public-safe pseudonym for response/display (PDPA-safe) |
| `reviewer_profile_url` | `text` | Reviewer's platform profile URL |
| `is_local_guide` | `boolean DEFAULT false` | GBP Local Guide status (weight signal) |
| **— Review Content —** | | |
| `rating` | `numeric(2,1) NOT NULL` | 1.0-5.0 (CHECK: rating BETWEEN 1.0 AND 5.0) |
| `review_title` | `text` | Title (if platform supports, e.g., Wongnai) |
| `review_text` | `text` | Full review body |
| `review_language` | `text DEFAULT 'th'` | ISO 639-1 |
| `review_photos` | `text[]` | URLs to reviewer-uploaded photos |
| `review_videos` | `text[]` | URLs to reviewer-uploaded videos |
| `posted_at` | `timestamptz NOT NULL` | Original review timestamp |
| **— Response Workflow —** | | |
| `response_required` | `boolean DEFAULT true` | Auto-set true for ratings ≤ 3.0 or flagged content |
| `response_priority` | `text DEFAULT 'normal'` | CHECK: 'urgent' / 'high' / 'normal' / 'low' |
| `response_status` | `text DEFAULT 'pending'` | CHECK: 'pending' / 'drafted' / 'legal_review' / 'approved' / 'published' / 'declined' |
| `response_text` | `text` | Public response body |
| `response_language` | `text` | ISO 639-1 |
| `response_drafted_by_fp` | `text FK→seo_authors_reviewers(fingerprint)` | Who drafted |
| `response_legal_reviewed` | `boolean DEFAULT false` | PDPA legal review checkpoint |
| `responded_by_fp` | `text FK→seo_authors_reviewers(fingerprint)` | Who published the response |
| `responded_at` | `timestamptz` | Response publish time |
| `pdpa_risk_flag` | `boolean DEFAULT false` | Flagged for PDPA risk (reviewer mentioned medical condition, specific staff names, etc.) |
| `pdpa_notes` | `text` | Legal review notes |
| **— NLP / Analytics —** | | |
| `detected_topics` | `text[]` | Auto-extracted topics (service mentioned, staff praised, complaint category) |
| `sentiment` | `text` | CHECK: 'positive' / 'neutral' / 'negative' / 'mixed' |
| `sentiment_score` | `numeric(4,3)` | -1.000 to 1.000 (NLP confidence) |
| `mentioned_entities_fps` | `text[]` | FK array → `seo_entity_graph(fingerprint)` — auto-detected entity mentions |
| `mentioned_doctors_fps` | `text[]` | FK array → `seo_authors_reviewers(fingerprint)` — auto-detected doctor mentions |
| **— Verification —** | | |
| `is_verified_customer` | `boolean DEFAULT false` | Cross-checked against CRM (if available) |
| `is_flagged` | `boolean DEFAULT false` | Internal flag for fake/spam/competitor review |
| `flag_reason` | `text` | Why flagged |
| `flag_reported_at` | `timestamptz` | When reported to platform |
| **— Sync Metadata —** | | |
| `last_synced_at` | `timestamptz` | Last Flow E1 sync |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
CREATE UNIQUE INDEX idx_reviews_source_dedupe ON seo_reviews(source_platform, source_review_id) WHERE source_review_id IS NOT NULL;
CREATE INDEX idx_reviews_branch ON seo_reviews(branch_id);
CREATE INDEX idx_reviews_brand ON seo_reviews(brand_id);
CREATE INDEX idx_reviews_rating ON seo_reviews(rating);
CREATE INDEX idx_reviews_response_pending ON seo_reviews(response_status) WHERE response_status IN ('pending', 'drafted', 'legal_review');
CREATE INDEX idx_reviews_pdpa_flagged ON seo_reviews(pdpa_risk_flag) WHERE pdpa_risk_flag = true;
CREATE INDEX idx_reviews_posted ON seo_reviews(posted_at DESC);
CREATE INDEX idx_reviews_sentiment ON seo_reviews(sentiment) WHERE sentiment IN ('negative', 'mixed');

ALTER TABLE seo_reviews ADD CONSTRAINT check_rating_range CHECK (rating BETWEEN 1.0 AND 5.0);
ALTER TABLE seo_reviews ADD CONSTRAINT check_source_platform CHECK (source_platform IN ('gbp', 'wongnai', 'facebook', 'google_maps', 'pantip', 'apple_maps', 'tripadvisor', 'manual'));
ALTER TABLE seo_reviews ADD CONSTRAINT check_response_status CHECK (response_status IN ('pending', 'drafted', 'legal_review', 'approved', 'published', 'declined'));
```

#### Used By

- n8n Flow E1 (GBP Reviews Sync every 6h) — INSERTs new reviews, UPDATEs `gbp_review_count`/`gbp_avg_rating` on parent `seo_branches`
- Response approval workflow (Notion UI → n8n → seo_reviews update → platform publish)
- NLP sentiment dashboard (Supabase view)
- KPI tracking (Bible Part 16 — Local SEO Health Metrics)

#### Migration Files

- `010_create_seo_reviews.sql` (DR-025)

---

### 3.6 `seo_directory_listings` 🆕 v1.11

> **Purpose:** NAP (Name/Address/Phone) citation tracker across ~50 local directories per branch + auto-detect inconsistency. **Distinct from `seo_citations`** (which is academic citations like PubMed DOI) — this table is Local SEO directory listings (GBP, Wongnai, Apple Maps, Foursquare, etc.).
> **Tier:** 1 (Critical Operational — clinic Day 1)
> **Sync:** S only (audit via n8n Flow E3 weekly); Notion notifications for inconsistency
> **Bible Reference:** Part 10.5 (Local SEO), Part 17.6 GROUP E Flow E3 (NAP Audit), Appendix B.5 Table 26
> **Volume:** ~30-100 records per branch (avg ~50 directories tracked)

> **DR Reference:** DR-025 Locked 2026-05-12 (Restore Local SEO Tables). Bible Appendix B.5 Table 26 explicit warning: "distinct from `seo_citations` (academic) — these are 'directory listings' / 'NAP citations' in Local SEO".

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `fingerprint` | `text UNIQUE NOT NULL` | Format: `dirl_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | Format: `{fp_last_6}::{branch_slug}::{directory_name}` |
| `branch_id` | `uuid FK→seo_branches(id) ON DELETE CASCADE` | Branch being listed |
| `brand_id` | `uuid FK→brands(id)` | Denormalized for query speed |
| **— Directory Info —** | | |
| `directory_name` | `text NOT NULL` | e.g., 'Google Business Profile', 'Wongnai', 'Apple Maps', 'Foursquare', 'Bing Places', 'LINE OA', 'Yellow Pages TH', 'Pantip' |
| `directory_slug` | `text NOT NULL` | URL-safe identifier ('gbp', 'wongnai', 'apple-maps') |
| `directory_category` | `text` | 'major_search' / 'thai_local' / 'industry_specific' / 'social' / 'mapping' |
| `directory_authority_score` | `integer` | 1-100 SEO authority weight (DA-equivalent) |
| `is_thai_specific` | `boolean DEFAULT false` | TH-market-only directory (Wongnai, Pantip) |
| `is_industry_specific` | `boolean DEFAULT false` | Industry-specific (e.g., RateMDs for medical) |
| `industry_focus` | `text` | If industry_specific: 'medical' / 'dental' / 'beauty' / 'wellness' |
| **— Listing —** | | |
| `citation_url` | `text` | Direct URL to the listing |
| `status` | `text DEFAULT 'pending'` | CHECK: 'live' / 'pending' / 'rejected' / 'duplicate' / 'unlisted' |
| `claim_status` | `text DEFAULT 'unclaimed'` | CHECK: 'claimed' / 'unclaimed' / 'in_progress' / 'verification_failed' |
| `claimed_at` | `timestamptz` | When claim verified |
| `claimed_by_fp` | `text FK→seo_authors_reviewers(fingerprint)` | Who claimed it |
| **— NAP As Listed (snapshot from directory) —** | | |
| `business_name_listed` | `text` | Name as appears on directory |
| `address_listed` | `text` | Address as appears |
| `phone_listed` | `text` | Phone as appears |
| `website_listed` | `text` | Website URL as appears |
| `hours_listed` | `jsonb` | Hours as appears |
| `categories_listed` | `text[]` | Categories as appears |
| **— Consistency Scoring (auto-computed) —** | | |
| `name_match_score` | `numeric(4,3)` | 0.000-1.000 fuzzy match vs `seo_branches.business_name_brand` |
| `address_match_score` | `numeric(4,3)` | vs `seo_branches.formatted_address` |
| `phone_match_score` | `numeric(4,3)` | vs `seo_branches.phone` (normalized) |
| `website_match_score` | `numeric(4,3)` | vs `seo_branches.website_url` |
| `nap_match_score` | `numeric(4,3) GENERATED ALWAYS AS ((name_match_score + address_match_score + phone_match_score) / 3.0) STORED` | Overall NAP consistency |
| `has_inconsistency` | `boolean GENERATED ALWAYS AS (nap_match_score < 0.95) STORED` | Auto-flag |
| `inconsistency_notes` | `text` | Operator notes |
| `inconsistency_severity` | `text` | 'critical' (wrong phone/address) / 'moderate' (name variation) / 'minor' (formatting only) |
| **— Discovery & Verification —** | | |
| `found_via` | `text` | 'manual_audit' / 'gbp_insights' / 'whitespark' / 'brightlocal' / 'discovered_search' |
| `discovered_at` | `timestamptz` | When first added to tracking |
| `last_verified_at` | `timestamptz` | Last Flow E3 check |
| `next_verification_due` | `timestamptz` | Next scheduled check |
| **— Sync —** | | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
CREATE UNIQUE INDEX idx_dirl_branch_directory ON seo_directory_listings(branch_id, directory_slug);
CREATE INDEX idx_dirl_brand ON seo_directory_listings(brand_id);
CREATE INDEX idx_dirl_status ON seo_directory_listings(status);
CREATE INDEX idx_dirl_inconsistency ON seo_directory_listings(has_inconsistency) WHERE has_inconsistency = true;
CREATE INDEX idx_dirl_unclaimed ON seo_directory_listings(claim_status) WHERE claim_status = 'unclaimed';
CREATE INDEX idx_dirl_next_check ON seo_directory_listings(next_verification_due) WHERE status = 'live';

ALTER TABLE seo_directory_listings ADD CONSTRAINT check_status CHECK (status IN ('live', 'pending', 'rejected', 'duplicate', 'unlisted'));
ALTER TABLE seo_directory_listings ADD CONSTRAINT check_claim_status CHECK (claim_status IN ('claimed', 'unclaimed', 'in_progress', 'verification_failed'));
ALTER TABLE seo_directory_listings ADD CONSTRAINT check_severity CHECK (inconsistency_severity IS NULL OR inconsistency_severity IN ('critical', 'moderate', 'minor'));
```

#### Used By

- n8n Flow E3 (NAP Audit weekly) — fetches each directory, compares against `seo_branches` canonical NAP, computes match scores
- Local SEO health dashboard — count of inconsistencies per branch
- Citation acquisition workflow — Notion task auto-create when `claim_status = 'unclaimed'` on high-authority directory

#### Migration Files

- `011_create_seo_directory_listings.sql` (DR-025)

---

### 3.7 `seo_gbp_posts` 🆕 v1.11

> **Purpose:** Google Business Profile Posts management + **local archive critical** (GBP posts disappear after 6 months — without local archive, historical campaign data is lost). Supports multi-branch campaigns via `batch_id` for cross-branch publishing.
> **Tier:** 1 (Critical Operational — clinic Day 1 if GBP active)
> **Sync:** S only (publish via n8n Flow E2, metrics sync via Flow E4)
> **Bible Reference:** Part 10.5 (Local SEO), Part 17.6 GROUP E Flow E2 (GBP Posts Publish), Flow E4 (GBP Posts Metrics Sync), Appendix B.5 Table 27
> **Volume:** ~10-100 records per branch per year (1-4 posts/month avg)

> **DR Reference:** DR-025 Locked 2026-05-12 (Restore Local SEO Tables).

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `fingerprint` | `text UNIQUE NOT NULL` | Format: `gbpp_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | Format: `{fp_last_6}::{branch_slug}::{post_type}::{date}` |
| `branch_id` | `uuid FK→seo_branches(id) ON DELETE CASCADE` | Target branch |
| `brand_id` | `uuid FK→brands(id)` | Denormalized for query speed |
| **— Post Type & Campaign —** | | |
| `post_type` | `text NOT NULL` | CHECK: 'standard' / 'event' / 'offer' / 'product' / 'covid_update' |
| `campaign_id` | `text` | Multi-branch campaign grouping |
| `campaign_name` | `text` | Human-readable campaign label |
| `batch_id` | `uuid` | Multi-location publish batch (same content across N branches) |
| `parent_post_id` | `uuid FK→seo_gbp_posts(id)` | If reposting/duplicating from a master post |
| **— Content —** | | |
| `title` | `text` | Post title (max 58 chars per GBP spec) |
| `body` | `text NOT NULL` | Post body (max 1500 chars) |
| `language_code` | `text DEFAULT 'th'` | ISO 639-1 |
| `photo_url` | `text` | Primary photo (recommended for engagement) |
| `video_url` | `text` | Optional video |
| `cta_type` | `text` | CHECK: 'book' / 'order' / 'shop' / 'learn_more' / 'sign_up' / 'call' / 'none' |
| `cta_url` | `text` | Where CTA leads |
| **— Event/Offer-specific —** | | |
| `event_start_at` | `timestamptz` | For post_type='event' |
| `event_end_at` | `timestamptz` | For post_type='event' |
| `offer_coupon_code` | `text` | For post_type='offer' |
| `offer_terms` | `text` | For post_type='offer' |
| `offer_redeem_url` | `text` | For post_type='offer' |
| **— Product-specific (if post_type='product') —** | | |
| `product_name` | `text` | |
| `product_price_min` | `numeric(10,2)` | |
| `product_price_max` | `numeric(10,2)` | |
| `product_currency` | `text DEFAULT 'THB'` | ISO 4217 |
| **— Schedule —** | | |
| `scheduled_for` | `timestamptz` | When to auto-publish |
| `published_at` | `timestamptz` | Actual publish time |
| `expires_at` | `timestamptz` | When post auto-expires (GBP 6-month default for non-event) |
| **— Status / Approval —** | | |
| `status` | `text DEFAULT 'draft'` | CHECK: 'draft' / 'scheduled' / 'publishing' / 'published' / 'expired' / 'failed' / 'archived' |
| `approval_status` | `text DEFAULT 'pending'` | CHECK: 'pending' / 'approved' / 'rejected' |
| `approved_by_fp` | `text FK→seo_authors_reviewers(fingerprint)` | Who approved |
| `approved_at` | `timestamptz` | |
| `rejection_reason` | `text` | If rejected |
| **— GBP API Response —** | | |
| `gbp_post_id` | `text` | GBP-assigned post ID (after publish) |
| `gbp_post_url` | `text` | Public URL on GBP |
| `gbp_published_at` | `timestamptz` | GBP-side publish timestamp |
| `gbp_api_response` | `jsonb` | Raw API response (for debugging) |
| `gbp_last_synced_at` | `timestamptz` | Last Flow E4 metrics sync |
| **— Performance Metrics (synced via Flow E4) —** | | |
| `views_count` | `integer DEFAULT 0` | |
| `clicks_count` | `integer DEFAULT 0` | CTA clicks |
| `conversions_count` | `integer DEFAULT 0` | If tracked via GA4/conversion API |
| `engagement_rate` | `numeric(5,4) GENERATED ALWAYS AS (CASE WHEN views_count > 0 THEN clicks_count::numeric / views_count ELSE 0 END) STORED` | CTR equivalent |
| **— Sync —** | | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
CREATE INDEX idx_gbpp_branch ON seo_gbp_posts(branch_id);
CREATE INDEX idx_gbpp_brand ON seo_gbp_posts(brand_id);
CREATE INDEX idx_gbpp_campaign ON seo_gbp_posts(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX idx_gbpp_batch ON seo_gbp_posts(batch_id) WHERE batch_id IS NOT NULL;
CREATE INDEX idx_gbpp_scheduled ON seo_gbp_posts(scheduled_for) WHERE status = 'scheduled';
CREATE INDEX idx_gbpp_published ON seo_gbp_posts(published_at DESC) WHERE status = 'published';
CREATE INDEX idx_gbpp_approval ON seo_gbp_posts(approval_status) WHERE approval_status = 'pending';

ALTER TABLE seo_gbp_posts ADD CONSTRAINT check_post_type CHECK (post_type IN ('standard', 'event', 'offer', 'product', 'covid_update'));
ALTER TABLE seo_gbp_posts ADD CONSTRAINT check_cta_type CHECK (cta_type IS NULL OR cta_type IN ('book', 'order', 'shop', 'learn_more', 'sign_up', 'call', 'none'));
ALTER TABLE seo_gbp_posts ADD CONSTRAINT check_status CHECK (status IN ('draft', 'scheduled', 'publishing', 'published', 'expired', 'failed', 'archived'));
ALTER TABLE seo_gbp_posts ADD CONSTRAINT check_approval CHECK (approval_status IN ('pending', 'approved', 'rejected'));
ALTER TABLE seo_gbp_posts ADD CONSTRAINT check_event_dates CHECK (post_type != 'event' OR (event_start_at IS NOT NULL AND event_end_at IS NOT NULL AND event_end_at >= event_start_at));
```

#### Used By

- n8n Flow E2 (GBP Posts Publish) — picks `status='scheduled' AND scheduled_for <= NOW()`, publishes to GBP API, updates `gbp_post_id`/`status='published'`
- n8n Flow E4 (GBP Posts Metrics Sync daily) — for each `status='published' AND last_synced < 1d ago`, fetches views/clicks
- Multi-branch campaign workflow — operator creates 1 master post in Notion, n8n duplicates to N branches with shared `batch_id`
- Campaign performance dashboard

#### Migration Files

- `012_create_seo_gbp_posts.sql` (DR-025)

---

## 4. Group 2 — Knowledge Architecture (5 tables)

> **Role:** หัวใจของ Knowledge Graph — entities, clusters, citations, **typed relationship edges**, และความสัมพันธ์ระหว่าง pages กับ citations  
> **Bible Reference:** Part 2 (Conceptual Architecture), **Part 2.6 (Entity Genesis Protocol)**, **Part 2.6.6.1 (EUG)** 🆕 v1.9, **Part 2.7 (Edge Vocabulary)**, **Part 2.7.5 (Edge Evolution Policy)** 🆕 v1.9, Part 5 (Database), Part 7 (Taxonomy SKOS), Part 23.1 (Citation Tiers), Part 26 (Schema Pipeline)

### 4.1 `seo_entity_graph`

> **Purpose:** Master ของทุก entity ในระบบ — concepts, conditions, procedures, ingredients, devices, drugs — เชื่อมโยงกับ Wikidata, ICD-10, MeSH, และระบุ brand_scope (ใช้ข้าม brand ได้ไหม)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Bible Reference:** Part 2 (Conceptual Architecture), Part 7 (SKOS), Part 14 (Vertical Profiles), **Part 2.6.6.1 (EUG)** 🆕 v1.9  
> **Volume:** ~500-2000 entities (mid-size brand portfolio)

> **v1.9 NOTE — Two Identity Columns (Transition State):**
> 
> This table has TWO identity columns during v1.8/v1.9 transition:
> 
> 1. **`fingerprint`** (v1.8+ canonical) — `ent_{ULID16}` format, IMMUTABLE — USE THIS for new code
> 2. **`entity_fingerprint`** (legacy) — `entity:{slug}` format, MUTABLE — preserved for n8n compat only
> 
> All new FK references should target `fingerprint`. The legacy `entity_fingerprint` will be dropped in v2.0 after n8n workflows migrate.
> 
> See Bible Section 18.9 for Two-Column Identity Pattern. See DR-008 for decision rationale.

> **v1.9 NOTE — EUG (Entity Uniqueness Guard):**
> 
> Per Bible Section 2.6.6.1, this table is protected by Entity Uniqueness Guard v1.0:
> - Layer 1: UNIQUE constraint on `(entity_slug, brand_scope_primary)` 
> - Layer 2: `entity_slug` auto-normalized via `trg_normalize_entity_slug` trigger (BEFORE INSERT/UPDATE)
> - Layer 3a: Application calls `check_alias_collision()` before INSERT
> - Layer 3b: Application calls `find_similar_entities()` before INSERT (warning-level)
> 
> See Schema v1.9 Appendix G for full EUG implementation. See DR-011 for decision rationale.

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `fingerprint` | `text UNIQUE NOT NULL` | **CANONICAL machine ID (v1.8+)** — Two-Column Identity Pattern. Format: `ent_{ULID16}` (e.g., `ent_01HZP5K2XQR7N3MF`). IMMUTABLE. Auto-generated by `trg_set_fingerprint_entity()` trigger. Used for ALL FK references in v1.8+ (replaces `entity_fingerprint`). See Bible Section 18.9 + Schema Appendix B. |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8+** — Two-Column Identity human label. Format: `{fp_last_6}::{entity_type}::{entity_slug}::{icd_10_code}`. Auto-refreshed by trigger. Example: `n3mf::condition::sleep-apnea::g47.3` |
| `entity_fingerprint` | `text UNIQUE` | ⚠️ **LEGACY field (deprecated v1.8, removal planned v2.0)** — Old slug-based natural ID format: `entity:niacinamide`, `entity:peri_implantitis`. Preserved during transition for n8n workflow compatibility. **DO NOT USE for new development** — use `fingerprint` instead. Will be dropped after all n8n workflows migrate to `fingerprint`-based references. |
| `entity_name` | `text` | ชื่อ entity primary (display name) |
| `entity_slug` | `text NOT NULL` | URL slug สำหรับ /entity/{slug} ถ้ามีหน้า dedicated. **v1.9: Auto-normalized via EUG Layer 2 trigger** |
| `brand_scope_primary` | `text GENERATED ALWAYS AS (CASE WHEN '*' = ANY(brand_scope) THEN '*' WHEN array_length(brand_scope, 1) >= 1 THEN brand_scope[1] ELSE '*' END) STORED` | **v1.9 NEW** — Computed column for EUG Layer 1 UNIQUE constraint. First brand in `brand_scope[]` or `*` for universal. |
| `entity_type` | `text` | **15-type master list** (per Bible Appendix A.1): `'condition'` / `'symptom'` / `'procedure'` / `'treatment'` / `'device'` / `'concept'` / `'product'` / `'drug'` / `'ingredient'` / `'anatomy'` / `'specialty'` / `'lab_test'` / `'biomarker'` / `'person'` / `'organization'` (Bible Part 2.6 Genesis Checklist) |
| `parent_entity_fp` | `text` | ⚠️ **Legacy field** — Use `seo_entity_relationships` with `edge_type='child_of'` for typed edges (Bible Part 2.7). Kept for backward compatibility. **Two-Phase Sync**: text-based reference filled at Phase 1, used to compute `parent_notion_id` at Phase 2 backfill |
| `parent_notion_id` | `text` | **Two-Phase Sync field** — Notion page ID ของ parent entity (filled at Phase 2 backfill). NULL until parent has been synced to Notion. Used to populate Notion `parent_relation` property for tree UI rendering |
| `sync_state` | `text DEFAULT 'flat_loaded'` | **Two-Phase Sync state**: `'flat_loaded'` / `'notion_synced'` / `'relations_backfilled'` / `'live'` (Bible Part 18.8) |
| `aliases` | `jsonb DEFAULT '{}'` | **v1.6+** — Multilingual aliases per language. Schema: `{"en": ["sleep apnea syndrome", "OSA"], "th": ["หยุดหายใจตอนนอน", "นอนกรนแบบรุนแรง"]}` (Bible Part 28.3). **Used by EUG Layer 3a** 🆕 v1.9 |
| `topic_cluster_id` | `text FK` | Topic cluster ที่ entity นี้สังกัด (จาก seo_topic_cluster_master) |
| `topic_cluster_name` | `text` | Denormalized cluster name (ความเร็ว query) |
| `schema_org_type` | `text` | Schema.org type: 'MedicalCondition' / 'MedicalProcedure' / 'Drug' / 'AnatomicalStructure' / 'DefinedTerm' / etc. |
| `canonical_names` | `jsonb DEFAULT '{}'` | **v1.6+** — Multilingual entity names per language. Schema: `{"en": "Sleep Apnea", "th": "ภาวะหยุดหายใจขณะหลับ", "ja": "睡眠時無呼吸"}`. **Used by EUG Layer 3a** 🆕 v1.9 |
| `descriptions` | `jsonb DEFAULT '{}'` | **v1.6+** — Multilingual entity descriptions per language |
| `brand_display_names` | `jsonb DEFAULT '{}'` | **v1.6+** — Brand-specific marketing names per language. Schema: `{"vth-biodent": {"th": "การรักษา TMJ", "en": "TMJ Programme"}}` |
| `entity_subtype` | `text` | Optional subtype (e.g., 'autoimmune' for condition) |
| `icd_10_code` | `text` | ICD-10 code (if condition/symptom) |
| `icd_11_code` | `text` | ICD-11 code |
| `snomed_ct_id` | `text` | SNOMED CT identifier |
| `mesh_id` | `text` | MeSH identifier |
| `umls_cui` | `text` | UMLS CUI |
| `wikidata_id` | `text` | Wikidata Q-number |
| `wikipedia_url` | `text` | Wikipedia article URL |
| `same_as` | `text[]` | Array of equivalent identifiers (URLs to other knowledge bases) |
| `related_entities_fps` | `text[]` | ⚠️ **Legacy field** — Use `seo_entity_relationships` for typed edges. Kept for backward compatibility. |
| `hierarchy_path` | `text` | Materialized path (e.g., 'tmj > tmj_pain > tmj_acute_pain') |
| `brand_scope` | `text[] DEFAULT ARRAY['*']` | Federation: `['*']` (universal), `['vth-biodent']` (single-brand), `['vth-biodent', 'vitalsleep']` (shared) |
| `applicable_verticals` | `text[]` | Verticals where this entity applies (Bible Part 14) |
| `evidence_level` | `text` | Strength of evidence (e.g., 'strong', 'moderate', 'limited') |
| `type_properties` | `jsonb DEFAULT '{}'` | Type-specific properties (Bible Part 2.5 Polymorphism) |
| `entity_lifecycle` | `text DEFAULT 'emerging'` | 'emerging' / 'growing' / 'mature' / 'deprecated' (Bible Part 7 SKOS) |
| `reviewed_by_fp` | `text FK→seo_authors.fingerprint` | Author who last reviewed |
| `freshness_status` | `text` | 'fresh' / 'aging' / 'stale' (computed) |
| `last_reviewed_at` | `timestamptz` | Last review timestamp |
| `entity_authority_score` | `integer` | **v1.3** — Computed authority score (0-100, Bible Part 27.3) |
| `entity_authority_breakdown` | `jsonb` | **v1.3** — Score component breakdown |
| `entity_freshness_score` | `integer` | **v1.3** — Score 0-100 |
| `entity_completeness_score` | `integer` | **v1.3** — Score 0-100 |
| `score_formula_version` | `text` | **v1.3** — Formula version |
| `score_computed_at` | `timestamptz` | **v1.3** — Last score computation |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_entity_fingerprint (fingerprint);
UNIQUE INDEX idx_entity_legacy_fp (entity_fingerprint) WHERE entity_fingerprint IS NOT NULL;
UNIQUE INDEX idx_entity_slug_brand (entity_slug, brand_scope_primary);  -- v1.9 EUG Layer 1
INDEX idx_entity_type (entity_type);
INDEX idx_entity_brand_scope ON seo_entity_graph USING gin(brand_scope);
INDEX idx_entity_canonical_names_gin ON seo_entity_graph USING gin(canonical_names);
INDEX idx_entity_aliases_gin ON seo_entity_graph USING gin(aliases);  -- v1.9 EUG Layer 3a
INDEX idx_entity_slug_trgm ON seo_entity_graph USING gin(entity_slug gin_trgm_ops);  -- v1.9 EUG Layer 3b
INDEX idx_entity_topic_cluster (topic_cluster_id);
INDEX idx_entity_parent (parent_entity_fp) WHERE parent_entity_fp IS NOT NULL;
INDEX idx_entity_lifecycle (entity_lifecycle) WHERE entity_lifecycle != 'mature';

-- v1.8 Two-Column Identity triggers
CREATE TRIGGER set_fp_before_insert_entity
  BEFORE INSERT ON seo_entity_graph
  FOR EACH ROW EXECUTE FUNCTION trg_set_fingerprint_entity();

CREATE TRIGGER prevent_fp_update_entity
  BEFORE UPDATE ON seo_entity_graph
  FOR EACH ROW EXECUTE FUNCTION trg_prevent_fingerprint_change();

CREATE TRIGGER refresh_display_name_entity
  BEFORE UPDATE ON seo_entity_graph
  FOR EACH ROW EXECUTE FUNCTION trg_refresh_display_name_entity();

-- v1.9 EUG Layer 2 trigger
CREATE TRIGGER normalize_slug_before_write
  BEFORE INSERT OR UPDATE OF entity_slug ON seo_entity_graph
  FOR EACH ROW EXECUTE FUNCTION trg_normalize_entity_slug();
```

#### Used By
- **Part 2 (Knowledge Graph core)** — every page links to entities
- **seo_website_page_master.primary_entity_fp** — page anchored to entity
- **seo_entity_relationships** — typed edges between entities
- **seo_entity_embeddings** — vector embeddings per entity
- **All citation tracking** — citations attached to entities
- **EUG (v1.9)** — protected by 4-layer uniqueness enforcement

---

### 4.2 `seo_topic_cluster_master`

> **Purpose:** SKOS-based topic cluster definitions — hub-and-spoke organization, pillar-supporting page ratios (Bible Part 3 + Part 7)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Volume:** ~50-150 clusters per brand portfolio

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.8** — Format: `clus_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8** — Format: `{fp_last_6}::{cluster_id}::{cluster_name}` |
| `cluster_id` | `text UNIQUE` | kebab-case identifier |
| `cluster_name` | `text NOT NULL` | Display name |
| `canonical_names` | `jsonb DEFAULT '{}'` | **v1.6+** — Multilingual cluster names |
| `pref_label` | `text` | SKOS prefLabel |
| `alt_labels` | `text[]` | SKOS altLabels |
| `cluster_type` | `text` | 'topical' / 'content-format' / 'audience' |
| `domain_id` | `text` | Domain identifier (e.g., 'A: TMJ & Jaw') |
| `parent_cluster_id` | `text` | Parent cluster (SKOS broader) |
| `parent_notion_id` | `text` | **v1.7** — Two-Phase Sync field |
| `sync_state` | `text DEFAULT 'flat_loaded'` | **v1.7** |
| `pillar_page_id` | `uuid FK→page_master.id` | L5 pillar page |
| `definition` | `text` | SKOS definition |
| `scope_note` | `text` | Boundary clarification |
| `brand_scope` | `text[] DEFAULT ARRAY['*']` | Federation scope |
| `applicable_verticals` | `text[]` | Vertical applicability |
| `cluster_lifecycle` | `text DEFAULT 'pending_review'` | 'pending_review' / 'active' / 'deprecated' / 'merged' (Bible Part 7) |
| `cluster_health_score` | `integer` | **v1.3** — Score 0-100 |
| `cluster_topical_authority` | `integer` | **v1.3** — Topical authority score |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Used By
- **seo_entity_graph.topic_cluster_id** — entities organized by cluster
- **seo_website_page_master.topical_cluster_id** — pages organized by cluster
- **Part 3 (Hub-Spoke)** — pillar-supporting ratio enforcement (8-25)

---

### 4.3 `seo_citations`

> **Purpose:** Master ของแหล่งอ้างอิง — peer-reviewed papers, clinical guidelines, government sources, textbooks (Bible Part 23.1)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Volume:** ~5,000-20,000 citations across all brands (universal pool)

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.8** — Format: `cite_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8** — Format: `{fp_last_6}::{citation_type}::{first_author}::{year}` |
| `citation_type` | `text NOT NULL` | 'journal_article' / 'clinical_guideline' / 'government_report' / 'textbook' / 'website' / 'press_release' |
| `evidence_tier` | `integer NOT NULL` | 1-6 (Bible Part 23.1) |
| `schema_evidence_level` | `text` | 'EvidenceLevelA' / 'EvidenceLevelB' / 'EvidenceLevelC' (Schema.org MedicalEvidenceLevel) |
| `title` | `text NOT NULL` | Citation title |
| `canonical_names` | `jsonb DEFAULT '{}'` | **v1.6+** — Multilingual titles |
| `authors` | `text[]` | Array of author names |
| `journal` | `text` | Journal name (if applicable) |
| `publisher` | `text` | Publisher (if applicable) |
| `publication_year` | `integer NOT NULL` | Year |
| `publication_date` | `date` | Specific date (if available) |
| `doi` | `text UNIQUE` | DOI identifier |
| `pmid` | `text UNIQUE` | PubMed ID |
| `pmc_id` | `text UNIQUE` | PMC ID |
| `isbn` | `text` | ISBN (if book) |
| `url` | `text` | Citation URL |
| `inline_quote_template` | `text` | Standard inline citation text |
| `citation_freshness_status` | `text` | 'fresh' / 'aging' / 'stale' (auto-computed per tier rules) |
| `conflict_of_interest_disclosed` | `boolean DEFAULT false` | COI declaration |
| `coi_details` | `text` | COI description |
| `is_retracted` | `boolean DEFAULT false` | Article retracted? |
| `retraction_date` | `date` | When retracted |
| `brand_scope` | `text[] DEFAULT ARRAY['*']` | Universal by default |
| `citation_authority_weight` | `numeric(5,2)` | **v1.3** — Computed authority weight |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz` | |

#### Used By
- **seo_page_citations** — junction table (page ↔ citation)
- **Part 23.1 (Citation Tier System)** — 6-tier evidence hierarchy
- **Part 13 (LLMO E-E-A-T)** — citation richness signal
- **Part 23.4 (Editorial Review)** — Stage 1 medical review checks evidence tier

---

### 4.4 `seo_page_citations`

> **Purpose:** Junction table — page อ้างอิง citation อะไรบ้าง พร้อม weight และ context  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S (simple relation)  
> **Volume:** ~3-10 citations per page × total pages

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.8** — Format: `pcit_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8** — Format: `{fp_last_6}::{page_slug}::{citation_first_author}::{year}` |
| `page_id` | `uuid FK→page_master.id` | |
| `citation_id` | `uuid FK→seo_citations.id` | |
| `citation_context` | `text` | Section in page (e.g., 'introduction' / 'mechanism' / 'efficacy' / 'safety') |
| `citation_pattern` | `text` | Pattern used: 'A' / 'B' / 'C' / 'D' / 'E' / 'F' (Bible Part 6) |
| `citation_position` | `integer` | Order in page |
| `inline_text` | `text` | Excerpt that connects to citation |
| `is_primary_evidence` | `boolean DEFAULT false` | Primary evidence for claim |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_page_citations_unique (page_id, citation_id, citation_context);
INDEX idx_page_citations_page (page_id);
INDEX idx_page_citations_citation (citation_id);
INDEX idx_page_citations_pattern (citation_pattern);
```

---

### 4.5 `seo_entity_relationships`

> **Purpose:** Junction table for **typed relationship edges** between entities — replaces generic `related_entities_fps[]` array.  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Bible Reference:** Part 2.7 (Edge Vocabulary), **Part 2.7.5 (Edge Evolution Policy)** 🆕 v1.9  
> **Volume:** ~3-15 relationships per entity × total entities

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.8** — Format: `rel_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8** — Format: `{fp_last_6}::{from_entity}::{edge_type}::{to_entity}` |
| `from_entity_fp` | `text FK→seo_entity_graph.fingerprint` | Source entity |
| `to_entity_fp` | `text FK→seo_entity_graph.fingerprint` | Target entity |
| `edge_type` | `text NOT NULL` | One of 10 LOCKED edges: 'parent_of' / 'child_of' / 'subtype_of' / 'treats' / 'treated_by' / 'symptom_of' / 'uses' / 'used_by' / 'alternative_to' / 'part_of' / 'contains' / 'requires_assessment' / 'evidenced_by' / 'related_to' (Bible Part 2.7). **v1.9: Locked per DR-012** |
| `is_bidirectional` | `boolean DEFAULT false` | true = symmetric edge (e.g., related_to, alternative_to) |
| `edge_strength` | `integer` | **v1.3** — 0-100, signal strength (formula Bible Part 27.3) |
| `edge_evidence_score` | `integer` | **v1.3** — Score 0-100 |
| `notes` | `text` | Free-text editorial note |
| `evidence_citation_fp` | `text FK→seo_citations.fingerprint` | Optional citation backing this edge |
| `brand_scope` | `text[] DEFAULT ARRAY['*']` | Federation scope |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_relationship_unique (from_entity_fp, to_entity_fp, edge_type);
INDEX idx_relationship_from (from_entity_fp);
INDEX idx_relationship_to (to_entity_fp);
INDEX idx_relationship_edge_type (edge_type);

-- v1.9 — Edge Vocabulary CHECK constraint (DR-012 enforcement)
CONSTRAINT valid_edge_type CHECK (edge_type IN (
  'parent_of', 'child_of', 'subtype_of', 'part_of', 'contains',
  'treats', 'treated_by', 'symptom_of', 'requires_assessment',
  'uses', 'used_by', 'alternative_to', 'evidenced_by', 'related_to'
));
```

#### Used By
- **Part 2.7 (Edge Vocabulary)** — typed edges
- **Part 26.4 (Schema Generation)** — edge → JSON-LD
- **WordPress ACF eywa_relationships** — frontend rendering

---

## 5. Group 3 — Page System (2 tables)

> **Role:** Page metadata + URL structure + multilingual content  
> **Bible Reference:** Part 3 (Page Definition), Part 4 (Sitemap), Part 9 (Template Anatomy), Part 28 (Multilingual)

### 5.1 `seo_website_page_master`

> **Purpose:** Master ของทุกหน้าในระบบ — Layer + Tier + Funnel + Type tagging, multilingual, schema markup planning  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Volume:** ~500-5000 pages per brand

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.8** — Format: `page_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8** — Format: `{fp_last_6}::{layer}::{slug}::{language}::{brand_slug}` |
| `page_fingerprint` | `text UNIQUE` | ⚠️ Legacy field |
| `wp_post_id` | `bigint` | WordPress post ID (after publish) |
| `brand_slug` | `text NOT NULL FK→brands.brand_slug` | **v1.8** — Brand owner |
| `sitemap_node_id` | `text NOT NULL` | Numbered hierarchy ID (e.g., '5.2.1') |
| `page_url` | `text` | Canonical URL |
| `page_slug` | `text` | URL slug |
| `page_title` | `text` | H1 / og:title |
| `meta_description` | `text` | Meta description |
| **— Three-Dimensional Tagging (Bible Part 3) —** | | |
| `seo_layer` | `text NOT NULL` | L1 / L2 / L3 / L4 / L5 / L6 / L7 |
| `seo_tier` | `text NOT NULL` | A / B / C / D |
| `funnel_stage` | `text NOT NULL` | top / mid / bottom / retention |
| `page_type` | `text NOT NULL` | A (Standard) / B (Branch Landing) / C (Programmatic) / D (Tagged) |
| **— Knowledge Graph Anchoring —** | | |
| `primary_entity_fp` | `text FK→seo_entity_graph.fingerprint` | Anchor entity |
| `topical_cluster_id` | `text FK→seo_topic_cluster_master.cluster_id` | Cluster |
| `secondary_entities_fps` | `text[]` | Additional entities |
| `target_keyword_fp` | `text FK→seo_x_ads_keywords_contextual_master.fingerprint` | Primary keyword target |
| **— Multilingual (Tier 2 pattern, v1.7+) —** | | |
| `translation_group_id` | `text` | Format: `tg_{ULID16}` — shared across translations |
| `page_language` | `text NOT NULL` | ISO 639-1 (e.g., 'th', 'en') |
| `is_source_page` | `boolean DEFAULT false` | true = canonical for hreflang (exactly 1 per group) |
| `source_translation_fp` | `text` | Reference to source page (NULL if is_source) |
| **— Schema Markup —** | | |
| `schema_org_type` | `text` | Schema.org type (must match seo_layer per mapping) |
| `schema_markup_planned` | `jsonb` | Planned JSON-LD blocks |
| **— Editorial —** | | |
| `author_fp` | `text FK→seo_authors.fingerprint` | Author |
| `medical_reviewer_fp` | `text FK→seo_authors.fingerprint` | Medical reviewer |
| `last_reviewed_at` | `timestamptz` | Last editorial review |
| `editorial_status` | `text DEFAULT 'planned'` | 'planned' / 'drafting' / 'reviewing' / 'published' / 'updating' / 'archived' |
| **— Two-Phase Sync —** | | |
| `parent_notion_id` | `text` | **v1.7** |
| `sync_state` | `text DEFAULT 'flat_loaded'` | **v1.7** |
| **— Scoring (v1.3) —** | | |
| `e_e_a_t_score` | `integer` | 0-100 |
| `e_e_a_t_breakdown` | `jsonb` | |
| `content_quality_score` | `integer` | 0-100 |
| `page_freshness_score` | `integer` | 0-100 |
| `score_formula_version` | `text` | |
| `score_computed_at` | `timestamptz` | |
| **— Sitemap Design (v1.10) —** | | |
| `content_brief` | `text NULL` | **v1.10 (DR-017)** — Editorial brief from sitemap phase. REQUIRED for collapsed pages, recommended otherwise. Free-text 2-5 sentences/bullets. |
| `marketplace_proposal_status` | `text NULL` | **v1.10 (DR-015)** — Reconciliation status: `direct_match` / `repackaged` / `forced_fit_with_caveat` / `rejected`. NULL = not yet reconciled. |
| `reconciliation_notes` | `text NULL` | **v1.10 (DR-015)** — Operator's repackaging rationale (Necessity score, Brand-Fit verdict, SEO opportunity, framing decision). |
| `viability_assessment` | `jsonb NULL` | **v1.10 (DR-016)** — Audit trail for §4.14 quality gate. Schema: `{predicted_volume, search_volume, topic_distinctness, intent_distinctness, decision, exception_clause}`. |
| **— Lifecycle —** | | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `published_at` | `timestamptz` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_page_fingerprint (fingerprint);
UNIQUE INDEX idx_page_translation_source (translation_group_id) WHERE is_source_page = true;
INDEX idx_page_brand_slug (brand_slug);
INDEX idx_page_sitemap_node (sitemap_node_id);
INDEX idx_page_layer_tier (seo_layer, seo_tier);
INDEX idx_page_translation_group (translation_group_id) WHERE translation_group_id IS NOT NULL;
INDEX idx_page_language (page_language);
INDEX idx_page_primary_entity (primary_entity_fp) WHERE primary_entity_fp IS NOT NULL;

-- v1.10 additions (DR-015, DR-016, DR-017)
ALTER TABLE seo_website_page_master
  ADD CONSTRAINT chk_marketplace_proposal_status
  CHECK (marketplace_proposal_status IS NULL OR marketplace_proposal_status IN (
    'direct_match', 'repackaged', 'forced_fit_with_caveat', 'rejected'
  ));

INDEX idx_page_marketplace_status (marketplace_proposal_status)
  WHERE marketplace_proposal_status IS NOT NULL;
INDEX idx_page_content_brief_present (brand_slug)
  WHERE content_brief IS NOT NULL;
INDEX idx_page_viability_gin ON seo_website_page_master USING gin (viability_assessment)
  WHERE viability_assessment IS NOT NULL;
```

#### Migration Files (v1.10)

```sql
-- File: 007_add_content_brief.sql (DR-017)
ALTER TABLE seo_website_page_master
  ADD COLUMN IF NOT EXISTS content_brief text NULL;
COMMENT ON COLUMN seo_website_page_master.content_brief IS
  'Editorial brief captured at sitemap design time. Required for collapsed pages (DR-016). Recommended otherwise. Free-text 2-5 sentences or bullets.';

-- File: 008_add_sitemap_design_columns.sql (DR-015, DR-016)
ALTER TABLE seo_website_page_master
  ADD COLUMN IF NOT EXISTS marketplace_proposal_status text NULL,
  ADD COLUMN IF NOT EXISTS reconciliation_notes text NULL,
  ADD COLUMN IF NOT EXISTS viability_assessment jsonb NULL,
  ADD CONSTRAINT chk_marketplace_proposal_status
    CHECK (marketplace_proposal_status IS NULL OR marketplace_proposal_status IN (
      'direct_match', 'repackaged', 'forced_fit_with_caveat', 'rejected'
    ));
COMMENT ON COLUMN seo_website_page_master.marketplace_proposal_status IS
  'DR-015 Market Reconciliation status — see Bible §4.13.';
COMMENT ON COLUMN seo_website_page_master.reconciliation_notes IS
  'DR-015 Operator notes — Necessity/Brand-Fit/SEO Opportunity rationale.';
COMMENT ON COLUMN seo_website_page_master.viability_assessment IS
  'DR-016 Page Viability Assessment audit trail — see Bible §4.14.';
```

---

### 5.2 `seo_editorial_reviews`

> **Purpose:** Track editorial review workflow per page (5-stage process per Bible Part 23.4)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Volume:** ~5 reviews per page (one per stage)

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE NOT NULL` | **v1.8** — Format: `rev_{ULID16}` |
| `fingerprint_display_name` | `text NOT NULL` | **v1.8** |
| `page_id` | `uuid FK→page_master.id` | |
| `translation_group_id` | `text` | **v1.8** — For multilingual review tracking |
| `review_stage` | `text NOT NULL` | 'medical' / 'seo' / 'brand_voice' / 'legal_pdpa' / 'final_signoff' |
| `reviewer_fp` | `text FK→seo_authors.fingerprint` | Reviewer |
| `review_status` | `text DEFAULT 'pending'` | 'pending' / 'in_review' / 'approved' / 'changes_requested' / 'rejected' |
| `review_notes` | `text` | Detailed notes |
| `started_at` | `timestamptz` | |
| `completed_at` | `timestamptz` | |
| `sla_deadline` | `timestamptz` | SLA enforcement |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

---

## 6. Group 4 — Keyword & Search Intelligence (4 tables)

> **Role:** Keyword research, market intelligence, SERP competitive analysis, voice search  
> **Bible Reference:** Part 13 (LLMO Playbook), Part 14 (Vertical Profiles), Part 20 (KPIs)

### 6.1 `seo_x_ads_keywords_contextual_master`

> **Purpose:** Master ของทุก keyword — เป็น exception ของ Two-Column Identity Pattern (keeps existing format)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Volume:** ~50,000-200,000 keywords across all brands

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE NOT NULL` | **EXCEPTION — keeps existing format**: `{brand_slug}::{market}::{language}::{keyword}` (Bible Section 18.9 exception clause) |
| `keyword` | `text NOT NULL` | The keyword text |
| `brand` | `text` | Legacy field (use `brand_slug` going forward) |
| `brand_slug` | `text NOT NULL FK→brands.brand_slug` | **v1.8** |
| `market` | `text NOT NULL` | Country/market code |
| `language` | `text NOT NULL` | ISO 639-1 |
| `translation_group` | `text` | **EXCEPTION — pre-existing pattern (matches Tier 2 multilingual)** |
| `search_intent` | `text` | 'informational' / 'transactional' / 'navigational' / 'commercial' |
| `funnel_stage` | `text` | 'top' / 'mid' / 'bottom' / 'retention' |
| `notion_tier` | `text DEFAULT 'universe'` | 'universe' / 'galaxy' / 'star' / 'planet' / 'satellite' |
| `primary_entity_fp` | `text FK→entity_graph.fingerprint` | Mapped entity |
| `primary_entity_name` | `text` | Denormalized |
| `note` | `text` | Editorial note |
| `keyword_contextual_ready_last_update` | `timestamptz` | When contextual analysis complete |
| `gsc_last_update` | `timestamptz` | GSC data freshness |
| `ga4_last_update` | `timestamptz` | GA4 data freshness |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (fingerprint);  -- exception: keyword uses fingerprint as PK
INDEX idx_keywords_brand (brand_slug);
INDEX idx_keywords_intent (search_intent);
INDEX idx_keywords_funnel (funnel_stage);
INDEX idx_keywords_tier (notion_tier);
INDEX idx_keywords_entity (primary_entity_fp);
INDEX idx_keywords_translation_group (translation_group) WHERE translation_group IS NOT NULL;
INDEX idx_keywords_keyword_trgm USING GIN (keyword gin_trgm_ops);
```

---

### 6.2 `seo_x_ads_keywords_monthly_market_snapshot`

> **Purpose:** Monthly market intelligence per keyword (DataForSEO enriched)  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** S only (high-volume snapshot, no Notion mirror)  
> **Volume:** ~10,000+ records/month

#### Schema (Key Columns Selected)

```yaml
# Volume Metrics
search_volume: integer
search_volume_trend_3m: numeric
cpc_min, cpc_max, cpc_avg: numeric
competition_level: text  # 'low' / 'medium' / 'high'

# Momentum
momentum_score: integer  # 0-100
seasonality_pattern: jsonb  # monthly distribution

# DataForSEO Source
dataforseo_collected_at: timestamptz
```

→ **Full schema** : preserved from v1.8

---

### 6.3 `seo_x_ads_keyword_serp_competitors`

> **Purpose:** SERP competitor tracking per keyword × snapshot  
> **Tier:** 2  
> **Sync:** S only  
> **Volume:** ~50,000+ records (10 competitors × keywords × snapshots)

→ **Full schema** : preserved from v1.8

---

### 6.4 `seo_x_voice_search`

> **Purpose:** Voice search query optimization tracking  
> **Tier:** 2  
> **Sync:** N↔S (master setup), S only (analytics)  
> **Volume:** ~5,000-15,000 records

→ **Full schema** : preserved from v1.8

---

## 7. Group 5 — Performance Fact Tables (2 tables)

> **Role:** High-volume time-series performance tracking (rolling + yearly partitioned)  
> **Bible Reference:** Part 5.7 (Architecture), Part 20 (KPIs), Part 23.5 (CWV targets)

### 7.1 `seo_x_ads_keywords_x_url_daily_logs`

> **Purpose:** Daily metrics per (URL × keyword × snapshot date) — rankings, traffic, CTR, CWV, on-page health  
> **Tier:** 1 (Critical Operational)  
> **Sync:** S only (high volume, no Notion mirror)  
> **Volume:** ~50,000-500,000 records/month

#### Schema (Key Columns Selected — full has 130+ columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text FK→keywords_master.fingerprint` | Keyword |
| `target_url` | `text NOT NULL` | URL |
| `snapshot_at` | `date NOT NULL` | Snapshot date |
| `serp_position` | `integer` | Google rank |
| `impressions` | `integer` | GSC impressions |
| `clicks` | `integer` | GSC clicks |
| `ctr` | `numeric(5,4)` | Click-through rate |
| `lcp_ms` | `integer` | Largest Contentful Paint (ms) |
| `inp_ms` | `integer` | Interaction to Next Paint (ms) |
| `cls` | `numeric(4,3)` | Cumulative Layout Shift |
| `is_indexable` | `boolean` | Indexability |
| `inbound_links_count` | `integer` | Internal inbound link count |
| `outbound_links_count` | `integer` | Internal outbound link count |
| `created_at` | `timestamptz DEFAULT now()` | |

**CWV Targets per Layer (Bible Part 23.5):**

```yaml
Layer_2_Money_Pages:        LCP ≤ 2.0s, INP ≤ 150ms, CLS ≤ 0.1
Layer_4_Concern_Pillars:    LCP ≤ 2.0s, INP ≤ 150ms, CLS ≤ 0.05
Layer_5_Knowledge_Hub:      LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1
Layer_7_Evidence_Pages:     LCP ≤ 2.8s, INP ≤ 200ms, CLS ≤ 0.1
```

→ **Full schema** : preserved from v1.8

---

### 7.2 `seo_local_rankings`

> **Purpose:** Local SERP / Map Pack rankings per (keyword × search point × branch). Tracks Local Pack position, Maps position, and competitor presence at various search points around each branch.
> **Tier:** 1
> **Sync:** S only
> **Bible Reference:** Part 10.5 (Local SEO), Part 16 (KPIs — Local Pack metric), Appendix B.5 Table 28
> **Volume:** ~10,000-50,000 records/month (keyword × branch × search_point × snapshot)
> **Cost note:** Auto-tracking requires paid tool ($24-99/mo per location); manual sampling is free but lower frequency

> **v1.11 NOTE (DR-025):** FK column is `branch_id` (FK → `seo_branches.id`). Bible Appendix B.5 Table 28 previously referenced `location_id` — that label is now consistently `branch_id` across Schema + Bible v3.15. No data migration needed in this table (column was already named `branch_id` in Schema v1.10).

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `keyword_fp` | `text FK→keywords_master.fingerprint` | Keyword being ranked |
| `branch_id` | `uuid FK→seo_branches(id)` | Branch whose ranking is measured (🔄 v1.11 — formerly `location_id` per Bible Appendix B.5 Table 28; consolidated naming per DR-025) |
| `brand_id` | `uuid FK→brands(id)` | Denormalized for query speed |
| `search_location_lat` | `numeric(10,7)` | GPS lat of search simulation point |
| `search_location_lng` | `numeric(10,7)` | GPS lng of search simulation point |
| `search_location_name` | `text` | Human label ('1km north of branch', 'BTS Asoke', etc.) |
| `search_radius_km` | `numeric(5,2)` | Search radius from point |
| `device_type` | `text` | 'mobile' / 'desktop' / 'tablet' |
| `snapshot_at` | `date NOT NULL` | Date of measurement |
| `local_pack_position` | `integer` | 1-3 visible in map pack (NULL if not in pack) |
| `local_pack_total_results` | `integer` | Total Local Pack listings shown |
| `local_finder_position` | `integer` | Position in Local Finder (after "More places") |
| `maps_position` | `integer` | Position in Google Maps result |
| `maps_total_results` | `integer` | |
| `is_in_local_pack_three` | `boolean GENERATED ALWAYS AS (local_pack_position BETWEEN 1 AND 3) STORED` | Convenience flag |
| `organic_position` | `integer` | Position in organic results (blue links) |
| `featured_in_snippet` | `boolean DEFAULT false` | |
| `ai_overview_cited` | `boolean DEFAULT false` | Cited in Google AI Overview |
| `competitors_in_map_pack` | `jsonb` | Top 3 competitors at this query/location |
| `distance_to_branch_km` | `numeric(6,2)` | Distance from search point to branch |
| `previous_position` | `integer` | Previous snapshot's local_pack_position |
| `position_change` | `integer GENERATED ALWAYS AS (COALESCE(previous_position, 0) - COALESCE(local_pack_position, 0)) STORED` | + improvement / − decline |
| `data_source` | `text` | 'brightlocal' / 'whitespark' / 'manual' / 'dataforseo' / 'gbp_insights' |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Migration Files

- `013_rename_local_rankings_fk.sql` (DR-025 — descriptive rename + new columns; no destructive migration since column already named `branch_id`)

---

## 8. Group 6 — Backlinks & Off-Page (2 tables)

> **Role:** Backlink profile tracking — aggregate stats + individual link records  
> **Bible Reference:** Part 13 (LLMO — authority signals), Part 23.3 (Authority Validation)

### 8.1 `seo_backlinks_data`

> **Purpose:** Aggregate backlink statistics per (URL × snapshot date)  
> **Tier:** 2  
> **Sync:** S only (DataForSEO ingestion)  
> **Volume:** ~1,000-5,000 records

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `target_url` | `text NOT NULL` | |
| `target_domain` | `text NOT NULL` | |
| `snapshot_at` | `date NOT NULL` | |
| `total_backlinks` | `integer` | |
| `referring_domains` | `integer` | |
| `dofollow_count` | `integer` | |
| `broken_backlinks` | `integer` | |
| `new_backlinks` | `integer` | velocity tracking |
| `lost_backlinks` | `integer` | |
| `domain_rank` | `integer` | DR (0-100) |
| `avg_source_dr` | `numeric` | |
| `backlink_summary_json` | `jsonb` | Detailed summary |
| `created_at` | `timestamptz DEFAULT now()` | |

---

### 8.2 `seo_backlinks_links`

> **Purpose:** Individual backlink records  
> **Tier:** 2  
> **Sync:** S only  
> **Volume:** ~10,000-100,000+ records

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `target_url` | `text NOT NULL` | |
| `source_url` | `text NOT NULL` | |
| `source_domain` | `text NOT NULL` | |
| `anchor_text` | `text` | |
| `is_dofollow` | `boolean` | |
| `is_broken` | `boolean DEFAULT false` | |
| `source_domain_rank` | `integer` | |
| `source_page_rank` | `integer` | |
| `spam_score` | `integer` | 0-17, ≥8 = toxic candidate |
| `first_seen_at` | `timestamptz` | |
| `last_seen_at` | `timestamptz` | |
| `created_at` | `timestamptz DEFAULT now()` | |

---

## 9. Group 7 — AI Operations & Embeddings (4 tables)

> **Role:** Track AI engine interactions, brand mentions, citations, vector embeddings  
> **Bible Reference:** Part 21 (AI Operations), Part 13 (LLMO Playbook), Part 20 (KPIs #11, #12, #13)

### 9.1 `seo_brand_mentions`

> **Purpose:** Track when AI engines mention our brand  
> **Tier:** 1  
> **Sync:** S only  
> **Volume:** ~5,000-20,000 records/month

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `mention_fingerprint` | `text UNIQUE` | |
| `brand_id` | `uuid FK→brands.id` | |
| `ai_engine` | `text NOT NULL` | 'chatgpt' / 'claude' / 'gemini' / 'perplexity' / 'copilot' |
| `triggering_query_fp` | `text FK→keywords_master.fingerprint` | |
| `mention_position` | `integer` | Position in AI response |
| `is_first_in_list` | `boolean` | |
| `mention_sentiment` | `text` | 'positive' / 'neutral' / 'negative' |
| `wikidata_referenced` | `boolean` | Did AI reference our Wikidata? |
| `observed_at` | `timestamptz NOT NULL` | |
| `created_at` | `timestamptz DEFAULT now()` | |

---

### 9.2 `seo_llm_citations`

> **Purpose:** Track when AI engines cite our URLs  
> **Tier:** 1  
> **Sync:** S only  
> **Volume:** ~2,000-10,000 records/month

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `citation_fingerprint` | `text UNIQUE` | |
| `our_url` | `text NOT NULL` | |
| `our_url_fp` | `text FK→page_master.fingerprint` | |
| `brand_id` | `uuid FK→brands.id` | |
| `ai_engine` | `text NOT NULL` | |
| `triggering_query` | `text NOT NULL` | |
| `triggering_query_fp` | `text FK→keywords_master.fingerprint` | |
| `citation_position` | `integer` | |
| `total_citations_in_response` | `integer` | |
| `cited_excerpt` | `text` | |
| `pattern_type` | `text` | 'A' / 'B' / 'C' / 'D' / 'E' / 'F' (Bible Part 6) |
| `citation_quality_score` | `integer` | 0-100 |
| `brand_also_mentioned` | `boolean DEFAULT false` | |
| `linked_brand_mention_id` | `uuid FK→seo_brand_mentions.id` | |
| `simulation_id` | `uuid FK→seo_llm_query_simulations.id` | |
| `observed_at` | `timestamptz NOT NULL` | |
| `created_at` | `timestamptz DEFAULT now()` | |

---

### 9.3 `seo_llm_query_simulations`

> **Purpose:** Automated AI engine probing — execute queries, capture responses  
> **Tier:** 2  
> **Sync:** S only  
> **Volume:** ~10,000+ records/month

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `simulation_batch_id` | `uuid` | |
| `query_text` | `text NOT NULL` | |
| `mapped_keyword_fp` | `text FK→keywords_master.fingerprint` | |
| `ai_engine` | `text NOT NULL` | |
| `our_brand_mentioned` | `boolean DEFAULT false` | |
| `our_brand_mention_position` | `integer` | |
| `our_url_cited` | `boolean DEFAULT false` | |
| `competitor_brands_mentioned` | `text[]` | |
| `simulated_at` | `timestamptz NOT NULL` | |
| `simulation_method` | `text` | 'api_direct' / 'browser_automation' / 'manual' |
| `cost_usd` | `numeric(10,4)` | |
| `created_at` | `timestamptz DEFAULT now()` | |

---

### 9.4 `seo_entity_embeddings`

> **Purpose:** Vector embeddings for semantic search, RAG, **and EUG v2.0 Wave 2** 🆕 v1.9  
> **Tier:** 2  
> **Sync:** S only  
> **Required Extension:** `pgvector`  
> **Volume:** ~5,000-50,000 vectors per brand portfolio

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `source_type` | `text NOT NULL` | 'entity' / 'page' / 'citation' / 'keyword' / 'cluster' / 'paragraph' |
| `source_fingerprint` | `text NOT NULL` | Reference to source |
| `embedding` | `vector(1536)` | OpenAI text-embedding-3-small (1536 dims) |
| `embedding_model` | `text NOT NULL` | e.g., 'text-embedding-3-small' |
| `model_version` | `text` | |
| `embedded_text` | `text` | Source text that was embedded |
| `text_hash` | `text` | SHA256 hash of text (dedup) |
| `language` | `text` | ISO 639-1 |
| `embedded_at` | `timestamptz NOT NULL` | |
| `expires_at` | `timestamptz` | TTL for re-embedding |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_embeddings_source_text (source_fingerprint, source_type, text_hash);
INDEX idx_embeddings_source (source_type, source_fingerprint);
INDEX idx_embeddings_hnsw ON seo_entity_embeddings USING hnsw (embedding vector_cosine_ops);
```

> **v1.9 Note — EUG v2.0 Wave 2 will leverage this table:**  
> When pgvector + embedding pipeline are live (Phase 2), EUG Layer 4 will query this table for cosine similarity to detect deep semantic synonym duplicates. No schema changes required — only new SQL function `eug_preflight_check_v2()`. See Bible Section 2.6.6.2 + DR-011 amendment.

---

## 10. Group 8 — Data Quality & Governance (2 tables)

> **Role:** Data quality monitoring + DDL audit trail  
> **Bible Reference:** Part 19 (Data Quality), Part 15 (Schema Governance)

### 10.1 `seo_data_quality_metrics`

> **Purpose:** Track data quality across tables  
> **Tier:** 3 (Operational/Audit)  
> **Sync:** S only  
> **Volume:** ~100-1000 records/day

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `target_table` | `text NOT NULL` | |
| `metric_dimension` | `text NOT NULL` | 'completeness' / 'accuracy' / 'freshness' / 'consistency' / 'uniqueness' / 'timeliness' (Bible Part 19.3) |
| `metric_score` | `integer` | 0-100 |
| `total_records` | `integer` | |
| `failing_records` | `integer` | |
| `failure_details` | `jsonb` | Sample failures |
| `measured_at` | `timestamptz NOT NULL` | |
| `created_at` | `timestamptz DEFAULT now()` | |

> **v1.9 Note:** EUG (Section 2.6.6.1) provides algorithmic enforcement for Dimension 5 (Uniqueness) — formalizing what was previously aspirational measurement.

---

### 10.2 `seo_schema_changes`

> **Purpose:** DDL audit trail (Bible Part 15)  
> **Tier:** 1  
> **Sync:** S only  
> **Volume:** ~50-500 records/year

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `change_type` | `text NOT NULL` | 'CREATE_TABLE' / 'ALTER_TABLE' / 'DROP_TABLE' / 'CREATE_INDEX' / etc. |
| `target_object` | `text NOT NULL` | Schema-qualified object name |
| `change_description` | `text` | Human-readable description |
| `migration_file` | `text` | Migration file name |
| `applied_at` | `timestamptz NOT NULL` | |
| `applied_by` | `text` | User/process that applied |
| `bible_reference` | `text` | Bible section reference |
| `decision_record_ref` | `text` | DR-NNN reference |
| `is_breaking_change` | `boolean DEFAULT false` | |
| `rollback_sql` | `text` | Rollback procedure |
| `created_at` | `timestamptz DEFAULT now()` | |

---

## 11. Group 9 — Entity Extensions & Templates (10 tables = 9 extensions + 1 template registry)

> **Role:** Type-specific entity extensions (polymorphism per Bible Part 2.5) + programmatic template registry  
> **Pattern:** Extensions are 1:1 FK to `seo_entity_graph` via `entity_fp` (text FK to `seo_entity_graph.fingerprint`); populated by trigger when `seo_entity_graph.entity_type` matches  
> **Bible Reference:** Part 2.5 (Entity Polymorphism), Part 5.11 (Group 9), Part 9 (Programmatic Templates), Part 14 (Vertical Profiles), Appendix B.3 (9 Extension Tables)  
> **Restored in v1.11 per DR-024 (Locked 2026-05-12):** 6 missing extensions added back (product, condition, drug, anatomy, organization, lab_test). `seo_programmatic_templates` renumbered §11.4 → §11.10 and reclassified as template registry (not entity extension).

### 11.1 `seo_entity_ingredients` *(entity_type='ingredient')*

> **Purpose:** Extension table for entities of type='ingredient' — INCI name, allergens, regulatory status. Primarily used by skincare/cosmetic verticals (the brand) and supplements (Dr. Trin).
> **Tier:** 2
> **Sync:** N↔S
> **Schema.org:** Substance / ChemicalSubstance
> **Bible Reference:** Part 5.11, Part 14.4 (Skincare-Media), Appendix B.3 Table 11
> **Volume:** ~500-2000 records

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `entity_fp` | `text FK→seo_entity_graph.fingerprint UNIQUE NOT NULL` | 1:1 link to entity (CASCADE) |
| `inci_name` | `text` | International Nomenclature of Cosmetic Ingredients |
| `inci_aliases` | `text[]` | Alternative INCI names |
| `cas_number` | `text` | Chemical Abstracts Service number |
| `ec_number` | `text` | European Community number |
| `ewg_id` | `text` | Environmental Working Group ID |
| `cosing_ref_no` | `text` | EU CosIng database ref |
| `allergen_status` | `text` | CHECK: 'safe' / 'restricted' / 'allergen' / 'restricted_concentration' |
| `comedogenic_rating` | `integer` | 0-5 scale |
| `irritancy_rating` | `integer` | 0-5 scale |
| `pregnancy_safe` | `boolean` | |
| `breastfeeding_safe` | `boolean` | |
| `fungal_acne_safe` | `boolean` | |
| `photosensitivity` | `boolean` | |
| `function_categories` | `text[]` | 'humectant', 'emollient', 'antioxidant', etc. |
| `concentration_range_typical` | `text` | e.g., '0.5-2%' |
| `typical_concentration_min` | `numeric(5,3)` | |
| `typical_concentration_max` | `numeric(5,3)` | |
| `effective_concentration_min` | `numeric(5,3)` | Minimum to be effective per research |
| `regulatory_status` | `jsonb` | Per-region: `{"FDA": "approved", "EU": "restricted"}` |
| `thai_fda_classification` | `text` | |
| `thai_fda_max_concentration` | `numeric(5,3)` | |
| `eu_annex_restriction` | `text` | EU Cosmetic Regulation Annex II/III/IV/V/VI |
| `us_fda_status` | `text` | |
| `mechanism_of_action` | `text` | |
| `evidence_level` | `text` | 'strong' / 'moderate' / 'weak' / 'anecdotal' |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Used By

- Skincare product pages (T-product) — list ingredients
- Comparison pages (T-comparison) — ingredient profile compare
- Listicle pages — "best Vitamin C serums" requires ingredient entity

#### Migration Files

- Pre-existing (Phase 1A baseline)

---

### 11.2 `seo_entity_devices` *(entity_type='device')*

> **Purpose:** Extension for entities of type='device' — FDA/CE mark, manufacturer, technology category. Used by medical/aesthetic devices (Fotona LightWalker for VTH BioDent NightLase, CBCT scanners, etc.).
> **Tier:** 2
> **Sync:** N↔S
> **Schema.org:** MedicalDevice
> **Bible Reference:** Part 5.11, Part 14.6 (Hospital), Appendix B.3 Table 19
> **Volume:** ~50-500 records

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `entity_fp` | `text FK→seo_entity_graph.fingerprint UNIQUE NOT NULL` | 1:1 link |
| `manufacturer` | `text` | e.g., 'Fotona' |
| `manufacturer_org_fp` | `text FK→seo_entity_graph.fingerprint` | 🆕 **v1.11** — Link to manufacturer's organization entity |
| `model_number` | `text` | e.g., 'LightWalker' |
| `device_family` | `text` | Product family grouping |
| `fda_clearance` | `text` | 510(k) number |
| `fda_clearance_date` | `date` | |
| `ce_mark` | `boolean` | |
| `ce_mark_class` | `text` | CHECK: 'I' / 'IIa' / 'IIb' / 'III' |
| `thai_fda_reg_no` | `text` | 🆕 **v1.11** — Thai FDA medical device registration |
| `regulatory_class` | `text` | CHECK: 'I' / 'II' / 'III' (US FDA classification) |
| `technology_category` | `text` | 'laser' / 'IPL' / 'RF' / 'ultrasound' / 'cryolipolysis' / 'imaging' / 'surgical' |
| `wavelength_nm` | `numeric(6,2)` | For laser/IPL devices |
| `clinical_indications` | `text[]` | What it treats |
| `contraindications` | `text[]` | When NOT to use |
| `treatment_areas` | `text[]` | Body areas |
| `typical_session_duration_min` | `integer` | |
| `typical_sessions_required` | `text` | e.g., '4-6 sessions' |
| `downtime_days` | `numeric(3,1)` | Recovery time |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Used By

- T-device pages (Fotona LightWalker page, NightLase pages)
- `seo_branches.equipment_at_branch_fps[]` — which devices each branch has
- Procedure pages that use specific devices

#### Migration Files

- Pre-existing (Phase 1A baseline)

---

### 11.3 `seo_entity_procedures` *(entity_type='procedure')*

> **Purpose:** Extension for entities of type='procedure' — CPT codes, contraindications, recovery time, technique details. Used by medical/dental/aesthetic procedures (caries treatment, NightLase, root canal, hair transplant, etc.).
> **Tier:** 2
> **Sync:** N↔S
> **Schema.org:** MedicalProcedure / SurgicalProcedure / TherapeuticProcedure / DiagnosticProcedure
> **Bible Reference:** Part 5.11, Part 14 (all medical verticals), Appendix B.3 Table 13
> **Volume:** ~100-1000 records

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `entity_fp` | `text FK→seo_entity_graph.fingerprint UNIQUE NOT NULL` | 1:1 link |
| `cpt_code` | `text` | Current Procedural Terminology (US billing) |
| `cpt_alternate_codes` | `text[]` | 🆕 **v1.11** — TH-specific or institutional billing codes |
| `procedure_type` | `text` | CHECK: 'surgical' / 'non_surgical' / 'minimally_invasive' / 'diagnostic' / 'therapeutic' |
| `invasiveness_level` | `text` | CHECK: 'non_invasive' / 'minimally_invasive' / 'invasive' |
| `procedure_duration_min` | `integer` | Minimum duration in minutes |
| `procedure_duration_max` | `integer` | Maximum duration in minutes |
| `procedure_duration_typical` | `integer` | Typical duration |
| `recovery_time_days` | `integer` | |
| `recovery_back_to_work_days` | `integer` | 🆕 **v1.11** — Back-to-work timing |
| `recovery_full_recovery_days` | `integer` | 🆕 **v1.11** — Full recovery timing |
| `anesthesia_type` | `text` | CHECK: 'none' / 'topical' / 'local' / 'sedation' / 'general' |
| `anesthesia_required` | `boolean DEFAULT false` | |
| `treats_conditions_fps` | `text[]` | 🆕 **v1.11** — FK array → `seo_entity_graph.fingerprint` (conditions this procedure treats) |
| `affects_anatomy_fps` | `text[]` | 🆕 **v1.11** — FK array → `seo_entity_graph.fingerprint` (anatomy involved) |
| `uses_devices_fps` | `text[]` | 🆕 **v1.11** — FK array → `seo_entity_graph.fingerprint` (devices used in procedure) |
| `contraindications` | `text[]` | |
| `contraindication_entities_fps` | `text[]` | 🆕 **v1.11** — Structured FK to condition entities |
| `complications_common` | `jsonb` | `[{name, frequency_pct, severity}]` |
| `success_rate_pct` | `numeric(5,2)` | Published success rate |
| `requires_followup` | `boolean DEFAULT false` | |
| `followup_visits_typical` | `integer` | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Used By

- T2-medical-procedure template (Bible §4.1.2 — primary)
- T-comparison pages (treatment-A vs treatment-B)
- Service page on branch landing (Bible Part 4.4)

#### Migration Files

- Pre-existing (Phase 1A baseline)

---

### 11.4 `seo_entity_product` *(entity_type='product')* 🆕 v1.11

> **Purpose:** Extension for entities of type='product' — commercial products including skincare, supplements, devices-as-products, OTC medical products. Distinct from `seo_entity_drug` (Rx) and `seo_entity_device` (capital equipment).
> **Tier:** 2
> **Sync:** N↔S
> **Schema.org:** Product (Schema.org core type)
> **Bible Reference:** Part 5.11, Part 14.4 (Skincare-Media), Part 14.5 (Wellness-Media), Appendix B.3 Table 12
> **Volume:** ~200-2000 records (heavy for skincare brand, light for clinic)
> **Used by brands:** the brand (skincare line), Dr. Trin (supplements), any brand selling product

> **DR Reference:** DR-024 Locked 2026-05-12 (Restore 9 Entity Extension Tables).

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `entity_fp` | `text FK→seo_entity_graph(fingerprint) UNIQUE NOT NULL` | 1:1 link (CASCADE) |
| **— Identification —** | | |
| `gtin` | `text` | Global Trade Item Number (UPC/EAN/ISBN) |
| `sku` | `text` | Internal SKU |
| `manufacturer_part_number` | `text` | MPN |
| `product_name` | `text NOT NULL` | Display name (canonical) |
| `product_slug` | `text` | URL-safe slug |
| **— Brand & Owner —** | | |
| `brand_owner_name` | `text` | Brand owner (may be external) |
| `brand_owner_org_fp` | `text FK→seo_entity_graph(fingerprint)` | Link to brand owner's organization entity |
| `is_own_brand_product` | `boolean DEFAULT false` | true if this brand owns the product |
| **— Categorization —** | | |
| `product_category` | `text NOT NULL` | 'skincare' / 'supplement' / 'medical_device_otc' / 'cosmetic' / 'wellness_product' |
| `product_subcategory` | `text` | 'serum' / 'cleanser' / 'moisturizer' / 'multivitamin' / etc. |
| `product_form` | `text` | 'cream' / 'serum' / 'capsule' / 'tablet' / 'powder' / 'liquid' / 'patch' |
| **— Composition —** | | |
| `ingredients_fps` | `text[]` | FK array → `seo_entity_ingredients` via entity_fp |
| `key_active_ingredients` | `text[]` | Marketing-facing actives (subset of ingredients) |
| `inactive_ingredients` | `text[]` | Excipients |
| `allergen_warnings` | `text[]` | Common allergens present |
| `free_from_claims` | `text[]` | 'paraben-free' / 'fragrance-free' / 'vegan' / 'cruelty-free' |
| **— Sizing & Variants —** | | |
| `size_value` | `numeric(8,2)` | Quantity value |
| `size_unit` | `text` | 'ml' / 'g' / 'oz' / 'capsules' / 'tablets' |
| `variants` | `jsonb` | `[{size, color, flavor, price}]` |
| **— Pricing —** | | |
| `price_min` | `numeric(10,2)` | |
| `price_max` | `numeric(10,2)` | |
| `price_typical` | `numeric(10,2)` | |
| `currency` | `text DEFAULT 'THB'` | ISO 4217 |
| `price_per_unit` | `numeric(10,4) GENERATED ALWAYS AS (CASE WHEN size_value > 0 THEN price_typical / size_value ELSE NULL END) STORED` | Auto-computed |
| **— Regulatory —** | | |
| `thai_fda_reg_no` | `text` | เลขจดแจ้ง อย. |
| `thai_fda_type` | `text` | 'เครื่องสำอาง' / 'ผลิตภัณฑ์เสริมอาหาร' / 'เครื่องมือแพทย์' |
| `regulatory_status` | `jsonb` | Per-region status |
| `requires_prescription` | `boolean DEFAULT false` | |
| **— Safety —** | | |
| `pregnancy_safe` | `boolean` | |
| `breastfeeding_safe` | `boolean` | |
| `pediatric_safe` | `boolean` | |
| `pediatric_min_age_years` | `numeric(4,1)` | |
| `contraindications` | `text[]` | |
| **— Certifications —** | | |
| `certifications` | `text[]` | 'GMP' / 'ISO22716' / 'COSMOS' / 'Halal' / 'HACCP' / 'organic' |
| **— Schema.org —** | | |
| `schema_product_type` | `text DEFAULT 'Product'` | 'Product' / 'Drug' (OTC) / 'DietarySupplement' |
| **— Metadata —** | | |
| `is_discontinued` | `boolean DEFAULT false` | |
| `launch_date` | `date` | |
| `discontinued_date` | `date` | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
CREATE INDEX idx_prod_entity ON seo_entity_product(entity_fp);
CREATE INDEX idx_prod_category ON seo_entity_product(product_category);
CREATE INDEX idx_prod_brand_owner ON seo_entity_product(brand_owner_org_fp);
CREATE INDEX idx_prod_thai_fda ON seo_entity_product(thai_fda_reg_no) WHERE thai_fda_reg_no IS NOT NULL;
CREATE INDEX idx_prod_active_ingredients ON seo_entity_product USING GIN(key_active_ingredients);
CREATE INDEX idx_prod_ingredients_fps ON seo_entity_product USING GIN(ingredients_fps);

ALTER TABLE seo_entity_product ADD CONSTRAINT check_category CHECK (product_category IN ('skincare', 'supplement', 'medical_device_otc', 'cosmetic', 'wellness_product', 'food_drink', 'medical_food'));
ALTER TABLE seo_entity_product ADD CONSTRAINT check_schema_type CHECK (schema_product_type IN ('Product', 'Drug', 'DietarySupplement', 'IndividualProduct', 'ProductModel'));
```

#### Populate Trigger

```sql
CREATE TRIGGER trg_populate_entity_product
  AFTER INSERT OR UPDATE OF entity_type ON seo_entity_graph
  FOR EACH ROW
  WHEN (NEW.entity_type = 'product')
  EXECUTE FUNCTION populate_entity_extension('product');
```

#### Used By

- T-product page template
- T-comparison page template
- T-listicle page template
- `seo_page_master` for product-focused pages (skincare brand)

#### Migration Files

- `014_restore_entity_product.sql` (DR-024)

---

### 11.5 `seo_entity_condition` *(entity_type='condition')* 🆕 v1.11

> **Purpose:** Extension for entities of type='condition' — diseases and medical conditions with ICD-10, SNOMED-CT, MeSH coding. **Primary schema binding for T1 medical-condition template** (Bible §4.1.1). Cross-referenced extensively with anatomy, drug, and procedure entities to form the medical knowledge graph.
> **Tier:** 1 (Critical — T1 template binding)
> **Sync:** N↔S
> **Schema.org:** MedicalCondition
> **Bible Reference:** Part 4.1.1 (T1 Medical Condition template), Part 5.11, Part 14 (all medical verticals), Appendix B.3 Table 14
> **Volume:** ~200-1500 records
> **Used by brands:** ALL medical brands — VTH BioDent (caries, periodontitis, OSA), Deezy (malocclusion), SmileScape (aesthetic concerns), Dr. Trin (men's vitality conditions), the brand (skin conditions)

> **DR Reference:** DR-024 Locked 2026-05-12 (Restore 9 Entity Extension Tables).

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `entity_fp` | `text FK→seo_entity_graph(fingerprint) UNIQUE NOT NULL` | 1:1 link (CASCADE) |
| **— Medical Coding —** | | |
| `icd10_code` | `text` | ICD-10-CM diagnosis code (e.g., 'K05.3' for chronic periodontitis) |
| `icd10_codes_related` | `text[]` | Additional ICD-10 codes for severity/progression |
| `snomed_ct_id` | `text` | SNOMED-CT concept ID |
| `mesh_id` | `text` | MeSH (Medical Subject Headings) identifier |
| `umls_cui` | `text` | UMLS Concept Unique Identifier |
| `wikidata_qid` | `text` | Wikidata Q-number (e.g., 'Q31796') |
| **— Classification —** | | |
| `condition_category` | `text` | 'infectious' / 'neoplastic' / 'metabolic' / 'genetic' / 'autoimmune' / 'degenerative' / 'traumatic' / 'congenital' / 'functional' / 'psychiatric' / 'unknown' |
| `body_system` | `text[]` | Affected systems: 'cardiovascular' / 'respiratory' / 'digestive' / 'oral' / 'integumentary' / etc. |
| `is_chronic` | `boolean` | |
| `is_acute` | `boolean` | |
| `is_recurrent` | `boolean` | |
| `is_lifestyle_related` | `boolean` | Smoking / diet / sleep / stress-related |
| **— Clinical Profile —** | | |
| `prevalence_global_pct` | `numeric(5,3)` | % of global population |
| `prevalence_thailand_pct` | `numeric(5,3)` | % of Thai population |
| `prevalence_source` | `text` | Citation source for prevalence |
| `incidence_per_100k_yearly` | `numeric(8,2)` | Annual incidence |
| `mortality_rate_pct` | `numeric(5,3)` | Untreated mortality |
| `severity_levels` | `text[]` | 'mild' / 'moderate' / 'severe' / 'critical' |
| **— Symptoms —** | | |
| `symptoms` | `text[]` | Common symptoms (text descriptions) |
| `symptom_entities_fps` | `text[]` | 🆕 — FK array → `seo_entity_graph` (symptom entities if modeled) |
| `early_warning_signs` | `text[]` | Patient-facing early signs |
| **— Anatomy Affected —** | | |
| `related_anatomy_fps` | `text[]` | FK array → `seo_entity_graph` (anatomy entities affected) |
| **— Treatment Cross-Refs —** | | |
| `treatment_drugs_fps` | `text[]` | FK array → `seo_entity_graph` (drug entities used in treatment) |
| `treatment_procedures_fps` | `text[]` | FK array → `seo_entity_graph` (procedure entities for treatment) |
| `prevention_strategies` | `text[]` | Free-text prevention guidance |
| **— Demographics —** | | |
| `affected_age_groups` | `text[]` | 'infant' / 'child' / 'adolescent' / 'adult' / 'elderly' |
| `gender_predominance` | `text` | CHECK: 'male' / 'female' / 'equal' / 'unknown' |
| `risk_factors` | `text[]` | |
| **— Diagnosis —** | | |
| `diagnostic_methods` | `text[]` | 'clinical_exam' / 'imaging' / 'blood_test' / 'biopsy' / 'genetic_test' |
| `diagnostic_tests_fps` | `text[]` | FK array → `seo_entity_lab_test` |
| **— Patient Communication —** | | |
| `patient_explanation_th` | `text` | Layperson explanation in Thai |
| `patient_explanation_en` | `text` | Layperson explanation in English |
| `common_misconceptions` | `text[]` | Myth-busting content seeds |
| **— SEO Metadata —** | | |
| `search_volume_proxy` | `text` | 'high' / 'medium' / 'low' (qualitative if no DFS data yet) |
| **— Metadata —** | | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
CREATE INDEX idx_cond_entity ON seo_entity_condition(entity_fp);
CREATE INDEX idx_cond_icd10 ON seo_entity_condition(icd10_code) WHERE icd10_code IS NOT NULL;
CREATE INDEX idx_cond_snomed ON seo_entity_condition(snomed_ct_id) WHERE snomed_ct_id IS NOT NULL;
CREATE INDEX idx_cond_category ON seo_entity_condition(condition_category);
CREATE INDEX idx_cond_body_system ON seo_entity_condition USING GIN(body_system);
CREATE INDEX idx_cond_treatment_procs ON seo_entity_condition USING GIN(treatment_procedures_fps);
CREATE INDEX idx_cond_treatment_drugs ON seo_entity_condition USING GIN(treatment_drugs_fps);

ALTER TABLE seo_entity_condition ADD CONSTRAINT check_gender CHECK (gender_predominance IS NULL OR gender_predominance IN ('male', 'female', 'equal', 'unknown'));
ALTER TABLE seo_entity_condition ADD CONSTRAINT check_chronicity CHECK (NOT (is_chronic AND is_acute));
```

#### Used By

- **T1-medical-condition template (PRIMARY BINDING)** — Bible §4.1.1
- Knowledge graph cross-refs (condition → anatomy → drug → procedure)
- Patient-facing content (Bible Part 23.4 — patient communication tier)
- Schema.org MedicalCondition emission (DR-019 schema strategy)

#### Migration Files

- `015_restore_entity_condition.sql` (DR-024)

---

### 11.6 `seo_entity_drug` *(entity_type='drug')* 🆕 v1.11

> **Purpose:** Extension for entities of type='drug' — Rx/OTC pharmaceuticals with RxNorm, ATC, Thai FDA registration. Used for post-procedure medications (VTH BioDent antibiotics), supplements at Rx level (Dr. Trin TRT), cosmeceuticals borderline (the brand).
> **Tier:** 2
> **Sync:** N↔S
> **Schema.org:** Drug
> **Bible Reference:** Part 5.11, Part 14.6 (Hospital), Appendix B.3 Table 15
> **Volume:** ~100-500 records
> **PDPA Note:** Drug entity pages cannot mention real patient cases (PDPA + medical advertising law)

> **DR Reference:** DR-024 Locked 2026-05-12 (Restore 9 Entity Extension Tables).

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `entity_fp` | `text FK→seo_entity_graph(fingerprint) UNIQUE NOT NULL` | 1:1 link |
| **— Drug Coding —** | | |
| `rxnorm_code` | `text` | RxNorm concept code |
| `atc_code` | `text` | WHO ATC (Anatomical Therapeutic Chemical) classification |
| `mesh_id` | `text` | MeSH ID |
| `wikidata_qid` | `text` | Wikidata Q-number |
| **— Drug Identity —** | | |
| `generic_name` | `text NOT NULL` | International nonproprietary name (INN) |
| `brand_names` | `text[]` | Common brand names in market |
| `chemical_name` | `text` | IUPAC or systematic name |
| `drug_class` | `text` | 'antibiotic' / 'NSAID' / 'corticosteroid' / 'statin' / etc. |
| `drug_subclass` | `text` | More specific class |
| **— Forms & Routes —** | | |
| `dosage_forms` | `text[]` | 'tablet' / 'capsule' / 'injection' / 'topical' / 'inhaler' / 'syrup' |
| `routes_of_administration` | `text[]` | 'oral' / 'IV' / 'IM' / 'topical' / 'sublingual' / 'inhalation' |
| `available_strengths` | `text[]` | '500mg', '1000mg/5ml', etc. |
| **— Regulatory —** | | |
| `thai_fda_reg_no` | `text` | เลขทะเบียนยา |
| `thai_fda_status` | `text` | 'approved' / 'restricted' / 'withdrawn' |
| `prescription_required` | `boolean DEFAULT true` | |
| `controlled_substance_class` | `text` | TH Narcotics Act classification (วัตถุออกฤทธิ์ ประเภท 1-4 / ยาเสพติด) |
| `requires_special_program` | `boolean DEFAULT false` | E.g., isotretinoin program |
| **— Clinical Use —** | | |
| `indications_fps` | `text[]` | FK array → `seo_entity_condition` (what it treats) |
| `indications_text` | `text[]` | Indications descriptions |
| `off_label_uses` | `text[]` | Documented off-label uses |
| `contraindications_fps` | `text[]` | FK array → `seo_entity_condition` (when NOT to use) |
| `contraindications_text` | `text[]` | Free-text contraindications |
| **— Safety —** | | |
| `side_effects_common` | `text[]` | |
| `side_effects_serious` | `text[]` | |
| `pregnancy_category` | `text` | FDA: 'A' / 'B' / 'C' / 'D' / 'X' (legacy) or modern Pregnancy and Lactation Labeling |
| `breastfeeding_category` | `text` | |
| `pediatric_use` | `text` | Approval status for pediatric |
| `pediatric_min_age_years` | `numeric(4,1)` | |
| `geriatric_considerations` | `text` | |
| **— Interactions —** | | |
| `drug_interactions_fps` | `text[]` | FK array → other `seo_entity_drug` entities (interacts with) |
| `food_interactions` | `text[]` | |
| **— Dosing —** | | |
| `typical_dosing_adult` | `text` | |
| `max_daily_dose` | `text` | |
| `duration_typical` | `text` | e.g., '7-10 days for acute infection' |
| **— Pharmacology —** | | |
| `mechanism_of_action` | `text` | |
| `half_life_hours` | `numeric(6,2)` | |
| `bioavailability_pct` | `numeric(5,2)` | |
| **— Metadata —** | | |
| `is_generic_available` | `boolean DEFAULT false` | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
CREATE INDEX idx_drug_entity ON seo_entity_drug(entity_fp);
CREATE INDEX idx_drug_rxnorm ON seo_entity_drug(rxnorm_code) WHERE rxnorm_code IS NOT NULL;
CREATE INDEX idx_drug_atc ON seo_entity_drug(atc_code) WHERE atc_code IS NOT NULL;
CREATE INDEX idx_drug_thai_fda ON seo_entity_drug(thai_fda_reg_no) WHERE thai_fda_reg_no IS NOT NULL;
CREATE INDEX idx_drug_class ON seo_entity_drug(drug_class);
CREATE INDEX idx_drug_indications ON seo_entity_drug USING GIN(indications_fps);
CREATE INDEX idx_drug_controlled ON seo_entity_drug(controlled_substance_class) WHERE controlled_substance_class IS NOT NULL;
```

#### Used By

- T-drug-monograph template
- Post-procedure care content (linked from procedure pages)
- T1-medical-condition treatment section (cross-refs treatment_drugs_fps)

#### Migration Files

- `016_restore_entity_drug.sql` (DR-024)

---

### 11.7 `seo_entity_anatomy` *(entity_type='anatomy')* 🆕 v1.11

> **Purpose:** Extension for entities of type='anatomy' — body anatomy entities (jaw, gum, tooth, TMJ, skin, hair follicle, etc.). Mostly a **supporting entity** for condition/procedure pages rather than standalone, but central to knowledge graph cross-refs. Self-FK hierarchy (TMJ ⊂ jaw ⊂ skull).
> **Tier:** 2
> **Sync:** N↔S
> **Schema.org:** AnatomicalStructure
> **Bible Reference:** Part 5.11, Part 14 (all medical verticals), Appendix B.3 Table 16
> **Volume:** ~100-500 records

> **DR Reference:** DR-024 Locked 2026-05-12 (Restore 9 Entity Extension Tables).

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `entity_fp` | `text FK→seo_entity_graph(fingerprint) UNIQUE NOT NULL` | 1:1 link |
| **— Coding —** | | |
| `fma_id` | `text` | Foundational Model of Anatomy ID |
| `uberon_id` | `text` | Uber-anatomy ontology ID (cross-species) |
| `terminologia_anatomica` | `text` | TA98 code |
| `mesh_id` | `text` | MeSH (anatomy branch) |
| `wikidata_qid` | `text` | |
| **— Identity —** | | |
| `anatomical_name_latin` | `text` | Latin canonical name |
| `anatomical_name_th` | `text` | Thai medical term |
| `common_name_th` | `text` | Layperson Thai term |
| **— Classification —** | | |
| `body_system` | `text` | 'cardiovascular' / 'respiratory' / 'digestive' / 'musculoskeletal' / 'oral' / 'integumentary' / 'nervous' / 'endocrine' / 'reproductive' / 'urinary' / 'lymphatic' / 'sensory' |
| `anatomical_region` | `text` | 'head_neck' / 'thorax' / 'abdomen' / 'upper_limb' / 'lower_limb' / 'spine' / 'pelvis' |
| `anatomy_type` | `text` | CHECK: 'organ' / 'tissue' / 'bone' / 'muscle' / 'vessel' / 'nerve' / 'gland' / 'cavity' / 'region' / 'structure' / 'cell' |
| **— Hierarchy (self-FK) —** | | |
| `parent_anatomy_fp` | `text FK→seo_entity_graph(fingerprint)` | Parent anatomy (e.g., TMJ → jaw) |
| `parent_anatomy_relation` | `text` | 'part_of' / 'attached_to' / 'innervated_by' / 'supplied_by' |
| `child_anatomy_fps` | `text[]` | Child anatomies (reverse, denormalized) |
| **— Functional Relationships —** | | |
| `connected_to_fps` | `text[]` | Anatomically connected structures |
| `innervated_by_fps` | `text[]` | Nerves supplying this anatomy |
| `vascularized_by_fps` | `text[]` | Blood vessels supplying this anatomy |
| **— Clinical Relevance —** | | |
| `affected_by_conditions_fps` | `text[]` | FK array → `seo_entity_condition` (conditions affecting this anatomy) |
| `target_of_procedures_fps` | `text[]` | FK array → `seo_entity_procedure` (procedures targeting this anatomy) |
| **— Visualization —** | | |
| `illustration_url` | `text` | Reference image URL |
| `3d_model_url` | `text` | Optional 3D model |
| **— Metadata —** | | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
CREATE INDEX idx_anat_entity ON seo_entity_anatomy(entity_fp);
CREATE INDEX idx_anat_parent ON seo_entity_anatomy(parent_anatomy_fp);
CREATE INDEX idx_anat_body_system ON seo_entity_anatomy(body_system);
CREATE INDEX idx_anat_fma ON seo_entity_anatomy(fma_id) WHERE fma_id IS NOT NULL;
CREATE INDEX idx_anat_uberon ON seo_entity_anatomy(uberon_id) WHERE uberon_id IS NOT NULL;
CREATE INDEX idx_anat_affected_by ON seo_entity_anatomy USING GIN(affected_by_conditions_fps);

ALTER TABLE seo_entity_anatomy ADD CONSTRAINT check_anatomy_type CHECK (anatomy_type IN ('organ', 'tissue', 'bone', 'muscle', 'vessel', 'nerve', 'gland', 'cavity', 'region', 'structure', 'cell'));
ALTER TABLE seo_entity_anatomy ADD CONSTRAINT check_no_self_parent CHECK (parent_anatomy_fp != entity_fp);
```

#### Used By

- T-anatomy-reference (rare standalone page)
- T1-medical-condition (cross-ref via related_anatomy_fps)
- T2-medical-procedure (cross-ref via affects_anatomy_fps)
- Knowledge graph foundation

#### Migration Files

- `017_restore_entity_anatomy.sql` (DR-024)

---

### 11.8 `seo_entity_organization` *(entity_type='organization')* 🆕 v1.11

> **Purpose:** Extension for entities of type='organization' — **external organizations** referenced in content (Thai FDA, ADA, Wikidata Q-entities, manufacturers, accreditation bodies, professional associations). **Distinct from `brands` table** which represents own brands.
> **Tier:** 2
> **Sync:** N↔S
> **Schema.org:** Organization / MedicalOrganization / Hospital / Corporation / NGO / GovernmentOrganization
> **Bible Reference:** Part 5.11, Part 23.3 (Authority Validation), Part 24 (External Citations), Appendix B.3 Table 17
> **Volume:** ~100-500 records
> **Scope clarification:** `brands` (own brands ~10-50) vs `seo_entity_organization` (external orgs ~100-500). Owned-brand companies may ALSO have an entity_organization row for KG cross-ref purposes.

> **DR Reference:** DR-024 Locked 2026-05-12 (Restore 9 Entity Extension Tables).

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `entity_fp` | `text FK→seo_entity_graph(fingerprint) UNIQUE NOT NULL` | 1:1 link |
| **— Identity —** | | |
| `legal_name` | `text NOT NULL` | Legal registered name |
| `common_name` | `text` | Display name |
| `aliases` | `text[]` | Alternative names |
| `wikidata_qid` | `text` | Wikidata Q-number (KG critical) |
| `ringgold_id` | `text` | Ringgold institutional ID (academic citation use) |
| `ror_id` | `text` | Research Organization Registry ID |
| **— Classification —** | | |
| `organization_type` | `text NOT NULL` | CHECK: 'clinic' / 'hospital' / 'professional_association' / 'regulator' / 'manufacturer' / 'accreditation_body' / 'university' / 'research_institute' / 'NGO' / 'government_agency' / 'media_publisher' / 'company' |
| `organization_subtype` | `text` | More specific classification |
| `industry_focus` | `text[]` | 'medical' / 'dental' / 'beauty' / 'wellness' / 'pharma' / 'medical_devices' |
| `is_for_profit` | `boolean` | |
| **— Geography —** | | |
| `headquarters_country_code` | `text` | ISO 3166-1 alpha-2 |
| `headquarters_city` | `text` | |
| `headquarters_address` | `text` | |
| `operates_in_countries` | `text[]` | ISO codes |
| **— Founding —** | | |
| `founding_date` | `date` | |
| `founders` | `text[]` | Notable founders |
| **— Hierarchy —** | | |
| `parent_organization_fp` | `text FK→seo_entity_graph(fingerprint)` | Parent org |
| `subsidiaries_fps` | `text[]` | Known subsidiaries |
| **— Authority Signals (Bible Part 23.3) —** | | |
| `authority_tier` | `text` | CHECK: 'tier_1_regulatory' / 'tier_2_professional_assoc' / 'tier_3_accreditation' / 'tier_4_university' / 'tier_5_industry' / 'tier_6_media' / 'tier_7_other' |
| `is_government_authority` | `boolean DEFAULT false` | |
| `is_who_recognized` | `boolean DEFAULT false` | WHO recognition |
| `accredits` | `text[]` | What this org accredits (if accreditation_body) |
| **— Web Presence —** | | |
| `official_website` | `text` | |
| `wikipedia_url_en` | `text` | |
| `wikipedia_url_th` | `text` | |
| `same_as_urls` | `text[]` | Schema.org sameAs (LinkedIn, Twitter, Facebook official) |
| **— Brand-Owned Companies —** | | |
| `is_own_brand_org` | `boolean DEFAULT false` | true if this org represents one of our brands (KG cross-ref) |
| `linked_brand_id` | `uuid FK→brands(id)` | If `is_own_brand_org = true`, link to brands row |
| **— Citation Use —** | | |
| `used_as_citation_source` | `boolean DEFAULT false` | Used in `seo_citations.source_org_fp` |
| `citation_count_in_corpus` | `integer DEFAULT 0` | Cached count for authority weighting |
| **— Metadata —** | | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
CREATE INDEX idx_org_entity ON seo_entity_organization(entity_fp);
CREATE INDEX idx_org_wikidata ON seo_entity_organization(wikidata_qid) WHERE wikidata_qid IS NOT NULL;
CREATE INDEX idx_org_type ON seo_entity_organization(organization_type);
CREATE INDEX idx_org_authority_tier ON seo_entity_organization(authority_tier);
CREATE INDEX idx_org_own_brand ON seo_entity_organization(linked_brand_id) WHERE is_own_brand_org = true;
CREATE INDEX idx_org_country ON seo_entity_organization(headquarters_country_code);

ALTER TABLE seo_entity_organization ADD CONSTRAINT check_org_type CHECK (organization_type IN ('clinic', 'hospital', 'professional_association', 'regulator', 'manufacturer', 'accreditation_body', 'university', 'research_institute', 'NGO', 'government_agency', 'media_publisher', 'company'));
ALTER TABLE seo_entity_organization ADD CONSTRAINT check_authority_tier CHECK (authority_tier IS NULL OR authority_tier IN ('tier_1_regulatory', 'tier_2_professional_assoc', 'tier_3_accreditation', 'tier_4_university', 'tier_5_industry', 'tier_6_media', 'tier_7_other'));
ALTER TABLE seo_entity_organization ADD CONSTRAINT check_own_brand_link CHECK (NOT is_own_brand_org OR linked_brand_id IS NOT NULL);
```

#### Used By

- `seo_citations.source_org_fp` — citation source attribution
- `seo_branches.organization_entity_id` — own-brand org cross-ref
- `seo_entity_product.brand_owner_org_fp` — product manufacturer
- `seo_entity_device.manufacturer_org_fp` — device manufacturer
- About pages, accreditation references
- Schema.org Organization emission with sameAs URLs

#### Migration Files

- `018_restore_entity_organization.sql` (DR-024)

---

### 11.9 `seo_entity_lab_test` *(entity_type='lab_test')* 🆕 v1.11

> **Purpose:** Extension for entities of type='lab_test' — lab tests, imaging studies, biopsies, diagnostic procedures with LOINC + CPT coding. Used by VTH BioDent (x-ray, CBCT, blood work pre-surgery), Dr. Trin (hormone panels), future hospital brands.
> **Tier:** 2
> **Sync:** N↔S
> **Schema.org:** MedicalTest (parent: MedicalIntangible)
> **Bible Reference:** Part 5.11, Part 14.6 (Hospital), Appendix B.3 Table 18
> **Volume:** ~100-500 records

> **DR Reference:** DR-024 Locked 2026-05-12 (Restore 9 Entity Extension Tables).

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `entity_fp` | `text FK→seo_entity_graph(fingerprint) UNIQUE NOT NULL` | 1:1 link |
| **— Coding —** | | |
| `loinc_code` | `text` | LOINC code (lab test identifier) |
| `cpt_code` | `text` | CPT code (procedure billing) |
| `snomed_ct_id` | `text` | |
| `mesh_id` | `text` | |
| `wikidata_qid` | `text` | |
| **— Identity —** | | |
| `test_name` | `text NOT NULL` | Display name |
| `test_aliases` | `text[]` | Alternative names |
| `test_acronym` | `text` | 'CBC', 'BMP', 'CBCT', 'MRI', 'CT', etc. |
| **— Classification —** | | |
| `test_category` | `text NOT NULL` | CHECK: 'blood' / 'urine' / 'imaging_radiology' / 'imaging_mri' / 'imaging_ct' / 'imaging_ultrasound' / 'imaging_dental' / 'biopsy' / 'pathology' / 'genetic' / 'microbiology' / 'cardiology_test' / 'pulmonary_test' / 'sleep_study' / 'allergy_test' / 'other' |
| `test_subcategory` | `text` | More specific |
| `test_type` | `text` | CHECK: 'diagnostic' / 'screening' / 'monitoring' / 'prognostic' |
| **— Sample / Procedure —** | | |
| `sample_type` | `text` | 'venous_blood' / 'capillary_blood' / 'urine_random' / 'urine_24h' / 'tissue_biopsy' / 'swab' / 'imaging_no_sample' / 'saliva' |
| `sample_volume` | `text` | e.g., '5ml blood' |
| `is_invasive` | `boolean DEFAULT false` | |
| `requires_fasting` | `boolean DEFAULT false` | |
| `fasting_hours_required` | `numeric(4,1)` | |
| `preparation_instructions` | `text` | Patient prep |
| **— Performance —** | | |
| `typical_duration_minutes` | `integer` | Procedure duration |
| `results_turnaround_hours` | `numeric(6,1)` | When results available |
| `requires_appointment` | `boolean DEFAULT true` | |
| **— Clinical Use —** | | |
| `indications` | `text[]` | When to order |
| `related_conditions_fps` | `text[]` | FK array → `seo_entity_condition` |
| `related_anatomy_fps` | `text[]` | FK array → `seo_entity_anatomy` |
| `screens_for_conditions_fps` | `text[]` | If screening test |
| **— Interpretation —** | | |
| `reference_ranges` | `jsonb` | `[{parameter, sex, age_min, age_max, range_low, range_high, unit, source}]` |
| `result_unit` | `text` | Primary unit of measurement |
| **— Equipment —** | | |
| `requires_devices_fps` | `text[]` | FK array → `seo_entity_device` (CBCT machine, MRI scanner) |
| **— Safety —** | | |
| `radiation_dose_msv` | `numeric(6,3)` | For radiology tests |
| `contraindications` | `text[]` | |
| `pregnancy_safety` | `text` | 'safe' / 'caution' / 'contraindicated' |
| **— Cost —** | | |
| `typical_cost_thb` | `numeric(10,2)` | Reference cost in Thailand |
| `insurance_typical_coverage` | `text` | 'covered' / 'partial' / 'not_covered' / 'varies' |
| **— Metadata —** | | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
CREATE INDEX idx_test_entity ON seo_entity_lab_test(entity_fp);
CREATE INDEX idx_test_loinc ON seo_entity_lab_test(loinc_code) WHERE loinc_code IS NOT NULL;
CREATE INDEX idx_test_cpt ON seo_entity_lab_test(cpt_code) WHERE cpt_code IS NOT NULL;
CREATE INDEX idx_test_category ON seo_entity_lab_test(test_category);
CREATE INDEX idx_test_conditions ON seo_entity_lab_test USING GIN(related_conditions_fps);

ALTER TABLE seo_entity_lab_test ADD CONSTRAINT check_test_category CHECK (test_category IN ('blood', 'urine', 'imaging_radiology', 'imaging_mri', 'imaging_ct', 'imaging_ultrasound', 'imaging_dental', 'biopsy', 'pathology', 'genetic', 'microbiology', 'cardiology_test', 'pulmonary_test', 'sleep_study', 'allergy_test', 'other'));
ALTER TABLE seo_entity_lab_test ADD CONSTRAINT check_test_type CHECK (test_type IS NULL OR test_type IN ('diagnostic', 'screening', 'monitoring', 'prognostic'));
```

#### Used By

- T-diagnostic-service template
- T-test-info template
- T1-medical-condition diagnosis section (cross-ref via diagnostic_tests_fps)

#### Migration Files

- `019_restore_entity_lab_test.sql` (DR-024)

---

### 11.10 `seo_programmatic_templates` *(template registry — not entity extension)*

> **Purpose:** Type C programmatic page templates (Bible Part 9). **Renumbered from §11.4 → §11.10 in v1.11** to keep all 9 entity extensions contiguous (§11.1-11.9) and template registry separately at end.
> **Tier:** 2
> **Sync:** N↔S
> **Bible Reference:** Part 9 (Programmatic Templates)
> **Volume:** ~10-50 templates

#### Schema (Key Columns)

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | |
| `fingerprint` | `text UNIQUE` | Format: `tmpl_{ULID16}` |
| `template_name` | `text NOT NULL` | |
| `template_id` | `text` | 'T1' / 'T2' / 'T6a' / etc. (Bible §4.1.X reference) |
| `target_layer` | `text` | L4 / L5 / L6 / L7 |
| `url_pattern` | `text NOT NULL` | e.g., '/services/{service-slug}/at-{branch-slug}' |
| `page_template_blueprint` | `jsonb` | Section structure (25 blocks per Bible Content_Templates v1.3) |
| `applicable_brands` | `text[]` | brand_scope[] pattern |
| `entity_type_required` | `text` | Which entity_type binds (e.g., 'condition' for T1) |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

---

## 12. Group 10 — Ads Landing Page Track 🆕 v1.12 (DR-026 Proposed)

> **Per DR-026 (Proposed 2026-05-12) + Bible Part 29** — parallel implementation track to SEO.
>
> **Phase 0 (this v1.12 release):** additive columns on `seo_website_page_master` + `seo_x_ads_keywords_contextual_master`. NO new tables ship in v1.12. The `seo_campaigns` table is hinted only (Phase 1, DR-027) — full DDL ships in Schema v1.13+ when DR-027 locks.
>
> **Companion Bible:** Part 29 (Ads Landing Page Track). **Companion Templates:** v1.4 (T-ADS-1 through T-ADS-5).

### 12.1 Phase 0 Column Additions — `seo_website_page_master` (extends §5.1)

5 new nullable columns added to the canonical page master table. All additive — zero downtime migration, no existing row breakage. Backfill optional (default to `page_purpose='seo_organic'` for pre-existing rows).

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| `page_purpose` | `text` | DEFAULT `'seo_organic'`, CHECK IN (`'seo_organic'`, `'ads_lp'`, `'dual_use'`) | Page role in the SEO/Ads track |
| `ads_template_id` | `text` | nullable, CHECK regex `^T-ADS-[1-5]$` OR matches future `T-DUAL-{N}` | Required when `page_purpose IN ('ads_lp', 'dual_use')` |
| `index_directive` | `text` | DEFAULT `'index'`, CHECK IN (`'index'`, `'noindex_lp'`, `'noindex_nofollow'`, `'dual'`) | Controls `<meta robots>` + sitemap.xml inclusion |
| `conversion_event_primary` | `text` | nullable, CHECK IN (`'lead_form'`, `'call_click'`, `'line_follow'`, `'booking'`, `'download'`, `'package_view'`, `'add_to_cart'`) | Required when `page_purpose IN ('ads_lp', 'dual_use')` |
| `conversion_event_secondary` | `text[]` | nullable, max 3 elements | Optional secondary events tracked but not primary KPI |
| `campaign_id` | `text` | nullable | **TRANSITIONAL STUB** — Phase 0 placeholder; becomes `campaign_fp text FK → seo_campaigns` in Schema v1.13+ when DR-027 locks |

**Constraint additions (migration `020_dr026_ads_lp_page_columns.sql`):**

```sql
ALTER TABLE seo_website_page_master
  ADD COLUMN page_purpose text NOT NULL DEFAULT 'seo_organic'
    CHECK (page_purpose IN ('seo_organic', 'ads_lp', 'dual_use')),
  ADD COLUMN ads_template_id text
    CHECK (ads_template_id IS NULL OR ads_template_id ~ '^T-ADS-[1-5]$' OR ads_template_id ~ '^T-DUAL-[0-9]+$'),
  ADD COLUMN index_directive text NOT NULL DEFAULT 'index'
    CHECK (index_directive IN ('index', 'noindex_lp', 'noindex_nofollow', 'dual')),
  ADD COLUMN conversion_event_primary text
    CHECK (conversion_event_primary IS NULL OR conversion_event_primary IN
      ('lead_form', 'call_click', 'line_follow', 'booking', 'download', 'package_view', 'add_to_cart')),
  ADD COLUMN conversion_event_secondary text[]
    CHECK (conversion_event_secondary IS NULL OR cardinality(conversion_event_secondary) <= 3),
  ADD COLUMN campaign_id text;

-- Conditional NOT NULL constraint enforced via trigger or app layer:
-- ads_template_id NOT NULL when page_purpose IN ('ads_lp', 'dual_use')
-- conversion_event_primary NOT NULL when page_purpose IN ('ads_lp', 'dual_use')
-- (CHECK constraints can't reference other columns in standard SQL — enforce in app/trigger layer)

CREATE INDEX idx_page_master_purpose ON seo_website_page_master(page_purpose) WHERE page_purpose != 'seo_organic';
CREATE INDEX idx_page_master_campaign ON seo_website_page_master(campaign_id) WHERE campaign_id IS NOT NULL;
```

**Index rationale:** Most rows are `seo_organic` (default) — partial index on non-default values yields tiny index with high query selectivity for Ads-track audits. `campaign_id` partial index supports operator dashboards filtering by campaign without scanning full table.

### 12.2 Phase 0 Column Additions — `seo_x_ads_keywords_contextual_master` (extends §6.1)

6 new columns on the canonical keyword master table.

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| `seo_active` | `boolean` | DEFAULT `true`, NOT NULL | Keyword is in SEO content strategy (default true — most KWs in EYWA are SEO-led) |
| `ad_active` | `boolean` | DEFAULT `false`, NOT NULL | Keyword is in active Ads bidding (opt-in per KW) |
| `ad_intent_score` | `smallint` | nullable, CHECK `BETWEEN 1 AND 10` | 1=informational, 10=transactional/buyer-ready (operator scores) |
| `ad_match_type_preferred` | `text` | nullable, CHECK IN (`'exact'`, `'phrase'`, `'broad'`, `'broad_modified'`) | Planning-time preference; actual platform match enforced at campaign level |
| `ad_landing_page_fp` | `text` | nullable, FK → `seo_website_page_master(fingerprint)` ON DELETE SET NULL | Primary LP for this KW (Phase 0; Phase 1 moves to `seo_campaign_keywords` M2M) |
| `ad_priority_tier` | `text` | DEFAULT `'none'`, CHECK IN (`'t1'`, `'t2'`, `'t3'`, `'none'`) | Budget priority: t1=always-on hero, t2=supporting, t3=exploratory, none=SEO-only |

**Constraint additions (migration `021_dr026_ads_lp_keyword_columns.sql`):**

```sql
ALTER TABLE seo_x_ads_keywords_contextual_master
  ADD COLUMN seo_active boolean NOT NULL DEFAULT true,
  ADD COLUMN ad_active boolean NOT NULL DEFAULT false,
  ADD COLUMN ad_intent_score smallint
    CHECK (ad_intent_score IS NULL OR ad_intent_score BETWEEN 1 AND 10),
  ADD COLUMN ad_match_type_preferred text
    CHECK (ad_match_type_preferred IS NULL OR ad_match_type_preferred IN
      ('exact', 'phrase', 'broad', 'broad_modified')),
  ADD COLUMN ad_landing_page_fp text
    REFERENCES seo_website_page_master(fingerprint) ON DELETE SET NULL,
  ADD COLUMN ad_priority_tier text NOT NULL DEFAULT 'none'
    CHECK (ad_priority_tier IN ('t1', 't2', 't3', 'none'));

-- Conditional NOT NULL enforced via trigger or app layer:
-- ad_intent_score NOT NULL when ad_active=true
-- ad_landing_page_fp NOT NULL when ad_active=true (operator workflow requirement)

CREATE INDEX idx_keyword_master_ad_active ON seo_x_ads_keywords_contextual_master(ad_active) WHERE ad_active = true;
CREATE INDEX idx_keyword_master_ad_priority ON seo_x_ads_keywords_contextual_master(ad_priority_tier) WHERE ad_priority_tier != 'none';
```

**Dual-flag pattern explained:** A keyword CAN have `seo_active=true` AND `ad_active=true` simultaneously — that's the canonical "shared use" case the operator vision predicted. `seo_active` defaults true (SEO-led portfolio); `ad_active` defaults false (Ads is opt-in per KW with explicit operator scoring).

### 12.3 Future: `seo_campaigns` Universal Master Table (HINT ONLY — Phase 1, DR-027)

> **THIS SECTION IS NON-NORMATIVE.** No DDL ships in Schema v1.12. The architecture sketch below documents Phase 1 direction so operators can adopt the Phase 0 `campaign_id` TEXT stub with migration-friendly naming. Full DDL ships in Schema v1.13+ when DR-027 locks.

**Architecture sketch (per DR-027):**

```sql
-- ⚠️ PHASE 1 — DOES NOT SHIP IN v1.12 — for reference only ⚠️

CREATE TABLE seo_campaigns (
  -- Identity
  campaign_fp text PRIMARY KEY,           -- hash of (brand_id, campaign_id, date_start)
  campaign_id text NOT NULL UNIQUE,       -- short slug, e.g., "vth-biodent-launch-2026-q2"
  campaign_name text NOT NULL,            -- human label
  notion_page_id text,                    -- Notion sync state

  -- Brand scope
  brand_id text NOT NULL REFERENCES brands(id),

  -- Entity focus (optional)
  entity_focus_fp text REFERENCES seo_entity_graph(fingerprint),

  -- Classification
  platforms text[] NOT NULL,              -- enum elements: google_ads, meta_ads, youtube_ads, line_ads, tiktok_ads, other
  objective text NOT NULL                 -- lead_gen | awareness | conversion | retargeting | reactivation | launch | promo
    CHECK (objective IN ('lead_gen', 'awareness', 'conversion', 'retargeting', 'reactivation', 'launch', 'promo')),
  audience_tier text                      -- cold | warm | hot | mixed
    CHECK (audience_tier IS NULL OR audience_tier IN ('cold', 'warm', 'hot', 'mixed')),

  -- Financial
  budget_total_thb numeric(12,2),
  budget_currency text NOT NULL DEFAULT 'THB',
  budget_per_platform jsonb,              -- {"google_ads": 50000, "meta_ads": 30000}
  budget_pacing text                      -- front_loaded | even | back_loaded | accelerated
    CHECK (budget_pacing IS NULL OR budget_pacing IN ('front_loaded', 'even', 'back_loaded', 'accelerated')),

  -- Schedule
  date_start date NOT NULL,
  date_end date,                          -- nullable for ongoing
  status text NOT NULL DEFAULT 'planning' -- planning | active | paused | completed | archived
    CHECK (status IN ('planning', 'active', 'paused', 'completed', 'archived')),

  -- Governance
  approved_by_fp text REFERENCES seo_authors_reviewers(fingerprint),
  approval_date date,
  notes text,

  -- Timestamps
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE seo_campaign_pages (        -- M2M junction
  campaign_fp text REFERENCES seo_campaigns ON DELETE CASCADE,
  page_fp text REFERENCES seo_website_page_master(fingerprint) ON DELETE CASCADE,
  role text NOT NULL                     -- primary_lp | secondary_lp | thank_you | followup | dual_use_seo_page
    CHECK (role IN ('primary_lp', 'secondary_lp', 'thank_you', 'followup', 'dual_use_seo_page')),
  active boolean NOT NULL DEFAULT true,
  added_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (campaign_fp, page_fp)
);

CREATE TABLE seo_campaign_keywords (     -- M2M junction
  campaign_fp text REFERENCES seo_campaigns ON DELETE CASCADE,
  keyword_fp text REFERENCES seo_x_ads_keywords_contextual_master(fingerprint) ON DELETE CASCADE,
  platform text NOT NULL                 -- google_ads | meta_ads | youtube_ads | line_ads | tiktok_ads | other
    CHECK (platform IN ('google_ads', 'meta_ads', 'youtube_ads', 'line_ads', 'tiktok_ads', 'other')),
  match_type text                        -- exact | phrase | broad | broad_modified | negative
    CHECK (match_type IS NULL OR match_type IN ('exact', 'phrase', 'broad', 'broad_modified', 'negative')),
  bid_strategy text                      -- manual_cpc | enhanced_cpc | maximize_clicks | maximize_conversions | target_cpa | target_roas
    CHECK (bid_strategy IS NULL OR bid_strategy IN
      ('manual_cpc', 'enhanced_cpc', 'maximize_clicks', 'maximize_conversions', 'target_cpa', 'target_roas')),
  bid_amount_thb numeric(10,2),
  budget_share_pct numeric(5,2),
  active boolean NOT NULL DEFAULT true,
  PRIMARY KEY (campaign_fp, keyword_fp, platform)
);

CREATE TABLE seo_campaign_performance_snapshot (
  campaign_fp text NOT NULL REFERENCES seo_campaigns ON DELETE CASCADE,
  platform text NOT NULL
    CHECK (platform IN ('google_ads', 'meta_ads', 'youtube_ads', 'line_ads', 'tiktok_ads', 'other')),
  snapshot_date date NOT NULL,

  -- Volume metrics
  impressions int NOT NULL DEFAULT 0,
  clicks int NOT NULL DEFAULT 0,

  -- Spend
  spend_thb numeric(10,2) NOT NULL DEFAULT 0,

  -- Outcome
  conversions int NOT NULL DEFAULT 0,
  conversion_value_thb numeric(12,2) NOT NULL DEFAULT 0,

  -- Derived metrics (GENERATED)
  ctr numeric(7,4) GENERATED ALWAYS AS (
    CASE WHEN impressions > 0 THEN clicks::numeric / impressions ELSE NULL END
  ) STORED,
  cpc numeric(8,2) GENERATED ALWAYS AS (
    CASE WHEN clicks > 0 THEN spend_thb / clicks ELSE NULL END
  ) STORED,
  cpm numeric(8,2) GENERATED ALWAYS AS (
    CASE WHEN impressions > 0 THEN spend_thb * 1000 / impressions ELSE NULL END
  ) STORED,
  conv_rate numeric(7,4) GENERATED ALWAYS AS (
    CASE WHEN clicks > 0 THEN conversions::numeric / clicks ELSE NULL END
  ) STORED,
  cpa_thb numeric(10,2) GENERATED ALWAYS AS (
    CASE WHEN conversions > 0 THEN spend_thb / conversions ELSE NULL END
  ) STORED,
  roas numeric(8,4) GENERATED ALWAYS AS (
    CASE WHEN spend_thb > 0 THEN conversion_value_thb / spend_thb ELSE NULL END
  ) STORED,

  -- Quality layer (platform-specific)
  quality_layer jsonb,                   -- e.g., {"quality_score": 8, "relevance_score": 7}

  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (campaign_fp, platform, snapshot_date)
);

-- ⚠️ END OF PHASE 1 REFERENCE — NOT SHIPPED IN v1.12 ⚠️
```

### 12.4 Phase 0 → Phase 1 Migration Path

When DR-027 ships and `seo_campaigns` is created (Schema v1.13+):

1. **Parse distinct campaign_id values** from `seo_website_page_master`:
   ```sql
   SELECT DISTINCT campaign_id FROM seo_website_page_master WHERE campaign_id IS NOT NULL;
   ```

2. **Create `seo_campaigns` rows** for each — operator fills in `campaign_name`, `platforms`, `objective`, `date_start`, etc.

3. **Populate `seo_campaign_pages` junction** from existing `page_master` rows:
   ```sql
   INSERT INTO seo_campaign_pages (campaign_fp, page_fp, role)
   SELECT
     (SELECT campaign_fp FROM seo_campaigns WHERE campaign_id = pm.campaign_id),
     pm.fingerprint,
     CASE pm.page_purpose
       WHEN 'ads_lp' THEN 'primary_lp'
       WHEN 'dual_use' THEN 'dual_use_seo_page'
     END
   FROM seo_website_page_master pm
   WHERE pm.campaign_id IS NOT NULL
     AND pm.page_purpose IN ('ads_lp', 'dual_use');
   ```

4. **Populate `seo_campaign_keywords` junction** from KW rows already flagged `ad_active=true` with `ad_landing_page_fp` set:
   ```sql
   INSERT INTO seo_campaign_keywords (campaign_fp, keyword_fp, platform, match_type)
   SELECT
     (SELECT cp.campaign_fp FROM seo_campaign_pages cp WHERE cp.page_fp = km.ad_landing_page_fp LIMIT 1),
     km.fingerprint,
     'google_ads',                          -- Phase 0 assumption: all Phase 0 ad work is Google Ads
     km.ad_match_type_preferred
   FROM seo_x_ads_keywords_contextual_master km
   WHERE km.ad_active = true AND km.ad_landing_page_fp IS NOT NULL;
   ```

5. **Replace `campaign_id text` with FK column** on `seo_website_page_master`:
   ```sql
   ALTER TABLE seo_website_page_master
     ADD COLUMN campaign_fp text REFERENCES seo_campaigns(campaign_fp) ON DELETE SET NULL;

   UPDATE seo_website_page_master pm
   SET campaign_fp = (SELECT c.campaign_fp FROM seo_campaigns c WHERE c.campaign_id = pm.campaign_id);

   ALTER TABLE seo_website_page_master DROP COLUMN campaign_id;
   ```

6. **Validation queries** post-migration:
   - Every page with `page_purpose='ads_lp'` should have at least one row in `seo_campaign_pages`
   - Every `ad_active=true` KW should have at least one row in `seo_campaign_keywords`

**Naming convention for Phase 0 `campaign_id` (CRITICAL for clean migration):**

```
{brand-id}-{purpose}-{date-suffix}

✅  vth-biodent-launch-2026-q2
✅  smilescape-blue-diamond-promo-2026-may
✅  trin-wellness-vital-core-evergreen
❌  test-1
❌  promo
❌  ads-2026
```

Brands MUST adopt this convention from day 1. Free-form labels make Phase 1 migration painful.

### 12.5 Cross-References

| Topic | See Also |
|-------|----------|
| Page Purpose taxonomy | Bible Part 29.2 |
| URL convention `/lp/{slug}/` | Bible Part 29.3 |
| Index directive enum | Bible Part 29.4 |
| Conversion event taxonomy | Bible Part 29.5 |
| Dual-use eligibility (6 gates) | Bible Part 29.6 |
| Keyword schema extensions detail | Bible Part 29.7 |
| Page schema extensions detail | Bible Part 29.8 |
| T-ADS template family | Content_Templates v1.4 §3.4 |
| YMYL evidence rules (unchanged) | Bible Part 23 + Part 29.10 |
| Future Campaign Master architecture | DR-027 + Bible Part 29.11 |
| Phase 0 → Phase 1 migration | This document §12.4 |

---

## Appendix A — Required PostgreSQL Extensions

### Installation Order

```sql
-- 1. Core (required for all tables)
CREATE EXTENSION IF NOT EXISTS pgcrypto;            -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";          -- uuid_generate_v4()

-- 2. Required for specific groups
CREATE EXTENSION IF NOT EXISTS pg_trgm;             -- Fuzzy text search + EUG v1.0 Layer 3b (v1.9 NEW)
CREATE EXTENSION IF NOT EXISTS vector;               -- pgvector for embeddings (Group 7) + EUG v2.0 (future)

-- 3. Recommended for Group 1 (Branches geo)
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS earthdistance CASCADE;

-- 4. Optional for automation
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pgmq;
CREATE EXTENSION IF NOT EXISTS pg_partman;

-- 5. Optional for monitoring & data quality
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_jsonschema;
CREATE EXTENSION IF NOT EXISTS hypopg;
```

### Extension-to-Table Map

| Extension | Required For | Tables |
|-----------|--------------|--------|
| `uuid-ossp` / `pgcrypto` | UUID PKs | All tables |
| `pg_trgm` | Fuzzy text search + Entity Uniqueness Guard (EUG v1.0 — Layer 3b) | seo_x_ads_keywords_contextual_master, seo_backlinks_links, **seo_entity_graph (v1.9+)** |
| `vector` (pgvector) | Vector similarity search + EUG v2.0 (future) | seo_entity_embeddings (REQUIRED) |
| `postgis` | Geo queries | seo_branches, seo_local_rankings (RECOMMENDED) |
| `pg_partman` | Yearly partition automation | Group 5 Performance Fact Tables (OPTIONAL) |
| `pg_cron` | Scheduled archival jobs | Group 5 archive workflow (OPTIONAL) |

---

## Appendix B — Fingerprint Patterns (v1.8)

> **Updated v1.8 (2026-05-08)** — Two-Column Identity Pattern (DR-008). See also: Bible Part 18.9.

### Two-Column Identity Convention

Every table (except `seo_x_ads_keywords_contextual_master`) has TWO identity columns:

```sql
fingerprint              text UNIQUE NOT NULL  -- IMMUTABLE machine ID
fingerprint_display_name text NOT NULL          -- MUTABLE human label
```

### Column 1: `fingerprint` (Machine ID)

**Format:** `{tablecode}_{ULID16}`

**Properties:**
- IMMUTABLE — enforced by `trg_prevent_fingerprint_change()` trigger
- Auto-generated on INSERT via `trg_set_fingerprint_*()` trigger
- Used for ALL relations (`parent_fp`, `related_fps[]`, FK references)
- ULID = 48-bit timestamp + 80-bit random, Crockford Base32 encoded
- 16 chars after prefix → ~19 chars total

**Examples:**
- `ent_01HZP5K2XQR7N3MF` — entity
- `page_01HZP5K3YR8M4PFQ` — page
- `clus_01HZP5K4ZS9L5QGR` — cluster
- `brnd_01HZP5K5AT0M6RHS` — brand 🆕 v1.9 (was natural PK in v1.8)
- `auth_01HZP5K6BU1N7SHT` — author
- `doc_01HZP5K7CV2O8TIU` — doctor
- `brch_01HZP5K8DW3P9UJV` — branch
- `cite_01HZP5K9EX4Q0VKW` — citation
- `pcit_01HZP5KAFY5R1WLX` — page citation
- `rel_01HZP5KBGZ6S2XMY` — relationship
- `tg_01HZP5KCH07T3YNZ` — translation group

### Column 2: `fingerprint_display_name` (Human Label)

**Format:** `{fp_last_6}::{type_or_category}::{slug_or_name}::{key_data}`

**Properties:**
- MUTABLE — auto-refreshed when source data changes
- First segment = last 6 chars of `fingerprint` (cross-check)
- Separator: `::` (double colon)
- Per-table composition (each table has its own formula)
- Used for: debug, admin UI, eyeball validation

### Per-Table Formulas

| Table | Display Formula | Example |
|-------|-----------------|---------|
| `brands` 🆕 v1.9 | `{fp_last_6}::{brand_slug}::{brand_name}` | `m4pfq::vth-biodent::VTH BioDent` |
| `seo_entity_graph` | `{fp_last_6}::{entity_type}::{entity_slug}::{icd_10_code}` | `n3mf::condition::sleep-apnea::g47.3` |
| `seo_topic_cluster_master` | `{fp_last_6}::{cluster_id}::{cluster_name}` | `5qgr::tmj-orofacial-pain::TMJ & Orofacial Pain` |
| `seo_authors` | `{fp_last_6}::{role}::{full_name}` | `7sht::reviewer::Dr. Pakaboon S.` |
| `seo_brand_doctors` | `{fp_last_6}::{brand_slug}::{author_name}::{branch}` | `... ::vth-biodent::Pakaboon::main` |
| `seo_brand_branches` | `{fp_last_6}::{brand_slug}::{branch_slug}` | `9ujv::vth-biodent::sukhumvit-49` |
| `seo_citations` | `{fp_last_6}::{citation_type}::{first_author}::{year}` | `vkw::journal::lin::2022` |
| `seo_page_citations` | `{fp_last_6}::{page_slug}::{citation_first_author}::{year}` | `wlx::tmj-treatment::lin::2022` |
| `seo_website_page_master` | `{fp_last_6}::{layer}::{slug}::{language}::{brand_slug}` | `mfqr::pillar::airway-optimization::th::vth-biodent` |
| `seo_editorial_reviews` | `{fp_last_6}::{stage}::{page_slug}::{language}` | `... ::medical::tmj-treatment::th` |
| `seo_entity_relationships` | `{fp_last_6}::{from_entity}::{edge_type}::{to_entity}` | `xmy::tmj-pain::symptom_of::tmj-disorder` |

### Trigger Pattern

```sql
-- 1. Set fingerprint on INSERT (immutable)
CREATE TRIGGER set_fp_before_insert ...

-- 2. Prevent fingerprint UPDATE (immutability)
CREATE TRIGGER prevent_fp_update ...

-- 3. Refresh display name on data changes
CREATE TRIGGER refresh_display_name ...
```

**Note:** Old `entity_fingerprint` column is preserved during transition for n8n compatibility. Will deprecate after workflow updates.

---

## Appendix C — Naming Conventions

### Table Naming

```yaml
prefix_seo_:
  All tables prefix with seo_ (except brands which is the central entity)
  
plural_for_collections:
  Tables represent collections → use plural noun
  Examples: brands, seo_branches, seo_authors_reviewers

structure_indicators:
  _master           = primary canonical table (e.g., seo_topic_cluster_master)
  _x_              = junction/cross-reference (e.g., seo_x_ads_keywords_x_url_daily_logs)
  _data / _links   = aggregate vs detail (e.g., seo_backlinks_data + seo_backlinks_links)
  _history         = time-series archive (deprecated — use Group 5 partition pattern)
  _metrics         = measurement records
  _changes         = audit/change log
```

### Column Naming

```yaml
identifiers:
  id                     = surrogate UUID PK
  fingerprint            = canonical machine ID (v1.8+)
  fingerprint_display_name = human label (v1.8+)
  *_fingerprint          = legacy natural unique ID (text)
  *_id                   = FK to other table (UUID typically)
  *_fp                   = abbreviated fingerprint reference (in arrays)
  notion_id              = Notion page ID for sync

timestamps:
  created_at             = record creation
  updated_at             = last record modification
  *_synced_at            = sync operation completion
  *_at                   = generic timestamp (lifecycle event)
  *_last_update          = last data update (less precise than _at)

booleans:
  is_*                   = state check (is_orphan, is_https, is_dofollow)
  has_*                  = possession check (has_medical_review, has_duplicate_title)
  *_required             = requirement flag

denormalized_fields:
  brand                  = legacy denormalized brand_name (use brand_slug going forward)
  brand_slug             = denormalized canonical brand identifier (v1.8+)
  *_name                 = denormalized display name
  
arrays:
  *s                     = plural for arrays (medical_specialty, accreditations)
  *_fps                  = arrays of fingerprints (related_entities_fps)
```

### JSON Field Conventions

```yaml
*_json:                  Always specifies JSON content (e.g., backlink_summary_json)
*_metadata:              Generic metadata dictionary
*_history:               Array of historical records
canonical_names:         Multilingual names per language (jsonb)
aliases:                 Multilingual alternative names (jsonb arrays per lang)
descriptions:            Multilingual descriptions (jsonb)
brand_display_names:     Brand-specific marketing names per language (jsonb nested)
```

---

## Appendix D — Cross-Reference Index to Bible

### By Bible Part

```yaml
Part 1 (Core Philosophy):
  - brands (multi-brand identity)
  - All tables (foundational)

Part 2 (Conceptual Architecture):
  - seo_entity_graph (knowledge graph core)
  - seo_topic_cluster_master (cluster architecture)

Part 2.6 (Entity Genesis Protocol):
  - seo_entity_graph (entity creation workflow)
  - seo_entity_relationships (edge wiring)

Part 2.6.6.1 (Entity Uniqueness Guard) 🆕 v1.9:
  - seo_entity_graph (EUG protection)
  - Schema Appendix G (full implementation)

Part 2.6.6.2 (EUG v2.0 Roadmap) 🆕 v1.9:
  - seo_entity_embeddings (Wave 2 leverage)
  - Schema Appendix G (v2 provisions)

Part 2.7 (Edge Vocabulary):
  - seo_entity_relationships (10-edge enforcement)

Part 2.7.5 (Edge Evolution Policy) 🆕 v1.9:
  - seo_entity_relationships (CHECK constraint enforcement)

Part 3 (Neural Authority Architecture):
  - seo_website_page_master (layer + tier + funnel)
  - seo_topic_cluster_master (pillar-cluster ratio)

Part 4 (Sitemap Architecture):
  - seo_website_page_master (sitemap_node_id)
  - seo_branches (Type B branch landing)
  - seo_programmatic_templates (Type C local programmatic)

Part 5 (Database Schema):
  - All tables (this document IS the companion)

Part 6 (Content Standard):
  - seo_citations (citation patterns A-F)
  - seo_page_citations (citation tracking)

Part 7 (Taxonomy SKOS):
  - seo_entity_graph (entity_lifecycle governance)
  - seo_topic_cluster_master (SKOS hierarchy)

Part 9 (Page Template Anatomy):
  - seo_programmatic_templates (template definitions)

Part 10 (Multi-Brand Strategy):
  - brands (brand_scope concept)
  - seo_doctor_assignments (cross-brand sharing)

Part 13 (LLMO Execution Playbook):
  - seo_brand_mentions (KPI #11)
  - seo_llm_citations (KPI #12)
  - seo_llm_query_simulations (automated probing)
  - brands.wikidata_id (Brand SERP)

Part 14 (Vertical Profiles):
  - brands.vertical_family + healthcare_format
  - seo_entity_ingredients (aesthetic/wellness)
  - seo_entity_devices (sleep/dental/aesthetic)
  - seo_entity_procedures (surgical/aesthetic)

Part 15 (Schema Change Governance):
  - seo_schema_changes (audit trail)

Part 17 (n8n Flow Library):
  - seo_x_ads_keywords_monthly_market_snapshot (DataForSEO ingestion)
  - seo_x_ads_keyword_serp_competitors (SERP analysis)
  - seo_x_ads_keywords_x_url_daily_logs (daily metrics)

Part 18.8 (Two-Phase Hierarchy Sync):
  - seo_entity_graph.parent_notion_id, sync_state
  - seo_topic_cluster_master.parent_notion_id, sync_state
  - seo_website_page_master.parent_notion_id, sync_state

Part 18.9 (Two-Column Identity Pattern):
  - All tables have fingerprint + fingerprint_display_name (v1.8+)
  - Schema Appendix B (full pattern)
  - Schema Appendix F (helper functions)

Part 19 (Data Quality Framework):
  - seo_data_quality_metrics
  - EUG v1.0 (algorithmic Dimension 5 Uniqueness enforcement) 🆕 v1.9

Part 20 (KPIs):
  - seo_x_ads_keywords_x_url_daily_logs (KPI sources)
  - seo_brand_mentions (KPI #11)
  - seo_llm_citations (KPI #12)

Part 21 (AI Operations):
  - seo_entity_embeddings (vector storage)
  - seo_brand_mentions, seo_llm_citations
  - seo_llm_query_simulations

Part 23.1 (Citation Tier System):
  - seo_citations.evidence_tier
  - seo_citations.schema_evidence_level

Part 23.3 (Authority Validation):
  - brands.accreditations
  - seo_authors.medical_license_*
  - seo_authors.is_advisory_board_member

Part 23.4 (Editorial Review):
  - seo_editorial_reviews (5-stage workflow)

Part 26 (Schema Generation Pipeline):
  - All concept tables (entity, brand, author, citation)
  - seo_entity_relationships (edge → JSON-LD)
  - seo_website_page_master.schema_markup_planned

Part 27 (EYWA Scoring Framework):
  - All scoring columns: brand_authority_score, entity_authority_score, etc.

Part 28 (Multilingual Strategy):
  - Tier 1 jsonb columns (canonical_names, aliases, descriptions)
  - Tier 2 translation_group_id pattern
```

---

## Appendix E — Multilingual Strategy (Two-Tier Pattern)

> **Added v1.8 (2026-05-08)** — DR-009. See also: Bible Part 28.

### Two-Tier Pattern

EYWA splits multilingual handling into 2 tiers based on data semantics:

```
┌─────────────────────────────────────────────────────────────┐
│  TIER 1: CONCEPT TABLES                                     │
│  Pattern: 1 row + jsonb translations                        │
│  Used when: same concept, multiple language labels          │
│                                                              │
│  Tables: ent, clus, brnd, auth, doc, brch, cite             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  TIER 2: CONTENT TABLES                                     │
│  Pattern: 1 row per language + translation_group_id         │
│  Used when: each language is unique content asset           │
│                                                              │
│  Tables: page, kw (existing), rev                           │
└─────────────────────────────────────────────────────────────┘
```

### Tier 1: Concept Tables (jsonb pattern)

**Schema columns added:**

```sql
canonical_names jsonb DEFAULT '{}'::jsonb
  -- Primary names per language
  -- Schema: {"en": "Sleep Apnea", "th": "ภาวะหยุดหายใจขณะหลับ", "ja": "睡眠時無呼吸"}

aliases jsonb DEFAULT '{}'::jsonb
  -- Alternative names per language
  -- Schema: {
  --   "en": ["sleep apnea syndrome", "OSA"],
  --   "th": ["หยุดหายใจตอนนอน", "นอนกรนแบบรุนแรง"]
  -- }

descriptions jsonb DEFAULT '{}'::jsonb
  -- Optional multilingual descriptions
  -- Schema: {"en": "...", "th": "..."}
```

**For brand-specific marketing variations (entity_graph only):**

```sql
brand_display_names jsonb DEFAULT '{}'::jsonb
  -- Schema: {
  --   "vth-biodent": {"th": "การรักษา TMJ", "en": "TMJ Programme"},
  --   "vitalsleep": {"th": "Sleep Solution"}
  -- }
```

**Query patterns:**

```sql
-- Find entity by Thai alias
SELECT * FROM seo_entity_graph
WHERE aliases @> '{"th": ["นอนกรน"]}';

-- Get name for current language
SELECT canonical_names->>'th' AS name_th
FROM seo_entity_graph
WHERE fingerprint = 'ent_01HZP5K2XQR7N3MF';

-- All entities with Japanese support
SELECT * FROM seo_entity_graph
WHERE canonical_names ? 'ja';
```

**Indexes:**

```sql
CREATE INDEX idx_ent_canonical_names ON seo_entity_graph USING gin(canonical_names);
CREATE INDEX idx_ent_aliases ON seo_entity_graph USING gin(aliases);
```

### Tier 2: Content Tables (translation_group_id pattern)

**Schema columns:**

```sql
translation_group_id text  -- "tg_01HZP5K2X..."
page_language text NOT NULL  -- 'th', 'en', 'ja', etc.
is_source_page boolean DEFAULT false  -- exactly 1 per group
source_translation_fp text  -- reference to source page's fingerprint
```

**Constraints:**

```sql
-- Exactly 1 source per group
CREATE UNIQUE INDEX idx_translation_group_source 
  ON seo_website_page_master(translation_group_id) 
  WHERE is_source_page = true;
```

**Query patterns:**

```sql
-- Get all translations of a page
SELECT * FROM seo_website_page_master
WHERE translation_group_id = 'tg_01HZP5K2X';

-- Get source page for hreflang
SELECT * FROM seo_website_page_master
WHERE translation_group_id = 'tg_01HZP5K2X' AND is_source_page = true;

-- Aggregate analytics across translations
SELECT translation_group_id, sum(views), sum(clicks)
FROM page_analytics
GROUP BY translation_group_id;
```

### Decision Matrix — Which Tier?

| Question | Answer | Tier |
|----------|--------|------|
| Same concept, different language labels? | Yes | Tier 1 (jsonb) |
| Each language has unique URL slug? | Yes | Tier 2 (translation_group) |
| Each language has different SEO metadata? | Yes | Tier 2 |
| Translation status varies per language? | Yes | Tier 2 |
| Wikidata Q-number applies to all langs? | Yes | Tier 1 |

### Lifecycle Examples

**Entity adds language:** UPDATE jsonb to add new key (no new row)

```sql
UPDATE seo_entity_graph
SET canonical_names = canonical_names || '{"ja": "睡眠時無呼吸"}'::jsonb
WHERE fingerprint = 'ent_01HZP5K2XQR7N3MF';
```

**Page adds language:** INSERT new row with same translation_group_id

```sql
INSERT INTO seo_website_page_master (
  fingerprint,                  -- new unique
  translation_group_id,          -- shared
  page_language,                 -- new lang
  is_source_page,                -- false
  source_translation_fp,          -- ref to source
  ...
) VALUES (
  generate_fingerprint('page'),
  'tg_01HZP5K2X',                -- same as source
  'ja',
  false,
  'page_01HZP5K3YR8M4PFQ',
  ...
);
```

---

## Appendix F — Helper Functions Reference

> **Added v1.8 (2026-05-08)** — Helper functions for Two-Column Identity Pattern.

### F.1 ULID Generator (Pure SQL)

```sql
-- Crockford Base32 alphabet (no I, L, O, U)
CREATE OR REPLACE FUNCTION generate_ulid()
RETURNS text AS $$
DECLARE
  alphabet text := '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  ulid text := '';
  ts_ms bigint;
  ts_part text := '';
  rand_part text := '';
  i int;
BEGIN
  -- Time component (48 bits = 10 chars in Base32)
  ts_ms := (extract(epoch from now()) * 1000)::bigint;
  FOR i IN 1..10 LOOP
    ts_part := substr(alphabet, (ts_ms % 32)::int + 1, 1) || ts_part;
    ts_ms := ts_ms / 32;
  END LOOP;
  
  -- Random component (80 bits = 16 chars in Base32)
  FOR i IN 1..16 LOOP
    rand_part := rand_part || substr(alphabet, (random() * 32)::int + 1, 1);
  END LOOP;
  
  ulid := ts_part || rand_part;
  RETURN ulid;
END;
$$ LANGUAGE plpgsql VOLATILE;
```

**Usage:**

```sql
SELECT generate_ulid();
-- Output: 01HZP5K2XQR7N3MFGHJKMNPQ
```

### F.2 Fingerprint Generator

```sql
CREATE OR REPLACE FUNCTION generate_fingerprint_v2(p_tablecode text)
RETURNS text AS $$
DECLARE
  ulid text;
BEGIN
  IF p_tablecode IS NULL OR length(p_tablecode) < 2 THEN
    RAISE EXCEPTION 'tablecode must be at least 2 characters';
  END IF;
  
  ulid := substr(generate_ulid(), 1, 16);  -- 16 chars
  RETURN p_tablecode || '_' || ulid;
END;
$$ LANGUAGE plpgsql VOLATILE;
```

**Usage:**

```sql
SELECT generate_fingerprint_v2('ent');
-- Output: ent_01HZP5K2XQR7N3MF
```

### F.3 Display Name Generators (per-table)

```sql
-- Brand (v1.9 NEW)
CREATE OR REPLACE FUNCTION generate_brand_display_name(
  p_fingerprint text,
  p_brand_slug text,
  p_brand_name text
) RETURNS text AS $$
BEGIN
  RETURN substr(p_fingerprint, length(p_fingerprint) - 5, 6) 
    || '::' || coalesce(p_brand_slug, 'unknown')
    || '::' || coalesce(p_brand_name, 'unnamed');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Entity
CREATE OR REPLACE FUNCTION generate_entity_display_name(
  p_fingerprint text,
  p_entity_type text,
  p_entity_slug text,
  p_icd_10_code text DEFAULT NULL
) RETURNS text AS $$
BEGIN
  RETURN substr(p_fingerprint, length(p_fingerprint) - 5, 6) 
    || '::' || coalesce(p_entity_type, 'concept')
    || '::' || coalesce(p_entity_slug, 'unknown')
    || '::' || coalesce(p_icd_10_code, '-');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- (similar patterns for page, cluster, author, doctor, branch, citation, etc.)
```

### F.4 Trigger Functions

```sql
-- Set fingerprint on INSERT
CREATE OR REPLACE FUNCTION trg_set_fingerprint_brand()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fingerprint IS NULL THEN
    NEW.fingerprint := generate_fingerprint_v2('brnd');
  END IF;
  IF NEW.fingerprint_display_name IS NULL THEN
    NEW.fingerprint_display_name := generate_brand_display_name(
      NEW.fingerprint, NEW.brand_slug, NEW.brand_name
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Prevent fingerprint change on UPDATE
CREATE OR REPLACE FUNCTION trg_prevent_fingerprint_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.fingerprint != NEW.fingerprint THEN
    RAISE EXCEPTION 'fingerprint is IMMUTABLE — cannot change from % to %', 
      OLD.fingerprint, NEW.fingerprint;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Refresh display name on data change
CREATE OR REPLACE FUNCTION trg_refresh_display_name_brand()
RETURNS TRIGGER AS $$
BEGIN
  NEW.fingerprint_display_name := generate_brand_display_name(
    NEW.fingerprint, NEW.brand_slug, NEW.brand_name
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- (similar trigger functions for entity, page, cluster, author, etc.)
```

### F.5 Two-Phase Sync Helpers

```sql
-- Resolve text-based parent reference to notion_id (Phase 2 backfill)
CREATE OR REPLACE FUNCTION resolve_parent_notion_id(
  p_table_name text,
  p_parent_text_ref text
) RETURNS text AS $$
DECLARE
  v_notion_id text;
  v_query text;
BEGIN
  v_query := format(
    'SELECT notion_id FROM %I WHERE entity_slug = $1 OR sitemap_node_id = $1 OR cluster_id = $1 LIMIT 1',
    p_table_name
  );
  EXECUTE v_query INTO v_notion_id USING p_parent_text_ref;
  RETURN v_notion_id;
END;
$$ LANGUAGE plpgsql STABLE;
```

---

## Appendix G — Entity Uniqueness Guard (EUG) Implementation (v1.9)

> **Added v1.9 (2026-05-08)** — Implementation specifications for Entity Uniqueness Guard.  
> **Bible Reference:** Section 2.6.6.1 (EUG v1.0) + Section 2.6.6.2 (EUG v2.0 Roadmap)  
> **Decision Record:** DR-011

### Purpose

Prevents duplicate entity creation in `seo_entity_graph` through 3 enforcement layers:

1. **Database UNIQUE constraint** — hard block at INSERT/UPDATE
2. **Slug normalization function** — auto-format consistency
3. **Application-level pre-flight checks** — alias collision + similarity warning

### G.1 Required Extensions

```sql
-- pg_trgm is REQUIRED for EUG v1.0 (Layer 3b similarity check)
-- Already in Required Extensions (Schema Appendix A)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- pgvector is OPTIONAL (only required for EUG v2.0 Wave 2)
-- Already in Required Extensions for Group 7 (AI Operations)
-- CREATE EXTENSION IF NOT EXISTS vector;  -- Phase 2
```

### G.2 SQL Helper Functions

#### `normalize_entity_slug(text)` — Layer 2

**Purpose:** Convert input text to canonical slug format

```sql
CREATE OR REPLACE FUNCTION normalize_entity_slug(input_text text)
RETURNS text AS $$
DECLARE
  result text;
BEGIN
  IF input_text IS NULL THEN 
    RETURN NULL; 
  END IF;
  
  -- Step 1: Lowercase
  result := lower(input_text);
  
  -- Step 2: Replace underscores and whitespace with hyphens
  result := regexp_replace(result, '[_\s]+', '-', 'g');
  
  -- Step 3: Strip special characters (keep alphanumeric + hyphen + Thai/CJK)
  result := regexp_replace(result, '[^a-z0-9\-\u0E00-\u0E7F\u4E00-\u9FFF\u3040-\u30FF]', '', 'g');
  
  -- Step 4: Collapse multiple hyphens
  result := regexp_replace(result, '\-+', '-', 'g');
  
  -- Step 5: Trim leading/trailing hyphens
  result := trim(both '-' from result);
  
  -- Validation
  IF length(result) = 0 THEN
    RAISE EXCEPTION 'Slug normalization resulted in empty string from input: %', input_text;
  END IF;
  
  IF length(result) > 100 THEN
    RAISE EXCEPTION 'Slug too long (max 100 chars): %', result;
  END IF;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

**Test cases:**

```sql
SELECT normalize_entity_slug('TMJ Therapy');         -- 'tmj-therapy'
SELECT normalize_entity_slug('tmj_therapy');          -- 'tmj-therapy'
SELECT normalize_entity_slug('  TMJ  Therapy  ');    -- 'tmj-therapy'
SELECT normalize_entity_slug('TMJ-Therapy!!!');      -- 'tmj-therapy'
SELECT normalize_entity_slug('sleep-apnea (G47.3)'); -- 'sleep-apnea-g473'
SELECT normalize_entity_slug('การรักษา-ขากรรไกร');  -- 'การรักษา-ขากรรไกร' (preserved)
```

#### `check_alias_collision(text, jsonb, text[])` — Layer 3a

**Purpose:** Detect synonym duplicates via canonical_names + aliases jsonb

```sql
CREATE OR REPLACE FUNCTION check_alias_collision(
  p_candidate_slug text,
  p_candidate_aliases jsonb DEFAULT '{}'::jsonb,
  p_brand_scope text[] DEFAULT ARRAY['*']
)
RETURNS TABLE (
  collision_type text,
  existing_fingerprint text,
  existing_slug text,
  matched_value text,
  matched_via text
) AS $$
BEGIN
  -- Check 1: Candidate slug matches existing canonical_names
  RETURN QUERY
  SELECT 
    'canonical_name_match'::text,
    e.fingerprint,
    e.entity_slug,
    name_value,
    'canonical_names.' || name_lang
  FROM seo_entity_graph e,
       jsonb_each_text(e.canonical_names) AS t(name_lang, name_value)
  WHERE (
    lower(name_value) = lower(p_candidate_slug)
    OR normalize_entity_slug(name_value) = normalize_entity_slug(p_candidate_slug)
  )
  AND (e.brand_scope && p_brand_scope OR '*' = ANY(e.brand_scope) OR '*' = ANY(p_brand_scope));
  
  -- Check 2: Candidate slug matches existing aliases
  RETURN QUERY
  SELECT 
    'alias_match'::text,
    e.fingerprint,
    e.entity_slug,
    alias_value,
    'aliases.' || alias_lang
  FROM seo_entity_graph e,
       jsonb_each(e.aliases) AS t(alias_lang, alias_array),
       jsonb_array_elements_text(alias_array) AS alias_value
  WHERE (
    lower(alias_value) = lower(p_candidate_slug)
    OR normalize_entity_slug(alias_value) = normalize_entity_slug(p_candidate_slug)
  )
  AND (e.brand_scope && p_brand_scope OR '*' = ANY(e.brand_scope) OR '*' = ANY(p_brand_scope));
  
  -- Check 3: Candidate aliases match existing entities
  RETURN QUERY
  SELECT 
    'reverse_alias_match'::text,
    e.fingerprint,
    e.entity_slug,
    candidate_alias_value,
    'candidate_aliases.' || candidate_lang
  FROM seo_entity_graph e,
       jsonb_each(p_candidate_aliases) AS t(candidate_lang, candidate_alias_array),
       jsonb_array_elements_text(candidate_alias_array) AS candidate_alias_value
  WHERE 
    (
      normalize_entity_slug(candidate_alias_value) = e.entity_slug
      OR EXISTS (
        SELECT 1 FROM jsonb_each_text(e.canonical_names) AS cn(lang, value)
        WHERE lower(value) = lower(candidate_alias_value)
      )
      OR EXISTS (
        SELECT 1 FROM jsonb_each(e.aliases) AS al(lang, arr),
                     jsonb_array_elements_text(arr) AS av
        WHERE lower(av) = lower(candidate_alias_value)
      )
    )
    AND (e.brand_scope && p_brand_scope OR '*' = ANY(e.brand_scope) OR '*' = ANY(p_brand_scope));
END;
$$ LANGUAGE plpgsql STABLE;
```

#### `find_similar_entities(text, real, text[], integer)` — Layer 3b

**Purpose:** Detect typos/plurals via trigram similarity

```sql
CREATE OR REPLACE FUNCTION find_similar_entities(
  p_candidate_slug text,
  p_threshold real DEFAULT 0.6,
  p_brand_scope text[] DEFAULT ARRAY['*'],
  p_limit integer DEFAULT 5
)
RETURNS TABLE (
  existing_fingerprint text,
  existing_slug text,
  existing_entity_type text,
  similarity_score real,
  recommendation text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.fingerprint,
    e.entity_slug,
    e.entity_type,
    similarity(e.entity_slug, p_candidate_slug) AS sim,
    CASE 
      WHEN similarity(e.entity_slug, p_candidate_slug) >= 0.90 
        THEN 'BLOCK_likely_typo'
      WHEN similarity(e.entity_slug, p_candidate_slug) >= 0.75 
        THEN 'WARN_high_similarity'
      WHEN similarity(e.entity_slug, p_candidate_slug) >= 0.60 
        THEN 'INFO_moderate_similarity'
      ELSE 'OK_distinct'
    END AS recommendation
  FROM seo_entity_graph e
  WHERE e.entity_slug % p_candidate_slug
    AND similarity(e.entity_slug, p_candidate_slug) >= p_threshold
    AND (e.brand_scope && p_brand_scope OR '*' = ANY(e.brand_scope) OR '*' = ANY(p_brand_scope))
  ORDER BY sim DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- Required GIN Index:
CREATE INDEX IF NOT EXISTS idx_entity_slug_trgm 
  ON seo_entity_graph USING gin(entity_slug gin_trgm_ops);
```

### G.3 Triggers

#### Layer 2 Trigger — Auto-normalize

```sql
CREATE OR REPLACE FUNCTION trg_normalize_entity_slug()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.entity_slug IS NOT NULL THEN
    NEW.entity_slug := normalize_entity_slug(NEW.entity_slug);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER normalize_slug_before_write
  BEFORE INSERT OR UPDATE OF entity_slug 
  ON seo_entity_graph
  FOR EACH ROW 
  EXECUTE FUNCTION trg_normalize_entity_slug();
```

#### Layer 1 — UNIQUE Constraint

```sql
ALTER TABLE seo_entity_graph
  ADD COLUMN IF NOT EXISTS brand_scope_primary text 
  GENERATED ALWAYS AS (
    CASE 
      WHEN brand_scope IS NULL THEN '*'
      WHEN '*' = ANY(brand_scope) THEN '*'
      WHEN array_length(brand_scope, 1) >= 1 THEN brand_scope[1]
      ELSE '*'
    END
  ) STORED;

ALTER TABLE seo_entity_graph
  ADD CONSTRAINT entity_slug_brand_unique 
  UNIQUE (entity_slug, brand_scope_primary);

CREATE INDEX IF NOT EXISTS idx_entity_slug_brand_scope 
  ON seo_entity_graph(entity_slug, brand_scope_primary);
```

### G.4 Required Indexes

```sql
CREATE INDEX IF NOT EXISTS idx_entity_canonical_names_gin 
  ON seo_entity_graph USING gin(canonical_names jsonb_path_ops);

CREATE INDEX IF NOT EXISTS idx_entity_aliases_gin 
  ON seo_entity_graph USING gin(aliases jsonb_path_ops);

CREATE INDEX IF NOT EXISTS idx_entity_slug_trgm 
  ON seo_entity_graph USING gin(entity_slug gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_entity_slug_brand_scope 
  ON seo_entity_graph(entity_slug, brand_scope_primary);
```

### G.5 Combined Pre-Flight Check

```sql
CREATE OR REPLACE FUNCTION eug_preflight_check(
  p_candidate_slug text,
  p_candidate_aliases jsonb DEFAULT '{}'::jsonb,
  p_brand_scope text[] DEFAULT ARRAY['*']
)
RETURNS TABLE (
  decision text,
  layer text,
  details jsonb
) AS $$
DECLARE
  v_normalized_slug text;
  v_collision_count integer;
  v_similar_count integer;
BEGIN
  -- Layer 2: Normalize first
  v_normalized_slug := normalize_entity_slug(p_candidate_slug);
  
  IF v_normalized_slug != p_candidate_slug THEN
    RETURN QUERY SELECT 
      'INFO'::text,
      'L2_normalize'::text,
      jsonb_build_object(
        'original', p_candidate_slug,
        'normalized', v_normalized_slug
      );
  END IF;
  
  -- Layer 3a: Alias collision
  SELECT count(*) INTO v_collision_count
  FROM check_alias_collision(v_normalized_slug, p_candidate_aliases, p_brand_scope);
  
  IF v_collision_count > 0 THEN
    RETURN QUERY 
    SELECT 
      'BLOCK'::text,
      'L3a_alias'::text,
      jsonb_build_object(
        'collisions', (
          SELECT jsonb_agg(row_to_json(c)::jsonb)
          FROM check_alias_collision(v_normalized_slug, p_candidate_aliases, p_brand_scope) c
        )
      );
    RETURN;
  END IF;
  
  -- Layer 3b: Similarity check
  SELECT count(*) INTO v_similar_count
  FROM find_similar_entities(v_normalized_slug, 0.6, p_brand_scope, 5)
  WHERE recommendation IN ('BLOCK_likely_typo', 'WARN_high_similarity');
  
  IF v_similar_count > 0 THEN
    RETURN QUERY 
    SELECT 
      CASE 
        WHEN EXISTS (
          SELECT 1 FROM find_similar_entities(v_normalized_slug, 0.6, p_brand_scope, 5)
          WHERE recommendation = 'BLOCK_likely_typo'
        ) THEN 'BLOCK'::text
        ELSE 'WARN'::text
      END,
      'L3b_similarity'::text,
      jsonb_build_object(
        'similar_entities', (
          SELECT jsonb_agg(row_to_json(s)::jsonb)
          FROM find_similar_entities(v_normalized_slug, 0.6, p_brand_scope, 5) s
        )
      );
    RETURN;
  END IF;
  
  -- All checks passed
  RETURN QUERY SELECT 
    'CLEAN'::text,
    'all_layers'::text,
    jsonb_build_object('normalized_slug', v_normalized_slug);
END;
$$ LANGUAGE plpgsql STABLE;
```

**Usage example:**

```sql
SELECT * FROM eug_preflight_check(
  'temporomandibular-joint-therapy',
  '{"en": ["TMJ therapy"]}'::jsonb,
  ARRAY['vth-biodent']
);
```

### G.6 Performance Benchmarks

```yaml
expected_performance_at_scale:
  
  baseline_500_entities:
    layer_1_unique_constraint: "< 1ms"
    layer_2_normalize: "< 1ms"
    layer_3a_alias_check: "5-15ms"
    layer_3b_similarity: "5-10ms"
    total_preflight: "10-30ms"
  
  scale_5000_entities:
    layer_1_unique_constraint: "< 5ms"
    layer_2_normalize: "< 1ms"
    layer_3a_alias_check: "30-80ms"
    layer_3b_similarity: "10-30ms"
    total_preflight: "40-120ms"
```

### G.7 Phase 1A Deployment Plan

```yaml
phase_1a_eug_deployment_steps:
  
  step_1_extension:
    sql: "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    duration: "< 1 minute"
  
  step_2_helper_functions:
    deploy:
      - "normalize_entity_slug(text)"
      - "check_alias_collision(text, jsonb, text[])"
      - "find_similar_entities(text, real, text[], integer)"
      - "eug_preflight_check(text, jsonb, text[])"
    duration: "5-10 minutes"
  
  step_3_indexes:
    deploy:
      - "idx_entity_slug_trgm (gin_trgm_ops)"
      - "idx_entity_canonical_names_gin"
      - "idx_entity_aliases_gin"
      - "idx_entity_slug_brand_scope"
    duration: "2-5 minutes"
  
  step_4_constraints:
    deploy:
      - "brand_scope_primary computed column"
      - "UNIQUE (entity_slug, brand_scope_primary)"
    duration: "5-10 minutes"
    rollback: "ALTER TABLE DROP CONSTRAINT entity_slug_brand_unique;"
  
  step_5_triggers:
    deploy:
      - "trg_normalize_entity_slug BEFORE INSERT/UPDATE OF entity_slug"
    duration: "< 1 minute"
  
  step_6_optional_backfill:
    sql: |
      UPDATE seo_entity_graph
      SET entity_slug = normalize_entity_slug(entity_slug)
      WHERE entity_slug != normalize_entity_slug(entity_slug);
    note: "Optional — only if existing slugs don't match canonical format"
  
  step_7_workflow_integration:
    update: "n8n entity creation flow to call eug_preflight_check() before INSERT"
    duration: "1-2 hours dev time"

total_migration_time: "1-2 hours including testing"
breaking_changes: "None — all additive"
```

### G.8 EUG v2.0 Schema Provisions (Future)

```yaml
v2_schema_additions_when_activated:
  
  uses_existing_table:
    table: "seo_entity_embeddings (Schema Group 7)"
    role: "Stores entity embedding vectors"
    new_source_type: "'entity' (already supported)"
  
  new_function_v2:
    name: "eug_preflight_check_v2"
    additional_parameters:
      - p_use_vector_similarity boolean DEFAULT true
      - p_vector_threshold real DEFAULT 0.85
    
    additional_layer_l4:
      step_1: "Embed candidate description via OpenAI API (n8n flow)"
      step_2: "Vector cosine similarity search in seo_entity_embeddings"
      step_3: "Threshold-based BLOCK/WARN/INFO/CLEAN classification"
  
  no_schema_changes_needed: |
    Wave 2 leverages existing pgvector + seo_entity_embeddings infrastructure.
    Only new function added; existing schema unchanged.
  
  activation_dr: "DR-011 amendment (when ready)"
```

### G.9 Cross-References

| Topic | See |
|-------|-----|
| EUG v1.0 architecture | Bible Section 2.6.6.1 |
| EUG v2.0 roadmap | Bible Section 2.6.6.2 |
| Two-Column Identity Pattern | Bible Section 18.9 |
| Multilingual aliases jsonb | Bible Section 28.3 |
| pg_trgm extension | Schema Appendix A |
| Helper Functions Reference | Schema Appendix F |
| Decision rationale | DECISION_RECORDS DR-011 |
| Phase 1A migration plan | EYWA_HANDOVER §6 |

---

**END OF DOCUMENT — Schema_Overview EYWA v1.12**

*🌿 EYWA™ PROTOCOL Database Architecture • May 2026*  
*Companion to คัมภีร์ EYWA™ PROTOCOL v3.16*  
*EYWA™ is a registered service mark — Class 35+42, DIP Thailand (filed 2026-04-20)*  
*Source of Truth: Bible Part 5 (Architecture) + Bible Part 29 (Ads Track) + this document (Reference)*
