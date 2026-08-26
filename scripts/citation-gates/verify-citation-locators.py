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
Verdicts: PASS | TITLE_MISMATCH | TITLE_INCOMPLETE | DOI_PMID_CONFLICT | UNREACHABLE | NOT_FOUND | NO_LOCATOR

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


# A transport failure is not a fact about the data. Distinct from None, which means
# "the source answered, and it has no such record".
UNREACHABLE = object()


def full_text(el, path):
    """All the text under a child element, tails included.

    findtext() and .text return only the text BEFORE the first child, so a title
    carrying inline markup — <i> for species names, <sup>/<sub> for formulae — comes
    back short or empty. Measured across the 543 PMIDs in the pool: three titles were
    truncated and one was empty. PMID 30746447 opens with
    "<i>Porphyromonas gingivalis</i> in Alzheimer's disease brains", so findtext gave ""
    against a 132-character title, agreement scored 0.00, and a correct citation was
    reported TITLE_MISMATCH — whose documented remedy is to strip the locator.

    eywa-deezy found the same fault in how I was reading abstracts (PMID 34776943 has a
    1,948-character abstract that .text reported as empty) and asked me to check the
    gates. This is what that check found.
    """
    node = el.find(path)
    return " ".join("".join(node.itertext()).split()) if node is not None else ""


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
        # BOTH element types. efetch wraps NCBI Bookshelf records (StatPearls,
        # GeneReviews, NBK chapters — heavily cited in clinical content) in
        # <PubmedBookArticle>, which root.iter("PubmedArticle") never yields. Every
        # valid Bookshelf PMID therefore fell through to "not in pm" and was reported
        # NOT_FOUND, and this file's own remedy for NOT_FOUND is to strip the locator.
        # A book record puts its title in BookTitle or ArticleTitle depending on
        # whether the citation is the whole book or one chapter, so read either.
        for tag in ("PubmedArticle", "PubmedBookArticle"):
            for a in root.iter(tag):
                pmid = a.findtext(".//PMID")
                if not pmid:
                    continue
                out[pmid] = {
                    "title": full_text(a, ".//ArticleTitle") or full_text(a, ".//BookTitle"),
                    "journal": (a.findtext(".//Journal/ISOAbbreviation")
                                or a.findtext(".//Book/Publisher/PublisherName") or ""),
                    "year": (a.findtext(".//PubDate/Year")
                             or a.findtext(".//Book/PubDate/Year") or ""),
                    "pubtypes": [p.text for p in a.iter("PublicationType")],
                    # The DOI PubMed itself links to this PMID. Free — it is already in
                    # the response — and it is the only way to check a DOI on a row that
                    # also carries a PMID. See the conflict branch in main().
                    "doi": next((i.text for i in a.iter("ArticleId")
                                 if (i.get("IdType") or "").lower() == "doi" and i.text), ""),
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
    except urllib.error.HTTPError as e:
        # 404 is Crossref answering "no such DOI". Anything else is Crossref not
        # answering: 429 (likely — the caller sleeps 0.25s with no backoff), 500, 503.
        return None if e.code == 404 else UNREACHABLE
    except Exception:
        # Timeout, DNS, TLS. Never a statement about the DOI.
        return UNREACHABLE


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
    # No match — including the modal case ["Journal Article"] on its own, and [None]
    # when a PublicationType element carries no text. This used to fall through to
    # (5, "cohort_study"), printing a specific study design under a column header that
    # reads as derived fact; a tier reconciliation trusting that column would rewrite
    # accurate hand-entered rows to a guess. reconcile-citation-tiers.py returns None
    # here and the two are meant to stay identical — this copy is the one that drifted.
    return None, None


def main(path, threshold=0.34):
    rows = []
    for line in open(path, encoding="utf-8"):
        parts = line.rstrip("\n").split("\t")
        if len(parts) < 4 or parts[0] in ("fingerprint", ""):
            continue
        rows.append(parts[:4])

    if not rows:
        # An empty verdicts stream is the exact output of a perfectly clean pool, so it
        # cannot be allowed to print like one: a truncated or wrong-format export would
        # read as "every citation round-tripped".
        sys.exit("🔴 no input rows parsed from %s — expected TSV "
                 "fingerprint\\tpmid\\tdoi\\ttitle with at least 4 columns.\n"
                 "   ศูนย์แถวที่อ่านได้ ไม่ใช่ศูนย์แถวที่ผิด" % path)

    pmids = [r[1] for r in rows if r[1] and r[1].isdigit()]
    pm = fetch_pubmed(pmids) if pmids else {}

    print("fingerprint\tverdict\tlocator\tstored_title\tsource_title\ttier_from_source")
    for fp, pmid, doi, title in rows:
        src = tier = None
        if pmid and pmid.isdigit():
            rec, locator = pm.get(pmid), "PMID:" + pmid
            if rec:
                src = rec["title"]
                t, name = tier_from_pubtypes(rec["pubtypes"])
                tier = "T%d/%s" % (t, name) if t else "UNCLASSIFIED"
                # A row carrying BOTH locators had only ever had one of them checked.
                # This branch used to be `if pmid: ... elif doi: ...`, so on any row with
                # a PMID the DOI was skipped entirely — 521 of the 613 rows in the shared
                # pool. Two of them were wrong and had been sitting at
                # verification_status='verified': cite_7B4BB347ECAE4D71 held Sanz's DOI
                # against Polak's PMID and title (eywa-deezy found it), and
                # cite_07FB9899456B4030 held a DOI that 404s at Crossref (found only by
                # running this comparison across the whole pool).
                # The check costs nothing — PubMed returns its own DOI in the same
                # response — and it is reported before the title comparison, because the
                # title matches perfectly in exactly this failure.
                ours = (doi or "").strip().lower()
                theirs = (rec.get("doi") or "").strip().lower()
                if ours and theirs and ours != theirs:
                    print("\t".join([fp, "DOI_PMID_CONFLICT", locator, title,
                                      "stored %s · PubMed links %s" % (ours, theirs), tier or ""]))
                    continue
        elif doi:
            rec, locator = fetch_crossref(doi), "DOI:" + doi
            time.sleep(0.25)
            if rec is UNREACHABLE:
                # Not a verdict about the DOI. Printing NOT_FOUND here is what turns one
                # rate-limit window into an instruction to strip every DOI in the pool.
                print("\t".join([fp, "UNREACHABLE", locator, title, "", ""]))
                continue
            src = rec["title"] if rec else None
        else:
            print("\t".join([fp, "NO_LOCATOR", "", title, "", ""]))
            continue

        # PASS means the overlap cleared MATCH_FLOOR. It does NOT mean the stored title
        # is the title. eywa-deezy diffed stored against source character by character
        # across their 47 PubMed rows after the findtext fix and found one that had
        # PASSed for months reading "A systematic review and-analysis" — the word "meta"
        # sat in inline markup their intake tool had dropped, and they had already
        # written it up as a typo in PubMed's own record rather than a fault in their
        # pipeline. A threshold cannot catch that: 0.34 leaves plenty of room to lose a
        # word. Running the same diff over vth's 543 rows found one, on the same PMID
        # whose title findtext could not read at all.
        # Warns, never blocks — a stored title that is a deliberate human paraphrase is
        # allowed under DR-061, and this cannot tell the two apart. It says what differs
        # and lets a person decide.
        if src and " ".join((title or "").split()).strip().rstrip(".").lower() \
                != " ".join(src.split()).strip().rstrip(".").lower() \
                and overlap(title, src) >= threshold:
            print("\t".join([fp, "TITLE_INCOMPLETE", locator, title, src, tier or ""]))
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
