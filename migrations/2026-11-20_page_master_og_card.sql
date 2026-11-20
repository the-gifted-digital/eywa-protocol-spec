-- 2026-11-20_page_master_og_card.sql — DR-084 · APPLIED 2026-11-20 (operator: "apply ได้เลย"; Supabase migration `page_master_og_card`)
-- Verified after apply: 5 og_* columns, 4 CHECKs, trigger present; v_page_og_card returns all 3,885 rows;
-- og_display_resolved filled on 2,687 (the 1,198 without primary_entity_fp stay NULL — the generator must
-- skip or ask for og_display there); og_tagline_resolved filled on 3,742.
-- Shared table (seo_website_page_master). Additive only: 5 nullable columns, 4 CHECKs, 1 trigger, 1 view.
-- No existing row changes and no brand code reads these columns yet, so nothing breaks on apply.
--
-- What it is for: the og:image of a page becomes a designed card (1200x630) built from the page's
-- own photo, one card per page per language — the same "one row = one page, one language" rule as
-- BROADCAST-2026-11-17-multilingual-rows. The card has two lines of text:
--   og_display  line 1, English, the brand's display face. NULL = the primary entity's English name
--               (seo_entity_graph.entity_name via primary_entity_fp). Write it only to override.
--   og_tagline  line 2, in the row's own language and face. NULL = the page title (seo_title without
--               the " | Brand" suffix). Write it when the title does not read well as a tagline.
-- og_style holds per-page overrides of the brand defaults (band / display_color / grain / logo / focus);
-- the brand's own defaults live in the brand repo, not here. og_image_url is written back by the brand's
-- card generator after upload; og_image_generated_at says when.
--
-- Regeneration signal: changing og_display, og_tagline, og_style or primary_entity_fp clears
-- og_image_generated_at (trg_page_og_inputs_changed). og_image_url is kept, so the live card keeps
-- working until the generator replaces it. "Needs a (re)build" = og_image_generated_at IS NULL.
--
-- Rollback (nothing else depends on these objects):
--   DROP VIEW IF EXISTS v_page_og_card;
--   DROP TRIGGER IF EXISTS trg_page_og_inputs_changed ON seo_website_page_master;
--   DROP FUNCTION IF EXISTS fn_page_og_inputs_changed();
--   ALTER TABLE seo_website_page_master
--     DROP COLUMN IF EXISTS og_display, DROP COLUMN IF EXISTS og_tagline, DROP COLUMN IF EXISTS og_style,
--     DROP COLUMN IF EXISTS og_image_url, DROP COLUMN IF EXISTS og_image_generated_at;

BEGIN;

ALTER TABLE seo_website_page_master
  ADD COLUMN IF NOT EXISTS og_display            text,
  ADD COLUMN IF NOT EXISTS og_tagline            text,
  ADD COLUMN IF NOT EXISTS og_style              jsonb,
  ADD COLUMN IF NOT EXISTS og_image_url          text,
  ADD COLUMN IF NOT EXISTS og_image_generated_at timestamptz;

-- Empty strings would silently beat the NULL defaults; whitespace-only text is never a real value.
ALTER TABLE seo_website_page_master
  ADD CONSTRAINT chk_page_master_og_display_not_blank
    CHECK (og_display IS NULL OR btrim(og_display) <> ''),
  ADD CONSTRAINT chk_page_master_og_tagline_not_blank
    CHECK (og_tagline IS NULL OR btrim(og_tagline) <> ''),
  -- og_style is an object of known keys with known value shapes. Unknown keys are allowed so a brand
  -- can trial a new override before it is promoted into this list.
  ADD CONSTRAINT chk_page_master_og_style_shape
    CHECK (
      og_style IS NULL OR (
        jsonb_typeof(og_style) = 'object'
        AND (NOT og_style ? 'band'          OR og_style->>'band' IN ('light','dark'))
        AND (NOT og_style ? 'logo'          OR og_style->>'logo' IN ('color','white'))
        AND (NOT og_style ? 'display_color' OR og_style->>'display_color' ~ '^#[0-9A-Fa-f]{6}$')
        AND (NOT og_style ? 'grain'         OR (jsonb_typeof(og_style->'grain') = 'number'
                                                AND (og_style->>'grain')::numeric BETWEEN 0 AND 1))
        AND (NOT og_style ? 'focus'         OR og_style->>'focus' ~ '^(100|[0-9]{1,2})% (100|[0-9]{1,2})%$')
      )
    ),
  -- og:image must be an absolute https URL: LINE / Facebook / Slack unfurlers do not resolve relative paths.
  ADD CONSTRAINT chk_page_master_og_image_url_https
    CHECK (og_image_url IS NULL OR og_image_url ~ '^https://');

CREATE OR REPLACE FUNCTION fn_page_og_inputs_changed() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.og_display        IS DISTINCT FROM OLD.og_display
  OR NEW.og_tagline        IS DISTINCT FROM OLD.og_tagline
  OR NEW.og_style          IS DISTINCT FROM OLD.og_style
  OR NEW.primary_entity_fp IS DISTINCT FROM OLD.primary_entity_fp THEN
    -- Mark the card for rebuild unless this same statement is the generator recording a new build.
    IF NEW.og_image_generated_at IS NOT DISTINCT FROM OLD.og_image_generated_at THEN
      NEW.og_image_generated_at := NULL;
    END IF;
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER trg_page_og_inputs_changed
  BEFORE UPDATE OF og_display, og_tagline, og_style, primary_entity_fp
  ON seo_website_page_master
  FOR EACH ROW EXECUTE FUNCTION fn_page_og_inputs_changed();

-- One place that resolves the defaults, so every brand's generator reads the same answer.
-- security_invoker: the view runs with the caller's rights, like the table it reads (K0a).
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
  (p.og_image_generated_at IS NULL)                                              AS og_needs_build
FROM seo_website_page_master p
LEFT JOIN seo_entity_graph g ON g.entity_fingerprint = p.primary_entity_fp;

COMMENT ON COLUMN seo_website_page_master.og_display IS
  'og card line 1 (English, brand display face). NULL = the primary entity''s English name (seo_entity_graph.entity_name via primary_entity_fp) — write only to override. Resolved in v_page_og_card. DR-084.';
COMMENT ON COLUMN seo_website_page_master.og_tagline IS
  'og card line 2, in THIS row''s language and that language''s face. NULL = seo_title without the " | Brand" suffix. One line on the card; the generator shrinks to a floor and fails rather than wrap. DR-084.';
COMMENT ON COLUMN seo_website_page_master.og_style IS
  'Per-page overrides of the brand og-card defaults (defaults live in the brand repo): band light|dark · display_color #RRGGBB · grain 0..1 · logo color|white · focus "X% Y%" (crop of the source photo, same meaning as CSS object-position). DR-084.';
COMMENT ON COLUMN seo_website_page_master.og_image_url IS
  'Absolute https URL of the built og card for THIS row (one card per page per language), e.g. https://cdn.{brand}/og/{slug}-v1.jpg. Written by the brand''s card generator. NULL = the site falls back to its own crop of the hero. DR-084.';
COMMENT ON COLUMN seo_website_page_master.og_image_generated_at IS
  'When og_image_url was last built. Cleared by trg_page_og_inputs_changed when og_display / og_tagline / og_style / primary_entity_fp change, so NULL = needs a (re)build. DR-084.';
COMMENT ON VIEW v_page_og_card IS
  'og card inputs with defaults resolved (og_display -> entity name, og_tagline -> seo_title) and og_needs_build. Read this, not the raw columns. DR-084.';

COMMIT;
