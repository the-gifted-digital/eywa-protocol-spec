# {Brand Display Name} — Phase B Patient Journey Map

> **Stage:** Stage 1 → Phase B (Lean Research, DR-022)
> **Goal:** Map audience persona + funnel stages + painpoint catalog + anxiety triggers — feeds Phase F content brief context (painpoint→hook, anxiety_level→tone, funnel_stage→CTA per DR-022)

---

## Primary Persona

### Demographics

- **Age range:** {e.g., 30-60}
- **Gender:** {if relevant — some verticals skew}
- **Income tier:** {e.g., upper-middle-class — premium-conscious but not ultra-luxury}
- **Location:** {urban Bangkok / nationwide / specific regions}
- **Occupation patterns:** {office worker / business owner / professional / retiree}

### Psychographics

- **Values:** {what matters to them — health, quality, family, status}
- **Lifestyle:** {how they spend free time, what they consume in media}
- **Health literacy:** {high — researches before deciding / medium — trusts referrals / low — relies on word of mouth}
- **Brand sensitivity:** {care about brand name? international vs Thai?}

### Decision drivers

| Driver | Weight | Notes |
|--------|--------|-------|
| Price | {high/med/low} | {context} |
| Doctor expertise | {high/med/low} | {context} |
| Clinic reputation | {high/med/low} | {context} |
| Technology / modernity | {high/med/low} | {context} |
| Location convenience | {high/med/low} | {context} |
| Warranty / safety | {high/med/low} | {context} |
| Peer recommendation | {high/med/low} | {context} |

---

## Secondary Personas (Adjacent Segments)

{If applicable — e.g., elderly parents of primary persona, professional referrers, expat community}

### Persona 2 — {Name}

{Repeat structure briefly}

---

## Funnel Stage Map

### Awareness Stage

**Patient state:** "I notice something is wrong / I want to look better / I heard about X"

**Painpoints at this stage:**

1. {e.g., "Wake up with headache repeatedly"}
2. {e.g., "Embarrassed to smile in photos"}
3. {e.g., "Eating becomes painful"}

**Anxiety triggers:**

- {e.g., Fear of unknown diagnosis}
- {e.g., Fear of cost ballooning}

**Information they seek:**

- {Symptom education}
- {Cause exploration}
- {Self-test / when to see a doctor}

**Content type fit:** Long-form educational (T1 condition, T6a guide), short FAQ (T6b)

**CTA pattern:** "Read more" / "Take quiz" / "Free consultation"

---

### Consideration Stage

**Patient state:** "I'm researching solutions — which option is right for me?"

**Painpoints at this stage:**

1. {e.g., "Confused between option A and option B"}
2. {e.g., "Worried about pain/recovery time"}
3. {e.g., "Don't know how to compare prices"}

**Anxiety triggers:**

- {e.g., Wrong choice irreversible}
- {e.g., Sales pressure from clinics}

**Information they seek:**

- {Comparison content (A vs B)}
- {Real patient experiences (case studies, reviews)}
- {Pricing transparency}
- {Doctor credentials}

**Content type fit:** Comparison (T6b), case studies (T17), service deep-dive (T2), doctor profile (T9)

**CTA pattern:** "Compare options" / "See cases" / "Meet our doctors" / "Get a quote"

---

### Decision Stage

**Patient state:** "I'm ready to book — which clinic?"

**Painpoints at this stage:**

1. {e.g., "Last-minute doubts about clinic safety"}
2. {e.g., "Payment options unclear"}
3. {e.g., "Scheduling friction"}

**Anxiety triggers:**

- {e.g., First visit nerves}
- {e.g., Financial commitment}

**Information they seek:**

- {Booking flow + ease}
- {Payment + financing options}
- {Pre-visit prep instructions}
- {Branch location + parking}

**Content type fit:** Branch page (T7), pricing page (T19), patient guide (T11), CTA landing (T2 commercial)

**CTA pattern:** "Book now" / "Add LINE @" / "Call to schedule" / "Apply for 0% installment"

---

### Post-Visit / Loyalty Stage

**Patient state:** "How do I maintain / when should I return / should I recommend?"

**Painpoints at this stage:**

1. {e.g., "Forgot aftercare instructions"}
2. {e.g., "Unsure when to come back"}
3. {e.g., "Want to recommend to family but unsure how"}

**Content type fit:** Aftercare guide (T6a), follow-up reminders (email/LINE), referral program info

**CTA pattern:** "Schedule follow-up" / "Refer a friend"

---

## Painpoint Catalog (consolidated)

> This catalog feeds `seo_x_ads_keywords_contextual_master.keyword_painpoint` column.

| ID | Painpoint (TH) | Related Cluster | Funnel Stage | Anxiety Level |
|----|---------------|----------------|-------------|---------------|
| PP-1 | {e.g., "อยากรู้ค่าใช้จ่ายในการทำรากฟันเทียม"} | Hero Service | Consideration | Medium |
| PP-2 | {...} | ... | ... | ... |

---

## Anxiety Trigger Catalog

> Feeds `seo_x_ads_keywords_contextual_master.anxiety_level` column.

| Anxiety Level | Tone Calibration | Example KW Pattern |
|--------------|-----------------|-------------------|
| High | Reassuring + empathetic + slow + explicit safety | "{condition} อันตรายไหม", "{procedure} เจ็บไหม" |
| Medium | Educational + factual + balanced | "{procedure} ขั้นตอน", "{procedure} กี่วัน" |
| Low | Informational + neutral | "{condition} คืออะไร", "{procedure} ราคา" |

---

## Voice Calibration Cheat Sheet (for Phase F content writers)

```yaml
high_anxiety_content:
  open_with: acknowledgment of fear + reassurance ("เข้าใจว่ากังวล...")
  avoid: graphic clinical detail without warning, jargon
  emphasize: safety record, doctor expertise, patient testimonials
  CTA: low-friction (free consultation, no commitment)

medium_anxiety_content:
  open_with: clear factual framing
  avoid: over-promising, vague reassurance
  emphasize: process clarity, expected outcomes
  CTA: medium-friction (comparison tool, quote request)

low_anxiety_content:
  open_with: direct answer
  avoid: unnecessary hedging
  emphasize: depth + technical accuracy
  CTA: any (no anxiety friction)
```

---

## Operator Action Items

1. {e.g., "Validate persona via 5 patient interviews"}
2. {e.g., "Pull 30 recent reviews from Google/Facebook for painpoint extraction"}
3. {e.g., "Confirm secondary persona priority — pursue or defer?"}

---

## Next Phase Triggers

✅ **Phase B output ready** when persona + funnel + painpoint catalog ≥80% filled
🟡 **Phase C Entity Genesis** uses painpoint catalog for "concern" entity discovery
🟡 **Phase F Content Production** consumes painpoint + anxiety + funnel_stage per page via `seo_x_ads_keywords_contextual_master` (DR-022)

---

*Initialized via `templates/folder-skeleton/content-plan/patient-journey.template.md`. Per DR-022 (Proposed) — Phase B output file (replaces section of legacy `research-notes.md`).*
