# R2 Media — {Brand Name} (`{brand-slug}`)

> **Stack:** Astro / Cloudflare brands **only** (per DR-EYWA-MKT-005). **WordPress brands skip this file** — WP serves its own media (DR-035 legacy path).
> **Canonical spec:** EYWA Bible **§18.5b** (R2 Media Bucket Governance) + DECISION_RECORDS → **DR-040** (per-brand isolation) · **DR-035** (R2 storage decision) · **DR-038** (`seo_media_assets` DAM table + per-brand Cloudflare routing).
> Fill the `{placeholders}`, then rename to `r2-media.md`. **Convention-only — no schema work here.**

## Bucket

- **Bucket name:** `{brand-slug}-media`  ← one bucket = one brand, **never shared across brands** (DR-040)
- **Location hint:** `apac`
- **Cloudflare account:** `{account-email}` → also recorded in Supabase `brands.cloudflare_account_email`; set `brands.cloudflare_r2_bucket = "{brand-slug}-media"`
- **Hard rule (DR-040):** this brand never reads another brand's bucket. Reusable / stock imagery is **copied in**, not linked across brands. Reasons: SEO (no cross-domain signal dilution) · blast-radius (a delete here can't break another site) · clean handover (sell/hand off = one self-contained bucket).

## Folder structure (archetype → object key, 1:1 with sitemap entities)

```
brand/              logo.png, logo-white.png, favicon.*, og-default.jpg
services/{slug}/     branches/{slug}/     doctors/{slug}/
promos/{YYYY-MM}/    cases/{slug}/         articles/{slug}/     og/
```

## Object-key naming (= `seo_media_assets.r2_object_key`)

- lowercase **kebab-case**, English slug **matching the page/entity slug**
- **no Thai filenames, no spaces**
- prefer **`.webp`**
- optional role suffix: `hero` / `thumb` / `og` / `exterior` / `before-after`
- **never repeat the brand name** in the key (the bucket is already brand-scoped)
- **mutable assets** (promos, etc.) → versioned / dated keys; don't overwrite (edge-cache staleness)

Examples:

```
brand/logo.webp
services/dental-implant/hero.webp
doctors/dr-somchai/portrait.webp
promos/2026-07/songkran-whitening-hero.webp
cases/case-0142/before-after.webp
```

## Delivery

- **Preview:** `https://{hash}.r2.dev/...` — rate-limited, **non-production only**
- **Production:** `https://cdn.{brand-domain}/...` (per-bucket custom domain — the zone must live on the same Cloudflare account) **or** a Worker R2 binding on `/media/*`
- Keep the base URL in **one module** so the r2.dev → cdn cutover is a one-line swap:

```ts
// web/src/lib/media.ts
const R2_BASE = import.meta.env.PUBLIC_R2_BASE ?? "https://{hash}.r2.dev";
export const media = (key: string) => `${R2_BASE}/${key}`;
```

## Pipeline (per DR-038)

The n8n Media-Library sync uploads binaries to `{brand-slug}-media` using the object-key convention above, then writes `r2_bucket` / `r2_object_key` / `cdn_url` back to the `seo_media_assets` row in Supabase. PDPA consent gate applies to patient images (DR-030 / DR-038) — a patient image cannot go `Active` without obtained consent + a use window.
