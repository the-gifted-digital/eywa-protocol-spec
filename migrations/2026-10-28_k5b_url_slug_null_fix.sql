-- K5b · fix console.url_slug(NULL) returning 'home' (applied 2026-10-28) · 2026-10-28
-- Bug in K5a: coalesce(nullif(..., ''), 'home') turned a NULL ranking URL into 'home', so every tracked keyword with
-- no ranking URL looked like it ranked on the home page ("Ranks on wrong page" flagged 609 of 761 VTH pages).
-- STRICT returns NULL for NULL input; same signature, so dependent views are untouched. Then rebuild the MVs that used it.

begin;

create or replace function console.url_slug(p_url text) returns text
language sql immutable strict set search_path = '' as $$
  select coalesce(nullif(regexp_replace(regexp_replace(p_url, '^https?://[^/]+', ''), '^/+|/+$', '', 'g'), ''), 'home')
$$;

refresh materialized view console.mv_keyword_rank_28d;
refresh materialized view console.mv_page_ga4_28d;

commit;

-- Verify (read-only): select count(*) filter (where page_slug is null), count(*) filter (where page_slug = 'home') from console.mv_keyword_rank_28d where brand_slug = 'vth-biodent';
