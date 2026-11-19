---
id: 01-prd
title: Product Requirements Document
status: approved
traces: [00-constitution]
owner: "@example"
version: 1.1.0
---

# Product Requirements Document

## 1. Problem & context
Developers who automate personal workflows (shell scripts, cron jobs, small bots) need a place to drop short text notes without opening an app. Today they append to local files, which are not reachable from other machines and have no ordering or deletion semantics, or they use heavyweight note apps whose APIs require accounts, OAuth and SDKs. Evidence: the maintainer's own scripts keep notes in five different ad-hoc files, and every comparable hosted service needs a sign-up flow before the first request.

## 2. Goals and non-goals
- Goals:
  - G1: a client can store a note in a single HTTP call with no sign-up (verified by REQ-001).
  - G2: a client can read back its notes newest first, page by page (REQ-002).
  - G3: 95 percent of create and list calls complete in under 200 ms at 50 requests per second (NFR-001).
- Non-goals: accounts, sharing, search, attachments, rich text. These are deferred, not rejected, and need their own PRD.

## 3. Personas
| Persona | Needs | Success looks like |
|---------|-------|--------------------|
| Script author | Store a note from a script in one call | A success response that includes the new note id |
| Note keeper | See recent notes and remove old ones | Newest notes listed first; a deleted note never reappears |

## 4. Functional requirements
| ID | Requirement | Priority (MoSCoW) | Acceptance criteria (Given/When/Then) |
|----|-------------|-------------------|----------------------------------------|
| REQ-001 | A client can create a note with a title and body | Must | Given a title of 1 to 120 characters and a body of up to 10000 characters When the client creates a note Then the note is stored and the client receives the note with a generated id and creation time. Given a missing or empty title or an oversize field When the client creates a note Then nothing is stored and the client receives a validation error naming the field |
| REQ-002 | A client can list notes, newest first, in pages | Must | Given 25 stored notes and a page size of 10 When the client requests pages in sequence Then it receives pages of 10, 10 and 5 notes, newest first, with no note repeated or skipped. Given no stored notes When the client lists Then it receives an empty page and no continuation marker. Given an invalid page size When the client lists Then it receives a validation error |
| REQ-003 | A client can delete a note by id | Should | Given an existing note When the client deletes it Then it no longer appears in any listing. Given an id that does not exist or was already deleted When the client deletes it Then it receives a not-found error and no other note changes |

## 5. Non-functional requirements
| ID | Category | Requirement | Measure |
|----|----------|-------------|---------|
| NFR-001 | Performance | Create and list respond quickly under normal load | p95 latency under 200 ms at 50 requests per second with 1000 stored notes |
| NFR-002 | Security | All input is validated at the boundary and note contents are never written to logs | Validation tests for every field; log inspection in the load test shows no note text |
| NFR-003 | Reliability | A note acknowledged to the client is durable | After a process restart, 100 percent of previously acknowledged notes are still listed |

## 6. Workflows
1. Create: client sends title and body and receives the stored note. Error path: invalid input is rejected with a message naming the field, and nothing is stored.
2. Browse: client lists notes page by page until no continuation remains. Error paths: an invalid page size or malformed continuation marker is rejected; an empty store returns an empty page.
3. Clean up: client deletes a note it no longer needs. Error path: deleting a missing note reports not found.

## 7. Assumptions, risks, open questions
| Type | Item | Owner | Due |
|------|------|-------|-----|
| Assumption | Single-user deployment, so no authentication is needed in this version | @example | n/a |
| Risk | Without authentication the service must not be exposed to the public internet; mitigated by deployment guidance in the architecture | @example | before first release |
| Risk | Cursor-based paging may be implemented incorrectly and skip notes with equal timestamps; mitigated by the tie-break rule BR-002 and TEST-002 | @example | TASK-002 |
| Open question | Is a maximum total note count needed to protect disk space? Deferred until real usage data exists | @example | after first release |
