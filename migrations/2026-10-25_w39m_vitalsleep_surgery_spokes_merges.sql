-- W39m · VitalSleep surgery-spokes + myofunctional round: 2 merges + 1 re-pointed 301 (DRAFT, not applied) · 2026-10-25
-- Source: brand session "การเชื่อมต่อ WordPress" (published 2026-10-25, user-approved there). Same merge convention as W39e.
-- Owners proposed in the same round were checked against GSC page×query (90d) and are kept as they are in the DB:
--   mandibular-snoring-sleep-apnea keeps ผ่าตัดขากรรไกร นอนกรน (147 impr p4.1; proposed ผ่าตัดขากรรไกร แก้นอนกรน 144 p3.0 is
--   already its semantic) · pillar-implant keeps การฝังพิลลาร์ (proposed ฝังพิลลาร์ has no GSC; pillar คือ 487 p3 is a semantic)
--   · radiofrequency-rf keeps รักษาด้วยคลื่นความถี่วิทยุ (87 p11.7; proposed RF แก้นอนกรน has no GSC) · myofuction-therapy =
--   myofunctional therapy already matches · hub snoring-treatment-cpap/snoring-surgery keeps ผ่าตัดนอนกรน.
-- Released by the merges (back to the pool, for the semantic round): rf bot, myofunctional therapy คือ.
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39m_20261025_vitalsleep as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic'
   and p.slug in ('rf-of-tongue-snoring-sleep-apnea','snoring-myofunctional-therapy-health','snoring-therapy-myofunctional-therapy'); -- 3 rows expected

create temp table w39m_merge (slug text, target_slug text) on commit drop;
insert into w39m_merge values
('rf-of-tongue-snoring-sleep-apnea','radiofrequency-rf'), -- releases rf bot
('snoring-myofunctional-therapy-health','myofuction-therapy'); -- releases myofunctional therapy คือ

-- 1 · merges
update public.seo_website_page_master p
   set status = 'Merged',
       redirect_target = 'https://www.vitalsleepclinic.com/' || m.target_slug || '/',
       target_keyword_fp = null,
       semantic_keywords_fps = null,
       reconciliation_notes = coalesce(p.reconciliation_notes || ' | ', '') || 'W39 surgery-spokes merge 2026-10-25 → /' || m.target_slug || '/'
  from w39m_merge m
 where p.brand_id = 'vitalsleep-clinic' and p.slug = m.slug and p.status = 'Live'; -- 2 rows

-- 2 · re-point the old 301 straight to the survivor (no chain)
update public.seo_website_page_master
   set redirect_target = 'https://www.vitalsleepclinic.com/myofuction-therapy/',
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39m 2026-10-25: 301 re-pointed to /myofuction-therapy/'
 where brand_id = 'vitalsleep-clinic' and slug = 'snoring-therapy-myofunctional-therapy' and status = 'Merged'
   and redirect_target = 'https://www.vitalsleepclinic.com/snoring-myofunctional-therapy-health/'; -- 1 row

-- 3 · keyword_use_as for every keyword the merged pages held
update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.fingerprint in (
         select b.row_data->>'target_keyword_fp' from public.bak_w39m_20261025_vitalsleep b where b.row_data->>'target_keyword_fp' is not null
         union
         select jsonb_array_elements_text(b.row_data->'semantic_keywords_fps') from public.bak_w39m_20261025_vitalsleep b where jsonb_typeof(b.row_data->'semantic_keywords_fps') = 'array')
   and k.keyword_use_as is distinct from 'excluded';

-- 4 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master
   where brand_id = 'vitalsleep-clinic'
     and ((slug = 'rf-of-tongue-snoring-sleep-apnea' and status = 'Merged' and redirect_target = 'https://www.vitalsleepclinic.com/radiofrequency-rf/')
       or (slug in ('snoring-myofunctional-therapy-health','snoring-therapy-myofunctional-therapy') and status = 'Merged'
           and redirect_target = 'https://www.vitalsleepclinic.com/myofuction-therapy/'));
  if n <> 3 then raise exception 'W39m: expected 3 rows in final state, got %', n; end if;
end $$;

commit;
