# Client Ops Skills — Starter Kit

A set of Claude Code skills for turning meeting transcripts into structured client records and tracked issues. Extracted from a working consulting system and genericized — every client name, contact, ID, and workspace URL in here is fake and meant to be replaced.

## What this does

You get off a client call. Instead of writing notes by hand and forgetting half the follow-ups, you run one command:

```
/process-meeting-notes
```

Claude fetches the transcript, figures out which client it was, writes a structured meeting note, updates that client's long-lived record files (decisions, results, opportunities, tech stack), cross-references every commitment you made against your issue tracker, and creates the ones that are missing. It ends by drafting the status message you send the client afterward.

The core idea worth stealing: **the pipeline from "someone said a thing on a call" to "it's a tracked issue" must not leak.** Everything else here is in service of that.

## The skills

| Skill | What it does |
|---|---|
| `process-meeting-notes` | The main pipeline. Transcript → meeting note → client file updates → issues. Auto-invokes `client-status-update` at the end. |
| `client-status-update` | Generates the prioritized Done / In Progress / Coming Up / Backlog list you send the client post-call. |
| `onboard-client` | Sets up a new client folder from templates, researches the company/competitors/benchmarks with parallel sub-agents, and registers the client in `client-mappings.md`. |

Plus three shared references the skills read at runtime:

| Reference | What it holds |
|---|---|
| `client-mappings.md` | **The file you must customize.** Client detection rules — title keywords, email domains, Slack channels, issue-tracker team mapping, folder layout. |
| `update-client-files.md` | How to read, extract, and write client record files. The bulk of the actual logic. |
| `accuracy-rules.md` | Anti-hallucination strategies and when each applies. Generic — useful outside this kit. |

## Install

Copy `.claude/` into the root of your vault or notes repo:

```bash
cp -r claude-client-ops-starter/.claude /path/to/your-vault/
```

Then merge `CLAUDE.md.example` into your own `CLAUDE.md` (or use it as a starting point if you don't have one).

Structure once installed:

```
your-vault/
├── CLAUDE.md
├── Clients/
│   ├── Templates/              ← you provide these (see below)
│   └── Acme Outdoors/
├── System/
│   └── meetings-sync-state.json   ← auto-created on first run
└── .claude/
    ├── references/
    └── skills/
```

## What you must change before this works

1. **`.claude/references/client-mappings.md`** — replace every placeholder client (Acme Outdoors, Globex, Initech) with your real ones. This is the file that makes client detection work. Nothing else functions correctly until this reflects reality. If you use `/onboard-client`, it appends new clients here for you.

2. **`Clients/Templates/`** — the skills copy from this folder and it isn't included here (the originals were full of real client data). You need to create these yourself. At minimum:
   - `Client Profile Template.md` — company overview table, background, key contacts, engagement details
   - `Decision Log Template.md` — a table: `| Date | Decision | Context | Outcome/Notes |`
   - `Results Tracker Template.md` — four sections: Quick Stats, Project Results, Testimonials, Before/After
   - `Opportunity Backlog Template.md` — High Impact table, Quick Wins checkboxes, Competitive Intel table
   - `Tech Stack Template.md` — Quick Reference table + detailed per-integration sections
   - `Conversion Benchmarks Template.md`, `Competitors Template.md`

   Each needs YAML frontmatter with `date_created` / `date_updated` at minimum — the validation hooks check for it.

3. **MCP servers** — the skills assume a transcription service and an issue tracker connected over MCP. The `allowed-tools` frontmatter and tool names in each SKILL.md use the originals (Fireflies, Linear, Google Calendar). Swap in whatever you use. Tool names appear in `allowed-tools`, and as `fireflies_get_transcript`, `list_issues`, `save_issue`, `save_comment`, `list_comments`, `list_events`.

4. **Your name** — search for `[Your Name]` across the skills. Action item extraction is built around separating *your* commitments from the client's.

5. **Issue tracker URL** — `https://linear.app/[your-workspace]/issue/` appears in a couple of places.

## Design decisions worth understanding

These are the parts that came from things going wrong, not from planning. They're the reason the kit works.

**Hard gates with Stop hooks.** `process-meeting-notes` declares a `Stop` hook that runs `scripts/validate-output.sh`. The script checks that a changelog file contains the literal strings `### Action Item Audit` and `### Results Capture`. If they're missing, the skill is blocked from completing and Claude gets told why. This exists because a step that's merely *documented* as mandatory gets skipped eventually — the results-capture step silently went unrun for months before it was gated. If a step in your workflow actually matters, gate it. Prose alone won't hold.

The script self-gates on recent activity (it only validates if a meeting note was touched in the last 60 minutes) because skill-declared Stop hooks persist for the rest of the session once loaded, and you don't want unrelated work tripping a meeting-notes validator.

**Deduplication before anything else.** Step 0 cross-references the transcription service against existing notes by **date + client**, not just by transcript URL. Matching on the URL alone misses notes that were written by hand or seeded as prep files. Processing a meeting twice creates conflicting records and is annoying to unwind.

**Full transcripts, not summaries.** The skill explicitly refuses to work from the transcription service's own summary. Summaries misattribute decisions to the wrong speaker and bury the offhand remarks that turn out to matter.

**Never auto-close issues.** Even when a transcript says "yeah that's shipped," the skill collects apparent-completions into a list and asks. Wrong status is worse than stale status.

**Verbatim quotes for praise.** A casual "oh that's perfect" in the middle of a call is testimonial material. It's also the first thing lost to summarization. The Results Tracker section insists on word-for-word capture.

**Changelog as audit trail.** Every issue-tracker change gets logged to a per-client `Linear Changelog.md` in the vault, prepended newest-first. Because the vault is a git repo, `git diff` shows exactly what Claude did to the tracker. This is how you trust the automation without reading every issue.

## Adapting it

The kit assumes an Obsidian vault under git, but nothing depends on Obsidian except the wiki-link formatting rules — it's all plain markdown in folders and works fine without it.

Start with `process-meeting-notes` alone against one client. Get detection and file updates right before adding the issue-tracker push. `onboard-client` is the last piece to bother with — it's the most opinionated and the easiest to write yourself once you know what your own client files should look like.

The `effort: max` frontmatter on two of the skills is deliberate — this work is judgment-heavy and cheap to get wrong.

## Credits

Built and maintained by **Darren Squashic** of [Traverse Design](https://traversedesign.com), a Shopify theme development and ecommerce consulting studio.

These skills were extracted from a live consulting system that runs on them daily. The design decisions above aren't hypothetical — the gates exist because the ungated versions failed in production.

Questions, issues, and pull requests welcome — open an issue on this repo. If you adapt this into something better, I'd genuinely like to hear about it.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, sell work built with it. No attribution required, though it's appreciated.
