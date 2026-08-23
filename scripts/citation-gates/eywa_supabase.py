#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Read-only PostgREST helpers shared by the gates in this directory.

These three things — the key, a paging fetch, and the base URL — used to live inside
`find-page-forks.py`, which is one brand's fork-detection tool and carries
`BRAND = "VTH BioDent"` near the top. Gates that all three brands run were importing from
it just to borrow the helpers, which quietly made a shared gate depend on a brand's file.
Splitting them out is what let this directory move out of eywa-vth-biodent at all.

Credential lookup, in order:
  1. SUPABASE_SERVICE_KEY in the environment — how CI should supply it
  2. EYWA_SECRETS_ENV pointing at a file holding SUPABASE_SERVICE_KEY=...
  3. .secrets/supabase.env walking up from the working directory

The key is never printed, never logged, and never written anywhere by these helpers.
"""
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

# The project origin, with no path. SB appends the PostgREST prefix, because callers
# split on that boundary two different ways and having both spelled out here is what stops a
# second copy of the host appearing in some other file.
SB_ORIGIN = "https://lffcbeszjqzioobqfdav.supabase.co"
SB = SB_ORIGIN + "/rest/v1/"


def _from_env_file(path):
    try:
        with open(path, encoding="utf-8") as fh:
            for line in fh:
                if line.startswith("SUPABASE_SERVICE_KEY="):
                    v = line.split("=", 1)[1].strip()
                    if v:
                        return v
    except OSError:
        pass
    return None


def key():
    k = os.environ.get("SUPABASE_SERVICE_KEY")
    if k:
        return k
    named = os.environ.get("EYWA_SECRETS_ENV")
    if named:
        k = _from_env_file(named)
        if k:
            return k
    # Walk up from the working directory looking for a brand's .secrets/supabase.env.
    # Relative to this file would be wrong: the gates live in the protocol repo now, and
    # the secret belongs to whichever brand is being checked, not to the protocol.
    d = os.path.abspath(os.getcwd())
    while True:
        k = _from_env_file(os.path.join(d, ".secrets", "supabase.env"))
        if k:
            return k
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    sys.exit(
        "no SUPABASE_SERVICE_KEY.\n"
        "  set it in the environment, or point EYWA_SECRETS_ENV at a file holding it,\n"
        "  or run from inside a brand repo that has .secrets/supabase.env"
    )


def fetch(table, select, flt="", k=None, page=1000, order="id"):
    """Every row matching the filter. PostgREST caps a response, so page until short.

    `order` is not decoration. LIMIT/OFFSET without ORDER BY has no stability
    guarantee in PostgreSQL — the planner may return page 2 in an order that skips
    rows page 1 walked past, or repeats them. This helper feeds every gate here, and
    the tables that matter are well past one page (seo_page_internal_links ~16.5k,
    seo_page_citations ~5k), so an unordered walk lets a gate audit a subset and then
    report on it as if it were the whole table: a row lost in the gap enters no
    counter and raises no finding. All four tables the gates read carry `id`; a table
    that does not must be handed its own stable key by the caller."""
    k = k or key()
    out, off = [], 0
    while True:
        url = "%s%s?select=%s%s%s&limit=%d&offset=%d" % (
            SB, urllib.parse.quote(table), select, flt,
            "&order=" + urllib.parse.quote(order) if order else "", page, off)
        req = urllib.request.Request(
            url, headers={"apikey": k, "Authorization": "Bearer " + k})
        try:
            batch = json.load(urllib.request.urlopen(req))
        except urllib.error.HTTPError as e:
            if e.code == 400 and order:
                sys.exit("%s cannot be ordered by %r — pass order= to fetch(), but do not "
                         "pass order=None unless the result fits in one page of %d"
                         % (table, order, page))
            raise
        out += batch
        if len(batch) < page:
            return out
        off += page
