#!/usr/bin/env bash
# PreToolUse (Edit|Write|MultiEdit|NotebookEdit): no code before approved specs.
# Only active once the project has a specs/ folder. Bypass for a session: SDD_ENFORCE=off.
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
read_payload

[ "${SDD_ENFORCE:-on}" = "off" ] && exit 0

f="$(json_get file_path)"
[ -z "$f" ] && f="$(json_get notebook_path)"
[ -z "$f" ] && exit 0
[ -d "$(project_dir)/specs" ] || exit 0

rel="$(rel_path "$f")"
case "$rel" in
  /*|../*) exit 0 ;;                                   # outside the project
  specs/*|.sdd/*|.claude/*|docs/*|.github/*) exit 0 ;; # specs, config, docs
  *.md|LICENSE*|.gitignore|.gitattributes) exit 0 ;;   # prose and repo meta files
esac

missing="$(missing_specs | tr '\n' ' ')"
[ -z "$missing" ] && exit 0

block "No code before approved specs. Not approved yet: ${missing}. Draft them with the /sdd-* commands and approve each with /sdd-approve <id>. Only specs/, docs/ and config may be edited until then."
