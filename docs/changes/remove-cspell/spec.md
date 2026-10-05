# Spec: Remove the cspell spell checker

Status: accepted.

## Requirements

The repo has no cspell config; the template does not generate any cspell file for new apps; nothing else changes.

## Acceptance criteria

- `git grep -n -i -E '(^|[^a-z])cspell' -- ':!docs/changes'` prints nothing.
- `git ls-files | grep -i cspell` prints nothing.
- Repo lint stays as green as on main.
