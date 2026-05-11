# 📝 Content Templates — EYWA™ PROTOCOL

> **Companion document to** EYWA Bible v3.15 + Schema Overview v1.11
> **Universal Content Production Standards across 13 brands × 6 verticals**

**Version:** v1.3 (DRAFT 2026-05-10 — companion refs bumped 2026-05-12 per DR-024/025 spec catch-up; content unchanged, still pending DR-020 lock 2026-06-07)
**Status:** Proposed — pending DR-020 lock
**Companion to:** Bible v3.15 + Schema Overview v1.11 + DECISION_RECORDS v1.9
**Format:** Append-only with semantic versioning (v1.0 → v1.1 → v1.2 → v1.3 backward compatible)

## v1.3 Changelog (2026-05-10) — Section 2 Pattern Lock + Icon Taxonomy

Operator review of Section 2 across all 25 templates surfaced need for:
- Per-template Quick Facts variations (some templates need different fields, some skip entirely)
- Universal Icon Taxonomy (consistent across templates for visual coherence)
- Concrete render examples (writers + designers reference)

- ➕ **B02 spec expanded** — `per_template_variations` documents all 25 templates' Section 2 patterns
- 📁 **NEW reference file** `/examples/SECTION-2-PATTERNS-REFERENCE.md` (~600 lines) — concrete rendered examples for all 25 templates with EYWA brand context (VTH/Trin/SmileScape/Genowell etc.)
- 🎨 **Universal Icon Taxonomy** — 35+ icons mapped to consistent use cases across templates (👤 audience, ✅ reviewer, 🎯 outcome, 📅 timeline, 🚨 emergency, etc.)
- 📊 **Template grouping locked**:
  - Group A (16): Quick Facts with 5-essential + toggle pattern
  - Group B (4): Alternative blocks (T8 patient_profile / T9 credentials / T10 address / T18 branch_hero)
  - Group C (3): Skip Section 2 entirely (T11 institutional / T13 pricing / T19 promo)
- 📝 No Schema impact (rendering layer only)

## v1.2 Changelog (2026-05-10) — Part 1 / Part 2 Strict Separation

Operator review of v1.1 worked example (T1 OSA) surfaced UX issues with mixing technical annotations into review-ready content. v1.2 enforces strict separation.

- ➕ **§7 Part 1 / Part 2 Editorial-Production Separation Pattern (NEW)** — formal spec for content-team-friendly Part 1 (WYSIWYG, copy-paste-ready) vs technical Part 2 (multi-toggle spec)
- ➕ **§7.1 On-Page SEO Brief Table** — required at top of Part 1 with focus keyword, related keywords, SEO title (50-60 char optimal), meta description (120-155 char optimal), URL slug, target word count, Featured Snippet target. Char count + status indicator (✅ Optimal / ⚠️ Borderline / ❌ Revise) included.
- ➕ **§7.2 Citation Map Table** — replaces inline `📌 Citable #N — Pattern X:` markers. Lives in Part 2 toggle. Tracks: section, sentence preview, pattern, citation_id, notes.
- ➕ **§7.3 Section Brief Table** — replaces inline `> 📖 Annotation:` blocks. Lives in Part 2. Per-section: purpose + length target + speakable flag + schema feed.
- ➕ **§7.4 CSS Class Map Table** — centralizes per-section CSS class assignments (no longer inline in Part 1).
- 🔄 **§2.8 update** — `editorial_marker_convention` now mandates Part 2 Citation Map location (NOT inline in Part 1)
- 🔄 **All 25 templates** — tagged with new Part 1 / Part 2 structure. Skeleton + worked example pattern in `examples/` directory demonstrates compliance.

## v1.1 Changelog (2026-05-10) — OSA Master Example Integration

Added concepts from operator's pre-spec OSA Master Example doc (cross-checked, no conflicts found):
- ➕ **§2.8 Pattern A-E Citable Taxonomy** — 5 brand-citable patterns including Pattern E Brand Stance (LLMO-critical)
- ➕ **§2.9 Predicted Prompts Bank** — off-render planning artifact + 2-table Schema spec (`seo_predicted_prompts` + `seo_ai_prompt_test_results`) for active LLMO measurement
- ➕ **§2.10 Cross-Vertical Adaptability Framework** — per-specialty perspective pivot guide for multi-brand entity reuse
- ➕ **§2.7 B25a Crisis Disclosure Block** — explicit emergency-trigger callout for acute YMYL conditions
- ➕ **§6.4 Schema Tier Architecture (1/2/3)** — site/page/content emission tier mapping
- ➕ **§5.4 Translation Tier Rubric** (1=native / 2=AI+heavy edit / 3=AI-only ❌YMYL)
- ➕ Quick wins: ≥8 Q&A floor + "🎯 จุดยืนของ {brand}:" Pattern E prefix + member array + Cannibalization Shield naming + 5 Quote-Worthy Patterns sub-table
- 📝 No new templates added (T-count remains 25); 2 new blocks (B25a, B26) + 1 new sub-block class (B11a)
- 📝 Schema impact: 2 new tables proposed for v1.11 (additive, deferred until DR-020 lock)



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
  purpose: "Entity Signal + Citable Data Cluster + Reader Hook"
  
  ui_pattern: "5-essentials always visible + technical depth under toggle (v1.2 🆕)"
  
  rationale: |
    Reader-centric framing — 5 essentials answer "What's in it for me?" questions:
    1. Disease name → "ใช่หน้าที่ฉันหา?"
    2. Risk groups → "ฉันเสี่ยงไหม?" ⭐ highest hook
    3. Diagnostic methods → "รู้ได้ยังไงว่าเป็น?"
    4. Treatment options → "รักษาได้ไหม?"
    5. Reviewer → "เชื่อได้ไหม?" (visual EEAT)
    
    Technical codes (ICD-10/11, SNOMED, MeSH) collapsed under toggle —
    audience ทั่วไป (99%+ of traffic) ไม่รู้จัก codes. Power users
    (researcher/clinician) คลิก expand เพื่อดู.
    
    Google indexes collapsed <details> content fully (since 2019) —
    ZERO SEO penalty for hiding under toggle.
  
  structure_v1_2:
    essentials_always_visible:  # 5 rows, no toggle
      - title_row: "**{Disease/Topic Name (TH)}** | {English Term + Acronym}"
      - row_1: "👤 **ใครเสี่ยง?** | {risk groups / demographic}"
      - row_2: "🔍 **รู้ได้อย่างไร?** | {primary diagnostic methods}"
      - row_3: "💊 **รักษาได้ไหม?** | {primary treatments}"
      - row_4: "✅ **ตรวจสอบโดย** | {reviewer name + credentials}"
    
    toggle_label: "▶ ข้อมูลทางเทคนิค (สำหรับผู้สนใจเชิงลึก)"
    toggle_default_state: collapsed
    
    collapsed_under_toggle:  # render inside <details>
      - ICD-10-CM, ICD-11, SNOMED CT, MeSH codes
      - prevalence (TH-specific)
      - related medical specialties
      - any other technical/clinical metadata
  
  per_template_variations:  # Quick Facts content varies by template type
    T1_medical_condition:
      essentials: [disease_name, risk_groups, diagnostic_methods, treatment_options, reviewer]
      collapsed: [icd_codes, snomed, mesh, prevalence, specialty]
    
    T2_medical_procedure:
      essentials: [procedure_name, who_for, duration, recovery_time, reviewer]
      collapsed: [cpt_code, anesthesia_type, contraindications]
    
    T2a_aesthetic:
      essentials: [procedure_name, treatment_area, downtime, results_timeline, performed_by]
      collapsed: [maintenance_schedule, contraindications, FDA_status]
    
    T2b_dental:
      essentials: [procedure_name, who_for, visits_required, materials_brands, reviewer]
      collapsed: [ada_code, warranty_terms, anesthesia]
    
    T3_diagnostic:
      essentials: [test_name, what_it_detects, sample_type, accuracy, reviewer]
      collapsed: [loinc_code, duration, contraindications]
    
    T4_medical_device:
      essentials: [device_name, indications, available_at_branches, reviewer]
      collapsed: [model_number, manufacturer, fda_ce_approval, technical_specs]
    
    T6_concept:
      optional: true  # Quick Facts may be skipped for non-YMYL concepts
      essentials_if_present: [concept_name, field_discipline, related_concepts]
    
    T6a_guide:
      essentials: [topic, audience_for, estimated_reading_time, sections_covered, reviewer]
    
    T7_comparison:
      essentials: [options_compared, decision_factors, recommended_for]
      reviewer_required: true
    
    T8_case_study:
      uses_different_block: "B31 patient_profile (NOT Quick Facts)"
      info_box_replaces_quick_facts: [age, gender, presenting_complaint, doctor]
    
    T9_author_profile:
      uses_different_block: "B34 photo_credentials_header (NOT Quick Facts)"
      no_quick_facts: true
    
    T10_branch:
      uses_different_block: "B42 address_hours_block (NOT Quick Facts)"
      no_quick_facts: true
    
    T11_institutional:
      no_quick_facts: true  # Home/About/Contact don't need
    
    T12_hub:
      essentials: [topic_covered, articles_in_hub, last_updated]
    
    T13_pricing:
      uses_different_block: "B79 pricing_table_grid (IS the page content)"
      no_quick_facts: true
    
    T14_trending:
      essentials: [topic, date_published, update_type, source, reviewer]
    
    T15_quiz:
      essentials: [quiz_purpose, time_required, what_you_learn, reviewer]
    
    T17_care_instructions:
      essentials: [procedure_referenced, recovery_phase, total_recovery_time, reviewer]
    
    T18_programmatic_local:
      uses_different_block: "B41 branch_hero (location-specific)"
      no_quick_facts: true (Section 2 = address/hours/doctor instead)
    
    T19_promotion:
      essentials: [offer_name, valid_through, price, eligibility]
      no_reviewer: true  # operational
  
  schema_emit: |
    Both essential rows AND toggle rows feed schema (Google indexes both):
    - ICD/SNOMED codes (in toggle) → MedicalCondition.code[]
    - Risk groups → MedicalRiskFactor mentions
    - Treatment options → MedicalTherapy array
    - Reviewer → reviewedBy property
  
  required_in: T1, T2/T2a-e, T3, T4
  recommended_in: [T6a, T7, T12, T14, T15, T17]
  not_used_in: [T8 (uses patient_profile), T9 (uses credentials), T10 (uses address), T11 (skip), T13 (uses pricing), T18 (uses branch_hero), T19 (uses offer details)]
  
  example_sources:
    - "/examples/T1-osa-vth-biodent-WORKED-EXAMPLE.md §2 (v1.2 5+toggle pattern)"
    - "/examples/SECTION-2-PATTERNS-REFERENCE.md — RENDERED EXAMPLES for all 25 templates 🆕"
    - "Original sample sleep apnea (12-row legacy format pre-v1.2)"
  
  reference_doc: "/examples/SECTION-2-PATTERNS-REFERENCE.md"
  reference_doc_includes:
    - "All 25 templates with concrete render examples (real EYWA brand context)"
    - "Universal Icon Taxonomy (35+ icons mapped to use cases)"
    - "Group A (16 templates with Quick Facts) / B (4 alternative blocks) / C (3 skip)"
    - "Validation checklist per template"
    - "Status: Approved 2026-05-10 (operator review)"

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
    8 FAQ Intent Types (Bible Part 6.X):
    [What is X], [Can X], [Is X], [How to X], [How serious is X],
    [Difference between X and Y], [Cost of X], [Who is X for]
  minimum_floor: "≥8 Q&A across ≥7 of the 8 intent types per pillar (v1.1 🆕)"
  rationale: "OSA Master Example pattern — ensures full intent coverage for AI extraction"
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
    
    Organization (Tier 1 emission) {  # v1.1 🆕 — link doctors to org via member array
      "member": [
        {
          "@type": ["Person", "Physician"],
          "@id": "...#dr-amorphong",
          "name": "ทพ. ดร. อมรพงษ์ วชิรมน",
          "jobTitle": "Executive Medical Director",
          "medicalSpecialty": "Dentistry",
          "sameAs": ["...", "..."]
        }
      ]
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

B25a_crisis_disclosure_block:  # 🆕 v1.1
  purpose: "Explicit emergency-trigger callout for acute YMYL conditions"
  structure: |
    🚨 Crisis Disclosure callout box (red/orange visual)
    - Specific symptom triggers (e.g., "หายใจหยุดนานกว่า 30 วินาที")
    - Immediate actions ("โทร 1669 / ไปห้องฉุกเฉินทันที")
    - When to call clinic vs emergency services (decision rule)
  schema_emit: "Renders as <aside role='alert'> with structured emergency info"
  required_in:
    - T1 if condition has acute risk (severe OSA, heart attack risk, allergic reaction, etc.)
    - T2/T2a-e if procedure has acute complication risk
    - T8 case study if patient outcome involved acute event
  recommended_in: T6a Guide (when comprehensive coverage needs safety net)
  not_required_in: T6 concept (educational, no acute decision)
  
  example_template: |
    🚨 ติดต่อฉุกเฉินทันทีหาก:
    - {trigger 1 ที่ specific to condition}
    - {trigger 2}
    - {trigger 3}
    
    📞 โทรฉุกเฉิน: 1669 (หรือ 1646 กรุงเทพฯ)
    🏥 ห้องฉุกเฉินที่ใกล้ที่สุด — Google Maps: "emergency room near me"
    📲 ปรึกษา {brand} เร่งด่วน: LINE @{brand} (24/7)
  
  rationale: |
    Generic safety_disclosures (B25) ครอบคลุม chronic risks ดี
    แต่ acute conditions ต้อง explicit emergency triggers ที่อ่านแล้วรู้ทันทีว่าต้องโทร 1669
    Per Bible Part 23.2 (Medical Red Lines) — failure to surface acute triggers = liability + EEAT loss
```

---

### 2.8 Brand-Linked Citable Taxonomy 🆕 v1.1 (Pattern A-E)

Replaces the single-flavor Citable Sentence Formula (Bible §6) with **5 distinct patterns** mapped to LLM intent. Pattern E (Brand Stance) is the **LLMO superweapon** for "ควรเลือกอะไร" queries.

```yaml
pattern_a_clinical_data:
  marker: "🟢 Pattern A"
  source_type: "Clinic operations data — actual patient outcomes"
  formula: |
    "จากข้อมูลผู้ป่วย {N} รายของ {clinic} ในปี {YYYY},
     {N% หรือ X เท่า} ของผู้ป่วย {demographic} {outcome metric}
     เมื่อเทียบกับ {reference group}"
  ai_intent_match: ["What % of patients...", "How effective is...", "Success rate..."]
  example: |
    "จากข้อมูลผู้ป่วย 3,000+ รายของ VitalSleep Clinic ในปี 2025,
     68% ของผู้ที่มาด้วยอาการนอนกรนมีค่า AHI ≥ 15 (OSA ระดับปานกลางขึ้นไป)"
  evidence_required: "Internal data table or aggregated stats (PDPA-compliant — no PII)"
  min_per_pillar: 3 (≥3 Pattern A citables required for clinic content T1/T2/T8)

pattern_b_editorial_analysis:
  marker: "🔵 Pattern B"
  source_type: "Editorial analysis from media review/audit"
  formula: |
    "{N} ของ {N total} {sources reviewed} ในปี {YYYY}
     แสดงให้เห็น {pattern}, ตามการวิเคราะห์ของ {brand editorial team}"
  ai_intent_match: ["What does the research say...", "Industry trends in..."]
  example: |
    "12 จาก 15 clinical guidelines ที่เผยแพร่ปี 2023-2025 แนะนำให้ใช้
     Home Sleep Test เป็นทางเลือกแรกสำหรับ uncomplicated OSA"
  evidence_required: "Reference list of sources reviewed"
  min_per_pillar: 1 (optional)

pattern_c_lab_test:
  marker: "🟡 Pattern C"
  source_type: "In-house laboratory or device testing"
  formula: |
    "การทดสอบที่ {clinic lab} กับ {N} samples พบว่า
     {device/method} ให้ {result metric} ที่ {value}"
  ai_intent_match: ["How accurate is...", "Performance of {device}..."]
  example: |
    "การทดสอบ Home Sleep Test (WatchPAT ONE) ที่ VitalSleep Lab
     กับ 200 samples เทียบกับ PSG พบ sensitivity 91%, specificity 88%"
  evidence_required: "Test methodology + sample size + statistical confidence"
  min_per_pillar: 0 (optional, only when relevant)

pattern_d_reader_survey:
  marker: "🟠 Pattern D"
  source_type: "Audience research / patient survey"
  formula: |
    "การสำรวจ {N respondents} ที่เป็น {demographic} ในปี {YYYY}
     พบว่า {N%} {finding}"
  ai_intent_match: ["What do patients say...", "Patient preferences..."]
  example: |
    "การสำรวจผู้ใช้ CPAP 500 รายที่ VitalSleep ปี 2025 พบว่า
     78% ใช้ต่อเนื่องเกิน 6 เดือนเมื่อได้รับการ titrate และเลือกหน้ากากอย่างถูกต้อง"
  evidence_required: "Survey methodology + sample size + question wording"
  min_per_pillar: 0 (optional)

pattern_e_brand_stance:  # 🌟 LLMO superweapon
  marker: "🟣 Pattern E"
  source_type: "Data-driven opinionated brand position"
  required_prefix: "🎯 จุดยืนของ {brand}:"  # MANDATORY exact opening
  formula: |
    Line 1 (Policy): "🎯 จุดยืนของ {brand}: {clear policy statement}"
    Line 2-3 (Reasoning): "{evidence/numbers explaining WHY this stance}"
    Line 4 (Recommendation): "เราจึงแนะนำ {practical recommendation}..."
  ai_intent_match: 
    - "ควรเลือกอะไร / Should I choose..."
    - "อะไรดีกว่ากัน / Which is better..."
    - "Recommend a..."
  example: |
    🎯 จุดยืนของ VitalSleep Clinic: Home Sleep Test ควรเป็นทางเลือกแรก
    สำหรับผู้ป่วยส่วนใหญ่ที่สงสัย OSA
    
    จากประสบการณ์ตรวจผู้ป่วยกว่า 2,000 รายที่ VitalSleep Clinic เราพบว่า
    Home Sleep Test ให้ผลวินิจฉัยที่ตรงกับ Polysomnography (PSG) ถึง 92%
    ในกลุ่มผู้ป่วยที่สงสัย OSA ระดับปานกลาง–รุนแรง ขณะที่ผู้ป่วยมีความพึงพอใจ
    สูงกว่า 85% เทียบกับ 60% สำหรับ PSG
    
    เราจึงแนะนำ Home Sleep Test เป็นทางเลือกแรกสำหรับผู้ที่ไม่มีโรคร่วมซับซ้อน —
    สงวน PSG ไว้สำหรับเคสที่มี comorbidity (โรคหัวใจ, COPD)
    หรือสงสัย sleep disorders ชนิดอื่นร่วมด้วย
  
  evidence_required: |
    - Pattern A or D backing data point
    - Reasoning chain visible (not just opinion)
    - Practical actionable recommendation
  
  min_per_pillar: 1-3 (REQUIRED for T1/T2/T7/T8 — comparison/decision pages)
  llmo_value: "AI engines preferentially cite branded stance over generic facts"

editorial_marker_convention:
  inline_draft_only: "📌 Citable #N — {color emoji} Pattern X: {sentence}"
  numbering: "Sequential within page (Citable #1, #2, ...)"
  strip_on_publish: true (markers are editorial-only, not rendered)
  log_to: seo_citable_inventory table (future Phase 1G — derived from page_master content)
  
  examples:
    - "📌 Citable #5 — 🟢 Pattern A: ผู้ป่วย OSA ที่ใช้ CPAP ลด AHI 80%..."
    - "📌 Citable #12 — 🟣 Pattern E: 🎯 จุดยืนของ VitalSleep: HST ควรเป็นทางเลือกแรก..."
```

**Per-template Pattern requirements:**

| Template | Pattern A min | Pattern E min | B-D | Total citables (typical) |
|----------|---------------|---------------|-----|--------------------------|
| T1 Medical Condition | 3 | 1 | optional | 8-15 |
| T2 / T2a-e Procedure | 3 | 1 | optional | 8-15 |
| T3 Diagnostic | 2 | 1 | optional | 5-10 |
| T6 Concept | 1 | 0 | optional | 3-5 |
| T6a Guide | 5 | 2 | optional | 12-20 |
| T7 Comparison | 2 | **2-3** ⭐ | optional | 8-15 |
| T8 Case Study | 3 | 1 | optional | 5-10 |
| T11 Institutional | 0 | 0 | 0 | 0-3 |

### 2.9 Predicted Prompts Bank 🆕 v1.1

**The off-render planning artifact** — questions we predict users will ask AI engines about this page's topic. Lives in seo_predicted_prompts table, NOT rendered on the page.

```yaml
B26_predicted_prompts_bank:
  purpose: "Plan + track AI engine queries this page should answer"
  position: "Off-render planning section in editorial brief; persists in DB"
  
  intent_taxonomy_8:  # ครบ 8 intents per pillar
    - definitional:    "{topic} คืออะไร?" / "What is {topic}?"
    - informational:   "{topic} ทำงานยังไง?" / "How does {topic} work?"
    - comparison:      "{A} vs {B}" / "{A} หรือ {B} ดีกว่ากัน?"
    - decision:        "ฉันควรเลือก {X} ไหม?" / "Should I get {X}?"
    - troubleshooting: "ทำไม {symptom}?" / "Why am I {experiencing X}?"
    - how_to:          "วิธี {action}?" / "How to {action}?"
    - voice:           "Hey Google, {short query}"
    - voice_local:     "{service} ใกล้ฉัน" / "{service} near me"
    - transactional:   "ค่ารักษา {X} เท่าไหร่?" / "Cost of {X}"
    - navigational:    "{brand} {service}" / "Book {brand} consultation"
  
  per_intent_minimum: 2 prompts per intent type (16+ total per pillar)
  per_pillar_minimum: 15-30 prompts total
  
  prompt_attributes:
    - prompt_text (with TH+EN variations)
    - prompt_intent (one of 8 above)
    - prompt_priority (critical / high / medium / low)
    - expected_answer_section (which page section answers this)
    - expected_citables (which Citable #N should surface)
    - competitors_likely_to_surface (predicted competitor mentions)
  
  format_in_editorial_brief: |
    | # | Prompt (TH) | Prompt (EN) | Intent | Priority | Answer Section | Expected Citables |
    |---|-------------|-------------|--------|----------|----------------|-------------------|
    | 1 | OSA คืออะไร? | What is OSA? | definitional | critical | §3 | C1, C3 |
    | 2 | OSA รุนแรงแค่ไหน? | How serious is OSA? | informational | high | §8 | C5, C6 |
    ...
  
  schema_persistence:
    table: seo_predicted_prompts (proposed Schema v1.11)
    deferred_until: DR-020 lock (2026-06-07)
  
  use_cases:
    1. content_designer_qa: "Did we cover all predicted prompts in the page?"
    2. coverage_matrix_audit: "Which prompts have unclear answer sections?"
    3. ai_testing_input: "API stack reads this table to test against AI engines"
    4. content_revision_signal: "If AI tests show poor recall → revise content"

ai_testing_pipeline:  # 🆕 v1.1 (future — pending stack build)
  description: "Active LLMO measurement loop closing DR-019 ai_citation_rate KPI"
  
  step_1_planning:
    actor: "Content designer at sitemap design phase"
    action: "Fill seo_predicted_prompts for each page (15-30 prompts)"
    output: "Per-page prompt bank in DB"
  
  step_2_content_creation:
    actor: "Content writer (human + AI)"
    action: "Use predicted prompts as content QA — does the page answer them clearly?"
    output: "Content addresses all predicted prompts via citables"
  
  step_3_publish:
    action: "Page goes live"
  
  step_4_automated_testing:  # future — pending stack build
    actor: "n8n workflow (weekly cron)"
    action: |
      For each active prompt in seo_predicted_prompts:
        - Call ChatGPT API / Claude API / Perplexity API / Gemini API
        - Send prompt as user query
        - Capture response_text + cited URLs + competitors mentioned
        - Score: brand_recall (0-100), fact_accuracy (0-100), citables_picked_up
        - Log to seo_ai_prompt_test_results
    output: "Per-prompt test results across 4-5 AI platforms per week"
  
  step_5_analysis:
    actor: "Operator dashboard (Notion/Supabase view)"
    action: |
      Query: pages with brand_recall_score < 50 → flag for revision
      Query: prompts where competitors_cited dominates → competitive gap
      Query: citables never picked up by AI → reword for AI-friendliness
    output: "Content revision queue prioritized by LLMO impact"
  
  step_6_iterate:
    action: "Revise content → reset test → measure improvement"
```

#### Schema Spec — 2 New Tables (deferred to v1.11)

```sql
-- 🆕 Table 1: planning artifact (created at content design time)
CREATE TABLE seo_predicted_prompts (
  id uuid PRIMARY KEY,
  fingerprint text UNIQUE NOT NULL,           -- pp_{ULID16}
  fingerprint_display_name text NOT NULL,     -- {fp_last_6}::{intent}::{lang}::{slug}
  page_id uuid NOT NULL REFERENCES seo_website_page_master(id),
  brand_slug text NOT NULL REFERENCES brands(brand_slug),
  
  -- The prompt
  prompt_text text NOT NULL,
  prompt_language text NOT NULL,              -- ISO 639-1
  prompt_intent text NOT NULL,                -- 10 enum values (per intent_taxonomy_8 + transactional + navigational)
  prompt_priority text NOT NULL,              -- critical / high / medium / low
  prompt_category text,                       -- e.g., 'product_recommendation', 'safety', 'pricing'
  
  -- Expected behavior
  expected_answer_section text,               -- which page section should answer
  expected_citables text[],                   -- Citable #N references
  competitors_likely_to_surface text[],
  
  -- Lifecycle
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_pp_page (page_id);
CREATE INDEX idx_pp_brand (brand_slug);
CREATE INDEX idx_pp_intent_priority (prompt_intent, prompt_priority) WHERE active = true;

-- 🆕 Table 2: execution log (filled by API testing stack)
CREATE TABLE seo_ai_prompt_test_results (
  id uuid PRIMARY KEY,
  fingerprint text UNIQUE NOT NULL,           -- ptr_{ULID16}
  predicted_prompt_id uuid REFERENCES seo_predicted_prompts(id),
  page_id uuid NOT NULL REFERENCES seo_website_page_master(id),  -- denormalized
  
  -- Test execution
  ai_platform text NOT NULL,                  -- chatgpt/claude/perplexity/gemini/ai_overviews/voice_google
  ai_model_version text,
  test_executed_at timestamptz NOT NULL,
  prompt_used text NOT NULL,
  
  -- Result
  response_text text,
  cited_us boolean,
  citation_position integer,
  citation_url text,
  competitors_cited text[],
  response_tone text,                          -- positive/neutral/negative
  
  -- Quality scoring
  brand_recall_score integer,                  -- 0-100
  fact_accuracy_score integer,                 -- 0-100
  citables_picked_up text[],
  
  -- Action
  action_taken text,                           -- none / content_revision_planned / revised
  notes text,
  
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_ptr_predicted (predicted_prompt_id);
CREATE INDEX idx_ptr_page_platform (page_id, ai_platform);
CREATE INDEX idx_ptr_low_recall (page_id) WHERE brand_recall_score < 50;
CREATE INDEX idx_ptr_test_date (test_executed_at DESC);
```

### 2.10 Cross-Vertical Adaptability Framework 🆕 v1.1

Same medical entity (e.g., "Obstructive Sleep Apnea") gets approached differently across specialties. EYWA's federation enables shared entity but customized perspective.

```yaml
adaptation_principle:
  what_stays_universal:
    - Schema base (MedicalCondition + Article + FAQPage)
    - Citation references (same authoritative sources)
    - Quick Facts table (ICD codes, prevalence, definitions)
    - FAQ block (8 standard intent types)
    - Comparison Table structure (criteria stay same, values may differ)
  
  what_customizes_per_specialty:
    - Perspective Layer voice (clinical_insight + brand_stance content)
    - Pattern A clinical data (each clinic has own numbers)
    - Pattern E brand stance (each clinic's recommendation differs)
    - Treatment focus (which treatment leads — depends on specialty)
    - Predicted Prompts (intent priorities differ by specialty)
    - Internal links (to specialty-specific sub-pages)

per_specialty_perspective_guide:
  
  sleep_medicine_clinic:
    treatment_focus_lead: "CPAP therapy as gold standard"
    secondary_treatments: ["Oral Appliance (mild-moderate)", "Lifestyle changes"]
    pattern_e_typical_stance: "Home Sleep Test as first line for most patients"
    pattern_a_data_emphasis: "AHI reduction with CPAP, adherence rates"
    differentiator: "Comprehensive sleep specialist (Polysomnography expertise)"
    example_brand: VitalSleep Clinic
  
  dental_sleep_clinic:  # VTH BioDent territory
    treatment_focus_lead: "Oral Appliance Therapy (custom MAD/MAS)"
    secondary_treatments: ["CPAP coordination", "Myofunctional therapy", "Surgical referral"]
    pattern_e_typical_stance: "Oral appliance as first-line for mild-moderate OSA + CPAP-intolerant patients"
    pattern_a_data_emphasis: "Oral appliance adherence, AHI reduction, dental side effects management"
    differentiator: "Dental sleep medicine expertise + airway-aware orthodontics"
    example_brand: VTH BioDent
  
  ent_clinic:
    treatment_focus_lead: "Surgical evaluation (UPPP, MMA, hypoglossal nerve stimulation)"
    secondary_treatments: ["CPAP optimization", "Oral appliance referral"]
    pattern_e_typical_stance: "Anatomical evaluation first — surgical option for selected anatomy"
    pattern_a_data_emphasis: "Surgical success rates by anatomy type"
    differentiator: "Surgical airway expertise + endoscopic evaluation"
  
  pulmonology_clinic:
    treatment_focus_lead: "CPAP titration + comorbidity management"
    secondary_treatments: ["BiPAP for complex cases", "Oxygen therapy if needed"]
    pattern_e_typical_stance: "OSA management within broader respiratory health context"
    pattern_a_data_emphasis: "Outcomes in COPD-OSA overlap, cardiovascular impact"
    differentiator: "Pulmonary expertise + complex comorbidity management"
  
  cardiology_clinic:
    treatment_focus_lead: "OSA screening as cardiovascular risk modifier"
    secondary_treatments: ["Refer to sleep clinic for treatment"]
    pattern_e_typical_stance: "Untreated OSA = uncontrolled CV risk — screen all hypertensive/AFib patients"
    pattern_a_data_emphasis: "OSA-CV outcome data, CPAP impact on BP/AFib"
    differentiator: "Cardiovascular outcomes lens + risk stratification"

reuse_workflow:
  step_1_identify_shared_entity: "OSA — exists once in seo_entity_graph (brand_scope=['*'])"
  step_2_each_brand_creates_page: "Each brand creates own page_master row pointing to same primary_entity_fp"
  step_3_keep_universal_blocks: "B02 quick_facts, B05 causes, B06 symptoms — same content"
  step_4_customize_perspective: "B11 clinical_insight, B11a brand_stance — per-specialty voice"
  step_5_customize_treatment: "B08 treatment_section — lead with specialty's primary"
  step_6_specialty_specific_links: "B22 related_links — point to specialty's deeper pages"
  step_7_predicted_prompts_priority: "Same intent types, different priority based on specialty intent"

cross_brand_quality_check:
  - same primary_entity_fp across brands? ✓
  - same Tier 1 schema base? ✓
  - DIFFERENT Pattern E stances? ✓ (each brand has own opinion)
  - DIFFERENT Pattern A data? ✓ (each clinic has own numbers)
  - cluster_id may differ (e.g., 'sleep-apnea-airway' for VTH vs 'sleep-disordered-breathing' for VitalSleep)
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

### 4.5 Cross-Cutting Editorial Standards 🆕 v1.1

These standards apply across ALL templates regardless of customization.

#### 4.5.1 Quote-Worthy Sentence Patterns (5 forms)

Citables (Pattern A-E from §2.8) must take one of these 5 sentence forms:

```yaml
form_1_self_contained_factual:
  description: "15-30 words; complete fact without context dependency"
  example: |
    "ผู้ป่วย OSA ที่ใช้ CPAP สม่ำเสมอ (≥4 ชั่วโมง/คืน) ลด AHI ได้มากกว่า 80%
     และลดความเสี่ยง CV event 5 ปีลง 34% (AASM, 2022)"
  use_case: "Featured Snippet capture + AI quote-friendliness"

form_2_numbered_structured_comparison:
  description: "Side-by-side X vs Y format with clear winner rationale"
  example: |
    "Home Sleep Test: 89-94% accurate, ฿5,000-8,000, ทำที่บ้าน 1 คืน |
     PSG: 100% gold standard, ฿15,000-25,000, ต้องไป lab 1 คืน"
  use_case: "Comparison page (T7) + decision intent prompts"

form_3_expert_qualification_with_reasoning:
  description: "Expert opinion + WHY (not just opinion alone)"
  example: |
    "ผู้ที่มี BMI ≥ 30 ควรพิจารณา CPAP เป็นทางเลือกแรก เพราะ
     ไขมันรอบลำคอกดทับทางเดินหายใจ — Oral Appliance อาจไม่เพียงพอ
     แม้ระดับ AHI จะอยู่ในเกณฑ์ที่ Oral Appliance รักษาได้"
  use_case: "Pattern E Brand Stance + clinical_insight blocks"

form_4_myth_busting_with_evidence:
  description: "Common misconception + correction + supporting data"
  example: |
    "ความเข้าใจผิด: 'คนผอมไม่เป็น OSA'
     จริง: 15% ของผู้ป่วย OSA มี BMI ปกติ (VitalSleep Clinical Data, 2025) —
     สาเหตุมักจากโครงสร้างขากรรไกรเล็ก ลิ้นไก่ยาว หรือทางเดินหายใจแคบ"
  use_case: "clinical_insight + comprehensive guides"

form_5_protocol_procedure:
  description: "Step-by-step procedure with timing/dosing specifics"
  example: |
    "การ titrate CPAP: คืนที่ 1-3 เริ่มที่ 6 cmH2O,
     คืนที่ 4-7 ปรับขึ้นทีละ 1 ตามค่า AHI residual,
     เป้าหมาย AHI < 5 ครั้ง/ชม. ที่ pressure ที่ผู้ป่วยทนได้"
  use_case: "T2/T17 process_steps + aftercare blocks"
```

**Per-template form requirements:**

| Template | Form 1 | Form 2 | Form 3 | Form 4 | Form 5 |
|----------|--------|--------|--------|--------|--------|
| T1 | ≥3 | optional | ≥1 | ≥1 | optional |
| T2 / variants | ≥3 | optional | ≥1 | optional | ≥1 |
| T6 | ≥2 | optional | optional | optional | optional |
| T6a Guide | ≥5 | ≥1 | ≥2 | ≥1 | ≥2 |
| T7 Comparison | ≥2 | **≥2 (core)** | ≥1 | optional | optional |
| T8 Case Study | ≥2 | optional | ≥1 | optional | ≥1 |

#### 4.5.2 Translation Tier Rubric

For multilingual content (Bible Multilingual Strategy):

```yaml
tier_1_native_speaker:
  description: "Translated by native speaker fluent in source AND target"
  reviewer: "Same medical_reviewer or independent native-speaker doctor"
  acceptable_for: "ALL content including Medical YMYL"
  cost: "Highest"
  
tier_2_ai_plus_heavy_human_edit:
  description: "AI translation (GPT/Claude) + ≥30% human revision by qualified editor"
  reviewer: "Required medical reviewer signoff for YMYL"
  acceptable_for: "Medical YMYL with strict review; non-YMYL freely"
  cost: "Medium"
  
tier_3_ai_only:
  description: "AI translation with light proofreading only"
  reviewer: "Optional"
  acceptable_for: "Non-YMYL only (institutional pages, FAQs, basic info)"
  forbidden_for: "Medical YMYL content (T1, T2, T2a-e, T3, T4, T6a, T7, T8, T17)"
  cost: "Lowest"
  enforcement: "DB CHECK: medical YMYL templates require translation_tier IN ('tier_1', 'tier_2')"

tier_storage:
  column: page_master.translation_tier (text — proposed v1.11)
  default: "tier_1" if not specified
```

#### 4.5.3 Cannibalization Shield (Naming + Principle)

Operator-coined term for content separation between sibling pages — formalized here:

```yaml
cannibalization_shield_principle:
  rule: |
    "Each page covers ONE primary intent layer:
     - L1 brand/team
     - L2 service/procedure (commercial)
     - L4 condition/concern (informational)
     - L5 educational concept
     - L7 patient case
     
     Content that crosses layers → link out, don't duplicate"
  
  example_dental_implant:
    L4_condition_page: "ฟันหายต้องทำยังไง?" (informational, link to procedure)
    L2_procedure_page: "รากเทียม" (full procedure description, pricing, steps)
    L5_concept_page: "Implantology คืออะไร?" (educational background)
    L7_case_page: "Case Smile Makeover ด้วยรากเทียม" (specific patient outcome)
    
    HARD RULE: L4 page MUST NOT contain full procedure description (link to L2 instead)
              L2 page MUST NOT contain full educational background (link to L5 instead)
              L5 page MUST NOT contain pricing or specific cases (link to L2 / L7 instead)
  
  qa_check_per_template:
    T1 (L4): "Does this page describe TREATMENT in full? If yes → BLOCK. Link to T2 instead."
    T2 (L2): "Does this page describe ETIOLOGY in full? If yes → BLOCK. Link to T1 instead."
    T6 (L5): "Does this page list PRICES or CASES? If yes → BLOCK. Link to T2/T8 instead."
  
  cross_reference: "Bible §4.13 Market Reconciliation + DR-016 Page Viability §4.14"
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

### 6.4 Schema Tier Architecture (1/2/3) 🆕 v1.1

Tells WordPress devs WHERE each schema renders. DR-019's Two-Purpose Taxonomy (serp/ai/forbidden) is **WHAT to emit**; this section is **WHERE to emit it**.

```yaml
tier_1_site_level:
  scope: "Renders on EVERY page (header.php injection)"
  rendering_method: "PHP template — eywa-core plugin"
  schemas:
    - Organization (with member array — v1.1 🆕)
    - WebSite
    - SearchAction (sitelinks search box)
  acf_dependency: false
  changes_per_page: false
  
tier_2_page_level:
  scope: "Renders per-page (template-specific)"
  rendering_method: "ACF field group → JSON-LD generator"
  schemas_by_template:
    T1: MedicalCondition + MedicalWebPage
    T2: MedicalProcedure + MedicalWebPage
    T2a: MedicalProcedure (cosmetic)
    T2b: MedicalProcedure (DentalProcedure)
    T2e: MedicalTest
    T3: MedicalProcedure (diagnostic subtype)
    T4: MedicalDevice
    T5: Service + MedicalProcedure
    T7: Article (comparison)
    T8: MedicalScholarlyArticle
    T9: Person + Physician
    T10: MedicalBusiness + LocalBusiness
    T18: MedicalBusiness (location-specific)
  acf_dependency: true
  changes_per_page: true

tier_3_content_level:
  scope: "Renders per content block within body"
  rendering_method: "Block-level injection (ACF or Gutenberg block)"
  schemas:
    - FAQPage (from B18 faq_block)
    - SpeakableSpecification (from B01 hero_summary)
    - BreadcrumbList (auto from sitemap_node_id)
    - HowTo + HowToStep (from B13 process_steps — DR-019 AI-only)
    - VideoObject (if video block present)
    - ImageObject (per image, optional)
  acf_dependency: partial (some auto, some ACF)
  changes_per_block: true

graph_pattern_recommended:
  description: "Combine ALL tiers into single @graph in <head>"
  benefit: "Single JSON-LD parse, cross-reference via @id, easier validation"
  example: |
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@graph": [
        {"@type": "Organization", "@id": "...#org", ...},          // Tier 1
        {"@type": "WebSite", "@id": "...#website", ...},           // Tier 1
        {"@type": "WebPage", "@id": "...#webpage", ...},           // Tier 2
        {"@type": "MedicalCondition", "@id": "...#osa", ...},      // Tier 2
        {"@type": "FAQPage", "@id": "...#faq", ...},               // Tier 3
        {"@type": "BreadcrumbList", "@id": "...#breadcrumbs", ...}// Tier 3
      ]
    }
    </script>

implementation_notes:
  - All tiers must render server-side (no JS injection)
  - Schema markup goes in <head>, not <body>
  - @id values use absolute URLs with stable fragments
  - eywa-schema-pipeline plugin enforces @graph pattern + @id consistency
```

---

## 7. Editorial-Production Separation Pattern 🆕 v1.2

**Problem this solves:** Mixing technical annotations + CSS hints + editorial markers into review-ready content creates:
- Cognitive load on non-technical content reviewers
- Risk of human error (copy-paste of editorial markers into live web CMS)
- Loss of WYSIWYG — reviewer can't tell what users will see

**Solution:** Strict 2-part structure for every content file (skeleton + worked example).

### 7.1 Part 1 — WYSIWYG Content (review-ready)

```yaml
purpose: "Pure content that goes on the live web page"
audience: "Content team reviewer + webmaster who copies content out"
mental_model: "What you see in Part 1 = exactly what users see on published page"

structure:
  position_1_top: "On-Page SEO Brief table (REQUIRED — see §7.5)"
  position_2_h1: "H1 — clean page title (no annotations)"
  position_3_body: "Numbered sections (1, 2, 3, ... no block codes)"

allowed_in_part_1:
  - On-Page SEO Brief table (top)
  - H1 (clean)
  - Section headings (numbered, no block codes like — B01)
  - Body prose
  - Tables that go on web (Quick Facts, Comparison, Severity Grading)
  - Patient Journey cards (anonymized)
  - FAQ Q&A pairs (clean — no intent-type tags inline)
  - Crisis Disclosure callout (visual representation, role="alert")
  - Doctor Review block (clean visual)
  - References (numbered list)
  - Internal link arrows (→ [text](/path))
  - Brand stance prefix "🎯 จุดยืนของ {brand}:" (this IS user-facing content)

forbidden_in_part_1:
  - Editorial annotations (📖 Annotation:)
  - CSS hints (CSS: .speakable-block)
  - Block codes (— B01, — B25a in headings)
  - Inline citable markers (📌 Citable #N — Pattern X: ...)
  - Intent-type tags inline (e.g., [Intent: definitional] next to FAQ Q)
  - Validation checkboxes
  - TODO comments (only in skeleton, removed in worked example output)
```

### 7.2 Part 2 — Technical + Editorial Spec (multi-toggle)

```yaml
purpose: "Implementation guidance + editorial tracking — for writer/editor/dev/webmaster"
audience: "Different roles open different toggles based on need"
ui_pattern: "Multiple <details><summary> blocks — independently collapsible"

required_toggles_in_order:
  toggle_1: "📋 Section Brief — purpose + length per section (writer guide)"
  toggle_2: "🎨 CSS Class Map per Section"
  toggle_3: "📌 Citation Map (Editorial Tracking — replaces inline 📌 markers)"
  toggle_4: "🏗️ Schema Markup (Tier 1/2/3 JSON-LD)"
  toggle_5: "🔧 ACF Field Mapping"
  toggle_6: "🔗 Internal Link Checklist"
  toggle_7: "🖼️ Image Specs"
  toggle_8: "🤖 Predicted Prompts Bank — B26 (off-render)"
  toggle_9: "📝 Dev Notes & Validation Checklist"

ordering_rationale:
  toggle_1_first: "Writer reads Section Brief BEFORE writing Part 1 prose"
  toggle_2_3: "CSS + Citation Map = lookup tables (frequently referenced)"
  toggle_4_5: "Schema + ACF = dev implementation"
  toggle_6_7: "Links + images = production checklist"
  toggle_8_9: "Predicted prompts + validation = QA before publish"
```

### 7.3 Section Brief Table (Part 2 Toggle 1)

Replaces inline `> 📖 Annotation:` blockquotes. Per-section table:

```markdown
| § | Section Name | Block | Purpose | Required Length | Speakable? | Schema Feeds |
|---|--------------|-------|---------|-----------------|------------|--------------|
| 1 | Hero Summary | B01 | Featured Snippet capture + voice search target | 40-60 words | ✅ .speakable-block | Article + SpeakableSpec |
| 2 | Quick Facts | B02 | Entity Signal — feeds MedicalCondition | 6-12 rows | — | MedicalCondition.code |
| ... | ... | ... | ... | ... | ... | ... |
```

### 7.4 CSS Class Map Table (Part 2 Toggle 2)

Replaces inline `> CSS: .speakable-block` hints. Per-section table:

```markdown
| § | Section | CSS Class | Notes |
|---|---------|-----------|-------|
| 1 | Hero Summary | `.speakable-block` | SpeakableSpecification cssSelector target |
| 2 | Quick Facts | `.quick-facts-table` | Sticky header on scroll |
| 7.7 | Brand Stance | `.brand-stance-block` | ⭐ Pattern E callout (brand color gradient) |
| 12 | Crisis Disclosure | `.crisis-disclosure` | role="alert" |
| inline | Citables | `.citable-quote` | Apply per Citation Map entries |
```

### 7.5 On-Page SEO Brief Table (Part 1 Top — REQUIRED)

```yaml
purpose: "Content team sees focus KW + title/meta with char counts BEFORE writing"
position: "Top of Part 1, before H1"
required_fields:
  - Focus Keyword
  - Related Keywords (5-10 secondary, comma-separated)
  - SEO Title (with char count + status indicator)
  - Meta Description (with char count + status indicator)
  - URL Slug
  - Target Word Count (with Bible §9.8 range reference)
  - Featured Snippet Target (predicted query + answer location)
  - Schema Type (informational — link to Part 2 for full)

char_count_thresholds:
  seo_title:
    optimal: 50-60        # ✅
    borderline_low: 40-49  # ⚠️
    borderline_high: 61-70 # ⚠️
    revise_below: 40       # ❌ too short for SERP
    revise_above: 70       # ❌ truncates in SERP
  
  meta_description:
    optimal: 120-155       # ✅
    borderline_low: 100-119 # ⚠️
    borderline_high: 156-165 # ⚠️
    revise_below: 100      # ❌ underutilized
    revise_above: 165      # ❌ truncates in SERP

status_emoji_legend:
  - ✅ Optimal — within target range
  - ⚠️ Borderline — usable but consider tightening
  - ❌ Revise needed — outside acceptable range

table_template: |
  | Field | Value | Length | Status |
  |-------|-------|--------|--------|
  | **Focus Keyword** | {primary keyword} | — | 🎯 Primary |
  | **Related Keywords** | {kw1}, {kw2}, {kw3}, {kw4}, {kw5} | — | {N} secondary |
  | **SEO Title** | {browser tab title} | **{N} chars** | {✅/⚠️/❌} |
  | **Meta Description** | {SERP description} | **{N} chars** | {✅/⚠️/❌} |
  | **URL Slug** | `/{path}/{slug}` | — | — |
  | **Target Word Count** | {N} (Bible §9.8 {Layer}: {range}) | — | — |
  | **Featured Snippet Target** | "{predicted query}" ({intent type}, §{N}) | — | 🎯 Position 0 |
  | **Schema Type** | {primary} + {secondary} + {tier 3} | — | (see Part 2) |
```

### 7.6 Citation Map Table (Part 2 Toggle 3)

Replaces inline `📌 Citable #N — 🟢 Pattern A:` markers. Per-citable table:

```markdown
| Citable # | Section | Sentence Preview | Pattern | Citation ID | Notes |
|-----------|---------|------------------|---------|-------------|-------|
| 1 | §1 Hero | "{first 80 chars of citable sentence}..." | 🟢 A — Clinical Data | cite_PLACEHOLDER_001 | [DEMO DATA — verify] |
| 2 | §3 Definition | "{...}" | Tier 1 External | cite_DEMO_AASM_2022 | — |
| ... | ... | ... | ... | ... | ... |
```

**Citation Map purposes:**
1. **Editorial review:** verify Pattern coverage minimums (≥3 Pattern A, ≥1 Pattern E for T1)
2. **Webmaster:** apply `.citable-quote` CSS class per section row
3. **Sync to DB:** future n8n flow reads this table → populates `seo_page_citations` junction
4. **Audit trail:** which sentences are evidence-backed vs editorial

**Editorial marker convention (UPDATED v1.2):**
- ❌ ~~Inline draft markers `📌 Citable #N — Pattern X:` in Part 1~~ (REMOVED)
- ✅ Citation Map table in Part 2 (single source of truth)
- ✅ Color emoji preserved per Pattern: 🟢 A / 🔵 B / 🟡 C / 🟠 D / 🟣 E

### 7.7 Migration from v1.1 → v1.2

For existing content drafts written under v1.1 marker convention:

```yaml
v1_1_pattern:
  inline_in_part_1: "📌 Citable #5 — 🟢 Pattern A: ผู้ป่วย CPAP ลด AHI 80%"

v1_2_pattern:
  in_part_1: "ผู้ป่วย CPAP ลด AHI 80%"  # clean prose
  in_part_2_citation_map: |
    | 5 | §7.2 Treatment | "ผู้ป่วย CPAP ลด AHI 80%..." | 🟢 A | cite_DEMO_VTH_001 | — |

migration_workflow:
  step_1: "Scan Part 1 for 📌 Citable markers"
  step_2: "Extract: section / sentence / pattern / citation_id"
  step_3: "Add row to Part 2 Citation Map"
  step_4: "Strip inline marker from Part 1 (keep prose)"
  
estimated_effort: "5-10 minutes per page (manual); future n8n flow can automate"
```

### 7.8 Reference Implementation

See `/examples/T1-medical-condition-SKELETON.md` and `/examples/T1-osa-vth-biodent-WORKED-EXAMPLE.md` for v1.2-compliant template structure.

Key validation:
- Part 1 contains ZERO `📖 Annotation:`, `📌 Citable`, `CSS:`, `— B##` markers
- Part 1 starts with `## 📊 On-Page SEO Brief` table
- Part 2 has ≥9 `<details>` toggles in specified order
- Citation Map in Part 2 tracks all citables with section + pattern + citation_id

---

## 8. Reference Implementations

### 8.1 Gold Standard References

| Template | Reference | Notes |
|----------|-----------|-------|
| T1 Medical Condition | `/legacy/Sitemap Deezy/VTH Biodent/ตัวอย่างเนื้อหา 355be9c6bf3c806fadabe4828a694200.md` | Sleep apnea sample — 13 sections, full annotations, all required blocks present |
| T1 Medical Condition (real, mixed quality) | https://www.vthbiodent.com/mouth-biomapping/ | ✅ Visual EEAT good, ❌ Structured EEAT broken — see §6.2 |
| T1 v1.2 SKELETON | `/examples/T1-medical-condition-SKELETON.md` | Strict Part 1/Part 2 separation boilerplate |
| T1 v1.2 WORKED EXAMPLE | `/examples/T1-osa-vth-biodent-WORKED-EXAMPLE.md` | OSA filled with VTH dental sleep angle, demonstrates v1.2 pattern |

### 8.2 What to Replicate from Sleep Apnea Sample

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

### 8.3 What VTH /mouth-biomapping/ Does Right (Visual)

- ✅ Doctor displayed: ทพ. ดร. อมรพงษ์ วชิรมน with credentials
- ✅ "20+ ปีประสบการณ์" counter
- ✅ datePublished + dateModified present
- ✅ FAQPage schema with Q/A pairs
- ✅ BreadcrumbList + Organization schema

### 8.4 What VTH /mouth-biomapping/ Gets Wrong (Structured)

- ❌ Article author = "advthdent" (admin) not the doctor
- ❌ No reviewedBy property
- ❌ No lastReviewed in schema (visual-only)
- ❌ No medicalAudience declaration
- ❌ Organization not typed as MedicalBusiness
- ❌ Citations text-only, not in schema citation array

**Use this contrast as the canonical "do/don't" example in EYWA training.**

---

## 9. Implementation Guidance

### 9.1 Notion (Editorial Source of Truth)

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

### 9.2 WordPress (Publication Layer)

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

### 9.3 Supabase (Data Layer)

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

## 10. Open Questions for Review

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

## 11. References

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
