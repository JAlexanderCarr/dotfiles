#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[[ -z "$COMMAND" ]] && exit 0

# Patterns that target root, home, or use --no-preserve-root
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "rm -rf \${HOME}"
  "rm -fr /"
  "rm -fr ~"
  "rm -fr \$HOME"
  "rm -fr \${HOME}"
  "--no-preserve-root"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$pattern"* ]]; then
    echo "Blocked: dangerous rm command ('$pattern'). This action is not permitted and cannot be overridden." >&2
    exit 2
  fi
done
