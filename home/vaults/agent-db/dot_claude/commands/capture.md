Add a timestamped note to the Inbox folder in this vault.

Usage: /capture <note content>

Create a new file at `Inbox/YYYY-MM-DD-HHmm.md` with this structure:

```markdown
---
id: YYYYMMDDHHmm
type: capture
created: YYYY-MM-DD
tags: []
status: inbox
---

# Capture — YYYY-MM-DD HH:mm

<provided content>
```

If no content is provided, create an empty capture note and report the path.
