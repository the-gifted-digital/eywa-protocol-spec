# {Brand Display Name} — Brand Repo Changelog

> **Append-only log of significant brand repo events.** Per Handover §9.3, every Stage gate + DR adoption should appear here.

**Format:** Reverse chronological (newest first)

---

## [{YYYY-MM-DD}] — Brand Bootstrap

Initialized eywa-{brand-id} repo from `templates/folder-skeleton/` baseline.

**Files created via template:**
- `README.md` — brand overview (from `templates/README.template.md`)
- `brand-config.json` — federation config (from `templates/brand-config.template.json`)
- `docs/brand-concept.md` — Phase A scaffold (from template)
- `docs/decision-records.md` — empty DR log (from template)
- `docs/changelog.md` — this file (from template)

**Folder structure created:**

```
docs/{signature-programs/}
content-plan/{archive/}
content-drafts/{pillar-pages, supporting-pages, citations}/
content-published/
theme/{brand-assets, custom-css, elementor-templates-overrides}/
deployment/{acf-overrides/}
multilingual/
reports/
```

**Spec snapshot pinned (per Handover §9.3):**

```yaml
bible: v3.26
schema: v1.21
templates: v1.8
handover: v1.18
decision_records: v1.22
drs_locked: 33 (DR-001..022 + 024/025/028..036)
drs_proposed: 1 (DR-026)
drs_opted_in_early: [] (or list if any)
snapshot_taken_at: {YYYY-MM-DD}
snapshot_taken_at_stage: Stage 1 Phase A entry
```

**Stage status (per Handover §7.1):**

- Phase A (Brand Understanding): 🟡 IN PROGRESS — `brand-concept.md` scaffold ready, content fill needed
- Phase B (Lean Research, DR-022): ❌ NOT STARTED
- Phase B.2 (Citation Pool Seeding): ❌ NOT STARTED
- Phase C (Entity Genesis): ❌ NOT STARTED
- Phase D (Cluster & Domain): ❌ NOT STARTED
- Phase E (Sitemap): ❌ NOT STARTED
- Stage 1 Gate: ❌ NOT REACHED
- Stage 1.5 Migration: ❌ blocked (DR-021 lock 2026-06-07)
- Stage 2 Content Production: ❌ NOT STARTED

**Pending operator actions:**

{Fill in 3-7 brand-specific items operator needs to provide before Phase A can complete}

1. {e.g., Founder credentials + photos}
2. {e.g., Branch addresses + phone numbers}
3. {e.g., Existing logo + brand assets}
4. {e.g., Service inventory completeness check}
5. {e.g., Pricing tier confirmation}

---

*Initialized {YYYY-MM-DD} by {Operator name / Architect}. See `eywa-protocol-spec/templates/NEW_BRAND_BOOTSTRAP.md` for replication steps.*

---

## Future Entry Triggers

Per Handover §9.4, add entries here when:

- Stage gate reached (Stage 1 / Stage 1.5 / Stage 2)
- DR adopted (universal DR opted-in OR new brand DR locked)
- Major sitemap restructure
- Migration completed (markdown → Supabase)
- First content batch deployed
- Brand voice / positioning shift
- Engagement status change (LEAD → CLOSED, etc.)
- Spec snapshot re-pinned
