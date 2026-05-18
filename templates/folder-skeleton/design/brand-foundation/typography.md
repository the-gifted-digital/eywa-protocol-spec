# Typography — {Brand Name}

> **Per DR-029 + Bible Part 31.** Typeface choices, scale rationale, voice extension.
> **Token source:** `design/tokens/core.tokens.json` (`typography.*`) + `design/tokens/semantic.tokens.json` (`typography.heading-1` etc.)

---

## 1. Typography Philosophy

> {How does typography express the brand voice? Connect to DNA Graph Field 6 + messaging.md voice ID.}

Example: "Calm authority — Apple restraint + Notion warmth. Inter primary for tech clarity. No display fonts that scream. Letter spacing tight for confidence, line height generous for breathing room."

---

## 2. Typeface Selection

### Display Font (headlines)

| Property | Value | Rationale |
|----------|-------|-----------|
| Name | TBD | {why this typeface — voice fit / legibility / Thai support} |
| Token | `{typography.fontFamily.display}` | |
| Source | Google Fonts / Adobe / Custom | |
| License | TBD | |
| Weights used | 600 (semibold) + 700 (bold) | |
| Thai support? | yes/no — if no, fallback Thai typeface? | |
| Where to find | URL / file path | |

### Body Font

| Property | Value | Rationale |
|----------|-------|-----------|
| Name | TBD | {readability at small sizes, Thai pairing} |
| Token | `{typography.fontFamily.body}` | |
| Source | TBD | |
| Weights used | 400 (regular) + 500 (medium) + 600 (semibold) | |
| Thai support? | yes/no | |

### Mono Font (code blocks, data, technical content)

| Property | Value |
|----------|-------|
| Name | TBD (e.g., JetBrains Mono, Fira Code, Geist Mono) |
| Token | `{typography.fontFamily.mono}` |
| Use cases | Code, technical data, schema examples |

---

## 3. Type Scale (Modular)

Recommended modular scale: **1.25 (major third)** for editorial brands, **1.333 (perfect fourth)** for tech/SaaS brands.

| Token | rem | px (16px base) | Use case |
|-------|-----|----------------|----------|
| `fontSize.xs` | 0.75rem | 12px | Footer text, fine print |
| `fontSize.sm` | 0.875rem | 14px | Captions, meta info |
| `fontSize.base` | 1rem | 16px | Body text default |
| `fontSize.lg` | 1.125rem | 18px | Lead paragraphs |
| `fontSize.xl` | 1.25rem | 20px | Subheadings |
| `fontSize.2xl` | 1.5rem | 24px | Card titles, H4 |
| `fontSize.3xl` | 1.875rem | 30px | Section subheadings, H3 |
| `fontSize.4xl` | 2.25rem | 36px | Page titles, H2 |
| `fontSize.5xl` | 3rem | 48px | Major headlines, H1 |
| `fontSize.6xl` | 3.75rem | 60px | Hero on tablet/desktop |
| `fontSize.7xl` | 4.5rem | 72px | Hero on large desktop only |

---

## 4. Semantic Type Roles (per semantic.tokens.json)

| Role | Token | Settings |
|------|-------|----------|
| `heading-1` | `{typography.heading-1}` | display / 5xl / bold / tight / -0.02em |
| `heading-2` | `{typography.heading-2}` | display / 4xl / semibold / tight |
| `heading-3` | `{typography.heading-3}` | display / 2xl / semibold / snug |
| `body-base` | `{typography.body-base}` | body / base / regular / normal |
| `body-large` | `{typography.body-large}` | body / lg / regular / normal |
| `caption` | `{typography.caption}` | body / sm / regular / snug |

---

## 5. Line Height Discipline

| Token | Value | When to use |
|-------|-------|-------------|
| `lineHeight.tight` | 1.1 | Display headlines (5xl+) only |
| `lineHeight.snug` | 1.3 | Subheadings (2xl-4xl) |
| `lineHeight.normal` | 1.5 | Body text default |
| `lineHeight.relaxed` | 1.75 | Long-form articles, knowledge content |

---

## 6. Voice Extension (link to messaging.md)

> Typography is voice made visual. Pair with brand voice rules:

- **Voice ID:** {from messaging.md — e.g., "The expert who explains like a friend"}
- **Type personality translation:**
  - "Expert" → letter-spacing tight on headlines (confident, no wobble)
  - "Like a friend" → line-height relaxed on body (breathing, conversational)
  - "Quietly" → max H1 size 5xl (not 6xl/7xl — restraint)
  - "Never showy" → no display fonts (Bodoni/Playfair/Didone — exclude unless premium-doc context per memory `feedback_premium_doc_design.md`)

---

## 7. Thai + English Typography Pairing

> Thai-first brands (per DR-EYWA-MKT-013 for EYWA marketing — applies similar pattern per brand):

| Concern | Approach |
|---------|---------|
| Thai font quality | Many Latin fonts have weak Thai fallback. Prefer fonts with native Thai support (Noto Sans Thai, Sarabun, Athiti, Trirong, Mali) or pair Latin font + dedicated Thai font via `font-family` stack |
| Vertical rhythm | Thai script taller than Latin x-height. Adjust line-height +0.1 on Thai-only pages if needed |
| Mixed-script lines | Test mixed TH+EN sentences for vertical alignment. Some fonts mis-align by 2-3px. |
| Number rendering | Thai numerals (๑๒๓) vs Arabic (123) — default to Arabic unless brand voice calls for Thai |

---

## 8. Anti-Patterns

- ❌ Don't use raw font-family in CSS — always reference tokens
- ❌ Don't mix more than 2 typefaces on a single page (display + body — that's it)
- ❌ Don't use more than 4 sizes in single viewport (scale collapses into noise)
- ❌ Don't underline body text for emphasis — use weight (semibold) instead
- ❌ Don't justify text alignment (Thai + Latin mix wraps poorly with justify)
- ❌ Don't use display font for body text (legibility tank)

---

## Cross-references

- `design/tokens/core.tokens.json` — typography primitives
- `design/tokens/semantic.tokens.json` — semantic type roles
- `design/brand-foundation/color-system.md` — pairs with typography for full text system
- `strategy/messaging.md` (brand voice ID) — informs type choices
- DNA Graph Field 6 — Brand Personality
