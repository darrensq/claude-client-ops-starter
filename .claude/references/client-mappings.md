# Client Mappings

Shared reference for client detection, folder structure, and issue-tracker mappings. Used by multiple skills.

> **CUSTOMIZE THIS FILE FIRST.** Every client below is a placeholder. Client detection does not work until this reflects your real clients. `Acme Outdoors` is an example single-brand client; `Globex - Initech` is an example multi-brand client (parent company with two brands).

## Client Folder Structure

```
Clients/
├── Globex - Initech/                 # Multi-brand client
│   ├── Globex/
│   │   ├── Client Details/
│   │   └── Issues/
│   ├── Initech/
│   │   ├── Client Details/
│   │   └── Issues/
│   └── Meeting Notes/                # Shared at client level
│
├── Acme Outdoors/                    # Single-brand client
│   ├── Client Details/
│   ├── Meeting Notes/
│   └── Issues/
│
└── Templates/                        # Source templates for new clients
```

**Key points:**
- Meeting notes go at the **client level** (shared across brands)
- Supporting files (Profile, Decision Log, Tech Stack, Results Tracker, Opportunity Backlog, Conversion Benchmarks, Competitors) are at the **brand level**
- **Projects folder** — long-lived project reference material (research, analysis, proposals, assets) lives in `[Brand]/Projects/[Project Name]/`. These are NOT issue docs — they are reference material that spans multiple issues
- **Linear Changelog** — **brand-level** audit trail of Claude-initiated tracker changes, matching the per-brand tracker teams: single-brand clients at `Clients/[Client]/Linear Changelog.md`; multi-brand clients at `Clients/[Client Folder]/[Brand]/Linear Changelog.md` (one per brand — no combined client-level changelogs; create the brand file if missing). Entries are prepended newest-first
- **Issues folder** — optional. If you keep issue context in your tracker rather than in the vault, don't create vault issue docs at all
- When processing meetings, update the appropriate brand's files based on discussion topics
- Templates for all client files live in `Clients/Templates/` — use them when creating new files for a client

## Client Detection — Title Keywords

Matched against the meeting title. Include misspellings and how people actually talk about the client.

| Keywords in Title | Client Folder | Primary Brand(s) |
|-------------------|---------------|------------------|
| "Acme", "Acme Outdoors" | Acme Outdoors | Acme Outdoors |
| "Globex", "Initech" | Globex - Initech | Globex, Initech |

## Client Detection — Email Domains

Matched against attendee email addresses. More reliable than title keywords when both are available.

| Domain | Client Folder | Brand |
|--------|---------------|-------|
| `@acmeoutdoors.example.com` | Acme Outdoors | Acme Outdoors |
| `@globex.example.com` | Globex - Initech | Globex |
| `@initech.example.com` | Globex - Initech | Initech |

## No Match Found — ALWAYS ASK

If participants don't match any existing client:

```
This meeting with [Company/Attendees] doesn't match any existing client.

Options:
1. Save to general Meeting Notes folder (Meeting Notes/)
2. Create a new client folder for [Company Name]

Which would you prefer?
```

**Do NOT automatically assume** vendor calls or training sessions go to general — let the user decide.

## Slack Channel Mapping (optional)

Only needed if you also sync Slack. Mark archived channels rather than deleting the row — it documents why a channel stopped appearing.

| Channel | Workspace | Client Folder | Brand(s) |
|---------|-----------|---------------|----------|
| `#acme` | Your Workspace | Acme Outdoors | Acme Outdoors |
| `#globex-initech` | Your Workspace | Globex - Initech | Globex, Initech |
| ~~`#old-channel`~~ | Your Workspace | Acme Outdoors | **Archived YYYY-MM-DD** (reason; exclude from sync) |

**Notes:**
- For multi-brand channels, use brand keywords from the Client Detection table to determine which brand a message relates to
- Note the workspace when a channel lives somewhere other than your primary one (shared/Connect channels)

## Slack DM Mapping (optional)

| Contact | Slack User ID | DM Channel ID | Client Folder | Brand |
|---------|---------------|---------------|---------------|-------|
| Example Contact (contact@acmeoutdoors.example.com) | U000EXAMPLE01 | D000EXAMPLE01 | Acme Outdoors | Acme Outdoors |

**DM search syntax:** Use `in:<@USER_ID>` with `slack_search_public_and_private` (channel_types: "im"). Email-based and name-based searches do not work for external/Connect users.

Add a note under this table for any contact whose signal needs context — e.g. an external contractor who isn't client staff but whose messages carry project signal.

## Slack Sync Settings (optional)

| Setting | Value |
|---------|-------|
| Default lookback | 72 hours |
| Min message length | 20 chars |
| Action keywords | "can you", "please", "need", "by Friday", "next week", "ASAP", "let's do", "approved", "confirmed", "go with", "decided" |

## Issue Tracker Team Mapping

One team per brand. This is what `save_issue` needs.

| Client / Brand | Tracker Team |
|--------|-------------|
| Acme Outdoors | Acme Outdoors |
| Globex | Globex |
| Initech | Initech |
| General / internal | Internal |

**Note:** Check `list_teams` if unsure — new teams may have been added since this mapping was written.

## Obsidian Link Format

When creating internal section links, use Obsidian wiki-link format:

```markdown
# Correct (Obsidian wiki-link):
| [[#Example App - Product Personalization|Example App]] | Product Personalization | Active |

# Incorrect (standard markdown anchor - breaks in Obsidian):
| [Example App](#example-app---product-personalization) | Product Personalization | Active |
```
