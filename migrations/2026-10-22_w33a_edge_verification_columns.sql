-- W3.3a (DR-078)
-- 1. Edge verification that is not a clinician sign-off. Operator decision 2026-10-22: an edge
--    checked against international sources (MeSH tree, ICD, PubMed, guidelines) is "verified",
--    recorded apart from medical_reviewer_signoff_at, which stays reserved for a named clinician.
--    evidence_verified_by: 'agent:<source>' (e.g. agent:mesh, agent:pubmed) or 'human:<person fp>'.
-- 2. Residual-code rule refined (operator decision 2026-10-22): a WHO ICD-10 "other" (.8) code is
--    allowed when WHO lists the entity's concept by name as an inclusion term. Restores the two
--    codes W3.2d removed under the stricter reading: toothache K08.8 ("Toothache NOS") and
--    tooth-sensitivity K03.8 ("Sensitive dentine"). F45.8 / F98.8 were kept and stay.

begin;

alter table public.seo_entity_relationships
  add column evidence_verified_at timestamptz,
  add column evidence_verified_by text
    constraint chk_edge_evidence_verified_by check (evidence_verified_by ~ '^(agent|human):[a-z0-9_.-]+$'),
  add constraint chk_edge_evidence_verified_pair
    check ((evidence_verified_at is null) = (evidence_verified_by is null));

comment on column public.seo_entity_relationships.evidence_verified_at is
  'When the edge was checked against an international source (DR-078). Not a clinician sign-off — that is medical_reviewer_signoff_at.';
comment on column public.seo_entity_relationships.evidence_verified_by is
  'Who/what verified the edge: agent:<source> (mesh, icd, pubmed, guideline) or human:<person fp>. Source URL in edge_note. DR-078.';

update public.seo_entity_symptom set icd10_code = 'K08.8', updated_at = now()
where entity_fp = 'toothache' and icd10_code is null;
update public.seo_entity_symptom set icd10_code = 'K03.8', updated_at = now()
where entity_fp = 'tooth-sensitivity' and icd10_code is null;

commit;
