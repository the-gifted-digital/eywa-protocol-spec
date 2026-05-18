# Spacing & Layout — {Brand Name}

> **Per DR-029 + Bible Part 31.** Spacing scale, layout grid, breakpoints.
> **Token source:** `design/tokens/core.tokens.json` (`spacing.*` + `breakpoint.*` + `radius.*`)

---

## 1. Base Unit

**4px** — every spacing token is a multiple of 4. Aligns with industry standard (Material, Tailwind, Apple HIG, Figma defaults).

---

## 2. Spacing Scale

| Token | rem | px | Common use |
|-------|-----|-----|----------|
| `spacing.0` | 0 | 0 | Reset |
| `spacing.1` | 0.25rem | 4px | Icon-text gap, tight inline |
| `spacing.2` | 0.5rem | 8px | Form label spacing, inline padding |
| `spacing.3` | 0.75rem | 12px | Button vertical padding, small gaps |
| `spacing.4` | 1rem | 16px | Default block padding, paragraph spacing |
| `spacing.6` | 1.5rem | 24px | Card padding, section internal spacing |
| `spacing.8` | 2rem | 32px | Subsection breaks |
| `spacing.12` | 3rem | 48px | Large component spacing |
| `spacing.16` | 4rem | 64px | Section padding (mobile) |
| `spacing.20` | 5rem | 80px | Major section breaks |
| `spacing.24` | 6rem | 96px | Hero padding |
| `spacing.32` | 8rem | 128px | Section padding (desktop) |

---

## 3. Layout Grid

### Container max-widths

| Context | Max-width | Token | When to use |
|---------|-----------|-------|-------------|
| Long-form text | 65ch | `{layout.container-max-width.content}` | Article body, knowledge content |
| Narrow | 640px | `{layout.container-max-width.narrow}` | Forms, focused content |
| Normal | 1024px | `{layout.container-max-width.normal}` | Standard pages |
| Wide | 1280px | `{layout.container-max-width.wide}` | Marketing pages, hero sections |
| Full | 100% | — | Background fills, full-bleed images |

### Column system

> Recommended: 12-column grid with gutter = `{spacing.6}` (24px) on desktop, `{spacing.4}` (16px) on mobile.

| Breakpoint | Columns | Gutter | Margin |
|-----------|---------|--------|--------|
| Mobile (<640px) | 4 | `{spacing.4}` 16px | `{spacing.4}` 16px |
| Tablet (768-1024px) | 8 | `{spacing.6}` 24px | `{spacing.8}` 32px |
| Desktop (1024px+) | 12 | `{spacing.6}` 24px | `{spacing.8}` 32px or auto |

---

## 4. Responsive Breakpoints

Per `design/tokens/core.tokens.json` `breakpoint.*`:

| Token | Value | Targets |
|-------|-------|---------|
| `breakpoint.sm` | 640px | Small phones landscape, large phones |
| `breakpoint.md` | 768px | Tablets portrait |
| `breakpoint.lg` | 1024px | Tablets landscape, small laptops |
| `breakpoint.xl` | 1280px | Standard desktop |
| `breakpoint.2xl` | 1536px | Large desktop |

**Mobile-first principle:** Default styles apply to mobile (<640px). Override via `min-width` media queries at breakpoints above.

---

## 5. Section Padding (Vertical Rhythm)

| Context | Mobile | Desktop | Tokens |
|---------|--------|---------|--------|
| Hero section | 64-96px | 96-128px | `{spacing.16}` → `{spacing.24}` → `{spacing.32}` |
| Standard section | 48-64px | 80-96px | `{spacing.12}` → `{spacing.16}` → `{spacing.20}` |
| Tight section (CTA) | 32-48px | 48-64px | `{spacing.8}` → `{spacing.12}` → `{spacing.16}` |

Semantic shortcuts in `semantic.tokens.json`:
- `layout.section-padding-y.mobile` → `{spacing.16}` (64px)
- `layout.section-padding-y.desktop` → `{spacing.32}` (128px)

---

## 6. Component-Level Spacing

Per `design/tokens/component.tokens.json`:

| Component | Padding | Token |
|-----------|---------|-------|
| Button (default) | 24px × 12px | `button.primary.padding-x` × `padding-y` |
| Card (default) | 24px all sides | `card.padding` |
| Input field | 16px × 12px | `input.padding-x` × `padding-y` |

---

## 7. Border Radius (Corner Treatment)

Per `design/tokens/core.tokens.json` `radius.*`:

| Token | Value | Use case |
|-------|-------|----------|
| `radius.none` | 0 | Sharp corners — premium/editorial feel |
| `radius.sm` | 0.25rem (4px) | Subtle softening |
| `radius.md` | 0.5rem (8px) | Buttons, inputs, default cards |
| `radius.lg` | 1rem (16px) | Larger cards, modals, hero cards |
| `radius.full` | 9999px | Pills, avatars, circular badges |

**Brand voice consideration:**
- Conservative/medical brands → `radius.sm` or `radius.md` (trust + restraint)
- Modern/tech brands → `radius.md` or `radius.lg` (friendly + approachable)
- Editorial/premium → `radius.none` or `radius.sm` (sharp, intentional)

---

## 8. Anti-Patterns

- ❌ Don't use raw pixel values in CSS — always reference spacing tokens
- ❌ Don't break the 4px base unit (no 5px, 7px, 13px spacing)
- ❌ Don't use more than 4 distinct radius values across the site (visual chaos)
- ❌ Don't ignore mobile padding — many designs over-pad mobile causing single-column claustrophobia
- ❌ Don't justify-content: center for large blocks of text (mobile readability tanks)
- ❌ Don't fix max-width at exact px on long-form (use 65ch for readability optimum)

---

## Cross-references

- `design/tokens/core.tokens.json` — spacing + breakpoint + radius primitives
- `design/tokens/semantic.tokens.json` — semantic spacing roles
- `design/tokens/component.tokens.json` — component-level spacing
- Bible Part 9 — Template anatomy (uses these tokens for layout)
- Bible Part 19 — Data Quality / CWV (spacing affects CLS metric)
