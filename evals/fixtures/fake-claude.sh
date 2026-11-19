#!/usr/bin/env bash
# Stand-in for the `claude` CLI, to test evals/run-cases.sh mechanics without a model.
# Prints $FAKE_CLAUDE_OUT and does nothing else.
printf '%s\n' "${FAKE_CLAUDE_OUT:-ok}"
