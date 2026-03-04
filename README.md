# Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/). Supports macOS and Linux (Debian/Ubuntu, Fedora, CentOS/RHEL/Amazon Linux, Arch).

## Purpose

This repository provides a reproducible, personalized development environment that can be applied to any new machine in minutes. It manages shell configuration, editor setup, Git preferences, and optional tooling installs through a single, templated source of truth. All user-specific values (name, email, signing key) are injected at install time via chezmoi's prompt system, so no secrets or personal data are stored in the repository.

## Installation

### Prerequisites

- `curl` must be available on the target machine.
- SSH key for GitHub must exist at `~/.ssh/id_github.pub` (or you will be prompted to provide a different path).

### Quick Start

```sh
# One-liner: installs chezmoi if needed, then applies dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jalexandercarr/dotfiles

# Or, if chezmoi is already installed
chezmoi init --apply jalexandercarr/dotfiles
```

### Setup Prompts

During `chezmoi init`, you will be prompted for:

| Setting | Description | Example |
|---------|-------------|---------|
| `name` | Full name used in Git commits | `Jane Doe` |
| `email` | Email address used in Git commits | `jane@example.com` |
| `githubUsername` | GitHub username | `jdoe` |
| `sshSigningKey` | Path to SSH public key for commit signing | `~/.ssh/id_github.pub` |

You will also be prompted to select which packages and add-ons to install. See [Packages](#packages) and [Add-ons](#add-ons) below.

### Updating

Pull the latest changes from the remote repo and apply them:

```sh
chezmoi update
```

To change your configuration or package selections:

```sh
chezmoi init      # re-runs prompts
chezmoi apply
```

## Managed Files

| Path | Description |
|------|-------------|
| `~/.aliases` | Shell aliases for Git, kubectl, Python, and ls |
| `~/.bashrc` / `~/.zshrc` | Interactive shell configuration |
| `~/.profile` / `~/.zprofile` / `~/.bash_profile` / `~/.bash_login` | Login shell environment and PATH setup |
| `~/.bash_completion` / `~/.zsh_completion` | Shell completion scripts |
| `~/.gitconfig` | Git config (name, email, signing key, defaults) |
| `~/.config/nvim/` | Neovim configuration with LSP, completion, and plugins |

### Shell Configuration

The Zsh configuration (`~/.zshrc`) provides:

- **Custom prompt** with Git branch, Kubernetes context/namespace, command execution time, and right-justified clock
- **History settings**: deduplication, append mode, 2000-line history
- **Tool initialization**: NVM, goenv, pyenv, and fzf are initialized if installed
- **Aliases**: sourced from `~/.aliases`

### Git Configuration

The `~/.gitconfig` is templated with your personal details and sets:

- Default branch: `main`
- Default remote: `origin`
- Pull strategy: rebase
- Commit signing: SSH (using the configured signing key)
- Editor: `nvim`
- GitHub HTTPS URLs rewritten to SSH

### Shell Aliases

**Git:**

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gaa` | `git add -A` |
| `gc` | `git commit -s` |
| `gca` | `git commit -s --amend` |
| `gch` | `git checkout` |
| `gb` | `git branch` |
| `gfp` | `git push --force-with-lease` |
| `gpu` | `git push -u origin <current-branch>` |
| `gr` | `git rebase -i` |

**kubectl:**

| Alias | Command |
|-------|---------|
| `k` | `kubectl` |
| `kn` | `kubens` |
| `kx` | `kubectx` |
| `kgp` | `kubectl get pods` |
| `kgs` | `kubectl get services` |
| `kgd` | `kubectl get deployments` |

**Other:**

| Alias | Command |
|-------|---------|
| `py` | `python3` |
| `ll` | `ls -alF` |
| `la` | `ls -A` |

### Environment Overrides

The shell profile sources `~/.env` if it exists. Use this file for machine-local environment variables that should not be tracked by chezmoi:

```sh
# Example ~/.env
export AWS_PROFILE=myprofile
export EDITOR=code
```

This file is not managed by chezmoi — create and maintain it manually.

## Packages

Packages are prompted during `chezmoi init` and installed via the OS-appropriate package manager. Each package re-runs automatically when its install script changes.

### devtools

Core development tools and build utilities.

- **macOS** (Homebrew): git, gnu-tar, gnu-sed, bash-completion, pkg-config, openssh, fzf, hub
- **Debian/Ubuntu**: build-essential, libssl-dev, make, git, g++, curl, bash-completion, pkg-config, openssh-client, fuse, software-properties-common, fzf, hub
- **Fedora**: @development-tools, openssl-devel, make, git, gcc-c++, curl, bash-completion, pkgconf-pkg-config, openssh-clients, fzf, hub
- **RHEL/CentOS**: "Development Tools" group, openssl-devel, make, git, gcc-c++, curl, bash-completion, pkgconfig, openssh-clients, fzf, hub
- **Arch**: base-devel, openssl, make, git, gcc, curl, bash-completion, pkgconf, openssh, fzf, hub

### neovim

- Neovim (pre-built binary)
- vim-plug plugin manager
- All configured plugins auto-installed on first launch (LSP, completion, gitsigns, lualine, nvim-tree, which-key)

### docker

- **macOS**: Docker Desktop (Homebrew cask)
- **Debian/Ubuntu**: Docker CE, CLI, containerd, buildx plugin, compose plugin (from Docker's official repo)
- **Fedora / RHEL / CentOS**: Docker CE, CLI, containerd (from Docker's official repo)
- **Arch**: docker

### go

- goenv (Go version manager)
- Go (installed and managed by goenv)

### kubernetes

- **macOS** (Homebrew): kind, kubectl, kubectx/kubens
- **Linux** (direct binary downloads): kind, kubectl, kubectx, kubens

### node

- NVM (Node Version Manager)
- Node.js (installed and managed by NVM)

### python

- pyenv (Python version manager)
- pyenv-virtualenv plugin
- Python (built from source via pyenv)

## Add-ons

Add-ons are supplemental features prompted separately from packages during `chezmoi init`.

### fonts

Installs FiraMono Nerd Font (.otf/.ttf files) to the system font directory.

### motd

Installs a custom message of the day displaying system info (OS, memory, disk, IP address, uptime).

- **Linux with `update-motd.d`**: installs a dynamic script into `/etc/update-motd.d/`
- **macOS and other Linux**: generates a static `/etc/motd` file

### ai

Installs global AI coding agent configuration files and the `aide` CLI. See [AI Agent Integration](#ai-agent-integration) for full details.

### vscode

Copies VS Code settings, keybindings, and a curated extensions list to the OS-appropriate VS Code user directory. If the `code` CLI is available, extensions are installed automatically.

- **macOS**: `~/Library/Application Support/Code/User/`
- **Linux**: `~/.config/Code/User/`

## AI Agent Integration

The `ai` add-on installs global preferences for AI coding agents (Claude Code, OpenAI Codex) and the `aide` CLI for bootstrapping project-level instruction files.

### What Gets Installed

| Path | Description |
|------|-------------|
| `~/.config/aide/AI_PREFERENCES.md` | Canonical global AI preferences shared across all agents |
| `~/.claude/CLAUDE.md` | Global Claude Code instructions (symlink to `AI_PREFERENCES.md`) |
| `~/.codex/AGENTS.md` | Global OpenAI Codex instructions (symlink to `AI_PREFERENCES.md`) |
| `~/.config/aide/ai-templates/` | Template library for `aide init` |
| `~/.local/bin/aide` | AI Development Environment CLI |

Both `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` are symlinks pointing to the same `AI_PREFERENCES.md`, ensuring all agents follow identical global preferences.

### The `aide` CLI

`aide` bootstraps and manages AI agent instruction files for individual projects.

```sh
aide init <type...>        # Generate AI instruction files from templates
aide status                # Show agent file status in current directory
aide templates             # List available templates
aide templates add <name>  # Create a new template scaffold
aide agents                # List supported agents and their files
aide doctor                # Verify global AI config is properly installed
aide --help
```

**Generating project instruction files:**

```sh
aide init go               # Go project
aide init python           # Python project
aide init typescript       # TypeScript/Node project
aide init go infrastructure  # Compose multiple templates
aide init go -a claude     # Only generate the Claude file
```

`aide init` creates `AGENTS.md` as the canonical file and `CLAUDE.md` as a symlink to it, so all agents share a single source of truth per project.

**Shell aliases** (available in bash/zsh):

| Alias | Command |
|-------|---------|
| `ai` | `aide` |
| `ais` | `aide status` |
| `ait` | `aide templates` |
| `aid` | `aide doctor` |

### Template Library

Templates are stored in `~/.config/aide/ai-templates/` and composed by `aide init`.

| Template | Purpose |
|----------|---------|
| `base.md` | Universal rules included in every project |
| `general.md` | General AI coding assistant guidelines |
| `go.md` | Go conventions |
| `python.md` | Python conventions |
| `typescript.md` | TypeScript/Node conventions |
| `infrastructure.md` | Terraform/Kubernetes/IaC conventions |

See [docs/ai-agents.md](docs/ai-agents.md) for complete documentation.

## Common Commands

```sh
chezmoi diff               # Preview what would change
chezmoi apply              # Apply changes to the home directory
chezmoi update             # Pull and apply remote changes
chezmoi edit ~/.bashrc     # Edit a managed file
chezmoi add ~/.config/foo  # Add a new file to chezmoi
chezmoi init               # Re-run prompts to change settings
chezmoi data               # View current template data
chezmoi edit-config        # Edit the chezmoi config file directly
```

### Re-run Install Scripts

```sh
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Testing

The `build/` directory contains Dockerfiles and a `Makefile` for testing the installation against Ubuntu and Amazon Linux containers.

```sh
make build           # Build all Docker images (Ubuntu and Amazon Linux)
make test            # Run install tests on all containers
make test-ubuntu     # Run tests on Ubuntu only
make test-amazon     # Run tests on Amazon Linux only
make manual-test     # Launch an interactive container for manual testing
```

Multi-arch builds (linux/amd64, linux/arm64) are supported via Docker Buildx.

## Default Configuration

The following table shows the defaults presented during `chezmoi init`. All settings can be changed by re-running `chezmoi init`.

| Setting | Default |
|---------|---------|
| `sshSigningKey` | `~/.ssh/id_github.pub` |
| **Packages** | |
| devtools | on |
| neovim | on |
| docker | off |
| go | on |
| kubernetes | on |
| node | on |
| python | on |
| **Add-ons** | |
| fonts | off |
| motd | on |
| ai | on |
| vscode | on |

To inspect or edit the current configuration directly:

```sh
chezmoi data                # View all current template variables
chezmoi edit-config         # Open ~/.config/chezmoi/chezmoi.yaml in your editor
```
