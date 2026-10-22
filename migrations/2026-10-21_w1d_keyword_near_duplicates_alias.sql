-- W1d (handover data-quality #3): near-duplicate keywords via entity aliases
-- v_keyword_near_duplicates only matched spelling (trigram > 0.72), so
-- Thai<->English pairs such as ผ่าตัดปลายราก / apicoectomy were missed.
-- Now a pair is also flagged when both keywords equal (after seo_kw_norm) the
-- name or an alias of the same entity. match_reason says which rule fired.
-- Same primary_entity_fp alone is NOT used: one entity legitimately owns many
-- intents (ราคา / คือ / รีวิว), which would flood the view.
--
-- seo_entity_graph.aliases is text in two formats today (116 rows as a
-- Postgres array literal '{a,"b c"}', 625 as 'a, b, c'). seo_entity_name_list()
-- reads both; normalising the column to text[] is a W3 follow-up.

create or replace function public.seo_entity_name_list(p_name text, p_aliases text)
returns text[]
language sql immutable
as $$
  select array_agg(distinct n) from (
    select p_name as n
    union all
    select btrim(a, ' "')
    from regexp_split_to_table(btrim(coalesce(p_aliases, ''), '{} '), '\s*,\s*') a
  ) x
  where n is not null and n <> '';
$$;

comment on function public.seo_entity_name_list(text, text) is
  'Entity name + aliases as text[]; accepts both alias formats in seo_entity_graph.aliases.';

create or replace view public.v_keyword_near_duplicates as
with entity_names as (
  select e.entity_fingerprint as entity_fp, seo_kw_norm(n) as name_norm
  from seo_entity_graph e
  cross join lateral unnest(seo_entity_name_list(e.entity_name, e.aliases)) n
), alias_hits as (
  select distinct k.brand, k.fingerprint, en.entity_fp
  from seo_x_ads_keywords_contextual_master k
  join entity_names en on en.name_norm = seo_kw_norm(k.keyword)
), pairs as (
  select a.brand, a.fingerprint as kw_a, b.fingerprint as kw_b,
         'trigram'::text as reason, null::text as entity_fp
  from seo_x_ads_keywords_contextual_master a
  join seo_x_ads_keywords_contextual_master b
    on a.brand = b.brand and a.fingerprint < b.fingerprint and a.keyword % b.keyword
  where similarity(a.keyword, b.keyword) > 0.72
  union all
  select a.brand, a.fingerprint, b.fingerprint, 'entity_alias', a.entity_fp
  from alias_hits a
  join alias_hits b
    on a.brand = b.brand and a.entity_fp = b.entity_fp and a.fingerprint < b.fingerprint
), grouped as (
  select brand, kw_a, kw_b,
         string_agg(distinct reason, '+') as match_reason,
         max(entity_fp) as entity_fp
  from pairs
  group by brand, kw_a, kw_b
)
select g.brand,
       g.kw_a,
       a.keyword as keyword_a,
       a.keyword_use_as as use_a,
       g.kw_b,
       b.keyword as keyword_b,
       b.keyword_use_as as use_b,
       round(similarity(a.keyword, b.keyword)::numeric, 3) as kw_similarity,
       (select p.sitemap_node_id from seo_website_page_master p where p.target_keyword_fp = g.kw_a) as page_a,
       (select p.sitemap_node_id from seo_website_page_master p where p.target_keyword_fp = g.kw_b) as page_b,
       g.match_reason,
       g.entity_fp
from grouped g
join seo_x_ads_keywords_contextual_master a on a.fingerprint = g.kw_a
join seo_x_ads_keywords_contextual_master b on b.fingerprint = g.kw_b;

comment on view public.v_keyword_near_duplicates is
  'Keyword pairs per brand that are near-duplicates by spelling (trigram > 0.72) and/or name the same entity (entity_alias). Handover data-quality #3, 2026-10-21.';
