-- =====================================================================
-- 2026-10-21 · DR-078 · Page change history (live-crawl SEO change log)
-- Proposal: proposals/2026-10-21-page-change-history.md (§4.1, §4.3, §4.4)
--
-- New objects only. Nothing existing is altered; no trigger on page_master.
--   function  seo_norm_url(text)
--   tables    seo_page_live_state · seo_page_change_log (append-only) · seo_page_change_note
--   views     v_page_change_events · v_page_change_impact · v_page_field_history
--
-- Idempotent: safe to run more than once.
-- Self-test:  migrations/tests/2026-10-21_w12_01_page_change_history.test.sql
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- 1. URL normalisation (mirrored in JS; shared cases in
--    scripts/page-history/fixtures/url-cases.json)
--    lowercase scheme + host, drop leading www., drop query + fragment,
--    drop one trailing '/' unless the path is just '/' (an empty path
--    becomes '/'). Then the PATH is percent-encoded canonically: every
--    non-ASCII character becomes its UTF-8 bytes as %XX (uppercase hex)
--    and every existing %xx escape gets uppercase hex. ASCII characters
--    and escapes are otherwise untouched (%2F stays, spaces stay). So a
--    decoded Thai path (page_master) and its %-encoded form (GSC) match.
--    Nothing is decoded. Non-URL input is returned as is.
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION seo_norm_url(u text) RETURNS text
LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
  SELECT CASE WHEN u !~ '^[A-Za-z][A-Za-z0-9+.-]*://' THEN u ELSE
           regexp_replace(lower(substring(u FROM '^([A-Za-z][A-Za-z0-9+.-]*://[^/?#]*)')), '^([a-z][a-z0-9+.-]*://)www\.', '\1')
           || coalesce(nullif((
                SELECT string_agg(CASE WHEN length(m.t[1]) = 3 THEN upper(m.t[1])          -- existing %xx escape
                                       WHEN ascii(m.t[1]) < 128 THEN m.t[1]                -- ASCII as is
                                       ELSE upper(regexp_replace(encode(convert_to(m.t[1], 'UTF8'), 'hex'), '(..)', '%\1', 'g'))
                                  END, '' ORDER BY m.n)
                  FROM regexp_matches(regexp_replace(substring(u FROM '^[A-Za-z][A-Za-z0-9+.-]*://[^/?#]*([^?#]*)'), '/$', ''),
                                      '%[0-9A-Fa-f]{2}|.', 'g') WITH ORDINALITY AS m(t, n)
              ), ''), '/')
         END
$$;

-- ─────────────────────────────────────────────────────────────────────
-- 2. Tables
-- ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS seo_page_live_state (
  page_fp              text PRIMARY KEY,   -- FK (ON DELETE CASCADE) added below, re-run safe
  brand_id             text NOT NULL,
  url                  text NOT NULL,
  http_status          int,
  final_url            text,
  title                text,
  meta_description     text,
  h1                   text,
  canonical            text,
  robots               text,
  schema_types         text[],
  content_hash         text,
  etag                 text,
  last_modified        text,
  first_seen_at        timestamptz,
  last_checked_at      timestamptz,
  last_ok_at           timestamptz,
  consecutive_failures int NOT NULL DEFAULT 0
);

-- State is disposable: deleting a page_master row drops its state. The log and
-- notes keep NO ACTION, so a page with history cannot be hard-deleted
-- (archive it via page_master.status instead).
ALTER TABLE seo_page_live_state DROP CONSTRAINT IF EXISTS seo_page_live_state_page_fp_fkey;
ALTER TABLE seo_page_live_state ADD CONSTRAINT seo_page_live_state_page_fp_fkey
  FOREIGN KEY (page_fp) REFERENCES seo_website_page_master(fingerprint) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS seo_page_change_log (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_fp     text NOT NULL REFERENCES seo_website_page_master(fingerprint),
  brand_id    text NOT NULL,
  field       text NOT NULL CHECK (field IN ('url', 'final_url', 'http_status', 'title', 'meta_description',
                                             'h1', 'canonical', 'robots', 'schema_types', 'content_hash')),
  old_value   jsonb,
  new_value   jsonb,
  detected_at timestamptz NOT NULL,
  prev_ok_at  timestamptz,
  change_date date GENERATED ALWAYS AS ((detected_at AT TIME ZONE 'Asia/Bangkok')::date) STORED,
  run_id      text NOT NULL
);

CREATE TABLE IF NOT EXISTS seo_page_change_note (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id   text NOT NULL,
  page_fp    text NOT NULL REFERENCES seo_website_page_master(fingerprint),
  batch_id   text,
  note       text NOT NULL,
  author     text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────────────────────────────────
-- 3. Indexes
-- ─────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_page_change_log_page_detected ON seo_page_change_log (page_fp, detected_at DESC);
CREATE INDEX IF NOT EXISTS idx_page_change_log_brand_date    ON seo_page_change_log (brand_id, change_date);

-- ─────────────────────────────────────────────────────────────────────
-- 4. RLS (house convention) + append-only log
-- ─────────────────────────────────────────────────────────────────────
ALTER TABLE seo_page_live_state  ENABLE ROW LEVEL SECURITY;
ALTER TABLE seo_page_change_log  ENABLE ROW LEVEL SECURITY;
ALTER TABLE seo_page_change_note ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS eywa_authenticated_full_access ON seo_page_live_state;
CREATE POLICY eywa_authenticated_full_access ON seo_page_live_state  FOR ALL TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS eywa_authenticated_full_access ON seo_page_change_log;
CREATE POLICY eywa_authenticated_full_access ON seo_page_change_log  FOR ALL TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS eywa_authenticated_full_access ON seo_page_change_note;
CREATE POLICY eywa_authenticated_full_access ON seo_page_change_note FOR ALL TO authenticated USING (true) WITH CHECK (true);

REVOKE UPDATE, DELETE, TRUNCATE ON seo_page_change_log FROM anon, authenticated, service_role;

-- service_role bypasses RLS but not triggers. "Admin delete" = the postgres
-- owner disabling this trigger inside a reviewed migration.
CREATE OR REPLACE FUNCTION fn_page_change_log_immutable() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'seo_page_change_log is append-only';
END $$;

CREATE OR REPLACE TRIGGER trg_page_change_log_immutable
  BEFORE UPDATE OR DELETE ON seo_page_change_log
  FOR EACH ROW EXECUTE FUNCTION fn_page_change_log_immutable();

CREATE OR REPLACE TRIGGER trg_page_change_log_no_truncate
  BEFORE TRUNCATE ON seo_page_change_log
  FOR EACH STATEMENT EXECUTE FUNCTION fn_page_change_log_immutable();

-- ─────────────────────────────────────────────────────────────────────
-- 5. Views
-- ─────────────────────────────────────────────────────────────────────

-- One change event = all log rows of one page on one Bangkok date.
-- Notes attach when created within the 14 days up to the change_date.
CREATE OR REPLACE VIEW v_page_change_events WITH (security_invoker = true) AS
SELECT l.page_fp,
       l.change_date,
       min(l.brand_id) AS brand_id,
       array_agg(DISTINCT l.field ORDER BY l.field) AS fields,
       CASE WHEN bool_or(l.field IN ('url', 'final_url')) THEN 'url_change'
            WHEN bool_or(l.field IN ('title', 'meta_description', 'h1', 'canonical', 'robots', 'schema_types')) THEN 'seo_meta'
            WHEN bool_or(l.field = 'content_hash') THEN 'content'
            ELSE 'health' END AS event_kind,
       (SELECT array_agg(n.note ORDER BY n.created_at)
          FROM seo_page_change_note n
         WHERE n.page_fp = l.page_fp
           AND (n.created_at AT TIME ZONE 'Asia/Bangkok')::date BETWEEN l.change_date - 14 AND l.change_date) AS notes
FROM seo_page_change_log l
GROUP BY l.page_fp, l.change_date;

-- Before = [change_date-28, change_date); after = [change_date+3, change_date+31).
CREATE OR REPLACE VIEW v_page_change_impact WITH (security_invoker = true) AS
WITH ev AS (
  SELECT * FROM v_page_change_events
),
lo AS (                   -- earliest GSC day any window needs; bounds every GSC scan
  SELECT min(change_date) - 28 AS d FROM ev
),
gurl AS (                 -- normalise distinct GSC URLs, not rows (DISTINCT first, then the function)
  SELECT d.brand_id, d.page_url, seo_norm_url(d.page_url) AS nurl
    FROM (SELECT DISTINCT g.brand_id, g.page_url
            FROM seo_gsc_query_daily g
           WHERE g.brand_id IN (SELECT brand_id FROM ev) AND g.search_type = 'web'
             AND g.snapshot_date >= (SELECT d FROM lo)) d
),
page_urls AS (            -- every URL the page has had, normalised
  SELECT pm.fingerprint AS page_fp, seo_norm_url(pm.canonical_url) AS nurl
    FROM seo_website_page_master pm
   WHERE pm.canonical_url IS NOT NULL AND pm.fingerprint IN (SELECT page_fp FROM ev)
  UNION
  SELECT l.page_fp, seo_norm_url(l.old_value #>> '{}')
    FROM seo_page_change_log l
   WHERE l.field IN ('url', 'final_url') AND jsonb_typeof(l.old_value) = 'string'
  UNION
  SELECT l.page_fp, seo_norm_url(l.new_value #>> '{}')
    FROM seo_page_change_log l
   WHERE l.field IN ('url', 'final_url') AND jsonb_typeof(l.new_value) = 'string'
),
page_win AS (
  SELECT e.page_fp, e.change_date,
         sum(g.clicks)                     FILTER (WHERE g.snapshot_date <  e.change_date)     AS clicks_b,
         sum(g.impressions)                FILTER (WHERE g.snapshot_date <  e.change_date)     AS impr_b,
         sum(g.position * g.impressions)   FILTER (WHERE g.snapshot_date <  e.change_date)     AS posw_b,
         sum(g.clicks)                     FILTER (WHERE g.snapshot_date >= e.change_date + 3) AS clicks_a,
         sum(g.impressions)                FILTER (WHERE g.snapshot_date >= e.change_date + 3) AS impr_a,
         sum(g.position * g.impressions)   FILTER (WHERE g.snapshot_date >= e.change_date + 3) AS posw_a
    FROM ev e
    JOIN page_urls u ON u.page_fp = e.page_fp
    JOIN gurl gu ON gu.brand_id = e.brand_id AND gu.nurl = u.nurl
    JOIN seo_gsc_query_daily g
      ON g.brand_id = gu.brand_id
     AND g.page_url = gu.page_url
     AND g.search_type = 'web'
     AND (g.snapshot_date >= e.change_date - 28 AND g.snapshot_date < e.change_date
          OR g.snapshot_date >= e.change_date + 3 AND g.snapshot_date < e.change_date + 31)
   GROUP BY e.page_fp, e.change_date
),
brand_daily AS (
  SELECT g.brand_id, g.snapshot_date, sum(g.clicks) AS clicks, sum(g.impressions) AS impr
    FROM seo_gsc_query_daily g
   WHERE g.brand_id IN (SELECT brand_id FROM ev) AND g.search_type = 'web'
     AND g.snapshot_date >= (SELECT d FROM lo)
   GROUP BY g.brand_id, g.snapshot_date
),
brand_cov AS (            -- unbounded on purpose: min_d must be the brand's true first GSC day
  SELECT g.brand_id, min(g.snapshot_date) AS min_d, max(g.snapshot_date) AS max_d
    FROM seo_gsc_query_daily g
   WHERE g.brand_id IN (SELECT brand_id FROM ev) AND g.search_type = 'web'
   GROUP BY g.brand_id
),
brand_win AS (
  SELECT e.page_fp, e.change_date,
         sum(b.clicks) FILTER (WHERE b.snapshot_date <  e.change_date)     AS clicks_b,
         sum(b.impr)   FILTER (WHERE b.snapshot_date <  e.change_date)     AS impr_b,
         sum(b.clicks) FILTER (WHERE b.snapshot_date >= e.change_date + 3) AS clicks_a,
         sum(b.impr)   FILTER (WHERE b.snapshot_date >= e.change_date + 3) AS impr_a
    FROM ev e
    JOIN brand_daily b
      ON b.brand_id = e.brand_id
     AND (b.snapshot_date >= e.change_date - 28 AND b.snapshot_date < e.change_date
          OR b.snapshot_date >= e.change_date + 3 AND b.snapshot_date < e.change_date + 31)
   GROUP BY e.page_fp, e.change_date
),
m AS (
  SELECT e.page_fp, e.change_date, e.brand_id, e.event_kind, e.fields, e.notes,
         coalesce(p.clicks_b, 0) AS clicks_b, coalesce(p.impr_b, 0) AS impr_b,
         p.clicks_b::numeric / nullif(p.impr_b, 0) AS ctr_b,
         p.posw_b / nullif(p.impr_b, 0)            AS pos_b,
         coalesce(p.clicks_a, 0) AS clicks_a, coalesce(p.impr_a, 0) AS impr_a,
         p.clicks_a::numeric / nullif(p.impr_a, 0) AS ctr_a,
         p.posw_a / nullif(p.impr_a, 0)            AS pos_a,
         bw.clicks_b::numeric / nullif(bw.impr_b, 0) AS brand_ctr_b,
         bw.clicks_a::numeric / nullif(bw.impr_a, 0) AS brand_ctr_a,
         bw.clicks_b AS brand_clicks_b, bw.clicks_a AS brand_clicks_a,
         c.min_d, c.max_d,
         EXISTS (SELECT 1 FROM ev o
                  WHERE o.page_fp = e.page_fp AND o.change_date <> e.change_date
                    AND abs(o.change_date - e.change_date) <= 31) AS has_overlap
    FROM ev e
    LEFT JOIN page_win  p  ON p.page_fp = e.page_fp AND p.change_date = e.change_date
    LEFT JOIN brand_win bw ON bw.page_fp = e.page_fp AND bw.change_date = e.change_date
    LEFT JOIN brand_cov c  ON c.brand_id = e.brand_id
)
SELECT page_fp, change_date, brand_id, event_kind, fields, notes,
       clicks_b, impr_b, ctr_b, pos_b,
       clicks_a, impr_a, ctr_a, pos_a,
       clicks_a - clicks_b AS d_clicks,
       ctr_a - ctr_b       AS d_ctr,
       pos_a - pos_b       AS d_pos,
       (ctr_a - ctr_b) - (brand_ctr_a - brand_ctr_b) AS ctr_delta_vs_brand,
       (clicks_a::numeric / nullif(clicks_b, 0) - 1)
         - (brand_clicks_a::numeric / nullif(brand_clicks_b, 0) - 1) AS clicks_delta_vs_brand,
       CASE WHEN max_d >= change_date + 30 THEN 'ready' ELSE 'pending' END AS status,
       CASE WHEN impr_b < 100 OR impr_a < 100 OR has_overlap
                 OR min_d IS NULL OR min_d > change_date - 28 THEN 'low'
            WHEN event_kind = 'url_change' THEN 'medium'
            ELSE 'high' END AS confidence
FROM m;

COMMENT ON VIEW v_page_change_impact IS
$$One row per change event (page_fp, change_date) with GSC before/after windows: before = [change_date-28, change_date), after = [change_date+3, change_date+31). GSC rows are matched by seo_norm_url against every URL the page has had (canonical_url + all url/final_url log values), so slug changes keep their before traffic. pos = impression-weighted average position. d_ctr and ctr_delta_vs_brand are absolute CTR deltas (page minus brand); clicks_delta_vs_brand is the page's relative click change minus the brand's (fractions, 0.1 = 10 points). status='ready' once brand GSC reaches change_date+30. confidence: low if either window < 100 impressions, another event on the page within ±31 days, or brand GSC starts after change_date-28; else medium for url_change; else high. CAVEAT: totals are summed from seo_gsc_query_daily (query x page x day), and GSC drops anonymised queries, so page totals UNDERCOUNT. Comparisons within one page are valid; absolute numbers are a lower bound. Only search_type='web' rows are read. CAVEAT: final_url values join the page's URL set, so if this page redirects to another page or to the home page, that target's GSC traffic is attributed to this page from then on.$$;

-- Every value a field has had on a page. The first row per (page, field) is
-- the crawl baseline (old_value of the first change; live_from unknown, NULL).
-- A value restored by a rollback appears again as its own row.
-- change_date = the event that introduced the value (join to v_page_change_impact).
CREATE OR REPLACE VIEW v_page_field_history WITH (security_invoker = true) AS
WITH l AS (
  SELECT page_fp, brand_id, field, old_value, new_value, detected_at, change_date,
         lead(detected_at) OVER (PARTITION BY page_fp, field ORDER BY detected_at, id) AS next_at,
         row_number()      OVER (PARTITION BY page_fp, field ORDER BY detected_at, id) AS rn
    FROM seo_page_change_log
)
SELECT page_fp, brand_id, field, old_value AS value,
       NULL::timestamptz AS live_from, detected_at AS live_to, NULL::date AS change_date
  FROM l WHERE rn = 1
UNION ALL
SELECT page_fp, brand_id, field, new_value AS value,
       detected_at AS live_from, next_at AS live_to, change_date
  FROM l;

REVOKE ALL ON v_page_change_events, v_page_change_impact, v_page_field_history FROM anon;
