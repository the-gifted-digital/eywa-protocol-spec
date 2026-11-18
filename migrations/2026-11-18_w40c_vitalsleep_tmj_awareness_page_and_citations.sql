-- W40c · VitalSleep NEW post /tmj-awareness-month/ (Planned): target + 3 new citations + 4 bindings (DRAFT, not applied) · 2026-11-18
-- Source: brand session "การเชื่อมต่อ WordPress" intake + TSV content/rewrites/tmj-awareness-month-2026-11-18.tsv. Awareness post, completeness not SEO.
-- Checks 2026-11-18: tmj awareness month / เดือนรณรงค์ tmj / สัญญาณเตือน tmj not in registry, held by no page; GSC 90d no awareness/รณรงค์/
-- สัญญาณเตือน queries → no clash with 24660 / 27395 / 23569 / 23119. Semantics เดือนรณรงค์ tmj, สัญญาณเตือน tmj NOT written (queued; write at Live).
-- Citations: Valesan 2021 (33409693) pubtype SR+MA → T1 new. Durham 2015 BMJ (25767130) NOT in pool though cited on 24660 → added; pubtype
-- Review only, BMJ clinical review = narrative → expert_opinion T6 (Amicucci precedent). Schiffman 2014 DC/TMD (24482784) already in pool, T3 → bind.
-- TMJ Association event page → patient_resource T6 (pool convention for org pages, e.g. aae.org), cited for the event only, not clinical claims.
-- Run in the Supabase SQL editor as one transaction.

begin;

-- 1 · reserve target + page (citations bind by FK)
insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::tmj awareness month'), 'tmj awareness month', 'VitalSleep Clinic', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai',
       'Informational', 'Added 2026-11-18 W40c reserved target for planned awareness post (brand session, DataForSEO TH ~10/mo).'
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'VitalSleep Clinic' and kw_norm(k.keyword) = kw_norm('tmj awareness month'))
on conflict (fingerprint) do nothing; -- 1 row

insert into public.seo_website_page_master (page_fingerprint, brand_id, brand_name, slug, canonical_url, status, page_type, page_language,
                                            target_keyword_fp, viability_assessment, reconciliation_notes)
select 'vsc-wp-' || left(md5('tmj-awareness-month'), 8), 'vitalsleep-clinic', 'VitalSleep Clinic', 'tmj-awareness-month',
       'https://www.vitalsleepclinic.com/tmj-awareness-month/', 'Planned', 'knowledge_article', 'th',
       lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::tmj awareness month'),
       jsonb_build_object('kw_rule_version','1.0','keyword_source','brand_session','decided_by','w40c-migration','decided_at','2026-11-18'),
       'W40c 2026-11-18: reserved (Planned) by brand session; awareness post, must not target 24660/27395/23569/23119 queries; WP id pending; set Live when published'
 where not exists (select 1 from public.seo_website_page_master p where p.brand_id = 'vitalsleep-clinic' and p.slug = 'tmj-awareness-month'); -- 1 row

update public.seo_x_ads_keywords_contextual_master
   set keyword_use_as = 'target_keyword'
 where fingerprint = lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::tmj awareness month')
   and keyword_use_as is distinct from 'excluded'; -- 1 row

-- 2 · new citations (skip any pmid/doi/url already in the pool)
create temp table w40c_cite (title text, authors text[], yr smallint, pmid text, doi text, url text, journal text,
                             tier smallint, ctype text, stype text, lang text, slug text, note text) on commit drop;
insert into w40c_cite values
('Prevalence of temporomandibular joint disorders: a systematic review and meta-analysis.', array['Valesan LF','Da-Cas CD','Réus JC','Denardin ACS','Garanhani RR','Bonotto D','Januzzi E','de Souza BDM']::text[], 2021, '33409693', '10.1007/s00784-020-03710-w', 'https://doi.org/10.1007/s00784-020-03710-w', 'Clinical oral investigations', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'valesan-2021-pmid33409693', 'tier_source=pubtype (Meta-Analysis, Systematic Review); verified PubMed 2026-11-18 by WP session'),
('Temporomandibular disorders.', array['Durham J','Newton-John TR','Zakrzewska JM']::text[], 2015, '25767130', '10.1136/bmj.h1154', 'https://doi.org/10.1136/bmj.h1154', 'BMJ (Clinical research ed.)', 6, 'expert_opinion', 'narrative_review', 'en', 'durham-2015-pmid25767130', 'tier_source=pubtype (Review only; BMJ clinical review = narrative → expert_opinion T6, Amicucci precedent); PMID from doi esearch 2026-11-18; also cited on 24660'),
('November is TMJ Awareness Month', null, 2026, null, null, 'https://tmj.org/november-is-tmj-awareness-month/', 'The TMJ Association', 6, 'patient_resource', 'patient_resource', 'en', 'tmja-tmj-awareness-month', 'non-clinical: source for the awareness-month event only, not for clinical claims; URL 200 on 2026-11-18');

insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
                                  citation_type, study_type, language_code, is_thai_specific, brand_scope, verification_status,
                                  last_verified_at, load_from, load_source, maintenance_log)
select c.slug, c.title, c.authors, c.yr, c.pmid, c.doi, c.url, c.journal, c.tier, c.ctype, c.stype, c.lang, false, array['*'], 'verified',
       now(), 'vitalsleep-clinic', 'vitalsleep-clinic:citation intake 2026-11-18 tmj awareness (PubMed round-trip by WP session + operator session)', c.note
  from w40c_cite c
 where not exists (select 1 from public.seo_citations x where (c.pmid is not null and x.pubmed_pmid = c.pmid)
                                                         or (c.doi is not null and lower(x.doi) = c.doi)
                                                         or x.citation_slug = c.slug); -- 3 rows

-- 3 · bindings (by slug; Schiffman reused from pool)
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, b.purpose, 'references', 'active'
  from (values ('valesan-2021-pmid33409693', null, 'supporting_evidence'),
               ('durham-2015-pmid25767130', null, 'supporting_evidence'),
               (null, '24482784', 'guideline_reference'),
               ('tmja-tmj-awareness-month', null, 'supporting_evidence')) b(cslug, pmid, purpose)
  join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = 'tmj-awareness-month'
  join public.seo_citations c on c.citation_slug = b.cslug or c.pubmed_pmid = b.pmid
on conflict (page_fp, citation_fp, citation_purpose) do nothing; -- 4 rows

-- 4 · assert
do $$
declare n_page int; n_bind int;
begin
  select count(*) into n_page from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'tmj-awareness-month'
     and status = 'Planned' and target_keyword_fp like '%::tmj awareness month';
  if n_page <> 1 then raise exception 'W40c: page not reserved'; end if;
  select count(*) into n_bind from public.seo_page_citations pc join public.seo_website_page_master p on p.page_fingerprint = pc.page_fp
   where p.brand_id = 'vitalsleep-clinic' and p.slug = 'tmj-awareness-month' and pc.status = 'active';
  if n_bind <> 4 then raise exception 'W40c: expected 4 bindings, got %', n_bind; end if;
end $$;

commit;
