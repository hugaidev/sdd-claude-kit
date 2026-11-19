#!/usr/bin/env bash
# Install the SDD kit into a target project.
# Usage: scripts/install.sh <target-dir> [--force]
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"
FORCE=0
[ "${2:-}" = "--force" ] && FORCE=1

if [ -z "$TARGET" ] || [ ! -d "$TARGET" ]; then
  echo "Usage: $0 <existing-target-dir> [--force]" >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

copy_dir() { # src dst
  local src="$1" dst="$2"
  [ -d "$src" ] || return 0
  mkdir -p "$dst"
  # copy file by file so existing user files are never overwritten without --force
  (cd "$src" && find . -type f ! -name '.gitkeep' ! -name 'settings.local.json') | while read -r f; do
    if [ -e "$dst/$f" ] && [ "$FORCE" -ne 1 ]; then
      echo "skip (exists): $dst/$f"
    else
      mkdir -p "$(dirname "$dst/$f")"
      cp "$src/$f" "$dst/$f"
      echo "installed: $dst/$f"
    fi
  done
}

copy_dir "$KIT/.claude/agents"   "$TARGET/.claude/agents"
copy_dir "$KIT/.claude/commands" "$TARGET/.claude/commands"
copy_dir "$KIT/.claude/skills"   "$TARGET/.claude/skills"
copy_dir "$KIT/.claude/hooks"    "$TARGET/.claude/hooks"
copy_dir "$KIT/templates"        "$TARGET/.sdd/templates"

# settings.json: never overwrite an existing one; user merges manually
if [ -f "$KIT/.claude/settings.json" ]; then
  if [ -e "$TARGET/.claude/settings.json" ] && [ "$FORCE" -ne 1 ]; then
    echo "NOTE: $TARGET/.claude/settings.json exists; merge permissions/hooks from the kit manually."
  else
    cp "$KIT/.claude/settings.json" "$TARGET/.claude/settings.json"
    echo "installed: $TARGET/.claude/settings.json"
  fi
fi

mkdir -p "$TARGET/specs/adr"
if [ ! -e "$TARGET/CLAUDE.md" ]; then
  echo "NOTE: no CLAUDE.md found. Run /sdd-init in Claude Code to create it from the template."
fi

echo
echo "Done. Open the project in Claude Code and run: /sdd-init <your idea>"
