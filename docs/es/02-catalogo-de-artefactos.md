# 02 — Catálogo de artefactos

> English version: [../02-artifact-catalog.md](../02-artifact-catalog.md)

Cada artefacto tiene un template en [`templates/`](../../templates). Cópialo a la carpeta `specs/` de tu proyecto y complétalo.

## Capas

| Capa | Artefactos | Templates |
|------|-----------|-----------|
| 1. Producto | Constitución, PRD, Modelo de datos, Contrato de API, UI/UX, Arquitectura, Plan, Tareas, Verificación | `templates/product/00–08` |
| 2. Proceso de ingeniería | Estrategia Git, CI/CD, Entornos, Gestión de releases, Code review | `templates/engineering/09–13` |
| 3. Seguridad y cumplimiento | Spec de seguridad, Gobernanza de datos | `templates/security/14–15` |
| 4. Operaciones | Observabilidad, Respuesta a incidentes, Rendimiento/SLO | `templates/operations/16–18` |
| 5. Configuración de IA | `CLAUDE.md`, subagentes, skills, hooks, Protocolo de Uso de IA | `templates/ai/`, `.claude/` |
| 6. Conocimiento | ADR, Onboarding, Glosario, Política de dependencias | `templates/knowledge/19–22` |

## Frontmatter obligatorio

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

`scripts/validate.sh` hace fallar el CI si falta `id`, `title`, `status` o `traces`.

## Adopción según el tamaño del proyecto

| Artefacto | Solo / prototipo | Equipo pequeño | Enterprise |
|-----------|:---:|:---:|:---:|
| Constitución, PRD, Modelo de datos, API, Arquitectura | ● | ● | ● |
| UI/UX, Plan, Tareas, Verificación | ○ | ● | ● |
| `CLAUDE.md` + 1–2 skills | ● | ● | ● |
| Subagentes + hooks | ○ | ● | ● |
| Estrategia Git, Code review, CI/CD | ○ | ● | ● |
| Entornos, Gestión de releases | | ○ | ● |
| Spec de seguridad | ○ | ● | ● |
| Gobernanza de datos, Observabilidad, SLOs, Incidentes | | ○ | ● |
| ADR, Glosario, Onboarding, Política de dependencias | | ○ | ● |
| Protocolo de Uso de IA | ○ | ● | ● |

● obligatorio · ○ recomendado · vacío = opcional

## Orden de creación

1. **Antes de cualquier código:** Constitución → PRD → Modelo de datos → API → Arquitectura, más `CLAUDE.md` y el Protocolo de Uso de IA.
2. **Antes del primer sprint:** UI/UX, Plan, Tareas, Verificación, Estrategia Git, Code review, CI/CD.
3. **Antes de producción:** Spec de seguridad, Gobernanza de datos, Entornos, Releases, Observabilidad, SLOs, Respuesta a incidentes.
4. **Continuo:** ADR (uno por decisión relevante), Glosario, Onboarding, Política de dependencias.

## Estructura de proyecto sugerida

```
tu-proyecto/
├── CLAUDE.md
├── .claude/            # agents, commands, skills, hooks, settings.json
├── specs/
│   ├── 00-constitution.md … 08-verification.md
│   ├── engineering/  security/  operations/
│   └── adr/ADR-0001-….md
└── src/                # bloqueado por un hook hasta que las specs estén aprobadas
```

## Convención de trazabilidad

Los IDs son estables y nunca se reutilizan: `REQ-001`, `NFR-001`, `BR-001`, `TASK-001`, `TEST-001`, `ADR-0001`.

```text
Contrato API:   POST /bills  (traces: REQ-003)
Tarea:          TASK-014  traces: REQ-003, TEST-009
Verificación:   TEST-009 (traces: REQ-003)
Commit:         feat(bills): create bill endpoint [TASK-014]
```
