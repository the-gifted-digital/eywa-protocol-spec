# EYWA™ Protocol — Phase 1 Decisions Summary

**Document Version**: 1.9
**Date**: 2026-05-12 PM
**Status**: 🏗️ Phase 1A BUILD COMPLETE — **43** EYWA canonical tables live in GTGT *(corrected 2026-08-24 against live schema: "39" was the 2026-05-12 build snapshot per Schema v1.15; live count is 43, matching Schema Overview v1.23's "43 EYWA canonical tables". **Not** the README's figure — the README row counts a different scope, every non-backup base table in `public`, which also sweeps in the non-EYWA `fbads_*` / `tsa_*` / `web_lead` / `ss_kw_seed_*` tables and so lands near 57; the two totals are not comparable. Do not hardcode — the count is `brands` + `seo_*` in the OpenAPI definitions at `GET /rest/v1/`, excluding `_`-prefixed scratch, `*_bak*`/`*backup*` and `*_20YYMMDD` snapshots and `v_` views)*. 🔒 Locked DRs: 013/014/015..018/019/020/021/022/024/025/008 propagated. 🌱 DR-026 Proposed — 🔴 **DORMANT**: the 2026-06-21 lock target passed without a lock and `ad_active` is false on all 22,710 keyword rows *(corrected 2026-08-24 against live schema; DR-057)*. 🔮 DR-027 Reserved (Future Phase 1).
**Phase**: 1 — Supabase Database Foundation **(1A complete; 1B = n8n flow wire-up next)**
**Project**: GTGT (in-place upgrade)
**Companion to**: Bible v3.34 + Schema Overview v1.23 + Handover v1.19 + DECISION_RECORDS v1.37 (DR-001..DR-058) + Content_Templates_EYWA_v1_0.md v1.9 (LOCKED per DR-020) + `migrations/README.md` *(companion versions corrected 2026-08-24 — every one of the five was stale)*

---

## 🎯 Strategic Decisions

### DR-007: In-Place GTGT Upgrade

**Decision**: Upgrade existing GTGT Supabase project schema to align with Bible v3.12 / Schema v1.8, **without splitting into multiple projects**.

**Rationale**:
- 30 existing migrations show working in-place evolution discipline
- 6 active n8n workflows in production
- Solo developer scale (15 brands) doesn't justify multi-project overhead *(corrected 2026-08-24 against live schema: `select count(*) from brands` = 20 rows today, one of which is `w-test-brand`; only 3 carry page rows — deezy-dental 869, vth-biodent 761, smile-scape-clinic 728)*
- Cost-effective ($0 additional infrastructure)
- Existing keyword pipeline (25K+ rows) preserved without disruption *(corrected 2026-08-24 against live schema: `seo_x_ads_keywords_contextual_master` holds 22,710 rows across 8 brands, not 25K+)*

**Out of Scope**:
- Data migration (existing entity/page data may be discarded — handled by other projects)
- n8n workflow rewrites (will adapt later if needed)
- Notion database restructure (handled separately)

**In Scope**:
- Schema upgrade only
- New tables creation
- New columns addition
- Triggers, functions, indexes

---

### DR-008: Two-Column Identity Pattern

**Decision**: Every table (except `seo_x_ads_keywords_contextual_master`) has TWO identity columns: *(corrected 2026-08-24 against live schema — 🔴 the "every table, one exception" claim is far from what shipped. Of the 43 canonical tables: **22 carry both** columns, **6 carry `fingerprint` only** and no display name (`seo_x_ads_keywords_contextual_master`, `…_monthly_market_snapshot`, `…_x_url_daily_logs`, `seo_x_ads_keyword_serp_competitors`, `seo_backlinks_data`, `seo_backlinks_links`), and **15 carry neither** — the 10 Group-9 entity extension tables plus `seo_entity_embeddings`, which key 1:1 on `entity_fp`, and `seo_page_citations` (`page_fp` + `citation_fp`), `seo_local_rankings` (`keyword_fp`), `seo_data_quality_metrics` and `seo_schema_changes` (uuid `id` only). Re-run the audit as: for each `brands`/`seo_*` OpenAPI definition, test for the two property names.)*

| Column | Type | Mutability | Purpose |
|--------|------|------------|---------|
| `fingerprint` | text UNIQUE | IMMUTABLE | Machine identity, used for FK/joins |
| `fingerprint_display_name` | text | MUTABLE | Human label, debug aid |

**Format**: *(corrected 2026-08-24 against live schema — the shipped generator is `generate_ulid16()`, which returns 16 UPPERCASE HEX characters, not a ULID)*
- `fingerprint`: `{tablecode}_{ULID16}` — Pattern B
  - Example: `ent_01HZP5K2XQR7N3MF` → live example `ent_01C203B7098F4047`, `page_0017783949AA4A39`, `brnd_2ADC0BB0585F45CF`
  - 16 characters of ULID (time-sortable, 80-bit entropy) → 🔴 **not what shipped**: all 3,090 live entity + page fingerprints are 16 chars drawn from `[0-9A-F]` only = **64 bits, hex, and NOT time-sortable** (sorting page fingerprints does not reproduce `created_at` order). The `_{ULID16}` suffix in the name is historical
  - Compact yet collision-safe
- `fingerprint_display_name`: `{fp_last_6}::{type}::{slug}::{key_data}`
  - Example: `N3MF::condition::sleep-apnea::G47.3` → 🔴 the 4-part form never shipped: live column comments give `{fp_last_6}::{entity_slug}` for `seo_entity_graph` and `{fp_last_6}::{slug}` for `seo_website_page_master` *(corrected 2026-08-24 against live schema)*
  - First 6 chars = last 6 of fingerprint (cross-check)
  - `::` (double colon) separator
  - Auto-refreshed when source data changes

**Exception**: `seo_x_ads_keywords_contextual_master` keeps existing fingerprint format `{brand}::{market}::{language}::{keyword}` because it's already self-documenting and immutable. *(verified 2026-08-24 against live data — this one is right: live values look like `deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::ยกไซนัส`, and the generator `generate_fingerprint(p_brand, p_target_market, p_target_language, p_keyword)` is live as an RPC.)*

**Rationale**:
- Stable machine identity prevents broken relations on rename
- Human-readable label enables debugging and data validation
- Last-6-of-fingerprint in display creates double cross-check
- ULID provides time-ordering benefit for free — 🔴 **this benefit was never obtained**: the shipped identifier is random hex, so fingerprints carry no time order *(corrected 2026-08-24 against live data)*

---

### DR-009: Multilingual Strategy

**Decision**: Two-tier multilingual handling based on table type.

#### Concept Tables (1 row + jsonb translations)

Tables where the entity itself is universal but has multiple language labels:

*(table names + jsonb reality corrected 2026-08-24 against live schema — three of these seven names do not exist, and only one table carries the full jsonb trio)*

- `ent::seo_entity_graph` — 🔴 has `aliases` as **plain `text`**, and has NO `canonical_names` and NO `descriptions`. Its language labels live in `entity_name` + comma/line-separated `aliases`
- `clus::seo_topic_cluster_master` — ✅ the only table with all three as `jsonb` (`canonical_names`, `aliases`, `descriptions`)
- `brnd::brands` — 🔴 has none of the three; brand labels are flat `brand_name` + `brand_slug`
- `auth::seo_authors` → **`seo_authors_reviewers`** (`seo_authors` has never existed) — has `canonical_names jsonb`, no `aliases`, no `descriptions`
- `doc::seo_brand_doctors` → **`seo_doctor_assignments`** (`seo_brand_doctors` has never existed) — 🔴 none of the three
- `brch::seo_brand_branches` → **`seo_branches`** (`seo_brand_branches` has never existed) — has `canonical_names jsonb` only
- `cite::seo_citations` — 🔴 none of the three

**Pattern**:
```jsonb
canonical_names: {"en": "Sleep Apnea", "th": "ภาวะหยุดหายใจขณะหลับ"}
aliases: {
  "en": ["sleep apnea syndrome", "OSA"],
  "th": ["หยุดหายใจตอนนอน", "นอนกรนแบบรุนแรง"]
}
```
*(the jsonb `aliases` shape above is real only in `seo_topic_cluster_master`; in `seo_entity_graph` — the table anyone actually reaches for — `aliases` is a text blob and this shape will not parse. Corrected 2026-08-24 against live schema.)*

#### Content Tables (1 row per language + translation_group_id)

Tables where each language version is a separate content asset:

- `page::seo_website_page_master`
- `kw::seo_x_ads_keywords_contextual_master` (existing `translation_group`) — column exists, but 🔴 it is NULL in all 22,710 rows and has never been written *(corrected 2026-08-24 against live data)*
- `rev::seo_editorial_reviews` — 🔴 carries no language or translation column at all; it cannot participate in this pattern *(corrected 2026-08-24 against live schema)*

**Pattern**: *(corrected 2026-08-24 against live schema — the grouping column named here was never built)*
- Each language = separate row with unique fingerprint
- All translations share `translation_group_id` (e.g., `tg_01HZP5K2X...`) — 🔴 **no `translation_group_id` column exists on any table.** What shipped on `seo_website_page_master` is the pair `translations_versions_fps text[]` (the sibling language rows) + `source_translation_fp` (the row this was translated from); `page_language` holds the ISO code
- One row marked `is_source_page = true` (canonical) — live and consistent: 36 rows true, each with a populated `translations_versions_fps`, against 72 rows carrying `source_translation_fp` — which is exactly the non-Thai half of the table, since `page_language` across all 2,358 rows is th 2,286 / en 36 / zh-cn 36 as of 2026-08-24. Note the live column comment describes `is_source_page` as the cluster authority hub instead — the data follows this DR, the comment does not
- Other rows reference source via `source_translation_fp`

**Translation Group ID Format**: `tg_{ULID16}` (tg = translation group, separate namespace) — 🔴 unimplementable as written: no such column and no `tg_` fingerprint namespace exists in the live database *(corrected 2026-08-24 against live schema)*

---

### DR-010: Brand Scope Architecture

**Decision**: Standardize brand association via `brand_scope text[]` column.

**Pattern**:
- Single brand: `['vth-biodent']`
- Universal: `['*']`
- Shared: `['vth-biodent', 'vitalsleep', 'the-face-hospital']`

**brand_slug** is canonical reference (immutable, lowercase, kebab-case).

**Tables Using brand_scope[]**: *(corrected 2026-08-24 against live schema)*
- `seo_entity_graph` (shared across brands)
- `seo_topic_cluster_master` (shared)
- `seo_authors` (may write for multiple brands) → **`seo_authors_reviewers`**
- also live with `brand_scope text[]`, not listed here: `seo_citations`, `seo_entity_relationships` and `seo_page_internal_links`. That is the complete live set — six tables carry `brand_scope`, and no other canonical table does

**Tables Using brand_slug (single)**: *(corrected 2026-08-24 against live schema — none of these three uses a column named `brand_slug`)*
- `seo_website_page_master` (page belongs to 1 brand site) → column is **`brand_id text`**, and it holds the SLUG (`deezy-dental` / `vth-biodent` / `smile-scape-clinic`), not a uuid
- `seo_brand_doctors` (doctor licensed to 1 clinic) → **`seo_doctor_assignments`**, column **`brand_id uuid`** (a real uuid here, unlike page_master)
- `seo_brand_branches` (branch belongs to 1 brand) → **`seo_branches`**, which carries BOTH `brand_id uuid` and `brand_slug text`
- `brands` itself is the only other table with a `brand_slug` column

---

## 📐 Naming Conventions

### Table Codes (3-4 letters)

| Code | Table | Type |
|------|-------|------|
| `ent` | seo_entity_graph | Concept |
| `page` | seo_website_page_master | Content (multilang) |
| `clus` → live **`clst`** | seo_topic_cluster_master | Concept |
| `kw` | seo_x_ads_keywords_contextual_master | Existing (no migration) |
| `brnd` | brands | Concept |
| `auth` | ~~seo_authors~~ → **seo_authors_reviewers** | Concept |
| `doc` → live **`docasg`** | ~~seo_brand_doctors~~ → **seo_doctor_assignments** | Concept |
| `brch` | ~~seo_brand_branches~~ → **seo_branches** | Concept |
| `cite` | seo_citations | Concept |
| `pcit` — 🔴 unused | seo_page_citations | Junction (no fingerprint column at all) |
| `rev` → live **`edrv`** (47 legacy `rev_` rows remain) | seo_editorial_reviews | Content |
| `aici` — 🔴 code never used | ~~seo_ai_citation_tracking~~ → **seo_llm_citations** (built, 0 rows) | Time-series |
| `asc` — 🔴 UNIMPLEMENTABLE | ~~seo_brand_authority_scores~~ — table does not exist | Score |
| `chs` — 🔴 UNIMPLEMENTABLE | ~~seo_cluster_health_scores~~ — table does not exist | Score |
| `eas` — 🔴 UNIMPLEMENTABLE | ~~seo_entity_authority_scores~~ — table does not exist | Score |
| `eeat` — 🔴 UNIMPLEMENTABLE | ~~seo_eeat_scores~~ — table does not exist | Score |
| `gov` — 🔴 UNIMPLEMENTABLE | ~~seo_governance_audit~~ — table does not exist | Audit |
| `kpi` — 🔴 UNIMPLEMENTABLE | ~~seo_kpi_baseline~~ — table does not exist | KPI |
| `tg` — 🔴 UNIMPLEMENTABLE | (translation group, namespace only) — no `tg_` fingerprint exists | N/A |

*(whole table corrected 2026-08-24 against live fingerprint prefixes — read as `select distinct split_part(fingerprint,'_',1)` per table. Six of the tables listed — `asc`/`chs`/`eas`/`eeat`/`gov`/`kpi` — were never built, so those codes cannot fire; the rows are kept so nobody re-issues the same code.)*

**Live prefixes this table omits** *(added 2026-08-24 against live data)*: `erel` seo_entity_relationships (5 legacy `erl_`) · `pil` seo_page_internal_links (83 legacy `lnk_`) · `payp` seo_payer_partners · `tmpl` seo_programmatic_templates · `ctr` seo_brand_centers · `mda` seo_media_assets (documented in Schema Overview v1.23; both post-date Wave 10, both tables empty).

⚠️ **Do not copy a prefix for the empty tables out of either document — they disagree.** `migrations/README.md` Wave 10 lists `dirl` / `gbpp` / `vsr` / `bmnt` / `llmc` / `lqs`; Schema Overview v1.23's per-table fingerprint registry lists `dirlist_` / `gbppost_` / `vsrch_` / `bmen_` / `llmc_` / `llmq_` for the same six tables, and adds `rev_` for `seo_reviews` — which is also the legacy prefix sitting on 47 `seo_editorial_reviews` rows. Only `llmc` agrees across the two. Every one of these tables holds 0 rows, so PostgREST cannot settle it; the prefix is whatever `fn_set_fingerprint_generic` was handed at creation, and that needs a `pg_proc`/`pg_trigger` read. `seo_backlinks_data` and `seo_backlinks_links` carry `fingerprint` but predate DR-008 (Group 6, pre-existing) and appear in neither registry. *(conflict recorded 2026-08-24)*

---

## 🔧 Technical Specifications

### ULID Generation

**Method**: Pure SQL function (no extensions, Postgres 17 compatible)

**Function**: `generate_ulid()` returns 16-character Crockford Base32 string — 🔴 **wrong on both counts.** The live function is **`generate_ulid16()`**, and its own DB comment calls it a *"16-char hex identifier"*. There is no `generate_ulid()` in the database *(corrected 2026-08-24 against the live RPC list at `GET /rest/v1/`)*

**Properties**: *(🔴 none of the four survived — the shipped generator emits random hex, so this whole block describes a ULID that was never built. Corrected 2026-08-24 against live data.)*
- 48-bit timestamp prefix (millisecond precision) — 🔴 no timestamp prefix
- 80-bit random suffix — 🔴 64 bits (16 hex chars)
- Lexicographically sortable — sortable, but see below
- Time-ordered for INSERT performance — 🔴 not time-ordered; page fingerprints sorted lexicographically do not reproduce `created_at` order

### Fingerprint Generator

```sql
generate_fingerprint_v2(p_tablecode text)
RETURNS: '{tablecode}_{ULID16}'
```
🔴 *(corrected 2026-08-24 against the live RPC list)* — **`generate_fingerprint_v2` does not exist.** Two things do, and neither has this signature:
- `generate_ulid16()` — the 16-hex body, called from per-table BEFORE INSERT trigger functions that prepend the table code (`fn_set_fingerprint_generic(prefix, slug_col, name_col)` per `migrations/README.md` Wave 10)
- `generate_fingerprint(p_brand, p_target_market, p_target_language, p_keyword)` — the KEYWORD fingerprint builder, unrelated to the `{tablecode}_` pattern

### Display Name Generators

Per-table functions: 🔴 *(corrected 2026-08-24 — not one of these four names exists in the database.)* Display names are refreshed by trigger functions in the `fn_refresh_display_name_*` family (e.g. `fn_refresh_display_name_brand()`), which PostgREST does not expose because they return `trigger`; the only display-name helper reachable as an RPC is `slugify(input text)`. Verify the rest against `pg_proc`, not against this list.
- `generate_entity_display_name()` — entity formula
- `generate_page_display_name()` — page formula
- `generate_brand_display_name()` — brand formula
- `generate_cluster_display_name()` — cluster formula
- (etc., one per table type)

### Trigger Pattern

Each table gets: *(**unverified** as of 2026-08-24 — trigger existence is not reachable through PostgREST, so nothing here could be checked against the live database. Note "each table" is at best 22 of 43 regardless, since the other 21 have no fingerprint column to trigger on. Confirm against `pg_trigger` before relying on it.)*
1. **BEFORE INSERT trigger** → auto-generate fingerprint + display_name
2. **BEFORE UPDATE trigger** → prevent fingerprint mutation, refresh display_name
3. **AFTER INSERT/UPDATE trigger** → cross-table updates if needed

---

## 🚫 Out of Scope (Phase 1)

The following are **explicitly NOT** part of Phase 1:

1. **Data migration** — existing entity/page data may be discarded
2. **n8n workflow rewrites** — will adapt later if compatibility breaks
3. **Notion database restructure** — handled separately
4. **WordPress integration** — Phase 3+
5. **Performance dashboards** — Phase 4+
6. **EEAT scoring implementation** — Phase 3+ *(still true 2026-08-24: no `seo_eeat_scores` table exists)*
7. **AI citation tracking** — Phase 3+ *(corrected 2026-08-24 against live schema: the TABLE shipped inside Phase 1A after all — `seo_llm_citations`, plus `seo_llm_query_simulations` and `seo_brand_mentions`, built in Wave 7. All three hold 0 rows, so the tracking itself is indeed still out of scope; only the storage moved forward)*

---

## 📊 Migration Phases

### Phase 1A: Foundation (Non-Breaking)

**Goal**: Add new columns and helper functions without affecting existing data

**Migrations**:
*(as with Phase 1B below, none of these `20260508_*` filenames exist — the work shipped 2026-05-12 in the `eywa_w*` waves. Annotated 2026-08-24 against live schema.)*

1. `20260508_001_create_ulid_function.sql` — ULID generator → shipped inside `eywa_w8_01` as **`generate_ulid16()`**, a 16-char HEX generator (see Technical Specifications)
2. `20260508_002_create_fingerprint_helpers.sql` — Display name generators → shipped in `eywa_w8_01` (`slugify`, `fn_set_fingerprint_brand`, `fn_prevent_fingerprint_change`, `fn_refresh_display_name_brand`) and `eywa_w10_03` (`fn_set_fingerprint_generic`)
3. `20260508_003_add_two_column_identity_to_existing.sql` — Add `fingerprint`/`fingerprint_display_name` columns to existing tables (NULL allowed during migration) → `eywa_w10_01`/`_02`, finalized NOT NULL + UNIQUE; 🔴 reached only 22 of 43 tables
4. `20260508_004_add_multilingual_columns.sql` — Add `canonical_names`, `aliases`, `descriptions` jsonb to entity/cluster/brand → 🔴 landed on **cluster only**. `brands` got none of the three, and `seo_entity_graph.aliases` is plain `text` with no `canonical_names`/`descriptions` (see DR-009)
5. `20260508_005_add_brand_slug_to_brands.sql` — Add `brand_slug` UNIQUE column → ✅ live on `brands` (20 rows, all populated)

### Phase 1B: New Tables

**Goal**: Create missing v1.7 tables

> 🔴 **This numbered plan is not what was applied** *(corrected 2026-08-24 against live schema)*. None of these `20260508_*` filenames exist in `migrations/`; the build went out on 2026-05-12 as the `eywa_w*` wave migrations manifested in `migrations/README.md`, and the source of truth is Supabase `supabase_migrations.schema_migrations`. Six of the fourteen tables below were never created under any name. Kept as the original plan of record, annotated with what landed.

**Migrations**:
6. `20260508_010_create_seo_topic_cluster_master.sql` — ✅ built as `eywa_w1_01` (58 rows)
7. `20260508_011_create_seo_authors.sql` — ✅ built as **`seo_authors_reviewers`** (`eywa_w3_01`, 184 rows); `seo_authors` never existed
8. `20260508_012_create_seo_brand_doctors.sql` — ✅ built as **`seo_doctor_assignments`** (`eywa_w3_01`, 262 rows)
9. `20260508_013_create_seo_brand_branches.sql` — ✅ built as **`seo_branches`** (`eywa_w3_02`, 37 rows)
10. `20260508_014_create_seo_citations.sql` — ✅ built as `eywa_w1_02` (551 rows)
11. `20260508_015_create_seo_page_citations.sql` — ✅ built as `eywa_w1_03` (6,626 rows)
12. `20260508_016_create_seo_editorial_reviews.sql` — ✅ built as `eywa_w4_01` (2,095 rows)
13. `20260508_017_create_seo_ai_citation_tracking.sql` — ✅ built as **`seo_llm_citations`** (`eywa_w7_01`, 0 rows)
14. `20260508_018_create_seo_brand_authority_scores.sql` — 🔴 NEVER BUILT
15. `20260508_019_create_seo_cluster_health_scores.sql` — 🔴 NEVER BUILT
16. `20260508_020_create_seo_entity_authority_scores.sql` — 🔴 NEVER BUILT (the score itself lives on as `seo_entity_graph.entity_authority_score`)
17. `20260508_021_create_seo_eeat_scores.sql` — 🔴 NEVER BUILT
18. `20260508_022_create_seo_governance_audit.sql` — 🔴 NEVER BUILT (nearest live tables: `seo_data_quality_metrics`, `seo_schema_changes`, `eywa_w7_02`)
19. `20260508_023_create_seo_kpi_baseline.sql` — 🔴 NEVER BUILT

*(row counts measured 2026-08-24; they drift — re-measure with `GET /rest/v1/<table>?select=id`)*

### Phase 1C: Triggers & Constraints

**Goal**: Add triggers and constraints for data integrity

**Migrations**:
20. `20260508_030_add_fingerprint_triggers_existing.sql`
21. `20260508_031_add_fingerprint_triggers_new.sql`
22. `20260508_032_add_immutability_constraints.sql`
23. `20260508_033_add_fk_constraints.sql`

### Phase 1D: Indexes & Performance

**Goal**: Performance optimization

**Migrations**:
24. `20260508_040_add_gin_indexes_jsonb.sql`
25. `20260508_041_add_gin_indexes_arrays.sql`
26. `20260508_042_add_btree_indexes_lookups.sql`

### Phase 1A.2 — Sitemap Design Quality Gates 🆕 v1.3 (DR-015, DR-016, DR-017)

**Goal**: Add page_master columns supporting Bible §4.13 (Market Reconciliation) + §4.14 (Page Viability) + §4.5 (Content Brief).

**Migrations** (independent of DR-013/014 lock — can apply now):

*(both migrations landed as `eywa_w0c_02` on 2026-05-12, not under these filenames — corrected 2026-08-24 against `migrations/README.md` + live schema)*

27. `20260510_007_add_content_brief.sql` (DR-017)
    - `ALTER TABLE seo_website_page_master ADD COLUMN content_brief text NULL` — ✅ column is live
    - REQUIRED for collapsed pages, RECOMMENDED otherwise — 🔴 **this rule has never fired**: `content_brief` is NULL in all 2,358 page rows as of 2026-08-24. What editorial intent exists is in `note_brief` (266 / 2,358 rows) — the other candidate, `suggested_page_content`, is NULL in all 2,358 rows too *(re-measured 2026-08-24; an earlier correction on this line named `suggested_page_content` as a live destination, and it is empty)*
    - No constraint at DB level (validation in app/Notion layer) — and no validator appears in this repo or in the brand ETL either (`content_brief` occurs only in prose files), which is why the count above is zero

28. `20260510_008_add_sitemap_design_columns.sql` (DR-015 + DR-016)
    - `ADD COLUMN marketplace_proposal_status text NULL` with CHECK constraint:
      `('direct_match' | 'repackaged' | 'forced_fit_with_caveat' | 'rejected')` — 🔴 column is live but **NULL in all 2,358 rows** (2026-08-24), so the reconciliation status is recorded nowhere; and the live column COMMENT documents a different vocabulary — `proposed/approved/rejected/repackaged/deferred`. Only `repackaged` and `rejected` appear in both. The CHECK body itself is not reachable through PostgREST and is **unverified** — needs a `pg_constraint` read before either list is trusted
    - `ADD COLUMN reconciliation_notes text NULL` — ✅ live and heavily used: 1,778 / 2,358 rows populated (2026-08-24). Append-only log delimited by `" | "`; gates read it for `INTENT` / `CITATION EXEMPTION` markers
    - `ADD COLUMN viability_assessment jsonb NULL` — ✅ live, 1,455 / 2,358 rows populated (2026-08-24)
    - Partial index on `marketplace_proposal_status WHERE NOT NULL` — indexes are not reachable through PostgREST; **unverified**
    - GIN index on `viability_assessment WHERE NOT NULL` — **unverified**, same reason

**Properties**:
- Additive (no breaking changes)
- All NULL-able (backwards compatible)
- Idempotent (`IF NOT EXISTS`)
- Independent of DR-013/014 (can apply before edge vocabulary lock decision)

---

## 🎯 Success Criteria

Phase 1 is complete when:

> *(boxes ticked 2026-08-24 against live schema — every box was still empty while the Status line above and the README badge both said "Phase 1A Built ✅". Ticked = verified live today; 🔴 = verified NOT met; unticked with a note = not reachable through PostgREST and still unverified.)*

- [x] All v1.7 tables exist in GTGT — 43 canonical tables live, **but** 6 planned score/audit/KPI tables were never built (see Phase 1B above); v1.7's list is not the list that shipped
- [ ] 🔴 Two-column identity pattern applied to all relevant tables — 22 of 43 carry both columns, 6 carry `fingerprint` only, 15 carry neither
- [x] ULID generation function tested and working — `generate_ulid16()` is live and every one of the 3,090 entity + page fingerprints matches `{code}_[0-9A-F]{16}`; it is not a ULID (see Technical Specifications)
- [ ] 🔴 Multilingual jsonb columns ready for data — only `seo_topic_cluster_master` has the full jsonb trio; `seo_entity_graph.aliases` is plain text and `brands`/`seo_citations`/`seo_doctor_assignments` have none
- [ ] Triggers prevent fingerprint mutation — trigger existence is **not reachable through PostgREST**; unverified since the 2026-05-12 build tests
- [ ] Existing n8n workflows still functional — not observable from the database; unverified
- [x] All migrations versioned in git (eywa-supabase-migrations repo) — resolved to a `migrations/` subfolder of THIS repo (DR-024), holding `migrations/README.md` + one column-comment SQL file; Supabase `schema_migrations` remains the source of truth
- [x] Migration runbook documented — `migrations/README.md`
- [ ] Rollback strategy defined — documented per-migration only (e.g. the Wave 9 FDW reinstall note); no repo-wide strategy exists

---

## 📚 References

*(all four "current" pointers corrected 2026-08-24 — each named a version that has been superseded, and the Bible path did not resolve to a file)*

- **Bible v3.34** (current): `EYWA_PROTOCOL_v3_33.md` — note the filename still says v3.33 while the document's own front matter says v3.34; there is no `EYWA_PROTOCOL_v3_29.md` in this repo
- **Schema Overview v1.10** (archived → current is **v1.23**, `Schema_Overview_EYWA_v1_23.md`): `archive/Schema_Overview_EYWA_v1_10.md`
- **Handover v1.19** (current): `EYWA_HANDOVER.md` (Section 6 — Phase 1 Status)
- **Decision Records v1.37** (current): `DECISION_RECORDS.md` (DR-001..**DR-058**; DR-057/058 carry the rulings this document was re-checked against)
- Bible v3.13 (archived): `archive/EYWA_PROTOCOL_v3_13.md`
- Bible v3.12 (archived): for historical reference only
- Schema v1.9 (archived): `archive/Schema_Overview_EYWA_v1_9.md`
- Schema v1.8 (archived): for historical reference only

---

## 🔄 Open Items (Not Decided Yet)

### Active (DR-013 + DR-014) — Field-Tested Feedback from VTH BioDent 🌱

These items emerged from real EGP work (Naphannop S.) and are now in Proposed status, testing DR-012 governance for first time: *(section header corrected 2026-08-24 — nothing below is still open. All five DRs in this section were **Locked 2026-05-12** per `migrations/README.md`, and four of the five are visible in live data. The heading "Open Items (Not Decided Yet)" also contradicts this document's own Status line, which has listed 013/014/019/020/021 as locked since v1.9.)*

- 🌱 **DR-013 — Edge Vocabulary v3.5 Expansion**: Proposes adding `causes/caused_by` + `contraindicates` edges (10 → 12 vocabulary). 
  - Status: Proposed (review until 2026-05-20) → **LOCKED 2026-05-12**, shipped in `eywa_w1_04`. All three proposed edges are live in data as of 2026-08-24: `contraindicates` 21 rows, `causes` 6, `caused_by` 5, within 1,089 relationship rows over 10 distinct edge types *(corrected 2026-08-24 against live data)*
  - Blocking: NO for current Phase 1A; YES for future Phase 1E + Bible v3.15+
  - Critical path: Cross-brand canvass by 2026-05-13
  - Note: Bible v3.14 was issued for DR-015..018 (sitemap design layer) — DR-013/014 will trigger v3.15 if locked

- 🌱 **DR-014 — Concept Entity Subtype Lock**: Proposes controlled vocabulary `framework` + `axis` for `entity_subtype` on concept entities.
  - Status: Proposed (paired with DR-013) → **LOCKED 2026-05-12**, shipped in `eywa_w0c_01` as `entity_subtype` + `chk_concept_subtype`; the live column comment admits a third value, `general`, alongside NULL. 🔴 **DORMANT in practice**: `entity_subtype` is NULL in all 732 entity rows, so the vocabulary has never been exercised *(corrected 2026-08-24 against live data)*
  - Blocking: NO

- 🌱 **DR-019 — Schema Strategy for Post-Rich-Results Era**: Triggered by Google FAQ rich results full deprecation (announced 2026-05-07, effective June 2026).
  - Status: Proposed (review until 2026-06-07) → **LOCKED 2026-05-12** (no DDL — schema emission strategy) *(corrected 2026-08-24 per `migrations/README.md` DR coverage table; the forbidden-schema enforcement below lives in `eywa-schema-pipeline` and is not observable in this database)*
  - Blocking: NO for Phase 1A migrations (no DDL change required)
  - Blocking_phase_1A.2: NO (independent of DR-015..018 lock)
  - Targets Bible v3.15 if locked (Part 26 restructure + Part 9 Featured Snippet + Part 20 KPIs)
  - 4 sub-decisions: Two-Purpose Taxonomy / Featured Snippet pattern / KPI replacement / AggregateRating tightening
  - Forbidden schemas to BLOCK in `eywa-schema-pipeline`: CourseInfo, ClaimReview, EstimatedSalary, LearningVideo, SpecialAnnouncement, VehicleListing, PracticeProblem
  - Independent of DR-013/014 (different governance scope — emission layer vs edge vocabulary)

- 🌱 **DR-020 — Universal Content Template Standard**: Triggered by VTH /mouth-biomapping/ EEAT audit + Deezy sitemap gap analysis.
  - Status: Proposed (review until 2026-06-07 — paired with DR-019 cycle) → **LOCKED 2026-05-12** *(corrected 2026-08-24)*
  - Blocking: NO for Phase 1A migrations (no DDL change for v1.0)
  - Companion file: `Content_Templates_EYWA_v1_0.md` (DRAFT in `drafts/`, 1,456 lines) → now **v1.9, LOCKED, at the repo root, 3,134 lines** (`wc -l`, working tree 2026-08-24; 2,984 at the last commit — the file is under active edit, so treat the figure as approximate); there is no `drafts/` directory *(corrected 2026-08-24; an earlier pass on this line said 3,125, which matched neither)*
  - 4 sub-decisions: Companion architecture / 3-layer composition / EEAT requirement matrix / Schema enforcement pattern
  - 25 templates: 12 core + 5 T2 vertical variants + 7 specialized (T13-T19) + T6a Guide — the arithmetic still holds (T1–T19 + T2a–T2e + T6a), but 🔴 **this is not a validation list**: `content_format` codes are PER BRAND and may diverge completely (operator ruling 2026-08-23, DR-057). Live codes as of 2026-08-24 — vth-biodent 9 codes, smile-scape-clinic 13, deezy-dental 21, and deezy uses `T2b` where the others use `T2`. Two codes in live use, `T8g` and `T12i`, are not derivable from the global list at all. Validate against the brand's own registry, never against these 25 *(corrected 2026-08-24 against live data)*
  - ~25 universal blocks compose templates (LEGO architecture)
  - EEAT phasing: Soft-warn now → Hard-block **gated on measurement, date withdrawn 2026-08-23** (prerequisite ≥80% doctor onboarding — วัดที่ `seo_authors_reviewers` ไม่ใช่ `seo_authors` ที่ไม่มีอยู่จริง)
  - Future Phase 1F: ACF field group refactor (~15-20h) + eywa-schema-pipeline plugin update (~6h)
  - Future v1.1 Schema may add `template_id` + `template_version` columns (deferred)
  - Independent of DR-013/014; complements DR-017/018/019

- 🌱 **DR-021 — Internal Linking Architecture (HYBRID)**: Triggered by Stage 1.5 (Handover v1.6) needing internal linking storage + operator's pre-EYWA Notion DB precedent.
  - Status: Proposed (review until 2026-06-07 — paired with DR-019/020 cycle) → **LOCKED 2026-05-12 and fully built** *(corrected 2026-08-24 against live schema — this is the most stale entry in the document: it is written as deferred while the junction table has been carrying 16,564 rows)*
  - Blocking: NO for Phase 1A migrations (deferred to v1.11/Phase 1A.3 if locked)
  - 4 sub-decisions:
    1. 12 page-level linking strategy cols added to `seo_website_page_master` (port from Notion DB) — ✅ live: `authority_weight`, `link_equity_score`, `orphan_risk_score`, `crawl_depth`, `node_tier_strategy`, `link_role`, `link_priority`, `anchor_strategy_mode`, `strategic_page`, `required_min_inbound`, `required_min_outbound`, plus the cross-brand set (`cross_brand_approved`, `cross_brand_justification`, `cross_brand_role`, `cross_brand_link_type`, `cross_brand_links_fps`, `brand_authority_focus`)
    2. New `seo_page_internal_links` junction table (~22 cols per-edge) — ✅ live with **28 columns** and 16,564 rows (2026-08-24)
    3. Bidirectional consistency validation (reciprocal/anchor diversity/orphan/depth) — the reciprocal trigger is recorded in `eywa_w4_01`; trigger existence is not reachable through PostgREST, **unverified**
    4. Cross-brand link governance (justification + approved flag required) — columns live but 🔴 the rule has never fired: as of 2026-08-24 `cross_brand_approved` is true on 0 of 2,358 rows and `cross_brand_justification` / `cross_brand_link_type` are empty in all of them (`cross_brand_role` is set on 689). With no approved page there is nothing for the governance check to reject
  - Schema v1.11 migrations: 009_add_linking_strategy_cols.sql + 010_create_seo_page_internal_links.sql — 🔴 neither filename was used; it shipped as `eywa_w0c_02` (columns) + `eywa_w4_01` (table) *(corrected 2026-08-24)*
  - HYBRID rationale: page-level alone (Notion) lacks per-edge fidelity; junction alone lacks page-level strategy
  - Total effort if locked: ~15-20 hours one-time + ~2-3 hours per brand
  - Independent of DR-013/014; complements DR-019/020 — together = full content production stack (composition + emission + linking)

### Phase 1 Operational Items (renumbered from v1.1)

These items will become DR-022+ when decided: *(all three were decided — Locked 2026-05-12 per `migrations/README.md`; corrected 2026-08-24)*

- [x] **DR-022 — Branch testing protocol**: Test migrations on Supabase development branch before main? — **Locked** (process/workflow, no DDL)
  - Recommended: yes (low cost, high safety)
  - Can decide during: before first migration applied
  
- [x] **DR-024 — Migration repo strategy**: separate `eywa-supabase-migrations` repo vs subfolder in `eywa-protocol-spec`? — **Locked**: subfolder, `migrations/` in this repo. It also shipped schema — the 9 Group-9 entity extension tables (`eywa_w2_01`..`eywa_w2_03`), all live
  - Can decide during: Phase 1A execution
  
- [x] **DR-025 — Notion sync scope**: Which v1.9 tables sync to Notion, which are Supabase-only? — **Locked**; shipped `seo_branches` + `seo_reviews` / `seo_directory_listings` / `seo_gbp_posts` (`eywa_w3_02`, `eywa_w3_03`). The sync itself: `seo_website_page_master.notion_id` and `notion_synced_at` are live columns, and the Notion FDW was removed in Wave 9 in favour of n8n
  - Affects Phase 1B table design
  - Can decide during: between Phase 1B and Phase 1C

- [ ] **Existing migrations export**: Export 30 GTGT migrations to git as historical baseline (operational task, not architectural)
- [ ] **Cluster multilingual variant**: Tier 1 (jsonb) confirmed for cluster_master, but reserve Tier 2 option if cluster pages need separate language URLs in future

**Note:** None of these block Phase 1A migration writing. Decisions can be made during execution.

---

## 🆕 v1.2 Changelog (2026-05-09)

- 🔄 References updated: Bible v3.12 → v3.13, Schema v1.8 → v1.9, Handover v1.3 → v1.5, DR v1.1 → v1.3
- ➕ Added DR-013 (Edge Vocabulary v3.5 Expansion) — Proposed status
- ➕ Added DR-014 (Concept Entity Subtype Lock) — Proposed status
- 🔄 Renumbered placeholders: DR-020→DR-022, DR-021→DR-024, DR-022→DR-025
- 📝 Note: DR-013/014 are first proposed additions under DR-012 (Edge Vocabulary Evolution Policy) governance

---

## 🆕 v1.3 Changelog (2026-05-10)

- 🔄 References updated: Bible v3.13 → v3.14, Schema v1.9 → v1.10, Handover v1.5 → v1.6, DR v1.3 → v1.4
- ➕ Added Phase 1A.2 sub-phase — Sitemap Design Quality Gates
- ➕ Added migration 007: `20260510_007_add_content_brief.sql` (DR-017)
- ➕ Added migration 008: `20260510_008_add_sitemap_design_columns.sql` (DR-015 + DR-016)
- 🔒 DR-015..DR-018 locked (operator approval 2026-05-10) — independent of DR-013/014 governance
- 📝 Note: 4 new DRs (015-018) emerged from VTH BioDent field testing — sitemap design layer refinements, not edge vocabulary changes

---

## 🆕 v1.4 Changelog (2026-05-10)

- 🔄 Reference updated: DR v1.4 → v1.5 (DR-019 Proposed)
- 🌱 Added DR-019 to Active Open Items section (Proposed, review until 2026-06-07)
- 📝 No DDL change from DR-019 — spec-level + plugin-level only (`eywa-schema-pipeline` enforces forbidden schema list)
- 📝 DR-019 independent of DR-013/014 — different governance scope (schema emission layer vs entity edge vocabulary layer)
- 📝 Trigger: Google FAQ rich results full deprecation announcement 2026-05-07 (effective June 2026)

---

## 🆕 v1.5 Changelog (2026-05-10)

- 🔄 Reference updated: DR v1.5 → v1.6 (DR-020 Proposed)
- 🌱 Added DR-020 to Active Open Items section (Proposed, review until 2026-06-07 — paired with DR-019 cycle)
- 📁 New companion file: `Content_Templates_EYWA_v1_0.md` at repo root (DRAFT status in frontmatter, 1,456 lines, 25 templates, ~25 blocks)
- 📝 No DDL change from DR-020 v1.0 — existing page_master columns suffice
- 📝 Future v1.1 of DR-020 may add `template_id` + `template_version` columns to page_master (deferred)
- 📝 EEAT phase 2 hard-block — **date withdrawn 2026-08-23, now gated on measurement** (≥80% doctor onboarding, วัดที่ `seo_authors_reviewers`)
- 📝 Trigger: VTH `/mouth-biomapping/` EEAT audit (visual EEAT good, structured EEAT broken — 6 failures) + Deezy sitemap gap analysis (13 page types, no template framework)
- 📝 Companion to DR-017 (content_brief), DR-018 (length standards), DR-019 (schema strategy) — together form complete content production stack

---

**End of Phase 1 Decisions Summary v1.9** *(corrected 2026-08-24 — the footer said v1.6 while the front matter and the README both say v1.9; the v1.6→v1.9 changes were never given changelog entries, so the changelog stops at v1.5)*
