#!/usr/bin/env bash
set -euo pipefail

# Fail closed: without jq this hook can't inspect the command at all, so a
# missing jq must block rather than silently letting everything through.
command -v jq >/dev/null 2>&1 || { echo "jq required for safety hook" >&2; exit 2; }

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[[ -z "$COMMAND" ]] && exit 0

block() {
  echo "Blocked: $1. This action is not permitted and cannot be overridden." >&2
  exit 2
}

# Fork bomb
echo "$COMMAND" | grep -qF ':(){ :|:&};:' \
  && block "fork bomb detected"

# World-writable chmod on broad paths
echo "$COMMAND" | grep -qE 'chmod\s+-?R\s+[0-9]*7\s+/' \
  && block "'chmod -R *7 /' sets world-writable permissions on system paths"
echo "$COMMAND" | grep -qE 'chmod\s+777\s+/' \
  && block "'chmod 777 /' sets world-writable permissions on a system path"

# Overwriting critical system files via redirection
echo "$COMMAND" | grep -qE '>\s*/etc/(passwd|shadow|sudoers|hosts)\b' \
  && block "redirecting output to a critical system file"

# Disk wipe
echo "$COMMAND" | grep -qE 'dd\s.*of=/dev/(s|h|v|xv)d[a-z]\b' \
  && block "'dd' targeting a raw disk device"
echo "$COMMAND" | grep -qE 'dd\s.*of=/dev/disk[0-9]' \
  && block "'dd' targeting a raw disk device"
echo "$COMMAND" | grep -qE 'dd\s.*of=/dev/nvme[0-9]+n[0-9]+\b' \
  && block "'dd' targeting a raw disk device"
echo "$COMMAND" | grep -qE 'dd\s.*of=/dev/mmcblk[0-9]+\b' \
  && block "'dd' targeting a raw disk device"

# Shutdown/reboot without explicit intent
echo "$COMMAND" | grep -qE '^\s*(shutdown|reboot|halt|poweroff)\b' \
  && block "system shutdown/reboot requires explicit user confirmation"

exit 0
