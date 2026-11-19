# 03 — Configuración de Claude Code

> English version: [../03-claude-code-setup.md](../03-claude-code-setup.md)

Configura Claude Code como incorporarías a un nuevo ingeniero: dile quién es, cómo trabajas y qué está prohibido, y dale especialistas y playbooks.

## 1. La superficie de configuración

| Mecanismo | Ubicación | Responde | Se carga |
|-----------|-----------|----------|----------|
| `CLAUDE.md` | raíz del repo (también `~/.claude/CLAUDE.md`, subcarpetas) | *Cómo trabajamos aquí* | En cada sesión |
| `settings.json` | `.claude/settings.json` (compartido), `.claude/settings.local.json` (personal, ignorado por git) | Permisos, hooks, env | En cada sesión |
| Subagentes | `.claude/agents/*.md` | *Quién* hace qué, con qué herramientas | Al delegar |
| Comandos slash | `.claude/commands/*.md` | *Qué flujo* iniciar | Al invocar `/nombre` |
| Skills | `.claude/skills/<nombre>/SKILL.md` | *Cómo* hacer una tarea recurrente | Cuando es relevante |
| Hooks | `.claude/hooks/*` + `settings.json` | *Qué se hace cumplir* | En eventos de herramientas |
| Servidores MCP | `.mcp.json` | Herramientas/datos externos | En cada sesión |

Regla práctica: **consejo → CLAUDE.md; procedimiento → skill; rol → subagente; punto de entrada → comando; lo que nunca debe ocurrir → hook + permiso deny.**

## 2. CLAUDE.md

Mantenlo por debajo de ~200 líneas. Contenido: misión del proyecto, flujo spec-first, comandos de build/test, 5–10 convenciones concretas y acciones prohibidas. Usa imports `@ruta` para traer specs en lugar de pegarlas. Parte de [`templates/ai/claude-md.md`](../../templates/ai/claude-md.md).

Espectro de calidad de las reglas:

```text
✗ "Escribe código limpio"
~ "Usa nombres consistentes"
✓ "Funciones ≤ 40 líneas; un símbolo exportado por archivo; los errores usan AppError, nunca se lanzan strings"
```

Añade una regla cada vez que Claude falle dos veces en lo mismo.

## 3. Subagentes (`.claude/agents/<nombre>.md`)

```markdown
---
name: spec-reviewer
description: Reviews a spec against its template and upstream artifacts. Use after any spec draft.
tools: Read, Grep, Glob
model: sonnet
---
You review specs. Never edit files. Report: missing sections, ambiguity,
contradictions with upstream specs, untraced requirements. Output a numbered findings list.
```

Reglas de diseño: un rol por agente; **herramientas mínimas** (los revisores son de solo lectura); una `description` que diga *cuándo* delegar; formato de salida determinista. El kit incluye: `spec-writer`, `spec-reviewer`, `architect`, `data-modeler`, `api-designer`, `security-auditor`, `task-planner`, `implementer`, `verifier`, `traceability-checker`.

## 4. Comandos slash (`.claude/commands/<nombre>.md`)

```markdown
---
description: Draft the PRD from the approved constitution
argument-hint: <product idea or notes file>
---
Read specs/00-constitution.md (must be approved). Using templates/product/01-prd.md,
draft specs/01-prd.md for: $ARGUMENTS. Delegate review to the spec-reviewer subagent.
```

Un comando por fase: `/sdd-init`, `/sdd-constitution`, `/sdd-prd`, `/sdd-data-model`, `/sdd-api`, `/sdd-ui`, `/sdd-architecture`, `/sdd-plan`, `/sdd-verify-spec`, `/sdd-implement <TASK-ID>`, `/sdd-trace`.

## 5. Skills (`.claude/skills/<nombre>/SKILL.md`)

Un skill es un playbook parametrizado con `name` y `description` en el frontmatter (es lo que Claude usa para decidir si aplica), seguido de Parámetros → Prerrequisitos → Pasos → Resultado. Buenos skills: *add-adr*, *add-endpoint-from-contract*, *record-spec-deviation*. Enlaza los templates desde la carpeta del skill en lugar de incrustarlos.

## 6. settings.json: permisos y hooks

```json
{
  "permissions": {
    "allow": ["Bash(git status)", "Bash(git diff:*)", "Read(./specs/**)"],
    "ask":   ["Bash(git push:*)"],
    "deny":  ["Read(./.env*)", "Edit(./.env*)", "Bash(rm -rf:*)", "Bash(git push --force:*)"]
  },
  "hooks": {
    "PreToolUse": [
      { "matcher": "Edit|Write|MultiEdit",
        "hooks": [{ "type": "command", "command": ".claude/hooks/require-approved-spec.sh" }] }
    ]
  }
}
```

Los hooks reciben la llamada a la herramienta como JSON por stdin; **el código de salida 2 bloquea la llamada** y devuelve stderr a Claude. Eventos que usa este kit: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`. Detalles en [05](05-guardrails-y-evals.md).

> Verifica los nombres de campos contra la documentación vigente de Claude Code al actualizar; el esquema de configuración evoluciona.

## 7. Personal vs compartido

- Se commitea: `CLAUDE.md`, `.claude/settings.json`, agentes, comandos, skills, hooks.
- Nunca se commitea: `.claude/settings.local.json`, `.env*`, tokens.
- Las preferencias de usuario van en `~/.claude/`.

## 8. Cadencia de mantenimiento

| Cadencia | Acción |
|----------|--------|
| Cada error | Añadir o afinar una regla |
| Mensual | Podar reglas obsoletas; comprobar que las descripciones de agentes siguen activándose bien |
| Trimestral | Revisar permisos, hooks y el Protocolo de Uso de IA; volver a ejecutar los evals |

## 9. Antipatrones

1. Un CLAUDE.md de 1.000 líneas (las instrucciones se diluyen) → divídelo en skills e imports.
2. Subagentes con todas las herramientas → dales lo mínimo.
3. Reglas sin motivo → añade el *porqué*.
4. Confiar en prompts para la seguridad → usa reglas `deny` y hooks.
5. Copiar specs dentro de CLAUDE.md → importa por ruta.
6. No podar nunca → las reglas obsoletas engañan.

## 10. Configuración mínima en 15 minutos

1. Crea `CLAUDE.md` desde el template (identidad, comandos, 5 convenciones, 5 prohibiciones).
2. Añade `permissions.deny` para secretos y comandos destructivos.
3. Añade el hook `require-approved-spec`.
4. Añade una regla cada vez que Claude se equivoque.
