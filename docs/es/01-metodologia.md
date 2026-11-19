# 01 — Metodología: Spec-Driven Development con Claude

> English version: [../01-methodology.md](../01-methodology.md)

## 1. Por qué SDD

| Tradicional | Spec-Driven |
|-------------|-------------|
| Idea → Código → Docs | Idea → Specs → Código |
| La documentación es un añadido tardío | Las specs dirigen todo |
| La IA adivina convenciones | La IA sigue convenciones escritas |
| Resultados inconsistentes | Resultados consistentes y trazables |

Los asistentes de IA son rápidos pero literales: rellenan los vacíos con suposiciones verosímiles. Una spec escrita y revisada elimina esos vacíos, y la velocidad del asistente se convierte en trabajo correcto y no en deriva rápida.

## 2. Principios

1. **Specs antes que código.** Define el *qué* y el *por qué* antes del *cómo*.
2. **Tú aportas la intención; la IA la estructura.** El humano decide; Claude redacta y contrasta.
3. **Configura al agente como incorporas a un desarrollador.** `CLAUDE.md`, subagentes, skills y hooks son ese onboarding.
4. **Trazabilidad.** Cada línea de código se traza a una tarea, un requisito y una prueba (`REQ → API → TASK → TEST`).
5. **Las specs están vivas.** Si la implementación demuestra que una spec es errónea, se corrige primero la spec y luego el código.
6. **Se hace cumplir, no se sugiere.** Hooks y evals vuelven ejecutables las reglas (ver [05](05-guardrails-y-evals.md)).

## 3. El flujo de trabajo

```
Fase 0  Carga de contexto
Fase 1  Constitución            → templates/product/00-constitution.md
Fase 2  Requisitos de producto  → 01-prd.md
Fase 3  Modelo de datos         → 02-data-model.md
Fase 4  Contrato de API         → 03-api-contract.md
Fase 5  Especificación UI/UX    → 04-ui-ux.md
Fase 6  Arquitectura            → 05-architecture.md
Fase 7  Plan y tareas           → 06-implementation-plan.md, 07-task-breakdown.md
Fase 8  Especificación de verificación → 08-verification.md
Fase 9  Implementación          → código, guiado por tareas
```

Cada fase tiene un comando slash (`/sdd-*`, que se añade en la Fase 4 de este kit), un subagente que la redacta y un eval que la revisa.

### El ciclo de interacción (en cada fase)

1. **Tú** das contexto e intención.
2. **Claude** redacta el artefacto a partir del template.
3. **El agente revisor y los evals** comprueban estructura, trazabilidad y consistencia.
4. **Tú** apruebas, rechazas o pides cambios.
5. Al aprobar, pon `status: approved` en el frontmatter. El artefacto queda congelado; los cambios pasan por una revisión.

Nunca te saltes el paso 4. Las specs sin revisar arrastran suposiciones a todos los artefactos posteriores.

## 4. Grafo de dependencias

```
Idea
 └─ 00-constitution
     └─ 01-prd
         ├─ 02-data-model ─┐
         ├─ 03-api-contract├─ 05-architecture ─ 06-plan ─ 07-tasks ─ código
         └─ 04-ui-ux ──────┘
 08-verification valida 01–05 y controla el release
CLAUDE.md + agentes + skills + hooks informan todas las fases
El Protocolo de Uso de IA gobierna cómo se usa la IA en todo el proceso
```

## 5. Usar bien Claude Code en cada fase

- **Fases 0–8:** usa el **modo plan** y subagentes de solo lectura; Claude no debe tocar `src/`.
- **Fase 9:** trabaja **una tarea a la vez**. Dale a Claude el ID de la tarea; leerá solo las specs enlazadas. Un commit por tarea, con los IDs en el mensaje.
- **Higiene de contexto:** una sesión nueva por fase. Las specs en disco son la memoria, no el chat.
- **Desviaciones de la spec:** detente, propón un cambio de spec, obtén aprobación y entonces programa.

## 6. Antipatrones

| No hagas | Por qué | Haz en su lugar |
|----------|---------|-----------------|
| Generar todas las specs de una vez | Se diluye el contexto y aparecen contradicciones | Un artefacto a la vez, revisado |
| Saltarte la revisión | Las suposiciones erróneas se propagan | Léelo todo; pregunta "¿por qué X y no Y?" |
| Tratar las specs como documentación de solo lectura | Una spec obsoleta engaña | Actualiza primero la spec, luego el código |
| Sobreespecificar la implementación | Las specs se vuelven frágiles | Especifica comportamiento, interfaces y restricciones |
| Especificar un dominio que no entiendes | Basura entra, basura sale | Estudia el dominio y luego estructúralo con IA |
| Tratar las primeras specs como sagradas | Las specs posteriores revelan errores | Presupuesta 2–3 pasadas de revisión |

Sobreespecificado vs bien especificado:

```text
✗ "Crea un bucle for sobre bills y comprueba bill.status === 'DRAFT'..."
✓ "Eliminar una factura exige estado DRAFT; si no, devolver 400 con 'Only draft bills can be deleted'."
```

## 7. Puerta de completitud (antes de la Fase 9)

- [ ] Constitución aprobada; todos los requisitos del PRD tienen ID y criterios de aceptación
- [ ] Modelo de datos, API y UI son coherentes entre sí (mismas entidades, mismos nombres)
- [ ] Decisiones de arquitectura registradas como ADR
- [ ] Todo REQ tiene al menos un TEST; toda TASK se traza a un REQ
- [ ] Spec de seguridad y Protocolo de Uso de IA en vigor
- [ ] Sin preguntas abiertas marcadas como bloqueantes

El agente `traceability-checker` y `evals/` automatizan la mayor parte de esta lista.
