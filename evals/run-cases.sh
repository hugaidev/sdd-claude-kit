#!/usr/bin/env bash
# Behavioral golden cases: run the installed kit through Claude Code headless and
# assert on the model output and on the resulting files. OPT-IN: costs tokens and
# needs the `claude` CLI. Skips (exit 0) when the CLI is not available.
#
# Usage: evals/run-cases.sh [--only <case-name>]
# Env:   CLAUDE_BIN  path/command of the CLI (default: claude)
#        CASE_TIMEOUT seconds per case (default 300)
#
# Case file format (evals/cases/<name>.case, sourced by bash):
#   DESCRIPTION  one line
#   FIXTURE      folder under evals/fixtures/ whose specs/ is copied into the sandbox
#   SETUP        optional shell snippet run in the sandbox before the prompt
#   PROMPT       what to send to claude -p
#   ASSERT       shell snippet run in the sandbox; $OUT holds the model output; exit 0 = pass
set -u
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
ONLY=""; [ "${1:-}" = "--only" ] && ONLY="${2:-}"

if ! command -v "$CLAUDE_BIN" >/dev/null 2>&1 && [ ! -x "$CLAUDE_BIN" ]; then
  echo "SKIPPED: '$CLAUDE_BIN' not found. Install Claude Code or set CLAUDE_BIN to run behavioral cases."
  exit 0
fi

pass=0; failn=0
for casef in "$KIT"/evals/cases/*.case; do
  name="$(basename "$casef" .case)"
  [ -n "$ONLY" ] && [ "$ONLY" != "$name" ] && continue

  DESCRIPTION=""; FIXTURE=""; SETUP=""; PROMPT=""; ASSERT=""
  . "$casef"

  SANDBOX="$(mktemp -d)"
  bash "$KIT/scripts/install.sh" "$SANDBOX" >/dev/null 2>&1
  cp -r "$KIT/evals/fixtures/$FIXTURE/specs" "$SANDBOX/"
  ( cd "$SANDBOX" && git init -q . 2>/dev/null )
  [ -n "$SETUP" ] && ( cd "$SANDBOX" && eval "$SETUP" )

  OUT="$(cd "$SANDBOX" && timeout "${CASE_TIMEOUT:-300}" "$CLAUDE_BIN" -p "$PROMPT" --permission-mode acceptEdits 2>&1)"
  export OUT
  if ( cd "$SANDBOX" && eval "$ASSERT" ); then
    pass=$((pass + 1)); echo "PASS $name — $DESCRIPTION"
  else
    failn=$((failn + 1)); echo "FAIL $name — $DESCRIPTION"
    printf '%s\n' "$OUT" | head -15 | sed 's/^/     | /'
  fi
  rm -rf "$SANDBOX"
done

echo "behavioral cases: $pass passed, $failn failed"
[ "$failn" -eq 0 ]
