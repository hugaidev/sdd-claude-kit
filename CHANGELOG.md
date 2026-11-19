# Changelog

All notable changes follow [Keep a Changelog](https://keepachangelog.com/) and [SemVer](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-11-19
First public release.

### Added
- 25 stack-agnostic document templates (product, engineering, security, operations, knowledge, AI config).
- Documentation in English and Spanish: methodology, artifact catalog, Claude Code setup, AI Use Protocol, guardrails and evals.
- 10 subagents, 13 `/sdd-*` slash commands and 3 skills for Claude Code.
- 6 guardrail hooks (spec-before-code, secrets, destructive commands, spec format, traceability, completeness gate) and a `settings.json` permission set.
- Evals: 9 deterministic checks, 10 LLM-judge rubrics and 6 behavioral cases, with self-tests.
- Installers for Bash and PowerShell.
- Worked example `examples/notes-api`: approved specs plus code and tests implemented with `/sdd-implement`.
- CI running validation, hook tests, eval tests and the example's spec checks.

### Changed
- Relicensed from CC0 (original guides) to MIT.
