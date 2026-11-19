---
description: Phase 1 - draft the project constitution (non-negotiable principles)
argument-hint: <optional extra principles or constraints>
---

Phase 1: Constitution.

1. Require `specs/00-context.md`. If missing, tell the user to run `/sdd-init`.
2. Delegate to the `spec-writer` subagent: draft `specs/00-constitution.md` from `.sdd/templates/product/00-constitution.md` using the context and: $ARGUMENTS
3. Delegate to the `spec-reviewer` subagent and apply its BLOCKERS (re-delegate to `spec-writer` if needed; max 2 rounds).
4. Present the final draft summary, assumptions and open questions to the user.
5. Do NOT set `status: approved`. Tell the user to review and run `/sdd-approve 00-constitution`, then `/sdd-prd`.
