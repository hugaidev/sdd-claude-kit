---
description: Phase 9 - implement exactly one task from the approved breakdown
argument-hint: <TASK-ID, e.g. TASK-001>
---

Phase 9: Implementation of $ARGUMENTS.

1. Completeness gate: every required spec must exist with `status: approved` (default: 00, 01, 02, 03, 05, 06, 07, 08; `04-ui-ux` only if the product has a UI; the list is overridable in `.sdd/required-specs`), and the `traceability-checker` subagent must report PASS. If not, stop and list what is missing. The `completeness-gate` hook already enforces this; do not ask the user to create a UI spec for a product without a UI.
2. Confirm the task exists in `specs/07-task-breakdown.md` and its dependencies are done.
3. Delegate to the `implementer` subagent with the task ID.
4. Delegate to the `verifier` subagent for the requirements in scope.
5. If the implementer reported a spec deviation, do not code around it: present it and propose the spec change.
6. Summarize: files changed, tests run, verifier result. Update the task status in `specs/07-task-breakdown.md` only if the verifier reports VERIFIED.
