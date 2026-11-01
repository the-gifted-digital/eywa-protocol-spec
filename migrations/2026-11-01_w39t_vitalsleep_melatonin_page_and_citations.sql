-- W39t · VitalSleep /melatonin/: reserve Planned page (target เมลาโทนิน) + 9 citations + 9 bindings (DRAFT, not applied) · 2026-11-01
-- Source: brand session "การเชื่อมต่อ WordPress" pool intake (gap-plan P3) + TSV content/consolidation/vitalsleep-citations-2026-11-01-melatonin.tsv
-- (9 rows, PubMed+Crossref round-trip; authors/language from PubMed esummary 2026-11-01). Same shape as W39p/W39r.
-- Cannibalization check 2026-11-01: no registry row, no page and no GSC query (90d) on this site contains เมลาโทนิน / melatonin → no owner
-- conflict. None of the 9 citations, DOIs or the StatPearls NBK534823 URL was in the pool. Tiers taken as sent (AASM guidelines T3 match
-- the pool convention). Semantics (melatonin, เมลาโทนิน คือ / ช่วยนอนหลับ / ผลข้างเคียง / กินตอนไหน) are queued for the ~11-10 round.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create temp table w39p_cite (title text, authors text[], yr smallint, pmid text, doi text, url text, journal text,
                             tier smallint, ctype text, stype text, lang text, slug text, note text) on commit drop;
create temp table w39p_bind (slug text, pmid text, purpose text) on commit drop;

insert into w39p_cite values
('Meta-analysis: melatonin for the treatment of primary sleep disorders.', array['Ferracioli-Oda E','Qawasmi A','Bloch MH']::text[], 2013, '23691095', '10.1371/journal.pone.0063773', 'https://doi.org/10.1371/journal.pone.0063773', 'PloS one', 1, 'meta_analysis', 'meta_analysis', 'en', 'ferracioli-oda-2013-pmid23691095', 'tier_source=pubtype; locator PASS PASS'),
('Optimizing the Time and Dose of Melatonin as a Sleep-Promoting Drug: A Systematic Review of Randomized Controlled Trials and Dose-Response Meta-Analysis.', array['Cruz-Sanabria F','Bruno S','Crippa A','Frumento P','Scarselli M','Skene DJ','Faraguna U']::text[], 2024, '38888087', '10.1111/jpi.12985', 'https://doi.org/10.1111/jpi.12985', 'Journal of pineal research', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'cruz-sanabria-2024-pmid38888087', 'tier_source=pubtype; locator PASS PASS'),
('Melatonin for the prevention and treatment of jet lag.', array['Herxheimer A','Petrie KJ']::text[], 2002, '12076414', '10.1002/14651858.cd001520', 'https://doi.org/10.1002/14651858.CD001520', 'The Cochrane database of systematic reviews', 1, 'systematic_review', 'systematic_review', 'en', 'herxheimer-2002-pmid12076414', 'tier_source=pubtype; locator PASS PASS'),
('Adverse Events Associated with Melatonin for the Treatment of Primary or Secondary Sleep Disorders: A Systematic Review.', array['Besag FMC','Vasey MJ','Lao KSJ','Wong ICK']::text[], 2019, '31722088', '10.1007/s40263-019-00680-w', 'https://doi.org/10.1007/s40263-019-00680-w', 'CNS drugs', 1, 'systematic_review', 'systematic_review', 'en', 'besag-2019-pmid31722088', 'tier_source=pubtype; locator PASS PASS'),
('Clinical Practice Guideline for the Pharmacologic Treatment of Chronic Insomnia in Adults: An American Academy of Sleep Medicine Clinical Practice Guideline.', array['Sateia MJ','Buysse DJ','Krystal AD','Neubauer DN','Heald JL']::text[], 2017, '27998379', '10.5664/jcsm.6470', 'https://doi.org/10.5664/jcsm.6470', 'Journal of clinical sleep medicine : JCSM : official publication of the American Academy of Sleep Medicine', 3, 'clinical_guideline', 'clinical_practice_guideline', 'en', 'sateia-2017-pmid27998379', 'tier_source=pubtype; locator PASS PASS'),
('Clinical Practice Guideline for the Treatment of Intrinsic Circadian Rhythm Sleep-Wake Disorders: Advanced Sleep-Wake Phase Disorder (ASWPD), Delayed Sleep-Wake Phase Disorder (DSWPD), Non-24-Hour Sleep-Wake Rhythm Disorder (N24SWD), and Irregular Sleep-Wake Rhythm Disorder (ISWRD). An Update for 2015: An American Academy of Sleep Medicine Clinical Practice Guideline.', array['Auger RR','Burgess HJ','Emens JS','Deriy LV','Thomas SM','Sharkey KM']::text[], 2015, '26414986', '10.5664/jcsm.5100', 'https://doi.org/10.5664/jcsm.5100', 'Journal of clinical sleep medicine : JCSM : official publication of the American Academy of Sleep Medicine', 3, 'clinical_guideline', 'clinical_practice_guideline', 'en', 'auger-2015-pmid26414986', 'tier_source=pubtype; locator PASS PASS'),
('Melatonin Natural Health Products and Supplements: Presence of Serotonin and Significant Variability of Melatonin Content.', array['Erland LA','Saxena PK']::text[], 2017, '27855744', '10.5664/jcsm.6462', 'https://doi.org/10.5664/jcsm.6462', 'Journal of clinical sleep medicine : JCSM : official publication of the American Academy of Sleep Medicine', 5, 'cross_sectional', 'cross_sectional', 'en', 'erland-2017-pmid27855744', 'tier_source=abstract-read (pubtype only Journal Article; lab analysis of 31 commercial products); locator PASS PASS'),
('Exposure to room light before bedtime suppresses melatonin onset and shortens melatonin duration in humans.', array['Gooley JJ','Chamberlain K','Smith KA','Khalsa SB','Rajaratnam SM','Van Reen E','Zeitzer JM','Czeisler CA','Lockley SW']::text[], 2011, '21193540', '10.1210/jc.2010-2098', 'https://doi.org/10.1210/jc.2010-2098', 'The Journal of clinical endocrinology and metabolism', 5, 'cohort_study', 'clinical_study', 'en', 'gooley-2011-pmid21193540', 'tier_source=abstract-read (pubtype only Journal Article; within-subject light-exposure experiment); locator PASS PASS'),
('Melatonin', array['Savage RA','Zafar N','Yohannan S','Miller JMM']::text[], 2024, '30521244', null, 'https://www.ncbi.nlm.nih.gov/books/NBK534823/', 'StatPearls', 6, 'textbook', 'textbook', 'en', 'savage-2024-pmid30521244', 'tier_source=pubtype Study Guide (StatPearls NBK534823); locator PASS PASS');

-- binds (page slug, pmid, purpose)
insert into w39p_bind values
('melatonin','23691095','supporting_evidence'),
('melatonin','38888087','supporting_evidence'),
('melatonin','12076414','supporting_evidence'),
('melatonin','31722088','supporting_evidence'),
('melatonin','27998379','guideline_reference'),
('melatonin','26414986','guideline_reference'),
('melatonin','27855744','supporting_evidence'),
('melatonin','21193540','supporting_evidence'),
('melatonin','30521244','supporting_evidence');

-- 1 · reserve the page (citations bind by FK)
insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::เมลาโทนิน'), 'เมลาโทนิน', 'VitalSleep Clinic', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai',
       'Informational', 'Added 2026-11-01 W39t reserved target for planned page (brand session); no volume inferred.'
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'VitalSleep Clinic' and kw_norm(k.keyword) = kw_norm('เมลาโทนิน'))
on conflict (fingerprint) do nothing; -- 1 row

insert into public.seo_website_page_master (page_fingerprint, brand_id, brand_name, slug, canonical_url, status, page_type, page_language,
                                            target_keyword_fp, viability_assessment, reconciliation_notes)
select 'vsc-wp-' || left(md5('melatonin'), 8), 'vitalsleep-clinic', 'VitalSleep Clinic', 'melatonin',
       'https://www.vitalsleepclinic.com/melatonin/', 'Planned', 'knowledge_article', 'th',
       lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::เมลาโทนิน'),
       jsonb_build_object('kw_rule_version','1.0','keyword_source','brand_session','decided_by','w39t-migration','decided_at','2026-11-01'),
       'W39t 2026-11-01: reserved (Planned) by brand session, gap-plan P3; education only, Rx drug in TH; set Live when published'
 where not exists (select 1 from public.seo_website_page_master p where p.brand_id = 'vitalsleep-clinic' and p.slug = 'melatonin'); -- 1 row

update public.seo_x_ads_keywords_contextual_master
   set keyword_use_as = 'target_keyword'
 where fingerprint = lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::เมลาโทนิน')
   and keyword_use_as is distinct from 'excluded'; -- 1 row

-- 2 · new citations (skip any pmid/doi already in the pool)
insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
                                  citation_type, study_type, language_code, is_thai_specific, brand_scope, verification_status,
                                  last_verified_at, load_from, load_source, maintenance_log)
select c.slug, c.title, c.authors, c.yr, c.pmid, c.doi, c.url, c.journal, c.tier, c.ctype, c.stype, c.lang, false, array['*'], 'verified',
       now(), 'vitalsleep-clinic', 'vitalsleep-clinic:citation intake 2026-11-01 melatonin (PubMed+Crossref round-trip by WP session)', c.note
  from w39p_cite c
 where not exists (select 1 from public.seo_citations x where x.pubmed_pmid = c.pmid or (c.doi is not null and lower(x.doi) = c.doi)); -- 9 rows

-- 3 · bindings
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, b.purpose, 'references', 'active'
  from w39p_bind b
  join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
  join public.seo_citations c on c.pubmed_pmid = b.pmid
on conflict (page_fp, citation_fp, citation_purpose) do nothing; -- 9 rows

-- 4 · assert
do $$
declare n_cite int; n_bind int;
begin
  select count(*) into n_cite from w39p_cite w join public.seo_citations c on c.pubmed_pmid = w.pmid and c.verification_status = 'verified';
  if n_cite <> 9 then raise exception 'W39t: expected 9 verified citations, got %', n_cite; end if;
  select count(*) into n_bind from w39p_bind b
    join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
    join public.seo_citations c on c.pubmed_pmid = b.pmid
    join public.seo_page_citations pc on pc.page_fp = p.page_fingerprint and pc.citation_fp = c.fingerprint and pc.citation_purpose = b.purpose;
  if n_bind <> 9 then raise exception 'W39t: expected 9 bindings, got %', n_bind; end if;
end $$;

commit;
