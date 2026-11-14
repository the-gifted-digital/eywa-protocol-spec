-- Rubric phase 8 (C1) · VTH BioDent · 2026-11-15
-- 11 new pool rows (PubMed esummary round-trip; abstracts read for PICO + tier; Review-only pubtypes
-- confirmed SR by PRISMA/database search in abstract) + 33 page bindings on 26 Live pages below the
-- C1 minimum + 2 pool backfills + sleep-airway exemption note (append-only).
begin;
create temp table p8_cite (pmid text, doi text, title text, authors text[], yr smallint, journal text, tier smallint, ctype text, stype text, kf text[], note text) on commit drop;
create temp table p8_bind (slug text, pmid text) on commit drop;
insert into p8_cite values
($q$41821098$q$,$q$10.1186/s13005-026-00609-x$q$,$q$Diagnostic and prognostic value of (cone-beam) computed tomography in dental sleep medicine for obstructive sleep apnea: a systematic review$q$,array[$q$Sambale J$q$,$q$Hass J$q$,$q$Koehler U$q$,$q$Waldmann S$q$,$q$Korbmacher-Steiner HM$q$]::text[],2026,$q$Head & face medicine$q$,1,$q$systematic_review$q$,$q$systematic_review$q$,array[$q$Of 11 mostly high-risk-of-bias studies, only a smaller retropalatal minimum cross-sectional area was fairly consistent in OSA; total airway volume and other measures did not reliably diagnose, grade OSA or predict treatment response, so routine CBCT/CT for OSA screening is not justified.$q$]::text[],$q$tier_source=abstract: PRISMA, PROSPERO CRD42024556837, 5 databases, 392 records, 11 studies included (7 diagnostic, 4 therapeutic); no pooling$q$),
($q$28379334$q$,$q$10.1093/ejo/cjx005$q$,$q$Impact of adenotonsillectomy on the dentofacial development of obstructed children: a systematic review and meta-analysis$q$,array[$q$Becking BE$q$,$q$Verweij JP$q$,$q$Kalf-Scholte SM$q$,$q$Valkenburg C$q$,$q$Bakker EWP$q$,$q$van Merkesteyn JPR$q$]::text[],2017,$q$European journal of orthodontics$q$,1,$q$systematic_review$q$,$q$systematic_review_and_meta_analysis$q$,array[$q$After surgery, incisor inclination and mandibular growth pattern normalised toward a more horizontal direction, maxillary arch width increased and lateral crossbite became less frequent; overjet, overbite, SNB and gonial angle findings were inconsistent. High risk of bias and heterogeneity limit conclusions.$q$]::text[],$q$tier_source=abstract: systematic search of databases + grey literature, 1196 papers, 16 controlled prospective cohort studies (461 children), duplicate extraction, Cochrane RoB, descriptive + quantitative synthesis$q$),
($q$39952790$q$,$q$10.1111/joor.13949$q$,$q$Mandibular Oral Tori Predict the Presence but Not the Severity of Obstructive Sleep Apnoea. A Systematic Review and Meta-Analysis of the Literature$q$,array[$q$Yong CW$q$,$q$Quah B$q$,$q$Kong NLS$q$,$q$Colpani JT$q$,$q$Wong RCW$q$]::text[],2025,$q$Journal of oral rehabilitation$q$,1,$q$meta_analysis$q$,$q$systematic_review_and_meta_analysis$q$,array[$q$Pooled RR for OSA with mandibular torus 1.9 (95% CI 0.9–4.1, not statistically significant); AHI difference 1.6 (−5.3 to 8.6). Torus did not impede mandibular advancement device or soft-tissue surgery outcomes. Note the title overstates the association; the honest usable finding is that torus does not block oral-appliance therapy.$q$]::text[],$q$tier_source=abstract: PRISMA, PubMed/Embase/Cochrane to 15 Jul 2024, 11 studies (1372 patients), pooled RR and mean difference$q$),
($q$32513091$q$,$q$10.1177/0194599820931087$q$,$q$Impact of Alcohol Consumption on Snoring and Sleep Apnea: A Systematic Review and Meta-analysis$q$,array[$q$Burgos-Sanchez C$q$,$q$Jones NN$q$,$q$Avillion M$q$,$q$Gibson SJ$q$,$q$Patel JA$q$,$q$Neighbors J$q$,$q$Zaghi S$q$,$q$Camacho M$q$]::text[],2020,$q$Otolaryngology--head and neck surgery : official journal of American Academy of Otolaryngology-Head and Neck Surgery$q$,1,$q$meta_analysis$q$,$q$systematic_review_and_meta_analysis$q$,array[$q$Alcohol increased AHI by 3.98 events/h (95% CI 3.27–4.68) and lowered minimum oxygen saturation by 2.72%; associated with worse snoring severity and altered sleep architecture. Small total sample (279).$q$]::text[],$q$tier_source=abstract: PROSPERO-registered, PRISMA, 5 databases, 1266 screened, 13 PSG studies (279 patients) pooled$q$),
($q$21938435$q$,$q$10.1007/s11325-011-0596-8$q$,$q$Gender difference in snoring and how it changes with age: systematic review and meta-regression$q$,array[$q$Chan CH$q$,$q$Wong BM$q$,$q$Tang JL$q$,$q$Ng DK$q$]::text[],2012,$q$Sleep & breathing = Schlaf & Atmung$q$,1,$q$meta_analysis$q$,$q$systematic_review_and_meta_analysis$q$,array[$q$Men snore more than women, pooled OR 1.89 (95% CI 1.75–2.03); age significantly modifies the sex difference. High heterogeneity; cross-sectional data. PubMed pubdate 2012 (online 2011).$q$]::text[],$q$tier_source=abstract: 1593 citations, 63 cross-sectional general-population studies (~215,000 people) pooled, meta-regression on age. Pools observational prevalence data only.$q$),
($q$38392225$q$,$q$10.3390/dj12020021$q$,$q$Mouth Breathing and Its Impact on Atypical Swallowing: A Systematic Review and Meta-Analysis$q$,array[$q$Gómez-González C$q$,$q$González-Mosquera A$q$,$q$Alkhraisat MH$q$,$q$Anitua E$q$]::text[],2024,$q$Dentistry journal$q$,1,$q$meta_analysis$q$,$q$systematic_review_and_meta_analysis$q$,array[$q$Atypical swallowing (tongue thrust) was more frequent in mouth breathers, pooled RR 3.70 (95% CI 2.06-6.66) from 4 observational studies. Diagnostic criteria for both conditions varied widely between studies, limiting certainty.$q$]::text[],$q$tier_source=abstract: PRISMA 2020, PROSPERO CRD42022339527, 4 databases, 12 studies included, 4 pooled (RevMan) — SR+MA despite PubMed pubtype 'Review'$q$),
($q$30152076$q$,$q$10.1111/idj.12421$q$,$q$Are bristle stiffness and bristle end-shape related to adverse effects on soft tissues during toothbrushing? A systematic review$q$,array[$q$Ranzan N$q$,$q$Muniz FWMG$q$,$q$Rösing CK$q$]::text[],2019,$q$International dental journal$q$,1,$q$systematic_review$q$,$q$systematic_review$q$,array[$q$13 controlled trials: hard-bristle manual toothbrushes produced more gingival lesions than medium- and soft-bristle brushes; soft/extra-soft brushes tend to be safer, and lesions were similar for tapered vs end-rounded bristles. Only 4 trials had adverse effects as primary outcome; no meta-analysis.$q$]::text[],$q$tier_source=abstract: systematic search of Scopus/EMBASE/PubMed + grey literature, two independent reviewers, Cochrane RoB tool, 13 controlled trials synthesised (qualitative/meta-ethnography, no pooling)$q$),
($q$33691678$q$,$q$10.1186/s12903-021-01458-7$q$,$q$Effects of mouth breathing on facial skeletal development in children: a systematic review and meta-analysis$q$,array[$q$Zhao Z$q$,$q$Zheng L$q$,$q$Huang X$q$,$q$Li C$q$,$q$Liu J$q$,$q$Hu Y$q$]::text[],2021,$q$BMC oral health$q$,1,$q$meta_analysis$q$,$q$systematic_review_and_meta_analysis$q$,array[$q$10 studies: mouth-breathing children had lower SNA (MD −1.63°) and SNB (−1.96°), steeper mandibular plane (PP-MP +4.92°, SNGoGn +4.10°), more proclined upper incisors and narrower airway. Observational data — association, not causation.$q$]::text[],$q$tier_source=abstract: search of 6 databases, ROBINS-I + GRADE, PROSPERO CRD42019129198, 10 studies pooled (mean differences)$q$),
($q$42026531$q$,$q$10.1186/s12903-026-08349-9$q$,$q$Dental arch dimension and palatal morphology in children and adolescents with mouth breathing: a systematic review and meta-analysis$q$,array[$q$Lekvijittada K$q$,$q$Uengkajornkul P$q$,$q$Changsiripun C$q$]::text[],2026,$q$BMC oral health$q$,1,$q$meta_analysis$q$,$q$systematic_review_and_meta_analysis$q$,array[$q$13 studies: mouth-breathing children had narrower upper intercanine and intermolar widths and narrower lower intermolar width, deeper posterior palate, and more posterior crossbite (p<0.00001); palatal width and anterior palatal depth did not differ. Thai authors (Chulalongkorn).$q$]::text[],$q$tier_source=abstract: search of MEDLINE/Embase/Cochrane/LILACS/Scopus to Dec 2025, two independent reviewers, 13 studies pooled in RevMan$q$),
($q$40739849$q$,$q$10.1111/ipd.70022$q$,$q$Dental Caries and Periodontal Outcomes in Mouth-Breathing Children and Adolescents: A Systematic Review$q$,array[$q$Kimura ACRS$q$,$q$de Arruda JAA$q$,$q$Drumond VZ$q$,$q$Martins-Júnior PA$q$,$q$Mesquita RA$q$,$q$Abreu LG$q$]::text[],2026,$q$International journal of paediatric dentistry$q$,1,$q$systematic_review$q$,$q$systematic_review$q$,array[$q$11 cross-sectional studies: mouth breathers showed more gingival bleeding, plaque and gingival alterations; caries association limited to initial and advanced (ICDAS 5–6) lesions. Evidence is cross-sectional only.$q$]::text[],$q$tier_source=abstract: PROSPERO CRD42024536891, 5 databases, PECOS stated, Newcastle-Ottawa RoB, 11 cross-sectional studies (no pooling)$q$),
($q$41473620$q$,$q$10.7759/cureus.98084$q$,$q$Digital Smile Design and Patient-Centered Outcomes in Esthetic Restorative Dentistry: A Systematic Review$q$,array[$q$Alwabel LK$q$,$q$Alabduljabar WM$q$,$q$Alawfi LK$q$,$q$Al Johani NK$q$,$q$Alharbi LE$q$,$q$Kharif MA$q$,$q$Albahrani FD$q$,$q$Alarjani MB$q$,$q$Alzahrani MS$q$,$q$Alshammari AA$q$,$q$Alashjai A$q$,$q$Alanaz L Sr$q$]::text[],2025,$q$Cureus$q$,1,$q$systematic_review$q$,$q$systematic_review$q$,array[$q$Across 7 studies DSD was associated with higher patient satisfaction, treatment acceptance and better communication than conventional approaches. Limitations: heterogeneous designs and outcome measures, small samples; Cureus is a lower-tier journal — weaker T1, flag for reviewer.$q$]::text[],$q$tier_source=pubtype only 'Review' but abstract: PRISMA, PubMed/ScienceDirect/Google Scholar/Cochrane searched to Aug 2025, 7 studies (RCTs, observational, qualitative); narrative synthesis, no pooling$q$);
insert into p8_bind values
($q$impacted-tooth$q$,$q$33680330$q$),
($q$pediatric-snoring$q$,$q$23692173$q$),
($q$volumetric-airway-analysis$q$,$q$41821098$q$),
($q$adenoid-face$q$,$q$28379334$q$),
($q$oral-torus$q$,$q$39952790$q$),
($q$snoring$q$,$q$32513091$q$),
($q$snoring$q$,$q$21938435$q$),
($q$pediatric-malocclusion$q$,$q$38548628$q$),
($q$pediatric-malocclusion$q$,$q$37832339$q$),
($q$tonsil-adenoid$q$,$q$23692173$q$),
($q$gum-recession$q$,$q$39988303$q$),
($q$pediatric-bruxism$q$,$q$38098259$q$),
($q$pediatric-bruxism$q$,$q$36629590$q$),
($q$tongue-thrust$q$,$q$38392225$q$),
($q$dental-local-anesthesia$q$,$q$34391560$q$),
($q$pediatric-dental-trauma$q$,$q$30222244$q$),
($q$sleep-airway$q$,$q$29497502$q$),
($q$sleep-airway$q$,$q$24581717$q$),
($q$sleep-airway$q$,$q$28162150$q$),
($q$gingival-trauma$q$,$q$30152076$q$),
($q$mouth-breathing$q$,$q$40397877$q$),
($q$teeth-grinding-vs-clenching$q$,$q$40716827$q$),
($q$tongue-tie$q$,$q$35689515$q$),
($q$mouth-breathing-in-children$q$,$q$33691678$q$),
($q$mouth-breathing-in-children$q$,$q$42026531$q$),
($q$mouth-breathing-in-children$q$,$q$40739849$q$),
($q$dental-abscess$q$,$q$31668170$q$),
($q$self-ligating-vs-traditional-braces$q$,$q$23299650$q$),
($q$dark-gums$q$,$q$31143000$q$),
($q$bruxism-evidence$q$,$q$34955330$q$),
($q$short-teeth$q$,$q$37251724$q$),
($q$smile-simulation$q$,$q$41473620$q$),
($q$pericoronitis$q$,$q$33680330$q$);
insert into public.seo_citations (citation_slug, title, authors, publication_year, pubmed_pmid, doi, url, journal_name, citation_tier,
  citation_type, study_type, key_findings, language_code, is_thai_specific, brand_scope, verification_status, last_verified_at,
  load_from, load_source, maintenance_log)
select 'pmid-'||c.pmid, c.title, c.authors, c.yr, c.pmid, c.doi, 'https://pubmed.ncbi.nlm.nih.gov/'||c.pmid||'/', c.journal, c.tier,
       c.ctype, c.stype, c.kf, 'en', false, array['*'], 'verified', now(),
       'vth-biodent', 'vth-biodent:rubric phase 8 C1 gap-fill 2026-11-15 (PubMed esummary round-trip, abstract read)', c.note
  from p8_cite c
 where not exists (select 1 from public.seo_citations x where x.pubmed_pmid = c.pmid or (c.doi is not null and lower(x.doi) = c.doi));
insert into public.seo_page_citations (page_fp, citation_fp, citation_purpose, section_context, status)
select p.page_fingerprint, c.fingerprint, 'supporting_evidence', 'references', 'active'
  from p8_bind b
  join public.seo_website_page_master p on p.brand_id = 'vth-biodent' and trim(both '/' from p.slug) = b.slug
  join public.seo_citations c on c.pubmed_pmid = b.pmid
on conflict (page_fp, citation_fp, citation_purpose) do update set status = 'active' where seo_page_citations.status <> 'active';
-- pool backfills from the PubMed record
update public.seo_citations set publication_year = 2024, journal_name = $q$The Journal of clinical pediatric dentistry$q$,
  authors = coalesce(authors, array[$q$Sadoun C$q$,$q$Templier L$q$,$q$Alloul L$q$,$q$Rossi C$q$,$q$Renovales ID$q$,$q$Sanchez IN$q$,$q$Sahagún PM$q$]::text[])
 where fingerprint = 'cite_B397016B55797A5B' and publication_year is null;
update public.seo_citations set key_findings = array[$q$10 small studies (213 patients): 2 showed improvement in AHI/oxygen desaturation, others showed no difference; authors flag potential serious harm incl. asphyxiation risk with nasal obstruction, and many studies excluded people with nasal obstruction.$q$]::text[]
 where fingerprint = 'cite_0A46102A4F0D426E' and key_findings is null;
-- sleep-airway carried a 2026-08-02 CITATION EXEMPTION; it now cites 3 refs (append-only log)
update public.seo_website_page_master
   set reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || '2026-11-15 rubric C1: CITATION EXEMPTION superseded — page now cites 3 refs (AASM 2017 guideline, Hou 2018 MA, Sedky 2014 MA); no-numbers hub style kept'
 where brand_id = 'vth-biodent' and trim(both '/' from slug) = 'sleep-airway';
do $$
declare n_cite int; n_bind int; n_slug int;
begin
  select count(*) into n_cite from p8_cite w join public.seo_citations c on c.pubmed_pmid = w.pmid and c.verification_status = 'verified';
  if n_cite <> 11 then raise exception 'p8: expected 11 verified citations, got %', n_cite; end if;
  select count(distinct b.slug) into n_slug from p8_bind b join public.seo_website_page_master p on p.brand_id='vth-biodent' and trim(both '/' from p.slug) = b.slug;
  if n_slug <> 26 then raise exception 'p8: expected 26 pages, got %', n_slug; end if;
  select count(*) into n_bind from p8_bind b
    join public.seo_website_page_master p on p.brand_id = 'vth-biodent' and trim(both '/' from p.slug) = b.slug
    join public.seo_citations c on c.pubmed_pmid = b.pmid
    join public.seo_page_citations pc on pc.page_fp = p.page_fingerprint and pc.citation_fp = c.fingerprint and pc.status = 'active';
  if n_bind < 33 then raise exception 'p8: expected >= 33 active bindings, got %', n_bind; end if;
end $$;
commit;
