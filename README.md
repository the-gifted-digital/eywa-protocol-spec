# EYWA™ Protocol — Specification

> **Universal Knowledge Graph SEO Specification for Healthcare & Wellness Brands**

| 📖 Bible | 📊 Schema | 🏗️ Phase | ⚖️ License |
|----------|-----------|-----------|-------------|
| **v3.34** | **v1.23** | **1A Built ✅** | Proprietary |

<!-- Badges (render on GitHub.com): -->
[![Bible](https://img.shields.io/badge/Bible-v3.34-blue?style=flat-square)](./EYWA_PROTOCOL_v3_33.md)
[![Schema](https://img.shields.io/badge/Schema-v1.23-green?style=flat-square)](./Schema_Overview_EYWA_v1_23.md)
[![Migrations](https://img.shields.io/badge/Migrations-Phase%201A%20Built-success?style=flat-square)](./migrations/README.md)
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
| `PROJECT_MEMORY.md` | Project context for AI sessions + onboarding | ~880 | 🧠 Memory (local-only, gitignored) |
| `EYWA_PROTOCOL_v3_33.md` | The Bible — full specification | ~27,800 | 🔒 Active (v3.34) |
| `Schema_Overview_EYWA_v1_23.md` | Database schema companion (43 live base tables, Group 11 NEW media_assets) | ~2,000 | 🔒 Active (v1.23) |
| `EYWA_HANDOVER.md` | Operating manual for Claude/AI | ~3,100 | 🔒 Active (v1.19) |
| `DECISION_RECORDS.md` | Architecture decision log | ~3,900 | 🔒 Active (v1.30) |
| `Keyword_Assignment_SOP_v1_0.md` | SOP — เลือกคีย์เวิร์ดหลัก/รอง ผูกเข้าหน้า (DR-043) + บทเรียน L1–L19 | ~520 | 🔒 Active (v1.2) |
| `Citation_Pool_SOP_v1_0.md` | SOP — สร้าง/ตรวจ/ผูก citation (DR-044) + บทเรียน C1–C20 | ~160 | 🔒 Active (v1.2) |
| `verify-citation-locators.py` | ยิง PMID/DOI กลับไปถาม PubMed + Crossref คืน verdict (DR-044 ขั้นที่ 2) | ~150 | 🧰 Tool |
| `citation-qa-gates.sql` | QA gate G1–G11 สำหรับสระ citation ต้องคืน 0 แถวทุกข้อ | ~150 | 🧰 Tool |
| `PHASE_1_DECISIONS.md` | Phase 1 quick reference | ~440 | 🔒 Active (v1.9) |
| `Content_Templates_EYWA_v1_0.md` | Universal Content Templates (DR-020 companion, v1.9 internal) | ~2,500 | 🔒 Active (v1.9 — DR-020 locked 2026-05-12 + §4.5.4 per DR-034 + §4.6/§4.7 per DR-039) |
| `examples/T1-medical-condition-SKELETON.md` | T1 boilerplate (Part 1/2 separation reference) | ~840 | 🌱 DRAFT |
| `examples/T1-osa-vth-biodent-WORKED-EXAMPLE.md` | T1 OSA filled example (VTH dental sleep angle) | ~1,060 | 🌱 DRAFT |
| `examples/SECTION-2-PATTERNS-REFERENCE.md` | Section 2 rendered patterns × 25 templates | ~534 | 🌱 DRAFT |
| `archive/EYWA_PROTOCOL_v3_13.md` | Bible (previous version) | ~25,460 | 📦 Archived |
| `archive/Schema_Overview_EYWA_v1_9.md` | Schema (previous version) | ~3,985 | 📦 Archived |
| `archive/EYWA_PROTOCOL_v3_12.md` | Bible (older version) | ~24,800 | 📦 Archived |
| `archive/Schema_Overview_EYWA_v1_8.md` | Schema (older version) | ~3,400 | 📦 Archived |

---

## 🆕 Latest Update — Bible v3.34 / Schema v1.23 (2026-06-21)

**Current spec stack — brands bump to these versions:**
**Bible v3.34** · **Schema v1.23** · **Handover v1.19** · **Decision Records v1.27** · **Content_Templates v1.9** · **PHASE_1 v1.9**

**DR-041 (Locked 2026-06-21):** **Heading Hierarchy & Document-Semantics Standard** — universal §9.9. One stack-agnostic heading + landmark contract for every brand (Elementor Pro **and** Astro): real headings only inside `<main>` (H1 hero → H2 sections → H3/H4, no skips), `<header>`/`<footer>` heading-free landmarks, injected promos = `<aside aria-label>` with a non-heading `<p>` headline. Block-role → element/level map keyed on Part 9 anatomy. Promoted from the VTH BioDent brand standard; masthead compliance bumped `WCAG 2.1` → **`2.2 Level AA`** (matches §23.6). Documentation-only (no schema change); Bible §9.9.

**DR-040 (Locked 2026-06-14):** R2 media buckets — **strict per-brand isolation** (`{brand-slug}-media`, no cross-brand sharing, ever) + object-key/folder naming convention + `r2.dev` → `cdn.{brand}` delivery. Convention-only (no schema change); Bible §18.5b. Supersedes the unapplied 2026-06-09 Deezy "DR-038" staging draft (number collision with the canonical DR-038 below).

**DR-038 (Locked 2026-06-11):** Canonical `seo_media_assets` table + `brands` Cloudflare config columns. 14th N↔S table (🖼️ Media Library mirror) + per-brand CF account routing. Group 11 NEW (Media Assets). Wave 11.8 + 11.9 applied to Supabase. ☁️ Cloudflare Accounts reference DB seeded in both Notion workspaces (operator UI, non-mirror per Bible §18.1.2b).

Most recent decisions (full detail + rationale in [`DECISION_RECORDS.md`](./DECISION_RECORDS.md)):

| DR | Status | What | Schema |
|----|--------|------|--------|
| **DR-036** Split `condition` / `symptom` CPTs 🔒 | 2026-06-04 (Locked) | Tier-1 Core 8→9; `symptom` its own CPT (sibling to `condition`, like `treatment`↔`procedure`); shared `/by-concern/` base; greenfield/additive | **v1.21** — new `seo_entity_symptom` (29 cols, built `eywa_w11_06`); Bible §25 (v3.26) |
| **DR-035** Image Storage & Delivery (Astro / Cloudflare R2) | 2026-06-04 (Locked) | Astro brands: image binaries on Cloudflare (R2 + Transformations / Images), Supabase stores only the URL | — (Bible v3.25, no DDL) |
| **DR-034** Intra-Page Answer Routing (PAA × FAQ) | 2026-06-03 (Locked) | §4.5.4 — understanding-PAA → body, decision-PAA → FAQ; tiered FAQ floor; PAA subordinate to the locked template | **v1.20** — `page_master` +`intent_source_tier`, `paa_checked_at` |
| **DR-033** ICD Dual-Coding Standard | 2026-06-02 | `MedicalCondition.code[]` = ICD-11-MMS → ICD-10 → ICD-10-CM → SNOMED | v1.19 — `seo_entity_condition` +`icd11_code`, `icd10_cm_code` |
| **DR-032** Multi-Center Hospital Brand Pattern | 2026-05-25 | `brand_structure: monolithic \| multi_center` chosen upfront at onboarding | v1.18 — `seo_brand_centers` + `center_slug`; Bible §25.13 (v3.24) |
| **DR-031** Google Generative AI Search Alignment | 2026-05-24 | llms.txt deprioritized; query fan-out + audience-first framing | — (Bible v3.23, no DDL) |
| **DR-030** Sensitive Topic Compliance | 2026-05-20 | Product × Content tier matrix + `positioning_mode` | v1.17 — `page_master` +6 compliance cols |

> **Brand snapshot:** new brands inherit the current stack via `templates/brand-config.template.json` → `eywa_spec_snapshot` (defaulted to the versions above; locked set = DR-001..022 + 024/025/028..036, DR-026 Proposed). New brands bootstrap with **9 Tier-1 CPTs** (incl. `symptom` per DR-036). Earlier waves — DR-024/025 schema catch-up (v3.15 / v1.11), DR-028 Brand Genesis Protocol, DR-029 Universal Brand Design System — see the `DECISION_RECORDS.md` changelog.

---

## 🆕 Previous Update — v3.14 / v1.10 (2026-05-10)

**Sitemap Design Quality Gates — 4 new DRs from VTH BioDent field testing**

Real-world feedback from VTH BioDent (Naphannop S.) surfaced 4 process gaps in the sitemap design layer (Phase E). All 4 DRs locked together — independent of DR-013/014 edge vocabulary governance (still under review).

- ✅ **DR-015** — Brand Scope Market Reconciliation Pattern (Bible §4.13)
- ✅ **DR-016** — Page Viability Assessment / Thin Page Detection (Bible §4.14)
- ✅ **DR-017** — Page Content Brief Field (Schema column + Bible §4.5)
- ✅ **DR-018** — Page Content Length Standards (Bible §9.8)

**Bible v3.14 changes (additive):**
- Section 4.13 — Market Reality Reconciliation Pattern (3-axis scoring: Necessity / Brand-Fit / SEO Opportunity)
- Section 4.14 — Page Viability Assessment (4-criteria gate + 5 exception clauses)
- Section 9.8 — Page Content Length Standards (14 page types × Min/Target/Max words; multilingual -20%)

**Schema v1.10 changes (additive — page_master only):**
- `content_brief text NULL` (DR-017)
- `marketplace_proposal_status text NULL` with CHECK constraint (DR-015)
- `reconciliation_notes text NULL` (DR-015)
- `viability_assessment jsonb NULL` (DR-016)

**New migrations (Phase 1A.2):**
- `007_add_content_brief.sql`
- `008_add_sitemap_design_columns.sql`

> **Scope note:** v3.14/v1.10 is sitemap design layer refinement. Edge vocabulary remains 10 LOCKED (DR-013/014 governance review continues independently — see below).

---

## 🌱 Governance Update — DR-021 Proposed (2026-05-10)

**Trigger:** Stage 1.5 (Handover v1.6) needs internal linking storage. Operator's pre-EYWA Notion DB ("Website & SEO Page Intelligent Master") had rich page-level linking strategy. Current Schema v1.10 has implicit linking only (cluster + entities + sitemap hierarchy) — no per-edge fidelity.

- 🌱 **DR-021 (Proposed):** Internal Linking Architecture HYBRID — review until **2026-06-07** (paired with DR-019/020 cycle)

**4 sub-decisions to lock together:**
1. **12 Page-Level Strategy Columns** — port from Notion DB to `seo_website_page_master` (Authority Weight, Strategic Page, Required Min In/Out, Link Priority Default, Anchor Strategy Mode, Cross-Brand governance, etc.)
2. **New Junction Table `seo_page_internal_links`** — ~22 cols per-edge (anchor_text, anchor_variant_type, section_context, link_type, link_role, link_priority, is_reciprocal, is_cross_brand, etc.)
3. **Bidirectional Consistency Validation** — reciprocal detection trigger, anchor diversity warning, orphan detection, authority depth check
4. **Cross-Brand Link Governance** — `is_cross_brand=true` REQUIRES `cross_brand_justification` + `from_page.cross_brand_approved=true`

**Schema v1.11 deferred additions:**
- 12 new columns on `seo_website_page_master`
- New table `seo_page_internal_links` (~22 columns)
- New migrations: `009_add_linking_strategy_cols.sql` + `010_create_seo_page_internal_links.sql` (Phase 1A.3)

**HYBRID rationale:**
- Page-level alone (Notion DB approach) → lacks per-edge fidelity (anchor text, section context per edge)
- Junction alone → lacks page-level strategy (Authority Weight, Mode, Required Min)
- HYBRID = best of both worlds for production-grade SEO + content production fidelity

**Effort estimate (if locked):** ~15-20 hours one-time + ~2-3 hours per brand for population.

**If LOCKED 2026-06-07:** Schema v1.11 migrations + ACF field updates + n8n flow updates + Bible v3.15 cross-references (Part 4 + Part 13) + Content_Templates v1.4 (Part 2 §6 Internal Link Checklist references DB)

**If REJECTED:** Continue with implicit linking via cluster + entities + sitemap hierarchy; re-evaluate when Stage 2 surfaces concrete pain points

> **Note:** DR-021 complements DR-019 (schema emission) + DR-020 (content composition) — together form complete content production stack: composition + emission + linking.

---

## 🌱 Governance Update — DR-020 Proposed (2026-05-10)

**Trigger:** VTH BioDent /mouth-biomapping/ EEAT audit (visual EEAT good, structured EEAT broken — 6 failures) + Deezy sitemap gap analysis (13 distinct page types, no universal template framework).

- 🌱 **DR-020 (Proposed):** Universal Content Template Standard — review until **2026-06-07** (paired with DR-019 cycle)

**4 sub-decisions to lock together:**
1. **Companion File Architecture** — `Content_Templates_EYWA_v1_0.md` becomes 3rd canonical reference (alongside Bible + Schema)
2. **3-Layer Composition System** — ~25 Universal Building Blocks → 25 Content Type Templates → Customization Hooks
3. **EEAT Requirement Matrix** — locked per template type (medical YMYL: required; institutional: not required)
4. **Schema Enforcement Pattern** — beyond visual EEAT (Article author = Physician, reviewedBy explicit, lastReviewed property, medicalAudience, citation array, MedicalBusiness typing)

**Templates summary (25 total):**
- **Core Universal (12):** T1 Medical Condition, T2 Medical Procedure, T3 Diagnostic, T4 Medical Device, T5 Service Page, T6 Concept, T6a Guide 🆕, T7 Comparison, T8 Case Study, T9 Author Profile, T10 Branch, T11 Institutional, T12 Hub
- **T2 Vertical Variants (5):** T2a Aesthetic, T2b Dental, T2c Wellness Program, T2d Physiotherapy, T2e Genomic
- **Specialized (7):** T13 Pricing List, T14 Trending, T15 Quiz, T16 Insurance, T17 Care Instructions, T18 Programmatic Local 🆕, T19 Promotion 🆕

**No DDL change** — existing page_master columns suffice. Future v1.1 may add `template_id` + `template_version` columns.

**EEAT enforcement phasing:** Soft-warn now → Hard-block 2026-09-01 (prerequisite: ≥80% brand doctor onboarding).

**If LOCKED 2026-06-07:** `Content_Templates_EYWA_v1_0.md` upgrades from DRAFT → LOCKED status (already at repo root) + Bible v3.15 references it + ACF field group refactor + eywa-schema-pipeline plugin update for medical_reviewer injection.

**If REJECTED:** Document remains as advisory pattern in scratchpad; per-brand customization via existing flexibility.

> **Note:** DR-020 is independent of DR-013/014, complements DR-017/018/019. Together with DR-019 forms complete content production stack (composition + emission).


---

## 🌱 Governance Update — DR-019 Proposed (2026-05-10)

**Trigger:** Google announcement 2026-05-07 — FAQ rich results full deprecation effective June 2026 (incl. gov/health carve-out). Multi-source verification (12+ industry sources) confirms schema role shift from SERP-rendering to AI-extraction signal.

- 🌱 **DR-019 (Proposed):** Schema Strategy for Post-Rich-Results Era — review until **2026-06-07**

**4 sub-decisions to lock together:**
1. **Two-Purpose Schema Taxonomy** — split into `serp_rich_result` / `ai_citation` / `forbidden`
2. **Featured Snippet Capture Pattern** — H2/H3 = question, 40-60 word direct answer (Bible Part 9 NEW section)
3. **KPI Replacement** — drop `faq_rich_result_impressions`, add `ai_citation_rate` + `featured_snippet_capture_rate` (Bible Part 20)
4. **AggregateRating Tightening** — min 5 verifiable reviews + crawler-accessible source

**Forbidden schemas (BLOCK emission):** `CourseInfo`, `ClaimReview`, `EstimatedSalary`, `LearningVideo`, `SpecialAnnouncement`, `VehicleListing`, `PracticeProblem` (Google Mar 2026 deprecations)

**AI-citation schemas (emit but no SERP expectation):** `FAQPage`, `HowTo`, `MedicalCondition`, `MedicalProcedure`, `MedicalTherapy`, `Drug`, `DefinedTerm`, `QAPage`, `SpeakableSpecification`

**No DDL change** — spec-level + plugin-level only (`eywa-schema-pipeline` enforces forbidden list).

**If LOCKED 2026-06-07:** Bible v3.15 (Part 26 restructure, Part 9 new section, Part 20 KPI update) + plugin updates  
**If REJECTED:** Workaround pattern (selective emission per page via existing `schema_markup_planned` jsonb)

> **Note:** DR-019 is independent of DR-013/014 governance — different scope (schema emission layer vs entity edge vocabulary layer). Targets Bible v3.15 if locked.


---

## 🌱 Governance Update — DR-013 + DR-014 Still Proposed (2026-05-09)

**Field-tested feedback from VTH BioDent EGP work** — first test of DR-012 (Edge Vocabulary Evolution Policy) governance.

- 🌱 **DR-013 (Proposed):** Edge Vocabulary v3.5 Expansion (causes/caused_by + contraindicates) — review until 2026-05-20
- 🌱 **DR-014 (Proposed):** Concept Entity Subtype Lock (framework + axis) — review until 2026-05-20

**Critical path:** Cross-brand verification by 2026-05-13 → Schema Review Board 2026-05-15 → Lock or Reject decision 2026-05-20

**If LOCKED:** Bible v3.15 + Schema v1.11 + 5 SQL migrations (Phase 1E)  
**If REJECTED:** Workaround pattern (related_to + notes with brand_scope)

> **Note:** v3.14/v1.10 (DR-015..018) was issued independently for sitemap design. DR-013/014 (edge vocabulary) targets future v3.15/v1.11 only after governance review.


---

## 🛡️ Previous Update — v3.13 (2026-05-08)

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
6. Read **Bible Sections 4.13, 4.14, 9.8** (Sitemap Design Quality Gates) — before sitemap work 🆕 v3.14
7. Read **Schema v1.10 Appendix F** (Helper Functions) — for SQL development
8. Read **Schema v1.10 Appendix G** (EUG Implementation) — for entity governance 🆕 v1.9

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
- ✅ Schema upgrade (Bible v3.14 / Schema v1.10)
- ✅ Two-Column Identity Pattern adoption (now includes brands table)
- ✅ Two-Tier Multilingual Strategy
- ✅ brand_slug standardization
- ✅ Entity Uniqueness Guard (EUG) v1.0 design 🆕 v3.13
- ✅ Edge Vocabulary Evolution Policy 🆕 v3.13
- ✅ Sitemap Design Quality Gates (DR-015..018) 🆕 v3.14
- ⏳ Migration files (29 SQL files planned across Phases 1A-1D + 1A.2)
- ⏳ Helper functions (`generate_ulid()`, fingerprint generators, triggers, EUG functions)

**Migration Plan (29 files):** 🔄 v3.14/v1.10

- Phase 1A: Foundation (6 migrations) — non-breaking column additions + helpers + **EUG** 🆕 v3.13
- Phase 1A.2: Sitemap Design Quality Gates (2 migrations) 🆕 v3.14 — content_brief + 3 reconciliation/viability columns
- Phase 1B: New Tables (~14 migrations) — create v1.9+ tables (incl. brands Two-Column compliance)
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
007_add_content_brief.sql                  # Content brief column (DR-017) 🆕 v3.14
008_add_sitemap_design_columns.sql         # Reconciliation + viability columns (DR-015 + DR-016) 🆕 v3.14
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
| **DR-013** | **Edge Vocabulary v3.5 Expansion (causes + contraindicates)** | 🌱 **Proposed (review until 2026-05-20)** |
| **DR-014** | **Concept Entity Subtype Lock (framework + axis)** | 🌱 **Proposed (review until 2026-05-20)** |
| **DR-015** | **Brand Scope Market Reconciliation Pattern** | 🔒 **Locked (NEW v1.4)** |
| **DR-016** | **Page Viability Assessment / Thin Page Detection** | 🔒 **Locked (NEW v1.4)** |
| **DR-017** | **Page Content Brief Field** | 🔒 **Locked (NEW v1.4)** |
| **DR-018** | **Page Content Length Standards** | 🔒 **Locked (NEW v1.4)** |
| **DR-019** | **Schema Strategy for Post-Rich-Results Era (FAQ/HowTo/AggregateRating)** | 🌱 **Proposed (NEW v1.5 — review until 2026-06-07)** |
| **DR-020** | **Universal Content Template Standard (25 templates × ~25 blocks)** | 🌱 **Proposed (NEW v1.6 — review until 2026-06-07)** |
| **DR-021** | **Internal Linking Architecture (HYBRID — page strategy + junction)** | 🌱 **Proposed (NEW v1.7 — review until 2026-06-07)** |
| DR-022..026 | Various (WordPress hosting, Supabase tier, migration repo, Notion sync scope, branch testing, etc.) | ⏳ Placeholder |

See `DECISION_RECORDS.md` for full rationale.

---

## 📐 Schema Overview

The EYWA database schema (v1.11) consists of **37 tables organized into 9 groups**:

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
- **v3.14 (2026-05-10)** — Sitemap Design Quality Gates (DR-015..018) 🗺️🛡️ *(current)*
- v3.13 (2026-05-08) — Entity Uniqueness Guard + Edge Evolution Policy 🛡️🔄
- v3.12 (2026-05-08) — Two-Column Identity + Phase 1 Foundation 🆔🏗️
- v3.11 (2026-05-07) — Two-Phase Hierarchy Sync Pattern 🌳
- v3.10.1 (2026-05-07) — Structural Cleanup 🧹
- v3.10 (2026-05-07) — 2-Tier Schema Strategy Documentation 📐
- v3.9 (2026-05-07) — Multilingual Strategy 🌐
- v3.8 (2026-05-07) — Elementor Pro Integration 🎨
- v3.7 (2026-05-07) — Multi-Brand Federation Pattern 🌐
- v3.6 (2026-05-07) — Universal Scoring Framework 📊
- *(see Bible changelog for full v1.0 → v3.14 history)*

**Schema:**
- **v1.10 (2026-05-10)** — page_master sitemap design columns (DR-015..017) 🗺️ *(current)*
- v1.9 (2026-05-08) — EUG Implementation + brands Two-Column Compliance 🛡️🆔
- v1.8 (2026-05-08) — Two-Column Identity + Multilingual v2 🆔🌐
- v1.7 (2026-05-07) — Two-Phase Hierarchy Sync Pattern 🌳
- v1.6 (2026-05-07) — Sync with Bible v3.9 (Multilingual) 🌐
- *(see Schema changelog for full v1.0 → v1.10 history)*

**Handover:**
- **v1.6 (2026-05-10)** — Phase E sitemap quality gates + session_2026_05_10 entry 🗺️ *(current)*
- v1.5 (2026-05-09) — DR-013 + DR-014 Proposed status added 🌱
- v1.4 (2026-05-08) — EUG integration + Phase 1A migration update
- v1.3 (2026-05-08) — Phase 1 Status section added
- v1.2 (2026-05-07) — Per-brand repo folder structure
- v1.1 (2026-05-07) — Planning file schemas
- v1.0 (2026-05-07) — Initial release

**Decision Records:**
- **v1.7 (2026-05-10)** — DR-021 (Internal Linking Architecture HYBRID) Proposed 🌱 *(current)*
- v1.6 (2026-05-10) — DR-020 (Universal Content Template Standard) Proposed 🌱
- v1.5 (2026-05-10) — DR-019 (Schema Strategy Post-Rich-Results) Proposed 🌱
- v1.4 (2026-05-10) — DR-015..018 (Market Reconciliation + Viability + Brief + Length Standards) 🔒
- v1.3 (2026-05-09) — DR-013 (Edge v3.5 Expansion) + DR-014 (Concept Subtype Lock) Proposed 🌱
- v1.2 (2026-05-08) — DR-011 (EUG) + DR-012 (Edge Evolution) added
- v1.1 (2026-05-08) — DR-007 through DR-010 added
- v1.0 (2026-05-07) — Initial release with DR-001 through DR-006

**Future (pending governance reviews):**
- 🔮 **Bible v3.15** (combined trigger):
  - DR-013/014 lock → Edge vocabulary 10 → 12 + typed edge_note + concept subtype lock
  - DR-019 lock → Part 26 restructure (3-purpose schema taxonomy) + Part 9 Featured Snippet pattern + Part 20 KPI replacement
  - DR-020 lock → Part 6 + Part 9 reference new companion file (Content_Templates_EYWA_v1_0.md)
  - DR-021 lock → Part 4 + Part 13 reference internal linking architecture
- 🔮 **Schema v1.11** (combined DDL from DR-013/014 + DR-021):
  - DR-013/014: edge_evidence_citation + medical_reviewer_signoff fields
  - DR-021: 12 page-level linking strategy cols + new `seo_page_internal_links` junction table
  - Future v1.1 of DR-020 may add `template_id` + `template_version` columns to page_master
  - Phase 1A.3 migrations: 009_add_linking_strategy_cols.sql + 010_create_seo_page_internal_links.sql
  - Phase 1E migrations (if DR-013/014 locked): edge vocabulary expansion
- 🔮 **New canonical companion file** (post DR-020 lock):
  - `Content_Templates_EYWA_v1_0.md` upgrades from DRAFT to LOCKED status (already in repo root)
- ⚠️ DR-013/014 review 2026-05-15 (lock or reject)
- ⚠️ DR-019 review 2026-06-07 (lock 1 week after Google June 2026 effective date)
- ⚠️ DR-020 review 2026-06-07 (paired with DR-019 cycle)
- ⚠️ DR-021 review 2026-06-07 (paired with DR-019/020 cycle — together = full content production stack)

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
