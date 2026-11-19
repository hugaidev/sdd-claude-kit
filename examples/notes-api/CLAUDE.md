# CLAUDE.md

## Project
Notes API: a tiny HTTP service to create, list and delete personal text notes (see `specs/00-constitution.md`, `specs/01-prd.md`).

## Spec-driven workflow
1. Specs live in `specs/` (numbered 00-08, plus `specs/adr/`). Read the ones a task traces to before changing code.
2. No code without approved specs (a hook enforces this). If a spec is wrong or ambiguous, stop and use the `record-spec-deviation` skill instead of improvising.
3. Every commit message references the TASK ID, e.g. `feat(notes): create endpoint [TASK-001]`.

## Stack (decided for this example, consistent with `specs/05-architecture.md` and ADR-0001)
- Node.js 22 or newer, ES modules, **no third-party dependencies**.
- HTTP: built-in `node:http`. Storage: built-in `node:sqlite` (embedded database, WAL mode). Tests: built-in `node:test` and `node:assert`.
- Layout from the architecture spec: `src/http/`, `src/service/`, `src/repo/`, `tests/`. Entry point `src/server.js`.

## Commands
- Install: nothing to install (no dependencies)
- Test: `node --test tests/` (always pass the folder; bare `node --test` can run unrelated files)
- Run: `node src/server.js` (env: `PORT` default 3000, `HOST` default 127.0.0.1, `DB_FILE` default `./notes.db`)
- Lint / type-check: none for this example; keep the code small and consistent

## Conventions
- One exported function or class per file where practical; files under 150 lines.
- Validation and the standard error envelope live in `src/http/`; business rules BR-001 to BR-006 in `src/service/` or `src/repo/` as the data model says.
- Tests use a temporary database file per test run, with synthetic data only.
- Never log note titles or bodies (NFR-002).

## Forbidden
- Editing `.env*`, committing secrets, force-pushing, skipping tests or hooks.
- Adding dependencies, endpoints or fields that are not in the specs.
- Changing an approved spec silently.
