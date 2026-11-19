---
id: 12-release-management
title: Release Management
status: draft
traces: [09-git-strategy,10-ci-cd]
owner: "{{owner}}"
version: 0.1.0
---

# Release Management

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## Versioning
SemVer. Breaking change = major; see `03-api-contract` compatibility policy.

## Release process
1. Freeze and changelog 2. Release candidate 3. Verify (`08-verification` gate) 4. Tag 5. Deploy 6. Announce

## Rollback and hotfix
{{criteria, steps, max time}}

## Release checklist
- [ ] Changelog updated
- [ ] Migrations reversible
- [ ] Feature flags set
- [ ] Runbook current
