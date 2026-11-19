# 05 — Guardrails and Evals

> Spanish version: [es/05-guardrails-y-evals.md](es/05-guardrails-y-evals.md)

Prompts ask; guardrails enforce; evals measure. This kit uses all three.

## 1. Defense in depth

| Layer | Mechanism | Strength |
|-------|-----------|----------|
| 1. Instruction | `CLAUDE.md`, skills | Soft — can be ignored |
| 2. Permission | `permissions.allow/ask/deny` | Hard — blocked before execution |
| 3. Hook | Scripts on tool events | Hard — custom logic, exit 2 blocks |
| 4. CI | `scripts/validate.sh`, evals, secret scan | Hard — blocks merge |
| 5. Human | PR review, CODEOWNERS | Final authority |

## 2. Hooks shipped with the kit (`.claude/hooks/`)

| Hook | Event | Behavior |
|------|-------|----------|
| `require-approved-spec` | PreToolUse (Edit/Write) | Blocks writes under `src/` unless `specs/` contains approved specs for the work |
| `block-secrets` | PreToolUse (Edit/Write/Read/Bash) | Blocks touching `.env*`, key files, and writing strings that look like secrets |
| `block-destructive-bash` | PreToolUse (Bash) | Blocks `rm -rf`, force-push, `DROP TABLE`, etc. |
| `validate-spec-format` | PostToolUse (Edit/Write on `specs/`) | Checks frontmatter and required sections; feeds errors back to Claude |
| `check-traceability` | PostToolUse / Stop | Verifies IDs referenced exist; no orphan REQ/TASK/TEST |
| `completeness-gate` | UserPromptSubmit (`/sdd-implement`) | Refuses Phase 9 until the completeness checklist passes |

### Hook contract

- Input: JSON on stdin (`tool_name`, `tool_input`, `cwd`, …).
- **Exit 0** = allow. **Exit 2** = block; stderr is shown to Claude so it can correct course. Other codes = non-blocking error.
- Keep hooks fast (< 1 s), deterministic, dependency-light (bash or Node).
- Fail **closed** for safety hooks, **open** for convenience hooks.

Example (sketch):

```bash
#!/usr/bin/env bash
payload=$(cat)
file=$(echo "$payload" | jq -r '.tool_input.file_path // empty')
case "$file" in
  */src/*) grep -rqs '^status: approved' specs/ || { echo "Blocked: no approved specs. Run /sdd-* first." >&2; exit 2; } ;;
esac
exit 0
```

## 3. Evals

Evals answer: **are the specs and the agent's behavior good enough?** Two kinds.

### Deterministic (run in CI, free, fast)
- Frontmatter present and valid; status values legal.
- Required sections per template exist.
- No unresolved `{{placeholder}}` in `approved` specs.
- Traceability: every REQ has ≥ 1 TEST; every TASK traces to a REQ; every referenced ID exists.
- Cross-spec naming: entities in the API/UI exist in the data model.

### Rubric-based (LLM-as-judge, optional, run on demand)
Each artifact has `evals/rubrics/<artifact>.md` converted from the review checklists in the original guides: criteria scored 0–2 with evidence quotes, plus a pass threshold.

```yaml
criteria:
  - id: PRD-01
    check: Every requirement has a testable acceptance criterion
    weight: 3
  - id: PRD-02
    check: No implementation details (HOW) in requirements
    weight: 2
pass_threshold: 0.8
```

### Behavioral evals for the agents
Golden cases in `evals/cases/`: a prompt, fixture project and expected properties (e.g., "attempt to edit `.env` is blocked", "implementer refuses without approved spec", "reviewer reports the seeded contradiction"). Run them against the hooks directly (unit) and against Claude Code headless (`claude -p`) for end-to-end.

## 4. CI

```text
push/PR → validate.sh (frontmatter) → evals (deterministic) → hook unit tests → secret scan
```

Rubric evals run nightly or on label `run-evals` to control cost.

## 5. Governing the guardrails

- Every hook has a test and a documented reason.
- Changes to `.claude/settings.json` and `.claude/hooks/` require CODEOWNERS review.
- Log blocked attempts for the quarterly review of the [AI Use Protocol](04-ai-use-protocol.md).
