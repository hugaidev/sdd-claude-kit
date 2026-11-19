---
id: 18-performance-slo
title: Performance and SLO Specification
status: draft
traces: [01-prd,05-architecture]
owner: "{{owner}}"
version: 0.1.0
---

# Performance and SLO Specification

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## SLIs / SLOs
| Service | SLI | SLO | Window | Error budget |
|---------|-----|-----|--------|--------------|
| API | p95 latency | under {{300 ms}} | 30d | |
| API | availability | {{99.9%}} | 30d | |

## Load profile
Expected RPS, peak, data volume.

## Scaling strategy and capacity
{{}}

## Error-budget policy
{{What happens when the budget is exhausted.}}
