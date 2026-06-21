# Heading & Document-Semantics Conformance — {Brand Name} (`{brand-slug}`)

> **Applies to: EVERY EYWA brand, both stacks** (WordPress + Elementor Pro · Astro). Not stack-scoped — unlike `r2-media`, every brand fills this.
> **Canonical spec (normative — do NOT restate the rules here):** EYWA Bible **§9.9** (Heading Hierarchy & Document-Semantics Standard) + DECISION_RECORDS → **DR-041** (Universal, WCAG 2.2 AA). This file is **this brand's adoption record + per-release conformance evidence + deviations log** — it *points at* §9.9, it does not replace it.
> Fill the `{placeholders}`, tick the boxes, then rename to `heading-semantics-conformance.md`. **Documentation / conformance-only — no schema work here.**
>
> **▶ How to adopt (3 steps):** (1) confirm `brand-config.json` → `eywa_spec_snapshot` lists **DR-041** (bumped to Bible v3.34 / DR v1.27); (2) fill **§A** with this brand's real components/widgets; (3) run **§B** every release and log any brand-choice deviation in **§C**. The full rules + rationale live in **Bible §9.9** — read it once, then this file is your per-release checklist.

## 0. The one rule (reminder — full contract in Bible §9.9)

> Headings describe the structure of the **content**, not of everything on the page. Real headings (`<h1>`–`<h6>`) live **only inside `<main>`**; `<header>`/`<footer>` carry **zero headings** (banner / contentinfo landmarks); injected promos are **`<aside aria-label>`** with a non-heading `<p>` headline.

```
<header> → 0 headings    <main> → H1 → H2 → H3 → H4 (no skips)    <aside> → 0    <footer> → 0
```

## A. Brand component → element/level inventory

Map **this brand's actual components / Elementor widgets / Astro components** onto the §9.9.6 block roles. Put the real component/widget name (and the heading level it emits) in the third column, then confirm it matches the required element/level.

| EYWA block role (§9.9.6) | Required markup | This brand renders it as | ✅ conforms? |
|---|---|---|---|
| Hero (page title) | `<h1>` × 1 | `{component / widget}` | ☐ |
| Top-level section wrapper | `<h2>` | `{…}` | ☐ |
| References / E-E-A-T | `<h2>` | `{…}` | ☐ |
| FAQ / Related / News-Why-Now / Final CTA | `<h2>` | `{…}` | ☐ |
| Treatment / procedure option titles | `<h3>` | `{…}` | ☐ |
| Card titles (service / branch / pillar) | `<h3>` | `{…}` | ☐ |
| Nested box → its items | `<h3>` → `<h4>` (never `h3→h5`) | `{…}` | ☐ |
| Injected promo / ad | `<aside aria-label>` + `<p>` headline | `{…}` | ☐ |
| Inline CTA band | `<p>` (not a heading) | `{…}` | ☐ |
| Sticky CTA (§9.3) | complementary landmark; label **not** a heading | `{…}` | ☐ |
| Header mega-menu label | `<div>` / `<button>` (control, not heading) | `{…}` | ☐ |
| Footer column labels | `<p>` inside `<nav aria-label> + <ul>`; contact = `<address>` | `{…}` | ☐ |

> If a row can't conform without a **shared-component** change, fix it at the component level (the §9.9 thesis) — don't patch page-by-page.

## B. Per-release verification (run EVERY release — §9.9.10)

| Check | Tool | Result | Date | By |
|---|---|---|---|---|
| `page-has-heading-one` | axe | ☐ pass | {YYYY-MM-DD} | {name} |
| `empty-heading` | axe | ☐ pass | | |
| `heading-order` (no skips) | axe | ☐ pass | | |
| Outline scan: 1× H1, no skips, `<header>`/`<footer>` 0 headings | §9.9.10 script vs `dist/` (Astro) or rendered-HTML crawl (WP) | ☐ pass | | |
| Headings rotor = hero-H1 + content H2/H3 only | screen reader | ☐ pass | | |
| Landmarks rotor = banner / main / contentinfo (+ a *named, distinct* complementary per live promo) | screen reader | ☐ pass | | |
| Lighthouse accessibility ≥ 90 (§9.7.5 gate) | Lighthouse CI | ☐ ≥90 | | |

> Outline-scan script: copy the JS block from Bible §9.9.10 and point `base` at this brand's built routes.

## C. Deviations log (brand-choice tier ONLY — §9.9.8)

Only the **"genuine brand choice"** tier may deviate (e.g. footer carries `<h2>` columns GOV.UK-style; promo disclosure wording "Advertisement" vs "Special promotion"). Each deviation needs a **brand-level DR**. The *hard-rule* and *house-style* tiers are **not** deviable here.

| Deviation | §9.9.8 brand-choice it touches | Brand DR | Rationale |
|---|---|---|---|
| _none by default_ | | | |

## D. Sign-off

- **Release / site version:** {…}
- **Conformance reviewed by:** {name} · **Date:** {YYYY-MM-DD}
- **Canonical spec pinned:** Bible §9.9 / DR-041 (see `eywa_spec_snapshot` in `brand-config.json`)
