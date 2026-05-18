# Iconography — {Brand Name}

> **Per DR-029 + Bible Part 31.** Icon style, library choice, usage rules.

---

## 1. Icon Library Selection

### Primary library

| Property | Value | Rationale |
|----------|-------|-----------|
| Library name | TBD (e.g., Lucide, Heroicons, Phosphor, Tabler) | {why this library — style fit + license + breadth} |
| License | TBD (MIT preferred) | |
| Style | TBD (line / solid / duotone) | Match brand voice |
| Stroke width | TBD (1.5px / 2px) | |
| Default size | 24px × 24px | |
| Color | Inherits from text color (`currentColor`) | |
| Source | URL / package | |

### Special-purpose icons

| Use case | Library / source |
|----------|------------------|
| Medical / clinical | Healthicons, Iconify medical set, custom set |
| Brand logo marks | `brand-assets/logos/` (custom — see brand-assets/) |
| Social media | Lucide / Simple Icons |
| Flags (i18n) | flag-icons npm package |

---

## 2. Style Discipline

| Rule | Why |
|------|-----|
| One style per surface (don't mix line + solid + duotone) | Visual consistency |
| Same stroke width across all icons | Harmonized weight |
| Same corner treatment (rounded vs square) across all icons | Consistent personality |
| 24px default, 16px small, 32px medium, 48px hero | Standardized sizes prevent visual chaos |
| Icons inherit text color via `currentColor` | Tokenized, themeable |

---

## 3. Size & Spacing Conventions

| Context | Icon size | Adjacent spacing |
|---------|-----------|------------------|
| Inline with text | 16px or 1em | 0.5rem gap (`{spacing.2}`) |
| Button icon | 16-20px | 0.5rem gap (`{spacing.2}`) |
| Navigation item | 20-24px | 0.75rem gap (`{spacing.3}`) |
| Feature card | 32-48px | 1rem-2rem margin-bottom (`{spacing.4}`-`{spacing.8}`) |
| Hero illustration | 64-128px | Generous surrounding whitespace |

---

## 4. Accessibility

- **Decorative icons** — `aria-hidden="true"` (don't announce to screen readers)
- **Functional icons** (icon-only buttons) — `aria-label="action description"` required
- **Icon+text buttons** — icon is decorative, label is the announced text
- **Minimum tap target** — 44×44px for interactive icons (per WCAG 2.5.5)

---

## 5. Brand-Specific Icon Conventions

> {If brand has specific icons that represent proprietary concepts, document here.}

Example — Relaxia 3 pillars:
| Pillar | Icon | Use case |
|--------|------|----------|
| Calm by Design | 🌿 (or custom leaf icon) | Pillar 1 visual marker |
| Smaller by Technology | (custom precision/microscope icon) | Pillar 2 visual marker |
| Sleep when Needed | 🌙 (or custom moon icon) | Pillar 3 visual marker |

---

## 6. Icon Anti-Patterns

- ❌ Mixing icon libraries on one page (style clash)
- ❌ Random sizes (15px next to 23px next to 31px)
- ❌ Decorative icons without `aria-hidden`
- ❌ Functional icons without `aria-label`
- ❌ Using emoji as primary icons in production (inconsistent rendering across OS)
- ❌ Color-coding icons by category without text label (color-blind users miss the signal)

---

## Cross-references

- `brand-assets/icons/` — custom-drawn icon files (SVG)
- `design/brand-foundation/color-system.md` — icon color via `currentColor` inheritance
- Bible Part 9 — WCAG AA accessibility requirements
