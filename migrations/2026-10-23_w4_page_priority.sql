-- W4 (handover data-quality #7): one priority score per live page
-- Operator-approved weights 2026-10-23. Each signal is turned into a within-brand percentile
-- (0..1, ties share a rank) so one outlier cannot dominate; a signal a brand has no data for at all
-- is left out and the remaining weights are rescaled to 100 — missing data never lowers a score.
-- Weights live in seo_priority_weights (brand_id '*' = default; a brand row overrides; highest active
-- version wins) so they can be re-tuned after the November measurement without code changes.
-- Signals (28-day window unless noted):
--   striking_impressions  GSC impressions while ranking 4–20                     -> push to page 1
--   ctr_gap               expected clicks (brand's own CTR-by-position curve, 90d) minus actual -> rewrite title/meta
--   organic_contacts      tsa_bond contacts whose entry channel is organic_search  -> money page: improve first
--   duplication           title near-duplicates + keyword near-duplicate pairs     -> merge or differentiate
--   orphan_risk           seo_website_page_master.orphan_risk_score               -> add internal links
--   weak_evidence         1 when the page cites no tier 1–3 source                 -> upgrade citations
--   ux_friction           Clarity quick-backs + dead clicks + rage clicks          -> fix landing UX
--   ai_visits             AI-agent retrievals (seo_ai_agent_visits)                -> template candidate, keep fresh
-- Product value weighting of contacts is left out until tsa_product_value holds real values
-- (all 35 rows are placeholders on 2026-10-23).

begin;

create table public.seo_priority_weights (
  brand_id   text not null default '*',
  signal     text not null check (signal in ('striking_impressions', 'ctr_gap', 'organic_contacts', 'duplication',
                                             'orphan_risk', 'weak_evidence', 'ux_friction', 'ai_visits')),
  weight     numeric not null check (weight >= 0),
  version    integer not null default 1,
  active     boolean not null default true,
  note       text,
  created_at timestamptz not null default now(),
  primary key (brand_id, signal, version)
);
alter table public.seo_priority_weights enable row level security;
create policy "authenticated_full_access" on public.seo_priority_weights for all to authenticated using (true) with check (true);

comment on table public.seo_priority_weights is
  'Weights for v_page_priority. brand_id ''*'' = default for every brand; a brand row overrides it. Highest active version per (brand, signal) wins.';

insert into public.seo_priority_weights (brand_id, signal, weight, version, note) values
  ('*', 'striking_impressions', 25, 1, 'approved 2026-10-23'),
  ('*', 'ctr_gap',              20, 1, 'approved 2026-10-23'),
  ('*', 'organic_contacts',     20, 1, 'approved 2026-10-23'),
  ('*', 'duplication',          10, 1, 'approved 2026-10-23'),
  ('*', 'orphan_risk',          10, 1, 'approved 2026-10-23'),
  ('*', 'weak_evidence',         5, 1, 'approved 2026-10-23'),
  ('*', 'ux_friction',           5, 1, 'approved 2026-10-23'),
  ('*', 'ai_visits',             5, 1, 'approved 2026-10-23');

-- Computing it scans 90 days of GSC (1.7M rows) and takes ~40 s, so it is materialized;
-- refresh_page_priority() rebuilds it (run daily after the GSC load, and after editing weights).
set local statement_timeout = '10min';

create materialized view public.mv_page_priority as
with pages as (
  select p.brand_id, p.brand_name, p.page_fingerprint, p.sitemap_node_id, p.slug, p.page_type, p.orphan_risk_score
  from seo_website_page_master p
  where p.status = 'Live'
), gsc as (
  select q.brand_id, q.page_slug, q.position, q.clicks, q.impressions, q.snapshot_date
  from seo_gsc_query_daily q
  where q.search_type = 'web' and q.snapshot_date >= current_date - 90
), curve as (   -- the brand's own CTR at each rounded position 1..20 over 90 days
  select brand_id, least(greatest(round(position), 1), 20) as pos,
         sum(clicks)::numeric / nullif(sum(impressions), 0) as ctr
  from gsc where position <= 20
  group by 1, 2
), gsc_page as (
  select g.brand_id, g.page_slug,
         sum(g.impressions) filter (where g.position between 4 and 20) as striking_impressions,
         greatest(sum(g.impressions * coalesce(c.ctr, 0)) filter (where g.position <= 20)
                  - sum(g.clicks) filter (where g.position <= 20), 0) as ctr_gap
  from gsc g
  left join curve c on c.brand_id = g.brand_id and c.pos = least(greatest(round(g.position), 1), 20)
  where g.snapshot_date >= current_date - 28
  group by 1, 2
), contacts as (
  select brand_id, entry_slug as slug, count(*) as organic_contacts
  from v_tsa_bond_enriched
  where entry_channel = 'organic_search' and created_at >= now() - interval '28 days' and entry_slug is not null
  group by 1, 2
), dup as (
  select brand_name, slug, count(*) as n from (
    select brand_name, slug_a as slug from v_page_title_near_duplicates
    union all select brand_name, slug_b from v_page_title_near_duplicates
  ) t group by 1, 2
), kwdup as (
  select brand, node, count(*) as n from (
    select brand, page_a as node from v_keyword_near_duplicates where page_a is not null and page_b is not null and page_a <> page_b
    union all
    select brand, page_b from v_keyword_near_duplicates where page_a is not null and page_b is not null and page_a <> page_b
  ) t group by 1, 2
), evidence as (
  select pc.page_fp, bool_or(c.citation_tier <= 3) as has_tier1_3
  from seo_page_citations pc join seo_citations c on c.fingerprint = pc.citation_fp
  where pc.status = 'active'
  group by 1
), clarity as (
  select brand_id, tsa_page_slug(regexp_replace(regexp_replace(url, '\?.*$', ''), '^https?://[^/]+', '')) as slug,
         sum(coalesce((metrics->>'subTotal')::numeric, 0)) as friction
  from seo_clarity_daily
  where snapshot_date >= current_date - 28 and metric_name in ('QuickbackClick', 'DeadClickCount', 'RageClickCount')
  group by 1, 2
), ai as (
  select brand_id, tsa_page_slug(regexp_replace(regexp_replace(visit_url, '\?.*$', ''), '^https?://[^/]+', '')) as slug,
         count(*) as visits
  from seo_ai_agent_visits
  where visited_at >= now() - interval '28 days'
  group by 1, 2
), raw as (
  select p.*,
         coalesce(gp.striking_impressions, 0)::numeric as striking_impressions,
         coalesce(gp.ctr_gap, 0)::numeric as ctr_gap,
         coalesce(ct.organic_contacts, 0)::numeric as organic_contacts,
         (coalesce(d.n, 0) + coalesce(kd.n, 0))::numeric as duplication,
         coalesce(p.orphan_risk_score, 0)::numeric as orphan_risk,
         case when coalesce(ev.has_tier1_3, false) then 0 else 1 end::numeric as weak_evidence,
         coalesce(cl.friction, 0)::numeric as ux_friction,
         coalesce(a.visits, 0)::numeric as ai_visits
  from pages p
  left join gsc_page gp on gp.brand_id = p.brand_id and gp.page_slug = p.slug
  left join contacts ct on ct.brand_id = p.brand_id and ct.slug = p.slug
  left join dup d on d.brand_name = p.brand_name and d.slug = p.slug
  left join kwdup kd on kd.brand = p.brand_name and kd.node = p.sitemap_node_id
  left join evidence ev on ev.page_fp = p.page_fingerprint
  left join clarity cl on cl.brand_id = p.brand_id and cl.slug = p.slug
  left join ai a on a.brand_id = p.brand_id and a.slug = p.slug
), long as (
  select r.brand_id, r.page_fingerprint, s.signal, s.val
  from raw r
  cross join lateral (values
    ('striking_impressions', r.striking_impressions), ('ctr_gap', r.ctr_gap), ('organic_contacts', r.organic_contacts),
    ('duplication', r.duplication), ('orphan_risk', r.orphan_risk), ('weak_evidence', r.weak_evidence),
    ('ux_friction', r.ux_friction), ('ai_visits', r.ai_visits)) s(signal, val)
), ranked as (
  select l.*,
         percent_rank() over (partition by l.brand_id, l.signal order by l.val) as pr,
         max(l.val) over (partition by l.brand_id, l.signal) > 0 as available
  from long l
), weights as (
  select distinct on (b.brand_id, w.signal) b.brand_id, w.signal, w.weight
  from (select distinct brand_id from pages) b
  join seo_priority_weights w on w.active and w.brand_id in (b.brand_id, '*')
  order by b.brand_id, w.signal, (w.brand_id = b.brand_id) desc, w.version desc
), scored as (
  select r.brand_id, r.page_fingerprint, r.signal, r.val, r.available, w.weight,
         case when not r.available or r.val <= 0 then 0::numeric
              when r.signal = 'weak_evidence' then 1::numeric   -- yes/no signal: a percentile of a flag means nothing
              else r.pr::numeric end as pr
  from ranked r join weights w on w.brand_id = r.brand_id and w.signal = r.signal
), agg as (
  select brand_id, page_fingerprint,
         round(100 * sum(weight * pr) filter (where available) / nullif(sum(weight) filter (where available), 0), 1) as score,
         (array_agg(signal order by weight * pr desc) filter (where available and pr > 0))[1:2] as top_signals,
         jsonb_object_agg(signal, jsonb_build_object('value', val, 'percentile', round(pr::numeric, 3), 'used', available)) as signals
  from scored group by 1, 2
)
select p.brand_id, p.page_fingerprint, p.sitemap_node_id, p.slug, p.page_type,
       a.score, a.top_signals,
       case a.top_signals[1]
         when 'striking_impressions' then 'push to page 1: strengthen content for the queries ranking 4–20'
         when 'ctr_gap'              then 'rewrite title and meta description'
         when 'organic_contacts'     then 'money page: improve first'
         when 'duplication'          then 'merge or differentiate overlapping pages'
         when 'orphan_risk'          then 'add internal links'
         when 'weak_evidence'        then 'upgrade citations to tier 1–3'
         when 'ux_friction'          then 'fix landing UX (quick-backs, dead/rage clicks)'
         when 'ai_visits'            then 'template candidate: keep fresh'
       end as suggested_action,
       a.signals,
       now() as refreshed_at
from pages p join agg a on a.brand_id = p.brand_id and a.page_fingerprint = p.page_fingerprint;

create unique index uq_mv_page_priority on public.mv_page_priority (page_fingerprint);

create view public.v_page_priority as select * from public.mv_page_priority;

create or replace function public.refresh_page_priority()
returns void
language plpgsql
set statement_timeout = '10min'
as $$
begin
  refresh materialized view concurrently public.mv_page_priority;
end;
$$;

comment on function public.refresh_page_priority() is
  'Rebuilds mv_page_priority (~40 s). Run daily after the GSC load and after any change to seo_priority_weights.';

comment on view public.v_page_priority is
  'One priority score (0–100) per Live page from 8 signals, within-brand percentiles, weights from seo_priority_weights; signals a brand has no data for are excluded and weights rescaled. Handover data-quality #7, 2026-10-23.';

commit;
