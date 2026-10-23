-- W38 · bind target keywords to unbound Live pages (DRAFT, not applied) · 2026-10-23
-- Brands: the-face-by-vertex, tc-smile-dental, clearisma, vitalsleep-clinic.
-- Rules: Keyword_Assignment_SOP §10/§10.1, DR-076 (one intent = one URL, trg_page_keyword_no_reuse).
-- Source order per page: (a) the page's own GSC queries, last 90 days ('gsc'; 'gsc-sibling' = query seen
-- on a weaker/no-target sibling page), (b) a free registry keyword ('registry'), (c) DataForSEO
-- Google Ads search volume, TH/th, 2026-10-23 ('dfs').
-- Pages NOT bound here (no-target-needed / cannibal / keyword-research gap) are listed with reasons in
-- 2026-10-23_w38_target_keyword_binding_report.md.
-- No semantic keywords are written. primary_entity_fp / primary_entity_name are not touched.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

-- 0 · backup: every page row and every keyword row this migration can touch
create table public.bak_w38_20261023_target_bind as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id in ('the-face-by-vertex','tc-smile-dental','clearisma','vitalsleep-clinic')
   and p.status not in ('Merged','Dropped')
   and p.target_keyword_fp is null; -- 446 rows expected

create temp table w38_bind (brand_id text, slug text, keyword text, src text, intent text) on commit drop;

insert into w38_bind (brand_id, slug, keyword, src, intent) values
-- vitalsleep-clinic (22)
('vitalsleep-clinic','clinic-snore-therapy','คลินิกนอนกรนใกล้ฉัน','gsc','Commercial'), -- 21 imp p9.7; "คลินิกนอนกรน" is held as semantic elsewhere
('vitalsleep-clinic','congenital-disease-snoring-sleep','นอนกรน ความดันสูง','gsc','Informational'), -- 31 imp p9.7
('vitalsleep-clinic','CPAP-snoring-obstructive-sleep-apnea3','โรคไหลตายเกิดจากอะไร','registry','Informational'), -- title "ใหลตาย อาจเริ่มจากเสียงกรน" = cause angle; head ใหลตาย held by suds-sudden-unexpected-death-syndrome-sudden-death
('vitalsleep-clinic','osa-sleep-lab-obstructive-sleep-apnea','อาการใหลตาย','registry','Informational'), -- symptom angle of the ใหลตาย cluster
('vitalsleep-clinic','sleep-lab-snoring-suds','sleep lab คือ','gsc','Informational'), -- 20 imp p3.2
('vitalsleep-clinic','polysomnographystudy-treatnonsurger','ลดอาการกรน','gsc','Informational'), -- 14 imp p11.3 (top query)
('vitalsleep-clinic','radiofrequency-rf','รักษาด้วยคลื่นความถี่วิทยุ','gsc','Informational'), -- 85 imp p11.8
('vitalsleep-clinic','rf-of-tongue-snoring-sleep-apnea','rf bot','gsc','Commercial'), -- 11 imp p3.3; promotion-rf-bot (promo, no target) also gets it
('vitalsleep-clinic','sleep-health-obstructive-sleep-apnea-breathless','ภาวะหยุดหายใจขณะหลับ อันตราย','registry','Informational'), -- title "หยุดหายใจขณะหลับ อันตรายใกล้ตัว"; head held by sleep-apnea-inap-snoring
('vitalsleep-clinic','snoring-in-women-snoring-snoring-treatments','แก้อาการนอนกรน ผู้หญิง','gsc','Informational'), -- 44 imp p22; treatment angle vs held ผู้หญิงนอนกรน
('vitalsleep-clinic','snoring-myofunctional-therapy-health','myofunctional therapy คือ','gsc','Informational'), -- 138 imp 2 clk p9.6; head held by myofuction-therapy (DR-048 head vs angle)
('vitalsleep-clinic','snoring-sleep-health','นอนกรนอันตรายไหม','gsc','Informational'), -- 66 imp; most impressions of 3 pages getting it (others are reviews / sunds)
('vitalsleep-clinic','snoring-treatment-cpap/snoring-surgery','ผ่าตัดแก้กรน','registry','Commercial'), -- ผ่าตัดนอนกรน / ผ่าตัดแก้นอนกรน are held as semantics elsewhere
('vitalsleep-clinic','snoringclinc-osa','รักษาโรคนอนกรน','registry','Commercial'), -- hub "โรคนอนกรน รักษานอนกรน"
('vitalsleep-clinic','weight-loss-for-snoring-relief','วิธีแก้คนอ้วน นอนกรน','gsc','Informational'), -- 40 imp p14.8
('vitalsleep-clinic','services/effortless-weight-loss-sleep-wellness-fat','effortless weight loss','dfs','Commercial'), -- DFS vol 10
('vitalsleep-clinic','services/emsculpt-neo-muscle-sleep-wellness','emsculpt neo','gsc','Commercial'), -- 150 imp p12.4
('vitalsleep-clinic','services/emsella-hifem-osa','emsella','gsc','Commercial'), -- 101 imp p25
('vitalsleep-clinic','services/exion-rf-osa','exion','dfs','Commercial'), -- DFS vol 260
('vitalsleep-clinic','services/exomind-brain-balance-for-better-sleep','exomind','registry','Commercial'), -- free registry; also seen on promotion pages
('vitalsleep-clinic','services/myosculpt-hifem-sleep-apnea','hifem','gsc','Commercial'), -- 6 imp; Myosculpt is HIFEM
('vitalsleep-clinic','services/smart-light-whole-body-infrared-deep-sleep','light therapy','dfs','Commercial'), -- DFS vol 170
-- clearisma (15)
('clearisma','home','clearisma','registry','Navigational'), -- brand head, vol 74
('clearisma','clear-aligner','จัดฟันใส','dfs','Commercial'), -- pillar service; DFS vol 6600; GSC "จัด ฟัน ใส" lands on what-clearisma (cannibal, see report)
('clearisma','aligner-3d-plan','สแกนฟัน 3 มิติ','gsc','Informational'), -- 14 imp p9
('clearisma','aligner-braces-teeth','จัดฟันแบบไม่เห็นเหล็ก','gsc','Commercial'), -- 3 imp p14, exact title
('clearisma','cheese-prevent-tooth-decay','อาหารบำรุงฟัน','registry','Informational'), -- vol 161
('clearisma','clear-aligner-adult','จัดฟันใสผู้ใหญ่','registry','Commercial'), -- title "วัยทำงาน"
('clearisma','clear-aligner-good','ข้อดีของจัดฟันใส','registry','Informational'), -- title "ดียังไง เหมาะกับใคร"
('clearisma','clearaligner-best-choice','จัดฟันใส ดีไหม','gsc-sibling','Informational'), -- title "จัดฟันใสดีไหม"; query seen on review page
('clearisma','clearbraces-dental-care-clinic','จัดฟัน invisalign คือ','registry','Informational'), -- title "จัดฟัน Invisalign คืออะไร"
('clearisma','clearligner-choose-dentals-clinic','จัดฟันใส มีกี่แบบ','gsc-sibling','Informational'), -- clear-aligner angle of held จัดฟันมีกี่แบบ
('clearisma','dental-aligner-braces','จัดฟันใส กับ จัดฟันเหล็ก','registry','Commercial'), -- comparison
('clearisma','round-2-aligner','ฟันล้ม','registry','Informational'), -- vol 2992; title "ฟันล้มหลังถอดรีเทนเนอร์"
('clearisma','coollight-home-bleaching-teeth-whitening','วิธีแก้ฟันเหลืองด้วยตัวเอง','registry','Informational'), -- vol 655
('clearisma','smilemate','smilemate','gsc','Navigational'), -- product page, 1 imp p3
('clearisma','price-of-clearisma','จัดฟันใส ราคาไม่แพง','gsc','Commercial'), -- 43 imp p4; "จัดฟันใส ราคา" held by cost-pay-installment
-- tc-smile-dental (52)
('tc-smile-dental','aligner-online-orthodontic','จัดฟันออนไลน์','registry','Commercial'), -- title "จัดฟันออนไลน์"
('tc-smile-dental','airflow-dental-cleaning','gbt airflow','registry','Commercial'), -- vol 70; ขูดหินปูน airflow held by what-airflow-dental
('tc-smile-dental','braces-tooth-extraction','จัดฟันต้องถอนฟันไหม','gsc','Informational'), -- 7 imp p13 (+ two variants 5 imp)
('tc-smile-dental','brace-kind-busy','ดัดฟันแบบไหนดี','gsc','Commercial'), -- 4 imp p18
('tc-smile-dental','ceramic-composite-veneer','veneers คือ','registry','Informational'), -- vol 491; title "ทำวีเนียร์คืออะไร"
('tc-smile-dental','chipped-tooth-dental','ฟันแตก','registry','Informational'), -- vol 3867
('tc-smile-dental','clinic-dental-dentist','คลินิกทันตกรรมทีสมายล์','registry','Navigational'), -- vol 502 brand
('tc-smile-dental','clinic-dental-good','ทำฟันที่ไหนดี','registry','Commercial'), -- exact title
('tc-smile-dental','crown','ครอบฟัน','gsc-sibling','Commercial'), -- pillar service head; ครอบฟันราคา/คืออะไร/หน้า/เซรามิก held by children
('tc-smile-dental','crown-smile-beautiful','ครอบฟันเทียม','registry','Commercial'), -- exact title
('tc-smile-dental','where-dental-crown','ทำครอบฟันที่ไหนดี','gsc','Commercial'), -- 4 imp p16
('tc-smile-dental','dental-braces-colors','สีเหล็กจัดฟัน','gsc','Informational'), -- 10 imp p45
('tc-smile-dental','dental-care-smile-elderly-person','การจัดฟันของผู้สูงอายุ','registry','Informational'), -- title "จัดฟันให้ผู้สูงอายุ"
('tc-smile-dental','dental-care-tooth-beautiful-teeth','จัดฟันใส vs จัดฟันเหล็ก','dfs','Commercial'), -- DFS vol 30
('tc-smile-dental','dental-ceramic-material','ฟันเซรามิกคืออะไร','gsc','Informational'), -- 3 imp p9, vol 43
('tc-smile-dental','dental-denture-implants','ฟันปลอมแบบติดแน่น','gsc','Commercial'), -- 2 imp p57; title ถอดได้ vs ติดแน่น
('tc-smile-dental','denture-tooth-elderly','ทําฟันปลอมผู้สูงอายุ','registry','Commercial'), -- vol 42; GSC "ใส่ฟันปลอมผู้สูงอายุ" 8 imp
('tc-smile-dental','dental-implant-cheap','รากฟันเทียมราคาถูก','gsc','Commercial'), -- exact title; cheap angle (DR-048)
('tc-smile-dental','implant-price-truth','รากฟันเทียมราคาหลักพัน','registry','Commercial'), -- exact title; GSC variant p2
('tc-smile-dental','dental-implant-tooth-artificial-teeth','ทำรากฟันเทียม','gsc','Commercial'), -- 1 imp p12
('tc-smile-dental','implant-5-benefits','ข้อดีของรากฟันเทียม','gsc-sibling','Informational'), -- title "5 ข้อดี"; query ranks p1 on implant-false-teeth-tooth
('tc-smile-dental','where-best-implant','ทํารากฟันเทียม ที่ไหนดี','gsc','Commercial'), -- 3 imp p24 (+ variant 6 imp p11)
('tc-smile-dental','dental-implant-uv','uv implant','gsc','Commercial'), -- 2 imp p2
('tc-smile-dental','dental-implant-digital','รากฟันเทียม','gsc','Commercial'), -- pillar service head, 3 imp p59
('tc-smile-dental','dental-implant-digital/dental-implants-all-on-4-dental','all-on-4','gsc-sibling','Commercial'), -- all on 4 ราคา held by price page; 9 imp on allon4-vs-dentures
('tc-smile-dental','implant-support-jawbone','กระดูกขากรรไกรละลาย','dfs','Informational'), -- DFS vol 20
('tc-smile-dental','dental-implants-zygoma','zygoma implant','dfs','Commercial'), -- DFS vol 50
('tc-smile-dental','dental-tartar-tooth-dental-health','ขูดหินปูน','registry','Commercial'), -- vol 12142; ขูดหินปูน airflow is the angle page
('tc-smile-dental','frist-braces-hurt','จัดฟันเจ็บไหม','gsc','Informational'), -- 7 imp p39
('tc-smile-dental','lingual-braces-lingual-orthodontics','จัดฟันด้านในราคา','gsc','Commercial'), -- 3 imp p19; head จัดฟันข้างใน held by blog lingual-braces-good
('tc-smile-dental','brava-by-brius','brava by brius','gsc','Commercial'), -- 4 imp p45
('tc-smile-dental','namel-white-teeth-veneer','ฟันเหลืองแก้ยังไง','gsc','Informational'), -- 10 imp p53 (+ variant 6 imp)
('tc-smile-dental','oxygen-dental-recovery','mhbot','gsc','Informational'), -- 4 imp p3
('tc-smile-dental','orthodontic-braces-dental','จัดฟันคลินิกไหนดี','gsc','Commercial'), -- 20 imp p10
('tc-smile-dental','orthodontics-bangkok-adult','จัดฟันกทมที่ไหนดี','registry','Commercial'), -- exact title; Bangkok qualifier
('tc-smile-dental','orthodontic-bangkok-ai','aiดัดฟัน','registry','Commercial'), -- vol 290; AI angle of the title
('tc-smile-dental','tooth-decay-cheese-prevent','ลดฟันผุ','registry','Informational'), -- only free decay keyword; title "ชีส ป้องกันฟันผุ"
('tc-smile-dental','tooth-dental-whitening','ฟอกสีฟัน','registry','Commercial'), -- vol 3867 head; price variants held
('tc-smile-dental','veneer-dental-care','จัดฟันวีเนียร์','gsc','Informational'), -- 2 imp p15, exact title
('tc-smile-dental','veneer-smile-natural','ทำวีเนียร์ ที่ไหนดี','gsc','Commercial'), -- 1 imp p10, exact title
('tc-smile-dental','veneer-cheap-price','ทําวีเนียร์ราคาถูก','registry','Commercial'), -- exact title; cheap angle (DR-048)
('tc-smile-dental','veneer-teeth-dental/nemo-smile-veneer-dsd','ออกแบบรอยยิ้ม','gsc','Commercial'), -- 5 imp p6
('tc-smile-dental','wisdom-teeth-price-tooth-extraction','ถอนฟันคุด ราคา','registry','Commercial'), -- exact title; ถอนฟันราคา held by price page
('tc-smile-dental','what-clear-aligner','aligner คือ','gsc','Informational'), -- 7 imp p75
('tc-smile-dental','biolux-active','จัดฟันแบบใสไบโอลักซ์แอคทีฟ','gsc','Commercial'), -- 26 imp p4; "biolux active" held by blog infrared-biolux
('tc-smile-dental','smart-night','จัดฟันแบบเร่งด่วน','gsc','Commercial'), -- 2 imp p9
('tc-smile-dental','dental-spa','dental spa','gsc','Commercial'), -- 1 imp p1
('tc-smile-dental','emsmile-non-surgical','emsmile','dfs','Commercial'), -- DFS vol 10
('tc-smile-dental','invisalign-braces','อินวิซาไลน์','gsc','Commercial'), -- 2 imp p8
('tc-smile-dental','invisalign-braces-clear-aligners','diamond smile','gsc','Commercial'), -- 4 imp p6, vol 58
('tc-smile-dental','register-smilemate','ปรึกษาหมอฟันออนไลน์','gsc','Commercial'), -- 15 imp 1 clk p8
('tc-smile-dental','price-dental-all','ราคาทำฟัน','dfs','Commercial'), -- DFS vol 170
-- the-face-by-vertex (50)
('the-face-by-vertex','home','vertex clinic','gsc','Navigational'), -- 182 imp 35 clk p3
('the-face-by-vertex','3dcustomied-silicone-forehead-surgery','customized silicone','gsc','Commercial'), -- 82 imp p5
('the-face-by-vertex','artificialteeth-tooth-dental-implant','รากฟันเทียมราคาถูก','registry','Commercial'), -- exact title; price held by implant-dental-promotion
('the-face-by-vertex','dental-implant-tooth-artificial-teeth','รากฟันเทียม คือ','gsc','Informational'), -- 1 imp p24, exact title
('the-face-by-vertex','genioplasty-with-bone','เสริมคางด้วยกระดูกตัวเอง','gsc','Commercial'), -- 17 imp p5
('the-face-by-vertex','jaw-osa-snoring','คางสั้น นอนกรน','gsc','Informational'), -- 8 imp p9
('the-face-by-vertex','jaw-surgery-doctor','ขากรรไกรเบี้ยวเกิดจากอะไร','gsc','Informational'), -- 9 imp p4; head held by orthognathic-jaw-surgery-face-surgery
('the-face-by-vertex','jaw-surgery-facial-surgery-thai-doctor-korean-surgery','ผ่าตัด ขา กรรไกร ที่ เกาหลี','gsc','Commercial'), -- 8 imp p16
('the-face-by-vertex','kids-orthodontics-pedodontics','จัดฟันเด็ก','gsc','Commercial'), -- 9 imp p22
('the-face-by-vertex','rhinoplasty-surgery-close-surgery-open-surgery','เสริมจมูก open กับ close ต่างกันยังไง','gsc','Informational'), -- 41 imp p2
('the-face-by-vertex','target-cool-face','target cool','gsc','Commercial'), -- 4 imp p24
('the-face-by-vertex','teeth-implant-denture','รากฟันเทียมกับฟันปลอม','gsc','Commercial'), -- 8 imp p4
('the-face-by-vertex','teeth-orthodontics-dental','จัดฟันแบบผ่อน','gsc','Commercial'), -- 12 imp p2
('the-face-by-vertex','undefined-jawline','กรอบหน้าไม่ชัด','dfs','Informational'), -- DFS vol 140
('the-face-by-vertex','wisdom-tooth-partially-erupted','ฟันคุดต้องถอนไหม','registry','Informational'), -- vol 439
('the-face-by-vertex','วีเนียร์','วีเนียร์ฟันขาว','gsc','Commercial'), -- 2 imp p31
('the-face-by-vertex','หน้าสวย-โหงวเฮ้งดี','ปรับโครงหน้าโหงวเฮ้ง','gsc','Commercial'), -- 13 imp p6
('the-face-by-vertex','dental-center','vertex dental','gsc','Navigational'), -- 2 imp p6
('the-face-by-vertex','dental-center/biolux','แสงอินฟาเรดไบโอลักซ์','gsc','Commercial'), -- 21 imp p2
('the-face-by-vertex','dental-center/dental-implants-ceramic','รากฟันเทียมเซรามิก','gsc','Commercial'), -- 13 imp p7
('the-face-by-vertex','dental-center/dental-scaling','ขูดหินปูน','dfs','Commercial'), -- DFS vol 12100
('the-face-by-vertex','dental-center/denture','ฟันปลอม','dfs','Commercial'), -- DFS vol 8100
('the-face-by-vertex','dental-center/diagnosis','ตรวจสุขภาพช่องปาก','gsc','Commercial'), -- 2 imp p66
('the-face-by-vertex','dental-center/full-clear-braces','diamond smile','gsc','Commercial'), -- 8 imp p4
('the-face-by-vertex','dental-center/inlay-onlay','inlay onlay','gsc','Commercial'), -- 11 imp p11
('the-face-by-vertex','dental-center/intra-lock','intralock implants','gsc','Commercial'), -- 5 imp 1 clk p3
('the-face-by-vertex','dental-center/laser-dentistry','ทันตกรรมเลเซอร์','dfs','Informational'), -- DFS vol 10, exact title
('the-face-by-vertex','dental-center/laser-gum-bleaching','เหงือกดำ','gsc','Informational'), -- 16 imp p14
('the-face-by-vertex','dental-center/pedodontics','คลินิกทันตกรรมเด็ก','gsc','Commercial'), -- 2 imp p43; ฟันเด็ก held by blog clinic-dental-pedodontics
('the-face-by-vertex','dental-center/periodontic','การรักษาโรคเหงือก','registry','Commercial'), -- title "รักษาโรคเหงือก"
('the-face-by-vertex','dental-center/pontic','สะพานฟัน','dfs','Commercial'), -- DFS vol 1900; also GSC 1 imp
('the-face-by-vertex','dental-center/smart-clear','smart clear','registry','Commercial'), -- product page
('the-face-by-vertex','dental-center/smart-inside','smart inside','gsc','Commercial'), -- 1 imp p1
('the-face-by-vertex','dental-center/smart-night','smart night','dfs','Commercial'), -- DFS vol 10
('the-face-by-vertex','dental-center/uv-dental-implant','uv implant','gsc','Commercial'), -- 9 imp p2
('the-face-by-vertex','dental-center/x-ray-3d-x-ray-computer','x-ray 3d','gsc','Commercial'), -- 4 imp p2
('the-face-by-vertex','dental-center/zygomatic-implant','zygoma implant','dfs','Commercial'), -- DFS vol 50; GSC "zygoma คือ" is the bone, not the implant
('the-face-by-vertex','dental-monitoring','dental monitoring','dfs','Commercial'), -- DFS vol 10
('the-face-by-vertex','face-surgery','ศัลยกรรมใบหน้า','gsc','Commercial'), -- 13 imp p41; ศัลยกรรมโครงหน้า held by facial-surgery
('the-face-by-vertex','face-surgery/cheek-augmentation-biopolymer-cheek-surgery','เสริมหน้าแก้ม','gsc','Commercial'), -- 11 imp p1
('the-face-by-vertex','face-surgery/eye-surgery-eyelid-eyebag','แก้ตา 2 ชั้น','gsc','Commercial'), -- revision angle; ตาสองชั้น held
('the-face-by-vertex','face-surgery/eyebag-surgery-lower-blepharoplasty-eye-surgery','ผ่าตัดถุงใต้ตา','gsc','Commercial'), -- 7 imp p43
('the-face-by-vertex','face-surgery/lip-surgery-horn-chestnut-shaped-lips','ปากกระจับ','registry','Commercial'), -- vol 4750; GSC variants p6
('the-face-by-vertex','face-surgery/nose-surgery-rhinoplasty-open-rhinoplasty','เสริมจมูกแบบเปิด','gsc','Commercial'), -- 12 imp p11
('the-face-by-vertex','facial-smile-design','ออกแบบรอยยิ้ม','gsc','Commercial'), -- 10 imp p7 (stronger than dental-center/nemo-smile-veneer-dsd, 5 imp)
('the-face-by-vertex','facial-surgery/v-line-cheek-bone-reduction-jaw-surgery','ทําโครงหน้า 3 จุด','gsc','Commercial'), -- 18 imp p2
('the-face-by-vertex','jaw-surgery/removal-of-pins-pin-removal-screw-removed','ขา กรรไกร บน ยื่น ปัก หมุด','gsc','Informational'), -- 19 imp p3
('the-face-by-vertex','jaw-surgery/two-jaw-orthognathic-man-facial-contour','โครงหน้าผู้ชาย','gsc','Commercial'), -- 168 imp p7
('the-face-by-vertex','jaw-surgery/two-jaw-orthognathic-woman-facial-contour','โครงหน้าผู้หญิง','gsc','Commercial'), -- 20 imp p8
('the-face-by-vertex','nemotec-mis-surgery-facial','nemotec mis','gsc','Commercial'); -- 17 imp p6

-- 1 · add keywords missing from the registry (same kw_norm already in the brand = reuse that row)
insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select distinct on (bb.brand, kw_norm(b.keyword))
       lower(bb.brand||'::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::'||b.keyword), b.keyword, bb.brand, '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai', b.intent,
       'Added 2026-10-23 W38 target binding from '||case b.src when 'dfs' then 'DataForSEO search volume' else 'GSC query discovery' end||' (DR-076); no volume inferred.'
  from w38_bind b
  join (values ('the-face-by-vertex','The Face by Vertex'),('tc-smile-dental','TC Smile Dental'),('clearisma','Clearisma'),('vitalsleep-clinic','VitalSleep Clinic')) bb(brand_id, brand) on bb.brand_id = b.brand_id
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = bb.brand and kw_norm(k.keyword) = kw_norm(b.keyword))
on conflict (fingerprint) do nothing;

-- 2 · resolve each binding to one registry fingerprint (exact text first, then kw_norm)
create temp table w38_resolved on commit drop as
select b.*, (select k.fingerprint from public.seo_x_ads_keywords_contextual_master k
              where k.brand = bb.brand and kw_norm(k.keyword) = kw_norm(b.keyword)
              order by (k.keyword = b.keyword) desc, k.fingerprint limit 1) as fp
  from w38_bind b
  join (values ('the-face-by-vertex','The Face by Vertex'),('tc-smile-dental','TC Smile Dental'),('clearisma','Clearisma'),('vitalsleep-clinic','VitalSleep Clinic')) bb(brand_id, brand) on bb.brand_id = b.brand_id;

-- 3 · bind (guarded: page must still be Live and unbound)
update public.seo_website_page_master p
   set target_keyword_fp = r.fp,
       viability_assessment = coalesce(p.viability_assessment, '{}'::jsonb)
         || jsonb_build_object('kw_rule_version','1.0','keyword_source',r.src,'decided_by','w38-migration','decided_at','2026-10-23')
  from w38_resolved r
 where p.brand_id = r.brand_id and p.slug = r.slug
   and p.status not in ('Merged','Dropped')
   and p.target_keyword_fp is null; -- 139 rows expected

-- 4 · keyword_use_as (trg_sync_keyword_use_as should already have done this; excluded is never overwritten)
update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = 'target_keyword'
  from w38_resolved r
 where k.fingerprint = r.fp
   and k.keyword_use_as is distinct from 'target_keyword'
   and k.keyword_use_as is distinct from 'excluded';

-- 5 · assert: all 139 bound, no duplicate target in the 4 brands
do $$
declare n int; d int;
begin
  select count(*) into n from w38_resolved r join public.seo_website_page_master p on p.brand_id = r.brand_id and p.slug = r.slug and p.target_keyword_fp = r.fp;
  if n <> 139 then raise exception 'W38: expected 139 bound pages, got %', n; end if;
  select count(*) into d from (select target_keyword_fp from public.seo_website_page_master
     where brand_id in ('the-face-by-vertex','tc-smile-dental','clearisma','vitalsleep-clinic') and status not in ('Merged','Dropped') and target_keyword_fp is not null
     group by 1 having count(*) > 1) x;
  if d <> 0 then raise exception 'W38: % duplicate targets', d; end if;
end $$;

commit;

-- after commit: select refresh_keyword_near_pairs(); select refresh_page_priority();
