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
  return origin + (m[2].replace(/\/$/, '') || '/');
}
