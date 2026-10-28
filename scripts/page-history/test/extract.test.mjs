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

test('links: same-host, normalised, aggregated, self/mailto/tel/#/js/external dropped', () => {
  const { links } = extractFields(read('links.html'), {}, 'https://www.vthbiodent.com/team/');
  const by = Object.fromEntries(links.map((l) => [l.to_slug, l]));
  assert.deepEqual(Object.keys(by).sort(), ['about', 'contact', 'home', 'implants', 'privacy', 'team/dr-x', 'veneers']);
  // relative + absolute + www vs bare + query/fragment stripped -> one row
  assert.deepEqual(by.implants, { to_url: 'https://vthbiodent.com/implants', to_slug: 'implants',
    anchor: 'dental implants', in_main: true, nofollow: false, occurrences: 3 });
  assert.equal(by.home.to_url, 'https://vthbiodent.com/');
  assert.equal(by.home.in_main, false);
  assert.equal(by.privacy.in_main, false);
  // nested slug; nav occurrence first, main occurrence wins in_main + anchor; nofollow only if every occurrence is
  assert.deepEqual(by['team/dr-x'], { to_url: 'https://vthbiodent.com/team/dr-x', to_slug: 'team/dr-x',
    anchor: 'Dr. X & team', in_main: true, nofollow: false, occurrences: 2 });
  assert.equal(by.about.nofollow, false);
  assert.equal(by.veneers.anchor, 'Veneers gallery');
  assert.equal(by.contact.anchor, 'Contact the clinic');
});

test('links: nofollow when every occurrence has it; main_selector decides in_main; anchor capped at 200', () => {
  const long = 'x'.repeat(300);
  const html = `<body><div id="c"><a href="/a" rel="NoFollow">${long}</a></div><div id="side"><a href="/b">b</a></div></body>`;
  const { links } = extractFields(html, { main_selector: '#c' }, 'https://e.com/p');
  assert.deepEqual(links.map((l) => [l.to_slug, l.in_main, l.nofollow]), [['a', true, true], ['b', false, false]]);
  assert.equal(links[0].anchor.length, 200);
});

test('links: empty without a page url, and the main-content strip does not hide nav links', () => {
  assert.deepEqual(extractFields(read('links.html'), {}).links, []);
  const a = extractFields(read('links.html'), {}, 'https://vthbiodent.com/team');
  assert.equal(a.content_hash, extractFields(read('links.html'), {}).content_hash); // links don't change the hash
});
