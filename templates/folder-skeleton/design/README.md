# 🎨 design/ — Universal Brand Design System

> **Per DR-029 + Bible Part 31** — universal stack-agnostic design layer. Whether the brand ships on WordPress + Elementor (per DR-002) or Astro (per DR-EYWA-MKT-005) or any future stack, this folder is identical in structure.
>
> **Audience:** Designers, design-aware operators, devs across any stack.
> **Format standard:** W3C DTCG (Design Tokens Community Group) JSON for `tokens/`.

---

## Folder Map

```
design/
├── README.md                ← this file
├── tokens/                  📐 DESIGN TOKENS — DTCG-compliant JSON (source of truth)
│   ├── core.tokens.json     (primitives — color palette, type scale, spacing scale)
│   ├── semantic.tokens.json (role-based — primary/surface/text/border semantic mappings)
│   ├── component.tokens.json(component-level — button-bg, card-shadow, input-border)
│   └── brand.tokens.json    (brand-unique — pillar colors, signature accents, brand-specific)
│
├── brand-foundation/        📋 Visual identity specs (Markdown — designer-readable)
│   ├── color-system.md      (palette rationale, contrast pairs, semantic mapping, WCAG)
│   ├── typography.md        (typeface choices, scale rationale, voice extension)
│   ├── spacing.md           (spacing scale, layout grid, breakpoints)
│   ├── iconography.md       (icon style, library, usage rules)
│   ├── imagery.md           (photography style, illustration guidelines)
│   └── motion.md            (animation principles + duration/easing tokens)
│
├── component-specs/         📐 Per-component design spec (Markdown — one .md per component)
│   ├── Hero.md
│   ├── CTA.md
│   ├── ServiceCard.md
│   └── ...
│
├── page-templates/          🗺  Page-level layout specs (one .md per page archetype)
│   ├── homepage.md
│   ├── service-page.md
│   └── ...
│
├── wireframes/              🗺  Hand-drawn / lo-fi sketches
│   └── (PNGs, sketch files, or text-based wireframes)
│
└── references/              💡 Mood boards, inspiration, competitor screens
    └── (organize freely per project)
```

---

## Why this exists (and why stack-agnostic)

Brand visual identity does NOT change when the implementation stack changes. The color palette of a clinic is the color palette regardless of whether the site is built with WordPress, Astro, Next.js, or hand-coded HTML.

This folder captures the brand's design specification ONCE. Then each stack-specific implementation in `theme/` (WP+Elementor) or `src/` (Astro) consumes from here. When a brand migrates stacks, this folder doesn't change — only the consumption pipeline changes.

---

## Workflow per stack

### WordPress + Elementor (default per DR-002)

```
1. Designer edits design/tokens/*.tokens.json
   ↓
2. Run sync script: tokens → Elementor global colors/fonts JSON
   ↓
3. Import JSON into Elementor (Site Settings → Import)
   ↓
4. All Elementor templates using global colors/fonts update automatically
   ↓
5. theme/custom-css/ holds any tokens-derived CSS variables not handled by Elementor globals
```

### Astro (when stack is Astro, e.g., eywa-marketing per DR-EYWA-MKT-005)

```
1. Designer edits design/tokens/*.tokens.json
   ↓
2. tailwind.config.mjs auto-imports tokens (Style Dictionary or direct import)
   ↓
3. npm run build → CSS regenerates
   ↓
4. Astro components in src/components/ use Tailwind classes generated from tokens
```

### Figma 2-way sync (when designer uses Figma)

```
1. Tokens Studio plugin in Figma reads design/tokens/*.tokens.json (via GitHub sync)
   ↓
2. Designer changes colors/fonts in Figma using Tokens Studio
   ↓
3. Tokens Studio commits back to design/tokens/ via GitHub API
   ↓
4. Stack-specific pipelines (above) pick up new values
```

---

## DTCG (Design Tokens) format primer

The W3C Design Tokens Community Group spec is the emerging industry standard. Format:

```json
{
  "color": {
    "brand": {
      "primary": {
        "$value": "#1E40AF",
        "$type": "color",
        "$description": "Primary brand color — used on CTAs and key accents"
      }
    }
  },
  "spacing": {
    "4": {
      "$value": "1rem",
      "$type": "dimension"
    }
  }
}
```

**Key rules:**
- Every token has `$value` (mandatory) and `$type` (recommended)
- `$description` field optional but encouraged for non-obvious tokens
- Nest by semantic hierarchy (color > brand > primary, not flat color-brand-primary)
- Reference other tokens via `{path.to.token}` syntax (semantic.tokens.json references core.tokens.json this way)

**Tools that understand DTCG:**
- Figma + Tokens Studio plugin (2-way sync)
- Style Dictionary (transform to CSS/SCSS/JS/Swift/Android)
- W3C tooling
- Any modern design system tool

**Why DTCG over custom formats:** Designers don't need to learn a brand-specific format. Anyone who knows design systems recognizes DTCG immediately. Tools interoperate natively.

---

## File responsibilities

| File | Owner | Update frequency | Consumed by |
|------|-------|------------------|-------------|
| `tokens/core.tokens.json` | Designer (with operator review) | Rare — brand identity locks | All theme implementations |
| `tokens/semantic.tokens.json` | Designer | Rare — semantic mappings stable | Theme + components |
| `tokens/component.tokens.json` | Designer + Dev | Per component additions | Components only |
| `tokens/brand.tokens.json` | Designer | Brand event (pillar add, etc.) | Brand-specific surfaces |
| `brand-foundation/*.md` | Designer (operator drafts) | Phase A.1 + annual review | Reference documentation |
| `component-specs/*.md` | Operator + AI co-author | Per new component | Claude Code (implements per spec) |
| `page-templates/*.md` | Operator | Phase D sitemap planning | Theme implementation |
| `wireframes/*` | Designer/operator | Pre-implementation | Theme implementation |
| `references/*` | Anyone | Capture freely | Decision context |

---

## Cross-references

- **Bible Part 31** — Universal Brand Design System (this folder's spec)
- **DR-029** — Design tokens + design layer locked universal
- **DR-002** — WP+Elementor stack default (consumes from this folder)
- **DR-EYWA-MKT-005** — Astro stack profile (consumes from this folder)
- **BGP Phase A.1** (Bible §30.4) — eywa-dna-graph.md informs brand identity → drives core.tokens.json + brand-foundation/
- **`brand-assets/`** (sibling folder) — raw binary sources (logos, photos, illustrations, icons)
- **`theme/`** (sibling folder) — stack-specific implementation (WP CSS, Elementor templates, Astro components)

---

*Per DR-029 + Bible Part 31 — Universal Brand Design System. Initialized via Bootstrap Kit `templates/folder-skeleton/design/`.*
