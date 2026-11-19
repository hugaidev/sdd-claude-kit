# 05 — Guardrails y Evals

> English version: [../05-guardrails-and-evals.md](../05-guardrails-and-evals.md)

Los prompts piden; los guardrails obligan; los evals miden. Este kit usa los tres.

## 1. Defensa en profundidad

| Capa | Mecanismo | Fuerza |
|------|-----------|--------|
| 1. Instrucción | `CLAUDE.md`, skills | Blanda — puede ignorarse |
| 2. Permisos | `permissions.allow/ask/deny` | Dura — se bloquea antes de ejecutar |
| 3. Hook | Scripts en eventos de herramientas | Dura — lógica propia, exit 2 bloquea |
| 4. CI | `scripts/validate.sh`, evals, escaneo de secretos | Dura — bloquea el merge |
| 5. Humano | Revisión de PR, CODEOWNERS | Autoridad final |

## 2. Hooks incluidos en el kit (`.claude/hooks/`)

| Hook | Evento | Comportamiento |
|------|--------|----------------|
| `require-approved-spec` | PreToolUse (Edit/Write) | Bloquea escrituras en `src/` salvo que `specs/` contenga specs aprobadas para el trabajo |
| `block-secrets` | PreToolUse (Edit/Write/Read/Bash) | Bloquea tocar `.env*`, archivos de claves y escribir cadenas con aspecto de secreto |
| `block-destructive-bash` | PreToolUse (Bash) | Bloquea `rm -rf`, force-push, `DROP TABLE`, etc. |
| `validate-spec-format` | PostToolUse (Edit/Write en `specs/`) | Comprueba frontmatter y secciones requeridas; devuelve errores a Claude |
| `check-traceability` | PostToolUse / Stop | Verifica que los IDs referenciados existan; sin REQ/TASK/TEST huérfanos |
| `completeness-gate` | UserPromptSubmit (`/sdd-implement`) | Rechaza la Fase 9 hasta que pase el checklist de completitud |

### Contrato de un hook

- Entrada: JSON por stdin (`tool_name`, `tool_input`, `cwd`, …).
- **Exit 0** = permitir. **Exit 2** = bloquear; stderr se muestra a Claude para que corrija el rumbo. Otros códigos = error no bloqueante.
- Hooks rápidos, deterministas y con pocas dependencias. Los del kit son bash puro (grep/sed/awk): no necesitan `jq`, Python ni Node. En Windows corren vía Git Bash, donde lanzar procesos es lento (medido: cerca de 1 s por llamada), así que mantenlos pequeños.
- Válvulas de escape: `SDD_ENFORCE=off` desactiva el bloqueo de código sin specs aprobadas durante una sesión; `.sdd/required-specs` define qué specs deben estar aprobadas; `SDD_TRACE_STRICT=1` vuelve bloqueante el chequeo de trazabilidad del hook Stop.
- Fallar **cerrado** en hooks de seguridad, **abierto** en los de conveniencia.

Ejemplo (esbozo):

```bash
#!/usr/bin/env bash
payload=$(cat)
file=$(echo "$payload" | jq -r '.tool_input.file_path // empty')
case "$file" in
  */src/*) grep -rqs '^status: approved' specs/ || { echo "Blocked: no approved specs. Run /sdd-* first." >&2; exit 2; } ;;
esac
exit 0
```

## 3. Evals

Implementados en [`evals/`](../../evals/README.md): `deterministic.sh` (checks D1–D9), `run-rubric.sh` (juez LLM), `run-cases.sh` (casos de comportamiento). Las descripciones de abajo explican el diseño.

Los evals responden: **¿son suficientemente buenas las specs y el comportamiento del agente?** Hay dos tipos.

### Deterministas (corren en CI, gratis, rápidos)
- Frontmatter presente y válido; valores de `status` legales.
- Existen las secciones requeridas de cada template.
- Ningún `{{placeholder}}` sin resolver en specs `approved`.
- Trazabilidad: todo REQ tiene ≥ 1 TEST; toda TASK se traza a un REQ; todo ID referenciado existe.
- Nombres entre specs: las entidades de API/UI existen en el modelo de datos.

### Basados en rúbrica (LLM-as-judge, opcional, bajo demanda)
Cada artefacto tiene `evals/rubrics/<artefacto>.md`, convertido de los checklists de revisión de las guías originales: criterios puntuados 0–2 con citas de evidencia, más un umbral de aprobación.

```yaml
criteria:
  - id: PRD-01
    check: Every requirement has a testable acceptance criterion
    weight: 3
  - id: PRD-02
    check: No implementation details (HOW) in requirements
    weight: 2
pass_threshold: 0.8
```

### Evals de comportamiento de los agentes
Casos "golden" en `evals/cases/`: un prompt, un proyecto fixture y propiedades esperadas (p. ej., "el intento de editar `.env` se bloquea", "el implementer se niega sin spec aprobada", "el reviewer reporta la contradicción sembrada"). Se ejecutan contra los hooks directamente (unitarios) y contra Claude Code en modo headless (`claude -p`) para extremo a extremo.

## 4. CI

```text
push/PR → validate.sh (frontmatter) → evals (deterministas) → tests de hooks → escaneo de secretos
```

Los evals con rúbrica corren de noche o con la etiqueta `run-evals` para controlar costos.

## 5. Gobernar los guardrails

- Cada hook tiene un test y una razón documentada.
- Los cambios en `.claude/settings.json` y `.claude/hooks/` requieren revisión de CODEOWNERS.
- Registra los intentos bloqueados para la revisión trimestral del [Protocolo de Uso de IA](04-protocolo-de-uso-de-ia.md).
