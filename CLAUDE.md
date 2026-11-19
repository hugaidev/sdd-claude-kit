# CLAUDE.md — rules for working on this repo

- This repo is a kit of Markdown templates, Claude Code config and shell/Node validators. No app code.
- Keep everything stack-agnostic; examples go in `examples/` only.
- Every template in `templates/` needs frontmatter: `id`, `title`, `status`, `traces`.
- Primary language is English; Spanish mirrors live in `docs/es/`.
- Never commit secrets. Use Conventional Commits.
- Run `scripts/validate.sh` before finishing a change.
