# EYWA Migrations — Phase 1A Build (2026-05-12)

> Applied to Supabase project **GTGT** (`lffcbeszjqzioobqfdav`) via MCP `apply_migration`.
> Source of truth: Supabase `supabase_migrations.schema_migrations` table.
> This README provides the manifest + dependency order for reference.

## Scope

Phase 1A baseline complete: **39 EYWA tables across 9 groups** (per Schema v1.15) — all RLS-enabled with permissive `authenticated_full_access` policy.

## Wave Order + Migrations Applied

### Wave 0a — Foundation Setup (2 migrations)
1. `eywa_w0a_01_enable_extensions.sql` — `pg_trgm`, `vector`, `postgis`
2. `eywa_w0a_02_rls_enable_and_permissive_policies.sql` — RLS + `eywa_authenticated_full_access` policy on 12 legacy tables (skipped `wrappers_fdw_stats` system table)

### Wave 0c — ALTER existing tables (3 migrations)
3. `eywa_w0c_01_entity_graph_dr014_subtype.sql` — DR-014: `entity_subtype` column + `chk_concept_subtype` CHECK
4. `eywa_w0c_02_page_master_dr015_016_017_021_026.sql` — 17 column additions:
   - DR-015 (2): `marketplace_proposal_status`, `reconciliation_notes`
   - DR-016 (1): `viability_assessment jsonb`
   - DR-017 (1): `content_brief`
   - DR-021 (5): `authority_weight`, `link_equity_score`, `orphan_risk_score`, `crawl_depth`, `node_tier_strategy`
   - DR-026 (6): `page_purpose`, `ads_template_id`, `index_directive`, `conversion_event_primary`, `conversion_event_secondary`, `campaign_id`
   - + 5 partial indexes + CHECK constraints
5. `eywa_w0c_03_keywords_dr026_ads_track.sql` — DR-026: 6 columns on `seo_x_ads_keywords_contextual_master` (`seo_active`, `ad_active`, `ad_intent_score`, `ad_match_type_preferred`, `ad_landing_page_fp`, `ad_priority_tier`) + 4 partial indexes

### Wave 1 — Group 2 Knowledge Architecture (4 migrations)
6. `eywa_w1_01_seo_topic_cluster_master.sql` — SKOS topical/format/audience/section_meta cluster master
7. `eywa_w1_02_seo_citations.sql` — Academic citation pool (PubMed/DOI/guidelines), 6-tier hierarchy
8. `eywa_w1_03_seo_page_citations.sql` — Junction page ↔ citation (M:N)
9. `eywa_w1_04_seo_entity_relationships_dr013.sql` — DR-013: 12-edge vocab + evidence FK + 2 validation triggers (medical signoff for contraindications)

### Wave 2 — Group 9 Entity Extensions (3 migrations, 10 tables)
10. `eywa_w2_01_ingredients_devices_procedures.sql` — Pre-DR-024 extensions: `seo_entity_ingredients`, `seo_entity_devices`, `seo_entity_procedures`
11. `eywa_w2_02_product_condition_drug.sql` — DR-024: `seo_entity_product`, `seo_entity_condition` (T1 binding), `seo_entity_drug`
12. `eywa_w2_03_anatomy_organization_lab_test.sql` — DR-024: `seo_entity_anatomy`, `seo_entity_organization`, `seo_entity_lab_test`, + `seo_programmatic_templates` (renumbered §11.10)

### Wave 3 — Group 1 Brand & Local SEO (4 migrations, 6 tables + 1 prep)
13. `eywa_w3_00_brands_add_unique_id.sql` — Preflight: ADD UNIQUE on `brands.id` (legacy PK was on `brand_name`) so FKs work
14. `eywa_w3_01_authors_reviewers_doctor_assignments.sql` — `seo_authors_reviewers` + `seo_doctor_assignments`
15. `eywa_w3_02_seo_branches_full_dr025.sql` — `seo_branches` ~40 cols (Local SEO master per DR-025) + PostGIS geo trigger
16. `eywa_w3_03_reviews_directory_gbp_posts.sql` — DR-025: `seo_reviews` (PDPA workflow), `seo_directory_listings` (NAP audit, GENERATED `nap_match_score`/`has_inconsistency`), `seo_gbp_posts` (with `engagement_rate` GENERATED)

### Wave 4 — Group 3 Page System (1 migration, 2 tables)
17. `eywa_w4_01_page_internal_links_editorial_reviews.sql` — DR-021: `seo_page_internal_links` (~22 cols + auto-reciprocal trigger) + `seo_editorial_reviews`

### Wave 5 — Group 4 Keyword & Search (1 migration, 1 new table)
18. `eywa_w5_01_voice_search.sql` — `seo_x_voice_search`
    *(existing tables in Group 4: `seo_x_ads_keywords_contextual_master`, `seo_x_ads_keywords_monthly_market_snapshot`, `seo_x_ads_keyword_serp_competitors` — already in production)*

### Wave 6 — Group 5 Performance Facts (1 migration, 1 new table)
19. `eywa_w6_01_local_rankings.sql` — `seo_local_rankings` with branch_id FK + GENERATED `is_in_local_pack_three` + `position_change`
    *(existing: `seo_x_ads_keywords_x_url_daily_logs` + 2 partitions logs_2025/logs_2026)*

### Wave 7 — Groups 6/7/8 (2 migrations, 6 new tables)
20. `eywa_w7_01_ai_operations_group7.sql` — `seo_brand_mentions`, `seo_llm_citations`, `seo_llm_query_simulations`, `seo_entity_embeddings` (pgvector, HNSW deferred)
21. `eywa_w7_02_governance_group8.sql` — `seo_data_quality_metrics`, `seo_schema_changes`
    *(Group 6 backlinks `seo_backlinks_data` + `seo_backlinks_links` — already in production from earlier work)*

### Wave 10 — DR-008 propagation (3 migrations)
25. `eywa_w10_01_dr008_entity_graph_page_master_setup.sql` — ADD nullable `fingerprint` + `fingerprint_display_name` on `seo_entity_graph` + `seo_website_page_master`; CREATE 4 trigger fns (set + refresh × 2 tables)
26. *(execute_sql backfill)* — 466 entity rows + 1,376 page rows assigned `ent_{ULID16}` / `page_{ULID16}` fingerprints
27. `eywa_w10_02_dr008_finalize_entity_graph_page_master.sql` — NOT NULL + UNIQUE + CHECK format + 6 triggers attached (set/prevent/refresh × 2 tables) + 2 indexes; legacy `entity_fingerprint`/`page_fingerprint` cols preserved per v1.9 Transition State
28. `eywa_w10_03_dr008_generic_triggers_new_tables.sql` — Generic `fn_set_fingerprint_generic(prefix, slug_col, name_col)` (hstore-based) + attached to 17 new tables (Groups 1/2/3/4/7/9); each gets table-specific prefix (clst/cite/erel/auth/docasg/brch/rev/dirl/gbpp/pil/edrv/vsr/bmnt/llmc/lqs/tmpl) + reuses generic `fn_prevent_fingerprint_change`. Test verified: INSERT without fingerprint auto-sets with correct prefix + display_name.

### Wave 9 — Remove Notion FDW + wrappers extension (1 migration, operator decision 2026-05-12)
24. `eywa_w9_01_remove_notion_fdw_wrappers.sql` — Clean removal:
    - `DROP SCHEMA notion_vt_intelligence_space CASCADE` (removes 2 foreign tables: databases, pages)
    - `DROP SERVER notion_server_vt_intelligence_space CASCADE`
    - `DROP EXTENSION wrappers CASCADE` (removes wasm_wrapper FDW + wrappers_fdw_stats system table)
    - Rationale: Notion sync fully via n8n; FDW had 7 invocations across 2 months = vestigial. No views/functions depended on it.
    - Reversibility: re-install via original `setup_notion_wrapper_workspace_a_v2` migration (~5 min)

### Wave 8 — DR-008 brands Two-Column Identity (2 migrations)
22. `eywa_w8_01_dr008_brands_two_column_identity_setup.sql` — ADD 3 cols (`fingerprint`, `fingerprint_display_name`, `brand_slug`) + 5 helper functions:
    - `generate_ulid16()` — 16-char hex identifier
    - `slugify(text)` — kebab-case slug from arbitrary text
    - `fn_set_fingerprint_brand()` — INSERT trigger fn (auto-set fingerprint/slug/display_name)
    - `fn_prevent_fingerprint_change()` — UPDATE trigger fn (immutability enforcement)
    - `fn_refresh_display_name_brand()` — UPDATE trigger fn (auto-refresh on brand_name/slug change)
    - Backfill of 15 existing brand rows via `execute_sql` (between migrations 01 and 02)
23. `eywa_w8_02_dr008_brands_finalize.sql` — NOT NULL + UNIQUE + CHECK constraints + 3 triggers attached + 2 indexes
    - Verification tests passed: ✅ fingerprint immutability rejected forbidden UPDATE; ✅ brand_name change → brand_slug + display_name auto-refresh; ✅ all 15 backfilled rows have valid `brnd_{16hex}` format

**Note on PK migration:** brands.brand_name retains its PK status for backwards compatibility with legacy FK references. The `id` column has UNIQUE constraint (from Wave 3 preflight), and `fingerprint` now has UNIQUE constraint. Future migration could DROP PK on brand_name + ADD PK on id when legacy FK references have all migrated.

### Wave 11 — Post-Phase-1B DR builds (6 migrations)
24. `eywa_w11_01_dr030_v17_sensitive_topic_compliance` (2026-05-27) — DR-030: Product×Content tier-matrix columns + `compliance_max_tier` generated col + `positioning_mode`. → Schema v1.17
25. `eywa_w11_02_dr032_v18_multi_center_hospital` (2026-05-27) — DR-032: `seo_brand_centers` table + `center_scope`/`center_slug` cols + `brand_structure` enum. → Schema v1.18
26. `eywa_w11_03_brand_centers_notion_sync_cols` (2026-05-29) — DR-032 follow-up: `notion_id`/`notion_synced_at`/`sync_state` on `seo_brand_centers`.
27. `eywa_w11_04_dr033_v19_icd_dual_coding_condition` (2026-06-02) — DR-033: `seo_entity_condition` +`icd11_code` (ICD-11-MMS) +`icd10_cm_code` (US ICD-10-CM) + `icd10_code` comment. Additive/nullable; **not** in fingerprint. → Schema v1.19
28. `eywa_w11_05_dr034_v20_page_master_paa_routing` (2026-06-03) — DR-034: `seo_website_page_master` +`intent_source_tier` (text, CHECK paa/derived/template_only, DEFAULT template_only) +`paa_checked_at` (timestamptz) + CHECK + comments. Additive; 1,376 rows default-backfilled to `template_only`; **not** in fingerprint. → Schema v1.20
29. `eywa_w11_06_dr036_v21_entity_symptom` (2026-06-04) — DR-036: new Group-9 extension `seo_entity_symptom` (29 cols; 1:1 with `seo_entity_graph` `entity_type='symptom'`; `entity_fp` FK → `entity_fingerprint` ON DELETE CASCADE; 2 CHECKs severity/onset; RLS `eywa_authenticated_full_access`). Splits `symptom` out of `condition` per Bible §25.3. Additive `CREATE TABLE` + policy, no data. → Schema v1.21

> Source of truth = Supabase `schema_migrations`. This Wave 11 block catches the manifest up from the Phase-1A snapshot below.

## Final State

```
EYWA tables built:           39 / 39 (per Schema v1.15 spec)
RLS enabled:                 41 / 42  (only wrappers_fdw_stats — Supabase system — skipped)
Indexes created:             ~70 (partial + GIN + GiST + composite)
Triggers/functions created:  4 (geo_point sync, reciprocal link, edge evidence validation, medical signoff)
CHECK constraints:           ~60 (controlled vocab + range + mutually-exclusive)
GENERATED columns:           5 (nap_match_score, has_inconsistency, engagement_rate, is_in_local_pack_three, position_change, price_per_unit)
```

## DR Implementation Coverage

| DR | Status | Implemented in |
|----|--------|----------------|
| DR-001..DR-012 | Locked (pre-existing) | n/a |
| DR-013 | Locked 2026-05-12 | `eywa_w1_04` (entity_relationships + triggers) |
| DR-014 | Locked 2026-05-12 | `eywa_w0c_01` (entity_subtype CHECK) |
| DR-015..DR-018 | Locked | `eywa_w0c_02` (page_master columns) |
| DR-019 | Locked 2026-05-12 | Schema emission strategy (no DDL — content rules) |
| DR-020 | Locked 2026-05-12 | Content_Templates v1.5 (no DDL) |
| DR-021 | Locked 2026-05-12 | `eywa_w0c_02` + `eywa_w4_01` (cols + page_internal_links) |
| DR-022 | Locked 2026-05-12 | Process/workflow (no DDL) |
| DR-023 | Claimed | (External link tracking — future) |
| DR-024 | Locked 2026-05-12 | `eywa_w2_01` + `eywa_w2_02` + `eywa_w2_03` (9 extensions) |
| DR-025 | Locked 2026-05-12 | `eywa_w3_02` + `eywa_w3_03` (branches + Local SEO children) |
| DR-026 | Proposed (lock target 2026-06-21) | `eywa_w0c_02` + `eywa_w0c_03` (column additions) |
| DR-027 | Reserved | (seo_campaigns Phase 1 — future) |
| DR-030 | Locked 2026-05-20 | `eywa_w11_01` (sensitive topic compliance) |
| DR-032 | Locked 2026-05-25 | `eywa_w11_02` + `eywa_w11_03` (multi-center hospital) |
| DR-033 | Locked 2026-06-02 | `eywa_w11_04` (ICD dual-coding on `seo_entity_condition`) |
| DR-034 | Locked 2026-06-03 | `eywa_w11_05` (PAA × FAQ intent routing on `seo_website_page_master`) |
| DR-036 | Locked 2026-06-04 | `eywa_w11_06_dr036_v21_entity_symptom` (additive `seo_entity_symptom`, 29 cols, Group 9) |

## Outstanding Items

### Security
- ⚠️ `wrappers_fdw_stats` RLS disabled — **Supabase system table managed by `wrappers` extension**. Enabling RLS here may break Foreign Data Wrapper functionality. Recommend leaving as-is unless wrappers usage stops.

### Schema Refinements (Future)
- ~~**brands DR-008 full migration**~~ ✅ Completed in Wave 8 (2026-05-12). PK still on `brand_name` for legacy FK compat; full PK migration to `id` deferred until legacy FKs migrated.
- **HNSW index on seo_entity_embeddings** — defer until bulk-loaded with embeddings.
- **Partition strategy for seo_local_rankings** — when growth approaches >10M rows, partition by `snapshot_at` (monthly), similar to daily_logs.
- **seo_x_ads_keywords_x_url_daily_logs schema audit** — table exists with 0 rows in main + 90k in `logs_2026` partition. Verify columns match Schema v1.15 §7.1 (~130 cols spec).
- **DR-008 propagation to other tables** — Apply Two-Column Identity pattern (fingerprint+display_name+slug) to remaining tables that don't yet have it: `seo_entity_graph` uses legacy `entity_fingerprint` format (slug-based, e.g., `entity:slug`); should migrate to `ent_{ULID16}` per spec. Same for `seo_website_page_master.page_fingerprint`.

### Notion Sync (n8n)
- Tables in N↔S sync pattern (per Schema v1.15 §2 sync direction) need n8n flows wired up:
  - Group 1 (brands, branches, authors, doctor_assignments) — N↔S master
  - Group 1 (reviews, directory_listings, gbp_posts) — S-only via Flow E1/E2/E3/E4
  - Group 2 (5 tables) — N↔S
  - Group 3 (3 tables) — N↔S
  - Group 9 (10 tables) — N↔S
- Reviews/Backlinks/AI Ops/Governance — S only (no Notion mirror)

## Verification

```sql
-- Quick verification: count tables per group via COMMENT prefix
SELECT
  substring(obj_description(c.oid, 'pg_class') FROM 'Group \d+') AS group_label,
  count(*) AS table_count
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND obj_description(c.oid, 'pg_class') LIKE 'Group %'
GROUP BY group_label
ORDER BY group_label;
```
