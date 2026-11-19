# sdd-claude-kit

A kit for **Spec-Driven Development (SDD)** with Claude and Claude Code: document templates, subagents, slash commands, skills, guardrail hooks and evals. Write and approve specs first; let Claude implement one verified task at a time; have hooks and evals keep it honest.

```
Idea → Constitution → PRD → Data model → API → UI/UX → Architecture → Plan → Tasks → Code → Verification
```

> Status: **v0.1.0**, first public release. It works end to end (see [what is verified](#what-is-verified)), but it is young: expect rough edges and open an issue when you find one. Spanish documentation: [docs/es/](docs/es/).

## Why

AI coding assistants are fast and literal; they fill gaps with plausible guesses. A written, reviewed spec removes the gaps. This kit gives Claude Code the structure to work that way and enforces it with permissions, hooks and tests, instead of only asking nicely in a prompt.

## What's inside

| Path | What it is |
|------|-----------|
| [`templates/`](templates) | 25 document templates, one per artifact: product (constitution, PRD, data model, API, UI/UX, architecture, plan, tasks, verification), engineering, security, operations, knowledge, AI config |
| [`.claude/agents/`](.claude/agents) | 10 subagents with minimal tools: `spec-writer`, `spec-reviewer`, `architect`, `data-modeler`, `api-designer`, `security-auditor`, `task-planner`, `implementer`, `verifier`, `traceability-checker` |
| [`.claude/commands/`](.claude/commands) | 13 slash commands: `/sdd-init`, `/sdd-constitution`, `/sdd-prd`, `/sdd-data-model`, `/sdd-api`, `/sdd-ui`, `/sdd-architecture`, `/sdd-plan`, `/sdd-verify-spec`, `/sdd-implement`, `/sdd-trace`, `/sdd-security`, `/sdd-approve` |
| [`.claude/skills/`](.claude/skills) | 3 skills: `add-adr`, `record-spec-deviation`, `add-endpoint-from-contract` |
| [`.claude/hooks/`](.claude/hooks) + [`settings.json`](.claude/settings.json) | 6 guardrail hooks and a permission set: no code before approved specs, no secrets, no destructive commands, spec format checks, traceability, completeness gate |
| [`evals/`](evals) | 9 deterministic checks, 10 LLM-judge rubrics, 6 behavioral cases |
| [`examples/notes-api/`](examples/notes-api) | A small worked example: approved specs plus the code and tests Claude implemented from them |
| [`docs/`](docs) | Methodology, artifact catalog, Claude Code setup, AI Use Protocol, guardrails and evals |

## Requirements

- [Claude Code](https://docs.claude.com/en/docs/claude-code) (the kit was tested with 2.1.328).
- `bash` for the hooks and scripts: Linux, macOS, or Git Bash on Windows. The hooks use only `grep`, `sed` and `awk`; no `jq`, Python or Node.
- Node.js 22+ only for the example project.

## Quick start

```bash
# macOS / Linux / Git Bash
./scripts/install.sh /path/to/your/project
# Windows PowerShell
.\scripts\install.ps1 -Target C:\path\to\your\project
```

The installer copies agents, commands, skills, hooks and evals into your project, templates into `.sdd/templates/`, and creates `specs/`. It never overwrites existing files unless you pass `--force` / `-Force`, and if you already have a `.claude/settings.json` it tells you to merge the permissions and hooks by hand.

Then open the project in Claude Code and follow the workflow, approving each spec yourself with `/sdd-approve <id>`:

```
/sdd-init <your idea>   →   /sdd-constitution   →   /sdd-prd   →   /sdd-data-model   →   /sdd-api
→   /sdd-architecture   →   /sdd-plan   →   /sdd-verify-spec   →   /sdd-implement TASK-001   →   ...
```

(`/sdd-ui` is only needed if your product has a UI.) Until the required specs are approved, a hook blocks edits to code files, and `/sdd-implement` refuses to run.

See [`examples/notes-api`](examples/notes-api) for what the result looks like.

## What is verified

- 96 self-tests: hooks (46) and evals (50), run in CI.
- With a real Claude Code session: the 6 behavioral cases pass, and the guardrails block what they should; turning the gate off makes the matching case fail, so the checks are not vacuous.
- The worked example was implemented task by task with `/sdd-implement` (5 tasks, 15 tests passing, specs pass 9/9 deterministic checks and the rubrics).
- `install.ps1` and `install.sh` were run against empty and populated target folders.

## Known limitations

- **Windows speed:** each hook call takes about a second under Git Bash. Linux and macOS are faster.
- **Secret detection is heuristic.** It catches common key formats and `password = "..."` literals, not everything. It is a safety net, not a replacement for review or a secret scanner.
- **LLM-judge scores are noisy.** Rubrics find problems; they do not approve anything. Approval is always the human's `/sdd-approve`.
- **Headless runs** (`claude -p`) in a folder you have not trusted ignore `permissions.allow` entries from `settings.json` (deny rules and hooks still apply), and commits asked about by the `ask` rule are denied.
- The kit has been exercised mostly on one Windows machine so far; reports from other platforms are welcome.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Run `bash scripts/validate.sh`, `bash scripts/test-hooks.sh` and `bash scripts/test-evals.sh` before opening a pull request. Security issues: [SECURITY.md](SECURITY.md).

## Origin

Evolved from the author's earlier SDD guides, rewritten for Claude Code, made stack-agnostic, and turned from prose into executable parts. The original repositories are now archived:

- [slackdevs/spec-driven-development-guides](https://github.com/slackdevs/spec-driven-development-guides): the original four guides (CC0).
- [slackdevs/sdc-spec-driven-development-guides](https://github.com/slackdevs/sdc-spec-driven-development-guides): a second copy of the same guides with a longer commit history (identical content).

## License

[MIT](LICENSE) © 2026 HugAIDev
