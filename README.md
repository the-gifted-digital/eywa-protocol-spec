# EYWA™ Protocol — Specification

> **Universal Knowledge Graph SEO Specification for Healthcare & Wellness Brands**

| 📖 Bible | 📊 Schema | 🏗️ Phase | ⚖️ License |
|----------|-----------|-----------|-------------|
| **v3.13** | **v1.9** | **1 — Foundation** | Proprietary |

<!-- Badges (render on GitHub.com): -->
[![Bible](https://img.shields.io/badge/Bible-v3.13-blue?style=flat-square)](./EYWA_PROTOCOL_v3_13.md)
[![Schema](https://img.shields.io/badge/Schema-v1.9-green?style=flat-square)](./Schema_Overview_EYWA_v1_9.md)
[![Phase](https://img.shields.io/badge/Phase-1%20Foundation-orange?style=flat-square)](./PHASE_1_DECISIONS.md)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=flat-square)]()

---

## 📖 What is EYWA?

EYWA™ Protocol is a comprehensive specification for building structured, multilingual, AI-citable healthcare websites at scale. It combines:

- **Knowledge Graph SEO** — entities, edges, clusters, evidence-based content
- **Multi-Brand Federation** — manage 5-20 brands with shared backend, independent frontends
- **AI Citation Optimization** — designed for Google AI Overviews, ChatGPT, Claude, Perplexity
- **Healthcare-Grade Standards** — WCAG AA accessibility, evidence-tier citations, E-E-A-T compliant
- **Multilingual Support** — 8 languages designed (Thai default, English, Chinese, Japanese, Korean, Arabic, French, Spanish)
- **Ontology Drift Prevention** — Entity Uniqueness Guard (EUG) algorithmically enforces vocabulary discipline at scale

EYWA™ is a registered trademark of **The Gifted Digital Marketing Co., Ltd.** (Thailand)

---

## 📚 Documents in This Repo

| Document | Purpose | Lines | Status |
|----------|---------|-------|--------|
| `PROJECT_MEMORY.md` | Project context for AI sessions + onboarding | ~880 | 🧠 Memory |
| `EYWA_PROTOCOL_v3_13.md` | The Bible — full specification | ~25,460 | 🔒 Active |
| `Schema_Overview_EYWA_v1_9.md` | Database schema companion | ~3,985 | 🔒 Active |
| `EYWA_HANDOVER.md` | Operating manual for Claude/AI | ~1,780 | 🔒 Active (v1.5) |
| `DECISION_RECORDS.md` | Architecture decision log | ~1,525 | 🔒 Active (v1.3) |
| `PHASE_1_DECISIONS.md` | Phase 1 quick reference | ~310 | 🔒 Active |
| `EYWA_PROTOCOL_v3_12.md` | Bible (previous version) | ~24,800 | 📦 Archived |
| `Schema_Overview_EYWA_v1_8.md` | Schema (previous version) | ~3,400 | 📦 Archived |
| `EYWA_PROTOCOL_v3_11.md` | Bible (older version) | ~24,260 | 📦 Archived |
| `Schema_Overview_EYWA_v1_7.md` | Schema (older version) | ~2,750 | 📦 Archived |

---

## 🌱 Governance Update — DR-013 + DR-014 Proposed (2026-05-09)

**Field-tested feedback from VTH BioDent EGP work** — first test of DR-012 (Edge Vocabulary Evolution Policy) governance.

- 🌱 **DR-013 (Proposed):** Edge Vocabulary v3.5 Expansion (causes/caused_by + contraindicates) — review until 2026-05-20
- 🌱 **DR-014 (Proposed):** Concept Entity Subtype Lock (framework + axis) — review until 2026-05-20

**Critical path:** Cross-brand verification by 2026-05-13 → Schema Review Board 2026-05-15 → Lock or Reject decision 2026-05-20

**If LOCKED:** Bible v3.14 + Schema v1.10 + 5 SQL migrations (Phase 1E)  
**If REJECTED:** Workaround pattern (related_to + notes with brand_scope)

> **Note:** Bible v3.13 + Schema v1.9 remain canonical. Stream B (DR-013/014) targets future v3.14/v1.10 only after governance review.


---

## 🆕 Latest Update — v3.13 (2026-05-08)

**Entity Uniqueness Guard + Edge Evolution Policy + brands Two-Column Compliance**

Operational governance enhancements based on expert review feedback. Adds **enforced uniqueness** to entity creation and **formal evolution policy** for edge vocabulary — preventing ontology drift at scale.

- ✅ **DR-011** — Entity Uniqueness Guard (EUG) Two-Wave approach
- ✅ **DR-012** — Edge Vocabulary Evolution Policy
- 🔧 **Bible header fix** — corrected from v3.11 → v3.13
- 🔧 **brands table** — now follows Two-Column Identity Pattern (per DR-008)
- 🔧 **entity_fingerprint** — explicitly marked as legacy (use `fingerprint` going forward)

**Entity Uniqueness Guard (EUG) — 3-Layer Architecture:**

```yaml
eug_v1_0_layers:
  layer_1_database_constraint:
    type: "PostgreSQL UNIQUE"
    target: "(entity_slug, brand_scope_primary)"
    enforcement: "Hard block at INSERT/UPDATE"
  
  layer_2_canonical_normalization:
    function: "normalize_entity_slug(text)"
    catches: "Case variations, underscores, whitespace, special chars"
  
  layer_3a_alias_collision:
    function: "check_alias_collision(text, jsonb, text[])"
    catches: "Synonym duplicates via aliases jsonb"
  
  layer_3b_trigram_similarity:
    function: "find_similar_entities(text, real, text[], integer)"
    catches: "Typos, plurals, near-matches"
    technology: "pg_trgm (already required)"

coverage_wave_1: "~85% of duplicate scenarios"
cost_wave_1: "$0 (no new dependencies)"
deployment: "Phase 1A (additive, non-breaking)"

eug_v2_0_roadmap:
  layer_4_vector_similarity:
    technology: "pgvector + OpenAI embeddings"
    catches: "Deep semantic synonyms + cross-language"
    coverage: "Extends to ~99%"
  activation: "Phase 2 (when seo_entity_embeddings live)"
  cost: "~$0.015/month at typical scale"
```

**Edge Vocabulary Evolution Policy:**

```yaml
edges_locked: 10 (no changes from v3.12)
parking_lot: 4 future edges (measures, predicts_risk_of, contraindicated_with, prerequisite_for)
addition_criteria: 4 (real cases ≥3, cross-brand, schema.org, orthogonal)
review_period: 2 weeks per addition
```

**Headline Two-Column Identity (now applied to brands):**

```yaml
brands_table_v1_9:
  fingerprint: 
    type: "text UNIQUE NOT NULL"
    format: "brnd_{ULID16}"
    example: "brnd_01HZP5K3YR8M4PFQ"
  fingerprint_display_name:
    format: "{fp_last_6}::{brand_slug}::{brand_name}"
    example: "m4pfq::vth-biodent::VTH BioDent"
  brand_slug:
    type: "text UNIQUE NOT NULL"
    example: "vth-biodent"
  brand_name:
    description: "Display name only (mutable, supports rebranding)"
```

See `DECISION_RECORDS.md` (DR-011 + DR-012) and Bible Sections 2.6.6.1, 2.6.6.2, 2.7.5 for full rationale.

---

## 🔑 Headline Patterns (v3.12 — Still Active)

```yaml
fingerprint_columns:
  fingerprint: 
    type: "text UNIQUE NOT NULL"
    format: "{tablecode}_{ULID16}"
    example: "ent_01HZP5K2XQR7N3MF"
    mutability: IMMUTABLE
  
  fingerprint_display_name:
    type: "text NOT NULL"
    format: "{fp_last_6}::{type}::{slug}::{key_data}"
    example: "n3mf::condition::sleep-apnea::g47.3"
    mutability: MUTABLE (auto-refreshed)

multilingual:
  tier_1_concept_tables: "1 row + jsonb translations"
  tier_2_content_tables: "1 row per language + translation_group_id"
```

See `PHASE_1_DECISIONS.md` for full Phase 1 summary.

---

## 🎯 Quick Start

### For New Team Members

1. Read **Bible Part 1** (philosophy + first principles)
2. Read **Bible Part 2.6** (Entity Genesis Protocol)
3. Read `EYWA_HANDOVER.md` (operating manual)
4. Read `PHASE_1_DECISIONS.md` (current phase status)

### For Developers

1. Read **Bible Part 1** (philosophy)
2. Read **Bible Part 16** (4-tool architecture overview)
3. Read **Bible Part 11** (implementation roadmap)
4. Read **Bible Section 18.9** (Two-Column Identity Pattern) — for any database work
5. Read **Bible Section 2.6.6.1** (Entity Uniqueness Guard) — before entity creation flows 🆕 v3.13
6. Read **Schema v1.9 Appendix F** (Helper Functions) — for SQL development
7. Read **Schema v1.9 Appendix G** (EUG Implementation) — for entity governance 🆕 v1.9

### For Designers

1. Read **Bible Part 9** (template anatomy + WCAG AA)
2. Read **Bible Section 25.11** (Elementor Pro integration)
3. Read **Bible Section 28.10** (Elementor + WPML pattern)

### For Editorial Team

1. Read **Bible Part 6** (content standards)
2. Read **Bible Part 23** (medical content excellence)
3. Read **Bible Part 18** (Notion DB usage)

### For Operators

1. Read **Bible Section 10.7** (federation pattern)
2. Read **Bible Part 20** (KPIs)
3. Read **Bible Part 27** (scoring framework)
4. Read `PHASE_1_DECISIONS.md` for current phase status

---

## 🏗️ Active Phase: Phase 1 — Supabase Database Foundation

**Status:** 🟡 Documentation locked, migrations pending

**Scope:**
- ✅ Schema upgrade (Bible v3.13 / Schema v1.9)
- ✅ Two-Column Identity Pattern adoption (now includes brands table)
- ✅ Two-Tier Multilingual Strategy
- ✅ brand_slug standardization
- ✅ Entity Uniqueness Guard (EUG) v1.0 design 🆕 v3.13
- ✅ Edge Vocabulary Evolution Policy 🆕 v3.13
- ⏳ Migration files (27 SQL files planned across Phases 1A-1D)
- ⏳ Helper functions (`generate_ulid()`, fingerprint generators, triggers, EUG functions)

**Migration Plan (27 files):** 🔄 v3.13/v1.9

- Phase 1A: Foundation (6 migrations) — non-breaking column additions + helpers + **EUG** 🆕
- Phase 1B: New Tables (~14 migrations) — create v1.9 tables (incl. brands Two-Column compliance)
- Phase 1C: Triggers & Constraints (4 migrations)
- Phase 1D: Indexes & Performance (3 migrations)

**Phase 1A Migration Files:**

```yaml
001_create_ulid_function.sql              # ULID generator
002_create_fingerprint_helpers.sql        # Per-table fingerprint + display generators
003_alter_existing_tables_two_column.sql  # Add fingerprint columns to existing tables
004_alter_existing_tables_multilingual.sql  # Add jsonb columns for Tier 1 multilingual
005_alter_existing_tables_brand_scope.sql  # Standardize brand_scope across tables
006_create_entity_uniqueness_guard.sql    # EUG v1.0 (4 functions + indexes + trigger) 🆕 v3.13
```

See `EYWA_HANDOVER.md` Section 6 + `PHASE_1_DECISIONS.md` for details.

**Out of Scope (Phase 1):**
- Data migration (existing entity/page data may be discarded)
- n8n workflow rewrites (deferred)
- Notion database restructure (separate effort)
- EUG v2.0 (Wave 2 — vector similarity) — Phase 2 roadmap

---

## 📋 Decision Records Status

| DR | Title | Status |
|----|-------|--------|
| DR-001 | Multi-Brand Federation Pattern | 🔒 Locked |
| DR-002 | Elementor Pro + Hello Theme Stack | 🔒 Locked |
| DR-003 | Single Entity, Multilingual Labels | 🔒 Locked |
| DR-004 | URL Structure: Subdirectory + Thai Default | 🔒 Locked |
| DR-005 | GitHub Distribution Strategy | 🔒 Locked |
| DR-006 | Two-Phase Hierarchy Sync Pattern | 🔒 Locked |
| **DR-007** | **In-Place GTGT Schema Upgrade** | 🔒 **Locked** |
| **DR-008** | **Two-Column Identity Pattern** | 🔒 **Locked** |
| **DR-009** | **Multilingual Strategy v2 (Two-Tier)** | 🔒 **Locked** |
| **DR-010** | **Brand Scope Architecture** | 🔒 **Locked** |
| **DR-011** | **Entity Uniqueness Guard (Two-Wave)** | 🔒 **Locked (NEW v3.13)** |
| **DR-012** | **Edge Vocabulary Evolution Policy** | 🔒 **Locked (NEW v3.13)** |
| **DR-013** | **Edge Vocabulary v3.5 Expansion (causes + contraindicates)** | 🌱 **Proposed (NEW v1.3 — review until 2026-05-20)** |
| **DR-014** | **Concept Entity Subtype Lock (framework + axis)** | 🌱 **Proposed (NEW v1.3 — review until 2026-05-20)** |
| DR-015..026 | Various (WordPress hosting, Supabase tier, migration repo, etc.) | ⏳ Placeholder |

See `DECISION_RECORDS.md` for full rationale.

---

## 📐 Schema Overview

The EYWA database schema (v1.9) consists of **28 tables organized into 9 groups**:

1. **Group 1 — Core Identity** (brands, seo_authors, seo_brand_doctors, seo_brand_branches)
2. **Group 2 — Knowledge Graph** (seo_entity_graph, seo_entity_relationships, seo_topic_cluster_master)
3. **Group 3 — Content Pages** (seo_website_page_master)
4. **Group 4 — Citations** (seo_citations, seo_page_citations, seo_editorial_reviews)
5. **Group 5 — Keywords** (seo_x_ads_keywords_contextual_master + analytics)
6. **Group 6 — Logs & Audits** (seo_governance_audit, seo_kpi_baseline)
7. **Group 7 — AI Operations** (seo_entity_embeddings, seo_ai_citation_tracking, seo_ai_query_log)
8. **Group 8 — Scoring & Authority** (seo_brand_authority_scores, seo_cluster_health_scores, seo_entity_authority_scores, seo_eeat_scores)
9. **Group 9 — Operations** (translations, schema_changes, etc.)

**Schema Appendices:**

- **Appendix A:** PostgreSQL Extensions (pg_trgm + pgvector + others)
- **Appendix B:** Fingerprint Patterns (Two-Column Identity)
- **Appendix C:** Naming Conventions
- **Appendix D:** Cross-Reference Index to Bible
- **Appendix E:** Multilingual Strategy (Two-Tier pattern)
- **Appendix F:** Helper Functions Reference (ULID generator, fingerprint generators, triggers)
- **Appendix G:** Entity Uniqueness Guard (EUG) Implementation 🆕 v1.9

---

## 📜 Version History

**Bible:**
- **v3.13 (2026-05-08)** — Entity Uniqueness Guard + Edge Evolution Policy 🛡️🔄 *(current)*
- v3.12 (2026-05-08) — Two-Column Identity + Phase 1 Foundation 🆔🏗️
- v3.11 (2026-05-07) — Two-Phase Hierarchy Sync Pattern 🌳
- v3.10.1 (2026-05-07) — Structural Cleanup 🧹
- v3.10 (2026-05-07) — 2-Tier Schema Strategy Documentation 📐
- v3.9 (2026-05-07) — Multilingual Strategy 🌐
- v3.8 (2026-05-07) — Elementor Pro Integration 🎨
- v3.7 (2026-05-07) — Multi-Brand Federation Pattern 🌐
- v3.6 (2026-05-07) — Universal Scoring Framework 📊
- *(see Bible changelog for full v1.0 → v3.13 history)*

**Schema:**
- **v1.9 (2026-05-08)** — EUG Implementation + brands Two-Column Compliance 🛡️🆔 *(current)*
- v1.8 (2026-05-08) — Two-Column Identity + Multilingual v2 🆔🌐
- v1.7 (2026-05-07) — Two-Phase Hierarchy Sync Pattern 🌳
- v1.6 (2026-05-07) — Sync with Bible v3.9 (Multilingual) 🌐
- *(see Schema changelog for full v1.0 → v1.9 history)*

**Handover:**
- **v1.5 (2026-05-09)** — DR-013 + DR-014 Proposed status added 🌱 *(current)*
- v1.4 (2026-05-08) — EUG integration + Phase 1A migration update
- v1.3 (2026-05-08) — Phase 1 Status section added
- v1.2 (2026-05-07) — Per-brand repo folder structure
- v1.1 (2026-05-07) — Planning file schemas
- v1.0 (2026-05-07) — Initial release

**Decision Records:**
- **v1.3 (2026-05-09)** — DR-013 (Edge v3.5 Expansion) + DR-014 (Concept Subtype Lock) Proposed 🌱 *(current)*
- v1.2 (2026-05-08) — DR-011 (EUG) + DR-012 (Edge Evolution) added
- v1.1 (2026-05-08) — DR-007 through DR-010 added
- v1.0 (2026-05-07) — Initial release with DR-001 through DR-006

**Future (pending DR-013/014 governance review 2026-05-15):**
- 🔮 Bible v3.14 — Edge vocabulary 10 → 12 + typed edge_note + concept subtype lock
- 🔮 Schema v1.10 — edge_evidence_citation + medical_reviewer_signoff fields + Phase 1E migrations
- ⚠️ Build only triggers AFTER DR-013/014 lock (not before)

---

## 🔗 Related Repos

| Repo | Purpose |
|------|---------|
| `eywa-acf-fields` | ACF JSON files (universal field structure) |
| `eywa-core` | Foundation plugin |
| `eywa-cpt-activation` | CPT registration plugin |
| `eywa-schema-pipeline` | 3-Layer schema generator plugin |
| `eywa-elementor-templates` | Theme Builder JSON exports |
| `eywa-supabase-migrations` | SQL migration scripts (Phase 1+) |
| `eywa-n8n-flows` | n8n workflow exports |
| `vth-biodent` | Brand-specific: VTH BioDent content + config |
| `vitalsleep` | Brand-specific: VitalSleep content + config |
| ... | (additional per-brand repos as brands onboard) |

---

## 📧 Contact

The Gifted Digital Marketing Co., Ltd.  
Website: [thegifteddigital.com](#)

---

## ⚖️ License

This specification is proprietary. EYWA™ is a registered trademark of The Gifted Digital Marketing Co., Ltd. (Thailand, DIP, filed 2026-04-20, Class 35+42).

Internal use within The Gifted Digital portfolio companies and licensed partners only.
