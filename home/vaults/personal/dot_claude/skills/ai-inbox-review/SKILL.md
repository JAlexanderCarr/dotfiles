---
name: ai-inbox-review
description: List AI draft notes awaiting review and suggest promotion candidates. Use when the user asks to review the AI inbox, see what's pending, or check what AI has drafted.
---

**When to use this skill:** The user wants to see what's in the AI inbox and decide what to promote or discard.

**Before doing anything**, read `CLAUDE.md` at the vault root.

### What to do

1. Scan `ai/inbox/` for all `.md` files with `ai_status: draft`.
2. For each file, output a one-line summary:
   ```
   ai/inbox/YYYY-MM-DD-slug.md — <type> — <one-sentence description> — generated <ai_generated date>
   ```
3. If `ai/inbox/` is empty, say so and stop.

### Suggest promotion candidates

After listing, identify notes that look ready for promotion (have full frontmatter, non-empty body, clear action items or summary). Mark them with `→ ready to promote`.

Notes that may need human attention first (incomplete frontmatter, unclear content, unresolved `[[links]]` to unknown entities) should be flagged with `→ needs review`.

### What not to do

- Do not read or summarize notes outside `ai/`. This skill is scoped to the inbox.
- Do not modify any files. This skill is read-only.
- Do not promote notes. That's the `promote-ai-note` skill.
