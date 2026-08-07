-- =====================================================================
-- 2026-08-04 · Column-semantics lock (DR-047)
-- Tables: seo_website_page_master · seo_entity_graph · seo_topic_cluster_master
--
-- WHY: 156 columns across the 3 core planning tables, of which only 39 carried
-- COMMENT ON COLUMN. Everything else was inferred from the field name at write
-- time, which is how VTH ended up with tier letters in page_type, two parallel
-- cluster vocabularies, and 181 stale topic_cluster_name copies.
--
-- RULE: comments describe LIVE behaviour, not the aspirational spec. Where the
-- Schema_Overview doc and the live CHECK constraint disagree, the constraint
-- wins and the divergence is stated in the comment.
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- 1. seo_website_page_master (91 columns)
-- ─────────────────────────────────────────────────────────────────────

COMMENT ON TABLE seo_website_page_master IS
$$Canonical page master — one row per URL EYWA tracks, planning through live. Shared across brands; scope every query by brand_id. Identity is two-column per DR-008: fingerprint (immutable machine ID) + page_fingerprint (legacy human/n8n key). Cluster/entity/keyword bindings are SOFT FKs — no database-level referential integrity, so orphan pointers are possible and must be checked by gates.$$;

-- Identity
COMMENT ON COLUMN seo_website_page_master.id IS
$$Surrogate PK (uuid, gen_random_uuid). Never referenced by other tables — cross-table joins use fingerprint / page_fingerprint.$$;

COMMENT ON COLUMN seo_website_page_master.page_fingerprint IS
$$LEGACY v1.10 identity, still the join key used by parent_page_fp, seo_page_internal_links, planned_outbound_fps and every brand ETL. Brand-local convention: '{brand_prefix}-{sitemap_node_id}' (VTH: 'vth-5.3.1'). Because it encodes the node number it CHANGES on renumber — renumber is 2-phase (write 'zzz-<new>' first) and must update 4 places: this column, parent_page_fp, internal_links.from_page_fp, internal_links.to_page_fp. Do NOT treat as stable identity; use fingerprint for that.$$;

COMMENT ON COLUMN seo_website_page_master.notion_id IS
$$Notion page UUID for N<->S two-phase sync (DR-006). NULL = never synced to Notion.$$;

-- Brand & taxonomy
COMMENT ON COLUMN seo_website_page_master.brand_id IS
$$Brand slug that OWNS the page (live values: deezy-dental, vth-biodent, smile-scape-clinic). Schema_Overview v1.23 describes this as brands.id UUID-as-text; LIVE DATA IS THE SLUG — slug is authoritative. Every query against this shared table must filter on it.$$;

COMMENT ON COLUMN seo_website_page_master.brand_name IS
$$Denormalized display name of brand_id. Read-only convenience copy — never join on it.$$;

COMMENT ON COLUMN seo_website_page_master.cluster_id IS
$$TOPICAL cluster of the page. Soft FK -> seo_topic_cluster_master.cluster_slug (spec v1.10 name: topical_cluster_id). SAME REGISTRY as seo_entity_graph.topic_cluster_id — one vocabulary, not two. DR-047 precedence: if the page has primary_entity_fp, this MUST equal that entity's topic_cluster_id unless a reason is written in reconciliation_notes; structural pages (home/contact/branch/index) have no entity and set it directly. Only cluster_type='topical' rows belong here. Merging a cluster requires repointing 4 places: this column, entity_graph.topic_cluster_id, entity_graph.topic_cluster_name, and cluster_master.aliases.merged_from.$$;

COMMENT ON COLUMN seo_website_page_master.sitemap_node_id IS
$$Operator-facing hierarchical number ('5.3.1'). NOT the URL (see slug) and NOT guaranteed to encode the real parent — parent_page_fp is the authority for hierarchy. Where the two disagree the page was re-parented without renumbering; that is a known, allowed state only if documented.$$;

COMMENT ON COLUMN seo_website_page_master.sitemap_section IS
$$Top-level section grouping, brand-defined (VTH: '1'..'9'; Deezy: 'home','branches-support','our-uniqueness'...). Drives intent x page-type gates in the brand keyword SOP. Free text — no CHECK.$$;

-- URL & SEO meta
COMMENT ON COLUMN seo_website_page_master.slug IS
$$Page slug / path segment(s). Independent of sitemap_node_id, so a page can be renumbered without a redirect. May contain a path ('pricing/whitening'). Unique per brand by convention, not by constraint.$$;

COMMENT ON COLUMN seo_website_page_master.seo_title IS
$$<title> tag. Planning-stage value is a BASELINE to be revisited against live SERPs at writing time (Keyword SOP L18). Length convention is per-brand — measure existing rows before imposing a limit.$$;

COMMENT ON COLUMN seo_website_page_master.meta_description IS
$$Meta description. For legal_review_required pages, wording is regulated: pricing pages describe cost FACTORS with no figures and no call-to-action (TH Sanatorium Act s.38); drug pages state no efficacy claims (Drug Act s.88).$$;

COMMENT ON COLUMN seo_website_page_master.canonical_url IS
$$Absolute <link rel=canonical> when it differs from the composed brand URL. NULL = self-canonical.$$;

COMMENT ON COLUMN seo_website_page_master.redirect_target IS
$$Where THIS row redirects to. Only meaningful for rows that exist in page_master. Legacy CMS URLs with no row here belong in the edge worker 301 map, NOT this column (VTH 301-map-cutover.md).$$;

-- Naming & display
COMMENT ON COLUMN seo_website_page_master.page_name IS
$$Operator-facing page name. Must be unique across the brand even when slugs differ — duplicates make two pages indistinguishable to reader and crawler.$$;

COMMENT ON COLUMN seo_website_page_master.parent_page_name IS
$$Denormalized page_name of parent_page_fp. Read-only copy; refresh when the parent is renamed.$$;

COMMENT ON COLUMN seo_website_page_master.primary_entity_name IS
$$Denormalized entity_name of primary_entity_fp. Read-only copy — goes stale when the entity is renamed or merged.$$;

-- Page taxonomy
COMMENT ON COLUMN seo_website_page_master.page_intent_type IS
$$Search intent the page serves: informational / commercial / transactional / navigational. Must satisfy the brand intent x section matrix (e.g. Knowledge sections take informational only). Independent axis from page_type and node_tier.$$;

COMMENT ON COLUMN seo_website_page_master.funnel_stage IS
$$Funnel position. TWO VOCABULARIES ARE LIVE and both are in use: awareness/consideration/decision/retention and top/mid/bottom/retention. No CHECK — pick one per brand and stay consistent.$$;

-- Authority & link strategy
COMMENT ON COLUMN seo_website_page_master.priority IS
$$XML sitemap <priority> value as text ('0.4'..'1.0'). Not the same thing as link_priority or authority_weight.$$;

COMMENT ON COLUMN seo_website_page_master.link_role IS
$$Role of the page in the internal link graph. Live values: primary_hub / cluster_spoke / supporting / reference. Consumed by gen-internal-links.$$;

COMMENT ON COLUMN seo_website_page_master.link_priority IS
$$Link weighting bucket 1-10 stored as text. Cannot express a long reading order (VTH tried 1-26) — use group-level priority plus internal_links.section_context / surrounding_text_snippet for intra-group order.$$;

COMMENT ON COLUMN seo_website_page_master.anchor_strategy_mode IS
$$Anchor-text variation policy for inbound links. Live values: branded_navigational / topical_diverse / partial_diverse / generic_mixed.$$;

COMMENT ON COLUMN seo_website_page_master.brand_authority_focus IS
$$DR-021 s6: which brand this page routes authority to in a cross-brand cluster. Holds a brand slug.$$;

COMMENT ON COLUMN seo_website_page_master.is_source_page IS
$$TRUE = this page is the canonical authority hub for its cluster. At most one per cluster per brand.$$;

COMMENT ON COLUMN seo_website_page_master.strategic_page IS
$$Operator flag: page carries business priority beyond its SEO metrics. Excludes it from automatic thin-page/merge sweeps.$$;

-- Cross-brand linking
COMMENT ON COLUMN seo_website_page_master.cross_brand_approved IS
$$DR-021: TRUE = links to another brand in the portfolio are approved for this page. Requires cross_brand_justification.$$;

COMMENT ON COLUMN seo_website_page_master.cross_brand_justification IS
$$DR-021: required prose reason when cross_brand_approved = true. Empty + approved = governance violation.$$;

COMMENT ON COLUMN seo_website_page_master.cross_brand_role IS
$$DR-021: this page role in the cross-brand relationship (source / target / none).$$;

COMMENT ON COLUMN seo_website_page_master.cross_brand_link_type IS
$$DR-021: nature of the cross-brand link (referral / authority / service_handoff). Unused so far — all rows NULL.$$;

COMMENT ON COLUMN seo_website_page_master.cross_brand_links_fps IS
$$text[] of page_fingerprint values in OTHER brands this page links to. Only populate when cross_brand_approved = true.$$;

-- Entity & keyword binding
COMMENT ON COLUMN seo_website_page_master.primary_entity_fp IS
$$Soft FK -> seo_entity_graph.entity_fingerprint. The ONE concept the page is about; drives cluster_id (DR-047), schema.org type, and the R1 relevance tier when assigning keywords. NULL is legitimate ONLY for structural pages (home/hub/index/glossary/contact/branch/local) — content pages with NULL must carry a flag_review, never a silent blank.$$;

COMMENT ON COLUMN seo_website_page_master.related_entities_fps IS
$$text[] of secondary entity fingerprints (spec v1.10 name: secondary_entities_fps). Use for comparison pages: primary_entity_fp = the side that converts, the other side goes here.$$;

COMMENT ON COLUMN seo_website_page_master.target_keyword_fp IS
$$Soft FK -> seo_x_ads_keywords_contextual_master.fingerprint. The single primary keyword this page OWNS brand-wide. One keyword : one page — enforce with a normalised uniqueness gate (lower + strip spaces/hyphens + token-sort); the raw fingerprint does NOT catch spacing variants. A keyword that is primary here must not appear in another page semantic_keywords_fps.$$;

COMMENT ON COLUMN seo_website_page_master.semantic_keywords_fps IS
$$text[] of supporting keyword fingerprints covered in body/H2/FAQ but NOT owned. Caps by page type (pillar 8-15, child 5-10, local 3-6). Same keyword may be semantic on at most 3 pages. Never include this page own target_keyword_fp. Blacklist rules apply here too, not just to the target.$$;

-- Outbound link planning
COMMENT ON COLUMN seo_website_page_master.planned_outbound_fps IS
$$text[] of page_fingerprint values this page is planned to link to internally. Planning intent — the realised graph lives in seo_page_internal_links.$$;

COMMENT ON COLUMN seo_website_page_master.planned_outbound_external_links IS
$$Free-text list of intended external/outbound URLs (authority citations, guidelines). Not a typed array.$$;

-- Schema markup
COMMENT ON COLUMN seo_website_page_master.schema_markup_type IS
$$Schema.org type(s) emitted as JSON-LD. Column TYPE IS text but rows hold both a bare type ('Article') and a brace-set literal ('{MedicalCondition,MedicalWebPage}') — parse defensively. Distinct from page_type: page_type picks the template, this describes the markup.$$;

-- Multilingual
COMMENT ON COLUMN seo_website_page_master.page_language IS
$$ISO language of THIS row (th/en/zh/ar/...). One row per language version; versions are tied together by translations_versions_fps + source_translation_fp.$$;

COMMENT ON COLUMN seo_website_page_master.translation_status IS
$$DR-009 workflow state of this language version: pending / in_progress / approved / live.$$;

COMMENT ON COLUMN seo_website_page_master.translation_due_date IS
$$Target date for translation delivery of this row.$$;

COMMENT ON COLUMN seo_website_page_master.translations_versions_fps IS
$$text[] of page_fingerprints that are other-language versions of this same content. Used to emit hreflang.$$;

COMMENT ON COLUMN seo_website_page_master.source_translation_fp IS
$$page_fingerprint of the source-language row this was translated FROM. NULL = this row is the source.$$;

COMMENT ON COLUMN seo_website_page_master.hreflang_validated IS
$$TRUE = the hreflang cluster for this row was checked to be reciprocal and complete.$$;

COMMENT ON COLUMN seo_website_page_master.wpml_page_id IS
$$Legacy WordPress/WPML post ID for the same page. Migration bookkeeping only.$$;

-- Hierarchy & format
COMMENT ON COLUMN seo_website_page_master.parent_page_fp IS
$$Soft FK -> seo_website_page_master.page_fingerprint. THE AUTHORITY ON HIERARCHY — breadcrumbs, link inheritance and depth all read this, not sitemap_node_id. NULL only for the brand home row. A child whose numeric parent does not exist as a row is a numbering ghost, not a hierarchy error.$$;

COMMENT ON COLUMN seo_website_page_master.content_format IS
$$Content template key. Live values are EYWA T-codes (T1..T19, plus T2b/T6a/T8g variants); legacy prose values ('guide','knowledge') still exist and should be migrated. NOT the aspirational cluster_master content_format facet — that link was never built.$$;

-- Word count / link minimums
COMMENT ON COLUMN seo_website_page_master.auto_suggested_word_count_target IS
$$Suggested word count derived from page_type + template. Guidance for writers, not a gate.$$;

COMMENT ON COLUMN seo_website_page_master.required_min_outbound IS
$$Minimum internal links this page must EMIT before it is considered structurally complete.$$;

COMMENT ON COLUMN seo_website_page_master.required_min_inbound IS
$$Minimum internal links this page must RECEIVE. Zero inbound = orphan; every newly created page must satisfy this before content is written.$$;

-- XML sitemap & robots
COMMENT ON COLUMN seo_website_page_master.in_xml_sitemap IS
$$TRUE = include in sitemap.xml. Must agree with index_directive — noindex + in_xml_sitemap is contradictory.$$;

COMMENT ON COLUMN seo_website_page_master.robots_directive IS
$$Raw <meta robots> string as rendered ('index, follow'). LEGACY/duplicated by index_directive, which is the constrained field. When they disagree, index_directive wins.$$;

-- Editorial
COMMENT ON COLUMN seo_website_page_master.note_brief IS
$$Planning-phase note: why this page exists, traps to avoid, instructions to the writer. Free text, appended chronologically by convention.$$;

COMMENT ON COLUMN seo_website_page_master.suggested_page_content IS
$$Operator-suggested outline / section list for the page. Precedes content_brief in the workflow.$$;

COMMENT ON COLUMN seo_website_page_master.flag_review IS
$$Operator review flag. Live vocabulary: brand-nav (intentional zero-volume brand page), kw-none (no eligible keyword in the pool), kw-nodfs (chosen term has no DFS data), kw-r3 (keyword taken from cluster-level fallback), structural-exempt (no entity by design), entity-mismatch, merged, merged-blend-pending. RULE: a page with no target_keyword_fp must ALWAYS carry a flag — no silent blanks.$$;

COMMENT ON COLUMN seo_website_page_master.snapshot_version IS
$$Planning snapshot the row was produced under, e.g. 'eywa-b3.19-s1.15-t1.5-h1.13-dr1.13' (bible-schema-templates-handover-DR versions). Lets an audit reconstruct which rulebook applied.$$;

-- Status & lifecycle
COMMENT ON COLUMN seo_website_page_master.status IS
$$Page lifecycle. CHECK chk_page_status: Planned | Live | Merged | Dropped (NULL allowed). Schema_Overview v1.23 still lists planning/draft/published — THAT IS STALE, the constraint is authoritative. Merged = folded into another page, keep the row for provenance. Every script that reads this table must exclude Merged and Dropped explicitly; filtering on the string 'deprecated' matches nothing.$$;

COMMENT ON COLUMN seo_website_page_master.published_date IS
$$Timestamp the page went live. Set by the publish/stamp step, not by hand.$$;

COMMENT ON COLUMN seo_website_page_master.has_medical_review IS
$$TRUE = a clinician sign-off exists for this page in seo_editorial_reviews. Publication gate for YMYL pages.$$;

COMMENT ON COLUMN seo_website_page_master.review_cycle IS
$$Re-review cadence: monthly / quarterly / semiannual / annual. Feeds seo_editorial_reviews.next_review_due.$$;

-- Sync & timestamps
COMMENT ON COLUMN seo_website_page_master.notion_synced_at IS
$$Last successful push/pull to the Notion mirror (DR-006 two-phase).$$;

COMMENT ON COLUMN seo_website_page_master.created_at IS
$$Row creation timestamp. Reflects planning-record creation, NOT page publication (see published_date).$$;

COMMENT ON COLUMN seo_website_page_master.updated_at IS
$$Last modification timestamp of this row.$$;

-- ─────────────────────────────────────────────────────────────────────
-- 2. seo_entity_graph (36 columns)
-- ─────────────────────────────────────────────────────────────────────

COMMENT ON TABLE seo_entity_graph IS
$$Universal knowledge-graph node table — one row per real-world concept, SHARED across all brands (DR-042 reuse-first: one concept = one row). Found an existing row? extend aliases, never insert a near-duplicate. Genuinely different granularity? keep both rows and immediately add a typed edge in seo_entity_relationships. Never resolve a duplicate by remapping one brand keywords — that silently breaks cross-brand rollups; merge at the graph.$$;

COMMENT ON COLUMN seo_entity_graph.id IS
$$Surrogate PK (uuid). Not used as a join key — use entity_fingerprint (legacy) or fingerprint (DR-008).$$;

COMMENT ON COLUMN seo_entity_graph.entity_fingerprint IS
$$LEGACY v1.10 identity and STILL the actual join key used by page_master.primary_entity_fp, related_entities_fps, keywords.primary_entity_fp and seo_entity_relationships. Human-readable slug form ('tmj-disorder'). Do not rename casually.$$;

COMMENT ON COLUMN seo_entity_graph.entity_name IS
$$Canonical display name. Before creating a row, search this column AND aliases AND icd_10_code for an existing concept — name-only checks miss '&' vs 'and', word order, and (TH) suffix variants.$$;

COMMENT ON COLUMN seo_entity_graph.entity_slug IS
$$Immutable machine key, UNIQUE table-wide. Changing it re-triggers fingerprint_display_name refresh.$$;

COMMENT ON COLUMN seo_entity_graph.entity_type IS
$$CHECK enum: condition, symptom, treatment, technology, specialty, anatomy, drug, procedure, concept, product, ingredient, device, organization, lab_test. Selects the Group 9 extension table and the schema.org type. Splitting one real concept across two types (e.g. a whitening system as both technology and treatment) creates a duplicate — pick one and relate the other.$$;

COMMENT ON COLUMN seo_entity_graph.entity_subtype IS
$$DR-014: when entity_type='concept' must be framework | axis | general | NULL (CHECK chk_concept_subtype). Free text for other types.$$;

COMMENT ON COLUMN seo_entity_graph.parent_entity_fp IS
$$LEGACY single-parent pointer. Typed hierarchy belongs in seo_entity_relationships (edge_type='child_of' / 'subtype_of'). Kept for backward compat only.$$;

COMMENT ON COLUMN seo_entity_graph.topic_cluster_id IS
$$DENORMALIZED copy of the entity cluster. Soft FK -> seo_topic_cluster_master.cluster_slug — SAME REGISTRY as page_master.cluster_id. Because the column is a single slot on a row shared by every brand, the most recent loader overwrites earlier brands: never point a shared entity at a cluster only one brand uses. DR-047: cluster_master is the source of truth; this is a cached pointer and must be repointed in the same transaction as any cluster merge.$$;

COMMENT ON COLUMN seo_entity_graph.topic_cluster_name IS
$$Denormalized cluster_name for the pointer above. Goes stale silently on rename/merge — as of 2026-08-04, 181 rows disagreed with cluster_master. Never read this for logic; join to cluster_master instead.$$;

COMMENT ON COLUMN seo_entity_graph.schema_org_type IS
$$schema.org class emitted for this entity (MedicalCondition, MedicalTherapy, MedicalProcedure, MedicalDevice, Drug, MedicalSpecialty...). Must be consistent with entity_type.$$;

COMMENT ON COLUMN seo_entity_graph.entity_authority_score IS
$$0-100 evidence/authority rollup (DR-013). Computed — do not hand-edit.$$;

COMMENT ON COLUMN seo_entity_graph.search_volume_total IS
$$Cached sum of monthly volume across keywords whose primary_entity_fp = this entity. Recompute after any keyword remap or entity merge.$$;

COMMENT ON COLUMN seo_entity_graph.brand_scope IS
$$DR-010 text[]. {*} = shared by the whole table; any brand may propose a merge and all brands benefit (DR-046). A specific brand list = private to those brands — other brands MUST NOT attach pages to it.$$;

COMMENT ON COLUMN seo_entity_graph.brand_scope_id IS
$$Denormalized single-brand fast path; NULL when brand_scope holds more than one entry. Maintained by trg_brand_scope_names.$$;

COMMENT ON COLUMN seo_entity_graph.brand_scope_name IS
$$Denormalized brand display name for the single-brand case. Maintained by trigger.$$;

COMMENT ON COLUMN seo_entity_graph.entity_lifecycle IS
$$Demand trajectory: Emerging / Growing / Mature / Declining (plus 'merged' for retired rows). NO CHECK — mixed casing exists live ('emerging' and 'Emerging'); normalise before grouping.$$;

COMMENT ON COLUMN seo_entity_graph.programmatic_eligible IS
$$TRUE = this entity may auto-spawn programmatic pages. Leave FALSE for concepts whose SERP is not owned by clinics.$$;

COMMENT ON COLUMN seo_entity_graph.wikipedia_url IS
$$sameAs trust signal for schema.org. Must resolve to the SAME concept as entity_name.$$;

COMMENT ON COLUMN seo_entity_graph.wikidata_id IS
$$Q-number for Google Knowledge Graph linkage. Strongest duplicate detector available — two rows with the same Q-number are the same concept.$$;

COMMENT ON COLUMN seo_entity_graph.competing_entities IS
$$Free-text notes on competitor-owned entity targets for this concept.$$;

COMMENT ON COLUMN seo_entity_graph.ai_entity_summary IS
$$AI-generated neutral brief used as schema.org description and as writer context. Must be sourced, not invented.$$;

COMMENT ON COLUMN seo_entity_graph.hreflang_group IS
$$Groups language variants of the same entity for multilingual rollups.$$;

COMMENT ON COLUMN seo_entity_graph.aliases IS
$$PLAIN TEXT (not jsonb, despite older docs). Comma/line-separated alternate names, brand names and TH/EN variants. THE duplicate-prevention field: when a near-duplicate is found, extend this instead of inserting a row (DR-042). Merges append the retired name here.$$;

COMMENT ON COLUMN seo_entity_graph.icd_10_code IS
$$WHO base ICD-10 (ICD-10-TM aligned). Emitted in MedicalCondition.code[]. Also a duplicate detector — but shared codes do NOT prove duplication: catch-all codes (K08.89) and legitimately distinct siblings (K07.3 crowding vs diastema) collide. Per DR-033 the fuller coding set lives on seo_entity_condition.$$;

COMMENT ON COLUMN seo_entity_graph.content_gap_flag IS
$$TRUE = the entity has demand/relevance but no canonical page yet. Drives the new-page backlog.$$;

COMMENT ON COLUMN seo_entity_graph.related_entities_fps IS
$$text[] quick-lookup neighbours. Canonical, typed edges live in seo_entity_relationships — this is a cache, keep in sync.$$;

COMMENT ON COLUMN seo_entity_graph.center_scope IS
$$DR-032 text[]: center_slugs within the brand that own/use the entity. Orthogonal to brand_scope. NULL = brand-wide / monolithic brand.$$;

COMMENT ON COLUMN seo_entity_graph.notion_id IS
$$Notion row ID for the Entity Graph mirror.$$;

COMMENT ON COLUMN seo_entity_graph.notion_synced_at IS
$$Last Notion sync timestamp.$$;

COMMENT ON COLUMN seo_entity_graph.last_graph_update IS
$$Last time edges/scores for this entity were recomputed.$$;

COMMENT ON COLUMN seo_entity_graph.created_at IS
$$Row creation timestamp. Oldest row usually indicates the vetted original when resolving duplicates.$$;

COMMENT ON COLUMN seo_entity_graph.updated_at IS
$$Last modification timestamp.$$;

-- ─────────────────────────────────────────────────────────────────────
-- 3. seo_topic_cluster_master (29 columns)
-- ─────────────────────────────────────────────────────────────────────

COMMENT ON TABLE seo_topic_cluster_master IS
$$SKOS-style topic registry shared by every brand. The single vocabulary behind BOTH page_master.cluster_id and entity_graph.topic_cluster_id. Designed for four facets via cluster_type (topical / content_format / audience / section_meta); only the topical facet is populated today. DR-046 governance for brand_scope {*} rows: the survivor of a duplicate is the row from the brand furthest ahead, decided by load_from and NOT by page count; the retired slug is preserved as aliases.merged_from and its row set status='merged', never deleted; ALWAYS inspect the losing row for data the survivor lacks before retiring it.$$;

COMMENT ON COLUMN seo_topic_cluster_master.id IS
$$Surrogate PK (uuid). Join on cluster_slug (from pages/entities) or fingerprint (from parent_cluster_fp).$$;

COMMENT ON COLUMN seo_topic_cluster_master.fingerprint IS
$$DR-008 immutable machine ID, format tcls_{ULID16}. Target of parent_cluster_fp.$$;

COMMENT ON COLUMN seo_topic_cluster_master.fingerprint_display_name IS
$$Mutable label '{fp_last_6}::{cluster_slug}'. Auto-refreshed by trigger.$$;

COMMENT ON COLUMN seo_topic_cluster_master.cluster_slug IS
$$THE key that page_master.cluster_id and entity_graph.topic_cluster_id point at. UNIQUE PER BRAND ONLY — nothing at database level stops two brands from naming one topic differently, which is exactly how parallel vocabularies appeared. kebab-case noun phrase.$$;

COMMENT ON COLUMN seo_topic_cluster_master.cluster_name IS
$$Display name. Identical or word-swapped names across two rows ('Orthodontics & Alignment' twice, 'Prosthetics & Dentures' vs 'Dentures & Prosthetics') are the primary duplicate signal — check before every insert (Bible 7.7.1 Check 1).$$;

COMMENT ON COLUMN seo_topic_cluster_master.cluster_type IS
$$CHECK: topical | content_format | audience | section_meta | campaign | general. TOPICAL means a clinical/subject domain. A row describing urgency, audience or page format is NOT topical and must not be mixed into the topical vocabulary — doing so spawns duplicate condition entities under an urgency label.$$;

COMMENT ON COLUMN seo_topic_cluster_master.cluster_facet IS
$$Sub-facet within cluster_type (CHECK: topical | content_format | audience | section_meta). Empty on all rows today — populate when the multi-facet design is actually built.$$;

COMMENT ON COLUMN seo_topic_cluster_master.parent_cluster_fp IS
$$Self-FK -> fingerprint (CHECK chk_no_self_parent). REQUIRED for any cluster that is not a level-0 pillar (Bible 7.7.1 Check 4). A flat registry is what makes later brands invent sibling clusters instead of reusing a parent.$$;

COMMENT ON COLUMN seo_topic_cluster_master.hierarchy_level IS
$$0 = root, 1 = child, etc. Must equal parent hierarchy_level + 1.$$;

COMMENT ON COLUMN seo_topic_cluster_master.skos_concept_scheme IS
$$SKOS ConceptScheme URI this cluster belongs to.$$;

COMMENT ON COLUMN seo_topic_cluster_master.canonical_names IS
$$jsonb multilingual preferred labels {th, en, ...}. Presence of a filled canonical_names is a strong signal the row is the vetted original.$$;

COMMENT ON COLUMN seo_topic_cluster_master.aliases IS
$$jsonb. Two uses: multilingual alternate labels, and merge provenance {"merged_from": ["<retired-slug>"]} written when another row is folded in (DR-046). Search here before creating a cluster.$$;

COMMENT ON COLUMN seo_topic_cluster_master.descriptions IS
$$jsonb multilingual prose definitions. Frequently the ONLY place a topic definition exists — DR-046 requires checking this on the losing row before a merge (VTH 2026-08-03 nearly destroyed the sole en+th copy).$$;

COMMENT ON COLUMN seo_topic_cluster_master.brand_scope IS
$$DR-010 text[]. {*} = shared by the whole table and subject to DR-046 dedupe; a specific brand list = private, other brands must not attach pages or entities to it.$$;

COMMENT ON COLUMN seo_topic_cluster_master.brand_scope_primary IS
$$Denormalized single owning brand. NOT the dedupe tiebreaker — load_from is (DR-046 point 2).$$;

COMMENT ON COLUMN seo_topic_cluster_master.cluster_health_score IS
$$0-100, cluster_health_formula_v1.0, recomputed nightly. Inputs include entity count, pillar presence and internal edge density.$$;

COMMENT ON COLUMN seo_topic_cluster_master.cluster_topical_authority IS
$$0-100 authority of the brand within this cluster (cluster_topical_authority_formula_v1.0).$$;

COMMENT ON COLUMN seo_topic_cluster_master.cluster_health_breakdown IS
$$jsonb of the factors behind cluster_health_score.$$;

COMMENT ON COLUMN seo_topic_cluster_master.cluster_health_formula_version IS
$$Version tag of the scoring formula used, e.g. 'v1.0'.$$;

COMMENT ON COLUMN seo_topic_cluster_master.cluster_health_computed_at IS
$$Timestamp of the last health computation.$$;

COMMENT ON COLUMN seo_topic_cluster_master.status IS
$$CHECK chk_status: active | deprecated | merged | split. Bible 7.6 also describes a pending_review entry state — IT IS NOT IN THE CONSTRAINT, do not write it. deprecated = stop assigning new content, existing content stays. merged = terminal, folded into another cluster; the row is kept for provenance and no page or entity may point at it.$$;

COMMENT ON COLUMN seo_topic_cluster_master.load_source IS
$$Origin file of the load that created this row, e.g. content-plan/clusters.md (DZ-DR-029).$$;

COMMENT ON COLUMN seo_topic_cluster_master.notion_id IS
$$Notion row ID for the Topic Cluster Master mirror.$$;

COMMENT ON COLUMN seo_topic_cluster_master.parent_notion_id IS
$$Notion row ID of the parent cluster, mirroring parent_cluster_fp.$$;

COMMENT ON COLUMN seo_topic_cluster_master.sync_state IS
$$Two-phase Notion sync state (DR-006). Live rows show 'flat_loaded' = loaded from file, not yet reconciled with Notion.$$;

COMMENT ON COLUMN seo_topic_cluster_master.notion_synced_at IS
$$Last Notion sync timestamp.$$;

COMMENT ON COLUMN seo_topic_cluster_master.created_at IS
$$Row creation timestamp. Combined with load_from, identifies the vetted original in a duplicate pair.$$;

COMMENT ON COLUMN seo_topic_cluster_master.updated_at IS
$$Last modification timestamp.$$;
