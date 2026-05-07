# 📊 Database Schema — EYWA™ PROTOCOL System
## Companion Reference to คัมภีร์ EYWA™ PROTOCOL

> **Purpose:** Source of Truth สำหรับ "WHAT exists" — full schema + column descriptions ของระบบ EYWA™ PROTOCOL ครบทุกตาราง  
> **Companion to:** คัมภีร์ EYWA™ PROTOCOL v3.9 (Part 5 + Part 2.6/2.7 + Part 10.7 Federation + Part 25.11 Elementor + Part 27 Scoring + Part 28 Multilingual)  
> **Version:** v1.6 — 2026-05-07  
> **Trademark:** EYWA™ (Class 35+42, DIP Thailand, filed 2026-04-20)  
> **Created by:** The Gifted Digital Marketing Co., Ltd.  
> **Stack:** Notion (planning) + Supabase PostgreSQL (knowledge graph + analytics) + n8n (sync) + WordPress (rendering)

---

## 📜 Changelog

### v1.6 (2026-05-07) — Sync with Bible v3.9 (Multilingual Strategy) 🌐

Added multilingual jsonb fields supporting 8-language architecture (Bible Part 28):

- ➕ **`seo_entity_graph`** multilingual fields:
  - `canonical_names jsonb` — `{"th": "...", "en": "...", "zh": "..."}` (8 languages designed)
  - `descriptions jsonb` — per-language description text
  - `alternative_names_per_language jsonb` — synonyms per language
  - `search_volume_per_language jsonb` — DataForSEO data per market
- ➕ **`seo_website_page_master`** translation tracking:
  - `wpml_translation_id text` — WPML element_id linking translations
  - `is_translation_of uuid` — FK to original page
  - `translation_status text` — `original`/`machine_translated`/`human_reviewed`
  - `translation_completeness numeric` — 0-1 (% fields translated)
- ➕ **`seo_citations`** multilingual:
  - `title_translations jsonb` — translated titles per language
  - existing `language` field documented as ISO 639-1 code
- ➕ **Per-language scoring fields** (Bible Part 28.9):
  - `entity_authority_score_th`, `entity_authority_score_en`, etc.
  - `e_e_a_t_score_th`, `e_e_a_t_score_en`, etc.
  - `cluster_health_score_th`, `cluster_health_score_en`, etc.
  - `brand_authority_score_th`, `brand_authority_score_en`, etc.
  - Aggregate score = GREATEST() across language-specific scores
- 🎯 Schema v1.6 = multilingual-ready (8 languages designed, 2 active initially)

### v1.5 (2026-05-07) — Sync with Bible v3.8 (Elementor Pro Integration) 🎨

Reference sync — no schema changes:
- 🔗 Updated companion reference: Bible v3.7 → v3.8
- 📜 No DB schema changes (Elementor integration is frontend-only)
- 🎯 ACF Field Groups continue to drive Dynamic Tags in Elementor
- 🎯 No new tables/columns needed for Elementor integration

### v1.4 (2026-05-07) — Sync with Bible v3.7 (Federation Pattern) 🌐

Aligned with Bible v3.7 Federation Pattern architecture:
- ➕ **`seo_website_page_master`:** Added `cross_brand_references jsonb` field — tracks lifecycle ของ inter-brand external links (Bible Section 4.12)
- 🔄 **`brand_scope[]`:** Convention now formally documented in Bible Section 10.7.5 — brand isolation enforced at data level via GIN-indexed array filter
- 🔄 **Federation philosophy clarified:** Team management lives in Notion (workspace level) + n8n flow config — NOT in Supabase tables. Supabase = data layer only, doesn't track teams/users beyond standard audit fields
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
- 🧹 Stripped all inline version markers (🆕 v1.1 / 🔄 v1.1 etc.) from headers + tables
- 🧹 Replaced "Deprecated v1.1" prefix with cleaner "Legacy field" wording
- 🔗 Synced companion reference to Bible v3.5
- 📜 All version history preserved in this changelog (single source of truth)
- 🎯 Schema_Overview v1.2 = production-ready companion document

### v1.1 (2026-05-07) — Sync with Bible v3.4 🌿

Aligned with Bible v3.4 "Universal Framework Codification":
- ➕ **NEW table:** `seo_entity_relationships` (Section 4.5) — typed edge junction table replacing generic `related_entities_fps[]`
- 🔄 **`brands` table:** Added `cpt_activation_flags jsonb` field — derived flags drive CPT auto-activation (Bible Part 25.6)
- 🔄 **`seo_entity_graph.entity_type`:** Reconciled to **15-type master list** (was 10) — adds `treatment`, `product`, `lab_test`, `person`, `organization` (Bible Part 2.6 + Appendix A.1)
- 🔄 **`seo_entity_graph`:** Marked `parent_entity_fp` + `related_entities_fps[]` as deprecated (kept for fallback) — replaced by typed edges
- ➕ **Cross-reference:** Bible Part 2.6 (Entity Genesis Protocol), Part 2.7 (Edge Vocabulary), Part 25 (WordPress Universal Kit), Part 26 (Schema Pipeline)
- ✅ Backward compatible — all changes additive (no breaking schema changes)

### v1.0 (2026-05-05) — Initial Specification

Initial release of Database Schema companion document.

---

## 1. How to Read This Document

This document describes the **complete EYWA™ PROTOCOL data architecture** as a unified system. Every table specified here serves a defined role in the protocol — together they form the neural network that powers AI-era SEO for healthcare brands.

### Document Conventions

```yaml
section_format:
  > Header: Purpose, Tier, Sync direction, Bible reference, Volume estimate
  ### Schema: Column-level table with type and description
  ### Indexes & Constraints: SQL block for keys, indexes, FKs
  ### Used By: Cross-references to Bible Parts and other tables

column_description_level: medium
  - Each column has 1-2 sentences explaining purpose
  - Business meaning included where relevant
  - References Bible Part where the field's logic is detailed

tier_classification:
  Tier 1 — Critical Operational: Daily-touched, system can't run without
  Tier 2 — Intelligence/Analytics: Insight generation, weekly-touched
  Tier 3 — Audit/Reference: Historical/governance, monthly-touched

sync_direction_codes:
  N→S: Notion is source, Supabase is mirror (one-way write)
  N↔S: Bidirectional sync (Notion ↔ Supabase)
  S only: Supabase only (high-volume, no Notion mirror)
  S→N: Supabase generates, Notion reads only
```

### Companion Documents

```
📜 Bible Part 5 (Architecture)  — WHY each table exists, design philosophy
📊 This Document (Reference)     — WHAT each table contains, full specs
💻 Migration Scripts (DDL)       — HOW to deploy (forward + reverse SQL)
🔧 Notion Blueprints             — Property setup per database in Notion
```

---

## 2. System Architecture Overview

### The 9-Group Organization

```
┌────────────────────────────────────────────────────────────────┐
│                  EYWA™ PROTOCOL DATA SYSTEM                     │
│                  ─────────────────────────                      │
│                                                                 │
│  Group 1: Brand & Organization        (4 tables) — Tier 1       │
│  Group 2: Knowledge Architecture      (4 tables) — Tier 1       │
│  Group 3: Page System                 (2 tables) — Tier 1       │
│  Group 4: Keyword & Search            (4 tables) — Tier 1       │
│  Group 5: Performance Fact Tables     (2 tables) — Tier 1       │
│  Group 6: Backlinks & Off-Page        (2 tables) — Tier 2       │
│  Group 7: AI Operations & Embeddings  (4 tables) — Tier 1/2     │
│  Group 8: Data Quality & Governance   (2 tables) — Tier 1/3     │
│  Group 9: Entity Extensions           (4 tables) — Tier 2       │
│                                       ─────────                 │
│                                       28 tables                 │
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
| 1. Brand & Organization | brands, branches, authors, doctor_assignments | N↔S |
| 2. Knowledge Architecture | entity_graph, topic_cluster, citations, page_citations | N↔S |
| 3. Page System | page_master, editorial_reviews | N↔S |
| 4. Keyword & Search | keywords_master, market_snapshot, serp_competitors, voice_search | N↔S (master), S only (snapshots) |
| 5. Performance Facts | daily_logs, local_rankings | S only (high volume) |
| 6. Backlinks | backlinks_data, backlinks_links | S only (DataForSEO ingest) |
| 7. AI Operations | brand_mentions, llm_citations, query_sims, embeddings | S only |
| 8. Data Quality | quality_metrics, schema_changes | S only (system-generated) |
| 9. Entity Extensions | ingredients, devices, procedures, templates | N↔S |

### Required PostgreSQL Extensions

| Extension | Required For | Status |
|-----------|--------------|--------|
| `pgcrypto` | UUID generation | Required |
| `uuid-ossp` | UUID functions | Required |
| `pgvector` (`vector`) | Group 7 — Entity Embeddings (vector similarity search) | Required |
| `postgis` | Group 1 — Branches (geo coordinates) | Recommended |
| `pg_cron` | Scheduled jobs (refresh, archival) | Optional |
| `pgmq` | Async job queue (n8n integration) | Optional |
| `wrappers` | Foreign Data Wrappers | Optional |

→ See Appendix A for installation order and version compatibility

---

## 3. Group 1 — Brand & Organization (4 tables)

> **Role:** กำหนดตัวตนของ brand, สาขา, แพทย์/ผู้ตรวจสอบ และความสัมพันธ์ระหว่างกัน  
> **Bible Reference:** Part 1 (Core Philosophy), Part 10 (Multi-Brand Strategy), Part 23.3 (Authority Validation)

### 3.1 `brands`

> **Purpose:** ตารางหลักของแบรนด์ทุกแบรนด์ในเครือข่าย — กำหนด vertical, format, accreditations และ identity บน knowledge graph ระดับสากล (Wikidata)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S (Notion master ↔ Supabase mirror)  
> **Bible Reference:** Part 1 (Multi-brand identity), Part 10 (Multi-Vertical), Part 14 (Vertical Profiles), Part 23.3 (Authority)  
> **Volume:** ~10-50 records (one per brand)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid` | Primary surrogate key, auto-generated |
| `brand_name` | `text PK` | ชื่อ brand (natural primary key — case-sensitive, unique) |
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
| `medical_specialty` | `text[]` | array รายการ specialty ที่ brand ครอบคลุม (เช่น `['dermatology', 'sleep_medicine']`) |
| `primary_branch_id` | `uuid` | สาขาหลัก (computed FK to seo_branches — สำหรับ Type B page rendering) |
| `accreditations` | `jsonb DEFAULT '[]'` | array รายการ accreditation: `[{"name": "JCI", "accredited_at": "...", "expires_at": "...", "verification_url": "..."}, {"name": "HA Thailand", ...}]` (Bible Part 23.3) |
| `medical_advisory_board_url` | `text` | URL หน้า Medical Advisory Board (Bible Part 23.3) |
| `wikidata_id` | `text` | Wikidata Q-number ของ brand (เช่น `Q123456789`) (Bible Part 13.X) |
| `wikidata_verified_at` | `timestamptz` | Timestamp ยืนยันว่า Wikidata entity ของ brand ยัง valid |
| `knowledge_panel_status` | `text` | สถานะ Google Knowledge Panel: 'not_yet' / 'pending_claim' / 'claimed' / 'verified' |
| `created_at` | `timestamptz DEFAULT now()` | Timestamp สร้าง record |
| `updated_at` | `timestamptz DEFAULT now()` | Timestamp อัพเดทล่าสุด (auto-trigger) |
| `notion_synced_at` | `timestamptz` | Timestamp sync กับ Notion ล่าสุด |
| `cpt_activation_flags` | `jsonb DEFAULT '{}'` | Derived flags ที่ขับ WordPress CPT auto-activation. Computed via `v_brand_cpt_activation` view — keys: `tier1_*` (always true), `tier2_program`, `tier2_signature_system`, `tier3_ingredient`, `tier3_product`, `tier3_drug`, `tier3_lab_test` (Bible Part 25.6) |
| `signature_offerings` | `text[] DEFAULT '{}'` | Array ของ branded methodologies (e.g., `['Mouth Bio Mapping', 'EmSmile']`) — drives `tier2_signature_system` activation |
| `brand_profile` | `jsonb DEFAULT '{}'` | Free-form brand-specific config keys (e.g., `has_treatment_pathways`, `has_active_ingredients`, `sells_dtc`, `has_pharmacy_focus`, `has_diagnostic_lab`) — feeds `cpt_activation_flags` derivation |
| `active_languages` | `text[] DEFAULT ARRAY['th']` | ISO 639-1 codes of active languages (Bible Part 28.1). Default Thai-only; expand to `['th', 'en']` after English launch |
| `default_language` | `text DEFAULT 'th'` | Default site language (no URL prefix in WPML) |
| `brand_authority_score_th` | `numeric` | Per-language brand authority score (Bible Part 28.9) |
| `brand_authority_score_en` | `numeric` | Per-language brand authority score for English |
| `brand_authority_score` | `numeric` | EYWA Scoring v1.0 — 0-100 (Bible Part 27.7.1). Top-level brand health rollup: external (DataForSEO domain rank, 25%), avg cluster health (20%), E-E-A-T coverage (20%), AI visibility (15%), KG coverage (10%), sitemap health (10%). Computed weekly |
| `brand_authority_breakdown` | `jsonb` | Factor-by-factor breakdown |
| `ai_citation_readiness` | `numeric` | EYWA Scoring v1.0 — 0-100 (Bible Part 27.7.2). Brand readiness for AI citation: schema completeness (25%), wikidata disambiguation (20%), citable density (20%), reviewed pct (15%), FAQ schema (10%), Speakable schema (10%) |
| `brand_score_formula_version` | `text DEFAULT 'v1.0'` | Tracks formula version |
| `brand_score_computed_at` | `timestamptz` | When scores last computed |

#### Indexes & Constraints

```sql
PRIMARY KEY (brand_name);
UNIQUE INDEX idx_brands_notion_id (notion_id) WHERE notion_id IS NOT NULL;
INDEX idx_brands_status (status) WHERE status = 'active';
INDEX idx_brands_vertical (vertical_family, healthcare_format);

-- Foreign keys (referenced by other tables)
-- seo_x_ads_keywords_contextual_master.brand → brands.brand_name
-- seo_branches.brand_id → brands.id
-- seo_authors_reviewers.brand_id → brands.id (via doctor_assignments)
-- seo_website_page_master.brand_id → brands.id
```

#### Used By
- **Part 5 (Database Schema)** — central entity referenced by most tables
- **Part 10 (Multi-Brand Strategy)** — brand_scope sharing patterns
- **Part 14 (Vertical Profiles)** — vertical_family + healthcare_format determine profile
- **Part 23.3 (Authority Validation)** — accreditations + advisory board
- **Part 13.X (Brand SERP)** — wikidata_id + knowledge_panel_status
- **Part 25.6 (CPT Activation)** — `cpt_activation_flags` + `signature_offerings` + `brand_profile` drive WordPress CPT registration
- **Part 26 (Schema Pipeline)** — brand identity drives Schema baseline + signature schemas

#### Computed View — `v_brand_cpt_activation`

```sql
CREATE OR REPLACE VIEW v_brand_cpt_activation AS
SELECT
  b.id, b.brand_name,
  -- Tier 1 (always)
  true AS tier1_doctor,
  true AS tier1_branch,
  true AS tier1_procedure,
  true AS tier1_treatment,
  true AS tier1_technology,
  true AS tier1_condition,
  true AS tier1_case_study,
  true AS tier1_post,
  -- Tier 2 (derived)
  (
    array_length(b.signature_offerings, 1) >= 1
    OR (b.brand_profile->>'has_treatment_pathways')::boolean = true
  ) AS tier2_program,
  (array_length(b.signature_offerings, 1) >= 1) AS tier2_signature_system,
  -- Tier 3 (vertical-driven)
  (b.vertical_family IN ('beauty', 'wellness', 'skincare-media')
   OR (b.brand_profile->>'has_active_ingredients')::boolean = true) AS tier3_ingredient,
  ((b.brand_profile->>'sells_dtc')::boolean = true
   OR b.vertical_family = 'ecommerce') AS tier3_product,
  ((b.brand_profile->>'has_pharmacy_focus')::boolean = true) AS tier3_drug,
  ((b.brand_profile->>'has_diagnostic_lab')::boolean = true) AS tier3_lab_test
FROM brands b;
```

---

### 3.2 `seo_branches`

> **Purpose:** สาขาทางกายภาพของ brand — ใช้สำหรับ Local SEO, Google Business Profile, schema.org LocalBusiness, และ Type B (Branch Landing) / Type C (Local Programmatic) pages  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Bible Reference:** Part 4.5 (Page Type Matrix), Part 4.6 (Multi-Vertical Variations), Part 14 (Vertical Profiles)  
> **Volume:** ~5-50 records per brand (typically 1-15 branches per healthcare brand)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key, auto-generated |
| `branch_fingerprint` | `text UNIQUE` | Natural unique identifier (e.g., `branch:brand_a_sukhumvit`) สำหรับ stable cross-system referencing |
| `brand_id` | `uuid FK→brands.id` | Brand เจ้าของสาขา |
| `branch_name` | `text` | ชื่อสาขาเต็ม (เช่น "Brand A สาขาสุขุมวิท") |
| `branch_slug` | `text` | URL slug สำหรับ /branches/{slug} (เช่น `sukhumvit`) |
| `branch_status` | `text DEFAULT 'active'` | 'active' / 'inactive' / 'opening_soon' / 'closed' |
| `address_full` | `text` | ที่อยู่เต็ม (multi-line — ใช้ใน schema:PostalAddress) |
| `address_street` | `text` | ที่อยู่ถนน |
| `address_district` | `text` | เขต/แขวง |
| `address_city` | `text` | จังหวัด/เมือง |
| `address_postal_code` | `text` | รหัสไปรษณีย์ |
| `address_country` | `text DEFAULT 'TH'` | ประเทศ ISO code |
| `geo_lat` | `numeric(10,7)` | Latitude (ใช้ postgis ถ้า install) |
| `geo_lng` | `numeric(10,7)` | Longitude |
| `phone_primary` | `text` | เบอร์โทรหลัก (E.164 format preferred) |
| `phone_secondary` | `text` | เบอร์สำรอง |
| `email_contact` | `text` | Email ติดต่อสาขา |
| `business_hours` | `jsonb` | Operating hours per day: `{"monday": {"open": "09:00", "close": "20:00", "closed": false}, ...}` |
| `directions_bts` | `text` | คำแนะนำเดินทางจาก BTS (สถานี + ทางออก) |
| `directions_mrt` | `text` | คำแนะนำเดินทางจาก MRT |
| `directions_car` | `text` | คำแนะนำสำหรับรถยนต์ (parking, ทางเข้า) |
| `parking_info` | `text` | ข้อมูลที่จอดรถ (ค่าใช้จ่าย, จำนวน slot) |
| `gbp_place_id` | `text` | Google Business Profile Place ID (เช่น `ChIJ...`) |
| `gbp_url` | `text` | Google Business Profile public URL |
| `services_offered` | `text[]` | array บริการที่สาขานี้ให้ (subset ของ brand services) |
| `medical_specialty` | `text[]` | array specialty ที่สาขามี (เช่น Type B page filter) |
| `doctor_count` | `integer` | จำนวนแพทย์ประจำสาขา (computed from doctor_assignments) |
| `image_hero_url` | `text` | URL รูป hero ของสาขา |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_id` | `text` | Notion page ID สำหรับ sync |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_branches_fp (branch_fingerprint);
UNIQUE INDEX idx_branches_brand_slug (brand_id, branch_slug);
INDEX idx_branches_brand (brand_id);
INDEX idx_branches_status (branch_status) WHERE branch_status = 'active';
INDEX idx_branches_geo (geo_lat, geo_lng) WHERE geo_lat IS NOT NULL;

-- With postgis: GIST index for spatial queries
-- CREATE INDEX idx_branches_geom USING GIST (ST_Point(geo_lng, geo_lat));
```

#### Used By
- **Part 4.5 (Page Type Matrix)** — Type B (Branch Landing), Type C (Local Programmatic), Type D (Brand-Wide Tagged)
- **Part 14 (Vertical Profiles)** — branch-aware patterns per vertical
- **Part 23.3 (Authority Validation)** — branch credentials in schema markup
- **seo_doctor_assignments** — junction with authors

---

### 3.3 `seo_authors_reviewers`

> **Purpose:** ทะเบียนแพทย์ ผู้เขียน และผู้ตรวจสอบทางการแพทย์ของ brand — แหล่ง authority สำหรับ E-E-A-T, schema:Physician markup, และ Multi-Stage Editorial Review (Bible Part 23.4)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Bible Reference:** Part 23.3 (Authority Validation), Part 23.4 (Editorial Review), Part 13 (LLMO E-E-A-T)  
> **Volume:** ~20-200 records per brand portfolio (cross-brand sharing supported)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key, auto-generated |
| `author_fingerprint` | `text UNIQUE` | Natural unique ID across all brands (e.g., `author:dr_first_last_specialty`) |
| `author_name_full` | `text` | ชื่อเต็มพร้อมคำนำหน้า (เช่น "นพ. สมชาย ใจดี") |
| `author_name_display` | `text` | ชื่อที่แสดง public (อาจเป็นแบบสั้น "ดร. สมชาย") |
| `slug` | `text UNIQUE` | URL slug สำหรับ /authors/{slug} |
| `bio_short` | `text` | Bio สั้น 1-2 ประโยค สำหรับ byline |
| `bio_long` | `text` | Bio เต็ม (≥150 words) สำหรับ author profile page |
| `photo_url` | `text` | URL รูปภาพ (with consent) — schema:Person.image |
| `schema_org_type` | `text DEFAULT 'Physician'` | Schema.org type: 'Physician' / 'Dentist' / 'Nutritionist' / 'Person' (default fallback) |
| `medical_specialty` | `text[]` | array specialty (เช่น `['Dermatology', 'Sleep Medicine']`) |
| `credentials` | `text[]` | array degrees/certifications (เช่น `['MD', 'Board Certified Dermatologist', 'PhD']`) |
| `years_of_experience` | `integer` | ปีประสบการณ์ทั้งหมด |
| `tmc_license_number` | `text` | เลขใบประกอบวิชาชีพแพทยสภา (TMC) |
| `tmc_license_verified_at` | `timestamptz` | Timestamp ยืนยันใบอนุญาตล่าสุด (Bible Part 23.3) |
| `license_verification_method` | `text` | 'TMC public registry lookup' / 'physical certificate' / 'employer verification' |
| `license_jurisdiction` | `text DEFAULT 'TH'` | ประเทศที่ออกใบอนุญาต (ISO code) |
| `license_authority` | `text` | หน่วยงาน: 'Thai Medical Council' / 'Thai Dental Council' / 'US Medical Board' / etc. |
| `active_status` | `text DEFAULT 'active'` | 'active' / 'inactive' / 'retired' / 'suspended' |
| `specialty_board_certs` | `text[]` | array board certifications (เช่น `['American Academy of Dermatology', 'สมาคมแพทย์ผิวหนังแห่งประเทศไทย']`) |
| `external_profiles` | `jsonb` | Links to external authority sources: `{"healthgrades_url": "...", "wikipedia_url": "...", "doctolib_url": "...", "orcid_id": "...", "linkedin_url": "..."}` (Bible Part 23.3) |
| `wikidata_id` | `text` | Wikidata Q-number (สำหรับแพทย์ที่ notable) |
| `advisory_board_role` | `text` | บทบาทใน Medical Advisory Board: 'chair' / 'member' / 'guest_reviewer' / NULL |
| `publication_count` | `integer` | จำนวน peer-reviewed publications (สำหรับ credibility scoring future) |
| `social_links` | `jsonb` | Social media links: `{"twitter": "...", "linkedin": "...", "instagram": "..."}` |
| `email_public` | `text` | Email สำหรับ contact public (ถ้ามี) |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_id` | `text` | Notion page ID |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_authors_fp (author_fingerprint);
UNIQUE INDEX idx_authors_slug (slug);
INDEX idx_authors_active (active_status) WHERE active_status = 'active';
INDEX idx_authors_specialty (medical_specialty) USING GIN;
INDEX idx_authors_advisory (advisory_board_role) WHERE advisory_board_role IS NOT NULL;
INDEX idx_authors_tmc (tmc_license_number) WHERE tmc_license_number IS NOT NULL;
```

#### Used By
- **Part 23.3 (Authority Validation)** — license verification + accreditation
- **Part 23.4 (Editorial Review)** — reviewer assignment per stage
- **Part 13 (LLMO)** — schema:Physician markup, byline attribution
- **seo_doctor_assignments** — junction with brands + branches
- **seo_website_page_master.reviewer_id** — page-level reviewer attribution

---

### 3.4 `seo_doctor_assignments`

> **Purpose:** Junction table เชื่อมแพทย์/ผู้เขียนกับ brand + branch — รองรับกรณีแพทย์คนเดียวประจำหลายสาขา หรือทำงานข้าม brand ในเครือ  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S (junction database in Notion)  
> **Bible Reference:** Part 10 (Multi-Brand), Part 23.3 (Authority)  
> **Volume:** ~50-500 records (1-N per author across brands/branches)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `assignment_fingerprint` | `text UNIQUE` | Natural ID (e.g., `assign:author_id+brand_id+branch_id`) |
| `author_id` | `uuid FK→seo_authors_reviewers.id` | แพทย์/ผู้เขียน |
| `brand_id` | `uuid FK→brands.id` | Brand |
| `branch_id` | `uuid FK→seo_branches.id NULLABLE` | สาขา (NULL = brand-wide ไม่ผูก branch) |
| `role` | `text` | 'primary_doctor' / 'consulting' / 'reviewer_only' / 'guest_author' |
| `assignment_status` | `text DEFAULT 'active'` | 'active' / 'inactive' / 'on_leave' |
| `start_date` | `date` | วันที่เริ่มทำงาน |
| `end_date` | `date` | วันที่สิ้นสุด (NULL = ongoing) |
| `weekly_schedule` | `jsonb` | ตารางออกตรวจ: `{"monday": ["09:00-12:00", "14:00-17:00"], ...}` |
| `consultation_languages` | `text[]` | ภาษาที่ให้บริการ |
| `is_brand_face` | `boolean DEFAULT false` | true = หมอที่เป็น face ของ brand (key visibility) |
| `display_priority` | `integer DEFAULT 100` | ลำดับการแสดงผลบนเว็บ (ต่ำ=แสดงก่อน) |
| `notes` | `text` | หมายเหตุภายใน |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_id` | `text` | Notion page ID |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_assignments_fp (assignment_fingerprint);
UNIQUE INDEX idx_assignments_unique (author_id, brand_id, branch_id);
INDEX idx_assignments_brand (brand_id, assignment_status);
INDEX idx_assignments_branch (branch_id) WHERE branch_id IS NOT NULL;
INDEX idx_assignments_active (assignment_status) WHERE assignment_status = 'active';
```

#### Used By
- **Part 10 (Multi-Brand)** — doctor sharing across brands in portfolio
- **Part 23.3 (Authority)** — branch-level doctor visibility
- Branch landing pages (Type B) — show doctors per branch
- Author profile pages (Type D — brand-wide tagged) — show all assignments


## 4. Group 2 — Knowledge Architecture (5 tables)

> **Role:** หัวใจของ Knowledge Graph — entities, clusters, citations, **typed relationship edges**, และความสัมพันธ์ระหว่าง pages กับ citations  
> **Bible Reference:** Part 2 (Conceptual Architecture), Part 2.6 (Entity Genesis Protocol) 🆕, Part 2.7 (Edge Vocabulary) 🆕, Part 5 (Database), Part 7 (Taxonomy SKOS), Part 23.1 (Citation Tiers), Part 26 (Schema Pipeline)

### 4.1 `seo_entity_graph`

> **Purpose:** Master ของทุก entity ในระบบ — concepts, conditions, procedures, ingredients, devices, drugs — เชื่อมโยงกับ Wikidata, ICD-10, MeSH, และระบุ brand_scope (ใช้ข้าม brand ได้ไหม)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Bible Reference:** Part 2 (Conceptual Architecture), Part 7 (SKOS), Part 14 (Vertical Profiles)  
> **Volume:** ~500-2000 entities (mid-size brand portfolio)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `entity_fingerprint` | `text UNIQUE` | Natural unique ID (e.g., `entity:niacinamide`, `entity:peri_implantitis`) |
| `entity_name` | `text` | ชื่อ entity primary (display name) |
| `entity_slug` | `text` | URL slug สำหรับ /entity/{slug} ถ้ามีหน้า dedicated |
| `entity_type` | `text` | **15-type master list** (per Bible Appendix A.1): `'condition'` / `'symptom'` / `'procedure'` / `'treatment'` / `'device'` / `'concept'` / `'product'` / `'drug'` / `'ingredient'` / `'anatomy'` / `'specialty'` / `'lab_test'` / `'biomarker'` / `'person'` / `'organization'` (Bible Part 2.6 Genesis Checklist) |
| `parent_entity_fp` | `text` | ⚠️ **Legacy field** — Use `seo_entity_relationships` with `edge_type='child_of'` for typed edges (Bible Part 2.7). Kept for backward compatibility. FK เชิง self-reference สำหรับ hierarchy |
| `aliases` | `text` | Comma-separated aliases (ชื่ออื่นที่ใช้เรียก entity เดียวกัน — สำหรับ search expansion) |
| `topic_cluster_id` | `text FK` | Topic cluster ที่ entity นี้สังกัด (จาก seo_topic_cluster_master) |
| `topic_cluster_name` | `text` | Denormalized cluster name (ความเร็ว query) |
| `schema_org_type` | `text` | Schema.org type: 'MedicalCondition' / 'MedicalProcedure' / 'Drug' / 'AnatomicalStructure' / 'DefinedTerm' / etc. |
| `canonical_names` | `jsonb DEFAULT '{}'` | Multilingual entity names (Bible Part 28.3). Structure: `{"th": "โรค TMJ", "en": "TMJ Disorder", "zh": "颞下颌关节紊乱", "ja": "顎関節症", "ko": "턱관절 장애", "ar": "اضطراب", "fr": "Trouble TMJ", "es": "Trastorno TMJ"}`. Active: TH+EN; designed for 8 languages |
| `descriptions` | `jsonb DEFAULT '{}'` | Multilingual description text (same key structure as canonical_names) |
| `alternative_names_per_language` | `jsonb DEFAULT '{}'` | Synonyms per language: `{"th": ["TMJ", "ขากรรไกรค้าง"], "en": ["TMJ", "TMD"]}` |
| `search_volume_per_language` | `jsonb DEFAULT '{}'` | DataForSEO data per language market: `{"th": {"monthly_volume": 5400, "trend": "stable"}, "en": {"monthly_volume": 12000, "trend": "rising"}}` (Bible Part 28.11) |
| `entity_authority_score_th` | `numeric` | Per-language EYWA authority score (Bible Part 28.9). Computed from Thai-scoped data only |
| `entity_authority_score_en` | `numeric` | Per-language EYWA authority score for English |
| `entity_authority_score` | `numeric` | Score 0-100 บอก authority ของ entity ในระบบ (computed) |
| `search_volume_total` | `integer` | Aggregate search volume (sum of related keywords) |
| `brand_scope` | `text[]` | array brand_name ที่ใช้ entity นี้ (`['*']` = universal, `['brand_a', 'brand_b']` = shared, single = brand-specific) |
| `brand_scope_id` | `text` | Brand id ที่เป็นเจ้าของหลัก (ถ้า single brand) |
| `brand_scope_name` | `text` | Denormalized brand name (เร็ว query) |
| `entity_lifecycle` | `text` | สถานะ: 'active' / 'deprecated' / 'merged' / 'pending_review' (Bible Part 7 SKOS governance) |
| `programmatic_eligible` | `boolean DEFAULT false` | true = ใช้สร้าง Type C local programmatic pages ได้ (Bible Part 4.5) |
| `wikipedia_url` | `text` | Wikipedia URL (canonical English version) |
| `wikidata_id` | `text` | Wikidata Q-number (เช่น `Q422983`) |
| `icd_10_code` | `text` | ICD-10 code (สำหรับ MedicalCondition) |
| `mesh_id` | `text` | MeSH ID (Medical Subject Headings) |
| `snomed_id` | `text` | SNOMED CT ID (clinical terminology) |
| `cas_number` | `text` | CAS Registry Number (สำหรับ chemical substances/ingredients) |
| `applicable_verticals` | `text[]` | array verticals ที่ entity ใช้ได้: `['healthcare', 'aesthetic', 'wellness']` |
| `competing_entities` | `text` | Comma-separated entity_fingerprints ที่แข่งกัน (cannibalization signal) |
| `related_entities_fps` | `text[]` | ⚠️ **Legacy field** — Use `seo_entity_relationships` with typed `edge_type` (10 controlled values, Bible Part 2.7). Kept for backward compatibility. Generic relationship hints |
| `entity_authority_score` | `numeric` | EYWA Scoring v1.0 — 0-100 (Bible Part 27.2.1). Composite of: internal coverage (20%), edge centrality (15%), citation density (20%), search authority (15%), external authority via DataForSEO (15%), AI visibility (15%). Computed nightly |
| `entity_authority_breakdown` | `jsonb` | Factor-by-factor breakdown for transparency: `{internal_coverage, edge_centrality, citation_density, search_authority, external_authority, ai_visibility}` each 0-100 |
| `entity_authority_formula_version` | `text DEFAULT 'v1.0'` | Tracks which formula version was used to compute the score (for backward compatibility) |
| `entity_authority_computed_at` | `timestamptz` | When score was last computed |
| `entity_freshness_score` | `numeric` | EYWA Scoring v1.0 — 0.0-1.0 (Bible Part 27.2.2). Decay curve based on max(last_modified) of anchored pages |
| `entity_completeness_score` | `numeric` | EYWA Scoring v1.0 — 0.0-1.0 (Bible Part 27.2.3). Pct of recommended fields populated |
| `ai_entity_summary` | `text` | AI-generated 2-3 sentence summary สำหรับ AI citation |
| `entity_description_long` | `text` | คำอธิบายเต็ม สำหรับ entity page |
| `hreflang_group` | `text` | Group identifier สำหรับ multi-language entity (เช่น `eg:niacinamide` group ที่มี TH+EN+JP versions) |
| `content_gap_flag` | `boolean DEFAULT false` | true = ระบบ flag ว่ายังไม่มี content แม้จะ priority เพียงพอ |
| `last_graph_update` | `timestamptz` | Timestamp อัพเดท graph relationship ล่าสุด |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_id` | `text` | Notion page ID |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_entity_fp (entity_fingerprint);
INDEX idx_entity_type (entity_type);
INDEX idx_entity_cluster (topic_cluster_id);
INDEX idx_entity_lifecycle (entity_lifecycle) WHERE entity_lifecycle = 'active';
INDEX idx_entity_brand_scope (brand_scope) USING GIN;
INDEX idx_entity_verticals (applicable_verticals) USING GIN;
INDEX idx_entity_wikidata (wikidata_id) WHERE wikidata_id IS NOT NULL;
INDEX idx_entity_icd10 (icd_10_code) WHERE icd_10_code IS NOT NULL;
INDEX idx_entity_aliases USING GIN (to_tsvector('simple', aliases));
INDEX idx_entity_programmatic (programmatic_eligible) WHERE programmatic_eligible = true;
```

#### Used By
- **Part 2 (Conceptual Architecture)** — central knowledge graph
- **Part 2.6 (Entity Genesis Protocol)** — entity creation methodology
- **Part 2.7 (Edge Vocabulary)** — `seo_entity_relationships` references entity_fingerprint
- **Part 7 (SKOS Taxonomy)** — entity_lifecycle governance
- **Part 14 (Vertical Profiles)** — applicable_verticals filtering
- **Part 25.3 (CPT Spec)** — entity_type drives WordPress CPT mapping
- **Part 26.3 (Schema Pipeline Layer 1)** — entity_type → schema.org type
- **seo_entity_relationships** — typed edges (FK from + to)
- **seo_website_page_master.primary_entity_fp** — page anchored to entity
- **seo_entity_embeddings** — vector embeddings reference entity via source_fingerprint
- Extension tables (Group 9): entity_ingredients, entity_devices, entity_procedures

---

### 4.2 `seo_topic_cluster_master`

> **Purpose:** Hub-and-spoke topic clusters — กำหนด pillar (primary entity) + supporting entities ตาม pillar-cluster ratio 8-25 (Bible Part 3 / Part 5)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Bible Reference:** Part 3 (Neural Authority), Part 5 (Schema), Part 7 (SKOS)  
> **Volume:** ~30-200 clusters per brand portfolio

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `cluster_id` | `text UNIQUE` | Natural cluster ID (e.g., `cluster:peri_implantitis`) |
| `cluster_name` | `text` | Display name |
| `cluster_slug` | `text` | URL slug |
| `pillar_entity_fp` | `text FK→entity_graph.entity_fingerprint` | Pillar entity (cluster head) |
| `pillar_page_fp` | `text FK→page_master.page_fingerprint` | Pillar page (Layer 4 typically) |
| `cluster_depth` | `integer` | Depth in cluster hierarchy (0=root, 1=child, ...) |
| `parent_cluster_id` | `text` | FK เชิง self-reference สำหรับ nested clusters |
| `brand_scope` | `text[]` | array brand_name ที่ใช้ cluster นี้ |
| `vertical_family` | `text` | 'healthcare' / 'media' / 'wellness' / 'mixed' |
| `cluster_authority_score` | `numeric` | Aggregate authority (computed from member pages) |
| `supporting_pages_count` | `integer` | จำนวน supporting pages (computed — should be 8-25 per Bible) |
| `cluster_health_status` | `text` | 'healthy' (8-25 supporting) / 'undersized' (<8) / 'oversized' (>25 — should split) |
| `lifecycle_state` | `text DEFAULT 'active'` | 'planning' / 'active' / 'maintenance' / 'archived' |
| `funnel_distribution` | `jsonb` | Distribution: `{"awareness": N, "consideration": N, "decision": N, "retention": N}` |
| `total_search_volume` | `integer` | Aggregate keyword search volume (computed) |
| `cluster_owner_author_id` | `uuid FK→authors_reviewers.id` | Designated owner/maintainer |
| `last_review_at` | `timestamptz` | Last cluster health review |
| `next_review_due_at` | `timestamptz` | Next scheduled review |
| `description` | `text` | Cluster strategy description |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_id` | `text` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_cluster_id (cluster_id);
INDEX idx_cluster_pillar_entity (pillar_entity_fp);
INDEX idx_cluster_lifecycle (lifecycle_state) WHERE lifecycle_state = 'active';
INDEX idx_cluster_health (cluster_health_status);
INDEX idx_cluster_brand_scope (brand_scope) USING GIN;

-- Computed view for cluster health
-- CREATE VIEW v_cluster_health AS SELECT cluster_id, cluster_health_status, supporting_pages_count, ...
```

#### Used By
- **Part 3 (Neural Authority)** — cluster-based authority architecture
- **Part 5 (Database)** — pillar-cluster ratio enforcement
- **seo_website_page_master.cluster_id** — pages belong to clusters
- **seo_entity_graph.topic_cluster_id** — entities belong to clusters

---

### 4.3 `seo_citations`

> **Purpose:** Master ของแหล่งอ้างอิง — peer-reviewed, guidelines, gov, textbook, hospital data — พร้อม Evidence Tier (Bible Part 23.1) สำหรับ E-E-A-T และ AI citation weighting  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S  
> **Bible Reference:** Part 23.1 (Citation Tier System), Part 6 (Pattern A-F Citables), Part 13 (LLMO E-E-A-T)  
> **Volume:** ~500-3000 citations per brand portfolio

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `citation_fingerprint` | `text UNIQUE` | Natural ID (e.g., `cite:pubmed:12345678` or `cite:guideline:aad_2024_melasma`) |
| `citation_type` | `text` | 'external_journal' / 'systematic_review' / 'rct' / 'guideline' / 'gov_health' / 'textbook' / 'hospital_data' / 'expert_consensus' |
| `evidence_tier` | `integer` | 1-6 hierarchy (Bible Part 23.1): 1=Cochrane/Systematic Review, 2=RCT, 3=Society Guideline, 4=Government, 5=Observational, 6=Textbook/Expert |
| `schema_evidence_level` | `text` | Maps to schema:MedicalEvidenceLevel: 'EvidenceLevelA' / 'EvidenceLevelB' / 'EvidenceLevelC' |
| `title` | `text` | ชื่อบทความ/แหล่ง (full title) |
| `authors` | `text[]` | array รายชื่อผู้เขียน |
| `published_year` | `integer` | ปีที่เผยแพร่ |
| `published_date` | `date` | วันที่ specific (ถ้ามี) |
| `journal_name` | `text` | Journal/publisher name |
| `volume` | `text` | Journal volume |
| `issue` | `text` | Journal issue |
| `pages` | `text` | Page range |
| `url` | `text` | URL ของแหล่ง (NULL ถ้าเป็น textbook/no online) |
| `pubmed_id` | `text` | PMID (Pubmed identifier) |
| `pmc_id` | `text` | PMC identifier (free full-text) |
| `doi` | `text` | Digital Object Identifier |
| `language` | `text DEFAULT 'en'` | ภาษาของ citation |
| `country` | `text` | ประเทศต้นทาง (สำหรับ gov citations) |
| `citation_freshness_status` | `text` | Auto-computed: 'fresh' / 'aging' / 'stale' (per tier-specific rules in Bible Part 23.1) |
| `freshness_threshold_years` | `integer` | Tier-specific freshness threshold (Tier 1=5y, Tier 2=7y, Tier 3=track latest) |
| `last_freshness_check_at` | `timestamptz` | Timestamp เช็ค freshness ครั้งล่าสุด |
| `conflict_of_interest_disclosed` | `boolean DEFAULT false` | true = มี COI disclosure ใน citation (Bible Part 23.1) |
| `conflict_of_interest_text` | `text` | COI description ถ้ามี |
| `funding_source` | `text` | แหล่งเงินทุนที่สนับสนุนงานวิจัย |
| `open_access` | `boolean` | true = เข้าถึงฟรีได้ |
| `summary_for_lay_audience` | `text` | สรุปสำหรับผู้ใช้ทั่วไป (เผื่อใช้ใน Pattern F citable) |
| `key_finding` | `text` | ข้อค้นพบสำคัญ (1 ประโยค สำหรับ citable extraction) |
| `evidence_grade_grade` | `text` | GRADE rating: 'high' / 'moderate' / 'low' / 'very_low' (ถ้ามี) |
| `usage_count` | `integer DEFAULT 0` | จำนวนหน้าที่ cite citation นี้ (computed via page_citations) |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_id` | `text` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_citations_fp (citation_fingerprint);
INDEX idx_citations_type (citation_type);
INDEX idx_citations_tier (evidence_tier);
INDEX idx_citations_year (published_year DESC);
INDEX idx_citations_freshness (citation_freshness_status);
INDEX idx_citations_pubmed (pubmed_id) WHERE pubmed_id IS NOT NULL;
INDEX idx_citations_doi (doi) WHERE doi IS NOT NULL;

CONSTRAINT valid_evidence_tier CHECK (evidence_tier BETWEEN 1 AND 6);
CONSTRAINT valid_evidence_level CHECK (schema_evidence_level IN ('EvidenceLevelA','EvidenceLevelB','EvidenceLevelC') OR schema_evidence_level IS NULL);
```

#### Used By
- **Part 23.1 (Citation Tier System)** — evidence hierarchy implementation
- **Part 6 (Content Standard)** — Pattern F (Evidence-Level citable)
- **Part 13 (LLMO E-E-A-T)** — citation richness signal
- **seo_page_citations** — junction with pages
- **Part 23.4 (Editorial Review)** — Stage 1 medical review checks evidence tier

---

### 4.4 `seo_page_citations`

> **Purpose:** Junction table — page อ้างอิง citation อะไรบ้าง พร้อม weight และ context  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S (simple relation, not rich junction)  
> **Bible Reference:** Part 23.1, Part 6 (citable patterns)  
> **Volume:** ~3-10 citations per page × total pages

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `page_id` | `uuid FK→page_master.id` | Page ที่ cite |
| `citation_id` | `uuid FK→seo_citations.id` | Citation ที่ถูก cite |
| `citation_context` | `text` | Section ในหน้าที่ cite (เช่น 'introduction' / 'mechanism' / 'efficacy' / 'safety') |
| `citation_pattern` | `text` | Pattern ที่ใช้: 'A' / 'B' / 'C' / 'D' / 'E' / 'F' (Bible Part 6) |
| `citation_position` | `integer` | ลำดับการอ้างใน page (สำหรับ numbered references) |
| `inline_text` | `text` | ข้อความที่ทำหน้าที่เชื่อมกับ citation (excerpt) |
| `is_primary_evidence` | `boolean DEFAULT false` | true = citation นี้คือหลักฐานหลักของ claim ในหน้า |
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

#### Used By
- **Part 6 (Content Standard)** — citable pattern tracking
- **Part 20 KPI #3 (E-E-A-T Coverage)** — % pages with reviewer + citations
- **Part 23.4 (Editorial Review)** — Stage 1 validates citations

---

### 4.5 `seo_entity_relationships`

> **Purpose:** Junction table for **typed relationship edges** between entities — replaces generic `related_entities_fps[]` array. Implements 10 controlled edge types (Bible Part 2.7) that drive Schema knowledge graph generation, related-content blocks, and AI knowledge graph rendering  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S (Notion DB "Entity Relationships" master ↔ Supabase mirror)  
> **Bible Reference:** Part 2.7 (Edge Vocabulary), Part 25.5 (ACF Relationships), Part 26.4 (Edge → Schema Mapping)  
> **Volume:** ~3-10x entity_graph row count (typical: 1500-15000 rows)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `from_entity_fp` | `text NOT NULL FK` | Source entity (FK → seo_entity_graph.entity_fingerprint, ON DELETE CASCADE) |
| `to_entity_fp` | `text NOT NULL FK` | Target entity (FK → seo_entity_graph.entity_fingerprint, ON DELETE CASCADE) |
| `edge_type` | `text NOT NULL` | Edge type — controlled vocabulary (14 enum values for 10 logical edges + inverses): `parent_of` / `child_of` / `subtype_of` / `treats` / `treated_by` / `symptom_of` / `uses` / `used_by` / `alternative_to` / `part_of` / `contains` / `requires_assessment` / `evidenced_by` / `related_to` (Bible Part 2.7.2) |
| `edge_strength` | `numeric DEFAULT 1.0` | EYWA Scoring v1.0 — 0.0-1.0 (Bible Part 27.3.1). Default 1.0, reduced based on edge_note modifiers (off-label=0.7, experimental=0.5) + edge_type weight + citation backing. Drives related content ranking + schema graph priority |
| `edge_note` | `text` | Optional metadata: `"off-label"` for treats edges, `"comorbidity"` for related_to edges, `"synergy"` for ingredient edges, etc. |
| `bidirectional_synced` | `boolean DEFAULT false` | true = inverse edge auto-inserted (e.g., when 'parent_of' added, 'child_of' inverse already exists) |
| `edge_evidence_score` | `numeric` | EYWA Scoring v1.0 — 0.0-1.0 (Bible Part 27.3.2). Computed from supporting citation count + tier average. Used for ranking related content + AI knowledge graph weighting |
| `edge_evidence_breakdown` | `jsonb` | Citation count + avg tier breakdown for transparency |
| `brand_scope` | `text[] DEFAULT '{*}'` | Brand scoping — same convention as entity_graph. `['*']` = universal edge, `['vth-biodent']` = brand-specific edge |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);

-- Foreign keys with cascade
FOREIGN KEY (from_entity_fp) REFERENCES seo_entity_graph(entity_fingerprint) ON DELETE CASCADE;
FOREIGN KEY (to_entity_fp) REFERENCES seo_entity_graph(entity_fingerprint) ON DELETE CASCADE;

-- Edge type controlled vocabulary
CHECK (edge_type IN (
  'parent_of', 'child_of', 'subtype_of',
  'treats', 'treated_by', 'symptom_of',
  'uses', 'used_by', 'alternative_to',
  'part_of', 'contains', 'requires_assessment',
  'evidenced_by', 'related_to'
));

-- Prevent self-loops + duplicate edges
CHECK (from_entity_fp <> to_entity_fp);
UNIQUE (from_entity_fp, edge_type, to_entity_fp);

-- Performance indexes
INDEX idx_edge_from (from_entity_fp);
INDEX idx_edge_to (to_entity_fp);
INDEX idx_edge_type (edge_type);
INDEX idx_edge_brand_scope (brand_scope) USING GIN;
INDEX idx_edge_paired (from_entity_fp, edge_type, to_entity_fp);
```

#### Triggers (Required)

```sql
-- Auto-sync paired/undirected edges
-- When 'parent_of' added → auto-insert 'child_of' inverse
-- When 'alternative_to' added → auto-insert reverse direction
CREATE TRIGGER trg_sync_paired_edges
  AFTER INSERT ON seo_entity_relationships
  FOR EACH ROW
  EXECUTE FUNCTION fn_sync_paired_edge_inverse();

-- Cycle detection for hierarchical edges (parent_of, subtype_of, part_of)
CREATE TRIGGER trg_prevent_edge_cycles
  BEFORE INSERT ON seo_entity_relationships
  FOR EACH ROW
  WHEN (NEW.edge_type IN ('parent_of', 'subtype_of', 'part_of'))
  EXECUTE FUNCTION fn_check_edge_no_cycle();
```

#### Migration from Legacy Fields

```sql
-- v1.1 Migration — populate from deprecated entity_graph fields
-- Step 1: Migrate parent_entity_fp → child_of edges
INSERT INTO seo_entity_relationships (from_entity_fp, edge_type, to_entity_fp)
SELECT entity_fingerprint, 'child_of', parent_entity_fp
FROM seo_entity_graph
WHERE parent_entity_fp IS NOT NULL
ON CONFLICT (from_entity_fp, edge_type, to_entity_fp) DO NOTHING;

-- Step 2: Migrate related_entities_fps[] → related_to edges (default classification)
-- Editorial team will re-classify into specific edge types over time
INSERT INTO seo_entity_relationships (from_entity_fp, edge_type, to_entity_fp)
SELECT entity_fingerprint, 'related_to', unnest(related_entities_fps)
FROM seo_entity_graph
WHERE related_entities_fps IS NOT NULL
ON CONFLICT (from_entity_fp, edge_type, to_entity_fp) DO NOTHING;
```

#### Used By
- **Bible Part 2.7** — full edge vocabulary specification (10 edge types)
- **Bible Part 8.8** — Related Section Logic (per-page-type edge priority)
- **Bible Part 25.5** — ACF eywa_relationships field group (1 ACF field per edge type)
- **Bible Part 26.4** — Schema Generation Pipeline Layer 2 (edge → JSON-LD property mapping)
- **Bible Part 4.1** — Sitemap XML internal `<link rel>` generation
- WordPress: replaces ACF `manual_related_*` fields with typed-edge queries
- AI Operations: edge graph powers entity embedding context (Group 7)

---

## 5. Group 3 — Page System (2 tables)

> **Role:** ตัวระบบหลักของ pages — page master + editorial workflow tracking  
> **Bible Reference:** Part 4 (Sitemap Architecture), Part 5 (Database), Part 9 (Page Template), Part 23.4 (Editorial Review)

### 5.1 `seo_website_page_master`

> **Purpose:** ตารางหลักของทุก page ในระบบ — กำหนด identity, layer, tier, funnel stage, schema, cluster, branch relationship, และ comprehensive SEO metadata  
> **Tier:** 1 (Critical Operational — heart of the system)  
> **Sync:** N↔S  
> **Bible Reference:** Part 3 (Neural Authority), Part 4 (Sitemap), Part 9 (Template), Part 23.4 (Editorial)  
> **Volume:** ~1,000-5,000 pages per brand portfolio  
> **Note:** Largest table by columns (~60+) — column groupings for readability

#### Schema — Core Identity

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `page_fingerprint` | `text UNIQUE` | Natural unique ID (e.g., `page:brand_a:peri_implantitis`) |
| `notion_id` | `text UNIQUE` | Notion page ID |
| `brand_id` | `text` | Brand owner (denormalized for query speed; FK to brands.brand_name) |
| `brand_name` | `text` | Brand name (denormalized) |
| `page_name` | `text` | Page name (working title) |
| `slug` | `text` | URL slug |
| `canonical_url` | `text` | Canonical URL (full path) |
| `redirect_target` | `text` | Redirect target if page is redirect |
| `status` | `text` | 'draft' / 'in_review' / 'active' / 'archived' / 'redirected' |

#### Schema — Neural Authority Architecture (Bible Part 3)

| Column | Type | Description |
|--------|------|-------------|
| `layer` | `integer` | 1-7 Knowledge Layer: 1=Authority, 2=Money, 3=Product, 4=Concern, 5=Knowledge, 6=Protocol, 7=Evidence |
| `node_tier` | `text` | Tier A/B/C/D — determines crawl depth allowance (Bible Part 3.4) |
| `funnel_stage` | `text` | 'awareness' / 'consideration' / 'decision' / 'retention' (Bible Part 3.5) |
| `page_intent_type` | `text` | 'informational' / 'commercial' / 'transactional' / 'navigational' |
| `page_type` | `text` | Schema-aligned type: 'pillar' / 'supporting' / 'service' / 'branch_landing' / 'doctor_profile' / 'evidence_case' / etc. |

#### Schema — Branch Relationship (Bible Part 4.5)

| Column | Type | Description |
|--------|------|-------------|
| `page_branch_relationship` | `text` | 'brand_wide' / 'branch_landing' / 'local_programmatic' / 'brand_wide_tagged' |
| `branch_id` | `uuid FK→seo_branches.id` | Branch ที่ผูก (NULL ถ้า brand_wide) |
| `branch_tags` | `text[]` | Array branch fingerprints สำหรับ Type D (brand-wide tagged — เช่น doctor pages) |
| `programmatic_template_id` | `uuid FK→seo_programmatic_templates.id` | Template ที่ใช้สร้าง (สำหรับ Type C) |

#### Schema — Sitemap & Hierarchy (Bible Part 4)

| Column | Type | Description |
|--------|------|-------------|
| `sitemap_node_id` | `text` | Hierarchical node ID (e.g., `4.2.1` per Bible Part 4.4 numbering) |
| `sitemap_section` | `text` | Top-level section (Home/Services/Knowledge/Cases/Contact per Bible Part 4.2) |
| `parent_page_fp` | `text` | Parent page fingerprint (for hierarchy) |
| `parent_page_name` | `text` | Denormalized parent name |
| `crawl_depth` | `numeric` | Computed click depth from homepage |
| `cluster_id` | `text FK→topic_cluster_master.cluster_id` | Topic cluster |

#### Schema — Knowledge Graph Linkage

| Column | Type | Description |
|--------|------|-------------|
| `primary_entity_fp` | `text FK→entity_graph.entity_fingerprint` | Primary entity ที่ page เกี่ยวกับ |
| `primary_entity_name` | `text` | Denormalized entity name |
| `related_entities_fps` | `text[]` | Related entities mentioned in content |
| `target_keyword_fp` | `text FK→keywords_master.fingerprint` | Primary target keyword |
| `semantic_keywords_fps` | `text[]` | Secondary semantic keywords |

#### Schema — SEO Metadata

| Column | Type | Description |
|--------|------|-------------|
| `seo_title` | `text` | Title tag (≤60 chars target) |
| `meta_description` | `text` | Meta description (≤160 chars target) |
| `schema_markup_type` | `text[]` | Array Schema.org types ที่ใช้ (e.g., `['MedicalCondition', 'FAQPage']`) |
| `content_format` | `text[]` | Array formats (e.g., `['article', 'video', 'infographic']`) |
| `auto_suggested_word_count_target` | `numeric` | Recommended word count (computed from competitors + intent) |
| `note_brief` | `text` | Editorial brief สำหรับ writer |
| `suggested_page_content` | `text` | AI-suggested content outline |

#### Schema — Internal Linking

| Column | Type | Description |
|--------|------|-------------|
| `link_role` | `text` | Role in link graph: 'hub' / 'spoke' / 'satellite' |
| `link_priority` | `text` | Internal link priority weight |
| `priority` | `text` | Overall page priority |
| `anchor_strategy_mode` | `text` | Anchor text strategy (Bible Part 3.6 anchor distribution) |
| `planned_outbound_fps` | `text[]` | Array page fingerprints we'll link out to |
| `planned_outbound_external_links` | `text` | External outbound links plan |
| `required_min_inbound` | `numeric` | Minimum inbound link count for tier health |
| `required_min_outbound` | `numeric` | Minimum outbound link count |

#### Schema — Cross-Brand Sharing (Bible Part 10)

| Column | Type | Description |
|--------|------|-------------|
| `cross_brand_role` | `text` | Role in cross-brand network: 'origin' / 'consumer' / 'shared' |
| `cross_brand_link_type` | `text` | 'reference' / 'topic_link' / 'authority_signal' |
| `cross_brand_links_fps` | `text[]` | Array cross-brand page fingerprints |
| `cross_brand_approved` | `boolean DEFAULT false` | Approved for cross-brand sharing |
| `cross_brand_justification` | `text` | Rationale for cross-brand approval |
| `brand_authority_focus` | `text` | Which brand's authority this page primarily reinforces |
| `wpml_translation_id` | `text` | WPML's element_id linking translations together (Bible Part 28.5). Same value across translated versions of same page |
| `is_translation_of` | `uuid` | FK to seo_website_page_master.id of original page (NULL if this IS the original) |
| `translation_status` | `text` | Enum: `original` / `pending_translation` / `machine_translated` / `human_reviewed` / `outdated` |
| `translation_completeness` | `numeric` | 0.0-1.0 (% of translatable fields populated). Used for translation pipeline visibility |
| `cross_brand_references` | `jsonb DEFAULT '[]'` | **Federation feature** (Bible Section 4.12) — tracks lifecycle ของ external links ออก-ไปแบรนด์ในเครือ. Array of `{ref_id, target_brand_id, target_page_concept, target_keywords[], target_url, anchor_text, anchor_position, status, last_checked_at, resolved_target_page_id, broken_since, notes}`. Status enum: `pending`/`draft_at_target`/`live`/`broken`/`manual_link`. n8n flow auto-resolves every 6h, alerts on status changes |

#### Schema — Multi-Language (Bible WPML integration)

| Column | Type | Description |
|--------|------|-------------|
| `page_language` | `text DEFAULT 'th'` | Page language (ISO code) |
| `translation_status` | `text` | 'original' / 'translated' / 'pending_translation' / 'outdated_translation' |
| `translations_versions_fps` | `text[]` | Array fingerprints of translations |
| `source_translation_fp` | `text` | Source page fingerprint (if this is a translation) |
| `translation_due_date` | `timestamptz` | Translation deadline |
| `hreflang_validated` | `boolean DEFAULT false` | Hreflang setup validated |
| `wpml_page_id` | `numeric` | WordPress page ID via WPML |

#### Schema — Editorial & Quality

| Column | Type | Description |
|--------|------|-------------|
| `reviewer_id` | `uuid FK→authors_reviewers.id` | Medical reviewer (Bible Part 23.4 Stage 1) |
| `has_medical_review` | `boolean DEFAULT false` | true = passed Stage 1 medical accuracy review |
| `flag_review` | `text` | Review flags (e.g., 'pending_medical_review' / 'pending_legal_review' / 'cleared') |
| `review_cycle` | `text` | Review cadence: 'quarterly' / 'semi_annual' / 'annual' |
| `published_date` | `timestamptz` | Publication date |
| `last_content_review_at` | `timestamptz` | Last content review timestamp (Bible Part 19 — freshness) |
| `confidence_score` | `numeric` | Page-level confidence score (computed) |
| `structurally_complete` | `boolean DEFAULT false` | true = all required Tier 1 fields filled |
| `schema_type_validated` | `boolean DEFAULT false` | true = schema markup validated against rich-results test |

#### Schema — Indexing & Robots

| Column | Type | Description |
|--------|------|-------------|
| `robots_directive` | `text` | 'index,follow' / 'noindex,follow' / 'noindex,nofollow' |
| `in_xml_sitemap` | `boolean DEFAULT false` | Include in XML sitemap |
| `is_source_page` | `boolean DEFAULT false` | true = original source (not derivative) |
| `strategic_page` | `boolean DEFAULT false` | true = strategic priority page |

#### Schema — Performance Rollups (computed)

| Column | Type | Description |
|--------|------|-------------|
| `traffic_30d` | `integer` | 30-day organic traffic (rollup from daily_logs) |
| `keyword_rank_avg_30d` | `numeric` | Avg ranking in 30 days |
| `internal_inbound_count` | `numeric` | Internal links pointing to this page |
| `is_orphan` | `boolean` | true = no internal inbound links |

#### Schema — Versioning & Sync

| Column | Type | Description |
|--------|------|-------------|
| `snapshot_version` | `text` | Content version identifier (sequential or semantic) |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_page_fp (page_fingerprint);
UNIQUE INDEX idx_page_notion_id (notion_id) WHERE notion_id IS NOT NULL;
UNIQUE INDEX idx_page_canonical (canonical_url) WHERE status = 'active';
INDEX idx_page_brand (brand_id);
INDEX idx_page_layer (layer);
INDEX idx_page_tier (node_tier);
INDEX idx_page_status (status) WHERE status = 'active';
INDEX idx_page_cluster (cluster_id);
INDEX idx_page_entity (primary_entity_fp);
INDEX idx_page_branch (branch_id) WHERE branch_id IS NOT NULL;
INDEX idx_page_branch_tags (branch_tags) USING GIN;
INDEX idx_page_keywords (semantic_keywords_fps) USING GIN;
INDEX idx_page_orphan (is_orphan) WHERE is_orphan = true;
INDEX idx_page_review_due (last_content_review_at) WHERE status = 'active';

CONSTRAINT valid_layer CHECK (layer BETWEEN 1 AND 7);
CONSTRAINT valid_tier CHECK (node_tier IN ('A','B','C','D'));
CONSTRAINT valid_branch_relationship CHECK (
  page_branch_relationship IN ('brand_wide','branch_landing','local_programmatic','brand_wide_tagged')
);
```

#### Used By
- **Part 3 (Neural Authority Architecture)** — layer + tier + funnel definition
- **Part 4 (Sitemap)** — sitemap_node_id hierarchy + page types A/B/C/D
- **Part 9 (Page Template)** — template selection based on page_type
- **Part 19 (Data Quality)** — completeness/consistency/freshness measurement
- **Part 20 (KPIs)** — KPI #1, #2, #3, #6 all derive from this table
- **Part 23.4 (Editorial Review)** — workflow tracking via seo_editorial_reviews
- All other tables FK to this table or are FK'd from this table

---

### 5.2 `seo_editorial_reviews`

> **Purpose:** Track 5-stage editorial review workflow per page (Medical → Editorial → SEO/LLMO → Legal → Final Publish) with SLA tracking  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S (workflow UI in Notion ↔ analytics in Supabase)  
> **Bible Reference:** Part 23.4 (Multi-Stage Editorial Review)  
> **Volume:** ~5 records per page (one per stage) × active pages

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `page_id` | `uuid FK→page_master.id NOT NULL` | Page being reviewed |
| `brand_id` | `uuid` | Denormalized brand (for filtering) |
| `stage` | `integer NOT NULL` | 1-5 stage number |
| `stage_name` | `text NOT NULL` | 'medical_accuracy' / 'editorial' / 'seo_llmo' / 'legal' / 'final_publish' |
| `reviewer_id` | `uuid FK→authors_reviewers.id` | Assigned reviewer |
| `status` | `text NOT NULL` | 'in_progress' / 'approved' / 'rejected' / 'revisions_requested' |
| `started_at` | `timestamptz` | When this stage started |
| `due_at` | `timestamptz` | SLA deadline |
| `reviewed_at` | `timestamptz DEFAULT now()` | When status was set |
| `sla_met` | `boolean` | true = completed within SLA |
| `checklist_completed` | `jsonb` | Per-item ☐/☑ tracking (specific to stage) |
| `notes` | `text` | Reviewer notes |
| `blocking_issues` | `text[]` | If rejected/revisions: list of issues |
| `revision_count` | `integer DEFAULT 0` | Number of revisions cycled |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
INDEX idx_editorial_reviews_page (page_id, stage);
INDEX idx_editorial_reviews_status (status, due_at) WHERE status = 'in_progress';
INDEX idx_editorial_reviews_reviewer (reviewer_id) WHERE status = 'in_progress';

CONSTRAINT valid_stage CHECK (stage BETWEEN 1 AND 5);
CONSTRAINT valid_status CHECK (status IN ('in_progress', 'approved', 'rejected', 'revisions_requested'));
CONSTRAINT valid_stage_name CHECK (stage_name IN ('medical_accuracy', 'editorial', 'seo_llmo', 'legal', 'final_publish'));
```

#### Used By
- **Part 23.4 (Multi-Stage Editorial Review)** — workflow source of truth
- **Part 19 (Data Quality)** — stage completion as quality gate
- **Part 20 (KPIs)** — KPI #1, #3 (citable density + E-E-A-T) gate at Stage 3 + Stage 1

---

## 6. Group 4 — Keyword & Search Intelligence (4 tables)

> **Role:** Master + analytics + competitive landscape + voice search สำหรับ keyword intelligence  
> **Bible Reference:** Part 13 (LLMO Execution Playbook), Part 20 (KPIs)

### 6.1 `seo_x_ads_keywords_contextual_master`

> **Purpose:** Master ของทุก keyword ที่ระบบ track — กำหนด search intent, painpoint, funnel stage, anxiety level และ contextual metadata สำหรับ content planning  
> **Tier:** 1 (Critical Operational)  
> **Sync:** N↔S (Notion master ↔ Supabase mirror)  
> **Bible Reference:** Part 3 (Funnel/Tier), Part 13 (LLMO), Part 14 (Vertical Profiles)  
> **Volume:** ~5,000-15,000 keywords per brand portfolio

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `fingerprint` | `text PK` | Natural unique ID — primary key (e.g., hash of brand+keyword+market) |
| `notion_id` | `text` | Notion page ID สำหรับ sync |
| `keyword` | `text` | คีย์เวิร์ดในรูปแบบ canonical (clean — ตัด comma/special chars แล้ว) |
| `brand` | `text FK→brands.brand_name` | Brand ที่ track keyword นี้ |
| `target_market` | `text` | ตลาดเป้าหมาย (เช่น 'TH-bangkok', 'TH-nationwide') |
| `target_language` | `text` | ภาษา keyword (เช่น 'th', 'en') |
| `wpml_code` | `text` | WPML language code (สำหรับ translation linking) |
| `translation_group` | `text` | Group ID ของ translation set (keyword เดียวกันข้ามภาษา) |
| **— Intent & Funnel —** | | |
| `search_intent` | `text` | Main intent: 'informational' / 'navigational' / 'commercial' / 'transactional' |
| `ads_intent` | `text` | Intent สำหรับ Ads strategy (อาจต่างจาก SEO) |
| `funnel_stage` | `text` | 'awareness' / 'consideration' / 'decision' / 'retention' (Bible Part 3.5) |
| `anxiety_level` | `text` | 'low' / 'medium' / 'high' — รุนแรงของความกังวลของผู้ใช้ (medical context) |
| `keyword_painpoint` | `text` | Painpoint ที่ keyword สะท้อน (1-2 sentences) |
| `keyword_core_insight` | `text` | Core insight จาก analyst — ทำไม keyword นี้สำคัญ |
| `keyword_use_as` | `text` | บทบาท: 'pillar_target' / 'supporting' / 'long_tail' / 'ad_only' / 'monitoring_only' |
| **— Difficulty & Strategy —** | | |
| `qualitative_kd` | `text` | Qualitative KD label (เช่น 'easy' / 'medium' / 'hard') |
| `qualitative_kd_number` | `numeric` | Numeric KD (0-100, qualitative scoring) |
| `kd_reasoning` | `text` | Reasoning behind KD assessment |
| `predicted_serp_features` | `text` | Predicted SERP features (FAQ, Featured Snippet, etc.) |
| `note` | `text` | Free-text editorial note |
| **— Entity Linkage —** | | |
| `primary_entity_fp` | `text FK→entity_graph.entity_fingerprint` | Primary entity ที่ keyword นี้ map ถึง |
| `primary_entity_name` | `text` | Denormalized entity name |
| **— Notion Tier System —** | | |
| `notion_tier` | `text DEFAULT 'universe'` | Tier label ที่ Notion ใช้: 'universe' / 'galaxy' / 'star' / 'planet' / 'satellite' |
| `notion_tier_updated_at` | `timestamptz DEFAULT now()` | Timestamp อัพเดท tier ล่าสุด |
| `satellite_data_updated_at` | `timestamptz DEFAULT now()` | Timestamp อัพเดท satellite-tier data |
| **— Sync & Lifecycle —** | | |
| `keyword_contextual_ready_last_update` | `timestamptz` | Timestamp เมื่อ contextual analysis เสร็จ (พร้อมใช้งาน) |
| `gsc_last_update` | `timestamptz` | Timestamp ดึง GSC data ครั้งล่าสุด |
| `ga4_last_update` | `timestamptz` | Timestamp ดึง GA4 data ครั้งล่าสุด |
| `last_checked_at` | `timestamptz` | Last general check |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (fingerprint);
INDEX idx_keywords_brand (brand);
INDEX idx_keywords_intent (search_intent);
INDEX idx_keywords_funnel (funnel_stage);
INDEX idx_keywords_tier (notion_tier);
INDEX idx_keywords_entity (primary_entity_fp);
INDEX idx_keywords_translation_group (translation_group) WHERE translation_group IS NOT NULL;
INDEX idx_keywords_keyword_trgm USING GIN (keyword gin_trgm_ops);  -- fuzzy search

-- Foreign keys (referenced by other tables)
-- seo_x_ads_keywords_x_url_daily_logs.fingerprint → here
-- seo_x_ads_keywords_monthly_market_snapshot.fingerprint → here
-- seo_x_ads_keyword_serp_competitors.fingerprint → here
```

#### Used By
- **Part 13 (LLMO)** — keyword strategy + intent mapping
- **Part 14 (Vertical Profiles)** — vertical-specific keyword sets
- **seo_website_page_master.target_keyword_fp** — page targets keyword
- All performance + market snapshot + competitor tables FK back here

---

### 6.2 `seo_x_ads_keywords_monthly_market_snapshot`

> **Purpose:** Snapshot รายเดือนของ market intelligence per keyword — volume trends, CPC, competition, momentum, seasonality (enriched by DataForSEO + n8n analytics)  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** S only (high-volume snapshot, no Notion mirror)  
> **Bible Reference:** Part 13 (LLMO), Part 20 (KPIs)  
> **Volume:** ~10,000+ records/month (one per active keyword per month)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `fingerprint` | `text FK→keywords_master.fingerprint` | Keyword reference |
| `keyword` | `text` | Denormalized keyword (clean format) |
| `brand` | `text` | Denormalized brand |
| `snapshot_date` | `timestamptz` | วันที่ snapshot |
| **— Volume Metrics —** | | |
| `ads_volume_history` | `jsonb` | Array รายเดือน 48 เดือน [{month, year, volume}, ...] |
| `volume_avg_48m` | `integer` | Volume เฉลี่ย 48 เดือน — บอก market size ระยะยาว (>1000=Mass, <100=Niche) |
| `volume_recent_12m` | `integer` | Volume เฉลี่ย 12 เดือนล่าสุด — ภาพรวมปีปัจจุบัน |
| `volume_recent_6m` | `integer` | Volume เฉลี่ย 6 เดือนล่าสุด |
| `volume_recent_3m` | `integer` | Volume เฉลี่ย 3 เดือนล่าสุด — ความฮิต ณ ปัจจุบัน (Real-time demand) |
| `volume_max_48m` | `integer` | Peak volume — เพดานสูงสุดของตลาด |
| `volume_min_48m` | `integer` | Floor volume (ที่ไม่ใช่ 0) — จุดต่ำสุด |
| `volume_index_norm` | `integer` | Avg/Max × 100 — ใกล้ 100 = วิ่งใกล้พีคตลอด (Demand แข็งแรง) |
| `demand_floor_percentile` | `numeric` | % เดือนที่ volume < 10 — ค่าสูง = ตลาดร้างบ่อย |
| **— CPC & Competition —** | | |
| `cpc_low_bid` | `numeric` | CPC ต่ำสุด (บาท) |
| `cpc_high_bid` | `numeric` | CPC สูงสุด (บาท) |
| `cpc_avg` | `numeric` | CPC เฉลี่ย — ยิ่งแพง = Conversion สูง (คู่แข่งยอมจ่าย) |
| `competition_index` | `integer` | Competition 0-100 จาก API — 100=Red Ocean |
| `competition_level` | `text` | Text: 'LOW' (0-33) / 'MEDIUM' (34-66) / 'HIGH' (>66) |
| `keyword_difficulty` | `integer` | DataForSEO Labs KD (0-100) |
| **— Volatility & Trend —** | | |
| `volatility_raw` | `numeric` | Standard Deviation ของ Volume 48 เดือน |
| `volatility_cv` | `numeric` | Coefficient of Variation (StdDev/Mean) — capped at 9.9999. >0.5 = เหวี่ยงแรงคาดเดายาก |
| `trend_slope_6m_raw` | `numeric` | Linear slope 6 เดือน (raw value) |
| `trend_slope_12m_raw` | `numeric` | Linear slope 12 เดือน — + = ขาขึ้น, - = ขาลง |
| `trend_slope_6m_status` | `varchar` | Status 6m: 'Rising' / 'Declining' / 'Stable' |
| `trend_slope_12m_status` | `varchar` | Status 1y: Rising (>5% growth) / Declining (>5% drop) / Stable |
| `momentum_index` | `integer` | 0-100 — Slope_6m(60%) + Slope_12m(30%) + Recent_vol(10%). สูง = Hot Trend |
| `forecast_slope` | `numeric` | Predicted future slope |
| **— Seasonality —** | | |
| `seasonality_strength` | `numeric` | 0-1 — yearly variance / total variance. สูง = ฮิตเป็นพักๆ |
| `seasonality_score` | `integer` | 0-100 normalized seasonality score |
| `stability_index` | `integer` | 0-100 — (1-Volatility)×0.7 + Frequency×0.3. สูง = ตลาดนิ่ง รายได้สม่ำเสมอ |
| **— Auto-Suggestions Intelligence —** | | |
| `auto_suggestions_raw` | `jsonb` | Array ของ Google Autocomplete suggestions |
| `auto_suggestions_count` | `integer` | จำนวน suggestions — เยอะ = สนใจหลากแง่มุม |
| `auto_brand_suggestions_pct` | `numeric` | % suggestions ที่มีชื่อ brand เรา — Brand Awareness signal |
| `auto_entropy` | `numeric` | Shannon Entropy — สูง = ตลาดสับสน/กว้าง, ต่ำ = ตลาดชัดเจน |
| `auto_depth_score` | `numeric` | Mean word count ของ suggestions — สูง = Long-tail intent |
| `auto_commercial_ratio` | `numeric` | 0-100 % suggestions ที่มีคำการค้า (ราคา/ซื้อ/รีวิว/โปรโมชั่น) |
| `auto_confidence_count` | `integer` | Confidence count |
| **— Composite Scores —** | | |
| `trend_score_ads` | `integer` | 0-100 — Momentum + Seasonality. สำหรับ Ads short-term planning |
| `keyword_maturity_score` | `integer` | 0-100 — Volume + Suggestions + Stability. สูง = Evergreen — ทำ SEO กินยาว |
| `intent_confidence_score` | `integer` | 0-100 — Commercial Ratio × Entropy. ใช้ตัดสินใจยิง Ads |
| `seo_ads_priority_score` | `integer` | 🔥 0-100 — Volume(40%) + Low_Comp(35%) + Intent(25%). 90+=Must Do, <50=Ignore |
| `keyword_risk_score` | `integer` | 0-100 — Volatility + Negative_slope + Instability. สูง = เสี่ยงดอย |
| `seo_roi_proxy` | `numeric` | ROI ประเมิน (บาท/เดือน) — (Volume × CTR_2% × Conv_1% × 5000฿) / CPC |
| **— SERP Competitive Landscape —** | | |
| `avg_backlinks` | `numeric` | Avg backlinks ของ top SERP results |
| `avg_dofollow` | `numeric` | Avg dofollow backlinks |
| `avg_referring_domains` | `numeric` | Avg referring domains |
| `avg_referring_main_domains` | `numeric` | Avg referring main domains |
| `avg_backlink_rank` | `numeric` | Avg backlink rank |
| `avg_main_domain_rank` | `numeric` | Avg main domain rank |
| `se_results_count` | `bigint` | Total search results |
| `serp_features` | `jsonb` | Array ของ SERP features types ที่มี |
| **— Intent & Core —** | | |
| `foreign_intent` | `jsonb` | Array additional intents จาก DataForSEO |
| `core_keyword` | `text` | Core keyword identified |
| **— Quality —** | | |
| `data_signal_quality` | `numeric` | QA Score — ความครบถ้วนของ Volume, CPC, History — กรองข้อมูลขยะ |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_market_snap_kw_date (fingerprint, snapshot_date);
INDEX idx_market_snap_brand (brand, snapshot_date DESC);
INDEX idx_market_snap_priority (seo_ads_priority_score DESC) WHERE seo_ads_priority_score IS NOT NULL;
INDEX idx_market_snap_momentum (momentum_index DESC) WHERE momentum_index IS NOT NULL;
INDEX idx_market_snap_quality (data_signal_quality DESC);
```

#### Used By
- **Part 13 (LLMO)** — momentum-based content prioritization
- **Part 20 (KPIs)** — keyword pipeline health
- **Part 17 (n8n flows)** — DataForSEO ingestion + scoring computations
- Strategic dashboards (Part 20.5)

---

### 6.3 `seo_x_ads_keyword_serp_competitors`

> **Purpose:** SERP landscape per keyword — top competitors, Featured Snippet, AI Overview, People Also Ask, image pack, related searches  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** S only  
> **Bible Reference:** Part 13 (LLMO), Part 17 (n8n flows)  
> **Volume:** ~5,000-10,000 records (one per active keyword)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `fingerprint` | `text FK→keywords_master.fingerprint` | Keyword reference |
| `keyword` | `text` | Denormalized keyword |
| `brand` | `text` | Denormalized brand |
| `snapshot_date` | `timestamptz` | Snapshot date |
| **— Our Position —** | | |
| `actual_rank` | `integer` | อันดับจริงของเรา ใน SERP |
| `actual_url` | `text` | URL ของเราที่ติดอันดับ |
| `my_content_json` | `jsonb` | Content ของหน้าเราที่ติดอันดับ (snapshot ของ structure + key elements) |
| `my_onpage_score` | `integer` | OnPage score ของหน้าเรา |
| **— Competitors —** | | |
| `top_competitors_meta` | `jsonb` | Array meta ของ top 10 competitors: [{rank, url, domain, title, description, ...}] |
| `competitor_url_list` | `jsonb` | Array URL ของ competitors |
| `competitors_content_json` | `jsonb` | Snapshot content ของ competitor pages (structure + key elements) |
| **— SERP Features —** | | |
| `serp_features_list` | `jsonb` | Array features types: ['featured_snippet', 'people_also_ask', 'image_pack', 'video', 'map_pack', ...] |
| `featured_snippet` | `jsonb` | Featured Snippet data: {url, source, content_type, content} |
| `ai_overview_text` | `text` | Google AI Overview text (Generative SERP) |
| `paa_ai_content_json` | `jsonb` | People Also Ask + AI-generated answers |
| `people_also_ask_json` | `jsonb` | Raw PAA data |
| `related_searches` | `jsonb` | Related searches array |
| `video_domains` | `jsonb` | Domains ที่มี video ใน SERP |
| `image_pack` | `jsonb` | Image pack data |
| `total_results_count` | `bigint` | Total search results (Google's reported count) |
| **— Ads Context —** | | |
| `ads_context_json` | `jsonb` | Ads (top + bottom + shopping) context |
| `total_ads_count` | `integer DEFAULT 0` | จำนวน ads ที่แสดง |
| **— SERP Strategy & AI Analysis —** | | |
| `serp_strategy_md` | `text` | Markdown — กลยุทธ์ที่ analyst เขียนหลังดู SERP |
| `ai_analysis_json` | `jsonb` | AI-generated analysis: gap analysis, opportunity, recommended angle |
| `ai_analysis_case` | `text` | Case study label จาก AI analysis |
| `ai_analysis_date` | `timestamptz` | Timestamp ที่ AI วิเคราะห์ |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_serp_kw_date (fingerprint, snapshot_date);
INDEX idx_serp_brand (brand, snapshot_date DESC);
INDEX idx_serp_rank (actual_rank) WHERE actual_rank IS NOT NULL;
INDEX idx_serp_features_gin (serp_features_list) USING GIN;
```

#### Used By
- **Part 13 (LLMO)** — SERP feature targeting (Featured Snippet, AI Overview)
- **Part 20 (KPIs)** — Featured Snippet capture rate, AI Overview presence
- Competitive analysis dashboards
- AI Citation tracking (cross-reference with seo_llm_citations)

---

### 6.4 `seo_voice_search_queries`

> **Purpose:** Track voice search queries (long-form, conversational) ที่เกี่ยวกับ brand — สำหรับ optimize FAQ, schema:Question, และ AI Assistant integration (Siri, Alexa, Google Assistant)  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** S only  
> **Bible Reference:** Part 13.X (LLMO future), Part 23 (Medical Excellence — emergency content patterns)  
> **Volume:** ~500-3,000 voice queries per brand portfolio

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `query_fingerprint` | `text UNIQUE` | Natural unique ID |
| `brand` | `text FK→brands.brand_name` | Brand context |
| `voice_query` | `text` | Full voice query (conversational form, e.g., "อาการของโรคปริทันต์อักเสบเป็นยังไง") |
| `query_intent_type` | `text` | 'symptom_check' / 'how_to' / 'where_to' / 'price_inquiry' / 'emergency' / 'comparison' |
| `is_emergency_query` | `boolean DEFAULT false` | true = emergency context — needs immediate response patterns (Bible Part 23.2) |
| `language` | `text` | Query language code |
| `mapped_keyword_fp` | `text FK→keywords_master.fingerprint` | Mapped to text-based keyword if exists |
| `target_page_fp` | `text FK→page_master.page_fingerprint` | Page that should answer this query |
| `target_faq_block_id` | `text` | FAQ block ID within target page |
| `expected_answer_format` | `text` | 'short_answer' (≤30 words) / 'paragraph' / 'list' / 'video' |
| `current_ranking_status` | `text` | 'ranking_well' / 'ranking_poorly' / 'not_ranking' / 'unknown' |
| `assistant_seen_in` | `text[]` | Array assistants that surfaced this query: ['google_assistant', 'siri', 'alexa', 'gemini_voice'] |
| `last_observed_at` | `timestamptz` | Last timestamp this query was observed |
| `query_volume_proxy` | `integer` | Estimated volume (proxy from text equivalent + voice multiplier) |
| `priority_score` | `integer` | 0-100 priority for content optimization |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_voice_fp (query_fingerprint);
INDEX idx_voice_brand (brand);
INDEX idx_voice_emergency (is_emergency_query) WHERE is_emergency_query = true;
INDEX idx_voice_priority (priority_score DESC) WHERE priority_score IS NOT NULL;
INDEX idx_voice_target_page (target_page_fp) WHERE target_page_fp IS NOT NULL;
```

#### Used By
- **Part 13 (LLMO)** — voice + AI Assistant targeting
- **Part 23.2 (Medical Disclaimers)** — emergency_query → crisis hotline patterns
- FAQ block optimization (Part 9 Page Template)

---

## 7. Group 5 — Performance Fact Tables (2 tables)

> **Role:** Time-series performance data — daily metrics + local SEO rankings  
> **Bible Reference:** Part 5 (Performance Fact Tables architecture), Part 20 (KPIs), Part 23.5 (Core Web Vitals)

### 7.1 Architecture — Rolling + Yearly Partition Pattern

```yaml
pattern_name: Rolling Current + Yearly Archive

main_table: seo_x_ads_keywords_x_url_daily_logs
  role: Rolling current — most recent active snapshots
  retention: ~90-180 days rolling
  
yearly_partitions: logs_{YYYY}
  role: Yearly archive — long-term historical data
  pattern: New partition created automatically per year
  example_active: logs_2026 (current year)
  retention: indefinite (or per data governance policy)

rationale:
  - High-volume time-series data (~250K+ rows/year per brand)
  - Yearly partitioning enables fast queries on recent vs historical
  - PostgreSQL partition pruning optimizes WHERE snapshot_at queries
  - Allows individual year archive/cold-storage decisions

migration_strategy:
  - Records in main table older than threshold → archived to logs_{YYYY}
  - Archival job runs nightly via pg_cron or n8n scheduled flow
  - Archive job determines target year from snapshot_at timestamp
```

### 7.2 `seo_x_ads_keywords_x_url_daily_logs`

> **Purpose:** Daily snapshot per (keyword × URL) — comprehensive performance metrics from GSC, GA4, Core Web Vitals, indexing status, internal linking. Heart of the performance monitoring system  
> **Tier:** 1 (Critical Operational)  
> **Sync:** S only (high volume, no Notion mirror)  
> **Bible Reference:** Part 20 (KPIs — KPI #4, #5, #6), Part 23.5 (CWV targets)  
> **Volume:** ~90,000+ rows/year per brand portfolio

#### Schema — Identity & Time

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Composite PK with snapshot_at |
| `snapshot_at` | `timestamptz PK` | Snapshot timestamp — composite key for unique daily records |
| `fingerprint` | `text FK→keywords_master.fingerprint` | Keyword reference |
| `brand` | `text` | Denormalized brand |
| `keyword` | `text` | Denormalized keyword |
| `gsc_actual_ranking_url` | `text` | URL ที่ Google actually ranks (อาจไม่ตรง canonical) |
| `gsc_actual_ranking_url_position` | `numeric` | Position ของ URL ที่ Google เลือก |
| `gsc_canabalization_urls` | `text` | URLs อื่นในเว็บที่แข่งกันในคีย์เวิร์ดนี้ (cannibalization signal) |

#### Schema — GSC Metrics

| Column | Type | Description |
|--------|------|-------------|
| `ranking` | `numeric` | Average position ของหน้าใน SERP |
| `gsc_clicks` | `integer` | จำนวนคลิกในวันนั้น |
| `gsc_impressions` | `integer` | จำนวน impressions |
| `gsc_ctr` | `numeric` | CTR (0.0-1.0) |
| `gsc_ctr_mobile` | `numeric` | CTR mobile only |
| `gsc_ctr_desktop` | `numeric` | CTR desktop only |
| `gsc_mobile_ranking` | `numeric` | Avg position mobile |
| `gsc_desktop_ranking` | `numeric` | Avg position desktop |
| `gsc_inspection_status` | `text` | URL inspection status |
| `gsc_inspection_verdict` | `text` | Inspection verdict (PASS/FAIL/etc.) |
| `gsc_inspection_last_update` | `timestamptz` | Last inspection check |
| `gsc_last_update` | `timestamptz` | Last GSC data fetch |

#### Schema — Indexing Status

| Column | Type | Description |
|--------|------|-------------|
| `index_http_status` | `integer` | HTTP status (200/301/404/500/etc.) |
| `indexing_status` | `text` | 'indexed' / 'noindex' / 'pending' / 'error' |
| `indexing_last_update` | `timestamptz` | Last indexing check |

#### Schema — Core Web Vitals (Bible Part 23.5)

| Column | Type | Description |
|--------|------|-------------|
| `cwv_mobile_performance_score` | `numeric` | Lighthouse mobile performance (0-100) |
| `cwv_lcp_loading` | `numeric` | Largest Contentful Paint (ms) — target < 2,500ms (Layer 2: < 2,000ms) |
| `cwv_inp` | `numeric` | Interaction to Next Paint (ms) — target < 200ms (Layer 2: < 150ms) |
| `cwv_cls_stability` | `numeric` | Cumulative Layout Shift — target < 0.1 (Layer 4: < 0.05) |
| `cwv_fcp` | `numeric` | First Contentful Paint (ms) |
| `cwv_tbt` | `numeric` | Total Blocking Time (ms) |
| `cwv_ttfb` | `numeric` | Time To First Byte (ms) — target < 200ms |
| `cwv_speed_index` | `numeric` | Lighthouse Speed Index |
| `cwv_total_byte_weight` | `integer` | Total page byte size |
| `cwv_score_seo` | `numeric` | Lighthouse SEO score (0-100) |
| `cwv_score_accessibility` | `numeric` | Lighthouse a11y score (0-100) — target ≥ 95 (Bible Part 23.6) |
| `cwv_score_best_practices` | `numeric` | Lighthouse best practices score (0-100) |
| `cwv_last_update` | `timestamptz` | Last CWV measurement |

#### Schema — Page Timing (DataForSEO OnPage)

| Column | Type | Description |
|--------|------|-------------|
| `page_timing_ttfb` | `numeric` | TTFB from DataForSEO measurement |
| `page_timing_lcp` | `numeric` | LCP from DataForSEO |
| `page_timing_tti` | `numeric` | Time To Interactive |
| `page_timing_load` | `numeric` | Total page load duration |

#### Schema — On-Page Health Checks

| Column | Type | Description |
|--------|------|-------------|
| `is_https` | `boolean` | true = HTTPS (secure) |
| `no_description` | `boolean` | true = missing meta description (issue) |
| `title_too_long` | `boolean` | true = title > 60 chars (issue) |
| `high_loading_time` | `boolean` | true = load time exceeds threshold (issue) |
| `no_h1_tag` | `boolean` | true = missing H1 (issue) |
| `canonical_chains` | `boolean` | true = chained canonical (issue) |
| `has_duplicate_title` | `boolean` | true = duplicate title detected |
| `onpage_score` | `numeric` | Overall on-page score (computed) |
| `plain_text_word_count` | `numeric` | Word count of page content |
| `automated_readability_index` | `numeric` | ARI score (reading grade level) |
| `page_meta_title` | `text` | Current meta title (snapshot) |
| `page_meta_description` | `text` | Current meta description (snapshot) |

#### Schema — Internal Linking

| Column | Type | Description |
|--------|------|-------------|
| `click_depth` | `numeric` | Click depth from homepage |
| `internal_inbound_count` | `numeric` | จำนวน internal links เข้าหน้านี้ |
| `internal_outbound_count` | `numeric` | จำนวน internal links ออกจากหน้านี้ |
| `external_outbound_count` | `numeric` | จำนวน external links ออกจากหน้านี้ |
| `is_orphan` | `boolean` | true = ไม่มี internal inbound link (orphan) |
| `technical_link_last_update` | `timestamptz` | Last link analysis |

#### Schema — GA4 Metrics (Comprehensive — Organic + Total × Mobile/Desktop breakdowns)

| Pattern | Description |
|---------|-------------|
| `ga4_organic_*` (32 fields) | Organic traffic metrics: active_users, sessions, page_views, engagement_rate, engagement_time, new_users, percent_new_users, key_event, event_count, scrolled_users, scrolled_users_rate — × {mobile, desktop} variants |
| `ga4_total_*` (32 fields) | Same metrics for ALL traffic (not just organic) — × {mobile, desktop} variants |
| `ga4_last_update` | `timestamptz` Last GA4 data fetch |

> **Note:** GA4 fields ทั้งหมด ~64 columns — อ้างอิงจาก GA4 standard reporting dimensions × organic/total × mobile/desktop. Detail full inventory ใน Supabase column metadata

#### Indexes & Constraints

```sql
PRIMARY KEY (id, snapshot_at);
INDEX idx_logs_fingerprint (fingerprint, snapshot_at DESC);
INDEX idx_logs_brand (brand, snapshot_at DESC);
INDEX idx_logs_snapshot (snapshot_at DESC);
INDEX idx_logs_orphan (is_orphan) WHERE is_orphan = true;
INDEX idx_logs_indexing_issues (indexing_status) WHERE indexing_status != 'indexed';

FOREIGN KEY (fingerprint) REFERENCES seo_x_ads_keywords_contextual_master(fingerprint);

-- Yearly partition tables (logs_{YYYY}) follow same schema + same FK
-- Created automatically via pg_partman or manual CREATE TABLE per year
```

#### Used By
- **Part 20 KPI #4 (Organic Traffic Growth)** — gsc_clicks, ga4_organic_sessions
- **Part 20 KPI #5 (Keyword Coverage)** — ranking, fingerprint
- **Part 20 KPI #6 (Internal Link Depth)** — click_depth, is_orphan
- **Part 23.5 (CWV Targets)** — all cwv_* fields, page_timing_*
- **Part 23.6 (Accessibility)** — cwv_score_accessibility
- Sitemap Health Score (Part 4.10)
- Performance dashboards (Part 20)

---

### 7.3 `seo_local_rankings`

> **Purpose:** Track local SERP rankings per (keyword × location × branch) — crucial for medical clinic local SEO and Map Pack visibility  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** S only  
> **Bible Reference:** Part 4.5 (Type B Branch Landing), Part 23.X (Local SEO future)  
> **Volume:** ~5,000-30,000 records (keywords × branches × snapshots)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `snapshot_at` | `timestamptz` | Snapshot timestamp |
| `fingerprint` | `text FK→keywords_master.fingerprint` | Keyword reference |
| `branch_id` | `uuid FK→seo_branches.id` | Branch context |
| `brand` | `text` | Denormalized brand |
| `location_lat` | `numeric(10,7)` | Search location latitude (where ranking measured) |
| `location_lng` | `numeric(10,7)` | Search location longitude |
| `location_label` | `text` | Human-readable location (e.g., "Sukhumvit BTS Phrom Phong") |
| `radius_km` | `numeric DEFAULT 5` | Local search radius |
| **— Map Pack Position —** | | |
| `map_pack_position` | `integer` | Position in Map Pack (1-3 = visible, NULL = not in pack) |
| `map_pack_total_results` | `integer` | Total results in Map Pack |
| `is_in_map_pack` | `boolean` | true = appears in Map Pack |
| **— Organic Position (Local) —** | | |
| `organic_position` | `integer` | Position in organic local SERP |
| `is_in_local_pack_three` | `boolean` | true = top 3 organic local |
| **— Competitor Map Pack —** | | |
| `competitors_in_map_pack` | `jsonb` | Array competitors in Map Pack: [{name, place_id, rating, reviews_count}, ...] |
| `our_gbp_rating` | `numeric` | Our GBP rating shown |
| `our_gbp_reviews_count` | `integer` | Our review count shown |
| **— Distance & Geo Context —** | | |
| `distance_to_branch_km` | `numeric` | Distance from search point to our branch |
| `nearest_competitor_km` | `numeric` | Distance to nearest competitor |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_local_unique (fingerprint, branch_id, snapshot_at, location_lat, location_lng);
INDEX idx_local_branch (branch_id, snapshot_at DESC);
INDEX idx_local_keyword (fingerprint, snapshot_at DESC);
INDEX idx_local_map_pack (is_in_map_pack, snapshot_at DESC) WHERE is_in_map_pack = true;
INDEX idx_local_geo USING GIST (ST_Point(location_lng, location_lat));  -- requires postgis
```

#### Used By
- **Part 4.5 (Page Type Matrix)** — Type B (Branch Landing) + Type C (Local Programmatic) optimization
- Local SEO dashboards
- GBP optimization tracking
- **Part 23.X (Local SEO future)** — when activated for medical tourism brands

---

## 8. Group 6 — Backlinks & Off-Page (2 tables)

> **Role:** Backlink profile tracking — aggregate stats + individual link records  
> **Bible Reference:** Part 13 (LLMO — authority signals), Part 23.3 (Authority Validation)

### 8.1 `seo_backlinks_data`

> **Purpose:** Aggregate backlink statistics per (URL × snapshot date) — counts, referring domains, domain rank, dofollow ratio  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** S only (DataForSEO ingestion)  
> **Bible Reference:** Part 13 (LLMO authority), Part 20 (KPIs)  
> **Volume:** ~1,000-5,000 records (per URL per snapshot)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `fingerprint` | `text` | Reference to associated keyword fingerprint (if keyword-based monitoring) |
| `keyword` | `text` | Denormalized keyword (NULL if URL-based monitoring only) |
| `target_url` | `text NOT NULL` | URL being analyzed for backlinks |
| `target_domain` | `text NOT NULL` | Domain extracted from target_url |
| `snapshot_at` | `date NOT NULL` | Snapshot date |
| **— Aggregate Counts —** | | |
| `total_backlinks` | `integer` | จำนวน backlinks ทั้งหมด |
| `referring_domains` | `integer` | จำนวน unique domains ที่ link มา |
| `dofollow_count` | `integer` | จำนวน dofollow links (passing link equity) |
| `broken_backlinks` | `integer` | จำนวน broken backlinks (404 ที่ link มา) |
| `broken_pages` | `integer` | จำนวน pages ที่ broken |
| `new_backlinks` | `integer` | จำนวน backlinks ใหม่ (since last snapshot) |
| `lost_backlinks` | `integer` | จำนวน backlinks ที่หายไป (since last snapshot) |
| **— Quality Metrics —** | | |
| `domain_rank` | `integer` | Domain Rank (DataForSEO scale 0-100, similar to DR) |
| `avg_source_dr` | `numeric` | Average DR ของ source domains ที่ link มา (link equity proxy) |
| `backlink_summary_json` | `jsonb` | Detailed summary blob: {anchor_distribution, link_velocity, top_anchors, ...} |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_backlinks_data_url_date (target_url, snapshot_at);
INDEX idx_backlinks_data_domain (target_domain, snapshot_at DESC);
INDEX idx_backlinks_data_dr (domain_rank DESC) WHERE domain_rank IS NOT NULL;
INDEX idx_backlinks_data_velocity (new_backlinks DESC, snapshot_at DESC);
```

#### Used By
- **Part 13 (LLMO)** — authority signal aggregation
- **Part 20 (KPIs)** — backlink growth velocity
- Off-page SEO dashboards
- Toxic backlink detection (cross-reference with seo_backlinks_links spam_score)

---

### 8.2 `seo_backlinks_links`

> **Purpose:** Individual backlink records — every link from external domain to our pages, with anchor text, type, and source quality metrics  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** S only  
> **Bible Reference:** Part 13 (LLMO), Part 23.3 (Authority signals)  
> **Volume:** ~10,000-100,000+ records (every individual backlink)

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `fingerprint` | `text` | Associated keyword fingerprint (if any) |
| `keyword` | `text` | Denormalized keyword |
| `target_url` | `text NOT NULL` | Our URL receiving the backlink |
| `target_domain` | `text NOT NULL` | Our domain |
| `snapshot_at` | `date NOT NULL` | Snapshot date |
| **— Source Information —** | | |
| `source_url` | `text NOT NULL` | URL ของหน้าที่ link มาหาเรา |
| `source_domain` | `text NOT NULL` | Domain ของ source |
| `source_domain_rank` | `integer` | Domain rank ของ source (link equity proxy) |
| `source_page_rank` | `integer` | Page rank ของ source page |
| **— Link Properties —** | | |
| `anchor_text` | `text` | Anchor text ของ link |
| `is_dofollow` | `boolean` | true = dofollow, false = nofollow/sponsored/UGC |
| `links_count` | `integer` | จำนวน links ออกจาก source page (link dilution signal) |
| `page_from_external_links` | `integer` | จำนวน external links ออกจาก source page |
| **— Quality & Risk —** | | |
| `spam_score` | `integer` | Spam score (DataForSEO 0-17 scale) — สูง = น่าสงสัย/toxic |
| `is_broken` | `boolean DEFAULT false` | true = link is broken (404 detected) |
| **— Lifecycle —** | | |
| `first_seen_at` | `timestamptz` | Timestamp ที่เห็น link นี้ครั้งแรก |
| `last_seen_at` | `timestamptz` | Timestamp ล่าสุดที่ยืนยันยัง active |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_backlinks_link_unique (source_url, target_url, snapshot_at);
INDEX idx_backlinks_target_domain (target_domain, snapshot_at DESC);
INDEX idx_backlinks_source_domain (source_domain);
INDEX idx_backlinks_dofollow (is_dofollow, snapshot_at DESC);
INDEX idx_backlinks_spam (spam_score DESC) WHERE spam_score >= 8;  -- toxic candidates
INDEX idx_backlinks_broken (is_broken, snapshot_at DESC) WHERE is_broken = true;
INDEX idx_backlinks_anchor_trgm USING GIN (anchor_text gin_trgm_ops);
```

#### Used By
- **Part 13 (LLMO)** — anchor text distribution analysis
- **Part 23.3 (Authority Validation)** — high-quality source domain identification
- Toxic backlink disavow workflow
- Link velocity tracking
- Anchor text optimization (Bible Part 3.6)

---

## 9. Group 7 — AI Operations & Embeddings (4 tables)

> **Role:** AI engine tracking — brand mentions, LLM citations, query simulations, semantic embeddings  
> **Bible Reference:** Part 21 (AI Operations & Embedding Strategy), Part 13 (LLMO Playbook), Part 20 KPI #11-13

### 9.1 `seo_brand_mentions`

> **Purpose:** Track เมื่อ brand ถูกพูดถึงใน AI engines (ChatGPT, Perplexity, Gemini, Claude, Copilot) สำหรับ measure Brand Mention Rate (KPI #11)  
> **Tier:** 1 (Critical Operational)  
> **Sync:** S only (system-generated from query simulations)  
> **Bible Reference:** Part 13 (LLMO), Part 20 KPI #11 (Brand Mention Rate), Part 21  
> **Volume:** ~1,000-5,000 records per brand portfolio per month

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `mention_fingerprint` | `text UNIQUE` | Natural unique ID (hash of source+query+brand+date) |
| `brand_id` | `uuid FK→brands.id` | Brand mentioned |
| `brand_name` | `text` | Denormalized brand name |
| **— AI Engine Source —** | | |
| `ai_engine` | `text NOT NULL` | 'chatgpt' / 'perplexity' / 'gemini' / 'claude' / 'copilot' / 'meta_ai' / 'mistral_chat' / 'other' |
| `ai_engine_version` | `text` | Specific version/model (e.g., 'gpt-4o', 'claude-3.7-sonnet', 'gemini-pro-1.5') |
| `triggering_query` | `text NOT NULL` | Query ที่ทำให้ brand ถูก mention |
| `triggering_query_fp` | `text FK→keywords_master.fingerprint` | Mapped to text keyword if match |
| **— Mention Context —** | | |
| `mention_position` | `integer` | ลำดับการ mention ใน response (1=first mentioned) |
| `total_brands_mentioned` | `integer` | จำนวน brands ที่ AI mention ใน response นั้น (competitive context) |
| `mention_context` | `text` | Surrounding text context (paragraph excerpt) |
| `mention_sentiment` | `text` | 'positive' / 'neutral' / 'negative' / 'mixed' |
| `mention_recommendation_strength` | `text` | 'top_recommendation' / 'mentioned_as_option' / 'mentioned_as_alternative' / 'comparison_only' / 'critical' |
| `is_first_in_list` | `boolean` | true = AI listed our brand first |
| `is_only_brand_mentioned` | `boolean` | true = only our brand was mentioned (zero competition) |
| **— Citation & Source —** | | |
| `cited_our_url` | `text` | URL ของเราที่ AI cited (NULL = mentioned without citation) |
| `cited_our_url_fp` | `text FK→page_master.page_fingerprint` | Mapped page fingerprint |
| `our_url_position_in_citations` | `integer` | Position ของ URL เราใน citation list ของ AI |
| `competitor_urls_cited` | `jsonb` | Array URLs ของ competitors ที่ถูก cite |
| **— Query Simulation Reference —** | | |
| `simulation_id` | `uuid FK→seo_llm_query_simulations.id` | Source simulation that surfaced this mention |
| `observed_at` | `timestamptz NOT NULL` | Timestamp observation |
| **— Trust Signals —** | | |
| `wikidata_referenced` | `boolean DEFAULT false` | true = AI referenced Wikidata entity (high trust signal — Bible Part 13.X) |
| `accreditation_referenced` | `boolean DEFAULT false` | true = AI referenced accreditation (JCI/HA/etc.) |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_mentions_fp (mention_fingerprint);
INDEX idx_mentions_brand_date (brand_id, observed_at DESC);
INDEX idx_mentions_engine (ai_engine, observed_at DESC);
INDEX idx_mentions_query (triggering_query_fp) WHERE triggering_query_fp IS NOT NULL;
INDEX idx_mentions_position (mention_position) WHERE mention_position IS NOT NULL;
INDEX idx_mentions_sentiment (mention_sentiment);
INDEX idx_mentions_top (is_first_in_list) WHERE is_first_in_list = true;
```

#### Used By
- **Part 20 KPI #11 (Brand Mention Rate)** — primary metric source
- **Part 13 (LLMO)** — Brand SERP visibility tracking
- **Part 21 (AI Operations)** — AI engine performance dashboards
- Wikidata setup ROI tracking (correlation with wikidata_referenced)

---

### 9.2 `seo_llm_citations`

> **Purpose:** Track เมื่อ AI engines cite URL ของเรา (with or without brand mention) — different from brand mentions because citations include "informational" references where brand isn't named  
> **Tier:** 1 (Critical Operational)  
> **Sync:** S only  
> **Bible Reference:** Part 21 (AI Operations), Part 20 KPI #12 (AI Citation Rate)  
> **Volume:** ~2,000-10,000 records per month

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `citation_fingerprint` | `text UNIQUE` | Natural unique ID |
| `our_url` | `text NOT NULL` | URL ของเราที่ถูก cite |
| `our_url_fp` | `text FK→page_master.page_fingerprint` | Mapped page |
| `brand_id` | `uuid FK→brands.id` | Brand owner of URL |
| **— AI Engine Context —** | | |
| `ai_engine` | `text NOT NULL` | AI engine code |
| `ai_engine_version` | `text` | Specific version |
| `triggering_query` | `text NOT NULL` | Query ที่ทำให้ cite |
| `triggering_query_fp` | `text FK→keywords_master.fingerprint` | Mapped keyword |
| **— Citation Details —** | | |
| `citation_position` | `integer` | Position in citation list (1=top) |
| `total_citations_in_response` | `integer` | จำนวน citations ทั้งหมดใน response |
| `cited_excerpt` | `text` | ข้อความที่ AI ดึงไปใช้ (excerpt) |
| `pattern_type` | `text` | Pattern ของ excerpt: 'A' / 'B' / 'C' / 'D' / 'E' / 'F' (Bible Part 6) |
| `cited_section_anchor` | `text` | Section ของหน้าที่ถูก cite (anchor link if available) |
| `citation_quality_score` | `integer` | 0-100 — quality of citation (high if exact quote + position 1) |
| **— Brand Mention Co-occurrence —** | | |
| `brand_also_mentioned` | `boolean DEFAULT false` | true = brand was named alongside citation |
| `linked_brand_mention_id` | `uuid FK→seo_brand_mentions.id` | Link to brand_mention record if co-occurred |
| **— Simulation Reference —** | | |
| `simulation_id` | `uuid FK→seo_llm_query_simulations.id` | Source simulation |
| `observed_at` | `timestamptz NOT NULL` | Observation timestamp |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_llm_cite_fp (citation_fingerprint);
INDEX idx_llm_cite_url (our_url_fp, observed_at DESC);
INDEX idx_llm_cite_engine (ai_engine, observed_at DESC);
INDEX idx_llm_cite_position (citation_position) WHERE citation_position IS NOT NULL;
INDEX idx_llm_cite_pattern (pattern_type) WHERE pattern_type IS NOT NULL;
```

#### Used By
- **Part 20 KPI #12 (AI Citation Rate)** — primary source
- **Part 6 (Content Standard)** — Pattern A-F effectiveness measurement
- **Part 21 (AI Operations)** — citation quality dashboards
- Pattern F validation (Evidence-Level citables)

---

### 9.3 `seo_llm_query_simulations`

> **Purpose:** Run simulated queries on AI engines เพื่อ track brand visibility — automated probing of AI responses for our target keywords  
> **Tier:** 1 (Critical Operational)  
> **Sync:** S only (system-generated)  
> **Bible Reference:** Part 21 (AI Operations & Embedding Strategy), Part 13 (LLMO)  
> **Volume:** ~5,000-20,000 simulations per month per brand portfolio

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `simulation_batch_id` | `uuid` | Group ID — multiple simulations from same batch run |
| `brand_id` | `uuid FK→brands.id` | Brand context |
| **— Query Setup —** | | |
| `query_text` | `text NOT NULL` | Query text submitted to AI |
| `query_intent_type` | `text` | 'best_in_category' / 'comparison' / 'how_to' / 'price_check' / 'symptom_check' / 'recommendation' / 'fact_lookup' |
| `query_persona` | `text` | Simulated user persona: 'patient_first_time' / 'patient_returning' / 'caregiver' / 'researcher' / 'comparison_shopper' |
| `query_language` | `text` | Language: 'th' / 'en' / etc. |
| `query_location_context` | `text` | Geo context: 'bangkok' / 'thailand' / 'global' |
| `mapped_keyword_fp` | `text FK→keywords_master.fingerprint` | Source keyword if simulation derived from one |
| **— AI Engine —** | | |
| `ai_engine` | `text NOT NULL` | Engine identifier |
| `ai_engine_version` | `text` | Specific model version |
| `engine_settings` | `jsonb` | Engine config: {temperature, mode (search/chat), tools_enabled, ...} |
| **— Response Capture —** | | |
| `response_text` | `text` | Full AI response (raw text) |
| `response_tokens_count` | `integer` | Approximate tokens in response |
| `response_citations_raw` | `jsonb` | Raw citations from AI: [{url, title, position}, ...] |
| `response_brands_mentioned` | `text[]` | Array brand names extracted from response |
| `response_summary` | `text` | AI-generated summary of response (if processed) |
| **— Results —** | | |
| `our_brand_mentioned` | `boolean DEFAULT false` | true = our brand appeared in response |
| `our_brand_mention_position` | `integer` | Position of our brand in response (NULL = not mentioned) |
| `our_url_cited` | `boolean DEFAULT false` | true = our URL was cited |
| `competitor_brands_mentioned` | `text[]` | Array competitor brands mentioned |
| `competitor_urls_cited` | `jsonb` | Array competitor URLs cited |
| **— Lifecycle —** | | |
| `simulated_at` | `timestamptz NOT NULL` | Simulation execution timestamp |
| `simulation_method` | `text` | 'api_direct' / 'browser_automation' / 'manual' |
| `cost_usd` | `numeric(10,4)` | API cost (if metered) |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
INDEX idx_sims_brand (brand_id, simulated_at DESC);
INDEX idx_sims_engine (ai_engine, simulated_at DESC);
INDEX idx_sims_batch (simulation_batch_id);
INDEX idx_sims_keyword (mapped_keyword_fp) WHERE mapped_keyword_fp IS NOT NULL;
INDEX idx_sims_brand_mentioned (our_brand_mentioned, simulated_at DESC) WHERE our_brand_mentioned = true;
```

#### Used By
- **Part 21 (AI Operations)** — automated AI visibility probing
- **Part 20 KPI #11, #12, #13** — feeds brand_mentions + llm_citations + share-of-voice
- AI engine performance comparison dashboards
- Persona-based AI response analysis

---

### 9.4 `seo_entity_embeddings`

> **Purpose:** Vector embeddings ของทุก entity, page, citation — สำหรับ semantic search, similarity matching, RAG pipelines, content gap detection  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** S only (system-generated via embedding pipeline)  
> **Bible Reference:** Part 21 (AI Operations & Embedding Strategy)  
> **Required Extension:** `pgvector` (Appendix A)  
> **Volume:** ~5,000-50,000 vectors per brand portfolio

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `source_type` | `text NOT NULL` | 'entity' / 'page' / 'citation' / 'keyword' / 'cluster' / 'paragraph' |
| `source_fingerprint` | `text NOT NULL` | Reference to source (entity_fp / page_fp / citation_fp / etc.) |
| `source_id` | `uuid` | UUID reference (alternative to fingerprint) |
| `chunk_index` | `integer DEFAULT 0` | If source split into chunks (e.g., long page → multiple chunks) |
| `chunk_text` | `text NOT NULL` | Text content that was embedded |
| `chunk_word_count` | `integer` | Word count of chunk |
| **— Embedding —** | | |
| `embedding_model` | `text NOT NULL` | Model used: 'text-embedding-3-large' / 'voyage-3' / 'text-embedding-3-small' / 'multilingual-e5-large' |
| `embedding_dimensions` | `integer NOT NULL` | Vector dimensions (e.g., 1536, 3072, 1024) |
| `embedding` | `vector(3072)` | The actual embedding vector (pgvector type — sized to model) |
| `embedding_normalized` | `boolean DEFAULT true` | true = vector is normalized for cosine similarity |
| **— Metadata —** | | |
| `language` | `text` | Source language |
| `brand_scope` | `text[]` | Brand scope (inherited from source if applicable) |
| `metadata` | `jsonb` | Additional metadata: {section, position, content_type, ...} |
| `quality_flag` | `text` | 'high' / 'medium' / 'low' — based on source quality |
| **— Lifecycle —** | | |
| `embedded_at` | `timestamptz DEFAULT now()` | When embedding was generated |
| `model_version` | `text` | Specific model version (for re-embedding tracking) |
| `re_embed_required` | `boolean DEFAULT false` | true = needs re-embedding (model upgrade or content change) |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
INDEX idx_embeddings_source (source_type, source_fingerprint);
INDEX idx_embeddings_model (embedding_model, embedded_at DESC);
INDEX idx_embeddings_re_embed (re_embed_required) WHERE re_embed_required = true;

-- Vector similarity search index (HNSW for high-dimensional vectors)
CREATE INDEX idx_embeddings_hnsw ON seo_entity_embeddings 
  USING hnsw (embedding vector_cosine_ops) 
  WITH (m = 16, ef_construction = 64);

-- Alternative: IVFFlat for memory-constrained environments
-- CREATE INDEX idx_embeddings_ivfflat ON seo_entity_embeddings 
--   USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

CONSTRAINT valid_source_type CHECK (source_type IN ('entity','page','citation','keyword','cluster','paragraph'));
```

#### Used By
- **Part 21 (AI Operations)** — RAG pipelines, semantic search, similarity-based content gaps
- **Part 13 (LLMO)** — semantic relevance scoring
- Content recommendation engine
- Topic cluster auto-suggestion (find similar entities not yet linked)
- AI Citation prediction (find pages most likely to be cited for a given query)

---

## 10. Group 8 — Data Quality & Governance (2 tables)

> **Role:** Data quality measurement + schema change audit  
> **Bible Reference:** Part 19 (Data Quality Framework), Part 15 (Schema Change Governance)

### 10.1 `seo_data_quality_metrics`

> **Purpose:** Measure 5 DAMA dimensions of data quality across all tables — completeness, consistency, validity, uniqueness, freshness — for systematic quality monitoring  
> **Tier:** 1 (Critical Operational)  
> **Sync:** S only (system-generated by quality jobs)  
> **Bible Reference:** Part 19 (Data Quality — 5 DAMA dimensions)  
> **Volume:** ~500-2,000 records per measurement run

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `measured_at` | `timestamptz NOT NULL` | Timestamp of measurement |
| **— Subject —** | | |
| `target_table` | `text NOT NULL` | Table being measured (e.g., 'seo_website_page_master') |
| `target_column` | `text` | Specific column (NULL if table-level) |
| `target_record_id` | `text` | Specific record (NULL if aggregate) |
| `target_scope` | `text` | 'table' / 'column' / 'record' / 'cluster' / 'brand' |
| **— DAMA Dimensions —** | | |
| `quality_dimension` | `text NOT NULL` | 'completeness' / 'consistency' / 'validity' / 'uniqueness' / 'freshness' |
| `metric_name` | `text NOT NULL` | Specific metric (e.g., 'reviewer_id_filled_pct', 'orphan_pages_count') |
| `metric_value` | `numeric` | Numeric value (0-100 for percentages, raw count otherwise) |
| `metric_unit` | `text` | 'percentage' / 'count' / 'days' / 'ratio' |
| `threshold_target` | `numeric` | Target threshold for "good" (Bible Part 19 standards) |
| `threshold_warning` | `numeric` | Warning threshold |
| `threshold_critical` | `numeric` | Critical threshold |
| `status` | `text` | 'good' / 'warning' / 'critical' (computed from value vs thresholds) |
| **— Context —** | | |
| `brand_scope` | `text` | Brand context (NULL = system-wide) |
| `vertical_scope` | `text` | Vertical context |
| `measurement_method` | `text` | How measured: 'sql_query' / 'computed' / 'manual_audit' |
| `failing_records_count` | `integer` | Count of records failing this metric |
| `failing_records_sample` | `jsonb` | Sample of failing record IDs (max 10 for investigation) |
| `notes` | `text` | Additional context |
| `created_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
INDEX idx_dq_table_dimension (target_table, quality_dimension, measured_at DESC);
INDEX idx_dq_status (status, measured_at DESC) WHERE status IN ('warning', 'critical');
INDEX idx_dq_brand (brand_scope, measured_at DESC) WHERE brand_scope IS NOT NULL;
INDEX idx_dq_metric (metric_name, measured_at DESC);

CONSTRAINT valid_dimension CHECK (
  quality_dimension IN ('completeness', 'consistency', 'validity', 'uniqueness', 'freshness')
);
CONSTRAINT valid_status CHECK (status IN ('good', 'warning', 'critical'));
```

#### Used By
- **Part 19 (Data Quality Framework)** — primary measurement source
- **Part 20 KPI #14, #15** — Data Quality Score + System Health
- Quality dashboards (Part 20.5)
- Automated alerts on critical status
- Pre-deployment validation checks

---

### 10.2 `seo_schema_changes`

> **Purpose:** Audit trail ของทุกการเปลี่ยน schema — track DDL changes, who, when, why, rollback plan  
> **Tier:** 3 (Audit/Reference)  
> **Sync:** S only (audit log)  
> **Bible Reference:** Part 15 (Schema Change Governance)  
> **Volume:** ~50-200 records per year

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `change_id` | `text UNIQUE` | Human-readable change ID (e.g., 'CHG-2026-001') |
| `change_type` | `text NOT NULL` | 'add_column' / 'drop_column' / 'alter_type' / 'add_table' / 'drop_table' / 'add_index' / 'add_constraint' / 'rename' |
| `target_table` | `text NOT NULL` | Affected table |
| `target_column` | `text` | Affected column (if applicable) |
| **— Change Details —** | | |
| `change_description` | `text NOT NULL` | Human description (e.g., "Add evidence_tier column to seo_citations per Bible Part 23.1") |
| `forward_sql` | `text NOT NULL` | SQL to apply the change |
| `rollback_sql` | `text` | SQL to reverse the change |
| `affected_rows_estimate` | `integer` | Estimated affected rows |
| `breaking_change` | `boolean DEFAULT false` | true = backwards-incompatible |
| `bible_section_reference` | `text` | Bible Part/Section that mandated this change |
| **— Approval & Execution —** | | |
| `proposed_by` | `text` | Person who proposed change |
| `proposed_at` | `timestamptz` | Proposal timestamp |
| `approved_by` | `text` | Approver |
| `approved_at` | `timestamptz` | Approval timestamp |
| `executed_by` | `text` | Who executed the migration |
| `executed_at` | `timestamptz` | Execution timestamp |
| `execution_status` | `text` | 'pending' / 'approved' / 'executed' / 'rolled_back' / 'failed' |
| `execution_duration_ms` | `integer` | Execution time |
| **— Validation —** | | |
| `pre_execution_checks_passed` | `boolean` | Pre-flight checks passed |
| `post_execution_validation` | `jsonb` | Post-execution validation results: {row_counts_match, constraint_checks, ...} |
| `rollback_executed_at` | `timestamptz` | Rollback timestamp if rolled back |
| `rollback_reason` | `text` | Reason for rollback |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_schema_changes_id (change_id);
INDEX idx_schema_changes_table (target_table, executed_at DESC);
INDEX idx_schema_changes_status (execution_status);
INDEX idx_schema_changes_breaking (breaking_change) WHERE breaking_change = true;
INDEX idx_schema_changes_pending (execution_status) WHERE execution_status IN ('pending', 'approved');

CONSTRAINT valid_change_type CHECK (
  change_type IN ('add_column', 'drop_column', 'alter_type', 'add_table', 'drop_table', 
                  'add_index', 'add_constraint', 'rename', 'add_extension', 'other')
);
CONSTRAINT valid_execution_status CHECK (
  execution_status IN ('pending', 'approved', 'executed', 'rolled_back', 'failed')
);
```

#### Used By
- **Part 15 (Schema Change Governance)** — primary audit source
- **Part 19 (Data Quality)** — change impact tracking
- Compliance/audit reporting
- DDL migration history (Phase 1 deployment tracking)

---

## 11. Group 9 — Entity Extensions & Templates (4 tables)

> **Role:** Extended entity metadata for medical-specific use cases (ingredients, devices, procedures) + programmatic page template definitions  
> **Bible Reference:** Part 14 (Vertical Profiles), Part 4.5 (Page Type Matrix — Type C)

### 11.1 `seo_entity_ingredients`

> **Purpose:** Extended metadata for ingredient entities (cosmeceuticals, supplements, drug compounds) — INCI names, mechanisms, evidence levels, contraindications  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** N↔S  
> **Bible Reference:** Part 14 (Vertical: Aesthetic, Wellness, Pharmacy)  
> **Volume:** ~100-500 ingredient entities per applicable brand

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `entity_fingerprint` | `text FK→entity_graph.entity_fingerprint UNIQUE` | Parent entity (must be entity_type='ingredient') |
| `inci_name` | `text` | INCI (International Nomenclature of Cosmetic Ingredients) name |
| `inn_name` | `text` | INN (International Nonproprietary Name) for drugs |
| `cas_number` | `text` | CAS Registry Number |
| `chemical_formula` | `text` | Chemical formula (e.g., 'C8H10N4O2') |
| `molecular_weight` | `numeric` | Molecular weight (g/mol) |
| **— Mechanism & Function —** | | |
| `mechanism_of_action` | `text` | How ingredient works (clinical/biochemical) |
| `cosmetic_function` | `text[]` | Array functions: ['antioxidant', 'humectant', 'anti-inflammatory', 'depigmenting'] |
| `target_skin_concerns` | `text[]` | Array concerns it addresses: ['acne', 'wrinkles', 'hyperpigmentation', 'dryness'] |
| **— Concentration & Use —** | | |
| `typical_concentration_min` | `numeric` | Minimum effective concentration (%) |
| `typical_concentration_max` | `numeric` | Maximum safe concentration (%) |
| `typical_concentration_unit` | `text DEFAULT '%'` | Unit |
| `optimal_ph_min` | `numeric` | Optimal pH range minimum |
| `optimal_ph_max` | `numeric` | Optimal pH range maximum |
| **— Safety & Regulation —** | | |
| `evidence_level` | `text` | 'EvidenceLevelA' / 'B' / 'C' (per Bible Part 23.1) |
| `safety_profile` | `text` | 'well_established' / 'generally_safe' / 'use_with_caution' / 'restricted' |
| `pregnancy_safe` | `boolean` | true = safe in pregnancy |
| `contraindications` | `text[]` | Array contraindications |
| `incompatible_ingredients` | `text[]` | Array ingredient_fingerprints ที่ใช้ร่วมกันไม่ดี |
| `synergistic_ingredients` | `text[]` | Array ingredient_fingerprints ที่ใช้ร่วมกันดี |
| `eu_inci_restricted` | `boolean DEFAULT false` | EU INCI restriction flag |
| `fda_status` | `text` | FDA classification (OTC / Rx / GRAS / etc.) |
| **— Citations —** | | |
| `key_research_citations` | `text[]` | Array citation_fingerprints (links to seo_citations) |
| `notion_id` | `text` | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_ingredients_entity (entity_fingerprint);
INDEX idx_ingredients_inci (inci_name) WHERE inci_name IS NOT NULL;
INDEX idx_ingredients_cas (cas_number) WHERE cas_number IS NOT NULL;
INDEX idx_ingredients_concerns (target_skin_concerns) USING GIN;
INDEX idx_ingredients_function (cosmetic_function) USING GIN;
INDEX idx_ingredients_evidence (evidence_level);
```

#### Used By
- **Part 14 (Vertical: Aesthetic/Wellness)** — ingredient-driven content
- Programmatic ingredient pages (Type C)
- Ingredient comparison tools
- "What's in this product" rendering

---

### 11.2 `seo_entity_devices`

> **Purpose:** Extended metadata for medical device entities — FDA classification, technology, indications, contraindications  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** N↔S  
> **Bible Reference:** Part 14 (Vertical: Aesthetic, Sleep Medicine, Dental — device-heavy verticals)  
> **Volume:** ~50-300 device entities per applicable brand

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `entity_fingerprint` | `text FK→entity_graph.entity_fingerprint UNIQUE` | Parent entity (entity_type='device') |
| `device_brand_name` | `text` | Brand/model (e.g., 'Ultraformer III', 'CPAP DreamStation') |
| `manufacturer` | `text` | Manufacturer company |
| `manufacturer_country` | `text` | Country of manufacture |
| **— Regulation —** | | |
| `fda_classification` | `text` | 'Class I' / 'Class II' / 'Class III' (FDA medical device classification) |
| `fda_510k_number` | `text` | FDA 510(k) clearance number |
| `fda_approved_indications` | `text[]` | Array FDA-approved uses |
| `ce_marking` | `text` | CE marking class (EU) |
| `thai_fda_registration` | `text` | Thai FDA registration number (อย.) |
| **— Technology —** | | |
| `technology_type` | `text` | Technology classification (e.g., 'HIFU', 'CPAP', 'Laser CO2', 'Q-switched') |
| `wavelength_nm` | `numeric` | Wavelength (nm) for laser devices |
| `frequency_mhz` | `numeric` | Frequency (MHz) for ultrasound devices |
| `pressure_range_cmh2o` | `text` | Pressure range for CPAP/respiratory devices |
| `technical_specs_json` | `jsonb` | Additional technical specifications |
| **— Clinical —** | | |
| `evidence_level` | `text` | 'EvidenceLevelA' / 'B' / 'C' |
| `clinical_indications` | `text[]` | Array clinical conditions treated |
| `contraindications` | `text[]` | Array contraindications |
| `typical_treatment_duration_min` | `integer` | Typical session duration (minutes) |
| `typical_sessions_required` | `text` | Typical course (e.g., '3-6 sessions, monthly') |
| `recovery_time_text` | `text` | Recovery period description |
| `pain_level` | `text` | 'minimal' / 'mild' / 'moderate' / 'significant' |
| **— Comparable Devices —** | | |
| `comparable_devices` | `text[]` | Array entity_fingerprints of similar devices |
| `key_research_citations` | `text[]` | Array citation_fingerprints |
| `notion_id` | `text` | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_devices_entity (entity_fingerprint);
INDEX idx_devices_technology (technology_type);
INDEX idx_devices_fda_class (fda_classification);
INDEX idx_devices_indications (clinical_indications) USING GIN;
INDEX idx_devices_evidence (evidence_level);
```

#### Used By
- **Part 14 (Vertical: Aesthetic/Sleep Medicine/Dental)** — device-driven content
- Device comparison pages
- Treatment selection guides
- "Compare X vs Y device" programmatic pages

---

### 11.3 `seo_entity_procedures`

> **Purpose:** Extended metadata for medical/aesthetic procedure entities — protocol, recovery, results timeline, pricing context  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** N↔S  
> **Bible Reference:** Part 14 (Vertical Profiles), Part 23.1 (Citation Tiers)  
> **Volume:** ~100-500 procedure entities per applicable brand

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `entity_fingerprint` | `text FK→entity_graph.entity_fingerprint UNIQUE` | Parent entity (entity_type='procedure') |
| `procedure_thai_name` | `text` | ชื่อภาษาไทย (display name) |
| `procedure_english_name` | `text` | English name |
| `procedure_aliases` | `text[]` | Array aliases (alternative names) |
| `procedure_category` | `text` | 'surgical' / 'minimally_invasive' / 'non_invasive' / 'diagnostic' / 'preventive' |
| `medical_specialty` | `text[]` | Array specialties that perform this |
| **— Clinical Details —** | | |
| `evidence_level` | `text` | Evidence level per Bible Part 23.1 |
| `procedure_purpose` | `text` | Why it's done (clinical purpose) |
| `clinical_indications` | `text[]` | Conditions it treats |
| `contraindications` | `text[]` | When NOT to do |
| `risks_and_complications` | `text[]` | Common risks |
| **— Protocol —** | | |
| `typical_duration_min` | `integer` | Typical duration (minutes) |
| `anesthesia_type` | `text` | 'none' / 'topical' / 'local' / 'sedation' / 'general' |
| `pre_procedure_prep_text` | `text` | Pre-procedure preparation |
| `procedure_steps_text` | `text` | Procedure outline |
| `post_procedure_care_text` | `text` | Aftercare instructions |
| **— Recovery & Results —** | | |
| `downtime_days` | `text` | Downtime (e.g., '0-3 days', '1-2 weeks') |
| `recovery_milestones_json` | `jsonb` | [{day: 1, description: "..."}, ...] |
| `results_timeline_text` | `text` | When results show (e.g., 'immediate' / '3-6 months gradual') |
| `results_duration_text` | `text` | How long results last |
| `repeat_session_advice` | `text` | Repeat treatment guidance |
| **— Pricing Context —** | | |
| `price_range_thb_min` | `numeric` | Price range minimum (THB) |
| `price_range_thb_max` | `numeric` | Price range maximum |
| `pricing_factors_text` | `text` | What affects pricing (area size, sessions, doctor) |
| **— Comparison —** | | |
| `comparable_procedures` | `text[]` | Array entity_fingerprints |
| `alternative_procedures` | `text[]` | Array entity_fingerprints (alternative options) |
| `combined_with_procedures` | `text[]` | Procedures often combined |
| `key_research_citations` | `text[]` | Array citation_fingerprints |
| `notion_id` | `text` | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_procedures_entity (entity_fingerprint);
INDEX idx_procedures_category (procedure_category);
INDEX idx_procedures_specialty (medical_specialty) USING GIN;
INDEX idx_procedures_indications (clinical_indications) USING GIN;
INDEX idx_procedures_evidence (evidence_level);
```

#### Used By
- **Part 14 (Vertical Profiles)** — procedure-heavy verticals (aesthetic, dental, surgical)
- Layer 6 Protocol pages (Bible Part 3)
- Procedure comparison pages
- Recovery timeline visualizations
- Pricing transparency pages

---

### 11.4 `seo_programmatic_templates`

> **Purpose:** Define template structures สำหรับสร้าง programmatic pages (Type C — Local Programmatic, Type D — Brand-Wide Tagged) — variable substitution, schema markup, content blocks  
> **Tier:** 2 (Intelligence/Analytics)  
> **Sync:** N↔S  
> **Bible Reference:** Part 4.5 (Page Type Matrix), Part 9 (Page Template Anatomy)  
> **Volume:** ~10-50 templates per brand portfolio

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | `uuid PK` | Primary key |
| `template_fingerprint` | `text UNIQUE` | Natural unique ID (e.g., 'tpl:branch_landing_v2') |
| `template_name` | `text NOT NULL` | Display name |
| `template_version` | `text DEFAULT '1.0'` | Version (semver-style) |
| `target_page_type` | `text NOT NULL` | 'branch_landing' / 'local_programmatic' / 'doctor_profile' / 'condition_pillar' / 'procedure_pillar' / 'ingredient_explainer' / 'device_explainer' |
| `target_layer` | `integer` | Target Layer 1-7 (Bible Part 3) |
| `target_tier` | `text` | Target Tier A/B/C/D |
| **— Template Structure —** | | |
| `url_pattern` | `text NOT NULL` | URL pattern with variables (e.g., '/services/{service_slug}/{branch_slug}') |
| `title_pattern` | `text` | SEO title pattern (e.g., '{service_name} ที่ {branch_name} | {brand_name}') |
| `meta_description_pattern` | `text` | Meta description pattern |
| `h1_pattern` | `text` | H1 pattern |
| `content_blocks_json` | `jsonb NOT NULL` | Array content blocks: [{block_type, order, content_pattern, variables_used, schema_markup}, ...] |
| `schema_markup_template` | `jsonb` | Schema.org JSON-LD template with variable placeholders |
| **— Variables —** | | |
| `required_variables` | `text[] NOT NULL` | Array variable names required (e.g., ['branch_id', 'service_id', 'language']) |
| `optional_variables` | `text[]` | Array optional variables |
| `data_sources_json` | `jsonb` | Where each variable pulls from: {variable_name: {source_table, source_column, fallback}} |
| **— Generation Rules —** | | |
| `eligibility_rules_json` | `jsonb` | Rules for which entities/branches can use this template |
| `min_content_word_count` | `integer DEFAULT 800` | Minimum content length to publish |
| `requires_images` | `boolean DEFAULT true` | true = images required |
| `requires_doctor_assignment` | `boolean DEFAULT false` | true = needs doctor assignment data |
| `requires_branch_data` | `boolean DEFAULT false` | true = needs branch context |
| `requires_citations` | `boolean DEFAULT false` | true = template includes citation block |
| `min_citations_count` | `integer DEFAULT 0` | Minimum citations required |
| **— Quality Gates —** | | |
| `editorial_review_required` | `boolean DEFAULT true` | true = must pass editorial review (Part 23.4) |
| `medical_review_required` | `boolean DEFAULT false` | true = must pass Stage 1 medical review |
| `legal_review_required` | `boolean DEFAULT false` | true = must pass Stage 4 legal review |
| **— Lifecycle —** | | |
| `template_status` | `text DEFAULT 'draft'` | 'draft' / 'active' / 'deprecated' / 'archived' |
| `pages_generated_count` | `integer DEFAULT 0` | Cumulative count of pages generated from this template |
| `last_used_at` | `timestamptz` | Last time template was used |
| `created_by_author_id` | `uuid FK→authors_reviewers.id` | Template creator |
| `description` | `text` | Template description / use case |
| `usage_examples_text` | `text` | Example pages generated |
| `notion_id` | `text` | |
| `created_at` | `timestamptz DEFAULT now()` | |
| `updated_at` | `timestamptz DEFAULT now()` | |
| `notion_synced_at` | `timestamptz` | |

#### Indexes & Constraints

```sql
PRIMARY KEY (id);
UNIQUE INDEX idx_templates_fp (template_fingerprint);
INDEX idx_templates_page_type (target_page_type);
INDEX idx_templates_status (template_status) WHERE template_status = 'active';
INDEX idx_templates_layer (target_layer, target_tier);

CONSTRAINT valid_template_status CHECK (
  template_status IN ('draft', 'active', 'deprecated', 'archived')
);
```

#### Used By
- **Part 4.5 (Page Type Matrix)** — Type C/D programmatic page generation
- **Part 9 (Page Template Anatomy)** — content block structure
- **seo_website_page_master.programmatic_template_id** — pages reference templates
- Bulk page generation pipelines (n8n flows)
- A/B testing of template variations

---

## Appendix A — Required PostgreSQL Extensions

### Installation Order

```sql
-- 1. Core (typically pre-installed in Supabase)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";       -- UUID generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;           -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pg_trgm;            -- Trigram similarity (fuzzy text search)

-- 2. For Group 7 (AI Operations & Embeddings)
CREATE EXTENSION IF NOT EXISTS vector;             -- pgvector for vector similarity search
-- Note: HNSW index requires pgvector >= 0.5.0

-- 3. Recommended for Group 1 (Branches geo)
CREATE EXTENSION IF NOT EXISTS postgis;            -- Spatial types and operators
CREATE EXTENSION IF NOT EXISTS earthdistance CASCADE;  -- Earth distance calculations (alt to PostGIS for simple cases)

-- 4. Optional for automation
CREATE EXTENSION IF NOT EXISTS pg_cron;            -- Scheduled jobs (archival, quality checks)
CREATE EXTENSION IF NOT EXISTS pgmq;               -- Async message queue (n8n integration)
CREATE EXTENSION IF NOT EXISTS pg_partman;         -- Automated partition management for Group 5

-- 5. Optional for monitoring & data quality
CREATE EXTENSION IF NOT EXISTS pg_stat_statements; -- Query performance tracking (typically enabled by default)
CREATE EXTENSION IF NOT EXISTS pg_jsonschema;      -- JSON Schema validation
CREATE EXTENSION IF NOT EXISTS hypopg;             -- Hypothetical indexes for tuning
```

### Extension-to-Table Map

| Extension | Required For | Tables |
|-----------|--------------|--------|
| `uuid-ossp` / `pgcrypto` | UUID PKs | All tables |
| `pg_trgm` | Fuzzy text search | seo_x_ads_keywords_contextual_master, seo_backlinks_links |
| `vector` (pgvector) | Vector similarity search | seo_entity_embeddings (REQUIRED) |
| `postgis` | Geo queries | seo_branches, seo_local_rankings (RECOMMENDED) |
| `pg_partman` | Yearly partition automation | Group 5 Performance Fact Tables (OPTIONAL) |
| `pg_cron` | Scheduled archival jobs | Group 5 archive workflow (OPTIONAL) |

---

## Appendix B — Fingerprint Patterns

### Convention

```
fingerprint = "<entity_kind>:<unique_identifier_string>"

  entity_kind: indicates type — used for type-safety and filtering
  unique_identifier_string: stable, human-readable, slugified
```

### Pattern Catalog

| Entity Kind | Pattern | Example |
|-------------|---------|---------|
| Page | `page:<brand>:<slug>` | `page:brand_a:peri_implantitis_treatment` |
| Entity | `entity:<concept>` | `entity:niacinamide` |
| Author | `author:<name_specialty>` | `author:dr_somchai_dermatology` |
| Branch | `branch:<brand>_<location>` | `branch:brand_a_sukhumvit` |
| Citation | `cite:<source_type>:<id>` | `cite:pubmed:12345678` |
| Cluster | `cluster:<topic>` | `cluster:periodontal_disease` |
| Keyword | `keyword:<brand>:<keyword_hash>` | `keyword:brand_a:abc123def` |
| Assignment | `assign:<author>+<brand>+<branch>` | `assign:dr_somchai+brand_a+sukhumvit` |
| Mention | `mention:<engine>:<query_hash>:<date>` | `mention:perplexity:xyz789:20260505` |
| Template | `tpl:<page_type>_v<version>` | `tpl:branch_landing_v2` |
| Voice Query | `voice:<lang>:<query_hash>` | `voice:th:abc123` |

### Why Fingerprints Matter

1. **Stable across systems**: ID เดียวกันใน Notion + Supabase + WordPress
2. **Human-readable**: Debug ได้โดยไม่ต้อง lookup
3. **Type-safe**: Prefix บอกประเภท (page vs entity vs citation)
4. **Indexable**: Faster than UUID for natural relationships
5. **Migration-safe**: ไม่ต้อง re-generate IDs เมื่อ migrate

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
  *_fingerprint          = natural unique ID (text)
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
  brand                  = denormalized brand_name for query speed
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

Part 19 (Data Quality Framework):
  - seo_data_quality_metrics (5 DAMA dimensions)

Part 20 (Measurement & KPIs):
  - All Tier 1 tables (KPI sources)

Part 21 (AI Operations & Embedding):
  - seo_brand_mentions
  - seo_llm_citations
  - seo_llm_query_simulations
  - seo_entity_embeddings (RAG infrastructure)

Part 23.1 (Citation Tier System):
  - seo_citations.evidence_tier + schema_evidence_level
  - seo_page_citations.citation_pattern (Pattern F)

Part 23.3 (Authority Validation):
  - seo_authors_reviewers (license + accreditation)
  - brands.accreditations + medical_advisory_board_url

Part 23.4 (Multi-Stage Editorial Review):
  - seo_editorial_reviews (5-stage workflow)

Part 23.5 (Core Web Vitals):
  - seo_x_ads_keywords_x_url_daily_logs.cwv_*

Part 23.6 (Accessibility):
  - seo_x_ads_keywords_x_url_daily_logs.cwv_score_accessibility
```

### By Operational Workflow

```yaml
Daily Workflow (automated):
  - seo_x_ads_keywords_x_url_daily_logs (GSC + GA4 + CWV ingestion)
  - seo_data_quality_metrics (quality measurement runs)

Weekly Workflow:
  - seo_x_ads_keywords_monthly_market_snapshot (market intelligence refresh)
  - seo_x_ads_keyword_serp_competitors (SERP analysis refresh)
  - seo_brand_mentions (AI engine probing)
  - seo_llm_citations (AI citation tracking)

Monthly Workflow:
  - seo_x_ads_keywords_monthly_market_snapshot (full snapshot)
  - seo_local_rankings (local SEO rankings)
  - seo_backlinks_data + seo_backlinks_links (backlink profile)

Quarterly Workflow:
  - Cluster health review (seo_topic_cluster_master)
  - Citation freshness audit (seo_citations.citation_freshness_status)
  - Schema change governance review (seo_schema_changes)

Continuous (event-driven):
  - seo_editorial_reviews (5-stage workflow per page lifecycle)
  - seo_website_page_master (page CRUD)
  - seo_entity_graph (entity additions/updates)
```

---

## 📜 Closing Notes

This document is the **complete data architecture specification** for EYWA™ PROTOCOL. It is designed to be read as a unified Day 1 system — every table here serves a specific role in the protocol's neural network.

### Document Status

```yaml
version: v1.1
date: 2026-05-05
status: Day 1 Specification (production roadmap reference)
total_tables: 28
total_groups: 9
companion_to: คัมภีร์ EYWA™ PROTOCOL v3.1
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

**END OF DOCUMENT — Schema_Overview EYWA v1.0**

*🌿 EYWA™ PROTOCOL Database Architecture • May 2026*  
*Companion to คัมภีร์ EYWA™ PROTOCOL v3.1*  
*EYWA™ is a registered service mark — Class 35+42, DIP Thailand (filed 2026-04-20)*  
*Source of Truth: Bible Part 5 (Architecture) + this document (Reference)*
