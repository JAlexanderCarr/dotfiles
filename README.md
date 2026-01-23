# Dotfiles

A cross-platform dotfiles repository managed with [chezmoi](https://www.chezmoi.io/). This setup provides OS-aware configuration files, optional package installations, and support for multiple profiles (personal/work).

## Features

- 🏠 **chezmoi-managed**: Modern dotfiles management with templates, secrets support, and multi-machine sync
- 🔧 **Profile Support**: Configure for personal or work environments during installation
- 📦 **Optional Packages**: Choose which development tools to install during setup
- 🖥️ **Cross-Platform**: Supports macOS and Linux (Debian/Ubuntu, Fedora, CentOS/RHEL, Arch)
- 🔤 **Nerd Fonts**: Automatic installation of developer fonts

## Quick Start

### One-Line Install

```sh
chezmoi init --apply JAlexanderCarr/dotfiles
```

Or if you don't have chezmoi installed yet:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply JAlexanderCarr/dotfiles
```

### Manual Installation

1. **Install chezmoi**

   ```sh
   # macOS
   brew install chezmoi

   # Linux
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```

2. **Initialize with this repo**

   ```sh
   chezmoi init JAlexanderCarr/dotfiles
   ```

3. **Preview changes**

   ```sh
   chezmoi diff
   ```

4. **Apply configuration**

   ```sh
   chezmoi apply
   ```

## Configuration

During `chezmoi init`, you'll be prompted for:

| Setting | Description |
|---------|-------------|
| `name` | Your full name (for git commits) |
| `email` | Your email address |
| `githubUsername` | Your GitHub username |
| `sshSigningKey` | Path to SSH signing key |
| `profile` | `personal` or `work` |

### Optional Packages

You can enable/disable the following during setup:

- **devtools**: Development tools (git, make, build-essential)
- **docker**: Docker and Docker Compose
- **go**: Go programming language
- **kubernetes**: kubectl, kind, kubectx, kubens
- **node**: Node.js via NVM
- **python**: Python from source or package manager
- **java**: OpenJDK
- **fonts**: Nerd Fonts (FiraMono)

## Repository Structure

```
.
├── .chezmoiroot             # Points chezmoi to home/ as source directory
├── home/                    # chezmoi source directory
│   ├── .chezmoi.yaml.tmpl   # Config template (prompts for user data)
│   ├── .chezmoiignore       # Files to ignore
│   ├── .chezmoiattributes   # File attributes
│   ├── dot_*                # Dotfiles (installed as .*)
│   ├── dot_*.tmpl           # Templated dotfiles
│   ├── run_once_*           # Run-once scripts (fonts, welcome)
│   ├── run_onchange_*       # Run-on-change scripts (packages)
│   ├── fonts/               # Source font files (installed by script)
├── build/                   # Docker test environments
│   ├── Dockerfile.amazon
│   ├── Dockerfile.ubuntu
│   └── Makefile
├── files/                   # Legacy dotfiles (kept for reference)
├── fonts/                   # Source font files
├── packages/                # Legacy package scripts (kept for reference)
├── scripts/                 # Legacy installation scripts
└── README.md
```

## Managing Your Dotfiles

### Common Commands

```sh
# Check for differences
chezmoi diff

# Apply changes
chezmoi apply

# Update from remote repository
chezmoi update

# Edit a managed file
chezmoi edit ~/.bashrc

# Add a new file to chezmoi
chezmoi add ~/.config/newfile

# Re-run init to change configuration
chezmoi init

# Edit chezmoi config
chezmoi edit-config
```

### Changing Configuration

To change your profile or package selections:

```sh
chezmoi init
chezmoi apply
```

Or manually edit `~/.config/chezmoi/chezmoi.yaml`.

## Testing in Containers

The `build/` directory contains Dockerfiles for testing the installation:

```sh
cd build

# Build and test on Ubuntu
make build-ubuntu
make test-ubuntu

# Build and test on Amazon Linux
make build-amazon
make test-amazon
```

## What Gets Installed

### Dotfiles

| File | Description |
|------|-------------|
| `.aliases` | Shell aliases for common commands |
| `.bashrc` | Bash configuration |
| `.zshrc` | Zsh configuration |
| `.profile` | Login shell environment |
| `.zprofile` | Zsh login shell environment |
| `.gitconfig` | Git configuration (templated with your name/email) |
| `.vimrc` | Vim configuration |
| `.bash_completion` | Bash completion scripts |
| `.zsh_completion` | Zsh completion scripts |

### Profile Support

When using the `work` profile, additional git configuration is included:

- `.gitconfig-work`: Include file for work-specific git settings in `~/work/` directories

## Troubleshooting

### Re-run Package Installation

Package scripts run once. To re-run them:

```sh
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### View Current Data

```sh
chezmoi data
```

### Debug Template Rendering

```sh
chezmoi execute-template < ~/.local/share/chezmoi/dot_gitconfig.tmpl
```

## Supported Operating Systems & Package Managers

- **macOS**: Homebrew
- **Debian/Ubuntu**: apt
- **Fedora**: dnf
- **CentOS/RHEL/Amazon Linux**: yum
- **Arch Linux**: pacman

## Legacy Installation

The original installation scripts are preserved in `files/`, `packages/`, and `scripts/` directories for reference. The new chezmoi-based installation is recommended.

## License

See [LICENSE](LICENSE) file.
