---
description: Bootstrap SDD in this project (specs folder, CLAUDE.md check, context loading)
argument-hint: <one-paragraph product idea, or path to a brief>
---

You are starting Spec-Driven Development (Phase 0: context loading).

1. Ensure `specs/` and `specs/adr/` exist. Ensure `.sdd/templates/` exists; if not, tell the user to run the kit installer.
2. If `CLAUDE.md` is missing, create it from `.sdd/templates/ai/claude-md.md` and ask the user for the build/test commands.
3. Read the idea or brief: $ARGUMENTS
4. Ask the user (max 8 short questions, in one message) about: target users, core workflows, hard constraints (tech, legal, budget, deadline), integrations, what is explicitly out of scope, and any reference products.
5. Save the answers in `specs/00-context.md` (frontmatter: id `00-context`, status `approved`, traces `[]`).
6. Tell the user the next step is `/sdd-constitution`. Do not write any other spec yet.
