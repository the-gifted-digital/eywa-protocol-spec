# 🌱 EYWA Brand Bootstrap Templates

> **Baseline templates for spinning up a new brand repo within the EYWA portfolio.**
> **Goal:** zero → Phase A ready in ~15 minutes.

---

## What's in this folder

```
templates/
├── README.md                          ← this file (orientation)
├── NEW_BRAND_BOOTSTRAP.md             ⭐ START HERE — step-by-step checklist
├── brand-config.template.json         (federation config template — Bible §25.6)
├── README.template.md                 (brand repo README template)
└── folder-skeleton/                   (copy this whole tree into new brand repo)
    ├── docs/
    │   ├── brand-concept.template.md       (Phase A — brand identity)
    │   ├── decision-records.template.md    (brand-specific DRs per §9.1 Path 1)
    │   ├── changelog.template.md           (audit trail)
    │   └── signature-programs/             (per-signature deep dives, optional)
    │
    ├── content-plan/                  (Stage 1 — Phase B-E markdown outputs)
    │   ├── keyword-seed-list.template.md          (Phase B — DR-022)
    │   ├── competitor-scan.template.md            (Phase B — DR-022)
    │   ├── citation-pool-seed.template.md         (Phase B.2 — Bible §23.1)
    │   ├── patient-journey.template.md            (Phase B — DR-022)
    │   └── archive/                               (frozen earlier drafts)
    │
    ├── content-drafts/{pillar-pages, supporting-pages, citations}/
    ├── content-published/                          (Phase G snapshots)
    ├── theme/{brand-assets, custom-css, elementor-templates-overrides}/
    ├── deployment/{acf-overrides/}
    ├── multilingual/
    └── reports/
```

---

## Quick Start

1. **Read** `NEW_BRAND_BOOTSTRAP.md` (full checklist, ~15-min process)
2. **Copy** `folder-skeleton/` contents into your new brand repo
3. **Customize** `brand-config.json` + `README.md` + `docs/brand-concept.md`
4. **Commit** initial bootstrap

---

## Flexibility Clause 🌿

Templates are **baselines**, not strict cages. Each brand may:

- ✅ ADD brand-specific files for real production needs
- ✅ OMIT non-applicable files (e.g., single-language brands skip `multilingual/`)
- ✅ CREATE custom subfolders under existing folders

**Core 4 are required** (federation contracts):

- `brand-config.json`
- `docs/brand-concept.md`
- `docs/decision-records.md`
- `docs/changelog.md`

Log any structural deviation in `docs/decision-records.md` as a brand DR.

---

## When to Update These Templates

If you find the SAME manual fix across multiple brand bootstraps, that's a signal to update the template. Propose via DR:

```
Title: Bootstrap Template Update — {what changed}
Status: Proposed
Rationale: Observed in 3+ brand bootstraps (list them)
```

---

## Reference Implementations

- **Full bootstrap example:** `eywa-vth-biodent/` (Stage 1 done)
- **Fresh DR-022 field test:** `eywa-smile-scape/` (Stage 1 Phase E)

---

## Versioning

| Templates Version | Date | Aligns With |
|------------------|------|-------------|
| 1.0 | 2026-05-11 | Bible v3.14 / Schema v1.10 / Handover v1.8 / DR v1.8 (incl. DR-022 Proposed) |

---

*See `EYWA_HANDOVER.md` §1 Project Setup Checklist + §5.11 Per-Brand Folder Structure for spec context.*
