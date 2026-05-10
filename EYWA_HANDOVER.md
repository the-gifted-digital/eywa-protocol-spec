# 🚀 EYWA™ Protocol — Brand Onboarding Handover

> **For Claude (and any AI assistant) working on a new brand within the EYWA portfolio.**  
> **Read this file first, every new project, every new session.**

**Document Version:** 1.6  
**Last Updated:** 2026-05-10  
**Companion to:** EYWA Bible v3.14 + Schema Overview v1.10 + DECISION_RECORDS v1.6 + Content_Templates_EYWA_v1_0.md (DRAFT)  
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

## 🎯 Section 1 — Project Setup Checklist (ก่อนเริ่มทุกอย่าง)

### 1.1 Required Files in Project Knowledge

ตรวจให้แน่ใจว่า project นี้มีไฟล์ครบ:

```
☑ EYWA_PROTOCOL_v3_X_X.md          ← Bible (latest version)
☑ Schema_Overview_EYWA_v1_X.md     ← Database schema spec
☑ EYWA_HANDOVER.md                 ← This file
☐ {brand}_concept.md               ← Brand-specific context (optional but preferred)
☐ {brand}_research_notes.md        ← Research data (optional)
```

> **If Bible/Schema are missing or outdated:** STOP. Ask the operator to upload latest versions from `https://github.com/the-gifted-digital/eywa-protocol-spec/`. Do not proceed with stale specs.

### 1.2 Verify GitHub Connection

```yaml
verification_steps:
  
  1. Test GitHub MCP connector:
     → Try reading a file from `the-gifted-digital/eywa-protocol-spec`
     → If fails: alert operator to check MCP permissions
  
  2. Confirm brand-specific repo exists:
     → Format: `the-gifted-digital/eywa-{brand-slug}`
     → If not: ask operator to create it (Private, with README)
  
  3. Verify can write:
     → Test push a small file (e.g., README update)
     → If fails: write access not granted yet
```

### 1.3 Confirm Brand Context

```yaml
required_context_before_work_starts:
  
  brand_basics:
    □ Brand name (legal + display)
    □ Domain (e.g., vth-biodent.com)
    □ Vertical family (healthcare | media | other)
    □ Healthcare format (single_specialty | multi_specialty | dental | hospital | etc.)
    □ Specialty focus (list of services)
    □ Branch count (single | multiple)
    □ Active languages (TH default, others?)
  
  brand_unique_value:
    □ Why this brand exists (mission)
    □ Who it serves (target audience)
    □ What makes it different (USP)
    □ Signature methodologies/products (if any)
  
  business_context:
    □ Stage (pre-launch | active | rebranding)
    □ Existing content (yes — migration | no — greenfield)
    □ Competitor landscape
    □ Existing brand assets (logo, colors, voice)
```

**If brand concept file is provided:** Read it thoroughly first.

**If NOT provided:** Ask the operator structured questions to build understanding (see Section 5).

---

## 🏛️ Section 2 — The Federation Mindset

### 2.1 What "Federation" Means in EYWA

EYWA is **not** a collection of independent brand websites. It is a **knowledge graph federation** where shared backend (Supabase + Notion + n8n) feeds isolated frontends (per-brand WordPress).

**Implication:** When working on Brand A, your decisions can affect Brands B, C, D... You are never "working in isolation" even though the website looks isolated.

### 2.2 The brand_scope[] Pattern (CRITICAL)

Every shared entity, citation, cluster has a `brand_scope[]` field:

- `['*']` — Universal, available to ALL brands (e.g., "TMJ Disorder")
- `['vth-biodent']` — Single-brand exclusive (e.g., "EmSmile®")
- `['vth-biodent', 'vitalsleep']` — Multi-brand shared subset

### 2.3 Reuse Before Create (HARD RULE)

Before creating ANY new entity, citation, or cluster:

1. Search seo_entity_graph for universal (`brand_scope=['*']`)
2. Search for other-brand existing entities (consider adopting)
3. Only create new when truly novel

**Anti-Patterns to AVOID:**
- ❌ Creating "TMJ Disorder" if it already exists universally
- ❌ Duplicating citations across brands
- ✅ Search FIRST, every time

> 🆕 **v1.4 Note — Entity Uniqueness Guard (EUG):** Per Bible v3.14 Section 2.6.6.1, EUG v1.0 enforces "Search Before Create" at the database level via 4 SQL functions. After Phase 1A migration `006_create_entity_uniqueness_guard.sql` deploys, n8n entity creation flows must call `eug_preflight_check()` before INSERT. This catches typos, format variations, and synonym duplicates automatically. See DR-011 for full rationale.

### 2.4 Cross-Brand Decision Awareness

Always ask:
1. Does this affect `['*']` resources?
2. Could other brands benefit?
3. Brand-specific quirk OR federation gap?
4. Will this scale to 5+ more brands?

---

## 📚 Section 3 — Source of Truth Hierarchy

### 3.1 The Three Sources (in priority order)

1. **GitHub (Canonical)** — `the-gifted-digital/eywa-protocol-spec/` and `eywa-{brand}/`. Final truth. GitHub wins on conflicts.
2. **Project Knowledge (Cache)** — Files uploaded to current Claude project. May lag GitHub.
3. **Conversation Context (Working Memory)** — Lowest priority. Always verify against GitHub.

### 3.2 When to Update Each Source

**Spec changes (Bible/Schema):** Master scope → sandbox → GitHub eywa-protocol-spec FIRST → re-upload to all brand projects.

**Brand-specific changes:** Brand project → GitHub eywa-{brand} → if pattern emerges, promote to spec.

**Decisions:** Document in DECISION_RECORDS.md → push to appropriate repo → reference DR-NNN going forward.

### 3.3 Anti-Drift Rules

1. **Single source** — never have 2 places where same fact lives without sync
2. **Canonical first** — sandbox → GitHub → project knowledge
3. **Changelog discipline** — every spec change = version bump + entry
4. **Mention version** — always specify "Bible v3.14 Part 4..." not just "Part 4..."

---

## 🎨 Section 4 — Brand Uniqueness Philosophy

### 4.1 The Core Tenet

> **"Same Skeleton. Different Soul."**

Every EYWA brand uses the **same 8-section sitemap** (Bible Part 4.2): Home, Our Uniqueness, Services, Technology, By Concern, Knowledge, Case Studies, Contact/Branches.

**BUT:** No two EYWA brands should ever look or feel the same. The skeleton is universal. The presentation, content, voice, and emphasis must be unique.

### 4.2 What Must Differ Per Brand

- **Visual design:** color palette, typography, imagery, layout emphasis
- **Voice/tone:** formal vs friendly vs clinical vs luxe
- **Content emphasis:** which section is dominant for this brand
- **Signature offerings:** unique programs/methodologies highlighted
- **Evidence emphasis:** research-led vs story-led vs methodology-led

### 4.3 What Must Stay Consistent

- Schema markup (Tier 1 + Tier 2)
- Citation standards (6 tiers)
- WCAG AA accessibility
- Knowledge graph integrity (entity types, edges)
- Editorial quality gates

### 4.4 The Test: Would a User Notice?

1. **Visual swap test** — copy text to another brand's design — does it feel wrong?
2. **Blind recognition** — without logo, can someone identify the brand?
3. **Value prop clarity** — what's unique about this brand's approach?
4. **Journey distinctiveness** — why choose THIS brand over a sister brand?

---

## 📊 Section 5 — Planning File Schema (NEW in v1.1)

> **Why this section exists:** EYWA workflow แยก **planning** กับ **implementation** ชัดเจน. Planning ทำใน markdown files (.md) — fast iteration, human-readable, GitHub-friendly. Implementation ทำใน Supabase + Notion (production system).

### 5.1 Planning vs Implementation

```yaml
planning_phase:
  location: eywa-{brand}/content-plan/*.md
  format: Markdown tables
  edited_by: AI assistant + brand team
  iterations: many (markdown is fast)
  refs: text-based (slug, sitemap_node_id)

implementation_phase:
  location: Supabase + Notion + WordPress
  format: Database rows + Notion pages
  edited_by: editorial team via Notion UI
  refs: notion_id (after Two-Phase Sync backfill)
```

### 5.2 Planning Files — Required Set

ทุก brand มี planning files เหล่านี้ใน `eywa-{brand}/content-plan/`:

```yaml
required_planning_files:
  
  1_entities.md:
    purpose: "Knowledge graph entities (universal + brand-specific)"
    pattern: Group by topic_cluster, table per cluster
    columns: 12 (see 5.3)
  
  2_clusters.md:
    purpose: "Topic cluster index + metadata"
    pattern: Single master table
    columns: 6 (see 5.4)
  
  3_sitemap.md:
    purpose: "Page hierarchy + properties"
    pattern: Group by section, table per section
    columns: 7 (see 5.5)
  
  4_relationships.md:
    purpose: "Typed edges between entities (10 edges per Bible Part 2.7)"
    pattern: Single master table
    columns: 5 (see 5.6)
  
  5_content_priorities.md (optional):
    purpose: "Editorial calendar + production sequence"
    pattern: Sprint-based grouping
    columns: 7 (see 5.7)
```

### 5.3 Schema — Entities Planning File

**File:** `entities.md` (or per-cluster: `entities/{cluster-id}.md`)

**Structure:**

```markdown
# {Brand Name} — Entity Graph (Planning File)

## Entity Type Distribution
| Type | Count | % |
| ... | ... | ... |

## Topic Cluster Index
(reference to clusters.md)

---

## {cluster-id}: {Cluster Name}
**Brand Scope:** ['*'] | ['{brand}'] | ['{brand}', '{other}']
**Pillar Page:** {sitemap_node_id}
**Domain:** {domain-id}

| # | Entity Name | Slug | Type | Schema.org | Parent (text) | ICD-10 | Lifecycle | Primary Page | Aliases | Brand Scope | Notes |
|---|-------------|------|------|------------|---------------|--------|-----------|--------------|---------|-------------|-------|
| 1 | TMJ Disorder | tmj-disorder | Condition | MedicalCondition | — | M26.609 | Mature | 5.2 | TMD, ... | ['*'] | (link to cluster anchor) |
| 2 | TMJ Pain | tmj-pain | Symptom | Symptom | tmj-disorder | M26.629 | Mature | 5.2.1 | ... | ['*'] | symptom_of relationship |
```

**Column specs (12 columns):**

| Column | Required | Description |
|--------|----------|-------------|
| `#` | Yes | Sequential numbering (within cluster) |
| `Entity Name` | Yes | Display name |
| `Slug` | Yes | URL-safe identifier (kebab-case) |
| `Type` | Yes | One of 15 types (Bible Part 2.5) |
| `Schema.org` | Yes | schema.org type (e.g., MedicalCondition) |
| `Parent (text)` | Optional | text-based parent reference (entity slug) — for Two-Phase Sync |
| `ICD-10` | Optional | ICD-10 code (or "—" if N/A) |
| `Lifecycle` | Yes | emerging / growing / mature / deprecated |
| `Primary Page` | Yes | sitemap_node_id (e.g., "5.2.1") |
| `Aliases` | Recommended | Comma-separated alternative names |
| `Brand Scope` | Yes | `['*']` / `['{brand}']` / `['{brand}', '{other}']` |
| `Notes` | Optional | Additional context, planned relationships, etc. |

> **Important:** `Parent (text)` column uses entity slug — NOT notion_id. Notion ID does not exist yet at planning phase. This is **intentional** — see Bible Part 18.8 (Two-Phase Hierarchy Sync Pattern).

> 🆕 **v1.4 Reminder — EUG impacts entity creation:** When entities are loaded into Supabase via Phase 1 sync (post-EUG migration), `eug_preflight_check()` runs automatically. If `Aliases` column is well-populated at planning phase, Layer 3a (alias collision check) catches synonym duplicates. **Editorial discipline:** populate aliases for all 8 languages where known.

### 5.4 Schema — Clusters Planning File

**File:** `clusters.md`

```markdown
# {Brand Name} — Topic Clusters (Planning File)

| Cluster ID | Cluster Name | Domain | Parent Cluster (text) | Pillar Page | Brand Scope |
|------------|--------------|--------|----------------------|-------------|-------------|
| tmj-orofacial-pain | TMJ & Orofacial Pain | A: TMJ & Jaw | — | 6.1.14 | ['*'] |
| bruxism-clenching | Bruxism & Clenching | A: TMJ & Jaw | tmj-orofacial-pain | 6.1.15 | ['*'] |
```

**Column specs (6 columns):**

| Column | Required | Description |
|--------|----------|-------------|
| `Cluster ID` | Yes | kebab-case-noun-phrase (globally unique) |
| `Cluster Name` | Yes | Display name |
| `Domain` | Yes | Domain ID + name (e.g., "A: TMJ & Jaw") |
| `Parent Cluster (text)` | Optional | Parent cluster ID (for nested SKOS hierarchy) |
| `Pillar Page` | Yes | sitemap_node_id of L5 pillar guide |
| `Brand Scope` | Yes | `['*']` / `['{brand}']` / `['{brand}', '{other}']` |

### 5.5 Schema — Sitemap Planning File

**File:** `sitemap.md`

```markdown
# {Brand Name} — Sitemap (Planning File)

## Tier Distribution
- Tier A: ...
- Tier B: ...

## Layer Distribution
- L1: ...

---

## Section 5: TREATMENT BY CONCERNS (147 pages)

| # | Page Name | Layer | Tier | Funnel | Page Type | Primary Entity (text) |
|---|-----------|-------|------|--------|-----------|----------------------|
| 5.2 | TMJ & Jaw Disorders Hub | L4 | B | top | A | tmj-disorder |
| 5.2.1 | TMJ Pain — symptom guide | L4 | C | top | A | tmj-pain |
```

**Column specs (7 columns):**

| Column | Required | Description |
|--------|----------|-------------|
| `#` | Yes | sitemap_node_id (e.g., "5.2.1") — defines hierarchy via numbering |
| `Page Name` | Yes | Display name |
| `Layer` | Yes | L1-L7 (Bible Part 3.2) |
| `Tier` | Yes | A / B / C / D (Bible Part 3.3) |
| `Funnel` | Yes | top / mid / bottom / retention (Bible Part 3.4) |
| `Page Type` | Yes | A (Standard) / B (Branch Landing) / C (Programmatic) / D (Tagged) |
| `Primary Entity (text)` | Optional | Entity slug if page anchored to specific entity |

> **Hierarchy via numbering:** Page "5.2.1" is automatically child of "5.2" (no separate parent column needed in sitemap — numbering encodes hierarchy)

### 5.6 Schema — Relationships Planning File

**File:** `relationships.md`

```markdown
# {Brand Name} — Entity Relationships (Planning File)

> Edges defined per Bible Part 2.7 (10-edge vocabulary)

| From Entity | Edge Type | To Entity | Bidirectional | Notes |
|-------------|-----------|-----------|---------------|-------|
| tmj-pain | symptom_of | tmj-disorder | No (auto-paired) | Symptom presents as TMJ pain |
| tmj-disorder | treats | tmj-non-surgical | No (auto-paired) | Treatment option |
| tmj-injection | uses | hyaluronic-acid | No (auto-paired) | Material used in injection |
| tmj-disorder | related_to | bruxism | Yes | Bidirectional clinical association |
```

**Column specs (5 columns):**

| Column | Required | Description |
|--------|----------|-------------|
| `From Entity` | Yes | Entity slug (must exist in entities.md) |
| `Edge Type` | Yes | One of 10 edges (Bible Part 2.7) |
| `To Entity` | Yes | Entity slug (must exist in entities.md) |
| `Bidirectional` | Yes | Yes / No (auto-paired edges = No) |
| `Notes` | Optional | Context, evidence link, exceptions |

**Valid edge types (Bible Part 2.7):**
- `parent_of` / `child_of` (paired hierarchy)
- `subtype_of`
- `treats` / `treated_by` (paired)
- `symptom_of`
- `uses` / `used_by` (paired)
- `alternative_to`
- `part_of` / `contains` (paired)
- `requires_assessment`
- `evidenced_by`
- `related_to` (bidirectional default)

> 🆕 **v1.4 Reminder — Edge Vocabulary is LOCKED:** Per Bible v3.14 Section 2.7.5 (Edge Vocabulary Evolution Policy) and DR-012, the 10-edge vocabulary is locked. New edges require formal DR with 4 criteria met (real cases ≥3, cross-brand, schema.org mapping, orthogonality). Use `related_to` + `Notes` for edge cases. See parking lot in DR-012 for future edge candidates.

### 5.7 Schema — Content Priorities Planning File (Optional)

**File:** `content-priorities.md`

```markdown
# {Brand Name} — Content Production Priorities

| Priority | Page Node | Layer | Tier | Sprint | Status | Owner |
|----------|-----------|-------|------|--------|--------|-------|
| 1 | 1.0 | L1 | A | Sprint 1 | Drafting | @writer1 |
| 2 | 2.1 | L1 | B | Sprint 1 | Planned | @writer2 |
| 3 | 3.1 | L2 | A | Sprint 1 | Planned | @writer1 |
```

**Column specs (7 columns):**

| Column | Required | Description |
|--------|----------|-------------|
| `Priority` | Yes | Sequential priority order |
| `Page Node` | Yes | sitemap_node_id |
| `Layer` | Yes | L1-L7 |
| `Tier` | Yes | A/B/C/D (typically Tier A first) |
| `Sprint` | Yes | Sprint identifier |
| `Status` | Yes | Planned / Drafting / Reviewing / Published |
| `Owner` | Yes | Writer/team assigned |

### 5.8 Why "Parent" is Text (Not Notion ID) at Planning

> **Critical principle:** ที่ planning phase, **เราไม่มี Notion ID** เพราะยังไม่ได้ sync เข้า Notion. ทุก parent reference ต้องเป็น **text-based** (entity slug, sitemap_node_id, cluster_id).

**Why this is correct:**

```yaml
benefits_of_text_based_parent:
  
  human_readable:
    "Parent: tmj-disorder" → operator เข้าใจทันที
    "Parent: notion-abc-123-def" → meaningless without lookup
  
  portable:
    Markdown file ทำงานได้ stand-alone
    ไม่ต้อง dependency กับ Notion ID
  
  iteration_friendly:
    เปลี่ยนใจ parent ได้ง่าย — แก้ text refs
    ไม่ต้องไปแก้ relations ใน Notion
  
  github_friendly:
    Diff ของ parent change = 1 line of text
    Reviewable in pull request
  
  matches_supabase_storage:
    Supabase ใช้ entity_fingerprint (text)
    Markdown ก็ใช้ slug เดียวกัน — direct mapping

how_it_becomes_native_relation:
  
  Phase 1 (Flat Load):
    Markdown text refs → Supabase text refs → Notion text properties
  
  Phase 2 (Backfill):
    n8n flow resolves text → Notion ID
    UPDATE Notion: parent_relation = parent's notion_id
  
  Result:
    Notion UI shows tree (relation-based)
    Markdown stays simple (text-based)
    Best of both worlds
```

→ **See Bible Part 18.8** for complete Two-Phase Hierarchy Sync Pattern

### 5.9 Hierarchy Encoding — Two Methods

```yaml
method_1_explicit_parent_column:
  used_in: entities.md, clusters.md
  format: separate "Parent (text)" column
  reason: 
    - Hierarchy is logical, not positional
    - Same-level entities exist (TMJ Pain + Jaw Lock = both children of TMJ Disorder)
    - Explicit clarity

method_2_implicit_via_numbering:
  used_in: sitemap.md
  format: numbered IDs (5.2.1 child of 5.2)
  reason:
    - Hierarchy is positional + sequential
    - Numbering encodes both parent AND order
    - No separate column needed
    - Bible Part 4.4 standard

both_methods_yield_same_database_result:
  Phase 1: text refs in Supabase
  Phase 2: parent_notion_id backfilled
  Phase 3: Notion native relations rendering tree
```

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
│   ├── changelog.md                    # Brand version history
│   └── signature-programs/             # Brand flagship programs (NEW v1.2)
│       ├── README.md                   # Folder index + flagship designation rules
│       └── {program-slug}.md           # Per-program full spec
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
└── reports/                            # 📊 Optional — analysis outputs
    ├── README.md
    ├── monthly-kpi/                    # KPI snapshots per month
    └── audit-snapshots/                # Quality audit results over time
```

#### 5.10.2 Folder Purpose Quick Reference

| Folder | Purpose | When Edited | Required? |
|--------|---------|-------------|-----------|
| Root | Brand identity, federation config | Project init + major changes | ✅ Required |
| `docs/` | Human-authored brand documentation | Frequently | ✅ Required |
| `docs/signature-programs/` | Flagship program specs (e.g., MBM for VTH BioDent) | When new program defined | Optional but recommended |
| `content-plan/` | Markdown planning files (Phase 1 input) | Active during EGP execution | ✅ Required |
| `content-drafts/` | Page draft markdown (pre-Notion) | Active during content production | Recommended |
| `theme/` | Brand-specific Elementor + CSS overrides | When designer iterates | Required for live brands |
| `deployment/` | Infra config metadata (NO secrets) | When infra changes | ✅ Required |
| `reports/` | KPI + audit outputs over time | Monthly | Optional |

#### 5.10.3 Required vs Optional Folders

```yaml
required_for_all_brands:
  - Root (README.md, brand-config.json, .gitignore)
  - docs/
  - content-plan/
  - deployment/

required_for_active_brands:
  - content-drafts/
  - theme/

optional_but_recommended:
  - docs/signature-programs/ (if brand has flagship)
  - reports/

never_in_per_brand_repo:
  - Bible files (live in eywa-protocol-spec)
  - Schema_Overview (lives in eywa-protocol-spec)
  - Shared plugin code (lives in eywa-{plugin} repos)
  - Database secrets / API keys
  - Patient PII data
```

#### 5.10.4 Naming Conventions

```yaml
folder_naming:
  case: kebab-case (lowercase + hyphens)
  format: lowercase-words-separated-by-hyphens
  good_examples:
    - content-plan/
    - signature-programs/
    - acf-overrides/
  bad_examples:
    - ContentPlan/      ❌ PascalCase
    - content_plan/      ❌ snake_case
    - Content Plan/      ❌ spaces
    - contentplan/        ❌ no separator

file_naming:
  case: kebab-case
  format: descriptive-name.md
  good_examples:
    - mouth-biomapping.md
    - tmj-and-bruxism-relief.md
  bad_examples:
    - MouthBioMapping.md     ❌ PascalCase
    - tmj_bruxism.md          ❌ snake_case (use kebab)
    - prog1.md                ❌ not descriptive
```

#### 5.10.5 README Requirements per Folder

ทุก folder ต้องมี README.md ขึ้นต้นด้วย:

```markdown
# {Folder Name} — {Brand Name}

> **Purpose:** {one-line description}  
> **Edited by:** {who maintains this folder}  
> **Lifecycle:** {when files are created vs deleted}

## Files in This Folder

| File | Purpose | Schema Ref |
|------|---------|-----------|
| ... | ... | ... |

## Cross-References

- {link to relevant Bible/Schema sections}
```

เพราะ Claude (และคนใหม่) ที่เข้ามา repo ครั้งแรก ต้อง orient ตัวเองได้ทันที.

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

ก่อนเริ่มทำงานใน brand repo ใหม่ ตรวจ:

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
| Entity Uniqueness Guard 🆕 | Bible Part 2.6.6.1 |
| Edge Vocabulary Evolution 🆕 | Bible Part 2.7.5 |
| Sitemap methodology | Bible Part 4.1 |
| Federation pattern | Bible Section 10.7 |
| Brand-config.json schema | Handover §1.3 |
| Elementor template overrides | Bible Section 25.11.7 |

---


## 🏗️ Section 6 — Phase 1 Status (Supabase Database Foundation)

> **Updated v1.4 (2026-05-08)** — Active phase tracking for Phase 1 work, now including EUG migration. This section documents what is locked, what is pending, and the migration plan for the Supabase database upgrade.

### 6.1 Phase 1 Scope

```yaml
phase_1_supabase_foundation:
  
  goal: "Upgrade GTGT Supabase project schema to align with Bible v3.13 / Schema v1.9"
  
  in_scope:
    - Schema upgrade (ALTER existing tables, CREATE new tables)
    - Helper functions (ULID generator, fingerprint generators, display generators)
    - Triggers (auto-generation, immutability, refresh)
    - Indexes (GIN for jsonb/arrays, B-tree for lookups)
    - Two-Column Identity Pattern application
    - Multilingual jsonb columns (Tier 1) + translation_group_id (Tier 2)
    - brand_slug standardization
    - Entity Uniqueness Guard (EUG) v1.0 — 4 SQL functions + UNIQUE constraint + trigram index 🆕 v1.4
    - brands table Two-Column Identity compliance (fingerprint + brand_slug + display) 🆕 v1.4
  
  out_of_scope:
    - Data migration (existing entity/page data may be discarded)
    - n8n workflow rewrites (deferred to later phase)
    - Notion database restructure (separate effort)
    - WordPress integration (Phase 3+)
    - EEAT scoring implementation (Phase 3+)
    - AI citation tracking (Phase 3+)
    - Performance dashboards (Phase 4+)
    - EUG v2.0 (Wave 2 — vector similarity) — Phase 2 roadmap
```

### 6.2 Locked Decisions (DR-007 through DR-012)

| DR | Title | Status | Source |
|----|-------|--------|--------|
| **DR-007** | In-Place GTGT Schema Upgrade | 🔒 Locked | DECISION_RECORDS.md |
| **DR-008** | Two-Column Identity Pattern | 🔒 Locked | DECISION_RECORDS.md + Bible §18.9 |
| **DR-009** | Multilingual Strategy v2 (Two-Tier) | 🔒 Locked | DECISION_RECORDS.md + Schema Appendix E |
| **DR-010** | Brand Scope Architecture | 🔒 Locked | DECISION_RECORDS.md |
| **DR-011** 🆕 | Entity Uniqueness Guard (Two-Wave) | 🔒 Locked | DECISION_RECORDS.md + Bible §2.6.6.1 + Schema Appendix G |
| **DR-012** 🆕 | Edge Vocabulary Evolution Policy | 🔒 Locked | DECISION_RECORDS.md + Bible §2.7.5 |

**Key Patterns Locked:**

```yaml
fingerprint_format:
  general: "{tablecode}_{ULID16}"  # e.g., "ent_01HZP5K2XQR7N3MF"
  exception: 
    keyword: "{brand_slug}::{market}::{language}::{keyword}"  # existing format kept
  
display_name_format:
  formula: "{fp_last_6}::{type}::{slug_or_name}::{key_data}"
  separator: "::"
  example_entity: "n3mf::condition::sleep-apnea::g47.3"
  example_page: "mfqr::pillar::airway-optimization::th::vth-biodent"
  example_brand: "m4pfq::vth-biodent::VTH BioDent"  # NEW v1.4

multilingual:
  tier_1_concept:
    pattern: "1 row + jsonb translations"
    columns: [canonical_names, aliases, descriptions]
    tables: [ent, clus, brnd, auth, doc, brch, cite]
  
  tier_2_content:
    pattern: "1 row per language + translation_group_id"
    columns: [translation_group_id, page_language, is_source_page, source_translation_fp]
    tables: [page, kw, rev]

brand_scope:
  pattern_a_array: 
    column: "brand_scope text[]"
    tables: [ent, clus, auth, cite]
    examples: ["['*']", "['vth-biodent']", "['vth-biodent', 'vitalsleep']"]
  pattern_b_scalar:
    column: "brand_slug text NOT NULL"  
    tables: [page, doc, brch, kw]

table_codes:
  ent:  seo_entity_graph
  page: seo_website_page_master
  clus: seo_topic_cluster_master
  kw:   seo_x_ads_keywords_contextual_master  # exception
  brnd: brands
  auth: seo_authors
  doc:  seo_brand_doctors
  brch: seo_brand_branches
  cite: seo_citations
  pcit: seo_page_citations
  rev:  seo_editorial_reviews
  aici: seo_ai_citation_tracking
  asc:  seo_brand_authority_scores
  chs:  seo_cluster_health_scores
  eas:  seo_entity_authority_scores
  eeat: seo_eeat_scores
  gov:  seo_governance_audit
  kpi:  seo_kpi_baseline
  tg:   translation_group_id  # namespace, not a table
```

### 6.3 Migration Plan — 27 Files (was 26 in v1.3)

**Phase 1A: Foundation (6 migrations) — Non-Breaking** 🔄 v1.4

```yaml
20260508_001_create_ulid_function.sql:
  purpose: "Pure SQL ULID generator (Crockford Base32, time-encoded)"
  function: generate_ulid() RETURNS text

20260508_002_create_fingerprint_helpers.sql:
  purpose: "Universal fingerprint creator + per-table display generators"
  functions:
    - generate_fingerprint_v2(p_tablecode text)
    - generate_entity_display_name(...)
    - generate_page_display_name(...)
    - generate_brand_display_name(...)
    - generate_cluster_display_name(...)
    - generate_author_display_name(...)
    - generate_doctor_display_name(...)

20260508_003_alter_existing_tables_two_column.sql:
  purpose: "Add fingerprint + fingerprint_display_name columns to existing 13 tables"
  approach: ALTER TABLE ... ADD COLUMN IF NOT EXISTS

20260508_004_alter_existing_tables_multilingual.sql:
  purpose: "Add jsonb columns for Tier 1 multilingual + translation_group_id for Tier 2"
  approach: Additive — preserves existing data

20260508_005_alter_existing_tables_brand_scope.sql:
  purpose: "Standardize brand_scope[] across tables; rename brand_id → brand_slug where needed"
  approach: Additive + backfill

20260508_006_create_entity_uniqueness_guard.sql:  # 🆕 NEW v1.4
  purpose: "Entity Uniqueness Guard (EUG) v1.0 — prevent duplicate entity creation"
  bible_ref: "Section 2.6.6.1 + 2.6.6.2"
  schema_ref: "v1.9 Appendix G"
  decision_ref: "DR-011"
  
  functions:
    - normalize_entity_slug(text) RETURNS text
    - check_alias_collision(text, jsonb, text[]) RETURNS table
    - find_similar_entities(text, real, text[], integer) RETURNS table
    - eug_preflight_check(text, jsonb, text[]) RETURNS table  # combined convenience function
  
  computed_columns:
    - brand_scope_primary text GENERATED ALWAYS AS (...)  # for unique constraint
  
  constraints:
    - UNIQUE (entity_slug, brand_scope_primary) ON seo_entity_graph
  
  triggers:
    - trg_normalize_entity_slug BEFORE INSERT/UPDATE OF entity_slug
  
  indexes:
    - idx_entity_slug_trgm GIN(entity_slug gin_trgm_ops)
    - idx_entity_canonical_names_gin GIN(canonical_names jsonb_path_ops)
    - idx_entity_aliases_gin GIN(aliases jsonb_path_ops)
    - idx_entity_slug_brand_scope (entity_slug, brand_scope_primary)
  
  prerequisites:
    - pg_trgm extension active (already in Required Extensions)
    - Phase 1A files 001-005 applied first
  
  estimated_runtime: "5-10 minutes"
  rollback: "DROP FUNCTION ... CASCADE; DROP CONSTRAINT ...; DROP INDEX ...;"
  breaking_changes: "None — fully additive"
```

**Phase 1B: New Tables (~14 migrations)**

```yaml
goal: "Create v1.9 tables (extension tables, scoring tables, audit tables)"
approach: CREATE TABLE IF NOT EXISTS

migrations:
  20260508_010_alter_brands_two_column_identity.sql:  # ENHANCED v1.4
    purpose: "Bring brands table into Two-Column Identity compliance per DR-008 + DR-010"
    bible_ref: "Section 18.9"
    schema_ref: "v1.9 §3.1"
    
    alterations:
      - ADD COLUMN fingerprint text  # backfilled with brnd_{ULID16}
      - ADD COLUMN fingerprint_display_name text
      - ADD COLUMN brand_slug text  # backfilled from brand_name normalization
    
    triggers_added:
      - trg_set_fingerprint_brand
      - trg_prevent_fingerprint_change (for brands)
      - trg_refresh_display_name_brand
    
    constraints_added:
      - UNIQUE (fingerprint)
      - UNIQUE (brand_slug)
      - CHECK valid_brand_slug (kebab-case validation)
    
    constraints_removed:
      - PRIMARY KEY (brand_name)  # replaced by id UUID PK
    
    backfill_required: yes
    estimated_runtime: "2-5 minutes (15 brands × backfill)"
    breaking_changes: "FK references to brands.brand_name break — must migrate to brands.fingerprint"
    migration_strategy: "Update FK references in subsequent Phase 1B migrations"
  
  # ... 13 more Phase 1B migrations for new tables
  20260508_011_create_seo_topic_cluster_master.sql
  20260508_012_create_seo_authors.sql
  20260508_013_create_seo_brand_doctors.sql
  20260508_014_create_seo_brand_branches.sql
  20260508_015_create_seo_citations.sql
  20260508_016_create_seo_page_citations.sql
  20260508_017_create_seo_editorial_reviews.sql
  20260508_018_create_seo_entity_relationships.sql
  20260508_019_create_seo_entity_embeddings.sql
  20260508_020_create_seo_ai_citation_tracking.sql
  20260508_021_create_seo_authority_scores.sql
  20260508_022_create_seo_governance_audit.sql
  20260508_023_create_seo_kpi_baseline.sql
```

**Phase 1C: Triggers & Constraints (4 migrations)**

```yaml
goal: "Add triggers and constraints for data integrity"
approach: CREATE TRIGGER + ADD CONSTRAINT

migrations:
  20260508_030_add_fingerprint_triggers_existing.sql  # for v1.7-era tables
  20260508_031_add_fingerprint_triggers_new.sql       # for v1.9 new tables
  20260508_032_add_immutability_constraints.sql        # prevent fingerprint changes
  20260508_033_add_fk_constraints.sql                   # FK relationships
```

**Phase 1D: Indexes & Performance (3 migrations)**

```yaml
goal: "Performance optimization"
approach: CREATE INDEX

migrations:
  20260508_040_add_gin_indexes_jsonb.sql      # GIN for jsonb columns
  20260508_041_add_gin_indexes_arrays.sql      # GIN for text[] columns
  20260508_042_add_btree_indexes_lookups.sql   # B-tree for common lookups
```

### 6.4 Phase 1 Success Criteria

Phase 1 is complete when:

- [ ] All v1.9 tables exist in GTGT
- [ ] Two-column identity pattern applied to all relevant tables (incl. brands 🆕)
- [ ] ULID generation function tested and working
- [ ] Multilingual jsonb columns ready for data
- [ ] Triggers prevent fingerprint mutation
- [ ] **Entity Uniqueness Guard (EUG) v1.0 active** 🆕
  - [ ] 4 SQL functions deployed (normalize, check_alias, find_similar, preflight)
  - [ ] UNIQUE constraint on (entity_slug, brand_scope_primary)
  - [ ] Trigram index on entity_slug
  - [ ] Normalize trigger active on INSERT/UPDATE
- [ ] Existing n8n workflows still functional
- [ ] All migrations versioned in git (eywa-supabase-migrations repo)
- [ ] Migration runbook documented
- [ ] Rollback strategy defined

### 6.5 Open Items (Pending Decisions)

```yaml
# 🆕 v1.5 (2026-05-09) — Field-tested feedback from VTH BioDent EGP work
DR-013_edge_vocabulary_v3_5_expansion:
  status: "Proposed (review until 2026-05-20)"
  priority: HIGH
  blocking: false (current Bible v3.13 still functional)
  blocking_phase_1A: false
  blocking_future_bible_v3_14: yes
  
  proposes:
    - Add 2 new edges: causes/caused_by + contraindicates (10 → 12)
    - Add typed edge_note sub-vocabulary (formalize ad-hoc notes)
    - Add edge_evidence_citation field (mandatory for strength≥2)
    - Add medical_reviewer_signoff_at field (mandatory for strength=3)
  
  governance_status_per_DR_012:
    C1_real_cases: "⏳ In Collection (VTH BioDent has multiple, need final 3+)"
    C2_cross_brand: "⏳ PENDING (canvass 14 brands by 2026-05-13)"
    C3_schema_org: "✅ Documented (causeOf, riskFactor, contraindication)"
    C4_orthogonal: "✅ Architect verified"
  
  schema_review_board: "2026-05-15 (Lock or Reject decision)"
  source: "Stream B work order (Naphannop S., VTH BioDent)"
  
  if_locked_2026_05_20:
    triggers: "Build Bible v3.14 + Schema v1.10 + 5 SQL migrations + plugin updates"
    estimated_effort: "58-64 hours (Architect + Tech Lead)"
  
  if_rejected:
    workaround: "VTH BioDent uses related_to + notes with brand_scope=['vth-biodent']"
    consequence: "Reduced schema markup specificity, no functional break"

DR-014_concept_entity_subtype_lock:
  status: "Proposed (review until 2026-05-20)"
  priority: MEDIUM
  blocking: false
  companion_to: DR-013
  
  proposes:
    - Lock entity_subtype controlled vocabulary for concept type:
      - 'framework' (overarching methodology, e.g., VTH BioDent's MBM)
      - 'axis' (causal dimension, e.g., gut-brain axis)
      - 'general' (default fallback)
  
  governance_status_per_DR_012:
    C1_real_cases: "⏳ In Collection (VTH BioDent has 2 examples)"
    C2_cross_brand: "⏳ Pending canvass"
    C3_schema_org: "✅ Documented (additionalType emission)"
    C4_orthogonal: "✅ Architect verified"
  
  schema_review_board: "2026-05-15 (paired with DR-013)"

# Existing pending items (preserved from v1.4)
DR-022_branch_testing_protocol:  # was DR-022 in v1.4 (placeholder still applies)
  question: "Test migrations on Supabase development branch before main?"
  blocking: false
  recommended: yes (low cost, high safety)
  can_decide_during: before first migration applied

DR-024_migration_repo:  # renumbered from DR-022 in v1.5
  question: "Separate eywa-supabase-migrations repo vs subfolder in eywa-protocol-spec?"
  blocking: false
  blocking_phase_1A: false
  can_decide_during: Phase 1A execution

DR-025_notion_sync_scope:  # renumbered from DR-023 in v1.5
  question: "Which v1.9 tables sync to Notion? Which are Supabase-only?"
  blocking: false
  blocking_phase_1A: false
  blocking_phase_1B: partial (affects table design choices)
  can_decide_during: between Phase 1B and Phase 1C
```

### 6.6 Resume Instructions for Next Session

When resuming Phase 1 work, follow this checklist:

```yaml
session_resume_checklist:
  
  step_1_read_priority:
    - DECISION_RECORDS.md (DR-007 through DR-014)  # 🔄 v1.5 (was DR-007..012)
    - Bible Section 18.9 (Two-Column Identity Pattern)
    - Bible Section 2.6.6.1 (Entity Uniqueness Guard)
    - Bible Section 2.6.6.2 (EUG v2.0 Roadmap)
    - Bible Section 2.7.5 (Edge Vocabulary Evolution Policy — DR-012 governance)
    - Schema_Overview Appendix B, E, F, G
    - PHASE_1_DECISIONS.md (Phase 1 quick reference)
  
  step_2_verify_audit_state:
    - Run `Supabase:list_tables` on lffcbeszjqzioobqfdav
    - Compare to "tables_existing: 13" baseline
    - Note any divergence (someone may have added tables manually)
  
  step_3_decide_open_items:
    - DR-020 (migration repo location)
    - DR-021 (Notion sync scope)
    - DR-022 (branch testing)
  
  step_4_choose_starting_action:
    options:
      A: "Start writing Phase 1A migrations (6 SQL files including EUG)"  # 🔄 v1.4
      B: "Export existing 30 migrations to git as historical baseline"
      C: "Set up eywa-supabase-migrations repo structure"
      D: "Create Supabase development branch for testing"
  
  step_5_remember_constraints:
    - Migration files must be idempotent (IF NOT EXISTS, IF EXISTS)
    - Existing 25K+ keyword rows MUST NOT break
    - 6 active n8n workflows MUST continue functioning
    - Operator commits to git themselves (Claude doesn't push)
    - EUG migration is additive, no breaking changes  # 🆕 v1.4
```

### 6.7 Session History (Phase 1 Tracking)

```yaml
session_2026_05_07:
  duration: ~6 hours
  outcomes:
    - GTGT audit completed
    - n8n workflows analyzed (6 workflows)
    - Multilingual strategy designed
    - Two-Phase Hierarchy Sync (DR-006) finalized
    - Bible v3.11 created
    - Schema v1.7 created
    - Handover v1.2 created

session_2026_05_08:
  duration: ~3 hours
  outcomes:
    - Two-Column Identity Pattern designed (DR-008)
    - Multilingual Strategy v2 (DR-009) — Two-Tier
    - Brand Scope Architecture (DR-010)
    - In-Place GTGT Upgrade (DR-007) confirmed
    - Bible v3.12 (Section 18.9 added)
    - Schema v1.8 (Appendices B/E/F)
    - Handover v1.3 (Section 6 added)
    - Phase 1 migration plan (26 files outlined)
  
  status: "Documentation phase complete. Next: write migrations."

session_2026_05_08_part_2:  # 🆕 NEW v1.4
  duration: ~2 hours
  trigger: "Expert review feedback + ontology drift concern from operator"
  outcomes:
    - Entity Uniqueness Guard (EUG) v1.0 designed (DR-011)
    - Edge Vocabulary Evolution Policy (DR-012)
    - Bible v3.13 — Sections 2.6.6.1, 2.6.6.2, 2.7.5
    - Schema v1.9 — Appendix G + brands Two-Column compliance + entity_fingerprint legacy clarification
    - DECISION_RECORDS v1.2 — DR-011 + DR-012
    - Handover v1.4 — Phase 1A migration count: 5 → 6 (added EUG)
    - README v3.13 / v1.9 refresh
  
  fixes_applied:
    - Bible header v3.11 → v3.13 (was incorrect)
    - Schema 4.1 entity_fingerprint legacy clarified
    - Schema 3.1 brands table fingerprint compliance
  
  outputs:
    - 5 patch documents created → applied to full files
    - 0 breaking changes introduced
    - 100% backward compatible
  
  status: "Phase 1A documentation complete + EUG ready for migration writing"

session_2026_05_09:  # 🆕 NEW v1.5
  duration: ~2 hours
  trigger: "VTH BioDent Phase D EGP work (Naphannop S.) surfaced edge vocabulary gap"
  parallel_workstream: "Stream B work order arrived after Stream A (DR-011/012) locked"
  
  collision_detected:
    - "DR-011 number collision (Stream A=EUG, Stream B=Edge Expansion)"
    - "Bible version collision (both wanted v3.13)"
    - "Schema version collision (both wanted v1.9)"
  
  resolution_strategy: "Hybrid Merge"
    - "Stream A locked DRs preserved (DR-011 + DR-012)"
    - "Stream B renumbered → DR-013 + DR-014"
    - "Stream B retargeted → Bible v3.14 + Schema v1.10 (future)"
    - "Apply DR-012 governance to Stream B (4 criteria + 2-week review)"
    - "DR-013 + DR-014 set to Proposed status (NOT locked)"
  
  outcomes:
    - DR-013 (Edge Vocabulary v3.5 Expansion) — Proposed
    - DR-014 (Concept Entity Subtype Lock) — Proposed
    - DECISION_RECORDS v1.2 → v1.3
    - EYWA_HANDOVER v1.4 → v1.5
    - README updated (Decision Records Status table)
  
  governance_milestone: "DR-012 (Edge Evolution Policy) tested for first time"
  
  pending_actions:
    week_1_to_2026_05_13:
      - Architect canvasses 14 other brands for C2 cross-brand evidence
      - Schema Review Board scheduled for 2026-05-15
    
    schema_review_board_2026_05_15:
      - Decision: LOCK or REJECT or REVISE
      - If LOCK → trigger Bible v3.14 + Schema v1.10 build (Stream B's 60h scope)
      - If REJECT → document workaround, communicate to Naphannop
    
    if_locked_phase_1E:
      - 5 SQL migrations (Phase 1E)
      - eywa-schema-pipeline plugin updates
      - eywa-acf-fields field group updates
      - relationships.md template updates
      - genesis_checklist.yaml validation rules
      - Bible v3.14 build (multi-section update)
      - Schema v1.10 build (new fields + Appendix updates)
  
  status: "Governance phase active — DR-013/014 awaiting evidence verification"
  
  files_delivered_session:
    - DECISION_RECORDS.md v1.3 (DR-013 + DR-014 Proposed)
    - EYWA_HANDOVER.md v1.5 (this update)
    - README.md updated (Decision Records Status table)
  
  files_NOT_changed_yet:
    - Bible v3.13 (stays canonical until DR-013/014 lock)
    - Schema v1.9 (stays canonical until DR-013/014 lock)
    - Phase 1A migrations 001-006 (unchanged)

session_2026_05_10:  # 🆕 NEW v1.6
  duration: ~3 hours
  trigger: "VTH BioDent field test feedback (Naphannop S.) — 4 process gaps surfaced during real sitemap design"
  parallel_workstream: "Independent of Stream A/B (DR-013/014 still in governance review)"
  
  problems_surfaced:
    - "Strict EGP vetoed legitimate market-demand pages (e.g., general dentistry)"
    - "Sitemap accepted thin/redundant pages (no quality gate at design time)"
    - "Page intent lost between sitemap design and content writing weeks later"
    - "Word count standards informal — inconsistent depth across pages"
  
  outcomes:
    - DR-015 (Brand Scope Market Reconciliation Pattern) — Locked
    - DR-016 (Page Viability Assessment / Thin Page Detection) — Locked
    - DR-017 (Page Content Brief Field) — Locked
    - DR-018 (Page Content Length Standards) — Locked
    - Bible v3.13 → v3.14 (Sections 4.13, 4.14, 9.8 added)
    - Schema v1.9 → v1.10 (4 new page_master columns)
    - DECISION_RECORDS v1.3 → v1.4
    - EYWA_HANDOVER v1.5 → v1.6 (this update)
    - 2 new migrations: 007_add_content_brief.sql, 008_add_sitemap_design_columns.sql
  
  scope: "Sitemap design layer (Phase E) refinement — independent of DR-013/014 edge work"
  source: "Operator approval 2026-05-10 (single session, all 4 DRs approved together)"
  
  status: "Bible/Schema/Handover/DR all v1.10/v3.14/v1.6/v1.4 synced. Migrations 007/008 ready for Phase 1A."

session_2026_05_10_part_2:  # 🆕 NEW v1.6 (continued — same calendar day)
  duration: ~1.5 hours
  trigger: "BIO DADDY infographic 2026-05-09 → operator request 2026-05-10 → multi-source verification (12+ industry sources) of Google FAQ rich results full deprecation"
  parallel_workstream: "Independent of Stream A/B (DR-013/014) and DR-015..018 sitemap layer"
  
  problem_surfaced:
    - "Google announcement 2026-05-07: FAQ rich results FULL kill (incl. gov/health) effective June 2026"
    - "March 2026 Core Update already deprecated 7 schemas Bible v3.14 doesn't list as forbidden"
    - "EYWA conflates SERP-purpose vs AI-citation-purpose schemas across Part 6/9/25/26"
    - "Existing FAQ rich result KPI plans now obsolete (will be 0 after June 2026)"
  
  outcomes:
    - DR-019 (Schema Strategy for Post-Rich-Results Era) — Proposed
    - DECISION_RECORDS v1.4 → v1.5
    - EYWA_HANDOVER v1.6 (this update — pre-flight + session log)
    - PHASE_1_DECISIONS v1.3 → v1.4 (added DR-019 to Open Items)
    - README updated (Governance section + DR table + Future versions)
  
  scope: "Schema emission layer (Bible Part 26 + Part 9 + Part 20) — independent of edge vocabulary work"
  source: "Operator approval Option B 2026-05-10 — apply as Proposed (4-week review until 2026-06-07)"
  
  governance_milestone: "Second use of Proposed-status pattern (DR-013/014 was first)"
  
  pending_actions:
    review_window:
      - Review until 2026-06-07
      - Final lock targeted 1 week after Google June 2026 effective date
      - Watch for last-minute Google behaviour changes (Rich Results Test removal timing)
    
    if_locked_2026_06_07:
      - Bible v3.15 — Part 26 restructure + Part 9 Featured Snippet section + Part 20 KPI replacement
      - eywa-schema-pipeline plugin update — forbidden schema list enforcement
      - eywa-acf-fields plugin update — remove deprecated schema field groups
      - genesis_checklist.yaml — schema validation rules
      - Audit existing 14 brand sites for 7 deprecated schemas
    
    if_rejected:
      - Document workaround pattern (selective per-page emission via existing schema_markup_planned jsonb)
  
  status: "Proposed — review window active until 2026-06-07. No DDL change. No Phase 1A blocker."

session_2026_05_10_part_3:  # 🆕 NEW v1.6 (continued — same calendar day)
  duration: ~2 hours
  trigger: "Operator request for universal content writing standard + VTH /mouth-biomapping/ EEAT audit reveal + Deezy sitemap gap analysis"
  parallel_workstream: "Independent of DR-013/014, DR-015..018, DR-019 — complements all"
  
  problem_surfaced:
    - "EYWA spec covers WHAT (Bible) + WHERE (Schema) but not HOW to compose content blocks"
    - "VTH /mouth-biomapping/ visual EEAT good (doctor with credentials) but structured EEAT broken (Article author='advthdent' admin)"
    - "Deezy sitemap has 13 distinct page types — no universal template framework"
    - "Operator has working content sample (sleep apnea T1) but no codification across types"
    - "Aesthetic/Wellness/Genomic/Programmatic-Local page types had no template coverage"
  
  outcomes:
    - DR-020 (Universal Content Template Standard) — Proposed
    - Content_Templates_EYWA_v1_0.md DRAFT created (1,456 lines initial — now v1.3 ~2,420 lines after part_4 refinements; 25 templates, ~25 blocks)
    - DECISION_RECORDS v1.5 → v1.6
    - PHASE_1_DECISIONS v1.4 → v1.5 (added DR-020 to Open Items)
    - EYWA_HANDOVER v1.6 (companion ref + content template awareness checklist + this entry)
    - README updated (Governance section + DR table + Future versions + 4th canonical doc reference)
  
  scope: "Content composition layer — complements DR-019 schema emission layer"
  source: "Operator approval Auto Mode 2026-05-10 — apply as Proposed (4-week review until 2026-06-07)"
  
  governance_milestone: "Third use of Proposed-status pattern (DR-013/014, DR-019, DR-020 in same review cycle)"
  
  templates_summary:
    core_universal_12: [T1, T2, T3, T4, T5, T6, T6a_Guide, T7, T8, T9, T10, T11, T12]  
    t2_variants_5: [T2a_Aesthetic, T2b_Dental, T2c_Wellness_Program, T2d_Physiotherapy, T2e_Genomic]
    specialized_7: [T13_Pricing, T14_Trending, T15_Quiz, T16_Insurance, T17_Care_Instructions, T18_Programmatic_Local, T19_Promotion]
    blocks_total: ~25 universal building blocks (B01-B100 placeholder space)
  
  pending_actions:
    review_window:
      - Review until 2026-06-07 (paired with DR-019 cycle)
      - Border cases T6 vs T6a need editorial reviewer judgment
      - T18 Programmatic Local uniqueness enforcement strategy needs decision (manual vs algorithmic)
    
    if_locked_2026_06_07:
      - Upgrade Content_Templates_EYWA_v1_0.md from DRAFT to LOCKED (already at repo root)
      - Bible v3.15 — Part 6 + Part 9 add reference to companion file
      - ACF field group refactor (one group per template, ~15-20h dev)
      - eywa-schema-pipeline plugin — medical_reviewer_fp injection logic (~6h dev)
      - Notion editorial DB — add template_id property + template_version
      - Schema v1.11 (deferred) — add template_id text + template_version jsonb to page_master
      - Phase 2 EEAT enforcement (CHECK constraint) targeted 2026-09-01 after doctor onboarding
    
    if_rejected:
      - Document remains advisory pattern in scratchpad
      - Per-brand customization via existing flexibility (no enforcement)
  
  status: "Proposed — review window active until 2026-06-07. No DDL change for v1.0. No Phase 1A blocker."

session_2026_05_10_part_4:  # 🆕 NEW v1.6 (continued same day — DR-020 internal refinements)
  duration: ~3 hours
  trigger: "Operator review of T1 OSA worked example surfaced UX + content marketing issues"
  parallel_workstream: "Within DR-020 DRAFT lifecycle (still Proposed, no governance change)"
  
  problems_surfaced:
    - "Part 1 of worked example mixed annotations / CSS hints / inline 📌 markers — overwhelming content reviewers + risk of copy-paste error"
    - "Section 2 had 12 rows including ICD/SNOMED/MeSH codes — audience ทั่วไป 99% ไม่รู้จัก, no hook factor"
    - "Spec lacked per-template Quick Facts variations (was 'one-size-fits-all' which doesn't work — T8/T9/T10 etc. need different boxes)"
    - "Missing On-Page SEO Brief table at top (writers couldn't see KW + title/meta char count without scrolling to frontmatter)"
  
  outcomes:
    - Content_Templates v1.0 → v1.1 → v1.2 → v1.3 (3 internal version bumps)
    - examples/T1-medical-condition-SKELETON.md REFACTORED (strict Part 1/Part 2 separation)
    - examples/T1-osa-vth-biodent-WORKED-EXAMPLE.md REFACTORED (clean Part 1, Citation Map in Part 2)
    - NEW examples/SECTION-2-PATTERNS-REFERENCE.md (~534 lines, all 25 templates rendered)
    - README updated (Documents table reflects examples/ files + correct line counts)
  
  v1_2_changes_part_1_part_2_separation:
    - Part 1 = WYSIWYG (no annotations, no CSS, no block codes, no inline citables)
    - On-Page SEO Brief table at top of Part 1 (focus KW, related KWs, title 50-60 char, meta 120-155 char)
    - Part 2 = 9 multi-toggle spec (Section Brief / CSS Map / Citation Map / Schema 1-3 / ACF / Links / Images / Predicted Prompts / Dev Notes)
    - Editorial markers (Pattern A-E) tracked via Citation Map table in Part 2 (NOT inline)
  
  v1_3_changes_section_2_pattern:
    - 5-essential rows + toggle for technical depth (replaces 12-row dump)
    - Reader-centric question labels with icons (👤 Who / 🔍 How known / 💊 Treatable / ✅ Reviewer)
    - Toggle label "▶ ข้อมูลทางเทคนิค (สำหรับผู้สนใจเชิงลึก)"
    - ICD/SNOMED/MeSH codes hidden under toggle (still SEO-indexed, zero penalty per Google 2019+)
    - Per-template Quick Facts variations documented for ALL 25 templates:
      - Group A (16 templates): Standard Quick Facts pattern with template-specific fields
      - Group B (4 templates): T8 patient_profile / T9 credentials / T10 address / T18 branch_hero
      - Group C (3 templates): T11/T13/T19 skip Section 2 entirely
    - Universal Icon Taxonomy locked (35+ icons mapped to consistent use cases)
  
  governance_milestone: "DR-020 spec refined within Proposed status — no governance review needed (still in DRAFT lifecycle)"
  
  status: "Done. Content_Templates_EYWA_v1_0.md now v1.3 internal (~2,420 lines), 3 reference files in examples/. Ready for content writers + production work."
```

---


## 🛠️ Section 7 — Workflow Phases for New Brand

### 7.1 Overview — 2 Stages, 7 Phases (🆕 v1.6 restructured)

```
╔═══════════════════════════════════════════════════════════════════╗
║ STAGE 1 — Foundation & Architecture                               ║
║   PHASE A: Brand Understanding                                    ║
║   PHASE B: Research & Discovery + Citation Pool Seeding 🆕        ║
║   PHASE C: Entity Genesis + Citation-Entity Linking 🆕            ║
║   PHASE D: Cluster & Domain Mapping                               ║
║   PHASE E: Sitemap Architecture (incl. Phase 4.5 Quality Gates)   ║
║                                                                   ║
║   ▶ STAGE 1 GATE: Sitemap Approval ← MUST PASS BEFORE STAGE 2    ║
╚═══════════════════════════════════════════════════════════════════╝
                              ↓
                    [operator approval]
                              ↓
╔═══════════════════════════════════════════════════════════════════╗
║ STAGE 2 — Production & Deployment                                 ║
║   PHASE F: Content Production (uses Stage 1 outputs)              ║
║   PHASE G: Deployment                                             ║
║                                                                   ║
║   ⤴ Backloop allowed: revisit Stage 1 if needed (brand pivot,    ║
║     market reality changes, KW data updates, new entity surfaces) ║
╚═══════════════════════════════════════════════════════════════════╝
```

**Stage discipline:**
- Stage 1 must reach `sitemap-approved` status before Stage 2 begins
- Stage 1 outputs are LOCKED at gate (snapshot version-tagged in git)
- Stage 2 may surface need to revisit Stage 1 — when it happens:
  - Document the trigger (brand change / market data / new entity)
  - Update Stage 1 file → bump version
  - Re-run downstream Stage 1 phases as needed
  - Re-pass Stage 1 Gate before resuming Stage 2

---

## 📦 STAGE 1 — Foundation & Architecture

### 7.2 Phase A — Brand Understanding

**Goal:** Build a complete mental model of the brand before doing anything technical.

**If brand concept document exists:** Read fully → extract vertical/audience/USP/voice → confirm understanding.

**If NOT provided:** Use 20-question interview framework covering identity, competitive, service, audience journey, business context.

**Output:** `eywa-{brand}/docs/brand-concept.md` — get operator approval.

### 7.3 Phase B — Research & Discovery + Citation Pool Seeding 🆕 v1.6

**Part B.1 — Market & Audience Research:**
- **Competitor analysis** (DataForSEO + manual)
- **Keyword research** (DataForSEO Labs + Google Keyword Planner)
- **Patient journey mapping** (interviews + reviews)
- **Existing content audit** (if migration scenario)

**Part B.2 — Citation Pool Seeding 🆕 (Bible Part 23.1 — 6-tier hierarchy):**

For each main pillar topic identified in Phase A/B.1, research authoritative sources BEFORE entity creation. This builds the universal citation pool that downstream phases (C, F) will draw from.

```yaml
citation_research_per_pillar:
  for_each_topic:
    - identify 5-15 authoritative sources covering this topic
    - tier_classification (1-6 per Bible Part 23.1):
        1: Clinical guidelines, government health bodies (AASM, WHO, CDC, FDA, ทันตแพทยสภา)
        2: Peer-reviewed journals (NEJM, JCSM, Cochrane, A&D Journal)
        3: Authoritative medical org publications
        4: Expert-authored books/textbooks
        5: Brand internal data (clinic reports, surveys) — brand_scope=['{brand}']
        6: Reputable secondary sources (medical news, etc.)
    - freshness_check: within tier-specific freshness threshold
    - capture metadata: doi, pmid, pmc_id, isbn, publication_year, url
    - mark brand_scope: ['*'] for universal vs ['{brand}'] for brand-specific
    - check for duplicates against existing seo_citations pool (federation reuse)

priority_targets:
  - L4 pillar topics (need 5-10 Tier 1-3 citations each)
  - L5 knowledge topics (need 3-5 Tier 1-3 each)
  - Brand stance topics (Pattern E backing — need ≥1 Tier 1-2 + brand internal data)
```

**Output Files:**
- `eywa-{brand}/content-plan/research-notes.md` — competitor + KW + audience
- `eywa-{brand}/content-plan/citation-pool-seed.md` 🆕 — citation candidates per pillar with tier + freshness + source URL
  - Schema: matches `seo_citations` table fields (tier, schema_evidence_level, doi, authors, journal, year, url, brand_scope)
  - On Phase G deployment, this file syncs to Supabase `seo_citations`

### 7.4 Phase C — Entity Genesis (EGP — Bible Part 2.6) + Citation Linking 🆕

**Core 5 Steps:**

0. Brand profile validation
1. Domain mapping (3-9 domains: anatomical + methodological + cross-cutting)
2. Cluster identification (15-30 clusters typical)
3. Entity population (Tier 1 mandatory: condition+procedure+treatment; Tier 2 optional; Tier 3 cross-cutting). **Search before create.**
4. Relationship wiring (10-edge vocabulary)
5. Validation (4 health checks)

**Citation-to-Entity Linking 🆕 v1.6 (during Step 3-4):**

As entities are created, attach authoritative citations from Phase B.2 pool:
- Each entity may reference 1-5 anchoring citations (e.g., disease entity → ICD definition source + epidemiology source + clinical guideline)
- Citation_id captured in entity metadata (for federation reuse)
- New citations discovered during entity research → add to `citation-pool-seed.md` (pool grows)

> 🆕 **v1.4 Note — EUG enforces Step 3:** Once Phase 1A migration `006_create_entity_uniqueness_guard.sql` deploys, Step 3 ("Search before create") becomes algorithmically enforced. n8n entity creation flow calls `eug_preflight_check()` before INSERT. See Bible Section 2.6.6.1 for operator decision matrix when collision detected.

**Output Files (per Section 5 schemas):**
- `clusters.md` — cluster index (6 columns)
- `entities.md` (or `entities/{cluster}.md`) — 12 columns per entity (incl. anchoring citation_ids)
- `relationships.md` — 5 columns per edge
- `egp-output-summary.md` — overall stats
- `citation-pool-seed.md` (updated from Phase B with entity-discovery additions)

### 7.5 Phase D — Cluster & Domain Mapping

Validate: pillar-supporting ratio (8-25), domain balance, cross-brand overlap with correct brand_scope[].

### 7.6 Phase E — Sitemap Architecture (Bible Part 4)

5+1 steps (v3.14): section assignment → numbered hierarchy → page typing → **Phase 4.5 Sitemap Quality Gates (§4.1)** 🆕 → internal linking → health audit.

> 🆕 **v1.6 Note — Phase 4.5 Sitemap Quality Gates** (Bible §4.1 Phase 4.5, run in this order):
> - **Gate 1 — Market Reconciliation (§4.13, DR-015):** for healthcare brands, MUST run the 3-step pass (Strict EGP → Reconciliation pass → Operator review). Pages outside strict scope but with high market demand get repackaged via Necessity/Brand-Fit/SEO Opportunity scoring. Status stored in `page_master.marketplace_proposal_status`.
> - **Gate 2 — Page Viability Assessment (§4.14, DR-016):** every page passes the 4-criteria gate (predicted volume, search volume, topic distinctness, intent distinctness). Result stored in `page_master.viability_assessment` (jsonb). Decision: standalone / collapse / merge / exception. **HARD RULE:** L4/L5 pillars NEVER thin.
> - **Gate 3 — Content Brief (DR-017):** every page gets `content_brief` filled at design time. **REQUIRED** for collapsed pages, **RECOMMENDED** for all others. Preserves intent across weeks/writers/AI sessions.
> - **Reference — Content Length Standards (§9.8, DR-018):** word count targets per Layer × Tier × language. Drives QA and informs viability assessment.

**Output:** `sitemap.md` (now 11 columns including `content_brief`, `marketplace_proposal_status`, `reconciliation_notes`, `viability_assessment`), `internal-linking-plan.md`, `audit-report.md`

---

### 🛑 STAGE 1 GATE — Sitemap Approval (🆕 v1.6)

Before proceeding to Stage 2, ALL of the following must be approved by operator:

```yaml
stage_1_gate_checklist:
  
  brand_understanding:
    ☐ brand-concept.md operator-approved
  
  research_complete:
    ☐ research-notes.md (KW + competitor + audience)
    ☐ citation-pool-seed.md (≥5 Tier 1-3 citations per main pillar)
  
  entity_graph_health:
    ☐ entities.md complete (Tier 1 mandatory entities present)
    ☐ relationships.md (10-edge vocabulary, no orphans)
    ☐ EUG preflight clean (no duplicates)
    ☐ 4 health checks passed
    ☐ citation-to-entity linking done (key entities have anchoring citations)
  
  cluster_balance:
    ☐ pillar-supporting ratio 8-25
    ☐ domain balance verified
    ☐ brand_scope[] assigned correctly
  
  sitemap_quality:
    ☐ Phase 4.5 Quality Gates ALL passed (Market Reconciliation + Viability + Content Brief)
    ☐ sitemap.md operator-approved
    ☐ internal-linking-plan.md mapped
    ☐ audit-report.md clean (no orphans, depth OK)
  
  → ✅ ALL CHECKED → Lock Stage 1, version-tag in git, proceed to Stage 2
  → ❌ ANY UNCHECKED → resolve before Stage 2
```

**Lock convention:** `git tag stage-1-approved-{brand}-{YYYY-MM-DD}` to mark approval point. Future Stage 1 revisits create new tags.

---

## 🚀 STAGE 2 — Production & Deployment

### 7.7 Phase F — Content Production

Per-page requirements: schema planned, citations from Phase B.2 pool linked via `seo_page_citations`, author+reviewer assigned, multilingual fields, WCAG AA, internal links per plan, citable patterns used.

**Citation Workflow in Stage 2 🆕 v1.6:**
- Writer pulls from `citation-pool-seed.md` (Phase B.2 output) when writing each page
- Each citation used → row in `seo_page_citations` junction (page_id × citation_id)
- New citations discovered during writing → ADD to pool (new row in `seo_citations`) — pool keeps growing
- Pattern E Brand Stance — backed by Tier 5 brand internal data + ≥1 Tier 1-2 supporting citation

**Template-driven workflow (DR-020):**
- Each page selects template_id (T1-T19) — see `Content_Templates_EYWA_v1_0.md` + `examples/`
- Part 1 = WYSIWYG content (review-ready)
- Part 2 = 9 multi-toggle technical + editorial spec

**5-stage editorial workflow:** Medical → SEO → Brand Voice → Legal/PDPA → Final Sign-off (Bible Part 23.4)

### 7.8 Phase G — Deployment

Pre-launch checklist (entities pushed, schema active, ACF imported, CPTs activated, sitemap.xml, robots.txt, hreflang).

**Two-Phase Sync execution:** Planning files → Phase 1 (Supabase flat — incl. citation pool sync to `seo_citations`) → Phase 2 (Notion backfill) → Live.

---

### 🔄 Stage 1 Backloop Triggers (Stage 2 → Stage 1) 🆕 v1.6

When Stage 2 work surfaces issues requiring Stage 1 changes:

```yaml
common_backloop_triggers:
  
  brand_pivot:
    example: "Operator decides VTH adds Wellness vertical mid-production"
    affects: [Phase A brand-concept, Phase D cluster mapping, Phase E sitemap]
    action: "Re-do A/D/E partial pass; preserve completed Stage 2 pages where possible"
  
  market_data_update:
    example: "KW research returns surprising volume numbers post-launch"
    affects: [Phase B research, Phase E sitemap (viability assessment may flip)]
    action: "Re-run Phase E §4.14 Page Viability for affected pages"
  
  new_entity_surfaces:
    example: "Patient feedback reveals condition we didn't have in Phase C"
    affects: [Phase C entities, Phase D clusters, Phase E sitemap]
    action: "Add entity → check cluster placement → add page if needed"
  
  citation_freshness_expired:
    example: "Tier 1 citation became >5 years old, no replacement found"
    affects: [Phase B.2 citation pool, Phase F pages using that citation]
    action: "Re-research citation alternative → update pool → re-link affected pages"
  
  competitive_response:
    example: "Competitor launches superior content on our pillar topic"
    affects: [Phase B competitor analysis, Phase E sitemap (may need new pages)]
    action: "Refresh Phase B → assess Phase E gap → adjust"

backloop_discipline:
  - Document trigger reason in DECISION_RECORDS or session log
  - Bump version of affected Stage 1 files
  - Create new git tag: `stage-1-revised-{brand}-{YYYY-MM-DD}-{reason-slug}`
  - Notify content team if their in-progress Stage 2 work is affected
  - Re-pass relevant Stage 1 Gate checks before resuming Stage 2
```

---

## ⚠️ Section 8 — Red Flags & Quality Gates

### 8.1 STOP Signs

Stop and escalate to operator if:

**Knowledge graph:**
- About to create entity that "feels familiar" without searching first
- Entity_fingerprint conflicts (or `eug_preflight_check()` returns BLOCK 🆕)
- brand_scope decision impacts other brand's pages
- Edge doesn't fit standard 10 edges (use `related_to` + notes — see DR-012 🆕)

**Content quality:**
- Citation tier <3 used as primary evidence
- Citation older than freshness threshold
- No author/reviewer for medical content
- Direct quotes >15 words (copyright)

**Schema:**
- Tier 1 + Tier 2 not linked via @id
- Page lacks hasCredential when brand is healthcare
- Schema type inconsistent with page Layer

**Federation:**
- Decision affects ['*'] entities
- Pattern emerges that other brands should adopt
- Spec ambiguity affecting multiple brands

**Deployment:**
- WCAG AA failure
- LCP > 2.5s
- Schema validation errors
- Missing alt text/aria labels

### 8.2 Quality Gates Per Deliverable

**Entity:** searched? brand_scope correct? fingerprint unique? type valid? linked to cluster? **EUG preflight passed?** 🆕

**Cluster:** anchor entity? ≥5 entities? L5 pillar planned? naming format? domain mapped?

**Page:** 3 dimensions defined? schema matches Layer? citations meet minimums? author+reviewer? multilingual fields? internal links per plan?

**Citation:** evidence_tier set? within freshness? COI disclosed? schema:MedicalEvidenceLevel mapped?

**Schema:** Tier 1 via WPCode? Tier 2 via Schema Pipeline? @graph + @id? validates in Rich Results Test?

**Planning files:** All required columns present? text-based parents (not notion_id)? brand_scope set?

### 8.3 Continuity Discipline

**Before ending session:** commit to GitHub, update DECISION_RECORDS, note next steps.

**Starting new session:** read this handover, read DECISION_RECORDS, check GitHub for recent commits, read brand-config, verify Bible/Schema versions.

**Cross-session:** never assume previous Claude remembers. Always read DECISION_RECORDS to catch up.

---

## 🔄 Section 9 — Update & Sync Protocols

### 9.1 When Spec Changes

1. Read changelog of new version
2. Identify affected current work
3. Replace project knowledge files (delete old, upload new)
4. Update brand-config.json metadata (eywa_protocol_version)
5. Re-validate pending entities/pages against new spec
6. Document forced refactors in DECISION_RECORDS

### 9.2 When Brand Config Changes

Triggers: new service line, specialty add/remove, CPT flag changes, new language.

Steps: update brand-config.json → push GitHub → if structural, re-run affected EGP steps → update sitemap → re-validate cluster health.

### 9.3 When Decision Made

Document context, options, choice, rationale, consequences, references in DR-NNN format. Append-only. Universal decisions go to eywa-protocol-spec, brand-specific to eywa-{brand}/docs/.

---

## 📋 Section 10 — Pre-Flight Checklist for Every Session

```yaml
session_kickoff_checklist:
  
  context_verification:
    ☐ Read EYWA_HANDOVER.md (this file — v1.6)
    ☐ Read latest Bible version (v3.14 as of 2026-05-10)
    ☐ Read latest Schema version (v1.10 as of 2026-05-10)
    ☐ Read brand-config.json
    ☐ Read DECISION_RECORDS.md (v1.6, DR-001..DR-020 — DR-013/014/019/020 Proposed; DR-015..DR-018 Locked)
    ☐ Read Content_Templates_EYWA_v1_0.md (v1.3 internal DRAFT, ~2,420 lines — pending DR-020 lock)
    ☐ Read brand-concept.md (if exists)
  
  content_production_references:  # 🆕 v1.6 (added 2026-05-10 part 4)
    ☐ Read examples/T1-medical-condition-SKELETON.md (Part 1/Part 2 separation reference)
    ☐ Read examples/T1-osa-vth-biodent-WORKED-EXAMPLE.md (filled example, VTH dental sleep angle)
    ☐ Read examples/SECTION-2-PATTERNS-REFERENCE.md (all 25 templates' Section 2 + Universal Icon Taxonomy)
  
  infrastructure_verification:
    ☐ GitHub MCP working
    ☐ Brand repo accessible
    ☐ Bible version matches latest
  
  state_verification:
    ☐ Current phase (A-G)?
    ☐ Last completed?
    ☐ Blockers?
    ☐ Operator's priority for this session?
  
  federation_verification:
    ☐ Recent updates in seo_entity_graph
    ☐ Universal entities relevant
    ☐ Cross-brand impact noted
  
  governance_verification:  # 🆕 v1.4
    ☐ EUG preflight available? (post-Phase 1A check)
    ☐ Edge vocabulary unchanged from 10 locked edges?
    ☐ brands table Two-Column compliance applied? (post-Phase 1B check)
  
  sitemap_quality_gates:  # 🆕 v1.6 (Phase E)
    ☐ Market Reconciliation pass run? (mandatory for healthcare — Bible §4.13)
    ☐ Page Viability Assessment performed for every page? (Bible §4.14)
    ☐ Content Brief filled for collapsed pages? (Bible §4.5, DR-017)
    ☐ Word count targets reviewed against §9.8 standards?
  
  schema_emission_awareness:  # 🆕 v1.6 (DR-019 Proposed — soft guidance until lock 2026-06-07)
    ☐ Avoid emitting 7 deprecated schemas? (CourseInfo, ClaimReview, EstimatedSalary, LearningVideo, SpecialAnnouncement, VehicleListing, PracticeProblem)
    ☐ FAQPage / HowTo emit OK but expect ZERO SERP rich result post-June 2026? (AI citation only)
    ☐ Featured Snippet pattern applied? (H2/H3 question + 40-60 word direct answer — DR-019 Decision 2)
    ☐ AggregateRating compliant? (min 5 verifiable reviews + crawler-accessible source)
  
  content_template_awareness:  # 🆕 v1.6 (DR-020 Proposed — soft guidance until lock 2026-06-07)
    ☐ Page assigned a template_id? (T1-T19, see Content_Templates_EYWA_v1_0.md)
    ☐ All REQUIRED blocks present per template? (e.g., T1 needs B19 doctor_review_block)
    ☐ EEAT signals match template requirement? (medical YMYL = author + reviewer + lastReviewed REQUIRED)
    ☐ Structured EEAT not just visual? (Article author = Physician, NOT WP admin like 'advthdent')
    ☐ Schema reviewedBy property explicit? (NOT just visual reviewer block)
    ☐ Citations in schema citation array? (NOT text-only in body)
    ☐ Organization typed as MedicalBusiness? (NOT generic Organization for clinics)
    ☐ medicalAudience declared? ({audienceType: 'Patient'} default)
  
  part_1_part_2_separation:  # 🆕 v1.6 (added 2026-05-10 part 4 — DR-020 v1.2)
    ☐ Part 1 = WYSIWYG content only? (NO annotations, NO CSS hints, NO block codes, NO inline 📌 citables)
    ☐ Part 1 starts with On-Page SEO Brief table? (Focus KW, Related KWs, Title 50-60 chars, Meta 120-155 chars)
    ☐ Part 2 has 9 multi-toggle spec? (Section Brief / CSS Map / Citation Map / Schema Tier 1-3 / ACF / Links / Images / Predicted Prompts / Dev Notes)
    ☐ Citation tracking in Part 2 Citation Map? (NOT inline 📌 markers in Part 1)
    ☐ Section Brief table in Part 2 replaces inline 📖 Annotation blockquotes
  
  section_2_pattern_awareness:  # 🆕 v1.6 (added 2026-05-10 part 4 — DR-020 v1.3)
    ☐ Section 2 follows 5-essential + toggle pattern? (NOT 12-row dump)
    ☐ Title row = bold {Disease/Topic} + (English Term)
    ☐ 4 question-format rows with icons? (👤 Who? / 🔍 How known? / 💊 Treatable? / ✅ Reviewer)
    ☐ Toggle "▶ ข้อมูลทางเทคนิค (สำหรับผู้สนใจเชิงลึก)" — collapsed default?
    ☐ ICD/SNOMED/MeSH codes inside toggle (NOT visible by default)?
    ☐ Icons match Universal Icon Taxonomy? (see examples/SECTION-2-PATTERNS-REFERENCE.md)
    ☐ Per-template variation correct? (T8 uses patient_profile / T9 credentials / T10 address / T11/T13/T19 skip Section 2 entirely)
```

---

## 🌟 Section 11 — Success Criteria

A brand is **bootstrap complete** when:

**Knowledge graph:** all entities created/adopted, clusters validated, edges wired, brand_scope correct, **EUG preflight clean** 🆕.

**Sitemap:** 8 sections decided, every page has Layer+Tier+Funnel+Type, hierarchy consistent, linking plan complete, health audit passed.

**Content:** 6-month editorial calendar, first 5 cornerstone pages drafted, 50+ citations, author/reviewer profiles, brand voice approved.

**Technical:** Schema Tier 1 + Tier 2 active, ACF imported, CPTs activated, multilingual setup.

**Governance:** decision records up to date, KPI baseline measured, editorial workflow active, sync flows running.

---

## 🆘 Section 12 — When in Doubt

**Spec ambiguity:** ask operator → reference latest Bible → document interpretation in DECISION_RECORDS

**Cross-brand conflict:** stop → discuss in master spec → resolve before continuing

**Technical uncertainty:** reference Bible/Schema → ask operator → don't guess

**Ethical/legal concern:** STOP → flag immediately (PDPA, medical misinformation, copyright)

**Scope creep:** note as future work → don't expand without approval → document as deferred

---

## 📞 Quick Reference — Key Bible Sections

```yaml
knowledge_graph:
  Entity Genesis Protocol:    Part 2.6
  Entity Uniqueness Guard:    Part 2.6.6.1 🆕 v1.4
  EUG v2.0 Roadmap:           Part 2.6.6.2 🆕 v1.4
  Entity Polymorphism:        Part 2.5
  Edge Vocabulary (10 edges): Part 2.7
  Edge Evolution Policy:      Part 2.7.5 🆕 v1.4

sitemap:
  8-Section Universal:        Part 4.2
  Section ↔ Layer Mapping:    Part 4.3
  Numbered Hierarchy:         Part 4.4
  Health Metrics:             Part 4.10

page_definition:
  3-Dimensional Definition:   Part 3.1
  Layer Definitions (1-7):    Part 3.2
  Tier System (A-D):          Part 3.3
  Funnel Stages:              Part 3.4

schema:
  2-Tier Strategy:            Section 7.5.0 (start here!)
  Tier 1 Implementation:      Section 8.6 (WPCode)
  Tier 2 Implementation:      Part 26 (Schema Pipeline)
  @graph Pattern:             Section 7.5.5

content_quality:
  Citation Tier System:       Part 23.1
  Editorial Review:           Part 23.4
  Citable Patterns (A-F):     Part 6
  WCAG AA:                    Part 23.6

multilingual:
  Strategy Overview:          Part 28
  URL Structure:              Section 28.2
  Schema Per Language:        Section 28.7

federation:
  Federation Pattern:         Section 10.7
  Cross-Brand Tracking:       Section 4.12
  brand_scope Usage:          Throughout, see Section 10.7.3

scoring:
  Scoring Framework:          Part 27
  15 KPIs:                    Part 20

wordpress:
  Stack Decision:             Section 25.11 (Elementor Pro)
  Plugin Architecture:        Part 25
  ACF Fields:                 Section 25.5
  Schema Pipeline:            Part 26

sync_patterns:
  Two-Phase Hierarchy Sync:   Part 18.8
  Two-Column Identity:        Part 18.9
  Multi-Workspace Sync:       Section 18.7
  Notion ↔ Supabase Mapping:  Section 18.5

schema_appendices:
  Required Extensions:        Schema Appendix A
  Fingerprint Patterns:       Schema Appendix B
  Naming Conventions:         Schema Appendix C
  Bible Cross-Reference:      Schema Appendix D
  Multilingual Strategy:      Schema Appendix E
  Helper Functions:           Schema Appendix F
  EUG Implementation:         Schema Appendix G 🆕 v1.4
```

---

## 🏁 Final Notes

```
✅ Read this file every session
✅ Reference Bible + Schema for technical decisions
✅ Search before create (entities, citations, clusters) — EUG enforces this 🆕
✅ Document decisions (DECISION_RECORDS.md)
✅ Push to GitHub (canonical source)
✅ Think federation, not silo
✅ Maintain brand uniqueness within shared structure
✅ Quality gates before any deliverable
✅ Escalate when uncertain
✅ Use planning schema (Section 5) — text-based parents
✅ Populate aliases jsonb at entity creation (helps EUG Layer 3a) 🆕

🚫 Never edit Bible from brand context
🚫 Never assume entity doesn't exist without searching
🚫 Never duplicate work across brands
🚫 Never skip citation tier validation
🚫 Never proceed with spec ambiguity unresolved
🚫 Never use notion_id in markdown planning files
🚫 Never add new edges without DR + 4 criteria met (DR-012) 🆕
```

**Ready to work?** Start with Section 10 (Pre-Flight Checklist), then proceed to the appropriate phase based on brand state.

🌿 **Welcome to EYWA. Let's build something exceptional.**

---

## 📜 Changelog

### v1.5 (2026-05-09) — DR-013 + DR-014 Proposed (Field-Tested Feedback) 🌱

Companion update to DECISION_RECORDS v1.3. Documents Stream B work order arrival (Naphannop S., VTH BioDent) — first test of DR-012 (Edge Vocabulary Evolution Policy) governance.

**Headline Changes:**

- 🔄 **Section 6.5 — Open Items** updated:
  - Added DR-013 (Edge Vocabulary v3.5 Expansion) — Status: Proposed
  - Added DR-014 (Concept Entity Subtype Lock) — Status: Proposed
  - Renumbered remaining placeholders (DR-020/021/022 → DR-022/024/025)
  - Documented governance status per DR-012 4-criteria
  - Documented critical path: C2 (cross-brand) verification by 2026-05-13

- 🔄 **Section 6.6 — Resume Instructions** updated:
  - Added DR-013/014 to required reading

- 🔄 **Section 6.7 — Session History** updated:
  - Added session_2026_05_09 entry documenting Stream B collision + Hybrid Merge resolution
  - Lists files delivered + files preserved unchanged

- 🔄 **Section 10 — Pre-Flight Checklist** updated:
  - Added DR-013/014 to context verification

- 🔗 **Reference updates throughout:**
  - "DR-007..012" → "DR-007..014"
  - DECISION_RECORDS v1.2 → v1.3 references

- 🎯 **Why this matters:**
  - DR-012 governance ทำงานจริง (Stream B is first proposed addition under policy)
  - Bible v3.13 + Schema v1.9 stay canonical (Stream B = future v3.14/v1.10)
  - Field-tested feedback documented officially (not lost in chat history)
  - Schema Review Board has structured documents to review 2026-05-15

- ✅ **Backward compatible:**
  - All v1.5 changes are content additions
  - No new requirements for current Phase 1A work
  - 5 files from v1.4 still valid + uploadable

### v1.4 (2026-05-08) — EUG Integration + Phase 1A Migration Update 🛡️📦

Companion update to Bible v3.13 + Schema v1.9 + DECISION_RECORDS v1.2. Integrates Entity Uniqueness Guard into Phase 1A migration plan + updates references to new versions.

**Headline Changes:**

- 🔄 **Section 6.1 — Phase 1 In-Scope** updated:
  - Added: "Entity Uniqueness Guard (EUG) v1.0 — 4 SQL functions + UNIQUE constraint + trigram index"
  - Added: "brands table Two-Column Identity compliance"

- 🔄 **Section 6.2 — Locked Decisions** updated:
  - Added: DR-011 (Entity Uniqueness Guard — Two-Wave)
  - Added: DR-012 (Edge Vocabulary Evolution Policy)
  - Total locked decisions: DR-007 through DR-012 (was DR-007 through DR-010)
  - Added `example_brand: "m4pfq::vth-biodent::VTH BioDent"` to display name examples

- 🔄 **Section 6.3 — Migration Plan** updated:
  - Phase 1A: 5 → **6 migrations** (added `006_create_entity_uniqueness_guard.sql`)
  - Phase 1B: brands table migration enhanced with Two-Column Identity addition
  - Total Phase 1 migrations: 26 → **27 files**

- 🔄 **Section 6.4 — Success Criteria** updated:
  - Added EUG v1.0 active checklist (4 functions, constraints, indexes, triggers)
  - Added Two-Column compliance for brands

- 🔄 **Section 6.5 — Open Items** renumbered:
  - DR-018 → DR-020 (migration repo)
  - DR-019 → DR-021 (Notion sync scope)
  - DR-020 → DR-022 (branch testing)

- 🔄 **Section 6.6 — Resume Instructions** updated:
  - Added Bible §2.6.6.1 + §2.6.6.2 + §2.7.5 to required reading
  - Updated DR range (DR-007..010 → DR-007..012)
  - Added Schema Appendix G to required reading
  - Phase 1A migration count: 5 → 6 SQL files

- 🔄 **Section 6.7 — Session History** updated:
  - Added session_2026_05_08_part_2 entry documenting EUG work
  - Lists all 5 patch documents created
  - Confirms 0 breaking changes

- 🔄 **Section 7.4 — Phase C** updated:
  - Added EUG enforcement note for Step 3 (Search Before Create)

- 🔄 **Section 8.1 — STOP Signs** updated:
  - Added EUG preflight BLOCK as stop signal
  - Added DR-012 reference for edge vocabulary

- 🔄 **Section 8.2 — Quality Gates** updated:
  - Added "EUG preflight passed?" to Entity gate

- 🔄 **Section 10 — Pre-Flight Checklist** updated:
  - Added governance_verification block (EUG, edge vocab, brands compliance)
  - Updated version refs to Bible v3.13 + Schema v1.9 + DR v1.2

- 🔄 **Section 11 — Success Criteria** updated:
  - Added "EUG preflight clean" to knowledge graph criteria

- 🔄 **Quick Reference** updated:
  - Added Bible Part 2.6.6.1 (EUG)
  - Added Bible Part 2.6.6.2 (EUG v2.0)
  - Added Bible Part 2.7.5 (Edge Evolution)
  - Added Bible Part 18.9 (Two-Column Identity)
  - Added Schema Appendix G

- 🔄 **Final Notes** updated:
  - Added EUG-related ✅ and 🚫 items
  - Added DR-012 reference

- 🔗 **Reference updates throughout:**
  - All "Bible v3.12" references → "Bible v3.13"
  - All "Schema v1.8" references → "Schema v1.9"
  - "Schema_Overview Appendix E, F" → "Schema_Overview Appendix E, F, G"

- 🎯 **Why this matters:**
  - Phase 1A now ships ontology drift prevention (EUG) before scale problem emerges
  - brands table joins all other tables in Two-Column Identity Pattern
  - Migration count increases minimally (+1 file in Phase 1A)
  - Estimated additional Phase 1A work: 1-2 hours
  - Zero impact on Phase 1B/1C/1D timelines

- ✅ **Backward compatible:**
  - All HANDOVER changes are content additions, not behavior changes
  - Existing teams reading v1.3 will not be confused by v1.4 (additive only)
  - Phase 1A migrations 001-005 unchanged from v1.3 plan

### v1.3 (2026-05-08) — Phase 1 Status Section 🏗️

- ➕ **Section 6 (NEW):** Phase 1 Status (Supabase Database Foundation)
  - 6.1: Phase 1 Scope (in/out)
  - 6.2: Locked Decisions (DR-007..010)
  - 6.3: Migration Plan (26 files)
  - 6.4: Success Criteria
  - 6.5: Open Items (pending decisions)
  - 6.6: Resume Instructions
  - 6.7: Session History
- 🔗 References Bible v3.12 + Schema v1.8 + PHASE_1_DECISIONS.md
- 🎯 Active phase tracking for ongoing Phase 1 work

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
- 🎯 Closes gap: comprehensive folder structure was scattered across Bible — now consolidated in one place
- 🎯 Applies to: ALL existing + future per-brand repos
- 🎯 Action item: existing brand repos must align with v1.2 structure

### v1.1 (2026-05-07) — Planning Schema Specification 📊
- ➕ **Section 5 (NEW):** Planning File Schema — comprehensive spec for markdown planning files
  - Section 5.2: Required planning file set (5 files)
  - Section 5.3: Entities schema (12 columns)
  - Section 5.4: Clusters schema (6 columns)
  - Section 5.5: Sitemap schema (7 columns)
  - Section 5.6: Relationships schema (5 columns)
  - Section 5.7: Content priorities schema (7 columns, optional)
  - Section 5.8: Why parent is text (not notion_id) at planning
  - Section 5.9: Hierarchy encoding methods (explicit vs numbering)
- 🔗 References Bible Part 18.8 (Two-Phase Hierarchy Sync Pattern)
- 🔗 References Schema_Overview v1.7 (parent_notion_id + sync_state fields)
- 📌 Section renumbering: previous Section 5 (Workflow Phases) → Section 6, etc.

### v1.0 (2026-05-07) — Initial Release
- Complete operating manual for Claude/AI assistants
- 10 sections covering project setup → escalation paths
- Quick reference to Bible sections

---

*This document is part of the EYWA Protocol governance suite. For updates, see GitHub: `the-gifted-digital/eywa-protocol-spec/EYWA_HANDOVER.md`*
