-- W3.6 · entity_type fixes (DRAFT, not applied) · 2026-10-23
-- Rule (Bible App. A.1 + Entity_Identity_SOP §1/§8 + Schema §4.1):
--   procedure/treatment = an act performed (ext: seo_entity_procedures)
--   device              = a physical object, appliance, machine, implant/prosthesis variant (ext: seo_entity_devices)
--   materials           = stay device (no material type exists; ingredient = skincare active)
--   concept             = idea/marketing construct, no ext; condition = disorder (ext: seo_entity_condition)
-- Umbrella service entities (dental-crown, dental-implant, denture ...) are NOT touched here: operator call.
-- Ext rows move with entity_fp, mesh_id, contraindications, load_from, load_source (the only shared columns).
-- Comments sit after the trailing ; or , on each line.

begin;

create table public.bak_w36_20261023_entity_type as
select 'seo_entity_graph'::text as src, g.entity_fingerprint as fp, to_jsonb(g) as row_data, now() as backed_up_at
  from public.seo_entity_graph g
 where g.entity_fingerprint in ('mad','gold-crown','ssc-pedo','orthodontic-retainer','thermoformed-aligner','dental-autoclave','opg-machine','intraoral-scanner','dental-laser','dental-photography','pncl-dashboard','dental-anxiety-child')
union all
select 'seo_entity_procedures', p.entity_fp, to_jsonb(p), now()
  from public.seo_entity_procedures p
 where p.entity_fp in ('mad','ssc-pedo','orthodontic-retainer')
union all
select 'seo_entity_devices', d.entity_fp, to_jsonb(d), now()
  from public.seo_entity_devices d
 where d.entity_fp in ('mad','pncl-dashboard'); -- 12 graph + 3 procedures + 2 devices = 17 rows expected

-- 1 · graph retypes (guarded on old type and live lifecycle)
update public.seo_entity_graph set entity_type='device', schema_org_type='MedicalDevice' where entity_fingerprint='mad' and entity_type='treatment' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- name is "Mandibular Advancement Device"; act sense already held by oral-appliance-therapy; MeSH D017090 Occlusal Splints = E07
update public.seo_entity_graph set entity_type='device', schema_org_type='MedicalDevice' where entity_fingerprint='gold-crown' and entity_type='treatment' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- material variant of crown; siblings zirconia-crown/emax-crown/pfm-crown are device; schema_org already MedicalDevice
update public.seo_entity_graph set entity_type='device', schema_org_type='MedicalDevice' where entity_fingerprint='ssc-pedo' and entity_type='treatment' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- prefabricated stainless steel crown = object; act sense held by pediatric-crown (treatment)
update public.seo_entity_graph set entity_type='device', schema_org_type='MedicalDevice' where entity_fingerprint='orthodontic-retainer' and entity_type='treatment' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- appliance; children fixed-retainer/removable-retainer are device; MeSH D018704 Orthodontic Retainers
update public.seo_entity_graph set entity_type='device', schema_org_type='MedicalDevice' where entity_fingerprint='thermoformed-aligner' and entity_type='concept' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- vacuum-formed aligner = physical appliance; was concept with MedicalProcedure
update public.seo_entity_graph set entity_type='device' where entity_fingerprint='dental-autoclave' and entity_type='technology' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- sterilizer machine; App. A.1 equipment = device; schema_org already MedicalDevice
update public.seo_entity_graph set entity_type='device' where entity_fingerprint='opg-machine' and entity_type='technology' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- panoramic X-ray machine; the act is opg-xray (procedure)
update public.seo_entity_graph set entity_type='device' where entity_fingerprint='intraoral-scanner' and entity_type='technology' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- scanner hardware; brand children aoralscan/trios-intraoral-scanner are device
update public.seo_entity_graph set entity_type='device' where entity_fingerprint='dental-laser' and entity_type='technology' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- laser unit; child fotona-lightwalker is device; act is laser-dentistry (treatment)
update public.seo_entity_graph set entity_type='procedure', schema_org_type='MedicalProcedure' where entity_fingerprint='dental-photography' and entity_type='technology' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- act of taking clinical photos; MeSH D010781 Photography = E01/E05 techniques
update public.seo_entity_graph set entity_type='concept', schema_org_type='DefinedTerm' where entity_fingerprint='pncl-dashboard' and entity_type='device' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- brand outcomes dashboard; SOP §8 lists it as a marketing concept; device ext row is all-null
update public.seo_entity_graph set entity_type='condition' where entity_fingerprint='dental-anxiety-child' and entity_type='concept' and lower(coalesce(entity_lifecycle,'')) not in ('merged','dropped'); -- sibling dental-anxiety-adult is condition; already has seo_entity_condition row and MedicalCondition

-- 2 · ext rows: procedures -> devices
update public.seo_entity_devices d
   set mesh_id = coalesce(d.mesh_id, p.mesh_id),
       contraindications = coalesce(d.contraindications, p.contraindications),
       load_source = concat_ws('; ', coalesce(d.load_source, p.load_source), 'w36 2026-10-23 merged from seo_entity_procedures'),
       updated_at = now()
  from public.seo_entity_procedures p
 where p.entity_fp = d.entity_fp and d.entity_fp = 'mad'; -- mad already had an empty device row; fill it from the procedures row

insert into public.seo_entity_devices (entity_fp, mesh_id, contraindications, load_from, load_source)
select p.entity_fp, p.mesh_id, p.contraindications, p.load_from,
       concat_ws('; ', p.load_source, 'w36 2026-10-23 moved from seo_entity_procedures')
  from public.seo_entity_procedures p
 where p.entity_fp in ('ssc-pedo','orthodontic-retainer')
on conflict (entity_fp) do nothing; -- keeps contraindications so entity-clinical.json output is unchanged

delete from public.seo_entity_procedures where entity_fp in ('mad','ssc-pedo','orthodontic-retainer'); -- now device-typed

-- 3 · ext rows: new empty rows for types that need one
insert into public.seo_entity_devices (entity_fp, load_source)
select fp, 'w36 2026-10-23 retype stub'
  from unnest(array['gold-crown','thermoformed-aligner','dental-autoclave','opg-machine','intraoral-scanner','dental-laser']) as fp
on conflict (entity_fp) do nothing; -- 6 stubs

insert into public.seo_entity_procedures (entity_fp, load_source)
values ('dental-photography', 'w36 2026-10-23 retype stub')
on conflict (entity_fp) do nothing; -- 1 stub

delete from public.seo_entity_devices where entity_fp = 'pncl-dashboard'; -- concept has no ext table; row was all-null (backed up)

-- 4 · assertions
do $$
declare n_wrong int; n_orphan int;
begin
  select count(*) into n_wrong from public.seo_entity_graph g
   join (values ('mad','device'),('gold-crown','device'),('ssc-pedo','device'),('orthodontic-retainer','device'),
                ('thermoformed-aligner','device'),('dental-autoclave','device'),('opg-machine','device'),
                ('intraoral-scanner','device'),('dental-laser','device'),('dental-photography','procedure'),
                ('pncl-dashboard','concept'),('dental-anxiety-child','condition')) v(fp, t)
     on v.fp = g.entity_fingerprint
  where g.entity_type <> v.t;
  select count(*) into n_orphan from (
    select d.entity_fp from public.seo_entity_devices d join public.seo_entity_graph g on g.entity_fingerprint=d.entity_fp where g.entity_type<>'device' and d.entity_fp<>'cbct-scan'
    union all
    select p.entity_fp from public.seo_entity_procedures p join public.seo_entity_graph g on g.entity_fingerprint=p.entity_fp where g.entity_type not in ('procedure','treatment')) x;
  if n_wrong <> 0 or n_orphan <> 0 then
    raise exception 'w36 assertion failed: wrong_type=% ext_mismatch=%', n_wrong, n_orphan;
  end if;
end $$; -- cbct-scan stray device row is pre-existing and left for the operator

commit;
