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
only when its full DOI or its PMID (word-bounded) appears in the page's own
YAML. No keyword matching — a loose comparator that approves everything is a
gate that checks nothing.

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
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
CONTENT = os.path.join(ROOT, "web", "src", "content")

spec = importlib.util.spec_from_file_location("fpf", os.path.join(HERE, "find-page-forks.py"))
fpf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fpf)


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
    """True when the page itself points at this citation.

    Locators first, because they are unambiguous. Textbooks and guidelines often
    carry neither a DOI nor a PMID (ISBN or a plain URL instead) and would be
    reported as unused forever, so fall back to the URL and then to a long title
    prefix — pages label references with the full title."""
    doi = (c.get("doi") or "").strip()
    if doi and doi.lower() in low:
        return True
    pmid = (c.get("pubmed_pmid") or "").strip()
    if pmid and re.search(r"\b" + re.escape(pmid) + r"\b", text):
        return True
    url = (c.get("url") or "").strip()
    if url and len(url) > 20 and url.lower().rstrip("/") in low:
        return True
    title = re.sub(r"\s+", " ", (c.get("title") or "")).strip()
    if len(title) >= TITLE_PREFIX_CHARS:
        return title[:TITLE_PREFIX_CHARS].lower() in low
    return False


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
        "seo_citations", "fingerprint,title,doi,pubmed_pmid,citation_tier", "", k)}
    links = [l for l in fpf.fetch(
        "seo_page_citations", "page_fp,citation_fp,status,supports_claim", "&limit=20000", k)
        if l["status"] == "active"
        and l["page_fp"] in pages
        and pages[l["page_fp"]]["status"] in wanted]

    by_slug = content_files_by_slug()
    by_page = collections.defaultdict(list)
    for l in links:
        by_page[l["page_fp"]].append(l)

    used = unused = nofile = 0
    for pf in sorted(by_page):
        page = pages[pf]
        # Some slugs are nested ("pricing/dental-veneer"); the file keeps only the leaf.
        files = by_slug.get(page["slug"].rstrip("/").split("/")[-1], [])
        if not files:
            # Planned pages usually have no file yet — only worth reporting for Live.
            if page["status"] == "Live":
                nofile += 1
                print("  NOFILE  %-14s %s" % (pf, page["slug"]))
            continue
        text = "\n".join(io.open(f, encoding="utf-8").read() for f in files)
        low = text.lower()
        misses = []
        for l in by_page[pf]:
            c = cites.get(l["citation_fp"]) or {}
            if cited_on_page(c, text, low):
                used += 1
            else:
                unused += 1
                misses.append((l["citation_fp"], c.get("citation_tier"), c.get("title")))
        if misses or a.verbose:
            print("\n  %-14s %s  (%s, %d bound)"
                  % (pf, page["slug"], page["status"], len(by_page[pf])))
            for fp, tier, title in misses:
                print("      UNUSED  t%-3s %s  %s" % (tier, fp, str(title)[:70]))

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
    print("cited by the page: %d · bound but never cited: %d · Live page with no file: %d · "
          "cited but not in the pool: %d" % (used, unused, nofile, len(orphan_locators)))
    return 1 if (unused or nofile or orphan_locators) else 0


if __name__ == "__main__":
    sys.exit(main())
