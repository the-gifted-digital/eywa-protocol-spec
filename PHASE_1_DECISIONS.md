# EYWA™ Protocol — Phase 1 Decisions Summary

**Document Version**: 1.5
**Date**: 2026-05-10
**Status**: 🔒 Locked (Phase 1A specs + DR-015..018) + 🌱 DR-013/014 + DR-019 + DR-020 Proposed
**Phase**: 1 — Supabase Database Foundation
**Project**: GTGT (in-place upgrade)
**Companion to**: Bible v3.14 + Schema Overview v1.10 + Handover v1.6 + DECISION_RECORDS v1.6 + Content_Templates_EYWA_v1_0.md (DRAFT)

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

### Phase 1A.2 — Sitemap Design Quality Gates 🆕 v1.3 (DR-015, DR-016, DR-017)

**Goal**: Add page_master columns supporting Bible §4.13 (Market Reconciliation) + §4.14 (Page Viability) + §4.5 (Content Brief).

**Migrations** (independent of DR-013/014 lock — can apply now):

27. `20260510_007_add_content_brief.sql` (DR-017)
    - `ALTER TABLE seo_website_page_master ADD COLUMN content_brief text NULL`
    - REQUIRED for collapsed pages, RECOMMENDED otherwise
    - No constraint at DB level (validation in app/Notion layer)

28. `20260510_008_add_sitemap_design_columns.sql` (DR-015 + DR-016)
    - `ADD COLUMN marketplace_proposal_status text NULL` with CHECK constraint:
      `('direct_match' | 'repackaged' | 'forced_fit_with_caveat' | 'rejected')`
    - `ADD COLUMN reconciliation_notes text NULL`
    - `ADD COLUMN viability_assessment jsonb NULL`
    - Partial index on `marketplace_proposal_status WHERE NOT NULL`
    - GIN index on `viability_assessment WHERE NOT NULL`

**Properties**:
- Additive (no breaking changes)
- All NULL-able (backwards compatible)
- Idempotent (`IF NOT EXISTS`)
- Independent of DR-013/014 (can apply before edge vocabulary lock decision)

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

- **Bible v3.14** (current): `EYWA_PROTOCOL_v3_14.md`
- **Schema Overview v1.10** (current): `Schema_Overview_EYWA_v1_10.md`
- **Handover v1.6** (current): `EYWA_HANDOVER.md` (Section 6 — Phase 1 Status)
- **Decision Records v1.4** (current): `DECISION_RECORDS.md` (DR-001..DR-018)
- Bible v3.13 (archived): `archive/EYWA_PROTOCOL_v3_13.md`
- Bible v3.12 (archived): for historical reference only
- Schema v1.9 (archived): `archive/Schema_Overview_EYWA_v1_9.md`
- Schema v1.8 (archived): for historical reference only

---

## 🔄 Open Items (Not Decided Yet)

### Active (DR-013 + DR-014) — Field-Tested Feedback from VTH BioDent 🌱

These items emerged from real EGP work (Naphannop S.) and are now in Proposed status, testing DR-012 governance for first time:

- 🌱 **DR-013 — Edge Vocabulary v3.5 Expansion**: Proposes adding `causes/caused_by` + `contraindicates` edges (10 → 12 vocabulary). 
  - Status: Proposed (review until 2026-05-20)
  - Blocking: NO for current Phase 1A; YES for future Phase 1E + Bible v3.15+
  - Critical path: Cross-brand canvass by 2026-05-13
  - Note: Bible v3.14 was issued for DR-015..018 (sitemap design layer) — DR-013/014 will trigger v3.15 if locked

- 🌱 **DR-014 — Concept Entity Subtype Lock**: Proposes controlled vocabulary `framework` + `axis` for `entity_subtype` on concept entities.
  - Status: Proposed (paired with DR-013)
  - Blocking: NO

- 🌱 **DR-019 — Schema Strategy for Post-Rich-Results Era**: Triggered by Google FAQ rich results full deprecation (announced 2026-05-07, effective June 2026).
  - Status: Proposed (review until 2026-06-07)
  - Blocking: NO for Phase 1A migrations (no DDL change required)
  - Blocking_phase_1A.2: NO (independent of DR-015..018 lock)
  - Targets Bible v3.15 if locked (Part 26 restructure + Part 9 Featured Snippet + Part 20 KPIs)
  - 4 sub-decisions: Two-Purpose Taxonomy / Featured Snippet pattern / KPI replacement / AggregateRating tightening
  - Forbidden schemas to BLOCK in `eywa-schema-pipeline`: CourseInfo, ClaimReview, EstimatedSalary, LearningVideo, SpecialAnnouncement, VehicleListing, PracticeProblem
  - Independent of DR-013/014 (different governance scope — emission layer vs edge vocabulary)

- 🌱 **DR-020 — Universal Content Template Standard**: Triggered by VTH /mouth-biomapping/ EEAT audit + Deezy sitemap gap analysis.
  - Status: Proposed (review until 2026-06-07 — paired with DR-019 cycle)
  - Blocking: NO for Phase 1A migrations (no DDL change for v1.0)
  - Companion file: `Content_Templates_EYWA_v1_0.md` (DRAFT in `drafts/`, 1,456 lines)
  - 4 sub-decisions: Companion architecture / 3-layer composition / EEAT requirement matrix / Schema enforcement pattern
  - 25 templates: 12 core + 5 T2 vertical variants + 7 specialized (T13-T19) + T6a Guide
  - ~25 universal blocks compose templates (LEGO architecture)
  - EEAT phasing: Soft-warn now → Hard-block 2026-09-01 (prerequisite: ≥80% doctor onboarding)
  - Future Phase 1F: ACF field group refactor (~15-20h) + eywa-schema-pipeline plugin update (~6h)
  - Future v1.1 Schema may add `template_id` + `template_version` columns (deferred)
  - Independent of DR-013/014; complements DR-017/018/019

### Phase 1 Operational Items (renumbered from v1.1)

These items will become DR-022+ when decided:

- [ ] **DR-022 — Branch testing protocol**: Test migrations on Supabase development branch before main?
  - Recommended: yes (low cost, high safety)
  - Can decide during: before first migration applied
  
- [ ] **DR-024 — Migration repo strategy**: separate `eywa-supabase-migrations` repo vs subfolder in `eywa-protocol-spec`?
  - Can decide during: Phase 1A execution
  
- [ ] **DR-025 — Notion sync scope**: Which v1.9 tables sync to Notion, which are Supabase-only?
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
- 📝 EEAT phase 2 hard-block targeted 2026-09-01 (prerequisite: ≥80% brand doctor onboarding)
- 📝 Trigger: VTH `/mouth-biomapping/` EEAT audit (visual EEAT good, structured EEAT broken — 6 failures) + Deezy sitemap gap analysis (13 page types, no template framework)
- 📝 Companion to DR-017 (content_brief), DR-018 (length standards), DR-019 (schema strategy) — together form complete content production stack

---

**End of Phase 1 Decisions Summary v1.5**
