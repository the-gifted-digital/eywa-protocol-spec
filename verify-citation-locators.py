#!/usr/bin/env python3
"""
Round-trip every citation locator against its source of truth.

Why this exists
---------------
2026-07-29, VTH BioDent: of 115 citations carrying a PMID or DOI, 13 pointed at
a completely unrelated paper — an ecology study, a tomato-transformation paper,
an ALS spatial analysis, a firefighter lung-function study. The stored titles
were plausible and on-topic; only the identifiers were wrong. No amount of
reading the pool catches this. You have to ask PubMed and Crossref.

Usage
-----
    # 1. export the pool to TSV: fingerprint <TAB> pmid <TAB> doi <TAB> title
    #    (psql \copy, Supabase export, whatever)
    python3 verify-citation-locators.py pool.tsv > verdicts.tsv

Output columns: fingerprint, verdict, locator, stored_title, source_title
Verdicts: PASS | TITLE_MISMATCH | NOT_FOUND | NO_LOCATOR

TITLE_MISMATCH is not automatically a fabrication — a stored title that is a
human paraphrase will also trip it. Read every one. Rule of thumb: if the source
record is on-topic, keep the row and overwrite the title with the real one; if
the source record is from another field entirely, strip the locator, set
verification_status='broken_link', and re-source the claim.
"""
import sys, json, re, time, urllib.request, urllib.parse, urllib.error
import xml.etree.ElementTree as ET

UA = {"User-Agent": "eywa-citation-audit/1.0 (mailto:naphannop.n@gmail.com)"}
EUTILS = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"

STOP = set("""the a an of and for in on with to vs versus is are at by from as its their
study review systematic meta analysis clinical trial randomized randomised outcome
outcomes effect effects""".split())


def tokens(s):
    return {w for w in re.findall(r"[a-z0-9]+", (s or "").lower())
            if len(w) > 3 and w not in STOP}


def overlap(a, b):
    A, B = tokens(a), tokens(b)
    if not A or not B:
        return 0.0
    return len(A & B) / max(1, min(len(A), len(B)))


def fetch_pubmed(pmids):
    """Batch efetch. Returns {pmid: {title, journal, year, pubtypes}}."""
    out = {}
    for i in range(0, len(pmids), 150):
        chunk = pmids[i:i + 150]
        req = urllib.request.Request(
            EUTILS + "efetch.fcgi", headers=UA,
            data=urllib.parse.urlencode(
                {"db": "pubmed", "retmode": "xml", "id": ",".join(chunk)}).encode())
        root = ET.fromstring(urllib.request.urlopen(req, timeout=60).read())
        for a in root.iter("PubmedArticle"):
            out[a.findtext(".//PMID")] = {
                "title": " ".join((a.findtext(".//ArticleTitle") or "").split()),
                "journal": a.findtext(".//Journal/ISOAbbreviation") or "",
                "year": a.findtext(".//PubDate/Year") or "",
                "pubtypes": [p.text for p in a.iter("PublicationType")],
            }
        time.sleep(0.4)
    return out


def fetch_crossref(doi):
    try:
        req = urllib.request.Request(
            "https://api.crossref.org/works/" + urllib.parse.quote(doi), headers=UA)
        m = json.load(urllib.request.urlopen(req, timeout=30))["message"]
        return {
            "title": re.sub(r"<[^>]+>", "", (m.get("title") or ["?"])[0]),
            "journal": (m.get("container-title") or [""])[0],
            "year": (m.get("issued", {}).get("date-parts", [[None]])[0] or [None])[0],
        }
    except Exception:
        return None


def tier_from_pubtypes(pt):
    """Bible 23.1 tier, derived from PubMed PublicationType — not from the title."""
    s = set(pt)
    if s & {"Systematic Review", "Meta-Analysis", "Network Meta-Analysis"}:
        return 1, ("meta_analysis" if s & {"Meta-Analysis", "Network Meta-Analysis"}
                   else "systematic_review")
    if s & {"Randomized Controlled Trial", "Clinical Trial", "Controlled Clinical Trial"}:
        return 2, "rct"
    if s & {"Practice Guideline", "Guideline", "Consensus Statement"}:
        return 3, "clinical_guideline"
    if s & {"Review", "Introductory Journal Article"}:
        return 6, "expert_opinion"
    if s & {"Case Reports"}:
        return 6, "case_report"
    if s & {"Letter", "Comment", "Editorial"}:
        return 6, "editorial"
    return 5, "cohort_study"


def main(path, threshold=0.34):
    rows = []
    for line in open(path, encoding="utf-8"):
        parts = line.rstrip("\n").split("\t")
        if len(parts) < 4 or parts[0] in ("fingerprint", ""):
            continue
        rows.append(parts[:4])

    pmids = [r[1] for r in rows if r[1] and r[1].isdigit()]
    pm = fetch_pubmed(pmids) if pmids else {}

    print("fingerprint\tverdict\tlocator\tstored_title\tsource_title\ttier_from_source")
    for fp, pmid, doi, title in rows:
        src = tier = None
        if pmid and pmid.isdigit():
            rec, locator = pm.get(pmid), "PMID:" + pmid
            if rec:
                src = rec["title"]
                tier = "T%d/%s" % tier_from_pubtypes(rec["pubtypes"])
        elif doi:
            rec, locator = fetch_crossref(doi), "DOI:" + doi
            time.sleep(0.25)
            src = rec["title"] if rec else None
        else:
            print("\t".join([fp, "NO_LOCATOR", "", title, "", ""]))
            continue

        if src is None:
            verdict = "NOT_FOUND"
        elif overlap(title, src) < threshold:
            verdict = "TITLE_MISMATCH"
        else:
            verdict = "PASS"
        print("\t".join([fp, verdict, locator, title, src or "", tier or ""]))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    main(sys.argv[1])
