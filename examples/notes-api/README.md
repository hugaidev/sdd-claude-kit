# Example: Notes API

A complete, small worked example of the kit: eight approved specs, an ADR set, and the code and tests that Claude Code implemented from them, one task at a time, with `/sdd-implement`.

| Part | Where |
|------|-------|
| Approved specs (constitution, PRD, data model, API, architecture, plan, tasks, verification) | `specs/` |
| Architecture decisions | `specs/adr/` |
| Project rules for Claude | `CLAUDE.md` |
| Implementation (Node.js, no dependencies) | `src/` |
| Tests, including the load test for NFR-001 | `tests/` |

## Run it

Requires Node.js 22 or newer (uses the built-in `node:sqlite`).

```bash
npm test                 # node --test tests/  (15 tests)
npm start                # http://127.0.0.1:3000  (env: PORT, HOST, DB_FILE)
node tests/load004.js    # TEST-004: 50 requests/s load check (see the file header)
```

```bash
curl -s -X POST localhost:3000/v1/notes -H 'content-type: application/json' -d '{"title":"hello","body":"world"}'
curl -s 'localhost:3000/v1/notes?limit=10'
```

## Check the specs

```bash
bash ../../evals/deterministic.sh .          # 9 structural and traceability checks
VERBOSE=1 bash ../../evals/run-rubric.sh specs/03-api-contract.md   # LLM-judge rubric (needs the claude CLI)
```

## How it was built (and what it taught the kit)

1. The specs were written and approved first (`specs/`); the task list in `specs/07-task-breakdown.md` drives the work.
2. Each task was implemented with `/sdd-implement TASK-00N` in a fresh Claude Code session with the kit installed, by the `implementer` subagent and checked by the `verifier` subagent. Task status moved from `todo` to `done` only after the verifier reported VERIFIED.
3. The process surfaced real problems that were fixed in the specs or the kit instead of being coded around:
   - the command text required a UI spec that the product does not have (kit fix);
   - the task definition of done asked for lint and type checks that the stack does not have (spec fix);
   - oversize request bodies had no status code (added 413 to the API contract);
   - a task row and its test disagreed on page sizes (spec fix);
   - a generated test blocked the event loop with per-row commits and failed on keep-alive connections (test fixed with one transaction).

This is a demonstration project, not a production service: single user, no authentication, and the load figures come from one developer machine.
