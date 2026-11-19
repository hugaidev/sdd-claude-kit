#!/usr/bin/env bash
# Shared helpers for SDD guardrail hooks.
# Dependencies: bash 4+, grep, sed, awk (no jq, no python, no node).
#
# Hook contract: the tool call arrives as JSON on stdin.
#   exit 0 = allow; exit 2 = block (stderr is shown to Claude / the user).

PAYLOAD=""
read_payload() { [ -n "$PAYLOAD" ] || PAYLOAD="$(cat)"; }

# json_get <key>: value of the last string field named <key> in the payload, unescaped.
json_get() {
  printf '%s' "$PAYLOAD" \
    | sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' \
    | head -n1 \
    | sed -e 's/\\\\/\x01/g' -e 's/\\"/"/g' -e 's/\\n/\n/g' -e 's/\\t/\t/g' -e 's/\x01/\\/g'
}

# norm_path: backslashes to slashes; C:/x -> /c/x (Git Bash style).
norm_path() {
  local p="${1//\\//}"
  if [[ "$p" =~ ^([A-Za-z]):/(.*)$ ]]; then
    p="/${BASH_REMATCH[1],,}/${BASH_REMATCH[2]}"
  fi
  printf '%s' "$p"
}

project_dir() { norm_path "${CLAUDE_PROJECT_DIR:-$PWD}"; }

# rel_path <path>: path relative to the project dir (case-insensitive prefix match).
rel_path() {
  local p proj lp lj
  p="$(norm_path "$1")"
  proj="$(project_dir)"; proj="${proj%/}"
  lp="${p,,}"; lj="${proj,,}"
  if [[ "$lp" == "$lj/"* ]]; then
    p="${p:$((${#proj} + 1))}"
  fi
  printf '%s' "${p#./}"
}

# frontmatter_get <file> <key>
frontmatter_get() {
  tr -d '\r' < "$1" | awk -v k="$2" '
    NR==1 && $0!="---" {exit}
    NR>1 && $0=="---" {exit}
    NR>1 && index($0,k":")==1 {
      sub("^"k":[ ]*",""); sub("[ ]*#.*$",""); sub("[ ]*$",""); gsub(/^"|"$/,""); print; exit
    }'
}

DEFAULT_REQUIRED_SPECS="00-constitution 01-prd 02-data-model 03-api-contract 05-architecture 06-implementation-plan 07-task-breakdown 08-verification"

# required_specs: ids that must be approved before code. Override with .sdd/required-specs (one id per line).
required_specs() {
  local f
  f="$(project_dir)/.sdd/required-specs"
  if [ -f "$f" ]; then
    tr -d '\r' < "$f" | grep -vE '^[[:space:]]*(#|$)'
  else
    printf '%s\n' $DEFAULT_REQUIRED_SPECS
  fi
}

# missing_specs: required spec ids that are absent or not approved.
missing_specs() {
  local id file
  for id in $(required_specs); do
    file="$(project_dir)/specs/$id.md"
    if [ ! -f "$file" ] || [ "$(frontmatter_get "$file" status)" != "approved" ]; then
      echo "$id"
    fi
  done
}

block() { echo "[sdd-guardrail] $*" >&2; exit 2; }
