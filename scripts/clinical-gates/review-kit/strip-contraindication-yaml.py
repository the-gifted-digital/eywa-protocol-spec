#!/usr/bin/env python3
"""Remove the top-level `contraindication:` block from content YAML files, byte-preserving everything else.

usage: strip_contraindication.py [--apply] [--only <slugs.txt>] <content_root>
Dry run by default: prints what would change. With --apply, rewrites files. Validates that the parsed
document after the edit equals the parsed document before minus the `contraindication` key.
"""
import sys, os, re, glob, copy
import yaml

apply = "--apply" in sys.argv
only = None
if "--only" in sys.argv:
    only = set(l.strip() for l in open(sys.argv[sys.argv.index("--only") + 1], encoding="utf-8") if l.strip())
root = [a for a in sys.argv[1:] if not a.startswith("--") and (only is None or a != sys.argv[sys.argv.index("--only") + 1])][-1]

TOP_KEY = re.compile(r"^[A-Za-z_][A-Za-z0-9_-]*:")
changed = skipped = 0
for f in sorted(glob.glob(os.path.join(root, "*", "*", "*.yaml"))):
    slug = os.path.basename(f)[:-5]
    if only is not None and slug not in only: continue
    src = open(f, encoding="utf-8").read()
    lines = src.splitlines(keepends=True)
    start = next((i for i, l in enumerate(lines) if l.startswith("contraindication:")), None)
    if start is None: continue
    end = start + 1
    while end < len(lines):
        l = lines[end]
        if l.strip() == "" :
            # blank line: part of the block only if the next non-blank line is still indented / a list item
            nxt = next((m for m in lines[end+1:] if m.strip() != ""), None)
            if nxt is not None and (nxt.startswith(" ") or nxt.startswith("- ")): end += 1; continue
            break
        if l.startswith(" ") or l.startswith("- ") or l.startswith("-\n"): end += 1; continue
        break
    before = yaml.safe_load(src)
    new_src = "".join(lines[:start] + lines[end:])
    after = yaml.safe_load(new_src)
    exp = copy.deepcopy(before); exp.pop("contraindication", None)
    if after != exp:
        print(f"SKIP (parse mismatch) {f}"); skipped += 1; continue
    n = len(before.get("contraindication") or []) if isinstance(before.get("contraindication"), list) else "?"
    print(f"{'APPLY' if apply else 'DRY  '} {os.path.relpath(f, root)}  lines {start+1}-{end}  ({n} items)")
    if apply: open(f, "w", encoding="utf-8").write(new_src)
    changed += 1
print(f"{'changed' if apply else 'would change'} {changed} · skipped {skipped}")
