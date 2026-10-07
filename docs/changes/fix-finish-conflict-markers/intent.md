# Intent: Remove committed conflict markers from the finish step

Author: Etienne van Delden de la Haije. Status: accepted. Type: bugfix. Delivery: autonomous.

## Problem

Commit `745cc30` ("Add emojis to output") committed an unresolved stash-pop conflict in `template/finish.rb` (lines 43–49). The markers make the file a Ruby syntax error. Every `rails new myapp -m template.rb` run fails at the finish step, so nobody can generate a new app from the current template.

## Proposed outcome

Generating a new app runs to the end and prints the full "next steps" summary. The admin panel step reads like the other numbered steps and points at the admin dashboard.

## Affected users and systems

- The repo owner, who bootstraps new personal Rails apps with this template.
- `template/finish.rb`, which the template applies last.
- Apps that already exist are not affected: the finish step only prints console output during generation.

## Constraints

- No `UPGRADING.md` chapter: the change alters console output only, not generated files.
- The emoji label must match the other numbered steps (`1️⃣` to `5️⃣`).
- Approved permissions: none needed (no dependencies, system tools, destructive migrations or deploy files).

## In scope

- Resolve the conflict in `template/finish.rb`: keep the `6️⃣  Admin panel:` label and the `http://localhost:3000/admin` URL.
- A regression test: `template.rb` and every `template/*.rb` contain no conflict markers and pass a Ruby syntax check.

## Out of scope

- Any other wording or content in the finish summary.
- The pre-existing failure in `test/appkit_template_test.rb#test_deleted_template_files_are_gone`.

## Acceptance criteria

- Generating a new app does not stop at the finish step with a syntax error.
- The summary shows step 6 as "6️⃣  Admin panel:" followed by "http://localhost:3000/admin (admin only)".
- A template module that contains a conflict marker makes the test suite fail.
- A template module with a Ruby syntax error makes the test suite fail.

## Open questions

None.
