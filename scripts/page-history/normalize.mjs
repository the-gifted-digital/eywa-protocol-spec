import he from 'he';

// Whitespace-collapse without entity decoding (for values the parser already decoded).
export const collapse = (s) => {
  if (s == null) return null;
  const t = String(s).replace(/\s+/g, ' ').trim();
  return t === '' ? null : t;
};

export const normText = (s) => (s == null ? null : collapse(he.decode(String(s))));

// Mirror of SQL seo_norm_url (shared cases: fixtures/url-cases.json).
export function normUrl(u) {
  const m = /^([A-Za-z][A-Za-z0-9+.-]*:\/\/[^/?#]*)([^?#]*)/.exec(u);
  if (!m) return u;
  const origin = m[1].toLowerCase().replace(/^([a-z][a-z0-9+.-]*:\/\/)www\./, '$1');
  return origin + (encPath(m[2].replace(/\/$/, '')) || '/');
}

// Canonical %-encoding of a path: non-ASCII -> UTF-8 bytes as %XX, existing %xx -> uppercase. ASCII untouched.
const encPath = (p) => p.replace(/%[0-9A-Fa-f]{2}|[^\x00-\x7F]+/g, (t) => (t[0] === '%' ? t.toUpperCase()
  : [...Buffer.from(t, 'utf8')].map((b) => `%${b.toString(16).toUpperCase().padStart(2, '0')}`).join('')));
