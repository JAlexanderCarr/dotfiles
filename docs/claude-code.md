# Claude Code

The `ai` add-on installs global Claude Code configuration managed by chezmoi.

## What Gets Installed

| Path | Description |
|------|-------------|
| `~/.claude/CLAUDE.md` | Global coding preferences and standards |
| `~/.claude/settings.json` | Claude Code settings (provider, env vars, plugins, hooks) |
| `~/.claude/hooks/` | Safety hooks that run before tool execution |
| `~/.claude/skills/` | Custom skill definitions |
| `~/.config/ccstatusline/settings.json` | Status line config |

## Hooks

`PreToolUse` hooks run before every tool call and block execution by exiting with code `2`. They apply globally across all projects.

| Hook | Trigger | What it blocks |
|------|---------|----------------|
| `block-dangerous-rm.sh` | `Bash` | `rm -rf /`, `rm -rf ~`, `--no-preserve-root` |
| `block-dangerous-git.sh` | `Bash` | Force push, `reset --hard`, `clean -f`, `branch -D`, `restore`/`checkout --` without `--staged` |
| `block-dangerous-bash.sh` | `Bash` | Fork bomb, `chmod *7 /`, writes to `/etc/passwd`/`shadow`/`sudoers`, `dd` to raw disk, shutdown/reboot |
| `protect-sensitive-files.sh` | `Edit`, `Write` | `.env*`, SSH private keys, `*.pem`/`*.key`, `.aws/credentials`, `.netrc`, `.pypirc` |

Hooks are permanent — blocked commands cannot be overridden via permission prompts or user approval.

All four hooks require `jq` (installed by the `devtools` package) and fail closed — a missing `jq` blocks the action rather than silently letting it through.

## Provider Setup

During `chezmoi init`, you'll be prompted to choose a Claude provider:

```
Claude provider (claude/bedrock) [claude]:
```

- **claude** — uses your Anthropic subscription (default)
- **bedrock** — uses AWS Bedrock; injects `AWS_PROFILE=claude-code` into `settings.json`

To change later, edit `~/.config/chezmoi/chezmoi.yaml`:

```yaml
data:
  addons:
    claudeProvider: "bedrock"   # or "claude"
```

Then run `chezmoi apply`.

## Settings

`~/.claude/settings.json` is templated and includes:

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING": "1",
    "MAX_THINKING_TOKENS": "128000",
    "AWS_PROFILE": "claude-code"   // bedrock only
  }
}
```

## Machine-Local Overrides

Claude Code supports `settings.local.json` for project-level local overrides (gitignored). For global machine-specific env vars, use a shell function in `~/.zshrc` or `~/.env`:

```zsh
claude() {
  SOME_VAR=value command claude "$@"
}
```

`~/.env` is sourced by the shell profile and is not tracked by chezmoi.
