-- K1b · fix console_api.actions: impact lookup through a definer function (DRAFT, not applied) · 2026-10-28
-- Bug in K1a: public.v_page_change_impact / v_page_change_events are security_invoker views, so inside
-- console_api.actions they are checked as the caller (authenticated), whose grants K0a revoked →
-- "permission denied for view v_page_change_events" for every signed-in user.
-- Fix: read the impact through a security-definer function (runs as owner), not by re-granting the public views
-- (that would re-expose them on the public Data API).

begin;

create function console.first_impact_after(p_page_fp text, p_from date)
returns table (change_date date, status text, confidence text, d_clicks bigint, pct_clicks numeric, d_pos numeric)
language sql stable security definer set search_path = '' as $$
  select i.change_date, i.status, i.confidence, i.d_clicks, i.pct_clicks, i.d_pos
    from public.v_page_change_impact i
   where i.page_fp = p_page_fp and i.change_date >= p_from
   order by i.change_date
   limit 1
$$;
revoke all on function console.first_impact_after(text, date) from public, anon;
grant execute on function console.first_impact_after(text, date) to authenticated, service_role;

create or replace view console_api.actions as
with page as (
  select p.brand_id, p.page_fingerprint as page_code, p.fingerprint as page_fp, p.slug, p.page_name, p.page_type
    from public.seo_website_page_master p
   where p.brand_id in (select console.readable_brands())
), feed as (
  select a.id as action_id, v.brand_id as brand_slug, 'priority'::text as source,
         v.page_fingerprint as page_code, v.suggested_action as title, v.score, v.top_signals, v.refreshed_at,
         a.status, a.assignee, a.note, a.due_date, a.created_at, a.updated_at, a.done_at, a.done_by
    from public.v_page_priority v
    left join console.actions a
      on a.brand_slug = v.brand_id and a.page_code = v.page_fingerprint and a.action_key = v.suggested_action
   where v.brand_id in (select console.readable_brands())
), kept as (
  select a.id, a.brand_slug, a.source, a.page_code, coalesce(a.title, a.action_key), null::numeric, null::text[], null::timestamptz,
         a.status, a.assignee, a.note, a.due_date, a.created_at, a.updated_at, a.done_at, a.done_by
    from console.actions a
   where a.brand_slug in (select console.readable_brands())
     and (a.source = 'manual'
          or not exists (select 1 from public.v_page_priority v
                          where v.brand_id = a.brand_slug and v.page_fingerprint = a.page_code and v.suggested_action = a.action_key))
), allx as (
  select * from feed union all select * from kept
)
select x.action_id,
       x.brand_slug,
       x.source,
       x.page_code,
       pg.page_fp,
       pg.slug,
       pg.page_name,
       pg.page_type,
       x.title,
       x.score,
       x.top_signals,
       case
         when x.title ilike 'add internal links%' or x.title ilike 'fix landing UX%' then 'webmaster'
         when x.source = 'manual' then null
         else 'seo_specialist'
       end                                         as role_hint,
       coalesce(x.status, 'open')                  as status,
       x.assignee,
       u.email                                     as assignee_email,
       x.note,
       x.due_date,
       x.created_at, x.updated_at, x.done_at,
       g.clicks_28d, g.clicks_prev_28d, g.impressions_28d, g.position_28d,
       imp.change_date                             as impact_change_date,
       imp.status                                  as impact_status,
       imp.confidence                              as impact_confidence,
       imp.d_clicks                                as impact_d_clicks,
       imp.pct_clicks                              as impact_pct_clicks,
       imp.d_pos                                   as impact_d_pos,
       x.refreshed_at                              as feed_refreshed_at
  from allx x
  left join page pg on pg.brand_id = x.brand_slug and pg.page_code = x.page_code
  left join auth.users u on u.id = x.assignee
  left join console.mv_page_gsc_28d g on g.brand_id = x.brand_slug and g.page_slug = pg.slug
  left join lateral console.first_impact_after(pg.page_fp, x.done_at::date - 1) imp
         on x.done_at is not null;

commit;
