---
id: 16-observability
title: Observability Specification
status: draft
traces: [05-architecture]
owner: "{{owner}}"
version: 0.1.0
---

# Observability Specification

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## Logging
Structured JSON; fields: timestamp, level, trace_id, service, message. Never log PII or secrets.

## Metrics
RED (rate, errors, duration) per service plus business metrics: {{}}

## Tracing
{{OpenTelemetry}}; sampling {{}}.

## Alerts
| Alert | Condition | Severity | Runbook |
|-------|-----------|----------|---------|

## Health endpoints
`/health/live`, `/health/ready` — semantics.
