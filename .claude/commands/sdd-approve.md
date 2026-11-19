---
description: Mark a reviewed spec as approved (human decision)
argument-hint: <spec id, e.g. 01-prd>
---

The user is explicitly approving the spec with id: $ARGUMENTS

1. Find the file in `specs/` whose frontmatter `id` matches. If none or several, stop and ask.
2. Refuse if it still contains `{{` placeholders or `[OPEN QUESTION` markers; list them.
3. Set `status: approved` in its frontmatter and bump nothing else.
4. Confirm which file changed and name the next command in the workflow.
