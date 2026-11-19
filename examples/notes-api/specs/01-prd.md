---
id: 01-prd
title: Product Requirements Document
status: approved
traces: [00-constitution]
owner: "@example"
version: 1.0.0
---

# Product Requirements Document

## 1. Problem & context
People want a minimal programmatic place to keep short notes. Existing apps are heavy; scripts and other tools need a plain API.

## 2. Goals and non-goals
- Goals: create, list and delete notes through a documented API; respond fast.
- Non-goals: accounts, sharing, search, attachments.

## 3. Personas
| Persona | Needs | Success looks like |
|---------|-------|--------------------|
| Script author | Store a note from a script in one call | A 201 response with the note id |
| Note keeper | See recent notes and remove old ones | Newest notes listed first, deletion is final |

## 4. Functional requirements
| ID | Requirement | Priority (MoSCoW) | Acceptance criteria (Given/When/Then) |
|----|-------------|-------------------|----------------------------------------|
| REQ-001 | A client can create a note with a title and body | Must | Given a valid title and body When the client creates a note Then the note is stored and returned with an id |
| REQ-002 | A client can list notes, newest first, with pagination | Must | Given stored notes When the client lists notes Then they are returned newest first in pages |
| REQ-003 | A client can delete a note by id | Must | Given an existing note When the client deletes it Then it no longer appears in listings |

## 5. Non-functional requirements
| ID | Category | Requirement | Measure |
|----|----------|-------------|---------|
| NFR-001 | Performance | List and create respond quickly under normal load | p95 under 200 ms at 50 requests per second |

## 6. Workflows
1. Create: client sends title and body, receives the stored note.
2. Browse: client lists notes page by page.
3. Clean up: client deletes a note it no longer needs; deleting a missing note reports not found.

## 7. Assumptions, risks, open questions
| Type | Item | Owner | Due |
|------|------|-------|-----|
| Assumption | Single-user deployment, no authentication | @example | n/a |
