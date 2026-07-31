#!/bin/bash
# hooks-test.sh - Exercise the Claude Code safety hooks with representative
# JSON payloads and assert their exit codes.
#
# Usage: ./test/hooks-test.sh
#
# Runs entirely on the host (no container needed). Requires jq (to build the
# "jq missing" fail-closed scenario, jq itself doesn't need to be absent —
# we just hide it from the hook's PATH for that one case).
#
# Exit codes the hooks use: 2 = blocked, 0 = allowed.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$DOTFILES_DIR/home/dot_claude/hooks"

BASH_HOOK="$HOOKS_DIR/executable_block-dangerous-bash.sh"
GIT_HOOK="$HOOKS_DIR/executable_block-dangerous-git.sh"
RM_HOOK="$HOOKS_DIR/executable_block-dangerous-rm.sh"
SENSITIVE_HOOK="$HOOKS_DIR/executable_protect-sensitive-files.sh"

command -v jq >/dev/null 2>&1 || { echo "jq is required to run this test" >&2; exit 1; }

PASSED=0
FAILED=0

# Usage: check <hook> <description> <json-payload> <expected-exit-code>
check() {
    local hook="$1" desc="$2" payload="$3" expected="$4"
    local actual
    actual=$(printf '%s' "$payload" | bash "$hook" >/dev/null 2>&1; echo $?)
    if [[ "$actual" == "$expected" ]]; then
        echo "[PASS] $desc (exit $actual)"
        ((PASSED++))
    else
        echo "[FAIL] $desc (expected exit $expected, got $actual)"
        ((FAILED++))
    fi
}

echo "== block-dangerous-bash.sh =="
check "$BASH_HOOK" "fork bomb is blocked" \
    '{"tool_input":{"command":":(){ :|:&};:"}}' 2
check "$BASH_HOOK" "chmod -R 777 / is blocked" \
    '{"tool_input":{"command":"sudo chmod -R 777 /"}}' 2
check "$BASH_HOOK" "dd to /dev/sda is blocked" \
    '{"tool_input":{"command":"dd if=/dev/zero of=/dev/sda"}}' 2
check "$BASH_HOOK" "dd to /dev/nvme0n1 is blocked" \
    '{"tool_input":{"command":"dd if=/dev/zero of=/dev/nvme0n1"}}' 2
check "$BASH_HOOK" "dd to /dev/mmcblk0 is blocked" \
    '{"tool_input":{"command":"dd if=/dev/zero of=/dev/mmcblk0"}}' 2
check "$BASH_HOOK" "dd to a regular file is allowed" \
    '{"tool_input":{"command":"dd if=/dev/zero of=/tmp/backup.img bs=1M count=10"}}' 0
check "$BASH_HOOK" "safe command is allowed" \
    '{"tool_input":{"command":"echo hello world"}}' 0

echo "== block-dangerous-git.sh =="
check "$GIT_HOOK" "git push -f is blocked" \
    '{"tool_input":{"command":"git push -f origin main"}}' 2
check "$GIT_HOOK" "git reset --hard is blocked" \
    '{"tool_input":{"command":"git reset --hard HEAD~1"}}' 2
check "$GIT_HOOK" "git stash is blocked" \
    '{"tool_input":{"command":"git stash"}}' 2
check "$GIT_HOOK" "compound command with a dangerous git op is blocked" \
    '{"tool_input":{"command":"cd /tmp/repo && git reset --hard origin/main"}}' 2
check "$GIT_HOOK" "gh pr merge is blocked (not in allowlist)" \
    '{"tool_input":{"command":"gh pr merge 5"}}' 2
check "$GIT_HOOK" "gh api with -X DELETE is blocked" \
    '{"tool_input":{"command":"gh api -X DELETE repos/foo/bar"}}' 2
check "$GIT_HOOK" "git status is allowed" \
    '{"tool_input":{"command":"git status"}}' 0
check "$GIT_HOOK" "git commit is allowed" \
    '{"tool_input":{"command":"git commit -m \"fix: something\""}}' 0
check "$GIT_HOOK" "gh pr view is allowed" \
    '{"tool_input":{"command":"gh pr view 5"}}' 0
check "$GIT_HOOK" "compound command with a safe git op is allowed" \
    '{"tool_input":{"command":"mkdir -p out && git add out"}}' 0
check "$GIT_HOOK" "non-git command is allowed" \
    '{"tool_input":{"command":"npm install"}}' 0

echo "== block-dangerous-rm.sh =="
check "$RM_HOOK" "rm -rf / is blocked" \
    '{"tool_input":{"command":"rm -rf /"}}' 2
check "$RM_HOOK" "rm -rf ~ is blocked" \
    '{"tool_input":{"command":"rm -rf ~"}}' 2
check "$RM_HOOK" "rm --no-preserve-root is blocked" \
    '{"tool_input":{"command":"rm --no-preserve-root -rf /"}}' 2
check "$RM_HOOK" "rm -rf on a project directory is allowed" \
    '{"tool_input":{"command":"rm -rf ./build"}}' 0

echo "== protect-sensitive-files.sh =="
check "$SENSITIVE_HOOK" ".env is blocked" \
    '{"tool_input":{"file_path":"/home/dev/.env"}}' 2
check "$SENSITIVE_HOOK" "SSH private key is blocked" \
    '{"tool_input":{"file_path":"/home/dev/.ssh/id_ed25519"}}' 2
check "$SENSITIVE_HOOK" "AWS credentials file is blocked" \
    '{"tool_input":{"file_path":"/home/dev/.aws/credentials"}}' 2
check "$SENSITIVE_HOOK" "SSH public key is allowed" \
    '{"tool_input":{"file_path":"/home/dev/.ssh/id_ed25519.pub"}}' 0
check "$SENSITIVE_HOOK" "an ordinary file is allowed" \
    '{"tool_input":{"file_path":"/home/dev/notes.md"}}' 0

echo "== fail-closed without jq =="
# Hide jq from PATH (rather than requiring it to be uninstalled) by building
# a minimal PATH of symlinks to just the binaries each hook needs, minus jq.
NO_JQ_DIR="$(mktemp -d)"
trap 'rm -rf "$NO_JQ_DIR"' EXIT
for bin in bash cat grep sed basename printf tr env; do
    src="$(command -v "$bin")"
    [[ -n "$src" ]] && ln -s "$src" "$NO_JQ_DIR/$bin"
done

check_no_jq() {
    local hook="$1" desc="$2" payload="$3"
    local actual
    actual=$(printf '%s' "$payload" | env -i PATH="$NO_JQ_DIR" bash "$hook" >/dev/null 2>&1; echo $?)
    if [[ "$actual" == "2" ]]; then
        echo "[PASS] $desc (exit $actual)"
        ((PASSED++))
    else
        echo "[FAIL] $desc (expected exit 2, got $actual)"
        ((FAILED++))
    fi
}

check_no_jq "$BASH_HOOK" "block-dangerous-bash.sh fails closed without jq" '{"tool_input":{"command":"echo hi"}}'
check_no_jq "$GIT_HOOK" "block-dangerous-git.sh fails closed without jq" '{"tool_input":{"command":"git status"}}'
check_no_jq "$RM_HOOK" "block-dangerous-rm.sh fails closed without jq" '{"tool_input":{"command":"echo hi"}}'
check_no_jq "$SENSITIVE_HOOK" "protect-sensitive-files.sh fails closed without jq" '{"tool_input":{"file_path":"/home/dev/notes.md"}}'

echo ""
echo "============================================="
echo "  Hooks Test Summary"
echo "============================================="
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo "============================================="

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
exit 0
