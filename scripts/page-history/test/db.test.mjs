import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadTargets, loadStates, saveResult } from '../db.mjs';

// Fake supabase: chainable builder that records eq args; range pages through the configured rows.
// fail: {log: n, state: n} = number of times a write to that table fails before succeeding.
function fakeDb({ rows = [], fail = {} } = {}) {
  const calls = []; const eqs = []; const left = { log: fail.log ?? 0, state: fail.state ?? 0 };
  const run = (kind, table, r, o) => {
    const t = table === 'seo_page_change_log' ? 'log' : 'state';
    calls.push([`${kind}-${t}`, table, r.length, o, r]);
    if (left[t] > 0) { left[t]--; return Promise.resolve({ error: { message: `${t} boom` } }); }
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
  assert.deepEqual(kinds(db), ['upsert-log:250', 'upsert-state:1', 'upsert-log:2', 'upsert-state:1', 'upsert-state:1']);
  assert.equal(db.calls[1][4][0].page_fp, 'a');
  assert.equal(db.calls[4][4][0].page_fp, 'c');
  assert.equal(db.calls[4][3].onConflict, 'page_fp');
});

test('saveResult batches states without log rows in chunks of 200', async () => {
  const db = fakeDb();
  await saveResult(db, { log: [], states: Array.from({ length: 201 }, (_, i) => ({ page_fp: `p${i}` })) }, { wait: nowait });
  assert.deepEqual(kinds(db), ['upsert-state:200', 'upsert-state:1']);
});

test('saveResult retries a failed request once then succeeds', async () => {
  const waits = []; const db = fakeDb({ fail: { log: 1 } });
  await saveResult(db, { log: L('a'), states: [{ page_fp: 'a' }] }, { wait: (ms) => { waits.push(ms); return Promise.resolve(); } });
  assert.deepEqual(kinds(db), ['upsert-log:1', 'upsert-log:1', 'upsert-state:1']);
  assert.deepEqual(waits, [2000]);
});

test("saveResult does not upsert a page's state when its log insert fails twice and names the page in the error", async () => {
  const db = fakeDb({ fail: { log: 2 } });
  await assert.rejects(saveResult(db, { log: L('page_X'), states: [{ page_fp: 'page_X' }] }, { wait: nowait }), /page_X log insert: log boom/);
  assert.equal(db.calls.some((c) => c[0] === 'upsert-state'), false);
});

test('saveResult names the step when state upsert fails twice', async () => {
  await assert.rejects(saveResult(fakeDb({ fail: { state: 2 } }), { log: [], states: [{ page_fp: 'a' }] }, { wait: nowait }), /batch state upsert: state boom/);
});

test('saving the same page rows twice uses ignoreDuplicates on id', async () => {
  const db = fakeDb();
  const res = { log: [{ id: 'x', page_fp: 'a' }], states: [{ page_fp: 'a' }] };
  await saveResult(db, res, { wait: nowait });
  await saveResult(db, res, { wait: nowait });
  const logCalls = db.calls.filter((c) => c[0] === 'upsert-log');
  assert.equal(logCalls.length, 2);
  for (const c of logCalls) assert.deepEqual(c[3], { onConflict: 'id', ignoreDuplicates: true });
  assert.equal(db.calls.some((c) => c[0].startsWith('insert')), false);
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
