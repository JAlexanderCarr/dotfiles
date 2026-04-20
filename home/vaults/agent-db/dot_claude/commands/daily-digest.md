Generate a daily digest of today's sessions and decisions.

Usage: /daily-digest

1. Find all notes in `Sessions/` and `Decisions/` created or modified today.
2. Summarize each session (goal, outcome) and each decision (context, decision made) in 1-2 sentences each.
3. Write the digest to `Inbox/Digest-YYYY-MM-DD.md` with this front-matter:
   ```yaml
   ---
   id: YYYYMMDDHHmm
   type: digest
   created: YYYY-MM-DD
   tags: []
   status: active
   ---
   ```
4. Report the output path when done.
