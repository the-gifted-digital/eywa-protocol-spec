-- 2026-11-20b_page_master_og_image_alt.sql — DR-084 (Ayrel) addendum · APPLIED 2026-11-20 (operator: "เอาแบบ ข. ทำได้เลย";
-- Supabase migration `page_master_og_image_alt`). Tested on Postgres 16 first. After apply: 3,885 rows,
-- og_image_alt_resolved on 3,747 (rows with neither line 1 nor line 2 stay NULL).
-- Shared table. Additive: 1 nullable column, 1 CHECK, view v_page_og_card gains 2 columns at the end.
--
-- og:image:alt / twitter:image:alt for the og card. The card shows text, so its alt is that text:
--   og_image_alt_resolved = COALESCE(og_image_alt, og_display_resolved || ' — ' || og_tagline_resolved)
-- One row = one page in one language, so every language row gets its own alt with its own tagline.
-- og_image_alt is an override only — e.g. a card built from an AI result simulation, whose alt must
-- also carry the simulation sentence (Ayrel SOP A10). Not a rebuild input: alt is not drawn on the card,
-- so trg_page_og_inputs_changed does not watch it.
--
-- Rollback:
--   (re-run the view definition from 2026-11-20_page_master_og_card.sql — CREATE OR REPLACE cannot drop columns,
--    so DROP VIEW v_page_og_card first)
--   ALTER TABLE seo_website_page_master DROP CONSTRAINT IF EXISTS chk_page_master_og_image_alt_not_blank,
--     DROP COLUMN IF EXISTS og_image_alt;

BEGIN;

ALTER TABLE seo_website_page_master
  ADD COLUMN IF NOT EXISTS og_image_alt text;

ALTER TABLE seo_website_page_master
  ADD CONSTRAINT chk_page_master_og_image_alt_not_blank
    CHECK (og_image_alt IS NULL OR btrim(og_image_alt) <> '');

-- New columns go at the end: CREATE OR REPLACE VIEW may only append.
CREATE OR REPLACE VIEW v_page_og_card WITH (security_invoker = true) AS
SELECT
  p.page_fingerprint,
  p.brand_id,
  p.slug,
  p.page_language,
  p.status,
  p.canonical_url,
  p.primary_entity_fp,
  COALESCE(p.og_display, g.entity_name)                                         AS og_display_resolved,
  (p.og_display IS NOT NULL)                                                     AS og_display_overridden,
  COALESCE(p.og_tagline, NULLIF(btrim(split_part(p.seo_title, ' | ', 1)), ''))   AS og_tagline_resolved,
  (p.og_tagline IS NOT NULL)                                                     AS og_tagline_overridden,
  COALESCE(p.og_style, '{}'::jsonb)                                              AS og_style,
  p.og_image_url,
  p.og_image_generated_at,
  (p.og_image_generated_at IS NULL)                                              AS og_needs_build,
  COALESCE(
    p.og_image_alt,
    NULLIF(concat_ws(' — ',
      COALESCE(p.og_display, g.entity_name),
      COALESCE(p.og_tagline, NULLIF(btrim(split_part(p.seo_title, ' | ', 1)), ''))
    ), '')
  )                                                                              AS og_image_alt_resolved,
  (p.og_image_alt IS NOT NULL)                                                   AS og_image_alt_overridden
FROM seo_website_page_master p
LEFT JOIN seo_entity_graph g ON g.entity_fingerprint = p.primary_entity_fp;

COMMENT ON COLUMN seo_website_page_master.og_image_alt IS
  'Override for the og card alt (og:image:alt, twitter:image:alt), in THIS row''s language. NULL = the text on the card: og_display_resolved — og_tagline_resolved (v_page_og_card.og_image_alt_resolved). Write it when the card needs more, e.g. the AI-simulation sentence (Ayrel SOP A10). DR-084.';
COMMENT ON VIEW v_page_og_card IS
  'og card inputs with defaults resolved (og_display -> entity name, og_tagline -> seo_title, og_image_alt -> card text) and og_needs_build. Read this, not the raw columns. DR-084 (Ayrel).';

COMMIT;
