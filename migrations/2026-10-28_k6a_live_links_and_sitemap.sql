-- K6a · internal links: live (crawled) vs planned, for the Kameie sitemap view (applied 2026-10-28) · 2026-10-28
-- 1) public.seo_page_live_links — written nightly by scripts/page-history (service_role), one row per
--    (source page, internal target URL) currently present in the page's HTML. Rows the crawler stops seeing are
--    deleted for that page, so the table is "links on the page as of last_seen_at".
-- 2) console views that line planned links (public.seo_page_internal_links, page codes) up against live ones
--    (by target slug): live / missing / unplanned, plus per-page in/out counts for the plan tree.
-- Run in the Supabase SQL editor as one transaction.

begin;

create table public.seo_page_live_links (
  from_page_fp  text not null,                  -- seo_website_page_master.fingerprint (page_…)
  brand_id      text not null,
  to_url        text not null,                  -- normalised absolute URL (no query/fragment, trailing slash kept as served)
  to_slug       text not null,                  -- console.url_slug(to_url): path without slashes, root = 'home'
  anchor        text,                           -- visible anchor text (first occurrence), collapsed whitespace, ≤ 200 chars
  in_main       boolean not null,               -- inside the main content (not nav/header/footer)
  nofollow      boolean not null default false,
  occurrences   integer not null default 1,
  first_seen_at timestamptz not null default now(),
  last_seen_at  timestamptz not null default now(),
  primary key (from_page_fp, to_url)
);
create index seo_page_live_links_brand_slug on public.seo_page_live_links (brand_id, to_slug);
alter table public.seo_page_live_links enable row level security;   -- no policies: service_role only (same as seo_*)
revoke all on public.seo_page_live_links from anon, authenticated;
grant all on public.seo_page_live_links to service_role;

-- ── planned vs live, internal (no grants)
create view console.page_links_all as
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
            when p.from_page_fp is not null and fs.status = 'Live' and fl.has_links then 'missing'
            when p.from_page_fp is not null then 'pending'        -- source page not live, or not crawled for links yet
            else 'unplanned' end                as state,
       p.link_type, p.link_role, p.link_priority, p.planned_anchor, v.live_anchor, v.in_main, v.nofollow, v.last_seen_at
  from planned p
  full join live v on v.from_page_fp = p.from_page_fp and v.to_slug = p.to_slug
  left join pm fs on fs.page_fp = coalesce(p.from_page_fp, v.from_page_fp)
  left join lateral (select exists (select 1 from public.seo_page_live_links x where x.from_page_fp = fs.page_fp) as has_links) fl on true;

create view console_api.page_links as
select l.*, f.page_name as from_page_name, f.slug as from_slug, t.page_name as to_page_name, t.status as to_status
  from console.page_links_all l
  left join public.seo_website_page_master f on f.fingerprint = l.from_page_fp
  left join public.seo_website_page_master t on t.fingerprint = l.to_page_fp
 where l.brand_slug in (select console.readable_brands());

-- per page: outbound and inbound counts by state (unplanned counted in main content only — nav links are everywhere)
create view console_api.page_link_summary as
with x as (
  select * from console.page_links_all where brand_slug in (select console.readable_brands())
), o as (
  select from_page_fp as page_fp,
         count(*) filter (where state <> 'unplanned')                 as out_planned,
         count(*) filter (where state = 'live')                       as out_live,
         count(*) filter (where state = 'missing')                    as out_missing,
         count(*) filter (where state = 'unplanned' and in_main)      as out_unplanned
    from x group by 1
), i as (
  select to_page_fp as page_fp,
         count(*) filter (where state <> 'unplanned')                 as in_planned,
         count(*) filter (where state = 'live')                       as in_live,
         count(*) filter (where state in ('live','unplanned') and coalesce(in_main, true)) as in_actual
    from x where to_page_fp is not null group by 1
)
select coalesce(o.page_fp, i.page_fp) as page_fp, p.brand_id as brand_slug,
       coalesce(o.out_planned, 0) as out_planned, coalesce(o.out_live, 0) as out_live,
       coalesce(o.out_missing, 0) as out_missing, coalesce(o.out_unplanned, 0) as out_unplanned,
       coalesce(i.in_planned, 0) as in_planned, coalesce(i.in_live, 0) as in_live, coalesce(i.in_actual, 0) as in_actual
  from o full join i on i.page_fp = o.page_fp
  join public.seo_website_page_master p on p.fingerprint = coalesce(o.page_fp, i.page_fp);

revoke all on console_api.page_links, console_api.page_link_summary from public, anon;
grant select on console_api.page_links, console_api.page_link_summary to authenticated;

commit;

-- Verify (read-only, signed-in user):
-- select state, count(*) from console_api.page_links where brand_slug = 'vth-biodent' group by 1;
--   before the first crawl with links: only 'pending' (planned links, nothing crawled yet)
