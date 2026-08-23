#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Check content_format against the brand's own template registry.

deezy-dental reported on 2026-08-24 that `content_format` had no gate of any kind — their
`check-content` returned zero findings every time while four of their pages were deliberately
written against a different template than the plan recorded. A column nothing validates is a
column that drifts, and DR-057 made that worse in one specific way: it ruled that template
codes belong to the brand, so there is no global list left to check a code against.

The registry is what replaces the global list. Each brand keeps
`content-plan/template-registry.json` naming every code it uses, which template directory that
code renders through, and which page_category values it may carry. This gate reads it.

Three findings, and the split matters as much as the checks:

  R1_unregistered_code    a content_format in the plan that the registry does not define.
                          Blocks. This is the "code with no definition" DR-057 named.
  R2_category_mismatch    a page whose page_category is not one the registry lets that code
                          carry. Blocks.
  R3w_template_mismatch   a written file sitting in a different template directory than the
                          registry says. WARNS, because deezy showed this is sometimes done on
                          purpose and recorded in the file header — a deliberate deviation is a
                          decision, not a defect, and a gate that blocks it teaches people to
                          stop recording deviations.

No registry file is itself a finding, not a pass: a brand with no registry is exactly the state
this gate exists to end.

    python3 check-template-registry.py --brand vth-biodent
    python3 check-template-registry.py --brand deezy-dental --content-root ../eywa-deezy/web/src/content
"""
import argparse
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import eywa_supabase  # noqa: E402


def find_registry(start=None):
    """Walk up from the working directory for the brand's registry."""
    override = os.environ.get("EYWA_TEMPLATE_REGISTRY")
    if override:
        return override
    d = os.path.abspath(start or os.getcwd())
    while True:
        cand = os.path.join(d, "content-plan", "template-registry.json")
        if os.path.isfile(cand):
            return cand
        parent = os.path.dirname(d)
        if parent == d:
            return None
        d = parent


def find_content(start=None):
    d = os.path.abspath(start or os.getcwd())
    while True:
        cand = os.path.join(d, "web", "src", "content")
        if os.path.isdir(cand):
            return cand
        parent = os.path.dirname(d)
        if parent == d:
            return None
        d = parent


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--brand", required=True)
    ap.add_argument("--registry")
    ap.add_argument("--content-root")
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args()

    reg_path = a.registry or find_registry()
    if not reg_path:
        print("🔴 R0_no_registry — ไม่พบ content-plan/template-registry.json")
        print("   แบรนด์ที่ไม่มีทะเบียนคือสภาพที่เกตนี้มีไว้เพื่อจบ ไม่ใช่สภาพที่ผ่าน")
        print("   ดูตัวอย่างที่ eywa-vth-biodent/content-plan/template-registry.json")
        return 1
    reg = json.load(open(reg_path, encoding="utf-8"))
    codes = reg.get("codes", {})
    if reg.get("brand_id") and reg["brand_id"] != a.brand:
        print("🔴 ทะเบียนที่เจอเป็นของ %s แต่สั่งตรวจ %s — %s"
              % (reg["brand_id"], a.brand, reg_path))
        return 1

    k = eywa_supabase.key()
    rows = [r for r in eywa_supabase.fetch(
        "seo_website_page_master", "page_fingerprint,slug,content_format,page_category,status",
        "&brand_id=eq." + a.brand, k) if r["status"] != "Merged"]

    findings = {}
    findings["R1_unregistered_code"] = sorted(
        {(r["content_format"], r["page_fingerprint"]) for r in rows
         if r["content_format"] and r["content_format"] not in codes})
    findings["R2_category_mismatch"] = sorted(
        (r["page_fingerprint"], r["content_format"], r["page_category"]) for r in rows
        if r["content_format"] in codes and r["page_category"]
        and r["page_category"] not in codes[r["content_format"]].get("category", []))

    content = a.content_root or find_content()
    mismatch = []
    if content:
        want = {c: v["template"] for c, v in codes.items()}
        by_slug = {r["slug"]: r for r in rows if r["content_format"]}
        for f in glob.glob(os.path.join(content, "*", "*", "*.yaml")):
            tpl = os.path.basename(os.path.dirname(os.path.dirname(f)))
            row = by_slug.get(os.path.basename(f)[:-5])
            if row and want.get(row["content_format"]) not in (None, tpl):
                mismatch.append((row["page_fingerprint"], row["content_format"],
                                 want[row["content_format"]], tpl))
    findings["R3w_template_mismatch"] = sorted(mismatch)

    print("template registry — %s · %d โค้ด · %d หน้าที่ไม่ใช่ Merged" % (a.brand, len(codes), len(rows)))
    print("registry: %s" % reg_path)
    if not content:
        print("⚠️  ไม่พบ web/src/content — ข้าม R3w (ตรวจได้เฉพาะชั้นแผน)")
    print("-" * 78)
    blocking = 0
    for gate, hits in findings.items():
        warn = gate.split("_", 1)[0].endswith("w")
        if not hits:
            print("  PASS  %-26s 0" % gate)
            continue
        if not warn:
            blocking += len(hits)
        print("  %s  %-26s %d" % ("WARN" if warn else "FAIL", gate, len(hits)))
        for h in (hits if a.verbose else hits[:6]):
            print("          " + " | ".join(str(x) for x in h))
        if not a.verbose and len(hits) > 6:
            print("          … อีก %d (--verbose เพื่อดูทั้งหมด)" % (len(hits) - 6))
    print("-" * 78)
    print("blocking rows: %d" % blocking)
    return 1 if blocking else 0


if __name__ == "__main__":
    sys.exit(main())
