# Dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/). Supports macOS and Linux (Debian/Ubuntu, Fedora, CentOS/RHEL/Amazon Linux, Arch).

## Quick Start

```sh
# One-liner (installs chezmoi if needed)
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jalexandercarr/dotfiles

# Or if chezmoi is already installed
chezmoi init --apply jalexandercarr/dotfiles
```

During `chezmoi init`, you'll be prompted for:

| Setting | Description |
|---------|-------------|
| `name` | Full name (for git commits) |
| `email` | Email address |
| `githubUsername` | GitHub username |
| `sshSigningKey` | Path to SSH signing key (default: `~/.ssh/id_github.pub`) |

You'll also choose which [optional packages](#optional-packages) to install.

## Dotfiles

| File | Description |
|------|-------------|
| `.aliases` | Shell aliases (git, kubectl, ls, python) |
| `.bashrc` / `.zshrc` | Shell configuration (Bash and Zsh) |
| `.profile` / `.zprofile` / `.bash_profile` / `.bash_login` | Login shell environment |
| `.bash_completion` / `.zsh_completion` | Completion scripts |
| `.gitconfig` | Git config (templated with name/email/signing key) |
| `.config/nvim/` | Neovim configuration with LSP, completion, and plugins |

## Environment Overrides (`.env`)

The shell profile sources `~/.env` if it exists. Use this file for machine-local environment variables that shouldn't be tracked by chezmoi:

```sh
# Example ~/.env
export AWS_PROFILE=myprofile
export EDITOR=code
```

This file is **not** managed by chezmoi — create and maintain it manually.

## Optional Packages

Each package is toggled during `chezmoi init` and installed via OS-appropriate package managers.

### devtools (default: on)

Core development tools:

- **macOS**: git, gnu-tar, gnu-sed, bash-completion, pkg-config, openssh (via Homebrew)
- **Debian/Ubuntu**: build-essential, libssl-dev, make, git, g++, curl, bash-completion, pkg-config, openssh-client, fuse, software-properties-common
- **Fedora**: @development-tools, openssl-devel, make, git, gcc-c++, curl, bash-completion, pkgconf-pkg-config, openssh-clients
- **RHEL/CentOS**: "Development Tools" group, openssl-devel, make, git, gcc-c++, curl, bash-completion, pkgconfig, openssh-clients
- **Arch**: base-devel, openssl, make, git, gcc, curl, bash-completion, pkgconf, openssh

### neovim (default: on)

- Neovim (pre-built binary)
- vim-plug plugin manager
- All configured plugins auto-installed (LSP, completion, gitsigns, lualine, nvim-tree, which-key)

### docker (default: off)

- **macOS**: Docker Desktop (via Homebrew cask)
- **Debian/Ubuntu**: Docker CE, CLI, containerd, buildx plugin, compose plugin (from Docker's official repo)
- **Fedora**: Docker CE, CLI, containerd (from Docker's official repo)
- **RHEL/CentOS**: Docker CE, CLI, containerd (from Docker's official repo)
- **Arch**: docker

### go (default: off)

- goenv (Go version manager)
- Go (managed by goenv)

### kubernetes (default: off)

- **macOS** (via Homebrew): kind, kubectl, kubectx/kubens
- **Linux** (direct binary downloads): kind, kubectl, kubectx, kubens

### node (default: off)

- NVM (Node Version Manager)
- Node.js (managed by NVM)

### python (default: off)

- pyenv (Python version manager)
- pyenv-virtualenv plugin
- Python (built from source via pyenv)

### fonts (default: on)

- FiraMono Nerd Font (.otf/.ttf files copied to system font directory)

### motd add-on (default: off)

- Custom `/etc/motd` displaying system info (OS, memory, disk, IP, uptime)

### AI Agent Configs (optional)

| File | Description |
|------|-------------|
| `.config/aide/AI_PREFERENCES.md` | Shared global AI preferences (canonical) |
| `.claude/CLAUDE.md` | Global Claude Code instructions (symlink → AI_PREFERENCES.md) |
| `.codex/AGENTS.md` | Global OpenAI Codex instructions (symlink → AI_PREFERENCES.md) |
| `.config/aide/ai-templates/` | Project template library for `aide` |
| `.local/bin/aide` | AI Development Environment CLI |

See [docs/ai-agents.md](docs/ai-agents.md) for full documentation.

## Updating

Pull the latest changes from the remote repo and apply them:

```sh
chezmoi update
```

To change your configuration or package selections:

```sh
chezmoi init
chezmoi apply
```

## Common Commands

```sh
chezmoi diff              # Preview changes
chezmoi apply             # Apply changes
chezmoi update            # Pull and apply remote changes
chezmoi edit ~/.bashrc    # Edit a managed file
chezmoi add ~/.config/foo # Add a new file
chezmoi init              # Re-run prompts to change settings
chezmoi data              # View current template data
```

### Re-run Install Scripts

```sh
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Testing

```sh
cd build
make build-ubuntu && make test-ubuntu
make build-amazon && make test-amazon
```
