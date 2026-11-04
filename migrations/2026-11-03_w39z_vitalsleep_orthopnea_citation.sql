-- W39z · VitalSleep /shortness-of-breath-dyspnea-dyspnea-causes/ orthopnea add: 1 new citation + 1 binding (DRAFT, not applied) · 2026-11-03
-- Source: brand session "การเชื่อมต่อ WordPress" W44-D intake (user-approved there) + TSV
-- content/consolidation/vitalsleep-citations-2026-11-03-orthopnea.tsv (1 row, PubMed+Crossref round-trip; authors/language from esummary).
-- Wang 2005 JAMA 16234501: PubMed pubtype only "Review" → abstract read: MEDLINE search, 2 independent abstractors, pooled LRs → SR, T1 kept.
-- Keyword orthopnea คือ (Semrush 1,900) is NOT written here (semantic round ~11-10): not in the registry, held by no page; GSC 90d 4 impr on
-- snoring-treatment-cpap p29 only → no conflict. Page keeps its target หายใจไม่อิ่ม.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create temp table w39p_cite (title text, authors text[], yr smallint, pmid text, doi text, url text, journal text,
                             tier smallint, ctype text, stype text, lang text, slug text, note text) on commit drop;
create temp table w39p_bind (slug text, pmid text, purpose text) on commit drop;

insert into w39p_cite values
('Does this dyspneic patient in the emergency department have congestive heart failure?', array['Wang CS','FitzGerald JM','Schulzer M','Mak E','Ayas NT']::text[], 2005, '16234501', '10.1001/jama.294.15.1944', 'https://doi.org/10.1001/jama.294.15.1944', 'JAMA', 1, 'systematic_review', 'systematic_review', 'en', 'wang-2005-pmid16234501', 'tier_source=title+abstract-read (MEDLINE search, 2 independent abstractors, pooled LRs); locator PASS PASS');

-- binds (page slug, pmid, purpose)
insert into w39p_bind values
('shortness-of-breath-dyspnea-dyspnea-causes','16234501','supporting_evidence');
-- 1 · new citations (skip any pmid/doi already in the pool)
insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
                                  citation_type, study_type, language_code, is_thai_specific, brand_scope, verification_status,
                                  last_verified_at, load_from, load_source, maintenance_log)
select c.slug, c.title, c.authors, c.yr, c.pmid, c.doi, c.url, c.journal, c.tier, c.ctype, c.stype, c.lang, false, array['*'], 'verified',
       now(), 'vitalsleep-clinic', 'vitalsleep-clinic:citation intake 2026-11-03 orthopnea (PubMed+Crossref round-trip by WP session)', c.note
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
  if n_cite <> 1 then raise exception 'W39z: expected 1 verified citation, got %', n_cite; end if;
  select count(*) into n_bind from w39p_bind b
    join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
    join public.seo_citations c on c.pubmed_pmid = b.pmid
    join public.seo_page_citations pc on pc.page_fp = p.page_fingerprint and pc.citation_fp = c.fingerprint and pc.citation_purpose = b.purpose;
  if n_bind <> 1 then raise exception 'W39z: expected 1 binding, got %', n_bind; end if;
end $$;

commit;
