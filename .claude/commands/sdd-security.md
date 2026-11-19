---
description: Security review of the specs (and code, if present)
argument-hint: <scope, e.g. specs | code | both>
---

Delegate to the `security-auditor` subagent with scope: $ARGUMENTS (default: both). If `specs/14-security-spec.md` does not exist, recommend creating it from `.sdd/templates/security/14-security-spec.md`. Show the findings ordered by severity and ask which to turn into tasks or spec changes. Do not edit anything.
