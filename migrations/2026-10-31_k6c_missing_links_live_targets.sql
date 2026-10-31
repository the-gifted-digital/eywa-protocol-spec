-- K6c · Kameie: a planned link counts as "missing" only when its target page is Live too · 2026-10-31
-- K6a marked every planned link absent from a crawled live page as missing — including links to pages that are not
-- built yet (Planned) or were merged away. On VTH that was 856 + 23 of 1,350 "missing": nothing a webmaster can add.
-- Those now show as 'pending' (waiting for the target). Output columns unchanged, so console_api views keep working.
-- Run in the Supabase SQL editor as one transaction.

begin;

create or replace view console.page_links_all as
with pm as (
  select fingerprint as page_fp, page_fingerprint as page_code, brand_id, coalesce(nullif(slug, ''), 'home') as slug,
         page_name, status
    from public.seo_website_page_master
), planned as (
  select f.brand_id, f.page_fp as from_page_fp, t.page_fp as to_page_fp, t.slug as to_slug,
         l.link_type, l.link_role, l.anchor_text as planned_anchor, l.link_priority
    from public.seo_page_internal_links l
    join pm f on f.page_code = l.from_page_fp
    join pm t on t.page_code = l.to_page_fp
   where l.status = 'planned' and l.to_page_fp is not null
), live as (
  select ll.brand_id, ll.from_page_fp, ll.to_slug, ll.anchor as live_anchor, ll.in_main, ll.nofollow, ll.last_seen_at,
         t.page_fp as to_page_fp
    from public.seo_page_live_links ll
    left join pm t on t.brand_id = ll.brand_id and t.slug = ll.to_slug
)
select coalesce(p.brand_id, v.brand_id)         as brand_slug,
       coalesce(p.from_page_fp, v.from_page_fp) as from_page_fp,
       coalesce(p.to_page_fp, v.to_page_fp)     as to_page_fp,
       coalesce(p.to_slug, v.to_slug)           as to_slug,
       case when p.from_page_fp is not null and v.from_page_fp is not null then 'live'
            when p.from_page_fp is not null and fs.status = 'Live' and ts.status = 'Live' and fl.has_links then 'missing'
            when p.from_page_fp is not null then 'pending'        -- either page not live, or source not crawled for links yet
            else 'unplanned' end                as state,
       p.link_type, p.link_role, p.link_priority, p.planned_anchor, v.live_anchor, v.in_main, v.nofollow, v.last_seen_at
  from planned p
  full join live v on v.from_page_fp = p.from_page_fp and v.to_slug = p.to_slug
  left join pm fs on fs.page_fp = coalesce(p.from_page_fp, v.from_page_fp)
  left join pm ts on ts.page_fp = p.to_page_fp
  left join lateral (select exists (select 1 from public.seo_page_live_links x where x.from_page_fp = fs.page_fp) as has_links) fl on true;

commit;

-- Verify (read-only): missing on VTH should drop from 1,350 to ~471, all with a Live target.
-- select l.state, t.status, count(*) from console.page_links_all l
--   left join public.seo_website_page_master t on t.fingerprint = l.to_page_fp
--  where l.brand_slug = 'vth-biodent' and l.state in ('missing', 'pending') group by 1, 2 order by 1, 3 desc;
