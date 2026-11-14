-- Rubric C4: seo_citations.publication_year is CE. Seven Thai government / legal rows were
-- stored in Buddhist Era (2510-2569). Convert BE -> CE (minus 543). Shared pool, brand_scope '*'.
do $$
declare n int;
begin
  update seo_citations
     set publication_year = publication_year - 543
   where fingerprint in (
     'cite_TH01A2B3C4D5E601','cite_TH02A2B3C4D5E602','cite_TH05A2B3C4D5E605','cite_TH06A2B3C4D5E606',
     'cite_4DEA3603E5B9409B','cite_707AB46A1DF74421','cite_AA67F3684DD645BF')
     and publication_year > extract(year from now())::int + 1;
  get diagnostics n = row_count;
  if n <> 7 then raise exception 'expected 7 rows, updated %', n; end if;
  if exists (select 1 from seo_citations where publication_year > extract(year from now())::int + 1) then
    raise exception 'pool still has future years';
  end if;
end $$;
