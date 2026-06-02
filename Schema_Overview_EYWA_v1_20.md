# 📊 Schema Overview — EYWA™ PROTOCOL Database

**Version:** v1.20 (2026-06-03) — DR-034 Intra-Page Answer Routing (PAA × FAQ) 🔒🧭
**Live database:** Supabase project `lffcbeszjqzioobqfdav` ("GTGT") · region `ap-northeast-1` · Postgres 17
**Total base tables:** 40 (in `public` schema, excluding `logs_2025`/`logs_2026` and backups)
**Spec stack:** Bible v3.23 · Handover v1.18 · Decision Records v1.20
**Audit method:** Full drift audit vs live `information_schema` performed 2026-05-30. Every column listed below was verified against the live database at audit time.

> **Reader heads-up:** v1.18 is a **full rewrite + audit** of v1.10. Aspirational columns from v1.0–v1.10 that never shipped are dropped (or moved to **Appendix H — Deferred v2.0 Provisions**). Every column under each table reflects the live database. Two new DR waves landed in this version:
> - **DR-030 Sensitive Topic Compliance** (Schema v1.17, 2026-05-27)
> - **DR-032 Multi-Center Hospital Brand Pattern** (Schema v1.18, 2026-05-27)
> - **DR-033 ICD Dual-Coding Standard** (Schema v1.19, 2026-06-02) — `seo_entity_condition` gains `icd11_code` + `icd10_cm_code`
> - **DR-034 Intra-Page Answer Routing (PAA × FAQ)** (Schema v1.20, 2026-06-03) — `seo_website_page_master` gains `intent_source_tier` + `paa_checked_at`

---

## Changelog

### v1.20 (2026-06-03) — DR-034 Intra-Page Answer Routing (PAA × FAQ) 🔒🧭

**Migration:** `eywa_w11_05_dr034_v20_page_master_paa_routing` (W11.5, applied 2026-06-03).

**`seo_website_page_master` 88 → 90 cols** — adds the two columns that record where a page's on-page intent coverage came from and whether PAA has been crawled:
- `intent_source_tier text NOT NULL DEFAULT 'template_only'` 🆕 — `CHECK IN ('paa','derived','template_only')`. Which signal drove the page's intent map: real PAA, derived (painpoint / predicted SERP features / voice), or the 8-intent template baseline.
- `paa_checked_at timestamptz` 🆕 — last PAA crawl time. `NULL` = never crawled (trigger a crawl, *not* tier-3). SET + empty `paa_questions` = checked, genuinely no PAA → tier-2/3.

Additive, non-breaking; the NOT NULL column carries a safe default so existing 1,376 rows auto-set to `template_only` (no backfill). **NOT** in the page fingerprint → no reference cascade. Drives **Content_Templates §4.5.4 Intra-Page Answer Routing** (understanding-PAA → body, decision-PAA → FAQ; page-level ≥8 intent coverage; tiered FAQ floor). PAA source is the existing **`seo_x_ads_keyword_serp_competitors.paa_questions text[]`** — the original proposal's `people_also_ask_json` / `paa_ai_content_json` / `related_searches` columns **do not exist** in the audited schema and were re-mapped to `paa_questions` + `keyword_painpoint` + `predicted_serp_features` + `seo_x_voice_search`. See **DR-034**.

### v1.19 (2026-06-02) — DR-033 ICD Dual-Coding Standard 🔒🩺🌐

**Migration:** `eywa_w11_04_dr033_v19_icd_dual_coding_condition` (W11.4, applied 2026-06-02).

**`seo_entity_condition` 38 → 40 cols** — adds the ICD-11 + US-CM coding fields that the §11.5 spec always intended but the live build omitted:
- `icd11_code text` 🆕 — ICD-11-MMS stem code (primary going forward). JSON-LD `codingSystem="ICD-11-MMS"`.
- `icd10_cm_code text` 🆕 — US ICD-10-CM clinical modification (granular; EN/international SEO). `codingSystem="ICD-10-CM"`.
- `icd10_code` (existing) comment clarified = WHO base ICD-10 (ICD-10-TM aligned for TH). `codingSystem="ICD-10"`.

Additive, nullable, non-breaking. **NOT** added to the entity fingerprint (`seo_entity_graph.icd_10_code`, WHO base, unchanged) → no reference cascade. Column naming follows the table's existing `icd10_code` (no-underscore) convention. See **DR-033**.

### v1.18 (2026-05-30) — DR-032 Multi-Center Hospital + Full Audit Rewrite 🔒🏥📐

**New table:**
- `seo_brand_centers` (17 columns) — Group 1 expanded to 8 tables. Center subdivision for `brand_structure='multi_center'` brands. First adopter: `vitality-hospital` (7 centers). DR-008 Two-Column Identity applied (`ctr_{ULID16}` fingerprint).

**Column additions:**
- `brands.brand_structure text NOT NULL DEFAULT 'monolithic' CHECK IN ('monolithic','multi_center')`
- `seo_website_page_master.center_slug text NULL` (soft FK to seo_brand_centers, validated by trigger)
- `seo_entity_graph.center_scope text[] NULL` (orthogonal to `brand_scope`)
- `seo_brand_centers` adds `notion_id`, `notion_synced_at`, `sync_state` (Wave 11.3 follow-up for Notion mirror)

**New functions / triggers (4 + 3):**
- Functions: `fn_set_fingerprint_center`, `fn_refresh_display_name_center`, `fn_validate_page_center_slug`
- Triggers on `seo_brand_centers`: `trg_set_fingerprint_center`, `trg_refresh_display_name_center`, `trg_prevent_fingerprint_change_center`
- Trigger on `seo_website_page_master`: `trg_validate_page_center_slug` (enforces NULL for `monolithic` brands; verifies center exists in `seo_brand_centers` for `multi_center` brands)

**Doc-level audit fixes (full rewrite delta vs v1.10):**
- §3.1 `brands` — dropped 20 aspirational columns that never landed (moved to Appendix H)
- §4.1 `seo_entity_graph` — dropped 17 aspirational columns; `aliases` corrected to `text` (was wrong `jsonb`)
- §5.1 `seo_website_page_master` — canonical 84-column listing, grouped by domain (Identity / Sitemap / Schema / Multilingual / Linking / Compliance / Ads / Lifecycle)
- §5.2 `seo_editorial_reviews` — column renamed `review_stage` → `review_type` to match live; full 21-column dump; enum updated
- §12.1 `chk_page_purpose` enum corrected: `('seo_organic','ads_landing','hybrid','utility','legal','thank_you')` (v1.10 listed wrong 4-value set)
- §12.1 `chk_index_directive` enum corrected: `('index','noindex','index_no_follow','noindex_no_follow')` (v1.10 listed wrong 4-value set)
- Appendix F — documented `fn_validate_edge_evidence_requirement`, `fn_validate_medical_signoff_for_contraindication`, `fn_check_reciprocal_link`, `fn_branches_sync_geo_point` (preexisting, never doc'd)

### v1.17 (2026-05-27) — DR-030 Sensitive Topic Compliance Layer 🔒⚖️🛡️

Two-dimensional tier matrix (Product Regulatory × Content Topic) applied at the page level.

- `seo_website_page_master` +6 cols:
  - `product_regulatory_tier smallint CHECK 1..4`
  - `content_topic_tier smallint CHECK 1..4`
  - `sensitive_topic_flag text CHECK IN ('none','low','medium','high','critical')`
  - `target_audience_segment text[]`
  - `legal_review_required boolean NOT NULL DEFAULT false`
  - `compliance_max_tier smallint GENERATED ALWAYS AS GREATEST(product_regulatory_tier, content_topic_tier) STORED`
- `seo_reviews` +3 cols (PDPA workflow for sensitive recovery testimonials):
  - `is_sensitive_recovery_testimonial boolean NOT NULL DEFAULT false`
  - `consent_record_id text`
  - `anonymization_status text CHECK IN ('not_required','pending','completed','verified')`
- `brands` +2 cols:
  - `positioning_mode text CHECK IN ('A-open-identity','B-dual-layer','B-weighted-recovery','C-implicit','baseline')`
  - `compliance_profile jsonb`
- `seo_editorial_reviews.review_type` CHECK enum extended with `'legal_compliance'`

### v1.16 (2026-05-12 PM) — Phase 1A BUILD COMPLETE + DR-008 Propagation 🏗️🔒

- Wave 10 finalized: DR-008 Two-Column Identity applied across 30+ tables (every fingerprinted table has `trg_set_fingerprint` + `trg_prevent_fingerprint_change` + display_name refresh trigger)
- Generic `fn_set_fingerprint_generic` used for tables that don't need custom fingerprint logic
- Per-table custom fingerprint functions: brands (`brnd_`), centers (`ctr_`), entity_graph (`ent_`), page_master (`pg_`)
- All N↔S tables have `notion_id` + `notion_synced_at` + `sync_state` columns
- Phase 1A scope: 39 tables built, no data migration; baseline for v1.17/v1.18 deltas

### v1.15 (2026-05-12) — Internal Linking HYBRID Architecture (DR-021 Locked) 🔒🔗

- NEW: `seo_page_internal_links` (28 cols) — page↔page junction with auto-reciprocal trigger
- `seo_website_page_master` extended with DR-021 link-strategy columns (priority/role/cross-brand)

### v1.14 (2026-05-12) — Concept Entity Subtype Lock (DR-014 Locked) 🔒💠

- `seo_entity_graph.entity_subtype text` with CHECK constraint for concept-typed entities (`framework` / `axis` / `health-belief`)

### v1.13 (2026-05-12) — Edge Vocabulary v3.5 Expansion (DR-013 Locked) 🔒🧬

- `seo_entity_relationships` (19 cols) added with 12-edge vocabulary including `causes`, `caused_by`, `contraindicates`, evidence FK, medical signoff triggers

### v1.12 (2026-05-12) — Ads Landing Page Track Phase 0 (DR-026 Proposed) 🌱📣

- 6 columns added to `seo_website_page_master` (page_purpose, ads_template_id, index_directive, conversion_event_primary/secondary, campaign_id)
- 6 columns added to `seo_x_ads_keywords_contextual_master` (seo_active, ad_active, ad_intent_score, ad_match_type_preferred, ad_landing_page_fp, ad_priority_tier)

### v1.11 (2026-05-12) — Restore Forgotten Schema (DR-024 + DR-025 Locked) 🔒🧬🏥

- Group 9: 9 entity extension tables (ingredients/devices/procedures/product/condition/drug/anatomy/organization/lab_test) — restored after v1.10 silent drop
- Group 1: Local SEO subsystem (`seo_branches` rename from seo_locations, `seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`)

### Earlier versions (archived)

v1.10 → v1.0: see `archive/Schema_Overview_EYWA_v1_10.md` for the historical document. **Note:** v1.10 file body actually documented through v1.16 changes; v1.18 is the first version where the filename and body content match; v1.19 (DR-033) keeps them matched (file renamed `…v1_18.md` → `…v1_19.md`); v1.20 (DR-034) likewise (file renamed `…v1_19.md` → `…v1_20.md`).

---

## 1. How to Read This Document

### Document Status

**This document is the authoritative reference for the EYWA Supabase schema.** It is regenerated from live `information_schema` queries at each version bump. Other documents (Bible, Handover, Decision Records) reference this doc for column-level detail.

| Source of truth | Used for |
|---|---|
| **This doc (Schema Overview)** | Column lists, types, constraints, triggers, indexes |
| `EYWA_PROTOCOL_v3_19.md` (Bible) | Strategic intent, why columns exist, workflow context |
| `DECISION_RECORDS.md` | Why a column was added or changed (DR-NNN cross-ref) |
| `EYWA_HANDOVER.md` | Operational sync patterns, n8n flows, Notion mirror behavior |

### How To Use This Document

1. **For schema verification:** open the §X.Y section for the table you care about; the column list mirrors live DB at audit time
2. **For DR provenance:** look for `(DR-NNN v1.X)` badges next to columns — that tells you which DR introduced the column
3. **For trigger logic:** see **Appendix F** for the trigger registry and SQL bodies
4. **For naming conventions:** see **Appendix C**
5. **For sync direction (N↔S vs S-only):** see the per-table `Sync:` line, or the master matrix in §2

### Conventions used in this doc

- **N↔S** = Notion is master, Supabase mirrors (or bidirectional via two-phase sync per DR-006)
- **S only** = Supabase-only; no Notion mirror (off-page ingest, telemetry, governance audit logs)
- 🔒 = DR locked; column is canonical
- 🌱 = DR proposed but locked; column may exist as Phase 0 stub
- 🆕 = Added in current spec version
- ⚠️ = Type mismatch or constraint drift; requires operator attention

---

## 2. System Architecture Overview

### The 10-Group Organization

| Group | Theme | Tables (count) | Sync Direction |
|---|---|---|---|
| **Group 1** | Brand & Organization | brands, seo_branches, seo_brand_centers 🆕 v1.18, seo_authors_reviewers, seo_doctor_assignments, seo_reviews, seo_directory_listings, seo_gbp_posts (**8**) | N↔S (master) · S only (reviews/directory_listings/gbp_posts via API ingest) |
| **Group 2** | Knowledge Architecture | seo_entity_graph, seo_topic_cluster_master, seo_citations, seo_page_citations, seo_entity_relationships (**5**) | N↔S |
| **Group 3** | Page System | seo_website_page_master, seo_editorial_reviews, seo_page_internal_links (**3**) | N↔S |
| **Group 4** | Keyword & Search Intelligence | seo_x_ads_keywords_contextual_master, seo_x_ads_keywords_monthly_market_snapshot, seo_x_ads_keyword_serp_competitors, seo_x_voice_search (**4**) | N↔S (master) · S only (monthly_snapshot, serp_competitors) |
| **Group 5** | Performance Fact Tables | seo_x_ads_keywords_x_url_daily_logs (alias for logs_YYYY partitions), seo_local_rankings (**2**) | S only |
| **Group 6** | Backlinks & Off-Page | seo_backlinks_data, seo_backlinks_links (**2**) | S only (Ahrefs/Moz/DFS ingest) |
| **Group 7** | AI Operations & Embeddings | seo_brand_mentions, seo_llm_citations, seo_llm_query_simulations, seo_entity_embeddings (**4**) | S only |
| **Group 8** | Data Quality & Governance | seo_data_quality_metrics, seo_schema_changes (**2**) | S only |
| **Group 9** | Entity Extensions & Templates | seo_entity_ingredients, seo_entity_devices, seo_entity_procedures, seo_entity_product, seo_entity_condition, seo_entity_drug, seo_entity_anatomy, seo_entity_organization, seo_entity_lab_test, seo_programmatic_templates (**10**) | S only (built without notion_id despite spec comment; treat as S-only — see §11 intro) |
| **Group 10** | Ads Landing Page Track (column extensions only) | (no new tables; columns on page_master + keyword master) | — |

**Total: 40 base tables** in `public` schema.

> **Note on Group 9 vs spec drift:** Spec comments on Group 9 tables mark them `N↔S`, but they were built without `notion_id` columns — practically these function as **S-only** lookup/detail tables (1:1 with entity_graph). v1.18 keeps the historical N↔S label in the spec comment but flags the practical S-only behavior here.

### Notion ↔ Supabase Sync Architecture (Two-Phase Sync per DR-006)

```
Markdown planning  →  Wave 1 (flat load)   →  Supabase rows w/ sync_state='flat_loaded'
                                                  ↓
                                             Wave 2 (Notion mirror)
                                                  ↓
                                              Notion pages created with notion_id stored back
                                              sync_state='notion_synced'
                                                  ↓
                                             Wave 3 (relations backfill)
                                                  ↓
                                              parent_notion_id / FK relations populated
                                              sync_state='relations_backfilled'
                                                  ↓
                                             Wave 4 (live sync)
                                                  ↓
                                              n8n bidirectional flow active
                                              sync_state='live'
```

> Wave 9 (2026-05-12) **removed the Notion FDW + wrappers extension**. Current sync mechanism is **n8n flows + Notion REST API**, not Supabase FDW. See `EYWA_HANDOVER.md` for n8n flow definitions.

### Sync direction by group (matrix)

| Group | Default direction | Exceptions |
|---|---|---|
| 1 | N↔S | seo_reviews, seo_directory_listings, seo_gbp_posts = S only (API ingest from GBP) |
| 2 | N↔S | seo_page_citations = S only (M:N junction; no notion_id) |
| 3 | N↔S | — |
| 4 | N↔S | snapshot tables = S only |
| 5–8 | S only | — |
| 9 | S only (practical) | spec comments say N↔S but no notion_id columns — see §11 intro |
| 10 | — | column extensions on page_master + keyword master |

### Required PostgreSQL Extensions

| Extension | Purpose | Required by |
|---|---|---|
| `uuid-ossp` | UUID generation (`gen_random_uuid`) | All tables w/ UUID PK |
| `pgcrypto` | Crypto helpers (alt UUID source) | DR-008 fingerprint generator |
| `pg_trgm` | Trigram fuzzy matching | EUG entity uniqueness guard |
| `unaccent` | Diacritic removal for slug normalization | DR-010 brand_slug, DR-008 display_name |
| `postgis` | Geo types (Point) | seo_branches.geo_point |
| `vector` (pgvector) | Vector embeddings | seo_entity_embeddings |

See **Appendix A** for installation order and per-table extension dependencies.

---

## 3. Group 1 — Brand & Organization (8 tables)

> Authoritative tables for brand identity, physical/local presence, medical staff, multi-center subdivision, and external reputation signals.
>
> **DR-032 v1.18 addition:** `seo_brand_centers` for multi-center hospital brands (e.g., Vitality Hospital).

### 3.1 `brands`

> **Purpose:** Authoritative brand registry. One row per brand (e.g., `vth-biodent`, `vitality-hospital`, `the-face-by-vertex`).
> **Sync:** N↔S (Notion master `[DB 1.1] Brand Database`, Supabase mirror via n8n)
> **PK:** Currently on `brand_name` (legacy from v1.0); UNIQUE on `id` (UUID), `brand_slug`, `fingerprint`, `notion_id`. Migration to id-as-PK deferred to v2.0.
> **Volume:** 10–50 rows (current: 15).
> **Bible:** §17.6 Group A (Brand Identity)

#### Columns (20 — full live snapshot)

| Column | Type | Constraint | Description |
|---|---|---|---|
| `id` | `uuid` | DEFAULT `gen_random_uuid()`, UNIQUE | Stable machine key (NOT current PK; v2.0 target). |
| `brand_name` | `text` | PK | Human-readable name (e.g. "VTH BioDent"). |
| `brand_slug` | `text` | UNIQUE NOT NULL | DR-010 v1.9 — URL-safe kebab-case (auto from brand_name via lowercase + dash normalization). |
| `fingerprint` | `text` | UNIQUE NOT NULL | DR-008 v1.9 — `brnd_{ULID16}` immutable machine ID. Auto-generated by `trg_set_fingerprint_brand`. Immutable via `trg_prevent_fingerprint_change`. |
| `fingerprint_display_name` | `text` | NOT NULL | DR-008 v1.9 — auto-computed `{fp_last_6}::{brand_slug}` by `trg_refresh_display_name_brand`. |
| `company` | `text` | nullable | Legal company name (e.g. "The Gifted Digital Co., Ltd."). |
| `status` | `text` | nullable | Lifecycle status (`'ACTIVE'`, `'IN ACTIVE'`, `'PENDING'`). |
| `brand_web_url` | `text` | nullable | Public marketing site URL. |
| `gsc_property_url` | `text` | nullable | Google Search Console property URL. |
| `ga4_property_id` | `text` | nullable | Google Analytics 4 property ID (e.g. `G-XXXXXXX`). |
| `brand_description` | `text` | nullable | Long-form brand description. |
| `notion_workspace` | `text` | nullable | Notion workspace tag for federation (`'vt_intelligence'` / `'other'`). |
| `notion_database_id` | `text` | nullable | Notion DB ID for per-brand database (if brand has its own workspace DB). |
| `notion_id` | `text` | UNIQUE WHERE NOT NULL | Notion page ID for brand's row in Notion `[DB 1.1] Brand Database`. |
| `workspace_id` | `text` | nullable | Internal workspace ID for federation routing. |
| `positioning_mode` 🆕 v1.17 | `text` | CHECK IN (`'A-open-identity'`,`'B-dual-layer'`,`'B-weighted-recovery'`,`'C-implicit'`,`'baseline'`) | DR-030 §6 — brand positioning mode for sensitive-topic content strategy. `'baseline'` = no sensitive topic (default for most brands). |
| `compliance_profile` 🆕 v1.17 | `jsonb` | nullable | DR-030 §2 — `{product_regulatory_tier_default, content_topic_tier_default, sensitive_topic_flag_default, medical_advisor_required, legitscript_status, ads_strategy, forbidden_claims[], approved_claims_source}`. Drives default tiers for new pages. |
| `brand_structure` 🆕 v1.18 | `text` | NOT NULL DEFAULT `'monolithic'`, CHECK IN (`'monolithic'`,`'multi_center'`) | DR-032 §1 — `'monolithic'` = standard single-brand pattern (all existing brands inherit). `'multi_center'` = opt-in for hospital-scope brands; activates `seo_brand_centers` subdivision + URL rewriting + per-center plugin behaviors. |
| `created_at` | `timestamptz` | NOT NULL DEFAULT `now()` | |
| `updated_at` | `timestamptz` | NOT NULL DEFAULT `now()` | |

#### Indexes

- `brands_pkey` PRIMARY KEY (brand_name)
- `brands_id_unique` UNIQUE (id)
- `brands_brand_slug_unique` UNIQUE (brand_slug)
- `brands_fingerprint_unique` UNIQUE (fingerprint)
- `brands_notion_id_key` UNIQUE (notion_id) WHERE notion_id IS NOT NULL

#### Triggers

- `trg_set_fingerprint_brand` BEFORE INSERT — auto-generate `brnd_{ULID16}` fingerprint + display_name
- `trg_refresh_display_name_brand` BEFORE UPDATE — refresh display_name if brand_slug changes
- `trg_prevent_fingerprint_change` BEFORE UPDATE OF fingerprint — DR-008 immutability enforcement

#### Constraints

- `chk_brand_structure` CHECK (brand_structure IN ('monolithic','multi_center'))
- `chk_positioning_mode` CHECK (positioning_mode IN ('A-open-identity','B-dual-layer','B-weighted-recovery','C-implicit','baseline'))

#### Aspirational columns dropped from this section

The v1.0–v1.10 doc body listed ~20 aspirational columns on `brands` that were never `ALTER TABLE`'d into the live database:
`vertical_family`, `healthcare_format`, `medical_specialty[]`, `primary_branch_id`, `accreditations`, `medical_advisory_board_url`, `wikidata_id`, `wikidata_verified_at`, `knowledge_panel_status`, `cpt_activation_flags`, `signature_offerings[]`, `brand_profile`, `active_languages[]`, `canonical_names`, `descriptions`, `brand_authority_score`, `brand_authority_breakdown`, `ai_citation_readiness`, `score_formula_version`, `score_computed_at`.

These are preserved in **Appendix H — Deferred v2.0 Provisions** for historical reference. Do not write SQL referencing these columns against the current database.

---

### 3.2 `seo_branches`

> **Purpose:** Local SEO master — physical branch locations with GBP integration. Renamed from `seo_locations` per DR-025 in v1.11.
> **Sync:** N↔S (Notion `Branches Database`, Supabase mirror)
> **Bible:** §10.5 Local SEO · Part 17.6 Group E
> **Volume:** 1–20 rows per brand.

#### Columns (60 — abridged to logical groups; full DDL in live `information_schema`)

**Identity & DR-008 (5):**
- `id uuid` UNIQUE
- `fingerprint text` (`brch_{ULID16}`)
- `fingerprint_display_name text`
- `branch_fingerprint text` (legacy v1.10 — preserved for n8n compat)
- `branch_slug text` (kebab-case canonical, UNIQUE per brand)

**Brand linkage (2):**
- `brand_id uuid` (FK → brands.id soft)
- `brand_slug text`

**Naming (4):**
- `branch_name text`
- `business_name_legal text` (Thai DBD registered name)
- `business_name_brand text` (marketing name, may differ)
- `canonical_names jsonb` (multilingual `{th, en}`)

**Address (10):**
- `address text` (free-form full)
- `street_address text`, `district text`, `city text`, `region text`
- `country_code text` (ISO 3166-1 alpha-2)
- `postal_code text`
- `formatted_address text` (Google geocoding result)
- `plus_code text`
- `latitude numeric`, `longitude numeric`
- `geo_point geometry(Point,4326)` (PostGIS; auto-synced from lat/lng via `trg_branches_sync_geo_point`)

**Contact (5):**
- `phone text`, `email text`, `line_id text`, `website_url text`
- `apple_maps_id text`, `facebook_page_url text`, `wongnai_url text`, `wongnai_id text`

**Operations (5):**
- `opening_hours jsonb` (Schema.org OpeningHoursSpecification)
- `special_hours jsonb` (holiday/exception)
- `status text` (`'active'`,`'closed'`,`'temp_closed'`,`'pending_opening'`)
- `is_primary boolean` (one per brand)
- `opened_date date`, `closed_date date`

**Services & staff linkage (5 array FK):**
- `services_at_branch text[]` (taxonomy)
- `services_offered_fps text[]` (FK → seo_entity_graph fingerprints)
- `specialties_at_branch text[]`
- `doctors_at_branch_fps text[]` (FK → seo_authors_reviewers fingerprints)
- `equipment_at_branch_fps text[]`

**GBP integration (6):**
- `gbp_place_id text`, `gbp_account_id text`, `gbp_categories text[]`
- `gbp_review_count integer`, `gbp_avg_rating numeric`, `gbp_last_synced_at timestamptz`

**Schema.org & assets (4):**
- `local_business_schema_type text` (`'LocalBusiness'`, `'MedicalClinic'`, `'DentalClinic'`, `'Hospital'`, etc.)
- `primary_photo_url text`
- `exterior_photos text[]`, `interior_photos text[]`

**Compliance (2):**
- `business_registration_no text` (Thai DBD เลขทะเบียนนิติบุคคล)
- `medical_license_no text` (เลขใบอนุญาตประกอบกิจการสถานพยาบาล)

**Organization FK (1):**
- `organization_entity_id uuid` (FK → seo_entity_graph.id for parent organization)

**Notion sync (3):**
- `notion_id text`, `notion_synced_at timestamptz`, `parent_notion_id text`, `sync_state text DEFAULT 'flat_loaded'`

**Standard (2):**
- `created_at timestamptz`, `updated_at timestamptz`

#### Triggers
- `trg_set_fingerprint` (generic) BEFORE INSERT
- `trg_prevent_fingerprint_change` BEFORE UPDATE
- `trg_branches_sync_geo_point` BEFORE INSERT/UPDATE — auto-derives `geo_point` from `latitude` + `longitude`

---

### 3.3 `seo_authors_reviewers` (renamed `seo_authors` in v1.9)

> **Purpose:** Doctor/author registry — license verification + E-E-A-T compliance for medical content authority.
> **Sync:** N↔S (Notion `Medical Team Database`, Supabase mirror)
> **Bible:** §23.3 Authors/Reviewers E-E-A-T
> **Volume:** 1–30 per brand; shared across brands via `seo_doctor_assignments`.

#### Columns (26)

| Column | Type | Notes |
|---|---|---|
| `id uuid` UNIQUE | machine key |
| `fingerprint text` | `auth_{ULID16}` |
| `fingerprint_display_name text` | DR-008 |
| `full_name text` | Display name (TH or EN) |
| `canonical_names jsonb` | `{th, en, zh, ...}` multilingual |
| `photo_url text` | Schema.org Person image |
| `credential_types text[]` | `{MD, DDS, PhD, MD-PhD, RPh, RN, PharmD, DPT}` |
| `medical_license_number text` | |
| `medical_license_country text` | ISO 3166-1 alpha-2 |
| `medical_license_verified_at timestamptz` | Last verification date |
| `board_certifications jsonb` | `[{board, year, expires}, ...]` |
| `is_advisory_board_member boolean` | Bible Part 23.3 |
| `brand_scope text[]` | DR-010 — brands this doctor is contracted to |
| `bio text` | Long bio for Schema.org Person |
| `short_bio text` | One-line summary |
| `primary_specialty text` | Primary medical specialty |
| `specialties text[]` | All practiced specialties |
| `languages_spoken text[]` | `{th, en, zh, ja, ko, ar, fr, es}` |
| `email text` | |
| `linkedin_url text` | |
| `is_active boolean` | |
| `notion_id text`, `notion_synced_at`, `sync_state` | N↔S |
| `created_at`, `updated_at` | |

#### Notion-side fields NOT mirrored to Supabase

The Notion `Medical Team Database` has additional operator-facing fields for UI/profile cards that are not in Supabase:
- Contact Number (phone)
- Doctor English Name
- Title / Degree
- Nickname
- Gender
- Credentials Summary (denormalized from credential_types)
- Profile Priority (`'Featured'` / `'Standard'`)
- Slug

These are Notion-only UI fields; operator-managed in Notion, not synced.

---

### 3.4 `seo_doctor_assignments` (renamed `seo_brand_doctors` in v1.9)

> **Purpose:** Junction (author × brand × branch). Supports cross-brand doctor sharing within EYWA federation.
> **Sync:** N↔S (Notion `Doctor Assignments Database`)
> **Volume:** ~1 row per (author × brand) pair.

#### Columns (13)

| Column | Type | Notes |
|---|---|---|
| `id uuid` UNIQUE | |
| `fingerprint text` | `docasg_{ULID16}` |
| `fingerprint_display_name text` | `{fp_last_6}::{brand_slug}::{author_name}::{role}` |
| `author_id uuid` | FK → seo_authors_reviewers.id |
| `author_fp text` | FK → seo_authors_reviewers.fingerprint |
| `brand_id uuid` | FK → brands.id |
| `branch_id uuid` | FK → seo_branches.id (NULL = brand-wide assignment) |
| `role_at_brand text` | CHECK IN (`'reviewer'`,`'author'`,`'consultant'`,`'medical_director'`,`'attending'`,`'visiting'`) |
| `is_primary_role boolean` | True = primary brand affiliation for this doctor |
| `started_at date` | |
| `ended_at date` | NULL = active |
| `created_at`, `updated_at` | |

---

### 3.5 `seo_reviews` (Local SEO — Multi-platform customer reviews) 🔒 v1.11

> **Purpose:** Multi-platform reviews (GBP, Wongnai, Pantip, Facebook, Google Maps) + PDPA workflow for sensitive testimonials.
> **Sync:** **S only** — ingested via GBP API + n8n flows (E1)
> **DR-025 v1.11** — Local SEO subsystem
> **DR-030 v1.17** — +3 cols for sensitive recovery testimonials (consent + anonymization workflow)
> **Volume:** ~1k–100k rows per brand (high cardinality from review platforms).

#### Columns (45 — abridged)

**Identity & lineage (5):**
- `id uuid` UNIQUE
- `fingerprint text` (`rev_{ULID16}`)
- `fingerprint_display_name text`
- `branch_id uuid` (FK → seo_branches.id)
- `brand_id uuid`

**Source platform (5):**
- `source_platform text` (`'GBP'`, `'Wongnai'`, `'Pantip'`, `'Facebook'`, `'Google_Maps'`, `'TripAdvisor'`)
- `source_review_id text` (platform's review ID)
- `source_url text`
- `last_synced_at timestamptz`
- `is_verified_customer boolean`

**Reviewer (4):**
- `reviewer_name text`
- `reviewer_anonymized boolean`
- `reviewer_profile_url text`
- `is_local_guide boolean` (GBP-specific)

**Review content (6):**
- `rating numeric` (1.0–5.0)
- `review_title text`
- `review_text text`
- `review_language text`
- `review_photos text[]`
- `review_videos text[]`
- `posted_at timestamptz`

**Operator response workflow (7):**
- `response_required boolean`
- `response_priority text` (`'urgent'`,`'high'`,`'normal'`,`'low'`)
- `response_status text` (`'pending'`,`'drafted'`,`'legal_review'`,`'sent'`,`'no_response'`)
- `response_text text`
- `response_language text`
- `response_drafted_by_fp text` (FK → seo_authors_reviewers)
- `response_legal_reviewed boolean`
- `responded_by_fp text`
- `responded_at timestamptz`

**PDPA workflow (2 baseline + 3 NEW DR-030 v1.17):**
- `pdpa_risk_flag boolean` — generic baseline flag
- `pdpa_notes text`
- 🆕 `is_sensitive_recovery_testimonial boolean NOT NULL DEFAULT false` — DR-030 §5 trigger for tightened workflow
- 🆕 `consent_record_id text` — external pointer (Notion / contract DMS)
- 🆕 `anonymization_status text` CHECK IN (`'not_required'`,`'pending'`,`'completed'`,`'verified'`) — must reach `'verified'` before `responded_at` may be set when `is_sensitive_recovery_testimonial=true`

**AI extracted (4):**
- `detected_topics text[]`
- `sentiment text` (`'positive'`,`'neutral'`,`'negative'`,`'mixed'`)
- `sentiment_score numeric`
- `mentioned_entities_fps text[]` (FK → seo_entity_graph)
- `mentioned_doctors_fps text[]` (FK → seo_authors_reviewers)

**Moderation (3):**
- `is_flagged boolean`
- `flag_reason text`
- `flag_reported_at timestamptz`

**Standard (2):**
- `created_at`, `updated_at`

#### DR-030 Sensitive Recovery Testimonial Workflow

When `is_sensitive_recovery_testimonial=true`:
1. `anonymization_status` must transition `pending` → `completed` → `verified` before publish
2. `consent_record_id` must point to a valid consent record (external storage in Notion or contract DMS)
3. DPO sign-off required on retention policy
4. 30-day deletion-on-request SLA (tighter than baseline PDPA Article 30)

App-layer constraint (Phase 1A): enforced in n8n flow E1.5; database-layer trigger deferred to v1.19+.

---

### 3.6 `seo_directory_listings` 🔒 v1.11

> **Purpose:** NAP (Name/Address/Phone) citations across third-party directories + auto-detect inconsistency.
> **Sync:** S only — auto-detected via n8n flow E3
> **Distinct from `seo_citations`** which is academic/medical citation pool.
> **Bible:** Local SEO §10.5

37 columns. Key fields:
- `directory_name text` (`'YellowPages_TH'`, `'Wongnai'`, `'TripAdvisor'`, etc.)
- `listing_url text`
- `nap_name text`, `nap_address text`, `nap_phone text` (as found on directory)
- `nap_consistency_score numeric` (vs branch canonical)
- `nap_mismatch_flags text[]` (which fields disagree)
- `is_claimed boolean`
- `claim_status text`
- `last_audited_at timestamptz`

(Full column list in live DB; this section will be expanded in v1.19 if directory listings become a primary editorial workflow surface. Currently low-touch S-only.)

---

### 3.7 `seo_gbp_posts` 🔒 v1.11

> **Purpose:** Google Business Profile Posts management + local archive.
> **Sync:** S only — n8n flow E2/E4 (publish to GBP) + E4 (archive responses)

45 columns. Key fields:
- `gbp_post_id text` (Google's ID)
- `post_type text` (`'EVENT'`, `'OFFER'`, `'WHATS_NEW'`, `'PRODUCT'`)
- `headline text`, `body text`, `cta_label text`, `cta_url text`
- `event_start_date`, `event_end_date`, `offer_coupon_code`, `offer_terms`
- `media_urls text[]`
- `branch_id uuid` (FK → seo_branches)
- `scheduled_publish_at timestamptz`, `published_at`, `expires_at`
- `gbp_views_count int`, `gbp_clicks_count int`
- `status text` (`'draft'`,`'scheduled'`,`'published'`,`'expired'`,`'failed'`)

---

### 3.8 `seo_brand_centers` 🆕 v1.18 (DR-032)

> **Purpose:** Center subdivision for brands where `brands.brand_structure='multi_center'`. One row per center within a multi-center hospital brand.
> **Sync:** N↔S (Notion `Brand Centers Database`, Supabase mirror via Wave 11.3 follow-up)
> **First adopter:** `vitality-hospital` (7 centers — Vital Sleep, Vital Sleep Intimacy, Vital Breathing, Vital Facial Pain, Vital Wellness, Vital Effortless Weight Loss, Vital Brain Center)
> **DR:** DR-032 (Locked 2026-05-25) — Multi-Center Hospital Brand Pattern
> **Bible:** §25.13 (post-lock propagation)

#### Columns (17)

| Column | Type | Constraint | Description |
|---|---|---|---|
| `fingerprint` | `text` | PRIMARY KEY | DR-008 — `ctr_{ULID16}` immutable. Auto-generated by `trg_set_fingerprint_center`. |
| `fingerprint_display_name` | `text` | NOT NULL | DR-008 — `{fp_last_6}::{brand_slug}::{center_slug}` auto-computed by `trg_refresh_display_name_center`. |
| `brand_id` | `text` | NOT NULL, FK → `brands(brand_slug)` ON DELETE CASCADE | Parent brand. Note: this stores `brand_slug` (text), not `brands.id` (UUID). |
| `center_slug` | `text` | NOT NULL | Canonical key (e.g. `'vital-sleep'`). kebab-case. |
| `center_name` | `jsonb` | NOT NULL | DR-009 Tier 1 multilingual `{"th":"...","en":"..."}` |
| `url_segment` | `text` | NOT NULL | URL-safe segment (may differ from `center_slug`, e.g. `'vitalsleep'`). App routing must reserve known segments to prevent slug collisions. |
| `positioning_one_line` | `jsonb` | nullable | DR-009 multilingual one-liner tagline. |
| `signature_methodologies` | `text[]` | nullable | e.g. `{'Sleep Restoration Program', 'Couples Sleep Twin'}` |
| `color_treatment_hex` | `text` | nullable | DR-029 — visual treatment hex for header band, footer accent. |
| `position_order` | `integer` | NOT NULL DEFAULT 0 | Nav ordering. |
| `status` | `text` | NOT NULL DEFAULT `'planning'`, CHECK IN (`'planning'`,`'active'`,`'paused'`,`'sunset'`) | Lifecycle. |
| `anchor_outcome` | `text` | nullable | E.g. `"ISI ≥ 7-point reduction; AHI normalization on PAP / oral appliance"` |
| `notion_id` 🆕 Wave 11.3 | `text` | UNIQUE WHERE NOT NULL | N↔S sync — Notion page ID. |
| `notion_synced_at` 🆕 Wave 11.3 | `timestamptz` | nullable | Last Notion sync timestamp. |
| `sync_state` 🆕 Wave 11.3 | `text` | NOT NULL DEFAULT `'flat_loaded'`, CHECK IN (`'flat_loaded'`,`'notion_synced'`,`'relations_backfilled'`,`'live'`) | DR-006 Two-Phase Sync state. |
| `created_at` | `timestamptz` | NOT NULL DEFAULT `now()` | |
| `updated_at` | `timestamptz` | NOT NULL DEFAULT `now()` | |

#### Indexes

- PRIMARY KEY (fingerprint)
- UNIQUE (brand_id, center_slug)
- UNIQUE (brand_id, url_segment)
- `idx_seo_brand_centers_brand_id` btree (brand_id)
- `idx_seo_brand_centers_status` btree (status)
- `idx_brand_centers_notion_id` UNIQUE btree (notion_id) WHERE notion_id IS NOT NULL

#### Triggers

- `trg_set_fingerprint_center` BEFORE INSERT → `fn_set_fingerprint_center()` — generates `ctr_{ULID16}` if NULL, computes display_name
- `trg_refresh_display_name_center` BEFORE UPDATE → `fn_refresh_display_name_center()` — refresh display_name if brand_id or center_slug changes; bump updated_at
- `trg_prevent_fingerprint_change_center` BEFORE UPDATE OF fingerprint → `fn_prevent_fingerprint_change()` (shared) — DR-008 immutability

#### Cross-table impacts

DR-032 also added these column-level relationships:

1. `seo_website_page_master.center_slug text NULL` — when `brand.brand_structure='multi_center'`, this assigns a page to a center (NULL = umbrella/hospital-wide page like Home/About/Method/Membership). Validated by `trg_validate_page_center_slug` — must be NULL when brand is monolithic; must match a `seo_brand_centers.center_slug` when brand is multi_center.
2. `seo_entity_graph.center_scope text[] NULL` — orthogonal to `brand_scope[]`. Lists center_slugs within the brand that own/use the entity. GIN-indexed via `idx_entity_graph_center_scope`.

#### URL pattern (extends DR-004)

When `brand_structure='multi_center'`:
```
{brand_domain}/{lang}/{center_url_segment}/{page_slug}/
```
e.g. `vitalityhospital.com/th/vitalsleep/insomnia-overview/`

When `brand_structure='monolithic'`: unchanged DR-004 behavior `{brand_domain}/{lang}/{page_slug}/`.

#### Internal linking governance (extends DR-021)

| Link type | Governance |
|---|---|
| Intra-center (same center) | Default approved — no per-link justification |
| Intra-brand cross-center (Vital Sleep → Vital Brain within Vitality) | **Default approved** — recorded as `link_type='cross_center_intra_brand'` in `seo_page_internal_links` for analytics, NOT gated |
| Cross-brand (Vitality ↔ Biodent) | Existing DR-021 governance — `is_cross_brand=true` + `cross_brand_justification` required |

---

## 4. Group 2 — Knowledge Architecture (5 tables)

> Entity graph (universal concepts), topic clusters (SKOS classification), citation pool (evidence backing), entity relationships (typed edges), and the page↔citation junction.

### 4.1 `seo_entity_graph`

> **Purpose:** Master of every named entity (condition, treatment, ingredient, drug, etc.) used across EYWA brands. Foundation of the Knowledge Graph.
> **Sync:** N↔S (Notion `🧬 Entity Graph`, Supabase mirror)
> **DR:** DR-008 (Two-Column Identity), DR-013 (edge vocab — see §4.5), DR-014 (entity_subtype lock for concept type), DR-024 (links to Group 9 extensions), DR-032 (center_scope)
> **Volume:** ~500–5,000 per brand · 466 current rows (VTH BioDent + VitalSleep and Wellness only).

#### Columns (34 — full live snapshot)

| Column | Type | Notes |
|---|---|---|
| `id` `uuid` UNIQUE | machine key |
| `fingerprint` `text` | `ent_{ULID16}` (DR-008) |
| `fingerprint_display_name` `text` | `{fp_last_6}::{entity_slug}` |
| `entity_fingerprint` `text` | **Legacy v1.10** — preserved for n8n compat (drop in v2.0) |
| `entity_name` `text` | Canonical display name |
| `entity_slug` `text` | Canonical machine key (immutable) |
| `entity_type` `text` | CHECK enum — see below |
| `entity_subtype` `text` 🆕 v1.14 | DR-014 — for `entity_type='concept'` only: CHECK IN (`'framework'`,`'axis'`,`'health-belief'`) |
| `parent_entity_fp` `text` | **Legacy** — use `seo_entity_relationships` w/ `edge_type='child_of'` for typed edges (Bible Part 2.7); kept for backward compat |
| `topic_cluster_id` `text` | denormalized cluster key (FK soft → seo_topic_cluster_master.cluster_slug) |
| `topic_cluster_name` `text` | denormalized cluster name |
| `schema_org_type` `text` | `'MedicalCondition'`, `'MedicalTherapy'`, `'MedicalProcedure'`, `'Symptom'`, `'MedicalSpecialty'`, `'Drug'`, `'MedicalDevice'`, etc. |
| `entity_authority_score` `numeric` | 0–100, DR-013 evidence rollup |
| `search_volume_total` `integer` | Aggregated monthly search volume across keywords mapped to entity |
| `brand_scope` `text[]` | DR-010 — brands this entity is in scope for (`['*']` = universal) |
| `brand_scope_id` `text` | DR-008 single-brand fast path (NULL for multi-brand) |
| `brand_scope_name` `text` | Denormalized brand name when single-brand |
| `entity_lifecycle` `text` | `'Emerging'`, `'Growing'`, `'Mature'`, `'Declining'` |
| `programmatic_eligible` `boolean` | True = OK to auto-spawn programmatic pages |
| `wikipedia_url` `text` | sameAs trust signal |
| `wikidata_id` `text` | Q-number for Google Knowledge Graph linkage |
| `competing_entities` `text` | Plain-text notes on competitor entity targets |
| `ai_entity_summary` `text` | AI-generated brief for Schema.org `description` |
| `hreflang_group` `text` | Multilingual entity grouping |
| `aliases` `text` ⚠️ | Plain text (NOT jsonb as some legacy docs claim) |
| `icd_10_code` `text` | WHO base ICD-10 (ICD-10-TM aligned for TH market) — **universal entity code + fingerprint key**. Emitted in `MedicalCondition.code[]` as `codingSystem:"ICD-10"`. Per **DR-033**, the full per-condition coding set (`icd11_code` ICD-11-MMS primary + `icd10_cm_code` US clinical-mod) lives on **`seo_entity_condition` §11.5** (built v1.19), not on this universal table. |
| `content_gap_flag` `boolean` | True = entity surfaces but no canonical page yet |
| `related_entities_fps` `text[]` | Array of fingerprints (for quick lookup; canonical edges live in seo_entity_relationships) |
| `center_scope` `text[]` 🆕 v1.18 | DR-032 — orthogonal to `brand_scope[]`. Lists center_slugs within the brand that own/use the entity. GIN-indexed. |
| `notion_id` `text` | N↔S sync |
| `notion_synced_at` `timestamptz` | |
| `last_graph_update` `timestamptz` | |
| `created_at`, `updated_at` `timestamptz` | |

#### `entity_type` CHECK enum

Live: `('condition','symptom','treatment','technology','specialty','anatomy','drug','procedure','concept','product','ingredient','device','organization','lab_test')`. The 9 extension types (ingredient/device/procedure/product/condition/drug/anatomy/organization/lab_test) bind to Group 9 detail tables.

#### Indexes

- PRIMARY KEY (id)
- UNIQUE (fingerprint)
- UNIQUE (entity_slug)
- `idx_entity_graph_center_scope` GIN (center_scope) WHERE center_scope IS NOT NULL
- `idx_entity_graph_brand_scope` GIN (brand_scope)
- `idx_entity_graph_topic_cluster` btree (topic_cluster_id)

#### Triggers

- `trg_set_fingerprint_entity_graph` BEFORE INSERT → `fn_set_fingerprint_entity_graph()` — generates `ent_{ULID16}` + display_name
- `trg_refresh_display_name_entity_graph` BEFORE UPDATE → refreshes display_name when entity_slug changes
- `trg_prevent_fingerprint_change_entity_graph` BEFORE UPDATE OF fingerprint — DR-008 immutability
- `trg_brand_scope_names` BEFORE INSERT/UPDATE — populates `brand_scope_id` + `brand_scope_name` denorm fields when single brand_scope

#### Aspirational columns dropped from this section

The v1.0–v1.10 doc body listed these columns that were never `ALTER TABLE`'d:
`canonical_names jsonb`, `descriptions jsonb`, `brand_display_names jsonb`, `icd_11_code`, `snomed_ct_id`, `mesh_id`, `umls_cui`, `same_as text[]`, `applicable_verticals text[]`, `evidence_level text`, `type_properties jsonb`, `reviewed_by_fp`, `freshness_status`, `last_reviewed_at`, `entity_authority_breakdown jsonb`, `entity_freshness_score`, `entity_completeness_score`, `score_formula_version`, `score_computed_at`, `hierarchy_path`, `brand_scope_primary` (GENERATED), `aliases jsonb` (live is `text`).

Preserved in **Appendix H — Deferred v2.0 Provisions**.

---

### 4.2 `seo_topic_cluster_master`

> **Purpose:** SKOS-style topic cluster registry. Four facets: topical (medical domain), content_format (page type taxonomy), audience (persona), section_meta (sitemap section).
> **Sync:** N↔S (Notion `Topic Cluster Master` — created 2026-05-30)
> **DR:** Bible Part 7 SKOS pattern
> **Volume:** ~10–50 per brand.

#### Columns (27)

| Column | Type | Notes |
|---|---|---|
| `id` `uuid` UNIQUE | |
| `fingerprint` `text` | `tcls_{ULID16}` |
| `fingerprint_display_name` `text` | |
| `cluster_slug` `text` | UNIQUE per brand |
| `cluster_name` `text` | Display name |
| `cluster_type` `text` | CHECK IN (`'topical'`,`'content_format'`,`'audience'`,`'section_meta'`) |
| `parent_cluster_fp` `text` | Self-FK for hierarchy |
| `hierarchy_level` `smallint` | 0=root, 1=child, etc. |
| `skos_concept_scheme` `text` | SKOS scheme URI |
| `canonical_names` `jsonb` | Multilingual `{th, en, ...}` |
| `aliases` `jsonb` | Multilingual aliases array per language |
| `descriptions` `jsonb` | Multilingual descriptions |
| `brand_scope` `text[]` | DR-010 |
| `brand_scope_primary` `text` | Single primary brand (denorm) |
| `cluster_facet` `text` | Subcategory within cluster_type |
| `cluster_health_score` `numeric` | 0–100; computed nightly via cron |
| `cluster_topical_authority` `numeric` | 0–100 |
| `cluster_health_breakdown` `jsonb` | Score factors |
| `cluster_health_formula_version` `text` | E.g. `'v1.0'` |
| `cluster_health_computed_at` `timestamptz` | |
| `status` `text` | `'active'`, `'draft'`, `'archived'` |
| `notion_id` `text`, `parent_notion_id` `text`, `notion_synced_at`, `sync_state` | N↔S sync (Two-Phase per DR-006) |
| `created_at`, `updated_at` | |

---

### 4.3 `seo_citations`

> **Purpose:** Academic citation pool (PubMed/DOI/clinical guidelines/government sources). 6-tier hierarchy per Bible Part 23.1.
> **Sync:** N↔S (Notion `Citations Pool` — created 2026-05-30)
> **Distinct from:** `seo_directory_listings` (Local SEO NAP citations)
> **Volume:** ~50–500 per brand (Phase B.2 seeded ≥5 per pillar).

#### Columns (38)

**Identity & lineage:**
- `id uuid`, `fingerprint text` (`cite_{ULID16}`), `fingerprint_display_name text`, `citation_slug text`

**Bibliographic (12):**
- `title text`, `authors text[]`, `publication_year smallint`
- `pubmed_pmid text`, `doi text`, `isbn text`, `url text`, `archive_url text`
- `journal_name text`, `publisher_name text`
- `source_org_fp text` (FK → seo_entity_organization)
- `publication_date date`

**Classification (4):**
- `citation_tier smallint` (1–6 per Bible Part 23.1; 1=meta-analysis, 6=expert opinion)
- `citation_type text` (`'journal_article'`, `'clinical_guideline'`, `'systematic_review'`, `'rct'`, `'book'`, `'government'`, `'organization'`, `'website'`)
- `study_type text` (`'meta_analysis'`, `'systematic_review'`, `'rct'`, `'cohort'`, `'case_control'`, `'case_series'`, `'expert_opinion'`, `'in_vitro'`, `'animal'`)
- `country_of_origin text`, `language_code text`, `is_thai_specific boolean`

**Authority scoring (4):**
- `citation_authority_weight numeric` — computed weight 0.0–1.0
- `authority_breakdown jsonb` — score factors
- `authority_formula_version text`
- `authority_computed_at timestamptz`

**Content (3):**
- `abstract text`
- `key_findings text[]`
- `brand_scope text[]`

**Verification & status (4):**
- `is_retracted boolean`, `retracted_at timestamptz`
- `last_verified_at timestamptz`
- `verification_status text` (`'verified'`,`'pending'`,`'broken'`,`'unverified'`)

**Notion sync (3):**
- `notion_id text`, `notion_synced_at`, `sync_state`

**Standard (2):** `created_at`, `updated_at`

---

### 4.4 `seo_page_citations`

> **Purpose:** Junction table page ↔ citation. A page may cite the same source for different purposes (claim backing vs methodology vs counter-evidence).
> **Sync:** **S only** (no notion_id — built as S-only M:N junction)
> **Volume:** ~5–20 citations per page.

#### Columns (15)

- `id uuid`, `fingerprint text` (`pcit_{ULID16}`), `fingerprint_display_name text`
- `page_fp text` (FK → seo_website_page_master.fingerprint)
- `citation_fp text` (FK → seo_citations.fingerprint)
- `citation_purpose text` CHECK IN (`'primary_claim_backing'`,`'supporting_evidence'`,`'counter_evidence'`,`'methodology'`,`'background'`,`'further_reading'`)
- `citation_anchor_text text` — visible text near the citation marker on the page
- `citation_position text` — section identifier (e.g. `'§3.2-paragraph-2'`)
- `claim_being_backed text` — short paraphrase of what the citation supports
- `evidence_strength smallint` — 1–5, operator scored
- `is_primary boolean` — primary citation for the claim
- `notes text`
- `created_at`, `updated_at`

---

### 4.5 `seo_entity_relationships`

> **Purpose:** Typed edge junction over `seo_entity_graph`. Models 12-edge vocabulary (DR-013 v3.5) including medical edges (`treats`, `causes`, `caused_by`, `contraindicates`) with evidence FK + medical signoff requirements.
> **Sync:** N↔S (Notion `Entity Relationships` — created 2026-05-30)
> **DR:** DR-013 (Edge Vocab v3.5 Locked v1.13)
> **Volume:** ~200–2,000 edges per brand (estimated 2–10× entity count).

#### Columns (19)

| Column | Type | Notes |
|---|---|---|
| `id uuid` UNIQUE | |
| `fingerprint text` | `edge_{ULID16}` |
| `fingerprint_display_name text` | |
| `from_entity_fp text` | FK → seo_entity_graph.fingerprint |
| `to_entity_fp text` | FK → seo_entity_graph.fingerprint |
| `edge_type text` | DR-013 vocab — see below |
| `edge_note text` | Free-form context |
| `edge_strength smallint` | 1–5 operator scored |
| `edge_evidence_score numeric` | 0.0–1.0, computed from linked citations |
| `edge_evidence_citation text` | FK → seo_citations.fingerprint (required for `causes`, `treats`, `contraindicates` edges per `trg_validate_edge_evidence`) |
| `medical_reviewer_signoff_at timestamptz` | Required for `contraindicates` edges per `trg_validate_medical_signoff` |
| `medical_reviewer_fp text` | FK → seo_authors_reviewers.fingerprint |
| `brand_scope text[]` | |
| `status text` | `'active'`, `'draft'`, `'pending_signoff'`, `'deprecated'` |
| `notion_id text`, `notion_synced_at`, `sync_state` | N↔S |
| `created_at`, `updated_at` | |

#### DR-013 Edge Vocabulary (12 edge types)

| Edge type | Description | Evidence required? | Medical signoff? |
|---|---|---|---|
| `child_of` | Hierarchical parent (replaces legacy `parent_entity_fp`) | No | No |
| `part_of` | Mereological — anatomy components | No | No |
| `related_to` | Generic association | No | No |
| `treats` | A treats B (treatment → condition) | **Yes (citation)** | No |
| `treated_by` | Inverse of treats | **Yes** | No |
| `causes` | A causes B (etiology) | **Yes** | No |
| `caused_by` | Inverse of causes | **Yes** | No |
| `contraindicates` | A contraindicates B (safety-critical) | **Yes** | **Yes (MD signoff)** |
| `symptom_of` | A is a symptom of B | **Yes** | No |
| `diagnoses` | A (test/procedure) diagnoses B (condition) | **Yes** | No |
| `prevents` | A prevents B | **Yes** | No |
| `risk_factor_for` | A is a risk factor for B | **Yes** | No |

#### Triggers

- `trg_set_fingerprint` BEFORE INSERT — generic
- `trg_prevent_fingerprint_change` BEFORE UPDATE
- `trg_validate_edge_evidence` BEFORE INSERT/UPDATE → `fn_validate_edge_evidence_requirement()` — for `causes`/`treats`/`contraindicates`/etc., raises if `edge_evidence_citation` is NULL
- `trg_validate_medical_signoff` BEFORE INSERT/UPDATE → `fn_validate_medical_signoff_for_contraindication()` — for `contraindicates`, raises if `medical_reviewer_signoff_at` is NULL

---

## 5. Group 3 — Page System (3 tables)

> The page master + per-page editorial workflow + page↔page internal linking junction. Largest single table in the system (`seo_website_page_master` at 88 columns).

### 5.1 `seo_website_page_master`

> **Purpose:** Canonical URL/page master. Every page that EYWA tracks (planning → published → live) gets one row.
> **Sync:** N↔S (Notion `🌐 Website & SEO Page Intelligent Master`)
> **DR:** DR-008 (identity), DR-015 (marketplace reconciliation), DR-016 (viability assessment / thin page risk), DR-017 (content brief field), DR-021 (internal linking HYBRID), DR-026 (Ads LP Phase 0), DR-030 (compliance tiers), DR-032 (center_slug), DR-034 (PAA × FAQ intent routing)
> **Volume:** 100s–10,000s per brand.
> **Current data:** 1,376 rows (VitalSleep and Wellness only).

#### Columns (90 — canonical full list grouped by domain)

**Identity (5):**
- `id` `uuid` PK DEFAULT `gen_random_uuid()`
- `page_fingerprint` `text` NOT NULL — **legacy v1.10**, preserved for n8n compat
- `fingerprint` `text` NOT NULL — DR-008 canonical `page_{16HEX}` (CHECK `^page_[0-9A-F]{16}$`)
- `fingerprint_display_name` `text` NOT NULL — `{fp_last_6}::{brand_slug}::{slug}`
- `notion_id` `text` — Notion mirror

**Brand & taxonomy (5):**
- `brand_id` `text` (stores `brands.id` UUID as text)
- `brand_name` `text` (denormalized)
- `cluster_id` `text` (FK soft → seo_topic_cluster_master)
- `sitemap_node_id` `text` — operator-facing sitemap identifier
- `sitemap_section` `text` — operator-defined section grouping

**URL & SEO meta (5):**
- `slug` `text` — page slug
- `seo_title` `text` — `<title>` tag
- `meta_description` `text` — meta description
- `canonical_url` `text` — `<link rel=canonical>`
- `redirect_target` `text` — destination if redirect

**Naming & display (3):**
- `page_name` `text` — operator-facing name
- `parent_page_name` `text` (denormalized)
- `primary_entity_name` `text` (denormalized)

**Page taxonomy (5):**
- `page_type` `text` — page-type taxonomy (`'pillar'`, `'spoke'`, `'lp'`, `'support'`, etc.)
- `page_intent_type` `text` — search intent (`'informational'`, `'commercial'`, etc.)
- `node_tier` `text` — A/B/C tier
- `node_tier_strategy` `text` CHECK IN (`'hub'`,`'spoke'`,`'pillar'`,`'supporting'`,`'leaf'`)
- `funnel_stage` `text` — `'awareness'`, `'consideration'`, `'decision'`, `'retention'`

**Authority & link strategy (DR-021, 7):**
- `priority` `text` — operator-set priority label
- `link_role` `text` — `'structural'`, `'authority'`, `'contextual'`, `'conversion'`
- `link_priority` `text`
- `anchor_strategy_mode` `text` — anchor text variation strategy
- `authority_weight` `smallint` CHECK 1..100 — operator-set link equity weight
- `link_equity_score` `smallint` CHECK 0..100 — computed
- `orphan_risk_score` `smallint` CHECK 0..100 — computed (high = orphan candidate)
- `crawl_depth` `smallint` — clicks from homepage
- `brand_authority_focus` `text` — DR-021 §6 brand authority routing
- `is_source_page` `boolean` — true = canonical authority hub for cluster
- `strategic_page` `boolean` — operator flag

**Cross-brand linking (DR-021, 4):**
- `cross_brand_approved` `boolean` DEFAULT false
- `cross_brand_justification` `text` — required when approved
- `cross_brand_role` `text`
- `cross_brand_link_type` `text`

**Entity & keyword binding (8):**
- `primary_entity_fp` `text` (FK → seo_entity_graph)
- `related_entities_fps` `text[]`
- `target_keyword_fp` `text` (FK → seo_x_ads_keywords_contextual_master)
- `semantic_keywords_fps` `text[]`
- `planned_outbound_fps` `text[]` (intended outbound internal links — FK → page_master fingerprints)
- `planned_outbound_external_links` `text` — free-form external URL list
- `cross_brand_links_fps` `text[]`

**Schema markup (1 + linked):**
- `schema_markup_type` `text` (`'WebPage'`, `'Article'`, `'MedicalProcedure'`, `'Drug'`, etc.) — drives JSON-LD generation
- (Schema markup planned/emitted details live in editorial_reviews + page templates)

**Multilingual (DR-009, 5):**
- `page_language` `text` — `'th'`, `'en'`, `'zh'`, `'ar'`, `'fr'`, ...
- `translation_status` `text` — `'pending'`, `'in_progress'`, `'approved'`, `'live'`
- `translation_due_date` `timestamptz`
- `translations_versions_fps` `text[]` — FK to other-language versions of same content
- `source_translation_fp` `text` — FK to source-language version

**Hierarchy (2):**
- `parent_page_fp` `text` (FK → seo_website_page_master)
- `content_format` `text` (`'long_form_article'`, `'comparison_table'`, `'video_centric'`, etc.)

**Word count targets (3):**
- `auto_suggested_word_count_target` `numeric`
- `required_min_outbound` `numeric`
- `required_min_inbound` `numeric`

**XML sitemap & SEO directives (3):**
- `in_xml_sitemap` `boolean` DEFAULT false
- `robots_directive` `text` — `<meta robots>` content
- `wpml_page_id` `numeric` — WPML translation post ID

**Editorial (DR-015/016/017, 8):**
- `note_brief` `text` — planning-phase brief
- `content_brief` `text` 🆕 v1.16 (DR-017) — content brief
- `suggested_page_content` `text` — operator-suggested content outline
- `viability_assessment` `jsonb` 🆕 v1.16 (DR-016) — thin page risk + viability audit trail
- `marketplace_proposal_status` `text` 🆕 v1.16 (DR-015) CHECK IN (`'proposed'`,`'approved'`,`'rejected'`,`'repackaged'`,`'deferred'`) — multi-brand marketplace reconciliation
- `reconciliation_notes` `text` — DR-015 operator notes
- `flag_review` `text` — operator review flag
- `snapshot_version` `text` — planning snapshot identifier

**Status & lifecycle (4):**
- `status` `text` — page lifecycle (`'planning'`, `'draft'`, `'in_review'`, `'published'`, `'archived'`)
- `published_date` `timestamptz`
- `hreflang_validated` `boolean` DEFAULT false
- `has_medical_review` `boolean` DEFAULT false
- `review_cycle` `text` — review cadence (`'monthly'`, `'quarterly'`, `'annual'`)

**Ads LP track (DR-026, 6):** 🌱 v1.12
- `page_purpose` `text` NOT NULL DEFAULT `'seo_organic'` CHECK IN (`'seo_organic'`,`'ads_landing'`,`'hybrid'`,`'utility'`,`'legal'`,`'thank_you'`)
- `ads_template_id` `text` (CHECK regex `^T-ADS-[1-5]$` OR `^T-DUAL-[0-9]+$`)
- `index_directive` `text` NOT NULL DEFAULT `'index'` CHECK IN (`'index'`,`'noindex'`,`'index_no_follow'`,`'noindex_no_follow'`)
- `conversion_event_primary` `text` — CHECK IN (`'lead_form'`,`'call_click'`,`'line_follow'`,`'booking'`,`'download'`,`'package_view'`,`'add_to_cart'`)
- `conversion_event_secondary` `text[]` (max 3 elements)
- `campaign_id` `text` — Phase 0 stub; becomes `campaign_fp` FK in Schema v1.13+ when DR-027 locks

**Sensitive Topic Compliance (DR-030, 6):** 🆕 v1.17
- `product_regulatory_tier` `smallint` CHECK 1..4 — DR-030 §1 (1=Basic / 2=Functional / 3=Medical-Adjacent / 4=Quasi-Restricted)
- `content_topic_tier` `smallint` CHECK 1..4 — DR-030 §1 (1=General Lifestyle / 2=Specific Outcome / 3=YMYL-High / 4=Legal-Sensitive)
- `sensitive_topic_flag` `text` CHECK IN (`'none'`,`'low'`,`'medium'`,`'high'`,`'critical'`) — aggregated for editorial routing
- `target_audience_segment` `text[]` — e.g. `{recovery, postpartum, mental-health-clinical}`
- `legal_review_required` `boolean` NOT NULL DEFAULT false — triggers `legal_compliance` editorial review row
- `compliance_max_tier` `smallint` **GENERATED ALWAYS AS** `GREATEST(product_regulatory_tier, content_topic_tier)` **STORED** — drives reviewer tier auto-routing

**Multi-Center (DR-032, 1):** 🆕 v1.18
- `center_slug` `text` — NULL = umbrella/hospital-wide page (Home/About/Method/Membership). Non-NULL = page belongs to a center (URL: `/{lang}/{url_segment}/{slug}/`). Validated by `trg_validate_page_center_slug`: must be NULL when `brand.brand_structure='monolithic'`; must match a `seo_brand_centers.center_slug` row when `multi_center`.

**Intra-Page Routing (DR-034, 2):** 🆕 v1.20
- `intent_source_tier` `text` NOT NULL DEFAULT `'template_only'` CHECK IN (`'paa'`,`'derived'`,`'template_only'`) — source of the page's on-page intent coverage: `paa` = real PAA (`seo_x_ads_keyword_serp_competitors.paa_questions`), `derived` = `keyword_painpoint` / `predicted_serp_features` / voice signals, `template_only` = 8-intent baseline. Drives Content_Templates §4.5.4 routing + tiered FAQ floor.
- `paa_checked_at` `timestamptz` — last PAA crawl time. NULL = never crawled (→ trigger crawl, **not** tier-3). SET + empty `paa_questions` = checked, genuinely no PAA → tier-2/3.

**Sync (3):**
- `notion_id text`, `notion_synced_at timestamptz`, (`sync_state` carried by other tables; page_master uses `notion_synced_at` only currently)

**Standard (2):** `created_at`, `updated_at`

#### CHECK constraints (live)

| Constraint | Definition |
|---|---|
| `chk_page_master_fingerprint_format` | `fingerprint ~ '^page_[0-9A-F]{16}$'` |
| `chk_page_purpose` | `page_purpose IN ('seo_organic','ads_landing','hybrid','utility','legal','thank_you')` |
| `chk_index_directive` | `index_directive IN ('index','noindex','index_no_follow','noindex_no_follow')` |
| `chk_node_tier_strategy` | `node_tier_strategy IS NULL OR IN ('hub','spoke','pillar','supporting','leaf')` |
| `chk_authority_weight_range` | `authority_weight IS NULL OR BETWEEN 1 AND 100` |
| `chk_link_equity_score_range` | `link_equity_score IS NULL OR BETWEEN 0 AND 100` |
| `chk_orphan_risk_score_range` | `orphan_risk_score IS NULL OR BETWEEN 0 AND 100` |
| `chk_marketplace_proposal_status` | `marketplace_proposal_status IS NULL OR IN ('proposed','approved','rejected','repackaged','deferred')` |
| `seo_website_page_master_product_regulatory_tier_check` | `product_regulatory_tier BETWEEN 1 AND 4` |
| `seo_website_page_master_content_topic_tier_check` | `content_topic_tier BETWEEN 1 AND 4` |
| `seo_website_page_master_sensitive_topic_flag_check` | `sensitive_topic_flag IN ('none','low','medium','high','critical')` |
| `seo_website_page_master_intent_source_tier_check` 🆕 v1.20 | `intent_source_tier IN ('paa','derived','template_only')` |

#### Triggers

- `trg_set_fingerprint_page_master` BEFORE INSERT → `fn_set_fingerprint_page_master()` — `page_{16HEX}` generator
- `trg_refresh_display_name_page_master` BEFORE UPDATE → refresh display_name when slug or brand_slug changes
- `trg_prevent_fingerprint_change_page_master` BEFORE UPDATE OF fingerprint — DR-008
- `trg_validate_page_center_slug` BEFORE INSERT/UPDATE OF center_slug → `fn_validate_page_center_slug()` (DR-032) — enforces monolithic→NULL rule and multi_center→exists rule

#### DR-030 Editorial Review Auto-routing

When `compliance_max_tier >= 3`, n8n flow auto-creates a pending `seo_editorial_reviews` row with `review_type='medical'`.
When `content_topic_tier=4 OR product_regulatory_tier=4`, also auto-creates `review_type='legal_compliance'`.
Page cannot move to `status='published'` until all required review rows have `approved=true`. (Enforced at app/n8n layer; database-layer trigger deferred to v1.19+.)

---

### 5.2 `seo_editorial_reviews`

> **Purpose:** Per-page editorial workflow rows. Multiple review types per page (medical, editorial, fact_check, legal, seo, translation, final_approval, legal_compliance).
> **Sync:** N↔S (Notion `Editorial Reviews` — created 2026-05-30)
> **DR:** Bible Part 23.4 (editorial review workflow), DR-030 (legal_compliance type added)
> **Volume:** 1–8 rows per page.

#### Columns (21 — full live snapshot)

| Column | Type | Notes |
|---|---|---|
| `id uuid` UNIQUE | |
| `fingerprint text` | `erev_{ULID16}` |
| `fingerprint_display_name text` | |
| `page_fp text` | FK → seo_website_page_master.fingerprint |
| `reviewer_fp text` | FK → seo_authors_reviewers.fingerprint |
| `review_type text` | CHECK enum — see below ⚠️ NOT `review_stage` (legacy v1.10 doc had this wrong) |
| `review_stage text` | Free-form stage descriptor (orthogonal to review_type) |
| `review_status text` | CHECK enum — see below |
| `review_score smallint` | 1–10 operator scored |
| `findings jsonb` DEFAULT `'[]'` | Array of finding objects `[{severity, category, description, location}, ...]` |
| `recommendations text` | |
| `blocking_issues_count smallint` | Computed/cached |
| `e_e_a_t_compliance jsonb` | E-E-A-T audit detail per Bible Part 23.3 |
| `scheduled_for date` | Review scheduled date |
| `started_at timestamptz` | |
| `completed_at timestamptz` | |
| `next_review_due date` | Auto-computed from review_cycle |
| `approved boolean` | |
| `approved_at timestamptz` | |
| `notion_id text` | N↔S |
| `created_at, updated_at` | |

#### CHECK constraints (live)

- `chk_er_review_type` CHECK IN **(`'medical'`, `'editorial'`, `'fact_check'`, `'legal'`, `'seo'`, `'translation'`, `'final_approval'`, `'legal_compliance'`)** 🆕 v1.17 — `legal_compliance` added by DR-030
- `chk_er_review_status` CHECK IN (`'pending'`, `'in_progress'`, `'changes_requested'`, `'approved'`, `'rejected'`, `'skipped'`)
- `chk_er_review_score` CHECK (`review_score IS NULL OR BETWEEN 1 AND 10`)

#### Triggers
- `trg_set_fingerprint` BEFORE INSERT (generic)
- `trg_prevent_fingerprint_change` BEFORE UPDATE

> **Doc drift fix vs v1.10:** Legacy v1.10 doc body called the column `review_stage` with a different enum. Live database has always used `review_type`. v1.18 corrects this.

---

### 5.3 `seo_page_internal_links` 🔒 v1.15 (DR-021)

> **Purpose:** Junction page↔page (or page↔external URL). Records both planned and implemented internal links for analytics + audit + cross-brand governance.
> **Sync:** N↔S (Notion `Page Internal Links` — created 2026-05-30)
> **DR:** DR-021 (Internal Linking HYBRID Locked v1.15)
> **Volume:** ~10–50 links per page.

#### Columns (28)

**Identity (3):** `id uuid`, `fingerprint text` (`plnk_{ULID16}`), `fingerprint_display_name text`

**Link target (3):**
- `from_page_fp text` (FK → seo_website_page_master.fingerprint)
- `to_page_fp text` (FK → seo_website_page_master.fingerprint, nullable when external)
- `to_external_url text` (when linking to external URL)

**Link classification (3):**
- `link_type text` CHECK IN (`'internal'`,`'external'`,`'cross_brand'`,`'cross_center_intra_brand'` 🆕 v1.18 DR-032)
- `link_role text` CHECK IN (`'structural'`,`'authority'`,`'contextual'`,`'conversion'`)
- `link_priority smallint` 1..5

**Anchor text strategy (4):**
- `anchor_text text` — actual anchor copy
- `anchor_variant_type text` CHECK IN (`'exact'`,`'partial'`,`'branded'`,`'generic'`,`'naked_url'`)
- `section_context text` — where on the page (`'header'`, `'body-§3'`, `'footer'`, etc.)
- `surrounding_text_snippet text` — context for review

**Lifecycle (4):**
- `status text` CHECK IN (`'planned'`,`'implemented'`,`'broken'`,`'removed'`)
- `planned boolean`
- `implemented boolean`
- `first_planned_at timestamptz`, `last_verified_at timestamptz`

**Reciprocal & cross-brand (5):**
- `is_reciprocal boolean` — auto-flipped by `trg_internal_link_reciprocal`
- `is_cross_brand boolean`
- `cross_brand_justification text` — required when is_cross_brand=true
- `cross_brand_role text`
- `brand_scope text[]`

**Sync (3):** `notion_id text`, `notion_synced_at`, `sync_state`
**Standard (2):** `created_at`, `updated_at`

#### Triggers
- `trg_set_fingerprint` BEFORE INSERT
- `trg_prevent_fingerprint_change` BEFORE UPDATE
- `trg_internal_link_reciprocal` AFTER INSERT/UPDATE → `fn_check_reciprocal_link()` — auto-creates inverse link row when forward link is added

---

## 6. Group 4 — Keyword & Search Intelligence (4 tables)

### 6.1 `seo_x_ads_keywords_contextual_master` (38 cols)

> **Purpose:** Master keyword registry — contextual classification (intent, painpoint, funnel stage), SEO/Ads dual-flag, primary entity binding.
> **Sync:** N↔S (Notion `Keyword Hub`) for master; daily logs S-only
> **Volume:** 12,526 current rows (multi-brand).
> **DR:** DR-026 v1.12 (+6 cols seo_active/ad_active/ad_intent_score/ad_match_type_preferred/ad_landing_page_fp/ad_priority_tier)

Key columns:
- Identity: `fingerprint`, `notion_id`, `keyword`, `brand`
- Intent classification: `search_intent`, `ads_intent`, `funnel_stage`, `anxiety_level`, `keyword_painpoint`, `keyword_core_insight`
- Localization: `target_market`, `target_language`, `wpml_code`, `translation_group`
- Difficulty: `qualitative_kd`, `qualitative_kd_number`, `kd_reasoning`, `predicted_serp_features`
- Entity binding: `primary_entity_fp`, `primary_entity_name`, `keyword_use_as`
- DR-026 Ads track: `seo_active boolean DEFAULT true`, `ad_active boolean DEFAULT false`, `ad_intent_score smallint 1..10`, `ad_match_type_preferred text` CHECK IN `('exact','phrase','broad','broad_modified')`, `ad_landing_page_fp text` FK → seo_website_page_master.fingerprint, `ad_priority_tier text DEFAULT 'none'` CHECK IN `('t1','t2','t3','none')`
- Notion tier: `notion_tier`, `notion_tier_updated_at`
- Telemetry: `gsc_last_update`, `ga4_last_update`, `satellite_data_updated_at`, `notion_synced_at`, `keyword_contextual_ready_last_update`, `last_checked_at`
- Standard: `created_at`, `updated_at`, `note`

### 6.2 `seo_x_ads_keywords_monthly_market_snapshot` (57 cols)

> **Purpose:** Monthly DataForSEO snapshot — volume metrics, KD, CPC, momentum, ROI proxy. Recomputed monthly by n8n.
> **Sync:** S only
> **Volume:** 12,156 current rows.

Key column families: Volume Metrics (3/6/12/48-month avg), Difficulty (KD score, competition), Cost (CPC range), Momentum (trend slope, seasonality), DataForSEO Source metadata.

### 6.3 `seo_x_ads_keyword_serp_competitors` (29 cols)

> **Purpose:** SERP top-3 + AI Overview + Featured Snippet + PAA snapshots per keyword × time.
> **Sync:** S only
> **Volume:** 8,589 current rows (9 snapshot waves 2026-02 → 05).

Key columns include `top_competitors_meta jsonb`, `aio_present boolean`, `featured_snippet_url`, `paa_questions text[]`, `content_scraped_at`.

### 6.4 `seo_x_voice_search` (19 cols)

> **Purpose:** Voice search query tracking — natural language queries that trigger Alexa/Siri/Google Assistant answers.
> **Sync:** N↔S (master only)

Columns: `fingerprint`, `parent_keyword_fp` (FK → keyword master), `voice_query`, `query_language`, `query_intent`, `conversational_form`, `triggered_assistants text[]` (`{Alexa, Siri, Google_Assistant, Bixby}`), `expected_answer_format`, `current_answer_source`, `optimized_for_page_fp` (FK → page_master), `is_featured_snippet`, `featured_snippet_url`, `is_in_pasf` (People Also Search For), `query_volume_estimate`, `last_tested_at`, plus standard.

---

## 7. Group 5 — Performance Fact Tables (2 tables)

### 7.1 Daily Logs (`logs_YYYY` partitions, alias `seo_x_ads_keywords_x_url_daily_logs`)

> **Purpose:** Denormalized daily fact table — GSC + GA4 + CWV + indexing + on-page audit + link graph. The dashboard's primary data source.
> **Sync:** S only (telemetry ingest from GSC API, GA4 API, PSI, Lighthouse)
> **Partitioning:** Per year — `logs_2025`, `logs_2026` (125 cols each)
> **Volume:** logs_2026 = 89,960 rows (2026-02-27 → 03-22 currently)

125 columns total per partition. Major column families:
- **GSC:** clicks, impressions, ctr, ranking_mobile, ranking_desktop, per-query rollups
- **GA4:** organic_sessions, organic_users, organic_engagement_rate, total_sessions, conversions
- **Core Web Vitals (mobile + desktop):** LCP, CLS, FCP, TBT, INP, TTFB, performance_score
- **Indexing:** indexing_status, indexability_issues, last_crawl_at, has_canonical_issue
- **On-page audit:** title_length, meta_description_length, has_h1, schema_emitted, image_count, broken_links_count
- **Link graph:** inbound_link_count, outbound_internal_link_count, outbound_external_link_count, is_orphan

Triggers: `trg_dl_bump_keyword` AFTER INSERT/UPDATE → updates `seo_x_ads_keywords_contextual_master.gsc_last_update` and `ga4_last_update` denorm fields.

> **Backup:** `seo_x_ads_keywords_x_url_daily_logs_backup_20260227` exists from a pre-partition migration — 37,572 rows. Retain through v2.0 then drop.

### 7.2 `seo_local_rankings` (25 cols)

> **Purpose:** Local SERP / Google Maps Pack rankings per keyword × branch × search point × time.
> **Sync:** S only — DataForSEO Maps API + n8n flow E5
> **DR:** DR-025 v1.11 (FK rename `location_id` → `branch_id`)

Columns:
- Identity: `id`, `keyword_fp` (FK → keyword master), `branch_id` (FK → seo_branches.id), `brand_id`
- Geo search point: `search_location_lat`, `search_location_lng`, `search_location_name`, `search_radius_km`, `device_type`
- Snapshot: `snapshot_at date`
- Positions: `local_pack_position`, `local_pack_total_results`, `local_finder_position`, `maps_position`, `maps_total_results`, `is_in_local_pack_three`, `organic_position`
- Features: `featured_in_snippet`, `ai_overview_cited`, `competitors_in_map_pack jsonb`
- Branch context: `distance_to_branch_km`
- Delta: `previous_position`, `position_change`
- Source: `data_source`, `created_at`

---

## 8. Group 6 — Backlinks & Off-Page (2 tables)

### 8.1 `seo_backlinks_data` (17 cols)

> **Purpose:** Aggregated backlink domain authority + referring domain count per brand per snapshot.
> **Sync:** S only — Ahrefs / Moz / DataForSEO ingest (pipeline pending)
> **Status:** 0 rows currently (schema ready, ingest not wired)

Typical fields: brand_id, snapshot_at, total_backlinks, referring_domains, dofollow_count, nofollow_count, domain_rating, url_rating, source_provider.

### 8.2 `seo_backlinks_links` (19 cols)

> **Purpose:** Per-link backlink rows — source URL, target URL, anchor text, link attributes.
> **Sync:** S only
> **Status:** 0 rows currently

Typical fields: source_url, source_domain, target_url, target_page_fp, anchor_text, link_attribute (`'dofollow'`/`'nofollow'`/`'ugc'`/`'sponsored'`), first_seen_at, last_verified_at, is_active, source_authority_score.

---

## 9. Group 7 — AI Operations & Embeddings (4 tables)

### 9.1 `seo_brand_mentions` (22 cols)

> **Purpose:** Cross-platform brand mention tracking (Pantip/Facebook/Wongnai/IG/TikTok/X/news/blog). "Everywhere SEO" per Bible Part 13.
> **Sync:** S only — monitor tool (Mention.com / Brand24 / custom scraper) ingest
> **Status:** 0 rows currently

Columns:
- Identity: `id`, `fingerprint` (`bmen_{ULID16}`), `fingerprint_display_name`, `brand_id`
- Source: `source_platform`, `source_url`, `source_title`, `source_author`, `source_domain`, `source_authority_score smallint`
- Mention: `mention_text`, `mention_context`, `mention_type`, `language_code`, `is_thai_specific boolean`
- Linking: `is_linked boolean`, `link_target_page_fp`
- AI extraction: `sentiment text`, `sentiment_score numeric`
- Temporal: `mentioned_at`, `detected_at`, `created_at`

### 9.2 `seo_llm_citations` (24 cols)

> **Purpose:** LLMO citation tracking — record when ChatGPT/Claude/Perplexity/Gemini cite the brand or its pages in responses to test prompts.
> **Sync:** S only — scripted query simulation (LangChain + Anthropic SDK + OpenAI SDK + Perplexity API + Gemini API)
> **Status:** 0 rows currently
> **Bible:** Part 13

Columns:
- Identity: `id`, `fingerprint` (`llmc_{ULID16}`), `fingerprint_display_name`, `brand_id`
- LLM context: `llm_platform` (`'ChatGPT'`,`'Claude'`,`'Perplexity'`,`'Gemini'`,`'Copilot'`), `llm_model_version`
- Query: `prompt_text`, `prompt_category`, `prompt_intent`, `query_language`, `test_geography`, `test_run_id` UUID
- Response: `response_text`, `was_cited boolean`, `citation_position smallint`, `cited_url`, `cited_page_fp` (FK), `citation_context`
- Brand signals: `brand_mentioned boolean`, `brand_sentiment`
- Competitors: `competitors_cited text[]`, `source_domains_cited text[]`
- Temporal: `tested_at`, `created_at`

### 9.3 `seo_llm_query_simulations` (21 cols)

> **Purpose:** Recurring LLM query simulation registry — prompts tested on a cadence (weekly/monthly) to track citation/mention rate over time.
> **Sync:** S only
> **Status:** 0 rows currently

Columns: `id`, `fingerprint` (`llmq_{ULID16}`), `fingerprint_display_name`, `brand_id`, `simulation_name`, `prompt_template`, `prompt_variables jsonb`, `target_intent`, `target_funnel_stage`, `target_entity_fp`, `expected_citation_pages_fps text[]`, `expected_brand_mention boolean`, `total_runs int`, `successful_citations int`, `citation_rate numeric`, `brand_mention_rate numeric`, `last_run_at`, `next_scheduled_run`, `is_active boolean`, `created_at`, `updated_at`.

### 9.4 `seo_entity_embeddings` (9 cols)

> **Purpose:** Vector embeddings per entity (via pgvector). For semantic search, EUG (Entity Uniqueness Guard) v2.0, and similar-entity recommendations.
> **Sync:** S only
> **Extension:** `vector` (pgvector). HNSW index **deferred** until bulk-loaded (creating HNSW on near-empty table wastes catalog space).

Columns:
- `id uuid`
- `entity_fp text` (FK → seo_entity_graph.fingerprint)
- `embedding_model text` (e.g. `'text-embedding-3-large'`, `'voyage-2'`)
- `embedding_dimensions smallint` (e.g. 1536, 1024)
- `embedding vector(N)` — pgvector type (N varies per model)
- `source_text text` — text that was embedded
- `source_text_hash text` — for cache busting
- `computed_at timestamptz`
- `is_stale boolean` — flag for re-embedding (e.g. when entity description changes)

---

## 10. Group 8 — Data Quality & Governance (2 tables)

### 10.1 `seo_data_quality_metrics` (15 cols)

> **Purpose:** Time-series data quality metrics — DAMA 5 dimensions (completeness, consistency, accuracy, timeliness, uniqueness) + sync lag + FK integrity scores.
> **Sync:** S only — populated by scheduled jobs

Columns: `id`, `metric_name`, `metric_category` (e.g. `'completeness'`, `'consistency'`, `'sync_lag'`), `metric_value numeric`, `metric_value_jsonb` (for structured breakdowns), `threshold_min`, `threshold_max`, `status` (`'green'`, `'yellow'`, `'red'`), `target_table_name`, `target_brand_id`, `scope_description`, `computed_at`, `computation_duration_ms`.

### 10.2 `seo_schema_changes` (18 cols)

> **Purpose:** DDL audit log — one row per schema migration step. Cross-references `migration_version` and `related_dr_id` for traceability.
> **Sync:** S only — append-only, populated by `apply_migration` workflow

Columns: `id`, `change_type` text CHECK IN (`'create_table'`,`'drop_table'`,`'alter_table_add_column'`,`'alter_table_drop_column'`,`'alter_table_alter_column'`,`'rename_table'`,`'rename_column'`,`'add_index'`,`'drop_index'`,`'add_constraint'`,`'drop_constraint'`,`'add_trigger'`,`'drop_trigger'`,`'create_function'`,`'drop_function'`,`'create_view'`,`'drop_view'`,`'enable_rls'`,`'disable_rls'`,`'create_policy'`,`'drop_policy'`,`'other'`), `table_name`, `column_name`, `index_name`, `constraint_name`, `migration_version`, `migration_name`, `related_dr_id`, `spec_version`, `description`, `ddl_statement`, `performed_by`, `performed_at`, `duration_ms`, `rolled_back boolean`, `rolled_back_at`, `rollback_reason`.

**Recent activity:** 20 rows logged 2026-05-27 for Wave 11 (DR-030 + DR-032). See `migration_version LIKE 'eywa_w11_%'`.

---

## 11. Group 9 — Entity Extensions & Templates (10 tables = 9 extensions + 1 template registry)

> **Pattern:** 1:1 extension to `seo_entity_graph` via `entity_fp text FK→seo_entity_graph.fingerprint`. One row per qualifying entity. Each table adds vocabulary specific to its entity_type (CPT codes for procedures, ATC codes for drugs, FMA terms for anatomy, etc.).
>
> **Sync drift note:** Spec comments mark these `N↔S` but the actual tables were built **without `notion_id` columns** — practically these function as **S-only** detail tables today. Operator may add notion_id later if a Notion mirror DB is built. See §2 Sync direction matrix.

### 11.1 `seo_entity_ingredients` (29 cols) — entity_type='ingredient'

INCI / CAS / EWG hazard scores. Used by cosmetic/supplement product pages.
Key fields: `inci_name`, `cas_number`, `ewg_hazard_score`, `function_category text[]`, `restrictions_eu`, `restrictions_us_fda`, `restrictions_thai_fda`, `comedogenic_rating`, `vegan_status`, `cruelty_free_status`, `paraben_free`, `phthalate_free`, `is_natural`, `synonyms text[]`, `safe_usage_concentration_pct`.

### 11.2 `seo_entity_devices` (22 cols) — entity_type='device'

FDA / CE / manufacturer registration. Used by medical device pages.
Key fields: `fda_clearance_number`, `ce_mark_number`, `manufacturer_name`, `device_class`, `intended_use_statement`, `contraindications text[]`, `warnings text[]`, `made_in_country`, `is_class_iii boolean`, `is_implantable boolean`, `approval_status`.

### 11.3 `seo_entity_procedures` (25 cols) — entity_type='procedure'

CPT codes + recovery + contraindications. **T2-medical-procedure template binding** — page templates auto-pull from this when `page_type='procedure'`.
Key fields: `cpt_code`, `hcpcs_code`, `thai_procedure_code`, `procedure_category`, `typical_duration_minutes`, `anesthesia_type`, `recovery_time_days`, `pain_level smallint`, `success_rate_pct`, `risks text[]`, `contraindications text[]`, `pre_op_instructions text`, `post_op_instructions text`, `expected_outcomes text[]`, `cost_range_thb numrange`.

### 11.4 `seo_entity_product` 🆕 v1.11 (42 cols) — entity_type='product'

Product master for skincare/supplements/medical devices that are productized offerings. Bridges DR-024.
Key fields: `product_sku`, `product_brand_id`, `gtin`, `manufacturer_name`, `product_category`, `ingredients_list_inci text[]`, `claims_marketing text[]`, `claims_substantiated text[]`, `price_thb numrange`, `pack_size`, `unit_count`, `storage_conditions`, `shelf_life_months`, `is_prescription_only`, `is_otc`, `is_supplement`, `regulatory_registration_no`, `regulatory_registration_country`.

### 11.5 `seo_entity_condition` 🆕 v1.11 (40 cols, +2 v1.19 DR-033) — entity_type='condition' (T1 CRITICAL)

ICD-11 / ICD-10 / ICD-10-CM / SNOMED CT / MeSH. **T1 page template binding** — every condition page pulls from this. CRITICAL for medical content authority. **DR-033 ICD coding set:** `icd11_code` (ICD-11-MMS, primary) · `icd10_code` (WHO base / ICD-10-TM) · `icd10_cm_code` (US clinical-mod) · `icd10_codes_related[]` — emitted together in `MedicalCondition.code[]`, ICD-11 first.
Key fields: `icd11_code` 🆕 v1.19, `icd10_code` (WHO base), `icd10_cm_code` 🆕 v1.19, `icd10_codes_related[]`, `snomed_ct_id`, `mesh_id`, `umls_cui`, `condition_category`, `body_system text[]`, `severity_levels jsonb`, `prevalence_estimate text`, `typical_age_onset numrange`, `symptoms_list_fps text[]` (FK → entity_graph), `risk_factors_list_fps text[]`, `diagnosis_methods text[]`, `treatment_options_fps text[]`, `prognosis text`, `is_chronic boolean`, `is_emergency boolean`, `is_contagious boolean`, `is_genetic boolean`, `who_classification`.

### 11.6 `seo_entity_drug` 🆕 v1.11 (42 cols) — entity_type='drug'

RxNorm / ATC / Thai FDA registration.
Key fields: `generic_name`, `brand_names text[]`, `inn_name`, `drug_class`, `atc_code`, `rxnorm_id`, `schedule_dea`, `thai_fda_registration_no`, `dosage_forms text[]`, `routes_of_administration text[]`, `mechanism_of_action text`, `pharmacokinetics jsonb`, `indications text[]`, `contraindications text[]`, `adverse_effects text[]`, `drug_interactions_fps text[]` (FK → seo_entity_drug self), `pregnancy_category`, `is_prescription`, `is_controlled`, `half_life_hours numrange`.

### 11.7 `seo_entity_anatomy` 🆕 v1.11 (25 cols) — entity_type='anatomy'

FMA (Foundational Model of Anatomy) / UBERON. Self-FK hierarchy for body system tree.
Key fields: `fma_id`, `uberon_id`, `terminologia_anatomica`, `parent_anatomy_fp` (self-FK), `body_system`, `body_region`, `is_organ boolean`, `is_tissue boolean`, `is_cell boolean`, `function_summary text`, `related_conditions_fps text[]` (FK → seo_entity_condition).

### 11.8 `seo_entity_organization` 🆕 v1.11 (34 cols) — entity_type='organization'

External organizations (WHO, IAOMT, IABDM, ทันตแพทยสภา, A4M, etc.) — DISTINCT from `brands` table which is internal EYWA brands.
Key fields: `organization_name`, `legal_name`, `org_type` (`'professional_association'`,`'regulatory_body'`,`'research_institute'`,`'government'`,`'ngo'`,`'university'`), `country_of_origin`, `founding_year`, `wikidata_id`, `official_url`, `headquarters_address`, `notable_publications text[]`, `is_credentialing_body boolean`, `accredited_specialties text[]`, `member_count_estimate`, `mission_statement`.

### 11.9 `seo_entity_lab_test` 🆕 v1.11 (36 cols) — entity_type='lab_test'

LOINC / CPT. Lab test definitions for biomarker entities.
Key fields: `loinc_code`, `cpt_code`, `test_name`, `test_category`, `specimen_type` (`'blood'`,`'urine'`,`'saliva'`,`'tissue'`,`'breath'`,`'stool'`), `reference_range_units`, `reference_range_low`, `reference_range_high`, `interpretation_low text`, `interpretation_normal text`, `interpretation_high text`, `clinical_significance text`, `typical_cost_thb_range numrange`, `is_fasting_required boolean`, `is_overnight_required boolean`, `result_turnaround_days`.

### 11.10 `seo_programmatic_templates` (12 cols) — template registry (NOT entity extension)

> **Purpose:** Registry of page templates T1–T22 (SEO) + T-ADS-1 to T-ADS-5 (Ads LP per DR-026).
> **Sync:** S only (despite spec comment saying N↔S — no notion_id column built). Source of truth for human-readable templates lives in `Content_Templates_EYWA_v1_0.md` in spec repo; this table is the pipeline-consumed structured registry.
> **Trigger:** `trg_set_fingerprint`, `trg_prevent_fingerprint_change`

Columns: `id uuid`, `fingerprint text` (`tmpl_{ULID16}`), `fingerprint_display_name`, `template_name text`, `template_id text` (e.g. `'T1'`, `'T-ADS-3'`), `target_layer text`, `url_pattern text`, `page_template_blueprint jsonb` (the actual template structure: sections, schema rules, content requirements), `applicable_brands text[]`, `entity_type_required text`, `created_at`, `updated_at`.

---

## 12. Group 10 — Ads Landing Page Track (column extensions only) 🌱 v1.12 (DR-026 Proposed)

> Per **DR-026 Proposed 2026-05-12** + Bible Part 29. Phase 0 — additive columns on existing tables; NO new tables ship in v1.12. The `seo_campaigns` table is reserved for Phase 1 (DR-027 — Locked v1.13+).
>
> **Companion Bible:** Part 29 (Ads Landing Page Track)
> **Companion Templates:** v1.4 (T-ADS-1 through T-ADS-5)

### 12.1 `seo_website_page_master` extensions (already detailed in §5.1 "Ads LP track" subsection)

6 columns: `page_purpose`, `ads_template_id`, `index_directive`, `conversion_event_primary`, `conversion_event_secondary[]`, `campaign_id` (Phase 0 stub).

### 12.2 `seo_x_ads_keywords_contextual_master` extensions (already detailed in §6.1 "DR-026 Ads track")

6 columns: `seo_active`, `ad_active`, `ad_intent_score`, `ad_match_type_preferred`, `ad_landing_page_fp`, `ad_priority_tier`.

### 12.3 Future: `seo_campaigns` Universal Master Table (Phase 1, DR-027 — NOT IN v1.18)

Architecture sketch reserved for DR-027 lock. Stub column `seo_website_page_master.campaign_id text` exists today; will become `campaign_fp text FK → seo_campaigns(fingerprint)` when DR-027 ships. Until then, operators populate `campaign_id` with operator-chosen identifiers (e.g. `'vth-biodent-launch-2026-q2'`).

---

## Appendix A — Required PostgreSQL Extensions

### Installation Order

```sql
-- 1. Core UUID + crypto (DR-008 fingerprint generator)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Text search helpers (EUG, slug normalization)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- 3. Geo (seo_branches.geo_point)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 4. Vector (seo_entity_embeddings)
CREATE EXTENSION IF NOT EXISTS vector;
```

### Extension-to-Table Map

| Extension | Used by |
|---|---|
| `uuid-ossp` | All tables with UUID PK (all 40 base tables) |
| `pgcrypto` | DR-008 fingerprint generators (`gen_random_uuid` → ULID16) |
| `pg_trgm` | EUG (Entity Uniqueness Guard) v2.0; fuzzy matching in dedupe scripts |
| `unaccent` | DR-010 `brand_slug` normalization; DR-008 display_name generation |
| `postgis` | `seo_branches.geo_point geometry(Point,4326)` + `trg_branches_sync_geo_point` |
| `vector` | `seo_entity_embeddings.embedding vector(N)` |

---

## Appendix B — Fingerprint Patterns (DR-008 v1.9)

### Two-Column Identity Convention

Every fingerprinted table has two columns:

- **`fingerprint`** (text, UNIQUE, IMMUTABLE) — machine ID matching a regex per table. Generated by trigger.
- **`fingerprint_display_name`** (text, NOT NULL, refreshable) — human label `{fp_last_6}::{contextual_keys}`. Auto-refreshed by trigger on UPDATE.

### Per-Table Fingerprint Formats

| Table | Prefix | Pattern | Example |
|---|---|---|---|
| `brands` | `brnd_` | `^brnd_[0-9A-F]{16}$` | `brnd_A3F2D7E9B4C81256` |
| `seo_brand_centers` 🆕 v1.18 | `ctr_` | `^ctr_[0-9a-f]{16}$` | `ctr_dbd48d061e674e55` |
| `seo_entity_graph` | `ent_` | `^ent_[0-9A-F]{16}$` | `ent_F4D9C1A7B6E8F3D2` |
| `seo_website_page_master` | `page_` | `^page_[0-9A-F]{16}$` | `page_3B4F2D6E8A91C5F0` |
| `seo_branches` | `brch_` | (auto) | `brch_...` |
| `seo_authors_reviewers` | `auth_` | (auto) | `auth_...` |
| `seo_doctor_assignments` | `docasg_` | (auto) | `docasg_...` |
| `seo_topic_cluster_master` | `tcls_` | (auto) | `tcls_...` |
| `seo_citations` | `cite_` | (auto) | `cite_...` |
| `seo_page_citations` | `pcit_` | (auto) | `pcit_...` |
| `seo_entity_relationships` | `edge_` | (auto) | `edge_...` |
| `seo_editorial_reviews` | `erev_` | (auto) | `erev_...` |
| `seo_page_internal_links` | `plnk_` | (auto) | `plnk_...` |
| `seo_reviews` | `rev_` | (auto) | `rev_...` |
| `seo_directory_listings` | `dirlist_` | (auto) | `dirlist_...` |
| `seo_gbp_posts` | `gbppost_` | (auto) | `gbppost_...` |
| `seo_brand_mentions` | `bmen_` | (auto) | `bmen_...` |
| `seo_llm_citations` | `llmc_` | (auto) | `llmc_...` |
| `seo_llm_query_simulations` | `llmq_` | (auto) | `llmq_...` |
| `seo_programmatic_templates` | `tmpl_` | (auto) | `tmpl_...` |
| `seo_x_voice_search` | `vsrch_` | (auto) | `vsrch_...` |

### Display Name Formulas

| Table | Display Name Pattern |
|---|---|
| `brands` | `{fp_last_6}::{brand_slug}` |
| `seo_brand_centers` | `{fp_last_6}::{brand_id}::{center_slug}` |
| `seo_entity_graph` | `{fp_last_6}::{entity_slug}` |
| `seo_website_page_master` | `{fp_last_6}::{brand_slug}::{slug}` |
| `seo_branches` | `{fp_last_6}::{brand_slug}::{branch_slug}` |
| `seo_doctor_assignments` | `{fp_last_6}::{brand_slug}::{author_name}::{role}` |
| Others | `{fp_last_6}::{primary_text_key}` |

### Standard Trigger Triplet (DR-008)

Every fingerprinted table installs:

1. `trg_set_fingerprint_<table>` BEFORE INSERT — generates fingerprint if NULL, computes display_name
2. `trg_refresh_display_name_<table>` BEFORE UPDATE — refreshes display_name when key columns change
3. `trg_prevent_fingerprint_change[_<table>]` BEFORE UPDATE OF fingerprint — raises if fingerprint is being modified (immutability)

Tables with simple identity use generic `trg_set_fingerprint` + `trg_prevent_fingerprint_change` backed by `fn_set_fingerprint_generic()` + `fn_prevent_fingerprint_change()`. Tables with custom display_name formulas (brands, centers, entity_graph, page_master) have per-table function variants.

---

## Appendix C — Naming Conventions

### Table Naming

- **Prefix:** All EYWA SEO tables start with `seo_` except `brands` (legacy, predates prefix convention) and `logs_YYYY` (partition pattern).
- **Plural:** Use plural noun (`seo_brand_centers` not `seo_brand_center`).
- **No camelCase:** `snake_case_only`.
- **Junction tables:** Combine both nouns (`seo_page_citations`, `seo_page_internal_links`, `seo_doctor_assignments`).
- **Extensions:** `seo_entity_<type>` (singular type per DR-024).

### Column Naming

- **FK by fingerprint:** `<entity>_fp` (e.g. `from_entity_fp`, `parent_page_fp`, `medical_reviewer_fp`).
- **FK by UUID:** `<entity>_id` (e.g. `brand_id`, `branch_id`, `target_brand_id`).
- **Denormalized labels:** `<entity>_name` next to `<entity>_fp` (e.g. `brand_name` alongside `brand_id`).
- **Array FKs:** `<entity>_fps` plural (e.g. `related_entities_fps text[]`).
- **Boolean flags:** prefix with `is_`/`has_`/`was_` (e.g. `is_primary`, `has_medical_review`, `was_cited`).
- **Timestamps:** suffix `_at` for events (`created_at`, `responded_at`); suffix `_date` for dates (`opened_date`, `published_date`).
- **Score/metric columns:** suffix `_score`, `_count`, `_rate`.

### JSON Field Conventions

- Multilingual: jsonb `{"th": "...", "en": "...", "zh": "..."}` — DR-009 Tier 1 pattern.
- Score breakdowns: jsonb `{"factor_a": 0.X, "factor_b": 0.Y, "total": 0.Z}`.
- Audit trails: jsonb `[{"actor": "...", "action": "...", "at": "ISO8601"}, ...]`.
- Findings/issues: jsonb `[{"severity": "...", "category": "...", "description": "..."}, ...]`.

---

## Appendix D — Cross-Reference Index to Bible

| Bible Part | Covered tables / topics |
|---|---|
| Part 2 Knowledge Graph | seo_entity_graph (§4.1), seo_entity_relationships (§4.5), Group 9 extensions |
| Part 5 Cluster health | seo_topic_cluster_master (§4.2) |
| Part 7 SKOS / Topic Clusters | seo_topic_cluster_master (§4.2) |
| Part 10.5 Local SEO | seo_branches, seo_reviews, seo_directory_listings, seo_gbp_posts, seo_local_rankings |
| Part 13 Everywhere SEO + Citable Patterns | seo_brand_mentions, seo_llm_citations, seo_llm_query_simulations |
| Part 17.6 Group A–G ARC | All groups; group-by-group taxonomy |
| Part 18.8 Two-Phase Sync | sync_state, parent_notion_id columns across N↔S tables |
| Part 20 KPI Stack | logs_2026 + view layer (Phase 0 pending) |
| Part 23.1 Citation 6-tier hierarchy | seo_citations.citation_tier |
| Part 23.3 Authors/Reviewers E-E-A-T | seo_authors_reviewers, seo_doctor_assignments |
| Part 23.4 Editorial review workflow | seo_editorial_reviews |
| Part 25 Multi-Brand Federation | brands.brand_scope across tables |
| **Part 25.13 Multi-Center Architecture 🆕** | **seo_brand_centers + center_slug + center_scope (DR-032)** |
| Part 26 WordPress + Elementor | brand_structure routing, ads_template_id |
| Part 27 Scoring Framework | brand_authority_score, entity_authority_score, cluster_health_score |
| Part 28 Multilingual v2 | canonical_names jsonb pattern, hreflang_group |
| Part 29 Ads Landing Page Track | seo_website_page_master Ads LP cols, DR-026 |
| **Part 32 Sensitive Topic Compliance 🆕** | **seo_website_page_master compliance cols + seo_reviews PDPA + brands.positioning_mode (DR-030)** |

---

## Appendix E — Multilingual Strategy (Two-Tier Pattern)

DR-009 v2 establishes two tiers:

**Tier 1 — JSONB inline (high-value high-fidelity tables):**
- `brands.compliance_profile` (jsonb)
- `seo_brand_centers.center_name`, `.positioning_one_line` (jsonb)
- `seo_topic_cluster_master.canonical_names`, `.aliases`, `.descriptions` (jsonb)
- `seo_authors_reviewers.canonical_names` (jsonb)
- `seo_branches.canonical_names` (jsonb)

Pattern: `{"th": "...", "en": "...", "zh": "...", "ja": "...", "ko": "...", "ar": "..."}`.

**Tier 2 — Per-page translation versions (page_master via FK chain):**
- `seo_website_page_master.page_language`
- `.translations_versions_fps text[]` — FKs to other-language pages
- `.source_translation_fp` — FK to the source page
- `.translation_status` — workflow status
- `.translation_due_date`

A "translation group" is implicit: all pages sharing a `source_translation_fp` ancestor form one translation set.

**Hreflang:**
- `seo_entity_graph.hreflang_group` — used to bind translated pages of the same entity across languages
- `seo_website_page_master.hreflang_validated boolean` — post-launch hreflang audit gate

---

## Appendix F — Helper Functions & Triggers Reference

### F.1 DR-008 Two-Column Identity functions

| Function | Tables using it |
|---|---|
| `fn_set_fingerprint_brand()` | brands |
| `fn_set_fingerprint_center()` 🆕 v1.18 | seo_brand_centers |
| `fn_set_fingerprint_entity_graph()` | seo_entity_graph |
| `fn_set_fingerprint_page_master()` | seo_website_page_master |
| `fn_set_fingerprint_generic()` | All other fingerprinted tables (15+) |
| `fn_refresh_display_name_brand()` | brands |
| `fn_refresh_display_name_center()` 🆕 v1.18 | seo_brand_centers |
| `fn_refresh_display_name_entity_graph()` | seo_entity_graph |
| `fn_refresh_display_name_page_master()` | seo_website_page_master |
| `fn_prevent_fingerprint_change()` | All fingerprinted tables (shared) |
| `generate_fingerprint()` | Underlying ULID generator |
| `check_fingerprints()` | Operator utility — audit fingerprint integrity across tables |

### F.2 DR-013 Edge Validation (seo_entity_relationships)

- `fn_validate_edge_evidence_requirement()` — raises when edge_type IN ('treats','treated_by','causes','caused_by','contraindicates','symptom_of','diagnoses','prevents','risk_factor_for') AND edge_evidence_citation IS NULL
- `fn_validate_medical_signoff_for_contraindication()` — raises when edge_type='contraindicates' AND medical_reviewer_signoff_at IS NULL

### F.3 DR-021 Reciprocal Link (seo_page_internal_links)

- `fn_check_reciprocal_link()` — AFTER INSERT/UPDATE; auto-creates inverse link row (`to → from`) when forward link added

### F.4 DR-025 Geo Sync (seo_branches)

- `fn_branches_sync_geo_point()` — BEFORE INSERT/UPDATE; recomputes `geo_point geometry(Point,4326)` from `latitude` + `longitude` when either changes

### F.5 DR-032 Multi-Center Validation (seo_website_page_master) 🆕 v1.18

- `fn_validate_page_center_slug()`:
  - If `NEW.center_slug IS NULL` → allow
  - Lookup `brands.brand_structure` for `NEW.brand_id`
  - If `brand_structure='monolithic'` AND `center_slug IS NOT NULL` → RAISE (Group 1 violation per DR-032 §3)
  - If `brand_structure='multi_center'` AND `center_slug NOT IN (seo_brand_centers.center_slug WHERE brand_id=lookup)` → RAISE (slug must match an existing center)

### F.6 Daily Logs Triggers

- `trg_dl_bump_keyword` on `logs_2025`, `logs_2026`, alias view: AFTER INSERT/UPDATE → updates `seo_x_ads_keywords_contextual_master.gsc_last_update` and `ga4_last_update`

### F.7 Monthly Snapshot Triggers

- `trg_ms_bump_keyword` on `seo_x_ads_keywords_monthly_market_snapshot`: AFTER INSERT/UPDATE → updates `seo_x_ads_keywords_contextual_master.satellite_data_updated_at`

### F.8 SERP Snapshot Triggers

- `trg_sc_bump_keyword` on `seo_x_ads_keyword_serp_competitors`: AFTER INSERT/UPDATE → updates parent keyword's `last_checked_at`

### F.9 Brand Scope Denormalization

- `trg_brand_scope_names` on `seo_entity_graph`: BEFORE INSERT/UPDATE — populates `brand_scope_id` + `brand_scope_name` denormalized fields when `cardinality(brand_scope) = 1`

---

## Appendix G — Entity Uniqueness Guard (EUG) Implementation v2.0

EUG v2.0 deferred to a follow-up release. Current state (v1.18):

- v1.0 placeholder: text-based slug uniqueness via UNIQUE constraint on `seo_entity_graph.entity_slug` per brand
- v2.0 plan: pgvector + pg_trgm hybrid:
  - On entity insert, compute embedding via `seo_entity_embeddings` (text-embedding-3-large or equivalent)
  - Query top-K similar entities (cosine distance < 0.05 + trigram similarity > 0.8)
  - Surface candidates to operator review queue
  - Auto-block if exact match (cosine < 0.02 + trigram > 0.95)

Tables ready: `seo_entity_embeddings` (9 cols, HNSW index deferred).
DR ref: DR-011 (EUG Two-Wave Approach v1.2).

---

## Appendix H — Deferred v2.0 Provisions (aspirational columns from v1.0–v1.10)

The v1.0–v1.10 documents listed these columns that were never `ALTER TABLE`'d into the live database. They are preserved here for historical context and potential v2.0 reconsideration. **Do not write SQL referencing these against the current schema.**

### H.1 `brands` (20 dropped columns)

`vertical_family`, `healthcare_format`, `medical_specialty[]`, `primary_branch_id`, `accreditations`, `medical_advisory_board_url`, `wikidata_id`, `wikidata_verified_at`, `knowledge_panel_status`, `cpt_activation_flags`, `signature_offerings[]`, `brand_profile`, `active_languages[]`, `canonical_names jsonb`, `descriptions jsonb`, `brand_authority_score`, `brand_authority_breakdown`, `ai_citation_readiness`, `score_formula_version`, `score_computed_at`.

Note: `brand_authority_score` and breakdown may still ship via DR-related future work (Part 27.7.1 stored procedure + `seo_brand_authority_scores` table — see EYWA Dashboard project pending).

### H.2 `seo_entity_graph` (17 dropped columns)

`canonical_names jsonb`, `descriptions jsonb`, `brand_display_names jsonb`, `icd_11_code`, `snomed_ct_id`, `mesh_id`, `umls_cui`, `same_as text[]`, `applicable_verticals text[]`, `evidence_level text`, `type_properties jsonb`, `reviewed_by_fp`, `freshness_status`, `last_reviewed_at`, `entity_authority_breakdown jsonb`, `entity_freshness_score`, `entity_completeness_score`, `hierarchy_path`, `brand_scope_primary` (GENERATED column never created).

Type drift: `aliases` was specced as `jsonb` in v1.0; live is `text`. v1.18 documents live behavior.

### H.3 `seo_website_page_master` (legacy column names)

The v1.10 doc referred to columns by names that never matched live. v1.18 uses live names:

| v1.10 doc said | Live actual |
|---|---|
| `topical_cluster_id` | `cluster_id` |
| `page_url` | (does not exist — URL is composed from canonical_url + slug) |
| `page_title` | `seo_title` |
| `seo_layer`, `seo_tier` | (does not exist — replaced by `node_tier` + `node_tier_strategy`) |
| `secondary_entities_fps` | `related_entities_fps` |
| `schema_markup_planned jsonb` | (does not exist) |
| `editorial_status` | (does not exist; status flow lives in `status` + `seo_editorial_reviews`) |

### H.4 `seo_editorial_reviews` (column rename)

v1.0–v1.10 doc used `review_stage` with 5-value enum. Live database has always used `review_type` with the 8-value enum (now including `legal_compliance` per DR-030 v1.17). v1.18 corrects.

---

## Appendix I — Wave-Level Migration History

Recent migration waves applied to live DB (verified via `supabase_migrations.schema_migrations`):

| Wave | Date | Migration | DR coverage |
|---|---|---|---|
| W0a | 2026-05-12 | eywa_w0a_01_enable_extensions, eywa_w0a_02_rls_enable_and_permissive_policies | Foundation |
| W0c | 2026-05-12 | dr014_subtype on entity_graph; dr015/016/017/021/026 cols on page_master; dr026 ads track on keywords | DR-014, DR-015, DR-016, DR-017, DR-021, DR-026 |
| W1 | 2026-05-12 | topic_cluster_master, citations, page_citations, entity_relationships (DR-013) | DR-013 |
| W2 | 2026-05-12 | 9 entity extensions (ingredients/devices/procedures/product/condition/drug/anatomy/organization/lab_test) | DR-024 |
| W3 | 2026-05-12 | brands id, authors_reviewers, doctor_assignments, branches (DR-025), reviews, directory_listings, gbp_posts | DR-025 |
| W4 | 2026-05-12 | page_internal_links (DR-021), editorial_reviews | DR-021 |
| W5 | 2026-05-12 | voice_search | — |
| W6 | 2026-05-12 | local_rankings (FK branch_id) | DR-025 |
| W7 | 2026-05-12 | AI operations (brand_mentions, llm_citations, llm_query_simulations, entity_embeddings); governance (data_quality_metrics, schema_changes) | — |
| W8 | 2026-05-12 | brands DR-008 Two-Column Identity setup + finalize | DR-008 |
| W9 | 2026-05-12 | remove Notion FDW + wrappers extension | — |
| W10 | 2026-05-12 | DR-008 propagation: entity_graph + page_master + generic triggers across all fingerprinted tables | DR-008 |
| **W11.1** | **2026-05-27** | **eywa_w11_01_dr030_v17_sensitive_topic_compliance** | **DR-030** |
| **W11.2** | **2026-05-27** | **eywa_w11_02_dr032_v18_multi_center_hospital** | **DR-032** |
| **W11.3** | **2026-05-29** | **eywa_w11_03_brand_centers_notion_sync_cols** (add notion_id/notion_synced_at/sync_state) | **DR-032 follow-up** |
| **W11.4** | **2026-06-02** | **eywa_w11_04_dr033_v19_icd_dual_coding_condition** (seo_entity_condition +icd11_code +icd10_cm_code) | **DR-033** |

---

**END OF SCHEMA OVERVIEW v1.19**

> Generated 2026-05-30 from full audit against live Supabase project `lffcbeszjqzioobqfdav` (v1.18); v1.19 delta (DR-033, W11.4) verified live 2026-06-02. Cross-referenced against DECISION_RECORDS.md (DR-001 through DR-033), Bible v3.19, and Handover v1.18.
>
> For schema corrections: file an issue in the spec repo or amend via DR-NNN process. Direct edits to this document without a DR are discouraged (the doc is meant to mirror live DB; live DB is the source of truth, this doc is the human-readable index).



