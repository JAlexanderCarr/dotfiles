#!/bin/bash
# shellcheck.sh - Lint shell scripts (and rendered chezmoi templates) with shellcheck
#
# Usage: ./test/shellcheck.sh
#
# Requires `shellcheck` and `chezmoi` on PATH.
#
# Most dotfiles carry a .tmpl suffix for consistency but contain no actual
# {{ }} template directives, so they're linted directly. The run_once_*/
# run_onchange_* install scripts DO contain template directives (package
# guards, welcome-script printf substitutions), which read as shell syntax
# errors on their own — those are rendered first via `chezmoi
# execute-template` (with every package/add-on enabled, to cover every
# branch) and the rendered output is linted instead.
#
# .zshrc and .zsh_completion are intentionally excluded: shellcheck has no
# zsh dialect, and zsh-only syntax (glob qualifiers, prompt escapes, etc.)
# reads as a parse error under every dialect shellcheck does support.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
cd "$DOTFILES_DIR"

command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck is required but not installed" >&2; exit 1; }
command -v chezmoi >/dev/null 2>&1 || { echo "chezmoi is required but not installed" >&2; exit 1; }

# error-only for now: several scripts carry pre-existing style/warning-level
# findings (e.g. SC1091 for dynamically sourced files) that are out of scope
# for this lint gate. Override with SHELLCHECK_SEVERITY=warning locally to
# see the full picture.
SEVERITY="${SHELLCHECK_SEVERITY:-error}"
FAILED=0

STATIC_FILES=(
    home/dot_bashrc.tmpl
    home/dot_profile
    home/dot_aliases
    home/dot_bash_completion
    home/dot_zprofile
    home/dot_bash_profile
    home/dot_claude/hooks/executable_block-dangerous-bash.sh
    home/dot_claude/hooks/executable_block-dangerous-git.sh
    home/dot_claude/hooks/executable_block-dangerous-rm.sh
    home/dot_claude/hooks/executable_protect-sensitive-files.sh
    home/dot_local/bin/executable_chezmoi-log-helper.sh
    home/dot_local/bin/executable_motd
    home/dot_local/bin/executable_motd-static
    home/run_onchange_post-configure-claude-json.sh
    test/chezmoi-test.sh
    test/hooks-test.sh
)

echo "==> Linting static shell files"
for f in "${STATIC_FILES[@]}"; do
    [[ -f "$f" ]] || continue
    if ! shellcheck -s bash --severity="$SEVERITY" "$f"; then
        FAILED=1
    fi
done

echo "==> Rendering and linting templated install scripts"
CONFIG_DIR="$(mktemp -d)"
trap 'rm -rf "$CONFIG_DIR"' EXIT
CONFIG="$CONFIG_DIR/chezmoi.yaml"
cat > "$CONFIG" << 'YAML'
data:
  name: "Test User"
  email: "test@example.com"
  githubUsername: "testuser"
  sshSigningKey: "~/.ssh/id_ed25519.pub"
  generateSshKey: true
  sshKeyName: "id_ed25519"
  packages:
    devtools: true
    docker: true
    go: true
    kubernetes: true
    lima: true
    node: true
    neovim: true
    python: true
  addons:
    fonts: true
    motd: true
    ai: true
    claudeProvider: "claude"
    vscode: true
    obsidian: true
YAML

for f in home/run_once_*.tmpl home/run_onchange_*.tmpl; do
    [[ -f "$f" ]] || continue
    if ! chezmoi --config "$CONFIG" execute-template < "$f" | shellcheck -s bash --severity="$SEVERITY" -; then
        echo "[shellcheck] issues found in rendered $f" >&2
        FAILED=1
    fi
done

if [[ $FAILED -eq 0 ]]; then
    echo "shellcheck: all checks passed"
else
    echo "shellcheck: issues found" >&2
fi
exit $FAILED
