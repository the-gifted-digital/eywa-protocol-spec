-- K6b · plan_pages + sitemap_section (applied 2026-10-29) · 2026-10-29
-- The Sitemap view groups pages by the plan's sitemap sections (1 Home … 9 Local). Same view as K5a with one
-- column appended at the end (create or replace allows that). No data change.

begin;

create or replace view console_api.plan_pages as
with pg as (
  select p.*, coalesce(nullif(p.slug, ''), 'home') as slug_n
    from public.seo_website_page_master p
   where p.brand_id in (select console.readable_brands())
), qb as (
  select brand_slug, page_slug, count(*) as queries,
         count(*) filter (where position <= 3) as q1_3, count(*) filter (where position > 3 and position <= 10) as q4_10,
         count(*) filter (where position > 10 and position <= 20) as q11_20, count(*) filter (where position > 20) as q21p
    from console.mv_page_query_28d
   where brand_slug in (select console.readable_brands())
   group by 1, 2
)
select pg.fingerprint as page_fp, pg.page_fingerprint as page_code, pg.brand_id as brand_slug, pg.slug, pg.page_name,
       pg.status, pg.page_category, pg.page_type, pg.node_tier, pg.page_role, pg.funnel_stage, pg.priority,
       pg.parent_page_fp as parent_code, pg.cluster_id, coalesce(c.cluster_name, pg.cluster_id) as cluster_name,
       pm.product_line, pg.primary_entity_fp, pg.primary_entity_name, pg.published_date,
       pg.target_keyword_fp, split_part(pg.target_keyword_fp, '::', 4) as target_keyword,
       coalesce(cardinality(pg.semantic_keywords_fps), 0) as semantic_kw_count,
       kp.volume as target_volume, kr.rank_now as target_rank, kr.rank_prev as target_rank_prev,
       kr.page_slug as target_ranking_slug,
       g.clicks_28d, g.clicks_prev_28d, g.impressions_28d, g.impressions_prev_28d, g.position_28d,
       qb.queries, qb.q1_3, qb.q4_10, qb.q11_20, qb.q21p,
       ga.organic_sessions_28d, ga.organic_sessions_prev_28d, ga.organic_key_events_28d, ga.organic_engagement_rate,
       h.issues,
       pg.sitemap_section
  from pg
  left join public.seo_topic_cluster_master c on c.cluster_slug = pg.cluster_id
  left join public.tsa_product_map pm on pm.brand_id = pg.brand_id and pm.cluster_id = pg.cluster_id
  left join console.mv_keyword_pool kp on kp.brand_slug = pg.brand_id and kp.keyword_fp = pg.target_keyword_fp
  left join console.mv_keyword_rank_28d kr on kr.brand_slug = pg.brand_id and kr.keyword_fp = pg.target_keyword_fp
  left join console.mv_page_gsc_28d g on g.brand_id = pg.brand_id and g.page_slug = pg.slug_n
  left join qb on qb.brand_slug = pg.brand_id and qb.page_slug = pg.slug_n
  left join console.mv_page_ga4_28d ga on ga.brand_slug = pg.brand_id and ga.page_slug = pg.slug_n
  left join console.page_health_all h on h.page_fp = pg.fingerprint;

commit;

-- Verify (read-only, signed-in user): select sitemap_section, count(*) from console_api.plan_pages where brand_slug = 'vth-biodent' group by 1 order by 1;
