# 01 — Methodology: Spec-Driven Development with Claude

> Spanish version: [es/01-metodologia.md](es/01-metodologia.md)

## 1. Why SDD

| Traditional | Spec-Driven |
|-------------|-------------|
| Idea → Code → Docs | Idea → Specs → Code |
| Docs are an afterthought | Specs drive everything |
| AI guesses conventions | AI follows written conventions |
| Inconsistent output | Consistent, traceable output |

AI assistants are fast but literal. They fill gaps with plausible assumptions. A written, reviewed spec removes the gaps, so the assistant's speed turns into correct work instead of fast drift.

## 2. Principles

1. **Specs before code.** Define *what* and *why* before *how*.
2. **You provide intent; AI structures it.** The human owns decisions; Claude drafts and cross-checks.
3. **Configure the agent like you onboard a developer.** `CLAUDE.md`, subagents, skills and hooks are the onboarding.
4. **Traceability.** Every line of code traces to a task, a requirement and a test (`REQ → API → TASK → TEST`).
5. **Specs are living.** If implementation proves a spec wrong, update the spec first, then the code.
6. **Enforced, not suggested.** Hooks and evals make the rules executable (see [05](05-guardrails-and-evals.md)).

## 3. The workflow

```
Phase 0  Context loading
Phase 1  Constitution          → templates/product/00-constitution.md
Phase 2  Product requirements  → 01-prd.md
Phase 3  Data model            → 02-data-model.md
Phase 4  API contract          → 03-api-contract.md
Phase 5  UI/UX specification   → 04-ui-ux.md
Phase 6  Architecture          → 05-architecture.md
Phase 7  Plan and tasks        → 06-implementation-plan.md, 07-task-breakdown.md
Phase 8  Verification spec     → 08-verification.md
Phase 9  Implementation        → code, driven by tasks
```

Each phase has a slash command (`/sdd-*`), a subagent that drafts it, and an eval that reviews it.

### The interaction loop (every phase)

1. **You** give context and intent.
2. **Claude** drafts the artifact from the template.
3. **The reviewer agent and evals** check structure, traceability and consistency.
4. **You** approve, reject or request changes.
5. On approval set `status: approved` in the frontmatter. The artifact is frozen; changes go through a revision.

Never skip step 4. Unreviewed specs carry assumptions into every downstream artifact.

## 4. Artifact dependency graph

```
Idea
 └─ 00-constitution
     └─ 01-prd
         ├─ 02-data-model ─┐
         ├─ 03-api-contract├─ 05-architecture ─ 06-plan ─ 07-tasks ─ code
         └─ 04-ui-ux ──────┘
 08-verification validates 01–05 and gates release
CLAUDE.md + agents + skills + hooks inform every phase
AI Use Protocol governs how AI is used throughout
```

## 5. Using Claude Code well in each phase

- **Phases 0–8:** use **plan mode** and read-only subagents; Claude should not touch `src/`.
- **Phase 9:** work **one task at a time**. Give Claude the task ID; it reads only the linked specs. Commit per task with the IDs in the message.
- **Context hygiene:** start a fresh session per phase. Specs on disk are the memory, not the chat.
- **Spec deviations:** stop, propose a spec change, get approval, then code.

## 6. Anti-patterns

| Don't | Why | Do instead |
|-------|-----|-----------|
| Generate all specs in one shot | Context dilution, internal contradictions | One artifact at a time, reviewed |
| Skip review | Plausible but wrong assumptions propagate | Read it all; ask "why X over Y?" |
| Treat specs as read-only docs | Stale specs mislead | Update spec first, then code |
| Over-specify implementation | Specs become brittle | Specify behavior, interfaces, constraints |
| Spec a domain you don't understand | Garbage in, garbage out | Study the domain, then structure it with AI |
| Treat early specs as sacred | Later specs reveal errors | Budget 2–3 revision passes |

Over-specified vs well-specified:

```text
✗ "Create a for loop over bills and check bill.status === 'DRAFT'..."
✓ "Deleting a bill requires DRAFT status; otherwise return 400 with 'Only draft bills can be deleted'."
```

## 7. Completeness gate (before Phase 9)

- [ ] Constitution approved; PRD requirements all have IDs and acceptance criteria
- [ ] Data model, API and UI consistent with each other (same entities, same names)
- [ ] Architecture decisions recorded as ADRs
- [ ] Every REQ has at least one TEST; every TASK traces to a REQ
- [ ] Security spec and AI Use Protocol in place
- [ ] No open questions marked blocking

The `traceability-checker` agent and `evals/` automate most of this list.
