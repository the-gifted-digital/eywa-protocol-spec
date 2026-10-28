import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import { fetchPage } from '../crawl.mjs';

let server, base; const seen = [];
before(async () => {
  server = http.createServer((req, res) => {
    seen.push({ url: req.url, h: req.headers });
    if (req.url === '/old') { res.writeHead(301, { location: '/new' }); return res.end(); }
    if (req.url === '/new') { res.writeHead(200, { 'content-type': 'text/html', etag: '"e1"', 'last-modified': 'Wed, 01 Jan 2025 00:00:00 GMT' }); return res.end('<html><head><title>Hi</title></head><body><h1>H</h1></body></html>'); }
    if (req.url === '/cond') {
      if (req.headers['if-none-match'] === '"e1"') { res.writeHead(304); return res.end(); }
      res.writeHead(200, { 'content-type': 'text/html' }); return res.end('<title>x</title>');
    }
    if (req.url === '/slow') return setTimeout(() => { res.writeHead(200); res.end('late'); }, 1500);
    res.writeHead(404); res.end('nope');
  });
  await new Promise((r) => server.listen(0, '127.0.0.1', r));
  base = `http://127.0.0.1:${server.address().port}`;
});
after(() => { server.closeAllConnections?.(); server.close(); });

const opts = { timeoutMs: 200, ua: 'test-ua' };
const healthy = (url, o = {}) => ({ url, last_ok_at: 'x', consecutive_failures: 0, http_status: 200, etag: '"e1"', last_modified: 'lm', ...o });

test('fetchPage returns ok with final_url after 301', async () => {
  const o = await fetchPage(`${base}/old`, null, opts);
  assert.equal(o.kind, 'ok'); assert.equal(o.http_status, 200);
  assert.equal(o.final_url, `${base}/new`);
  assert.equal(o.etag, '"e1"'); assert.equal(o.fields.title, 'Hi');
  assert.equal(seen.at(-1).h['user-agent'], 'test-ua');
});

test('returns not_modified on 304 when etag sent', async () => {
  const url = `${base}/cond`;
  const o = await fetchPage(url, healthy(url), opts);
  assert.equal(o.kind, 'not_modified');
  assert.equal(seen.at(-1).h['if-none-match'], '"e1"');
  assert.equal(seen.at(-1).h['if-modified-since'], 'lm');
});

test('does not send If-None-Match when url changed', async () => {
  const url = `${base}/cond`;
  const o = await fetchPage(url, healthy(`${base}/other`), opts);
  assert.equal(o.kind, 'ok');
  assert.equal(seen.at(-1).h['if-none-match'], undefined);
});

test('does not send conditional headers when prev is unhealthy', async () => {
  const url = `${base}/cond`;
  for (const bad of [{ http_status: 503 }, { consecutive_failures: 1 }, { last_ok_at: null }]) {
    const o = await fetchPage(url, healthy(url, bad), opts);
    assert.equal(o.kind, 'ok');
    assert.equal(seen.at(-1).h['if-none-match'], undefined);
    assert.equal(seen.at(-1).h['if-modified-since'], undefined);
  }
});

test('returns fail on 404 and on timeout', async () => {
  const a = await fetchPage(`${base}/missing`, null, opts);
  assert.equal(a.kind, 'fail'); assert.equal(a.http_status, 404);
  const b = await fetchPage(`${base}/slow`, null, opts);
  assert.equal(b.kind, 'fail'); assert.equal(b.http_status, null); assert.ok(b.error);
});

test('ok HTML returns links; Merged 301 to target is ok with final_url, no fields, no links, no conditional GET', async () => {
  const o = await fetchPage(`${base}/new`, null, opts);
  assert.deepEqual(o.links, []);
  assert.equal(o.fields.links, undefined);
  const url = `${base}/old`;
  const m = await fetchPage(url, healthy(url), { ...opts, merged: true });
  assert.equal(m.kind, 'ok'); assert.equal(m.http_status, 200);
  assert.equal(m.final_url, `${base}/new`);
  assert.deepEqual(m.fields, {}); assert.equal(m.links, null);
  assert.equal(seen.at(-1).h['if-none-match'], undefined);
});

test('non-HTML 2xx body gives links null (stored links left untouched)', async () => {
  const o = await fetchPage(`${base}/cond`, null, opts); // text/html
  assert.ok(Array.isArray(o.links));
  const s = await fetchPage(`${base}/slow`, null, { ...opts, timeoutMs: 3000 }); // no content-type
  assert.equal(s.kind, 'ok'); assert.equal(s.links, null);
});
