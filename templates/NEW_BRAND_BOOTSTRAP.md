# 🌱 New Brand Bootstrap Checklist

> **Goal:** Spin up a new brand repo from zero to **Phase A ready** in ~15 minutes.
> **Companion to:** `EYWA_HANDOVER.md` §1 Project Setup Checklist + §5.11 Per-Brand Folder Structure.

---

## Flexibility Clause 🌿

This checklist is the **baseline standard**, not a strict cage. Each brand may:

- ✅ **ADD brand-specific files** if they serve real production needs (e.g., `docs/oem-supplier-catalog.md` for a brand that imports devices, or `content-plan/promo-calendar.md` for a brand with seasonal campaigns)
- ✅ **OMIT non-applicable files** (e.g., a single-branch brand may skip `docs/branches.md` and put info inline in brand-concept)
- ✅ **CREATE custom subfolders** under existing folders (e.g., `docs/regulatory/` for a brand under FDA scrutiny)
- ❌ **DO NOT skip the core 4** (they are spec contracts):
  - `brand-config.json` (federation key)
  - `docs/brand-concept.md` (Phase A deliverable)
  - `docs/decision-records.md` (brand-specific DRs per Handover §9.1 Path 1)
  - `docs/changelog.md` (audit trail)

If unsure whether to add or omit, log the decision in `docs/decision-records.md` as a brand-specific DR (e.g., `{BRAND}-DR-001: Skip multilingual/ folder until language expansion approved`).

---

## Pre-Bootstrap

```yaml
prerequisites:
  ☐ Brand identified + brand_id chosen (kebab-case, e.g., "tc-smile", "smile-scape")
  ☐ Brand structure decided 🆕 v1.18 (DR-032): monolithic | multi_center
                    # monolithic = 1 brand = 1 WP site, no center subdivision (90%+ of portfolio)
                    # multi_center = 1 brand = umbrella + N productized centers as URL subdirectories
                    # See Step 1.5 below + EYWA_HANDOVER.md v1.18 Note for decision criteria
  ☐ Repo created on GitHub: github.com/the-gifted-digital/eywa-{brand-id}
  ☐ Local clone exists at /Volumes/SSD NN/CLAUDE AI/repos/brands/eywa-{brand-id}/
  ☐ Operator has access to brand source materials (if any — concept docs, existing site, brand book)
```

---

## Step-by-Step (15 minutes)

### Step 1 — Copy folder skeleton (~1 min)

```bash
cd "/Volumes/SSD NN/CLAUDE AI/repos/brands/eywa-{brand-id}"
cp -r ../../eywa-protocol-spec/templates/folder-skeleton/. .
```

This creates: `docs/` (with signature-programs/), `content-plan/` (with archive/), `content-drafts/{pillar-pages, supporting-pages, citations}/`, `content-published/`, `theme/{brand-assets, custom-css, elementor-templates-overrides}/`, `deployment/acf-overrides/`, `multilingual/`, `reports/`.

**Optional folders to remove if not needed:**
- `multilingual/` — only TH brand → safe to keep empty (no harm)
- `theme/elementor-templates-overrides/` — only if brand will customize global Elementor templates
- `deployment/acf-overrides/` — only if brand needs custom ACF beyond GTGT defaults
- `deployment/cloudflare/r2-media.template.md` 🆕 v1.4 — **Astro / Cloudflare brands only** (DR-040 + DR-035 + DR-038): per-brand R2 bucket `{brand-slug}-media` + object-key/folder naming + delivery. Copy → rename to `r2-media.md` → fill placeholders. **WP brands skip** (WordPress serves its own media).
- `docs/heading-semantics-conformance.template.md` 🆕 v1.5 — **EVERY brand, both stacks** (DR-041 / Bible §9.9): per-brand heading + landmark conformance record. Copy → rename to `heading-semantics-conformance.md` → fill the component→level inventory + per-release verification log + brand-choice deviations. Points at §9.9 (doesn't restate the rules); re-run the checklist each release.

### Step 1.5 — Decide `brand_structure` 🆕 v1.8 (DR-032 Locked 2026-05-25)

**Every new brand MUST pick one of two structures at bootstrap time.** This decision drives subsequent Steps 2-6 + sitemap design (Phase E) + WordPress permalink architecture.

```yaml
choose_monolithic_if:
  - 1 brand = 1 specialty / 1 audience persona / 1 voice
  - No need to surface internal divisions as URL subdirectories
  - DEFAULT for 90%+ of EYWA portfolio (vth-biodent, smile-scape, the-face-by-vertex, hp100, etc.)
  
  → Continue with Step 2 baseline (no extra folders needed)

choose_multi_center_if:
  - Brand is a HOSPITAL with multiple productized centers under one umbrella
  - "One roof, one record, one team" doctrine (centers share patient record / EHR / MDT)
  - Locked vocabulary across centers (master glossary; no center invents parallel terms)
  - URL pattern requires subdirectories per division (e.g., domain.com/center1/, domain.com/center2/)
  - First adopter: vitality-hospital (7 productized centers under Vitality umbrella)
  
  → Continue with Step 2 + add multi-center additions (see below)
```

**See `EYWA_HANDOVER.md` v1.18 Note + DECISION_RECORDS.md DR-032 for full decision criteria + counter-cases (when NOT to pick multi_center).**

**If multi_center, additional setup required (after Step 4):**

```bash
# Create per-center folder structure
mkdir -p docs/centers
mkdir -p content-plan/sitemap-centers

# For each center, create:
mkdir -p docs/centers/{NN}-{center-slug}
# e.g.,
mkdir -p docs/centers/01-{first-center-slug}
mkdir -p docs/centers/02-{second-center-slug}
# ... one per center

# Create per-center concept doc placeholder per center:
# docs/centers/{NN}-{center-slug}/concept.md
# Create per-center sitemap placeholder per center:
# content-plan/sitemap-centers/{center-slug}.md
```

**Multi-center sitemap split (Phase E):**
- `content-plan/sitemap.md` becomes the **MASTER INDEX** (not a direct page list) — cross-cutting rules, sub-gate strategy, page count summary
- `content-plan/sitemap-hospital-wide.md` — pages with `center_slug=NULL` (umbrella pages: Home, About, Concept hubs, Membership, Outcomes, Press, institutional)
- `content-plan/sitemap-centers/{center-slug}.md` × N — per-center page hierarchies (`center_slug={center}`)
- `content-plan/internal-linking-plan.md` — cross-center funnels (default approved) + cross-brand network links (DR-021 governed)

**Reference implementation:** see `eywa-vitality-hospital/` (7 centers, single WP site, subdirectory pattern).

### Step 2 — Copy + customize brand-config.json (~5 min)

```bash
cp ../../eywa-protocol-spec/templates/brand-config.template.json brand-config.json
```

Then edit `brand-config.json`:

```yaml
required_fields_to_replace:
  ☐ brand_id, brand_name, brand_name_translations.th + en
  ☐ domain
  ☐ vertical_family + healthcare_format + positioning_tier
  ☐ brand_structure 🆕 v1.18 (DR-032) — 'monolithic' (DEFAULT) or 'multi_center' per Step 1.5 decision
  ☐ brand_concept (tagline_th, tagline_en, core_positioning, tone, persona)
  ☐ signature_offerings[] (at least 1 — hero service)
  ☐ specialty_focus[] (at least 1)
  ☐ branches[] (at least 1)
  ☐ schema_org_type
  ☐ engagement.deal_status (LEAD | NEGOTIATING | CLOSED | PAUSED)
  ☐ deployment.current_site_state
  ☐ metadata.created_at + last_updated_at
  ☐ eywa_spec_snapshot.snapshot_taken_at + snapshot_taken_at_stage

if_brand_structure_is_multi_center_also_required:
  ☐ centers[] — at least 1 center; populate per template doc (center_slug, center_name_th/en, url_segment, positioning_one_line, flagship_programs[], anchor_outcome, position_order, status='planning')
  ☐ parent_network (if brand belongs to a network/group like Vertex Hospital) — else leave null
  ☐ deployment.wordpress_pattern = 'single_site_multi_center_subdirectory'

optional_fields_keep_as_TBD_until_known:
  ☐ founders / clinical_team (if brand has dedicated section)
  ☐ founding_year, license_number, primary_address_th, primary_phone
  ☐ social_media URLs
  ☐ team_assignment.notion_workspace_url
```

### Step 3 — Copy + customize README.md (~2 min)

```bash
cp ../../eywa-protocol-spec/templates/README.template.md README.md
```

Edit `README.md` with brand-specific text (positioning, hero service, founders, branches, engagement status). See VTH BioDent or SmileScape README as reference.

### Step 4 — Initialize core docs (~5 min)

```bash
cp ../../eywa-protocol-spec/templates/folder-skeleton/docs/brand-concept.template.md docs/brand-concept.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/docs/decision-records.template.md docs/decision-records.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/docs/changelog.template.md docs/changelog.md
```

Fill `docs/brand-concept.md` skeleton with brand identity (vision, mission, positioning, values, hero service, signature techniques, founders, audience, voice). This is **Phase A output** — required before Phase B can start.

`docs/decision-records.md` starts empty (just header). Brand DRs accumulate as decisions emerge during work (per Handover §9.1 Path 1).

`docs/changelog.md` records this bootstrap as the first entry.

### Step 5 — Optional: copy Phase B planning templates (~2 min)

Only if starting Phase B in same session:

```bash
cp ../../eywa-protocol-spec/templates/folder-skeleton/content-plan/keyword-seed-list.template.md content-plan/keyword-seed-list.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/content-plan/competitor-scan.template.md content-plan/competitor-scan.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/content-plan/citation-pool-seed.template.md content-plan/citation-pool-seed.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/content-plan/patient-journey.template.md content-plan/patient-journey.md
```

These are the 4 Phase B output files per DR-022 (Lean Phase B).

### Step 6 — First commit (~1 min)

```bash
git add .
git commit -m "Brand bootstrap: eywa-{brand-id}

Folder skeleton + brand-config + core docs initialized from
templates/ baseline. Phase A brand-concept.md ready for editing.

Spec snapshot pinned: Bible v3.34 / Schema v1.23 / Templates v1.9
                      / Handover v1.19 / DR v1.27

Per Handover §9.3 — eywa_spec_snapshot block records this entry point.
Per DR-022 (Locked) — Lean Phase B workflow adopted from inception."

git push -u origin main
```

---

## Post-Bootstrap Verification

```yaml
sanity_checks_after_step_6:
  ☐ brand-config.json valid JSON (no trailing commas, no syntax errors)
  ☐ brand_id matches folder name + git remote
  ☐ docs/brand-concept.md has at least sections 1-3 filled (vision, mission, positioning)
  ☐ docs/changelog.md has bootstrap entry
  ☐ git push successful (visible on github.com/the-gifted-digital/eywa-{brand-id})
  ☐ eywa_spec_snapshot block has all 5 versions + snapshot_taken_at populated
  ☐ Memory updated: ~/.claude/projects/-Users-nn-CLAUDE-AI/memory/project_{brand}.md created (or noted in MEMORY.md)
```

---

## Common Pitfalls

| Pitfall | How to Avoid |
|---------|-------------|
| Skip brand-config and start writing content immediately | brand-config is federation contract — empty/wrong = downstream syncs break. Spend the 5 min. |
| Copy SmileScape's brand-config wholesale | Has SmileScape-specific blocks (SMILE DNA, Founders, Implant Brand Strategy) that don't apply to other brands. Use the **template**, not another brand's config. |
| Set deal_status="CLOSED" prematurely | Only set CLOSED when contract signed. Use LEAD/NEGOTIATING during sales pipeline. |
| Pin old spec versions in eywa_spec_snapshot | Always pin **current** versions at bootstrap time. Re-snapshot at each Stage gate, not retroactively. |
| Treat templates as immutable | Templates are baselines. If a brand needs a new field that 80% of brands would need, propose an update to `templates/brand-config.template.json` via DR. If only this brand needs it, add inline + log in brand DR. |

---

## Reference Examples

- **Full bootstrap (~13 sections, mature):** `eywa-vth-biodent/` — Stage 1 done, Phase 4.5 retrofit pending
- **Fresh bootstrap (recent):** `eywa-smile-scape/` — Stage 1 Phase E, DR-022 field test
- **Folder structure spec:** Handover §5.11
- **Spec snapshot semantics:** Handover §9.3
- **DR lifecycle:** Handover §9.1 (brand-specific Path 1 vs system-wide Path 2)

---

## When to Update This Template

If you find yourself doing the SAME manual fix on multiple brands during bootstrap, that's a signal to update the template. Open a DR proposal:

```
Title: Bootstrap Template Update — {what changed}
Status: Proposed
Rationale: Observed in 3+ brand bootstraps (list them) — repetition cost > template change cost
```

---

*Last updated: 2026-05-11 (templates v1.0 — initial release alongside DR-022 Proposed)*
