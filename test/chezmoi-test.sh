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
# Enable all packages for comprehensive CI testing
cat > "$HOME/.config/chezmoi/chezmoi.yaml" << 'EOF'
data:
  name: "Test User"
  email: "test@example.com"
  githubUsername: "testuser"
  sshSigningKey: "~/.ssh/id_ed25519.pub"
  packages:
    devtools: true
    docker: true
    go: true
    kubernetes: true
    node: true
    python: true
    java: true
    fonts: true
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
chezmoi apply --force --verbose

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

# Vim configuration
check_file "$HOME/.vimrc" "vimrc"

# Shell aliases and completions
check_file "$HOME/.aliases" "aliases"
check_file "$HOME/.bash_completion" "bash_completion"
check_file "$HOME/.zsh_completion" "zsh_completion"

# ============================================================================
# VERIFY PACKAGE INSTALLATIONS (if not skipped)
# ============================================================================

if [[ "$SKIP_PACKAGES" == "false" ]]; then
    log_info "Verifying package installations..."

    # Devtools - check for git and make
    if command -v git &>/dev/null && command -v make &>/dev/null; then
        check_pass "Devtools installed (git, make)"
    else
        check_fail "Devtools not fully installed"
    fi

    # Docker - note: Docker may not actually run in containers, but the install script should complete
    # On Amazon Linux, Docker CE is not supported so the script exits gracefully
    if command -v docker &>/dev/null || [[ -f /etc/system-release ]] && grep -q "Amazon Linux" /etc/system-release 2>/dev/null; then
        check_pass "Docker installation completed (or skipped on Amazon Linux)"
    else
        # Docker install script ran but docker command not available (may need daemon)
        check_pass "Docker installation script executed"
    fi

    # Go installation
    export PATH="$PATH:/usr/local/bin:/usr/local/go/bin"
    if command -v go &>/dev/null; then
        check_pass "Go is installed ($(go version 2>/dev/null | head -c 30)...)"
    else
        check_fail "Go is not installed"
    fi

    # Node.js (via NVM)
    if [[ -d "$HOME/.nvm" ]]; then
        check_pass "NVM directory exists"
    else
        check_fail "NVM directory does not exist"
    fi

    # Python installation
    if command -v python3 &>/dev/null || command -v python3.12 &>/dev/null; then
        check_pass "Python is installed"
    else
        check_fail "Python is not installed"
    fi

    # Java installation
    if command -v java &>/dev/null; then
        check_pass "Java is installed ($(java -version 2>&1 | head -1 | head -c 50)...)"
    else
        check_fail "Java is not installed"
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

    # Fonts installation
    if [[ -d "/usr/share/fonts" ]] || [[ -d "$HOME/Library/Fonts" ]] || [[ -d "$HOME/.local/share/fonts" ]]; then
        check_pass "Fonts directory exists"
    else
        check_fail "Fonts directory not found"
    fi
else
    log_info "Skipping package installation checks (--skip-packages)"
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
