#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Find pages competing for the same search query, and propose which should yield.

WHY THIS EXISTS
eywa-deezy reported on 2026-08-24 that the existing keyword check returns zero on
collisions that are obvious to a reader and, more to the point, obvious to Google:

    รากเทียม ยี่ห้อ        vs  รากเทียม ยี่ห้อไหนดี
    จัดฟันเจ็บไหม          vs  ดัดฟันเจ็บไหม

Neither pair is an exact string match, so an exact-match gate is silent. Thai makes
this worse than English would: there are no word boundaries, so a space is a typing
habit rather than a token separator, and จัด/ดัด is a routine spelling variant. Two
of deezy's three cases were worse still — the *keywords* did not collide at all, the
*titles* did, because one page's seo_title contained a sibling's whole target keyword.

WHAT THIS GATE MAY AND MAY NOT DO
It proposes. It never writes. `target_keyword_fp` is under a standing rule that it is
not touched without the operator, and that rule is right: swapping which page owns a
query re-points internal links, changes what each page is optimised for, and is not
recoverable by re-running anything. Every finding here prints both candidates, both
volumes and a recommendation; the operator decides.

THE SEMANTIC LAYER
The operator asked for a second pass "เชิงความหมาย" on top of the string match. A
gate cannot judge meaning, so it does not pretend to — it reads the two columns the
keyword table already holds for exactly this question:

    search_intent      informational / commercial / transactional / navigational
    primary_entity_fp  the entity the keyword is about

Same intent AND same entity  -> the same query in two spellings. Swap by volume.
Anything else                -> genuinely different demand. Report, do not propose.
Either column empty          -> ESCALATE. Not "no collision" — unknown, and the
                                operator was explicit: ถ้าสงสัยให้ตรงมาให้ฉัน verify.

FINDINGS
  K1_duplicate_target_fp    two pages in one brand carry the identical
                            target_keyword_fp. Blocks — this is not a judgement call.
  K2_normalized_identical   two keyword rows whose text is the same once spacing and
                            punctuation are removed, both used as targets. Blocks.
  K3w_one_contains_other    one normalized keyword contains the other whole. Warns.
  K4w_near_identical        edit distance <= 2 over >= 6 characters. Warns; this is
                            the จัด/ดัด class.
  K5w_title_holds_sibling   a page's seo_title contains another page's whole target
                            keyword, and that other page is Live. Warns.
  K6_escalate               a collision whose intent or entity data is missing, so the
                            semantic layer could not run. Listed separately and never
                            folded into the others — a comparison that could not be
                            made must not read as a comparison that found nothing.

Usage:
    python3 check-keyword-collisions.py --brand vth-biodent
    python3 check-keyword-collisions.py --brand deezy-dental --verbose
"""
import argparse
import collections
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import eywa_supabase  # noqa: E402

KW_TABLE = "seo_x_ads_keywords_contextual_master"
SNAP_TABLE = "seo_x_ads_keywords_monthly_market_snapshot"

# The keyword tables key brands by display name while page_master keys them by slug.
# Resolved from page_master itself rather than hardcoded, so a new brand needs no edit.
NEAR_MIN_LEN = 6
NEAR_MAX_DIST = 2

# Containment alone is not collision. A long-tail keyword contains its head term by
# construction — "AI ติดตามจัดฟัน" holds "จัดฟัน" — and that is correct architecture,
# not two pages fighting. What deezy reported looks different: รากเทียมยี่ห้อ inside
# รากเทียมยี่ห้อไหนดี is 14 characters inside 19, the same question with a suffix. The
# ratio is what separates the two, so containment only counts when the shorter keyword
# is most of the longer one. Below this it is a head term and its own long tail.
CONTAIN_MIN_RATIO = 0.6


def norm(s):
    """Strip everything that is a typing choice rather than a word.

    Thai has no spaces between words, so a space inside a Thai keyword carries no
    grammatical information and two writers will not agree on where to put one.
    Punctuation and case are the same kind of noise. Nothing else is touched: folding
    vowel marks or tone marks would merge keywords that really are different words.
    """
    return re.sub(r"[\s​]+|[?!.,\"'()\[\]/\\-]", "", (s or "")).lower()


def edit_distance(a, b, cap=3):
    """Levenshtein, abandoned once it passes `cap` — we only care about near-misses."""
    if abs(len(a) - len(b)) > cap:
        return cap + 1
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ca != cb)))
        if min(cur) > cap:
            return cap + 1
        prev = cur
    return prev[-1]


# The four values search_intent is documented to hold. Everything else in that column —
# "Ambiguous", "Mixed Intent" — is the labeller saying it could not decide, which is an
# absence of an answer and not an answer two rows can agree on.
INTENT_VOCAB = {"informational", "commercial", "transactional", "navigational"}


def semantic_verdict(ka, kb):
    """same | different | unknown — from stored columns, never from a guess.

    Compared case-INSENSITIVELY, reported by smile-scape-clinic on 2026-08-26. The
    docstring at the top of this file writes the vocabulary in lower case; the data is
    written both ways, and which way depends on the brand: vth-biodent and deezy-dental
    store 2,129 and 3,625 rows all capitalised, while smile-scape stores 215 capitalised
    against 373 lower — "Informational" 70 vs "informational" 227 inside one brand.
    A case-sensitive `==` therefore called that brand's own rows "different", meaning
    "genuinely different demand, do not propose", which is the opposite of true. The two
    brands whose data happens to be internally consistent never saw it.

    Normalising 18,140 rows across eight brands to work around a one-line comparison
    would be the wrong way round, and smile-scape said so rather than doing it.

    A value outside INTENT_VOCAB returns "unknown", not "same". Two rows both labelled
    "Ambiguous" agree on nothing except that nobody could tell — 25 such rows on
    vth-biodent, 51 on deezy — and "same" would send them to an automatic proposal on
    the strength of a shrug.
    """
    ia = (ka.get("search_intent") or "").strip().casefold()
    ib = (kb.get("search_intent") or "").strip().casefold()
    ea = (ka.get("primary_entity_fp") or "").strip().casefold()
    eb = (kb.get("primary_entity_fp") or "").strip().casefold()
    if not ia or not ib or not ea or not eb:
        return "unknown"
    if ia not in INTENT_VOCAB or ib not in INTENT_VOCAB:
        return "unknown"
    return "same" if (ia == ib and ea == eb) else "different"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--brand", required=True, help="brand_id, e.g. vth-biodent")
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args()

    k = eywa_supabase.key()
    pages = [p for p in eywa_supabase.fetch(
        "seo_website_page_master",
        "page_fingerprint,slug,status,seo_title,target_keyword_fp,brand_id,brand_name",
        "&limit=6000", k) if p.get("brand_id") == a.brand and p.get("status") != "Merged"]
    if not pages:
        seen = sorted({str(p.get("brand_id")) for p in eywa_supabase.fetch(
            "seo_website_page_master", "brand_id", "&limit=6000", k)} - {"None"})
        sys.exit("🔴 --brand %r ไม่ตรงกับหน้าไหนเลย · brand_id ที่มี: %s"
                 % (a.brand, ", ".join(seen)))

    # These two tables are keyed by fingerprint, not id — fetch() would otherwise page
    # them in whatever order the planner felt like and quietly drop rows past the first
    # page. It refuses rather than guessing, which is why this is spelled out.
    kws = {r["fingerprint"]: r for r in eywa_supabase.fetch(
        KW_TABLE, "fingerprint,keyword,keyword_use_as,search_intent,primary_entity_fp,"
        "target_language,brand", "&limit=20000", k, order="fingerprint")}

    # Latest snapshot per keyword. Rows accumulate monthly, so take the newest date.
    vol = {}
    for r in eywa_supabase.fetch(
            SNAP_TABLE, "fingerprint,snapshot_date,volume_recent_12m", "&limit=40000", k):
        fp, d = r["fingerprint"], r.get("snapshot_date") or ""
        if fp not in vol or d > vol[fp][0]:
            vol[fp] = (d, r.get("volume_recent_12m"))
    volume = {fp: v for fp, (_d, v) in vol.items()}

    def vfmt(fp):
        v = volume.get(fp)
        return "vol —" if v is None else "vol %s" % v

    targets = [p for p in pages if p.get("target_keyword_fp")]
    print("keyword collisions — %s · %d หน้า (%d มี target keyword) · keyword pool %d"
          % (a.brand, len(pages), len(targets), len(kws)))
    missing = sum(1 for p in targets if p["target_keyword_fp"] not in kws)
    if missing:
        print("⚠️  %d หน้าชี้ไป target_keyword_fp ที่ไม่มีในตารางคีย์เวิร์ด — เทียบไม่ได้" % missing)
    print("-" * 78)

    findings = collections.OrderedDict(
        (n, []) for n in ("K1_duplicate_target_fp", "K2_normalized_identical",
                          "K3w_one_contains_other", "K4w_near_identical",
                          "K5w_title_holds_sibling", "K6_escalate"))

    cleared = []
    by_fp = collections.defaultdict(list)
    for p in targets:
        by_fp[p["target_keyword_fp"]].append(p)
    for fp, ps in sorted(by_fp.items()):
        if len(ps) > 1:
            findings["K1_duplicate_target_fp"].append(
                (fp, (kws.get(fp) or {}).get("keyword", "?"),
                 " · ".join("%s %s" % (x["page_fingerprint"], x["status"]) for x in ps)))

    # Pairwise over distinct target keywords only. One brand holds tens of pages, not
    # thousands, so the quadratic pass is cheap and needs no blocking/bucketing that
    # could itself drop a pair.
    uniq = []
    for fp in sorted(by_fp):
        row = kws.get(fp)
        if row and (row.get("keyword") or "").strip():
            uniq.append((fp, row, norm(row["keyword"]), by_fp[fp][0]))

    def propose(fa, fb):
        """Which keyword should stay the target. Volume decides, per the operator."""
        va, vb = volume.get(fa), volume.get(fb)
        if va is None or vb is None:
            return "ไม่มี volume ทั้งสองฝั่ง — ตัดสินไม่ได้ ส่งให้ operator"
        if va == vb:
            return "volume เท่ากัน — ตัดสินไม่ได้ ส่งให้ operator"
        hi, lo = (fa, fb) if va > vb else (fb, fa)
        return ("เสนอ: '%s' เป็น target (%s) · '%s' ลงเป็น semantic (%s)"
                % (kws[hi]["keyword"], vfmt(hi), kws[lo]["keyword"], vfmt(lo)))

    for i in range(len(uniq)):
        fa, ra, na, pa = uniq[i]
        for j in range(i + 1, len(uniq)):
            fb, rb, nb, pb = uniq[j]
            if not na or not nb:
                continue
            kind = None
            if na == nb:
                kind = "K2_normalized_identical"
            elif (na in nb or nb in na) and \
                    min(len(na), len(nb)) / max(len(na), len(nb)) >= CONTAIN_MIN_RATIO:
                kind = "K3w_one_contains_other"
            elif (min(len(na), len(nb)) >= NEAR_MIN_LEN
                  and edit_distance(na, nb, NEAR_MAX_DIST) <= NEAR_MAX_DIST):
                kind = "K4w_near_identical"
            if not kind:
                continue
            # Two keywords that differ only in their digits are a series, not a
            # collision: ฟอกฟันขาวลำลูกกาคลอง 2 and ...คลอง 4 are one page per canal,
            # and จัดฟันเด็ก 7 ขวบ / 9 ขวบ is one page per age. Edit distance cannot
            # tell a spelling variant from an enumeration; the digits can. Same entity
            # and same intent by construction, so the semantic layer would clear neither.
            if (re.sub(r"\d+", "", na) == re.sub(r"\d+", "", nb)
                    and re.search(r"\d", na) and re.search(r"\d", nb)):
                cleared.append("%s | %s (ต่างกันแค่ตัวเลข — เป็นชุด ไม่ใช่ชน)"
                               % (ra["keyword"], rb["keyword"]))
                continue
            verdict = semantic_verdict(ra, rb)
            if verdict == "different":
                # The semantic layer did its job: same-looking strings, different intent
                # and different entity, so the two pages are not after the same demand.
                # Counted, not filed — a finding list padded with things the gate itself
                # already cleared is how a real collision gets scrolled past.
                cleared.append("%s | %s" % (ra["keyword"], rb["keyword"]))
                continue
            row = ("%s | %s" % (ra["keyword"], rb["keyword"]),
                   "%s %s / %s %s" % (pa["page_fingerprint"], pa["status"],
                                      pb["page_fingerprint"], pb["status"]),
                   propose(fa, fb) if verdict == "same"
                   else "intent หรือ entity ว่าง — เทียบเชิงความหมายไม่ได้")
            findings["K6_escalate" if verdict == "unknown" else kind].append(row)

    # The title layer. Two of deezy's three cases live only here.
    live_targets = [(fp, kws[fp], n, p) for fp, kws_row, n, p in
                    [(f, r, n, p) for f, r, n, p in uniq]
                    for kws_row in [kws[fp]] if p["status"] == "Live"]
    for p in pages:
        t = norm(p.get("seo_title"))
        if not t:
            continue
        for fp, row, n, owner in live_targets:
            if owner["page_fingerprint"] == p["page_fingerprint"]:
                continue
            if p.get("target_keyword_fp") == fp or not n or len(n) < NEAR_MIN_LEN:
                continue
            pos = t.find(n)
            if pos < 0:
                continue
            # Where it sits decides whether this is competition or a mention. A title
            # that OPENS with another page's target keyword is bidding for that query;
            # the same keyword halfway through a title about something else is the
            # sentence needing the word — "จมูกตันเรื้อรัง ทำไมนำไปสู่การหายใจทางปาก"
            # is a page about blocked noses that has to say "mouth breathing" once.
            # Length is the other half: if the sibling's keyword IS most of the title,
            # position stops mattering.
            opens = pos <= max(2, len(t) // 10)
            dominates = len(n) / len(t) >= 0.5
            if not (opens or dominates):
                cleared.append("%s ⊂ title ของ %s (อยู่กลางเรื่อง)"
                               % (row["keyword"], p["page_fingerprint"]))
                continue
            findings["K5w_title_holds_sibling"].append(
                (row["keyword"],
                 "%s %s · seo_title %s คีย์ของ %s (Live)"
                 % (p["page_fingerprint"], p["status"],
                    "ขึ้นต้นด้วย" if opens else "เป็น", owner["page_fingerprint"]),
                 str(p.get("seo_title"))[:70]))

    blocking = 0
    for name, hits in findings.items():
        warn = name.split("_", 1)[0].endswith("w") or name == "K6_escalate"
        if not hits:
            print("  PASS  %-26s 0" % name)
            continue
        if not warn:
            blocking += len(hits)
        print("  %s  %-26s %d" % ("WARN" if warn else "FAIL", name, len(hits)))
        for h in (hits if a.verbose else hits[:8]):
            print("          " + h[0])
            for extra in h[1:]:
                print("            %s" % extra)
        if not a.verbose and len(hits) > 8:
            print("          … อีก %d (--verbose)" % (len(hits) - 8))

    print("-" * 78)
    # Two different unknowns both end up in front of the operator: K6 is "the semantic
    # layer had no data to run on", and a row whose proposal says so is "the semantic
    # layer ran, the collision is real, but volume cannot pick a winner". Counting only
    # K6 printed "ส่งให้ operator: 0" on a run where 18 of 20 rows asked for exactly
    # that — a summary line that contradicts the list above it teaches people to skip
    # the summary.
    undecided = sum(1 for hits in findings.values() for h in hits
                    if any("ส่งให้ operator" in str(x) for x in h))
    print("blocking: %d · ต้องให้ operator ตัดสิน: %d · ชั้นความหมาย/ตำแหน่งเคลียร์ให้ %d คู่"
          % (blocking, undecided, len(cleared)))
    print("เกตนี้เสนออย่างเดียว ไม่เขียน target_keyword_fp — การสลับเจ้าของคีย์เป็นการตัดสินใจ")
    return 1 if blocking else 0


if __name__ == "__main__":
    sys.exit(main())
