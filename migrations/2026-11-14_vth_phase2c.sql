-- 2026-11-14 · VTH rubric phase 2c — owners for the 6 keywords released in 2b (operator decided 2026-11-14)
--   นอนกรน อันตรายไหม      -> semantic of snoring-vs-sleep-apnea
--   เหงือก กิน ฟัน         -> semantic of periodontitis
--   จีโนม สุขภาพช่องปาก     -> semantic of genetic-risk-predisposition
--   จัดฟัน ถอนฟันกี่ซี่     -> target of NEW Planned page braces-tooth-extraction (vth-6.2.10.14)
--   mouth biomapping คืออะไร -> target of NEW Planned page mouth-biomapping (vth-3.5.6, MBM hub)
--   เวชศาสตร์ฟื้นฟู ทันตกรรม -> stays released (no volume, no fitting page)
-- New rows copy structural columns from a sibling (orthodontic-elastics / genetic-testing) and
-- override identity, placement, entity and keyword.

create temp table _kw(kw text, fp text) on commit drop;
insert into _kw select k, 'vth biodent::🇹🇭 th – thailand::🇹🇭 th – thai::' || k from unnest(array[
  'นอนกรน อันตรายไหม','เหงือก กิน ฟัน','จีโนม สุขภาพช่องปาก','จัดฟัน ถอนฟันกี่ซี่','mouth biomapping คืออะไร']) k;

do $$
begin
  if (select count(*) from _kw k join public.seo_x_ads_keywords_contextual_master m on m.fingerprint = k.fp) <> 5 then
    raise exception 'keyword fingerprint not found in master';
  end if;
  if exists (select 1 from public.seo_website_page_master p join _kw k
             on p.target_keyword_fp = k.fp or k.fp = any(p.semantic_keywords_fps)) then
    raise exception 'a keyword is already held by a page';
  end if;
  if exists (select 1 from public.seo_website_page_master where page_fingerprint in ('vth-6.2.10.14','vth-3.5.6')
             or (brand_id = 'vth-biodent' and slug in ('braces-tooth-extraction','mouth-biomapping'))) then
    raise exception 'new page fingerprint or slug already taken';
  end if;
end $$;

-- semantics on existing ranking pages
update public.seo_website_page_master d
set semantic_keywords_fps = coalesce(d.semantic_keywords_fps, '{}') || k.fp, updated_at = now(),
    reconciliation_notes = concat_ws(' | ', nullif(d.reconciliation_notes, ''),
      '2026-11-14 PHASE2C: + semantic "' || k.kw || '" (released in 2b, operator-assigned)')
from (values ('snoring-vs-sleep-apnea','นอนกรน อันตรายไหม'),
             ('periodontitis','เหงือก กิน ฟัน'),
             ('genetic-risk-predisposition','จีโนม สุขภาพช่องปาก')) v(slug, kw)
join _kw k on k.kw = v.kw
where d.brand_id = 'vth-biodent' and d.slug = v.slug;

-- new Planned pages
insert into public.seo_website_page_master (
  page_fingerprint, fingerprint, fingerprint_display_name, page_name, slug, cluster_id, status,
  sitemap_section, parent_page_fp, parent_page_name, primary_entity_fp, primary_entity_name,
  target_keyword_fp, content_role, reconciliation_notes, brand_id, brand_name,
  page_type, robots_directive, page_intent_type, node_tier, funnel_stage, priority, page_language,
  translation_status, content_format, schema_markup_type, in_xml_sitemap, strategic_page,
  has_medical_review, page_purpose, index_directive, content_topic_tier, page_category, page_role,
  intent_source_tier, legal_review_required, created_at, updated_at)
select n.pfp, n.fp, right(n.fp, 6) || '::' || n.slug, n.name, n.slug, n.cluster, 'Planned',
  n.section, n.parent, par.page_name, n.entity, n.entity_name,
  k.fp, 'ranking',
  '2026-11-14 PHASE2C: created as owner of "' || k.kw || '" (released from support page in 2b; operator decision); structure copied from ' || s.slug,
  s.brand_id, s.brand_name,
  s.page_type, s.robots_directive, s.page_intent_type, s.node_tier, s.funnel_stage, s.priority, s.page_language,
  s.translation_status, s.content_format, s.schema_markup_type, s.in_xml_sitemap, s.strategic_page,
  s.has_medical_review, s.page_purpose, s.index_directive, s.content_topic_tier, s.page_category, s.page_role,
  s.intent_source_tier, s.legal_review_required, now(), now()
from (values
  ('vth-6.2.10.14', 'page_' || upper(substr(md5('vth-6.2.10.14 braces-tooth-extraction'), 1, 16)),
   'Tooth Extraction for Braces', 'braces-tooth-extraction', 'orthodontics', '6', 'vth-6.1.15',
   'orthodontic-treatment', 'Orthodontic Treatment', 'จัดฟัน ถอนฟันกี่ซี่', 'orthodontic-elastics'),
  ('vth-3.5.6', 'page_' || upper(substr(md5('vth-3.5.6 mouth-biomapping'), 1, 16)),
   'Mouth BioMapping (hub)', 'mouth-biomapping', 'vth-signature', '3', 'vth-3.5',
   'mouth-biomapping', 'Mouth BioMapping (MBM)', 'mouth biomapping คืออะไร', 'genetic-testing')
) n(pfp, fp, name, slug, cluster, section, parent, entity, entity_name, kw, src)
join _kw k on k.kw = n.kw
join public.seo_website_page_master s on s.brand_id = 'vth-biodent' and s.slug = n.src
left join public.seo_website_page_master par on par.page_fingerprint = n.parent;

-- 2c follow-up (operator approved 2026-11-14, applied as vth_phase2c_mbm_reparent):
-- the five MBM component services in §3.5 now sit under the new MBM hub instead of the
-- precision-diagnostics hub. MBM pages in §3.1/§4.1/§6.7 keep their section parents.
update public.seo_website_page_master
set parent_page_fp = 'vth-3.5.6', parent_page_name = 'Mouth BioMapping (hub)', updated_at = now(),
    reconciliation_notes = concat_ws(' | ', nullif(reconciliation_notes, ''),
      '2026-11-14 PHASE2C: parent vth-3.5 -> vth-3.5.6 (new MBM hub)')
where brand_id = 'vth-biodent' and parent_page_fp = 'vth-3.5'
  and page_fingerprint in ('vth-3.5.5','vth-3.5.9','vth-3.5.10','vth-3.5.11','vth-3.5.12');
