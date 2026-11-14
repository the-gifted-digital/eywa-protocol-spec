-- 2026-11-14 · VTH rubric phase 2b (operator approved 2026-11-14)
-- reports/technical-audit/2026-11-14-phase2-proposal.md §1–§2 in eywa-vth-biodent
-- 1) 19 support pages: target -> role-pattern keyword (loaded by deployment/supabase-load/58)
-- 2) S7: each old target goes where the proposal sends it, in the same transaction
--    (trigger fn_enforce_page_keyword_no_reuse forbids a keyword held by two pages):
--      semantic of a ranking page · target of general-dentistry · kept as semantic of the
--      same page (x-guide งานวิจัย; laser family parked until 6.1.11) · or released (dest null)
--    Released keywords stay in the master; no page holds them until the operator decides.

create temp table _p2b(slug text, new_kw text, dest text, as_target boolean) on commit drop;
insert into _p2b values
  ('bruxism-guide',                  'คู่มือนอนกัดฟัน',                    'bruxism',                     false),
  ('bruxism-faq',                    'คำถามที่พบบ่อย นอนกัดฟัน',           'bruxism',                     false),
  ('bruxism-evidence',               'งานวิจัยนอนกัดฟัน',                  'teeth-grinding-vs-clenching', false),
  ('tmj-guide',                      'คู่มือ tmj',                         'tmj-disorder',                false),
  ('tmj-evidence',                   'งานวิจัย tmj',                       'tmj-non-surgical',            false),
  ('tmj-faq',                        'คำถามที่พบบ่อย tmj',                 'jaw-clicking-sound',          false),
  ('dental-veneer-faq',              'คำถามที่พบบ่อย วีเนียร์',            'no-prep-vs-prep-veneers',     false),
  ('dental-implant-faq',             'คำถามที่พบบ่อย รากฟันเทียม',         'dental-implant',              false),
  ('braces-facial-change-evidence',  'งานวิจัย จัดฟันกับรูปหน้า',          'braces-and-facial-change',    false),
  ('pediatric-dentistry-faq',        'คำถามที่พบบ่อย ทันตกรรมเด็ก',        'pediatric-dentistry',         false),
  ('dental-implant-evidence',        'งานวิจัยรากฟันเทียม',                'dental-implant-evidence',     false),
  ('laser-dentistry-guide',          'คู่มือทันตกรรมเลเซอร์',              'laser-dentistry-guide',       false),
  ('general-dentistry-faq',          'คำถามที่พบบ่อย ทำฟัน',               'general-dentistry',           true),
  ('gum-disease-faq',                'คำถามที่พบบ่อย โรคเหงือก',           null,                          false),
  ('sleep-apnea-faq',                'คำถามที่พบบ่อย นอนกรน',              null,                          false),
  ('orthodontics-faq',               'คำถามที่พบบ่อย จัดฟัน',              null,                          false),
  ('mouth-biomapping-guide',         'คู่มือ mouth biomapping',            null,                          false),
  ('genomics-evidence',              'งานวิจัยจีโนมช่องปาก',               null,                          false),
  ('regenerative-medicine-evidence', 'งานวิจัยเวชศาสตร์ฟื้นฟูทางทันตกรรม', null,                          false);

alter table _p2b add column old_fp text, add column new_fp text;
update _p2b t set old_fp = p.target_keyword_fp,
  new_fp = regexp_replace(p.target_keyword_fp, '::[^:]*$', '') || '::' || t.new_kw
from public.seo_website_page_master p where p.brand_id = 'vth-biodent' and p.slug = t.slug;

do $$
begin
  if (select count(*) from _p2b t join public.seo_x_ads_keywords_contextual_master m on m.fingerprint = t.new_fp) <> 19 then
    raise exception 'a role-pattern keyword is missing from the master (run 57 first)';
  end if;
  if (select count(*) from _p2b t join public.seo_website_page_master d
        on d.brand_id = 'vth-biodent' and d.slug = t.dest and d.status in ('Live','Planned')
      where t.dest is not null) <> 13 then
    raise exception 'a destination page is missing or not active';
  end if;
  if exists (select 1 from public.seo_website_page_master where brand_id = 'vth-biodent'
             and slug = 'general-dentistry' and target_keyword_fp is not null) then
    raise exception 'general-dentistry already has a target';
  end if;
end $$;

-- 1) support pages take their role keyword; old target released from the row
update public.seo_website_page_master p
set target_keyword_fp = t.new_fp, updated_at = now(),
    reconciliation_notes = concat_ws(' | ', nullif(p.reconciliation_notes, ''),
      '2026-11-14 PHASE2B: target "' || split_part(t.old_fp,'::',4) || '" -> role keyword "' || t.new_kw || '" (S2); old target '
      || case when t.dest is null then 'released, owner pending operator decision'
              when t.dest = t.slug then 'kept here as semantic'
              when t.as_target then 'became target of ' || t.dest
              else 'moved to semantic of ' || t.dest end)
from _p2b t where p.brand_id = 'vth-biodent' and p.slug = t.slug;

-- 2a) general-dentistry: old FAQ target becomes its target
update public.seo_website_page_master d
set target_keyword_fp = t.old_fp, updated_at = now(),
    reconciliation_notes = concat_ws(' | ', nullif(d.reconciliation_notes, ''),
      '2026-11-14 PHASE2B: target "' || split_part(t.old_fp,'::',4) || '" from support page ' || t.slug || ' (S7)')
from _p2b t where d.brand_id = 'vth-biodent' and d.slug = t.dest and t.as_target;

-- 2b) everything else with a destination: append as semantic (several sources can share one dest)
update public.seo_website_page_master d
set semantic_keywords_fps = coalesce(d.semantic_keywords_fps, '{}') || s.fps, updated_at = now(),
    reconciliation_notes = concat_ws(' | ', nullif(d.reconciliation_notes, ''), s.note)
from (
  select dest, array_agg(old_fp order by slug) fps,
         '2026-11-14 PHASE2B: + semantic ' || string_agg('"' || split_part(old_fp,'::',4) || '" from ' || slug, ', ' order by slug) || ' (S7)' note
  from _p2b where dest is not null and not as_target group by dest
) s
where d.brand_id = 'vth-biodent' and d.slug = s.dest;

select t.slug, split_part(p.target_keyword_fp,'::',4) now_target, t.dest,
  (select split_part(d.target_keyword_fp,'::',4) from public.seo_website_page_master d where d.brand_id='vth-biodent' and d.slug=t.dest) dest_target,
  (select t.old_fp = any(d.semantic_keywords_fps) from public.seo_website_page_master d where d.brand_id='vth-biodent' and d.slug=t.dest) in_dest_sem
from _p2b t join public.seo_website_page_master p on p.brand_id='vth-biodent' and p.slug=t.slug order by t.dest nulls last, t.slug;

-- 3) seo_title / meta_description of the 11 Live support pages, synced to the role-led YAML
update seo_website_page_master set seo_title='คู่มือนอนกัดฟันฉบับสมบูรณ์ — สาเหตุ การรักษา เมื่อไหร่ต้องตรวจ', meta_description='คู่มือนอนกัดฟัน: ต่างจากกัดเค้นฟันตอนตื่นอย่างไร เฝือกสบฟันช่วยอะไรได้และช่วยอะไรไม่ได้ และหลักฐานเรื่องความเชื่อมโยงกับภาวะหยุดหายใจขณะหลับบอกอะไร', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='bruxism-guide';
update seo_website_page_master set seo_title='คู่มือ TMJ ข้อต่อขากรรไกรฉบับสมบูรณ์ — สาเหตุถึงการฟื้นฟู', meta_description='คู่มือ TMJ ข้อต่อขากรรไกร ส่วนใหญ่เป็น TMD ที่ดูแลได้ แต่บางอาการต้องรีบพบแพทย์ คู่มือนี้รวมสาเหตุ การวินิจฉัย ประเภท และการรักษาอย่างมีหลักฐาน', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='tmj-guide';
update seo_website_page_master set seo_title='คู่มือหยุดหายใจขณะหลับฉบับสมบูรณ์ — ทันตกรรมและกายภาพบำบัด', meta_description='คู่มือหยุดหายใจขณะหลับ ฉบับทันตกรรมและกายภาพบำบัด อ่านว่าเครื่องมือในช่องปากทำงานอย่างไร ใช้ได้กับใคร ต้องติดตามอะไร และข้อจำกัดอยู่ตรงไหน', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='sleep-apnea-guide';
update seo_website_page_master set seo_title='งานวิจัยนอนกัดฟัน — เรื่องไหนเชื่อได้ เรื่องไหนยังไม่แน่', meta_description='งานวิจัยนอนกัดฟัน: เรื่องที่คุณอ่านเจอทั่วไป อันไหนมีหลักฐานหนักแน่น อันไหนมีแต่ไม่มาก และอันไหนที่ผลออกมาว่าไม่จริง เรียงให้ตามระดับความมั่นใจ', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='bruxism-evidence';
update seo_website_page_master set seo_title='งานวิจัย TMJ — การรักษาแต่ละแบบ หลักฐานแน่นแค่ไหน', meta_description='งานวิจัย TMJ เรียงการรักษาแต่ละแบบตามความหนักของหลักฐาน ไม่ใช่ตามความนิยม รวมทั้งวิธีที่ผลออกมาไม่ต่างจากยาหลอก และเรื่องที่พูดกันบ่อยแต่วัดแล้วไม่พบ', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='tmj-evidence';
update seo_website_page_master set seo_title='คำถามที่พบบ่อย นอนกัดฟัน — เฝือกสบฟัน เด็กกัดฟัน นอนกรน', meta_description='คำถามที่พบบ่อย นอนกัดฟัน ตั้งแต่ต้องใส่เฝือกสบฟันตลอดไปไหม เด็กกัดฟันอันตรายหรือไม่ ไปจนถึงความเกี่ยวข้องกับการนอนกรน ตอบทีละข้อจากคลินิก', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='bruxism-faq';
update seo_website_page_master set seo_title='คำถามที่พบบ่อย วีเนียร์ — เรื่องที่ควรรู้ก่อนทำ', meta_description='คำถามที่พบบ่อย วีเนียร์ ตอบเรื่อง No-Prep กับ Minimal-Prep ความเหมาะสม การยึดติด แรงกัด การดูแล และสิ่งที่ควรถามก่อนตัดสินใจ', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='dental-veneer-faq';
update seo_website_page_master set seo_title='คำถามที่พบบ่อย โรคเหงือก — เลือดออก เหงือกร่น ฟันโยก', meta_description='คำถามที่พบบ่อย โรคเหงือก สิ่งที่โรคเหงือกทำลายคือกระดูกที่ยึดฟัน ไม่ใช่ตัวฟัน รวมเรื่องเลือดออก กลิ่นปาก น้ำยาบ้วนปาก โพรไบโอติก และรอบการมาตรวจ', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='gum-disease-faq';
update seo_website_page_master set seo_title='คำถามที่พบบ่อย Mouth BioMapping — จำเป็นไหม บ่อยแค่ไหน', meta_description='คำถามที่พบบ่อย Mouth BioMapping ทั้งความจำเป็น ความถี่ที่ควรตรวจซ้ำ และสิ่งที่ทำให้ขอบเขตกับค่าใช้จ่ายต่างกันในแต่ละคน ตอบทีละข้อ อ่านข้อไหนก่อนก็ได้', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='mouth-biomapping-faq';
update seo_website_page_master set seo_title='คำถามที่พบบ่อย นอนกรนและหยุดหายใจขณะหลับ — ตรวจอย่างไร', meta_description='คำถามที่พบบ่อย นอนกรนและหยุดหายใจขณะหลับ ตรวจการนอนหลับทำอย่างไร ค่าที่ได้อ่านยังไง และการอยู่กับเครื่องมือในช่องปากระยะยาวเป็นแบบไหน ตอบทีละข้อ', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='sleep-apnea-faq';
update seo_website_page_master set seo_title='คำถามที่พบบ่อย TMJ ข้อต่อขากรรไกร — เสียงดัง ปวดเรื้อรัง', meta_description='คำถามที่พบบ่อย TMJ ข้อต่อขากรรไกร เสียงดังต้องรักษาไหม ปวดเรื้อรังทำอะไรได้บ้าง แนวทางสากลแนะนำและคัดค้านอะไร พร้อมระบุว่าแต่ละข้อมาจากหลักฐานชั้นไหน', updated_at=now(), reconciliation_notes=concat_ws(' | ', nullif(reconciliation_notes,''), '2026-11-14 PHASE2B: seo_title/meta synced to role-led YAML (S2)') where brand_id='vth-biodent' and slug='tmj-faq';
