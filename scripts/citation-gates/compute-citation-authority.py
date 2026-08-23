#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Compute citation_authority_weight — formula eywa-authority-1.0.

WHY THIS EXISTS
The schema has carried citation_authority_weight, authority_breakdown and
authority_computed_at since the pool was built, with authority_formula_version
stamped "bible-23.1" on most rows. No score was ever written: 0 of 390
citations, 0 of 715 entities, 0 of 58 clusters. The Bible 23.1 authority
formula is not in this repo and the operator does not have it, so on 2026-08-09
we defined our own rather than leave the column dead or fill it by hand.

DESIGN RULES
1. Every component comes from data we hold or can fetch from a free API. No
   component is a judgement call, so the score is reproducible.
2. The breakdown is stored alongside the score. Any number can be taken apart
   and argued with; a bare 0-100 that nobody can audit is worse than nothing.
3. The version string is the formula's own name, not "bible-23.1" — this is not
   that formula and must not claim to be.
4. Re-running is idempotent. Change a weight, bump the version, re-run.

SCALE
citation_authority_weight is numeric(4,3), so the column tops out at 9.999.
That is the schema telling us the intended scale is 0-10, not 0-100, so the
formula is defined on 0-10 and a perfect score is stored as 9.999.

FORMULA — 0 to 10
    tier base        5.5   Bible 23.1 evidence tier, the primary axis
    recency          2.0   age against the tier's freshness ceiling (gate G8)
    corroboration    1.5   OpenAlex FWCI, field- and year-normalised
    source authority 1.0   the body behind it, via source_org_fp

    retracted or broken link -> 0
    not yet verified         -> capped at 2.0

Usage:
    python3 compute-citation-authority.py            # report + distribution
    python3 compute-citation-authority.py --apply    # write
    python3 compute-citation-authority.py --top 25   # show the ranking
"""
import argparse
import datetime
import importlib.util
import json
import math
import os
import time
import urllib.parse
import urllib.request

_HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("citation_qa_gates",
                                               os.path.join(_HERE, "run-citation-qa-gates.py"))
_gates = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_gates)
fetch_all, KEY, SB = _gates.fetch_all, _gates.KEY, _gates.SB

FORMULA_VERSION = "eywa-authority-1.0"
UA = {"User-Agent": "vth-citation-authority (naphannop.n@gmail.com)"}

# Tier base. T1-T4 are all citable authority and sit close together; the wide
# gap is T4 -> T5, the boundary between a guideline and an observation.
TIER_BASE = {1: 5.5, 2: 4.7, 3: 4.2, 4: 3.8, 5: 2.6, 6: 1.5}

# Freshness ceiling in years. T1/T2/T5 mirror gate G8 exactly so the two never
# disagree. G8 does not bound T3/T4/T6, so: guidelines get superseded on roughly
# a decade, textbooks and first-party material age much more slowly.
CEILING = {1: 5, 2: 7, 3: 10, 4: 10, 5: 7, 6: 15}

# Source authority by what kind of body stands behind the citation.
ORG_POINTS = {
    ("government_agency", "tier_1_regulatory"): 1.0,
    ("government_agency", None): 0.9,
    ("professional_association", None): 0.8,
    ("accreditation_body", None): 0.7,
    ("university", None): 0.6,
    ("research_institute", None): 0.6,
    ("hospital", None): 0.3,
    ("clinic", None): 0.3,
    ("manufacturer", None): 0.1,
}


def recency_points(year, tier):
    """Full marks inside the ceiling, then a straight line to zero at twice it."""
    if not year or tier not in CEILING:
        return 0.0
    age = datetime.date.today().year - year
    ceil = CEILING[tier]
    if age <= ceil:
        return 2.0
    if age >= ceil * 2:
        return 0.0
    return round(2.0 * (1 - (age - ceil) / ceil), 3)


def corroboration_points(fwci, cited_by):
    """FWCI is normalised for field and year: 1.0 is the world average.

    Raw counts are the fallback and are capped at 0.8 of the available 1.5,
    because a raw count rewards age rather than influence and should never
    outrank a work whose FWCI we actually know.
    """
    if fwci is not None:
        for threshold, pts in ((3.0, 1.5), (2.0, 1.2), (1.5, 1.0), (1.0, 0.7), (0.5, 0.4)):
            if fwci >= threshold:
                return float(pts)
        return 0.2 if fwci > 0 else 0.0
    if cited_by:
        return round(min(0.8, 0.2 * math.log10(cited_by + 1)), 3)
    return 0.0


def org_points(org):
    if not org:
        return 0.0
    key = (org.get("organization_type"), org.get("authority_tier"))
    if key in ORG_POINTS:
        return float(ORG_POINTS[key])
    return float(ORG_POINTS.get((org.get("organization_type"), None), 0))


def openalex(cites):
    """One call per 50 works. OpenAlex is free and needs no key; be polite.

    The filter keys are 'doi' and 'pmid'. 'ids.doi' returns HTTP 400 — an
    earlier version used it and silently matched almost nothing, so failures
    are reported here rather than swallowed.
    """
    out, failed = {}, 0
    by_doi = [c for c in cites if c.get("doi")]
    by_pmid = [c for c in cites if not c.get("doi") and c.get("pubmed_pmid")]
    for field, group, keyfn in (("doi", by_doi, lambda c: c["doi"].lower()),
                                ("pmid", by_pmid, lambda c: c["pubmed_pmid"])):
        for i in range(0, len(group), 50):
            chunk = group[i:i + 50]
            flt = "%s:%s" % (field, "|".join(keyfn(c) for c in chunk))
            url = "https://api.openalex.org/works?per-page=50&filter=" + urllib.parse.quote(flt, safe=":|/.")
            try:
                data = json.load(urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60))
            except Exception as exc:
                failed += len(chunk)
                print("  openalex %s batch failed (%d works): %s" % (field, len(chunk), exc))
                continue
            for w in data.get("results", []):
                ids = w.get("ids", {})
                doi = (ids.get("doi") or "").replace("https://doi.org/", "").lower()
                pmid = (ids.get("pmid") or "").rstrip("/").split("/")[-1]
                rec = {"fwci": w.get("fwci"), "cited_by": w.get("cited_by_count")}
                if doi:
                    out["doi:" + doi] = rec
                if pmid:
                    out["pmid:" + pmid] = rec
            time.sleep(0.3)
    if failed:
        print("  %d works could not be looked up" % failed)
    return out


def score(c, oa, orgs):
    breakdown = {}
    if c.get("is_retracted") or c.get("verification_status") in ("retracted", "broken_link"):
        return 0.0, {"blocked": "retracted or broken link"}

    tier = c.get("citation_tier")
    breakdown["tier_base"] = float(TIER_BASE.get(tier, 0))
    breakdown["recency"] = recency_points(c.get("publication_year"), tier)

    rec = oa.get("doi:" + (c["doi"] or "").lower()) if c.get("doi") else None
    if rec is None and c.get("pubmed_pmid"):
        rec = oa.get("pmid:" + c["pubmed_pmid"])
    breakdown["corroboration"] = corroboration_points((rec or {}).get("fwci"), (rec or {}).get("cited_by"))
    breakdown["corroboration_source"] = ("fwci %.2f" % rec["fwci"]) if rec and rec.get("fwci") is not None \
        else ("cited_by %s" % rec["cited_by"] if rec and rec.get("cited_by") else "none")

    breakdown["source_authority"] = org_points(orgs.get(c.get("source_org_fp")))
    total = sum(v for k, v in breakdown.items() if isinstance(v, float))

    if c.get("verification_status") != "verified":
        breakdown["cap"] = "unverified, capped at 2.0"
        total = min(total, 2.0)
    # numeric(4,3) tops out at 9.999, so a perfect 10.0 is stored as 9.999.
    return min(round(total, 3), 9.999), breakdown


def main(apply, top):
    cites = fetch_all("seo_citations", "fingerprint,title,citation_tier,publication_year,doi,pubmed_pmid,"
                                       "verification_status,is_retracted,source_org_fp,brand_scope")
    orgs = {o["entity_fp"]: o for o in fetch_all("seo_entity_organization",
                                                 "entity_fp,organization_type,authority_tier")}
    print("citations %d · organisations %d" % (len(cites), len(orgs)))
    oa = openalex(cites)
    print("OpenAlex matched %d lookup keys\n" % len(oa))

    scored = []
    for c in cites:
        total, bd = score(c, oa, orgs)
        scored.append((total, bd, c))
    scored.sort(key=lambda x: -x[0])

    buckets = {}
    for total, _, _ in scored:
        buckets[int(total)] = buckets.get(int(total), 0) + 1
    print("distribution")
    for lo in sorted(buckets, reverse=True):
        print("  %2d.0-%2d.9  %4d  %s" % (lo, lo, buckets[lo], "#" * min(60, buckets[lo])))
    with_fwci = sum(1 for _, b, _ in scored if str(b.get("corroboration_source", "")).startswith("fwci"))
    print("\nFWCI available for %d of %d · no external signal for %d"
          % (with_fwci, len(scored), sum(1 for _, b, _ in scored if b.get("corroboration_source") == "none")))

    if top:
        print("\ntop %d" % top)
        for total, bd, c in scored[:top]:
            print("  %6.3f  T%s %s  %s" % (total, c.get("citation_tier"),
                                           str(bd.get("corroboration_source"))[:14].ljust(14),
                                           str(c["title"])[:62]))
        print("\nbottom %d" % top)
        for total, bd, c in scored[-top:]:
            print("  %6.3f  T%s %s  %s" % (total, c.get("citation_tier"),
                                           str(bd.get("corroboration_source"))[:14].ljust(14),
                                           str(c["title"])[:62]))

    if not apply:
        print("\nreport only — re-run with --apply to write")
        return

    now = datetime.datetime.now(datetime.timezone.utc).isoformat()
    for total, bd, c in scored:
        body = {"citation_authority_weight": total, "authority_breakdown": bd,
                "authority_computed_at": now, "authority_formula_version": FORMULA_VERSION}
        req = urllib.request.Request("%s/rest/v1/seo_citations?fingerprint=eq.%s" % (SB, c["fingerprint"]),
                                     data=json.dumps(body).encode(), method="PATCH",
                                     headers={"apikey": KEY, "Authorization": "Bearer " + KEY,
                                              "Content-Type": "application/json"})
        urllib.request.urlopen(req).read()
    print("\nwrote %d rows at %s" % (len(scored), FORMULA_VERSION))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--top", type=int, default=0)
    a = ap.parse_args()
    main(a.apply, a.top)
