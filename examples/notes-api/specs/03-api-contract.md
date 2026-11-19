---
id: 03-api-contract
title: API Contract
status: approved
traces: [01-prd, 02-data-model]
owner: "@example"
version: 1.0.0
---

# API Contract

## 1. Conventions
Base path `/v1`. JSON requests and responses (`Content-Type: application/json`). IDs are UUIDs, timestamps are ISO 8601 UTC. No authentication (single-user). Pagination: `limit` (1 to 100, default 20) and `cursor` (opaque string).

## 2. Standard error format
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "title is required", "details": [] } }
```

## 3. Endpoints
### POST /v1/notes  (traces: REQ-001)
- Auth / roles: none
- Request: `{ "title": string (1-120), "body": string (0-10000) }`
- Response 201: `{ "id", "title", "body", "created_at" }`
- Errors: 400 `VALIDATION_ERROR`, 415 unsupported media type

### GET /v1/notes  (traces: REQ-002)
- Auth / roles: none
- Query: `limit`, `cursor`
- Response 200: `{ "items": [Note], "next_cursor": string | null }`, newest first
- Errors: 400 `VALIDATION_ERROR` (bad limit or cursor)

### DELETE /v1/notes/{id}  (traces: REQ-003)
- Auth / roles: none
- Response 204: empty body
- Errors: 404 `NOT_FOUND`, 400 `VALIDATION_ERROR` (id is not a uuid)

## 4. Events / webhooks (if any)
None.

## 5. Backward-compatibility policy
Additive changes only within `/v1`. Breaking changes require `/v2` and an ADR.
