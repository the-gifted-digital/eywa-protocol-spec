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
