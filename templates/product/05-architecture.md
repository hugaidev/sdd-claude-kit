---
id: 05-architecture
title: Architecture
status: draft
traces: [00-constitution,01-prd,02-data-model,03-api-contract]
owner: "{{owner}}"
version: 0.1.0
---

# Architecture

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## 1. Context diagram
```mermaid
flowchart LR
  User --> System --> ExternalService
```

## 2. Containers / components
| Component | Responsibility | Tech | Owns data |
|-----------|----------------|------|-----------|

## 3. Key decisions
Link each to an ADR: ADR-0001 {{title}}.

## 4. Repository / file structure
```
{{tree}}
```

## 5. Cross-cutting concerns
Auth, config, logging, error handling, caching, feature flags.

## 6. Deployment topology
Environments, networking, scaling — see `11-environments`.

## 7. Risks and trade-offs
{{}}
