---
description: Phase 5 - draft the UI/UX specification
argument-hint: <design references, brand constraints>
---

Phase 5: UI/UX.

1. Require approved `specs/01-prd.md` and `specs/03-api-contract.md`.
2. Delegate to the `spec-writer` subagent: draft `specs/04-ui-ux.md` from `.sdd/templates/product/04-ui-ux.md`. Every screen traces to `REQ-` IDs and lists the endpoints it uses. References: $ARGUMENTS
3. Delegate to the `spec-reviewer` subagent; apply BLOCKERS (max 2 rounds).
4. Do NOT approve. Next: `/sdd-approve 04-ui-ux`, then `/sdd-architecture`.
