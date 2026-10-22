-- W1c (handover data-quality #5): v_citation_type_mismatch
-- citation_tier already agrees with citation_type (gate G5). What drifts is
-- study_type (free text from the loader) vs citation_type, e.g. p7-c3
-- (PMID 38002660): citation_type expert_opinion / tier 6, study_type systematic_review.
-- This view maps study_type to the tier it implies (Bible 23.1) and lists rows
-- whose tier disagrees, plus broken/unverified rows, so each can be checked
-- against the source (PubMed publication type) and fixed by hand.
--   overrated  = tier claims stronger evidence than study_type supports (fix first)
--   underrated = study_type is stronger than the tier given
-- study_type 'other' / null implies nothing and is not flagged.

create or replace view public.v_citation_type_mismatch as
with mapped as (
  select c.*,
         case lower(replace(c.study_type, ' ', '_'))
           when 'systematic_review'                   then 1
           when 'systematic_review_and_meta_analysis' then 1
           when 'meta_analysis'                       then 1
           when 'cochrane_review'                     then 1
           when 'rct'                                 then 2
           when 'randomized_controlled_trial'         then 2
           when 'clinical_guideline'                  then 3
           when 'clinical_practice_guideline'         then 3
           when 'consensus_guideline'                 then 3
           when 'consensus_statement'                 then 3
           when 'systematic_review_guideline'         then 3
           when 'regulatory_document'                 then 4
           when 'regulation'                          then 4
           when 'law'                                 then 4
           when 'fact_sheet'                          then 4
           when 'report'                              then 4
           when 'survey_report'                       then 4
           when 'cohort_study'                        then 5
           when 'prospective_cohort'                  then 5
           when 'retrospective_cohort'                then 5
           when 'case_control'                        then 5
           when 'cross_sectional'                     then 5
           when 'case_series'                         then 5
           when 'controlled_clinical_trial'           then 5
           when 'clinical_study'                      then 5
           when 'pilot_study'                         then 5
           when 'genetic_association'                 then 5
           when 'case_report'                         then 6
           when 'narrative_review'                    then 6
           when 'scoping_review'                      then 6
           when 'expert_opinion'                      then 6
           when 'in_vitro'                            then 6
           when 'textbook'                            then 6
           when 'manufacturer_document'               then 6
           when 'patient_resource'                    then 6
           when 'patient_information_page'            then 6
           when 'patient_information_leaflet'         then 6
         end as implied_tier
  from seo_citations c
)
select m.fingerprint, m.citation_slug, m.pubmed_pmid, m.doi, m.url,
       left(m.title, 120) as title,
       m.citation_type, m.study_type, m.citation_tier, m.implied_tier,
       m.verification_status, m.brand_scope,
       case
         when m.implied_tier is not null and m.citation_tier < m.implied_tier then 'overrated'
         when m.implied_tier is not null and m.citation_tier > m.implied_tier then 'underrated'
         when m.verification_status = 'broken_link' then 'broken_link'
         when m.verification_status = 'unverified'  then 'unverified'
       end as issue,
       (select count(*) from seo_page_citations pc where pc.citation_fp = m.fingerprint and pc.status = 'active') as pages_using
from mapped m
where (m.implied_tier is not null and m.citation_tier is distinct from m.implied_tier)
   or m.verification_status in ('broken_link', 'unverified');

comment on view public.v_citation_type_mismatch is
  'Citations whose tier disagrees with study_type (overrated first), or broken/unverified. Fix by checking the source; do not auto-correct. Handover data-quality #5, 2026-10-21.';
