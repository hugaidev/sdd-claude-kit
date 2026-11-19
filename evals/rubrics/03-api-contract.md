---
artifact: 03-api-contract
pass_threshold: 0.8
---

# Rubric: API Contract

- API-01 | 3 | Every PRD workflow maps to at least one endpoint, and every endpoint traces to a requirement.
- API-02 | 3 | Every endpoint defines auth, request schema, success response and the error statuses it can return.
- API-03 | 3 | Error cases cover not found, validation failure and state violation, using one standard error envelope.
- API-04 | 2 | Pagination, filtering and sorting are standardised across all list endpoints.
- API-05 | 2 | Response shapes are consistent (same envelope, naming, date and ID formats everywhere).
- API-06 | 3 | Every request and response field exists in the data model, and every model field the clients need appears in a response.
- API-07 | 2 | A reader can answer "call with X returns Y; with bad data returns Z" for each endpoint from the spec alone.
- API-08 | 1 | A backward-compatibility and versioning policy is stated.
