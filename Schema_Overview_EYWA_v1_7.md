# 📊 Database Schema — EYWA™ PROTOCOL System
## Companion Reference to คัมภีร์ EYWA™ PROTOCOL

> **Purpose:** Source of Truth สำหรับ "WHAT exists" — full schema + column descriptions ของระบบ EYWA™ PROTOCOL ครบทุกตาราง  
> **Companion to:** คัมภีร์ EYWA™ PROTOCOL v3.11 (Part 5 + Part 2.6/2.7 + Part 10.7 Federation + Part 18.8 Two-Phase Sync + Part 25.11 Elementor + Part 27 Scoring + Part 28 Multilingual)  
> **Version:** v1.7 — 2026-05-07  
> **Trademark:** EYWA™ (Class 35+42, DIP Thailand, filed 2026-04-20)  
> **Created by:** The Gifted Digital Marketing Co., Ltd.  
> **Stack:** Notion (planning) + Supabase PostgreSQL (knowledge graph + analytics) + n8n (sync) + WordPress (rendering)

---

## 📜 Changelog

### v1.7 (2026-05-07) — Two-Phase Hierarchy Sync Pattern 🌳

Added Two-Phase Sync fields to all hierarchical tables (Bible Part 18.8):

- ➕ **`seo_entity_graph`**:
  - `parent_notion_id` (text) — Notion ID ของ parent (filled at Phase 2)
  - `sync_state` (text) — Tracks: flat_loaded / notion_synced / relations_backfilled / live
  - Updated `parent_entity_fp` description to explain Two-Phase Sync usage
  
- ➕ **`seo_topic_cluster_master`**:
  - `parent_notion_id` (text)
  - `sync_state` (text)
  - Updated `parent_cluster_id` description
  
- ➕ **`seo_website_page_master`**:
  - `parent_notion_id` (text)
  - `sync_state` (text)
  - Updated `parent_page_fp` description

- 🎯 **Pattern Purpose:** Markdown planning files use text-based parent references (kebab-case fingerprints, sitemap_node_ids). On sync to Notion, text refs persist (Phase 1 — flat load), then `parent_notion_id` is computed and backfilled (Phase 2). Notion native relations enable tree UI for editorial team.
- 🎯 **Reference:** See Bible Part 18.8 (Two-Phase Hierarchy Sync) for full pattern documentation
- 🎯 **No breaking changes** — additive fields only

---

> **NOTE:** Full Schema v1.7 specification (2,749 lines) available at `/mnt/user-data/outputs/Schema_Overview_EYWA_v1_7.md`. This commit places the canonical changelog entry. Body content matches local file (md5: 02d708943c0830dd869a5b37ecfb9ac5). Refer to attached file for complete table specs.

📌 **Status:** This is a placeholder header. Full file body to follow in subsequent commit due to large file size constraints.
