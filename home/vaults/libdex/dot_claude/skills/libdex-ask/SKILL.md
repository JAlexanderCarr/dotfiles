---
name: libdex-ask
description: Research a question across the libdex vault and write a query report. Use when the user asks the vault a question, says "ask the vault", or wants to research a topic using libdex sources and concepts.
---

**When to use this skill:** The user has a research question and wants Claude to search libdex (sources, concepts, prior query reports) and write a cited report.

**Before doing anything**, read `CLAUDE.md` at the vault root for the full rules of engagement.

### Scope

The question to answer is whatever the user provided. If no question was given, open `wiki/_meta/index.md` and pick the oldest entry in the **Open Questions** list. If that list is empty too, say so and stop — don't invent a question.

### How to answer

1. **Search in this order** (most distilled first):
   - Concept articles in `wiki/` — these already synthesise across sources. Read every concept whose title, keywords, or `Related:` plausibly touches the question.
   - Source notes in `sources/` — for specific claims, quotes, and evidence.
   - Prior query reports in `wiki/` (Type: #type/query) — queries compound.

2. **Cite every claim.** Every factual or interpretive sentence in the answer must trace back to a specific note via `[[Title]]` wikilinks. If a claim has no source, either find one or drop it — don't invent evidence.

3. **Hold tensions explicitly.** When sources disagree, name the disagreement rather than collapsing it. Honest signal matters more than a clean answer.

### Output

Write to `wiki/YYYY-MM-DD-<question-slug>.md`. Slug the question — kebab-case, ~6 words max, enough for the filename to be scannable.

Front-matter:

```
Type: #type/query
Area: #area/<section>/<beat>
Keyword: #keyword/...
Date created: [[YYYY-MM-DD]]
Question: <the user's exact question>

---
```

Body. **Bias toward terse.** A tight, dense report is more useful than a thorough one.

- **Short answer** — one paragraph, ~4-6 sentences max. The honest answer, not a summary of the search. If the vault can't answer, say so and name what's missing.
- **Evidence** — 5-8 bullets max. Each bullet is one claim, cited to 1–N notes with wikilinks. Collapse related points into one bullet rather than spawning sub-headers.
- **Tensions** — 0-3 bullets. Name real disagreement, not every mild difference. Empty is fine.
- **Follow-on questions** — 3-5 bullets max. Real research gaps the vault raised but can't answer. These feed back into `wiki/_meta/index.md` → Open Questions.

### Feedback into the graph (so queries compound)

After writing the report:

1. **Any finding backed by ≥2 sources** that isn't yet a concept article — add it to the Candidates section of `wiki/_meta/index.md` with the query filename as the rationale.
2. **Any follow-on question** that isn't already in `wiki/_meta/index.md` → Open Questions — append it there, one line each.
3. **If the question came from the Open Questions list**, move it from **Open** to **Answered** with a link to the query report.
4. **Update `wiki/_meta/log.md`** under `## [YYYY-MM-DD] query | <slug>` — one-line answer summary.
5. **Pages catalog** — add the report to the Queries subsection under Pages in `wiki/_meta/index.md`.

### Final summary to print

- Question
- One-sentence answer
- Report path
- Candidates flagged (count + titles)
- Follow-on questions logged (count)

### Hard rules

- Never invent a citation. If the vault doesn't contain evidence for a claim, leave the claim out.
- Never summarise your search process in the report — the report is the answer, not a diary of the lookup.
- Never collapse a real tension into false consensus. If sources disagree, the report must say so.
- If the report would be thin (fewer than 3 cited claims), stop and return a note saying the vault isn't yet ready to answer this question. Don't pad with speculation.
- Tight over thorough. If a bullet repeats the claim above it, cut one. If a section has nothing pointed to say, leave it empty.
- No "What this suggests writing" / essay-prompt section. Follow-on questions are research gaps, not essay seeds.
