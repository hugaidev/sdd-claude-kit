---
id: 00-constitution
title: Constitution
status: draft
traces: []
owner: "{{owner}}"
version: 0.1.0
---

# Constitution

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

> Non-negotiable principles. Every other artifact must comply. Keep under 2 pages.

## 1. Mission
{{One sentence: what this product exists to do and for whom.}}

## 2. Principles (MUST / MUST NOT)
- MUST {{principle}} — *Why:* {{reason}}
- MUST NOT {{principle}} — *Why:* {{reason}}

## 3. Quality bar
- Testing: {{minimum coverage / required test types}}
- Accessibility: {{standard}}
- Performance: see `18-performance-slo`
- Security: see `14-security-spec`

## 4. Technology constraints
| Area | Decision | Locked? |
|------|----------|---------|
| Language/runtime | {{}} | yes/no |
| Data store | {{}} | yes/no |

## 5. Out of scope (forever)
- {{}}

## 6. Amendment process
Changes require an ADR (`19-adr`) approved by {{role}}.
