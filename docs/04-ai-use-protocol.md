# 04 — AI Use Protocol

> Spanish version: [es/04-protocolo-de-uso-de-ia.md](es/04-protocolo-de-uso-de-ia.md)
> Version 1.1 · Status: active · Template: [`templates/ai/04-ai-use-protocol.md`](../templates/ai/04-ai-use-protocol.md)

## 1. Purpose and scope

Defines how AI tools are used in a project or organization: prevent security, legal and compliance risk; standardize usage; keep speed without losing accountability. Applies to everyone using AI in any capacity (code, content, analysis, automation). Mandatory and evolving.

## 2. Core principle

AI is a tool. **Humans are responsible.** AI does not decide and does not control systems. The user is accountable for inputs, outputs and consequences.

## 3. Usage tiers

### Tier 1 — Automation (no human review)
Low-risk transformation of existing content: translation, formatting, summarization, structured extraction, same-meaning rewriting, tagging. Conditions: no sensitive data, no legal/financial/regulatory impact, no decision-making output.

### Tier 2 — Assisted generation (human validation required)
New code, specs, docs, user flows, UI, marketing, prototypes. A qualified human must review before use, checking:
- **Accuracy** — correct and complete?
- **Compliance** — conforms to regulations and policy?
- **Alignment** — matches the specs (traceable to REQ/TASK)?
- Could it read as authoritative professional advice? Does it add operational, reputational or legal risk?

If unclear → escalate.

### Tier 3 — Prohibited
- **Domain-critical decisions:** legal/medical/financial advice presented as authoritative.
- **Autonomous system actions:** production changes, irreversible operations, agents acting without confirmation.
- **Security violations:** sharing keys, credentials, tokens; exposing private repos; connecting AI to production.
- **Sensitive data exposure:** PII, regulated data (HIPAA, GDPR, PCI-DSS), trade secrets, NDA material.

## 4. Inputs and access

Never provide: production access, database credentials, keys/tokens, personal data, confidential architecture, proprietary agreements.
Allowed: mock/synthetic data, sanitized or anonymized data, public documentation.

## 5. Tools and integrations

- Maintain a registry of approved tools and versions.
- **MCP servers and tool integrations:** sandbox/dev/staging only; no production access; no secrets in prompts (use env vars or a secret manager); least privilege; no autonomous irreversible actions; all usage auditable.
- **Approval process:** evaluate data access, security/privacy risk and compliance impact; get approval from the team lead or product owner; engineering validation for system integrations; document use case and scope.
- **Forbidden:** AI connected to production databases or live systems, domain-critical third-party APIs, systems with real user data; uploading real user data, confidential data or credentials.

### How this kit enforces it in Claude Code
| Rule | Enforcement |
|------|-------------|
| No secrets to AI | `permissions.deny` on `.env*`; secret-scan hook |
| No autonomous destructive actions | `deny` / `ask` rules on dangerous Bash; hook blocks |
| Human review of Tier 2 | PR template + CODEOWNERS; `status: approved` required before code |
| Auditability | Commit trailers with REQ/TASK IDs; PR label `ai-assisted` |
| Least privilege | Subagents declare minimal `tools` |

## 6. Quick check (before using AI for a task)

| # | Question | If YES |
|---|----------|--------|
| 1 | Real user data or PII involved? | Stop — use mock/sanitized data |
| 2 | Exposing credentials, keys or system access? | Stop — use env vars |
| 3 | Could the output create legal/regulatory risk? | Stop — expert review |
| 4 | Will output reach users or production without review? | Stop — add review |
| 5 | Could it trigger an irreversible operation? | Stop — require confirmation |
| 6 | Unsure it's appropriate? | Stop — escalate |

Any YES → stop and require validation.

## 7. Responsibility

The AI user owns **inputs** (what is provided), **outputs** (what is generated and how it's used) and **consequences**. No exceptions.

## 8. Compliance alignment

| Framework | Relevance |
|-----------|-----------|
| GDPR | Personal data and privacy |
| SOC 2 | Security, availability, confidentiality controls |
| HIPAA | Protected health information |
| PCI-DSS | Payment card data |
| ISO 27001 | Information security management |

Each team documents which frameworks apply and maps controls to this protocol. This kit is not legal advice.

## 9. Versioning and review

Quarterly review; review on any AI-related incident; review when adopting a new tool. Record changes in the history table.

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-04-23 | Initial version (original SDD guides) |
| 1.1 | 2026-11-19 | Added Claude Code enforcement mapping |

## Appendix A — Domain overlays

Keep the core unchanged; add an addendum extending §3 Tier 3, §4 and §8.

- **Fintech:** no content that reads as financial advice; no autonomous transactions or payment routing; add KYC/AML data to sensitive list; map to PCI-DSS, SOX.
- **Healthcare:** no diagnoses or treatment recommendations; PHI is sensitive; HIPAA-compliant handling; no patient records to external AI.
- **E-commerce:** no autonomous pricing/inventory changes; purchase and payment data are sensitive; review regulatory claims in generated copy; PCI-DSS.
- **SaaS / platform:** no AI changes to access control, permissions or tenant data; enforce multi-tenant isolation; review generated API docs; SOC 2 Type II.
