# 🚀 EYWA™ Protocol — Brand Onboarding Handover

> **For Claude (and any AI assistant) working on a new brand within the EYWA portfolio.**  
> **Read this file first, every new project, every new session.**

**Document Version:** 1.15  
**Last Updated:** 2026-05-18  
**Companion to:** EYWA Bible v3.21 + Schema Overview v1.16 + DECISION_RECORDS v1.15 + Content_Templates_EYWA_v1_0.md v1.7 (LOCKED)  
**Created by:** The Gifted Digital Marketing Co., Ltd.

---

## 🆕 v1.15 Note (2026-05-18) — Universal Brand Design System LOCKED (DR-029)

Bible v3.21 ships with **Part 31 — Universal Brand Design System** per DR-029 Locked 2026-05-18. **Universal scope** — applies to all 13 brand repos + eywa-marketing + future brands, regardless of stack (WP+Elementor or Astro or future).

### What changes for every brand repo

**Two new mandatory folders at brand repo root:**

```
brands/eywa-{brand}/
├── design/                       🎨 Stack-agnostic design layer (NEW)
│   ├── README.md
│   ├── tokens/                   📐 W3C DTCG JSON (source of truth)
│   │   ├── core.tokens.json
│   │   ├── semantic.tokens.json
│   │   ├── component.tokens.json
│   │   └── brand.tokens.json
│   ├── brand-foundation/         📋 6 markdown specs
│   │   ├── color-system.md
│   │   ├── typography.md
│   │   ├── spacing.md
│   │   ├── iconography.md
│   │   ├── imagery.md
│   │   └── motion.md
│   ├── component-specs/          (per-component design spec)
│   ├── page-templates/           (page-level layout spec)
│   ├── wireframes/
│   └── references/
├── brand-assets/                 🖼  Raw binary sources (RELOCATED from theme/brand-assets/)
│   ├── logos/
│   ├── photography/
│   ├── illustrations/
│   └── icons/
└── theme/                        🚀 Stack-specific implementation (preserved naming)
    ├── custom-css/
    └── elementor-templates-overrides/  (WP — or src/ for Astro)
```

### Industry-standard format

`design/tokens/` uses **W3C Design Tokens Community Group (DTCG)** JSON format — recognized by Figma + Tokens Studio + Style Dictionary + design system tools industry-wide. Designers + tools speak this format natively — no brand-specific learning curve.

### Stack-specific consumption (same source, different pipelines)

| Stack | Consumption pipeline |
|-------|----------------------|
| **WP+Elementor** (DR-002 default) | Sync script transforms DTCG → Elementor global colors/fonts JSON → import into Site Settings |
| **Astro** (DR-EYWA-MKT-005 profile) | tailwind.config.mjs auto-imports tokens → npm run build → CSS regenerates |
| **Figma 2-way sync** | Tokens Studio plugin reads/writes design/tokens/ via GitHub |

### Retrofit for existing 13 brands + eywa-marketing

Per DR-029 retrofit policy:
- **At next Stage gate** — operator creates `design/` and `brand-assets/` per Bootstrap Kit
- **Minimum viable retrofit** — `design/tokens/core.tokens.json` filled with primary palette + body typography + base spacing
- **Move existing assets** — `git mv theme/brand-assets/ brand-assets/` preserves history
- **No retroactive deadline** — Pre-Stage 1 brands fill incrementally; brands in Phase E+ should backfill before Phase F

### Operator workload from DR-029

- [ ] Per-brand retrofit (~2-4 hours each at next Stage gate)
- [ ] WP sync script implementation — Style Dictionary + custom Elementor transformer (~4-6 hours one-time)
- [ ] Per-brand DNA Graph (BGP Phase A.1) workshop → fills design/brand-foundation/ + tokens/
- [ ] Decide per-brand whether to adopt Figma + Tokens Studio (depends on hired designer)

### eywa-marketing precedent

eywa-marketing repo already has partial version of this structure (per DR-EYWA-MKT-005). DR-029 generalizes + standardizes DTCG format + extends to all brand repos.

---

## 🆕 v1.14 Note (2026-05-17) — Brand Genesis Protocol Universal (DR-028 LOCKED)

Bible v3.20 ships with **Part 30 — Brand Genesis Protocol (BGP)** per DR-028 Locked 2026-05-17. **Universal scope** — applies to all 13 brand repos AND eywa-marketing (EYWA dogfoods its own protocol).

### What changes for brand onboarding

**Phase A (was: unstructured `brand-concept.md`) is now 5 sub-phases:**

| Sub-phase | Duration | Deliverable | Output file |
|-----------|----------|-------------|-------------|
| **A.0** Pre-Engagement Discovery | 1-2 hr kickoff | Business goals + stakeholders + constraints | `docs/brand-genesis/business-context.md` |
| **A.1** EYWA DNA Graph | 4-6 hr workshop | 10-field brand identity (Brand Key + Compliance Boundaries) | `docs/brand-genesis/eywa-dna-graph.md` |
| **A.2** EYWA Framework Synapse | 2-3 hr | Golden Circle + EYWA Intent Roots (JTBD) + EYWA Journey Map (CDJ) | `docs/brand-genesis/framework-synapse.md` |
| **A.3** EYWA TRUST Rubric Baseline | 3-5 hr audit | 5-pillar audit (Trust/Results/Understanding/Safety/Transparency) | `docs/brand-genesis/eywa-trust-rubric.md` |
| **A.4** Brand-Business-SEO Alignment Map | 2-3 hr | Proves every SEO move serves brand promise + business goal | `docs/brand-genesis/alignment-map.md` |

**Total Phase A:** ~3 weeks (vs prior ~1 week). Phase B-E becomes faster because foundation is clearer.

### EYWA Naming Lexicon (Locked DR-028)

| Concept | EYWA Name | Bible reference |
|---------|-----------|----------------|
| Brand Key (Unilever-adapted) | **EYWA DNA Graph** | §30.4 + §30.11.1 |
| Consumer Decision Journey | **EYWA Journey Map** | §30.5 + §30.11.2 |
| Jobs-to-be-Done | **EYWA Intent Roots** | §30.5 + §30.11.3 |
| Healthcare rubric | **EYWA TRUST Rubric** | §30.6 + §30.11.4 |
| OKR / KPI tracker | **EYWA Compound Growth** | §30.9 + §30.11.5 |
| AI brand-consistency check | **EYWA DNAi Diagnostic** | §30.8 + §30.11.6 |

See Bible §30.11 for full naming definitions (canonical lexicon — do not lose meaning over time).

### EYWA DNAi Diagnostic — TWO touchpoints

1. **Draft-time awareness** (lightweight) — content author references DNA Graph + voice ID during writing. AI co-author prompt includes brand context. Goal: draft enters review 80-90% on-brand.
2. **Pre-publish formal gate** (serious) — Stage 2 in editorial workflow. Claude API check via n8n. Pass/fail + revision suggestions. Block publish on fail.

### Service Suite mapping (productized deliverables)

| Service Tier | BGP Phase Output |
|--------------|------------------|
| **EYWA™ Audit** | Phase A.0-A.3 deliverable package (business-context + DNA Graph + Framework Synapse + TRUST baseline) |
| **EYWA™ Graph** | Phase B-D (Entity Genesis + Knowledge Graph build) |
| **EYWA™ Stack** | Schema implementation + WP/Astro stack setup |
| **EYWA™ Vital** | Phase F content production retainer |
| **EYWA™ Forge** | Phase G growth + iteration retainer |
| **EYWA™ Score** | EYWA Compound Growth dashboard + quarterly reporting |
| **EYWA™ Atlas** | Enterprise multi-brand orchestration |

### Existing 8 brands — backfill required

VTH BioDent · SmileScape · Trin Wellness · Classy Clinic · Deezy · Biodental Wellness · Relaxia · TC Smile — all need Phase A.0-A.4 retrofit at next Stage gate. Estimated 1-2 sessions per brand to backfill.

### Operator workload from DR-028

- [ ] Phase A.1-A.4 sessions per new brand (~10-15 hours)
- [ ] n8n DNAi Diagnostic flow build (one-time ~6-8 hours dev)
- [ ] eywa-marketing pilot — run BGP Phase A on EYWA itself (immediate, dogfood)
- [ ] Retrofit 8 bootstrapped brands at next Stage gate (1-2 sessions each)
- [ ] Per-brand `deployment/dnai-config.yaml` setup (tuning DNAi per brand voice)

---

## 🆕 v1.13 Note (2026-05-12) — Paired Batch Lock: 4 DRs (DR-019/020/021/022)

Operator-approved early lock of 4 paired-cluster DRs originally scheduled for 2026-06-07 review. Justification: 99.99% Google-principle aligned, field-tested across 5 brands, marginal value of waiting < operational cost. Locked together as one coherent governance batch.

### DR-022 LOCKED — Lean Phase B + Two-Layer Sitemap

- **Workflow now canonical** — brands follow lean Phase B (single human-blocking phase, async DFS enrichment, iterative refinement)
- **Two-Layer Sitemap pattern**: Layer 1 (brand-immune services/uniqueness/tech/branches) + Layer 2 (volume-driven concerns/knowledge)
- Currently active: Deezy Dental, Classy Clinic, VTH BioDent, SmileScape, Trin Wellness
- New brands inherit pattern from inception (Bootstrap Kit §1.0 already incorporates)

### DR-021 LOCKED — Internal Linking HYBRID Architecture

- **Schema v1.15** adds: 12 page-level strategy columns on `seo_website_page_master` + new junction table `seo_page_internal_links` (~22 cols) with auto-reciprocal trigger
- **Content_Templates §6 Internal Link Checklist** binds to junction table
- **Brands must declare** per page: `authority_weight`, `node_tier_strategy`, `required_min_inbound/outbound`, `anchor_strategy_mode`
- Cross-brand links require `cross_brand_approved=true` + `cross_brand_justification` (CHECK constraint)

### DR-020 LOCKED — Universal Content Template Standard

- **Content_Templates_EYWA_v1_0.md v1.5 LOCKED** — T1-T22 SEO template family canonical
- T-ADS-X family (DR-026 Proposed) remains pending lock 2026-06-21
- Editorial review now requires `template_id` selection (Bible Part 23.4 stage 1 step)

### DR-019 LOCKED (with Insurance Review Clause)

- **Two-Purpose Schema Taxonomy** locked: `serp_rich_result` / `ai_citation` / `forbidden`
- **7 forbidden schemas**: CourseInfo, ClaimReview, EstimatedSalary, LearningVideo, SpecialAnnouncement, VehicleListing, PracticeProblem — `eywa-schema-pipeline` must block emission
- **Featured Snippet Pattern** mandatory for question-intent pages (Bible Part 9 new sub-section)
- **KPI metrics replaced**: drop FAQ/HowTo rich result impressions; add `ai_citation_rate` per platform + `featured_snippet_capture_rate` + `zero_click_vs_click_ratio`
- **AggregateRating tightening**: min 5 verifiable reviews + crawler-accessible source
- **Insurance Review 2026-06-30** — post-Google-effective-date verification; file Category 2 amendment if needed (Bible §15.2, ~1 hour cost)

### Operator Workload Queue (Phase 1E)

| Migration | DR | Effort |
|-----------|-----|--------|
| 040_add_page_linking_cols.sql | DR-021 | < 5 min |
| 041_create_seo_page_internal_links.sql | DR-021 | < 5 min |
| 042_reciprocal_trigger_fn.sql | DR-021 | < 5 min |
| `eywa-schema-pipeline` plugin update | DR-019 | ~4 hours dev |
| `eywa-acf-fields` plugin update | DR-021 | ~3 hours dev |
| n8n flow updates (orphan + reciprocal + anchor diversity) | DR-021 | ~6 hours |
| Initial brand population × 13 | DR-021 | ~26-39 hours total |

### Brand Snapshot Refresh

All brands currently on `bible_version: 3.18` should refresh `eywa_spec_snapshot` at next Stage gate to pick up v3.19 + Schema v1.15 + Templates v1.5 (LOCKED). No retroactive work required — additive changes only.

---

## 🆕 v1.12 Note (2026-05-12) — Concept Entity Subtype LOCKED (DR-014)

Bible v3.18 + Schema v1.14 ship with **DR-014 Locked** — paired companion to DR-013. When creating new concept entities (`entity_type='concept'`), `entity_subtype` must now be one of:

- **`framework`** — branded methodology / paradigm / clinical protocol (e.g., PNCL-Medicine, Biodental Longevity Protocol™, Classy Design Protocol™, Root-Cause Medicine™). Emits `additionalType="ClinicalFramework"`.
- **`axis`** — causal/relational dimension across systems (e.g., BJGML axis, oral-systemic axis, vascular-sexual axis, HPG axis). Emits `additionalType="BiologicalAxis"`.
- **`general`** — standalone concept term (default fallback). Emits `schema:DefinedTerm`.
- **`NULL`** — backward compat (existing rows preserved; operator can promote later)

**Decision flow:** Does the concept ORGANIZE other concepts? → `framework`. Does it describe a CAUSAL chain across systems? → `axis`. Otherwise → `general` or NULL.

**Pairs with DR-013:** Framework concepts naturally become `parent_of` axes (via Edge 1); axes naturally contain member entities via `part_of` (Edge 7); causal chains across axis members use `causes` (Edge 11) and `contraindicates` (Edge 12). Full cluster pattern in Bible §2.6.10.

**Existing brand work impact:** Brands mid-Stage 1 (Trin Wellness, SmileScape, VTH Biodental Wellness etc.) gain cleaner branded-methodology + axis schema markup at next entity graph revision. No retroactive backfill required.

---

## 🆕 v1.11 Note (2026-05-12) — Edge Vocabulary v3.5 LOCKED (DR-013)

Bible v3.17 + Schema v1.13 ship with **DR-013 Locked** — vocabulary expanded 10 → 12 edges. Brands creating entity relationships must now use:

- **Edge 11 `causes / caused_by`** (paired, directional) — etiological relationships (X → causes → Y). Required `edge_evidence_citation` when `edge_strength ≥ 2`. Use typed `edge_note` (direct / contributing / developmental / hypothesized).
- **Edge 12 `contraindicates`** (symmetric, undirected) — safety hard-block (X ↔ Y must not combine). Required `medical_reviewer_signoff_at` + `medical_reviewer_fp` when `edge_strength = 3` (absolute contraindication). Use typed `edge_note` (absolute / relative-controllable / relative-temporal / interferes-outcome).
- **Typed `edge_note` sub-vocabulary** (Bible §2.7.11) — formalized values per edge type. Free-text still allowed for structural edges (parent_of, subtype_of, etc.) but MANDATORY typed values on causes/caused_by/contraindicates and recommended on related_to, treats, alternative_to, requires_assessment, evidenced_by.

**Existing brand work impact:** Brands currently mid-Stage 1 (Trin Wellness, SmileScape, etc.) gain new edge capacity at next entity graph revision. No retroactive backfill required — existing 10-edge data is preserved. Add new edges as content needs surface.

**Companion DR-014 (Concept Entity Subtype Lock)** remains Proposed — locks separately.

---

## 🆕 v1.10 Note (2026-05-12) — Ads Landing Page Track Proposed

Bible v3.16 ships with **Part 29 — Ads Landing Page Track** per DR-026 (Proposed, target lock 2026-06-21). Brands launching Google Ads should follow:

- **Page rows:** set `page_purpose='ads_lp'`, `ads_template_id='T-ADS-{1-5}'`, `index_directive='noindex_lp'`, `conversion_event_primary`, `campaign_id` (TEXT stub per §29.11 naming convention)
- **Keyword rows:** flag `ad_active=true`, set `ad_intent_score` (1-10), `ad_priority_tier` (t1/t2/t3), `ad_landing_page_fp`
- **Templates:** T-ADS-1 (Hero) / T-ADS-2 (Booking) / T-ADS-3 (Promo) / T-ADS-4 (Comparison) / T-ADS-5 (Lead Magnet) — see Content_Templates v1.4 §3.4
- **YMYL evidence rules UNCHANGED** — Bible Part 23 applies to Ads LPs identically
- **PDPA consent banner MANDATORY** on T-ADS-2/3/5 (any LP with form/booking/capture)
- **Campaign Master Table (DR-027)** = Phase 1, future Schema v1.13+ — Phase 0 brands use `campaign_id` TEXT stub with `{brand-id}-{purpose}-{date-suffix}` naming for migration safety

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

### 1.0 New Brand? Start with Bootstrap Kit 🆕 v1.8

> **If bootstrapping a brand-new brand repo from scratch**, follow:
>
> 📄 **[`templates/NEW_BRAND_BOOTSTRAP.md`](templates/NEW_BRAND_BOOTSTRAP.md)** — step-by-step ~15 min checklist
>
> The templates folder provides:
> - `brand-config.template.json` (federation config baseline)
> - `README.template.md` (brand repo README)
> - `folder-skeleton/` (full directory tree with `.gitkeep` + 7 starter docs)
>
> **Per templates/README.md Flexibility Clause:** Templates are baselines, not strict cages. Brands may add/omit files per real production needs — log deviations in brand `docs/decision-records.md`. Core 4 required: `brand-config.json` / `docs/brand-concept.md` / `docs/decision-records.md` / `docs/changelog.md`.

### 1.1 Required Files in Project Knowledge

ตรวจให้แน่ใจว่า project นี้มีไฟล์ครบ:

```
☑ EYWA_PROTOCOL_v3_X_X.md          ← Bible (latest version)
☑ Schema_Overview_EYWA_v1_X.md     ← Database schema spec
☑ EYWA_HANDOVER.md                 ← This file
☑ DECISION_RECORDS.md              ← DR log (v1.8+)
☑ Content_Templates_EYWA_v1_0.md   ← Content templates (DRAFT v1.3+)
☐ {brand}_concept.md               ← Brand-specific context (optional but preferred)
☐ {brand}_research_notes.md        ← DEPRECATED per DR-022 — use 5 split files in content-plan/
```

> **If Bible/Schema are missing or outdated:** STOP. Ask the operator to upload latest versions from `https://github.com/the-gifted-digital/eywa-protocol-spec/`. Do not proceed with stale specs.
>
> **If brand repo is missing bootstrap structure:** point to `templates/NEW_BRAND_BOOTSTRAP.md` (§1.0 above) before continuing.

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
  
  6_citation-pool-seed.md (🆕 v1.6 — Phase B.2 deliverable):
    purpose: "Authoritative citations seeded during research, before entity creation"
    pattern: Group by pillar topic, table per pillar
    columns: 13 (see 5.8 — mirrors seo_citations table for direct DB sync)
    grows_during: Phase B.2 (breadth) + Phase F step 3 (per-page depth)
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

### 5.8 Schema — Citation Pool Planning File 🆕 v1.6

**File:** `citation-pool-seed.md`

**Phase ที่สร้าง:** B.2 (breadth survey) → ขยายต่อใน F step 3 (per-page depth)

**Structure:**

```markdown
# {Brand Name} — Citation Pool Seed (Planning File)

## Pool Distribution
| Tier | Count | % |
| 1 (Clinical guidelines) | ... | ... |
| 2 (Peer-reviewed) | ... | ... |
| 3 (Authoritative org) | ... | ... |
| 4 (Books/textbooks) | ... | ... |
| 5 (Brand internal) | ... | ... |
| 6 (Reputable secondary) | ... | ... |

## Pillar Topic Index
(reference to clusters.md for pillar mapping)

---

## {pillar-topic-id}: {Pillar Topic Name}
**Cluster:** {cluster-id}
**Phase B.2 minimum:** ≥5 Tier 1-3 citations
**Brand Scope:** ['*'] for universal, ['{brand}'] for brand-specific data

| # | Cite ID | Type | Tier | Schema Evidence | Title | Authors | Journal/Pub | Year | DOI/PMID | URL | Brand Scope | Freshness | Notes |
|---|---------|------|------|-----------------|-------|---------|-------------|------|----------|-----|-------------|-----------|-------|
| 1 | cite_PLACEHOLDER_001 | clinical_guideline | 1 | EvidenceLevelA | Clinical Practice Guideline for Diagnostic Testing for Adult OSA | Kapur et al. | AASM | 2022 | 10.5664/jcsm.6506 | https://aasm.org/... | ['*'] | fresh | Primary OSA diagnosis source |
| 2 | cite_PLACEHOLDER_002 | journal_article | 1 | EvidenceLevelA | Clinical Practice Guideline for OSA Treatment with Oral Appliance | Ramar et al. | JCSM | 2015 | 10.5664/jcsm.4858 | https://jcsm.aasm.org/... | ['*'] | aging | Tier 1 but >10y — flag for refresh check |
| 3 | cite_VTH_INTERNAL_001 | website | 5 | EvidenceLevelC | VTH BioDent OAT 2-Year Outcomes | VTH Clinical Team | VTH | 2025 | — | https://vthbiodent.com/clinical-data/ | ['vth-biodent'] | fresh | Internal data — Pattern A backing |
```

**Column specs (13 columns):**

| Column | Required | Description | Maps to seo_citations field |
|--------|----------|-------------|----------------------------|
| `#` | Yes | Sequential numbering within pillar | — |
| `Cite ID` | Yes | Placeholder ID (`cite_PLACEHOLDER_NNN`) — DB assigns real `cite_{ULID16}` on sync | `fingerprint` |
| `Type` | Yes | journal_article / clinical_guideline / government_report / textbook / website / press_release | `citation_type` |
| `Tier` | Yes | 1-6 (Bible Part 23.1) | `evidence_tier` |
| `Schema Evidence` | Yes | EvidenceLevelA / EvidenceLevelB / EvidenceLevelC | `schema_evidence_level` |
| `Title` | Yes | Citation title | `title` |
| `Authors` | Yes | Comma-separated last names with year | `authors` (text[]) |
| `Journal/Pub` | Optional | Journal name OR publisher | `journal` / `publisher` |
| `Year` | Yes | Publication year (integer) | `publication_year` |
| `DOI/PMID` | Recommended | DOI preferred, PMID/PMC_ID OK; "—" if unavailable | `doi` / `pmid` / `pmc_id` |
| `URL` | Yes | Authoritative URL (publisher/journal site) | `url` |
| `Brand Scope` | Yes | `['*']` (universal — reusable across brands) or `['{brand}']` (brand-internal data) | (federation logic) |
| `Freshness` | Yes | fresh / aging / stale (per Bible Part 23.1 tier-specific thresholds) | `citation_freshness_status` |
| `Notes` | Optional | Context, e.g., "Primary OSA diagnosis source" / "Pattern A backing for VTH stance" | — |

**Cite ID convention:**
- `cite_PLACEHOLDER_NNN` during planning
- On Phase G publish, n8n flow generates real `cite_{ULID16}` from `seo_citations` trigger
- Maintain mapping in this file for backtracking

**Tier classification rules (Bible Part 23.1):**

| Tier | Source Type | Examples | Freshness Threshold |
|------|-------------|----------|---------------------|
| 1 | Clinical guidelines / gov health bodies | AASM, WHO, CDC, FDA, ทันตแพทยสภา | 5 years |
| 2 | Peer-reviewed journals | NEJM, JCSM, Cochrane, A&D Journal | 5 years (3 for emerging fields) |
| 3 | Authoritative medical org publications | Specialty associations (AADSM, AAOMS, etc.) | 5 years |
| 4 | Expert-authored books/textbooks | Standard textbooks | 7 years |
| 5 | Brand internal data | Clinic outcomes report, surveys | 2 years (data ages quickly) |
| 6 | Reputable secondary sources | Medical news (NYT Health, BBC Health) | 2 years |

**Federation reuse rule:**
- Before adding new citation: check if same DOI/PMID exists in pool already
- If exists with `brand_scope=['*']` → REUSE (just reference cite_id, don't duplicate)
- If exists with different brand_scope → expand brand_scope[] array
- Only add NEW row if completely new citation

**Editorial discipline:**
- Phase B.2 Goal: ≥5 Tier 1-3 citations per main pillar topic (breadth)
- Phase F Goal: per-page intensive — gap-fill specific claims (depth)
- Pattern E (Brand Stance) requires: ≥1 Tier 1-2 supporting + Tier 5 brand internal data
- Refresh rotation: stale citations get flagged for replacement at editorial review (Bible Part 23.4 stage 2)

> **Important:** Citation pool grows organically across brands and phases. First brand to research a pillar (e.g., OSA) does heavy lifting (10-15 sources). Subsequent brands writing OSA reuse via brand_scope=['*'] + add their edge cases. Federation = compounding research investment over time.

### 5.9 Why "Parent" is Text (Not Notion ID) at Planning

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

### 5.10 Hierarchy Encoding — Two Methods

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

### 5.11 Per-Brand Repo Folder Structure (UPDATED v1.6 🆕)

ทุก per-brand repo (`eywa-{brand-slug}`) ต้องใช้โครงสร้างเดียวกัน เพื่อให้ทุก brand work-flow consistent + onboarding ใหม่หา file ไม่หลง.

**v1.6 changes** (reflects Stage 1/Stage 2 split + Citation Pool + DR-020 templates):
- ➕ Added `content-plan/citation-pool-seed.md` (Phase B.2 deliverable per §5.8)
- 🔄 Restructured `content-drafts/` → per-template subfolders + `_templates/` boilerplate
- ➕ Added `content-published/` archive folder (Phase G snapshot)
- ➕ Added `stage-tags.md` log for Stage 1 Gate version tags

#### 5.11.1 Standard Folder Tree

```
eywa-{brand-slug}/                       Example: eywa-vth-biodent/
│
├── README.md                           # Brand overview + folder map + quick links
├── brand-config.json                   # Federation config (brand_scope, vertical, languages)
├── .gitignore
│
├── docs/                               # 📚 Brand documentation (human-authored)
│   ├── README.md                       # Index of docs/
│   ├── brand-concept.md                # Phase A output — brand identity, voice, USP
│   ├── decision-records.md             # Brand-specific DRs (link global for shared)
│   ├── changelog.md                    # Brand version history
│   ├── stage-tags.md                   # 🆕 v1.6 — Log of Stage 1 Gate git tags
│   │                                   # (e.g., stage-1-approved-vth-biodent-2026-05-10)
│   └── signature-programs/             # Brand flagship programs (NEW v1.2)
│       ├── README.md                   # Folder index + flagship designation rules
│       └── {program-slug}.md           # Per-program full spec
│
├── content-plan/                       # 🌳 STAGE 1: PLANNING (Phases A-E outputs)
│   ├── README.md                       # Index + file purpose + Stage 1 Gate checklist
│   │
│   │   # Phase B outputs (Research & Discovery)
│   ├── research-notes.md               # B.1 — DataForSEO, competitors, journey, audit
│   ├── citation-pool-seed.md           # 🆕 v1.6 B.2 — 13-col schema (§5.8)
│   │                                   # Phase B.2 breadth-level survey
│   │                                   # Pool grows in Phase F step 3 (depth)
│   │
│   │   # Phase C outputs (Entity Genesis)
│   ├── entities.md                     # 12-col schema (§5.3) — knowledge graph entities
│   ├── clusters.md                     # 6-col schema (§5.4) — topic cluster index
│   ├── relationships.md                # 5-col schema (§5.6) — typed edges (10 types)
│   ├── egp-output-summary.md           # Entity Genesis Protocol summary (Bible 2.6)
│   │
│   │   # Phase E outputs (Sitemap Architecture)
│   ├── sitemap.md                      # 7-col schema (§5.5) — page hierarchy
│   ├── internal-linking-plan.md        # Link strategy + cluster connections
│   ├── audit-report.md                 # Sitemap health audit results
│   │
│   │   # Optional planning outputs
│   └── content-priorities.md           # 7-col schema (§5.7) — editorial calendar
│
├── content-drafts/                     # 📝 STAGE 2: DRAFTING (Phase F output) 🆕 RESTRUCTURED v1.6
│   ├── README.md                       # Workflow guide + Part 1/Part 2 + Section 2 patterns
│   │
│   ├── _templates/                     # 🆕 Boilerplate skeletons (copy from
│   │                                   # eywa-protocol-spec/examples/)
│   │   ├── T1-medical-condition.md     # Copy from examples/T1-medical-condition-SKELETON.md
│   │   ├── T2-medical-procedure.md     # (when produced)
│   │   ├── T2a-aesthetic.md
│   │   ├── T2b-dental.md
│   │   ├── T6a-guide.md
│   │   └── ...                         # One per template type brand will use
│   │
│   │   # Per-template subfolders — drafts grouped by template_id
│   ├── T1-medical-condition/           # Disease/condition pages (L4 pillars typically)
│   │   ├── obstructive-sleep-apnea.md
│   │   ├── tmj-disorder.md
│   │   └── ...
│   ├── T2-medical-procedure/           # Treatment/service detail pages (L2)
│   ├── T2a-aesthetic-procedure/        # If brand has aesthetic vertical
│   ├── T2b-dental-procedure/           # If brand is dental
│   ├── T2c-wellness-program/           # If brand has wellness programs
│   ├── T2d-physiotherapy/
│   ├── T2e-genomic/                    # If brand offers genomic testing
│   ├── T3-diagnostic/
│   ├── T4-medical-device/              # Technology pages (L3)
│   ├── T5-service-money-page/
│   ├── T6-concept/                     # Knowledge concepts (L5)
│   ├── T6a-guide/                      # Comprehensive guides
│   ├── T7-comparison/
│   ├── T8-case-study/                  # L7 patient cases (PDPA-anonymized)
│   ├── T9-author-profile/              # Doctor/team pages
│   ├── T10-branch/                     # Branch location pages (L6)
│   ├── T11-institutional/              # Home/About/Contact/Privacy
│   ├── T12-hub/                        # Topic hubs (L3 navigational)
│   ├── T13-pricing/
│   ├── T14-trending/                   # News/clinical updates
│   ├── T15-quiz/                       # Self-assessment tools
│   ├── T16-insurance/
│   ├── T17-care-instructions/
│   ├── T18-programmatic-local/         # Hyper-local [service]×[branch]
│   └── T19-promotion/                  # Time-sensitive offers
│
├── content-published/                  # 🆕 v1.6 — Archive of published content
│   ├── README.md                       # Snapshot rules — what gets archived when
│   ├── 2026-05/                        # Monthly snapshots (or per-publish-batch)
│   │   └── (copies from content-drafts/ at publish time)
│   └── ...
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

#### 5.11.2 Stage Mapping (which folder produces what when)

```yaml
stage_1_outputs_to_content_plan:
  phase_A: docs/brand-concept.md
  phase_B: content-plan/research-notes.md
  phase_B.2: content-plan/citation-pool-seed.md  # 🆕 v1.6
  phase_C: content-plan/entities.md, clusters.md, relationships.md, egp-output-summary.md
  phase_D: (validates entities/clusters — no new file, may update relationships.md)
  phase_E: content-plan/sitemap.md, internal-linking-plan.md, audit-report.md
  
  → STAGE 1 GATE: git tag stage-1-approved-{brand}-{YYYY-MM-DD}
  → log in docs/stage-tags.md

stage_2_outputs_to_content_drafts:
  phase_F: content-drafts/{template_id}/{slug}.md (per-template subfolders)
  phase_F_intensive_research: extends content-plan/citation-pool-seed.md (pool grows)
  phase_G: content-published/{YYYY-MM}/* (snapshot at publish time)

backloop_workflow:
  if_stage_2_triggers_stage_1_revisit:
    - update relevant content-plan/ file(s)
    - bump version in file frontmatter
    - new tag: stage-1-revised-{brand}-{date}-{reason}
    - log in docs/stage-tags.md
```

#### 5.11.3 Naming Conventions

```yaml
file_naming:
  draft_files: "{slug}.md" (kebab-case, matches page_slug column in seo_website_page_master)
  template_files: "T{##}{-suffix}.md" (matches template_id from Content_Templates)
  
folder_naming:
  template_folders: "T{##}-{descriptive-slug}/" (e.g., T1-medical-condition/)
  rationale: "T## prefix sorts naturally; descriptive slug aids discovery"

git_tag_naming:
  stage_1_approved: "stage-1-approved-{brand}-{YYYY-MM-DD}"
  stage_1_revised: "stage-1-revised-{brand}-{YYYY-MM-DD}-{reason-slug}"
  publish_snapshot: "publish-{YYYY-MM-DD}-{batch-id}" (optional, per Phase G batch)
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

session_2026_05_10_part_5:  # 🆕 NEW v1.6 (continued same day — Stage 1.5 + DR-021)
  duration: ~3 hours
  trigger: |
    Operator question 1: "After sitemap confirmed → push to Supabase → 
    sync Notion → fill columns → THEN start content writing — correct?"
    Operator question 2: "Internal linking — does spec already have a table?"
  parallel_workstream: "Stage 1.5 architecture + DR-021 (paired with DR-019/020 lock cycle)"
  
  problems_surfaced:
    - "Section 7 had NO explicit phase between Sitemap Approved (Phase E) and Content Writing (Phase F) — Two-Phase Sync was implied at Phase G but should run earlier"
    - "Internal linking storage in DB undefined — implicit only via cluster + entities + sitemap hierarchy, no per-edge fidelity"
    - "Operator's pre-EYWA Notion DB ('Website & SEO Page Intelligent Master') had rich page-level linking strategy fields EYWA spec was missing (Authority Weight, Anchor Strategy Mode, Cross-Brand governance, etc.)"
  
  outcomes:
    - Q1 confirmed: ใช่ workflow ที่ถูกคือ markdown → Supabase flat → Notion sync → column completion → Stage 2
    - Q2 verdict: ไม่มีตารางเฉพาะใน Schema v1.10 — ต้องเพิ่ม
    - Stage 1.5 added to Section 7 (between Stage 1 Gate and Stage 2)
    - DR-021 (Internal Linking Architecture HYBRID) drafted + applied as Proposed
    - DECISION_RECORDS v1.6 → v1.7
    - 4 sub-decisions in DR-021:
      1. 12 page-level strategy cols added to seo_website_page_master
      2. New seo_page_internal_links junction table (~22 cols, per-edge)
      3. Bidirectional consistency validation (reciprocal/anchor diversity/orphan/depth)
      4. Cross-brand link governance (justification + approved flag required)
    - Universal Pattern: Page-level strategy + Junction = HYBRID (best of both worlds)
  
  scope_clarification:
    - Stage 1.5 is BEFORE content production (not after)
    - Markdown planning files become audit snapshots after Stage 1.5
    - Content writers query DB, not markdown
    - Citation pool grows in Phase B.2 (breadth) AND Phase F step 3 (depth)
    - Internal linking planned in Stage 1.5 step 3 (junction table)
  
  governance_milestone: "Fourth Proposed-status DR (DR-013/014 + DR-019 + DR-020 + DR-021) all in 2026-06-07 review cycle"
  
  pending_actions:
    review_window:
      - DR-021 review until 2026-06-07 (paired with DR-019/020)
      - Schema v1.11 design (12 + 22 cols) for review
      - n8n flow update planning (sync seo_page_internal_links)
    
    if_locked_2026_06_07:
      - Schema v1.11 migrations 009 + 010 (Phase 1A.3)
      - ACF field group additions (~3 hours)
      - n8n flow update for new table sync (~6 hours)
      - Bible v3.15 cross-references to DR-021 (Part 4 + Part 13)
      - Content_Templates v1.4 update (Part 2 §6 Internal Link Checklist references DB)
    
    if_rejected:
      - Document workaround: continue using implicit linking (cluster + entities + sitemap hierarchy)
      - Re-evaluate when Stage 2 surfaces concrete pain points
  
  status: "Stage 1.5 documented. DR-021 Proposed. Schema v1.11 design pending lock 2026-06-07."
```

---


## 🛠️ Section 7 — Workflow Phases for New Brand

### 7.1 Overview — 2 Stages, 7 Phases (🆕 v1.6 restructured)

```
╔═══════════════════════════════════════════════════════════════════╗
║ STAGE 1 — Foundation & Architecture (Markdown planning)           ║
║   PHASE A: Brand Understanding                                    ║
║   PHASE B: Research & Discovery + Citation Pool Seeding 🆕        ║
║   PHASE C: Entity Genesis + Citation-Entity Linking 🆕            ║
║   PHASE D: Cluster & Domain Mapping                               ║
║   PHASE E: Sitemap Architecture (incl. Phase 4.5 Quality Gates)   ║
║                                                                   ║
║   ▶ STAGE 1 GATE: Sitemap Approval                               ║
╚═══════════════════════════════════════════════════════════════════╝
                              ↓
                    [operator approval]
                              ↓
╔═══════════════════════════════════════════════════════════════════╗
║ STAGE 1.5 — Supabase Migration & Linking 🆕 v1.6                 ║
║   STEP 1: Flat load to Supabase (DR-006 Phase 1)                 ║
║   STEP 2: Two-way sync Supabase ↔ Notion (DR-006 Phase 2)        ║
║   STEP 3: Column completion + internal linking (DR-021) ⭐         ║
║   STEP 4: Validation (FK, EUG, orphan, reciprocal, depth)        ║
║                                                                   ║
║   ▶ STAGE 1.5 GATE: DB Ready ← MUST PASS BEFORE STAGE 2          ║
╚═══════════════════════════════════════════════════════════════════╝
                              ↓
                  [DB validation passed]
                              ↓
╔═══════════════════════════════════════════════════════════════════╗
║ STAGE 2 — Production & Deployment (DB-driven)                     ║
║   PHASE F: Content Production (queries DB, NOT markdown)          ║
║   PHASE G: Deployment (publish from DB → WP, simpler post-v1.6)   ║
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

### 7.3 Phase B — Lean Research & Discovery 🆕 v1.8 (DR-022 Proposed)

> **🔄 v1.8 Restructure (DR-022 Proposed — review 2026-06-07):** Phase B is now a single human-blocking lean phase. DFS volume + SERP enrichment runs **asynchronously after Stage 1.5 push** (background n8n trigger). Refinement happens once in NEW Phase E.refine after enrichment lands. Operator does NOT block Phase B waiting for DFS data.

**Phase B inputs:**
- `brand-concept.md` (Phase A output)
- Operator domain knowledge
- WebSearch breadth research (competitor sitemaps, manual SERP/PAA peek, Google autocomplete)

**Phase B outputs (5 files — replaces single `research-notes.md`):**

```yaml
keyword-seed-list.md:
  source: operator + AI brand-driven dump (NO DFS)
  scope: every service + signature + concern + question topic the brand should cover
  example: SmileScape content-plan/keyword-research-dump.md (~680 KW × 16 clusters)
  policy: brand-led — captures topical territory regardless of volume

competitor-scan.md:
  source: WebSearch (browse competitor sites, SERP top 5-10 per pillar)
  scope: structural intelligence (page types, sitemap shapes, USP positioning)

citation-pool-seed.md:
  source: Bible Part 23.1 — 6-tier hierarchy
  scope: 5-15 authoritative sources per pillar (BREADTH survey)
  schema: matches seo_citations columns (tier, schema_evidence_level, doi, authors, journal, year, url, brand_scope)

patient-journey.md:
  source: operator + interviews + reviews
  scope: audience persona, funnel stage map, painpoint catalog, anxiety triggers

```

**Phase B outputs (deferred — populated AFTER Stage 1.5 push, NOT in Phase B):**

```yaml
keyword-volume-data.csv:           # Auto-populated by n8n cheap pull (24-48h SLA)
serp-intelligence-shortlist.md:    # Operator approves Tier A/B → DFS SERP scrape (manual gate)
gap-report.md:                     # Phase E.refine output (AI-generated, operator-reviewed)
```

**Two-Layer Sitemap Architecture (DR-022):**

```yaml
layer_1_brand_service:
  scope: [Section 1 Home, 2 Uniqueness, 3 Services, 4 Tech, 7 Branches, 8 Contact]
  policy: VOLUME-IMMUNE — every service/signature/founder/branch = page
  rationale: topical authority + E-E-A-T + AI citation context completeness
  cut_for_low_volume: ❌ NEVER

layer_2_knowledge_blog:
  scope: [Section 5 Concerns, Section 6 Knowledge]
  policy: VOLUME-DRIVEN additions via Phase E.refine gap discovery
  rationale: traffic harvesting + AI citation entry
  cut_for_low_viability: ⚠️ Layer 2 only (DR-016 applies)

layer_3_internal_linking:
  policy: priority_score weights authority flow; never deletes pages
```

**Citation Pool Seeding (Bible Part 23.1 — 6-tier hierarchy):**

For each main pillar topic, research authoritative sources BEFORE entity creation. This builds the universal citation pool that downstream phases (C, F) will draw from.

> **Scope:** Phase B citation = **BREADTH-level survey** (5-15 sources per pillar — covers main claims). Per-page **DEPTH-level intensive research** happens in Phase F step 3 — see §7.7. Pool grows organically across both phases.

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

## 🔄 STAGE 1.5 — Supabase Migration & Linking 🆕 v1.6

**Purpose:** ระหว่าง Stage 1 Gate (sitemap approved) และ Stage 2 (content writing) — ทุก planning data ต้อง migrate เข้า Supabase + ครบทุก auxiliary columns + internal linking planned ใน DB ก่อนเริ่มเขียน content

**ทำไมต้องมี Stage 1.5:**
- Stage 2 writers ต้อง query DB (citations, entities, sitemap, related pages, internal links) — ไม่ใช่ markdown
- Federation reuse (cross-brand citation pool, link templates) ต้องการ DB
- Two-Phase Sync (DR-006) — Phase 1 flat load + Phase 2 Notion sync ต้องเสร็จก่อน column completion
- Internal linking planning (DR-021 — Proposed) ต้องเก็บใน junction table

```yaml
stage_1_5_workflow:
  
  step_1_flat_load_to_supabase:  # = DR-006 Phase 1
    duration: "~1-2 hours per brand"
    actions:
      - Markdown files → Supabase flat (rows = rows in markdown)
      - entities.md → seo_entity_graph
      - clusters.md → seo_topic_cluster_master
      - relationships.md → seo_entity_relationships
      - sitemap.md → seo_website_page_master (sync_state='flat_loaded')
      - citation-pool-seed.md → seo_citations
    state: parent_notion_id NULL, sync_state='flat_loaded'
    eug_check: ทุก entity ผ่าน eug_preflight_check() — หา duplicates ก่อน insert
    via: n8n flow (markdown → Notion → Supabase) หรือ direct CSV import
  
  step_2_two_way_sync_supabase_notion:  # = DR-006 Phase 2 ⭐
    duration: "~30 mins per brand (after Notion DBs configured)"
    actions:
      - Notion ดึงจาก Supabase → สร้าง pages ใน Notion DBs
      - Notion-side parent assignment (drag-drop hierarchy)
      - notion_id generated ที่ Notion → sync กลับมา Supabase
      - sync_state advances to 'notion_synced'
      - parent_notion_id resolved
    via: existing n8n flows (Entity Graph 2-way ✅, Website Master Notion→SB ✅, SB→Notion pending)
  
  step_3_column_completion_in_supabase:  # ⭐ heart of Stage 1.5
    duration: "~3-5 hours per brand"
    
    auxiliary_cols_not_in_planning_markdown:
      - schema_markup_planned (jsonb — design JSON-LD per page)
      - secondary_entities_fps[] (related entities per page beyond primary)
      - author_fp + medical_reviewer_fp (assign reviewers to pages — required for YMYL)
      - target_keyword_fp (link to keyword_master row)
      - viability_assessment.predicted_volume (final post-KW data)
      - schema_org_type per page (must match seo_layer mapping)
      - content_brief refinement (DR-017 — may add details after sitemap review)
    
    internal_linking_planning:  # 🆕 DR-021 Proposed
      via_seo_page_internal_links_junction_table:
        - For each page: list outgoing links (which pages does it link TO?)
        - Per edge: anchor_text + anchor_variant_type + section_context + link_type + link_role + link_priority
        - Mark is_reciprocal where bidirectional
        - Mark is_cross_brand where cross-brand (with cross_brand_justification)
      
      via_seo_website_page_master_strategy_cols:  # 🆕 DR-021
        - Set authority_weight (0-100) per page
        - Set strategic_page=true for "must rank" pages
        - Set required_min_inbound + required_min_outbound per Tier
        - Set link_priority_default + link_role_default + anchor_strategy_mode
        - Set cross_brand_approved=true on pages allowed cross-brand outbound
    
    cross_table_validation:
      - EUG check ทุก entity ใน DB (no duplicates)
      - FK validation ทุกตาราง (page.primary_entity_fp exists, etc.)
      - Citation freshness audit (flag stale Tier 1-3 citations)
      - Reciprocal link detection trigger (auto-mark is_reciprocal=true)
      - Anchor diversity check (warn same anchor >3x for different targets)
      - Orphan detection (pages with required_min_inbound > actual)
      - Authority depth check (Tier A ≤ 3, Tier B ≤ 4)
  
  step_3a_async_kw_enrichment:  # 🆕 v1.8 (DR-022 Proposed)
    duration: "24-48h cheap pull / up to 7 days SERP scrape — async, non-blocking"
    trigger: "n8n auto-trigger on seo_x_ads_keywords_contextual_master INSERT/UPDATE"
    
    cheap_layer_auto:  # no operator gate
      endpoint: DataForSEO Keywords Volume + KD + CPC
      target_table: seo_x_ads_keywords_monthly_market_snapshot
      cost: "~$0.05-0.10 per ~680 KW (full seed list)"
      sla: "within 24-48h of seed push"
      computed_scores_n8n_local:
        - seo_ads_priority_score (0-100)
        - seo_roi_proxy
        - keyword_risk_score
        - keyword_maturity_score
        - intent_confidence_score
    
    expensive_layer_manual:  # operator approval gate
      endpoint: DataForSEO SERP API (full scrape + PAA + related + AI Overview)
      target_table: seo_x_ads_keyword_serp_competitors
      target_scope: Tier A/B shortlist only (~150-250 KW per brand)
      cost: "~$0.10-0.30 per shortlist batch"
      cost_gate: "operator reviews shortlist + approves before pull"
      sla: "within 7 days of approval"
    
    operator_action: "no manual blocking — work continues on column completion + linking"

  step_3b_phase_E_refine:  # 🆕 v1.8 (DR-022 Proposed) — NEW iterative refinement step
    duration: "~2-4 hours per brand (after enrichment lands)"
    trigger: "enrichment data complete (cheap + expensive layers populated)"
    
    inputs_AI_analyzes:
      - seo_x_ads_keywords_contextual_master (operator-authored)
      - seo_x_ads_keywords_monthly_market_snapshot (enriched volume + scores)
      - seo_x_ads_keyword_serp_competitors (PAA + related + competitors)
      - sitemap (current Layer 1 + Layer 2)
      - entities + clusters
    
    output: content-plan/gap-report.md (auto-generated):
      sections:
        - high_vol_kw_no_entity         # entity gap to fill
        - high_vol_kw_no_page           # Layer 2 page candidate
        - paa_clusters_uncovered        # potential Section 5/6 page
        - autocomplete_expansions       # KW expansion suggestions
        - serp_feature_template_mismatch # template_id review
        - tier_reweight_proposals       # priority_score-based A/B/C adjustments
    
    refinement_scope_policy:
      ADD Layer 2 page                : "✅ free (gap-driven additions)"
      SPLIT page (multi-intent PAA)   : "✅ free"
      MERGE thin pages (no live URL)  : "⚠️ allowed pre-deploy only"
      CUT page                        : "❌ NEVER for Layer 1; ⚠️ Layer 2 only if DR-016 viability fails"
      REORDER tier A/B/C              : "✅ free (uses priority_score)"
      flexibility_clause: "operator may override case-by-case with brand DR (SS-DR-NNN, VTH-DR-NNN, etc.)"
    
    process:
      1. AI generates gap-report.md
      2. Operator reviews each finding (✅/❌ per item)
      3. Sitemap delta applied (ADD-only by default, REORDER OK, MERGE conditional)
      4. Updates flow back to seo_website_page_master + Notion sync
      5. KW context (painpoint/anxiety/insight) flows to Phase F via seo_x_ads_keywords_contextual_master

  step_4_stage_1_5_gate:
    duration: "~30 mins"
    checklist:
      ☐ All planning markdown synced to Supabase (sync_state='notion_synced' all rows)
      ☐ schema_markup_planned populated for all pages (per template)
      ☐ author_fp + medical_reviewer_fp assigned (YMYL pages)
      ☐ Internal linking planned in seo_page_internal_links (≥1 outgoing per page)
      ☐ Page-level linking strategy cols populated (DR-021)
      ☐ Reciprocal critical-priority links bidirectional ✅
      ☐ Anchor diversity check passed (no exact-match overuse)
      ☐ Orphan check passed (all required_min_inbound satisfied)
      ☐ Cross-brand links: justification + approval present
      ☐ Authority depth: Tier A ≤ 3, Tier B ≤ 4
      ☐ Citation freshness audit clean (no Tier 1-3 stale)
      ☐ KW enrichment complete: monthly_market_snapshot populated for ≥95% seed KW (🆕 DR-022)
      ☐ Phase E.refine gap-report.md reviewed + sitemap delta applied (🆕 DR-022)
      ☐ Layer 1 sitemap unchanged from Stage 1 Gate (volume-immune verification — 🆕 DR-022)
    
    on_pass:
      - git tag: stage-1-5-db-ready-{brand}-{YYYY-MM-DD}
      - Update docs/stage-tags.md
      - Notify content team: "ready for Stage 2 Phase F content writing"
    
    on_fail:
      - resolve specific check before retry
      - if Stage 1 file change needed → backloop pattern (re-pass Stage 1 Gate first)
```

**Lock convention:** `git tag stage-1-5-db-ready-{brand}-{YYYY-MM-DD}` marks DB ready for Stage 2.

**ความสัมพันธ์กับ Phase G:**
- ก่อน v1.6: Two-Phase Sync รันที่ Phase G (deploy time)
- ตั้งแต่ v1.6: Two-Phase Sync รันที่ Stage 1.5 → Phase G เรียบง่ายขึ้น (content แค่ publish จาก DB ที่มีอยู่แล้ว → WP)

---

## 🚀 STAGE 2 — Production & Deployment

### 7.7 Phase F — Content Production

Per-page requirements: schema planned, citations from Phase B.2 pool **+ per-page intensive research** linked via `seo_page_citations`, author+reviewer assigned, multilingual fields, WCAG AA, internal links per plan, citable patterns used.

**🆕 v1.8 — Per-Page KW Context Consumption (DR-022 Proposed):**

Content writers pull per-page KW context from `seo_x_ads_keywords_contextual_master` to calibrate voice and structure:

```yaml
kw_context_per_page_brief:
  keyword_painpoint        : "→ hook + intro section (lead with patient's actual pain)"
  keyword_core_insight     : "→ primary message + section narrative"
  anxiety_level            : "→ tone calibration (high → reassuring; medium → educational; low → informational)"
  funnel_stage             : "→ CTA strategy + page depth (Awareness=lighter, Consideration=deeper, Decision=transactional)"
  predicted_serp_features  : "→ schema emit + section pattern (Featured Snippet → 40-60w direct answer block)"
  search_intent            : "→ template_id confirmation (Informational=T1/T6a, Commercial=T2, Local=T7/T9)"

content_brief_query_pattern:
  - Join page → primary_keyword_fp → seo_x_ads_keywords_contextual_master (context)
  - Join page → primary_keyword_fp → seo_x_ads_keywords_monthly_market_snapshot (volume + scores for length target)
  - Join page → primary_keyword_fp → seo_x_ads_keyword_serp_competitors (PAA → FAQ section, competitor URLs → competitive differentiation)
```

**Per-Page Citation Workflow 🆕 v1.6 (5-step, run BEFORE writing prose):**

```yaml
step_1_pre_write_survey:
  action: "Pull from citation-pool-seed.md (or seo_citations table) — filter by page's primary_entity + cluster_id"
  output: "Candidate list of relevant citations from existing pool"
  rationale: "Federation reuse — don't re-research what other brands already found"

step_2_gap_analysis:
  action: |
    For each major claim in page outline:
      - Does pool already have a backing citation?
      - If yes → mark as covered
      - If no → flag as 'gap' (needs intensive research in step 3)
    
    Required claims to back per template:
      - T1/T2: 5-10 claims (statistics, mechanisms, outcomes)
      - T3/T4: 3-5 claims (accuracy, indications)
      - T6a Guide: 8-15 claims (comprehensive)
      - T7 Comparison: 5-8 claims (per option)
      - T8 Case Study: 2-4 claims (clinical context)
  output: "List of gaps requiring fresh citation research"

step_3_intensive_per_page_research: ⭐ # explicit allowance for additional research
  action: |
    For EACH gap from step 2:
      - Research 1-3 candidate citations (PubMed, Cochrane, AASM, etc.)
      - Apply 6-tier classification (Bible Part 23.1):
          1: Clinical guidelines / gov health bodies
          2: Peer-reviewed journals / Cochrane
          3: Authoritative medical org publications
          4: Expert-authored books/textbooks
          5: Brand internal data — brand_scope=['{brand}']
          6: Reputable secondary sources
      - Verify freshness (within tier-specific threshold)
      - Capture metadata: doi, pmid, pmc_id, isbn, publication_year, url
      - EUG-style dedup check against existing pool (same DOI/PMID = reuse, not duplicate)
      - Add new citations to seo_citations pool — brand_scope based on universality
  
  intensity_principle: |
    Phase B.2 = BREADTH-level survey (what could OSA pillar cite, generally?)
    Phase F step 3 = DEPTH-level research (what does THIS specific OSA page need?)
    
    Per-page research is more granular and may surface citations Phase B.2 missed.
    Pool grows organically — first brand to write topic does heaviest lifting,
    subsequent brands reuse + add edge-case citations.
  
  output: "New citations added to pool + linked to current page's claim list"

step_4_write_content:
  action: |
    With full citation set in hand:
      - Write Part 1 prose (per template structure — DR-020)
      - Apply Pattern A-E citables formulas (Bible Part 6 + Content_Templates §2.8)
      - Track each citable sentence in Part 2 Citation Map table
      - Pattern E Brand Stance — backed by Tier 5 brand internal data + ≥1 Tier 1-2 supporting
  output: "Draft markdown file ready for editorial review"

step_5_persist_on_publish:
  action: |
    On final approval:
      - Each citation used → row in seo_page_citations junction (page_id × citation_id × Pattern + section_context)
      - Pool keeps growing — federation benefits scale up over portfolio
  output: "seo_page_citations populated; citation usage trackable across portfolio"
```

**Why allow per-page intensive research:**
- Phase B.2 covers 5-15 citations per pillar (broad survey)
- Real pages may need 8-20 citations for depth (specific claims need specific sources)
- Without explicit step 3, writers either skip citations or stop to ask operator
- With step 3 codified: writers know research IS allowed + expected during writing
- Pool grows: brand 1 does heavy research → brand 2-13 reuse + add their edge cases

**Template-driven workflow (DR-020):**
- Each page selects template_id (T1-T19) — see `Content_Templates_EYWA_v1_0.md` + `examples/`
- Part 1 = WYSIWYG content (review-ready)
- Part 2 = 9 multi-toggle technical + editorial spec
- Citation Map table in Part 2 tracks all citables with section + Pattern + citation_id

**5-stage editorial workflow:** Medical → SEO → Brand Voice → Legal/PDPA → Final Sign-off (Bible Part 23.4)
- Medical review checks citation tier ≥3 for primary evidence
- SEO review checks Pattern A-E coverage minimums per template
- Citation freshness re-checked at this stage (catches expired sources)

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

> **Operating principle:** Brands work in parallel. Batching DR locks before spec updates causes massive backfill cost across all in-flight brands. Therefore: **update spec immediately when DR enters Proposed, lock after soak period.** See §9.1–9.3 for the full workflow.

### 9.1 DR Lifecycle (Brand-Specific vs System-Wide)

When a decision surfaces during brand work, route it via **decision tree**:

```
Decision needed
      │
      ▼
Does this affect ONLY this brand's content/structure/voice?
      │
      ├── YES ──► Path 1: Brand-Specific DR
      │           - Log in eywa-{brand}/docs/decision-records.md (SS-DR-NNN, VTH-DR-NNN, etc.)
      │           - Adapt brand work IMMEDIATELY
      │           - Status: Locked (no soak needed — brand owns the call)
      │           - DO NOT touch eywa-protocol-spec
      │
      └── NO ───► Path 2: System-Wide DR
                  - Affects multiple brands, schema, edge vocab, governance, or templates
                  - Draft DR-NNN in eywa-protocol-spec/DECISION_RECORDS.md (Status: Proposed)
                  - Apply Immediate Update Protocol (§9.2)
                  - Soak 2 weeks → Schema Review Board → Lock or Reject
```

**Path 1 examples (brand-specific, no spec change):**

- SS-DR-001: Blue Diamond as hero implant brand (SmileScape pricing strategy)
- SS-DR-004: Founders treatment under Clinical Team (SmileScape narrative choice)
- VTH-DR-001 (hypothetical): "Use sleep-medicine angle for OSA pillar" (brand voice)

**Path 2 examples (system-wide, spec change required):**

- DR-019: FAQ/HowTo schema deprecation handling (affects all 13 brands' template emission)
- DR-020: Content_Templates v1.3 mandate (affects all brand content)
- DR-021: Internal linking architecture HYBRID (affects schema + all brand sitemaps)

**Why brand-specific stays brand-specific:** SmileScape's hero brand choice doesn't constrain TC Smile or Deezy. Forcing it into the universal spec creates noise and false precedent. Universal DRs are reserved for things every brand must consider.

### 9.2 Immediate Update Protocol (when DR enters Proposed)

**Trigger:** New system-wide DR drafted with Status: Proposed.

**Steps (within same session if possible):**

1. **Author DR** in `eywa-protocol-spec/DECISION_RECORDS.md` with full ADR format (Status: **Proposed**)
2. **Identify affected spec files** — typically subset of:
   - `BIBLE_v3_X.md` (concepts, principles)
   - `SCHEMA_v1_X.md` (column adds/changes)
   - `Content_Templates_EYWA_v1_X.md` (template blocks)
   - `EYWA_HANDOVER.md` (Pre-Flight checklist, workflow steps)
3. **Update each affected spec file IMMEDIATELY** with:
   - Bump minor version (Bible v3.14 → v3.15, Schema v1.10 → v1.11, etc.)
   - Add Proposed marker: `🆕 DR-NNN Proposed — soft guidance until lock {YYYY-MM-DD}`
   - Cross-link to DR-NNN in DECISION_RECORDS.md
4. **Update changelog** in each spec file with one-line entry per DR
5. **Update Pre-Flight Checklist** (§10) — add awareness section for new DR
6. **Commit + push** with message: `feat(spec): DR-NNN proposed — {one-line description}`
7. **Notify brands in flight** (project memory `project_eywa_spec_governance.md` — log review date)

**Locked vs Proposed signaling discipline:**

- Every Proposed item in spec MUST carry: `🆕 DR-NNN Proposed — review {YYYY-MM-DD}`
- Brands implementing Stage 1 follow **Locked DRs only** as binding; Proposed = preview / informational
- When Locked, remove Proposed marker, bump major or minor per impact, update changelog

**Why immediate (not batched):**

| Scenario | Batched (old) | Immediate (current) |
|----------|--------------|---------------------|
| 5 brands in Stage 1, 3 DRs queue up over 6 weeks | All 5 brands rebuild Stage 1 outputs after batch lock | New brands started after each DR Proposed adopt latest; only brands started before each DR backfill on next stage gate |
| Bible version churn | Low (1 bump per quarter) | Higher (3-5 bumps per quarter) — acceptable with semver discipline |
| Risk of half-baked DR entering spec | Low | Mitigated by Proposed status + soak window + Lock review |
| Operator coordination cost | High (many brands need backfill on same week) | Low (each brand picks up at next gate) |

### 9.3 Brand Snapshot Discipline

Each brand pins its current **EYWA Spec Snapshot** at Stage gates and adopts new DRs on each subsequent gate.

**brand-config.json metadata block:**

```json
{
  "eywa_spec_snapshot": {
    "bible_version": "3.15",
    "schema_version": "1.11",
    "templates_version": "1.3",
    "handover_version": "1.9",
    "drs_locked_at_snapshot": ["DR-001", "DR-002", "...", "DR-018", "DR-024", "DR-025"],
    "drs_proposed_at_snapshot": ["DR-013", "DR-014", "DR-019", "DR-020", "DR-021", "DR-022"],
    "snapshot_taken_at": "2026-05-12",
    "snapshot_taken_at_stage": "Stage 1 Phase E"
  }
}
```

**Snapshot rules:**

1. **Set snapshot** when brand enters Stage 1 (Phase A start) — pin versions
2. **Re-snapshot** at each Stage gate (Stage 1 → 1.5, Stage 1.5 → 2) — adopt newly Locked DRs
3. **Mid-stage DR locks** — log in brand changelog, decide per DR whether to retrofit now or defer to next gate (most defer)
4. **Proposed DRs at snapshot** — brand may opt-in early ("we want DR-021 internal linking pattern even before lock") — log decision in brand changelog

**Why this matters:**

- **Traceability:** Every published page is traceable to which spec version produced it
- **Auditability:** When a Locked DR retroactively breaks something, we know which brands+pages need patching
- **Forward compatibility:** Brand authors don't chase a moving spec mid-stage — only at gates

### 9.4 When Spec Changes (operational sync)

1. Read changelog of new version
2. Identify affected current work via `drs_proposed_at_snapshot` vs current Locked DRs
3. Replace project knowledge files (delete old, upload new)
4. Update brand-config.json metadata (`eywa_spec_snapshot.*`)
5. Re-validate pending entities/pages against new spec
6. Document forced refactors in brand `decision-records.md` (not universal DR)

### 9.5 When Brand Config Changes

Triggers: new service line, specialty add/remove, CPT flag changes, new language.

Steps: update brand-config.json → push GitHub → if structural, re-run affected EGP steps → update sitemap → re-validate cluster health.

### 9.6 DR Format Reminder

Every DR (universal or brand-specific) carries: **Status, Context, Options Considered, Decision, Rationale, Consequences, References**. Append-only. Universal → `eywa-protocol-spec/DECISION_RECORDS.md`. Brand-specific → `eywa-{brand}/docs/decision-records.md` with brand prefix (SS-DR, VTH-DR, etc.).

---

## 📋 Section 10 — Pre-Flight Checklist for Every Session

```yaml
session_kickoff_checklist:
  
  context_verification:
    ☐ Read EYWA_HANDOVER.md (this file — v1.9)
    ☐ Read latest Bible version (v3.15 as of 2026-05-12)
    ☐ Read latest Schema version (v1.11 as of 2026-05-12 — 37 tables; 9 ext + 4 Local SEO restored per DR-024/025)
    ☐ Read brand-config.json (incl. eywa_spec_snapshot block — §9.3)
    ☐ Read DECISION_RECORDS.md (v1.9, DR-001..DR-025 — DR-013/014/019/020/021/022 Proposed; DR-015..DR-018, DR-024, DR-025 Locked)
    ☐ Read Content_Templates_EYWA_v1_0.md (v1.3 internal DRAFT, ~2,420 lines — pending DR-020 lock)
    ☐ Read brand-concept.md (if exists)
    ☐ Read brand decision-records.md (eywa-{brand}/docs/ — SS-DR/VTH-DR/etc., per §9.1 Path 1)
  
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
  
  internal_linking_awareness:  # 🆕 v1.6 (added 2026-05-10 — DR-021 Proposed, soft guidance until lock 2026-06-07)
    ☐ Page-level strategy assigned? (authority_weight, node_tier_strategy, strategic_page, required_min_inbound/outbound, link_priority_default, anchor_strategy_mode)
    ☐ Internal links planned in seo_page_internal_links junction (NOT in jsonb)?
    ☐ Each edge has explicit anchor_text + section_context (NOT inherited from page-level)?
    ☐ anchor_variant_type set per edge? (exact/partial/branded/generic/topical)
    ☐ link_type per edge? (contextual/navigational/footer/breadcrumb/related/cta)
    ☐ Reciprocal critical-priority links → both sides exist + is_reciprocal=true?
    ☐ Anchor diversity: no from_page uses same anchor >3 times for different targets?
    ☐ Orphan check: page with required_min_inbound > 0 has actual inbound count satisfied?
    ☐ Cross-brand links: cross_brand_approved=true on from_page + cross_brand_justification text present?
    ☐ Authority depth: Tier A pages crawl_depth ≤ 3, Tier B ≤ 4?
  
  lean_phase_b_two_layer_awareness:  # 🆕 v1.8 (added 2026-05-11 — DR-022 Proposed, soft guidance until lock 2026-06-07)
    ☐ Phase B output split into 5 files? (keyword-seed-list, competitor-scan, citation-pool-seed, patient-journey + post-enrichment: keyword-volume-data.csv, serp-intelligence-shortlist, gap-report)
    ☐ Phase B does NOT block on DFS volume? (volume = async background after Stage 1.5 push)
    ☐ Two-Layer Sitemap classification applied? (Layer 1 = S1/S2/S3/S4/S7/S8 brand-immune / Layer 2 = S5/S6 vol-driven / Layer 3 = internal linking)
    ☐ Layer 1 pages NEVER cut for low volume? (verified at Stage 1.5 Gate)
    ☐ Stage 1.5 step_3a — n8n cheap pull triggered on contextual_master INSERT? (24-48h SLA)
    ☐ Stage 1.5 step_3a — Tier A/B SERP scrape requires operator approval? (cost gate)
    ☐ Stage 1.5 step_3b — Phase E.refine gap-report.md generated + reviewed?
    ☐ Refinement scope respected? (ADD Layer 2 ✅ / SPLIT ✅ / MERGE ⚠️ pre-deploy / CUT ❌ Layer 1)
    ☐ Phase F Content brief consumes KW context? (painpoint → hook / anxiety → tone / insight → message / funnel → CTA)
    ☐ research-notes.md DEPRECATED in favor of 5 split files (no new brands should create research-notes.md)
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

### v1.9 (2026-05-12) — Schema Catch-Up: DR-024 + DR-025 Locked (37 Tables) 🔒🧬🏥

Companion bump to **DR-024 + DR-025 (Locked 2026-05-12)**, **Schema v1.11**, and **Bible v3.15**. Schema_Overview restored to parity with Bible Appendix B by adding 9 tables that were silently dropped between Schema v1.0→v1.10 (no DR, no changelog explanation — operator confirmed forgotten, not deliberate). No new operational workflow — Handover bump primarily updates spec stack references and Pre-Flight Checklist DR awareness.

**Headline Changes:**

- 🔄 **Header reference block:** Companion to Bible v3.15 + Schema v1.11 + DECISION_RECORDS v1.9
- 🔄 **§9.3 Brand Snapshot Discipline:** Updated `eywa_spec_snapshot` example to show DR-024/DR-025 in `drs_locked_at_snapshot` array + Bible 3.15 / Schema 1.11
- 🔄 **§10 Pre-Flight Checklist context_verification:**
  - Bible reference: v3.15
  - Schema reference: v1.11 (37 tables: 9 ext + 4 Local SEO restored per DR-024/025)
  - DECISION_RECORDS: v1.9 with DR-024 + DR-025 marked Locked

- 🆕 **Stage 1.5 step 3 (Column Completion) — expanded scope:**
  - Clinic brands now populate 3 Local SEO tables (`seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`) in addition to `seo_branches` (enhanced ~40 cols)
  - Medical brands now bind T1 pages to `seo_entity_condition` (primary T1 schema binding), plus cross-refs to `seo_entity_anatomy`, `seo_entity_drug`, `seo_entity_procedure`
  - Skincare brands (the brand) populate `seo_entity_product` for product entities

- 🎯 **Why this matters:**
  - T1 medical-condition template (Bible §4.1.1) gains its schema binding — was implementable-on-paper but not in DB
  - Clinic vertical Phase 5 (Local SEO) unblocked — Bible Part 17.6 n8n GROUP E flows (E1/E2/E3/E4) become implementable
  - All in-flight brands picking up next Stage gate now have full schema available
  - Bible-Schema sync restored after silent drift

- 🚦 **Active brand impact:**
  - **VTH BioDent** (Stage 1.5 blocked on DR-021 lock) — at next Stage gate refresh adopt: DR-024 (condition extension binding for OSA T1 page) + DR-025 (Local SEO tables for branch landing pages)
  - **SmileScape** (Stage 1 Phase E in progress) — adopt at Stage 1 → 1.5 transition (no current work blocked)
  - **Deezy Dental** (Stage 1 complete) — at Stage 1.5 entry adopt full new schema
  - **TC Smile** (Stage 1 sitemap draft) — adopt at next session refresh
  - **Dr. Trin Wellness** (pre-Stage 1) — uses v1.9 + v3.15 + v1.11 from inception
  - **11 empty brand repos** — use new spec from inception

- 📦 **No new templates or bootstrap files** — purely spec stack refresh

- 🔗 **Companion DRs:**
  - DR-024 (Restore 9 Entity Extension Tables — Locked 2026-05-12)
  - DR-025 (Restore Local SEO Tables + Consolidate `seo_locations` → `seo_branches` — Locked 2026-05-12)

- ✅ **Backward compatible:**
  - Existing brand snapshots (`bible_version: 3.14`, `schema_version: 1.10`) remain valid at their snapshot point
  - Brands refresh at next Stage gate (no mid-stage forced refactor)
  - 11 empty repos: use new spec directly from inception

### v1.8 (2026-05-11) — DR-022 Lean Phase B + Two-Layer Sitemap + Iterative Refinement + Bootstrap Kit 🌱

Field-tested workflow change from VTH BioDent + SmileScape sessions. Replaces lump Phase B (volume-gated) with lean planning loop + async background DFS enrichment + single iterative refinement (Phase E.refine). Companion: NEW `templates/` folder enables ~15-min brand bootstrap from baseline.

**Headline Changes:**

- 🔄 **§7.3 Phase B restructured (lean):**
  - Single human-blocking phase (NOT 5 sub-phases)
  - DFS volume + SERP enrichment moved to **async background** (post-Stage 1.5)
  - 5 output files (replaces single `research-notes.md`):
    `keyword-seed-list.md` / `competitor-scan.md` / `citation-pool-seed.md` / `patient-journey.md` (Phase B)
    + `keyword-volume-data.csv` / `serp-intelligence-shortlist.md` / `gap-report.md` (post-enrichment)
  - Two-Layer Sitemap pattern documented (Layer 1 brand-immune / Layer 2 vol-driven / Layer 3 internal linking)

- 🆕 **Stage 1.5 NEW steps:**
  - **step_3a — Async KW Enrichment:** n8n auto-trigger on `seo_x_ads_keywords_contextual_master` INSERT → cheap pull (24-48h SLA, no gate); Tier A/B SERP scrape (manual approval gate, ~$0.10-0.30/batch)
  - **step_3b — Phase E.refine:** AI-generated `gap-report.md` → operator review → sitemap delta (ADD-only default, REORDER OK, MERGE conditional, CUT NEVER for Layer 1)

- 🆕 **§7.7 Phase F — KW Context Consumption:**
  - Content writers query `contextual_master` per page for: painpoint → hook / anxiety_level → tone / core_insight → message / funnel_stage → CTA / predicted_serp_features → schema emit / search_intent → template_id

- 🆕 **§10 Pre-Flight — `lean_phase_b_two_layer_awareness` block** (10 checks)

- 🆕 **`templates/` folder (NEW):**
  - `NEW_BRAND_BOOTSTRAP.md` — ~15-min step-by-step bootstrap checklist with Flexibility Clause
  - `brand-config.template.json` — federation config baseline (incl. `eywa_spec_snapshot` per §9.3)
  - `README.template.md` — brand repo README template
  - `folder-skeleton/` — full directory tree with `.gitkeep` markers + 7 starter docs:
    - `docs/brand-concept.template.md` (Phase A — 14 sections)
    - `docs/decision-records.template.md` (brand DR log scaffold)
    - `docs/changelog.template.md` (audit trail scaffold)
    - `content-plan/keyword-seed-list.template.md` (Phase B — DR-022)
    - `content-plan/competitor-scan.template.md` (Phase B — DR-022)
    - `content-plan/citation-pool-seed.template.md` (Phase B.2 — Bible §23.1)
    - `content-plan/patient-journey.template.md` (Phase B — DR-022 + Phase F context)
  - §1.0 added to Handover pointing to bootstrap kit

- 🎯 **Why this matters:**
  - Phase 1 timeline shortened (no DFS gate blocking entity/sitemap/citation)
  - 30-60% cheaper DFS spend per brand via layered enrichment (cheap full-list + expensive shortlist)
  - Brand topical authority preserved (Layer 1 service pages volume-immune)
  - Modern E-E-A-T + AI search era alignment (whole-site context > volume-only selection)
  - Maps to existing 4-table KW architecture + n8n flows (no schema migrations)

- 📚 **Companion DR:** DR-022 (Proposed) in DECISION_RECORDS v1.8

- ✅ **Backward compatible:**
  - No schema changes
  - VTH BioDent + SmileScape adopt at next stage gate (logged in respective brand changelog)
  - 11 empty brand repos use DR-022 from inception

### v1.7 (2026-05-10) — DR Workflow Formalization 🔁

Codifies parallel-brand DR workflow after operator pushback on "batch before Bible bump" approach. Brands work in parallel; batching causes massive backfill cost, so spec is now updated **immediately** when DR enters Proposed status.

**Headline Changes:**

- 🔄 **Section 9 — Update & Sync Protocols** restructured (3 subsections → 6):
  - **9.1 DR Lifecycle** — Decision tree: Brand-Specific (Path 1) vs System-Wide (Path 2)
  - **9.2 Immediate Update Protocol** — Step-by-step for spec updates when DR enters Proposed
  - **9.3 Brand Snapshot Discipline** — `eywa_spec_snapshot` block in brand-config.json + Stage-gate adoption rules
  - **9.4 When Spec Changes** (was 9.1) — operational sync
  - **9.5 When Brand Config Changes** (was 9.2)
  - **9.6 DR Format** (was 9.3)

- 🎯 **Why this matters:**
  - 5 brands working in parallel × 3 DRs queued over 6 weeks = batched lock forces all 5 to rebuild Stage 1 outputs
  - Immediate update = each brand picks up new DRs at next stage gate; only mid-stage DRs require optional retrofit
  - Bible version churn (3-5 bumps/quarter vs 1) is acceptable with semver discipline + DR cross-links

- ✅ **Backward compatible:**
  - All existing Locked DRs retain status
  - DR-013/014/019/020/021 already in Proposed status — no change to their state
  - brand-config.json `eywa_spec_snapshot` block is additive (existing brands can backfill at next gate)

### v1.6 (2026-05-10) — Stage 1.5 + Citation Pool + Sitemap Quality Gates + Content Templates 🏗️🌱

Companion update to Bible v3.14 + Schema v1.10 + DECISION_RECORDS v1.6 + Content_Templates v1.3 (DRAFT).

**Headline Changes:**

- 🆕 **Section 5.8 — Citation Pool Planning File** added (13-column schema for Phase B.2 breadth seeding)
- 🆕 **Section 5.11 — Per-Brand Repo Folder Structure** restructured (content-plan/, content-drafts/, theme/, deployment/, multilingual/, reports/)
- 🆕 **Stage 1.5 Migration** added between Stage 1 Gate and Stage 2 (markdown → Supabase)
- 🆕 **Sitemap Quality Gates** (Phase E.4.5) — Market Reconciliation, Page Viability Assessment, Content Brief
- 🆕 **Section 10 Pre-Flight** — added schema_emission_awareness, content_template_awareness, part_1_part_2_separation, section_2_pattern_awareness, internal_linking_awareness blocks
- 🆕 **DR-015..DR-021** referenced (DR-015..018 Locked, DR-019..021 Proposed)
- 🆕 **examples/** folder (T1 SKELETON, T1 OSA WORKED EXAMPLE, SECTION-2-PATTERNS-REFERENCE)

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
