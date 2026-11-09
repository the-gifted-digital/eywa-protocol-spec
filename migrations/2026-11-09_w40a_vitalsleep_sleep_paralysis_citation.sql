-- W40a · VitalSleep /sleeptest-health-sleep-apnea/ (post 25663) ผีอำ gap-fill: 1 new citation + 1 binding (DRAFT, not applied) · 2026-11-09
-- Source: brand session "การเชื่อมต่อ WordPress" intake + TSV content/rewrites/sleep-paralysis-gapfill-2026-11-09.tsv (additive edits, not on site yet).
-- Cheyne 1999 Conscious Cogn 10487786: pubtype "Journal Article"; abstract read: 3-factor model (Intruder/Incubus/Unusual bodily) tested on
-- several large questionnaire samples → cross_sectional T5 (pool convention, 41/42 cross_sectional rows are T5).
-- The 6 ผีอำ keywords (โดนผีอํารู้สึกยังไง, ผีอํารู้สึกยังไง, ผีอํามีจริงไหม, ผี อํามีจริง ไหม, ผีอำ ความเชื่อ โบราณ, ผีอํา ทางวิทยาศาสตร์) are NOT
-- written here (semantic round ~11-10): none in the registry, held by no page; GSC 90d all ผีอ* queries land on this page only → no conflict.
-- Page keeps its target อาการผีอำ.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create temp table w39p_cite (title text, authors text[], yr smallint, pmid text, doi text, url text, journal text,
                             tier smallint, ctype text, stype text, lang text, slug text, note text) on commit drop;
create temp table w39p_bind (slug text, pmid text, purpose text) on commit drop;

insert into w39p_cite values
('Hypnagogic and hypnopompic hallucinations during sleep paralysis: neurological and cultural construction of the night-mare', array['Cheyne JA','Rueffer SD','Newby-Clark IR']::text[], 1999, '10487786', '10.1006/ccog.1999.0404', 'https://doi.org/10.1006/ccog.1999.0404', 'Consciousness and Cognition', 5, 'cross_sectional', 'cross_sectional', 'en', 'cheyne-1999-pmid10487786', 'tier_source=title+abstract-read (3-factor structural model tested on several large questionnaire samples); verified PubMed 2026-11-09 by WP session');

-- binds (page slug, pmid, purpose)
insert into w39p_bind values
('sleeptest-health-sleep-apnea','10487786','supporting_evidence');
-- 1 · new citations (skip any pmid/doi already in the pool)
insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
                                  citation_type, study_type, language_code, is_thai_specific, brand_scope, verification_status,
                                  last_verified_at, load_from, load_source, maintenance_log)
select c.slug, c.title, c.authors, c.yr, c.pmid, c.doi, c.url, c.journal, c.tier, c.ctype, c.stype, c.lang, false, array['*'], 'verified',
       now(), 'vitalsleep-clinic', 'vitalsleep-clinic:citation intake 2026-11-09 sleep paralysis (PubMed+Crossref round-trip by WP session)', c.note
  from w39p_cite c
 where not exists (select 1 from public.seo_citations x where x.pubmed_pmid = c.pmid or (c.doi is not null and lower(x.doi) = c.doi)); -- 1 row

-- 2 · bindings
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, b.purpose, 'references', 'active'
  from w39p_bind b
  join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
  join public.seo_citations c on c.pubmed_pmid = b.pmid
on conflict (page_fp, citation_fp, citation_purpose) do nothing; -- 1 row

-- 3 · assert
do $$
declare n_cite int; n_bind int;
begin
  select count(*) into n_cite from w39p_cite w join public.seo_citations c on c.pubmed_pmid = w.pmid and c.verification_status = 'verified';
  if n_cite <> 1 then raise exception 'W40a: expected 1 verified citation, got %', n_cite; end if;
  select count(*) into n_bind from w39p_bind b
    join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
    join public.seo_citations c on c.pubmed_pmid = b.pmid
    join public.seo_page_citations pc on pc.page_fp = p.page_fingerprint and pc.citation_fp = c.fingerprint and pc.citation_purpose = b.purpose;
  if n_bind <> 1 then raise exception 'W40a: expected 1 binding, got %', n_bind; end if;
end $$;

commit;
