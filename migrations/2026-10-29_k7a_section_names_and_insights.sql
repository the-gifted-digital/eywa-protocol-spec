-- K7a · Kameie: sitemap section names + Phase 6b panels absorbed from Deezy Analytics (applied 2026-10-29) · 2026-10-29
-- 1) console.sitemap_section_names — standard names for sections 1–9 ('*' = default), per-brand overrides.
-- 2) AI visibility — crawls by AI agents (public.seo_ai_agent_visits, logged by brand-site workers; today deezy + vth).
--    Aggregates only: no user-agent strings, ASN or country leave the base table.
-- 3) Page tech — latest Core Web Vitals + mobile/desktop rank and GA4 sessions per URL, from the daily logs.
-- 4) Entity graph — the brand's entities (console.mv_entity_plan nodes) and the relationships between them.
-- Run in the Supabase SQL editor as one transaction.

begin;

-- ── 1. section names
create table console.sitemap_section_names (
  brand_slug text not null default '*',          -- '*' = default for every brand
  section    integer not null check (section between 1 and 20),
  name       text not null,
  primary key (brand_slug, section)
);
alter table console.sitemap_section_names enable row level security;
create policy ssn_select on console.sitemap_section_names for select to authenticated using (true);   -- names only, no data
create policy ssn_write on console.sitemap_section_names for all to authenticated
  using (console.is_platform_admin()) with check (console.is_platform_admin());
grant select, insert, update, delete on console.sitemap_section_names to authenticated;
grant all on console.sitemap_section_names to service_role;

insert into console.sitemap_section_names (brand_slug, section, name) values
  ('*', 1, 'Home'), ('*', 2, 'Uniqueness'), ('*', 3, 'Services'), ('*', 4, 'Technology'), ('*', 5, 'Conditions'),
  ('*', 6, 'Insights'), ('*', 7, 'Cases'), ('*', 8, 'Patient journey'), ('*', 9, 'Local');

-- one row per readable brand x section that its plan uses; brand override wins over the default
create view console_api.sitemap_sections as
with used as (
  select distinct brand_id as brand_slug, sitemap_section::integer as section
    from public.seo_website_page_master
   where brand_id in (select console.readable_brands()) and sitemap_section ~ '^[0-9]+$'
)
select u.brand_slug, u.section, coalesce(b.name, d.name, 'Section ' || u.section) as name, (b.name is not null) as overridden
  from used u
  left join console.sitemap_section_names b on b.brand_slug = u.brand_slug and b.section = u.section
  left join console.sitemap_section_names d on d.brand_slug = '*' and d.section = u.section;

-- ── 2. AI visibility
create materialized view console.mv_ai_visits_daily as
select brand_id as brand_slug, (visited_at at time zone 'Asia/Bangkok')::date as day,
       coalesce(agent_platform, 'unknown') as platform, coalesce(agent_type, 'unknown') as agent_type,
       count(*)::int as visits, count(distinct console.url_slug(regexp_replace(visit_url, '[?#].*$', '')))::int as pages,
       count(*) filter (where http_status_code >= 400)::int as errors
  from public.seo_ai_agent_visits
 where visited_at > now() - interval '200 days'
 group by 1, 2, 3, 4;
create unique index on console.mv_ai_visits_daily (brand_slug, day, platform, agent_type);

create materialized view console.mv_ai_visits_page_28d as
select brand_id as brand_slug, console.url_slug(regexp_replace(visit_url, '[?#].*$', '')) as page_slug, coalesce(agent_platform, 'unknown') as platform,
       count(*)::int as visits_28d, max(visited_at) as last_visit,
       count(*) filter (where agent_type = 'retrieval')::int as retrieval_28d
  from public.seo_ai_agent_visits
 where visited_at > now() - interval '28 days' and visit_url is not null
 group by 1, 2, 3;
create unique index on console.mv_ai_visits_page_28d (brand_slug, page_slug, platform);

-- ── 3. page tech: latest CWV per URL + device split
create materialized view console.mv_page_tech as
with l as (
  select b.brand_slug, console.url_slug(l.gsc_actual_ranking_url) as page_slug, l.*
    from public.seo_x_ads_keywords_x_url_daily_logs l
    join public.brands b on b.brand_name = l.brand
   where l.snapshot_at > now() - interval '60 days' and l.gsc_actual_ranking_url is not null
), cwv as (
  select distinct on (brand_slug, page_slug) brand_slug, page_slug,
         cwv_mobile_performance_score as perf, cwv_lcp_loading as lcp, cwv_cls_stability as cls, cwv_inp as inp,
         cwv_tbt as tbt, cwv_fcp as fcp, cwv_ttfb as ttfb, cwv_score_seo as seo_score,
         cwv_score_accessibility as a11y_score, cwv_last_update
    from l where cwv_mobile_performance_score is not null
   order by brand_slug, page_slug, snapshot_at desc
), last as (select brand_slug, max(snapshot_at::date) as d from l group by 1
), dev as (
  select l.brand_slug, l.page_slug,
         round(avg(l.gsc_mobile_ranking) filter (where l.snapshot_at::date > last.d - 7), 1)  as pos_mobile,
         round(avg(l.gsc_desktop_ranking) filter (where l.snapshot_at::date > last.d - 7), 1) as pos_desktop,
         round(avg(l.gsc_ctr_mobile) filter (where l.snapshot_at::date > last.d - 7), 2)      as ctr_mobile,
         round(avg(l.gsc_ctr_desktop) filter (where l.snapshot_at::date > last.d - 7), 2)     as ctr_desktop
    from l join last on last.brand_slug = l.brand_slug
   group by 1, 2
), ga as (   -- page-level GA4 repeats on every keyword row: max per URL per day, then sum over 28 days
  select brand_slug, page_slug, sum(mob)::int as sessions_mobile_28d, sum(dsk)::int as sessions_desktop_28d
    from (select l.brand_slug, l.page_slug, l.snapshot_at::date as day,
                 max(l.ga4_total_mobile_sessions) as mob, max(l.ga4_total_desktop_sessions) as dsk
            from l join last on last.brand_slug = l.brand_slug
           where l.snapshot_at::date > last.d - 28
           group by 1, 2, 3) d
   group by 1, 2
)
select coalesce(d.brand_slug, c.brand_slug) as brand_slug, coalesce(d.page_slug, c.page_slug) as page_slug,
       c.perf, c.lcp, c.cls, c.inp, c.tbt, c.fcp, c.ttfb, c.seo_score, c.a11y_score, c.cwv_last_update,
       d.pos_mobile, d.pos_desktop, d.ctr_mobile, d.ctr_desktop, g.sessions_mobile_28d, g.sessions_desktop_28d
  from dev d
  full join cwv c on c.brand_slug = d.brand_slug and c.page_slug = d.page_slug
  left join ga g on g.brand_slug = coalesce(d.brand_slug, c.brand_slug) and g.page_slug = coalesce(d.page_slug, c.page_slug);
create unique index on console.mv_page_tech (brand_slug, page_slug);

create function console.refresh_insight_mvs() returns void
language plpgsql security definer set search_path = '' as $$
begin
  refresh materialized view concurrently console.mv_ai_visits_daily;
  refresh materialized view concurrently console.mv_ai_visits_page_28d;
  refresh materialized view concurrently console.mv_page_tech;
end $$;
revoke all on function console.refresh_insight_mvs() from public, anon, authenticated;
select cron.schedule('kameie-refresh-insight-mvs', '55 0 * * *', 'select console.refresh_insight_mvs()');

-- ── read API
create view console_api.ai_visits_daily as
select * from console.mv_ai_visits_daily where brand_slug in (select console.readable_brands());

create view console_api.ai_visits_pages as
select v.*, p.page_name, p.fingerprint as page_fp
  from console.mv_ai_visits_page_28d v
  left join public.seo_website_page_master p on p.brand_id = v.brand_slug and coalesce(nullif(p.slug, ''), 'home') = v.page_slug
 where v.brand_slug in (select console.readable_brands());

create view console_api.page_tech as
select t.*, p.page_name, p.fingerprint as page_fp
  from console.mv_page_tech t
  left join public.seo_website_page_master p on p.brand_id = t.brand_slug and coalesce(nullif(p.slug, ''), 'home') = t.page_slug
 where t.brand_slug in (select console.readable_brands());

-- entity graph: nodes = the brand's entities (with plan/supply metrics), edges = relationships between two of them
create view console_api.entity_graph_nodes as
select e.brand_id as brand_slug, e.entity_fp, e.entity_name, e.entity_type, e.topic_cluster_id,
       e.pages, e.kw_total, e.vol_total, e.vol_free, e.new_page_candidate, e.page_gap, e.supply_gap,
       g.schema_org_type, g.entity_authority_score, g.parent_entity_fp
  from console.mv_entity_plan e
  left join public.seo_entity_graph g on g.entity_fingerprint = e.entity_fp
 where e.brand_id in (select console.readable_brands());

create view console_api.entity_graph_edges as
select a.brand_id as brand_slug, r.from_entity_fp, r.to_entity_fp, r.edge_type, r.edge_strength, r.edge_evidence_score
  from public.seo_entity_relationships r
  join console.mv_entity_plan a on a.entity_fp = r.from_entity_fp
  join console.mv_entity_plan b on b.entity_fp = r.to_entity_fp and b.brand_id = a.brand_id
 where a.brand_id in (select console.readable_brands())
   and coalesce(r.status, 'active') not in ('deprecated', 'rejected');

revoke all on console_api.sitemap_sections, console_api.ai_visits_daily, console_api.ai_visits_pages,
              console_api.page_tech, console_api.entity_graph_nodes, console_api.entity_graph_edges from public, anon;
grant select on console_api.sitemap_sections, console_api.ai_visits_daily, console_api.ai_visits_pages,
                console_api.page_tech, console_api.entity_graph_nodes, console_api.entity_graph_edges to authenticated;

commit;

-- Verify (read-only, signed-in user):
-- select * from console_api.sitemap_sections where brand_slug = 'vth-biodent' order by section;
-- select platform, sum(visits) from console_api.ai_visits_daily where brand_slug = 'vth-biodent' group by 1 order by 2 desc;
-- select count(*), count(perf) from console_api.page_tech where brand_slug = 'vitalsleep-clinic';
-- select count(*) from console_api.entity_graph_edges where brand_slug = 'vth-biodent';
