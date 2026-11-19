---
id: 22-dependency-policy
title: Dependency Policy
status: draft
traces: [14-security-spec]
owner: "{{owner}}"
version: 0.1.0
---

# Dependency Policy

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## Approval criteria
License allow-list ({{MIT, Apache-2.0, BSD}}), maintenance health, security record, size.

## Updates
Automated PRs (Dependabot/Renovate), cadence {{weekly}}, critical CVE SLA {{48h}}.

## Pinning and lockfiles
{{}}

## Prohibited
Unmaintained packages, incompatible copyleft, unreviewed install scripts.
