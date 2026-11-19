#!/usr/bin/env bash
# PreToolUse (Read|Edit|Write|MultiEdit|Bash|Grep|Glob): keep secrets away from the model.
# Fails CLOSED: anything that looks like a secret file or credential is blocked.
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
read_payload

tool="$(json_get tool_name)"

# 1. Secret-bearing files (examples/templates are allowed)
f="$(json_get file_path)"
[ -z "$f" ] && f="$(json_get path)"
if [ -n "$f" ]; then
  base="$(basename "$(norm_path "$f")")"
  case "$base" in
    .env.example|.env.sample|.env.template|.env.dist) ;;
    .env|.env.*|*.pem|*.key|*.p12|*.pfx|*.keystore|id_rsa*|id_ed25519*|credentials.json|.netrc|.npmrc)
      block "Access to '$base' is blocked: it can contain secrets. Use environment variables or a secret manager; document variable NAMES in a .env.example instead." ;;
  esac
fi

# 2. Shell commands that touch .env files
if [ "$tool" = "Bash" ]; then
  cmd="$(json_get command)"
  stripped="$(printf '%s' "$cmd" | sed -E 's/\.env\.(example|sample|template|dist)//g')"
  if printf '%s' "$stripped" | grep -Eiq '(^|[[:space:]/="'"'"'])\.env(\.[A-Za-z0-9_-]+)?([[:space:]"'"'"'|;&<>]|$)'; then
    block "Shell access to .env files is blocked. Use environment variables or a secret manager."
  fi
fi

# 3. Credential-looking content in anything being written or executed
case "$tool" in
  Write|Edit|MultiEdit|NotebookEdit|Bash)
    SECRET_RE='AKIA[0-9A-Z]{16}|-----BEGIN ([A-Z]+ )?PRIVATE KEY-----|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{32,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}'
    GENERIC_RE='(api[_-]?key|secret|token|passwd|password)[A-Za-z_]*(\\?"|'"'"')?[[:space:]]*[:=][[:space:]]*(\\?"|'"'"')[A-Za-z0-9/+_.=-]{16,}'
    if printf '%s' "$PAYLOAD" | grep -Eq "$SECRET_RE" || printf '%s' "$PAYLOAD" | grep -Eiq "$GENERIC_RE"; then
      block "Content looks like it contains a credential (key, token or password literal). Do not hard-code secrets: read them from environment variables or a secret manager."
    fi
    ;;
esac

exit 0
