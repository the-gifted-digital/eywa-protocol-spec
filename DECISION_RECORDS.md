# 📋 EYWA Protocol — Decision Records

> **Append-only architectural decision log.** Each record explains WHY a decision was made — not just WHAT.

**Document Version:** 1.15  
**Last Updated:** 2026-05-18  
**Format:** Reverse chronological (newest first)

---

## Format Template

```markdown
## [DR-NNN] — Title (YYYY-MM-DD)

**Status:** Proposed | Accepted | Locked | Superseded by DR-XXX  
**Bible Reference:** Part X.Y (if applicable)  
**Schema Reference:** v1.X (if applicable)

**Context:** What problem are we solving?

**Decision:** What did we choose?

**Rationale:** Why this option vs alternatives?

**Consequences:** Trade-offs, follow-ups, known limitations.

**References:** Related Bible sections, related DRs, external sources.
```

---

## Decisions Log

### [DR-029] — Universal Brand Design System (DTCG Tokens + Design Specifications Layer) (2026-05-18) 🔒🎨

**Status:** **Locked 2026-05-18** (operator-approved — universal scope, applies to all brand repos including WP and Astro stacks)
**Bible Reference:** Part 31 NEW — Universal Brand Design System
**Schema Reference:** No DDL change — file-system + JSON specification
**Companion to:** DR-002 (WP+Elementor stack default — consumes from this folder), DR-EYWA-MKT-005 (Astro stack profile — also consumes from this folder)
**Scope:** **UNIVERSAL** — applies to all 13 brand repos + eywa-marketing + future brands

**Context:**

Pre-DR-029, brand design assets lived in `theme/brand-assets/` with no formalized design tokens, no W3C-standard format, no stack-agnostic separation between specification and implementation. Each brand operator/designer reinvented:

1. **Color palette format** — sometimes CSS variables, sometimes Elementor global colors JSON, sometimes Figma styles export, sometimes nothing
2. **Typography scale** — operator-determined per brand, no shared modular scale convention
3. **Spacing system** — ad hoc per page, no token discipline
4. **Cross-stack portability** — if a brand migrated WP → Astro, design system was rebuilt from scratch
5. **Designer-readable format** — operators tried to communicate design decisions through long Notion docs; designers expected DTCG-formatted JSON they recognize

Operator increasingly uses coding-augmented workflows even for WP+Elementor stack (per recent practice). Design tokens become essential to keep design discipline + accelerate handoffs to AI co-authors + reduce per-brand reinvention.

**Decision:**

Establish **Universal Brand Design System** as a per-brand folder structure consisting of three layers — design specifications (stack-agnostic), raw brand assets (binary sources), and stack-specific implementation. The design specifications layer adopts W3C DTCG (Design Tokens Community Group) JSON format as the cross-stack standard.

#### 1. Folder structure (mandatory per-brand)

```
brands/eywa-{brand}/
├── design/                       🎨 Stack-agnostic design layer
│   ├── README.md                 ← workflow guide
│   ├── tokens/                   📐 DTCG-compliant JSON (source of truth)
│   │   ├── core.tokens.json      (primitives — palette, type scale, spacing)
│   │   ├── semantic.tokens.json  (role-based — primary/surface/text)
│   │   ├── component.tokens.json (component-level — button-bg, card-shadow)
│   │   └── brand.tokens.json     (brand-unique — pillar colors, signature accents)
│   ├── brand-foundation/         📋 Visual identity specs (Markdown)
│   │   ├── color-system.md
│   │   ├── typography.md
│   │   ├── spacing.md
│   │   ├── iconography.md
│   │   ├── imagery.md
│   │   └── motion.md
│   ├── component-specs/          📐 Per-component design spec
│   ├── page-templates/           🗺  Page-level layout specs
│   ├── wireframes/               🗺  Hand-drawn / lo-fi sketches
│   └── references/               💡 Mood boards, competitor screens
├── brand-assets/                 🖼  Raw binary sources
│   ├── logos/
│   ├── photography/
│   ├── illustrations/
│   └── icons/
└── theme/                        🚀 Stack-specific implementation
    ├── custom-css/               (WP — generated from tokens where possible)
    ├── elementor-templates-overrides/  (WP)
    └── (or src/ if Astro stack — see DR-EYWA-MKT-005)
```

**Renames from pre-DR-029 structure:**
- `theme/brand-assets/` → `brand-assets/` (root-level, expanded to logos/photography/illustrations/icons subfolders)
- `theme/` keeps remaining stack-specific implementation only (custom-css, elementor-templates-overrides)
- `design/` is NEW (did not exist universally; eywa-marketing had a partial version)

#### 2. DTCG (W3C Design Tokens Community Group) format adoption

All token files in `design/tokens/` use DTCG JSON format:

```json
{
  "color": {
    "brand": {
      "primary": {
        "$value": "#1E40AF",
        "$type": "color",
        "$description": "Primary brand color"
      }
    }
  }
}
```

Token files reference each other via `{path.to.token}` syntax. semantic.tokens.json references core.tokens.json primitives; component.tokens.json references both.

**Why DTCG (not custom format):**
- Industry-standard (W3C committee + design tool industry consensus)
- Figma + Tokens Studio plugin enables 2-way sync between Figma and `design/tokens/`
- Style Dictionary tool transforms DTCG → any output format (CSS, SCSS, JS, Swift, Android)
- Any designer hired in the future recognizes format on first glance
- Tool interoperability — no lock-in

#### 3. Stack-specific consumption pipelines

**WP+Elementor (per DR-002 default stack):**

```yaml
pipeline:
  - Designer edits design/tokens/*.tokens.json
  - Run sync script (operator workload — Phase 1F): transforms tokens → Elementor global colors/fonts JSON
  - Import JSON into Elementor (Site Settings → Import Site Kit)
  - All Elementor templates using global colors/fonts update automatically
  - theme/custom-css/ holds tokens-derived CSS variables for cases Elementor globals don't cover
```

**Astro (per DR-EYWA-MKT-005 — eywa-marketing + future Astro brands):**

```yaml
pipeline:
  - Designer edits design/tokens/*.tokens.json
  - tailwind.config.mjs imports tokens via Style Dictionary or direct import
  - npm run build → CSS regenerates
  - Astro components in src/components/ use Tailwind classes generated from tokens
```

**Figma 2-way sync (when designer uses Figma):**

```yaml
pipeline:
  - Tokens Studio plugin in Figma reads design/tokens/*.tokens.json (via GitHub sync)
  - Designer changes values in Figma using Tokens Studio
  - Tokens Studio commits back to design/tokens/ via GitHub API
  - Stack-specific pipelines (above) pick up new values on next build
```

#### 4. Bootstrap Kit additions

`templates/folder-skeleton/` updated with:
- `design/README.md` — workflow guide + DTCG primer
- `design/tokens/{core,semantic,component,brand}.tokens.json` — 4 DTCG skeleton files with TBD placeholders
- `design/brand-foundation/{color-system,typography,spacing,iconography,imagery,motion}.md` — 6 markdown templates
- `design/{component-specs,page-templates,wireframes,references}/` — placeholders with .gitkeep
- `brand-assets/{logos,photography,illustrations,icons}/` — replaces old `theme/brand-assets/`
- `brand-assets/README.md` — folder map + cross-reference to imagery.md

#### 5. Retrofit policy for existing brands

Existing brands (13 brand repos + eywa-marketing) follow this rule:

- **At next Stage gate** — operator creates `design/` and `brand-assets/` folders per Bootstrap Kit template
- **Fill incrementally** — `design/tokens/core.tokens.json` mandatory at minimum; other layers as needed
- **Move existing assets** from `theme/brand-assets/` → `brand-assets/` (preserve git history via `git mv`)
- **No retroactive deadline** — brands at Pre-Stage 1 can backfill at their leisure; brands in Phase E+ should backfill before Phase F content production starts

#### 6. eywa-marketing precedent

eywa-marketing repo already has a partial version of this structure (DR-EYWA-MKT-005 era). DR-029 generalizes that pattern + standardizes DTCG format + extends to all brand repos.

### Naming choice — `theme/` preserved

Per operator preference (2026-05-18) — `theme/` naming retained for stack-specific implementation folder. Reasons:

- WordPress developer community recognizes "theme" instantly
- Avoids invented naming ("implementation/") that adds cognitive load for operator's existing team
- Brand repos may eventually have multi-stack implementations (e.g., WP + Astro coexisting during migration); `theme/wp-elementor/` and `theme/astro/` subfolder pattern works under one `theme/` umbrella

**Rationale:**

1. **Stack-agnostic by design** — Brand visual identity does not change when implementation stack changes. One brand running WP today and migrating to Astro tomorrow should NOT redesign its color palette. Separating spec layer from implementation layer makes this future-proof.
2. **W3C DTCG = no lock-in** — Industry standard format ensures tools interoperate. Operator never has to learn a custom EYWA-specific design token format; designers recognize DTCG instantly.
3. **Designer-friendly entry** — When a new designer joins an EYWA brand engagement, they open `design/` folder and recognize the layout in 30 seconds. Color system, typography, spacing — universal mental model.
4. **Coding-augmented workflow accelerator** — Operator + Claude Code workflow consumes design tokens to generate consistent components. Without tokens, every component is bespoke; with tokens, components are derivative + consistent.
5. **WP brand benefit (not just Astro)** — Common misconception: design tokens are only for code-first stacks. False — Elementor accepts global colors/fonts JSON, which is generated from DTCG tokens via sync script. WP brands gain consistency at scale (especially multi-branch sites with shared identity).
6. **Cross-brand pattern sharing** — When `eywa-portfolio` design language emerges (e.g., shared accent style across Vertex/VT family), tokens make sharing trivial. Per-pixel CSS makes sharing impossible.
7. **EYWA marketing self-applies** — `eywa-marketing` already partially uses this pattern. DR-029 codifies + extends to all brands. EYWA dogfoods its own protocol.

**Consequences:**

- ✅ Brand visual consistency improves dramatically as tokens propagate via build pipelines
- ✅ Designer onboarding time drops (universal recognized format vs custom brand format)
- ✅ AI co-author (Claude Code) consumes tokens reliably — fewer ad-hoc style choices in generated components
- ✅ Multi-stack migration becomes feasible (Astro POC → broader adoption) without losing design system
- ✅ Figma 2-way sync option enables designer-driven workflow when applicable
- ⚠️ Existing 13 brand repos need retrofit at next Stage gate (low effort — folder creation + skeleton + incremental fill)
- ⚠️ Operator workload: sync script for WP+Elementor stack (~4-6 hours one-time, then automation)
- ⚠️ Each brand DNA Graph workshop (Phase A.1 per Bible Part 30 BGP) now feeds directly into `design/brand-foundation/color-system.md` + `typography.md` decisions — workshop output more structured
- ⚠️ Existing `theme/brand-assets/` content must move to root `brand-assets/` — git mv preserves history, but commit + push required per brand
- ⚠️ Sample tokens.json files have TBD placeholders — brands must fill with actual values; DTCG validators (e.g., w3c/design-tokens) can verify format compliance

**Open Questions (operator decisions over time):**

- Sync script implementation language — Node.js (Style Dictionary) vs operator-preferred tooling? (Recommend: Style Dictionary — widely supported, DTCG-native)
- Figma sync — adopt Tokens Studio plugin universally or per-brand decision? (Recommend: per-brand — depends on whether designer is hired + uses Figma)
- Multi-stack `theme/wp-elementor/` vs `theme/astro/` subfolder convention — formalize now or defer until first dual-stack brand emerges? (Recommend: defer — YAGNI)
- Cross-brand shared token layer (e.g., eywa-portfolio common colors) — future DR if pattern emerges? (Recommend: defer until 2+ brands share visual identity)

**References:**

- Bible Part 31 NEW — Universal Brand Design System (this DR's authoritative spec)
- Bible Part 30 — Brand Genesis Protocol (BGP) — A.1 DNA Graph informs design tokens via brand-foundation
- Bible Part 9 — Template Anatomy (consumes tokens via theme implementation)
- Bible Part 25 — WordPress Universal Kit (WP-specific consumption pipeline)
- DR-002 — WP+Elementor stack default (consumes from this folder)
- DR-EYWA-MKT-005 — Astro stack profile (consumes from this folder)
- DR-028 — BGP Phase A.1 EYWA DNA Graph (Field 6 Brand Personality drives color/typography choices)
- External: [W3C DTCG Spec](https://design-tokens.github.io/community-group/format/) — format specification
- External: [Style Dictionary](https://amzn.github.io/style-dictionary/) — DTCG transformation tool
- External: [Tokens Studio (Figma plugin)](https://tokens.studio/) — Figma 2-way sync tool
- Bootstrap Kit additions: `templates/folder-skeleton/design/` + `templates/folder-skeleton/brand-assets/`

---

### [DR-028] — Brand Genesis Protocol (BGP) Universal (2026-05-17) 🔒🌱🧬

**Status:** **Locked 2026-05-17** (operator-approved — final on first iteration, applied immediately to all brand repos + eywa-marketing)
**Bible Reference:** Part 30 NEW — Brand Genesis Protocol (BGP)
**Schema Reference:** No DDL change in this DR — uses existing tables. Optional `seo_website_page_master.brand_dna_alignment_score` field deferred to follow-up DR.
**Companion to:** EGP (Entity Genesis Protocol, Bible Part 2.6) — BGP is the brand-side parallel that produces foundation for EGP to consume
**Scope:** **UNIVERSAL** — applies to all 13 brand repos AND eywa-marketing (EYWA dogfoods its own protocol)

**Context:**

Pre-DR-028, Stage 1 Phase A produced an unstructured `brand-concept.md` narrative. Field-tested across 8 brand bootstraps (VTH BioDent, SmileScape, Trin Wellness, Classy Clinic, Deezy, Biodental Wellness, Relaxia, TC Smile) revealed consistent gaps:

1. **No structured brand DNA** — narratives drift, hard to enforce brand consistency across content
2. **No business goal mapping** — SEO tactics not explicitly tied to revenue/conversion goals → ROI hard to prove
3. **No TRUST baseline** — healthcare brands need pre-engagement audit to identify SEO content gaps
4. **Framework inputs invisible** — operators implicitly use Golden Circle / JTBD / CDJ but don't document → drift across sessions
5. **No brand-consistency check on output** — content gets published without final brand DNA alignment QC

EYWA promises "Be found first. By Google and AI" (DR-EYWA-MKT-004 tagline) — but for that to be commercially defensible, SEO must serve **Google + Brand + Business** simultaneously, not Google alone.

**Decision:**

Establish **Brand Genesis Protocol (BGP)** as a Universal Bootstrap Kit addition — parallel to EGP (Entity Genesis Protocol) but operating on brand-business layer rather than entity-knowledge layer.

#### 1. BGP = 5 Sub-phases (Phase A.0 → A.4)

```yaml
phase_A_0_pre_engagement_discovery:
  goal: Capture business context + stakeholders + constraints BEFORE bootstrap
  deliverable: docs/brand-genesis/business-context.md
  duration: 1-2 hour kickoff session
  outputs:
    - Business goals (12-month revenue, growth, market position)
    - Stakeholder map (decision makers, gatekeepers, end users)
    - Constraints (budget, timeline, compliance, regulatory)
    - Success metrics (definition of "win" in 12 months)

phase_A_1_eywa_dna_graph:
  goal: Structured brand DNA in 10 fields (Brand Key adapted for healthcare)
  deliverable: docs/brand-genesis/eywa-dna-graph.md
  duration: 4-6 hour workshop with operator + client
  outputs (10 fields):
    1. Target Patient (demographic + psychographic)
    2. Patient Insight (deep truth / pain / unmet need)
    3. Clinical Benefits (functional outcomes — measurable)
    4. Emotional Benefits (how patient feels after engagement)
    5. Reasons to Trust (RTBs — credentials, evidence, track record, social proof)
    6. Brand Personality (5-7 traits + 3-5 anti-traits)
    7. Discriminator (single point of differentiation vs key competitors)
    8. Brand Essence (one-line distilled identity)
    9. Competitive Frame (which playing field we choose)
    10. Compliance Boundaries (what we CAN'T claim — healthcare YMYL discipline)

phase_A_2_eywa_framework_synapse:
  goal: Document framework inputs that compose into EYWA methodology
  deliverable: docs/brand-genesis/framework-synapse.md
  duration: 2-3 hour session
  contains:
    - Golden Circle (WHY/HOW/WHAT) — brand purpose + methodology + services
    - EYWA Intent Roots (JTBD) — functional + emotional + social jobs patient hires clinic for
    - EYWA Journey Map (Consumer Decision Journey — McKinsey adapted)
       stages: Initial Consideration → Active Evaluation → Moment of Purchase → Post-Purchase → Loyalty Loop
       touchpoints: per stage, what channels/content/interactions exist?

phase_A_3_eywa_trust_rubric_baseline:
  goal: Audit current brand state across 5 TRUST pillars to identify SEO content gaps
  deliverable: docs/brand-genesis/eywa-trust-rubric.md
  duration: 3-5 hour audit (operator + client)
  five_pillars:
    T_trust: medical authority, credentials, evidence-backed claims, citations
    R_results: clinical outcomes, case studies, before/after, measurable success rates
    U_understanding: deep patient understanding, journey clarity, accessibility
    S_safety: compliance, contraindications, disclosures, YMYL discipline
    T_transparency: pricing transparency, process clarity, data handling, PDPA
  per_pillar_outputs:
    - Score 0-10
    - Evidence (what exists today)
    - Gaps (what's missing)
    - SEO content opportunity (what new content fills the gap)

phase_A_4_brand_business_seo_alignment_map:
  goal: Prove every SEO move serves a brand promise AND a business goal
  deliverable: docs/brand-genesis/alignment-map.md
  duration: 2-3 hour mapping session
  structure: Table per business goal with rows:
    - Business goal
    - Brand promise involved
    - TRUST pillar served
    - SEO tactic
    - Content cluster anchor
    - Success metric
  used_downstream: Phase B-E execution validates against this map; reporting back to client cites this table for ROI proof
```

#### 2. EYWA Naming Lexicon (Locked in this DR)

| Concept | EYWA Name |
|---------|-----------|
| Brand Key (Unilever-adapted) | **EYWA DNA Graph** |
| Consumer Decision Journey (McKinsey-adapted) | **EYWA Journey Map** |
| Jobs-to-be-Done (Christensen-adapted) | **EYWA Intent Roots** |
| Healthcare brand evaluation rubric (SASSY-analog) | **EYWA TRUST Rubric** |
| OKR / business outcome tracker | **EYWA Compound Growth** |
| Brand consistency AI check | **EYWA DNAi Diagnostic** |

Naming pattern: **"EYWA + concept"** for productized deliverables of Service Suite. Generic frameworks (Golden Circle, etc.) keep original names when cited as inputs.

#### 3. EYWA DNAi Diagnostic — Publication Pipeline Integration

Late-stage AI brand-alignment QC inserted into editorial workflow (Bible Part 23.4):

```yaml
pipeline_position:
  - Stage 0: Content draft (T-template structure + body content)
  - Stage 1: Human editorial review (accuracy, citations, voice — Part 23.4 existing)
  - Stage 2: EYWA DNAi Diagnostic (NEW — AI brand alignment check)
  - Stage 3: Revise if needed → re-run DNAi
  - Stage 4: Final approval gate
  - Stage 5: Publish

dnai_n8n_workflow:
  trigger: Notion page status="ready_for_dnai_check"
  inputs_pulled:
    - Content draft
    - docs/brand-genesis/eywa-dna-graph.md (10 fields)
    - strategy/messaging.md or equivalent voice ID + 5 axes
    - Anti-patterns list (per brand)
    - Compliance Boundaries (field 10 of DNA Graph)
  claude_api_call: |
    "Check this content against brand DNA Graph + voice ID + compliance.
     Return: pass/fail + specific issues + suggested revisions per issue."
  outputs_written_to_notion:
    - dnai_check_status: pass | warn | fail
    - dnai_check_score: 0-100
    - dnai_check_issues: structured JSON (issue, severity, suggestion)
    - dnai_check_revised_draft: AI-suggested revision (operator review)
  publish_gate: dnai_check_status='pass' AND human_editorial_approved
```

#### 4. EYWA Compound Growth — KPI Tracking Link

References existing Bible Part 20 (Measurement & KPI Framework). DR-028 doesn't redefine KPIs; instead establishes that **Phase A.4 Alignment Map success metrics → Part 20 KPI dashboard**, ensuring brand-business goals flow into ongoing measurement.

#### 5. Scope: Universal Application

**Applies immediately to:**
- All 13 brand repos (existing bootstrapped brands run Phase A.0-A.4 retroactively at next Stage gate; new brands run from kickoff)
- `eywa-marketing` repo (EYWA dogfoods its own protocol — Phase A docs become part of EYWA's strategy/ folder)
- Future brand engagements (mandatory pre-engagement deliverable)

**Bootstrap Kit additions:**
- `templates/folder-skeleton/docs/brand-genesis/` (new subfolder) with 5 template files

**Rationale:**

1. **Closes the brand-business-SEO triple-fit gap** — SEO can no longer drift away from brand promises or business goals. Every content piece traces back to alignment-map.md
2. **Productizes the methodology** — EYWA DNA Graph, EYWA TRUST Rubric become Service Suite deliverables (Audit tier output)
3. **EYWA self-application proves the protocol** — eywa-marketing site itself runs through BGP. Operator's own brand becomes the canonical reference implementation
4. **Parallel-structure with EGP** — operators familiar with Entity Genesis Protocol mental-model can adopt BGP fast. Both are "Genesis" protocols (foundation layers)
5. **TRUST baseline as Audit deliverable** — first commercial output of new client engagement = TRUST Rubric scorecard. Justifies premium pricing of EYWA™ Audit tier
6. **DNAi Diagnostic prevents content drift at scale** — humans miss subtle voice/brand violations as content volume grows. AI pre-publish gate catches what humans don't

**Consequences:**

- ✅ Phase A duration expands ~1 week → ~3 weeks (5 sub-phases), but Phase B-E becomes faster (foundation clearer)
- ✅ Client deliverables in week 1-3 of engagement become tangible (DNA Graph, TRUST Rubric, Alignment Map) — perceived value increases vs vague "we'll do SEO research"
- ✅ Brand-level DRs (`DR-{BRAND}-*`) become richer — anchored to DNA Graph + Alignment Map
- ✅ EYWA Service Suite (Audit / Graph / Stack / Vital / Forge / Score / Atlas) gains concrete deliverable mapping:
  - **EYWA Audit** = BGP Phase A.0-A.3 output package
  - **EYWA Graph** = Entity Genesis + Knowledge Graph build (Phase B-D)
  - **EYWA Stack** = Schema implementation + WP/Astro stack setup
  - **EYWA Vital** = Phase F content production retainer
  - **EYWA Forge** = Phase G growth + iteration retainer
  - **EYWA Score** = EYWA Compound Growth dashboard + reporting
  - **EYWA Atlas** = Enterprise multi-brand orchestration
- ⚠️ Operator workload: ~10-15 hours per new brand for Phase A (kickoff + 5 deliverable sessions)
- ⚠️ Existing 8 bootstrapped brands need Phase A retro-fit at next Stage gate (1-2 sessions per brand to backfill DNA Graph + TRUST baseline + Alignment Map)
- ⚠️ n8n DNAi Diagnostic flow needs build (~6-8 hours dev one-time)
- ⚠️ EYWA marketing site Phase A starts immediately — DNA Graph + TRUST + Alignment for EYWA itself

**Action items:**

- [x] Lock decision (this DR) — done 2026-05-17
- [x] Bible Part 30 NEW (BGP) — done 2026-05-17 with this commit
- [x] Bootstrap Kit additions: `templates/folder-skeleton/docs/brand-genesis/` with 5 templates — done 2026-05-17
- [ ] EYWA_HANDOVER update §brand-onboarding to reference BGP Phase A.0-A.4 — done with this commit
- [ ] eywa-marketing pilot: run BGP Phase A on EYWA itself (1-2 sessions, this week)
- [ ] Retrofit 8 existing brand repos with Phase A backfill at next Stage gate
- [ ] Build n8n DNAi Diagnostic flow (operator workload, ~6-8 hours dev)
- [ ] Update Content_Templates §7 Editorial Workflow to insert DNAi Stage 2 — done with this commit (v1.5 → v1.6)
- [ ] Future DR consideration: `seo_website_page_master.brand_dna_alignment_score` column (Schema v1.17 candidate)

**References:**

- Bible Part 30 NEW (Brand Genesis Protocol — BGP)
- Bible Part 2.6 (Entity Genesis Protocol — EGP, parallel sibling)
- Bible Part 20 (Measurement & KPI Framework — Compound Growth integration)
- Bible Part 23.4 (Editorial Review Workflow — DNAi insertion point)
- Bible Part 25.6 (Brand Config — DNA Graph fields may inform brand-config.json schema)
- Content_Templates v1.6 §7 (Editorial Workflow with DNAi Stage 2)
- DR-EYWA-MKT-003 (Knowledge Graph SEO Method™ — category claim, brand-business-SEO triple-fit reinforces)
- DR-EYWA-MKT-004 (Tagline locked — "Be found first. By Google and AI." now operationally enforced via BGP)
- DR-013 (12-edge vocabulary — DNA Graph concepts feed entity_graph as `concept` type with subtype='framework')
- DR-014 (Concept entity subtype — DNA Graph + TRUST Rubric + Compound Growth all qualify as `framework` subtype)
- External: Unilever Brand Key methodology (adapted, healthcare-extended with Compliance Boundaries)
- External: McKinsey Consumer Decision Journey (adapted as EYWA Journey Map)
- External: Christensen Jobs-to-be-Done (adapted as EYWA Intent Roots)
- External: Sinek Golden Circle (input framework, no rename)

---

### [DR-027] — Campaign Universal Master Table (Future Phase 1) (2026-05-12) 🌱📣

**Status:** Proposed (Phase 1 implementation — soak window opens upon DR-026 lock; review cycle TBD)
**Bible Reference:** Part 29.11 (Future: Campaign Master Track), Part 5 (Database Schema Architecture)
**Schema Reference:** v1.12 (hint only — no DDL ships in v1.12; full table ships in Schema v1.13+ when DR-027 locks)
**Pairs with:** DR-026 (Ads-LP Phase 0 — this DR is the Phase 1 successor)

**Context:**

DR-026 establishes the **Phase 0 Ads-LP Track** — Bible Part 29, page/keyword schema extensions, T-ADS-1 through T-ADS-5 templates, `/lp/{slug}/` URL convention. Phase 0 is sufficient for a brand to launch Google Ads with structured LPs and dual-use SEO/Ad keyword tracking. It is NOT sufficient for:

1. **Multi-platform campaign orchestration** — 1 campaign typically spans Google Ads + Meta Ads + (optionally) YouTube + LINE + TikTok with shared budget envelope, shared audience target, shared LP set
2. **Cross-platform consolidated reporting** — daily performance snapshot per platform aggregated to campaign level for budget reallocation decisions
3. **Junction between campaigns ↔ pages ↔ keywords** — 1 campaign uses N LPs and M keywords; 1 LP can serve multiple campaigns over time
4. **Historical performance archival** — Notion can't hold per-campaign-per-day-per-platform snapshot rows; Supabase is the right home

Operator vision (predates EYWA spec, see project memory): keyword + page tables are dimensional backbones; SEO is one track, Ads is another, and Campaign-level orchestration is the natural horizontal expansion. "ค่อยๆ ขยายออกด้านข้างไปเรื่อยๆ"

**Decision:**

Reserve DR-027 for the **Campaign Universal Master Table architecture** to ship in Schema v1.13 (or later) once DR-026 is locked and Phase 0 has live brand data (target: VTH BioDent post-launch, ~2-4 weeks after first Ads campaign). Until then, Phase 0 brands use the `campaign_id` TEXT stub column on `seo_page_master` (added in v1.12 per DR-026) to label LPs with campaign identifiers manually (e.g., `"vth-biodent-launch-2026-q2"`).

**Proposed Schema Sketch (Phase 1 — NOT shipped in v1.12):**

```yaml
seo_campaigns:
  purpose: Universal campaign orchestration across platforms (Google Ads, Meta Ads, YouTube, LINE Ads, TikTok Ads, organic launches)
  fp: campaign_fp (text PK, hash of brand_id + campaign_name + date_start)
  fk:
    - brand_id → brands.id (NOT NULL — every campaign belongs to one brand)
    - entity_focus_fp → seo_entity_graph.fingerprint (optional — primary entity the campaign targets)
  identity:
    - campaign_id (text — short slug, e.g., "vth-launch-2026-q2")
    - campaign_name (text — human label)
    - notion_page_id (text — Notion sync state)
  classification:
    - platforms text[] (enum: google_ads, meta_ads, youtube_ads, line_ads, tiktok_ads, other)
    - objective enum (lead_gen | awareness | conversion | retargeting | reactivation | launch | promo)
    - audience_tier enum (cold | warm | hot | mixed)
  financial:
    - budget_total_thb numeric(12,2)
    - budget_currency text default 'THB'
    - budget_per_platform jsonb  # {"google_ads": 50000, "meta_ads": 30000} — per-platform allocation
    - budget_pacing enum (front_loaded | even | back_loaded | accelerated)
  schedule:
    - date_start date
    - date_end date (nullable for ongoing)
    - status enum (planning | active | paused | completed | archived)
  governance:
    - approved_by_fp text (→ seo_authors_reviewers)
    - approval_date date
    - notes text

seo_campaign_pages (M2M junction):
  fk:
    - campaign_fp → seo_campaigns
    - page_fp → seo_page_master
  role enum (primary_lp | secondary_lp | thank_you | followup | dual_use_seo_page)
  active boolean default true
  added_at timestamptz default now()

seo_campaign_keywords (M2M junction):
  fk:
    - campaign_fp → seo_campaigns
    - keyword_fp → seo_x_ads_keywords_contextual_master
  platform enum (google_ads | meta_ads | youtube_ads | line_ads | tiktok_ads | other)
  match_type enum (exact | phrase | broad | broad_modified | negative)  # google ads style; phrase semantics for meta = audience interest mapping
  bid_strategy enum (manual_cpc | enhanced_cpc | maximize_clicks | maximize_conversions | target_cpa | target_roas)
  bid_amount_thb numeric(10,2) nullable
  budget_share_pct numeric(5,2)  # what % of campaign budget this KW gets
  active boolean default true

seo_campaign_performance_snapshot:
  purpose: Daily performance snapshot per campaign per platform (mirrors keyword_daily_logs pattern)
  fk: campaign_fp → seo_campaigns
  identity: (campaign_fp, platform, snapshot_date) UNIQUE
  metrics:
    - impressions int
    - clicks int
    - spend_thb numeric(10,2)
    - conversions int
    - conversion_value_thb numeric(12,2)
    - ctr numeric(7,4) GENERATED  # clicks / impressions
    - cpc numeric(8,2) GENERATED  # spend / clicks
    - cpm numeric(8,2) GENERATED  # spend / impressions * 1000
    - conv_rate numeric(7,4) GENERATED  # conversions / clicks
    - cpa_thb numeric(10,2) GENERATED  # spend / conversions
    - roas numeric(8,4) GENERATED  # conversion_value / spend
  quality_layer (platform-specific, jsonb):
    - quality_score (Google Ads — 1-10)
    - relevance_score (Meta — 1-10)
    - quality_ranking_engagement_rate_ranking_conversion_rate_ranking (Meta — low/avg/high)
```

**Rationale:**

- **Why a separate DR (not folded into DR-026):** DR-026 ships now; DR-027 needs Phase 0 field data + platform API integrations (Google Ads API, Meta Marketing API) before its full schema can be validated. Locking the architecture before brands have real campaign data risks premature DDL that needs migration later.
- **Why hint it in v1.12 (Bible Part 29.11):** Future readers need to know the `campaign_id` TEXT stub on `seo_page_master` is *transitional* — the FK target will materialize. Without the hint, brands might invest in alternative tracking (Notion-only, spreadsheets) that becomes legacy.
- **Why multi-platform from day 1 (when implemented):** Same operator vision — adding Meta/YouTube/TikTok later as separate tables creates platform silos. Single `platforms text[]` + per-platform junction rows scales cleanly.
- **Why include `campaign_pages` AND `campaign_keywords` M2M (not just one):** Many-to-many on both axes is real. 1 LP often serves multiple campaigns over time (especially Hero LPs); 1 campaign often targets multiple keyword clusters across platforms with different match strategies.
- **Why a separate `_performance_snapshot` table (not columns on `seo_campaigns`):** Mirrors successful pattern of `seo_x_ads_keywords_x_url_daily_logs` (DR-022 referenced). Keeps `seo_campaigns` static-ish (campaign-level config); performance rows grow daily and need partition-ready architecture.

**Consequences:**

- ✅ Phase 0 (DR-026) brands can launch Ads today using `campaign_id` TEXT stub
- ✅ When DR-027 ships, migration path is mechanical: parse distinct TEXT values, create `seo_campaigns` rows, populate `campaign_pages` junction from existing page rows, populate `campaign_keywords` from any KW-side ad_active flags already present
- ⚠️ Phase 0 brands MUST adopt a campaign_id naming convention from day 1 (e.g., `{brand-id}-{purpose}-{date-suffix}`) to make migration painless — Bible Part 29.11 documents naming convention
- ⚠️ Reporting Dashboard (cross-platform consolidated view) is a Phase 2 deliverable post-DR-027 lock — not promised in any Phase 0 brand handover
- ⚠️ Google Ads API + Meta Marketing API integration is operator workload (n8n flows) — DR-027 doesn't ship those flows, only the table that receives their output

**Open Questions (resolve before locking):**

- Should `seo_campaigns` carry attribution model field (last-click / data-driven / position-based) per platform, or live in performance snapshot? Decision deferred — operators rarely change model mid-campaign.
- Should `campaign_keywords.match_type` be platform-specific enum (Google match types vs Meta audience types are semantically different)? Likely yes — split into platform-typed jsonb `targeting_config` instead of single enum. Final form TBD with real Meta campaign data.
- Cross-brand campaigns (1 campaign for 2 brands — e.g., shared anti-aging launch by Genowell + Dr. Trin) — multi-brand FK or junction? Defer until ecosystem campaigns become real (Vertex node use case).

**References:**

- DR-026 (Ads-LP Phase 0 — predecessor, this DR is the Phase 1 successor)
- Bible Part 29.11 (Future: Campaign Master Track — placeholder hint)
- Bible Part 5 (Database Schema Architecture — host group for `seo_campaigns`)
- Operator vision document (predates EYWA spec) — keyword + page + entity as dimensional backbone, horizontal expansion via track tables
- Schema v1.12 §X (hint section only — no DDL); full DDL in Schema v1.13+

---

### [DR-026] — Ads Landing Page Track (Phase 0) (2026-05-12) 🌱📣

**Status:** Proposed (review window opens 2026-05-12, target lock 2026-06-21 — 40-day soak per Handover §9 default; pilot validation expected via VTH BioDent Google Ads launch ~2026-05-15)
**Bible Reference:** Part 29 (NEW — Ads Landing Page Track), Part 4 (Sitemap Architecture — Layer 1/2 unchanged; Ads-LP is parallel track)
**Schema Reference:** v1.12 (additive columns on `seo_page_master` + `seo_x_ads_keywords_contextual_master`; no new tables in Phase 0)
**Pairs with:** DR-027 (Campaign Universal Master — Future Phase 1 successor)

**Context:**

EYWA Protocol v3.15 is a comprehensive SEO + content + knowledge-graph specification. It has NOT addressed paid acquisition (Google Ads, Meta Ads, YouTube Ads, etc.) as a deliverable track. Operators have multiple live brand engagements (VTH BioDent, SmileScape, Dr. Trin, etc.) that will or have started running Google Ads — without spec guidance, each brand reinvents:

1. **LP architecture** — should the Hero Service SEO page double as Ads LP, or is `/lp/{slug}/` parallel structure required?
2. **Page table modeling** — is an Ads LP a row in `seo_page_master`? How does it differ from a SEO page?
3. **Keyword reuse** — when a brand bids on a keyword that also has an SEO target, how is the dual-use recorded? Are budgets/match-types stored anywhere?
4. **URL conventions** — `/lp/`, `/go/`, `/ad/`, `/promo/`? Index policy? Schema rules?
5. **YMYL governance** — do medical Ads LPs still require citation evidence rules (Bible Part 23)? (Yes — clarify in spec.)
6. **Templates** — current Content_Templates v1.3 lacks any Ads-optimized template; T1-T22 series targets SEO E-E-A-T + topical authority, not single-CTA conversion-focused LPs.

Without DR-026, brand work fragments into per-brand patterns that drift, contradict, and make Federation cross-brand analysis (cross-brand ad performance benchmarking) impossible.

**Decision:**

Establish the **Ads Landing Page Track** as a *parallel* implementation track to the existing SEO Track. The Ads Track rides on the **same dimensional backbone** (page_master, keyword_master, entity_graph) with **additive schema columns** + a **dedicated template family (T-ADS-X)** + a **new Bible Part (Part 29)**.

#### A. Page Purpose Taxonomy (additive enum on `seo_page_master`)

```yaml
page_purpose enum:
  seo_organic:
    description: Pure SEO page — indexed, hub-spoke, topical authority builder
    index_directive: index
    nav_treatment: full site nav
    cta_count: multiple soft CTAs allowed
    template_family: T1-T22 (SEO templates per Content_Templates v1.3)

  ads_lp:
    description: Pure Ads landing page — conversion-optimized, often noindex
    index_directive: noindex_lp (default) — operator can override per campaign for evergreen LPs
    nav_treatment: stripped or minimal (no full site nav distraction)
    cta_count: ONE primary CTA, repeated 2-3x on page
    template_family: T-ADS-1 to T-ADS-5 (NEW per Content_Templates v1.4)

  dual_use:
    description: Page serves BOTH SEO + Ads (commercial/transactional intent + conversion-optimized)
    index_directive: index
    nav_treatment: full site nav
    cta_count: dominant primary CTA but supporting SEO content depth
    template_family: T-DUAL-X (subset of T-ADS hybridized with T2 service-page) — see §29.6 eligibility
    eligibility_gate: must pass §29.6 Dual-Use Eligibility Criteria
```

#### B. URL Convention

```yaml
seo_organic pages: /{vertical-slug}/{topic-slug}/  # existing Bible Part 4 convention
ads_lp pages: /lp/{campaign-or-offer-slug}/  # NEW — `/lp/` segment marks Ads track
dual_use pages: existing SEO URL (no change) — flagged via page_purpose only
```

Rationale for `/lp/` prefix: visually clear to operators + analytics teams that the URL is an Ads LP; easy regex for Quality Score audits, robots.txt directives (e.g., AI crawler block on `/lp/*` if desired), and report segmentation.

#### C. Index Directive Enum (additive on `seo_page_master`)

```yaml
index_directive enum:
  index: standard — indexed by search engines (default for seo_organic + dual_use)
  noindex_lp: noindex,follow — Ads LP not indexed but link equity flows (default for ads_lp)
  noindex_nofollow: noindex,nofollow — fully isolated (e.g., A/B variant)
  dual: indexed AND served as Ads LP (rare — dual_use pages)
```

#### D. Conversion Event Taxonomy (additive on `seo_page_master`)

```yaml
conversion_event_primary enum:
  lead_form: form submission
  call_click: phone CTA click
  line_follow: LINE Add Friend / chat-initiate
  booking: appointment booking submitted
  download: lead magnet download
  package_view: pricing/package PDF view (high-intent intermediate signal)
  add_to_cart: e-commerce (rare in EYWA — most brands are clinic)

conversion_event_secondary text[]:  # additional events tracked but not primary KPI
```

Maps cleanly to Google Ads Conversion Actions + Meta Pixel Standard Events.

#### E. Campaign ID Stub (transitional column on `seo_page_master`)

```yaml
campaign_id text nullable:
  purpose: Phase 0 placeholder for campaign association
  values: free-form slug (operator convention: "{brand-id}-{purpose}-{date-suffix}", e.g., "vth-biodent-launch-2026-q2")
  future_state: when DR-027 locks, this column becomes campaign_fp (text FK → seo_campaigns)
  migration_plan: parse distinct values, create seo_campaigns rows, populate junction
```

#### F. Keyword Schema Extensions (additive on `seo_x_ads_keywords_contextual_master`)

```yaml
seo_active boolean default true:
  description: Keyword used in SEO content strategy
  rationale: explicit flag — some keywords are Ads-only (e.g., competitor brand bidding)

ad_active boolean default false:
  description: Keyword used in Ads bidding strategy (Google, Meta, etc.)

ad_intent_score smallint:  # 1-10
  description: How well the keyword fits Ads (10 = transactional/commercial buyer-ready, 1 = pure informational)
  rationale: helps operator decide which SEO keywords promote to Ads
  default: NULL (operator scores during keyword research)

ad_match_type_preferred enum:
  values: exact | phrase | broad | broad_modified
  rationale: planning-time preference; actual platform match enforced at campaign level

ad_landing_page_fp text nullable:
  description: FK to seo_page_master.fingerprint — the LP intended for this KW
  rationale: 1 keyword → 1 primary LP for now (Phase 0); Phase 1 moves to campaign_keywords M2M

ad_priority_tier enum: t1 | t2 | t3 | none
  description: Budget priority — t1 = always-on hero KW, t2 = supporting, t3 = exploratory
```

#### G. T-ADS Template Family (Content_Templates v1.4 — NEW)

5 templates ship Phase 0:

```yaml
T-ADS-1: Hero Service LP
  purpose: Single-service conversion focus (e.g., "Dental Implant Free Consultation")
  block_structure: Hero (offer + CTA) → Trust strip (logos/credentials) → Benefits (3-5 bullets) → Social proof (review snippets) → Process (3-step) → FAQ (5 max) → Final CTA + booking widget
  word_count_target: 400-800 words
  schema: Organization + LocalBusiness + Offer + (medical brands: MedicalBusiness)

T-ADS-2: Booking / Consultation LP
  purpose: Drive appointment booking — calendar widget prominent
  block_structure: Hero (offer + booking widget above fold) → What you get (3 bullets) → Doctor intro (1 person, photo + 2-line credential) → 1-paragraph social proof → FAQ (3 max) → Repeat booking CTA
  word_count_target: 300-600 words
  schema: Organization + Offer + Person (doctor)

T-ADS-3: Promo / Limited Offer LP
  purpose: Time-bound offer (countdown, scarcity) — e.g., "Founding 100 patients only"
  block_structure: Hero (offer + countdown timer + CTA) → What's included (price stack) → Why now (urgency rationale) → Eligibility (who qualifies) → How to claim (3-step) → Repeat CTA + terms
  word_count_target: 350-700 words
  schema: Organization + Offer (with priceValidUntil)
  guardrail: Bible Part 23 YMYL evidence rules STILL APPLY for medical claims; price/promo terms must be operator-verified

T-ADS-4: Comparison / Alternative LP
  purpose: Win clicks from competitor brand keywords or alternative-seeking intent
  block_structure: Hero (positioning statement) → Comparison table (us vs alternative — neutral framing) → Differentiation bullets (3-5) → Doctor/credential trust → CTA
  word_count_target: 500-900 words
  schema: Organization + (no Offer if pure positioning)
  guardrail: Comparative claims must avoid disparagement (Bible Part 23.5 + Thai consumer protection law). If naming competitors, use factual public information only.

T-ADS-5: Lead Magnet / Download LP
  purpose: Email/LINE capture in exchange for downloadable resource (e-book, guide, checklist)
  block_structure: Hero (asset preview + capture form) → What's inside (3-5 bullets) → Who it's for → Author credential (1-line) → Form (minimal fields) → Privacy note
  word_count_target: 200-400 words
  schema: Organization + (resource = ImageObject or CreativeWork)
  data_capture: PDPA consent checkbox MANDATORY per Bible Part 23.6
```

#### H. Dual-Use Eligibility Criteria (when a SEO page CAN serve as Ads LP)

A page can be `page_purpose='dual_use'` ONLY IF:

1. **Intent match:** Page targets commercial/transactional intent keyword (not informational/research)
2. **CTA prominence:** Primary CTA visible above fold on mobile + repeated at 1-2 mid-page positions
3. **Conversion infrastructure:** Conversion tracking pixel/event installed; LINE/phone/form CTAs all wired to GTM
4. **Page load:** CWV LCP < 2.5s mobile, CLS < 0.1, INP < 200ms (matches Bible Part 19 CWV standards)
5. **Content focus:** Single dominant offer (not a hub page listing 10 services)
6. **Quality Score viability (post-launch check):** Google Ads Quality Score ≥ 7 after 2-week stabilization; if < 7 for 4+ weeks, demote to seo_organic and build parallel `/lp/` version

Operator MUST document dual_use justification in `viability_assessment` column (Bible Part 4.14 reuse) when marking a page dual_use.

#### I. YMYL Evidence Rules — UNCHANGED for Ads LPs

Bible Part 23 (Medical Content Excellence) citation tier rules + editorial review workflow apply IDENTICALLY to Ads LPs that make medical claims. Ads LPs do NOT get a YMYL exemption. Rationale: Thai PDPA + medical advertising regulations (พรบ.การโฆษณาทางการแพทย์) + Google's ad policy enforcement of medical claim accuracy. Brand legal exposure does not decrease because content is on a `/lp/` URL.

#### J. Phase 0 Scope Boundary

Explicitly NOT shipped in DR-026:

- ❌ `seo_campaigns` table (deferred to DR-027 Phase 1)
- ❌ Cross-platform Meta Ads, YouTube Ads, LINE Ads, TikTok Ads orchestration (architectural sketch only in DR-027)
- ❌ Performance snapshot pipeline (n8n Google Ads API → Supabase flow)
- ❌ Consolidated dashboard (Phase 2)
- ❌ A/B testing variant management (Phase 2 — likely separate DR)

**Rationale:**

- **Why Proposed (not Locked):** Standard 40-day soak per Handover §9 default. Pilot validation via VTH BioDent Ads launch will surface real-world spec gaps before lock — locking before pilot risks DDL changes post-deployment.
- **Why parallel `/lp/` URL structure (not subdirectory of service pages):** Clean separation of analytics scope, ability to robots.txt or noindex en masse, immediate visual signal in operator/legal review. Service page URLs remain canonical for organic.
- **Why same `seo_page_master` table (not separate `ads_lp_pages` table):** Operator vision is dimensional — every URL is a row, every URL has fingerprint, every URL has CWV metrics. Splitting into ads vs seo tables would duplicate the page lifecycle logic, fragment reporting, and break the single-table dashboard story.
- **Why `campaign_id` TEXT stub (not FK from day 1):** Phase 0 needs to ship before DR-027 can ship; FK requires the target table to exist. TEXT stub captures operator intent for clean migration later. Cost of "wrong stub value" is low (rename string); cost of NOT capturing campaign association now is high (impossible to attribute Phase 0 page rows to campaigns retrospectively).
- **Why T-ADS-1 through T-ADS-5 (not more):** 5 templates cover ~95% of clinic/wellness Ads use cases. Add T-ADS-6+ only when a brand surfaces a use case not handled by existing 5 — avoid speculative templates.
- **Why YMYL rules unchanged (no relaxation for LPs):** Legal/regulatory exposure is per-claim, not per-URL. A medical claim on `/lp/dental-implant/` carries identical risk as on `/services/dental-implant/`. Spec consistency reinforces brand discipline.

**Consequences:**

- ✅ Operators can launch Google Ads with structured spec compliance — page model, KW model, template choice all defined
- ✅ Federation cross-brand Ads benchmarking becomes possible (same `page_purpose` enum, same Quality Score model, same conversion event taxonomy across 13 brands)
- ✅ Phase 0 → Phase 1 (DR-027) migration path is clean (TEXT stub → FK)
- ✅ VTH BioDent Ads launch (target ~2026-05-15) has spec to follow — no per-brand reinvention
- ✅ Bible v3.16 ships with Part 29 (Ads Landing Page Track) as first-class spec section
- ⚠️ Schema v1.12 migration: 5 columns added to `seo_page_master`, 6 columns added to `seo_x_ads_keywords_contextual_master` (all nullable, additive — zero downtime)
- ⚠️ Content_Templates v1.4 adds T-ADS-1 through T-ADS-5 as new family (DRAFT status, pending DR-020 lock cycle 2026-06-07)
- ⚠️ Brand snapshot blocks (`eywa_spec_snapshot`) need refresh at next Stage gate for brands currently on bible_version 3.15
- ⚠️ Quality Score < 7 dual_use demote workflow needs operator runbook (deferred to Brand Handover §X update post-pilot)
- ⚠️ Conversion tracking n8n flow (Google Ads Conversions API → Notion + Supabase) is operator work — DR-026 doesn't ship the flow, only the data model that receives it

**Open Questions (resolve during pilot, before lock):**

- Does T-ADS-3 (Promo) need PDPA consent banner pattern documented in template (alongside the form on T-ADS-5)? Likely yes for any LP with form capture — clarify in v1.4 lock.
- Should `index_directive='noindex_lp'` also imply removal from sitemap.xml? Default to YES (excluded from XML sitemap); operator override allowed for evergreen LPs.
- Cross-brand "competitor Ads LP" pattern (e.g., Trin running an Ads LP that compares against W9 by name) — needs Bible Part 23.5 comparative-claim discipline reinforcement? Yes; add §29.10 cross-ref to Part 23.5.
- For Thai clinics: should T-ADS-2 (Booking) include LINE-first capture pattern as default (LINE OA Add Friend > form)? Most clinic brands prioritize LINE; document as template variant.

**References:**

- Bible Part 29 (NEW — Ads Landing Page Track, ships in v3.16)
- Bible Part 4 (Sitemap Architecture — Ads-LP is parallel track, not Layer 1/2 substitute)
- Bible Part 23 (Medical Content Excellence — YMYL rules apply to Ads LPs unchanged)
- Bible Part 19 (Data Quality + CWV — dual_use eligibility gate)
- Content_Templates v1.4 §X (T-ADS-1 through T-ADS-5)
- Schema v1.12 §5.1 (seo_page_master additions), §6.X (keyword_master additions), §X.X (seo_campaigns hint for Phase 1)
- DR-022 (Lean Phase B + Two-Layer Sitemap — Ads is third dimension, not part of Layer 1/2)
- DR-027 (Campaign Universal Master — Phase 1 successor)
- Operator vision document (predates EYWA spec) — keyword + page as dimensional backbone, Ads as horizontal expansion

---

### [DR-025] — Restore Local SEO Tables + Consolidate `seo_locations` → `seo_branches` (2026-05-12) 🔒🏥

**Status:** Locked 2026-05-12
**Bible Reference:** Part 4.4 (Type B Branch Landing), Part 10.5 (Local SEO), Part 17.6 (n8n GROUP E Flows), Appendix B.5
**Schema Reference:** v1.11 (Group 1 — Brand & Organization)

**Context:**

Bible v3.14 Appendix B.5 specifies a **5-table Local SEO subsystem** (Category D, Phase 1 Day 1 for clinic verticals): `seo_locations`, `seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`, `seo_local_rankings`. Bible Part 17.6 (n8n GROUP E) defines 4 operational flows (E1 GBP Reviews sync 6h, E2 GBP Posts publish, E3 NAP audit weekly, E4 GBP Posts metrics) that depend on these tables.

Schema_Overview v1.10 silently dropped 3 of these tables (`seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`) — never explained, never DR'd. Only `seo_local_rankings` survived (Group 5) and `seo_locations` was renamed to `seo_branches` (Group 1, Section 3.2) with a **minimal schema (~25 cols)** missing ~15 columns specified in Bible Table 24 (multi-directory IDs, GBP categories/rating, photos, compliance, staff assignment, special hours).

Without these tables: Bible n8n Group E flows are non-implementable; clinic brands (VTH BioDent, Deezy, TC Smile, SmileScape, Dr. Trin) cannot deliver Local SEO at Day 1 (Bible Part 10.5 promise).

**Decision:**

**A. Restore all 5 Local SEO tables in Schema v1.11.** Three are net-new (reviews, directory_listings, gbp_posts), one is enhanced (branches), one already exists (local_rankings — only FK rename needed).

**B. Consolidate `seo_locations` → `seo_branches`** as the canonical name. Reasons:
- `seo_branches` already exists in Schema v1.10 with real `branch_*` fingerprint columns + Notion sync state
- Bible Part 4.4 already uses "Branch Landing" terminology
- Thai operator context: "สาขา" (branch) is the established business term
- Semantically 1 brand → N branches, 1 branch = 1 physical location (1:1 mapping) — no need for 2 tables
- Renaming in Bible (~8 references) is cheaper than renaming in Schema + Notion + n8n flows

**C. Enhance `seo_branches` to full Bible Table 24 spec** — add ~15 columns:
- NAP completeness: `business_name_legal`, `business_name_brand`, `district`, `formatted_address`, `plus_code`
- Contact: `line_id`, `special_hours jsonb`
- Staff/Equipment: `doctors_at_branch_fps text[]` (→ seo_authors_reviewers), `equipment_at_branch_fps text[]`, `specialties_at_branch text[]`
- GBP completeness: `gbp_account_id`, `gbp_categories text[]`, `gbp_review_count int`, `gbp_avg_rating numeric(3,2)`, `gbp_last_synced_at timestamptz`
- Other directories: `apple_maps_id`, `facebook_page_url`, `wongnai_url`, `wongnai_id`
- Schema/Photos: `local_business_schema_type`, `primary_photo_url`, `exterior_photos text[]`, `interior_photos text[]`
- Status/Compliance: `status` (active/closed/temp-closed), `opened_date`, `closed_date`, `business_registration_no`, `medical_license_no`
- NEW FK: `organization_entity_id uuid FK→seo_entity_graph(id)` — links branch to its organization entity for KG

**D. Three new tables (full schemas in Schema v1.11 §3.5/3.6/3.7):**

```yaml
seo_reviews:
  purpose: Multi-platform review aggregation + PDPA-safe response workflow
  fk: branch_id→seo_branches, brand_id→brands, responded_by_fp→seo_authors_reviewers, mentioned_entities_fps[]→seo_entity_graph
  sources: GBP, Wongnai, Facebook, Google Maps, Pantip mentions
  unique: (source_platform, source_review_id) — dedupe
  pdpa_critical: response_legal_reviewed, pdpa_risk_flag, reviewer_anonymized
  flow: E1 (GBP Reviews sync every 6h)

seo_directory_listings:
  purpose: Track NAP citations across ~50 directories per branch + auto-detect inconsistency
  fk: branch_id→seo_branches, brand_id→brands
  distinct_from: seo_citations (academic/PubMed — these are Local SEO directory listings)
  key_fields: directory_name, citation_url, status, claim_status, business_name_listed, address_listed, phone_listed, nap_match_score (GENERATED), has_inconsistency
  flow: E3 (NAP audit weekly)

seo_gbp_posts:
  purpose: GBP Posts management + local archive (GBP posts disappear after 6 months)
  fk: branch_id→seo_branches, brand_id→brands, approved_by_fp→seo_authors_reviewers
  multi_location: batch_id, parent_post_id (cross-branch campaigns)
  flows: E2 (publish), E4 (metrics sync daily)
```

**E. `seo_local_rankings` FK rename:** `location_id` → `branch_id` (FK → `seo_branches`). Already in Schema v1.10 Group 5 — Bible Table 28 referenced `location_id` which never matched the actual schema.

**F. Bible Appendix B.5 + Part 17.6 + Part 4.4 rename:** All 8 references to `seo_locations` in Bible v3.14 become `seo_branches`. Bumps Bible v3.14 → v3.15.

**Rationale:**

- **Why now (not deferred):** Clinic brands are in active Stage 1 work (VTH BioDent done, SmileScape Phase E, 3 others queuing). Phase 5 of any clinic deployment requires Local SEO — postponing forces architecture rework later.
- **Why Locked immediately (no Proposed soak):** This is a *restore of forgotten spec*, not new design. Bible v3.14 already documented these tables (Appendix B.5 unchanged since v2.3 / 2026-05-01); Schema simply fell behind. The DR formalizes catch-up, doesn't propose new ideas.
- **Why consolidate to `seo_branches` (not `seo_locations`):** See §B above. Lower total churn (rename Bible once vs rename Schema + Notion + n8n + downstream brand docs).

**Consequences:**

- ✅ Bible n8n GROUP E flows (E1/E2/E3/E4) become implementable
- ✅ Clinic brand Phase 5 (Local SEO) unblocked
- ✅ NAP consistency monitoring + PDPA-safe review responses operational
- ✅ Schema v1.11 ships with Group 1 = 7 tables (was 4), Group 5 unchanged
- ⚠️ Migration files needed: `009_enhance_seo_branches.sql`, `010_create_seo_reviews.sql`, `011_create_seo_directory_listings.sql`, `012_create_seo_gbp_posts.sql`, `013_rename_local_rankings_fk.sql`
- ⚠️ Existing brands with `seo_branches` rows: backfill new columns as available (NULL allowed initially)
- ⚠️ Bible v3.15 ships paired with Schema v1.11 — coordinated bump
- ⚠️ Brand snapshot blocks (`eywa_spec_snapshot`) need refresh at next Stage gate for brands currently on bible_version 3.14

**References:**
- Bible Part 4.4 (Type B Branch Landing) — naming origin
- Bible Part 10.5 (Local SEO) — strategic rationale
- Bible Part 17.6 GROUP E (n8n Flows E1-E4) — operational dependencies
- Bible Appendix B.5 (5-table Local SEO subsystem)
- Schema v1.11 §3.2 (enhanced seo_branches), §3.5 (seo_reviews), §3.6 (seo_directory_listings), §3.7 (seo_gbp_posts), §7.2 (seo_local_rankings FK rename)
- DR-024 (paired — Restore 9 Extension Tables, same v1.11 release)

---

### [DR-024] — Restore 9 Entity Extension Tables (2026-05-12) 🔒🧬

**Status:** Locked 2026-05-12
**Bible Reference:** Part 2.5 (Entity Polymorphism), Part 5.11 (Group 9), Part 14 (Vertical Profiles), Appendix B.3
**Schema Reference:** v1.11 (Group 9 — Entity Extensions & Templates)

**Context:**

Bible v3.14 Appendix B.3 specifies **9 type-specific extension tables** (Category B, 1:1 FK to `seo_entity_graph` ON DELETE CASCADE, populate trigger when `entity_type` matches):

```
11. seo_entity_ingredient   (entity_type='ingredient')
12. seo_entity_product      (entity_type='product')
13. seo_entity_procedure    (entity_type='procedure')
14. seo_entity_condition    (entity_type='condition')
15. seo_entity_drug         (entity_type='drug')
16. seo_entity_anatomy      (entity_type='anatomy')
17. seo_entity_organization (entity_type='organization')
18. seo_entity_lab_test     (entity_type='lab_test')
19. seo_entity_device       (entity_type='device')
```

This was introduced in Bible v2.0 (2026-04-30) as the universal core + extension pattern (`#`universal entity_graph` + 1:1 type-specific extension`) and has not changed in strategy since.

Schema_Overview v1.10 documents only 3 of 9 extensions (`ingredient`, `procedure`, `device`) in Group 9 (§11.1-11.3) plus `seo_programmatic_templates` (§11.4 — unrelated to entity polymorphism). The remaining 6 extensions (product, condition, drug, anatomy, organization, lab_test) silently disappeared between Schema v1.0 (which Bible §5.11 line 6918 references for "Full schemas + all 22-24 columns per extension table") and v1.10. No DR explained the removal.

Without these tables: T1 medical-condition template (Bible Part 4.1.1) has no condition extension to bind ACF fields; drug monograph pages have no monograph store; anatomy entities can't carry FMA/UBERON IDs for knowledge graph; external orgs collapse into either `brands` (wrong scope) or generic `entity_graph` (loses typed columns).

**Decision:**

**A. Restore 6 missing extension tables in Schema v1.11 Group 9.** All 1:1 FK to `seo_entity_graph(id)` via `entity_fp text FK→seo_entity_graph.fingerprint` (matches pattern of `seo_entity_ingredients` v1.10 §11.1).

```yaml
seo_entity_product:
  entity_type: product
  schema_org: Product, MedicalDevice (overlap)
  key_fields: gtin, sku, brand_owner_fp, product_category, ingredients_fps[]→seo_entity_ingredient, thai_fda_reg_no, regulatory_status, pregnancy_safe, certifications[], price_range
  used_by: the brand (skincare), Dr. Trin (supplement), any brand selling product
  template: T-product, T-comparison, T-listicle

seo_entity_condition:
  entity_type: condition
  schema_org: MedicalCondition
  key_fields: icd10_code, snomed_ct_id, mesh_id, prevalence_thailand, severity_levels[], symptoms[], related_anatomy_fps[]→seo_entity_anatomy, treatment_drugs_fps[]→seo_entity_drug, treatment_procedures_fps[]→seo_entity_procedure, affected_age_groups[]
  used_by: ALL medical brands (VTH, Deezy, SmileScape, Dr. Trin, the brand)
  template: T1-medical-condition (primary Bible Part 4.1.1)

seo_entity_drug:
  entity_type: drug
  schema_org: Drug
  key_fields: rxnorm_code, atc_code, thai_fda_reg_no, prescription_required, indications_fps[]→seo_entity_condition, contraindications_fps[]→seo_entity_condition, side_effects[], pregnancy_category, breastfeeding_category, controlled_substance_class
  used_by: VTH (post-surgery antibiotics), Dr. Trin (TRT/vitamins), the brand (cosmeceuticals borderline)
  template: T-drug-monograph

seo_entity_anatomy:
  entity_type: anatomy
  schema_org: AnatomicalStructure
  key_fields: fma_id (Foundational Model of Anatomy), uberon_id, body_system, parent_anatomy_fp (self-FK hierarchy), child_anatomy_fps[], affected_by_conditions_fps[]→seo_entity_condition
  used_by: ALL medical brands (anatomy → condition → procedure knowledge graph)
  template: T-anatomy-reference (mostly supporting entity, rarely standalone page)

seo_entity_organization:
  entity_type: organization
  schema_org: Organization, MedicalOrganization
  key_fields: wikidata_qid, legal_name, founding_date, headquarters_location, parent_organization_fp (self-FK), organization_type (clinic/hospital/professional_association/regulator/manufacturer/accreditation_body)
  used_by: ALL brands — external orgs (Thai Dental Association, Thai FDA, ADA, Wikidata Q-entities, manufacturers)
  scope_note: SEPARATE from `brands` table — brands = own brands (~10-50); seo_entity_organization = external refs (~100-500)
  template: About pages, citation source attribution, accreditation refs

seo_entity_lab_test:
  entity_type: lab_test
  schema_org: MedicalTest
  key_fields: loinc_code, cpt_code, test_category (imaging/blood/biopsy), sample_type, preparation_instructions, reference_ranges[], related_conditions_fps[]→seo_entity_condition
  used_by: VTH (x-ray, CBCT, blood test pre-surgery), Dr. Trin (hormone panel), future hospitals
  template: T-diagnostic-service, T-test-info
```

**B. Keep existing 3 extensions** (`seo_entity_ingredients`, `seo_entity_devices`, `seo_entity_procedures`) — already in §11.1-11.3. Plural form (`ingredients` not `ingredient`) preserved for backward compat; Bible Appendix B singular form treated as informal.

**C. Keep `seo_programmatic_templates`** as §11.10 (was §11.4) — not an entity extension, but logically Group 9 (template registry for Type C programmatic pages, Bible Part 9).

**D. Group 9 count update:** 4 → 10 tables (9 extensions + 1 template registry).

**Rationale:**

- **Why Locked immediately (no Proposed soak):** Bible v2.0 strategy unchanged for 13+ days; Bible Appendix B.3 has been authoritative since 2026-04-30; Schema v1.10 drop was undocumented (no DR, no changelog note) — clearly oversight, not deliberate design change. Restoring known-good spec doesn't warrant 2-week soak.
- **Why all 9 (not subset):** Bible Vertical Profiles (Part 14) explicitly maps 6 verticals to extension table usage (dental → procedure/condition/drug; skincare → ingredient/product/condition; etc.). Partial restoration creates per-vertical gaps.
- **Why `entity_fp` (text FK) not `entity_id` (uuid FK):** Matches existing §11.1 pattern (`entity_fp text FK→seo_entity_graph.fingerprint`). Fingerprint-based FKs align with DR-008 Two-Column Identity (immutable machine ID). Bible Appendix B.3 says "1:1 FK to `seo_entity_graph.id`" but Schema v1.10 §11.1 uses `entity_fp` — sticking with Schema convention; updating Bible to match.

**Consequences:**

- ✅ T1 medical-condition template binding becomes implementable (ACF field group ↔ seo_entity_condition columns)
- ✅ Knowledge graph cross-refs (condition ↔ anatomy ↔ drug ↔ procedure) become typed FKs not text matches
- ✅ External organization citation source attribution becomes schema-clean (separate from `brands`)
- ✅ All clinic, dental, dermatology, hospital, skincare-media verticals (Bible Part 14) become Day-1 schema-complete
- ⚠️ Migration files needed: `014_restore_entity_product.sql`, `015_restore_entity_condition.sql`, `016_restore_entity_drug.sql`, `017_restore_entity_anatomy.sql`, `018_restore_entity_organization.sql`, `019_restore_entity_lab_test.sql`
- ⚠️ Each extension table needs populate trigger: `trg_populate_entity_{type}_on_insert` (fires when `entity_graph.entity_type = '{type}'`)
- ⚠️ Bible Appendix B.3 column hints (2026-04-30 era) need cross-check against current Schema v1.11 column definitions; minor field rename per current naming convention possible
- ⚠️ Brands actively building T1 medical-condition pages (VTH BioDent OSA, etc.) gain schema binding at next Stage 1.5 gate

**References:**
- Bible Part 2.5 (Entity Polymorphism — universal core + extension pattern)
- Bible Part 5.11 (Group 9 — Entity Extensions & Templates)
- Bible Part 14 (Vertical Profiles — per-vertical extension usage)
- Bible Appendix B.3 (Tables 11-19, schema summaries)
- Schema v1.11 §11.1-11.9 (extensions) + §11.10 (programmatic_templates)
- DR-025 (paired — Restore 5 Local SEO Tables, same v1.11 release)
- DR-008 (Two-Column Identity — fingerprint FK pattern)

---

### [DR-022] — Lean Phase B + Two-Layer Sitemap + Iterative Refinement (2026-05-11 → Locked 2026-05-12) 🔒🌳

**Status:** **Locked 2026-05-12** (early lock — field-tested across 5 brands; review board fast-tracked per operator approval; ≥99.99% Google-principle aligned per Bible Part 1.5 + industry consensus 2026)
**Locked Bible Version:** v3.19 (Part 4 Two-Layer Sitemap pattern already authoritative; lock formalizes status)
**Locked Schema Version:** v1.15 (no DDL change — uses existing 4 KW tables)
**Bible Reference:** Part 4 (Sitemap Architecture), Part 23.1 (Citation), Part 25.6 (Brand Config)
**Schema Reference:** No schema changes — uses existing 4 KW tables (`seo_x_ads_keywords_contextual_master`, `seo_x_ads_keywords_monthly_market_snapshot`, `seo_x_ads_keyword_serp_competitors`, `seo_x_ads_keywords_x_url_daily_logs`)

**Lock Audit Trail (2026-05-12):**

```yaml
field_test_evidence:
  - "Deezy Dental: Sitemap 764p + Entity 251 + Keywords 2,103 done using Layer 1/Layer 2 split"
  - "Classy Clinic: Phase B+C+D complete (808p v18, 279 entities, 28 clusters) per Lean Phase B pattern"
  - "VTH BioDent: Stage 1 done using brand-immune Layer 1 + volume-driven Layer 2"
  - "SmileScape: Phase E in progress (414p WIP) per Two-Layer pattern"
  - "Trin Wellness: Phase B keyword research + competitor scan + patient journey + citations all per DR-022 lean template"
operator_approval:
  date: 2026-05-12
  rationale: |
    Cross-brand field test depth (5 brands × 2-3 months) exceeds typical Proposed soak.
    Two-Layer Sitemap principle is industry consensus 2026 (HubSpot, Ahrefs, SEMrush
    confirm volume-immune topical authority Layer 1 + volume-driven Layer 2 pattern).
    Brand-immune E-E-A-T topical authority IS Google's stated March 2026 Core Update
    priority. Waiting until 2026-06-07 review provides marginal certainty at
    meaningful operational cost (5 brands × 3 weeks stalled decision-making).
follow_up_workload:
  - "Companion DRs lock together (DR-019/020/021) — paired batch"
  - "DR-016 Page Viability §4.14 amendment for Layer 1 exemption (already locked)"
  - "Brand snapshot block refresh at next Stage gate for brands on bible_version 3.18"
```


**Context:**

Original Phase B (Handover §7.3 v1.7) was a single lump phase mixing competitor scan, KW research, patient journey, content audit. Field-tested with VTH BioDent + SmileScape revealed three operational problems:

1. **Volume gate confusion** — Spec didn't say whether DFS volume data was required before sitemap/entity work could proceed. Operators either over-waited (bottleneck) or skipped volume entirely (under-prioritized).
2. **Cost inefficiency** — Pulling DFS SERP scrape on full seed list (~680 KW for SmileScape) wastes spend on long-tail KW that get cut anyway. SERP scrape is the expensive endpoint (~$0.60-2.00 per 1000 KW vs $0.05 for volume).
3. **Volume-driven page cuts vs brand-driven sitemap conflict** — Some operators cut service pages with low volume, fragmenting topical authority and brand narrative. Industry shift (Google E-E-A-T era + AI search context absorption) favors complete topical coverage over volume-only selection.

**Decision:**

Reorganize Phase B into a **lean planning loop** with **async background enrichment** and **single iterative refinement**, replacing the volume-gated multi-phase model.

#### 1. Two-Layer Sitemap Architecture

```yaml
layer_1_brand_service:
  scope: [Section 1 Home, 2 Uniqueness, 3 Services, 4 Technology, 7 Branches, 8 Contact]
  policy: VOLUME-IMMUNE — every service/signature/founder/branch the brand has = page
  rationale: topical authority + E-E-A-T + brand truth + AI citation context completeness
  cut_allowed: NEVER for low-volume reasons

layer_2_knowledge_blog:
  scope: [Section 5 Concerns, Section 6 Knowledge]
  policy: VOLUME-DRIVEN — additions selected via gap discovery from enriched KW data
  rationale: traffic harvesting + AI citation entry + funnel TOFU
  cut_allowed: yes for Layer 2 candidates that fail Page Viability (DR-016)

layer_3_internal_linking:
  policy: VOLUME-AWARE for weighting, STRUCTURE-FIXED for existence
  rationale: priority_score guides authority flow; never used to delete pages
```

#### 2. Lean Phase B (single human-blocking phase, not 5 sub-phases)

```yaml
phase_B_lean:
  inputs:
    - brand-concept.md (Phase A output)
    - operator domain knowledge
    - WebSearch breadth research (competitor sitemaps, manual SERP/PAA peek, autocomplete)

  outputs:
    - keyword-seed-list.md         # Brand-driven KW dump (no DFS — current SmileScape pattern)
    - competitor-scan.md           # Layer 1 competitive landscape
    - citation-pool-seed.md        # 5-15 sources per pillar (existing Phase B.2)
    - patient-journey.md           # audience research

  what_NOT_to_do_in_phase_B:
    - DO NOT pull DFS volume here (deferred to async background)
    - DO NOT make page cuts based on volume (Layer 1 immune)
    - DO NOT block waiting for volume data
```

#### 3. Stage 1 Gate Adjustment

Stage 1 Gate confirms: **sitemap structure + entity graph + KW seed list + citation pool seed** — NOT volume data. Operator can proceed to Stage 1.5 with structural confidence alone.

#### 4. Stage 1.5 Push + Async Enrichment Trigger

```yaml
stage_1_5_migration:
  step_1: markdown content-plan/ → Supabase tables (existing)
  step_2: Notion ↔ Supabase sync (existing DR-006)
  step_3_NEW: n8n auto-trigger on seo_x_ads_keywords_contextual_master INSERT
              → cheap pull (volume + KD + CPC) into seo_x_ads_keywords_monthly_market_snapshot
              SLA: within 24-48h
              cost_gate: none (cheap)
  step_4_NEW: operator approves Tier A/B shortlist for SERP scrape
              → DFS SERP API → seo_x_ads_keyword_serp_competitors
              cost_gate: manual approval (~$0.10-0.30 per shortlist batch)
              SLA: within 7 days of approval
```

#### 5. Phase E.refine — Iterative Refinement (NEW phase, post-enrichment)

```yaml
phase_E_refine:
  trigger: enrichment data lands in monthly_market_snapshot + serp_competitors
  
  inputs_AI_analyzes:
    - seo_x_ads_keywords_contextual_master (operator authored)
    - seo_x_ads_keywords_monthly_market_snapshot (enriched volume + scores)
    - seo_x_ads_keyword_serp_competitors (PAA + related + competitor URLs)
    - sitemap.md (Layer 1 + Layer 2 current)
    - entities.md / clusters.md
  
  output: gap-report.md with structured findings:
    - high_vol_kw_no_entity        → entity gap to fill
    - high_vol_kw_no_page          → Layer 2 page candidate
    - paa_clusters_uncovered       → potential Section 5/6 page
    - autocomplete_expansions      → KW expansion suggestions
    - serp_feature_template_mismatch → template_id review
    - tier_reweight_proposals      → priority_score-based A/B/C adjustments
  
  refinement_scope_policy:
    ADD Layer 2 page                : ✅ free (gap-driven additions)
    SPLIT page (multi-intent PAA)   : ✅ free
    MERGE thin pages                : ⚠️ allowed if no live URL (pre-deploy)
    CUT page                        : ❌ NEVER (Layer 1 immune; Layer 2 stays unless DR-016 viability fails)
    REORDER tier A/B/C              : ✅ free (uses priority_score)
    
    flexibility_clause: operator may override on case-by-case basis with brand DR
                        (e.g., SS-DR-NNN logged in eywa-{brand}/docs/decision-records.md)
  
  process:
    1. AI generates gap-report.md
    2. Operator reviews each finding (✅/❌ per item)
    3. Sitemap delta applied (ADD-only by default, REORDER OK, MERGE conditional)
    4. Stage 1.5 Gate re-confirmed
```

#### 6. Phase F Content Production — KW Context Consumption

Content writers consume per-page KW context from `seo_x_ads_keywords_contextual_master`:

```yaml
content_brief_uses_kw_context:
  keyword_painpoint        → hook + intro section
  keyword_core_insight     → primary message + section narrative
  anxiety_level            → tone calibration (high anxiety → reassuring; low → informational)
  funnel_stage             → CTA strategy + page depth
  predicted_serp_features  → schema emit + section pattern (Featured Snippet → 40-60w direct answer)
  search_intent            → template_id confirmation (T1/T2/T6a/T7)
```

#### 7. Output File Restructure (deprecate `research-notes.md`)

Replace single dump with 5 specific files:

```
content-plan/
├── keyword-seed-list.md            (Phase B — operator)
├── competitor-scan.md              (Phase B — operator + WebSearch)
├── citation-pool-seed.md           (Phase B — existing)
├── patient-journey.md              (Phase B — operator)
├── keyword-volume-data.csv         (post-enrichment — n8n export, optional cache)
├── serp-intelligence-shortlist.md  (post-enrichment — Tier A/B only)
└── gap-report.md                   (Phase E.refine — auto-generated, operator-reviewed)
```

**Rationale:**

1. **Industry alignment:** Modern topical-authority SEO (2024-2026, post-HCU) favors brand-complete sitemaps over volume-only selection. AI search (SGE/AIO/Perplexity) reads whole-site context — missing service pages = missing context = reduced citation likelihood. Long-tail aggregation (200 pages × 10 vol = 2,000+/mo combined) often beats curated high-vol selection due to topical match.

2. **Cost efficiency:** Layered enrichment (cheap full-list volume + expensive shortlist SERP) is 30-60% cheaper than one-shot full-SERP pull. Maps directly to existing 4-table architecture which was designed for this pattern.

3. **Operator throughput:** Lean Phase B unblocks parallel work (Phase C entity / sitemap / citation / patient journey can all proceed without DFS). Refinement happens once asynchronously, not as a per-decision gate.

4. **Brand truthfulness:** Service pages exist because the brand offers the service, not because Google has volume. This serves SmileScape (specialty clinic with new/premium services like Ceramic Implant where Thai market awareness is still building) and similar mid-value vertical brands.

5. **Existing infrastructure leverage:** Supabase 4-table KW architecture + n8n workflows + Notion sync (DR-006) already built for this pattern. No schema migrations needed.

**Consequences:**

✅ **Positive:**
- Phase 1 timeline shortened (no DFS gate)
- Lower DFS cost per brand (~$0.50 vs ~$1.40 one-shot)
- Topical authority preserved (Layer 1 complete)
- Volume intelligence still consumed (Layer 2 augmentation + tier weighting + production prep)
- Content production gets richer per-page context (painpoint, anxiety, insight)

⚠️ **Trade-offs:**
- Refinement adds round-trip (Stage 1.5 → enrichment → refine → Stage 1.5 confirm)
- Operator must review gap-report.md (manual approval gate)
- SERP scrape requires manual approval (cost gate friction)

🚧 **Known limitations:**
- Bible §9.8 word-count standards still need volume for SERP-length comparison → falls in Phase F (post-Stage 1.5)
- DR-016 Page Viability §4.14 only applies to Layer 2 candidates (Layer 1 exempt) — needs Bible §4.14 amendment
- DR-018 Page Content Length Standards still applies to all pages (volume not required for Standards baseline)

**Migration Path (existing brands):**

| Brand | Stage | Action |
|-------|-------|--------|
| SmileScape | Stage 1 Phase E (414p WIP) | adopt DR-022 — current `keyword-research-dump.md` ↔ `keyword-seed-list.md`; defer DFS to Stage 1.5 background |
| VTH BioDent | Stage 1 Gate reached (Stage 1.5 blocked) | adopt DR-022 at Stage 1.5 entry — backfill split files from `research-notes.md` |
| 11 empty brands | Pre-Stage 1 | use DR-022 from inception |

**References:**

- Handover v1.8 §7.3 (Phase B restructure), §7.6.x (new Phase E.refine), §10 (Pre-Flight awareness)
- Bible Part 4 (Sitemap Architecture)
- Bible §4.14 (Page Viability — to be amended for Layer 1 exemption)
- DR-006 (Two-Phase Hierarchy Sync — Stage 1.5 dependency)
- DR-015 (Brand Scope Market Reconciliation — input to Phase B)
- DR-016 (Page Viability — applies to Layer 2 only)
- DR-018 (Page Content Length Standards — applies to all)
- DR-020 (Universal Content Templates — KW context consumption per template)
- DR-021 (Internal Linking — uses priority_score for weighting)
- Field tests: VTH BioDent (Stage 1 done) + SmileScape (`content-plan/keyword-research-dump.md`, ~680 KW × 16 clusters, commit `493a2d7`)

---

### [DR-021] — Internal Linking Architecture (HYBRID) (2026-05-10 → Locked 2026-05-12) 🔒🔗

**Status:** **Locked 2026-05-12** (early lock — paired companion lock with DR-019/020/022; operator-approved per 99.99%-Google-aligned assessment)
**Locked Bible Version:** v3.19 (Part 4 internal linking strategy + Part 13 authority signals already authoritative)
**Locked Schema Version:** v1.15 (§5.3 NEW `seo_page_internal_links` table + 12 columns added to `seo_website_page_master`)
**Bible Reference:** Part 4 (Sitemap), Part 13 (LLMO authority signals), Part 26 (Schema Pipeline)
**Schema Reference:** v1.10 → v1.15 (adds 12 columns to `seo_website_page_master` + new table `seo_page_internal_links` ~22 cols)

**Open Questions resolved at lock (per operator approval):**

1. anchor_variant_type enum: **5 values** (exact/partial/branded/generic/topical) — add 'cta' later if practice surfaces need
2. surrounding_text_snippet: **200 chars** (captures full sentence context)
3. is_reciprocal: **auto-trigger** AFTER INSERT/UPDATE via DB function
4. Status enum: **6 values** (planned/live/broken/deprecated/pending_review/archived)
5. external_url scope: **keep separate** from seo_page_citations (citations are different model; external links here = nav external only)
6. Authority Weight: **manual baseline + computed link_equity_score** (operator sets weight; system computes equity flow)
7. Crawl depth: **nightly cron** + on-demand at Stage 1.5 Gate

**Lock Audit Trail (2026-05-12):**

```yaml
field_validation:
  - "Operator Notion DB pre-EYWA precedent ('Website & SEO Page Intelligent Master') — 6 brands' worth of field-tested fields ported"
  - "Authority Weight + Link Equity Score + Orphan Risk Score = proven SEO concepts (industry consensus)"
  - "Anchor diversity tracking aligns with Google Penguin avoidance"
operator_approval:
  date: 2026-05-12
  rationale: |
    Hybrid model (page-level strategy + junction-level per-edge fidelity) is the
    only architecture that scales to 13 brands × ~500-5000 pages each. JSONB-only
    cannot support bidirectional queries at scale; junction-only loses page-level
    strategy fields. HYBRID was the considered choice from start.
follow_up_workload:
  - "Schema migration 040_dr021_add_page_linking_cols.sql (12 cols on page_master)"
  - "Schema migration 041_dr021_create_seo_page_internal_links.sql (~22 cols)"
  - "Schema migration 042_dr021_reciprocal_trigger_fn.sql"
  - "eywa-acf-fields plugin updates (~3 hours dev)"
  - "n8n flow updates (~6 hours)"
  - "Initial population per brand (~2-3 hours per brand × 13 = 26-39 hours total)"
  - "Stage 1.5 Gate validation pipeline reference seo_page_internal_links"
deferred_to_follow_up_drs:
  - "DR-028 candidate: External Authoritative Link Tracking (extend to_external_url usage)"
  - "DR-029 candidate: Anchor Diversity Algorithm (formal scoring formula)"
```

**Phase 1 Reference:** New migrations `009_add_linking_strategy_cols.sql` + `010_create_seo_page_internal_links.sql` (Phase 1A.3)
**Companion DRs:** DR-001 (Federation), DR-006 (Two-Phase Sync), DR-017 (content_brief), DR-019 (schema), DR-020 (templates)
**Trigger:** Operator review surfaced gap — current spec has implicit linking (cluster + entities + sitemap hierarchy) but no per-edge fidelity (anchor text, section context, link type)

**Context:**

```yaml
gap_in_v1_10:
  implicit_linking_only:
    - same topical_cluster_id → "related" pages
    - secondary_entities_fps[] overlap → topical
    - sitemap_node_id prefix → parent-child
  
  missing_for_production_seo:
    - Anchor text per-edge (Google ranks anchor diversity)
    - Section context (link from §7.2 ≠ link from §14)
    - Link type taxonomy (contextual / navigational / footer / breadcrumb)
    - Bidirectional consistency check (A→B planned but B↛A?)
    - Cross-brand link governance
    - Authority flow + orphan detection
    - Anchor diversity tracking

operator_notion_db_precedent:
  source: "Website & SEO Page Intelligent Master" (collection 496810b9-aac2-4409-94d0-540ae0cbdda8)
  page_level_strategy_present:
    - Authority Weight, Link Equity Score, Orphan Risk Score, Crawl Depth
    - Required Min Inbound/Outbound, Link Priority, Link Role
    - Anchor Strategy Mode, Anchor Diversity Score
    - Cross-Brand: Approved/Justification/Type/Role/Risk/Ratio
  limitation: |
    Links stored as "page-set relations" (JSON array of page URLs).
    Anchor text DERIVED via rollup from target's Target Keyword.
    Per-edge metadata (anchor variant per link, section context, link type) NOT captured.
```

**Decision (4 sub-decisions to lock together):**

1. **Enhance `seo_website_page_master` with 12 page-level linking strategy columns** (port from operator's Notion DB):
   - Authority management: `authority_weight`, `link_equity_score`, `orphan_risk_score`, `crawl_depth`, `strategic_page`, `node_tier_strategy`
   - Strategy defaults: `required_min_inbound`, `required_min_outbound`, `link_priority_default`, `link_role_default`, `anchor_strategy_mode`
   - Cross-brand: `cross_brand_approved`, `cross_brand_role`

2. **New junction table `seo_page_internal_links`** (per-edge fidelity):
   - Endpoints: `from_page_fp`, `to_page_fp`, `to_external_url`
   - Link metadata: `link_type`, `link_role`, `link_priority`
   - Anchor + context: `anchor_text`, `anchor_variant_type` (exact/partial/branded/generic/topical), `section_context`, `surrounding_text_snippet` (200 chars)
   - Lifecycle: `planned`, `implemented`, `status` (planned/live/broken/deprecated)
   - Quality: `is_reciprocal`, `is_cross_brand`, `cross_brand_justification`
   - Audit: timestamps + `first_planned_at`, `last_verified_at`

3. **Bidirectional Consistency Validation**:
   - Reciprocal detection trigger (auto-mark `is_reciprocal=true` when A→B and B→A both exist)
   - Anchor diversity warning (same anchor used >3 times for different targets → flag in editorial review)
   - Orphan detection (pages with `actual_inbound < required_min_inbound` flagged at Stage 1.5 Gate)
   - Authority depth check (Tier A pages crawl_depth ≤ 3, Tier B ≤ 4)

4. **Cross-Brand Link Governance**:
   - `is_cross_brand=true` REQUIRES `cross_brand_justification IS NOT NULL` AND `from_page.cross_brand_approved=true` (DB CHECK constraint)
   - Cross-brand role tracked: 'exporter' / 'importer' / 'balanced'
   - Editorial review (Bible Part 23.4 stage 4 brand voice) checks justification quality

**Rationale:**

- **Why HYBRID:** Page-level alone (Notion DB approach) lacks per-edge fidelity. Junction alone lacks page-level strategy fields. Both layers needed for production-grade SEO.
- **Why port from Notion DB:** Operator field-tested fields work — Authority Weight, Link Equity Score, Anchor Strategy Mode are proven SEO concepts.
- **Why junction table (not jsonb on page_master):** Bidirectional queries free with junction (`WHERE to_page_fp = X`). Per-edge metadata structured + indexable. Anchor diversity SQL aggregations possible. jsonb at scale (5K+ pages × 10+ links each = 50K+ edges) = poor performance.
- **Why now (DR-021 in current cycle):** Stage 1.5 (Handover v1.6) NEEDS internal linking storage. Without `seo_page_internal_links`, content writers cannot consult planned link strategy. Federation reuse (cross-brand link templates) requires query-able junction.
- **Why paired with DR-019/020 cycle:** Operator already in review mode 2026-06-07; bundle saves governance overhead.

**Consequences:**

- ✅ **SEO benefits:** anchor diversity per-edge (avoids Penguin penalty), link equity flow trackable, orphan detection automated, authority depth enforced, cross-brand governance prevents toxic patterns
- ✅ **Content production:** writers see explicit link instructions per section, AI/Claude queries DB for precise anchor + context, bidirectional consistency check catches drift
- ✅ **Federation:** link strategy templates reusable across brands (VTH defines OSA pattern → Deezy/VitalSleep reuse)
- ✅ **Quality automation:** Stage 1.5 Gate validates orphan + reciprocal + anchor diversity at DB level
- ⚠️ Schema v1.11 migration (~4 hours dev)
- ⚠️ ACF field group additions (~3 hours)
- ⚠️ n8n flow updates (~6 hours)
- ⚠️ Initial population per brand (~2-3 hours per brand)
- ⚠️ Total: ~15-20 hours one-time + ~2-3 hours per brand
- 🚧 Follow-up: DR-023 candidate (External Authoritative Link Tracking — extend to_external_url usage). [DR-022 claimed 2026-05-11 for Lean Phase B + Two-Layer Sitemap workflow]
- 🚧 Follow-up: DR-023 candidate (Anchor Diversity Algorithm — formal scoring formula)

**Open Questions for Review:**

1. anchor_variant_type enum scope — 5 enough or add 'cta'? *(Recommend: keep 5, add later if practice surfaces need)*
2. surrounding_text_snippet — 80 → 200 chars? *(Recommend: 200 — captures full sentence)*
3. is_reciprocal — auto-trigger or manual? *(Recommend: auto-trigger AFTER INSERT/UPDATE)*
4. Status enum — add 'pending_review'? *(Recommend: yes, for editorial workflow)*
5. external_url scope — replace seo_page_citations? *(Recommend: keep separate — citations are different model; external links here = nav external only)*
6. Authority Weight — manual vs computed? *(Recommend: manual baseline + computed link_equity_score)*
7. Crawl depth computation frequency — nightly cron acceptable? *(Recommend: yes + on-demand at Stage 1.5 Gate)*

**References:**

- DR-001 (Federation Pattern) — brand_scope foundation
- DR-006 (Two-Phase Hierarchy Sync) — informs Stage 1.5 timing
- DR-019 (Schema Strategy) — link role for AI-only schemas
- DR-020 (Universal Content Template) — Part 2 §6 Internal Link Checklist references this
- Bible Part 4.X (Sitemap Architecture)
- Bible Part 13 (LLMO authority signals)
- Schema v1.10 §5.1 — page_master expansion target
- External: Notion DB "Website & SEO Page Intelligent Master" (operator's pre-EYWA precedent — collection 496810b9-aac2-4409-94d0-540ae0cbdda8)
- Companion: `Content_Templates_EYWA_v1_0.md` — Part 2 §6 Internal Link Checklist
- Draft: `scratchpad/drafts/DR-021-internal-linking-architecture.md`

---

### [DR-020] — Universal Content Template Standard (2026-05-10 → Locked 2026-05-12) 🔒📝

**Status:** **Locked 2026-05-12** (early lock — Content_Templates v1.4 already field-active across portfolio planning; operator-approved batch lock with DR-019/021/022)
**Locked Bible Version:** v3.19 (Part 6 + Part 9 reference Content_Templates_EYWA_v1_0.md — companion file gains LOCKED status)
**Locked Companion File:** `Content_Templates_EYWA_v1_0.md` v1.5 — header status updated from "DRAFT — Proposed pending DR-020 lock" to "Locked 2026-05-12"
**Schema Reference:** v1.10 — no DDL change for v1.0 of standard; future v1.1+ may add `template_id text` + `template_version jsonb` columns to page_master
**Phase 1 Reference:** No migration required for spec lock; ACF field group updates per template (operational)
**Companion File:** `Content_Templates_EYWA_v1_0.md` (in repo root with DRAFT status header — formal lock + Bible reference upon DR-020 approval)
**Companion DRs:** DR-017 (content_brief — captures block tweaks), DR-018 (length standards — drives word count targets), DR-019 (schema strategy — defines emission purpose)

**Context:**

EYWA spec covers WHAT to build (Bible) + WHERE data lives (Schema), but lacks a UNIVERSAL standard for HOW to compose content blocks across 13 brands × 6 verticals. Real-world evidence:

```yaml
gaps_observed:
  vth_biodent:
    issue: "/mouth-biomapping/ has perfect visual EEAT but broken structured EEAT"
    cause: "AIOSEO emits author='advthdent' (admin), reviewed-by-doctor visual not in JSON-LD"
    impact: "Google sees anonymous-authored medical content (E-E-A-T weak signal)"
  
  deezy_dental:
    issue: "13 distinct page types in actual sitemap, no template framework to ensure consistency"
    types_observed:
      - Service procedure pages (Section 3, 225 pages)
      - Concern pages (Section 5, 124 pages)
      - Clinical Guide (Section 6.1, 31 pages — NEW page type, no template)
      - Glossary topical (Section 6.3, 26 pages)
      - FAQ Library (Section 6.5, 28 pages)
      - Case studies (Section 7, 56 pages)
      - Branch pages (Section 8.2, 33 pages)
      - Hyper-local programmatic (Section 9, 68+ pages — NEW, no template)
    impact: "Content writers reinvent structure per page; thin-page risk; EEAT inconsistency"

field_test_evidence:
  sample_content_doc: "ตัวอย่างเนื้อหา 355be9c6bf3c806fadabe4828a694200.md"
  observation: |
    Sleep apnea sample has 13 well-organized sections with annotations.
    Operator already has the pattern internalized — just needs codification
    + extension across content types beyond Medical Condition.
```

**Decision:**

Lock the following 4 sub-decisions together (final lock 2026-06-07):

1. **Companion File Architecture** — `Content_Templates_EYWA_v1_0.md` becomes the 3rd canonical reference alongside Bible + Schema. Bible/Schema reference it; do not duplicate content.

2. **3-Layer Composition System:**
   - **Layer 1:** ~25 Universal Section Building Blocks (atomic units, high reuse)
   - **Layer 2:** 25 Content Type Templates (12 core + 5 T2 variants + 7 specialized + 1 T6a Guide)
   - **Layer 3:** Customization Hooks (block_substitution / addition / removal / reordering with HARD RULE: never remove REQUIRED blocks)

3. **EEAT Requirement Matrix** — locked per template type (see companion file §5):
   - Medical YMYL templates (T1, T2, T2a-e, T3, T4, T6a, T7, T8, T14, T15, T17): author + medical_reviewer + last_reviewed REQUIRED
   - Conditional (T5, T6, T12): required if YMYL/medical claim
   - Not required (T9 self-EEAT, T10, T11, T13, T16, T18 page-level, T19): operational/branch-level
   - Decision rule: "If reader makes a health decision based on this page → reviewer REQUIRED"

4. **Schema Enforcement Pattern** — beyond visual EEAT, structured emission must include:
   - Article schema with `author` linked to Physician (not WP admin)
   - `reviewedBy` property explicit
   - `lastReviewed` property
   - `medicalAudience` declaration
   - Citations as schema `citation` array (not text-only)
   - Organization typed as `MedicalBusiness` (specialty subtype)

**Rationale:**

- **Why companion file (not in Bible)?** Bible is 26K lines already; templates evolve faster than philosophy; mirrors Schema_Overview pattern; easier to version/maintain.
- **Why 25 templates (not 12 or 50)?** 12 too few (misses verticals like aesthetic/wellness/genomic); 50 = overengineering. 25 derives from actual sitemap analysis (Deezy 13 page types + 6 verticals × 2-3 specialized variants each).
- **Why 3-layer composition?** Block reuse maximizes consistency without duplication. Templates are recipes; blocks are LEGO units. Layer 3 hooks allow brand identity without breaking standard.
- **Why schema enforcement beyond visual?** VTH /mouth-biomapping/ audit proves visual EEAT can be perfect while structured EEAT silently fails. Google's Medical YMYL guidelines (E-E-A-T 2026) explicitly check structured signals.
- **Why pair with DR-019?** DR-019 governs schema emission purpose (serp/ai/forbidden); DR-020 governs content composition. Together they form the complete content production stack.
- **Why no DDL for v1.0?** Existing columns (author_fp, medical_reviewer_fp, last_reviewed_at, schema_org_type, schema_markup_planned, content_brief, viability_assessment) suffice. Future template_id column can be added in v1.1 without breaking changes.

**Consequences:**

- ✅ Universal standard across 13 brands eliminates "writer reinvents structure" waste
- ✅ EEAT enforcement (visual + structured) closes the silent failure gap audited at VTH
- ✅ T18 Programmatic Local solves Deezy 68+ hyper-local pages problem (and all multi-branch brand scaling)
- ✅ T6a Guide solves "คู่มือ" search intent (31 pages in Deezy alone)
- ✅ Block-level reuse means future template additions are cheap (compose from existing blocks)
- ✅ Per-template length standards consume DR-018 §9.8 directly
- ✅ Per-template schema mappings consume DR-019 emission taxonomy directly
- ⚠️ ACF field groups need refactor (~15-20 hours dev) — one ACF group per template
- ⚠️ `eywa-schema-pipeline` plugin needs medical_reviewer_fp injection logic (~6 hours dev)
- ⚠️ Editorial workflow gains template_id selection step (Notion DB schema update)
- ⚠️ Existing pages need template_id back-fill (audit task, can be opportunistic)
- 🚧 Follow-up: separate DR-021 may add `template_id` + `template_version` columns to page_master (v1.1)
- 🚧 Follow-up: phase 2 EEAT enforcement (CHECK constraint) targeted 2026-09-01 after doctor onboarding

**Open Questions for Review (must answer before lock):**

1. Template count — 25 too many? *(Recommend: keep, each addresses real page type from sitemap analysis)*
2. T6 vs T6a Guide overlap — risk of confusion? *(Recommend: editorial reviewer makes call; border cases default to T6 lower bar)*
3. T18 Programmatic Local uniqueness enforcement — algorithmic check or manual? *(Recommend: manual v1, algorithmic v2 with cosine similarity threshold <0.7)*
4. EEAT phase 2 hard-block timing — 2026-09-01 OK? *(Prerequisite: ≥80% of brand clinic doctors registered in seo_authors)*
5. Template versioning strategy — semantic versioning vs date-stamped? *(Recommend: semver, store in page_master.template_version jsonb in v1.1)*
6. ~~Should `Content_Templates_EYWA_v1_0.md` move to repo root immediately or wait for lock?~~ **RESOLVED 2026-05-10:** placed at repo root with DRAFT status in frontmatter (gitignore excludes `drafts/` folder; root placement enables claude.ai project sync during review window).

**References:**

- Companion file: `Content_Templates_EYWA_v1_0.md` (DRAFT, 1,456 lines, 25 templates, ~25 blocks)
- DR-017 (content_brief — captures block-level tweaks at sitemap design phase)
- DR-018 (length standards — drives per-template word count targets)
- DR-019 (schema strategy — defines emission purpose for each template's schemas)
- Bible Part 6 (Citable Formulas + Perspective Layer — content philosophy that templates implement)
- Bible Part 9 (Template Anatomy + WCAG AA + §9.8 Length Standards)
- Bible Part 23.4 (Multi-Stage Editorial Review — gains template_id selection step)
- Schema v1.10 §5.1 (page_master columns: author_fp, medical_reviewer_fp, last_reviewed_at, schema_org_type, schema_markup_planned, content_brief, viability_assessment)
- Reference content sample: `/legacy/Sitemap Deezy/VTH Biodent/ตัวอย่างเนื้อหา 355be9c6bf3c806fadabe4828a694200.md`
- Live audit reference: https://www.vthbiodent.com/mouth-biomapping/ (audited 2026-05-10 — visual EEAT good, structured EEAT 6 failures)
- Sitemap gap analysis source: `/legacy/Sitemap Deezy/Deezy Dental/deezy-sitemap.md` (13 page types observed)

**Lock Audit Trail (2026-05-12):**

```yaml
field_validation:
  - "Content_Templates v1.4 already in field active use across portfolio planning"
  - "T1-T22 templates referenced by VTH BioDent, SmileScape, Trin Wellness, Classy Clinic content briefs"
  - "v1.4 added T-ADS-X family (DR-026) — T1-T22 baseline mature enough to extend"
operator_approval:
  date: 2026-05-12
  rationale: |
    Template family field-tested. Industry-validated patterns (HubSpot, Brafton,
    Whitehat consensus 2026 per Bible §3.5). Block-composition + per-template
    schema mapping + length standards are settled. Locking now seals existing
    practice; future template additions follow Section 12 governance (semantic
    versioning v1.4 → v1.5 → v2.0 path established).
follow_up_workload:
  - "Content_Templates_EYWA_v1_0.md header status: DRAFT → Locked 2026-05-12 (v1.5)"
  - "Bible Part 6 + Part 9 cross-references updated to reflect locked status"
  - "ACF field group registration per template (Phase 1F operational work)"
  - "Editorial review checklist update — template_id selection becomes mandatory step"
```

---

### [DR-019] — Schema Strategy for Post-Rich-Results Era (2026-05-10 → Locked 2026-05-12) 🔒🔬

**Status:** **Locked 2026-05-12** (early lock with **Insurance Review Clause** — operator-approved batch lock with DR-020/021/022; spec-level decisions all aligned with Google's publicly-announced position. Re-review trigger 2026-06-30 post-Google-effective-date for last-mile reconciliation.)
**Locked Bible Version:** v3.19 (Part 26 schema strategy taxonomy; Part 9 Featured Snippet pattern; Part 20 KPI metrics — all formalized at lock)
**Locked Schema Version:** v1.15 (no DDL change — strategy is spec + plugin layer)
**Insurance Review Clause:** Re-review window 2026-06-30 (post-Google-effective-date). If Google's actual behavior at June 2026 effective date contradicts DR-019 framing (FAQPage/HowTo/MedicalCondition AI consumption behavior, AggregateRating min-5 review enforcement), file Category 2 amendment per Bible §15.2.
**Open Questions resolved at lock:**

1. Plugin enforcement timing: **warn-only first 2 weeks** then escalate to hard-block
2. Existing pages cleanup: **opportunistic** (most brands don't use the 7 deprecated schemas anyway)
3. Featured Snippet pattern enforcement: **WARN v1**, BLOCK for L4/L5 only after 6 months measurement
4. AI citation tracking ETL: **accept lag** — DR specifies metric, ETL is Phase 3 task
5. `QAPage` schema for single-question Knowledge L5 pages: **YES**
6. SpeakableSpecification rollout: **only pages following Decision 2 Featured Snippet pattern**

**Bible Reference:** Part 26 (Schema Pipeline) — major refactor pending lock; Part 9 (Templates) — new Featured Snippet section pending lock; Part 20 (KPIs) — metric replacement pending lock
**Schema Reference:** v1.10 — **no DDL change** (decision is spec-level + plugin-level)
**Phase 1 Reference:** Updates `eywa-schema-pipeline` plugin emission logic (no migration)
**Companion DRs:** DR-001 (Federation — schemas inherit brand_scope), DR-011 (EUG — entity-schema discipline)
**Trigger event:** Google announcement 2026-05-07 — FAQ rich results full deprecation effective June 2026 (incl. gov/health carve-out)

**Context:**

Multi-source verification (12+ industry sources, 2026-05-10) confirms a 3-year deprecation arc completing in June 2026:

```yaml
deprecation_timeline:
  2023-08: "FAQ rich results restricted to gov/health (HowTo desktop-only)"
  2023-09: "HowTo rich results FULLY removed"
  2026-03: "7 schemas deprecated (CourseInfo, ClaimReview, EstimatedSalary, LearningVideo, SpecialAnnouncement, VehicleListing, PracticeProblem)"
  2026-03: "AggregateRating scrutiny tightened — min 5 verifiable reviews + crawler-accessible"
  2026-05-07: "FAQ rich results full kill announced (incl. gov/health carve-out)"
  2026-06: "Effective: FAQ search appearance + Rich Results Test support removed"

empirical_pivot_evidence:
  faqpage_ai_citation_rate: "67% for relevant queries"
  faqpage_in_ai_overviews: "3.2x more likely vs prose-only"
  active_consumers: [ChatGPT, Claude, Perplexity, Gemini, Google AI Overviews]
  schema_role_shift: "SERP-rendering signal → AI-extraction signal"
```

EYWA Bible v3.14 currently embeds FAQPage and HowTo across Part 6, 9, 25, 26 + L6 schema mapping. The compliance header declares "Google March 2026 Core Update aligned" but predates the 2026-05-07 announcement. Without architectural separation between SERP-purpose and AI-purpose schemas, KPIs and emission logic conflate two different value streams.

**Decision (4 sub-decisions to lock together):**

1. **Two-Purpose Schema Taxonomy** — Classify all emitted schemas into:
   - `serp_rich_result` (active SERP renderers): Product, Review, Organization, MedicalBusiness, LocalBusiness, Article, NewsArticle, BlogPosting, MedicalScholarlyArticle, BreadcrumbList, VideoObject, Person, Recipe (non-EYWA), Event (non-EYWA)
   - `ai_citation` (AI-only — emit but expect no SERP rich result): FAQPage, HowTo, MedicalCondition, MedicalProcedure, MedicalTherapy, Drug, DefinedTerm, QAPage, SpeakableSpecification
   - `forbidden` (BLOCK emission): CourseInfo, ClaimReview, EstimatedSalary, LearningVideo, SpecialAnnouncement, VehicleListing, PracticeProblem

2. **Featured Snippet Capture Pattern** (Bible Part 9 NEW sub-section) — H2/H3 = literal user question; first paragraph after H2/H3 = direct 40-60 word answer; supporting list/table below; co-emit `SpeakableSpecification`. Becomes the primary SERP-capture mechanism for question-intent queries (replacing FAQ rich result niche).

3. **KPI Replacement** (Bible Part 20):
   - DROP: `faq_rich_result_impressions`, `howto_rich_result_impressions`
   - ADD: `ai_citation_rate` (per platform: chatgpt/claude/perplexity/gemini/ai_overviews), `featured_snippet_capture_rate`, `zero_click_vs_click_ratio`
   - RETAIN: `product_review_rich_result_impressions`, `organization_knowledge_panel_presence`, `breadcrumb_rich_result_appearance`, `video_thumbnail_rich_result`

4. **AggregateRating Tightening** — `eywa-schema-pipeline` plugin enforces min 5 reviews + crawler-accessible source pre-emission; non-compliant pages emit individual `Review` schemas without `AggregateRating` wrapper.

**Rationale:**

- **Why split FAQPage/HowTo from forbidden 7?** Google explicitly says they'll continue using FAQPage/HowTo for understanding pages (just no SERP rendering). The 7 forbidden schemas have processing entirely removed. AI consumption (67% citation rate) makes continued emission high-value.
- **Why no DDL change?** Existing `schema_org_type` (text) + `schema_markup_planned` (jsonb) suffice. A `schema_emission_purpose` enum was considered but rejected — purpose is derivable from type via lookup table (no need to denormalise).
- **Why Featured Snippet now (was implicit)?** With FAQ rich results gone, Position 0 becomes the highest-value SERP capture for Q&A intent. Bible mentions Featured Snippets in passing (Part 20 KPI ~line 14416) but lacks template-level pattern enforcement.
- **Why 4-week review (until 2026-06-07)?** Google's June 2026 effective date may bring last-minute behavioural changes. Lock 1 week post-effective lets us observe actual Rich Results Test removal + page treatment behaviour.
- **Why independent of DR-013/014?** DR-013/014 = entity_relationships edge vocabulary layer. DR-019 = schema.org JSON-LD emission layer. Different files, different governance scope.

**Consequences:**

- ✅ Eliminates wasted bytes from 7 deprecated schemas (cleaner crawl budget)
- ✅ Operator/AI mental model split: "this schema = AI" vs "this schema = SERP"
- ✅ Featured Snippet capture becomes measurable, not hope-based
- ✅ AggregateRating compliance prevents future Google penalty
- ✅ KPI metrics align with reality (no more tracking dead features)
- ⚠️ Bible Part 26 needs significant restructure (~3 hours), Part 9 new sub-section (~2 hours), eywa-schema-pipeline plugin update (~4 hours dev)
- ⚠️ Existing pages with deprecated 7 schemas need cleanup audit (operator-driven, not auto-strip)
- ⚠️ Temporary inconsistency between operators following old pattern vs new (during review window)
- 🚧 Follow-up: audit 14 brand sites for 7 deprecated schemas in production
- 🚧 Follow-up: update `eywa-acf-fields` + `genesis_checklist.yaml` schema validation
- 🚧 Follow-up: consider DR-020 (AI Citation Tracking & Optimization Cycle — operationalize `ai_citation_rate` ETL)

**Open Questions for Review (must answer before lock):**

1. Plugin enforcement timing: warn-only first 2 weeks then hard-block, OR hard-block immediately? *(Recommend: warn-only 2 weeks)*
2. Existing pages cleanup priority: blocking bug / opportunistic / batch? *(Recommend: opportunistic — most brands don't use the 7 anyway)*
3. Featured Snippet pattern enforcement: WARN or BLOCK in editorial review? *(Recommend: WARN v1, BLOCK for L4/L5 only after 6 months measurement)*
4. AI citation tracking ETL: block this DR until pipeline exists, or accept lag? *(Recommend: accept lag — DR specifies metric, ETL is separate Phase 3 task)*
5. Add `QAPage` schema for single-question Knowledge L5 pages? *(Recommend: YES)*
6. SpeakableSpecification rollout: all pages or only Featured-Snippet-targeted? *(Recommend: only pages following Decision 2 pattern)*

**References:**

- Bible Part 26 (current Schema Pipeline — to be restructured post-lock)
- Bible Part 9 (Template Anatomy — to gain Featured Snippet section post-lock)
- Bible Part 20 (KPI Framework — to update metrics post-lock)
- Bible Part 23.4 (Editorial Review — to gain Featured Snippet check post-lock)
- DR-001 (Federation Pattern) — schemas inherit brand_scope[]
- DR-011 (EUG) — entity-schema linking discipline
- External: [Google Search Central blog 2023-08 (HowTo + FAQ original announcement)](https://developers.google.com/search/blog/2023/08/howto-faq-changes)
- External: Google announcement 2026-05-07 (FAQ rich results full deprecation, effective June 2026)
- External: Google March 2026 Core Update — 7 schema deprecations
- Multi-source verification 2026-05-10: Search Engine Land, Schema App, ALM Corp, Frase.io, WebFX, Engagecoders, Stanventures, Wildnet, faqjsonld.com, Leapd, Stackmatix, Over The Top SEO (12+ sources confirmed convergent narrative)
- Trigger: BIO DADDY infographic 2026-05-09 → operator request 2026-05-10 → multi-source verification → DR-019 draft

**Lock Audit Trail (2026-05-12):**

```yaml
operator_approval:
  date: 2026-05-12
  rationale: |
    99.99%-Google-aligned assessment confirmed by operator. EYWA's two-purpose
    schema taxonomy (serp_rich_result vs ai_citation vs forbidden) matches
    Google's communicated post-Rich-Results-era position. The 7 forbidden
    schemas list is final per Google's March 2026 announcement. FAQPage/HowTo/
    MedicalCondition AI consumption pattern (67% citation rate, 3.2x more
    likely in AI Overviews) is empirically observed.
  insurance_clause:
    re_review_window: 2026-06-30 (post-Google-effective-date)
    trigger: |
      If Google's actual behavior at June 2026 effective date contradicts
      DR-019 framing — file Category 2 amendment per Bible §15.2 (low cost,
      ~1 hour work).
    expected_outcome: "No amendment needed — DR-019 framing matches Google's
                       publicly-announced direction. Re-review is insurance,
                       not expected change."
follow_up_workload:
  - "Bible Part 26 schema strategy restructure (~3 hours dev)"
  - "Bible Part 9 NEW Featured Snippet sub-section (~2 hours dev)"
  - "Bible Part 20 KPI replacement (~1 hour dev)"
  - "eywa-schema-pipeline plugin update (~4 hours dev)"
  - "Audit 13 brand sites for 7 deprecated schemas in production (operator-driven, opportunistic)"
  - "Re-review check 2026-06-30 (15-minute Google effective-date verification)"
```

---

### [DR-018] — Page Content Length Standards (2026-05-10) 🆕

**Status:** Locked (operator approval 2026-05-10)  
**Bible Reference:** Part 9.8 (NEW Section — Page Content Length Standards)  
**Schema Reference:** v1.10 — no schema change (process standard)  
**Companion DRs:** DR-016 (consumes these min thresholds for thin-page detection)

**Context:**

Bible v3.13 contained scattered word count references but no comprehensive standards table:
- Line 4685: `word_count_minimum: 1500` (one context-specific mention)
- Line 10887: `ความยาว 40-50 คำ` (Speakable section guidance)
- No Layer-by-Layer table, no rationale, no exception clauses

Real impact at VTH BioDent: AI/operator designing sitemap and assessing thin-page risk had no concrete benchmarks. Pillar pages risk being under-built (1,500 vs needed 4,000+ words); service pages risk over-engineering (2,500 vs target 1,500). DR-016 thin-page detection has nothing to reference.

**Decision:**

Add comprehensive Page Content Length Standards table to Bible Part 9.8 covering all 7 Layers + 5 documented exception clauses for valid non-SEO purposes (legal, contact, intent-capture, glossary, programmatic).

Standards (key targets, full table in Bible §9.8):

| Layer | Type | Min | Target | Max |
|-------|------|-----|--------|-----|
| L1 | Home | 500 | 1,000 | 1,500 |
| L2 | Money/Service | 800 | 1,500 | 2,500 |
| L3 | Center/Hub | 1,500 | 2,500 | 4,000 |
| L4 | Concern Pillar | 2,500 | 4,000 | 6,000 |
| L5 | Knowledge | 2,000 | 3,500 | 5,000 |
| L6 | Local | 600 | 1,200 | 2,000 |
| L7 | Case Study | 1,500 | 2,500 | 4,000 |

Multilingual adjustment: Thai/Chinese -20% (denser per character).

**Rationale:**

- Concrete benchmarks unblock DR-016 (viability assessment needs numbers)
- Layer-specific (Home ≠ Pillar; intent and value-of-length curve differ)
- Industry-grounded (Backlinko, Ahrefs, HubSpot 2020-2024 studies)
- Exception clauses preserve flexibility — 5 documented patterns for valid thin pages
- Pillar exception explicitly forbidden (L4/L5 must be exhaustive — SEO authority)
- Annual review cadence (algorithm landscape shifts)

**Consequences:**

- ✅ DR-016 has concrete thresholds to enforce
- ✅ Editorial review (Bible Part 23.4 Stage 2) gets clear pass/fail criteria
- ✅ Cross-brand consistency (every brand uses same standards)
- ⚠️ Numbers may need adjustment (per-vertical refinement future)
- ⚠️ Risk: writers focus on count not quality — mitigated by editorial review
- 🚧 Follow-up: yearly review at Schema Review Board cadence

**Implementation:**

- Bible Part 9.8 (NEW): full standards table + 5 exception clauses + industry rationale
- Schema v1.10: no DDL change required for DR-018 itself — standards are spec-level reference; runtime enforcement via `viability_assessment` (DR-016) audit trail and editorial review (Bible Part 23.4)
- Editorial workflow: Stage 2 review uses targets as benchmarks
- Brand application: per-brand may add vertical-specific refinements via DR

**References:**

- DR-016 (Thin Page Detection) — primary consumer of these thresholds
- DR-017 (Content Brief) — brief shapes coverage to hit these standards
- Bible Part 6 (Content Standard) — quality companion
- Bible Part 23.4 (Editorial Review) — validation phase
- Industry: Backlinko ranking factor studies, Ahrefs content depth research, HubSpot pillar page methodology, Google Helpful Content Update

---

### [DR-017] — Page Content Brief Field (2026-05-10) 🆕

**Status:** Locked (operator approval 2026-05-10)  
**Bible Reference:** Part 5 §5.1 — page_master spec update  
**Schema Reference:** v1.10 §5.1 — adds `content_brief text` column  
**Phase 1 Reference:** New migration `007_add_content_brief.sql`

**Context:**

Two related problems from VTH BioDent field test:

1. **Lost context after page collapse (DR-016 outcome):** When sitemap design collapses children into parent (e.g., 3.1.1-3 → merged into 3.1), the conceptual structure that informed the design is lost. Content writer (weeks/months later, possibly different person/AI) sees only the parent name with no hint of original coverage plan.

2. **Even non-collapsed pages benefit from upfront briefs:** Sitemap design captures the WHY of a page existing. By content creation phase, original framing forgotten, strategic positioning unclear, internal link planning hints missing.

Currently no structured place to store "what this page should cover."

**Decision:**

Add column `content_brief text NULL` to `seo_website_page_master`:
- **REQUIRED** for collapsed pages (parent absorbs children's outlines)
- **RECOMMENDED** for all standalone pages (operator best practice)
- Free-text format: 2-5 sentences or bullet list capturing planned coverage, key topics, internal link targets, distinctive angle
- Programmatic Type C pages: reference template (no free-text)

**Rationale:**

- Text format > jsonb (easier to read/write, AI/Notion render natively, free-form > structured)
- Optional but recommended (backwards compatible, doesn't block existing workflows)
- Required only when needed (collapsed pages — can't lose context)
- Same column instead of separate table (1:1 relationship, no JOIN cost)
- Phase 1A inclusion (cheap addition ~30 min effort, critical pairing with DR-016)

**Consequences:**

- ✅ Context preserved across time, writers, AI sessions
- ✅ Required for collapsed pages → no lost outlines
- ✅ Onboarding aid for new writers
- ✅ AI uses brief when generating content (better outputs)
- ✅ Audit trail of editorial intent
- ⚠️ Adds ~5 min per page during sitemap design
- ⚠️ Risk: writer ignores brief (mitigation: editorial review checks alignment)

**Implementation:**

- Schema v1.10 §5.1: ADD column `content_brief text NULL`
- Phase 1A migration `007_add_content_brief.sql` (independent of DR-013/014)
- Bible Part 4 Phase 4.5 (NEW step): Content Brief Drafting in sitemap design workflow
- Notion: add property "Content Brief" (long text, bidirectional sync)
- WordPress: add ACF field `content_brief` (textarea) in eywa-acf-fields plugin

**References:**

- DR-011 (EUG) — quality gate pattern
- DR-016 (Thin Page Detection) — primary consumer
- DR-018 (Word Count Standards) — brief shapes coverage to hit standards
- Bible Part 5 (Database Schema) — table this column joins
- Bible Part 23.4 (Editorial Review) — validation phase

---

### [DR-016] — Thin Page Risk Detection (Sitemap Quality Gate) (2026-05-10) 🆕

**Status:** Locked (operator approval 2026-05-10)  
**Bible Reference:** Part 4.14 (NEW Section — Page Viability Assessment)  
**Schema Reference:** v1.10 §5.1 — adds optional `viability_assessment jsonb` column  
**Companion DRs:** DR-017 (preserves collapsed page context), DR-018 (provides word count thresholds)

**Context:**

Current EGP + sitemap design produces hierarchical structures where children pages can end up as thin content. VTH BioDent example:

```
3.1 Mouth BioMapping
├── 3.1.1 หลักการ (~300 words predicted)
├── 3.1.2 วิธีตรวจ (~400 words)
└── 3.1.3 ใครเหมาะ (~250 words)
```

Each child individually too narrow to support standalone page → SEO penalty risk. Better outcome: collapse children into parent, create rich 2,500-word page covering all sub-topics.

Bible v3.13 had no comprehensive thin-page risk framework. No criteria, no decision matrix, no exceptions.

**Decision:**

Add **"Page Viability Assessment"** quality gate in sitemap design (new Phase 4.5, between Phase 4 Page-Level Tagging and Phase 5 Connection Audit).

**4 Criteria per page:**
1. Predicted Content Volume (vs DR-018 Layer minimum)
2. Search Volume (≥ 100/mo Thai, ≥ 50/mo English niche)
3. Topic Distinctness (< 30% overlap with parent)
4. User Intent Distinctness (different intent type or sub-intent)

**Decision Matrix:**
- All 4 PASS → Standalone
- 1-2 WARN → Standalone with watch flag
- 3-4 WARN or 1 FAIL → Human review
- 2+ FAIL → COLLAPSE into parent (preserve content_brief per DR-017)

**Exception Clauses (5 patterns where thin pages are valid):**
1. Legal/Required pages (privacy, terms — 300-1,000 words)
2. Contact/Location pages (300-800, schema compensates)
3. Intent-capture pages (500-1,000, commercial intent + CTA)
4. Disambiguation/Glossary hubs (200-600, heavy cross-linking)
5. Programmatic pages Type C (600-1,200 per template)

**Pillars NEVER allowed thin** (L4/L5 — SEO authority pages have no exception).

**Rationale:**

- Word count proxy for "did we have enough valuable to share?" (industry-validated)
- 4 criteria orthogonal — different dimensions of viability
- Exception framework prevents tyranny — 5 valid non-SEO patterns documented
- Pre-lock quality gate (catch before publish, not after)
- Pairs with EUG (DR-011) — both quality gates pre-finalize

**Consequences:**

- ✅ Prevents thin-page SEO penalties before publish
- ✅ Forces deliberate page existence justification
- ✅ Acknowledges valid non-SEO reasons (5 exceptions)
- ✅ Audit trail (assessment stored optionally)
- ⚠️ Adds ~10 min per page during sitemap design
- ⚠️ Requires DataForSEO query for criterion 2

**Implementation:**

- Bible Part 4.14 (NEW): full assessment framework + decision matrix + exceptions
- Bible Part 4 Phase 4.5: viability assessment as quality gate before sitemap lock
- Schema v1.10 §5.1: optional column `viability_assessment jsonb` (audit trail)
- Handover §7: workflow step added between EGP and sitemap lock

**References:**

- DR-011 (EUG) — pre-lock quality gate pattern
- DR-017 (Content Brief) — preserves context when pages collapse
- DR-018 (Word Count Standards) — provides Layer minimums (Criterion 1)
- Bible Part 3.5 (Cannibalization Shield) — related concern
- Bible Part 4.5 (Page Type Matrix) — Type C programmatic exception
- Industry: Google Helpful Content Update (Aug 2022, ongoing)

---

### [DR-015] — Brand Scope Market Reconciliation Pattern (2026-05-10) 🆕

**Status:** Locked (operator approval 2026-05-10)  
**Bible Reference:** Part 4.13 (NEW Section — Market Reality Reconciliation)  
**Schema Reference:** v1.10 §5.1 — adds `marketplace_proposal_status text` column  
**Phase 1 Reference:** New migration `008_add_marketplace_reconciliation.sql`

**Context:**

EYWA's strict `brand_scope` discipline (DR-001 + DR-010) successfully prevents brand drift, but real-world testing on VTH BioDent revealed an over-correction:

> AI สร้าง sitemap ที่ไม่มีบริการทันตกรรมพื้นฐาน (อุดฟัน/ขูดหินปูน/ถอนฟัน) เพราะ brand concept ของ VTH BioDent คือ "premium integrative dental + biological mapping". Strict brand_scope ตัดบริการเหล่านี้ออก — แต่ในชีวิตจริง dental clinic ขาดไม่ได้.

Protection too strict — blocks services that:
1. Are real-world necessities for the clinic to function
2. Have legitimate search demand (real Thai search volume)
3. Could fit brand concept WITH repackaging (e.g., "Comprehensive Dental Wellness Center" instead of "General Dentistry")

AI is "too obedient" — protects brand integrity at cost of business reality.

**Decision:**

Adopt **"Market Reality Reconciliation"** — OPTIONAL second pass that runs AFTER strict EGP completes.

**3-Step Process:**
1. Strict EGP runs as normal (current behavior)
2. Reconciliation pass: AI explores vertical-standard services NOT in current brand_scope, scores each:
   - **Necessity Score (1-5):** how essential for vertical to function
   - **Brand-Fit:** Direct / Repackageable / Forced (reject)
   - **SEO Opportunity:** search volume + intent + competition
3. Output to operator review (NOT auto-applied):
   - Status: `proposed` → operator approves/rejects/defers
   - Approved items get `accepted_repackaged` with new positioning name

**When to run:**
- Healthcare brands: MANDATORY (clinical reality)
- Wellness brands: RECOMMENDED
- Media brands: OPTIONAL

**Rationale:**

- Pattern matches DR-012 philosophy: strict default + governed exceptions
- Discussion list (not auto-add) → forces conscious brand decisions
- Repackaging requires human creativity (naming, positioning)
- 3-axis scoring lets different verticals optimize differently
- Audit trail per service decision

**Consequences:**

- ✅ Healthcare brands unblocked — can offer general dentistry under "Wellness Center"
- ✅ AI more useful (proposes, doesn't just block)
- ✅ Brand discipline preserved (operator approval required)
- ✅ Cross-brand applicable (every healthcare brand faces this)
- ⚠️ Adds ~15 min per brand reconciliation pass
- ⚠️ Operator must judge repackaging wisely (could over-extend brand)

**Implementation:**

- Bible Part 4.13 (NEW): Market Reconciliation Phase + 3-criteria scoring + decision tree
- Schema v1.10 §5.1: ADD column `marketplace_proposal_status` with CHECK constraint (`in_scope` / `proposed` / `accepted_repackaged` / `rejected` / `deferred`)
- Schema v1.10 §5.1: ADD column `reconciliation_notes text` (operator's repackaging notes)
- Phase 1A migration `008_add_marketplace_reconciliation.sql`
- Handover §7: Reconciliation phase in per-brand workflow checklist

**Test Cases (VTH BioDent):**

```yaml
general_dentistry:
  blocked: ["อุดฟัน", "ขูดหินปูน", "ถอนฟัน"]
  necessity: 5/5, fit: REPACKAGEABLE, seo: HIGH (~22K-33K/mo)
  decision: ACCEPT — "Comprehensive Dental Wellness Center"

cosmetic_dentistry:
  blocked: ["ฟอกสีฟัน", "วีเนียร์"]
  necessity: 3/5, fit: REPACKAGEABLE, seo: VERY HIGH (~33K/mo)
  decision: ACCEPT — "Aesthetic Smile Refinement"

emergency_dental:
  blocked: ["ปวดฟันกะทันหัน"]
  necessity: 4/5, fit: PARTIAL, seo: MEDIUM
  decision: DEFER — discuss positioning
```

**References:**

- DR-001 (Multi-Brand Federation) — established brand_scope[]
- DR-010 (Brand Scope Architecture) — locked brand_slug
- DR-012 (Edge Vocabulary Evolution) — pattern for governed expansion
- DR-016 (Thin Page Detection) — viability check follows reconciliation
- Bible Part 2.6 (EGP) — strict process this complements
- Bible Part 14 (Vertical Profiles) — vertical reality definitions

---

### [DR-014] — Concept Entity Subtype Lock (framework + axis) (2026-05-09 → Locked 2026-05-12) 🔒💠

**Status:** **Locked 2026-05-12** (paired companion lock with DR-013; cross-brand evidence ≥5 medical brands)  
**Locked Bible Version:** v3.18 (Part §2.6.10 NEW — Concept Entity Subtype Controlled Vocabulary)  
**Locked Schema Version:** v1.14 (§4.1 seo_entity_graph — CHECK chk_concept_subtype)  
**Bible Reference:** v3.18 §2.6.10 (entity_subtype controlled vocabulary for concept type)  
**Schema Reference:** v1.14 §4.1 (CHECK constraint on entity_subtype for concept type)  
**Companion DR:** DR-013 (Edge Vocabulary v3.5 Expansion — Locked 2026-05-12)

**Context:**

Per Stream B work order (2026-05-09) — field-tested feedback from VTH BioDent EGP work surfaced gap:

When entities of `entity_type='concept'` represent **integrative methodologies or causal dimensions** (e.g., VTH BioDent's "Mouth Bio Mapping" framework, "neuroimmune axis" concepts), existing `entity_subtype` field has no controlled vocabulary. This leads to:

- Inconsistent labeling (`'methodology'` vs `'paradigm'` vs `'system'` for same concept)
- Schema markup ambiguity (no `additionalType` value to emit)
- Cluster organization confusion (when should subtype matter?)

**Proposed Decision:**

Lock 2 controlled vocabulary values for `concept` entity_subtype:

```yaml
proposed_subtype_values:
  
  framework:
    description: "Overarching methodology / paradigm that organizes other concepts"
    examples:
      - VTH BioDent: "pncl-medicine" (Personalized Neural-Cognitive Lifestyle Medicine)
      - Healthcare general: "integrative-medicine", "functional-medicine"
    schema_org_emission: 'additionalType="ClinicalFramework"'
    cluster_role: "Often parent_of multiple axes/clusters"
  
  axis:
    description: "Causal/relational dimension across systems (e.g., 'gut-brain axis')"
    examples:
      - VTH BioDent: "bjgml-axis" (Bio-Joint-Gut-Mouth-Lung axis)
      - Healthcare general: "gut-brain-axis", "hpa-axis"
    schema_org_emission: 'additionalType="BiologicalAxis"'
    cluster_role: "part_of frameworks, contains member entities"

  general (default fallback):
    description: "Concept that is neither framework nor axis"
    use_when: "Concept is a single idea/principle, not organizing structure"
    backward_compat: "Existing concept entities default here on migration"
```

**Required Verification (per DR-012 governance):**

| Criterion | Status | Notes |
|-----------|--------|-------|
| C1: ≥3 real cases | ⏳ Collection | VTH BioDent has 2 examples; need 1+ more |
| C2: Cross-brand applicability | ⏳ Pending canvass | Other brands may have implicit frameworks |
| C3: Schema.org mapping | ✅ Documented | additionalType="ClinicalFramework"/"BiologicalAxis" |
| C4: Orthogonal | ✅ Architect verified | No existing entity_subtype value covers this |

**Rationale:**

✅ **Improves schema markup precision:**
- Without lock: concept entities emit generic `schema:DefinedTerm`
- With lock: framework concepts emit `additionalType="ClinicalFramework"` (richer for AI engines)

✅ **Improves cluster organization:**
- Framework concepts naturally become parent_of axes
- Axes naturally contain member entities via `part_of` edge
- Tree structure becomes self-documenting

✅ **Brand IP protection:**
- VTH BioDent's "Mouth Bio Mapping" framework gets proper schema markup as branded methodology
- Differentiates from generic concepts in AI search results

⚠️ **Backward compatibility considerations:**
- Existing concept entities have `entity_subtype` either NULL or arbitrary text
- Migration approach: allow NULL (don't force categorization)
- Only NEW concept entities at framework/axis level required to declare subtype

**Alternatives Rejected:**

- **A. No controlled vocabulary:** ❌ Inconsistent labeling, no schema markup benefit
- **B. Free-text entity_subtype:** ❌ Loses governance, fragments ontology
- **C. New entity_type values (e.g., 'framework' as type):** ❌ Breaks 15-type master list (Bible Part 2.5)

**Implementation Plan (if Locked 2026-05-20):**

```yaml
phase_1B_addition:
  migration_file: "20260520_053_add_concept_subtype_check_constraint.sql"
  
  ddl_change:
    table: seo_entity_graph
    constraint: |
      CHECK (
        entity_type != 'concept' 
        OR entity_subtype IS NULL 
        OR entity_subtype IN ('framework', 'axis', 'general')
      )
  
  backward_compat: "Allows NULL — does not force migration of existing concept entities"
  estimated_runtime: "< 1 minute"
  rollback: "DROP CONSTRAINT chk_concept_subtype"
```

**Consequences:**

✅ **Positive:**
- Schema markup richer for branded frameworks
- Cluster hierarchies become explicit
- Editorial team has clear "which subtype?" guidance for concept entities
- Backward compatible (NULL allowed)

⚠️ **Trade-offs:**
- DR-013 dependency: contraindicates/causes edges work better with framework/axis labeling
- Editorial training needed: "When should I declare framework vs axis vs general?"

**References:**
- Stream B work order (2026-05-09)
- DR-013 (companion — Edge Vocabulary v3.5 Expansion — Locked 2026-05-12)
- DR-012 (governance: 4 criteria + 2-week review)
- Bible v3.18 §2.5 (Entity Polymorphism — 15 entity_types)
- Bible v3.18 §2.6 (Entity Genesis Protocol — subtype population)
- Bible v3.18 §2.6.10 NEW (Concept Entity Subtype Controlled Vocabulary — full spec)
- Schema v1.14 §4.1 (entity_graph entity_subtype field + chk_concept_subtype CHECK constraint)

**Audit Trail:**

```yaml
proposal_history:
  
  2026_05_09:
    event: "DR-014 set to Proposed alongside DR-013 (Stream B work order)"
    next_action: "Cross-brand canvass for C2 evidence by 2026-05-13"
  
  2026_05_12_lock:
    event: "Operator-approved early lock — paired companion lock with DR-013; cross-brand evidence threshold exceeded"
    cross_brand_framework_evidence:
      - "VTH BioDent: pncl-medicine, mouth-bio-mapping"
      - "VTH Biodental Wellness: biodental-longevity-protocol, ceramic-first-implant-pathway, smart-plus, oral-inflammation-index"
      - "Trin Wellness: root-cause-medicine"
      - "Classy Clinic: classy-design-protocol, classy-face-blueprint"
      - "Relaxia Dental: fear-free-sleep-dentistry"
    cross_brand_axis_evidence:
      - "VTH BioDent: bjgml-axis (Bio-Joint-Gut-Mouth-Lung)"
      - "VTH Biodental Wellness: oral-systemic-axis"
      - "Trin Wellness: vascular-sexual-axis (DR-TW-004 pillar), hpg-axis (hormone cascade)"
      - "Future Vital Mind/Sleep brands: gut-brain-axis, neuroinflammation-axis"
    verification:
      C1_three_real_cases: "✅ Passed — ≥10 framework cases + ≥6 axis cases documented"
      C2_cross_brand: "✅ Passed — applies to ≥5 medical brands"
      C3_schema_mapping: "✅ Passed — additionalType=ClinicalFramework + BiologicalAxis"
      C4_orthogonal: "✅ Passed — no existing entity_subtype value covers organizational concepts"
    actor: Naphannop S. (operator approval)
    artifact_updated:
      - DECISION_RECORDS.md v1.11 → v1.12
      - EYWA_PROTOCOL Bible v3.17 → v3.18 (NEW §2.6.10)
      - Schema_Overview v1.13 → v1.14 (§4.1 chk_concept_subtype CHECK)
      - EYWA_HANDOVER v1.11 → v1.12
    deferred_to_operator_workload:
      - "Phase 1B migration 034_dr014_add_concept_subtype_check.sql"
      - "eywa-schema-pipeline plugin updates (emission rules per subtype)"
      - "eywa-acf-fields radio control (framework/axis/general) for concept entities"
      - "Audit query run to flag pre-v1.14 concept rows with non-standard entity_subtype values"
```

---

### [DR-013] — Edge Vocabulary v3.5 Expansion (causes + contraindicates) (2026-05-09 → Locked 2026-05-12) 🔒🧬

**Status:** **Locked 2026-05-12** (early lock — cross-brand evidence threshold exceeded; canvass deadline of 2026-05-13 surfaced ≥5 brand applications)  
**Locked Bible Version:** v3.17 (Part 2.7.2 vocabulary, 2.7.3 CHECK enum, 2.7.4 edge specs, 2.7.5 rules 8+9, 2.7.11 NEW typed edge_note sub-vocabulary)  
**Locked Schema Version:** v1.13 (§4.5 seo_entity_relationships — CHECK 14→16 enum + 3 new columns + 2 trigger functions)  
**Bible Reference:** Future v3.14 §2.7.2 (vocabulary expansion 10→12 edges) + §2.7.6 (typed edge_note sub-vocabulary)  
**Schema Reference:** Future v1.10 §4.5 (seo_entity_relationships CHECK constraint expansion + new fields)  
**Companion DR:** DR-014 (Concept Entity Subtype Lock)  

**Context:**

Per Stream B work order (2026-05-09) — field-tested feedback from VTH BioDent EGP work surfaced 2 vocabulary gaps:

**Gap 1 — Etiological relationships (causes):**
At Phase D (sitemap + content) work for VTH BioDent, encountered need to express "X causes Y" (e.g., "bruxism causes TMJ disorder"). Existing edges insufficient:
- `treats` = wrong direction (therapeutic, not etiological)
- `symptom_of` = wrong abstraction (manifestation marker, not origin)
- `related_to + notes` = loses directional + mechanistic signal + schema:causeOf SEO benefit

**Gap 2 — Safety conflicts (contraindicates):**
Procedure entities (e.g., "dental implant surgery") need to declare drug/condition contraindications. Existing edges insufficient:
- `alternative_to` = preference choice, not safety hard block
- `related_to + notes` = loses schema:contraindication SEO + queryable safety semantics

**Proposed Decision:**

Add 2 new edges to vocabulary (10 → 12 edges):

```yaml
new_edge_11_causes_caused_by:
  paired: yes (directional)
  edge_type_values: ['causes', 'caused_by']
  schema_org_mapping:
    causes: "schema:causeOf"
    caused_by: "schema:riskFactor (semantic inverse)"
  semantics: "Etiological — entity X creates/contributes-to condition Y"
  bible_section_for_full_spec: "v3.14 §2.7.2"

new_edge_12_contraindicates:
  paired: no (symmetric, undirected)
  edge_type_values: ['contraindicates']
  schema_org_mapping:
    contraindicates: "schema:contraindication"
  semantics: "Safety — entity X must not be combined with entity Y"
  bible_section_for_full_spec: "v3.14 §2.7.2"
  governance_addition: 
    - "edge_evidence_citation MANDATORY for strength≥2"
    - "medical_reviewer_signoff_at MANDATORY for strength=3 (absolute)"
```

**Typed edge_note Sub-Vocabulary (NEW concept per work order):**

Currently `edge_note` is free-text (ad-hoc). Stream B proposes formalizing per-edge-type controlled values:

```yaml
edge_note_typed_examples:
  
  causes:
    direct: "X is direct mechanistic cause"
    contributing: "X is one of multiple causes"
    developmental: "X causes Y over time/development"
    hypothesized: "Causal link proposed but not proven (strength=1 mandatory)"
  
  contraindicates:
    absolute: "Must never combine (strength=3, requires medical signoff)"
    relative-controllable: "Can combine with monitoring (strength=2)"
    relative-temporal: "Time-based contraindication (e.g., post-surgery window)"
    interferes-outcome: "Reduces efficacy without safety risk"
  
  related_to:
    comorbidity: "Frequently co-occur (deferred co_occurs_with edge candidate)"
    bidirectional-influence: "Mutual reinforcement"
    historical-association: "Documented but mechanism unclear"
  
  requires_assessment:
    diagnostic-gold-standard: "Primary diagnostic test"
    diagnostic-supportive: "Supporting test"
    pre-procedure-required: "Mandatory before procedure"

governance_for_edge_note:
  - "Adding new edge_note value = Category 2 change (lighter than new edge)"
  - "Schema pipeline emits different schema.org based on edge_note (e.g., diagnostic-gold-standard → primaryDiagnosis)"
```

**Required Verification (per DR-012 governance):**

| Criterion | Status | Notes |
|-----------|--------|-------|
| **C1: ≥3 real cases** | ⏳ In Collection | VTH BioDent has multiple cases; collected in Notion governance database |
| **C2: Cross-brand applicability (≥2 brands)** | ⏳ **PENDING** | Architect canvasses 14 other brands by 2026-05-13. Critical blocker. |
| **C3: Schema.org mapping** | ✅ Documented | causeOf, riskFactor, contraindication all in schema.org |
| **C4: Orthogonal to existing 10** | ✅ Architect verified | causes ≠ treats; contraindicates ≠ alternative_to. Awaits board signoff. |

**Critical Path:**
- C2 (cross-brand) is the **primary risk**. If only VTH BioDent has cases → DR-013 should reject + use brand_scope workaround
- Notion governance database tracks evidence collection structurally

**Rationale:**

✅ **Field-tested origin (not speculative):**
- Stream B emerged from real VTH BioDent EGP work, not hypothetical scenarios
- Naphannop (VTH BioDent founder) identified gap during actual entity creation

✅ **Schema.org alignment strengthens AI citation:**
- `schema:causeOf` and `schema:contraindication` are well-established medical schema properties
- Google Health Knowledge Panel + AI engines weight these heavily for medical content
- Without these edges, JSON-LD emission misses high-value markup

✅ **Patient safety semantics (contraindicates):**
- Healthcare brands NEED ability to express "do not combine"
- Workaround via `alternative_to + notes` loses critical safety signal
- DR-008 Two-Column Identity already established medical-grade governance posture

✅ **Brand IP differentiation (when paired with DR-014):**
- Framework + axis concepts can have explicit causal chains
- VTH BioDent's "Mouth Bio Mapping" methodology gets richer schema markup

✅ **Governance test case for DR-012:**
- DR-013 is the FIRST proposed addition under DR-012's 4-criteria + 2-week review process
- Outcome (Lock or Reject) sets precedent for future edge proposals
- Either decision validates that DR-012 governance works

**Alternatives Rejected:**

- **A. Use `related_to + notes` as catch-all:**
  - ❌ Loses schema:causeOf / schema:contraindication SEO benefit
  - ❌ Loses queryable semantics (can't filter "all causal chains for X" or "all contraindications for procedure Y")
  - ❌ Loses governance enforcement (edge_evidence_citation mandatory for safety-critical edges)
  - ⚠️ Acceptable as workaround if DR-013 rejected (single-brand pattern)

- **B. JSONB-only storage (no edge_type expansion):**
  - ❌ Schema generation pipeline can't emit proper JSON-LD
  - ❌ Loses CHECK constraint enforcement
  - ❌ Cross-brand inconsistency

- **C. Brand-specific edge extensions:**
  - ❌ Fragments ontology across brands (against DR-001 Federation Pattern)
  - ❌ Cross-brand schema markup becomes inconsistent
  - ❌ Editorial team confused which edges apply when

**Consequences (if Locked):**

✅ **Positive:**
- Vocabulary 10 → 12 edges
- Schema markup richer for healthcare brands
- Patient safety queries possible (find all contraindications for procedure X)
- Causal chain visualization in knowledge graph
- Brand IP (frameworks) gets proper schema:additionalType emission

⚠️ **Operational requirements:**
- 5 SQL migrations (Phase 1E)
- eywa-schema-pipeline plugin updates (~16-20h dev)
- eywa-acf-fields field group updates (~3h)
- relationships.md template updates
- genesis_checklist.yaml validation rules
- n8n classifier updates (test 6 active workflows)
- Notion select options sync

⚠️ **Schema Review Board approval required:**
- Category 3 (Major) change per Bible §15.2
- Medical reviewer signoff required for contraindicates strength=3 cases

⚠️ **Effort estimate:** ~58-64 hours total (Architect + Tech Lead) per Stream B work order

**Consequences (if Rejected):**

⚠️ **Workaround pattern:**
- VTH BioDent uses `related_to + notes` with `brand_scope=['vth-biodent']`
- Schema pipeline custom Layer 3 handler emits `schema:relatedCondition` (less specific than causeOf)
- For contraindicates: use `alternative_to + notes='safety-critical'` with custom schema additionalType
- Reduced SEO benefit but functional

✅ **Positive of rejection:**
- DR-012 governance proven to work (catches single-brand premature additions)
- VTH BioDent unblocked within hours
- Future cross-brand cases can re-trigger DR-013 with stronger evidence

**Implementation Plan (if Locked 2026-05-20):**

Per Stream B work order — Phase 1E migrations:

```yaml
phase_1E_migrations:
  20260520_050_extend_edge_type_check_constraint.sql:
    action: "ALTER seo_entity_relationships CHECK constraint to 16 enum values"
    breaking: no (additive)
  
  20260520_051_add_edge_evidence_citation_field.sql:
    action: "ADD edge_evidence_citation text NULL FK to seo_citations"
    breaking: no (additive)
  
  20260520_052_add_medical_reviewer_signoff_fields.sql:
    action: "ADD medical_reviewer_signoff_at timestamptz + medical_reviewer_fp text"
    breaking: no (additive)
  
  20260520_053_add_concept_subtype_check_constraint.sql:
    action: "ADD CHECK constraint for entity_subtype on concept type"
    breaking: no (companion to DR-014, NULL-allowed)
  
  20260520_054_add_edge_validation_triggers.sql:
    action: "Trigger functions for evidence + signoff enforcement"
    breaking: no
```

**Bible v3.14 Updates Planned:**

```yaml
bible_v3_14_sections_to_update:
  
  section_2_7_2:
    change: "Master vocabulary 10 → 12 edges"
    callout: "v3.5 expansion rationale → see DR-013"
    callout: "deferred co_occurs_with → see DR-013 future amendment"
  
  section_2_7_3:
    change: "Storage Pattern CHECK constraint 14 → 16 enum values"
  
  section_2_7_4:
    change: "Decision flow precedence — causes/contraindicates inserted at correct positions"
  
  section_2_7_5_now_2_7_5_extended:
    add_rules:
      - "causes edge requires evidence_citation if strength≥2"
      - "contraindicates edge requires evidence_citation if strength≥2"
      - "contraindicates strength=3 requires medical reviewer signoff"
  
  section_2_7_6_NEW:
    title: "Edge Note Typed Sub-Vocabulary"
    content: "Per-edge allowed edge_note values + schema.org emission rules"
  
  section_2_6:
    add: "entity_subtype controlled vocabulary for concept type (per DR-014)"
  
  section_2_6_2:
    update: "Step 4 — Procedures with safety concerns must have ≥1 contraindicates edge"
  
  section_27_3_1:
    update: "edge_strength formula — typed edge_note multiplier"
```

**Schema v1.10 Updates Planned:**

```yaml
schema_v1_10_changes:
  
  section_4_5_seo_entity_relationships:
    add_fields:
      - edge_evidence_citation text NULL (FK to seo_citations.fingerprint)
      - medical_reviewer_signoff_at timestamptz NULL
      - medical_reviewer_fp text NULL (FK to seo_authors.fingerprint)
    expand_check_constraint: 16 enum values
  
  section_4_2_seo_entity_graph:
    add_check_constraint: "Concept entity_subtype IN (NULL, 'framework', 'axis', 'general')"
  
  appendix_F_helper_functions:
    add_functions:
      - fn_validate_edge_evidence_requirement()
      - fn_validate_medical_signoff_for_contraindication()
      - fn_emit_schema_org_per_edge_note()
```

**References:**
- Stream B work order (2026-05-09 — "EYWA v3.4 → v3.5 Documentation Update Checklist")
- DR-014 (companion — Concept Entity Subtype Lock)
- DR-012 (governance — 4 criteria + 2-week review)
- DR-008 (Two-Column Identity Pattern — preserved during v3.5)
- DR-001 (Federation Pattern — cross-brand impact)
- Bible v3.13 §2.7 (current 10-edge vocabulary)
- Schema v1.9 §4.5 (seo_entity_relationships)
- Naphannop S. (VTH BioDent founder, original proposer)

**Audit Trail:**

```yaml
proposal_history:
  
  2026_05_09_AM:
    event: "VTH BioDent Phase D EGP work surfaced gap"
    actor: Naphannop S.
    outcome: "Stream B work order drafted"
  
  2026_05_09_PM:
    event: "Cross-checked with Stream A (DR-011 + DR-012 just locked)"
    discovery: "DR number collision + version collision"
    resolution: "Rename Stream B → DR-013/014, target v3.14/v1.10"
  
  2026_05_09_late:
    event: "DR-013 + DR-014 set to Proposed status"
    artifact_created:
      - DECISION_RECORDS.md v1.3
      - EYWA_HANDOVER.md v1.5
    next_action: "Architect canvasses 14 brands for C2 cross-brand evidence by 2026-05-13"
  
  2026_05_12_lock:
    event: "Operator-approved early lock — C2 cross-brand evidence exceeded threshold"
    cross_brand_evidence_captured:
      - "Trin Wellness (DR-TW-004): Atherosclerosis → causes → ED (strength=3, AHA/AUA guideline)"
      - "Trin Wellness: TRT ↔ contraindicates ↔ Prostate cancer history (absolute, strength=3)"
      - "VTH Biodental Wellness: Periodontal disease → causes → Systemic inflammation (developmental, strength=2)"
      - "VTH BioDent: Bruxism → causes → TMJ disorder (direct, strength=2 — original Stream B case)"
      - "SmileScape: Dental implant surgery ↔ contraindicates ↔ Bisphosphonate therapy (relative-controllable, strength=2)"
      - "SmileScape: Untreated periodontitis → causes → Implant failure (contributing, strength=2)"
      - "Relaxia Dental: IV sedation ↔ contraindicates ↔ Severe OSA without CPAP (absolute, strength=3)"
    verification:
      C1_three_real_cases: "✅ Passed — ≥7 cases documented across 4+ brands"
      C2_cross_brand: "✅ Passed — applies to ≥5 medical brands (threshold was ≥2)"
      C3_schema_mapping: "✅ Passed — schema:causeOf + schema:contraindication + schema:riskFactor documented"
      C4_orthogonal: "✅ Passed — distinct from treats, alternative_to, related_to, symptom_of"
    actor: Naphannop S. (operator approval)
    artifact_updated:
      - DECISION_RECORDS.md v1.10 → v1.11
      - EYWA_PROTOCOL Bible v3.16 → v3.17 (Part 2.7.2/2.7.3/2.7.4/2.7.5/2.7.11)
      - Schema_Overview v1.12 → v1.13 (§4.5 columns + triggers)
      - EYWA_HANDOVER v1.10 → v1.11
    deferred_to_operator_workload:
      - "Phase 1E SQL migrations (030/031/032/033)"
      - "eywa-schema-pipeline plugin updates (~16-20h dev)"
      - "eywa-acf-fields field group updates"
      - "n8n classifier updates (test 6 active workflows)"
      - "Notion select options sync"
      - "Brand snapshot block refresh at next Stage gate for brands on bible_version 3.16"
    companion_dr_status:
      DR-014: "Remains Proposed — separate lock cycle"
```

---

## Decisions Log

### [DR-012] — Edge Vocabulary Evolution Policy (2026-05-08)

**Status:** Locked  
**Bible Reference:** Section 2.7.5 (Edge Vocabulary Evolution Policy)  
**Schema Reference:** v1.9 §4.5 (seo_entity_relationships CHECK constraint)

**Context:**

The 10-edge vocabulary defined in Bible Part 2.7.2 was intentionally minimal for healthcare + wellness Phase 1:

```yaml
locked_edges_10:
  hierarchical: [parent_of, child_of, subtype_of, part_of, contains]
  clinical: [treats, treated_by, symptom_of, requires_assessment]
  utility: [uses, used_by, alternative_to, evidenced_by, related_to]
```

Expert review (2026-05-08) raised concern about edge vocabulary potentially being insufficient as EYWA expands to verticals like education, finance, B2B SaaS, or AI systems. The catch-all `related_to` becomes overloaded, semantic distinctions blur, and ad-hoc edge additions risk ontology fragmentation.

Without governance policy, additions become reactive ("we need this edge for THIS use case") and lose architectural coherence.

**Decision:**

Adopt **Edge Vocabulary Evolution Policy** with formal addition workflow.

**Lock Status:**

The 10 existing edges are LOCKED. No new edges may be added without satisfying ALL 4 criteria below + completing the formal addition workflow.

**4 Criteria for Adding an Edge (ALL must be met):**

1. **Real Use Case Proven**
   - ≥3 real entity pairs encountered where existing 10 edges fit poorly
   - Cases must come from actual EGP execution (not hypothetical)
   - Documented in DECISION_RECORDS pending section

2. **Cross-Brand Applicability**
   - New edge usable across ≥2 brands (not single-brand specific)
   - Brand-specific needs handled via `brand_scope[]` on existing edges

3. **Schema.org Mapping Exists**
   - Edge maps to documented schema.org property OR generates measurable SEO benefit
   - Required for Bible Part 26 (Schema Generation Pipeline) integration

4. **Orthogonal to Existing 10**
   - Captures distinct semantics not expressible by combining existing edges
   - Test: Can the relationship be expressed by `existing_edge + qualifier`? If yes, don't add.

**Addition Workflow:**

```yaml
edge_addition_steps:
  step_1_collect_evidence:
    duration: "1-3 months production usage"
    artifact: "Pending edges log with ≥3 real cases documented"
  
  step_2_propose_via_dr:
    template: "## [DR-XXX] — Add Edge: '{edge_name}' (YYYY-MM-DD)"
    required_sections:
      - Evidence (3+ cases)
      - Cross-brand applicability proof
      - schema.org mapping spec
      - Rationale why existing edges insufficient
  
  step_3_review_period:
    duration: "2 weeks"
    reviewers:
      - 1 strategy lead (ontology consistency)
      - 1 engineering lead (implementation impact)
      - 1 editorial lead (content workflow impact)
  
  step_4_acceptance_or_rejection:
    if_approved:
      - DR status: Locked
      - Update Bible Part 2.7.2 with new edge
      - Update Schema seo_entity_relationships CHECK constraint
      - Update n8n edge classification logic
      - Update WordPress ACF eywa_relationships fields
    if_rejected:
      - Document rejection rationale in DR
      - Use existing edges with notes column for special cases
```

**Parking Lot — Future Edges Under Consideration:**

Documented but NOT activated. Will be added if all 4 criteria are met.

```yaml
parking_lot_edges:
  
  measures:
    description: "Diagnostic relationship — entity X measures property Y"
    example: "hrv_test measures autonomic_recovery"
    schema_org_candidate: "diagnoses or hasMeasurement"
    blocked_by: "Need 3+ cross-brand cases (currently 1: VTH BioDent)"
  
  predicts_risk_of:
    description: "Predictive — biomarker → future condition"
    example: "elevated_hs_crp predicts_risk_of cardiovascular_disease"
    schema_org_candidate: "relatedCondition + RiskFactor extension"
    blocked_by: "Need 3+ real cases + schema.org mapping research"
  
  contraindicated_with:
    description: "Treatment/drug interaction conflicts"
    example: "warfarin contraindicated_with vitamin_k_supplements"
    blocked_by: "Currently uses 'alternative_to' + notes (sufficient)"
  
  prerequisite_for:
    description: "Sequential dependency — procedure A before procedure B"
    example: "cbct_scan prerequisite_for dental_implant_surgery"
    blocked_by: "Currently uses 'requires_assessment' (close enough)"
```

**Anti-Patterns (Edge Additions to REJECT):**

```yaml
do_not_add_edge_when:
  
  pattern_1_brand_specific:
    bad: "'mbm_module_of' (VTH BioDent specific)"
    fix: "Use 'part_of' edge with brand_scope=['vth-biodent']"
  
  pattern_2_temporary_campaign:
    bad: "'q4_2026_promotion_for'"
    fix: "Use 'related_to' with notes column, time-bound"
  
  pattern_3_existing_edge_sufficient:
    bad: "'cures' (similar to 'treats')"
    fix: "Use 'treats' — distinguish severity in entity properties"
  
  pattern_4_too_specific:
    bad: "'is_secondary_outcome_marker_for'"
    fix: "Use 'evidenced_by' with citation tier in notes"
  
  pattern_5_one_off_use_case:
    bad: "'sponsors' (single brand uses)"
    fix: "Out of scope for ontology — store in business_relationships table if needed"
```

**Edge Removal Policy:**

```yaml
edge_deprecation_workflow:
  if_unused_12_months:
    1: Document zero-usage in audit log
    2: Propose deprecation via DR
    3: Mark as deprecated in Bible (do not remove immediately)
    4: 12-month grace period — no new usage, existing data preserved
    5: Migration to alternative edge type
    6: Final removal in next major version

current_status: "All 10 edges actively used as of v3.13"
```

**Rationale:**

✅ **Prevents ontology drift before it manifests:**
- Without policy: edges added ad-hoc → vocabulary balloons → schema markup fragments
- With policy: deliberate evolution → vocabulary stays minimal + meaningful

✅ **Aligns with EYWA philosophy:**
- "Discipline > convenience" — same principle as VTH BioDent founder's note
- Mirrors Section 2.6.6.1 EUG (algorithmic enforcement of human discipline)

✅ **Preserves catch-all utility:**
- `related_to` edge intentionally exists for relationships that don't warrant new edges
- Combined with `notes` column, handles 95% of edge cases without vocabulary expansion

✅ **Documented future path:**
- Parking lot edges signal awareness of likely future needs
- Vertical-specific brands (education, finance) can plan for future additions
- Operator retains optionality without committing prematurely

**Alternatives Rejected:**

- **A. Add edges proactively (anticipatory):** ❌ Pre-mature optimization; YAGNI principle
- **B. No policy — add as needed informally:** ❌ Predictably leads to drift over time
- **C. Lock vocabulary forever:** ❌ Too rigid; some verticals genuinely need additions
- **D. Per-brand edge vocabularies:** ❌ Fragments cross-brand knowledge graph; against federation principle

**Consequences:**

✅ **Positive:**
- Edge vocabulary stays minimal + intentional
- Cross-brand schema markup remains consistent
- New edges, when added, have proven justification
- Editorial team has clear "use what edge?" guidance via existing 10
- Future verticals (education, finance, AI) get clear path to add domain-specific edges if truly needed

⚠️ **Trade-offs:**
- Operator must use `related_to + notes` for edge cases instead of creating new edges
- 2-week review period adds friction (but appropriate given irreversibility)
- ≥3 cases requirement may delay edge additions even when need is clear

⚠️ **Process discipline required:**
- Pending edges log must be maintained (DECISION_RECORDS pending section)
- Quarterly review of catch-all `related_to` usage to identify potential new edges
- Annual review of parking lot edges (re-evaluate criteria)

**References:**
- Bible Part 2.7.2 (Edge Vocabulary — 10 edges)
- Bible Section 2.7.5 (Edge Evolution Policy — full spec)
- Schema v1.9 §4.5 (seo_entity_relationships CHECK constraint)
- Bible Part 26.4 (Schema Generation Pipeline — edge → JSON-LD)
- DR-001 (Multi-Brand Federation — cross-brand consistency principle)
- Expert review feedback (2026-05-08) — identified edge vocabulary as future risk

---

### [DR-011] — Entity Uniqueness Guard (EUG) Two-Wave Approach (2026-05-08)

**Status:** Locked  
**Bible Reference:** Section 2.6.6.1 (EUG v1.0) + Section 2.6.6.2 (EUG v2.0 Roadmap)  
**Schema Reference:** v1.9 Appendix G

**Context:**

Bible Part 2.6.6 establishes "Search Before Create" as a discipline for entity creation, but it relies on **human judgment** to detect duplicates. Real-world scenarios that this misses:

- **Typos:** Operator creates `tmj-therapyy` (95% similar to existing `tmj-therapy`)
- **Format variations:** `TMJ_Therapy`, `tmj_therapy`, `TMJ-therapy` all create separate rows
- **Synonyms:** `temporomandibular-joint-therapy` and `tmj-therapy` are the same concept
- **Plurals:** `tmj-disorder` vs `tmj-disorders` — accidentally split
- **Cross-language:** Thai `การรักษาขากรรไกร` collision with English `tmj-therapy` not detected

At 15 brands today, manual discipline + Bible Part 2.6.6 search is sufficient. At 30+ brands and 5,000+ entities (target scale), human discipline alone fails. Expert review (2026-05-08) confirmed "Ontology Drift" as the #1 future risk and called this the "single most important governance addition needed."

The operator (เพื่อน) explicitly raised the example: *"สมมุตว่าในระบบเรามี entity tmj therapy แล้วมันอาจจะมี Temporomandibular joint therapy มาเพิ่มหรือป่าว ซึ่งมันคือเรื่องเดียวกัน อาจจะต้องสร้างระบบป้องกันตรงนี้ขึ้นมา"*

**Decision:**

Adopt **Entity Uniqueness Guard (EUG)** as a 2-wave deployment:

**Wave 1 (Phase 1A — DEPLOY NOW):**

3-layer enforcement using Pure SQL + pg_trgm (already required):

1. **Layer 1 — Database UNIQUE constraint:**
   - `UNIQUE (entity_slug, brand_scope_primary)` on `seo_entity_graph`
   - Hard block at INSERT/UPDATE — PostgreSQL native enforcement
   
2. **Layer 2 — Slug normalization function:**
   - `normalize_entity_slug(text)` returns canonical kebab-case
   - BEFORE INSERT/UPDATE trigger auto-applies
   - Catches: case variations, underscores, whitespace, special characters

3. **Layer 3a — Alias collision check:**
   - `check_alias_collision(slug, aliases, brand_scope)` function
   - Searches existing `canonical_names jsonb` + `aliases jsonb` for matches
   - Application-level pre-flight call before INSERT

4. **Layer 3b — Trigram similarity warning:**
   - `find_similar_entities(slug, threshold, brand_scope, limit)` function
   - Uses `pg_trgm` extension (already required for keywords)
   - Threshold semantics: ≥0.90 BLOCK, 0.75-0.89 WARN, 0.60-0.74 INFO

**Coverage:** ~85% of duplicate scenarios at $0 marginal cost (no new dependencies).

**Wave 2 (Phase 2+ — ROADMAP):**

Add Layer 4 vector similarity check leveraging existing pgvector + `seo_entity_embeddings` infrastructure:

- Embed candidate entity description (OpenAI text-embedding-3-small, ~$0.0001/check)
- Cosine similarity search against existing entity embeddings
- Catches deep semantic synonyms + cross-language equivalents
- Coverage extends to ~99%

**Wave 2 Activation Criteria:**
- pgvector extension live
- Embedding pipeline (n8n + OpenAI) running
- 100+ entities with embeddings populated
- Cost monitoring proven < $5/month

**Rationale:**

✅ **Two-wave defers complexity until value proven:**
- Wave 1 deployable Phase 1A (now) — uses pg_trgm already required
- Wave 2 deferred to Phase 2 — uses pgvector when infrastructure ready
- Avoids over-engineering when 85% solution catches majority of cases

✅ **Smart leveraging of existing infrastructure:**
- pg_trgm: already required for `seo_x_ads_keywords_contextual_master` fuzzy search
- pgvector: already planned for `seo_entity_embeddings` (Schema Group 7)
- No NEW dependencies required for either wave

✅ **Aligned with operator's expressed need:**
- Operator's TMJ therapy / Temporomandibular joint therapy scenario solved by Layer 3a (alias collision) — works because aliases jsonb stores synonyms
- Wave 1 ships discipline-enforcement before drift becomes systemic problem

✅ **Architectural philosophy fit:**
- "The biggest risk is internal drift — discipline > convenience" (founder principle)
- Algorithmic enforcement scales beyond human attention bandwidth
- Aligns with "measurement-first" discipline pattern from VTH BioDent flagship

**Alternatives Rejected:**

- **A. Entity Registry Service (microservice):** ❌ Over-engineering for current scale; Bible Part 19 already provides quality framework
- **B. Embeddings-only (no string layers):** ❌ Higher cost, requires API for every check, doesn't catch typos as well as trigram
- **C. Manual review queue:** ❌ Adds bureaucracy + bottleneck; AI-assisted operator workflow already handles edge cases via Layer 3 warnings
- **D. Defer entirely until problem manifests:** ❌ Reactive fixes harder than preventive; ontology cleanup at 1000+ entities exponentially more expensive

**Consequences:**

✅ **Positive:**
- 85% of duplicate scenarios caught automatically
- Zero new infrastructure dependencies for Wave 1
- Zero ongoing cost for Wave 1
- Clear roadmap to 99% coverage in Wave 2
- Aligns with existing schema (uses canonical_names + aliases jsonb already in Schema v1.8)
- Self-documenting: pre-flight function returns structured collision details
- Migration is additive (no breaking changes)

⚠️ **Trade-offs:**
- Layer 3a/3b add 10-100ms to entity creation (acceptable for non-high-frequency ops)
- Operator must understand decision matrix when collision detected (4 options: adopt/alias/specify/reject)
- ~15% of edge cases (deep semantic synonyms without alias overlap) not caught until Wave 2
- Editorial discipline still required for alias population at entity creation (multilingual coverage)

⚠️ **Operational requirements:**
- n8n workflows must be updated to call `eug_preflight_check()` before INSERT
- Notion automation must validate slugs before sync
- Editorial team must populate `aliases` jsonb at entity creation (not just canonical_names)
- Phase 1A migration adds 1 SQL file: `06-entity-uniqueness-guard.sql`

**Implementation Plan:**

```yaml
phase_1a_eug_v1_deployment:
  ☐ Step 1: Verify pg_trgm extension active (CREATE EXTENSION IF NOT EXISTS)
  ☐ Step 2: Deploy 4 SQL functions (normalize, check_alias, find_similar, preflight)
  ☐ Step 3: Deploy 4 indexes (slug_trgm, canonical_names_gin, aliases_gin, slug_brand_scope)
  ☐ Step 4: Deploy brand_scope_primary computed column + UNIQUE constraint
  ☐ Step 5: Deploy normalize trigger
  ☐ Step 6: Optional backfill (normalize existing slugs)
  ☐ Step 7: Update n8n entity creation flow to call preflight
  ☐ Step 8: Update editorial guidance: populate aliases at create time

phase_2_eug_v2_activation_criteria:
  ☐ pgvector extension active in production
  ☐ seo_entity_embeddings table live with embedding pipeline
  ☐ 100+ entities with embeddings populated
  ☐ Embedding API cost monitoring proven < $5/month
  ☐ Vector similarity query performance < 100ms baseline
  
estimated_total_dev_time: "Wave 1: 1-2 hours; Wave 2: 4-8 hours"
breaking_changes: "None"
rollback_capability: "Full — drop functions, constraints, triggers, indexes"
```

**References:**
- Bible Section 2.6.6 (Search Before Create — predecessor discipline)
- Bible Section 2.6.6.1 (EUG v1.0 specification)
- Bible Section 2.6.6.2 (EUG v2.0 roadmap)
- Schema v1.9 Appendix G (full implementation)
- DR-008 (Two-Column Identity Pattern — uses fingerprint, not slug, for relations)
- DR-009 (Multilingual Strategy — aliases jsonb structure leveraged by Layer 3a)
- DR-010 (Brand Scope Architecture — used by Layer 1 UNIQUE constraint)
- Bible Part 19.3 Dimension 5 (Uniqueness — formalizes what was aspirational)
- Expert review feedback (2026-05-08) — identified ontology drift as #1 risk

---

### [DR-010] — Brand Scope Architecture (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 2.4, Part 28.13  
**Schema Reference:** v1.8

**Context:**  
EYWA federation ใช้ 1 shared Supabase + N Notion workspaces (DR-001) แต่ schema เดิมมี 3 รูปแบบของการเก็บ brand reference ที่ขัดแย้งกัน:
- `seo_entity_graph.brand_scope` = `text[]` (notion_ids without dashes)
- `seo_website_page_master.brand_id` = `text` (UUID format)
- `seo_x_ads_keywords_contextual_master.brand` = `text` (FK to brands.brand_name)

ทำให้ cross-table queries ยาก, federation pattern ใช้จริงไม่ได้, และ shared entities ต้องบอกได้ว่าใช้ใน brand ไหนบ้าง

**Decision:**  
Standardize brand association ผ่าน 2 patterns:

**Pattern A — `brand_scope text[]` (สำหรับตารางที่ shared ระหว่าง brands):**
- Single brand: `['vth-biodent']`
- Universal: `['*']`
- Shared: `['vth-biodent', 'vitalsleep', 'the-face-hospital']`

Tables: `seo_entity_graph`, `seo_topic_cluster_master`, `seo_authors`, `seo_citations`

**Pattern B — `brand_slug text NOT NULL` (สำหรับตารางที่ผูก 1 brand):**
- Single value only
- FK to `brands.brand_slug`

Tables: `seo_website_page_master`, `seo_brand_doctors`, `seo_brand_branches`, `seo_x_ads_keywords_contextual_master`

**`brand_slug`** = canonical brand identifier:
- Lowercase, kebab-case, immutable
- Examples: `vth-biodent`, `vitalsleep`, `the-face-by-vertex`
- Replaces inconsistent UUID/notion_id usage

**Rationale:**  
- **Pattern A**: Entities/clusters/authors อาจ shared หลาย brand → array makes sense
- **Pattern B**: Pages/doctors/branches ผูก 1 brand เสมอ → scalar simpler + FK enforceable
- **brand_slug**: Stable, human-readable, ไม่ผูก Notion IDs, ใช้ใน URL/file naming ได้
- ลด JOIN complexity (no UUID lookups, no notion_id stripping)
- Federation queries ทำได้ง่าย: `WHERE 'vth-biodent' = ANY(brand_scope)`

**Consequences:**
- ✅ Federation pattern (DR-001) implementable in queries
- ✅ Cross-brand entity sharing (DR-003) supported via array
- ✅ GIN index on `brand_scope[]` for fast lookup
- ⚠️ Migration: rename `brand_id` → `brand_slug` in page_master
- ⚠️ Migration: rename `brand` → `brand_slug` in keywords_master (kept FK)
- ⚠️ Backfill needed: notion_id → brand_slug mapping

**Implementation:**
- New column `brand_slug` on `brands` table (UNIQUE, immutable)
- 15 brand slugs locked: vth-biodent, vitalsleep-and-wellness, the-face-by-vertex, etc.
- All references migrate to `brand_slug` in Phase 1

**References:**
- DR-001 (Multi-Brand Federation Pattern)
- DR-003 (Single Entity, Multilingual Labels)
- Bible Part 2.4 (Multi-Brand Sharing)
- Schema v1.8 §3.1, §4.1, §5.1

---

### [DR-009] — Multilingual Strategy v2 (Two-Tier Pattern) (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 28 (entire)  
**Schema Reference:** v1.8

**Context:**  
EYWA targets 8 languages (TH, EN immediate; ZH, JA, KO, AR, FR, ES phased). Bible v3.9 introduced "Single Entity, Multilingual Labels" pattern (DR-003) but didn't differentiate between:
- **Concept tables** (entity, brand, author): same concept, multiple language labels
- **Content tables** (page, keyword, review): each language is separate content asset

Without this differentiation, applying single-row jsonb pattern to all tables would break content-level workflows (separate URL slugs, distinct SEO metadata, independent translation status per language).

**Decision:**  
Adopt **Two-Tier Multilingual Strategy**:

**Tier 1 — Concept Tables (1 row + jsonb translations):**

Used for entities where the concept is universal but has multiple language labels.

```jsonb
canonical_names: {"en": "Sleep Apnea", "th": "ภาวะหยุดหายใจขณะหลับ"}
aliases: {
  "en": ["sleep apnea syndrome", "OSA"],
  "th": ["หยุดหายใจตอนนอน", "นอนกรนแบบรุนแรง"]
}
descriptions: {"en": "...", "th": "..."}
```

Tables:
- `seo_entity_graph` (ent)
- `seo_topic_cluster_master` (clus)
- `brands` (brnd)
- `seo_authors` (auth)
- `seo_brand_doctors` (doc)
- `seo_brand_branches` (brch)
- `seo_citations` (cite)

**Tier 2 — Content Tables (1 row per language + translation_group_id):**

Used for content where each language version is a separate asset with unique SEO properties.

```yaml
schema:
  fingerprint: "page_01HZP5K2A"  # unique per row
  translation_group_id: "tg_01HZP5K2X"  # shared across translations
  page_language: "th"
  is_source_page: true  # exactly 1 per group
  source_translation_fp: "page_01HZP5K2A"  # NULL if is_source
```

Tables:
- `seo_website_page_master` (page)
- `seo_x_ads_keywords_contextual_master` (kw) — already has `translation_group`
- `seo_editorial_reviews` (rev)

**Translation Group ID Format:** `tg_{ULID16}` (separate namespace from row fingerprints)

**Rationale:**  
- **Concept** = "entity is the same, only label changes" → 1 row, jsonb is right
- **Content** = "each language is unique content with its own URL, slug, metadata" → separate rows
- jsonb keeps concept tables DRY (Wikidata link / ICD-10 / parent_fp shared across languages)
- translation_group_id enables consolidated performance queries:
  ```sql
  SELECT translation_group_id, sum(views) 
  FROM page_analytics 
  GROUP BY translation_group_id;
  ```
- Pattern matches existing keyword table's `translation_group` column (already production-tested)
- Source page flag enables canonical reference for hreflang generation

**Consequences:**
- ✅ Each table has clear multilingual semantics
- ✅ Content workflows (status per language, due dates per translation) supported
- ✅ Consolidated analytics across language versions possible
- ✅ hreflang generation has canonical source
- ⚠️ Pages: 1 entity = N pages (4 languages = 4 rows)
- ⚠️ Migration: existing page rows need `translation_group_id` backfill
- ⚠️ Constraint: only 1 `is_source_page = true` per group (UNIQUE INDEX with WHERE clause)

**Edge Cases:**
- Entity adds language: just add key to `canonical_names` jsonb (no new row)
- Page adds language: new row with same `translation_group_id`, `is_source_page = false`
- Translation removed: delete row, group still valid
- All translations of group deleted: orphaned group_id (cleanup periodically)

**References:**
- DR-003 (Single Entity, Multilingual Labels) — extended by this DR
- Bible Part 28 (Multilingual Architecture)
- Schema v1.8 §3-5 (table definitions per tier)

---

### [DR-008] — Two-Column Identity Pattern (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 18.9 (NEW)  
**Schema Reference:** v1.8

**Context:**  
Existing fingerprint patterns use composite of business fields:
- `page:vth-biodent:tmj-treatment`
- `entity:sleep-apnea`
- `vth-biodent::th::th::tmj รักษา` (keyword)

This works for **immutable** fields (keyword text never changes) but breaks for **mutable** fields (entity slug renames, page slug restructures, ICD-10 corrections by AI/expert review).

**Decision:**  
Every table (except `seo_x_ads_keywords_contextual_master`) gets TWO identity columns:

| Column | Type | Mutability | Purpose |
|--------|------|------------|---------|
| `fingerprint` | text UNIQUE NOT NULL | IMMUTABLE | Machine identity, used for FK/joins |
| `fingerprint_display_name` | text NOT NULL | MUTABLE | Human label, debug aid |

**Format:**
- `fingerprint`: `{tablecode}_{ULID16}` (Pattern B)
  - Example: `ent_01HZP5K2XQR7N3MF`
  - 16 characters of ULID (time-sortable, 80-bit entropy)
  - Compact yet collision-safe
- `fingerprint_display_name`: `{fp_last_6}::{type}::{slug}::{key_data}`
  - Example: `n3mf::condition::sleep-apnea::g47.3`
  - First 6 chars = last 6 of fingerprint (cross-check)
  - `::` (double colon) separator
  - Auto-refreshed when source data changes

**Exception:** `seo_x_ads_keywords_contextual_master` keeps existing fingerprint format `{brand_slug}::{market}::{language}::{keyword}` because it's already self-documenting and immutable.

**Rationale:**
- ✅ Stable machine identity prevents broken relations on rename
- ✅ Human-readable label enables debugging and data validation
- ✅ Last-6-of-fingerprint in display creates double cross-check
- ✅ ULID provides time-ordering benefit for free
- ✅ ICD-10 corrections by AI don't cascade-break references
- ✅ Two-Phase Hierarchy Sync (DR-006) more robust

**Consequences:**
- ✅ All tables follow consistent pattern
- ✅ FK columns use `fingerprint` (not slug)
- ✅ Debug surface area expanded (display name visible in queries)
- ⚠️ Migration: backfill existing rows with new fingerprint format
- ⚠️ Trigger overhead must be measured (ULID generation + display refresh)
- ⚠️ Cross-system updates (Notion ↔ Supabase) reference `fingerprint` consistently

**Implementation Order:**

1. Create `generate_ulid()` function
2. Create `generate_*_display_name()` functions per table
3. ALTER existing tables: add columns (NULLable initially)
4. Backfill existing rows
5. Add triggers (insert, update, immutability)
6. Set NOT NULL constraint after backfill complete
7. Update n8n workflows to use new column

**References:**
- Bible Part 18.9 (NEW — Two-Column Identity Pattern)
- DR-006 (Two-Phase Hierarchy Sync) — strengthened by this pattern
- Schema v1.8 Appendix B (Fingerprint Patterns — rewritten)
- Helper functions: `generate_ulid()`, `generate_fingerprint_v2()`, per-table display generators

---

### [DR-007] — In-Place GTGT Schema Upgrade (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 5 (Database Schema Architecture)  
**Schema Reference:** v1.7 → v1.8

**Context:**  
Existing GTGT Supabase project (lffcbeszjqzioobqfdav, ap-northeast-1) contains:
- 13 production tables (brands, entity_graph, page_master, keyword pipeline, logs, etc.)
- 30 tracked migrations (2026-03-10 to 2026-03-23)
- 6 active n8n workflows (Notion ↔ Supabase sync)
- 25K+ keyword analytics rows (active feed: 5K-7K/day from 5 brands)
- 466 entities (287 VTH BioDent + 179 VitalSleep)
- 1,376 planned pages (all VitalSleep)

Bible v3.11 + Schema v1.7 specify ~17 additional tables and require schema changes (sync_state, parent_notion_id, multilingual jsonb, fingerprint normalization).

**Options Considered:**

| Option | Approach | Cost | Risk | Verdict |
|--------|----------|------|------|---------|
| A | New project (clean slate) | $25/mo | 🟢 LOW | ❌ Loses sweat equity |
| B | In-place upgrade GTGT | $0 | 🟡 MED | ✅ Chosen |
| C | 2 environments (GTGT+new) | $25/mo | 🟢 LOW | ❌ Over-engineering |
| D | Branch test first | $10/mo | 🟢 LOW | ⚠️ Optional add-on |
| E | Split DBs (keywords vs core) | $25/mo | 🟡 MED | ❌ Premature optimization |

**Decision:**  
**Option B — In-Place Upgrade** of GTGT to align with Schema v1.8.

**Strategy:**
- ALTER existing tables: add columns (idempotent IF NOT EXISTS)
- CREATE missing v1.8 tables (~17 new tables)
- Add triggers, functions, indexes
- **Data migration is OUT of scope** (existing entity/page data may be discarded — operator confirmed)
- **n8n workflow changes** deferred to later phase (compatibility maintained where possible)

**Rationale:**  
- 30 existing migrations show working in-place evolution discipline
- Solo developer scale (15 brands) doesn't justify multi-project overhead
- Cost-effective ($0 additional infrastructure)
- Existing keyword pipeline preserved without disruption
- Operator explicitly accepted that schema-first work doesn't require data preservation
- Notion FDW + sync infrastructure already in place

**Consequences:**
- ✅ Zero downtime migration possible (all changes additive)
- ✅ Existing n8n workflows continue running
- ✅ 30 historical migrations preserved as baseline
- ✅ No data export/import gymnastics
- ⚠️ Some legacy columns coexist with new pattern (graceful coexistence period)
- ⚠️ Migration must be careful with FK constraints
- ⚠️ Trigger overhead measured before production load

**Out of Scope (Phase 1):**
- Data migration (entity/page rebuild = future project responsibility)
- n8n workflow rewrites (will adapt later if needed)
- Notion database restructure (separate phase)
- WordPress integration (Phase 3+)
- Performance dashboards (Phase 4+)

**References:**
- Schema v1.8 (entire)
- Bible Part 5 (Database Schema Architecture)
- DR-008, DR-009, DR-010 (companion decisions for this upgrade)
- 30 GTGT historical migrations (in `supabase_migrations.schema_migrations`)

---

### [DR-006] — Two-Phase Hierarchy Sync Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Part 18.8  
**Schema Reference:** v1.7

**Context:**  
Hierarchical data (entities with parents, sitemap pages with parent pages, nested clusters) ต้องอยู่ใน 2 ระบบที่มี ID system ต่างกัน:
- **Supabase:** ใช้ text-based references (entity_fingerprint, sitemap_node_id) — portable, human-readable, planning-friendly
- **Notion:** ต้องใช้ native relations (UUID-based) สำหรับ tree UI rendering, rollups, expand/collapse

ที่ planning phase (markdown files), เรายังไม่มี Notion ID เลย — ต้องใช้ text references. แต่ที่ implementation phase, Notion ต้อง native relations เพื่อ render hierarchy บน UI.

**Decision:**  
Two-Phase Sync Pattern — separate columns สำหรับ planning state vs operational state:

**Phase 1 (Planning):** Markdown files use text-based parent references
```yaml
parent_entity_fp: "entity:tmj-disorder"
sync_state: "draft"  # markdown only, not yet in Notion
```

**Phase 2 (Operational):** After Notion sync, both columns coexist:
```yaml
parent_entity_fp: "entity:tmj-disorder"  # preserved for queries
parent_notion_id: "abc-123-def"           # native Notion relation
sync_state: "synced"                       # both representations valid
```

**Schema additions:**
- `parent_notion_id text` — populated after Notion creates parent
- `sync_state text` — values: 'draft', 'syncing', 'synced', 'orphaned'
- `last_sync_at timestamptz` — when last successfully synced
- n8n flow B (resolver) — periodically maps text refs → notion_ids

**Rationale:**  
- ✅ Planning works without Notion (offline, version-controlled markdown)
- ✅ Operational queries can use either text or notion_id reference
- ✅ Sync failures don't block content creation
- ✅ Markdown remains source of truth for structure
- ✅ Notion native relations work for UI rendering

**Consequences:**
- ✅ Hierarchy works in both planning and operational phases
- ✅ Resilient to Notion outages
- ⚠️ Two columns to maintain (sync flow handles)
- ⚠️ Sync state must be monitored (orphans can accumulate)

**References:**
- Bible Part 18.8 — Two-Phase Hierarchy Sync Pattern
- Schema v1.7 — `parent_notion_id` + `sync_state` fields added
- DR-008 (Two-Column Identity) — strengthens this pattern

---

### [DR-005] — GitHub Distribution Strategy (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 10.7  
**Schema Reference:** N/A

**Context:**  
EYWA Protocol ecosystem ต้อง distribute code, specs, per-brand content ในรูปแบบที่:
- ทีม access ได้ (cross-team collaboration)
- Version controlled (history + rollback)
- Permission-managed (private repos for proprietary content)
- Scalable (10+ brands)

**Decision:**  
3-level GitHub structure:

**Level 1 — Organization:** `the-gifted-digital`

**Level 2 — Universal Shared Repos (eywa-* prefix):**
- `eywa-protocol-spec` — Bible, Schema, Handover, DECISION_RECORDS
- `eywa-core` — Foundation plugin
- `eywa-cpt-activation` — CPT registration plugin
- `eywa-acf-fields` — ACF field group JSONs
- `eywa-schema-pipeline` — Schema generator plugin
- `eywa-elementor-templates` — Theme Builder JSON exports
- `eywa-db-migrations` — SQL migration scripts
- `eywa-n8n-flows` — n8n workflow exports
- `eywa-docs` — Public documentation (if needed)

**Level 3 — Per-Brand Repos (eywa-{brand} pattern):**
- `eywa-vth-biodent` — VTH BioDent content + config
- `eywa-vitalsleep` — VitalSleep content + config
- ... (one per brand)

**Visibility:** All repos Private by default.

**Rationale:**  
- Universal code in shared repos = deploy once, all brands benefit
- Brand-specific content separated = privacy + team isolation
- Federation pattern reflected at code level (mirror of database brand_scope concept)
- Easy team permission management (per-repo)
- Scales to 20+ brands without restructuring

**Consequences:**  
- ✅ Clear separation of universal vs brand-specific
- ✅ Permission boundaries match operational boundaries
- ⚠️ Bible/Schema updates require notification to all brand teams
- ⚠️ Cross-repo dependencies must be documented

**References:**  
- Bible Section 10.7 — Federation Pattern
- EYWA_HANDOVER Section 3 — Source of Truth Hierarchy

---

### [DR-004] — URL Structure: Subdirectory + Thai Default (2026-05-07)

**Status:** Locked  
**Bible Reference:** Part 28.2

**Context:**  
EYWA brands serve Thai-first audience (medical/dental clinics in Thailand). Multilingual support needed for:
- Medical tourism (English, Chinese, Japanese, Korean)
- Future expansion (Arabic, French, Spanish)

URL strategy options for multilingual:
- **A. Subdirectory:** `/en/`, `/zh/`, `/`(Thai default)
- **B. Subdomain:** `en.example.com`, `zh.example.com`
- **C. ccTLD:** `.co.th`, `.com`, `.cn`

**Decision:**  
Subdirectory pattern with Thai as default (no prefix), other languages prefixed:
- Default Thai: `https://example.com/services/dental-implants`
- English: `https://example.com/en/services/dental-implants`
- Chinese: `https://example.com/zh/services/dental-implants`

**Rationale:**  
- ✅ Single domain = cumulative SEO authority (vs spreading across subdomains/ccTLDs)
- ✅ Simpler hosting + SSL (one cert, one server config)
- ✅ Easier Google Search Console management (one property)
- ✅ Thai default reflects primary market reality
- ✅ WPML default + recommended pattern
- ✅ Easier hreflang implementation
- ✅ Shared backlink authority across languages

**Alternatives Rejected:**
- **Subdomain:** Splits authority across subdomains, complex hosting, separate GSC properties
- **ccTLD:** Highest cost, complex management, only justified for very large markets

**Consequences:**  
- ✅ Best SEO authority concentration
- ✅ Operationally simple
- ⚠️ Requires hreflang implementation (not optional)
- ⚠️ WPML must be configured correctly per brand

**References:**  
- Bible Part 28.2 — URL Structure for Multilingual
- Bible Section 28.7 — Schema Per Language
- Google: hreflang implementation guidelines
- WPML: subdirectory configuration docs

---

### [DR-003] — Single Entity, Multilingual Labels Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Part 28.3, Schema_Overview v1.6 Section 4.1

**Context:**  
Multilingual entity strategy options:
- **A. One entity per language with sameAs links** (e.g., separate "TMJ Disorder" + "โรค TMJ" + "顳下頜關節紊亂" entities)
- **B. Single entity with multilingual labels jsonb** (one entity, name varies per language)

**Decision:**  
Option B — single entity record per concept, with `canonical_names jsonb` field containing per-language values. Universal entity ID (entity_fingerprint) across all 8 supported languages.

**Schema Implementation:**
```sql
canonical_names jsonb DEFAULT '{}'
-- Structure: {"th": "...", "en": "...", "zh": "...", "ja": "...", ...}
```

**Rationale:**  
- ✅ Knowledge graph stays unified (1 concept = 1 entity)
- ✅ Edges defined once, not duplicated per language
- ✅ Wikidata mapping cleaner (1 Q-ID per entity)
- ✅ Scoring computed at entity level (cross-language signals consolidate)
- ✅ Schema generation simpler (entity → schema in target language)
- ✅ Translation workflow more straightforward

**Alternatives Rejected:**
- **One entity per language:** ❌ Graph fragmentation, edge duplication, unclear authority distribution

**Consequences:**  
- ✅ Simpler graph queries
- ✅ Cleaner schema
- ⚠️ Per-language scoring requires GREATEST() aggregation across languages
- ⚠️ Translation workflow must populate jsonb fields per language
- ⚠️ Missing translations need fallback strategy (default to Thai)

**References:**  
- Bible Part 28.3 — Multilingual Entity Strategy
- Schema_Overview v1.6 Section 4.1 — `canonical_names` field spec
- Wikidata: multilingual label pattern
- DR-009 (Multilingual Strategy v2) — extends this DR with Two-Tier pattern

---

### [DR-002] — Elementor Pro + Hello Theme Stack (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 25.11

**Context:**  
WordPress frontend stack choice for EYWA brand sites. Options:
- **A. Custom Gutenberg blocks** — full programmatic control
- **B. Page Builder (visual)** — designer-friendly
- **C. Hybrid** — combination

**Decision:**  
Hello Elementor theme + Elementor Pro + ACF Pro + RankMath Pro + WPML stack.

Specifically:
- **Hello Elementor** — minimal theme (no built-in styles, fast)
- **Elementor Pro** — Theme Builder + Loop Builder + Dynamic Tags
- **ACF Pro** — custom fields + JSON sync + WPML compat
- **RankMath Pro** — SEO + hreflang + breadcrumbs
- **WPML** — multilingual

**Plugin count reduced:** 5 → 4 EYWA custom plugins (Loop Builder replaces eywa-related-blocks)

**Rationale:**  
- ✅ Designer-friendly (zero-PHP layouts via Elementor UI)
- ✅ Theme Builder = single template per CPT, conditional logic native
- ✅ Loop Builder replaces custom Gutenberg blocks
- ✅ Dynamic Tags pull ACF data automatically
- ✅ Industry-standard, extensive community + docs
- ✅ Reduced custom plugin count = less maintenance
- ✅ Designer can iterate without dev intervention

**Alternatives Rejected:**
- **Pure Gutenberg:** Too programmatic, designers can't iterate
- **Bricks Builder:** Smaller community, fewer integrations
- **Divi:** Bundled theme too opinionated, harder to customize

**Consequences:**  
- ✅ 80% of design work in Elementor UI (designer autonomy)
- ✅ Reduced custom plugin count
- ⚠️ Elementor Pro license cost ($59-399/site/year)
- ⚠️ Hello theme has no built-in schema → EYWA Schema Pipeline plugin handles
- ⚠️ Performance must be monitored (Elementor + WPML can be heavy)

**References:**  
- Bible Section 25.11 — Elementor Pro Integration
- Bible Section 25.8 — Template Hierarchy
- Industry: Hello Elementor + ACF + WPML pattern

---

### [DR-001] — Multi-Brand Federation Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 10.7

**Context:**  
EYWA system needs to support managing 5-20 healthcare/wellness brands. Architectural choice:
- **A. Fully separate per-brand systems** — 1 Supabase + 1 Notion + 1 WP per brand
- **B. Single mega-system** — Everything merged
- **C. Federation pattern** — Shared backend, isolated frontends

**Decision:**  
**Option C — Federation pattern:**

**Shared (Federation Backend):**
- 1 Supabase database (with brand_scope[] column on relevant tables)
- N Notion workspaces (per editorial team)
- 1 n8n instance (for sync orchestration)

**Isolated (Per-Brand Frontend):**
- N WordPress sites (one per brand)
- Each pulls only its brand's data via brand_scope filter
- Independent domains, themes, content

**Rationale:**  
- ✅ Schema upgrade once for all brands (vs N migrations)
- ✅ Citations/entities sharable when relevant (`brand_scope=['*']`)
- ✅ Generic medical entities (TMJ, sleep apnea) defined once
- ✅ Cross-brand visibility for operators
- ✅ Resource sharing (citations researched once benefit all)
- ✅ Brand isolation enforced via `brand_scope` filter
- ✅ Frontend autonomy preserved (per-brand WordPress)
- ✅ Cross-brand referrals = native feature
- ✅ Onboarding new brand = data, not architecture

**Alternatives Rejected:**
- **Full separation:** Schema migrations exponential, citation duplication, no cross-brand visibility
- **Full merger:** Permission nightmare, brand isolation hard, frontend coupling

**Decision Evolution:**
- Original draft included `teams` table — REMOVED (over-engineering)
- Team management via Notion ACL + n8n flow ENV vars (lighter)

**Consequences:**  
- ✅ Efficient cross-brand operations
- ✅ Right-sized for portfolio operators (5-20 brands)
- ⚠️ Notion workspace topology requires manual setup per team
- ⚠️ brand_scope validation must happen in n8n flow config (not DB-level)
- ⚠️ Editorial isolation via Notion permissions (not DB-level RLS)

**References:**  
- Bible Section 10.7 — Operational Multi-Brand Federation Pattern
- Bible Section 4.12 — Cross-Brand External Link Tracking
- Bible Section 18.7 — Multi-Workspace Sync Strategy
- Schema_Overview v1.6 — brand_scope[] field on all relevant tables

---

## Future Decision Topics

Decisions to be documented as they emerge:

- [ ] **DR-015:** WordPress hosting strategy (per-brand or shared?) *(was DR-013 in v1.2)*
- [ ] **DR-016:** Supabase project tier + scaling strategy *(was DR-014 in v1.2)*
- [ ] **DR-017:** n8n hosting strategy (self-hosted vs cloud) *(was DR-015 in v1.2)*
- [ ] **DR-018:** Translation provider selection (Claude vs GPT-4 vs DeepL) *(was DR-016)*
- [ ] **DR-019:** Editorial review workflow tooling *(was DR-017)*
- [ ] **DR-020:** CDN strategy (Cloudflare, BunnyCDN, etc.) *(was DR-018)*
- [ ] **DR-021:** Image optimization pipeline *(was DR-019)*
- [ ] **DR-023:** External Authoritative Link Tracking (extend `to_external_url` usage from seo_page_internal_links) *(claimed 2026-05-11 from DR-021 follow-up)*
- [ ] **DR-026:** Analytics stack (GA4 + custom + ?) *(was DR-024 in v1.8)*
- [ ] **DR-027:** Backup + disaster recovery strategy *(was DR-025 in v1.8)*
- [ ] **DR-028:** Migration repo strategy (separate vs subfolder) *(was DR-026 in v1.8)*
- [ ] **DR-029:** Notion database sync scope (which tables sync) *(was DR-027 in v1.8)*
- [ ] **DR-030:** Branch testing protocol for migrations *(was DR-028 in v1.8)*

> **Note on renumbering (v1.9):** DR-024 (Restore 9 Entity Extension Tables) and DR-025 (Restore Local SEO Tables + Consolidate Branches) became Locked in v1.9. Future placeholders shifted from DR-024..DR-028 to DR-026..DR-030. Future placeholders preserve their previous topic context.

> **Note on renumbering (v1.8):** DR-022 (Lean Phase B + Two-Layer Sitemap + Iterative Refinement) became Proposed in v1.8. Future placeholders shifted from DR-022..DR-026 to DR-024..DR-028 (DR-023 newly claimed for External Link Tracking). Future placeholders preserve their previous topic context.

> **Note on renumbering (v1.3):** DR-013 (Edge Vocabulary v3.5 Expansion) and DR-014 (Concept Entity Subtype Lock) became Proposed decisions in v1.3 (field-tested feedback from VTH BioDent). Future placeholders shifted from DR-013..DR-024 to DR-015..DR-026 to preserve numbering continuity. Future placeholders preserve their previous topic context.

> **Note on renumbering (v1.2 — historical):** DR-011 (Entity Uniqueness Guard) and DR-012 (Edge Vocabulary Evolution Policy) became LOCKED decisions in v1.2. Placeholders shifted from DR-011..DR-022 to DR-013..DR-024 at that time.

---

## Maintenance Rules

```yaml
decision_record_governance:
  
  who_can_add:
    - Operator (final authority)
    - Claude/AI (proposes — operator approves)
    - Tech leads (with operator sign-off)
  
  what_must_be_documented:
    - Architectural choices (database design, framework selection)
    - Strategic patterns (federation, multilingual, sync)
    - Trade-off decisions (cost vs features, speed vs quality)
    - Anything that future developers/AI will ask "WHY did we do it this way?"
  
  what_does_NOT_belong:
    - Implementation details (use code comments)
    - Bug fixes (use commit messages)
    - Daily operational decisions (use issue tracker)
  
  format_discipline:
    - Sequential numbering (never reuse numbers)
    - Append-only (don't delete — supersede instead)
    - Cross-reference Bible sections + related DRs
    - Date stamp every entry
  
  review_cadence:
    - Quarterly: review all DRs for relevance
    - When superseded: mark old DR + reference new DR
    - When implemented: update Status to "Locked"
```

---

## Changelog

### v1.9 (2026-05-12) — DR-024 + DR-025 Locked (Restore Forgotten Schema) 🔒🧬🏥

Spec catch-up: Bible v3.14 Appendix B.3 (9 entity extension tables) and Appendix B.5 (5 Local SEO tables) silently fell out of Schema_Overview between v1.0 and v1.10 — no DR, no changelog explanation. Operator confirmed forgotten, not deliberate; strategy unchanged. Two paired Locked DRs restore parity; ships paired with Schema v1.11 + Bible v3.15.

**Headline Changes:**

- ➕ **DR-024 (NEW, Locked):** Restore 9 Entity Extension Tables. 6 missing extensions added back to Schema Group 9 (`seo_entity_product`, `seo_entity_condition`, `seo_entity_drug`, `seo_entity_anatomy`, `seo_entity_organization`, `seo_entity_lab_test`). Existing 3 (`ingredients`, `procedures`, `devices`) preserved. `seo_programmatic_templates` reclassified as §11.10 (template registry, not entity extension). Group 9 count: 4 → 10 tables.

- ➕ **DR-025 (NEW, Locked):** Restore Local SEO Tables + Consolidate `seo_locations` → `seo_branches`.
  - 3 new tables: `seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`
  - 1 enhanced: `seo_branches` gains ~15 columns to match Bible Table 24 spec (multi-directory IDs, GBP categories/rating, photos, compliance, staff assignment, special hours, organization entity FK)
  - 1 FK rename: `seo_local_rankings.location_id` → `branch_id`
  - Bible-side rename: all 8 `seo_locations` references in Bible v3.14 → `seo_branches` (Bible bumps v3.14 → v3.15)
  - Group 1 count: 4 → 7 tables

- 🎯 **Why this matters:**
  - T1 medical-condition template (Bible Part 4.1.1) gains its schema binding — was implementable-on-paper but not in DB
  - Clinic vertical Phase 5 (Local SEO + GBP) unblocked — n8n GROUP E flows (E1/E2/E3/E4) become implementable
  - NAP consistency monitoring + PDPA-safe review responses operational at Day 1 (Bible Part 10.5 promise honored)
  - Knowledge graph typed FKs (condition ↔ anatomy ↔ drug ↔ procedure) instead of text matches
  - External org citations gain proper entity store (was conflating with `brands` or generic `entity_graph`)

- 🔄 **Renumbering:**
  - Future placeholders DR-024..DR-028 → DR-026..DR-030 (preserves topic context per maintenance rules)
  - DR-023 (External Authoritative Link Tracking) unchanged — still claimed from 2026-05-11

- 🚧 **Paired releases (same day):**
  - Schema_Overview v1.10 → v1.11 (Group 1 +3 tables, §3.2 enhanced; Group 9 +6 tables; architecture overview 28 → 37 tables)
  - Bible v3.14 → v3.15 (rename `seo_locations` → `seo_branches` × 8 refs; changelog entry only; no structural change)
  - EYWA_HANDOVER v1.8 → v1.9 (spec snapshot reference + Pre-Flight Checklist refresh)

- ✅ **Backward compatible (within EYWA spec stack):**
  - Existing 3 extensions + existing `seo_branches` rows preserved
  - New columns NULL-allowed for backfill
  - Existing brand snapshots (`bible_version: 3.14`, `schema_version: 1.10`) remain valid for their snapshot point; brands refresh at next Stage gate per Handover §9.3

- 📦 **Migration files to author (eywa-supabase-migrations or in-spec subfolder):**
  - `009_enhance_seo_branches.sql`
  - `010_create_seo_reviews.sql`
  - `011_create_seo_directory_listings.sql`
  - `012_create_seo_gbp_posts.sql`
  - `013_rename_local_rankings_fk.sql`
  - `014_restore_entity_product.sql`
  - `015_restore_entity_condition.sql`
  - `016_restore_entity_drug.sql`
  - `017_restore_entity_anatomy.sql`
  - `018_restore_entity_organization.sql`
  - `019_restore_entity_lab_test.sql`

- 🚧 **Pending brand work (post-spec-bump):**
  - All in-flight clinic brands refresh `eywa_spec_snapshot` at next Stage gate (typically Stage 1 → 1.5 transition)
  - Stage 1.5 step 3 (column completion) now includes 3 Local SEO tables + 6 new extension tables for clinics
  - VTH BioDent (Stage 1.5 blocked on DR-021 lock — also note new DR-024/025 to incorporate)
  - SmileScape (Stage 1 Phase E in progress — adopt DR-024/025 at Stage 1 → 1.5 gate)

### v1.8 (2026-05-11) — DR-022 Proposed (Lean Phase B + Two-Layer Sitemap + Iterative Refinement) 🌱

Field-tested workflow proposal from VTH BioDent + SmileScape sessions. Replaces lump Phase B with lean planning loop + async background DFS enrichment + single iterative refinement.

**Headline Changes:**

- ➕ **DR-022 (NEW, Proposed):** Lean Phase B + Two-Layer Sitemap. 7 sub-decisions:
  1. Two-Layer Sitemap (Layer 1 brand-immune / Layer 2 volume-driven / Layer 3 internal linking)
  2. Lean Phase B (single human-blocking phase, not 5 sub-phases — no DFS gate)
  3. Stage 1 Gate adjustment (sitemap structure confirmed without volume data)
  4. Stage 1.5 async enrichment trigger (n8n on `seo_x_ads_keywords_contextual_master` INSERT)
  5. Phase E.refine NEW (post-enrichment iterative refinement with gap-report.md)
  6. Phase F KW context consumption (painpoint/anxiety/insight per page)
  7. Output file restructure (deprecate `research-notes.md`, split into 5 specific files)

- 🎯 **Why this matters:**
  - Phase 1 timeline shortened (no DFS gate blocking entity/sitemap/citation)
  - 30-60% cheaper DFS spend per brand via layered enrichment (cheap full-list volume + expensive shortlist SERP)
  - Brand topical authority preserved (Layer 1 service pages volume-immune)
  - Modern E-E-A-T + AI search era alignment (whole-site context > volume-only selection)
  - Maps to existing 4-table KW infrastructure + n8n flows (no schema migrations)

- 🔄 **Renumbering:**
  - DR-023 newly claimed for External Authoritative Link Tracking (was DR-022 follow-up note in DR-021)
  - Future placeholders DR-022..DR-026 → DR-024..DR-028

- ✅ **Backward compatible:**
  - No schema changes
  - VTH BioDent (Stage 1 done) + SmileScape (Stage 1 Phase E) adopt at next gate
  - 11 empty brand repos use DR-022 from inception

- 🚧 **Pending Bible amendments (post-lock):**
  - Bible §4.14 Page Viability — Layer 1 exemption clause
  - Bible Part 4 — Two-Layer Sitemap pattern documentation

### v1.7 (2026-05-10) — DR-021 Proposed (Internal Linking Architecture HYBRID) 🌱

Triggered by operator review of pre-EYWA Notion DB "Website & SEO Page Intelligent Master" + Stage 1.5 (Handover v1.6) needing internal linking storage. Surfaces a gap in v1.10 (implicit linking only via cluster/entities/sitemap hierarchy — no per-edge fidelity).

- ➕ **DR-021 (NEW, Proposed):** Internal Linking Architecture (HYBRID). 4 sub-decisions: (1) 12 page-level strategy cols added to page_master, (2) new `seo_page_internal_links` junction (~22 cols, per-edge), (3) bidirectional consistency validation (reciprocal detection, anchor diversity, orphan check, depth), (4) cross-brand link governance.
- 📝 **Review cycle:** 4 weeks (until 2026-06-07) — paired with DR-019/020 cycle.
- 📝 **Schema impact:** v1.11 migration — 12 new page_master columns + new `seo_page_internal_links` table. 2 new migrations (009 + 010, Phase 1A.3).
- 📝 **Operator Notion DB precedent:** Page-level fields ported (Authority Weight, Link Equity Score, Anchor Strategy Mode, Cross-Brand governance). Junction adds per-edge fidelity Notion lacked.
- 📝 **Independent of DR-013/014** — different governance scope. Complements DR-019 (schema emission) + DR-020 (content composition) — together form complete content production stack: composition + emission + linking.
- 📝 **Stage 1.5 dependency:** Handover Stage 1.5 step 3 references this for internal linking planning step.

### v1.6 (2026-05-10) — DR-020 Proposed (Universal Content Template Standard) 🌱

Triggered by VTH BioDent /mouth-biomapping/ EEAT audit (visual EEAT good, structured EEAT broken — 6 failures) + Deezy sitemap gap analysis (13 page types, no template framework). Operator field test confirmed need for universal content composition standard across 13 brands × 6 verticals.

- ➕ **DR-020 (NEW, Proposed):** Universal Content Template Standard — 4 sub-decisions: (1) Companion file architecture, (2) 3-layer composition (~25 blocks → 25 templates → customization hooks), (3) EEAT requirement matrix locked per template, (4) Schema enforcement beyond visual.
- 📁 **New companion file:** `Content_Templates_EYWA_v1_0.md` (placed at repo root with DRAFT status in frontmatter, **v1.1 as of 2026-05-10** — bumped from v1.0 same day after operator OSA Master Example integration; 25 templates, ~26 blocks incl. B25a Crisis Disclosure + B26 Predicted Prompts Bank) — formal Bible cross-reference upon DR-020 approval.

- 🆕 **v1.1 additions** (operator-driven from pre-spec OSA Master Example doc):
  - §2.8 Pattern A-E Citable Taxonomy (5 brand-citable patterns including Pattern E Brand Stance — LLMO superweapon)
  - §2.9 Predicted Prompts Bank (off-render planning artifact + 2-table Schema spec for active LLMO measurement)
  - §2.10 Cross-Vertical Adaptability Framework (per-specialty perspective pivot guide)
  - §2.7 B25a Crisis Disclosure Block (acute YMYL emergency triggers)
  - §6.4 Schema Tier Architecture (1/2/3 — site/page/content emission tiers)
  - §4.5 Cross-Cutting Editorial Standards (Quote-Worthy Patterns + Translation Tier Rubric + Cannibalization Shield principle)
  - Quick wins: ≥8 Q&A floor, "🎯 จุดยืนของ {brand}:" Pattern E prefix, Organization member array

- 🔮 **Schema v1.11 deferred additions** (proposed, will lock with DR-020):
  - `seo_predicted_prompts` table (planning artifact)
  - `seo_ai_prompt_test_results` table (API testing execution log)
  - `page_master.translation_tier` column (text — for §4.5.2 enforcement)
- 📝 **Review cycle:** 4 weeks (until 2026-06-07) — paired with DR-019 lock cycle.
- 📝 **No DDL change for v1.0** — existing page_master columns suffice. Future template_id + template_version columns deferred to v1.1.
- 📝 **EEAT phase 2 hard-block targeted 2026-09-01** — prerequisite: ≥80% brand doctor onboarding to seo_authors.
- 📝 **Independent of DR-013/014** — different governance scope (content composition layer vs entity edge vocabulary layer).
- 📝 **Companion to DR-017/018/019** — together form complete content production stack.

### v1.5 (2026-05-10) — DR-019 Proposed (Schema Strategy Post-Rich-Results) 🌱

Triggered by Google announcement 2026-05-07 (FAQ rich results full deprecation effective June 2026, incl. gov/health carve-out) + multi-source verification (12+ industry sources confirm schema role shift from SERP-rendering to AI-extraction).

- ➕ **DR-019 (NEW, Proposed):** Schema Strategy for Post-Rich-Results Era. 4 sub-decisions to lock together: (1) Two-Purpose Taxonomy (serp/ai/forbidden), (2) Featured Snippet capture pattern, (3) KPI replacement (drop FAQ rich result impressions, add ai_citation_rate), (4) AggregateRating tightening (min 5 verifiable reviews).
- 📝 **Review cycle:** 4 weeks (until 2026-06-07) — final lock targeted **after** Google June 2026 effective date for behavioural confirmation.
- 📝 **No DDL change** — spec-level + plugin-level only (`eywa-schema-pipeline` enforces forbidden list).
- 📝 **Independent of DR-013/014** — different governance scope (schema emission layer vs entity edge vocabulary layer).

### v1.4 (2026-05-10) — DR-015..018 Locked (Sitemap Design Quality Gates) 🗺️🔒

Field-tested feedback from VTH BioDent surfaced 4 process gaps in the sitemap design layer (Phase E). All 4 DRs locked together, independent of DR-013/014 governance.

- ➕ **DR-015 (NEW, Locked):** Brand Scope Market Reconciliation Pattern — 3-axis scoring (Necessity / Brand-Fit / SEO Opportunity) for healthcare brands. Adds `marketplace_proposal_status` + `reconciliation_notes` to page_master.
- ➕ **DR-016 (NEW, Locked):** Page Viability Assessment / Thin Page Detection — 4-criteria gate + 5 exception clauses + HARD RULE (L4/L5 pillars never thin). Adds `viability_assessment` jsonb to page_master.
- ➕ **DR-017 (NEW, Locked):** Page Content Brief Field — REQUIRED for collapsed pages, RECOMMENDED otherwise. Adds `content_brief` text to page_master.
- ➕ **DR-018 (NEW, Locked):** Page Content Length Standards — 14 page types × Min/Target/Max word count, multilingual -20%. Spec-level only, no DDL.
- 🔄 Bible v3.13 → v3.14 (Sections 4.13, 4.14, 9.8 + §4.1 Phase 4.5 added)
- 🔄 Schema v1.9 → v1.10 (4 new page_master columns)
- 🔄 New migrations: 007_add_content_brief.sql, 008_add_sitemap_design_columns.sql

### v1.3 (2026-05-09) — DR-013 + DR-014 Proposed (Field-Tested Feedback) 🌱

Companion to ongoing VTH BioDent EGP work. **Tests DR-012 governance for first time** — DR-013 is the inaugural proposed addition under DR-012's 4-criteria + 2-week review process.

- ➕ **DR-013 (NEW, Proposed):** Edge Vocabulary v3.5 Expansion — proposes adding `causes/caused_by` + `contraindicates` edges (10 → 12 vocabulary). Source: Stream B work order from VTH BioDent field work.
- ➕ **DR-014 (NEW, Proposed):** Concept Entity Subtype Lock — proposes controlled vocabulary `framework` + `axis` for `entity_subtype` on `entity_type='concept'`.
- 🔄 **Future placeholder renumbering:** DR-013..DR-024 → DR-015..DR-026 (preserves topic continuity).
- 🎯 **Status:** BOTH DRs Proposed (NOT Locked). Schema Review Board target: 2026-05-15. Lock target: 2026-05-20 (if all 4 DR-012 criteria met).
- ⚠️ **Critical path:** C2 (cross-brand applicability) requires canvass of 14 other brands by 2026-05-13. If only VTH BioDent has cases → DR-013 should reject + use brand_scope workaround.
- 📦 **Future Bible v3.14 + Schema v1.10:** Build only triggers AFTER DR-013/014 lock. v3.13/v1.9 remain canonical until then.
- 🔗 References: Bible v3.13 §2.7.5 (DR-012 governance), Schema v1.9 §4.5 (current edge constraint), Stream B work order.

### v1.2 (2026-05-08) — EUG + Edge Evolution Policy Added 🛡️🔄

- ➕ **DR-011 (NEW):** Entity Uniqueness Guard (Two-Wave) — algorithmic enforcement of "Search Before Create" discipline
- ➕ **DR-012 (NEW):** Edge Vocabulary Evolution Policy — formal addition workflow + parking lot + anti-patterns
- 🔄 Renumbered placeholder DRs: old DR-011..DR-022 → DR-013..DR-024 (preserves topic context)
- 🔗 Cross-references to Bible v3.13 (Sections 2.6.6.1, 2.6.6.2, 2.7.5)
- 🔗 Cross-references to Schema v1.9 (Appendix G — EUG Implementation)

### v1.1 (2026-05-08) — Phase 1 Foundation DRs

- ➕ **DR-007:** In-Place GTGT Schema Upgrade (operational strategy)
- ➕ **DR-008:** Two-Column Identity Pattern (immutable fingerprint + mutable display)
- ➕ **DR-009:** Multilingual Strategy v2 (Two-Tier Pattern — concept vs content)
- ➕ **DR-010:** Brand Scope Architecture (canonical brand_slug)

### v1.0 (2026-05-07) — Initial Release

- ➕ DR-001: Multi-Brand Federation Pattern
- ➕ DR-002: Elementor Pro + Hello Theme Stack
- ➕ DR-003: Single Entity, Multilingual Labels Pattern
- ➕ DR-004: URL Structure (Subdirectory + Thai Default)
- ➕ DR-005: GitHub Distribution Strategy
- ➕ DR-006: Two-Phase Hierarchy Sync Pattern

---

*This document is part of the EYWA Protocol governance suite. For updates, see GitHub: `the-gifted-digital/eywa-protocol-spec/DECISION_RECORDS.md`*
