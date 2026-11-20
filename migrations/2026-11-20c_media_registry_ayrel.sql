-- 2026-11-20c_media_registry_ayrel.sql — DR-085 (Ayrel media registry) · APPLIED 2026-11-20 (operator: "apply ได้เลย";
-- Supabase migration `media_registry_ayrel` + cron job id 10 `eywa-media-daily-sweep`). Tested 53/53 on Postgres 16 first.
-- First rows: mda_B6F9C02130644397 (teeth-whitening hero v1, AI) + mda_3D3856E6C01843B9 (og card th v1), 3 usages on vth-3.7.4.
-- Builds on DR-038 seo_media_assets (37 cols, 0 rows) and restores what SS-DR-015/016 designed but DR-038
-- left out: the servable view, the daily sweep, quarantine and an audit trail. Additive; the table is empty.
--
--   seo_media_assets            + format / origin / kind / consent_subject / person / AI provenance / video /
--                                 delivery / takedown date (remove_on = use_until - 1 day) / quarantine / purge
--   seo_media_asset_texts       NEW  alt · caption · transcript per locale, tied to the file version they describe
--   seo_media_asset_usages      NEW  which page uses which asset in which slot (reuse across pages)
--   seo_media_asset_events      NEW  append-only audit trail (UPDATE/DELETE refused)
--   fn_media_guard              no reactivation after takedown, no Active past remove_on, no key reuse
--   fn_media_daily_sweep        pg_cron 00:05 Asia/Bangkok: warnings at 15/7/3 days, Active -> Expired/Revoked
--   views                       seo_servable_media · v_media_expiry_alerts · v_media_due_takedown ·
--                               v_media_quarantine · v_media_usage_blocked · v_media_text_issues
--
-- Time: every date rule uses today in Asia/Bangkok (fn_media_today()). remove_on is one day BEFORE
-- use_until (operator 2026-11-20): an image is taken down the day before the last day written on the consent,
-- so no hour/minute/timezone reading of use_until can leave it online past the agreed date.
--
-- The brand side (R2 quarantine to a private bucket, cache purge, gated Worker manifest, rebuild, CDN 404
-- verification, hard delete after 90 days) runs in each brand repo and writes back through the events table.
--
-- Rollback (nothing outside this file depends on these objects; the table is empty):
--   SELECT cron.unschedule('eywa-media-daily-sweep');
--   DROP VIEW IF EXISTS v_media_text_issues, v_media_usage_blocked, v_media_quarantine, v_media_due_takedown,
--                       v_media_expiry_alerts, seo_servable_media;
--   DROP TABLE IF EXISTS seo_media_asset_events, seo_media_asset_usages, seo_media_asset_texts;
--   DROP FUNCTION IF EXISTS fn_media_daily_sweep(), fn_media_guard(), fn_media_log_status(),
--                           fn_media_events_append_only(), fn_media_today();
--   ALTER TABLE seo_media_assets DROP COLUMN ... (every column added below), restore seo_media_assets_source_check.

BEGIN;

-- ── time ─────────────────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_media_today() RETURNS date
LANGUAGE sql STABLE AS $$ SELECT (now() AT TIME ZONE 'Asia/Bangkok')::date $$;

-- ── seo_media_assets: new columns ───────────────────────────────────────────────────────────────
ALTER TABLE seo_media_assets
  ADD COLUMN asset_format        text NOT NULL DEFAULT 'image',
  ADD COLUMN origin              text NOT NULL DEFAULT 'photo',
  ADD COLUMN kind                text NOT NULL DEFAULT 'hero',
  ADD COLUMN consent_subject     text NOT NULL DEFAULT 'none',
  ADD COLUMN person_fp           text,
  ADD COLUMN delivery            text NOT NULL DEFAULT 'public_cdn',
  ADD COLUMN generation_model    text,
  ADD COLUMN generation_prompt   text,
  ADD COLUMN generation_job_id   text,
  ADD COLUMN duration_seconds    numeric(8,2),
  ADD COLUMN has_audio           boolean,
  ADD COLUMN poster_asset_id     uuid REFERENCES seo_media_assets(id) ON DELETE SET NULL,
  ADD COLUMN supersedes_asset_id uuid REFERENCES seo_media_assets(id) ON DELETE SET NULL,
  ADD COLUMN remove_on           date GENERATED ALWAYS AS (use_until - 1) STORED,
  ADD COLUMN quarantined_at      timestamptz,
  ADD COLUMN quarantine_key      text,
  ADD COLUMN purged_at           timestamptz;

ALTER TABLE seo_media_assets
  ALTER COLUMN kind DROP DEFAULT;   -- every row says what it is for

ALTER TABLE seo_media_assets DROP CONSTRAINT seo_media_assets_source_check;

ALTER TABLE seo_media_assets
  ADD CONSTRAINT seo_media_assets_source_check
    CHECK (source IN ('notion','batch-upload','wp-migration','ayrel')),
  ADD CONSTRAINT chk_media_asset_format
    CHECK (asset_format IN ('image','video','animated_image','vector')),
  ADD CONSTRAINT chk_media_origin
    CHECK (origin IN ('photo','ai_generated','ai_edited','illustration','render','screenshot')),
  ADD CONSTRAINT chk_media_kind
    CHECK (kind IN ('hero','illustration','diagram','icon','equipment','clinic_space',
                    'portrait','case_before_after','review_photo','testimonial',
                    'result_simulation','og_card','logo',
                    'video_hero_loop','video_explainer','video_testimonial')),
  ADD CONSTRAINT chk_media_consent_subject
    CHECK (consent_subject IN ('none','patient','staff','customer','model')),
  ADD CONSTRAINT chk_media_delivery
    CHECK (delivery IN ('public_cdn','gated_worker')),
  -- a real person in the frame = consent lifecycle + gated delivery, whatever else the row says
  ADD CONSTRAINT chk_media_person_needs_gate
    CHECK (consent_subject = 'none' OR delivery = 'gated_worker'),
  ADD CONSTRAINT chk_media_patient_flag_consistent
    CHECK (is_patient_image = (consent_subject = 'patient')),
  ADD CONSTRAINT chk_media_person_active_consent
    CHECK (consent_subject = 'none' OR status <> 'Active'
           OR (coalesce(consent_status, '') = 'Obtained' AND (use_forever OR use_until IS NOT NULL))),
           -- coalesce: a NULL consent_status must FAIL the check, not slip through as unknown
  -- kinds that are a real person by definition cannot be declared consent-free
  ADD CONSTRAINT chk_media_person_kinds
    CHECK (kind NOT IN ('portrait','case_before_after','review_photo','testimonial','video_testimonial')
           OR consent_subject <> 'none'),
  -- an AI image is never presented as a real case / review / testimonial
  ADD CONSTRAINT chk_media_ai_not_real_evidence
    CHECK (origin NOT IN ('ai_generated','ai_edited')
           OR kind NOT IN ('case_before_after','review_photo','testimonial','video_testimonial')),
  ADD CONSTRAINT chk_media_result_simulation_is_ai
    CHECK (kind <> 'result_simulation' OR origin IN ('ai_generated','ai_edited')),
  ADD CONSTRAINT chk_media_ai_provenance
    CHECK (origin NOT IN ('ai_generated','ai_edited') OR generation_model IS NOT NULL),
  ADD CONSTRAINT chk_media_video_fields
    CHECK (asset_format = 'video' OR (duration_seconds IS NULL AND has_audio IS NULL)),
  ADD CONSTRAINT chk_media_quarantine_pair
    CHECK ((quarantined_at IS NULL) = (quarantine_key IS NULL)),
  ADD CONSTRAINT chk_media_purge_after_quarantine
    CHECK (purged_at IS NULL OR quarantined_at IS NOT NULL);

-- A key is used once, ever: a taken-down file never comes back under its old URL (caches, bookmarks).
CREATE UNIQUE INDEX uq_media_r2_key ON seo_media_assets (r2_bucket, r2_object_key) WHERE r2_object_key IS NOT NULL;
CREATE INDEX idx_media_person_fp ON seo_media_assets (person_fp) WHERE person_fp IS NOT NULL;
CREATE INDEX idx_media_remove_on ON seo_media_assets (remove_on) WHERE status = 'Active' AND consent_subject <> 'none';
CREATE INDEX idx_media_quarantine ON seo_media_assets (quarantined_at) WHERE quarantined_at IS NOT NULL AND purged_at IS NULL;

-- ── texts per locale ────────────────────────────────────────────────────────────────────────────
CREATE TABLE seo_media_asset_texts (
  asset_id        uuid NOT NULL REFERENCES seo_media_assets(id) ON DELETE CASCADE,
  locale          text NOT NULL,
  alt             text,
  caption         text,
  transcript      text,
  written_for_key text NOT NULL,           -- r2_object_key the text describes; differs => stale
  written_by      text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (asset_id, locale),
  CONSTRAINT chk_media_text_locale CHECK (locale ~ '^[a-z]{2}(-[a-z]{2})?$'),
  CONSTRAINT chk_media_text_alt_not_blank CHECK (alt IS NULL OR btrim(alt) <> ''),
  CONSTRAINT chk_media_text_alt_length CHECK (alt IS NULL OR char_length(alt) <= 250)
);
CREATE TRIGGER trg_updated_at_media_texts BEFORE UPDATE ON seo_media_asset_texts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ── usages ──────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE seo_media_asset_usages (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_id         uuid NOT NULL REFERENCES seo_media_assets(id) ON DELETE RESTRICT,
  page_fingerprint text NOT NULL,          -- seo_website_page_master.page_fingerprint (soft, survives renames)
  slot             text NOT NULL,
  locale           text,                   -- NULL = every language version of the page
  position         int  NOT NULL DEFAULT 0,
  created_at       timestamptz NOT NULL DEFAULT now(),
  removed_at       timestamptz,
  CONSTRAINT chk_media_usage_slot CHECK (slot IN ('hero','mobile_card','og','inline','gallery','portrait',
                                                  'reviewer_badge','poster','background','other'))
);
CREATE UNIQUE INDEX uq_media_usage_live ON seo_media_asset_usages
  (asset_id, page_fingerprint, slot, COALESCE(locale, '*'), position) WHERE removed_at IS NULL;
CREATE INDEX idx_media_usage_page ON seo_media_asset_usages (page_fingerprint) WHERE removed_at IS NULL;

-- ── events (append-only) ────────────────────────────────────────────────────────────────────────
CREATE TABLE seo_media_asset_events (
  id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  asset_id  uuid NOT NULL REFERENCES seo_media_assets(id) ON DELETE RESTRICT,
  event     text NOT NULL,
  detail    jsonb NOT NULL DEFAULT '{}'::jsonb,
  actor     text NOT NULL DEFAULT current_user,
  at        timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chk_media_event CHECK (event IN (
    'registered','status_changed','warning_15d','warning_7d','warning_3d',
    'takedown_due','quarantined','cache_purged','gate_manifest_updated','rebuild_requested',
    'cdn_verified_404','leak_detected','re_consented','purged','text_written','note'))
);
CREATE INDEX idx_media_events_asset ON seo_media_asset_events (asset_id, at DESC);
-- one warning per threshold per asset
CREATE UNIQUE INDEX uq_media_event_warning ON seo_media_asset_events (asset_id, event)
  WHERE event IN ('warning_15d','warning_7d','warning_3d','takedown_due');

CREATE OR REPLACE FUNCTION fn_media_events_append_only() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'seo_media_asset_events is append-only (DR-085)';
END $$;
CREATE TRIGGER trg_media_events_append_only BEFORE UPDATE OR DELETE ON seo_media_asset_events
  FOR EACH ROW EXECUTE FUNCTION fn_media_events_append_only();

-- ── guard: no backflow ──────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_media_guard() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    -- once taken down, a row never serves again; re-consent = a NEW row with a NEW key (supersedes_asset_id)
    IF OLD.status IN ('Expired','Revoked') AND NEW.status IN ('Active','Pending') THEN
      RAISE EXCEPTION 'media % was %; re-consent needs a new asset row and a new R2 key (supersedes_asset_id)', OLD.fingerprint, OLD.status;
    END IF;
    IF OLD.quarantined_at IS NOT NULL AND NEW.status = 'Active' THEN
      RAISE EXCEPTION 'media % is quarantined and cannot be Active', OLD.fingerprint;
    END IF;
    IF OLD.purged_at IS NOT NULL AND (NEW.status IS DISTINCT FROM OLD.status
        OR NEW.r2_object_key IS DISTINCT FROM OLD.r2_object_key OR NEW.purged_at IS DISTINCT FROM OLD.purged_at) THEN
      RAISE EXCEPTION 'media % was purged; the row is a record only', OLD.fingerprint;
    END IF;
    -- the file a row points at is fixed once it has served: new pixels = new row
    IF OLD.status <> 'Pending' AND NEW.r2_object_key IS DISTINCT FROM OLD.r2_object_key
       AND NEW.quarantined_at IS NOT DISTINCT FROM OLD.quarantined_at THEN
      RAISE EXCEPTION 'media % already served %; upload a new version as a new row', OLD.fingerprint, OLD.r2_object_key;
    END IF;
  END IF;
  -- consent withdrawn: the row leaves Active in the same statement (safe direction, never an error)
  IF NEW.status = 'Active' AND NEW.consent_status = 'Revoked' THEN
    NEW.status := 'Revoked';
    NEW.expired_at := coalesce(NEW.expired_at, now());
  END IF;
  -- a person image cannot be Active on or after its takedown day (use_until - 1, Asia/Bangkok)
  IF NEW.status = 'Active' AND NEW.consent_subject <> 'none' AND NOT NEW.use_forever
     AND NEW.use_until IS NOT NULL AND NEW.use_until - 1 <= fn_media_today() THEN
    IF TG_OP = 'UPDATE' AND OLD.status = 'Active' THEN
      NEW.status := 'Expired';                       -- already live: take it down, do not block the edit
      NEW.expired_at := coalesce(NEW.expired_at, now());
    ELSE
      RAISE EXCEPTION 'media % is past its takedown day % (use_until % minus 1 day)', NEW.fingerprint, NEW.use_until - 1, NEW.use_until;
    END IF;
  END IF;
  RETURN NEW;
END $$;
-- NB: BEFORE triggers see generated columns as NULL/stale, so the takedown day is computed from use_until here.

CREATE TRIGGER trg_media_guard BEFORE INSERT OR UPDATE ON seo_media_assets
  FOR EACH ROW EXECUTE FUNCTION fn_media_guard();

CREATE OR REPLACE FUNCTION fn_media_log_status() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO seo_media_asset_events (asset_id, event, detail) VALUES (NEW.id, 'registered',
      jsonb_build_object('status', NEW.status, 'kind', NEW.kind, 'origin', NEW.origin, 'key', NEW.r2_object_key));
  ELSIF NEW.status IS DISTINCT FROM OLD.status THEN
    INSERT INTO seo_media_asset_events (asset_id, event, detail) VALUES (NEW.id, 'status_changed',
      jsonb_build_object('from', OLD.status, 'to', NEW.status, 'use_until', NEW.use_until, 'remove_on', NEW.remove_on));
  END IF;
  IF TG_OP = 'UPDATE' AND NEW.quarantined_at IS NOT NULL AND OLD.quarantined_at IS NULL THEN
    INSERT INTO seo_media_asset_events (asset_id, event, detail) VALUES (NEW.id, 'quarantined',
      jsonb_build_object('from_key', OLD.r2_object_key, 'quarantine_key', NEW.quarantine_key));
  END IF;
  IF TG_OP = 'UPDATE' AND NEW.purged_at IS NOT NULL AND OLD.purged_at IS NULL THEN
    INSERT INTO seo_media_asset_events (asset_id, event, detail) VALUES (NEW.id, 'purged',
      jsonb_build_object('quarantine_key', NEW.quarantine_key));
  END IF;
  RETURN NULL;
END $$;
CREATE TRIGGER trg_media_log_status AFTER INSERT OR UPDATE ON seo_media_assets
  FOR EACH ROW EXECUTE FUNCTION fn_media_log_status();

-- ── views ───────────────────────────────────────────────────────────────────────────────────────
-- The ONLY source a site build or the gate Worker may read.
CREATE VIEW seo_servable_media WITH (security_invoker = true) AS
SELECT a.*
FROM seo_media_assets a
WHERE a.status = 'Active'
  AND a.quarantined_at IS NULL AND a.purged_at IS NULL
  AND a.r2_object_key IS NOT NULL
  AND (a.consent_subject = 'none'
       OR (a.consent_status = 'Obtained' AND (a.use_forever OR a.remove_on > fn_media_today())));

-- dashboard: warnings at 15 / 7 / 3 days before the takedown day
CREATE VIEW v_media_expiry_alerts WITH (security_invoker = true) AS
SELECT a.id, a.fingerprint, a.brand_id, a.asset_name, a.kind, a.consent_subject, a.patient_ref, a.person_fp,
       a.use_until, a.remove_on, (a.remove_on - fn_media_today()) AS days_to_takedown,
       CASE WHEN a.remove_on - fn_media_today() <= 3 THEN '3d'
            WHEN a.remove_on - fn_media_today() <= 7 THEN '7d' ELSE '15d' END AS alert_level,
       (SELECT count(*) FROM seo_media_asset_usages u WHERE u.asset_id = a.id AND u.removed_at IS NULL) AS live_usages
FROM seo_media_assets a
WHERE a.status = 'Active' AND a.consent_subject <> 'none' AND NOT a.use_forever
  AND a.remove_on - fn_media_today() BETWEEN 1 AND 15;

-- brand job input: everything that must leave the CDN now (status already flipped, or about to be)
CREATE VIEW v_media_due_takedown WITH (security_invoker = true) AS
SELECT a.id, a.fingerprint, a.asset_name, a.brand_id, a.status, a.consent_status, a.use_until, a.remove_on,
       a.r2_bucket, a.r2_object_key, a.cdn_url, a.delivery
FROM seo_media_assets a
WHERE a.quarantined_at IS NULL AND a.r2_object_key IS NOT NULL
  AND (a.status IN ('Expired','Revoked')
       OR (a.consent_subject <> 'none' AND (a.consent_status = 'Revoked'
           OR (NOT a.use_forever AND a.remove_on <= fn_media_today()))));

CREATE VIEW v_media_quarantine WITH (security_invoker = true) AS
SELECT a.id, a.fingerprint, a.asset_name, a.brand_id, a.status, a.quarantined_at, a.quarantine_key,
       (a.quarantined_at + interval '90 days')::date AS purge_on,
       ((a.quarantined_at + interval '90 days')::date <= fn_media_today()) AS purge_due,
       (SELECT max(e.at) FROM seo_media_asset_events e WHERE e.asset_id = a.id AND e.event = 'cdn_verified_404') AS last_verified_404,
       EXISTS (SELECT 1 FROM seo_media_asset_events e WHERE e.asset_id = a.id AND e.event = 'leak_detected'
               AND e.at > coalesce((SELECT max(v.at) FROM seo_media_asset_events v WHERE v.asset_id = a.id AND v.event = 'cdn_verified_404'), '-infinity')) AS open_leak
FROM seo_media_assets a
WHERE a.quarantined_at IS NOT NULL AND a.purged_at IS NULL;

-- build gate: a live usage pointing at something not servable fails the build
CREATE VIEW v_media_usage_blocked WITH (security_invoker = true) AS
SELECT u.id AS usage_id, u.page_fingerprint, u.slot, u.locale, a.id AS asset_id, a.fingerprint, a.asset_name, a.status,
       a.quarantined_at, a.remove_on
FROM seo_media_asset_usages u
JOIN seo_media_assets a ON a.id = u.asset_id
WHERE u.removed_at IS NULL
  AND NOT EXISTS (SELECT 1 FROM seo_servable_media s WHERE s.id = a.id);

-- text gaps: missing locale, stale (written for another key), AI result without its label
CREATE VIEW v_media_text_issues WITH (security_invoker = true) AS
WITH need AS (
  -- locale NULL on a usage = every language row of that page: the row itself + its translation rows
  SELECT DISTINCT u.asset_id, p.page_language AS locale
  FROM seo_media_asset_usages u
  JOIN seo_website_page_master p
    ON p.page_fingerprint = u.page_fingerprint OR p.source_translation_fp = u.page_fingerprint
  WHERE u.removed_at IS NULL AND (u.locale IS NULL OR u.locale = p.page_language)
)
SELECT n.asset_id, a.fingerprint, a.asset_name, n.locale,
       CASE WHEN t.asset_id IS NULL OR t.alt IS NULL THEN 'missing_alt'
            WHEN t.written_for_key IS DISTINCT FROM a.r2_object_key THEN 'stale_alt'
            WHEN a.kind = 'result_simulation' AND t.alt !~* '(AI|เอไอ)' THEN 'simulation_label_missing'
       END AS issue
FROM need n
JOIN seo_media_assets a ON a.id = n.asset_id
LEFT JOIN seo_media_asset_texts t ON t.asset_id = n.asset_id AND t.locale = n.locale
WHERE t.asset_id IS NULL OR t.alt IS NULL
   OR t.written_for_key IS DISTINCT FROM a.r2_object_key
   OR (a.kind = 'result_simulation' AND t.alt !~* '(AI|เอไอ)');

-- ── daily sweep (DB side) ───────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_media_daily_sweep() RETURNS jsonb
LANGUAGE plpgsql AS $$
DECLARE
  today date := fn_media_today();
  n_warn int := 0; n_expired int := 0; n_revoked int := 0;
BEGIN
  -- warnings: one event per threshold per asset (unique index makes re-runs harmless)
  INSERT INTO seo_media_asset_events (asset_id, event, detail, actor)
  SELECT a.id, 'warning_' || t.d || 'd', jsonb_build_object('remove_on', a.remove_on, 'use_until', a.use_until), 'fn_media_daily_sweep'
  FROM seo_media_assets a
  CROSS JOIN (VALUES (15), (7), (3)) AS t(d)
  WHERE a.status = 'Active' AND a.consent_subject <> 'none' AND NOT a.use_forever
    AND a.remove_on - today <= t.d AND a.remove_on - today > 0
  ON CONFLICT DO NOTHING;
  GET DIAGNOSTICS n_warn = ROW_COUNT;

  -- revoked consent: out now
  UPDATE seo_media_assets SET status = 'Revoked', expired_at = now()
  WHERE status = 'Active' AND consent_status = 'Revoked';
  GET DIAGNOSTICS n_revoked = ROW_COUNT;

  -- takedown day reached (use_until - 1)
  UPDATE seo_media_assets SET status = 'Expired', expired_at = now()
  WHERE status = 'Active' AND consent_subject <> 'none' AND NOT use_forever AND remove_on <= today;
  GET DIAGNOSTICS n_expired = ROW_COUNT;

  INSERT INTO seo_media_asset_events (asset_id, event, detail, actor)
  SELECT d.id, 'takedown_due', jsonb_build_object('status', d.status, 'remove_on', d.remove_on), 'fn_media_daily_sweep'
  FROM v_media_due_takedown d
  ON CONFLICT DO NOTHING;

  RETURN jsonb_build_object('date', today, 'warnings', n_warn, 'expired', n_expired, 'revoked', n_revoked);
END $$;

-- ── comments ────────────────────────────────────────────────────────────────────────────────────
COMMENT ON COLUMN seo_media_assets.kind IS 'What the asset is for (DR-085): hero · illustration · diagram · icon · equipment · clinic_space · portrait · case_before_after · review_photo · testimonial · result_simulation (AI, labelled on the image, Ayrel A10) · og_card · logo · video_hero_loop · video_explainer · video_testimonial.';
COMMENT ON COLUMN seo_media_assets.consent_subject IS 'Who is identifiable in the frame: none · patient · staff · customer · model. Anything but none = consent lifecycle + gated_worker delivery + takedown on remove_on. DR-085.';
COMMENT ON COLUMN seo_media_assets.remove_on IS 'Takedown day = use_until - 1 (operator 2026-11-20): removed the day before the last day on the consent, so no time-of-day or timezone reading can keep it online past the agreed date.';
COMMENT ON COLUMN seo_media_assets.person_fp IS 'The person shown (seo_authors_reviewers.fingerprint) for portraits of doctors/staff; a person can have one asset per brand (DR-040 per-brand buckets). DR-085.';
COMMENT ON COLUMN seo_media_assets.alt_th IS 'Superseded by seo_media_asset_texts (one row per locale, DR-085). Kept for the Notion mirror.';
COMMENT ON COLUMN seo_media_assets.alt_en IS 'Superseded by seo_media_asset_texts (one row per locale, DR-085). Kept for the Notion mirror.';
COMMENT ON TABLE seo_media_asset_texts IS 'alt / caption / transcript per locale. written_for_key = the r2_object_key described; when the asset key differs the text is stale (v_media_text_issues). DR-085.';
COMMENT ON TABLE seo_media_asset_usages IS 'Which page uses which asset in which slot; one asset may serve many related pages. A taken-down asset lists its pages here (v_media_usage_blocked fails the build). DR-085.';
COMMENT ON TABLE seo_media_asset_events IS 'Append-only audit trail of every registration, status change, warning, quarantine, purge, CDN verification and leak. DR-085.';
COMMENT ON VIEW seo_servable_media IS 'The only media a site build or the gate Worker may read. Person media needs Obtained consent and today < remove_on (Asia/Bangkok). DR-085.';

-- RLS: the 3 new tables follow K0a (RLS on, no policy — service role only), like seo_media_assets.
ALTER TABLE seo_media_asset_texts  ENABLE ROW LEVEL SECURITY;
ALTER TABLE seo_media_asset_usages ENABLE ROW LEVEL SECURITY;
ALTER TABLE seo_media_asset_events ENABLE ROW LEVEL SECURITY;

COMMIT;

-- Outside the transaction: schedule the DB sweep. pg_cron runs in UTC: 17:05 UTC = 00:05 Asia/Bangkok.
SELECT cron.schedule('eywa-media-daily-sweep', '5 17 * * *', $$SELECT public.fn_media_daily_sweep()$$);
