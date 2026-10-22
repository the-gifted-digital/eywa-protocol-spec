-- W3.2b: Wikidata ids adjudicated from `verify-entity-ids.mjs --all` (report run 2026-10-22)
-- Do NOT run that script with --apply: it writes every "proposed" id, and 12 of its 21 proposals
-- were wrong (a Hong Kong shopping mall for emax-material, journals for pediatric-dentistry and
-- implantologist, "osteoporosis" for alveolar-bone-loss, "anatomy" for tooth-anatomy, a 1991
-- article for omfs ...). Only the ids below passed a human read of label + description
-- (Entity_Identity_SOP §2 three gates). Never overwrites: each row requires wikidata_id to be empty.

begin;

update public.seo_entity_graph g
set wikidata_id = v.qid, last_graph_update = now()
from (values
  ('implant-failure',  'Q17055904'),  -- implant failure: malfunction / loosening of implants
  ('diastema',         'Q1174313'),   -- diastema: gap between teeth
  ('orthodontist',     'Q3842067'),
  ('endodontist',      'Q67502614'),
  ('periodontist',     'Q1957982'),
  ('pediatric-dentist','Q97611620'),
  ('prosthodontist',   'Q92561898'),
  ('piezosurgery',     'Q7193133')    -- piezoelectric surgery
) v(fp, qid)
where g.entity_fingerprint = v.fp
  and coalesce(g.wikidata_id, '') = ''
  and lower(coalesce(g.entity_lifecycle, '')) not in ('merged', 'dropped')
  and not exists (select 1 from public.seo_entity_graph o where o.wikidata_id = v.qid and o.entity_fingerprint <> v.fp);

-- Existing id that names a different thing: periodontal-surgery -> Q2142843 "pedicled flap" (a flap
-- design used in some surgeries, not periodontal surgery itself). Cleared; an exact item can be set later.
update public.seo_entity_graph
set wikidata_id = null, wikipedia_url = null, last_graph_update = now()
where entity_fingerprint = 'periodontal-surgery' and wikidata_id = 'Q2142843';

commit;

-- Rejected proposals (not written): emax-crown (2004 article), brain-fog-oral (obnubilation),
-- oral-cancer (lip AND oral cavity carcinoma — broader), alveolar-bone-loss (osteoporosis),
-- night-guard (item without description), emax-material (shopping mall), omfs (1991 article),
-- oral-surgery (entity is Merged), tooth-anatomy (anatomy), hydrogen-peroxide-whitening (the chemical),
-- pediatric-dentistry and implantologist (journals), 3d-printer-aligner (generic 3D printer).
