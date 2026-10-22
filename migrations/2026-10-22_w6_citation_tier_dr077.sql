-- W6 (DR-077): citation tier criteria — COMMENT, data fixes from PubMed review, drop duplicate view
-- Run as one script in the Supabase SQL editor. Afterwards run
--   python3 -I scripts/citation-gates/compute-citation-authority.py   (refresh citation_authority_weight)
--   python3 -I scripts/citation-gates/run-citation-qa-gates.py        (G5/G14/G14u/G15 should be quieter)

begin;

-- 1. Replace the stale COMMENT on citation_tier (it predated DR-063 and DR-077).
comment on column public.seo_citations.citation_tier is
$c$ระดับหลักฐาน 1–6 (1 = แข็งที่สุด) · ตั้งตาม `citation_type` ผ่าน TIER_BY_TYPE (gate G5) และต้องไม่ขัดกับ `study_type` (gate G14)

📕 ต้นทาง: Bible §23.1 · Citation_Pool_SOP §2 · DR-063 (conduct ชนะ) · DR-077 (เกณฑ์ 2026-10-22)
implement: eywa-protocol-spec/scripts/citation-gates/run-citation-qa-gates.py (TIER_BY_TYPE · STUDY_TYPE_SYNONYM · STUDY_TYPE_TIER)

ตัดสินจากสิ่งที่งานวิจัยทำจริง — PubMed PublicationType + บทคัดย่อ · ห้ามตัดสินจากชื่อเรื่อง
แท็ก "Review" อย่างเดียวไม่ได้บอกอะไร: มี search strategy / PRISMA / pooling → SR/MA (T1) · ไม่มี → narrative (T6)

  1 = systematic_review · meta_analysis
  2 = rct (randomized / controlled clinical trial)
  3 = clinical_guideline (สมาคมวิชาชีพ) · systematic_review_guideline ที่ไม่ได้ทำ SR เอง
  4 = regulatory_document · report ที่ออกโดยรัฐ/ผู้กำกับดูแล
  5 = cohort_study · case_control · cross_sectional · case_series · clinical_study / pilot_study ที่ไม่สุ่ม · genetic_association / mendelian_randomization
  6 = textbook · expert_opinion · narrative/scoping review · case_report · editorial · industry_publication · patient_resource · in_vitro

study_type = 'other' ห้ามเป็นค่าสุดท้ายของแถวที่มี PMID · ข้อมูล first-party ของคลินิก = citation_type other / T6
ข้อจำกัดของหลักฐาน (เช่น SR ที่รวมแต่งานในสัตว์) เขียนใน key_findings — ห้ามกด tier แทน
หลังเปลี่ยน tier ให้รัน compute-citation-authority.py$c$;

-- 2. Data fixes from the PubMed review (generated, one statement per row, with the reason).
-- 2a. Main fixes (164 rows, confidence high/medium). Each row is guarded on its current values,
--     so a row edited since the review is skipped rather than overwritten.
-- p14-c4 (pages 48): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 7 databases searched; random-effects pooled OR')
where fingerprint = 'cite_5AC51F56315549E5' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-c12 (pages 30): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · PRISMA; 4 databases; SR of RCTs (PubMed tags Meta-Analysis)')
where fingerprint = 'cite_9C48979713B2489C' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-c9 (pages 29): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'consensus_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> clinical_guideline/consensus_guideline/T3 · high · consensus workshops + literature searches + validation data produce diagnostic criteria')
where fingerprint = 'cite_3792CFCEF7214035' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- world-workshop-2017-gingival-health (pages 28): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'consensus_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> clinical_guideline/consensus_guideline/T3 · high · workshop consensus report building case definitions on commissioned reviews')
where fingerprint = 'cite_9C1B7F04E28A536D' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';
-- p9-c3 (pages 21): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'consensus_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> clinical_guideline/consensus_guideline/T3 · high · structured consensus on 8 prior systematic reviews -> evidence-based recommendations')
where fingerprint = 'cite_29DB78BCE93A47CB' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';
-- bruxism-dental-implants-meta-2023 (pages 20): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/other/T1 -> meta_analysis/meta_analysis/T1 · high · PROSPERO-registered; PubMed/WoS/ScienceDirect; pairwise random-effects MA')
where fingerprint = 'cite_BRUXIMPLANT2023' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from 'other';
-- vth-c11 (pages 20): T6 -> T6
update public.seo_citations set citation_type = 'textbook', study_type = 'textbook', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] textbook/clinical_guideline/T6 -> textbook/textbook/T6 · high · book (Quintessence, 7th ed.) of AAOP guidelines; narrative, no SR methods reported')
where fingerprint = 'cite_B2731F07B2B24BD6' and citation_tier = 6 and citation_type = 'textbook' and study_type is not distinct from 'clinical_guideline';
-- osa-international-consensus (pages 17): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'consensus_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> clinical_guideline/consensus_guideline/T3 · medium · topics as evidence-based reviews with graded recommendations by multidisciplinary panel')
where fingerprint = 'cite_DE4E3E6347A40373' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';
-- gerd-dental-erosion-sr (pages 14): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/null/T1 -> systematic_review/systematic_review/T1 · high · PubMed+WoS search with descriptors, clinical studies 2012-2020')
where fingerprint = 'cite_DB247DD4E3228ADF' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from null;
-- ada-2019-antibiotic-urgent-dental-pain (pages 13): T3 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/systematic_review_guideline/T3 -> systematic_review/systematic_review/T1 · high · panel conducted SR: MEDLINE/Embase/Cochrane/CINAHL + GRADE certainty')
where fingerprint = 'cite_ADA2019ANTIBIOTIC' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'systematic_review_guideline';
-- vth-c28 (pages 13): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'consensus_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> clinical_guideline/consensus_guideline/T3 · high · AAE/AAOMR joint position statement with recommendations')
where fingerprint = 'cite_1DA2EFF57DD3422B' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';
-- vth-c16 (pages 13): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'consensus_statement', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> expert_opinion/consensus_statement/T6 · medium · introductory summary of AAP/EFP workshop consensus classification')
where fingerprint = 'cite_69C1F4926F244514' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- p10-c1 (pages 12): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'clinical_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> clinical_guideline/clinical_guideline/T3 · medium · AAPD Reference Manual: society clinical policies/recommendations (URL)')
where fingerprint = 'cite_AD325DAF3AF54CB0' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- omt-osa-ma-2024 (pages 12): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · PRISMA; 4 databases; RCT meta-analysis')
where fingerprint = 'cite_896B2401B88EB629' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-c20 (pages 12): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'consensus_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> clinical_guideline/consensus_guideline/T3 · high · EFP/WHF consensus report with recommendations for clinicians')
where fingerprint = 'cite_B5742623A794486E' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';
-- p12-c1 (pages 12): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'clinical_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> clinical_guideline/clinical_guideline/T3 · medium · AAPD reference-manual guidelines (behavior guidance, sedation)')
where fingerprint = 'cite_8CFDE3EF97754A67' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- tinnitus-tmd-ma (pages 11): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 5-database search; PubMed tags Meta-Analysis')
where fingerprint = 'cite_F6F55E992053488C' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-c45 (pages 11): T5 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/narrative_review/T5 -> expert_opinion/narrative_review/T6 · high · summarises SEDENTEXCT guidelines and illustrates CBCT use; no original data')
where fingerprint = 'cite_00DEDF0CB51446AF' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'narrative_review';
-- ios-edentulous-accuracy-sr (pages 10): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · PubMed/Scopus/WoS search, 334 retrieved, 12 included')
where fingerprint = 'cite_4CDEFB718281C800' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- pm31717812 (pages 10): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/null/T1 -> systematic_review/systematic_review/T1 · high · MEDLINE/EMBASE/CINAHL 2009-2019; 25 surveys included')
where fingerprint = 'cite_130A4DEF62FEE50D' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from null;
-- vth-c41 (pages 10): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/null/T5 -> other/in_vitro/T6 · high · preparations on typodont resin teeth; tooth structure removed quantified')
where fingerprint = 'cite_6411320490624939' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from null;
-- vth-c7 (pages 9): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · Cochrane/Scopus/WoS/MEDLINE search; PRISMA; meta-analysis')
where fingerprint = 'cite_1B6987A06A60457A' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-c83 (pages 9): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · MEDLINE/Cochrane/WoS search; dual reviewers; risk of bias')
where fingerprint = 'cite_SBMGMT2022SR' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- vth-c23 (pages 9): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/null/T5 -> other/in_vitro/T6 · medium · 16S rRNA sequence curation into HOMD database; lab/bioinformatic')
where fingerprint = 'cite_36FC713305E347B7' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from null;
-- dentalcouncil-dsg-2567 (pages 9): T4 -> T4
update public.seo_citations set citation_type = 'regulatory_document', study_type = 'regulatory_document', citation_tier = 4,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] regulatory_document/null/T4 -> regulatory_document/regulatory_document/T4 · medium · Dental Council of Thailand (statutory regulator) safety goals')
where fingerprint = 'cite_AB5FB724012A37EF' and citation_tier = 4 and citation_type = 'regulatory_document' and study_type is not distinct from null;
-- iti-consensus-prosthodontics (pages 9): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'consensus_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> clinical_guideline/consensus_guideline/T3 · high · consensus on 6 commissioned SRs -> statements and clinical recommendations')
where fingerprint = 'cite_1A73E44363A98B99' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';
-- c1.6 (pages 9): T3 -> T6
update public.seo_citations set citation_type = 'patient_resource', study_type = 'patient_resource', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> patient_resource/patient_resource/T6 · medium · aaoinfo.org consumer page for parents')
where fingerprint = 'cite_E32596D18BF84EF9' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- vth-c6 (pages 9): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/null/T1 -> systematic_review/systematic_review/T1 · high · PRISMA-based SR; database search, 262 records')
where fingerprint = 'cite_4B14A9D487FE4325' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from null;
-- lip-repositioning-gummy-smile-ma (pages 8): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 4 databases incl. CENTRAL; SR+MA')
where fingerprint = 'cite_861889759FCCA285' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- implant-diabetes-naujokat (pages 8): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · systematic literature search per PRISMA on PICO question')
where fingerprint = 'cite_AADCBD5B7B58615A' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- laser-adhesion-enamel-ma (pages 8): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 4 databases; 25 studies pooled; Cochrane bias tool')
where fingerprint = 'cite_56125DE29677DBA2' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- composite-vs-ceramic-anterior-review (pages 8): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> expert_opinion/narrative_review/T6 · high · case illustrations + literature synthesis; no search methods')
where fingerprint = 'cite_2F99E981C085F74F' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- dms-systemic-disease-dental-2564 (pages 8): T4 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'clinical_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] regulatory_document/null/T4 -> clinical_guideline/clinical_guideline/T3 · medium · Dept of Medical Services (MoPH) clinical practice guideline PDF')
where fingerprint = 'cite_3ADB73A59512D51A' and citation_tier = 4 and citation_type = 'regulatory_document' and study_type is not distinct from null;
-- p8-c3 (pages 8): T2 -> T5
update public.seo_citations set citation_type = 'cohort_study', study_type = 'prospective_cohort', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] rct/cohort_study/T2 -> cohort_study/prospective_cohort/T5 · high · 23 test/23 control implants by placement level, grouped by tissue thickness; no randomisation stated')
where fingerprint = 'cite_AC38F5ACADFD4646' and citation_tier = 2 and citation_type = 'rct' and study_type is not distinct from 'cohort_study';
-- indications-symptomatic-impacted-third-molar-extraction-2021 (pages 7): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · Medline+EMBASE search; 19 studies included')
where fingerprint = 'cite_BCB14F45151C8A27' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- myofunctional-osa-ma-2015 (pages 7): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 4 databases; PRISMA; meta-analysis')
where fingerprint = 'cite_0AF77C86760C29F6' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-c21 (pages 7): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> expert_opinion/narrative_review/T6 · medium · literature searches then data summarised in tables and narrative review; no appraisal')
where fingerprint = 'cite_7B4BB347ECAE4D71' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- oral-cytology-opmd-ma (pages 7): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · PRISMA-DTA; 5 databases; diagnostic MA')
where fingerprint = 'cite_4B3B8EFBDFAD9C09' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- c6.3 (pages 7): T4 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'clinical_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] regulatory_document/clinical_guideline/T4 -> clinical_guideline/clinical_guideline/T3 · medium · NICE technology appraisal guidance with recommendations')
where fingerprint = 'cite_CA8F977FF7164BF5' and citation_tier = 4 and citation_type = 'regulatory_document' and study_type is not distinct from 'clinical_guideline';
-- vth-uv3 (pages 6): T5 -> T5
update public.seo_citations set citation_type = 'cohort_study', study_type = 'retrospective_cohort', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/other/T5 -> cohort_study/retrospective_cohort/T5 · high · retrospective evaluation of factors incl. photofunctionalization on early failure')
where fingerprint = 'cite_UVPF03C4D5E6F708' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'other';
-- ssri-induced-bruxism-tmd-antidepressant-choice-2017 (pages 6): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/null/T6 -> expert_opinion/narrative_review/T6 · high · literature review of mechanisms; no search methods')
where fingerprint = 'cite_954FAF0F94852679' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from null;
-- milled-versus-prototyped-smile-mockups-2020 (pages 6): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] case_series/clinical_study/T5 -> other/in_vitro/T6 · medium · trueness of milled vs printed mock-ups by digital superimposition on wax-up')
where fingerprint = 'cite_849B9D8717A848B9' and citation_tier = 5 and citation_type = 'case_series' and study_type is not distinct from 'clinical_study';
-- ada-2024-acute-dental-pain-pharmacologic (pages 6): T3 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/systematic_review_guideline/T3 -> systematic_review/systematic_review/T1 · high · panel conducted 4 systematic reviews + GRADE')
where fingerprint = 'cite_ADA2024ACUTEPAIN' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'systematic_review_guideline';
-- vth-c15 (pages 6): T5 -> T5
update public.seo_citations set citation_type = 'cross_sectional', study_type = 'cross_sectional', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/other/T5 -> cross_sectional/cross_sectional/T5 · high · cross-sectional study, 240 individuals with polysomnography')
where fingerprint = 'cite_1A2897C258384683' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'other';
-- smile-design-treatment-planning-conventional-versus-digital-pilot-2023 (pages 6): T5 -> T5
update public.seo_citations set citation_type = 'case_series', study_type = 'case_series', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] case_series/pilot_study/T5 -> case_series/case_series/T5 · medium · 5 patients, analog vs digital mock-ups rated by 3 observers; not randomised')
where fingerprint = 'cite_4B8C3F7006214D0D' and citation_tier = 5 and citation_type = 'case_series' and study_type is not distinct from 'pilot_study';
-- p12-c4 (pages 5): T6 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/meta_analysis/T6 -> meta_analysis/meta_analysis/T1 · high · PROSPERO; PRISMA; 7 RCTs pooled; RoB tools')
where fingerprint = 'cite_378A13BAB8094A6B' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'meta_analysis';
-- dental-trauma-clinical-practice (pages 5): T5 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/narrative_review/T5 -> expert_opinion/narrative_review/T6 · high · clinical overview of trauma complications; no original data')
where fingerprint = 'cite_847F902727DAEA84' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'narrative_review';
-- biomimetic-unibody-design (pages 5): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> expert_opinion/narrative_review/T6 · high · conceptual review of material design; no search methods')
where fingerprint = 'cite_E48137CAE39116BB' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- vth-c64 (pages 5): T6 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> meta_analysis/meta_analysis/T1 · high · umbrella SR + four meta-meta-analyses; AMSTAR 2 / ROBIS')
where fingerprint = 'cite_PTTMD2023MMA' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- gummy-smile-nonsurgical-ma (pages 5): T6 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> meta_analysis/meta_analysis/T1 · high · PubMed/Scopus/Embase/WoS/Cochrane + grey literature; SR+MA')
where fingerprint = 'cite_2E33F8563F1F6E70' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- breathing-route-airway-surface-tension (pages 5): T2 -> T2
update public.seo_citations set citation_type = 'rct', study_type = 'randomized_controlled_trial', citation_tier = 2,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] rct/null/T2 -> rct/randomized_controlled_trial/T2 · medium · nasal vs oral breathing on separate days, randomised order (crossover)')
where fingerprint = 'cite_59864BD78D97DF5D' and citation_tier = 2 and citation_type = 'rct' and study_type is not distinct from null;
-- p16-c6 (pages 5): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/in_vitro/T5 -> other/in_vitro/T6 · high · thermomechanical tests on four aligner polymers')
where fingerprint = 'cite_0DF3B2DB6273422C' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'in_vitro';
-- c7.5 (pages 5): T5 -> T2
update public.seo_citations set citation_type = 'rct', study_type = 'randomized_controlled_trial', citation_tier = 2,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/randomized_controlled_trial/T5 -> rct/randomized_controlled_trial/T2 · high · patients randomly allocated to single- vs two-visit RCT')
where fingerprint = 'cite_EA341100748D4C21' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'randomized_controlled_trial';
-- navigation-robot-implant-sr (pages 5): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · PubMed/Scopus/WoS search 2019-2025 with eligibility criteria')
where fingerprint = 'cite_A3BAB93FDB72AD72' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- c8.4 (pages 5): T5 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/other/T5 -> expert_opinion/narrative_review/T6 · high · overview of caries risk models and prevention; no original data')
where fingerprint = 'cite_9CF0F0BE12EA447E' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'other';
-- pap-mortality-ma-2025 (pages 5): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · PubMed/Embase/CENTRAL search; RCTs + NRCS pooled')
where fingerprint = 'cite_04B370DFF8F1564F' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- p7-c3 (pages 5): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · PRISMA; PROSPERO; two independent reviewers')
where fingerprint = 'cite_45AEFE6CBE404DB3' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- vth-uv2 (pages 5): T5 -> T5
update public.seo_citations set citation_type = 'case_series', study_type = 'case_series', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/other/T5 -> case_series/case_series/T5 · medium · prospective single-centre, 70 implants in 16 patients, no comparator')
where fingerprint = 'cite_UVPF02B3C4D5E6F7' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'other';
-- aphthous-zinc-sr (pages 5): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/null/T1 -> systematic_review/systematic_review/T1 · high · 5 databases; 7 clinical trials included')
where fingerprint = 'cite_15C5AD088721AAB8' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from null;
-- p14-c9 (pages 5): T5 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/narrative_review/T5 -> expert_opinion/narrative_review/T6 · high · summarises and revisits three MRONJ guidelines')
where fingerprint = 'cite_7354247CF0144F7D' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'narrative_review';
-- single-dose-analgesics-cochrane (pages 5): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · Cochrane overview of 39 reviews with pooled NNTs')
where fingerprint = 'cite_CDF64047C10C0FE2' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- cx.4 (pages 4): T4 -> T6
update public.seo_citations set citation_type = 'patient_resource', study_type = 'patient_resource', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] regulatory_document/fact_sheet/T4 -> patient_resource/patient_resource/T6 · medium · WHO public fact sheet on oral health')
where fingerprint = 'cite_C91EA758790B4EF8' and citation_tier = 4 and citation_type = 'regulatory_document' and study_type is not distinct from 'fact_sheet';
-- vth-c40 (pages 4): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'consensus_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> clinical_guideline/consensus_guideline/T3 · medium · AHA scientific statement updating 2007 prophylaxis recommendations')
where fingerprint = 'cite_D56EA7BF60B64312' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- vth-c51 (pages 4): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/null/T1 -> systematic_review/systematic_review/T1 · high · Scopus+PubMed 2015-2024; RoB 2')
where fingerprint = 'cite_TMJINJ40965683' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from null;
-- vth-c19 (pages 4): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/in_vitro/T5 -> other/in_vitro/T6 · high · gingipain detection in post-mortem brains, mouse infection, in-vitro neurotoxicity')
where fingerprint = 'cite_9B1065873D374EBB' and citation_tier = 5 and citation_type = 'other' and study_type is not distinct from 'in_vitro';
-- antidepressants-movement-disorders-vigibase-2020 (pages 4): T5 -> T5
update public.seo_citations set citation_type = 'cross_sectional', study_type = 'cross_sectional', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cross_sectional/null/T5 -> cross_sectional/cross_sectional/T5 · medium · disproportionality analysis of VigiBase pharmacovigilance reports')
where fingerprint = 'cite_81121EA5337EFF06' and citation_tier = 5 and citation_type = 'cross_sectional' and study_type is not distinct from null;
-- ai-clear-aligner-scoping (pages 4): T5 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'scoping_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/scoping_review/T5 -> expert_opinion/scoping_review/T6 · high · scoping review with systematic search, no appraisal/pooling')
where fingerprint = 'cite_27249D22691D6743' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'scoping_review';
-- vth-c33 (pages 4): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'consensus_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> clinical_guideline/consensus_guideline/T3 · high · AAOMS position paper with management strategies/recommendations')
where fingerprint = 'cite_5AA584E1195C4E6C' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';
-- vth-c54 (pages 3): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · RCTs; Cochrane RoB; GRADE; network meta-analysis')
where fingerprint = 'cite_TMJINJ37633896' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- type-iv-hypersensitivity-restorative-2021 (pages 3): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · clinical report + systematic literature review in 4 databases')
where fingerprint = 'cite_TYPE4HYPERSENSMAT2021' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';
-- cpap-cvd-secondary-prevention-ma-2019 (pages 3): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · PubMed/CENTRAL/LILACS/SciElo; random-effects MA of RCTs')
where fingerprint = 'cite_61163851CC5BAF7B' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- frenotomy-techniques-ma (pages 3): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 6 databases; inverse-variance meta-analysis')
where fingerprint = 'cite_94BBE6438F2A80EE' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-c13 (pages 3): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 5 databases; RCTs; meta-analysis')
where fingerprint = 'cite_8693A70805844B64' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-uv1 (pages 3): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/other/T1 -> meta_analysis/meta_analysis/T1 · high · 4 databases + manual search; SR+MA')
where fingerprint = 'cite_UVPF01A7B2C3D4E5' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from 'other';
-- mronj-tooth-extraction-oncology-2026 (pages 3): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/other/T1 -> meta_analysis/meta_analysis/T1 · high · PRISMA; 5 databases; random-effects MA of proportions')
where fingerprint = 'cite_MRONJEXTRACTONC2026' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from 'other';
-- fragment-reattachment-5yr (pages 3): T5 -> T5
update public.seo_citations set citation_type = 'cohort_study', study_type = 'retrospective_cohort', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/other/T5 -> cohort_study/retrospective_cohort/T5 · medium · two technique groups followed 5 years retrospectively')
where fingerprint = 'cite_62DF46A3201053EB' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'other';
-- sleep-bruxism-ceramic-restoration-failure-2017 (pages 3): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/other/T1 -> meta_analysis/meta_analysis/T1 · high · SR+MA of observational studies and trials')
where fingerprint = 'cite_BRUXCERAMIC2017' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from 'other';
-- abdalla-2017-nccl-microscopy (pages 3): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/in_vitro/T5 -> other/in_vitro/T6 · high · 23 extracted teeth imaged by focus variation microscopy')
where fingerprint = 'cite_NCCLMICRO2017' and citation_tier = 5 and citation_type = 'other' and study_type is not distinct from 'in_vitro';
-- vth-uv5 (pages 3): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> expert_opinion/narrative_review/T6 · high · self-described narrative review')
where fingerprint = 'cite_UVPF05E6F7081920' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- eryag-root-canal-disinfection-sr (pages 3): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · PRISMA 2020; 4 databases; risk-of-bias checklist')
where fingerprint = 'cite_4CB0108B2F3D926B' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- vth-c49 (pages 3): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/null/T1 -> systematic_review/systematic_review/T1 · medium · PubMed search string, 363 screened, 16 included')
where fingerprint = 'cite_TMJINJ34299024' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from null;
-- p7-c6 (pages 2): T6 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> meta_analysis/meta_analysis/T1 · medium · PubMed search; 16 articles; meta-analysis performed')
where fingerprint = 'cite_B7CF93C35EF441A0' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- vth-c50 (pages 2): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · PROSPERO; PubMed/Embase/CENTRAL; network MA of RCTs')
where fingerprint = 'cite_TMJINJ36162894' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- fragment-reattachment-review (pages 2): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/null/T6 -> expert_opinion/narrative_review/T6 · high · descriptive review of classification and technique steps')
where fingerprint = 'cite_FFE3194B6244E387' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from null;
-- vth-c80 (pages 2): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · umbrella SR following PRISMA 2020')
where fingerprint = 'cite_SBOSA2026UMB' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- dental-implant-mronj-drug-history-2021 (pages 2): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · PRISMA; 5 databases')
where fingerprint = 'cite_IMPLANTMRONJHX2021' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';
-- osa-hypertension-ma-2018 (pages 2): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · PRISMA; PubMed+Embase; pooled OR')
where fingerprint = 'cite_A5E46DDD0ECC0B25' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-c53 (pages 2): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 4 databases; network MA of RCTs')
where fingerprint = 'cite_TMJINJ39294620' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- cpic-cyp2d6-betablocker-2024 (pages 2): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'clinical_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> clinical_guideline/clinical_guideline/T3 · medium · CPIC therapeutic recommendations by genotype')
where fingerprint = 'cite_5E9C7B14D3F0A628' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- vth-c60 (pages 2): T3 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/narrative_review/T3 -> expert_opinion/narrative_review/T6 · high · review defining paresthesia and causes; no search methods')
where fingerprint = 'cite_PARESTHDENT2010' and citation_tier = 3 and citation_type = 'other' and study_type is not distinct from 'narrative_review';
-- food4me-personalised-nutrition-2020 (pages 2): T2 -> T2
update public.seo_citations set citation_type = 'rct', study_type = 'randomized_controlled_trial', citation_tier = 2,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] rct/null/T2 -> rct/randomized_controlled_trial/T2 · high · 1607 adults randomised in Food4Me RCT')
where fingerprint = 'cite_6F0D8A25B4C71E39' and citation_tier = 2 and citation_type = 'rct' and study_type is not distinct from null;
-- vth-c52 (pages 2): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 5 databases; ROB 2/ROBINS-I; meta-analysis')
where fingerprint = 'cite_TMJINJ41091224' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- fiber-retainer-lucchese (pages 2): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/in_vitro/T6 -> other/in_vitro/T6 · high · SEM analysis of FRC retainer samples')
where fingerprint = 'cite_43C557102C009DFF' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'in_vitro';
-- naralan-2025-airway-software-comparison (pages 2): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/in_vitro/T5 -> other/in_vitro/T6 · high · 3D-printed airway model; software volumes vs water-filled gold standard')
where fingerprint = 'cite_CBCTAIRWAYSW2025' and citation_tier = 5 and citation_type = 'other' and study_type is not distinct from 'in_vitro';
-- cpap-blood-pressure-ipd-2025 (pages 2): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · SR of RCTs; IPD meta-analysis')
where fingerprint = 'cite_2652BCE160C85348' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- vth-c44 (pages 2): T6 -> T5
update public.seo_citations set citation_type = 'case_series', study_type = 'case_series', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] case_report/case_series/T6 -> case_series/case_series/T5 · medium · review of 1994-2008 patch test files; 24 patients')
where fingerprint = 'cite_31E131CADA504600' and citation_tier = 6 and citation_type = 'case_report' and study_type is not distinct from 'case_series';
-- cpap-adherence-macce-ipd-2023 (pages 2): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · multi-database search; IPD meta-analysis of RCTs')
where fingerprint = 'cite_F6F0A3B69EB86DC4' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- chen-2017-cbct-airway-software-accuracy (pages 2): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/in_vitro/T5 -> other/in_vitro/T6 · high · software reliability on CBCT sets + accuracy on printed phantom')
where fingerprint = 'cite_CBCTAIRWAY2017PHANTOM' and citation_tier = 5 and citation_type = 'other' and study_type is not distinct from 'in_vitro';
-- breathing-exercises-asthma-cochrane (pages 2): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · Cochrane SR; 6 databases; RCTs')
where fingerprint = 'cite_982C764A27E8D339' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- monteiro-2020-eryag-snoring-dualmode (pages 1): T5 -> T5
update public.seo_citations set citation_type = 'case_series', study_type = 'case_series', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] case_series/clinical_study/T5 -> case_series/case_series/T5 · high · 30 patients, before/after comparison, no control')
where fingerprint = 'cite_ERYAGSNORE2020INTERV' and citation_tier = 5 and citation_type = 'case_series' and study_type is not distinct from 'clinical_study';
-- p2-c3 (pages 1): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'expert_opinion', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/case_series/T6 -> expert_opinion/expert_opinion/T6 · medium · article presents a suturing technique; no patient series reported')
where fingerprint = 'cite_E1078AE3682B4710' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'case_series';
-- odontogenic-infection-complications-2022 (pages 1): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> expert_opinion/narrative_review/T6 · high · narrative review of complications')
where fingerprint = 'cite_ODONTOINFCOMPL2022' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- vth-c70 (pages 1): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · PubMed/Scopus/Embase; PRISMA; 9 RCTs')
where fingerprint = 'cite_BTXSB2024SR' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- pm37370027 (pages 1): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/in_vitro/T6 -> other/in_vitro/T6 · high · in-vitro randomised crossover on models; students vs instructors')
where fingerprint = 'cite_1738A6C92AC6E4C0' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'in_vitro';
-- dental-imaging-pregnancy-safety-2024 (pages 1): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> systematic_review/systematic_review/T1 · high · PubMed/Scopus/WoS search with inclusion criteria')
where fingerprint = 'cite_DENTALIMAGINGPREG2024' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- vth-c57 (pages 1): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · PubMed/Embase/Cochrane 2000-2025; PRISMA')
where fingerprint = 'cite_IANREPAIR2025SR' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- vth-c71 (pages 1): T6 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> meta_analysis/meta_analysis/T1 · medium · PRISMA SR and meta-analysis; databases + manual search')
where fingerprint = 'cite_BTXLP2025SR' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- rme-bruxism-osa-children-2025 (pages 1): T5 -> T5
update public.seo_citations set citation_type = 'case_series', study_type = 'case_series', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] case_series/pilot_study/T5 -> case_series/case_series/T5 · high · single-arm RME, re-evaluated after 6 months')
where fingerprint = 'cite_4EA2D895B9B21D52' and citation_tier = 5 and citation_type = 'case_series' and study_type is not distinct from 'pilot_study';
-- early-open-bite-mixed-dentition-sr-2025 (pages 1): T6 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/systematic_review/T6 -> systematic_review/systematic_review/T1 · high · 4 databases; PRISMA; RCTs')
where fingerprint = 'cite_7B3D5E1A9C64F208' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'systematic_review';
-- pm11238497 (pages 1): T4 -> T5
update public.seo_citations set citation_type = 'cohort_study', study_type = 'cohort_study', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/controlled_clinical_trial/T4 -> cohort_study/cohort_study/T5 · medium · 10 men on 7/13 sleep-wake schedule compared with men in continuous sleep; not randomised')
where fingerprint = 'cite_475AC289F9F8468D' and citation_tier = 4 and citation_type = 'other' and study_type is not distinct from 'controlled_clinical_trial';
-- sleep-restriction-testosterone-2011 (pages 1): T2 -> T5
update public.seo_citations set citation_type = 'case_series', study_type = 'case_series', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] rct/null/T2 -> case_series/case_series/T5 · medium · no abstract; 10 men, 1 week normal then 1 week restricted sleep (within-subject)')
where fingerprint = 'cite_2B8F4D31E6A75908' and citation_tier = 2 and citation_type = 'rct' and study_type is not distinct from null;
-- cpap-testosterone-ma-2019 (pages 1): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · PROSPERO; 4 sources; SR+MA')
where fingerprint = 'cite_3C7A6E92F1B84D50' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- omt-child-residual-osa (pages 1): T5 -> T5
update public.seo_citations set citation_type = 'cohort_study', study_type = 'prospective_cohort', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/controlled_clinical_trial/T5 -> cohort_study/prospective_cohort/T5 · medium · 37 children divided into treated vs untreated; no randomisation reported')
where fingerprint = 'cite_37592616081D9841' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'controlled_clinical_trial';
-- pm36991526 (pages 1): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/null/T1 -> systematic_review/systematic_review/T1 · high · 3 databases; only in-vitro studies included')
where fingerprint = 'cite_F6740F83E5C79EE0' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from null;
-- cbct-paediatric-dentistry-2019 (pages 1): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · SR of in-vivo paediatric studies + supplementary searches')
where fingerprint = 'cite_CBCTPEDIATRIC2019' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';
-- world-workshop-2017-non-plaque-induced-gingival-diseases (pages 1): T3 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> expert_opinion/narrative_review/T6 · medium · workshop review paper describing non-plaque gingival lesions')
where fingerprint = 'cite_WW2017NONPLAQUE' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';
-- p16-c5 (pages 1): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/in_vitro/T5 -> other/in_vitro/T6 · high · 3D-printed resin specimens with wires; mechanical tests')
where fingerprint = 'cite_C8EE9727FE5C4152' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'in_vitro';
-- vth-c55 (pages 1): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · 5 databases; RCTs pooled')
where fingerprint = 'cite_TMJINJ39097521' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- ultrasound-tmj-jia-2026 (pages 1): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · 5 databases + grey literature; diagnostic studies')
where fingerprint = 'cite_7A3E1D60C58B942F' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';
-- collagen-peptides-bmd-2018 (pages 1): T2 -> T2
update public.seo_citations set citation_type = 'rct', study_type = 'randomized_controlled_trial', citation_tier = 2,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] rct/null/T2 -> rct/randomized_controlled_trial/T2 · high · 131 women, randomised placebo-controlled double-blind')
where fingerprint = 'cite_4D6B5A08C2E93F71' and citation_tier = 2 and citation_type = 'rct' and study_type is not distinct from null;
-- dental-implants-growing-patients-2019 (pages 1): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · PRISMA; 4 databases')
where fingerprint = 'cite_IMPLANTGROWING2019' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';
-- osa-cv-risk-cohort-ma-2025 (pages 1): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/null/T1 -> meta_analysis/meta_analysis/T1 · high · PRISMA; PROSPERO; 18 cohorts pooled')
where fingerprint = 'cite_6670DE949F7C30BA' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from null;
-- lin-2024-tmd-brain-mendelian (pages 1): T4 -> T5
update public.seo_citations set citation_type = 'other', study_type = 'mendelian_randomization', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/genetic_association/T4 -> other/mendelian_randomization/T5 · high · Mendelian randomisation of TMD and brain imaging phenotypes')
where fingerprint = 'cite_TMDBRAINMR2024' and citation_tier = 4 and citation_type = 'other' and study_type is not distinct from 'genetic_association';
-- p6-c9 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_2DBE6DA1707540BF' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- titanium-hypersensitivity-implants-2026 (pages 0): T5 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] case_series/other/T5 -> systematic_review/systematic_review/T1 · high · PRISMA; 4 databases; 9 studies (mostly case reports)')
where fingerprint = 'cite_TITANIUMHYPERSENS2026' and citation_tier = 5 and citation_type = 'case_series' and study_type is not distinct from 'other';
-- p5-c4 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_AD4E4E3ADC6A430F' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- p12-c5 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_115DFBA5BEA8459A' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- aap-non-surgical-treatments (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'patient_resource', study_type = 'patient_resource', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] patient_resource/patient_information_page/T6 -> patient_resource/patient_resource/T6 · high · AAP for-patients web page')
where fingerprint = 'cite_114AD575CF974B40' and citation_tier = 6 and citation_type = 'patient_resource' and study_type is not distinct from 'patient_information_page';
-- cx.2 (pages 0): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'clinical_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> clinical_guideline/clinical_guideline/T3 · high · NICE TA1 guidance (URL)')
where fingerprint = 'cite_EDB2933E8B324183' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- p8-c5 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_5BA22A0F8F5B4862' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- p11-c5 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_097971E6EABF4A6A' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- sweeps-pips-irrigation (pages 0): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/in_vitro/T5 -> other/in_vitro/T6 · high · 50 extracted teeth randomly assigned; smear layer graded')
where fingerprint = 'cite_682DB1D82318D243' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'in_vitro';
-- p15-c7 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_F55341D57EC149BB' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- p9-c4 (pages 0): T3 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'clinical_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> clinical_guideline/clinical_guideline/T3 · medium · EFP S3-level clinical practice guideline (2023), publisher stated')
where fingerprint = 'cite_159EBD6AA7D84EBD' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- onabotulinumtoxina-pregnancy-safety-2026 (pages 0): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · PubMed/Scopus/WoS searched')
where fingerprint = 'cite_BOTOXPREGNANCY2026' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';
-- p11-c2 (pages 0): T1 -> T3
update public.seo_citations set citation_type = 'clinical_guideline', study_type = 'clinical_guideline', citation_tier = 3,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T1 -> clinical_guideline/clinical_guideline/T3 · medium · AAE treatment standards / position papers (society guidance)')
where fingerprint = 'cite_005DB7BA4E864B7B' and citation_tier = 1 and citation_type = 'other' and study_type is not distinct from null;
-- p16-c8 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'industry_publication', study_type = 'manufacturer_document', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] industry_publication/null/T6 -> industry_publication/manufacturer_document/T6 · high · manufacturer documentation')
where fingerprint = 'cite_7B039168BB1441EC' and citation_tier = 6 and citation_type = 'industry_publication' and study_type is not distinct from null;
-- mronj-after-extraction-meta-2015 (pages 0): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/other/T1 -> meta_analysis/meta_analysis/T1 · high · PubMed/EMBASE/LILACS; MA of incidence')
where fingerprint = 'cite_MRONJEXTRACTMA2015' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from 'other';
-- sleep-quality-academic-ma (pages 0): T6 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/meta_analysis/T6 -> meta_analysis/meta_analysis/T1 · high · PRISMA 2020; 72 effect sizes from 59 articles')
where fingerprint = 'cite_1F0A6CA7754C8AA2' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'meta_analysis';
-- p16-c9 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_44F6F66DA92A41AA' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- p7-c1 (pages 0): T4 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T4 -> other/in_vitro/T6 · high · 72 osteotomies in porcine tibial bone samples')
where fingerprint = 'cite_8DFAAEC7629644D1' and citation_tier = 4 and citation_type = 'other' and study_type is not distinct from null;
-- p16-c7 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'industry_publication', study_type = 'manufacturer_document', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] industry_publication/null/T6 -> industry_publication/manufacturer_document/T6 · medium · manufacturer FDA-clearance and clinical claims')
where fingerprint = 'cite_066661CBAFE24AC1' and citation_tier = 6 and citation_type = 'industry_publication' and study_type is not distinct from null;
-- p4-c4 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_6C7FCA130A454B9E' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- p3-c5 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_626B51CED5D74838' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- p10-c6 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_CB1C2BB367A74922' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- dental-implant-organ-transplant-2021 (pages 0): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · electronic + manual search; 10 articles, 93 patients')
where fingerprint = 'cite_IMPLANTTRANSPLANT2021' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';
-- nhs-crown-lengthening-surgery (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'patient_resource', study_type = 'patient_resource', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] patient_resource/patient_information_leaflet/T6 -> patient_resource/patient_resource/T6 · high · NHS trust patient information leaflet')
where fingerprint = 'cite_F01DEE4000944D11' and citation_tier = 6 and citation_type = 'patient_resource' and study_type is not distinct from 'patient_information_leaflet';
-- sso-2569 (pages 0): T4 -> T4
update public.seo_citations set citation_type = 'regulatory_document', study_type = 'regulatory_document', citation_tier = 4,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] regulatory_document/fact_sheet/T4 -> regulatory_document/regulatory_document/T4 · medium · Social Security Office document stating 2569 dental benefit entitlements')
where fingerprint = 'cite_4DEA3603E5B9409B' and citation_tier = 4 and citation_type = 'regulatory_document' and study_type is not distinct from 'fact_sheet';
-- glycemic-control-postextraction-2015 (pages 0): T5 -> T5
update public.seo_citations set citation_type = 'case_control', study_type = 'case_control', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] case_control/other/T5 -> case_control/case_control/T5 · medium · prospective study, 53 diabetic vs 29 non-diabetic, after extraction')
where fingerprint = 'cite_DIABEXTRACT2015' and citation_tier = 5 and citation_type = 'case_control' and study_type is not distinct from 'other';
-- p2-c6 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_E1BDDA2AD40E46ED' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- p7-c8 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_0BF77F3AD9FF45A9' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- cardiovascular-dental-management-2022 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> expert_opinion/narrative_review/T6 · high · self-described narrative review')
where fingerprint = 'cite_CVDDENTALMGMT2022' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- haemophilia-dental-guidelines-review-2025 (pages 0): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · 6 databases; 11 guidelines extracted')
where fingerprint = 'cite_HAEMOPHILIADENTGL2025' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';
-- vth-c32 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · internal outcomes registry placeholder')
where fingerprint = 'cite_78516472F67043E4' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- c6.2 (pages 0): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/null/T1 -> systematic_review/systematic_review/T1 · high · Cochrane SR; trials registers searched')
where fingerprint = 'cite_F5F076DBD0C14D9B' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from null;
-- anesthetic-management-pregnant-dental-2021 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'narrative_review', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] expert_opinion/other/T6 -> expert_opinion/narrative_review/T6 · high · narrative review of fetal pharmacology for dentists')
where fingerprint = 'cite_PREGNANCYANESTH2021' and citation_tier = 6 and citation_type = 'expert_opinion' and study_type is not distinct from 'other';
-- onabotulinumtoxina-pediatric-safety-2024 (pages 0): T1 -> T1
update public.seo_citations set citation_type = 'meta_analysis', study_type = 'meta_analysis', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] meta_analysis/other/T1 -> meta_analysis/meta_analysis/T1 · high · PRISMA SR; RCTs+observational; MA')
where fingerprint = 'cite_BOTOXPEDIATRIC2024' and citation_tier = 1 and citation_type = 'meta_analysis' and study_type is not distinct from 'other';
-- inherited-bleeding-oral-surgery-2024 (pages 0): T5 -> T5
update public.seo_citations set citation_type = 'cohort_study', study_type = 'retrospective_cohort', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/other/T5 -> cohort_study/retrospective_cohort/T5 · medium · retrospective observational study of patients with bleeding disorders')
where fingerprint = 'cite_BLEEDORALSURG2024' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'other';
-- vth-c31 (pages 0): T5 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'in_vitro', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/in_vitro/T5 -> other/in_vitro/T6 · high · 56 Wistar rats; 72 h sleep deprivation')
where fingerprint = 'cite_F9F57866679E4191' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'in_vitro';
-- antifibrinolytic-oral-surgery-haemophilia-2019 (pages 0): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · Cochrane review update; trials register searched')
where fingerprint = 'cite_HAEMOPHILIAEXTRACT2019' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';
-- immunosuppressive-drugs-extraction-healing-2018 (pages 0): T5 -> T5
update public.seo_citations set citation_type = 'cohort_study', study_type = 'retrospective_cohort', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] cohort_study/other/T5 -> cohort_study/retrospective_cohort/T5 · high · retrospective cohort of 101 patients from records')
where fingerprint = 'cite_IMMUNOSUPPEXTRACT2018' and citation_tier = 5 and citation_type = 'cohort_study' and study_type is not distinct from 'other';
-- cx.3 (pages 0): T3 -> T6
update public.seo_citations set citation_type = 'patient_resource', study_type = 'patient_resource', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> patient_resource/patient_resource/T6 · medium · aaoinfo.org consumer page')
where fingerprint = 'cite_C9DF1D8DD3384410' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- p9-c6 (pages 0): T6 -> T6
update public.seo_citations set citation_type = 'other', study_type = 'other', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] other/null/T6 -> other/other/T6 · high · first-party clinic audit, no external id')
where fingerprint = 'cite_F08174B4334741A7' and citation_tier = 6 and citation_type = 'other' and study_type is not distinct from null;
-- mronj-implant-regenerative-2019 (pages 0): T1 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] systematic_review/other/T1 -> systematic_review/systematic_review/T1 · high · PubMed MeSH search, last 5 years')
where fingerprint = 'cite_MRONJIMPLANTREGEN2019' and citation_tier = 1 and citation_type = 'systematic_review' and study_type is not distinct from 'other';

-- 2b. JUDGEMENT CALL 1 (5 rows): guidelines that report their own systematic review -> T1 (rule 4 applied beyond
--     systematic_review_guideline rows). Comment this block out to keep them at T3.
-- cx.1 (pages 21): T3 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> systematic_review/systematic_review/T1 · medium · panel conducted SR: MEDLINE+Cochrane searched, 71 trials included, then recommendations')
where fingerprint = 'cite_D04445E318FF4A25' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- vth-c2 (pages 19): T3 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> systematic_review/systematic_review/T1 · medium · AASM guideline: SR of literature + GRADE; PubMed tags Meta-Analysis/SR')
where fingerprint = 'cite_23F680BB1E38449A' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- aapd-vital-pulp-therapy-primary-teeth-guideline-2024 (pages 3): T3 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/systematic_review/T3 -> systematic_review/systematic_review/T1 · high · guideline built on own SR/MA with GRADE')
where fingerprint = 'cite_CC52103CBAFC65AC' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'systematic_review';
-- vth-c56 (pages 1): T3 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/systematic_review/T3 -> systematic_review/systematic_review/T1 · medium · guideline built on systematic literature review in multiple databases + Delphi')
where fingerprint = 'cite_TMJINJ34874262' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'systematic_review';
-- onj-taskforce-antiresorptive-implant-2025 (pages 0): T3 -> T1
update public.seo_citations set citation_type = 'systematic_review', study_type = 'systematic_review', citation_tier = 1,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> systematic_review/systematic_review/T1 · medium · Taskforce conducted SR then GRADEd consensus recommendation')
where fingerprint = 'cite_ONJTASKFORCE2025' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';

-- 2c. JUDGEMENT CALL 2 (2 rows): consensus built on expert agreement only (no evidence search) -> consensus_statement T6.
--     Comment out to keep them at T3.
-- vth-c10 (pages 21): T3 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'consensus_statement', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/null/T3 -> expert_opinion/consensus_statement/T6 · medium · expert consensus updating bruxism definition; no systematic search or appraisal')
where fingerprint = 'cite_311B8BAC19354EA8' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from null;
-- vth-c42 (pages 18): T3 -> T6
update public.seo_citations set citation_type = 'expert_opinion', study_type = 'consensus_statement', citation_tier = 6,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] clinical_guideline/other/T3 -> expert_opinion/consensus_statement/T6 · medium · written consensus discussion among bruxism experts; no evidence search')
where fingerprint = 'cite_AAED1234FC0C4301' and citation_tier = 3 and citation_type = 'clinical_guideline' and study_type is not distinct from 'other';

-- 2d. JUDGEMENT CALL 3 (2 rows): Thai national oral health surveys classified by conduct (cross-sectional, T5)
--     rather than 'government report' (T4). Comment out to keep T4.
-- th-national-oral-health-survey-9 (pages 12): T4 -> T5
update public.seo_citations set citation_type = 'cross_sectional', study_type = 'cross_sectional', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] regulatory_document/survey_report/T4 -> cross_sectional/cross_sectional/T5 · medium · national oral health survey (Dept of Health) = cross-sectional epidemiology')
where fingerprint = 'cite_TH01A2B3C4D5E601' and citation_tier = 4 and citation_type = 'regulatory_document' and study_type is not distinct from 'survey_report';
-- th-oral-health-survey-9-hsri-p2 (pages 4): T4 -> T5
update public.seo_citations set citation_type = 'cross_sectional', study_type = 'cross_sectional', citation_tier = 5,
  maintenance_log = concat_ws(E'\n', maintenance_log, '[DR-077 2026-10-22] regulatory_document/survey_report/T4 -> cross_sectional/cross_sectional/T5 · medium · national oral health survey phase 2 (HSRI)')
where fingerprint = 'cite_TH02A2B3C4D5E602' and citation_tier = 4 and citation_type = 'regulatory_document' and study_type is not distinct from 'survey_report';

-- 2e. NOT CHANGED — needs a human (9 rows: no identifiable source, or low confidence):
--   vth-c3 (pages 1, now clinical_guideline/null/T3): No PMID; nosology reference, kept guideline tier.
--   p5-c3 (pages 0, now expert_opinion/null/T6): needs human: source not identifiable (likely expert_opinion/6).
--   p15-c2 (pages 0, now other/null/T1): Mirrors cx.1; confirm which edition (2006 vs 2013).
--   p1-c5 (pages 0, now expert_opinion/null/T6): needs human: cannot establish document or design.
--   vth-c26 (pages 0, now other/null/T2): needs human: cannot verify source; current tier 2 unsupported.
--   p3-c4 (pages 0, now expert_opinion/null/T6): needs human: source not identifiable (likely expert_opinion/6).
--   prd-2569 (pages 0, now regulatory_document/report/T4): Unchanged per rule 5, but it is a PR/news item; news_article (6) arguable.
--   p5-c2 (pages 0, now expert_opinion/null/T6): needs human.
--   p4-c3 (pages 0, now clinical_guideline/null/T3): needs human: cannot confirm document exists.

-- 3. The duplicate checker: gate G14 is the canonical cross-check.
drop view if exists public.v_citation_type_mismatch;

commit;
