---
id: 04-ai-use-protocol
title: AI Use Protocol
status: draft
traces: [00-constitution]
owner: "{{owner}}"
version: 0.1.0
---

# AI Use Protocol

> Instructions for the author (human or AI): replace every {{placeholder}}, delete guidance blockquotes when done, and set `status: approved` only after review.

## Tier 1 — Automation (no review)
Formatting, translation, summarization of non-sensitive text.

## Tier 2 — Assisted generation (human review required)
Code, tests, specs, docs, UI. The reviewer owns the result.

## Tier 3 — Prohibited
Autonomous production changes, sharing restricted data, unreviewed merges, credentials in prompts.

## Data rules
Allowed and forbidden inputs per classification in `15-data-governance`.

## Tools and MCP
Approval process, allow-list, forbidden integrations: {{}}

## Quick check (6 questions)
1. Is the data allowed? 2. Which tier? 3. Who reviews? 4. Is output traceable to a spec? 5. Any secrets involved? 6. Is it reversible?

## Compliance mapping
{{GDPR / SOC 2 / ISO 27001 / HIPAA / PCI-DSS controls}}
