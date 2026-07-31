#!/usr/bin/env bash
set -euo pipefail

# Fail closed: without jq this hook can't inspect the command at all, so a
# missing jq must block rather than silently letting everything through.
command -v jq >/dev/null 2>&1 || { echo "jq required for safety hook" >&2; exit 2; }

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[[ -z "$COMMAND" ]] && exit 0

# Inspect git/gh anywhere in the command, not just at the start — otherwise
# compound commands like `cd repo && git push -f` skip inspection entirely.
echo "$COMMAND" | grep -qE '(^|[;&|]|&&|\|\|)\s*(git|gh)\b' || exit 0

block() {
  echo "Blocked: $1. This action is not permitted and cannot be overridden." >&2
  exit 2
}

# ── git: denylist ─────────────────────────────────────────────────────────────
# The set of dangerous git operations is small and stable — denylist is appropriate.

if echo "$COMMAND" | grep -qE '(^|[;&|]|&&|\|\|)\s*git\b'; then
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

  # Stash (hides uncommitted changes in a way that's easy to lose or forget)
  echo "$COMMAND" | grep -qE 'git stash\b' \
    && block "'git stash' is not permitted; commit or discard changes explicitly"
fi

# ── gh: allowlist ─────────────────────────────────────────────────────────────
# gh has too many subcommands to enumerate dangerous ones — allowlist known-safe
# operations and block everything else by default.

if echo "$COMMAND" | grep -qE '(^|[;&|]|&&|\|\|)\s*gh\b'; then
  # Auth: status only (login/logout/refresh/switch require human presence)
  echo "$COMMAND" | grep -qE '\bgh auth status\b' && exit 0

  # Global status
  echo "$COMMAND" | grep -qE '\bgh status\b' && exit 0

  # PR: read, create, review, comment, edit, checkout, diff, checks, ready
  echo "$COMMAND" | grep -qE '\bgh pr (view|list|status|checkout|diff|checks|create|comment|review|ready|edit)\b' && exit 0

  # Issue: read, create, comment, edit, close (delete is not permitted)
  echo "$COMMAND" | grep -qE '\bgh issue (view|list|status|create|comment|edit|close)\b' && exit 0

  # Repo: read and clone only
  echo "$COMMAND" | grep -qE '\bgh repo (view|list|clone)\b' && exit 0

  # Release: read only
  echo "$COMMAND" | grep -qE '\bgh release (view|list)\b' && exit 0

  # Workflow and run: read only
  echo "$COMMAND" | grep -qE '\bgh (workflow|run) (view|list|watch)\b' && exit 0

  # Labels, milestones, projects: list only
  echo "$COMMAND" | grep -qE '\bgh label list\b' && exit 0
  echo "$COMMAND" | grep -qE '\bgh milestone list\b' && exit 0
  echo "$COMMAND" | grep -qE '\bgh project list\b' && exit 0

  # API: allow GET requests (default method); block explicit non-GET methods
  if echo "$COMMAND" | grep -qE '\bgh api\b'; then
    echo "$COMMAND" | grep -qiE '(-X|--method)\s+(POST|PUT|PATCH|DELETE)\b' \
      && block "'gh api' with a mutating method (POST/PUT/PATCH/DELETE) is not permitted"
    exit 0
  fi

  # Anything else is not in the allowlist
  block "gh command not permitted; only read, create, and review operations are allowed"
fi
