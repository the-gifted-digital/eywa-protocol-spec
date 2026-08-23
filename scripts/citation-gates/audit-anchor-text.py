#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Audit internal-link anchor text against the plan's own declared intent.

Google publishes no percentage for exact-match anchors — its guidance on internal
links is qualitative: descriptive, understandable out of context, no "click here",
and "resist the urge to cram every keyword". Percentages quoted around the industry
come from third-party studies of *backlink* profiles, which is a different problem.
So everything numeric below is a house rule, and is labelled as one.

The house rule we do have is already in the data: every link carries an
`anchor_variant_type` (exact · partial · topical · branded · generic). The plan
declares what each anchor is supposed to be; nothing ever checked that the anchor
text agrees. These are the checks:

  BLOCKING
    A1  empty anchor
    A2  planning note leaked into the anchor (TBD, canonical, revision codes)
    A3  anchor is the target's page_name verbatim — a title, not a phrase
    A4  anchor longer than MAX_LEN — house rule, keeps anchors sentence-sized
    A5  declared `exact` but the anchor does not contain the target keyword

  WARN (quality debt, not correctness)
    A6  one target, many inbound links, a single anchor repeated for all of them
    A7  surrounding_text_snippet missing — with no sentence around it, an anchor
        has nothing to blend into and drifts back to being the page title

Usage:
    python3 content-plan/etl/audit-anchor-text.py --brand vth-biodent
    python3 content-plan/etl/audit-anchor-text.py --verbose
"""
import argparse
import collections
import importlib.util
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("fpf", os.path.join(HERE, "find-page-forks.py"))
fpf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fpf)

# House rules. Not standards — chosen so an anchor stays a phrase inside a sentence.
MAX_LEN = 60
MONOTONY_MIN_INBOUND = 5

NOISE = re.compile(r"TBD|operator|canonical|rev\s*\d|v\d+\.\d+|20\d\d-\d\d|→|::|\bWave\b|⚠|🔴", re.I)


def keyword_of(page):
    v = page.get("target_keyword_fp")
    return str(v).split("::")[-1].strip().lower() if v else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--brand", default="vth-biodent")
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args()

    k = fpf.key()
    pages = {p["page_fingerprint"]: p for p in fpf.fetch(
        "seo_website_page_master", "page_fingerprint,page_name,target_keyword_fp,brand_id",
        "&limit=6000", k)}
    links = [l for l in fpf.fetch(
        "seo_page_internal_links",
        "id,from_page_fp,to_page_fp,anchor_text,anchor_variant_type,surrounding_text_snippet",
        "&limit=40000", k)
        if l["from_page_fp"] in pages and pages[l["from_page_fp"]].get("brand_id") == a.brand]

    findings = collections.defaultdict(list)
    inbound = collections.defaultdict(list)

    for l in links:
        anchor = (l.get("anchor_text") or "").strip()
        target = pages.get(l["to_page_fp"], {})
        inbound[l["to_page_fp"]].append(anchor)

        if not anchor:
            findings["A1_empty"].append((l["from_page_fp"], l["to_page_fp"], ""))
            continue
        if NOISE.search(anchor):
            findings["A2_planning_note"].append((l["from_page_fp"], l["to_page_fp"], anchor))
        name = (target.get("page_name") or "").strip()
        if name and anchor == name:
            findings["A3_is_page_name"].append((l["from_page_fp"], l["to_page_fp"], anchor))
        if len(anchor) > MAX_LEN:
            findings["A4_too_long"].append((l["from_page_fp"], l["to_page_fp"],
                                            "%d chars: %s" % (len(anchor), anchor)))
        kw = keyword_of(target)
        if l.get("anchor_variant_type") == "exact" and kw and kw not in anchor.lower():
            findings["A5_exact_without_keyword"].append(
                (l["from_page_fp"], l["to_page_fp"], "kw=%s anchor=%s" % (kw, anchor)))

    for to, anchors in inbound.items():
        if len(anchors) >= MONOTONY_MIN_INBOUND and len(set(anchors)) == 1:
            findings["A6_one_anchor_many_links"].append(
                (to, "%d inbound, 1 distinct" % len(anchors), anchors[0]))

    missing_snippet = sum(1 for l in links if not (l.get("surrounding_text_snippet") or "").strip())
    if missing_snippet:
        findings["A7_no_surrounding_text"].append(
            ("(sitewide)", "%d of %d links" % (missing_snippet, len(links)),
             "an anchor with no sentence around it defaults back to the page title"))

    warn_gates = ("A6_one_anchor_many_links", "A7_no_surrounding_text")
    print("Anchor text audit — brand %s · %d internal links" % (a.brand, len(links)))
    print("-" * 78)
    blocking = 0
    for gate in ("A1_empty", "A2_planning_note", "A3_is_page_name", "A4_too_long",
                 "A5_exact_without_keyword", "A6_one_anchor_many_links",
                 "A7_no_surrounding_text"):
        rows = findings.get(gate, [])
        if not rows:
            print("  PASS  %-28s 0" % gate)
            continue
        if gate not in warn_gates:
            blocking += len(rows)
        print("  %s  %-28s %d" % ("WARN" if gate in warn_gates else "FAIL", gate, len(rows)))
        shown = rows if a.verbose else rows[:5]
        for r in shown:
            print("          " + " | ".join(str(x)[:60] for x in r))
        if len(rows) > len(shown):
            print("          ... %d more (--verbose for all)" % (len(rows) - len(shown)))
    print("-" * 78)
    print("blocking rows: %d" % blocking)
    return 1 if blocking else 0


if __name__ == "__main__":
    sys.exit(main())
