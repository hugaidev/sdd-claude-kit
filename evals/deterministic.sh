#!/usr/bin/env bash
# Deterministic spec evals (free, fast, CI-friendly).
# Usage: evals/deterministic.sh [project-dir] [--templates <dir>]
# Exit 0 = all checks pass, 1 = at least one failed.
#
#  D1 frontmatter valid (id = filename, legal status, traces resolve)
#  D2 required sections of the matching template exist (non-draft specs)
#  D3 approved specs have no {{placeholders}} / OPEN QUESTION markers
#  D4 traceability (REQ <-> TASK <-> TEST, undefined references)
#  D5 no duplicate IDs (NFR, BR, TASK, TEST)
#  D6 every REQ has Given/When/Then acceptance criteria
#  D7 every API endpoint traces to a REQ
#  D8 every TEST traces to a REQ
#  D9 an approved spec never depends on an unapproved upstream spec
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="."; TPL=""
while [ $# -gt 0 ]; do
  case "$1" in
    --templates) TPL="$2"; shift 2 ;;
    *) ROOT="$1"; shift ;;
  esac
done
ROOT="$(cd "$ROOT" && pwd)"
S="$ROOT/specs"
[ -d "$S" ] || { echo "No specs/ directory in $ROOT" >&2; exit 2; }

find_up() { # relative-path -> first existing among project, kit layouts
  local c
  for c in "$ROOT/$1" "$HERE/../$1" "$HERE/../../$1"; do [ -e "$c" ] && { echo "$c"; return; }; done
}
LIB="$(find_up .claude/hooks/_lib.sh)"; [ -n "$LIB" ] || { echo "cannot find .claude/hooks/_lib.sh" >&2; exit 2; }
TRACE="$(find_up .claude/hooks/check-traceability.sh)"
. "$LIB"
if [ -z "$TPL" ]; then
  for c in "$ROOT/.sdd/templates" "$HERE/../templates" "$HERE/../../.sdd/templates"; do [ -d "$c" ] && { TPL="$c"; break; }; done
fi

specs=(); for f in "$S"/*.md; do [ -f "$f" ] && [ "$(basename "$f")" != deviations.md ] && specs+=("$f"); done
spec_ids=(); for f in "${specs[@]}"; do spec_ids+=("$(basename "$f" .md)"); done
has_id() { local x; for x in "${spec_ids[@]}"; do [ "$x" = "$1" ] && return 0; done; return 1; }

declare -A TPL_BY_ID
if [ -n "$TPL" ]; then
  while IFS= read -r t; do
    tid="$(frontmatter_get "$t" id)"; [ -n "$tid" ] && TPL_BY_ID["$tid"]="$t"
  done < <(find "$TPL" -name '*.md')
fi

fails=0; total=0
check() { # <id> <description>; findings on stdin, empty = PASS
  local out; out="$(cat)"; total=$((total + 1))
  if [ -z "$out" ]; then echo "PASS $1 $2"
  else echo "FAIL $1 $2"; printf '%s\n' "$out" | sed 's/^/     - /'; fails=$((fails + 1)); fi
}
rel() { printf 'specs/%s' "$(basename "$1")"; }
trace_list() { frontmatter_get "$1" traces | tr -d '[]' | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$'; }
norm_heading() { printf '%s\n' "$1" | sed -E 's/^#+[[:space:]]*//; s/^[0-9]+\.[[:space:]]*//; s/[[:space:]]+$//' | tr 'A-Z' 'a-z'; }

d1() {
  local f id st t
  for f in "${specs[@]}"; do
    id="$(frontmatter_get "$f" id)"; st="$(frontmatter_get "$f" status)"
    for k in id title status; do [ -n "$(frontmatter_get "$f" "$k")" ] || echo "$(rel "$f"): missing '$k'"; done
    tr -d '\r' < "$f" | awk 'NR>1&&$0=="---"{exit} NR>1' | grep -qE '^traces:' || echo "$(rel "$f"): missing 'traces'"
    [ -z "$id" ] || [ "$id" = "$(basename "$f" .md)" ] || echo "$(rel "$f"): id '$id' differs from filename"
    case "$st" in draft|in-review|approved|superseded|"") ;; *) echo "$(rel "$f"): invalid status '$st'" ;; esac
    while IFS= read -r t; do
      has_id "$t" || [ -n "${TPL_BY_ID[$t]:-}" ] || echo "$(rel "$f"): traces unknown artifact '$t'"
    done < <(trace_list "$f")
  done
}

d2() {
  local f id st tpl line n h found
  for f in "${specs[@]}"; do
    id="$(frontmatter_get "$f" id)"; st="$(frontmatter_get "$f" status)"
    [ "$st" = draft ] && continue
    tpl="${TPL_BY_ID[$id]:-}"; [ -n "$tpl" ] || continue
    mapfile -t heads < <(tr -d '\r' < "$f" | grep -E '^#{1,4}[[:space:]]' | while IFS= read -r l; do norm_heading "$l"; done)
    while IFS= read -r line; do
      case "$line" in *'{{'*) continue ;; esac
      n="$(norm_heading "$line")"; found=0
      for h in "${heads[@]}"; do [[ "$h" == "$n"* ]] && { found=1; break; }; done
      [ "$found" -eq 1 ] || echo "$(rel "$f"): missing section '$n' (from template $id)"
    done < <(tr -d '\r' < "$tpl" | grep -E '^##[[:space:]]')
  done
}

d3() {
  local f
  for f in "${specs[@]}"; do
    [ "$(frontmatter_get "$f" status)" = approved ] || continue
    grep -n '{{' "$f" | head -3 | sed "s|^|$(rel "$f") line |; s|:| has placeholder: |"
    grep -n 'OPEN QUESTION' "$f" | head -3 | sed "s|^|$(rel "$f") line |; s|:| has open question: |"
  done
}

d4() {
  [ -n "$TRACE" ] || { echo "check-traceability.sh not found"; return; }
  bash "$TRACE" "$ROOT" 2>&1 | grep -vE ': none$|^COVERAGE|^STATUS|nothing to check'
}

dup_ids() { # <prefix> <file>
  [ -f "$2" ] || return 0
  tr -d '\r' < "$2" | grep -oE "^(\|[[:space:]]*|#+[[:space:]]*)$1-[0-9]+" | grep -oE "$1-[0-9]+" | sort | uniq -d | sed "s|^|$(rel "$2"): duplicate |"
}
d5() { dup_ids NFR "$S/01-prd.md"; dup_ids BR "$S/02-data-model.md"; dup_ids TASK "$S/07-task-breakdown.md"; dup_ids TEST "$S/08-verification.md"; }

d6() {
  [ -f "$S/01-prd.md" ] || return 0
  tr -d '\r' < "$S/01-prd.md" | grep -E '^\|[[:space:]]*REQ-[0-9]+' | grep -viE 'given.*then' | grep -oE 'REQ-[0-9]+' | sed 's|$| has no Given/Then acceptance criteria|'
}

d7() {
  [ -f "$S/03-api-contract.md" ] || return 0
  tr -d '\r' < "$S/03-api-contract.md" | grep -E '^#{2,4}[[:space:]]+(GET|POST|PUT|PATCH|DELETE)[[:space:]]' | grep -v 'REQ-' | sed 's/^#* *//; s/$/ : endpoint does not trace to a REQ/'
}

d8() {
  [ -f "$S/08-verification.md" ] || return 0
  tr -d '\r' < "$S/08-verification.md" | grep -E '^(\|[[:space:]]*|#+[[:space:]]*)TEST-[0-9]+' | grep -v 'REQ-' | grep -oE 'TEST-[0-9]+' | sed 's/$/ does not trace to a REQ/'
}

d9() {
  local f t
  for f in "${specs[@]}"; do
    [ "$(frontmatter_get "$f" status)" = approved ] || continue
    while IFS= read -r t; do
      [ -f "$S/$t.md" ] || continue
      [ "$(frontmatter_get "$S/$t.md" status)" = approved ] || echo "$(rel "$f") is approved but depends on '$t' which is not approved"
    done < <(trace_list "$f")
  done
}

echo "SDD deterministic evals for: $ROOT"
check D1 "frontmatter valid" < <(d1)
check D2 "required template sections present" < <(d2)
check D3 "no placeholders or open questions in approved specs" < <(d3)
check D4 "traceability" < <(d4)
check D5 "no duplicate IDs" < <(d5)
check D6 "every REQ has Given/When/Then criteria" < <(d6)
check D7 "every endpoint traces to a REQ" < <(d7)
check D8 "every TEST traces to a REQ" < <(d8)
check D9 "approved specs depend only on approved specs" < <(d9)

echo "RESULT: $((total - fails))/$total checks passed"
[ "$fails" -eq 0 ]
