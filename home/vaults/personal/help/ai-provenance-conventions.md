---
type: help
aliases:
  - AI Provenance Conventions
tags: []
---
# AI vs Human

← [[help/index|Help]]

This vault separates human-written and AI-generated content so each can be trusted on its own terms. The split is **soft isolation in a single vault** — wikilinks, graph, and Dataview keep working across the boundary.

## Why the split exists

AI output needs a review step before it's trusted. Mixing reviewed and unreviewed content in the same folder makes it impossible to know at a glance what's been verified. The `ai/` quarantine and `ai_status` field make provenance explicit without hiding AI output from the workflow.

## The `ai/` quarantine rule

AI writes **only** under `ai/`. It never creates or edits files in `notes/`, `help/`, `templates/`, `bases/`, `boards/`, or `canvases/`. This is enforced in `CLAUDE.md` at the vault root and in each skill.

```
ai/
  inbox/       — fresh AI output, unreviewed
  meetings/    — AI meeting notes (post-review stays here with ai_status: reviewed)
  transcripts/ — raw transcripts
```

## The `ai_status` property

`ai_status` is an optional frontmatter property present **only on AI-touched notes**. Human notes and templates never carry it.

| Value | Meaning |
|-------|---------|
| `draft` | Written by AI, not yet reviewed |
| `reviewed` | Human has reviewed and approved |

**Human note (from template — no `ai_status`):**
```yaml
---
type: meeting
date: 2026-05-11
tags: []
---
```

**AI note (written by a skill — never via template insertion):**
```yaml
---
type: meeting
date: 2026-05-11
ai_status: draft
ai_model: claude-opus-4-7
ai_source: ~/recordings/2026-05-11-standup.m4a
ai_generated: 2026-05-11T14:32:00
tags: [ai/draft]
attendees: ["[[Alex Carr]]"]
project: "[[Libdex]]"
---
```

**After human review:**
```yaml
ai_status: reviewed
ai_reviewed_date: 2026-05-12
```
The `ai_model`, `ai_source`, and `ai_generated` fields are retained — the audit trail survives permanently.

**Why `ai_status` and not `author`?** `author` is reserved for a future human-attribution use case (e.g., guest writers). Using a field specific to AI provenance prevents collision and keeps the two concerns separate.

**Why do templates omit it?** Templates are provenance-neutral so AI skills can reuse them. The skill stamps `ai_status: draft` programmatically at write time — the template itself stays clean and reusable.

## Linking conventions

- **AI → human**: encouraged. Use shortest-path wikilinks (`[[Alex Carr]]`, `[[2026-05-10]]`). They resolve normally.
- **Human → AI**: valid and encouraged for cross-reference (e.g., a human meeting note linking to its AI draft). Use folder-qualified links to avoid name collisions: `[[ai/meetings/2026-05-11-standup]]`.
- **Within `ai/`**: always folder-qualified (`[[ai/transcripts/2026-05-11-standup]]`).

Backlinks naturally show both directions; human ↔ AI cross-refs are part of the intended workflow.

## Views and filtering

The `bases/meetings.base` view filters to notes without `ai_status` set — so the default meetings view is human-only. AI drafts have their own view in `bases/ai-review.base`, sorted by `ai_generated` descending.

## Where rules are enforced

- **`CLAUDE.md`** (vault root) — hard write-boundary and required frontmatter rules
- **`dot_claude/skills/meeting-notes/SKILL.md`** — drafts meeting notes into `ai/inbox/`
- **`dot_claude/skills/ai-inbox-review/SKILL.md`** — lists draft notes and suggests promotion candidates
- **`dot_claude/skills/promote-ai-note/SKILL.md`** — human-confirmed promotion from draft to reviewed
