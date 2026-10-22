-- W3.1: entity dedupe (DR-042 procedure; decisions reviewed 2026-10-22, DR-078)
-- Source decisions: /Volumes/SSD NN/CLAUDE AI/tmp/entity-dedupe-2026-10-22.json (138 decisions, 95 clusters).
-- Applied here: duplicate merges (high/medium confidence), alias removals, parent/child is_a links.
-- Operator 2026-10-22: vth MBM module rows stay separate and get is_a to the shared concept instead of a merge.
-- Not applied: 2 "unsure" clusters (airway-biomapping vs mbm-airway-analysis; muscle- vs tmj-posture-recovery)
--   and 1 low-confidence alias removal (ไม่ต้องสำรองจ่าย) — left for a human.
-- HOW TO RUN: paste the whole file into the Supabase SQL editor, run once. Single transaction.
-- Do not re-run: STEP 1 creates the backup tables and a second run stops there.
-- Rollback net: bak_w31_20261022_{graph,rels,pages,kw,ext}.

begin;

-- generated from entity-dedupe-2026-10-22.json: 21 core merges, 7 MBM modules kept separate (is_a), 106 alias removals, 53 parent/child links
create temp table _m(loser text primary key, winner text not null, why text) on commit drop;
insert into _m values
  ('facial-change-mouth-breathing', 'adenoid-face', 'Both describe adenoid face / long-face changes from chronic mouth breathing; same condition.'),
  ('gbt-airflow', 'airflow-air-polishing', 'Both rows are the EMS Airflow air-polishing device (device type, dev ext).'),
  ('airway-monitoring', 'airway-assessment-3d', 'Both are CBCT-based 3D volumetric upper-airway measurement procedures under OSA; monitoring is the same scan repeated.'),
  ('pediatric-extraction', 'baby-tooth-extraction', 'Both are extraction of primary teeth in children, same parent tooth-extraction.'),
  ('wisdom-tooth-removal', 'wisdom-tooth-extraction', 'Same procedure (third molar extraction), identical aliases.'),
  ('cbct-technology', 'cbct-scan', 'All three are cone-beam CT imaging; technology row and MBM module row duplicate the established CBCT scan entity.'),
  ('cosmetic-bonding', 'dental-bonding', '''Cosmetic bonding'' is a common synonym of dental (composite) bonding; summaries describe the same resin repair.'),
  ('dental-phobia', 'dental-anxiety-adult', 'Same condition (dental anxiety/phobia); already flagged as a true duplicate by Q-id collision audit.'),
  ('pediatric-dental-anxiety', 'dental-anxiety-child', 'Same concept: dental fear in children.'),
  ('dental-laser-therapy', 'laser-dentistry', 'Both mean using lasers in dental treatment (practice), distinct from the laser device rows.'),
  ('pit-fissure-sealant', 'dental-sealant', 'Pit and fissure sealant is the same treatment as dental sealant.'),
  ('medication-oral', 'drug-oral-effects', 'Both cover side effects of medications on oral health (dry mouth, gum overgrowth).'),
  ('facial-rejuvenation-program', 'non-surgical-facial', 'Loser''s alias is the canonical''s exact name; same non-surgical RF facial rejuvenation.'),
  ('endodontic-treatment', 'root-canal-treatment', 'Same treatment (Q-id collision audit flagged as true duplicate); drop practitioner/laser aliases.'),
  ('senior-dental', 'geriatric-dentistry', 'Same field: dental care for the elderly; identical aliases.'),
  ('gingival-swelling', 'gum-swelling', 'Identical concept and aliases (swollen gums / เหงือกบวม); type differs only by labelling.'),
  ('gum-surgery', 'periodontal-surgery', 'Both rows describe periodontal flap surgery; identical aliases.'),
  ('oral-surgery', 'omfs', 'Thin ''Oral Surgery'' hub row duplicates the OMFS specialty, which already aliases ''oral surgery''.'),
  ('pncl-philosophy', 'pncl-medicine', 'Same vth-biodent PNCL framework; philosophy row aliases ''PNCL medicine''.'),
  ('regenerative-protocol-facial', 'regenerative-prf', 'Both are PRF facial regenerative protocol; names near-identical.'),
  ('zirconia', 'zirconia-material', 'Both are zirconium dioxide dental ceramic; drop loser''s generic ''เซรามิก''.');

create temp table _rm(entity_fp text, alias text) on commit drop;
insert into _rm values
  ('3d-printer-aligner', 'dental 3D printer'),
  ('ai-remote-monitoring', 'เจ้าเดียวในไทย'),
  ('dental-monitoring-ai', 'เจ้าเดียวในไทย'),
  ('nemostudio', 'เจ้าเดียวในไทย'),
  ('gbt-airflow', 'Guided Biofilm Therapy'),
  ('gbt-airflow-prophylaxis', 'GBT Airflow'),
  ('all-on-x', 'All-on-4'),
  ('all-on-x', 'All-on-6'),
  ('anesthetic-allergy-screening', 'แพ้ยาง'),
  ('aoralscan', 'intraoral scanner'),
  ('bisphosphonate-screening', 'Bisphosphonates'),
  ('blue-diamond-implant', 'Korean implant'),
  ('osstem-implant-co', 'ออสเท็ม'),
  ('brain-fog-oral', 'brain fog'),
  ('bruxism', 'นอนกัดฟัน'),
  ('mbm-bruxism-evaluation', 'bruxism evaluation'),
  ('composite-filling', 'อุดฟัน'),
  ('dental-filling', 'composite filling'),
  ('gum-graft', 'connective tissue graft'),
  ('conscious-sedation', 'sedation dentistry'),
  ('conscious-sedation', 'nitrous oxide'),
  ('tooth-fracture', 'cracked tooth'),
  ('crowding', 'ฟันเก'),
  ('gingivectomy', 'crown lengthening'),
  ('gingivectomy', 'gingivoplasty'),
  ('self-ligating-braces', 'Damon system'),
  ('self-ligating-braces', 'จัดฟันแบบ Damon'),
  ('dental-crown', 'dental bridge'),
  ('dental-crown', 'สะพานฟัน'),
  ('dental-crown', 'fixed prosthesis'),
  ('dental-crown', 'เดือยฟัน'),
  ('dental-implant-components', 'abutment'),
  ('laser-dentistry', 'dental laser'),
  ('dental-laser-therapy', 'dental laser'),
  ('dental-laser', 'เลเซอร์ทันตกรรม'),
  ('fotona-lightwalker', 'dental laser'),
  ('denture-dissatisfaction', 'loose denture'),
  ('denture-dissatisfaction', 'ฟันปลอมหลวม'),
  ('guided-implant', 'digital implant planning'),
  ('pediatric-orthodontics', 'Phase I orthodontics'),
  ('early-orthodontic-intervention', 'จัดฟันเด็ก'),
  ('missing-tooth', 'edentulism'),
  ('single-missing-tooth', 'ฟันหลุด'),
  ('facial-rejuvenation-program', 'Emface / Exion'),
  ('facial-rejuvenation-program', 'Programme Component'),
  ('non-surgical-facial', 'Emface'),
  ('non-surgical-facial', 'facial toning'),
  ('non-surgical-facial', 'Exion'),
  ('endodontic-treatment', 'endodontist'),
  ('endodontic-treatment', 'laser root canal'),
  ('precision-clinical-dentistry', 'evidence-based dentistry'),
  ('orthodontic-retainer', 'clear retainer'),
  ('fluoride-treatment', 'ฟลูออไรด์'),
  ('remineralization', 'fluoride treatment'),
  ('frenectomy', 'ลิ้นติด'),
  ('functional-metabolic-panel', 'hs-CRP IL-6'),
  ('mbm-genetic-risk-panel', 'ตรวจพันธุกรรม'),
  ('mbm-hrv', 'heart rate variability'),
  ('mbm-hrv', 'ความแปรปรวนอัตราหัวใจ'),
  ('immunosuppression-screening', 'Immunosuppression'),
  ('impacted-tooth', 'impacted wisdom tooth'),
  ('impacted-wisdom-tooth', 'ฟันคุด'),
  ('impacted-wisdom-tooth', 'ฟันฝัง'),
  ('implant-denture', 'overdenture'),
  ('overdenture', 'ฟันปลอมบนรากเทียม'),
  ('overdenture', 'implant-retained denture'),
  ('material-allergy-screening', 'Titanium'),
  ('tmj-assessment', '3D TMJ Analysis'),
  ('neodent-implant', 'Straumann Group'),
  ('straumann-group', 'สเตร๊าแมน'),
  ('nobel-biocare-implant', 'Nobel Biocare'),
  ('nobel-biocare', 'โนเบล ไบโอแคร์'),
  ('nobel-biocare', 'Envista'),
  ('ormco', 'Envista'),
  ('pulp-necrosis', 'dead tooth'),
  ('pulp-necrosis', 'ฟันตาย'),
  ('oral-surgery', 'hub'),
  ('precision-diagnostics', 'hub'),
  ('thumb-sucking-effect', 'ดูดนิ้ว'),
  ('orthodontics-specialty', 'orthodontist'),
  ('orthopostural', 'postural rehabilitation'),
  ('pediatric-breathing', 'pediatric airway obstruction'),
  ('pediatric-airway', 'ปัญหาหายใจในเด็ก'),
  ('pediatric-crown', 'SSC'),
  ('pediatric-crown', 'stainless steel crown'),
  ('ssc-pedo', 'ครอบฟันเด็ก'),
  ('pediatric-dental-trauma', 'tooth avulsion'),
  ('pediatric-pulpotomy', 'pulpotomy'),
  ('pediatric-pulpotomy', 'pulpectomy'),
  ('periodontal-disease', 'periodontitis'),
  ('periodontitis', 'periodontal disease'),
  ('periodontitis', 'โรคปริทันต์'),
  ('periodontitis', 'โรคเหงือก'),
  ('periodontics', 'periodontist'),
  ('periodontics', 'gum specialist'),
  ('physiotherapy', 'นักกายภาพบำบัด'),
  ('sleep-study', 'polysomnography'),
  ('pregnancy-gum-disease', 'pregnancy gingivitis'),
  ('root-canal-file', 'rotary file'),
  ('tooth-shape-anomaly', 'microdontia'),
  ('tooth-shape-anomaly', 'ฟันเล็ก'),
  ('tooth-shape-anomaly', 'ฟันสั้น'),
  ('tmj-disorder', 'ข้อต่อขากรรไกร'),
  ('tmj-disorder', 'TMJ pain'),
  ('tooth-wear', 'ฟันสึกกร่อน'),
  ('zirconia', 'เซรามิก');

create temp table _pc(child text, parent text) on commit drop;
insert into _pc values
  ('3d-printer-aligner', 'dental-3d-printing'),
  ('all-on-4', 'all-on-x'),
  ('all-on-5', 'all-on-x'),
  ('all-on-6', 'all-on-x'),
  ('aoralscan', 'intraoral-scanner'),
  ('wisdom-tooth-extraction', 'tooth-extraction'),
  ('baby-tooth-extraction', 'tooth-extraction'),
  ('brain-fog-oral', 'brain-fog'),
  ('sleep-bruxism', 'bruxism'),
  ('bruxism-emg', 'bruxism-assessment'),
  ('composite-filling', 'dental-filling'),
  ('connective-tissue-graft', 'gum-graft'),
  ('ice-berg-technique', 'connective-tissue-graft'),
  ('conscious-sedation', 'sedation-dentistry'),
  ('pediatric-sedation', 'sedation-dentistry'),
  ('corticosteroid-injection-tmj', 'tmj-injection'),
  ('cracked-tooth', 'tooth-fracture'),
  ('crowding', 'malocclusion'),
  ('laser-gingivectomy', 'gingivectomy'),
  ('damon-system', 'self-ligating-braces'),
  ('implant-abutment', 'dental-implant-components'),
  ('fotona-lightwalker', 'dental-laser'),
  ('pediatric-sealant', 'dental-sealant'),
  ('early-orthodontic-intervention', 'pediatric-orthodontics'),
  ('single-missing-tooth', 'missing-tooth'),
  ('rct-retreatment', 'root-canal-treatment'),
  ('removable-retainer', 'orthodontic-retainer'),
  ('full-arch-immediate-loading', 'immediate-loading'),
  ('mbm-genetic-risk-panel', 'genetic-testing'),
  ('impacted-wisdom-tooth', 'impacted-tooth'),
  ('implant-denture', 'overdenture'),
  ('laser-perio', 'periodontal-treatment'),
  ('tmj-assessment-3d', 'tmj-assessment'),
  ('mbm-tmj-biomechanics-assessment', 'tmj-assessment'),
  ('pediatric-myofunction', 'myofunctional-therapy'),
  ('non-vital-tooth', 'pulp-necrosis'),
  ('postural-rehab', 'orthopostural'),
  ('pediatric-airway', 'pediatric-breathing'),
  ('ssc-pedo', 'pediatric-crown'),
  ('pediatric-pulpotomy', 'pulpotomy'),
  ('periodontitis', 'periodontal-disease'),
  ('polysomnography', 'sleep-study'),
  ('rotary-endodontic-system', 'root-canal-file'),
  ('short-teeth', 'tooth-shape-anomaly'),
  ('tmj-pain', 'tmj-disorder'),
  ('tooth-erosion', 'tooth-wear'),
  ('mbm-bruxism-evaluation', 'bruxism-emg'),
  ('mbm-cbct', 'cbct-scan'),
  ('mbm-inflammation-panel', 'inflammation-panel'),
  ('mbm-hrv', 'hrv-assessment'),
  ('mbm-occlusal-mapping', 'occlusal-mapping'),
  ('mbm-oral-microbiome-testing', 'microbiome-testing'),
  ('mbm-sleep-breathing-screening', 'sleep-screening');

-- ── STEP 0 · views: W3.0 made entity_lifecycle Title case; both duplicate views compared lowercase ─
create or replace view public.v_entity_near_duplicates as
 select a.fingerprint as entity_a, a.entity_name as name_a, a.topic_cluster_id as cluster_a, a.brand_scope as scope_a,
        b.fingerprint as entity_b, b.entity_name as name_b, b.topic_cluster_id as cluster_b, b.brand_scope as scope_b,
        round(similarity(lower(a.entity_name), lower(b.entity_name))::numeric, 3) as name_similarity,
        a.topic_cluster_id is distinct from b.topic_cluster_id as cluster_conflict
   from seo_entity_graph a
   join seo_entity_graph b on a.fingerprint < b.fingerprint
  where lower(coalesce(a.entity_lifecycle, '')) not in ('merged', 'dropped')
    and lower(coalesce(b.entity_lifecycle, '')) not in ('merged', 'dropped')
    and similarity(lower(a.entity_name), lower(b.entity_name)) > 0.62;

create or replace view public.v_entity_semantic_duplicates as
 select ea.entity_fp as entity_a, ga.entity_name as name_a, ga.topic_cluster_id as cluster_a, ga.brand_scope as scope_a,
        eb.entity_fp as entity_b, gb.entity_name as name_b, gb.topic_cluster_id as cluster_b, gb.brand_scope as scope_b,
        round((ea.embedding <=> eb.embedding)::numeric, 4) as cosine_distance,
        round(similarity(lower(ga.entity_name), lower(gb.entity_name))::numeric, 3) as name_similarity,
        ga.topic_cluster_id is distinct from gb.topic_cluster_id as cluster_conflict
   from seo_entity_embeddings ea
   join seo_entity_embeddings eb on ea.entity_fp < eb.entity_fp
   join seo_entity_graph ga on ga.entity_fingerprint = ea.entity_fp
   join seo_entity_graph gb on gb.entity_fingerprint = eb.entity_fp
  where lower(coalesce(ga.entity_lifecycle, '')) not in ('merged', 'dropped')
    and lower(coalesce(gb.entity_lifecycle, '')) not in ('merged', 'dropped')
    and (ea.embedding <=> eb.embedding) < 0.18;

-- guard: every fingerprint in the maps must exist and be active
do $g$
declare bad text;
begin
  select string_agg(fp, ', ') into bad from (
    select loser fp from _m union select winner from _m union select child from _pc union select parent from _pc
    union select entity_fp from _rm) x
  where not exists (select 1 from seo_entity_graph g where g.entity_fingerprint = x.fp
                    and lower(coalesce(g.entity_lifecycle, '')) not in ('merged', 'dropped'));
  if bad is not null then raise exception 'W3.1 abort: missing or inactive entities: %', bad; end if;
end $g$;

-- ── STEP 1 · backups (rollback net) ───────────────────────────────────────────
create table public.bak_w31_20261022_graph as select * from seo_entity_graph;
create table public.bak_w31_20261022_rels as select * from seo_entity_relationships
  where from_entity_fp in (select loser from _m) or to_entity_fp in (select loser from _m);
create table public.bak_w31_20261022_pages as select id, primary_entity_fp, related_entities_fps, reconciliation_notes
  from seo_website_page_master
  where primary_entity_fp in (select loser from _m) or related_entities_fps && (select array_agg(loser) from _m);
create table public.bak_w31_20261022_kw as select fingerprint, primary_entity_fp
  from seo_x_ads_keywords_contextual_master where primary_entity_fp in (select loser from _m);
create table public.bak_w31_20261022_ext as
  select 'condition' t, entity_fp, to_jsonb(x) row from seo_entity_condition x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'symptom', entity_fp, to_jsonb(x) from seo_entity_symptom x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'procedures', entity_fp, to_jsonb(x) from seo_entity_procedures x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'devices', entity_fp, to_jsonb(x) from seo_entity_devices x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'drug', entity_fp, to_jsonb(x) from seo_entity_drug x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'anatomy', entity_fp, to_jsonb(x) from seo_entity_anatomy x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'organization', entity_fp, to_jsonb(x) from seo_entity_organization x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'product', entity_fp, to_jsonb(x) from seo_entity_product x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'ingredients', entity_fp, to_jsonb(x) from seo_entity_ingredients x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'lab_test', entity_fp, to_jsonb(x) from seo_entity_lab_test x where entity_fp in (select loser from _m union select winner from _m)
  union all select 'embeddings', entity_fp, to_jsonb(x) - 'embedding' from seo_entity_embeddings x where entity_fp in (select loser from _m);
alter table public.bak_w31_20261022_graph enable row level security;
alter table public.bak_w31_20261022_rels  enable row level security;
alter table public.bak_w31_20261022_pages enable row level security;
alter table public.bak_w31_20261022_kw    enable row level security;
alter table public.bak_w31_20261022_ext   enable row level security;

-- ── STEP 2 · alias removals (wrong_alias / parent_child), before any alias is lifted ─
update seo_entity_graph g
set aliases = (select nullif(string_agg(btrim(a), ', ' order by pos), '')
               from unnest(string_to_array(g.aliases, ',')) with ordinality t(a, pos)
               where btrim(a) <> '' and btrim(a) not in (select r.alias from _rm r where r.entity_fp = g.entity_fingerprint)),
    last_graph_update = now()
where g.entity_fingerprint in (select entity_fp from _rm);

-- ── STEP 3 · lift what the losers hold onto the winner (DR-042 §5 / DR-046) ──
-- 3a aliases: winner's + loser's name + loser's aliases, de-duplicated (case-insensitive), winner's name excluded
update seo_entity_graph w
set aliases = (select nullif(string_agg(a, ', ' order by ord, pos), '')
               from (select distinct on (lower(a)) a, ord, pos
                     from (select btrim(translate(t.x, '{}"', '')) a, src.ord, t.pos
                           from (select 1 as ord, w.aliases as txt
                                 union all
                                 select 2, (select string_agg(l.entity_name || ', ' || coalesce(l.aliases, ''), ', ')
                                            from _m m join seo_entity_graph l on l.entity_fingerprint = m.loser
                                            where m.winner = w.entity_fingerprint)) src
                           cross join lateral unnest(string_to_array(src.txt, ',')) with ordinality t(x, pos)) z
                     where a <> '' and lower(a) <> lower(w.entity_name)
                     order by lower(a), ord, pos) d),
    competing_entities = btrim(coalesce(w.competing_entities, '') || ' merged_from 2026-10-22 (W3.1 dedupe): ' ||
      (select string_agg(m.loser, ', ') from _m m where m.winner = w.entity_fingerprint)),
    last_graph_update = now()
where w.entity_fingerprint in (select winner from _m);

-- 3b summary, wikidata, wikipedia, schema type: only where the winner is empty / shorter
update seo_entity_graph w
set ai_entity_summary = case when length(coalesce(l.ai_entity_summary, '')) > length(coalesce(w.ai_entity_summary, ''))
                             then l.ai_entity_summary else w.ai_entity_summary end,
    wikidata_id     = coalesce(nullif(w.wikidata_id, ''), nullif(l.wikidata_id, '')),
    wikipedia_url   = coalesce(nullif(w.wikipedia_url, ''), nullif(l.wikipedia_url, '')),
    schema_org_type = coalesce(nullif(w.schema_org_type, ''), nullif(l.schema_org_type, ''))
from _m m join seo_entity_graph l on l.entity_fingerprint = m.loser
where w.entity_fingerprint = m.winner;

-- ── STEP 4 · repoint scalar references ────────────────────────────────────────
update seo_website_page_master p
set primary_entity_fp = m.winner,
    reconciliation_notes = case when coalesce(p.reconciliation_notes, '') = '' then '' else p.reconciliation_notes || ' | ' end ||
      '2026-10-22 W3.1 · primary entity ' || m.loser || ' merged into ' || m.winner || ' (DR-042 dedupe)'
from _m m where p.primary_entity_fp = m.loser;
update seo_x_ads_keywords_contextual_master k set primary_entity_fp = m.winner from _m m where k.primary_entity_fp = m.loser;
update seo_service_prices s        set entity_fp = m.winner        from _m m where s.entity_fp = m.loser;
update seo_media_assets s          set entity_fp = m.winner        from _m m where s.entity_fp = m.loser;
update seo_llm_query_simulations s set target_entity_fp = m.winner from _m m where s.target_entity_fp = m.loser;
update seo_entity_graph e set parent_entity_fp = m.winner from _m m where e.parent_entity_fp = m.loser and e.entity_fingerprint <> m.winner;
update seo_entity_graph set parent_entity_fp = null where parent_entity_fp = entity_fingerprint;

-- ── STEP 5 · repoint array references (order kept, duplicates dropped) ────────
create temp table _arr_map on commit drop as select loser, winner from _m;
create or replace function pg_temp.remap(arr text[]) returns text[] language sql stable as $f$
  select array_agg(v order by first_pos) from (
    select coalesce(m.winner, x) v, min(pos) first_pos
    from unnest(arr) with ordinality t(x, pos) left join _arr_map m on m.loser = x
    group by coalesce(m.winner, x)) s
$f$;
update seo_website_page_master p
set related_entities_fps = pg_temp.remap(p.related_entities_fps),
    reconciliation_notes = case when coalesce(p.reconciliation_notes, '') = '' then '' else p.reconciliation_notes || ' | ' end ||
      '2026-10-22 W3.1 · related entities remapped after dedupe'
where p.related_entities_fps && (select array_agg(loser) from _m);
update seo_entity_graph e set related_entities_fps = pg_temp.remap(e.related_entities_fps)
  where e.related_entities_fps && (select array_agg(loser) from _m);
update seo_entity_graph e set related_entities_fps = array_remove(e.related_entities_fps, e.entity_fingerprint)
  where e.entity_fingerprint = any(e.related_entities_fps);
update seo_entity_condition c  set symptom_entities_fps = pg_temp.remap(c.symptom_entities_fps)
  where c.symptom_entities_fps && (select array_agg(loser) from _m);
update seo_entity_procedures c set contraindication_entities_fps = pg_temp.remap(c.contraindication_entities_fps)
  where c.contraindication_entities_fps && (select array_agg(loser) from _m);
update seo_reviews r set mentioned_entities_fps = pg_temp.remap(r.mentioned_entities_fps)
  where r.mentioned_entities_fps && (select array_agg(loser) from _m);

-- ── STEP 6 · edges: drop what would become a self-edge or a duplicate, then repoint ─
delete from seo_entity_relationships r
where coalesce((select winner from _m where loser = r.from_entity_fp), r.from_entity_fp)
    = coalesce((select winner from _m where loser = r.to_entity_fp), r.to_entity_fp)
  and (r.from_entity_fp in (select loser from _m) or r.to_entity_fp in (select loser from _m));
delete from seo_entity_relationships r
where (r.from_entity_fp in (select loser from _m) or r.to_entity_fp in (select loser from _m))
  and exists (
    select 1 from seo_entity_relationships q
    where q.id <> r.id and q.edge_type = r.edge_type
      and coalesce((select winner from _m where loser = q.from_entity_fp), q.from_entity_fp)
        = coalesce((select winner from _m where loser = r.from_entity_fp), r.from_entity_fp)
      and coalesce((select winner from _m where loser = q.to_entity_fp), q.to_entity_fp)
        = coalesce((select winner from _m where loser = r.to_entity_fp), r.to_entity_fp)
      -- keep the edge already on the winner; between two loser edges keep the lower id
      and (not (q.from_entity_fp in (select loser from _m) or q.to_entity_fp in (select loser from _m)) or q.id < r.id));
update seo_entity_relationships r set from_entity_fp = m.winner, updated_at = now() from _m m where r.from_entity_fp = m.loser;
update seo_entity_relationships r set to_entity_fp   = m.winner, updated_at = now() from _m m where r.to_entity_fp   = m.loser;

-- ── STEP 7 · extension tables: winner without a row inherits one loser row; codes fill blanks ─
-- (when both hold a row, the loser's list columns stay only in bak_w31_20261022_ext — see the report)
update seo_entity_condition w set
  icd10_code = coalesce(w.icd10_code, l.icd10_code), icd10_cm_code = coalesce(w.icd10_cm_code, l.icd10_cm_code),
  icd11_code = coalesce(w.icd11_code, l.icd11_code), mesh_id = coalesce(w.mesh_id, l.mesh_id),
  snomed_ct_id = coalesce(w.snomed_ct_id, l.snomed_ct_id), umls_cui = coalesce(w.umls_cui, l.umls_cui),
  wikidata_qid = coalesce(w.wikidata_qid, l.wikidata_qid)
from _m m join seo_entity_condition l on l.entity_fp = m.loser where w.entity_fp = m.winner;
update seo_entity_symptom w set
  icd10_code = coalesce(w.icd10_code, l.icd10_code), icd11_code = coalesce(w.icd11_code, l.icd11_code),
  mesh_id = coalesce(w.mesh_id, l.mesh_id), snomed_ct_id = coalesce(w.snomed_ct_id, l.snomed_ct_id),
  umls_cui = coalesce(w.umls_cui, l.umls_cui), wikidata_qid = coalesce(w.wikidata_qid, l.wikidata_qid)
from _m m join seo_entity_symptom l on l.entity_fp = m.loser where w.entity_fp = m.winner;

do $x$
declare t text;
begin
  foreach t in array array['seo_entity_condition','seo_entity_symptom','seo_entity_procedures','seo_entity_devices',
                           'seo_entity_drug','seo_entity_anatomy','seo_entity_organization','seo_entity_product',
                           'seo_entity_ingredients','seo_entity_lab_test'] loop
    execute format($q$
      update %1$I l set entity_fp = m.winner
      from _m m
      where l.entity_fp = m.loser
        and not exists (select 1 from %1$I w where w.entity_fp = m.winner)
        and m.loser = (select min(m2.loser) from _m m2 join %1$I l2 on l2.entity_fp = m2.loser where m2.winner = m.winner)$q$, t);
    execute format('delete from %I where entity_fp in (select loser from _m)', t);
  end loop;
end $x$;

-- ── STEP 8 · embeddings of the losers go (a merged row must not surface in the similarity views) ─
delete from seo_entity_embeddings where entity_fp in (select loser from _m);

-- ── STEP 9 · close the loser rows — never delete (DR-042 §5) ─────────────────
update seo_entity_graph l
set entity_lifecycle = 'Merged',
    ai_entity_summary = '[MERGED 2026-10-22 -> ' || m.winner || '] ' || coalesce(l.ai_entity_summary, ''),
    competing_entities = 'MERGED 2026-10-22 into ' || m.winner || ' (W3.1 dedupe: ' || m.why || '). Do not point pages here.',
    last_graph_update = now()
from _m m where l.entity_fingerprint = m.loser;

-- ── STEP 10 · parent / child: set the parent where empty, and an is_a edge child -> parent ─
update seo_entity_graph c set parent_entity_fp = p.parent, last_graph_update = now()
from _pc p where c.entity_fingerprint = p.child and c.parent_entity_fp is null;
insert into seo_entity_relationships (from_entity_fp, to_entity_fp, edge_type, edge_note, status, load_source)
select p.child, p.parent, 'is_a', '[W3.1 2026-10-22] parent/child from duplicate review', 'active', 'w31_entity_dedupe'
from _pc p
where not exists (select 1 from seo_entity_relationships r
                  where r.from_entity_fp = p.child and r.to_entity_fp = p.parent and r.edge_type = 'is_a');

-- ── report: winners whose loser also held an extension row (lists not merged, kept in backup) ─
-- select b.t, m.loser, m.winner from bak_w31_20261022_ext b join _m m on m.loser = b.entity_fp
--  where exists (select 1 from bak_w31_20261022_ext w where w.t = b.t and w.entity_fp = m.winner);

commit;
