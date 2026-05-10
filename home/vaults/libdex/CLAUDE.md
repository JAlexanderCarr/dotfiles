# libdex - A Personal Newspaper / Encyclopedia

libdex is an autonomous knowledge vault maintained by Claude. Drop articles, PDFs, and URLs into `inbox/`. Claude ingests them into atomic source notes and compiles a wiki of topics you want to remember. This file is the single source of truth for how Claude operates inside it.

The model is a personal newspaper / encyclopedia — retention and retrieval, not essay-seeding.

---

## Directory structure

Three layers:

| Directory | Purpose | Who writes |
|---|---|---|
| `inbox/` | Staging for unprocessed drops (PDFs, URLs, screenshots, pasted text) | You drop, Claude clears |
| `sources/` | Immutable atomic source notes — one per article/paper/transcript | Claude on ingest; minor edits only after creation |
| `wiki/` | LLM-maintained pages: concepts, queries, people, index, log, health | Claude maintains |

Special files in `wiki/_meta/`:
- **`index.md`** — catalog of every page, keyword glossary, section counters, research threads, open questions, candidates. Claude reads this first when answering a query. Updated on every operation.
- **`log.md`** — append-only chronological record. Each entry: `## [YYYY-MM-DD] operation | Title`. Never rewritten, only appended.
- **`health.md`** — lint dashboard. Overwritten each `libdex-lint` run.

---

## File naming

- **Source notes**: Title Case — `The Rosetta Stone of Design Engineering.md`
- **Concept articles**: Title Case, descriptive — `Quantum Key Distribution.md`
- **People**: `FirstName LastName.md` with hyphens only inside compound names. If surname unknown, `FirstName.md` and note the uncertainty.
- **Queries**: `YYYY-MM-DD-slug.md`
- No emoji, no unicode hacks, no date prefixes in titles (dates go in front-matter)

---

## Front-matter

Plain key-value lines, not YAML. Blank line then `---` then body.

**Source notes (`sources/`):**
```
Type: #type/source
Area: #area/tech/ai
Keyword: #keyword/transformers #keyword/inference
Date created: [[2026-05-09]]
Source: https://example.com/article

---

**Summary**
3-5 sentences. Who/what/when/where/why. The core claim and the key actors.

**Key facts**
- 5-10 tight bullets. Quote figures verbatim where helpful (dates, dollar amounts, named entities).

**Why it matters**
One short paragraph. What this changes, what it confirms, what it contradicts.
```

**Wiki pages — concepts (`wiki/`):**
```
Type: #type/concept
Area: #area/tech/security
Keyword: #keyword/zero-trust
Date created: [[2026-05-09]]
Sources: [[Source One]], [[Source Two]]
Related: [[Concept A]], [[Concept B]]

---
```
Body: `What it is` > `Why it matters` > `Key points` > `Evidence across sources` > `Open questions`.

**Voice for source notes.** Optimised for *recall* — what did this article actually say? Tight summary, factual bullets, one paragraph on significance. Don't editorialise; don't seed essays.

**Voice for concept pages.** Encyclopedic, not essayistic.
- *What it is*: one-sentence definition.
- *Why it matters*: one short paragraph.
- *Key points*: claim-shaped bullets, each cited.
- *Evidence across sources*: per-source bullets summarising what each source contributed.
- *Open questions*: real gaps the vault can't yet answer.

**Wiki pages — queries:**
```
Type: #type/query
Area: #area/finance/markets
Keyword: #keyword/inflation
Date created: [[2026-05-09]]
Question: the question asked

---
```

**Wiki pages — people:**
```
Type: #type/person
Area: #area/tech/ai
Keyword: #keyword/llms
Date created: [[2026-05-09]]

---

One-line identifier. Topic description.

**Sources in libdex**
- [[Source Title]]

**Concepts they inform**
- [[Concept Title]]
```

---

## Tag taxonomy

**`#type/`** — each note gets exactly one:
- `source` — an ingested external source (in `sources/`)
- `concept` — a synthesised wiki page
- `query` — a research report answering a question
- `person` — an entity page for a thinker/author/subject
- `meta` — vault infrastructure (index, log, health)

**`#area/`** — top-level sections (newspaper-style). Each note gets exactly one. Tag form: `#area/<section>/<beat>`.

| Section | Sub-beats |
|---|---|
| `tech` | ai, security, networking, software, hardware, web, devops, data |
| `finance` | personal, business, markets, crypto, taxes |
| `science` | biology, physics, chemistry, climate, space, neuroscience |
| `health` | nutrition, fitness, medicine, mental, sleep |
| `sport` | (add as relevant — e.g. soccer, basketball, tennis, motorsport, climbing) |
| `business` | management, strategy, startups, careers, marketing, operations |
| `culture` | books, film, music, art, gaming |
| `lifestyle` | food, travel, hobbies, home |
| `politics` | us, international, policy, elections |

`#area/meta` — vault infrastructure (index, log, health). No sub-beat needed.

**Sub-beats are curated.** Before tagging a note with a new sub-beat:
1. Check the table above.
2. If a near-match exists, reuse it.
3. If genuinely new, add it to this table with a one-line scope note. Don't mint sub-beats on the fly.

**`#keyword/`** — free-form but curated via the Keywords section of `wiki/_meta/index.md`. Before creating a new keyword:
1. Check `wiki/_meta/index.md`.
2. If a near-match exists, reuse it.
3. If genuinely new, add it to the Keywords section with a one-line definition.

---

## People — when to create a page

Three tiers:

| Tier | Trigger | Action |
|---|---|---|
| Author | Person authored a source in `sources/` | Always create a page in `wiki/` on ingest |
| Subject | Source is substantively about a person | Create page with a richer profile |
| Passing reference | Mentioned in passing | Use `[[Name]]` wikilink without creating a file. Create only on the **second** independent citation |

People pages stay thin — connector nodes, not essays.

---

## Citation & linking

- **Every claim in a concept must be traceable.** `Sources:` front-matter lists the source notes the claim rests on.
- **Backlink rule**: every new concept links at least 2 existing concepts in `Related:`, or notes why it's an island (flagged in `wiki/_meta/health.md` Orphans section).
- **Never break a link.** If renaming, update all backlinks.

---

## The soft 2-source rule

**Default**: a concept page needs 2+ sources to corroborate the theme.

**Exception**: a single source may seed a concept page if it is **reference-grade** — a definitive overview (encyclopedia entry, official documentation, a standards document, a comprehensive review article) where the goal is recall of the topic itself, not synthesis across viewpoints. When invoking the exception, note it in the concept page body:

```
Single-source — reference-grade: <one-line justification>
```

Speculative themes from a single non-reference source still go to Candidates and wait for a second source.

---

## Operations

### Ingest (`libdex-ingest` skill)

Process anything in `inbox/` — web clippings, PDFs, URLs, pasted text — into clean atomic source notes in `sources/`.

Flow: read source > normalise into source note > assign `#area/<section>/<beat>` (consult the sub-beat table above) > write summary + key facts + why it matters > update `wiki/_meta/index.md` (Sources, Keywords, Sections counters) > append to `wiki/_meta/log.md` > clear inbox.

Won't do: create concept articles (that's compile's job), invent work if inbox is empty.

### Compile (`libdex-compile` skill)

Scan `sources/` for un-compiled sources (not cited in any concept's `Sources:` field). Either extend an existing concept or spin out a new one. Default to the 2-source rule; invoke the reference-grade exception only when the source is a definitive overview.

After each run: update Research Threads, Section counters, keyword counts — all in `wiki/_meta/index.md`. Append to `wiki/_meta/log.md`.

Won't do: spin out a speculative concept from a single non-reference source, break links.

### Query (`libdex-ask` skill)

Research a question across libdex. Write report to `wiki/YYYY-MM-DD-slug.md`. Every claim cites its source. Findings with 2+ sources feed back to Candidates. Open gaps feed to Open Questions in `wiki/_meta/index.md`.

Won't do: invent citations, pad thin answers.

### Lint (`libdex-lint` skill)

Health-check the whole vault. Overwrite `wiki/_meta/health.md` with: Stats, Front-matter validation, Orphans, Broken links, Index staleness, Section coverage, Sub-beat drift, Keyword drift, Candidates needing attention.

---

## What NOT to do

- Don't create files outside `sources/`, `wiki/`, or `inbox/`.
- Don't speculatively create concepts from a single non-reference source. Wait for cross-source signal or invoke the reference-grade exception with a written justification.
- Don't mint new sub-beats without registering them in the taxonomy table.
- Don't seed essays. This vault is for retention; "Prompts" / "What this suggests writing" sections are out of scope.
- Don't use emojis.
- Don't add TODO comments. If something's missing, log it in Candidates or Open Questions.
- Don't create helpers, templates, or meta-infrastructure. The schema (this file) + index + log is all the infrastructure the vault needs.
