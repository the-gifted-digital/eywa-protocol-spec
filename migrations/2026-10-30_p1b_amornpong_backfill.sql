-- P1b · DR-083 backfill for ทพ.ดร. อมรพงษ์ วชิรมน (auth_E964C7C14EED40E4) (DRAFT, not applied) · 2026-10-30
-- Requires P1a. Decisions from operator 2026-10-31:
--   · entity home = https://dr-amornpong.com/ (Cloudflare zone to be added later) → person_iri https://dr-amornpong.com/#person
--   · he holds a role at all 8 brands below; roles for 5 of them to be supplied later
--   · reviewer scope: operator considers his scope sufficient; matrix to be re-reviewed (docs/person-authority/amornpong-reviewer-scope.md)
-- Evidence for the 2 roles inserted here:
--   the-face-by-vertex → eywa-the-face-hospital/web/src/data/doctors.json  (Medical Director, The Face by Vertex)
--   vitality-hospital  → eywa-vitality-hospital/brand-config.json _kol_doctor (referral specialist, sleep–brain–airway–longevity)
-- Run in the Supabase SQL editor as one transaction.

begin;

-- 1 · identity + program + brand scope (all 8 brands the operator confirmed)
update public.seo_authors_reviewers
   set authority_program = 'active',
       entity_home_url   = 'https://dr-amornpong.com/',
       person_iri        = 'https://dr-amornpong.com/#person',
       brand_scope = (select array_agg(distinct s order by s) from unnest(brand_scope || array[
                        'vth-biodent','the-face-by-vertex','vitality-hospital','vitalsleep-clinic',
                        'tc-smile-dental','clearisma','hisher-vitality','vth-dental-vitality']) s),
       updated_at = now()
 where fingerprint = 'auth_E964C7C14EED40E4';

-- 2 · entity home in the sameAs registry (last_http_status stays null until the site is live and checked)
insert into public.seo_person_profiles (author_id, profile_type, platform, url, is_owned, name_as_displayed, notes)
select id, 'entity_home', 'own-domain', 'https://dr-amornpong.com/', true, canonical_names->>'th',
       'DR-083 entity home; not live yet (Cloudflare zone pending)'
  from public.seo_authors_reviewers where fingerprint = 'auth_E964C7C14EED40E4'
on conflict (url) do nothing;

-- 3 · assignments with a known role (vth-biodent medical_director already exists: docasg_282B55B52C3044A9)
insert into public.seo_doctor_assignments
       (fingerprint, fingerprint_display_name, author_id, author_fp, brand_id, role_at_brand, is_primary_role, display_title, sync_state)
select 'docasg_' || upper(substr(md5(random()::text || clock_timestamp()::text || x.slug), 1, 16)),
       upper(substr(md5(random()::text || x.slug), 1, 6)) || '::' || x.role,
       ar.id, ar.fingerprint, b.id, x.role, false, x.title::jsonb, 'flat_loaded'
  from (values
          ('the-face-by-vertex', 'medical_director', '{"th":"ผู้อำนวยการแพทย์","en":"Medical Director"}'),
          ('vitality-hospital',  'consultant',       '{"th":"ทันตแพทย์ผู้เชี่ยวชาญด้านการนอนหลับ ทางเดินหายใจ และใบหน้า","en":"Referral Specialist — Sleep, Airway & Facial"}')
       ) as x(slug, role, title)
  join public.brands b on b.brand_slug = x.slug
  join public.seo_authors_reviewers ar on ar.fingerprint = 'auth_E964C7C14EED40E4'
 where not exists (select 1 from public.seo_doctor_assignments d
                    where d.author_id = ar.id and d.brand_id = b.id and d.ended_at is null);

do $$
declare n int; s int;
begin
  select count(*) into n from public.seo_doctor_assignments d
    join public.seo_authors_reviewers ar on ar.id = d.author_id
   where ar.fingerprint = 'auth_E964C7C14EED40E4' and d.ended_at is null;
  select cardinality(brand_scope) into s from public.seo_authors_reviewers where fingerprint = 'auth_E964C7C14EED40E4';
  if n < 3 then raise exception 'P1b: expected >= 3 active assignments, got %', n; end if;
  if s < 8 then raise exception 'P1b: expected brand_scope >= 8, got %', s; end if;
end $$;

-- TODO (follow-up migration P1c, when the operator supplies details):
--   a) roles + display_title for vitalsleep-clinic, tc-smile-dental, clearisma, hisher-vitality, vth-dental-vitality
--   b) profile_url per assignment + seo_person_profiles 'brand_profile' rows (name_as_displayed = exact name on the page)
--   c) dental council registry URL → license_registry_url + 'license_registry' profile; medical_license_verified_at only after a person checked it
--   d) seo_reviewer_scope rows from the re-reviewed matrix
--   e) after dr-amornpong.com is live: set last_http_status / verified_at on the entity_home row

commit;
