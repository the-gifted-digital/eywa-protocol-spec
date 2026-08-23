# 📊 Schema Overview — EYWA™ PROTOCOL Database

**Version:** v1.23 (2026-06-11) — DR-038 Canonicalize `seo_media_assets` (Group 11 NEW §13.1, BUILT) + Cloudflare config columns on `brands` (§3.1, BUILT) 🔒🖼️☁️
**Live database:** Supabase project `lffcbeszjqzioobqfdav` ("GTGT") · region `ap-northeast-1` · Postgres 17
**Total base tables:** 43 EYWA canonical tables — all 43 confirmed present *(corrected 2026-08-24 against live schema: the count is right, the scope claim was not — `public` also holds non-EYWA tables `tsa_bond`/`tsa_bond_valued`/`tsa_call`/`tsa_event`/`tsa_page_product`/`tsa_param`/`tsa_product_map`/`tsa_product_value`, `fbads_account`/`fbads_daily`/`fbads_sync_log`, `web_lead`, `ss_kw_seed_wave16_20260806`, plus ~140 `_`-prefixed backup/scratch tables and 7 `v_` views. The live list is whatever `GET /rest/v1/` returns as OpenAPI definitions; do not hardcode a total)* — `seo_media_assets` §13.1 (Group 11) canonicalized 2026-06-11 via migration `eywa_w11_08` (DR-038); `brands` §3.1 +4 Cloudflare cols via `eywa_w11_09` (DR-038); `seo_payer_partners` §3.9 canonicalized 2026-06-08 via migration `eywa_w11_07` (DR-037); `seo_entity_symptom` §11.5a built 2026-06-04 via `eywa_w11_06`
**Spec stack:** Bible v3.32 · Handover v1.18 · Decision Records v1.24
**Audit method:** Last full drift audit vs live `information_schema` was **2026-05-30**. A cross-brand reconciliation on 2026-08-23 checked 2,317 documented claims against the live database and found 1,837 that no longer match, including 336 rules that cannot fire at all. **Every column count, allowed-value list and row count in this document was re-checked against the live PostgREST schema + live data on 2026-08-24**; corrections carry an inline `*(corrected 2026-08-24 against live schema)*` marker. Row counts drift daily — treat every number here as a measurement with a date, not a constant. Constraint definitions (CHECK bodies, trigger existence, index lists, partitions) are **not** reachable through PostgREST and remain unverified since 2026-05-30. See `eywa-vth-biodent/content-plan/` reconciliation report.

> **Reader heads-up:** v1.18 is a **full rewrite + audit** of v1.10. Aspirational columns from v1.0–v1.10 that never shipped are dropped (or moved to **Appendix H — Deferred v2.0 Provisions**). Every column under each table reflects the live database. Two new DR waves landed in this version:
> - **DR-030 Sensitive Topic Compliance** (Schema v1.17, 2026-05-27)
> - **DR-032 Multi-Center Hospital Brand Pattern** (Schema v1.18, 2026-05-27)
> - **DR-033 ICD Dual-Coding Standard** (Schema v1.19, 2026-06-02) — `seo_entity_condition` gains `icd11_code` + `icd10_cm_code`
> - **DR-034 Intra-Page Answer Routing (PAA × FAQ)** (Schema v1.20, 2026-06-03) — `seo_website_page_master` gains `intent_source_tier` + `paa_checked_at`
> - **DR-036 Split `condition` / `symptom` CPTs** (Schema v1.21, 2026-06-04 🔒) — new Group-9 extension `seo_entity_symptom` (29 cols, S-only, 1:1 with `entity_graph type='symptom'`, mirrors `seo_entity_condition`); **BUILT** via migration `eywa_w11_06`

---

## Changelog

### v1.23 (2026-06-11) — DR-038 Canonicalize `seo_media_assets` + Cloudflare config on `brands` 🔒🖼️☁️

Paired companion to **DR-038 (Locked 2026-06-11)**. Ships Group 11 NEW (Media Assets) closing the Supabase-side gap flagged in Bible v3.31; adds per-brand Cloudflare account routing on `brands` so n8n can resolve which CF account/zone/R2 bucket to upload to per brand.

- ➕ **Group 11 NEW — Media Assets** — `seo_media_assets` §13.1 (37 cols, Family-B operational pattern). DR-008 two-column identity (`mda_{ULID16}`), DR-006 two-phase sync, 11-option `media_type` enum mirroring Notion select (doctor/branch/brand/treatment/procedure/condition/tech/case/clinic/brand_asset/other), Family-B `brand_id uuid` FK with `ON DELETE CASCADE`, soft entity binding via `entity_fp text`, DR-032 multi-center `center_scope[]`, PDPA consent gate via `CHECK pdpa_active_consent_gate` (patient image cannot go Active without Obtained consent + use window), DR-035 Cloudflare R2 fields (`r2_account_email/r2_bucket/r2_object_key/r2_uploaded_at/cdn_url`), 6 indexes incl. partial index on `use_until` for consent-expiry alerting, RLS `eywa_authenticated_full_access`, 3 triggers.
- ➕ **`brands` §3.1 +4 Cloudflare config columns** — `cloudflare_account_email`, `cloudflare_account_id`, `cloudflare_zone_id`, `cloudflare_r2_bucket` + partial index. Drives n8n image-upload routing decision (Layer A of DR-038's 2-layer design). Brand → CF account binding lives here (canonical); Notion `☁️ Cloudflare Accounts` reference DB is Layer B (operator UI, no Supabase mirror).
- 🗃️ **Schema v1.22 → v1.23** (Wave 11.8 + 11.9 applied 2026-06-11). Base tables 42 → 43; Groups 1–10 → Groups 1–11.
- 🔄 **§2 group count updated:** 10-Group → 11-Group organization; total reflects 43 base tables.
- 🔄 **Appendix I migration history extended:** W11.5 (DR-034 PAA routing) + W11.6 (DR-036 entity_symptom) + W11.7 (doctor_assignments notion sync cols) + W11.8 (DR-038 media_assets) + W11.9 (DR-038 brands CF cols) — Appendix was stale before v1.23 bump.
- 📌 **Appendix J unchanged at 14 N↔S rows** — `☁️ Cloudflare Accounts` is operator-UI-only (no Supabase mirror, no sync flow); see Bible §18.1.2b for non-mirror reference DBs.

### v1.22 (2026-06-08) — DR-037 Canonicalize `seo_payer_partners` Federation Table 🔒🏥🧾

**Migration:** `eywa_w11_07_dr037_v22_payer_partners_canonical` — **APPLIED 2026-06-08.** In-place composite ALTER of the brand-local Deezy table (DZ-DR-014); 71 rows migrated, no data loss.

**New canonical Group-1 table `seo_payer_partners` §3.9 (19 cols)** — per-brand directory of commercial payer partners (cashless insurers + corporate-welfare employers). Backported from Deezy's brand-local table into the canonical federation schema as a **Family-B per-brand-operational** table (sibling of `seo_branches`/`seo_reviews`/`seo_directory_listings`/`seo_gbp_posts`/`seo_doctor_assignments`). Group 1 **8 → 9**; base tables **41 → 42**.

- ➕ **DR-037 (NEW, Locked):** `brand_id` migrated `text`(slug) → `uuid NOT NULL` FK → `brands(id)`; +DR-008 two-column identity (`fingerprint text NOT NULL UNIQUE` `payp_{ULID16}` + `fingerprint_display_name`), trigger-set via `fn_set_fingerprint_generic('payp','partner_name','partner_name')` + `fn_prevent_fingerprint_change`. RLS `eywa_authenticated_full_access` unchanged. Retained CHECKs (`partner_type`/`insurer_category`/`verification_status`), UNIQUE `(brand_id,partner_type,partner_name)`.
- 🔧 **Distinct from `seo_entity_organization` (§11.8)** — that hosts authority/citation orgs (E-E-A-T graph); payers are operational, per-brand, high-churn reference data. Not a knowledge-graph entity (no `seo_entity_graph` row).
- 🔧 §2 Group-1 list + §3 heading (8→9) + total base tables (41→42) updated. Verified: 71/71 distinct well-formed fingerprints; FK valid; bare `INSERT` auto-sets fingerprint.
- 🔒 Companion Bible → **v3.29**. See **DR-037**.

### v1.21 (2026-06-04) — DR-036 Split `condition` / `symptom` CPTs 🔒🧬🩺

**Migration:** `eywa_w11_06_dr036_v21_entity_symptom` — **APPLIED 2026-06-04.** Greenfield/additive `CREATE TABLE` + RLS policy; no data, no existing table touched.

**New Group-9 extension `seo_entity_symptom` §11.5a (29 cols)** — sibling to `seo_entity_condition`, 1:1 with `seo_entity_graph` rows where `type='symptom'` (already a valid enum value — see §4.1 `entity_type` CHECK). `entity_fp text NOT NULL UNIQUE` FK → `seo_entity_graph.entity_fingerprint` ON DELETE CASCADE; PK `id uuid`; RLS-enabled (`eywa_authenticated_full_access`). Mirrors the condition extension, dropping condition-only fields (`prevalence_*`, `is_chronic`/`is_acute`, `mortality_rate_pct`) and adding symptom-specific ones (severity/onset CHECK-constrained, YMYL safety, cross-CPT FKs). Group 9 **10 → 11**; base tables **40 → 41**.

- ➕ **DR-036 (NEW, Locked):** realizes the Bible §25.3 `condition`/`symptom` CPT split at the schema layer. `condition` vs `symptom` is carried by `seo_entity_graph.type` (no schema discriminator change needed — both already in the `entity_type` enum). `seo_entity_condition` now hosts conditions only.
- 🔧 §2 Group-9 list + §11 heading + §4.1 `entity_type` note updated (`symptom` becomes the 10th extension-bound type). `entity_subtype` (DR-014 concept-axis) **unchanged** — it never discriminated condition/symptom at the schema level.
- 🔒 Companion Bible → **v3.26** (Tier-1 Core 8→9). See **DR-036**.

### v1.20 (2026-06-03) — DR-034 Intra-Page Answer Routing (PAA × FAQ) 🔒🧭

**Migration:** `eywa_w11_05_dr034_v20_page_master_paa_routing` (W11.5, applied 2026-06-03).

**`seo_website_page_master` 88 → 90 cols** — adds the two columns that record where a page's on-page intent coverage came from and whether PAA has been crawled:
- `intent_source_tier text NOT NULL DEFAULT 'template_only'` 🆕 — `CHECK IN ('paa','derived','template_only')`. Which signal drove the page's intent map: real PAA, derived (painpoint / predicted SERP features / voice), or the 8-intent template baseline.
- `paa_checked_at timestamptz` 🆕 — last PAA crawl time. `NULL` = never crawled (trigger a crawl, *not* tier-3). SET + empty PAA store = checked, genuinely no PAA → tier-2/3.

Additive, non-breaking; the NOT NULL column carries a safe default so existing 1,376 rows auto-set to `template_only` (no backfill). **NOT** in the page fingerprint → no reference cascade. Drives **Content_Templates §4.5.4 Intra-Page Answer Routing** (understanding-PAA → body, decision-PAA → FAQ; page-level ≥8 intent coverage; tiered FAQ floor). PAA source is **`seo_x_ads_keyword_serp_competitors.people_also_ask_json`** (with `paa_ai_content_json`). *(corrected 2026-08-24 against the live schema — this entry had the mapping exactly backwards: `people_also_ask_json`, `paa_ai_content_json` and `related_searches` **do** exist on that table, and `paa_questions` does not exist at all. `keyword_painpoint` + `predicted_serp_features` + `seo_x_voice_search` remain the `derived` inputs.)* See **DR-034**.

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
| `EYWA_PROTOCOL_v3_33.md` (Bible) | Strategic intent, why columns exist, workflow context *(corrected 2026-08-24 — the file in the spec repo is v3_33; no `EYWA_PROTOCOL_v3_19.md` exists there)* |
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

### The 11-Group Organization 🔄 v1.23

| Group | Theme | Tables (count) | Sync Direction |
|---|---|---|---|
| **Group 1** | Brand & Organization | brands, seo_branches, seo_brand_centers 🆕 v1.18, seo_authors_reviewers, seo_doctor_assignments, seo_reviews, seo_directory_listings, seo_gbp_posts, seo_payer_partners 🆕 v1.22 (**9**) | N↔S (master) · S only (reviews/directory_listings/gbp_posts/payer_partners via API ingest / curated) |
| **Group 2** | Knowledge Architecture | seo_entity_graph, seo_topic_cluster_master, seo_citations, seo_page_citations, seo_entity_relationships (**5**) | N↔S |
| **Group 3** | Page System | seo_website_page_master, seo_editorial_reviews, seo_page_internal_links (**3**) | N↔S |
| **Group 4** | Keyword & Search Intelligence | seo_x_ads_keywords_contextual_master, seo_x_ads_keywords_monthly_market_snapshot, seo_x_ads_keyword_serp_competitors, seo_x_voice_search (**4**) | N↔S (master) · S only (monthly_snapshot, serp_competitors) |
| **Group 5** | Performance Fact Tables | seo_x_ads_keywords_x_url_daily_logs (alias for logs_YYYY partitions), seo_local_rankings (**2**) | S only |
| **Group 6** | Backlinks & Off-Page | seo_backlinks_data, seo_backlinks_links (**2**) | S only (Ahrefs/Moz/DFS ingest) |
| **Group 7** | AI Operations & Embeddings | seo_brand_mentions, seo_llm_citations, seo_llm_query_simulations, seo_entity_embeddings (**4**) | S only |
| **Group 8** | Data Quality & Governance | seo_data_quality_metrics, seo_schema_changes (**2**) | S only |
| **Group 9** | Entity Extensions & Templates | seo_entity_ingredients, seo_entity_devices, seo_entity_procedures, seo_entity_product, seo_entity_condition, seo_entity_symptom, seo_entity_drug, seo_entity_anatomy, seo_entity_organization, seo_entity_lab_test, seo_programmatic_templates (**11**) | S only (built without notion_id despite spec comment; treat as S-only — see §11 intro). `seo_entity_symptom` built per DR-036 (§11.5a) |
| **Group 10** | Ads Landing Page Track (column extensions only) | (no new tables; columns on page_master + keyword master) | — |
| **Group 11** 🆕 v1.23 | Media Assets | seo_media_assets (**1**) | N↔S (Notion master 🖼️ Media Library; n8n → Cloudflare R2 + Supabase mirror per DR-038) |

**Total: 43 EYWA canonical base tables** (incl. `seo_entity_symptom` built 2026-06-04 DR-036; `seo_payer_partners` canonicalized 2026-06-08 DR-037; `seo_media_assets` shipped 2026-06-11 DR-038). *(corrected 2026-08-24 against live schema — all 43 exist; `public` additionally holds non-EYWA tables and ~140 backup/scratch tables that this 43 does not count, see the header note.)*

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
| 11 🆕 v1.23 | N↔S | `seo_media_assets` mirrors Notion 🖼️ Media Library in every workspace; binaries land in Cloudflare R2 (per DR-035) — see §13.1 |

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

## 3. Group 1 — Brand & Organization (9 tables)

> Authoritative tables for brand identity, physical/local presence, medical staff, multi-center subdivision, and external reputation signals.
>
> **DR-032 v1.18 addition:** `seo_brand_centers` for multi-center hospital brands (e.g., Vitality Hospital).

### 3.1 `brands`

> **Purpose:** Authoritative brand registry. One row per brand (e.g., `vth-biodent`, `vitality-hospital`, `the-face-by-vertex`).
> **Sync:** N↔S (Notion master `[DB 1.1] Brand Database`, Supabase mirror via n8n)
> **PK:** Currently on `brand_name` (legacy from v1.0); UNIQUE on `id` (UUID), `brand_slug`, `fingerprint`, `notion_id`. Migration to id-as-PK deferred to v2.0.
> **Volume:** 10–50 rows (current: **20**, measured 2026-08-24). *(corrected 2026-08-24 against live schema)*
> **Bible:** §17.6 Group A (Brand Identity)

#### Columns (31 — full live snapshot; was documented as 24) *(corrected 2026-08-24 against live schema — +`notion_synced_at` and +6 Tsaheylu/analytics columns were never documented)*

| Column | Type | Constraint | Description |
|---|---|---|---|
| `id` | `uuid` | DEFAULT `gen_random_uuid()`, UNIQUE | Stable machine key (NOT current PK; v2.0 target). |
| `brand_name` | `text` | PK | Human-readable name (e.g. "VTH BioDent"). |
| `brand_slug` | `text` | UNIQUE NOT NULL | DR-010 v1.9 — URL-safe kebab-case (auto from brand_name via lowercase + dash normalization). |
| `fingerprint` | `text` | UNIQUE NOT NULL | DR-008 v1.9 — `brnd_{ULID16}` immutable machine ID. Auto-generated by `trg_set_fingerprint_brand`. Immutable via `trg_prevent_fingerprint_change`. |
| `fingerprint_display_name` | `text` | NOT NULL | DR-008 v1.9 — auto-computed `{fp_last_6}::{brand_slug}` by `trg_refresh_display_name_brand`. |
| `company` | `text` | nullable | Legal company name (e.g. "The Gifted Digital Co., Ltd."). |
| `status` | `text` | nullable | Lifecycle status. *(corrected 2026-08-24 against live schema — no CHECK; the only values in the table are `'active'` (7 rows, one with a trailing newline) and the empty string (13 rows). `'ACTIVE'`/`'IN ACTIVE'`/`'PENDING'` appear nowhere.)* |
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
| `cloudflare_account_email` 🆕 v1.23 | `text` | nullable | DR-038 Layer A — which Cloudflare account hosts this brand's assets (e.g. `marketing@vplanetgroup.com`). Drives n8n image-upload routing decision. Operator-curated; canonical registry in Notion `☁️ Cloudflare Accounts` reference DB. |
| `cloudflare_account_id` 🆕 v1.23 | `text` | nullable | DR-038 — Cloudflare numeric account ID (optional; used for account-scoped API endpoints). |
| `cloudflare_zone_id` 🆕 v1.23 | `text` | nullable | DR-038 — Cloudflare DNS zone ID for this brand's primary domain; used by Image Transformations (per DR-035). |
| `cloudflare_r2_bucket` 🆕 v1.23 | `text` | nullable | DR-038 — R2 bucket name that holds this brand's images (`{brand-slug}-media`). **One bucket per brand — no cross-brand sharing (DR-040, 2026-06-14).** |
| `notion_synced_at` | `timestamptz` | nullable | *(added 2026-08-24 — live column, never documented.)* Last bidirectional Notion sync. N→S poll filters on `last_edited_time > notion_synced_at`. |
| `gtm_container_id` | `text` | nullable | *(added 2026-08-24 — live column, never documented.)* Tsaheylu: GTM container (`GTM-XXXXXXX`). Public value, not a secret. |
| `ga4_measurement_id` | `text` | nullable | *(added 2026-08-24 — live column, never documented.)* Tsaheylu: GA4 web-stream measurement id (`G-XXXXXXXXXX`). Distinct from `ga4_property_id`. |
| `bq_dataset` | `text` | nullable | *(added 2026-08-24 — live column, never documented.)* GA4→BigQuery export dataset. NULL = export off (raw events for that period are lost permanently). |
| `tsa_phase` | `smallint` | nullable | *(added 2026-08-24 — live column, never documented.)* Tsaheylu rollout phase 0–5. |
| `tsa_events_live` | `jsonb` | nullable | *(added 2026-08-24 — live column, never documented.)* Event names verified firing in production. |
| `tsa_verified_at` | `timestamptz` | nullable | *(added 2026-08-24 — live column, never documented.)* |
| `created_at` | `timestamptz` | NOT NULL DEFAULT `now()` | |
| `updated_at` | `timestamptz` | NOT NULL DEFAULT `now()` | |

#### Indexes

- `brands_pkey` PRIMARY KEY (brand_name)
- `brands_id_unique` UNIQUE (id)
- `brands_brand_slug_unique` UNIQUE (brand_slug)
- `brands_fingerprint_unique` UNIQUE (fingerprint)
- `brands_notion_id_key` UNIQUE (notion_id) WHERE notion_id IS NOT NULL
- `idx_brands_cloudflare_account_email` (partial) WHERE cloudflare_account_email IS NOT NULL — 🆕 v1.23 DR-038

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
> **Volume:** 1–20 rows per brand — **37 rows** across all brands, measured 2026-08-24. *(corrected 2026-08-24 against live schema)*

#### Columns (61 — abridged to logical groups; full DDL in live `information_schema`) *(corrected 2026-08-24 against live schema — was documented as 60)*

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
> **Volume:** 1–30 per brand; shared across brands via `seo_doctor_assignments`. **184 rows** total, measured 2026-08-24. *(corrected 2026-08-24 against live schema)*

#### Columns (28) *(corrected 2026-08-24 against live schema — was documented as 26; live adds `load_from` + `load_source`, the DZ-DR-029 federation-provenance pair)*

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
| `load_from text`, `load_source text` | *(added 2026-08-24 — live columns, never documented.)* DZ-DR-029 federation provenance: which brand's load created the row, and from which file |
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
> **Volume:** ~1 row per (author × brand) pair — **262 rows**, measured 2026-08-24. *(corrected 2026-08-24 against live schema)*

#### Columns (16) *(corrected 2026-08-24 against live schema — was documented as 13; the three Notion-sync columns added by Wave 11.7a, already listed in Appendix I, were never added to this table)*

| Column | Type | Notes |
|---|---|---|
| `id uuid` UNIQUE | |
| `fingerprint text` | `docasg_{ULID16}` |
| `fingerprint_display_name text` | `{fp_last_6}::{role_at_brand}` *(corrected 2026-08-24 against live data — e.g. `6E40BA::medical_director`; no brand or author segment is stored)* |
| `author_id uuid` | FK → seo_authors_reviewers.id |
| `author_fp text` | FK → seo_authors_reviewers.fingerprint |
| `brand_id uuid` | FK → brands.id |
| `branch_id uuid` | FK → seo_branches.id (NULL = brand-wide assignment) |
| `role_at_brand text` | CHECK IN (`'reviewer'`,`'author'`,`'consultant'`,`'medical_director'`,`'attending'`,`'visiting'`) |
| `is_primary_role boolean` | True = primary brand affiliation for this doctor |
| `started_at date` | |
| `ended_at date` | NULL = active |
| `notion_id text`, `notion_synced_at timestamptz`, `sync_state text` | *(added 2026-08-24 — live columns; added by W11.7a 2026-06-04, never listed here)* |
| `created_at`, `updated_at` | |

---

### 3.5 `seo_reviews` (Local SEO — Multi-platform customer reviews) 🔒 v1.11

> **Purpose:** Multi-platform reviews (GBP, Wongnai, Pantip, Facebook, Google Maps) + PDPA workflow for sensitive testimonials.
> **Sync:** **S only** — ingested via GBP API + n8n flows (E1)
> **DR-025 v1.11** — Local SEO subsystem
> **DR-030 v1.17** — +3 cols for sensitive recovery testimonials (consent + anonymization workflow)
> **Volume:** ~1k–100k rows per brand at maturity — **0 rows** live, measured 2026-08-24: the GBP/n8n ingest has never run, so every rule below is schema-ready but has nothing to fire on. *(corrected 2026-08-24 against live schema)*

#### Columns (45 — abridged) *(count confirmed 2026-08-24 against live schema)*

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

37 columns *(confirmed 2026-08-24 against live schema)* · **0 rows** live, measured 2026-08-24 — the flow-E3 auto-detect has never run. Key fields *(every name below corrected 2026-08-24 against the live column list — eight of the ten previously listed here did not exist; only `directory_name` and `claim_status` were real)*:
- `directory_name text` (`'YellowPages_TH'`, `'Wongnai'`, `'TripAdvisor'`, etc.), `directory_slug`, `directory_category`, `directory_authority_score`
- `citation_url text` — the listing URL *(live name; this doc said `listing_url`)*
- `business_name_listed`, `address_listed`, `phone_listed`, `website_listed`, `hours_listed`, `categories_listed` — NAP as found on the directory *(live names; this doc said `nap_name` / `nap_address` / `nap_phone`)*
- `nap_match_score` plus per-field `name_match_score`, `address_match_score`, `phone_match_score`, `website_match_score` *(live names; this doc said `nap_consistency_score`)*
- `has_inconsistency boolean`, `inconsistency_severity`, `inconsistency_notes` *(live names; there is no `nap_mismatch_flags text[]`)*
- `claim_status text`, `claimed_at`, `claimed_by_fp` *(live; there is no `is_claimed boolean`)*
- `last_verified_at timestamptz`, `next_verification_due`, `discovered_at`, `found_via` *(live names; this doc said `last_audited_at`)*
- `brand_id`, `branch_id`, `status`, `is_industry_specific`, `industry_focus`, `is_thai_specific`

(Full column list in live DB; this section will be expanded in v1.19 if directory listings become a primary editorial workflow surface. Currently low-touch S-only.)

---

### 3.7 `seo_gbp_posts` 🔒 v1.11

> **Purpose:** Google Business Profile Posts management + local archive.
> **Sync:** S only — n8n flow E2/E4 (publish to GBP) + E4 (archive responses)

45 columns *(confirmed 2026-08-24 against live schema)* · **0 rows** live, measured 2026-08-24 — flows E2/E4 have never published. Key fields *(every name below corrected 2026-08-24 against the live column list — eight of the eighteen previously listed here did not exist)*:
- `gbp_post_id text` (Google's ID), `gbp_post_url`, `gbp_published_at`, `gbp_last_synced_at`, `gbp_api_response jsonb`
- `post_type text` (`'EVENT'`, `'OFFER'`, `'WHATS_NEW'`, `'PRODUCT'`)
- `title text`, `body text` *(live name is `title`; this doc said `headline`)*
- `cta_type text`, `cta_url text` *(live name is `cta_type`; this doc said `cta_label`)*
- `event_start_at`, `event_end_at` *(live names; this doc said `event_start_date` / `event_end_date`)*
- `offer_coupon_code`, `offer_terms`, `offer_redeem_url`
- `product_name`, `product_price_min`, `product_price_max`, `product_currency`
- `photo_url text`, `video_url text` *(live names; there is no `media_urls text[]`)*
- `brand_id`, `branch_id uuid` (FK → seo_branches), `language_code`
- `scheduled_for timestamptz` *(live name; this doc said `scheduled_publish_at`)*, `published_at`, `expires_at`
- `views_count int`, `clicks_count int`, `conversions_count`, `engagement_rate` *(live names; this doc said `gbp_views_count` / `gbp_clicks_count`)*
- `status text`, `approval_status`, `approved_at`, `approved_by_fp`, `rejection_reason` — value lists unverifiable: the CHECK bodies are not exposed by PostgREST and the table is empty
- `campaign_id`, `campaign_name`, `batch_id`, `parent_post_id`

---

### 3.8 `seo_brand_centers` 🆕 v1.18 (DR-032)

> **Purpose:** Center subdivision for brands where `brands.brand_structure='multi_center'`. One row per center within a multi-center hospital brand.
> **Sync:** N↔S (Notion `Brand Centers Database`, Supabase mirror via Wave 11.3 follow-up)
> **First adopter:** `vitality-hospital` was the planned first adopter (7 centers — Vital Sleep, Vital Sleep Intimacy, Vital Breathing, Vital Facial Pain, Vital Wellness, Vital Effortless Weight Loss, Vital Brain Center).
> 🔴 **DR-032 is DORMANT — nothing in this section can fire today** *(corrected 2026-08-24 against live schema)*: `seo_brand_centers` holds **0 rows**, all **20** `brands` rows carry `brand_structure='monolithic'` (no `multi_center` brand exists), and all **2,358** `seo_website_page_master` rows have `center_slug` NULL. The table, the trigger and the URL pattern below are built and correct; they simply have no data. Re-measure with `select brand_structure, count(*) from brands group by 1`.
> **DR:** DR-032 (Locked 2026-05-25) — Multi-Center Hospital Brand Pattern
> **Bible:** §25.13 (post-lock propagation)

#### Columns (17) *(confirmed 2026-08-24 against live schema)*

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

### 3.9 `seo_payer_partners` 🆕 v1.22 (DR-037)

> **Purpose:** Per-brand directory of **commercial payer partners** — cashless insurers + corporate-welfare employers — rendered on a brand's cashless/partner directory pages (e.g. Deezy sitemap §2.7/§2.8). Operational, per-brand, high-churn reference data.
> **Distinct from `seo_entity_organization` (§11.8):** that table hosts **authority/citation** orgs for the E-E-A-T graph; payers are commercial partners, **not** knowledge-graph entities (no `seo_entity_graph` row).
> **Sync:** S only (operator-curated / API-ingested reference data; refresh cadence per brand)
> **First adopter:** `deezy-dental` — **70 rows** as of 2026-08-24: 35 insurers (`insurer_category`: 23 non_life, 7 life, 4 foreign, 1 tpa) + 35 employers. *(corrected 2026-08-24 against live schema — the 71/36-insurer figure was the 2026-06-08 migration count; one insurer row has since gone.)*
> **DR:** DR-037 (Locked 2026-06-08) — canonicalized from brand-local DZ-DR-014 into the Family-B per-brand-operational shape (sibling of `seo_branches` §3.2 / `seo_reviews` §3.5 / `seo_directory_listings` §3.6).
> **Bible:** §5.3 Group 1

#### Columns (19) *(confirmed 2026-08-24 against live schema)*

| Column | Type | Constraint | Description |
|---|---|---|---|
| `id` | `uuid` | PRIMARY KEY DEFAULT `gen_random_uuid()` | Surrogate PK. |
| `fingerprint` | `text` | NOT NULL, UNIQUE | DR-008 — `payp_{ULID16}` immutable. Auto-set by `trg_set_fingerprint`. ✅ verified live 2026-08-24. |
| `fingerprint_display_name` | `text` | NOT NULL | DR-008 — `{fp_last_6}::{partner_name}` auto-computed. |
| `brand_id` | `uuid` | NOT NULL, FK → `brands(id)` | Owning brand. uuid FK (matches the Local-SEO operational subsystem), **not** `brand_scope[]`. |
| `partner_type` | `text` | NOT NULL, CHECK IN (`insurer`,`employer`) | Row discriminator. |
| `partner_no` | `integer` | nullable | Source/infographic ordering (Deezy used 101–104 for foreign insurers). |
| `partner_name` | `text` | NOT NULL | TH legal/display name. |
| `partner_name_en` | `text` | nullable | English name (foreign insurers / english-named corps). |
| `insurer_category` | `text` | CHECK NULL OR IN (`life`,`non_life`,`tpa`,`foreign`) | Insurer-only classification. |
| `cashless` | `boolean` | nullable | Insurer = direct-billing / no upfront payment. |
| `opd_only` | `boolean` | NOT NULL DEFAULT `false` | Coverage limited to OPD. |
| `affiliates` | `text[]` | nullable | "บริษัทในเครือ" sub-companies. |
| `affiliate_count` | `integer` | nullable | |
| `conditions_note` | `text` | nullable | Conditional scope / data-quality note. |
| `verification_status` | `text` | NOT NULL DEFAULT `unverified`, CHECK IN (`unverified`,`verified`,`needs_review`) | Operator data-validation state (orthogonal to schema canonicalization). |
| `source` | `text` | nullable | Provenance. |
| `last_verified_date` | `date` | nullable | |
| `created_at` | `timestamptz` | NOT NULL DEFAULT `now()` | |
| `updated_at` | `timestamptz` | NOT NULL DEFAULT `now()` | |

#### Indexes

- PRIMARY KEY (id)
- UNIQUE (fingerprint) — `seo_payer_partners_fingerprint_key`
- UNIQUE (brand_id, partner_type, partner_name) — `seo_payer_partners_uniq`
- `idx_seo_payer_partners_brand` btree (brand_id)
- `idx_seo_payer_partners_type` btree (brand_id, partner_type)

#### Triggers

- `trg_set_fingerprint` BEFORE INSERT → `fn_set_fingerprint_generic('payp','partner_name','partner_name')` — generates `payp_{ULID16}` if NULL + computes display_name. (Confirmed: a bare `INSERT` of `brand_id`+`partner_type`+`partner_name` auto-populates both identity columns.)
- `trg_prevent_fingerprint_change` BEFORE UPDATE → `fn_prevent_fingerprint_change()` (shared) — DR-008 immutability.

#### Constraints

- FK `seo_payer_partners_brand_id_fkey` (brand_id) → `brands(id)`
- CHECK `partner_type ∈ {insurer, employer}`
- CHECK `insurer_category` NULL or ∈ {life, non_life, tpa, foreign}
- CHECK `verification_status ∈ {unverified, verified, needs_review}`
- RLS enabled — policy `eywa_authenticated_full_access` (ALL / authenticated / true)

> **Convention note (DR-037):** no per-table fingerprint **format CHECK** — like every Family-B table, the `payp_` format is enforced by `fn_set_fingerprint_generic` + the UNIQUE index, not a CHECK constraint. `brand_id` is `uuid` FK (matching branches/reviews/directory/gbp/doctor); `seo_brand_centers` and `seo_website_page_master` use `text → brand_slug` instead — a known live split, see DR-037 rationale.

---

## 4. Group 2 — Knowledge Architecture (5 tables)

> Entity graph (universal concepts), topic clusters (SKOS classification), citation pool (evidence backing), entity relationships (typed edges), and the page↔citation junction.

### 4.1 `seo_entity_graph`

> **Purpose:** Master of every named entity (condition, treatment, ingredient, drug, etc.) used across EYWA brands. Foundation of the Knowledge Graph.
> **Sync:** N↔S (Notion `🧬 Entity Graph`, Supabase mirror)
> **DR:** DR-008 (Two-Column Identity), DR-013 (edge vocab — see §4.5), DR-014 (entity_subtype lock for concept type), DR-024 (links to Group 9 extensions), DR-032 (center_scope)
> **Volume:** ~500–5,000 per brand · **732 rows**, measured 2026-08-24. `brand_scope`: 665 `['*']` (shared), 38 vth-biodent, 25 smile-scape-clinic, 4 deezy-dental. *(corrected 2026-08-24 against live schema — was "466 rows, VTH BioDent + VitalSleep and Wellness only")*

#### Columns (36 — full live snapshot) *(corrected 2026-08-24 against live schema — was documented as 34; live adds `load_from` + `load_source`)*

| Column | Type | Notes |
|---|---|---|
| `id` `uuid` UNIQUE | machine key |
| `fingerprint` `text` | `ent_{ULID16}` (DR-008) |
| `fingerprint_display_name` `text` | `{fp_last_6}::{entity_slug}` |
| `entity_fingerprint` `text` | 🔴 **LOAD-BEARING — DO NOT DROP.** This is the key the whole entity layer actually resolves on: 12 FKs target it, 1,089/1,089 edges and 2,043/2,043 page `primary_entity_fp` bindings resolve here, while `fingerprint` resolves **0**. *(re-measured 2026-08-24 and still exact: 1,089 of 1,089 edges and 2,043 of 2,043 non-NULL `primary_entity_fp` values match an `entity_fingerprint`; zero match a `fingerprint`. The value is the entity slug, e.g. `horizontal-bone-deficiency`.)* §11.5a of this same document defines new extension FKs against it. The former note calling it "Legacy v1.10, drop in v2.0" was wrong and is withdrawn 2026-08-23 — acting on it would orphan the entity graph for all three brands at once. |
| `entity_name` `text` | Canonical display name |
| `entity_slug` `text` | Canonical machine key (immutable) |
| `entity_type` `text` | CHECK enum — see below |
| `entity_subtype` `text` 🆕 v1.14 | DR-014 — for `entity_type='concept'` only: CHECK `chk_concept_subtype` IN (`'framework'`,`'axis'`,`'general'`) or NULL; other entity_types are free-text. *(corrected 2026-08-24 against live schema — the third value is `'general'`, not `'health-belief'`; Appendix J.5 row 1 already said so. The column is **NULL in all 732 rows**, so the DR-014 concept-axis lock has never been exercised.)* |
| `parent_entity_fp` `text` | **Legacy** — use `seo_entity_relationships` w/ `edge_type='child_of'` for typed edges (Bible Part 2.7); kept for backward compat |
| `topic_cluster_id` `text` | denormalized cluster key (FK soft → seo_topic_cluster_master.cluster_slug) |
| `topic_cluster_name` `text` | denormalized cluster name |
| `schema_org_type` `text` | `'MedicalCondition'`, `'MedicalTherapy'`, `'MedicalProcedure'`, `'Symptom'`, `'MedicalSpecialty'`, `'Drug'`, `'MedicalDevice'`, etc. |
| `entity_authority_score` `numeric` | **0–10**, DR-013 evidence rollup · live range 0.3–7.94, nothing above 8 *(corrected 2026-08-24 — documented 0–100, so a "promote entities ≥70" rule matches nothing, ever)* |
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
| `load_from` `text`, `load_source` `text` | *(added 2026-08-24 — live columns, never documented.)* DZ-DR-029 federation provenance: brand slug whose load created/vetted the row, and the origin file |
| `created_at`, `updated_at` `timestamptz` | |

#### `entity_type` CHECK enum

Documented: `('condition','symptom','treatment','technology','specialty','anatomy','drug','procedure','concept','product','ingredient','device','organization','lab_test')`. The 10 extension types (ingredient/device/procedure/product/condition/**symptom**/drug/anatomy/organization/lab_test) bind to Group 9 detail tables (`symptom` → `seo_entity_symptom` §11.5a per **DR-036**, built 2026-06-04). The remaining enum values (`treatment`/`technology`/`specialty`/`concept`) bind to CPTs without a dedicated extension table.

⚠️ *(corrected 2026-08-24 against live schema)* **The live data contains a 15th value the list above does not: `person` (6 rows — Dr. Amornpong Vachiramon, Dr. Tomas Linkevicius, Dr. Pitchapa Phudphong, Dr. Woraphat Jarangkul, and two TH-named clinicians).** Either the CHECK admits `person` or no CHECK is installed; PostgREST cannot show the constraint body, so which one is true is unverified. Add `person` to any validation list before it rejects rows that already exist. Live value counts 2026-08-24: concept 154 · procedure 142 · condition 127 · treatment 119 · device 73 · organization 25 · anatomy 21 · symptom 21 · specialty 19 · technology 12 · drug 9 · person 6 · product 4 — `ingredient` and `lab_test` have **zero** rows.

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
> **DR:** Bible Part 7 SKOS pattern · **DR-046** (shared-table governance)
> **Volume:** ~10–50 per brand — **58 rows** total, measured 2026-08-24 (56 `brand_scope ['*']`, 1 vth-biodent, 1 smile-scape-clinic). *(corrected 2026-08-24 against live schema)*

> 🔴 **Rows with `brand_scope ['*']` are shared across the whole table, not owned by the brand that
> created them.** When two rows describe one topic, merge per DR-046 / PAMREL P15: the survivor is
> the row from the brand furthest ahead (`load_from`), **not** the row with more pages; the retired
> slug is preserved as `aliases.merged_from` on the survivor and its own row is set `status='merged'`,
> never deleted. Check the LOSING row for data the survivor lacks before retiring it — VTH 2026-08-03
> found the retired row held the only `descriptions` for the topic. `cluster_slug` is UNIQUE per
> brand, so nothing at the database level prevents two brands from naming the same topic differently.

#### Columns (29) *(corrected 2026-08-24 against live schema — was documented as 27; live adds `load_from` + `load_source`)*

| Column | Type | Notes |
|---|---|---|
| `id` `uuid` UNIQUE | |
| `fingerprint` `text` | `clst_{ULID16}` *(corrected 2026-08-24 against live data — live fingerprints read `clst_FDD80BDCE00946A0`, not `tcls_`)* |
| `fingerprint_display_name` `text` | |
| `cluster_slug` `text` | UNIQUE per brand |
| `cluster_name` `text` | Display name |
| `cluster_type` `text` | CHECK IN (`'topical'`,`'content_format'`,`'audience'`,`'section_meta'`). *(measured 2026-08-24: all 58 live rows are `'topical'` — the other three facets have never been populated, so any rule that reads a `content_format` / `audience` / `section_meta` cluster returns nothing.)* |
| `parent_cluster_fp` `text` | Self-FK for hierarchy |
| `hierarchy_level` `smallint` | 0=root, 1=child, etc. |
| `skos_concept_scheme` `text` | SKOS scheme URI |
| `canonical_names` `jsonb` | Multilingual `{th, en, ...}` |
| `aliases` `jsonb` | Multilingual aliases array per language |
| `descriptions` `jsonb` | Multilingual descriptions |
| `brand_scope` `text[]` | DR-010 |
| `brand_scope_primary` `text` | Single primary brand (denorm) |
| `cluster_facet` `text` | Subcategory within cluster_type |
| `cluster_health_score` `numeric` | **0–10**; computed nightly via cron · live range 0.0–8.19, mean 5.17 *(corrected 2026-08-24 — a "warn below 60" alert on a 0–10 column fires on every cluster forever)* |
| `cluster_topical_authority` `numeric` | **0–10** · live range 0.0–6.76, mean 4.20 *(corrected 2026-08-24 — a target of ≥60 is unreachable by construction)* |
| `cluster_health_breakdown` `jsonb` | Score factors |
| `cluster_health_formula_version` `text` | E.g. `'v1.0'` |
| `cluster_health_computed_at` `timestamptz` | |
| `status` `text` | *(corrected 2026-08-24 against live data)* live values are `'active'` (46), `'merged'` (7), `'deprecated'` (5). `'draft'` and `'archived'` appear nowhere; `'merged'` is the DR-046 survivor-merge state described in the box above and was missing from this list. |
| `notion_id` `text`, `parent_notion_id` `text`, `notion_synced_at`, `sync_state` | N↔S sync (Two-Phase per DR-006) |
| `load_from` `text`, `load_source` `text` | *(added 2026-08-24 — live columns, never documented.)* DZ-DR-029 federation provenance |
| `created_at`, `updated_at` | |

---

### 4.3 `seo_citations`

> **Purpose:** Academic citation pool (PubMed/DOI/clinical guidelines/government sources). 6-tier hierarchy per Bible Part 23.1.
> **Sync:** N↔S (Notion `Citations Pool` — created 2026-05-30)
> **Distinct from:** `seo_directory_listings` (Local SEO NAP citations)
> **Volume:** **551 rows**, measured 2026-08-24 — ONE pool shared by all three brands (`brand_scope`: 466 `['*']`, 62 vth-biodent, 23 smile-scape-clinic), not ~50–500 *per brand*. *(corrected 2026-08-24 against live schema)*

#### Columns (41) *(corrected 2026-08-24 against live schema — was documented as 38; live adds `load_from`, `load_source` and `maintenance_log`)*

**Identity & lineage:**
- `id uuid`, `fingerprint text` (`cite_{ULID16}`), `fingerprint_display_name text`, `citation_slug text`

**Bibliographic (12):**
- `title text`, `authors text[]`, `publication_year smallint`
- `pubmed_pmid text`, `doi text`, `isbn text`, `url text`, `archive_url text`
- `journal_name text`, `publisher_name text`
- `source_org_fp text` (FK → seo_entity_organization)
- `publication_date date`

**Classification (4):**
- `citation_tier smallint` (1–6) — *(corrected 2026-08-24 against live schema)* **the `COMMENT ON COLUMN` in the database is the authoritative scale**, and it is not "1=meta-analysis … 6=expert opinion". The tier reflects **study design**, never journal quality or author standing; use `citation_authority_weight` for quality weighting. This is the scale gate G5 (`check:citations`) enforces in every brand's CI — a mistiered row stops the other brands' deploys too:
  - **1** = `systematic_review` · `meta_analysis` · `systematic_review_and_meta_analysis` · `cochrane_review`
  - **2** = `rct` · `randomized_controlled_trial` · `cohort_study`
  - **3** = `clinical_guideline` · `consensus_guideline` · `clinical_practice_guideline`
  - **4** = `law` · `regulation` · `regulatory_document` · `report` · `fact_sheet` · `survey_report` · `genetic_association`
  - **5** = `cross_sectional` · `in_vitro` · `retrospective_cohort` · `prospective_cohort` · `case_series` · `clinical_study` · `pilot_study`
  - **6** = `narrative_review` · `textbook` · `manufacturer_document` · `expert_opinion` · `consensus_statement`

  Undecided: `scoping_review` (**3** rows live, tiered 1, 5 and 6 — the database comment's "2 rows, tiered 5 and 6" was measured 2026-08-18 and a third row has since landed) and `other` (spread across 1/3/5/6 — live 1=16, 3=10, 5=9, 6=10). Evidence limitations — a meta-analysis of animal studies, say — go in `key_findings`; never push the tier down instead. Live distribution 2026-08-24: tier 1 = 288 · 2 = 38 · 3 = 50 · 4 = 16 · 5 = 57 · 6 = 102.
- `citation_type text` — *(corrected 2026-08-24 against live data — the old list was mostly values that do not occur.)* live values: `meta_analysis` (170), `systematic_review` (116), `expert_opinion` (80), `clinical_guideline` (49), `cohort_study` (40), `rct` (37), `other` (25), `regulatory_document` (14), `cross_sectional` (7), `case_series` (4), `industry_publication` (4), `textbook` (3), `case_control` (1), `case_report` (1)
- `study_type text` — drives `citation_tier` (see the scale above). **33** distinct live values *(re-measured 2026-08-24 — an earlier reading said 34 because it counted NULL as a value)*; the largest are `systematic_review` (121), `meta_analysis` (117), `narrative_review` (52), `other` (45, = *not yet classified*, not a real category), `rct` (20), `clinical_guideline` (19); 82 rows NULL. *(corrected 2026-08-24 against live data — `'cohort'` and `'animal'` are not live values; the live spellings are `retrospective_cohort` / `prospective_cohort` and `in_vitro`.)*
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
- `verification_status text` — CHECK `chk_verification_status` IN (`'unverified'`,`'verified'`,`'broken_link'`,`'paywalled'`,`'retracted'`). *(corrected 2026-08-24 against live schema — `'pending'` and `'broken'` are not values; the live spelling is `broken_link`, and `paywalled`/`retracted` were missing. Live distribution: verified 522, unverified 26, broken_link 3.)* `verified` means a human checked the PMID/DOI/title against the source record — never mark it on someone else's behalf.

**Notion sync (3):**
- `notion_id text`, `notion_synced_at`, `sync_state`

**Provenance & maintenance (3):** *(added 2026-08-24 — live columns, never documented.)*
- `load_from text`, `load_source text` — DZ-DR-029 federation provenance
- `maintenance_log text` — split out of `abstract` on 2026-08-17 (Wave 16as) because log text was being read as abstract text. Tags in live use: `PMID-VERIFY`, `FRESHNESS`, `PURGE` and five others.

**Standard (2):** `created_at`, `updated_at`

---

### 4.4 `seo_page_citations`

> **Purpose:** Junction table page ↔ citation. A page may cite the same source for different purposes (claim backing vs methodology vs counter-evidence).
> **Sync:** **S only** (no notion_id — built as S-only M:N junction)
> **Volume:** ~5–20 citations per page — **6,626 rows**, measured 2026-08-24.

#### Columns (15) *(count right, names largely wrong — corrected 2026-08-24 against live schema)*

🔴 **This table has NO `fingerprint` / `fingerprint_display_name`** — it is the one table in Appendix B's fingerprint registry that never got DR-008 two-column identity. A `pcit_` prefix does not exist. Join on `(page_fp, citation_fp)`.

- `id uuid`
- `page_fp text` → `seo_website_page_master.page_fingerprint` (the `vth-4.4.4`-style key, **not** `fingerprint`)
- `citation_fp text` → `seo_citations.fingerprint`
- `citation_purpose text`
- `citation_anchor_text text` — visible text near the citation marker on the page
- `section_context text` *(live name; the doc said `citation_position`)*
- `inline_position text` *(live column, never documented)*
- `supports_claim text` — short paraphrase of what the citation backs *(live name; the doc said `claim_being_backed`)*
- `evidence_strength_score` *(live name; the doc said `evidence_strength`)*
- `status text` *(live column, never documented)*
- `added_by_fp text`, `reviewed_by_fp text`, `reviewed_at timestamptz` *(live columns, never documented)*
- `created_at`, `updated_at`

**Not live:** `is_primary` and `notes` do not exist. The `citation_purpose` CHECK list previously given here (`primary_claim_backing` / `supporting_evidence` / `counter_evidence` / `methodology` / `background` / `further_reading`) could not be re-verified — PostgREST does not expose CHECK bodies — so it is left as written; confirm against `pg_constraint` before relying on it.

> ⚠️ A row here does not prove the page cites the source. Binding rows and rendered YAML references are two different surfaces — see `check:citation-usage`.

---

### 4.5 `seo_entity_relationships`

> **Purpose:** Typed edge junction over `seo_entity_graph`. Models 12-edge vocabulary (DR-013 v3.5) including medical edges (`treats`, `causes`, `caused_by`, `contraindicates`) with evidence FK + medical signoff requirements.
> **Sync:** N↔S (Notion `Entity Relationships` — created 2026-05-30)
> **DR:** DR-013 (Edge Vocab v3.5 Locked v1.13)
> **Volume:** **1,089 edges** total, measured 2026-08-24 (`brand_scope`: 669 vth-biodent, 339 `['*']`, 73 smile-scape-clinic, 8 deezy-dental). `status`: 1,077 `active`, 12 `flagged_review`. *(corrected 2026-08-24 against live schema — `'draft'`, `'pending_signoff'` and `'deprecated'` do not occur; `'flagged_review'` was missing from the documented list.)*

#### Columns (21) *(corrected 2026-08-24 against live schema — was documented as 19; live adds `load_from` + `load_source`)*

| Column | Type | Notes |
|---|---|---|
| `id uuid` UNIQUE | |
| `fingerprint text` | `erel_{ULID16}` *(corrected 2026-08-24 against live data — live fingerprints read `erel_27CFB90655A84B87`, not `edge_`)* |
| `fingerprint_display_name text` | |
| `from_entity_fp text` | FK → `seo_entity_graph.entity_fingerprint` (the entity slug). *(corrected 2026-08-24 against live data — 1,089 of 1,089 edges resolve there, zero on `fingerprint`; see §4.1.)* |
| `to_entity_fp text` | FK → `seo_entity_graph.entity_fingerprint` — same key as `from_entity_fp`. |
| `edge_type text` | DR-013 vocab — see below |
| `edge_note text` | Free-form context |
| `edge_strength smallint` | 1–5 operator scored |
| `edge_evidence_score numeric` | 0.0–1.0, computed from linked citations |
| `edge_evidence_citation text` | FK → seo_citations.fingerprint (required for `causes`, `treats`, `contraindicates` edges per `trg_validate_edge_evidence`) |
| `medical_reviewer_signoff_at timestamptz` | Required for `contraindicates` edges per `trg_validate_medical_signoff` |
| `medical_reviewer_fp text` | FK → seo_authors_reviewers.fingerprint |
| `brand_scope text[]` | |
| `status text` | live values only: `'active'`, `'flagged_review'` *(corrected 2026-08-24 against live data)* |
| `notion_id text`, `notion_synced_at`, `sync_state` | N↔S |
| `load_from text`, `load_source text` | *(added 2026-08-24 — live columns, never documented.)* DZ-DR-029 federation provenance |
| `created_at`, `updated_at` | |

#### DR-013 Edge Vocabulary (12 edge types) + live counts *(corrected 2026-08-24 against live data)*

| Edge type | Description | Evidence required? | Medical signoff? | Live rows 2026-08-24 |
|---|---|---|---|---|
| `child_of` | Hierarchical parent (replaces legacy `parent_entity_fp`) | No | No | **0** |
| `part_of` | Mereological — anatomy components | No | No | 51 |
| `related_to` | Generic association | No | No | 427 |
| `treats` | A treats B (treatment → condition) | **Yes (citation)** | No | 166 |
| `treated_by` | Inverse of treats | **Yes** | No | **0** |
| `causes` | A causes B (etiology) | **Yes** | No | 6 |
| `caused_by` | Inverse of causes | **Yes** | No | 5 |
| `contraindicates` | A contraindicates B (safety-critical) | **Yes** | **Yes (MD signoff)** | 21 |
| `symptom_of` | A is a symptom of B | **Yes** | No | 54 |
| `diagnoses` | A (test/procedure) diagnoses B (condition) | **Yes** | No | **0** |
| `prevents` | A prevents B | **Yes** | No | **0** |
| `risk_factor_for` | A is a risk factor for B | **Yes** | No | **0** |
| `broader_than` 🔴 | **not in the DR-013 vocabulary but live** | — | — | 271 |
| `requires` 🔴 | **not in the DR-013 vocabulary but live** | — | — | 58 |
| `is_a` 🔴 | **not in the DR-013 vocabulary but live** | — | — | 30 |

🔴 *(added 2026-08-24 against live data)* Three edge types outside the locked vocabulary hold **359 of 1,089 edges** — `broader_than` alone is the second-largest edge type in the graph. Either the CHECK admits them or none is installed. Any consumer that switches on the 12-value list silently drops a third of the graph; `broader_than` and `is_a` look like the hierarchy `child_of` was supposed to carry (which has zero rows).

#### Triggers

- `trg_set_fingerprint` BEFORE INSERT — generic
- `trg_prevent_fingerprint_change` BEFORE UPDATE
- `trg_validate_edge_evidence` BEFORE INSERT/UPDATE → `fn_validate_edge_evidence_requirement()` — for `causes`/`treats`/`contraindicates`/etc., raises if `edge_evidence_citation` is NULL
- `trg_validate_medical_signoff` BEFORE INSERT/UPDATE → `fn_validate_medical_signoff_for_contraindication()` — for `contraindicates`, raises if `medical_reviewer_signoff_at` is NULL

> 🔴 **Neither validation trigger is protecting the live data** *(measured 2026-08-24)*. Rows that the two rules say cannot exist do exist: `edge_evidence_citation` is NULL on **all 166 `treats`**, all 6 `causes`, all 5 `caused_by` and all 54 `symptom_of` edges, and `medical_reviewer_signoff_at` is NULL on **all 21 `contraindicates`** edges. Whether the triggers were dropped, disabled during a bulk load, or never installed cannot be seen through PostgREST — but do not rely on the database to refuse a bad edge. Treat both requirements as ETL-side gates and verify with:
> `select edge_type, count(*) filter (where edge_evidence_citation is null) from seo_entity_relationships group by 1`.

---

## 5. Group 3 — Page System (3 tables)

> The page master + per-page editorial workflow + page↔page internal linking junction. Widest table outside the telemetry partitions (`seo_website_page_master` at **93 columns**; the daily-logs partitions carry 125). *(corrected 2026-08-24 against live schema — was "largest single table … at 88 columns")*

### 5.1 `seo_website_page_master`

> **Purpose:** Canonical URL/page master. Every page that EYWA tracks (planning → published → live) gets one row.
> **Sync:** N↔S (Notion `🌐 Website & SEO Page Intelligent Master`)
> **DR:** DR-008 (identity), DR-015 (marketplace reconciliation), DR-016 (viability assessment / thin page risk), DR-017 (content brief field), DR-021 (internal linking HYBRID), DR-026 (Ads LP Phase 0), DR-030 (compliance tiers), DR-032 (center_slug), DR-034 (PAA × FAQ intent routing)
> **Volume:** 100s–10,000s per brand.
> **Current data:** **2,358 rows** across three brands, measured 2026-08-24 — deezy-dental 869, vth-biodent 761, smile-scape-clinic 728. `status`: Planned 1,513 · Live 742 · Merged 102 · Dropped 1. *(corrected 2026-08-24 against live schema — was "1,376 rows (VitalSleep and Wellness only)"; VitalSleep has no rows in this table. This is a SHARED table: every query must filter on `brand_id`.)*

#### Columns (93 — canonical full list grouped by domain) *(corrected 2026-08-24 against live schema — was documented as 90; `page_category`, `page_role` and `content_format_name` were live but undocumented, and are added below)*

**Identity (5):**
- `id` `uuid` PK DEFAULT `gen_random_uuid()`
- `page_fingerprint` `text` NOT NULL — **the real join key**, format `{brand_prefix}-{sitemap_node_id}` (`vth-5.3.1`). *(corrected 2026-08-24 against live schema — this is not merely "legacy, preserved for n8n compat": since 2026-08-16 seven real FKs target it — `seo_page_citations`, `seo_editorial_reviews`, `seo_page_internal_links` (from/to), `parent_page_fp` self-FK, `seo_x_ads_keywords_contextual_master.ad_landing_page_fp`, `seo_x_voice_search.optimized_for_page_fp` — all ON UPDATE CASCADE.)*
- `fingerprint` `text` NOT NULL — DR-008 canonical `page_{16HEX}` (CHECK `^page_[0-9A-F]{16}$`). Audit identity only — **never join on it**: no satellite table stores this form.
- `fingerprint_display_name` `text` NOT NULL — `{fp_last_6}::{slug}` *(corrected 2026-08-24 against live data — live values read `A943E6::myofunction-tmj`; there is no `brand_slug` segment)*
- `notion_id` `text` — Notion mirror

**Brand & taxonomy (5):**
- `brand_id` `text` — **the brand SLUG**, live values `deezy-dental` / `vth-biodent` / `smile-scape-clinic`. *(corrected 2026-08-24 against live data — this doc's "stores `brands.id` UUID as text" is wrong and the live column comment calls it out by name.)*
- `brand_name` `text` (denormalized)
- `cluster_id` `text` (FK soft → seo_topic_cluster_master.cluster_slug; DR-047: must equal the primary entity's `topic_cluster_id` unless a reason is written in `reconciliation_notes`)
- `sitemap_node_id` `text` — dotted path in the page tree (`5.3.9`); its leading segment is what the citation minimum keys on. No UNIQUE constraint, but zero duplicates exist and tree-building code depends on that.
- `sitemap_section` `text` — **site zone as a NUMBER, `'1'`..`'9'`**, for all three brands (deezy-dental's slug form was migrated 2026-08-23). *(corrected 2026-08-24 against live schema — "operator-defined section grouping" understated it. Live distribution: 3=658, 6=617, 5=444, 8=196, 7=135, 9=126, 4=115, 2=62, 1=5; no NULLs.)* This is a ZONE, never a substitute for `page_category` when the rule asks what a page **is** — section 5 on smile-scape-clinic holds 91 `condition_pillar` rows plus 80 `service_page` and five other kinds.

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

**Page taxonomy (7):** *(corrected 2026-08-24 against live schema — was 5; `page_category` and `page_role` are live columns this listing never had; the third undocumented column, `content_format_name`, is listed under Hierarchy below)*
- `page_type` `text` — 🔴 **DEPRECATED 2026-08-20** because it carried two axes at once (semantic kind + hub/leaf role), which made cross-column validation impossible. Split into `page_category` + `page_role`. **DO NOT DROP YET**: the Bible §3.2 layer mapping resolves through `coalesce(page_category, page_type)` and `page_category` is not yet complete on any brand. Live values (2,358 rows): knowledge_article 608 · service_page 544 · condition_pillar 263 · supporting 218 · technology_page 143 · evidence_case 131 · branch_landing 110 · local_programmatic 99 · procedure_pillar 77 · pillar 62 · about 45 · local_landing 21 · doctor_profile 16 · local_service_page 6 · home 5 · contact 5 · local_service 4 · popup 1. *(corrected 2026-08-24 — the documented value list omitted `local_programmatic`, `local_service_page`, `local_service` and `popup`.)*
- `page_category` `text` 🆕 *(added 2026-08-24 — live column, never documented)* — **SEMANTIC PAGE KIND**, the replacement for the category half of `page_type`. Controlled values: `home`, `about`, `contact`, `condition_pillar`, `procedure_pillar`, `service_page`, `technology_page`, `knowledge_article`, `evidence_case`, `doctor_profile`, `branch_landing`, `local_landing` — plus `local_programmatic` and `local_service_page`, which occur in the data. Mostly determined by `content_format` but not a function of it. Backfilled on **all three brands** as of 2026-08-24: vth-biodent 686/761, deezy-dental 776/869, smile-scape-clinic 707/728 (189 NULL overall).
- `page_role` `text` 🆕 *(added 2026-08-24 — live column, never documented)* — **STRUCTURAL ROLE**: `hub` (has ≥1 non-Merged child via `parent_page_fp`) or `leaf`. **DERIVED — never hand-set**; recomputed by `content-plan/etl/derive-page-role-category.py`, and `check:plan` fails when a stored value disagrees with the tree. Live: leaf 1,972 · hub 197 · NULL 189 *(re-measured 2026-08-24; an earlier reading the same day said 1,969/197/192 — the derive script had not finished the last three deezy rows)*.
- `page_intent_type` `text` — search intent. Live values: informational 1,284 · commercial 514 · transactional 420 · navigational 65 · NULL 75.
- `node_tier` `text` — **TIER only**: `A`/`B`/`C`/`D` (crawl-depth allowance, Bible Part 3.4). The page's importance tier — NOT its category. Live: C 1,416 · D 530 · B 319 · A 87 · NULL 6.
- `node_tier_strategy` `text` CHECK IN (`'hub'`,`'spoke'`,`'pillar'`,`'supporting'`,`'leaf'`) — structural hub/leaf role (distinct from `page_type` and `node_tier`). Live: spoke 1,588 · supporting 229 · pillar 199 · leaf 195 · hub 45 · NULL 102.
- `funnel_stage` `text` — `'awareness'`, `'consideration'`, `'decision'`, `'retention'` (DR-057, 2026-08-23; `top`/`mid`/`bottom` are RETIRED — pre-migration values are kept in `_funnel_stage_bak_20260823`). *(confirmed 2026-08-24 against live data: consideration 1,066 · awareness 682 · decision 560 · retention 45 · NULL 5. No CHECK constraint is installed yet.)*

> **⚠️ Column-semantics clarification (2026-07-09, SmileScape backfill).** `page_type` (category), `node_tier` (A/B/C/D tier), and `node_tier_strategy` (hub/leaf role) are **three independent axes** — do not conflate. ~~**Known data bug:** VTH BioDent rows currently store the tier letters `A/B/C/D` in `page_type`~~ — **fixed; do not go looking for it.** *(corrected 2026-08-24 against live data — zero rows in any brand hold `A`/`B`/`C`/`D` in `page_type`; all 18 live values are semantic categories. The axis-splitting work went further and produced `page_category` + `page_role`, see above.)* These semantics are now also documented as live `COMMENT ON COLUMN` on `seo_website_page_master` in GTGT so any brand inspecting the DB sees them. SmileScape derives `page_type` deterministically from `primary_entity` entity_type + `sitemap_section` + hub/leaf role (no keyword research needed). The sitemap markdown's own "Page Type" column (mostly `A`) is a legacy placeholder and must NOT be copied into this field.

**Authority & link strategy (DR-021, 11):** *(subtotal corrected 2026-08-24 — the label said 7; eleven columns are listed and all eleven are live)*
- `priority` `text` — **XML sitemap `<priority>` as text** (`'0.4'`..`'1.0'`). Not the same thing as `link_priority` or `authority_weight`. *(corrected 2026-08-24 against live schema — "operator-set priority label" was too vague to be checkable. Live: 0.6=1,176 · 0.4=569 · 0.8=301 · 0.5=100 · 0.9=89 · 0.7=18 · 1.0=16 · NULL=89.)*
- `link_role` `text` — live values `'primary_hub'`, `'cluster_spoke'`, `'supporting'`, `'reference'`. *(corrected 2026-08-24 against live data — `structural`/`authority`/`contextual`/`conversion` occur in zero rows. Consumed by `gen-internal-links`. Live: cluster_spoke 1,180 · supporting 230 · primary_hub 101 · reference 2 · NULL 845.)*
- `link_priority` `text` — weighting bucket 1–10 stored as text. Cannot express a long reading order; use group-level priority plus `seo_page_internal_links.section_context` for intra-group order.
- `anchor_strategy_mode` `text` — anchor text variation strategy. Live values: `topical_diverse` (1,536), `partial_diverse` (371), `generic_mixed` (148), `branded_navigational` (97), NULL (206). *(added 2026-08-24 against live data — the column had no value list.)*
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
- `primary_entity_fp` `text` → **`seo_entity_graph.entity_fingerprint`** (the slug-shaped key), not `.fingerprint` *(corrected 2026-08-24 against live schema)*
- `related_entities_fps` `text[]`
- `target_keyword_fp` `text` (FK → seo_x_ads_keywords_contextual_master)
- `semantic_keywords_fps` `text[]`
- `planned_outbound_fps` `text[]` (intended outbound internal links — FK → page_master fingerprints)
- `planned_outbound_external_links` `text` — free-form external URL list
- `cross_brand_links_fps` `text[]`

**Schema markup (1 + linked):**
- `schema_markup_type` `text` — **a bare scalar Schema.org type**, one per row, e.g. `'MedicalWebPage'` (493), `'MedicalProcedure'` (431), `'MedicalCondition'` (269), `'Article'` (241), `'Service'` (179), `'MedicalDevice'` (167) — **26** distinct types live plus 1 NULL row. *(count re-measured 2026-08-24 — an earlier reading said 27 because it counted NULL as a value.)* Drives JSON-LD generation. *(corrected 2026-08-24 against live data — the brace-set form `{MedicalCondition,MedicalWebPage}` is **retired**: zero rows in any of the three brands hold one. The live `COMMENT ON COLUMN` still tells readers to "parse defensively" for brace sets; that comment is stale, the data is clean. Distinct from `page_type`/`page_category`: those pick the template, this describes the markup.)*
- (Schema markup planned/emitted details live in editorial_reviews + page templates)

**Multilingual (DR-009, 5):**
- `page_language` `text` — `'th'`, `'en'`, `'zh'`, `'ar'`, `'fr'`, ...
- `translation_status` `text` — DR-009 workflow state. *(corrected 2026-08-24 against live data — only `'pending'` (1,415) and `'published'` (108) occur, plus 835 NULL. `'in_progress'`, `'approved'` and `'live'` are in no row; `'published'` was missing from this list.)*
- `translation_due_date` `timestamptz`
- `translations_versions_fps` `text[]` — FK to other-language versions of same content
- `source_translation_fp` `text` — FK to source-language version

**Hierarchy (3):**
- `parent_page_fp` `text` → `seo_website_page_master(page_fingerprint)` self-FK · ON UPDATE CASCADE · **ON DELETE SET NULL deliberately — never change to CASCADE**, or deleting one hub deletes its whole branch
- `content_format` `text` — **a template code, PER BRAND**: `T1`, `T2`, `T2b`, `T4`, `T5`, `T6`, `T6a`, `T18`… **22** distinct codes live (T6=605, T5=397, T1=270, T4=158, T2b=151, T18=130, T8=124, T10=111, T12=91, …) plus 21 NULL rows. *(count re-measured 2026-08-24 — an earlier reading said 23 because it counted NULL as a code.)* *(corrected 2026-08-24 against live schema — `'long_form_article'` / `'comparison_table'` / `'video_centric'` occur in zero rows and were never the vocabulary.)* **Operator ruling 2026-08-23:** brands design their own templates, so the vocabularies may legitimately differ and diverge completely — deezy uses `T2b` where vth and smile-scape use `T2`, and that is allowed. What is not allowed is a code with no definition. **Validation is per-brand registry membership, never a global T-code list**, and any code→category map must be keyed by brand as well as code.
- `content_format_name` `text` 🆕 *(added 2026-08-24 — live column, never documented)* — human-readable name for the `content_format` code (web template key + descriptive name, per `web/src/lib/template-keys.ts`). Denormalized companion to `content_format`, like `primary_entity_name`. DZ-DR-034. 32 distinct live values, 752 NULL.

**Word count targets (3):**
- `auto_suggested_word_count_target` `numeric` — a target for writers, **not a gate**. *(added 2026-08-24: there is no measured word-count column on this table. The only measured one in the schema is `seo_x_ads_keywords_x_url_daily_logs.plain_text_word_count`, which is NULL in all 151,471 rows — so a word-count floor has nothing to compare a target against today. Do not document a `word_count` column here; there is none.)*
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
- `marketplace_proposal_status` `text` 🆕 v1.16 (DR-015) CHECK IN (`'proposed'`,`'approved'`,`'rejected'`,`'repackaged'`,`'deferred'`) — multi-brand marketplace reconciliation. *(measured 2026-08-24: **NULL in all 2,358 rows** — DR-015 marketplace reconciliation has never been recorded here.)*
- `reconciliation_notes` `text` — DR-015 operator notes. **Append-only log**, entries separated by `" | "`; gates read it for `INTENT` and `CITATION EXEMPTION` markers. Overwriting it deletes those silently.
- `flag_review` `text` — operator review flag
- `snapshot_version` `text` — planning snapshot identifier

**Status & lifecycle (5):** *(subtotal corrected 2026-08-24 — the label said 4; five columns are listed and all five are live)*
- `status` `text` — page lifecycle. CHECK `chk_page_status`: **`Planned` | `Live` | `Merged` | `Dropped`** (NULL allowed). *(corrected 2026-08-24 against live schema — `'planning'`/`'draft'`/`'in_review'`/`'published'`/`'archived'` are in no row and the constraint rejects them; the live column comment names this document as the stale source. `Merged` = folded into another page, row kept for provenance. **Every script reading this table must exclude `Merged` and `Dropped` explicitly** — filtering on the string `'deprecated'` matches nothing.)*
- `published_date` `timestamptz`
- `hreflang_validated` `boolean` DEFAULT false
- `has_medical_review` `boolean` DEFAULT false — **operator ruling 2026-08-23: a page the operator approves and sets `Live` IS medically reviewed.** `Live` implies true; set it and emit the reviewer into schema markup. This is **not** gated on rows in `seo_editorial_reviews`. Non-Live rows may carry true harmlessly, since schema only ships when the page is Live. *(added 2026-08-24 against the live column comment; live: 2,057 true / 301 false.)*
- `review_cycle` `text` — review cadence. Live values: `annual` (1,943), `semiannual` (362), `quarterly` (26), `post_live_6m` (8), `monthly` (8), NULL (11). *(corrected 2026-08-24 against live data — `semiannual` and `post_live_6m` were missing from the list.)*

**Ads LP track (DR-026, 6):** 🌱 v1.12 — 🔴 **DORMANT** *(measured 2026-08-24)*: `ads_template_id` is NULL in all 2,358 page rows and `ad_active` is false on all 22,710 keyword rows (§6.1). The columns exist and are correct; no ad landing page has ever been recorded through them.
- `page_purpose` `text` NOT NULL DEFAULT `'seo_organic'` CHECK IN (`'seo_organic'`,`'ads_landing'`,`'hybrid'`,`'utility'`,`'legal'`,`'thank_you'`) — *(live 2026-08-24: only `seo_organic` (2,276) and `utility` (82) occur.)*
- `ads_template_id` `text` (CHECK regex `^T-ADS-[1-5]$` OR `^T-DUAL-[0-9]+$`) — *(live 2026-08-24: NULL in all 2,358 rows.)*
- `index_directive` `text` NOT NULL DEFAULT `'index'` CHECK IN (`'index'`,`'noindex'`,`'index_no_follow'`,`'noindex_no_follow'`) — *(live 2026-08-24: index 2,321, noindex 37.)* This is the constrained field; `robots_directive` is the raw legacy string and loses when they disagree.
- `conversion_event_primary` `text` — *(corrected 2026-08-24 against live data: only `'line_follow'` (2,224) and `'call_click'` (36) occur, 98 NULL. `lead_form`/`booking`/`download`/`package_view`/`add_to_cart` are in no row, and the live column comment names a different set again (`form_submit`, `phone_click`, `line_click`, `schedule`, `purchase`) — three vocabularies for one column. The CHECK body is not readable through PostgREST; confirm before validating against any of them.)*
- `conversion_event_secondary` `text[]` (max 3 elements)
- `campaign_id` `text` — Phase 0 stub; becomes `campaign_fp` FK when DR-027 locks. *(confirmed 2026-08-24: `seo_campaigns` still does not exist.)*

**Sensitive Topic Compliance (DR-030, 6):** 🆕 v1.17
- `product_regulatory_tier` `smallint` CHECK 1..4 — DR-030 §1 (1=Basic / 2=Functional / 3=Medical-Adjacent / 4=Quasi-Restricted)
- `content_topic_tier` `smallint` CHECK 1..4 — DR-030 §1 (1=General Lifestyle / 2=Specific Outcome / 3=YMYL-High / 4=Legal-Sensitive)
- `sensitive_topic_flag` `text` CHECK IN (`'none'`,`'low'`,`'medium'`,`'high'`,`'critical'`) — aggregated for editorial routing
- `target_audience_segment` `text[]` — e.g. `{recovery, postpartum, mental-health-clinical}`
- `legal_review_required` `boolean` NOT NULL DEFAULT false — triggers `legal_compliance` editorial review row
- `compliance_max_tier` `smallint` **GENERATED ALWAYS AS** `GREATEST(product_regulatory_tier, content_topic_tier)` **STORED** — drives reviewer tier auto-routing

**Multi-Center (DR-032, 1):** 🆕 v1.18 — 🔴 **DORMANT**: NULL in all 2,358 rows, because no brand is `multi_center` (§3.8). *(measured 2026-08-24)*
- `center_slug` `text` — NULL = umbrella/hospital-wide page (Home/About/Method/Membership). Non-NULL = page belongs to a center (URL: `/{lang}/{url_segment}/{slug}/`). Validated by `trg_validate_page_center_slug`: must be NULL when `brand.brand_structure='monolithic'`; must match a `seo_brand_centers.center_slug` row when `multi_center`.

**Intra-Page Routing (DR-034, 2):** 🆕 v1.20
- `intent_source_tier` `text` NOT NULL DEFAULT `'template_only'` CHECK IN (`'paa'`,`'derived'`,`'template_only'`,**`'brand'`**) — source of the page's on-page intent coverage: `paa` = real PAA (`seo_x_ads_keyword_serp_competitors.people_also_ask_json` — *corrected 2026-08-24: that table has no `paa_questions` column; the live column comment on `intent_source_tier` repeats the wrong name*), `derived` = `keyword_painpoint` / `predicted_serp_features` / voice signals, `template_only` = 8-intent baseline, **`brand` = brand-supplied intent**. *(corrected 2026-08-24 against live data — a fourth value `brand` is in use and was undocumented. Live: template_only 2,259 · brand 88 · derived 11 · **`paa` = 0 rows, never once written** — so the PAA branch of Content_Templates §4.5.4 has never routed anything.)* Drives Content_Templates §4.5.4 routing + tiered FAQ floor.
- `paa_checked_at` `timestamptz` — last PAA crawl time. NULL = never crawled (→ trigger crawl, **not** tier-3). SET + empty `people_also_ask_json` = checked, genuinely no PAA → tier-2/3. *(column name corrected 2026-08-24 — see §6.3.)*

**Sync (2):** *(subtotal corrected 2026-08-24 — `sync_state` is **not** a column on this table, so the group holds two, not three)*
- `notion_id text` (also counted under Identity above), `notion_synced_at timestamptz` — page_master has no `sync_state` column

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
| `seo_website_page_master_intent_source_tier_check` 🆕 v1.20 | `intent_source_tier IN ('paa','derived','template_only','brand')` *(corrected 2026-08-24 — `brand` is live on 88 rows)* |
| `chk_page_status` *(added 2026-08-24 — live constraint, never documented)* | `status IS NULL OR status IN ('Planned','Live','Merged','Dropped')` |
| `chk_page_master_page_fingerprint` etc. | ⚠️ *(2026-08-24)* CHECK **bodies are not exposed by PostgREST** — every definition in this table is carried over from the 2026-05-30 audit and re-verified only where live data contradicted it. Re-read from `pg_constraint` before treating any row here as current. |

#### Triggers

- `trg_set_fingerprint_page_master` BEFORE INSERT → `fn_set_fingerprint_page_master()` — `page_{16HEX}` generator
- `trg_refresh_display_name_page_master` BEFORE UPDATE → refresh display_name when slug or brand_slug changes
- `trg_prevent_fingerprint_change_page_master` BEFORE UPDATE OF fingerprint — DR-008
- `trg_validate_page_center_slug` BEFORE INSERT/UPDATE OF center_slug → `fn_validate_page_center_slug()` (DR-032) — enforces monolithic→NULL rule and multi_center→exists rule

#### DR-030 Editorial Review Auto-routing

When `compliance_max_tier >= 3`, n8n flow auto-creates a pending `seo_editorial_reviews` row with `review_type='medical'`.
When `content_topic_tier=4 OR product_regulatory_tier=4`, also auto-creates `review_type='legal_compliance'`.
Page cannot move to `status='Live'` until all required review rows have `approved=true`. (Enforced at app/n8n layer; database-layer trigger deferred to v1.19+.) *(corrected 2026-08-24 — the terminal status is `Live`; `'published'` is not a value `chk_page_status` accepts, so this rule as previously written could never fire. Note also that `has_medical_review` is **not** derived from these rows — see §5.1: the operator setting a page Live is the medical review.)*

🔴 *(added 2026-08-24 against live data)* **The `legal_compliance` branch has never run.** `seo_editorial_reviews` holds 2,095 rows of exactly two types — `medical` (2,022) and `editorial` (73). No `legal_compliance`, `fact_check`, `legal`, `seo`, `translation` or `final_approval` row exists.

---

### 5.2 `seo_editorial_reviews`

> **Purpose:** Per-page editorial workflow rows. Multiple review types per page (medical, editorial, fact_check, legal, seo, translation, final_approval, legal_compliance).
> **Sync:** N↔S (Notion `Editorial Reviews` — created 2026-05-30)
> **DR:** Bible Part 23.4 (editorial review workflow), DR-030 (legal_compliance type added)
> **Volume:** 1–8 rows per page — **2,095 rows**, measured 2026-08-24. `review_status`: pending 1,636 · approved 459. `review_stage`: pre_publication 1,317 · plan_cleared 724 · post_publication 54. *(corrected 2026-08-24 against live schema)*

#### Columns (22 — full live snapshot) *(corrected 2026-08-24 against live schema — was documented as 21; the table's own listing already ran to 22 columns)*

| Column | Type | Notes |
|---|---|---|
| `id uuid` UNIQUE | |
| `fingerprint text` | `edrv_{ULID16}` *(corrected 2026-08-24 against live data — live fingerprints read `edrv_25C411303ED44224`, not `erev_`)* |
| `fingerprint_display_name text` | |
| `page_fp text` | FK → `seo_website_page_master.page_fingerprint` — the `deezy-1` / `vth-4.4.4` form. *(corrected 2026-08-24 against live data — all 2,095 rows resolve on `page_fingerprint` and **zero** on `fingerprint`; §5.1 lists this as one of the seven FKs targeting it.)* |
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

- `chk_er_review_type` CHECK IN **(`'medical'`, `'editorial'`, `'fact_check'`, `'legal'`, `'seo'`, `'translation'`, `'final_approval'`, `'legal_compliance'`)** 🆕 v1.17 — `legal_compliance` added by DR-030. *(2026-08-24: only `medical` and `editorial` are used; the other six have zero rows. CHECK body unverifiable through PostgREST.)*
- `chk_er_review_status` CHECK IN (`'pending'`, `'in_progress'`, `'changes_requested'`, `'approved'`, `'rejected'`, `'skipped'`) *(2026-08-24: only `pending` and `approved` occur.)*
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
> **Volume:** ~10–50 links per page — **16,564 rows**, measured 2026-08-24.

#### Columns (28) *(count confirmed 2026-08-24 against live schema; four value lists below were wrong and are corrected)*

**Identity (3):** `id uuid`, `fingerprint text` (`pil_{ULID16}` — *corrected 2026-08-24 against live data: live fingerprints read `pil_3AF0672CF8924DD7`, not `plnk_`*), `fingerprint_display_name text`

**Link target (3):**
- `from_page_fp text` → `seo_website_page_master.page_fingerprint` (the `vth-4.4.4` form — **not** `fingerprint`; all 16,564 rows use it) *(corrected 2026-08-24 against live schema)*
- `to_page_fp text` → same key, nullable when external
- `to_external_url text` (when linking to external URL)

**Link classification (3):** *(all three value lists corrected 2026-08-24 against live data)*
- `link_type text` — live values `'contextual'` (10,040), `'breadcrumb'` (4,230), `'navigational'` (2,174), `'related'` (120). The documented set `internal`/`external`/`cross_brand`/`cross_center_intra_brand` occurs in **zero** rows — including the DR-032 `cross_center_intra_brand` value, which has nothing to record while no brand is multi-center.
- `link_role text` — live values `'cluster_spoke'` (8,853), `'primary_hub'` (3,646), `'cross_cluster'` (3,092), `'supporting'` (904), `'reference'` (69). `structural`/`authority`/`contextual`/`conversion` occur in zero rows; `cross_cluster` was missing from the documented set. Same vocabulary as `seo_website_page_master.link_role`.
- `link_priority smallint` 1..5

**Anchor text strategy (4):**
- `anchor_text text` — actual anchor copy
- `anchor_variant_type text` — live values `'partial'` (9,402), `'topical'` (4,430), `'branded'` (2,066), `'exact'` (524), NULL (142). *(corrected 2026-08-24 — `'topical'` was undocumented; `'generic'` and `'naked_url'` occur in zero rows.)*
- `section_context text` — where on the page (`'header'`, `'body-§3'`, `'footer'`, etc.)
- `surrounding_text_snippet text` — context for review

**Lifecycle (4):**
- `status text` — live values `'planned'` (15,299), `'deprecated'` (1,194), `'live'` (71). *(corrected 2026-08-24 against live data — `'implemented'`, `'broken'` and `'removed'` occur in zero rows; `'deprecated'` and `'live'` were undocumented. Only 71 of 16,564 planned links are recorded as live.)*
- `planned boolean`
- `implemented boolean`
- `first_planned_at timestamptz`, `last_verified_at timestamptz`

**Reciprocal & cross-brand (5):**
- `is_reciprocal boolean` — auto-flipped by `trg_internal_link_reciprocal`
- `is_cross_brand boolean` — *(2026-08-24: false on all 16,564 rows; the DR-021 cross-brand governance path has never been exercised.)*
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
> **Volume:** **22,710 rows across 8 brands**, measured 2026-08-24 — Deezy Dental 6,269 · VitalSleep and Wellness 4,412 · The Face by Vertex 3,586 · VitalSleep Clinic 3,478 · VTH BioDent 2,129 · Smile Scape Clinic 1,786 · TC Smile Dental 784 · Clearisma 266. *(corrected 2026-08-24 against live schema — was "12,526 rows"; and this table is **not** limited to the three page-master brands, so `where brand = …` is mandatory.)*
> **DR:** DR-026 v1.12 (+6 cols seo_active/ad_active/ad_intent_score/ad_match_type_preferred/ad_landing_page_fp/ad_priority_tier)

Key columns:
- Identity: `fingerprint`, `notion_id`, `keyword`, `brand`
- Intent classification: `search_intent`, `ads_intent`, `funnel_stage`, `anxiety_level`, `keyword_painpoint`, `keyword_core_insight`
- Localization: `target_market`, `target_language`, `wpml_code`, `translation_group`
- Difficulty: `qualitative_kd`, `qualitative_kd_number`, `kd_reasoning`, `predicted_serp_features`
- Entity binding: `primary_entity_fp`, `primary_entity_name`, `keyword_use_as`
- DR-026 Ads track — 🔴 **DORMANT** *(measured 2026-08-24)*: `ad_active` is **false on all 22,710 rows**, `ad_priority_tier` is `'none'` on all 22,710, and `ad_match_type_preferred` is NULL on all 22,710. Only `seo_active` carries signal (22,436 true / 274 false). Columns: `seo_active boolean DEFAULT true`, `ad_active boolean DEFAULT false`, `ad_intent_score smallint 1..10`, `ad_match_type_preferred text` CHECK IN `('exact','phrase','broad','broad_modified')`, `ad_landing_page_fp text` → `seo_website_page_master.page_fingerprint` (real FK since 2026-08-16, ON DELETE SET NULL — *corrected 2026-08-24, the doc said `.fingerprint`*), `ad_priority_tier text DEFAULT 'none'` CHECK IN `('t1','t2','t3','none')`
- ⚠️ `funnel_stage` on **this** table is Title-Case (`Awareness` 7,201 · `Consideration` 6,968 · `Decision` 3,361 · `None` 563 · `Ambiguous` 1 · NULL 4,616), while `seo_website_page_master.funnel_stage` is lower-case after DR-057. Joining the two on funnel stage requires folding case. *(added 2026-08-24 against live data.)*
- Notion tier: `notion_tier`, `notion_tier_updated_at`
- Telemetry: `gsc_last_update`, `ga4_last_update`, `satellite_data_updated_at`, `notion_synced_at`, `keyword_contextual_ready_last_update`, `last_checked_at`
- Standard: `created_at`, `updated_at`, `note`

### 6.2 `seo_x_ads_keywords_monthly_market_snapshot` (61 cols) *(corrected 2026-08-24 against live schema — was documented as 57)*

> **Purpose:** Monthly DataForSEO snapshot — volume metrics, KD, CPC, momentum, ROI proxy. Recomputed monthly by n8n.
> **Sync:** S only
> **Volume:** **24,610 rows**, measured 2026-08-24. *(corrected 2026-08-24 against live schema — was 12,156)*

Key column families: Volume Metrics (3/6/12/48-month avg), Difficulty (KD score, competition), Cost (CPC range), Momentum (trend slope, seasonality), DataForSEO Source metadata.

### 6.3 `seo_x_ads_keyword_serp_competitors` (29 cols)

> **Purpose:** SERP top-3 + AI Overview + Featured Snippet + PAA snapshots per keyword × time.
> **Sync:** S only
> **Volume:** **13,666 rows**, measured 2026-08-24. `content_scraped_at` months present: 2026-05, 2026-07, 2026-08 (plus NULLs). *(corrected 2026-08-24 against live data — was "8,589 rows (9 snapshot waves 2026-02 → 05)"; the wave count is not derivable from the data and is dropped rather than re-guessed.)*

Key columns *(corrected 2026-08-24 against the live schema — `aio_present`, `featured_snippet_url` and `paa_questions` exist in no form on this table)*: `top_competitors_meta jsonb`, `competitor_url_list`, `competitors_content_json`, `my_content_json`, `my_onpage_score`, `ai_overview_text` (the AI-Overview body — there is **no** `aio_present boolean`; "AIO present" = this column non-NULL), `featured_snippet` (**not** `featured_snippet_url`), `people_also_ask_json` + `paa_ai_content_json` (the PAA store — there is **no** `paa_questions text[]`), `serp_features_list`, `image_pack`, `video_domains`, `related_searches`, `actual_rank`, `actual_url`, `total_ads_count`, `ads_context_json`, `snapshot_date`, `content_scraped_at`.

### 6.4 `seo_x_voice_search` (19 cols)

> **Purpose:** Voice search query tracking — natural language queries that trigger Alexa/Siri/Google Assistant answers.
> **Sync:** N↔S (master only)
> **Volume:** 🔴 **0 rows**, measured 2026-08-24 — nothing has ever been recorded here, so `intent_source_tier='derived'` cannot draw on voice signals in practice (§5.1).

Columns: `fingerprint`, `parent_keyword_fp` (FK → keyword master), `voice_query`, `query_language`, `query_intent`, `conversational_form`, `triggered_assistants text[]` (`{Alexa, Siri, Google_Assistant, Bixby}`), `expected_answer_format`, `current_answer_source`, `optimized_for_page_fp` (FK → page_master), `is_featured_snippet`, `featured_snippet_url`, `is_in_pasf` (People Also Search For), `query_volume_estimate`, `last_tested_at`, plus standard.

---

## 7. Group 5 — Performance Fact Tables (2 tables)

### 7.1 Daily Logs (`logs_YYYY` partitions, alias `seo_x_ads_keywords_x_url_daily_logs`)

> **Purpose:** Denormalized daily fact table — GSC + GA4 + CWV + indexing + on-page audit + link graph. The dashboard's primary data source.
> **Sync:** S only (telemetry ingest from GSC API, GA4 API, PSI, Lighthouse)
> **Partitioning:** Per year — `logs_2025`, `logs_2026` (125 cols each). ⚠️ *(2026-08-24: the partitions are **not** individually reachable through PostgREST — `GET /rest/v1/logs_2026` returns 404 — which is normal for partitions but means the partition layout could not be re-verified here. Confirm against `pg_inherits` before relying on it.)*
> **Volume:** **151,471 rows** on `seo_x_ads_keywords_x_url_daily_logs`, measured 2026-08-24; `snapshot_at` spans **2026-02-27 → 2026-08-23**. *(corrected 2026-08-24 against live data — was "logs_2026 = 89,960 rows (2026-02-27 → 03-22)"; the time column is `snapshot_at`, there is no `log_date`.)*

125 columns total per partition. Major column families *(every name below corrected 2026-08-24 against the live column list — the previous names were paraphrases and none of them existed)*:
- **GSC:** `gsc_clicks`, `gsc_impressions`, `gsc_ctr` (+`_mobile`/`_desktop`), `gsc_mobile_ranking`, `gsc_desktop_ranking`, `ranking`, `gsc_actual_ranking_url`, `gsc_canabalization_urls` *(live spelling, sic)*, `gsc_inspection_status`/`_verdict`
- **GA4:** `ga4_organic_sessions`, `ga4_organic_active_users`, `ga4_organic_engagement_rate`, `ga4_total_sessions`, `ga4_organic_key_event` / `ga4_total_key_event` (conversions), each with mobile/desktop splits
- **Core Web Vitals (mobile only — no desktop set exists):** `cwv_lcp_loading`, `cwv_cls_stability`, `cwv_fcp`, `cwv_tbt`, `cwv_inp`, `cwv_ttfb`, `cwv_speed_index`, `cwv_mobile_performance_score`, `cwv_score_seo`/`_accessibility`/`_best_practices`
- **Indexing:** `indexing_status`, `index_http_status`, `indexing_last_update`, `canonical_chains` — there is no `indexability_issues`, `last_crawl_at` or `has_canonical_issue`
- **On-page audit:** `onpage_score`, `page_meta_title`, `page_meta_description`, `title_too_long`, `no_description`, `no_h1_tag`, `has_duplicate_title`, `click_depth`, `automated_readability_index`, `plain_text_word_count` — there is no `title_length`, `meta_description_length`, `has_h1`, `schema_emitted`, `image_count` or `broken_links_count`
- **Link graph:** `internal_inbound_count`, `internal_outbound_count`, `external_outbound_count`, `is_orphan`

> 🔴 **`plain_text_word_count` is NULL in all 151,471 rows** *(measured 2026-08-24)*. It is the only measured word count in the schema and the crawl ETL has never populated it — so any word-count floor keyed on measured content cannot run. `seo_website_page_master.auto_suggested_word_count_target` is a target with nothing to compare against. Fix the ETL here rather than inventing a word-count column on the page master.

Triggers: `trg_dl_bump_keyword` AFTER INSERT/UPDATE → updates `seo_x_ads_keywords_contextual_master.gsc_last_update` and `ga4_last_update` denorm fields.

> **Backup:** `seo_x_ads_keywords_x_url_daily_logs_backup_20260227` exists from a pre-partition migration — 37,572 rows *(confirmed 2026-08-24 against live data)*. Retain through v2.0 then drop.

### 7.2 `seo_local_rankings` (25 cols)

> **Purpose:** Local SERP / Google Maps Pack rankings per keyword × branch × search point × time.
> **Sync:** S only — DataForSEO Maps API + n8n flow E5
> **Status:** 🔴 **0 rows**, measured 2026-08-24 — flow E5 has never run; the local-ranking rules below have no data to read.
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
> **Status:** **0 rows**, confirmed 2026-08-24 against live data (schema ready, ingest not wired)

Typical fields: brand_id, snapshot_at, total_backlinks, referring_domains, dofollow_count, nofollow_count, domain_rating, url_rating, source_provider.

### 8.2 `seo_backlinks_links` (19 cols)

> **Purpose:** Per-link backlink rows — source URL, target URL, anchor text, link attributes.
> **Sync:** S only
> **Status:** **0 rows**, confirmed 2026-08-24 against live data

Typical fields: source_url, source_domain, target_url, target_page_fp, anchor_text, link_attribute (`'dofollow'`/`'nofollow'`/`'ugc'`/`'sponsored'`), first_seen_at, last_verified_at, is_active, source_authority_score.

---

## 9. Group 7 — AI Operations & Embeddings (4 tables)

### 9.1 `seo_brand_mentions` (22 cols)

> **Purpose:** Cross-platform brand mention tracking (Pantip/Facebook/Wongnai/IG/TikTok/X/news/blog). "Everywhere SEO" per Bible Part 13.
> **Sync:** S only — monitor tool (Mention.com / Brand24 / custom scraper) ingest
> **Status:** **0 rows**, confirmed 2026-08-24 against live data

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
> **Status:** **0 rows**, confirmed 2026-08-24 against live data
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
> **Status:** **0 rows**, confirmed 2026-08-24 against live data

Columns: `id`, `fingerprint` (`llmq_{ULID16}`), `fingerprint_display_name`, `brand_id`, `simulation_name`, `prompt_template`, `prompt_variables jsonb`, `target_intent`, `target_funnel_stage`, `target_entity_fp`, `expected_citation_pages_fps text[]`, `expected_brand_mention boolean`, `total_runs int`, `successful_citations int`, `citation_rate numeric`, `brand_mention_rate numeric`, `last_run_at`, `next_scheduled_run`, `is_active boolean`, `created_at`, `updated_at`.

### 9.4 `seo_entity_embeddings` (9 cols)

> **Purpose:** Vector embeddings per entity (via pgvector). For semantic search, EUG (Entity Uniqueness Guard) v2.0, and similar-entity recommendations.
> **Sync:** S only
> **Volume:** **684 rows**, measured 2026-08-24 — against 732 entity rows, ~93% coverage. *(added 2026-08-24 against live data — this table is no longer empty.)*
> **Extension:** `vector` (pgvector). HNSW index **deferred** — the "creating HNSW on a near-empty table wastes catalog space" rationale no longer applies at 684 vectors; re-decide.

Columns:
- `id uuid`
- `entity_fp text` (FK → seo_entity_graph.entity_fingerprint) *(corrected 2026-08-24 — the entity layer resolves on `entity_fingerprint`, not `fingerprint`)*
- `embedding_model text` (e.g. `'text-embedding-3-large'`, `'voyage-2'`)
- `embedding_dimensions smallint` (e.g. 1536, 1024)
- `embedding vector(N)` — pgvector type (N varies per model)
- `source_text text` — text that was embedded
- `source_text_hash text` — for cache busting
- `computed_at timestamptz`
- `is_stale boolean` — flag for re-embedding (e.g. when entity description changes)

---

## 10. Group 8 — Data Quality & Governance (2 tables)

### 10.1 `seo_data_quality_metrics` (13 cols) *(corrected 2026-08-24 against live schema — was documented as 15; the column list below has always enumerated 13)*

> **Purpose:** Time-series data quality metrics — DAMA 5 dimensions (completeness, consistency, accuracy, timeliness, uniqueness) + sync lag + FK integrity scores.
> **Sync:** S only — populated by scheduled jobs
> **Status:** 🔴 **0 rows**, measured 2026-08-24 — the scheduled jobs have never written here, so no DAMA metric is tracked in the database today.

Columns: `id`, `metric_name`, `metric_category` (e.g. `'completeness'`, `'consistency'`, `'sync_lag'`), `metric_value numeric`, `metric_value_jsonb` (for structured breakdowns), `threshold_min`, `threshold_max`, `status` (`'green'`, `'yellow'`, `'red'`), `target_table_name`, `target_brand_id`, `scope_description`, `computed_at`, `computation_duration_ms`.

### 10.2 `seo_schema_changes` (18 cols)

> **Purpose:** DDL audit log — one row per schema migration step. Cross-references `migration_version` and `related_dr_id` for traceability.
> **Sync:** S only — append-only, populated by `apply_migration` workflow

Columns: `id`, `change_type` text CHECK IN (`'create_table'`,`'drop_table'`,`'alter_table_add_column'`,`'alter_table_drop_column'`,`'alter_table_alter_column'`,`'rename_table'`,`'rename_column'`,`'add_index'`,`'drop_index'`,`'add_constraint'`,`'drop_constraint'`,`'add_trigger'`,`'drop_trigger'`,`'create_function'`,`'drop_function'`,`'create_view'`,`'drop_view'`,`'enable_rls'`,`'disable_rls'`,`'create_policy'`,`'drop_policy'`,`'other'`), `table_name`, `column_name`, `index_name`, `constraint_name`, `migration_version`, `migration_name`, `related_dr_id`, `spec_version`, `description`, `ddl_statement`, `performed_by`, `performed_at`, `duration_ms`, `rolled_back boolean`, `rolled_back_at`, `rollback_reason`.

**Recent activity:** **54 rows** total, measured 2026-08-24 — 33 of them carry `migration_version LIKE 'eywa_w11_%'`. Logged dates: 2026-05-27, 06-02, 06-04, 06-07, 06-08, 06-11, 07-10, 07-27, 07-28, 07-29. *(corrected 2026-08-24 against live data — was "20 rows logged 2026-05-27". Note the log stops at 2026-07-29: the DR-057 funnel/section/schema migrations of 2026-08-23 are **not** recorded here, so this table is no longer a complete DDL audit trail.)*

---

## 11. Group 9 — Entity Extensions & Templates (11 tables = 10 extensions + 1 template registry; `seo_entity_symptom` §11.5a added per DR-036)

> **Pattern:** 1:1 extension to `seo_entity_graph` via `entity_fp text FK→seo_entity_graph.entity_fingerprint` *(corrected 2026-08-24 — the extensions resolve on `entity_fingerprint`, the load-bearing key of §4.1, not on `fingerprint`)*. One row per qualifying entity. Each table adds vocabulary specific to its entity_type (CPT codes for procedures, ATC codes for drugs, FMA terms for anatomy, etc.).
>
> **Sync drift note:** Spec comments mark these `N↔S` but the actual tables were built **without `notion_id` columns** — practically these function as **S-only** detail tables today. Operator may add notion_id later if a Notion mirror DB is built. See §2 Sync direction matrix. *(confirmed 2026-08-24: no Group-9 table has a `notion_id` column.)*
>
> ⚠️ *(added 2026-08-24 against live data)* **Every "Key fields" line in §11.1–§11.9 was re-checked column by column against the live schema and most were wrong** — they listed plausible names that do not exist. The lists below are now the live names. Row counts are as of 2026-08-24 and will drift; re-measure per table.

### 11.1 `seo_entity_ingredients` (29 cols) — entity_type='ingredient' · **0 rows** (2026-08-24)

INCI / CAS / EWG. Used by cosmetic/supplement product pages. 🔴 Empty, and `seo_entity_graph` holds no `ingredient`-typed entity either — nothing binds here today.
Key fields *(corrected 2026-08-24 against live schema)*: `inci_name`, `inci_aliases`, `cas_number`, `ec_number`, `ewg_id`, `cosing_ref_no`, `allergen_status`, `comedogenic_rating`, `irritancy_rating`, `pregnancy_safe`, `breastfeeding_safe`, `fungal_acne_safe`, `photosensitivity`, `function_categories`, `concentration_range_typical`, `typical_concentration_min`/`_max`, `effective_concentration_min`, `regulatory_status`, `thai_fda_classification`, `thai_fda_max_concentration`, `eu_annex_restriction`, `us_fda_status`, `mechanism_of_action`, `evidence_level`. **Not live:** `ewg_hazard_score`, `function_category`, `restrictions_eu`, `restrictions_us_fda`, `restrictions_thai_fda`, `vegan_status`, `cruelty_free_status`, `paraben_free`, `phthalate_free`, `is_natural`, `synonyms`, `safe_usage_concentration_pct`.

### 11.2 `seo_entity_devices` (24 cols) — entity_type='device' · **64 rows** (2026-08-24) *(count corrected 2026-08-24 — was documented as 22 cols)*

FDA / CE / manufacturer registration. Used by medical device pages.
Key fields *(corrected 2026-08-24 against live schema)*: `manufacturer`, `manufacturer_org_fp`, `model_number`, `device_family`, `fda_clearance`, `fda_clearance_date`, `ce_mark`, `ce_mark_class`, `thai_fda_reg_no`, `regulatory_class`, `technology_category`, `wavelength_nm`, `clinical_indications`, `contraindications`, `treatment_areas`, `typical_session_duration_min`, `typical_sessions_required`, `downtime_days`, `load_from`, `load_source`. **Not live:** `fda_clearance_number`, `ce_mark_number`, `manufacturer_name`, `device_class`, `intended_use_statement`, `warnings`, `made_in_country`, `is_class_iii`, `is_implantable`, `approval_status`.

### 11.3 `seo_entity_procedures` (27 cols) — entity_type='procedure' · **145 rows** (2026-08-24) *(count corrected 2026-08-24 — was documented as 25 cols)*

CPT codes + recovery + contraindications. **T2-medical-procedure template binding.**
Key fields *(corrected 2026-08-24 against live schema)*: `cpt_code`, `cpt_alternate_codes`, `procedure_type`, `invasiveness_level`, `procedure_duration_min`/`_max`/`_typical`, `recovery_time_days`, `recovery_back_to_work_days`, `recovery_full_recovery_days`, `anesthesia_type`, `anesthesia_required`, `treats_conditions_fps`, `affects_anatomy_fps`, `uses_devices_fps`, `contraindications`, `contraindication_entities_fps`, `complications_common`, `success_rate_pct`, `requires_followup`, `followup_visits_typical`, `load_from`, `load_source`. **Not live:** `hcpcs_code`, `thai_procedure_code`, `procedure_category`, `typical_duration_minutes`, `pain_level`, `risks`, `pre_op_instructions`, `post_op_instructions`, `expected_outcomes`, `cost_range_thb`.

### 11.4 `seo_entity_product` 🆕 v1.11 (42 cols) — entity_type='product' · **0 rows** (2026-08-24)

Product master for productized offerings. Bridges DR-024. 🔴 Empty despite 4 `product`-typed entities in the graph.
Key fields *(corrected 2026-08-24 against live schema)*: `gtin`, `sku`, `manufacturer_part_number`, `product_name`, `product_slug`, `brand_owner_name`, `brand_owner_org_fp`, `is_own_brand_product`, `product_category`, `product_subcategory`, `product_form`, `ingredients_fps`, `key_active_ingredients`, `inactive_ingredients`, `allergen_warnings`, `free_from_claims`, `size_value`, `size_unit`, `variants`, `price_min`/`price_max`/`price_typical`/`currency`/`price_per_unit`, `thai_fda_reg_no`, `thai_fda_type`, `regulatory_status`, `requires_prescription`, `pregnancy_safe`, `breastfeeding_safe`, `pediatric_safe`, `pediatric_min_age_years`, `contraindications`, `certifications`, `schema_product_type`, `is_discontinued`, `launch_date`, `discontinued_date`. **Not live:** `product_sku`, `product_brand_id`, `manufacturer_name`, `ingredients_list_inci`, `claims_marketing`, `claims_substantiated`, `price_thb`, `pack_size`, `unit_count`, `storage_conditions`, `shelf_life_months`, `is_prescription_only`, `is_otc`, `is_supplement`, `regulatory_registration_no`, `regulatory_registration_country`.

### 11.5 `seo_entity_condition` 🆕 v1.11 (42 cols) — entity_type='condition' (T1 CRITICAL) · **125 rows** (2026-08-24) *(count corrected 2026-08-24 — was documented as 40)*

ICD-11 / ICD-10 / ICD-10-CM / SNOMED CT / MeSH. **T1 page template binding** — every condition page pulls from this. CRITICAL for medical content authority. **DR-033 ICD coding set:** `icd11_code` (ICD-11-MMS, primary) · `icd10_code` (WHO base / ICD-10-TM) · `icd10_cm_code` (US clinical-mod) · `icd10_codes_related[]` — emitted together in `MedicalCondition.code[]`, ICD-11 first.
Key fields *(corrected 2026-08-24 against live schema)*: `icd11_code` 🆕 v1.19, `icd10_code` (WHO base), `icd10_cm_code` 🆕 v1.19, `icd10_codes_related[]`, `snomed_ct_id`, `mesh_id`, `umls_cui`, `wikidata_qid`, `condition_category`, `body_system`, `is_chronic`, `is_acute`, `is_recurrent`, `is_lifestyle_related`, `prevalence_global_pct`, `prevalence_thailand_pct`, `prevalence_source`, `incidence_per_100k_yearly`, `mortality_rate_pct`, `severity_levels`, `symptoms`, `symptom_entities_fps`, `early_warning_signs`, `related_anatomy_fps`, `treatment_drugs_fps`, `treatment_procedures_fps`, `prevention_strategies`, `affected_age_groups`, `gender_predominance`, `risk_factors`, `diagnostic_methods`, `diagnostic_tests_fps`, `patient_explanation_th`, `patient_explanation_en`, `common_misconceptions`, `search_volume_proxy`, `load_from`, `load_source`. **Not live:** `prevalence_estimate`, `typical_age_onset`, `symptoms_list_fps`, `risk_factors_list_fps`, `diagnosis_methods`, `treatment_options_fps`, `prognosis`, `is_emergency`, `is_contagious`, `is_genetic`, `who_classification`.

### 11.5a `seo_entity_symptom` 🔒 v1.21 BUILT (DR-036) — entity_type='symptom' (T1) · 31 cols · **21 rows** (2026-08-24) *(column count corrected 2026-08-24 — was documented as 29; live adds `load_from` + `load_source`)*

> **Built 2026-06-04** (migration `eywa_w11_06_dr036_v21_entity_symptom`). Sibling extension to §11.5 `seo_entity_condition`, split out per **DR-036** (Bible §25.3 Core CPT 7 `symptom`). 1:1 with `seo_entity_graph` rows where `type='symptom'` — already a valid `entity_type` enum value (§4.1), so **no enum/discriminator change** was required. Numbered **11.5a** (deliberately *not* folded into the 11.6–11.10 sequence) to preserve the existing cross-references to §11.6–§11.10.
>
> **Pattern:** mirrors `seo_entity_condition` — `entity_fp text NOT NULL UNIQUE` FK → `seo_entity_graph.entity_fingerprint` ON DELETE CASCADE, PK `id uuid DEFAULT gen_random_uuid()`, RLS-enabled (`eywa_authenticated_full_access`), S-only, one row per symptom entity. Drops condition-only fields (`prevalence_*`, `incidence_*`, `mortality_rate_pct`, `is_chronic`/`is_acute`/`is_recurrent`/`is_lifestyle_related`); keeps the coding + anatomy fields and adds symptom-specific character + YMYL-safety fields.

**Key fields (31 cols — every name below confirmed live 2026-08-24)** — `id`, `entity_fp` (FK → `seo_entity_graph.entity_fingerprint`), plus `load_from` + `load_source`. **Coding:** `snomed_ct_id` (symptoms lead with SNOMED CT), `icd11_code` (ICD-11-MMS), `icd10_code` (WHO base — R-codes where applicable), `icd10_codes_related text[]`, `mesh_id`, `umls_cui`, `wikidata_qid`. **Classification:** `symptom_category`, `body_system text[]`, `related_anatomy_fps text[]` (→ `seo_entity_anatomy`). **Character:** `severity_scale` (CHECK `mild|moderate|severe|variable`), `typical_onset` (CHECK `acute|sudden|gradual|intermittent|variable`), `typical_duration`, `is_emergency_sign boolean`. **Relations:** `associated_conditions_fps text[]` (→ `seo_entity_condition`; reciprocal of `seo_entity_condition.symptom_entities_fps`), `accompanying_symptoms_fps text[]` (self-FK), `triggers_factors text[]`, `relieving_factors text[]`. **YMYL safety:** `red_flag_indicators text[]` (when to seek urgent care), `self_care_guidance`, `when_to_see_doctor`. **Patient-facing:** `patient_explanation_th`, `patient_explanation_en`, `common_misconceptions text[]`, `search_volume_proxy`. **Audit:** `created_at`, `updated_at`. **Schema-type emission:** `MedicalSignOrSymptom`, keyed off `post_type` (Bible §25.3, DR-036). **Edge:** `symptom_of` → parent `seo_entity_condition` (cross-CPT; vocab unchanged — DR-013/DR-014).

### 11.6 `seo_entity_drug` 🆕 v1.11 (44 cols) — entity_type='drug' · **9 rows** (2026-08-24) *(count corrected 2026-08-24 — was documented as 42)*

RxNorm / ATC / Thai FDA registration.
Key fields *(corrected 2026-08-24 against live schema)*: `rxnorm_code`, `atc_code`, `mesh_id`, `wikidata_qid`, `generic_name`, `brand_names`, `chemical_name`, `drug_class`, `drug_subclass`, `dosage_forms`, `routes_of_administration`, `available_strengths`, `thai_fda_reg_no`, `thai_fda_status`, `prescription_required`, `controlled_substance_class`, `requires_special_program`, `indications_fps`, `indications_text`, `off_label_uses`, `contraindications_fps`, `contraindications_text`, `side_effects_common`, `side_effects_serious`, `pregnancy_category`, `breastfeeding_category`, `pediatric_use`, `pediatric_min_age_years`, `geriatric_considerations`, `drug_interactions_fps` (self-FK), `food_interactions`, `typical_dosing_adult`, `max_daily_dose`, `duration_typical`, `mechanism_of_action`, `half_life_hours`, `bioavailability_pct`, `is_generic_available`, `load_from`, `load_source`. **Not live:** `inn_name`, `rxnorm_id`, `schedule_dea`, `thai_fda_registration_no`, `pharmacokinetics`, `indications`, `contraindications`, `adverse_effects`, `is_prescription`, `is_controlled`.

### 11.7 `seo_entity_anatomy` 🆕 v1.11 (27 cols) — entity_type='anatomy' · **21 rows** (2026-08-24) *(count corrected 2026-08-24 — was documented as 25)*

FMA (Foundational Model of Anatomy) / UBERON. Self-FK hierarchy for body system tree.
Key fields *(corrected 2026-08-24 against live schema)*: `fma_id`, `uberon_id`, `terminologia_anatomica`, `mesh_id`, `wikidata_qid`, `anatomical_name_latin`, `anatomical_name_th`, `common_name_th`, `body_system`, `anatomical_region`, `anatomy_type`, `parent_anatomy_fp` (self-FK), `parent_anatomy_relation`, `child_anatomy_fps`, `connected_to_fps`, `innervated_by_fps`, `vascularized_by_fps`, `affected_by_conditions_fps`, `target_of_procedures_fps`, `illustration_url`, `model_3d_url`, `load_from`, `load_source`. **Not live:** `body_region`, `is_organ`, `is_tissue`, `is_cell`, `function_summary`, `related_conditions_fps`.

### 11.8 `seo_entity_organization` 🆕 v1.11 (34 cols) — entity_type='organization' · **21 rows** (2026-08-24)

External organizations (WHO, IAOMT, IABDM, ทันตแพทยสภา, A4M, etc.) — DISTINCT from `brands` table which is internal EYWA brands.
Key fields *(corrected 2026-08-24 against live schema)*: `legal_name`, `common_name`, `aliases`, `wikidata_qid`, `ringgold_id`, `ror_id`, `organization_type`, `organization_subtype`, `industry_focus`, `is_for_profit`, `headquarters_country_code`, `headquarters_city`, `headquarters_address`, `operates_in_countries`, `founding_date`, `founders`, `parent_organization_fp`, `subsidiaries_fps`, `authority_tier`, `is_government_authority`, `is_who_recognized`, `accredits`, `official_website`, `wikipedia_url_en`, `wikipedia_url_th`, `same_as_urls`, `is_own_brand_org`, `linked_brand_id`, `used_as_citation_source`, `citation_count_in_corpus`. **Not live:** `organization_name`, `org_type`, `country_of_origin`, `founding_year`, `wikidata_id`, `official_url`, `notable_publications`, `is_credentialing_body`, `accredited_specialties`, `member_count_estimate`, `mission_statement` — the discriminator column is `organization_type`, not `org_type`, so the enum previously listed here could not be re-verified either.

### 11.9 `seo_entity_lab_test` 🆕 v1.11 (36 cols) — entity_type='lab_test' · **0 rows** (2026-08-24)

LOINC / CPT. Lab test definitions for biomarker entities. 🔴 Empty, and no `lab_test`-typed entity exists in the graph.
Key fields *(corrected 2026-08-24 against live schema)*: `loinc_code`, `cpt_code`, `snomed_ct_id`, `mesh_id`, `wikidata_qid`, `test_name`, `test_aliases`, `test_acronym`, `test_category`, `test_subcategory`, `test_type`, `sample_type`, `sample_volume`, `is_invasive`, `requires_fasting`, `fasting_hours_required`, `preparation_instructions`, `typical_duration_minutes`, `results_turnaround_hours`, `requires_appointment`, `indications`, `related_conditions_fps`, `related_anatomy_fps`, `screens_for_conditions_fps`, `reference_ranges`, `result_unit`, `requires_devices_fps`, `radiation_dose_msv`, `contraindications`, `pregnancy_safety`, `typical_cost_thb`, `insurance_typical_coverage`. **Not live:** `specimen_type` (it is `sample_type`), `reference_range_units`/`_low`/`_high` (one `reference_ranges` column), `interpretation_low`/`_normal`/`_high`, `clinical_significance`, `typical_cost_thb_range`, `is_fasting_required`, `is_overnight_required`, `result_turnaround_days`.

### 11.10 `seo_programmatic_templates` (12 cols) — template registry (NOT entity extension)

> **Purpose:** Registry of page templates. **23 rows** live, measured 2026-08-24: `T1`–`T19` plus the variants `T6a`, `T8g`, `T12g`, `T12i`. *(corrected 2026-08-24 against live data — the registry does **not** run to T22, and it contains **zero** `T-ADS-*` rows, so the DR-026 ads templates exist only on paper. `applicable_brands`: 22 rows `['*']`, 1 row `['deezy-dental']`; `entity_type_required` is set on 4 rows (procedure ×2, condition, device) and NULL on 19.)*
> ⚠️ This registry is a **global** T-code list, but `seo_website_page_master.content_format` is **per brand** (deezy uses `T2b`, which has no row here). Do not validate a page's `content_format` against this table — validate against the brand's own content-template document. *(added 2026-08-24 against live data.)*
> **Sync:** S only (despite spec comment saying N↔S — no notion_id column built). Source of truth for human-readable templates lives in `Content_Templates_EYWA_v1_0.md` in spec repo; this table is the pipeline-consumed structured registry.
> **Trigger:** `trg_set_fingerprint`, `trg_prevent_fingerprint_change`

Columns: `id uuid`, `fingerprint text` (`tmpl_{ULID16}`), `fingerprint_display_name`, `template_name text`, `template_id text` (e.g. `'T1'`, `'T-ADS-3'`), `target_layer text` 🔴 **UNIMPLEMENTABLE as written — see mapping note** (nothing to join on: the page master has no `layer` column — Appendix H.3), `url_pattern text`, `page_template_blueprint jsonb` (the actual template structure: sections, schema rules, content requirements), `applicable_brands text[]`, `entity_type_required text`, `created_at`, `updated_at`.

> 🔴 **`target_layer` mapping note** *(rewritten 2026-08-23 — `layer` column does not exist; see the reconciliation report)*
> This column stores Bible Part 3.2 layers `L1`–`L7` and is populated on all 23 rows (L5×7, L4×4, L6×4, L2×3, L7×2, L1×2, L3×1, measured 2026-08-24), but `seo_website_page_master` has **no `layer` column** to match them against (Appendix H.3) — and there never will be one — so template↔page resolution cannot join here. Resolve on the taxonomy columns that do exist (§5.1) — `coalesce(page_category, page_type)`. `page_category` is now documented in the §5.1 listing and is **backfilled on all three brands** *(corrected 2026-08-24 against live data — the earlier "still empty on two of three brands" is out of date: vth-biodent 686/761, deezy-dental 776/869, smile-scape-clinic 707/728; 189 rows brand-wide are still NULL, which is exactly why `page_type` remains the fallback and must not be dropped)*:
>
> | Bible layer | Predicate on `seo_website_page_master` | Fit |
> |---|---|---|
> | L1 Authority | `coalesce(page_category, page_type) IN ('home','about','doctor_profile','contact','branch_landing')` | **approximate** — sweeps in branch/contact rows that are navigational, not E-E-A-T signals. Do not substitute `sitemap_section IN ('1','2','8')`. |
> | L2 Money | `coalesce(page_category, page_type) IN ('service_page','procedure_pillar')` | **approximate** — also absorbs L6 protocol pages; excludes `local_landing`/`local_service*` programmatic money pages unless added explicitly. |
> | L3 Product / Tech | `coalesce(page_category, page_type) = 'technology_page'` | **approximate** — category and `sitemap_section='4'` disagree on ~26% of VTH device pages; no third column breaks the tie. |
> | L4 Concern | `coalesce(page_category, page_type) = 'condition_pillar'` | clean — do **not** substitute `sitemap_section='5'` (a zone, not a layer). |
> | L5 Knowledge | `coalesce(page_category, page_type) = 'knowledge_article'` | **approximate** — also swallows protocol/aftercare articles; nothing separates L5 from L6 here. |
> | L6 Protocol | 🔴 **UNIMPLEMENTABLE as written — see mapping note:** no value of `page_category`, `page_type`, `node_tier` or `sitemap_section` isolates protocol pages (they are stored as `service_page` in section 3 or `knowledge_article` in section 6). Nearest runnable filter leaves these columns entirely: `schema_markup_type LIKE '%HowTo%' OR schema_markup_type LIKE '%TreatmentPlan%'` — which returns zero rows on two of three brands. | **no equivalent** |
> | L7 Evidence | `coalesce(page_category, page_type) = 'evidence_case'` | clean — `sitemap_section='7'` corroborates to within 4 rows per brand. |
>
> Because L6 has no predicate, the Bible rules keyed on it cannot run as column checks and must be rewritten as content checks or dropped: "L3 MUST connect to L6", "L7 must link back to L2 or L6", the L4/L5/L6 cannibalization shield (only the L4-vs-L5 half survives), and the per-layer word-count floors in §9.8. Layer is also neither `sitemap_section` (site zone) nor `node_tier` (importance) — see the three-axes warning in §5.1.

---

## 12. Group 10 — Ads Landing Page Track (column extensions only) 🌱 v1.12 (DR-026 Proposed)

> Per **DR-026 Proposed 2026-05-12** + Bible Part 29. Phase 0 — additive columns on existing tables; NO new tables ship in v1.12. The `seo_campaigns` table is reserved for Phase 1 (DR-027 — Locked v1.13+).
>
> **Companion Bible:** Part 29 (Ads Landing Page Track)
> **Companion Templates:** v1.4 (T-ADS-1 through T-ADS-5)

> 🔴 **DR-026 is DORMANT across both extension sets** *(measured 2026-08-24)*: `ads_template_id` NULL on all 2,358 page rows, `page_purpose` only ever `seo_organic`/`utility`, `ad_active` false on all 22,710 keyword rows, `ad_priority_tier` `'none'` on all 22,710. All 12 columns exist and are correct; none carries an ad landing page. Re-measure with `select count(*) from seo_x_ads_keywords_contextual_master where ad_active`.

### 12.1 `seo_website_page_master` extensions (already detailed in §5.1 "Ads LP track" subsection)

6 columns: `page_purpose`, `ads_template_id`, `index_directive`, `conversion_event_primary`, `conversion_event_secondary[]`, `campaign_id` (Phase 0 stub). *(all 6 confirmed live 2026-08-24)*

### 12.2 `seo_x_ads_keywords_contextual_master` extensions (already detailed in §6.1 "DR-026 Ads track")

6 columns: `seo_active`, `ad_active`, `ad_intent_score`, `ad_match_type_preferred`, `ad_landing_page_fp`, `ad_priority_tier`. *(all 6 confirmed live 2026-08-24)*

### 12.3 Future: `seo_campaigns` Universal Master Table (Phase 1, DR-027 — NOT IN v1.18)

Architecture sketch reserved for DR-027 lock. Stub column `seo_website_page_master.campaign_id text` exists today; will become `campaign_fp text FK → seo_campaigns(fingerprint)` when DR-027 ships. Until then, operators populate `campaign_id` with operator-chosen identifiers (e.g. `'vth-biodent-launch-2026-q2'`).

---

## 13. Group 11 — Media Assets (1 table) 🆕 v1.23 (DR-038)

> Multi-brand Digital Asset Manager (DAM). One row per image binary. Mirrored to Notion `🖼️ Media Library` DB in every workspace (14th N↔S table per Bible §18.1.2). Binary storage delivered via Cloudflare R2 + Image Transformations per DR-035. PDPA consent lifecycle enforced at DB layer.

### 13.1 `seo_media_assets` 🆕 v1.23 (DR-038)

> **Purpose:** Canonical store for image metadata + R2 location + PDPA consent state. One row per image across all brands.
> **Sync:** N↔S (Notion master `🖼️ Media Library`, Supabase mirror via n8n; binaries pushed to R2 during sync)
> **PK:** `id uuid` (DEFAULT `gen_random_uuid()`).
> **Volume:** 100s–10000s per brand at maturity — 🔴 **0 rows**, measured 2026-08-24. The table exists (37 columns, confirmed live) but no image has ever been registered, so the PDPA consent gate, the consent-expiry cron and the R2 fields below have nothing to act on. *(corrected 2026-08-24 against live schema)*
> **Bible:** §18.1.2 row 14 · §18.1.3 parity notes · DR-035 (R2 path) · DR-038 (this table)
> **Brand pattern:** Family-B operational (per DR-037 ruling) — `brand_id uuid NOT NULL` FK with `ON DELETE CASCADE`, NOT `brand_scope[]`. Per-brand operational data, not knowledge-graph entity.

#### Columns (37) *(confirmed 2026-08-24 against live schema — count and every column name below match the live table)*

**Identity (DR-008 Two-Column, 3):**
- `id uuid` PK, DEFAULT `gen_random_uuid()`
- `fingerprint text` UNIQUE NOT NULL — `mda_{ULID16}` (trigger-set via `fn_set_fingerprint_generic('mda','asset_name','asset_name')`)
- `fingerprint_display_name text` NOT NULL — `{fp_last_6}::{slug(asset_name)}` (set in same trigger)

**Notion sync (DR-006 Two-Phase, 3):**
- `notion_id text` UNIQUE (nullable until Phase 1 sync writes back)
- `notion_synced_at timestamptz`
- `sync_state text` NOT NULL DEFAULT `'flat_loaded'`, CHECK IN (`'flat_loaded'`,`'notion_synced'`,`'relations_backfilled'`,`'live'`)

**Asset metadata (5):**
- `asset_name text` NOT NULL (Notion title)
- `caption_th text` · `caption_en text`
- `alt_th text` · `alt_en text` — required at Notion-governance layer (not DB-enforced)

**File dimensions (4):**
- `width integer` · `height integer` · `file_size_bytes bigint` · `mime_type text`

**Classification (2):**
- `media_type text` NOT NULL, CHECK IN 11 categories: `doctor`, `branch`, `brand`, `treatment`, `procedure`, `condition`, `tech`, `case`, `clinic`, `brand_asset`, `other`. Non-patient categories (`brand`, `brand_asset`, `tech`, `clinic`) bypass PDPA gate.
- `source text` NOT NULL DEFAULT `'notion'`, CHECK IN (`'notion'`, `'batch-upload'`, `'wp-migration'`)

**Brand / Entity binding (3):**
- `brand_id uuid` NOT NULL **FK → `brands(id)` ON DELETE CASCADE** (Family-B pattern, not `brand_scope[]`)
- `entity_fp text` (soft FK → `seo_entity_graph(fingerprint)`; nullable — not all assets bind to an entity)
- `center_scope text[]` (DR-032 multi-center; nullable for monolithic brands)

**PDPA consent lifecycle (7):**
- `is_patient_image boolean` NOT NULL DEFAULT `false`
- `consent_status text` CHECK IN (`'Obtained'`, `'Pending'`, `'Revoked'`) — nullable
- `consent_date date`
- `consent_doc_url text` — pointer to signed consent (stored privately outside Supabase)
- `patient_ref text` — pseudonymized reference (e.g. `'P-2026-001'`); **NEVER patient name or PII** (constraint enforced operationally; column comment documents this)
- `use_forever boolean` NOT NULL DEFAULT `false`
- `use_until date` — last date this patient image may appear (auto-removal target)

**Cloudflare R2 (DR-035, 5):**
- `r2_account_email text` — which CF account hosts binary (operator convention: matches `brands.cloudflare_account_email` for the bound brand; no FK kept simple for n8n)
- `r2_bucket text`
- `r2_object_key text`
- `r2_uploaded_at timestamptz`
- `cdn_url text` — delivered URL (Cloudflare edge)

**Lifecycle (3):**
- `status text` NOT NULL DEFAULT `'Pending'`, CHECK IN (`'Pending'`,`'Active'`,`'Expired'`,`'Revoked'`,`'Archived'`)
- `expired_at timestamptz` · `archived_at timestamptz`

**Audit (2):**
- `created_at timestamptz` NOT NULL DEFAULT `now()`
- `updated_at timestamptz` NOT NULL DEFAULT `now()` (auto-bumped via `update_updated_at_column`)

#### Indexes (9 total — incl. PK + 2 UNIQUE)

- `seo_media_assets_pkey` PRIMARY KEY (id)
- `seo_media_assets_fingerprint_key` UNIQUE (fingerprint)
- `seo_media_assets_notion_id_key` UNIQUE (notion_id)
- `idx_media_assets_brand_id` (brand_id) — every per-brand query
- `idx_media_assets_entity_fp` (entity_fp) WHERE entity_fp IS NOT NULL — entity binding lookups
- `idx_media_assets_notion_id` (notion_id) WHERE notion_id IS NOT NULL — sync flow
- `idx_media_assets_media_type` (media_type) — classification reports
- `idx_media_assets_status_open` (status) WHERE status <> 'Archived' — operational dashboard
- `idx_media_assets_consent_expiry` (use_until) WHERE is_patient_image=true AND use_forever=false AND status='Active' — **PDPA consent-expiry alerting cron**

#### Triggers (3)

- `trg_set_fingerprint_media` BEFORE INSERT — `fn_set_fingerprint_generic('mda','asset_name','asset_name')`
- `trg_prevent_fingerprint_change_media` BEFORE UPDATE OF fingerprint — `fn_prevent_fingerprint_change` (DR-008 immutability)
- `trg_updated_at_media` BEFORE UPDATE — `update_updated_at_column`

#### Constraints

- `pdpa_active_consent_gate` CHECK — **enforces PDPA at DB layer**:
  ```sql
  CHECK (
    NOT (is_patient_image = true AND status = 'Active')
    OR (consent_status = 'Obtained' AND (use_forever = true OR use_until IS NOT NULL))
  )
  ```
  Patient image cannot be `Active` without `Obtained` consent + (`use_forever=true` OR `use_until` set). Non-patient images (brand assets, tech, clinic) bypass the gate.

- `chk_media_type` CHECK 11 categories (above)
- `chk_source` CHECK 3 sources
- `chk_sync_state` CHECK 4 sync states
- `chk_consent_status` CHECK 3 consent states (or NULL)
- `chk_status` CHECK 5 lifecycle states

#### RLS

- `eywa_authenticated_full_access` — `FOR ALL TO authenticated USING (true) WITH CHECK (true)` (Family-B operational policy, matches `seo_payer_partners` per DR-037)

#### Companion (non-canonical, operator UI)

Notion `☁️ Cloudflare Accounts` reference DB (per Bible §18.1.2b) carries the registry of org-owned CF accounts. **Not mirrored to Supabase** — canonical brand→account binding lives in `brands.cloudflare_account_email` (§3.1 above). The reference DB is operator-facing only.

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
| `uuid-ossp` | All tables with UUID PK (all 43 EYWA base tables) *(corrected 2026-08-24 — the doc's own total is 43, not 40)* |
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
| `seo_topic_cluster_master` | `clst_` ⚠️ | (auto) | `clst_FDD80BDCE00946A0` *(corrected 2026-08-24 against live data — the doc said `tcls_`)* |
| `seo_citations` | `cite_` | (auto) | `cite_005DB7BA4E864B7B` ✅ verified live 2026-08-24 |
| ~~`seo_page_citations`~~ | 🔴 **none** | — | 🔴 *(corrected 2026-08-24 against live schema — **this table has no `fingerprint` or `fingerprint_display_name` column at all**; a `pcit_` prefix does not exist. It is the one junction that never received DR-008 two-column identity. Join on `(page_fp, citation_fp)` — see §4.4.)* |
| `seo_entity_relationships` | `erel_` ⚠️ | (auto) | `erel_27CFB90655A84B87` *(corrected 2026-08-24 against live data — the doc said `edge_`)* |
| `seo_editorial_reviews` | `edrv_` ⚠️ | (auto) | `edrv_25C411303ED44224` *(corrected 2026-08-24 against live data — the doc said `erev_`)* |
| `seo_page_internal_links` | `pil_` ⚠️ | (auto) | `pil_3AF0672CF8924DD7` *(corrected 2026-08-24 against live data — the doc said `plnk_`)* |
| `seo_payer_partners` | `payp_` | (auto) | `payp_39F7418781F34DD9` ✅ verified live 2026-08-24 |
| `seo_reviews` | `rev_` | (auto) | `rev_...` — ⚠️ unverified: table is empty, no live fingerprint to read |
| `seo_directory_listings` | `dirlist_` | (auto) | `dirlist_...` — ⚠️ unverified: table is empty |
| `seo_gbp_posts` | `gbppost_` | (auto) | `gbppost_...` — ⚠️ unverified: table is empty |
| `seo_brand_mentions` | `bmen_` | (auto) | `bmen_...` — ⚠️ unverified: table is empty |
| `seo_llm_citations` | `llmc_` | (auto) | `llmc_...` — ⚠️ unverified: table is empty |
| `seo_llm_query_simulations` | `llmq_` | (auto) | `llmq_...` — ⚠️ unverified: table is empty |
| `seo_programmatic_templates` | `tmpl_` | (auto) | `tmpl_0928802692DD4B54` ✅ verified live 2026-08-24 |
| `seo_x_voice_search` | `vsrch_` | (auto) | `vsrch_...` — ⚠️ unverified: table is empty |

> *(added 2026-08-24)* Prefixes marked ✅ were read from live rows. The four ⚠️ corrections above were all cases where the documented prefix appears in **no** live row — four of the six populated satellite tables had the wrong prefix on file. The remaining `⚠️ unverified` rows sit on empty tables: the prefix is whatever `fn_set_fingerprint_generic` was given at creation, which PostgREST cannot show. `seo_local_rankings` and `seo_entity_embeddings` also have no fingerprint columns and never appear in this registry, correctly.
>
> ⚠️ *(added 2026-08-24)* **Three tables are not single-prefix — do not build a CHECK regex from this table alone.** Live: `seo_entity_relationships` = `erel_` ×1,084 **+ `erl_` ×5**; `seo_editorial_reviews` = `edrv_` ×2,048 **+ `rev_` ×47**; `seo_page_internal_links` = `pil_` ×16,481 **+ `lnk_` ×83**. The minority prefixes are legacy rows from before the generic trigger was standardized; an anchored `^erel_` / `^edrv_` / `^pil_` validator rejects 135 rows that are already in the database. `brands`, `seo_branches`, `seo_authors_reviewers`, `seo_doctor_assignments`, `seo_entity_graph`, `seo_website_page_master`, `seo_citations`, `seo_payer_partners` and `seo_programmatic_templates` are uniform across every live row.

### Display Name Formulas

| Table | Display Name Pattern |
|---|---|
| `brands` | `{fp_last_6}::{brand_slug}` ✅ verified live 2026-08-24 (`5F45CF::vth-biodent`) |
| `seo_brand_centers` | `{fp_last_6}::{brand_id}::{center_slug}` — ⚠️ unverified: table is empty |
| `seo_entity_graph` | `{fp_last_6}::{entity_slug}` ✅ verified live 2026-08-24 (`D24EAF::horizontal-bone-deficiency`) |
| `seo_website_page_master` | `{fp_last_6}::{slug}` *(corrected 2026-08-24 against live data — live values read `A943E6::myofunction-tmj`; there is no `{brand_slug}` segment)* |
| `seo_branches` | `{fp_last_6}::{branch_slug}` *(corrected 2026-08-24 against live data — live values read `AB47E2::lamlukka-khlong-2`; there is no `{brand_slug}` segment. 36 of 37 rows match exactly; the 37th, `3745F1::rangsit-klong-2`, is a stale display name left behind by a `branch_slug` rename.)* |
| `seo_doctor_assignments` | `{fp_last_6}::{role_at_brand}` *(corrected 2026-08-24 against live data — live values read `6E40BA::medical_director`; all 262 rows are fingerprint + role only, with no `{brand_slug}` or `{author_name}` segment)* |
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

Tables ready: `seo_entity_embeddings` (9 cols, HNSW index deferred) — **684 rows against 732 entities as of 2026-08-24**, so the embeddings half of the v2.0 plan is effectively populated and only the index + the guard logic are missing. *(corrected 2026-08-24 against live data — this appendix was written when the table was empty.)* Two duplicate-detection views already exist and are not mentioned anywhere in this document: `v_entity_near_duplicates` (trigram) and `v_entity_semantic_duplicates` (embedding), plus `v_keyword_near_duplicates` and `v_page_title_near_duplicates`.
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
| `seo_layer`, `seo_tier` | (does not exist — replaced by `node_tier` + `node_tier_strategy`). ⚠️ This is also the denial for the Bible Part 3.2 **L1–L7 layer system**: no layer column exists on the page master, so nothing keyed on `layer` can run. Do not re-introduce `seo_layer` — resolve layers on `page_type` per the mapping table in §11.10. *(strengthened 2026-08-23 — see the reconciliation report)* |
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
| **W11.5** | **2026-06-02** | **eywa_w11_05_dr034_v20_page_master_paa_routing** (seo_website_page_master +intent_source_tier +paa_checked_at) | **DR-034** |
| **W11.6** | **2026-06-04** | **eywa_w11_06_dr036_v21_entity_symptom** (CREATE TABLE seo_entity_symptom — 29 cols, 1:1 with entity_graph type='symptom') | **DR-036** |
| **W11.7a** | **2026-06-04** | **eywa_w11_07_doctor_assignments_notion_sync_cols** (seo_doctor_assignments +notion_id +notion_synced_at +sync_state) | **DR-006 sync gap closure** |
| **W11.7b** | **2026-06-08** | **eywa_w11_07_dr037_v22_payer_partners_canonical** (in-place ALTER seo_payer_partners → canonical Group-1 §3.9; 71 Deezy rows migrated) | **DR-037** |
| **W11.8** 🆕 | **2026-06-11** | **eywa_w11_08_dr038_v23_media_assets_canonical** (CREATE TABLE seo_media_assets — 37 cols, Group 11 NEW, PDPA gate, R2 fields) | **DR-038** |
| **W11.9** 🆕 | **2026-06-11** | **eywa_w11_09_dr038_v23_brands_cloudflare_config** (brands +4 CF cols: account_email, account_id, zone_id, r2_bucket) | **DR-038** |

---

## Appendix J — Notion Mirror Cross-Reference 🆕 (2026-06-11 addendum)

> Companion to **Bible v3.30 §18.1.2** (Multi-Workspace Notion DB IDs Reference). Maps each N↔S Supabase table to its Notion mirror DB IDs across the two operational workspaces (VT Intelligence Space + The Gifted Synapse) and documents column-level property naming conventions per workspace.

### J.1 Workspace inventory

| Workspace | Notion Workspace ID | Bot Integration | Status |
|---|---|---|---|
| **VT Intelligence Space** | `f81dc4e2-1689-816a-99dd-000319960445` | `VTVT X CLAUDE` (`36cdc4e2-...`) | 🟢 operational since v3.15 era |
| **The Gifted Synapse** | `b3bbe9c6-bf3c-8156-9f09-0003c0a8b9ff` | `GIFTED X CLAUDE` (`36dbe9c6-...`) | 🟢 operational since 2026-06-11 (greenfield canonical mirror) |

### J.2 Per-table DB IDs

| # | Supabase Table | Icon | Notion DB Name | VT Intelligence | The Gifted Synapse |
|---|---|:---:|---|---|---|
| 1 | `brands` | 🏢 | [DB 1.1] Brand Database | `2a3dc4e2-1689-80e4-926f-ecad4224f591` | `37bbe9c6-bf3c-817c-954b-e9e09c0d3f0e` |
| 2 | `seo_branches` | 🏥 | Branches Database | `67f9363b-cfc9-46fe-a0c0-f8bb5977e528` | `37bbe9c6-bf3c-81f8-984c-e916dae3793e` |
| 3 | `seo_brand_centers` | 🏨 | Brand Centers | `e5710988-c87b-45eb-9e01-d28a4059abcf` | `37bbe9c6-bf3c-813c-a96b-e88f8817337a` |
| 4 | `seo_authors_reviewers` | 👨‍⚕️ | Medical Team Database | `822cf154-651a-4e36-a932-3cb4d4e59162` | `37bbe9c6-bf3c-81be-b5f8-c3849830149d` |
| 5 | `seo_doctor_assignments` | 👥 | Doctor Assignments Database | `dfc6a0d9-a8cc-4ed0-8b73-a443673f225d` | `37bbe9c6-bf3c-81ba-9cbd-df7111af977e` |
| 6 | `seo_entity_graph` | 🧬 | Entity Graph | `42d08624-0d4c-440b-94aa-91f49c8343fa` | `37bbe9c6-bf3c-8158-9ad9-feb3b29d81c4` |
| 7 | `seo_topic_cluster_master` | 🗂️ | Topic Cluster Master | `da1fd987-f729-4f55-8dd0-11395da1d009` | `37bbe9c6-bf3c-81e5-b314-ebb9ff229216` |
| 8 | `seo_citations` | 📚 | Citations Pool | `5f73703c-234b-4743-a77b-000b83899093` | `37bbe9c6-bf3c-81c5-b513-d091f22c7721` |
| 9 | `seo_entity_relationships` | 🕸️ | Entity Relationships | `6c026bb0-e4e0-47de-b448-e4fd31839630` | `37bbe9c6-bf3c-8189-919f-e3ca2e80a043` |
| 10 | `seo_website_page_master` | 🌐 | W&SPIM | `4d316588-ff7c-4207-896e-cda45a358994` | `37bbe9c6-bf3c-81dd-92a8-ccb5ba936360` |
| 11 | `seo_editorial_reviews` | ✍️ | Editorial Reviews | `eed92b9e-f0f0-4b70-8380-9797dd438808` | `37bbe9c6-bf3c-8157-8a50-c2523930dddf` |
| 12 | `seo_page_internal_links` | 🔗 | Page Internal Links | `553c5000-84e1-429d-8715-262892649ab9` | `37bbe9c6-bf3c-81c8-9740-dccb0f432c95` |
| 13 | `seo_x_ads_keywords_contextual_master` | 🔑 | Keyword Hub | `325dc4e2-1689-80b4-ad0b-ef69e2499d0b` | `37bbe9c6-bf3c-81cf-9ad3-c98c48c70cae` |
| 14 🆕 | `seo_media_assets` | 🖼️ | Media Library (multi-brand DAM) | `656514e1-274f-4ea5-8aab-576d66858a27` | `37cbe9c6-bf3c-8130-b636-d7e1c0cf874a` |

Env-var form: `n8n-flows/notion_db_ids.the_gifted.env.template`.

> ✅ **Row 14 — the Supabase table SHIPPED** *(corrected 2026-08-24 against live schema)*. `seo_media_assets` exists in `public` with 37 columns (§13.1), built by migration `eywa_w11_08` on 2026-06-11 — the same day the ⚠️ note below was written, which is why the two disagreed. The note's "does not yet exist in the public schema — verified 2026-06-11" and its "pending action: create central DR" are **both discharged**: DR-038 is the central DR. What remains open is data, not schema: the table holds **0 rows**, so the Notion mirror has never synced an asset.

### J.3 Column-level property naming conventions

Across both workspaces, every Supabase column has a corresponding Notion property. Naming follows a consistent pattern:

| Supabase column naming | Notion property naming | Example |
|---|---|---|
| `snake_case` text | `Title Case` rich_text | `entity_slug` → `Entity Slug` |
| `<entity>_fp` text (FK fingerprint) | `<Entity> FP` rich_text | `from_entity_fp` → `From Entity FP` |
| `<entity>_fps` text[] (array FK) | `<Entity> FPs` rich_text (comma-joined OR Notion `relation` in vt_intelligence) | `related_entities_fps` → `Related Entities FPs` (the_gifted) / `Related Entities` (vt_intelligence native relation) |
| `<field>_score` numeric | `<Field> Score` number | `cluster_health_score` → `Cluster Health Score` |
| `<field>_at` timestamptz | `<Field> At` date | `notion_synced_at` → `Notion Synced At` / `Supabase Synced At` (vt_intelligence convention) |
| `is_<flag>` / `has_<flag>` boolean | `<Flag>?` or `Is <Flag>` checkbox | `is_primary` → `Is Primary`, `has_medical_review` → `Has Medical Review?` |
| `<field>` enum text (CHECK) | `<Field>` select with options matching CHECK enum verbatim | `sensitive_topic_flag` → `Sensitive Topic Flag` with `none/low/medium/high/critical` |
| `<field>` text[] enum (e.g. brand_scope) | `<Field>` multi_select with options matching CHECK enum | `brand_scope` → `Brand Scope` |
| `<field>` jsonb | `<Field>` rich_text (serialized JSON) | `compliance_profile` → `Compliance Profile` |
| `fingerprint`, `fingerprint_display_name` (DR-008) | `Fingerprint`, `Fingerprint Display Name` (the_gifted) / `Fingerprint`, `Display Name` (vt_intelligence legacy) | — |

### J.4 Structural deltas per workspace

VT Intelligence Space (older, production-era) carries:

- **Native Notion `relation` properties** binding DBs together (Brand ↔ Doctors / Branches / Doctor Assignments; Entity ↔ Pages / Keywords; Entity self-relation for Parent / Child; etc.)
- **Rollups** (e.g. Entity Graph → Related Keywords rollup from Primary Page → Target Keyword)
- **Formulas**: `Brand UUID` / `Entity UUID` (`id()`); `Notion → Supabase Needs Sync` (drift detection comparing `last_edited_time` vs `Supabase Synced At`)
- **Legacy custom fields** not in canonical schema: Brand DB → `Clarity Project ID`, `PB_Brand_ID`, `Name of Brand`, `no`, `note`; Entity Graph → `temp brand`
- **Date field convention**: `Supabase Synced At` (the_gifted side uses `Notion Synced At`)

The Gifted Synapse (greenfield canonical mirror, 2026-06-11+):

- **Text-only FP fields** for every relation (e.g. `From Entity FP`, `To Entity FP`, `Brand ID`, `Primary Entity FP`)
- **No native relations / rollups / formulas** (by design — pure flat Supabase mirror)
- **No legacy custom fields**
- **Matches Supabase CHECK enums verbatim** in select / multi_select options

### J.5 Known schema drift (non-blocking)

| # | Item | VT Intelligence | The Gifted | Live Supabase | Recommended Fix |
|---|---|---|---|---|---|
| 1 | `seo_entity_graph.entity_subtype` enum | `framework / axis / health-belief` ⚠️ | `framework / axis / general` ✅ | `chk_concept_subtype` allows `framework / axis / general` — *(confirmed 2026-08-24; §4.1 has been corrected to match. The column is NULL in all 732 rows, so no row needs migrating today)* | Sync code maps `health-belief` → `general`; OR migrate vt_intelligence rows + ALTER select options |
| 2 | Brand DB `Workspace` select | `vt_intelligence / other` | `vt_intelligence / the_gifted_synapse / other` | n/a (jsonb-only) | Add `the_gifted_synapse` to vt_intelligence Brand DB via `API-update-a-data-source` |
| 3 | Entity Graph drift-detection symmetry | has `Supabase Synced At` (date) + `Notion → Supabase Needs Sync` (formula) | missing both | n/a (computed in Notion) | Add equivalent date + formula to the_gifted Entity Graph |

### J.6 Phase-1 vs Phase-2 sync compatibility

Per Bible §18.8.2 Two-Phase Hierarchy Sync Pattern:

| Phase | Action | The Gifted | VT Intelligence | Notes |
|---|---|---|---|---|
| **1 — Flat load** | Supabase row → Notion page; write text-based FP fields | ✅ identical | ✅ identical | Same payload works for both workspaces (after property-name remap via J.3 table) |
| **2 — Relation backfill** | Resolve text FP → native Notion relation | ⏭️ N/A by design | ✅ required (Brand ↔ Doctors, Entity ↔ Pages, etc.) | Conditional logic in n8n: skip Phase 2 for `workspace == 'the_gifted_synapse'` |
| **Drift repair (cron)** | Compare Notion vs Supabase, repair stale fields | requires symmetric setup (J.5 item #3) | ✅ uses `Notion → Supabase Needs Sync` formula | Until J.5 #3 fixes, the_gifted relies on flat re-sync rather than incremental drift repair |

### J.7 Connection requirements per workspace

Each integration bot must be explicitly connected to each Notion DB before R/W access is granted (Notion native permission model):

- **VT Intelligence Space**: All 13 DBs already connected to `VTVT X CLAUDE` (legacy)
- **The Gifted Synapse**: All 13 DBs already connected to `GIFTED X CLAUDE` (inherits from `🕸️ Knowledge Graph` parent page sharing performed 2026-06-10)

When onboarding new team workspaces per Bible §18.7.8, the connection step must be repeated per DB OR inherited via parent-page sharing.

### J.8 Cross-references

- **Bible §18.1** — Multi-Workspace Notion DB IDs Reference (canonical IDs)
- **Bible §18.7** — Multi-Workspace Sync Strategy (Federation)
- **Bible §18.7.5a** — Dynamic Token Implementation Pattern
- **Bible §18.7.5b** — Operational State (env vars, workspace selection)
- **Bible §18.8** — Two-Phase Hierarchy Sync Pattern
- **`n8n-flows/notion_db_ids.the_gifted.env.template`** — env vars source-of-truth
- **`n8n-flows/create_notion_dbs_the_gifted.sh`** — reusable creation script (used to bootstrap the_gifted DBs; pattern repeatable for new workspaces)
- **`n8n-flows/supabase-to-notion__entity-graph.json`** — Phase 1 flat sync reference workflow

---

**END OF SCHEMA OVERVIEW v1.19**

> Generated 2026-05-30 from full audit against live Supabase project `lffcbeszjqzioobqfdav` (v1.18); v1.19 delta (DR-033, W11.4) verified live 2026-06-02. Cross-referenced against DECISION_RECORDS.md (DR-001 through DR-033), Bible v3.19, and Handover v1.18.
>
> **Column-level re-verification 2026-08-24** against the same live project via the PostgREST OpenAPI schema + live row queries: all 43 EYWA tables confirmed present, 18 documented column counts corrected, 4 fingerprint prefixes corrected, and ~25 allowed-value lists replaced with the values actually in the data. Corrections carry an inline dated marker. **Not covered:** CHECK constraint bodies, trigger existence, index lists, RLS policies and partition layout — PostgREST cannot read them, so every such statement in this document still dates from 2026-05-30.
>
> For schema corrections: file an issue in the spec repo or amend via DR-NNN process. Direct edits to this document without a DR are discouraged (the doc is meant to mirror live DB; live DB is the source of truth, this doc is the human-readable index).



