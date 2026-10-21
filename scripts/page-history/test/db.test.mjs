import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadTargets, loadStates, saveResult } from '../db.mjs';

// Fake supabase: chainable builder that records eq args; range pages through the configured rows.
// fail: {insert: n, upsert: n} = number of times that request type fails before succeeding.
function fakeDb({ rows = [], fail = {} } = {}) {
  const calls = []; const eqs = []; const left = { insert: fail.insert ?? 0, upsert: fail.upsert ?? 0 };
  const run = (kind, table, r, o) => {
    calls.push([kind, table, r.length, o, r]);
    if (left[kind] > 0) { left[kind]--; return Promise.resolve({ error: { message: `${kind} boom` } }); }
    return Promise.resolve({ error: null });
  };
  return {
    calls, eqs,
    from(table) {
      const q = {
        select: () => q, not: () => q, order: () => q,
        eq: (c, v) => { eqs.push([c, v]); return q; },
        range: (a, b) => Promise.resolve({ data: rows.slice(a, b + 1), error: null }),
        insert: (r) => run('insert', table, r),
        upsert: (r, o) => run('upsert', table, r, o),
      };
      return q;
    },
  };
}
const nowait = () => Promise.resolve();
const L = (fp, n = 1) => Array.from({ length: n }, () => ({ page_fp: fp }));
const kinds = (db) => db.calls.map((c) => `${c[0]}:${c[2]}`);

test('saveResult saves each changed page as one log insert followed by its state upsert', async () => {
  const db = fakeDb();
  await saveResult(db, { log: [...L('a', 250), ...L('b', 2)], states: [{ page_fp: 'a' }, { page_fp: 'b' }, { page_fp: 'c' }] }, { wait: nowait });
  assert.deepEqual(kinds(db), ['insert:250', 'upsert:1', 'insert:2', 'upsert:1', 'upsert:1']);
  assert.equal(db.calls[1][4][0].page_fp, 'a');
  assert.equal(db.calls[4][4][0].page_fp, 'c');
  assert.equal(db.calls[4][3].onConflict, 'page_fp');
});

test('saveResult batches states without log rows in chunks of 200', async () => {
  const db = fakeDb();
  await saveResult(db, { log: [], states: Array.from({ length: 201 }, (_, i) => ({ page_fp: `p${i}` })) }, { wait: nowait });
  assert.deepEqual(kinds(db), ['upsert:200', 'upsert:1']);
});

test('saveResult retries a failed request once then succeeds', async () => {
  const waits = []; const db = fakeDb({ fail: { insert: 1 } });
  await saveResult(db, { log: L('a'), states: [{ page_fp: 'a' }] }, { wait: (ms) => { waits.push(ms); return Promise.resolve(); } });
  assert.deepEqual(kinds(db), ['insert:1', 'insert:1', 'upsert:1']);
  assert.deepEqual(waits, [2000]);
});

test("saveResult does not upsert a page's state when its log insert fails twice and names the page in the error", async () => {
  const db = fakeDb({ fail: { insert: 2 } });
  await assert.rejects(saveResult(db, { log: L('page_X'), states: [{ page_fp: 'page_X' }] }, { wait: nowait }), /page_X log insert: insert boom/);
  assert.equal(db.calls.some((c) => c[0] === 'upsert'), false);
});

test('saveResult names the step when state upsert fails twice', async () => {
  await assert.rejects(saveResult(fakeDb({ fail: { upsert: 2 } }), { log: [], states: [{ page_fp: 'a' }] }, { wait: nowait }), /batch state upsert: upsert boom/);
});

const many = (n, f) => Array.from({ length: n }, (_, i) => f(i));

test('loadTargets filters by brand_id and pages past 1000 rows', async () => {
  const rows = many(2300, (i) => ({ fingerprint: `p${i}`, brand_id: 'b', canonical_url: `https://e.com/${i}` }));
  const db = fakeDb({ rows });
  const t = await loadTargets(db, 'b');
  assert.equal(t.length, 2300);
  assert.ok(db.eqs.some(([c, v]) => c === 'brand_id' && v === 'b'));
  assert.ok(db.eqs.some(([c, v]) => c === 'status' && v === 'Live'));
});

test('loadStates filters by brand_id and pages past 1000 rows', async () => {
  const rows = many(2300, (i) => ({ page_fp: `p${i}`, brand_id: 'b' }));
  const db = fakeDb({ rows });
  const m = await loadStates(db, 'b');
  assert.equal(m.size, 2300);
  assert.ok(db.eqs.some(([c, v]) => c === 'brand_id' && v === 'b'));
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
