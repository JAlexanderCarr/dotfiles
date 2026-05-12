# Packages

Each package is prompted during `chezmoi init` and re-runs automatically when its install script changes.

## devtools

Core development tools and build utilities.

| Platform | Packages |
|----------|----------|
| macOS | git, gnu-tar, gnu-sed, bash-completion, pkg-config, openssh, fzf, tmux |
| Debian/Ubuntu | build-essential, libssl-dev, make, git, g++, curl, bash-completion, pkg-config, openssh-client, fzf, tmux |
| Fedora | @development-tools, openssl-devel, make, git, gcc-c++, curl, bash-completion, fzf, tmux |
| RHEL/CentOS | "Development Tools" group, openssl-devel, make, git, gcc-c++, curl, bash-completion, fzf, tmux |
| Arch | base-devel, openssl, make, git, gcc, curl, bash-completion, openssh, fzf, tmux |

## neovim

- Neovim (pre-built binary)
- vim-plug plugin manager
- Plugins auto-installed on first launch: LSP, completion, gitsigns, lualine, nvim-tree, which-key

## docker

| Platform | Method |
|----------|--------|
| macOS | Docker Desktop (Homebrew cask) |
| Debian/Ubuntu | Docker CE + CLI + containerd + buildx + compose (official repo) |
| Fedora / RHEL / CentOS | Docker CE + CLI + containerd (official repo) |
| Arch | docker |

## go

- goenv (Go version manager)
- Go installed and managed via goenv

## kubernetes

| Platform | Method |
|----------|--------|
| macOS | kind, kubectl, kubectx/kubens via Homebrew |
| Linux | kind, kubectl, kubectx, kubens via direct binary downloads |

## node

- NVM (Node Version Manager)
- Node.js installed and managed via NVM

## python

- pyenv + pyenv-virtualenv
- Python built from source via pyenv

## fonts

FiraMono Nerd Font (.otf/.ttf) installed to the system font directory.

## motd

Custom message of the day showing OS, memory, disk, IP address, and uptime.

- Linux with `update-motd.d`: dynamic script in `/etc/update-motd.d/`
- macOS and other Linux: static `/etc/motd`

## vscode

Copies settings, keybindings, and extensions list to the VS Code user directory. Installs extensions automatically if `code` CLI is available.

| Platform | Path |
|----------|------|
| macOS | `~/Library/Application Support/Code/User/` |
| Linux | `~/.config/Code/User/` |

## obsidian

Scaffolds two Obsidian vaults at `~/vaults/`:

| Vault | Purpose |
|-------|---------|
| `personal` | Personal notes, meeting notes, AI inbox workflow |
| `libdex` | Reference library and knowledge base |

Each vault includes pre-configured `.obsidian/` settings (plugins, appearance, hotkeys) and a `help/` directory with usage documentation.
