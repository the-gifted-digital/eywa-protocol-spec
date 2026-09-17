#!/usr/bin/env python3
"""Turn the six reviewer outputs (out-*.json) into one SQL file + one review markdown.

  python3 gen-backfill-sql.py  →  contraindication-backfill.sql · review.md

SQL contract (DR-069): seo_entity_procedures.contraindications = the reviewed list (≤ 8, strength
3 → 2 → 1), load_source appended with the PMIDs; rows inserted for entities that have none. Nothing is
deleted. A backup of the touched rows is taken first. Strength-3 items are listed for sign-off.
"""
import json, glob, os, sys, datetime

D = os.path.dirname(os.path.abspath(__file__))
import argparse
_a = argparse.ArgumentParser(); _a.add_argument('--brand', required=True); _a.add_argument('--date', required=True, help='YYYY-MM-DD'); _a.add_argument('--out-name', default=None)
_args = _a.parse_args()
BRAND = _args.brand
DATE = _args.date
SCOPE = json.load(open(os.path.join(D, 'round2-scope.json')))  # entity → {table: procedures|devices}
CAP = 8

outs = sorted(glob.glob(os.path.join(D, 'out-*.json')))
if not outs:
    sys.exit('no out-*.json files yet')

def sqlq(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"

def arr(items):
    return 'array[' + ', '.join(sqlq(i) for i in items) + ']::text[]'

entities = []
for f in outs:
    data = json.load(open(f, encoding='utf-8'))
    for e in data['entities']:
        items = sorted(e['items'], key=lambda x: -int(x.get('strength', 1)))
        if len(items) > CAP:
            print(f"WARN {e['entity_fp']}: {len(items)} items > cap {CAP} — truncating to {CAP} (reviewer should have capped)")
            items = items[:CAP]
        texts = [i['text_th'].strip() for i in items]
        if len(set(texts)) != len(texts):
            sys.exit(f"duplicate item text in {e['entity_fp']}")
        for t in texts:
            if '](entity:' in t: sys.exit(f"link markup in {e['entity_fp']}: {t}")
            if len(t) > 220: print(f"WARN {e['entity_fp']}: item > 220 chars: {t[:60]}…")
        pmids = sorted({ev for i in items for ev in i.get('evidence', []) if ev.startswith('PMID:')})
        others = sorted({ev for i in items for ev in i.get('evidence', []) if not ev.startswith('PMID:')})
        entities.append({**e, 'items': items, 'texts': texts, 'pmids': pmids, 'others': others, 'cluster': data['cluster']})

fps = [e['entity_fp'] for e in entities]
procs = [f for f in fps if SCOPE[f]['table'] == 'procedures']
devs = [f for f in fps if SCOPE[f]['table'] == 'devices']
sql = [f"""-- contraindication-review.sql — {BRAND} · DR-069 review round 2 ({DATE})
--
-- Re-verifies the {len(fps)} entities whose contraindication lists already existed in the shared tables
-- (2026-07/08 backfills, some loaded by deezy) and are rendered live since 2026-09-17. Every existing
-- item got a keep / reword / drop verdict; additions were verified on PubMed; cap {CAP}; strength 3 → 2 → 1;
-- patient Thai, no brand names or doses. Review copy: review-r2.md next to this file
-- (content-plan/contraindication-review-r2-2026-09-18.md in the repo).
--
-- HOW TO RUN: whole file, once, in the Supabase SQL editor. Then tell the operator's assistant to
-- `npm run gen:entity-clinical`, commit the bridge, and push.

begin;

create table _{BRAND.replace('-','_')}_contra_r2_bak_{DATE.replace('-', '')}_proc as
  select * from seo_entity_procedures where entity_fp in ({', '.join(sqlq(f) for f in procs)});
create table _{BRAND.replace('-','_')}_contra_r2_bak_{DATE.replace('-', '')}_dev as
  select * from seo_entity_devices where entity_fp in ({', '.join(sqlq(f) for f in devs) or "''"});
"""]

for e in entities:
    src = f"{BRAND}:contraindication-review {DATE} (DR-069 round 2, cluster {e['cluster']}; " + \
          ', '.join(e['pmids'] + e['others']) + f"; confidence {e.get('confidence','?')})"
    sql.append(f"\n-- {e['entity_fp']} · {len(e['texts'])} items · strength-3: {len(e.get('signoff_required', []))} · confidence {e.get('confidence','?')}")
    table = 'seo_entity_' + SCOPE[e['entity_fp']]['table']
    sql.append(f"""update {table}
set contraindications = {arr(e['texts'])},
    load_source = coalesce(load_source,'') || ' · ' || {sqlq(src)},
    updated_at = now()
where entity_fp = {sqlq(e['entity_fp'])};""")

sql.append("\ncommit;\n")
sql.append("-- VERIFY: expect one row per entity with n between 1 and 8")
sql.append("-- select entity_fp, array_length(contraindications,1) n from seo_entity_procedures where entity_fp in (" +
           ', '.join(sqlq(f) for f in procs) + ") union all select entity_fp, array_length(contraindications,1) from seo_entity_devices where entity_fp in (" +
           (', '.join(sqlq(f) for f in devs) or "''") + ") order by 1;")

open(os.path.join(D, 'contraindication-review.sql'), 'w', encoding='utf-8').write('\n'.join(sql))

# review markdown
md = [f"# Contraindication review round 2 — existing lists re-verified ({DATE})\n",
      f"{len(entities)} entities · {sum(len(e['texts']) for e in entities)} items · strength-3 needing sign-off: {sum(len(e.get('signoff_required', [])) for e in entities)}\n"]
for e in entities:
    md.append(f"\n## `{e['entity_fp']}` — {len(e['texts'])} items · confidence {e.get('confidence','?')} · cluster {e['cluster']}\n")
    if e.get('reviewer_note'): md.append(f"> {e['reviewer_note']}\n")
    md.append("| # | strength | ข้อความ | evidence | source |\n|---|---|---|---|---|\n")
    for i, it in enumerate(e['items'], 1):
        md.append(f"| {i} | {it.get('strength')} | {it['text_th']} | {', '.join(it.get('evidence', []))} | {it.get('source','')} |\n")
    if e.get('existing_verdicts'):
        md.append("\nรายการเดิมบนเว็บ: " + ' · '.join(f"«{v['text'][:50]}» → **{v['verdict']}**" + (f" ({v['why'][:80]})" if v['verdict']!='keep' else '') for v in e['existing_verdicts']) + "\n")
    if e.get('dropped'):
        md.append("\nตัดออก: " + ' · '.join(f"«{d['text'][:60]}» ({d['why']})" for d in e['dropped']) + "\n")
sign = [(e['entity_fp'], t) for e in entities for t in e.get('signoff_required', [])]
md.append("\n## รายการที่ต้องให้ทันตแพทย์เซ็น (strength 3)\n")
md += [f"- `{fp}`: {t}\n" for fp, t in sign] or ["- (none)\n"]
open(os.path.join(D, 'review-r2.md'), 'w', encoding='utf-8').write(''.join(md))
print(f"wrote contraindication-review.sql + review-r2.md · {len(entities)} entities · {sum(len(e['texts']) for e in entities)} items · sign-off {len(sign)}")
