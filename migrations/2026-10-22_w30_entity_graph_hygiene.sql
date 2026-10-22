-- W3.0: seo_entity_graph hygiene before dedupe (DR-078)
-- 1. aliases: one format. The column stays TEXT, holding a comma-separated list
--    ("a, b, c"), because readers take it as a string: the n8n Supabase->Notion
--    sync writes it straight into a rich_text property, and brand SQL splits it
--    with string_to_array(aliases, ','). Converting to text[] would break both.
--    116 rows were stored as a Postgres array literal '{a,"b c"}', 3 mixed both
--    formats, 7 carried stray quotes. A CHECK keeps the format from coming back.
-- 2. entity_lifecycle: one casing. Values were Mature/mature, Growing/growing,
--    Emerging/emerging, merged, dropped. Title case wins (it is the Notion select
--    name and the majority for Mature); a BEFORE trigger normalises any casing a
--    script writes, so existing scripts that set 'merged' keep working.
-- 3. Two active related_to edges point at entities marked dropped (no canonical
--    to repoint to) -> status 'deprecated'.
-- Backup: bak_entity_graph_w30_20261022. Rollback in the table comment.

begin;

create table public.bak_entity_graph_w30_20261022 as
select entity_fingerprint, aliases, entity_lifecycle, now() as backed_up_at
from public.seo_entity_graph;

alter table public.bak_entity_graph_w30_20261022 enable row level security;

comment on table public.bak_entity_graph_w30_20261022 is
  'W3.0 backup (2026-10-22). Rollback: alter table seo_entity_graph drop constraint chk_entity_aliases_plain_list, drop constraint chk_entity_lifecycle; drop trigger trg_normalise_entity_lifecycle on seo_entity_graph; update seo_entity_graph g set aliases = b.aliases, entity_lifecycle = b.entity_lifecycle from bak_entity_graph_w30_20261022 b where b.entity_fingerprint = g.entity_fingerprint;';

-- 1. aliases -> "a, b, c" (first occurrence order, duplicates and blanks dropped)
update public.seo_entity_graph g
set aliases = x.plain
from (
  select e.entity_fingerprint,
         (select string_agg(a, ', ' order by first_pos)
          from (
            select btrim(s.part, E' \t\n"') as a, min(s.pos) as first_pos
            from regexp_split_to_table(translate(e.aliases, '{}', ',,'), ',') with ordinality as s(part, pos)
            where btrim(s.part, E' \t\n"') <> ''
            group by btrim(s.part, E' \t\n"')
          ) parts) as plain
  from public.seo_entity_graph e
  where e.aliases ~ '[{}"]'
) x
where x.entity_fingerprint = g.entity_fingerprint;

alter table public.seo_entity_graph
  add constraint chk_entity_aliases_plain_list check (aliases is null or aliases !~ '[{}"]');

comment on column public.seo_entity_graph.aliases is
  'Comma-separated plain list: "alias one, alias two". No braces or quotes (chk_entity_aliases_plain_list). Read as a list with seo_entity_name_list(entity_name, aliases). DR-078.';

-- 2. entity_lifecycle -> Title case, enforced
update public.seo_entity_graph
set entity_lifecycle = initcap(lower(btrim(entity_lifecycle)))
where entity_lifecycle is distinct from initcap(lower(btrim(entity_lifecycle)));

create or replace function public.fn_normalise_entity_lifecycle()
returns trigger
language plpgsql
as $$
begin
  if NEW.entity_lifecycle is not null then
    NEW.entity_lifecycle := initcap(lower(btrim(NEW.entity_lifecycle)));
  end if;
  return NEW;
end;
$$;

create trigger trg_normalise_entity_lifecycle
  before insert or update of entity_lifecycle on public.seo_entity_graph
  for each row execute function public.fn_normalise_entity_lifecycle();

alter table public.seo_entity_graph
  add constraint chk_entity_lifecycle
  check (entity_lifecycle is null or entity_lifecycle in ('Emerging', 'Growing', 'Mature', 'Merged', 'Dropped'));

-- 3. edges that still point at dropped entities
update public.seo_entity_relationships r
set status = 'deprecated',
    edge_note = concat_ws(E'\n', r.edge_note, '[W3.0 2026-10-22] deprecated: endpoint entity is Dropped')
where r.status = 'active'
  and exists (select 1 from public.seo_entity_graph g
              where g.entity_fingerprint in (r.from_entity_fp, r.to_entity_fp)
                and g.entity_lifecycle in ('Merged', 'Dropped'));

commit;
