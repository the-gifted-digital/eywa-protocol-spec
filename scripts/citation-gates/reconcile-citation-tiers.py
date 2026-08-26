#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Reconcile citation_tier and citation_type against PubMed PublicationType.

SOP §2 is explicit: Bible 23.1 tiers map from PubMed PublicationType directly,
never from a regex on the title and never from a reviewer's impression. This
script enforces that. It is the fix for gate G5.

For a citation with a PMID it re-derives BOTH type and tier from the source
record. For one without, the PublicationType is unavailable, so it only
corrects the tier to agree with the stored type using the same map gate G5
checks — no type is invented.

The pool is shared across brands, so this touches every brand at once. That is
deliberate: a tier that disagrees with its type is wrong for all of them.

Usage:
    python3 reconcile-citation-tiers.py            # report only
    python3 reconcile-citation-tiers.py --apply    # write

Reads SUPABASE_SERVICE_KEY from the environment, EYWA_SECRETS_ENV, or a brand's
.secrets/supabase.env found by walking up from the working directory (eywa_supabase.py).
"""
import argparse
import importlib.util
import json
import os
import urllib.request
import xml.etree.ElementTree as ET

# The gates script owns TIER_BY_TYPE and the Supabase reader. Load it by path
# rather than copying the map — two copies of a tier table is how they drift.
_HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("citation_qa_gates",
                                               os.path.join(_HERE, "run-citation-qa-gates.py"))
_gates = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_gates)
TIER_BY_TYPE, fetch_all, KEY, SB = _gates.TIER_BY_TYPE, _gates.fetch_all, _gates.KEY, _gates.SB

UA = {"User-Agent": "vth-citation-reconcile"}
EFETCH = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&id="


def tier_from_pubtypes(pt):
    """Bible 23.1 tier + type from PubMed PublicationType.

    Kept identical to tier_from_pubtypes in verify-citation-locators.py. If one
    changes, change both — they are the same rule expressed twice.

    Returns None when PubMed carries no informative PublicationType. Most
    records are tagged only "Journal Article" plus funding boilerplate, which
    says nothing about study design; falling through to a default would
    overwrite an accurate hand-entered type (cross_sectional, case_series) with
    a guess. The caller keeps the stored type in that case and fixes only the
    tier.
    """
    s = set(pt)
    if s & {"Systematic Review", "Meta-Analysis", "Network Meta-Analysis"}:
        return 1, ("meta_analysis" if s & {"Meta-Analysis", "Network Meta-Analysis"}
                   else "systematic_review")
    if s & {"Randomized Controlled Trial", "Clinical Trial", "Controlled Clinical Trial"}:
        return 2, "rct"
    if s & {"Practice Guideline", "Guideline", "Consensus Statement"}:
        return 3, "clinical_guideline"
    # DR-063 (2026-08-27). "Review" is an INDEX tag, not a finding about how the work
    # was done, and MEDLINE applies it to narrative reviews and to systematic reviews it
    # did not separately tag as "Systematic Review". Returning 6/expert_opinion from it
    # was the same fault this function already guards against one branch below — a
    # specific tier printed under a header that reads as derived fact — except it
    # returned a value instead of None, so it looked like an answer.
    #
    # eywa-deezy found it on four rows. All four carry ['Journal Article', 'Review'] and
    # all four show systematic-review conduct in the abstract: PROSPERO CRD4 with PRISMA
    # and random-effects pooling (38248221), PRISMA with MEDLINE/Embase and random
    # effects (38920855), JBI risk-of-bias with meta-analysis (37251724), and
    # random-effects pooling of eight studies with I2 reported (34776943). Under the old
    # branch the gate called every one of them tier 6, and G7 — which fails a page with
    # no tier 1-3 evidence — would have gone red on pages whose evidence is strong.
    #
    # So: no tier from "Review" alone. The caller reports PUBTYPE_UNDERTAGGED and a
    # person reads the abstract. That is slower and it is the only thing that works —
    # a regex over abstracts is not a substitute either, as the run that produced the
    # list above missed 38132412's three-database search because the words "databases"
    # and "were used" had other words between them.
    if s & {"Review", "Introductory Journal Article"} and not s & {
            "Systematic Review", "Meta-Analysis", "Network Meta-Analysis"}:
        return None
    if s & {"Case Reports"}:
        return 6, "case_report"
    if s & {"Letter", "Comment", "Editorial"}:
        return 6, "editorial"
    return None


def pubtypes_for(pmids):
    out = {}
    for i in range(0, len(pmids), 150):
        chunk = pmids[i:i + 150]
        xml = urllib.request.urlopen(
            urllib.request.Request(EFETCH + ",".join(chunk), headers=UA), timeout=60).read()
        for art in ET.fromstring(xml).iter("PubmedArticle"):
            pmid = art.findtext(".//PMID")
            out[pmid] = [p.text for p in art.iter("PublicationType") if p.text]
    return out


def patch(fp, body):
    req = urllib.request.Request(
        "%s/rest/v1/seo_citations?fingerprint=eq.%s" % (SB, fp),
        data=json.dumps(body).encode(), method="PATCH",
        headers={"apikey": KEY, "Authorization": "Bearer " + KEY, "Content-Type": "application/json"})
    urllib.request.urlopen(req).read()


def main(apply):
    cites = fetch_all("seo_citations", "fingerprint,title,citation_type,citation_tier,pubmed_pmid,brand_scope")
    bad = [c for c in cites
           if (c.get("brand_scope") or [])
           and c.get("citation_type") in TIER_BY_TYPE
           and c.get("citation_tier") != TIER_BY_TYPE[c["citation_type"]]]
    print("mismatched rows: %d of %d" % (len(bad), len(cites)))

    pmids = [c["pubmed_pmid"] for c in bad if c.get("pubmed_pmid")]
    pt = pubtypes_for(pmids) if pmids else {}
    print("PublicationType retrieved for %d of %d rows with a PMID\n" % (len(pt), len(pmids)))

    from_source, from_map, changed_type = 0, 0, 0
    for c in bad:
        pmid = c.get("pubmed_pmid")
        derived = tier_from_pubtypes(pt[pmid]) if pmid and pmid in pt else None
        if derived:
            tier, ctype = derived
            origin = "pubmed " + "/".join(pt[pmid])[:38]
            from_source += 1
        else:
            tier, ctype = TIER_BY_TYPE[c["citation_type"]], c["citation_type"]
            origin = ("G5 map (PubMed says only %s)" % "/".join(pt[pmid])[:26]) if pmid in pt \
                else "G5 map (no PMID record)"
            from_map += 1
        body = {"citation_tier": tier}
        if ctype != c["citation_type"]:
            body["citation_type"] = ctype
            changed_type += 1
        print("  T%s %-20s -> T%d %-20s  %-46s  %s"
              % (c["citation_tier"], c["citation_type"], tier, ctype, origin, str(c["title"])[:46]))
        if apply:
            patch(c["fingerprint"], body)

    print("\nfrom PubMed: %d · from the G5 map: %d · citation_type also corrected: %d"
          % (from_source, from_map, changed_type))
    print("APPLIED" if apply else "report only — re-run with --apply to write")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    main(ap.parse_args().apply)
