---
id: 10-ci-cd
title: CI/CD Pipeline
status: draft
traces: [09-git-strategy,11-environments]
owner: "{{owner}}"
version: 0.1.0
---

# CI/CD Pipeline

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## Stages
| Stage | Trigger | Steps | Blocking? |
|-------|---------|-------|-----------|
| Validate | PR | lint, type-check, spec validation | yes |
| Test | PR | unit, integration | yes |
| Security | PR | SAST, dependency and secret scan | yes |
| Build | merge | artifact + SBOM | yes |
| Deploy | merge/tag | per environment | gated |

## Environment promotion
{{dev, staging, prod; approvals; rollback}}

## Secrets and permissions
Least-privilege tokens, OIDC over long-lived keys.

## Performance budget
Target pipeline time: {{}}
