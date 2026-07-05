#!/bin/bash
# chezmoi-test.sh - Test chezmoi dotfiles installation
# This script is designed to run inside a Docker container with the dotfiles repo mounted
#
# Usage: ./test/chezmoi-test.sh [--skip-packages]
#
# Options:
#   --skip-packages    Skip package installation checks (faster, for dotfiles-only testing)

set -uo pipefail

# Trap to show where script failed
trap 'echo "[ERROR] Script failed at line $LINENO with exit code $?"' ERR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SKIP_PACKAGES=false
FAILED_CHECKS=0
PASSED_CHECKS=0

# Parse arguments
for arg in "$@"; do
    case $arg in
        --skip-packages)
            SKIP_PACKAGES=true
            shift
            ;;
    esac
done

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_CHECKS++))
}

check_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_CHECKS++))
}

# Check if a file exists
check_file() {
    local file="$1"
    local description="${2:-$file}"
    if [[ -f "$file" ]]; then
        check_pass "$description exists"
        return 0
    else
        check_fail "$description does not exist"
        return 1
    fi
}

# Check if a directory exists
check_dir() {
    local dir="$1"
    local description="${2:-$dir}"
    if [[ -d "$dir" ]]; then
        check_pass "$description exists"
        return 0
    else
        check_fail "$description does not exist"
        return 1
    fi
}

# Check if a command exists
check_command() {
    local cmd="$1"
    local description="${2:-$cmd}"
    if command -v "$cmd" &>/dev/null; then
        check_pass "$description is installed"
        return 0
    else
        check_fail "$description is not installed"
        return 1
    fi
}

# Check if a file contains a string
check_file_contains() {
    local file="$1"
    local pattern="$2"
    local description="${3:-$file contains $pattern}"
    if [[ -f "$file" ]] && grep -q "$pattern" "$file"; then
        check_pass "$description"
        return 0
    else
        check_fail "$description"
        return 1
    fi
}

# ============================================================================
# SETUP
# ============================================================================

log_info "Starting chezmoi dotfiles test..."
log_info "Running as user: $(whoami)"
log_info "Home directory: $HOME"

# Ensure we're in the dotfiles directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
log_info "Dotfiles directory: $DOTFILES_DIR"

# ============================================================================
# INSTALL CHEZMOI
# ============================================================================

log_info "Installing chezmoi..."
if ! command -v chezmoi &>/dev/null; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
fi
check_command chezmoi "chezmoi"

# ============================================================================
# CONFIGURE CHEZMOI
# ============================================================================

log_info "Configuring chezmoi..."

# Create chezmoi config directory
mkdir -p "$HOME/.config/chezmoi"

# Create test configuration
# Enable packages that can be tested in a container (docker, fonts, and lima binary install are excluded)
cat > "$HOME/.config/chezmoi/chezmoi.yaml" << 'EOF'
data:
  name: "Test User"
  email: "test@example.com"
  githubUsername: "testuser"
  sshSigningKey: "~/.ssh/id_ed25519.pub"
  packages:
    devtools: true
    docker: false
    go: true
    kubernetes: true
    lima: true
    node: true
    neovim: true
    python: true
  addons:
    fonts: false
    motd: true
    ai: true
    claudeProvider: "claude"
    vscode: true
    obsidian: true
EOF

check_file "$HOME/.config/chezmoi/chezmoi.yaml" "chezmoi config"

# ============================================================================
# INITIALIZE CHEZMOI WITH LOCAL SOURCE
# ============================================================================

log_info "Initializing chezmoi with local dotfiles..."

# Copy dotfiles to chezmoi source directory
mkdir -p "$HOME/.local/share/chezmoi"
cp -r "$DOTFILES_DIR"/* "$HOME/.local/share/chezmoi/"
# Copy hidden files (like .chezmoiroot) - use find to avoid issues with globs
find "$DOTFILES_DIR" -maxdepth 1 -name ".*" -type f ! -name ".git*" -exec cp {} "$HOME/.local/share/chezmoi/" \; 2>/dev/null || true

check_dir "$HOME/.local/share/chezmoi" "chezmoi source directory"
check_dir "$HOME/.local/share/chezmoi/home" "chezmoi home directory"

# ============================================================================
# APPLY CHEZMOI
# ============================================================================

log_info "Applying chezmoi configuration..."
chezmoi apply --force --verbose --keep-going || log_warn "Some scripts failed during chezmoi apply"

# Source .profile now that it's installed — sets up PATH for the rest of this script
# shellcheck disable=SC1090
. "$HOME/.profile" 2>/dev/null || true

# ============================================================================
# VERIFY DOTFILES
# ============================================================================

log_info "Verifying dotfiles installation..."

# Shell configuration files
check_file "$HOME/.bashrc" "bashrc"
check_file "$HOME/.zshrc" "zshrc"
check_file "$HOME/.profile" "profile"
check_file "$HOME/.zprofile" "zprofile"

# Git configuration
check_file "$HOME/.gitconfig" "gitconfig"
check_file_contains "$HOME/.gitconfig" "Test User" "gitconfig contains user name"
check_file_contains "$HOME/.gitconfig" "test@example.com" "gitconfig contains user email"

# Neovim configuration
check_file "$HOME/.config/nvim/init.vim" "nvim init.vim"
check_dir "$HOME/.config/nvim" "nvim config directory"
check_dir "$HOME/.local/share/nvim/site/autoload" "nvim autoload directory"
check_file "$HOME/.local/share/nvim/site/autoload/plug.vim" "vim-plug plugin manager"

# Shell aliases and completions
check_file "$HOME/.aliases" "aliases"
check_file "$HOME/.bash_completion" "bash_completion"
check_file "$HOME/.zsh_completion" "zsh_completion"

# npm configuration
check_file "$HOME/.npmrc" "npmrc"
check_file_contains "$HOME/.npmrc" "min-release-age=7" "npmrc has min-release-age=7"

# Claude Code configuration
check_file "$HOME/.claude/CLAUDE.md"                    "Claude CLAUDE.md"
check_file "$HOME/.claude/settings.json"                "Claude settings.json"
check_file "$HOME/.config/ccstatusline/settings.json"   "ccstatusline settings.json"

# Obsidian vaults — personal
check_dir  "$HOME/vaults/personal/.obsidian"                                      "personal vault .obsidian dir"
check_file "$HOME/vaults/personal/.obsidian/community-plugins.json"               "personal community-plugins.json"
check_file "$HOME/vaults/personal/home.md"                                        "personal home.md"
check_file "$HOME/vaults/personal/templates/daily.md"                             "personal daily template"
check_file "$HOME/vaults/personal/templates/meeting.md"                           "personal meeting template"
check_file "$HOME/vaults/personal/templates/notecard.md"                          "personal notecard template"
check_file "$HOME/vaults/personal/bases/daily.base"                               "personal daily base"
check_file "$HOME/vaults/personal/bases/meetings.base"                            "personal meetings base"
check_file "$HOME/vaults/personal/bases/ai-review.base"                          "personal ai-review base"
check_dir  "$HOME/vaults/personal/notes/daily"                                   "personal daily notes dir"
check_dir  "$HOME/vaults/personal/notes/meetings"                                 "personal meeting notes dir"
check_dir  "$HOME/vaults/personal/boards/notecards"                               "personal notecards board dir"
check_dir  "$HOME/vaults/personal/ai/inbox"                                       "personal ai inbox dir"
check_dir  "$HOME/vaults/personal/ai/meetings"                                    "personal ai meetings dir"
check_dir  "$HOME/vaults/personal/ai/transcripts"                                 "personal ai transcripts dir"
# Obsidian vaults — libdex
check_dir  "$HOME/vaults/libdex/.obsidian"                                        "libdex vault .obsidian dir"
check_file "$HOME/vaults/libdex/.obsidian/community-plugins.json"                 "libdex community-plugins.json"
check_file "$HOME/vaults/libdex/CLAUDE.md"                                        "libdex CLAUDE.md"
check_dir  "$HOME/vaults/libdex/wiki"                                             "libdex wiki dir"
check_dir  "$HOME/vaults/libdex/inbox"                                            "libdex inbox dir"
# Verify user notes alongside managed files are not removed on re-apply
touch "$HOME/vaults/personal/My Note.md"
chezmoi apply --force --keep-going >/dev/null 2>&1 || true
check_file "$HOME/vaults/personal/My Note.md"                                     "user note preserved after re-apply"

# ============================================================================
# VERIFY PACKAGE INSTALLATIONS (if not skipped)
# ============================================================================

if [[ "$SKIP_PACKAGES" == "false" ]]; then
    log_info "Verifying package installations..."

    # Devtools - check for git, make, and tmux
    if command -v git &>/dev/null && command -v make &>/dev/null && command -v tmux &>/dev/null; then
        check_pass "Devtools installed (git, make, tmux)"
    else
        check_fail "Devtools not fully installed"
    fi

    # Go installation (via goenv) — PATH provided by .profile sourced above
    if command -v go &>/dev/null; then
        check_pass "Go is installed ($(go version 2>/dev/null | head -c 30)...)"
    else
        check_fail "Go is not installed"
    fi

    # Node.js (via NVM)
    if [[ -d "$HOME/.nvm" ]]; then
        check_pass "NVM directory exists"
        if command -v node &>/dev/null; then
            check_pass "node is installed ($(node --version 2>/dev/null))"
        else
            check_fail "node is not on PATH"
        fi
        if command -v npm &>/dev/null; then
            check_pass "npm is installed ($(npm --version 2>/dev/null))"
        else
            check_fail "npm is not on PATH"
        fi
    else
        check_fail "NVM directory does not exist"
    fi

    # Python installation (via pyenv) — PATH provided by .profile sourced above
    if command -v python3 &>/dev/null || command -v python &>/dev/null; then
        check_pass "Python is installed ($(python3 --version 2>/dev/null || python --version 2>/dev/null))"
    else
        check_fail "Python is not installed"
    fi

    # Kubernetes tools
    if command -v kubectl &>/dev/null || [[ -f "/usr/local/bin/kubectl" ]]; then
        check_pass "kubectl is installed"
    else
        check_fail "kubectl is not installed"
    fi

    if command -v kind &>/dev/null || [[ -f "/usr/local/bin/kind" ]]; then
        check_pass "kind is installed"
    else
        check_fail "kind is not installed"
    fi

    if [[ -f "/usr/local/bin/kubectx" ]] || command -v kubectx &>/dev/null; then
        check_pass "kubectx is installed"
    else
        check_fail "kubectx is not installed"
    fi

    # Lima - validate rendered config files with limactl
    check_file "$HOME/.config/lima/dev-arm64.yaml" "Lima ARM64 VM template"
    check_file "$HOME/.config/lima/dev-x86_64.yaml" "Lima x86_64 VM template"
    for lima_config in "$HOME/.config/lima/dev-arm64.yaml" "$HOME/.config/lima/dev-x86_64.yaml"; do
        if limactl validate "$lima_config" &>/dev/null; then
            check_pass "$(basename "$lima_config") is valid (limactl validate)"
        else
            check_fail "$(basename "$lima_config") failed limactl validate"
        fi
    done

    # MOTD dynamic script
    if [[ -f "$HOME/.local/bin/motd" ]]; then
        check_pass "MOTD script exists at ~/.local/bin/motd"
        if [[ -x "$HOME/.local/bin/motd" ]]; then
            check_pass "MOTD script is executable"
        else
            check_fail "MOTD script is not executable"
        fi
    else
        check_fail "MOTD script not found at ~/.local/bin/motd"
    fi

    # MOTD static script
    check_file "$HOME/.local/bin/motd-static" "MOTD static script"

    # VSCode configuration
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
    check_dir "$VSCODE_CONFIG_DIR" "VSCode config directory"
    check_file "$VSCODE_CONFIG_DIR/settings.json" "VSCode settings.json"
    check_file "$VSCODE_CONFIG_DIR/keybindings.json" "VSCode keybindings.json"
else
    log_info "Skipping package installation checks (--skip-packages)"
fi

# ============================================================================
# VERIFY PATH CONFIGURATION
# ============================================================================

log_info "Verifying PATH configuration for bash and zsh..."

# Helper: run a command in a clean bash subshell with only .profile sourced,
# simulating a login non-interactive shell (e.g. bash -l script.sh, cron, ssh).
_check_bash_profile_path() {
    local cmd="$1"
    local desc="$2"
    local result
    result=$(bash -c '. ~/.profile 2>/dev/null && '"$cmd" 2>/dev/null)
    if [[ -n "$result" ]]; then
        check_pass "$desc on PATH after sourcing .profile (bash)"
    else
        check_fail "$desc not on PATH after sourcing .profile (bash)"
    fi
}

# ~/.local/bin must be on PATH from .profile
if bash -c '. ~/.profile 2>/dev/null && echo "$PATH"' 2>/dev/null | grep -q "$HOME/.local/bin"; then
    check_pass ".profile adds ~/.local/bin to PATH"
else
    check_fail ".profile does not add ~/.local/bin to PATH"
fi

# NVM: node and npm reachable via default alias path in .profile
if [[ -d "$HOME/.nvm" ]]; then
    _check_bash_profile_path "command -v node" "node"
    _check_bash_profile_path "command -v npm" "npm"

    # NVM shell function must be loaded in interactive bash (.bashrc sources nvm.sh)
    _nvm_ver=$(bash -i -c 'nvm --version' 2>/dev/null)
    if [[ -n "$_nvm_ver" ]]; then
        check_pass "NVM is functional in interactive bash (v${_nvm_ver})"
    else
        check_fail "NVM is not functional in interactive bash (.bashrc may not load nvm.sh)"
    fi
    unset _nvm_ver
fi

# goenv: go reachable via shims added by .profile
if [[ -d "$HOME/.goenv" ]]; then
    _check_bash_profile_path "command -v go" "go"
fi

# pyenv: python3 reachable via shims added by .profile
if [[ -d "$HOME/.pyenv" ]]; then
    _check_bash_profile_path "command -v python3" "python3"
fi

unset -f _check_bash_profile_path

# zsh PATH checks (if zsh is available)
if command -v zsh &>/dev/null; then
    # Interactive zsh sources .zshrc → NVM is loaded
    if [[ -d "$HOME/.nvm" ]]; then
        _zsh_node=$(zsh -i -c 'command -v node' 2>/dev/null)
        if [[ -n "$_zsh_node" ]]; then
            check_pass "node is on PATH in interactive zsh"
        else
            check_fail "node is not on PATH in interactive zsh (.zshrc may not load NVM)"
        fi
        unset _zsh_node
    fi

    # Login zsh sources .zprofile → .profile → goenv/pyenv shims are on PATH
    if [[ -d "$HOME/.goenv" ]]; then
        _zsh_go=$(zsh -l -c 'command -v go' 2>/dev/null)
        if [[ -n "$_zsh_go" ]]; then
            check_pass "go is on PATH in login zsh"
        else
            check_fail "go is not on PATH in login zsh (.zprofile/.profile may not add goenv shims)"
        fi
        unset _zsh_go
    fi

    if [[ -d "$HOME/.pyenv" ]]; then
        _zsh_py=$(zsh -l -c 'command -v python3' 2>/dev/null)
        if [[ -n "$_zsh_py" ]]; then
            check_pass "python3 is on PATH in login zsh"
        else
            check_fail "python3 is not on PATH in login zsh (.zprofile/.profile may not add pyenv shims)"
        fi
        unset _zsh_py
    fi
else
    log_warn "zsh not installed — skipping zsh PATH checks"
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "============================================="
echo "  Test Summary"
echo "============================================="
echo -e "  ${GREEN}Passed:${NC} $PASSED_CHECKS"
echo -e "  ${RED}Failed:${NC} $FAILED_CHECKS"
echo "============================================="

if [[ $FAILED_CHECKS -gt 0 ]]; then
    log_error "Some checks failed!"
    exit 1
else
    log_info "All checks passed!"
    exit 0
fi
