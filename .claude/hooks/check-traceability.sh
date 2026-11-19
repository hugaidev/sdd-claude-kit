#!/usr/bin/env bash
# Traceability check across specs/.
#   CLI:        check-traceability.sh [project-dir]   -> exit 1 on FAIL
#   Stop hook:  no args, JSON on stdin                -> advisory (exit 0) unless SDD_TRACE_STRICT=1
set -u
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -ge 1 ]; then
  MODE=cli
  ROOT="$1"
else
  MODE=hook
  . "$here/_lib.sh"
  read_payload
  # avoid Stop-hook loops
  printf '%s' "$PAYLOAD" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
  ROOT="$(project_dir)"
fi

S="$ROOT/specs"
prd="$S/01-prd.md"; tasks="$S/07-task-breakdown.md"; ver="$S/08-verification.md"
[ -f "$prd" ] || { [ "$MODE" = cli ] && echo "traceability: no specs/01-prd.md yet; nothing to check"; exit 0; }

# ids <regex> <files...>: unique matches
ids() { local re="$1"; shift; local f; for f in "$@"; do [ -f "$f" ] && tr -d '\r' < "$f"; done | grep -oE "$re" | sort -u; }
# defs <ID-prefix> <file>: IDs DEFINED (table row start or heading) in a file
defs() { [ -f "$2" ] && tr -d '\r' < "$2" | grep -oE "^(\|[[:space:]]*|#+[[:space:]]*)$1-[0-9]+" | grep -oE "$1-[0-9]+"; }
# minus <listA> <listB>: lines in A not in B
minus() { comm -23 <(printf '%s\n' "$1" | grep -v '^$' | sort -u) <(printf '%s\n' "$2" | grep -v '^$' | sort -u); }

req_all="$(defs REQ "$prd" | sort)"
req_defined="$(printf '%s\n' "$req_all" | sort -u)"
req_dups="$(printf '%s\n' "$req_all" | grep -v '^$' | uniq -d)"

task_defined="$(defs TASK "$tasks" | sort -u)"
test_defined="$(defs TEST "$ver" | sort -u)"

req_in_tasks="$(ids 'REQ-[0-9]+' "$tasks")"
req_in_ver="$(ids 'REQ-[0-9]+' "$ver")"

no_task="$(minus "$req_defined" "$req_in_tasks")"
no_test="$(minus "$req_defined" "$req_in_ver")"

specfiles=("$S"/*.md "$S"/adr/*.md)
others=(); for f in "${specfiles[@]}"; do [ -f "$f" ] && [ "$f" != "$prd" ] && others+=("$f"); done
undef_req="$(minus "$(ids 'REQ-[0-9]+' "${others[@]}")" "$req_defined")"
undef_test=""
[ -f "$ver" ] && undef_test="$(minus "$(ids 'TEST-[0-9]+' "$tasks")" "$test_defined")"

orphan_tasks=""
if [ -f "$tasks" ]; then
  orphan_tasks="$(tr -d '\r' < "$tasks" | grep -E '^\|[[:space:]]*TASK-[0-9]+' | grep -v 'REQ-' | grep -oE 'TASK-[0-9]+' | sort -u)"
fi

fmt() { [ -n "$1" ] && printf '%s' "$1" | tr '\n' ' ' || printf 'none'; }
count() { printf '%s\n' "$1" | grep -vc '^$'; }

total="$(count "$req_defined")"
with_test=$(( total - $(count "$no_test") ))
with_task=$(( total - $(count "$no_task") ))

report="COVERAGE: REQ ${with_test}/${total} have TEST · REQ ${with_task}/${total} have TASK
REQ WITHOUT TASK: $(fmt "$no_task")
REQ WITHOUT TEST: $(fmt "$no_test")
TASKS WITHOUT REQ: $(fmt "$orphan_tasks")
UNDEFINED REQ REFERENCES: $(fmt "$undef_req")
UNDEFINED TEST REFERENCES: $(fmt "$undef_test")
DUPLICATE REQ IDS: $(fmt "$req_dups")"

status=PASS
for v in "$no_task" "$no_test" "$orphan_tasks" "$undef_req" "$undef_test" "$req_dups"; do
  [ -n "$v" ] && status=FAIL
done
report="$report
STATUS: $status"

if [ "$MODE" = cli ]; then
  echo "$report"
  [ "$status" = PASS ]
  exit $?
fi

# hook mode (Stop): advisory by default
if [ "$status" = FAIL ]; then
  echo "[sdd-guardrail] traceability gaps:" >&2
  echo "$report" >&2
  [ "${SDD_TRACE_STRICT:-0}" = 1 ] && exit 2
fi
exit 0
