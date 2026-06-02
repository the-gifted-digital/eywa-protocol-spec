# 🌿 {Brand Display Name} — EYWA Brand Repo

> **{Brand tagline_th or tagline_en}**

**Brand ID:** `{brand-id}`
**Vertical:** {vertical_family} ({positioning_tier})
**EYWA Protocol:** v3.23 / Schema v1.20 / Content_Templates v1.8 / Handover v1.18 / DR v1.20
**Engagement:** {LEAD | NEGOTIATING | CLOSED} {YYYY-MM-DD if known}

---

## 📂 Folder Map

```
eywa-{brand-id}/
├── README.md                    ← this file
├── brand-config.json             ← Federation config (read first)
│
├── docs/                         📚 Brand documentation
│   ├── brand-concept.md          ⭐ READ FIRST — full brand identity (Phase A output)
│   ├── decision-records.md       brand-specific DRs (per Handover §9.1 Path 1)
│   ├── changelog.md              brand version history
│   └── signature-programs/       per-signature deep-dive docs (if applicable)
│
├── content-plan/                 🌳 STAGE 1 Planning (markdown)
│   ├── keyword-seed-list.md      (Phase B — DR-022 lean dump, no DFS)
│   ├── competitor-scan.md        (Phase B — WebSearch breadth)
│   ├── citation-pool-seed.md     (Phase B — 5-15 sources per pillar)
│   ├── patient-journey.md        (Phase B — audience research)
│   ├── entities.md               (Phase C — entity graph)
│   ├── clusters.md               (Phase C — topic clusters)
│   ├── relationships.md          (Phase C — edge wiring)
│   ├── sitemap.md                (Phase E — Layer 1 + Layer 2)
│   ├── gap-report.md             (Phase E.refine — post-enrichment, auto-generated)
│   └── archive/                  (frozen earlier drafts)
│
├── content-drafts/               📝 STAGE 2 Drafting (per template_id)
│   ├── pillar-pages/
│   ├── supporting-pages/
│   └── citations/
│
├── content-published/            📦 Phase G snapshots (deploy archive)
│
├── theme/                        🎨 Brand visual assets
│   ├── brand-assets/             (logos, colors, fonts)
│   ├── custom-css/               (brand-specific overrides)
│   └── elementor-templates-overrides/
│
├── deployment/                   🚀 Infra config
│   └── acf-overrides/
│
├── multilingual/                 🌐 Translation work (if active_languages > 1)
│
└── reports/                      📊 Analysis outputs + audits
```

> 🌿 **Flexibility:** This is the baseline structure. Brand may add/omit folders per real needs — log brand-specific structure decisions in `docs/decision-records.md`. See `eywa-protocol-spec/templates/NEW_BRAND_BOOTSTRAP.md` §"Flexibility Clause."

---

## 🎯 Quick Start

1. **Read brand context:**
   - `docs/brand-concept.md` — full brand identity
   - `brand-config.json` — federation config + signature offerings

2. **Check current Stage** (per Handover §7.1):
   - Phase A (Brand Understanding) → `docs/brand-concept.md` complete?
   - Phase B (Lean Research, DR-022) → 4 files in `content-plan/`?
   - Phase C (Entity Genesis) → `entities.md` / `clusters.md` / `relationships.md`?
   - Phase E (Sitemap) → `sitemap.md` reviewed by client?
   - Stage 1.5 (Supabase migration) → DB synced?
   - Stage 2 (Content Production) → `content-drafts/` populated?

3. **Reference EYWA Spec:**
   - Open workspace: `eywa-{brand-id}.code-workspace` (sees both spec + this repo)
   - Read `EYWA_HANDOVER.md` Section 7 (Stage 1 → 1.5 → 2 workflow)

---

## 🔑 Hero Service

**{Hero service name}** — {one-line description, e.g., "starting price + warranty"}

{Add 3-5 bullet points highlighting why this is hero — quality, pricing, signature differentiator}

---

## 👥 Founders / Clinical Lead

| Name | Role | Credentials |
|------|------|-------------|
| **{Name in TH}** | {Title} | {1-2 line summary of credentials} |

---

## 📍 Branches

- **{Branch Name}** — {Address or transit reference}

---

## 📅 Engagement Status

```yaml
deal_status: {LEAD | NEGOTIATING | CLOSED}
deal_closed_date: {YYYY-MM-DD or null}
monthly_rate: {amount THB or TBD}
website_state: {greenfield | near_empty | partial | mature}
rebuild_required: {true | false}
```

---

## ⏭ Pending Actions (operator)

{List 3-7 specific items operator needs to provide or decide — e.g., doctor credentials, branch addresses, brand inventory, technology list, FB sub-brand strategy}

See `docs/brand-concept.md` §"Open Questions" for full list.

---

## 📚 Key References

- **EYWA Spec:** `repos/eywa-protocol-spec/` (open via workspace)
- **Bootstrap template:** `repos/eywa-protocol-spec/templates/NEW_BRAND_BOOTSTRAP.md`
- **Similar brand (reference):** {e.g., `eywa-smile-scape/` for dental-implant clinic}
- **Memory:** `~/.claude/projects/-Users-nn-CLAUDE-AI/memory/project_{brand}.md`

---

*Initialized {YYYY-MM-DD} via `templates/NEW_BRAND_BOOTSTRAP.md` v1.0*
