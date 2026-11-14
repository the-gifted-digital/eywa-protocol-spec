-- 2026-11-14 · VTH rubric phase 2d — link plan for the two pages created in 2c (operator approved 2026-11-14)
-- Mirrors existing patterns: genetic-testing (procedure_pillar hub under precision-diagnostics) and
-- orthodontic-elastics (knowledge leaf under orthodontic-treatment).
--   breadcrumb p8/p9 · section_nav p7 · contextual primary_hub p7 · contextual cluster_spoke p5–6
-- Inbound rows from Live pages are planned; the site renders them only once the target is Live.

create temp table _l(fr text, tt text, typ text, role text, prio smallint, anchor text, variant text, sect text) on commit drop;
insert into _l values
  -- mouth-biomapping hub: breadcrumbs out
  ('mouth-biomapping','home','breadcrumb','primary_hub',9,'VTH BioDent — หน้าแรก','branded','breadcrumb'),
  ('mouth-biomapping','precision-diagnostics','breadcrumb','cluster_spoke',8,'ตรวจวินิจฉัยแม่นยำ เครื่องมือประเมินสุขภาพช่องปาก','partial','breadcrumb'),
  -- hub -> its five component services
  ('mouth-biomapping','hrv-assessment','navigational','cluster_spoke',7,'Mouth BioMapping® HRV ประเมินระบบประสาทอัตโนมัติ','partial','section_nav'),
  ('mouth-biomapping','mbm-occlusal-mapping','navigational','cluster_spoke',7,'MBM Occlusal Mapping วิเคราะห์แรงสบฟันดิจิทัล','partial','section_nav'),
  ('mouth-biomapping','bruxism-evaluation','navigational','cluster_spoke',7,'MBM ตรวจนอนกัดฟัน ด้วย EMG และการประเมินคลินิก','partial','section_nav'),
  ('mouth-biomapping','mbm-inflammation-panel','navigational','cluster_spoke',7,'MBM Inflammation Panel ตรวจ hs-CRP และ IL-6 บอกอะไร','partial','section_nav'),
  ('mouth-biomapping','mbm-sleep-breathing-screening','navigational','cluster_spoke',7,'MBM Sleep Breathing Screening คัดกรองการหายใจ','partial','section_nav'),
  -- hub -> booking + support pages
  ('mouth-biomapping','book-mouth-biomapping','contextual','cluster_spoke',6,'จองตรวจ Mouth BioMapping® นัดหมายล่วงหน้าได้ทุกสาขา','partial','body'),
  ('mouth-biomapping','mouth-biomapping-faq','contextual','cluster_spoke',5,'คำถามที่พบบ่อย Mouth BioMapping — จำเป็นไหม บ่อยแค่ไหน','partial','body_related'),
  ('mouth-biomapping','mouth-biomapping-vs-dental-checkup','contextual','cluster_spoke',5,'Mouth BioMapping® ต่างจากตรวจฟันทั่วไปอย่างไร','partial','body_related'),
  -- inbound to the hub
  ('precision-diagnostics','mouth-biomapping','navigational','cluster_spoke',7,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','section_nav'),
  ('hrv-assessment','mouth-biomapping','breadcrumb','cluster_spoke',8,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','breadcrumb'),
  ('mbm-occlusal-mapping','mouth-biomapping','breadcrumb','cluster_spoke',8,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','breadcrumb'),
  ('bruxism-evaluation','mouth-biomapping','breadcrumb','cluster_spoke',8,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','breadcrumb'),
  ('mbm-inflammation-panel','mouth-biomapping','breadcrumb','cluster_spoke',8,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','breadcrumb'),
  ('mbm-sleep-breathing-screening','mouth-biomapping','breadcrumb','cluster_spoke',8,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','breadcrumb'),
  ('mouth-biomapping-faq','mouth-biomapping','contextual','primary_hub',7,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','body'),
  ('mouth-biomapping-guide','mouth-biomapping','contextual','primary_hub',7,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','body'),
  ('mouth-biomapping-vs-dental-checkup','mouth-biomapping','contextual','primary_hub',7,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','body'),
  ('mouth-biomapping-case-study','mouth-biomapping','contextual','primary_hub',7,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','body'),
  ('book-mouth-biomapping','mouth-biomapping','contextual','primary_hub',7,'Mouth BioMapping คืออะไร และตรวจอะไรบ้าง','partial','body'),
  -- braces-tooth-extraction (leaf)
  ('braces-tooth-extraction','orthodontic-treatment','contextual','primary_hub',7,'จัดฟัน ภาพรวมการรักษาเพื่อการสบฟันที่ดีต่อสุขภาพ',null,'body'),
  ('orthodontic-treatment','braces-tooth-extraction','contextual','cluster_spoke',6,'จัดฟันต้องถอนฟันไหม ถอนกี่ซี่ และเมื่อไหร่ไม่ต้องถอน',null,'body'),
  ('braces-types-guide','braces-tooth-extraction','contextual','cluster_spoke',5,'จัดฟันต้องถอนฟันไหม ถอนกี่ซี่ และเมื่อไหร่ไม่ต้องถอน',null,'body'),
  ('orthodontics-faq','braces-tooth-extraction','contextual','cluster_spoke',6,'จัดฟันต้องถอนฟันไหม ถอนกี่ซี่ และเมื่อไหร่ไม่ต้องถอน',null,'body');

create temp table _r on commit drop as
select l.*, f.page_fingerprint from_fp, t.page_fingerprint to_fp
from _l l
join public.seo_website_page_master f on f.brand_id = 'vth-biodent' and f.slug = l.fr and f.status in ('Live','Planned')
join public.seo_website_page_master t on t.brand_id = 'vth-biodent' and t.slug = l.tt and t.status in ('Live','Planned');

do $$
begin
  if (select count(*) from _r) <> (select count(*) from _l) then
    raise exception 'a slug did not resolve to an active VTH page';
  end if;
  if exists (select 1 from _r r join public.seo_page_internal_links x
             on x.from_page_fp = r.from_fp and x.to_page_fp = r.to_fp and x.link_type = r.typ
             and x.status in ('planned','live')) then
    raise exception 'an active link of the same type already exists';
  end if;
end $$;

insert into public.seo_page_internal_links (
  fingerprint, fingerprint_display_name, from_page_fp, to_page_fp, link_type, link_role, link_priority,
  anchor_text, anchor_variant_type, section_context, status, planned, implemented, first_planned_at)
select fp, right(fp, 6) || '::' || typ, from_fp, to_fp, typ, role, prio, anchor, variant, sect,
       'planned', true, false, now()
from (select r.*, 'pil_' || upper(substr(md5(r.from_fp || '>' || r.to_fp || '>' || r.typ || '>phase2d'), 1, 16)) fp from _r r) s;
