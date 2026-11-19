---
description: Phase 7 - draft the implementation plan and task breakdown
argument-hint: <team size, deadline, other constraints>
---

Phase 7: Plan and tasks.

1. Require approved specs 00 to 05.
2. Delegate to the `task-planner` subagent to draft `specs/06-implementation-plan.md` and `specs/07-task-breakdown.md`. Constraints: $ARGUMENTS
3. Delegate to the `traceability-checker` subagent and confirm every `REQ-` is covered by a task.
4. Delegate to the `spec-reviewer` subagent for each file; apply BLOCKERS (max 2 rounds).
5. Do NOT approve. Next: `/sdd-approve 06-implementation-plan`, `/sdd-approve 07-task-breakdown`, then `/sdd-verify-spec`.
