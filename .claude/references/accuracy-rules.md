# Accuracy Rules

Reference for reducing hallucinations and improving factual reliability. Consult this when building or running skills that process source material.

## Which strategies apply?

Not every strategy applies to every workflow. Use this matrix to determine which rules to follow based on what the skill is doing.

| Strategy | Applies when... | Example skills |
|---|---|---|
| Direct quotes | Extracting facts from long documents (transcripts, Slack threads, PDFs). Grounding claims in exact text prevents drift. | process-meeting-notes |
| Verify with citations | Synthesizing across multiple source files into a report or briefing. Citing sources makes the output auditable. | client-progress-report, daily-briefing |
| Iterative refinement | Multi-pass workflows where an initial extraction can be verified against the source in a second pass. Catches things the first pass missed. | process-meeting-notes (summary → transcript → verify) |
| External knowledge restriction | Processing user-provided or fetched data where the goal is to reflect what's there, not what you think should be there. Prevents hallucinating details that sound right but aren't in the source. | process-meeting-notes, client-progress-report |
| Admit uncertainty | Any workflow making claims about client data, timelines, or project status. Saying "I'm not sure" is better than a confident wrong answer. | All skills (also in CLAUDE.md) |
| Chain-of-thought verification | Non-trivial analysis or recommendations where reasoning could have faulty assumptions. Showing work lets the user spot errors. | All skills (also in CLAUDE.md) |

## Strategy details

### Direct quotes

Before summarizing or extracting from a long document (20k+ tokens), pull word-for-word quotes first, then build your summary from those quotes. This prevents the common failure mode where a summary drifts from what was actually said.

**How to apply:**
- Read the source document
- Extract relevant quotes verbatim (with enough context to be meaningful)
- Build your summary, decisions, and action items from those quotes
- If you can't find a supporting quote for a claim, drop the claim

### Verify with citations

When synthesizing information from multiple files into a report or briefing, note where each claim came from. This makes the output auditable — the user can trace any statement back to its source.

**How to apply:**
- For intermediate/working files: include source references inline (e.g., "per 2026-02-15 meeting", "from Clients/Acme Outdoors/Client Details/Acme Outdoors Decision Log.md")
- For client-facing deliverables: citations may be stripped from the final output, but the intermediate files should retain them
- If you can't find a source for a claim after generating it, retract it

### Iterative refinement

For multi-pass workflows, use the output of one pass as input for a verification pass. This catches inconsistencies and omissions.

**How to apply:**
- First pass: extract information from the source
- Second pass: re-read the source and verify your extraction is complete and accurate
- Flag anything in your extraction that doesn't match the source
- Flag anything in the source that your extraction missed

### External knowledge restriction

When processing provided documents, only use information from those documents and existing vault files. Don't supplement with general knowledge about clients, their products, or their industry — even if you're confident you know something, the point of these workflows is to reflect what's *documented*, not what you *assume*.

**How to apply:**
- Only state facts that appear in the source material
- If context is missing, leave it out rather than guessing
- If a stored context file is outdated, flag it as potentially stale rather than filling in gaps from general knowledge
- If asked about something not in the sources, say so explicitly

### Admit uncertainty

Say "I don't know" or "I'm not sure" rather than guessing. Flag confidence level when making claims about client data, timelines, or project status.

This is also a universal rule in CLAUDE.md — it's included here for completeness.

### Chain-of-thought verification

For non-trivial analysis or recommendations, explain reasoning step-by-step before stating conclusions. This surfaces faulty assumptions early and lets the user correct course.

This is also a universal rule in CLAUDE.md — it's included here for completeness.

## For skill creators

When building a new skill, ask yourself:
1. Does this skill extract information from documents? → Direct quotes, External knowledge restriction
2. Does this skill combine data from multiple files? → Verify with citations
3. Does this skill have multiple processing stages? → Iterative refinement
4. Does this skill make claims about client/project state? → Admit uncertainty

Add a line to the skill's SKILL.md pointing here: `For accuracy guidelines, consult .claude/references/accuracy-rules.md.`

Then include an "Accuracy Rules" section in the skill with the specific strategies that apply, written in the skill's own context. The strategies here are the *what* and *why* — your skill provides the *how* for its specific workflow.
