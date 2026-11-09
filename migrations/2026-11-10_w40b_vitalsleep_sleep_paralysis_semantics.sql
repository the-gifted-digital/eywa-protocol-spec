-- W40b · VitalSleep /sleeptest-health-sleep-apnea/ (post 25663) ผีอำ gap-fill LIVE: 6 new registry keywords as semantics (DRAFT, not applied) · 2026-11-10
-- Source: brand session "การเชื่อมต่อ WordPress": gap-fill published 2026-11-09 23:11, front end verified 2026-11-10 (H3 #h-feel, extended FAQ,
-- Cheyne 1999 ref = W40a). TSV content/rewrites/sleep-paralysis-gapfill-2026-11-09.tsv.
-- Checks 2026-11-10: none of the 6 in the registry (kw_norm), held by no page; GSC 90d all ผีอ* queries on this page only → no conflict.
-- Page keeps target อาการผีอำ; semantics 8 → 14. Keywords stored as written in the TSV (ํา vs ำ spellings kept, as GSC reports them).
-- Run in the Supabase SQL editor as one transaction.

begin;

create temp table w40b_kw (kw text) on commit drop;
insert into w40b_kw values
('โดนผีอํารู้สึกยังไง'), ('ผีอํารู้สึกยังไง'), ('ผีอํามีจริงไหม'), ('ผี อํามีจริง ไหม'), ('ผีอำ ความเชื่อ โบราณ'), ('ผีอํา ทางวิทยาศาสตร์');

-- 1 · registry rows (skip any kw_norm duplicate)
insert into public.seo_x_ads_keywords_contextual_master (fingerprint, keyword, brand, target_market, target_language, search_intent, note)
select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::' || w.kw), w.kw, 'VitalSleep Clinic', '🇹🇭 TH – Thailand', '🇹🇭 TH – Thai',
       'Informational', 'Added 2026-11-10 W40b semantic for sleeptest-health-sleep-apnea (ผีอำ gap-fill, GSC 10-25..11-07, brand session).'
  from w40b_kw w
 where not exists (select 1 from public.seo_x_ads_keywords_contextual_master k where k.brand = 'VitalSleep Clinic' and kw_norm(k.keyword) = kw_norm(w.kw))
on conflict (fingerprint) do nothing; -- 6 rows

-- 2 · append to page semantics
update public.seo_website_page_master p
   set semantic_keywords_fps = (select array_agg(distinct f) from unnest(coalesce(p.semantic_keywords_fps, '{}') ||
                                  (select array_agg(lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::' || kw)) from w40b_kw)) f),
       reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') || 'W40b 2026-11-10: +6 ผีอำ semantics (gap-fill LIVE 2026-11-09)'
 where brand_id = 'vitalsleep-clinic' and slug = 'sleeptest-health-sleep-apnea' and status = 'Live'; -- 1 row

-- 3 · keyword_use_as
update public.seo_x_ads_keywords_contextual_master
   set keyword_use_as = 'semantic_keyword'
 where fingerprint in (select lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::' || kw) from w40b_kw)
   and keyword_use_as is distinct from 'excluded'; -- 6 rows

-- 4 · assert
do $$
declare n_sem int; n_held int;
begin
  select array_length(semantic_keywords_fps, 1) into n_sem from public.seo_website_page_master
   where brand_id = 'vitalsleep-clinic' and slug = 'sleeptest-health-sleep-apnea';
  if n_sem <> 14 then raise exception 'W40b: expected 14 semantics, got %', n_sem; end if;
  select count(*) into n_held from public.seo_website_page_master p, w40b_kw w
   where lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::' || w.kw) = any(p.semantic_keywords_fps)
      or p.target_keyword_fp = lower('VitalSleep Clinic::🇹🇭 TH – Thailand::🇹🇭 TH – Thai::' || w.kw);
  if n_held <> 6 then raise exception 'W40b: expected 6 keywords held by exactly this page, got %', n_held; end if;
end $$;

commit;
