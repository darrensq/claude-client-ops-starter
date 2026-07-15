# Meeting Note Templates

Templates and formatting rules for meeting notes.

## Create or Update Meeting Note File

Save to: `Clients/[Client Folder]/Meeting Notes/YYYY-MM-DD [Topic].md`

### If the user has already created a note file (COMMON CASE)

The user typically creates meeting notes before the call with prep notes and takes real-time notes during the call. Look for existing files matching the meeting date and client.

**CRITICAL RULES:**
1. **NEVER modify anything above `# AI Notes`** — the user's manual notes are sacred
2. **Complete empty frontmatter fields** (date, attendees, duration, transcript_url) from the transcription service data
3. **Replace everything below `# AI Notes`** with AI-generated content from the transcript

**Section order (always follow this order):**
1. **Prep Notes** — context gathered before the meeting (first, at the top)
2. **Topics & Real-Time Notes** — notes taken during the call (second)
3. **AI Notes** — AI-generated summary, action items, decisions (always last)

**Expected user format:**
```markdown
---
tags:
  - meeting-notes
  - [brand-tag]
date: YYYY-MM-DD
attendees:
  - Name 1
  - Name 2
duration: X minutes
transcript_url: https://app.fireflies.ai/view/[ID]
---

# [Meeting Title]

## Prep Notes
[User's prep notes - NEVER MODIFY]

## Topics & Real-Time Notes
[User's notes during call - NEVER MODIFY]

# AI Notes

[Everything below this line gets replaced with AI-generated content]
```

**AI-generated content to add below `# AI Notes`:**
```markdown
# AI Notes

---

### Summary
[2-3 sentence overview from transcript]

---

### Key Topics

#### [Topic 1]
- Key points
- Details discussed

#### [Topic 2]
- Key points

---

### Action Items

**[Your Name]**
- [ ] Action item 1
- [ ] Action item 2

**[Client Name]**
- [ ] Action item 1

---

### Decisions Made

| Decision | Context |
|----------|---------|
| Decision 1 | Why/context |

---

### Opportunities Identified

- Opportunity 1
- Opportunity 2
```

### If creating a new note from scratch

Follow the same section order. Prep Notes and Topics & Real-Time Notes will be empty since no one took notes before/during the call.

```yaml
---
tags:
  - meeting-notes
  - [brand-tag-1]
  - [brand-tag-2]  # if multiple brands discussed
date: YYYY-MM-DD
attendees:
  - Name 1
  - Name 2
duration: X minutes
transcript_url: https://app.fireflies.ai/view/[TRANSCRIPT_ID]
brands_discussed:
  - [Brand 1]
  - [Brand 2]  # if applicable
---

# [Meeting Title]

## Prep Notes



## Topics & Real-Time Notes

-

# AI Notes

---

### Summary
[2-3 sentence overview from transcript]

---

### Key Topics

#### [Topic 1]
- Key points
- Details discussed

#### [Topic 2]
- Key points

---

### Action Items

**[Your Name]**
- [ ] Action item 1
- [ ] Action item 2

**[Client Name]**
- [ ] Action item 1

---

### Decisions Made

| Decision | Context |
|----------|---------|
| Decision 1 | Why/context |

---

### Opportunities Identified

- Opportunity 1
- Opportunity 2
```
