import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadTargets, saveResult } from '../db.mjs';

// Fake supabase: every builder method chains; await / range resolve to the configured result.
function fakeDb({ rows = [], failInsert = false, failUpsert = false } = {}) {
  const calls = [];
  const db = {
    calls,
    from(table) {
      const q = {
        select: () => q, eq: () => q, not: () => q, order: () => q,
        range: (a, b) => Promise.resolve({ data: rows.slice(a, b + 1), error: null }),
        insert: (r) => { calls.push(['insert', table, r.length]); return Promise.resolve({ error: failInsert ? { message: 'boom' } : null }); },
        upsert: (r, o) => { calls.push(['upsert', table, r.length, o]); return Promise.resolve({ error: failUpsert ? { message: 'boom2' } : null }); },
      };
      return q;
    },
  };
  return db;
}

test('saveResult inserts log before upserting state', async () => {
  const db = fakeDb();
  await saveResult(db, { log: Array(250).fill({}), states: Array(201).fill({}) });
  assert.deepEqual(db.calls.map((c) => c.slice(0, 3).join(':')),
    ['insert:seo_page_change_log:200', 'insert:seo_page_change_log:50', 'upsert:seo_page_live_state:200', 'upsert:seo_page_live_state:1']);
  assert.equal(db.calls[2][3].onConflict, 'page_fp');
});

test('saveResult does not upsert when log insert throws', async () => {
  const db = fakeDb({ failInsert: true });
  await assert.rejects(saveResult(db, { log: [{}], states: [{}] }), /boom/);
  assert.equal(db.calls.some((c) => c[0] === 'upsert'), false);
});

test('saveResult throws on upsert error', async () => {
  await assert.rejects(saveResult(fakeDb({ failUpsert: true }), { log: [], states: [{}] }), /boom2/);
});

test('loadTargets dedups by normalised url and warns', async () => {
  const rows = [
    { fingerprint: 'page_A', brand_id: 'b', canonical_url: 'https://www.example.com/x/' },
    { fingerprint: 'page_B', brand_id: 'b', canonical_url: 'https://example.com/x' },
    { fingerprint: 'page_C', brand_id: 'b', canonical_url: 'https://example.com/y' },
  ];
  const warns = [];
  const orig = console.warn; console.warn = (m) => warns.push(m);
  let t; try { t = await loadTargets(fakeDb({ rows }), 'b'); } finally { console.warn = orig; }
  assert.deepEqual(t, [
    { page_fp: 'page_A', brand_id: 'b', url: 'https://www.example.com/x/' },
    { page_fp: 'page_C', brand_id: 'b', url: 'https://example.com/y' }]);
  assert.equal(warns.length, 1);
});
