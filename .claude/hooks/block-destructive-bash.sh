#!/usr/bin/env bash
# PreToolUse (Bash): block irreversible or high-blast-radius commands.
# Fails CLOSED. For legitimate cases the human runs the command themselves.
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
read_payload

[ "$(json_get tool_name)" = "Bash" ] || exit 0
cmd="$(json_get command)"
[ -z "$cmd" ] && exit 0

patterns=(
  'rm[[:space:]]+-[a-zA-Z]*[rR][a-zA-Z]*[[:space:]]+(--[[:space:]]+)?(/|/\*|~|~/|\*|\.|\.\.|\$HOME)([[:space:]]|$)'
  'git[[:space:]]+push[^|;&]*([[:space:]]-f([[:space:]]|$)|--force([[:space:]]|$))'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f'
  'git[[:space:]]+branch[[:space:]]+-D'
  '(drop|truncate)[[:space:]]+(table|database|schema)'
  'delete[[:space:]]+from[[:space:]]+[a-zA-Z_."]+[[:space:]]*(;|$)'
  'mkfs(\.|[[:space:]])'
  'dd[[:space:]]+if=.*of=/dev/'
  'chmod[[:space:]]+-R[[:space:]]+777'
  '(curl|wget)[^|;&]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z)?sh'
  ':\(\)[[:space:]]*\{'
  'Remove-Item[^|;&]*-Recurse[^|;&]*-Force'
  'format[[:space:]]+[a-zA-Z]:'
  'del[[:space:]]+/[sS]'
)

for p in "${patterns[@]}"; do
  if printf '%s' "$cmd" | grep -Eiq -- "$p"; then
    block "Destructive command blocked (matched: $p). If this is truly needed, ask the human to run it."
  fi
done

exit 0
