-- DR-086: citation_tier follows citation_type — enforced when a row is written, not only in CI.
--
-- Why: until now the rule lived in the COMMENT on citation_tier and in gate G5 (CI), and the table
-- itself only checked 1 ≤ tier ≤ 6. A brand that wrote rows straight into the shared pool without
-- running the gates could store any tier. On 2026-11-20 myobrace-center loaded 20 rows using a
-- guideline-first pyramid (guideline = 1, SR/MA = 2, cohort = 3 …); G5 checks the whole shared
-- pool, so every vth-biodent deploy failed (runs 454–456) while the brand that wrote the rows saw
-- nothing. The writer must be the one refused.
--
-- What: one function holds TIER_BY_TYPE (the same map as run-citation-qa-gates.py — keep in step);
-- a BEFORE trigger on seo_citations
--   · tier omitted (NULL) on a mapped type  → filled in from the type
--   · UPDATE that changes citation_type but leaves citation_tier as it was → tier follows the type
--   · any other mismatch                    → refused (23514) with the expected tier in the message
--   · unmapped types ('other', 'news_article') → tier left to the writer, as G5 does
-- Pre-check on 2026-11-20 after the myobrace fix: 0 mismatching rows in the pool.
--
-- Rollback:
--   drop trigger if exists trg_citation_tier_by_type on public.seo_citations;
--   drop function if exists public.fn_citation_tier_guard();
--   drop function if exists public.fn_citation_tier_for_type(text);

begin;

create or replace function public.fn_citation_tier_for_type(p_type text)
returns smallint
language sql
immutable
as $$
  select case p_type
    when 'systematic_review'    then 1
    when 'meta_analysis'        then 1
    when 'rct'                  then 2
    when 'clinical_guideline'   then 3
    when 'regulatory_document'  then 4
    when 'cohort_study'         then 5
    when 'case_control'         then 5
    when 'cross_sectional'      then 5
    when 'case_series'          then 5
    when 'textbook'             then 6
    when 'expert_opinion'       then 6
    when 'case_report'          then 6
    when 'editorial'            then 6
    when 'industry_publication' then 6
    when 'patient_resource'     then 6
    else null  -- 'other', 'news_article': no fixed tier
  end::smallint
$$;

comment on function public.fn_citation_tier_for_type(text) is
  'DR-086 · Bible §23.1 tier for a citation_type (NULL = no fixed tier). Same map as TIER_BY_TYPE in eywa-protocol-spec/scripts/citation-gates/run-citation-qa-gates.py — change both together.';

create or replace function public.fn_citation_tier_guard()
returns trigger
language plpgsql
as $$
declare
  expected smallint := public.fn_citation_tier_for_type(new.citation_type);
begin
  if expected is null then
    return new;
  end if;
  if new.citation_tier is null then
    new.citation_tier := expected;
  elsif tg_op = 'UPDATE'
        and new.citation_type is distinct from old.citation_type
        and new.citation_tier is not distinct from old.citation_tier then
    new.citation_tier := expected;  -- reclassified: the tier follows the type
  elsif new.citation_tier <> expected then
    raise exception 'citation % (%): citation_tier % does not match citation_type %, which is tier % (DR-086, Bible §23.1)',
      coalesce(new.fingerprint, '(new row)'), left(coalesce(new.title, ''), 60), new.citation_tier, new.citation_type, expected
      using errcode = 'check_violation',
            hint = 'Tier is set by citation_type: 1 SR/MA · 2 RCT · 3 guideline · 4 regulatory · 5 observational/case series · 6 textbook/expert opinion/case report/editorial/industry/patient resource. Omit citation_tier to have it filled in. If the type is wrong, fix the type (decide by what the study did — DR-063).';
  end if;
  return new;
end
$$;

drop trigger if exists trg_citation_tier_by_type on public.seo_citations;
create trigger trg_citation_tier_by_type
  before insert or update of citation_type, citation_tier on public.seo_citations
  for each row execute function public.fn_citation_tier_guard();

comment on column public.seo_citations.citation_tier is
$c$ระดับหลักฐาน 1–6 (1 = แข็งที่สุด) · ตั้งตาม `citation_type` — **บังคับตอนเขียนด้วย trigger `trg_citation_tier_by_type` (DR-086)**: ไม่ใส่ tier = เติมให้ · เปลี่ยน type โดยไม่แตะ tier = tier ตามให้ · ใส่ไม่ตรง = ถูกปฏิเสธ · gate G5 ใน CI ยังตรวจซ้ำ และต้องไม่ขัดกับ `study_type` (gate G14)

📕 ต้นทาง: Bible §23.1 · Citation_Pool_SOP §2 · DR-063 (conduct ชนะ) · DR-077 (เกณฑ์ 2026-10-22) · DR-086 (บังคับตอนเขียน)
implement: fn_citation_tier_for_type() ในฐานข้อมูล = TIER_BY_TYPE ใน eywa-protocol-spec/scripts/citation-gates/run-citation-qa-gates.py (แก้คู่กันเสมอ)

ตัดสินจากสิ่งที่งานวิจัยทำจริง — PubMed PublicationType + บทคัดย่อ · ห้ามตัดสินจากชื่อเรื่อง
แท็ก "Review" อย่างเดียวไม่ได้บอกอะไร: มี search strategy / PRISMA / pooling → SR/MA (T1) · ไม่มี → narrative (T6)
ห้ามใช้สเกลอื่น (เช่นพีระมิดที่ให้ guideline = 1) — สเกล EYWA ให้ SR/MA = 1 และ guideline = 3

  1 = systematic_review · meta_analysis
  2 = rct (randomized / controlled clinical trial)
  3 = clinical_guideline (สมาคมวิชาชีพ) · systematic_review_guideline ที่ไม่ได้ทำ SR เอง
  4 = regulatory_document · report ที่ออกโดยรัฐ/ผู้กำกับดูแล
  5 = cohort_study · case_control · cross_sectional · case_series · clinical_study / pilot_study ที่ไม่สุ่ม · genetic_association / mendelian_randomization
  6 = textbook · expert_opinion · narrative/scoping review · case_report · editorial · industry_publication · patient_resource · in_vitro
  ไม่ตายตัว = other · news_article (ผู้เขียนใส่เอง)

study_type = 'other' ห้ามเป็นค่าสุดท้ายของแถวที่มี PMID · ข้อมูล first-party ของคลินิก = citation_type other / T6
study_type ใช้ค่ามาตรฐาน (ดู STUDY_TYPE_SYNONYM) ไม่ใช่ข้อความอิสระ — รายละเอียดอย่าง n= หรือ retrospective เขียนใน key_findings
ข้อจำกัดของหลักฐาน (เช่น SR ที่รวมแต่งานในสัตว์) เขียนใน key_findings — ห้ามกด tier แทน
หลังเปลี่ยน tier ให้รัน compute-citation-authority.py$c$;

commit;
