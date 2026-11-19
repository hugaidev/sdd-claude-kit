---
name: add-endpoint-from-contract
description: Implement one API endpoint exactly as defined in specs/03-api-contract.md, with its tests. Use when a task says to implement an endpoint.
---

# Skill: Add Endpoint From Contract

## Parameters
- `endpoint` — method and path as written in the contract (e.g. `POST /bills`)
- `task` — the TASK ID

## Prerequisites
- Specs 02, 03, 05 and 08 approved; the task exists in `specs/07-task-breakdown.md`.
- Test, lint and type-check commands defined in `CLAUDE.md`.

## Steps
1. Read the endpoint section of the contract, the entities it touches in the data model, and the tests mapped to its REQ in the verification spec.
2. Write tests first: success case, each documented error status, authorization, validation limits.
3. Implement following the structure in `specs/05-architecture.md` and conventions in `CLAUDE.md`. Request and response shapes must match the contract exactly, including the standard error envelope.
4. Enforce the business rules (`BR-`) listed for the entities involved, at the layer the architecture assigns.
5. Run tests, lint and type-check until green.
6. If the contract cannot be implemented as written, use the `record-spec-deviation` skill.

## Result
Endpoint plus tests, commit `feat(<area>): <endpoint> [TASK-NNN]`.
