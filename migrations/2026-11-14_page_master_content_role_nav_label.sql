-- 2026-11-14 · VTH rubric phase 0 (reports/technical-audit/2026-11-14-rubric-draft.md in eywa-vth-biodent)
-- Adds two nullable, brand-agnostic columns to seo_website_page_master. Additive only; no existing data touched.
--   content_role : ranking vs support page (rubric S1). `page_role` already exists and means hub/leaf
--                  across 4 brands, so it is NOT reused. NOT NULL is enforced per brand by a gate, not here,
--                  because other brands have not classified their pages yet.
--   nav_label    : short page name for menus/sidebar (rubric N1). The ≤28-grapheme rule is a gate (Thai
--                  combining marks make char_length ≠ graphemes); the DB caps at 60 chars to keep prose out.

alter table public.seo_website_page_master
  add column if not exists content_role text,
  add column if not exists nav_label text;

alter table public.seo_website_page_master
  add constraint chk_page_master_content_role
    check (content_role is null or content_role in
      ('ranking', 'support:complete-guide', 'support:faq', 'support:evidence')),
  add constraint chk_page_master_nav_label
    check (nav_label is null or (char_length(btrim(nav_label)) between 1 and 60 and nav_label = btrim(nav_label)));

create unique index if not exists uq_page_master_brand_nav_label
  on public.seo_website_page_master (brand_id, nav_label)
  where nav_label is not null;

comment on column public.seo_website_page_master.content_role is
  'Rubric S1: ranking = competes for a volume keyword; support:* = strategic page (complete-guide / faq / evidence) that targets a role-pattern keyword only. Distinct from page_role (hub/leaf).';
comment on column public.seo_website_page_master.nav_label is
  'Rubric N1: short noun-phrase page name for sidebar/menus, ≤28 Thai graphemes (gate), unique per brand, no ad words.';
