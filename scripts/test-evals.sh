#!/usr/bin/env bash
# Tests the deterministic evals themselves: the good example must pass,
# the seeded-defect fixture must fail every check D1..D9.
# Usage: bash scripts/test-evals.sh
set -u
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EV="$KIT/evals/deterministic.sh"
pass=0; failn=0
ok()  { pass=$((pass + 1)); }
bad() { failn=$((failn + 1)); echo "FAIL: $1"; }

# 1. good example passes everything
out="$(bash "$EV" "$KIT/examples/notes-api" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -q '9/9 checks passed'; then ok; else bad "examples/notes-api should pass 9/9"; printf '%s\n' "$out"; fi

# 2. bad fixture fails, and each check D1..D9 is caught
out="$(bash "$EV" "$KIT/evals/fixtures/bad" 2>&1)"; rc=$?
[ "$rc" -ne 0 ] && ok || bad "bad fixture should fail"
for d in D1 D2 D3 D4 D5 D6 D7 D8 D9; do
  printf '%s' "$out" | grep -q "^FAIL $d " && ok || bad "bad fixture should trigger $d"
done

# 3. specific findings
printf '%s' "$out" | grep -q "traces unknown artifact '99-missing'" && ok || bad "unknown trace not reported"
printf '%s' "$out" | grep -q "invalid status 'bogus'"              && ok || bad "invalid status not reported"
printf '%s' "$out" | grep -q "TASK-002"                            && ok || bad "orphan task not reported"

# 4. no specs dir -> usage error (exit 2)
T="$(mktemp -d)"; bash "$EV" "$T" >/dev/null 2>&1; rc=$?; rm -rf "$T"
[ "$rc" -eq 2 ] && ok || bad "missing specs/ should exit 2 (got $rc)"

# 5. rubric runner, using a fake judge (no model calls)
RR="$KIT/evals/run-rubric.sh"
SPEC="$KIT/examples/notes-api/specs/01-prd.md"
cd "$KIT" || exit 1   # JUDGE_CMD is word-split, so use a space-free relative path
JD="bash evals/fixtures/fake-judge.sh"
JUDGE_CMD="$JD" bash "$RR" "$SPEC" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 0 ] && ok || bad "rubric: all-2 judge should PASS (rc=$rc)"
FAKE_SCORE=0 JUDGE_CMD="$JD" bash "$RR" "$SPEC" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 1 ] && ok || bad "rubric: all-0 judge should FAIL (rc=$rc)"
FAKE_SKIP=1 JUDGE_CMD="$JD" bash "$RR" "$SPEC" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 1 ] && ok || bad "rubric: unscored criterion must FAIL (rc=$rc)"
FAKE_FAIL=1 JUDGE_CMD="$JD" bash "$RR" "$SPEC" >/dev/null 2>&1; rc=$?
[ "$rc" -eq 2 ] && ok || bad "rubric: broken judge should exit 2 (rc=$rc)"
FAKE_SCORE=1 JUDGE_CMD="$JD" bash "$RR" "$SPEC" 2>&1 | grep -q 'SCORE: 0.50' && ok || bad "rubric: all-1 judge should score 0.50"
JUDGE_CMD="$JD" bash "$RR" "$KIT/evals/fixtures/bad/specs/00-constitution.md" /nonexistent.md >/dev/null 2>&1; rc=$?
[ "$rc" -eq 2 ] && ok || bad "rubric: missing rubric file should exit 2 (rc=$rc)"

# 6. every rubric is well formed
for r in "$KIT"/evals/rubrics/*.md; do
  n="$(basename "$r" .md)"
  [ "$(grep -m1 '^artifact:' "$r" | sed 's/^artifact:[ ]*//' | tr -d '\r')" = "$n" ] && ok || bad "rubric $n: artifact must equal filename"
  c="$(grep -cE '^- [A-Z0-9]+-[0-9]+ \| [0-9]+ \|' "$r")"
  u="$(grep -oE '^- [A-Z0-9]+-[0-9]+' "$r" | sort | uniq -d | wc -l)"
  [ "$c" -ge 5 ] && [ "$u" -eq 0 ] && ok || bad "rubric $n: needs >= 5 criteria and unique IDs (found $c, $u duplicates)"
done

# 7. behavioral case runner mechanics (fake CLI, no model)
RC="$KIT/evals/run-cases.sh"
CLAUDE_BIN=/definitely/not/here bash "$RC" 2>&1 | grep -q '^SKIPPED' && ok || bad "run-cases should SKIP when the CLI is missing"
CLAUDE_BIN="$KIT/evals/fixtures/fake-claude.sh" FAKE_CLAUDE_OUT="VERDICT: CHANGES_REQUESTED" bash "$RC" --only reviewer-reports-seeded-defects >/dev/null 2>&1; rc=$?
[ "$rc" -eq 0 ] && ok || bad "run-cases: case should PASS when output has CHANGES_REQUESTED (rc=$rc)"
CLAUDE_BIN="$KIT/evals/fixtures/fake-claude.sh" FAKE_CLAUDE_OUT="VERDICT: PASS" bash "$RC" --only reviewer-reports-seeded-defects >/dev/null 2>&1; rc=$?
[ "$rc" -eq 1 ] && ok || bad "run-cases: case should FAIL when output lacks CHANGES_REQUESTED (rc=$rc)"
for cf in "$KIT"/evals/cases/*.case; do
  ( . "$cf"; [ -n "$DESCRIPTION" ] && [ -n "$FIXTURE" ] && [ -n "$PROMPT" ] && [ -n "$ASSERT" ] && [ -d "$KIT/evals/fixtures/$FIXTURE/specs" ] ) && ok || bad "case $(basename "$cf"): missing field or fixture"
done

echo "eval tests: $pass passed, $failn failed"
[ "$failn" -eq 0 ]
