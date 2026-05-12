# Personal Vault — Rules of Engagement

This file is the source of truth for how Claude operates inside the `personal/` vault. Read it before taking any action.

---

## Directory structure

| Directory | Purpose | Who writes |
|-----------|---------|------------|
| `notes/daily/` | Daily notes | Human only |
| `notes/meetings/` | Human meeting notes | Human only |
| `ai/inbox/` | Fresh AI output, unreviewed | Claude writes; human reviews |
| `ai/meetings/` | AI meeting notes (reviewed or awaiting) | Claude writes; human promotes |
| `ai/transcripts/` | Raw transcripts | Claude writes |
| `templates/` | Provenance-neutral templates | Human only |
| `bases/` | Bases views | Human only |
| `boards/`, `canvases/` | Visual boards | Human only |
| `help/` | Vault documentation | Human only |

---

## Hard rules

1. **Write only under `ai/`.** Never create or edit files in `notes/`, `help/`, `templates/`, `bases/`, `boards/`, or `canvases/`.
2. **Required frontmatter on every AI file:**
   ```yaml
   ai_status: draft
   ai_model: <model-id>
   ai_source: <path or description of input>
   ai_generated: <ISO 8601 timestamp>
   ```
3. **File naming:** `YYYY-MM-DD-<slug>.md` for all AI-created files.
4. **Wikilinks:** Use existing `[[wikilinks]]` for known people and projects found in `notes/`. Do not create entity pages. If a person or project is unknown, surface it inline for the human to resolve.
5. **Never self-promote.** Flipping `ai_status` from `draft` to `reviewed` and adding `ai_reviewed_date` is a human action, performed via the `promote-ai-note` skill on explicit human confirmation.
6. **Retain all `ai_*` frontmatter after review.** `ai_model`, `ai_source`, and `ai_generated` stay on the note permanently for audit purposes.

---

## Skills available in this vault

| Skill | Trigger |
|-------|---------|
| `meeting-notes` | Draft a meeting note from a transcript or pasted text |
| `ai-inbox-review` | List draft notes in `ai/inbox/` and suggest promotion candidates |
| `promote-ai-note` | Promote a reviewed note from `draft` to `reviewed` status |

Each skill file has its own detailed instructions. When a user invokes a skill, read the corresponding `SKILL.md` before proceeding.
