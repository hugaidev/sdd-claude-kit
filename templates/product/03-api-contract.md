---
id: 03-api-contract
title: API Contract
status: draft
traces: [01-prd,02-data-model]
owner: "{{owner}}"
version: 0.1.0
---

# API Contract

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

> Contract first. Prefer an OpenAPI file referenced here as source of truth.

## 1. Conventions
Base path, versioning, auth scheme, pagination, filtering, idempotency, date/ID formats.

## 2. Standard error format
```json
{ "error": { "code": "{{CODE}}", "message": "{{}}", "details": [] } }
```

## 3. Endpoints
### {{METHOD}} {{/path}}  (traces: REQ-001)
- Auth / roles: {{}}
- Request schema: {{}}
- Response 2xx: {{}}
- Errors: 400 {{}}, 401, 403, 404, 409, 422
- Rate limit: {{}}

## 4. Events / webhooks (if any)
| Event | Payload | Delivery guarantees |
|-------|---------|---------------------|

## 5. Backward-compatibility policy
{{Deprecation window, breaking-change rules.}}
