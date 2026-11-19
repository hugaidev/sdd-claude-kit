---
id: 03-api-contract
title: API Contract
status: approved
traces: [01-prd, 02-data-model]
owner: "@example"
version: 1.1.0
---

# API Contract

## 1. Conventions
Base path `/v1`. JSON requests and responses (`Content-Type: application/json`). IDs are UUIDs, timestamps are ISO 8601 UTC. No authentication (single-user; see PRD risks).
Pagination: `limit` (integer 1 to 100, default 20) and `cursor` (opaque string returned as `next_cursor`; it encodes the created_at and id of the last item, see BR-002). Lists are always ordered newest first; version 1 has no filtering or sorting parameters (search is a PRD non-goal).
Idempotency: GET and DELETE are idempotent; POST is not.

## 2. Standard error format
Every error uses one envelope; `details` lists the offending fields for validation errors and is empty otherwise.
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "title is required", "details": [{ "field": "title", "reason": "required" }] } }
```
Codes: `VALIDATION_ERROR` (400), `NOT_FOUND` (404), `UNSUPPORTED_MEDIA_TYPE` (415), `INTERNAL_ERROR` (500). There is no state-violation error because notes have no lifecycle states (see data model).

## 3. Endpoints
### POST /v1/notes  (traces: REQ-001)
- Auth / roles: none
- Request body: `{ "title": string (trimmed, 1 to 120 characters), "body": string (0 to 10000 characters) }`
- Response 201: `{ "id": uuid, "title": string, "body": string, "created_at": timestamp }`
- Errors: 400 `VALIDATION_ERROR` (missing or oversize field, malformed JSON; `details` names each field), 415 `UNSUPPORTED_MEDIA_TYPE` (content type is not JSON)

### GET /v1/notes  (traces: REQ-002)
- Auth / roles: none
- Query: `limit` (1 to 100, default 20), `cursor` (optional)
- Response 200: `{ "items": [Note], "next_cursor": string | null }`; an empty store returns `{ "items": [], "next_cursor": null }`; `next_cursor` is null on the last page
- Errors: 400 `VALIDATION_ERROR` (limit not an integer in range, or cursor malformed)

### DELETE /v1/notes/{id}  (traces: REQ-003)
- Auth / roles: none
- Path parameter: `id` (uuid)
- Response 204: empty body
- Errors: 400 `VALIDATION_ERROR` (id is not a uuid), 404 `NOT_FOUND` (no such note, including already deleted)

## 4. Events / webhooks (if any)
None.

## 5. Backward-compatibility policy
Additive changes only within `/v1` (new optional fields, new endpoints). Removing or renaming fields, changing types or status codes requires `/v2` and an ADR. Clients must ignore unknown response fields.
