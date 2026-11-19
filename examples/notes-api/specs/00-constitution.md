---
id: 00-constitution
title: Constitution
status: approved
traces: []
owner: "@example"
version: 1.0.0
---

# Constitution

## 1. Mission
Give individuals a tiny, reliable HTTP API to create, list and delete personal text notes.

## 2. Principles (MUST / MUST NOT)
- MUST validate every input at the API boundary — *Why:* untrusted input is the main failure source.
- MUST keep the API stateless and idempotent where the verb allows — *Why:* simple horizontal scaling.
- MUST cover every requirement with at least one automated test — *Why:* specs are only real if verified.
- MUST NOT log note contents — *Why:* notes may hold personal data.
- MUST NOT add features that are not traced to a requirement — *Why:* scope discipline.

## 3. Quality bar
- Testing: every REQ has a TEST; CI blocks merges on failure.
- Accessibility: not applicable (no UI).
- Performance: see NFR-001 in the PRD.
- Security: input validation, no secrets in the repo.

## 4. Technology constraints
| Area | Decision | Locked? |
|------|----------|---------|
| Interface | JSON over HTTP | yes |
| Language/runtime | any mainstream, chosen in architecture | no |
| Data store | a single relational or document store | no |

## 5. Out of scope (forever)
- User accounts and sharing between users
- Rich text and attachments

## 6. Amendment process
Changes require an ADR approved by the maintainer.
