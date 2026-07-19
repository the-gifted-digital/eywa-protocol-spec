# Proposal — Authority/Media-Hub Archetype & De-Branded Property (lessons from Stem Cell Hub, Site B)

> **Status:** 🟡 Proposed — for protocol-team review. **Not locked; creates no DRs by itself** (candidate DRs listed in §11 for the owner to number, to avoid collisions like the DR-038/040 incident).
> **Provenance:** Stage-1 (content + SEO) engagement for the **de-branded Stem Cell Knowledge Hub** — Site B of a two-site model (`repos/brands/eywa-stemcell-web/`). Informational/authority hub, YMYL, Thai market, `vertical_family=other`.
> **Author:** S1 stem-cell hub session · **Date:** 2026-07-19 · **Applies to:** Bible §4 (sitemap), §2.6.6 (EUG), Part 23 (E-E-A-T/citations), Handover §7 (phases), Templates.
> **Goal:** the next brand building an **informational/authority-media property** on EYWA does not repeat this trial-and-error and can lift the checklists + reference files as-is.
> **Sibling proposal:** `2026-07-19-service-first-compliance-first.md` (Site A / clinic). Several items **converge** — see §10.

---

## 0. The meta-insight (read this first)

The protocol assumes **1 brand = 1 clinical/service provider**. This brand is the first **informational/authority-media property**: it sells nothing, is deliberately isolated from a commercial sibling, and exists to build citable authority. Almost every clinic-shaped default had to be re-typed or inverted:

- The **8-section sitemap** is provider-shaped (Services=Money, Technology=devices, Case-Studies=testimonials, Contact=branches). For an authority hub we drop/skip/re-type, and the **money hub disappears** — the content sections carry conversion.
- The **active layer set collapses** to L1/L4/L5/L7 (L2 Money / L3 Product / L6 Protocol = OFF).
- A **de-branded property paired with a commercial sibling** (shared expert, no `sameAs`, covert funnel) has real isolation + compliance rules the protocol never modelled.

**Proposed addition:** a first-class **"Authority/Media-Hub archetype"** alongside the clinic archetype, plus a **"Paired Isolated Properties"** pattern. Everything below operationalizes that.

---

## 1. TL;DR — lessons → changes

| # | Lesson | Symptom on Site B | Proposed change | Phase | Federation |
|---|--------|-------------------|-----------------|-------|-----------|
| B1 | "Paired Isolated Properties" (authority-hub ⇄ commercial sibling) | Invented SCW-DR-001..006 from scratch (no-fingerprint, shared-person-no-sameAs, covert funnel) | Codify the pattern + isolation checklist + ⚖️ covert-funnel compliance flag | A | ⭐ any media-arm+commercial-arm family |
| B2 | Authority/Media-Hub sitemap archetype | Clinic 8-section didn't fit; re-typed S4→L5, S7→evidence, dropped S3, L2/L3/L6 off | Positive archetype in Bible §4 w/ section-disposition + re-type rules | E | all publishers / education / authority hubs |
| B3 | S6 Knowledge = 4 content-types | Knowledge was a single bucket; missed freshness + entity + voice surfaces | Guides/Insights/Glossary/FAQ taxonomy + intra-S6 shield + freshness flywheel | E | content-heavy / GEO-AEO brands |
| B4 | YMYL case-study & evidence rules | "published"? case vs testimonial? sign-off scope? — all undefined | Bible-23 sub-section: published=indep-review; case≠testimonial; CSA≠legal | B.2/F | ⭐ all YMYL |
| B5 | Planning-time EUG + new-vertical-into-shared-graph | Ran EUG at planning; found shared graph is a *dental* vertical; no brand row | Planning-time reconciliation + `aliases` match + new-vertical guidance | C | any brand joining a shared graph |
| B6 | Negative-Scope Register | Had to record what B deliberately does NOT cover (peptide etc.) | Template: topic × why-off × narrow-allowance; "focus protects topical authority" | B/C | sibling-scoped or focus-disciplined brands |
| B7 | Viability rationale: authority/internal-link (no volume) | S4 built for link-density with zero KW volume — no gate category | Add "authority/internal-link" as a legit viability rationale | E | any topical-authority scaffolding |
| B8 | Citation anti-padding + vertical-scoped search | Exosome 5th: only plant/aesthetic papers surfaced → refused to pad | Gate = "≥5 OR documented shortfall + evidence"; scope search to vertical | B.2 | all YMYL (converges w/ Site A P4/P7) |
| B9 | Upward governance-proposal channel | Found matrix-worthy KWs but matrix is S0-locked → risk of loss | Standard `governance-proposals.md` (S1/S2→S0) | any | multi-site / governance-split (converges w/ Site A P5) |

---

## 2. B1 — "Paired Isolated Properties" pattern ⭐ (High)

**Symptom.** A de-branded informational hub paired with a commercial clinic sibling: shares one expert (a scientist) but **no `sameAs`**, no cross-link, no shared fingerprint (design / GA4 / GTM / GSC / hosting-IP), and funnels leads to the sibling **without disclosing the relationship**. We wrote SCW-DR-001..006 to cover it — none of it was in the protocol.

**Root cause.** The protocol models a single provider, not a *family* of intentionally-isolated properties splitting informational vs commercial intent.

**Change.** Codify **"Paired Isolated Properties"** (Bible pattern + universal DR) with:
- **Isolation checklist:** distinct domain · design system · theme/HTML boilerplate · GA4/GTM/GSC property · hosting IP. Production **grep-for-sibling-name = 0**.
- **Shared-person rule:** natural-person overlap allowed; **no `sameAs`**; tell different facets of the *same true facts*, never a fabricated persona. Isolation is real only at brand/domain level (Google may infer via the person — accept it).
- **Intent split** enforced via the shared keyword-ownership-matrix (informational vs commercial).
- **⚖️ Covert-funnel compliance flag:** a property that collects leads and routes to treatment **is still medical advertising** (Thai สบส. and equivalents). De-branding is **not** legal immunity — lawyer review mandatory pre-launch.

**Reference impl.** `eywa-stemcell-web/docs/decision-records.md` (SCW-DR-001..006); `nobel-longevity-shared/governance/seo-governance.md`.

---

## 3. B2 — Authority/Media-Hub sitemap archetype ⭐ (High)

**Symptom.** The clinic 8-section skeleton (§4.2) didn't fit. Final: keep S1/S2/S8, **drop S3** (no services), **re-type S4** L3-Product→L5-Knowledge ("what the tech does *with* stem cells", not "devices we use"), **S5** = condition/indication topic-pillar, **S6** dominant, **S7** re-purposed testimonials→published case-studies. **L2/L3/L6 OFF.**

**Root cause.** §4.2 says "media skip" for some sections but gives no positive archetype, no layer re-typing rules, and doesn't model the "no money hub → content carries conversion" inversion.

**Change.** Add **"Authority/Media-Hub archetype"** to Bible Part 4:
- **Section-disposition table** for `vertical_family=other` (keep / skip+justify / re-type).
- **Re-type rule:** educational technology content is **L5 Knowledge**, never L3 Product; never turn on L3/L2/L6 for a non-provider.
- **Layer profile:** L1/L4/L5/L7 active.
- **Inversion note:** no L2 money hub → volume-driven Knowledge/Concern sections feed the CTA; conversion is content-led.

**Reference impl.** `eywa-stemcell-web/content-plan/sitemap-skeleton.md` (full worked adaptation + skip register + §4.3 mapping + intra-section shields).

---

## 4. B4 — YMYL case-study & evidence rules ⭐ (High)

**Symptom.** Three nuances the 6-tier hierarchy alone didn't resolve:
1. **"Published" is ambiguous.** Operator assumed content on the *sibling clinic's own website* counts. It does not → that's Tier-5 self-published + a de-brand provenance leak. **"Published" = an independent reviewed venue** (journal/PubMed/DOI, registered trial, preprint). *The test is who reviewed it, not where it appears.*
2. **Case study ≠ testimonial.** An independent hub *can* use real clinic-treated cases — as **กรณีศึกษา (scientific case study)**, tier-labelled single-case (Tier 5 / evidence C) — but **never as เคสรีวิว/testimonial**.
3. **Sign-off separation.** A scientific/editorial sign-off (CSA) does **not** clear a clinical case. **CSA ≠ legal ≠ PDPA:** outcome deltas (blood/liver/kidney) are efficacy/advertising claims needing a medical-ad lawyer per case; de-identify **person AND institution**.

**Root cause.** Part 23 has the tier hierarchy but no rules for brand-internal clinical cases as content, the published-definition, or the sign-off separation.

**Change.** Part 23 sub-section + DR:
- **Claim-strength must match evidence-level** (Phase-I trial ≠ proof) as a publishable rule. *(Converges with Site A P7.)*
- **Definition of "published"** + the self-published-on-related-property anti-pattern.
- **Clinical-case content gate:** CSA sign-off (scientific) **+** separate legal sign-off (advertising) **+** PDPA consent **+** de-identify person *and* institution.

**Reference impl.** `eywa-stemcell-web/content-plan/sitemap-skeleton.md` (S7 + decision D1); `content-drafts/supporting-pages/editorial-evidence-standards.md`.

---

## 5. B3 — S6 Knowledge as 4 content-types

Split Knowledge into **Guides** (evergreen `MedicalWebPage`), **Insights** (dated `Article/NewsArticle` — crawl-freshness + GEO), **Glossary** (`DefinedTermSet` — entity SEO + AI-citation), **FAQ** (`FAQPage`+`Speakable` — voice/AI). Add **intra-S6 shield** (evergreen vs dated don't cannibalize) + **freshness flywheel** (each Insight links up to a Guide). Caveats: Insights needs a real publishing **cadence**; FAQ must **de-dup** schema vs pillar-inline FAQs. **Reference:** `sitemap-skeleton.md` (S6) + `internal-linking-plan.md` (S6 content-type `link_type`s).

## 6. B5 — Planning-time EUG + new-vertical-into-shared-graph

Ran EUG at **planning time** (queried `seo_entity_graph` before naming entities; matched `aliases` for synonyms; annotated provenance `NEW/REUSE/DISAMBIGUATE/RELATE`). Findings: the shared graph is a **dental vertical**; our stem-cell entities were **almost all NEW**; the real risk was a few **cross-cutting universal concepts** (`healthy-aging`, `biological-aging-acceleration`); **no brand row existed** for this vertical. **Change:** (a) planning-time reconciliation step before entities.md finalizes; (b) require `aliases` matching; (c) new-vertical guidance (register brand first; expect mostly-NEW; watch the aging/longevity semantic-commons); (d) federation **pre-seeds `['*']` aging/longevity concepts**. **Reference:** `entities.md`.

## 7. B6 — Negative-Scope Register

Recorded what B deliberately does **not** cover (peptide 8,100/+820%, NAD, HBOT, hormone) + a **molecule-vs-service** rule (peptide-as-molecule OK incidentally; peptide-*therapy* keyword = sibling). Insight: **scope discipline protects topical authority (anti-dilution), not just anti-cannibalization.** **Change:** a Negative-Scope Register template (topic × why-off × narrow-allowance). **Reference:** `sitemap-skeleton.md` ("Out of scope").

## 8. B7 — Viability rationale: authority/internal-link pages

Built S4 as a **topical-authority + internal-link-density** play with **no KW volume**. Phase-4.5 viability (DR-016) is volume-framed → such pages have no clean justification. **Change:** add "authority / internal-link density" as a legit viability rationale (`recon` with a non-volume justification). *(Adjacent to Site A P6 `funnel_role`/`data_provenance`.)* **Reference:** `sitemap.md` (S4 rows); `audit-report.md`.

## 9. B8 — Citation anti-padding + vertical-scoped search

Reaching "≥5 Tier1-3/pillar" for Exosome, searches surfaced only **plant-derived** and **aesthetic** papers — off-target. We **refused to pad** and logged an honest shortfall. **Change:** soften the gate to **"≥5 OR documented honest-shortfall + search evidence + Phase-F follow-up"**; add a **vertical-scoping rule** (human vs plant, science vs aesthetic); record PubMed verification. *(Converges strongly with Site A P4 "verify-at-seed".)* **Reference:** `citation-pool-seed.md` (19 verified + honest gap list).

## 10. B9 — Upward governance-proposal channel

Found matrix-worthy keywords but the matrix is **S0-locked (S1/S2 read-only)** → risk of loss. Created `governance-proposals.md` to carry findings up. **Change:** standard `governance-proposals.md` template (S1/S2 → S0). *(Converges with Site A P5 `s0-keyword-proposal.md` — recommend a single unified template.)* **Reference:** `content-plan/governance-proposals.md`.

---

## 10.5 Convergence with the Site A proposal (high-confidence signals)

Two independent brand sessions (clinic + hub), same date, arrived at the **same gaps** — the owner should weight these heavily:

| Theme | Site A (clinic) | Site B (hub) | Recommendation |
|---|---|---|---|
| **Citation verify-at-seed + role** | P4 `citation_role`, PubMed-verify | B8 verify + vertical-scope + anti-padding | Merge into one citation-integrity DR |
| **Claim-strength vs evidence** | P7 investigational framing | B4 (published-def + claim-strength) | One YMYL claim-discipline rule |
| **S1/S2 → S0 proposal channel** | P5 `s0-keyword-proposal.md` | B9 `governance-proposals.md` | **Single unified template** (don't ship two) |
| **Structural node attributes** | P6 `funnel_role`, `data_provenance` | B7 authority/link viability | Consider together in the DR-016 amend |

---

## 11. Candidate DRs (owner to number — do NOT self-assign)

1. **Paired Isolated Properties pattern** (B1) — new universal DR + Bible pattern.
2. **Authority/Media-Hub sitemap archetype** (B2) — Bible §4 addition (may be doc-only, no DR).
3. **YMYL case-study & evidence rules** (B4) — Bible Part 23 sub-section + DR; coordinate with Site A P7.
4. **Citation integrity** (B8 + Site A P4) — one DR: verify-at-seed, vertical-scope, anti-padding, role.
5. **Node attributes** (B7 + Site A P6) — DR-016 amendment (viability rationale) + `funnel_role`/`data_provenance`.
6. **Unified S1/S2→S0 proposal template** (B9 + Site A P5) — template, likely no DR.
7. Doc/template-only, no DR: S6 content-types (B3), Negative-Scope Register (B6), planning-time EUG note (B5).

---

## 12. Reference implementations (copy these)

| Artifact | File (in `eywa-stemcell-web/`) | Demonstrates |
|---|---|---|
| Full lesson writeup | `docs/protocol-feedback.md` | all B1–B9 |
| Section adaptation | `content-plan/sitemap-skeleton.md` | B2, B3, B4, B6 |
| 11-col sitemap | `content-plan/sitemap.md` | B2, B7 |
| EUG-reconciled entities | `content-plan/entities.md` | B5 |
| Verified citation pool | `content-plan/citation-pool-seed.md` | B4, B8 |
| Health audit | `content-plan/audit-report.md` | B7 |
| Editorial standards page | `content-drafts/supporting-pages/editorial-evidence-standards.md` | B4 |
| Governance proposals | `content-plan/governance-proposals.md` | B9 |
| Brand DR set | `docs/decision-records.md` | B1 |

---

*Drafted 2026-07-19 from the eywa-stemcell-web engagement. For the protocol maintainer to triage into DRs / Bible sections / templates at S0. Local IDs B1–B9; assign canonical DR numbers at S0. Pairs with `2026-07-19-service-first-compliance-first.md` (Site A).*
