# 🚀 EYWA™ Protocol — Brand Onboarding Handover

> **For Claude (and any AI assistant) working on a new brand within the EYWA portfolio.**  
> **Read this file first, every new project, every new session.**

**Document Version:** 1.2  
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
- **Folder structure ของ per-brand repo** (NEW v1.2)

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

### 5.10 Per-Brand Repo Folder Structure (NEW in v1.2)

ทุก per-brand repo (`eywa-{brand-slug}`) ต้องใช้โครงสร้างเดียวกัน เพื่อให้ทุก brand work-flow consistent + onboarding ใหม่หา file ไม่หลง.

#### 5.10.1 Standard Folder Tree

```
eywa-{brand-slug}/                       Example: eywa-vth-biodent/
│
├── README.md                           # Brand overview + folder map + quick links
├── brand-config.json                   # Federation config (brand_scope, vertical, languages)
├── .gitignore
│
├── docs/                               # 📚 Brand documentation (human-authored)
│   ├── README.md                       # Index of docs/
│   ├── brand-concept.md                # Brand identity, voice, positioning, USP
│   ├── decision-records.md             # Brand-specific DRs (link global for shared)
│   └── changelog.md                    # Brand version history
│
├── content-plan/                       # 🌳 PLANNING PHASE (markdown — Section 5 schemas)
│   ├── README.md                       # Index + file purpose
│   ├── research-notes.md               # Phase B output (DataForSEO, competitors, journey)
│   ├── entities.md                     # 12-col schema (§5.3) — knowledge graph entities
│   ├── clusters.md                     # 6-col schema (§5.4) — topic cluster index
│   ├── sitemap.md                      # 7-col schema (§5.5) — page hierarchy
│   ├── relationships.md                # 5-col schema (§5.6) — typed edges (10 types)
│   ├── content-priorities.md           # 7-col schema (§5.7, optional) — calendar
│   ├── internal-linking-plan.md        # Phase E output — link strategy
│   ├── audit-report.md                 # Sitemap health audit results
│   └── egp-output-summary.md           # Entity Genesis Protocol summary (Bible 2.6)
│
├── content-drafts/                     # 📝 DRAFTING PHASE (before Notion sync)
│   ├── README.md
│   ├── pillar-pages/                   # Layer 4 pillar drafts (cornerstone content)
│   ├── supporting-pages/               # Layer 5+ supporting drafts
│   └── citations/                      # Curated citation list (pre-Supabase upload)
│
├── theme/                              # 🎨 BRAND VISUAL (Elementor stack)
│   ├── README.md
│   ├── elementor-templates-overrides/  # Brand-specific template tweaks (JSON exports)
│   ├── custom-css/                     # Brand stylesheet overrides (CSS files)
│   ├── site-settings.json              # Elementor Global Colors + Fonts export
│   └── brand-assets/                   # Logo, hero images, mascot, brand photos
│
├── deployment/                         # 🚀 INFRA & SYNC config
│   ├── README.md
│   ├── notion-workspace-config.md      # Notion DB IDs, workspace metadata
│   ├── n8n-flow-overrides.md           # Brand-specific n8n flow tweaks (rare)
│   ├── wp-plugins-list.md              # Active WP plugins for this brand
│   ├── acf-overrides/                  # Brand-specific ACF JSON (if any)
│   └── ENV.md                          # Environment variable names (NO secrets!)
│
├── multilingual/                       # 🌐 i18n (only if multi-language brand)
│   ├── README.md
│   ├── translation-status.md           # Per-page translation status tracker
│   └── glossary.md                     # Brand-specific terminology per language
│
└── reports/                            # 📊 Periodic measurement reports
    ├── README.md
    ├── kpi-baseline.md                 # Day 1 measurement baseline
    ├── monthly/                        # Monthly health reports
    └── quarterly/                      # Quarterly cluster reviews
```

#### 5.10.2 Folder Purpose Quick Reference

| Folder | When to use | Sync target | Authority |
|--------|-------------|-------------|-----------|
| `docs/` | Brand identity, decisions | Manual reference | Brand team |
| `content-plan/` | EGP output, sitemap, planning | → Supabase + Notion (via n8n) | EYWA spec authority |
| `content-drafts/` | Page content before publish | → Notion (manual or n8n) | Editorial team |
| `theme/` | Visual customization | → WordPress (manual deploy) | Designer |
| `deployment/` | Infrastructure config | → n8n / WP / Notion (operational) | DevOps |
| `multilingual/` | i18n tracking | → WPML + Supabase | Translation team |
| `reports/` | KPI measurement | Read-only output | Analytics |

#### 5.10.3 Required vs Optional Folders

```yaml
required_for_every_brand:
  - README.md                    # Always
  - brand-config.json            # Always
  - .gitignore                   # Always
  - docs/                        # Always (at minimum brand-concept.md)
  - content-plan/                # Always (core EYWA workflow)
  - theme/                       # Always (even if minimal — branding required)
  - deployment/                  # Always (Notion config required)

optional_per_brand:
  - content-drafts/              # If using markdown-first drafting
  - multilingual/                # Only if active_languages > 1
  - reports/                     # Generated as KPIs accumulate (Day 30+)
```

#### 5.10.4 Naming Conventions

```yaml
file_naming:
  - kebab-case for markdown: brand-concept.md, internal-linking-plan.md
  - snake_case for JSON: brand-config.json (exception: hyphen ok for top-level)
  - PascalCase NEVER (avoid Windows case-insensitive issues)
  - lowercase for folder names: content-plan/ NOT Content-Plan/

folder_naming:
  - All lowercase
  - Hyphen-separated (kebab-case) for multi-word
  - No underscores in folder names
  - No spaces (ever)

slug_pattern:
  - Brand slug: kebab-case (vth-biodent, the-brand, vital-sleep)
  - Repo name: eywa-{brand-slug}
  - Folder names match slug pattern
```

#### 5.10.5 README Requirements Per Folder

ทุก folder (ยกเว้น root + brand-assets/) ต้องมี `README.md` อธิบาย: folder purpose, files inside, when to update, cross-references to Bible/Handover.

ทำไม? เพราะ Claude (และคนใหม่) ที่เข้ามา repo ครั้งแรก ต้อง orient ตัวเองได้ทันที.

#### 5.10.6 Where Sitemap & Entities Files Live

**ตอบคำถามตรงๆ ที่ถามบ่อย:**

```yaml
"ไซต์แมปเสร็จ + entity เสร็จ จะเก็บที่ไหน?"

answer:
  📁 eywa-{brand-slug}/content-plan/
     ├── entities.md         ← Entity list (§5.3, 12 columns)
     ├── sitemap.md          ← Sitemap (§5.5, 7 columns)
     ├── clusters.md         ← Cluster index (§5.4, 6 columns)
     └── relationships.md    ← Edges (§5.6, 5 columns)

reasoning:
  - "Plan" = ก่อน execute ลง Supabase + Notion
  - "Content" = ครอบ knowledge graph + sitemap + content artifacts
  - Markdown = human-editable + GitHub-diffable
  - Universal: ทุก brand ใช้โครงสร้างเดียวกัน
```

#### 5.10.7 Lifecycle of Planning Files

```yaml
planning_files_lifecycle:

  draft_phase:
    location: eywa-{brand}/content-plan/*.md
    edited_by: AI assistant + brand team (PR review)
    iterations: many (markdown is fast)
    state: text refs only (no notion_id yet)
  
  approved_phase:
    trigger: brand owner approves planning files
    action: commit to GitHub main branch
    state: locked for Phase 1 sync
  
  phase_1_sync:
    trigger: n8n flow `phase_1_load_markdown`
    target: Supabase tables (with text refs as parent fields)
    state: sync_state='flat_loaded'
    
  phase_1_to_notion:
    trigger: n8n flow `phase_1_supabase_to_notion`
    target: Notion (creates pages, captures notion_id back to Supabase)
    state: sync_state='notion_synced'
  
  phase_2_backfill:
    trigger: n8n flow `phase_2_relation_backfill`
    target: Notion (sets parent_relation property)
    state: sync_state='relations_backfilled'
  
  live_phase:
    state: sync_state='live'
    edits: bidirectional Notion ↔ Supabase
    markdown_role: 
      - Historical record (audit trail)
      - Re-baseline source (if rollback needed)
      - NOT the source of truth anymore (DB is)
```

> 🔄 **After Phase 2:** Markdown planning files become **historical reference**. Active edits happen in Notion → propagated to Supabase. Edit markdown only for major restructure (re-baseline scenarios).

#### 5.10.8 What NOT to Put in Per-Brand Repo

```yaml
do_not_store_here:
  ❌ Bible files (lives in eywa-protocol-spec)
  ❌ Schema_Overview (lives in eywa-protocol-spec)
  ❌ DECISION_RECORDS.md global (lives in eywa-protocol-spec)
  ❌ Shared Elementor templates (lives in eywa-elementor-templates)
  ❌ Shared n8n flows (lives in eywa-n8n-flows or central)
  ❌ Database credentials, API keys, passwords (NEVER)
  ❌ Patient/customer PII data (PDPA — never in git)
  ❌ Production-secret URLs with tokens
  ❌ WP plugin code (lives in eywa-{plugin-name} repos)

instead:
  - Reference shared specs by URL/path in docs/
  - brand-config.json links to shared resources
  - deployment/ENV.md lists ENV var NAMES only (values in vault)
```

#### 5.10.9 Repo Initialization Checklist

```yaml
☐ Repo created on GitHub: eywa-{brand-slug}
☐ Set to Private (Internal preferred for org-wide visibility)
☐ Default branch: main
☐ Clone or open via GitHub MCP
☐ All 7 required folders exist (or create them)
☐ All folders have README.md
☐ Root has: README.md, brand-config.json, .gitignore
☐ brand-config.json validated (brand_scope, vertical, languages, branches)
☐ Linked to global EYWA infrastructure:
   - Notion workspace ID in deployment/notion-workspace-config.md
   - Supabase project ID in deployment/ENV.md
   - n8n flow set IDs in deployment/n8n-flow-overrides.md
☐ Initial commit message: "init: EYWA brand structure v1.2"
```

#### 5.10.10 Cross-References

| Topic | See |
|-------|-----|
| Planning file schemas | Handover §5.3-5.7 |
| Why text-based parents | Handover §5.8 |
| Hierarchy encoding | Handover §5.9 |
| Two-Phase Sync pattern | Bible Part 18.8 |
| Entity Genesis Protocol | Bible Part 2.6 |
| Sitemap methodology | Bible Part 4.1 |
| Federation pattern | Bible Section 10.7 |
| Brand-config.json schema | Handover §1.3 |
| Elementor template overrides | Bible Section 25.11.7 |

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
✅ Follow folder structure (Section 5.10) for all per-brand repos

🚫 Never edit Bible from brand context
🚫 Never assume entity doesn't exist without searching
🚫 Never duplicate work across brands
🚫 Never skip citation tier validation
🚫 Never proceed with spec ambiguity unresolved
🚫 Never use notion_id in markdown planning files
🚫 Never store secrets/PII in per-brand repo
```

**Ready to work?** Section 9 (Pre-Flight) → Section 6 (Phase A-G).

🌿 **Welcome to EYWA. Let's build something exceptional.**

---

## 📜 Changelog

### v1.2 (2026-05-07) — Per-Brand Repo Folder Structure 📁
- ➕ **Section 5.10 (NEW):** Per-Brand Repo Folder Structure
  - 5.10.1: Standard folder tree (7 required + 3 optional folders)
  - 5.10.2: Folder purpose quick reference table
  - 5.10.3: Required vs optional folders
  - 5.10.4: Naming conventions (kebab-case, lowercase, no underscores)
  - 5.10.5: README requirements per folder
  - 5.10.6: Where sitemap & entities files live (FAQ answer)
  - 5.10.7: Planning files lifecycle (draft → Phase 1 → Phase 2 → live)
  - 5.10.8: What NOT to put in per-brand repo (security + scope)
  - 5.10.9: Repo initialization checklist
  - 5.10.10: Cross-references to Bible
- 🔗 References Bible Part 18.8, Part 2.6, Section 10.7, Section 25.11.7
- 🎯 Closes gap: comprehensive folder structure was scattered across Bible — now consolidated
- 🎯 Applies to: ALL existing + future per-brand repos
- 🎯 Action item: existing brand repos must align with v1.2 structure

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
