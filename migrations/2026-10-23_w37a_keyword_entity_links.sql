-- W3.4a (handover data-quality #2): keyword -> entity links, mechanical part
-- Table: seo_x_ads_keywords_contextual_master.primary_entity_fp (no FK) + primary_entity_name (cached copy).
-- 1. Broken links (14): keyword points at a Merged entity, a fingerprint that does not exist, or a Dropped entity.
--    Merged/missing -> the live entity that holds the concept; Dropped -> NULL (the concept left the graph on purpose).
-- 2. Exact-name links (194): unlinked keywords whose normalised text equals exactly ONE live entity's name or alias,
--    within that entity's brand_scope ('*' or the keyword's brand). Ambiguous matches are skipped.
-- 3. primary_entity_name becomes a maintained copy of seo_entity_graph.entity_name (DR-050: one store per fact;
--    the column stays because the Notion sync and brand SQL read it). ~1.4k stale rows synced, then two triggers
--    keep it in step: on the keyword when primary_entity_fp changes, on the entity when entity_name changes.
-- Judgement cases (keyword text names entity X but links Y; target keyword vs page entity) are W3.4b, a separate file.
-- Excludes brand 'VitalSleep and Wellness' (out of scope).

begin;

create table public.bak_w37a_20261023 as
select fingerprint, brand, primary_entity_fp, primary_entity_name, now() as backed_up_at
  from public.seo_x_ads_keywords_contextual_master
 where brand <> 'VitalSleep and Wellness'
   and (primary_entity_fp is not null or primary_entity_name is not null);

-- 1 · broken links
update public.seo_x_ads_keywords_contextual_master set primary_entity_fp = 'full-mouth-rehab'
 where primary_entity_fp = 'full-mouth-restoration' and brand <> 'VitalSleep and Wellness'; -- merged into full-mouth-rehab in W3.1 (2 rows)
update public.seo_x_ads_keywords_contextual_master set primary_entity_fp = 'multiple-implant'
 where primary_entity_fp = 'multiple-implants' and brand <> 'VitalSleep and Wellness'; -- fingerprint never existed; the live entity is multiple-implant (4 rows)
update public.seo_x_ads_keywords_contextual_master set primary_entity_fp = null
 where primary_entity_fp in ('civil-servant-dental-benefit', 'dental-tax-deduction-th', 'universal-coverage-th')
   and brand <> 'VitalSleep and Wellness'; -- Dropped entities (8 rows)

-- 2 · exact-name links
with bm as (
  select distinct brand_id, brand_name from public.seo_website_page_master
), en as (
  select e.entity_fingerprint as fp, e.brand_scope, seo_kw_norm(n) as nn
    from public.seo_entity_graph e
   cross join lateral unnest(seo_entity_name_list(e.entity_name, e.aliases)) n
   where lower(coalesce(e.entity_lifecycle, '')) not in ('merged', 'dropped')
), hit as (
  select k.fingerprint, array_agg(distinct en.fp) as fps
    from public.seo_x_ads_keywords_contextual_master k
    left join bm on bm.brand_name = k.brand
    join en on en.nn = seo_kw_norm(k.keyword)
           and ('*' = any(en.brand_scope) or bm.brand_id = any(en.brand_scope))
   where k.primary_entity_fp is null and k.brand <> 'VitalSleep and Wellness'
   group by k.fingerprint
)
update public.seo_x_ads_keywords_contextual_master k
   set primary_entity_fp = h.fps[1]
  from hit h
 where h.fingerprint = k.fingerprint and cardinality(h.fps) = 1 and k.primary_entity_fp is null;

-- 3 · primary_entity_name = entity_name
update public.seo_x_ads_keywords_contextual_master k
   set primary_entity_name = g.entity_name
  from public.seo_entity_graph g
 where g.entity_fingerprint = k.primary_entity_fp
   and k.primary_entity_name is distinct from g.entity_name
   and k.brand <> 'VitalSleep and Wellness';
update public.seo_x_ads_keywords_contextual_master
   set primary_entity_name = null
 where primary_entity_fp is null and primary_entity_name is not null
   and brand <> 'VitalSleep and Wellness';

create or replace function public.fn_keyword_entity_name()
returns trigger language plpgsql as $$
begin
  new.primary_entity_name := (select g.entity_name from public.seo_entity_graph g
                               where g.entity_fingerprint = new.primary_entity_fp);
  return new;
end $$;

create trigger trg_keyword_entity_name
before insert or update of primary_entity_fp, primary_entity_name on public.seo_x_ads_keywords_contextual_master
for each row execute function public.fn_keyword_entity_name();

create or replace function public.fn_entity_name_to_keywords()
returns trigger language plpgsql as $$
begin
  update public.seo_x_ads_keywords_contextual_master
     set primary_entity_name = new.entity_name
   where primary_entity_fp = new.entity_fingerprint;
  return null;
end $$;

create trigger trg_entity_name_to_keywords
after update of entity_name on public.seo_entity_graph
for each row when (old.entity_name is distinct from new.entity_name)
execute function public.fn_entity_name_to_keywords();

-- 4 · assertions
do $$
declare n_broken int; n_drift int; n_exact_left int;
begin
  select count(*) into n_broken
    from public.seo_x_ads_keywords_contextual_master k
    left join public.seo_entity_graph g on g.entity_fingerprint = k.primary_entity_fp
   where k.primary_entity_fp is not null and k.brand <> 'VitalSleep and Wellness'
     and (g.entity_fingerprint is null or lower(coalesce(g.entity_lifecycle, '')) in ('merged', 'dropped'));
  select count(*) into n_drift
    from public.seo_x_ads_keywords_contextual_master k
    left join public.seo_entity_graph g on g.entity_fingerprint = k.primary_entity_fp
   where k.brand <> 'VitalSleep and Wellness' and k.primary_entity_name is distinct from g.entity_name;
  if n_broken <> 0 or n_drift <> 0 then
    raise exception 'w37a assertion failed: broken=% name_drift=%', n_broken, n_drift;
  end if;
end $$;

commit;
