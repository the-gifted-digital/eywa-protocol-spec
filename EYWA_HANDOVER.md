# 🚀 EYWA™ Protocol — Brand Onboarding Handover

> **For Claude (and any AI assistant) working on a new brand within the EYWA portfolio.**  
> **Read this file first, every new project, every new session.**

**Document Version:** 1.0  
**Last Updated:** 2026-05-07  
**Companion to:** EYWA Bible v3.10.1 + Schema Overview v1.6  
**Created by:** The Gifted Digital Marketing Co., Ltd.

---

## 📌 What This Document Is

ไฟล์นี้คือ **operating manual** สำหรับ Claude (หรือ AI assistant ใดก็ตาม) ที่จะเริ่มทำงานบน brand ใหม่ภายใต้ EYWA Protocol ecosystem. มันบอกว่า:

- **อ่านอะไรก่อน** เริ่มงาน
- **คิดงานยังไง** ในระบบที่เป็น federation
- **ป้องกันอะไรบ้าง** เพื่อไม่ให้เสียหลักการของ EYWA
- **ทำงานยังไง** ให้ต่อเนื่อง consistent ข้าม sessions
- **เช็คอะไรก่อน** ทุก deliverable

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
4. **Mention version** — always specify "Bible v3.10.1 Part 4..." not just "Part 4..."

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

## 🛠️ Section 5 — Workflow Phases for New Brand

### Overview — 7 Phases

```
PHASE A: Brand Understanding       ← Before any technical work
PHASE B: Research & Discovery      ← Data gathering
PHASE C: Entity Genesis            ← Knowledge graph building
PHASE D: Cluster & Domain Mapping  ← Topical organization
PHASE E: Sitemap Architecture      ← Page structure
PHASE F: Content Production        ← Writing & validation
PHASE G: Deployment                ← Schema + publish
```

### 5.2 Phase A — Brand Understanding

**If brand concept document exists:** Read fully → extract vertical/audience/USP/voice → confirm understanding.

**If NOT provided:** Use 20-question interview framework covering identity, competitive, service, audience journey, business context. (See Bible-aligned questions in full document version.)

**Output:** `eywa-{brand}/docs/brand-concept.md` — get operator approval.

### 5.3 Phase B — Research & Discovery

- **Competitor analysis** (DataForSEO + manual)
- **Keyword research** (DataForSEO Labs + Google Keyword Planner)
- **Patient journey mapping** (interviews + reviews)
- **Existing content audit** (if migration scenario)

**Output:** `eywa-{brand}/content-plan/research-notes.md`

### 5.4 Phase C — Entity Genesis (EGP — Bible Part 2.6)

**5 Steps:**

0. Brand profile validation
1. Domain mapping (3-9 domains: anatomical + methodological + cross-cutting)
2. Cluster identification (15-30 clusters typical)
3. Entity population (Tier 1 mandatory: condition+procedure+treatment; Tier 2 optional; Tier 3 cross-cutting). **Search before create.**
4. Relationship wiring (10-edge vocabulary)
5. Validation (4 health checks)

**Output Files:**
- `domains/{domain-id}.md`
- `clusters/{cluster-id}.md`
- `entities/{entity-fingerprint}.md`
- `relationships.md`
- `egp-output-summary.md`

### 5.5 Phase D — Cluster & Domain Mapping

Validate: pillar-supporting ratio (8-25), domain balance, cross-brand overlap with correct brand_scope[].

### 5.6 Phase E — Sitemap Architecture (Bible Part 4)

5 steps: section assignment → numbered hierarchy → page typing → internal linking → health audit.

**Output:** `sitemap.md`, `internal-linking-plan.md`, `audit-report.md`

### 5.7 Phase F — Content Production

Per-page requirements: schema planned, citations ≥layer minimum, author+reviewer assigned, multilingual fields, WCAG AA, internal links per plan, citable patterns used.

5-stage editorial workflow: Medical → SEO → Brand Voice → Legal/PDPA → Final Sign-off.

### 5.8 Phase G — Deployment

Pre-launch checklist (entities pushed, schema active, ACF imported, CPTs activated, sitemap.xml, robots.txt, hreflang).

Launch day: monitor GSC, submit sitemap, verify Rich Results, Lighthouse, WCAG audit.

Post-launch: KPI tracking (15 KPIs — Bible Part 20), weekly health audits, monthly content reviews.

---

## ⚠️ Section 6 — Red Flags & Quality Gates

### 6.1 STOP Signs

Stop and escalate to operator if:

**Knowledge graph:**
- About to create entity that "feels familiar" without searching first
- Entity_fingerprint conflicts
- brand_scope decision impacts other brand's pages
- Edge doesn't fit standard 10 edges

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

### 6.2 Quality Gates Per Deliverable

**Entity:** searched? brand_scope correct? fingerprint unique? type valid? linked to cluster?

**Cluster:** anchor entity? ≥5 entities? L5 pillar planned? naming format? domain mapped?

**Page:** 3 dimensions defined? schema matches Layer? citations meet minimums? author+reviewer? multilingual fields? internal links per plan?

**Citation:** evidence_tier set? within freshness? COI disclosed? schema:MedicalEvidenceLevel mapped?

**Schema:** Tier 1 via WPCode? Tier 2 via Schema Pipeline? @graph + @id? validates in Rich Results Test?

### 6.3 Continuity Discipline

**Before ending session:** commit to GitHub, update DECISION_RECORDS, note next steps.

**Starting new session:** read this handover, read DECISION_RECORDS, check GitHub for recent commits, read brand-config, verify Bible/Schema versions.

**Cross-session:** never assume previous Claude remembers. Always read DECISION_RECORDS to catch up.

---

## 🔄 Section 7 — Update & Sync Protocols

### 7.1 When Spec Changes

1. Read changelog of new version
2. Identify affected current work
3. Replace project knowledge files (delete old, upload new)
4. Update brand-config.json metadata (eywa_protocol_version)
5. Re-validate pending entities/pages against new spec
6. Document forced refactors in DECISION_RECORDS

### 7.2 When Brand Config Changes

Triggers: new service line, specialty add/remove, CPT flag changes, new language.

Steps: update brand-config.json → push GitHub → if structural, re-run affected EGP steps → update sitemap → re-validate cluster health.

### 7.3 When Decision Made

Document context, options, choice, rationale, consequences, references in DR-NNN format. Append-only. Universal decisions go to eywa-protocol-spec, brand-specific to eywa-{brand}/docs/.

---

## 📋 Section 8 — Pre-Flight Checklist for Every Session

```yaml
session_kickoff_checklist:
  
  context_verification:
    ☐ Read EYWA_HANDOVER.md (this file)
    ☐ Read latest Bible version
    ☐ Read latest Schema version
    ☐ Read brand-config.json
    ☐ Read DECISION_RECORDS.md (if exists)
    ☐ Read brand-concept.md (if exists)
  
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
```

---

## 🌟 Section 9 — Success Criteria

A brand is **bootstrap complete** when:

**Knowledge graph:** all entities created/adopted, clusters validated, edges wired, brand_scope correct.

**Sitemap:** 8 sections decided, every page has Layer+Tier+Funnel+Type, hierarchy consistent, linking plan complete, health audit passed.

**Content:** 6-month editorial calendar, first 5 cornerstone pages drafted, 50+ citations, author/reviewer profiles, brand voice approved.

**Technical:** Schema Tier 1 + Tier 2 active, ACF imported, CPTs activated, multilingual setup.

**Governance:** decision records up to date, KPI baseline measured, editorial workflow active, sync flows running.

---

## 🆘 Section 10 — When in Doubt

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
  Entity Polymorphism:        Part 2.5
  Edge Vocabulary (10 edges): Part 2.7

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
```

---

## 🏁 Final Notes

```
✅ Read this file every session
✅ Reference Bible + Schema for technical decisions
✅ Search before create (entities, citations, clusters)
✅ Document decisions (DECISION_RECORDS.md)
✅ Push to GitHub (canonical source)
✅ Think federation, not silo
✅ Maintain brand uniqueness within shared structure
✅ Quality gates before any deliverable
✅ Escalate when uncertain

🚫 Never edit Bible from brand context
🚫 Never assume entity doesn't exist without searching
🚫 Never duplicate work across brands
🚫 Never skip citation tier validation
🚫 Never proceed with spec ambiguity unresolved
```

**Ready to work?** Start with Section 8 (Pre-Flight Checklist), then proceed to the appropriate phase based on brand state.

🌿 **Welcome to EYWA. Let's build something exceptional.**

---

*This document is part of the EYWA Protocol governance suite. For updates, see GitHub: `the-gifted-digital/eywa-protocol-spec/EYWA_HANDOVER.md`*
