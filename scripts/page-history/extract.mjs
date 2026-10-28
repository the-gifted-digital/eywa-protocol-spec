import { createHash } from 'node:crypto';
import { parse } from 'node-html-parser';
import { collapse, normText, normUrl } from './normalize.mjs';

// Join text nodes with a space at every tag boundary so the hash ignores source whitespace/minification.
const textOf = (n) => (n.nodeType === 3 ? n.rawText.replace(/<[^>]*>/g, ' ') : // pre content arrives as one raw text node, strip its markup
   ` ${n.childNodes.map(textOf).join(' ')} `);

const STRIP = 'script, style, noscript, nav, header, footer, svg, iframe';

function collectTypes(node, out) {
  if (Array.isArray(node)) return node.forEach((n) => collectTypes(n, out));
  if (!node || typeof node !== 'object') return;
  const t = node['@type'];
  for (const x of [].concat(t ?? [])) if (typeof x === 'string') out.add(x);
  if (node['@graph']) collectTypes(node['@graph'], out);
}

// Mirror of SQL console.url_slug: path without leading/trailing '/', root = 'home'.
export const urlSlug = (u) => u.replace(/^https?:\/\/[^/]+/, '').replace(/^\/+|\/+$/g, '') || 'home';

const bareHost = (u) => u.host.toLowerCase().replace(/^www\./, '');
const OUTSIDE_MAIN = new Set(['nav', 'header', 'footer']);

// Same-host <a href> links of the whole document, aggregated per to_url (self-links dropped).
function collectLinks(root, main, pageUrl) {
  let page; try { page = new URL(pageUrl); } catch { return []; }
  const self = urlSlug(normUrl(page.origin + page.pathname));
  const out = new Map();
  for (const a of root.querySelectorAll('a[href]')) {
    const href = a.getAttribute('href').trim();
    if (!href || href.startsWith('#')) continue;
    let u; try { u = new URL(href, page); } catch { continue; }
    if ((u.protocol !== 'http:' && u.protocol !== 'https:') || bareHost(u) !== bareHost(page)) continue; // drops mailto/tel/javascript
    const to_url = normUrl(u.origin + u.pathname);
    const to_slug = urlSlug(to_url);
    if (to_slug === self) continue;
    let inMain = false; let outside = false;
    for (let n = a; n; n = n.parentNode) {
      if (n === main) inMain = true;
      if (OUTSIDE_MAIN.has(n.rawTagName?.toLowerCase())) outside = true;
    }
    inMain &&= !outside;
    const text = normText(a.rawText) ?? collapse(a.querySelector('img[alt]')?.getAttribute('alt')) ?? collapse(a.getAttribute('aria-label'));
    const anchor = text == null ? null : [...text].slice(0, 200).join('');
    const nofollow = /(^|\s)nofollow(\s|$)/i.test(a.getAttribute('rel') ?? '');
    const l = out.get(to_url);
    if (!l) { out.set(to_url, { to_url, to_slug, anchor, in_main: inMain, nofollow, occurrences: 1 }); continue; }
    l.occurrences++;
    l.nofollow &&= nofollow; // nofollow only if every occurrence is
    if (anchor != null && (l.anchor == null || (inMain && !l.in_main))) l.anchor = anchor; // prefer the in-content anchor
    l.in_main ||= inMain;
  }
  return [...out.values()];
}

export function extractFields(html, cfg = {}, pageUrl = null) {
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
  const links = pageUrl ? collectLinks(root, main, pageUrl) : []; // before the strip below removes nav/footer
  for (const sel of [STRIP, ...(cfg.ignore_selectors ?? [])].filter(Boolean)) {
    main.querySelectorAll(sel).forEach((n) => n.remove());
  }
  const text = normText(textOf(main)) ?? '';

  return {
    title: normText(root.querySelector('title')?.rawText),
    meta_description: attr('meta[name="description" i]', 'content'),
    h1: h1 ? normText(h1.rawText) : null,
    canonical: attr('link[rel="canonical" i]', 'href'),
    robots: attr('meta[name="robots" i]', 'content'),
    schema_types: [...types].sort(),
    content_hash: createHash('sha256').update(text).digest('hex'),
    links,
  };
}
