-- Self-test for 2026-10-23_eywa_w12_02_dr078_impact_14_28.sql (run AFTER the migration).
-- Everything is inside BEGIN … ROLLBACK: nothing persists. Success = last result row 'ALL PASS'.
BEGIN;

INSERT INTO seo_website_page_master (page_fingerprint, fingerprint_display_name, brand_id, status, canonical_url, slug) VALUES
  ('w-test-14a', 'w-test::14a', 'w-test-brand', 'Live', 'https://test.invalid/14a', '14a'),
  ('w-test-14b', 'w-test::14b', 'w-test-brand', 'Live', 'https://test.invalid/14b', '14b');

DO $$
DECLARE fa text; fb text; v record;
BEGIN
  SELECT fingerprint INTO fa FROM seo_website_page_master WHERE page_fingerprint = 'w-test-14a';
  SELECT fingerprint INTO fb FROM seo_website_page_master WHERE page_fingerprint = 'w-test-14b';

  -- Page A: title change on 2026-08-01 (Bangkok). Brand GSC runs 2026-07-04 .. 2026-08-31.
  INSERT INTO seo_page_change_log (page_fp, brand_id, field, old_value, new_value, detected_at, run_id)
  VALUES (fa, 'w-test-brand', 'title', '"old"', '"new"', '2026-08-01 03:00+07', 'test');
  -- before: days -28..-15 → 10 impr / 1 click; days -14..-1 → 10 impr / 2 clicks
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d::date, 'web', 'q', 'https://test.invalid/14a', 1, 10, 0.1, 6
  FROM generate_series(date '2026-07-04', date '2026-07-17', interval '1 day') d;
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d::date, 'web', 'q', 'https://test.invalid/14a', 2, 10, 0.2, 4
  FROM generate_series(date '2026-07-18', date '2026-07-31', interval '1 day') d;
  -- after: days +3..+16 → 10 impr / 4 clicks; days +17..+30 → 10 impr / 1 click
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d::date, 'web', 'q', 'https://test.invalid/14a', 4, 10, 0.4, 2
  FROM generate_series(date '2026-08-04', date '2026-08-17', interval '1 day') d;
  INSERT INTO seo_gsc_query_daily (brand_id, snapshot_date, search_type, query, page_url, clicks, impressions, ctr, position)
  SELECT 'w-test-brand', d::date, 'web', 'q', 'https://test.invalid/14a', 1, 10, 0.1, 3
  FROM generate_series(date '2026-08-18', date '2026-08-31', interval '1 day') d;

  SELECT * INTO v FROM v_page_change_impact WHERE page_fp = fa AND change_date = date '2026-08-01';
  IF v IS NULL THEN RAISE EXCEPTION 'no impact row for page A'; END IF;

  -- existing 28-day columns unchanged in meaning
  IF (v.impr_b, v.clicks_b, v.impr_a, v.clicks_a, v.d_clicks, v.status, v.confidence)
     IS DISTINCT FROM (280::bigint, 42::bigint, 280::bigint, 70::bigint, 28::bigint, 'ready', 'high') THEN
    RAISE EXCEPTION '28-day block wrong: %', row_to_json(v);
  END IF;
  -- new 28-day relative columns
  IF v.d_impr <> 0 OR round(v.pct_clicks, 4) <> 0.6667 OR v.pct_impr <> 0 OR round(v.pct_ctr, 4) <> 0.6667 THEN
    RAISE EXCEPTION '28-day pct block wrong: d_impr=% pct_clicks=% pct_impr=% pct_ctr=%', v.d_impr, v.pct_clicks, v.pct_impr, v.pct_ctr;
  END IF;
  -- 14-day early read: only days -14..-1 and +3..+16
  IF (v.impr_b14, v.clicks_b14, v.impr_a14, v.clicks_a14, v.d_clicks14, v.d_impr14)
     IS DISTINCT FROM (140::bigint, 28::bigint, 140::bigint, 56::bigint, 28::bigint, 0::bigint)
     OR v.ctr_b14 <> 0.2 OR v.ctr_a14 <> 0.4 OR round(v.d_ctr14, 4) <> 0.2
     OR v.pos_b14 <> 4 OR v.pos_a14 <> 2 OR v.d_pos14 <> -2
     OR v.pct_clicks14 <> 1 OR v.pct_ctr14 <> 1
     OR v.status14 <> 'ready' OR v.confidence14 <> 'high' THEN
    RAISE EXCEPTION '14-day block wrong: %', row_to_json(v);
  END IF;

  -- Page B: change on 2026-08-10 → 14-day read is ready (needs GSC to 08-26), 28-day still pending (needs 09-09)
  INSERT INTO seo_page_change_log (page_fp, brand_id, field, old_value, new_value, detected_at, run_id)
  VALUES (fb, 'w-test-brand', 'title', '"b-old"', '"b-new"', '2026-08-10 03:00+07', 'test');
  SELECT * INTO v FROM v_page_change_impact WHERE page_fp = fb AND change_date = date '2026-08-10';
  IF v.status14 <> 'ready' OR v.status <> 'pending' THEN
    RAISE EXCEPTION 'page B statuses wrong: status14=% status=%', v.status14, v.status;
  END IF;
  -- no GSC for page B → both reads low confidence
  IF v.confidence14 <> 'low' OR v.confidence <> 'low' THEN
    RAISE EXCEPTION 'page B confidence wrong: %/%', v.confidence14, v.confidence;
  END IF;

  -- second event on page A 20 days later: overlaps the 28-day read (±31) but not the 14-day read (±17)
  INSERT INTO seo_page_change_log (page_fp, brand_id, field, old_value, new_value, detected_at, run_id)
  VALUES (fa, 'w-test-brand', 'h1', '"x"', '"y"', '2026-08-21 03:00+07', 'test');
  SELECT * INTO v FROM v_page_change_impact WHERE page_fp = fa AND change_date = date '2026-08-01';
  IF v.confidence <> 'low' OR v.confidence14 <> 'high' THEN
    RAISE EXCEPTION 'overlap windows wrong: confidence=% confidence14=%', v.confidence, v.confidence14;
  END IF;

  -- view stays invoker + closed to anon
  IF has_table_privilege('anon', 'v_page_change_impact', 'SELECT') THEN
    RAISE EXCEPTION 'anon can read v_page_change_impact';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'v_page_change_impact'
                 AND array_to_string(reloptions, ',') LIKE '%security_invoker=true%') THEN
    RAISE EXCEPTION 'v_page_change_impact lost security_invoker';
  END IF;

  RAISE NOTICE 'ALL PASS';
END $$;

SELECT 'ALL PASS' AS result;
ROLLBACK;
