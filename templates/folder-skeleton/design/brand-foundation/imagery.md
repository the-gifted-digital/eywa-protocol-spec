# Imagery — {Brand Name}

> **Per DR-029 + Bible Part 31.** Photography style + illustration guidelines + brand image use rules.

---

## 1. Photography Style

### Tone

> {What does brand photography feel like? Connect to DNA Graph Field 4 — Emotional Benefits.}

Example: "Calm authority. Natural light dominant. Real patients (consented) over stock. Faces showing relief and trust, never fear. No clinical-cold imagery."

### Composition rules

| Rule | Example |
|------|---------|
| Subject placement | Rule-of-thirds preferred, dead-center for portraits with intentional eye contact |
| Background | Soft-focus or solid-neutral — no clutter |
| Color grading | {warm vs cool / saturation level / contrast — per brand voice} |
| People | {smiling vs neutral / direct gaze vs candid} |
| Hands | Visible and active (signals expertise + care in medical context) |
| Equipment | Background only — never product hero (per brand-voice "service-first, device-second" if applicable) |

### Where to source

- **Brand photoshoot (preferred)** — `brand-assets/photography/raw/`
- **Stock (interim)** — Unsplash, Pexels with brand-fitting collections — note in commit which used
- **AI-generated (case-by-case)** — disclose per Bible Part 23 (transparency); avoid for patient-facing trust content

### Patient consent + PDPA

- All photos of identifiable individuals require signed consent (PDPA + medical advertising law)
- Before/after photos require explicit before/after consent + anonymization where applicable
- Internal staff photos OK with employment consent

---

## 2. Illustration Style

### When to use illustration vs photo

| Use case | Illustration | Photo |
|----------|--------------|-------|
| Abstract concepts (methodology, framework) | ✅ Preferred | Generic stock won't fit |
| People interactions (patient + doctor) | Often ✅ | Stock can feel canned |
| Equipment/technology | ✅ Hero shot OK | Real equipment if owned + branded |
| Editorial / blog hero | Either | Either |

### Illustration style guide

| Property | Value |
|----------|-------|
| Style | TBD (flat / line / isometric / hand-drawn / spot illustration) |
| Color palette | References `design/tokens/core.tokens.json` brand-primary + accent |
| Line weight | Consistent (e.g., 2px) |
| Character design | Inclusive (skin tones, body types, age ranges, abilities) |
| Source | `brand-assets/illustrations/raw/` |
| Format | SVG preferred (scalable), PNG fallback |

### Brand-specific illustrations

> {Diagrams that visualize proprietary frameworks. Examples:}

- Relaxia 3 Pillars diagram (`brand-assets/illustrations/3-pillars-hero.svg`)
- MID Workflow 5-phase diagram
- Patient Journey 6-step diagram

---

## 3. Image Specifications

### Hero images

| Property | Value |
|----------|-------|
| Desktop hero | 1920×1080 (16:9) or 2400×1350 (16:9 retina) |
| Mobile hero | 750×1334 (9:16) or larger square crop |
| Format | WebP primary, JPG fallback |
| Compression | 80-85% quality |
| File size budget | <200KB after compression |
| LCP target | <2.5s per Bible Part 19 CWV |

### Card / thumbnail images

| Property | Value |
|----------|-------|
| Default ratio | 4:3 or 1:1 |
| Size | 800×600 or 800×800 |
| File size | <80KB |

### Service / Technology images

| Property | Value |
|----------|-------|
| Ratio | Square or 4:3 |
| Background | Solid neutral or branded subtle gradient |
| Subject | Center-weighted, padding around equipment shots |

---

## 4. Image Tokens (motion + treatment)

| Token | Value | Use case |
|-------|-------|----------|
| Image border-radius default | `{radius.md}` | Cards, inline content |
| Image border-radius hero | `{radius.none}` or `{radius.lg}` | Full-bleed or large feature |
| Image shadow | `{card.shadow-default}` | Floating photo cards |
| Image hover effect | Subtle scale 1.02 + shadow upgrade | Interactive image cards |

---

## 5. File Organization

```
brand-assets/photography/
├── raw/                     ← Originals from photoshoot (RAW, high-res)
├── processed/               ← Web-ready (resized, color-corrected, compressed)
├── consent-records/         ← PDPA consent forms (PRIVATE — gitignored)
└── shoot-log.md             ← Notes on each shoot — date, photographer, subjects, usage rights

brand-assets/illustrations/
├── raw/                     ← Source files (Illustrator, Figma, etc.)
├── processed/               ← Web-ready SVG + PNG fallback
└── diagrams/                ← Proprietary methodology diagrams (3-pillars, journey maps, etc.)
```

---

## 6. Imagery Anti-Patterns

- ❌ Cliché stock photos (handshake, smiling-at-laptop, finger-pointing-at-graph)
- ❌ Equipment hero shots when service is the value (per brand voice "service-first")
- ❌ Color-tinted photos that drift from brand palette (over-treated images)
- ❌ Images without alt text (WCAG fail + AI doesn't understand visual content)
- ❌ Images >1MB (CWV LCP fail, mobile data unfriendly)
- ❌ Patient photos without explicit consent (PDPA + medical law violation)
- ❌ Before/after photos in marketing without anonymization protocol

---

## Cross-references

- `brand-assets/photography/` — raw + processed photo files
- `brand-assets/illustrations/` — illustration source + processed files
- `design/brand-foundation/color-system.md` — color treatment of images aligns with palette
- Bible Part 9 — WCAG accessibility (alt text mandatory)
- Bible Part 19 — Core Web Vitals (image performance)
- Bible Part 23 — Medical Content Excellence (PDPA + consent)
- DNA Graph Field 4 — Emotional Benefits (informs photo direction)
- DNA Graph Field 10 — Compliance Boundaries (consent + anonymization rules)
