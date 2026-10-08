# Plan: Remove committed conflict markers from the finish step

From `intent.md` (2026-10-08). Status: accepted.

## Context

Commit `745cc30` ("Add emojis to output") committed an unresolved stash-pop conflict into `template/finish.rb`, lines 43–49. Shown with line numbers, so this file itself holds no marker at a line start:

```text
43 | <<<<<<< Updated upstream
44 | say "6. Admin panel:", :cyan
45 | say "   http://localhost:3000/admin (admin only)", :white
46 | =======
47 | say "6️⃣  Admin panel:", :cyan
48 | say "   http://localhost:3000/admin/users (admin only)", :white
49 | >>>>>>> Stashed changes
```

`ruby -c template/finish.rb` fails, so every `rails new myapp -m template.rb` run stops at the last module. `template.rb` and the other 26 `template/*.rb` files each pass `ruby -c` today. Commit `bbd6168` changed the URL from `/admin/users` to `/admin` on purpose: `template/routes.rb` routes `namespace :admin { root "dashboard#index" }`, so `/admin` is the admin dashboard. The resolution keeps the emoji label from one side and the URL from the other.

The repo has no Gemfile, Rakefile or CI. Tests are plain Minitest scripts run from the repo root with `ruby test/<name>_test.rb`, and they read template files by relative path. The owner's toolchain is Ruby 4.0.7 via `rv`, with global `rubocop` and `rails` 8.1.4. The repo pins no Ruby version.

## Design decisions

- **Two new test files, not one.** `test/finish_template_test.rb` proves the finish summary content and that the step runs to its end (acceptance criteria 1, 2). `test/template_syntax_test.rb` guards every template file against conflict markers and syntax errors (acceptance criteria 1, 3, 4). The split matches the existing one-file-per-concern layout in `test/`.
- **The finish test runs `finish.rb` in a recorder, not a string match.** A small `FinishRecorder` class in the test file defines the four Thor/Rails generator methods `finish.rb` calls: `say(message = "", _color = nil)` records the message; `rails_command(*)`, `run(*)` and `git(*)` are no-ops. The anonymous splat matters: `finish.rb` calls `git :init`, `git add: "."` and `git commit: "..."`. `FinishRecorder#apply(path)` evaluates the file with `instance_eval(File.read(path), path)`, the way Thor's own `apply` does. This proves the step runs to its last line and prints step 6 in order, which a substring match on the source cannot. The methods are explicit; no `method_missing`.
- **Exact expected lines.** The summary must contain `6️⃣  Admin panel:` (keycap emoji, two spaces, as steps 1–5) immediately followed by `   http://localhost:3000/admin (admin only)` (three leading spaces, as the other step bodies).
- **Syntax check through the running interpreter's `ruby -c`, one subprocess per file.** The helper `syntax_error(source)` runs `Open3.capture3(RbConfig.ruby, "-c", stdin_data: source)` and returns `nil` on success, else the first line of stderr. This is the check the intent names, it works on every Ruby the template supports (Rails 8.1 allows Ruby 3.2), and `open3` and `rbconfig` are standard library, so no dependency is added. Each file needs its own call: `ruby -c a.rb b.rb` checks only `a.rb` and reports `Syntax OK` even when `b.rb` is broken (verified during planning). 28 calls take about 2.3 seconds.
- **Conflict marker pattern, a deliberate superset of the lefthook hook.** The shared lefthook `no-merge-conflicts` hook matches `^(<{7} |>{7} |={7}$)`. The test matches `/\A(?:<{7}|\|{7}|={7}|>{7})(?: |\z)/` against each chomped line: exactly seven `<`, `|`, `=` or `>` at the start of a line, followed by a space or the end of the line. Differences from the hook, all intended: it also catches the diff3 base marker (`|||||||`), a bare `<<<<<<<` or `>>>>>>>` with no label, and `=======` followed by a space. Only line starts match, so Ruby code such as `x <<<<<<< y` cannot match. Apart from the three marker lines in `finish.rb` (43, 46, 49), no template line matches today.
- **The guard covers `template.rb` plus `Dir["template/*.rb"].sort`**, not only the modules `template.rb` applies. An unapplied file such as `template/theme_system.rb` gets checked too. It is valid Ruby today, so this costs nothing and needs no list kept in sync.
- **Detector self-tests on crafted strings.** After the fix, the real-file tests pass, so nothing would show that a marker or a syntax error still fails the suite. Two tests feed the private helpers a string with markers and a string with invalid Ruby. A third test asserts the file list holds `template.rb` and `template/finish.rb`, so an empty glob cannot make the guard pass by checking nothing.
- **No source line in the new test files starts with a marker.** The global pre-commit hook (`no-merge-conflicts`, active in this repo through `core.hooksPath`) refuses any staged file with a line that starts with a marker; it refused the first commit of this plan for that reason. Build the marker sample as an array of quoted strings joined with `"\n"` — for example `["<<<<<<< ours", "|||||||", "=======", "======= ", ">>>>>>> theirs", "x <<<<<<< y", "========", "<<<<<<<<"].join("\n")`, laid out one element per indented line. Each source line then starts with whitespace and a quote. A heredoc is not suitable: its content lines start with the marker, and the `"======= "` case needs trailing whitespace that `Layout/TrailingWhitespace` flags. Never commit with `--no-verify`.
- **Flagged conflict, resolved by the intent:** the `rails-testing` skill says "no meta-tests that assert code standards or repo plumbing — hooks and CI guard those". The marker and syntax guard is such a test. `intent.md` puts it in scope explicitly (acceptance criteria 3 and 4), and the premise of the skill rule does not hold here: the repo has no CI (no `.github/`), and the lefthook hooks did not stop `745cc30`. The plan follows the intent.
- **Test order inside each file:** failure and edge cases first, then the happy path, as the `rails-testing` skill asks. No comment headers; the two concerns live in two files, so no nested classes are needed.

## Integration points

- `template.rb` applies `template/finish.rb` last, inside `after_bundle`. Nothing else reads `finish.rb`.
- The finish step only prints to the console during generation, so no generated file changes. No `UPGRADING.md` chapter is needed (intent constraint).
- The shared `lefthook.yml` symlink already runs `no-merge-conflicts` and `ruby-syntax` on staged files at pre-commit. Those hooks did not stop `745cc30`. The new tests are a second line of defence that runs with the suite, independent of hook installation.

## Files that change

- `test/finish_template_test.rb` — new. `FinishRecorder` (about 15 lines) and `FinishTemplateTest` with two tests (see Proof).
- `test/template_syntax_test.rb` — new. `TemplateSyntaxTest` with five tests (see Proof) and private helpers `template_files`, `conflict_marker_lines(source)` (returns 1-based line numbers) and `syntax_error(source)` (see Design decisions). Failure messages name each offending `path:line`, or `path` with the first stderr line of `ruby -c`.
- `template/finish.rb` — replace lines 43–49 with exactly two lines: `say "6️⃣  Admin panel:", :cyan` and `say "   http://localhost:3000/admin (admin only)", :white`. Nothing else in the file changes.

## Order of work

1. Write `test/finish_template_test.rb` with both tests. Run `ruby test/finish_template_test.rb`. Watch both tests error with a `SyntaxError` raised from `template/finish.rb`. Any other error (for example a `NoMethodError` or `ArgumentError` from the recorder) is the wrong reason: fix the test first.
2. Write `test/template_syntax_test.rb` with all five tests. Run `ruby test/template_syntax_test.rb`. Watch `test_every_template_module_is_free_of_conflict_markers` fail naming `template/finish.rb:43`, `:46` and `:49`, and `test_every_template_module_is_valid_ruby` fail naming `template/finish.rb` and no other file. The three self-tests pass.
3. Resolve the conflict in `template/finish.rb` as described above. Run both new test files; all seven tests pass.
4. Run the full suite: `for t in test/*_test.rb; do ruby "$t"; done`. Expect exactly one failure, the pre-existing `AppkitTemplateTest#test_deleted_template_files_are_gone`; anything else is a regression from this change.
5. Lint: `rubocop test/finish_template_test.rb test/template_syntax_test.rb template/finish.rb` reports no offenses (the resolved `finish.rb` lints clean; checked on a copy during planning). Syntax-check each file on its own: `for f in template.rb template/*.rb; do ruby -c "$f" >/dev/null || echo "FAIL $f"; done` prints nothing. Fix offenses in the code, never with disable comments or config edits.
6. Verify as a human would: in a scratch directory outside the repo, run `rails new <scratch>/finishcheck -m <worktree>/template.rb` with the global Rails 8.1.4. Record the tail of the output: it must reach `=== 🚀 Next Steps ===`, show `6️⃣  Admin panel:` then `   http://localhost:3000/admin (admin only)`, and end with `🎊 Happy coding!`. This bundles gems from rubygems.org and GitHub, so it needs network access. Do not install, upgrade or switch Ruby, Rails or any system tool for it. If generation fails before the finish step for a reason this change did not cause, record the failure as evidence and report it to the coordinator; do not fix it here. Delete the scratch app afterwards.
7. Re-read the full diff. Every hunk belongs to one of the three files above. Suggested commits, one logical change each: the two test files; the `finish.rb` fix.

## Risks

- **False positives:** a future heredoc in a template that generates a line of exactly seven `=` (a Markdown underline, for example) would fail the marker test. The lefthook hook would already refuse that line at commit time. Accepted.
- **Recorder drift:** if `finish.rb` later calls another generator method, the finish test raises `NoMethodError`. That is a loud, intended failure: add the method to the recorder.
- **Suite time:** the syntax test starts 28 Ruby processes, about 2.3 seconds. Accepted for a suite that runs by hand.
- **Pre-existing failure:** `test/appkit_template_test.rb#test_deleted_template_files_are_gone` keeps failing. It is out of scope (intent) and must not be "fixed" by deleting `template/theme_system.rb`.
- **Step 6 depends on the network and on other modules.** A failure in another module or in `bundle install` is not this change's bug. It is reported, not fixed.
- Rejected: `Prism.parse` in-process — faster, but it needs Ruby 3.3 or later while the repo pins no Ruby version and Rails 8.1 allows 3.2. Rejected: a substring match on `finish.rb` source — it cannot prove the step runs to the end. Rejected: a full `rails new` as an automated test — minutes long and network-bound; it stays a manual verification step. Rejected: relying on the lefthook hooks alone — they demonstrably did not stop `745cc30`.

## Out of scope

- Any other wording or content in the finish summary, including the "Features Included" list.
- The pre-existing `test_deleted_template_files_are_gone` failure and `template/theme_system.rb`.
- Listing the two new test commands in the `## Commands` block of `AGENTS.md` (`CLAUDE.md` is a symlink to it). The intent does not ask for it; it is a candidate follow-up change.
- Lefthook configuration and hook installation in this repo.
- `UPGRADING.md`, `TEMPLATE_STRUCTURE.md`, `README.md`.

## Proof

- Generating a new app does not stop at the finish step with a syntax error → `test/finish_template_test.rb` `test_finish_step_runs_to_the_end_of_the_summary`, and `test/template_syntax_test.rb` `test_every_template_module_is_valid_ruby`; manual evidence from Order of work step 6.
- The summary shows step 6 as "6️⃣  Admin panel:" followed by "http://localhost:3000/admin (admin only)" → `test/finish_template_test.rb` `test_summary_shows_the_admin_panel_as_step_six`.
- A template module that contains a conflict marker makes the test suite fail → `test/template_syntax_test.rb` `test_every_template_module_is_free_of_conflict_markers`, backed by `test_conflict_marker_detection_flags_every_marker_line`.
- A template module with a Ruby syntax error makes the test suite fail → `test/template_syntax_test.rb` `test_every_template_module_is_valid_ruby`, backed by `test_syntax_check_rejects_invalid_ruby`.

Per changed file, the unit tests expected, named as behaviour:

- `template/finish.rb` (through `test/finish_template_test.rb`): `test_finish_step_runs_to_the_end_of_the_summary` (the last non-empty recorded line is `🎊 Happy coding!`), `test_summary_shows_the_admin_panel_as_step_six` (`6️⃣  Admin panel:` is recorded and the next recorded line is `   http://localhost:3000/admin (admin only)`).
- `test/template_syntax_test.rb`: `test_conflict_marker_detection_flags_every_marker_line` (a sample with `<<<<<<< ours`, a bare `|||||||`, a bare `=======`, `======= ` with a trailing space and `>>>>>>> theirs` yields those five line numbers; `x <<<<<<< y`, `========` (eight) and `<<<<<<<<` (eight) yield none), `test_syntax_check_rejects_invalid_ruby` (a sample such as `say "a" <<<` yields an error; `say "a", :cyan` yields `nil`), `test_template_files_cover_the_orchestrator_and_every_module` (the list includes `template.rb` and `template/finish.rb` and holds more than one module).

Test setup: no fixtures. The real-file tests read files relative to the repo root, as the existing tests do. The marker self-test uses an array of quoted strings joined with `"\n"` (see Design decisions); the syntax self-test uses short inline strings. `FinishRecorder` fakes the generator boundary: `say` records; `rails_command`, `run` and `git` are no-ops, so no migration, RuboCop run or git command executes.

---
Domain skills applied: rails-testing (one conflict flagged under Design decisions).

## Critique

### Round 1 (codex exec -p terra)

- The work order started with the syntax guard, not with the first acceptance criterion's test (the recorder test) → fixed (Order of work step 1 now writes and runs `test/finish_template_test.rb`; the syntax guard moved to step 2)
- `Prism` narrows the suite to Ruby 3.3 or later while Rails 8.1 allows 3.2 and the repo pins no Ruby version; use the running interpreter's `ruby -c` per file instead → fixed (the syntax helper now shells out to the running interpreter's `ruby -c`)
  - The helper is `syntax_error(source)`, built on `Open3.capture3` with `RbConfig.ruby` and `stdin_data`. Prism moved to Rejected. The Ruby-version risk was replaced by a suite-time risk.
- `FinishRecorder` method signatures were unspecified, and a no-argument `git` raises `ArgumentError` on `git add: "."` → fixed (Design decisions now give every recorder signature)
  - `say` takes a message and an optional colour; `rails_command`, `run` and `git` take an anonymous splat. Step 1 names `ArgumentError` as a wrong-reason failure. A probe against a resolved copy of `finish.rb` ran clean.
- Verification commands were unreliable: `ruby -c a.rb b.rb` checks only the first file, the subprocess count was 28 not 27, and no full-suite command was given → fixed (step 5 uses a per-file `ruby -c` loop, step 4 gives the full-suite loop, the count is 28 with the measured 2.3 seconds, and the single-file limitation is recorded under Design decisions)
- The marker pattern was called the lefthook pattern plus diff3, but it differs in more ways, and "no template file contains such a line" ignored `finish.rb` → fixed (Design decisions now give the exact regex, list every difference from the hook as intended, and say only `finish.rb` lines 43, 46 and 49 match today; the self-test lists the boundary cases)
- Updating `AGENTS.md` is outside the accepted scope, and the claim that an unlisted test does not get run was false → fixed (the `AGENTS.md` change was removed from Files that change and Order of work, and moved to Out of scope as a candidate follow-up)

### Round 2 (codex exec -p terra)

No findings.
