---
type: help
aliases:
  - Templates
tags: []
---
# Templates

← [[help/index|Help]]

## Available Templates

Templates are provenance-neutral — they carry no `ai_status` field and can be used by both humans and AI skills. When an AI skill creates a note, it stamps `ai_status: draft` programmatically at write time; the template itself stays clean.

| Template | File | Type | Purpose |
|----------|------|------|---------|
| Daily | `templates/daily.md` | `daily` | Tasks, notes, and journal for a single day. Stored in `notes/daily/`. |
| Meeting | `templates/meeting.md` | `meeting` | Attendees, agenda, notes, and action items for a meeting. |
| Notecard | `templates/notecard.md` | `notecard` | Self-contained topic card for the Kanban board in `boards/notecards/`. |
