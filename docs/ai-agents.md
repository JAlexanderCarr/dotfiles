# AI Agent Integration

This dotfiles repo includes optional support for AI coding agents — global personal preferences that follow you across machines, and a template library for bootstrapping project-level instruction files.

## Overview

AI coding agents (Claude Code, OpenAI Codex) each look for instruction files to guide their behavior. These instructions exist at two levels:

| Level | Purpose | Where it lives |
|-------|---------|----------------|
| **Global** | Your personal coding style, preferences, and standards | Dotfiles (`~/.claude/`, `~/.codex/`) |
| **Project** | Project-specific conventions, architecture, and rules | Project repo root (`AGENTS.md`, `CLAUDE.md`, etc.) |

This dotfiles repo manages the **global** level and provides the `aide` CLI to bootstrap the **project** level.

## What Gets Installed

When the `ai` add-on is enabled during `chezmoi init`, the following files are installed:

| Installed Path | Source | Description |
|----------------|--------|-------------|
| `~/.config/aide/AI_PREFERENCES.md` | `home/dot_config/aide/AI_PREFERENCES.md` | Shared global AI preferences |
| `~/.claude/CLAUDE.md` | `home/dot_claude/symlink_CLAUDE.md` | Global Claude Code preferences (symlink → AI_PREFERENCES.md) |
| `~/.codex/AGENTS.md` | `home/dot_codex/symlink_AGENTS.md` | Global OpenAI Codex preferences (symlink → AI_PREFERENCES.md) |
| `~/.config/aide/ai-templates/base.md` | `home/dot_config/aide/ai-templates/base.md` | Universal project instructions |
| `~/.config/aide/ai-templates/general.md` | `home/dot_config/aide/ai-templates/general.md` | General AI coding assistant instructions |
| `~/.config/aide/ai-templates/go.md` | `home/dot_config/aide/ai-templates/go.md` | Go conventions |
| `~/.config/aide/ai-templates/python.md` | `home/dot_config/aide/ai-templates/python.md` | Python conventions |
| `~/.config/aide/ai-templates/typescript.md` | `home/dot_config/aide/ai-templates/typescript.md` | TypeScript/Node conventions |
| `~/.config/aide/ai-templates/infrastructure.md` | `home/dot_config/aide/ai-templates/infrastructure.md` | Terraform/K8s/IaC conventions |
| `~/.local/bin/aide` | `home/dot_local/bin/executable_aide` | AI Development Environment CLI |

### Enabling/Disabling

During `chezmoi init`, you'll be prompted:

```
AI agent configs (Claude, Codex, templates)? [yes]
```

To change later:

```sh
chezmoi init    # re-prompts for all settings
chezmoi apply
```

Or edit `~/.config/chezmoi/chezmoi.yaml` directly:

```yaml
data:
  addons:
    ai: true   # or false
```

## Global Instruction Files

### `~/.config/aide/AI_PREFERENCES.md`

This is the canonical global preferences file shared across all AI coding assistants. Both `~/.claude/CLAUDE.md` and `~/.codex/instructions.md` are symlinks to this file, ensuring all AI tools follow the same guidelines.

**What to put here:**
- Code style preferences (error handling, naming, structure)
- Commit message format
- Testing philosophy
- Security practices
- General language-agnostic conventions

**What NOT to put here:**
- Project-specific architecture or dependencies
- Team conventions (those belong in the project repo)
- Anything that changes per-project

### `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`

These files are symlinks to `~/.config/aide/AI_PREFERENCES.md`. Both Claude Code and OpenAI Codex will automatically load their respective files, but they both point to the same shared preferences file. This ensures consistency across all AI coding assistants.

## The `aide` CLI

`aide` (AI Development Environment) is a CLI tool that manages AI agent instruction files for projects. It replaces the previous `ai-init` script with a full subcommand interface.

### Commands

```sh
aide init <type...>          # Bootstrap AI instruction files
aide status                  # Show agent file status in current directory
aide templates               # List available templates
aide templates add <name>    # Create a new template
aide agents                  # List supported agents and their files
aide doctor                  # Verify global AI config is properly installed
aide --help                  # Full help
aide --version               # Version info
```

### `aide init`

Bootstraps AI agent instruction files for a project by composing templates.

```sh
# In a project directory:
aide init go                          # Go project
aide init python                      # Python project
aide init go infrastructure           # Go + IaC project
aide init typescript                  # TypeScript/Node project

# Generate for specific agents only:
aide init go -a codex                 # Only Codex file
aide init go -a claude                # Only Claude file

# Overwrite existing files without prompting:
aide init go --force
```

#### What It Generates

| Generated File | Agent | Type |
|----------------|-------|------|
| `AGENTS.md` | OpenAI Codex | Canonical file |
| `CLAUDE.md` | Claude Code | **Symlink → AGENTS.md** |

All files share the same content: `base.md` + the templates for each specified type, composed together. Only `AGENTS.md` is a real file — `CLAUDE.md` is a symlink pointing back to it.

#### Symlink Strategy

`AGENTS.md` is the **canonical** instruction file — the single source of truth. `CLAUDE.md` is created as a **symlink** pointing to `AGENTS.md`. This means:

- **One file to edit.** Changes to `AGENTS.md` are automatically reflected in both agent configs.
- **Both agents work.** Each agent reads its own expected file, but they both resolve to the same content.
- **Git-friendly.** Git tracks symlinks natively. Your team clones the repo and both agents work out of the box.
- **No drift.** Unlike copies, symlinks can never get out of sync with `AGENTS.md`.

### `aide status`

Shows which agent files exist in the current project directory, including symlink health.

```sh
$ aide status
AI agent file status in my-project/

  ● codex    AGENTS.md (42 lines)
  ● claude   CLAUDE.md → AGENTS.md (symlink)

2 agent(s) configured, 0 missing.
```

### `aide templates`

Lists available templates from your template library.

```sh
$ aide templates
Available templates
Location: ~/.config/aide/ai-templates

  ● base (18 lines — included in every project)
  ● general (23 lines)
  ● go (10 lines)
  ● infrastructure (10 lines)
  ● python (10 lines)
  ● typescript (10 lines)
```

### `aide templates add`

Creates a scaffold for a new template type.

```sh
$ aide templates add rust
Created template: ~/.config/aide/ai-templates/rust.md
```

### `aide doctor`

Verifies that your global AI development environment is properly installed:

```sh
$ aide doctor
Checking AI development environment...

Templates:
  ✓ Template directory exists (6 files)
  ✓ base.md exists

Global agent configs:
  ✓ ~/.claude/CLAUDE.md
  ✓ ~/.codex/instructions.md

CLI:
  ✓ aide is in PATH

All checks passed.
```

### Shell Aliases

The following aliases are available when using bash or zsh:

| Alias | Command | Purpose |
|-------|---------|---------|
| `ai` | `aide` | Quick access |
| `ais` | `aide status` | Check current project |
| `ait` | `aide templates` | List templates |
| `aid` | `aide doctor` | Health check |

### Backward Compatibility

If you run `aide <type>` directly (e.g., `aide go`), it will still work but will show a deprecation warning suggesting `aide init go` instead. The old `ai-init` script is replaced by `aide`.

### Workflow

1. Create a new project or `cd` into an existing one
2. Run `aide init <type>` to generate instruction files
3. Review and customize the generated files for the project
4. Commit them to the project repo so the whole team benefits
5. Use `aide status` to verify everything is in place

## Template Library

Templates live in `~/.config/aide/ai-templates/` and are composed by `aide init`.

### Structure

| File | Purpose |
|------|---------|
| `base.md` | Universal rules included in every project (read existing code, run tests, no hardcoded secrets) |
| `general.md` | General AI coding assistant instructions (code quality, best practices, safety) |
| `go.md` | Go-specific conventions (error handling, interfaces, project layout) |
| `python.md` | Python conventions (type hints, ruff, pytest, pathlib) |
| `typescript.md` | TypeScript/Node conventions (strict mode, ESLint, Vitest) |
| `infrastructure.md` | IaC conventions (Terraform modules, K8s resource limits, secret management) |

### Adding a New Template

1. Use `aide templates add`:

   ```sh
   aide templates add rust
   ```

   Or create it manually:

   ```sh
   cat > ~/.config/aide/ai-templates/rust.md << 'EOF'
   ## Rust Conventions

   - Use `clippy` and `rustfmt` before committing
   - Prefer `Result<T, E>` over panicking
   - Use `thiserror` for library error types, `anyhow` for applications
   - Write doc tests for public API functions
   - Use `cargo test` and `cargo clippy -- -D warnings` in CI
   EOF
   ```

2. Templates are auto-discovered — no code changes needed. `aide init rust` works immediately.

3. To persist in dotfiles, add the template to this repo:

   ```sh
   cp ~/.config/aide/ai-templates/rust.md \
      ~/code/dotfiles/home/dot_config/aide/ai-templates/rust.md
   # Or: chezmoi add ~/.config/aide/ai-templates/rust.md
   ```

## Best Practices

### Global Instructions (dotfiles)

- **Keep it concise.** Agents have context limits. Focus on high-signal preferences.
- **Be prescriptive, not descriptive.** Say "Use conventional commits" not "I usually use conventional commits."
- **Avoid project specifics.** Global files should work for any project.
- **Review periodically.** As your practices evolve, update the templates.

### Project Instructions (generated by `aide init`)

- **Commit them.** The whole team should benefit from consistent agent behavior.
- **Customize after generation.** `aide init` gives you a starting point — add project-specific architecture, key files, and domain context.
- **Include "where things are."** Agents work better when they know the project layout (e.g., "API handlers are in `internal/api/`, tests mirror source structure").
- **List key commands.** Tell agents how to build, test, and lint: `make test`, `go test ./...`, `npm run lint`.
- **Specify what NOT to do.** Negative instructions are powerful: "Do not modify the database migration files without discussion."

### Agent File Versioning

Recommendation for your projects' `.gitignore`:

```gitignore
# Commit these — they benefit the whole team:
# AGENTS.md
# CLAUDE.md          (symlink to AGENTS.md)
```

## File Reference

```
~/.config/aide/
├── AI_PREFERENCES.md              # Shared global AI preferences (canonical)
└── ai-templates/
    ├── base.md                    # Universal project template
    ├── general.md                 # General AI coding assistant template
    ├── go.md                      # Go template
    ├── python.md                  # Python template
    ├── typescript.md              # TypeScript/Node template
    └── infrastructure.md          # IaC template

~/.claude/
└── CLAUDE.md → ~/.config/aide/AI_PREFERENCES.md   # Symlink to shared preferences

~/.codex/
└── AGENTS.md → ~/.config/aide/AI_PREFERENCES.md   # Symlink to shared preferences

~/.local/bin/
└── aide                           # AI Development Environment CLI
```
