#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Run the 11 citation QA gates from citation-qa-gates.sql against Supabase.

The .sql file is the specification and stays the source of truth for what each
gate means. It is written for psql, which we do not have against this project —
Supabase exposes PostgREST, not a SQL endpoint. This runner ports the same 11
gates to REST reads so the pool can actually be checked before a writing sprint,
which is what SOP §4 asks for.

Usage:
    python3 run-citation-qa-gates.py [--brand vth-biodent] [--verbose]

Reads SUPABASE_SERVICE_KEY from ../../.secrets/supabase.env.
Exits 1 if any blocking gate returns rows. G8 is warn-level and never blocks.
"""
import argparse
import datetime
import json
import os
import re
import sys
import urllib.parse
import urllib.request
from collections import Counter, defaultdict

SB = "https://lffcbeszjqzioobqfdav.supabase.co"
SECRETS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".secrets", "supabase.env")

# Bible 23.1 tier per citation_type. Mirrors G5 in the .sql — keep in step.
TIER_BY_TYPE = {
    "systematic_review": 1, "meta_analysis": 1,
    "rct": 2,
    "clinical_guideline": 3,
    "regulatory_document": 4,
    "cohort_study": 5, "case_control": 5, "cross_sectional": 5, "case_series": 5,
    "textbook": 6, "expert_opinion": 6, "case_report": 6, "editorial": 6,
    "industry_publication": 6, "patient_resource": 6,
}
# study_type is a SECOND, INDEPENDENT reading of the same paper. It does not set the tier —
# citation_type does, through TIER_BY_TYPE above. Its whole job is to disagree when
# citation_type is wrong, which is what G14 reports. See the G15 note for the randomised
# trial that sat at tier 5 as a cohort study because nothing was there to contradict it.
#
# 2026-08-24: the column has no CHECK and had grown 33 spellings, only about ten of which
# TIER_BY_TYPE recognises. G14 compares two dict lookups, so every row spelled any other way
# was skipped in silence — and G15 did not catch them either, because study_type was not null.
# 174 of 551 pool rows sat in that gap: they looked cross-checked because the field was filled,
# and nothing compared them. Fold the synonyms HERE rather than rewriting the column, so
# 'retrospective_cohort' keeps the detail it carries while still being comparable as a cohort.
STUDY_TYPE_SYNONYM = {
    "Systematic Review": "systematic_review",
    "cochrane_review": "systematic_review",
    "systematic_review_and_meta_analysis": "meta_analysis",
    "systematic_review_guideline": "clinical_guideline",
    "clinical_practice_guideline": "clinical_guideline",
    "consensus_guideline": "clinical_guideline",
    "consensus_statement": "expert_opinion",
    "narrative_review": "expert_opinion",
    "scoping_review": "expert_opinion",
    "randomized_controlled_trial": "rct",
    "controlled_clinical_trial": "rct",
    "prospective_cohort": "cohort_study",
    "retrospective_cohort": "cohort_study",
    "survey_report": "cross_sectional",
    "law": "regulatory_document",
    "regulation": "regulatory_document",
    "manufacturer_document": "industry_publication",
    "fact_sheet": "patient_resource",
}
# Values left deliberately unmapped, because folding them would assert a study design nobody
# has established: clinical_study, pilot_study, report, genetic_association, in_vitro, other.
# G14u reports them rather than letting them pass as cross-checked.


def study_tier(v):
    """Tier implied by study_type, after folding synonyms. None when unmappable."""
    return TIER_BY_TYPE.get(STUDY_TYPE_SYNONYM.get(v, v))


# Bible 23.1 minimum_per_layer, keyed by leading sitemap section.
MIN_PER_LAYER = {"5": 3, "6": 3, "3": 2, "4": 2, "7": 1}
# House rule: how many distinct clusters one citation may span before it is worth a look.
CLUSTER_SPREAD_WARN = 5

# Pages that state no numbers and no evidence claims, so there is nothing for a citation
# to support. A minimum-count gate cannot tell "cited nothing because it claims nothing"
# from "claims things and cites nothing", so the exemption has to be declared.
#
# 2026-08-24: it is declared IN THE DATA, as the string "CITATION EXEMPTION" in the page's
# reconciliation_notes — the same mechanism check-plan.mjs already uses for INTENT EXEMPTION.
# This used to be a Python dict holding two vth- fingerprints, which put one brand's page list
# inside a gate all three brands run, and duplicated notes both pages already carried. Two
# copies of the same fact drift; the one in the database is the one an operator can edit.
# A page only qualifies while it stays claim-free: adding a statistic means removing the line
# from its notes, not widening anything here.
EXEMPT_MARKER = "CITATION EXEMPTION"
# G8 freshness ceilings in years, by tier.
FRESHNESS = {1: 5, 2: 7, 5: 7}
COMMERCIAL_RE = re.compile(r"\bmanufacturer\b|\bversah\b|graphy inc|\btrioclear\b|tera harz", re.I)
PUBMED_URL_RE = re.compile(r"pubmed\.ncbi\.nlm\.nih\.gov/([0-9]+)")


def load_key():
    if "SUPABASE_SERVICE_KEY" in os.environ:
        return os.environ["SUPABASE_SERVICE_KEY"]
    with open(SECRETS, encoding="utf-8") as fh:
        for line in fh:
            if line.startswith("SUPABASE_SERVICE_KEY="):
                return line.split("=", 1)[1].strip()
    sys.exit("SUPABASE_SERVICE_KEY not found in env or " + SECRETS)


KEY = load_key()


def fetch_all(table, select, flt=""):
    """PostgREST caps a response at 1000 rows, so page until short."""
    out, offset = [], 0
    while True:
        url = "%s/rest/v1/%s?select=%s%s&limit=1000&offset=%d" % (SB, table, select, flt, offset)
        req = urllib.request.Request(url, headers={"apikey": KEY, "Authorization": "Bearer " + KEY})
        batch = json.load(urllib.request.urlopen(req))
        out += batch
        if len(batch) < 1000:
            return out
        offset += 1000


def in_pool(citation, brand):
    """brand_scope '*' means every brand's pool; [] means parked, not in any."""
    scope = citation.get("brand_scope") or []
    return bool(scope) and ("*" in scope or brand in scope)


def run(brand, verbose):
    cites = fetch_all("seo_citations", "fingerprint,title,citation_type,study_type,citation_tier,publication_year,"
                                       "pubmed_pmid,doi,url,isbn,publisher_name,verification_status,"
                                       "is_retracted,brand_scope")
    links = fetch_all("seo_page_citations", "page_fp,citation_fp,citation_purpose,status")
    pages = fetch_all("seo_website_page_master", "page_fingerprint,sitemap_node_id,sitemap_section,status,cluster_id,reconciliation_notes",
                      "&brand_id=eq." + urllib.parse.quote(brand))
    by_fp = {c["fingerprint"]: c for c in cites}
    pool = [c for c in cites if in_pool(c, brand)]
    this_year = datetime.date.today().year

    # Page-level gates look only at this brand's pages. They used to walk every binding in
    # the shared table, which meant another brand's half-finished work blocked this brand's
    # deploy: on 2026-08-17 nine citations another session had inserted but not yet verified
    # turned check:citations red here, on pages this repo does not own and cannot fix.
    # A gate invoked with --brand should report that brand's problems. Pool-level gates
    # (G1, G5, G8, G9, G10, G14, G15) still cover the shared pool, because a wrong tier or a
    # missing locator is wrong for everyone who draws from it.
    own_pages = {p["page_fingerprint"] for p in pages}
    active = [l for l in links if l["status"] == "active" and l["page_fp"] in own_pages]

    findings = {}

    # 2026-08-24: split the locatorless rows by whether anyone relies on them. A row that says
    # verification_status='unverified' and is bound to no page is a research to-do somebody wrote
    # down honestly — smile-scape keeps eight, naming the EFP and EAO consensus documents it still
    # has to track down. Blocking on those makes the gate punish bookkeeping and gives the brand a
    # reason to delete its own backlog to get green. The guarantee that matters is unaffected:
    # G2 blocks any unverified citation the moment it is bound to a page, so one of these cannot
    # reach a reader without failing there first.
    bound_fps = {l["citation_fp"] for l in links}
    _locatorless = [
        c for c in pool
        if not any(c.get(k) for k in ("pubmed_pmid", "doi", "url", "isbn"))
        and c.get("citation_type") not in ("textbook", "other")
    ]
    findings["G1_no_locator"] = [
        (c["fingerprint"], c["title"]) for c in _locatorless
        if c.get("verification_status") == "verified" or c["fingerprint"] in bound_fps
    ]
    findings["G1w_locatorless_backlog"] = [
        (c["fingerprint"], c["title"]) for c in _locatorless
        if c.get("verification_status") != "verified" and c["fingerprint"] not in bound_fps
    ]
    findings["G2_unverified_on_page"] = [
        (l["page_fp"], l["citation_fp"], by_fp[l["citation_fp"]].get("verification_status"))
        for l in active
        if l["citation_fp"] in by_fp and by_fp[l["citation_fp"]].get("verification_status") != "verified"
    ]
    findings["G3_retracted_on_page"] = [
        (l["page_fp"], l["citation_fp"])
        for l in active
        if l["citation_fp"] in by_fp and (
            by_fp[l["citation_fp"]].get("is_retracted")
            or by_fp[l["citation_fp"]].get("verification_status") in ("retracted", "broken_link"))
    ]
    findings["G4_url_pmid_mismatch"] = []
    for c in cites:
        m = PUBMED_URL_RE.search(c.get("url") or "")
        if m and m.group(1) != (c.get("pubmed_pmid") or ""):
            findings["G4_url_pmid_mismatch"].append((c["fingerprint"], c.get("pubmed_pmid"), c.get("url")))
    findings["G5_tier_type_mismatch"] = [
        (c["fingerprint"], c.get("citation_tier"), c.get("citation_type"), c["title"])
        for c in pool
        if c.get("citation_type") in TIER_BY_TYPE and c.get("citation_tier") != TIER_BY_TYPE[c["citation_type"]]
    ]

    # G6/G7 scope: only pages that will carry content. Merged and Dropped pages
    # were folded into another URL and have nothing to cite.
    #
    # 2026-08-16: split by status. The minimum is a promise about what SHIPS — a page
    # on the site making clinical claims must rest on evidence. Applying it to Planned
    # pages demands citations for text nobody has written yet, and the only way to
    # satisfy that is to attach something. That is literally where the backbone sweep
    # came from, and it put 182 off-topic citations on this brand's pages: fluoride
    # varnish in children on laser and TMJ pages, frenotomy and breastfeeding on the
    # microbiome cluster. Live still blocks; Planned warns, so the shortfall stays
    # visible as the writing queue it actually is.
    got = Counter(l["page_fp"] for l in active)
    live_pages = {p["page_fingerprint"] for p in pages if p.get("status") == "Live"}
    # 2026-08-23: fall back to sitemap_section when sitemap_node_id is empty, and make an
    # unresolvable section a finding instead of a quota of 0. The old lookup defaulted to 0, so
    # a row with no node_id was exempted from the evidence minimum without anything being said —
    # deezy's 72 translation rows sat in exactly that hole, all of them Live, all with no
    # citations. A page the gate cannot classify is a page the gate has not checked, and those
    # are opposite outcomes that must not share a code path.
    def _section(p):
        node = str(p.get("sitemap_node_id") or "").split(".")[0].strip()
        return node or str(p.get("sitemap_section") or "").strip()

    considered = [p for p in pages if (p.get("status") or "Planned") in ("Planned", "Live")]
    quota, unclassified = {}, []
    for p in considered:
        sec = _section(p)
        if sec in MIN_PER_LAYER:
            quota[p["page_fingerprint"]] = MIN_PER_LAYER[sec]
        elif sec:
            quota[p["page_fingerprint"]] = 0      # a real section with no stated minimum
        else:
            unclassified.append((p["page_fingerprint"],))
    for p in considered:
        if EXEMPT_MARKER in (p.get("reconciliation_notes") or ""):
            quota.pop(p["page_fingerprint"], None)
    findings["G6u_section_unresolvable"] = unclassified

    short = [(fp, q, got.get(fp, 0)) for fp, q in quota.items() if q > 0 and got.get(fp, 0) < q]
    findings["G6_below_minimum"] = [r for r in short if r[0] in live_pages]
    findings["G6w_planned_below_minimum"] = [r for r in short if r[0] not in live_pages]

    tiers_on_page = defaultdict(set)
    for l in active:
        c = by_fp.get(l["citation_fp"])
        if c and c.get("citation_tier") is not None:
            tiers_on_page[l["page_fp"]].add(c["citation_tier"])
    no_anchor = [(fp,) for fp, q in quota.items()
                 if q > 0 and not any(t <= 3 for t in tiers_on_page.get(fp, ()))]
    findings["G7_no_tier1_3"] = [r for r in no_anchor if r[0] in live_pages]
    findings["G7w_planned_no_tier1_3"] = [r for r in no_anchor if r[0] not in live_pages]

    findings["G8_stale"] = [
        (c["fingerprint"], c.get("citation_tier"), c.get("publication_year"), c["title"])
        for c in pool
        if c.get("publication_year") and c.get("citation_tier") in FRESHNESS
        and c["publication_year"] < this_year - FRESHNESS[c["citation_tier"]]
    ]
    findings["G9_undisclosed_commercial"] = [
        (c["fingerprint"], c.get("citation_type"), c.get("publisher_name") or c["title"])
        for c in pool
        if COMMERCIAL_RE.search((c.get("publisher_name") or "") + " " + (c.get("title") or ""))
        and c.get("citation_type") not in ("industry_publication", "other")
    ]

    dupes = []
    for field in ("doi", "pubmed_pmid"):
        counts = Counter(c[field] for c in pool if c.get(field))
        dupes += [("G10_duplicate_" + field, v, n) for v, n in counts.items() if n > 1]
    findings["G10_duplicate_locator"] = dupes

    pair = Counter((l["page_fp"], l["citation_fp"]) for l in active)
    findings["G11_dup_on_page"] = [(p, c, n) for (p, c), n in pair.items() if n > 1]

    # G12 (L28) — page_fp must hold page_fingerprint ("vth-4.4.4"), never the ULID
    # identity column `fingerprint` ("page_942B5270A0314DAB"). There is no FK, so a
    # wrong key does not error: the row survives, the join misses, and the page reads
    # as uncited. Validity is checked against every brand's fingerprints, not just this
    # one, because a bad key has no brand prefix to filter on.
    # G13 — one citation bound across many unrelated clusters is how a cluster-level
    # matcher announces it guessed. The signal is structural, not semantic: no keyword
    # comparison, so it cannot be made to approve everything by loosening a word list.
    # It warns rather than blocks, because a few citations legitimately span clusters
    # (periodontitis and cardiovascular disease belongs to both oral-systemic and
    # periodontics). Anything above the threshold is asking to be read, not deleted.
    # Found this way on 2026-08-16: the MRONJ family, bound to 19 pages about posture,
    # aesthetic devices and glossaries — none of which mention bone-modifying drugs.
    cluster_of = {p["page_fingerprint"]: p.get("cluster_id") for p in pages}
    spread = defaultdict(set)
    for l in active:
        if l["page_fp"] in cluster_of:
            spread[l["citation_fp"]].add(cluster_of[l["page_fp"]])
    # Regulations, laws and professional guidelines are broad by their nature — a code of
    # dental practice belongs on every page it governs, and counting clusters cannot tell
    # that apart from a matcher smearing one paper across the site. Flagged by
    # eywa-smile-scape, whose professional-conduct rules span six clusters legitimately.
    BROAD_BY_NATURE = {"regulation", "law", "clinical_guideline", "regulatory_document",
                       "clinical_practice_guideline", "consensus_statement"}
    findings["G13_citation_spread"] = sorted(
        ((fp, "%d clusters" % len(cl), (by_fp.get(fp) or {}).get("title", "?"))
         for fp, cl in spread.items()
         if len(cl) >= CLUSTER_SPREAD_WARN
         and (by_fp.get(fp) or {}).get("study_type") not in BROAD_BY_NATURE
         and (by_fp.get(fp) or {}).get("citation_type") not in BROAD_BY_NATURE),
        key=lambda r: -int(r[1].split()[0]))

    # G14 — the pool carries two type fields, citation_type and study_type, and 197 of 431
    # rows disagree. Most are vocabulary variants (rct / randomized_controlled_trial). The
    # ones that matter map to different tiers: fourteen systematic reviews are labelled
    # expert_opinion, which parks them at tier 6 and lets G5 pass them, because G5 only ever
    # reads citation_type. This does not decide which field is authoritative — it reports
    # where the choice changes the answer, so a human makes it. Raised by eywa-smile-scape
    # after they found an AAOP guideline sitting at tier 6 as a textbook.
    findings["G14_type_fields_disagree"] = [
        (c["fingerprint"], "%s→t%d vs %s→t%d" % (
            c["citation_type"], TIER_BY_TYPE[c["citation_type"]],
            c["study_type"], study_tier(c["study_type"])), c["title"])
        for c in pool
        if c.get("citation_type") in TIER_BY_TYPE and study_tier(c.get("study_type")) is not None
        and TIER_BY_TYPE[c["citation_type"]] != study_tier(c["study_type"])
    ]
    # A study_type nobody can map is a row G14 cannot cross-check. Before this existed it was
    # indistinguishable from a row that passed, which is the failure this whole gate set is for.
    findings["G14u_study_type_uncomparable"] = [
        (c["fingerprint"], c.get("study_type"), c["title"]) for c in pool
        if c.get("study_type") and study_tier(c["study_type"]) is None
    ]

    # G15 — a row with no study_type cannot be cross-checked by G14 at all, so it rests on
    # citation_type alone and nothing can contradict it. That is how a randomised trial sat
    # in the pool as a cohort study at tier 5: G5 was satisfied, because tier 5 is right for
    # a cohort study, and there was no second field to disagree. Reported by eywa-smile-scape
    # from the other side, after their own tier detector skipped every row with a null here.
    findings["G15_no_study_type"] = [
        (c["fingerprint"], "tier %s, type %s, no study_type" % (c.get("citation_tier"), c.get("citation_type")),
         c["title"])
        for c in pool if not (c.get("study_type") or "").strip()
    ]

    all_page_fps = {p["page_fingerprint"] for p in fetch_all("seo_website_page_master", "page_fingerprint")}
    findings["G12_page_fp_not_fingerprint"] = [
        (l["page_fp"], l["citation_fp"],
         "ULID identity column — use page_fingerprint"
         if re.match(r"^page_[0-9A-Za-z]{16}$", l["page_fp"] or "") else "no such page")
        for l in active if (l["page_fp"] or "") not in all_page_fps
    ]

    print("Citation QA gates — brand %s · pool %d of %d citations · %d active links · %d pages"
          % (brand, len(pool), len(cites), len(active), len(pages)))
    print("-" * 78)
    blocking = 0
    for gate, rows in findings.items():
        # 2026-08-23: the warn marker is the trailing "w" on the gate id ("G6w_..."), not the
        # substring "w_" anywhere in the name. "G6_below_minimum" contains "w_" inside the word
        # "below", so the one gate that is supposed to block a Live page shipping without its
        # evidence minimum has been printing WARN and adding nothing to the blocking count since
        # the day it was named. Match the id, not the sentence.
        # Gate ids are a number plus an optional suffix: G6 blocks, G6w warns, G6u is a
        # separate blocking finding on the same number. Split the two apart before deciding,
        # or a suffix silently changes which bucket a gate lands in — the reason this
        # classifier was rewritten in the first place.
        gid = gate.split("_", 1)[0]
        base = re.match(r"G\d+", gid).group(0)
        warn = base in ("G8", "G13", "G14", "G15") or gid.endswith("w")
        if not rows:
            print("  PASS  %-28s 0" % gate)
            continue
        if not warn:
            blocking += len(rows)
        print("  %s  %-28s %d" % ("WARN" if warn else "FAIL", gate, len(rows)))
        shown = rows if verbose else rows[:5]
        for r in shown:
            print("          " + " | ".join(str(x)[:64] for x in r))
        if len(rows) > len(shown):
            print("          ... %d more (--verbose for all)" % (len(rows) - len(shown)))
    print("-" * 78)
    print("blocking rows: %d" % blocking)
    return 1 if blocking else 0


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--brand", default="vth-biodent")
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args()
    sys.exit(run(a.brand, a.verbose))
