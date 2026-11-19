---
id: 07-task-breakdown
title: Task Breakdown
status: approved
traces: [06-implementation-plan]
owner: "@example"
version: 1.1.0
---

# Task Breakdown

Each task is at most one working day and can be understood with only its row and the specs it traces to.

| ID | Task | Phase | Traces (REQ / API / TEST) | Depends on | Definition of done | Status |
|----|------|-------|---------------------------|------------|--------------------|--------|
| TASK-001 | Project skeleton, note repository and POST /v1/notes with validation and the standard error mapper | P1 | REQ-001, POST /v1/notes, TEST-001 | none | TEST-001 passes including 400 with field details and 415; lint and type checks pass; one command starts the service | todo |
| TASK-002 | Decide the cursor format (created_at plus id, BR-002) and implement GET /v1/notes with pagination | P1 | REQ-002, GET /v1/notes, TEST-002 | TASK-001 | TEST-002 passes: pages of 10, 10 and 5 with no repeats, empty store gives an empty page, bad limit or cursor gives 400 | todo |
| TASK-003 | DELETE /v1/notes/{id} with not-found and invalid-id handling | P2 | REQ-003, DELETE /v1/notes/{id}, TEST-003 | TASK-001 | TEST-003 passes: 204, then 404 on repeat, 400 on a non-uuid id, listing no longer contains the note | todo |
| TASK-004 | Load test of create and list at 50 requests per second against 1000 notes | P2 | REQ-002, NFR-001, TEST-004 | TASK-002 | TEST-004 result attached to the pull request showing p95 under 200 ms for both create and list | todo |
| TASK-005 | Durability across restart and log-content check; bind address defaults to internal | P1 | REQ-001, NFR-002, NFR-003, TEST-005, TEST-006 | TASK-001 | TEST-005 passes (acknowledged notes survive a restart); TEST-006 passes (no note text in logs); default listen address is not public | todo |
