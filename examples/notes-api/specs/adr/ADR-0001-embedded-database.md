---
id: ADR-0001
title: Use an embedded database
status: approved
traces: [05-architecture]
owner: "@example"
version: 1.0.0
---

# ADR-0001: Use an embedded database

- Status: accepted
- Date: 2026-11-19  Deciders: @example

## Context
The service is single-user, targets 50 requests per second (NFR-001) and must make acknowledged writes durable (NFR-003). The constitution allows one relational or document store and forbids unneeded complexity.

## Options considered
1. Embedded database (a single file managed in-process) — pros: one process to deploy, zero network hops, simple backup (copy the file), transactional durability; cons: no horizontal scaling, one writer at a time.
2. Client-server relational database — pros: scales out, familiar operations tooling; cons: second service to run, secure and back up, overkill for the stated load.
3. Plain append-only file — pros: trivial; cons: no indexed ordering, hard to delete safely, easy to corrupt on crash.

## Decision
We will use an embedded database with write-ahead logging, stored on a persistent volume.

## Consequences
- Positive: deployment is one process and one file; durability comes from the database transaction log.
- Negative: scaling beyond one instance needs a migration to option 2; revisit if the single-user assumption changes (new ADR).
- Follow-up: TASK-005 verifies durability across restarts (NFR-003).
