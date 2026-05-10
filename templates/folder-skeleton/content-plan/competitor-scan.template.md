# {Brand Display Name} — Phase B Competitor Scan

> **Stage:** Stage 1 → Phase B (Lean Research, DR-022)
> **Method:** WebSearch breadth — manual SERP exploration, browse competitor sites, capture structural intelligence (NOT performance/volume — that's DFS layer post-Stage 1.5)

---

## Scope of this file

✅ **DO capture:**
- Competitor sitemap shapes (what sections do they have?)
- Page types per service (single landing? funnel? blog?)
- USP positioning + tagline patterns
- Hero service framing (price-led? warranty-led? expertise-led?)
- Founder/team presentation patterns
- Content depth markers (per page word count rough estimate)
- Schema markup observable (FAQ? Review? AggregateRating?)

❌ **DO NOT capture here:**
- Traffic estimates → goes to `serp-intelligence-shortlist.md` (post-DFS, Tier A/B only)
- Backlink profiles → optional, lives in `reports/` if needed
- Volume / KD per keyword → DFS enrichment (async)

---

## Competitor Inventory

### Top 5 Direct Competitors (same vertical, same region)

| # | Competitor | URL | Position | Notes |
|---|-----------|-----|----------|-------|
| 1 | {Name} | {URL} | {Direct competitor / Tier-up / Tier-down} | {1 line} |
| 2 | ... | ... | ... | ... |

### Adjacent Competitors (different vertical, overlapping audience)

| # | Competitor | URL | Why Adjacent | Notes |
|---|-----------|-----|-------------|-------|
| ... | ... | ... | ... | ... |

---

## Per-Competitor Structural Breakdown

### Competitor 1 — {Name}

**URL:** {URL}
**Positioning tagline:** "{Tagline}"
**Hero framing:** {Price-led / Warranty-led / Expertise-led / Tech-led / Emotional}

**Sitemap shape observed:**

```
{Top nav structure — what menu items do they have?}
{Footer structure — what categories appear?}
```

**Page types per service:**

- Single landing page (e.g., /implant/)
- Funnel page (e.g., /implant/blue-diamond/)
- Comparison page (e.g., /implant/vs-osstem/)
- Knowledge page (e.g., /knowledge/peri-implantitis/)
- Blog (e.g., /blog/...)

**Authority signals visible:**

- Doctor profiles (yes/no — how many?)
- Credentials displayed (Mahidol / Chula / international masterclasses?)
- Case studies (before/after, anonymized?)
- Awards / certifications
- Patient reviews (volume + integration with schema)
- Media mentions

**Schema observable (via View Source / Schema.org validator):**

- Organization / MedicalBusiness / Dentist? {which}
- MedicalProcedure on service pages? {Y/N}
- Article / BlogPosting on knowledge pages? {Y/N}
- FAQPage? {Y/N — note: deprecated for rich results post-2026-06}
- AggregateRating? {Y/N + count}
- reviewedBy on YMYL pages? {Y/N}

**Content depth rough estimate:**

- Service page: ~{N} words
- Knowledge page: ~{N} words
- Blog post: ~{N} words

**What they do well:**

- {Observation 1}
- {Observation 2}

**What they miss / weakness for us to exploit:**

- {Observation 1}
- {Observation 2}

---

### Competitor 2 — {Name}

{Repeat structure}

---

## Patterns Observed Across Competitors

### Common sitemap section names (Thai vertical norms)

- {e.g., "บริการ" / "ทันตกรรม" / "ทีมแพทย์" / "ความรู้" / "บทความ"}

### Common URL structures

- {e.g., /service/{slug}/ vs /treatment/{slug}/ vs /th/{slug}/}

### Common hero CTAs

- {e.g., "นัดปรึกษาฟรี" / "ขอราคาโปร" / "Add LINE @"}

### Common authority displays

- {e.g., "ทันตแพทย์ 30+ คน" / "ประสบการณ์ 20 ปี" / "ผ่าน 5000+ เคส"}

### Common schema gaps

- {e.g., no reviewedBy on YMYL / FAQ deprecated but still emitted / Organization not MedicalBusiness}

---

## Positioning Opportunity Map

### Where competitors cluster (avoid me-too)

- {Price-led basic implants → 5 competitors crowded}
- {Generic invisalign → 4 competitors}

### White space (we can own this)

- {Premium ceramic implant + holistic angle}
- {Spousal-founder family-warmth narrative}
- {Specific signature technique no one else does in Thailand}

### Layer 2 blog topics competitors do well (we should match or exceed)

- {Topic 1 — covered by Competitor 1 + 3}
- {Topic 2 — covered by Competitor 2 + 4 + 5}

### Layer 2 blog topics competitors miss (gap we can fill)

- {Topic 1 — no competitor covers this PAA cluster well}
- {Topic 2 — only thin/old content exists}

---

## Audit Flags

🚩 **Flag 1:** {Anything anomalous observed — e.g., "Competitor 3 dropped 50% of their site recently — investigate before mimicking"}

🚩 **Flag 2:** {Another flag}

---

## Operator Action Items

1. {Brand decision needed — e.g., "Confirm if we want to compete on price tier with Competitor 1 or position above"}
2. {Brand decision needed}

---

## Next Phase Triggers

✅ **Phase B output ready** when this file is committed alongside `keyword-seed-list.md`
🟡 **Phase C Entity Genesis** can use competitor patterns as entity discovery input
🟡 **Phase E Sitemap structure** uses positioning opportunity map for Layer 2 prioritization

---

*Initialized via `templates/folder-skeleton/content-plan/competitor-scan.template.md`. Per DR-022 (Proposed) — Phase B output file (replaces section of legacy `research-notes.md`).*
