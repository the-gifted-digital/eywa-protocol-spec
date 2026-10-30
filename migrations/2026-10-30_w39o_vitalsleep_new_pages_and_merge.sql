-- W39o · VitalSleep: register 5 new live pages + 1 merge (DRAFT, not applied) · 2026-10-30
-- Source: brand session "การเชื่อมต่อ WordPress" pool update 2026-10-30 (handoff file, section "Update 2026-10-30"). Live checked
-- 2026-10-30: the 5 pages return 200; services/myosculpt-hifem-sleep-apnea 301s to services/emsculpt-neo-muscle-sleep-wellness.
-- None of the 5 targets is in the registry or held by any page; no GSC history yet (new pages), so keyword_source = brand_session.
-- leg-twitching does not take กระตุกตอนนอน / นอนสะดุ้ง (they stay with hypnic-jerks). Proposed semantics are queued for ~11-10.
-- Confirmed with no change: emsella-hifem-osa = emsella, emsculpt-neo = emsculpt neo, exion-rf-osa = exion, shortness-of-breath = หายใจไม่อิ่ม.
-- Merge releases hifem (back to the pool; seed for emsculpt-neo). blog-test (27780) is not in page_master — nothing to record.
-- Reserved targets for the 4 upcoming pages are not written here; they are registered when those pages go live.
-- page_fingerprint follows the brand convention 'vsc-wp-' || left(md5(slug), 8).
-- Run in the Supabase SQL editor as one transaction. Comments sit after the trailing , or ; on each line.

begin;

create table public.bak_w39o_20261030_vitalsleep as
select 'seo_website_page_master'::text as src, p.page_fingerprint as fp, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p
 where p.brand_id = 'vitalsleep-clinic' and p.slug = 'services/myosculpt-hifem-sleep-apnea'; -- 1 row expected

create temp table w39o_new (slug text, kw text, intent text, page_type text) on commit drop;
insert into w39o_new values
('nocturia-sleep-apnea','ฉี่บ่อยตอนกลางคืน','Informational','knowledge_article'), -- post 29136
('sleepwalking-sleep-talking','ละเมอ','Informational','knowledge_article'), -- post 29143
('night-sweats-sleep-apnea','เหงื่อออกตอนกลางคืน','Informational','knowledge_article'), -- post 29170
('leg-twitching-sleep-restless-legs','ขากระตุกตอนนอน','Informational','knowledge_article'), -- post 29177
('services/nightlase-laser-snoring','เลเซอร์นอนกรน','Commercial','service_page'); -- service 29150

-- 1 · registry rows for the 5 targets
insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::'||n.kw), n.kw, 'VitalSleep Clinic', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai', n.intent,
       'Added 2026-10-30 W39o new page target (brand session); no volume inferred.'
  from w39o_new n
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'VitalSleep Clinic' and kw_norm(k.keyword) = kw_norm(n.kw))
on conflict (fingerprint) do nothing; -- 5 rows

-- 2 · page rows
insert into public.seo_website_page_master (page_fingerprint, brand_id, brand_name, slug, canonical_url, status, page_type, page_language,
                                            target_keyword_fp, published_date, viability_assessment, reconciliation_notes)
select 'vsc-wp-' || left(md5(n.slug), 8), 'vitalsleep-clinic', 'VitalSleep Clinic', n.slug,
       'https://www.vitalsleepclinic.com/' || n.slug || '/', 'Live', n.page_type, 'th',
       lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::'||n.kw), null,
       jsonb_build_object('kw_rule_version','1.0','keyword_source','brand_session','decided_by','w39o-migration','decided_at','2026-10-30'),
       'W39o 2026-10-30: new page created by brand session'
  from w39o_new n
 where not exists (select 1 from public.seo_website_page_master p where p.brand_id = 'vitalsleep-clinic' and p.slug = n.slug); -- 5 rows

-- 3 · merge
update public.seo_website_page_master
   set status = 'Merged',
       redirect_target = 'https://www.vitalsleepclinic.com/services/emsculpt-neo-muscle-sleep-wellness/',
       target_keyword_fp = null,
       semantic_keywords_fps = null,
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W39 merge 2026-10-28 → /services/emsculpt-neo-muscle-sleep-wellness/'
 where brand_id = 'vitalsleep-clinic' and slug = 'services/myosculpt-hifem-sleep-apnea' and status = 'Live'; -- 1 row

-- 4 · keyword_use_as for the new targets and the released keyword
update public.seo_x_ads_keywords_contextual_master k
   set keyword_use_as = case
     when exists (select 1 from public.seo_website_page_master p where p.target_keyword_fp = k.fingerprint) then 'target_keyword'
     when exists (select 1 from public.seo_website_page_master p where k.fingerprint = any(p.semantic_keywords_fps)) then 'semantic_keyword'
   end
 where k.brand = 'VitalSleep Clinic'
   and (k.keyword in (select kw from w39o_new)
        or k.fingerprint in (select b.row_data->>'target_keyword_fp' from public.bak_w39o_20261030_vitalsleep b where b.row_data->>'target_keyword_fp' is not null))
   and k.keyword_use_as is distinct from 'excluded'; -- 6 rows

-- 5 · assert
do $$
declare n int;
begin
  select count(*) into n from public.seo_website_page_master p join w39o_new w on w.slug = p.slug
   where p.brand_id = 'vitalsleep-clinic' and p.status = 'Live' and p.target_keyword_fp = lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::'||w.kw);
  if n <> 5 then raise exception 'W39o: expected 5 new pages bound, got %', n; end if;
  if not exists (select 1 from public.seo_website_page_master where brand_id = 'vitalsleep-clinic' and slug = 'services/myosculpt-hifem-sleep-apnea' and status = 'Merged') then
    raise exception 'W39o: merge not recorded';
  end if;
end $$;

commit;
