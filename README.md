# sdd-claude-kit

Enterprise-grade kit for **Spec-Driven Development (SDD)** with Claude and Claude Code:
document templates, subagents, slash commands, skills, guardrail hooks and evals.

> Status: **under construction** (v0.1.0-dev). See [ROADMAP.md](ROADMAP.md).

## The idea

```
Idea → Constitution → PRD → Data model → API → UI/UX → Architecture → Plan → Tasks → Code → Verification
```

Specs are written and approved **before** code. Claude Code is configured to follow them,
and hooks + evals enforce it.

## What's inside

| Path | Purpose |
|------|---------|
| `docs/` | Methodology, artifact catalog, Claude Code setup, AI Use Protocol, guardrails & evals (Spanish in `docs/es/`) |
| `templates/` | One template per document to generate (product, engineering, security, operations, knowledge) |
| `.claude/agents/` | Role-focused subagents with minimal tools |
| `.claude/commands/` | `/sdd-*` slash commands, one per phase |
| `.claude/skills/` | Reusable task skills |
| `.claude/hooks/` | Guardrail scripts (spec-before-code, secrets, traceability) |
| `evals/` | Executable rubrics and validators for specs |
| `examples/` | A complete worked example |
| `scripts/` | Installer and validators |

## Quick start

```bash
# macOS / Linux / Git Bash
./scripts/install.sh /path/to/your/project
# Windows PowerShell
.\scripts\install.ps1 -Target C:\path\to\your\project
```

Then open the project in Claude Code and run `/sdd-init <your idea>`. The workflow is:
`/sdd-init` → `/sdd-constitution` → `/sdd-prd` → `/sdd-data-model` → `/sdd-api` → `/sdd-ui` → `/sdd-architecture` → `/sdd-plan` → `/sdd-verify-spec` → `/sdd-implement TASK-001`,
approving each spec with `/sdd-approve <id>`. Templates are installed to `.sdd/templates/`. The installer never overwrites existing files unless you pass `--force` / `-Force`.

## Origin

Evolved from the author's earlier SDD guides, rewritten for Claude Code and made stack-agnostic.

## License

[MIT](LICENSE) © 2026 HugAIDev
