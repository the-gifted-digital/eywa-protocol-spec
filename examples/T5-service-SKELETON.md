<!--
═══════════════════════════════════════════════════════════════════════
  T5 — Service / Money Page (บริการ/หน้าขาย) — SKELETON BOILERPLATE v1.0
  Generated 2026-06-13 per DR-039. Seeded from the SmileScape All-on-4 reference build.

  STRUCTURE PRINCIPLE (same as T1 — Part 1 / Part 2 separation):
    Part 1 = WYSIWYG Content (review-ready, copy-paste-ready for web). Pure prose/tables/lists. No annotations.
    Part 2 = Technical + Editorial Spec (under multi-toggle). Section Brief, CSS Map, Schema, ACF, etc.

  T5 IS A MONEY PAGE. Two things make it different from T1:
    1. CRO FUNNEL ORDER — proof (comparison + before/after) comes BEFORE price (DR-039 §4.6 hook zones).
       Sequence: hook → who/what → how → PROOF → credibility → stance → THE ASK (price) → objections (FAQ) → trust → close.
    2. COMMERCIAL LAYER — hero carries a marketing band (rating / trust chips / price teaser / dual CTA);
       pricing is a real conversion block (per-tier CTA, "popular" ribbon). Still YMYL-gated (§4.6 tone guard).

  §4.6 CONTENT TENSION MODEL — each section is tagged answer-first / hook / both in the Section Brief.
    Answer-first (sacred, never delay): B01 summary, B02 Quick Check, B04 first line, B18 FAQ answers.
    Hook (tension OK): hero, section HEADINGS (question form), CTA copy.
  §4.7 BLOCK DATA-READINESS — each block carries a tier (🔴 gate / 🟠 first-party / 🟢 conditional).
    If first-party data (brand stance, clinical insight, before/after, clinic stats) isn't ready →
    SKIP + log a `content_gaps[]` row (never ship an empty shell, never fabricate stats).

  VALIDATION (per Content_Templates v1.9):
  □ Required blocks present (B01, B04, B13, B17, B18, B19, B20, B21, B22, B25)
  □ §4.6 tension roles assigned; no hook delays an answer-first block
  □ §4.7 readiness tiers checked; every skipped block logged in content_gaps[]; no 🔴 gate skipped
  □ Proof (B09/B16) ordered BEFORE pricing (B17)
  □ ≥1 Pattern E Brand Stance "🎯 จุดยืนของ {brand}:" IF first-party data ready (else 🟠 content_gap)
  □ B19 Doctor Review present IF page makes a medical/clinical claim (T5 EEAT matrix: "⚠️ if medical claim")
  □ B25 Safety Disclosures present for any procedure/treatment claim
  □ Schema: Service + (MedicalProcedure if clinical) + Offer; reviewedBy if claims
  □ Word count target met (Bible §9.8 L2: 1,500-2,500)
═══════════════════════════════════════════════════════════════════════
-->

---
template_id: T5
template_version: 1.0
brand_slug: "{brand-slug}"
page_fingerprint: "page_{TBD_ULID16}"
sitemap_node_id: "{X.Y.Z}"
status: draft

# === Identity ===
page_url: "/services/{slug}"
page_slug: "{slug}"
page_title: "{H1 / og:title}"
meta_description: "{120-155 chars — include price-from + primary outcome}"
page_language: th
translation_group_id: "tg_{TBD_ULID16}"
is_source_page: true
hreflang_group_id: "{topic}-{layer}-{type}"

# === 3D Tagging (Bible Part 3) ===
seo_layer: L2
seo_tier: A
funnel_stage: mid
page_type: A

# === Knowledge Graph ===
primary_entity_fp: "ent_{TBD_ULID16}"
topical_cluster_id: "{kebab-case-cluster}"
secondary_entities_fps: []
target_keyword_fp: "kw_{TBD}"

# === Schema Markup (per Content_Templates §6.4) ===
schema_org_type: Service                  # + MedicalProcedure (if clinical) + Offer
schema_tier_emission:
  tier_1_site:    [Organization, WebSite]
  tier_2_page:    [Service, MedicalProcedure, Offer]
  tier_3_content: [FAQPage, SpeakableSpecification, BreadcrumbList]

# === Editorial / EEAT (per Content_Templates §5) ===
author_fp: "auth_{TBD_ULID16}"
medical_reviewer_fp: "auth_{TBD_ULID16}"   # REQUIRED if the page makes a medical/clinical claim (T5 EEAT matrix)
last_reviewed_at: "{YYYY-MM-DD}"
next_review_due: "{YYYY-MM-DD}"
editorial_status: planned
translation_tier: tier_1

# === Word Count Target (Bible §9.8 L2) ===
target_word_count_min: 1500
target_word_count_target: 2000
target_word_count_max: 2500

# === Block Data-Readiness (Content_Templates §4.7) ===
# Log every block whose real data is NOT ready at publish. 🔴 = block release; 🟠 = ship + backfill; 🟢 = N/A.
content_gaps:
  - block: "B11a brand_stance"
    tier: "🟠 first-party-preferred"
    reason: "{clinic has not formulated a data-backed stance yet}"
    fallback_used: "external-evidence stance | none (skipped)"
    owner: "{operator}"
    due: "{YYYY-MM-DD}"
  # - add rows for B12 clinical_insight, B16 before_after, Pattern A clinic stats if not ready

# === Citations Used (mirrors seo_citations on publish) ===
citations_used:
  - id: "cite_PLACEHOLDER_001"
    type: clinical_guideline
    tier: 1
    schema_evidence_level: EvidenceLevelA
    title: "{Citation title}"
    publisher: "{Publisher}"
    publication_year: 2024
  # T5 minimum: 4 citations across mixed tiers (clinical claims must be sourced).
---

# Part 1: Content (ขึ้นเว็บจริง)

## 📊 On-Page SEO Brief

| Field | Value | Length | Status |
|-------|-------|--------|--------|
| **Focus Keyword** | {primary commercial keyword — e.g. "All-on-4 ราคา"} | — | 🎯 Primary |
| **Related Keywords** | {kw1}, {kw2}, {kw3}, {kw4}, {kw5} | — | {N} secondary |
| **SEO Title** | {browser tab title} | **{N} chars** | {✅ 50-60 / ⚠️ / ❌} |
| **Meta Description** | {SERP description — price-from + outcome + CTA} | **{N} chars** | {✅ 120-155 / ⚠️ / ❌} |
| **URL Slug** | `/services/{slug}` | — | — |
| **Target Word Count** | {N} (Bible §9.8 L2: 1,500-2,500) | — | — |
| **Featured Snippet Target** | "{service} คืออะไร" (definitional, §3) + "{service} ราคา" (transactional, §11) | — | 🎯 Position 0 |
| **Schema Type** | Service + MedicalProcedure + Offer | — | (see Part 2) |

---

# {H1: Service name — commercial, outcome-led, with focus keyword}

[TODO: H1 = outcome-led service title. e.g. "All-on-4 ฟันทั้งปากใน 1 วัน". 50-65 chars.]

## SECTION 1: Hero (commercial)

> **§4.6 zone = HOOK.** The hero is the one place a T5 leads with desire/tension, not the definition.
> The answer-first B01 summary lives in §2/§3 — the AI extracts from there, not here.

[TODO: Hero — outcome promise + a marketing band: ⭐ rating ({N} reviews) · trust chips ({N}+ cases/yr, warranty) · price-from teaser · dual CTA (primary "จองปรึกษาฟรี" + secondary "ดูราคา"). Optional 1-2 floating proof stats over the hero image.]

---

## SECTION 2: Quick Check — ข้อมูลสำคัญ

> **§4.6 zone = ANSWER-FIRST** (B02 variant). 4-5 commercial-clinical essentials, reviewer row. Technical codes → toggle.

**{Service Name TH}** | {English Term}

| | |
|---|---|
| ✅ **ข้อบ่งชี้ (เหมาะกับ)** | {who/what this restores — primary indication} |
| 💙 **ช่วยฟื้นฟู** | {function/confidence restored} |
| ⚠️ **ข้อห้าม / ข้อควรระวัง** | {key contraindications — feeds §12 Safety + MedicalProcedure.contraindication} |
| 🛡️ **ช่วยป้องกัน** | {what it prevents — e.g. bone resorption} |
| ✅ **ตรวจสอบโดย** | {reviewer name + credentials} |

<details>
<summary>▶ ข้อมูลทางเทคนิค</summary>

| | |
|---|---|
| หัตถการ (EN) | {procedure name} |
| ICD-10-CM / ICD-11 | {codes if applicable} |
| ระยะเวลา / นัด | {visits / timeline} |
| วัสดุ / ระบบ | {materials / brand systems} |
| รับประกัน | {warranty terms} |

</details>

---

## SECTION 3: {Service}คืออะไร?

> **§4.6 zone = BOTH.** Question-heading (hook + AEO) → answer-first first line (B04, `.speakable-block`).

[TODO: 40-60 word direct answer (Featured Snippet target). What it is + the core mechanism + the headline outcome.]

[TODO: 1-2 paragraphs — how it works, what makes this clinic's approach distinct (no superlatives).]

---

## SECTION 4: {Service}เหมาะกับใคร?

> **§4.6 zone = BOTH** (B27 who_for). Question-heading; reader self-identifies. Card per persona.

[TODO: 3 persona cards — each: who they are (pain-led title) + 1-line description. Link to the matching T1 Concern page where relevant.]

---

## SECTION 5: ขั้นตอนการรักษา

> **§4.6 zone = ANSWER-FIRST** (B13 process_steps, emits HowTo). Clear numbered steps = "easy to buy".

[TODO: 5-9 numbered steps — each: title + 1-2 sentences (what happens + patient experience). Keep clinical depth on the T2 procedure page (Cannibalization Shield).]

---

## SECTION 6: เปรียบเทียบทางเลือก — เลือกแบบไหนดี?

> **§4.6 zone = BOTH** (B09). PROOF #1 — comes BEFORE price. Highlight this clinic's option column. ✓/✗ as icons.

[TODO: comparison table — rows = criteria (efficacy, suitability, durability, time, cost-range, limitation); columns = options; emphasize THIS service's column. Neutral framing (no disparagement).]

---

## SECTION 7: ผลลัพธ์ก่อน-หลัง

> **§4.6 zone = HOOK** · **§4.7 tier = 🟠 first-party** (B16). PROOF #2. PDPA consent required (DR-030).
> If no consented cases yet → SKIP + log `content_gaps[]` (do NOT use stock/competitor images).

[TODO: 2-4 before/after pairs — caption: anonymized profile + treatment + timeframe. Consent on file.]

---

## SECTION 8: ทำไมต้อง {Brand}

> **§4.6 zone = HOOK** (B10 expertise). Credibility — team / training / technology / volume. Specific, verifiable.

[TODO: trust band — credentials, training, case volume, technology systems. A 1-line quote (brand standard) optional.]

---

## SECTION 9: 🎯 จุดยืนของ {Brand}

> **§4.6 zone = ANSWER-FIRST (stance)** · **§4.7 tier = 🟠 first-party** (B11a, Pattern E — ⭐ LLMO superweapon).
> MANDATORY prefix "🎯 จุดยืนของ {brand}:". If no data-backed stance yet → SKIP + log `content_gaps[]`
> (or fallback to an external-evidence stance, flagged lower-LLMO). NEVER fabricate clinic stats.

> 🎯 **จุดยืนของ {Brand}: [TODO: clear policy statement in 1 sentence]**
>
> [TODO: 2-3 sentences with first-party clinic data + reasoning supporting the stance]
>
> **เราจึงแนะนำ {practical recommendation}** — [TODO: who/when this applies]

---

## SECTION 10: จากห้องตรวจ

> **§4.6 zone = HOOK** · **§4.7 tier = 🟠 first-party** (B12, recommended for T5). Doctor quote + clinic data + 1-2 myths.
> If not ready → SKIP + log `content_gaps[]`.

[TODO: doctor observation quote + 2-3 clinic data points (Pattern A citables) + 1-2 misconception corrections.]

---

## SECTION 11: ราคา

> **§4.6 zone = ANSWER-FIRST** (B17). THE ASK — placed AFTER proof. Per-tier card: was-price (real), price, installment, ✓ inclusions, per-tier CTA, "popular" ribbon on the highlight tier. Transparent inclusions/exclusions.

[TODO: pricing — note (what's included) + 1-3 tiers. Each tier: name, (optional real was-price), price, period, installment, includes[], CTA. NO fabricated discounts (Thai consumer law).]

---

## SECTION 12: ข้อควรระวังและความปลอดภัย

> **§4.6 zone = ANSWER-FIRST** · **§4.7 tier = 🔴 gate** (B25). REQUIRED for any procedure/treatment claim. Plain-language contraindications + risks. Feeds MedicalProcedure.contraindication.

[TODO: bulleted contraindications + common risks/side effects + when this is NOT suitable. Honest, non-alarmist.]

---

## SECTION 13: คำถามที่พบบ่อย

> **§4.6 zone = ANSWER-FIRST** (B18, AEO). ≥6 Q&A (≥8 if no PAA, per §4.5.4) across intent types incl. cost.

**Q1: {service} ต่างจาก {alternative} อย่างไร?** [comparison]

[TODO: answer]

**Q2: {service} เจ็บไหม / พักฟื้นนานไหม?** [troubleshooting]

[TODO: answer]

**Q3: ใช้งานได้นานแค่ไหน / รับประกันอย่างไร?** [informational]

[TODO: answer]

**Q4: ราคา {service} รวมอะไรบ้าง?** [transactional]

[TODO: answer + what's included]

**Q5: ถ้า {risk condition} ทำได้ไหม?** [decision]

[TODO: answer]

**Q6: ผ่อนได้ไหม / มีสิทธิ์เบิกไหม?** [transactional]

[TODO: answer]

[TODO: add to ≥6 (≥8 if no PAA). Cover ≥7 of 8 intent types page-wide.]

---

<!-- §14–17 = E-E-A-T trust footer → conversion close (per DR-039 / Content_Templates §4.6 + §4.7).
     ORDER: Doctor Review → References → Related → CTA (final). -->

## SECTION 14: ตรวจสอบและรับรองโดย

> **§4.7 tier = 🔴 gate** if the page makes a medical/clinical claim (B19). Visual + structured; feeds reviewedBy → Physician.

✅ **ตรวจสอบและรับรองโดย:** **{Dr. Prefix} {Name}**

{Title}

**Credentials:** {credential list} · Specialty: {specialty}

ตรวจสอบล่าสุด: **{Month YYYY}** | Next review due: **{Month YYYY}**

[→ ดูประวัติของ {Dr. Name}](/{path-to-T9})

---

## SECTION 15: แหล่งข้อมูลอ้างอิง

> **§4.7 tier = 🔴 gate** for any clinical claim (B21).

1. {Citation 1}
2. {Citation 2}
3. {Citation 3}
4. {Citation 4}

[TODO: 4-10 citations matching `citations_used`.]

---

## SECTION 16: บริการที่เกี่ยวข้อง

> (B22) 3-7 related services / alternatives / the concern this treats.

- [{Alternative service}](/{slug}) — {1-line}
- [{Related concern this treats}](/{slug}) — {1-line}
- [{Supporting procedure}](/{slug}) — {1-line}

---

## SECTION 17: พร้อมเริ่มต้นหรือยัง?

> **§4.6 zone = HOOK** (B20). Final conversion close. One clear primary CTA + low-pressure alternative.

[TODO: 1-2 sentence value prop + primary CTA "จองปรึกษาฟรี" + alt "โทร / LINE".]

---
---

# Part 2: Technical + Editorial Spec 🔧

> For writer / editor / dev. Strip on publish.

<details>
<summary>📋 Section Brief — purpose + §4.6 tension role + §4.7 readiness tier (writer guide)</summary>

| § | Section | Block | Purpose | §4.6 Tension | §4.7 Tier | Length |
|---|---------|-------|---------|--------------|-----------|--------|
| 1 | Hero (commercial) | B01 + promo | Desire + trust band + dual CTA | 🟡 hook | 🔴 gate | — |
| 2 | Quick Check | B02 | Commercial-clinical essentials + reviewer | 🔵 answer-first | 🔴 gate | 4-5 rows |
| 3 | {Service}คืออะไร? | B04 | Featured-snippet definition (.speakable) | 🟢 both | 🔴 gate | 150-300w |
| 4 | เหมาะกับใคร? | B27 | Self-identification, persona cards | 🟢 both | 🟢 recommended | 150-250w |
| 5 | ขั้นตอน | B13 | HowTo steps — "easy to buy" | 🔵 answer-first | 🟠 (needs real protocol) | 200-400w |
| 6 | เปรียบเทียบ | B09 | PROOF #1 — decision table | 🟢 both | 🟢 (skip if 1 option) | table |
| 7 | ก่อน-หลัง | B16 | PROOF #2 — visual outcome | 🟡 hook | 🟠 first-party (PDPA) | 2-4 pairs |
| 8 | ทำไมต้อง {brand} | B10 | Credibility | 🟡 hook | 🟢 | 150-250w |
| 9 | จุดยืนคลินิก | B11a | ⭐ LLMO stance (Pattern E) | 🔵 answer-first | 🟠 first-party | 100-200w |
| 10 | จากห้องตรวจ | B12 | Expert voice + clinic data + myths | 🟡 hook | 🟠 first-party | 200-400w |
| 11 | ราคา | B17 | THE ASK (after proof) | 🔵 answer-first | 🔴 gate | tiers |
| 12 | ข้อควรระวัง | B25 | Safety / contraindications | 🔵 answer-first | 🔴 gate | 100-200w |
| 13 | FAQ | B18 | AEO, incl. cost intent | 🔵 answer-first | 🔴 gate | ≥6 Q&A |
| 14 | Doctor Review | B19 | E-E-A-T (if claim) | — | 🔴 gate (if claim) | — |
| 15 | References | B21 | Authority citations | — | 🔴 gate (if claim) | 4-10 |
| 16 | Related | B22 | Cross-links | — | 🟢 | 3-7 |
| 17 | CTA (final) | B20 | Conversion close | 🟡 hook | 🔴 gate | — |

**Rule reminders:** no 🟡 hook may delay a 🔵 answer-first block · every skipped block → a `content_gaps[]` row · no 🔴 gate may be skipped (block release or noindex) · proof (§6/§7) before price (§11).

</details>

<details>
<summary>🧩 Block Composition & Readiness (T5)</summary>

**Required (🔴 gate — release blocked if data missing):** B01, B04, B13, B17, B18, B25, B19 (if medical claim), B21 (if clinical claim), B20.
**First-party-preferred (🟠 — ship + log `content_gaps[]`, optional external fallback):** B11a brand_stance, B12 clinical_insight, B16 before_after, B02 Pattern-A clinic stats.
**Conditional / recommended (🟢):** B02 Quick Check, B27 who_for, B09 comparison (skip if 1 option), B22 related.

**Fallback decisions (§4.7):**
- No formulated brand stance → SKIP B11a + `content_gap` (or external-evidence stance, flagged lower-LLMO).
- No consented before/after → SKIP B16 + `content_gap` (NEVER stock/competitor images).
- No clinic outcome data → Pattern A citables fall back to Tier 1-2 external; flag for first-party upgrade.

</details>

<details>
<summary>🏗️ Schema Markup (Tier 2 — Service + MedicalProcedure + Offer)</summary>

```jsonld
{
  "@type": ["Service", "MedicalProcedure"],
  "@id": "https://{brand}.com/services/{slug}/#service",
  "name": "{Service Name}",
  "procedureType": "{type}",
  "howPerformed": "{1-line mechanism}",
  "indication": [{"@type": "MedicalIndication", "name": "{indication}"}],
  "contraindication": "{contraindication summary}",
  "provider": {"@id": "https://{brand}.com/#organization"},
  "offers": {
    "@type": "Offer",
    "priceCurrency": "THB",
    "price": "{price-from}",
    "priceSpecification": {"@type": "PriceSpecification", "minPrice": "{min}", "maxPrice": "{max}"},
    "availability": "https://schema.org/InStock"
  }
}
```
Page node also emits `MedicalWebPage` with `reviewedBy` + `lastReviewed` when a medical claim is present (T5 EEAT matrix). FAQPage + SpeakableSpecification (`.speakable-block`) + BreadcrumbList per Tier 3 (see T1 skeleton for full Tier 1/3 boilerplate).

</details>

<details>
<summary>🎨 CSS Class Map · 🔧 ACF · 🖼️ Images · 🤖 Predicted Prompts</summary>

CSS classes follow the T1 convention (`.speakable-block`, `.quick-facts-table`, `.comparison-table`, `.brand-stance-block`, `.clinical-insight-block`, `.pricing-grid`, `.faq-accordion`, `.doctor-review-block`, `.references-list`, `.related-links-cluster`, `.cta-block`).
ACF / Image specs / Predicted Prompts Bank (B26, ≥15 prompts × ≥7 intents incl. transactional "ราคา") — author per the T1 skeleton pattern, adapting fields to the T5 sections above.

</details>

<details>
<summary>📝 Dev Notes & Validation Checklist</summary>

## Cannibalization Shield (§4.5.3)
✅ T5 covers the COMMERCIAL OFFER: what it restores, who for, steps OVERVIEW, comparison, proof, price, booking.
❌ Deep clinical procedure detail → T2 · diagnostic protocol → T3 · disease education → T1 · full pricing matrix → T13.

## Validation Before Publish
- [ ] Required (🔴) blocks present; no 🔴 gate skipped
- [ ] Every skipped block logged in `content_gaps[]` (§4.7); 🟠 gaps have owner + due
- [ ] §4.6 tension roles assigned; no hook delays an answer-first block
- [ ] Proof (§6/§7) precedes price (§11)
- [ ] Pattern E stance present OR logged as 🟠 content_gap (never fabricated)
- [ ] B25 Safety present; contraindications feed schema
- [ ] B19 reviewer = Physician if medical claim; lastReviewed in JSON-LD
- [ ] Offer schema price real; no fabricated was-prices (Thai consumer law)
- [ ] Word count §9.8 L2 (1,500-2,500); ≥4 citations
- [ ] All [TODO: ...] resolved

</details>

---

<!--
END OF T5 SKELETON v1.0 — generated per DR-039 (2026-06-13).
Seeded from brands/eywa-smile-scape All-on-4 reference build (web/src/layouts/templates/Service.astro).
References: Content_Templates v1.9 (§4.6 Tension Model, §4.7 Readiness/Fallback, §5 EEAT matrix T5 row),
T1-medical-condition-SKELETON.md (Part 1/Part 2 pattern), DR-039, DR-034, DR-030 (PDPA).
-->
