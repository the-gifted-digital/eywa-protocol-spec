-- 2026-11-14 · VTH rubric phase 4 follow-up (operator approved 2026-11-14)
-- V2 (report narration) text that lives in the DB, not in YAML:
--   1. sleep-apnea-heart-disease: YAML title moved "งานวิจัย" -> "หลักฐาน" in phase 4; sync seo_title and
--      the 32 inbound anchors (L4 drift) to the rendered title.
--   2. three contraindication strings (rendered through entity-clinical.json) restated without
--      study narration / method jargon. Meaning unchanged.
-- Anchors to support:evidence pages keep their "งานวิจัย X" role phrase (S2/S3) — exempted from V2 in the rubric.

do $$
declare n int;
begin
  update public.seo_website_page_master
  set seo_title = 'Sleep Apnea โรคหัวใจ ความสัมพันธ์ที่หลักฐานยืนยันได้แค่ไหน', updated_at = now(),
      reconciliation_notes = concat_ws(' | ', nullif(reconciliation_notes, ''),
        '2026-11-14 PHASE4: seo_title synced to YAML (งานวิจัย -> หลักฐาน, rubric V2)')
  where brand_id = 'vth-biodent' and slug = 'sleep-apnea-heart-disease'
    and seo_title = 'Sleep Apnea โรคหัวใจ ความสัมพันธ์ที่งานวิจัยยืนยันได้แค่ไหน';
  get diagnostics n = row_count;
  if n <> 1 then raise exception 'seo_title row not found (%)', n; end if;

  update public.seo_page_internal_links
  set anchor_text = 'Sleep Apnea โรคหัวใจ ความสัมพันธ์ที่หลักฐานยืนยันได้แค่ไหน', updated_at = now()
  where to_page_fp = 'vth-6.2.3.2' and status in ('planned','live')
    and anchor_text = 'Sleep Apnea โรคหัวใจ ความสัมพันธ์ที่งานวิจัยยืนยันได้แค่ไหน';
  get diagnostics n = row_count;
  if n <> 32 then raise exception 'expected 32 anchor rows, got %', n; end if;

  update public.seo_entity_procedures
  set contraindications = array_replace(contraindications,
        'คาดหวังว่าเลือกระบบรัดในตัวแล้วจะเสร็จเร็วกว่าอย่างมีนัยสำคัญ — หลักฐานไม่รองรับ ต้องเข้าใจก่อนตัดสินใจเลือกระบบ',
        'คาดหวังว่าเลือกระบบรัดในตัวแล้วจะเสร็จเร็วกว่าอย่างชัดเจน — หลักฐานไม่รองรับ ต้องเข้าใจก่อนตัดสินใจเลือกระบบ'), updated_at = now()
  where entity_fp = 'self-ligating-braces';
  update public.seo_entity_procedures
  set contraindications = array_replace(contraindications,
        'ยังไม่ได้ขูดหินปูนและเกลารากฟันครบทุกตำแหน่ง — ต้องทำให้ครบก่อน งานวิจัยที่ได้ผลดีล้วนใช้เลเซอร์เสริมหลังการขูดหินปูน',
        'ยังไม่ได้ขูดหินปูนและเกลารากฟันครบทุกตำแหน่ง — ต้องทำให้ครบก่อน วิธีที่ติดอันดับต้น ๆ ล้วนใช้เลเซอร์เสริมหลังการขูดหินปูน'), updated_at = now()
  where entity_fp = 'laser-perio';
  update public.seo_entity_procedures
  set contraindications = array_replace(contraindications,
        'ตั้งครรภ์หรือให้นมบุตร — ควรเลื่อนไปก่อน เป็นหัตถการเพื่อความงามที่ไม่เร่งด่วน และงานวิจัยฟอกสีฟันไม่รับกลุ่มนี้เข้าศึกษา จึงไม่มีข้อมูลความปลอดภัย',
        'ตั้งครรภ์หรือให้นมบุตร — ควรเลื่อนไปก่อน เป็นหัตถการเพื่อความงามที่ไม่เร่งด่วน และยังไม่มีข้อมูลความปลอดภัยของการฟอกสีฟันในกลุ่มนี้'), updated_at = now()
  where entity_fp = 'touchwhite';

  if exists (select 1 from public.seo_entity_procedures, unnest(contraindications) c
             where entity_fp in ('self-ligating-braces','laser-perio','touchwhite')
               and c ~ 'งานวิจัย|นัยสำคัญ') then
    raise exception 'a contraindication string was not replaced';
  end if;
end $$;
