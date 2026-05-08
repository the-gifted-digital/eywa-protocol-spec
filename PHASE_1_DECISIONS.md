# EYWA™ Protocol — Phase 1 Decisions Summary

**Document Version**: 1.1
**Date**: 2026-05-08
**Status**: 🔒 Locked
**Phase**: 1 — Supabase Database Foundation
**Project**: GTGT (in-place upgrade)
**Companion to**: Bible v3.12 + Schema Overview v1.8 + Handover v1.3

---

## 🎯 Strategic Decisions

### DR-007: In-Place GTGT Upgrade

**Decision**: Upgrade existing GTGT Supabase project schema to align with Bible v3.12 / Schema v1.8, **without splitting into multiple projects**.

**Rationale**:
- 30 existing migrations show working in-place evolution discipline
- 6 active n8n workflows in production
- Solo developer scale (15 brands) doesn't justify multi-project overhead
- Cost-effective ($0 additional infrastructure)
- Existing keyword pipeline (25K+ rows) preserved without disruption

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

**Decision**: Every table (except `seo_x_ads_keywords_contextual_master`) has TWO identity columns:

| Column | Type | Mutability | Purpose |
|--------|------|------------|---------|
| `fingerprint` | text UNIQUE | IMMUTABLE | Machine identity, used for FK/joins |
| `fingerprint_display_name` | text | MUTABLE | Human label, debug aid |

**Format**:
- `fingerprint`: `{tablecode}_{ULID16}` — Pattern B
  - Example: `ent_01HZP5K2XQR7N3MF`
  - 16 characters of ULID (time-sortable, 80-bit entropy)
  - Compact yet collision-safe
- `fingerprint_display_name`: `{fp_last_6}::{type}::{slug}::{key_data}`
  - Example: `N3MF::condition::sleep-apnea::G47.3`
  - First 6 chars = last 6 of fingerprint (cross-check)
  - `::` (double colon) separator
  - Auto-refreshed when source data changes

**Exception**: `seo_x_ads_keywords_contextual_master` keeps existing fingerprint format `{brand}::{market}::{language}::{keyword}` because it's already self-documenting and immutable.

**Rationale**:
- Stable machine identity prevents broken relations on rename
- Human-readable label enables debugging and data validation
- Last-6-of-fingerprint in display creates double cross-check
- ULID provides time-ordering benefit for free

---

### DR-009: Multilingual Strategy

**Decision**: Two-tier multilingual handling based on table type.

#### Concept Tables (1 row + jsonb translations)

Tables where the entity itself is universal but has multiple language labels:

- `ent::seo_entity_graph`
- `clus::seo_topic_cluster_master`
- `brnd::brands`
- `auth::seo_authors`
- `doc::seo_brand_doctors`
- `brch::seo_brand_branches`
- `cite::seo_citations`

**Pattern**:
```jsonb
canonical_names: {"en": "Sleep Apnea", "th": "ภาวะหยุดหายใจขณะหลับ"}
aliases: {
  "en": ["sleep apnea syndrome", "OSA"],
  "th": ["หยุดหายใจตอนนอน", "นอนกรนแบบรุนแรง"]
}
```

#### Content Tables (1 row per language + translation_group_id)

Tables where each language version is a separate content asset:

- `page::seo_website_page_master`
- `kw::seo_x_ads_keywords_contextual_master` (existing `translation_group`)
- `rev::seo_editorial_reviews`

**Pattern**:
- Each language = separate row with unique fingerprint
- All translations share `translation_group_id` (e.g., `tg_01HZP5K2X...`)
- One row marked `is_source_page = true` (canonical)
- Other rows reference source via `source_translation_fp`

**Translation Group ID Format**: `tg_{ULID16}` (tg = translation group, separate namespace)

---

### DR-010: Brand Scope Architecture

**Decision**: Standardize brand association via `brand_scope text[]` column.

**Pattern**:
- Single brand: `['vth-biodent']`
- Universal: `['*']`
- Shared: `['vth-biodent', 'vitalsleep', 'the-face-hospital']`

**brand_slug** is canonical reference (immutable, lowercase, kebab-case).

**Tables Using brand_scope[]**:
- `seo_entity_graph` (shared across brands)
- `seo_topic_cluster_master` (shared)
- `seo_authors` (may write for multiple brands)

**Tables Using brand_slug (single)**:
- `seo_website_page_master` (page belongs to 1 brand site)
- `seo_brand_doctors` (doctor licensed to 1 clinic)
- `seo_brand_branches` (branch belongs to 1 brand)

---

## 📐 Naming Conventions

### Table Codes (3-4 letters)

| Code | Table | Type |
|------|-------|------|
| `ent` | seo_entity_graph | Concept |
| `page` | seo_website_page_master | Content (multilang) |
| `clus` | seo_topic_cluster_master | Concept |
| `kw` | seo_x_ads_keywords_contextual_master | Existing (no migration) |
| `brnd` | brands | Concept |
| `auth` | seo_authors | Concept |
| `doc` | seo_brand_doctors | Concept |
| `brch` | seo_brand_branches | Concept |
| `cite` | seo_citations | Concept |
| `pcit` | seo_page_citations | Junction |
| `rev` | seo_editorial_reviews | Content |
| `aici` | seo_ai_citation_tracking | Time-series |
| `asc` | seo_brand_authority_scores | Score |
| `chs` | seo_cluster_health_scores | Score |
| `eas` | seo_entity_authority_scores | Score |
| `eeat` | seo_eeat_scores | Score |
| `gov` | seo_governance_audit | Audit |
| `kpi` | seo_kpi_baseline | KPI |
| `tg` | (translation group, namespace only) | N/A |

---

## 🔧 Technical Specifications

### ULID Generation

**Method**: Pure SQL function (no extensions, Postgres 17 compatible)

**Function**: `generate_ulid()` returns 16-character Crockford Base32 string

**Properties**:
- 48-bit timestamp prefix (millisecond precision)
- 80-bit random suffix
- Lexicographically sortable
- Time-ordered for INSERT performance

### Fingerprint Generator

```sql
generate_fingerprint_v2(p_tablecode text)
RETURNS: '{tablecode}_{ULID16}'
```

### Display Name Generators

Per-table functions:
- `generate_entity_display_name()` — entity formula
- `generate_page_display_name()` — page formula
- `generate_brand_display_name()` — brand formula
- `generate_cluster_display_name()` — cluster formula
- (etc., one per table type)

### Trigger Pattern

Each table gets:
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
6. **EEAT scoring implementation** — Phase 3+
7. **AI citation tracking** — Phase 3+

---

## 📊 Migration Phases

### Phase 1A: Foundation (Non-Breaking)

**Goal**: Add new columns and helper functions without affecting existing data

**Migrations**:
1. `20260508_001_create_ulid_function.sql` — ULID generator
2. `20260508_002_create_fingerprint_helpers.sql` — Display name generators
3. `20260508_003_add_two_column_identity_to_existing.sql` — Add `fingerprint`/`fingerprint_display_name` columns to existing tables (NULL allowed during migration)
4. `20260508_004_add_multilingual_columns.sql` — Add `canonical_names`, `aliases`, `descriptions` jsonb to entity/cluster/brand
5. `20260508_005_add_brand_slug_to_brands.sql` — Add `brand_slug` UNIQUE column

### Phase 1B: New Tables

**Goal**: Create missing v1.7 tables

**Migrations**:
6. `20260508_010_create_seo_topic_cluster_master.sql`
7. `20260508_011_create_seo_authors.sql`
8. `20260508_012_create_seo_brand_doctors.sql`
9. `20260508_013_create_seo_brand_branches.sql`
10. `20260508_014_create_seo_citations.sql`
11. `20260508_015_create_seo_page_citations.sql`
12. `20260508_016_create_seo_editorial_reviews.sql`
13. `20260508_017_create_seo_ai_citation_tracking.sql`
14. `20260508_018_create_seo_brand_authority_scores.sql`
15. `20260508_019_create_seo_cluster_health_scores.sql`
16. `20260508_020_create_seo_entity_authority_scores.sql`
17. `20260508_021_create_seo_eeat_scores.sql`
18. `20260508_022_create_seo_governance_audit.sql`
19. `20260508_023_create_seo_kpi_baseline.sql`

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

---

## 🎯 Success Criteria

Phase 1 is complete when:

- [ ] All v1.7 tables exist in GTGT
- [ ] Two-column identity pattern applied to all relevant tables
- [ ] ULID generation function tested and working
- [ ] Multilingual jsonb columns ready for data
- [ ] Triggers prevent fingerprint mutation
- [ ] Existing n8n workflows still functional
- [ ] All migrations versioned in git (eywa-supabase-migrations repo)
- [ ] Migration runbook documented
- [ ] Rollback strategy defined

---

## 📚 References

- Bible v3.12: `EYWA_PROTOCOL_v3_12.md`
- Schema Overview v1.8: `Schema_Overview_EYWA_v1_8.md`
- Handover v1.3: `EYWA_HANDOVER.md` (Section 6 — Phase 1 Status)
- Handover v1.2: `EYWA_HANDOVER.md`
- Decision Records: `DECISION_RECORDS.md` (DR-001 to DR-010)

---

## 🔄 Open Items (Not Decided Yet)

These items will become DR-020+ when decided:

- [ ] **DR-020 — Migration repo strategy**: separate `eywa-supabase-migrations` repo vs subfolder in `eywa-protocol-spec`?
- [ ] **DR-021 — Notion sync scope**: Which v1.8 tables sync to Notion, which are Supabase-only?
- [ ] **DR-022 — Branch testing protocol**: Test migrations on Supabase development branch before main?
- [ ] **Existing migrations export**: Export 30 GTGT migrations to git as historical baseline (operational task, not architectural)
- [ ] **Cluster multilingual variant**: Tier 1 (jsonb) confirmed for cluster_master, but reserve Tier 2 option if cluster pages need separate language URLs in future

**Note:** None of these block Phase 1A migration writing. Decisions can be made during execution.

---

**End of Phase 1 Decisions Summary v1.1**
