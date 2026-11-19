---
id: 09-git-strategy
title: Git Strategy
status: draft
traces: [00-constitution]
owner: "{{owner}}"
version: 0.1.0
---

# Git Strategy

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## Branch model
{{GitHub Flow | Trunk-based | GitFlow}} — why: {{}}

## Branch naming
`feat/<id>-<slug>`, `fix/<id>-<slug>`, `docs/…`, `chore/…`

## Commits
Conventional Commits: `type(scope): subject`. Types: feat, fix, docs, refactor, test, chore, ci.

## Merge strategy
{{squash | rebase | merge commit}}

## Protected branch rules (`main`)
- PR required, {{N}} approval(s), CODEOWNERS review
- Required checks: {{ci}}
- No force-push, linear history {{yes/no}}, signed commits {{yes/no}}
