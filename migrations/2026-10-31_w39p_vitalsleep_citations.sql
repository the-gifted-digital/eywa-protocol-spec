-- W39p · VitalSleep citation intake: 38 new citations + 46 page bindings + 2 reserved page rows (DRAFT, not applied) · 2026-10-31
-- Source: brand session "การเชื่อมต่อ WordPress" TSV content/consolidation/vitalsleep-citations-2026-10-31.tsv (40 rows, all locator
-- PASS per Citation_Pool_SOP §3; title/journal/year from PubMed). Authors and language filled from PubMed esummary 2026-10-31.
-- Duplicates already in the pool (not re-inserted, only bound): 35867153 (NightLase sham RCT, T2, scope *) and 40566115 (Er:YAG SR/MA,
-- T1, verified; scope was vth-biodent only and gets vitalsleep-clinic appended — it is not first-party data).
-- Tier check requested by the brand session: 26620900 (Wang 2015) abstract read 2026-10-31 — literature search of MEDLINE/Embase/Cochrane,
-- 5 studies / 307 patients pooled (SMD) → SR/MA by conduct, T1 stands (DR-063). 40566115 was already verified T1 in the pool.
-- All other tiers are taken as sent. verification_status = 'verified' set explicitly (an unset value defaults to unverified and trips G2). brand_scope '*' (none is first-party).
-- Not live yet, reserved as status 'Planned': /excessive-daytime-sleepiness/ = ง่วงนอนตลอดเวลา (its citations bind by FK) and
-- /sleep-cycle-sleep-schedule/ = ตาราง นอน (brand session 2026-10-31).
-- Binding: citation_purpose guideline_reference for clinical_guideline rows, else supporting_evidence; section_context 'references'.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create temp table w39p_cite (title text, authors text[], yr smallint, pmid text, doi text, url text, journal text,
                             tier smallint, ctype text, stype text, lang text, slug text, note text) on commit drop;
create temp table w39p_bind (slug text, pmid text, purpose text) on commit drop;

insert into w39p_cite values
('Sleep disordered breathing and nocturnal polyuria: nocturia and enuresis.', array['Umlauf MG','Chasens ER']::text[], 2003, '14573376', '10.1053/smrv.2002.0273', 'https://pubmed.ncbi.nlm.nih.gov/14573376/', 'Sleep medicine reviews', 6, 'expert_opinion', 'narrative_review', 'en', 'umlauf-2003-pmid14573376', 'tier_source=abstract-read; locator PASS 1.0'),
('[Nocturia in obstructive sleep apnoea (OSA)].', array['Pływaczewski R','Stokłosa A','Bednarek M','Czerniawska J','Bieleń P','Górecka D','Sliwiński P']::text[], 2007, '17973220', null, 'https://pubmed.ncbi.nlm.nih.gov/17973220/', 'Pneumonologia i alergologia polska', 5, 'cross_sectional', 'cross_sectional', 'pl', 'pywaczewski-2007-pmid17973220', 'tier_source=abstract-read; locator PASS 1.0'),
('The Efficacy of Continuous Positive Airway Pressure Therapy on Nocturia in Patients With Obstructive Sleep Apnea: A Systematic Review and Meta-Analysis.', array['Wang T','Huang W','Zong H','Zhang Y']::text[], 2015, '26620900', '10.5213/inj.2015.19.3.178', 'https://pubmed.ncbi.nlm.nih.gov/26620900/', 'International neurourology journal', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'wang-2015-pmid26620900', 'tier_source=abstract-read; locator PASS 1.0'),
('Is the High-Intensity Focused Electromagnetic Energy an Effective Treatment for Urinary Incontinence in Women?', array['Tosun H','Akınsal EC','Sönmez G','Baydilli N','Demirci D']::text[], 2024, '39640007', '10.2147/tcrm.s478919', 'https://pubmed.ncbi.nlm.nih.gov/39640007/', 'Therapeutics and clinical risk management', 5, 'cohort_study', 'clinical_study', 'en', 'tosun-2024-pmid39640007', 'tier_source=abstract-read; locator PASS 1.0'),
('Evaluating the Efficacy of High-Intensity Focused Electromagnetic (HIFEM) Therapy for Postprostatectomy Incontinence in Men.', array['Tosun H','Akinsal EC','Bas U','Sonmez G','Baydilli N','Demirci D']::text[], 2025, '40909763', '10.2147/tcrm.s534674', 'https://pubmed.ncbi.nlm.nih.gov/40909763/', 'Therapeutics and clinical risk management', 5, 'cohort_study', 'clinical_study', 'en', 'tosun-2025-pmid40909763', 'tier_source=abstract-read; locator PASS 1.0'),
('Prevalence of Sleepwalking: A Systematic Review and Meta-Analysis.', array['Stallman HM','Kohler M']::text[], 2016, '27832078', '10.1371/journal.pone.0164769', 'https://pubmed.ncbi.nlm.nih.gov/27832078/', 'PloS one', 1, 'systematic_review', 'systematic_review', 'en', 'stallman-2016-pmid27832078', 'tier_source=pubtype; locator PASS 1.0'),
('Sleepwalking and sleep terrors in prepubertal children: what triggers them?', array['Guilleminault C','Palombini L','Pelayo R','Chervin RD']::text[], 2003, '12509590', '10.1542/peds.111.1.e17', 'https://pubmed.ncbi.nlm.nih.gov/12509590/', 'Pediatrics', 5, 'cohort_study', 'prospective_cohort', 'en', 'guilleminault-2003-pmid12509590', 'tier_source=abstract-read; locator PASS 1.0'),
('Families with sleepwalking.', array['Cao M','Guilleminault C']::text[], 2010, '20598633', '10.1016/j.sleep.2010.01.011', 'https://pubmed.ncbi.nlm.nih.gov/20598633/', 'Sleep medicine', 5, 'case_series', 'case_series', 'en', 'cao-2010-pmid20598633', 'tier_source=abstract-read; locator PASS 1.0'),
('[Daytime sleepiness with recurrent nocturnal fall-related injuries: a case report of somnambulism triggered by severe obstructive sleep apnea].', array['Hu SS','Zhang Q','Lin MY','Zhou MM','Ge YJ']::text[], 2026, '42811568', '10.3760/cma.j.cn112147-20260526-00311', 'https://pubmed.ncbi.nlm.nih.gov/42811568/', 'Zhonghua jie he he hu xi za zhi = Zhonghua jiehe he huxi zazhi = Chinese journal of tuberculosis and respiratory diseases', 6, 'case_report', 'case_report', 'zh', 'hu-2026-pmid42811568', 'tier_source=pubtype; locator PASS 0.5'),
('REM sleep behavior disorder: Mimics and variants.', array['Antelmi E','Lippolis M','Biscarini F','Tinazzi M','Plazzi G']::text[], 2021, '34186416', '10.1016/j.smrv.2021.101515', 'https://pubmed.ncbi.nlm.nih.gov/34186416/', 'Sleep medicine reviews', 6, 'expert_opinion', 'narrative_review', 'en', 'antelmi-2021-pmid34186416', 'tier_source=abstract-read; locator PASS 1.0'),
('Sleepwalking and sleep-related eating associated with atypical antipsychotic medications: Case series and systematic review of literature.', array['Chopra A','Patel RS','Baliga N','Narahari A','Das P']::text[], 2020, '32535329', '10.1016/j.genhosppsych.2020.05.014', 'https://pubmed.ncbi.nlm.nih.gov/32535329/', 'General hospital psychiatry', 1, 'systematic_review', 'systematic_review', 'en', 'chopra-2020-pmid32535329', 'tier_source=pubtype; locator PASS 0.67'),
('Minimally invasive erbium laser treatment for selected snorers.', array['Frelich H','Ścierski W','Marków M','Frelich J','Frelich H','Maciej M']::text[], 2019, '30762193', '10.1007/s10103-019-02731-6', 'https://pubmed.ncbi.nlm.nih.gov/30762193/', 'Lasers in medical science', 5, 'cohort_study', 'clinical_study', 'en', 'frelich-2019-pmid30762193', 'tier_source=abstract-read; locator PASS 1.0'),
('Erbium:Yttrium Aluminum Garnet (Er:YAG) Laser: A Minimally Invasive Treatment Method in Selected Patients with Impaired Breathing During Sleep-The Assessment of Treatment Effectiveness After 4 Years.', array['Frelich H','Marków M','Tażbirek M','Frelich-Truchel H','Misiołek M','Ścierski W']::text[], 2023, '37579131', '10.1089/photob.2022.0144', 'https://pubmed.ncbi.nlm.nih.gov/37579131/', 'Photobiomodulation, photomedicine, and laser surgery', 5, 'cohort_study', 'prospective_cohort', 'en', 'frelich-2023-pmid37579131', 'tier_source=abstract-read; locator PASS 0.82'),
('A Long-Term Follow-up Study for the Treatment of Snoring after Using Patterned Non-Ablative Erbium: YAG 2,940 nm Laser.', array['Kassab AN','Kharbotly AE','Elsamie AA','Ahmed MR']::text[], 2023, '36714903', '10.1055/s-0042-1744171', 'https://pubmed.ncbi.nlm.nih.gov/36714903/', 'International archives of otorhinolaryngology', 5, 'cohort_study', 'prospective_cohort', 'en', 'kassab-2023-pmid36714903', 'tier_source=abstract-read; locator PASS 1.0'),
('Nocturnal sweating--a common symptom of obstructive sleep apnoea: the Icelandic sleep apnoea cohort.', array['Arnardottir ES','Janson C','Bjornsdottir E','Benediktsdottir B','Juliusson S','Kuna ST','Pack AI','Gislason T']::text[], 2013, '23674447', '10.1136/bmjopen-2013-002795', 'https://pubmed.ncbi.nlm.nih.gov/23674447/', 'BMJ open', 5, 'cohort_study', 'cohort_study', 'en', 'arnardottir-2013-pmid23674447', 'tier_source=abstract-read; locator PASS 1.0'),
('Prevalence of night sweats in primary care patients: an OKPRN and TAFP-Net collaborative study.', array['Mold JW','Mathew MK','Belgore S','DeHaven M']::text[], 2002, '12019054', null, 'https://pubmed.ncbi.nlm.nih.gov/12019054/', 'The Journal of family practice', 5, 'cross_sectional', 'cross_sectional', 'en', 'mold-2002-pmid12019054', 'tier_source=abstract-read; locator PASS 1.0'),
('Night sweats: a systematic review of the literature.', array['Mold JW','Holtzclaw BJ','McCarthy L']::text[], 2012, '23136329', '10.3122/jabfm.2012.06.120033', 'https://pubmed.ncbi.nlm.nih.gov/23136329/', 'Journal of the American Board of Family Medicine : JABFM', 1, 'systematic_review', 'systematic_review', 'en', 'mold-2012-pmid23136329', 'tier_source=pubtype; locator PASS 1.0'),
('Hyperhidrosis in sleep disorders - A narrative review of mechanisms and clinical significance.', array['Idiaquez J','Casar JC','Arnardottir ES','August E','Santin J','Iturriaga R']::text[], 2023, '35706374', '10.1111/jsr.13660', 'https://pubmed.ncbi.nlm.nih.gov/35706374/', 'Journal of sleep research', 6, 'expert_opinion', 'narrative_review', 'en', 'idiaquez-2023-pmid35706374', 'tier_source=abstract-read; locator PASS 1.0'),
('Women and obstructive sleep apnea syndrome: Can we finally ask the right questions? The OSAF study.', array['Trotta L','Antonaglia C','Fabozzi A','Stanganelli M','Nikolli L','Scialla F','Steffanina A','Citton GM','Galantino A','Maggisano M','De Nes A','Ruaro B','Salton F','Bonini M','Palange P','Confalonieri M']::text[], 2026, '42030838', '10.1016/j.sleep.2026.108932', 'https://pubmed.ncbi.nlm.nih.gov/42030838/', 'Sleep medicine', 5, 'cohort_study', 'prospective_cohort', 'en', 'trotta-2026-pmid42030838', 'tier_source=abstract-read; locator PASS 1.0'),
('Clinical features of obstructive sleep apnea in children with obesity.', array['Liu AL','Zheng YJ','Su Z','Wei JR','Yang Q','Wang CC','Li JH']::text[], 2021, '34535209', '10.7499/j.issn.1008-8830.2104155', 'https://pubmed.ncbi.nlm.nih.gov/34535209/', 'Zhongguo dang dai er ke za zhi = Chinese journal of contemporary pediatrics', 5, 'cohort_study', 'retrospective_cohort', 'en', 'liu-2021-pmid34535209', 'tier_source=abstract-read; locator PASS 1.0'),
('Treatment of restless legs syndrome and periodic limb movement disorder: an American Academy of Sleep Medicine clinical practice guideline.', array['Winkelman JW','Berkowski JA','DelRosso LM','Koo BB','Scharf MT','Sharon D','Zak RS','Kazmi U','Falck-Ytter Y','Shelgikar AV','Trotti LM','Walters AS']::text[], 2025, '39324694', '10.5664/jcsm.11390', 'https://pubmed.ncbi.nlm.nih.gov/39324694/', 'Journal of clinical sleep medicine : JCSM : official publication of the American Academy of Sleep Medicine', 3, 'clinical_guideline', 'clinical_guideline', 'en', 'winkelman-2025-pmid39324694', 'tier_source=pubtype; locator PASS 1.0'),
('Restless legs syndrome/Willis-Ekbom disease diagnostic criteria: updated International Restless Legs Syndrome Study Group (IRLSSG) consensus criteria--history, rationale, description, and significance.', array['Allen RP','Picchietti DL','Garcia-Borreguero D','Ondo WG','Walters AS','Winkelman JW','Zucconi M','Ferri R','Trenkwalder C','Lee HB']::text[], 2014, '25023924', '10.1016/j.sleep.2014.03.025', 'https://pubmed.ncbi.nlm.nih.gov/25023924/', 'Sleep medicine', 6, 'expert_opinion', 'consensus_statement', 'en', 'allen-2014-pmid25023924', 'tier_source=pubtype; locator PASS 0.58'),
('Epidemiology of restless legs syndrome: a synthesis of the literature.', array['Ohayon MM','O''Hara R','Vitiello MV']::text[], 2012, '21795081', '10.1016/j.smrv.2011.05.002', 'https://pubmed.ncbi.nlm.nih.gov/21795081/', 'Sleep medicine reviews', 6, 'expert_opinion', 'narrative_review', 'en', 'ohayon-2012-pmid21795081', 'tier_source=abstract-read; locator PASS 1.0'),
('Exploring the obstructive sleep apnea and restless legs syndrome comorbidity (Co-ROSA): A systematic review.', array['Tam J','Garcia Borreguero D','DelRosso LM']::text[], 2025, '41061431', '10.1016/j.smrv.2025.102178', 'https://pubmed.ncbi.nlm.nih.gov/41061431/', 'Sleep medicine reviews', 1, 'systematic_review', 'systematic_review', 'en', 'tam-2025-pmid41061431', 'tier_source=pubtype; locator PASS 1.0'),
('Efficacy and Safety of Simultaneous Application of HIFEM and Synchronized Radiofrequency for Abdominal Fat Reduction and Muscle Toning: A Multicenter Magnetic Resonance Imaging Evaluation Study.', array['Jacob C','Kent D','Ibrahim O']::text[], 2021, '34001694', '10.1097/dss.0000000000003086', 'https://pubmed.ncbi.nlm.nih.gov/34001694/', 'Dermatologic surgery : official publication for American Society for Dermatologic Surgery [et al.]', 5, 'cohort_study', 'clinical_study', 'en', 'jacob-2021-pmid34001694', 'tier_source=abstract-read; locator PASS 1.0'),
('Radiofrequency Heating and High-Intensity Focused Electromagnetic Treatment Delivered Simultaneously: The First Sham-Controlled Randomized Trial.', array['Samuels JB','Katz B','Weiss RA']::text[], 2022, '35259147', '10.1097/prs.0000000000009030', 'https://pubmed.ncbi.nlm.nih.gov/35259147/', 'Plastic and reconstructive surgery', 2, 'rct', 'rct', 'en', 'samuels-2022-pmid35259147', 'tier_source=pubtype; locator PASS 1.0'),
('Longitudinal study of moderate weight change and sleep-disordered breathing.', array['Peppard PE','Young T','Palta M','Dempsey J','Skatrud J']::text[], 2000, '11122588', '10.1001/jama.284.23.3015', 'https://pubmed.ncbi.nlm.nih.gov/11122588/', 'JAMA', 5, 'cohort_study', 'prospective_cohort', 'en', 'peppard-2000-pmid11122588', 'tier_source=abstract-read; locator PASS 1.0'),
('Effect of Weight Loss on Upper Airway Anatomy and the Apnea-Hypopnea Index. The Importance of Tongue Fat.', array['Wang SH','Keenan BT','Wiemken A','Zang Y','Staley B','Sarwer DB','Torigian DA','Williams N','Pack AI','Schwab RJ']::text[], 2020, '31918559', '10.1164/rccm.201903-0692oc', 'https://pubmed.ncbi.nlm.nih.gov/31918559/', 'American journal of respiratory and critical care medicine', 5, 'cohort_study', 'prospective_cohort', 'en', 'wang-2020-pmid31918559', 'tier_source=abstract-read; locator PASS 1.0'),
('Upper airway fat tissue distribution in subjects with obstructive sleep apnea and its effect on retropalatal mechanical loads.', array['Li Y','Lin N','Ye J','Chang Q','Han D','Sperry A']::text[], 2012, '22273428', '10.4187/respcare.00929', 'https://pubmed.ncbi.nlm.nih.gov/22273428/', 'Respiratory care', 5, 'case_control', 'cross_sectional', 'en', 'li-2012-pmid22273428', 'tier_source=abstract-read; locator PASS 1.0'),
('An official American Thoracic Society statement: update on the mechanisms, assessment, and management of dyspnea.', array['Parshall MB','Schwartzstein RM','Adams L','Banzett RB','Manning HL','Bourbeau J','Calverley PM','Gift AG','Harver A','Lareau SC','Mahler DA','Meek PM','O''Donnell DE']::text[], 2012, '22336677', '10.1164/rccm.201111-2042st', 'https://pubmed.ncbi.nlm.nih.gov/22336677/', 'American journal of respiratory and critical care medicine', 3, 'clinical_guideline', 'clinical_guideline', 'en', 'parshall-2012-pmid22336677', 'tier_source=pubtype; locator PASS 1.0'),
('Dysfunctional breathing: a review of the literature and proposal for classification.', array['Boulding R','Stacey R','Niven R','Fowler SJ']::text[], 2016, '27581828', '10.1183/16000617.0088-2015', 'https://pubmed.ncbi.nlm.nih.gov/27581828/', 'European respiratory review : an official journal of the European Respiratory Society', 6, 'expert_opinion', 'narrative_review', 'en', 'boulding-2016-pmid27581828', 'tier_source=abstract-read; locator PASS 1.0'),
('Usefulness of the Medical Research Council (MRC) dyspnoea scale as a measure of disability in patients with chronic obstructive pulmonary disease.', array['Bestall JC','Paul EA','Garrod R','Garnham R','Jones PW','Wedzicha JA']::text[], 1999, '10377201', '10.1136/thx.54.7.581', 'https://pubmed.ncbi.nlm.nih.gov/10377201/', 'Thorax', 5, 'cross_sectional', 'cross_sectional', 'en', 'bestall-1999-pmid10377201', 'tier_source=abstract-read; locator PASS 1.0'),
('A new method for measuring daytime sleepiness: the Epworth sleepiness scale.', array['Johns MW']::text[], 1991, '1798888', '10.1093/sleep/14.6.540', 'https://pubmed.ncbi.nlm.nih.gov/1798888/', 'Sleep', 5, 'cross_sectional', 'cross_sectional', 'en', 'johns-1991-pmid1798888', 'tier_source=abstract-read; locator PASS None'),
('Obstructive sleep apnea and risk of motor vehicle crash: systematic review and meta-analysis.', array['Tregear S','Reston J','Schoelles K','Phillips B']::text[], 2009, '20465027', null, 'https://pubmed.ncbi.nlm.nih.gov/20465027/', 'Journal of clinical sleep medicine : JCSM : official publication of the American Academy of Sleep Medicine', 1, 'systematic_review', 'systematic_review', 'en', 'tregear-2009-pmid20465027', 'tier_source=pubtype; locator PASS None'),
('Treatment of Adult Obstructive Sleep Apnea with Positive Airway Pressure: An American Academy of Sleep Medicine Clinical Practice Guideline.', array['Patil SP','Ayappa IA','Caples SM','Kimoff RJ','Patel SR','Harrod CG']::text[], 2019, '30736887', '10.5664/jcsm.7640', 'https://pubmed.ncbi.nlm.nih.gov/30736887/', 'Journal of clinical sleep medicine : JCSM : official publication of the American Academy of Sleep Medicine', 3, 'clinical_guideline', 'clinical_guideline', 'en', 'patil-2019-pmid30736887', 'tier_source=pubtype; locator PASS None'),
('Recommended Amount of Sleep for a Healthy Adult: A Joint Consensus Statement of the American Academy of Sleep Medicine and Sleep Research Society.', array['Watson NF','Badr MS','Belenky G','Bliwise DL','Buxton OM','Buysse D','Dinges DF','Gangwisch J','Grandner MA','Kushida C','Malhotra RK','Martin JL','Patel SR','Quan SF','Tasali E']::text[], 2015, '26039963', '10.5665/sleep.4716', 'https://pubmed.ncbi.nlm.nih.gov/26039963/', 'Sleep', 6, 'expert_opinion', 'consensus_statement', 'en', 'watson-2015-pmid26039963', 'tier_source=pubtype; locator PASS None'),
('Noninvasive High-Intensity Focused Electromagnetic Therapy in Women With Urinary Incontinence: A Systematic Review and Meta-Analysis.', array['Leonardo K','Rahardjo HE','Afriansyah A']::text[], 2025, '39760417', '10.1002/nau.25658', 'https://pubmed.ncbi.nlm.nih.gov/39760417/', 'Neurourology and urodynamics', 1, 'meta_analysis', 'systematic_review_and_meta_analysis', 'en', 'leonardo-2025-pmid39760417', 'tier_source=pubtype; locator PASS '),
('The Role of Weight Management in the Treatment of Adult Obstructive Sleep Apnea. An Official American Thoracic Society Clinical Practice Guideline.', array['Hudgel DW','Patel SR','Ahasic AM','Bartlett SJ','Bessesen DH','Coaker MA','Fiander PM','Grunstein RR','Gurubhagavatula I','Kapur VK','Lettieri CJ','Naughton MT','Owens RL','Pepin JL','Tuomilehto H','Wilson KC']::text[], 2018, '30215551', '10.1164/rccm.201807-1326st', 'https://pubmed.ncbi.nlm.nih.gov/30215551/', 'American journal of respiratory and critical care medicine', 3, 'clinical_guideline', 'clinical_practice_guideline', 'en', 'hudgel-2018-pmid30215551', 'tier_source=pubtype; locator PASS ');

-- binds (page slug, pmid, purpose)
insert into w39p_bind values
('nocturia-sleep-apnea','14573376','supporting_evidence'),
('services/emsella-hifem-osa','14573376','supporting_evidence'),
('nocturia-sleep-apnea','17973220','supporting_evidence'),
('nocturia-sleep-apnea','26620900','supporting_evidence'),
('nocturia-sleep-apnea','39640007','supporting_evidence'),
('services/emsella-hifem-osa','39640007','supporting_evidence'),
('nocturia-sleep-apnea','40909763','supporting_evidence'),
('services/emsella-hifem-osa','40909763','supporting_evidence'),
('sleepwalking-sleep-talking','27832078','supporting_evidence'),
('sleepwalking-sleep-talking','12509590','supporting_evidence'),
('sleepwalking-sleep-talking','20598633','supporting_evidence'),
('sleepwalking-sleep-talking','42811568','supporting_evidence'),
('sleepwalking-sleep-talking','34186416','supporting_evidence'),
('sleepwalking-sleep-talking','32535329','supporting_evidence'),
('services/nightlase-laser-snoring','35867153','supporting_evidence'),
('services/nightlase-laser-snoring','30762193','supporting_evidence'),
('services/nightlase-laser-snoring','37579131','supporting_evidence'),
('services/nightlase-laser-snoring','36714903','supporting_evidence'),
('services/nightlase-laser-snoring','40566115','supporting_evidence'),
('night-sweats-sleep-apnea','23674447','supporting_evidence'),
('night-sweats-sleep-apnea','12019054','supporting_evidence'),
('night-sweats-sleep-apnea','23136329','supporting_evidence'),
('night-sweats-sleep-apnea','35706374','supporting_evidence'),
('night-sweats-sleep-apnea','42030838','supporting_evidence'),
('night-sweats-sleep-apnea','34535209','supporting_evidence'),
('leg-twitching-sleep-restless-legs','39324694','guideline_reference'),
('leg-twitching-sleep-restless-legs','25023924','supporting_evidence'),
('leg-twitching-sleep-restless-legs','21795081','supporting_evidence'),
('leg-twitching-sleep-restless-legs','41061431','supporting_evidence'),
('services/emsculpt-neo-muscle-sleep-wellness','34001694','supporting_evidence'),
('services/emsculpt-neo-muscle-sleep-wellness','35259147','supporting_evidence'),
('services/emsculpt-neo-muscle-sleep-wellness','11122588','supporting_evidence'),
('services/exion-rf-osa','11122588','supporting_evidence'),
('services/emsculpt-neo-muscle-sleep-wellness','31918559','supporting_evidence'),
('services/exion-rf-osa','31918559','supporting_evidence'),
('services/exion-rf-osa','22273428','supporting_evidence'),
('shortness-of-breath-dyspnea-dyspnea-causes','22336677','guideline_reference'),
('shortness-of-breath-dyspnea-dyspnea-causes','27581828','supporting_evidence'),
('shortness-of-breath-dyspnea-dyspnea-causes','10377201','supporting_evidence'),
('excessive-daytime-sleepiness','1798888','supporting_evidence'),
('excessive-daytime-sleepiness','20465027','supporting_evidence'),
('excessive-daytime-sleepiness','30736887','guideline_reference'),
('excessive-daytime-sleepiness','26039963','supporting_evidence'),
('services/emsella-hifem-osa','39760417','supporting_evidence'),
('services/exion-rf-osa','30215551','guideline_reference'),
('weight-loss-snoring-sleep-apnea','30215551','guideline_reference');

-- 1 · new citations (skip any pmid/doi already in the pool)
insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
                                  citation_type, study_type, language_code, is_thai_specific, brand_scope, verification_status,
                                  last_verified_at, load_from, load_source, maintenance_log)
select c.slug, c.title, c.authors, c.yr, c.pmid, c.doi, c.url, c.journal, c.tier, c.ctype, c.stype, c.lang, false, array['*'], 'verified',
       now(), 'vitalsleep-clinic', 'vitalsleep-clinic:citation intake 2026-10-31 (PubMed+Crossref round-trip by WP session)', c.note
  from w39p_cite c
 where not exists (select 1 from public.seo_citations x where x.pubmed_pmid = c.pmid or (c.doi is not null and lower(x.doi) = c.doi)); -- 38 rows

-- 2 · pool row reused by a second brand
update public.seo_citations
   set brand_scope = array_append(brand_scope, 'vitalsleep-clinic'), updated_at = now()
 where pubmed_pmid = '40566115' and not (brand_scope @> array['*'] or brand_scope @> array['vitalsleep-clinic']); -- 1 row

-- 3 · reserve the upcoming pages (citations bind by FK; sleep-cycle has no citations yet, reserved for its target only)
create temp table w39p_plan (slug text, kw text) on commit drop;
insert into w39p_plan values
('excessive-daytime-sleepiness','ง่วงนอนตลอดเวลา'),
('sleep-cycle-sleep-schedule','ตาราง นอน'); -- brand session 2026-10-31: 6,600/mo; sleep cycle / rem sleep คือ / วงจรการนอน = semantics (~11-10)

insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::'||w.kw), w.kw, 'VitalSleep Clinic', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai',
       'Informational', 'Added 2026-10-31 W39p reserved target for planned page (brand session); no volume inferred.'
  from w39p_plan w
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'VitalSleep Clinic' and kw_norm(k.keyword) = kw_norm(w.kw))
on conflict (fingerprint) do nothing; -- 2 rows

insert into public.seo_website_page_master (page_fingerprint, brand_id, brand_name, slug, canonical_url, status, page_type, page_language,
                                            target_keyword_fp, viability_assessment, reconciliation_notes)
select 'vsc-wp-' || left(md5(w.slug), 8), 'vitalsleep-clinic', 'VitalSleep Clinic', w.slug,
       'https://www.vitalsleepclinic.com/' || w.slug || '/', 'Planned', 'knowledge_article', 'th',
       lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::'||w.kw),
       jsonb_build_object('kw_rule_version','1.0','keyword_source','brand_session','decided_by','w39p-migration','decided_at','2026-10-31'),
       'W39p 2026-10-31: reserved (Planned) by brand session; set Live when published'
  from w39p_plan w
 where not exists (select 1 from public.seo_website_page_master p where p.brand_id = 'vitalsleep-clinic' and p.slug = w.slug); -- 2 rows

update public.seo_x_ads_keywords_contextual_master
   set keyword_use_as = 'target_keyword'
 where fingerprint in (select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::'||kw) from w39p_plan)
   and keyword_use_as is distinct from 'excluded'; -- 2 rows

-- 4 · bindings
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, b.purpose, 'references', 'active'
  from w39p_bind b
  join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
  join public.seo_citations c on c.pubmed_pmid = b.pmid
on conflict (page_fp, citation_fp, citation_purpose) do nothing; -- 46 rows

-- 5 · assert
do $$
declare n_cite int; n_bind int;
begin
  select count(*) into n_cite from w39p_cite w join public.seo_citations c on c.pubmed_pmid = w.pmid and c.verification_status = 'verified';
  if n_cite <> 38 then raise exception 'W39p: expected 38 verified citations, got %', n_cite; end if;
  select count(*) into n_bind from w39p_bind b
    join public.seo_website_page_master p on p.brand_id = 'vitalsleep-clinic' and p.slug = b.slug
    join public.seo_citations c on c.pubmed_pmid = b.pmid
    join public.seo_page_citations pc on pc.page_fp = p.page_fingerprint and pc.citation_fp = c.fingerprint and pc.citation_purpose = b.purpose;
  if n_bind <> 46 then raise exception 'W39p: expected 46 bindings, got %', n_bind; end if;
end $$;

commit;
