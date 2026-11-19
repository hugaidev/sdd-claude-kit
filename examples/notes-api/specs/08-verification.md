---
id: 08-verification
title: Verification Specification
status: approved
traces: [01-prd, 03-api-contract, 07-task-breakdown]
owner: "@example"
version: 1.1.0
---

# Verification Specification

## 1. Test strategy
Integration tests drive the HTTP layer against a database file in a temporary folder created per test run, so tests never touch real data. Unit tests cover validation and cursor encoding. One load test covers NFR-001. All test data is synthetic: titles like "note-001", bodies of generated lorem text, never real personal data. Tests run in CI on every pull request; the load test runs on demand and for P2.

## 2. Traceability matrix
| Requirement | Test IDs | Type | Status |
|-------------|----------|------|--------|
| REQ-001 | TEST-001, TEST-005, TEST-006 | integration | planned |
| REQ-002 | TEST-002, TEST-004 | integration, load | planned |
| REQ-003 | TEST-003 | integration | planned |
| NFR-001 (via REQ-002) | TEST-004 | load | planned |
| NFR-002 (via REQ-001) | TEST-006 | integration | planned |
| NFR-003 (via REQ-001) | TEST-005 | integration | planned |

## 3. Test cases
### TEST-001 (traces: REQ-001)
- Preconditions: empty store
- Steps: (a) POST `{"title":"note-001","body":"hello"}`; (b) POST with title `""`; (c) POST with a title of 121 characters; (d) POST with a body of 10001 characters; (e) POST with a text/plain content type; (f) POST malformed JSON
- Expected: (a) 201 with `id`, `title`, `body`, `created_at`; (b) 400 `VALIDATION_ERROR` with `details[0].field == "title"`; (c) 400 naming `title`; (d) 400 naming `body`; (e) 415 `UNSUPPORTED_MEDIA_TYPE`; (f) 400 `VALIDATION_ERROR`; the store contains exactly one note afterwards

### TEST-002 (traces: REQ-002)
- Preconditions: 25 stored notes created at distinct times, plus two notes created with the same timestamp
- Steps: GET with limit 10 and follow `next_cursor` until null; GET on an empty store; GET with limit 0, limit 101, limit abc and a garbage cursor
- Expected: pages of 10, 10 and 7 newest first with no repeats or skips (including the equal-timestamp pair, ordered by id); empty store gives `{"items":[],"next_cursor":null}`; each invalid query gives 400 `VALIDATION_ERROR`

### TEST-003 (traces: REQ-003)
- Preconditions: one stored note
- Steps: DELETE it; DELETE it again; DELETE a random uuid; DELETE `not-a-uuid`; list notes
- Expected: 204, then 404 `NOT_FOUND`, 404 `NOT_FOUND`, 400 `VALIDATION_ERROR`; the list is empty

### TEST-004 (traces: REQ-002)
- Preconditions: 1000 stored synthetic notes
- Steps: 50 requests per second for 60 seconds, mixing 80 percent list calls and 20 percent create calls
- Expected: p95 latency under 200 ms separately for create and list, and no 5xx responses (verifies NFR-001)

### TEST-005 (traces: REQ-001)
- Preconditions: empty store
- Steps: create 10 notes and wait for each 201; stop the process abruptly; start it again; list all notes
- Expected: all 10 acknowledged notes are listed (verifies NFR-003)

### TEST-006 (traces: REQ-001)
- Preconditions: log output captured
- Steps: create a note whose body contains a unique marker string; read all captured log lines
- Expected: the marker string appears in no log line, while the request is logged with method, path and status (verifies NFR-002)

## 4. End-to-end walkthrough
1. Start with an empty store. 2. Create note A and note B. 3. List: B then A, no continuation. 4. Create 25 more notes and page through with limit 10: three pages, newest first. 5. Try to create a note with an empty title and confirm the 400 and that the count is unchanged. 6. Delete note A. 7. Delete note A again and confirm 404. 8. List and confirm A is gone and ordering is preserved. 9. Restart the service and list again to confirm nothing acknowledged was lost.

## 5. Non-functional verification
Performance: TEST-004 against NFR-001. Security: validation cases in TEST-001 and TEST-002 and the log check in TEST-006 against NFR-002. Reliability: TEST-005 against NFR-003. Accessibility is not applicable (no user interface).

## 6. Exit criteria / release gate
Release is allowed when: every TEST-001 to TEST-006 passes in CI on the release commit; the TEST-004 result is attached to the release notes; `/sdd-trace` reports PASS; the evals in `evals/deterministic.sh` pass 9 of 9; no open blocker findings. Environment for the gate: CI runner with a clean temporary directory.
