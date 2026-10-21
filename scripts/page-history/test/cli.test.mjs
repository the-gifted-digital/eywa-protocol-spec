import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const crawl = join(dirname(fileURLToPath(import.meta.url)), '..', 'crawl.mjs');
const run = (args, env) => spawnSync('node', [crawl, ...args], { encoding: 'utf8', timeout: 15000, env: { PATH: process.env.PATH, ...env } });

test('CLI exits 1 with the standard message when SUPABASE_SERVICE_KEY is missing', () => {
  const r = run(['--brand', 'nobrand', '--dry-run'], {});
  assert.equal(r.status, 1);
  assert.match(r.stderr, /No SUPABASE_SERVICE_KEY/);
});

test('CLI exits 1 on bad ignore_selectors config before any IO', () => {
  const dir = mkdtempSync(join(process.env.TMPDIR ?? tmpdir(), 'ph-'));
  try {
    writeFileSync(join(dir, 'bad.json'), JSON.stringify({ ignore_selectors: ['['] }));
    // dummy key + no key check reached: config is validated first, so no network/DB call happens
    const r = run(['--brand', 'bad', '--dry-run', '--brands-dir', dir], { SUPABASE_SERVICE_KEY: 'dummy' });
    assert.equal(r.status, 1);
    assert.match(r.stderr, /config error for brand bad/);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
