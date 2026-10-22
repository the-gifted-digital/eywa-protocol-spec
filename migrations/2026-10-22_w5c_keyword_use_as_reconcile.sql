-- W5c: keep seo_x_ads_keywords_contextual_master.keyword_use_as true to the pages
-- trg_sync_keyword_use_as runs on INSERT/UPDATE only, so deleting a page row
-- never released its keywords, and rows written before the trigger existed
-- were never set. Drift found 2026-10-22:
--   semantic_keyword but on no page   420  -> null
--   on a page as target, use_as null   29  -> target_keyword
--   on a page as semantic, null/'seo'   2  -> semantic_keyword
--   legacy '🟡 Used as Semantic', on no page 1 -> null
-- 'excluded' (212) is an operator decision and is never overwritten.

-- 1. One-time reconcile against the pages.
with truth as (
  select k.fingerprint,
         case
           when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint)
             then 'target_keyword'
           when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps))
             then 'semantic_keyword'
         end as want
  from public.seo_x_ads_keywords_contextual_master k
  where k.keyword_use_as is distinct from 'excluded'
)
update public.seo_x_ads_keywords_contextual_master k
set keyword_use_as = t.want
from truth t
where t.fingerprint = k.fingerprint
  and k.keyword_use_as is distinct from t.want;

-- 2. Release keywords when a page row is deleted.
create or replace function public.release_keyword_use_as_on_page_delete()
returns trigger
language plpgsql
as $$
begin
  update public.seo_x_ads_keywords_contextual_master k
  set keyword_use_as = case
    when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
    when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
  end
  where k.fingerprint = any(coalesce(OLD.semantic_keywords_fps, '{}') || OLD.target_keyword_fp)
    and k.keyword_use_as is distinct from 'excluded';
  return OLD;
end;
$$;

create trigger trg_release_keyword_use_as_on_delete
  after delete on public.seo_website_page_master
  for each row execute function public.release_keyword_use_as_on_page_delete();

comment on function public.release_keyword_use_as_on_page_delete() is
  'Companion to sync_keyword_use_as_on_page_write: recomputes keyword_use_as for a deleted page''s keywords (excluded is kept). 2026-10-22.';
