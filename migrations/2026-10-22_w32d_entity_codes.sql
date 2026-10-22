-- W3.2d (DR-078): medical codes for conditions, symptoms, procedures and devices
-- Decisions come from two reviewer agents that read only official sources (WHO ICD-10 2019 +
-- 10To11 map, WHO ICD-11 MMS 2025-01 tabulation, ICD-10-CM, NLM MeSH); each statement carries the
-- source. Applied: high + medium confidence. Not applied: 7 low-confidence rows, and the residual
-- question (WHO "other" codes that list the concept by name: F45.8 bruxism, F98.8 oral habits,
-- K08.8 toothache, K03.8 sensitive dentine) — left as stored pending a decision.
-- Overrides of the reviewer: bruxism.icd11_code -> null (7A83 is sleep bruxism, which has its own
-- entity); oral-cancer.icd10_code -> null ("C00-C14" is a block, C06.9 a residual bucket).
-- Every UPDATE is guarded on the value the reviewer saw, so a row changed since is skipped.
-- Corrections include: CM codes removed from the WHO icd10_code column (G47.63, G47.33, R06.83,
-- K08.89 ...), ICD-11 Foundation ids and wrong concepts replaced (7A85 = benign sleep myoclonus of
-- infancy, DA0F.0 = burning mouth syndrome), nickel-allergy Z91.041 (radiographic-dye allergy) -> L23.0,
-- malformed icd10_codes_related cleaned.

begin;

create table public.bak_w32d_20261022 as
  select 'seo_entity_condition' t, entity_fp, to_jsonb(x) row from seo_entity_condition x
  union all select 'seo_entity_symptom', entity_fp, to_jsonb(x) from seo_entity_symptom x
  union all select 'seo_entity_procedures', entity_fp, jsonb_build_object('mesh_id', mesh_id) from seo_entity_procedures x
  union all select 'seo_entity_devices', entity_fp, jsonb_build_object('mesh_id', mesh_id) from seo_entity_devices x;
alter table public.bak_w32d_20261022 enable row level security;

-- 1. conditions / symptoms (decisions: tmp/codes-conditions-2026-10-22.json, high+medium only)
insert into public.seo_entity_condition (entity_fp, load_source) select fp, 'W3.2d 2026-10-22' from (values ('alveolar-bone-loss'), ('autonomic-dysregulation'), ('awake-bruxism'), ('bruxism'), ('cracked-tooth'), ('dental-abscess'), ('dental-caries-extraction'), ('gerd-tooth-erosion'), ('gum-recession'), ('horizontal-bone-deficiency'), ('impacted-wisdom-tooth'), ('jaw-asymmetry'), ('jaw-cyst'), ('lost-filling-crown'), ('missing-tooth'), ('multiple-missing-teeth'), ('non-vital-tooth'), ('oral-cancer'), ('oral-habits'), ('osa-airway-narrowing'), ('osteoporosis-on-oral-bisphosphonate'), ('osteoradionecrosis'), ('pediatric-airway'), ('pediatric-bruxism'), ('pediatric-dental-trauma'), ('pediatric-malocclusion'), ('pediatric-mouth-breathing'), ('pediatric-snoring'), ('pediatric-tmd'), ('pediatric-tongue-tie'), ('periodontal-pocket'), ('pregnancy-gingivitis'), ('premature-wrinkles'), ('primary-tooth-cavity'), ('root-caries'), ('short-teeth'), ('single-missing-tooth'), ('sleep-bruxism'), ('stress-bruxism'), ('stress-burnout'), ('tmj-disorder'), ('tongue-thrust'), ('tooth-avulsion'), ('tooth-shape-anomaly'), ('tooth-staining-external'), ('tooth-tipping'), ('torus-mandibularis-palatinus'), ('traumatic-tooth-loss'), ('vertical-bone-deficiency'), ('white-spot-lesion')) v(fp) where exists (select 1 from seo_entity_graph g where g.entity_fingerprint = v.fp) on conflict (entity_fp) do nothing;
insert into public.seo_entity_symptom (entity_fp, load_source) select fp, 'W3.2d 2026-10-22' from (values ('chronic-fatigue'), ('loose-tooth'), ('orofacial-paresthesia'), ('sensitivity-post-whitening'), ('tmj-clicking'), ('tmj-pain'), ('tooth-sensitivity')) v(fp) where exists (select 1 from seo_entity_graph g where g.entity_fingerprint = v.fp) on conflict (entity_fp) do nothing;
-- adenoid-face.icd10_code: J35.2 -> None (correct, medium)  | J35.2 codes adenoid hypertrophy (the cause), not the facial phenotype; no WHO code for ade | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'adenoid-face' and icd10_code is not distinct from 'J35.2';
-- adenoid-face.icd10_cm_code: J35.2 -> None (correct, medium)  | Same: CM J35.2 is adenoid hypertrophy, not adenoid facies | https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_cm_code = null, updated_at = now() where entity_fp = 'adenoid-face' and icd10_cm_code is not distinct from 'J35.2';
-- adenoid-face.icd11_code: CA0F.1 -> None (correct, medium)  | CA0F.1 Hypertrophy of adenoids = cause, not concept | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'adenoid-face' and icd11_code is not distinct from 'CA0F.1';
-- alveolar-bone-loss.icd10_code: K06.3 -> None (correct, medium)  | K06.3 is ICD-10-CM only; WHO has no alveolar bone loss code (K08.2 = edentulous ridge only | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'alveolar-bone-loss' and icd10_code is not distinct from 'K06.3';
-- alveolar-bone-loss.mesh_id: None -> D016301 (fill, high) Alveolar Bone Loss | Exact descriptor | https://id.nlm.nih.gov/mesh/D016301.html
update public.seo_entity_condition set mesh_id = 'D016301', updated_at = now() where entity_fp = 'alveolar-bone-loss' and mesh_id is not distinct from null::text;
-- autonomic-dysregulation.mesh_id: None -> D001342 (fill, medium) Autonomic Nervous System Diseases | Autonomic Nervous System Diseases; Primary Dysautonomias D054969 narrower | https://id.nlm.nih.gov/mesh/D001342.html
update public.seo_entity_condition set mesh_id = 'D001342', updated_at = now() where entity_fp = 'autonomic-dysregulation' and mesh_id is not distinct from null::text;
-- awake-bruxism.mesh_id: None -> D002012 (fill, high) Bruxism | Bruxism | https://id.nlm.nih.gov/mesh/D002012.html
update public.seo_entity_condition set mesh_id = 'D002012', updated_at = now() where entity_fp = 'awake-bruxism' and mesh_id is not distinct from null::text;
-- bleeding-disorders.icd11_code: 1016799900 -> None (correct, medium)  | Foundation id of block 'Coagulation defects' (no MMS code); only 3B6Z residual exists | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'bleeding-disorders' and icd11_code is not distinct from '1016799900';
-- bruxism.icd10_code: G47.63 -> None (correct, high)  | G47.63 is ICD-10-CM only; WHO has no specific bruxism code (F45.8/G47.8 residual) | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'bruxism' and icd10_code is not distinct from 'G47.63';
-- bruxism.icd11_code: 7A85 -> None (correct, medium) Sleep-related bruxism | OVERRIDE: 7A83 is sleep-related bruxism = the sleep-bruxism entity; bruxism (awake + sleep | https://icd.who.int/browse/2025-01/mms/en#60908067
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'bruxism' and icd11_code is not distinct from '7A85';
-- bruxism.mesh_id: None -> D002012 (fill, high) Bruxism | Bruxism | https://id.nlm.nih.gov/mesh/D002012.html
update public.seo_entity_condition set mesh_id = 'D002012', updated_at = now() where entity_fp = 'bruxism' and mesh_id is not distinct from null::text;
-- canker-sore.icd11_code: 2135294385 -> DA01.10 (correct, high) Oral aphthae or aphtha-like ulceration | Foundation id in MMS column; WHO K12.0 maps to DA01.10 | https://icd.who.int/browse/2025-01/mms/en#365022111
update public.seo_entity_condition set icd11_code = 'DA01.10', updated_at = now() where entity_fp = 'canker-sore' and icd11_code is not distinct from '2135294385';
-- cardiovascular-disease-active.icd10_code: I25.9 -> None (correct, medium)  | Chronic IHD contradicts 'active' (recent MI/unstable angina); I51.6 residual; no specific  | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'cardiovascular-disease-active' and icd10_code is not distinct from 'I25.9';
-- cardiovascular-disease-active.icd10_cm_code: I25.9 -> None (correct, medium)  | Same: chronic IHD is wrong concept for active/unstable state | https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_cm_code = null, updated_at = now() where entity_fp = 'cardiovascular-disease-active' and icd10_cm_code is not distinct from 'I25.9';
-- cardiovascular-disease-active.icd11_code: BE2Z -> None (correct, high)  | Chapter-level 'unspecified' residual | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'cardiovascular-disease-active' and icd11_code is not distinct from 'BE2Z';
-- cracked-tooth.icd10_cm_code: S02.5XXA -> K03.81 (correct, high) Cracked tooth | Cracked tooth is non-traumatic; S02.5XXA is traumatic tooth fracture | https://icd10cmtool.cdc.gov/?fy=FY2027&query=K03.81
update public.seo_entity_condition set icd10_cm_code = 'K03.81', updated_at = now() where entity_fp = 'cracked-tooth' and icd10_cm_code is not distinct from 'S02.5XXA';
-- cracked-tooth.icd11_code: None -> DA08.3 (fill, medium) Nontraumatic fracture of tooth | Nontraumatic fracture of tooth | https://icd.who.int/browse/2025-01/mms/en#1299071429
update public.seo_entity_condition set icd11_code = 'DA08.3', updated_at = now() where entity_fp = 'cracked-tooth' and icd11_code is not distinct from null::text;
-- cracked-tooth.mesh_id: None -> D003387 (fill, high) Cracked Tooth Syndrome | Cracked Tooth Syndrome | https://id.nlm.nih.gov/mesh/D003387.html
update public.seo_entity_condition set mesh_id = 'D003387', updated_at = now() where entity_fp = 'cracked-tooth' and mesh_id is not distinct from null::text;
-- dark-gums.icd10_code: K06.8 -> None (correct, medium)  | Residual 'other specified'; no inclusion term for pigmentation | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'dark-gums' and icd10_code is not distinct from 'K06.8';
-- dark-gums.icd10_cm_code: K06.8 -> None (correct, medium)  | Residual 'other specified' | https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_cm_code = null, updated_at = now() where entity_fp = 'dark-gums' and icd10_cm_code is not distinct from 'K06.8';
-- dark-gums.icd11_code: DA0D -> None (correct, medium)  | DA0D is a heterogeneous parent category, not pigmentation | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'dark-gums' and icd11_code is not distinct from 'DA0D';
-- dental-abscess.mesh_id: None -> D010482 (fill, high) Periapical Abscess | Periapical Abscess | https://id.nlm.nih.gov/mesh/D010482.html
update public.seo_entity_condition set mesh_id = 'D010482', updated_at = now() where entity_fp = 'dental-abscess' and mesh_id is not distinct from null::text;
-- dental-caries.icd11_code: DA08 -> DA08.0 (correct, high) Dental caries | DA08 is 'Diseases of hard tissues of teeth'; DA08.0 is Dental caries | https://icd.who.int/browse/2025-01/mms/en#1983306720
update public.seo_entity_condition set icd11_code = 'DA08.0', updated_at = now() where entity_fp = 'dental-caries' and icd11_code is not distinct from 'DA08';
-- dental-caries.icd10_codes_related: ['K0202.', 'K02.6'] -> ['K02.6'] (correct, medium)  | Drop malformed 'K0202.'; keep CM K02.6 smooth-surface caries | https://icd.who.int/browse10/2019/en ; https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_codes_related = array['K02.6']::text[], updated_at = now() where entity_fp = 'dental-caries' and coalesce(icd10_codes_related, '{}') = array['K0202.', 'K02.6']::text[];
-- dental-caries-extraction.icd10_code: None -> K02 (fill, medium) Dental caries | Underlying condition is dental caries | https://icd.who.int/browse10/2019/en#/K02
update public.seo_entity_condition set icd10_code = 'K02', updated_at = now() where entity_fp = 'dental-caries-extraction' and icd10_code is not distinct from null::text;
-- dental-caries-extraction.mesh_id: None -> D003731 (fill, medium) Dental Caries | Dental Caries | https://id.nlm.nih.gov/mesh/D003731.html
update public.seo_entity_condition set mesh_id = 'D003731', updated_at = now() where entity_fp = 'dental-caries-extraction' and mesh_id is not distinct from null::text;
-- denture-stomatitis.icd11_code: DA01.0 -> None (correct, medium)  | 'Disturbances of oral epithelium' (leukoplakia etc.) is not denture stomatitis; no specifi | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'denture-stomatitis' and icd11_code is not distinct from 'DA01.0';
-- edentulism.mesh_id: D007576 -> D009066 (correct, high) Mouth, Edentulous | D007576 is 'Jaw, Edentulous, Partially'; complete tooth loss = Mouth, Edentulous | https://id.nlm.nih.gov/mesh/D009066.html
update public.seo_entity_condition set mesh_id = 'D009066', updated_at = now() where entity_fp = 'edentulism' and mesh_id is not distinct from 'D007576';
-- fluorosis.icd11_code: 5B91.3 -> DA07.0 (correct, high) Fluoride related opacities or lesions | 5B91.3 systemic fluorine excess; WHO K00.3 maps to DA07.0 | https://icd.who.int/browse/2025-01/mms/en#1561314208
update public.seo_entity_condition set icd11_code = 'DA07.0', updated_at = now() where entity_fp = 'fluorosis' and icd11_code is not distinct from '5B91.3';
-- gerd-tooth-erosion.icd10_code: K21.9 -> K03.2 (correct, medium) Erosion of teeth | Concept is tooth erosion (WHO K03.2 incl. 'persistent vomiting'), not GERD itself | https://icd.who.int/browse10/2019/en#/K03.2
update public.seo_entity_condition set icd10_code = 'K03.2', updated_at = now() where entity_fp = 'gerd-tooth-erosion' and icd10_code is not distinct from 'K21.9';
-- gerd-tooth-erosion.icd10_cm_code: K21.9 -> K03.2 (correct, medium) Erosion of teeth | Same | https://icd10cmtool.cdc.gov/?fy=FY2027&query=K03.2
update public.seo_entity_condition set icd10_cm_code = 'K03.2', updated_at = now() where entity_fp = 'gerd-tooth-erosion' and icd10_cm_code is not distinct from 'K21.9';
-- gerd-tooth-erosion.icd11_code: None -> DA08.12 (fill, medium) Erosion of teeth | Erosion of teeth | https://icd.who.int/browse/2025-01/mms/en#147176774
update public.seo_entity_condition set icd11_code = 'DA08.12', updated_at = now() where entity_fp = 'gerd-tooth-erosion' and icd11_code is not distinct from null::text;
-- gerd-tooth-erosion.mesh_id: None -> D014077 (fill, medium) Tooth Erosion | Tooth Erosion | https://id.nlm.nih.gov/mesh/D014077.html
update public.seo_entity_condition set mesh_id = 'D014077', updated_at = now() where entity_fp = 'gerd-tooth-erosion' and mesh_id is not distinct from null::text;
-- gingivitis.icd11_code: 1542018172 -> None (correct, medium)  | Foundation id; K05.1 has no MMS equivalent (WHO map gives DA0Z residual) | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'gingivitis' and icd11_code is not distinct from '1542018172';
-- gum-recession.mesh_id: None -> D005889 (fill, high) Gingival Recession | Gingival Recession | https://id.nlm.nih.gov/mesh/D005889.html
update public.seo_entity_condition set mesh_id = 'D005889', updated_at = now() where entity_fp = 'gum-recession' and mesh_id is not distinct from null::text;
-- gummy-smile.icd10_code: K06.8 -> None (correct, medium)  | Residual 'other specified'; no inclusion term | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'gummy-smile' and icd10_code is not distinct from 'K06.8';
-- gummy-smile.icd11_code: DA0D -> None (correct, medium)  | Heterogeneous parent category | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'gummy-smile' and icd11_code is not distinct from 'DA0D';
-- horizontal-bone-deficiency.icd10_code: None -> K08.2 (fill, medium) Atrophy of edentulous alveolar ridge | Implant-site ridge deficiency = atrophy of edentulous alveolar ridge | https://icd.who.int/browse10/2019/en#/K08.2
update public.seo_entity_condition set icd10_code = 'K08.2', updated_at = now() where entity_fp = 'horizontal-bone-deficiency' and icd10_code is not distinct from null::text;
-- horizontal-bone-deficiency.icd11_code: None -> DA0A.2 (fill, medium) Atrophy of edentulous alveolar ridge | Atrophy of edentulous alveolar ridge | https://icd.who.int/browse/2025-01/mms/en#2092941190
update public.seo_entity_condition set icd11_code = 'DA0A.2', updated_at = now() where entity_fp = 'horizontal-bone-deficiency' and icd11_code is not distinct from null::text;
-- horizontal-bone-deficiency.mesh_id: None -> D016301 (fill, medium) Alveolar Bone Loss | Alveolar Bone Loss | https://id.nlm.nih.gov/mesh/D016301.html
update public.seo_entity_condition set mesh_id = 'D016301', updated_at = now() where entity_fp = 'horizontal-bone-deficiency' and mesh_id is not distinct from null::text;
-- ill-fitting-denture.icd10_code: K08.89 -> None (correct, high)  | CM code in WHO column; residual 'other specified' | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'ill-fitting-denture' and icd10_code is not distinct from 'K08.89';
-- ill-fitting-denture.icd10_cm_code: K08.89 -> None (correct, medium)  | Residual 'other specified' | https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_cm_code = null, updated_at = now() where entity_fp = 'ill-fitting-denture' and icd10_cm_code is not distinct from 'K08.89';
-- immunosuppression.mesh_id: D007165 -> D016867 (correct, medium) Immunocompromised Host | D007165 is Immunosuppression Therapy (procedure); state is Immunocompromised Host | https://id.nlm.nih.gov/mesh/D016867.html
update public.seo_entity_condition set mesh_id = 'D016867', updated_at = now() where entity_fp = 'immunosuppression' and mesh_id is not distinct from 'D007165';
-- impacted-wisdom-tooth.mesh_id: None -> D014095 (fill, medium) Tooth, Impacted | Tooth, Impacted (no third-molar-specific descriptor) | https://id.nlm.nih.gov/mesh/D014095.html
update public.seo_entity_condition set mesh_id = 'D014095', updated_at = now() where entity_fp = 'impacted-wisdom-tooth' and mesh_id is not distinct from null::text;
-- implant-failure.icd10_code: M27.6 -> None (correct, high)  | M27.6 is ICD-10-CM only; no WHO equivalent | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'implant-failure' and icd10_code is not distinct from 'M27.6';
-- implant-failure.icd10_cm_code: M27.69 -> M27.6 (correct, medium) Endosseous dental implant failure | M27.69 is residual 'other'; generic failure = M27.6 category | https://icd10cmtool.cdc.gov/?fy=FY2027&query=M27.6
update public.seo_entity_condition set icd10_cm_code = 'M27.6', updated_at = now() where entity_fp = 'implant-failure' and icd10_cm_code is not distinct from 'M27.69';
-- implant-failure.icd11_code: DA0F.0 -> None (correct, high)  | DA0F.0 is Burning mouth syndrome - wrong concept | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'implant-failure' and icd11_code is not distinct from 'DA0F.0';
-- implant-failure.icd10_codes_related: ['T85.69'] -> [] (correct, medium)  | Generic residual prosthesis code; dental M27.6x is primary | https://icd.who.int/browse10/2019/en ; https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_codes_related = '{}'::text[], updated_at = now() where entity_fp = 'implant-failure' and coalesce(icd10_codes_related, '{}') = array['T85.69']::text[];
-- insomnia.icd10_code: G47.00 -> G47.0 (correct, medium) Disorders of initiating and maintaining sleep [insomnias] | G47.00 is CM-only; WHO G47.0 'insomnias' (F51.0 nonorganic narrower) | https://icd.who.int/browse10/2019/en#/G47.0
update public.seo_entity_condition set icd10_code = 'G47.0', updated_at = now() where entity_fp = 'insomnia' and icd10_code is not distinct from 'G47.00';
-- insomnia.icd10_codes_related: ['F51.0', 'G47.0'] -> ['F51.0'] (correct, medium)  | G47.0 becomes primary; F51.0 stays related | https://icd.who.int/browse10/2019/en ; https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_codes_related = array['F51.0']::text[], updated_at = now() where entity_fp = 'insomnia' and coalesce(icd10_codes_related, '{}') = array['F51.0', 'G47.0']::text[];
-- jaw-asymmetry.icd10_code: M26.12 -> K07.1 (correct, high) Anomalies of jaw-cranial base relationship | M26 is CM-only; WHO K07.1 includes 'Asymmetry of jaw' | https://icd.who.int/browse10/2019/en#/K07.1
update public.seo_entity_condition set icd10_code = 'K07.1', updated_at = now() where entity_fp = 'jaw-asymmetry' and icd10_code is not distinct from 'M26.12';
-- jaw-asymmetry.icd11_code: None -> DA0E.1 (fill, high) Anomalies of jaw-cranial base relationship | Official map of K07.1 | https://icd.who.int/browse/2025-01/mms/en#1184251077
update public.seo_entity_condition set icd11_code = 'DA0E.1', updated_at = now() where entity_fp = 'jaw-asymmetry' and icd11_code is not distinct from null::text;
-- jaw-asymmetry.mesh_id: None -> D005146 (fill, medium) Facial Asymmetry | Facial Asymmetry | https://id.nlm.nih.gov/mesh/D005146.html
update public.seo_entity_condition set mesh_id = 'D005146', updated_at = now() where entity_fp = 'jaw-asymmetry' and mesh_id is not distinct from null::text;
-- jaw-cyst.mesh_id: None -> D007570 (fill, high) Jaw Cysts | Jaw Cysts | https://id.nlm.nih.gov/mesh/D007570.html
update public.seo_entity_condition set mesh_id = 'D007570', updated_at = now() where entity_fp = 'jaw-cyst' and mesh_id is not distinct from null::text;
-- latex-allergy.icd10_code: Z91.040 -> None (correct, high)  | CM-only code in WHO column; WHO Z91.0 is generic allergy history | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'latex-allergy' and icd10_code is not distinct from 'Z91.040';
-- latex-allergy.icd11_code: 617057640 -> None (correct, medium)  | Foundation id; no MMS stem for latex allergy | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'latex-allergy' and icd11_code is not distinct from '617057640';
-- lost-filling-crown.mesh_id: None -> D019232 (fill, medium) Dental Restoration Failure | Dental Restoration Failure | https://id.nlm.nih.gov/mesh/D019232.html
update public.seo_entity_condition set mesh_id = 'D019232', updated_at = now() where entity_fp = 'lost-filling-crown' and mesh_id is not distinct from null::text;
-- methacrylate-allergy.icd10_code: T78.49 -> None (correct, high)  | CM-only; WHO T78.4 'Allergy, unspecified' residual | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'methacrylate-allergy' and icd10_code is not distinct from 'T78.49';
-- missing-tooth.icd10_code: K08.4 -> K08.1 (correct, high) Loss of teeth due to accident, extraction or local periodont | K08.4 is CM-only; WHO K08.1 covers tooth loss | https://icd.who.int/browse10/2019/en#/K08.1
update public.seo_entity_condition set icd10_code = 'K08.1', updated_at = now() where entity_fp = 'missing-tooth' and icd10_code is not distinct from 'K08.4';
-- missing-tooth.icd11_code: DA0D.0 -> DA0A.1 (correct, high) Loss of teeth due to accident, extraction or local periodont | DA0D.0 is Gingival recession - wrong concept | https://icd.who.int/browse/2025-01/mms/en#135458681
update public.seo_entity_condition set icd11_code = 'DA0A.1', updated_at = now() where entity_fp = 'missing-tooth' and icd11_code is not distinct from 'DA0D.0';
-- missing-tooth.mesh_id: None -> D016388 (fill, high) Tooth Loss | Tooth Loss | https://id.nlm.nih.gov/mesh/D016388.html
update public.seo_entity_condition set mesh_id = 'D016388', updated_at = now() where entity_fp = 'missing-tooth' and mesh_id is not distinct from null::text;
-- multiple-missing-teeth.icd10_code: K08.109 -> K08.1 (correct, high) Loss of teeth due to accident, extraction or local periodont | CM code in WHO column | https://icd.who.int/browse10/2019/en#/K08.1
update public.seo_entity_condition set icd10_code = 'K08.1', updated_at = now() where entity_fp = 'multiple-missing-teeth' and icd10_code is not distinct from 'K08.109';
-- multiple-missing-teeth.icd10_cm_code: K08.109 -> K08.409 (correct, high) Partial loss of teeth, unspecified cause, unspecified class | K08.109 is complete loss; entity is partial edentulism | https://icd10cmtool.cdc.gov/?fy=FY2027&query=K08.409
update public.seo_entity_condition set icd10_cm_code = 'K08.409', updated_at = now() where entity_fp = 'multiple-missing-teeth' and icd10_cm_code is not distinct from 'K08.109';
-- multiple-missing-teeth.mesh_id: None -> D007576 (fill, high) Jaw, Edentulous, Partially | Jaw, Edentulous, Partially | https://id.nlm.nih.gov/mesh/D007576.html
update public.seo_entity_condition set mesh_id = 'D007576', updated_at = now() where entity_fp = 'multiple-missing-teeth' and mesh_id is not distinct from null::text;
-- nasal-obstruction.icd10_code: J34.89 -> None (correct, medium)  | CM code in WHO column; WHO J34.8/R09.8 residual | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'nasal-obstruction' and icd10_code is not distinct from 'J34.89';
-- nasal-obstruction.icd10_cm_code: J34.89 -> R09.81 (correct, medium) Nasal congestion | Wikidata R09.81 Nasal congestion beats residual J34.89 | https://icd10cmtool.cdc.gov/?fy=FY2027&query=R09.81
update public.seo_entity_condition set icd10_cm_code = 'R09.81', updated_at = now() where entity_fp = 'nasal-obstruction' and icd10_cm_code is not distinct from 'J34.89';
-- nasal-obstruction.icd10_codes_related: ['R09.81'] -> [] (correct, medium)  | R09.81 becomes primary | https://icd.who.int/browse10/2019/en ; https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_codes_related = '{}'::text[], updated_at = now() where entity_fp = 'nasal-obstruction' and coalesce(icd10_codes_related, '{}') = array['R09.81']::text[];
-- nickel-allergy.icd10_code: Z91.041 -> L23.0 (correct, high) Allergic contact dermatitis due to metals | Z91.041 = radiographic dye allergy (CM-only); WHO L23.0 lists 'Nickel' | https://icd.who.int/browse10/2019/en#/L23.0
update public.seo_entity_condition set icd10_code = 'L23.0', updated_at = now() where entity_fp = 'nickel-allergy' and icd10_code is not distinct from 'Z91.041';
-- nickel-allergy.icd10_cm_code: Z91.041 -> L23.0 (correct, high) Allergic contact dermatitis due to metals | Z91.041 is radiographic dye allergy status | https://icd10cmtool.cdc.gov/?fy=FY2027&query=L23.0
update public.seo_entity_condition set icd10_cm_code = 'L23.0', updated_at = now() where entity_fp = 'nickel-allergy' and icd10_cm_code is not distinct from 'Z91.041';
-- nickel-allergy.icd10_codes_related: ['L23.0'] -> [] (correct, high)  | L23.0 becomes primary | https://icd.who.int/browse10/2019/en ; https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_codes_related = '{}'::text[], updated_at = now() where entity_fp = 'nickel-allergy' and coalesce(icd10_codes_related, '{}') = array['L23.0']::text[];
-- non-vital-tooth.icd10_code: None -> K04.1 (fill, high) Necrosis of pulp | Necrosis of pulp | https://icd.who.int/browse10/2019/en#/K04.1
update public.seo_entity_condition set icd10_code = 'K04.1', updated_at = now() where entity_fp = 'non-vital-tooth' and icd10_code is not distinct from null::text;
-- non-vital-tooth.icd10_cm_code: None -> K04.1 (fill, high) Necrosis of pulp | Necrosis of pulp | https://icd10cmtool.cdc.gov/?fy=FY2027&query=K04.1
update public.seo_entity_condition set icd10_cm_code = 'K04.1', updated_at = now() where entity_fp = 'non-vital-tooth' and icd10_cm_code is not distinct from null::text;
-- non-vital-tooth.icd11_code: None -> DA09.1 (fill, high) Necrosis of pulp | Official map of K04.1 | https://icd.who.int/browse/2025-01/mms/en#1192336635
update public.seo_entity_condition set icd11_code = 'DA09.1', updated_at = now() where entity_fp = 'non-vital-tooth' and icd11_code is not distinct from null::text;
-- non-vital-tooth.mesh_id: None -> D019553 (fill, high) Tooth, Nonvital | Tooth, Nonvital | https://id.nlm.nih.gov/mesh/D019553.html
update public.seo_entity_condition set mesh_id = 'D019553', updated_at = now() where entity_fp = 'non-vital-tooth' and mesh_id is not distinct from null::text;
-- oral-cancer.icd10_code: C00-C14 -> None (correct, medium) Malignant neoplasm: Mouth, unspecified | OVERRIDE: "C00-C14" is a block, not a code; C06.9 would be a residual bucket (SOP §4) | https://icd.who.int/browse10/2019/en#/C06.9
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'oral-cancer' and icd10_code is not distinct from 'C00-C14';
-- oral-cancer.mesh_id: None -> D009062 (fill, high) Mouth Neoplasms | Mouth Neoplasms | https://id.nlm.nih.gov/mesh/D009062.html
update public.seo_entity_condition set mesh_id = 'D009062', updated_at = now() where entity_fp = 'oral-cancer' and mesh_id is not distinct from null::text;
-- oral-habits.mesh_id: None -> D005386 (fill, high) Fingersucking | Fingersucking | https://id.nlm.nih.gov/mesh/D005386.html
update public.seo_entity_condition set mesh_id = 'D005386', updated_at = now() where entity_fp = 'oral-habits' and mesh_id is not distinct from null::text;
-- osa.icd10_code: G47.33 -> G47.3 (correct, high) Sleep apnoea | G47.33 is CM-only; WHO G47.3 includes obstructive sleep apnoea | https://icd.who.int/browse10/2019/en#/G47.3
update public.seo_entity_condition set icd10_code = 'G47.3', updated_at = now() where entity_fp = 'osa' and icd10_code is not distinct from 'G47.33';
-- osa-airway-narrowing.mesh_id: None -> D000402 (fill, medium) Airway Obstruction | Airway Obstruction | https://id.nlm.nih.gov/mesh/D000402.html
update public.seo_entity_condition set mesh_id = 'D000402', updated_at = now() where entity_fp = 'osa-airway-narrowing' and mesh_id is not distinct from null::text;
-- osteoporosis-on-oral-bisphosphonate.mesh_id: None -> D015663 (fill, medium) Osteoporosis, Postmenopausal | Osteoporosis, Postmenopausal (aliases postmenopausal) | https://id.nlm.nih.gov/mesh/D015663.html
update public.seo_entity_condition set mesh_id = 'D015663', updated_at = now() where entity_fp = 'osteoporosis-on-oral-bisphosphonate' and mesh_id is not distinct from null::text;
-- pediatric-airway.icd10_code: G47.33 -> G47.3 (correct, medium) Sleep apnoea | CM code in WHO column | https://icd.who.int/browse10/2019/en#/G47.3
update public.seo_entity_condition set icd10_code = 'G47.3', updated_at = now() where entity_fp = 'pediatric-airway' and icd10_code is not distinct from 'G47.33';
-- pediatric-airway.icd11_code: None -> 7A41 (fill, medium) Obstructive sleep apnoea | Summary describes paediatric OSA | https://icd.who.int/browse/2025-01/mms/en#1919233290
update public.seo_entity_condition set icd11_code = '7A41', updated_at = now() where entity_fp = 'pediatric-airway' and icd11_code is not distinct from null::text;
-- pediatric-airway.mesh_id: None -> D020181 (fill, medium) Sleep Apnea, Obstructive | Sleep Apnea, Obstructive | https://id.nlm.nih.gov/mesh/D020181.html
update public.seo_entity_condition set mesh_id = 'D020181', updated_at = now() where entity_fp = 'pediatric-airway' and mesh_id is not distinct from null::text;
-- pediatric-breathing.icd10_code: R06.9 -> None (correct, high)  | R06.9 not in WHO 2019 (WHO R06.8 residual) | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'pediatric-breathing' and icd10_code is not distinct from 'R06.9';
-- pediatric-breathing.icd10_cm_code: R06.9 -> None (correct, medium)  | Residual 'unspecified' | https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_cm_code = null, updated_at = now() where entity_fp = 'pediatric-breathing' and icd10_cm_code is not distinct from 'R06.9';
-- pediatric-bruxism.icd10_code: G47.63 -> None (correct, high)  | CM-only code in WHO column | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'pediatric-bruxism' and icd10_code is not distinct from 'G47.63';
-- pediatric-bruxism.icd11_code: None -> 7A83 (fill, medium) Sleep-related bruxism | Summary describes sleep bruxism | https://icd.who.int/browse/2025-01/mms/en#60908067
update public.seo_entity_condition set icd11_code = '7A83', updated_at = now() where entity_fp = 'pediatric-bruxism' and icd11_code is not distinct from null::text;
-- pediatric-bruxism.mesh_id: None -> D002012 (fill, high) Bruxism | Bruxism | https://id.nlm.nih.gov/mesh/D002012.html
update public.seo_entity_condition set mesh_id = 'D002012', updated_at = now() where entity_fp = 'pediatric-bruxism' and mesh_id is not distinct from null::text;
-- pediatric-dental-trauma.icd11_code: None -> NA0D (fill, medium) Injury of teeth or supporting structures | Injury of teeth or supporting structures | https://icd.who.int/browse/2025-01/mms/en#1413338122
update public.seo_entity_condition set icd11_code = 'NA0D', updated_at = now() where entity_fp = 'pediatric-dental-trauma' and icd11_code is not distinct from null::text;
-- pediatric-dental-trauma.mesh_id: None -> D018677 (fill, high) Tooth Injuries | Tooth Injuries | https://id.nlm.nih.gov/mesh/D018677.html
update public.seo_entity_condition set mesh_id = 'D018677', updated_at = now() where entity_fp = 'pediatric-dental-trauma' and mesh_id is not distinct from null::text;
-- pediatric-malocclusion.icd10_code: M26.4 -> K07.4 (correct, medium) Malocclusion, unspecified | M26 is CM-only; same generic code as 'malocclusion' entity | https://icd.who.int/browse10/2019/en#/K07.4
update public.seo_entity_condition set icd10_code = 'K07.4', updated_at = now() where entity_fp = 'pediatric-malocclusion' and icd10_code is not distinct from 'M26.4';
-- pediatric-malocclusion.icd11_code: None -> DA0E.5 (fill, high) Malocclusion | Malocclusion | https://icd.who.int/browse/2025-01/mms/en#614347322
update public.seo_entity_condition set icd11_code = 'DA0E.5', updated_at = now() where entity_fp = 'pediatric-malocclusion' and icd11_code is not distinct from null::text;
-- pediatric-malocclusion.mesh_id: None -> D008310 (fill, high) Malocclusion | Malocclusion | https://id.nlm.nih.gov/mesh/D008310.html
update public.seo_entity_condition set mesh_id = 'D008310', updated_at = now() where entity_fp = 'pediatric-malocclusion' and mesh_id is not distinct from null::text;
-- pediatric-mouth-breathing.icd11_code: None -> MD11.8 (fill, high) Mouth breathing | Mouth breathing | https://icd.who.int/browse/2025-01/mms/en#1530206530
update public.seo_entity_condition set icd11_code = 'MD11.8', updated_at = now() where entity_fp = 'pediatric-mouth-breathing' and icd11_code is not distinct from null::text;
-- pediatric-mouth-breathing.mesh_id: None -> D009058 (fill, high) Mouth Breathing | Mouth Breathing | https://id.nlm.nih.gov/mesh/D009058.html
update public.seo_entity_condition set mesh_id = 'D009058', updated_at = now() where entity_fp = 'pediatric-mouth-breathing' and mesh_id is not distinct from null::text;
-- pediatric-snoring.icd10_code: R06.83 -> R06.5 (correct, medium) Mouth breathing | R06.83 CM-only; WHO R06.5 includes 'Snoring' | https://icd.who.int/browse10/2019/en#/R06.5
update public.seo_entity_condition set icd10_code = 'R06.5', updated_at = now() where entity_fp = 'pediatric-snoring' and icd10_code is not distinct from 'R06.83';
-- pediatric-snoring.mesh_id: None -> D012913 (fill, high) Snoring | Snoring | https://id.nlm.nih.gov/mesh/D012913.html
update public.seo_entity_condition set mesh_id = 'D012913', updated_at = now() where entity_fp = 'pediatric-snoring' and mesh_id is not distinct from null::text;
-- pediatric-tmd.icd10_code: M26.6 -> K07.6 (correct, high) Temporomandibular joint disorders | M26.6 is CM-only; WHO K07.6 TMJ disorders | https://icd.who.int/browse10/2019/en#/K07.6
update public.seo_entity_condition set icd10_code = 'K07.6', updated_at = now() where entity_fp = 'pediatric-tmd' and icd10_code is not distinct from 'M26.6';
-- pediatric-tmd.icd11_code: None -> DA0E.8 (fill, high) Temporomandibular joint disorders | Temporomandibular joint disorders | https://icd.who.int/browse/2025-01/mms/en#897101649
update public.seo_entity_condition set icd11_code = 'DA0E.8', updated_at = now() where entity_fp = 'pediatric-tmd' and icd11_code is not distinct from null::text;
-- pediatric-tmd.mesh_id: None -> D013705 (fill, high) Temporomandibular Joint Disorders | Temporomandibular Joint Disorders | https://id.nlm.nih.gov/mesh/D013705.html
update public.seo_entity_condition set mesh_id = 'D013705', updated_at = now() where entity_fp = 'pediatric-tmd' and mesh_id is not distinct from null::text;
-- pediatric-tongue-tie.mesh_id: None -> D000072676 (fill, high) Ankyloglossia | Ankyloglossia | https://id.nlm.nih.gov/mesh/D000072676.html
update public.seo_entity_condition set mesh_id = 'D000072676', updated_at = now() where entity_fp = 'pediatric-tongue-tie' and mesh_id is not distinct from null::text;
-- peri-implantitis.icd10_code: M27.6 -> None (correct, high)  | M27.6 is ICD-10-CM only | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'peri-implantitis' and icd10_code is not distinct from 'M27.6';
-- peri-implantitis.icd11_code: DA0F.0 -> None (correct, high)  | DA0F.0 is Burning mouth syndrome - wrong concept | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'peri-implantitis' and icd11_code is not distinct from 'DA0F.0';
-- periodontal-pocket.mesh_id: None -> D010514 (fill, high) Periodontal Pocket | Periodontal Pocket | https://id.nlm.nih.gov/mesh/D010514.html
update public.seo_entity_condition set mesh_id = 'D010514', updated_at = now() where entity_fp = 'periodontal-pocket' and mesh_id is not distinct from null::text;
-- periodontitis.icd11_code: 1242548497 -> None (correct, medium)  | Foundation id; K05.3 maps only to DA0C.Y residual | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_condition set icd11_code = null, updated_at = now() where entity_fp = 'periodontitis' and icd11_code is not distinct from '1242548497';
-- periodontitis.icd10_codes_related: ['K05.205.2,K05.305.3'] -> ['K05.2'] (correct, medium)  | Split malformed string; K05.3 is primary, keep K05.2 | https://icd.who.int/browse10/2019/en ; https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_codes_related = array['K05.2']::text[], updated_at = now() where entity_fp = 'periodontitis' and coalesce(icd10_codes_related, '{}') = array['K05.205.2,K05.305.3']::text[];
-- pericoronitis.icd10_codes_related: ['K05.3'] -> [] (correct, medium)  | Chronic periodontitis unrelated; WHO K05.2 already includes acute pericoronitis | https://icd.who.int/browse10/2019/en ; https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_codes_related = '{}'::text[], updated_at = now() where entity_fp = 'pericoronitis' and coalesce(icd10_codes_related, '{}') = array['K05.3']::text[];
-- pregnancy.icd10_code: Z33.1 -> Z33 (correct, high) Pregnant state, incidental | Z33.1 is CM-only; WHO Z33 has no subdivisions | https://icd.who.int/browse10/2019/en#/Z33
update public.seo_entity_condition set icd10_code = 'Z33', updated_at = now() where entity_fp = 'pregnancy' and icd10_code is not distinct from 'Z33.1';
-- pregnancy.icd10_codes_related: ['Z33'] -> [] (correct, high)  | Z33 becomes primary | https://icd.who.int/browse10/2019/en ; https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_codes_related = '{}'::text[], updated_at = now() where entity_fp = 'pregnancy' and coalesce(icd10_codes_related, '{}') = array['Z33']::text[];
-- pregnancy-gingivitis.icd10_code: None -> K05.1 (fill, medium) Chronic gingivitis | WHO chronic gingivitis; matches stored CM K05.10 | https://icd.who.int/browse10/2019/en#/K05.1
update public.seo_entity_condition set icd10_code = 'K05.1', updated_at = now() where entity_fp = 'pregnancy-gingivitis' and icd10_code is not distinct from null::text;
-- premature-wrinkles.mesh_id: None -> D015595 (fill, medium) Skin Aging | Skin Aging | https://id.nlm.nih.gov/mesh/D015595.html
update public.seo_entity_condition set mesh_id = 'D015595', updated_at = now() where entity_fp = 'premature-wrinkles' and mesh_id is not distinct from null::text;
-- primary-tooth-cavity.icd11_code: DA08 -> DA08.0 (correct, high) Dental caries | DA08 is the hard-tissue block; DA08.0 Dental caries | https://icd.who.int/browse/2025-01/mms/en#1983306720
update public.seo_entity_condition set icd11_code = 'DA08.0', updated_at = now() where entity_fp = 'primary-tooth-cavity' and icd11_code is not distinct from 'DA08';
-- primary-tooth-cavity.mesh_id: None -> D003731 (fill, medium) Dental Caries | Dental Caries | https://id.nlm.nih.gov/mesh/D003731.html
update public.seo_entity_condition set mesh_id = 'D003731', updated_at = now() where entity_fp = 'primary-tooth-cavity' and mesh_id is not distinct from null::text;
-- root-caries.icd10_code: None -> K02.2 (fill, high) Caries of cementum | Caries of cementum | https://icd.who.int/browse10/2019/en#/K02.2
update public.seo_entity_condition set icd10_code = 'K02.2', updated_at = now() where entity_fp = 'root-caries' and icd10_code is not distinct from null::text;
-- short-teeth.mesh_id: None -> D014071 (fill, medium) Tooth Abnormalities | Tooth Abnormalities | https://id.nlm.nih.gov/mesh/D014071.html
update public.seo_entity_condition set mesh_id = 'D014071', updated_at = now() where entity_fp = 'short-teeth' and mesh_id is not distinct from null::text;
-- single-missing-tooth.icd10_code: K08.409 -> K08.1 (correct, high) Loss of teeth due to accident, extraction or local periodont | CM code in WHO column | https://icd.who.int/browse10/2019/en#/K08.1
update public.seo_entity_condition set icd10_code = 'K08.1', updated_at = now() where entity_fp = 'single-missing-tooth' and icd10_code is not distinct from 'K08.409';
-- single-missing-tooth.icd11_code: None -> DA0A.1 (fill, high) Loss of teeth due to accident, extraction or local periodont | Official map of K08.1 | https://icd.who.int/browse/2025-01/mms/en#135458681
update public.seo_entity_condition set icd11_code = 'DA0A.1', updated_at = now() where entity_fp = 'single-missing-tooth' and icd11_code is not distinct from null::text;
-- single-missing-tooth.mesh_id: None -> D016388 (fill, high) Tooth Loss | Tooth Loss | https://id.nlm.nih.gov/mesh/D016388.html
update public.seo_entity_condition set mesh_id = 'D016388', updated_at = now() where entity_fp = 'single-missing-tooth' and mesh_id is not distinct from null::text;
-- sleep-bruxism.icd10_code: G47.63 -> None (correct, high)  | CM-only; WHO G47.8 residual without bruxism inclusion | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'sleep-bruxism' and icd10_code is not distinct from 'G47.63';
-- sleep-bruxism.icd11_code: None -> 7A83 (fill, high) Sleep-related bruxism | Sleep-related bruxism | https://icd.who.int/browse/2025-01/mms/en#60908067
update public.seo_entity_condition set icd11_code = '7A83', updated_at = now() where entity_fp = 'sleep-bruxism' and icd11_code is not distinct from null::text;
-- stress-bruxism.mesh_id: None -> D002012 (fill, high) Bruxism | Bruxism | https://id.nlm.nih.gov/mesh/D002012.html
update public.seo_entity_condition set mesh_id = 'D002012', updated_at = now() where entity_fp = 'stress-bruxism' and mesh_id is not distinct from null::text;
-- stress-burnout.mesh_id: None -> D000077062 (fill, high) Burnout, Psychological | Burnout, Psychological | https://id.nlm.nih.gov/mesh/D000077062.html
update public.seo_entity_condition set mesh_id = 'D000077062', updated_at = now() where entity_fp = 'stress-burnout' and mesh_id is not distinct from null::text;
-- structural-facial-aging.icd10_code: M89.9 -> None (correct, medium)  | Residual 'unspecified' bone disorder | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'structural-facial-aging' and icd10_code is not distinct from 'M89.9';
-- structural-facial-aging.icd10_cm_code: M89.9 -> None (correct, medium)  | Residual 'unspecified' | https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_cm_code = null, updated_at = now() where entity_fp = 'structural-facial-aging' and icd10_cm_code is not distinct from 'M89.9';
-- titanium-allergy.icd10_code: T78.49 -> None (correct, high)  | CM-only; WHO T78.4 residual | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'titanium-allergy' and icd10_code is not distinct from 'T78.49';
-- tmj-disorder.icd10_code: None -> K07.6 (fill, high) Temporomandibular joint disorders | Temporomandibular joint disorders | https://icd.who.int/browse10/2019/en#/K07.6
update public.seo_entity_condition set icd10_code = 'K07.6', updated_at = now() where entity_fp = 'tmj-disorder' and icd10_code is not distinct from null::text;
-- tmj-disorder.icd10_cm_code: M26.62 -> M26.60 (correct, medium) Temporomandibular joint disorder, unspecified | M26.62 is TMJ arthralgia only; umbrella TMD = M26.60 | https://icd10cmtool.cdc.gov/?fy=FY2027&query=M26.60
update public.seo_entity_condition set icd10_cm_code = 'M26.60', updated_at = now() where entity_fp = 'tmj-disorder' and icd10_cm_code is not distinct from 'M26.62';
-- tmj-disorder.icd11_code: None -> DA0E.8 (fill, high) Temporomandibular joint disorders | Temporomandibular joint disorders | https://icd.who.int/browse/2025-01/mms/en#897101649
update public.seo_entity_condition set icd11_code = 'DA0E.8', updated_at = now() where entity_fp = 'tmj-disorder' and icd11_code is not distinct from null::text;
-- tmj-disorder.mesh_id: None -> D013705 (fill, high) Temporomandibular Joint Disorders | Temporomandibular Joint Disorders | https://id.nlm.nih.gov/mesh/D013705.html
update public.seo_entity_condition set mesh_id = 'D013705', updated_at = now() where entity_fp = 'tmj-disorder' and mesh_id is not distinct from null::text;
-- tongue-thrust.mesh_id: None -> D014061 (fill, medium) Tongue Habits | Tongue Habits (covers tongue thrusting) | https://id.nlm.nih.gov/mesh/D014061.html
update public.seo_entity_condition set mesh_id = 'D014061', updated_at = now() where entity_fp = 'tongue-thrust' and mesh_id is not distinct from null::text;
-- tooth-avulsion.icd11_code: None -> NA0D.15 (fill, high) Avulsion of tooth | Avulsion of tooth | https://icd.who.int/browse/2025-01/mms/en#1917885197
update public.seo_entity_condition set icd11_code = 'NA0D.15', updated_at = now() where entity_fp = 'tooth-avulsion' and icd11_code is not distinct from null::text;
-- tooth-avulsion.mesh_id: None -> D014084 (fill, high) Tooth Avulsion | Tooth Avulsion | https://id.nlm.nih.gov/mesh/D014084.html
update public.seo_entity_condition set mesh_id = 'D014084', updated_at = now() where entity_fp = 'tooth-avulsion' and mesh_id is not distinct from null::text;
-- tooth-discoloration.icd10_code: K00.8 -> None (correct, medium)  | Residual developmental code; discoloration mostly posteruptive | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'tooth-discoloration' and icd10_code is not distinct from 'K00.8';
-- tooth-discoloration.icd10_cm_code: K00.8 -> None (correct, medium)  | Residual 'other disorders of tooth development' | https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_cm_code = null, updated_at = now() where entity_fp = 'tooth-discoloration' and icd10_cm_code is not distinct from 'K00.8';
-- tooth-fracture.icd11_code: NA02.6 -> NA0D.0 (correct, medium) Injury of hard dental tissues and pulp | NA02.6 absent from MMS 2025-01; NA0D.0 hard dental tissue injury | https://icd.who.int/browse/2025-01/mms/en#1642064112
update public.seo_entity_condition set icd11_code = 'NA0D.0', updated_at = now() where entity_fp = 'tooth-fracture' and icd11_code is not distinct from 'NA02.6';
-- tooth-shape-anomaly.mesh_id: None -> D014071 (fill, medium) Tooth Abnormalities | Tooth Abnormalities | https://id.nlm.nih.gov/mesh/D014071.html
update public.seo_entity_condition set mesh_id = 'D014071', updated_at = now() where entity_fp = 'tooth-shape-anomaly' and mesh_id is not distinct from null::text;
-- tooth-staining-external.mesh_id: None -> D014075 (fill, high) Tooth Discoloration | Tooth Discoloration | https://id.nlm.nih.gov/mesh/D014075.html
update public.seo_entity_condition set mesh_id = 'D014075', updated_at = now() where entity_fp = 'tooth-staining-external' and mesh_id is not distinct from null::text;
-- tooth-tipping.mesh_id: None -> D014085 (fill, medium) Tooth Migration | Tooth Migration | https://id.nlm.nih.gov/mesh/D014085.html
update public.seo_entity_condition set mesh_id = 'D014085', updated_at = now() where entity_fp = 'tooth-tipping' and mesh_id is not distinct from null::text;
-- torus-mandibularis-palatinus.icd11_code: None -> DA06.2 (fill, medium) Exostosis of jaw | Exostosis of jaw (K10.0 maps to residual) | https://icd.who.int/browse/2025-01/mms/en#194596555
update public.seo_entity_condition set icd11_code = 'DA06.2', updated_at = now() where entity_fp = 'torus-mandibularis-palatinus' and icd11_code is not distinct from null::text;
-- traumatic-tooth-loss.icd10_code: None -> K08.1 (fill, high) Loss of teeth due to accident, extraction or local periodont | Loss of teeth due to accident | https://icd.who.int/browse10/2019/en#/K08.1
update public.seo_entity_condition set icd10_code = 'K08.1', updated_at = now() where entity_fp = 'traumatic-tooth-loss' and icd10_code is not distinct from null::text;
-- traumatic-tooth-loss.icd10_cm_code: S02.5XXA -> K08.419 (correct, medium) Partial loss of teeth due to trauma, unspecified class | Concept is tooth loss from trauma, not fracture; class unspecified | https://icd10cmtool.cdc.gov/?fy=FY2027&query=K08.419
update public.seo_entity_condition set icd10_cm_code = 'K08.419', updated_at = now() where entity_fp = 'traumatic-tooth-loss' and icd10_cm_code is not distinct from 'S02.5XXA';
-- traumatic-tooth-loss.icd11_code: None -> DA0A.1 (fill, high) Loss of teeth due to accident, extraction or local periodont | Official map of K08.1 | https://icd.who.int/browse/2025-01/mms/en#135458681
update public.seo_entity_condition set icd11_code = 'DA0A.1', updated_at = now() where entity_fp = 'traumatic-tooth-loss' and icd11_code is not distinct from null::text;
-- traumatic-tooth-loss.mesh_id: None -> D016388 (fill, medium) Tooth Loss | Tooth Loss | https://id.nlm.nih.gov/mesh/D016388.html
update public.seo_entity_condition set mesh_id = 'D016388', updated_at = now() where entity_fp = 'traumatic-tooth-loss' and mesh_id is not distinct from null::text;
-- uncontrolled-diabetes.icd10_code: E11.65 -> None (correct, high)  | E11.65 is ICD-10-CM only; no WHO hyperglycaemia subcode | https://icd.who.int/browse10/2019/en
update public.seo_entity_condition set icd10_code = null, updated_at = now() where entity_fp = 'uncontrolled-diabetes' and icd10_code is not distinct from 'E11.65';
-- vertical-bone-deficiency.icd10_code: None -> K08.2 (fill, medium) Atrophy of edentulous alveolar ridge | Atrophy of edentulous alveolar ridge | https://icd.who.int/browse10/2019/en#/K08.2
update public.seo_entity_condition set icd10_code = 'K08.2', updated_at = now() where entity_fp = 'vertical-bone-deficiency' and icd10_code is not distinct from null::text;
-- vertical-bone-deficiency.icd10_cm_code: K06.3 -> None (correct, medium)  | K06.3 is horizontal bone loss - contradicts 'vertical' | https://icd10cmtool.cdc.gov/?fy=FY2027
update public.seo_entity_condition set icd10_cm_code = null, updated_at = now() where entity_fp = 'vertical-bone-deficiency' and icd10_cm_code is not distinct from 'K06.3';
-- vertical-bone-deficiency.icd11_code: None -> DA0A.2 (fill, medium) Atrophy of edentulous alveolar ridge | Atrophy of edentulous alveolar ridge | https://icd.who.int/browse/2025-01/mms/en#2092941190
update public.seo_entity_condition set icd11_code = 'DA0A.2', updated_at = now() where entity_fp = 'vertical-bone-deficiency' and icd11_code is not distinct from null::text;
-- vertical-bone-deficiency.mesh_id: None -> D016301 (fill, medium) Alveolar Bone Loss | Alveolar Bone Loss | https://id.nlm.nih.gov/mesh/D016301.html
update public.seo_entity_condition set mesh_id = 'D016301', updated_at = now() where entity_fp = 'vertical-bone-deficiency' and mesh_id is not distinct from null::text;
-- white-spot-lesion.icd10_code: None -> K02.0 (fill, high) Caries limited to enamel | WHO K02.0 includes 'White spot lesions' | https://icd.who.int/browse10/2019/en#/K02.0
update public.seo_entity_condition set icd10_code = 'K02.0', updated_at = now() where entity_fp = 'white-spot-lesion' and icd10_code is not distinct from null::text;
-- white-spot-lesion.icd10_cm_code: K02.51 -> K02.61 (correct, medium) Dental caries on smooth surface limited to enamel | WSLs are smooth-surface enamel caries, not pit-and-fissure | https://icd10cmtool.cdc.gov/?fy=FY2027&query=K02.61
update public.seo_entity_condition set icd10_cm_code = 'K02.61', updated_at = now() where entity_fp = 'white-spot-lesion' and icd10_cm_code is not distinct from 'K02.51';
-- white-spot-lesion.mesh_id: None -> D017001 (fill, medium) Tooth Demineralization | Tooth Demineralization | https://id.nlm.nih.gov/mesh/D017001.html
update public.seo_entity_condition set mesh_id = 'D017001', updated_at = now() where entity_fp = 'white-spot-lesion' and mesh_id is not distinct from null::text;
-- osteoradionecrosis.icd10_code: None -> K10.2 (fill, high) Inflammatory conditions of jaws | WHO K10.2 includes osteoradionecrosis; no ext row - needs insert | https://icd.who.int/browse10/2019/en#/K10.2
update public.seo_entity_condition set icd10_code = 'K10.2', updated_at = now() where entity_fp = 'osteoradionecrosis' and icd10_code is not distinct from null::text;
-- osteoradionecrosis.icd10_cm_code: None -> M27.2 (fill, medium) Inflammatory conditions of jaws | Inflammatory conditions of jaws; no ext row | https://icd10cmtool.cdc.gov/?fy=FY2027&query=M27.2
update public.seo_entity_condition set icd10_cm_code = 'M27.2', updated_at = now() where entity_fp = 'osteoradionecrosis' and icd10_cm_code is not distinct from null::text;
-- osteoradionecrosis.icd11_code: None -> DA06.0 (fill, medium) Inflammatory conditions of jaws | Official map of K10.2; FB81.5 is non-site alternative | https://icd.who.int/browse/2025-01/mms/en#425213515
update public.seo_entity_condition set icd11_code = 'DA06.0', updated_at = now() where entity_fp = 'osteoradionecrosis' and icd11_code is not distinct from null::text;
-- osteoradionecrosis.mesh_id: None -> D010025 (fill, high) Osteoradionecrosis | Osteoradionecrosis | https://id.nlm.nih.gov/mesh/D010025.html
update public.seo_entity_condition set mesh_id = 'D010025', updated_at = now() where entity_fp = 'osteoradionecrosis' and mesh_id is not distinct from null::text;
-- brain-fog.icd10_code: R41.82 -> None (correct, high)  | CM 'altered mental status' in WHO column; WHO R41.8 residual | https://icd.who.int/browse10/2019/en
update public.seo_entity_symptom set icd10_code = null, updated_at = now() where entity_fp = 'brain-fog' and icd10_code is not distinct from 'R41.82';
-- brain-fog.icd11_code: MB20.2 -> None (correct, medium)  | Clouding of consciousness is a different concept | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_symptom set icd11_code = null, updated_at = now() where entity_fp = 'brain-fog' and icd11_code is not distinct from 'MB20.2';
-- brain-fog-oral.icd10_code: R41.82 -> None (correct, high)  | CM code in WHO column; wrong concept | https://icd.who.int/browse10/2019/en
update public.seo_entity_symptom set icd10_code = null, updated_at = now() where entity_fp = 'brain-fog-oral' and icd10_code is not distinct from 'R41.82';
-- chronic-fatigue.icd10_code: R53.82 -> R53 (correct, medium) Malaise and fatigue | CM-only; WHO R53 includes chronic debility/tiredness | https://icd.who.int/browse10/2019/en#/R53
update public.seo_entity_symptom set icd10_code = 'R53', updated_at = now() where entity_fp = 'chronic-fatigue' and icd10_code is not distinct from 'R53.82';
-- chronic-fatigue.icd11_code: None -> MG22 (fill, medium) Fatigue | Fatigue | https://icd.who.int/browse/2025-01/mms/en#1109546957
update public.seo_entity_symptom set icd11_code = 'MG22', updated_at = now() where entity_fp = 'chronic-fatigue' and icd11_code is not distinct from null::text;
-- chronic-fatigue.mesh_id: None -> D005221 (fill, high) Fatigue | Fatigue (not CFS) | https://id.nlm.nih.gov/mesh/D005221.html
update public.seo_entity_symptom set mesh_id = 'D005221', updated_at = now() where entity_fp = 'chronic-fatigue' and mesh_id is not distinct from null::text;
-- jaw-lock.icd10_code: M26.69 -> R25.2 (correct, medium) Cramp and spasm | M26.69 CM-only; WHO index puts trismus at R25.2 (matches Wikidata) | https://icd.who.int/browse10/2019/en#/R25.2
update public.seo_entity_symptom set icd10_code = 'R25.2', updated_at = now() where entity_fp = 'jaw-lock' and icd10_code is not distinct from 'M26.69';
-- loose-tooth.icd10_code: K08.89 -> None (correct, high)  | CM code in WHO column; residual | https://icd.who.int/browse10/2019/en
update public.seo_entity_symptom set icd10_code = null, updated_at = now() where entity_fp = 'loose-tooth' and icd10_code is not distinct from 'K08.89';
-- loose-tooth.mesh_id: None -> D014086 (fill, high) Tooth Mobility | Tooth Mobility | https://id.nlm.nih.gov/mesh/D014086.html
update public.seo_entity_symptom set mesh_id = 'D014086', updated_at = now() where entity_fp = 'loose-tooth' and mesh_id is not distinct from null::text;
-- neck-shoulder-pain-posture.icd11_code: 9041111 -> ME84.0 (correct, medium) Cervical spine pain | Foundation id; M54.2 maps to ME84.0 Cervical spine pain | https://icd.who.int/browse/2025-01/mms/en#534629524
update public.seo_entity_symptom set icd11_code = 'ME84.0', updated_at = now() where entity_fp = 'neck-shoulder-pain-posture' and icd11_code is not distinct from '9041111';
-- orofacial-paresthesia.icd11_code: None -> DA0F (fill, medium) Sensory disturbances affecting orofacial complex | Sensory disturbances affecting orofacial complex | https://icd.who.int/browse/2025-01/mms/en#1943898717
update public.seo_entity_symptom set icd11_code = 'DA0F', updated_at = now() where entity_fp = 'orofacial-paresthesia' and icd11_code is not distinct from null::text;
-- orofacial-paresthesia.mesh_id: None -> D010292 (fill, medium) Paresthesia | Paresthesia | https://id.nlm.nih.gov/mesh/D010292.html
update public.seo_entity_symptom set mesh_id = 'D010292', updated_at = now() where entity_fp = 'orofacial-paresthesia' and mesh_id is not distinct from null::text;
-- poor-recovery.icd10_code: R53.82 -> None (correct, medium)  | Not a diagnosis; CM code in WHO column | https://icd.who.int/browse10/2019/en
update public.seo_entity_symptom set icd10_code = null, updated_at = now() where entity_fp = 'poor-recovery' and icd10_code is not distinct from 'R53.82';
-- sensitivity-post-whitening.mesh_id: None -> D003807 (fill, medium) Dentin Sensitivity | Dentin Sensitivity | https://id.nlm.nih.gov/mesh/D003807.html
update public.seo_entity_symptom set mesh_id = 'D003807', updated_at = now() where entity_fp = 'sensitivity-post-whitening' and mesh_id is not distinct from null::text;
-- snoring.icd10_code: R06.83 -> R06.5 (correct, medium) Mouth breathing | R06.83 CM-only; WHO R06.5 includes 'Snoring' | https://icd.who.int/browse10/2019/en#/R06.5
update public.seo_entity_symptom set icd10_code = 'R06.5', updated_at = now() where entity_fp = 'snoring' and icd10_code is not distinct from 'R06.83';
-- tmj-clicking.icd10_code: M26.69 -> K07.6 (correct, high) Temporomandibular joint disorders | CM code; WHO K07.6 includes 'Snapping jaw' | https://icd.who.int/browse10/2019/en#/K07.6
update public.seo_entity_symptom set icd10_code = 'K07.6', updated_at = now() where entity_fp = 'tmj-clicking' and icd10_code is not distinct from 'M26.69';
-- tmj-clicking.icd11_code: None -> DA0E.8 (fill, medium) Temporomandibular joint disorders | Map of K07.6 | https://icd.who.int/browse/2025-01/mms/en#897101649
update public.seo_entity_symptom set icd11_code = 'DA0E.8', updated_at = now() where entity_fp = 'tmj-clicking' and icd11_code is not distinct from null::text;
-- tmj-clicking.mesh_id: None -> D013705 (fill, medium) Temporomandibular Joint Disorders | Temporomandibular Joint Disorders | https://id.nlm.nih.gov/mesh/D013705.html
update public.seo_entity_symptom set mesh_id = 'D013705', updated_at = now() where entity_fp = 'tmj-clicking' and mesh_id is not distinct from null::text;
-- tmj-headache.icd10_code: G44.89 -> None (correct, high)  | CM code; WHO G44.8 residual | https://icd.who.int/browse10/2019/en
update public.seo_entity_symptom set icd10_code = null, updated_at = now() where entity_fp = 'tmj-headache' and icd10_code is not distinct from 'G44.89';
-- tmj-pain.icd10_code: M26.629 -> K07.6 (correct, high) Temporomandibular joint disorders | CM code; WHO K07.6 includes TMJ pain-dysfunction syndrome | https://icd.who.int/browse10/2019/en#/K07.6
update public.seo_entity_symptom set icd10_code = 'K07.6', updated_at = now() where entity_fp = 'tmj-pain' and icd10_code is not distinct from 'M26.629';
-- tmj-pain.icd11_code: None -> DA0E.8 (fill, medium) Temporomandibular joint disorders | Map of K07.6 | https://icd.who.int/browse/2025-01/mms/en#897101649
update public.seo_entity_symptom set icd11_code = 'DA0E.8', updated_at = now() where entity_fp = 'tmj-pain' and icd11_code is not distinct from null::text;
-- tmj-pain.mesh_id: None -> D013705 (fill, medium) Temporomandibular Joint Disorders | Temporomandibular Joint Disorders | https://id.nlm.nih.gov/mesh/D013705.html
update public.seo_entity_symptom set mesh_id = 'D013705', updated_at = now() where entity_fp = 'tmj-pain' and mesh_id is not distinct from null::text;
-- tooth-sensitivity.icd10_code: K03.89 -> None (correct, high)  | CM code in WHO column; WHO K03.8 residual | https://icd.who.int/browse10/2019/en
update public.seo_entity_symptom set icd10_code = null, updated_at = now() where entity_fp = 'tooth-sensitivity' and icd10_code is not distinct from 'K03.89';
-- tooth-sensitivity.icd11_code: DA08.1 -> None (correct, medium)  | DA08.1 is a parent of attrition/erosion, not sensitivity | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_symptom set icd11_code = null, updated_at = now() where entity_fp = 'tooth-sensitivity' and icd11_code is not distinct from 'DA08.1';
-- tooth-sensitivity.mesh_id: None -> D003807 (fill, high) Dentin Sensitivity | Dentin Sensitivity | https://id.nlm.nih.gov/mesh/D003807.html
update public.seo_entity_symptom set mesh_id = 'D003807', updated_at = now() where entity_fp = 'tooth-sensitivity' and mesh_id is not distinct from null::text;
-- toothache.icd10_code: K08.89 -> None (correct, medium)  | CM code in WHO column; WHO K08.8 lists 'Toothache NOS' but is residual | https://icd.who.int/browse10/2019/en
update public.seo_entity_symptom set icd10_code = null, updated_at = now() where entity_fp = 'toothache' and icd10_code is not distinct from 'K08.89';
-- toothache.icd11_code: 452224902 -> None (correct, medium)  | Foundation id; only chronic dental pain MG30.61 in MMS | https://icd.who.int/browse/2025-01/mms/en
update public.seo_entity_symptom set icd11_code = null, updated_at = now() where entity_fp = 'toothache' and icd11_code is not distinct from '452224902';
-- unrefreshing-sleep.icd10_code: G47.9 -> None (correct, high)  | Residual 'unspecified' | https://icd.who.int/browse10/2019/en
update public.seo_entity_symptom set icd10_code = null, updated_at = now() where entity_fp = 'unrefreshing-sleep' and icd10_code is not distinct from 'G47.9';

-- 2. MeSH for procedures / treatments / devices (43 rows; tmp/mesh-procedures-devices-2026-10-22.json)
create temp table _mesh_procedures (fp text, mesh text) on commit drop;
insert into _mesh_procedures values
  ('breathing-retraining', 'D001945'),  -- Breathing Retraining -> Breathing Exercises (medium)
  ('cephalometric-analysis', 'D002508'),  -- Cephalometric Analysis -> Cephalometry (high)
  ('clear-aligner', 'D009968'),  -- Clear Aligner -> Orthodontic Appliances, Removable (high)
  ('deep-scaling', 'D016745'),  -- Deep Scaling & Root Planing -> Root Planing (medium)
  ('dental-bridge', 'D003830'),  -- Dental Bridge -> Denture, Partial, Fixed (high)
  ('dental-filling', 'D003793'),  -- Dental Filling -> Dental Restoration, Permanent (medium)
  ('dental-impression', 'D003761'),  -- Dental Impression -> Dental Impression Technique (high)
  ('inlay-onlay', 'D007284'),  -- Dental Inlay & Onlay -> Inlays (high)
  ('scaling-polishing', 'D003777'),  -- Dental Scaling & Polishing -> Dental Prophylaxis (high)
  ('dental-xray', 'D011861'),  -- Dental X-ray -> Radiography, Dental (high)
  ('denture', 'D003778'),  -- Denture (umbrella) -> Dentures (high)
  ('denture-relining', 'D003823'),  -- Denture Relining -> Denture Rebasing (high)
  ('early-orthodontic-intervention', 'D009972'),  -- Early Orthodontic Intervention -> Orthodontics, Interceptive (high)
  ('remineralization', 'D014089'),  -- Enamel Remineralization -> Tooth Remineralization (medium)
  ('frenectomy', 'D000095782'),  -- Frenectomy -> Oral Frenectomy (high)
  ('full-mouth-rehab', 'D009065'),  -- Full-Mouth Rehabilitation -> Mouth Rehabilitation (high)
  ('guided-growth', 'D009972'),  -- Guided Growth Orthodontics -> Orthodontics, Interceptive (medium)
  ('gum-contouring', 'D005893'),  -- Gum Contouring -> Gingivoplasty (high)
  ('immediate-loading', 'D057893'),  -- Immediate Loading -> Immediate Dental Implant Loading (high)
  ('implant-denture', 'D019094'),  -- Implant-Supported Denture -> Dental Prosthesis, Implant-Supported (high)
  ('iv-sedation', 'D016292'),  -- IV Sedation -> Procedural Sedation (medium)
  ('laser-pbm', 'D028022'),  -- Laser Photobiomodulation (PBM) -> Low-Level Light Therapy (high)
  ('mad', 'D017090'),  -- Mandibular Advancement Device -> Occlusal Splints (high)
  ('medical-compromised-dentistry', 'D017742'),  -- Medical-Compromised Dentistry -> Dental Care for Chronically Ill (medium)
  ('occlusal-rehab', 'D019558'),  -- Occlusal Rehabilitation -> Occlusal Adjustment (medium)
  ('orthodontic-retainer', 'D018704'),  -- Orthodontic Retainer -> Orthodontic Retainers (high)
  ('orthodontic-treatment', 'D009971'),  -- Orthodontic Treatment -> Orthodontics, Corrective (medium)
  ('opg-xray', 'D011862'),  -- Panoramic X-ray (OPG) -> Radiography, Panoramic (high)
  ('post-core', 'D011176'),  -- Post & Core -> Post and Core Technique (high)
  ('pulp-regeneration', 'D000078483'),  -- Pulp Regeneration -> Regenerative Endodontics (medium)
  ('ridge-augmentation', 'D000540'),  -- Ridge Augmentation -> Alveolar Ridge Augmentation (high)
  ('single-implant', 'D019250'),  -- Single Tooth Implant -> Dental Implants, Single-Tooth (high)
  ('sinus-lift', 'D059546'),  -- Sinus Lift -> Sinus Floor Augmentation (high)
  ('sleep-study', 'D017286'),  -- Sleep Study -> Polysomnography (medium)
  ('snap-on-denture', 'D003828'),  -- Snap-on Denture -> Denture, Overlay (medium)
  ('space-maintainer', 'D013027'),  -- Space Maintainer -> Space Maintenance, Orthodontic (high)
  ('teeth-whitening', 'D014073');  -- Teeth Whitening -> Tooth Bleaching (high)
insert into public.seo_entity_procedures (entity_fp, load_source) select fp, 'W3.2d 2026-10-22' from _mesh_procedures on conflict (entity_fp) do nothing;
update public.seo_entity_procedures x set mesh_id = m.mesh, updated_at = now() from _mesh_procedures m where x.entity_fp = m.fp and x.mesh_id is null;
create temp table _mesh_devices (fp text, mesh text) on commit drop;
insert into _mesh_devices values
  ('bone-graft-substitute', 'D018786'),  -- Bone Graft Substitute -> Bone Substitutes (high)
  ('emax-material', 'C493120'),  -- E.max (Material) -> lithia disilicate (medium)
  ('night-guard', 'D017090'),  -- Night Guard -> Occlusal Splints (high)
  ('sports-mouthguard', 'D009064'),  -- Sports Mouthguard -> Mouth Protectors (medium)
  ('titanium', 'D014025'),  -- Titanium -> Titanium (high)
  ('zirconia-material', 'C028541');  -- Zirconia (Material) -> zirconium oxide (high)
insert into public.seo_entity_devices (entity_fp, load_source) select fp, 'W3.2d 2026-10-22' from _mesh_devices on conflict (entity_fp) do nothing;
update public.seo_entity_devices x set mesh_id = m.mesh, updated_at = now() from _mesh_devices m where x.entity_fp = m.fp and x.mesh_id is null;

commit;
