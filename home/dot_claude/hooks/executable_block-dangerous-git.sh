#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[[ -z "$COMMAND" ]] && exit 0

# Only inspect git commands
echo "$COMMAND" | grep -qE '^\s*git\b' || exit 0

block() {
  echo "Blocked: $1. This action is not permitted and cannot be overridden." >&2
  exit 2
}

# Force push (any form)
echo "$COMMAND" | grep -qE 'git push.+(-f\b|--force\b|--force-with-lease\b)' \
  && block "force push is not permitted and cannot be overridden"

# Force push where -f flag comes before the remote/branch
echo "$COMMAND" | grep -qE 'git push\s+-f\b' \
  && block "force push is not permitted and cannot be overridden"

# Reset hard
echo "$COMMAND" | grep -qE 'git reset --hard' \
  && block "'git reset --hard' permanently discards uncommitted changes"

# Clean (any -f variant: -f, -fd, -fdx, -fX, etc.)
echo "$COMMAND" | grep -qE 'git clean\s+-[a-zA-Z]*f' \
  && block "'git clean -f' permanently deletes untracked files"

# Force branch delete
echo "$COMMAND" | grep -qE 'git branch\s+-D\b' \
  && block "'git branch -D' force-deletes a branch without merge check"

# Rebase --abort or --skip while mid-rebase could lose work in edge cases — skip these, they're generally safe

# Restore working tree (discards local changes); --staged is safe
echo "$COMMAND" | grep -qE 'git restore\s' && ! echo "$COMMAND" | grep -qE '--staged' \
  && block "'git restore' without --staged discards uncommitted working tree changes"

# Checkout -- (discard working tree changes)
echo "$COMMAND" | grep -qE 'git checkout\s+--\s' \
  && block "'git checkout --' discards uncommitted changes"
