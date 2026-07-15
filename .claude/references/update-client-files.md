# Update Client Files

Shared reference for reading, extracting, and writing updates to client files. Used by `process-meeting-notes` and any skill that writes to client files from source material.

For client folder structure and brand detection, consult `.claude/references/client-mappings.md`.

---

## 1. Read Current Client Files

For each brand discussed, read these files from `[Brand]/Client Details/` (multi-brand) or `Client Details/` (single-brand):

**Always read:**
- `[Brand] Decision Log.md`
- `[Brand] Results Tracker.md`
- `[Brand] Opportunity Backlog.md`
- `[Brand] Tech Stack.md`

**Read if they exist:**
- `[Brand] Client Profile.md`
- `[Brand] Conversion Benchmarks.md`
- `[Brand] Competitors.md`

---

## 2. Update Brand Files

Update client files automatically — don't ask for confirmation. Decisions and opportunities go stale quickly if they're not captured while context is fresh.

For each brand discussed, update their respective files in `[Brand]/Client Details/`:

### Source Attribution

Always note the source when adding entries:
- **From meeting notes:** Include meeting date in Context column (e.g., "Discussed in 2026-03-15 call")
- **From Slack:** Include "via Slack [date]" in Context column for traceability

### [Brand] Decision Log.md
- Update `date_updated` in frontmatter
- Add new rows to the decisions table
- Format: `| Date | Decision | Context | Outcome/Notes |`
- Include ALL decisions made, even small ones
- Update outcome/notes on previous decisions if status changed

### [Brand] Results Tracker.md (HIGH PRIORITY — gated, see Results Capture below)
This file feeds future case studies and demonstrates value to the client. **Do not skip this file** during processing — scan every source for wins.

Update `date_updated` in frontmatter, then work the four canonical sections. **Do not invent new top-level sections** — dated entries go inside Project Results, never as new `##` headings. Full structure spec: `Clients/Templates/Results Tracker Template.md`.

- **Quick Stats** — project **outcomes** only, each with a Date Measured. Add metrics mentioned (conversion, average order value, revenue, traffic, sessions) with before/after when available.
  - **Never copy in site speed / Core Web Vitals / Search Console data.** If you auto-generate that data elsewhere, link to it instead. Copied performance data goes stale immediately.
  - Mark unrealized savings or projections as **targets**, never as booked wins.
- **Project Results** — newest first, heading `### YYYY-MM-DD — [Title]` + `**Type:**`. Light entries (a few bullets) for shipped batches and milestones; full `The Problem` / `What We Did` / `Results` for case-study-worthy projects. If a figure is a recommendation or projection rather than a measured live result, say so.
- **Testimonials** — **every quote goes here**, consolidated. Never scatter quotes into Project Results entries. Capture client praise **verbatim** — "I love this", "you did a great job", "this is exactly what we needed" — with speaker name, role, date, and source (call / Slack channel / issue ID). Mark paraphrases as paraphrases. Keep negative/trust-gap quotes too; they show the starting point.
- **Before/After** — note visual or functional changes, referencing screenshots or asset folders if mentioned.

#### Results Capture (MANDATORY — applies to every processing skill)

Scanning for wins is **not optional and not best-effort**. Every pass through a processing skill must explicitly sweep the source for all four of:

1. **Metrics** — any number describing performance, cost, revenue, traffic, or volume
2. **Shipped work** — anything completed, launched, fixed, or taken live
3. **Client praise** — any expression of satisfaction, relief, approval, or enthusiasm, however casual ("nice work", "that's perfect", "Yay", "Fantastic!")
4. **Process outcomes** — a standard adopted, a decision that changed how the client works, a team member newly self-sufficient

A quiet source is a legitimate outcome — but it must be an **affirmative finding, not silence.** Then write the receipt to the brand-level changelog entry for this run, directly below the Action Item Audit receipt:

```markdown
### Results Capture
- Metrics found: [N] ([brief] or "none")
- Project results added: [N] ([titles] or "none")
- Testimonials captured: [N] ([speakers] or "none")
- Results Tracker updated: [yes / no — nothing to capture this pass]
```

The literal string `### Results Capture` is what the `process-meeting-notes` Stop hook validates. Writing "none" across the board is acceptable when the source genuinely had no wins — **omitting the receipt is not.** This is the same gate model as the Action Item Audit, and it exists because these files silently went unpopulated for months while Project Results-only entries accumulated.

### [Brand] Opportunity Backlog.md
A **short, scannable menu** of ideas that could become future projects. When a client asks "what should we work on next?" this file provides quick answers.
- Update `date_updated` in frontmatter
- Add new ideas to the **High Impact** table: short description, Impact/Effort rating, and a **1-line** status note (not a paragraph)
- Add small ideas to **Quick Wins** as checkboxes with brief descriptions
- Add competitive observations to **Competitive Intel** table if mentioned
- **Always include a source link** at the end of the Notes column for traceability:
  - From meeting notes: `— [[YYYY-MM-DD Meeting Title|M/D call]]`
  - From Slack with permalink: `— [via Slack](permalink)`
  - From Slack without permalink: `— via Slack #channel YYYY-MM-DD`
- **Do NOT add running commentary, chronological notes, or meeting-by-meeting context** — that belongs in meeting notes
- **Remove entries that have graduated** to active projects (have a tracked issue). No breadcrumbs needed — version control covers history
- Keep this file short and scannable at all times

### [Brand] Tech Stack.md (CREATE IF MISSING)
- **If file doesn't exist:** Create it from `Clients/Templates/Tech Stack Template.md`
- Update `date_updated` in frontmatter
- Add new integrations to the Quick Reference table and detailed sections
- Update status of existing integrations (Active → Deprecated, Evaluating → Active, etc.)
- Add implementation details, configuration notes, or known issues mentioned
- Move integrations to Deprecated section if they're being replaced
- Add new entries to "Integrations Under Evaluation" if new tools are being considered
- Include **Implemented** date (YYYY-MM) for new integrations when known
- Include **Deprecated** date (YYYY-MM) when an integration is being removed/replaced
- Document any third-party apps, platforms, or tools discussed

**Obsidian Link Format:** When creating internal section links (e.g., in Quick Reference tables linking to detailed sections), use Obsidian wiki-link format:
```markdown
# Correct (Obsidian wiki-link):
| [[#Example App - Product Personalization|Example App]] | Product Personalization | Active |

# Incorrect (standard markdown anchor - breaks in Obsidian):
| [Example App](#example-app---product-personalization) | Product Personalization | Active |
```

### [Brand] Client Profile.md (update if relevant)
Not every source will have updates for this file. Update when:
- Client team changes (new hires, departures, role changes)
- Business context shifts (new funding, pivots, seasonal changes)
- Contact info updates (new email, phone, address)
- Company overview details change (size, ownership, key dates)

### [Brand] Conversion Benchmarks.md (update if relevant)
Not every source will have updates for this file. Track any conversion numbers mentioned — this isn't limited to conversion-rate-optimization projects. Update when:
- Any conversion metrics are shared (conversion rate %, average order value, traffic, revenue, sessions)
- Before/after data is mentioned for any project
- Industry benchmarks are referenced
- The client shares sales or traffic numbers in any context
- If the file doesn't exist and conversion data was discussed, create it from `Clients/Templates/Conversion Benchmarks Template.md`

### [Brand] Competitors.md (update if relevant)
Not every source will have updates for this file. Update when:
- Specific competitors are mentioned by name
- Competitive features, pricing, or positioning are discussed
- The client shares observations about what competitors are doing
- A/B test ideas inspired by competitor sites come up
- If the file doesn't exist and competitor intel was discussed, create it from `Clients/Templates/Competitors Template.md`

---

## 3. Push Findings to Tracked Issues

**The issue tracker is the single source of truth for all issue details, context, and research.** Don't create vault issue docs. Push findings directly into issue descriptions and comments.

### How to Identify Related Issues

1. **Scan the source** for mentions of:
   - Specific project names (e.g., "wholesale portal", "size guide rollout", "reviews platform migration")
   - Feature names, app names, or integration names
   - Keywords like "project", "implementation", "rollout", "launch"

2. **Fetch open issues** for the client's team using `list_issues`

3. **Match source topics to issues** by title, description keywords, and labels

### What to Update

For each matched issue:

1. **Update the issue description** (`save_issue` with `id` and `description`) if the new information changes the overall picture — scope, approach, requirements, blockers.

2. **Add a comment** (`save_comment` with `issueId` and `body`) for incremental updates — call notes, status changes, decisions that don't change the core description but add context. Format with a date header:
   ```markdown
   ## YYYY-MM-DD — [Source] Update

   [Summary of what was discussed]
   - Key decisions made
   - Status changes
   - Blockers identified or resolved
   ```

3. **Add decision comments**: When a decision is made about an issue, add it as both a comment on the issue AND an entry in the vault Decision Log. The comment provides in-context history; the Decision Log provides cross-cutting reference.

### Changelog Logging (REQUIRED)

Every tracker change must be logged to the **brand-level** `Linear Changelog.md`, matching the per-brand teams:
- Single-brand client → `Clients/[Client Folder]/Linear Changelog.md`
- Multi-brand client → `Clients/[Client Folder]/[Brand]/Linear Changelog.md` — **one changelog per brand.** A sync touching both brands writes an entry to each changelog, each scoped to its own brand's issues (create the brand file from the same header format if it's missing). Do NOT log to a combined client-level file for multi-brand clients.

Format:

```markdown
## YYYY-MM-DD — [Context]
- **[ID] [Issue Title]**
  - [Description of change]
  - [Another change]
```

**Prepend new entries directly below the intro line (newest first) — never append to the bottom of the file.** A bottom-appended entry reads as a missing entry to anyone scanning the top. Also bump `date_updated` (and `last_appended` if present) in the frontmatter.

This gives you a version-controlled audit trail of all Claude-initiated tracker changes — `git diff` shows exactly what changed.

### Vault Projects Folder

Long-lived project reference material (research docs, analysis, proposals, assets) lives in `Clients/[Client]/Projects/[Project Name]/`. These are NOT issue docs — they are reference material that spans multiple issues or provides deep context that doesn't fit in an issue description. Examples: theme analysis comparisons, implementation plans, proposals, data files.

---

## 4. Creating Issues

After updating all files, review action items and offer to create issues.

### ⚠️ CRITICAL: Marking Issues as Done Requires Explicit Approval

**Never mark an issue as Done without explicit approval from the user.** This applies to every skill that touches the tracker.

Even if a meeting transcript or Slack message strongly implies work is complete ("merged to live", "looks good", "all set"), do NOT update the status to Done automatically. Instead:
1. Update the client files with the progress note
2. Add the completion signal to the Decision Log
3. Collect all issues that appear complete into a confirmation list

**At the end of processing**, present the list for approval:
```
## Issues That Appear Complete — Confirm?

- [ ] ACME-31 "Gift Card Balance Checker" — client confirmed it's live (2026-04-15 call)
- [ ] GLX-27 "Bundle Discount Display" — client tested and confirmed "all looks good" (via Slack)

Mark as Done? (all / select by number / none)
```

**Once approved**, then:
1. Update the issue status to Done
2. Log the change in the brand-level `Linear Changelog.md`

### 4a. Identify ALL Action Items for You

Extract **every** action item assigned to you (not client action items). This includes:
- New standalone tasks
- Sub-tasks of existing projects
- Follow-ups on existing work

**Every actionable item you committed to must end up in the tracker.** If it's not there, it doesn't get done. Vault files are the source of truth for project *context*, but the tracker is the source of truth for *what to work on next*.

**From meeting transcripts**, look for explicit assignments and commitments.
**From Slack messages**, look for:
- Direct requests: "can you", "please", "need you to"
- Commitments: "I'll", "I will", "I can do that"
- Deadlines: "by Friday", "next week", "ASAP"

### 4b. Classify Each Action Item

For each action item, determine its relationship to existing issues:

1. **Fetch open issues** for the client's team(s) using `list_issues`
2. **For each action item**, classify as one of:
   - **Duplicate** — an existing issue already covers this exact task → skip, note in summary
   - **Already done (verified)** — the commitment was fulfilled between the source and now → skip, cite the evidence in the audit
   - **Sub-issue of existing parent** — the task is part of an existing project (e.g., "add gift note field" is a sub-task of "checkout customization") → create as sub-issue with `parentId`
   - **Related to existing issue** — connected but not a subtask → create as standalone, link with `relatedTo`
   - **New standalone** — no relationship to existing issues → create as new issue

**Scheduling commitments get a calendar check.** For action items that are calendar work (send an invite, schedule a recurring call, book a follow-up), check the calendar (`list_events`, read-only) for a matching event before classifying — you often send the invite minutes after committing to it, and a dead-on-arrival issue is noise. If the event exists, classify as Already done (verified).

**Be aggressive about matching to parents.** If an action item clearly belongs to an active project, it should be a sub-issue — not a standalone issue floating in the backlog.

**Prefer a sub-issue over a comment for discrete sub-tasks.** When an action item relates to an existing issue, decide deliberately: a **comment** is for status, context, or decisions on that issue; a **sub-issue** (`parentId`) is for a distinct, trackable unit of work. Default discrete tasks to sub-issues — don't bury a real to-do inside a comment, where it gets lost and never gets closed. Comments are often the right call (status notes, "no change needed", findings), but when in doubt and it's a *task*, make the sub-issue.

### 4c. Present All Issues for Approval

Present the full list grouped by type, then ask once:

```
## Issues from [Source]

### Sub-issues of existing projects
1. "Add gift note field to checkout" → sub-issue of GLX-12
2. "Build delivery date picker section" → sub-issue of GLX-12
3. "Set up remaining 3 collection templates" → sub-issue of GLX-12

### New standalone issues
4. "Investigate abandoned cart email setup" → Globex team, Normal priority

### Skipped (already exist)
- "Continue product image updates" → already GLX-2 and GLX-7

Create all? (y/n/select by number)
```

**If presenting via AskUserQuestion:** put the complete draft — title, priority, project/parent, and the full description — in each option's `preview` field so it can be read inside the dialog itself before answering. Summaries in the chat above the dialog get missed when answering quickly; the preview is the safeguard.

### 4d. If Approved

1. Create the issue using `save_issue` with:
   - `team`: Use the team mapping from `.claude/references/client-mappings.md`
   - `title`: Action item text
   - `description`: **Detailed description with full context.** The tracker is the single source of truth — include requirements, research findings, decision rationale, relevant quotes, and any context needed to work the issue.
   - `project`: Match to an existing project if applicable
   - `assignee`: "me"
   - `priority`: Map from context (1=Urgent, 2=High, 3=Normal, 4=Low)
   - `labels`: Appropriate labels (Setup/Config, Feature, Maintenance, Research, Documentation, etc.)
   - `state`: "Todo"

2. **Sub-issues**: Set `parentId` to the parent issue identifier (e.g., "GLX-12")

3. **Related issues**: Use `relatedTo` when issues are connected but not parent-child

4. **Don't manually list child issues in the parent's description** — the tracker's sub-issue panel already shows the tree, and a hand-maintained list goes stale.

### 4e. After Creating

1. **Log to the brand-level changelog** (see Changelog Logging in Section 3 — brand-level path, prepend newest-first):
   ```markdown
   ## YYYY-MM-DD — [Context]
   - **[ID] [Issue Title]**
     - Created new issue, Priority: [priority], assigned to current cycle
   ```

2. **Update the action item** in the source file with the link:
   ```markdown
   - [ ] Task description ([ACME-12](https://linear.app/[your-workspace]/issue/ACME-12))
   ```

---

## 5. Before Finishing

Before completing the workflow:

1. **Memory updates**: If you keep long-lived memory/context files, verify they've been updated to reflect new project status, decisions, or relationship changes.

2. **Changelog verification**: Confirm that ALL tracker changes made during this workflow have been logged to the appropriate brand-level changelog file, **prepended newest-first**. This is the version-controlled audit trail used to verify Claude's tracker changes via `git diff`.

3. **Changelog integrity spot-check** (piggyback — no extra tracker calls): while the client's issues are already in hand from the Action Item Audit, glance at recent Claude-initiated issue activity vs. the changelog's newest entry. If changes postdate it with no covering entry, or an entry sits appended at the bottom instead of prepended, flag the gap in the run summary rather than silently backfilling.
