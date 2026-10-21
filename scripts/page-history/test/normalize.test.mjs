import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { normUrl, normText } from '../normalize.mjs';

const cases = JSON.parse(readFileSync(new URL('../fixtures/url-cases.json', import.meta.url), 'utf8'));

test('normUrl matches shared fixture (and SQL seo_norm_url)', () => {
  for (const c of cases) assert.equal(normUrl(c.in), c.out, c.in);
});

test('normUrl returns non-URL input as is', () => assert.equal(normUrl('/rel/path/'), '/rel/path/'));

test('normText', () => {
  assert.equal(normText('  a&amp;b \n c '), 'a&b c');
  assert.equal(normText('  '), null);
  assert.equal(normText(null), null);
  assert.equal(normText(undefined), null);
});
