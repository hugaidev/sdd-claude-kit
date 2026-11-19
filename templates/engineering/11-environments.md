---
id: 11-environments
title: Environment Strategy
status: draft
traces: [05-architecture]
owner: "{{owner}}"
version: 0.1.0
---

# Environment Strategy

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

| Environment | Purpose | Data | Access | Deploy trigger |
|-------------|---------|------|--------|----------------|
| local | dev | synthetic | devs | manual |
| staging | pre-prod | anonymized | team | merge |
| production | live | real | restricted | gated |

## Configuration
Variables per environment (names only, never values): `{{VAR}}` — source: {{secret manager}}.

## Parity and drift policy
{{}}
