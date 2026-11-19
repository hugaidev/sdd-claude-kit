---
id: ai-claude-md
title: CLAUDE.md for your project
status: draft
traces: [00-constitution]
owner: "{{owner}}"
version: 0.1.0
---

# CLAUDE.md for your project

> Copy the block below to the root of your project as `CLAUDE.md`. Keep it short (under 200 lines); move detail into specs and skills.

```markdown
# CLAUDE.md

## Project
{{one-paragraph mission, from 00-constitution}}

## Spec-driven workflow
1. Specs live in `specs/` (numbered 00-08). Read the relevant ones before changing code.
2. No code without an approved spec (`status: approved`). If a spec is missing, run the matching /sdd-* command first.
3. Every change references REQ/TASK IDs in commits and PRs.

## Commands
- Install: `{{}}`  Test: `{{}}`  Lint: `{{}}`  Run: `{{}}`

## Conventions
- {{5-10 concrete rules}}

## Forbidden
- Editing `.env*`, committing secrets, force-pushing, skipping tests or hooks.
- Deviating from specs silently; propose a spec change instead.
```
