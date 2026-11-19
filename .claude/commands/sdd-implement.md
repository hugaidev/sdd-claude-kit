---
description: Phase 9 - implement exactly one task from the approved breakdown
argument-hint: <TASK-ID, e.g. TASK-001>
---

Phase 9: Implementation of $ARGUMENTS.

1. Completeness gate: specs 00 to 08 must exist with `status: approved`, and the `traceability-checker` subagent must report PASS. If not, stop and list what is missing.
2. Confirm the task exists in `specs/07-task-breakdown.md` and its dependencies are done.
3. Delegate to the `implementer` subagent with the task ID.
4. Delegate to the `verifier` subagent for the requirements in scope.
5. If the implementer reported a spec deviation, do not code around it: present it and propose the spec change.
6. Summarize: files changed, tests run, verifier result. Update the task status in `specs/07-task-breakdown.md` only if the verifier reports VERIFIED.
