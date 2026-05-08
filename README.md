# EYWA™ Protocol — Specification

> **Universal Knowledge Graph SEO Specification for Healthcare & Wellness Brands**

| 📖 Bible | 📊 Schema | 🏗️ Phase | ⚖️ License |
|----------|-----------|-----------|-------------|
| **v3.12** | **v1.8** | **1 — Foundation** | Proprietary |

<!-- Badges (render on GitHub.com): -->
[![Bible](https://img.shields.io/badge/Bible-v3.12-blue?style=flat-square)](./EYWA_PROTOCOL_v3_12.md)
[![Schema](https://img.shields.io/badge/Schema-v1.8-green?style=flat-square)](./Schema_Overview_EYWA_v1_8.md)
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

EYWA™ is a registered trademark of **The Gifted Digital Marketing Co., Ltd.** (Thailand)

---

## 📚 Documents in This Repo

| Document | Purpose | Lines | Status |
|----------|---------|-------|--------|
| `EYWA_PROTOCOL_v3_12.md` | The Bible — full specification | ~24,800 | 🔒 Active |
| `Schema_Overview_EYWA_v1_8.md` | Database schema companion | ~3,400 | 🔒 Active |
| `EYWA_HANDOVER.md` | Operating manual for Claude/AI | ~1,400 | 🔒 Active (v1.3) |
| `DECISION_RECORDS.md` | Architecture decision log | ~725 | 🔒 Active (v1.1) |
| `PHASE_1_DECISIONS.md` | Phase 1 quick reference | ~310 | 🔒 Active |
| `EYWA_PROTOCOL_v3_11.md` | Bible (previous version) | ~24,260 | 📦 Archived |
| `Schema_Overview_EYWA_v1_7.md` | Schema (previous version) | ~2,750 | 📦 Archived |

---

## 🆕 Latest Update — v3.12 (2026-05-08)

**Phase 1 Foundation — Two-Column Identity + Multilingual v2**

Major refinement based on production audit + operator feedback:

- ✅ **DR-007** — In-Place GTGT Schema Upgrade strategy
- ✅ **DR-008** — Two-Column Identity Pattern (Section 18.9)
- ✅ **DR-009** — Multilingual Strategy v2 (Two-Tier Pattern)
- ✅ **DR-010** — Brand Scope Architecture standardization

**Headline patterns:**

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

See `PHASE_1_DECISIONS.md` for full summary.

---

## 🗺️ Specification Coverage

The Bible (`EYWA_PROTOCOL_v3_12.md`) is organized into 27 Parts + 3 Appendices:

### Foundation (Parts 1-7)
- **Part 1:** Core Philosophy & Standards
- **Part 2:** Conceptual Architecture (Knowledge Graph foundations)
- **Part 3:** Neural Authority Architecture
- **Part 4:** Sitemap Architecture (8-section universal pattern)
- **Part 5:** Database Schema Architecture
- **Part 6:** Content Standard
- **Part 7:** Taxonomy Governance Rules (SKOS)

### Implementation (Parts 8-12)
- **Part 8:** WordPress Implementation
- **Part 9:** Content Page Template Anatomy + WCAG AA
- **Part 10:** Multi-Brand & Federation Strategy
- **Part 11:** Implementation Roadmap
- **Part 12:** References & Sources

### Intelligence Layer (Parts 13-15)
- **Part 13:** LLMO Execution Playbook (AI citation strategy)
- **Part 14:** Vertical Profiles
- **Part 15:** Schema Change Governance

### Operations (Parts 16-21)
- **Part 16:** 4-Tool Loose-Coupled Implementation
- **Part 17:** n8n Flow Library
- **Part 18:** Notion Database Specifications
  - Section 18.8: Two-Phase Hierarchy Sync Pattern
  - **Section 18.9: Two-Column Identity Pattern (NEW v3.12)**
- **Part 19:** Data Quality Framework
- **Part 20:** Measurement & KPI Framework
- **Part 21:** AI Operations & Embedding Strategy

### Content Excellence (Parts 23-24)
- **Part 23:** Medical Content Excellence (citation hierarchy, editorial review)
- **Part 24:** Future Roadmap & Beyond

### Technical Stack (Parts 25-28)
- **Part 25:** WordPress Universal Kit (4 EYWA plugins + Elementor Pro)
- **Part 26:** Schema Generation Pipeline (3-Layer architecture)
- **Part 27:** EYWA Scoring Framework (15 KPIs + 7 score types)
- **Part 28:** Multilingual Strategy (Two-Tier pattern, 8 languages)

### Reference (Appendices)
- **Appendix A:** Quick Reference Cards
- **Appendix B:** Complete Table & Schema Master List *(includes Section 18.7 Multi-Workspace Sync)*
- **Appendix D:** WordPress Code Reference Library

> **Note:** Part 22 and Appendix C numbering gaps are intentional — content was merged into Parts 24 and Appendix B respectively. Numbering preserved for backward-compatible cross-references (per v3.10.1 cleanup).

---

## 📊 Schema Overview

The Schema companion (`Schema_Overview_EYWA_v1_8.md`) covers:

- **Groups 1-9:** 30 tables organized by purpose
  - Group 1: Brand & Organization
  - Group 2: Knowledge Architecture
  - Group 3: Page System
  - Group 4: Keyword & Search Intelligence
  - Group 5: Performance Fact Tables
  - Group 6: Backlinks & Off-Page
  - Group 7: AI Operations & Embeddings
  - Group 8: Data Quality & Governance
  - Group 9: Entity Extensions & Templates

- **Appendix A:** PostgreSQL Extensions
- **Appendix B:** Fingerprint Patterns (v1.8 — Two-Column Identity)
- **Appendix C:** Naming Conventions
- **Appendix D:** Cross-Reference Index to Bible
- **Appendix E:** Multilingual Strategy (Two-Tier pattern)
- **Appendix F:** Helper Functions Reference (ULID generator, fingerprint generators, triggers)

---

## 🛠️ Implementation Stack

```
Backend (federation, shared):
├─ Supabase (single project, brand_scope filtered)
│  └─ GTGT project (lffcbeszjqzioobqfdav, ap-northeast-1, Postgres 17.6.1)
├─ Notion (multi-team workspaces, mirrored structure)
└─ n8n (sync orchestration, 6 active workflows)

Per-Brand WordPress:
├─ Hello Elementor theme
├─ Elementor Pro (Theme Builder + Loop Builder)
├─ ACF Pro (custom fields + JSON sync)
├─ RankMath Pro (SEO + hreflang)
├─ WPML (multilingual)
└─ EYWA Plugins (4):
   ├─ eywa-core
   ├─ eywa-cpt-activation
   ├─ eywa-acf-fields
   └─ eywa-schema-pipeline

Distribution:
├─ This repo: spec + Schema_Overview + decisions
├─ eywa-* repos: plugin code + ACF JSON + Elementor templates
└─ Per-brand repos: content plans + brand configs
```

---

## 🚀 Getting Started

### For New Sessions (Claude/AI Assistants)

**Required reading order:**
1. `EYWA_HANDOVER.md` Section 10 (Pre-Flight Checklist)
2. `EYWA_HANDOVER.md` Section 6 (Phase 1 Status — current work)
3. `DECISION_RECORDS.md` (DR-001 through DR-010)
4. Brand-specific README + brand-config.json

### For Developers

1. Read **Bible Part 1** (philosophy)
2. Read **Bible Part 16** (4-tool architecture overview)
3. Read **Bible Part 11** (implementation roadmap)
4. Read **Bible Section 18.9** (Two-Column Identity Pattern) — for any database work
5. Read **Schema v1.8 Appendix F** (Helper Functions) — for SQL development

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
- ✅ Schema upgrade (Bible v3.12 / Schema v1.8)
- ✅ Two-Column Identity Pattern adoption
- ✅ Two-Tier Multilingual Strategy
- ✅ brand_slug standardization
- ⏳ Migration files (26 SQL files planned across Phases 1A-1D)
- ⏳ Helper functions (`generate_ulid()`, fingerprint generators, triggers)

**Migration Plan (26 files):**
- Phase 1A: Foundation (5 migrations) — non-breaking column additions + helpers
- Phase 1B: New Tables (~14 migrations) — create v1.8 tables
- Phase 1C: Triggers & Constraints (4 migrations)
- Phase 1D: Indexes & Performance (3 migrations)

See `EYWA_HANDOVER.md` Section 6 + `PHASE_1_DECISIONS.md` for details.

**Out of Scope (Phase 1):**
- Data migration (existing entity/page data may be discarded)
- n8n workflow rewrites (deferred)
- Notion database restructure (separate effort)

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
| **DR-007** | **In-Place GTGT Schema Upgrade** | 🔒 **Locked (NEW)** |
| **DR-008** | **Two-Column Identity Pattern** | 🔒 **Locked (NEW)** |
| **DR-009** | **Multilingual Strategy v2 (Two-Tier)** | 🔒 **Locked (NEW)** |
| **DR-010** | **Brand Scope Architecture** | 🔒 **Locked (NEW)** |
| DR-011..022 | Various (WordPress hosting, Supabase tier, etc.) | ⏳ Placeholder |

See `DECISION_RECORDS.md` for full rationale.

---

## 📜 Version History

**Bible:**
- **v3.12 (2026-05-08)** — Two-Column Identity + Phase 1 Foundation 🆔🏗️ *(current)*
- v3.11 (2026-05-07) — Two-Phase Hierarchy Sync Pattern 🌳
- v3.10.1 (2026-05-07) — Structural Cleanup 🧹
- v3.10 (2026-05-07) — 2-Tier Schema Strategy Documentation 📐
- v3.9 (2026-05-07) — Multilingual Strategy 🌐
- v3.8 (2026-05-07) — Elementor Pro Integration 🎨
- v3.7 (2026-05-07) — Multi-Brand Federation Pattern 🌐
- v3.6 (2026-05-07) — Universal Scoring Framework 📊
- *(see Bible changelog for full v1.0 → v3.12 history)*

**Schema:**
- **v1.8 (2026-05-08)** — Two-Column Identity + Multilingual v2 🆔🌐 *(current)*
- v1.7 (2026-05-07) — Two-Phase Hierarchy Sync Pattern 🌳
- v1.6 (2026-05-07) — Sync with Bible v3.9 (Multilingual) 🌐
- *(see Schema changelog for full v1.0 → v1.8 history)*

**Handover:**
- **v1.3 (2026-05-08)** — Phase 1 Status section added *(current)*
- v1.2 (2026-05-07) — Per-brand repo folder structure
- v1.1 (2026-05-07) — Planning file schemas
- v1.0 (2026-05-07) — Initial release

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
