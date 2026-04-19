# Development

## Repository Layout

```
home/               # chezmoi source — maps to ~/
  dot_*.tmpl        # Templated config files
  dot_*             # Static config files
  run_once_*        # Scripts that run once
  run_onchange_*    # Scripts that re-run when content changes
  dot_claude/       # Claude Code config
  dot_config/       # XDG config files (nvim, lima, ccstatusline)
  dot_local/bin/    # Installed CLI tools
build/              # Dockerfiles for Ubuntu and Amazon Linux
test/               # chezmoi-test.sh integration test script
docs/               # Documentation
```

## Testing

The `build/` directory contains Dockerfiles and a `Makefile` for testing against Ubuntu and Amazon Linux containers. Multi-arch builds (linux/amd64, linux/arm64) are supported via Docker Buildx.

```sh
make build           # Build all Docker images
make test            # Run install tests on all containers
make test-ubuntu     # Ubuntu only
make test-amazon     # Amazon Linux only
make manual-test     # Interactive container for manual testing
```

Pass `--skip-packages` to the test script for faster dotfiles-only checks:

```sh
./test/chezmoi-test.sh --skip-packages
```

## Useful chezmoi Commands

```sh
chezmoi diff               # Preview what would change
chezmoi apply              # Apply changes
chezmoi edit ~/.bashrc     # Edit a managed file
chezmoi add ~/.config/foo  # Track a new file
chezmoi data               # View current template variables
chezmoi edit-config        # Edit ~/.config/chezmoi/chezmoi.yaml

# Force re-run of all install scripts
chezmoi state delete-bucket --bucket=scriptState && chezmoi apply
```
