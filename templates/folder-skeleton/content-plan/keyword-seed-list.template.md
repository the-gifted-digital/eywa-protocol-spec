# {Brand Display Name} — Phase B Keyword Seed List

> **Stage:** Stage 1 → Phase B (Lean Research, DR-022)
> **Method:** Brand-driven seed dump — NO DFS volume at this stage. Volume + KD + SERP enriched async after Stage 1.5 push.
> **Per feedback_keyword_research.md:** List-first, operator pulls DFS separately when ready.

---

## How to use this file

1. List all keywords organized by **topic cluster** (not by volume — we don't know volume yet)
2. Tag intent type: I = Informational / N = Navigational / C = Commercial / T = Transactional
3. Map each cluster to **sitemap section** anchor (Layer 1 brand-immune vs Layer 2 vol-driven)
4. Brand names appear ONLY in clusters mapped to Section 4 (Tech) + Section 6 (Knowledge) — per universal DR-022 pattern. Section 3 (Services) leads with method (no brand) for topical authority.
5. Volume/KD/CPC columns LEFT EMPTY — operator pulls via DataForSEO MCP later (async background)

---

## Cluster Index

| # | Cluster | Sitemap Anchor | KW Count | Layer |
|---|---------|---------------|----------|-------|
| 1 | {Cluster name — e.g., Hero Service} | {e.g., S3.2 + S5.1 + S6.2} | ~{N} | Layer 1 + Layer 2 |
| 2 | ... | ... | ... | ... |

**Target total: ~300-800 seed keywords** (operator validates volume → narrows to ~200-400 production list)

---

## Cluster 1 — {Hero / Primary Service}

**Sitemap Anchor:** {S3.X + S5.X + S6.X — list which sections this cluster supports}
**Intent dominant:** {C / T / I — what's the dominant intent of this cluster?}

### 1A. Generic Service KW (Informational + Commercial)

```
{seed kw 1}
{seed kw 2}
{seed kw 3}
...
```

### 1B. Specific Sub-types

```
{seed kw with sub-type 1}
{seed kw with sub-type 2}
...
```

### 1C. Process / Procedure

```
...
```

### 1D. Recovery / Aftercare / Follow-up

```
...
```

### 1E. Failure / Complications / Concerns

```
...
```

### 1F. Comparison / Alternatives

```
...
```

### 1G. Eligibility / Special Cases

```
...
```

---

## Cluster 2 — {Secondary Service / Specialty}

**Sitemap Anchor:** {...}

{Repeat structure}

---

## Cluster N — Brand & Local SEO

**Sitemap Anchor:** Homepage + Section 2 + Branch pages
**Intent dominant:** Navigational / Branded

### Brand search

```
{brand name}
{brand name} {modifier}
{brand name} pantip
{brand name} รีวิว
...
```

### Local search — {Branch Area}

```
ทำ{service} {area}
{service} {area}
คลินิก{vertical} {area}
หมอ{vertical} {area}
ทำ{service} {transit reference}
```

### Local search — {Other Branch Area}

{Repeat}

---

## Cluster Final — Geo Modifiers (apply to all service KWs)

```
[service] กรุงเทพ
[service] {area}
[service] ใกล้ฉัน
[service] ใกล้ MRT/BTS
[service] รถไฟฟ้า
[service] ดีที่สุด
[service] ราคาถูก
[service] โปรโมชั่น
[service] ผ่อน
[service] ที่ไหนดี
[service] รีวิว
[service] pantip
[service] อันไหนดี
[service] หมอเก่ง
[service] เฉพาะทาง
[service] ฟรี consult
```

> Apply to all primary KW heads in earlier clusters. Estimated +3-5x volume per cluster head.

---

## Sitemap × Keyword Coverage Audit

Cross-checked Cluster IDs vs sitemap.md sections:

| Sitemap Section | KW Cluster | Coverage Status |
|----------------|-----------|-----------------|
| S1 Homepage | {C# Brand} | {✅ Strong / ⚠️ Thin / ❌ Missing} |
| S2 Uniqueness | {C# Brand} | {...} |
| S3 Services | {C# Hero + Specialties} | {...} |
| S4 Tech | {C# Brand intent} | {...} |
| S5 Concerns | {C# problem-led} | {...} |
| S6 Knowledge | {C# brand intent + deep} | {...} |
| S7 Branches | {C# Local} | {...} |
| S8 Contact | {C# Brand} | {...} |

### Gaps / Flags

🚩 **Gap 1:** {Describe — e.g., "S3.X cluster KW thin — may merge"}

🚩 **Gap 2:** {Describe}

{...}

---

## Operator Action Items

1. **Pull volume/KD/CPC via DataForSEO MCP** (post-Stage 1.5)
2. **Validate brand-search reality** (does brand-led query rank Section 3 pages in SERP?)
3. **Refine sitemap tier distribution** based on volume reality (post-enrichment Phase E.refine)
4. **Trim final list to ~200-400** for production (operator + AI)

---

## Next Phase Triggers

✅ **Phase B output ready** when this file is committed
🔵 **Phase B.2 (Citation Pool)** — can run in parallel
🟡 **Phase C (Entity Genesis)** — entities derivable from this list + brand-concept
🟡 **Phase E (Sitemap structure)** — Layer 1 brand-immune, can proceed without volume
🔴 **Phase D.2 / Phase E.refine** — requires async DFS enrichment (post-Stage 1.5)

---

*Initialized via `templates/folder-skeleton/content-plan/keyword-seed-list.template.md`. Per DR-022 (Proposed) — Lean Phase B no-volume-gate pattern.*
