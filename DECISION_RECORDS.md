# 📋 EYWA Protocol — Decision Records

> **Append-only architectural decision log.** Each record explains WHY a decision was made — not just WHAT.

**Document Version:** 1.26  
**Last Updated:** 2026-06-14  
**Format:** Reverse chronological (newest first)

---

## Format Template

```markdown
## [DR-NNN] — Title (YYYY-MM-DD)

**Status:** Proposed | Accepted | Locked | Superseded by DR-XXX  
**Bible Reference:** Part X.Y (if applicable)  
**Schema Reference:** v1.X (if applicable)

**Context:** What problem are we solving?

**Decision:** What did we choose?

**Rationale:** Why this option vs alternatives?

**Consequences:** Trade-offs, follow-ups, known limitations.

**References:** Related Bible sections, related DRs, external sources.
```

---

## Decisions Log

### [DR-040] — R2 Media Bucket: Strict Per-Brand Isolation + Object-Key / Folder Naming Convention (Universal) (2026-06-14 → Locked 2026-06-14) 🔒🖼️☁️

**Status:** **🔒 Locked 2026-06-14** — operator-directed ("ฉันจะไม่มีวันข้าม", 2026-06-14), drafted + applied same working session. **Convention-only — no schema migration, no DDL change** (it standardizes *how* R2 objects are named/foldered and *which* bucket holds them; the columns that record this — `seo_media_assets.r2_bucket` / `r2_object_key` / `cdn_url` and `brands.cloudflare_r2_bucket` — already shipped in DR-038 / Schema v1.23). **Supersedes the unapplied Deezy-side "DR-038" staging draft** (2026-06-09, *"R2 Media Bucket Structure & Naming Convention"*): its number collided with the canonical DR-038 (locked 2026-06-11, `seo_media_assets` DAM), and its premise (a still-"proposed" `seo_media_assets` table + a `storage_key` column) was overtaken by that lock. This DR re-files the still-valid parts (key/folder convention, delivery cutover) under a free number, corrected to the shipped schema.

**Scope:** **UNIVERSAL** — every brand storing media on Cloudflare R2 per DR-035. WP-stack brands adopt at media-to-R2 migration.

**Bible Reference:** Additive — proposes a short **"R2 Media Bucket Governance" block** companion to §18.5 (Files & media — annotated by DR-035) and §18.1.2b (☁️ Cloudflare Accounts reference DB — DR-038). **Exact § slot reserved to operator** (per the staging-draft note "operator to slot the exact §"); bump Bible v3.32 → v3.33 when slotted.

**Schema Reference:** **No version change — stays v1.23.** No new/altered columns. One annotation correction in §3.1: `brands.cloudflare_r2_bucket` note changes from *"One bucket may serve multiple brands (operator convention)"* → *"One bucket per brand — no cross-brand sharing (DR-040)."*

**Companion to:** DR-035 (R2 + Image Transformations storage decision — WHERE binaries live), DR-038 (`seo_media_assets` DAM table + per-brand Cloudflare routing — the columns this DR gives a bucket/key contract to), DR-029 (universal brand design system — brand assets), DR-030 (PDPA / sensitive-topic compliance — patient-image isolation is a compliance driver).

**Context:**

DR-035 (🔒 2026-06-04) settled WHERE binaries live (Cloudflare R2; Supabase stores the delivered URL only). DR-038 (🔒 2026-06-11) shipped the metadata table (`seo_media_assets` with `r2_bucket` / `r2_object_key` / `cdn_url`) + per-brand Cloudflare routing on `brands`. **Neither specified (a) whether one R2 bucket may hold more than one brand's media, nor (b) how objects inside a bucket are named/foldered.** DR-038's `cloudflare_r2_bucket` note left bucket-sharing as a loose *"one bucket may serve multiple brands (operator convention)"* — under-specified. The 2026-06-09 Deezy staging draft proposed the opposite (one bucket per brand) plus a key-naming convention, but was never applied (number collision + stale premise). With hundreds of assets per brand across an 858-page build, an unstandardized key space cannot be wired programmatically, and the legacy WordPress Thai-filename URL fragility (`…/อินวิสะไลน์.png` → brittle percent-encoding) recurs.

**Decision:**

1. **Strict per-brand bucket isolation — `{brand-slug}-media`, NO cross-brand sharing, ever.** One bucket = one brand. Even reusable / stock imagery is **copied into each consuming brand's bucket** — a brand never reads another brand's bucket. Location hint `apac`. **This overrides DR-038's "one bucket may serve multiple brands" note.**
   - **Operator rationale (2026-06-14):**
     1. **SEO** — a brand's assets served from another brand's domain/CDN cross-pollinates hotlink/entity signals and dilutes per-domain authority; isolation keeps each brand's media graph clean.
     2. **Blast radius** — in a shared bucket, deleting an image for one page deletes the binary for *every* site referencing it → silent multi-brand breakage. Per-brand buckets contain the damage to one brand.
     3. **Portability / handover** — selling or handing a brand site to a client = hand over one self-contained bucket; no untangling shared objects.
   - **Reinforced by R2's access model:** R2 access control is **bucket-level** (API tokens scoped to account/bucket; public delivery via a per-bucket custom domain) — there is **no durable per-folder ACL**, so a shared public bucket cannot enforce "brand B may not read brand A's folder." Per-brand buckets are the only way to get per-brand access, deletion, quota, and PDPA breach-scope boundaries. Matches the healthcare/PHI multi-tenant consensus (isolate at the tenant boundary; query-time/prefix filters do not prevent storage-level co-mingling).

2. **Folder by content archetype** (object keys map 1:1 to sitemap entity types):
   ```
   brand/              logo.png, logo-white.png, favicon.*, og-default.jpg
   services/{slug}/     branches/{slug}/     doctors/{slug}/
   promos/{YYYY-MM}/    cases/{slug}/         articles/{slug}/     og/
   ```

3. **Key naming:** lowercase **kebab-case**, English slug **matching the page/entity slug**; **no Thai filenames, no spaces**; prefer **`.webp`**; optional role suffix (`hero` / `thumb` / `og` / `exterior` / `before-after`); **never repeat the brand name** inside the key (the bucket is already brand-scoped). This is the documented format of **`seo_media_assets.r2_object_key`** (the staging draft's `storage_key` was a mis-name — the shipped column is `r2_object_key`).

4. **Mutable assets** (e.g. promos) use **versioned / dated keys** instead of overwriting, to avoid edge-cache staleness.

5. **Delivery:** `r2.dev` managed domain for **preview only** (rate-limited); **production** uses **`cdn.{brand-domain}`** (per-bucket custom domain — needs the zone on the same CF account) **or** a Worker R2 binding (`/media/*`). Keep the base URL in **one module** per brand (e.g. Deezy `web/src/lib/media.ts`) so the r2.dev → cdn cutover is a one-line swap.

**Rationale:**

- **Why hard isolation, not a tiered (shared-for-stock) model** — a tier rule was considered (PHI isolated, generic/stock shared) and **rejected by operator** on the three grounds above. The marginal storage saved by sharing stock is trivial next to the blast-radius and handover risk, and R2 cannot ACL a shared bucket per-brand anyway. Copying stock per-brand is cheap and preserves a simple invariant: **a brand's bucket is the brand's — whole, isolated, and portable.**
- **Predictable, programmatic keys** — slug-based archetype folders let the 858-page build resolve image URLs deterministically (no per-asset lookup).
- **One mental model across 15 brands** → shared tooling, one n8n media-sync, shared docs.
- **Avoids URL/caching breakage** — kebab English keys fix the WordPress Thai-filename fragility.
- **Clean prod cutover** — base-URL-in-one-place decouples the convention from the r2.dev → cdn swap.

**Consequences:**

- ✅ **No migration** — convention-only. Existing `smilescape-media` / `deezy-media` already conform at bucket-name + top-folder level; adopt the folder/key naming going forward.
- 🔧 **Schema note corrected** — `Schema_Overview §3.1` `brands.cloudflare_r2_bucket` annotation updated (multi-brand → per-brand isolation). No version bump (annotation only).
- 🔧 **n8n media-sync** (DR-038 Phase 1 upload flow) must **generate object keys per this convention** and target `{brand-slug}-media`; `r2_object_key` stores the archetype-folder key.
- 🔧 **Per-brand code:** keep the R2 base URL in one module; switch r2.dev → `cdn.{brand}` (or Worker binding) at cutover.
- 📋 **Bible:** add "R2 Media Bucket Governance" block — operator to slot the §; bump Bible v3.32 → v3.33 at that point.
- ⚠️ **Stock / reusable imagery is duplicated per brand by design** — accept the redundancy as the price of isolation + portability.
- ⚠️ **WP-stack brands** unaffected until they migrate media to R2; the convention binds at that point.

**References:**

- **Supersedes:** Deezy-side "DR-038" staging draft (2026-06-09) — `deployment/cloudflare/r2-media.md`, `web/src/lib/media.ts`, bucket `deezy-media` (created 2026-06-09). Number collided with canonical DR-038; re-filed here as DR-040.
- DR-035 (R2 + Image Transformations storage decision), DR-038 (`seo_media_assets` DAM + Cloudflare routing), DR-029 (brand assets), DR-030 (PDPA).
- Industry grounding: dedicated-bucket-per-tenant is the healthcare/PHI multi-tenant consensus (storage-level isolation > prefix/RLS filters); Cloudflare R2 access control is bucket-level (tokens scoped to account/bucket; per-bucket custom domain) with no durable per-folder ACL.
- Operator decision 2026-06-14: "ฉันจะไม่มีวันข้าม" — SEO + blast-radius + clean handover.

---

### [DR-039] — Content Tension Model + Block Data-Readiness/Fallback Framework + T5 Service Skeleton + Trust-Footer Order (Content_Templates v1.8 → v1.9) (2026-06-13 → Locked 2026-06-13) 🔒✍️🧩

**Status:** **🔒 Locked 2026-06-13** — operator-directed during the SmileScape T5/T1 content-template build session (operator: "ทำคู่ได้เลย ใช้ทั้งของ smilescape และเขียนกลับ spec"). Drafted + applied same working session. **Additive** — no change to the LOCKED T1-T22 block taxonomy or composition (DR-020); this DR adds two cross-cutting editorial frameworks (§4.6, §4.7), one new worked skeleton (T5), and one example-order correction (T1). Promotes patterns proven in the SmileScape Astro reference build.
**Spec Reference:** Content_Templates **v1.8 → v1.9** — NEW §4.6 (Content Tension Model) + §4.7 (Block Data-Readiness & Fallback Framework); `examples/` gains **T5-service-SKELETON.md**; `examples/T1-medical-condition-SKELETON.md` §13–16 reordered.
**Schema Reference:** proposes `seo_website_page_master.content_gaps jsonb` (Schema Overview follow-up migration) for static-stack brands stored equivalently in page frontmatter `content_gaps[]`. Generalizes DR-034's FAQ-only `content_gap_flag` to ALL blocks.
**Companion to:** DR-034 (Intra-Page Answer Routing — §4.6 builds directly on its understanding→body / decision→FAQ split), DR-020 (T1-T22 template lock — unchanged), DR-019 (schema deprecations — Speakable retained), DR-029 (design tokens — block render layer), DR-017 (content brief), DR-030 (PDPA — patient-journey/before-after consent gate interacts with 🟠 readiness tier).
**Scope:** **UNIVERSAL** (all 14 brands × 6 verticals — every SEO content template inherits §4.6 + §4.7; T5 skeleton seeds all commercial/service pages).

**Context:**

Two production gaps surfaced while building SmileScape's T5 (Service/Money) and T1 (Concern) Astro reference templates:

1. **Answer-first vs engagement-hook was never reconciled in writing.** The spec optimizes hard for AEO/Speakable "give the answer in line 1" (B01 40-60 words; §4.5.4 understanding-PAA → body direct answer), yet good CRO copy opens sections with the reader's pain/question to build tension. These appear to conflict. The spec handled it only *implicitly* (§4.5.4 routing) — no named principle, so writers risk either (a) burying the AI answer behind a preamble, or (b) writing dry label-headings with no pull. SmileScape needed an explicit rule before scaling content.

2. **No fallback when a block's first-party DATA is not ready.** Templates compose blocks like B10/B11a Brand Stance, B12 Clinical Insight, §10 Patient Journey, and Pattern A clinic-data citables — all of which require *real first-party clinic data that a young brand may not have yet*. The spec had NO guidance: it implicitly assumes all data is ready at publish (T1 skeleton line 1007 "B12 placeholder OK on launch" is the only hint; DR-034's `content_gap_flag` covers FAQ only). Brands need a deterministic "skip + flag to backfill, or fallback" rule — never fabricate first-party stats, never silently drop a trust/compliance block.

Also surfaced: only **T1 has a worked skeleton** in `examples/` (T2-T19 carry block-lists only), and the T1 example placed **References after the final CTA**, diverging from the production E-E-A-T-footer-before-CTA pattern.

**Decision:**

**Four coordinated parts (matches DR-038's coordinated-sub-decisions precedent):**

**1 — §4.6 Content Tension Model (answer-first ↔ hook).** Formalizes the implicit reconciliation. Two layers coexist when *zoned*:
- **Answer-first zones — sacred, never delay the answer:** B01 Hero Summary, B02 Quick Facts, B04 Definition (first sentence), B18 FAQ answers, and every §4.5.4 understanding-PAA body answer. 40-60-word direct answers; these are the AI / Speakable / featured-snippet extraction targets.
- **Hook zones — tension/engagement permitted:** the visual hero (where a template has one distinct from B01), section H2/H3 **headings**, B20 CTA copy, inter-section transitions.
- **The unifier = Question-style headings.** A heading phrased as the reader's own question ("{topic} คืออะไร?", "เลือกแบบไหนดี?", "เหมาะกับใครบ้าง?") is *simultaneously* an engagement hook AND an AEO query-match; the answer-first body follows in the next line. A "micro-hook" is therefore **never** preamble before the answer — it is framing-with-the-reader's-question, then answering immediately. This aligns 1:1 with §4.5.4 (understanding-intent → body answer-first; decision-intent → FAQ/hook).
- **YMYL tone guard (Bible Part 23 / Thai med-ad law):** hooks must be question-form or empathetic; **never** fear-mongering, hyperbole, superlatives, urgency-pressure, or outcome guarantees. The Section Brief gains a per-block **tension role** column (`answer-first` / `hook` / `both`).

**2 — §4.7 Block Data-Readiness & Fallback Framework.** Every block in a template's composition carries a **readiness tier** governing publish behavior when real data is not ready. Three tiers:

| Tier | Blocks | Data not ready → | Publishes? | Flag |
|---|---|---|---|---|
| 🔴 **Gate** (core-answer + trust + compliance) | B01, B04, B18, B19, B21, B25, B25a (if acute) | **Block publish, OR publish `noindex` until ready** | ❌ / noindex | `blocking_gap` |
| 🟠 **First-party-preferred** | B10/B11a Brand Stance, B12 Clinical Insight, §10 Patient Journey, B16 Before/After, Pattern A clinic-data citables | **Skip + flag for backfill** (page still ships). Optional: external-evidence fallback (Tier 1-2 citation instead of first-party, lower LLMO power). **Never fabricate first-party stats.** | ✅ | `content_gap` |
| 🟢 **Conditional / Optional** | B09 (skip if 1 option), B25a (skip if chronic-only), severity table, etc. | **Skip silently** when genuinely N/A; justify in Dev Notes | ✅ | `na_justified` |

Mechanism: page carries `content_gaps[]` (`{block, tier, reason, fallback_used, owner, due}`) → feeds a **Content-Completeness report** so operators backfill 🟠 gaps over time and 🔴 gaps block release. This **retains** the existing graceful-skip render pattern (`{data.x && <Block/>}`) but mandates a **written flag (no silent skips)** and **tier enforcement** (a 🔴 gate block can never silently vanish).

**3 — `examples/T5-service-SKELETON.md` authored.** T5 was field-built (SmileScape All-on-4) but had no skeleton. Authored mirroring T1's strict Part 1 (WYSIWYG) / Part 2 (technical+editorial toggles) structure, using the T5 composition (B01, B04, B27 who-for, B13 process, B09 comparison, B16 before/after, B17 pricing, B18 FAQ, B19 review, B22 related, B20 CTA, B21 references) + the commercial marketing layer (heroPromo trust band, "Quick Check" B02 variant, per-tier pricing CTA). Establishes the worked-skeleton authoring pattern for the remaining T2/T3/T4/T6/T6a/T8 templates.

**4 — Trust-footer order standardized: References before the final CTA.** Production groups **Doctor Review + References** as the E-E-A-T trust footer, then the related cluster, then the single final conversion CTA. Standard end-sequence is now **B19 Doctor Review → B21 References → B22 Related → B20 CTA(final)**. `examples/T1` §13–16 reordered accordingly (was: Review → Related → CTA → References).

**Rationale:**

- **§4.6** turns a latent contradiction into a teachable rule; the question-heading unifier means we lose nothing on AEO (body stays answer-first) while gaining CRO tension — and it rides the existing §4.5.4 routing rather than fighting it.
- **§4.7** is the single biggest missing governance piece: without it, a young brand either ships empty block shells, fabricates stats (compliance + trust catastrophe), or blocks publication on data it doesn't have yet. The tiered rule makes the safe path deterministic and machine-trackable.
- **Trust-before-CTA**: citations + reviewer are the last persuasion beat before the ask; a CTA followed by a wall of references reads as an anticlimax and buries the conversion.

**Consequences:**

- Additive; brands re-bump `examples/` + adopt §4.6/§4.7 at their next content Stage gate. No retro-mandate (DR-020 lock unaffected; block composition unchanged).
- Follow-up: add `content_gaps jsonb` to `seo_website_page_master` (Schema Overview migration) — until then static-stack brands store it in page frontmatter. The Content-Completeness report (n8n / dashboard) is a Phase-1 build.
- The 🟠 external-evidence fallback for B10/B12 produces lower-LLMO content by design — flagged so it is upgraded to first-party as data accrues.
- Writers get one new Section-Brief column (tension role) + one new pre-publish gate (resolve 🔴 `blocking_gap`, log 🟠 `content_gap`).

**References:** DR-034 (intra-page routing — direct parent of §4.6), DR-020 (template lock), DR-019 (schema), DR-030 (PDPA consent — §10/B16 readiness), `examples/T1-medical-condition-SKELETON.md`, `examples/T5-service-SKELETON.md`, Content_Templates §4.5.4 → §4.6 → §4.7. First proven in `brands/eywa-smile-scape` (`web/src/layouts/templates/`, `docs/content-blueprint.md`).

### [DR-038] — Canonicalize `seo_media_assets` Multi-Brand Digital Asset Manager + Per-Brand Cloudflare Routing (promotes SS-DR-015/SS-DR-016) (2026-06-11 → Locked 2026-06-11) 🔒🖼️☁️

**Status:** **🔒 Locked 2026-06-11** — operator-directed completion ("Media Library ต้องใช้กับทุกแบรนด์นะ"), drafted + applied same working session. Bible v3.31 flagged `seo_media_assets` as pending; this DR closes the gap. **Greenfield, additive, no data migration** (verified live 2026-06-11: no `%media%`/`%asset%`/`%image%` table existed pre-migration). Promotes SmileScape brand-local **SS-DR-015** (DAM table) + **SS-DR-016** (consent lifecycle) into the canonical federation schema.
**Bible Reference:** §5.3 **Group 11 NEW (Media Assets), 1 table, 37 cols** + §18.1.2 row 14 (clears v3.31 ⚠️ pending → ✅ canonical) + §18.1.2b NEW (Non-mirror operator reference DBs) + system diagram (42 → 43 tables). Bump Bible v3.31 → **v3.32**.
**Schema Reference:** Schema **v1.22 → v1.23**. New canonical table **`seo_media_assets`** in Group 11 §13.1; `brands` §3.1 gains **4 Cloudflare config columns**. Base tables **42 → 43**; Groups **10 → 11**. Schema_Overview file renamed `…v1_22.md` → `…v1_23.md`.
**Companion to:** DR-008 (Two-Column Identity — `mda_{ULID16}`), DR-006 (Two-Phase Sync — Notion master + Supabase mirror), DR-010 (Brand Scope Architecture — explains why scalar `brand_id` not `brand_scope[]`), DR-030 (PDPA / sensitive topic compliance — consent gate semantics), DR-032 (multi-center — `center_scope[]`), DR-035 (Cloudflare R2 + Image Transformations — binary storage path this table tracks), DR-037 (Family-B operational pattern + canonicalization-from-brand-local precedent).
**Scope:** **UNIVERSAL** (every brand with images — clinic, hospital, dental, aesthetic, wellness, healthcare media). Additive table; brands with zero registered images simply carry no rows.

**Context:**

Media Library (Notion DB) was originally built **2026-06-06 by Naphannop N. for SmileScape's brand-pilot DAM** under SS-DR-015 (DAM table) + SS-DR-016 (consent lifecycle). Bible v3.31 (2026-06-11) promoted the Notion side to canonical N↔S DB #14 + cloned a clean copy into the_gifted workspace — but the **Supabase target `seo_media_assets` was never created**, leaving the sync write-back orphaned (Notion description targets `Supabase ID` / `Synced at` columns referencing a non-existent table).

Same operator session also surfaced: **n8n uploads to Cloudflare R2 need per-brand routing**. Two CF accounts in use across the org (`naphannop.n@gmail.com` personal, `marketing@vplanetgroup.com` work); brand → account assignment varies and needs a queryable source for n8n to consult before upload. Pre-DR-038, no such binding existed.

DR-035 (2026-06-04 🔒) locked the **storage decision** (Astro brands → R2 + Image Transformations; URL in Supabase only) but stopped short of specifying *which* Supabase table holds the URL. DR-038 ships that table.

**Decision:**

**Two coordinated changes, single DR (matches DR-032's coordinated-sub-decisions precedent):**

1. **`seo_media_assets`** — new canonical table, **Group 11 (Media Assets) NEW**. 37 columns:
   - **Identity:** DR-008 two-column (`fingerprint mda_{ULID16}` + `fingerprint_display_name`, trigger-set + immutable)
   - **Sync:** DR-006 three-state machine (`flat_loaded → notion_synced → relations_backfilled → live`)
   - **Asset metadata:** `asset_name`, bilingual captions/alt, dimensions, MIME
   - **Classification:** 11-option `media_type` enum **mirrors Notion select verbatim** (doctor/branch/brand/treatment/procedure/condition/tech/case/clinic/brand_asset/other)
   - **Brand/Entity binding (Family-B per DR-037 ruling):** scalar `brand_id uuid NOT NULL FK → brands(id) ON DELETE CASCADE` (NOT `brand_scope[]` — operational reference data, not knowledge-graph), soft `entity_fp text`, DR-032 `center_scope[]`
   - **PDPA consent lifecycle:** `is_patient_image bool`, `consent_status (Obtained/Pending/Revoked)`, `consent_date`, `consent_doc_url`, **pseudonymized** `patient_ref`, `use_forever`, `use_until`
   - **Cloudflare R2 (per DR-035):** `r2_account_email`, `r2_bucket`, `r2_object_key`, `r2_uploaded_at`, `cdn_url`
   - **Lifecycle:** 5-state status enum (`Pending/Active/Expired/Revoked/Archived`)
   - **DB-layer PDPA gate** (`CHECK pdpa_active_consent_gate`): patient image cannot go `Active` without `consent_status='Obtained'` AND (`use_forever=true` OR `use_until` set). Non-patient categories bypass.
   - **9 indexes** incl. partial index on `use_until` for **PDPA consent-expiry alerting cron**.
   - RLS `eywa_authenticated_full_access` (Family-B operational policy).

2. **`brands` +4 Cloudflare config columns:**
   - `cloudflare_account_email`, `cloudflare_account_id`, `cloudflare_zone_id`, `cloudflare_r2_bucket`
   - Partial index on `cloudflare_account_email` (queries always filter by account).
   - **Layer A** of the 2-layer design: canonical, queryable, drives n8n routing.
   - **Layer B** (operator UI, no Supabase mirror): Notion `☁️ Cloudflare Accounts` reference DB created in both workspaces, seeded with 2 known account emails (Bible §18.1.2b documents the non-mirror pattern).

Applied as **Wave 11.8** (`eywa_w11_08_dr038_v23_media_assets_canonical`) + **Wave 11.9** (`eywa_w11_09_dr038_v23_brands_cloudflare_config`).

**Rationale:**

- **Why Group 11 NEW, not extend an existing group?** — `seo_media_assets` is operationally distinct: not Brand-org (Group 1), not Knowledge (Group 2), not a Page (Group 3), not Keyword (Group 4), not a Fact table (Group 5), not Backlinks (Group 6), not AI ops (Group 7), not Governance (Group 8), not an Entity-CPT extension (Group 9), not Ads (Group 10). It's a **new operational dimension** (binary asset lifecycle). Future media-adjacent tables (e.g. `seo_media_collections`, `seo_media_usage_logs`) would land in this group too.
- **`brand_id uuid` FK, not `brand_scope[]`** — same ruling as DR-037: per-brand operational data (an image binary belongs to ONE brand, not shared across the graph). Matches `seo_branches`, `seo_doctor_assignments`, `seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`, `seo_payer_partners`.
- **PDPA gate at DB layer, not application layer** — bypassable in application code under pressure; DB-layer CHECK is the only enforcement strong enough for healthcare compliance. Cost: one CHECK constraint. Benefit: cannot accidentally publish patient image without consent.
- **R2 metadata in Supabase, binary in R2 (per DR-035 path a)** — pure URL field would lose `r2_object_key` (needed for re-delivery / rename) and `r2_uploaded_at` (drift detection). Five fields balance "lightweight but operable".
- **Non-canonical `☁️ Cloudflare Accounts` reference DB, not a 15th N↔S table** — pattern matches operator-config registries (login bank, internal contact list): 2 rows total, hand-curated, never mirrored to graph DB, never auto-synced. Lifting it to N↔S adds friction (sync flow, schema parity audits) for zero analytical value.
- **Promotes SS-DR-015/SS-DR-016 to central** — same precedent as DR-037 promoting DZ-DR-014. Pattern: brand-local solves first; canonicalize when 2nd brand needs it OR when operator confirms universal scope. User said "ต้องใช้กับทุกแบรนด์นะ" — confirmed universal.

**Consequences:**

- ✅ **DB (BUILT 2026-06-11):**
  - **W11.8** `eywa_w11_08_dr038_v23_media_assets_canonical` — verified: 37 cols, 9 indexes, 3 triggers, RLS enabled, PDPA gate blocks patient-image→Active without consent (test confirmed); fingerprint auto-set with `mda_` prefix (test confirmed); non-patient bypass works (test confirmed). 3 audit rows in `seo_schema_changes` (DR-038, v1.23).
  - **W11.9** `eywa_w11_09_dr038_v23_brands_cloudflare_config` — 4 cols added on `brands`; partial index on `cloudflare_account_email`. 4 audit rows in `seo_schema_changes` (DR-038, v1.23).
- ✅ **Notion (BUILT 2026-06-11):**
  - 🖼️ Media Library descriptions broadened in both workspaces (clarifies universal scope — non-patient images bypass PDPA gate).
  - ☁️ Cloudflare Accounts reference DB created in both workspaces (vt_intelligence `4bc7291f-…`, the_gifted `c8d63712-…`), 10 properties each, seeded 2 rows × 2 workspaces (4 rows total).
- 🌐 **Federation-ready** — any brand may now insert media rows keyed by its `brand_id`; sync flow can write back `notion_id` after Notion page creation.
- ⚠️ **Operator follow-ups (non-blocking):**
  - Fill in actual `Account ID`, `Default R2 Bucket`, `Default Zone ID`, `Plan`, `Brand Slugs Using` in the 4 seeded ☁️ Cloudflare Accounts rows.
  - Populate `brands.cloudflare_*` per brand (start with brands that have images today; defer for brands at Stage 1 pre-content).
  - n8n image-upload workflow needs to be built (Phase 1: Notion → R2 + write `r2_*` + `cdn_url` back to Supabase row; Phase 2: backfill `notion_id` after Notion page write).
- 🔧 **Docs:** Schema_Overview → **v1.23** (§13 Group 11 NEW; §3.1 brands +4 cols; §2 group count 10→11; Appendix I extends to W11.9; file renamed). Bible v3.31 → **v3.32** (changelog v3.32 entry; §18.1 header updated; §18.1.2 row 14 cleared; §18.1.2b NEW; v3.31 row warning removed). `n8n-flows/notion_db_ids.the_gifted.env.template` extended with `NOTION_DB_CLOUDFLARE_ACCOUNTS_*` + `CLOUDFLARE_ACCOUNT_EMAIL_*` registry vars.
- 🌱 **Deferred extensions (out of scope for DR-038):**
  - `seo_media_collections` (image groupings — landing-page hero set, doctor portrait pack, etc.) — future DR if operator need emerges.
  - `seo_media_usage_logs` (per-page-render audit) — future DR; deferred until cleanup/audit workflow exists.
  - Image-AI captioning pipeline — separate workflow (existing schema fields support output).
- 📋 **Out of scope (separate tracks):**
  - Historical image migration from WordPress brands — operator-driven per brand; `source='wp-migration'` value reserved for this.
  - Cloudflare API token storage — out of scope (use n8n credential vault or Supabase Vault per DR-038 Layer A note).

**References:**

- Origin: SmileScape brand session SS-DR-015 (DAM table) + SS-DR-016 (consent lifecycle), 2026-06-06.
- DR-008 (Two-Column Identity), DR-006 (Two-Phase Sync), DR-010 (Brand Scope Architecture — `brand_scope[]` vs `brand_id` split), DR-030 (PDPA / sensitive topic compliance), DR-032 (multi-center `center_scope[]`), DR-035 (Cloudflare R2 + Image Transformations storage decision), DR-037 (Family-B operational pattern + brand-local-to-canonical promotion precedent).
- Schema_Overview §13.1 (`seo_media_assets` full DDL), §3.1 (`brands` Cloudflare cols); migrations `eywa_w11_08_dr038_v23_media_assets_canonical` + `eywa_w11_09_dr038_v23_brands_cloudflare_config`.
- Bible §18.1.2 row 14 (cleared to canonical), §18.1.2b NEW (non-mirror operator reference DBs pattern), §18.1.3 structural parity notes.

---

### [DR-037] — Canonicalize `seo_payer_partners` as Tier-2 Local-SEO Federation Table (backport of DZ-DR-014) (2026-06-08 → Locked 2026-06-08) 🔒🏥🧾

**Status:** **🔒 Locked 2026-06-08** — operator-directed completion ("finish it so every brand can pick it up"), drafted + applied same working session. **In-place ALTER** of an existing brand-local table (71 Deezy rows migrated, no data loss); applied via migration `eywa_w11_07_dr037_v22_payer_partners_canonical`. Backport of the operator-approved brand-local **DZ-DR-014** (Deezy Dental) into the canonical federation schema.
**Bible Reference:** **§5.3 Group 1** (Brand & Organization, **8 → 9** tables) + system diagram (41 → 42 tables). Full DDL deferred to Schema_Overview §3.9 per the Bible's standing division of labor. Bump Bible v3.28 → **v3.29**.
**Schema Reference:** Schema **v1.21 → v1.22**. New canonical table **`seo_payer_partners`** in Group 1 §3.9. Base tables **41 → 42**; Group 1 **8 → 9**. Schema_Overview file renamed `…v1_21.md` → `…v1_22.md`.
**Companion to:** DZ-DR-014 (the brand-local origin), DR-008 (Two-Column Identity — `payp_{ULID16}`), DR-010 (Brand Scope Architecture — explains why `brand_scope[]` is **not** used here), DR-025 (Local SEO subsystem this table joins).
**Scope:** **UNIVERSAL** (Tier-2, all clinic/hospital brands). Additive table; brands with zero payer partners simply carry no rows.

**Context:**

Deezy raised **DZ-DR-014** needing a cashless payer + corporate-welfare partner directory (Deezy sitemap §2.7/§2.8). No existing spec table fit: `seo_entity_organization` (§11.8) is built for **authority / citation** orgs (`ror_id`, `is_who_recognized`, `used_as_citation_source`) — loading 70+ insurers/employers there would pollute the E-E-A-T citation graph; and a payer roster is **operational reference data** (churns frequently, per-brand), not a knowledge-graph entity, so modelling it in `seo_entity_graph` would bloat the graph for ~2 directory pages. The table was built **brand-local in GTGT 2026-06-07** (71 rows: 36 insurers + 35 employers) and logged in `seo_schema_changes` flagged `spec_version='v1.15 (backport pending)'`. The hand-off proposal lives at `brands/eywa-deezy/deployment/supabase-load/SPEC-BACKPORT-seo_payer_partners.md`.

**Decision:**

Adopt `seo_payer_partners` as a **canonical Tier-2 Local-SEO federation table** (Group 1, §3.9). Canonical shape = the **Family-B per-brand-operational pattern** (the subsystem of `seo_branches` / `seo_reviews` / `seo_directory_listings` / `seo_gbp_posts` / `seo_doctor_assignments`):

- `brand_id uuid NOT NULL` **FK → `brands(id)`** (was `text` slug with `DEFAULT 'deezy-dental'`).
- **DR-008 Two-Column Identity:** `fingerprint text NOT NULL UNIQUE` (`payp_{ULID16}`) + `fingerprint_display_name text NOT NULL`, set by `trg_set_fingerprint → fn_set_fingerprint_generic('payp','partner_name','partner_name')` + `trg_prevent_fingerprint_change` (immutability). **No format CHECK** — format is trigger-enforced, matching every Family-B table.
- RLS `eywa_authenticated_full_access` (already on). Existing CHECKs (`partner_type ∈ {insurer,employer}`, `insurer_category ∈ {life,non_life,tpa,foreign}`, `verification_status ∈ {unverified,verified,needs_review}`), UNIQUE `(brand_id, partner_type, partner_name)`, and `opd_only` / `cashless` / `affiliates[]` columns retained as loaded.

Applied as an **in-place ALTER** of the brand-local table (name already matched) — `eywa_w11_07`.

**Rationale:**

- **New table justified** — by the proposal's own analysis: payers are commercial/operational, not authority/citation orgs, and not graph entities. Cross-brand need: every clinic/hospital brand has cashless insurer + corporate-welfare partners, so this belongs in the shared spec, not as a Deezy fork.
- **`brand_id uuid` FK, NOT `brand_scope[]` (corrects proposal refinement #2)** — the proposal recommended `brand_scope text[]`, which **contradicts its own "not a knowledge-graph entity" reasoning**. Live convention is a clean split: `brand_scope[]` is for **graph/shared** data (`seo_entity_graph`, `seo_citations`, `seo_topic_cluster_master`, `seo_authors_reviewers`, `seo_entity_relationships`, `seo_page_internal_links`); **per-brand operational** tables use scalar `brand_id uuid` FK → `brands(id)`. `seo_payer_partners` is the 6th member of the Local-SEO operational subsystem → it matches those five. *(Noted: `seo_brand_centers` + `seo_website_page_master` use `text → brand_slug`; uuid was chosen here for consistency with the Local-SEO operational siblings. A future federation-wide brand-key standardization can revisit via DR.)*
- **Trigger-enforced fingerprint, no CHECK (corrects proposal refinement #1)** — the proposal asked for a `CHECK payp_[0-9A-F]{16}`; live Family-B tables enforce the format via `fn_set_fingerprint_generic` + UNIQUE only, no per-table CHECK. Followed the live convention.
- **Section §3.9, not §3.8 (corrects stale proposal anchor)** — the proposal targeted "§3.8 near `seo_branches`", but §3.8 has been `seo_brand_centers` since Schema v1.18 (DR-032). New table lands at §3.9.

**Consequences:**

- ✅ **DB (BUILT 2026-06-08, `eywa_w11_07_dr037_v22_payer_partners_canonical`):** in-place ALTER; 71 Deezy rows migrated (`brand_id` slug→uuid, `payp_` fingerprints backfilled). **Verified:** 71/71 distinct, well-formed `payp_[0-9A-F]{16}` fingerprints; FK valid; bare `INSERT` (brand_id + partner_type + partner_name only) auto-sets fingerprint via trigger. `seo_schema_changes`: origin `create_table` row `spec_version` cleared `'v1.15 (backport pending)'` → `'v1.22 (canonical · DR-037)'`; new `other` row records the migration.
- 🌐 **Federation-ready** — any brand may now insert payer rows keyed by its `brand_id`; RLS unchanged.
- 📋 **Out of scope (separate Deezy-operator track):** data verification of Deezy's 71 rows (true-cashless vs reimbursement, 7 `needs_review` names, 2 `opd_only` flags, `source` + `last_verified_date`). `verification_status` stays `unverified`/`needs_review` until Deezy validates — this DR canonicalizes the **schema**, not the data.
- 🔧 **Docs:** Schema_Overview → **v1.22** (§3.9 added; §2 Group-1 list + §3 heading 8→9; total 41→42; file renamed). Bible v3.28 → **v3.29** (§5.3 Group-1 list +`seo_payer_partners`; system diagram counts). migrations/README → Wave 11.07 entry.
- 🌱 **Deferred refinement (proposal #3):** optional `renders_on_page_fps text[]` link to page master — left to the page→`partner_type` convention for now; revisit if a payer needs multi-page targeting.

**References:**

- DZ-DR-014 origin + full proposal: `brands/eywa-deezy/deployment/supabase-load/SPEC-BACKPORT-seo_payer_partners.md`; reproducible load `11_payer_partners.sql`.
- DR-008 (Two-Column Identity), DR-010 (Brand Scope Architecture — the `brand_scope[]` vs `brand_id` split), DR-025 (Local SEO subsystem), DR-032 (§3.8 `seo_brand_centers`, the prior Group-1 addition).
- Schema_Overview §3.9 (`seo_payer_partners` full DDL), §2 Group 1; migration `eywa_w11_07_dr037_v22_payer_partners_canonical`.

---

### [DR-036] — Split `condition` / `symptom` into Separate CPTs (Tier-1 Core, 8 → 9) (2026-06-04 → Locked 2026-06-04) 🔒🧬🩺

**Status:** **🔒 Locked 2026-06-04** — operator-decided **and applied** same working session (14-day review waived per the waiver clause below, mirroring DR-035). Originally drafted **🌱 Proposed 2026-06-04**. **Greenfield, additive, no data migration** (verified: every brand is at Stage 1 / pre-WordPress-build; zero brands have built `condition`/`symptom` pages). Locking before the first WP build is the cheapest moment — same reasoning as DR-035. **Spec propagated to Bible v3.26 + Schema v1.21; `seo_entity_symptom` BUILT 2026-06-04 via migration `eywa_w11_06_dr036_v21_entity_symptom` (29 cols, RLS-enabled `eywa_authenticated_full_access`, additive `CREATE TABLE` — no existing table touched, no data).**
**Bible Reference:** Amends **§25.2** (CPT Tier Architecture — Tier-1 Core 8 → **9**), **§25.3** (splits "Core CPT 6 — `condition` (hosts BOTH condition + symptom)" into two CPTs: `condition` + new `symptom`), **§25.5** (adds `symptom_meta`; symptom uses the 4 universal ACF groups), **§25.6** (activation: `symptom` Tier-1 always-on). **§4.5** (Page-Branch Relationship A/B/C/D) **unaffected** — this is the entity-CPT axis, orthogonal to the branch axis.
**Schema Reference:** **Additive.** New extension table **`seo_entity_symptom`** in Group 9 (1:1 with `seo_entity_graph` rows where `type='symptom'`, S-only, mirrors the existing `seo_entity_condition` pattern); Group 9 count **10 → 11**. `seo_entity_condition` now hosts conditions only. **No data migration** (greenfield). Schema_Overview → **v1.21**.
**Companion to:** §25.3 Core CPT 6 (the original merge this DR reverses), DR-006 (Two-Phase Sync — symptom inherits Group-9 S-only behavior), DR-013/DR-014 (Edge Vocabulary — `symptom_of` semantics unchanged, now realized as a cross-CPT edge), DR-004/DR-010 (URL — `/by-concern/` base retained), DR-035 (greenfield-timing precedent).
**Scope:** **UNIVERSAL** (Tier-1, all brands). Additive. Brands with zero symptom entities carry an empty always-on CPT (harmless — generates no pages).

**Context:**

§25.3 originally merged `condition` + `symptom` into a single `condition` CPT, discriminated by an ACF `entity_subtype` radio (`condition` | `symptom`). The merge's only real benefit was **URL convenience** — one `/by-concern/{slug}` rewrite base aligned to the near-universal "Treatment by Concern" sitemap section — plus avoiding CPT sprawl. It did **not** give readers a unified experience: the template already branches (`single-condition.php` vs `single-condition--symptom.php`) and schema already differs (`MedicalCondition` vs `MedicalSignOrSymptom`), both keyed off `entity_subtype`.

Operator review (2026-06-04, Deezy planning) found the merge **confusing to maintain long-term** in the WP admin, and **inconsistent** with the already-split `procedure` / `treatment` sibling pair. Crucially, the **planning layer already separates the two**: `seo_entity_graph` carries `type='condition'` vs `type='symptom'` as distinct entity types (Deezy: 50 conditions, 7 symptoms). So the implementation (1 CPT) was *less* granular than the data model (2 types) — the split realigns them.

Because the federation is **greenfield** (no brand past Stage 1; no WP build; no live condition/symptom pages), the split is a pure spec + kit + entity-tagging change with **no data migration, no redirects** — the cheapest possible moment.

**Decision:**

Promote `symptom` to its own **Tier-1 Core CPT**. Tier-1 Core: **8 → 9**:
`doctor · branch · procedure · treatment · technology · condition · symptom · case_study · post`

Three locked sub-decisions:

1. **URL — shared `/by-concern/{slug}` for BOTH CPTs.** `symptom` registers under the same `/by-concern/` base as `condition`. A custom rewrite/request filter in the kit resolves `/by-concern/{slug}` across both post types. **No collision risk** — EUG (DR-011) already guarantees globally-unique entity slugs (verified: Deezy's 7 symptom slugs are distinct from all condition slugs). The "Treatment by Concern" sitemap-section grouping is preserved via the `sitemap_section` taxonomy (independent of CPT and URL), so both CPTs group together in that section. **No URL change, no redirects, no SEO impact.**
2. **Tier — Tier-1 always-on** (operator choice). An always-on CPT with zero symptom entities is harmless. *(Alternative considered: Tier-2 common-optional, default-on for clinical verticals — marginally more honest if non-clinical brands genuinely have zero symptoms. Operator chose Tier-1 for model simplicity / no activation-flag branching.)*
3. **Entity table — add `seo_entity_symptom`** (Group 9), 1:1 with `seo_entity_graph` rows of `type='symptom'`, mirroring the per-type extension pattern (each entity type = its own extension table). `seo_entity_condition` retains conditions only.

Downstream realizations (mechanical, no new vocabulary):
- `symptom_of` edge becomes a **cross-CPT** edge (`symptom` → parent `condition`) instead of intra-CPT. Edge vocabulary unchanged.
- `eywa-schema-pipeline` keys schema-type emission off **`post_type`** (`symptom` → `MedicalSignOrSymptom`; `condition` → `MedicalCondition`) instead of `entity_subtype`.
- The `entity_subtype` ACF field on `condition` becomes **vestigial** → removed (or left dormant; operator to confirm — see Consequences).

**Rationale:**

- **Consistency** — `procedure`/`treatment` are split siblings; `condition`/`symptom` (also distinct schema.org types) should match. One mental model.
- **Implementation matches planning** — the entity graph already types them separately; the split removes the model/implementation mismatch. CPT assignment becomes a **mechanical derivation** from the existing `type` column (`type=symptom → symptom CPT`), adding **zero** planning-phase complexity.
- **One clean federation-wide model** — promoting to core (vs a flag-gated optional CPT) avoids permanent **dual-model** branching in the shared kit (no "symptom-as-subtype OR symptom-as-CPT" forks in relationship constraints / schema-pipeline).
- **No reader regression** — reader UI and schema were already differentiated by template + conditional schema; the split is purely backend/admin clarity.
- **No URL/SEO impact** — `/by-concern/` retained; section alignment preserved via taxonomy.
- **Greenfield timing** — additive now, migration-free; deferring to post-WP-build would turn it into a coordinated cross-brand migration.

**Consequences:**

- ✅ **No data migration** — additive DDL only (`CREATE TABLE` + RLS policy); existing tables untouched. Existing 1,376 `seo_website_page_master` rows unaffected (page–branch axis untouched).
- 🔧 **Schema (v1.21, BUILT 2026-06-04):** `seo_entity_symptom` created in Group 9 — **29 cols**, mirrors `seo_entity_condition` (`entity_fp text NOT NULL UNIQUE` FK → `seo_entity_graph.entity_fingerprint` ON DELETE CASCADE; RLS `eywa_authenticated_full_access`; PK `id uuid`). Dropped condition-only fields; added symptom-specific `severity_scale`/`typical_onset` (CHECK-constrained) + `typical_duration` + YMYL-safety fields (`red_flag_indicators`, `self_care_guidance`, `when_to_see_doctor`, `is_emergency_sign`) + cross-CPT FKs (`associated_conditions_fps` → condition, `accompanying_symptoms_fps` → self, `related_anatomy_fps` → anatomy). Group 9: 10 → 11; base tables 40 → 41. Migration `eywa_w11_06_dr036_v21_entity_symptom` (Wave 11, applied via Supabase).
- 🔧 **Kit changes:**
  - `eywa-cpt-activation` — register `symptom` CPT, Tier-1 always-true in `v_brand_cpt_activation`.
  - `eywa-acf-fields` — `symptom` attaches the 4 universal groups (`eywa_classification`, `eywa_relationships`, `eywa_evidence`, `eywa_llmo_citables`) + new `symptom_meta`. Relationship-field constraints that referenced `post_type=condition` for symptoms (`symptoms_of`) now target `post_type=symptom`; constraints that target conditions (`treats_concerns`) stay `post_type=condition`.
  - `eywa-schema-pipeline` — emit by `post_type` (see above); drop `entity_subtype` branch.
  - Custom rewrite — `/by-concern/{slug}` resolves across `condition` + `symptom`.
- 🔧 **Bible edits:** §25.2 (Tier-1 8→9 table), §25.3 (split Core CPT 6 → `condition` + new `symptom`; renumber subsequent core CPTs; remove `condition_vs_symptom_handling` block from `condition`, add a `symptom` spec with `schema_org: MedicalSignOrSymptom`, `rewrite: by-concern`, `symptom_meta`), §25.5 (add `symptom_meta`), §25.6 (activation flag). Bump Bible v3.25 → **v3.26**.
- ⚠️ **`entity_subtype` disposition** — operator to confirm: **drop** the field (cleanest, greenfield) vs **leave dormant**. Recommended: drop, since `post_type` now carries the distinction. **Spec-propagation decision (2026-06-04):** the condition/symptom *discriminator* use of `entity_subtype` is removed (Core CPT 6 `condition_vs_symptom_handling` block deleted; `icd_10` visibility + `symptoms_of`/`treats_concerns` constraints re-keyed to `post_type`). The **general-purpose / DR-014 concept-axis** `entity_subtype` field (Group 1 — `framework`/`axis`/`health-belief`, ingredient subtypes) is **retained** (out of this DR's scope).
- ⚠️ **Other brands** — additive only; no runtime change to any brand's site (no brand is built). Brands with zero symptoms get an empty CPT.
- 📋 **Deezy follow-up** — 7 symptom entities (`tooth-sensitivity`, `toothache`, `gum-bleeding`, `gum-swelling`, `loose-tooth`, `sensitivity-post-whitening`, `emergency-toothache`) re-tag to the `symptom` CPT at load time (planning only; entities.md already types them `Symptom`). `page-archetypes.md` updated to map `concern → {condition, symptom}`.
- 📋 **Open follow-ups:** ~~(a) finalize `symptom_meta` field list~~ ✅ **done 2026-06-04** — table built (29 cols); ACF `symptom_meta` mirrors the built columns (Bible §25.3 Core CPT 7). (b) implement the shared-base `/by-concern/` rewrite resolver (kit-level — lands at first WP build). (c) ~~confirm `entity_subtype` drop~~ ✅ done at spec level (condition/symptom discriminator removed; DR-014 concept-axis field retained).

**References:**

- §25.2 (CPT Tier Architecture), §25.3 Core CPT 6 (the merge reversed here), §25.5 (ACF groups), §25.6 (activation flags), §4.5 (Page-Branch Relationship — unaffected).
- Schema_Overview §11 Group 9 (entity extensions, S-only 1:1 with entity_graph), §11.5a new `seo_entity_symptom`.
- DR-011 (EUG — slug uniqueness underpins the shared `/by-concern/` base), DR-013/DR-014 (edge vocab — `symptom_of`), DR-035 (greenfield-timing precedent), §25.3 Core CPT 3/4 (procedure/treatment split — the consistency precedent).
- Deezy evidence: `content-plan/entities.md` (Condition 50 / Symptom 7, typed); `content-plan/page-archetypes.md`.

---

### [DR-035] — Image Storage & Delivery for Astro Brands (Cloudflare R2 + Image Transformations) (2026-06-04 → Locked 2026-06-04) 🔒🖼️☁️

**Status:** **🔒 Locked 2026-06-04** — operator-approved in working session same day (14-day review waived: net-new capability, additive, **no schema change, no migration**; verified that **zero brands wire image binaries in code yet** — greenfield, so locking before the first image-heavy Astro brand build is the cheapest moment; **WordPress brands unaffected**).
**Bible Reference:** Clarifies **§18.5** (Notion ↔ Supabase Field Mapping — "Files & media") for the **Astro stack profile**. The WordPress media path is unchanged.
**Schema Reference:** **No change.** The `seo_*` image columns are already URL-typed (`primary_photo_url text`, `interior_photos text[]`, `review_photos text[]`, `media_urls text[]`, `before_after_photos`, etc. — Schema_Overview v1.20). This DR only changes **where the URL points** (Cloudflare R2 / Images instead of Supabase Storage) for Astro brands. No DDL.
**Companion to:** DR-EYWA-MKT-005 (Astro stack profile — this DR is its image layer), DR-002 (Elementor/WordPress stack — the unaffected legacy media path), DR-EYWA-MKT-006 / DR-EYWA-POLY-004 (Supabase content workflow — Supabase keeps image **metadata/URL**, not the binary).
**Scope:** **Astro brands only** (today: Polyvex + Deezy Express Dental Unit; all future Astro brands). **WordPress brands: NO action** — images stay in the WordPress media library as today.

**Context:**

The spec's only recorded image-storage statement (§18.5) maps Notion "Files & media" → "Supabase Storage URLs". That was written for the **WordPress** pipeline (Notion → Supabase → WordPress), where WP serves the media. The newer **Astro stack profile** (DR-EYWA-MKT-005) renders static output to the **Cloudflare** edge — which reframes the question. Two legacy placeholder topics ("CDN strategy", "image optimization pipeline") were never resolved, and **no brand has wired image storage in code** (verified 2026-06-04: zero `supabase.storage` / `createClient` usage across all repos). This is greenfield.

Decisive cost fact (verified 2026-06-04): **Supabase Storage runs on Cloudflare R2 under the hood and bills $0.09/GB egress on top; R2 used directly is egress-free.** Storing binaries in Supabase and serving them through the Cloudflare-hosted site means paying an egress markup to bounce through a layer the site does not need.

**Decision:**

For Astro brands, **image binaries live on Cloudflare; Supabase stores only the URL.** Three tiers by image profile:

1. **Brand chrome** (logo, favicon, default OG, icons, proprietary diagrams) → committed to git `web/src/assets/`, optimized at build by **`astro:assets`** (Sharp), emitted as content-hashed static assets on the Cloudflare edge. Cost: **$0**.
2. **Default for content/marketing + high-volume galleries** (e.g. clinic before/after, case libraries) → binaries in **Cloudflare R2** (egress-free), resized/converted on the fly by **Cloudflare Image Transformations** (`format=auto` → AVIF/WebP), served + cached at the edge. The Supabase row stores the delivered URL/object key in the existing URL columns.
3. **Optional managed upgrade** → **Cloudflare Images** (all-in-one: upload API + dashboard + variants) when a non-technical team needs a turnkey upload surface and the ~$5/mo base is worth avoiding a custom upload path. Swappable later at near-zero cost because the DB stores only a URL.

**Delivery rule (universal across tiers):** the browser always fetches images from the **Cloudflare edge** — never directly from Supabase Storage.

**Rationale:**

- **Cost** — R2 egress is free; Supabase egress is $0.09/GB on R2-under-the-hood (a markup to bounce). Transformations: first **5,000 unique/mo free**, then $0.50/1,000 — a ~2,000-image clinic at 3 sizes lands ≈ **$0–0.50/mo** all-in. (R2 $0.015/GB-mo + 10GB free; Cloudflare Images $5/100k stored + $1/100k delivered — all confirmed 2026-06-04.)
- **Locality** — the whole Astro site already lives on Cloudflare; keeping binaries + transforms + delivery on Cloudflare = one control plane, best Core Web Vitals, no cross-vendor hop.
- **Separation of concerns** — Postgres is the system of record for *which image belongs to which row* (URL + alt + consent metadata); the object store holds *bytes*. The schema already models this (URL columns), so no migration.
- **WordPress untouched** — WP brands already store + serve media from WP; forcing them onto R2 would be churn for no gain.

**Consequences:**

- ✅ **No schema change, no migration** — URL columns already fit; only the URL host changes for Astro brands.
- ✅ **§18.5 annotated** in EYWA_PROTOCOL v3.25 with a cross-ref to this DR (WordPress = Supabase/WP path; Astro = Cloudflare R2/Images path).
- ⚠️ **R2 has no friendly upload UI for non-technical operators.** Resolve per brand via one of: (a) **n8n pushes** Notion-attached images → R2 (S3 API) during sync, URL written to the Supabase row — fits the existing Notion → n8n → Supabase pipeline; (b) a small **upload Worker**; (c) jump to **Tier 3 (Cloudflare Images)** for a built-in dashboard. Chosen at each brand's Phase B, not here.
- ⚠️ **Consent / PDPA trap for before/after (healthcare).** Anything baked into the static `dist/` or served from a **public** R2 bucket is **permanently public + cacheable** → cannot be revoked. Consented-public before/after → public path OK. Pending-consent / revocable / sensitive → **private R2 bucket + signed URLs via a Worker, never baked**. Consent forms → private store / DMS only (never git, never public bucket) — consistent with the consent-record external-storage note (Schema_Overview) + `imagery.md` (consent-records gitignored).
- ⚠️ **Originals do not bloat git** — RAW / high-res originals go to a **private R2 bucket** (or cloud drive), not git, not the public bucket; only web-destined derivatives are served. Supersedes the implicit "commit web images to `web/public/`" convention in `brand-assets/README` for image-heavy brands.
- 📋 **Follow-ups:** per-brand upload-path choice (Phase B); enable Image Transformations on each Astro brand's Cloudflare zone; document the `astro:assets` `image.remotePatterns` / `image.domains` allowlist for the R2 origin; **Polyvex adopts via DR-EYWA-POLY-011**.

**References:**

- §18.5 Notion ↔ Supabase Field Mapping (now annotated).
- DR-EYWA-MKT-005 (Astro stack profile), DR-002 (WordPress stack), DR-EYWA-POLY-004 (Supabase content workflow).
- Cloudflare R2 pricing (egress-free; $0.015/GB-mo; 10GB / 1M Class A / 10M Class B free tier); Cloudflare Images + Image Transformations ($0.50/1,000 unique transforms, 5,000/mo free; stored Images $5/100k + $1/100k delivered); Supabase Storage egress $0.09/GB beyond plan allowance (R2 under the hood) — all verified 2026-06-04.
- `templates/folder-skeleton/design/brand-foundation/imagery.md` (consent + file organization).

---

### [DR-034] — Intra-Page Answer Routing (PAA × FAQ) (2026-06-03 → Locked 2026-06-03) 🔒🧭

**Status:** **🔒 Locked 2026-06-03** — operator-approved in working session same day (14-day review waived: additive/non-breaking, safe defaults, no brand mid-content-build to canvass, and the design *ratifies the existing §4.5.3 Cannibalization Shield intent* by extending it from between-page to within-page scope).
**Bible Reference:** Extends Content_Templates **§4.5.3 Cannibalization Shield** → new **§4.5.4 Intra-Page Answer Routing**; updates block **B18 FAQ** floor logic. Referenced in Bible v3.24 changelog (2026-06-03); full spec lives in Content_Templates §4.5.4 + this DR (no Bible §-section needed — this is a content-composition rule).
**Schema Reference:** **BUILT 2026-06-03** — migration `eywa_w11_05_dr034_v20_page_master_paa_routing` (W11.5) adds **`seo_website_page_master.intent_source_tier text NOT NULL DEFAULT 'template_only'`** (CHECK `paa`/`derived`/`template_only`) + **`seo_website_page_master.paa_checked_at timestamptz`**. **Schema_Overview → v1.20** (file renamed `…v1_19.md` → `…v1_20.md`). Additive; safe default backfills existing 1,376 rows to `template_only`; non-breaking. **NOT added to the page fingerprint** → no reference cascade.
**Companion to:** DR-020 (Universal Content Template Standard — §4.5.4 extends its §4.5.3; this DR does **not** reopen the locked DR-020), DR-019 (Schema emission AI-only — FAQ floor logic post-rich-results), DR-031 (Audience-first authoring — routing serves human + AI simultaneously).
**Scope:** **UNIVERSAL** — additive, non-breaking. **Zero brand-side action required.** Every existing page inherits `intent_source_tier='template_only'` + `paa_checked_at=NULL` and behaves identically to pre-DR-034 until a PAA crawl runs.

**Context:**

Operator review (2026-06-03) flagged a **PAA × FAQ overlap concern** before real content production began: People-Also-Ask demand signals and the B18 FAQ block both answer questions, with two failure modes — (a) **tail-wagging-the-dog**, where PAA dictates page structure instead of serving the locked template, and (b) **body/FAQ duplication**, where the same question is answered twice on one page. §4.5.3 (Cannibalization Shield) already governs separation *between* sibling pages but said nothing about separation *within* a single page.

The proposal arrived as a 4-part patch authored against an **older repo snapshot** (targeted "schema v1.11" and treated DR-020 as still-proposed with a 2026-06-07 lock). Reconciliation against the live repo found three stale anchors and three phantom data sources — all corrected before landing (see Consequences → Reconciliation).

**Decision:**

Adopt **§4.5.4 Intra-Page Answer Routing** with five rules + a 2-column page_master extension:

1. **PAA subordination (Q1 = B → separate §4.5.4):** PAA is *demand evidence*, not structure. PAA may not create a top-level H2 absent from the template, may not delete/shrink/replace a REQUIRED block, and need not be answered exhaustively. Relevant PAA lands as H3 inside the nearest required block; cross-intent PAA routes to FAQ + links out per §4.5.3.
2. **Routing by intent:** understanding-intent PAA (What/Why/How/Can/Is) → **body** (H2/H3 in a required block, 40–60-word direct answer up top, featured-snippet-ready); decision-intent PAA (Cost/Where/Who/Book/vs/How-long) → **FAQ block (B18)**.
3. **Dedup gate:** one question = one canonical answer location per page. If answered in body, no duplicate FAQ entry — FAQ may reference the body via a short anchor link.
4. **Coverage floor (Q2 = B + safety floor):** measure intent coverage at **page level (≥8 intents across body PAA-mapped + FAQ combined)**, not at the FAQ block. FAQ keeps a **safety floor of ≥3 Q&A**. Tier-1 (PAA present): FAQ ≥3 (understanding-PAA lives in body); tier-2/3 (no PAA): FAQ ≥8 (FAQ carries all coverage).
5. **3-tier source fallback (Q3 = A → generic field naming):** `tier_1_paa` (real PAA) → `tier_2_derived` (painpoint / predicted SERP / voice) → `tier_3_template_only` (8-intent baseline; sets `content_gap_flag`). Recorded per page via `intent_source_tier` + `paa_checked_at`.

**Rationale:**

- **PAA subordinate, not sovereign** — the locked T1–T22 template structure (DR-020) is the contract; PAA confirms/prioritizes/surfaces-gaps within it. Letting PAA mint sections would silently erode the Cannibalization Shield and EEAT layout guarantees.
- **Page-level coverage is the correct unit** — most PAA *confirms* body sections rather than migrating into FAQ. A high FAQ-block floor would force understanding-PAA into FAQ as a duplicate of body. Measuring at page level (with a ≥3 FAQ safety floor) avoids that distortion — this is *why* Q2 = B over a flat FAQ floor.
- **`paa_checked_at` separates "checked, none found" from "never checked"** — NULL triggers a crawl; SET-with-empty-`paa_questions` legitimately drops to tier-2/3. Collapsing them would either skip real PAA or waste crawls.
- **Generic field naming (Q3 = A)** — `intent_source_tier` is vocabulary-neutral, so future signal sources slot in without a schema rename.

**Consequences:**

- ✅ **Migration BUILT 2026-06-03 (`eywa_w11_05`):** `ALTER TABLE seo_website_page_master ADD COLUMN intent_source_tier … ADD COLUMN paa_checked_at …` (+ CHECK + bilingual comments). Verified live: 88 → 90 cols; CHECK `seo_website_page_master_intent_source_tier_check` present; 1,376 existing rows default to `template_only`. Schema_Overview bumped → v1.20. Post-DDL security advisors: no new findings tied to the change.
- ✅ **B18 FAQ floor is now tiered** (Content_Templates §2.5): ≥3 when PAA present (understanding moves to body), ≥8 when no PAA. Page-level ≥8-intent requirement holds across all tiers.
- 🔧 **Reconciliation from the original proposal (corrected before landing):**
  - Stale anchors fixed — "schema v1.11" → **v1.20**; "DR-020 pending 2026-06-07" → DR-020 **already Locked 2026-05-12**, so this lands as **new DR-034** (does not reopen the locked DR); "no DDL until v1.11" → DDL built at v1.20.
  - Phantom columns re-mapped to the audited schema — proposal's `people_also_ask_json` / `paa_ai_content_json` / `related_searches` **do not exist**. Real PAA lives in **`seo_x_ads_keyword_serp_competitors.paa_questions text[]`**; derived signals use **`keyword_painpoint`** + **`predicted_serp_features`** (`seo_x_ads_keywords_contextual_master`) + **`seo_x_voice_search`** (incl. `is_in_pasf` as the related-searches analog); `content_gap_flag` (entity graph) for tier-3.
- 📋 **Out of scope / follow-ups:** (a) PAA crawl wiring — n8n flow to populate `paa_checked_at` + `paa_questions` and set `intent_source_tier`. (b) Optional AI-generated PAA source (the proposal's `paa_ai_content_json`) — only if/when a PAA-AI ingest is built; not today. (c) Per-page QA automation of the §4.5.4 dedup gate.
- ⚠️ **No existing content needs rework** — DR-034 governs how *new* pages route PAA; published pages retrofit at next freshness review when a PAA crawl runs.

**References:**

- Content_Templates §4.5.3 (Cannibalization Shield, the between-page parent), §4.5.4 (this DR), §2.5 B18 FAQ block.
- `seo_x_ads_keyword_serp_competitors.paa_questions text[]` (PAA source, §6.3); `seo_x_ads_keywords_contextual_master.keyword_painpoint` / `predicted_serp_features` (§6.1); `seo_x_voice_search.is_in_pasf` (§6.4); `seo_entity_graph.content_gap_flag`.
- DR-020 (template standard, locked 2026-05-12), DR-019 (schema emission AI-only), DR-031 (audience-first authoring), DR-030 (deferred-migration / retrofit-at-next-gate precedent).

---

### [DR-033] — ICD Dual-Coding Standard (ICD-11-MMS Primary + ICD-10 / ICD-10-CM Full Coverage) (2026-06-02 → Locked 2026-06-02) 🔒🩺🌐

**Status:** **🔒 Locked 2026-06-02** — operator-approved in working session same day (14-day review waived: additive/non-breaking, no other medical-condition brand mid-build to canvass, and the change *aligns the spec with the existing entity-fingerprint intent*, which already keys on the WHO-base value `g47.3` not the US-CM `g47.33`).
**Bible Reference:** Entity Graph schema emission (`MedicalCondition.code[]` doctrine) + T1 medical-condition template — codingSystem standardization. Bible-prose propagation deferred to next Bible release; Handover + this DR carry operational guidance meanwhile.
**Schema Reference:** **BUILT 2026-06-02** — migration `eywa_w11_04_dr033_v19_icd_dual_coding_condition` (W11.4) adds **`seo_entity_condition.icd11_code text`** (ICD-11-MMS, primary) + **`seo_entity_condition.icd10_cm_code text`** (US ICD-10-CM) and clarifies the `icd10_code` comment (WHO base). **Schema_Overview → v1.19** (file renamed `…v1_18.md` → `…v1_19.md`). Additive, nullable, non-breaking. Columns follow the table's existing `icd10_code` (no-underscore) naming. **NOT added to the entity fingerprint** (`seo_entity_graph.icd_10_code`, WHO base, unchanged) → no reference cascade. *(Build note: the initial draft below targeted `seo_entity_graph`; the live audit showed the per-condition medical coding set lives on the `seo_entity_condition` extension — alongside `snomed_ct_id`/`mesh_id`/`umls_cui` — so the new columns landed there. `seo_entity_graph.icd_10_code` remains the universal entity code + fingerprint key.)*
**Companion to:** DR-031 (Google Generative AI Search Alignment — ICD codes serve AI/LLM entity grounding, not Google rich results), DR-019 (Schema Two-Purpose Taxonomy), DR-009 (Multilingual Strategy — codes are `never_translate` universals)
**Scope:** **UNIVERSAL** — every brand emitting `MedicalCondition` schema. **Zero brand-side action required.** Existing condition entities retrofit (verify `icd_10_code` = WHO base + optional `icd_10_cm_code` backfill) at next freshness review.

**Context:**

Operator asked (2026-06-02) whether EYWA's ICD-10 references in schema should migrate to ICD-11, stay ICD-10, or carry both during the transition. Research findings (June 2026):

- **WHO ICD-11** has been in effect since **2022-01-01**; WHO **stopped maintaining ICD-10 in 2018**. ~132 member states are at some implementation phase; ~45 have begun transition; 14 already report in ICD-11. ICD-11 is the unambiguous future.
- **Thailand** (EYWA's home market) is named among the **front-runner ICD-11 adopters** (with Canada, Netherlands, Norway, Finland) — but national reimbursement still runs on **ICD-10-TM** (a WHO-base ICD-10 Thai modification).
- **United States** still runs **ICD-10-CM**, with no firm ICD-11 date (projected ~2027–2029 for billing). EN/US data + AI consumers still "speak" ICD-10-CM.
- **schema.org** `MedicalCode.code[]` is an **array**; `codingSystem` is **free-text controlled vocabulary**; Google does **not validate** it and there is **no penalty** for multiple systems. `MedicalCondition` is **not a Google rich-result type** → ICD codes primarily serve **AI/LLM/Knowledge-Graph entity grounding** (ties to DR-031), where broader, accurate coverage is strictly better.

Audit of the spec found the doctrine was **half-implemented and inconsistent**: `codingSystem` written three ways (`"ICD-10"`, `"ICD-10-CM"`, `"ICD-11"` vs `"ICD-11-MMS"`); the PHP renderer mislabeled the base `icd_10_code` field as `"ICD-10-CM"`; the skeleton template emitted no ICD-11 at all; and TH-market examples carried **US-CM codes mislabeled as base ICD-10** (e.g. OSA `G47.33` and TMJ `M26.6`, which are US-CM — the WHO/TH base codes are `G47.3` and `K07.6`).

**Decision:**

1. **Dual / full coverage, not migration.** Emit **all available** codes in `MedicalCondition.code[]`, ordered **ICD-11-MMS → ICD-10 (WHO base) → ICD-10-CM (US) → SNOMED-CT**. ICD-11-MMS leads as the forward-primary; ICD-10 is retained throughout the transition.
2. **Standardized `codingSystem` strings:** `"ICD-11-MMS"`, `"ICD-10"`, `"ICD-10-CM"`, `"SNOMED-CT"`.
3. **Column semantics:** `icd_10_code` = **WHO base ICD-10** (= ICD-10-TM aligned, accurate for TH); new optional **`icd_10_cm_code`** = **US ICD-10-CM** clinical modification (more granular; for EN / international SEO). `icd_11_code` = **ICD-11-MMS stem code**.
4. **Why full coverage for TH brands:** operator confirmed EN + international-market SEO is a near-term goal → "capture everything" is the intent. Because `code[]` is additive with zero downside, carrying ICD-11 + base ICD-10 + US-CM + SNOMED maximizes entity grounding across TH, EN, and international AI/search consumers.

**Rationale:**

- **Transition is real and bidirectional** — can't drop ICD-10 (US + TH reimbursement still consume it) and shouldn't lead with ICD-10 (WHO froze it in 2018; TH is an ICD-11 front-runner). Carrying both, ICD-11 first, is the only forward-correct stance.
- **Zero technical downside** — array + free-text codingSystem + no Google validation = pure upside to breadth.
- **Correctness matters more than it looks** — labeling a US-CM code as base `"ICD-10"` on a Thai page is factually wrong. The base-vs-CM split is real: OSA `G47.3` (WHO/TH) vs `G47.33` (US-CM); TMJ `K07.6` (WHO/TH) vs `M26.6` (US-CM) — verified `K07.6` does not exist in ICD-10-CM (US moved it to `M26.6x`). ICD-11 unifies both (OSA `7A41`, TMJ `DA0E.8`).
- **Aligns with existing intent** — the entity-fingerprint example already uses WHO-base `g47.3`, so this DR ratifies the design rather than redirecting it.

**Consequences:**

- ✅ Additive, non-breaking; migration deferred to next wave; fingerprint unchanged → no reference cascade.
- ⚠️ **Existing condition entities** — at next freshness review, verify `icd_10_code` holds the **WHO base** value (not a US-CM code) and optionally backfill `icd_10_cm_code`. Same retrofit-at-next-gate posture as DR-029/DR-030.
- ✅ **Migration BUILT 2026-06-02 (`eywa_w11_04`):** `ALTER TABLE seo_entity_condition ADD COLUMN icd11_code text, ADD COLUMN icd10_cm_code text;` (+ column comments). Schema_Overview bumped → v1.19. **Remaining WP-side task:** add ACF field `icd_10_cm_code` (and confirm `icd_11_code`) on the condition page template so the JSON-LD renderer populates it — WordPress/ACF, not DB.
- 📋 **Out of scope / follow-ups:** (a) property-name normalization — examples mix non-standard `"code"` with schema.org-canonical `"codeValue"` inside `MedicalCode`; orthogonal to ICD versioning → separate DR. (b) Optional ICD-11 **Foundation URI** as `sameAs` for tighter AI grounding — nice-to-have, future. (c) SNOMED label `"SNOMED-CT"` left as-is (already internally consistent; schema.org prefers `"SNOMED CT"` — defer).
- 🗂️ **Files updated this commit:** `examples/T1-osa-vth-biodent-WORKED-EXAMPLE.md` (table + JSON-LD), `examples/T1-medical-condition-SKELETON.md` (table + JSON-LD), `EYWA_PROTOCOL_v3_14.md` (`seo_entity_graph` DDL, PHP schema renderer reorder+relabel+`icd_10_cm_code`, entity validation rule, content checklist, ACF Schema tab, `never_translate` list, 3 TMJ JSON-LD snippets), `Content_Templates_EYWA_v1_0.md` (technical-codes toggle order), `EYWA_HANDOVER.md` (entity-register `ICD-11 / ICD-10` column + spec + TMJ examples). **Follow-up build commit (2026-06-02):** live migration `eywa_w11_04` + `Schema_Overview_EYWA_v1_19.md` (renamed from v1_18; §11.5 condition columns + `icd_10_code` note corrected to point at `seo_entity_condition` + v1.19 changelog) + `migrations/README.md` (Wave 11 manifest) + `EYWA_PROTOCOL_v3_14.md` (entity_graph DDL corrected — codes moved off the universal table) + README/PHASE_1 schema-version refs.

**References:**

- WHO — ICD-11 in effect 2022-01-01; ICD-10 maintenance ceased 2018 ([WHO ICD-11 FAQ](https://www.who.int/standards/classifications/frequently-asked-questions/icd-11-implementation), [WHO ICD-11 fact sheet](https://www.who.int/news-room/fact-sheets/detail/icd-11))
- Thailand ICD-11 front-runner + ICD-10-TM (WHO-based) — [MedLearn ICD-11 in 2025](https://icd10monitor.medlearn.com/icd-11-in-2025-evolution-global-progress-and-what-to-watch/), [ICD-10-TM (PubMed)](https://pubmed.ncbi.nlm.nih.gov/22935742/)
- US still ICD-10-CM (~2027–2029 for ICD-11 billing) — [Libman Education US timeline](https://libmaneducation.com/us-timeline-for-icd-11-implementation/)
- schema.org — [MedicalCode](https://schema.org/MedicalCode), [MedicalCondition](https://schema.org/MedicalCondition)
- Verified code mappings: OSA `G47.3` (WHO) / `G47.33` (CM, valid) / `7A41` (ICD-11-MMS); TMJ `K07.6` (WHO; not in CM) / `M26.6`·`M26.609` (CM, valid) / `DA0E.8` (ICD-11-MMS)
- DR-031 (AI search alignment), DR-030 (deferred-migration precedent), DR-019 (schema taxonomy), DR-009 (multilingual `never_translate`)

---

### [DR-032] — Multi-Center Hospital Brand Pattern (2026-05-25 → Locked 2026-05-25) 🔒🏥🗂️

**Status:** **🔒 Locked 2026-05-25** — operator-approved same day as proposed (14-day review waived; no other multi-center brand currently in portfolio to canvass; Vitality opt-in early already proved pattern viability through full Phase A authoring + master/hospital-wide sitemap; doctrinal urgency on Vitality timeline)
**Bible Reference:** New **Section 25.13 — Multi-Center Brand Architecture** (✅ propagated to Bible §25.13 in v3.24, 2026-06-03; Handover v1.18 §1.3 carries the operational onboarding); extends Part 25 (Multi-Brand Federation), Part 26 (WordPress + Elementor Stack), Part 28 (Multilingual Strategy)
**Schema Reference:** Target **v1.18** (Wave 11 → v1.17 already pending separately; v1.18 = DR-032 additions) — adds 1 new table + 2 new optional columns + 1 brand-level enum field. **Migration scripts pending** — additive, non-breaking; can land at next Phase 1A.4 wave.
**Handover Reference:** **v1.18** — Section 1.3 now includes `brand_structure` as upfront brand context (monolithic | multi_center); `NEW_BRAND_BOOTSTRAP.md` Step 1.5 documents the decision; `brand-config.template.json` includes the field with both-option comments
**Companion to:** DR-001 (Multi-Brand Federation Pattern), DR-004 (URL Structure: Subdirectory + Thai Default), DR-010 (Brand Scope Architecture), DR-021 (Internal Linking Architecture HYBRID)
**Scope:** **UNIVERSAL** — additive, non-breaking. Existing brands inherit default `brand_structure=monolithic` and operate identically to pre-DR-032 behavior. Only brands explicitly opting into `brand_structure=multi_center` use the new fields.
**First adopter:** `vitality-hospital` brand (opt-in early at proposal 2026-05-25; on lock same day, forward-looking fields become canonical; `drs_proposed_opted_in_early: ["DR-032"]` cleared at next brand-config bump)

**Context:**

A new brand entered the portfolio on 2026-05-25 — **Vitality Hospital** — positioned as "the first Sleep, Brain & Wellness Hospital." The brand doctrine, verbatim from the operator's Notion master plan, requires architectural unity across 7 productized centers:

> "a **single integrated hospital under one roof, one record, one team**"
>
> "**No center invents parallel terms.**" (locked vocabulary across all centers)
>
> "Every sister hospital that writes into **the Vital Twin** makes Vitality more valuable to every other patient."

The 7 centers are:

1. Vital Sleep Center
2. Vital Sleep Intimacy
3. Vital Breathing & Myofunctional Center
4. Vital Facial Pain & Teeth Grinding Center
5. Vital Wellness & Lifestyle Medicine Center
6. Vital Effortless Weight Loss Center
7. Vital Brain Center

Each center has its own positioning, hero programs, signature trademarks (™), pricing tier, patient archetypes, and visual sub-treatment. But all 7 share: brand identity (Vitality Hospital), data spine (The Vital Twin™), operating method (The Vital Loop™), vocabulary (locked master glossary), MDT staff (one team), and SEO authority (one domain).

**Operator vision:** `vitalityhospital.com` as the umbrella; each center surfaced as a URL subdirectory (`/vitalsleep/`, `/vitalintimacy/`, `/vitalbreathing/`, etc.) on a single WordPress site — each center "looks like" its own site with own menu and own story, but all under one umbrella shell.

**EYWA Protocol gap:** existing patterns assume each brand = its own frontend (DR-001 Federation, DR-004 URL Structure subdirectory-by-language-only, DR-010 Brand Scope per-brand). Three architectural options were evaluated:

| Option | Description | Verdict |
|---|---|---|
| **A** | 1 WP site, "center" as taxonomy/section, no spec change (use brand-config metadata only) | Works, but loses cross-brand governance; no schema-enforced center scoping |
| **B** | WordPress Multisite (WPMU) — 1 main + 7 subsites | Contradicts "one record one team"; Vital Twin spine becomes a sync problem; 7× ops cost |
| **C** | 7 separate EYWA brands sharing brand_scope[] for cross-center entities | Architecturally lies about brand reality; every cross-center entity/link triggers DR-021 cross-brand governance; locked-vocabulary discipline becomes cross-brand sync |
| **D** ⭐ | 1 EYWA brand + center subdivision as a new dimension in schema + URL pattern | Matches brand doctrine; minimal additive schema; preserves all existing federation/governance |

Operator confirmed Option D (Hybrid): *"core ของ eywa protocol ยังเหมือนเดิม เพียงแต่เราขยายวิธีการบริหารจัดการสำหรับแบรนด์ที่จะมีหลาย centers ภายใต้แบรนด์เดียว."*

This DR formalizes Option D as a universal pattern — because Vitality is unlikely to be the only multi-center brand in the portfolio (VTH BioDent → potential VTH Hospital expansion path; `the-face-hospital` is already a hospital; future portfolio additions may follow).

**Decision:**

Introduce a universal **Multi-Center Brand Pattern** via 7 coordinated sub-decisions, all locked together at DR-032 lock event. Pattern is **opt-in per brand**; existing brands unaffected.

#### 1. Add `brand_structure` enum on `brands` table

```sql
ALTER TABLE brands
  ADD COLUMN brand_structure text NOT NULL DEFAULT 'monolithic'
    CHECK (brand_structure IN ('monolithic', 'multi_center'));
```

- `monolithic` — default; all existing brands inherit. No behavioral change.
- `multi_center` — opt-in; activates center subdivision schema + URL rewriting + plugin behaviors.

#### 2. New table `seo_brand_centers`

One row per center within a multi-center brand. ~15 columns covering identity, URL routing, positioning, visual treatment, and lifecycle.

```sql
CREATE TABLE seo_brand_centers (
  fingerprint              text UNIQUE NOT NULL,    -- 'ctr_{ULID16}' per DR-008
  fingerprint_display_name text NOT NULL,           -- '{fp_last_6}::{brand_slug}::{center_slug}'
  brand_id                 text NOT NULL REFERENCES brands(brand_slug) ON DELETE CASCADE,
  center_slug              text NOT NULL,           -- 'vital-sleep'
  center_name              jsonb NOT NULL,          -- {"th":"...", "en":"..."} per DR-009 Tier 1 multilingual
  url_segment              text NOT NULL,           -- 'vitalsleep' (URL-safe, may differ from center_slug)
  positioning_one_line     jsonb,                   -- {"th":"...", "en":"..."}
  signature_methodologies  text[],                  -- ['Sleep Restoration Program', 'Couples Sleep Twin']
  color_treatment_hex      text,                    -- visual signal for header band etc.
  position_order           integer NOT NULL DEFAULT 0,  -- nav order
  status                   text NOT NULL DEFAULT 'planning'
    CHECK (status IN ('planning', 'active', 'paused', 'sunset')),
  anchor_outcome           text,                    -- "ISI ≥ 7-point reduction; AHI normalization on PAP / oral appliance"
  created_at               timestamptz NOT NULL DEFAULT now(),
  updated_at               timestamptz NOT NULL DEFAULT now(),
  UNIQUE (brand_id, center_slug),
  UNIQUE (brand_id, url_segment)
);
```

Triggers per DR-008 (Two-Column Identity): `trg_set_fingerprint_center` on INSERT; `trg_refresh_display_name_center` on UPDATE; `trg_prevent_fingerprint_change_center` on UPDATE.

#### 3. New column `seo_website_page_master.center_slug text NULL`

```sql
ALTER TABLE seo_website_page_master
  ADD COLUMN center_slug text NULL
    REFERENCES seo_brand_centers(center_slug);  -- soft FK; or use brand_id+center_slug composite
```

- `NULL` = umbrella/hospital-wide page (Home, About, Concept, Method, Membership, Outcomes Book)
- `'vital-sleep'` = page belongs to Vital Sleep Center (URL: `/vitalsleep/{slug}/`)
- Validation trigger: `center_slug` MUST be NULL when `brand.brand_structure='monolithic'`; MAY be NULL when `'multi_center'`.

#### 4. New column `seo_entity_graph.center_scope text[]`

```sql
ALTER TABLE seo_entity_graph
  ADD COLUMN center_scope text[] NULL;
```

Orthogonal to existing `brand_scope text[]`. Examples:

| Entity example | brand_scope | center_scope | Interpretation |
|---|---|---|---|
| `obstructive-sleep-apnea` | `['vitality-hospital']` | `['vital-sleep']` | OSA primary entity owned by Vital Sleep Center |
| `osa-obesity-bundle` | `['vitality-hospital']` | `['vital-sleep','vital-weight-loss']` | Cross-center joint product |
| `nightlase` | `['vitality-hospital','vth-biodent']` | `['vital-sleep']` (within Vitality) | Cross-brand entity, scoped to Vital Sleep within Vitality |
| `circadian-hospital-concept` | `['vitality-hospital']` | `NULL` | Hospital-wide umbrella entity |
| `dental-implant` | `['vth-biodent']` | (N/A — vth-biodent is monolithic) | Pre-DR-032 behavior; center_scope NULL |

#### 5. URL pattern lock (extends DR-004)

When `brand_structure='multi_center'`:

```
{brand_domain}/{lang}/{center_url_segment}/{page_slug}/
                    ^                    ^
                    |                    |- center_slug → url_segment (vitalsleep, vitalintimacy, ...)
                    |- language (DR-004; th=default, en/zh/ar/etc.)
```

When `brand_structure='monolithic'`:

```
{brand_domain}/{lang}/{page_slug}/    (unchanged DR-004 behavior)
```

`url_segment` is operator-controlled per center (does not need to match `center_slug`); enforced UNIQUE per brand. App-layer routing must reserve known center segments to prevent slug collisions with non-center pages.

#### 6. Internal linking governance (extends DR-021)

| Link type | Governance |
|---|---|
| Intra-center (within same center) | Default approved — no per-link justification |
| Intra-brand cross-center (e.g., Vital Sleep → Vital Brain within Vitality) | **Default approved** — no per-link justification. Recorded in `seo_page_internal_links` with `link_type='cross_center_intra_brand'` for analytics, but not gated. |
| Cross-brand (Vitality ↔ Biodent within Vertex network) | Existing DR-021 governance applies — `is_cross_brand=true` + `cross_brand_justification` required |

Rationale: per the Notion source, cross-center "Funnels in / Funnels out" are first-class structural elements (e.g., Vital Sleep → Vital Breathing → Vital Brain → Vital Sleep Intimacy → Biodent). Making them exception-gated would force every clinical referral into a justification field.

#### 7. WordPress implementation pattern (Bible Part 26)

Specify in Bible §25.13 (post-lock):

- **Single WordPress site** (NOT WPMU/Multisite)
- **Custom taxonomy `center`** (attached to existing EYWA CPTs: procedure, treatment, condition, doctor, branch, etc.)
- **ACF field group** for center config (color, icon, hero image, signature methodologies)
- **Elementor Theme Builder** conditional templates per `center` taxonomy term (header band color, footer note, etc.)
- **Permalink rewrites** to map `/{url_segment}/{post_type}/{post_slug}/` to taxonomy-filtered queries
- **Hospital-wide nav** (top-level) + **center context nav** (secondary, shown when in a center subdirectory)
- **Schema markup:** `Hospital` (umbrella) + `MedicalSpecialty` (per center) + page-type schema per page
- **Cross-network sister-brand links:** standard hyperlinks, no canonical issues (different domains)

**Rationale:**

1. **Doctrinal alignment is non-negotiable** — Vitality's "one hospital, one record, one team" mandate cannot be honored by splitting into 7 brands (Option C). Splitting forces every shared entity into cross-brand sync (DR-021 governance overhead per link), every locked vocabulary term into cross-brand dictionary sync, and every Vital Twin write into a multi-brand data federation problem. Doctrine wins.

2. **Pattern is reusable across portfolio** — Hospital-scope brands are a recognizable class (`the-face-hospital` already exists; VTH BioDent's expansion path includes potential hospital status). Formalizing as universal DR pays compounding interest vs brand-specific workaround.

3. **Additive non-breaking design** — Every change defaults to existing behavior. `brand_structure='monolithic'` is the default; `center_slug=NULL` is allowed everywhere; `center_scope=NULL` is allowed everywhere. Existing brands deploy unchanged at next migration wave. Zero data migration required.

4. **Subdirectory beats subdomain for SEO** — `vitalityhospital.com/vitalsleep/` inherits full domain authority; subdomains split it. Operator confirmed subdirectory pattern from the outset.

5. **Subdirectory beats WPMU for ops** — single WP admin, single Elementor license, single GSC property, single analytics, single update cycle, single security surface. WPMU = 7× operational cost for no proportionate benefit when the data spine (Vital Twin) wants to be unified anyway.

6. **Cross-center funnels are first-class** — Notion explicitly structures each center with "Funnels in / Funnels out" sections. The schema must support this as default behavior, not as exception requiring per-link governance.

7. **EYWA core untouched** — Federation pattern (DR-001), brand_scope semantics (DR-010), edge vocabulary (DR-012/013/014), Two-Column Identity (DR-008), Multilingual v2 (DR-009), Internal Linking (DR-021), EUG (DR-011), all unaffected. This is purely additive at the boundary between "1 brand" and "what's inside 1 brand."

8. **Operator's mental model matches** — Quoted verbatim 2026-05-25: *"core ของ eywa protocol ยังเหมือนเดิม เพียงแต่เราขยายวิธีการบริหารจัดการสำหรับแบรนด์ที่จะมีหลาย centers ภายใต้แบรนด์เดียว และต้องยกแต่ละ center ขึ้นเป็น subdirectory สำหรับบริหารจัดการ บน wordpress เดียวกันภายใต้แบรนด์ใหญ่แบรนด์เดียว."*

**Consequences:**

- ✅ Vitality Hospital can author content, plan sitemap, and structure entities under correct architecture from Day 1
- ✅ Existing brands (`vth-biodent`, `smile-scape`, `the-face-by-vertex`, all 17 brand repos) unaffected — `brand_structure` defaults to `'monolithic'`, all queries continue working
- ✅ Schema migrations are additive — 1 ALTER TABLE (brand_structure column) + 1 CREATE TABLE (`seo_brand_centers`) + 2 ADD COLUMN (`center_slug`, `center_scope`) + triggers. No data migration; no rollback complexity.
- ✅ Plugin updates required but scoped: `eywa-schema-pipeline` adds `center_slug` awareness; `eywa-acf-fields` adds `center` taxonomy; new ACF field group for center config. Estimated 8–12 engineering hours total.
- ✅ WordPress implementation pattern documented in Bible §25.13 — single source of truth for multi-center brand build
- ⚠️ **Vitality opt-in early creates DR-032-pending state** — `vitality-hospital/brand-config.json` uses forward-looking fields (`brand_structure: multi_center`, `centers[]` array, `parent_network` block) that are advisory metadata until DR-032 locks. Config flagged accordingly with `_brand_structure_doc` notes.
- ⚠️ **WordPress implementation cannot begin until DR-032 locks** — theme work, ACF field groups, URL rewrites all depend on locked schema. Vitality Phase A (brand-concept, signature-programs, per-center concepts) + Phase B (research, keyword seeds) + Phase C (entity planning at markdown level) can proceed in parallel during review period.
- ⚠️ **Sister-brand cross-network linking pattern needs documentation** — Vitality references Biodent (NightLase, Waterlase) and other Vertex sister brands. DR-021 already covers cross-brand link governance; DR-032 §6 clarifies the boundary (intra-brand cross-center = default approved; cross-brand-network = DR-021 governance). Sister brands not opt-in early; they remain `monolithic`.
- ⚠️ **Multilingual interaction with DR-004** — Language segment must come BEFORE center segment in URL (`/th/vitalsleep/`, not `/vitalsleep/th/`). Document explicitly to avoid permalink confusion.
- ⚠️ **No retro-active migration for existing brands** — If `vth-biodent` later opts in to `multi_center` (e.g., becomes VTH Hospital), that's a brand-level decision logged in `vth-biodent/docs/decision-records.md` as a brand DR; no schema work required.

**Open Questions (resolve before lock):**

1. **Soft FK vs hard FK on `seo_website_page_master.center_slug`** — Hard FK (`REFERENCES seo_brand_centers`) gives integrity but couples migration order; soft FK (text-only) gives flexibility but requires app-layer validation. Lean toward hard FK with composite `(brand_id, center_slug)`.
2. **Storage decision: separate `seo_brand_centers` table vs jsonb on `brands`** — Table is more SQL-queryable (joins, aggregations, RLS); jsonb is denser. Lean toward table (matches EYWA pattern of breaking concerns into discrete tables).
3. **`url_segment` length / character constraints** — Reserve a list of forbidden segments (`api`, `wp-admin`, `wp-json`, `feed`, locale codes `th`/`en`/etc., common page slugs `about`/`contact`) to prevent collision.
4. **Should `seo_brand_doctors` and `seo_brand_branches` also get a `center_slug`?** — A doctor might primarily practice at one center (Dr. Amornpong → Vital Brain); a branch might house multiple centers initially but become center-specific later. Lean toward adding `center_scope text[]` (multi-value, allow doctor across centers) for consistency.
5. **Cross-network DR follow-up** — Vitality's Vertex network membership (Genowell, Recov, VTH PRM, Biodent, The FACE all share Vital Twin per Notion) hints at a higher-order pattern (network-of-brands, not just brand-of-centers). Out of scope for DR-032; may motivate future DR-033+.
6. **Backfill timing for `brand_structure` default** — On migration, all existing brands get `brand_structure='monolithic'` automatically via DEFAULT clause. Confirm no brand wants opt-in at migration time (only Vitality currently).

**References:**

- DR-001 — Multi-Brand Federation Pattern (extends, does not supersede)
- DR-004 — URL Structure: Subdirectory + Thai Default (extends with center segment after language segment)
- DR-008 — Two-Column Identity Pattern (`seo_brand_centers` follows the same fingerprint pattern)
- DR-009 — Multilingual Strategy v2 (Tier 1 jsonb for center names + positioning)
- DR-010 — Brand Scope Architecture (orthogonal to new `center_scope`; brand_scope unchanged)
- DR-021 — Internal Linking Architecture HYBRID (cross-center intra-brand = no governance; cross-brand still governed)
- DR-028 — Brand Genesis Protocol Universal (BGP may need a multi-center variant for hospital brands — defer)
- DR-029 — Universal Brand Design System (per-center color treatment fits in `seo_brand_centers.color_treatment_hex` + DTCG tokens)
- Bible Part 25 (current) — Multi-Brand Federation
- Bible Part 26 (current) — WordPress + Elementor Stack (will add §25.13 post-lock)
- Bible Part 28 (current) — Multilingual Strategy (DR-004 extension documented here)
- External: [`eywa-vitality-hospital/brand-config.json`](https://github.com/the-gifted-digital/eywa-vitality-hospital/blob/main/brand-config.json) — first opt-in adopter, forward-looking fields flagged
- External: [Vitality Hospital Notion master](https://www.notion.so/marketing-vt-intelligent/Vitality-Hospital-d85dc4e216898244b8f881d83ffb3ebc) — brand doctrine source ("one roof, one record, one team"; "No center invents parallel terms")

---

### [DR-031] — Google Generative AI Search Alignment (llms.txt + Chunking + Query Fan-out Framing) (2026-05-24) 🔒🔍📐

**Status:** **Locked 2026-05-24** (operator-approved — triggered by Google Search Central guidance "Mythbusting generative AI search" + "Is SEO still relevant for generative AI search?" published 2026-05)
**Bible Reference:** Part 1 §1.3 (SEO 2026 Layer Model) + §1.5 (Update Principles, new Principle 6 §1.5.1) + Part 13 §13.13 (Predicted Prompts ↔ Query Fan-out) + Part 13 §13.17 §4 (llms.txt enhancement) + Part 21 §21.2 (Chunking Strategy) — framing/terminology updates only
**Schema Reference:** **None** — pure spec-level reframing, no DDL changes, no migration. Optional follow-up: `COMMENT ON TABLE seo_predicted_prompts` (single non-blocking statement, can ride next migration wave)
**Companion to:** DR-018 (Word Count Standards — supports chunking scope clarification), Bible §1.5 (AEO+GEO+SEO+LLMO Update Principles — extended with Principle 6)
**Scope:** **UNIVERSAL** — applies to all brands using EYWA Protocol; framing affects how operators + content teams + AI agents reason about AI-search infrastructure priorities. **Zero brand-side action required** — existing content + infrastructure continues operating unchanged.

**Context:**

Google Search Central published clarifying guidance (2026-05) on generative AI search misconceptions. Three statements have direct implications for how EYWA Protocol Bible positions its GEO/LLMO recommendations:

1. **"LLMS.txt files and other 'special' markup … You don't need to create new machine readable files, AI text files, markup, or Markdown to appear in generative AI search."** — Google explicitly does not consume `llms.txt`. EYWA Bible §13.17 positioned `llms.txt` (+ `llms-full.txt` + `llms-agent.txt`) at **🔴 Critical 2026** priority alongside Schema and Citable Content. This priority labeling implied Google ranking impact, which is factually incorrect post-clarification.

2. **"'Chunking' content … There's no requirement to break your content into tiny pieces for AI to better understand it."** — EYWA Bible Part 21 §21.2 has detailed semantic chunking strategy (100-500 tokens, H2/H3 boundaries, 15-20% overlap). This is **internal RAG embedding strategy** (pgvector for our own brand chatbots + AI agent grounding) — but the term "chunking" without scope clarification risks misreading as "fragment page content for AI consumption", which would contradict EYWA's actual approach (long-form pillar pages 1,500-4,000+ words per DR-018 word count standards).

3. **"Query fan-out: A set of concurrent, related queries generated by the model to request more information…"** — Google formalized "query fan-out" as the official 2026 terminology for what EYWA calls **Predicted Prompts Bank** (Part 13.13, ≥15 per pillar across 8 intent types). The mechanism is identical; the naming divergence created onboarding friction for new operators familiar with industry terminology and for AI agents reading the Bible.

Additionally, Google's confirmation that **structured data is not required for generative AI** but **remains valuable for rich results** validates EYWA's existing positioning of Schema as Layer 2 SEO foundation (not Layer 3 GEO hack) — no change needed there. Google's stance on **inauthentic mentions** (counterproductive) aligns with EYWA's existing `seo_brand_mentions` table positioning (passive measurement, never seeking).

**EYWA's prior framing was reasonable pre-clarification** (Bible written 2026-Q1, before Google's explicit guidance). DR-031 brings the spec into alignment with the official terminology and removes outdated priority signals **without removing any EYWA capability** — every artifact, every table, every workflow continues operating.

**Decision:**

Apply five targeted framing/terminology updates to Bible v3.22 (→ v3.23). No schema changes, no operator workflow changes, no content rework required. Existing brand snapshots remain semantically valid.

#### 1. Reframe `llms.txt` priority (Bible Part 1 §1.3 Layer 3 GEO diagram)

**Before:** `Layer 3 GEO • llms.txt • Citable content • E-E-A-T entity → 🔴 Critical 2026` (single badge implies all elements equally critical for Google ranking)

**After:** Split into two priority rows:
- `Citable content • E-E-A-T entity • Schema → 🔴 Load-bearing`
- `llms.txt (non-Google AI engines only) → 🟡 Defensive¹` (with footnote linking to §13.17 reframe)

Rationale: Google does not consume llms.txt. Other GEO elements (Citable content, E-E-A-T, Schema) remain load-bearing for Google + non-Google AI engines.

#### 2. Extend Update Principles table with Principle 6 (Bible §1.5 + new §1.5.1)

**Add Principle 6: Audience-first authoring (DR-031, 2026-05-24)** — codifies existing EYWA practice (Citable Sentences + Perspective Layer serve humans AND AI simultaneously) as explicit decision heuristic for content tactic evaluation. Decision rule: "Does this serve a human reader?" before "Does this serve AI?"

**Light edits to existing Principles 4 + 5:**
- Principle 4 — clarify `llms.txt` scope (non-Google AI only)
- Principle 5 — clarify `seo_brand_mentions` is passive measurement (never seeking inauthentic mentions, per Google guidance)

**No removal** — table grows from 5 → 6 principles; existing 5 preserved.

#### 3. Add Query Fan-out cross-reference (Bible §13.13)

Insert terminology cross-reference at top of Predicted Prompts Methodology section: EYWA's Predicted Prompts Bank ≡ Google's official "query fan-out" (2026-05). Use **"query fan-out (Predicted Prompts)"** in external/agency documentation; preserve `seo_predicted_prompts` table name for schema stability.

**Coverage mechanism unchanged** — still ≥15 prompts/pillar across 8 intent types (informational, navigational, transactional, comparison, decision, troubleshooting, how-to, voice).

#### 4. Reframe llms.txt enhancement subsection (Bible §13.17 §4)

**Insert clarification statement above existing three-file pattern:**
- ✅ Keep `llms.txt` + `llms-full.txt` + `llms-agent.txt` as defensive infrastructure for non-Google AI engines
- ✅ Low-cost, low-priority maintenance
- ❌ NOT a Google ranking factor
- ❌ NOT a substitute for load-bearing artifacts (Citable Sentences, Schema, E-E-A-T)

**All file structure + recommendations preserved.** Re-elevation policy: if any major AI engine (or Google) announces load-bearing consumption, re-elevate priority via quarterly Bible §13.17 review.

#### 5. Add chunking scope clarification (Bible §21.2)

Insert scope clarification at top of Chunking Strategy section: chunking applies **exclusively to internal RAG embedding pipelines** (pgvector storage feeding own brand chatbots + AI agent grounding), NOT to published web page structure. Published pillar pages follow DR-018 word count standards (1,500-4,000+ words depending on Layer + topic depth).

**All chunking implementation details preserved** (100-500 token chunk size, H2/H3 boundaries, 15-20% overlap, embedding model selection table). Only adds scope guard to prevent misreading as page-structure prescription.

**Rationale:**

1. **Truthfulness over historical positioning** — Bible v3.21's "🔴 Critical 2026" labeling of `llms.txt` was best-guess pre-Google-clarification. Post-clarification, maintaining that priority would mislead operators into over-investing in a non-load-bearing artifact for Google ranking. Update reflects current evidence while preserving the file's defensive value for non-Google AI engines.

2. **Defensive value preserved (zero capability loss)** — `llms.txt` is not removed at any brand. ChatGPT, Claude, and Perplexity have varying degrees of opt-in to llms.txt conventions (industry not standardized as of 2026-05). The $0 marginal cost of maintaining three files justifies keeping them as defensive infrastructure. Removing entirely would forfeit non-Google AI surface area for zero savings.

3. **Chunking terminology disambiguation prevents future spec drift** — Without this clarification, a future operator or AI agent reading Part 21 in isolation could conclude "EYWA recommends chunking content into 500-token pages for AI". That would contradict DR-018 word count standards and produce thin-content SEO penalties. Scope note eliminates the ambiguity while preserving the full RAG embedding pipeline spec.

4. **Industry terminology alignment reduces onboarding friction** — New operators, agency partners, and AI assistants searching for "query fan-out optimization" should find EYWA's coverage mechanism. Currently they would find nothing because EYWA uses internal terminology only. Dual-naming policy (external "query fan-out (Predicted Prompts)" + internal `seo_predicted_prompts`) bridges both audiences.

5. **Audience-first principle codifies existing practice** — EYWA already practices audience-first content (Perspective Layer, Citable Sentences serve both humans and AI). Codifying it as Principle 6 makes the practice explicit and gives operators a decision heuristic for ambiguous content decisions ("optimize this for AI?" → No, optimize for the reader, AI alignment follows). This formalizes what was implicit.

6. **Zero schema/migration cost, zero brand-side action** — DR-031 is pure spec text. No DDL, no migration, no operator workflow change, no content rewrite, no brand notification beyond informational. Lowest-possible-risk landing.

7. **Validated against Google's 2026-05 official guidance** — Every framing change directly addresses a statement in Google Search Central's clarifications. No speculative interpretation; all changes traceable to specific Google statements (cited in References).

**Consequences:**

- ✅ Bible v3.22 → v3.23 framing aligns with Google's official 2026-05 guidance — no factual contradictions
- ✅ Operators stop over-investing in elaborate `llms.txt` variants; reallocate effort to Citable Sentences + Predicted Prompts (the load-bearing artifacts)
- ✅ Future operators + AI agents reading Bible reach correct conclusions about chunking scope (internal RAG vs page structure)
- ✅ External communication with SEO industry peers uses recognized terminology ("query fan-out") while preserving internal naming (`seo_predicted_prompts`)
- ✅ Principle 6 gives operators a clear heuristic for content decisions when AI-optimization temptations arise
- ✅ **All existing EYWA capabilities preserved** — RAG stack intact, llms.txt files retained, Predicted Prompts unchanged, Schema unchanged, every table semantically identical
- ✅ **Brand snapshots with `bible_version: 3.21` or `3.22` remain semantically valid** — framing/priority changes only, no normative requirements modified
- ⚠️ **No** existing brand content needs rework — DR-031 is framing-only
- ⚠️ **No** schema migration — `COMMENT ON TABLE seo_predicted_prompts` is the only optional DDL touch (can ride next migration wave)
- ⚠️ Bible version bumps to v3.23 — update version refs in EYWA_HANDOVER.md (done in same commit as DR-031)
- ⚠️ Slight communication risk: removing "🔴 Critical" from llms.txt might be misread by skim-readers as "remove llms.txt entirely" — DR-031 text + Bible reframe explicitly state **keep it, just deprioritize** to prevent that misreading

**Open Questions (operator decisions over time):**

- Should we monitor non-Google AI engine adoption of llms.txt quarterly and re-elevate priority if any major engine (ChatGPT, Claude, Perplexity) makes it load-bearing? — **Recommended yes**, track via Bible Part 13.17 quarterly review
- Should we add a `seo_ai_engine_llmstxt_adoption` tracking row per engine to record opt-in status? — Defer; current low-priority status doesn't warrant tracking infrastructure
- Will Google add `llms.txt` consumption in future? — Cannot predict; revisit if/when announced (DR-031 supersedable via new DR)
- Should "Query Fan-out" become the primary public-facing term and "Predicted Prompts" become the internal-only term? — Operator preference; recommend dual-name for one quarter then assess

**References:**

- Bible Part 1 §1.3 — SEO 2026 Layer Model (Layer 3 GEO diagram, reframed per DR-031)
- Bible Part 1 §1.5 + §1.5.1 — Update Principles (Principle 6 added per DR-031)
- Bible Part 13 §13.13 — Prompt Prediction Methodology (query fan-out cross-reference per DR-031)
- Bible Part 13 §13.17 §4 — AI Agent Era llms.txt enhancement (reframed per DR-031)
- Bible Part 21 §21.2 — Embedding Strategy Chunking Strategy (scope-clarified per DR-031)
- DR-018 — Layer-by-Layer Word Count Standards (supports chunking scope clarification — pillar pages 1,500-4,000+ words)
- External: [Google Search Central — Mythbusting generative AI search: what you don't need to do (2026-05)](https://developers.google.com/search/blog) — primary source for llms.txt + chunking + rewriting + mentions + structured data clarifications
- External: [Google Search Central — Is SEO still relevant for generative AI search? (2026-05)](https://developers.google.com/search/blog) — primary source for RAG + query fan-out + AEO/GEO terminology
- External: [llms.txt proposal (Answer.AI, 2024)](https://llmstxt.org/) — original spec, status unchanged but Google adoption clarified as "not consumed"

---

### [DR-030] — Sensitive Topic Compliance Layer (Product Tier × Content Tier Matrix) (2026-05-20) 🔒⚖️🛡️

**Status:** **Locked 2026-05-20** (operator-approved — first triggered by HP100 brand bootstrap, universal scope for all verticals where regulatory + YMYL compliance separation matters)
**Bible Reference:** Part 32 NEW — Sensitive Topic Compliance Layer
**Schema Reference:** Schema v1.17 — adds 6 columns to `seo_website_page_master` + 3 columns to `seo_reviews` + 2 columns to `brands` + extends `seo_editorial_reviews.review_type` enum
**Companion to:** DR-019 (Schema Strategy Two-Purpose Taxonomy — guides what schema is emittable per content tier), DR-021 (Internal Linking — sensitive pages may have linking restrictions), DR-026 (Ads Landing Page Track — ad_active gating intersects with sensitive topic flag)
**Scope:** **UNIVERSAL** — applies to all brands where product regulatory tier ≠ content topic tier (supplements, cosmetics, B2B health-adjacent, mental wellness, etc.); brands without sensitive content default to baseline (all tiers = 1, no overhead)

**Context:**

Pre-DR-030, EYWA spec assumed brand compliance was a single dimension — "this brand is healthcare, therefore all pages need medical review." Field-tested across brand discussions (notably HP100 post-rehab supplement brand 2026-05-20) revealed:

1. **Product regulatory tier ≠ content topic tier** — A supplement (legally just food, low regulatory bar) can require Tier 3 medical reviewer signoff because its CONTENT discusses YMYL-high topics (e.g., addiction recovery)
2. **One-size-fits-all medical review = wasteful** — Generic wellness pages don't need addiction-medicine MD signoff; recovery-education pages do. Operator was over-provisioning medical advisor cost across all pages or under-provisioning across critical pages
3. **Audience segment dimension missing** — Brands targeting sensitive populations (recovery, postpartum, cancer survivors, mental health) need per-page tagging for editorial workflow + analytics; current schema has no field
4. **Compliance binary too coarse** — `has_medical_review BOOLEAN` doesn't distinguish "reviewer needed at Tier 1 level (nutritionist)" vs "reviewer needed at Tier 3 level (MD specialist)" vs "legal + medical + อย. tri-signoff at Tier 4"
5. **PDPA on testimonials needs sensitivity tagging** — `seo_reviews` table has `pdpa_risk_flag BOOLEAN` but no granularity for "this testimonial discusses recovery from addiction → max-sensitivity anonymization required"
6. **Positioning mode is brand-level decision** — No field to record whether brand uses Mode A (open identity) / Mode B (dual-layer) / Mode C (implicit) — affects every downstream content + keyword + analytics choice

**Decision:**

Establish **Sensitive Topic Compliance Layer** — a two-dimensional tier matrix (Product Regulatory × Content Topic) applied at the **page level**, with brand-level metadata for positioning mode and audience segments. Editorial review workflow + claim guardrails + PDPA handling + Ads gating all derive from per-page tier flags.

#### 1. Two-Dimensional Tier Matrix

```
Product Regulatory Tier:        1  ────  2  ────  3  ────  4
                          (vitamin)  (functional)  (medical-grade)  (banned/restricted)

Content Topic Sensitivity:      1  ────  2  ────  3  ────  4
                       (general)  (specific outcome)  (YMYL-high)  (legal-sensitive)

Compliance intensity per page = max(Product Tier, Content Tier)
```

**Product Regulatory Tier (set at brand level, applies to product pages):**
- **T1 — Basic:** generic vitamins/minerals, basic cosmetics (lipstick, soap), general food
- **T2 — Functional:** anti-aging skincare, sleep aids, weight management, whitening, sports supplements, recovery supplements, energy/focus, joint health
- **T3 — Medical-Adjacent:** drug recovery support, diabetes/blood sugar, cardiovascular, fertility, mental health-adjacent, senior cognitive, pediatric (legally still supplement/cosmetic, but operates near medical category)
- **T4 — Quasi-Restricted:** cannabis-derived, kratom, anabolic, controlled-detox claims — country-specific bans likely; consult lawyer before scope

**Content Topic Sensitivity Tier (set per page on `seo_website_page_master`):**
- **T1 — General Lifestyle:** beauty routines, fitness tips, recipe content, decorative product showcase
- **T2 — Specific Outcome Education:** ingredient deep-dive, skin type guide, sleep improvement tips, exercise advice
- **T3 — YMYL-High:** addiction recovery education, mental health, cancer-adjacent wellness, post-illness recovery, pediatric advice, pregnancy advice
- **T4 — Legal-Sensitive:** content touching controlled substances, banned-ingredient comparison, jurisdictional medical claims, harm-reduction guides

#### 2. Schema additions (v1.16 → v1.17)

**Table `seo_website_page_master` — 6 NEW columns:**

```sql
ALTER TABLE seo_website_page_master
  ADD COLUMN product_regulatory_tier smallint
    CHECK (product_regulatory_tier BETWEEN 1 AND 4),
  ADD COLUMN content_topic_tier smallint
    CHECK (content_topic_tier BETWEEN 1 AND 4),
  ADD COLUMN sensitive_topic_flag text
    CHECK (sensitive_topic_flag IN ('none', 'low', 'medium', 'high', 'critical')),
  ADD COLUMN target_audience_segment text[],
  ADD COLUMN legal_review_required boolean DEFAULT false,
  ADD COLUMN compliance_max_tier smallint
    GENERATED ALWAYS AS (GREATEST(product_regulatory_tier, content_topic_tier)) STORED;
```

`compliance_max_tier` is generated column → derives reviewer tier automatically.

**Table `seo_reviews` (testimonials) — 3 NEW columns:**

```sql
ALTER TABLE seo_reviews
  ADD COLUMN is_sensitive_recovery_testimonial boolean DEFAULT false,
  ADD COLUMN consent_record_id text,
  ADD COLUMN anonymization_status text
    CHECK (anonymization_status IN ('not_required', 'pending', 'completed', 'verified'));
```

**Table `brands` — 2 NEW columns (or extend `metadata jsonb` if PK migration in progress):**

```sql
ALTER TABLE brands
  ADD COLUMN positioning_mode text
    CHECK (positioning_mode IN ('A-open-identity', 'B-dual-layer', 'B-weighted-recovery', 'C-implicit', 'baseline')),
  ADD COLUMN compliance_profile jsonb;
```

`compliance_profile` jsonb structure:
```json
{
  "product_regulatory_tier_default": 2,
  "content_topic_tier_default": 3,
  "sensitive_topic_flag_default": "high",
  "medical_advisor_required": true,
  "legitscript_status": "not-applied",
  "ads_strategy": "organic-first-no-paid-ads-until-legitscript",
  "forbidden_claims": ["..."],
  "approved_claims_source": "lawyer-engagement-2026-XX"
}
```

**Table `seo_editorial_reviews` — extend `review_type` enum:**

```sql
ALTER TABLE seo_editorial_reviews
  DROP CONSTRAINT seo_editorial_reviews_review_type_check;
ALTER TABLE seo_editorial_reviews
  ADD CONSTRAINT seo_editorial_reviews_review_type_check
  CHECK (review_type IN (
    'medical', 'editorial', 'fact_check', 'seo', 'translation', 'final',
    'legal_compliance'  -- NEW per DR-030
  ));
```

#### 3. Editorial Review Workflow Mapping

| `compliance_max_tier` | Required Reviewers | Citation Tier (Bible 23.1) | Schema.org Type Restrictions |
|---|---|---|---|
| **1** | optional pharmacist/nutritionist | 3-4 (popular science OK) | any non-restricted |
| **2** | pharmacist or nutritionist recommended | 2-3 (peer-reviewed preferred) | `DietarySupplement`, `Product`, no `Drug` |
| **3** | **MD signoff mandatory** + editorial + fact-check | 1-2 (PubMed, clinical guidelines) | `DietarySupplement` + `Article` only (no `MedicalCondition` schema unless explicit educational angle) |
| **4** | **MD + legal + อย./regulator signoff** | 1 only (gov + clinical) | strict whitelist per legal review |

**Trigger logic** (per DR-021 reciprocal trigger pattern):
- When page row inserted/updated with `compliance_max_tier >= 3`, automatically create pending `seo_editorial_reviews` row with `review_type='medical'`
- When `content_topic_tier=4 OR product_regulatory_tier=4`, also auto-create `review_type='legal_compliance'` row
- Page cannot move to `status='published'` until all required review rows have `approved=true`

#### 4. Keyword + Ads gating

In `seo_x_ads_keywords_contextual_master`:
- Add derived check: if landing page has `sensitive_topic_flag IN ('high','critical')` AND `target_audience_segment @> ARRAY['recovery','mental-health-clinical']`, then `ad_active=false` default
- Operator can manually flip after LegitScript or equivalent certification (lock in `decision_records.md` per brand)

#### 5. PDPA workflow for testimonials

When `seo_reviews.is_sensitive_recovery_testimonial=true`:
- `anonymization_status` must reach `verified` before `responded_at` can be set
- `consent_record_id` must point to consent record (operator stores externally — Notion / contract DMS)
- DPO must sign off on retention policy
- 30-day deletion-on-request SLA tighter than baseline PDPA

#### 6. Positioning Mode definitions (recorded on `brands.positioning_mode`)

| Mode | Description | When to use |
|---|---|---|
| **A-open-identity** | Brand openly addresses sensitive audience as primary | Recovery brand, postpartum brand, cancer-survivor brand where authenticity drives community trust |
| **B-dual-layer** | 50/50 split — main wellness layer + community section for sensitive audience | Brand wants reach + authenticity but is risk-averse |
| **B-weighted-recovery** | 70/30 — recovery is primary identity, broad wellness is collateral SEO reach | Brand identity committed to sensitive audience but wants broader keyword reach |
| **C-implicit** | No explicit sensitive topic mention — symptom/outcome keywords only | Risk-averse brands, banned-Ads categories (T4 products) |
| **baseline** | No sensitive topic — regular brand operation | All non-sensitive brands (most brands) |

#### 7. Bootstrap Kit additions

- `templates/folder-skeleton/docs/brand-intake.xlsx` — extend with Section 13 "Sensitive Audience Compliance Profile" (14 new questions, brings total to 95)
- `templates/folder-skeleton/docs/brand-concept.template.md` — add Section 11 "Compliance Profile" + Section 13 "Forbidden Topics & Risk Boundaries"
- `templates/folder-skeleton/brand-config.template.json` — add `positioning_mode` + `compliance_profile` keys

#### 8. Retrofit policy for existing brands

- **Baseline brands** (non-sensitive — dental, aesthetics, wellness clinics): set `product_regulatory_tier=1`, `content_topic_tier_default=1`, `positioning_mode='baseline'` — zero behavioral change, columns NULLable so no migration risk
- **Healthcare-adjacent brands** (existing supplements, vitamins): operator audit at next Stage gate — flag content_topic_tier per page if any YMYL pages exist; default `compliance_profile` per brand-config
- **New sensitive brands** (HP100 onwards): mandatory full profile at Pre-Stage 1 bootstrap before brand-concept.md finalization

**Rationale:**

1. **Separation of concerns** — Product compliance (legal, อย., country regulation) and Content compliance (Google YMYL E-E-A-T, journalistic standards) operate on different timescales and require different expertise. Conflating them produces either over-spending (medical reviewer on lipstick pages) or under-spending (no MD signoff on diabetes-adjacent supplement content).
2. **Per-page granularity matches reality** — A brand homepage might be T1 commercial; an educational FAQ might be T3 YMYL. Editorial workflow assigns reviewers per-page, not per-brand.
3. **Generated column reduces operator error** — `compliance_max_tier` derives automatically, can't get out-of-sync with input tiers; UI can validate against it before publish.
4. **Positioning mode is load-bearing** — Brand strategy decisions (homepage tone, B2B partnership channel, ad strategy, community section) all derive from positioning_mode. Recording it on `brands` table makes it queryable for dashboards + audits.
5. **PDPA tightening for sensitive testimonials** — Generic `pdpa_risk_flag` boolean was insufficient. Three-state `anonymization_status` enables workflow gates (cannot publish testimonial until verified anonymized).
6. **Ads gating prevents account bans** — Hard-link `ad_active=false` default for sensitive landing pages prevents accidental ad spend on uncertified categories that would suspend the entire Google Ads account.
7. **HP100 validates framework** — First brand designed under DR-030 (HP100 supplement for post-rehab recovery) hits all dimensions: Mode A open identity, Product T2 × Content T3 default, sensitive testimonials, ads paused for LegitScript. Real-world validation > theoretical framework.

**Consequences:**

- ✅ Editorial workflow auto-assigns correct reviewer tier per page → cost-efficient + compliance-safe
- ✅ Sensitive brands launchable without bespoke compliance layer — framework + Bootstrap Kit handles it
- ✅ Cross-brand analytics can segment by `target_audience_segment` for cohort analysis
- ✅ Schema additions are backward-compatible (all NULLable, default to baseline behavior for non-sensitive brands)
- ✅ Brand intake form section 13 captures all sensitive-topic decisions before content production begins
- ⚠️ Operator workload: 4 migrations (Wave 11) for the 5 column additions (page_master + reviews + brands + editorial_reviews extension)
- ⚠️ n8n flow update needed — trigger logic for auto-creating pending editorial_reviews rows when `compliance_max_tier >= 3`
- ⚠️ Existing brand audits at next Stage gate (operator workload — estimated 30 min per brand for tier classification)
- ⚠️ Bootstrap Kit `brand-intake.xlsx` becomes 95 questions (from 81) — slight intake friction increase

**Open Questions (operator decisions over time):**

- Should `compliance_max_tier` cascade to children pages via `parent_page_fp` automatically (inheritance)? — Defer; explicit per-page is safer for now
- Should `positioning_mode` evolve over brand lifecycle (e.g., Mode C → Mode A as brand matures)? — Yes, supersede via DR per-brand
- Should ads gating extend to LINE OA / Meta Ads / TikTok Ads per platform? — Defer until first sensitive brand runs paid ads in any platform
- Tier 4 jurisdictional differences (cannabis legal in Thailand but not all SE Asia) — handle via `target_market` field on brand + per-market overrides? — Defer until first multi-market T4 brand emerges

**References:**

- Bible Part 32 NEW — Sensitive Topic Compliance Layer (this DR's authoritative spec)
- Bible Part 23.1 — Citation 6-tier hierarchy (used by Tier 3-4 content pages)
- Bible Part 23.3 — Authors/Reviewers E-E-A-T (medical advisor signoff workflow)
- DR-019 — Schema Strategy Two-Purpose Taxonomy (constrains emittable schema types per tier)
- DR-021 — Internal Linking Architecture (sensitive pages may have anchor/link restrictions)
- DR-026 — Ads Landing Page Track Phase 0 (intersects with sensitive flag gating)
- DR-028 — Brand Genesis Protocol (positioning_mode emerges from BGP Phase A.0 intake)
- DR-029 — Universal Brand Design System (brand-foundation/imagery.md may flag sensitive imagery restrictions)
- DR-HP100-001..005 — first brand application of DR-030 framework (post-rehab supplement)
- External: [Google YMYL Quality Rater Guidelines](https://static.googleusercontent.com/media/guidelines.raterhub.com/en//searchqualityevaluatorguidelines.pdf)
- External: [LegitScript Healthcare Merchant Certification](https://www.legitscript.com/) — required for paid Ads on addiction-treatment-adjacent keywords
- External: Thai PDPA (พ.ร.บ.คุ้มครองข้อมูลส่วนบุคคล) — sensitive personal data Category Two requires explicit consent
- External: Thai อย. supplement notification regulations (พ.ร.บ.อาหาร)
- Bootstrap Kit additions: `templates/folder-skeleton/docs/brand-intake.xlsx` v2 (95 questions)

---

### [DR-029] — Universal Brand Design System (DTCG Tokens + Design Specifications Layer) (2026-05-18) 🔒🎨

**Status:** **Locked 2026-05-18** (operator-approved — universal scope, applies to all brand repos including WP and Astro stacks)
**Bible Reference:** Part 31 NEW — Universal Brand Design System
**Schema Reference:** No DDL change — file-system + JSON specification
**Companion to:** DR-002 (WP+Elementor stack default — consumes from this folder), DR-EYWA-MKT-005 (Astro stack profile — also consumes from this folder)
**Scope:** **UNIVERSAL** — applies to all 13 brand repos + eywa-marketing + future brands

**Context:**

Pre-DR-029, brand design assets lived in `theme/brand-assets/` with no formalized design tokens, no W3C-standard format, no stack-agnostic separation between specification and implementation. Each brand operator/designer reinvented:

1. **Color palette format** — sometimes CSS variables, sometimes Elementor global colors JSON, sometimes Figma styles export, sometimes nothing
2. **Typography scale** — operator-determined per brand, no shared modular scale convention
3. **Spacing system** — ad hoc per page, no token discipline
4. **Cross-stack portability** — if a brand migrated WP → Astro, design system was rebuilt from scratch
5. **Designer-readable format** — operators tried to communicate design decisions through long Notion docs; designers expected DTCG-formatted JSON they recognize

Operator increasingly uses coding-augmented workflows even for WP+Elementor stack (per recent practice). Design tokens become essential to keep design discipline + accelerate handoffs to AI co-authors + reduce per-brand reinvention.

**Decision:**

Establish **Universal Brand Design System** as a per-brand folder structure consisting of three layers — design specifications (stack-agnostic), raw brand assets (binary sources), and stack-specific implementation. The design specifications layer adopts W3C DTCG (Design Tokens Community Group) JSON format as the cross-stack standard.

#### 1. Folder structure (mandatory per-brand)

```
brands/eywa-{brand}/
├── design/                       🎨 Stack-agnostic design layer
│   ├── README.md                 ← workflow guide
│   ├── tokens/                   📐 DTCG-compliant JSON (source of truth)
│   │   ├── core.tokens.json      (primitives — palette, type scale, spacing)
│   │   ├── semantic.tokens.json  (role-based — primary/surface/text)
│   │   ├── component.tokens.json (component-level — button-bg, card-shadow)
│   │   └── brand.tokens.json     (brand-unique — pillar colors, signature accents)
│   ├── brand-foundation/         📋 Visual identity specs (Markdown)
│   │   ├── color-system.md
│   │   ├── typography.md
│   │   ├── spacing.md
│   │   ├── iconography.md
│   │   ├── imagery.md
│   │   └── motion.md
│   ├── component-specs/          📐 Per-component design spec
│   ├── page-templates/           🗺  Page-level layout specs
│   ├── wireframes/               🗺  Hand-drawn / lo-fi sketches
│   └── references/               💡 Mood boards, competitor screens
├── brand-assets/                 🖼  Raw binary sources
│   ├── logos/
│   ├── photography/
│   ├── illustrations/
│   └── icons/
└── theme/                        🚀 Stack-specific implementation
    ├── custom-css/               (WP — generated from tokens where possible)
    ├── elementor-templates-overrides/  (WP)
    └── (or src/ if Astro stack — see DR-EYWA-MKT-005)
```

**Renames from pre-DR-029 structure:**
- `theme/brand-assets/` → `brand-assets/` (root-level, expanded to logos/photography/illustrations/icons subfolders)
- `theme/` keeps remaining stack-specific implementation only (custom-css, elementor-templates-overrides)
- `design/` is NEW (did not exist universally; eywa-marketing had a partial version)

#### 2. DTCG (W3C Design Tokens Community Group) format adoption

All token files in `design/tokens/` use DTCG JSON format:

```json
{
  "color": {
    "brand": {
      "primary": {
        "$value": "#1E40AF",
        "$type": "color",
        "$description": "Primary brand color"
      }
    }
  }
}
```

Token files reference each other via `{path.to.token}` syntax. semantic.tokens.json references core.tokens.json primitives; component.tokens.json references both.

**Why DTCG (not custom format):**
- Industry-standard (W3C committee + design tool industry consensus)
- Figma + Tokens Studio plugin enables 2-way sync between Figma and `design/tokens/`
- Style Dictionary tool transforms DTCG → any output format (CSS, SCSS, JS, Swift, Android)
- Any designer hired in the future recognizes format on first glance
- Tool interoperability — no lock-in

#### 3. Stack-specific consumption pipelines

**WP+Elementor (per DR-002 default stack):**

```yaml
pipeline:
  - Designer edits design/tokens/*.tokens.json
  - Run sync script (operator workload — Phase 1F): transforms tokens → Elementor global colors/fonts JSON
  - Import JSON into Elementor (Site Settings → Import Site Kit)
  - All Elementor templates using global colors/fonts update automatically
  - theme/custom-css/ holds tokens-derived CSS variables for cases Elementor globals don't cover
```

**Astro (per DR-EYWA-MKT-005 — eywa-marketing + future Astro brands):**

```yaml
pipeline:
  - Designer edits design/tokens/*.tokens.json
  - tailwind.config.mjs imports tokens via Style Dictionary or direct import
  - npm run build → CSS regenerates
  - Astro components in src/components/ use Tailwind classes generated from tokens
```

**Figma 2-way sync (when designer uses Figma):**

```yaml
pipeline:
  - Tokens Studio plugin in Figma reads design/tokens/*.tokens.json (via GitHub sync)
  - Designer changes values in Figma using Tokens Studio
  - Tokens Studio commits back to design/tokens/ via GitHub API
  - Stack-specific pipelines (above) pick up new values on next build
```

#### 4. Bootstrap Kit additions

`templates/folder-skeleton/` updated with:
- `design/README.md` — workflow guide + DTCG primer
- `design/tokens/{core,semantic,component,brand}.tokens.json` — 4 DTCG skeleton files with TBD placeholders
- `design/brand-foundation/{color-system,typography,spacing,iconography,imagery,motion}.md` — 6 markdown templates
- `design/{component-specs,page-templates,wireframes,references}/` — placeholders with .gitkeep
- `brand-assets/{logos,photography,illustrations,icons}/` — replaces old `theme/brand-assets/`
- `brand-assets/README.md` — folder map + cross-reference to imagery.md

#### 5. Retrofit policy for existing brands

Existing brands (13 brand repos + eywa-marketing) follow this rule:

- **At next Stage gate** — operator creates `design/` and `brand-assets/` folders per Bootstrap Kit template
- **Fill incrementally** — `design/tokens/core.tokens.json` mandatory at minimum; other layers as needed
- **Move existing assets** from `theme/brand-assets/` → `brand-assets/` (preserve git history via `git mv`)
- **No retroactive deadline** — brands at Pre-Stage 1 can backfill at their leisure; brands in Phase E+ should backfill before Phase F content production starts

#### 6. eywa-marketing precedent

eywa-marketing repo already has a partial version of this structure (DR-EYWA-MKT-005 era). DR-029 generalizes that pattern + standardizes DTCG format + extends to all brand repos.

### Naming choice — `theme/` preserved

Per operator preference (2026-05-18) — `theme/` naming retained for stack-specific implementation folder. Reasons:

- WordPress developer community recognizes "theme" instantly
- Avoids invented naming ("implementation/") that adds cognitive load for operator's existing team
- Brand repos may eventually have multi-stack implementations (e.g., WP + Astro coexisting during migration); `theme/wp-elementor/` and `theme/astro/` subfolder pattern works under one `theme/` umbrella

**Rationale:**

1. **Stack-agnostic by design** — Brand visual identity does not change when implementation stack changes. One brand running WP today and migrating to Astro tomorrow should NOT redesign its color palette. Separating spec layer from implementation layer makes this future-proof.
2. **W3C DTCG = no lock-in** — Industry standard format ensures tools interoperate. Operator never has to learn a custom EYWA-specific design token format; designers recognize DTCG instantly.
3. **Designer-friendly entry** — When a new designer joins an EYWA brand engagement, they open `design/` folder and recognize the layout in 30 seconds. Color system, typography, spacing — universal mental model.
4. **Coding-augmented workflow accelerator** — Operator + Claude Code workflow consumes design tokens to generate consistent components. Without tokens, every component is bespoke; with tokens, components are derivative + consistent.
5. **WP brand benefit (not just Astro)** — Common misconception: design tokens are only for code-first stacks. False — Elementor accepts global colors/fonts JSON, which is generated from DTCG tokens via sync script. WP brands gain consistency at scale (especially multi-branch sites with shared identity).
6. **Cross-brand pattern sharing** — When `eywa-portfolio` design language emerges (e.g., shared accent style across Vertex/VT family), tokens make sharing trivial. Per-pixel CSS makes sharing impossible.
7. **EYWA marketing self-applies** — `eywa-marketing` already partially uses this pattern. DR-029 codifies + extends to all brands. EYWA dogfoods its own protocol.

**Consequences:**

- ✅ Brand visual consistency improves dramatically as tokens propagate via build pipelines
- ✅ Designer onboarding time drops (universal recognized format vs custom brand format)
- ✅ AI co-author (Claude Code) consumes tokens reliably — fewer ad-hoc style choices in generated components
- ✅ Multi-stack migration becomes feasible (Astro POC → broader adoption) without losing design system
- ✅ Figma 2-way sync option enables designer-driven workflow when applicable
- ⚠️ Existing 13 brand repos need retrofit at next Stage gate (low effort — folder creation + skeleton + incremental fill)
- ⚠️ Operator workload: sync script for WP+Elementor stack (~4-6 hours one-time, then automation)
- ⚠️ Each brand DNA Graph workshop (Phase A.1 per Bible Part 30 BGP) now feeds directly into `design/brand-foundation/color-system.md` + `typography.md` decisions — workshop output more structured
- ⚠️ Existing `theme/brand-assets/` content must move to root `brand-assets/` — git mv preserves history, but commit + push required per brand
- ⚠️ Sample tokens.json files have TBD placeholders — brands must fill with actual values; DTCG validators (e.g., w3c/design-tokens) can verify format compliance

**Open Questions (operator decisions over time):**

- Sync script implementation language — Node.js (Style Dictionary) vs operator-preferred tooling? (Recommend: Style Dictionary — widely supported, DTCG-native)
- Figma sync — adopt Tokens Studio plugin universally or per-brand decision? (Recommend: per-brand — depends on whether designer is hired + uses Figma)
- Multi-stack `theme/wp-elementor/` vs `theme/astro/` subfolder convention — formalize now or defer until first dual-stack brand emerges? (Recommend: defer — YAGNI)
- Cross-brand shared token layer (e.g., eywa-portfolio common colors) — future DR if pattern emerges? (Recommend: defer until 2+ brands share visual identity)

**References:**

- Bible Part 31 NEW — Universal Brand Design System (this DR's authoritative spec)
- Bible Part 30 — Brand Genesis Protocol (BGP) — A.1 DNA Graph informs design tokens via brand-foundation
- Bible Part 9 — Template Anatomy (consumes tokens via theme implementation)
- Bible Part 25 — WordPress Universal Kit (WP-specific consumption pipeline)
- DR-002 — WP+Elementor stack default (consumes from this folder)
- DR-EYWA-MKT-005 — Astro stack profile (consumes from this folder)
- DR-028 — BGP Phase A.1 EYWA DNA Graph (Field 6 Brand Personality drives color/typography choices)
- External: [W3C DTCG Spec](https://design-tokens.github.io/community-group/format/) — format specification
- External: [Style Dictionary](https://amzn.github.io/style-dictionary/) — DTCG transformation tool
- External: [Tokens Studio (Figma plugin)](https://tokens.studio/) — Figma 2-way sync tool
- Bootstrap Kit additions: `templates/folder-skeleton/design/` + `templates/folder-skeleton/brand-assets/`

---

### [DR-028] — Brand Genesis Protocol (BGP) Universal (2026-05-17) 🔒🌱🧬

**Status:** **Locked 2026-05-17** (operator-approved — final on first iteration, applied immediately to all brand repos + eywa-marketing)
**Bible Reference:** Part 30 NEW — Brand Genesis Protocol (BGP)
**Schema Reference:** No DDL change in this DR — uses existing tables. Optional `seo_website_page_master.brand_dna_alignment_score` field deferred to follow-up DR.
**Companion to:** EGP (Entity Genesis Protocol, Bible Part 2.6) — BGP is the brand-side parallel that produces foundation for EGP to consume
**Scope:** **UNIVERSAL** — applies to all 13 brand repos AND eywa-marketing (EYWA dogfoods its own protocol)

**Context:**

Pre-DR-028, Stage 1 Phase A produced an unstructured `brand-concept.md` narrative. Field-tested across 8 brand bootstraps (VTH BioDent, SmileScape, Trin Wellness, Classy Clinic, Deezy, Biodental Wellness, Relaxia, TC Smile) revealed consistent gaps:

1. **No structured brand DNA** — narratives drift, hard to enforce brand consistency across content
2. **No business goal mapping** — SEO tactics not explicitly tied to revenue/conversion goals → ROI hard to prove
3. **No TRUST baseline** — healthcare brands need pre-engagement audit to identify SEO content gaps
4. **Framework inputs invisible** — operators implicitly use Golden Circle / JTBD / CDJ but don't document → drift across sessions
5. **No brand-consistency check on output** — content gets published without final brand DNA alignment QC

EYWA promises "Be found first. By Google and AI" (DR-EYWA-MKT-004 tagline) — but for that to be commercially defensible, SEO must serve **Google + Brand + Business** simultaneously, not Google alone.

**Decision:**

Establish **Brand Genesis Protocol (BGP)** as a Universal Bootstrap Kit addition — parallel to EGP (Entity Genesis Protocol) but operating on brand-business layer rather than entity-knowledge layer.

#### 1. BGP = 5 Sub-phases (Phase A.0 → A.4)

```yaml
phase_A_0_pre_engagement_discovery:
  goal: Capture business context + stakeholders + constraints BEFORE bootstrap
  deliverable: docs/brand-genesis/business-context.md
  duration: 1-2 hour kickoff session
  outputs:
    - Business goals (12-month revenue, growth, market position)
    - Stakeholder map (decision makers, gatekeepers, end users)
    - Constraints (budget, timeline, compliance, regulatory)
    - Success metrics (definition of "win" in 12 months)

phase_A_1_eywa_dna_graph:
  goal: Structured brand DNA in 10 fields (Brand Key adapted for healthcare)
  deliverable: docs/brand-genesis/eywa-dna-graph.md
  duration: 4-6 hour workshop with operator + client
  outputs (10 fields):
    1. Target Patient (demographic + psychographic)
    2. Patient Insight (deep truth / pain / unmet need)
    3. Clinical Benefits (functional outcomes — measurable)
    4. Emotional Benefits (how patient feels after engagement)
    5. Reasons to Trust (RTBs — credentials, evidence, track record, social proof)
    6. Brand Personality (5-7 traits + 3-5 anti-traits)
    7. Discriminator (single point of differentiation vs key competitors)
    8. Brand Essence (one-line distilled identity)
    9. Competitive Frame (which playing field we choose)
    10. Compliance Boundaries (what we CAN'T claim — healthcare YMYL discipline)

phase_A_2_eywa_framework_synapse:
  goal: Document framework inputs that compose into EYWA methodology
  deliverable: docs/brand-genesis/framework-synapse.md
  duration: 2-3 hour session
  contains:
    - Golden Circle (WHY/HOW/WHAT) — brand purpose + methodology + services
    - EYWA Intent Roots (JTBD) — functional + emotional + social jobs patient hires clinic for
    - EYWA Journey Map (Consumer Decision Journey — McKinsey adapted)
       stages: Initial Consideration → Active Evaluation → Moment of Purchase → Post-Purchase → Loyalty Loop
       touchpoints: per stage, what channels/content/interactions exist?

phase_A_3_eywa_trust_rubric_baseline:
  goal: Audit current brand state across 5 TRUST pillars to identify SEO content gaps
  deliverable: docs/brand-genesis/eywa-trust-rubric.md
  duration: 3-5 hour audit (operator + client)
  five_pillars:
    T_trust: medical authority, credentials, evidence-backed claims, citations
    R_results: clinical outcomes, case studies, before/after, measurable success rates
    U_understanding: deep patient understanding, journey clarity, accessibility
    S_safety: compliance, contraindications, disclosures, YMYL discipline
    T_transparency: pricing transparency, process clarity, data handling, PDPA
  per_pillar_outputs:
    - Score 0-10
    - Evidence (what exists today)
    - Gaps (what's missing)
    - SEO content opportunity (what new content fills the gap)

phase_A_4_brand_business_seo_alignment_map:
  goal: Prove every SEO move serves a brand promise AND a business goal
  deliverable: docs/brand-genesis/alignment-map.md
  duration: 2-3 hour mapping session
  structure: Table per business goal with rows:
    - Business goal
    - Brand promise involved
    - TRUST pillar served
    - SEO tactic
    - Content cluster anchor
    - Success metric
  used_downstream: Phase B-E execution validates against this map; reporting back to client cites this table for ROI proof
```

#### 2. EYWA Naming Lexicon (Locked in this DR)

| Concept | EYWA Name |
|---------|-----------|
| Brand Key (Unilever-adapted) | **EYWA DNA Graph** |
| Consumer Decision Journey (McKinsey-adapted) | **EYWA Journey Map** |
| Jobs-to-be-Done (Christensen-adapted) | **EYWA Intent Roots** |
| Healthcare brand evaluation rubric (SASSY-analog) | **EYWA TRUST Rubric** |
| OKR / business outcome tracker | **EYWA Compound Growth** |
| Brand consistency AI check | **EYWA DNAi Diagnostic** |

Naming pattern: **"EYWA + concept"** for productized deliverables of Service Suite. Generic frameworks (Golden Circle, etc.) keep original names when cited as inputs.

#### 3. EYWA DNAi Diagnostic — Publication Pipeline Integration

Late-stage AI brand-alignment QC inserted into editorial workflow (Bible Part 23.4):

```yaml
pipeline_position:
  - Stage 0: Content draft (T-template structure + body content)
  - Stage 1: Human editorial review (accuracy, citations, voice — Part 23.4 existing)
  - Stage 2: EYWA DNAi Diagnostic (NEW — AI brand alignment check)
  - Stage 3: Revise if needed → re-run DNAi
  - Stage 4: Final approval gate
  - Stage 5: Publish

dnai_n8n_workflow:
  trigger: Notion page status="ready_for_dnai_check"
  inputs_pulled:
    - Content draft
    - docs/brand-genesis/eywa-dna-graph.md (10 fields)
    - strategy/messaging.md or equivalent voice ID + 5 axes
    - Anti-patterns list (per brand)
    - Compliance Boundaries (field 10 of DNA Graph)
  claude_api_call: |
    "Check this content against brand DNA Graph + voice ID + compliance.
     Return: pass/fail + specific issues + suggested revisions per issue."
  outputs_written_to_notion:
    - dnai_check_status: pass | warn | fail
    - dnai_check_score: 0-100
    - dnai_check_issues: structured JSON (issue, severity, suggestion)
    - dnai_check_revised_draft: AI-suggested revision (operator review)
  publish_gate: dnai_check_status='pass' AND human_editorial_approved
```

#### 4. EYWA Compound Growth — KPI Tracking Link

References existing Bible Part 20 (Measurement & KPI Framework). DR-028 doesn't redefine KPIs; instead establishes that **Phase A.4 Alignment Map success metrics → Part 20 KPI dashboard**, ensuring brand-business goals flow into ongoing measurement.

#### 5. Scope: Universal Application

**Applies immediately to:**
- All 13 brand repos (existing bootstrapped brands run Phase A.0-A.4 retroactively at next Stage gate; new brands run from kickoff)
- `eywa-marketing` repo (EYWA dogfoods its own protocol — Phase A docs become part of EYWA's strategy/ folder)
- Future brand engagements (mandatory pre-engagement deliverable)

**Bootstrap Kit additions:**
- `templates/folder-skeleton/docs/brand-genesis/` (new subfolder) with 5 template files

**Rationale:**

1. **Closes the brand-business-SEO triple-fit gap** — SEO can no longer drift away from brand promises or business goals. Every content piece traces back to alignment-map.md
2. **Productizes the methodology** — EYWA DNA Graph, EYWA TRUST Rubric become Service Suite deliverables (Audit tier output)
3. **EYWA self-application proves the protocol** — eywa-marketing site itself runs through BGP. Operator's own brand becomes the canonical reference implementation
4. **Parallel-structure with EGP** — operators familiar with Entity Genesis Protocol mental-model can adopt BGP fast. Both are "Genesis" protocols (foundation layers)
5. **TRUST baseline as Audit deliverable** — first commercial output of new client engagement = TRUST Rubric scorecard. Justifies premium pricing of EYWA™ Audit tier
6. **DNAi Diagnostic prevents content drift at scale** — humans miss subtle voice/brand violations as content volume grows. AI pre-publish gate catches what humans don't

**Consequences:**

- ✅ Phase A duration expands ~1 week → ~3 weeks (5 sub-phases), but Phase B-E becomes faster (foundation clearer)
- ✅ Client deliverables in week 1-3 of engagement become tangible (DNA Graph, TRUST Rubric, Alignment Map) — perceived value increases vs vague "we'll do SEO research"
- ✅ Brand-level DRs (`DR-{BRAND}-*`) become richer — anchored to DNA Graph + Alignment Map
- ✅ EYWA Service Suite (Audit / Graph / Stack / Vital / Forge / Score / Atlas) gains concrete deliverable mapping:
  - **EYWA Audit** = BGP Phase A.0-A.3 output package
  - **EYWA Graph** = Entity Genesis + Knowledge Graph build (Phase B-D)
  - **EYWA Stack** = Schema implementation + WP/Astro stack setup
  - **EYWA Vital** = Phase F content production retainer
  - **EYWA Forge** = Phase G growth + iteration retainer
  - **EYWA Score** = EYWA Compound Growth dashboard + reporting
  - **EYWA Atlas** = Enterprise multi-brand orchestration
- ⚠️ Operator workload: ~10-15 hours per new brand for Phase A (kickoff + 5 deliverable sessions)
- ⚠️ Existing 8 bootstrapped brands need Phase A retro-fit at next Stage gate (1-2 sessions per brand to backfill DNA Graph + TRUST baseline + Alignment Map)
- ⚠️ n8n DNAi Diagnostic flow needs build (~6-8 hours dev one-time)
- ⚠️ EYWA marketing site Phase A starts immediately — DNA Graph + TRUST + Alignment for EYWA itself

**Action items:**

- [x] Lock decision (this DR) — done 2026-05-17
- [x] Bible Part 30 NEW (BGP) — done 2026-05-17 with this commit
- [x] Bootstrap Kit additions: `templates/folder-skeleton/docs/brand-genesis/` with 5 templates — done 2026-05-17
- [ ] EYWA_HANDOVER update §brand-onboarding to reference BGP Phase A.0-A.4 — done with this commit
- [ ] eywa-marketing pilot: run BGP Phase A on EYWA itself (1-2 sessions, this week)
- [ ] Retrofit 8 existing brand repos with Phase A backfill at next Stage gate
- [ ] Build n8n DNAi Diagnostic flow (operator workload, ~6-8 hours dev)
- [ ] Update Content_Templates §7 Editorial Workflow to insert DNAi Stage 2 — done with this commit (v1.5 → v1.6)
- [ ] Future DR consideration: `seo_website_page_master.brand_dna_alignment_score` column (Schema v1.17 candidate)

**References:**

- Bible Part 30 NEW (Brand Genesis Protocol — BGP)
- Bible Part 2.6 (Entity Genesis Protocol — EGP, parallel sibling)
- Bible Part 20 (Measurement & KPI Framework — Compound Growth integration)
- Bible Part 23.4 (Editorial Review Workflow — DNAi insertion point)
- Bible Part 25.6 (Brand Config — DNA Graph fields may inform brand-config.json schema)
- Content_Templates v1.6 §7 (Editorial Workflow with DNAi Stage 2)
- DR-EYWA-MKT-003 (Knowledge Graph SEO Method™ — category claim, brand-business-SEO triple-fit reinforces)
- DR-EYWA-MKT-004 (Tagline locked — "Be found first. By Google and AI." now operationally enforced via BGP)
- DR-013 (12-edge vocabulary — DNA Graph concepts feed entity_graph as `concept` type with subtype='framework')
- DR-014 (Concept entity subtype — DNA Graph + TRUST Rubric + Compound Growth all qualify as `framework` subtype)
- External: Unilever Brand Key methodology (adapted, healthcare-extended with Compliance Boundaries)
- External: McKinsey Consumer Decision Journey (adapted as EYWA Journey Map)
- External: Christensen Jobs-to-be-Done (adapted as EYWA Intent Roots)
- External: Sinek Golden Circle (input framework, no rename)

---

### [DR-027] — Campaign Universal Master Table (Future Phase 1) (2026-05-12) 🌱📣

**Status:** Proposed (Phase 1 implementation — soak window opens upon DR-026 lock; review cycle TBD)
**Bible Reference:** Part 29.11 (Future: Campaign Master Track), Part 5 (Database Schema Architecture)
**Schema Reference:** v1.12 (hint only — no DDL ships in v1.12; full table ships in Schema v1.13+ when DR-027 locks)
**Pairs with:** DR-026 (Ads-LP Phase 0 — this DR is the Phase 1 successor)

**Context:**

DR-026 establishes the **Phase 0 Ads-LP Track** — Bible Part 29, page/keyword schema extensions, T-ADS-1 through T-ADS-5 templates, `/lp/{slug}/` URL convention. Phase 0 is sufficient for a brand to launch Google Ads with structured LPs and dual-use SEO/Ad keyword tracking. It is NOT sufficient for:

1. **Multi-platform campaign orchestration** — 1 campaign typically spans Google Ads + Meta Ads + (optionally) YouTube + LINE + TikTok with shared budget envelope, shared audience target, shared LP set
2. **Cross-platform consolidated reporting** — daily performance snapshot per platform aggregated to campaign level for budget reallocation decisions
3. **Junction between campaigns ↔ pages ↔ keywords** — 1 campaign uses N LPs and M keywords; 1 LP can serve multiple campaigns over time
4. **Historical performance archival** — Notion can't hold per-campaign-per-day-per-platform snapshot rows; Supabase is the right home

Operator vision (predates EYWA spec, see project memory): keyword + page tables are dimensional backbones; SEO is one track, Ads is another, and Campaign-level orchestration is the natural horizontal expansion. "ค่อยๆ ขยายออกด้านข้างไปเรื่อยๆ"

**Decision:**

Reserve DR-027 for the **Campaign Universal Master Table architecture** to ship in Schema v1.13 (or later) once DR-026 is locked and Phase 0 has live brand data (target: VTH BioDent post-launch, ~2-4 weeks after first Ads campaign). Until then, Phase 0 brands use the `campaign_id` TEXT stub column on `seo_page_master` (added in v1.12 per DR-026) to label LPs with campaign identifiers manually (e.g., `"vth-biodent-launch-2026-q2"`).

**Proposed Schema Sketch (Phase 1 — NOT shipped in v1.12):**

```yaml
seo_campaigns:
  purpose: Universal campaign orchestration across platforms (Google Ads, Meta Ads, YouTube, LINE Ads, TikTok Ads, organic launches)
  fp: campaign_fp (text PK, hash of brand_id + campaign_name + date_start)
  fk:
    - brand_id → brands.id (NOT NULL — every campaign belongs to one brand)
    - entity_focus_fp → seo_entity_graph.fingerprint (optional — primary entity the campaign targets)
  identity:
    - campaign_id (text — short slug, e.g., "vth-launch-2026-q2")
    - campaign_name (text — human label)
    - notion_page_id (text — Notion sync state)
  classification:
    - platforms text[] (enum: google_ads, meta_ads, youtube_ads, line_ads, tiktok_ads, other)
    - objective enum (lead_gen | awareness | conversion | retargeting | reactivation | launch | promo)
    - audience_tier enum (cold | warm | hot | mixed)
  financial:
    - budget_total_thb numeric(12,2)
    - budget_currency text default 'THB'
    - budget_per_platform jsonb  # {"google_ads": 50000, "meta_ads": 30000} — per-platform allocation
    - budget_pacing enum (front_loaded | even | back_loaded | accelerated)
  schedule:
    - date_start date
    - date_end date (nullable for ongoing)
    - status enum (planning | active | paused | completed | archived)
  governance:
    - approved_by_fp text (→ seo_authors_reviewers)
    - approval_date date
    - notes text

seo_campaign_pages (M2M junction):
  fk:
    - campaign_fp → seo_campaigns
    - page_fp → seo_page_master
  role enum (primary_lp | secondary_lp | thank_you | followup | dual_use_seo_page)
  active boolean default true
  added_at timestamptz default now()

seo_campaign_keywords (M2M junction):
  fk:
    - campaign_fp → seo_campaigns
    - keyword_fp → seo_x_ads_keywords_contextual_master
  platform enum (google_ads | meta_ads | youtube_ads | line_ads | tiktok_ads | other)
  match_type enum (exact | phrase | broad | broad_modified | negative)  # google ads style; phrase semantics for meta = audience interest mapping
  bid_strategy enum (manual_cpc | enhanced_cpc | maximize_clicks | maximize_conversions | target_cpa | target_roas)
  bid_amount_thb numeric(10,2) nullable
  budget_share_pct numeric(5,2)  # what % of campaign budget this KW gets
  active boolean default true

seo_campaign_performance_snapshot:
  purpose: Daily performance snapshot per campaign per platform (mirrors keyword_daily_logs pattern)
  fk: campaign_fp → seo_campaigns
  identity: (campaign_fp, platform, snapshot_date) UNIQUE
  metrics:
    - impressions int
    - clicks int
    - spend_thb numeric(10,2)
    - conversions int
    - conversion_value_thb numeric(12,2)
    - ctr numeric(7,4) GENERATED  # clicks / impressions
    - cpc numeric(8,2) GENERATED  # spend / clicks
    - cpm numeric(8,2) GENERATED  # spend / impressions * 1000
    - conv_rate numeric(7,4) GENERATED  # conversions / clicks
    - cpa_thb numeric(10,2) GENERATED  # spend / conversions
    - roas numeric(8,4) GENERATED  # conversion_value / spend
  quality_layer (platform-specific, jsonb):
    - quality_score (Google Ads — 1-10)
    - relevance_score (Meta — 1-10)
    - quality_ranking_engagement_rate_ranking_conversion_rate_ranking (Meta — low/avg/high)
```

**Rationale:**

- **Why a separate DR (not folded into DR-026):** DR-026 ships now; DR-027 needs Phase 0 field data + platform API integrations (Google Ads API, Meta Marketing API) before its full schema can be validated. Locking the architecture before brands have real campaign data risks premature DDL that needs migration later.
- **Why hint it in v1.12 (Bible Part 29.11):** Future readers need to know the `campaign_id` TEXT stub on `seo_page_master` is *transitional* — the FK target will materialize. Without the hint, brands might invest in alternative tracking (Notion-only, spreadsheets) that becomes legacy.
- **Why multi-platform from day 1 (when implemented):** Same operator vision — adding Meta/YouTube/TikTok later as separate tables creates platform silos. Single `platforms text[]` + per-platform junction rows scales cleanly.
- **Why include `campaign_pages` AND `campaign_keywords` M2M (not just one):** Many-to-many on both axes is real. 1 LP often serves multiple campaigns over time (especially Hero LPs); 1 campaign often targets multiple keyword clusters across platforms with different match strategies.
- **Why a separate `_performance_snapshot` table (not columns on `seo_campaigns`):** Mirrors successful pattern of `seo_x_ads_keywords_x_url_daily_logs` (DR-022 referenced). Keeps `seo_campaigns` static-ish (campaign-level config); performance rows grow daily and need partition-ready architecture.

**Consequences:**

- ✅ Phase 0 (DR-026) brands can launch Ads today using `campaign_id` TEXT stub
- ✅ When DR-027 ships, migration path is mechanical: parse distinct TEXT values, create `seo_campaigns` rows, populate `campaign_pages` junction from existing page rows, populate `campaign_keywords` from any KW-side ad_active flags already present
- ⚠️ Phase 0 brands MUST adopt a campaign_id naming convention from day 1 (e.g., `{brand-id}-{purpose}-{date-suffix}`) to make migration painless — Bible Part 29.11 documents naming convention
- ⚠️ Reporting Dashboard (cross-platform consolidated view) is a Phase 2 deliverable post-DR-027 lock — not promised in any Phase 0 brand handover
- ⚠️ Google Ads API + Meta Marketing API integration is operator workload (n8n flows) — DR-027 doesn't ship those flows, only the table that receives their output

**Open Questions (resolve before locking):**

- Should `seo_campaigns` carry attribution model field (last-click / data-driven / position-based) per platform, or live in performance snapshot? Decision deferred — operators rarely change model mid-campaign.
- Should `campaign_keywords.match_type` be platform-specific enum (Google match types vs Meta audience types are semantically different)? Likely yes — split into platform-typed jsonb `targeting_config` instead of single enum. Final form TBD with real Meta campaign data.
- Cross-brand campaigns (1 campaign for 2 brands — e.g., shared anti-aging launch by Genowell + Dr. Trin) — multi-brand FK or junction? Defer until ecosystem campaigns become real (Vertex node use case).

**References:**

- DR-026 (Ads-LP Phase 0 — predecessor, this DR is the Phase 1 successor)
- Bible Part 29.11 (Future: Campaign Master Track — placeholder hint)
- Bible Part 5 (Database Schema Architecture — host group for `seo_campaigns`)
- Operator vision document (predates EYWA spec) — keyword + page + entity as dimensional backbone, horizontal expansion via track tables
- Schema v1.12 §X (hint section only — no DDL); full DDL in Schema v1.13+

---

### [DR-026] — Ads Landing Page Track (Phase 0) (2026-05-12) 🌱📣

**Status:** Proposed (review window opens 2026-05-12, target lock 2026-06-21 — 40-day soak per Handover §9 default; pilot validation expected via VTH BioDent Google Ads launch ~2026-05-15)
**Bible Reference:** Part 29 (NEW — Ads Landing Page Track), Part 4 (Sitemap Architecture — Layer 1/2 unchanged; Ads-LP is parallel track)
**Schema Reference:** v1.12 (additive columns on `seo_page_master` + `seo_x_ads_keywords_contextual_master`; no new tables in Phase 0)
**Pairs with:** DR-027 (Campaign Universal Master — Future Phase 1 successor)

**Context:**

EYWA Protocol v3.15 is a comprehensive SEO + content + knowledge-graph specification. It has NOT addressed paid acquisition (Google Ads, Meta Ads, YouTube Ads, etc.) as a deliverable track. Operators have multiple live brand engagements (VTH BioDent, SmileScape, Dr. Trin, etc.) that will or have started running Google Ads — without spec guidance, each brand reinvents:

1. **LP architecture** — should the Hero Service SEO page double as Ads LP, or is `/lp/{slug}/` parallel structure required?
2. **Page table modeling** — is an Ads LP a row in `seo_page_master`? How does it differ from a SEO page?
3. **Keyword reuse** — when a brand bids on a keyword that also has an SEO target, how is the dual-use recorded? Are budgets/match-types stored anywhere?
4. **URL conventions** — `/lp/`, `/go/`, `/ad/`, `/promo/`? Index policy? Schema rules?
5. **YMYL governance** — do medical Ads LPs still require citation evidence rules (Bible Part 23)? (Yes — clarify in spec.)
6. **Templates** — current Content_Templates v1.3 lacks any Ads-optimized template; T1-T22 series targets SEO E-E-A-T + topical authority, not single-CTA conversion-focused LPs.

Without DR-026, brand work fragments into per-brand patterns that drift, contradict, and make Federation cross-brand analysis (cross-brand ad performance benchmarking) impossible.

**Decision:**

Establish the **Ads Landing Page Track** as a *parallel* implementation track to the existing SEO Track. The Ads Track rides on the **same dimensional backbone** (page_master, keyword_master, entity_graph) with **additive schema columns** + a **dedicated template family (T-ADS-X)** + a **new Bible Part (Part 29)**.

#### A. Page Purpose Taxonomy (additive enum on `seo_page_master`)

```yaml
page_purpose enum:
  seo_organic:
    description: Pure SEO page — indexed, hub-spoke, topical authority builder
    index_directive: index
    nav_treatment: full site nav
    cta_count: multiple soft CTAs allowed
    template_family: T1-T22 (SEO templates per Content_Templates v1.3)

  ads_lp:
    description: Pure Ads landing page — conversion-optimized, often noindex
    index_directive: noindex_lp (default) — operator can override per campaign for evergreen LPs
    nav_treatment: stripped or minimal (no full site nav distraction)
    cta_count: ONE primary CTA, repeated 2-3x on page
    template_family: T-ADS-1 to T-ADS-5 (NEW per Content_Templates v1.4)

  dual_use:
    description: Page serves BOTH SEO + Ads (commercial/transactional intent + conversion-optimized)
    index_directive: index
    nav_treatment: full site nav
    cta_count: dominant primary CTA but supporting SEO content depth
    template_family: T-DUAL-X (subset of T-ADS hybridized with T2 service-page) — see §29.6 eligibility
    eligibility_gate: must pass §29.6 Dual-Use Eligibility Criteria
```

#### B. URL Convention

```yaml
seo_organic pages: /{vertical-slug}/{topic-slug}/  # existing Bible Part 4 convention
ads_lp pages: /lp/{campaign-or-offer-slug}/  # NEW — `/lp/` segment marks Ads track
dual_use pages: existing SEO URL (no change) — flagged via page_purpose only
```

Rationale for `/lp/` prefix: visually clear to operators + analytics teams that the URL is an Ads LP; easy regex for Quality Score audits, robots.txt directives (e.g., AI crawler block on `/lp/*` if desired), and report segmentation.

#### C. Index Directive Enum (additive on `seo_page_master`)

```yaml
index_directive enum:
  index: standard — indexed by search engines (default for seo_organic + dual_use)
  noindex_lp: noindex,follow — Ads LP not indexed but link equity flows (default for ads_lp)
  noindex_nofollow: noindex,nofollow — fully isolated (e.g., A/B variant)
  dual: indexed AND served as Ads LP (rare — dual_use pages)
```

#### D. Conversion Event Taxonomy (additive on `seo_page_master`)

```yaml
conversion_event_primary enum:
  lead_form: form submission
  call_click: phone CTA click
  line_follow: LINE Add Friend / chat-initiate
  booking: appointment booking submitted
  download: lead magnet download
  package_view: pricing/package PDF view (high-intent intermediate signal)
  add_to_cart: e-commerce (rare in EYWA — most brands are clinic)

conversion_event_secondary text[]:  # additional events tracked but not primary KPI
```

Maps cleanly to Google Ads Conversion Actions + Meta Pixel Standard Events.

#### E. Campaign ID Stub (transitional column on `seo_page_master`)

```yaml
campaign_id text nullable:
  purpose: Phase 0 placeholder for campaign association
  values: free-form slug (operator convention: "{brand-id}-{purpose}-{date-suffix}", e.g., "vth-biodent-launch-2026-q2")
  future_state: when DR-027 locks, this column becomes campaign_fp (text FK → seo_campaigns)
  migration_plan: parse distinct values, create seo_campaigns rows, populate junction
```

#### F. Keyword Schema Extensions (additive on `seo_x_ads_keywords_contextual_master`)

```yaml
seo_active boolean default true:
  description: Keyword used in SEO content strategy
  rationale: explicit flag — some keywords are Ads-only (e.g., competitor brand bidding)

ad_active boolean default false:
  description: Keyword used in Ads bidding strategy (Google, Meta, etc.)

ad_intent_score smallint:  # 1-10
  description: How well the keyword fits Ads (10 = transactional/commercial buyer-ready, 1 = pure informational)
  rationale: helps operator decide which SEO keywords promote to Ads
  default: NULL (operator scores during keyword research)

ad_match_type_preferred enum:
  values: exact | phrase | broad | broad_modified
  rationale: planning-time preference; actual platform match enforced at campaign level

ad_landing_page_fp text nullable:
  description: FK to seo_page_master.fingerprint — the LP intended for this KW
  rationale: 1 keyword → 1 primary LP for now (Phase 0); Phase 1 moves to campaign_keywords M2M

ad_priority_tier enum: t1 | t2 | t3 | none
  description: Budget priority — t1 = always-on hero KW, t2 = supporting, t3 = exploratory
```

#### G. T-ADS Template Family (Content_Templates v1.4 — NEW)

5 templates ship Phase 0:

```yaml
T-ADS-1: Hero Service LP
  purpose: Single-service conversion focus (e.g., "Dental Implant Free Consultation")
  block_structure: Hero (offer + CTA) → Trust strip (logos/credentials) → Benefits (3-5 bullets) → Social proof (review snippets) → Process (3-step) → FAQ (5 max) → Final CTA + booking widget
  word_count_target: 400-800 words
  schema: Organization + LocalBusiness + Offer + (medical brands: MedicalBusiness)

T-ADS-2: Booking / Consultation LP
  purpose: Drive appointment booking — calendar widget prominent
  block_structure: Hero (offer + booking widget above fold) → What you get (3 bullets) → Doctor intro (1 person, photo + 2-line credential) → 1-paragraph social proof → FAQ (3 max) → Repeat booking CTA
  word_count_target: 300-600 words
  schema: Organization + Offer + Person (doctor)

T-ADS-3: Promo / Limited Offer LP
  purpose: Time-bound offer (countdown, scarcity) — e.g., "Founding 100 patients only"
  block_structure: Hero (offer + countdown timer + CTA) → What's included (price stack) → Why now (urgency rationale) → Eligibility (who qualifies) → How to claim (3-step) → Repeat CTA + terms
  word_count_target: 350-700 words
  schema: Organization + Offer (with priceValidUntil)
  guardrail: Bible Part 23 YMYL evidence rules STILL APPLY for medical claims; price/promo terms must be operator-verified

T-ADS-4: Comparison / Alternative LP
  purpose: Win clicks from competitor brand keywords or alternative-seeking intent
  block_structure: Hero (positioning statement) → Comparison table (us vs alternative — neutral framing) → Differentiation bullets (3-5) → Doctor/credential trust → CTA
  word_count_target: 500-900 words
  schema: Organization + (no Offer if pure positioning)
  guardrail: Comparative claims must avoid disparagement (Bible Part 23.5 + Thai consumer protection law). If naming competitors, use factual public information only.

T-ADS-5: Lead Magnet / Download LP
  purpose: Email/LINE capture in exchange for downloadable resource (e-book, guide, checklist)
  block_structure: Hero (asset preview + capture form) → What's inside (3-5 bullets) → Who it's for → Author credential (1-line) → Form (minimal fields) → Privacy note
  word_count_target: 200-400 words
  schema: Organization + (resource = ImageObject or CreativeWork)
  data_capture: PDPA consent checkbox MANDATORY per Bible Part 23.6
```

#### H. Dual-Use Eligibility Criteria (when a SEO page CAN serve as Ads LP)

A page can be `page_purpose='dual_use'` ONLY IF:

1. **Intent match:** Page targets commercial/transactional intent keyword (not informational/research)
2. **CTA prominence:** Primary CTA visible above fold on mobile + repeated at 1-2 mid-page positions
3. **Conversion infrastructure:** Conversion tracking pixel/event installed; LINE/phone/form CTAs all wired to GTM
4. **Page load:** CWV LCP < 2.5s mobile, CLS < 0.1, INP < 200ms (matches Bible Part 19 CWV standards)
5. **Content focus:** Single dominant offer (not a hub page listing 10 services)
6. **Quality Score viability (post-launch check):** Google Ads Quality Score ≥ 7 after 2-week stabilization; if < 7 for 4+ weeks, demote to seo_organic and build parallel `/lp/` version

Operator MUST document dual_use justification in `viability_assessment` column (Bible Part 4.14 reuse) when marking a page dual_use.

#### I. YMYL Evidence Rules — UNCHANGED for Ads LPs

Bible Part 23 (Medical Content Excellence) citation tier rules + editorial review workflow apply IDENTICALLY to Ads LPs that make medical claims. Ads LPs do NOT get a YMYL exemption. Rationale: Thai PDPA + medical advertising regulations (พรบ.การโฆษณาทางการแพทย์) + Google's ad policy enforcement of medical claim accuracy. Brand legal exposure does not decrease because content is on a `/lp/` URL.

#### J. Phase 0 Scope Boundary

Explicitly NOT shipped in DR-026:

- ❌ `seo_campaigns` table (deferred to DR-027 Phase 1)
- ❌ Cross-platform Meta Ads, YouTube Ads, LINE Ads, TikTok Ads orchestration (architectural sketch only in DR-027)
- ❌ Performance snapshot pipeline (n8n Google Ads API → Supabase flow)
- ❌ Consolidated dashboard (Phase 2)
- ❌ A/B testing variant management (Phase 2 — likely separate DR)

**Rationale:**

- **Why Proposed (not Locked):** Standard 40-day soak per Handover §9 default. Pilot validation via VTH BioDent Ads launch will surface real-world spec gaps before lock — locking before pilot risks DDL changes post-deployment.
- **Why parallel `/lp/` URL structure (not subdirectory of service pages):** Clean separation of analytics scope, ability to robots.txt or noindex en masse, immediate visual signal in operator/legal review. Service page URLs remain canonical for organic.
- **Why same `seo_page_master` table (not separate `ads_lp_pages` table):** Operator vision is dimensional — every URL is a row, every URL has fingerprint, every URL has CWV metrics. Splitting into ads vs seo tables would duplicate the page lifecycle logic, fragment reporting, and break the single-table dashboard story.
- **Why `campaign_id` TEXT stub (not FK from day 1):** Phase 0 needs to ship before DR-027 can ship; FK requires the target table to exist. TEXT stub captures operator intent for clean migration later. Cost of "wrong stub value" is low (rename string); cost of NOT capturing campaign association now is high (impossible to attribute Phase 0 page rows to campaigns retrospectively).
- **Why T-ADS-1 through T-ADS-5 (not more):** 5 templates cover ~95% of clinic/wellness Ads use cases. Add T-ADS-6+ only when a brand surfaces a use case not handled by existing 5 — avoid speculative templates.
- **Why YMYL rules unchanged (no relaxation for LPs):** Legal/regulatory exposure is per-claim, not per-URL. A medical claim on `/lp/dental-implant/` carries identical risk as on `/services/dental-implant/`. Spec consistency reinforces brand discipline.

**Consequences:**

- ✅ Operators can launch Google Ads with structured spec compliance — page model, KW model, template choice all defined
- ✅ Federation cross-brand Ads benchmarking becomes possible (same `page_purpose` enum, same Quality Score model, same conversion event taxonomy across 13 brands)
- ✅ Phase 0 → Phase 1 (DR-027) migration path is clean (TEXT stub → FK)
- ✅ VTH BioDent Ads launch (target ~2026-05-15) has spec to follow — no per-brand reinvention
- ✅ Bible v3.16 ships with Part 29 (Ads Landing Page Track) as first-class spec section
- ⚠️ Schema v1.12 migration: 5 columns added to `seo_page_master`, 6 columns added to `seo_x_ads_keywords_contextual_master` (all nullable, additive — zero downtime)
- ⚠️ Content_Templates v1.4 adds T-ADS-1 through T-ADS-5 as new family (DRAFT status, pending DR-020 lock cycle 2026-06-07)
- ⚠️ Brand snapshot blocks (`eywa_spec_snapshot`) need refresh at next Stage gate for brands currently on bible_version 3.15
- ⚠️ Quality Score < 7 dual_use demote workflow needs operator runbook (deferred to Brand Handover §X update post-pilot)
- ⚠️ Conversion tracking n8n flow (Google Ads Conversions API → Notion + Supabase) is operator work — DR-026 doesn't ship the flow, only the data model that receives it

**Open Questions (resolve during pilot, before lock):**

- Does T-ADS-3 (Promo) need PDPA consent banner pattern documented in template (alongside the form on T-ADS-5)? Likely yes for any LP with form capture — clarify in v1.4 lock.
- Should `index_directive='noindex_lp'` also imply removal from sitemap.xml? Default to YES (excluded from XML sitemap); operator override allowed for evergreen LPs.
- Cross-brand "competitor Ads LP" pattern (e.g., Trin running an Ads LP that compares against W9 by name) — needs Bible Part 23.5 comparative-claim discipline reinforcement? Yes; add §29.10 cross-ref to Part 23.5.
- For Thai clinics: should T-ADS-2 (Booking) include LINE-first capture pattern as default (LINE OA Add Friend > form)? Most clinic brands prioritize LINE; document as template variant.

**References:**

- Bible Part 29 (NEW — Ads Landing Page Track, ships in v3.16)
- Bible Part 4 (Sitemap Architecture — Ads-LP is parallel track, not Layer 1/2 substitute)
- Bible Part 23 (Medical Content Excellence — YMYL rules apply to Ads LPs unchanged)
- Bible Part 19 (Data Quality + CWV — dual_use eligibility gate)
- Content_Templates v1.4 §X (T-ADS-1 through T-ADS-5)
- Schema v1.12 §5.1 (seo_page_master additions), §6.X (keyword_master additions), §X.X (seo_campaigns hint for Phase 1)
- DR-022 (Lean Phase B + Two-Layer Sitemap — Ads is third dimension, not part of Layer 1/2)
- DR-027 (Campaign Universal Master — Phase 1 successor)
- Operator vision document (predates EYWA spec) — keyword + page as dimensional backbone, Ads as horizontal expansion

---

### [DR-025] — Restore Local SEO Tables + Consolidate `seo_locations` → `seo_branches` (2026-05-12) 🔒🏥

**Status:** Locked 2026-05-12
**Bible Reference:** Part 4.4 (Type B Branch Landing), Part 10.5 (Local SEO), Part 17.6 (n8n GROUP E Flows), Appendix B.5
**Schema Reference:** v1.11 (Group 1 — Brand & Organization)

**Context:**

Bible v3.14 Appendix B.5 specifies a **5-table Local SEO subsystem** (Category D, Phase 1 Day 1 for clinic verticals): `seo_locations`, `seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`, `seo_local_rankings`. Bible Part 17.6 (n8n GROUP E) defines 4 operational flows (E1 GBP Reviews sync 6h, E2 GBP Posts publish, E3 NAP audit weekly, E4 GBP Posts metrics) that depend on these tables.

Schema_Overview v1.10 silently dropped 3 of these tables (`seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`) — never explained, never DR'd. Only `seo_local_rankings` survived (Group 5) and `seo_locations` was renamed to `seo_branches` (Group 1, Section 3.2) with a **minimal schema (~25 cols)** missing ~15 columns specified in Bible Table 24 (multi-directory IDs, GBP categories/rating, photos, compliance, staff assignment, special hours).

Without these tables: Bible n8n Group E flows are non-implementable; clinic brands (VTH BioDent, Deezy, TC Smile, SmileScape, Dr. Trin) cannot deliver Local SEO at Day 1 (Bible Part 10.5 promise).

**Decision:**

**A. Restore all 5 Local SEO tables in Schema v1.11.** Three are net-new (reviews, directory_listings, gbp_posts), one is enhanced (branches), one already exists (local_rankings — only FK rename needed).

**B. Consolidate `seo_locations` → `seo_branches`** as the canonical name. Reasons:
- `seo_branches` already exists in Schema v1.10 with real `branch_*` fingerprint columns + Notion sync state
- Bible Part 4.4 already uses "Branch Landing" terminology
- Thai operator context: "สาขา" (branch) is the established business term
- Semantically 1 brand → N branches, 1 branch = 1 physical location (1:1 mapping) — no need for 2 tables
- Renaming in Bible (~8 references) is cheaper than renaming in Schema + Notion + n8n flows

**C. Enhance `seo_branches` to full Bible Table 24 spec** — add ~15 columns:
- NAP completeness: `business_name_legal`, `business_name_brand`, `district`, `formatted_address`, `plus_code`
- Contact: `line_id`, `special_hours jsonb`
- Staff/Equipment: `doctors_at_branch_fps text[]` (→ seo_authors_reviewers), `equipment_at_branch_fps text[]`, `specialties_at_branch text[]`
- GBP completeness: `gbp_account_id`, `gbp_categories text[]`, `gbp_review_count int`, `gbp_avg_rating numeric(3,2)`, `gbp_last_synced_at timestamptz`
- Other directories: `apple_maps_id`, `facebook_page_url`, `wongnai_url`, `wongnai_id`
- Schema/Photos: `local_business_schema_type`, `primary_photo_url`, `exterior_photos text[]`, `interior_photos text[]`
- Status/Compliance: `status` (active/closed/temp-closed), `opened_date`, `closed_date`, `business_registration_no`, `medical_license_no`
- NEW FK: `organization_entity_id uuid FK→seo_entity_graph(id)` — links branch to its organization entity for KG

**D. Three new tables (full schemas in Schema v1.11 §3.5/3.6/3.7):**

```yaml
seo_reviews:
  purpose: Multi-platform review aggregation + PDPA-safe response workflow
  fk: branch_id→seo_branches, brand_id→brands, responded_by_fp→seo_authors_reviewers, mentioned_entities_fps[]→seo_entity_graph
  sources: GBP, Wongnai, Facebook, Google Maps, Pantip mentions
  unique: (source_platform, source_review_id) — dedupe
  pdpa_critical: response_legal_reviewed, pdpa_risk_flag, reviewer_anonymized
  flow: E1 (GBP Reviews sync every 6h)

seo_directory_listings:
  purpose: Track NAP citations across ~50 directories per branch + auto-detect inconsistency
  fk: branch_id→seo_branches, brand_id→brands
  distinct_from: seo_citations (academic/PubMed — these are Local SEO directory listings)
  key_fields: directory_name, citation_url, status, claim_status, business_name_listed, address_listed, phone_listed, nap_match_score (GENERATED), has_inconsistency
  flow: E3 (NAP audit weekly)

seo_gbp_posts:
  purpose: GBP Posts management + local archive (GBP posts disappear after 6 months)
  fk: branch_id→seo_branches, brand_id→brands, approved_by_fp→seo_authors_reviewers
  multi_location: batch_id, parent_post_id (cross-branch campaigns)
  flows: E2 (publish), E4 (metrics sync daily)
```

**E. `seo_local_rankings` FK rename:** `location_id` → `branch_id` (FK → `seo_branches`). Already in Schema v1.10 Group 5 — Bible Table 28 referenced `location_id` which never matched the actual schema.

**F. Bible Appendix B.5 + Part 17.6 + Part 4.4 rename:** All 8 references to `seo_locations` in Bible v3.14 become `seo_branches`. Bumps Bible v3.14 → v3.15.

**Rationale:**

- **Why now (not deferred):** Clinic brands are in active Stage 1 work (VTH BioDent done, SmileScape Phase E, 3 others queuing). Phase 5 of any clinic deployment requires Local SEO — postponing forces architecture rework later.
- **Why Locked immediately (no Proposed soak):** This is a *restore of forgotten spec*, not new design. Bible v3.14 already documented these tables (Appendix B.5 unchanged since v2.3 / 2026-05-01); Schema simply fell behind. The DR formalizes catch-up, doesn't propose new ideas.
- **Why consolidate to `seo_branches` (not `seo_locations`):** See §B above. Lower total churn (rename Bible once vs rename Schema + Notion + n8n + downstream brand docs).

**Consequences:**

- ✅ Bible n8n GROUP E flows (E1/E2/E3/E4) become implementable
- ✅ Clinic brand Phase 5 (Local SEO) unblocked
- ✅ NAP consistency monitoring + PDPA-safe review responses operational
- ✅ Schema v1.11 ships with Group 1 = 7 tables (was 4), Group 5 unchanged
- ⚠️ Migration files needed: `009_enhance_seo_branches.sql`, `010_create_seo_reviews.sql`, `011_create_seo_directory_listings.sql`, `012_create_seo_gbp_posts.sql`, `013_rename_local_rankings_fk.sql`
- ⚠️ Existing brands with `seo_branches` rows: backfill new columns as available (NULL allowed initially)
- ⚠️ Bible v3.15 ships paired with Schema v1.11 — coordinated bump
- ⚠️ Brand snapshot blocks (`eywa_spec_snapshot`) need refresh at next Stage gate for brands currently on bible_version 3.14

**References:**
- Bible Part 4.4 (Type B Branch Landing) — naming origin
- Bible Part 10.5 (Local SEO) — strategic rationale
- Bible Part 17.6 GROUP E (n8n Flows E1-E4) — operational dependencies
- Bible Appendix B.5 (5-table Local SEO subsystem)
- Schema v1.11 §3.2 (enhanced seo_branches), §3.5 (seo_reviews), §3.6 (seo_directory_listings), §3.7 (seo_gbp_posts), §7.2 (seo_local_rankings FK rename)
- DR-024 (paired — Restore 9 Extension Tables, same v1.11 release)

---

### [DR-024] — Restore 9 Entity Extension Tables (2026-05-12) 🔒🧬

**Status:** Locked 2026-05-12
**Bible Reference:** Part 2.5 (Entity Polymorphism), Part 5.11 (Group 9), Part 14 (Vertical Profiles), Appendix B.3
**Schema Reference:** v1.11 (Group 9 — Entity Extensions & Templates)

**Context:**

Bible v3.14 Appendix B.3 specifies **9 type-specific extension tables** (Category B, 1:1 FK to `seo_entity_graph` ON DELETE CASCADE, populate trigger when `entity_type` matches):

```
11. seo_entity_ingredient   (entity_type='ingredient')
12. seo_entity_product      (entity_type='product')
13. seo_entity_procedure    (entity_type='procedure')
14. seo_entity_condition    (entity_type='condition')
15. seo_entity_drug         (entity_type='drug')
16. seo_entity_anatomy      (entity_type='anatomy')
17. seo_entity_organization (entity_type='organization')
18. seo_entity_lab_test     (entity_type='lab_test')
19. seo_entity_device       (entity_type='device')
```

This was introduced in Bible v2.0 (2026-04-30) as the universal core + extension pattern (`#`universal entity_graph` + 1:1 type-specific extension`) and has not changed in strategy since.

Schema_Overview v1.10 documents only 3 of 9 extensions (`ingredient`, `procedure`, `device`) in Group 9 (§11.1-11.3) plus `seo_programmatic_templates` (§11.4 — unrelated to entity polymorphism). The remaining 6 extensions (product, condition, drug, anatomy, organization, lab_test) silently disappeared between Schema v1.0 (which Bible §5.11 line 6918 references for "Full schemas + all 22-24 columns per extension table") and v1.10. No DR explained the removal.

Without these tables: T1 medical-condition template (Bible Part 4.1.1) has no condition extension to bind ACF fields; drug monograph pages have no monograph store; anatomy entities can't carry FMA/UBERON IDs for knowledge graph; external orgs collapse into either `brands` (wrong scope) or generic `entity_graph` (loses typed columns).

**Decision:**

**A. Restore 6 missing extension tables in Schema v1.11 Group 9.** All 1:1 FK to `seo_entity_graph(id)` via `entity_fp text FK→seo_entity_graph.fingerprint` (matches pattern of `seo_entity_ingredients` v1.10 §11.1).

```yaml
seo_entity_product:
  entity_type: product
  schema_org: Product, MedicalDevice (overlap)
  key_fields: gtin, sku, brand_owner_fp, product_category, ingredients_fps[]→seo_entity_ingredient, thai_fda_reg_no, regulatory_status, pregnancy_safe, certifications[], price_range
  used_by: the brand (skincare), Dr. Trin (supplement), any brand selling product
  template: T-product, T-comparison, T-listicle

seo_entity_condition:
  entity_type: condition
  schema_org: MedicalCondition
  key_fields: icd10_code, snomed_ct_id, mesh_id, prevalence_thailand, severity_levels[], symptoms[], related_anatomy_fps[]→seo_entity_anatomy, treatment_drugs_fps[]→seo_entity_drug, treatment_procedures_fps[]→seo_entity_procedure, affected_age_groups[]
  used_by: ALL medical brands (VTH, Deezy, SmileScape, Dr. Trin, the brand)
  template: T1-medical-condition (primary Bible Part 4.1.1)

seo_entity_drug:
  entity_type: drug
  schema_org: Drug
  key_fields: rxnorm_code, atc_code, thai_fda_reg_no, prescription_required, indications_fps[]→seo_entity_condition, contraindications_fps[]→seo_entity_condition, side_effects[], pregnancy_category, breastfeeding_category, controlled_substance_class
  used_by: VTH (post-surgery antibiotics), Dr. Trin (TRT/vitamins), the brand (cosmeceuticals borderline)
  template: T-drug-monograph

seo_entity_anatomy:
  entity_type: anatomy
  schema_org: AnatomicalStructure
  key_fields: fma_id (Foundational Model of Anatomy), uberon_id, body_system, parent_anatomy_fp (self-FK hierarchy), child_anatomy_fps[], affected_by_conditions_fps[]→seo_entity_condition
  used_by: ALL medical brands (anatomy → condition → procedure knowledge graph)
  template: T-anatomy-reference (mostly supporting entity, rarely standalone page)

seo_entity_organization:
  entity_type: organization
  schema_org: Organization, MedicalOrganization
  key_fields: wikidata_qid, legal_name, founding_date, headquarters_location, parent_organization_fp (self-FK), organization_type (clinic/hospital/professional_association/regulator/manufacturer/accreditation_body)
  used_by: ALL brands — external orgs (Thai Dental Association, Thai FDA, ADA, Wikidata Q-entities, manufacturers)
  scope_note: SEPARATE from `brands` table — brands = own brands (~10-50); seo_entity_organization = external refs (~100-500)
  template: About pages, citation source attribution, accreditation refs

seo_entity_lab_test:
  entity_type: lab_test
  schema_org: MedicalTest
  key_fields: loinc_code, cpt_code, test_category (imaging/blood/biopsy), sample_type, preparation_instructions, reference_ranges[], related_conditions_fps[]→seo_entity_condition
  used_by: VTH (x-ray, CBCT, blood test pre-surgery), Dr. Trin (hormone panel), future hospitals
  template: T-diagnostic-service, T-test-info
```

**B. Keep existing 3 extensions** (`seo_entity_ingredients`, `seo_entity_devices`, `seo_entity_procedures`) — already in §11.1-11.3. Plural form (`ingredients` not `ingredient`) preserved for backward compat; Bible Appendix B singular form treated as informal.

**C. Keep `seo_programmatic_templates`** as §11.10 (was §11.4) — not an entity extension, but logically Group 9 (template registry for Type C programmatic pages, Bible Part 9).

**D. Group 9 count update:** 4 → 10 tables (9 extensions + 1 template registry).

**Rationale:**

- **Why Locked immediately (no Proposed soak):** Bible v2.0 strategy unchanged for 13+ days; Bible Appendix B.3 has been authoritative since 2026-04-30; Schema v1.10 drop was undocumented (no DR, no changelog note) — clearly oversight, not deliberate design change. Restoring known-good spec doesn't warrant 2-week soak.
- **Why all 9 (not subset):** Bible Vertical Profiles (Part 14) explicitly maps 6 verticals to extension table usage (dental → procedure/condition/drug; skincare → ingredient/product/condition; etc.). Partial restoration creates per-vertical gaps.
- **Why `entity_fp` (text FK) not `entity_id` (uuid FK):** Matches existing §11.1 pattern (`entity_fp text FK→seo_entity_graph.fingerprint`). Fingerprint-based FKs align with DR-008 Two-Column Identity (immutable machine ID). Bible Appendix B.3 says "1:1 FK to `seo_entity_graph.id`" but Schema v1.10 §11.1 uses `entity_fp` — sticking with Schema convention; updating Bible to match.

**Consequences:**

- ✅ T1 medical-condition template binding becomes implementable (ACF field group ↔ seo_entity_condition columns)
- ✅ Knowledge graph cross-refs (condition ↔ anatomy ↔ drug ↔ procedure) become typed FKs not text matches
- ✅ External organization citation source attribution becomes schema-clean (separate from `brands`)
- ✅ All clinic, dental, dermatology, hospital, skincare-media verticals (Bible Part 14) become Day-1 schema-complete
- ⚠️ Migration files needed: `014_restore_entity_product.sql`, `015_restore_entity_condition.sql`, `016_restore_entity_drug.sql`, `017_restore_entity_anatomy.sql`, `018_restore_entity_organization.sql`, `019_restore_entity_lab_test.sql`
- ⚠️ Each extension table needs populate trigger: `trg_populate_entity_{type}_on_insert` (fires when `entity_graph.entity_type = '{type}'`)
- ⚠️ Bible Appendix B.3 column hints (2026-04-30 era) need cross-check against current Schema v1.11 column definitions; minor field rename per current naming convention possible
- ⚠️ Brands actively building T1 medical-condition pages (VTH BioDent OSA, etc.) gain schema binding at next Stage 1.5 gate

**References:**
- Bible Part 2.5 (Entity Polymorphism — universal core + extension pattern)
- Bible Part 5.11 (Group 9 — Entity Extensions & Templates)
- Bible Part 14 (Vertical Profiles — per-vertical extension usage)
- Bible Appendix B.3 (Tables 11-19, schema summaries)
- Schema v1.11 §11.1-11.9 (extensions) + §11.10 (programmatic_templates)
- DR-025 (paired — Restore 5 Local SEO Tables, same v1.11 release)
- DR-008 (Two-Column Identity — fingerprint FK pattern)

---

### [DR-022] — Lean Phase B + Two-Layer Sitemap + Iterative Refinement (2026-05-11 → Locked 2026-05-12) 🔒🌳

**Status:** **Locked 2026-05-12** (early lock — field-tested across 5 brands; review board fast-tracked per operator approval; ≥99.99% Google-principle aligned per Bible Part 1.5 + industry consensus 2026)
**Locked Bible Version:** v3.19 (Part 4 Two-Layer Sitemap pattern already authoritative; lock formalizes status)
**Locked Schema Version:** v1.15 (no DDL change — uses existing 4 KW tables)
**Bible Reference:** Part 4 (Sitemap Architecture), Part 23.1 (Citation), Part 25.6 (Brand Config)
**Schema Reference:** No schema changes — uses existing 4 KW tables (`seo_x_ads_keywords_contextual_master`, `seo_x_ads_keywords_monthly_market_snapshot`, `seo_x_ads_keyword_serp_competitors`, `seo_x_ads_keywords_x_url_daily_logs`)

**Lock Audit Trail (2026-05-12):**

```yaml
field_test_evidence:
  - "Deezy Dental: Sitemap 764p + Entity 251 + Keywords 2,103 done using Layer 1/Layer 2 split"
  - "Classy Clinic: Phase B+C+D complete (808p v18, 279 entities, 28 clusters) per Lean Phase B pattern"
  - "VTH BioDent: Stage 1 done using brand-immune Layer 1 + volume-driven Layer 2"
  - "SmileScape: Phase E in progress (414p WIP) per Two-Layer pattern"
  - "Trin Wellness: Phase B keyword research + competitor scan + patient journey + citations all per DR-022 lean template"
operator_approval:
  date: 2026-05-12
  rationale: |
    Cross-brand field test depth (5 brands × 2-3 months) exceeds typical Proposed soak.
    Two-Layer Sitemap principle is industry consensus 2026 (HubSpot, Ahrefs, SEMrush
    confirm volume-immune topical authority Layer 1 + volume-driven Layer 2 pattern).
    Brand-immune E-E-A-T topical authority IS Google's stated March 2026 Core Update
    priority. Waiting until 2026-06-07 review provides marginal certainty at
    meaningful operational cost (5 brands × 3 weeks stalled decision-making).
follow_up_workload:
  - "Companion DRs lock together (DR-019/020/021) — paired batch"
  - "DR-016 Page Viability §4.14 amendment for Layer 1 exemption (already locked)"
  - "Brand snapshot block refresh at next Stage gate for brands on bible_version 3.18"
```


**Context:**

Original Phase B (Handover §7.3 v1.7) was a single lump phase mixing competitor scan, KW research, patient journey, content audit. Field-tested with VTH BioDent + SmileScape revealed three operational problems:

1. **Volume gate confusion** — Spec didn't say whether DFS volume data was required before sitemap/entity work could proceed. Operators either over-waited (bottleneck) or skipped volume entirely (under-prioritized).
2. **Cost inefficiency** — Pulling DFS SERP scrape on full seed list (~680 KW for SmileScape) wastes spend on long-tail KW that get cut anyway. SERP scrape is the expensive endpoint (~$0.60-2.00 per 1000 KW vs $0.05 for volume).
3. **Volume-driven page cuts vs brand-driven sitemap conflict** — Some operators cut service pages with low volume, fragmenting topical authority and brand narrative. Industry shift (Google E-E-A-T era + AI search context absorption) favors complete topical coverage over volume-only selection.

**Decision:**

Reorganize Phase B into a **lean planning loop** with **async background enrichment** and **single iterative refinement**, replacing the volume-gated multi-phase model.

#### 1. Two-Layer Sitemap Architecture

```yaml
layer_1_brand_service:
  scope: [Section 1 Home, 2 Uniqueness, 3 Services, 4 Technology, 7 Branches, 8 Contact]
  policy: VOLUME-IMMUNE — every service/signature/founder/branch the brand has = page
  rationale: topical authority + E-E-A-T + brand truth + AI citation context completeness
  cut_allowed: NEVER for low-volume reasons

layer_2_knowledge_blog:
  scope: [Section 5 Concerns, Section 6 Knowledge]
  policy: VOLUME-DRIVEN — additions selected via gap discovery from enriched KW data
  rationale: traffic harvesting + AI citation entry + funnel TOFU
  cut_allowed: yes for Layer 2 candidates that fail Page Viability (DR-016)

layer_3_internal_linking:
  policy: VOLUME-AWARE for weighting, STRUCTURE-FIXED for existence
  rationale: priority_score guides authority flow; never used to delete pages
```

#### 2. Lean Phase B (single human-blocking phase, not 5 sub-phases)

```yaml
phase_B_lean:
  inputs:
    - brand-concept.md (Phase A output)
    - operator domain knowledge
    - WebSearch breadth research (competitor sitemaps, manual SERP/PAA peek, autocomplete)

  outputs:
    - keyword-seed-list.md         # Brand-driven KW dump (no DFS — current SmileScape pattern)
    - competitor-scan.md           # Layer 1 competitive landscape
    - citation-pool-seed.md        # 5-15 sources per pillar (existing Phase B.2)
    - patient-journey.md           # audience research

  what_NOT_to_do_in_phase_B:
    - DO NOT pull DFS volume here (deferred to async background)
    - DO NOT make page cuts based on volume (Layer 1 immune)
    - DO NOT block waiting for volume data
```

#### 3. Stage 1 Gate Adjustment

Stage 1 Gate confirms: **sitemap structure + entity graph + KW seed list + citation pool seed** — NOT volume data. Operator can proceed to Stage 1.5 with structural confidence alone.

#### 4. Stage 1.5 Push + Async Enrichment Trigger

```yaml
stage_1_5_migration:
  step_1: markdown content-plan/ → Supabase tables (existing)
  step_2: Notion ↔ Supabase sync (existing DR-006)
  step_3_NEW: n8n auto-trigger on seo_x_ads_keywords_contextual_master INSERT
              → cheap pull (volume + KD + CPC) into seo_x_ads_keywords_monthly_market_snapshot
              SLA: within 24-48h
              cost_gate: none (cheap)
  step_4_NEW: operator approves Tier A/B shortlist for SERP scrape
              → DFS SERP API → seo_x_ads_keyword_serp_competitors
              cost_gate: manual approval (~$0.10-0.30 per shortlist batch)
              SLA: within 7 days of approval
```

#### 5. Phase E.refine — Iterative Refinement (NEW phase, post-enrichment)

```yaml
phase_E_refine:
  trigger: enrichment data lands in monthly_market_snapshot + serp_competitors
  
  inputs_AI_analyzes:
    - seo_x_ads_keywords_contextual_master (operator authored)
    - seo_x_ads_keywords_monthly_market_snapshot (enriched volume + scores)
    - seo_x_ads_keyword_serp_competitors (PAA + related + competitor URLs)
    - sitemap.md (Layer 1 + Layer 2 current)
    - entities.md / clusters.md
  
  output: gap-report.md with structured findings:
    - high_vol_kw_no_entity        → entity gap to fill
    - high_vol_kw_no_page          → Layer 2 page candidate
    - paa_clusters_uncovered       → potential Section 5/6 page
    - autocomplete_expansions      → KW expansion suggestions
    - serp_feature_template_mismatch → template_id review
    - tier_reweight_proposals      → priority_score-based A/B/C adjustments
  
  refinement_scope_policy:
    ADD Layer 2 page                : ✅ free (gap-driven additions)
    SPLIT page (multi-intent PAA)   : ✅ free
    MERGE thin pages                : ⚠️ allowed if no live URL (pre-deploy)
    CUT page                        : ❌ NEVER (Layer 1 immune; Layer 2 stays unless DR-016 viability fails)
    REORDER tier A/B/C              : ✅ free (uses priority_score)
    
    flexibility_clause: operator may override on case-by-case basis with brand DR
                        (e.g., SS-DR-NNN logged in eywa-{brand}/docs/decision-records.md)
  
  process:
    1. AI generates gap-report.md
    2. Operator reviews each finding (✅/❌ per item)
    3. Sitemap delta applied (ADD-only by default, REORDER OK, MERGE conditional)
    4. Stage 1.5 Gate re-confirmed
```

#### 6. Phase F Content Production — KW Context Consumption

Content writers consume per-page KW context from `seo_x_ads_keywords_contextual_master`:

```yaml
content_brief_uses_kw_context:
  keyword_painpoint        → hook + intro section
  keyword_core_insight     → primary message + section narrative
  anxiety_level            → tone calibration (high anxiety → reassuring; low → informational)
  funnel_stage             → CTA strategy + page depth
  predicted_serp_features  → schema emit + section pattern (Featured Snippet → 40-60w direct answer)
  search_intent            → template_id confirmation (T1/T2/T6a/T7)
```

#### 7. Output File Restructure (deprecate `research-notes.md`)

Replace single dump with 5 specific files:

```
content-plan/
├── keyword-seed-list.md            (Phase B — operator)
├── competitor-scan.md              (Phase B — operator + WebSearch)
├── citation-pool-seed.md           (Phase B — existing)
├── patient-journey.md              (Phase B — operator)
├── keyword-volume-data.csv         (post-enrichment — n8n export, optional cache)
├── serp-intelligence-shortlist.md  (post-enrichment — Tier A/B only)
└── gap-report.md                   (Phase E.refine — auto-generated, operator-reviewed)
```

**Rationale:**

1. **Industry alignment:** Modern topical-authority SEO (2024-2026, post-HCU) favors brand-complete sitemaps over volume-only selection. AI search (SGE/AIO/Perplexity) reads whole-site context — missing service pages = missing context = reduced citation likelihood. Long-tail aggregation (200 pages × 10 vol = 2,000+/mo combined) often beats curated high-vol selection due to topical match.

2. **Cost efficiency:** Layered enrichment (cheap full-list volume + expensive shortlist SERP) is 30-60% cheaper than one-shot full-SERP pull. Maps directly to existing 4-table architecture which was designed for this pattern.

3. **Operator throughput:** Lean Phase B unblocks parallel work (Phase C entity / sitemap / citation / patient journey can all proceed without DFS). Refinement happens once asynchronously, not as a per-decision gate.

4. **Brand truthfulness:** Service pages exist because the brand offers the service, not because Google has volume. This serves SmileScape (specialty clinic with new/premium services like Ceramic Implant where Thai market awareness is still building) and similar mid-value vertical brands.

5. **Existing infrastructure leverage:** Supabase 4-table KW architecture + n8n workflows + Notion sync (DR-006) already built for this pattern. No schema migrations needed.

**Consequences:**

✅ **Positive:**
- Phase 1 timeline shortened (no DFS gate)
- Lower DFS cost per brand (~$0.50 vs ~$1.40 one-shot)
- Topical authority preserved (Layer 1 complete)
- Volume intelligence still consumed (Layer 2 augmentation + tier weighting + production prep)
- Content production gets richer per-page context (painpoint, anxiety, insight)

⚠️ **Trade-offs:**
- Refinement adds round-trip (Stage 1.5 → enrichment → refine → Stage 1.5 confirm)
- Operator must review gap-report.md (manual approval gate)
- SERP scrape requires manual approval (cost gate friction)

🚧 **Known limitations:**
- Bible §9.8 word-count standards still need volume for SERP-length comparison → falls in Phase F (post-Stage 1.5)
- DR-016 Page Viability §4.14 only applies to Layer 2 candidates (Layer 1 exempt) — needs Bible §4.14 amendment
- DR-018 Page Content Length Standards still applies to all pages (volume not required for Standards baseline)

**Migration Path (existing brands):**

| Brand | Stage | Action |
|-------|-------|--------|
| SmileScape | Stage 1 Phase E (414p WIP) | adopt DR-022 — current `keyword-research-dump.md` ↔ `keyword-seed-list.md`; defer DFS to Stage 1.5 background |
| VTH BioDent | Stage 1 Gate reached (Stage 1.5 blocked) | adopt DR-022 at Stage 1.5 entry — backfill split files from `research-notes.md` |
| 11 empty brands | Pre-Stage 1 | use DR-022 from inception |

**References:**

- Handover v1.8 §7.3 (Phase B restructure), §7.6.x (new Phase E.refine), §10 (Pre-Flight awareness)
- Bible Part 4 (Sitemap Architecture)
- Bible §4.14 (Page Viability — to be amended for Layer 1 exemption)
- DR-006 (Two-Phase Hierarchy Sync — Stage 1.5 dependency)
- DR-015 (Brand Scope Market Reconciliation — input to Phase B)
- DR-016 (Page Viability — applies to Layer 2 only)
- DR-018 (Page Content Length Standards — applies to all)
- DR-020 (Universal Content Templates — KW context consumption per template)
- DR-021 (Internal Linking — uses priority_score for weighting)
- Field tests: VTH BioDent (Stage 1 done) + SmileScape (`content-plan/keyword-research-dump.md`, ~680 KW × 16 clusters, commit `493a2d7`)

---

### [DR-021] — Internal Linking Architecture (HYBRID) (2026-05-10 → Locked 2026-05-12) 🔒🔗

**Status:** **Locked 2026-05-12** (early lock — paired companion lock with DR-019/020/022; operator-approved per 99.99%-Google-aligned assessment)
**Locked Bible Version:** v3.19 (Part 4 internal linking strategy + Part 13 authority signals already authoritative)
**Locked Schema Version:** v1.15 (§5.3 NEW `seo_page_internal_links` table + 12 columns added to `seo_website_page_master`)
**Bible Reference:** Part 4 (Sitemap), Part 13 (LLMO authority signals), Part 26 (Schema Pipeline)
**Schema Reference:** v1.10 → v1.15 (adds 12 columns to `seo_website_page_master` + new table `seo_page_internal_links` ~22 cols)

**Open Questions resolved at lock (per operator approval):**

1. anchor_variant_type enum: **5 values** (exact/partial/branded/generic/topical) — add 'cta' later if practice surfaces need
2. surrounding_text_snippet: **200 chars** (captures full sentence context)
3. is_reciprocal: **auto-trigger** AFTER INSERT/UPDATE via DB function
4. Status enum: **6 values** (planned/live/broken/deprecated/pending_review/archived)
5. external_url scope: **keep separate** from seo_page_citations (citations are different model; external links here = nav external only)
6. Authority Weight: **manual baseline + computed link_equity_score** (operator sets weight; system computes equity flow)
7. Crawl depth: **nightly cron** + on-demand at Stage 1.5 Gate

**Lock Audit Trail (2026-05-12):**

```yaml
field_validation:
  - "Operator Notion DB pre-EYWA precedent ('Website & SEO Page Intelligent Master') — 6 brands' worth of field-tested fields ported"
  - "Authority Weight + Link Equity Score + Orphan Risk Score = proven SEO concepts (industry consensus)"
  - "Anchor diversity tracking aligns with Google Penguin avoidance"
operator_approval:
  date: 2026-05-12
  rationale: |
    Hybrid model (page-level strategy + junction-level per-edge fidelity) is the
    only architecture that scales to 13 brands × ~500-5000 pages each. JSONB-only
    cannot support bidirectional queries at scale; junction-only loses page-level
    strategy fields. HYBRID was the considered choice from start.
follow_up_workload:
  - "Schema migration 040_dr021_add_page_linking_cols.sql (12 cols on page_master)"
  - "Schema migration 041_dr021_create_seo_page_internal_links.sql (~22 cols)"
  - "Schema migration 042_dr021_reciprocal_trigger_fn.sql"
  - "eywa-acf-fields plugin updates (~3 hours dev)"
  - "n8n flow updates (~6 hours)"
  - "Initial population per brand (~2-3 hours per brand × 13 = 26-39 hours total)"
  - "Stage 1.5 Gate validation pipeline reference seo_page_internal_links"
deferred_to_follow_up_drs:
  - "DR-028 candidate: External Authoritative Link Tracking (extend to_external_url usage)"
  - "DR-029 candidate: Anchor Diversity Algorithm (formal scoring formula)"
```

**Phase 1 Reference:** New migrations `009_add_linking_strategy_cols.sql` + `010_create_seo_page_internal_links.sql` (Phase 1A.3)
**Companion DRs:** DR-001 (Federation), DR-006 (Two-Phase Sync), DR-017 (content_brief), DR-019 (schema), DR-020 (templates)
**Trigger:** Operator review surfaced gap — current spec has implicit linking (cluster + entities + sitemap hierarchy) but no per-edge fidelity (anchor text, section context, link type)

**Context:**

```yaml
gap_in_v1_10:
  implicit_linking_only:
    - same topical_cluster_id → "related" pages
    - secondary_entities_fps[] overlap → topical
    - sitemap_node_id prefix → parent-child
  
  missing_for_production_seo:
    - Anchor text per-edge (Google ranks anchor diversity)
    - Section context (link from §7.2 ≠ link from §14)
    - Link type taxonomy (contextual / navigational / footer / breadcrumb)
    - Bidirectional consistency check (A→B planned but B↛A?)
    - Cross-brand link governance
    - Authority flow + orphan detection
    - Anchor diversity tracking

operator_notion_db_precedent:
  source: "Website & SEO Page Intelligent Master" (collection 496810b9-aac2-4409-94d0-540ae0cbdda8)
  page_level_strategy_present:
    - Authority Weight, Link Equity Score, Orphan Risk Score, Crawl Depth
    - Required Min Inbound/Outbound, Link Priority, Link Role
    - Anchor Strategy Mode, Anchor Diversity Score
    - Cross-Brand: Approved/Justification/Type/Role/Risk/Ratio
  limitation: |
    Links stored as "page-set relations" (JSON array of page URLs).
    Anchor text DERIVED via rollup from target's Target Keyword.
    Per-edge metadata (anchor variant per link, section context, link type) NOT captured.
```

**Decision (4 sub-decisions to lock together):**

1. **Enhance `seo_website_page_master` with 12 page-level linking strategy columns** (port from operator's Notion DB):
   - Authority management: `authority_weight`, `link_equity_score`, `orphan_risk_score`, `crawl_depth`, `strategic_page`, `node_tier_strategy`
   - Strategy defaults: `required_min_inbound`, `required_min_outbound`, `link_priority_default`, `link_role_default`, `anchor_strategy_mode`
   - Cross-brand: `cross_brand_approved`, `cross_brand_role`

2. **New junction table `seo_page_internal_links`** (per-edge fidelity):
   - Endpoints: `from_page_fp`, `to_page_fp`, `to_external_url`
   - Link metadata: `link_type`, `link_role`, `link_priority`
   - Anchor + context: `anchor_text`, `anchor_variant_type` (exact/partial/branded/generic/topical), `section_context`, `surrounding_text_snippet` (200 chars)
   - Lifecycle: `planned`, `implemented`, `status` (planned/live/broken/deprecated)
   - Quality: `is_reciprocal`, `is_cross_brand`, `cross_brand_justification`
   - Audit: timestamps + `first_planned_at`, `last_verified_at`

3. **Bidirectional Consistency Validation**:
   - Reciprocal detection trigger (auto-mark `is_reciprocal=true` when A→B and B→A both exist)
   - Anchor diversity warning (same anchor used >3 times for different targets → flag in editorial review)
   - Orphan detection (pages with `actual_inbound < required_min_inbound` flagged at Stage 1.5 Gate)
   - Authority depth check (Tier A pages crawl_depth ≤ 3, Tier B ≤ 4)

4. **Cross-Brand Link Governance**:
   - `is_cross_brand=true` REQUIRES `cross_brand_justification IS NOT NULL` AND `from_page.cross_brand_approved=true` (DB CHECK constraint)
   - Cross-brand role tracked: 'exporter' / 'importer' / 'balanced'
   - Editorial review (Bible Part 23.4 stage 4 brand voice) checks justification quality

**Rationale:**

- **Why HYBRID:** Page-level alone (Notion DB approach) lacks per-edge fidelity. Junction alone lacks page-level strategy fields. Both layers needed for production-grade SEO.
- **Why port from Notion DB:** Operator field-tested fields work — Authority Weight, Link Equity Score, Anchor Strategy Mode are proven SEO concepts.
- **Why junction table (not jsonb on page_master):** Bidirectional queries free with junction (`WHERE to_page_fp = X`). Per-edge metadata structured + indexable. Anchor diversity SQL aggregations possible. jsonb at scale (5K+ pages × 10+ links each = 50K+ edges) = poor performance.
- **Why now (DR-021 in current cycle):** Stage 1.5 (Handover v1.6) NEEDS internal linking storage. Without `seo_page_internal_links`, content writers cannot consult planned link strategy. Federation reuse (cross-brand link templates) requires query-able junction.
- **Why paired with DR-019/020 cycle:** Operator already in review mode 2026-06-07; bundle saves governance overhead.

**Consequences:**

- ✅ **SEO benefits:** anchor diversity per-edge (avoids Penguin penalty), link equity flow trackable, orphan detection automated, authority depth enforced, cross-brand governance prevents toxic patterns
- ✅ **Content production:** writers see explicit link instructions per section, AI/Claude queries DB for precise anchor + context, bidirectional consistency check catches drift
- ✅ **Federation:** link strategy templates reusable across brands (VTH defines OSA pattern → Deezy/VitalSleep reuse)
- ✅ **Quality automation:** Stage 1.5 Gate validates orphan + reciprocal + anchor diversity at DB level
- ⚠️ Schema v1.11 migration (~4 hours dev)
- ⚠️ ACF field group additions (~3 hours)
- ⚠️ n8n flow updates (~6 hours)
- ⚠️ Initial population per brand (~2-3 hours per brand)
- ⚠️ Total: ~15-20 hours one-time + ~2-3 hours per brand
- 🚧 Follow-up: DR-023 candidate (External Authoritative Link Tracking — extend to_external_url usage). [DR-022 claimed 2026-05-11 for Lean Phase B + Two-Layer Sitemap workflow]
- 🚧 Follow-up: DR-023 candidate (Anchor Diversity Algorithm — formal scoring formula)

**Open Questions for Review:**

1. anchor_variant_type enum scope — 5 enough or add 'cta'? *(Recommend: keep 5, add later if practice surfaces need)*
2. surrounding_text_snippet — 80 → 200 chars? *(Recommend: 200 — captures full sentence)*
3. is_reciprocal — auto-trigger or manual? *(Recommend: auto-trigger AFTER INSERT/UPDATE)*
4. Status enum — add 'pending_review'? *(Recommend: yes, for editorial workflow)*
5. external_url scope — replace seo_page_citations? *(Recommend: keep separate — citations are different model; external links here = nav external only)*
6. Authority Weight — manual vs computed? *(Recommend: manual baseline + computed link_equity_score)*
7. Crawl depth computation frequency — nightly cron acceptable? *(Recommend: yes + on-demand at Stage 1.5 Gate)*

**References:**

- DR-001 (Federation Pattern) — brand_scope foundation
- DR-006 (Two-Phase Hierarchy Sync) — informs Stage 1.5 timing
- DR-019 (Schema Strategy) — link role for AI-only schemas
- DR-020 (Universal Content Template) — Part 2 §6 Internal Link Checklist references this
- Bible Part 4.X (Sitemap Architecture)
- Bible Part 13 (LLMO authority signals)
- Schema v1.10 §5.1 — page_master expansion target
- External: Notion DB "Website & SEO Page Intelligent Master" (operator's pre-EYWA precedent — collection 496810b9-aac2-4409-94d0-540ae0cbdda8)
- Companion: `Content_Templates_EYWA_v1_0.md` — Part 2 §6 Internal Link Checklist
- Draft: `scratchpad/drafts/DR-021-internal-linking-architecture.md`

---

### [DR-020] — Universal Content Template Standard (2026-05-10 → Locked 2026-05-12) 🔒📝

**Status:** **Locked 2026-05-12** (early lock — Content_Templates v1.4 already field-active across portfolio planning; operator-approved batch lock with DR-019/021/022)
**Locked Bible Version:** v3.19 (Part 6 + Part 9 reference Content_Templates_EYWA_v1_0.md — companion file gains LOCKED status)
**Locked Companion File:** `Content_Templates_EYWA_v1_0.md` v1.5 — header status updated from "DRAFT — Proposed pending DR-020 lock" to "Locked 2026-05-12"
**Schema Reference:** v1.10 — no DDL change for v1.0 of standard; future v1.1+ may add `template_id text` + `template_version jsonb` columns to page_master
**Phase 1 Reference:** No migration required for spec lock; ACF field group updates per template (operational)
**Companion File:** `Content_Templates_EYWA_v1_0.md` (in repo root with DRAFT status header — formal lock + Bible reference upon DR-020 approval)
**Companion DRs:** DR-017 (content_brief — captures block tweaks), DR-018 (length standards — drives word count targets), DR-019 (schema strategy — defines emission purpose)

**Context:**

EYWA spec covers WHAT to build (Bible) + WHERE data lives (Schema), but lacks a UNIVERSAL standard for HOW to compose content blocks across 13 brands × 6 verticals. Real-world evidence:

```yaml
gaps_observed:
  vth_biodent:
    issue: "/mouth-biomapping/ has perfect visual EEAT but broken structured EEAT"
    cause: "AIOSEO emits author='advthdent' (admin), reviewed-by-doctor visual not in JSON-LD"
    impact: "Google sees anonymous-authored medical content (E-E-A-T weak signal)"
  
  deezy_dental:
    issue: "13 distinct page types in actual sitemap, no template framework to ensure consistency"
    types_observed:
      - Service procedure pages (Section 3, 225 pages)
      - Concern pages (Section 5, 124 pages)
      - Clinical Guide (Section 6.1, 31 pages — NEW page type, no template)
      - Glossary topical (Section 6.3, 26 pages)
      - FAQ Library (Section 6.5, 28 pages)
      - Case studies (Section 7, 56 pages)
      - Branch pages (Section 8.2, 33 pages)
      - Hyper-local programmatic (Section 9, 68+ pages — NEW, no template)
    impact: "Content writers reinvent structure per page; thin-page risk; EEAT inconsistency"

field_test_evidence:
  sample_content_doc: "ตัวอย่างเนื้อหา 355be9c6bf3c806fadabe4828a694200.md"
  observation: |
    Sleep apnea sample has 13 well-organized sections with annotations.
    Operator already has the pattern internalized — just needs codification
    + extension across content types beyond Medical Condition.
```

**Decision:**

Lock the following 4 sub-decisions together (final lock 2026-06-07):

1. **Companion File Architecture** — `Content_Templates_EYWA_v1_0.md` becomes the 3rd canonical reference alongside Bible + Schema. Bible/Schema reference it; do not duplicate content.

2. **3-Layer Composition System:**
   - **Layer 1:** ~25 Universal Section Building Blocks (atomic units, high reuse)
   - **Layer 2:** 25 Content Type Templates (12 core + 5 T2 variants + 7 specialized + 1 T6a Guide)
   - **Layer 3:** Customization Hooks (block_substitution / addition / removal / reordering with HARD RULE: never remove REQUIRED blocks)

3. **EEAT Requirement Matrix** — locked per template type (see companion file §5):
   - Medical YMYL templates (T1, T2, T2a-e, T3, T4, T6a, T7, T8, T14, T15, T17): author + medical_reviewer + last_reviewed REQUIRED
   - Conditional (T5, T6, T12): required if YMYL/medical claim
   - Not required (T9 self-EEAT, T10, T11, T13, T16, T18 page-level, T19): operational/branch-level
   - Decision rule: "If reader makes a health decision based on this page → reviewer REQUIRED"

4. **Schema Enforcement Pattern** — beyond visual EEAT, structured emission must include:
   - Article schema with `author` linked to Physician (not WP admin)
   - `reviewedBy` property explicit
   - `lastReviewed` property
   - `medicalAudience` declaration
   - Citations as schema `citation` array (not text-only)
   - Organization typed as `MedicalBusiness` (specialty subtype)

**Rationale:**

- **Why companion file (not in Bible)?** Bible is 26K lines already; templates evolve faster than philosophy; mirrors Schema_Overview pattern; easier to version/maintain.
- **Why 25 templates (not 12 or 50)?** 12 too few (misses verticals like aesthetic/wellness/genomic); 50 = overengineering. 25 derives from actual sitemap analysis (Deezy 13 page types + 6 verticals × 2-3 specialized variants each).
- **Why 3-layer composition?** Block reuse maximizes consistency without duplication. Templates are recipes; blocks are LEGO units. Layer 3 hooks allow brand identity without breaking standard.
- **Why schema enforcement beyond visual?** VTH /mouth-biomapping/ audit proves visual EEAT can be perfect while structured EEAT silently fails. Google's Medical YMYL guidelines (E-E-A-T 2026) explicitly check structured signals.
- **Why pair with DR-019?** DR-019 governs schema emission purpose (serp/ai/forbidden); DR-020 governs content composition. Together they form the complete content production stack.
- **Why no DDL for v1.0?** Existing columns (author_fp, medical_reviewer_fp, last_reviewed_at, schema_org_type, schema_markup_planned, content_brief, viability_assessment) suffice. Future template_id column can be added in v1.1 without breaking changes.

**Consequences:**

- ✅ Universal standard across 13 brands eliminates "writer reinvents structure" waste
- ✅ EEAT enforcement (visual + structured) closes the silent failure gap audited at VTH
- ✅ T18 Programmatic Local solves Deezy 68+ hyper-local pages problem (and all multi-branch brand scaling)
- ✅ T6a Guide solves "คู่มือ" search intent (31 pages in Deezy alone)
- ✅ Block-level reuse means future template additions are cheap (compose from existing blocks)
- ✅ Per-template length standards consume DR-018 §9.8 directly
- ✅ Per-template schema mappings consume DR-019 emission taxonomy directly
- ⚠️ ACF field groups need refactor (~15-20 hours dev) — one ACF group per template
- ⚠️ `eywa-schema-pipeline` plugin needs medical_reviewer_fp injection logic (~6 hours dev)
- ⚠️ Editorial workflow gains template_id selection step (Notion DB schema update)
- ⚠️ Existing pages need template_id back-fill (audit task, can be opportunistic)
- 🚧 Follow-up: separate DR-021 may add `template_id` + `template_version` columns to page_master (v1.1)
- 🚧 Follow-up: phase 2 EEAT enforcement (CHECK constraint) targeted 2026-09-01 after doctor onboarding

**Open Questions for Review (must answer before lock):**

1. Template count — 25 too many? *(Recommend: keep, each addresses real page type from sitemap analysis)*
2. T6 vs T6a Guide overlap — risk of confusion? *(Recommend: editorial reviewer makes call; border cases default to T6 lower bar)*
3. T18 Programmatic Local uniqueness enforcement — algorithmic check or manual? *(Recommend: manual v1, algorithmic v2 with cosine similarity threshold <0.7)*
4. EEAT phase 2 hard-block timing — 2026-09-01 OK? *(Prerequisite: ≥80% of brand clinic doctors registered in seo_authors)*
5. Template versioning strategy — semantic versioning vs date-stamped? *(Recommend: semver, store in page_master.template_version jsonb in v1.1)*
6. ~~Should `Content_Templates_EYWA_v1_0.md` move to repo root immediately or wait for lock?~~ **RESOLVED 2026-05-10:** placed at repo root with DRAFT status in frontmatter (gitignore excludes `drafts/` folder; root placement enables claude.ai project sync during review window).

**References:**

- Companion file: `Content_Templates_EYWA_v1_0.md` (DRAFT, 1,456 lines, 25 templates, ~25 blocks)
- DR-017 (content_brief — captures block-level tweaks at sitemap design phase)
- DR-018 (length standards — drives per-template word count targets)
- DR-019 (schema strategy — defines emission purpose for each template's schemas)
- Bible Part 6 (Citable Formulas + Perspective Layer — content philosophy that templates implement)
- Bible Part 9 (Template Anatomy + WCAG AA + §9.8 Length Standards)
- Bible Part 23.4 (Multi-Stage Editorial Review — gains template_id selection step)
- Schema v1.10 §5.1 (page_master columns: author_fp, medical_reviewer_fp, last_reviewed_at, schema_org_type, schema_markup_planned, content_brief, viability_assessment)
- Reference content sample: `/legacy/Sitemap Deezy/VTH Biodent/ตัวอย่างเนื้อหา 355be9c6bf3c806fadabe4828a694200.md`
- Live audit reference: https://www.vthbiodent.com/mouth-biomapping/ (audited 2026-05-10 — visual EEAT good, structured EEAT 6 failures)
- Sitemap gap analysis source: `/legacy/Sitemap Deezy/Deezy Dental/deezy-sitemap.md` (13 page types observed)

**Lock Audit Trail (2026-05-12):**

```yaml
field_validation:
  - "Content_Templates v1.4 already in field active use across portfolio planning"
  - "T1-T22 templates referenced by VTH BioDent, SmileScape, Trin Wellness, Classy Clinic content briefs"
  - "v1.4 added T-ADS-X family (DR-026) — T1-T22 baseline mature enough to extend"
operator_approval:
  date: 2026-05-12
  rationale: |
    Template family field-tested. Industry-validated patterns (HubSpot, Brafton,
    Whitehat consensus 2026 per Bible §3.5). Block-composition + per-template
    schema mapping + length standards are settled. Locking now seals existing
    practice; future template additions follow Section 12 governance (semantic
    versioning v1.4 → v1.5 → v2.0 path established).
follow_up_workload:
  - "Content_Templates_EYWA_v1_0.md header status: DRAFT → Locked 2026-05-12 (v1.5)"
  - "Bible Part 6 + Part 9 cross-references updated to reflect locked status"
  - "ACF field group registration per template (Phase 1F operational work)"
  - "Editorial review checklist update — template_id selection becomes mandatory step"
```

---

### [DR-019] — Schema Strategy for Post-Rich-Results Era (2026-05-10 → Locked 2026-05-12) 🔒🔬

**Status:** **Locked 2026-05-12** (early lock with **Insurance Review Clause** — operator-approved batch lock with DR-020/021/022; spec-level decisions all aligned with Google's publicly-announced position. Re-review trigger 2026-06-30 post-Google-effective-date for last-mile reconciliation.)
**Locked Bible Version:** v3.19 (Part 26 schema strategy taxonomy; Part 9 Featured Snippet pattern; Part 20 KPI metrics — all formalized at lock)
**Locked Schema Version:** v1.15 (no DDL change — strategy is spec + plugin layer)
**Insurance Review Clause:** Re-review window 2026-06-30 (post-Google-effective-date). If Google's actual behavior at June 2026 effective date contradicts DR-019 framing (FAQPage/HowTo/MedicalCondition AI consumption behavior, AggregateRating min-5 review enforcement), file Category 2 amendment per Bible §15.2.
**Open Questions resolved at lock:**

1. Plugin enforcement timing: **warn-only first 2 weeks** then escalate to hard-block
2. Existing pages cleanup: **opportunistic** (most brands don't use the 7 deprecated schemas anyway)
3. Featured Snippet pattern enforcement: **WARN v1**, BLOCK for L4/L5 only after 6 months measurement
4. AI citation tracking ETL: **accept lag** — DR specifies metric, ETL is Phase 3 task
5. `QAPage` schema for single-question Knowledge L5 pages: **YES**
6. SpeakableSpecification rollout: **only pages following Decision 2 Featured Snippet pattern**

**Bible Reference:** Part 26 (Schema Pipeline) — major refactor pending lock; Part 9 (Templates) — new Featured Snippet section pending lock; Part 20 (KPIs) — metric replacement pending lock
**Schema Reference:** v1.10 — **no DDL change** (decision is spec-level + plugin-level)
**Phase 1 Reference:** Updates `eywa-schema-pipeline` plugin emission logic (no migration)
**Companion DRs:** DR-001 (Federation — schemas inherit brand_scope), DR-011 (EUG — entity-schema discipline)
**Trigger event:** Google announcement 2026-05-07 — FAQ rich results full deprecation effective June 2026 (incl. gov/health carve-out)

**Context:**

Multi-source verification (12+ industry sources, 2026-05-10) confirms a 3-year deprecation arc completing in June 2026:

```yaml
deprecation_timeline:
  2023-08: "FAQ rich results restricted to gov/health (HowTo desktop-only)"
  2023-09: "HowTo rich results FULLY removed"
  2026-03: "7 schemas deprecated (CourseInfo, ClaimReview, EstimatedSalary, LearningVideo, SpecialAnnouncement, VehicleListing, PracticeProblem)"
  2026-03: "AggregateRating scrutiny tightened — min 5 verifiable reviews + crawler-accessible"
  2026-05-07: "FAQ rich results full kill announced (incl. gov/health carve-out)"
  2026-06: "Effective: FAQ search appearance + Rich Results Test support removed"

empirical_pivot_evidence:
  faqpage_ai_citation_rate: "67% for relevant queries"
  faqpage_in_ai_overviews: "3.2x more likely vs prose-only"
  active_consumers: [ChatGPT, Claude, Perplexity, Gemini, Google AI Overviews]
  schema_role_shift: "SERP-rendering signal → AI-extraction signal"
```

EYWA Bible v3.14 currently embeds FAQPage and HowTo across Part 6, 9, 25, 26 + L6 schema mapping. The compliance header declares "Google March 2026 Core Update aligned" but predates the 2026-05-07 announcement. Without architectural separation between SERP-purpose and AI-purpose schemas, KPIs and emission logic conflate two different value streams.

**Decision (4 sub-decisions to lock together):**

1. **Two-Purpose Schema Taxonomy** — Classify all emitted schemas into:
   - `serp_rich_result` (active SERP renderers): Product, Review, Organization, MedicalBusiness, LocalBusiness, Article, NewsArticle, BlogPosting, MedicalScholarlyArticle, BreadcrumbList, VideoObject, Person, Recipe (non-EYWA), Event (non-EYWA)
   - `ai_citation` (AI-only — emit but expect no SERP rich result): FAQPage, HowTo, MedicalCondition, MedicalProcedure, MedicalTherapy, Drug, DefinedTerm, QAPage, SpeakableSpecification
   - `forbidden` (BLOCK emission): CourseInfo, ClaimReview, EstimatedSalary, LearningVideo, SpecialAnnouncement, VehicleListing, PracticeProblem

2. **Featured Snippet Capture Pattern** (Bible Part 9 NEW sub-section) — H2/H3 = literal user question; first paragraph after H2/H3 = direct 40-60 word answer; supporting list/table below; co-emit `SpeakableSpecification`. Becomes the primary SERP-capture mechanism for question-intent queries (replacing FAQ rich result niche).

3. **KPI Replacement** (Bible Part 20):
   - DROP: `faq_rich_result_impressions`, `howto_rich_result_impressions`
   - ADD: `ai_citation_rate` (per platform: chatgpt/claude/perplexity/gemini/ai_overviews), `featured_snippet_capture_rate`, `zero_click_vs_click_ratio`
   - RETAIN: `product_review_rich_result_impressions`, `organization_knowledge_panel_presence`, `breadcrumb_rich_result_appearance`, `video_thumbnail_rich_result`

4. **AggregateRating Tightening** — `eywa-schema-pipeline` plugin enforces min 5 reviews + crawler-accessible source pre-emission; non-compliant pages emit individual `Review` schemas without `AggregateRating` wrapper.

**Rationale:**

- **Why split FAQPage/HowTo from forbidden 7?** Google explicitly says they'll continue using FAQPage/HowTo for understanding pages (just no SERP rendering). The 7 forbidden schemas have processing entirely removed. AI consumption (67% citation rate) makes continued emission high-value.
- **Why no DDL change?** Existing `schema_org_type` (text) + `schema_markup_planned` (jsonb) suffice. A `schema_emission_purpose` enum was considered but rejected — purpose is derivable from type via lookup table (no need to denormalise).
- **Why Featured Snippet now (was implicit)?** With FAQ rich results gone, Position 0 becomes the highest-value SERP capture for Q&A intent. Bible mentions Featured Snippets in passing (Part 20 KPI ~line 14416) but lacks template-level pattern enforcement.
- **Why 4-week review (until 2026-06-07)?** Google's June 2026 effective date may bring last-minute behavioural changes. Lock 1 week post-effective lets us observe actual Rich Results Test removal + page treatment behaviour.
- **Why independent of DR-013/014?** DR-013/014 = entity_relationships edge vocabulary layer. DR-019 = schema.org JSON-LD emission layer. Different files, different governance scope.

**Consequences:**

- ✅ Eliminates wasted bytes from 7 deprecated schemas (cleaner crawl budget)
- ✅ Operator/AI mental model split: "this schema = AI" vs "this schema = SERP"
- ✅ Featured Snippet capture becomes measurable, not hope-based
- ✅ AggregateRating compliance prevents future Google penalty
- ✅ KPI metrics align with reality (no more tracking dead features)
- ⚠️ Bible Part 26 needs significant restructure (~3 hours), Part 9 new sub-section (~2 hours), eywa-schema-pipeline plugin update (~4 hours dev)
- ⚠️ Existing pages with deprecated 7 schemas need cleanup audit (operator-driven, not auto-strip)
- ⚠️ Temporary inconsistency between operators following old pattern vs new (during review window)
- 🚧 Follow-up: audit 14 brand sites for 7 deprecated schemas in production
- 🚧 Follow-up: update `eywa-acf-fields` + `genesis_checklist.yaml` schema validation
- 🚧 Follow-up: consider DR-020 (AI Citation Tracking & Optimization Cycle — operationalize `ai_citation_rate` ETL)

**Open Questions for Review (must answer before lock):**

1. Plugin enforcement timing: warn-only first 2 weeks then hard-block, OR hard-block immediately? *(Recommend: warn-only 2 weeks)*
2. Existing pages cleanup priority: blocking bug / opportunistic / batch? *(Recommend: opportunistic — most brands don't use the 7 anyway)*
3. Featured Snippet pattern enforcement: WARN or BLOCK in editorial review? *(Recommend: WARN v1, BLOCK for L4/L5 only after 6 months measurement)*
4. AI citation tracking ETL: block this DR until pipeline exists, or accept lag? *(Recommend: accept lag — DR specifies metric, ETL is separate Phase 3 task)*
5. Add `QAPage` schema for single-question Knowledge L5 pages? *(Recommend: YES)*
6. SpeakableSpecification rollout: all pages or only Featured-Snippet-targeted? *(Recommend: only pages following Decision 2 pattern)*

**References:**

- Bible Part 26 (current Schema Pipeline — to be restructured post-lock)
- Bible Part 9 (Template Anatomy — to gain Featured Snippet section post-lock)
- Bible Part 20 (KPI Framework — to update metrics post-lock)
- Bible Part 23.4 (Editorial Review — to gain Featured Snippet check post-lock)
- DR-001 (Federation Pattern) — schemas inherit brand_scope[]
- DR-011 (EUG) — entity-schema linking discipline
- External: [Google Search Central blog 2023-08 (HowTo + FAQ original announcement)](https://developers.google.com/search/blog/2023/08/howto-faq-changes)
- External: Google announcement 2026-05-07 (FAQ rich results full deprecation, effective June 2026)
- External: Google March 2026 Core Update — 7 schema deprecations
- Multi-source verification 2026-05-10: Search Engine Land, Schema App, ALM Corp, Frase.io, WebFX, Engagecoders, Stanventures, Wildnet, faqjsonld.com, Leapd, Stackmatix, Over The Top SEO (12+ sources confirmed convergent narrative)
- Trigger: BIO DADDY infographic 2026-05-09 → operator request 2026-05-10 → multi-source verification → DR-019 draft

**Lock Audit Trail (2026-05-12):**

```yaml
operator_approval:
  date: 2026-05-12
  rationale: |
    99.99%-Google-aligned assessment confirmed by operator. EYWA's two-purpose
    schema taxonomy (serp_rich_result vs ai_citation vs forbidden) matches
    Google's communicated post-Rich-Results-era position. The 7 forbidden
    schemas list is final per Google's March 2026 announcement. FAQPage/HowTo/
    MedicalCondition AI consumption pattern (67% citation rate, 3.2x more
    likely in AI Overviews) is empirically observed.
  insurance_clause:
    re_review_window: 2026-06-30 (post-Google-effective-date)
    trigger: |
      If Google's actual behavior at June 2026 effective date contradicts
      DR-019 framing — file Category 2 amendment per Bible §15.2 (low cost,
      ~1 hour work).
    expected_outcome: "No amendment needed — DR-019 framing matches Google's
                       publicly-announced direction. Re-review is insurance,
                       not expected change."
follow_up_workload:
  - "Bible Part 26 schema strategy restructure (~3 hours dev)"
  - "Bible Part 9 NEW Featured Snippet sub-section (~2 hours dev)"
  - "Bible Part 20 KPI replacement (~1 hour dev)"
  - "eywa-schema-pipeline plugin update (~4 hours dev)"
  - "Audit 13 brand sites for 7 deprecated schemas in production (operator-driven, opportunistic)"
  - "Re-review check 2026-06-30 (15-minute Google effective-date verification)"
```

---

### [DR-018] — Page Content Length Standards (2026-05-10) 🆕

**Status:** Locked (operator approval 2026-05-10)  
**Bible Reference:** Part 9.8 (NEW Section — Page Content Length Standards)  
**Schema Reference:** v1.10 — no schema change (process standard)  
**Companion DRs:** DR-016 (consumes these min thresholds for thin-page detection)

**Context:**

Bible v3.13 contained scattered word count references but no comprehensive standards table:
- Line 4685: `word_count_minimum: 1500` (one context-specific mention)
- Line 10887: `ความยาว 40-50 คำ` (Speakable section guidance)
- No Layer-by-Layer table, no rationale, no exception clauses

Real impact at VTH BioDent: AI/operator designing sitemap and assessing thin-page risk had no concrete benchmarks. Pillar pages risk being under-built (1,500 vs needed 4,000+ words); service pages risk over-engineering (2,500 vs target 1,500). DR-016 thin-page detection has nothing to reference.

**Decision:**

Add comprehensive Page Content Length Standards table to Bible Part 9.8 covering all 7 Layers + 5 documented exception clauses for valid non-SEO purposes (legal, contact, intent-capture, glossary, programmatic).

Standards (key targets, full table in Bible §9.8):

| Layer | Type | Min | Target | Max |
|-------|------|-----|--------|-----|
| L1 | Home | 500 | 1,000 | 1,500 |
| L2 | Money/Service | 800 | 1,500 | 2,500 |
| L3 | Center/Hub | 1,500 | 2,500 | 4,000 |
| L4 | Concern Pillar | 2,500 | 4,000 | 6,000 |
| L5 | Knowledge | 2,000 | 3,500 | 5,000 |
| L6 | Local | 600 | 1,200 | 2,000 |
| L7 | Case Study | 1,500 | 2,500 | 4,000 |

Multilingual adjustment: Thai/Chinese -20% (denser per character).

**Rationale:**

- Concrete benchmarks unblock DR-016 (viability assessment needs numbers)
- Layer-specific (Home ≠ Pillar; intent and value-of-length curve differ)
- Industry-grounded (Backlinko, Ahrefs, HubSpot 2020-2024 studies)
- Exception clauses preserve flexibility — 5 documented patterns for valid thin pages
- Pillar exception explicitly forbidden (L4/L5 must be exhaustive — SEO authority)
- Annual review cadence (algorithm landscape shifts)

**Consequences:**

- ✅ DR-016 has concrete thresholds to enforce
- ✅ Editorial review (Bible Part 23.4 Stage 2) gets clear pass/fail criteria
- ✅ Cross-brand consistency (every brand uses same standards)
- ⚠️ Numbers may need adjustment (per-vertical refinement future)
- ⚠️ Risk: writers focus on count not quality — mitigated by editorial review
- 🚧 Follow-up: yearly review at Schema Review Board cadence

**Implementation:**

- Bible Part 9.8 (NEW): full standards table + 5 exception clauses + industry rationale
- Schema v1.10: no DDL change required for DR-018 itself — standards are spec-level reference; runtime enforcement via `viability_assessment` (DR-016) audit trail and editorial review (Bible Part 23.4)
- Editorial workflow: Stage 2 review uses targets as benchmarks
- Brand application: per-brand may add vertical-specific refinements via DR

**References:**

- DR-016 (Thin Page Detection) — primary consumer of these thresholds
- DR-017 (Content Brief) — brief shapes coverage to hit these standards
- Bible Part 6 (Content Standard) — quality companion
- Bible Part 23.4 (Editorial Review) — validation phase
- Industry: Backlinko ranking factor studies, Ahrefs content depth research, HubSpot pillar page methodology, Google Helpful Content Update

---

### [DR-017] — Page Content Brief Field (2026-05-10) 🆕

**Status:** Locked (operator approval 2026-05-10)  
**Bible Reference:** Part 5 §5.1 — page_master spec update  
**Schema Reference:** v1.10 §5.1 — adds `content_brief text` column  
**Phase 1 Reference:** New migration `007_add_content_brief.sql`

**Context:**

Two related problems from VTH BioDent field test:

1. **Lost context after page collapse (DR-016 outcome):** When sitemap design collapses children into parent (e.g., 3.1.1-3 → merged into 3.1), the conceptual structure that informed the design is lost. Content writer (weeks/months later, possibly different person/AI) sees only the parent name with no hint of original coverage plan.

2. **Even non-collapsed pages benefit from upfront briefs:** Sitemap design captures the WHY of a page existing. By content creation phase, original framing forgotten, strategic positioning unclear, internal link planning hints missing.

Currently no structured place to store "what this page should cover."

**Decision:**

Add column `content_brief text NULL` to `seo_website_page_master`:
- **REQUIRED** for collapsed pages (parent absorbs children's outlines)
- **RECOMMENDED** for all standalone pages (operator best practice)
- Free-text format: 2-5 sentences or bullet list capturing planned coverage, key topics, internal link targets, distinctive angle
- Programmatic Type C pages: reference template (no free-text)

**Rationale:**

- Text format > jsonb (easier to read/write, AI/Notion render natively, free-form > structured)
- Optional but recommended (backwards compatible, doesn't block existing workflows)
- Required only when needed (collapsed pages — can't lose context)
- Same column instead of separate table (1:1 relationship, no JOIN cost)
- Phase 1A inclusion (cheap addition ~30 min effort, critical pairing with DR-016)

**Consequences:**

- ✅ Context preserved across time, writers, AI sessions
- ✅ Required for collapsed pages → no lost outlines
- ✅ Onboarding aid for new writers
- ✅ AI uses brief when generating content (better outputs)
- ✅ Audit trail of editorial intent
- ⚠️ Adds ~5 min per page during sitemap design
- ⚠️ Risk: writer ignores brief (mitigation: editorial review checks alignment)

**Implementation:**

- Schema v1.10 §5.1: ADD column `content_brief text NULL`
- Phase 1A migration `007_add_content_brief.sql` (independent of DR-013/014)
- Bible Part 4 Phase 4.5 (NEW step): Content Brief Drafting in sitemap design workflow
- Notion: add property "Content Brief" (long text, bidirectional sync)
- WordPress: add ACF field `content_brief` (textarea) in eywa-acf-fields plugin

**References:**

- DR-011 (EUG) — quality gate pattern
- DR-016 (Thin Page Detection) — primary consumer
- DR-018 (Word Count Standards) — brief shapes coverage to hit standards
- Bible Part 5 (Database Schema) — table this column joins
- Bible Part 23.4 (Editorial Review) — validation phase

---

### [DR-016] — Thin Page Risk Detection (Sitemap Quality Gate) (2026-05-10) 🆕

**Status:** Locked (operator approval 2026-05-10)  
**Bible Reference:** Part 4.14 (NEW Section — Page Viability Assessment)  
**Schema Reference:** v1.10 §5.1 — adds optional `viability_assessment jsonb` column  
**Companion DRs:** DR-017 (preserves collapsed page context), DR-018 (provides word count thresholds)

**Context:**

Current EGP + sitemap design produces hierarchical structures where children pages can end up as thin content. VTH BioDent example:

```
3.1 Mouth BioMapping
├── 3.1.1 หลักการ (~300 words predicted)
├── 3.1.2 วิธีตรวจ (~400 words)
└── 3.1.3 ใครเหมาะ (~250 words)
```

Each child individually too narrow to support standalone page → SEO penalty risk. Better outcome: collapse children into parent, create rich 2,500-word page covering all sub-topics.

Bible v3.13 had no comprehensive thin-page risk framework. No criteria, no decision matrix, no exceptions.

**Decision:**

Add **"Page Viability Assessment"** quality gate in sitemap design (new Phase 4.5, between Phase 4 Page-Level Tagging and Phase 5 Connection Audit).

**4 Criteria per page:**
1. Predicted Content Volume (vs DR-018 Layer minimum)
2. Search Volume (≥ 100/mo Thai, ≥ 50/mo English niche)
3. Topic Distinctness (< 30% overlap with parent)
4. User Intent Distinctness (different intent type or sub-intent)

**Decision Matrix:**
- All 4 PASS → Standalone
- 1-2 WARN → Standalone with watch flag
- 3-4 WARN or 1 FAIL → Human review
- 2+ FAIL → COLLAPSE into parent (preserve content_brief per DR-017)

**Exception Clauses (5 patterns where thin pages are valid):**
1. Legal/Required pages (privacy, terms — 300-1,000 words)
2. Contact/Location pages (300-800, schema compensates)
3. Intent-capture pages (500-1,000, commercial intent + CTA)
4. Disambiguation/Glossary hubs (200-600, heavy cross-linking)
5. Programmatic pages Type C (600-1,200 per template)

**Pillars NEVER allowed thin** (L4/L5 — SEO authority pages have no exception).

**Rationale:**

- Word count proxy for "did we have enough valuable to share?" (industry-validated)
- 4 criteria orthogonal — different dimensions of viability
- Exception framework prevents tyranny — 5 valid non-SEO patterns documented
- Pre-lock quality gate (catch before publish, not after)
- Pairs with EUG (DR-011) — both quality gates pre-finalize

**Consequences:**

- ✅ Prevents thin-page SEO penalties before publish
- ✅ Forces deliberate page existence justification
- ✅ Acknowledges valid non-SEO reasons (5 exceptions)
- ✅ Audit trail (assessment stored optionally)
- ⚠️ Adds ~10 min per page during sitemap design
- ⚠️ Requires DataForSEO query for criterion 2

**Implementation:**

- Bible Part 4.14 (NEW): full assessment framework + decision matrix + exceptions
- Bible Part 4 Phase 4.5: viability assessment as quality gate before sitemap lock
- Schema v1.10 §5.1: optional column `viability_assessment jsonb` (audit trail)
- Handover §7: workflow step added between EGP and sitemap lock

**References:**

- DR-011 (EUG) — pre-lock quality gate pattern
- DR-017 (Content Brief) — preserves context when pages collapse
- DR-018 (Word Count Standards) — provides Layer minimums (Criterion 1)
- Bible Part 3.5 (Cannibalization Shield) — related concern
- Bible Part 4.5 (Page Type Matrix) — Type C programmatic exception
- Industry: Google Helpful Content Update (Aug 2022, ongoing)

---

### [DR-015] — Brand Scope Market Reconciliation Pattern (2026-05-10) 🆕

**Status:** Locked (operator approval 2026-05-10)  
**Bible Reference:** Part 4.13 (NEW Section — Market Reality Reconciliation)  
**Schema Reference:** v1.10 §5.1 — adds `marketplace_proposal_status text` column  
**Phase 1 Reference:** New migration `008_add_marketplace_reconciliation.sql`

**Context:**

EYWA's strict `brand_scope` discipline (DR-001 + DR-010) successfully prevents brand drift, but real-world testing on VTH BioDent revealed an over-correction:

> AI สร้าง sitemap ที่ไม่มีบริการทันตกรรมพื้นฐาน (อุดฟัน/ขูดหินปูน/ถอนฟัน) เพราะ brand concept ของ VTH BioDent คือ "premium integrative dental + biological mapping". Strict brand_scope ตัดบริการเหล่านี้ออก — แต่ในชีวิตจริง dental clinic ขาดไม่ได้.

Protection too strict — blocks services that:
1. Are real-world necessities for the clinic to function
2. Have legitimate search demand (real Thai search volume)
3. Could fit brand concept WITH repackaging (e.g., "Comprehensive Dental Wellness Center" instead of "General Dentistry")

AI is "too obedient" — protects brand integrity at cost of business reality.

**Decision:**

Adopt **"Market Reality Reconciliation"** — OPTIONAL second pass that runs AFTER strict EGP completes.

**3-Step Process:**
1. Strict EGP runs as normal (current behavior)
2. Reconciliation pass: AI explores vertical-standard services NOT in current brand_scope, scores each:
   - **Necessity Score (1-5):** how essential for vertical to function
   - **Brand-Fit:** Direct / Repackageable / Forced (reject)
   - **SEO Opportunity:** search volume + intent + competition
3. Output to operator review (NOT auto-applied):
   - Status: `proposed` → operator approves/rejects/defers
   - Approved items get `accepted_repackaged` with new positioning name

**When to run:**
- Healthcare brands: MANDATORY (clinical reality)
- Wellness brands: RECOMMENDED
- Media brands: OPTIONAL

**Rationale:**

- Pattern matches DR-012 philosophy: strict default + governed exceptions
- Discussion list (not auto-add) → forces conscious brand decisions
- Repackaging requires human creativity (naming, positioning)
- 3-axis scoring lets different verticals optimize differently
- Audit trail per service decision

**Consequences:**

- ✅ Healthcare brands unblocked — can offer general dentistry under "Wellness Center"
- ✅ AI more useful (proposes, doesn't just block)
- ✅ Brand discipline preserved (operator approval required)
- ✅ Cross-brand applicable (every healthcare brand faces this)
- ⚠️ Adds ~15 min per brand reconciliation pass
- ⚠️ Operator must judge repackaging wisely (could over-extend brand)

**Implementation:**

- Bible Part 4.13 (NEW): Market Reconciliation Phase + 3-criteria scoring + decision tree
- Schema v1.10 §5.1: ADD column `marketplace_proposal_status` with CHECK constraint (`in_scope` / `proposed` / `accepted_repackaged` / `rejected` / `deferred`)
- Schema v1.10 §5.1: ADD column `reconciliation_notes text` (operator's repackaging notes)
- Phase 1A migration `008_add_marketplace_reconciliation.sql`
- Handover §7: Reconciliation phase in per-brand workflow checklist

**Test Cases (VTH BioDent):**

```yaml
general_dentistry:
  blocked: ["อุดฟัน", "ขูดหินปูน", "ถอนฟัน"]
  necessity: 5/5, fit: REPACKAGEABLE, seo: HIGH (~22K-33K/mo)
  decision: ACCEPT — "Comprehensive Dental Wellness Center"

cosmetic_dentistry:
  blocked: ["ฟอกสีฟัน", "วีเนียร์"]
  necessity: 3/5, fit: REPACKAGEABLE, seo: VERY HIGH (~33K/mo)
  decision: ACCEPT — "Aesthetic Smile Refinement"

emergency_dental:
  blocked: ["ปวดฟันกะทันหัน"]
  necessity: 4/5, fit: PARTIAL, seo: MEDIUM
  decision: DEFER — discuss positioning
```

**References:**

- DR-001 (Multi-Brand Federation) — established brand_scope[]
- DR-010 (Brand Scope Architecture) — locked brand_slug
- DR-012 (Edge Vocabulary Evolution) — pattern for governed expansion
- DR-016 (Thin Page Detection) — viability check follows reconciliation
- Bible Part 2.6 (EGP) — strict process this complements
- Bible Part 14 (Vertical Profiles) — vertical reality definitions

---

### [DR-014] — Concept Entity Subtype Lock (framework + axis) (2026-05-09 → Locked 2026-05-12) 🔒💠

**Status:** **Locked 2026-05-12** (paired companion lock with DR-013; cross-brand evidence ≥5 medical brands)  
**Locked Bible Version:** v3.18 (Part §2.6.10 NEW — Concept Entity Subtype Controlled Vocabulary)  
**Locked Schema Version:** v1.14 (§4.1 seo_entity_graph — CHECK chk_concept_subtype)  
**Bible Reference:** v3.18 §2.6.10 (entity_subtype controlled vocabulary for concept type)  
**Schema Reference:** v1.14 §4.1 (CHECK constraint on entity_subtype for concept type)  
**Companion DR:** DR-013 (Edge Vocabulary v3.5 Expansion — Locked 2026-05-12)

**Context:**

Per Stream B work order (2026-05-09) — field-tested feedback from VTH BioDent EGP work surfaced gap:

When entities of `entity_type='concept'` represent **integrative methodologies or causal dimensions** (e.g., VTH BioDent's "Mouth Bio Mapping" framework, "neuroimmune axis" concepts), existing `entity_subtype` field has no controlled vocabulary. This leads to:

- Inconsistent labeling (`'methodology'` vs `'paradigm'` vs `'system'` for same concept)
- Schema markup ambiguity (no `additionalType` value to emit)
- Cluster organization confusion (when should subtype matter?)

**Proposed Decision:**

Lock 2 controlled vocabulary values for `concept` entity_subtype:

```yaml
proposed_subtype_values:
  
  framework:
    description: "Overarching methodology / paradigm that organizes other concepts"
    examples:
      - VTH BioDent: "pncl-medicine" (Personalized Neural-Cognitive Lifestyle Medicine)
      - Healthcare general: "integrative-medicine", "functional-medicine"
    schema_org_emission: 'additionalType="ClinicalFramework"'
    cluster_role: "Often parent_of multiple axes/clusters"
  
  axis:
    description: "Causal/relational dimension across systems (e.g., 'gut-brain axis')"
    examples:
      - VTH BioDent: "bjgml-axis" (Bio-Joint-Gut-Mouth-Lung axis)
      - Healthcare general: "gut-brain-axis", "hpa-axis"
    schema_org_emission: 'additionalType="BiologicalAxis"'
    cluster_role: "part_of frameworks, contains member entities"

  general (default fallback):
    description: "Concept that is neither framework nor axis"
    use_when: "Concept is a single idea/principle, not organizing structure"
    backward_compat: "Existing concept entities default here on migration"
```

**Required Verification (per DR-012 governance):**

| Criterion | Status | Notes |
|-----------|--------|-------|
| C1: ≥3 real cases | ⏳ Collection | VTH BioDent has 2 examples; need 1+ more |
| C2: Cross-brand applicability | ⏳ Pending canvass | Other brands may have implicit frameworks |
| C3: Schema.org mapping | ✅ Documented | additionalType="ClinicalFramework"/"BiologicalAxis" |
| C4: Orthogonal | ✅ Architect verified | No existing entity_subtype value covers this |

**Rationale:**

✅ **Improves schema markup precision:**
- Without lock: concept entities emit generic `schema:DefinedTerm`
- With lock: framework concepts emit `additionalType="ClinicalFramework"` (richer for AI engines)

✅ **Improves cluster organization:**
- Framework concepts naturally become parent_of axes
- Axes naturally contain member entities via `part_of` edge
- Tree structure becomes self-documenting

✅ **Brand IP protection:**
- VTH BioDent's "Mouth Bio Mapping" framework gets proper schema markup as branded methodology
- Differentiates from generic concepts in AI search results

⚠️ **Backward compatibility considerations:**
- Existing concept entities have `entity_subtype` either NULL or arbitrary text
- Migration approach: allow NULL (don't force categorization)
- Only NEW concept entities at framework/axis level required to declare subtype

**Alternatives Rejected:**

- **A. No controlled vocabulary:** ❌ Inconsistent labeling, no schema markup benefit
- **B. Free-text entity_subtype:** ❌ Loses governance, fragments ontology
- **C. New entity_type values (e.g., 'framework' as type):** ❌ Breaks 15-type master list (Bible Part 2.5)

**Implementation Plan (if Locked 2026-05-20):**

```yaml
phase_1B_addition:
  migration_file: "20260520_053_add_concept_subtype_check_constraint.sql"
  
  ddl_change:
    table: seo_entity_graph
    constraint: |
      CHECK (
        entity_type != 'concept' 
        OR entity_subtype IS NULL 
        OR entity_subtype IN ('framework', 'axis', 'general')
      )
  
  backward_compat: "Allows NULL — does not force migration of existing concept entities"
  estimated_runtime: "< 1 minute"
  rollback: "DROP CONSTRAINT chk_concept_subtype"
```

**Consequences:**

✅ **Positive:**
- Schema markup richer for branded frameworks
- Cluster hierarchies become explicit
- Editorial team has clear "which subtype?" guidance for concept entities
- Backward compatible (NULL allowed)

⚠️ **Trade-offs:**
- DR-013 dependency: contraindicates/causes edges work better with framework/axis labeling
- Editorial training needed: "When should I declare framework vs axis vs general?"

**References:**
- Stream B work order (2026-05-09)
- DR-013 (companion — Edge Vocabulary v3.5 Expansion — Locked 2026-05-12)
- DR-012 (governance: 4 criteria + 2-week review)
- Bible v3.18 §2.5 (Entity Polymorphism — 15 entity_types)
- Bible v3.18 §2.6 (Entity Genesis Protocol — subtype population)
- Bible v3.18 §2.6.10 NEW (Concept Entity Subtype Controlled Vocabulary — full spec)
- Schema v1.14 §4.1 (entity_graph entity_subtype field + chk_concept_subtype CHECK constraint)

**Audit Trail:**

```yaml
proposal_history:
  
  2026_05_09:
    event: "DR-014 set to Proposed alongside DR-013 (Stream B work order)"
    next_action: "Cross-brand canvass for C2 evidence by 2026-05-13"
  
  2026_05_12_lock:
    event: "Operator-approved early lock — paired companion lock with DR-013; cross-brand evidence threshold exceeded"
    cross_brand_framework_evidence:
      - "VTH BioDent: pncl-medicine, mouth-bio-mapping"
      - "VTH Biodental Wellness: biodental-longevity-protocol, ceramic-first-implant-pathway, smart-plus, oral-inflammation-index"
      - "Trin Wellness: root-cause-medicine"
      - "Classy Clinic: classy-design-protocol, classy-face-blueprint"
      - "Relaxia Dental: fear-free-sleep-dentistry"
    cross_brand_axis_evidence:
      - "VTH BioDent: bjgml-axis (Bio-Joint-Gut-Mouth-Lung)"
      - "VTH Biodental Wellness: oral-systemic-axis"
      - "Trin Wellness: vascular-sexual-axis (DR-TW-004 pillar), hpg-axis (hormone cascade)"
      - "Future Vital Mind/Sleep brands: gut-brain-axis, neuroinflammation-axis"
    verification:
      C1_three_real_cases: "✅ Passed — ≥10 framework cases + ≥6 axis cases documented"
      C2_cross_brand: "✅ Passed — applies to ≥5 medical brands"
      C3_schema_mapping: "✅ Passed — additionalType=ClinicalFramework + BiologicalAxis"
      C4_orthogonal: "✅ Passed — no existing entity_subtype value covers organizational concepts"
    actor: Naphannop S. (operator approval)
    artifact_updated:
      - DECISION_RECORDS.md v1.11 → v1.12
      - EYWA_PROTOCOL Bible v3.17 → v3.18 (NEW §2.6.10)
      - Schema_Overview v1.13 → v1.14 (§4.1 chk_concept_subtype CHECK)
      - EYWA_HANDOVER v1.11 → v1.12
    deferred_to_operator_workload:
      - "Phase 1B migration 034_dr014_add_concept_subtype_check.sql"
      - "eywa-schema-pipeline plugin updates (emission rules per subtype)"
      - "eywa-acf-fields radio control (framework/axis/general) for concept entities"
      - "Audit query run to flag pre-v1.14 concept rows with non-standard entity_subtype values"
```

---

### [DR-013] — Edge Vocabulary v3.5 Expansion (causes + contraindicates) (2026-05-09 → Locked 2026-05-12) 🔒🧬

**Status:** **Locked 2026-05-12** (early lock — cross-brand evidence threshold exceeded; canvass deadline of 2026-05-13 surfaced ≥5 brand applications)  
**Locked Bible Version:** v3.17 (Part 2.7.2 vocabulary, 2.7.3 CHECK enum, 2.7.4 edge specs, 2.7.5 rules 8+9, 2.7.11 NEW typed edge_note sub-vocabulary)  
**Locked Schema Version:** v1.13 (§4.5 seo_entity_relationships — CHECK 14→16 enum + 3 new columns + 2 trigger functions)  
**Bible Reference:** Future v3.14 §2.7.2 (vocabulary expansion 10→12 edges) + §2.7.6 (typed edge_note sub-vocabulary)  
**Schema Reference:** Future v1.10 §4.5 (seo_entity_relationships CHECK constraint expansion + new fields)  
**Companion DR:** DR-014 (Concept Entity Subtype Lock)  

**Context:**

Per Stream B work order (2026-05-09) — field-tested feedback from VTH BioDent EGP work surfaced 2 vocabulary gaps:

**Gap 1 — Etiological relationships (causes):**
At Phase D (sitemap + content) work for VTH BioDent, encountered need to express "X causes Y" (e.g., "bruxism causes TMJ disorder"). Existing edges insufficient:
- `treats` = wrong direction (therapeutic, not etiological)
- `symptom_of` = wrong abstraction (manifestation marker, not origin)
- `related_to + notes` = loses directional + mechanistic signal + schema:causeOf SEO benefit

**Gap 2 — Safety conflicts (contraindicates):**
Procedure entities (e.g., "dental implant surgery") need to declare drug/condition contraindications. Existing edges insufficient:
- `alternative_to` = preference choice, not safety hard block
- `related_to + notes` = loses schema:contraindication SEO + queryable safety semantics

**Proposed Decision:**

Add 2 new edges to vocabulary (10 → 12 edges):

```yaml
new_edge_11_causes_caused_by:
  paired: yes (directional)
  edge_type_values: ['causes', 'caused_by']
  schema_org_mapping:
    causes: "schema:causeOf"
    caused_by: "schema:riskFactor (semantic inverse)"
  semantics: "Etiological — entity X creates/contributes-to condition Y"
  bible_section_for_full_spec: "v3.14 §2.7.2"

new_edge_12_contraindicates:
  paired: no (symmetric, undirected)
  edge_type_values: ['contraindicates']
  schema_org_mapping:
    contraindicates: "schema:contraindication"
  semantics: "Safety — entity X must not be combined with entity Y"
  bible_section_for_full_spec: "v3.14 §2.7.2"
  governance_addition: 
    - "edge_evidence_citation MANDATORY for strength≥2"
    - "medical_reviewer_signoff_at MANDATORY for strength=3 (absolute)"
```

**Typed edge_note Sub-Vocabulary (NEW concept per work order):**

Currently `edge_note` is free-text (ad-hoc). Stream B proposes formalizing per-edge-type controlled values:

```yaml
edge_note_typed_examples:
  
  causes:
    direct: "X is direct mechanistic cause"
    contributing: "X is one of multiple causes"
    developmental: "X causes Y over time/development"
    hypothesized: "Causal link proposed but not proven (strength=1 mandatory)"
  
  contraindicates:
    absolute: "Must never combine (strength=3, requires medical signoff)"
    relative-controllable: "Can combine with monitoring (strength=2)"
    relative-temporal: "Time-based contraindication (e.g., post-surgery window)"
    interferes-outcome: "Reduces efficacy without safety risk"
  
  related_to:
    comorbidity: "Frequently co-occur (deferred co_occurs_with edge candidate)"
    bidirectional-influence: "Mutual reinforcement"
    historical-association: "Documented but mechanism unclear"
  
  requires_assessment:
    diagnostic-gold-standard: "Primary diagnostic test"
    diagnostic-supportive: "Supporting test"
    pre-procedure-required: "Mandatory before procedure"

governance_for_edge_note:
  - "Adding new edge_note value = Category 2 change (lighter than new edge)"
  - "Schema pipeline emits different schema.org based on edge_note (e.g., diagnostic-gold-standard → primaryDiagnosis)"
```

**Required Verification (per DR-012 governance):**

| Criterion | Status | Notes |
|-----------|--------|-------|
| **C1: ≥3 real cases** | ⏳ In Collection | VTH BioDent has multiple cases; collected in Notion governance database |
| **C2: Cross-brand applicability (≥2 brands)** | ⏳ **PENDING** | Architect canvasses 14 other brands by 2026-05-13. Critical blocker. |
| **C3: Schema.org mapping** | ✅ Documented | causeOf, riskFactor, contraindication all in schema.org |
| **C4: Orthogonal to existing 10** | ✅ Architect verified | causes ≠ treats; contraindicates ≠ alternative_to. Awaits board signoff. |

**Critical Path:**
- C2 (cross-brand) is the **primary risk**. If only VTH BioDent has cases → DR-013 should reject + use brand_scope workaround
- Notion governance database tracks evidence collection structurally

**Rationale:**

✅ **Field-tested origin (not speculative):**
- Stream B emerged from real VTH BioDent EGP work, not hypothetical scenarios
- Naphannop (VTH BioDent founder) identified gap during actual entity creation

✅ **Schema.org alignment strengthens AI citation:**
- `schema:causeOf` and `schema:contraindication` are well-established medical schema properties
- Google Health Knowledge Panel + AI engines weight these heavily for medical content
- Without these edges, JSON-LD emission misses high-value markup

✅ **Patient safety semantics (contraindicates):**
- Healthcare brands NEED ability to express "do not combine"
- Workaround via `alternative_to + notes` loses critical safety signal
- DR-008 Two-Column Identity already established medical-grade governance posture

✅ **Brand IP differentiation (when paired with DR-014):**
- Framework + axis concepts can have explicit causal chains
- VTH BioDent's "Mouth Bio Mapping" methodology gets richer schema markup

✅ **Governance test case for DR-012:**
- DR-013 is the FIRST proposed addition under DR-012's 4-criteria + 2-week review process
- Outcome (Lock or Reject) sets precedent for future edge proposals
- Either decision validates that DR-012 governance works

**Alternatives Rejected:**

- **A. Use `related_to + notes` as catch-all:**
  - ❌ Loses schema:causeOf / schema:contraindication SEO benefit
  - ❌ Loses queryable semantics (can't filter "all causal chains for X" or "all contraindications for procedure Y")
  - ❌ Loses governance enforcement (edge_evidence_citation mandatory for safety-critical edges)
  - ⚠️ Acceptable as workaround if DR-013 rejected (single-brand pattern)

- **B. JSONB-only storage (no edge_type expansion):**
  - ❌ Schema generation pipeline can't emit proper JSON-LD
  - ❌ Loses CHECK constraint enforcement
  - ❌ Cross-brand inconsistency

- **C. Brand-specific edge extensions:**
  - ❌ Fragments ontology across brands (against DR-001 Federation Pattern)
  - ❌ Cross-brand schema markup becomes inconsistent
  - ❌ Editorial team confused which edges apply when

**Consequences (if Locked):**

✅ **Positive:**
- Vocabulary 10 → 12 edges
- Schema markup richer for healthcare brands
- Patient safety queries possible (find all contraindications for procedure X)
- Causal chain visualization in knowledge graph
- Brand IP (frameworks) gets proper schema:additionalType emission

⚠️ **Operational requirements:**
- 5 SQL migrations (Phase 1E)
- eywa-schema-pipeline plugin updates (~16-20h dev)
- eywa-acf-fields field group updates (~3h)
- relationships.md template updates
- genesis_checklist.yaml validation rules
- n8n classifier updates (test 6 active workflows)
- Notion select options sync

⚠️ **Schema Review Board approval required:**
- Category 3 (Major) change per Bible §15.2
- Medical reviewer signoff required for contraindicates strength=3 cases

⚠️ **Effort estimate:** ~58-64 hours total (Architect + Tech Lead) per Stream B work order

**Consequences (if Rejected):**

⚠️ **Workaround pattern:**
- VTH BioDent uses `related_to + notes` with `brand_scope=['vth-biodent']`
- Schema pipeline custom Layer 3 handler emits `schema:relatedCondition` (less specific than causeOf)
- For contraindicates: use `alternative_to + notes='safety-critical'` with custom schema additionalType
- Reduced SEO benefit but functional

✅ **Positive of rejection:**
- DR-012 governance proven to work (catches single-brand premature additions)
- VTH BioDent unblocked within hours
- Future cross-brand cases can re-trigger DR-013 with stronger evidence

**Implementation Plan (if Locked 2026-05-20):**

Per Stream B work order — Phase 1E migrations:

```yaml
phase_1E_migrations:
  20260520_050_extend_edge_type_check_constraint.sql:
    action: "ALTER seo_entity_relationships CHECK constraint to 16 enum values"
    breaking: no (additive)
  
  20260520_051_add_edge_evidence_citation_field.sql:
    action: "ADD edge_evidence_citation text NULL FK to seo_citations"
    breaking: no (additive)
  
  20260520_052_add_medical_reviewer_signoff_fields.sql:
    action: "ADD medical_reviewer_signoff_at timestamptz + medical_reviewer_fp text"
    breaking: no (additive)
  
  20260520_053_add_concept_subtype_check_constraint.sql:
    action: "ADD CHECK constraint for entity_subtype on concept type"
    breaking: no (companion to DR-014, NULL-allowed)
  
  20260520_054_add_edge_validation_triggers.sql:
    action: "Trigger functions for evidence + signoff enforcement"
    breaking: no
```

**Bible v3.14 Updates Planned:**

```yaml
bible_v3_14_sections_to_update:
  
  section_2_7_2:
    change: "Master vocabulary 10 → 12 edges"
    callout: "v3.5 expansion rationale → see DR-013"
    callout: "deferred co_occurs_with → see DR-013 future amendment"
  
  section_2_7_3:
    change: "Storage Pattern CHECK constraint 14 → 16 enum values"
  
  section_2_7_4:
    change: "Decision flow precedence — causes/contraindicates inserted at correct positions"
  
  section_2_7_5_now_2_7_5_extended:
    add_rules:
      - "causes edge requires evidence_citation if strength≥2"
      - "contraindicates edge requires evidence_citation if strength≥2"
      - "contraindicates strength=3 requires medical reviewer signoff"
  
  section_2_7_6_NEW:
    title: "Edge Note Typed Sub-Vocabulary"
    content: "Per-edge allowed edge_note values + schema.org emission rules"
  
  section_2_6:
    add: "entity_subtype controlled vocabulary for concept type (per DR-014)"
  
  section_2_6_2:
    update: "Step 4 — Procedures with safety concerns must have ≥1 contraindicates edge"
  
  section_27_3_1:
    update: "edge_strength formula — typed edge_note multiplier"
```

**Schema v1.10 Updates Planned:**

```yaml
schema_v1_10_changes:
  
  section_4_5_seo_entity_relationships:
    add_fields:
      - edge_evidence_citation text NULL (FK to seo_citations.fingerprint)
      - medical_reviewer_signoff_at timestamptz NULL
      - medical_reviewer_fp text NULL (FK to seo_authors.fingerprint)
    expand_check_constraint: 16 enum values
  
  section_4_2_seo_entity_graph:
    add_check_constraint: "Concept entity_subtype IN (NULL, 'framework', 'axis', 'general')"
  
  appendix_F_helper_functions:
    add_functions:
      - fn_validate_edge_evidence_requirement()
      - fn_validate_medical_signoff_for_contraindication()
      - fn_emit_schema_org_per_edge_note()
```

**References:**
- Stream B work order (2026-05-09 — "EYWA v3.4 → v3.5 Documentation Update Checklist")
- DR-014 (companion — Concept Entity Subtype Lock)
- DR-012 (governance — 4 criteria + 2-week review)
- DR-008 (Two-Column Identity Pattern — preserved during v3.5)
- DR-001 (Federation Pattern — cross-brand impact)
- Bible v3.13 §2.7 (current 10-edge vocabulary)
- Schema v1.9 §4.5 (seo_entity_relationships)
- Naphannop S. (VTH BioDent founder, original proposer)

**Audit Trail:**

```yaml
proposal_history:
  
  2026_05_09_AM:
    event: "VTH BioDent Phase D EGP work surfaced gap"
    actor: Naphannop S.
    outcome: "Stream B work order drafted"
  
  2026_05_09_PM:
    event: "Cross-checked with Stream A (DR-011 + DR-012 just locked)"
    discovery: "DR number collision + version collision"
    resolution: "Rename Stream B → DR-013/014, target v3.14/v1.10"
  
  2026_05_09_late:
    event: "DR-013 + DR-014 set to Proposed status"
    artifact_created:
      - DECISION_RECORDS.md v1.3
      - EYWA_HANDOVER.md v1.5
    next_action: "Architect canvasses 14 brands for C2 cross-brand evidence by 2026-05-13"
  
  2026_05_12_lock:
    event: "Operator-approved early lock — C2 cross-brand evidence exceeded threshold"
    cross_brand_evidence_captured:
      - "Trin Wellness (DR-TW-004): Atherosclerosis → causes → ED (strength=3, AHA/AUA guideline)"
      - "Trin Wellness: TRT ↔ contraindicates ↔ Prostate cancer history (absolute, strength=3)"
      - "VTH Biodental Wellness: Periodontal disease → causes → Systemic inflammation (developmental, strength=2)"
      - "VTH BioDent: Bruxism → causes → TMJ disorder (direct, strength=2 — original Stream B case)"
      - "SmileScape: Dental implant surgery ↔ contraindicates ↔ Bisphosphonate therapy (relative-controllable, strength=2)"
      - "SmileScape: Untreated periodontitis → causes → Implant failure (contributing, strength=2)"
      - "Relaxia Dental: IV sedation ↔ contraindicates ↔ Severe OSA without CPAP (absolute, strength=3)"
    verification:
      C1_three_real_cases: "✅ Passed — ≥7 cases documented across 4+ brands"
      C2_cross_brand: "✅ Passed — applies to ≥5 medical brands (threshold was ≥2)"
      C3_schema_mapping: "✅ Passed — schema:causeOf + schema:contraindication + schema:riskFactor documented"
      C4_orthogonal: "✅ Passed — distinct from treats, alternative_to, related_to, symptom_of"
    actor: Naphannop S. (operator approval)
    artifact_updated:
      - DECISION_RECORDS.md v1.10 → v1.11
      - EYWA_PROTOCOL Bible v3.16 → v3.17 (Part 2.7.2/2.7.3/2.7.4/2.7.5/2.7.11)
      - Schema_Overview v1.12 → v1.13 (§4.5 columns + triggers)
      - EYWA_HANDOVER v1.10 → v1.11
    deferred_to_operator_workload:
      - "Phase 1E SQL migrations (030/031/032/033)"
      - "eywa-schema-pipeline plugin updates (~16-20h dev)"
      - "eywa-acf-fields field group updates"
      - "n8n classifier updates (test 6 active workflows)"
      - "Notion select options sync"
      - "Brand snapshot block refresh at next Stage gate for brands on bible_version 3.16"
    companion_dr_status:
      DR-014: "Remains Proposed — separate lock cycle"
```

---

## Decisions Log

### [DR-012] — Edge Vocabulary Evolution Policy (2026-05-08)

**Status:** Locked  
**Bible Reference:** Section 2.7.5 (Edge Vocabulary Evolution Policy)  
**Schema Reference:** v1.9 §4.5 (seo_entity_relationships CHECK constraint)

**Context:**

The 10-edge vocabulary defined in Bible Part 2.7.2 was intentionally minimal for healthcare + wellness Phase 1:

```yaml
locked_edges_10:
  hierarchical: [parent_of, child_of, subtype_of, part_of, contains]
  clinical: [treats, treated_by, symptom_of, requires_assessment]
  utility: [uses, used_by, alternative_to, evidenced_by, related_to]
```

Expert review (2026-05-08) raised concern about edge vocabulary potentially being insufficient as EYWA expands to verticals like education, finance, B2B SaaS, or AI systems. The catch-all `related_to` becomes overloaded, semantic distinctions blur, and ad-hoc edge additions risk ontology fragmentation.

Without governance policy, additions become reactive ("we need this edge for THIS use case") and lose architectural coherence.

**Decision:**

Adopt **Edge Vocabulary Evolution Policy** with formal addition workflow.

**Lock Status:**

The 10 existing edges are LOCKED. No new edges may be added without satisfying ALL 4 criteria below + completing the formal addition workflow.

**4 Criteria for Adding an Edge (ALL must be met):**

1. **Real Use Case Proven**
   - ≥3 real entity pairs encountered where existing 10 edges fit poorly
   - Cases must come from actual EGP execution (not hypothetical)
   - Documented in DECISION_RECORDS pending section

2. **Cross-Brand Applicability**
   - New edge usable across ≥2 brands (not single-brand specific)
   - Brand-specific needs handled via `brand_scope[]` on existing edges

3. **Schema.org Mapping Exists**
   - Edge maps to documented schema.org property OR generates measurable SEO benefit
   - Required for Bible Part 26 (Schema Generation Pipeline) integration

4. **Orthogonal to Existing 10**
   - Captures distinct semantics not expressible by combining existing edges
   - Test: Can the relationship be expressed by `existing_edge + qualifier`? If yes, don't add.

**Addition Workflow:**

```yaml
edge_addition_steps:
  step_1_collect_evidence:
    duration: "1-3 months production usage"
    artifact: "Pending edges log with ≥3 real cases documented"
  
  step_2_propose_via_dr:
    template: "## [DR-XXX] — Add Edge: '{edge_name}' (YYYY-MM-DD)"
    required_sections:
      - Evidence (3+ cases)
      - Cross-brand applicability proof
      - schema.org mapping spec
      - Rationale why existing edges insufficient
  
  step_3_review_period:
    duration: "2 weeks"
    reviewers:
      - 1 strategy lead (ontology consistency)
      - 1 engineering lead (implementation impact)
      - 1 editorial lead (content workflow impact)
  
  step_4_acceptance_or_rejection:
    if_approved:
      - DR status: Locked
      - Update Bible Part 2.7.2 with new edge
      - Update Schema seo_entity_relationships CHECK constraint
      - Update n8n edge classification logic
      - Update WordPress ACF eywa_relationships fields
    if_rejected:
      - Document rejection rationale in DR
      - Use existing edges with notes column for special cases
```

**Parking Lot — Future Edges Under Consideration:**

Documented but NOT activated. Will be added if all 4 criteria are met.

```yaml
parking_lot_edges:
  
  measures:
    description: "Diagnostic relationship — entity X measures property Y"
    example: "hrv_test measures autonomic_recovery"
    schema_org_candidate: "diagnoses or hasMeasurement"
    blocked_by: "Need 3+ cross-brand cases (currently 1: VTH BioDent)"
  
  predicts_risk_of:
    description: "Predictive — biomarker → future condition"
    example: "elevated_hs_crp predicts_risk_of cardiovascular_disease"
    schema_org_candidate: "relatedCondition + RiskFactor extension"
    blocked_by: "Need 3+ real cases + schema.org mapping research"
  
  contraindicated_with:
    description: "Treatment/drug interaction conflicts"
    example: "warfarin contraindicated_with vitamin_k_supplements"
    blocked_by: "Currently uses 'alternative_to' + notes (sufficient)"
  
  prerequisite_for:
    description: "Sequential dependency — procedure A before procedure B"
    example: "cbct_scan prerequisite_for dental_implant_surgery"
    blocked_by: "Currently uses 'requires_assessment' (close enough)"
```

**Anti-Patterns (Edge Additions to REJECT):**

```yaml
do_not_add_edge_when:
  
  pattern_1_brand_specific:
    bad: "'mbm_module_of' (VTH BioDent specific)"
    fix: "Use 'part_of' edge with brand_scope=['vth-biodent']"
  
  pattern_2_temporary_campaign:
    bad: "'q4_2026_promotion_for'"
    fix: "Use 'related_to' with notes column, time-bound"
  
  pattern_3_existing_edge_sufficient:
    bad: "'cures' (similar to 'treats')"
    fix: "Use 'treats' — distinguish severity in entity properties"
  
  pattern_4_too_specific:
    bad: "'is_secondary_outcome_marker_for'"
    fix: "Use 'evidenced_by' with citation tier in notes"
  
  pattern_5_one_off_use_case:
    bad: "'sponsors' (single brand uses)"
    fix: "Out of scope for ontology — store in business_relationships table if needed"
```

**Edge Removal Policy:**

```yaml
edge_deprecation_workflow:
  if_unused_12_months:
    1: Document zero-usage in audit log
    2: Propose deprecation via DR
    3: Mark as deprecated in Bible (do not remove immediately)
    4: 12-month grace period — no new usage, existing data preserved
    5: Migration to alternative edge type
    6: Final removal in next major version

current_status: "All 10 edges actively used as of v3.13"
```

**Rationale:**

✅ **Prevents ontology drift before it manifests:**
- Without policy: edges added ad-hoc → vocabulary balloons → schema markup fragments
- With policy: deliberate evolution → vocabulary stays minimal + meaningful

✅ **Aligns with EYWA philosophy:**
- "Discipline > convenience" — same principle as VTH BioDent founder's note
- Mirrors Section 2.6.6.1 EUG (algorithmic enforcement of human discipline)

✅ **Preserves catch-all utility:**
- `related_to` edge intentionally exists for relationships that don't warrant new edges
- Combined with `notes` column, handles 95% of edge cases without vocabulary expansion

✅ **Documented future path:**
- Parking lot edges signal awareness of likely future needs
- Vertical-specific brands (education, finance) can plan for future additions
- Operator retains optionality without committing prematurely

**Alternatives Rejected:**

- **A. Add edges proactively (anticipatory):** ❌ Pre-mature optimization; YAGNI principle
- **B. No policy — add as needed informally:** ❌ Predictably leads to drift over time
- **C. Lock vocabulary forever:** ❌ Too rigid; some verticals genuinely need additions
- **D. Per-brand edge vocabularies:** ❌ Fragments cross-brand knowledge graph; against federation principle

**Consequences:**

✅ **Positive:**
- Edge vocabulary stays minimal + intentional
- Cross-brand schema markup remains consistent
- New edges, when added, have proven justification
- Editorial team has clear "use what edge?" guidance via existing 10
- Future verticals (education, finance, AI) get clear path to add domain-specific edges if truly needed

⚠️ **Trade-offs:**
- Operator must use `related_to + notes` for edge cases instead of creating new edges
- 2-week review period adds friction (but appropriate given irreversibility)
- ≥3 cases requirement may delay edge additions even when need is clear

⚠️ **Process discipline required:**
- Pending edges log must be maintained (DECISION_RECORDS pending section)
- Quarterly review of catch-all `related_to` usage to identify potential new edges
- Annual review of parking lot edges (re-evaluate criteria)

**References:**
- Bible Part 2.7.2 (Edge Vocabulary — 10 edges)
- Bible Section 2.7.5 (Edge Evolution Policy — full spec)
- Schema v1.9 §4.5 (seo_entity_relationships CHECK constraint)
- Bible Part 26.4 (Schema Generation Pipeline — edge → JSON-LD)
- DR-001 (Multi-Brand Federation — cross-brand consistency principle)
- Expert review feedback (2026-05-08) — identified edge vocabulary as future risk

---

### [DR-011] — Entity Uniqueness Guard (EUG) Two-Wave Approach (2026-05-08)

**Status:** Locked  
**Bible Reference:** Section 2.6.6.1 (EUG v1.0) + Section 2.6.6.2 (EUG v2.0 Roadmap)  
**Schema Reference:** v1.9 Appendix G

**Context:**

Bible Part 2.6.6 establishes "Search Before Create" as a discipline for entity creation, but it relies on **human judgment** to detect duplicates. Real-world scenarios that this misses:

- **Typos:** Operator creates `tmj-therapyy` (95% similar to existing `tmj-therapy`)
- **Format variations:** `TMJ_Therapy`, `tmj_therapy`, `TMJ-therapy` all create separate rows
- **Synonyms:** `temporomandibular-joint-therapy` and `tmj-therapy` are the same concept
- **Plurals:** `tmj-disorder` vs `tmj-disorders` — accidentally split
- **Cross-language:** Thai `การรักษาขากรรไกร` collision with English `tmj-therapy` not detected

At 15 brands today, manual discipline + Bible Part 2.6.6 search is sufficient. At 30+ brands and 5,000+ entities (target scale), human discipline alone fails. Expert review (2026-05-08) confirmed "Ontology Drift" as the #1 future risk and called this the "single most important governance addition needed."

The operator (เพื่อน) explicitly raised the example: *"สมมุตว่าในระบบเรามี entity tmj therapy แล้วมันอาจจะมี Temporomandibular joint therapy มาเพิ่มหรือป่าว ซึ่งมันคือเรื่องเดียวกัน อาจจะต้องสร้างระบบป้องกันตรงนี้ขึ้นมา"*

**Decision:**

Adopt **Entity Uniqueness Guard (EUG)** as a 2-wave deployment:

**Wave 1 (Phase 1A — DEPLOY NOW):**

3-layer enforcement using Pure SQL + pg_trgm (already required):

1. **Layer 1 — Database UNIQUE constraint:**
   - `UNIQUE (entity_slug, brand_scope_primary)` on `seo_entity_graph`
   - Hard block at INSERT/UPDATE — PostgreSQL native enforcement
   
2. **Layer 2 — Slug normalization function:**
   - `normalize_entity_slug(text)` returns canonical kebab-case
   - BEFORE INSERT/UPDATE trigger auto-applies
   - Catches: case variations, underscores, whitespace, special characters

3. **Layer 3a — Alias collision check:**
   - `check_alias_collision(slug, aliases, brand_scope)` function
   - Searches existing `canonical_names jsonb` + `aliases jsonb` for matches
   - Application-level pre-flight call before INSERT

4. **Layer 3b — Trigram similarity warning:**
   - `find_similar_entities(slug, threshold, brand_scope, limit)` function
   - Uses `pg_trgm` extension (already required for keywords)
   - Threshold semantics: ≥0.90 BLOCK, 0.75-0.89 WARN, 0.60-0.74 INFO

**Coverage:** ~85% of duplicate scenarios at $0 marginal cost (no new dependencies).

**Wave 2 (Phase 2+ — ROADMAP):**

Add Layer 4 vector similarity check leveraging existing pgvector + `seo_entity_embeddings` infrastructure:

- Embed candidate entity description (OpenAI text-embedding-3-small, ~$0.0001/check)
- Cosine similarity search against existing entity embeddings
- Catches deep semantic synonyms + cross-language equivalents
- Coverage extends to ~99%

**Wave 2 Activation Criteria:**
- pgvector extension live
- Embedding pipeline (n8n + OpenAI) running
- 100+ entities with embeddings populated
- Cost monitoring proven < $5/month

**Rationale:**

✅ **Two-wave defers complexity until value proven:**
- Wave 1 deployable Phase 1A (now) — uses pg_trgm already required
- Wave 2 deferred to Phase 2 — uses pgvector when infrastructure ready
- Avoids over-engineering when 85% solution catches majority of cases

✅ **Smart leveraging of existing infrastructure:**
- pg_trgm: already required for `seo_x_ads_keywords_contextual_master` fuzzy search
- pgvector: already planned for `seo_entity_embeddings` (Schema Group 7)
- No NEW dependencies required for either wave

✅ **Aligned with operator's expressed need:**
- Operator's TMJ therapy / Temporomandibular joint therapy scenario solved by Layer 3a (alias collision) — works because aliases jsonb stores synonyms
- Wave 1 ships discipline-enforcement before drift becomes systemic problem

✅ **Architectural philosophy fit:**
- "The biggest risk is internal drift — discipline > convenience" (founder principle)
- Algorithmic enforcement scales beyond human attention bandwidth
- Aligns with "measurement-first" discipline pattern from VTH BioDent flagship

**Alternatives Rejected:**

- **A. Entity Registry Service (microservice):** ❌ Over-engineering for current scale; Bible Part 19 already provides quality framework
- **B. Embeddings-only (no string layers):** ❌ Higher cost, requires API for every check, doesn't catch typos as well as trigram
- **C. Manual review queue:** ❌ Adds bureaucracy + bottleneck; AI-assisted operator workflow already handles edge cases via Layer 3 warnings
- **D. Defer entirely until problem manifests:** ❌ Reactive fixes harder than preventive; ontology cleanup at 1000+ entities exponentially more expensive

**Consequences:**

✅ **Positive:**
- 85% of duplicate scenarios caught automatically
- Zero new infrastructure dependencies for Wave 1
- Zero ongoing cost for Wave 1
- Clear roadmap to 99% coverage in Wave 2
- Aligns with existing schema (uses canonical_names + aliases jsonb already in Schema v1.8)
- Self-documenting: pre-flight function returns structured collision details
- Migration is additive (no breaking changes)

⚠️ **Trade-offs:**
- Layer 3a/3b add 10-100ms to entity creation (acceptable for non-high-frequency ops)
- Operator must understand decision matrix when collision detected (4 options: adopt/alias/specify/reject)
- ~15% of edge cases (deep semantic synonyms without alias overlap) not caught until Wave 2
- Editorial discipline still required for alias population at entity creation (multilingual coverage)

⚠️ **Operational requirements:**
- n8n workflows must be updated to call `eug_preflight_check()` before INSERT
- Notion automation must validate slugs before sync
- Editorial team must populate `aliases` jsonb at entity creation (not just canonical_names)
- Phase 1A migration adds 1 SQL file: `06-entity-uniqueness-guard.sql`

**Implementation Plan:**

```yaml
phase_1a_eug_v1_deployment:
  ☐ Step 1: Verify pg_trgm extension active (CREATE EXTENSION IF NOT EXISTS)
  ☐ Step 2: Deploy 4 SQL functions (normalize, check_alias, find_similar, preflight)
  ☐ Step 3: Deploy 4 indexes (slug_trgm, canonical_names_gin, aliases_gin, slug_brand_scope)
  ☐ Step 4: Deploy brand_scope_primary computed column + UNIQUE constraint
  ☐ Step 5: Deploy normalize trigger
  ☐ Step 6: Optional backfill (normalize existing slugs)
  ☐ Step 7: Update n8n entity creation flow to call preflight
  ☐ Step 8: Update editorial guidance: populate aliases at create time

phase_2_eug_v2_activation_criteria:
  ☐ pgvector extension active in production
  ☐ seo_entity_embeddings table live with embedding pipeline
  ☐ 100+ entities with embeddings populated
  ☐ Embedding API cost monitoring proven < $5/month
  ☐ Vector similarity query performance < 100ms baseline
  
estimated_total_dev_time: "Wave 1: 1-2 hours; Wave 2: 4-8 hours"
breaking_changes: "None"
rollback_capability: "Full — drop functions, constraints, triggers, indexes"
```

**References:**
- Bible Section 2.6.6 (Search Before Create — predecessor discipline)
- Bible Section 2.6.6.1 (EUG v1.0 specification)
- Bible Section 2.6.6.2 (EUG v2.0 roadmap)
- Schema v1.9 Appendix G (full implementation)
- DR-008 (Two-Column Identity Pattern — uses fingerprint, not slug, for relations)
- DR-009 (Multilingual Strategy — aliases jsonb structure leveraged by Layer 3a)
- DR-010 (Brand Scope Architecture — used by Layer 1 UNIQUE constraint)
- Bible Part 19.3 Dimension 5 (Uniqueness — formalizes what was aspirational)
- Expert review feedback (2026-05-08) — identified ontology drift as #1 risk

---

### [DR-010] — Brand Scope Architecture (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 2.4, Part 28.13  
**Schema Reference:** v1.8

**Context:**  
EYWA federation ใช้ 1 shared Supabase + N Notion workspaces (DR-001) แต่ schema เดิมมี 3 รูปแบบของการเก็บ brand reference ที่ขัดแย้งกัน:
- `seo_entity_graph.brand_scope` = `text[]` (notion_ids without dashes)
- `seo_website_page_master.brand_id` = `text` (UUID format)
- `seo_x_ads_keywords_contextual_master.brand` = `text` (FK to brands.brand_name)

ทำให้ cross-table queries ยาก, federation pattern ใช้จริงไม่ได้, และ shared entities ต้องบอกได้ว่าใช้ใน brand ไหนบ้าง

**Decision:**  
Standardize brand association ผ่าน 2 patterns:

**Pattern A — `brand_scope text[]` (สำหรับตารางที่ shared ระหว่าง brands):**
- Single brand: `['vth-biodent']`
- Universal: `['*']`
- Shared: `['vth-biodent', 'vitalsleep', 'the-face-hospital']`

Tables: `seo_entity_graph`, `seo_topic_cluster_master`, `seo_authors`, `seo_citations`

**Pattern B — `brand_slug text NOT NULL` (สำหรับตารางที่ผูก 1 brand):**
- Single value only
- FK to `brands.brand_slug`

Tables: `seo_website_page_master`, `seo_brand_doctors`, `seo_brand_branches`, `seo_x_ads_keywords_contextual_master`

**`brand_slug`** = canonical brand identifier:
- Lowercase, kebab-case, immutable
- Examples: `vth-biodent`, `vitalsleep`, `the-face-by-vertex`
- Replaces inconsistent UUID/notion_id usage

**Rationale:**  
- **Pattern A**: Entities/clusters/authors อาจ shared หลาย brand → array makes sense
- **Pattern B**: Pages/doctors/branches ผูก 1 brand เสมอ → scalar simpler + FK enforceable
- **brand_slug**: Stable, human-readable, ไม่ผูก Notion IDs, ใช้ใน URL/file naming ได้
- ลด JOIN complexity (no UUID lookups, no notion_id stripping)
- Federation queries ทำได้ง่าย: `WHERE 'vth-biodent' = ANY(brand_scope)`

**Consequences:**
- ✅ Federation pattern (DR-001) implementable in queries
- ✅ Cross-brand entity sharing (DR-003) supported via array
- ✅ GIN index on `brand_scope[]` for fast lookup
- ⚠️ Migration: rename `brand_id` → `brand_slug` in page_master
- ⚠️ Migration: rename `brand` → `brand_slug` in keywords_master (kept FK)
- ⚠️ Backfill needed: notion_id → brand_slug mapping

**Implementation:**
- New column `brand_slug` on `brands` table (UNIQUE, immutable)
- 15 brand slugs locked: vth-biodent, vitalsleep-and-wellness, the-face-by-vertex, etc.
- All references migrate to `brand_slug` in Phase 1

**References:**
- DR-001 (Multi-Brand Federation Pattern)
- DR-003 (Single Entity, Multilingual Labels)
- Bible Part 2.4 (Multi-Brand Sharing)
- Schema v1.8 §3.1, §4.1, §5.1

---

### [DR-009] — Multilingual Strategy v2 (Two-Tier Pattern) (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 28 (entire)  
**Schema Reference:** v1.8

**Context:**  
EYWA targets 8 languages (TH, EN immediate; ZH, JA, KO, AR, FR, ES phased). Bible v3.9 introduced "Single Entity, Multilingual Labels" pattern (DR-003) but didn't differentiate between:
- **Concept tables** (entity, brand, author): same concept, multiple language labels
- **Content tables** (page, keyword, review): each language is separate content asset

Without this differentiation, applying single-row jsonb pattern to all tables would break content-level workflows (separate URL slugs, distinct SEO metadata, independent translation status per language).

**Decision:**  
Adopt **Two-Tier Multilingual Strategy**:

**Tier 1 — Concept Tables (1 row + jsonb translations):**

Used for entities where the concept is universal but has multiple language labels.

```jsonb
canonical_names: {"en": "Sleep Apnea", "th": "ภาวะหยุดหายใจขณะหลับ"}
aliases: {
  "en": ["sleep apnea syndrome", "OSA"],
  "th": ["หยุดหายใจตอนนอน", "นอนกรนแบบรุนแรง"]
}
descriptions: {"en": "...", "th": "..."}
```

Tables:
- `seo_entity_graph` (ent)
- `seo_topic_cluster_master` (clus)
- `brands` (brnd)
- `seo_authors` (auth)
- `seo_brand_doctors` (doc)
- `seo_brand_branches` (brch)
- `seo_citations` (cite)

**Tier 2 — Content Tables (1 row per language + translation_group_id):**

Used for content where each language version is a separate asset with unique SEO properties.

```yaml
schema:
  fingerprint: "page_01HZP5K2A"  # unique per row
  translation_group_id: "tg_01HZP5K2X"  # shared across translations
  page_language: "th"
  is_source_page: true  # exactly 1 per group
  source_translation_fp: "page_01HZP5K2A"  # NULL if is_source
```

Tables:
- `seo_website_page_master` (page)
- `seo_x_ads_keywords_contextual_master` (kw) — already has `translation_group`
- `seo_editorial_reviews` (rev)

**Translation Group ID Format:** `tg_{ULID16}` (separate namespace from row fingerprints)

**Rationale:**  
- **Concept** = "entity is the same, only label changes" → 1 row, jsonb is right
- **Content** = "each language is unique content with its own URL, slug, metadata" → separate rows
- jsonb keeps concept tables DRY (Wikidata link / ICD-10 / parent_fp shared across languages)
- translation_group_id enables consolidated performance queries:
  ```sql
  SELECT translation_group_id, sum(views) 
  FROM page_analytics 
  GROUP BY translation_group_id;
  ```
- Pattern matches existing keyword table's `translation_group` column (already production-tested)
- Source page flag enables canonical reference for hreflang generation

**Consequences:**
- ✅ Each table has clear multilingual semantics
- ✅ Content workflows (status per language, due dates per translation) supported
- ✅ Consolidated analytics across language versions possible
- ✅ hreflang generation has canonical source
- ⚠️ Pages: 1 entity = N pages (4 languages = 4 rows)
- ⚠️ Migration: existing page rows need `translation_group_id` backfill
- ⚠️ Constraint: only 1 `is_source_page = true` per group (UNIQUE INDEX with WHERE clause)

**Edge Cases:**
- Entity adds language: just add key to `canonical_names` jsonb (no new row)
- Page adds language: new row with same `translation_group_id`, `is_source_page = false`
- Translation removed: delete row, group still valid
- All translations of group deleted: orphaned group_id (cleanup periodically)

**References:**
- DR-003 (Single Entity, Multilingual Labels) — extended by this DR
- Bible Part 28 (Multilingual Architecture)
- Schema v1.8 §3-5 (table definitions per tier)

---

### [DR-008] — Two-Column Identity Pattern (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 18.9 (NEW)  
**Schema Reference:** v1.8

**Context:**  
Existing fingerprint patterns use composite of business fields:
- `page:vth-biodent:tmj-treatment`
- `entity:sleep-apnea`
- `vth-biodent::th::th::tmj รักษา` (keyword)

This works for **immutable** fields (keyword text never changes) but breaks for **mutable** fields (entity slug renames, page slug restructures, ICD-10 corrections by AI/expert review).

**Decision:**  
Every table (except `seo_x_ads_keywords_contextual_master`) gets TWO identity columns:

| Column | Type | Mutability | Purpose |
|--------|------|------------|---------|
| `fingerprint` | text UNIQUE NOT NULL | IMMUTABLE | Machine identity, used for FK/joins |
| `fingerprint_display_name` | text NOT NULL | MUTABLE | Human label, debug aid |

**Format:**
- `fingerprint`: `{tablecode}_{ULID16}` (Pattern B)
  - Example: `ent_01HZP5K2XQR7N3MF`
  - 16 characters of ULID (time-sortable, 80-bit entropy)
  - Compact yet collision-safe
- `fingerprint_display_name`: `{fp_last_6}::{type}::{slug}::{key_data}`
  - Example: `n3mf::condition::sleep-apnea::g47.3`
  - First 6 chars = last 6 of fingerprint (cross-check)
  - `::` (double colon) separator
  - Auto-refreshed when source data changes

**Exception:** `seo_x_ads_keywords_contextual_master` keeps existing fingerprint format `{brand_slug}::{market}::{language}::{keyword}` because it's already self-documenting and immutable.

**Rationale:**
- ✅ Stable machine identity prevents broken relations on rename
- ✅ Human-readable label enables debugging and data validation
- ✅ Last-6-of-fingerprint in display creates double cross-check
- ✅ ULID provides time-ordering benefit for free
- ✅ ICD-10 corrections by AI don't cascade-break references
- ✅ Two-Phase Hierarchy Sync (DR-006) more robust

**Consequences:**
- ✅ All tables follow consistent pattern
- ✅ FK columns use `fingerprint` (not slug)
- ✅ Debug surface area expanded (display name visible in queries)
- ⚠️ Migration: backfill existing rows with new fingerprint format
- ⚠️ Trigger overhead must be measured (ULID generation + display refresh)
- ⚠️ Cross-system updates (Notion ↔ Supabase) reference `fingerprint` consistently

**Implementation Order:**

1. Create `generate_ulid()` function
2. Create `generate_*_display_name()` functions per table
3. ALTER existing tables: add columns (NULLable initially)
4. Backfill existing rows
5. Add triggers (insert, update, immutability)
6. Set NOT NULL constraint after backfill complete
7. Update n8n workflows to use new column

**References:**
- Bible Part 18.9 (NEW — Two-Column Identity Pattern)
- DR-006 (Two-Phase Hierarchy Sync) — strengthened by this pattern
- Schema v1.8 Appendix B (Fingerprint Patterns — rewritten)
- Helper functions: `generate_ulid()`, `generate_fingerprint_v2()`, per-table display generators

---

### [DR-007] — In-Place GTGT Schema Upgrade (2026-05-08)

**Status:** Locked  
**Bible Reference:** Part 5 (Database Schema Architecture)  
**Schema Reference:** v1.7 → v1.8

**Context:**  
Existing GTGT Supabase project (lffcbeszjqzioobqfdav, ap-northeast-1) contains:
- 13 production tables (brands, entity_graph, page_master, keyword pipeline, logs, etc.)
- 30 tracked migrations (2026-03-10 to 2026-03-23)
- 6 active n8n workflows (Notion ↔ Supabase sync)
- 25K+ keyword analytics rows (active feed: 5K-7K/day from 5 brands)
- 466 entities (287 VTH BioDent + 179 VitalSleep)
- 1,376 planned pages (all VitalSleep)

Bible v3.11 + Schema v1.7 specify ~17 additional tables and require schema changes (sync_state, parent_notion_id, multilingual jsonb, fingerprint normalization).

**Options Considered:**

| Option | Approach | Cost | Risk | Verdict |
|--------|----------|------|------|---------|
| A | New project (clean slate) | $25/mo | 🟢 LOW | ❌ Loses sweat equity |
| B | In-place upgrade GTGT | $0 | 🟡 MED | ✅ Chosen |
| C | 2 environments (GTGT+new) | $25/mo | 🟢 LOW | ❌ Over-engineering |
| D | Branch test first | $10/mo | 🟢 LOW | ⚠️ Optional add-on |
| E | Split DBs (keywords vs core) | $25/mo | 🟡 MED | ❌ Premature optimization |

**Decision:**  
**Option B — In-Place Upgrade** of GTGT to align with Schema v1.8.

**Strategy:**
- ALTER existing tables: add columns (idempotent IF NOT EXISTS)
- CREATE missing v1.8 tables (~17 new tables)
- Add triggers, functions, indexes
- **Data migration is OUT of scope** (existing entity/page data may be discarded — operator confirmed)
- **n8n workflow changes** deferred to later phase (compatibility maintained where possible)

**Rationale:**  
- 30 existing migrations show working in-place evolution discipline
- Solo developer scale (15 brands) doesn't justify multi-project overhead
- Cost-effective ($0 additional infrastructure)
- Existing keyword pipeline preserved without disruption
- Operator explicitly accepted that schema-first work doesn't require data preservation
- Notion FDW + sync infrastructure already in place

**Consequences:**
- ✅ Zero downtime migration possible (all changes additive)
- ✅ Existing n8n workflows continue running
- ✅ 30 historical migrations preserved as baseline
- ✅ No data export/import gymnastics
- ⚠️ Some legacy columns coexist with new pattern (graceful coexistence period)
- ⚠️ Migration must be careful with FK constraints
- ⚠️ Trigger overhead measured before production load

**Out of Scope (Phase 1):**
- Data migration (entity/page rebuild = future project responsibility)
- n8n workflow rewrites (will adapt later if needed)
- Notion database restructure (separate phase)
- WordPress integration (Phase 3+)
- Performance dashboards (Phase 4+)

**References:**
- Schema v1.8 (entire)
- Bible Part 5 (Database Schema Architecture)
- DR-008, DR-009, DR-010 (companion decisions for this upgrade)
- 30 GTGT historical migrations (in `supabase_migrations.schema_migrations`)

---

### [DR-006] — Two-Phase Hierarchy Sync Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Part 18.8  
**Schema Reference:** v1.7

**Context:**  
Hierarchical data (entities with parents, sitemap pages with parent pages, nested clusters) ต้องอยู่ใน 2 ระบบที่มี ID system ต่างกัน:
- **Supabase:** ใช้ text-based references (entity_fingerprint, sitemap_node_id) — portable, human-readable, planning-friendly
- **Notion:** ต้องใช้ native relations (UUID-based) สำหรับ tree UI rendering, rollups, expand/collapse

ที่ planning phase (markdown files), เรายังไม่มี Notion ID เลย — ต้องใช้ text references. แต่ที่ implementation phase, Notion ต้อง native relations เพื่อ render hierarchy บน UI.

**Decision:**  
Two-Phase Sync Pattern — separate columns สำหรับ planning state vs operational state:

**Phase 1 (Planning):** Markdown files use text-based parent references
```yaml
parent_entity_fp: "entity:tmj-disorder"
sync_state: "draft"  # markdown only, not yet in Notion
```

**Phase 2 (Operational):** After Notion sync, both columns coexist:
```yaml
parent_entity_fp: "entity:tmj-disorder"  # preserved for queries
parent_notion_id: "abc-123-def"           # native Notion relation
sync_state: "synced"                       # both representations valid
```

**Schema additions:**
- `parent_notion_id text` — populated after Notion creates parent
- `sync_state text` — values: 'draft', 'syncing', 'synced', 'orphaned'
- `last_sync_at timestamptz` — when last successfully synced
- n8n flow B (resolver) — periodically maps text refs → notion_ids

**Rationale:**  
- ✅ Planning works without Notion (offline, version-controlled markdown)
- ✅ Operational queries can use either text or notion_id reference
- ✅ Sync failures don't block content creation
- ✅ Markdown remains source of truth for structure
- ✅ Notion native relations work for UI rendering

**Consequences:**
- ✅ Hierarchy works in both planning and operational phases
- ✅ Resilient to Notion outages
- ⚠️ Two columns to maintain (sync flow handles)
- ⚠️ Sync state must be monitored (orphans can accumulate)

**References:**
- Bible Part 18.8 — Two-Phase Hierarchy Sync Pattern
- Schema v1.7 — `parent_notion_id` + `sync_state` fields added
- DR-008 (Two-Column Identity) — strengthens this pattern

---

### [DR-005] — GitHub Distribution Strategy (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 10.7  
**Schema Reference:** N/A

**Context:**  
EYWA Protocol ecosystem ต้อง distribute code, specs, per-brand content ในรูปแบบที่:
- ทีม access ได้ (cross-team collaboration)
- Version controlled (history + rollback)
- Permission-managed (private repos for proprietary content)
- Scalable (10+ brands)

**Decision:**  
3-level GitHub structure:

**Level 1 — Organization:** `the-gifted-digital`

**Level 2 — Universal Shared Repos (eywa-* prefix):**
- `eywa-protocol-spec` — Bible, Schema, Handover, DECISION_RECORDS
- `eywa-core` — Foundation plugin
- `eywa-cpt-activation` — CPT registration plugin
- `eywa-acf-fields` — ACF field group JSONs
- `eywa-schema-pipeline` — Schema generator plugin
- `eywa-elementor-templates` — Theme Builder JSON exports
- `eywa-db-migrations` — SQL migration scripts
- `eywa-n8n-flows` — n8n workflow exports
- `eywa-docs` — Public documentation (if needed)

**Level 3 — Per-Brand Repos (eywa-{brand} pattern):**
- `eywa-vth-biodent` — VTH BioDent content + config
- `eywa-vitalsleep` — VitalSleep content + config
- ... (one per brand)

**Visibility:** All repos Private by default.

**Rationale:**  
- Universal code in shared repos = deploy once, all brands benefit
- Brand-specific content separated = privacy + team isolation
- Federation pattern reflected at code level (mirror of database brand_scope concept)
- Easy team permission management (per-repo)
- Scales to 20+ brands without restructuring

**Consequences:**  
- ✅ Clear separation of universal vs brand-specific
- ✅ Permission boundaries match operational boundaries
- ⚠️ Bible/Schema updates require notification to all brand teams
- ⚠️ Cross-repo dependencies must be documented

**References:**  
- Bible Section 10.7 — Federation Pattern
- EYWA_HANDOVER Section 3 — Source of Truth Hierarchy

---

### [DR-004] — URL Structure: Subdirectory + Thai Default (2026-05-07)

**Status:** Locked  
**Bible Reference:** Part 28.2

**Context:**  
EYWA brands serve Thai-first audience (medical/dental clinics in Thailand). Multilingual support needed for:
- Medical tourism (English, Chinese, Japanese, Korean)
- Future expansion (Arabic, French, Spanish)

URL strategy options for multilingual:
- **A. Subdirectory:** `/en/`, `/zh/`, `/`(Thai default)
- **B. Subdomain:** `en.example.com`, `zh.example.com`
- **C. ccTLD:** `.co.th`, `.com`, `.cn`

**Decision:**  
Subdirectory pattern with Thai as default (no prefix), other languages prefixed:
- Default Thai: `https://example.com/services/dental-implants`
- English: `https://example.com/en/services/dental-implants`
- Chinese: `https://example.com/zh/services/dental-implants`

**Rationale:**  
- ✅ Single domain = cumulative SEO authority (vs spreading across subdomains/ccTLDs)
- ✅ Simpler hosting + SSL (one cert, one server config)
- ✅ Easier Google Search Console management (one property)
- ✅ Thai default reflects primary market reality
- ✅ WPML default + recommended pattern
- ✅ Easier hreflang implementation
- ✅ Shared backlink authority across languages

**Alternatives Rejected:**
- **Subdomain:** Splits authority across subdomains, complex hosting, separate GSC properties
- **ccTLD:** Highest cost, complex management, only justified for very large markets

**Consequences:**  
- ✅ Best SEO authority concentration
- ✅ Operationally simple
- ⚠️ Requires hreflang implementation (not optional)
- ⚠️ WPML must be configured correctly per brand

**References:**  
- Bible Part 28.2 — URL Structure for Multilingual
- Bible Section 28.7 — Schema Per Language
- Google: hreflang implementation guidelines
- WPML: subdirectory configuration docs

---

### [DR-003] — Single Entity, Multilingual Labels Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Part 28.3, Schema_Overview v1.6 Section 4.1

**Context:**  
Multilingual entity strategy options:
- **A. One entity per language with sameAs links** (e.g., separate "TMJ Disorder" + "โรค TMJ" + "顳下頜關節紊亂" entities)
- **B. Single entity with multilingual labels jsonb** (one entity, name varies per language)

**Decision:**  
Option B — single entity record per concept, with `canonical_names jsonb` field containing per-language values. Universal entity ID (entity_fingerprint) across all 8 supported languages.

**Schema Implementation:**
```sql
canonical_names jsonb DEFAULT '{}'
-- Structure: {"th": "...", "en": "...", "zh": "...", "ja": "...", ...}
```

**Rationale:**  
- ✅ Knowledge graph stays unified (1 concept = 1 entity)
- ✅ Edges defined once, not duplicated per language
- ✅ Wikidata mapping cleaner (1 Q-ID per entity)
- ✅ Scoring computed at entity level (cross-language signals consolidate)
- ✅ Schema generation simpler (entity → schema in target language)
- ✅ Translation workflow more straightforward

**Alternatives Rejected:**
- **One entity per language:** ❌ Graph fragmentation, edge duplication, unclear authority distribution

**Consequences:**  
- ✅ Simpler graph queries
- ✅ Cleaner schema
- ⚠️ Per-language scoring requires GREATEST() aggregation across languages
- ⚠️ Translation workflow must populate jsonb fields per language
- ⚠️ Missing translations need fallback strategy (default to Thai)

**References:**  
- Bible Part 28.3 — Multilingual Entity Strategy
- Schema_Overview v1.6 Section 4.1 — `canonical_names` field spec
- Wikidata: multilingual label pattern
- DR-009 (Multilingual Strategy v2) — extends this DR with Two-Tier pattern

---

### [DR-002] — Elementor Pro + Hello Theme Stack (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 25.11

**Context:**  
WordPress frontend stack choice for EYWA brand sites. Options:
- **A. Custom Gutenberg blocks** — full programmatic control
- **B. Page Builder (visual)** — designer-friendly
- **C. Hybrid** — combination

**Decision:**  
Hello Elementor theme + Elementor Pro + ACF Pro + RankMath Pro + WPML stack.

Specifically:
- **Hello Elementor** — minimal theme (no built-in styles, fast)
- **Elementor Pro** — Theme Builder + Loop Builder + Dynamic Tags
- **ACF Pro** — custom fields + JSON sync + WPML compat
- **RankMath Pro** — SEO + hreflang + breadcrumbs
- **WPML** — multilingual

**Plugin count reduced:** 5 → 4 EYWA custom plugins (Loop Builder replaces eywa-related-blocks)

**Rationale:**  
- ✅ Designer-friendly (zero-PHP layouts via Elementor UI)
- ✅ Theme Builder = single template per CPT, conditional logic native
- ✅ Loop Builder replaces custom Gutenberg blocks
- ✅ Dynamic Tags pull ACF data automatically
- ✅ Industry-standard, extensive community + docs
- ✅ Reduced custom plugin count = less maintenance
- ✅ Designer can iterate without dev intervention

**Alternatives Rejected:**
- **Pure Gutenberg:** Too programmatic, designers can't iterate
- **Bricks Builder:** Smaller community, fewer integrations
- **Divi:** Bundled theme too opinionated, harder to customize

**Consequences:**  
- ✅ 80% of design work in Elementor UI (designer autonomy)
- ✅ Reduced custom plugin count
- ⚠️ Elementor Pro license cost ($59-399/site/year)
- ⚠️ Hello theme has no built-in schema → EYWA Schema Pipeline plugin handles
- ⚠️ Performance must be monitored (Elementor + WPML can be heavy)

**References:**  
- Bible Section 25.11 — Elementor Pro Integration
- Bible Section 25.8 — Template Hierarchy
- Industry: Hello Elementor + ACF + WPML pattern

---

### [DR-001] — Multi-Brand Federation Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 10.7

**Context:**  
EYWA system needs to support managing 5-20 healthcare/wellness brands. Architectural choice:
- **A. Fully separate per-brand systems** — 1 Supabase + 1 Notion + 1 WP per brand
- **B. Single mega-system** — Everything merged
- **C. Federation pattern** — Shared backend, isolated frontends

**Decision:**  
**Option C — Federation pattern:**

**Shared (Federation Backend):**
- 1 Supabase database (with brand_scope[] column on relevant tables)
- N Notion workspaces (per editorial team)
- 1 n8n instance (for sync orchestration)

**Isolated (Per-Brand Frontend):**
- N WordPress sites (one per brand)
- Each pulls only its brand's data via brand_scope filter
- Independent domains, themes, content

**Rationale:**  
- ✅ Schema upgrade once for all brands (vs N migrations)
- ✅ Citations/entities sharable when relevant (`brand_scope=['*']`)
- ✅ Generic medical entities (TMJ, sleep apnea) defined once
- ✅ Cross-brand visibility for operators
- ✅ Resource sharing (citations researched once benefit all)
- ✅ Brand isolation enforced via `brand_scope` filter
- ✅ Frontend autonomy preserved (per-brand WordPress)
- ✅ Cross-brand referrals = native feature
- ✅ Onboarding new brand = data, not architecture

**Alternatives Rejected:**
- **Full separation:** Schema migrations exponential, citation duplication, no cross-brand visibility
- **Full merger:** Permission nightmare, brand isolation hard, frontend coupling

**Decision Evolution:**
- Original draft included `teams` table — REMOVED (over-engineering)
- Team management via Notion ACL + n8n flow ENV vars (lighter)

**Consequences:**  
- ✅ Efficient cross-brand operations
- ✅ Right-sized for portfolio operators (5-20 brands)
- ⚠️ Notion workspace topology requires manual setup per team
- ⚠️ brand_scope validation must happen in n8n flow config (not DB-level)
- ⚠️ Editorial isolation via Notion permissions (not DB-level RLS)

**References:**  
- Bible Section 10.7 — Operational Multi-Brand Federation Pattern
- Bible Section 4.12 — Cross-Brand External Link Tracking
- Bible Section 18.7 — Multi-Workspace Sync Strategy
- Schema_Overview v1.6 — brand_scope[] field on all relevant tables

---

## Future Decision Topics

Decisions to be documented as they emerge:

- [ ] **DR-015:** WordPress hosting strategy (per-brand or shared?) *(was DR-013 in v1.2)*
- [ ] **DR-016:** Supabase project tier + scaling strategy *(was DR-014 in v1.2)*
- [ ] **DR-017:** n8n hosting strategy (self-hosted vs cloud) *(was DR-015 in v1.2)*
- [ ] **DR-018:** Translation provider selection (Claude vs GPT-4 vs DeepL) *(was DR-016)*
- [ ] **DR-019:** Editorial review workflow tooling *(was DR-017)*
- [x] ~~**DR-020:** CDN strategy~~ + ~~**DR-021:** Image optimization pipeline~~ → **RESOLVED by [DR-035]** (2026-06-04): Cloudflare for Astro brands (R2 + Image Transformations; CF Images optional), WordPress brands unchanged. *(Legacy placeholder topic-numbers from the v1.2 list — the live DR-020 / DR-021 numbers are now held by Content Template Standard / Internal Linking. The topics are captured under DR-035.)*
- [ ] **DR-023:** External Authoritative Link Tracking (extend `to_external_url` usage from seo_page_internal_links) *(claimed 2026-05-11 from DR-021 follow-up)*
- [ ] **DR-026:** Analytics stack (GA4 + custom + ?) *(was DR-024 in v1.8)*
- [ ] **DR-027:** Backup + disaster recovery strategy *(was DR-025 in v1.8)*
- [ ] **DR-028:** Migration repo strategy (separate vs subfolder) *(was DR-026 in v1.8)*
- [ ] **DR-029:** Notion database sync scope (which tables sync) *(was DR-027 in v1.8)*
- [ ] **DR-030:** Branch testing protocol for migrations *(was DR-028 in v1.8)*

> **Note on renumbering (v1.9):** DR-024 (Restore 9 Entity Extension Tables) and DR-025 (Restore Local SEO Tables + Consolidate Branches) became Locked in v1.9. Future placeholders shifted from DR-024..DR-028 to DR-026..DR-030. Future placeholders preserve their previous topic context.

> **Note on renumbering (v1.8):** DR-022 (Lean Phase B + Two-Layer Sitemap + Iterative Refinement) became Proposed in v1.8. Future placeholders shifted from DR-022..DR-026 to DR-024..DR-028 (DR-023 newly claimed for External Link Tracking). Future placeholders preserve their previous topic context.

> **Note on renumbering (v1.3):** DR-013 (Edge Vocabulary v3.5 Expansion) and DR-014 (Concept Entity Subtype Lock) became Proposed decisions in v1.3 (field-tested feedback from VTH BioDent). Future placeholders shifted from DR-013..DR-024 to DR-015..DR-026 to preserve numbering continuity. Future placeholders preserve their previous topic context.

> **Note on renumbering (v1.2 — historical):** DR-011 (Entity Uniqueness Guard) and DR-012 (Edge Vocabulary Evolution Policy) became LOCKED decisions in v1.2. Placeholders shifted from DR-011..DR-022 to DR-013..DR-024 at that time.

---

## Maintenance Rules

```yaml
decision_record_governance:
  
  who_can_add:
    - Operator (final authority)
    - Claude/AI (proposes — operator approves)
    - Tech leads (with operator sign-off)
  
  what_must_be_documented:
    - Architectural choices (database design, framework selection)
    - Strategic patterns (federation, multilingual, sync)
    - Trade-off decisions (cost vs features, speed vs quality)
    - Anything that future developers/AI will ask "WHY did we do it this way?"
  
  what_does_NOT_belong:
    - Implementation details (use code comments)
    - Bug fixes (use commit messages)
    - Daily operational decisions (use issue tracker)
  
  format_discipline:
    - Sequential numbering (never reuse numbers)
    - Append-only (don't delete — supersede instead)
    - Cross-reference Bible sections + related DRs
    - Date stamp every entry
  
  review_cadence:
    - Quarterly: review all DRs for relevance
    - When superseded: mark old DR + reference new DR
    - When implemented: update Status to "Locked"
```

---

## Changelog

### v1.22 (2026-06-08) — DR-037 Locked (Canonicalize `seo_payer_partners` Federation Table) 🔒🏥🧾

Backport of the operator-approved brand-local **DZ-DR-014** (Deezy cashless payer + corporate-welfare directory) into the canonical federation schema. The brand-local table (71 rows, flagged `spec_version='v1.15 (backport pending)'`) is promoted to a shared **Tier-2 Local-SEO table** so every clinic/hospital brand can use it. **In-place ALTER, no data loss.**

- ➕ **DR-037 (NEW, Locked):** `seo_payer_partners` canonical in Group 1 (§3.9). Shape aligned to the **Family-B per-brand-operational pattern** (siblings: branches/reviews/directory_listings/gbp_posts/doctor_assignments): `brand_id text(slug) → uuid NOT NULL FK brands(id)` + DR-008 two-column identity (`payp_{ULID16}` fingerprint + display_name, trigger-set, UNIQUE, no format CHECK). RLS `eywa_authenticated_full_access` unchanged.
- 🗃️ **Schema (BUILT 2026-06-08, migration `eywa_w11_07_dr037_v22_payer_partners_canonical` → Schema v1.22):** Group 1 **8 → 9**; base tables **41 → 42**. 71 Deezy rows migrated (verified: 71 distinct well-formed fingerprints, FK valid, trigger auto-sets on bare insert). `seo_schema_changes` origin row cleared to `'v1.22 (canonical · DR-037)'` + new migration row. Schema_Overview renamed `…v1_21.md → …v1_22.md`.
- 🔧 **Corrected 3 stale/wrong proposal refinements** vs the live schema: (1) **no** `brand_scope[]` — that pattern is for graph entities, per-brand operational tables use `brand_id uuid` FK; (2) **no** format CHECK — Family-B fingerprints are trigger-enforced; (3) section is **§3.9**, not the proposal's §3.8 (taken by `seo_brand_centers` since v1.18).
- 🔒 Companion Bible → **v3.29** (Group 1 8→9). See **DR-037**.
- 📋 **Separate track:** Deezy's 71-row data verification (cashless scope, `needs_review` names, `opd_only`, source/date) remains a Deezy-operator task — this DR locks the **schema**, not the data.

### v1.21 (2026-06-04) — DR-036 Locked (Split `condition` / `symptom` into Separate Tier-1 CPTs) 🔒🧬🩺

Operator review (Deezy planning) reversed the §25.3 `condition`-hosts-both merge: `symptom` is promoted to its **own Tier-1 Core CPT**, realigning the WP implementation (was 1 CPT) with the planning layer (`seo_entity_graph` already types `condition` vs `symptom` separately) and with the split `procedure`/`treatment` sibling pair. **Greenfield, additive, no migration** — no brand past Stage 1, no live condition/symptom pages.

- ➕ **DR-036 (NEW, Locked):** Tier-1 Core 8 → 9 (`…technology · condition · symptom · case_study · post`). Shared `/by-concern/{slug}` base for both CPTs (kit request-filter resolves across post types; EUG/DR-011 guarantees unique slugs). `symptom_of` becomes a cross-CPT edge (vocab unchanged). Schema-type emission keyed off `post_type` (not `entity_subtype`).
- 🗃️ **Schema (BUILT 2026-06-04, migration `eywa_w11_06_dr036_v21_entity_symptom` → Schema v1.21):** new Group-9 extension `seo_entity_symptom` (**29 cols**; 1:1 with `entity_graph type='symptom'`, mirrors `seo_entity_condition` — `entity_fp` FK → `seo_entity_graph.entity_fingerprint`, RLS-enabled). Group 9 10 → 11; base tables 40 → 41. Additive `CREATE TABLE` + RLS policy, no data, no existing table touched.
- 🔧 **Bible v3.25 → v3.26:** §25.2 (8→9 Tier-1 table, max 15), §25.3 (Core CPT 6 `condition` condition-only + new Core CPT 7 `symptom`; `case_study`→8, `post`→9; `condition_vs_symptom_handling` block removed), §25.5 (Group 5 `symptom_meta`; Group 1 `icd_10` visibility + Group 2 `symptoms_of`/`treats_concerns` constraints re-keyed to `post_type`), §25.6 (`tier1_symptom` always-on + `eywa_register_cpt_symptom()`), §25.7 (symptom URL row).
- ⚠️ **`entity_subtype`:** condition/symptom *discriminator* use removed; general-purpose / DR-014 concept-axis field retained.

### v1.20 (2026-06-03) — DR-034 Locked (Intra-Page Answer Routing PAA × FAQ) 🔒🧭

PAA × FAQ overlap raised in operator review before content production. Decision: extend §4.5.3 Cannibalization Shield to within-page scope via new §4.5.4 — understanding-PAA → body, decision-PAA → FAQ, dedup gate, page-level ≥8 intent coverage, tiered FAQ floor (≥3 with PAA / ≥8 without). PAA is subordinate to the locked template (no tail-wagging).

- ➕ **DR-034 (NEW, Locked):** Intra-Page Answer Routing. Filed as a fresh DR (not a DR-020 reopen — DR-020 locked 2026-05-12). Decisions: Q1=B (separate §4.5.4), Q2=B + FAQ safety floor ≥3, Q3=A (generic field naming).
- 🗃️ **Schema (BUILT 2026-06-03, migration `eywa_w11_05` → Schema v1.20):** `seo_website_page_master` gains `intent_source_tier` (text, CHECK paa/derived/template_only, DEFAULT template_only) + `paa_checked_at` (timestamptz). Additive; 1,376 rows default-backfilled; not in fingerprint. File renamed `…v1_19.md` → `…v1_20.md`.
- 🔧 **Reconciled from a stale proposal:** re-anchored v1.11→v1.20, DR-020-pending→DR-034-new; re-mapped phantom columns (`people_also_ask_json`/`paa_ai_content_json`/`related_searches`) to real `paa_questions` + `keyword_painpoint` + `predicted_serp_features` + `seo_x_voice_search`.
- 📌 Content_Templates → v1.8 (§4.5.4 added, B18 tiered floor).

### v1.19 (2026-06-02) — DR-033 Locked (ICD Dual-Coding Standard) 🔒🩺🌐

ICD-10 → ICD-11 transition handling for `MedicalCondition` schema. Operator-triggered (June 2026): keep ICD-10, migrate to ICD-11, or carry both? Decision: **full coverage, ICD-11-MMS primary, ICD-10 retained** — codes are additive in `code[]` with zero downside and serve AI/LLM entity grounding (DR-031), not Google rich results.

**Headline Changes:**

- ➕ **DR-033 (NEW, Locked):** ICD Dual-Coding Standard. `MedicalCondition.code[]` emits **ICD-11-MMS → ICD-10 (WHO base) → ICD-10-CM (US) → SNOMED-CT**. Standardized `codingSystem` strings. `icd_10_code` = WHO base (ICD-10-TM aligned, TH-accurate); new optional `icd_10_cm_code` = US clinical-mod (EN/intl SEO); `icd_11_code` = ICD-11-MMS.
- 🗃️ **Schema (BUILT 2026-06-02, migration `eywa_w11_04` → Schema v1.19):** `seo_entity_condition` gains `icd11_code` (ICD-11-MMS) + `icd10_cm_code` (US ICD-10-CM); `icd10_code` comment clarified (WHO base). Lives on the condition extension (alongside `snomed_ct_id`/`mesh_id`/`umls_cui`), **not** `seo_entity_graph` (which keeps `icd_10_code` as the universal/fingerprint code). **NOT** in the entity fingerprint → no reference cascade. Remaining: WP ACF field `icd_10_cm_code`.
- 🔧 **Spec consistency fixes (this commit):** OSA worked example + skeleton template (table + JSON-LD, ICD-11 lead + base/CM split), PHP schema renderer (reorder + relabel `icd_10_code`→`"ICD-10"` + add `icd_10_cm_code`), entity validation rule, content QA checklist, ACF Schema tab, `never_translate` list, 3 TMJ JSON-LD snippets (`K07.6` WHO / `M26.6` CM / `DA0E.8` ICD-11), Schema_Overview `icd_10_code` semantics note.
- 🩺 **Verified code mappings:** OSA `G47.3`/`G47.33`/`7A41`; TMJ `K07.6`(not in CM)/`M26.6`·`M26.609`/`DA0E.8`.
- 📋 **Out of scope (noted for follow-up):** `code` vs schema.org-canonical `codeValue` property normalization; ICD-11 Foundation URI as `sameAs`.

**Retrofit policy:**
- Existing condition entities — verify `icd_10_code` = WHO base + optional `icd_10_cm_code` backfill at next freshness review (no forced re-code).
- New condition entities — populate ICD-11-MMS + WHO-base ICD-10 from authoring; add US-CM when more granular.

### v1.16 (2026-05-20) — DR-030 Locked (Sensitive Topic Compliance Layer) 🔒⚖️🛡️

First DR triggered by a brand bootstrap (HP100 — post-rehab recovery supplement). Establishes two-dimensional tier matrix (Product Regulatory × Content Topic) at page level + brand-level positioning_mode + PDPA tightening for sensitive testimonials.

**Headline Changes:**

- ➕ **DR-030 (NEW, Locked):** Sensitive Topic Compliance Layer. Two-dim tier matrix (Product T1-T4 × Content T1-T4), `compliance_max_tier` generated column drives reviewer assignment automatically. Brand positioning_mode (A-open-identity / B-dual-layer / B-weighted-recovery / C-implicit / baseline). PDPA workflow tightens for sensitive testimonials (3-state anonymization). Ads gating prevents account bans on uncertified categories.
- 📘 Bible v3.21 → v3.22 — adds Part 32 (10 subsections covering matrix, schema, workflow, positioning, PDPA, Ads, retrofit)
- 📋 EYWA_HANDOVER v1.15 → v1.16 — adds §v1.16 Note documenting DR-030 changes + retrofit policy per brand cohort
- 🏥 First-apply brand: **HP100** (`the-gifted-digital/eywa-hp100`) — Mode A open-identity, Product T2 × Content T3 default. See DR-HP100-001..005 in brand repo
- 🗃️ Schema additions deferred to Wave 11 migration: 6 cols on `seo_website_page_master` + 3 cols on `seo_reviews` + 2 cols on `brands` + `seo_editorial_reviews.review_type` enum extension. Schema_Overview v1.16 unchanged in this DR; Wave 11 migration build will bump to v1.17.
- 📦 Bootstrap Kit extension: `templates/folder-skeleton/docs/brand-intake.xlsx` 81 → 95 questions (Section 13 — 14 new sensitive-audience questions). HP100-specific intake at `brands/eywa-hp100/docs/brand-intake-HP100.xlsx`.

**Retrofit policy:**
- Baseline brands (dental, aesthetics, wellness clinics) — zero-friction, all tiers default to 1
- Healthcare-adjacent supplements/vitamins — operator audit at next Stage gate
- New sensitive brands (HP100+) — mandatory full profile at Pre-Stage 1

**Cross-references:**
- Bible Part 32 — Sensitive Topic Compliance Layer (authoritative)
- Bible Part 30 — BGP (positioning_mode emerges from intake)
- Bible Part 31 — Universal Brand Design System (parallel layer; both retrofit at next Stage gate together)
- DR-019 — Schema Two-Purpose Taxonomy (constrains emittable types per tier)
- DR-021 — Internal Linking Architecture (sensitive pages link restrictions)
- DR-026 — Ads Landing Page Track Phase 0 (intersects with `sensitive_topic_flag` gating)
- DR-028 — Brand Genesis Protocol (intake feeds compliance_profile)
- External: Google YMYL Quality Rater Guidelines + LegitScript Healthcare Certification + Thai PDPA + Thai อย. supplement notification regs

### v1.15 (2026-05-18) — DR-029 Locked (Universal Brand Design System) 🔒🎨

Operator-approved universal scope. Establishes stack-agnostic per-brand design layer with W3C DTCG token format adoption. Ships paired with Bible v3.21 + EYWA_HANDOVER v1.15 + Content_Templates v1.7.

**Headline Changes:**

- ➕ **DR-029 (NEW, Locked):** Universal Brand Design System. `design/` (stack-agnostic specs + DTCG tokens) + `brand-assets/` (raw binary sources) + `theme/` (stack-specific implementation, name preserved per operator pref). 4 DTCG token files (core/semantic/component/brand) + 6 brand-foundation Markdown specs (color/typography/spacing/iconography/imagery/motion).
- 📘 Bible v3.20 → v3.21 — adds Part 31 (9 subsections)
- 📦 Bootstrap Kit additions: `templates/folder-skeleton/design/` + `templates/folder-skeleton/brand-assets/` + brand-intake.xlsx (81 questions baseline)
- 📋 Handover §v1.15 Note added; retrofit at next Stage gate per brand
- 🔄 EYWA marketing self-applies (already partial — DR-029 codifies + extends)

### v1.9 (2026-05-12) — DR-024 + DR-025 Locked (Restore Forgotten Schema) 🔒🧬🏥

Spec catch-up: Bible v3.14 Appendix B.3 (9 entity extension tables) and Appendix B.5 (5 Local SEO tables) silently fell out of Schema_Overview between v1.0 and v1.10 — no DR, no changelog explanation. Operator confirmed forgotten, not deliberate; strategy unchanged. Two paired Locked DRs restore parity; ships paired with Schema v1.11 + Bible v3.15.

**Headline Changes:**

- ➕ **DR-024 (NEW, Locked):** Restore 9 Entity Extension Tables. 6 missing extensions added back to Schema Group 9 (`seo_entity_product`, `seo_entity_condition`, `seo_entity_drug`, `seo_entity_anatomy`, `seo_entity_organization`, `seo_entity_lab_test`). Existing 3 (`ingredients`, `procedures`, `devices`) preserved. `seo_programmatic_templates` reclassified as §11.10 (template registry, not entity extension). Group 9 count: 4 → 10 tables.

- ➕ **DR-025 (NEW, Locked):** Restore Local SEO Tables + Consolidate `seo_locations` → `seo_branches`.
  - 3 new tables: `seo_reviews`, `seo_directory_listings`, `seo_gbp_posts`
  - 1 enhanced: `seo_branches` gains ~15 columns to match Bible Table 24 spec (multi-directory IDs, GBP categories/rating, photos, compliance, staff assignment, special hours, organization entity FK)
  - 1 FK rename: `seo_local_rankings.location_id` → `branch_id`
  - Bible-side rename: all 8 `seo_locations` references in Bible v3.14 → `seo_branches` (Bible bumps v3.14 → v3.15)
  - Group 1 count: 4 → 7 tables

- 🎯 **Why this matters:**
  - T1 medical-condition template (Bible Part 4.1.1) gains its schema binding — was implementable-on-paper but not in DB
  - Clinic vertical Phase 5 (Local SEO + GBP) unblocked — n8n GROUP E flows (E1/E2/E3/E4) become implementable
  - NAP consistency monitoring + PDPA-safe review responses operational at Day 1 (Bible Part 10.5 promise honored)
  - Knowledge graph typed FKs (condition ↔ anatomy ↔ drug ↔ procedure) instead of text matches
  - External org citations gain proper entity store (was conflating with `brands` or generic `entity_graph`)

- 🔄 **Renumbering:**
  - Future placeholders DR-024..DR-028 → DR-026..DR-030 (preserves topic context per maintenance rules)
  - DR-023 (External Authoritative Link Tracking) unchanged — still claimed from 2026-05-11

- 🚧 **Paired releases (same day):**
  - Schema_Overview v1.10 → v1.11 (Group 1 +3 tables, §3.2 enhanced; Group 9 +6 tables; architecture overview 28 → 37 tables)
  - Bible v3.14 → v3.15 (rename `seo_locations` → `seo_branches` × 8 refs; changelog entry only; no structural change)
  - EYWA_HANDOVER v1.8 → v1.9 (spec snapshot reference + Pre-Flight Checklist refresh)

- ✅ **Backward compatible (within EYWA spec stack):**
  - Existing 3 extensions + existing `seo_branches` rows preserved
  - New columns NULL-allowed for backfill
  - Existing brand snapshots (`bible_version: 3.14`, `schema_version: 1.10`) remain valid for their snapshot point; brands refresh at next Stage gate per Handover §9.3

- 📦 **Migration files to author (eywa-supabase-migrations or in-spec subfolder):**
  - `009_enhance_seo_branches.sql`
  - `010_create_seo_reviews.sql`
  - `011_create_seo_directory_listings.sql`
  - `012_create_seo_gbp_posts.sql`
  - `013_rename_local_rankings_fk.sql`
  - `014_restore_entity_product.sql`
  - `015_restore_entity_condition.sql`
  - `016_restore_entity_drug.sql`
  - `017_restore_entity_anatomy.sql`
  - `018_restore_entity_organization.sql`
  - `019_restore_entity_lab_test.sql`

- 🚧 **Pending brand work (post-spec-bump):**
  - All in-flight clinic brands refresh `eywa_spec_snapshot` at next Stage gate (typically Stage 1 → 1.5 transition)
  - Stage 1.5 step 3 (column completion) now includes 3 Local SEO tables + 6 new extension tables for clinics
  - VTH BioDent (Stage 1.5 blocked on DR-021 lock — also note new DR-024/025 to incorporate)
  - SmileScape (Stage 1 Phase E in progress — adopt DR-024/025 at Stage 1 → 1.5 gate)

### v1.8 (2026-05-11) — DR-022 Proposed (Lean Phase B + Two-Layer Sitemap + Iterative Refinement) 🌱

Field-tested workflow proposal from VTH BioDent + SmileScape sessions. Replaces lump Phase B with lean planning loop + async background DFS enrichment + single iterative refinement.

**Headline Changes:**

- ➕ **DR-022 (NEW, Proposed):** Lean Phase B + Two-Layer Sitemap. 7 sub-decisions:
  1. Two-Layer Sitemap (Layer 1 brand-immune / Layer 2 volume-driven / Layer 3 internal linking)
  2. Lean Phase B (single human-blocking phase, not 5 sub-phases — no DFS gate)
  3. Stage 1 Gate adjustment (sitemap structure confirmed without volume data)
  4. Stage 1.5 async enrichment trigger (n8n on `seo_x_ads_keywords_contextual_master` INSERT)
  5. Phase E.refine NEW (post-enrichment iterative refinement with gap-report.md)
  6. Phase F KW context consumption (painpoint/anxiety/insight per page)
  7. Output file restructure (deprecate `research-notes.md`, split into 5 specific files)

- 🎯 **Why this matters:**
  - Phase 1 timeline shortened (no DFS gate blocking entity/sitemap/citation)
  - 30-60% cheaper DFS spend per brand via layered enrichment (cheap full-list volume + expensive shortlist SERP)
  - Brand topical authority preserved (Layer 1 service pages volume-immune)
  - Modern E-E-A-T + AI search era alignment (whole-site context > volume-only selection)
  - Maps to existing 4-table KW infrastructure + n8n flows (no schema migrations)

- 🔄 **Renumbering:**
  - DR-023 newly claimed for External Authoritative Link Tracking (was DR-022 follow-up note in DR-021)
  - Future placeholders DR-022..DR-026 → DR-024..DR-028

- ✅ **Backward compatible:**
  - No schema changes
  - VTH BioDent (Stage 1 done) + SmileScape (Stage 1 Phase E) adopt at next gate
  - 11 empty brand repos use DR-022 from inception

- 🚧 **Pending Bible amendments (post-lock):**
  - Bible §4.14 Page Viability — Layer 1 exemption clause
  - Bible Part 4 — Two-Layer Sitemap pattern documentation

### v1.7 (2026-05-10) — DR-021 Proposed (Internal Linking Architecture HYBRID) 🌱

Triggered by operator review of pre-EYWA Notion DB "Website & SEO Page Intelligent Master" + Stage 1.5 (Handover v1.6) needing internal linking storage. Surfaces a gap in v1.10 (implicit linking only via cluster/entities/sitemap hierarchy — no per-edge fidelity).

- ➕ **DR-021 (NEW, Proposed):** Internal Linking Architecture (HYBRID). 4 sub-decisions: (1) 12 page-level strategy cols added to page_master, (2) new `seo_page_internal_links` junction (~22 cols, per-edge), (3) bidirectional consistency validation (reciprocal detection, anchor diversity, orphan check, depth), (4) cross-brand link governance.
- 📝 **Review cycle:** 4 weeks (until 2026-06-07) — paired with DR-019/020 cycle.
- 📝 **Schema impact:** v1.11 migration — 12 new page_master columns + new `seo_page_internal_links` table. 2 new migrations (009 + 010, Phase 1A.3).
- 📝 **Operator Notion DB precedent:** Page-level fields ported (Authority Weight, Link Equity Score, Anchor Strategy Mode, Cross-Brand governance). Junction adds per-edge fidelity Notion lacked.
- 📝 **Independent of DR-013/014** — different governance scope. Complements DR-019 (schema emission) + DR-020 (content composition) — together form complete content production stack: composition + emission + linking.
- 📝 **Stage 1.5 dependency:** Handover Stage 1.5 step 3 references this for internal linking planning step.

### v1.6 (2026-05-10) — DR-020 Proposed (Universal Content Template Standard) 🌱

Triggered by VTH BioDent /mouth-biomapping/ EEAT audit (visual EEAT good, structured EEAT broken — 6 failures) + Deezy sitemap gap analysis (13 page types, no template framework). Operator field test confirmed need for universal content composition standard across 13 brands × 6 verticals.

- ➕ **DR-020 (NEW, Proposed):** Universal Content Template Standard — 4 sub-decisions: (1) Companion file architecture, (2) 3-layer composition (~25 blocks → 25 templates → customization hooks), (3) EEAT requirement matrix locked per template, (4) Schema enforcement beyond visual.
- 📁 **New companion file:** `Content_Templates_EYWA_v1_0.md` (placed at repo root with DRAFT status in frontmatter, **v1.1 as of 2026-05-10** — bumped from v1.0 same day after operator OSA Master Example integration; 25 templates, ~26 blocks incl. B25a Crisis Disclosure + B26 Predicted Prompts Bank) — formal Bible cross-reference upon DR-020 approval.

- 🆕 **v1.1 additions** (operator-driven from pre-spec OSA Master Example doc):
  - §2.8 Pattern A-E Citable Taxonomy (5 brand-citable patterns including Pattern E Brand Stance — LLMO superweapon)
  - §2.9 Predicted Prompts Bank (off-render planning artifact + 2-table Schema spec for active LLMO measurement)
  - §2.10 Cross-Vertical Adaptability Framework (per-specialty perspective pivot guide)
  - §2.7 B25a Crisis Disclosure Block (acute YMYL emergency triggers)
  - §6.4 Schema Tier Architecture (1/2/3 — site/page/content emission tiers)
  - §4.5 Cross-Cutting Editorial Standards (Quote-Worthy Patterns + Translation Tier Rubric + Cannibalization Shield principle)
  - Quick wins: ≥8 Q&A floor, "🎯 จุดยืนของ {brand}:" Pattern E prefix, Organization member array

- 🔮 **Schema v1.11 deferred additions** (proposed, will lock with DR-020):
  - `seo_predicted_prompts` table (planning artifact)
  - `seo_ai_prompt_test_results` table (API testing execution log)
  - `page_master.translation_tier` column (text — for §4.5.2 enforcement)
- 📝 **Review cycle:** 4 weeks (until 2026-06-07) — paired with DR-019 lock cycle.
- 📝 **No DDL change for v1.0** — existing page_master columns suffice. Future template_id + template_version columns deferred to v1.1.
- 📝 **EEAT phase 2 hard-block targeted 2026-09-01** — prerequisite: ≥80% brand doctor onboarding to seo_authors.
- 📝 **Independent of DR-013/014** — different governance scope (content composition layer vs entity edge vocabulary layer).
- 📝 **Companion to DR-017/018/019** — together form complete content production stack.

### v1.5 (2026-05-10) — DR-019 Proposed (Schema Strategy Post-Rich-Results) 🌱

Triggered by Google announcement 2026-05-07 (FAQ rich results full deprecation effective June 2026, incl. gov/health carve-out) + multi-source verification (12+ industry sources confirm schema role shift from SERP-rendering to AI-extraction).

- ➕ **DR-019 (NEW, Proposed):** Schema Strategy for Post-Rich-Results Era. 4 sub-decisions to lock together: (1) Two-Purpose Taxonomy (serp/ai/forbidden), (2) Featured Snippet capture pattern, (3) KPI replacement (drop FAQ rich result impressions, add ai_citation_rate), (4) AggregateRating tightening (min 5 verifiable reviews).
- 📝 **Review cycle:** 4 weeks (until 2026-06-07) — final lock targeted **after** Google June 2026 effective date for behavioural confirmation.
- 📝 **No DDL change** — spec-level + plugin-level only (`eywa-schema-pipeline` enforces forbidden list).
- 📝 **Independent of DR-013/014** — different governance scope (schema emission layer vs entity edge vocabulary layer).

### v1.4 (2026-05-10) — DR-015..018 Locked (Sitemap Design Quality Gates) 🗺️🔒

Field-tested feedback from VTH BioDent surfaced 4 process gaps in the sitemap design layer (Phase E). All 4 DRs locked together, independent of DR-013/014 governance.

- ➕ **DR-015 (NEW, Locked):** Brand Scope Market Reconciliation Pattern — 3-axis scoring (Necessity / Brand-Fit / SEO Opportunity) for healthcare brands. Adds `marketplace_proposal_status` + `reconciliation_notes` to page_master.
- ➕ **DR-016 (NEW, Locked):** Page Viability Assessment / Thin Page Detection — 4-criteria gate + 5 exception clauses + HARD RULE (L4/L5 pillars never thin). Adds `viability_assessment` jsonb to page_master.
- ➕ **DR-017 (NEW, Locked):** Page Content Brief Field — REQUIRED for collapsed pages, RECOMMENDED otherwise. Adds `content_brief` text to page_master.
- ➕ **DR-018 (NEW, Locked):** Page Content Length Standards — 14 page types × Min/Target/Max word count, multilingual -20%. Spec-level only, no DDL.
- 🔄 Bible v3.13 → v3.14 (Sections 4.13, 4.14, 9.8 + §4.1 Phase 4.5 added)
- 🔄 Schema v1.9 → v1.10 (4 new page_master columns)
- 🔄 New migrations: 007_add_content_brief.sql, 008_add_sitemap_design_columns.sql

### v1.3 (2026-05-09) — DR-013 + DR-014 Proposed (Field-Tested Feedback) 🌱

Companion to ongoing VTH BioDent EGP work. **Tests DR-012 governance for first time** — DR-013 is the inaugural proposed addition under DR-012's 4-criteria + 2-week review process.

- ➕ **DR-013 (NEW, Proposed):** Edge Vocabulary v3.5 Expansion — proposes adding `causes/caused_by` + `contraindicates` edges (10 → 12 vocabulary). Source: Stream B work order from VTH BioDent field work.
- ➕ **DR-014 (NEW, Proposed):** Concept Entity Subtype Lock — proposes controlled vocabulary `framework` + `axis` for `entity_subtype` on `entity_type='concept'`.
- 🔄 **Future placeholder renumbering:** DR-013..DR-024 → DR-015..DR-026 (preserves topic continuity).
- 🎯 **Status:** BOTH DRs Proposed (NOT Locked). Schema Review Board target: 2026-05-15. Lock target: 2026-05-20 (if all 4 DR-012 criteria met).
- ⚠️ **Critical path:** C2 (cross-brand applicability) requires canvass of 14 other brands by 2026-05-13. If only VTH BioDent has cases → DR-013 should reject + use brand_scope workaround.
- 📦 **Future Bible v3.14 + Schema v1.10:** Build only triggers AFTER DR-013/014 lock. v3.13/v1.9 remain canonical until then.
- 🔗 References: Bible v3.13 §2.7.5 (DR-012 governance), Schema v1.9 §4.5 (current edge constraint), Stream B work order.

### v1.2 (2026-05-08) — EUG + Edge Evolution Policy Added 🛡️🔄

- ➕ **DR-011 (NEW):** Entity Uniqueness Guard (Two-Wave) — algorithmic enforcement of "Search Before Create" discipline
- ➕ **DR-012 (NEW):** Edge Vocabulary Evolution Policy — formal addition workflow + parking lot + anti-patterns
- 🔄 Renumbered placeholder DRs: old DR-011..DR-022 → DR-013..DR-024 (preserves topic context)
- 🔗 Cross-references to Bible v3.13 (Sections 2.6.6.1, 2.6.6.2, 2.7.5)
- 🔗 Cross-references to Schema v1.9 (Appendix G — EUG Implementation)

### v1.1 (2026-05-08) — Phase 1 Foundation DRs

- ➕ **DR-007:** In-Place GTGT Schema Upgrade (operational strategy)
- ➕ **DR-008:** Two-Column Identity Pattern (immutable fingerprint + mutable display)
- ➕ **DR-009:** Multilingual Strategy v2 (Two-Tier Pattern — concept vs content)
- ➕ **DR-010:** Brand Scope Architecture (canonical brand_slug)

### v1.0 (2026-05-07) — Initial Release

- ➕ DR-001: Multi-Brand Federation Pattern
- ➕ DR-002: Elementor Pro + Hello Theme Stack
- ➕ DR-003: Single Entity, Multilingual Labels Pattern
- ➕ DR-004: URL Structure (Subdirectory + Thai Default)
- ➕ DR-005: GitHub Distribution Strategy
- ➕ DR-006: Two-Phase Hierarchy Sync Pattern

---

*This document is part of the EYWA Protocol governance suite. For updates, see GitHub: `the-gifted-digital/eywa-protocol-spec/DECISION_RECORDS.md`*
