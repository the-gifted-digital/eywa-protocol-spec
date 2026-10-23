-- W3.7b · keyword/page entity review (queues C + D) (DRAFT, not applied) · 2026-10-23
-- C = keyword text equals a live entity name/alias X but keyword primary_entity_fp is another entity Y.
-- D = live page target keyword entity differs from page primary_entity_fp.
-- Decisions: tmp/w37/w37b_decisions.csv (145 rows). Only relink / relink_keyword / relink_page / fix_alias are applied here.
-- human / keep / keep_both / resolved rows are NOT touched.
-- Every UPDATE is guarded on fingerprint AND the old value; the final DO block aborts the whole run if any guard missed.
-- Reasons live in the why column of each VALUES row; statement comments sit after the trailing semicolon and carry no commas.
-- Rollback net: public.bak_w37b_20261023 (src + pk + to_jsonb row).

begin;

create temp table _w37b_kw (fp text primary key, old_fp text not null, new_fp text not null, why text) on commit drop; -- keyword relinks
insert into _w37b_kw (fp, old_fp, new_fp, why) values
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::ceramic implant', 'dental-implant', 'ceramic-implant', 'C Keyword names Ceramic Implant exactly; Dental Implant is the parent'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันเหล็ก vs จัดฟันใส', 'metal-braces', 'aligner-vs-braces', 'C Comparison query = Clear Aligner vs Metal Braces concept'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::เด็กฟันหัก', 'tooth-fracture', 'pediatric-dental-trauma', 'C Child dental trauma; Tooth Fracture is broader'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::ตัดเหงือก', 'laser-gingivectomy', 'gingivectomy', 'C Generic gingivectomy; laser variant is a child'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::ถุงน้ำในขากรรไกร', 'jaw-cyst-surgery', 'jaw-cyst', 'C Keyword names the condition Jaw Cyst; surgery is the treatment'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::ทันตแพทย์จัดฟัน', 'orthodontic-treatment', 'orthodontist', 'C Searcher wants an orthodontist (also page orthodontist-directory entity)'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::นอนกัดฟัน', 'bruxism', 'sleep-bruxism', 'C Grinding while asleep = Sleep Bruxism (child of Bruxism)'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::ป้องกันฟันผุ', 'dental-plaque', 'preventive-dentistry', 'C Caries prevention = Preventive Dentistry not Dental Plaque'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันปลอมหลวม', 'denture-relining', 'ill-fitting-denture', 'C Searcher has the ill-fitting denture condition; relining is one treatment'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันสึก', 'tooth-erosion', 'tooth-wear', 'C Tooth wear umbrella; erosion is a subtype'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::รักษาโรคเหงือก', 'periodontitis', 'periodontal-treatment', 'C Treatment intent (also page periodontitis-treatment entity)'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::รักษาเหงือก', 'gingiva', 'periodontal-treatment', 'C Treatment intent not anatomy (also page periodontal-gum-treatment entity)'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::โรคเหงือก', 'periodontitis', 'periodontal-disease', 'C Gum disease umbrella incl. gingivitis; Periodontitis is a child'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::เลเซอร์ตัดเหงือก', 'dental-laser', 'laser-gingivectomy', 'C Laser gum cutting = Laser Gingivectomy procedure not the device'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::อุดฟัน', 'composite-filling', 'dental-filling', 'C Generic filling query = umbrella Dental Filling (also page dental-filling-restoration entity)'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::composite veneer', 'dental-veneer', 'composite-veneer', 'C Exact subtype Composite Veneer'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::digital dentistry', 'digital-implant-planning', 'digital-planning', 'C Digital Treatment Planning closer than implant-only planning'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::flap surgery', 'periodontitis', 'periodontal-surgery', 'C Procedure not the condition'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::guided implant surgery', 'surgical-guide', 'guided-implant', 'C Exact procedure; surgical guide is the device'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::gum graft', 'soft-tissue-management', 'gum-graft', 'C Exact match Gum Graft'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::invisalign', 'thermoformed-aligner', 'invisalign', 'C Brand name exact; Thermoformed Aligner is the parent'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::invisalign vs braces', 'thermoformed-aligner', 'aligner-vs-braces', 'C Comparison query = Clear Aligner vs Metal Braces concept'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::lingual braces', 'orthodontic-treatment', 'lingual-braces', 'C Exact match Lingual Braces'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::periodontal surgery', 'periodontitis', 'periodontal-surgery', 'C Procedure not the condition'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::piezoelectric surgery', 'laser-dentistry', 'piezosurgery', 'C Piezo device not laser'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::scaling root planing', 'scaling-polishing', 'deep-scaling', 'C SRP is deep scaling not routine polishing'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::smile design', 'digital-smile-design', 'smile-design', 'C Generic smile design; DSD is the digital method'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::smile makeover', 'digital-smile-design', 'smile-makeover', 'C Exact match Smile Makeover; DSD is a planning tool'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::soft tissue graft', 'soft-tissue-management', 'gum-graft', 'C Gum Graft synonym; brand-scoped soft tissue management is broader'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::soft tissue laser', 'laser-dentistry', 'dental-laser', 'C Keyword names the device'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::zoom whitening', 'teeth-whitening', 'zoom-whitening', 'C Exact match Zoom Whitening'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ขากรรไกรมีเสียงคลิก', 'tmj-disorder', 'tmj-clicking', 'C Clicking symptom; TMD is the parent condition'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ครอบฟันบนรากเทียม', 'dental-crown', 'implant-crown', 'C Exact match Implant-Supported Crown'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ค่าทำฟัน', 'smilescape-dental-clinic', 'fee-transparency', 'C Cost concept; brand not named (also page dental-costs-and-coverage entity)'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::เคลือบฟลูออไรด์เด็ก', 'fluoride-treatment', 'pediatric-fluoride', 'C Exact match Pediatric Fluoride'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::เคลือบหลุมร่องฟันเด็ก', 'dental-sealant', 'pediatric-sealant', 'C Exact match Pediatric Sealant'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันด้านใน', 'orthodontic-treatment', 'lingual-braces', 'C Exact match Lingual Braces'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันเด็ก', 'early-orthodontic-intervention', 'pediatric-orthodontics', 'C Generic child orthodontics; early intervention is a child'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันผู้ใหญ่', 'orthodontic-treatment', 'adult-orthodontics', 'C Exact match Adult Orthodontics'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันเหล็ก', 'orthodontic-treatment', 'metal-braces', 'C Exact match Metal Braces'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::เด็กกลัวหมอฟัน', 'behavior-management', 'dental-anxiety-child', 'C Child dental anxiety condition; behavior management is the response'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ตรวจฟัน', 'scaling-polishing', 'dental-checkup', 'C Checkup not scaling'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ตรวจสุขภาพช่องปาก', 'smilescape-dental-clinic', 'dental-checkup', 'C Checkup; brand entity only when named'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ถอนฟันน้ำนม', 'tooth-extraction', 'baby-tooth-extraction', 'C Exact match (also page primary-tooth-extraction entity)'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ทันตกรรมประดิษฐ์', 'dental-crown', 'prosthodontics', 'C Prosthodontics specialty not a crown'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ทันตแพทย์เด็ก', 'pediatric-dentistry', 'pediatric-dentist', 'C Searcher wants a pediatric dentist'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ทันตแพทย์ทั่วไป', 'smilescape-dental-clinic', 'general-dentist', 'C Searcher wants a general dentist; brand not named'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::นอนกัดฟัน', 'bruxism', 'sleep-bruxism', 'C Grinding while asleep = Sleep Bruxism (child of Bruxism)'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ปวดฟัน', 'dental-caries', 'toothache', 'C Toothache symptom; caries is one cause'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ผ่าตัดเหงือก', 'periodontitis', 'periodontal-surgery', 'C Procedure not the condition (also page gum-surgery entity)'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันน้ำนม', 'pediatric-dentistry', 'primary-tooth', 'C Baby tooth anatomy'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันน้ำนมผุ', 'pediatric-dentistry', 'primary-tooth-cavity', 'C Exact match Primary Tooth Cavity'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันปลอม', 'removable-denture', 'denture', 'C Generic denture = umbrella entity'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันปลอมบนรากเทียม', 'overdenture', 'implant-denture', 'C Exact match Implant-Supported Denture'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันปลอมหลวม', 'all-on-4', 'ill-fitting-denture', 'C Condition Ill-Fitting Denture; All-on-4 is an upsell treatment'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันโยก', 'periodontitis', 'loose-tooth', 'C Loose tooth symptom; periodontitis is one cause'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันสึก', 'tooth-fracture', 'tooth-wear', 'C Tooth wear not fracture'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันหายหลายซี่', 'missing-tooth', 'multiple-missing-teeth', 'C Exact match Multiple Missing Teeth'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันเหลือง', 'teeth-whitening', 'tooth-discoloration', 'C Discoloration condition; whitening is the treatment'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ยิ้มเห็นเหงือก', 'gum-contouring', 'gummy-smile', 'C Condition Gummy Smile; contouring is one treatment'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::รักษาโรคเหงือก', 'periodontitis', 'periodontal-treatment', 'C Treatment intent (also page periodontics entity)'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::โรคเหงือก', 'periodontitis', 'periodontal-disease', 'C Gum disease umbrella incl. gingivitis; Periodontitis is a child'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::วีเนียร์คอมโพสิต', 'dental-veneer', 'composite-veneer', 'C Exact subtype Composite Veneer'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ศัลยกรรมช่องปาก', 'tooth-extraction', 'omfs', 'C Specialty query not extraction'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ส่วนประกอบรากฟันเทียม', 'dental-implant', 'dental-implant-components', 'C Exact match Dental Implant Components'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::สะพานฟัน', 'dental-crown', 'dental-bridge', 'C A bridge is not a crown'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::หมอฟันเด็ก', 'pediatric-dentistry', 'pediatric-dentist', 'C Searcher wants a pediatric dentist'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ออกแบบรอยยิ้ม', 'digital-smile-design', 'smile-design', 'C Generic smile design; DSD is the digital method'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::อ้าปากไม่ขึ้น', 'tmj-disorder', 'jaw-lock', 'C Trismus symptom; TMD is one cause'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::เอกซเรย์ฟัน', 'cbct-scan', 'dental-xray', 'C Generic dental x-ray not CBCT'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::3d tmj analysis', 'tmj-assessment', 'tmj-assessment-3d', 'C Exact match 3D TMJ Analysis'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::hrv ต่ำ', 'mbm-hrv', 'hrv', 'C Low HRV = the concept not the assessment service'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::pncl medicine', 'pncl-institute', 'pncl-medicine', 'C Keyword names PNCL Medicine exactly'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::เคลือบฟลูออไรด์', 'remineralization', 'fluoride-treatment', 'C Exact match Fluoride Treatment'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::เคลือบหลุมร่องฟัน', 'preventive-dentistry', 'dental-sealant', 'C Exact match Dental Sealant'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::ดมยาสลบทำฟัน', 'ambulatory-anesthesia', 'ga-dentistry', 'C Exact match General Anesthesia Dentistry'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::เด็กหายใจทางปาก', 'pediatric-airway', 'pediatric-mouth-breathing', 'C Exact match Pediatric Mouth Breathing'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::ทางเดินหายใจแคบ', 'airway-assessment-3d', 'osa-airway-narrowing', 'C Condition not the assessment'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::บูรณะฟันทั้งปาก', 'dental-crown', 'full-mouth-rehab', 'C Full-mouth rehab not a single crown'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::ฟันปลอมทั้งปาก', 'denture', 'complete-denture', 'C Exact match Complete Denture'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::ริ้วรอยก่อนวัย', 'structural-facial-aging', 'premature-wrinkles', 'C Exact match premature wrinkles'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::ออกแบบรอยยิ้ม', 'digital-smile-design', 'smile-design', 'C Generic smile design; DSD is the digital method'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::all on 4 อัตราความสำเร็จ', 'dental-implant', 'all-on-4', 'D Keyword names All-on-4'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::อุดฟันอมัลกัม', 'composite-filling', 'amalgam-filling', 'D Amalgam keyword was linked to composite filling'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันแบบไหนดี', 'orthodontic-treatment', 'aligner-vs-braces', 'D Which-braces query = comparison concept'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::digital smile design', 'smile-design', 'digital-smile-design', 'D Keyword names DSD'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::จัดฟันน้ำนม', 'primary-tooth', 'pediatric-orthodontics', 'D Orthodontics for kids not tooth anatomy'),
  ('deezy dental::🇹🇭 th – thailand::🇹🇭 th – thai::ปัญหาหลังใส่รากฟันเทียม', 'dental-implant', 'peri-implantitis-treatment', 'D Post-implant problems = peri-implantitis page entity'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::รากฟันเทียม นนทบุรี', 'smilescape-rattanathibet', 'dental-implant', 'D Branch/brand not named; implant intent'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ราคาทำฟัน', 'smilescape-dental-clinic', 'fee-transparency', 'D Cost concept; brand not named'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::รักษาโรคเหงือก ราคา', 'periodontitis', 'periodontal-treatment', 'D Treatment cost query; price modifier does not change entity'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ปรับผิวรากเทียม', 'resective-peri-implantitis-surgery', 'implantoplasty', 'D Implant surface smoothing = Implantoplasty'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ทีมทันตแพทย์ smilescape', 'dr-woraphat-jarangkul', 'smilescape-dental-clinic', 'D Keyword names SmileScape not the doctor'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::รากเทียม คืออะไร', 'implant-faq', 'dental-implant', 'D What-is-implant query = Dental Implant'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::หายใจทางปาก หน้าเปลี่ยน', 'mouth-breathing', 'adenoid-face', 'D Facial-change keyword = adenoid face'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::กระดูก เหงือก ปูด', 'torus-removal', 'torus-mandibularis-palatinus', 'D Bump description = torus condition'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::เคลือบฟลูออไรด์ ราคา', 'remineralization', 'fluoride-treatment', 'D Fluoride price query = Fluoride Treatment'),
  ('vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::เคลือบหลุมร่องฟัน คืออะไร', 'preventive-dentistry', 'dental-sealant', 'D What-is-sealant query = Dental Sealant'); -- 98 keyword rows (C relink + D relink_keyword not already covered by C)

create temp table _w37b_page (fp text primary key, old_fp text not null, new_fp text not null, why text) on commit drop; -- page relinks
insert into _w37b_page (fp, old_fp, new_fp, why) values
  ('deezy-3.7.9', 'orthodontic-treatment', 'metal-braces', 'D metal-braces-guide: page carried umbrella Orthodontic Treatment entity'),
  ('smilescape-3.10', 'clear-aligner', 'orthodontic-treatment', 'D orthodontics: pillar carried Clear Aligner entity'),
  ('vth-9.10', 'periodontal-disease', 'scaling-polishing', 'D scaling-near-me: local scaling landing carried Periodontal Disease entity'); -- 3 page rows

create temp table _w37b_alias (fp text primary key, old_aliases text not null, alias_rm text not null, why text) on commit drop; -- alias removals
insert into _w37b_alias (fp, old_aliases, alias_rm, why) values
  ('missing-tooth', 'ฟันหาย, tooth loss, ฟันหลุด, Tooth Loss, สูญเสียฟัน, missing tooth, tooth missing', 'ฟันหลุด', 'C ฟันหลุด = avulsion not missing tooth'),
  ('traumatic-tooth-loss', 'ฟันหักจากอุบัติเหตุ, tooth fracture trauma, avulsed tooth', 'ฟันหักจากอุบัติเหตุ', 'C accident fracture is not tooth loss'),
  ('surgical-extraction', 'ผ่าฟันคุดซับซ้อน, surgical removal, ผ่าตัดถอนฟัน', 'ผ่าฟันคุดซับซ้อน', 'C wisdom-tooth phrase off generic surgical extraction'),
  ('pediatric-sedation', 'ลูกกลัวหมอฟัน, Sedation Dentistry สำหรับเด็ก', 'ลูกกลัวหมอฟัน', 'C child-fear phrase is not sedation'),
  ('brain-fog-oral', 'สมองหมอก, สมองล้า, cognitive haze, mental fog', 'สมองล้า', 'C generic brain-fog term off the oral-origin variant'); -- 5 entity rows

create table public.bak_w37b_20261023 as
select 'seo_x_ads_keywords_contextual_master'::text as src, k.fingerprint as pk, to_jsonb(k) as row_data, now() as backed_up_at
  from public.seo_x_ads_keywords_contextual_master k join _w37b_kw v on v.fp = k.fingerprint
union all
select 'seo_website_page_master', p.page_fingerprint, to_jsonb(p), now()
  from public.seo_website_page_master p join _w37b_page v on v.fp = p.page_fingerprint
union all
select 'seo_entity_graph', g.entity_fingerprint, to_jsonb(g), now()
  from public.seo_entity_graph g join _w37b_alias v on v.fp = g.entity_fingerprint; -- expect 98 + 3 + 5 = 106 rows
alter table public.bak_w37b_20261023 enable row level security; -- same as earlier bak tables

update public.seo_x_ads_keywords_contextual_master k
   set primary_entity_fp = v.new_fp, updated_at = now()
  from _w37b_kw v
 where k.fingerprint = v.fp and k.primary_entity_fp = v.old_fp; -- expect 98

update public.seo_website_page_master p
   set primary_entity_fp = v.new_fp, updated_at = now()
  from _w37b_page v
 where p.page_fingerprint = v.fp and p.primary_entity_fp = v.old_fp and p.status not in ('Merged','Dropped'); -- expect 3

update public.seo_entity_graph g
   set aliases = nullif(array_to_string(array_remove(array(select trim(a) from unnest(string_to_array(g.aliases, ',')) a where trim(a) <> ''), v.alias_rm), ', '), ''),
       updated_at = now()
  from _w37b_alias v
 where g.entity_fingerprint = v.fp and g.aliases = v.old_aliases; -- expect 5 and aliases stay a plain comma list

do $$
declare n_bak int; n_kw int; n_pg int; n_al int; n_live int;
begin
  select count(*) into n_bak from public.bak_w37b_20261023;
  select count(*) into n_kw from public.seo_x_ads_keywords_contextual_master k join _w37b_kw v on v.fp = k.fingerprint and k.primary_entity_fp = v.new_fp;
  select count(*) into n_pg from public.seo_website_page_master p join _w37b_page v on v.fp = p.page_fingerprint and p.primary_entity_fp = v.new_fp;
  select count(*) into n_al from public.seo_entity_graph g join _w37b_alias v on v.fp = g.entity_fingerprint
   where not (seo_kw_norm(v.alias_rm) = any (select seo_kw_norm(n) from unnest(seo_entity_name_list(g.entity_name, g.aliases)) n));
  select count(*) into n_live from (select new_fp from _w37b_kw union select new_fp from _w37b_page) t
    join public.seo_entity_graph g on g.entity_fingerprint = t.new_fp and lower(coalesce(g.entity_lifecycle,'')) not in ('merged','dropped');
  if n_bak <> 106 then raise exception 'W3.7b abort: backup rows % <> 106', n_bak; end if;
  if n_kw <> 98 then raise exception 'W3.7b abort: keywords relinked % <> 98', n_kw; end if;
  if n_pg <> 3 then raise exception 'W3.7b abort: pages relinked % <> 3', n_pg; end if;
  if n_al <> 5 then raise exception 'W3.7b abort: aliases removed % <> 5', n_al; end if;
  if n_live <> (select count(*) from (select new_fp from _w37b_kw union select new_fp from _w37b_page) t) then raise exception 'W3.7b abort: a target entity is not live'; end if;
end $$; -- all-or-nothing

commit;
