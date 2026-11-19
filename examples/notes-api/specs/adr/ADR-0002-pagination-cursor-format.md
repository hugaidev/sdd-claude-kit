---
id: ADR-0002
title: Pagination cursor format
status: approved
traces: [02-data-model, 03-api-contract, 05-architecture]
owner: "@example"
version: 1.0.0
---

# ADR-0002: Pagination cursor format

- Status: accepted
- Date: 2026-11-19  Deciders: @example

## Context
GET /v1/notes pages newest first (BR-002: created_at descending, ties by id ascending). Timestamps can be equal, so a cursor on created_at alone would skip or repeat notes (plan risk, TASK-002). The contract says the cursor is opaque and encodes the created_at and id of the last item.

## Options considered
1. Offset cursor (number of rows to skip) — pros: trivial; cons: skips or repeats rows when notes are created or deleted between requests, slow for deep pages.
2. Keyset cursor on created_at only — pros: stable under inserts; cons: loses notes that share a timestamp across a page boundary.
3. Keyset cursor on (created_at, id), encoded as base64url of the JSON array `[created_at, id]` — pros: stable under inserts and deletes, uses the created_at index, matches BR-002 exactly; cons: clients must treat it as opaque, and the format is internal.

## Decision
Option 3. The next page is `WHERE created_at < :c OR (created_at = :c AND id > :id) ORDER BY created_at DESC, id ASC LIMIT :limit + 1`; the extra row tells whether `next_cursor` is null. A cursor is rejected (400 `VALIDATION_ERROR`, field `cursor`) unless it is base64url, decodes to a two-element JSON array, the first is a canonical ISO 8601 UTC timestamp and the second is a UUID. Encoding and decoding live in `src/repo/cursor.js`; the service maps the repository's invalid-cursor error to the standard envelope.

## Consequences
- Positive: no skips or repeats, including equal timestamps across a page boundary (TEST-002).
- Negative: the format is fixed once clients store cursors; changing it needs a compatibility decision under the `/v1` policy.
- Follow-up: add the reference to `05-architecture` section 3 when the human approves this ADR (approved specs were not edited by TASK-002).
