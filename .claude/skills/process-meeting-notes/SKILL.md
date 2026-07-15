---
name: process-meeting-notes
description: "Turn meeting transcripts into structured client files — extracts decisions, action items, and opportunities, then updates Decision Log, Opportunity Backlog, Tech Stack, and project files. Use this after any client call, when processing meeting backlog, or whenever the user mentions transcripts or meeting notes. Even if the user just says 'process meetings' or 'catch up on calls', this is the right skill."
effort: max
# Swap these for your own transcription service / issue tracker / calendar MCP servers
allowed-tools: Read, Write, Edit, Glob, Grep, mcp__claude_ai_Fireflies, mcp__claude_ai_Linear, mcp__claude_ai_Google_Calendar
hooks:
  Stop:
    - hooks:
        - type: command
          command: "bash \"$CLAUDE_PROJECT_DIR/.claude/skills/process-meeting-notes/scripts/validate-output.sh\""
          statusMessage: "Validating processed meeting notes..."
---

# Process Meeting Notes

Process meeting notes for a client and update relevant files.

> **Setup:** this skill assumes a transcription service and an issue tracker connected over MCP. Tool names below (`fireflies_get_transcripts`, `fireflies_get_transcript`, `list_issues`, `save_issue`, `save_comment`, `list_comments`, `list_events`) are from the original system — swap them for yours. Replace `[Your Name]` throughout with your actual name.

## Accuracy Rules

For the full strategy reference, see `.claude/references/accuracy-rules.md`. This skill applies: **direct quotes**, **iterative refinement**, and **external knowledge restriction**.

- **Extract word-for-word quotes** from transcripts for decisions and action items before summarizing — this prevents drift between what was said and what gets recorded
- **Only use information from the transcript and existing client files** — do not supplement with general knowledge about clients or their business
- **Verify extraction against the source** — after extracting decisions and action items, re-read the transcript to confirm nothing was missed or misattributed
- If something is unclear in the transcript, flag it as uncertain rather than guessing

## Instructions

You are processing meeting notes. The user may provide notes via:
1. An open file in the editor
2. Pasted content in the chat
3. **Nothing provided** — automatically fetch from the transcription service

### Step 0: Cross-Reference First

Start here to avoid duplicate processing. A meeting processed twice creates conflicting records, wastes time, and generates git noise. Before anything else, perform deduplication:

1. Read `System/meetings-sync-state.json` for `last_processed_meeting_date` (if the file doesn't exist, create it with the date set to 14 days ago). Fetch recent meetings with `fireflies_get_transcripts` using **`fromDate` set to one day before `last_processed_meeting_date`** (the one-day overlap protects the boundary; the cross-reference below dedupes it). Do NOT use a fixed `limit` as the primary window — a count-based window silently misses meetings during busy weeks.

2. Scan ALL markdown files for `transcript_url` fields:
   ```
   Grep: transcript_url:
   Path: (entire vault folder)
   ```
   This catches client notes in `Clients/`, general notes in `Meeting Notes/`, and any other location.

3. Match each meeting to the vault by **date + client**, not just the `transcript_url` string — a handled meeting may have a note that never got the URL recorded, and an upcoming meeting may already have a seeded prep file. Both should be skipped, not flagged as "unprocessed." For each recent meeting:
   - Detect the client (title keywords + attendee domains; see `.claude/references/client-mappings.md`).
   - Glob that client's `Meeting Notes/` folder (and the general `Meeting Notes/`) for a file whose name starts with the meeting's date (`YYYY-MM-DD`); confirm it's the same meeting via attendees/title.
   - Classify the matched file:
     - Has a `transcript_url` **or** a populated `## AI Notes` section → **Processed** — skip.
     - Prep file (`prep_status: seeded`/`ready`, no transcript_url, empty AI Notes) **and the meeting date is in the future** → **Upcoming (prep only)** — skip; it's a scaffold, nothing to process yet.
     - Prep file with no transcript_url / empty AI Notes **and the meeting has already happened** → **Needs processing** — this is the real target: merge the transcript into the existing prep file (round it out), do **not** create a duplicate.
     - No matching file → **Unprocessed** — create a new note.

4. Build a cross-reference table: meeting ID · date/title · matching note file (if any) · Status (**Processed** / **Upcoming (prep only)** / **Needs processing** / **Unprocessed**).

5. Present the meetings grouped by status. Only **Needs processing** + **Unprocessed** are actionable; list **Upcoming (prep only)** separately so it's clear they're future prep, not missed work:
   ```
   Cross-referenced 10 meetings with existing notes.

   ## Already Processed (X)
   - 2026-06-09 Acme Weekly → 2026-06-09 Weekly Call.md

   ## Upcoming — prep file only, not yet happened (Z) — skipped
   - 2026-07-09 Globex Bi-Weekly → 2026-07-09 Globex Bi-Weekly Call.md

   ## To Process (Y)

   | # | Date | Title | Duration | Client | Existing file |
   |---|------|-------|----------|--------|---------------|
   | 1 | 2026-06-03 | Globex/Initech Call | 33 min | Globex - Initech | new |
   | 2 | 2026-06-30 | Acme Collections Call | 110 min | Acme Outdoors | 2026-06-30 … (prep — round out) |

   Which would you like to process? (numbers, client name, "all", or "skip")
   ```

**If all meetings are processed:** Report "All meetings have been processed!" and exit.

**If user provides a file path or pastes content:** Still verify it's not already processed, then skip to Step 1.

### Step 0.5: Process Selected Meetings

For selected meetings:
- Fetch the full transcript using `fireflies_get_transcript` (not just the summary). The summary can bury nuance, and summaries sometimes misattribute decisions to the wrong person or context.
- Use the transcript to extract accurate information for client files.
- The service's own summary is helpful for quick reference, but the full transcript is essential to accurately extract decisions, action items, and opportunities.

---

## Step 1: Identify the Client and Brand(s)

For client detection logic, folder structure, and meeting organization, consult `.claude/references/client-mappings.md`.

For multi-brand clients, determine which brand(s) were discussed:
- Read the meeting title and transcript
- Identify which brand's products/site/issues were discussed
- A single meeting may cover multiple brands

**Examples:**
- "Globex x [Your Company] Monthly Call" discussing Initech products → Update both Globex and Initech files
- "Globex/Initech Call" → Check transcript to see which brand(s) were the focus

---

## Step 2: Read Current State and Create Meeting Note

1. **Read client files** per `.claude/references/update-client-files.md` Section 1.

2. **Read the full transcript** using `fireflies_get_transcript` to extract accurate information. Skipping the full transcript is the most common source of missed details and inaccurate summaries.

3. **Create or update meeting note file.** For templates and formatting rules, consult `.claude/skills/process-meeting-notes/references/meeting-templates.md`.

Save to: `Clients/[Client Folder]/Meeting Notes/YYYY-MM-DD [Topic].md`

**Section order in meeting notes (always follow this order):**

1. **Prep Notes** — context gathered before the meeting (work completed, open items, notes for the call). Pre-populated by a prep skill if you have one; should remain at the top.
2. **Topics & Real-Time Notes** — notes taken during the meeting by hand.
3. **Client Status Update (for Slack to [Recipient])** — the prioritized bullet list to send the client post-call. Generated by the `client-status-update` skill (auto-invoked in Step 5.5).
4. **AI Notes** — summary, key topics, action items, decisions, and opportunities extracted from the transcript. This section is always last.

When updating an existing meeting note file, add the AI Notes section after Topics & Real-Time Notes (and after the Client Status Update once it's generated). Do not move Prep Notes below other sections.

---

## Step 3: Analyze and Extract from Full Transcript

Read the full transcript to extract the information below. Summaries are a starting point but miss context, tone, and nuance needed to make accurate client decisions.

**Decisions Made:**
- Technical choices (platform, apps, architecture)
- Strategic decisions (priorities, timelines, approach)
- Client preferences or requirements confirmed
- Rejected alternatives discussed
- **Note which brand each decision applies to**

**Results & Feedback:**
- Metrics mentioned (conversion, revenue, traffic)
- Client feedback on previous work
- Before/after comparisons
- Testimonial-worthy quotes

**Opportunities:**
- Ideas discussed but not committed to
- Pain points mentioned
- Competitive observations
- Process improvement suggestions

---

## Step 4: Update Client Files and Push to the Tracker

Follow `.claude/references/update-client-files.md` Sections 2–5:
- **Section 2**: Update brand files (Decision Log, Results Tracker, Opportunity Backlog, Tech Stack, Client Profile, Conversion Benchmarks, Competitors)
- **Section 3**: Push findings to relevant issues (descriptions and comments)
- **Section 4**: Create issues for your action items (ask before creating)
- **Section 5**: Changelog verification and memory updates

---

## Step 4.5: Action Item Audit (MANDATORY — DO NOT SKIP)

**This step is a hard gate.** Do NOT proceed to the summary until this is complete.

Before moving to Step 5, you MUST:

1. **List every action item [Your Name] committed to** on the call — extract from the transcript, not from memory
2. **Fetch all open issues** for this client using `list_issues`. For any issue that looks like a candidate match for an action item, **also pull its comments via `list_comments`** — most substantive updates (status notes, blockers, decisions, follow-up findings) live in comments, not descriptions. Skipping them will cause duplicate issues to be created or "Update needed" cases to be miscategorized.
3. **Cross-reference each action item** against the open issues list. For each item, classify as:
   - **Covered** — an existing issue already handles this (note the issue ID)
   - **New** — no existing issue covers this → must be created
   - **Update needed** — an existing issue covers it but needs a description update or comment
   - **Already done (verified)** — the commitment was fulfilled between the meeting and now; cite the evidence

   **Scheduling commitments get a calendar check.** For action items that are calendar work (send an invite, schedule a recurring call, book a follow-up), check the calendar (`list_events`, read-only) for a matching event **before** classifying — the invite often goes out minutes after the call, and a dead-on-arrival issue is noise. If the event exists, classify as Already done (verified).
4. **Present the full audit table** to the user:

```
## Action Item Audit — [Meeting Name]

### Already covered by existing issues
- "Configure the gift-with-purchase app" → ACME-19 (no update needed)
- "Product spec table setup" → ACME-26 (description updated with "collapsible on mobile" decision)

### New issues to create
1. "Train client team on editing size guide metaobjects" → High priority, standalone
2. "Remove discontinued collection from navigation" → Medium priority, quick fix

### Skipped (not [Your Name]'s action items)
- "Client to reach out to their fulfilment vendor" — client action item
```

5. **Wait for approval** before creating the new issues
6. **Create all approved issues** with detailed descriptions per `update-client-files.md` Section 4
7. **Write the audit receipt to the per-client changelog.** This is what the Stop hook validates — if it's missing, the skill cannot complete. Format:

```markdown
### Action Item Audit
- Action items extracted: [N]
- Covered by existing issues: [X] ([issue IDs])
- New issues created: [Y] ([issue IDs])
- Existing issues updated: [Z] ([issue IDs])
```

This section MUST appear in the changelog entry for this meeting. The Stop hook checks for the literal string `### Action Item Audit` in a recently modified changelog file. Without it, the skill is blocked from completing.

**Every actionable item you committed to must end up in the tracker.** If it's not there, it doesn't get done. This is mission critical.

---

## Step 4.6: Results Capture (MANDATORY — DO NOT SKIP)

**This step is a hard gate.** Do NOT proceed to the summary until this is complete.

Action items capture what you *owe*. This step captures what you *delivered* — the raw material for every future case study. It was previously a single bullet in Step 4 and got silently skipped for months, which is why it is now gated exactly like the Action Item Audit.

Follow the **Results Capture** spec in `.claude/references/update-client-files.md` Section 2. In short:

1. **Sweep the transcript** for all four categories — metrics, shipped work, client praise, process outcomes. Extract praise **verbatim**; a casual "that's perfect" in passing is testimonial material and is exactly what gets lost.
2. **Update the brand's Results Tracker** — Quick Stats (outcomes only), Project Results (dated `###` entry, newest first), Testimonials (all quotes, consolidated).
3. **Write the receipt** to the same brand-level changelog entry as the Action Item Audit, directly below it:

```markdown
### Results Capture
- Metrics found: [N] ([brief] or "none")
- Project results added: [N] ([titles] or "none")
- Testimonials captured: [N] ([speakers] or "none")
- Results Tracker updated: [yes / no — nothing to capture this pass]
```

The Stop hook checks for the literal string `### Results Capture` in a recently modified changelog file. Without it, the skill is blocked from completing.

**A quiet call is a valid finding — silence is not.** If the meeting genuinely had no wins, praise, or metrics, write the receipt with "none" and move on. What is not acceptable is finishing the skill without having looked.

---

## Step 5: Summarize

**Update the sync state first:** write `System/meetings-sync-state.json` with `last_processed_meeting_date` set to the date of the newest meeting processed **or verified as already processed** this run. This is what the next run's `fromDate` window is built from.

After processing (including the action item audit and issue creation), provide a summary:
- Meeting note file created/location
- Which brand files were updated and what was added
- **Issues created** (with links), noting any sub-issue relationships
- **Existing issues updated** (comments or description changes)
- **Skipped issues** (already existed, no update needed)
- Any follow-up actions identified
- Remaining unprocessed meetings (if batch processing)

---

## Step 5.5: Generate Client Status Update

After Step 5's summary and before moving on, invoke the `client-status-update` skill via the Skill tool. Pass the just-processed meeting note path. The skill produces the prioritized bullet list (Done / In Progress / Coming Up / Backlog) to send the client post-call, and inserts it as a top-level `## Client Status Update` section in the meeting note **between Topics & Real-Time Notes and AI Notes**.

This runs automatically for every processed meeting — every successful pass through this skill ends with a ready-to-send message. If processing multiple meetings in one batch, run `client-status-update` once per meeting (right after that meeting's audit and summary), not once at the end of the batch.

---

## Step 6: Confirm Before Next Meeting

If processing multiple meetings, ask before continuing to the next one:

```
Completed: [Meeting Name]
Files updated: [list]
Issues created: [count]
Project files created/updated: [list]

Continue with next meeting: [Next Meeting Name]? (y/n)
```

Wait for confirmation before moving on. This prevents context overflow and ensures quality work.

---

## File Locations

| Meeting Type | Location |
|--------------|----------|
| Client meeting | `Clients/[Client Folder]/Meeting Notes/` |
| General/vendor | `Meeting Notes/` |

---

## Deduplication Reference

The `transcript_url` field contains the meeting ID from the transcription service. Example:
- `transcript_url: https://app.fireflies.ai/view/01ABCDEFGHIJKLMNOPQRSTUVWX`
- The ID is: `01ABCDEFGHIJKLMNOPQRSTUVWX`

A meeting is already processed if this ID appears in any existing meeting note's frontmatter.

---

## Usage

```
/process-meeting-notes
```
(Auto-fetches and shows unprocessed meetings)

```
/process-meeting-notes [path-to-meeting-note]
```
(Process a specific file)

Or paste the meeting content directly after invoking the command.

---

## Examples

**Auto-fetch mode:**
```
/process-meeting-notes

> Found 3 unprocessed meetings:
> 1. [2026-06-03] Globex/Initech Call - 33 min (Client: Globex - Initech)
> 2. [2026-05-25] Acme Weekly Call - 88 min (Client: Acme Outdoors)
> 3. [2026-05-24] Vendor Demo Call - 18 min (Client: no match — will ask)
>
> Which would you like to process?
```

**Specific file:**
```
/process-meeting-notes Clients/Acme Outdoors/Meeting Notes/2026-06-03 Q1 Planning.md
```
