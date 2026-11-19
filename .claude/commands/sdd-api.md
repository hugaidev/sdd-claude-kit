---
description: Phase 4 - draft the API contract
argument-hint: <optional notes, e.g. REST vs GraphQL preference>
---

Phase 4: API contract.

1. Require approved `specs/01-prd.md` and `specs/02-data-model.md`.
2. Delegate to the `api-designer` subagent to draft `specs/03-api-contract.md`. Extra notes: $ARGUMENTS
3. Delegate to the `spec-reviewer` subagent; apply BLOCKERS (max 2 rounds).
4. Walk each PRD workflow against the contract and list any workflow it cannot serve.
5. Do NOT approve. Next: `/sdd-approve 03-api-contract`, then `/sdd-ui` (if the product has a UI) or `/sdd-architecture`.
