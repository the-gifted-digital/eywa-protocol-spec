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
import urllib.parse
import urllib.request

SB = "https://lffcbeszjqzioobqfdav.supabase.co/rest/v1/"


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


def fetch(table, select, flt="", k=None, page=1000):
    """Every row matching the filter. PostgREST caps a response, so page until short."""
    k = k or key()
    out, off = [], 0
    while True:
        url = "%s%s?select=%s%s&limit=%d&offset=%d" % (
            SB, urllib.parse.quote(table), select, flt, page, off)
        req = urllib.request.Request(
            url, headers={"apikey": k, "Authorization": "Bearer " + k})
        batch = json.load(urllib.request.urlopen(req))
        out += batch
        if len(batch) < page:
            return out
        off += page
