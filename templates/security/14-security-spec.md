---
id: 14-security-spec
title: Security Specification
status: draft
traces: [00-constitution,03-api-contract]
owner: "{{owner}}"
version: 0.1.0
---

# Security Specification

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## Threat model
Assets, actors, trust boundaries, top threats (STRIDE). Link diagram.

## Authentication
Method, session/token lifetime, MFA, credential policy.

## Authorization
| Role | Permissions | Resources |
|------|-------------|-----------|

## OWASP Top 10 mitigations
| Risk | Mitigation | Verified by |
|------|-----------|-------------|

## Transport and headers
TLS, HSTS, CSP, CORS, cookie flags.

## Secrets management and key rotation
{{}}

## Supply chain
See `22-dependency-policy`.
