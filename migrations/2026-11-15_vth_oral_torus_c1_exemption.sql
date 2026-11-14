-- Rubric C1 exemption for VTH oral-torus (operator ruling 2026-11-15). reconciliation_notes is an
-- append-only " | " log read by gates; append, never overwrite.
do $$
declare n int;
begin
  update public.seo_website_page_master
     set reconciliation_notes = coalesce(reconciliation_notes || ' | ', '') ||
       'C1 EXEMPTION 2026-11-15 (operator): concern minimum needs 3 tier 1–3; page cites 2 (28213765 bruxism SR, 39952790 OSA SR+MA). PubMed search 2026-11-15 found no other SR/MA, RCT or society guideline on oral/mandibular/palatal tori — remainder is case reports and narrative reviews (T6). Re-check when new SR appears.'
   where brand_id = 'vth-biodent' and trim(both '/' from slug) = 'oral-torus'
     and coalesce(reconciliation_notes, '') not like '%C1 EXEMPTION%';
  get diagnostics n = row_count;
  if n <> 1 then raise exception 'expected 1 row, got %', n; end if;
end $$;
