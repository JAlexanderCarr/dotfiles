---
name: promote-ai-note
description: Promote a reviewed AI note from draft to reviewed status. Updates ai_status, adds ai_reviewed_date, and optionally moves the file. Use when the user confirms a note is ready to promote.
---

**When to use this skill:** The user has reviewed an AI draft and wants to mark it as reviewed (and optionally move it out of `ai/inbox/`).

**Before doing anything**, read `CLAUDE.md` at the vault root.

### Input

Accept a file path under `ai/` (e.g. `ai/inbox/2026-05-11-standup.md`). If not provided, ask.

### Steps

1. **Read the note** and display a brief summary (type, date, one-sentence description) so the user can confirm they have the right file.
2. **Ask the user:**
   - Confirm promotion (yes/no).
   - Destination: keep in `ai/inbox/` (default: move to `ai/<type>/`), or move to `notes/<type>/` if they want it in the human-trusted view.
3. **On confirmation:**
   - Flip `ai_status: draft` → `ai_status: reviewed`.
   - Add `ai_reviewed_date: YYYY-MM-DD` (today's date) immediately after `ai_status`.
   - If moving: relocate the file to the chosen destination. Update the path in any notes the human has that link to it (ask before making link updates if the list is long).
   - Retain all `ai_model`, `ai_source`, and `ai_generated` fields — do not remove them.
4. **Report** the final location and the updated frontmatter fields.

### Hard rules

- Never flip `ai_status` without explicit human confirmation.
- Never remove `ai_model`, `ai_source`, or `ai_generated`.
- If the destination is `notes/`, remind the user that the note will now appear in the default trusted views (e.g. `bases/meetings.base`) since it loses its `ai_status` filter. Confirm this is intended.
- If the file doesn't exist or isn't under `ai/`, say so and stop.
