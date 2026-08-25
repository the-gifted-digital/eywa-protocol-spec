# 🌱 New Brand Bootstrap Checklist

> **Goal:** Spin up a new brand repo from zero to **Phase A ready** in ~15 minutes.
> **Companion to:** `EYWA_HANDOVER.md` §1 Project Setup Checklist + §5.11 Per-Brand Folder Structure.

---

## Flexibility Clause 🌿

This checklist is the **baseline standard**, not a strict cage. Each brand may:

- ✅ **ADD brand-specific files** if they serve real production needs (e.g., `docs/oem-supplier-catalog.md` for a brand that imports devices, or `content-plan/promo-calendar.md` for a brand with seasonal campaigns)
- ✅ **OMIT non-applicable files** (e.g., a single-branch brand may skip `docs/branches.md` and put info inline in brand-concept)
- ✅ **CREATE custom subfolders** under existing folders (e.g., `docs/regulatory/` for a brand under FDA scrutiny)
- ❌ **DO NOT skip the core 4** (they are spec contracts):
  - `brand-config.json` (federation key)
  - `docs/brand-concept.md` (Phase A deliverable)
  - `docs/decision-records.md` (brand-specific DRs per Handover §9.1 Path 1)
  - `docs/changelog.md` (audit trail)

If unsure whether to add or omit, log the decision in `docs/decision-records.md` as a brand-specific DR (e.g., `{BRAND}-DR-001: Skip multilingual/ folder until language expansion approved`).

---

## Pre-Bootstrap

```yaml
prerequisites:
  ☐ Brand identified + brand_id chosen (kebab-case, e.g., "tc-smile", "smile-scape")
  ☐ Brand structure decided 🆕 v1.18 (DR-032): monolithic | multi_center
                    # monolithic = 1 brand = 1 WP site, no center subdivision (90%+ of portfolio)
                    # multi_center = 1 brand = umbrella + N productized centers as URL subdirectories
                    # See Step 1.5 below + EYWA_HANDOVER.md v1.18 Note for decision criteria
  ☐ Repo created on GitHub: github.com/the-gifted-digital/eywa-{brand-id}
  ☐ Local clone exists at /Volumes/SSD NN/CLAUDE AI/repos/brands/eywa-{brand-id}/
  ☐ Operator has access to brand source materials (if any — concept docs, existing site, brand book)
```

---

## Step-by-Step (15 minutes)

### Step 1 — Copy folder skeleton (~1 min)

```bash
cd "/Volumes/SSD NN/CLAUDE AI/repos/brands/eywa-{brand-id}"
cp -r ../../eywa-protocol-spec/templates/folder-skeleton/. .
```

This creates: `docs/` (with signature-programs/), `content-plan/` (with archive/), `content-drafts/{pillar-pages, supporting-pages, citations}/`, `content-published/`, `theme/{brand-assets, custom-css, elementor-templates-overrides}/`, `deployment/acf-overrides/`, `multilingual/`, `reports/`.

**Optional folders to remove if not needed:**
- `multilingual/` — only TH brand → safe to keep empty (no harm)
- `theme/elementor-templates-overrides/` — only if brand will customize global Elementor templates
- `deployment/acf-overrides/` — only if brand needs custom ACF beyond GTGT defaults
- `deployment/cloudflare/r2-media.template.md` 🆕 v1.4 — **Astro / Cloudflare brands only** (DR-040 + DR-035 + DR-038): per-brand R2 bucket `{brand-slug}-media` + object-key/folder naming + delivery. Copy → rename to `r2-media.md` → fill placeholders. **WP brands skip** (WordPress serves its own media).
- `docs/heading-semantics-conformance.template.md` 🆕 v1.5 — **EVERY brand, both stacks** (DR-041 / Bible §9.9): per-brand heading + landmark conformance record. Copy → rename to `heading-semantics-conformance.md` → fill the component→level inventory + per-release verification log + brand-choice deviations. Points at §9.9 (doesn't restate the rules); re-run the checklist each release.

### Step 1.2 — 🔴 เลือก stack ก่อน: WordPress หรือ Astro *(เพิ่ม 2026-08-25)*

`folder-skeleton/` สร้างโครงยุค WordPress ให้ (`theme/`, `deployment/acf-overrides/`)
แต่**ไม่มี `web/` และไม่มีอะไรที่เป็น Astro เลยสักไฟล์** ขณะที่ Step 5.5 สั่ง `cp … web/scripts/`
และ Step 6 รัน `npm run` — ทั้งสองขั้นทำงานใน `web/` ที่ไม่มีขั้นไหนสร้าง

**ทั้งสอง stack ใช้ได้ ต้องเลือกที่ขั้นนี้ และบันทึกไว้ใน `docs/changelog.md`**

| | WordPress | Astro |
|---|---|---|
| `theme/` · `deployment/acf-overrides/` | **เก็บ** | ลบทิ้งได้ |
| `web/` | ไม่ต้องมี | **ต้องสร้าง — ดูด้านล่าง** |
| Step 5.5 / Step 6 | ข้าม (สคริปต์ PAMREL อยู่ใน `web/`) | ทำ |
| เกตร่วมทั้ง 6 | ยังต้องมี — รันจากที่ไหนก็ได้ที่มี `.secrets/supabase.env` | รันจาก `web/` |
| media | WordPress เสิร์ฟเอง — ข้าม `r2-media.template.md` | R2 ต่อ brand · คัด `r2-media.template.md` |

> เกตร่วมทั้งหกอ่านจาก **ฐานข้อมูล** ไม่ได้อ่านจากเว็บ · แบรนด์ WordPress ก็ต้องต่อสายเหมือนกัน
> ต่างแค่ที่วางคำสั่ง (`package.json` ของ `web/` หรือ `Makefile`/สคริปต์ที่ราก)

---

#### ทาง A — WordPress

ไม่ต้องทำอะไรเพิ่มในขั้นนี้ · ข้ามไป Step 1.5 · แต่ **ยังต้องต่อเกตร่วมทั้ง 6 ตัว** ตามที่ Step 5.5
ระบุ (วางไว้ที่ไหนก็ได้ที่รันจากรากของ repo แบรนด์ได้ และมี `.secrets/supabase.env`)

---

#### ทาง B — Astro

**ยังไม่มีแม่แบบ Astro และจงใจไม่ทำ** — `web/` ของจริงคือ 138 ไฟล์ (smile-scape) ถึง 724 ไฟล์
(vth-biodent) แม่แบบตายตัวขนาดนั้นจะเน่าเร็วกว่าที่ใครจะมาอัปเดตทัน · คัดจากแบรนด์ที่ใกล้ที่สุดแทน

```bash
# เลือกต้นแบบตามความใกล้ ไม่ใช่ตามความใหญ่
#   eywa-smile-scape  — 37 component · 2 template · 0 script  · เริ่มจากศูนย์
#   eywa-vth-biodent  — 102 component · 23 template · 22 script · รู้แล้วว่าต้องใช้เยอะ
REF=eywa-smile-scape
rsync -a --exclude node_modules --exclude dist --exclude .astro \
      --exclude 'src/content/*' ../$REF/web/ web/
mkdir -p web/src/content
```

##### 🔴 เช็คเวอร์ชัน Astro ปัจจุบันเสมอ — อย่าเชื่อเลขในเอกสารนี้

```bash
npm view astro version          # เลขจริง ณ วันที่คุณอ่าน
```

> **ตัวเลข ณ 2026-08-25** — แบรนด์ที่มีอยู่ทั้งสามติดตั้ง **7.0.3** จริง · ล่าสุดบน npm **7.2.6**
> · เลขคู่นี้จะล้าสมัยแน่นอน คำสั่งข้างบนคือแหล่งอ้างอิง ไม่ใช่บรรทัดนี้

**กับดัก:** `package.json` ของแบรนด์ต้นแบบเขียน `"astro": "^7.0.3"` และถูกตรึงจริงที่ 7.0.3
ด้วย `package-lock.json` · caret แปลว่า `npm install` ที่ไม่มี lockfile จะได้ **7.x ล่าสุด** ทันที
แบรนด์ใหม่จึงได้ Astro คนละตัวกับแบรนด์ที่มันคัดมา **โดยไม่มีอะไรบอก**

เลือกอย่างจงใจ แล้วบันทึกใน `docs/changelog.md`:

- **ตามต้นแบบ** — คัด `package-lock.json` มาด้วย แล้ว `npm ci` · ปลอดภัยสุด แต่รับ tech debt
  ของต้นแบบมาทั้งก้อน
- **เอาล่าสุด** — ลบ `package-lock.json` แล้ว `npm install` · ต้องรัน **`npm run build` + เกตทั้งชุด
  ให้ผ่านก่อนเขียนหน้าแรก** เพราะ minor ของ Astro เคยเปลี่ยนพฤติกรรม content collection มาแล้ว
  · ถ้าเลือกทางนี้และเขียวหมด **บอกแบรนด์อื่นด้วย** — แปลว่าอัปเกรดได้

##### แล้วเปลี่ยน 6 อย่างนี้ ไม่เปลี่ยนแล้วสคริปต์จะอ่านข้อมูลแบรนด์อื่น

| # | ที่ไหน | เปลี่ยนเป็นอะไร |
|---|---|---|
| 1 | `web/package.json` — ทุกบรรทัด `--brand` | `brand_id` ของแบรนด์ตัวเอง (slug ไม่ใช่ชื่อเต็ม) |
| 2 | `web/src/data/*.json` | ลบทิ้งให้หมด แล้ว `npm run gen:*` ใหม่ — generate จาก DB ของแบรนด์ต้นแบบ |
| 3 | `web/astro.config.*` · `wrangler.*` | domain · CF account · R2 bucket ของแบรนด์ตัวเอง |
| 4 | `web/src/styles/` · design tokens | ของแบรนด์ตัวเอง (`design/tokens/*.json` ใน skeleton คือจุดเริ่ม) |
| 5 | `web/scripts/*.mjs` | ดู Step 5.5 ตาราง 6 ข้อ — `BRAND` · fingerprint prefix · `SITE` · `SKIP` |
| 6 | `web/src/content/` | **ลบเนื้อหาของแบรนด์ต้นแบบให้เกลี้ยง** เก็บไว้แต่ `demo.yaml` ซึ่งเป็น scaffolding ของเทมเพลต |

🔴 **`smile-scape` มี `web/scripts/` เป็น 0 ไฟล์** — คัดจากมันต้องดึงสคริปต์จาก vth เพิ่มตาม Step 5.5
(เป็นส่วนหนึ่งของเหตุที่แบรนด์นั้นยังรันเกตไม่ได้)

---

### Step 1.5 — Decide `brand_structure` 🆕 v1.8 (DR-032 Locked 2026-05-25)

**Every new brand MUST pick one of two structures at bootstrap time.** This decision drives subsequent Steps 2-6 + sitemap design (Phase E) + WordPress permalink architecture.

```yaml
choose_monolithic_if:
  - 1 brand = 1 specialty / 1 audience persona / 1 voice
  - No need to surface internal divisions as URL subdirectories
  - DEFAULT for 90%+ of EYWA portfolio (vth-biodent, smile-scape, the-face-by-vertex, hp100, etc.)
  
  → Continue with Step 2 baseline (no extra folders needed)

choose_multi_center_if:
  - Brand is a HOSPITAL with multiple productized centers under one umbrella
  - "One roof, one record, one team" doctrine (centers share patient record / EHR / MDT)
  - Locked vocabulary across centers (master glossary; no center invents parallel terms)
  - URL pattern requires subdirectories per division (e.g., domain.com/center1/, domain.com/center2/)
  - First adopter: vitality-hospital (7 productized centers under Vitality umbrella)
  
  → Continue with Step 2 + add multi-center additions (see below)
```

**See `EYWA_HANDOVER.md` v1.18 Note + DECISION_RECORDS.md DR-032 for full decision criteria + counter-cases (when NOT to pick multi_center).**

**If multi_center, additional setup required (after Step 4):**

```bash
# Create per-center folder structure
mkdir -p docs/centers
mkdir -p content-plan/sitemap-centers

# For each center, create:
mkdir -p docs/centers/{NN}-{center-slug}
# e.g.,
mkdir -p docs/centers/01-{first-center-slug}
mkdir -p docs/centers/02-{second-center-slug}
# ... one per center

# Create per-center concept doc placeholder per center:
# docs/centers/{NN}-{center-slug}/concept.md
# Create per-center sitemap placeholder per center:
# content-plan/sitemap-centers/{center-slug}.md
```

**Multi-center sitemap split (Phase E):**
- `content-plan/sitemap.md` becomes the **MASTER INDEX** (not a direct page list) — cross-cutting rules, sub-gate strategy, page count summary
- `content-plan/sitemap-hospital-wide.md` — pages with `center_slug=NULL` (umbrella pages: Home, About, Concept hubs, Membership, Outcomes, Press, institutional)
- `content-plan/sitemap-centers/{center-slug}.md` × N — per-center page hierarchies (`center_slug={center}`)
- `content-plan/internal-linking-plan.md` — cross-center funnels (default approved) + cross-brand network links (DR-021 governed)

**Reference implementation:** see `eywa-vitality-hospital/` (7 centers, single WP site, subdirectory pattern).

### Step 2 — Copy + customize brand-config.json (~5 min)

```bash
cp ../../eywa-protocol-spec/templates/brand-config.template.json brand-config.json
```

Then edit `brand-config.json`:

```yaml
required_fields_to_replace:
  ☐ brand_id, brand_name, brand_name_translations.th + en
  ☐ domain
  ☐ vertical_family + healthcare_format + positioning_tier
  ☐ brand_structure 🆕 v1.18 (DR-032) — 'monolithic' (DEFAULT) or 'multi_center' per Step 1.5 decision
  ☐ brand_concept (tagline_th, tagline_en, core_positioning, tone, persona)
  ☐ signature_offerings[] (at least 1 — hero service)
  ☐ specialty_focus[] (at least 1)
  ☐ branches[] (at least 1)
  ☐ schema_org_type
  ☐ engagement.deal_status (LEAD | NEGOTIATING | CLOSED | PAUSED)
  ☐ deployment.current_site_state
  ☐ metadata.created_at + last_updated_at
  ☐ eywa_spec_snapshot.snapshot_taken_at + snapshot_taken_at_stage

if_brand_structure_is_multi_center_also_required:
  ☐ centers[] — at least 1 center; populate per template doc (center_slug, center_name_th/en, url_segment, positioning_one_line, flagship_programs[], anchor_outcome, position_order, status='planning')
  ☐ parent_network (if brand belongs to a network/group like Vertex Hospital) — else leave null
  ☐ deployment.wordpress_pattern = 'single_site_multi_center_subdirectory'

optional_fields_keep_as_TBD_until_known:
  ☐ founders / clinical_team (if brand has dedicated section)
  ☐ founding_year, license_number, primary_address_th, primary_phone
  ☐ social_media URLs
  ☐ team_assignment.notion_workspace_url
```

### Step 3 — Copy + customize README.md (~2 min)

```bash
cp ../../eywa-protocol-spec/templates/README.template.md README.md
```

Edit `README.md` with brand-specific text (positioning, hero service, founders, branches, engagement status). See VTH BioDent or SmileScape README as reference.

### Step 4 — Initialize core docs (~5 min)

```bash
cp ../../eywa-protocol-spec/templates/folder-skeleton/docs/brand-concept.template.md docs/brand-concept.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/docs/decision-records.template.md docs/decision-records.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/docs/changelog.template.md docs/changelog.md
```

Fill `docs/brand-concept.md` skeleton with brand identity (vision, mission, positioning, values, hero service, signature techniques, founders, audience, voice). This is **Phase A output** — required before Phase B can start.

`docs/decision-records.md` starts empty (just header). Brand DRs accumulate as decisions emerge during work (per Handover §9.1 Path 1).

`docs/changelog.md` records this bootstrap as the first entry.

### Step 5 — Optional: copy Phase B planning templates (~2 min)

Only if starting Phase B in same session:

```bash
cp ../../eywa-protocol-spec/templates/folder-skeleton/content-plan/keyword-seed-list.template.md content-plan/keyword-seed-list.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/content-plan/competitor-scan.template.md content-plan/competitor-scan.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/content-plan/citation-pool-seed.template.md content-plan/citation-pool-seed.md
cp ../../eywa-protocol-spec/templates/folder-skeleton/content-plan/patient-journey.template.md content-plan/patient-journey.md
```

These are the 4 Phase B output files per DR-022 (Lean Phase B).

### Step 5.5 — ✍️ PAMREL content-writing setup (~10 min · ทำก่อนเขียนหน้าแรก ไม่ใช่ตอน bootstrap)

> **PAMREL** = ระบบเขียนคอนเทนต์ทั้งชุด (DR-045) · สเปกกลาง: [`Pamrel_Content_Writing_SOP_v1_0.md`](../Pamrel_Content_Writing_SOP_v1_0.md)
> ข้ามได้ตอน bootstrap **แต่ห้ามข้ามก่อนเขียนหน้าแรก** — ทุกขั้นด้านล่างมีหน้าที่ publish ผิดเป็นค่าเสียหายจริงมาแล้ว

ยังไม่มี template ของสองไฟล์นี้ (เนื้อในผูกกับข้อมูลจริงของแบรนด์เกินกว่าจะ generalize) — คัดลอกจาก reference แล้วปรับ:

```bash
cp ../eywa-vth-biodent/docs/CONTENT-WRITING-SOP.md       docs/
cp ../eywa-vth-biodent/docs/template-block-standards.md  docs/
cp ../eywa-vth-biodent/web/scripts/check-keyword-rules.mjs  web/scripts/
cp ../eywa-vth-biodent/web/scripts/page-brief.mjs           web/scripts/
cp ../eywa-vth-biodent/web/scripts/keyword-density.mjs      web/scripts/
cp ../eywa-vth-biodent/web/scripts/stamp-live.mjs           web/scripts/
```

#### 🔴 ปรับ 5 อย่าง — ไม่ปรับแล้วสคริปต์จะโกหกเงียบ ๆ

| # | ปรับอะไร | ทำไม |
|---|---|---|
| 1 | `brand_id` · fingerprint prefix · `ilike('brand', '%X%')` ในทุกสคริปต์ | ไม่ปรับ = อ่านข้อมูลแบรนด์อื่น |
| 2 | **§A ยิงคิวรีใหม่ทั้งหมด** — ห้ามลอกตัวเลข | สภาพข้อมูลแต่ละแบรนด์ไม่เหมือนกัน และตัวเลขเน่าเร็ว (PAMREL P4) |
| 3 | **§B ตรวจ layout ของแบรนด์เองว่า block ไหนไม่ render** | `grep -rl "<Component>" web/src/layouts/templates/` · VTH render `crisis` 2 template · Deezy 3 — **ต่างกันจริง** (P5) |
| 4 | B11 exempt pattern ให้ตรงผัง section ของแบรนด์ | VTH = `^vth-9` · Deezy = `^deezy-(8\|9)\.` เพราะ §2.5 ของ Deezy คือ Medical Team ไม่ใช่ Local |
| 5 | ตัดตัวอย่าง/บทเรียนที่เป็นของแบรนด์อื่นออก | เอกสารที่เล่าเคสของแบรนด์อื่นทำให้คนเขียนเชื่อผิด |
| 6 | `stamp-live.mjs` — `BRAND` · `SITE` (host **production** ไม่ใช่ preview/staging) · `SKIP` (locale ทั้งหมด + route ที่ไม่ใช่แถวใน page_master เช่น `/lp/*` `/preview/*`) | `/lp/dental-implant/` มี slug ท้ายสุดเป็น `dental-implant` ซึ่งเป็นหน้าจริงอีกหน้า — ไม่ SKIP จะเขียนทับ canonical ของหน้านั้น |

#### ✅ รันก่อนเขียนหน้าแรกเสมอ

```bash
cd web
npm run check:keywords                              # exit 1 ถ้ามีหน้าไหน target ชน B-rule
#   key มาจาก .secrets/supabase.env — อย่าพิมพ์ key ลงบรรทัดคำสั่ง มันตกไปอยู่ใน shell history
npm run brief -- <page_fingerprint>                 # ใบสั่งงานของหน้าแรก
```

> **Deezy รัน `check:keywords` ครั้งแรกเจอ 5 หน้าทันที** (3×B11 · 1×B3 · 1×B6) หลังจากที่กฎเหล่านั้นประกาศไว้เฉย ๆ มาหลายเดือน **สมมติว่าแบรนด์ใหม่ก็มี** จนกว่าเกตจะบอกว่าไม่มี

#### เพิ่มใน `web/package.json`

```json
"brief":          "node --env-file-if-exists=../.secrets/supabase.env scripts/page-brief.mjs",
"check:keywords": "node --env-file-if-exists=../.secrets/supabase.env scripts/check-keyword-rules.mjs",
"check:density":  "node scripts/keyword-density.mjs",
"stamp:live":     "node --env-file-if-exists=../.secrets/supabase.env scripts/stamp-live.mjs"
```

#### 🔴 แล้วเกตร่วมอีกหกตัว — ข้อนี้เคยหายไปจากคู่มือนี้ *(เพิ่ม 2026-08-24)*

สี่บรรทัดข้างบนเป็นเกตของแบรนด์เอง · **เกตที่ทุกแบรนด์ต้องรันชุดเดียวกัน**อยู่คนละที่ และคู่มือฉบับก่อน
ไม่ได้พูดถึงเลยสักตัว แบรนด์ที่ทำตามจนจบจึงได้ repo ที่ไม่มีเกต citation อยู่เลย

```json
"check:citations":          "python3 ../../../eywa-protocol-spec/scripts/citation-gates/run-citation-qa-gates.py --brand <brand_id>",
"check:citation-usage":     "python3 ../../../eywa-protocol-spec/scripts/citation-gates/verify-page-citation-usage.py --brand <brand_id>",
"check:content-citations":  "python3 ../../../eywa-protocol-spec/scripts/citation-gates/audit-content-locators.py --root src/content --brand <brand_id>",
"check:anchors":            "python3 ../../../eywa-protocol-spec/scripts/citation-gates/audit-anchor-text.py --brand <brand_id>",
"check:template-registry":  "python3 ../../../eywa-protocol-spec/scripts/citation-gates/check-template-registry.py --brand <brand_id>",
"check:keyword-collisions": "python3 ../../../eywa-protocol-spec/scripts/citation-gates/check-keyword-collisions.py --brand <brand_id>",
"gates:verify":             "cd ../../../eywa-protocol-spec/scripts/citation-gates && shasum -a 256 -c MANIFEST.sha256"
```

- **`<brand_id>` คือ slug** (`vth-biodent`) ไม่ใช่ชื่อเต็ม (`VTH BioDent`)
- **ห้ามคัดลอกสคริปต์เข้า repo ของแบรนด์** — สำเนาที่แยกไปจะ drift เงียบ ๆ ซึ่งเป็นเหตุที่
  ไดเรกทอรีนั้นมี `MANIFEST.sha256` และ `gates:verify`
- ต้องมี **`.secrets/supabase.env`** ที่มี `SUPABASE_SERVICE_KEY=` ไม่งั้นรันไม่ได้สักตัว ·
  ไฟล์นี้ gitignore ไว้ **ห้าม commit ห้ามคัดลอกข้ามแบรนด์** (smile-scape-clinic มีแต่ `README.md`
  ในโฟลเดอร์นั้น จึงยังรันเกตไม่ได้เลยจนถึงวันนี้)

#### `content-plan/template-registry.json` — ต้องมีก่อน `check:template-registry` จะทำงาน

นิยาม `content_format` ของแบรนด์ตัวเอง · **โค้ดเป็นสตริงอะไรก็ได้** (DR-057) ไม่ต้องขึ้นต้นด้วย `T`
ไม่ต้องเท่ากับแบรนด์อื่น — ของจริงตอนนี้ vth-biodent 9 โค้ด · smile-scape 13 · deezy 21 รวม
`T2b`/`T6a`/`T8g`/`T12i` ที่ไม่มีใครอื่นใช้ · **ที่ห้ามคือโค้ดที่ไม่มีนิยาม**

คัดแบบจาก `eywa-protocol-spec/scripts/citation-gates/template-registry.example.json`

#### 🔴 ต่อ `stamp-live` เข้า CI — ไม่ใช่ให้คนรันมือ

```yaml
      # หลังขั้น deploy เท่านั้น — รันกับสิ่งที่ ship จริง ไม่รันเมื่อ build ล้ม
      - name: Stamp shipped pages Live in page_master
        run: node scripts/stamp-live.mjs
        env:
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
```

ตรวจก่อนรันจริงครั้งแรก: `STAMP_LIVE_DRY=1 npm run stamp:live` พิมพ์ slug → canonical โดยไม่เขียนอะไร

> **ไม่มีตัวนี้ = หน้าที่ live แล้วจะค้าง `status=Planned` ตลอดไป** VTH มี 17 หน้าอยู่บน production สองวันโดยแผนยังบอกว่ายังไม่ได้ทำ จับได้เพราะ operator สังเกตเอง (PAMREL P13)

#### ⚠️ ห้ามลอกข้ามแบรนด์

ตัวเลขสภาพข้อมูล (§A) · block ที่ไม่ render (§B) · **นโยบาย medical review** (`byline.reviewedDate` / auto sign-off เป็นการตัดสินใจของเจ้าของแบรนด์แต่ละราย) · รายชื่อคู่แข่งใน blacklist

---

### Step 6 — First commit (~1 min)

```bash
git add .
git commit -m "Brand bootstrap: eywa-{brand-id}

Folder skeleton + brand-config + core docs initialized from
templates/ baseline. Phase A brand-concept.md ready for editing.

Spec snapshot pinned: Bible v3.34 / Schema v1.23 / Templates v1.9
                      / Handover v1.19 / DR v1.31

Per Handover §9.3 — eywa_spec_snapshot block records this entry point.
Per DR-022 (Locked) — Lean Phase B workflow adopted from inception."

git push -u origin main
```

---

## Post-Bootstrap Verification

```yaml
sanity_checks_after_step_6:
  ☐ brand-config.json valid JSON (no trailing commas, no syntax errors)
  ☐ brand_id matches folder name + git remote
  ☐ docs/brand-concept.md has at least sections 1-3 filled (vision, mission, positioning)
  ☐ docs/changelog.md has bootstrap entry
  ☐ git push successful (visible on github.com/the-gifted-digital/eywa-{brand-id})
  ☐ eywa_spec_snapshot block has all 5 versions + snapshot_taken_at populated
  ☐ Memory updated: ~/.claude/projects/-Users-nn-CLAUDE-AI/memory/project_{brand}.md created (or noted in MEMORY.md)

before_writing_the_first_page:   # ✍️ PAMREL — Step 5.5
  ☐ docs/CONTENT-WRITING-SOP.md + docs/template-block-standards.md คัดลอกและปรับแล้ว (5 ข้อใน Step 5.5)
  ☐ §A ยิงคิวรีใหม่ ไม่ใช่ลอกตัวเลขจาก reference
  ☐ §B ตรวจ layout ของแบรนด์เองแล้วว่า block ไหนไม่ render
  ☐ npm run check:keywords รันแล้ว — ต้องเขียว หรือมี veto ที่ operator อนุมัติแล้ว
  ☐ npm run brief -- <fp> พ่นใบสั่งงานได้จริง

after_first_deploy:
  ☐ stamp-live ต่อเข้า CI หลังขั้น deploy แล้ว
  ☐ STAMP_LIVE_DRY=1 รันแล้วดู slug → canonical ว่าถูกต้อง ก่อนปล่อยให้เขียนจริง
  ☐ page_master มีแถว status=Live เท่ากับจำนวนหน้าที่ ship จริง
```

---

## Common Pitfalls

| Pitfall | How to Avoid |
|---------|-------------|
| Skip brand-config and start writing content immediately | brand-config is federation contract — empty/wrong = downstream syncs break. Spend the 5 min. |
| Copy SmileScape's brand-config wholesale | Has SmileScape-specific blocks (SMILE DNA, Founders, Implant Brand Strategy) that don't apply to other brands. Use the **template**, not another brand's config. |
| Set deal_status="CLOSED" prematurely | Only set CLOSED when contract signed. Use LEAD/NEGOTIATING during sales pipeline. |
| Pin old spec versions in eywa_spec_snapshot | Always pin **current** versions at bootstrap time. Re-snapshot at each Stage gate, not retroactively. |
| ข้ามการปรับ brand filter ในสคริปต์ PAMREL | สคริปต์จะอ่านข้อมูลแบรนด์อื่นและรายงานว่า "ผ่าน" — โกหกเงียบ ๆ ไม่ error ตรวจด้วยการดูจำนวนหน้าที่ audit ว่าตรงกับแบรนด์ตัวเอง |
| ลอก §A/§B จาก reference โดยไม่ยิงคิวรี/ไม่ตรวจ layout | Deezy เคยเขียนผิดเรื่องโค้ดของ Deezy เอง (`Procedure.astro` render `crisis` แต่เอกสารบอกว่าไม่) นานหลายเดือน |
| ปล่อยให้ `stamp-live` เป็นงานมือ | ไม่มีใครจำได้ทุกครั้ง — หน้าจะ live แต่แผนบอกว่ายังไม่ได้ทำ และไม่มีอะไรฟ้อง |
| ตั้ง `SITE` เป็น host ของ preview/staging | canonical ใน DB จะไม่ตรงกับที่ HTML ประกาศ · staging เป็นการจัดการรอบปล่อย ไม่ใช่ตัวตนของหน้า |
| เขียนหน้าแรกก่อนรัน `check:keywords` | กฎที่ประกาศไว้ไม่ทำงานจนกว่าจะมีตัวบังคับ — Deezy เจอ 5 หน้าในการรันครั้งแรก |
| Treat templates as immutable | Templates are baselines. If a brand needs a new field that 80% of brands would need, propose an update to `templates/brand-config.template.json` via DR. If only this brand needs it, add inline + log in brand DR. |

---

## Reference Examples

- **Full bootstrap (~13 sections, mature):** `eywa-vth-biodent/` — Stage 1 done, Phase 4.5 retrofit pending
- **PAMREL reference implementation:** `eywa-vth-biodent/docs/` + `eywa-vth-biodent/web/scripts/` — 16 หน้า / 4 รอบพิสูจน์ (DR-045)
- **Fresh bootstrap (recent):** `eywa-smile-scape/` — Stage 1 Phase E, DR-022 field test
- **Folder structure spec:** Handover §5.11
- **Spec snapshot semantics:** Handover §9.3
- **DR lifecycle:** Handover §9.1 (brand-specific Path 1 vs system-wide Path 2)

---

## When to Update This Template

If you find yourself doing the SAME manual fix on multiple brands during bootstrap, that's a signal to update the template. Open a DR proposal:

```
Title: Bootstrap Template Update — {what changed}
Status: Proposed
Rationale: Observed in 3+ brand bootstraps (list them) — repetition cost > template change cost
```

---

*Last updated: 2026-07-31 (templates v1.2 — Step 5.5 PAMREL setup + stamp-live wiring per DR-045 / PAMREL P13)*
