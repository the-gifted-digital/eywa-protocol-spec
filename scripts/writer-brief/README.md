# Writer brief — `page-brief.mjs`

Generates a Thai-language "writer's brief" (ใบสั่งงาน) for ONE page, straight from the shared
Supabase database. Brand-agnostic port of `eywa-vth-biodent/web/scripts/page-brief.mjs` — see
"What differs from the VTH original" below for the exact delta.

Read-only. Never writes to the database. The page YAML is still authored by hand.

## Running it

```bash
cd <brand>/web    # so the script can see src/lib/template-keys.ts + layouts for the render report
node ../../eywa-protocol-spec/scripts/writer-brief/page-brief.mjs --brand <brand_id> <target> [--write] [--web <path>] [--out <dir>]
```

- `--brand <brand_id>` (required) — `smile-scape-clinic` · `vth-biodent` · `deezy-dental` (or a future brand's own id)
- `<target>` (required) — resolved in order: `page_fingerprint` (e.g. `vth-6.1.3`) → `slug` within the brand → `sitemap_node_id` within the brand
- `--write` — also write `docs/briefs/<slug>.md` under the brand repo root (parent of the resolved `web/`), or under `--out` if given
- `--web <path>` — the brand's `web/` directory. If omitted, the script walks up from `process.cwd()` looking for a directory containing `web/src/lib/template-keys.ts`, or that is itself such a `web/`. Not found → the render report ("block ที่ layout ไม่ render") and the brand-npm-scripts half of the gates section are skipped, with a flag saying so.
- `--out <dir>` — write directly into `<dir>` instead of `docs/briefs/`

Credential lookup (same order as `scripts/citation-gates/eywa_supabase.py`'s `key()`):
1. `SUPABASE_SERVICE_KEY` in the environment
2. `EYWA_SECRETS_ENV` pointing at a file holding `SUPABASE_SERVICE_KEY=...`
3. `.secrets/supabase.env`, walking up from the working directory

Zero npm dependencies — plain `fetch` against PostgREST
(`https://lffcbeszjqzioobqfdav.supabase.co/rest/v1/`). That's the whole reason this lives here as
its own file rather than an import: this repo has no `node_modules`, and the VTH original's
`@supabase/supabase-js` import can't run from it.

## Brand config (`brands/<brand_id>.json`)

All keys optional. Missing file = every default applies.

| key | type | default | meaning |
|---|---|---|---|
| `keyword_fp_prefix` | string | derived — `<brand_name lowercased>::🇹🇭 th – thailand::🇹🇭 th – thai::` | fallback keyword-fingerprint prefix, used only by the "no target keyword yet" flag, and only when the page itself has no `target_keyword_fp` to derive the prefix from |
| `local_sections` | string (regex source) | none — B11 vetoes `ใกล้ฉัน` everywhere | `page_fingerprint` pattern for B11's "near-me is allowed here" carve-out, e.g. `^vth-9` or `^smilescape-(8\|9)\.` |
| `forbidden_topics` | array of `{ pattern, why }` | `[]` | operator prohibitions — `pattern` is a case-insensitive regex checked against `page_name`, `seo_title`, `meta_description`, the target keyword, and related-entity names; a hit raises a 🔴 flag |
| `docs.sop` / `docs.blocks` | string | `docs/CONTENT-WRITING-SOP.md` / `docs/template-block-standards.md` | paths shown in the header line only — existence is never checked |

Current brands:
- `smile-scape-clinic.json` — `local_sections` for §8/§9, plus the two operator prohibitions in force since 2026-09-17 (บัตรทอง/สปสช/ราชการ · ลดหย่อนภาษี)
- `vth-biodent.json` — `local_sections: "^vth-9"`
- `deezy-dental.json` — `{}` (no exceptions configured yet — B11 currently vetoes `ใกล้ฉัน` everywhere for this brand until an operator adds `local_sections`)

A brand with no config file at all still runs, with every default above applying.

## What the sections mean

1. **Header + 🛑 veto block** — fires when the target keyword hits one of six rules (B1, B3, B6,
   B9, B10, B11 — numbering follows `keyword-assignment-sop.md` §4, which is not contiguous). B11
   is the only one with brand-specific behavior (`local_sections`).
2. **ธงที่ต้องอ่านก่อน** — every reason to stop and think, computed once so nobody has to remember
   to check it by hand: forbidden-topic hits, missing/near-me keywords, SERP/proxy state, entity
   summary and child-table material, inbound-link and anchor-drift counts, the render report,
   compliance flags, and the calibration markers below (`CITATION EXEMPTION`, `ENTITY GAP`,
   `[no-target:`, `intent_source_tier=brand`).
3. **คำสั่งจากรอบ calibrate** — `reconciliation_notes` filtered down to the markers that change
   what gets written (split on both `" | "` and newlines — real data uses both).
4. **หน้าที่จะเขียน** — the page's own metadata block: where its file goes, what `funnel:` value
   the template expects, plus `page_category`/`page_role`/`content_topic_tier`/
   `intent_source_tier`/`parent_page_fp`/`canonical_url`.
5. **baseline title/meta** — what's in the DB right now, before this writing pass.
6. **keyword + SERP** — the target keyword's SERP snapshot (or a semantic-keyword proxy when
   there's none), plus the page's other semantic keywords resolved to their actual keyword text.
7. **entity** — the primary entity's summary and populated child-table fields, plus related
   entities resolved to names.
8. **citation ที่ผูกไว้** — the citation pool bound to this page, and — the most load-bearing
   addition — each one's `supports_claim` in full: the verified boundary of what the page is
   allowed to say on that citation's authority.
9. **internal links** — inbound/outbound counts and anchor drift, plus a table of the planned
   *contextual* outbound links (to node/slug, anchor, variant, section) and the distinct inbound
   anchors (any link type) already pointing here.
10. **block ที่ layout ไม่ render** — which `baseFields` the resolved template's `.astro` layout
    silently drops (Zod accepts them; the layout may not render them). Skipped when `web/` isn't
    known, or when the page's `content_format` has no row in that brand's `template-keys.ts`.
11. **เกตที่ต้องรัน** — the three protocol-level citation gates every brand runs (path printed
    relative to the brand repo root when possible, absolute otherwise), then the brand's own npm
    scripts — but only the ones that actually exist in that brand's `web/package.json`.
12. **Closing line** — what to write back to the DB once the page ships.

## What differs from the VTH original

The VTH original (`eywa-vth-biodent/web/scripts/page-brief.mjs`) hardcoded
`BRAND_ID = 'vth-biodent'`, an `ilike('brand', '%VTH%')` SERP filter, B11's `^vth-9` carve-out, and
depended on `@supabase/supabase-js`. This port:

- Takes `--brand <brand_id>` and resolves everything brand-specific from the resolved page row
  (`brand_name`, used for an *exact* SERP filter — never `ilike`, which matches other brands too,
  e.g. `%smile%` on "TC Smile Dental") or from `brands/<brand_id>.json`.
- Resolves the target by `page_fingerprint`, `slug`, **or `sitemap_node_id`** (VTH only had the
  first two).
- Uses plain `fetch` against PostgREST instead of `@supabase/supabase-js` — this repo has no
  `node_modules`.
- Adds every section/column listed under "What the sections mean" above that wasn't in the VTH
  original: `supports_claim`/`citation_purpose` per citation, the contextual-outbound-links table
  and inbound-anchor tally, semantic-keyword and related-entity name resolution,
  `page_category`/`page_role`/`content_topic_tier`/`intent_source_tier`/`parent_page_fp`/
  `canonical_url`, the forbidden-topics flag, and the `CITATION EXEMPTION`/`ENTITY GAP`/
  `[no-target:` calibration markers.
- Fixes an entity lookup that only surfaced once three brands' data was compared side by side:
  `seo_entity_graph` is now looked up by `entity_fingerprint`, not `entity_slug` (equal for all
  but 2 rows across the shared tables, per the 2026-09-17 data check).
- Treats `flag_review` as a comma list (`.split(',')`) rather than testing equality — real rows
  carry multiple values (e.g. `"sso-2569-update,sso-verified-2569"`).
- Gates the brand-npm-scripts half of "เกตที่ต้องรัน" on what actually exists in that brand's
  `web/package.json` — VTH's `scripts` happen to include all of `scan:headings`/`check:links`/
  `check:density`/`gen:links`, but smile-scape's `content-templates` branch currently has none of
  them, so those lines are omitted instead of printing a command that would just fail.
- Drops every VTH-internal SOP section-number citation (`§3.3`, `§2.5`, `§2.6`, `§4.6.1`, `A.7`)
  from the carried-over flag/guidance text, since those numbers refer to VTH's own
  `CONTENT-WRITING-SOP.md` and would misdirect a writer on a brand whose SOP is numbered
  differently — or, for smile-scape today, doesn't exist at that path yet. The
  `keyword-assignment-sop.md` §4 reference in the veto block is kept, since B1–B11 and that
  section number are the one thing the brief requires to stay identical across brands.
- Everything else — tone, section order, the six B-rules, the `filled()`/`yn()` semantics, the
  calibration-note markers, the render-report logic — is unchanged.
