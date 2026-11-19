#!/usr/bin/env bash
# Fake judge for testing evals/run-rubric.sh without calling a model.
# Reads the prompt on stdin; prints "<ID>|<score>|fake" for each criterion.
#   FAKE_SCORE   score to give every criterion (default 2)
#   FAKE_SKIP    if set, omit the last criterion (simulates a judge that skips one)
#   FAKE_FAIL    if set, exit 1 (simulates a broken judge)
[ -n "${FAKE_FAIL:-}" ] && { echo "judge exploded" >&2; exit 1; }
ids="$(grep -oE '^- [A-Z0-9]+-[0-9]+ \|' | sed -E 's/^- //; s/ \|$//')"
[ -n "${FAKE_SKIP:-}" ] && ids="$(printf '%s\n' "$ids" | sed '$d')"
for id in $ids; do echo "$id|${FAKE_SCORE:-2}|fake"; done
