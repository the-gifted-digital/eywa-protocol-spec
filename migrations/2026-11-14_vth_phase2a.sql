-- 2026-11-14 · VTH rubric phase 2a (operator approved 2026-11-14)
-- reports/technical-audit/2026-11-14-phase2-proposal.md §3 in eywa-vth-biodent
-- 1) planned links into the 15 Merged pages: retarget to destination, or deprecate when
--    source = destination, source is Merged, source already links to destination, or a
--    sibling retarget already covers the same (source, destination) pair
-- 2) all planned/live links out of Merged pages -> deprecated
-- 3) real search keywords of 9 Merged pages -> semantic of destination; their target is
--    cleared on the Merged row (history in reconciliation_notes). Role phrases stay put.
-- 4) drop bargain semantic "เลเซอร์เหงือก ราคาถูก" from laser-dentistry-evidence

create temp table _p2a_map(src text, link_dest text, kw_dest text) on commit drop;
insert into _p2a_map values
  ('diabetes-dental-care-guide','gum-disease-and-diabetes','gum-disease-and-diabetes'),
  ('pharmacogenomics-guide','pharmacogenomics','pharmacogenomics'),
  ('gut-oral-axis-guide','gut-oral-axis','gut-oral-axis'),
  ('oral-probiotics-guide','oral-probiotics','oral-probiotics'),
  ('collagen-bone-density-guide','collagen-bone-preservation','collagen-bone-preservation'),
  ('ai-remote-monitoring-guide','ai-remote-monitoring','ai-remote-monitoring'),
  ('pncl-medicine-guide','pncl-philosophy','pncl-philosophy'),
  ('uv-implant-guide','dental-implant-guide','uv-photofunctionalized-implant'),
  ('genetics-oral-health-guide','genetic-testing','genetic-testing'),
  ('oral-microbiome-guide','microbiome-baseline',null),
  ('facial-structure-longevity-guide','structural-facial-longevity-program',null),
  ('facial-longevity-faq','structural-facial-longevity-program',null),
  ('oral-systemic-health-guide','oral-systemic-connection',null),
  ('senior-dental-care-guide','senior-dental-care',null),
  ('senior-dental-care-faq','dental-implant-for-seniors',null);

create temp table _p2a_fp on commit drop as
select m.src, s.page_fingerprint src_fp, d.page_fingerprint dest_fp, s.target_keyword_fp kw_fp, m.kw_dest
from _p2a_map m
join public.seo_website_page_master s on s.brand_id='vth-biodent' and s.slug=m.src and s.status='Merged'
join public.seo_website_page_master d on d.brand_id='vth-biodent' and d.slug=m.link_dest;

-- inbound links: decide per row before touching anything
create temp table _p2a_in on commit drop as
select l.id, l.from_page_fp, f.dest_fp,
  case
    when l.from_page_fp = f.dest_fp then 'deprecate'
    when l.from_page_fp in (select src_fp from _p2a_fp) then 'deprecate'
    when exists (select 1 from public.seo_page_internal_links x
                 where x.from_page_fp = l.from_page_fp and x.to_page_fp = f.dest_fp
                   and x.status in ('planned','live')) then 'deprecate'
    when row_number() over (partition by l.from_page_fp, f.dest_fp order by l.created_at, l.id) > 1 then 'deprecate'
    else 'retarget'
  end action
from public.seo_page_internal_links l
join _p2a_fp f on l.to_page_fp = f.src_fp
where l.status = 'planned';

update public.seo_page_internal_links l set to_page_fp = i.dest_fp, updated_at = now()
from _p2a_in i where l.id = i.id and i.action = 'retarget';

update public.seo_page_internal_links l set status = 'deprecated', planned = false, updated_at = now()
from _p2a_in i where l.id = i.id and i.action = 'deprecate';

update public.seo_page_internal_links set status = 'deprecated', planned = false, updated_at = now()
where from_page_fp in (select src_fp from _p2a_fp) and status in ('planned','live');

-- Merged rows first: release moved targets
update public.seo_website_page_master s
set updated_at = now(),
    -- trigger fn_enforce_page_keyword_no_reuse counts targets of every page incl. Merged,
    -- so a moved keyword must leave the Merged row; old value is kept in the note
    target_keyword_fp = case when f.kw_dest is null then s.target_keyword_fp end,
    reconciliation_notes = concat_ws(' | ', nullif(s.reconciliation_notes, ''),
      '2026-11-14 PHASE2A: inbound planned links retargeted/deprecated, outbound deprecated'
      || coalesce('; target "' || split_part(f.kw_fp,'::',4) || '" moved to semantic of ' || f.kw_dest, '; role-phrase keyword kept as history'))
from _p2a_fp f where s.brand_id='vth-biodent' and s.slug = f.src;

-- keywords of Merged pages -> destination semantics
update public.seo_website_page_master d
set semantic_keywords_fps = array_append(coalesce(d.semantic_keywords_fps, '{}'), f.kw_fp),
    updated_at = now(),
    reconciliation_notes = concat_ws(' | ', nullif(d.reconciliation_notes, ''),
      '2026-11-14 PHASE2A: + semantic "' || split_part(f.kw_fp,'::',4) || '" from Merged ' || f.src)
from _p2a_fp f
where d.brand_id='vth-biodent' and d.slug = f.kw_dest and f.kw_fp is not null
  and not (f.kw_fp = any(coalesce(d.semantic_keywords_fps, '{}'))) and d.target_keyword_fp is distinct from f.kw_fp;

-- bargain semantic out
update public.seo_website_page_master
set semantic_keywords_fps = array(select k from unnest(semantic_keywords_fps) k where split_part(k,'::',4) <> 'เลเซอร์เหงือก ราคาถูก'),
    updated_at = now(),
    reconciliation_notes = concat_ws(' | ', nullif(reconciliation_notes, ''), '2026-11-14 PHASE2A: - semantic "เลเซอร์เหงือก ราคาถูก" (bargain, premium positioning)')
where brand_id='vth-biodent' and slug='laser-dentistry-evidence'
  and exists (select 1 from unnest(semantic_keywords_fps) k where split_part(k,'::',4) = 'เลเซอร์เหงือก ราคาถูก');
