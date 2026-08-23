# -*- coding: utf-8 -*-
#!/usr/bin/env python3
"""Audit every row of seo_page_citations, across all brands. Reports only.

Written 2026-08-16 after the question "why does the citation situation look like
a mess" turned out to have a measurable answer. The gates in run-citation-qa-gates
check one brand and one dimension at a time; this walks the whole table so the
shape of the problem is visible in one screen.

The A-checks are structural — a key resolves, a status is in vocabulary, a
citation is not bound to a page that no longer exists. They are objective and a
failure is always a defect.

The B-checks are about trust, and they warn rather than fail. A binding can be
perfectly well-formed and still be a placeholder nobody has verified; half this
table is exactly that, self-labelled by the sweep that created it. B1 counts
them, B3 flags citations spread so widely that a cluster-level matcher must have
guessed, and B4 is informational.

Usage: python3 content-plan/etl/audit-page-citations.py
"""
import importlib.util, collections, re
spec = importlib.util.spec_from_file_location("fpf","content-plan/etl/find-page-forks.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m); k=m.key()

links=m.fetch("seo_page_citations","id,page_fp,citation_fp,status,supports_claim,citation_purpose,evidence_strength_score,inline_position,added_by_fp,created_at","&limit=40000",k)
cites={c["fingerprint"]:c for c in m.fetch("seo_citations","fingerprint,title,verification_status,is_retracted,citation_tier,brand_scope","",k)}
pages={p["page_fingerprint"]:p for p in m.fetch("seo_website_page_master","page_fingerprint,brand_id,status,cluster_id,slug","&limit=8000",k)}
# 2026-08-16: the first version of this pattern missed 199 rows — the second sweep round
# wrote "ผูกจากคลังผ่าน entity รองของหน้า", which shares no phrase with the first round.
# A detector that names one wording under-reports by however many wordings it has not seen.
# 2026-08-16: the first version of this pattern missed 199 rows — the second sweep round
# wrote "ผูกจากคลังผ่าน entity รองของหน้า", which shares no phrase with the first round.
# A detector that names one wording under-reports by however many wordings it has not seen.
# The second version then over-reported, because the note written to CLEAR a row also
# contains the word "sweep". A detector has to exclude its own remediation text, or it
# reports the cleanup as more of the problem.
SWEEP=re.compile(r"Backbone evidence assigned|ผูกจากคลัง|sweep|ยังไม่ได้แม็ป|to be refined during content writing")
CLEARED=re.compile(r"^\s*(ตรวจแล้ว|บันทึกย้อนหลัง|ปลด) \d{4}-\d{2}-\d{2}")
def is_sweep(s):
    s=str(s or "")
    return bool(SWEEP.search(s)) and not CLEARED.match(s)
act=[l for l in links if l["status"]=="active"]
print(f"=== seo_page_citations ทั้งตาราง ===")
print(f"  แถวทั้งหมด {len(links)} · active {len(act)} · removed {len(links)-len(act)}")
print(f"  citation ในพูล {len(cites)} · หน้าใน page_master {len(pages)}")

print("\n--- แยกตามแบรนด์ (เฉพาะ active) ---")
bb=collections.Counter(pages.get(l["page_fp"],{}).get("brand_id","(หน้าไม่มีในตาราง)") for l in act)
for b,n in bb.most_common(): print(f"  {str(b):28} {n:6}")

def chk(name, rows, note=""):
    print(f"  {'❌' if rows else '✅'} {name:44} {len(rows):6}  {note}")
    return rows

print("\n--- ความถูกต้องเชิงโครงสร้าง (ทั้งตาราง) ---")
bad_key=chk("A1 page_fp ไม่ใช่ page_fingerprint จริง", [l for l in act if l["page_fp"] not in pages])
ulid=[l for l in bad_key if re.match(r"^page_[0-9A-Za-z]{16}$", l["page_fp"] or "")]
print(f"      ในนั้นเป็นรูป ULID: {len(ulid)}")
chk("A2 citation_fp ไม่มีในพูล", [l for l in act if l["citation_fp"] not in cites])
chk("A3 status นอกวงคำ", [l for l in links if l["status"] not in ("active","removed")])
chk("A4 ผูกกับ citation ที่ยังไม่ verified", [l for l in act if cites.get(l["citation_fp"],{}).get("verification_status")!="verified"])
chk("A5 ผูกกับ citation ที่ถูกถอน", [l for l in act if cites.get(l["citation_fp"],{}).get("is_retracted")])
pair=collections.Counter((l["page_fp"],l["citation_fp"]) for l in act)
chk("A6 ผูกซ้ำคู่เดิม", [p for p,n in pair.items() if n>1])
chk("A7 ผูกกับหน้า Merged/Dropped", [l for l in act if pages.get(l["page_fp"],{}).get("status") in ("Merged","Dropped")])
chk("A8 citation_purpose ว่าง", [l for l in act if not l["citation_purpose"]])
chk("A9 evidence_strength นอกช่วง 1-5", [l for l in act if l["evidence_strength_score"] not in (None,1,2,3,4,5)])
chk("A10 inline_position ว่าง", [l for l in act if l["inline_position"] is None])
# ตำแหน่งซ้ำในหน้าเดียวกัน
pos=collections.defaultdict(list)
for l in act: pos[l["page_fp"]].append(l["inline_position"])
chk("A11 inline_position ซ้ำในหน้าเดียวกัน", [p for p,v in pos.items() if len([x for x in v if x is not None])!=len({x for x in v if x is not None})])
chk("A12 brand_scope ของ citation ไม่ครอบแบรนด์ของหน้า",
    [l for l in act if l["citation_fp"] in cites and pages.get(l["page_fp"]) and
     not ({"*"} & set(cites[l["citation_fp"]].get("brand_scope") or []) or
          {pages[l["page_fp"]]["brand_id"]} & set(cites[l["citation_fp"]].get("brand_scope") or []))])

print("\n--- ความน่าเชื่อถือของเนื้อหา ---")
sweep=[l for l in act if is_sweep(l["supports_claim"])]
print(f"  ⚠  B1 ยังเป็น backbone sweep ที่ไม่เคยแม็ป      {len(sweep):6}  ({100*len(sweep)//max(len(act),1)}% ของ active)")
bs=collections.Counter(pages.get(l["page_fp"],{}).get("brand_id","?") for l in sweep)
for b,n in bs.most_common(): print(f"        {str(b):26} {n:6}")
chk("B2 supports_claim ว่าง", [l for l in act if not str(l["supports_claim"] or "").strip()])
sp=collections.defaultdict(set)
for l in act:
    p=pages.get(l["page_fp"])
    if p: sp[(p["brand_id"],l["citation_fp"])].add(p["cluster_id"])
wide=[(b,c,len(cl)) for (b,c),cl in sp.items() if len(cl)>=5]
print(f"  ⚠  B3 citation ผูกข้าม >=5 คลัสเตอร์ (ต่อแบรนด์)  {len(wide):6}")
for b,n in collections.Counter(b for b,_,_ in wide).most_common(): print(f"        {str(b):26} {n:6}")
orph=[fp for fp in cites if not any(l["citation_fp"]==fp for l in act)]
print(f"  ℹ  B4 citation ในพูลที่ไม่ถูกผูกกับหน้าไหนเลย    {len(orph):6}")
