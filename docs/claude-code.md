# Claude Code

The `ai` add-on installs global Claude Code configuration managed by chezmoi.

## What Gets Installed

| Path | Description |
|------|-------------|
| `~/.claude/CLAUDE.md` | Global coding preferences and standards |
| `~/.claude/settings.json` | Claude Code settings (provider, env vars, plugins) |
| `~/.claude/skills/` | Custom skill definitions |
| `~/.config/ccstatusline/settings.json` | Status line config |

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

Claude Code supports `~/.claude/settings.local.json` for **project-level** local overrides (gitignored). For global machine-specific env vars, use a shell function in `~/.zshrc` or `~/.env`:

```zsh
# ~/.zshrc — pass extra env vars to claude without touching settings.json
claude() {
  SOME_VAR=value command claude "$@"
}
```

`~/.env` is sourced by the shell profile and is not tracked by chezmoi.
