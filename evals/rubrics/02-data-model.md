---
artifact: 02-data-model
pass_threshold: 0.8
---

# Rubric: Data Model Specification

- DM-01 | 3 | Every persistent noun in the PRD appears as an entity, or is explicitly rejected with a reason.
- DM-02 | 3 | Every entity has a complete field table: type, required, constraints.
- DM-03 | 3 | Business rules are written explicitly (not implied), have IDs, and trace to requirements.
- DM-04 | 2 | The relationship diagram is valid and matches the entity tables (same names, cardinalities).
- DM-05 | 2 | Lifecycle states and transitions are specified (states, guards, who may trigger) wherever an entity has a lifecycle.
- DM-06 | 2 | No circular dependencies or ambiguous ownership between entities.
- DM-07 | 2 | Personal or sensitive fields are flagged for data governance.
- DM-08 | 1 | The spec is technology-neutral (no SQL dialect or ORM syntax).
- DM-09 | 2 | Every field the workflows and API need exists in the model.
