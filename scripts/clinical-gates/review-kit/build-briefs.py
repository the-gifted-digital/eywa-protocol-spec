#!/usr/bin/env python3
"""Build the per-cluster reviewer briefs for the contraindication review-kit (DR-069 §6 step 2).

The review-kit README calls this step "unscripted — 40 lines of python, brand-specific joins". This is
that pull, brand-agnostic: for every entity in a clusters file it gathers the graph row's summary and
parent, the existing seo_entity_procedures row (if any), any `contraindicat*` edges, and — per page of
that brand whose primary_entity_fp is the entity — the page's hand-typed `contraindication:` items, its
`safety` items and `whoFor`/`indication` (context), and every active citation bound to the page with its
key_findings. One markdown per cluster, in the shape the vth-biodent and deezy-dental rounds used.

usage (from inside the brand repo so the service key resolves):
  python3 build-briefs.py --brand deezy-dental --clusters clusters.json --content web/src/content --out <dir>
clusters.json = {"<cluster-name>": ["entity-fp", ...], ...}

Read-only against the database. Writes only under --out. Credentials via eywa_supabase.key() from the
protocol repo's citation-gates folder (set EYWA_SPEC if the spec repo is not the sibling of brands/).
"""
import argparse, glob, json, os, sys, urllib.request

ap = argparse.ArgumentParser()
ap.add_argument("--brand", required=True)
ap.add_argument("--clusters", required=True, help="json: {cluster: [entity_fp,...]}")
ap.add_argument("--content", default="web/src/content")
ap.add_argument("--locale", default="th")
ap.add_argument("--out", required=True)
ap.add_argument("--spec", default=os.environ.get("EYWA_SPEC", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "..", "eywa-protocol-spec")))
a = ap.parse_args()

sys.path.insert(0, os.path.join(a.spec, "scripts", "citation-gates"))
import eywa_supabase as sb  # noqa: E402
import yaml  # noqa: E402

K = sb.key()
def get(path):
    out, start = [], 0
    while True:
        req = urllib.request.Request(sb.SB + path, headers={"apikey": K, "Authorization": "Bearer " + K, "Range": f"{start}-{start+999}"})
        chunk = json.load(urllib.request.urlopen(req))
        out += chunk
        if len(chunk) < 1000: return out
        start += 1000

CLUSTERS = json.load(open(a.clusters, encoding="utf-8"))
allfp = [e for v in CLUSTERS.values() for e in v]
inl = ",".join(allfp)
graph = {r["entity_fingerprint"]: r for r in get(f"seo_entity_graph?select=entity_fingerprint,entity_name,entity_type,ai_entity_summary,parent_entity_fp,load_from,competing_entities&entity_fingerprint=in.({inl})")}
proc = {r["entity_fp"]: r for r in get(f"seo_entity_procedures?select=entity_fp,contraindications,load_source,load_from&entity_fp=in.({inl})")}
rels = get(f"seo_entity_relationships?select=from_entity_fp,to_entity_fp,edge_type,edge_note,status&edge_type=ilike.*contraindicat*&or=(from_entity_fp.in.({inl}),to_entity_fp.in.({inl}))")
rel_by = {}
for r in rels:
    for side in ("from_entity_fp", "to_entity_fp"):
        rel_by.setdefault(r[side], []).append(r)
pages = [p for p in get(f"seo_website_page_master?select=page_fingerprint,slug,status,primary_entity_fp,page_name&brand_id=eq.{a.brand}&primary_entity_fp=in.({inl})") if p["status"] in ("Live", "Planned")]
pfps = ",".join(p["page_fingerprint"] for p in pages)
binds = get(f"seo_page_citations?select=page_fp,citation_fp,citation_purpose,supports_claim&status=eq.active&page_fp=in.({pfps})") if pfps else []
cfps = ",".join(sorted({b["citation_fp"] for b in binds}))
cites = {c["fingerprint"]: c for c in get(f"seo_citations?select=fingerprint,title,pubmed_pmid,publication_year,citation_tier,study_type,key_findings&fingerprint=in.({cfps})")} if cfps else {}

yaml_by_slug = {os.path.basename(f)[:-5]: f for f in glob.glob(os.path.join(a.content, "*", a.locale, "*.yaml"))}
def load_yaml(slug):
    f = yaml_by_slug.get(slug)
    if not f: return None
    try: return yaml.safe_load(open(f, encoding="utf-8"))
    except Exception as e: return {"_error": str(e)}
def items(x):
    if not x: return []
    if isinstance(x, dict): x = x.get("items") or x.get("bullets") or []
    return [i if isinstance(i, str) else json.dumps(i, ensure_ascii=False) for i in x]

os.makedirs(a.out, exist_ok=True)
for cname, ents in CLUSTERS.items():
    L = [f"# Brief — cluster `{cname}` — {a.brand} contraindication backfill", "",
         f"Brand: {a.brand} · table: `seo_entity_procedures` · insert_row=true unless the entity already has a row (stated per entity)."]
    for fp in ents:
        g = graph.get(fp, {})
        L.append(f"\n---\n## Entity `{fp}` — {g.get('entity_name','?')} · type {g.get('entity_type','?')} · load_from {g.get('load_from')}")
        if g.get("parent_entity_fp"): L.append(f"parent_entity_fp: `{g['parent_entity_fp']}`")
        L.append(f"ai_entity_summary: {g.get('ai_entity_summary') or '(none)'}")
        if g.get("competing_entities"): L.append(f"competing_entities note: {str(g['competing_entities'])[:600]}")
        pr = proc.get(fp)
        L.append("existing seo_entity_procedures row: " + (f"YES (load_from {pr.get('load_from')}; contraindications {'present' if pr.get('contraindications') else 'empty'}) → insert_row=false" if pr else "NONE → insert_row=true"))
        if pr and pr.get("contraindications"): L += ["  current list:"] + [f"  - {t}" for t in pr["contraindications"]]
        edges = rel_by.get(fp, [])
        L.append("contraindicates edges (DR-013): " + ("; ".join(f"{e['from_entity_fp']} → {e['to_entity_fp']} ({e['edge_type']}, {e.get('status')}) {e.get('edge_note') or ''}" for e in edges) if edges else "(none)"))
        for p in [p for p in pages if p["primary_entity_fp"] == fp]:
            d = load_yaml(p["slug"])
            L.append(f"\n### Page `{p['slug']}` ({p['page_fingerprint']}, {p['status']}) — {p['page_name']}")
            if not d: L.append("(no YAML found)"); continue
            if "_error" in d: L.append(f"(YAML parse error: {d['_error'][:100]})"); continue
            ci = items(d.get("contraindication")); L.append("writer's hand-typed contraindication items:" + ("\n" + "\n".join(f"  - {i}" for i in ci) if ci else " (none)"))
            si = items(d.get("safety")); L.append("page safety items (context only):" + ("\n" + "\n".join(f"  - {i}" for i in si) if si else " (none)"))
            wf = d.get("whoFor") or d.get("candidates") or d.get("indication")
            if wf: L.append("whoFor / indication (context only): " + json.dumps(wf, ensure_ascii=False)[:900])
            pb = [b for b in binds if b["page_fp"] == p["page_fingerprint"]]
            if pb:
                L.append("citations bound to this page:")
                for b in pb:
                    c = cites.get(b["citation_fp"], {}); kf = c.get("key_findings"); kf = " ".join(kf) if isinstance(kf, list) else str(kf or "")
                    L.append(f"  - PMID {c.get('pubmed_pmid')} · {c.get('publication_year')} · tier {c.get('citation_tier')} · {c.get('study_type')} · {c.get('title','')[:120]}\n    purpose {b['citation_purpose']} · key_findings: {kf[:1200]}")
            else: L.append("citations bound to this page: (none)")
    path = os.path.join(a.out, f"brief-{cname}.md")
    open(path, "w", encoding="utf-8").write("\n".join(L))
    print(f"{cname}: {len(ents)} entities · {sum(1 for p in pages if p['primary_entity_fp'] in ents)} pages → {path}")
