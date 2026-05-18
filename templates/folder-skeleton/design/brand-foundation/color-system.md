# Color System — {Brand Name}

> **Per DR-029 + Bible Part 31.** Color palette rationale + semantic mapping + WCAG contrast verification.
> **Token source:** `design/tokens/core.tokens.json` (primitives) + `design/tokens/semantic.tokens.json` (role mapping) + `design/tokens/brand.tokens.json` (brand-unique).

---

## 1. Palette Philosophy

> {Why this palette? What does it say about the brand? Connect to DNA Graph Field 6 — Brand Personality.}

Example: "Quietly confident. Calm by design. Premium without ostentation. Cool neutrals dominate; brand accent appears <5% of surface area for maximum impact."

---

## 2. Primary Brand Color

| Property | Value | Rationale |
|----------|-------|-----------|
| Hex | `#TBD` | {why this specific color — psychology / association / differentiation} |
| RGB | TBD | |
| Token | `{color.brand-primary.500}` | |
| Usage | Primary CTA buttons, key accents, hero focal points | |
| % of surface | <15% of any page | Apple-restraint discipline |

### Shade scale (10-step, 50-900)

| Token | Hex | Use case |
|-------|-----|----------|
| `brand-primary.50` | `#TBD` | Hover tint backgrounds, subtle highlights |
| `brand-primary.500` | `#TBD` | Main brand color — most usage |
| `brand-primary.900` | `#TBD` | Hover state, deep accent, text on light bg |

---

## 3. Accent Color (Secondary)

| Property | Value |
|----------|-------|
| Hex | `#TBD` |
| Token | `{color.brand-accent.500}` |
| Usage | Links, secondary CTAs, highlight badges |

---

## 4. Neutral Palette

12-step grey scale (per core.tokens.json `color.neutral.*`).

| Token | Hex | Use case |
|-------|-----|----------|
| `neutral.0` | `#FFFFFF` | Page background, card surfaces |
| `neutral.50` | `#TBD` | Subtle section backgrounds |
| `neutral.500` | `#TBD` | Secondary text, captions |
| `neutral.900` | `#TBD` | Body text default |
| `neutral.1000` | `#000000` | Reserved — rarely used pure black |

---

## 5. Brand-Unique Colors (if any)

> {e.g., pillar colors for multi-pillar brand like Relaxia 3-pillar. Reference `design/tokens/brand.tokens.json`}

| Token | Hex | Meaning |
|-------|-----|---------|
| `pillar-1` | `#TBD` | {pillar 1 identity color} |
| `pillar-2` | `#TBD` | {pillar 2 identity color} |
| `pillar-3` | `#TBD` | {pillar 3 identity color} |

---

## 6. Semantic Mapping (per semantic.tokens.json)

| Role | Token reference | When to use |
|------|----------------|-------------|
| Text primary | `{color.text.primary}` → `{color.neutral.900}` | Body text default |
| Text secondary | `{color.text.secondary}` → `{color.neutral.500}` | Captions, meta info |
| Surface page | `{color.surface.page}` → `{color.neutral.0}` | Page background |
| Surface card | `{color.surface.card}` → `{color.neutral.0}` | Card/panel default |
| Border subtle | `{color.border.subtle}` → `{color.neutral.100}` | Default card borders |
| Action primary | `{color.action.primary.default}` → `{color.brand-primary.500}` | CTAs |
| Action primary hover | `{color.action.primary.hover}` → `{color.brand-primary.900}` | CTA hover state |

---

## 7. WCAG 2.1 AA Contrast Verification

Per Bible Part 9 — all brand sites must achieve WCAG AA minimum.

| Text/Background pair | Token combo | Contrast ratio | AA pass? |
|----------------------|------------|---------------|----------|
| Body text on page | `{color.text.primary}` on `{color.surface.page}` | TBD | TBD |
| Button text on primary | `{color.action.primary.text}` on `{color.action.primary.default}` | TBD | TBD |
| Caption on page | `{color.text.secondary}` on `{color.surface.page}` | TBD | TBD |
| Link on page | `{color.text.link}` on `{color.surface.page}` | TBD | TBD |

**Tool:** Use https://webaim.org/resources/contrastchecker/ to verify each pair.

---

## 8. Color Anti-Patterns

- ❌ Never use raw hex in CSS/templates — always reference tokens
- ❌ Brand-primary > 15% of any page surface (overuse weakens impact)
- ❌ Pure black (`neutral.1000`) for body text — use `neutral.900` (softer, premium)
- ❌ Red/danger color for non-error UI (don't use semantic-utility colors decoratively)
- ❌ More than 3 brand-unique pillar colors in one viewport (visual overload)

---

## Cross-references

- `design/tokens/core.tokens.json` — palette primitives
- `design/tokens/semantic.tokens.json` — role mappings
- `design/tokens/brand.tokens.json` — brand-unique additions
- `design/brand-foundation/typography.md` — typography pairs with color for full text system
- Bible Part 9 — WCAG AA requirement
- DNA Graph Field 6 — Brand Personality (informs color choice)
