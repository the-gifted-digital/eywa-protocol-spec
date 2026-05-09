# 📝 Content Templates — EYWA™ PROTOCOL

> **Companion document to** EYWA Bible v3.14 + Schema Overview v1.10
> **Universal Content Production Standards across 13 brands × 6 verticals**

**Version:** v1.0 (DRAFT 2026-05-10)
**Status:** Proposed — pending DR-020 lock
**Companion to:** Bible v3.14 + Schema Overview v1.10 + DECISION_RECORDS v1.5
**Format:** Append-only with semantic versioning (v1.0 → v1.1 backward compatible)

---

## 📌 What This Document Is

ไฟล์มาตรฐานการเขียน content บนเว็บไซต์ ภายใต้ EYWA Protocol ecosystem.
**Lock มาตรฐาน + เปิดช่อง tweak ตาม content type** — ใช้ร่วมกับ Bible (philosophy) และ Schema (database).

**Scope:**
- 25 content type templates (ครอบคลุม 6 verticals × 13 brands)
- ~25 universal section building blocks (lego architecture)
- EEAT requirement matrix (locked)
- Customization hooks per brand

**Out of scope:**
- Visual/CSS design tokens (อยู่ใน Bible Part 9)
- Schema generation logic (อยู่ใน Bible Part 26 + eywa-schema-pipeline plugin)
- Editorial workflow (อยู่ใน Bible Part 23.4)

> **คำเตือน:** Templates ใน document นี้ = "การจัดวางเนื้อหา" ไม่ใช่ "เนื้อหาที่ต้องเขียน". เนื้อหาจริงต้องสะท้อน brand voice + medical accuracy + EYWA citable formulas (Bible Part 6) เสมอ.

---

## 1. Architecture — 3-Layer Composition System

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Customization Hooks (per-brand tweaks)             │
│ - block_substitution / block_addition / block_removal       │
│ - HARD RULE: never remove REQUIRED blocks                   │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │ composed from
                          │
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Content Type Templates (25 templates)              │
│ - Core Universal (12) | T2 Variants (5) | Specialized (7)   │
│ - Define: required/recommended/optional blocks per type     │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │ assembled from
                          │
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Universal Section Building Blocks (~25 blocks)     │
│ - Atomic units. Each has purpose, structure, schema mapping │
└─────────────────────────────────────────────────────────────┘
```

**Why 3-layer:**
- Layer 1 (blocks) = LEGO units — high reuse, version stable
- Layer 2 (templates) = recipe combining blocks — content-type specific
- Layer 3 (customization) = brand identity — flexibility without breaking standard

---

## 2. Layer 1 — Universal Section Building Blocks

แต่ละ block = 1 atomic content unit ที่ template ดึงไปประกอบ.

### 2.1 Hero & Summary Blocks

```yaml
B01_hero_summary:
  purpose: "Speakable Block + Featured Snippet capture"
  structure: |
    1 paragraph (40-60 words) — direct definition + key qualifier + outcome
    Marked with class="speakable-block"
  schema_emit: SpeakableSpecification (cssSelector → this block)
  required_in: ALL templates (universal)
  position: top of page, immediately after H1
  example_source: VTH Mouth BioMapping line 9, sample sleep apnea SECTION 1

B02_quick_facts_table:
  purpose: "Entity Signal + Citable Data Cluster"
  structure: |
    Table with 6-12 rows — key facts about the entity
    Required rows: TH name, EN name, ICD/SNOMED codes, prevalence, who reviews
  schema_emit: feeds entity Article schema with structured key-value pairs
  required_in: T1, T2 (medical), T3, T4
  example_source: sample sleep apnea SECTION 2

B03_at_a_glance_summary:
  purpose: "TL;DR for impatient readers + AI summary feed"
  structure: "3-5 bullet points covering the 80/20 of the page"
  required_in: T6a Guide (because Guide is long-form)
  optional_in: T1, T2, T7
```

### 2.2 Definition & Educational Blocks

```yaml
B04_definition:
  purpose: '"What is X" query target'
  structure: |
    H2 = "X คืออะไร?" (literal user question)
    Paragraph 1: 40-60 word direct definition (Featured Snippet)
    Paragraph 2-3: expand with mechanism / context
  schema_emit: DefinedTerm (if standalone), Article body (if part of larger)
  required_in: T1, T2, T3, T4, T6, T6a, T18

B05_causes_risk_factors:
  purpose: "MedicalRiskFactor entity + cross-cluster links"
  structure: |
    Subheadings by category (anatomical / behavioral / metabolic)
    Each factor: name + brief mechanism + evidence citation
  schema_emit: MedicalRiskFactor mentions
  required_in: T1
  optional_in: T2, T3 (if procedure responds to specific risk)

B06_symptoms_signs:
  purpose: "MedicalSymptom entity list + patient self-recognition"
  structure: |
    Categorized lists: during sleep / morning / daytime (or relevant)
    Each: symptom name + frequency + clinical note
  schema_emit: MedicalSymptom array
  required_in: T1
  optional_in: T2 (if procedure addresses specific symptom)

B07_diagnostic_section:
  purpose: "DiagnosticProcedure entity + downward links"
  structure: |
    Each diagnostic option: name + when used + accuracy + duration + cost
    Comparison if multiple options exist
  schema_emit: MedicalProcedure subtype
  required_in: T1, T3
  optional_in: T2

B08_treatment_section:
  purpose: "MedicalTherapy entity cluster + cannibalization shield"
  structure: |
    Each treatment option: mechanism + indications + efficacy + drawbacks
    Often paired with B09 comparison_table
  schema_emit: MedicalTherapy array
  required_in: T1, T2
  optional_in: T7
```

### 2.3 Decision-Making & Comparison Blocks

```yaml
B09_comparison_table:
  purpose: "Head-to-head query target (e.g., 'CPAP vs Oral Appliance')"
  structure: |
    Table: rows = comparison criteria, columns = options
    Required criteria: efficacy, cost, suitability, limitations, success rate
  schema_emit: feeds Article + can support QAPage if used as answer
  required_in: T7
  optional_in: T1, T2, T6a
  example_source: sample sleep apnea SECTION 7.5

B10_brand_stance:
  purpose: "Pattern E LLMO — brand-specific recommendation"
  structure: |
    H3 = "🎯 จุดยืนของ {brand}: {stance}"
    Body: 1-2 paragraphs with brand's data + reasoning
    Citable formula: brand data point with year
  schema_emit: feeds Article + Person (author) reasoning
  required_in: T7 (comparison must take stance)
  recommended_in: T1, T2, T6a (where relevant)
  example_source: sample sleep apnea SECTION 7.6

B11_decision_framework:
  purpose: "If/then guidance — when to choose what"
  structure: |
    Conditional logic in plain language
    e.g., "ถ้า OSA รุนแรง → CPAP first / ถ้า OSA เล็กน้อย → Oral Appliance"
  required_in: T6a Guide, T7 Comparison
  optional_in: T1, T2

B12_clinical_insight:
  purpose: "Perspective Layer — expert voice from clinic"
  structure: |
    Quote from doctor + clinic data + myth-busting
    1-3 misconceptions addressed
  schema_emit: feeds Person (doctor) reputation + Article
  recommended_in: T1, T2, T6a
  example_source: sample sleep apnea SECTION 8.5
```

### 2.4 Procedure & Process Blocks

```yaml
B13_process_steps:
  purpose: "HowTo emission for procedure pages"
  structure: |
    Numbered steps 1-N
    Each: name + duration + what happens + patient experience
  schema_emit: HowTo + HowToStep (per DR-019: AI-only consumption post-June 2026)
  required_in: T2, T2a, T2b, T2c, T2d, T17

B14_preparation_checklist:
  purpose: "Pre-procedure / Pre-visit checklist"
  structure: |
    Bulleted list of what to do/bring/avoid before
  required_in: T17
  recommended_in: T2, T2a, T2b, T6a (Guide)

B15_aftercare_recovery:
  purpose: "Post-procedure care + timeline"
  structure: |
    Day-by-day or phase-by-phase guidance
    Red flags requiring contact
  required_in: T2a, T2b, T17
  recommended_in: T2

B16_before_after_gallery:
  purpose: "Visual evidence of outcome"
  structure: |
    Image pairs with: timeframe, treatment notes, photographer credit
    PDPA compliance required (consent on file)
  schema_emit: ImageObject array + (CaseStudy if narrated)
  required_in: T2a Aesthetic
  recommended_in: T2b Dental, T8 Case Study
```

### 2.5 Trust & Conversion Blocks

```yaml
B17_pricing_block:
  purpose: "Commercial intent capture + transparency"
  structure: |
    Price ranges + what's included/excluded + payment options
    Disclaimers about case-specific variation
  schema_emit: Offer + PriceSpecification
  required_in: T5, T13, T19
  recommended_in: T2, T2b, T2c

B18_faq_block:
  purpose: "AEO + Featured Snippet capture (post-DR-019: AI-only)"
  structure: |
    8 FAQ Types (Bible Part 6.X):
    [What is X], [Can X], [Is X], [How to X], [How serious is X],
    [Difference between X and Y], [Cost of X], [Who is X for]
  schema_emit: FAQPage + Question + Answer (per DR-019: emit but expect zero SERP)
  required_in: T1, T2, T6, T6a, T7, T12
  example_source: sample sleep apnea SECTION 9

B19_doctor_review_block:
  purpose: "E-E-A-T Core Signal — both visual AND structured"
  structure: |
    Doctor name + credentials (DDS, MD, etc.) + specialty + photo
    Last reviewed date + Next review due
    Link to doctor profile (T9)
    SCHEMA REQUIREMENT: must emit Person/Physician schema linked
    via reviewedBy property on Article schema (NOT just visual)
  schema_emit: |
    Article {
      "reviewedBy": {
        "@type": ["Person", "Physician"],
        "name": "...",
        "honorificSuffix": "...",
        "medicalSpecialty": "...",
        "memberOf": "...",
        "url": "..."
      },
      "lastReviewed": "ISO 8601 date"
    }
  required_in: ALL T1, T2 (+variants), T3, T4, T5 (if claims), T6 (if YMYL),
                T6a, T7, T8, T14 (if YMYL), T15, T17
  not_required_in: T9 (page IS the doctor), T10, T11, T13 (pure pricing),
                   T16, T18, T19

B20_cta_block:
  purpose: "Funnel bottom conversion point"
  structure: |
    1-3 primary CTAs + booking method options + alternative low-pressure CTA
  required_in: T1, T2, T2a-e, T5, T7, T8, T13, T17, T18, T19
  example_source: sample sleep apnea SECTION 12

B21_references_block:
  purpose: "External authority links + medical E-E-A-T signal"
  structure: |
    Numbered citations with: authors, year, title, journal, link
    Tier classification (per Bible Part 23.1) tracked internally
  schema_emit: |
    Article {
      "citation": [
        {"@type": "ScholarlyArticle", "name": "...", "datePublished": "..."},
        ...
      ]
    }
  required_in: T1, T2, T3, T6, T6a, T7, T8, T14, T17
  example_source: sample sleep apnea SECTION 13
```

### 2.6 Cross-Linking & Navigation Blocks

```yaml
B22_related_links_cluster:
  purpose: "Sideway links + cross-cluster authority flow"
  structure: |
    3-7 related pages with: title + 1-line context why related
  required_in: ALL templates except T11 (institutional has site nav)

B23_internal_link_cta:
  purpose: "Inline →[link] within body — directs to deeper page"
  structure: |
    Inline arrow + link text + brief context
  required_in: ALL templates (organic content placement)

B24_branch_doctor_card:
  purpose: "Branch-level EEAT — who provides service AT this location"
  structure: |
    Doctor at branch: name + credentials + specialty + photo
    Available days/hours
  schema_emit: Person + (Place via branch link)
  required_in: T10, T18
```

### 2.7 Compliance & Legal Blocks

```yaml
B25_safety_disclosures:
  purpose: "Medical disclaimers + side effect / contraindication transparency"
  structure: |
    Bulleted list of: contraindications, side effects, warnings
    Plain language, no medical jargon hiding risk
  required_in: T2, T2a-e, T4 (devices with risk profile), T17
```

---

## 3. Layer 2 — Content Type Templates (25)

### 3.1 Core Universal Templates (12)

#### T1 — Medical Condition (โรค/ภาวะ)

```yaml
purpose: "Patient-facing disease/condition page (clinical or patient-language)"
schema_org_type: MedicalCondition
secondary_schemas: [Article, FAQPage]
layer_mapping: L4 pillar (primary) | L5 supporting
length_target: 2,500-4,000 words (per Bible §9.8)
eeat_required: YES — author + medical_reviewer + last_reviewed mandatory

required_blocks:
  - B01 hero_summary
  - B02 quick_facts_table
  - B04 definition
  - B05 causes_risk_factors
  - B06 symptoms_signs
  - B07 diagnostic_section
  - B08 treatment_section
  - B09 comparison_table (if multiple treatments exist)
  - B12 clinical_insight
  - B18 faq_block
  - B19 doctor_review_block
  - B22 related_links_cluster
  - B20 cta_block
  - B21 references_block

recommended_blocks:
  - B10 brand_stance (where clinic has differentiated approach)
  - B16 before_after_gallery (if visual outcome relevant)

modes:
  clinical_language: "Use ICD/SNOMED-aligned naming, formal tone"
  patient_language: "Use search-intent matching ('ฟันเหลือง', not 'Tooth Discoloration')"
  
allowed_tweaks:
  - B05 + B06 can be merged if condition is simple
  - B09 can be omitted if only 1 treatment exists
  - B12 can be deferred to update cycle (placeholder OK on launch)

reference_implementation: |
  - sample sleep apnea (in /Volumes/SSD NN/CLAUDE AI/legacy/Sitemap Deezy/VTH Biodent/ตัวอย่างเนื้อหา 355be9c6bf3c806fadabe4828a694200.md)
  - VTH Mouth BioMapping (vthbiodent.com/mouth-biomapping/) — ⚠️ visual EEAT good, structured EEAT broken (see §6)
```

#### T2 — Medical Procedure / Treatment (รักษา/หัตถการ generic)

```yaml
purpose: "Clinical procedure page — generic, applies across verticals"
schema_org_type: MedicalProcedure
secondary_schemas: [Service, Article]
layer_mapping: L2 money | L4 pillar
length_target: 2,000-3,500 words
eeat_required: YES

required_blocks:
  - B01 hero_summary
  - B04 definition
  - B07 diagnostic_section (when this procedure indicated)
  - B13 process_steps
  - B14 preparation_checklist
  - B15 aftercare_recovery
  - B17 pricing_block
  - B18 faq_block
  - B19 doctor_review_block
  - B22 related_links_cluster
  - B20 cta_block
  - B21 references_block
  - B25 safety_disclosures

recommended_blocks:
  - B09 comparison_table (vs alternative procedures)
  - B10 brand_stance
  - B12 clinical_insight
  - B16 before_after_gallery
  - B02 quick_facts_table

allowed_tweaks: "Pricing block can defer to T13 link if pricing is complex"
```

#### T3 — Diagnostic Procedure / Test

```yaml
purpose: "Test/screening page — Sleep Study, ABI, CBCT, hormone panel, etc."
schema_org_type: MedicalProcedure (subtype: diagnostic)
secondary_schemas: [Article, FAQPage]
layer_mapping: L2 | L3
length_target: 1,500-2,500 words
eeat_required: YES

required_blocks:
  - B01, B04, B13, B14, B15, B17, B18, B19, B20, B21, B22

recommended_blocks:
  - B02 quick_facts_table (test specs)
  - B09 comparison_table (vs other tests)
  - B12 clinical_insight (when interpret results)

allowed_tweaks: "B15 simplified or omitted if no aftercare needed (e.g., simple blood draw)"
```

#### T4 — Medical Device / Technology

```yaml
purpose: "Equipment/technology page — Fotona, Waterlase, EMFACE, CPAP machines"
schema_org_type: MedicalDevice
secondary_schemas: [Product, Article]
layer_mapping: L3
length_target: 1,500-2,500 words
eeat_required: YES (device claims need clinical reviewer)

required_blocks:
  - B01 hero_summary
  - B04 definition (how it works)
  - B02 quick_facts_table (specs: wavelength, power, FDA approval)
  - "B26 indications_who_benefits" (custom block — when this tech is used)
  - B17 pricing_block (or link to T5)
  - B18 faq_block
  - B19 doctor_review_block
  - B22 related_links_cluster
  - B20 cta_block
  - B21 references_block

recommended_blocks:
  - B09 comparison_table (vs prior generation tech)
  - B10 brand_stance (why this clinic chose this device)
  - B25 safety_disclosures
```

#### T5 — Service / Money Page (commercial L2)

```yaml
purpose: "Bundled service offering — primary commercial conversion"
schema_org_type: Service
secondary_schemas: [MedicalProcedure, Offer]
layer_mapping: L2
length_target: 1,500-2,500 words (Bible §9.8)
eeat_required: YES if claims medical outcome

required_blocks:
  - B01 hero_summary
  - "B27 who_is_it_for" (custom block — eligibility)
  - B13 process_steps (overview, link to T2 for detail)
  - B17 pricing_block (FULL — this is the page)
  - B18 faq_block (purchase-decision questions)
  - B19 doctor_review_block (if medical claims)
  - B22 related_links_cluster
  - B20 cta_block

recommended_blocks:
  - B09 comparison_table (vs competitor offerings or alternatives)
  - B16 before_after_gallery
```

#### T6 — Concept / Knowledge Article

```yaml
purpose: '"What is sleep medicine?" / "What is implantology?" — neutral education'
schema_org_type: Article
secondary_schemas: [DefinedTerm, FAQPage]
layer_mapping: L5 knowledge
length_target: 2,000-3,500 words (Bible §9.8)
eeat_required: REQUIRED if YMYL (medical/health), RECOMMENDED otherwise

required_blocks:
  - B01 hero_summary
  - B04 definition
  - "B28 why_it_matters" (custom — context for reader)
  - B22 related_links_cluster
  - B21 references_block

recommended_blocks:
  - B12 clinical_insight (if YMYL)
  - B19 doctor_review_block (if YMYL)
  - B18 faq_block

allowed_tweaks: |
  HIGHEST FLEXIBILITY — content type ranges from glossary entries (300 words)
  to comprehensive concept pieces (3,500 words). Use mode:
  
  modes:
    light: "200-500 words for glossary-style entries (single term)"
    standard: "1,500-2,500 words for typical concept article"
    comprehensive: "3,000+ words for cornerstone concept pillar"
```

#### T6a — Guide (Action-Oriented Long-Form) 🆕 v1.0

```yaml
purpose: "Comprehensive guide — 'คู่มือฉบับสมบูรณ์', step-by-step actionable"
schema_org_type: Article
secondary_schemas: [HowTo (sub-blocks), FAQPage]
layer_mapping: L5 pillar
length_target: 4,000-7,000 words (long-form for comprehensive coverage)
eeat_required: YES

required_blocks:
  - B01 hero_summary
  - B03 at_a_glance_summary (TL;DR for impatient readers)
  - B04 definition (quick — 200 words max)
  - "B29 step_flow_overview" (custom — visual timeline of phases)
  - B11 decision_framework (when to choose what)
  - B17 pricing_block (cost summary)
  - B14 preparation_checklist
  - B15 aftercare_recovery
  - B18 faq_block
  - B19 doctor_review_block
  - B22 related_links_cluster (deep links to specific topic articles)
  - B20 cta_block
  - B21 references_block

recommended_blocks:
  - B09 comparison_table
  - B12 clinical_insight
  - B25 safety_disclosures

distinguishes_from_T6: |
  - Action-oriented (reader will DO something)
  - Comprehensive single-page (vs T6 which can be focused)
  - Always long-form
  - Contains decision frameworks
  - Always includes cost/preparation/aftercare summaries

example_pages:
  - "คู่มือจัดฟันตั้งแต่เริ่มจนถอดเครื่องมือ" (Deezy 6.1.2)
  - "คู่มือรากเทียม — ทุกขั้นตอนที่ต้องรู้" (Deezy 6.1.3)
  - "คู่มือสิทธิ์ประกันสังคมทันตกรรม" (Deezy 6.1.12)
```

#### T7 — Comparison Page

```yaml
purpose: "Head-to-head — must take stance, not neutral list"
schema_org_type: Article
secondary_schemas: [FAQPage]
layer_mapping: L4 | L5
length_target: 1,500-2,500 words
eeat_required: YES (recommendation = health choice)

required_blocks:
  - B01 hero_summary
  - "B30 contenders_intro" (custom — brief intro to each option)
  - B09 comparison_table (CORE of this template)
  - B11 decision_framework
  - B10 brand_stance (REQUIRED — this template demands stance)
  - B18 faq_block
  - B19 doctor_review_block
  - B22 related_links_cluster
  - B20 cta_block
  - B21 references_block

recommended_blocks:
  - B12 clinical_insight

example_pages:
  - "CPAP vs Oral Appliance" (sleep)
  - "Implant vs Bridge vs Denture" (Deezy 6.3.19)
  - "Damon vs Self-Ligating vs Conventional" (Deezy 6.3.22)
```

#### T8 — Case Study / Patient Outcome

```yaml
purpose: "L7 evidence — patient story OR clinical reasoning teaching case"
schema_org_type: MedicalScholarlyArticle
secondary_schemas: [(CaseStudy if available)]
layer_mapping: L7
length_target: 1,500-2,500 words (Bible §9.8)
eeat_required: YES (clinical claim)

required_blocks:
  - B01 hero_summary
  - "B31 patient_profile" (anonymized: age, gender, presenting concern)
  - "B32 presenting_problem" (symptoms, history)
  - B07 diagnostic_section (what tests, results)
  - B13 process_steps (treatment plan)
  - "B33 outcome_results" (before/after measurements, timeline)
  - B16 before_after_gallery (if visual)
  - B19 doctor_review_block
  - B22 related_links_cluster
  - B25 safety_disclosures (PDPA — patient consent on file)

modes:
  patient_story: "Audience = potential patients, narrative + emotional + outcome-focused"
  clinical_reasoning: "Audience = sophisticated patient/clinician, diagnostic logic emphasized"

recommended_blocks:
  - B12 clinical_insight (doctor's reflection)
```

#### T9 — Author / Doctor Profile

```yaml
purpose: "Physician/team member page — IS the EEAT signal"
schema_org_type: Person
secondary_schemas: [Physician]
layer_mapping: L1 (team)
length_target: 800-1,500 words
eeat_required: SELF (page is its own reviewer)

required_blocks:
  - "B34 photo_credentials_header" (photo + name + suffix)
  - "B35 specialty_expertise"
  - "B36 experience_practice"
  - "B37 education_training"
  - "B38 publications_research" (if applicable)
  - "B39 affiliations_memberships"
  - "B40 languages_spoken"
  - B22 related_links_cluster (pages reviewed by this doctor)
  - B20 cta_block (book consultation)

schema_required_properties:
  - "@type": ["Person", "Physician"]
  - name (full)
  - honorificPrefix (ทพ., นพ., Dr., etc.)
  - honorificSuffix (DDS, MD, PhD credentials)
  - image (verifiable URL)
  - jobTitle
  - worksFor (clinic/brand)
  - medicalSpecialty (Schema.org enum)
  - alumniOf (institutions)
  - memberOf (medical councils)
  - url (canonical profile page)
  - sameAs (LinkedIn, ResearchGate if applicable)
```

#### T10 — Branch / Location Page

```yaml
purpose: "L6 local — clinic location"
schema_org_type: MedicalBusiness
secondary_schemas: [LocalBusiness, Place]
layer_mapping: L6
length_target: 600-1,200 words (Bible §9.8)
eeat_required: NOT REQUIRED (operational page)

required_blocks:
  - "B41 branch_hero" (branch photo + name + tagline)
  - "B42 address_hours_block"
  - "B43 services_at_branch" (what's offered here)
  - B24 branch_doctor_card (who provides service)
  - "B44 directions_map" (Google Maps embed)
  - "B45 photo_gallery_branch" (interior, equipment)
  - B20 cta_block (book at this branch)
  - B22 related_links_cluster (other branches)

recommended_blocks:
  - "B46 patient_testimonial_branch_specific"
  - "B47 transit_parking_info"
```

#### T11 — Institutional (Home / About / Contact / Privacy)

```yaml
purpose: "Brand-level operational pages — no medical content"
schema_org_type: Organization
secondary_schemas: [WebPage]
layer_mapping: L1
length_target: 500-1,500 words (Home), 800-1,200 (About), 300-600 (Contact)
eeat_required: NOT REQUIRED

required_blocks:
  vary_by_subtype:
    home_page: ["B01", "B48 brand_pillars", "B49 featured_services", "B22", "B20"]
    about_page: ["B50 brand_origin_story", "B51 values_mission", "B52 team_overview", "B22"]
    contact_page: ["B42 address_hours_block", "B44 directions_map", "B53 contact_form", "B22"]
    privacy_page: ["B54 legal_text"]

allowed_tweaks: "EXTREMELY high — institutional pages are brand-voice driven"
```

#### T12 — Hub Page (FAQ / Glossary / Topic)

```yaml
purpose: "L3 navigational hub — collects related sub-pages or anchor sections"
schema_org_type: CollectionPage
secondary_schemas: [FAQPage (if FAQ-style), DefinedTermSet (if glossary)]
layer_mapping: L3
length_target: 1,500-2,500 words (Bible §9.8 L3)
eeat_required: REQUIRED if individual hub items are YMYL

modes:
  faq_hub: |
    Collects topic-categorized FAQ pages (e.g., "FAQ จัดฟัน" + "FAQ รากเทียม" etc.)
    Schema: CollectionPage with mainEntity = array of FAQPage links
  
  glossary_hub: |
    Collects topical glossary entries (e.g., "วัสดุทันตกรรม" + "เทคโนโลยีทันตกรรม")
    Each entry can be: section anchor (preferred per VTH) OR separate page
    Schema: CollectionPage + DefinedTermSet
  
  topic_hub: |
    Collects all pages within a topic cluster (e.g., "Sleep Disorders Hub")
    Schema: CollectionPage + Article links

required_blocks:
  - B01 hero_summary
  - B04 definition (overview of hub topic)
  - "B55 hub_navigation" (organized list of sub-items)
  - B18 faq_block (top-level questions about the hub topic)
  - B22 related_links_cluster
  - B20 cta_block
  - B19 doctor_review_block (if YMYL)

allowed_tweaks: "Hub design varies — FAQ vs Glossary vs Topic each tweak block content"
```

### 3.2 T2 Vertical Variants (5)

#### T2a — Aesthetic Procedure

```yaml
purpose: "Cosmetic/aesthetic — Botox, fillers, EMFACE, NightLase, ortho cosmetic"
schema_org_type: MedicalProcedure
secondary_schemas: [Service, Article]
layer_mapping: L2 | L4
length_target: 2,000-3,000 words
eeat_required: YES (medical reviewer for any health-impact claim)

distinguishes_from_T2:
  - B16 before_after_gallery TOP OF PAGE (not buried)
  - "B56 downtime_recovery_visual" (CRITICAL — patients need to plan)
  - "B57 results_timeline" (when to see effects: immediate? 2 weeks? 3 months?)
  - "B58 candidate_screening" (who is suitable, who's not)
  - "B59 maintenance_schedule" (touch-ups, re-treatments)
  - Beauty-focused outcome language (not just clinical efficacy)

required_blocks:
  - B01, B16 (CRITICAL TOP), B04, "B58", "B57", B13, "B56", "B59",
    B17, B25, B18, B19, B22, B20, B21
```

#### T2b — Dental Procedure

```yaml
purpose: "Dental-specific — implant, ortho, root canal, crown, extraction"
schema_org_type: MedicalProcedure (DentalProcedure subtype)
secondary_schemas: [Service]
layer_mapping: L2 | L4
length_target: 2,500-4,000 words (often complex multi-visit)
eeat_required: YES

distinguishes_from_T2:
  - "B60 multi_visit_timeline" (1-7 visits typical, plan-by-plan)
  - "B61 materials_brands_block" (Blue Diamond / Osstem / Straumann / TrioClear)
  - "B62 anesthesia_options"
  - B15 aftercare CRITICAL with day-by-day for week 1
  - "B63 warranty_terms" (สำคัญสำหรับ implant — ตลอดชีพ vs 5 ปี)

required_blocks:
  - B01, B04, B07, B13, "B60", "B61", "B62", B14, B15, "B63",
    B17, B25, B18, B19, B22, B20, B21
```

#### T2c — Wellness Program / Multi-Session Protocol

```yaml
purpose: "Multi-session — Men's Vitality programs, Detox, Hair regrowth"
schema_org_type: MedicalTherapy
secondary_schemas: [Service, HealthAndBeautyBusiness]
layer_mapping: L2 program
length_target: 2,500-4,000 words
eeat_required: YES

distinguishes_from_T2:
  - "B64 program_phases" (e.g., 12-week structure)
  - "B65 included_services_list" (what's bundled)
  - "B66 expected_outcomes_per_phase"
  - "B67 lifestyle_integration" (diet, exercise complement)
  - "B68 graduation_criteria" (when program ends, transition plan)

required_blocks:
  - B01, B04, "B27 who_is_it_for", "B64", "B65", "B66", "B67", "B68",
    B17, B19, B25, B18, B22, B20, B21
```

#### T2d — Physiotherapy / Rehab Program

```yaml
purpose: "Recovery/rehab — PRP knee, post-stroke rehab, Cerebrolysin program"
schema_org_type: PhysicalTherapy
secondary_schemas: [MedicalTherapy]
layer_mapping: L2 | L4
length_target: 2,000-3,500 words
eeat_required: YES

distinguishes_from_T2:
  - "B69 functional_goal" (specific outcome: ROM, pain reduction, return to sport)
  - "B70 baseline_assessment_protocol"
  - "B71 session_frequency_duration"
  - "B72 progression_milestones"
  - "B73 home_exercises_block"

required_blocks:
  - B01, B04, "B69", "B70", B13, "B71", "B72", "B73", B17, B19,
    B25, B18, B22, B20, B21
```

#### T2e — Genomic / Precision Test

```yaml
purpose: "DNA-based test — Genowell signature"
schema_org_type: MedicalTest
secondary_schemas: [Article]
layer_mapping: L3 | L4
length_target: 1,800-3,000 words
eeat_required: YES

distinguishes_from_T2/T3:
  - "B74 genes_tested_panel" (panel composition disclosure)
  - "B75 actionable_insights_vs_raw_data"
  - "B76 sample_collection_method"
  - "B77 report_turnaround_time"
  - "B78 lifestyle_prescription_link" (links to T2c program if applicable)

required_blocks:
  - B01, B04, "B74", "B75", "B76", "B77", "B78", B17, B19,
    B25, B18, B22, B20, B21
```

### 3.3 Specialized Templates (7)

#### T13 — Pricing List Page

```yaml
purpose: "Pure price-list — ราคาครอบ/ขูดหินปูน/ฟอกฟัน list-style"
schema_org_type: WebPage
secondary_schemas: [PriceSpecification (multiple), Service]
layer_mapping: L4 (intent capture)
length_target: 800-1,500 words
eeat_required: NOT REQUIRED if pure prices, REQUIRED if explains procedure

distinguishes_from_T5: |
  T5 = full service page WITH pricing
  T13 = pricing-focused with brief service explanations + comparison

required_blocks:
  - B01 hero_summary
  - "B79 pricing_table_grid" (organized by service category)
  - "B80 inclusions_exclusions"
  - "B81 payment_methods_financing"
  - B22 related_links_cluster (link to T2 for full procedure detail)
  - B20 cta_block
  - "B82 price_validity_note" (date stamp + caveats)
```

#### T14 — Trending / News Update Article

```yaml
purpose: "Date-sensitive — Clinical Updates, viral trends, research news"
schema_org_type: NewsArticle
secondary_schemas: [Article]
layer_mapping: L5 supporting
length_target: 800-2,000 words (typically shorter)
eeat_required: REQUIRED + dateModified critical

modes:
  research_summary: "Less time-sensitive, more authoritative tone"
  clinical_update: "New device/protocol announcement"
  trending_topic: "Viral health concern explainer"
  industry_news: "Regulatory / industry change"

required_blocks:
  - B01 hero_summary (with date prominently)
  - B04 definition (what's the news/finding)
  - "B83 why_it_matters_now" (timeliness justification)
  - B12 clinical_insight (clinic's interpretation)
  - B19 doctor_review_block
  - B22 related_links_cluster
  - B21 references_block

allowed_tweaks: "Should be retired/archived once no longer current — scheduled review"
```

#### T15 — Quiz / Self-Assessment Tool

```yaml
purpose: "Interactive — STOP-BANG, Epworth Scale, OSA risk quiz, oral health checker"
schema_org_type: WebApplication (or Quiz custom type)
secondary_schemas: [WebPage]
layer_mapping: L4 (lead magnet)
length_target: 600-1,500 words supporting copy
eeat_required: YES (clinical scoring → health guidance)

required_blocks:
  - B01 hero_summary
  - "B84 quiz_intro_caveats" (what this tells you, what it doesn't)
  - "B85 quiz_widget" (interactive component)
  - "B86 results_interpretation_guide"
  - B19 doctor_review_block (clinical scoring needs validation)
  - B22 related_links_cluster (next steps based on result)
  - B20 cta_block (book consultation if high-risk)

special_property: "All quiz scoring algorithms must be documented + reviewer-signed"
```

#### T16 — Insurance / Coverage Explainer

```yaml
purpose: "ประกันสังคม / ประกันสุขภาพเอกชน explainer"
schema_org_type: WebPage
secondary_schemas: [(FinancialProduct if applicable)]
layer_mapping: L4 (intent capture)
length_target: 1,200-2,500 words
eeat_required: NOT REQUIRED (operational), reviewer for coverage details RECOMMENDED

required_blocks:
  - B01 hero_summary
  - B04 definition (what coverage applies)
  - "B87 covered_uncovered_table"
  - "B88 step_by_step_claim_process"
  - B14 preparation_checklist (documents needed)
  - B18 faq_block
  - B22 related_links_cluster (to specific procedure pages)
  - B20 cta_block

allowed_tweaks: "Brand-specific implementation — insurance varies by clinic agreements"
```

#### T17 — Patient Care Instructions

```yaml
purpose: "Post-op care, what to expect day 1-7, maintenance routines"
schema_org_type: HowTo
secondary_schemas: [MedicalTherapy]
layer_mapping: L4 supporting | L7 supporting
length_target: 1,000-2,000 words
eeat_required: YES (medical instruction)

required_blocks:
  - B01 hero_summary
  - "B89 timeline_phases" (Day 1 / Week 1 / Month 1 etc.)
  - B13 process_steps (per phase)
  - "B90 red_flags_warning_signs" (when to call clinic)
  - "B91 medication_schedule" (if applicable)
  - "B92 diet_activity_restrictions"
  - B18 faq_block
  - B19 doctor_review_block
  - B22 related_links_cluster
  - B20 cta_block (emergency contact)

example_pages:
  - "ดูแลรากเทียมให้ใช้ได้นาน" (Deezy 6.1.25)
  - "ดูแลฟันหลังทำหัตถการ" (Deezy 6.1.18)
```

#### T18 — Programmatic Local Service 🆕 v1.0

```yaml
purpose: "Hyper-local [service]×[branch] — auto-templated for SEO scale"
schema_org_type: MedicalBusiness
secondary_schemas: [Service, Place, LocalBusiness]
layer_mapping: L6 Local
length_target: 800-1,500 words (Bible §9.8 L6)
eeat_required: YES (branch doctor surface as Person/Physician)

programmatic_constraints:
  variables: [service_name, branch_name, district, doctor_list_at_branch, branch_pricing]
  forbidden: "Pure copy-paste — must achieve ≥30% unique content per page"
  techniques_for_uniqueness:
    - branch-specific photos
    - branch-specific doctor cards
    - branch-specific patient testimonials (when available)
    - district context (e.g., "ใกล้ MRT รัตนาธิเบศร์")
    - branch-specific case examples

required_blocks:
  - B01 hero_summary (with location keyword: "{service} ที่ {branch}")
  - "B93 service_offered_at_this_branch"
  - B24 branch_doctor_card (CRITICAL EEAT)
  - "B94 branch_specific_pricing" (if differs from main)
  - "B45 photo_gallery_branch"
  - "B44 directions_map"
  - "B42 address_hours_block"
  - B20 cta_block (book at this branch)
  - "B95 related_services_at_this_branch"
  - "B96 related_branches_for_this_service"

example_pages:
  - "จัดฟัน รัตนาธิเบศร์" (Deezy 9.1.x)
  - "รากเทียม ศรีนครินทร์" (Deezy 9.2.x)
  - All multi-branch brand combinations

scale_consideration: |
  Deezy alone has 68 pages today + 99+ candidates.
  All multi-branch brands (Deezy 33, Trin Wellness 3, VTH 2, etc.) benefit.
  Critical to enforce uniqueness or face thin-page penalty per DR-016.
```

#### T19 — Promotion / Offer Page 🆕 v1.0

```yaml
purpose: "Time-sensitive offer / promotion / package"
schema_org_type: Offer
secondary_schemas: [Product, Service]
layer_mapping: L4 commercial
length_target: 600-1,200 words
eeat_required: NOT REQUIRED (operational), author signoff RECOMMENDED for trust

required_blocks:
  - "B97 offer_hero" (with valid_through date prominent)
  - "B98 offer_details" (what's included, conditions)
  - "B99 inclusions_exclusions"
  - "B100 eligibility_terms"
  - B17 pricing_block (offer price + comparison to regular)
  - B22 related_links_cluster (link to T2 for full service detail)
  - B20 cta_block (booking before expiry)

mandatory_property: validThrough date — page should auto-archive when expired
schema_emit_offer:
  - "@type": Offer
  - validFrom + validThrough
  - price + priceCurrency
  - availability
  - url
```

---

## 4. Layer 3 — Customization Hooks (Per-Brand Tweaks)

```yaml
hook_1_block_substitution:
  description: "Replace block X with brand-specific variant"
  example: |
    VTH BioDent uses "PNCL_methodology_explainer" instead of generic
    B04 definition for L2 service pages
  enforcement: "Substitute must serve same purpose + maintain schema emission"

hook_2_block_addition:
  description: "Insert custom block (brand-specific)"
  example: |
    Dr. Trin adds "vascular_diagnostic_depth_block" on Men's Vitality 
    pages — explains hidden diagnostic workup
  enforcement: "Custom blocks must be documented in brand-config.json"

hook_3_block_removal:
  description: "Skip OPTIONAL or RECOMMENDED blocks not relevant"
  example: |
    Deezy can omit B16 before_after on cleaning pages — not visually relevant
  hard_rule: "NEVER remove REQUIRED blocks"

hook_4_block_reordering:
  description: "Reorder blocks for brand-specific reading flow"
  example: |
    Aesthetic brands move B16 before_after gallery to top
    (already enforced as REQUIRED for T2a)

tracking:
  page_master.content_brief: "DR-017 — captures any tweaks at design phase"
  page_master.template_id: "future column — locks which template was used"
```

---

## 5. EEAT Requirement Matrix (LOCKED)

### 5.1 Required vs Not Required

| Template | Author | Medical Reviewer | Last Reviewed | Reasoning |
|----------|--------|------------------|---------------|-----------|
| T1 Medical Condition | ✅ Required | ✅ Required | ✅ Required | YMYL critical |
| T2 Medical Procedure | ✅ Required | ✅ Required | ✅ Required | YMYL critical |
| T2a Aesthetic Procedure | ✅ Required | ✅ Required | ✅ Required | Health-impact even if cosmetic |
| T2b Dental Procedure | ✅ Required | ✅ Required | ✅ Required | YMYL critical |
| T2c Wellness Program | ✅ Required | ✅ Required | ✅ Required | YMYL critical |
| T2d Physiotherapy | ✅ Required | ✅ Required | ✅ Required | YMYL critical |
| T2e Genomic Test | ✅ Required | ✅ Required | ✅ Required | YMYL critical |
| T3 Diagnostic | ✅ Required | ✅ Required | ✅ Required | YMYL critical |
| T4 Medical Device | ✅ Required | ✅ Required | ✅ Required | Device claims |
| T5 Service Page | ✅ Required | ⚠️ If medical claim | ✅ Required | Conditional |
| T6 Concept | ✅ Required | ⚠️ If YMYL | ✅ Required | Conditional |
| T6a Guide | ✅ Required | ✅ Required | ✅ Required | Comprehensive YMYL |
| T7 Comparison | ✅ Required | ✅ Required | ✅ Required | Recommendation = health choice |
| T8 Case Study | ✅ Required | ✅ Required | ✅ Required | Clinical claim |
| T9 Author Profile | ✅ Self | ❌ N/A | ⚠️ When updated | Self-EEAT |
| T10 Branch | ❌ N/A | ❌ N/A | ⚠️ Optional | Operational |
| T11 Institutional | ❌ N/A | ❌ N/A | ⚠️ Optional | Brand voice |
| T12 Hub | ⚠️ Optional | ⚠️ If hub items YMYL | ✅ Required | Conditional |
| T13 Pricing List | ⚠️ Optional | ❌ N/A | ✅ Required | Date-sensitive |
| T14 Trending | ✅ Required | ✅ Required | ✅ Required | Date + accuracy |
| T15 Quiz | ✅ Required | ✅ Required | ✅ Required | Clinical scoring |
| T16 Insurance | ⚠️ Optional | ❌ N/A | ✅ Required | Operational + date |
| T17 Care Instructions | ✅ Required | ✅ Required | ✅ Required | Medical instruction |
| T18 Programmatic Local | ❌ Page-level | ✅ Branch doctor | ⚠️ Optional | Branch doctor signal |
| T19 Promotion | ⚠️ Optional | ❌ N/A | ✅ validThrough | Operational + date |

### 5.2 The Decision Rule

```
IF reader makes a health decision based on this page:
  → medical_reviewer REQUIRED
  → last_reviewed REQUIRED
  → schema must include reviewedBy property linked to Physician
  → visual reviewer block (B19) must be present

IF page is operational/institutional:
  → reviewer NOT required
  → but date stamps still useful for freshness
```

### 5.3 Enforcement Phasing (per DR consideration)

```yaml
phase_1_2026_05_to_2026_08: 
  level: SOFT WARN
  action: |
    Editorial review flags pages missing required EEAT signals.
    Pages publish anyway with warning logged.
    
phase_2_2026_09_onwards:
  level: HARD BLOCK (database CHECK constraint)
  action: |
    DB-level enforcement on seo_website_page_master:
    CHECK (
      schema_org_type NOT IN ('MedicalCondition', 'MedicalProcedure', 
                               'MedicalTherapy', 'MedicalDevice', ...)
      OR (medical_reviewer_fp IS NOT NULL AND last_reviewed_at IS NOT NULL)
    )
  prerequisite: "All clinics onboarded their doctors as seo_authors records"
```

---

## 6. Schema Enforcement — Beyond Visual EEAT

> **Critical insight from VTH BioDent /mouth-biomapping/ audit:**  
> A page can have **perfect visual EEAT** (doctor name, credentials, photo, last reviewed date) yet **fail structured EEAT** if WordPress emits author schema from admin user account instead of the actual reviewing doctor.
>
> This is the #1 silent EEAT failure across the EYWA portfolio.

### 6.1 Required Schema Pattern for Medical YMYL Pages

```jsonld
{
  "@type": "Article",
  "headline": "...",
  "datePublished": "2026-MM-DDTHH:mm:ss+07:00",
  "dateModified": "2026-MM-DDTHH:mm:ss+07:00",
  "lastReviewed": "2026-MM-DD",
  "author": {
    "@type": ["Person", "Physician"],
    "@id": "https://{brand}.com/our-doctors/{slug}",
    "name": "ทพ. ดร. อมรพงษ์ วชิรมน",
    "honorificPrefix": "ทพ. ดร.",
    "honorificSuffix": "DDS, DBA, PhD, LLD, ABDSM",
    "image": "https://{brand}.com/images/doctors/{slug}.jpg",
    "jobTitle": "Executive Medical Director",
    "medicalSpecialty": "Dentistry",
    "memberOf": {
      "@type": "Organization",
      "name": "Thai Dental Council"
    },
    "alumniOf": [...],
    "url": "https://{brand}.com/our-doctors/{slug}"
  },
  "reviewedBy": {
    "@type": ["Person", "Physician"],
    "@id": "...",  // can be same as author OR different
    "name": "...",
    ...same structure as author
  },
  "medicalAudience": {
    "@type": "MedicalAudience",
    "audienceType": "Patient"
  },
  "citation": [
    {
      "@type": "ScholarlyArticle",
      "name": "...",
      "author": "...",
      "datePublished": "...",
      "url": "..."
    }
  ],
  "publisher": {
    "@type": ["Organization", "MedicalBusiness", "Dentist"],
    "name": "...",
    "medicalSpecialty": [...],
    "hasCredential": [...]
  }
}
```

### 6.2 Common Failure Modes (Audit Checklist)

```yaml
failure_1_admin_author:
  symptom: '"author": {"name": "advthdent"}'
  cause: "AIOSEO/Yoast emits WP user as author"
  fix: "Override via eywa-schema-pipeline plugin reading medical_reviewer_fp"

failure_2_no_reviewedBy:
  symptom: 'Article schema missing "reviewedBy" property'
  cause: "Schema plugin doesn't know about medical reviewer concept"
  fix: "Custom JSON-LD injection from page_master.medical_reviewer_fp"

failure_3_lastReviewed_visual_only:
  symptom: 'Page shows "Reviewed: May 2026" but schema lacks lastReviewed'
  cause: "Visual block not connected to JSON-LD generator"
  fix: "ACF field date → schema property mapping"

failure_4_no_medicalAudience:
  symptom: 'Article has no audience declaration'
  cause: "Default schema generators don't add this"
  fix: "Default to {audienceType: 'Patient'} for all medical templates"

failure_5_organization_not_medical:
  symptom: '"@type": "Organization" only on clinic'
  cause: "Default WP / SEO plugin behavior"
  fix: 'Set "@type": ["Organization", "MedicalBusiness", "{specialty}"]'

failure_6_citations_text_only:
  symptom: 'Citations rendered as text in body but not in schema'
  cause: "References block doesn't feed citation property"
  fix: "Parse references block → emit schema citation array"
```

### 6.3 Validation Workflow

```yaml
pre_publish_check:
  step_1: "Render page → extract JSON-LD"
  step_2: "Run through eywa-schema-pipeline validator"
  step_3: "Check required properties per template type"
  step_4: "Cross-check visual blocks vs schema emission"
  step_5: "If mismatch: BLOCK publish (phase 2) or WARN (phase 1)"

post_publish_audit:
  schedule: "Monthly automated audit"
  tool: "Google Rich Results Test API + custom validator"
  alert: "Pages drifting from spec flagged in seo_governance_audit table"
```

---

## 7. Reference Implementations

### 7.1 Gold Standard References

| Template | Reference | Notes |
|----------|-----------|-------|
| T1 Medical Condition | `/legacy/Sitemap Deezy/VTH Biodent/ตัวอย่างเนื้อหา 355be9c6bf3c806fadabe4828a694200.md` | Sleep apnea sample — 13 sections, full annotations, all required blocks present |
| T1 Medical Condition (real, mixed quality) | https://www.vthbiodent.com/mouth-biomapping/ | ✅ Visual EEAT good, ❌ Structured EEAT broken — see §6.2 |

### 7.2 What to Replicate from Sleep Apnea Sample

```yaml
strengths_to_emulate:
  - section-by-section annotations with [📖 Annotation] tags
  - Speakable Block markup explicit (class="speakable-block")
  - Citable formula: [Fact] + [Number] + [Source] + [Year]
  - Brand Stance Block (Pattern E) — 2 distinct stances per page
  - Patient Journey block with anonymized cases
  - Comparison table with 7 criteria + recommendation
  - 8 FAQ types with type tags
  - References numbered with tier classification

weaknesses_to_avoid:
  - References block lacks structured year/journal/DOI separation
  - Internal links go to Notion instead of canonical URLs
  - Image references missing alt-text guidance
```

### 7.3 What VTH /mouth-biomapping/ Does Right (Visual)

- ✅ Doctor displayed: ทพ. ดร. อมรพงษ์ วชิรมน with credentials
- ✅ "20+ ปีประสบการณ์" counter
- ✅ datePublished + dateModified present
- ✅ FAQPage schema with Q/A pairs
- ✅ BreadcrumbList + Organization schema

### 7.4 What VTH /mouth-biomapping/ Gets Wrong (Structured)

- ❌ Article author = "advthdent" (admin) not the doctor
- ❌ No reviewedBy property
- ❌ No lastReviewed in schema (visual-only)
- ❌ No medicalAudience declaration
- ❌ Organization not typed as MedicalBusiness
- ❌ Citations text-only, not in schema citation array

**Use this contrast as the canonical "do/don't" example in EYWA training.**

---

## 8. Implementation Guidance

### 8.1 Notion (Editorial Source of Truth)

```yaml
notion_database: "Content Production"
required_properties:
  - template_id (select: T1, T2, T2a, ..., T19)
  - content_brief (long text — DR-017)
  - assigned_author (relation → Authors DB)
  - assigned_medical_reviewer (relation → Authors DB)
  - block_overrides (long text — Layer 3 hooks)
  - target_word_count (number — from §9.8)
  - last_reviewed_date (date)
  - next_review_due (formula: last_reviewed + 6/12 months)

editorial_workflow:
  stage_1: "Draft from template (writer pulls block list)"
  stage_2: "Medical review (reviewer signs off)"
  stage_3: "SEO review (citable formulas, internal links, schema)"
  stage_4: "Brand voice review"
  stage_5: "Final signoff → push to WordPress"
```

### 8.2 WordPress (Publication Layer)

```yaml
acf_field_groups_per_template:
  - one ACF group per template (T1-T19)
  - fields map 1:1 to required blocks
  - schema_emission_purpose (DR-019 — serp/ai/forbidden)

eywa_schema_pipeline_plugin:
  responsibility: "Generate JSON-LD overriding AIOSEO/Yoast defaults"
  inputs:
    - page_master (Supabase via REST)
    - ACF field values
    - template configuration
  outputs:
    - Tier 1 JSON-LD (Article + reviewedBy + citation array)
    - Tier 2 JSON-LD (entity-level — MedicalProcedure etc.)
  enforcement:
    - Block deprecated 7 schemas (per DR-019)
    - Validate AggregateRating compliance
    - Inject medical_reviewer_fp → Person/Physician schema
```

### 8.3 Supabase (Data Layer)

```yaml
page_master_columns_already_exist:
  - author_fp (FK → seo_authors)
  - medical_reviewer_fp (FK → seo_authors)
  - last_reviewed_at (timestamptz)
  - schema_org_type (text)
  - schema_markup_planned (jsonb)
  - content_brief (text — DR-017)
  - viability_assessment (jsonb — DR-016)

future_columns_pending:
  - template_id (text — to be added under DR-020 if locked)
  - eeat_compliance_status (computed jsonb)

future_constraint_pending:
  - CHECK enforcement (phase 2 — see §5.3)
```

---

## 9. Open Questions for Review

```yaml
Q1_template_count_too_many:
  question: "25 templates — is this overengineering?"
  answer_default: |
    No. Each template addresses a real page type found in actual sitemaps:
    - 13 brands × 6 verticals = high diversity
    - Deezy alone has 13 page types covered
    - Templates compose from blocks (not from scratch) — adoption cost low
    - Skip templates not relevant to brand (Aesthetic brand may skip T2b Dental)

Q2_block_count_explosion:
  question: "100+ blocks — too many?"
  answer_default: |
    Numbered B01-B100 placeholders for organization. Actual usage per template
    ~10-15 blocks. Most blocks reused across templates (high lego efficiency).

Q3_eeat_phase_2_timing:
  question: "When to flip from soft warn to hard block?"
  recommend: "2026-09-01 (4 months grace period)"
  prerequisite: "≥80% of brand clinic doctors registered in seo_authors"

Q4_t6_t6a_overlap:
  question: "Concept vs Guide — risk of confusion?"
  answer_default: |
    Distinguishing rule: 
    - T6 Concept = "what IS X" (knowledge transfer)
    - T6a Guide = "how to navigate X journey" (action transfer)
    Editorial reviewer makes call. Border cases default to T6 (lower bar).

Q5_t18_uniqueness_enforcement:
  question: "Programmatic Local — how to enforce ≥30% unique content?"
  recommend: |
    Algorithmic check:
    - Pairwise cosine similarity vs other branch pages
    - Threshold: <0.7 (i.e., must differ ≥30%)
    - Block publish if exceeds
  caveat: "Phase 2 implementation — Phase 1 = manual review"

Q6_template_versioning:
  question: "How to evolve templates without breaking existing pages?"
  recommend: |
    Semantic versioning:
    - v1.0 → v1.1: backward compatible (block additions OK)
    - v1.0 → v2.0: breaking (block removal/rename)
    Template version stored in page_master.template_version jsonb
```

---

## 10. References

- Bible Part 6 (Citable Formulas + Perspective Layer) — content philosophy
- Bible Part 9 (Template Anatomy + WCAG AA + Length Standards §9.8)
- Bible Part 23.4 (Multi-Stage Editorial Review)
- Bible §4.1 Phase 4.5 (Sitemap Quality Gates — DR-015/016/017)
- DR-017 (page_master.content_brief — captures block tweaks)
- DR-019 (Schema Strategy — Two-Purpose Taxonomy + EEAT enforcement)
- Schema Overview v1.10 §5.1 (page_master columns: author_fp, medical_reviewer_fp, last_reviewed_at)
- Reference content sample: `/legacy/Sitemap Deezy/VTH Biodent/ตัวอย่างเนื้อหา 355be9c6bf3c806fadabe4828a694200.md`
- Live audit sample: https://www.vthbiodent.com/mouth-biomapping/ (audited 2026-05-10)
- Deezy sitemap (gap analysis source): `/legacy/Sitemap Deezy/Deezy Dental/deezy-sitemap.md`

---

*Draft prepared 2026-05-10 by Architect for review*
*Phase 2 lock target: separate DR-020 — Universal Content Template Standard*
