# 📋 EYWA Protocol — Decision Records

> **Append-only architectural decision log.** Each record explains WHY a decision was made — not just WHAT.

**Document Version:** 1.0  
**Last Updated:** 2026-05-07  
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

### [DR-006] — Two-Phase Hierarchy Sync Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Part 18.8  
**Schema Reference:** v1.7

**Context:**  
Hierarchical data ต้องอยู่ใน 2 ระบบที่มี ID system ต่างกัน:
- **Supabase:** ใช้ text-based references (entity_fingerprint, sitemap_node_id) — portable, human-readable, planning-friendly
- **Notion:** ต้องใช้ native relations (UUID-based) สำหรับ tree UI rendering, rollups, expand/collapse

ที่ planning phase (markdown), เรายังไม่มี Notion ID. แต่ที่ Notion implementation, ต้องใช้ native relations เพื่อ render hierarchy บน UI.

**Decision:**  
Implement **Two-Phase Hierarchy Sync Pattern**:
- **Phase 1 (Flat Load):** Sync เข้า Supabase + Notion ด้วย text-based parent references
- **Phase 2 (Backfill):** หลังทุก row มี notion_id, backfill `parent_notion_id` ใน Supabase + set `parent_relation` บน Notion

**Required Schema Fields (v1.7):**
- `parent_notion_id` (text)
- `sync_state` (text): flat_loaded / notion_synced / relations_backfilled / live

**Applies to:** seo_entity_graph, seo_topic_cluster_master, seo_website_page_master, future hierarchical tables

**Rationale:**  
- ✅ Markdown planning ใช้ human-readable text refs
- ✅ Editors ใน Notion เห็น tree UI (native relations)
- ✅ Pattern industry-standard (PostgreSQL deferred constraints + Notion API)
- ✅ Failure recovery built-in (sync_state)
- ✅ Idempotent (UPSERT-based)

**Alternatives Considered:**
- Skip text parent, only Notion relations: ❌ ไม่สามารถวางแผนใน markdown
- UUID everywhere: ❌ Lose human readability
- Skip Notion: ❌ Lose editorial UI benefits

**Consequences:**  
- ✅ Operators get planning flexibility AND visual hierarchy
- ✅ Reusable pattern across all hierarchical tables
- ⚠️ n8n flows must implement 4-flow architecture
- ⚠️ sync_state lifecycle requires monitoring
- ⚠️ Reconciliation jobs needed for drift detection

**References:**
- Bible Part 18.8 — Two-Phase Hierarchy Sync (full pattern)
- Schema_Overview v1.7 — adds parent_notion_id + sync_state
- EYWA_HANDOVER v1.1 Section 5.8 — explains for brand teams

---

### [DR-005] — GitHub Distribution Strategy (2026-05-07)

**Status:** Locked

**Context:** EYWA ecosystem ต้อง distribute code, specs, per-brand content แบบ versioned + permission-managed + scalable (10+ brands).

**Decision:** 3-level GitHub structure:

**Level 1 — Organization:** `the-gifted-digital`

**Level 2 — Universal Shared (eywa-* prefix):**
- `eywa-protocol-spec` — Bible, Schema, Handover, DR
- `eywa-core` — Foundation plugin
- `eywa-cpt-activation` — CPT registration plugin
- `eywa-acf-fields` — ACF JSONs
- `eywa-schema-pipeline` — Schema generator
- `eywa-elementor-templates` — Theme Builder JSON
- `eywa-db-migrations` — SQL migrations
- `eywa-n8n-flows` — n8n workflows
- `eywa-docs` — Public docs

**Level 3 — Per-Brand (eywa-{brand}):**
- `eywa-vth-biodent`, `eywa-vitalsleep`, etc.

**Visibility:** All Private by default.

**Rationale:**
- Universal code in shared repos = deploy once, all brands benefit
- Brand-specific separated = privacy + team isolation
- Federation reflected at code level
- Easy permission management
- Scales to 20+ brands

**Consequences:**
- ✅ Clear universal vs brand-specific separation
- ⚠️ Bible/Schema updates require notification to all brand teams
- ⚠️ Cross-repo dependencies must be documented

**References:**
- Bible Section 10.7 — Federation Pattern
- EYWA_HANDOVER Section 3 — Source of Truth Hierarchy

---

### [DR-004] — URL Structure: Subdirectory + Thai Default (2026-05-07)

**Status:** Locked  
**Bible Reference:** Part 28.2

**Context:** Multilingual URL strategy for medical tourism brands.

**Decision:** Subdirectory pattern with Thai default:
- Default Thai: `https://example.com/services/dental-implants`
- English: `https://example.com/en/services/dental-implants`
- Chinese: `https://example.com/zh/services/dental-implants`

**Rationale:**
- ✅ Single domain = cumulative SEO authority
- ✅ Simpler hosting (one cert, one config)
- ✅ Easier GSC management
- ✅ Thai default reflects primary market
- ✅ WPML-recommended pattern
- ✅ Easier hreflang implementation

**Alternatives Rejected:**
- Subdomain: Splits authority, complex hosting
- ccTLD: Highest cost, only for very large markets

**Consequences:**
- ✅ Best SEO authority concentration
- ⚠️ Requires hreflang implementation (not optional)
- ⚠️ WPML must be configured correctly per brand

**References:** Bible Part 28.2, Section 28.7

---

### [DR-003] — Single Entity, Multilingual Labels (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Part 28.3, Schema_Overview Section 4.1

**Context:** Multilingual entity strategy — one entity per language vs single entity with jsonb labels.

**Decision:** Single entity record per concept with `canonical_names jsonb` field.

```sql
canonical_names jsonb DEFAULT '{}'
-- {"th": "...", "en": "...", "zh": "...", "ja": "...", ...}
```

**Rationale:**
- ✅ Knowledge graph unified (1 concept = 1 entity)
- ✅ Edges defined once, not duplicated per language
- ✅ Wikidata mapping cleaner (1 Q-ID)
- ✅ Scoring at entity level
- ✅ Schema generation simpler
- ✅ Translation workflow straightforward

**Alternatives Rejected:**
- One entity per language: ❌ Graph fragmentation, edge duplication

**Consequences:**
- ✅ Simpler graph queries
- ⚠️ Per-language scoring requires GREATEST() aggregation
- ⚠️ Translation workflow must populate jsonb
- ⚠️ Missing translations need fallback (default Thai)

**References:** Bible Part 28.3, Schema v1.6 Section 4.1

---

### [DR-002] — Elementor Pro + Hello Theme Stack (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 25.11

**Context:** WordPress frontend stack choice. Custom Gutenberg vs Page Builder vs Hybrid.

**Decision:** Hello Elementor + Elementor Pro + ACF Pro + RankMath Pro + WPML.

**Plugin count reduced:** 5 → 4 EYWA custom plugins (Loop Builder replaces eywa-related-blocks)

**Rationale:**
- ✅ Designer-friendly (zero-PHP layouts)
- ✅ Theme Builder + Loop Builder + Dynamic Tags
- ✅ Industry-standard, extensive community
- ✅ Reduced custom plugin count
- ✅ Designer can iterate without dev intervention

**Alternatives Rejected:**
- Pure Gutenberg: Too programmatic
- Bricks: Smaller community
- Divi: Too opinionated

**Consequences:**
- ✅ 80% design in Elementor UI
- ⚠️ Elementor Pro license cost
- ⚠️ Hello has no built-in schema → EYWA Schema Pipeline handles
- ⚠️ Performance must be monitored

**References:** Bible Section 25.11, 25.8

---

### [DR-001] — Multi-Brand Federation Pattern (2026-05-07)

**Status:** Accepted  
**Bible Reference:** Section 10.7

**Context:** Architectural choice for managing 5-20 brands.

**Decision:** Federation pattern:

**Shared Backend:** 1 Supabase + N Notion workspaces + 1 n8n  
**Isolated Frontends:** N WordPress sites (one per brand, brand_scope filter)

**Rationale:**
- ✅ Schema upgrade once for all brands
- ✅ Citations/entities sharable (`brand_scope=['*']`)
- ✅ Generic medical entities defined once
- ✅ Cross-brand visibility for operators
- ✅ Brand isolation via brand_scope filter
- ✅ Frontend autonomy preserved
- ✅ Cross-brand referrals = native feature
- ✅ New brand onboarding = data, not architecture

**Alternatives Rejected:**
- Full separation: Schema migrations exponential, citation duplication
- Full merger: Permission nightmare, brand isolation hard

**Decision Evolution:**
- Original draft included `teams` table — REMOVED (over-engineering)
- Team management via Notion ACL + n8n flow ENV vars

**Consequences:**
- ✅ Efficient cross-brand operations
- ✅ Right-sized for 5-20 brand portfolios
- ⚠️ Notion workspace topology requires manual setup
- ⚠️ brand_scope validation in n8n flow config (not DB-level)
- ⚠️ Editorial isolation via Notion permissions

**References:** Bible Section 10.7, Section 4.12, Section 18.7, Schema v1.6

---

## Future Decision Topics

- [ ] **DR-007:** WordPress hosting strategy
- [ ] **DR-008:** Supabase project tier + scaling
- [ ] **DR-009:** n8n hosting strategy
- [ ] **DR-010:** Translation provider selection
- [ ] **DR-011:** Editorial review workflow tooling
- [ ] **DR-012:** CDN strategy
- [ ] **DR-013:** Image optimization pipeline
- [ ] **DR-014:** Analytics stack
- [ ] **DR-015:** Backup + disaster recovery

---

## Maintenance Rules

```yaml
who_can_add:
  - Operator (final authority)
  - Claude/AI (proposes — operator approves)
  - Tech leads (with operator sign-off)

what_to_document:
  - Architectural choices
  - Strategic patterns
  - Trade-off decisions
  - Anything answering "WHY did we do this?"

what_NOT_to_document:
  - Implementation details (use code comments)
  - Bug fixes (use commit messages)
  - Daily operational decisions

format:
  - Sequential numbering (never reuse)
  - Append-only (supersede, don't delete)
  - Cross-reference Bible + related DRs
  - Date stamp every entry

review:
  - Quarterly: review all DRs
  - When superseded: mark + reference new
  - When implemented: update Status to "Locked"
```

---

*Part of EYWA Protocol governance suite. GitHub: `the-gifted-digital/eywa-protocol-spec/DECISION_RECORDS.md`*
