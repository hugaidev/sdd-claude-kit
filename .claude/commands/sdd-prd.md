---
description: Phase 2 - draft the Product Requirements Document
argument-hint: <product notes, or path to a notes file>
---

Phase 2: PRD.

1. Require `specs/00-constitution.md` with `status: approved`. If not, stop and say so.
2. Delegate to the `spec-writer` subagent: draft `specs/01-prd.md` from `.sdd/templates/product/01-prd.md`, using `specs/00-context.md` and: $ARGUMENTS
   - Every requirement gets a `REQ-` ID and Given/When/Then acceptance criteria. Priorities use MoSCoW.
3. Delegate to the `spec-reviewer` subagent; apply BLOCKERS (max 2 rounds).
4. Challenge the draft yourself: list the 3 priorities you are least sure about and ask the user to confirm.
5. Do NOT approve. Next: `/sdd-approve 01-prd`, then `/sdd-data-model`.
