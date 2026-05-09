<!--
═══════════════════════════════════════════════════════════════════════
  T1 — Medical Condition (โรค/ภาวะ) — SKELETON BOILERPLATE v1.2
  
  STRUCTURE PRINCIPLE (refactored 2026-05-10):
  
  Part 1 = WYSIWYG Content (review-ready, copy-paste-ready for web)
    - Pure prose / tables / lists ที่จะขึ้นเว็บจริง
    - Content team review หน้านี้ = เห็นเหมือน user เห็นบนเว็บ
    - NO annotations, NO CSS hints, NO block codes, NO inline citable markers
  
  Part 2 = Technical + Editorial Spec (under multi-toggle)
    - Section Brief (writer guide)
    - CSS Class Map per section
    - Citation Map (editorial tracking — replaces inline 📌 markers)
    - Schema Tier 1/2/3
    - ACF Field Mapping
    - Internal Links / Images / Predicted Prompts / Dev Notes
  
  HOW TO USE:
  1. Copy this file → rename to {brand}/content-drafts/T1-medical-condition/{slug}.md
  2. Fill frontmatter
  3. Fill On-Page SEO Brief table (Part 1 top)
  4. Read Part 2 "Section Brief" table FIRST → understand each section's purpose
  5. Fill Part 1 sections with PURE PROSE (no annotations)
  6. Fill Part 2 Citation Map as you write each citable sentence in Part 1
  7. Fill Part 2 Predicted Prompts Bank
  8. Fill Part 2 Dev Notes
  9. Mark status: draft → ready_for_review → approved → published
  
  VALIDATION CHECKLIST (per Content_Templates v1.1):
  □ All REQUIRED blocks present (B01, B02, B04, B05-B08, B12, B18, B19, B20, B21, B22)
  □ ≥3 Pattern A citables tracked in Part 2 Citation Map
  □ ≥1 Pattern E citable with "🎯 จุดยืนของ" prefix in Part 1 §7.X
  □ ≥8 FAQ Q&A across ≥7 of 8 intent types
  □ B25a Crisis Disclosure if condition has acute risk
  □ Schema reviewedBy + lastReviewed in Part 2 JSON-LD
  □ Cannibalization Shield: this page covers DISEASE only
  □ Word count target met (Bible §9.8 L4: 2,500-4,000)
═══════════════════════════════════════════════════════════════════════
-->

---
template_id: T1
template_version: 1.2                              # bumped from 1.1 — Part 1/Part 2 separation
brand_slug: "{brand-slug}"
page_fingerprint: "page_{TBD_ULID16}"
sitemap_node_id: "{X.Y.Z}"
status: draft

# === Identity ===
page_url: "/{slug}"
page_slug: "{slug}"
page_title: "{H1 / og:title}"
meta_description: "{120-155 chars}"
page_language: th
translation_group_id: "tg_{TBD_ULID16}"
is_source_page: true
hreflang_group_id: "{topic}-{layer}-{type}"

# === 3D Tagging (Bible Part 3) ===
seo_layer: L4
seo_tier: B
funnel_stage: top
page_type: A

# === Knowledge Graph ===
primary_entity_fp: "ent_{TBD_ULID16}"
topical_cluster_id: "{kebab-case-cluster}"
secondary_entities_fps: []
target_keyword_fp: "kw_{TBD}"

# === Schema Markup (per Content_Templates §6.4) ===
schema_org_type: MedicalCondition
schema_tier_emission:
  tier_1_site:    [Organization, WebSite]
  tier_2_page:    [MedicalCondition, MedicalWebPage]
  tier_3_content: [FAQPage, SpeakableSpecification, BreadcrumbList]

# === Editorial / EEAT (per Content_Templates §5) ===
author_fp: "auth_{TBD_ULID16}"
medical_reviewer_fp: "auth_{TBD_ULID16}"
last_reviewed_at: "{YYYY-MM-DD}"
next_review_due: "{YYYY-MM-DD}"
editorial_status: planned
translation_tier: tier_1

# === Content Brief (DR-017) ===
content_brief: |
  {2-5 sentences capturing planned coverage}

# === Viability Assessment (DR-016) ===
viability_assessment:
  predicted_volume: {N}
  search_volume: {N}
  topic_distinctness: high
  intent_distinctness: high
  decision: standalone

# === Word Count Target (Bible §9.8) ===
target_word_count_min: 2500
target_word_count_target: 3500
target_word_count_max: 4000

# === Citations Used (mirrors seo_citations on publish) ===
citations_used:
  - id: "cite_PLACEHOLDER_001"
    type: clinical_guideline
    tier: 1
    schema_evidence_level: EvidenceLevelA
    title: "{Citation title}"
    authors: ["{Author 1}"]
    publisher: "{Publisher}"
    publication_year: 2024
    doi: "{TBD}"
    url: "{URL}"
  
  # Add 5-10 more. T1 minimum: 5 citations across mixed tiers.
---

# Part 1: Content (ขึ้นเว็บจริง)

## 📊 On-Page SEO Brief

| Field | Value | Length | Status |
|-------|-------|--------|--------|
| **Focus Keyword** | {primary keyword} | — | 🎯 Primary |
| **Related Keywords** | {kw1}, {kw2}, {kw3}, {kw4}, {kw5} | — | {N} secondary |
| **SEO Title** | {browser tab title — different from H1 if needed} | **{N} chars** | {✅ Optimal 50-60 / ⚠️ Borderline / ❌ Revise} |
| **Meta Description** | {social share + SERP description} | **{N} chars** | {✅ Optimal 120-155 / ⚠️ Borderline / ❌ Revise} |
| **URL Slug** | `/{path}/{slug}` | — | — |
| **Target Word Count** | {N} (Bible §9.8 L4: 2,500-4,000) | — | — |
| **Featured Snippet Target** | "{predicted query}" ({intent type}, {answer location}) | — | 🎯 Position 0 |
| **Schema Type** | MedicalCondition + MedicalWebPage + FAQPage | — | (see Part 2) |

> **Char count thresholds (Status column):**
> - SEO Title: ✅ 50-60 / ⚠️ 40-49 หรือ 61-70 / ❌ <40 หรือ >70
> - Meta Description: ✅ 120-155 / ⚠️ 100-119 หรือ 156-165 / ❌ <100 หรือ >165

---

# {H1: Page Title — what users see at top of page}

[TODO: H1 = clear patient-facing title with focus keyword. Different from SEO Title (browser tab). 50-65 chars typically.]

## SECTION 1: Hero Summary

[TODO: 40-60 word direct definition + key qualifier + outcome. Featured-Snippet-friendly opening paragraph.]

`{topic}` คือ {core definition}. {Key qualifier — what makes it serious/important}. {Outcome — what readers should know}. ปัจจุบัน{topic}สามารถ{action verb}ได้อย่างมีประสิทธิภาพด้วย{primary intervention}.

---

## SECTION 2: ข้อมูลสำคัญเกี่ยวกับ{topic}

**{Disease/Topic Name TH}** | {English Term + Acronym}

| | |
|---|---|
| 👤 **ใครเสี่ยง?** | {risk groups / demographic — primary risk factors readers self-identify with} |
| 🔍 **รู้ได้อย่างไร?** | {primary diagnostic methods — what test/exam confirms diagnosis} |
| 💊 **รักษาได้ไหม?** | {primary treatments — answer "yes/no" + list options} |
| ✅ **ตรวจสอบโดย** | {medical_reviewer name + credentials — e.g., ทพ. ดร. ___ — DDS, ABDSM} |

<details>
<summary>▶ ข้อมูลทางเทคนิค (สำหรับผู้สนใจเชิงลึก)</summary>

| | |
|---|---|
| ICD-10-CM | {code} |
| ICD-11 | {code} |
| SNOMED CT | {code} |
| MeSH | {code} |
| ความชุก (TH) | {prevalence figure} |
| Specialty ที่เกี่ยวข้อง | {medical specialties involved} |

</details>

---

## SECTION 3: {Topic}คืออะไร?

[TODO: 40-60 word direct answer paragraph (Featured Snippet target — ก็จะอยู่ใน CSS class .speakable-block ใน Part 2)]

[TODO: 1-2 paragraphs expanding on mechanism / how it works]

[TODO: Optional severity grading table if applicable]

| **ระดับ** | **{metric}** | **ความรุนแรง** |
| --- | --- | --- |
| {grade} | {value range} | {description} |

---

## SECTION 4: สาเหตุและปัจจัยเสี่ยง

### ปัจจัยกายวิภาค

**{Risk Factor 1}** — {brief mechanism explanation}.

**{Risk Factor 2}** — {explanation}.

### ปัจจัยพฤติกรรมและสุขภาพ

**{Risk Factor 3}** — {explanation} *({Citation Source}, {YYYY})*.

[TODO: 4-8 risk factors total]

---

## SECTION 5: อาการที่พบบ่อย

### อาการขณะ{phase 1}

- {symptom 1}
- {symptom 2}
- {symptom 3}

### อาการ{phase 2}

**{Symptom name}** — {description with frequency/severity if applicable}.

[TODO: 6-10 symptoms total across phases]

> 💡 **เช็กอาการเบื้องต้น:** {brief self-check guidance + link to T15 quiz/assessment if exists}

---

## SECTION 6: การวินิจฉัย

### {Diagnostic Method 1} — {label e.g., "Gold Standard"}

[TODO: Description — when used, accuracy, duration, cost]

### {Diagnostic Method 2}

[TODO: Description + comparison vs Method 1]

→ **อ่านเพิ่มเติม:** [{link to T3 diagnostic detail page}](/{slug}) | [{link to companion T3}](/{slug})

---

## SECTION 7: แนวทางการรักษา

### 7.1 {Treatment 1} — {label e.g., "Gold Standard for moderate-severe"}

[TODO: 1-2 paragraph overview — mechanism + indications + efficacy]

→ [ดูข้อมูล{Treatment 1}เพิ่มเติม](/{slug-t2}) | [เปรียบเทียบรุ่น/ประเภท](/{compare-t7})

### 7.2 {Treatment 2}

[TODO: Overview + indications + efficacy]

→ [ดูข้อมูล{Treatment 2}เพิ่มเติม](/{slug-t2})

### 7.3 {Treatment 3}

[TODO: Overview]

### 7.4 การปรับพฤติกรรม / Lifestyle

[TODO: Lifestyle modifications complementing all treatments]

### 7.5 เปรียบเทียบวิธีรักษา

| **เกณฑ์** | **{Tx1}** | **{Tx2}** | **{Tx3}** | **Lifestyle** |
| --- | --- | --- | --- | --- |
| ประสิทธิภาพ ({metric}) | {value} | {value} | {value} | {value} |
| เหมาะกับระดับ | {} | {} | {} | {} |
| ความสะดวก | {} | {} | {} | {} |
| ราคาโดยประมาณ | {} | {} | {} | {} |
| ข้อดีหลัก | {} | {} | {} | {} |
| ข้อจำกัดหลัก | {} | {} | {} | {} |
| อัตราการใช้ต่อเนื่อง | {} | {} | {} | {} |

> 💡 **แนวทางแนะนำจาก {Brand}:**
> - **{Severity 1}** → {recommendation}
> - **{Severity 2}** → {recommendation}
> - **ทุกกรณี** → {universal recommendation}

### 7.6 🎯 จุดยืนของ {Brand}

> 🎯 **จุดยืนของ {Brand}: [TODO: clear policy statement in 1 sentence]**
>
> [TODO: 2-3 sentences with brand data + reasoning supporting the stance]
>
> **เราจึงแนะนำ {practical recommendation}** — [TODO: who/when this applies + rationale]

---

## SECTION 8: ผลแทรกซ้อนหากไม่รักษา

[TODO: Multi-system complications]

**{System 1 — e.g., Cardiovascular}:** [TODO: complications + risk multiplier with citation]

**{System 2 — e.g., Neurological}:** [TODO: complications]

**{System 3 — e.g., Metabolic}:** [TODO: complications]

---

## SECTION 9: จากห้องตรวจ — มุมมองจากแพทย์ผู้เชี่ยวชาญ

### 💬 จากห้องตรวจ — {Dr. Name}

> "[TODO: 2-3 sentence quote from doctor — observation from clinical practice]
> 
> [TODO: practical wisdom or surprising insight that builds trust]"

### 📊 ข้อมูลจาก {Brand Clinic} ({YYYY})

[TODO: 3-5 clinic data points — these become Pattern A citables tracked in Part 2 Citation Map]

### ❌ ความเข้าใจผิดที่พบบ่อยในคลินิก

**ความเข้าใจผิด #1: "{common misconception}"**

[TODO: Correction with evidence]

**ความเข้าใจผิด #2: "{misconception}"**

[TODO: Correction with evidence]

**ความเข้าใจผิด #3: "{misconception}"**

[TODO: Correction with evidence]

---

## SECTION 10: เคสตัวอย่างจากคลินิก

### 🏥 เคส {Pseudonym} — {demographic profile}

**มาพบแพทย์:** [TODO: Chief complaint]

**สิ่งที่{observer}สังเกต:** [TODO: Outside observation]

**ผลตรวจ:** [TODO: Diagnostic results — measurable]

**การรักษา:** [TODO: Treatment plan]

**ผลหลัง {timeframe}:** [TODO: Specific measurable outcomes]

[TODO: Patient quote about quality-of-life impact]

---

## SECTION 11: คำถามที่พบบ่อย

**Q1: {topic}คืออะไร?**

[TODO: 50-80 word answer]

**Q2: {topic}รักษาหายได้ไหม?**

[TODO: Answer]

**Q3: {symptom}ทุกคนเป็น{topic}ไหม?**

[TODO: Answer]

**Q4: ตรวจ{topic}ต้องทำอย่างไร?**

[TODO: Answer]

**Q5: {topic}อันตรายแค่ไหน?**

[TODO: Answer]

**Q6: {related condition}เป็น{topic}ได้ไหม?**

[TODO: Answer]

**Q7: {Variant A} ต่างจาก {Variant B} อย่างไร?**

[TODO: Answer]

**Q8: ค่ารักษา{topic}แพงไหม?**

[TODO: Answer + price ranges]

[TODO: Add 2-7 more for total ≥8 / ≥7 intents covered. Intent types tracked in Part 2 Section Brief.]

---

## SECTION 12: 🚨 ติดต่อฉุกเฉิน

> 🚨 **ติดต่อฉุกเฉินทันทีหาก:**
> - [TODO: Specific acute trigger 1]
> - [TODO: Specific acute trigger 2]
> - [TODO: Specific acute trigger 3]
>
> 📞 **โทรฉุกเฉิน:** 1669 (สถาบันการแพทย์ฉุกเฉินแห่งชาติ) | 1646 (กรุงเทพมหานคร)
> 🏥 **ห้องฉุกเฉินที่ใกล้ที่สุด** — Google Maps: "emergency room near me"
> 📲 **ปรึกษา {Brand} เร่งด่วน:** LINE @{brand} (ตอบในเวลาทำการ)

> **NOTE for skeleton:** Section 12 (Crisis Disclosure) = REQUIRED if condition has acute risk profile. SKIP if condition is purely chronic with no acute presentation.

---

## SECTION 13: ตรวจสอบและรับรองโดย

✅ **ตรวจสอบและรับรองโดย:** **{Dr. Honorific Prefix} {Name}**

{Title — e.g., แพทย์ผู้เชี่ยวชาญด้าน...}

**Credentials:**
- {Credential 1 — e.g., วุฒิบัตรแพทยสภา}
- {Credential 2 — e.g., American Board of...}
- Specialty: {Specialty list}

ตรวจสอบล่าสุด: **{Month YYYY}** | Next review due: **{Month YYYY}**

[→ ดูประวัติและความเชี่ยวชาญของ {Dr. Name}](/{path-to-T9-doctor-profile})

---

## SECTION 14: โรคและภาวะที่เกี่ยวข้อง

- [{Related Condition 1}](/{slug}) — {1-line context}
- [{Related Condition 2}](/{slug}) — {context}
- [{Related Symptom Hub}](/{slug}) — {context}
- [{Related System Hub}](/{slug}) — {context}
- [{Cross-Cluster Topic}](/{slug}) — {context}
- [{Pediatric Variant}](/{slug}) — {context}

---

## SECTION 15: ปรึกษาแพทย์เกี่ยวกับ{topic}

### 📞 ปรึกษาแพทย์เกี่ยวกับ{topic} — {pricing or "ฟรี"}

[TODO: 1-2 sentence value proposition for booking]

**[นัดปรึกษาแพทย์ออนไลน์ ฟรี]** | **[โทร {phone}]** | **[LINE: @{brand}]**

*ไม่แน่ใจว่าตัวเองเป็นหรือเปล่า? ลองทำ [{Quiz/Assessment Tool}](/{path-to-T15})ใช้เวลา {N} นาที*

---

## SECTION 16: แหล่งข้อมูลอ้างอิง

1. {Author lastname}, {first}. ({YYYY}). *{Title}*. {Journal/Publisher}. {URL/DOI}
2. {Citation 2}
3. {Citation 3}
4. {Citation 4}
5. {Citation 5}

[TODO: 5-10 numbered citations matching `citations_used` pool above]

---
---

# Part 2: Technical + Editorial Spec 🔧

> **Note:** ส่วนนี้สำหรับ writer / editor / dev / webmaster. แต่ละ toggle เปิดได้อิสระ. Strip on publish to web.

<details>
<summary>📋 Section Brief — purpose + length per section (writer guide)</summary>

| § | Section Name | Block | Purpose | Required Length | Speakable? | Schema Feeds |
|---|--------------|-------|---------|-----------------|------------|--------------|
| 1 | Hero Summary | B01 | Featured Snippet capture + voice search target. Direct 40-60 word answer to "What is {topic}?" | 40-60 words | ✅ `.speakable-block` | feeds Article + SpeakableSpec |
| 2 | Quick Facts | B02 | Entity Signal — feeds MedicalCondition schema with structured key-values | 6-12 rows | — | feeds MedicalCondition.code, epidemiology |
| 3 | Definition | B04 | "What is X" Featured Snippet target. H2 = literal user question. First paragraph = 40-60 words. | 200-400 words | ✅ second `.speakable-block` | Article body |
| 4 | Causes & Risk Factors | B05 | MedicalRiskFactor entities + cross-cluster link strategy. Categorize anatomical/behavioral/metabolic. | 300-500 words | — | MedicalRiskFactor mentions |
| 5 | Symptoms | B06 | MedicalSymptom entity list. Categorize by timing/observer for patient self-recognition. | 200-400 words | — | MedicalSymptom array |
| 6 | Diagnosis | B07 | DiagnosticProcedure entity + downward links to T3 diagnostic test pages. | 200-400 words | — | MedicalProcedure subtype |
| 7.1-7.4 | Treatment Overview | B08 | MedicalTherapy cluster + Cannibalization Shield (overview only, deep details in T2). | 400-700 words | — | MedicalTherapy array |
| 7.5 | Comparison Table | B09 | Head-to-head query target. Required for T1 if multiple treatments exist. | 7 criteria × N treatments | — | Article |
| 7.6 | Brand Stance | B11a | ⭐ LLMO Pattern E. Required prefix "🎯 จุดยืนของ {brand}:". | 100-200 words | — | Person (author) |
| 8 | Complications | B05/B06 hybrid | Related conditions cluster + cross-cluster authority flow. | 200-300 words | — | MedicalCondition.associatedAnatomy |
| 9 | Clinical Insight + Myth-busting | B12 | Perspective Layer — doctor's voice + 3 misconceptions. | 300-500 words | — | Person quote + Article |
| 10 | Patient Journey | optional | Experience signal. Anonymized cases (PDPA — consent required). | 300-500 words | — | Article |
| 11 | FAQ | B18 | AEO. ≥8 Q&A across ≥7 of 8 intent types: What/Can/Is/How-to/Cost/Difference/Serious/Cross-cluster | ≥8 Q&A | — | FAQPage (DR-019: AI-only) |
| 12 | Crisis Disclosure | B25a | Acute YMYL emergency-trigger callout. REQUIRED if acute risk. | 50-100 words | — | role="alert" |
| 13 | Doctor Review | B19 | E-E-A-T Core Signal. VISUAL + STRUCTURED both required. | — | — | Article.reviewedBy → Physician |
| 14 | Related | B22 | Cross-cluster authority flow. 5-7 deep links. | 5-7 links | — | — |
| 15 | CTA | B20 | Funnel bottom + low-pressure alternative. | — | — | — |
| 16 | References | B21 | External authority links. Numbered citations. | 5-10 entries | — | Article.citation array |

</details>

<details>
<summary>🎨 CSS Class Map per Section</summary>

| § | Section | CSS Class | Purpose |
|---|---------|-----------|---------|
| 1 | Hero Summary | `.speakable-block` | SpeakableSpecification cssSelector target |
| 2 | Quick Facts | `.quick-facts-table` | Entity signal table styling |
| 3 | Definition (1st para) | `.speakable-block` | Second voice-readable section |
| 4 | Risk Factors | `.risk-factors-list` | Categorized list styling |
| 5 | Symptoms | `.symptoms-list` | — |
| 6 | Diagnosis | `.diagnosis-section` | — |
| 7.1-7.4 | Treatments | `.treatment-block` | Per-treatment card |
| 7.5 | Comparison | `.comparison-table` | Sticky header on mobile scroll |
| 7.6 | Brand Stance | `.brand-stance-block` | ⭐ Pattern E callout (brand color gradient) |
| 8 | Complications | `.complications-block` | — |
| 9 | Clinical Insight | `.clinical-insight-block` | Doctor's voice card |
| 9 (myths) | Misconceptions | `.myth-bust-block` | — |
| 10 | Patient Journey | `.patient-journey-card` | Anonymized case styling |
| 11 | FAQ | `.faq-accordion` | Q&A collapsible UI |
| 12 | Crisis Disclosure | `.crisis-disclosure` | Red/orange callout, role="alert" |
| 13 | Doctor Review | `.doctor-review-block` | Reviewer card |
| 14 | Related | `.related-links-cluster` | — |
| 15 | CTA | `.cta-block` + `.cta-sticky` (mobile) | Conversion box |
| 16 | References | `.references-list` | Numbered citations |
| inline | Citables | `.citable-quote` | Per Pattern A-E sentence (subtle accent) — applied programmatically per Citation Map |

</details>

<details>
<summary>📌 Citation Map (Editorial Tracking — replaces inline 📌 markers)</summary>

> **Purpose:** ติดตาม citables ทุกประโยคในหน้านี้ — section, sentence preview, pattern, citation_id.  
> Editorial reviewer ใช้ table นี้ verify accuracy + Pattern coverage.  
> Webmaster apply `.citable-quote` CSS class ตาม section locations.

| Citable # | Section | Sentence Preview | Pattern | Citation ID | Notes |
|-----------|---------|------------------|---------|-------------|-------|
| 1 | §1 Hero | "{first 80 chars of citable sentence}..." | 🟢 A — Clinical Data | cite_PLACEHOLDER_001 | [TODO] |
| 2 | §3 Definition | "{...}" | Tier {N} External | cite_PLACEHOLDER_002 | — |
| 3 | §4 Risk Factors | "{...}" | 🟢 A — Clinical Data | cite_VTH_INTERNAL_xxx | brand_scope=['{brand}'] |
| 4 | §4 Risk Factors | "{...}" | Tier 1 External | cite_PLACEHOLDER_003 | — |
| 5 | §5 Symptoms | "{...}" | Tier 1 External | cite_PLACEHOLDER_004 | — |
| 6 | §6 Diagnosis | "{...}" | 🟡 C — Lab Test | cite_PLACEHOLDER_005 | — |
| 7 | §7.1 Treatment | "{...}" | Tier 1 External | cite_PLACEHOLDER_006 | — |
| 8 | §7.1 Treatment | "{...}" | 🟢 A — Clinical Data | cite_VTH_INTERNAL_xxx | — |
| 9 | §7.2 Treatment | "{...}" | Tier 1 External | cite_PLACEHOLDER_007 | — |
| 10 | §7.5 Comparison | "{...}" | 🟢 A — Clinical Data | cite_VTH_INTERNAL_xxx | — |
| 11 | §7.6 Brand Stance | "🎯 จุดยืนของ {brand}: {...}" | 🟣 E — Brand Stance | cite_VTH_INTERNAL_xxx | ⭐ LLMO superweapon |
| 12 | §7.6 Brand Stance | "🎯 จุดยืนของ {brand}: {...}" | 🟣 E — Brand Stance | cite_VTH_INTERNAL_xxx | ⭐ |
| 13 | §8 Complications | "{...}" | Tier 1 External | cite_PLACEHOLDER_008 | — |
| 14 | §8 Complications | "{...}" | Tier 1 External | cite_PLACEHOLDER_009 | — |
| 15 | §9 Clinical Insight | "{...}" | 🟢 A — Clinical Data | cite_VTH_INTERNAL_xxx | — |
| 16 | §9 Clinical Insight | "{...}" | 🟢 A — Clinical Data | cite_VTH_INTERNAL_xxx | — |
| 17 | §9 Clinical Insight | "{...}" | 🟢 A — Clinical Data | cite_VTH_INTERNAL_xxx | — |

**Pattern coverage required (per template T1):**
- Pattern A (🟢): minimum 3 ← currently {N} ← ✅/❌
- Pattern E (🟣): minimum 1 ← currently {N} ← ✅/❌
- B/C/D: optional

</details>

<details>
<summary>🏗️ Schema Markup Implementation (Tier 1/2/3)</summary>

### Tier 1: Site-Level (header.php — eywa-core, every page)

```jsonld
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": ["Organization", "MedicalBusiness", "{specific subtype}"],
      "@id": "https://{brand}.com/#organization",
      "name": "{Brand Name}",
      "url": "https://{brand}.com",
      "logo": "https://{brand}.com/logo.png",
      "medicalSpecialty": ["{Specialty 1}", "{Specialty 2}"],
      "hasCredential": ["{Accreditation 1}"],
      "member": [
        {
          "@type": ["Person", "Physician"],
          "@id": "https://{brand}.com/our-doctors/{slug}#person",
          "name": "{Dr. Name}",
          "honorificPrefix": "{prefix}",
          "honorificSuffix": "{credentials}",
          "jobTitle": "{title}",
          "medicalSpecialty": "{specialty}"
        }
      ]
    },
    {
      "@type": "WebSite",
      "@id": "https://{brand}.com/#website",
      "url": "https://{brand}.com",
      "name": "{Brand Name}",
      "publisher": {"@id": "https://{brand}.com/#organization"}
    }
  ]
}
```

### Tier 2: Page-Level (ACF-driven, per-page)

```jsonld
{
  "@type": "MedicalCondition",
  "@id": "https://{brand}.com/{slug}/#condition",
  "name": "{Topic Name (TH)}",
  "alternateName": "{English Term}",
  "code": [
    {"@type": "MedicalCode", "code": "{ICD-10}", "codingSystem": "ICD-10-CM"},
    {"@type": "MedicalCode", "code": "{SNOMED}", "codingSystem": "SNOMED-CT"}
  ],
  "epidemiology": "{prevalence statement}",
  "signOrSymptom": [
    {"@type": "MedicalSymptom", "name": "{symptom 1}"},
    {"@type": "MedicalSymptom", "name": "{symptom 2}"}
  ],
  "riskFactor": [
    {"@type": "MedicalRiskFactor", "name": "{risk factor 1}"}
  ],
  "possibleTreatment": [
    {"@type": "MedicalTherapy", "name": "{treatment 1}"}
  ]
},
{
  "@type": "MedicalWebPage",
  "@id": "https://{brand}.com/{slug}/#webpage",
  "url": "https://{brand}.com/{slug}",
  "headline": "{H1}",
  "description": "{meta description}",
  "datePublished": "{ISO 8601}",
  "dateModified": "{ISO 8601}",
  "lastReviewed": "{ISO 8601 date}",
  "author": {"@id": "https://{brand}.com/our-doctors/{slug}#person"},
  "reviewedBy": {"@id": "https://{brand}.com/our-doctors/{slug}#person"},
  "medicalAudience": {
    "@type": "MedicalAudience",
    "audienceType": "Patient"
  },
  "about": {"@id": "https://{brand}.com/{slug}/#condition"},
  "citation": [
    {
      "@type": "ScholarlyArticle",
      "name": "{citation 1 title}",
      "author": "{authors}",
      "datePublished": "{year}",
      "url": "{url}"
    }
  ],
  "isPartOf": {"@id": "https://{brand}.com/#website"},
  "publisher": {"@id": "https://{brand}.com/#organization"}
}
```

### Tier 3: Content-Level (in-body blocks)

```jsonld
{
  "@type": "FAQPage",
  "@id": "https://{brand}.com/{slug}/#faq",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "{Q1 text}",
      "acceptedAnswer": {"@type": "Answer", "text": "{A1 text}"}
    }
    // ... 7+ more questions
  ]
},
{
  "@type": "SpeakableSpecification",
  "cssSelector": [".speakable-block"]
},
{
  "@type": "BreadcrumbList",
  "itemListElement": [
    {"@type": "ListItem", "position": 1, "name": "{Section}", "item": "{URL}"},
    {"@type": "ListItem", "position": 2, "name": "{Sub-section}", "item": "{URL}"},
    {"@type": "ListItem", "position": 3, "name": "{This page}", "item": "{URL}"}
  ]
}
```

### Forbidden Schemas (per DR-019 March 2026 deprecations — DO NOT EMIT)

`CourseInfo`, `ClaimReview`, `EstimatedSalary`, `LearningVideo`, `SpecialAnnouncement`, `VehicleListing`, `PracticeProblem`

</details>

<details>
<summary>🔧 ACF Field Mapping (per T1 ACF Field Group)</summary>

| ACF Field | § | Type | Notes |
|-----------|---|------|-------|
| `field_focus_keyword` | SEO Brief | text | from On-Page SEO Brief |
| `field_related_keywords` | SEO Brief | repeater | secondary keywords array |
| `field_seo_title` | SEO Brief | text | 50-60 chars |
| `field_meta_description` | SEO Brief | textarea | 120-155 chars |
| `field_hero_summary` | §1 | textarea | 40-60 words enforced |
| `field_quick_facts` | §2 | repeater (label + value) | 6-12 rows |
| `field_definition_intro` | §3 | wysiwyg | 200-400 words |
| `field_severity_grading` | §3 | repeater (optional) | If condition has grading |
| `field_risk_factors_anatomical` | §4 | repeater | per factor: name + mechanism + citation_id |
| `field_risk_factors_behavioral` | §4 | repeater | per factor |
| `field_symptoms_phase1` | §5 | repeater | per symptom |
| `field_diagnostic_methods` | §6 | repeater (linked to T3 pages) | 2-4 methods |
| `field_treatments` | §7.1-7.4 | repeater (linked to T2 pages) | 3-5 treatments + sub-fields |
| `field_comparison_table` | §7.5 | repeater (rows) | 5-7 criteria × N treatments |
| `field_brand_stance` | §7.6 | wysiwyg | MUST start with "🎯 จุดยืนของ {brand}:" |
| `field_complications` | §8 | repeater (system + complications) | |
| `field_clinical_insight_quote` | §9 | textarea | doctor quote |
| `field_clinic_data_points` | §9 | repeater (Pattern A citables) | |
| `field_myths` | §9 | repeater (3+ myths) | |
| `field_patient_journeys` | §10 | repeater (optional) | 1-3 cases |
| `field_faq` | §11 | repeater (Q + A + intent_type) | ≥8 entries |
| `field_crisis_disclosure` | §12 | wysiwyg (conditional) | Only if condition has acute risk |
| `field_doctor_reviewer` | §13 | relation → seo_authors | REQUIRED |
| `field_related_links` | §14 | repeater (link + context) | 5-7 links |
| `field_cta_primary` | §15 | wysiwyg | |
| `field_references` | §16 | repeater (linked to seo_citations) | matches `citations_used` pool |

</details>

<details>
<summary>🔗 Internal Link Checklist</summary>

- → `/our-doctors/{reviewer-slug}` (§13 — Doctor profile T9)
- → `/{topic-cluster-hub}` (§14 — Topic Hub T12)
- → `/services/{primary-treatment-1}` (§7.1 — T2)
- → `/services/{primary-treatment-2}` (§7.2 — T2)
- → `/services/{primary-treatment-3}` (§7.3 — T2)
- → `/case-studies/{relevant-cases}` (§10 — T8)
- → `/diagnostic/{primary-test}` (§6 — T3)
- → `/quiz/{self-assessment-quiz}` (§5 + §15 — T15)
- → `/related-condition-1` (§14 — T1 sibling)

Total target: ≥5 internal links

</details>

<details>
<summary>🖼️ Image Specs (placeholder for image team)</summary>

| Image | § | Specs | Alt-text Pattern | Lazy-load |
|-------|---|-------|------------------|-----------|
| Hero | §1 | 1920×1080 | "{descriptive — Topic + visual cue}" | false |
| Anatomy diagram | §3 | 800×600 | "{anatomy of topic}" | true |
| Severity chart | §3 | 600×400 | "{severity grading visual}" | true |
| Symptom infographic | §5 | 800×600 | "{symptom checklist}" | true |
| Diagnostic photo | §6 | 800×600 | "{diagnostic procedure visual}" | true |
| Treatment device | §7.1 | 800×600 | "{treatment device}" | true |
| Comparison visual | §7.5 | 1200×800 | "{treatment comparison}" | true |
| Doctor portrait | §13 | 400×400 | "{Dr. Name} — {credentials}" | false |
| Branch photo | §15 | 1200×600 | "{Brand} {branch name}" | true |

</details>

<details>
<summary>🤖 Predicted Prompts Bank — B26 (off-render planning artifact)</summary>

> ≥15 prompts × ≥7 of 8 intents. Syncs to `seo_predicted_prompts` table on publish.

**Intent types coverage:**
- `definitional`: "What is X" / "X คืออะไร"
- `informational`: How does X work / Why
- `comparison`: A vs B
- `decision`: Should I get X / What's best
- `troubleshooting`: Why am I X
- `how-to`: How to do X
- `voice` / `voice-local`: Voice search variants
- `transactional`: Cost, pricing
- `navigational`: Brand-specific queries

| # | Prompt (TH) | Prompt (EN) | Intent | Priority | Answer § | Expected Citables | Competitors Likely |
|---|-------------|-------------|--------|----------|----------|-------------------|---------------------|
| 1 | {topic}คืออะไร? | What is {topic}? | definitional | critical | §1, §3 | C1, C3 | {comp1}, {comp2} |
| 2 | {topic}เกิดจากอะไร? | What causes {topic}? | informational | high | §4 | C2, C4 | {comp1} |
| 3 | {topic}อันตรายแค่ไหน? | How serious is {topic}? | informational | high | §8 | C5, C6 | {comp1} |
| 4 | ตรวจ{topic}ทำที่ไหน? | Where to test {topic}? | how-to + voice-local | high | §6 | C7 | {comp1} |
| 5 | รักษา{topic}แบบไหนดี? | What's the best treatment for {topic}? | decision | critical | §7.5, §7.6 | C8 (Pattern E) | {comp1} |
| 6 | {Tx1} หรือ {Tx2} ดีกว่า? | {Tx1} vs {Tx2} which is better? | comparison | critical | §7.5 | C9 | {comp1} |
| 7 | ค่ารักษา{topic}เท่าไหร่? | Cost of {topic} treatment? | transactional | high | §7.5, §15 | C10 | {comp1} |
| 8 | ทำไมฉัน{symptom}? | Why do I have {symptom}? | troubleshooting | medium | §5, §4 | C2, C5 | {comp1} |
| 9 | {topic}รักษาหายไหม? | Can {topic} be cured? | informational | high | §7 | C8 | {comp1} |
| 10 | นัดหมอเรื่อง{topic} ที่ {Brand} | Book {Brand} for {topic} | navigational | high | §15 | - | - |
| 11 | "Hey Google, {topic} symptoms" | (voice) | voice | medium | §5 | C5 | - |
| 12 | {topic}ใกล้ฉัน | {topic} near me | voice-local | high | §15 (with branch) | - | {comp1} |
| 13 | {Variant A} ต่างจาก {Variant B}? | {A} vs {B} difference | comparison | medium | §7.5, §11 Q7 | C9 | {comp1} |
| 14 | เด็กเป็น{topic}ได้ไหม? | Can children have {topic}? | informational | medium | §11 Q6 | - | - |
| 15 | {topic}กับ{related condition} | {topic} and {related} | cross-cluster | medium | §8 | - | {comp1} |

[TODO: Add 1-15 more for total 15-30 prompts. Cover all 8 intent types minimum 2 each.]

</details>

<details>
<summary>📝 Dev Notes & Validation Checklist</summary>

## Dev Notes / Known Caveats

- [TODO: Anything dev/webmaster needs to know that's not obvious]
- [TODO: Edge cases for this specific page]
- [TODO: Known limitations or pending items]
- [TODO: Coordination needed with other teams (image, n8n, etc.)]

## Cannibalization Shield Check (per Content_Templates §4.5.3)

✅ This page covers DISEASE/CONDITION only:
- Risk factors, symptoms, diagnosis OVERVIEW, treatment OVERVIEW
- Full treatment details → linked to T2 pages (§7.1-7.3)
- Full diagnostic details → linked to T3 pages (§6)
- Case examples → brief here; full cases → T8

❌ AVOID on this page:
- Step-by-step treatment procedures (those belong on T2)
- Detailed diagnostic protocols (those belong on T3)
- Pricing tables (general ranges OK; full pricing → T13)
- Educational concept depth (high-level only; details → T6)

## Validation Checklist Before Publish

- [ ] All REQUIRED blocks present (B01, B02, B04, B05-B08, B12, B18, B19, B20, B21, B22)
- [ ] Word count meets §9.8 L4 target (2,500-4,000)
- [ ] On-Page SEO Brief filled — title 50-60 chars, meta 120-155 chars
- [ ] ≥3 Pattern A citables tracked in Citation Map
- [ ] ≥1 Pattern E (Brand Stance) with required prefix in §7.6
- [ ] ≥8 FAQ entries across ≥7 of 8 intent types
- [ ] B25a Crisis Disclosure if condition has acute risk (else justify omission in Dev Notes)
- [ ] Schema reviewedBy = Physician (NOT WP admin)
- [ ] lastReviewed property in JSON-LD
- [ ] medicalAudience = Patient
- [ ] Organization schema typed as MedicalBusiness with member array
- [ ] All citations have evidence_tier 1-3 (Tier 4-6 only as supplementary)
- [ ] Cannibalization Shield check passed
- [ ] Internal links to ≥5 EYWA pages (T2/T3/T8/T9/T12)
- [ ] Predicted Prompts table ≥15 entries
- [ ] All [TODO: ...] markers resolved

</details>

---

<!--
END OF T1 SKELETON v1.2
Generated from Content_Templates_EYWA_v1_0.md v1.1 spec
Refactored 2026-05-10: strict Part 1/Part 2 separation per operator review
References:
- Bible v3.14 (philosophy + section guidelines)
- Schema v1.10 (page_master columns + citation tables)
- Content_Templates v1.1 (this template's source spec)
- DR-017 (content_brief), DR-018 (length standards), DR-019 (schema), DR-020 (templates)
-->
