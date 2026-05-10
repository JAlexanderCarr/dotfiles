---
name: libdex-ingest
description: Process files dropped into the libdex vault inbox/ into atomic source notes. Use when the user asks to ingest, process the inbox, or convert clippings/PDFs/URLs into source notes.
---

**When to use this skill:** The user has dropped files into `inbox/` and wants them converted into clean source notes, or has provided a specific URL or file to ingest.

**Before doing anything**, read `CLAUDE.md` at the vault root for the full rules of engagement. The summary below is a prompt, not the source of truth.

### What to ingest

1. Check `inbox/` for anything unprocessed. Files can be:
   - Raw `.md` clippings from Obsidian Web Clipper
   - PDFs — extract text
   - Plain URLs in a `.md` file — fetch them
   - Pasted text — treat as an article

2. If the user provided a URL or path, ingest that specifically instead of scanning the inbox.

### For each item

1. **Normalise into a source note** at `sources/<Title>.md`. Title is Title Case of the source.
2. **Assign `Area:` from the taxonomy.** Open `CLAUDE.md` and look up the section + sub-beat list:
   - Pick a top-level section (`tech`, `finance`, `science`, `health`, `sport`, `business`, `culture`, `lifestyle`, `politics`).
   - Pick an existing sub-beat from the section's row in the table. Reuse first; do not invent.
   - Only if the article fits no existing sub-beat: propose a new one and add it to the table in `CLAUDE.md` with a one-line scope note **as part of this ingest**. Note the addition in the log entry.
3. **Fill front-matter** per CLAUDE.md:
   - `Type: #type/source`
   - `Area: #area/<section>/<beat>` from step 2
   - `Keyword:` — read the Keywords section of `wiki/_meta/index.md` first. Reuse existing keywords. If adding a new one, register it there with a one-line definition.
   - `Date created: [[YYYY-MM-DD]]` — today
   - `Source:` — URL or canonical reference
4. **Write the body in retention voice:**
   - **Summary** — 3-5 sentences. Who/what/when/where/why. The core claim and the key actors.
   - **Key facts** — 5-10 tight bullets. Quote figures verbatim where helpful (dates, dollar amounts, named entities, version numbers).
   - **Why it matters** — one short paragraph. What this changes, what it confirms, what it contradicts. Don't editorialise; don't seed essays.
5. **Create a people page** if the source has an author and no page exists in `wiki/` yet. Keep it thin — a connector node, not an essay. See CLAUDE.md for the three-tier rule.
6. **Clear the inbox**: remove the original once the source note is written.

### Logging

Append to `wiki/_meta/log.md`:

```
## [YYYY-MM-DD] ingest | <one-line descriptor>
- Sources: [[Title]] — one-line descriptor
- Section: #area/<section>/<beat>
- Noticed: anything surprising — candidate themes, unusual keywords, contradictions with existing notes
- Taxonomy changes: (only if you added a sub-beat to CLAUDE.md)
```

Also update the relevant sections of `wiki/_meta/index.md`:
- Add the new source to the Sources catalog
- Increment the `<section>` counter under Sections (sources +1)
- Increment keyword counts; register any new keyword
- If a recurring theme appeared across 2+ sources, add it to Candidates for the compile loop to promote

### Hard rules

- Don't create concept articles in this skill — that's the compile loop's job. Just get the source notes in clean.
- Don't mint a new sub-beat without registering it in the CLAUDE.md table.
- If the inbox is empty and no specific item was provided, say so and stop. Don't invent work.
