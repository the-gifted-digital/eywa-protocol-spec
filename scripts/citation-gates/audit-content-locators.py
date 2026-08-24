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
import functools
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


# NOT adjacent to a hyphen on either side. "Global burden of severe periodontitis in
# 1990-2010" states a study period, not a publication year, and the first version of
# this check read both ends as claimed years and failed three correct VTH references
# that had scored 0.80 on title agreement.
YEAR_RE = re.compile(r"(?<![\d\-–])((?:19|20)\d{2})(?![\d\-–])")
# Epub-ahead-of-print means a label written from the online record and a PubMed record
# carrying the print year can differ by one. Anything wider is not a rounding difference.
YEAR_SLACK = 1


# "Surname AB," / "Surname AB." / "Surname AB et al" — the initials must be FOLLOWED by
# punctuation or "et al", which is what separates a person from an organisation.
# "International RDC/TMD Consortium Network" matched the naive pattern as surname
# "International" with initials "RDC", and outvoted the one page that credited
# Schiffman correctly — the check inventing the disagreement it then reported.
SURNAME_RE = re.compile(
    r"\b([A-ZÀ-Ý][A-Za-zÀ-ÿ'’\-]{2,})\s+[A-Z]{1,3}(?=[,.]|\s+et\s+al)")
# Belt and braces: words that open an organisation's name and never a person's.
ORG_WORDS = {"international", "american", "european", "national", "world", "royal",
             "academy", "association", "consortium", "network", "society",
             "federation", "college", "institute", "committee", "workshop"}


def claimed_surname(label):
    """The first author surname a label credits, or None if it credits nobody.

    Matches the "Surname AB" shape academic labels use. A claim-style label in Thai
    names nobody and returns None, which is correct — it makes no claim to contradict.
    """
    m = SURNAME_RE.search(label or "")
    if not m:
        return None
    sn = m.group(1).lower()
    return None if sn in ORG_WORDS else sn


def sibling_disagreements(by_url):
    """Labels that credit a different author than their siblings on the same locator.

    eywa-deezy's idea, 2026-08-24, and the cheapest of the three signals: it needs no
    API call at all, so it still works when PubMed and Crossref are unreachable — the
    exact situation in which the other two checks correctly refuse to conclude
    anything. PMID 32383274 is cited on 26 pages as Sanz, the EFP S3 guideline, and on
    one page as Chapple, a different consensus paper two years earlier. Twenty-six
    against one settles which side is wrong without asking anybody.

    Reported, never blocking. The majority is evidence, not proof — a locator could in
    principle be mislabelled on 26 pages and right on the 27th, and a gate that decides
    that by counting would be wrong in exactly the case worth catching.
    """
    out = []
    for url, entries in sorted(by_url.items()):
        claims = {}
        for slug, label in entries:
            sn = claimed_surname(label)
            if sn:
                claims.setdefault(sn, []).append((slug, label))
        if len(claims) < 2:
            continue
        ranked = sorted(claims.items(), key=lambda kv: -len(kv[1]))
        top, top_rows = ranked[0]
        for sn, rows in ranked[1:]:
            # Only when the majority is decisive. Two against two says nothing.
            if len(top_rows) >= 3 * max(1, len(rows)):
                for slug, label in rows:
                    out.append((slug, label, url, sn, top, len(top_rows), len(rows)))
    return out


def year_contradicts(label, year):
    """True when the label states a year and none of them is the paper's.

    eywa-deezy, 2026-08-24: smile-aesthetics-guide labelled a PMID
    "de Geus JL, At-home vs in-office bleaching ... Oper Dent. 2016." The PMID is
    Centenaro GG 2026, a randomised trial on hydrogen-peroxide concentration — wrong
    author, wrong journal, wrong study type, ten years out. It sailed past this gate
    because both papers are about bleaching and the titles share enough tokens to
    score 0.50 against a 0.34 floor, so it never reached the author comparison.

    A year is an integer. There is no fuzzy matching to tune and no API call to make
    beyond the one already made, and on its own it catches the case the title
    comparison and the author comparison both missed.
    """
    if not year:
        return False
    stated = YEAR_RE.findall(label or "")
    if not stated:
        return False
    return all(abs(int(s) - int(year)) > YEAR_SLACK for s in stated)


def identifies_by_author_year(label, authors, year):
    """Does this label name the paper the way an academic citation names it?

    DR-061 (2026-08-24). Nothing anywhere said what references[].label had to
    contain, so eywa-deezy wrote the finding — "การขูดหินปูนช่วยลดการอักเสบของเหงือก" —
    where vth-biodent wrote the paper's title. Both are defensible: one reads
    better to a patient, the other is machine-checkable. The ruling is that both
    are allowed, and the label must merely IDENTIFY the paper: either it carries
    enough of the real title to match, or it carries a first-author surname and
    the year, which is how a human names a paper without quoting its title.

    This matters because it is the only thing separating two very different
    findings that scored in the same band. A label that is a summary and a label
    that points at the wrong paper both disagree with the resolved title. Author
    and year tell them apart: the summary still names the right work.
    """
    low = (label or "").lower()
    if not year or str(year) not in low:
        return False
    return any(s and len(s) > 2 and s.lower() in low for s in (authors or []))


def _surnames_pubmed(rec):
    # esummary gives "Smith AB" — the surname is everything before the initials.
    out = []
    for a in (rec.get("authors") or []):
        n = (a.get("name") or "").strip()
        if n:
            out.append(n.split()[0])
    return out


def resolve(url):
    """Return (kind, identifier, title, authors, year).

    title is the resolved title, "" when there is nothing to resolve against,
    and None when the source could not be reached. None is deliberately not the
    same as a mismatch: unreachable is a network fact, wrong is a data fact, and
    only the second should ever fail a build. A gate that goes red because an
    API blinked is one people learn to ignore.

    authors and year come back for the same reason: without them a label written
    as a plain-language finding is indistinguishable from a label naming the
    wrong paper, and only one of those is a defect.
    """
    m = PMID_RE.search(url)
    if m:
        pmid = m.group(1)
        try:
            rec = fetch(ESUMMARY + pmid)["result"][pmid]
            yr = re.search(r"\b(19|20)\d{2}\b", str(rec.get("pubdate") or ""))
            return ("pmid", pmid, rec.get("title"), _surnames_pubmed(rec),
                    yr.group(0) if yr else "")
        except Exception:
            return "pmid", pmid, None, [], ""
    doi = url.lower().replace("https://doi.org/", "").replace("http://doi.org/", "").strip()
    if doi.startswith("10."):
        try:
            msg = fetch(CROSSREF + urllib.parse.quote(doi, safe=""))["message"]
            parts = (msg.get("issued", {}).get("date-parts") or [[None]])[0] or [None]
            return ("doi", doi, (msg.get("title") or [None])[0],
                    [a.get("family") for a in (msg.get("author") or []) if a.get("family")],
                    str(parts[0]) if parts[0] else "")
        except Exception:
            return "doi", doi, None, [], ""
    # A plain web source — a society guideline page, a government document.
    # Nothing to resolve a title against, so "" rather than None. Normalised the
    # same way db_backed_keys stores it: an unnormalised key here made the
    # backing check miss an AAO reference that was linked all along.
    return "url", url.rstrip("/").lower(), "", [], ""


def db_backed_keys(brand):
    """The identifiers seo_page_citations actually links, keyed by page slug."""
    # This used to re-open the secrets file by hand, referencing a name that was never
    # defined — a NameError sitting behind `if not key`, so it only fired for someone
    # without SUPABASE_SERVICE_KEY in the environment. Everyone who tested had it set.
    key = eywa_supabase.key()
    page_all = functools.partial(eywa_supabase.fetch, k=key)

    cites = {c["fingerprint"]: c for c in page_all("seo_citations", "fingerprint,doi,pubmed_pmid,url")}

    # `--brand` is a brand_id everywhere else in this directory, and all three brands'
    # package.json pass the slug here too — but this one gate filtered on brand_name,
    # which holds the display name ("VTH BioDent"). brand_name=eq.vth-biodent matched
    # nothing, so `pages` was empty, every binding was dropped below, and the unbacked
    # check reported nothing on every CI run for every brand since the flag was added.
    # Accept either spelling, and refuse to continue on a brand that matches no page:
    # a filter that selects nothing must not be reported as a brand with nothing wrong.
    rows = page_all("seo_website_page_master", "page_fingerprint,slug,brand_id,brand_name")
    pages = {p["page_fingerprint"]: p["slug"] for p in rows
             if brand in (p.get("brand_id"), p.get("brand_name"))}
    if not pages:
        seen = sorted({str(p.get("brand_id")) for p in rows} |
                      {str(p.get("brand_name")) for p in rows} - {"None"})
        sys.exit("🔴 --brand %r matches no page. brand_id or brand_name, one of: %s"
                 % (brand, ", ".join(seen)))
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
    seen, wrong, unresolved, unbacked, label_form = {}, [], [], [], []
    by_url = {}   # url -> [(slug, label)] · ป้อน sibling_disagreements ซึ่งไม่ต้องต่อเน็ต
    # 2026-08-24: this globbed "*/th/*.yaml" and so audited Thai content only. vth-biodent
    # writes ten languages — 183 of its 367 files, half the brand, were never checked while the
    # gate reported clean. deezy missed 147. A brand whose content is not laid out as
    # <template>/<lang>/ got zero files and a PASS, which is the exact failure this gate set
    # exists to catch, sitting inside one of the gates.
    # Take every .yaml under root, full stop. The fixed-depth glob was kept as the
    # primary with the recursive one as a *fallback that only fired on zero files*,
    # which meant a layout where most content sits two levels down and some sits three
    # scanned the two and never mentioned the three — partial coverage reported as full,
    # the same shape as the bug above but quieter, because the file count still looked
    # plausible. There is no reason to prefer the shallower answer.
    files = sorted(glob.glob(os.path.join(root, "**", "*.yaml"), recursive=True))
    # demo.yaml ships with the templates and carries example locators on purpose, so its
    # references point wherever the scaffolding pointed. verify-page-citation-usage.py in
    # this directory has excluded them since 2026-08-16; this gate did not, and blocked
    # two of eywa-deezy's builds on a fake reference nobody can fix without deleting the
    # scaffolding. Two gates disagreeing about whether the same file counts is worse than
    # either answer on its own.
    demo_n = sum(1 for f in files if os.path.basename(f) == "demo.yaml")
    files = [f for f in files if os.path.basename(f) != "demo.yaml"]
    langs = sorted({os.path.basename(os.path.dirname(f)) for f in files})
    for f in files:
        slug = os.path.basename(f)[:-5]
        m = REF_RE.search(open(f, encoding="utf-8").read())
        if not m:
            continue
        for label, url in PAIR_RE.findall(m.group(1)):
            by_url.setdefault(url.rstrip("/").lower(), []).append((slug, label))
            if (label, url) in seen:
                kind, ident, title, authors, year = seen[(label, url)]
            else:
                kind, ident, title, authors, year = resolve(url)
                seen[(label, url)] = (kind, ident, title, authors, year)
                time.sleep(0.15)
            if title is None:
                unresolved.append((slug, label, url))
            elif title and year_contradicts(label, year):
                # Checked BEFORE the title comparison, because the whole point is that a
                # high-scoring title is exactly how this class hides.
                wrong.append((slug, label, url,
                              "%s  [ปีจริง %s]" % (title, year),
                              round(agreement(label, title), 2)))
            elif title and agreement(label, title) < MATCH_FLOOR:
                # Two findings, not one. Both disagree with the resolved title and
                # both used to land in `wrong` and block the build, which is how 16
                # correctly-sourced deezy references sat in the same bucket as 4 that
                # pointed at the wrong paper. If the label names the first author and
                # the year, it identifies the work — the label is just not written as
                # a title, which DR-061 allows.
                ag = round(agreement(label, title), 2)
                if identifies_by_author_year(label, authors, year):
                    label_form.append((slug, label, url, title, ag))
                else:
                    wrong.append((slug, label, url, title, ag))
            if not skip_db and slug in backed and ("%s:%s" % (kind, ident)) not in backed[slug]:
                unbacked.append((slug, label, url))

    # Say the demo count out loud. vth-biodent ships 200 demo.yaml — 20 template
    # collections in each of 10 languages — against 170 real content files, so excluding
    # them more than halves the number and shrinks the language list from twelve
    # directories to four. Printed without explanation that reads exactly like content
    # having gone missing, which is how I misread my own output for several minutes.
    print("content locator audit — %d content files across %d dirs (%s)%s, %d distinct label+url pairs"
          % (len(files), len(langs), ", ".join(langs[:12]) or "-",
             " · ข้าม demo.yaml %d ไฟล์ (scaffolding ของเทมเพลต)" % demo_n if demo_n else "",
             len(seen)))
    if not files:
        # Zero files and zero findings look identical in a summary line. Say which one this is.
        print("🔴 R0_no_content — ไม่พบไฟล์ .yaml ใต้ %s" % root)
        print("   เกตที่ไม่มีอะไรให้ตรวจ ไม่ใช่เกตที่ผ่าน · ชี้ --root ให้ถูก หรือดูโครงโฟลเดอร์ของแบรนด์")
        return 1
    if not seen:
        # R0 covered zero files. Zero *pairs* with files present is the other way to
        # check nothing: PAIR_RE wants a quoted label: immediately followed by a quoted
        # url:, so a brand writing single quotes, a bare scalar, url-first, or any key
        # between the two yields no pairs at all — and printed "PASS every locator
        # resolves" over content it never parsed.
        print("🔴 R0_no_references — อ่าน %d ไฟล์แต่แยก label+url ไม่ได้สักคู่" % len(files))
        print("   ไม่ได้แปลว่าสะอาด แปลว่า parser ไม่รู้จักรูปแบบ references[] ของแบรนด์นี้")
        print("   ดูหนึ่งไฟล์ด้วยตา: ต้องเป็น label: \"...\" แล้วตามด้วย url: \"...\" (double quote)")
        return 1
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
    if label_form:
        print("WARN  label เขียนเป็นข้อสรุป ไม่ใช่ชื่อเรื่อง แต่ระบุเปเปอร์ถูก — %d" % len(label_form))
        print("        DR-061 อนุญาตทั้งสองแบบ · ที่ผ่านได้เพราะ label มีนามสกุลผู้เขียนคนแรก + ปี")
        print("        ถ้าอยากให้เกตเทียบชื่อเรื่องตรง ๆ ให้เปลี่ยน label เป็นชื่อเปเปอร์")
        for slug, label, url, title, ag in label_form[:10]:
            print("        %-26s %s" % (slug, label[:60]))
            print("          %s  (agreement %.2f)" % ((title or "")[:66], ag))
        if len(label_form) > 10:
            print("        ... อีก %d" % (len(label_form) - 10))
    if unresolved:
        print("WARN  could not reach the source after 3 tries — %d" % len(unresolved))
        print("        Unreachable is not the same as wrong. Re-run; if one keeps failing,")
        print("        open it by hand — a DOI that is permanently gone is a real problem.")
        for slug, label, url in unresolved:
            print("        %-28s %s" % (slug, url))
    disagree = sibling_disagreements(by_url)
    if disagree:
        print("WARN  label ให้เครดิตคนละคนกับพี่น้องที่ locator เดียวกัน — %d" % len(disagree))
        print("        ไม่ต้องเรียก API เลย · เสียงข้างมากคือหลักฐาน ไม่ใช่ข้อพิสูจน์ — ตรวจด้วยตา")
        for slug, label, url, mine, top, ntop, nmine in disagree[:10]:
            print("        %-26s อ้าง '%s' (%d หน้า) · อีก %d หน้าอ้าง '%s'"
                  % (slug, mine, nmine, ntop, top))
            print("          %s" % url)
        if len(disagree) > 10:
            print("        ... อีก %d" % (len(disagree) - 10))
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
