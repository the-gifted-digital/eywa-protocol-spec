# {Brand Display Name} — Brand-Specific Decision Records

> **Scope:** Decisions specific to {Brand Name}. For universal EYWA decisions, see `eywa-protocol-spec/DECISION_RECORDS.md`.

**Format:** Reverse chronological (newest first)
**DR Prefix:** `{BRAND-CODE}-DR-NNN` (e.g., SS-DR for SmileScape, VTH-DR for VTH BioDent)
**Per Handover §9.1 Path 1:** Brand-specific decisions adapt the brand immediately; status defaults to **Locked** (no soak required — brand owns the call).

---

## Decisions Log

<!--
Template for new entries:

## [{PREFIX}-DR-NNN] — Title ({YYYY-MM-DD})

**Status:** Locked (brand owns this decision per §9.1 Path 1)
**Companion to:** {Universal DR if relevant — e.g., DR-007 URL Structure}

**Context:**
{What problem are we solving for THIS brand?}

**Decision:**
{What did we choose?}

**Rationale:**
{Why this option vs alternatives, in the context of THIS brand's voice/audience/positioning?}

**Consequences:**
{Trade-offs, follow-ups, downstream impact on Phase B-G work.}
-->

---

## Format Template (universal)

```markdown
## [{PREFIX}-DR-NNN] — Title (YYYY-MM-DD)

**Status:** Locked | Proposed | Superseded by {PREFIX}-DR-XXX
**Companion to:** Universal DR-NNN (if relevant)

**Context:** Problem statement
**Decision:** What was chosen
**Rationale:** Why this option won
**Consequences:** Trade-offs + follow-ups
```

---

## When to Log a Brand DR

Per Handover §9.1 — log here when the decision is **brand-specific only** (does not affect spec or other brands). Examples:

- Hero service strategy specific to this brand's pricing tier
- Brand naming conventions in content (e.g., "we use Service Name X not Y")
- Section structure deviations from standard sitemap
- Voice/tone exceptions
- Skipping spec-baseline files due to brand context

**If decision affects multiple brands or spec → propose universal DR (`DECISION_RECORDS.md`) instead.**

---

## Future {PREFIX}-DR Placeholders

```yaml
common_decision_topics_brands_face:
  - Hero offering positioning (Tier A / Tier B differentiation)
  - Brand-vs-method content naming rules
  - Founder treatment (separate section vs in-line)
  - Multilingual launch timing
  - Sub-brand strategy (Facebook page, sister clinic)
  - Cross-brand link governance
  - Brand-specific compliance handling (regulatory differences per vertical)
```

---

*Initialized via `templates/folder-skeleton/docs/decision-records.template.md`. Replace `{PREFIX}` with brand code (e.g., SS for SmileScape, VTH for VTH BioDent).*
