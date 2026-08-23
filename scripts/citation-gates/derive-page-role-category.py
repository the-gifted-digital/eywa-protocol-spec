#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Derive page_role and page_category for the page master, and report what would change.

page_role is a pure function of the tree: a page is a hub when at least one non-Merged row
names it as parent_page_fp, otherwise a leaf. It is never hand-set — the tree already holds
the only correct answer, so an editable column would only add a way to be wrong.

page_category is the semantic half of the old page_type, resolved in two steps:

  1. page_type already holds a category on most rows (751/842 for deezy, 683/728 for
     smile-scape, measured 2026-08-24). Carry it straight over.
  2. Where page_type holds a structural role instead ('pillar', 'supporting', 'popup'), the
     category was erased. Recover it from what the brand's OWN other rows with the same
     content_format say. If every such sibling agrees on one category, take it. If they
     disagree, or there are no siblings, leave the row alone and print it.

There is deliberately NO global content_format -> category table. DR-057 (2026-08-24) ruled
that template codes belong to the brand: deezy uses T2b, T6a, T8g and T12i where smile-scape
uses T2 and T6, and both are correct because each brand designs its own templates. A shared
map would either force one brand's vocabulary onto another or silently skip the codes it does
not know. Asking the brand's own data what a code means keeps the rule brand-agnostic without
pretending the codes are.

Rows that stay unresolved are NOT guessed. A disagreement means nobody has ruled on what the
page is, and picking a winner in a script would bury the decision instead of surfacing it.

    python3 derive-page-role-category.py --brand vth-biodent           # report only (default)
    python3 derive-page-role-category.py --brand deezy-dental --apply  # write, after review
    python3 derive-page-role-category.py --all-brands                  # report every brand
"""
import argparse
import collections
import json
import os
import sys
import urllib.parse
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import eywa_supabase  # noqa: E402 — one place that knows the URL and how to find the key
SB = eywa_supabase.SB
TABLE = "seo_website_page_master"

# Values of page_type that ARE a semantic kind. Anything else in that column is a structural
# role left over from before the split, and carries no category.
CATEGORY_VALUES = {
    "home", "about", "contact",
    "condition_pillar", "procedure_pillar", "service_page", "technology_page",
    "knowledge_article", "evidence_case", "doctor_profile",
    "branch_landing", "local_landing", "local_programmatic", "local_service",
    "local_service_page",
}
# Legacy spellings folded into the controlled value.
ALIAS = {"local_service": "local_landing"}
# schema.org types that name the page kind on their own. Used only after page_category and
# page_type have both come up empty: a page whose schema says AboutPage is an about page no
# matter what its content_format is, and several brands leave content_format blank on exactly
# these — deezy's about page and its two translations carry no format at all.
SCHEMA_CATEGORY = {
    "AboutPage": "about",
    "ContactPage": "contact",
}


key = eywa_supabase.key  # the gates live in the protocol repo; the secret belongs to the brand


def fetch(select, flt, k):
    out, off = [], 0
    while True:
        url = f"{SB}{TABLE}?select={select}{flt}&limit=1000&offset={off}"
        req = urllib.request.Request(url, headers={"apikey": k, "Authorization": "Bearer " + k})
        batch = json.load(urllib.request.urlopen(req))
        out += batch
        if len(batch) < 1000:
            return out
        off += 1000


def patch_many(fps, body, k):
    """One PATCH per (category, role) group instead of one per row.

    Writing row by row meant ~1,250 sequential HTTPS round trips for a full three-brand
    backfill, which is slow enough that the run gets killed part-finished — it died at
    137 of smile-scape's 707 rows on 2026-08-24. Every row in a group gets identical
    values, so `page_fingerprint=in.(...)` sends the same work in a handful of calls.
    Chunked because the fingerprint list goes in the URL and servers cap its length."""
    written = 0
    for i in range(0, len(fps), 120):
        chunk = fps[i:i + 120]
        joined = ",".join(urllib.parse.quote(f, safe="") for f in chunk)
        data = json.dumps(body, ensure_ascii=False).encode()
        req = urllib.request.Request(
            f"{SB}{TABLE}?page_fingerprint=in.({joined})", data=data, method="PATCH",
            headers={"apikey": k, "Authorization": "Bearer " + k,
                     "Content-Type": "application/json", "Prefer": "return=minimal"})
        urllib.request.urlopen(req)
        written += len(chunk)
    return written


def norm(v):
    v = (v or "").strip()
    return ALIAS.get(v, v)


def run(brand, k, apply_writes):
    flt = f"&brand_id=eq.{urllib.parse.quote(brand)}"
    rows = fetch("page_fingerprint,slug,status,content_format,page_type,page_category,schema_markup_type,parent_page_fp", flt, k)
    live = [r for r in rows if r["status"] != "Merged"]
    alive = {r["page_fingerprint"] for r in live}

    # hub = named as parent by at least one non-Merged row
    kids = collections.Counter(
        r["parent_page_fp"] for r in rows
        if r["parent_page_fp"] and r["page_fingerprint"] in alive)

    # What does this brand's own data say each content_format means? A row votes with its
    # page_category when one is already stored, otherwise with page_type. Preferring the newer
    # column matters: on a brand whose backfill has landed, page_category carries rulings that
    # page_type never had, and ignoring it throws that work away.
    votes = collections.defaultdict(set)
    for r in live:
        cat = norm(r.get("page_category")) or norm(r["page_type"])
        if cat in CATEGORY_VALUES and r["content_format"]:
            votes[r["content_format"].strip()].add(cat)

    resolved, ambiguous, unknown = [], [], []
    # page_role and page_category are answers to two independent questions. role comes
    # from the tree — does this page have children — and is known for every live row the
    # moment `kids` is built. category comes from content_format and its siblings, and
    # sometimes cannot be settled. Tying the write of the first to the success of the
    # second left 87 live rows with page_role NULL, 30 of them genuine hubs (including
    # deezy-8.1, which has 99 children), and NULL reads downstream as "not derived yet"
    # rather than "wrong", so they queued forever instead of surfacing.
    roles = {}
    for r in live:
        fp = r["page_fingerprint"]
        cf = (r["content_format"] or "").strip()
        stored, pt = norm(r.get("page_category")), norm(r["page_type"])
        role = "hub" if kids.get(fp, 0) > 0 else "leaf"
        roles[fp] = role

        if stored in CATEGORY_VALUES:
            resolved.append((fp, r["slug"], stored, role, "page_category มีค่าอยู่แล้ว"))
            continue
        if pt in CATEGORY_VALUES:
            resolved.append((fp, r["slug"], pt, role, "page_type ระบุหมวดอยู่แล้ว"))
            continue
        by_schema = SCHEMA_CATEGORY.get((r.get("schema_markup_type") or "").strip())
        if by_schema:
            resolved.append((fp, r["slug"], by_schema, role, "schema_markup_type ระบุชนิดหน้าในตัว"))
            continue
        sibs = votes.get(cf, set())
        if len(sibs) == 1:
            resolved.append((fp, r["slug"], next(iter(sibs)), role,
                             f"กู้จากพี่น้อง {cf} ของแบรนด์นี้ (page_type เดิมเก็บ role '{pt or '—'}')"))
        elif len(sibs) > 1:
            ambiguous.append((fp, r["slug"], cf, pt, sorted(sibs)))
        else:
            unknown.append((fp, r["slug"], cf, pt))

    print(f"══ {brand} · {len(live)} แถวที่ไม่ใช่ Merged")
    print(f"   derive ได้ {len(resolved)} · กำกวม {len(ambiguous)} · ไม่รู้ {len(unknown)}\n")
    print("── page_role (คำนวณจากต้นไม้ · ทุกแถวที่ live ไม่ใช่เฉพาะแถวที่หมวดลงตัว)")
    for v, n in collections.Counter(roles.values()).most_common():
        print(f"   {v:<6} {n}")
    print("\n── page_category")
    for v, n in collections.Counter(x[2] for x in resolved).most_common():
        print(f"   {v:<22} {n}")
    print("\n── ที่มา")
    for v, n in collections.Counter(x[4] for x in resolved).most_common():
        print(f"   {n:>4}  {v}")

    if ambiguous:
        print(f"\n🔴 กำกวม {len(ambiguous)} แถว — พี่น้อง content_format เดียวกันบอกไม่ตรงกัน")
        print("   ไม่เขียนค่าให้ เพราะยังไม่มีใครตัดสินว่าหน้านี้คืออะไร")
        for fp, slug, cf, pt, opts in sorted(ambiguous)[:25]:
            print(f"   {fp:<18} {cf or '—':<6} role={pt or '—':<12} เลือกได้: {', '.join(opts)}  {slug[:26]}")
        if len(ambiguous) > 25:
            print(f"   … อีก {len(ambiguous) - 25} แถว")
    if unknown:
        print(f"\n⚠️ ไม่รู้หมวด {len(unknown)} แถว — content_format นี้ไม่มีแถวไหนของแบรนด์บอกหมวดเลย")
        for fp, slug, cf, pt in sorted(unknown)[:25]:
            print(f"   {fp:<18} format={cf or '—':<6} role={pt or '—':<12} {slug[:30]}")
        if len(unknown) > 25:
            print(f"   … อีก {len(unknown) - 25} แถว")

    if not apply_writes:
        print("\nreport only — ใส่ --apply เพื่อเขียนจริง")
        return len(ambiguous) + len(unknown)

    groups = collections.defaultdict(list)
    for fp, _slug, cat, role, _why in resolved:
        groups[(cat, role)].append(fp)
    written = 0
    for (cat, role), fps in sorted(groups.items()):
        written += patch_many(fps, {"page_category": cat, "page_role": role}, k)

    # Roles for the rows whose category did not resolve. Their role was never in doubt.
    settled = {fp for fp, _s, _c, _r, _w in resolved}
    role_only = collections.defaultdict(list)
    for fp, role in roles.items():
        if fp not in settled:
            role_only[role].append(fp)
    role_written = 0
    for role, fps in sorted(role_only.items()):
        role_written += patch_many(fps, {"page_role": role}, k)

    print(f"\nเขียนแล้ว {written} แถว (หมวด+role) ใน {len(groups)} กลุ่ม")
    print(f"เขียน role อย่างเดียวอีก {role_written} แถวที่หมวดยังไม่ลงตัว "
          f"— role มาจากต้นไม้ ไม่ได้ขึ้นกับหมวด")
    print(f"ยังค้างหมวด: กำกวม {len(ambiguous)} · ไม่รู้ {len(unknown)}")
    return len(ambiguous) + len(unknown)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--brand", help="brand_id เช่น vth-biodent · deezy-dental · smile-scape-clinic")
    ap.add_argument("--all-brands", action="store_true")
    ap.add_argument("--apply", action="store_true", help="write the derived values")
    a = ap.parse_args()
    if not a.brand and not a.all_brands:
        ap.error("ต้องระบุ --brand หรือ --all-brands")
    k = key()
    brands = ["deezy-dental", "smile-scape-clinic", "vth-biodent"] if a.all_brands else [a.brand]
    left = 0
    for i, b in enumerate(brands):
        if i:
            print("\n" + "─" * 78 + "\n")
        left += run(b, k, a.apply)
    return 0


if __name__ == "__main__":
    sys.exit(main())
