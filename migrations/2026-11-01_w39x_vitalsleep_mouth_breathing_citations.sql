-- W39x · VitalSleep /sleep-snoring-treatment/ mouth-breathing section: 4 new citations + 4 bindings (DRAFT, not applied) · 2026-11-01
-- Source: brand session "การเชื่อมต่อ WordPress" P4 intake (section on existing post 25323, no new page) + TSV
-- content/consolidation/vitalsleep-citations-2026-11-01-mouth-breathing.tsv (4 rows, PubMed+Crossref round-trip; authors/language from esummary).
-- None of the 4 is in the pool. Tier check: Alshehri 42662994 PubMed pubtype only "Review" → abstract read: systematic search of 5 DBs +
-- meta-analysis on nasal obstruction → T1 kept. Hsu 32473063 sent as "observational" (not in citation_type list) → cross_sectional, T5 kept.
-- Keywords NOT written here (semantic round ~11-10): หายใจทางปาก, นอนหายใจทางปาก, หายใจทางปากตอนนอน, นอนกรนหายใจทางปาก,
-- หายใจทางปากตลอด. None is in the registry or held by any page; page keeps its target นอนกรนเกิดจาก.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create temp table w39p_cite (title text, authors text[], yr smallint, pmid text, doi text, url text, journal text,
                             tier smallint, ctype text, stype text, lang text, slug text, note text) on commit drop;
create temp table w39p_bind (slug text, pmid text, purpose text) on commit drop;

insert into w39p_cite values
('Effect of nasal or oral breathing route on upper airway resistance during sleep.', array['Fitzpatrick MF','McLean H','Urton AM','Tan A','O''Donnell D','Driver HS']::text[], 2003, '14621092', '10.1183/09031936.03.00047903', 'https://doi.org/10.1183/09031936.03.00047903', 'The European respiratory journal', 2, 'rct', 'randomized_controlled_trial', 'en', 'fitzpatrick-2003-pmid14621092', 'tier_source=pubtype; locator PASS PASS'),
('Impact of Nasal Obstruction and Mouth Taping on Sleep Apnea Indicators: Systematic Review and Meta-Analysis.', array['Alshehri NA','Alsaif NF','Abdulrazaq AN','Jabor RM','Al-Sayed AA']::text[], 2026, '42662994', '10.1002/oto2.70294', 'https://doi.org/10.1002/oto2.70294', 'OTO open', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'alshehri-2026-pmid42662994', 'tier_source=title+abstract-read (systematic search 5 DBs, MA on nasal obstruction); locator PASS PASS'),
('Breaking social media fads and uncovering the safety and efficacy of mouth taping in patients with mouth breathing, sleep disordered breathing, or obstructive sleep apnea: A systematic review.', array['Rhee J','Iansavitchene A','Mannala S','Graham ME','Rotenberg B']::text[], 2025, '40397877', '10.1371/journal.pone.0323643', 'https://doi.org/10.1371/journal.pone.0323643', 'PloS one', 1, 'systematic_review', 'systematic_review', 'en', 'rhee-2025-pmid40397877', 'tier_source=pubtype; locator PASS PASS'),
('Association Between Breathing Route, Oxygen Desaturation, and Upper Airway Morphology.', array['Hsu YB','Lan MY','Huang YC','Kao MC','Lan MC']::text[], 2021, '32473063', '10.1002/lary.28774', 'https://doi.org/10.1002/lary.28774', 'The Laryngoscope', 5, 'cross_sectional', 'cross_sectional', 'en', 'hsu-2021-pmid32473063', 'tier_source=pubtype; locator PASS PASS');

-- binds (page slug, pmid, purpose)
insert into w39p_bind values
('sleep-snoring-treatment','14621092','supporting_evidence'),
('sleep-snoring-treatment','42662994','supporting_evidence'),
('sleep-snoring-treatment','40397877','supporting_evidence'),
('sleep-snoring-treatment','32473063','supporting_evidence');

-- 1 · new citations (skip any pmid/doi already in the pool)
insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
                                  citation_type, study_type, language_code, is_thai_specific, brand_scope, verification_status,
                                  last_verified_at, load_from, load_source, maintenance_log)
select c.slug, c.title, c.authors, c.yr, c.pmid, c.doi, c.url, c.journal, c.tier, c.ctype, c.stype, c.lang, false, array['*'], 'verified',
       now(), 'vitalsleep-clinic', 'vitalsleep-clinic:citation intake 2026-11-01 mouth-breathing (PubMed+Crossref round-trip by WP session)', c.note
  from w39p_cite c
 where not exists (select 1 from public.seo_citations x where x.pubmed_pmid = c.pmid or (c.doi is not null and lower(x.doi) = c.doi)); -- 4 rows

-- 2 · bindings
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, b.purpose, 'references', 'active'
  from w39p_bind b
  join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
  join public.seo_citations c on c.pubmed_pmid = b.pmid
on conflict (page_fp, citation_fp, citation_purpose) do nothing; -- 4 rows

-- 3 · assert
do $$
declare n_cite int; n_bind int;
begin
  select count(*) into n_cite from w39p_cite w join public.seo_citations c on c.pubmed_pmid = w.pmid and c.verification_status = 'verified';
  if n_cite <> 4 then raise exception 'W39x: expected 4 verified citations, got %', n_cite; end if;
  select count(*) into n_bind from w39p_bind b
    join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
    join public.seo_citations c on c.pubmed_pmid = b.pmid
    join public.seo_page_citations pc on pc.page_fp = p.page_fingerprint and pc.citation_fp = c.fingerprint and pc.citation_purpose = b.purpose;
  if n_bind <> 4 then raise exception 'W39x: expected 4 bindings, got %', n_bind; end if;
end $$;

commit;
