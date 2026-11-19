#!/usr/bin/env bash
# Validates that every template has the required frontmatter keys.
set -euo pipefail
fail=0
while IFS= read -r f; do
  for k in id title status traces; do
    grep -qE "^${k}:" "$f" || { echo "MISSING '$k' in $f"; fail=1; }
  done
done < <(find templates -name '*.md' 2>/dev/null)
exit $fail
