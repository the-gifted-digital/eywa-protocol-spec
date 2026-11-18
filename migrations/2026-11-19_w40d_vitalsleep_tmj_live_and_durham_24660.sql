-- W40d · VitalSleep: tmj-awareness-month Planned → Live (WP post 29441) + 2 semantics + Durham 2015 bound to 24660 (DRAFT, not applied) · 2026-11-19
-- Source: brand session "การเชื่อมต่อ WordPress" 2026-11-19: post 29441 published 00:15 site time (live check 200, title, content, Valesan doi).
-- Semantics เดือนรณรงค์ tmj, สัญญาณเตือน tmj (queued W40c; ~0 volume; not in registry, held by no page; no GSC queries).
-- Durham 2015 BMJ (25767130, added W40c) is in 24660's reference list → bind to /temporomandibular-joint-jaw-gritted-teeth/ (post 24660,
-- confirmed in brand repo bruxism-round-2026-10-26.md row E).
-- WP id goes in reconciliation_notes (vitalsleep convention, as W39w); wpml_page_id is unused for this brand and left alone.
-- Brand session added inbound links from 24660, 27395, 23569, 23119 (picked up by the next crawl; not written here).
-- Run in the Supabase SQL editor as one transaction.

begin;

create temp table w40d_kw (kw text) on commit drop;
insert into w40d_kw values ('เดือนรณรงค์ tmj'), ('สัญญาณเตือน tmj');

-- 1 · registry rows for the semantics
insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::' || w.kw), w.kw, 'VitalSleep Clinic', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai',
       'Informational', 'Added 2026-11-19 W40d semantic for tmj-awareness-month (brand session, ~0 volume).'
  from w40d_kw w
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'VitalSleep Clinic' and kw_norm(k.keyword) = kw_norm(w.kw))
on conflict (fingerprint) do nothing; -- 2 rows

-- 2 · Planned → Live + semantics + WP id
update public.seo_website_page_master p
   set status = 'Live',
       published_date = '2026-11-19',
       semantic_keywords_fps = (select array_agg(distinct f) from unnest(coalesce(p.semantic_keywords_fps, '{}') ||
                                  (select array_agg(lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::' || kw)) from w40d_kw)) f),
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W40d 2026-11-19: published (WP post 29441), Planned → Live; +2 semantics'
 where brand_id = 'vitalsleep-clinic' and slug = 'tmj-awareness-month' and status = 'Planned'; -- 1 row

update public.seo_x_ads_keywords_contextual_master
   set keyword_use_as = 'semantic_keyword'
 where fingerprint in (select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::' || kw) from w40d_kw)
   and keyword_use_as is distinct from 'excluded'; -- 2 rows

-- 3 · Durham on 24660
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, 'supporting_evidence', 'references', 'active'
  from public.seo_website_page_master p, public.seo_citations c
 where p.brand_id = 'vitalsleep-clinic' and p.slug = 'temporomandibular-joint-jaw-gritted-teeth' and p.status = 'Live'
   and c.pubmed_pmid = '25767130'
on conflict (page_fp, citation_fp, citation_purpose) do nothing; -- 1 row

-- 4 · assert
do $$
begin
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'tmj-awareness-month'
                  and status = 'Live' and target_keyword_fp like '%::tmj awareness month' and array_length(semantic_keywords_fps, 1) = 2
                  and reconciliation_notes like '%post 29441%') then
    raise exception 'W40d: page not Live with 2 semantics';
  end if;
  if not exists (select 1 from public.seo_page_citations pc
                   join public.seo_website_page_master p on p.page_fingerprint = pc.page_fp
                   join public.seo_citations c on c.fingerprint = pc.citation_fp
                  where p.brand_id = 'vitalsleep-clinic' and p.slug = 'temporomandibular-joint-jaw-gritted-teeth'
                    and c.pubmed_pmid = '25767130' and pc.status = 'active') then
    raise exception 'W40d: Durham not bound to 24660';
  end if;
end $$;

commit;
