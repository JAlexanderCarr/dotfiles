# Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/). Supports macOS and Linux (Debian/Ubuntu, Fedora, CentOS/RHEL/Amazon Linux, Arch).

## Quick Start

```sh
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jalexandercarr/dotfiles

# Or, if chezmoi is already installed
chezmoi init --apply jalexandercarr/dotfiles
```

During init you'll be prompted for your name, email, GitHub username, SSH signing key path, and which packages/add-ons to install.

## Packages

Prompted during `chezmoi init`. Re-run automatically when install scripts change (except `fonts`, which is one-time).

| Package | Default | Description |
|---------|---------|-------------|
| devtools | on | Core build tools, git, fzf |
| neovim | on | Neovim with LSP, completion, plugins |
| go | on | goenv + Go |
| kubernetes | on | kind, kubectl, kubectx/kubens |
| lima | off | Lima VMs for lightweight Linux on macOS |
| node | on | NVM + Node.js |
| python | on | pyenv + Python |
| docker | off | Docker CE / Docker Desktop |

## Add-ons

| Add-on | Default | Description |
|--------|---------|-------------|
| motd | on | Custom message of the day with system info |
| vscode | on | VS Code settings, keybindings, extensions |
| ai | on | Claude Code config and settings |
| obsidian | off | Obsidian vault scaffolding at `~/vaults/personal` and `~/vaults/agent-db` |
| fonts | off | FiraMono Nerd Font (installed once, not re-run on changes) |

When `ai` is enabled, you'll also be prompted for **Claude provider** (`claude` or `bedrock`, default `claude`).

## Common Commands

```sh
chezmoi update    # Pull and apply latest changes
chezmoi diff      # Preview what would change
chezmoi apply     # Apply changes
chezmoi init      # Re-run prompts to change settings
```

## Docs

See [the full documentation](docs/index.md) for shell config, package details, Claude Code setup, and development/testing.

## Acknowledgements

- [Matt Pocock](https://github.com/mattpocock) — Some Claude Code skills adapted from [mattpocock/skills](https://github.com/mattpocock/skills)
