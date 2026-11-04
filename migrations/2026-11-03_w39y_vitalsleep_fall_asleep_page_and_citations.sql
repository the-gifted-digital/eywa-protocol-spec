-- W39y · VitalSleep: reserve Planned /how-to-fall-asleep-fast/ (target วิธีนอนให้หลับเร็ว) + 12 new citations + 16 bindings on 3 pages (DRAFT, not applied) · 2026-11-03
-- Source: brand session "การเชื่อมต่อ WordPress" W44 intake + TSV content/consolidation/vitalsleep-citations-2026-11-03-sleepfast.tsv
-- (14 rows, PubMed+Crossref round-trip; authors/language from esummary; ExoTMS row has no PMID, Crossref metadata).
-- OWNER DECISION (DR-082): the proposed target วิธีทำให้นอนหลับ is already a semantic of 25860 /insomnia-sleep-test-health/ (target
-- ทำยังไงให้นอนหลับ), and Google already ranks 25860 for it (GSC 90d: วิธีทำให้หลับ 32 impr p5.1, วิธีทำให้นอนหลับ 29 p7.2, ทำให้นอนหลับ 18 p2.6).
-- 25860 keeps that cluster plus ทำยังไงให้นอนหลับ / ทําไงให้นอนหลับ / นอนไม่หลับ*. The new page takes the "fall asleep fast" sub-intent:
-- target วิธีนอนให้หลับเร็ว (880, not in registry, held by no page), with the หลับเร็ว / ภายใน X นาที / หลับง่าย variants queued as its
-- semantics for the ~11-10 round (not written here).
-- Type/tier changes vs the TSV: 33164742 guideline → clinical_guideline (already in pool, bound as guideline_reference); 22738673 narrative
-- review and 28346153 NSF consensus → expert_opinion T6 (same rule as Amicucci 42485698); 24136970 animal study → other (T5 kept).
-- ExoTMS (Nanos 2026, no PMID): randomized sham-controlled pilot kept at T2 by conduct; caveats in maintenance_log.
-- Already in the pool: 33164742 AASM 2021 and 23692173 CHAT (scope vth-biodent → vitalsleep-clinic appended, not first-party).
-- Sleep-cycle reuse of 15586779 / 30252388 / 42485698: already bound since W39r, no change.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create temp table w39p_cite (title text, authors text[], yr smallint, pmid text, doi text, url text, journal text,
                             tier smallint, ctype text, stype text, lang text, slug text, note text) on commit drop;
create temp table w39p_bind (slug text, pmid text, purpose text) on commit drop;

insert into w39p_cite values
('The effects of progressive muscle relaxation on sleep quality in adults: a systematic review and meta-analysis of randomized controlled trials.', array['Li K','Chen S','Liu Y','Yu N']::text[], 2026, '42625730', '10.3389/fpubh.2026.1906525', 'https://doi.org/10.3389/fpubh.2026.1906525', 'Frontiers in public health', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'li-2026-pmid42625730', 'tier_source=pubtype; locator PASS PASS'),
('The effect of caffeine on subsequent sleep: A systematic review and meta-analysis.', array['Gardiner C','Weakley J','Burke LM','Roach GD','Sargent C','Maniar N','Townshend A','Halson SL']::text[], 2023, '36870101', '10.1016/j.smrv.2023.101764', 'https://doi.org/10.1016/j.smrv.2023.101764', 'Sleep medicine reviews', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'gardiner-2023-pmid36870101', 'tier_source=pubtype; locator PASS PASS'),
('Caffeine effects on sleep taken 0, 3, or 6 hours before going to bed.', array['Drake C','Roehrs T','Shambroom J','Roth T']::text[], 2013, '24235903', '10.5664/jcsm.3170', 'https://doi.org/10.5664/jcsm.3170', 'Journal of clinical sleep medicine : JCSM : official publication of the American Academy of Sleep Medicine', 2, 'rct', 'randomized_controlled_trial', 'en', 'drake-2013-pmid24235903', 'tier_source=pubtype; locator PASS PASS'),
('Evening use of light-emitting eReaders negatively affects sleep, circadian timing, and next-morning alertness.', array['Chang AM','Aeschbach D','Duffy JF','Czeisler CA']::text[], 2015, '25535358', '10.1073/pnas.1418490112', 'https://doi.org/10.1073/pnas.1418490112', 'Proceedings of the National Academy of Sciences of the United States of America', 2, 'rct', 'randomized_controlled_trial', 'en', 'chang-2015-pmid25535358', 'tier_source=title; locator PASS PASS'),
('Effects of thermal environment on sleep and circadian rhythm.', array['Okamoto-Mizuno K','Mizuno K']::text[], 2012, '22738673', '10.1186/1880-6805-31-14', 'https://doi.org/10.1186/1880-6805-31-14', 'Journal of physiological anthropology', 6, 'expert_opinion', 'narrative_review', 'en', 'okamoto-mizuno-2012-pmid22738673', 'tier_source=pubtype (operator session: narrative review/consensus → expert_opinion T6, same as Amicucci 42485698); locator PASS PASS'),
('The effects of physical activity on sleep: a meta-analytic review.', array['Kredlow MA','Capozzoli MC','Hearon BA','Calkins AW','Otto MW']::text[], 2015, '25596964', '10.1007/s10865-015-9617-6', 'https://doi.org/10.1007/s10865-015-9617-6', 'Journal of behavioral medicine', 1, 'meta_analysis', 'meta_analysis', 'en', 'kredlow-2015-pmid25596964', 'tier_source=pubtype; locator PASS PASS'),
('National Sleep Foundation''s sleep quality recommendations: first report.', array['Ohayon M','Wickwire EM','Hirshkowitz M','Albert SM','Avidan A','Daly FJ','Dauvilliers Y','Ferri R','Fung C','Gozal D','Hazen N','Krystal A','Lichstein K','Mallampalli M','Plazzi G','Rawding R','Scheer FA','Somers V','Vitiello MV']::text[], 2017, '28346153', '10.1016/j.sleh.2016.11.006', 'https://doi.org/10.1016/j.sleh.2016.11.006', 'Sleep health', 6, 'expert_opinion', 'consensus_statement', 'en', 'ohayon-2017-pmid28346153', 'tier_source=title (operator session: narrative review/consensus → expert_opinion T6, same as Amicucci 42485698); locator PASS PASS'),
('Worldwide and regional prevalence rates of co-occurrence of insomnia and insomnia symptoms with obstructive sleep apnea: A systematic review and meta-analysis.', array['Zhang Y','Ren R','Lei F','Zhou J','Zhang J','Wing YK','Sanford LD','Tang X']::text[], 2019, '30844624', '10.1016/j.smrv.2019.01.004', 'https://doi.org/10.1016/j.smrv.2019.01.004', 'Sleep medicine reviews', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'zhang-2019-pmid30844624', 'tier_source=pubtype; locator PASS PASS'),
('Efficacy of repetitive transcranial magnetic stimulation for insomnia disorder: a systematic review and meta-analysis of randomized controlled trials.', array['Cao Z','Shi Q','Shi Z','Yuan D','Zeng S']::text[], 2026, '42305778', '10.3389/fnins.2026.1816963', 'https://doi.org/10.3389/fnins.2026.1816963', 'Frontiers in neuroscience', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'cao-2026-pmid42305778', 'tier_source=title; locator PASS PASS'),
('Sleep drives metabolite clearance from the adult brain.', array['Xie L','Kang H','Xu Q','Chen MJ','Liao Y','Thiyagarajan M','O''Donnell J','Christensen DJ','Nicholson C','Iliff JJ','Takano T','Deane R','Nedergaard M']::text[], 2013, '24136970', '10.1126/science.1241224', 'https://doi.org/10.1126/science.1241224', 'Science (New York, N.Y.)', 5, 'other', 'animal_study', 'en', 'xie-2013-pmid24136970', 'tier_source=title; locator PASS PASS'),
('Intranasal corticosteroids for nasal airway obstruction in children with moderate to severe adenoidal hypertrophy.', array['Zhang L','Mendoza-Sassi RA','César JA','Chadha NK']::text[], 2008, '18646145', '10.1002/14651858.cd006286.pub2', 'https://doi.org/10.1002/14651858.CD006286.pub2', 'The Cochrane database of systematic reviews', 1, 'systematic_review', 'systematic_review', 'en', 'zhang-2008-pmid18646145', 'tier_source=pubtype; locator PASS PASS'),
('Effects of ExoTMS stimulation on sleep quality: a sham-controlled study', array['Nanos G','Silva M','Patel C']::text[], 2026, null, '10.1186/s41606-026-00191-w', 'https://doi.org/10.1186/s41606-026-00191-w', 'Sleep Science and Practice', 2, 'rct', 'randomized_controlled_trial_pilot', 'en', 'nanos-2026-doi-s41606-026-00191-w', 'tier_source=full_text (T2 by conduct: block-randomized, single-blind, sham-controlled); no PMID, Crossref title match PASS; CAVEAT: pilot n=43 (31 active/12 sham), not powered for between-group comparison, authors are BTL clinical investigators (manufacturer); NCT07027657; supports clinic Exomind service - do not cite as proof of superiority over sham');

-- binds (page slug, pmid or doi for the ExoTMS row, purpose)
insert into w39p_bind values
('how-to-fall-asleep-fast','33164742','guideline_reference'),
('how-to-fall-asleep-fast','42625730','supporting_evidence'),
('how-to-fall-asleep-fast','36870101','supporting_evidence'),
('sleep-cycle-sleep-schedule','36870101','supporting_evidence'),
('how-to-fall-asleep-fast','24235903','supporting_evidence'),
('how-to-fall-asleep-fast','25535358','supporting_evidence'),
('how-to-fall-asleep-fast','22738673','supporting_evidence'),
('how-to-fall-asleep-fast','25596964','supporting_evidence'),
('sleep-cycle-sleep-schedule','25596964','supporting_evidence'),
('how-to-fall-asleep-fast','28346153','supporting_evidence'),
('how-to-fall-asleep-fast','30844624','supporting_evidence'),
('how-to-fall-asleep-fast','42305778','supporting_evidence'),
('sleep-cycle-sleep-schedule','24136970','supporting_evidence'),
('snoring-in-children','23692173','supporting_evidence'),
('snoring-in-children','18646145','supporting_evidence'),
('how-to-fall-asleep-fast','10.1186/s41606-026-00191-w','supporting_evidence');

-- 1 · reserve the page (citations bind by FK)
insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::วิธีนอนให้หลับเร็ว'), 'วิธีนอนให้หลับเร็ว', 'VitalSleep Clinic', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai',
       'Informational', 'Added 2026-11-03 W39y reserved target for planned page (brand session, Semrush 880); owner decision vs 25860 per DR-082.'
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'VitalSleep Clinic' and kw_norm(k.keyword) = kw_norm('วิธีนอนให้หลับเร็ว'))
on conflict (fingerprint) do nothing; -- 1 row

insert into public.seo_website_page_master (page_fingerprint, brand_id, brand_name, slug, canonical_url, status, page_type, page_language,
                                            target_keyword_fp, viability_assessment, reconciliation_notes)
select 'vsc-wp-' || left(md5('how-to-fall-asleep-fast'), 8), 'vitalsleep-clinic', 'VitalSleep Clinic', 'how-to-fall-asleep-fast',
       'https://www.vitalsleepclinic.com/how-to-fall-asleep-fast/', 'Planned', 'knowledge_article', 'th',
       lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::วิธีนอนให้หลับเร็ว'),
       jsonb_build_object('kw_rule_version','1.0','keyword_source','brand_session','decided_by','w39y-migration','decided_at','2026-11-03'),
       'W39y 2026-11-03: reserved (Planned) by brand session; target วิธีนอนให้หลับเร็ว (วิธีทำให้นอนหลับ stays with 25860 per DR-082); set Live when published'
 where not exists (select 1 from public.seo_website_page_master p where p.brand_id = 'vitalsleep-clinic' and p.slug = 'how-to-fall-asleep-fast'); -- 1 row

update public.seo_x_ads_keywords_contextual_master
   set keyword_use_as = 'target_keyword'
 where fingerprint = lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::วิธีนอนให้หลับเร็ว')
   and keyword_use_as is distinct from 'excluded'; -- 1 row

-- 1b · pool rows reused by a second brand
update public.seo_citations
   set brand_scope = array_append(brand_scope, 'vitalsleep-clinic'), updated_at = now()
 where pubmed_pmid in ('33164742','23692173') and not (brand_scope @> array['*'] or brand_scope @> array['vitalsleep-clinic']); -- 2 rows

-- 2 · new citations (skip any pmid/doi already in the pool)
insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
                                  citation_type, study_type, language_code, is_thai_specific, brand_scope, verification_status,
                                  last_verified_at, load_from, load_source, maintenance_log)
select c.slug, c.title, c.authors, c.yr, c.pmid, c.doi, c.url, c.journal, c.tier, c.ctype, c.stype, c.lang, false, array['*'], 'verified',
       now(), 'vitalsleep-clinic', 'vitalsleep-clinic:citation intake 2026-11-03 sleepfast (PubMed+Crossref round-trip by WP session)', c.note
  from w39p_cite c
 where not exists (select 1 from public.seo_citations x where x.pubmed_pmid = c.pmid or (c.doi is not null and lower(x.doi) = c.doi)); -- 12 rows

-- 3 · bindings
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, b.purpose, 'references', 'active'
  from w39p_bind b
  join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
  join public.seo_citations c on c.pubmed_pmid = b.pmid or lower(c.doi) = b.pmid
on conflict (page_fp, citation_fp, citation_purpose) do nothing; -- 16 rows

-- 4 · assert
do $$
declare n_cite int; n_bind int;
begin
  select count(*) into n_cite from w39p_cite w join public.seo_citations c on (c.pubmed_pmid = w.pmid or lower(c.doi) = w.doi) and c.verification_status = 'verified';
  if n_cite <> 12 then raise exception 'W39y: expected 12 verified citations, got %', n_cite; end if;
  select count(*) into n_bind from w39p_bind b
    join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
    join public.seo_citations c on c.pubmed_pmid = b.pmid or lower(c.doi) = b.pmid
    join public.seo_page_citations pc on pc.page_fp = p.page_fingerprint and pc.citation_fp = c.fingerprint and pc.citation_purpose = b.purpose;
  if n_bind <> 16 then raise exception 'W39y: expected 16 bindings, got %', n_bind; end if;
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'how-to-fall-asleep-fast'
                  and status = 'Planned' and target_keyword_fp like '%::วิธีนอนให้หลับเร็ว') then
    raise exception 'W39y: page not reserved';
  end if;
end $$;

commit;
