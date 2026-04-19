#!/usr/bin/env zsh
# dev-test.sh — Smoke tests for the dev container.
# Verifies that chezmoi applied correctly and key tools are present.
# Run inside the container: zsh /dotfiles/test/dev-test.sh

set -uo pipefail

trap 'echo "[ERROR] Script failed at line $LINENO with exit code $?"' ERR

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FAILED=0
PASSED=0

pass() { echo -e "${GREEN}[PASS]${NC} $1"; (( ++PASSED )) }
fail() { echo -e "${RED}[FAIL]${NC} $1"; (( ++FAILED )) }

check_file() {
    local path="$1" label="${2:-$1}"
    if [[ -f "$path" ]]; then pass "$label"; else fail "$label not found"; fi
}

check_dir() {
    local path="$1" label="${2:-$1}"
    if [[ -d "$path" ]]; then pass "$label"; else fail "$label not found"; fi
}

check_cmd() {
    local cmd="$1" label="${2:-$1}"
    if command -v "$cmd" &>/dev/null; then pass "$label"; else fail "$label not in PATH"; fi
}

check_bin() {
    local path="$1" label="${2:-$1}"
    if [[ -f "$path" ]]; then pass "$label"; else fail "$label not found at $path"; fi
}

echo "=== Dev Container Smoke Tests ==="
echo "User: $(whoami)  Home: $HOME"
echo ""

echo "--- Dotfiles ---"
check_file ~/.zshrc       ".zshrc"
check_file ~/.gitconfig   ".gitconfig"
check_file ~/.aliases     ".aliases"
check_file ~/.npmrc       ".npmrc"
check_file ~/.zprofile    ".zprofile"
check_file ~/.profile     ".profile"

echo ""
echo "--- Shell tools ---"
check_cmd chezmoi "chezmoi"
check_cmd git     "git"
check_cmd make    "make"

echo ""
echo "--- Version managers ---"
check_dir ~/.goenv  "goenv (~/.goenv)"
check_dir ~/.nvm    "nvm (~/.nvm)"
check_dir ~/.pyenv  "pyenv (~/.pyenv)"

echo ""
echo "--- Kubernetes ---"
check_bin /usr/local/bin/kubectl  "kubectl"
check_bin /usr/local/bin/kubectx  "kubectx"

echo ""
echo "--- Neovim ---"
check_dir ~/.config/nvim          "nvim config dir"
check_file ~/.config/nvim/init.vim "nvim init.vim"

echo ""
echo "--- AI config ---"
check_dir  ~/.claude              "claude config (~/.claude)"
check_file ~/.claude/CLAUDE.md   "CLAUDE.md"
check_file ~/.claude/settings.json "claude settings.json"

echo ""
echo "=========================="
echo "  Passed: $PASSED  Failed: $FAILED"
echo "=========================="

(( FAILED == 0 ))
