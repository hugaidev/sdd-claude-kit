---
description: Phase 8 - draft the verification specification (test matrix)
argument-hint: <test tooling preferences>
---

Phase 8: Verification spec.

1. Require approved specs 00 to 07.
2. Delegate to the `spec-writer` subagent: draft `specs/08-verification.md` from `.sdd/templates/product/08-verification.md`. Every `REQ-` gets at least one `TEST-` ID. Tooling notes: $ARGUMENTS
3. Delegate to the `traceability-checker` subagent; fix gaps by re-delegating to `spec-writer`.
4. Delegate to the `spec-reviewer` subagent; apply BLOCKERS (max 2 rounds).
5. Do NOT approve. Next: `/sdd-approve 08-verification`, then `/sdd-implement TASK-001`.
