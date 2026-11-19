# Evals

Three levels, from cheap and strict to expensive and fuzzy.

| Level | Script | Cost | Runs in CI | What it answers |
|-------|--------|------|-----------|-----------------|
| 1. Deterministic | `evals/deterministic.sh [project]` | free, seconds | yes | Are the specs structurally sound and traceable? |
| 2. Rubric (LLM judge) | `evals/run-rubric.sh <spec.md>` | tokens | on demand / nightly | Are the specs good, not just well-formed? |
| 3. Behavioral cases | `evals/run-cases.sh` | tokens, slow | on demand / nightly | Does Claude Code, with this kit installed, behave as the rules say? |

In an installed project the scripts live in `.sdd/evals/` (rubrics in `.sdd/evals/rubrics/`).

## 1. Deterministic checks

```bash
bash evals/deterministic.sh path/to/project      # needs <project>/specs/
```

| ID | Check |
|----|-------|
| D1 | Frontmatter valid: `id` equals filename, legal `status`, `traces` resolve |
| D2 | Required sections of the matching template exist (non-draft specs) |
| D3 | Approved specs contain no `{{placeholders}}` or `OPEN QUESTION` |
| D4 | Traceability: every REQ has a TASK and a TEST, no undefined references |
| D5 | No duplicate NFR, BR, TASK or TEST IDs |
| D6 | Every REQ has Given/When/Then acceptance criteria |
| D7 | Every API endpoint heading traces to a REQ |
| D8 | Every TEST traces to a REQ |
| D9 | An approved spec never depends on a spec that is not approved |

Exit code 0 = all pass, 1 = failures, 2 = usage error. The checks are themselves tested:
`bash scripts/test-evals.sh` requires `examples/notes-api` to pass 9/9 and `evals/fixtures/bad` (seeded defects) to fail every check.

## 2. Rubric evals (LLM-as-judge)

```bash
bash evals/run-rubric.sh specs/01-prd.md
```

Each artifact has a rubric in `evals/rubrics/<spec-id>.md`: weighted criteria (`- ID | weight 1-3 | check`) converted from the review checklists of the original guides. The judge scores each 0 (not met), 1 (partial), 2 (met) with an evidence quote; the weighted score must reach `pass_threshold` (default 0.8) and every criterion must be scored.

- Default judge: `claude -p` (Claude Code headless, prompt on stdin). Override with `JUDGE_CMD`, a command that reads the prompt on stdin and prints `ID|score|evidence` lines. The command is word-split, so avoid spaces in its path.
- Upstream specs listed in `traces` are included as context.
- Spec content is treated as data to score, never as instructions.
- LLM judges are noisy: use them to find problems, not as an approval authority. Approval stays human (`/sdd-approve`).

Rubrics exist for: 00, 01, 02, 03, 04, 05, 06, 07, 08 and 14-security-spec. Add one per new artifact (copy the format; the self-test checks filename, at least 5 criteria and unique IDs).

## 3. Behavioral cases

```bash
bash evals/run-cases.sh                       # all cases
bash evals/run-cases.sh --only env-file-not-created
```

Each `evals/cases/<name>.case` installs the kit into a temporary sandbox, copies a fixture's `specs/`, runs a prompt through `claude -p`, then asserts on the output and the files. Skips with exit 0 when the CLI is not installed. Cases shipped:

| Case | Asserts |
|------|---------|
| `reviewer-reports-seeded-defects` | spec-reviewer returns CHANGES_REQUESTED for a defective spec |
| `implement-blocked-without-approved-specs` | `/sdd-implement` creates no source files while specs are unapproved |
| `code-blocked-before-approval` | `src/index.js` cannot be created before approval |
| `env-file-not-created` | a `.env` with secrets is never written |
| `approve-refuses-placeholders` | `/sdd-approve` leaves a spec with placeholders as draft |
| `trace-reports-gaps` | `/sdd-trace` reports FAIL on a project with gaps |

Model behavior is non-deterministic: run a failing case a few times before concluding it is a regression.

## Fixtures

- `examples/notes-api/` — a small, fully approved, consistent project. Must pass 9/9.
- `evals/fixtures/bad/` — a project with defects seeded on purpose, one or more per check.
- `evals/fixtures/fake-judge.sh`, `fake-claude.sh` — stand-ins used only by the self-tests.

## Adding a check

1. Add the function to `evals/deterministic.sh`.
2. Seed a defect for it in `evals/fixtures/bad/`.
3. Assert it in `scripts/test-evals.sh`.
