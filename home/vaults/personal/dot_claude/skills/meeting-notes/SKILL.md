---
name: meeting-notes
description: Draft a meeting note from a transcript or pasted text. Writes to ai/inbox/ with full ai_* frontmatter. Use when the user asks to draft, write, or generate a meeting note.
---

**When to use this skill:** The user has provided a transcript file path or pasted meeting text and wants a structured meeting note drafted.

**Before doing anything**, read `CLAUDE.md` at the vault root. The summary below is a prompt, not the source of truth.

### Input

Accept either:
- A path to a transcript file (e.g. `~/recordings/2026-05-11-standup.m4a` or a `.txt`/`.md` transcript)
- Pasted text in the conversation

If neither is provided, ask the user before proceeding.

### Output location

Write to: `ai/inbox/YYYY-MM-DD-<slug>.md`

- Date is the meeting date, not today's date. Ask if ambiguous.
- Slug is a short kebab-case descriptor of the meeting (e.g. `standup`, `libdex-planning`).

### Required frontmatter

```yaml
---
type: meeting
date: YYYY-MM-DD
ai_status: draft
ai_model: <current model id>
ai_source: <file path or "pasted text">
ai_generated: <ISO 8601 timestamp of now>
tags: [ai/draft]
attendees: ["[[Name]]"]
project: "[[ProjectName]]"
---
```

- Use `[[wikilinks]]` for attendees and projects that exist in `notes/`. If unsure whether a page exists, use the name as a wikilink anyway — Obsidian will show it as unresolved.
- Do not create entity pages for unknown people or projects. Surface them inline as a note to the human.
- `project` is optional — omit if not applicable.

### Note body

Write in this order:

1. **Summary** — 2-4 sentences. What was discussed and decided.
2. **Attendees** — list from frontmatter (skip if already in frontmatter and obvious).
3. **Notes** — structured bullets of key discussion points.
4. **Action items** — checklist format (`- [ ] Owner: action`). Omit section if none.
5. **Open questions** — unresolved items for follow-up. Omit if none.

### Hard rules

- Write only to `ai/inbox/`. Never write to `notes/`, `help/`, `templates/`, or any other folder.
- Never set `ai_status: reviewed`. That is a human action.
- Never create entity pages for people or projects.
- If the transcript is empty or unintelligible, say so and stop. Do not invent content.
