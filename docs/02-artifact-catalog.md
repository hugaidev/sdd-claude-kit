# 02 — Artifact Catalog

> Spanish version: [es/02-catalogo-de-artefactos.md](es/02-catalogo-de-artefactos.md)

Every artifact has a template in [`templates/`](../templates). Copy it to your project's `specs/` folder and fill it in.

## Layers

| Layer | Artifacts | Templates |
|-------|-----------|-----------|
| 1. Product | Constitution, PRD, Data Model, API Contract, UI/UX, Architecture, Plan, Tasks, Verification | `templates/product/00–08` |
| 2. Engineering process | Git Strategy, CI/CD, Environments, Release Management, Code Review | `templates/engineering/09–13` |
| 3. Security & compliance | Security Spec, Data Governance | `templates/security/14–15` |
| 4. Operations | Observability, Incident Response, Performance/SLO | `templates/operations/16–18` |
| 5. AI configuration | `CLAUDE.md`, subagents, skills, hooks, AI Use Protocol | `templates/ai/`, `.claude/` |
| 6. Knowledge | ADR, Onboarding, Glossary, Dependency Policy | `templates/knowledge/19–22` |

## Required frontmatter

```yaml
---
id: 01-prd
title: Product Requirements Document
status: draft        # draft | in-review | approved | superseded
traces: [00-constitution]
owner: "@handle"
version: 0.1.0
---
```

`scripts/validate.sh` fails CI if `id`, `title`, `status` or `traces` are missing.

## Adoption by project size

| Artifact | Solo / prototype | Small team | Enterprise |
|----------|:---:|:---:|:---:|
| Constitution, PRD, Data model, API, Architecture | ● | ● | ● |
| UI/UX, Plan, Tasks, Verification | ○ | ● | ● |
| `CLAUDE.md` + 1–2 skills | ● | ● | ● |
| Subagents + hooks | ○ | ● | ● |
| Git strategy, Code review, CI/CD | ○ | ● | ● |
| Environments, Release management | | ○ | ● |
| Security spec | ○ | ● | ● |
| Data governance, Observability, SLOs, Incident response | | ○ | ● |
| ADRs, Glossary, Onboarding, Dependency policy | | ○ | ● |
| AI Use Protocol | ○ | ● | ● |

● required · ○ recommended · blank = optional

## Creation order

1. **Before any code:** Constitution → PRD → Data model → API → Architecture, plus `CLAUDE.md` and the AI Use Protocol.
2. **Before the first sprint:** UI/UX, Plan, Tasks, Verification, Git strategy, Code review, CI/CD.
3. **Before production:** Security spec, Data governance, Environments, Release, Observability, SLOs, Incident response.
4. **Ongoing:** ADRs (one per significant decision), Glossary, Onboarding, Dependency policy.

## Suggested project layout

```
your-project/
├── CLAUDE.md
├── .claude/            # agents, commands, skills, hooks, settings.json
├── specs/
│   ├── 00-constitution.md … 08-verification.md
│   ├── engineering/  security/  operations/
│   └── adr/ADR-0001-….md
└── src/                # blocked by hook until specs are approved
```

## Traceability convention

IDs are stable and never reused: `REQ-001`, `NFR-001`, `BR-001`, `TASK-001`, `TEST-001`, `ADR-0001`.

```text
API contract:   POST /bills  (traces: REQ-003)
Task:           TASK-014  traces: REQ-003, TEST-009
Verification:   TEST-009 (traces: REQ-003)
Commit:         feat(bills): create bill endpoint [TASK-014]
```
