# Proposal — Service-First & Compliance-First Stage-1 (lessons from Nobel Site A)

> **Status:** 🟡 Proposed — for protocol-team review. **Not locked; creates no DRs by itself** (candidate DRs listed in §7 for the owner to number, to avoid collisions like the DR-038/040 incident).
> **Provenance:** Stage-1 (content + SEO) engagement for **Nobel Longevity & Wellness** — Site A of a two-site model (`repos/brands/eywa-nobel-clinic/`). Ultra-premium longevity clinic, YMYL, Thai market (สบส./อย.).
> **Author:** S1 clinic session · **Date:** 2026-07-19 · **Applies to:** Bible §7 (Phase workflow), Schema (new fields), Templates (new artifacts).
> **Goal:** the next brand using the protocol **does not repeat these mistakes** and can lift the checklist in §8 as-is.

---

## 0. The meta-insight (read this first)

The protocol's Stage-1 runs **keyword-first**: Phase B seeds keywords → Phase C builds the entity/architecture → Phase E sitemaps. On Nobel that ordering caused avoidable rework, because a real medical/wellness business is **service-first and compliance-first**:

- The **real service menu** (what actually drives keywords, pages, and money) lived in operator **posters/brochures**, not in keyword tools. It surfaced *during* architecture and forced a major revision (6 → 8 pillars, a whole hormone line, ~48 peptides, a diagnostics pillar).
- **Regulatory status** (what may even be published) is a property of each *service*, and it gated ~40% of pages. Discovered reactively, page by page.

**Proposed corrected Stage-1 order:**
`service inventory (+compliance class) → keyword discovery (service-driven) → architecture (+funnel role) → citation (role-separated, verified) → sitemap`

Everything below operationalizes that sentence. Five of the seven items trace back to it.

---

## 1. TL;DR — lessons → changes

| # | Lesson | Symptom on Nobel | Proposed change | Phase | Federation |
|---|--------|------------------|-----------------|-------|-----------|
| P1 | Inventory before architecture; ingest visual assets | 48 peptides / hormone line / diagnostics surfaced mid-Phase-C from posters → big rev | `service-inventory.md` = mandatory Phase A/B artifact; ingest posters/brochures/decks | A/B | any operator-asset brand |
| P2 | Compliance is a per-service attribute + reusable jurisdiction ruleset | ~40% of pages legal-gated, found reactively | `publish_status`/`regulatory_class` per service from inventory; ship a **TH medical-ad ruleset module** | A→E | ⭐ all TH medical brands |
| P3 | "Exists ≠ marketable" — service marketability triage | GH-for-children: real service, indefensible marketing | 3-axis triage: indication × claim × clinical-governance | A/B | all medical/aesthetic |
| P4 | Citations have two roles; verify at seed | founder's mobile-app RCT nearly cited as stem-cell proof | `citation_role = authority \| claim-backing`; PubMed-verify at seed | B.2 | all YMYL |
| P5 | Keywords are service-driven → re-run after inventory; standard S1→S0 proposal | hormone ~13k & diagnostics ~37k clusters missed in first pass | 2nd keyword pass post-inventory; ship `s0-keyword-proposal.md` template | B/D | multi-site / governance-split |
| P6 | Structural attributes the model lacks | diagnostics-as-entry, pricing-as-sink had no home | add `funnel_role` (pillar) + `data_provenance` (any node) | C/E | all service brands |
| P7 | Match claim strength to evidence | most peptides lack RCTs | rule: evidence < tier ⇒ investigational framing, mechanism-only cites | B.2/F | all YMYL |

---

## 2. P1 — Service inventory before architecture (ingest visual assets)

**Symptom.** Phase B keyword matrix implied ~6 topics. The operator's posters/brochures revealed a far larger menu — CartilageCure®/Neurogenic/Vasculogenic MSC, FRESH MSCs®, exosome menu, Dermal Cell/ExoDerm, **5-product placenta hormone line**, NAD⁺/resveratrol IV, and a **~48-peptide, 8-category brochure**. It appeared mid-Phase-C and forced architecture Rev 2.

**Root cause.** Protocol has no first-class "what does this clinic actually sell" artifact, and doesn't require ingesting non-text operator material.

**Change.** Make `service-inventory.md` a **required Phase A/B deliverable, gated before Phase C**. It must be built by reading operator source material **including images/PDFs** (posters, brochures, credential decks). Reference implementation: `eywa-nobel-clinic/content-plan/service-inventory.md`.

**Use immediately.** Before any pillar work: list every service the operator offers, grouped, each with source + provenance (§6) + compliance class (§2/P2).

---

## 3. P2 — Compliance as a per-service attribute + reusable jurisdiction ruleset ⭐

**Symptom.** Legal-gates were discovered one page at a time: unapproved peptides (retatrutide, MK-677, LGD-4033…), growth hormone, testosterone/TRT, disease-indication MSC (Parkinson/Alzheimer/cardiac), NK-exosome (cancer-adjacent), GH-for-children. ~40% of the sitemap ended `blocked_pending_legal`.

**Root cause.** Compliance treated as a Phase-E gate checklist, not as an attribute that travels with each service from the moment it enters the inventory.

**Change.**
1. Add `publish_status ∈ {clear, blocked_pending_legal, escalate, dropped}` and `regulatory_class` to each service/page, **set at inventory time**.
2. Ship a reusable **Thai medical-advertising ruleset module** (สบส. + อย.): unapproved-substance list, prohibited claim register ("รักษาหาย/ย้อนวัย/cure"), disease-indication rules, prescription-drug advertising rules. Brands in the same market **reuse it** rather than rediscovering.

**Federation.** Highest-value item here — one ruleset amortizes across every TH medical brand. Compounds like the citation pool.

**Use immediately.** Tag every inventory line 🟢/🔴/🔴🔴 on entry. Never let SEO opportunity override a 🔴 (see `eywa-nobel-clinic` `seo-governance.md §5`).

---

## 4. P3 — "Exists ≠ marketable": service marketability triage

**Symptom.** BioHGH is a real service, and the poster marketed it for **children's height**. Real-world check showed: legitimate only as pediatric-endocrine *disease* treatment; the "make your kid taller" angle is publicly condemned + a clear regulatory red line. First instinct (drop) and operator instinct (keep for completeness) were both partly right — the resolution was a **reframe + hard gate**, not a binary.

**Root cause.** No framework separating "the clinic offers X" from "X is marketable/publishable, and how."

**Change.** A 3-axis triage per service:
- **Indication legitimacy** — is there a defensible medical indication (vs lifestyle/vanity)?
- **Claim wording** — can it be framed without prohibited/deterministic claims?
- **Clinical governance** — is it delivered under appropriate supervision?
Pass all → build. Fail one → held/reframed/dropped with the reason logged. Outcome states: `compete | include-non-targeted | held | dropped`.

**Use immediately.** For any service that feels edgy, run the three questions before writing a single page.

---

## 5. P4 — Citations have two roles; verify at seed

**Symptom.** A founder credential (PMID 34453570) was earmarked to back the knee stem-cell page. PubMed verification showed it's a **mobile-app exercise RCT**, not a stem-cell trial — valid as author-credential, invalid as clinical proof. Conflating them would have been a YMYL accuracy failure shipped to a medical page.

**Root cause.** Citation schema doesn't distinguish **authority/E-E-A-T citations** (this author is credible) from **claim-backing citations** (this claim is true), and verification happens late.

**Change.**
1. Add `citation_role ∈ {authority, claim-backing}` to the citation schema; a claim may only be backed by `claim-backing` cites at the required tier.
2. **Verify every seed citation against source (PubMed/DOI) at seed time**, not at publish.

**Use immediately.** When seeding, ask of each cite: "does this prove the *claim*, or just establish the *author*?" File accordingly. Reference: `eywa-nobel-clinic/content-plan/citation-pool-seed.md` (§0 authority vs §2 claim-backing, with the correction logged).

---

## 6. P5 — Keywords are service-driven → 2nd pass + standard S1→S0 proposal

**Symptom.** The first keyword pass missed the two biggest clusters — **hormone (~13k/mo, women+men)** and **diagnostics/ตรวจ (~37k/mo)** — because they only became obvious once the real services were known. In a governance-split model (S0 owns the matrix), S1 could not add them and had to hand-roll a proposal artifact.

**Root cause.** Keyword discovery runs once, before services are fully known; no standard channel for S1 to propose matrix changes.

**Change.**
1. Mandate a **second keyword pass after the service inventory** (services → keyword clusters), with per-cluster competitor validation (cheap, high-value; run when a cluster is *proposed*, not only up front).
2. Ship `s0-keyword-proposal.md` as a **standard template** for the S1→S0 channel (proposed rows + volumes + intent + boundary check). Reference: `eywa-nobel-clinic/content-plan/s0-keyword-proposal.md`.

**Use immediately.** After inventory, re-derive keywords *from the service list*; diff against the matrix; propose the gap.

---

## 7. P6 — Structural attributes the model lacks

**Symptom.** Diagnostics is structurally an **entry/lead-gen** node (test → plan → treat) and pricing is a **conversion sink** — the pillar model (topical hub only) had no way to express that, so their funnel roles were implicit. Separately, the diagnostics menu had to be scaffolded from competitor data before operator confirmation, with no standard way to mark "this is a placeholder."

**Change.**
- Add `funnel_role ∈ {entry, hub, conversion-sink, authority}` to pillars.
- Add `data_provenance ∈ {operator-confirmed, competitor-derived, inferred}` to any node — lets planning proceed on flagged placeholders without fabrication. Reference: `eywa-nobel-clinic/content-plan/content-architecture.md §1b` (competitor-derived diagnostics menu, clearly flagged).

**Use immediately.** Label each pillar's funnel role; mark any non-operator-confirmed content as `competitor-derived`/`inferred`.

---

## 8. P7 — Match claim strength to evidence (research-stage honesty)

**Symptom.** Most menu peptides have no RCT-grade human evidence for the marketed use. The temptation is to cite *something*.

**Change / rule.** If a service's evidence is below the required tier: **frame as investigational, cite mechanism only, do not seed efficacy citations that can't be defended.** Encode as a Phase B.2 / Phase F rule.

**Use immediately.** No efficacy citation you wouldn't defend to a regulator. Investigational service → say so.

---

## 9. Proposed revised Stage-1 sequence (diagram)

```
Phase A  Brand + OPERATOR-ASSET INGEST → service-inventory.md (+compliance class, +provenance)   [P1,P2]
Phase B  Keyword pass 1  →  (inventory)  →  Keyword pass 2 (service-driven) + per-cluster competitor check   [P5]
         Marketability triage on edgy services  [P3]
Phase B.2 Citation seed — role-separated + PubMed-verified-at-seed; evidence-matched framing   [P4,P7]
Phase C  Architecture — pillars carry funnel_role   [P6]
Phase E  Sitemap — publish_status per page drives the "publish-first wave"; gated pages drafted, not shipped   [P2]
```

---

## 10. Candidate DRs (for owner to number — do not self-assign)

- **[Proposed] Service Inventory as a gated Phase-A/B artifact (incl. visual-asset ingest).**
- **[Proposed] Per-service `publish_status`/`regulatory_class`; jurisdiction ruleset module (TH สบส./อย. first).**
- **[Proposed] Service marketability triage (indication × claim × governance).**
- **[Proposed] `citation_role` split + verify-at-seed.**
- **[Proposed] Second, service-driven keyword pass + `s0-keyword-proposal` template.**
- **[Proposed] `funnel_role` (pillar) + `data_provenance` (node) attributes.**
- **[Proposed] Evidence-matched claim rule for research-stage services.**

## 11. Reusable assets to promote (reference implementations in Nobel repo)

| Asset | Path (`repos/brands/eywa-nobel-clinic/`) | Promote to |
|-------|------------------------------------------|-----------|
| Service inventory | `content-plan/service-inventory.md` | Templates |
| S1→S0 keyword proposal | `content-plan/s0-keyword-proposal.md` | Templates |
| Citation pool (role-separated) | `content-plan/citation-pool-seed.md` | Templates |
| Sitemap w/ viability + publish_status | `content-plan/sitemap.md` | Schema/Templates |
| Two-site intent-boundary discipline | `nobel-longevity-shared/governance/seo-governance.md` | Bible (multi-site) |

---

## 12. Next-brand quick-start checklist (usable now, pre-adoption)

1. **Inventory first.** Read *all* operator material incl. images/PDFs → list every service, grouped.
2. **Tag compliance on entry.** 🟢 clear / 🔴 legal-gate / 🔴🔴 escalate. SEO never overrides 🔴.
3. **Triage edgy services.** indication × claim × governance → compete / include-non-targeted / held / dropped.
4. **Keywords from services.** Re-derive clusters from the inventory; competitor-check each; propose matrix gaps via the S1→S0 template.
5. **Funnel roles.** Mark entry (assessment/lead magnet), hubs, conversion-sink (pricing), authority (about).
6. **Cite honestly.** Separate author-credential from claim-backing; verify at seed; investigational = say so.
7. **Flag placeholders.** `competitor-derived`/`inferred` until the operator confirms; never present as fact.
8. **Sequence the sitemap by publish_status.** Ship the clear pages as a "publish-first wave"; draft gated pages in parallel; nothing 🔴 goes live pre-legal.

---

*Proposed 2026-07-19 from the Nobel Site A engagement. Additive proposal — touches no locked spec file. Numbers/DR assignment at the protocol owner's discretion.*
