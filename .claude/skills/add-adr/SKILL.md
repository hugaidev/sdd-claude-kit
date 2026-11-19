---
name: add-adr
description: Record an architecture decision as a numbered ADR in specs/adr/. Use whenever a significant technical choice is made or changed.
---

# Skill: Add ADR

## Parameters
- `title` — short decision title
- `context` — forces and constraints (ask the user if unknown)

## Prerequisites
- `specs/adr/` exists (create it if not).
- Template: `.sdd/templates/knowledge/19-adr.md`.

## Steps
1. List `specs/adr/` and take the next number `NNNN` (zero-padded, never reuse).
2. Copy the template to `specs/adr/ADR-NNNN-<kebab-title>.md`; fill frontmatter (`id: ADR-NNNN`, `traces`: the spec sections affected).
3. Write Context, at least two Options with pros and cons, the Decision, and Consequences.
4. If it supersedes an earlier ADR, set that ADR's status to `superseded by ADR-NNNN`; do not edit its body.
5. Add the ADR ID to the relevant section of `specs/05-architecture.md`.

## Result
New ADR file, updated architecture reference. Status stays `proposed` until the human accepts it.
