-- W39l · VitalSleep bruxism/TMJ round: 5 merges + pillar owner (DRAFT, not applied) · 2026-10-26
-- Source: brand session "การเชื่อมต่อ WordPress" (live 2026-10-26: Yoast 301, posts drafted, inbound links re-pointed).
-- Same merge convention as W39e. Pillar splint-bruxism-tmd (rewritten) takes the head นอนกัดฟัน (its own semantic; promoted)
-- in place of นอนกัดฟันเกิดจาก, which stays on the page as a semantic for the semantic round.
-- Checked and unchanged: bruxism-gritted-teeth… = ยางกัดฟัน, temporomandibular-joint-jaw-gritted-teeth = ข้อต่อขากรรไกรอักเสบ,
-- temporomandibular-joint-treat-disease = ปวดกราม, sleep-bruxism-toothache keeps นอนกัดฟันจนปวดฟัน (ranked p2 in Feb–Mar and now;
-- ปวดฟันจนนอนไม่ได้ is already its semantic). Semantics proposed in the same round are queued for the semantic round (~11-10).
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39l_20261026_vitalsleep as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic'
   and p.slug in ('doctor-sleep-bruxism','occlusal-splint-bruxism','sleeptest-bruxism-asa','bruxism-cpap-osa','bruxism-disease-safe','splint-bruxism-tmd'); -- 6 rows expected

create temp table w39l_merge (slug text, target_slug text) on commit drop;
insert into w39l_merge values
('doctor-sleep-bruxism','splint-bruxism-tmd'), -- releases นอนกัดฟัน แก้ยังไง
('occlusal-splint-bruxism','splint-bruxism-tmd'), -- releases เฝือกสบฟัน
('sleeptest-bruxism-asa','splint-bruxism-tmd'), -- releases จัดฟัน นอนกัดฟัน
('bruxism-cpap-osa','bruxism-gritted-teeth-teeth-grinding-problems'), -- releases ฟันยาง
('bruxism-disease-safe','bruxism-gritted-teeth-teeth-grinding-problems'); -- releases ฟันยาง นอนกัดฟัน

-- 1 · merges
update public.seo_website_page_master p
   set status = 'Merged',
       redirect_target = 'https://www.vitalsleepclinic.com/' || m.target_slug || '/',
       target_keyword_fp = null,
       semantic_keywords_fps = null,
       reconciliation_notes = coalesce(p.reconciliation_notes || ' | ', '') || 'W39 bruxism merge 2026-10-26 → /' || m.target_slug || '/'
  from w39l_merge m
 where p.brand_id = 'vitalsleep-clinic' and p.slug = m.slug and p.status = 'Live'; -- 5 rows

-- 2 · pillar: own semantic นอนกัดฟัน → target
update public.seo_website_page_master
   set semantic_keywords_fps = array_remove(semantic_keywords_fps, 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::นอนกัดฟัน'),
       target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::นอนกัดฟัน',
       viability_assessment = coalesce(viability_assessment,'{}'::jsonb) || jsonb_build_object('kw_rule_version','1.0','keyword_source','gsc','decided_by','w39l-migration','decided_at','2026-10-26','note','bruxism pillar after merges')
 where brand_id = 'vitalsleep-clinic' and slug = 'splint-bruxism-tmd'
   and target_keyword_fp = 'vitalsleep clinic::🇹🇭 th – thailand::🇹🇭 th – thai::นอนกัดฟันเกิดจาก'; -- 1 row

-- 3 · keyword_use_as for every keyword the 6 pages held
update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.fingerprint in (
         select b.row_data->>'target_keyword_fp' from public.bak_w39l_20261026_vitalsleep b where b.row_data->>'target_keyword_fp' is not null
         union
         select jsonb_array_elements_text(b.row_data->'semantic_keywords_fps') from public.bak_w39l_20261026_vitalsleep b where jsonb_typeof(b.row_data->'semantic_keywords_fps') = 'array')
   and k.keyword_use_as is distinct from 'excluded';

-- 4 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master p join w39l_merge m on m.slug = p.slug
   where p.brand_id = 'vitalsleep-clinic' and p.status = 'Merged' and p.target_keyword_fp is null;
  if n <> 5 then raise exception 'W39l: expected 5 merged pages, got %', n; end if;
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'splint-bruxism-tmd'
                  and target_keyword_fp like '%::นอนกัดฟัน') then
    raise exception 'W39l: pillar not retargeted';
  end if;
end $$;

commit;
