# EYWA™ Protocol — Specification

> **Universal Knowledge Graph SEO Specification for Healthcare & Wellness Brands**

[![Bible Version](https://img.shields.io/badge/Bible-v3.10.1-blue)]()
[![Schema Version](https://img.shields.io/badge/Schema-v1.6-green)]()
[![License](https://img.shields.io/badge/License-Proprietary-red)]()

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

| Document | Purpose | Lines |
|----------|---------|-------|
| `EYWA_PROTOCOL_v3_10_1.md` | The Bible — full specification | ~23,800 |
| `Schema_Overview_EYWA_v1_6.md` | Database schema companion | ~2,700 |
| `changelogs/` | Detailed version history | — |
| `decision_records/` | Architecture decision rationale | — |

---

## 🗺️ Specification Coverage

The Bible (`EYWA_PROTOCOL_v3_10_1.md`) is organized into 27 Parts + 3 Appendices:

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
- **Part 28:** Multilingual Strategy (8 languages, AI-draft + human review)

### Reference (Appendices)
- **Appendix A:** Quick Reference Cards
- **Appendix B:** Complete Table & Schema Master List
- **Appendix D:** WordPress Code Reference Library

> **Note:** Part 22 and Appendix C numbering gaps are intentional — content was merged into Parts 24 and Appendix B respectively. Numbering preserved for backward-compatible cross-references.

---

## 🛠️ Implementation Stack

```
Backend (federation, shared):
├─ Supabase (single project, brand_scope filtered)
├─ Notion (multi-team workspaces, mirrored structure)
└─ n8n (sync orchestration)

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
├─ This repo: spec + Schema_Overview
├─ eywa-* repos: plugin code + ACF JSON + Elementor templates
└─ Per-brand repos: content plans + brand configs
```

---

## 🚀 Getting Started

### For Developers
1. Read **Part 1** (philosophy)
2. Read **Part 16** (4-tool architecture overview)
3. Read **Part 11** (implementation roadmap)
4. Refer to specific Parts as needed

### For Designers
1. Read **Part 9** (template anatomy + WCAG AA)
2. Read **Section 25.11** (Elementor Pro integration)
3. Read **Part 28.10** (Elementor + WPML pattern)

### For Editorial Team
1. Read **Part 6** (content standards)
2. Read **Part 23** (medical content excellence)
3. Read **Part 18** (Notion DB usage)

### For Operators
1. Read **Section 10.7** (federation pattern)
2. Read **Part 20** (KPIs)
3. Read **Part 27** (scoring framework)

---

## 📜 Version History

See `EYWA_PROTOCOL_v3_10_1.md` changelog section for full history (26 versions tracked).

**Current version:** v3.10.1 (2026-05-07) — Structural Cleanup

---

## 🔗 Related Repos

| Repo | Purpose |
|------|---------|
| `eywa-acf-fields` | ACF JSON files (universal field structure) |
| `eywa-core` | Foundation plugin |
| `eywa-cpt-activation` | CPT registration plugin |
| `eywa-schema-pipeline` | 3-Layer schema generator plugin |
| `eywa-elementor-templates` | Theme Builder JSON exports |
| `eywa-db-migrations` | SQL migration scripts |
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
