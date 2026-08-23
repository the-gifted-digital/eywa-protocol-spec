-- ============================================================================
-- Citation QA gates — EYWA Bible Part 23.1
-- Run before any content-writing sprint and before publish.
-- Every gate must return 0 rows. Any row = blocker.
--
-- Origin: 2026-07-29 VTH BioDent citation-pool rebuild, which found 13 of 115
-- locators pointing at unrelated papers (an ecology study, a tomato-genetics
-- paper, an ALS spatial analysis...). Regex/­title heuristics did not catch any
-- of them; only round-tripping the identifier against the source did.
-- ============================================================================

\set brand 'vth-biodent'

-- ---------------------------------------------------------------------------
-- G1  Every citation admitted to a brand pool has a resolvable identifier.
--     A name-only row is not a citation.
-- ---------------------------------------------------------------------------
--     Exempt: 'textbook' (ISBN only) and 'other' (Bible T6 first-party clinic
--     registries, which have no external locator by definition).
--     2026-08-24: split by whether anyone relies on the row. A locatorless row that says
--     verification_status='unverified' and is bound to no page is a research to-do somebody
--     wrote down honestly, not a defect — blocking on it makes the gate punish bookkeeping.
--     G2 still blocks the moment such a row is bound to a page, so nothing reaches a reader.
select 'G1_no_locator' gate, c.fingerprint, left(c.title,70) title
from seo_citations c
where (c.brand_scope @> array['*'] or c.brand_scope @> array[:'brand'])
  and c.pubmed_pmid is null and c.doi is null and c.url is null and c.isbn is null
  and c.citation_type not in ('textbook','other')
  and (c.verification_status = 'verified'
       or exists (select 1 from seo_page_citations pc where pc.citation_fp = c.fingerprint));

select 'G1w_locatorless_backlog' gate, c.fingerprint, left(c.title,70) title
from seo_citations c
where (c.brand_scope @> array['*'] or c.brand_scope @> array[:'brand'])
  and c.pubmed_pmid is null and c.doi is null and c.url is null and c.isbn is null
  and c.citation_type not in ('textbook','other')
  and c.verification_status <> 'verified'
  and not exists (select 1 from seo_page_citations pc where pc.citation_fp = c.fingerprint);

-- ---------------------------------------------------------------------------
-- G2  Nothing unverified may reach a page.
--     verification_status must be 'verified' before a junction row exists.
-- ---------------------------------------------------------------------------
select 'G2_unverified_on_page' gate, pc.page_fp, c.fingerprint, c.verification_status
from seo_page_citations pc
join seo_citations c on c.fingerprint = pc.citation_fp
where pc.status = 'active' and c.verification_status <> 'verified';

-- ---------------------------------------------------------------------------
-- G3  Retracted or broken sources are never active on a page.
-- ---------------------------------------------------------------------------
select 'G3_retracted_or_broken' gate, pc.page_fp, c.fingerprint, c.verification_status
from seo_page_citations pc
join seo_citations c on c.fingerprint = pc.citation_fp
where pc.status = 'active' and (c.is_retracted or c.verification_status in ('retracted','broken_link'));

-- ---------------------------------------------------------------------------
-- G4  Stored PubMed URL agrees with the stored PMID.
--     Catches the "PMID stripped but URL left behind" failure.
-- ---------------------------------------------------------------------------
select 'G4_url_pmid_mismatch' gate, fingerprint, pubmed_pmid, url
from seo_citations
where url ~ 'pubmed\.ncbi\.nlm\.nih\.gov/[0-9]+'
  and coalesce(substring(url from 'pubmed\.ncbi\.nlm\.nih\.gov/([0-9]+)'),'')
      is distinct from coalesce(pubmed_pmid,'');

-- ---------------------------------------------------------------------------
-- G5  citation_tier agrees with citation_type per Bible 23.1.
--     T1 SR/MA · T2 RCT · T3 society guideline/consensus · T4 gov/regulator
--     T5 observational · T6 textbook/expert/first-party/industry
-- ---------------------------------------------------------------------------
select 'G5_tier_type_mismatch' gate, fingerprint, citation_tier, citation_type, left(title,60) title
from seo_citations
where brand_scope <> array[]::text[]
  and citation_tier is distinct from case citation_type
        when 'systematic_review'   then 1
        when 'meta_analysis'       then 1
        when 'rct'                 then 2
        when 'clinical_guideline'  then 3
        when 'regulatory_document' then 4
        when 'cohort_study'        then 5
        when 'case_control'        then 5
        when 'cross_sectional'     then 5
        when 'case_series'         then 5
        when 'textbook'            then 6
        when 'expert_opinion'      then 6
        when 'case_report'         then 6
        when 'editorial'           then 6
        when 'industry_publication' then 6
        when 'patient_resource'    then 6
        else citation_tier end;

-- ---------------------------------------------------------------------------
-- G6  minimum_per_layer met (Bible 23.1 "Citation Selection Rules").
--     §5 concern + §6 knowledge >= 3 · §3 service + §4 tech >= 2 · §7 case >= 1
-- ---------------------------------------------------------------------------
with quota as (
  -- Section comes from sitemap_node_id, falling back to sitemap_section when the node id is
  -- empty. deezy's 72 translation rows carry no node_id, and defaulting them to quota 0 exempted
  -- them silently — "nothing required" and "could not classify" must not share a return value.
  -- Pages whose notes carry CITATION EXEMPTION state no claims, so nothing is required of them;
  -- the exemption lives in the data, never in this file, so every brand can declare its own.
  select page_fingerprint page_fp, status,
         case coalesce(nullif(split_part(coalesce(sitemap_node_id,''),'.',1),''), sitemap_section)
           when '5' then 3 when '6' then 3 when '3' then 2 when '4' then 2 when '7' then 1 else 0 end q
  from seo_website_page_master
  where brand_id = :'brand'
    and status in ('Planned','Live')
    and coalesce(reconciliation_notes,'') not like '%CITATION EXEMPTION%'
), got as (
  select page_fp, count(*) n from seo_page_citations where status='active' group by 1
)
--     Live blocks, Planned warns. The minimum is a promise about what SHIPS; demanding
--     citations for text nobody has written yet is what produced the off-topic backbone sweep.
select case when quota.status = 'Live' then 'G6_below_minimum'
            else 'G6w_planned_below_minimum' end gate,
       quota.page_fp, quota.q required, coalesce(got.n,0) actual
from quota left join got using (page_fp)
where quota.q > 0 and coalesce(got.n,0) < quota.q;

-- ---------------------------------------------------------------------------
-- G7  Every page carrying medical claims has at least one Tier 1-3 source.
-- ---------------------------------------------------------------------------
with quota as (
  -- Section comes from sitemap_node_id, falling back to sitemap_section when the node id is
  -- empty. deezy's 72 translation rows carry no node_id, and defaulting them to quota 0 exempted
  -- them silently — "nothing required" and "could not classify" must not share a return value.
  -- Pages whose notes carry CITATION EXEMPTION state no claims, so nothing is required of them;
  -- the exemption lives in the data, never in this file, so every brand can declare its own.
  select page_fingerprint page_fp, status,
         case coalesce(nullif(split_part(coalesce(sitemap_node_id,''),'.',1),''), sitemap_section)
           when '5' then 3 when '6' then 3 when '3' then 2 when '4' then 2 when '7' then 1 else 0 end q
  from seo_website_page_master
  where brand_id = :'brand'
    and status in ('Planned','Live')
    and coalesce(reconciliation_notes,'') not like '%CITATION EXEMPTION%'
)
select case when quota.status = 'Live' then 'G7_no_tier1_3'
            else 'G7w_planned_no_tier1_3' end gate,
       quota.page_fp
from quota
where quota.q > 0
  and not exists (
    select 1 from seo_page_citations pc
    join seo_citations c on c.fingerprint = pc.citation_fp
    where pc.page_fp = quota.page_fp and pc.status='active' and c.citation_tier <= 3);

-- ---------------------------------------------------------------------------
-- G8  Freshness. Bible 23.1: T1 <= 5y, T2 <= 7y, T5 <= 7y; T3/T4 track latest.
--     Warn-level gate: an old landmark paper can stay if deliberately chosen,
--     but it must be a decision, not neglect.
-- ---------------------------------------------------------------------------
select 'G8_stale' gate, fingerprint, citation_tier, publication_year, left(title,60) title
from seo_citations
where brand_scope <> array[]::text[] and publication_year is not null
  and ((citation_tier = 1 and publication_year < extract(year from now()) - 5)
    or (citation_tier = 2 and publication_year < extract(year from now()) - 7)
    or (citation_tier = 5 and publication_year < extract(year from now()) - 7));

-- ---------------------------------------------------------------------------
-- G9  Commercial sources are labelled as such (Bible 23.1 forbids undisclosed
--     sponsored content). Manufacturer material must be industry_publication.
-- ---------------------------------------------------------------------------
--     NOTE: use word boundaries. A bare 'graphy' alternative false-positives on
--     "radiography" and "photogrammetry" — it flagged two AAOMR guidelines here.
select 'G9_undisclosed_commercial' gate, fingerprint, citation_type, left(coalesce(publisher_name,title),60) src
from seo_citations
where brand_scope <> array[]::text[]
  and (coalesce(publisher_name,'')||' '||coalesce(title,''))
      ~* '\ymanufacturer\y|\yversah\y|graphy inc|\ytrioclear\y|tera harz'
  and citation_type not in ('industry_publication','other');

-- ---------------------------------------------------------------------------
-- G10 No duplicate work in a single brand pool (same DOI or same PMID twice).
-- ---------------------------------------------------------------------------
select 'G10_duplicate_doi' gate, doi, count(*) n
from seo_citations where doi is not null and brand_scope <> array[]::text[]
group by doi having count(*) > 1
union all
select 'G10_duplicate_pmid', pubmed_pmid, count(*)
from seo_citations where pubmed_pmid is not null and brand_scope <> array[]::text[]
group by pubmed_pmid having count(*) > 1;

-- ---------------------------------------------------------------------------
-- G11 Same citation must not appear twice on one page.
-- ---------------------------------------------------------------------------
select 'G11_dup_on_page' gate, page_fp, citation_fp, count(*) n
from seo_page_citations where status='active'
group by 1,2,3 having count(*) > 1;
