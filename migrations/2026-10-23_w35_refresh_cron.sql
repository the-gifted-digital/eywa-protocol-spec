-- W3.5 (DR-079 follow-up): refresh the two quality materialized views every day.
-- mv_keyword_near_pairs (W3.4-prep) and mv_page_priority (W4) only change when refreshed.
-- The GSC load lands at 06:01 Asia/Bangkok (23:01 UTC) every day, so the job runs at
-- 07:00 Bangkok (00:00 UTC; pg_cron schedules in UTC). Near-pairs first: mv_page_priority
-- reads v_keyword_near_duplicates for its duplication signal.
-- Both functions set their own statement_timeout (10 min); together they take ~2 min.
-- Check runs with:  select * from cron.job_run_details order by start_time desc limit 5;

create extension if not exists pg_cron with schema pg_catalog;
grant usage on schema cron to postgres;

select cron.schedule(
  'eywa-refresh-quality-mvs',
  '0 0 * * *',
  $$select public.refresh_keyword_near_pairs(); select public.refresh_page_priority();$$
);
