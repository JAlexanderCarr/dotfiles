---
name: libdex-compile
description: Compile libdex source notes into concept articles. Use when the user asks to compile sources, build concept articles, or synthesise un-compiled sources in the libdex vault.
---

**When to use this skill:** The user wants un-compiled source notes turned into concept articles, or wants to extend existing concepts with new source material.

**Before doing anything**, read `CLAUDE.md` at the vault root for the full rules of engagement.

### Scope

Scan `sources/` for source notes that haven't been fully compiled. A source is "un-compiled" if its title doesn't appear in any concept article's `Sources:` field across `wiki/`.

If the user named a specific source note, concept, or theme, focus the compile run on that. Otherwise work through un-compiled sources oldest first.

### For each un-compiled source

1. **Read the source note** in full, including the "Why it matters" paragraph at the bottom.
2. **Scan existing concept articles** in `wiki/` for topical overlap.
3. **Decide**: extend an existing concept, or spin out a new one (subject to the soft 2-source rule below).
   - **Extend** when the source adds a new fact, example, or nuance to an existing concept. Add the source to the `Sources:` line. Add a bullet under **Evidence across sources** that cites the new source.
   - **Spin out** when a distinct topic recurs across 2+ sources, OR when a single source is **reference-grade** (a definitive overview — encyclopedia entry, official documentation, standards document, comprehensive review). A new concept article needs:
     - Front-matter: `Type: #type/concept`, `Area: #area/<section>/<beat>`, `Keyword:`, `Date created:`, `Sources:`, `Related:` (≥2 if any plausibly relate; otherwise note as island)
     - **What it is** — one-sentence definition
     - **Why it matters** — one short paragraph
     - **Key points** — claim-shaped bullets, each cited
     - **Evidence across sources** — per-source bullets summarising what each contributed
     - **Open questions** — real gaps the vault can't yet answer
     - If the soft 2-source exception applies, add a line in the body: `Single-source — reference-grade: <one-line justification>`
4. **If uncertain**: log the theme as a candidate in the Candidates section of `wiki/_meta/index.md` with a one-line rationale. Don't create speculative concepts from a single non-reference source — wait for cross-source signal.

### Maintenance passes

After compiling:

1. **Update the Research Threads section of `wiki/_meta/index.md`** — if a new thread has formed (a cluster of ≥3 concept articles sharing keywords), add a section for it with links. If a thread gained new articles, update its list.
2. **Sections counters** — for any new concept, increment `concepts +1` for the relevant section in the Sections block of `wiki/_meta/index.md`.
3. **Keywords** — register any new keywords used during compile in the Keywords section of `wiki/_meta/index.md`, and increment counts.
4. **Pages catalog** — add new concepts to the Concepts subsection under Pages.
5. **Update `wiki/_meta/log.md`** — append today's entry under `## [YYYY-MM-DD] compile | <summary>`, listing new concepts and extended ones. If the reference-grade exception was used, name the source.

### Output

End with a short summary printed to the user:
- Sources compiled (count + titles)
- New concepts created (titles + one-line each, flagging any single-source reference-grade)
- Existing concepts extended (titles)
- Candidates flagged (titles + reason)

### Hard rules

- Default: never create a concept article from a single source.
- Reference-grade exception: allowed only when the source is a definitive overview, and only with a written `Single-source — reference-grade:` justification in the concept body.
- Always update backlinks when renaming or restructuring. Never leave broken links.
- If you delete or substantially rewrite an existing concept, note it in the log under a **Restructured** bullet.
- Concept pages have no "Prompts" / "What this suggests writing" section. This vault is for retention.
