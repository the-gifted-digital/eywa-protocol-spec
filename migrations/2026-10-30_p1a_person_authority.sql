-- P1a · DR-083 Person Authority Layer (DRAFT, not applied — operator runs it) · 2026-10-30
-- 1) seo_authors_reviewers / seo_doctor_assignments: person identity + per-brand profile fields
-- 2) NEW seo_reviewer_scope      — doctor × brand × cluster → primary | co_review | excluded (gate for byline + reviewedBy)
-- 3) NEW seo_person_profiles     — one row per URL of a doctor; the ONLY source of sameAs (one store per fact)
-- 4) NEW seo_referral_pathways   — clinical reason for cross-brand links (DR-021); links point at a pathway
-- 5) person-level measurement: subject_author_fp on brand_mentions / llm_citations / llm_query_simulations
-- 6) views: v_person_same_as · v_review_scope_violations · v_cross_brand_links_without_pathway · v_reviewed_flag_without_record
-- Follows K0a: RLS on, no policies, nothing granted to anon/authenticated (service_role only).
-- Soft FKs on cluster_slug / page fingerprints, same as page_master (gates check them).
-- Run in the Supabase SQL editor as one transaction.

begin;

-- ── 1. extend existing tables ────────────────────────────────────────────────
alter table public.seo_authors_reviewers
  add column if not exists person_iri text,               -- canonical @id on the entity home, e.g. https://example.com/#person
  add column if not exists entity_home_url text,
  add column if not exists wikidata_id text,              -- planned in Bible (~§14274), never applied
  add column if not exists orcid_id text,
  add column if not exists license_registry_url text,     -- public verification page at the professional council
  add column if not exists knows_about_entity_fps text[], -- seo_entity_graph fingerprints (soft FK)
  add column if not exists alumni_of jsonb,               -- [{"org":"…","program":"…","year":2010}]
  add column if not exists memberships jsonb,             -- [{"org":"…","role":"Diplomate","since":2015}]
  add column if not exists authority_program text not null default 'none';

alter table public.seo_authors_reviewers
  add constraint chk_ar_authority_program check (authority_program in ('none','active','paused')),
  add constraint chk_ar_wikidata_format  check (wikidata_id is null or wikidata_id ~ '^Q[0-9]+$'),
  add constraint chk_ar_orcid_format     check (orcid_id is null or orcid_id ~ '^\d{4}-\d{4}-\d{4}-\d{3}[\dX]$'),
  add constraint chk_ar_person_iri_home  check (person_iri is null or (entity_home_url is not null and person_iri like entity_home_url || '%'));
create unique index if not exists uq_ar_person_iri on public.seo_authors_reviewers (person_iri) where person_iri is not null;

comment on column public.seo_authors_reviewers.person_iri is
  'DR-083: canonical schema.org @id of the person (entity home). Brand profile pages keep their own <profile>#entity @id and list the entity home in sameAs. sameAs itself is NOT stored here — read v_person_same_as.';

alter table public.seo_doctor_assignments
  add column if not exists profile_url text,     -- this brand''s profile page for the doctor (its @id = profile_url || '#entity')
  add column if not exists display_title jsonb;  -- {"th":"ผู้อำนวยการแพทย์","en":"Medical Director"} — what the brand shows
create unique index if not exists uq_da_profile_url on public.seo_doctor_assignments (profile_url) where profile_url is not null;

-- ── 2. reviewer scope ────────────────────────────────────────────────────────
create table if not exists public.seo_reviewer_scope (
  id                  uuid primary key default gen_random_uuid(),
  fingerprint         text not null unique default ('rvsc_' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 16))),
  author_id           uuid not null references public.seo_authors_reviewers(id) on delete cascade,
  brand_id            uuid not null references public.brands(id) on delete cascade,
  cluster_slug        text not null,             -- seo_topic_cluster_master.cluster_slug = page_master.cluster_id (soft FK)
  scope_level         text not null check (scope_level in ('primary','co_review','excluded')),
  basis               text,                      -- board / training / licence that justifies the level
  co_reviewer_fp      text,                      -- required reviewer when scope_level = co_review
  decided_by          text not null,
  decided_at          date not null default current_date,
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (author_id, brand_id, cluster_slug),
  constraint chk_rvsc_basis    check (scope_level = 'excluded' or basis is not null),
  constraint chk_rvsc_coreview check (scope_level <> 'co_review' or co_reviewer_fp is not null)
);
comment on table public.seo_reviewer_scope is
  'DR-083: which clusters a doctor may review at a brand. No primary/co_review row = the doctor''s name must not appear as reviewer on that brand+cluster. v_review_scope_violations must return 0 rows.';

-- ── 3. person profiles (sameAs registry) ─────────────────────────────────────
create table if not exists public.seo_person_profiles (
  id                  uuid primary key default gen_random_uuid(),
  fingerprint         text not null unique default ('pprf_' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 16))),
  author_id           uuid not null references public.seo_authors_reviewers(id) on delete cascade,
  profile_type        text not null check (profile_type in
                        ('entity_home','brand_profile','license_registry','professional_network','academic','media','social','other')),
  platform            text,                      -- 'linkedin','orcid','dental_council','youtube', brand slug …
  url                 text not null unique,
  brand_id            uuid references public.brands(id) on delete set null,
  include_in_same_as  boolean not null default true,
  is_owned            boolean not null default false,   -- we control the content (entity home, brand pages)
  name_as_displayed   text,                              -- exact name on that page → consistency check
  verified_at         timestamptz,
  last_checked_at     timestamptz,
  last_http_status    smallint,
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint chk_pprf_brand check (profile_type <> 'brand_profile' or brand_id is not null),
  constraint chk_pprf_https check (url ~ '^https://')
);
create unique index if not exists uq_pprf_one_home on public.seo_person_profiles (author_id) where profile_type = 'entity_home';
comment on table public.seo_person_profiles is
  'DR-083: every URL that represents a doctor. The only store for sameAs (read v_person_same_as).';

-- ── 4. referral pathways ─────────────────────────────────────────────────────
create table if not exists public.seo_referral_pathways (
  id                  uuid primary key default gen_random_uuid(),
  fingerprint         text not null unique default ('rfpw_' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 16))),
  from_cluster_slug   text not null,
  to_cluster_slug     text not null,
  from_brand_id       uuid references public.brands(id) on delete cascade,  -- null = any brand carrying the cluster
  to_brand_id         uuid references public.brands(id) on delete cascade,
  clinical_reason_th  text not null,
  clinical_reason_en  text,
  evidence_citation_fp text,                     -- seo_citations fingerprint (soft FK), optional
  endorsed_by_author_fp text,                    -- clinician who confirmed the pathway is real practice
  status              text not null default 'proposed' check (status in ('proposed','approved','retired')),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint chk_rfpw_distinct check (from_cluster_slug <> to_cluster_slug or from_brand_id is distinct from to_brand_id),
  constraint chk_rfpw_endorsed check (status <> 'approved' or endorsed_by_author_fp is not null)
);
create unique index if not exists uq_rfpw_route on public.seo_referral_pathways
  (from_cluster_slug, to_cluster_slug, coalesce(from_brand_id, '00000000-0000-0000-0000-000000000000'::uuid),
   coalesce(to_brand_id, '00000000-0000-0000-0000-000000000000'::uuid));

alter table public.seo_page_internal_links
  add column if not exists referral_pathway_fp text references public.seo_referral_pathways(fingerprint) on delete set null;

-- ── 5. person-level measurement ──────────────────────────────────────────────
alter table public.seo_brand_mentions        add column if not exists subject_author_fp text references public.seo_authors_reviewers(fingerprint) on delete set null;
alter table public.seo_llm_citations         add column if not exists subject_author_fp text references public.seo_authors_reviewers(fingerprint) on delete set null;
alter table public.seo_llm_query_simulations add column if not exists subject_author_fp text references public.seo_authors_reviewers(fingerprint) on delete set null;

alter table public.seo_brand_mentions alter column brand_id drop not null;
alter table public.seo_brand_mentions
  add constraint chk_bm_subject check (brand_id is not null or subject_author_fp is not null);

-- ── 6. views ─────────────────────────────────────────────────────────────────
-- sameAs for any page about the doctor; the caller removes the page's own URL.
create or replace view public.v_person_same_as with (security_invoker = true) as
select ar.fingerprint as author_fp, ar.person_iri, ar.entity_home_url,
       array_agg(pp.url order by (pp.profile_type = 'entity_home') desc, pp.profile_type, pp.url)
         filter (where pp.include_in_same_as and (pp.last_http_status is null or pp.last_http_status between 200 and 399)) as same_as,
       count(*) filter (where pp.name_as_displayed is not null
                          and pp.name_as_displayed not in (ar.canonical_names->>'th', ar.canonical_names->>'en', ar.full_name)) as name_mismatches
  from public.seo_authors_reviewers ar
  join public.seo_person_profiles pp on pp.author_id = ar.id
 group by ar.fingerprint, ar.person_iri, ar.entity_home_url, ar.canonical_names, ar.full_name;

-- approved/pending medical reviews by a doctor on a brand+cluster where the doctor has no primary/co_review scope.
-- Only doctors in the authority program are checked, so other brands are not flooded on day one.
create or replace view public.v_review_scope_violations with (security_invoker = true) as
select b.brand_slug, p.cluster_id, p.page_fingerprint, p.slug, e.review_status,
       ar.fingerprint as reviewer_fp, coalesce(s.scope_level, 'no_scope_row') as scope_level
  from public.seo_editorial_reviews e
  join public.seo_website_page_master p on p.page_fingerprint = e.page_fp
  join public.brands b on p.brand_id in (b.id::text, b.brand_slug)
  join public.seo_authors_reviewers ar on ar.fingerprint = e.reviewer_fp and ar.authority_program = 'active'
  left join public.seo_reviewer_scope s on s.author_id = ar.id and s.brand_id = b.id and s.cluster_slug = p.cluster_id
 where e.review_type = 'medical'
   and e.review_status in ('pending','in_progress','approved')
   and coalesce(s.scope_level, 'excluded') = 'excluded';

-- cross-brand links that carry no clinical pathway (DR-021 + DR-083).
create or replace view public.v_cross_brand_links_without_pathway with (security_invoker = true) as
select l.fingerprint, l.from_page_fp, l.to_page_fp, l.to_external_url, l.anchor_text, l.status, l.cross_brand_justification
  from public.seo_page_internal_links l
 where l.is_cross_brand and l.referral_pathway_fp is null;

-- pages that say "medically reviewed" with no approved medical review on record — for each brand team to check.
create or replace view public.v_reviewed_flag_without_record with (security_invoker = true) as
select p.brand_id, p.page_fingerprint, p.slug, p.status, p.cluster_id,
       (select count(*) from public.seo_editorial_reviews e
         where e.page_fp = p.page_fingerprint and e.review_type = 'medical' and e.review_status = 'pending') as pending_reviews
  from public.seo_website_page_master p
 where p.has_medical_review
   and not exists (select 1 from public.seo_editorial_reviews e
                    where e.page_fp = p.page_fingerprint and e.review_type = 'medical' and e.review_status = 'approved');

-- ── 7. security (K0a) ────────────────────────────────────────────────────────
alter table public.seo_reviewer_scope    enable row level security;
alter table public.seo_person_profiles   enable row level security;
alter table public.seo_referral_pathways enable row level security;
revoke all on public.seo_reviewer_scope, public.seo_person_profiles, public.seo_referral_pathways,
              public.v_person_same_as, public.v_review_scope_violations,
              public.v_cross_brand_links_without_pathway, public.v_reviewed_flag_without_record
  from anon, authenticated;

commit;
