#!/bin/bash
# =============================================================================
# create_notion_dbs_the_gifted.sh
# -----------------------------------------------------------------------------
# Creates 13 Notion databases that mirror EYWA Supabase N↔S tables.
# Target: The Gifted Synapse → Knowledge Graph page
# Spec ref: Schema_Overview_EYWA_v1_18.md + Bible §18.7
#
# USAGE:
#   1. Get integration token from https://www.notion.so/profile/integrations
#      (GIFTED X CLAUDE → Internal Integration Token)
#   2. export NOTION_TOKEN="ntn_..."
#   3. bash create_notion_dbs_the_gifted.sh
#   4. Copy the printed JSON output → paste back to Claude
#
# Token is read from env var only — never embedded in this file.
# =============================================================================

set -euo pipefail

if [ -z "${NOTION_TOKEN:-}" ]; then
  echo "ERROR: Please export NOTION_TOKEN first:"
  echo "  export NOTION_TOKEN=ntn_..."
  exit 1
fi

PAGE_ID="37bbe9c6-bf3c-8077-ab6e-c007e1de3e0e"
API_VERSION="2022-06-28"
API_URL="https://api.notion.com/v1/databases"
RESULTS_FILE="$(pwd)/notion_dbs_results.json"

echo "🚀 Creating 13 EYWA Notion DBs under Knowledge Graph page..."
echo "Token: ${NOTION_TOKEN:0:8}... (masked)"
echo "Page:  $PAGE_ID"
echo ""

# ---------------------------------------------------------------------------
# Helper: create one database
# ---------------------------------------------------------------------------
create_db() {
  local title="$1"
  local properties_json="$2"

  local payload
  payload=$(jq -nc \
    --arg pid "$PAGE_ID" \
    --arg title "$title" \
    --argjson props "$properties_json" \
    '{
      parent: {type: "page_id", page_id: $pid},
      title: [{type: "text", text: {content: $title}}],
      properties: $props
    }')

  local response
  response=$(curl -s -X POST "$API_URL" \
    -H "Authorization: Bearer $NOTION_TOKEN" \
    -H "Notion-Version: $API_VERSION" \
    -H "Content-Type: application/json" \
    --data "$payload")

  local db_id
  db_id=$(echo "$response" | jq -r '.id // empty')

  if [ -n "$db_id" ]; then
    echo "✅ $title → $db_id"
    echo "{\"title\":\"$title\",\"id\":\"$db_id\"}" >> "$RESULTS_FILE.jsonl"
  else
    local err
    err=$(echo "$response" | jq -r '.message // .code // "unknown error"')
    echo "❌ $title — $err"
    echo "$response" | jq . >&2
  fi
}

# Clear previous results
> "$RESULTS_FILE.jsonl"

# ---------------------------------------------------------------------------
# 1. [DB 1.1] Brand Database — mirror seo.brands
# ---------------------------------------------------------------------------
create_db "[DB 1.1] Brand Database" '{
  "Brand Name":              {"title": {}},
  "Brand Slug":              {"rich_text": {}},
  "Fingerprint":             {"rich_text": {}},
  "Fingerprint Display Name":{"rich_text": {}},
  "Company":                 {"rich_text": {}},
  "Status":                  {"select": {"options": [
    {"name": "ACTIVE", "color": "red"},
    {"name": "IN ACTIVE", "color": "blue"},
    {"name": "PENDING", "color": "green"}]}},
  "Brand Web URL":           {"url": {}},
  "GSC Property URL":        {"url": {}},
  "GA4 Property ID":         {"rich_text": {}},
  "Brand Description":       {"rich_text": {}},
  "Notion Workspace":        {"select": {"options": [
    {"name": "vt_intelligence", "color": "blue"},
    {"name": "the_gifted_synapse", "color": "purple"},
    {"name": "other", "color": "gray"}]}},
  "Workspace ID":            {"rich_text": {}},
  "Notion Database ID":      {"rich_text": {}},
  "Positioning Mode":        {"select": {"options": [
    {"name": "A-open-identity", "color": "red"},
    {"name": "B-dual-layer", "color": "orange"},
    {"name": "B-weighted-recovery", "color": "yellow"},
    {"name": "C-implicit", "color": "blue"},
    {"name": "baseline", "color": "gray"}]}},
  "Compliance Profile":      {"rich_text": {}},
  "Brand Structure":         {"select": {"options": [
    {"name": "monolithic", "color": "gray"},
    {"name": "multi_center", "color": "purple"}]}}
}'

# ---------------------------------------------------------------------------
# 2. Branches Database — mirror seo_branches
# ---------------------------------------------------------------------------
create_db "Branches Database" '{
  "Branch Name":             {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "Fingerprint Display Name":{"rich_text": {}},
  "Branch Slug":             {"rich_text": {}},
  "Brand ID":                {"rich_text": {}},
  "Brand Slug":              {"rich_text": {}},
  "Is Primary":              {"checkbox": {}},
  "Business Name (Legal)":   {"rich_text": {}},
  "Business Name (Brand)":   {"rich_text": {}},
  "Street":                  {"rich_text": {}},
  "District":                {"rich_text": {}},
  "City":                    {"rich_text": {}},
  "Region":                  {"rich_text": {}},
  "Country":                 {"select": {"options": [
    {"name": "TH", "color": "red"}, {"name": "US", "color": "blue"},
    {"name": "JP", "color": "pink"}, {"name": "CN", "color": "orange"},
    {"name": "SG", "color": "green"}, {"name": "MY", "color": "yellow"},
    {"name": "KR", "color": "purple"}, {"name": "GB", "color": "gray"},
    {"name": "AU", "color": "brown"}, {"name": "DE", "color": "default"},
    {"name": "FR", "color": "blue"}, {"name": "AE", "color": "red"}]}},
  "Postal Code":             {"rich_text": {}},
  "Formatted Address":       {"rich_text": {}},
  "Latitude":                {"number": {}},
  "Longitude":               {"number": {}},
  "Plus Code":               {"rich_text": {}},
  "Phone":                   {"phone_number": {}},
  "Email":                   {"email": {}},
  "LINE ID":                 {"rich_text": {}},
  "Website URL":             {"url": {}},
  "GBP Place ID":            {"rich_text": {}},
  "GBP Account ID":          {"rich_text": {}},
  "GBP Categories":          {"multi_select": {"options": [
    {"name": "dental_clinic", "color": "default"},
    {"name": "medical_clinic", "color": "blue"}]}},
  "GBP Review Count":        {"number": {}},
  "GBP Avg Rating":          {"number": {}},
  "GBP Last Synced At":      {"date": {}},
  "Apple Maps ID":           {"rich_text": {}},
  "Facebook Page":           {"url": {}},
  "Wongnai URL":             {"url": {}},
  "Wongnai ID":              {"rich_text": {}},
  "Schema Type":             {"select": {"options": [
    {"name": "LocalBusiness", "color": "default"},
    {"name": "MedicalClinic", "color": "blue"},
    {"name": "DentalClinic", "color": "green"},
    {"name": "Hospital", "color": "red"},
    {"name": "BeautySalon", "color": "pink"}]}},
  "Primary Photo":           {"url": {}},
  "Status":                  {"select": {"options": [
    {"name": "active", "color": "green"},
    {"name": "closed", "color": "red"},
    {"name": "temp_closed", "color": "orange"},
    {"name": "pending_opening", "color": "blue"}]}},
  "Opened Date":             {"date": {}},
  "Closed Date":              {"date": {}},
  "Business Reg No":         {"rich_text": {}},
  "Medical License No":      {"rich_text": {}}
}'

# ---------------------------------------------------------------------------
# 3. Brand Centers (DR-032 v1.18)
# ---------------------------------------------------------------------------
create_db "Brand Centers" '{
  "Center Name":             {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "Fingerprint Display Name":{"rich_text": {}},
  "Brand ID":                {"rich_text": {}},
  "Center Slug":             {"rich_text": {}},
  "Center Name JSON":        {"rich_text": {}},
  "URL Segment":             {"rich_text": {}},
  "Positioning One Line":    {"rich_text": {}},
  "Signature Methodologies": {"multi_select": {"options": []}},
  "Color Treatment Hex":     {"rich_text": {}},
  "Position Order":          {"number": {}},
  "Status":                  {"select": {"options": [
    {"name": "planning", "color": "gray"},
    {"name": "active", "color": "green"},
    {"name": "paused", "color": "orange"},
    {"name": "sunset", "color": "red"}]}},
  "Anchor Outcome":          {"rich_text": {}}
}'

# ---------------------------------------------------------------------------
# 4. Medical Team Database — mirror seo_authors_reviewers
# ---------------------------------------------------------------------------
create_db "Medical Team Database" '{
  "Doctor Name":             {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "Fingerprint Display Name":{"rich_text": {}},
  "Doctor English Name":     {"rich_text": {}},
  "Nickname":                {"rich_text": {}},
  "Title / Degree":          {"rich_text": {}},
  "Credentials":             {"multi_select": {"options": [
    {"name": "MD", "color": "blue"},
    {"name": "DDS", "color": "green"},
    {"name": "PhD", "color": "purple"},
    {"name": "MD-PhD", "color": "pink"},
    {"name": "RPh", "color": "orange"},
    {"name": "RN", "color": "red"},
    {"name": "PharmD", "color": "yellow"},
    {"name": "DPT", "color": "brown"}]}},
  "Credentials Summary":     {"rich_text": {}},
  "License Number":          {"rich_text": {}},
  "License Country":         {"select": {"options": [
    {"name": "TH", "color": "red"}, {"name": "US", "color": "blue"},
    {"name": "JP", "color": "pink"}, {"name": "CN", "color": "orange"},
    {"name": "SG", "color": "green"}, {"name": "MY", "color": "yellow"},
    {"name": "KR", "color": "purple"}, {"name": "GB", "color": "gray"},
    {"name": "AU", "color": "brown"}, {"name": "DE", "color": "default"}]}},
  "License Verified":        {"date": {}},
  "Board Certifications":    {"rich_text": {}},
  "Advisory Board":          {"checkbox": {}},
  "Bio (Long)":              {"rich_text": {}},
  "Bio (Short)":             {"rich_text": {}},
  "Primary Specialty":       {"select": {"options": [
    {"name": "Dental Sleep Medicine", "color": "yellow"},
    {"name": "General Dentistry", "color": "default"},
    {"name": "Orthodontics", "color": "blue"},
    {"name": "Prosthodontics", "color": "purple"},
    {"name": "Endodontics", "color": "orange"},
    {"name": "Periodontics", "color": "green"},
    {"name": "Pediatric Dentistry", "color": "pink"},
    {"name": "Oral Surgery", "color": "red"},
    {"name": "Maxillofacial Surgery", "color": "red"},
    {"name": "ENT", "color": "pink"},
    {"name": "Cosmetic Dentistry", "color": "yellow"},
    {"name": "Implantology", "color": "brown"},
    {"name": "Aesthetic Medicine", "color": "pink"},
    {"name": "Dermatology", "color": "blue"},
    {"name": "Mens Vitality", "color": "red"},
    {"name": "Wellness Medicine", "color": "green"}]}},
  "Specialty Tags":          {"multi_select": {"options": []}},
  "Languages":               {"multi_select": {"options": [
    {"name": "th", "color": "blue"}, {"name": "en", "color": "default"},
    {"name": "zh", "color": "red"}, {"name": "ja", "color": "pink"},
    {"name": "ko", "color": "orange"}, {"name": "ar", "color": "brown"},
    {"name": "fr", "color": "purple"}, {"name": "es", "color": "yellow"}]}},
  "Email":                   {"email": {}},
  "Contact Number":          {"phone_number": {}},
  "LinkedIn":                {"url": {}},
  "Photo URL":               {"url": {}},
  "Profile Priority":        {"select": {"options": [
    {"name": "Featured", "color": "yellow"},
    {"name": "Standard", "color": "gray"}]}},
  "Gender":                  {"select": {"options": [
    {"name": "Female", "color": "green"},
    {"name": "Male", "color": "brown"}]}},
  "Active Status":           {"checkbox": {}},
  "Slug":                    {"rich_text": {}}
}'

# ---------------------------------------------------------------------------
# 5. Doctor Assignments Database
# ---------------------------------------------------------------------------
create_db "Doctor Assignments Database" '{
  "Doctor":                  {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "Fingerprint Display Name":{"rich_text": {}},
  "Author FP":               {"rich_text": {}},
  "Brand ID":                {"rich_text": {}},
  "Branch ID":               {"rich_text": {}},
  "Role":                    {"select": {"options": [
    {"name": "reviewer", "color": "blue"},
    {"name": "author", "color": "green"},
    {"name": "consultant", "color": "yellow"},
    {"name": "medical_director", "color": "red"},
    {"name": "attending", "color": "purple"},
    {"name": "visiting", "color": "gray"}]}},
  "Primary Role":            {"checkbox": {}},
  "Started":                 {"date": {}},
  "Ended":                   {"date": {}}
}'

# ---------------------------------------------------------------------------
# 6. 🧬 Entity Graph — mirror seo_entity_graph
# ---------------------------------------------------------------------------
create_db "🧬 Entity Graph" '{
  "Entity Name":             {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "Fingerprint Display Name":{"rich_text": {}},
  "Entity Slug":             {"rich_text": {}},
  "Entity Type":             {"multi_select": {"options": [
    {"name": "Condition", "color": "blue"},
    {"name": "Symptom", "color": "red"},
    {"name": "Treatment", "color": "green"},
    {"name": "Technology", "color": "purple"},
    {"name": "Specialty", "color": "orange"},
    {"name": "Anatomy", "color": "pink"},
    {"name": "Drug", "color": "yellow"},
    {"name": "Procedure", "color": "brown"},
    {"name": "Concept", "color": "gray"},
    {"name": "Product", "color": "default"}]}},
  "Entity Subtype":          {"select": {"options": [
    {"name": "framework", "color": "purple"},
    {"name": "axis", "color": "blue"},
    {"name": "general", "color": "gray"}]}},
  "Topic Cluster ID":        {"rich_text": {}},
  "Topic Cluster Name":      {"rich_text": {}},
  "Schema.org Type":         {"select": {"options": [
    {"name": "MedicalCondition", "color": "blue"},
    {"name": "MedicalTherapy", "color": "green"},
    {"name": "MedicalProcedure", "color": "purple"},
    {"name": "Symptom", "color": "red"},
    {"name": "MedicalSpecialty", "color": "orange"},
    {"name": "Drug", "color": "yellow"},
    {"name": "MedicalDevice", "color": "pink"}]}},
  "Entity Authority Score":  {"number": {}},
  "Search Volume Total":     {"number": {}},
  "Brand Scope":             {"multi_select": {"options": []}},
  "Center Scope":            {"multi_select": {"options": []}},
  "Entity Lifecycle":        {"select": {"options": [
    {"name": "Emerging", "color": "blue"},
    {"name": "Growing", "color": "green"},
    {"name": "Mature", "color": "orange"},
    {"name": "Declining", "color": "red"}]}},
  "Programmatic Eligible":   {"checkbox": {}},
  "Wikipedia URL":           {"url": {}},
  "Wikidata ID":             {"rich_text": {}},
  "Competing Entities":      {"rich_text": {}},
  "AI Entity Summary":       {"rich_text": {}},
  "Hreflang Group":          {"rich_text": {}},
  "Aliases":                 {"rich_text": {}},
  "ICD-10 Code":             {"rich_text": {}},
  "Content Gap Flag":        {"checkbox": {}},
  "Last Graph Update":       {"date": {}}
}'

# ---------------------------------------------------------------------------
# 7. Topic Cluster Master
# ---------------------------------------------------------------------------
create_db "Topic Cluster Master" '{
  "Cluster Name":            {"title": {}},
  "Cluster Slug":            {"rich_text": {}},
  "Fingerprint":             {"rich_text": {}},
  "Fingerprint Display Name":{"rich_text": {}},
  "Cluster Type":            {"select": {"options": [
    {"name": "topical", "color": "blue"},
    {"name": "content_format", "color": "green"},
    {"name": "audience", "color": "orange"},
    {"name": "section_meta", "color": "purple"}]}},
  "Parent Cluster FP":       {"rich_text": {}},
  "Hierarchy Level":         {"number": {}},
  "SKOS Concept Scheme":     {"rich_text": {}},
  "Canonical Names":         {"rich_text": {}},
  "Aliases":                 {"rich_text": {}},
  "Descriptions":            {"rich_text": {}},
  "Brand Scope":             {"multi_select": {"options": []}},
  "Brand Scope Primary":     {"rich_text": {}},
  "Cluster Facet":           {"rich_text": {}},
  "Cluster Health Score":    {"number": {}},
  "Cluster Topical Authority":{"number": {}},
  "Cluster Health Breakdown":{"rich_text": {}},
  "Cluster Health Formula Version":{"rich_text": {}},
  "Cluster Health Computed At":{"date": {}},
  "Status":                  {"select": {"options": [
    {"name": "active", "color": "green"},
    {"name": "draft", "color": "gray"},
    {"name": "archived", "color": "red"}]}}
}'

# ---------------------------------------------------------------------------
# 8. Citations Pool — mirror seo_citations
# ---------------------------------------------------------------------------
create_db "Citations Pool" '{
  "Title":                   {"title": {}},
  "Citation Slug":           {"rich_text": {}},
  "Fingerprint":             {"rich_text": {}},
  "Fingerprint Display Name":{"rich_text": {}},
  "Authors":                 {"rich_text": {}},
  "Publication Year":        {"number": {}},
  "PubMed PMID":             {"rich_text": {}},
  "DOI":                     {"rich_text": {}},
  "ISBN":                    {"rich_text": {}},
  "URL":                     {"url": {}},
  "Archive URL":             {"url": {}},
  "Journal Name":            {"rich_text": {}},
  "Publisher Name":          {"rich_text": {}},
  "Source Org FP":           {"rich_text": {}},
  "Publication Date":        {"date": {}},
  "Citation Tier":           {"number": {}},
  "Citation Type":           {"select": {"options": [
    {"name": "journal_article", "color": "blue"},
    {"name": "clinical_guideline", "color": "green"},
    {"name": "systematic_review", "color": "purple"},
    {"name": "rct", "color": "orange"},
    {"name": "book", "color": "brown"},
    {"name": "government", "color": "red"},
    {"name": "organization", "color": "gray"},
    {"name": "website", "color": "default"}]}},
  "Citation Authority Weight":{"number": {}},
  "Authority Breakdown":     {"rich_text": {}},
  "Authority Formula Version":{"rich_text": {}},
  "Authority Computed At":   {"date": {}},
  "Country of Origin":       {"rich_text": {}},
  "Language Code":           {"rich_text": {}},
  "Is Thai Specific":        {"checkbox": {}},
  "Abstract":                {"rich_text": {}},
  "Key Findings":            {"rich_text": {}},
  "Study Type":              {"select": {"options": [
    {"name": "meta_analysis", "color": "purple"},
    {"name": "systematic_review", "color": "blue"},
    {"name": "rct", "color": "green"},
    {"name": "cohort", "color": "orange"},
    {"name": "case_control", "color": "yellow"},
    {"name": "case_series", "color": "brown"},
    {"name": "expert_opinion", "color": "gray"},
    {"name": "in_vitro", "color": "pink"},
    {"name": "animal", "color": "red"}]}},
  "Brand Scope":             {"multi_select": {"options": []}},
  "Is Retracted":            {"checkbox": {}},
  "Retracted At":            {"date": {}},
  "Last Verified At":        {"date": {}},
  "Verification Status":     {"select": {"options": [
    {"name": "verified", "color": "green"},
    {"name": "pending", "color": "yellow"},
    {"name": "broken", "color": "red"},
    {"name": "unverified", "color": "gray"}]}}
}'

# ---------------------------------------------------------------------------
# 9. Entity Relationships — mirror seo_entity_relationships (DR-013)
# ---------------------------------------------------------------------------
create_db "Entity Relationships" '{
  "Display Name":            {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "From Entity FP":          {"rich_text": {}},
  "To Entity FP":            {"rich_text": {}},
  "Edge Type":               {"rich_text": {}},
  "Edge Note":               {"rich_text": {}},
  "Edge Strength":           {"number": {}},
  "Edge Evidence Score":     {"number": {}},
  "Edge Evidence Citation":  {"rich_text": {}},
  "Medical Reviewer Signoff At":{"date": {}},
  "Medical Reviewer FP":     {"rich_text": {}},
  "Brand Scope":             {"multi_select": {"options": []}},
  "Status":                  {"select": {"options": [
    {"name": "active", "color": "green"},
    {"name": "draft", "color": "gray"},
    {"name": "pending_signoff", "color": "yellow"},
    {"name": "deprecated", "color": "red"}]}}
}'

# ---------------------------------------------------------------------------
# 10. 🌐 Website & SEO Page Intelligent Master — mirror seo_website_page_master
#     (Most complex — 86+ cols, condensed to ~50 most-used)
# ---------------------------------------------------------------------------
create_db "🌐 Website & SEO Page Intelligent Master" '{
  "Page Name":               {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "Fingerprint Display Name":{"rich_text": {}},
  "Brand ID":                {"rich_text": {}},
  "Slug":                    {"rich_text": {}},
  "SEO Title":               {"rich_text": {}},
  "Meta Description":        {"rich_text": {}},
  "Canonical URL":           {"url": {}},
  "Redirect Target":         {"url": {}},
  "Cluster ID":              {"rich_text": {}},
  "Sitemap Node ID":         {"rich_text": {}},
  "Sitemap Section":         {"rich_text": {}},
  "Page Type":               {"rich_text": {}},
  "Page Intent Type":        {"rich_text": {}},
  "Node Tier":               {"rich_text": {}},
  "Node Tier Strategy":      {"select": {"options": [
    {"name": "hub", "color": "blue"},
    {"name": "spoke", "color": "green"},
    {"name": "pillar", "color": "purple"},
    {"name": "supporting", "color": "orange"},
    {"name": "leaf", "color": "gray"}]}},
  "Funnel Stage":            {"rich_text": {}},
  "Priority":                {"rich_text": {}},
  "Link Role":               {"rich_text": {}},
  "Link Priority":           {"rich_text": {}},
  "Anchor Strategy Mode":    {"rich_text": {}},
  "Authority Weight":        {"number": {}},
  "Link Equity Score":       {"number": {}},
  "Orphan Risk Score":       {"number": {}},
  "Crawl Depth":             {"number": {}},
  "Is Source Page":          {"checkbox": {}},
  "Strategic Page":          {"checkbox": {}},
  "Cross-Brand Approved":    {"checkbox": {}},
  "Cross-Brand Justification":{"rich_text": {}},
  "Cross-Brand Role":        {"rich_text": {}},
  "Cross-Brand Link Type":   {"rich_text": {}},
  "Brand Authority Focus":   {"rich_text": {}},
  "Primary Entity FP":       {"rich_text": {}},
  "Target Keyword FP":       {"rich_text": {}},
  "Schema Markup Type":      {"rich_text": {}},
  "Page Language":           {"rich_text": {}},
  "Translation Status":      {"rich_text": {}},
  "Translation Due Date":    {"date": {}},
  "Source Page of Translation":{"rich_text": {}},
  "Content Format":          {"rich_text": {}},
  "Auto Suggested Word Count Target":{"number": {}},
  "Required Min Outbound":   {"number": {}},
  "Required Min Inbound":    {"number": {}},
  "In XML Sitemap":          {"checkbox": {}},
  "Robots Directive":        {"rich_text": {}},
  "WPML Page ID":            {"number": {}},
  "Note Brief":              {"rich_text": {}},
  "Content Brief":           {"rich_text": {}},
  "Suggested page content":  {"rich_text": {}},
  "Viability Assessment":    {"rich_text": {}},
  "Marketplace Proposal Status":{"select": {"options": [
    {"name": "in_scope", "color": "gray"},
    {"name": "proposed", "color": "blue"},
    {"name": "accepted_repackaged", "color": "green"},
    {"name": "rejected", "color": "red"},
    {"name": "deferred", "color": "orange"}]}},
  "Reconciliation Notes":    {"rich_text": {}},
  "FLAG/REVIEW":             {"rich_text": {}},
  "Status":                  {"rich_text": {}},
  "Published Date":          {"date": {}},
  "Hreflang Validated":      {"checkbox": {}},
  "Has Medical Review":      {"checkbox": {}},
  "Review Cycle":            {"rich_text": {}},
  "Snapshot Version":        {"rich_text": {}},
  "Product Regulatory Tier": {"number": {}},
  "Content Topic Tier":      {"number": {}},
  "Sensitive Topic Flag":    {"select": {"options": [
    {"name": "none", "color": "gray"},
    {"name": "low", "color": "blue"},
    {"name": "medium", "color": "yellow"},
    {"name": "high", "color": "orange"},
    {"name": "critical", "color": "red"}]}},
  "Target Audience Segment": {"multi_select": {"options": [
    {"name": "recovery", "color": "red"},
    {"name": "postpartum", "color": "pink"},
    {"name": "mental-health-clinical", "color": "purple"},
    {"name": "cancer-survivor", "color": "orange"},
    {"name": "pediatric", "color": "blue"},
    {"name": "senior", "color": "gray"},
    {"name": "pregnancy", "color": "yellow"}]}},
  "Legal Review Required":   {"checkbox": {}},
  "Compliance Max Tier":     {"number": {}},
  "Center Slug":             {"rich_text": {}},
  "Page Purpose":            {"select": {"options": [
    {"name": "seo_organic", "color": "green"},
    {"name": "ads_landing", "color": "orange"},
    {"name": "hybrid", "color": "purple"},
    {"name": "utility", "color": "gray"},
    {"name": "legal", "color": "red"},
    {"name": "thank_you", "color": "blue"}]}},
  "Ads Template ID":         {"rich_text": {}},
  "Index Directive":         {"select": {"options": [
    {"name": "index", "color": "green"},
    {"name": "noindex", "color": "red"},
    {"name": "index_no_follow", "color": "yellow"},
    {"name": "noindex_no_follow", "color": "orange"}]}},
  "Conversion Event Primary":{"rich_text": {}},
  "Conversion Event Secondary":{"multi_select": {"options": []}},
  "Campaign ID":             {"rich_text": {}}
}'

# ---------------------------------------------------------------------------
# 11. Editorial Reviews — mirror seo_editorial_reviews (DR-030 legal_compliance)
# ---------------------------------------------------------------------------
create_db "Editorial Reviews" '{
  "Display Name":            {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "Page FP":                 {"rich_text": {}},
  "Reviewer FP":             {"rich_text": {}},
  "Review Type":             {"select": {"options": [
    {"name": "medical", "color": "red"},
    {"name": "editorial", "color": "blue"},
    {"name": "fact_check", "color": "orange"},
    {"name": "legal", "color": "purple"},
    {"name": "seo", "color": "green"},
    {"name": "translation", "color": "yellow"},
    {"name": "final_approval", "color": "gray"},
    {"name": "legal_compliance", "color": "pink"}]}},
  "Review Stage":            {"rich_text": {}},
  "Review Status":           {"select": {"options": [
    {"name": "pending", "color": "gray"},
    {"name": "in_progress", "color": "yellow"},
    {"name": "changes_requested", "color": "orange"},
    {"name": "approved", "color": "green"},
    {"name": "rejected", "color": "red"},
    {"name": "skipped", "color": "default"}]}},
  "Review Score":            {"number": {}},
  "Findings":                {"rich_text": {}},
  "Recommendations":         {"rich_text": {}},
  "Blocking Issues Count":   {"number": {}},
  "E-E-A-T Compliance":      {"rich_text": {}},
  "Scheduled For":           {"date": {}},
  "Started At":              {"date": {}},
  "Completed At":            {"date": {}},
  "Next Review Due":         {"date": {}},
  "Approved":                {"checkbox": {}},
  "Approved At":             {"date": {}}
}'

# ---------------------------------------------------------------------------
# 12. Page Internal Links — mirror seo_page_internal_links (DR-021)
# ---------------------------------------------------------------------------
create_db "Page Internal Links" '{
  "Display Name":            {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "From Page FP":            {"rich_text": {}},
  "To Page FP":              {"rich_text": {}},
  "To External URL":         {"url": {}},
  "Link Type":               {"select": {"options": [
    {"name": "internal", "color": "blue"},
    {"name": "external", "color": "orange"},
    {"name": "cross_brand", "color": "purple"},
    {"name": "cross_center_intra_brand", "color": "green"}]}},
  "Link Role":               {"select": {"options": [
    {"name": "structural", "color": "blue"},
    {"name": "authority", "color": "purple"},
    {"name": "contextual", "color": "green"},
    {"name": "conversion", "color": "orange"}]}},
  "Link Priority":           {"number": {}},
  "Anchor Text":             {"rich_text": {}},
  "Anchor Variant Type":     {"select": {"options": [
    {"name": "exact", "color": "red"},
    {"name": "partial", "color": "orange"},
    {"name": "branded", "color": "blue"},
    {"name": "generic", "color": "gray"},
    {"name": "naked_url", "color": "default"}]}},
  "Section Context":         {"rich_text": {}},
  "Surrounding Text Snippet":{"rich_text": {}},
  "Status":                  {"select": {"options": [
    {"name": "planned", "color": "gray"},
    {"name": "implemented", "color": "green"},
    {"name": "broken", "color": "red"},
    {"name": "removed", "color": "default"}]}},
  "Planned":                 {"checkbox": {}},
  "Implemented":             {"checkbox": {}},
  "First Planned At":        {"date": {}},
  "Last Verified At":        {"date": {}},
  "Is Reciprocal":           {"checkbox": {}},
  "Is Cross Brand":          {"checkbox": {}},
  "Cross Brand Justification":{"rich_text": {}},
  "Cross Brand Role":        {"rich_text": {}},
  "Brand Scope":             {"multi_select": {"options": []}}
}'

# ---------------------------------------------------------------------------
# 13. Keyword Hub — mirror seo_x_ads_keywords_contextual_master (DR-026)
# ---------------------------------------------------------------------------
create_db "Keyword Hub" '{
  "Keyword":                 {"title": {}},
  "Fingerprint":             {"rich_text": {}},
  "Brand":                   {"rich_text": {}},
  "Search Intent":           {"rich_text": {}},
  "Ads Intent":              {"rich_text": {}},
  "Funnel Stage":            {"rich_text": {}},
  "Anxiety Level":           {"rich_text": {}},
  "Keyword Painpoint":       {"rich_text": {}},
  "Keyword Core Insight":    {"rich_text": {}},
  "Target Market":           {"rich_text": {}},
  "Target Language":         {"rich_text": {}},
  "Qualitative KD":          {"rich_text": {}},
  "Qualitative KD Number":   {"number": {}},
  "KD Reasoning":            {"rich_text": {}},
  "Predicted SERP Features": {"rich_text": {}},
  "WPML Code":               {"rich_text": {}},
  "Translation Group":       {"rich_text": {}},
  "Primary Entity FP":       {"rich_text": {}},
  "Primary Entity Name":     {"rich_text": {}},
  "Keyword Use As":          {"rich_text": {}},
  "SEO Active":              {"checkbox": {}},
  "Ad Active":               {"checkbox": {}},
  "Ad Intent Score":         {"number": {}},
  "Ad Match Type Preferred": {"select": {"options": [
    {"name": "exact", "color": "red"},
    {"name": "phrase", "color": "orange"},
    {"name": "broad", "color": "blue"},
    {"name": "broad_modified", "color": "purple"}]}},
  "Ad Landing Page FP":      {"rich_text": {}},
  "Ad Priority Tier":        {"select": {"options": [
    {"name": "t1", "color": "red"},
    {"name": "t2", "color": "orange"},
    {"name": "t3", "color": "yellow"},
    {"name": "none", "color": "gray"}]}},
  "Notion Tier":             {"rich_text": {}},
  "Note":                    {"rich_text": {}}
}'

# ---------------------------------------------------------------------------
# Print summary
# ---------------------------------------------------------------------------
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "📋 Results saved to: $RESULTS_FILE.jsonl"
echo ""
echo "Compact summary (paste this back to Claude):"
echo "------------------------------------------------------------------"
cat "$RESULTS_FILE.jsonl"
echo ""
echo "================================================================"
echo "Done. If any ❌, check $RESULTS_FILE.jsonl + curl output above."
