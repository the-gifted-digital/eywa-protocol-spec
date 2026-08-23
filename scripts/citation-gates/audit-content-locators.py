#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Check every locator in the written content against its source.

The pool has its own gates. This one guards the other half of the problem: a
reference block in a YAML file quotes a DOI or PMID that the pool never vouched
for, because a human typed it. On 2026-08-09 that check found eleven wrong
locators across live pages — one labelled "Global burden of severe periodontitis"
resolved to "Art as behaviour: an ethological approach to visual and verbal art,
music and architecture", another labelled as the occlusal splint review resolved
to a COVID-19 patient-presentation paper. The pool held the correct identifier
for every one of them. These were transcription errors, and no gate that only
reads the database could ever see them.

What it checks, per `label` + `url` pair in every `references:` block:

  1. the identifier resolves at all
  2. the resolved title is about the same thing as the label
  3. the pair is one the database actually links to that page

Rule 3 is why the audit runs against Supabase rather than standing alone: a
reference that no `seo_page_citations` row backs is one nobody approved.

Usage:
    python3 audit-content-locators.py                  # all three checks
    python3 audit-content-locators.py --skip-db        # locators only, no network to Supabase
    python3 audit-content-locators.py --json out.json

Exits non-zero only when a locator resolves to a different paper — that is a
data error and the build should stop. Two things are reported without failing:
a source that could not be reached after three tries, which is a network fact
rather than a data one, and a reference no seo_page_citations row backs, where
which side to correct is a judgement call.
"""
import argparse
import glob
import json
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import eywa_supabase  # noqa: E402
import re
import sys
import time
import urllib.parse
import urllib.request

UA = {"User-Agent": "vth-content-locator-audit (naphannop.n@gmail.com)"}
CROSSREF = "https://api.crossref.org/works/"
ESUMMARY = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&retmode=json&id="
PMID_RE = re.compile(r"pubmed\.ncbi\.nlm\.nih\.gov/(\d+)")
REF_RE = re.compile(r'\nreferences:(.*?)(\n[a-zA-Z_]+:\s*\n|\Z)', re.S)
PAIR_RE = re.compile(r'label:\s*"([^"]+)"\s*\n\s*url:\s*"([^"]+)"')
# Words that appear in half of all dental paper titles and so carry no signal.
STOP = set("""the of in a an and or for on to with is are was were by from at as its their this that
systematic review meta analysis randomized randomised controlled trial clinical study studies""".split())
# Below this share of the label's content words, the resolved title is a different paper.
MATCH_FLOOR = 0.34


def words(s):
    return {w for w in re.findall(r"[a-z][a-z\-]{2,}", (s or "").lower()) if w not in STOP}


def agreement(label, resolved):
    """How much of the label's title appears in the title the identifier resolves to.

    Labels come in two shapes. Some are the bare title. Others are written
    author-first — "Malo P, Rangert B, Nobre M. All-on-4 immediate-function
    concept. Clin Implant Dent Relat Res. 2003." — where surnames, initials and
    a journal abbreviation outnumber the words that actually name the work.
    Scoring the whole string against the resolved title marks those as
    mismatches even when the identifier is right; the first version of this
    check did exactly that and would have failed CI on two correct references.

    So score each sentence-ish segment separately and keep the best. A label
    whose title segment matches is a match, whichever shape it was written in.
    """
    r = words(resolved)
    best = 0.0
    for seg in [label] + [s for s in re.split(r"\.\s+", label or "") if s]:
        a = words(seg)
        if not a:
            continue
        best = max(best, len(a & r) / len(a))
    return best


def fetch(url, attempts=3):
    """Retry before giving up. A single blip must not be reported as bad data."""
    last = None
    for i in range(attempts):
        try:
            return json.load(urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30))
        except Exception as exc:
            last = exc
            time.sleep(1.5 * (i + 1))
    raise last


def resolve(url):
    """Return (kind, identifier, title).

    title is the resolved title, "" when there is nothing to resolve against,
    and None when the source could not be reached. None is deliberately not the
    same as a mismatch: unreachable is a network fact, wrong is a data fact, and
    only the second should ever fail a build. A gate that goes red because an
    API blinked is one people learn to ignore.
    """
    m = PMID_RE.search(url)
    if m:
        pmid = m.group(1)
        try:
            return "pmid", pmid, fetch(ESUMMARY + pmid)["result"][pmid].get("title")
        except Exception:
            return "pmid", pmid, None
    doi = url.lower().replace("https://doi.org/", "").replace("http://doi.org/", "").strip()
    if doi.startswith("10."):
        try:
            return "doi", doi, (fetch(CROSSREF + urllib.parse.quote(doi, safe=""))["message"].get("title") or [None])[0]
        except Exception:
            return "doi", doi, None
    # A plain web source — a society guideline page, a government document.
    # Nothing to resolve a title against, so "" rather than None. Normalised the
    # same way db_backed_keys stores it: an unnormalised key here made the
    # backing check miss an AAO reference that was linked all along.
    return "url", url.rstrip("/").lower(), ""


def db_backed_keys(brand):
    """The identifiers seo_page_citations actually links, keyed by page slug."""
    key = os.environ.get("SUPABASE_SERVICE_KEY")
    if not key:
        k = eywa_supabase.key()
        with open(secrets, encoding="utf-8") as fh:
            for line in fh:
                if line.startswith("SUPABASE_SERVICE_KEY="):
                    key = line.split("=", 1)[1].strip()
    sb = eywa_supabase.SB

    def page_all(table, select, flt=""):
        out, off = [], 0
        while True:
            req = urllib.request.Request("%s%s?select=%s%s&limit=1000&offset=%d" % (sb, table, select, flt, off),
                                         headers={"apikey": key, "Authorization": "Bearer " + key})
            batch = json.load(urllib.request.urlopen(req))
            out += batch
            if len(batch) < 1000:
                return out
            off += 1000

    cites = {c["fingerprint"]: c for c in page_all("seo_citations", "fingerprint,doi,pubmed_pmid,url")}
    pages = {p["page_fingerprint"]: p["slug"]
             for p in page_all("seo_website_page_master", "page_fingerprint,slug",
                               "&brand_name=eq." + urllib.parse.quote(brand))}
    backed = {}
    for l in page_all("seo_page_citations", "page_fp,citation_fp,status"):
        if l["status"] != "active" or l["page_fp"] not in pages:
            continue
        c = cites.get(l["citation_fp"])
        if not c:
            continue
        s = backed.setdefault(pages[l["page_fp"]], set())
        if c.get("pubmed_pmid"):
            s.add("pmid:" + str(c["pubmed_pmid"]))
        if c.get("doi"):
            s.add("doi:" + c["doi"].lower())
        if c.get("url"):
            m = PMID_RE.search(c["url"])
            if m:
                s.add("pmid:" + m.group(1))
            else:
                s.add("url:" + c["url"].rstrip("/").lower())
    return backed


def main(root, brand, skip_db, out_json):
    backed = {} if skip_db else db_backed_keys(brand)
    seen, wrong, unresolved, unbacked = {}, [], [], []
    files = sorted(glob.glob(os.path.join(root, "*/th/*.yaml")))
    for f in files:
        slug = os.path.basename(f)[:-5]
        m = REF_RE.search(open(f, encoding="utf-8").read())
        if not m:
            continue
        for label, url in PAIR_RE.findall(m.group(1)):
            kind, ident, title = seen.get((label, url), (None, None, None)) if (label, url) in seen else resolve(url)
            if (label, url) not in seen:
                seen[(label, url)] = (kind, ident, title)
                time.sleep(0.15)
            if title is None:
                unresolved.append((slug, label, url))
            elif title and agreement(label, title) < MATCH_FLOOR:
                wrong.append((slug, label, url, title, round(agreement(label, title), 2)))
            if not skip_db and slug in backed and ("%s:%s" % (kind, ident)) not in backed[slug]:
                unbacked.append((slug, label, url))

    print("content locator audit — %d files, %d distinct label+url pairs" % (len(files), len(seen)))
    print("-" * 78)
    if wrong:
        print("FAIL  resolves to a different paper — %d" % len(wrong))
        for slug, label, url, title, ag in wrong:
            print("        %s" % slug)
            print("          label    %s" % label[:72])
            print("          resolves %s" % (title or "")[:72])
            print("          %s  (agreement %.2f)" % (url, ag))
    else:
        print("PASS  every locator resolves to the paper its label names")
    if unresolved:
        print("WARN  could not reach the source after 3 tries — %d" % len(unresolved))
        print("        Unreachable is not the same as wrong. Re-run; if one keeps failing,")
        print("        open it by hand — a DOI that is permanently gone is a real problem.")
        for slug, label, url in unresolved:
            print("        %-28s %s" % (slug, url))
    if unbacked:
        print("WARN  no active seo_page_citations row backs this reference — %d" % len(unbacked))
        for slug, label, url in unbacked[:20]:
            print("        %-28s %s" % (slug, label[:56]))
        if len(unbacked) > 20:
            print("        ... %d more" % (len(unbacked) - 20))
    print("-" * 78)
    print("blocking: %d" % len(wrong))
    if out_json:
        json.dump({"wrong": wrong, "unresolved": unresolved, "unbacked": unbacked},
                  open(out_json, "w"), ensure_ascii=False, indent=1)
    return 1 if wrong else 0


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default="web/src/content")
    ap.add_argument("--brand", default="VTH BioDent")
    ap.add_argument("--skip-db", action="store_true")
    ap.add_argument("--json", dest="out_json")
    a = ap.parse_args()
    sys.exit(main(a.root, a.brand, a.skip_db, a.out_json))
