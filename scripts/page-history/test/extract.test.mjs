import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { extractFields } from '../extract.mjs';

const read = (f) => readFileSync(new URL(`../fixtures/${f}`, import.meta.url), 'utf8');
const pageA = read('page-a.html');
const noise = read('page-a-noise.html');

test('extracts head fields', () => {
  const f = extractFields(pageA, {});
  assert.equal(f.title, 'Dental Implants & Veneers | VTH BioDent');
  assert.equal(f.meta_description, 'Implants & veneers by a certified team in Bangkok.');
  assert.equal(f.h1, 'Dental Implants');
  assert.equal(f.canonical, 'https://vthbiodent.com/implants');
  assert.equal(f.robots, 'index, follow');
  assert.match(f.content_hash, /^[0-9a-f]{64}$/);
});

test('schema_types walks @graph, flattens arrays, dedupes, sorts, skips bad JSON', () => {
  assert.deepEqual(extractFields(pageA, {}).schema_types, ['FAQPage', 'MedicalClinic', 'WebPage']);
});

test('content_hash ignores script/style/nav/footer and ignore_selectors', () => {
  const cfg = { ignore_selectors: ['.ago'] };
  assert.equal(extractFields(pageA, cfg).content_hash, extractFields(noise, cfg).content_hash);
  // without ignore_selectors the relative-time div leaks into the hash
  assert.notEqual(extractFields(pageA, {}).content_hash, extractFields(noise, {}).content_hash);
});

test('content_hash changes when main text changes', () => {
  const cfg = { ignore_selectors: ['.ago'] };
  const edited = pageA.replace('with care', 'with great care');
  assert.notEqual(extractFields(edited, cfg).content_hash, extractFields(pageA, cfg).content_hash);
});

test('main_selector and fallbacks', () => {
  const html = '<body><div id="x">one</div><article>art</article></body>';
  const h = (cfg) => extractFields(html, cfg).content_hash;
  assert.notEqual(h({ main_selector: '#x' }), h({}));
  assert.equal(h({ main_selector: '#missing' }), h({}));
});

test('missing tags give null, never throw', () => {
  const f = extractFields('<html><body><p>hi</p></body></html>', {});
  assert.deepEqual(
    [f.title, f.meta_description, f.h1, f.canonical, f.robots, f.schema_types],
    [null, null, null, null, null, []]
  );
  assert.doesNotThrow(() => extractFields('', {}));
});

test('content_hash identical for minified vs pretty-printed same page', () => {
  const h = (html) => extractFields(html, {}).content_hash;
  assert.equal(h('<main><p>a</p>\n<p>b</p></main>'), h('<main><p>a</p><p>b</p></main>'));
  assert.equal(h('<main><ul><li>a</li><li>b</li></ul></main>'), h('<main>\n  <ul>\n    <li>a</li>\n    <li>b</li>\n  </ul>\n</main>'));
  assert.notEqual(h('<main><p>a</p><p>b</p></main>'), h('<main><p>a</p><p>c</p></main>'));
});

test('content_hash ignores markup inside <pre>', () => {
  const h = (c) => extractFields(`<main><pre><span class="${c}">x</span></pre></main>`, {}).content_hash;
  assert.equal(h('a'), h('b'));
});
