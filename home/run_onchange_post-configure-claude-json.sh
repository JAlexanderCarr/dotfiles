#!/bin/bash
# Ensure ~/.claude.json has prStatusFooterEnabled set to false.
# Creates the file if missing; preserves all existing keys.

CLAUDE_JSON="${HOME}/.claude.json"

if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found; skipping ~/.claude.json configuration" >&2
    exit 0
fi

if [ ! -f "${CLAUDE_JSON}" ]; then
    echo '{}' > "${CLAUDE_JSON}"
fi

tmp="$(mktemp)"
jq '.prStatusFooterEnabled = false' "${CLAUDE_JSON}" > "${tmp}" && mv "${tmp}" "${CLAUDE_JSON}"
