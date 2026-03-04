## What This Repo Is

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/). The `home/` directory is the chezmoi source — file naming conventions map directly to the home directory at apply time (e.g., `dot_bashrc.tmpl` → `~/.bashrc`).

## Repository Layout

```
home/               # chezmoi source — maps to ~/
  dot_*.tmpl        # Templated config files (inject name, email, etc.)
  dot_*             # Static config files
  run_once_*        # Scripts that run once (e.g., welcome message)
  run_onchange_*    # Scripts that re-run when their content changes (package installs)
  dot_config/
    aide/           # AI tooling: AI_PREFERENCES.md and ai-templates/
    nvim/           # Neovim config (init.vim + plugins)
  dot_local/bin/    # Installed CLI tools: aide, motd, motd-static, chezmoi-log-helper.sh
build/              # Dockerfiles for Ubuntu and Amazon Linux test containers
test/               # chezmoi-test.sh — integration test script
docs/               # Extended documentation (ai-agents.md)
renovate.json       # Automated dependency updates via Renovate bot
```

## Testing

```sh
make build           # Build Ubuntu + Amazon Linux Docker images (multi-arch)
make test            # Run integration tests on all containers
make test-ubuntu     # Ubuntu only
make test-amazon     # Amazon Linux only
make manual-test     # Interactive container for manual chezmoi testing
```

The test script (`test/chezmoi-test.sh`) writes a synthetic `chezmoi.yaml` with all packages enabled, runs `chezmoi apply --force`, then verifies expected files, directories, and installed commands exist.

Pass `--skip-packages` to the test script to run dotfiles-only checks (faster).
