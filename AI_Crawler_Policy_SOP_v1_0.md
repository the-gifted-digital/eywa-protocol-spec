# AI Crawler Policy SOP v1.0 — allow the answer engines, refuse the training corpora

**Status:** v1.0, 2026-09-21 · authored by vth-biodent from Deezy's DZ-DR-066 (2026-09-04) + DR-074 · **reviewed by the deezy Tsaheylu session 2026-09-21 (six corrections taken, all from probing Deezy's live edge)** · applies to every brand on the EYWA stack
**Related:** DR-074 (`seo_ai_agent_visits`) · DR-073 (`ai_referral`) · DZ-DR-066 (Deezy's original decision) · Bible Part 13 §3.11.4 · Pillar 2

> **The rule in one line:** a crawler that reads a page to *answer a person and cite us* is the
> audience this content was written for — let it in. A crawler that collects pages into a
> *training corpus* cites nobody and sends nobody — refuse it. They wear the same kind of header;
> tell them apart by token, never by "is it AI".

## 1. The three groups (the same list `web/worker/ai-agent.ts` classifies)

| group | tokens | policy | what it gives us |
|---|---|---|---|
| **retrieval** | `ChatGPT-User` · `Perplexity-User` · `Claude-User` · `meta-externalfetcher` · `MistralAI-User` · `DuckAssistBot` · `Google-CloudVertexBot` | **ALLOW** | the citation event itself (DR-074) + the click that follows |
| **index** | `OAI-SearchBot` · `PerplexityBot` · `Claude-SearchBot` · `Applebot` | **ALLOW** | the assistant's search index — the path to retrieval |
| **training** | `GPTBot` · `ClaudeBot` · `CCBot` · `Bytespider` · `TikTokSpider` · `meta-externalagent` · `cohere-ai` · `Applebot-Extended`* | **REFUSE** | nothing measurable; our curated clinical content becomes everyone's answer, uncredited |
| **refused although classified `index`** | `Amazonbot` (`amazon/index` in the log — Alexa's index, no citation payoff) | **REFUSE** | policy refuses an index bot when nothing comes back; the log keeps calling it what it is |

\* `Applebot-Extended` and `Google-Extended` are **not crawlers**: no request ever carries them as a user-agent. They are robots.txt tokens governing what an already-crawled page (fetched as `Applebot` / `Googlebot`) may be used for. The classifier's `Applebot-Extended` rule is therefore dead code kept for completeness; enforcement of both is **robots.txt only** (§3).

Two deliberate exceptions, stated so nobody re-argues them:

- **`ClaudeBot` is training, not "Claude's crawler".** Anthropic separates them: `Claude-User` and
  `Claude-SearchBot` do retrieval/search and stay allowed; `ClaudeBot` builds the corpus and is
  refused. (Deezy's DZ-DR-066 first allowed it under the wrong label; amended 2026-09-21.)
- **`Google-Extended` is ALLOWED although it permits training.** Google bundles Gemini *training*
  and Gemini *grounding* under one token; refusing it removes the site from Gemini's answers
  (the `gemini.google.com` referrals we classify as `ai_referral`) and buys nothing. Google
  Search, AI Overviews and AI Mode are `Googlebot`, unaffected either way. This is a trade-off
  accepted with eyes open, not an oversight.

A token not in the table is not "AI" for policy purposes. Add it to `tsa_param.agent_platform`
and to `ai-agent.ts` first (vth-biodent, hash to the other brands — DR-074), then decide its group.

## 2. Declaration: `web/public/robots.txt`

Copy the block verbatim; only the `Sitemap:` line is brand-specific. Reference copies:
`eywa-vth-biodent/web/public/robots.txt` · `eywa-deezy/web/public/robots.txt`.

```
User-agent: *
Content-Signal: search=yes, ai-input=yes, ai-train=no
Allow: /

User-agent: OAI-SearchBot
Allow: /
User-agent: ChatGPT-User
Allow: /
User-agent: Claude-User
Allow: /
User-agent: Claude-SearchBot
Allow: /
User-agent: PerplexityBot
Allow: /
User-agent: Perplexity-User
Allow: /
User-agent: Google-Extended
Allow: /

User-agent: GPTBot
Disallow: /
User-agent: ClaudeBot
Disallow: /
User-agent: CCBot
Disallow: /
User-agent: Bytespider
Disallow: /
User-agent: TikTokSpider
Disallow: /
User-agent: Applebot-Extended
Disallow: /
User-agent: meta-externalagent
Disallow: /
User-agent: Amazonbot
Disallow: /

Sitemap: https://<brand-domain>/sitemap-index.xml
```

The file must be served **byte-for-byte** — Cloudflare's *Managed robots.txt* (AI Crawl Control →
Signals) must be OFF, or Cloudflare prepends its own block above ours and the served policy is
no longer the one in git. Check: `curl -s https://<domain>/robots.txt | head -3` shows our first
comment line.

## 3. Enforcement: Cloudflare AI Crawl Control, per-crawler Block

robots.txt is a request. `Bytespider` ignores it; a spoofer ignores it. The control that stands is
**AI Crawl Control → Security → per-crawler Block toggles = ON** for every refused token the
dashboard lists: `GPTBot`, `ClaudeBot`, `CCBot`, `Bytespider`, `TikTok Spider`, `Meta-ExternalAgent`,
`Amazonbot`, `ProRataInc`. Everything in the allowed groups stays *Allow*. (VTH's dashboard on
2026-09-21 listed 34 crawlers; `TikTok Spider` is ByteDance's second token and sits apart from
`Bytespider` — block both.)

**Robots-only tokens — no toggle exists, and there is nothing to toggle:** `Applebot-Extended` and
`Google-Extended` never arrive as a user-agent (see §1), so they are enforced by the robots.txt
line alone — which is the reason *Managed robots.txt must be OFF*: if Cloudflare prepends its own
file, the `-Extended` policy served is Cloudflare's, not ours. `cohere-ai` is robots-only too
unless the zone's AI Crawl Control lists it; check the list, and if absent, count it among the
"not airtight" cases below.

- **Never the global "Block AI bots" toggle** — it blocks the retrieval agents too. Deezy found
  Cloudflare answering `GPTBot`, `ClaudeBot` **and `PerplexityBot`** with 403 on 2026-09-04: the
  site was paying to be citable and closing the door (DZ-DR-066).
- Per-crawler toggles are UA-matched at the edge — for every token we probed, a curl wearing the
  token got the same 403 as the real crawler, which is what makes them probe-able (§5).
- **The match is case-sensitive** (VTH edge, 2026-09-21): `GPTBot` → 403 but `gptbot` and
  `GPTBOT` → 200; `Bytespider` → 403 but `bytespider` → 200; `meta-externalagent` → 403 but
  `Meta-ExternalAgent` → 200. Real crawlers send their documented casing, so the real bots are
  blocked; a spoofer that varies case walks through. This is the cause of the Deezy
  `Meta-ExternalAgent/1.0` exception below — it was a scanner in the wrong case, not the crawler.
- **`/robots.txt` is exempt from the block** (crawlers must be able to read the policy):
  `Bytespider` and `GPTBot` get 200 there and 403 on every other path. Do not read a 200 on
  robots.txt as "not blocked".
- Fallback for a zone without AI Crawl Control: one WAF custom rule, **case-insensitive** on
  purpose (the toggles are not):
  `(lower(http.user_agent) contains "bytespider") or (lower(http.user_agent) contains "tiktokspider") or (lower(http.user_agent) contains "ccbot") or (lower(http.user_agent) contains "gptbot") or (lower(http.user_agent) contains "claudebot") or (lower(http.user_agent) contains "meta-externalagent") or (lower(http.user_agent) contains "amazonbot")` → Block.
  Prefer the toggles: nothing to keep in sync, visible in the dashboard, proven on both brands.
  A zone that wants the case-insensitive net *as well as* the toggles can run both; they do not
  conflict.
- **The one observed exception, now explained.** Deezy 2026-09-20: seven requests wearing
  `Meta-ExternalAgent/1.0` (capital M, capital E) from a GCP host reached the Worker while the
  toggle was ON — the case-sensitive match above; Meta's real crawler sends
  `meta-externalagent`, which is blocked. The edge is the first line; the log's `as_org` and the
  burst predicate are the second (§4).

## 4. Reading the log: `seo_ai_agent_visits` (DR-074)

- **Only `retrieval` belongs on a dashboard.** `index` and `training` volume is context: it rises
  when a crawler is busy, not when content is good. With the toggles ON, `training` rows
  (excluding `scanner_burst`) should be **~0**; non-zero means a token without a toggle (§3:
  `ClaudeBot` before its amendment, robots-only tokens) or a costume (`as_org`). Zero is the policy
  working, not a broken Worker.
- **A retrieval fetch means *read for an answer*, not *cited*.** `seo_llm_citations` owns the
  word "cited". Report the log as "read by assistants".
- **`as_org` is the heuristic for who is fetching — not proof on a single row.** Real
  `ChatGPT-User` rows come from Microsoft's network (OpenAI runs on Azure), real `ClaudeBot` from
  `Anthropic, PBC`, real `Bytespider` from ByteDance's AWS Singapore; but both labs also route some
  traffic through GCP/AWS. A lone `Google LLC` under an assistant token means *inspect*; the
  burst predicate below is what proves a costume.
- **The log sees what the edge lets through by case.** The classifier matches tokens
  case-insensitively (`/i`), the edge does not (§3). So a `training` row whose `agent_token` is
  in a non-documented case (`gptbot`, `GPTBOT`, `Meta-ExternalAgent`) with a non-vendor `as_org`
  is a recognisable shape: an edge bypass by case, i.e. a spoofer. The real crawler never looks
  like that. Count it as a costume, not as the vendor.
- **Scanners wear the allowlist.** 2026-09-20, Deezy: one GCP host, 133 requests in 2 s, twelve
  different agent tokens, every path a `/.env`-class probe, every response 404. The Worker keeps
  logging every status (a retrieval agent → 404 is a dead citation, which is signal); the
  subtraction happens in the view: `v_ai_agent_visits_page.scanner_burst` = same brand, same
  `as_org`, ≥ 3 distinct tokens within ±60 s. **Exclude `scanner_burst` from every count.** Both
  brands read the same predicate (migration `48_ai_agent_visits_scanner_flag.sql`).

## 5. Verification (the whole check, five minutes, no side effects)

**Probe `/favicon.svg` — never an HTML page, and never `/robots.txt`.** An HTML page is logged by
the Worker as a real visit (GET + `text/html`) and has to be deleted by the operator afterwards;
`/robots.txt` is *exempt* from Cloudflare's per-crawler block, so every token gets 200 there and
the probe proves nothing (found on Deezy's edge, 2026-09-21). `image/svg+xml` is blocked like any
other path and is never logged. The two `-Extended` tokens are not in the loops: they are not
user-agents (§1) and always return 200.

```sh
D=https://<domain>
for ua in OAI-SearchBot ChatGPT-User Claude-User Claude-SearchBot PerplexityBot Perplexity-User Applebot; do
  printf '%-20s %s  (expect 200)\n' "$ua" "$(curl -s -o /dev/null -w '%{http_code}' -A "Mozilla/5.0 (compatible; $ua/1.0)" "$D/favicon.svg")"
done
for ua in GPTBot ClaudeBot CCBot Bytespider TikTokSpider meta-externalagent Amazonbot; do
  printf '%-20s %s  (expect 403)\n' "$ua" "$(curl -s -o /dev/null -w '%{http_code}' -A "Mozilla/5.0 (compatible; $ua/1.0)" "$D/favicon.svg")"
done
curl -s "$D/robots.txt" | head -1      # must be OUR first line, not a Cloudflare header
# Optional, to see the case gap for yourself: -A gptbot and -A GPTBOT both return 200.
```

Then, after a day:

```sql
select agent_type, count(*) from v_ai_agent_visits_page
 where brand_id='<brand>' and not scanner_burst and visited_at > now()-interval '1 day' group by 1;
-- training must be 0; retrieval + index > 0 once assistants have found the site
```

## 6. Onboarding a new brand — the order

1. Copy the robots block (§2), set `Sitemap:`, deploy. Confirm byte-for-byte serving.
2. Cloudflare zone: AI Crawl Control → Managed robots.txt **OFF** (the `-Extended` tokens are
   enforced by our file alone); per-crawler Block **ON** for every refused token the dashboard
   lists; global "Block AI bots" **OFF**.
3. Run §5. Fix anything that is not 200/403 as expected before moving on.
4. Port `web/worker/ai-agent.ts` **verbatim** from vth-biodent with the hash in the header. The
   Worker hook is written per brand's Worker with these five properties: GET only · `text/html`
   responses only · apex host only · `cf.country` + `cf.asOrganization`, no IP · `ctx.waitUntil`
   (never in the response path). `seo_ai_agent_visits` is federation-shared, nothing to create.
5. Read via `v_ai_agent_visits_page`, excluding `scanner_burst`, `retrieval` only on dashboards.

## 7. Changelog

- **v1.0 (2026-09-21)** — first written standard. Source decisions: DZ-DR-066 (Deezy, 2026-09-04:
  allow answer engines / refuse training, toggles not the global switch), DR-074 (the log), the
  2026-09-20 scanner finding (deezy session), and the ClaudeBot correction (both sessions).
  Review corrections from the deezy session, each verified against Deezy's live edge: `/robots.txt`
  is exempt from the block (probe `/favicon.svg`); `-Extended` tokens are not user-agents and have
  no toggle; `Amazonbot` is refused although classified `index`; training rows are "~0 excluding
  bursts", not zero; `as_org` is a heuristic, the burst is the proof; the Worker hook is per brand.
  Same day, VTH edge: the toggle match is case-sensitive (explains the Deezy Meta exception); the
  WAF fallback is written with `lower()`; `TikTokSpider` added to the refused list and the
  classifier (ai-agent.ts, vth-biodent).
