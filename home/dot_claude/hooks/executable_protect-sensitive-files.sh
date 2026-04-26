#!/usr/bin/env bash
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[[ -z "$FILE_PATH" ]] && exit 0

FILENAME=$(basename "$FILE_PATH")

block() {
  echo "Blocked: '$FILE_PATH' is a sensitive file. This action is not permitted and cannot be overridden." >&2
  exit 2
}

# .env files
[[ "$FILENAME" == ".env" ]] && block
[[ "$FILENAME" == .env.* ]] && block

# SSH private keys (not .pub)
[[ "$FILENAME" =~ ^id_(rsa|ed25519|ecdsa|dsa)$ ]] && block

# Certificate and key files
[[ "$FILENAME" == *.pem ]] && block
[[ "$FILENAME" == *.key ]] && block
[[ "$FILENAME" == *.p12 ]] && block
[[ "$FILENAME" == *.pfx ]] && block

# AWS and cloud credentials
[[ "$FILE_PATH" == */.aws/credentials ]] && block
[[ "$FILE_PATH" == */.aws/config ]] && block

# Other known credential files
[[ "$FILENAME" == ".netrc" ]] && block
[[ "$FILENAME" == ".npmrc" ]] && [[ "$FILE_PATH" == "$HOME/.npmrc" ]] && block
[[ "$FILENAME" == ".pypirc" ]] && block

exit 0
