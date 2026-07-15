---
name: onboard-client
description: "Set up a new client folder with all templates, then research the company, competitors, and industry benchmarks to populate starting files. Use when onboarding a new client, setting up a new client folder, or when the user says 'new client', 'onboard', or 'set up [company name]'."
disable-model-invocation: true
effort: max
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch
hooks:
  Stop:
    - hooks:
        - type: command
          command: "bash \"$CLAUDE_PROJECT_DIR/.claude/skills/onboard-client/scripts/validate-onboarding.sh\""
          statusMessage: "Validating client folder structure..."
---

# Onboard Client

Set up a new client folder from templates and populate it with researched data.

> **Setup:** requires `Clients/Templates/` to exist with your own template files. The research steps below are written for ecommerce/agency work — rewrite Step 4 for your domain.

## Instructions

The user will provide at minimum a client name. They may also provide:
- Website URL
- Industry/vertical
- Engagement type (retainer, project, consulting)
- Whether this is a multi-brand client
- Any known contacts

### Step 1: Gather Basics

Ask the user for anything not provided:

```
Setting up: [Client Name]

I need a few details:
- Website URL?
- Industry/vertical?
- Engagement type? (retainer / project / consulting)
- Multi-brand? (if yes, list brand names)
- Any known contacts? (name, role, email)
```

Only ask for what's missing. If the user provided everything, skip straight to setup.

### Step 2: Create Folder Structure

**Single-brand client:**
```
Clients/[Client Name]/
├── Client Details/
├── Meeting Notes/
├── Issues/
├── Case Studies/
└── Reports/
    └── Source Data/
```

**Multi-brand client:**
```
Clients/[Client Name - Brand2]/
├── [Brand1]/
│   ├── Client Details/
│   └── Issues/
├── [Brand2]/
│   ├── Client Details/
│   └── Issues/
├── Meeting Notes/
├── Case Studies/
└── Reports/
    └── Source Data/
```

### Step 3: Copy and Rename Templates

Copy templates from `Clients/Templates/` to the new client's `Client Details/` folder. Rename each file with the client (or brand) name.

**Always create:**
- `[Name] Client Profile.md`
- `[Name] Decision Log.md`
- `[Name] Results Tracker.md`
- `[Name] Opportunity Backlog.md`

**Also create (populated by research):**
- `[Name] Competitors.md`
- `[Name] Conversion Benchmarks.md`
- `[Name] Tech Stack.md`

Set frontmatter `date_created` and `date_updated` to today's date. Set `tags` to kebab-case client name. Set `client_since` and `engagement_type` in the Client Profile.

For multi-brand clients, create Client Details files per brand.

### Step 4: Research (Parallel Sub-Agents)

Launch **3 sub-agents in parallel** to research the client. Each agent should use WebSearch and WebFetch to gather data.

**Agent 1 — Company Profile Research:**
- Company founding story, history, milestones
- Founders and leadership team
- Headquarters, company size, ownership (private/public)
- Market position and what they're known for
- Recent news or developments
- Store/platform details (theme, notable apps visible on the storefront)
- Current pain points visible from the outside (slow site, poor mobile UX, missing features)

Search queries to try:
- `"[Company Name]" founded history`
- `"[Company Name]" shopify store`
- `site:[website] about`
- `"[Company Name]" ecommerce`

**Agent 2 — Competitor Research:**
- Identify 3-5 direct competitors in the same vertical/market
- For each: website, market position, strengths, weaknesses
- Feature comparison where visible (product pages, checkout, UX patterns)
- Pricing comparison if products are similar
- What competitors do well that the client doesn't (opportunities)

Search queries to try:
- `"[Company Name]" competitors`
- `[industry] [product type] brands`
- `"[Company Name]" vs`
- `similar to "[Company Name]" [industry]`

**Agent 3 — Benchmark Research:**
- Industry-specific conversion rate benchmarks for the client's vertical
- Average order value benchmarks
- Mobile vs desktop conversion benchmarks
- Cart abandonment rate benchmarks
- Source all data and note the year/recency of each benchmark

Search queries to try:
- `[industry] ecommerce conversion rate benchmark [year]`
- `[platform] [industry] average conversion rate`
- `[industry] average order value ecommerce`
- `ecommerce conversion rate by industry`

### Step 5: Populate Files

Using research results from the sub-agents, populate the template files:

**Client Profile:**
- Fill in Company Overview table (company, industry, founded, founders, HQ, size, ownership, website)
- Write Background section (2-3 paragraphs from research)
- Write Market Position section
- Add known contacts to Key Contacts table
- Set Current Engagement details
- Flag any fields that couldn't be verified with `[unverified]` or leave blank

**Competitors:**
- Fill Competitor Overview table with 3-5 competitors
- Add Detailed Profiles for each (at minimum: website, market position, strengths, weaknesses)
- Start Feature Comparison table if enough data exists
- Note: this is a starting point — will be refined as client work progresses

**Conversion Benchmarks:**
- Fill Industry Benchmarks table with sourced data
- Add benchmark sources and dates
- Write Context section explaining the client's vertical
- Leave Client Baseline empty — to be filled during kickoff or first meeting
- Note: actual client metrics will be added once analytics access is granted

**Tech Stack:**
- Note the platform
- Add any visible apps or integrations detected from the storefront
- Leave detailed sections minimal — will be built up during meetings

### Step 6: Update Client Mappings

Add the new client to `.claude/references/client-mappings.md`:

1. **Title Keywords table** — add detection keywords for the new client
2. **Email Domains table** — add if the email domain is known
3. **Issue Tracker Team Mapping** — add, defaulting to a general team if there's no dedicated one yet

This step is what makes `/process-meeting-notes` able to detect the client later. Skipping it means the first call with this client won't route anywhere.

### Step 7: Create Context File

If you keep long-lived context/memory files, create one for the new client recording: onboarding date, engagement type, a one-sentence description of what they do, initial scope if known, and next steps (kickoff meeting, capture baseline metrics, confirm tech stack, refine competitor analysis).

### Step 8: Summary

Present the completed setup:

```
## Client Onboarded: [Client Name]

### Folder Structure
[tree showing created folders]

### Files Created
- [list of files with brief note on what was populated]

### Research Highlights
- **Company:** [1-2 sentence summary]
- **Competitors:** [count] competitors identified: [names]
- **Benchmarks:** [industry] conversion benchmarks sourced from [sources]

### What's Next
- Schedule kickoff meeting
- Capture baseline metrics (need analytics access)
- Refine competitor and tech stack data during first calls

### Things to Verify
[List any unverified or low-confidence data points from research]
```

---

## Accuracy Rules

For the full strategy reference, see `.claude/references/accuracy-rules.md`. This skill applies: **admit uncertainty** and **external knowledge restriction** (for existing vault data — research from the web is expected here).

- **Flag confidence levels** on researched data — company founding dates, employee counts, and market positions from web searches may be outdated or wrong. Mark anything uncertain.
- **Cite sources** for benchmarks — include the source name and year so the user knows how fresh the data is.
- **Don't fabricate competitors** — only include competitors that appear in search results. If fewer than 3 are found, note that and move on.

---

## Usage

```
/onboard-client
```
(Will prompt for client name and details)

```
/onboard-client Acme Outdoors
```
(Starts with client name, asks for remaining details)

---

## Before Finishing

Before completing this workflow, verify: (1) all created files have valid YAML frontmatter, (2) `client-mappings.md` was updated with the new client, (3) a context file was created if you use them. If any are missing, fix them now.
