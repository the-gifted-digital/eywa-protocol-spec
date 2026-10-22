-- W3.2c: lift the losers' extension-table lists onto the winners of the W3.1 merge (DR-078)
-- W3.1 carried only code columns when both rows had an extension row; the rest stayed in
-- bak_w31_20261022_ext. A reviewer agent compared each column (decisions: tmp/ext-merge-2026-10-22.json):
-- fill = winner empty, union = append loser items not already present, wrong items dropped,
-- no numbers carried. 7 of the 11 pairs change; adenoid-face, baby-tooth-extraction,
-- airway-assessment-3d and laser-dentistry had nothing correct to add.
-- Backup of the 7 winner rows as they are now: bak_w32c_20261022.

begin;

create table public.bak_w32c_20261022 as
  select 'seo_entity_condition' t, entity_fp, to_jsonb(x) row from seo_entity_condition x where entity_fp = 'dental-anxiety-adult'
  union all select 'seo_entity_devices', entity_fp, to_jsonb(x) from seo_entity_devices x where entity_fp in ('airflow-air-polishing', 'zirconia-material')
  union all select 'seo_entity_procedures', entity_fp, to_jsonb(x) from seo_entity_procedures x
    where entity_fp in ('dental-bonding', 'periodontal-surgery', 'root-canal-treatment', 'wisdom-tooth-extraction');
alter table public.bak_w32c_20261022 enable row level security;

-- dental-phobia -> dental-anxiety-adult
update public.seo_entity_condition set
    -- body_system (union): Added Behavioral Health; dropped 'Nervous System' (anxiety is psychological, not a nervous-system disease).
    body_system = array['oral_cavity', 'Behavioral Health']::text[],
    -- common_misconceptions (union): All three loser misconceptions apply to adult dental anxiety; none duplicate winner item.
    common_misconceptions = array['กลัวหมอฟันเป็นเรื่องอ่อนแอหรือน่าอาย (พบได้บ่อยและจัดการได้)', 'เข้าใจผิดว่าการกลัวหมอฟันเป็นเรื่องของเด็กเท่านั้น ผู้ใหญ่ไม่ควรกลัว ทั้งที่พบได้ทั่วไปในผู้ใหญ่เช่นกัน', 'คิดว่าการหลีกเลี่ยงไปหาหมอฟันจะทำให้ปัญหาหายไปเอง แต่จริง ๆ แล้วยิ่งปล่อยไว้โรคในช่องปากยิ่งลุกลามและรักษายากขึ้น', 'เข้าใจว่าต้องอดทนกับความกลัวไปเองโดยไม่มีทางรักษา ทั้งที่มีเทคนิคบำบัดและการจัดการทางการแพทย์ที่ได้ผล']::text[],
    -- diagnostic_methods (union): Added specific-phobia criteria assessment; MDAS/DAS and history-taking already covered.
    diagnostic_methods = array['แบบประเมิน Modified Dental Anxiety Scale (MDAS)', 'แบบประเมิน Corah Dental Anxiety Scale', 'การสัมภาษณ์ทางคลินิก', 'การประเมินร่วมกับเกณฑ์วินิจฉัยโรคกลัวเฉพาะ (specific phobia) ทางจิตเวช']::text[],
    -- early_warning_signs (union): Added anticipatory anxiety and refusing care despite pain; avoidance item already covered.
    early_warning_signs = array['เริ่มเลื่อนนัดหรือยกเลิกการรักษาซ้ำ ๆ', 'รู้สึกกังวลรุนแรงล่วงหน้าหลายวันก่อนถึงวันนัด', 'ปฏิเสธการรักษาแม้มีอาการปวดฟันหรือปัญหาช่องปากชัดเจน']::text[],
    -- prevention_strategies (union): Added relaxation/breathing and positive childhood visits; tell-show-do, CBT, communication, sedation already covered.
    prevention_strategies = array['สื่อสารกับทันตแพทย์และบอกความกลัวล่วงหน้า', 'ใช้เทคนิค tell-show-do', 'นัดสั้น ๆ และหยุดพักได้', 'ใช้ยาช่วยให้สงบ (sedation) เมื่อจำเป็น', 'บำบัดความคิดและพฤติกรรม (CBT) ในรายรุนแรง', 'เทคนิคการผ่อนคลายและฝึกการหายใจก่อนและระหว่างการรักษา', 'การพาไปพบทันตแพทย์ตั้งแต่วัยเด็กด้วยประสบการณ์เชิงบวกเพื่อลดความเสี่ยงสะสม']::text[],
    -- risk_factors (union): Added loss of control, female/younger, comorbid panic/phobias; past trauma and family history already covered.
    risk_factors = array['ประสบการณ์เจ็บปวดจากการทำฟันในอดีต', 'กลัวความเจ็บหรือกลัวเข็ม', 'โรควิตกกังวลทั่วไป', 'การเรียนรู้ความกลัวจากคนในครอบครัว', 'รู้สึกสูญเสียการควบคุมสถานการณ์ขณะถูกรักษา', 'เป็นเพศหญิงหรืออายุน้อย ซึ่งพบความชุกของอาการกลัวหมอฟันสูงกว่า', 'มีภาวะวิตกกังวลชนิดอื่น โรคตื่นตระหนก หรือโรคกลัวเฉพาะอย่างร่วมด้วย']::text[],
    -- symptoms (union): Added dizziness/faintness, breathlessness, crying/panic; palpitations, sweating, insomnia already covered.
    symptoms = array['กลัวหรือวิตกกังวลรุนแรงต่อการทำฟัน', 'เลื่อนหรือหลีกเลี่ยงการพบทันตแพทย์', 'ใจสั่น เหงื่อออก คลื่นไส้ เมื่อนึกถึงการทำฟัน', 'นอนไม่หลับก่อนวันนัดทำฟัน', 'วิงเวียนหรือหน้ามืดคล้ายจะเป็นลม', 'หายใจถี่หรือหายใจไม่อิ่ม', 'ร้องไห้ อาการตื่นตระหนก หรือรู้สึกไม่สบายใจอย่างรุนแรงเมื่อต้องรับการรักษา']::text[],
    load_source = concat_ws(' · ', load_source, 'W3.2 2026-10-22: lists/blank fields lifted from merged dental-phobia'),
    updated_at = now()
where entity_fp = 'dental-anxiety-adult';

-- gbt-airflow -> airflow-air-polishing
update public.seo_entity_devices set
    -- ce_mark (fill): Winner null; winner is the EMS Airflow system (aliases EMS/GBT/Prophylaxis Master), CE-marked.
    ce_mark = true,
    -- ce_mark_class (fill): Winner null; class IIa carried from loser for same EMS device.
    ce_mark_class = 'IIa',
    -- clinical_indications (union): Added ultrasonic calculus removal (system includes piezo scaler); stain/biofilm, peri-implant, GBT maintenance already covered.
    clinical_indications = array['ขจัดคราบจุลินทรีย์และคราบสีบนผิวฟัน / biofilm and extrinsic stain removal', 'ทำความสะอาดร่วมกับการรักษาปริทันต์และรอบรากเทียม / adjunct in periodontal and peri-implant maintenance', 'กำจัดหินปูนเหนือและใต้เหงือก พร้อมล้างร่องปริทันต์ด้วยหัวสเกลอัลตราโซนิก']::text[],
    -- contraindications (union): Added glycine allergy, reworded: loser wrongly named AIRFLOW PLUS (erythritol) as glycine. Sodium item duplicate.
    contraindications = array['ผู้ที่ต้องจำกัดโซเดียมเมื่อใช้ผงโซเดียมไบคาร์บอเนต / sodium-restricted diet with sodium bicarbonate powder', 'โรคระบบทางเดินหายใจที่ควบคุมไม่ได้ / uncontrolled respiratory disease', 'เยื่อบุช่องปากอักเสบหรือมีแผลเปิด / acute oral mucosal inflammation', 'ผิวรากฟันที่โผล่หรือวัสดุบูรณะเมื่อใช้ผงชนิดหยาบ / abrasive powder on exposed dentine or restorations', 'ผู้ที่แพ้ไกลซีน เมื่อใช้ผงขัดที่มีส่วนผสมไกลซีน / glycine allergy with glycine-based powder']::text[],
    -- fda_clearance (fill): Winner null; openFDA confirms K190124 = EMS AIRFLOW Prophylaxis Master/One, EMS, cleared 2019-10-20.
    fda_clearance = 'K190124',
    -- manufacturer (fill): Winner null; openFDA K190124 confirms EMS, Nyon.
    manufacturer = 'EMS Electro Medical Systems S.A. (Nyon, Switzerland)',
    -- model_number (fill): Winner null; Prophylaxis Master name matches FDA record; FT-229 code not independently verified.
    model_number = 'FT-229 (AIRFLOW Prophylaxis Master)',
    -- treatment_areas (union): Added tooth surfaces and implant surfaces; dropped pocket item with uncited '≤5 mm' depth limit.
    treatment_areas = array['maxilla', 'mandible', 'ผิวเคลือบฟัน (enamel) และผิวฟันทั่วไป', 'พื้นผิวรากฟันเทียมและซี่ฟันเทียมที่ยึดบนรากฟันเทียม']::text[],
    load_source = concat_ws(' · ', load_source, 'W3.2 2026-10-22: lists/blank fields lifted from merged gbt-airflow'),
    updated_at = now()
where entity_fp = 'airflow-air-polishing';

-- zirconia -> zirconia-material
update public.seo_entity_devices set
    -- contraindications (union): Added insufficient tooth structure and opposing-tooth wear from unpolished monolithic zirconia; both valid.
    contraindications = array['เลือกความโปร่งแสง/ความแข็งแรงไม่เหมาะกับตำแหน่ง / mismatched translucency-strength grade', 'เนื้อฟันเหลือน้อยเกินไป / insufficient tooth structure', 'ฟันคู่สบสึก (โมโนลิทิกที่ไม่ขัดเงา) / abrasive wear of opposing teeth if unpolished']::text[],
    load_source = concat_ws(' · ', load_source, 'W3.2 2026-10-22: lists/blank fields lifted from merged zirconia'),
    updated_at = now()
where entity_fp = 'zirconia-material';

-- cosmetic-bonding -> dental-bonding
update public.seo_entity_procedures set
    -- contraindications (union): Added fragment reattachment and repeated-repair history; pulp, caries, bruxism, extensive damage already covered.
    contraindications = array['มีภาวะฉุกเฉิน บาดเจ็บใบหน้า ฟันเคลื่อน/ราก หรือปัญหาโพรงประสาทฟัน — ต้องรักษาให้เรียบร้อยก่อนทำงานความสวยงาม', 'ฟันผุหรือเหงือกอักเสบที่ยังไม่ได้รักษา — ต้องรักษาให้เรียบร้อยก่อนทำบอนดิ้ง', 'สบฟันผิดปกติหรือนอนกัดฟันที่ยังไม่ได้จัดการ — วัสดุเสี่ยงบิ่นหรือหลุดสูงขึ้น ควรประเมินและป้องกันก่อน', 'โครงสร้างฟันเสียหายมาก รากแตก หรือปริทันต์รอบฟันไม่ดี — ต้องประเมินว่ายังเหมาะกับการบอนดิ้งหรือไม่ก่อนเริ่ม', 'สูบบุหรี่ ดื่มเครื่องดื่มติดสีเป็นประจำ ปากแห้ง หรือมีความเสี่ยงฟันผุสูง — วัสดุติดสี/หลุดเร็วขึ้น ควรแจ้งก่อนทำ', 'ปัญหาหลักอยู่ที่ตำแหน่งฟันมากกว่ารูปร่างหรือพื้นผิว — ควรได้รับการประเมินการจัดฟันก่อนเลือกวิธีนี้', 'มีชิ้นฟันที่เพิ่งแตกและยังเก็บไว้ได้ — แจ้งทันตแพทย์ก่อน การยึดชิ้นเดิมกลับอาจได้ผลดีและเก็บเนื้อฟันได้มากกว่า', 'เคยซ่อมหรือเปลี่ยนวัสดุจุดเดิมมาแล้วหลายครั้ง — งานที่ทำซ้ำมีความเสี่ยงล้มเหลวสูงกว่า ควรแจ้งประวัติก่อนทำ']::text[],
    load_source = concat_ws(' · ', load_source, 'W3.2 2026-10-22: lists/blank fields lifted from merged cosmetic-bonding'),
    updated_at = now()
where entity_fp = 'dental-bonding';

-- gum-surgery -> periodontal-surgery
update public.seo_entity_procedures set
    -- complications_common (union): Added delayed healing/wound dehiscence; other loser items duplicate winner wording.
    complications_common = '["ปวดและบวมหลังผ่าตัด", "เลือดออก", "เหงือกร่นและเสียวฟันหลังหาย", "การติดเชื้อของแผลผ่าตัด (พบไม่บ่อย)", "แผลหายช้าหรือขอบแผลแยก"]'::jsonb,
    -- contraindications (union): Added acute infection, no prior SRP/re-eval, endocarditis risk, MRONJ/radiation; smoking, bleeding, diabetes, plaque control already covered.
    contraindications = array['ผู้สูบบุหรี่จัด (ผลการหายของแผลลดลง)', 'ภาวะเลือดออกง่าย/ได้ยาต้านการแข็งตัวของเลือดที่ยังไม่ควบคุม', 'เบาหวานที่ควบคุมไม่ได้', 'การควบคุมคราบจุลินทรีย์ยังไม่ดีพอก่อนผ่าตัด', 'หญิงตั้งครรภ์ (เลื่อนหัตถการที่ไม่เร่งด่วน)', 'กำลังมีการติดเชื้อเฉียบพลันในบริเวณที่จะผ่าตัด เช่น บวมลามพร้อมไข้หรือมีหนอง — ไม่ควรทำ ต้องจัดการภาวะเฉียบพลันให้สงบก่อน', 'ยังไม่ได้ผ่านการขูดหินปูนและเกลารากฟันแล้วประเมินซ้ำ — ต้องทำขั้นก่อนหน้าให้ครบก่อน การผ่าตัดใช้เฉพาะตำแหน่งที่ยังมีร่องลึกหลังจากนั้น', 'มีความเสี่ยงสูงต่อการติดเชื้อที่ลิ้นหัวใจ เช่น เคยเป็นเยื่อบุหัวใจอักเสบหรือใส่ลิ้นหัวใจเทียม — แจ้งล่วงหน้า อาจต้องได้รับยาปฏิชีวนะป้องกันก่อนทำ', 'มีความเสี่ยงกระดูกขากรรไกรตาย จากยาต้านการสลายกระดูก ยาต้านการสร้างหลอดเลือด หรือเคยฉายรังสีศีรษะและลำคอ — ประเมินความเสี่ยงร่วมกับแพทย์ก่อนผ่าตัด']::text[],
    load_source = concat_ws(' · ', load_source, 'W3.2 2026-10-22: lists/blank fields lifted from merged gum-surgery'),
    updated_at = now()
where entity_fp = 'periodontal-surgery';

-- endodontic-treatment -> root-canal-treatment
update public.seo_entity_procedures set
    -- anesthesia_type (fill): Winner null; RCT is performed under local anesthesia.
    anesthesia_type = 'local',
    -- complications_common (fill): Winner empty array; all five are recognized RCT complications.
    complications_common = '["ปวดหลังทำหัตถการ (postoperative pain)", "อาการอักเสบเฉียบพลันหลังทำ (flare-up)", "เครื่องมือหักคาในคลองรากฟัน (instrument separation)", "คลองรากฟันทะลุ (root perforation)", "คลองรากฟันที่มองไม่พบ/รักษาไม่ครบ (missed canal)"]'::jsonb,
    -- contraindications (union): Added crown-root ratio and massive resorption; non-restorable, VRF, Grade III mobility already covered.
    contraindications = array['ฟันมีโครงสร้างเหลือน้อยเกินไปจนบูรณะกลับมาใช้งานไม่ได้ — ไม่ควรรักษาราก ควรพิจารณาทางเลือกอื่น เช่น การถอนฟัน', 'ฟันแตกร้าวแนวดิ่งลึกถึงราก (vertical root fracture) — ไม่ควรรักษาราก มักต้องพิจารณาการถอนฟัน', 'โรคปริทันต์รุนแรงจนฟันโยกมากและกระดูก/เอ็นยึดรองรับไม่เพียงพอ — ต้องประเมินและรักษาปริทันต์ก่อนตัดสินใจรักษาราก', 'มีโรคประจำตัว ใช้ยาบางชนิด มีประวัติแพ้ยา หรือตั้งครรภ์/ให้นมบุตร — แจ้งทันตแพทย์เพื่อประเมินก่อนวางแผนรักษาราก', 'อัตราส่วนตัวฟันต่อรากฟันไม่ดี (poor crown-root ratio)', 'มีพยาธิสภาพละลายรากฟัน/กระดูกรุนแรง (massive resorptive defect)']::text[],
    -- invasiveness_level (fill): Winner null; non-surgical RCT is minimally invasive in this vocabulary.
    invasiveness_level = 'minimally_invasive',
    -- procedure_type (fill): Winner null; RCT is therapeutic.
    procedure_type = 'therapeutic',
    load_source = concat_ws(' · ', load_source, 'W3.2 2026-10-22: lists/blank fields lifted from merged endodontic-treatment'),
    updated_at = now()
where entity_fp = 'root-canal-treatment';

-- wisdom-tooth-removal -> wisdom-tooth-extraction
update public.seo_entity_procedures set
    -- treats_conditions_fps (fill): Winner null; impacted-tooth exists (Mature) and is a valid indication.
    treats_conditions_fps = array['impacted-tooth']::text[],
    load_source = concat_ws(' · ', load_source, 'W3.2 2026-10-22: lists/blank fields lifted from merged wisdom-tooth-removal'),
    updated_at = now()
where entity_fp = 'wisdom-tooth-extraction';

-- JUDGEMENT CALL: root-canal-treatment says no anaesthesia and no follow-up; the merged row said
-- true for both, which is clinically right (local anaesthesia; review + final restoration).
-- Comment out to keep the current values.
update public.seo_entity_procedures
set anesthesia_required = true, requires_followup = true,
    load_source = concat_ws(' · ', load_source, 'W3.2 2026-10-22: anesthesia_required/requires_followup corrected to true'),
    updated_at = now()
where entity_fp = 'root-canal-treatment';

commit;
