#!/usr/bin/env bash
# PostToolUse (Edit|Write|MultiEdit): validate any spec under specs/ right after it is written.
# Errors are sent back to Claude (exit 2) so it fixes them immediately.
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
read_payload

f="$(json_get file_path)"
[ -z "$f" ] && exit 0
rel="$(rel_path "$f")"
case "$rel" in specs/*.md) ;; *) exit 0 ;; esac
[ "$(basename "$rel")" = "deviations.md" ] && exit 0

file="$(project_dir)/$rel"
[ -f "$file" ] || exit 0

errors=""
for k in id title status; do
  [ -n "$(frontmatter_get "$file" "$k")" ] || errors+="- missing frontmatter key '$k'"$'\n'
done
tr -d '\r' < "$file" | awk 'NR>1&&$0=="---"{exit} NR>1' | grep -qE '^traces:' \
  || errors+="- missing frontmatter key 'traces'"$'\n'

status="$(frontmatter_get "$file" status)"
case "$status" in
  draft|in-review|approved|superseded|proposed|accepted|"") ;;
  *) errors+="- invalid status '$status' (use draft | in-review | approved | superseded)"$'\n' ;;
esac

if [ "$status" = "approved" ]; then
  grep -q '{{' "$file" && errors+="- approved spec still contains {{placeholders}} (lines: $(grep -n '{{' "$file" | cut -d: -f1 | head -5 | tr '\n' ' '))"$'\n'
  grep -q 'OPEN QUESTION' "$file" && errors+="- approved spec still contains [OPEN QUESTION] markers"$'\n'
fi

if [ -n "$errors" ]; then
  printf '[sdd-guardrail] %s has format problems:\n%s' "$rel" "$errors" >&2
  exit 2
fi
exit 0
