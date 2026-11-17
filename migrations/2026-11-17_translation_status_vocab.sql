-- 2026-11-17_translation_status_vocab.sql — APPLIED 2026-11-17 (operator: "ปรับให้หมดเลย")
-- Shared table. See BROADCAST-2026-11-17-multilingual-rows.md.
--
-- translation_status now describes a row AS A TRANSLATION and nothing else:
--   pending / in_progress / live / stale on rows that have a source_translation_fp,
--   NULL on source rows.
-- Before this, three brands carried 'pending' on Thai source rows that had no translation
-- (it said nothing) and deezy used 'published', a word the column comment never listed.
--
-- Rows changed: 2,010
--   deezy-dental   78  translation rows   published -> live
--   deezy-dental  696  source rows        pending (657) / published (39) -> NULL
--   tc-smile      474  source rows        pending -> NULL
--   vth-biodent   762  source rows        pending -> NULL
-- After: 3,787 source rows NULL, 87 translation rows 'live' (78 deezy + 9 vth).
-- No code in any brand repo filters on these values (grep 2026-11-17: only load SQL writes them).
-- updated_at moved on all 2,010 rows (update_wpm_updated_at trigger).
--
-- To restore the old values exactly: tc-smile and vth sources (except vth-1) -> 'pending';
-- deezy sources with translations_versions_fps -> 'published'; other deezy sources -> 'pending'
-- EXCEPT the 116 that were already NULL: deezy-9.1.1..36, deezy-9.3.1..36, deezy-9.5.1..36,
-- deezy-2.10.1, deezy-6.9, deezy-8.3.11, deezy-8.5.7, deezy-8.6, deezy-8.6.1, deezy-8.6.2,
-- deezy-8.7. deezy translation rows -> 'published'. Drop the CHECK first.

BEGIN;

UPDATE seo_website_page_master SET translation_status = 'live'
WHERE source_translation_fp IS NOT NULL AND translation_status = 'published';

UPDATE seo_website_page_master SET translation_status = NULL
WHERE source_translation_fp IS NULL AND translation_status IN ('pending','published');

COMMIT;

ALTER TABLE seo_website_page_master
  ADD CONSTRAINT chk_page_master_translation_status
  CHECK (translation_status IS NULL OR translation_status IN ('pending','in_progress','live','stale'));

COMMENT ON COLUMN seo_website_page_master.translation_status IS
  'State of THIS row as a translation: pending (row exists, not translated) / in_progress (being translated or self-checked) / live (shipped; stamp-live sets it) / stale (the source changed after this was translated). NULL on a source row (source_translation_fp IS NULL): the column describes translations only. Vocabulary set 2026-11-17 (BROADCAST-2026-11-17-multilingual-rows).';

COMMENT ON COLUMN seo_website_page_master.page_language IS
  'Locale of THIS row, matching the URL prefix and the content folder (th, en, zh-cn, ar, ...). One row per page per language. A translation row is `<source page_fingerprint>-<locale>` with slug `<source slug>-<locale>`; versions are tied together by source_translation_fp (on the translation) + translations_versions_fps (on the source).';
