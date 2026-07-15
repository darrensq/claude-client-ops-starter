---
name: client-status-update
description: "Generate a prioritized client status update message in the standard format (Done / In Progress / Coming Up / Backlog) based on issue tracker state and the most recent client meeting. Inserts the message into the meeting notes file as a top-level section between Topics & Real-Time Notes and AI Notes. Use after processing a client meeting (auto-invoked by /process-meeting-notes), or when the user asks for a 'status update', 'priority list', 'biweekly summary', or anything that maps to the bullet list pattern sent to clients post-call."
effort: medium
# Swap for your own issue tracker MCP server
allowed-tools: Read, Write, Edit, Glob, Grep, mcp__claude_ai_Linear
---

# Client Status Update

Generate a prioritized status update message for a client, based on issue tracker state plus the most recent meeting. Inserts it into the meeting notes file under a `## Client Status Update` section. Output the message inline for easy copy/paste into Slack or email.

## When to Use

- **Auto-triggered** at the end of `/process-meeting-notes` — generates the status update for the just-processed meeting
- **Manually invoked** with `/client-status-update [client name]` or `/client-status-update [meeting note path]`
- When the user asks for a "status update", "priority list", "biweekly summary", or anything that fits the post-call bullet list pattern

## Output Format

Two numbered lists:

1. **Done** — completed since the previous meeting. Numbered 1 through N.
2. **In Progress + Coming Up + Backlog** — share **continuous numbering** starting at 1 in "In Progress" and continuing through Coming Up and Backlog.

```
**Done**
1. [item]
2. [item]
...

**In Progress**
1. [item]

**Coming Up**
2. [item]
3. [item]
...

**Backlog (as time allows)**
8. [item]
9. [item]
...
```

Numbering example: if Done has 5 items, In Progress has 1, Coming Up has 6, Backlog has 5 — Done numbers 1-5, then In Progress=1, Coming Up=2-7, Backlog=8-12.

## Instructions

### Step 1: Identify the Meeting and Client

If invoked from `/process-meeting-notes`, the meeting note path is the just-processed file.

If invoked manually:
- If the user gave a client name, find the most recent meeting note in `Clients/[Client Folder]/Meeting Notes/`
- If the user gave a path, use it
- If ambiguous, ask which client/meeting

Read the meeting note to identify the client. Get the tracker team name from `.claude/references/client-mappings.md` (Issue Tracker Team Mapping section).

### Step 2: Find the Previous Meeting

In the same `Meeting Notes/` folder, find the meeting note dated immediately before the current one. The date is in the filename (`YYYY-MM-DD ...`). This sets the "since" boundary for "Done" items.

If there's no prior meeting (first meeting for the client), use 14 days ago as the boundary.

### Step 3: Gather Issue State

Query the tracker for the client's team using `list_issues`:

- **Recently completed**: `state: "Done"`, filtered by `updatedAt: -P14D` or similar — then filter to issues completed since the previous meeting date
- **In Progress**: `state: "In Progress"`
- **Todo**: `state: "Todo"`, sorted by priority
- **Backlog**: `state: "Backlog"`, sorted by priority

Also pull anything completed during the just-processed meeting itself (decisions in the meeting note's AI Notes section often confirm work going live or being approved — these count as Done even if the tracker was just updated).

### Step 4: Categorize and Bundle

Apply judgment, not strict rules. The goal is a scannable list a non-technical stakeholder can read in 30 seconds.

**Bundling rules of thumb:**
- **Sub-issue families** → one parent line. E.g., ACME-21/22/23/24 all belong to the ACME-14 wholesale portal build — list as "Wholesale portal build."
- **Multiple small items in a single project** → bundle under the project name. E.g., 3 separate reviews-widget Todo items → "Reviews widget remaining quick wins (X, Y, Z)" instead of three lines.
- **Distinct projects** → keep separate.

**Skip:**
- **Meta tasks** like "Send the client the prioritized task list." They'd create a recursion. If you spot one, skip it silently.
- **Passive watches** like "Post-cutover monitoring (1 week)" unless they're imminent or notable.
- **Internal housekeeping** like Tech Stack updates or vault migrations — these are not client-facing work.

**Note inline (don't separate):**
- **Blocked / On Hold** — if a "Coming Up" item has a Blocked label or is paused, you may add a brief parenthetical note (e.g., "blocked on agency access"). Match the prior format — keep it short. If the prior format omitted these notes entirely, omit them.

**Title rewriting:**
Tracker titles are sometimes engineering-shorthand. Rewrite for clarity. E.g.:
- "Set up WS pricing metaobjects on wholesale store" → "Wholesale pricing metaobjects set up"
- "Fix or remove qty steppers on bundle product cards in upsell widgets" → "Fix quantity steppers on bundle product cards"

### Step 5: Apply the Numbering Convention

- **Done** items numbered 1 through N from scratch
- **In Progress** starts continuous numbering at 1
- **Coming Up** continues from where In Progress left off
- **Backlog** continues from where Coming Up left off

If a section is empty, omit it.

**Cap Backlog** at 5-7 items unless told otherwise — pick the highest-priority/oldest items, or whatever has been emphasized recently. The full backlog lives in the tracker.

### Step 6: Insert into Meeting Notes

Insert a new top-level section into the meeting note file **between `## Topics & Real-Time Notes` and `## AI Notes`**:

```markdown
## Client Status Update (for Slack to [Recipient Name])

[the formatted message]
```

Use a `##` heading (same level as Prep Notes / Topics & Real-Time Notes / AI Notes), not `###`. Use the recipient's first name if known — fall back to "client" if unsure.

If a `## Client Status Update` section already exists in the file (e.g., the skill was run before), replace it rather than appending a second copy.

### Step 7: Output Inline

Show the formatted message in the chat response so it's easy to copy. Note where it was inserted in the meeting note file.

## Format Reference Example

For a client meeting where 5 items completed since the prior call, 1 item is In Progress, 6 are coming up, and 5 are backlog:

```
**Done**
1. Gift card balance checker added to account page
2. Wholesale pricing metaobjects set up
3. Address form validation fix (allow apartment numbers)
4. Cart drawer totals fix on discounted bundles
5. Reviews platform migration

**In Progress**
1. Wholesale portal build

**Coming Up**
2. Set up client-owned analytics property and migrate historical data
3. Third-party app permission audit
4. Reviews widget remaining quick wins (star display, photo uploads)
5. Add colour filtering to collection pages
6. Replace legacy search app with native storefront search
7. Q2 accessibility improvements

**Backlog (as time allows)**
8. Increase flexibility of promo banner section
9. Fix quantity steppers on bundle product cards
10. Fix sticky header overlap on mobile
11. Fix footer link alignment
12. Fix order confirmation email formatting
```

## Notes

- Don't add extra commentary or context to the message itself — it's a scannable list.
- Don't include issue IDs in the message text. Internal vault linking is fine in the meeting note section header or surrounding text but not in the bullets themselves.
- If the previous meeting note also has a `## Client Status Update` section, use it as a reference for what was previously sent — items that were "Coming Up" last time and are now Done should appear under Done; items still Coming Up may stay there but with refreshed bundling.
