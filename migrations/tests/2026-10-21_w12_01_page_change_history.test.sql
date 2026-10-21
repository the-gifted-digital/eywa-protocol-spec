-- =====================================================================
-- Self-test for 2026-10-21_eywa_w12_01_dr076_page_change_history.sql
-- Assumes the migration is already applied. Everything runs inside one
-- transaction that is ROLLED BACK, so nothing persists.
-- Success = the output contains the notice 'ALL PASS'. Any failed assertion
-- raises an exception and aborts.
-- =====================================================================
BEGIN;

-- 1. URL normalisation (same cases as scripts/page-history/fixtures/url-cases.json)
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT * FROM (VALUES
    ('https://WWW.VthBiodent.com/team/dr-a/?utm_source=x#top', 'https://vthbiodent.com/team/dr-a'),
    ('https://deezydental.com/', 'https://deezydental.com/'),
    ('https://deezydental.com', 'https://deezydental.com/'),
    ('http://www.clearisma.com/a/b/', 'http://clearisma.com/a/b'),
    ('https://tcsmiledental.com/%E0%B8%9F%E0%B8%B1%E0%B8%99', 'https://tcsmiledental.com/%E0%B8%9F%E0%B8%B1%E0%B8%99'),
    ('HTTPS://Example.COM/Path/Keep-Case/', 'https://example.com/Path/Keep-Case'),
    ('https://example.com/?q=1', 'https://example.com/'),
    ('https://example.com#frag', 'https://example.com/'),
    ('https://wwwx.example.com/a', 'https://wwwx.example.com/a')
  ) v(i, o) LOOP
    IF seo_norm_url(r.i) IS DISTINCT FROM r.o THEN
      RAISE EXCEPTION 'seo_norm_url(%) = %, want %', r.i, seo_norm_url(r.i), r.o;
    END IF;
  END LOOP;
END $$;

-- Test pages (fingerprint is set by the page_master default/trigger)
INSERT INTO seo_website_page_master (page_fingerprint, fingerprint_display_name, brand_id, status, canonical_url, slug) VALUES
  ('w-test-p',     'w-test::p',     'w-test-brand', 'Live', 'https://test.invalid/p',     'p'),
  ('w-test-q',     'w-test::q',     'w-test-brand', 'Live', 'https://test.invalid/q',     'q'),
  ('w-test-r-new', 'w-test::r-new', 'w-test-brand', 'Live', 'https://test.invalid/r-new', 'r-new'),
  ('w-test-s',     'w-test::s',     'w-test-brand', 'Live', 'https://test.invalid/s',     's');

-- 2. Append-only log: privileges revoked, UPDATE and DELETE raise
DO $$
DECLARE fp text; ok boolean;
BEGIN
  IF EXISTS (SELECT 1 FROM unnest(ARRAY['anon', 'authenticated', 'service_role']) rl,
                           unnest(ARRAY['UPDATE', 'DELETE', 'TRUNCATE']) pv
             WHERE has_table_privilege(rl, 'seo_page_change_log', pv)) THEN
    RAISE EXCEPTION 'an app role still holds UPDATE/DELETE/TRUNCATE on seo_page_change_log';
  END IF;
  IF has_table_privilege('anon', 'v_page_change_impact', 'SELECT')
     OR has_table_privilege('anon', 'v_page_change_events', 'SELECT')
     OR has_table_privilege('anon', 'v_page_field_history', 'SELECT') THEN
    RAISE EXCEPTION 'anon can still read the change-history views';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname IN ('v_page_change_events', 'v_page_change_impact', 'v_page_field_history')
             AND NOT coalesce(reloptions @> ARRAY['security_invoker=true'], false)) THEN
    RAISE EXCEPTION 'a change-history view is not security_invoker';
  END IF;

  SELECT fingerprint INTO fp FROM seo_website_page_master WHERE canonical_url = 'https://test.invalid/s';
  INSERT INTO seo_page_change_log (page_fp, brand_id, field, old_value, new_value, detected_at, run_id)
  VALUES (fp, 'w-test-brand', 'title', '"a"', '"b"', '2026-01-01 03:00+07', 'test');

  ok := false;
  BEGIN
    UPDATE seo_page_change_log SET new_value = '"c"' WHERE page_fp = fp;
  EXCEPTION WHEN others THEN
    ok := sqlerrm LIKE '%append-only%';
  END;
  IF NOT ok THEN RAISE EXCEPTION 'UPDATE on seo_page_change_log did not raise append-only'; END IF;

  ok := false;
  BEGIN
    DELETE FROM seo_page_change_log WHERE page_fp = fp;
  EXCEPTION WHEN others THEN
    ok := sqlerrm LIKE '%append-only%';
  END;
  IF NOT ok THEN RAISE EXCEPTION 'DELETE on seo_page_change_log did not raise append-only'; END IF;

  ok := false;
  BEGIN
    TRUNCATE seo_page_change_log;
  EXCEPTION WHEN others THEN
    ok := sqlerrm LIKE '%append-only%';
  END;
  IF NOT ok THEN RAISE EXCEPTION 'TRUNCATE on seo_page_change_log did not raise append-only'; END IF;

  -- change_date is the Asia/Bangkok date of detected_at
  IF (SELECT change_date FROM seo_page_change_log WHERE page_fp = fp) <> date '2026-01-01' THEN
    RAISE EXCEPTION 'change_date is not the Bangkok date';
  END IF;
END $$;

-- 3. Impact math: before rows on www + trailing slash, after rows with a query string
DO $$
DECLARE fp text; v record;
BEGIN
  SELECT fingerprint INTO fp FROM seo_website_page_master WHERE canonical_url = 'https://test.invalid/p';
  INSERT INTO seo_page_change_log (page_fp, brand_id, field, old_value, new_value, detected_at, run_id)
  VALUES (fp, 'w-test-brand', 'url', '"https://test.invalid/p-old"', '"https://test.invalid/p"', '2026-08-01 03:00+07', 'test');

  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d::date, 'web', 'q1', 'https://www.test.invalid/p/', 1, 10, 0.1, 5
  FROM generate_series(date '2026-07-04', date '2026-07-31', interval '1 day') d;   -- 28 days before
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d::date, 'web', 'q1', 'https://test.invalid/p?x=1', 2, 10, 0.2, 3
  FROM generate_series(date '2026-08-04', date '2026-08-31', interval '1 day') d;   -- 28 days after
  -- decoys outside both windows (day -29, change day, recrawl gap, day +31): must be ignored
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d, 'web', 'q1', 'https://test.invalid/p', 500, 1000, 0.5, 1
  FROM unnest(ARRAY[date '2026-07-03', date '2026-08-01', date '2026-08-02', date '2026-08-03', date '2026-09-01']) d;
  -- non-web search type inside both windows: must be ignored
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  VALUES ('w-test-brand', date '2026-07-10', 'image', 'q1', 'https://test.invalid/p', 500, 1000, 0.5, 1),
         ('w-test-brand', date '2026-08-10', 'image', 'q1', 'https://test.invalid/p', 500, 1000, 0.5, 1);

  SELECT * INTO v FROM v_page_change_impact WHERE page_fp = fp AND change_date = date '2026-08-01';
  IF v IS NULL THEN RAISE EXCEPTION 'no impact row for the url event'; END IF;
  IF (v.impr_b, v.clicks_b, v.impr_a, v.clicks_a, v.d_clicks) IS DISTINCT FROM (280::numeric, 28::numeric, 280::numeric, 56::numeric, 28::numeric)
     OR v.status <> 'ready' OR v.event_kind <> 'url_change' OR v.confidence <> 'medium' THEN
    RAISE EXCEPTION 'impact row wrong: %', row_to_json(v);
  END IF;
  IF v.pos_b <> 5 OR v.pos_a <> 3 OR v.d_pos <> -2 OR v.ctr_b <> 0.1 OR v.ctr_a <> 0.2 THEN
    RAISE EXCEPTION 'impact ctr/pos wrong: %', row_to_json(v);
  END IF;
  -- The page is the whole brand here, so the brand-relative deltas are zero.
  IF v.ctr_delta_vs_brand <> 0 OR v.clicks_delta_vs_brand <> 0 THEN
    RAISE EXCEPTION 'brand-relative deltas wrong: %', row_to_json(v);
  END IF;
END $$;

-- 4. Slug change: before traffic on the old URL, after traffic on the new URL
DO $$
DECLARE fp text; v record;
BEGIN
  SELECT fingerprint INTO fp FROM seo_website_page_master WHERE canonical_url = 'https://test.invalid/r-new';
  INSERT INTO seo_page_change_log (page_fp, brand_id, field, old_value, new_value, detected_at, run_id)
  VALUES (fp, 'w-test-brand', 'url', '"https://test.invalid/r-old"', '"https://test.invalid/r-new"', '2026-08-02 03:00+07', 'test');
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d::date, 'web', 'q2', 'https://test.invalid/r-old', 1, 10, 0.1, 5
  FROM generate_series(date '2026-07-05', date '2026-08-01', interval '1 day') d;
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d::date, 'web', 'q2', 'https://test.invalid/r-new/', 3, 10, 0.3, 4
  FROM generate_series(date '2026-08-05', date '2026-09-01', interval '1 day') d;

  -- brand GSC now ends 2026-09-01 = change_date + 30, the earliest 'ready' day
  SELECT * INTO v FROM v_page_change_impact WHERE page_fp = fp;
  IF v.impr_b <> 280 OR v.clicks_b <> 28 OR v.impr_a <> 280 OR v.clicks_a <> 84 OR v.status <> 'ready' THEN
    RAISE EXCEPTION 'slug-change impact wrong: %', row_to_json(v);
  END IF;

  -- v_page_field_history: baseline value then the new value
  IF (SELECT array_agg(value #>> '{}' ORDER BY live_from NULLS FIRST) FROM v_page_field_history WHERE page_fp = fp AND field = 'url')
     IS DISTINCT FROM ARRAY['https://test.invalid/r-old', 'https://test.invalid/r-new'] THEN
    RAISE EXCEPTION 'v_page_field_history wrong';
  END IF;
  IF EXISTS (SELECT 1 FROM v_page_field_history WHERE page_fp = fp AND field = 'url' AND value = '"https://test.invalid/r-new"'
             AND (live_to IS NOT NULL OR change_date <> date '2026-08-02')) THEN
    RAISE EXCEPTION 'v_page_field_history current value wrong';
  END IF;
END $$;

-- 5. Pending: an event detected now has no 30 days of GSC after it
DO $$
DECLARE fp text;
BEGIN
  SELECT fingerprint INTO fp FROM seo_website_page_master WHERE canonical_url = 'https://test.invalid/s';
  INSERT INTO seo_page_change_log (page_fp, brand_id, field, old_value, new_value, detected_at, run_id)
  VALUES (fp, 'w-test-brand', 'title', '"b"', '"c"', now(), 'test');
  IF (SELECT status FROM v_page_change_impact WHERE page_fp = fp AND change_date = (now() AT TIME ZONE 'Asia/Bangkok')::date) <> 'pending' THEN
    RAISE EXCEPTION 'event detected now is not pending';
  END IF;
END $$;

-- 6. Overlap: two events on one page 10 days apart are both low confidence
DO $$
DECLARE fp text;
BEGIN
  SELECT fingerprint INTO fp FROM seo_website_page_master WHERE canonical_url = 'https://test.invalid/q';
  INSERT INTO seo_page_change_log (page_fp, brand_id, field, old_value, new_value, detected_at, run_id) VALUES
    (fp, 'w-test-brand', 'title', '"t1"', '"t2"', '2026-08-01 03:00+07', 'test'),
    (fp, 'w-test-brand', 'title', '"t2"', '"t3"', '2026-08-11 03:00+07', 'test');
  -- enough impressions in every window, so the overlap is the only reason for 'low'
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d::date, 'web', 'q3', 'https://test.invalid/q', 1, 10, 0.1, 5
  FROM generate_series(date '2026-07-04', date '2026-09-10', interval '1 day') d;
  IF (SELECT count(*) FROM v_page_change_impact WHERE page_fp = fp AND confidence = 'low') <> 2 THEN
    RAISE EXCEPTION 'overlapping events are not both low confidence';
  END IF;
  IF (SELECT event_kind FROM v_page_change_events WHERE page_fp = fp LIMIT 1) <> 'seo_meta' THEN
    RAISE EXCEPTION 'title event is not seo_meta';
  END IF;
END $$;

-- 7. Notes: a note made within 14 days before the event is attached
DO $$
DECLARE fp text;
BEGIN
  SELECT fingerprint INTO fp FROM seo_website_page_master WHERE canonical_url = 'https://test.invalid/q';
  INSERT INTO seo_page_change_note (brand_id, page_fp, batch_id, note, author, created_at) VALUES
    ('w-test-brand', fp, 'b1', 'add price to title', 'test', '2026-07-25 10:00+07'),
    ('w-test-brand', fp, NULL, 'too early', 'test', '2026-07-17 10:00+07');
  IF (SELECT notes FROM v_page_change_events WHERE page_fp = fp AND change_date = date '2026-08-01')
     IS DISTINCT FROM ARRAY['add price to title'] THEN
    RAISE EXCEPTION 'notes not attached as expected';
  END IF;
END $$;

-- 8. Late GSC start: brand data begins after change_date - 28, so 'low' despite enough impressions
DO $$
DECLARE fp text;
BEGIN
  INSERT INTO seo_website_page_master (page_fingerprint, fingerprint_display_name, brand_id, status, canonical_url, slug)
  VALUES ('w-test-late-x', 'w-test::late-x', 'w-test-brand-late', 'Live', 'https://late.invalid/x', 'x') RETURNING fingerprint INTO fp;
  INSERT INTO seo_page_change_log (page_fp, brand_id, field, old_value, new_value, detected_at, run_id)
  VALUES (fp, 'w-test-brand-late', 'title', '"a"', '"b"', '2026-08-01 03:00+07', 'test');
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand-late', d::date, 'web', 'q4', 'https://late.invalid/x', 1, 10, 0.1, 5
  FROM generate_series(date '2026-07-05', date '2026-08-31', interval '1 day') d;   -- starts at day -27
  IF (SELECT confidence FROM v_page_change_impact WHERE page_fp = fp) <> 'low' THEN
    RAISE EXCEPTION 'late GSC start is not low confidence';
  END IF;
  -- same data one day earlier covers the whole before window -> high
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  VALUES ('w-test-brand-late', date '2026-07-04', 'web', 'q4', 'https://late.invalid/x', 1, 10, 0.1, 5);
  IF (SELECT confidence FROM v_page_change_impact WHERE page_fp = fp) <> 'high' THEN
    RAISE EXCEPTION 'fully covered seo_meta event is not high confidence';
  END IF;
END $$;

DO $$ BEGIN RAISE NOTICE 'ALL PASS'; END $$;
SELECT 'ALL PASS' AS result;   -- the Supabase SQL editor may not show notices

ROLLBACK;
