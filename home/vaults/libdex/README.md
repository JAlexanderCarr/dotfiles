# libdex

libdex is a personal newspaper / encyclopedia maintained by Claude. Drop articles, PDFs, or URLs into `inbox/`. Claude turns them into atomic source notes, then builds an indexed wiki of topics you want to remember.

Inspired by [Andrej Karpathy's LLM wiki pattern](https://x.com/karpathy/status/2039805659525644595): raw source documents go in, an LLM incrementally compiles them into concept articles with backlinks, and the wiki becomes a rich substrate for recall and Q&A.

## Quick start

1. **Open this vault** in [Obsidian](https://obsidian.md)
2. **Install Claude Code** — [claude.ai/code](https://claude.ai/code)
3. **Drop something into `inbox/`** — a URL, a web clipping (via [Obsidian Web Clipper](https://obsidian.md/clipper)), a PDF, or pasted text
4. **Ask Claude to ingest the inbox** — Claude processes everything in the inbox into clean source notes
5. **Ask Claude to compile sources** — Claude builds or extends concept articles from un-compiled sources
6. **Ask Claude a question** — Claude researches your question across the vault and writes a cited report

That's it. Drop, ingest, compile. The vault grows itself.

## How it works

### Three layers

| Directory | Purpose | Who writes |
|---|---|---|
| `inbox/` | Staging for unprocessed drops | You |
| `sources/` | One atomic note per article, paper, or transcript | Claude |
| `wiki/` | Concept articles, people pages, query reports, index, and log | Claude |

### The contract

You curate what goes in. Claude writes and maintains the derived layer. The separation matters — your taste decides what's worth keeping; Claude does the synthesis work.

### The soft 2-source rule

Concept pages default to needing 2+ sources, so the wiki doesn't fill up with one-off speculation. The exception is **reference-grade** material — a definitive overview where a single source is the right unit of recall (encyclopedia entries, official documentation, comprehensive reviews). Claude notes the justification on the page when it invokes the exception.

### Newspaper-style taxonomy

Every note is tagged `#area/<section>/<beat>` — e.g. `#area/tech/ai`, `#area/finance/personal`, `#area/sport/climbing`. Sections and sub-beats are curated in `CLAUDE.md`; new sub-beats must be registered before use. The vault stays browseable like a newspaper.

## The four skills

| Invocation | What it does |
|---|---|
| "ingest the inbox" / "process my inbox" | Process inbox into source notes |
| "compile sources" / "run compile" | Build or extend concept articles from un-compiled sources |
| "ask the vault: [question]" | Research a question across the vault |
| "lint the vault" / "health check" | Health-check: stats, orphans, sub-beat drift, keyword drift |

Claude auto-recognises these phrasings and triggers the matching skill.

## Customisation

- **Sections / sub-beats**: Edit the taxonomy table in `CLAUDE.md` to add or rename sections/beats
- **Keywords**: Managed in `wiki/_meta/index.md` — add new ones as your reading grows
- **Obsidian theme**: The `.obsidian/` config is included with a clean Minimal setup. Swap themes or plugins as you like
- **Voice**: Source and concept voice rules live in `CLAUDE.md` — adjust if you want denser or lighter notes

## Schema

Everything Claude needs to know is in `CLAUDE.md`. That file is the single source of truth for how the vault operates. Read it if you want to understand or modify the rules.

---

Built with [Claude Code](https://claude.ai/code) and [Obsidian](https://obsidian.md).
