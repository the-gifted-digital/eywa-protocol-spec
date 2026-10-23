-- W3.7c · page primary-entity review (live pages whose target keyword entity differs from the page entity) (DRAFT not applied) · 2026-10-23
-- Queue: 65 live pages (smile-scape-clinic 34 · vth-biodent 18 · deezy-dental 13) after W3.4b moved keywords to their entity.
-- Decisions: tmp/w37c/relinks.tsv + report. Only relink_page (36) and relink_keyword (2) rows are applied here.
-- keep_both / retarget / human rows are NOT touched.
-- Page relink: primary_entity_fp -> new entity · primary_entity_name refreshed from seo_entity_graph (cached copy read by brand bridges)
--   · old entity appended to related_entities_fps only when add_related is set and not already present.
-- Every UPDATE is guarded on fingerprint AND the old value · the final DO block aborts the whole run if any guard missed.
-- trg_page_keyword_no_reuse fires only on target_keyword_fp/semantic_keywords_fps/status/brand_id · none touched here.
-- Keyword primary_entity_name is kept by trg_keyword_entity_name (W3.4a).
-- BRAND REPOS: vth-biodent check:entity-binding reads the live DB · apply the YAML edits in tmp/w37c/w37c_repo_edits.csv in the same window.
-- Rollback net: public.bak_w37c_20261023 (src + pk + to_jsonb row).

begin;

create temp table _w37c_page (fp text primary key, old_fp text not null, new_fp text not null, add_related text, why text) on commit drop; -- page relinks
insert into _w37c_page (fp, old_fp, new_fp, add_related, why) values
  ('deezy-5.6.6', 'tooth-fracture', 'pediatric-dental-trauma', 'tooth-fracture', 'Child trauma page, keyword entity Pediatric Dental Trauma is the exact topic'),
  ('deezy-6.7.8', 'bruxism', 'sleep-bruxism', 'bruxism', 'Title is about grinding while asleep = Sleep Bruxism'),
  ('deezy-6.1.30', 'dental-plaque', 'preventive-dentistry', 'dental-plaque', 'Caries prevention article not a plaque page'),
  ('deezy-3.4.14', 'gum-contouring', 'gummy-smile', 'gum-contouring', 'Page treats gummy smile by cause with several options, condition is the main thing'),
  ('deezy-3.11.2', 'pediatric-dentistry', 'scaling-polishing', 'pediatric-dentistry', 'Kids scaling page, specialty umbrella too broad'),
  ('deezy-6.1.5', 'periodontitis', 'periodontal-disease', 'periodontitis', 'Gum disease guide covers gingivitis and periodontitis = umbrella'),
  ('smilescape-3.9.2.2', 'dental-veneer', 'composite-veneer', 'dental-veneer', 'Exact subtype page'),
  ('smilescape-3.1.7', 'smilescape-dental-clinic', 'dental-checkup', null, 'Exam page is about the checkup not the clinic'),
  ('smilescape-3.10.4', 'orthodontic-treatment', 'metal-braces', 'orthodontic-treatment', 'Metal braces page'),
  ('smilescape-3.5.2', 'dental-crown', 'dental-bridge', 'dental-crown', 'Bridge page not crown'),
  ('smilescape-5.21.5', 'smilescape-dental-clinic', 'implantologist', null, 'How to judge an implant dentist = Implantologist'),
  ('smilescape-6.2.1.3', 'dental-implant', 'dental-implant-components', 'dental-implant', 'Page explains implant parts (part_of Dental Implant)'),
  ('smilescape-5.21.3', 'smilescape-dental-clinic', 'general-dentist', null, 'General vs specialist explainer not about the clinic'),
  ('smilescape-6.2.4.1', 'periodontitis', 'gingivitis', 'periodontitis', 'Reversible stage = Gingivitis, keyword matches'),
  ('smilescape-5.11', 'periodontitis', 'periodontal-disease', 'periodontitis', 'Gum problems hub = umbrella Periodontal Disease'),
  ('smilescape-3.7.4', 'gum-graft', 'gum-recession', 'gum-graft', 'Condition pillar on recession, graft is one treatment'),
  ('smilescape-5.5.5', 'gum-contouring', 'gummy-smile', 'gum-contouring', 'Problem page with several fixes'),
  ('smilescape-3.5.1.3', 'dental-crown', 'implant-crown', 'dental-crown', 'Implant crown page'),
  ('smilescape-3.1.3', 'cbct-scan', 'dental-xray', null, 'Intraoral 2D x-ray is not CBCT'),
  ('smilescape-5.15.3', 'tmj-disorder', 'tmj-clicking', 'tmj-disorder', 'Symptom page for clicking'),
  ('smilescape-5.15.2', 'tmj-disorder', 'jaw-lock', 'tmj-disorder', 'Symptom page for locked jaw'),
  ('smilescape-5.6.7', 'periodontitis', 'loose-tooth', 'periodontitis', 'Symptom page for loose tooth'),
  ('smilescape-5.1.2', 'missing-tooth', 'multiple-missing-teeth', 'missing-tooth', 'Several missing teeth page'),
  ('smilescape-3.8', 'tooth-extraction', 'omfs', 'tooth-extraction', 'OMFS hub not extraction only'),
  ('smilescape-3.5', 'dental-crown', 'prosthodontics', 'dental-crown', 'Prosthetic hub covers crowns bridges dentures'),
  ('smilescape-3.9.5', 'digital-smile-design', 'smile-makeover', 'digital-smile-design', 'Smile makeover combines treatments, DSD is one tool'),
  ('smilescape-5.16.1', 'tooth-fracture', 'tooth-wear', null, 'Attrition abfraction erosion = Tooth Wear'),
  ('smilescape-5.6.1', 'dental-caries', 'toothache', 'dental-caries', 'Toothache has many causes, caries is one'),
  ('smilescape-5.5.1', 'teeth-whitening', 'tooth-discoloration', 'teeth-whitening', 'Problem-led page asks whether whitening helps'),
  ('vth-6.8.16', 'airflow-air-polishing', 'gbt-airflow-prophylaxis', 'airflow-air-polishing', 'Compares cleaning procedures not the device'),
  ('vth-3.7.21.7', 'pediatric-dentistry', 'pediatric-orthodontics', 'pediatric-dentistry', 'Title asks when a 7-year-old should start orthodontics = Pediatric Orthodontics, specialty umbrella too broad (growth-monitoring rejected: no contraindication list so strict check:clinical would fail)'),
  ('vth-5.6.10', 'mouth-breathing', 'pediatric-mouth-breathing', 'mouth-breathing', 'Children-only page = Pediatric Mouth Breathing (is_a Mouth Breathing)'),
  ('vth-6.2.3.5', 'airway-assessment-3d', 'osa-airway-narrowing', 'airway-assessment-3d', 'Page explains the narrowing itself not the scan'),
  ('vth-3.7.13.3', 'dental-crown', 'full-mouth-rehab', 'dental-crown', 'Full-mouth reconstruction with crowns bridges onlays'),
  ('vth-6.2.7.7', 'structural-facial-aging', 'premature-wrinkles', 'structural-facial-aging', 'Page leads with premature wrinkles, structure is the angle'),
  ('vth-3.5.3', 'tmj-assessment', 'tmj-assessment-3d', 'tmj-assessment', 'Page is 3D TMJ Analysis (is_a TMJ Assessment)'); -- 36 page rows

create temp table _w37c_kw (fp text primary key, old_fp text not null, new_fp text not null, why text) on commit drop; -- keyword relinks
insert into _w37c_kw (fp, old_fp, new_fp, why) values
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::หมอฟันเก่งรากฟันเทียม ดูยังไง', 'dr-woraphat-jarangkul', 'implantologist', 'How to judge an implant dentist is about the Implantologist role not one named doctor'),
  ('smile scape clinic::🇹🇭 th – thailand::🇹🇭 th – thai::ทันตแพทย์เฉพาะทาง ต่างจากทั่วไป', 'dr-woraphat-jarangkul', 'general-dentist', 'General vs specialist dentist comparison is not about one named doctor'); -- 2 keyword rows

create table public.bak_w37c_20261023 as
select 'seo_website_page_master'::text as src, p.page_fingerprint as pk, to_jsonb(p) as row_data, now() as backed_up_at
  from public.seo_website_page_master p join _w37c_page v on v.fp = p.page_fingerprint
union all
select 'seo_x_ads_keywords_contextual_master', k.fingerprint, to_jsonb(k), now()
  from public.seo_x_ads_keywords_contextual_master k join _w37c_kw v on v.fp = k.fingerprint; -- expect 36 + 2 = 38 rows
alter table public.bak_w37c_20261023 enable row level security; -- same as earlier bak tables

update public.seo_website_page_master p
   set primary_entity_fp = v.new_fp,
       primary_entity_name = g.entity_name,
       related_entities_fps = case
         when v.add_related is null or v.add_related = any (coalesce(p.related_entities_fps, '{}'::text[])) then p.related_entities_fps
         else coalesce(p.related_entities_fps, '{}'::text[]) || v.add_related
       end,
       updated_at = now()
  from _w37c_page v
  join public.seo_entity_graph g on g.entity_fingerprint = v.new_fp
 where p.page_fingerprint = v.fp and p.primary_entity_fp = v.old_fp and p.status not in ('Merged','Dropped'); -- expect 36

update public.seo_x_ads_keywords_contextual_master k
   set primary_entity_fp = v.new_fp, updated_at = now()
  from _w37c_kw v
 where k.fingerprint = v.fp and k.primary_entity_fp = v.old_fp; -- expect 2

do $$
declare n_bak int; n_pg int; n_rel int; n_kw int; n_live int; n_tgt int;
begin
  select count(*) into n_bak from public.bak_w37c_20261023;
  select count(*) into n_pg from public.seo_website_page_master p join _w37c_page v on v.fp = p.page_fingerprint
   where p.primary_entity_fp = v.new_fp
     and p.primary_entity_name = (select g.entity_name from public.seo_entity_graph g where g.entity_fingerprint = v.new_fp);
  select count(*) into n_rel from public.seo_website_page_master p join _w37c_page v on v.fp = p.page_fingerprint
   where v.add_related is null
      or (v.add_related = any (p.related_entities_fps)
          and (select count(*) from unnest(p.related_entities_fps) r where r = v.add_related) = 1);
  select count(*) into n_kw from public.seo_x_ads_keywords_contextual_master k join _w37c_kw v on v.fp = k.fingerprint and k.primary_entity_fp = v.new_fp;
  select count(*) into n_tgt from (select new_fp from _w37c_page union select new_fp from _w37c_kw) t;
  select count(*) into n_live from (select new_fp from _w37c_page union select new_fp from _w37c_kw) t
    join public.seo_entity_graph g on g.entity_fingerprint = t.new_fp and lower(coalesce(g.entity_lifecycle,'')) not in ('merged','dropped');
  if n_bak <> 38 then raise exception 'W3.7c abort: backup rows % <> 38', n_bak; end if;
  if n_pg <> 36 then raise exception 'W3.7c abort: pages relinked % <> 36', n_pg; end if;
  if n_rel <> 36 then raise exception 'W3.7c abort: related_entities_fps check % <> 36', n_rel; end if;
  if n_kw <> 2 then raise exception 'W3.7c abort: keywords relinked % <> 2', n_kw; end if;
  if n_live <> n_tgt then raise exception 'W3.7c abort: % of % target entities are not live', n_tgt - n_live, n_tgt; end if;
end $$; -- all-or-nothing

commit;
