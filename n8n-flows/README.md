# n8n Workflow Templates

Reusable n8n workflow JSON templates implementing the EYWA Bible patterns for Notion ↔ Supabase synchronization.

**Spec reference:** Bible §18.7.5 (Brand Scope Validation) + **§18.7.5a Dynamic Token Implementation Pattern** (v3.28) + Part 17 (n8n Flow Library) · **v3.32 multi-workspace fan-out** (DR-038 follow-up)

---

## 📁 Files in this directory

| File | Purpose | Pattern |
|---|---|---|
| `supabase-to-notion__brands.json` 🆕 | Sync new `brands` rows → Notion 🏢 Brand Database (per-workspace property mapping; single-workspace routing) | Phase 1 flat sync · 🆕 **brands-v3.32** |
| `supabase-to-notion__entity-graph.json` | Sync new `seo_entity_graph` rows → Notion 🧬 Entity Graph DB (both workspaces, multi-workspace fan-out) | Phase 1 flat sync (Bible §18.8.2) · 🔄 **v3.32** |
| `notion_db_ids.the_gifted.env.template` | Env vars: data_source_ids (workflow) + database_ids (reference) + tokens + allowed brands + CF registry | — |
| `create_notion_dbs_the_gifted.sh` | Bash script that created the_gifted's 13 N↔S DBs (one-shot, 2026-06-11) | — |
| `notion_dbs_results.json.jsonl` | JSONL log of DB creation results | — |
| `README.md` | This file | — |

### 🔢 Sync order (hierarchy)

```
1. brands             ← run FIRST (master table; no parent dependencies)
2. seo_branches       ← depends on brands.id
3. seo_brand_centers  ← depends on brands.id
4. seo_authors_reviewers
5. seo_doctor_assignments
6. seo_entity_graph   ← depends on brands.brand_slug (Brand Scope relation)
7. ...rest of N↔S tables
```

⚠️ **Run brands sync FIRST** so all child tables can reference brand pages in Notion.

More table-specific flows will be added once this first one is validated in production.

### 🔄 v3.32 update (2026-06-11) — Multi-workspace fan-out

The entity_graph workflow now supports **simultaneous routing to BOTH workspaces** (vt_intelligence + the_gifted_synapse) per row:

- **Routing logic**: SELECT query joins `brands.notion_workspace` per `brand_scope[]` entry; Code node fans out one input row → N output items (one per target workspace).
- **Per-workspace property mapping**: `Brand Scope` is `relation` on vt (deferred to Phase 2 backfill workflow) vs `multi_select` on the_gifted (written immediately as text).
- **Notion API**: bumped to `2025-09-03` (was `2022-06-28`); `parent.type = 'data_source_id'` instead of legacy `database_id`.
- **sync_state**: vt entities land at `notion_synced` (Phase 2 needed); the_gifted entities land at `relations_backfilled` (terminal, no Phase 2).
- **Drift fixes prerequisite**: workflow assumes vt Brand DB `Workspace` select has `the_gifted_synapse` option + vt Entity Graph `Entity Subtype` enum uses `general` (not `health-belief`) + the_gifted Entity Graph has `Supabase Synced At` date + `Notion → Supabase Needs Sync` formula. All 3 applied 2026-06-11 — see DR-038 follow-up notes.

---

## 🚀 Quick Start — Import the entity_graph flow

### 1. Import the workflow into n8n

In n8n UI:

1. Click **Workflows** in left sidebar
2. Click the **⋯** menu (top right) → **Import from file**
3. Select `supabase-to-notion__entity-graph.json`
4. Click **Save** (workflow imported but disabled by default; `active: false`)

### 2. Configure the Supabase credential

The 3 Postgres nodes reference `REPLACE_WITH_SUPABASE_CREDENTIAL_ID`. Replace with your actual credential:

1. Go to **Credentials** → **Add Credential** → **Postgres**
2. Fill in:
   - Host: `db.lffcbeszjqzioobqfdav.supabase.co` (or pooler URL for production)
   - Port: `5432` (or `6543` for transaction pooler)
   - Database: `postgres`
   - User: `postgres` (or your service-role user)
   - Password: your Supabase DB password
   - SSL: `require`
3. Save credential — note the auto-generated credential ID
4. In each of the 3 Postgres nodes, select the new credential from dropdown

### 3. Set environment variables (Pattern A: credential reference)

In n8n: **Settings** → **Environments** (or `.env` file for self-hosted). Source `notion_db_ids.the_gifted.env.template` for the canonical list of env vars (all 14 N↔S DB IDs + ☁️ Cloudflare Accounts + per-workspace allowed brands).

```bash
# ─────────────────────────────────────────────────────────
# Notion integration tokens — one per workspace (v3.32)
# ─────────────────────────────────────────────────────────
NOTION_TOKEN_VT_INTELLIGENCE=ntn_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
NOTION_TOKEN_THE_GIFTED_SYNAPSE=ntn_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

# ─────────────────────────────────────────────────────────
# Notion data source IDs — one per (workspace × table) pair (v3.32 API 2025-09-03)
# ─────────────────────────────────────────────────────────
# Use bare UUID — NOT collection://... prefix
NOTION_DB_ENTITY_GRAPH_VT_INTELLIGENCE=434d8053-62be-4ff1-8d42-f503f2e07741
NOTION_DB_ENTITY_GRAPH_THE_GIFTED_SYNAPSE=37bbe9c6-bf3c-8103-9945-000b1186b63e

# ─────────────────────────────────────────────────────────
# Brand-scope allowlist per workspace (synced from brands.notion_workspace 2026-06-11)
# ─────────────────────────────────────────────────────────
ALLOWED_BRANDS_VT_INTELLIGENCE=the-face-hospital,vth-biodent,bio-dental-wellness,relaxia,tc-smile-dental,genowell,hisher-vitality,vitality-hospital
ALLOWED_BRANDS_THE_GIFTED_SYNAPSE=classy-clinic,deezy-dental

# ─────────────────────────────────────────────────────────
# Workspace role — drives universal-resource permissions
# ─────────────────────────────────────────────────────────
WORKSPACE_ROLE_VT_INTELLIGENCE=operator
WORKSPACE_ROLE_THE_GIFTED_SYNAPSE=operator
```

> **Pattern A note:** Tokens live in n8n env vars (encrypted at rest by n8n). For higher security, see Bible §18.7.5a Pattern C (Supabase Vault) — requires Schema v1.23+.

> **v3.32 tokens reminder:** Rotate the 2 tokens you used during 2026-06-11 setup at https://www.notion.so/profile/integrations before using them in production env vars.

### 4. Set up Notion integration

For **each Notion workspace** that should receive synced data:

1. Go to https://www.notion.so/profile/integrations
2. Create a new **internal integration** (named e.g. "EYWA Sync — VT Intelligence")
3. Copy the **integration token** → paste into corresponding env var (`NOTION_TOKEN_*`)
4. In the target Notion workspace, open each database that should be writable (e.g. 🧬 Entity Graph)
5. Click **⋯** menu → **Connections** → **Connect to** → select the integration
6. Repeat for every database the integration needs to write to

### 5. Test the flow

1. In the workflow editor, click **Execute Workflow** (top right)
2. Inspect output of each node:
   - **Supabase: SELECT pending rows** → should return rows where `notion_id IS NULL`
   - **Code: resolve token + validate + build payload** → check `notion_token` is set, `payload.properties` looks right
   - **HTTP Request** → status 200 + body containing `id` (the new Notion page ID)
   - **Supabase: UPDATE notion_id** → 1 row updated per item
3. Spot-check Notion DB: new pages should appear with correct properties
4. If errors → check **Supabase: log error to dq_metrics** → query: `SELECT * FROM seo_data_quality_metrics WHERE metric_name='notion_sync_error' ORDER BY computed_at DESC LIMIT 10;`

### 6. Activate

When happy:

1. Toggle **Active** switch top-right → ON
2. Workflow now runs every 5 minutes via Cron Trigger
3. Monitor `seo_entity_graph` table: `notion_id` should populate over time

---

## 🧩 The Dynamic Token Pattern (Bible §18.7.5a) — at a glance

```
┌────────────────────────────────────────────────────────────────┐
│  PROBLEM: Native n8n Notion node binds 1 credential per node    │
│   → cannot write to N Notion workspaces from 1 node              │
│                                                                  │
│  SOLUTION: HTTP Request node + dynamic Bearer token              │
│   Authorization: Bearer {{ $json.notion_token }}                 │
│                                                                  │
│   Same node → N workspaces (token differs per item)             │
└────────────────────────────────────────────────────────────────┘
```

### Why HTTP Request beats native Notion node × N

| Criterion | Native Notion × N | HTTP Request + dynamic |
|---|---|---|
| Workflow nodes per workspace | O(N) | **O(1)** |
| Onboard new workspace | duplicate workflow | **add env var row** |
| Credential rotation | N node-config updates | **1 env var update** |
| Audit "who has access to X" | walk n8n UI | **`SELECT * FROM brands`** |

---

## 🗺️ Roadmap — flows to add next

Priority based on N↔S tables that are sync-ready:

| Table | Notion DB | Status |
|---|---|---|
| ✅ `seo_entity_graph` | 🧬 Entity Graph | **THIS FILE** (v3.28 reference) |
| ⏳ `seo_topic_cluster_master` | Topic Cluster Master | clone + adjust property mapping |
| ⏳ `seo_citations` | Citations Pool | clone + adjust property mapping |
| ⏳ `seo_entity_relationships` | Entity Relationships | clone + add cross-CPT edge handling |
| ⏳ `seo_editorial_reviews` | Editorial Reviews | clone + status enum mapping |
| ⏳ `seo_page_internal_links` | Page Internal Links | clone + reciprocal trigger awareness |
| ⏳ `seo_brand_centers` | Brand Centers | clone + DR-032 multi-center routing |
| ⏳ `seo_website_page_master` | 🌐 Website & SEO Page Intelligent Master | clone + the most complex property mapping (84+ cols) |
| ⏳ `seo_branches` | Branches Database | clone |
| ⏳ `seo_authors_reviewers` | Medical Team Database | clone |
| ⏳ `seo_doctor_assignments` | Doctor Assignments Database | clone (just got notion_id col in Wave 11.7) |
| ⏳ `seo_x_ads_keywords_contextual_master` | Keyword Hub | clone (high volume — adjust batch size) |
| ⏳ `brands` | [DB 1.1] Brand Database | clone (lowest-frequency, single-row updates) |

### Phase 2: Reverse direction (Notion → Supabase)

Each of the above tables needs a **mirror flow** triggered by Notion webhook (not Cron). Pattern:

```
Notion webhook → Code: resolve workspace from payload
              → Code: brand-scope validation
              → Postgres: UPSERT seo_*
              → IF success: Postgres UPDATE notion_synced_at
```

Webhook setup requires Notion's webhook subscription API (limited to private integrations) OR polling-based fallback (`/v1/databases/{id}/query` with `last_edited_time` filter every 1-5 min).

### Phase 3: Reconciliation drift repair

Universal job (every 15 min per spec §18.7.3):
1. Query Supabase rows where `notion_synced_at` is stale (>1 hour) AND `notion_id IS NOT NULL`
2. Fetch Notion page state via `/v1/pages/{id}`
3. Compare fields → if drift → write back to Notion (Supabase computed fields) OR Supabase (Notion editorial fields)

---

## 🐛 Troubleshooting

### "Notion API: object_not_found" on page create

The integration is not connected to that database. Fix:
1. Open the Notion DB
2. **⋯** → **Connections** → connect your integration
3. Re-run flow

### "Notion API: validation_error: property does not exist"

The property name in `Code: resolve token + validate + build payload` doesn't match the Notion DB column name (case-sensitive). Fix:
1. Open the Notion DB
2. Compare property name with the code's `properties['<name>']` key
3. Adjust code OR rename Notion property

### "Notion API: rate_limited"

Notion API limit is ~3 req/s. The HTTP Request node config includes `batchSize: 3` + `batchInterval: 1000ms`. If you still hit limits:
1. Reduce batchSize to 2
2. Increase batchInterval to 1500ms

### Empty rows from SELECT

Either:
1. No new entities (all have `notion_id` already) — expected steady-state
2. All rows are missing `brand_scope_id` → the WHERE clause filters them out. Adjust query or backfill `brand_scope_id` via trigger

### Wrong Notion property type (text vs multi_select)

Notion property types are fixed at DB-creation time. If you need to change e.g. `Entity Type` from `multi_select` to `select`:
1. Update the Notion DB schema first (Notion UI or `notion-update-data-source` MCP tool)
2. Then update the property builder in code accordingly

---

## 📚 References

- Bible §18.7.5 — Brand Scope Validation
- Bible §18.7.5a — Dynamic Token Implementation Pattern (v3.28)
- Bible §18.8 — Two-Phase Hierarchy Sync Pattern
- Bible Part 17 — n8n Flow Library
- Bible Part 10.7 — Multi-Brand Federation Pattern
- [Notion API reference](https://developers.notion.com/reference/intro)
- [n8n HTTP Request node docs](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/)
- [Supabase Vault](https://supabase.com/docs/guides/database/vault) — Pattern C token storage

## 🔧 Operational Discovery — Smile-Scape Session 2026-06-07

This pattern was discovered + locked operationally in the eywa-smile-scape brand session on 2026-06-07. Bible v3.28 promotes it from session-only knowledge to canonical spec. Session ID: `local_497ba01a-f6f8-45ff-afb7-2187eb4f81ee`.
