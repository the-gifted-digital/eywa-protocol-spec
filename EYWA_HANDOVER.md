> **EYWA_HANDOVER v1.1** is the latest. Full content in this file.
> Updated: Section 5 (Planning File Schema) + cross-references to Bible v3.11 + Schema v1.7

# 🚀 EYWA™ Protocol — Brand Onboarding Handover

> **For Claude (and any AI assistant) working on a new brand within the EYWA portfolio.**  
> **Read this file first, every new project, every new session.**

**Document Version:** 1.1  
**Last Updated:** 2026-05-07  
**Companion to:** EYWA Bible v3.11 + Schema Overview v1.7  
**Created by:** The Gifted Digital Marketing Co., Ltd.

---

## 📌 What This Document Is

ไฟล์นี้คือ **operating manual** สำหรับ Claude (หรือ AI assistant ใดก็ตาม) ที่จะเริ่มทำงานบน brand ใหม่ภายใต้ EYWA Protocol ecosystem. มันบอกว่า:

- **อ่านอะไรก่อน** เริ่มงาน
- **คิดงานยังไง** ในระบบที่เป็น federation
- **ป้องกันอะไรบ้าง** เพื่อไม่ให้เสียหลักการของ EYWA
- **ทำงานยังไง** ให้ต่อเนื่อง consistent ข้าม sessions
- **เช็คอะไรก่อน** ทุก deliverable
- **Schema สำหรับ planning files** (โครงสร้างตารางที่ใช้)

> **คำเตือนสำคัญ:** EYWA ไม่ใช่แค่ "ทำเว็บ SEO ให้แบรนด์". มันคือ portfolio-wide knowledge graph ที่หลายแบรนด์ใช้ร่วมกัน. ทุก decision ที่ทำสำหรับแบรนด์เดียว อาจกระทบ federation ทั้งหมด. **คิดเสมอว่าคุณกำลังเขียนเข้า shared system, ไม่ใช่ silo.**

---

## 🎯 Section 1 — Project Setup Checklist

### 1.1 Required Files in Project Knowledge

```
☑ EYWA_PROTOCOL_v3_X_X.md          ← Bible (latest version)
☑ Schema_Overview_EYWA_v1_X.md     ← Database schema spec
☑ EYWA_HANDOVER.md                 ← This file
☐ {brand}_concept.md               ← Brand-specific context (optional but preferred)
☐ {brand}_research_notes.md        ← Research data (optional)
```

> **If Bible/Schema are missing or outdated:** STOP. Ask operator to upload latest from GitHub.

### 1.2 Verify GitHub Connection
1. Test GitHub MCP connector on `eywa-protocol-spec`
2. Confirm brand-specific repo `eywa-{brand-slug}` exists
3. Verify write access

### 1.3 Confirm Brand Context
Required: brand basics (name/domain/vertical/format/specialty/branches/languages), unique value (mission/audience/USP/signatures), business context (stage/existing content/competitors/assets).

If brand concept file exists: read first. If not: use Section 6 interview framework.

---

## 🏛️ Section 2 — The Federation Mindset

### 2.1 What "Federation" Means
Shared backend (Supabase + Notion + n8n) → isolated frontends (per-brand WordPress). Decisions on Brand A can affect Brands B-Z.

### 2.2 The brand_scope[] Pattern (CRITICAL)
- `['*']` — Universal (e.g., "TMJ Disorder")
- `['vth-biodent']` — Single-brand exclusive (e.g., "EmSmile®")
- `['vth-biodent', 'vitalsleep']` — Multi-brand subset

### 2.3 Reuse Before Create (HARD RULE)
1. Search seo_entity_graph for `['*']` first
2. Search other brands' entities (consider adopting)
3. Only create new when truly novel

❌ DON'T duplicate "TMJ Disorder" if it exists universally  
✅ DO search FIRST every time

### 2.4 Cross-Brand Decision Awareness
Always ask: affects `['*']`? Other brands benefit? Federation gap or brand quirk? Scales to 5+ brands?

---

## 📚 Section 3 — Source of Truth Hierarchy

### 3.1 Three Sources (priority order)
1. **GitHub (Canonical)** — final truth
2. **Project Knowledge (Cache)** — may lag GitHub
3. **Conversation Context** — verify against GitHub

### 3.2 Update Workflows
- Spec changes → master scope → sandbox → GitHub FIRST → re-upload to brand projects
- Brand-specific → brand project → GitHub eywa-{brand}
- Decisions → DECISION_RECORDS.md → push to appropriate repo

### 3.3 Anti-Drift Rules
1. Single source — no duplicated facts without sync
2. Canonical first — sandbox → GitHub → project knowledge
3. Changelog discipline — every change = version bump
4. Mention version: "Bible v3.11 Part 4..." not just "Part 4..."

---

## 🎨 Section 4 — Brand Uniqueness Philosophy

### 4.1 Core Tenet: "Same Skeleton. Different Soul."

Every brand uses same 8-section sitemap (Bible Part 4.2). NO two brands look/feel the same.

### 4.2 Must Differ Per Brand
Visual design, voice/tone, content emphasis, signature offerings, evidence emphasis.

### 4.3 Must Stay Consistent
Schema markup, citation standards, WCAG AA, knowledge graph integrity, editorial gates.

### 4.4 The Test: Would a User Notice?
1. Visual swap test — feel wrong on another brand?
2. Blind recognition — identify brand without logo?
3. Value prop clarity — unique approach to topic?
4. Journey distinctiveness — why THIS brand?

---

## 📊 Section 5 — Planning File Schema (NEW in v1.1)

> EYWA workflow แยก planning (markdown) กับ implementation (Supabase + Notion). Section นี้กำหนด schema มาตรฐานสำหรับ planning files

### 5.1 Planning vs Implementation

```
PLANNING PHASE (Markdown)              IMPLEMENTATION PHASE (DB)
- Fast iteration                       - Deliberate, validated
- 3-12 columns per file                - Full schema, all columns
- GitHub eywa-{brand}/content-plan/    - Supabase + Notion
- Many iterations                      - Less frequent
```

### 5.2 Required Planning Files

| File | Purpose | Columns |
|------|---------|---------|
| `entities.md` | Knowledge graph entities | 12 |
| `clusters.md` | Topic cluster index | 6 |
| `sitemap.md` | Page hierarchy + properties | 7 |
| `relationships.md` | Typed edges (10 edges per Bible Part 2.7) | 5 |
| `content-priorities.md` (optional) | Editorial calendar | 7 |

### 5.3 Entities Schema (12 columns)

```markdown
## {cluster-id}: {Cluster Name}
**Brand Scope:** ['*']  
**Pillar Page:** {sitemap_node_id}  
**Domain:** {domain-id}

| # | Entity Name | Slug | Type | Schema.org | Parent (text) | ICD-10 | Lifecycle | Primary Page | Aliases | Brand Scope | Notes |
|---|-------------|------|------|------------|---------------|--------|-----------|--------------|---------|-------------|-------|
```

| Column | Required | Description |
|--------|----------|-------------|
| `#` | Yes | Sequential numbering |
| `Entity Name` | Yes | Display name |
| `Slug` | Yes | URL-safe (kebab-case) |
| `Type` | Yes | One of 15 types (Bible Part 2.5) |
| `Schema.org` | Yes | schema.org type |
| `Parent (text)` | Optional | Entity slug (NOT notion_id) |
| `ICD-10` | Optional | ICD-10 code |
| `Lifecycle` | Yes | emerging/growing/mature/deprecated |
| `Primary Page` | Yes | sitemap_node_id |
| `Aliases` | Recommended | Alternative names |
| `Brand Scope` | Yes | `['*']` / `['{brand}']` / multi |
| `Notes` | Optional | Context |

> **Important:** `Parent (text)` uses entity slug — NOT notion_id. See Bible Part 18.8.

### 5.4 Clusters Schema (6 columns)

| Cluster ID | Cluster Name | Domain | Parent Cluster (text) | Pillar Page | Brand Scope |
|------------|--------------|--------|----------------------|-------------|-------------|

### 5.5 Sitemap Schema (7 columns)

```markdown
## Section 5: TREATMENT BY CONCERNS

| # | Page Name | Layer | Tier | Funnel | Page Type | Primary Entity (text) |
|---|-----------|-------|------|--------|-----------|----------------------|
```

| Column | Required | Description |
|--------|----------|-------------|
| `#` | Yes | sitemap_node_id (e.g., "5.2.1") — hierarchy via numbering |
| `Page Name` | Yes | Display name |
| `Layer` | Yes | L1-L7 |
| `Tier` | Yes | A/B/C/D |
| `Funnel` | Yes | top/mid/bottom/retention |
| `Page Type` | Yes | A (Standard) / B (Branch Landing) / C (Programmatic) / D (Tagged) |
| `Primary Entity (text)` | Optional | Entity slug |

> **Hierarchy via numbering:** "5.2.1" auto-child of "5.2" — no separate parent column needed

### 5.6 Relationships Schema (5 columns)

| From Entity | Edge Type | To Entity | Bidirectional | Notes |

**Valid edge types (Bible Part 2.7):** parent_of/child_of, subtype_of, treats/treated_by, symptom_of, uses/used_by, alternative_to, part_of/contains, requires_assessment, evidenced_by, related_to

### 5.7 Content Priorities Schema (7 columns, optional)

| Priority | Page Node | Layer | Tier | Sprint | Status | Owner |

### 5.8 Why "Parent" is Text (Not Notion ID) at Planning

**Critical principle:** ที่ planning phase, ไม่มี Notion ID ยัง. ทุก parent ต้องเป็น text-based.

**Benefits:**
- Human-readable ("tmj-disorder" vs "notion-abc-123")
- Portable (markdown stand-alone)
- Iteration-friendly (edit text, not relations)
- GitHub-friendly (1-line diffs)
- Matches Supabase storage (entity_fingerprint)

**How it becomes native relation:**
- Phase 1: Markdown text refs → Supabase text refs → Notion text properties
- Phase 2: n8n flow resolves text → Notion ID → UPDATE Notion parent_relation
- Result: Notion UI shows tree, markdown stays simple

→ See Bible Part 18.8 for complete pattern

### 5.9 Hierarchy Encoding — Two Methods

**Method 1 (explicit parent column):** entities.md, clusters.md — separate "Parent (text)" column

**Method 2 (implicit via numbering):** sitemap.md — "5.2.1" encodes hierarchy

Both yield same database result via Two-Phase Sync.

---

## 🛠️ Section 6 — Workflow Phases for New Brand

### 6.1 Overview — 7 Phases (A-G)

A: Brand Understanding → B: Research → C: Entity Genesis → D: Cluster Mapping → E: Sitemap → F: Content → G: Deployment

### 6.2 Phase A — Brand Understanding

If brand concept exists: read fully → extract → confirm.  
If not: 20-question interview (identity, competitive, service, journey, business).  
Output: `eywa-{brand}/docs/brand-concept.md`

### 6.3 Phase B — Research & Discovery

Competitor analysis (DataForSEO), keyword research, patient journey mapping, content audit (if migration).  
Output: `eywa-{brand}/content-plan/research-notes.md`

### 6.4 Phase C — Entity Genesis (Bible Part 2.6)

5 steps: brand profile → domain mapping → cluster identification → entity population (Tier 1-3) → relationship wiring → validation. **Search before create.**

Output (per Section 5 schemas): `clusters.md`, `entities.md`, `relationships.md`, `egp-output-summary.md`

### 6.5 Phase D — Cluster & Domain Mapping

Validate: pillar-supporting ratio (8-25), domain balance, cross-brand overlap.

### 6.6 Phase E — Sitemap (Bible Part 4)

5 steps: section assignment → numbered hierarchy → page typing → internal linking → health audit.  
Output: `sitemap.md` (7 cols), `internal-linking-plan.md`, `audit-report.md`

### 6.7 Phase F — Content Production

Per-page: schema planned, citations ≥layer min, author+reviewer, multilingual, WCAG AA, internal links, citable patterns.  
5-stage editorial workflow.

### 6.8 Phase G — Deployment

Pre-launch checklist, Two-Phase Sync execution (Phase 1 flat → Phase 2 backfill → Live).

---

## ⚠️ Section 7 — Red Flags & Quality Gates

### 7.1 STOP Signs

- Knowledge graph: about to create existing entity, edge doesn't fit 10-edge vocab
- Content: citation tier <3 primary, no author/reviewer, quotes >15 words
- Schema: Tier 1+2 not linked, missing hasCredential
- Federation: affects `['*']`, pattern other brands need
- Deployment: WCAG AA fail, LCP >2.5s, schema errors

### 7.2 Quality Gates Per Deliverable

Entity, Cluster, Page, Citation, Schema, Planning files — each has gate checklist.

### 7.3 Continuity Discipline

**Before ending:** commit GitHub, update DR, note next steps  
**Starting:** read this file, read DR, check GitHub, read brand-config, verify versions

---

## 🔄 Section 8 — Update & Sync Protocols

### 8.1 When Spec Changes
1. Read changelog
2. Identify affected work
3. Replace project knowledge files
4. Update brand-config.json
5. Re-validate pending work
6. Document in DR

### 8.2 When Brand Config Changes
Triggers: new service, specialty change, CPT flag, new language.
Steps: update → push → re-run EGP if structural.

### 8.3 When Decision Made
Format: DR-NNN with context/options/choice/rationale/consequences/references. Append-only.

---

## 📋 Section 9 — Pre-Flight Checklist for Every Session

```yaml
context: read handover + Bible + Schema + brand-config + DR + concept
infrastructure: GitHub MCP working, brand repo accessible, versions match
state: phase, last completed, blockers, priority
federation: recent updates, universal entities, cross-brand impact
```

---

## 🌟 Section 10 — Success Criteria

Bootstrap complete when:
- **Knowledge graph:** all entities/clusters/edges done, brand_scope correct
- **Sitemap:** 8 sections decided, all pages 3-dimensions, hierarchy/linking complete, audit passed
- **Content:** 6-month calendar, 5 cornerstones drafted, 50+ citations, voice approved
- **Technical:** Schema Tier 1+2 active, ACF/CPT done, multilingual setup
- **Governance:** DR updated, KPI baseline, editorial active, sync running

---

## 🆘 Section 11 — When in Doubt

- Spec ambiguity → ask + reference Bible + document in DR
- Cross-brand conflict → stop + master spec discussion
- Technical uncertainty → Bible/Schema → ask → don't guess
- Ethical/legal → STOP + flag (PDPA, misinformation, copyright)
- Scope creep → defer + document

---

## 📞 Quick Reference — Key Bible Sections

| Topic | Bible Section |
|-------|---------------|
| Entity Genesis Protocol | Part 2.6 |
| Entity Polymorphism | Part 2.5 |
| Edge Vocabulary (10 edges) | Part 2.7 |
| 8-Section Universal | Part 4.2 |
| Section ↔ Layer Mapping | Part 4.3 |
| Numbered Hierarchy | Part 4.4 |
| 3-Dimensional Page Definition | Part 3.1 |
| 2-Tier Schema Strategy | Section 7.5.0 |
| Schema Pipeline | Part 26 |
| Citation Tier System | Part 23.1 |
| Federation Pattern | Section 10.7 |
| Scoring Framework | Part 27 |
| 15 KPIs | Part 20 |
| Multilingual Strategy | Part 28 |
| **Two-Phase Hierarchy Sync** | **Part 18.8 (NEW v3.11)** |
| Multi-Workspace Sync | Section 18.7 |
| Notion ↔ Supabase Mapping | Section 18.5 |

---

## 🏁 Final Notes

```
✅ Read this file every session
✅ Reference Bible v3.11 + Schema v1.7 for technical decisions
✅ Search before create (entities, citations, clusters)
✅ Document decisions (DECISION_RECORDS.md)
✅ Push to GitHub (canonical source)
✅ Think federation, not silo
✅ Maintain brand uniqueness within shared structure
✅ Quality gates before any deliverable
✅ Escalate when uncertain
✅ Use planning schema (Section 5) — text-based parents

🚫 Never edit Bible from brand context
🚫 Never assume entity doesn't exist without searching
🚫 Never duplicate work across brands
🚫 Never skip citation tier validation
🚫 Never proceed with spec ambiguity unresolved
🚫 Never use notion_id in markdown planning files
```

**Ready to work?** Section 9 (Pre-Flight) → Section 6 (Phase A-G).

🌿 **Welcome to EYWA. Let's build something exceptional.**

---

## 📜 Changelog

### v1.1 (2026-05-07) — Planning Schema Specification 📊
- ➕ **Section 5 (NEW):** Planning File Schema — comprehensive spec
  - 5.2: Required planning file set (5 files)
  - 5.3: Entities schema (12 columns)
  - 5.4: Clusters schema (6 columns)
  - 5.5: Sitemap schema (7 columns)
  - 5.6: Relationships schema (5 columns)
  - 5.7: Content priorities (7 columns, optional)
  - 5.8: Why parent is text (not notion_id) at planning
  - 5.9: Hierarchy encoding methods
- 🔗 References Bible Part 18.8 (Two-Phase Hierarchy Sync)
- 🔗 References Schema_Overview v1.7
- 📌 Section renumbering: previous 5 → 6, etc.

### v1.0 (2026-05-07) — Initial Release
- Complete operating manual for Claude/AI
- 10 sections covering project setup → escalation
- Quick reference to Bible sections

---

*Part of EYWA Protocol governance suite. GitHub: `the-gifted-digital/eywa-protocol-spec/EYWA_HANDOVER.md`*
