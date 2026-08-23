#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Flag citations bound to a page that the page never actually cites.

L30: a foreign key catches a WRITE with the wrong key; nothing catches a
binding that is well-formed but unused. `seo_page_citations` says a page rests
on a study; the page's YAML is the only place that says whether it really does.
Backbone sweeps assign citations by cluster and leave `supports_claim` as
boilerplate, so a page can sit on Live looking evidence-backed for claims it
never makes.

The test is deliberately mechanical, not semantic: a citation counts as used
when a locator that identifies it — DOI, PMID, URL, or ISBN — or a 40-character
prefix of its title appears in the page's own YAML. No keyword matching; a loose
comparator that approves everything is a gate that checks nothing.

Rows the gate cannot judge are reported as UNCHECKABLE, never as unused. Read
cited_on_page() for why that distinction is the point of this script.

Usage:
    python3 content-plan/etl/verify-page-citation-usage.py            # Live pages
    python3 content-plan/etl/verify-page-citation-usage.py --all      # + Planned
    python3 content-plan/etl/verify-page-citation-usage.py --verbose  # list used too

Exit 1 if any active binding is unused on a Live page.
"""
import argparse
import collections
import glob
import importlib.util
import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
# Content lives in the BRAND being checked, not next to this script — the gates moved to the
# protocol repo, which holds no content at all. Resolve from the working directory, walking up
# for web/src/content, so the same file serves whichever brand repo it is run from.
def _find_content():
    override = os.environ.get("EYWA_CONTENT_ROOT")
    if override:
        return os.path.abspath(override)
    d = os.path.abspath(os.getcwd())
    while True:
        cand = os.path.join(d, "web", "src", "content")
        if os.path.isdir(cand):
            return cand
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    sys.exit("ไม่พบ web/src/content — รันจากใน repo ของแบรนด์ หรือชี้ EYWA_CONTENT_ROOT")


CONTENT = _find_content()
ROOT = os.path.abspath(os.path.join(CONTENT, "..", "..", ".."))

import sys as _sys
_sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import eywa_supabase as fpf  # key() / fetch() / SB — see eywa_supabase.py


def content_files_by_slug():
    """slug -> [paths]. Basenames can repeat across collections; keep them all so
    a page is judged against every file that could be its source (conservative:
    errs toward calling a binding used)."""
    out = collections.defaultdict(list)
    for f in glob.glob(os.path.join(CONTENT, "**", "*.yaml"), recursive=True):
        out[os.path.splitext(os.path.basename(f))[0]].append(f)
    return out


# A title prefix long enough to be unique to one paper. Short fragments are how a
# comparator ends up approving everything — "age" matches "average", "management".
TITLE_PREFIX_CHARS = 40


def cited_on_page(c, text, low):
    """Returns (verdict, detail) — "cited", "uncited", or "uncheckable".

    Locators first, because they are unambiguous. Guidelines, fact sheets and
    textbooks often carry neither a DOI nor a PMID (a plain URL or an ISBN
    instead), so fall back to the URL, the ISBN, and finally to a long title
    prefix — pages label references with the full title.

    "uncheckable" is a separate verdict on purpose, and it is the whole reason
    this function returns a string instead of a bool. A citation carrying no
    locator this gate can search for, and a title too short to match on, cannot
    be judged either way. Calling that "unused" is a false accusation, and the
    consequence is not theoretical: the remedy for an unused binding is to
    delete it, so a gate that cannot tell the two apart hands you a list that
    quietly mixes real dead weight with citations the page genuinely rests on.
    Only "uncited" may drive an unbind."""
    doi = (c.get("doi") or "").strip()
    pmid = (c.get("pubmed_pmid") or "").strip()
    url = (c.get("url") or "").strip()
    isbn = re.sub(r"[^0-9Xx]", "", (c.get("isbn") or ""))
    title = re.sub(r"\s+", " ", (c.get("title") or "")).strip()

    if doi and doi.lower() in low:
        return "cited", "doi"
    if pmid and re.search(r"\b" + re.escape(pmid) + r"\b", text):
        return "cited", "pmid"
    # A bare origin ("https://who.int") would match half the web; require a path.
    if url and len(url) > 20 and url.lower().rstrip("/") in low:
        return "cited", "url"
    # Pages print ISBNs with hyphens in any position, so compare digits only.
    if len(isbn) >= 10 and isbn in re.sub(r"[^0-9Xx]", "", text):
        return "cited", "isbn"
    if len(title) >= TITLE_PREFIX_CHARS:
        if title[:TITLE_PREFIX_CHARS].lower() in low:
            return "cited", "title"
        return "uncited", None

    if doi or pmid or (url and len(url) > 20) or len(isbn) >= 10:
        return "uncited", None      # had something to look for, it was not there
    return "uncheckable", "no locator, title %d chars" % len(title)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--brand", default="vth-biodent")
    ap.add_argument("--all", action="store_true", help="include Planned pages")
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args()

    k = fpf.key()
    pages = {p["page_fingerprint"]: p for p in fpf.fetch(
        "seo_website_page_master", "page_fingerprint,status,slug",
        "&brand_id=eq." + a.brand + "&limit=5000", k)}
    wanted = {"Live"} if not a.all else {"Live", "Planned"}
    cites = {c["fingerprint"]: c for c in fpf.fetch(
        # url and isbn are NOT optional here. cited_on_page() reads both, and for two
        # months this select omitted them, so `c.get("url")` was None on every row and
        # the URL branch below could never fire — dead code that reads as a live check.
        # 30 pool citations carry a URL as their only locator; every one of them was
        # reported unused on every page that binds it. eywa-deezy found it on
        # oral-cancer-screening, which cites a WHO fact sheet by URL in references[].
        "seo_citations",
        "fingerprint,title,doi,pubmed_pmid,url,isbn,citation_tier", "", k)}
    links = [l for l in fpf.fetch(
        "seo_page_citations", "page_fp,citation_fp,status,supports_claim", "&limit=20000", k)
        if l["status"] == "active"
        and l["page_fp"] in pages
        and pages[l["page_fp"]]["status"] in wanted]

    by_slug = content_files_by_slug()
    by_page = collections.defaultdict(list)
    for l in links:
        by_page[l["page_fp"]].append(l)

    used = unused = uncheckable = nofile = 0
    unwritten_pages = unwritten_bindings = 0
    for pf in sorted(by_page):
        page = pages[pf]
        # Some slugs are nested ("pricing/dental-veneer"); the file keeps only the leaf.
        files = by_slug.get(page["slug"].rstrip("/").split("/")[-1], [])
        if not files:
            # Planned pages usually have no file yet — only worth reporting for Live.
            if page["status"] == "Live":
                nofile += 1
                print("  NOFILE  %-14s %s" % (pf, page["slug"]))
            else:
                # Counted, not silently skipped. Under --all these pages dominate the
                # binding count, and a summary that omits them invites the reader to
                # treat "cited + unused" as the whole estate and unbind the remainder.
                unwritten_pages += 1
                unwritten_bindings += len(by_page[pf])
            continue
        text = "\n".join(io.open(f, encoding="utf-8").read() for f in files)
        low = text.lower()
        misses = []
        for l in by_page[pf]:
            c = cites.get(l["citation_fp"]) or {}
            verdict, detail = cited_on_page(c, text, low)
            if verdict == "cited":
                used += 1
            else:
                if verdict == "uncited":
                    unused += 1
                else:
                    uncheckable += 1
                misses.append((verdict, detail, l["citation_fp"],
                               c.get("citation_tier"), c.get("title")))
        if misses or a.verbose:
            print("\n  %-14s %s  (%s, %d bound)"
                  % (pf, page["slug"], page["status"], len(by_page[pf])))
            for verdict, detail, fp, tier, title in misses:
                label = "UNUSED" if verdict == "uncited" else "UNCHECKABLE"
                print("      %-11s t%-3s %s  %s%s"
                      % (label, tier, fp, str(title)[:60],
                         "  [%s]" % detail if detail else ""))

    # The other direction, added 2026-08-16 after eywa-deezy pointed out this script
    # only ever asked "is this binding used?". A page can equally cite a DOI or PMID the
    # pool has never heard of — written straight into references: with no row created —
    # and nothing was looking. That citation has been through no verification, no tier,
    # no authority scoring, and no gate, while sitting on a live page looking identical
    # to one that has. demo.yaml files are scaffolding shipped with the templates and
    # carry example locators on purpose, so they are excluded.
    orphan_locators = []
    pool_dois = {(c.get("doi") or "").strip().lower() for c in cites.values() if c.get("doi")}
    pool_pmids = {(c.get("pubmed_pmid") or "").strip() for c in cites.values() if c.get("pubmed_pmid")}
    doi_re = re.compile(r"10\.\d{4,9}/[^\s\"'<>)\]]+")
    pmid_re = re.compile(r"pubmed\.ncbi\.nlm\.nih\.gov/(\d{7,8})")
    for f in sorted(glob.glob(os.path.join(CONTENT, "**", "*.yaml"), recursive=True)):
        if os.path.basename(f) == "demo.yaml":
            continue
        text = "\n".join(l for l in io.open(f, encoding="utf-8").read().splitlines()
                         if not l.lstrip().startswith("#"))
        rel = os.path.relpath(f, CONTENT)
        for d in doi_re.findall(text):
            d = d.rstrip(".,;\"').").lower()
            if d not in pool_dois:
                orphan_locators.append((rel, "doi", d))
        for p in pmid_re.findall(text):
            if p not in pool_pmids:
                orphan_locators.append((rel, "pmid", p))
    if orphan_locators:
        print("\n  CITED BUT NOT IN THE POOL — %d locator(s)" % len(orphan_locators))
        for rel, kind, val in (orphan_locators if a.verbose else orphan_locators[:10]):
            print("      %-46s %s %s" % (rel, kind, val))
        if len(orphan_locators) > 10 and not a.verbose:
            print("      ... %d more (--verbose for all)" % (len(orphan_locators) - 10))

    print("\n" + "-" * 78)
    print("cited by the page: %d · bound but never cited: %d · could not be checked: %d · "
          "Live page with no file: %d · cited but not in the pool: %d"
          % (used, unused, uncheckable, nofile, len(orphan_locators)))
    if unwritten_bindings:
        print("ℹ️  %d more binding(s) on %d Planned page(s) that have no content file yet — not"
              % (unwritten_bindings, unwritten_pages))
        print("   examined, and not a finding. A page cannot cite what it has not been written")
        print("   to say. These are the plan's pre-bindings; judge them after the page exists.")
    if uncheckable:
        print("⚠️  the %d uncheckable rows are NOT a finding and MUST NOT be unbound — the pool"
              % uncheckable)
        print("   row carries no DOI, PMID, URL or ISBN to search for. Fix the pool row, not the")
        print("   binding. Only the 'bound but never cited' figure may drive an unbind.")
    return 1 if (unused or nofile or orphan_locators) else 0


if __name__ == "__main__":
    sys.exit(main())
