---
id: 13-code-review
title: Code Review Standards
status: draft
traces: [09-git-strategy]
owner: "{{owner}}"
version: 0.1.0
---

# Code Review Standards

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## PR requirements
Linked task/requirement, description of *why*, tests, small diff (max {{400}} lines), screenshots for UI.

## Reviewer checklist
- [ ] Matches spec (REQ/API/data model)
- [ ] Tests meaningful
- [ ] Security and privacy
- [ ] Errors/logging
- [ ] Docs updated

## AI-generated code
Must be labelled in the PR and reviewed at Tier 2 level per `04-ai-use-protocol`.

## SLA
First review within {{1 business day}}.
