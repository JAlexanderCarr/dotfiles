# Agent-DB Vault

This vault is a structured knowledge base for use with Claude Code and Codex CLI. When working in this vault, follow the conventions below.

## Folder Layout

| Folder | Purpose |
|--------|---------|
| `Sessions/` | Agent session logs — one note per working session |
| `Decisions/` | Decision logs (ADR-style) for choices made during work |
| `Entities/` | People, projects, systems, and tools |
| `Research/` | Research notes with sources and summaries |
| `Prompts/` | Reusable prompt patterns |
| `Inbox/` | Unprocessed captures and quick notes |
| `Attachments/` | Images and files linked from notes |
| `Templates/` | Templater templates (do not store notes here) |

## Front-Matter Schema

Every note should have this front-matter:

```yaml
---
id: YYYYMMDDHHmm        # timestamp-based unique id
type: session|decision|entity|research|prompt|capture|digest
created: YYYY-MM-DD
tags: []
status: active|draft|inbox|archived
---
```

## Links

Use shortest-path wikilinks: `[[Note Title]]`, not markdown links. Aliases: `[[Note Title|Display Text]]`.

## Creating Notes

Use the Templater plugin: open the command palette → "Templater: Create new note from template" and pick the appropriate template from `Templates/`.

## Querying with Dataview

List all decisions:

```dataview
LIST FROM "Decisions" WHERE type = "decision" SORT created DESC
```

Active sessions:

```dataview
TABLE goal, status FROM "Sessions" WHERE status = "active" SORT created DESC
```

All inbox items:

```dataview
LIST FROM "Inbox" SORT file.mtime DESC
```

## Slash Commands

The `.claude/commands/` directory contains commands for use with `claude` CLI from this vault root:

- `/capture` — append a timestamped note to `Inbox/`
- `/search` — search the vault and summarize hits
- `/summarize` — summarize a note or folder into a Research Note
- `/link` — suggest wikilinks for the current note
- `/daily-digest` — roll up today's sessions and decisions

## Workflow

1. Start a working session: create a Session Log from the template.
2. Capture quick notes to `Inbox/` via `/capture` or the Templater template.
3. Promote inbox items to the appropriate folder once processed.
4. Link related notes using wikilinks.
5. Run `/daily-digest` at end of day to generate a rollup summary.

## Managed Configuration

The `.obsidian/` config files in this vault are managed by chezmoi. Changes made through Obsidian's UI (plugin toggles, hotkeys, settings) will be reverted on the next `chezmoi apply`. To make permanent changes, edit the source files in the dotfiles repo under `home/vaults/agent-db/dot_obsidian/` and re-apply.
