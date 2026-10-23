-- W39e · VitalSleep: record the W39 §3 merges that went live 2026-10-24 ~00:40 Bangkok (DRAFT, not applied) · 2026-10-24
-- Source: brand session "การเชื่อมต่อ WordPress" (user-approved there); log in
--   repos/brands/eywa-vitalsleep-wellness/content/consolidation/W39-merge-batch-check-2026-10-24.md
-- Two targets changed from the plan by the brand session: tips-snoring-new-years-gift → snoring-non-surgery,
-- osa-sudden-death-sleep-test → sleep-apnea-inap-snoring.
-- Convention of earlier merges: status='Merged', redirect_target = full URL, target and semantics cleared
-- (trg_page_keyword_no_reuse rule 5: Merged pages hold no semantic keywords). Released targets go back to the pool.
-- Step 2 gives the freed head "ใหลตาย" to the ใหลตาย owner sleepdead-sleeptest-healthcare (W39 plan §3).
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39e_20261024_vitalsleep_merges as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic'
   and p.slug in ('snoring-health-care-non-surgery','snoring-treatment-healthcare','CPAP-snoring-obstructive-sleepapnea2','polysomnographystudy-treatnonsurger',
                  'snoring-obstructive-sleep-apnea-sleep-lab','snoring-cpap-rf-bot-oral-appliance','tips-snoring-new-years-gift','update-snoring-treatment-2021',
                  'snoring-in-women-snoring-snoring-treatments','weight-loss-for-snoring-relief','suds-sudden-unexpected-death-syndrome-sudden-death',
                  'sudden-unexplained-nocturnal-death-syndrome','sunds-obstructive-sleep-apnea-snoring','CPAP-snoring-obstructive-sleep-apnea3',
                  'osa-sleep-lab-obstructive-sleep-apnea','osa-sudden-death-sleep-test','sleep-lab-snoring-suds','sleep-apnea-health-dangerous',
                  'sleep-health-obstructive-sleep-apnea-breathless','congenital-disease-snoring-sleep','sleep-apnea-cancer','snoring-erectile-dysfunction-health',
                  'snoring-therapy-myofunctional-therapy','occlusal-splint-snoring-obstructive-sleep-apnea','sleepdead-sleeptest-healthcare'); -- 25 rows expected

create temp table w39e_merge (slug text, target_slug text) on commit drop;
insert into w39e_merge (slug, target_slug) values
('snoring-health-care-non-surgery','snoring-treatment-cpap/snoring-non-surgery'),
('snoring-treatment-healthcare','snoring-treatment-cpap/snoring-non-surgery'),
('CPAP-snoring-obstructive-sleepapnea2','snoring-treatment-cpap/snoring-non-surgery'),
('polysomnographystudy-treatnonsurger','snoring-treatment-cpap/snoring-non-surgery'), -- releases W38 ลดอาการกรน
('snoring-obstructive-sleep-apnea-sleep-lab','snoring-treatment-cpap/snoring-non-surgery'), -- releases การรักษานอนกรน
('snoring-cpap-rf-bot-oral-appliance','snoring-treatment-cpap/snoring-non-surgery'),
('tips-snoring-new-years-gift','snoring-treatment-cpap/snoring-non-surgery'), -- brand session changed target from how-to-stop-snoring
('update-snoring-treatment-2021','snoring-solutions-anti-snoring-devices-products-for-snoring'), -- releases อุปกรณ์แก้นอนกรน
('snoring-in-women-snoring-snoring-treatments','sleep-apnea-cause-women-snoring'), -- releases W38 แก้อาการนอนกรน ผู้หญิง
('weight-loss-for-snoring-relief','weight-loss-snoring-sleep-apnea'), -- releases W38 วิธีแก้คนอ้วน นอนกรน
('suds-sudden-unexpected-death-syndrome-sudden-death','sleepdead-sleeptest-healthcare'), -- releases ใหลตาย (re-bound in step 2)
('sudden-unexplained-nocturnal-death-syndrome','sleepdead-sleeptest-healthcare'),
('sunds-obstructive-sleep-apnea-snoring','sleepdead-sleeptest-healthcare'),
('CPAP-snoring-obstructive-sleep-apnea3','sleepdead-sleeptest-healthcare'), -- releases W38 โรคไหลตายเกิดจากอะไร
('osa-sleep-lab-obstructive-sleep-apnea','sleepdead-sleeptest-healthcare'), -- releases W38 อาการใหลตาย
('osa-sudden-death-sleep-test','sleep-apnea-inap-snoring'), -- brand session changed target from sleepdead
('sleep-lab-snoring-suds','sleep-test-cost-sleep-study'), -- releases W38 sleep lab คือ
('sleep-apnea-health-dangerous','sleep-apnea-inap-snoring'), -- releases การหยุดหายใจขณะนอนหลับ
('sleep-health-obstructive-sleep-apnea-breathless','sleep-apnea-inap-snoring'), -- releases W38 ภาวะหยุดหายใจขณะหลับ อันตราย
('congenital-disease-snoring-sleep','snoring-sleep-health'), -- releases W38 นอนกรน ความดันสูง
('sleep-apnea-cancer','snoring-sleep-health'),
('snoring-erectile-dysfunction-health','snore-erectile-dysfunction'),
('snoring-therapy-myofunctional-therapy','snoring-myofunctional-therapy-health'),
('occlusal-splint-snoring-obstructive-sleep-apnea','occlusal-splint-obstructive-sleep-apnea-mandibular-advancement-device'); -- 24 rows

-- 1 · mark merged (guarded: still Live)
update public.seo_website_page_master p
   set status = 'Merged',
       redirect_target = 'https://www.vitalsleepclinic.com/' || m.target_slug || '/',
       target_keyword_fp = null,
       semantic_keywords_fps = null,
       reconciliation_notes = coalesce(p.reconciliation_notes || ' | ', '') || 'W39 merge 2026-10-24 → /' || m.target_slug || '/'
  from w39e_merge m
 where p.brand_id = 'vitalsleep-clinic' and p.slug = m.slug
   and p.status = 'Live'; -- 24 rows

-- 2 · ใหลตาย → sleepdead-sleeptest-healthcare (drop it from its own semantics in the same statement)
update public.seo_website_page_master
   set target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ใหลตาย',
       semantic_keywords_fps = array_remove(semantic_keywords_fps, 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ใหลตาย'),
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','registry','decided_by','w39e-migration','decided_at','2026-10-24','note','ใหลตาย cluster owner after W39 merges')
 where brand_id = 'vitalsleep-clinic' and slug = 'sleepdead-sleeptest-healthcare'
   and target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ไหลตาย คือ'
   and exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.fingerprint = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ใหลตาย'); -- 1 row

-- 3 · keyword_use_as for every keyword these pages held (recompute; excluded never overwritten)
update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.fingerprint in (
         select (b.row_data->>'target_keyword_fp') from public.bak_w39e_20261024_vitalsleep_merges b where b.row_data->>'target_keyword_fp' is not null
         union
         select jsonb_array_elements_text(b.row_data->'semantic_keywords_fps') from public.bak_w39e_20261024_vitalsleep_merges b where jsonb_typeof(b.row_data->'semantic_keywords_fps') = 'array')
   and k.keyword_use_as is distinct from 'excluded';

-- 4 · assert
do $$
declare n int; t int;
begin
  select count(*) into n from public.seo_website_page_master p join w39e_merge m on m.slug = p.slug
   where p.brand_id = 'vitalsleep-clinic' and p.status = 'Merged' and p.target_keyword_fp is null and p.redirect_target like 'https://www.vitalsleepclinic.com/%';
  if n <> 24 then raise exception 'W39e: expected 24 merged pages, got %', n; end if;
  select count(*) into t from public.seo_website_page_master p
   where p.brand_id = 'vitalsleep-clinic' and p.status not in ('Merged','Dropped')
     and p.slug in (select target_slug from w39e_merge);
  if t <> 11 then raise exception 'W39e: expected 11 live merge targets, got %', t; end if;
end $$;

commit;
