import { createHash } from 'node:crypto';
import { parse } from 'node-html-parser';
import { collapse, normText } from './normalize.mjs';

const STRIP = 'script, style, noscript, nav, header, footer, svg, iframe';

function collectTypes(node, out) {
  if (Array.isArray(node)) return node.forEach((n) => collectTypes(n, out));
  if (!node || typeof node !== 'object') return;
  const t = node['@type'];
  for (const x of [].concat(t ?? [])) if (typeof x === 'string') out.add(x);
  if (node['@graph']) collectTypes(node['@graph'], out);
}

export function extractFields(html, cfg = {}) {
  const root = parse(html ?? '', { comment: false });
  const attr = (sel, name) => collapse(root.querySelector(sel)?.getAttribute(name)); // parser already decodes attrs
  const h1 = root.querySelector('h1');

  const types = new Set();
  for (const s of root.querySelectorAll('script[type="application/ld+json"]')) {
    try { collectTypes(JSON.parse(s.rawText), types); } catch { /* invalid JSON-LD: skip */ }
  }

  const main =
    (cfg.main_selector && root.querySelector(cfg.main_selector)) ||
    root.querySelector('main') || root.querySelector('article') || root.querySelector('body') || root;
  for (const sel of [STRIP, ...(cfg.ignore_selectors ?? [])].filter(Boolean)) {
    main.querySelectorAll(sel).forEach((n) => n.remove());
  }
  const text = normText(main.rawText) ?? '';

  return {
    title: normText(root.querySelector('title')?.rawText),
    meta_description: attr('meta[name="description" i]', 'content'),
    h1: h1 ? normText(h1.rawText) : null,
    canonical: attr('link[rel="canonical" i]', 'href'),
    robots: attr('meta[name="robots" i]', 'content'),
    schema_types: [...types].sort(),
    content_hash: createHash('sha256').update(text).digest('hex'),
  };
}
