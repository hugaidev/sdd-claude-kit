---
description: Phase 6 - draft the architecture and record ADRs
argument-hint: <optional technology preferences>
---

Phase 6: Architecture.

1. Require approved constitution, PRD, data model and API contract (UI/UX too if it exists).
2. Delegate to the `architect` subagent to draft `specs/05-architecture.md` and the needed `specs/adr/ADR-*.md`. Preferences: $ARGUMENTS
3. Delegate to the `spec-reviewer` subagent; apply BLOCKERS (max 2 rounds).
4. Present the key decisions and the risks that need the human to choose.
5. Do NOT approve. Next: `/sdd-approve 05-architecture`, then `/sdd-plan`.
