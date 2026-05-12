---
type: help
aliases:
  - Tags
tags: []
---
# Tags

← [[help/index|Help]]

## Type Values

| Value | Notes |
|-------|-------|
| `daily` | Daily note |
| `meeting` | Meeting note |
| `notecard` | Kanban card |
| `help` | Vault documentation |
| `transcript` | Raw meeting or audio transcript |

## AI Provenance Property

The `ai_status` property marks AI-touched notes. It is **never** present on human notes or templates.

| Value | Meaning |
|-------|---------|
| `draft` | Written by AI, not yet reviewed by a human |
| `reviewed` | Human has reviewed and approved the note |

Human-facing bases filter to "ai_status not set" so AI drafts don't pollute trusted views. See [[help/ai-provenance-conventions]] for the full convention.

## Tag Reference

| Tag | Use for |
|-----|---------|
| `work` | Job or professional projects |
| `personal` | Personal life, relationships |
| `side-project` | Hobby or side projects |
| `health` | Fitness, medical, mental health |
| `finance` | Money, budgeting, investments |
| `learning` | Books, courses, skill-building |
| `travel` | Trip planning or travel notes |
| `home` | House, maintenance, purchases |
| `idea` | Loose thought to revisit |
| `reference` | Something to look up again |
| `decision` | A choice made and why |
| `follow-up` | Needs action later |
| `ai/draft` | Applied by AI skills to unreviewed notes |
