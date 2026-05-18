# Motion — {Brand Name}

> **Per DR-029 + Bible Part 31.** Animation principles + duration/easing tokens + accessibility considerations.

---

## 1. Motion Philosophy

> {How should the brand feel in motion? Connect to DNA Graph Field 6 — Brand Personality.}

Example: "Subtle by default. Apple-restraint discipline — motion exists to support understanding, not entertain. No bouncing. No spinning hero text. Animations confirm action (button press, page transition) rather than decorate."

---

## 2. Duration & Easing Tokens

### Duration

| Token | Value | Use case |
|-------|-------|----------|
| `motion.duration.fast` | 100ms | Hover state changes, focus rings |
| `motion.duration.normal` | 200ms | Button press feedback, modal fade |
| `motion.duration.slow` | 400ms | Page transitions, larger element animations |
| `motion.duration.ultra-slow` | 800ms | Hero parallax, scroll-triggered reveals (use sparingly) |

### Easing

| Token | Cubic-bezier | Use case |
|-------|-------------|----------|
| `motion.ease.out` | `cubic-bezier(0.16, 1, 0.3, 1)` | Default for entering elements (fast start, slow end) |
| `motion.ease.in-out` | `cubic-bezier(0.65, 0, 0.35, 1)` | Symmetric motion (toggles, expand/collapse) |
| `motion.ease.linear` | `linear` | Progress bars, scroll indicators |

---

## 3. When to Use Motion

| Context | Motion type | Duration | Easing |
|---------|------------|----------|--------|
| Button hover | Background color fade | fast (100ms) | ease.out |
| Button press | Scale 0.98 + color shift | fast (100ms) | ease.out |
| Form field focus | Border color + shadow | fast (100ms) | ease.out |
| Modal open | Fade + slight scale-up | normal (200ms) | ease.out |
| Card hover | Subtle lift (shadow upgrade + 1-2px translateY) | normal (200ms) | ease.out |
| Page transition | Fade between routes | normal (200ms) | ease.out |
| Scroll reveal | Fade-up on entering viewport | slow (400ms) | ease.out |
| Toast/notification | Slide in + fade | normal (200ms) | ease.out |

---

## 4. Motion Restraint Rules

- **No looping animations** in primary content area (distracting, accessibility-hostile)
- **No autoplay video** with audio (annoying + autoplay-block by browsers)
- **No bouncy/spring animations** unless brand explicitly calls for playfulness
- **No motion on body text** (text in motion = hard to read)
- **No parallax on mobile** (battery drain + motion-sickness risk)

---

## 5. Accessibility — `prefers-reduced-motion`

**Mandatory:** All motion must respect `prefers-reduced-motion: reduce` media query.

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

When `reduce` is set:
- Disable all decorative motion
- Keep functional motion (button press feedback, focus rings) at minimum duration
- Replace fade transitions with instant state change
- Disable parallax / scroll-triggered reveals entirely

---

## 6. Tooling

| Stack | Motion library |
|-------|----------------|
| Astro / Vanilla CSS | CSS transitions + Web Animations API |
| Astro + React island | Framer Motion (only if complex orchestration needed) |
| WordPress + Elementor | Elementor built-in motion effects + custom CSS |

**Default preference:** CSS transitions first. JS animations only when CSS can't express the motion.

---

## 7. Brand-Specific Motion Patterns

> {If brand has signature motion that expresses identity, document here.}

Example for Relaxia (Fear-Free Dentistry):
- **Pillar reveal animation:** When 3 pillars appear on scroll, fade-up sequentially (200ms stagger between pillars 1→2→3). Reinforces escalation logic visually.
- **No anxiety-triggering motion:** No sudden flashes, no jarring transitions, no high-contrast pulsing. Brand promise is calm — motion must reflect that.

---

## 8. Motion Anti-Patterns

- ❌ Motion without `prefers-reduced-motion` fallback (WCAG fail + nausea risk)
- ❌ Hover effects that hide critical information (mobile users can't hover)
- ❌ Multiple competing animations in single viewport (attention thrashing)
- ❌ Motion duration >500ms for UI feedback (feels laggy)
- ❌ Bouncy easing on professional/medical brand (mood mismatch)
- ❌ Auto-cycling carousels (users miss content, accessibility issues)

---

## Cross-references

- `design/tokens/core.tokens.json` — `motion.*` duration + easing primitives
- `design/component-specs/` — per-component motion specs
- Bible Part 9 — WCAG AA accessibility (`prefers-reduced-motion` mandatory)
- Bible Part 19 — Core Web Vitals (motion affects INP metric)
- DNA Graph Field 6 — Brand Personality (informs motion character)
