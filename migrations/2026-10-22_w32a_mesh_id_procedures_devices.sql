-- W3.2a (DR-078): MeSH for procedures, treatments and devices
-- DR-050 gives procedures/treatments/devices no code column (ICD names diseases, not
-- what is done to them). MeSH covers procedures and devices (trees E and E07), is
-- free and international, and links PubMed — so it becomes their identifier.
-- One store per fact: procedures + treatments -> seo_entity_procedures, devices -> seo_entity_devices.
-- Format: MeSH descriptor (D + 6–9 digits) or supplementary concept (C + 6–9 digits), no prefix.

begin;

alter table public.seo_entity_procedures add column mesh_id text
  constraint chk_procedures_mesh_id check (mesh_id ~ '^[DC][0-9]{6,9}$');
alter table public.seo_entity_devices add column mesh_id text
  constraint chk_devices_mesh_id check (mesh_id ~ '^[DC][0-9]{6,9}$');

comment on column public.seo_entity_procedures.mesh_id is
  'MeSH descriptor/supplementary id (e.g. D003813) for the procedure or treatment itself — never the disease it treats (DR-050 §1.1). Filled from Wikidata P486 or the NLM MeSH API. DR-078.';
comment on column public.seo_entity_devices.mesh_id is
  'MeSH descriptor/supplementary id for the device or material (tree E07 / D). Filled from Wikidata P486 or the NLM MeSH API. DR-078.';

commit;
