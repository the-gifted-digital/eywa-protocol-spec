import test from 'node:test';
import assert from 'node:assert/strict';
import { decide, FAIL_THRESHOLD } from '../diff.mjs';

const URL1 = 'https://example.com/a';
const T0 = new Date('2026-10-01T00:00:00Z');
const T1 = new Date('2026-10-02T00:00:00Z');
const fields = (o = {}) => ({
  title: 'T', meta_description: 'M', h1: 'H', canonical: URL1, robots: 'index',
  schema_types: ['A', 'B'], content_hash: 'h1', ...o,
});
const ok = (o = {}, f = {}) => ({
  kind: 'ok', http_status: 200, final_url: URL1, etag: 'e1', last_modified: 'lm1', fields: fields(f), ...o,
});
const fail = (s = 503) => ({ kind: 'fail', http_status: s, error: 'x' });
const IDS = { page_fp: 'fp1', brand_id: 'b1' };
const base = () => decide(null, ok(), URL1, T0, 'r0', IDS).state;
const run = (prev, obs, url = URL1) => decide(prev, obs, url, T1, 'r1');
const deepFreeze = (o) => { Object.values(o).forEach((v) => v && typeof v === 'object' && deepFreeze(v)); return Object.freeze(o); };

test('first ok is baseline', () => {
  const { log, state } = decide(null, ok(), URL1, T0, 'r0', IDS);
  assert.equal(log.length, 0);
  assert.equal(state.title, 'T');
  assert.equal(state.page_fp, 'fp1');
  assert.deepEqual(state.schema_types, ['A', 'B']);
  assert.equal(state.first_seen_at, T0.toISOString());
  assert.equal(state.last_ok_at, T0.toISOString());
  assert.equal(state.url, URL1);
  assert.equal(state.etag, 'e1');
});

test('unchanged ok writes nothing', () => {
  assert.equal(run(base(), ok()).log.length, 0);
});

test('title change logs exactly one title row', () => {
  const prev = base();
  const { log } = run(prev, ok({}, { title: 'New' }));
  assert.match(log[0].id, /^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/);
  assert.deepEqual(log, [{
    id: log[0].id, page_fp: prev.page_fp, brand_id: prev.brand_id, field: 'title', old_value: 'T', new_value: 'New',
    detected_at: T1.toISOString(), prev_ok_at: prev.last_ok_at, run_id: 'r1',
  }]);
});

test('schema_types order-insensitive', () => {
  const { log, state } = run(base(), ok({}, { schema_types: ['B', 'A'] }));
  assert.equal(log.length, 0);
  assert.deepEqual(state.schema_types, ['A', 'B']);
});

test('two failures write nothing; third writes one http_status row; fourth writes nothing', () => {
  let s = base();
  const logs = [];
  for (let i = 0; i < FAIL_THRESHOLD + 1; i++) {
    const r = run(s, fail());
    logs.push(r.log); s = r.state;
  }
  assert.deepEqual(logs.map((l) => l.length), [0, 0, 1, 0]);
  assert.equal(logs[2][0].field, 'http_status');
  assert.equal(logs[2][0].old_value, 200);
  assert.equal(logs[2][0].new_value, 503);
  assert.equal(s.consecutive_failures, 4);
  assert.equal(s.title, 'T');
});

test('fetch error logs fetch_error string', () => {
  let s = { ...base(), consecutive_failures: FAIL_THRESHOLD - 1 };
  const r = run(s, { kind: 'fail', http_status: null, error: 'dns' });
  assert.equal(r.log[0].new_value, 'fetch_error');
  assert.equal(r.state.http_status, 0);
});

test('first ok after only failures is a baseline', () => {
  let prev = decide(null, fail(), URL1, T0, 'r0', IDS).state;
  prev = decide(prev, fail(), URL1, T0, 'r0').state;
  const { log, state } = run(prev, ok());
  assert.equal(log.length, 0);
  assert.equal(state.last_ok_at, T1.toISOString());
  assert.equal(state.first_seen_at, T1.toISOString());
  assert.equal(state.consecutive_failures, 0);
});

test('recovery after logged failure logs http_status back and diffs fields normally', () => {
  const prev = { ...base(), http_status: 503, consecutive_failures: 3 };
  const { log, state } = run(prev, ok({}, { title: 'New' }));
  assert.deepEqual(log.map((l) => l.field).sort(), ['http_status', 'title']);
  const hs = log.find((l) => l.field === 'http_status');
  assert.equal(hs.old_value, 503); assert.equal(hs.new_value, 200);
  assert.equal(state.consecutive_failures, 0);
});

test('url change logs url and diffs other fields', () => {
  const { log, state } = run(base(), ok({ final_url: 'https://example.com/b' }, { canonical: 'https://example.com/b' }), 'https://example.com/b');
  assert.deepEqual(log.map((l) => l.field).sort(), ['canonical', 'final_url', 'url']);
  assert.equal(state.url, 'https://example.com/b');
});

test('url change with identical observation logs exactly 1 url row', () => {
  const { log } = run(base(), ok(), 'https://example.com/b');
  assert.deepEqual(log.map((l) => l.field), ['url']);
});

test('url change applies to fail obs when page was OK before', () => {
  const { log, state } = run(base(), fail(), 'https://example.com/b');
  assert.deepEqual(log.map((l) => l.field), ['url']);
  assert.equal(state.url, 'https://example.com/b');
});

test('url change never logs when page was never OK', () => {
  const prev = { ...base(), last_ok_at: null, consecutive_failures: 1 };
  assert.equal(run(prev, fail(), 'https://example.com/b').log.length, 0);
  const r = run(prev, ok(), 'https://example.com/b');
  assert.equal(r.log.length, 0);
  assert.equal(r.state.url, 'https://example.com/b');
});

test('redirect logs final_url', () => {
  const { log } = run(base(), ok({ final_url: 'https://example.com/new' }));
  assert.deepEqual(log.map((l) => [l.field, l.old_value, l.new_value]), [['final_url', URL1, 'https://example.com/new']]);
});

test('absent field logs null old_value', () => {
  const prev = decide(null, ok({}, { h1: null }), URL1, T0, 'r0', IDS).state;
  const { log } = run(prev, ok({}, { h1: 'Hi' }));
  assert.deepEqual(log.map((l) => [l.field, l.old_value, l.new_value]), [['h1', null, 'Hi']]);
});

test('not_modified resets failures and logs nothing', () => {
  const prev = { ...base(), consecutive_failures: 2, etag: 'keep' };
  const { log, state } = run(prev, { kind: 'not_modified' });
  assert.equal(log.length, 0);
  assert.equal(state.consecutive_failures, 0);
  assert.equal(state.last_ok_at, T1.toISOString());
  assert.equal(state.last_checked_at, T1.toISOString());
  assert.equal(state.etag, 'keep');
});

test('fail keeps etag and last_modified; ok replaces them', () => {
  const prev = base();
  assert.equal(run(prev, fail()).state.etag, 'e1');
  assert.equal(run(prev, ok({ etag: 'e2', last_modified: null })).state.etag, 'e2');
  assert.equal(run(prev, ok({ etag: 'e2', last_modified: null })).state.last_modified, null);
});

test('decide does not mutate prev or obs', () => {
  const prev = deepFreeze(base());
  const obs = deepFreeze(ok({}, { title: 'New', schema_types: ['B', 'A'] }));
  const before = JSON.stringify([prev, obs]);
  decide(prev, obs, 'https://example.com/z', T1, 'r1');
  decide(prev, deepFreeze(fail()), URL1, T1, 'r1');
  assert.equal(JSON.stringify([prev, obs]), before);
});

test('threshold after not_modified reset does not log identical http_status', () => {
  for (const f of [fail(503), { kind: 'fail', http_status: null, error: 'dns' }]) {
    let s = base();
    for (let i = 0; i < 3; i++) s = run(s, f).state;
    s = run(s, { kind: 'not_modified' }).state;
    const logs = [];
    for (let i = 0; i < 3; i++) { const r = run(s, f); logs.push(r.log.length); s = r.state; }
    assert.deepEqual(logs, [0, 0, 0]);
  }
});

test("recovery from fetch_error logs 'fetch_error' -> 200", () => {
  const prev = { ...base(), http_status: 0, consecutive_failures: 3 };
  const { log } = run(prev, ok());
  assert.deepEqual(log.map((l) => [l.field, l.old_value, l.new_value]), [['http_status', 'fetch_error', 200]]);
});

test('not_modified on never-OK page keeps it a baseline candidate', () => {
  let s = decide(null, fail(), URL1, T0, 'r0', IDS).state;
  s = run(s, { kind: 'not_modified' }).state;
  assert.equal(s.last_ok_at, null);
  assert.equal(s.consecutive_failures, 1);
  const r = run(s, ok());
  assert.equal(r.log.length, 0);
  assert.equal(r.state.last_ok_at, T1.toISOString());
});

test('log row id is deterministic for the same transition and differs when prev_ok_at differs', () => {
  const prev = base();
  const a = run(prev, ok({}, { title: 'New' })).log[0];
  const b = decide(prev, ok({}, { title: 'New' }), URL1, new Date('2026-10-03T00:00:00Z'), 'r2').log[0];
  assert.equal(a.id, b.id); // same transition, different run/time -> same id
  const c = run({ ...prev, last_ok_at: T1.toISOString() }, ok({}, { title: 'New' })).log[0];
  assert.notEqual(a.id, c.id);
  assert.notEqual(a.id, run(prev, ok({}, { title: 'Other' })).log[0].id);
});

test('Merged page: state gets http_status/final_url, content fields stay null and are never logged', () => {
  const M = { ...IDS, merged: true };
  const target = 'https://example.com/b';
  const m0 = decide(null, ok({ final_url: target, fields: {} }), URL1, T0, 'r0', M);
  assert.deepEqual(m0.log, []);
  assert.equal(m0.state.final_url, target); assert.equal(m0.state.http_status, 200);
  assert.equal(m0.state.consecutive_failures, 0); assert.ok(m0.state.last_ok_at);
  for (const k of ['title', 'meta_description', 'h1', 'canonical', 'robots', 'content_hash', 'schema_types']) assert.equal(m0.state[k], null);
  // same redirect next night: nothing logged; a Live page turning Merged drops its fields silently
  assert.deepEqual(decide(m0.state, ok({ final_url: target }), URL1, T1, 'r1', M).log, []);
  assert.deepEqual(decide(base(), ok({ final_url: URL1 }), URL1, T1, 'r1', M).log, []);
  // redirect removed / retargeted: only final_url is logged
  const moved = decide(m0.state, ok({ final_url: URL1 }), URL1, T1, 'r1', M);
  assert.deepEqual(moved.log.map((r) => [r.field, r.old_value, r.new_value]), [['final_url', target, URL1]]);
});
