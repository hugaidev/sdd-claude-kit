# 04 — Protocolo de Uso de IA

> English version: [../04-ai-use-protocol.md](../04-ai-use-protocol.md)
> Versión 1.1 · Estado: activo · Template: [`templates/ai/04-ai-use-protocol.md`](../../templates/ai/04-ai-use-protocol.md)

## 1. Propósito y alcance

Define cómo se usan las herramientas de IA en un proyecto u organización: prevenir riesgos de seguridad, legales y de cumplimiento; estandarizar el uso; mantener la velocidad sin perder responsabilidad. Aplica a todas las personas que usen IA de cualquier forma (código, contenido, análisis, automatización). Es obligatorio y evoluciona.

## 2. Principio central

La IA es una herramienta. **Los humanos son responsables.** La IA no decide ni controla sistemas. La persona usuaria responde por entradas, salidas y consecuencias.

## 3. Niveles de uso

### Nivel 1 — Automatización (sin revisión humana)
Transformación de bajo riesgo de contenido existente: traducción, formato, resumen, extracción estructurada, reescritura con el mismo sentido, etiquetado. Condiciones: sin datos sensibles, sin impacto legal/financiero/regulatorio, sin salidas que tomen decisiones.

### Nivel 2 — Generación asistida (requiere validación humana)
Código nuevo, specs, documentación, flujos de usuario, UI, marketing, prototipos. Una persona cualificada debe revisar antes de usar, comprobando:
- **Exactitud** — ¿es correcto y completo?
- **Cumplimiento** — ¿se ajusta a regulaciones y políticas?
- **Alineación** — ¿coincide con las specs (trazable a REQ/TASK)?
- ¿Podría leerse como asesoría profesional con autoridad? ¿Añade riesgo operativo, reputacional o legal?

Si hay dudas → escalar.

### Nivel 3 — Prohibido
- **Decisiones críticas de dominio:** asesoría legal/médica/financiera presentada como autoritativa.
- **Acciones autónomas sobre sistemas:** cambios en producción, operaciones irreversibles, agentes actuando sin confirmación.
- **Violaciones de seguridad:** compartir claves, credenciales o tokens; exponer repos privados; conectar IA a producción.
- **Exposición de datos sensibles:** PII, datos regulados (HIPAA, GDPR, PCI-DSS), secretos comerciales, material bajo NDA.

## 4. Entradas y accesos

Nunca proporcionar: acceso a producción, credenciales de base de datos, claves/tokens, datos personales, arquitectura confidencial, acuerdos propietarios.
Permitido: datos de prueba/sintéticos, datos sanitizados o anonimizados, documentación pública.

## 5. Herramientas e integraciones

- Mantener un registro de herramientas y versiones aprobadas.
- **Servidores MCP e integraciones:** solo sandbox/dev/staging; sin acceso a producción; sin secretos en prompts (usar variables de entorno o gestor de secretos); mínimo privilegio; sin acciones irreversibles autónomas; todo uso auditable.
- **Proceso de aprobación:** evaluar acceso a datos, riesgo de seguridad/privacidad e impacto de cumplimiento; aprobación del líder de equipo o product owner; validación de ingeniería para integraciones con sistemas; documentar caso de uso y alcance.
- **Prohibido:** IA conectada a bases de datos de producción o sistemas en vivo, APIs de terceros críticas, sistemas con datos reales de usuarios; subir datos reales, datos confidenciales o credenciales.

### Cómo lo hace cumplir este kit en Claude Code
| Regla | Mecanismo |
|-------|-----------|
| Sin secretos hacia la IA | `permissions.deny` sobre `.env*`; hook de escaneo de secretos |
| Sin acciones destructivas autónomas | Reglas `deny` / `ask` sobre Bash peligroso; hook de bloqueo |
| Revisión humana en Nivel 2 | Template de PR + CODEOWNERS; `status: approved` antes de programar |
| Auditabilidad | IDs REQ/TASK en commits; etiqueta `ai-assisted` en PR |
| Mínimo privilegio | Los subagentes declaran `tools` mínimas |

## 6. Chequeo rápido (antes de usar IA en una tarea)

| # | Pregunta | Si es SÍ |
|---|----------|----------|
| 1 | ¿Hay datos reales de usuarios o PII? | Detente — usa datos de prueba/sanitizados |
| 2 | ¿Expongo credenciales, claves o accesos? | Detente — usa variables de entorno |
| 3 | ¿La salida podría crear riesgo legal/regulatorio? | Detente — revisión experta |
| 4 | ¿La salida llegará a usuarios o producción sin revisión? | Detente — añade revisión |
| 5 | ¿Podría disparar una operación irreversible? | Detente — exige confirmación |
| 6 | ¿Dudo de si es apropiado? | Detente — escala |

Cualquier SÍ → detente y exige validación.

## 7. Responsabilidad

Quien usa la IA responde por las **entradas** (qué se aporta), las **salidas** (qué se genera y cómo se usa) y las **consecuencias**. Sin excepciones.

## 8. Alineación de cumplimiento

| Marco | Relevancia |
|-------|-----------|
| GDPR | Datos personales y privacidad |
| SOC 2 | Controles de seguridad, disponibilidad y confidencialidad |
| HIPAA | Información de salud protegida |
| PCI-DSS | Datos de tarjetas de pago |
| ISO 27001 | Gestión de seguridad de la información |

Cada equipo documenta qué marcos aplican y mapea controles a este protocolo. Este kit no constituye asesoría legal.

## 9. Versionado y revisión

Revisión trimestral; revisión ante cualquier incidente relacionado con IA; revisión al adoptar una herramienta nueva. Registra los cambios en la tabla de historial.

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0 | 2026-04-23 | Versión inicial (guías SDD originales) |
| 1.1 | 2026-11-19 | Mapeo de cumplimiento en Claude Code |

## Apéndice A — Overlays por dominio

Mantén el núcleo intacto; añade un addendum que extienda el Nivel 3 (§3), §4 y §8.

- **Fintech:** nada que se lea como asesoría financiera; sin transacciones ni enrutamiento de pagos autónomos; añadir datos KYC/AML a la lista sensible; mapear a PCI-DSS, SOX.
- **Salud:** sin diagnósticos ni recomendaciones de tratamiento; PHI es sensible; manejo conforme a HIPAA; sin historiales de pacientes hacia IA externa.
- **E-commerce:** sin cambios autónomos de precios/inventario; datos de compra y pago son sensibles; revisar afirmaciones regulatorias en textos generados; PCI-DSS.
- **SaaS / plataforma:** la IA no modifica control de acceso, permisos ni datos de tenants; aislamiento multi-tenant; revisar documentación de API generada; SOC 2 Type II.
