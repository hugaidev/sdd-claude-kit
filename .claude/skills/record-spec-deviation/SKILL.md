---
name: record-spec-deviation
description: Handle a discovered mismatch between an approved spec and reality (spec error, ambiguity or impossible requirement). Use instead of coding around the spec.
---

# Skill: Record Spec Deviation

## Parameters
- `spec` — id of the affected spec (e.g. `03-api-contract`)
- `finding` — what is wrong or ambiguous, with evidence (file, line, error)

## Steps
1. Stop implementation work on the affected task.
2. Append a block to `specs/deviations.md` (create if missing):
   - Date, spec id, section, task ID, finding, impact, proposed change, options considered.
3. Propose the exact spec edit as a diff in chat. Do NOT apply it to an approved spec.
4. Ask the human to decide: approve change, reject (fix the code instead), or defer.
5. On approval: set the spec to `status: in-review`, apply the edit, re-run the `spec-reviewer` subagent and `/sdd-trace`, bump `version`, ask the human to re-approve, then resume the task.

## Result
A logged decision and, if approved, an updated and re-approved spec. Code and specs never diverge silently.
