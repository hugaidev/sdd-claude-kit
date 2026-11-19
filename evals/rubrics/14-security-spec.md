---
artifact: 14-security-spec
pass_threshold: 0.8
---

# Rubric: Security Specification

- SEC-01 | 3 | A threat model names assets, actors, trust boundaries and the top threats.
- SEC-02 | 3 | Authentication method, session or token lifetime and credential policy are specified.
- SEC-03 | 3 | Authorization is a role-by-resource matrix and every API endpoint is covered by it.
- SEC-04 | 2 | Each OWASP Top 10 risk is addressed with a concrete mitigation and how it is verified.
- SEC-05 | 2 | Transport and browser protections (TLS, headers, CORS, cookies) are specified where applicable.
- SEC-06 | 3 | Secrets management and rotation are described, and no real secret appears in the spec.
- SEC-07 | 2 | Personal data handling matches the data governance spec.
- SEC-08 | 1 | Supply-chain controls (dependency review, lockfiles, scanning) are referenced.
