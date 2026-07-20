## What This Repo Is

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/). The `home/` directory is the chezmoi source — file naming conventions map directly to the home directory at apply time (e.g., `dot_bashrc.tmpl` → `~/.bashrc`).

## Repository Layout

```
home/               # chezmoi source — maps to ~/
  dot_*.tmpl        # Templated config files (inject name, email, etc.)
  dot_*             # Static config files
  run_once_*        # Scripts that run once (e.g., welcome message)
  run_onchange_*    # Scripts that re-run when their content changes (package installs)
  dot_claude/       # Claude Code config — CLAUDE.md, hooks/, skills/, settings, keybindings
  dot_config/       # XDG config files (nvim, lima, ccstatusline)
  dot_local/bin/    # Installed CLI tools: motd, motd-static, chezmoi-log-helper.sh
  vaults/           # Obsidian vaults (personal, libdex); installed at ~/vaults when addons.obsidian is set
  vscode/           # VSCode settings/keybindings/extensions, installed directly by run_onchange_install-vscode.sh.tmpl
build/              # Dockerfiles: Ubuntu + Amazon Linux test containers, a dev container, and a manual-test container
test/               # chezmoi-test.sh (integration), shellcheck.sh, hooks-test.sh
docs/               # Extended documentation — shell.md, packages.md, claude-code.md, development.md, index.md
renovate.json       # Automated dependency updates via Renovate bot
```

## Testing

```sh
make build           # Build Ubuntu + Amazon Linux Docker images (multi-arch)
make test            # Run integration tests on all containers
make test-ubuntu     # Ubuntu only
make test-amazon     # Amazon Linux only
make shellcheck      # Lint shell scripts and rendered chezmoi templates
make test-hooks      # Run Claude Code safety hook tests (host, no container)
make manual-test     # Interactive container for manual chezmoi testing
```

The test script (`test/chezmoi-test.sh`) writes a synthetic `chezmoi.yaml` with all packages enabled, runs `chezmoi apply --force`, then verifies expected files, directories, and installed commands exist.

Pass `--skip-packages` to the test script to run dotfiles-only checks (faster).

See `docs/` for more detail: [shell](docs/shell.md), [packages](docs/packages.md), [Claude Code](docs/claude-code.md), [development](docs/development.md).
