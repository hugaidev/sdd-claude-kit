# 03 — Claude Code Setup

> Spanish version: [es/03-configuracion-claude-code.md](es/03-configuracion-claude-code.md)

Configure Claude Code the way you would onboard a new engineer: tell it who it is, how you work, what is forbidden, and give it specialists and playbooks.

## 1. The configuration surface

| Mechanism | Location | Answers | Loaded |
|-----------|----------|---------|--------|
| `CLAUDE.md` | repo root (also `~/.claude/CLAUDE.md`, subfolders) | *How we work here* | Every session |
| `settings.json` | `.claude/settings.json` (shared), `.claude/settings.local.json` (personal, gitignored) | Permissions, hooks, env | Every session |
| Subagents | `.claude/agents/*.md` | *Who* does what, with which tools | On delegation |
| Slash commands | `.claude/commands/*.md` | *Which workflow* to start | On `/name` |
| Skills | `.claude/skills/<name>/SKILL.md` | *How* to do a recurring task | When relevant |
| Hooks | `.claude/hooks/*` + `settings.json` | *What is enforced* | On tool events |
| MCP servers | `.mcp.json` | External tools/data | Every session |

Rule of thumb: **advice → CLAUDE.md; procedure → skill; role → subagent; entry point → command; must-never-happen → hook + permission deny.**

## 2. CLAUDE.md

Keep it under ~200 lines. Content: project mission, the spec-first workflow, build/test commands, 5–10 concrete conventions, forbidden actions. Use `@path` imports to pull in specs instead of pasting them. Start from [`templates/ai/claude-md.md`](../templates/ai/claude-md.md).

Quality spectrum for rules:

```text
✗ "Write clean code"
~ "Use consistent naming"
✓ "Functions ≤ 40 lines; one exported symbol per file; errors use AppError, never throw strings"
```

Add a rule every time Claude gets something wrong twice.

## 3. Subagents (`.claude/agents/<name>.md`)

```markdown
---
name: spec-reviewer
description: Reviews a spec against its template and upstream artifacts. Use after any spec draft.
tools: Read, Grep, Glob
model: sonnet
---
You review specs. Never edit files. Report: missing sections, ambiguity,
contradictions with upstream specs, untraced requirements. Output a numbered findings list.
```

Design rules: one role per agent; **minimum tools** (reviewers are read-only); a `description` that says *when* to delegate; deterministic output format. The kit ships: `spec-writer`, `spec-reviewer`, `architect`, `data-modeler`, `api-designer`, `security-auditor`, `task-planner`, `implementer`, `verifier`, `traceability-checker`.

## 4. Slash commands (`.claude/commands/<name>.md`)

```markdown
---
description: Draft the PRD from the approved constitution
argument-hint: <product idea or notes file>
---
Read specs/00-constitution.md (must be approved). Using templates/product/01-prd.md,
draft specs/01-prd.md for: $ARGUMENTS. Delegate review to the spec-reviewer subagent.
```

One command per phase: `/sdd-init`, `/sdd-constitution`, `/sdd-prd`, `/sdd-data-model`, `/sdd-api`, `/sdd-ui`, `/sdd-architecture`, `/sdd-plan`, `/sdd-verify-spec`, `/sdd-implement <TASK-ID>`, `/sdd-trace`.

## 5. Skills (`.claude/skills/<name>/SKILL.md`)

A skill is a parameterized playbook with a frontmatter `name` and a `description` (that is what Claude matches on), then Parameters → Prerequisites → Steps → Result. Good skills: *add-adr*, *add-endpoint-from-contract*, *record-spec-deviation*. Link templates from the skill folder rather than inlining them.

## 6. settings.json: permissions and hooks

```json
{
  "permissions": {
    "allow": ["Bash(git status)", "Bash(git diff:*)", "Read(./specs/**)"],
    "ask":   ["Bash(git push:*)"],
    "deny":  ["Read(./.env*)", "Edit(./.env*)", "Bash(rm -rf:*)", "Bash(git push --force:*)"]
  },
  "hooks": {
    "PreToolUse": [
      { "matcher": "Edit|Write|MultiEdit",
        "hooks": [{ "type": "command", "command": ".claude/hooks/require-approved-spec.sh" }] }
    ]
  }
}
```

Hooks receive the tool call as JSON on stdin; **exit code 2 blocks the call** and sends stderr back to Claude. Events used by this kit: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`. Details in [05](05-guardrails-and-evals.md).

> Verify field names against the current Claude Code documentation when upgrading; the config schema evolves.

## 7. Personal vs shared

- Commit: `CLAUDE.md`, `.claude/settings.json`, agents, commands, skills, hooks.
- Never commit: `.claude/settings.local.json`, `.env*`, tokens.
- User-level preferences go in `~/.claude/`.

## 8. Maintenance cadence

| Cadence | Action |
|---------|--------|
| Every mistake | Add or sharpen one rule |
| Monthly | Prune stale rules; check agent descriptions still trigger correctly |
| Quarterly | Review permissions, hooks and the AI Use Protocol; re-run evals |

## 9. Anti-patterns

1. A 1,000-line CLAUDE.md (instructions get diluted) → split into skills and imports.
2. Subagents with all tools → give the minimum.
3. Rules without reasons → add *why*.
4. Relying on prompts for safety → use `deny` rules and hooks.
5. Copy-pasting specs into CLAUDE.md → import by path.
6. Never pruning → stale rules mislead.

## 10. 15-minute minimum setup

1. Create `CLAUDE.md` from the template (identity, commands, 5 conventions, 5 forbidden).
2. Add `permissions.deny` for secrets and destructive commands.
3. Add the `require-approved-spec` hook.
4. Add one rule each time Claude gets something wrong.
