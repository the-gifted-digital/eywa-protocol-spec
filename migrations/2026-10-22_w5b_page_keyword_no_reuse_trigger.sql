-- W5b (handover data-quality #8, step 3): block keyword reuse across pages
-- Apply ONLY after W5a, when v_page_keyword_conflicts returns 0 rows,
-- otherwise every later write to an existing conflicting page is rejected.
-- Per brand, a keyword may be the target OR a semantic keyword of exactly one
-- active page. Targets are already globally unique (uq_page_master_target_keyword_fp).
-- Merged/Dropped pages are not checked and must carry no semantic keywords.

create index if not exists idx_page_master_semantic_fps
  on public.seo_website_page_master using gin (semantic_keywords_fps);

create or replace function public.fn_enforce_page_keyword_no_reuse()
returns trigger
language plpgsql
as $$
declare
  hit text;
  other_page text;
begin
  if NEW.status in ('Merged', 'Dropped') then
    if cardinality(coalesce(NEW.semantic_keywords_fps, '{}')) > 0 then
      raise exception 'page %: % pages must not carry semantic keywords', NEW.page_fingerprint, NEW.status;
    end if;
    return NEW;
  end if;

  if cardinality(coalesce(NEW.semantic_keywords_fps, '{}')) = 0 and NEW.target_keyword_fp is null then
    return NEW;
  end if;

  -- own target repeated in own semantic list
  if NEW.target_keyword_fp = any(coalesce(NEW.semantic_keywords_fps, '{}')) then
    raise exception 'page %: target keyword % is also in its semantic_keywords_fps',
      NEW.page_fingerprint, NEW.target_keyword_fp;
  end if;

  -- duplicate inside the semantic list
  select s.fp into hit
  from unnest(NEW.semantic_keywords_fps) s(fp) group by s.fp having count(*) > 1 limit 1;
  if hit is not null then
    raise exception 'page %: semantic keyword % listed twice', NEW.page_fingerprint, hit;
  end if;

  -- semantic keyword is another page's target
  select s.fp, p.page_fingerprint into hit, other_page
  from unnest(coalesce(NEW.semantic_keywords_fps, '{}')) s(fp)
  join public.seo_website_page_master p on p.target_keyword_fp = s.fp
  where p.id <> NEW.id
  limit 1;
  if hit is not null then
    raise exception 'page %: semantic keyword % is the target of page %',
      NEW.page_fingerprint, hit, other_page;
  end if;

  -- semantic or target keyword already a semantic keyword of another active page (same brand)
  select p.page_fingerprint,
         (select x from unnest(p.semantic_keywords_fps) x
          where x = any(coalesce(NEW.semantic_keywords_fps, '{}') || NEW.target_keyword_fp) limit 1)
    into other_page, hit
  from public.seo_website_page_master p
  where p.id <> NEW.id
    and p.brand_id = NEW.brand_id
    and p.status not in ('Merged', 'Dropped')
    and p.semantic_keywords_fps && (coalesce(NEW.semantic_keywords_fps, '{}') || NEW.target_keyword_fp)
  limit 1;
  if other_page is not null then
    raise exception 'page %: keyword % is already a semantic keyword of page %',
      NEW.page_fingerprint, hit, other_page;
  end if;

  return NEW;
end;
$$;

-- ponytail: no lock, so two concurrent writes can still race the same keyword in;
-- re-check with v_page_keyword_conflicts after bulk imports.
create trigger trg_page_keyword_no_reuse
  before insert or update of target_keyword_fp, semantic_keywords_fps, status, brand_id
  on public.seo_website_page_master
  for each row execute function public.fn_enforce_page_keyword_no_reuse();

comment on function public.fn_enforce_page_keyword_no_reuse() is
  'One intent = one URL per brand: rejects a page write whose semantic/target keyword is already used by another active page. Handover data-quality #8, 2026-10-22.';
