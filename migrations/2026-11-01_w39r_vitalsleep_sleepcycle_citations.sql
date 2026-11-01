-- W39r · VitalSleep citation intake for /sleep-cycle-sleep-schedule/: 5 new citations + 7 bindings (DRAFT, not applied) · 2026-11-01
-- Source: brand session "การเชื่อมต่อ WordPress" TSV content/consolidation/vitalsleep-citations-2026-11-01-sleepcycle.tsv (7 rows, all
-- locator PASS; title/journal/year from PubMed). Authors and language from PubMed esummary 2026-11-01. Same shape as W39p.
-- Already in the pool (bound only, pool row unchanged): 26039963 Watson 2015 (T6) and 27250809 Paruthi 2016 AASM pediatric
-- recommendations — the brand sent it as new T6; the pool holds it as clinical_guideline T3 since earlier, so it binds as guideline_reference.
-- Human check requested on 42485698 Amicucci 2026 (abstract read 2026-11-01): "56 entries identified from >11,000 records synthesized into
-- five sections" — no databases, eligibility criteria, appraisal or pooling stated; thematic narrative synthesis → narrative_review,
-- expert_opinion, T6 (the brand's fallback; DR-063 conduct rule). Other tiers as sent. The page (Planned since W39p) stays Planned.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create temp table w39p_cite (title text, authors text[], yr smallint, pmid text, doi text, url text, journal text,
                             tier smallint, ctype text, stype text, lang text, slug text, note text) on commit drop;
create temp table w39p_bind (slug text, pmid text, purpose text) on commit drop;

insert into w39p_cite values
('Meta-analysis of quantitative sleep parameters from childhood to old age in healthy individuals: developing normative sleep values across the human lifespan.', array['Ohayon MM','Carskadon MA','Guilleminault C','Vitiello MV']::text[], 2004, '15586779', '10.1093/sleep/27.7.1255', 'https://pubmed.ncbi.nlm.nih.gov/15586779/', 'Sleep', 1, 'meta_analysis', 'meta_analysis', 'en', 'ohayon-2004-pmid15586779', 'tier_source=pubtype; locator PASS PASS'),
('National Sleep Foundation''s sleep time duration recommendations: methodology and results summary.', array['Hirshkowitz M','Whiton K','Albert SM','Alessi C','Bruni O','DonCarlos L','Hazen N','Herman J','Katz ES','Kheirandish-Gozal L','Neubauer DN','O''Donnell AE','Ohayon M','Peever J','Rawding R','Sachdeva RC','Setters B','Vitiello MV','Ware JC','Adams Hillard PJ']::text[], 2015, '29073412', '10.1016/j.sleh.2014.12.010', 'https://pubmed.ncbi.nlm.nih.gov/29073412/', 'Sleep health', 6, 'expert_opinion', 'consensus_statement', 'en', 'hirshkowitz-2015-pmid29073412', 'tier_source=abstract-read (pubtype only Journal Article; RAND/UCLA expert panel); locator PASS PASS'),
('Sleep architecture impairment and cognitive performance in obstructive sleep apnea phenotypes and the effects of CPAP treatment.', array['Amicucci G','Tondo P','Mogavero MP','Vacca M','Ferri R','Ferini-Strambi L','Liguori C']::text[], 2026, '42485698', '10.1016/j.smrv.2026.102346', 'https://pubmed.ncbi.nlm.nih.gov/42485698/', 'Sleep medicine reviews', 6, 'expert_opinion', 'narrative_review', 'en', 'amicucci-2026-pmid42485698', 'tier_source=abstract-read (operator session: no search/appraisal method, narrative synthesis); locator PASS PASS'),
('Sleep regularity is a stronger predictor of mortality risk than sleep duration: A prospective cohort study.', array['Windred DP','Burns AC','Lane JM','Saxena R','Rutter MK','Cain SW','Phillips AJK']::text[], 2024, '37738616', '10.1093/sleep/zsad253', 'https://pubmed.ncbi.nlm.nih.gov/37738616/', 'Sleep', 5, 'cohort_study', 'prospective_cohort', 'en', 'windred-2024-pmid37738616', 'tier_source=abstract-read (UK Biobank prospective cohort); locator PASS PASS'),
('Physiology, Sleep Stages', array['Patel AK','Reddy V','Shumway KR','Araujo JF']::text[], 2024, '30252388', null, 'https://www.ncbi.nlm.nih.gov/books/NBK526132/', 'StatPearls', 6, 'textbook', 'textbook', 'en', 'patel-2024-pmid30252388', 'tier_source=pubtype Study Guide (StatPearls NBK526132); locator PASS PASS');

-- binds (page slug, pmid, purpose)
insert into w39p_bind values
('sleep-cycle-sleep-schedule','15586779','supporting_evidence'),
('sleep-cycle-sleep-schedule','29073412','supporting_evidence'),
('sleep-cycle-sleep-schedule','27250809','guideline_reference'),
('sleep-cycle-sleep-schedule','42485698','supporting_evidence'),
('sleep-cycle-sleep-schedule','37738616','supporting_evidence'),
('sleep-cycle-sleep-schedule','30252388','supporting_evidence'),
('sleep-cycle-sleep-schedule','26039963','supporting_evidence');

-- 1 · new citations (skip any pmid/doi already in the pool)
insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
                                  citation_type, study_type, language_code, is_thai_specific, brand_scope, verification_status,
                                  last_verified_at, load_from, load_source, maintenance_log)
select c.slug, c.title, c.authors, c.yr, c.pmid, c.doi, c.url, c.journal, c.tier, c.ctype, c.stype, c.lang, false, array['*'], 'verified',
       now(), 'vitalsleep-clinic', 'vitalsleep-clinic:citation intake 2026-11-01 sleep-cycle (PubMed+Crossref round-trip by WP session)', c.note
  from w39p_cite c
 where not exists (select 1 from public.seo_citations x where x.pubmed_pmid = c.pmid or (c.doi is not null and lower(x.doi) = c.doi)); -- 5 rows

-- 2 · bindings
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, b.purpose, 'references', 'active'
  from w39p_bind b
  join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
  join public.seo_citations c on c.pubmed_pmid = b.pmid
on conflict (page_fp, citation_fp, citation_purpose) do nothing; -- 7 rows

-- 3 · assert
do $$
declare n_cite int; n_bind int;
begin
  select count(*) into n_cite from w39p_cite w join public.seo_citations c on c.pubmed_pmid = w.pmid and c.verification_status = 'verified';
  if n_cite <> 5 then raise exception 'W39r: expected 5 verified citations, got %', n_cite; end if;
  select count(*) into n_bind from w39p_bind b
    join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
    join public.seo_citations c on c.pubmed_pmid = b.pmid
    join public.seo_page_citations pc on pc.page_fp = p.page_fingerprint and pc.citation_fp = c.fingerprint and pc.citation_purpose = b.purpose;
  if n_bind <> 7 then raise exception 'W39r: expected 7 bindings, got %', n_bind; end if;
end $$;

commit;
