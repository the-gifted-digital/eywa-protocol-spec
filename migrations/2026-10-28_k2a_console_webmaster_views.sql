-- K2a · Kameie Webmaster view: page health issues + live change feed (applied 2026-10-28) · 2026-10-28
-- Kameie Phase 3. Read-only views over the existing live-state monitor (seo_page_live_state, daily) and its
-- diff log (seo_page_change_log). No new crawler: issues are derived from what the monitor already records.
-- Scope: Live pages (full on-page checks) + Merged pages that have a redirect_target (is the 301 in place?).
-- Run in the Supabase SQL editor as one transaction.

begin;

create view console_api.page_health as
with p as (
  select p.fingerprint as page_fp, p.page_fingerprint as page_code, p.brand_id as brand_slug, p.slug, p.page_name,
         p.page_type, p.status, p.redirect_target
    from public.seo_website_page_master p
   where p.brand_id in (select console.readable_brands())
     and (p.status = 'Live' or (p.status = 'Merged' and p.redirect_target is not null))
), j as (
  select p.*, ls.page_fp is not null as monitored,
         ls.url, ls.final_url, ls.http_status, ls.title, ls.meta_description, ls.h1, ls.canonical, ls.robots,
         ls.schema_types, ls.last_checked_at, ls.last_ok_at, ls.consecutive_failures,
         rtrim(coalesce(ls.final_url, ls.url), '/') as landed,
         coalesce(ls.last_checked_at < now() - interval '3 days', false) as stale
    from p left join public.seo_page_live_state ls on ls.page_fp = p.page_fp
)
select j.page_fp, j.page_code, j.brand_slug, j.slug, j.page_name, j.page_type, j.status, j.redirect_target,
       j.url, j.final_url, j.http_status, j.title, char_length(j.title) as title_len,
       j.meta_description, char_length(j.meta_description) as meta_len, j.h1, j.canonical, j.robots, j.schema_types,
       j.last_checked_at, j.last_ok_at, j.consecutive_failures,
       array_remove(array[
         -- Live: is the page reachable and monitored?
         case when j.status = 'Live' and not j.monitored then 'not_monitored' end,
         case when j.status = 'Live' and j.stale then 'stale_check' end,
         case when j.monitored and j.http_status is null and not j.stale then 'unreachable' end,
         case when j.http_status >= 400 and not j.stale then 'http_error' end,
         -- Merged: is the 301 in place? (the monitor stops re-checking merged pages, so old evidence = unverified)
         case when j.status = 'Merged' and (not j.monitored or j.stale) then 'redirect_unverified' end,
         case when j.status = 'Merged' and j.monitored and not j.stale and j.landed = rtrim(j.url, '/') then 'redirect_missing' end,
         case when j.status = 'Merged' and j.monitored and not j.stale and j.landed <> rtrim(j.url, '/')
                   and j.landed <> rtrim(j.redirect_target, '/') then 'redirect_wrong_target' end,
         case when j.status = 'Live' and j.landed <> rtrim(j.url, '/') then 'live_redirected' end,
         case when j.status = 'Live' and j.monitored and coalesce(trim(j.title), '') = '' then 'missing_title' end,
         case when j.status = 'Live' and char_length(j.title) > 70 then 'title_long' end,
         case when j.status = 'Live' and j.monitored and coalesce(trim(j.meta_description), '') = '' then 'missing_meta' end,
         case when j.status = 'Live' and char_length(j.meta_description) > 160 then 'meta_long' end,
         case when j.status = 'Live' and j.monitored and coalesce(trim(j.h1), '') = '' then 'missing_h1' end,
         case when j.status = 'Live' and j.canonical is not null and rtrim(j.canonical, '/') <> j.landed then 'canonical_other' end,
         case when j.status = 'Live' and j.robots ilike '%noindex%' then 'noindex' end,
         case when j.status = 'Live' and j.monitored and coalesce(cardinality(j.schema_types), 0) = 0 then 'no_schema' end
       ], null) as issues
  from j;

-- what the monitor saw change, per page (last 90 days)
create view console_api.page_changes as
select c.id, c.brand_id as brand_slug, c.page_fp, p.page_fingerprint as page_code, p.slug, p.page_name,
       c.field, c.old_value, c.new_value, c.change_date, c.detected_at
  from public.seo_page_change_log c
  join public.seo_website_page_master p on p.fingerprint = c.page_fp
 where c.brand_id in (select console.readable_brands())
   and c.change_date >= current_date - 90;

revoke all on console_api.page_health, console_api.page_changes from public, anon;
grant select on console_api.page_health, console_api.page_changes to authenticated;

commit;

-- Verify (read-only, signed-in user): select unnest(issues) i, count(*) from console_api.page_health group by 1 order by 2 desc;
