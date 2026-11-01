-- W39v · VitalSleep /bmi-calculator-snoring/: reserve Planned page (target คำนวณ bmi) + 4 new citations + 7 bindings (DRAFT, not applied) · 2026-11-01
-- Source: brand session "การเชื่อมต่อ WordPress" pool intake (gap-plan BMI tool, user-approved 2026-11-01) + TSV
-- content/consolidation/vitalsleep-citations-2026-11-01-bmi.tsv (7 rows, PubMed+Crossref round-trip; authors/language from esummary).
-- Cannibalization check 2026-11-01: no registry row, no page and no GSC query (90d) on this site contains bmi / ดัชนีมวลกาย. Neighbours
-- weight-loss-snoring-sleep-apnea (ลดน้ำหนักรักษานอนกรน) and services/effortless-weight-loss-sleep-wellness-fat (effortless weight loss)
-- hold no BMI term → no conflict. Already in the pool (bound only): 11122588 Peppard (T5), 30215551 Hudgel ATS (T3), 38908268 Malhotra
-- 2024 SR/MA (T1; scope was vth-biodent only → vitalsleep-clinic appended, not first-party). WHO 2004 (14726171): collective author
-- "WHO Expert Consultation", slug set by hand. Tiers as sent. Semantics (หา ค่า bmi, หาค่าดัชนีมวลกาย, เช็ค bmi) queued for ~11-10.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create temp table w39p_cite (title text, authors text[], yr smallint, pmid text, doi text, url text, journal text,
                             tier smallint, ctype text, stype text, lang text, slug text, note text) on commit drop;
create temp table w39p_bind (slug text, pmid text, purpose text) on commit drop;

insert into w39p_cite values
('Effectiveness of lifestyle interventions on obstructive sleep apnea (OSA): systematic review and meta-analysis.', array['Araghi MH','Chen YF','Jagielski A','Choudhury S','Banerjee D','Hussain S','Thomas GN','Taheri S']::text[], 2013, '24082315', '10.5665/sleep.3056', 'https://doi.org/10.5665/sleep.3056', 'Sleep', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'araghi-2013-pmid24082315', 'tier_source=pubtype; locator PASS PASS'),
('Comparison of polysomnographic and clinical presentations and predictors for cardiovascular-related diseases between non-obese and obese obstructive sleep apnea among Asians.', array['Chirakalwasan N','Teerapraipruk B','Simon R','Hirunwiwatkul P','Jaimchariyatam N','Desudchit T','Charakorn N','Wanlapakorn C']::text[], 2013, '23772188', '10.5664/jcsm.2748', 'https://doi.org/10.5664/jcsm.2748', 'Journal of clinical sleep medicine : JCSM : official publication of the American Academy of Sleep Medicine', 5, 'cohort_study', 'retrospective_cohort', 'en', 'chirakalwasan-2013-pmid23772188', 'tier_source=abstract-read (pubtype Comparative Study; retrospective PSG review, Chulalongkorn, Thailand); locator PASS PASS'),
('Accuracy of body mass index in diagnosing obesity in the adult general population.', array['Romero-Corral A','Somers VK','Sierra-Johnson J','Thomas RJ','Collazo-Clavell ML','Korinek J','Allison TG','Batsis JA','Sert-Kuniyoshi FH','Lopez-Jimenez F']::text[], 2008, '18283284', '10.1038/ijo.2008.11', 'https://doi.org/10.1038/ijo.2008.11', 'International journal of obesity (2005)', 5, 'cross_sectional', 'cross_sectional', 'en', 'romero-corral-2008-pmid18283284', 'tier_source=abstract-read (pubtype only Journal Article; NHANES III n=13,601); locator PASS PASS'),
('Appropriate body-mass index for Asian populations and its implications for policy and intervention strategies.', array['WHO Expert Consultation']::text[], 2004, '14726171', '10.1016/s0140-6736(03)15268-3', 'https://doi.org/10.1016/S0140-6736(03)15268-3', 'Lancet (London, England)', 6, 'expert_opinion', 'consensus_statement', 'en', 'who-expert-consultation-2004-pmid14726171', 'tier_source=abstract-read (pubtype Review; WHO expert consultation); locator PASS PASS');

-- binds (page slug, pmid, purpose)
insert into w39p_bind values
('bmi-calculator-snoring','24082315','supporting_evidence'),
('bmi-calculator-snoring','38908268','supporting_evidence'),
('bmi-calculator-snoring','30215551','guideline_reference'),
('bmi-calculator-snoring','11122588','supporting_evidence'),
('bmi-calculator-snoring','23772188','supporting_evidence'),
('bmi-calculator-snoring','18283284','supporting_evidence'),
('bmi-calculator-snoring','14726171','supporting_evidence');

-- 1 · reserve the page (citations bind by FK)
insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::คำนวณ bmi'), 'คำนวณ bmi', 'VitalSleep Clinic', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai',
       'Informational', 'Added 2026-11-01 W39v reserved target for planned page (brand session); no volume inferred.'
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'VitalSleep Clinic' and kw_norm(k.keyword) = kw_norm('คำนวณ bmi'))
on conflict (fingerprint) do nothing; -- 1 row

insert into public.seo_website_page_master (page_fingerprint, brand_id, brand_name, slug, canonical_url, status, page_type, page_language,
                                            target_keyword_fp, viability_assessment, reconciliation_notes)
select 'vsc-wp-' || left(md5('bmi-calculator-snoring'), 8), 'vitalsleep-clinic', 'VitalSleep Clinic', 'bmi-calculator-snoring',
       'https://www.vitalsleepclinic.com/bmi-calculator-snoring/', 'Planned', 'knowledge_article', 'th',
       lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::คำนวณ bmi'),
       jsonb_build_object('kw_rule_version','1.0','keyword_source','brand_session','decided_by','w39v-migration','decided_at','2026-11-01'),
       'W39v 2026-11-01: reserved (Planned) by brand session, BMI tool (interactive calculator, Asian cutoffs); set Live when published'
 where not exists (select 1 from public.seo_website_page_master p where p.brand_id = 'vitalsleep-clinic' and p.slug = 'bmi-calculator-snoring'); -- 1 row

update public.seo_x_ads_keywords_contextual_master
   set keyword_use_as = 'target_keyword'
 where fingerprint = lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::คำนวณ bmi')
   and keyword_use_as is distinct from 'excluded'; -- 1 row

-- 1b · pool row reused by a second brand
update public.seo_citations
   set brand_scope = array_append(brand_scope, 'vitalsleep-clinic'), updated_at = now()
 where pubmed_pmid = '38908268' and not (brand_scope @> array['*'] or brand_scope @> array['vitalsleep-clinic']); -- 1 row

-- 2 · new citations (skip any pmid/doi already in the pool)
insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
                                  citation_type, study_type, language_code, is_thai_specific, brand_scope, verification_status,
                                  last_verified_at, load_from, load_source, maintenance_log)
select c.slug, c.title, c.authors, c.yr, c.pmid, c.doi, c.url, c.journal, c.tier, c.ctype, c.stype, c.lang, false, array['*'], 'verified',
       now(), 'vitalsleep-clinic', 'vitalsleep-clinic:citation intake 2026-11-01 bmi (PubMed+Crossref round-trip by WP session)', c.note
  from w39p_cite c
 where not exists (select 1 from public.seo_citations x where x.pubmed_pmid = c.pmid or (c.doi is not null and lower(x.doi) = c.doi)); -- 4 rows

-- 3 · bindings
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, b.purpose, 'references', 'active'
  from w39p_bind b
  join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
  join public.seo_citations c on c.pubmed_pmid = b.pmid
on conflict (page_fp, citation_fp, citation_purpose) do nothing; -- 7 rows

-- 4 · assert
do $$
declare n_cite int; n_bind int;
begin
  select count(*) into n_cite from w39p_cite w join public.seo_citations c on c.pubmed_pmid = w.pmid and c.verification_status = 'verified';
  if n_cite <> 4 then raise exception 'W39v: expected 4 verified citations, got %', n_cite; end if;
  select count(*) into n_bind from w39p_bind b
    join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
    join public.seo_citations c on c.pubmed_pmid = b.pmid
    join public.seo_page_citations pc on pc.page_fp = p.page_fingerprint and pc.citation_fp = c.fingerprint and pc.citation_purpose = b.purpose;
  if n_bind <> 7 then raise exception 'W39v: expected 7 bindings, got %', n_bind; end if;
end $$;

commit;
