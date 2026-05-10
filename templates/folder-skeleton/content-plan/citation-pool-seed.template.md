# {Brand Display Name} — Phase B.2 Citation Pool Seed

> **Stage:** Stage 1 → Phase B.2 (Citation Pool Seeding)
> **Per Bible Part 23.1:** 6-Tier Citation Hierarchy
> **Per Handover §5.8:** Schema mirrors `seo_citations` table columns

---

## Scope

Survey **BREADTH** of authoritative sources per pillar topic — 5-15 sources each.

✅ **Phase B.2 = breadth** (cover main claims per pillar)
🔄 **Phase F step 3 = depth** (per-page intensive research — adds more citations as discovered during content writing)

Both layers grow `seo_citations` pool. Federation: citations marked `brand_scope=['*']` are reusable across brands; `brand_scope=['{brand}']` are brand-specific (internal data, clinic surveys).

---

## Tier Hierarchy (Bible Part 23.1)

| Tier | Source Type | Examples |
|------|------------|----------|
| 1 | Clinical guidelines, government health bodies | AASM, WHO, CDC, FDA, ทันตแพทยสภา, สมาคมโรคหัวใจ |
| 2 | Peer-reviewed journals | NEJM, JCSM, Cochrane, Journal of Dental Research |
| 3 | Authoritative medical org publications | ADA, EFP, EAO statements |
| 4 | Expert-authored books/textbooks | Misch, Branemark, etc. |
| 5 | Brand internal data | clinic case reports, patient surveys (brand_scope=['{brand}']) |
| 6 | Reputable secondary sources | medical news, established health portals |

**Freshness thresholds:**

- Tier 1: within 5 years
- Tier 2: within 5-10 years (older OK if landmark)
- Tier 3: within 5 years
- Tier 4: per discipline norm (some textbook standards last 10+ years)
- Tier 5: within 2 years
- Tier 6: within 3 years

---

## Citation Pool Schema

Each citation row should have:

```yaml
citation_fingerprint: {sha hash — generated on insert}
tier: {1-6}
schema_evidence_level: {A | B | C | D — per study design hierarchy}
title: {Full title}
authors: [array of author names]
journal: {Journal/Org/Book name}
year: {YYYY}
doi: {DOI if available}
pmid: {PubMed ID if applicable}
pmc_id: {PMC ID if open-access}
isbn: {if book}
url: {canonical URL — DOI URL preferred over publisher landing}
publication_date: {YYYY-MM-DD if known}
brand_scope: {'*' for universal | '{brand-id}' for brand-specific}
covered_claims: [list of claim_ids this citation backs]
freshness_check_date: {YYYY-MM-DD}
freshness_status: {fresh | aging | stale}
```

---

## Per-Pillar Citation Plan

### Pillar 1 — {Hero Service / Topic}

**Goal:** 5-10 Tier 1-3 citations covering main claims

**Main claims to back:**

1. {Claim 1 — e.g., "Implant success rate 95%+ at 10 years"}
2. {Claim 2}
3. {Claim 3}

**Citations:**

| # | Tier | Source | Year | DOI/URL | Covers Claim(s) |
|---|------|--------|------|---------|----------------|
| 1 | 1 | {Org / journal} | {YYYY} | {DOI} | 1, 3 |
| 2 | 2 | {Journal} | {YYYY} | {DOI} | 2 |
| 3 | 3 | {ADA/EFP/EAO} | {YYYY} | {URL} | 1 |
| ... | ... | ... | ... | ... | ... |

---

### Pillar 2 — {Secondary Topic}

{Repeat structure — 3-7 citations}

---

### Pillar N — {...}

{Repeat as needed}

---

## Brand Stance Topics (Pattern E backing per DR-019)

For topics where the brand takes a position not directly stated in cited sources, link AT LEAST 1 Tier 1-2 citation + brand internal data (Tier 5):

| Brand Stance | Backing Tier 1-2 | Brand Internal (Tier 5) |
|-------------|-----------------|------------------------|
| {e.g., "We prefer Sausage Technique for vertical bone deficiency"} | {Urban 2017 systematic review} | {Brand case audit: 47 cases 2024-2025} |

---

## Citation Reuse Check (Federation)

Before adding new entries, check `seo_citations` table for existing entries by:

1. DOI match (exact)
2. Title+year fuzzy match (>85% similarity)
3. ISBN match (books)

If existing entry found with `brand_scope=['*']` → REUSE (don't duplicate). Add this brand's `covered_claims` mapping via `seo_page_citations` junction at Phase F.

---

## Freshness Audit Schedule

```yaml
audit_cadence:
  tier_1_2_3: every 6 months (regulatory + journal updates)
  tier_4: every 12 months (textbook editions)
  tier_5: every 3 months (clinic data drift)
  tier_6: every 6 months (secondary source decay)

automated_flag: n8n job to mark `freshness_status='stale'` when publication_date older than threshold
```

---

## Operator Action Items

1. {e.g., "Pull AASM 2024 guidelines for sleep apnea pillar"}
2. {Brand internal: "Compile 2024 case audit data for Implant pillar"}
3. {...}

---

## Next Phase Triggers

✅ **Phase B.2 minimum:** ≥5 Tier 1-3 citations per main pillar
✅ **Phase C Entity Linking:** Citations attach to entities (1-5 anchoring citations per entity)
🔄 **Phase F step 3:** Per-page intensive research — adds depth citations as needed

---

*Initialized via `templates/folder-skeleton/content-plan/citation-pool-seed.template.md`. Per Handover §5.8 schema + Bible Part 23.1 hierarchy.*
