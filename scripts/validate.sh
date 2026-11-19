#!/usr/bin/env bash
# Validates kit structure:
#  - templates/*.md have id, title, status, traces
#  - .claude/agents/*.md have name (matching filename), description, tools
#  - .claude/commands/*.md have description
#  - .claude/skills/*/SKILL.md have name (matching folder) and description
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
fail=0

fm_get() { # file key -> value from the first frontmatter block
  awk -v k="$2" 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1{ if (index($0,k":")==1) {sub("^"k":[ ]*","");print;exit} }' "$1"
}
need() { # file key
  [ -n "$(fm_get "$1" "$2")" ] || { echo "MISSING '$2' in $1"; fail=1; }
}

while IFS= read -r f; do
  for k in id title status; do need "$f" "$k"; done
  grep -qE '^traces:' "$f" || { echo "MISSING 'traces' in $f"; fail=1; }
done < <(find templates -name '*.md' 2>/dev/null)

for f in .claude/agents/*.md; do
  [ -e "$f" ] || continue
  for k in name description tools; do need "$f" "$k"; done
  [ "$(fm_get "$f" name)" = "$(basename "$f" .md)" ] || { echo "NAME != filename in $f"; fail=1; }
done

for f in .claude/commands/*.md; do
  [ -e "$f" ] || continue
  need "$f" description
done

for f in .claude/skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  for k in name description; do need "$f" "$k"; done
  [ "$(fm_get "$f" name)" = "$(basename "$(dirname "$f")")" ] || { echo "NAME != folder in $f"; fail=1; }
done

[ "$fail" -eq 0 ] && echo "validate: OK"
exit $fail
