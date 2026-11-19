#!/usr/bin/env bash
# UserPromptSubmit: refuse /sdd-implement until the completeness gate passes
# (all required specs approved + traceability PASS).
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
read_payload

prompt="$(json_get prompt)"
prompt="${prompt#"${prompt%%[![:space:]]*}"}"
case "$prompt" in /sdd-implement*) ;; *) exit 0 ;; esac

[ "${SDD_ENFORCE:-on}" = "off" ] && exit 0
[ -d "$(project_dir)/specs" ] || block "No specs/ folder. Run /sdd-init first."

missing="$(missing_specs | tr '\n' ' ')"
[ -z "$missing" ] || block "Completeness gate failed. Not approved yet: ${missing}. Finish and /sdd-approve them before implementing."

out="$(bash "$(dirname "${BASH_SOURCE[0]}")/check-traceability.sh" "$(project_dir)" 2>&1)" \
  || { echo "$out" >&2; block "Completeness gate failed: fix the traceability gaps above (see /sdd-trace)."; }

exit 0
