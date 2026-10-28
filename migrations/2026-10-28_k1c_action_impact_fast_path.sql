-- K1c · console.first_impact_after: skip work when there is nothing to measure (DRAFT, not applied) · 2026-10-28
-- K1b called the impact lookup for every action row (~13 ms each, ~2.5 s for 195 rows) even when done_at is null.
-- Same signature, so console_api.actions is untouched. plpgsql so the null check short-circuits before the view runs.

create or replace function console.first_impact_after(p_page_fp text, p_from date)
returns table (change_date date, status text, confidence text, d_clicks bigint, pct_clicks numeric, d_pos numeric)
language plpgsql stable security definer set search_path = '' as $$
begin
  if p_page_fp is null or p_from is null then
    return;
  end if;
  return query
    select i.change_date, i.status, i.confidence, i.d_clicks, i.pct_clicks, i.d_pos
      from public.v_page_change_impact i
     where i.page_fp = p_page_fp and i.change_date >= p_from
     order by i.change_date
     limit 1;
end $$;
