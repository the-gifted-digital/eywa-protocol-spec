# Citation & page gates — canonical copies

These nine scripts are the gates the Citation Pool SOP and Bible Part 23.1 describe. They are
**brand-agnostic**: every one takes `--brand <brand_id>`, and none of them contains a brand's page
list, keyword list or exemption list. That was not always true — until 2026-08-24
`run-citation-qa-gates.py` carried two `vth-` fingerprints in a Python dict, inside a gate all three
brands run. Exemptions now live in the data, as `CITATION EXEMPTION` in a page's
`reconciliation_notes`, so a brand can declare its own without editing a file every brand shares.

## Why this directory exists

The same SOP existed in four places at three versions, and nobody noticed until an audit went
looking. The failure was never the copying — it was that a copy could drift for months in silence.
`MANIFEST.sha256` is here so it cannot.

## Running them

```bash
export SUPABASE_SERVICE_KEY=...          # or leave a .secrets/supabase.env beside the repo
python3 run-citation-qa-gates.py --brand deezy-dental
python3 derive-page-role-category.py --all-brands          # report; add --apply to write
python3 verify-page-citation-usage.py                      # Live pages; --all adds Planned
```

`citation-qa-gates.sql` at the repo root is the SQL twin of `run-citation-qa-gates.py`. The two are
kept in step deliberately and were verified to return identical answers for vth-biodent on
2026-08-24 (G6 0, G6w 452, G7 0, G7w 407). If you change one, change the other and re-check, or the
brand without the Python toolchain gets a different answer from the brand with it — which is exactly
what happened before that date.

## If your brand vendors a copy

Vendoring is fine. Silent divergence is not. After copying, run:

```bash
shasum -a 256 -c MANIFEST.sha256
```

A mismatch means your copy and the canonical one have parted ways. That is a decision to make on
purpose — either push your change up here so every brand gets it, or record why your brand needs to
differ. What must not happen is finding out later, from an audit, that a gate has been quietly
weaker on one brand for months.

Regenerate the manifest whenever you change a script here:

```bash
shasum -a 256 *.py > MANIFEST.sha256
```

## What each one does

| script | blocks on |
|---|---|
| `run-citation-qa-gates.py` | G1–G15: locators, verification, tier↔type, per-section minimums, freshness, duplicates |
| `verify-page-citation-usage.py` | a citation bound to a page the page never actually cites |
| `audit-content-locators.py` | a reference whose DOI resolves to a different paper than its label names |
| `audit-anchor-text.py` | anchor-text quality on internal links |
| `audit-page-citations.py` | binding-level integrity |
| `verify-citation-locators.py` | pool-level locator round-trip against PubMed and Crossref |
| `reconcile-citation-tiers.py` | tier drift against `citation_type` |
| `compute-citation-authority.py` | writes `citation_authority_weight` from tier, recency and OpenAlex FWCI — never hand-enter that column |
| `derive-page-role-category.py` | writes `page_category` and `page_role`; prints, never guesses, the rows it cannot resolve |

## The rule these encode

A gate that returns zero because it checked and found nothing, and a gate that returns zero because
it could not check, must not look the same. Several findings here exist only to keep those apart —
`G1w` for locatorless rows nobody relies on, `G6u` for a page whose section cannot be resolved,
`G14u` for a `study_type` spelling no map recognises. Before `G14u` existed, 174 of 551 pool rows
looked cross-checked because the field was filled while nothing compared them.
