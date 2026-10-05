# Plan: Remove the cspell spell checker

Status: accepted.

## Files that change

Delete `cspell.json`. First confirm with `git grep -n -i cspell` that no template file (`template.rb`, `template/*.rb`) copies, generates or references it; if one does, stop and report instead of editing it.

## Proof

- `git grep -n -i -E '(^|[^a-z])cspell' -- ':!docs/changes'` prints nothing.
- `git ls-files | grep -i cspell` prints nothing.
- Repo lint stays as green as on main.
