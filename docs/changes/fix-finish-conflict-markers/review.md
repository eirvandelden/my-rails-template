# Review: fix-finish-conflict-markers

## Round 1 — 2026-10-08T08:59Z — 9553a22

Criteria: no `REVIEW.md` or `REVIEW.local.md` at the repository root, so the default Bugs, Security and Compliance passes apply.

- [ ] Nit: The new tests depend on a UTF-8 locale. `syntax_error` pipes the source to `ruby -c` through stdin, and Ruby reads a stdin script in the locale encoding, while it reads a script path as UTF-8. Under `LANG=C LC_ALL=C`, `test_every_template_module_is_valid_ruby` reports 21 of the 28 valid templates as syntax errors, but `ruby -c <path>` (the check the intent names) and `rails new` accept them. The same locale makes `File.read` return US-ASCII strings: the marker test raises `ArgumentError: invalid byte sequence in US-ASCII` and `FinishRecorder#apply` raises `SyntaxError`. `test/appkit_template_test.rb` already has the `File.read` dependency, but the false syntax errors are new. Verified fixes: `File.read(path, encoding: "UTF-8")` and `ruby -Ku -c` both pass under `LANG=C`; `-Eutf-8` does not. — `test/template_syntax_test.rb:64` → fixed (Read template sources as UTF-8 in the new tests)

### Bugs

- The resolution in `template/finish.rb` keeps the `6️⃣  Admin panel:` label (same keycap bytes as `1️⃣` to `5️⃣`) and the `/admin` URL. `template/routes.rb` routes `namespace :admin { root "dashboard#index" }`, so the URL resolves to the admin dashboard.
- `FinishRecorder` stubs every generator method `finish.rb` calls. The marker regex matches only line starts, and the self-test covers its edge cases.

### Security

- Nothing found. `Open3.capture3` uses the array form with no shell, and `instance_eval` runs only the repository's own `template/finish.rb` inside the test.

### Compliance

- AC1 (generation does not stop at the finish step with a syntax error) → `test/finish_template_test.rb` `test_finish_step_runs_to_the_end_of_the_summary` and `test/template_syntax_test.rb` `test_every_template_module_is_valid_ruby`. The manual `rails new` evidence from plan step 6 is not on the branch; it belongs in the coordinator's account or the pull request body.
- AC2 (step 6 label followed by the `/admin` URL) → `test/finish_template_test.rb` `test_summary_shows_the_admin_panel_as_step_six`.
- AC3 (a conflict marker fails the suite) → `test/template_syntax_test.rb` `test_every_template_module_is_free_of_conflict_markers`, backed by `test_conflict_marker_detection_flags_every_marker_line`.
- AC4 (a syntax error fails the suite) → `test/template_syntax_test.rb` `test_every_template_module_is_valid_ruby`, backed by `test_syntax_check_rejects_invalid_ruby`.
- Every test named in the plan's `## Proof` exists, including `test_template_files_cover_the_orchestrator_and_every_module`.
- No existing test was weakened, skipped or deleted. The diff touches only the three files the plan lists, plus the change folder.
- Fault injection on a scratch copy: the pre-fix `finish.rb` makes both finish tests error with `SyntaxError` at line 43, and the guards name `template/finish.rb:43`, `:46` and `:49`. A marker inside `=begin`/`=end` in `template/home.rb` (still valid Ruby) fails the marker test as `template/home.rb:77`. An unclosed `def` in `template/seeds.rb` fails the syntax test as `template/seeds.rb`.
- Suite: all green except the pre-existing `AppkitTemplateTest#test_deleted_template_files_are_gone`, which is out of scope. RuboCop reports no offenses on the three changed files. A per-file `ruby -c` over `template.rb` and `template/*.rb` reports no failure.

Totals: 0 Important, 1 Nit.

## Round 2 — 2026-10-08T11:55Z — 9553a22 (codex)

`codex review --base origin/main`: no findings. The change removes the conflict markers and keeps the admin dashboard URL; both new test files pass.

Totals: 0 Important, 0 Nit.

## Round 3 — 2026-10-08T12:10Z — 2bfb4f4

Criteria: no `REVIEW.md` or `REVIEW.local.md` at the repository root, so the default Bugs, Security and Compliance passes apply. This round covers the full diff against `origin/main`, with focus on `2bfb4f4`, the fix for the round 1 nit. The working tree is clean.

- [ ] Nit: The syntax failure message now repeats the path and includes the absolute interpreter path. `ruby -c <path>` prefixes stderr with the interpreter path, so an offense reads `template/seeds.rb: /Users/…/rubies/ruby-4.0.7/bin/ruby: template/seeds.rb:47: syntax errors found (SyntaxError)`. The stdin version printed `-:47: …` after the path. The message still names the file and the line, so the guard works; only the text is noisy. A possible fix: return the stderr line without the `"#{RbConfig.ruby}: "` prefix, or drop the `"#{path}: "` prefix in `test_every_template_module_is_valid_ruby`. — `test/template_syntax_test.rb:65` → fixed (Trim the interpreter path from syntax guard messages)

### Bugs

- The round 1 nit is fixed. Both new test files pass under `LANG=C LC_ALL=C` (2 and 5 runs, no failures). `File.read(path, encoding: "UTF-8")` in both files and `ruby -c <path>` remove the locale dependency.
- `syntax_error_in_source` writes the sample to a `Tempfile` with a `.rb` suffix and flushes it before the subprocess reads it. `Tempfile.create` with a block deletes the file afterwards. The self-test still proves that invalid Ruby yields an error and valid Ruby yields `nil`.
- Fault injection on a scratch copy under `LANG=C`: the pre-fix `finish.rb` makes both finish tests error with `SyntaxError` at line 43, and the marker test names `template/finish.rb:43`, `:46` and `:49`. An unclosed `def` appended to `template/seeds.rb` fails the syntax test as `template/seeds.rb:47`. The guards still fail for the right reason.

### Security

- Nothing found. `Open3.capture3` keeps the array form with no shell. The path argument comes from a fixed glob or from `Tempfile`, never from user input.

### Compliance

- The helper shape differs from the plan: the plan specifies `syntax_error(source)` over stdin, the code now has `syntax_error(path)` plus `syntax_error_in_source(source)`. The change follows the round 1 finding and matches the intent's wording ("pass a Ruby syntax check" per file, as `ruby -c <path>`). The Proof list is unchanged and every named test exists.
- AC1 to AC4 keep the same test coverage as round 1.
- The diff still touches only `template/finish.rb`, the two new test files and the change folder. No existing test was weakened, skipped or deleted.
- Suite: all green except the pre-existing `AppkitTemplateTest#test_deleted_template_files_are_gone` (`template/theme_system.rb` still exists), which is out of scope. RuboCop reports no offenses on the three changed files. A per-file `ruby -c` over `template.rb` and `template/*.rb` reports no failure.
- The manual `rails new` evidence from plan step 6 is still not on the branch; it belongs in the coordinator's account or the pull request body.

Totals: 0 Important, 1 Nit.

## Round 4 — 2026-10-08T11:58Z — 2bfb4f4 (codex)

`codex review --base origin/main`: no findings. The finish step has no conflict markers and keeps the admin dashboard URL; both new test files pass and the diff has no whitespace errors.

Totals: 0 Important, 0 Nit.

## Round 5 — 2026-10-08T12:00Z — 02686b4

Criteria: no `REVIEW.md` or `REVIEW.local.md` at the repository root, so the default Bugs, Security and Compliance passes apply. This round covers the full diff against `origin/main`, with focus on `02686b4`, the fix for the round 3 nit. The working tree is clean.

- [ ] Nit: A parse warning hides the syntax error in the failure message. `syntax_error` returns the first stderr line, and `ruby -c` prints parse warnings before the error. A file with `h = {a: 1, a: 2}` on line 1 and an unclosed `def` on line 2 reports `<path>:1: warning: key :a is duplicated and overwritten on line 1`, not the `:2: syntax errors found` line. The guard still fails, because it checks the exit status; only the message points at the wrong line. No template emits a warning today. Verified fix: pass `-W0` (`Open3.capture3(RbConfig.ruby, "-W0", "-c", path)`); the first line is then the error. Present since round 1, not introduced by `02686b4`. — `test/template_syntax_test.rb:65`

### Bugs

- The round 3 nit is fixed. Fault injection on a scratch copy: an unclosed `def` appended to `template/seeds.rb` now reads `template/seeds.rb:48: syntax errors found (SyntaxError)`, and the pre-fix `finish.rb` reads `template/finish.rb:43: syntax errors found (SyntaxError)`. The path appears once and the interpreter path is gone. The marker test still names `template/finish.rb:43`, `:46` and `:49`.
- `delete_prefix("#{RbConfig.ruby}: ")` matches because `Open3.capture3` passes `RbConfig.ruby` as `argv[0]`, and Ruby prefixes the error with `argv[0]`. On a Ruby whose message has no such prefix, `delete_prefix` is a no-op, so the message stays correct.
- `test_syntax_check_rejects_invalid_ruby` now also asserts that the message excludes the interpreter path. That pins the round 3 fix.

### Security

- Nothing found. `Open3.capture3` keeps the array form with no shell; the path comes from a fixed glob or from `Tempfile`.

### Compliance

- AC1 to AC4 keep the same test coverage as round 1; every test named in the plan's `## Proof` exists.
- The diff still touches only `template/finish.rb`, the two new test files and the change folder. No existing test was weakened, skipped or deleted.
- Suite: all green except the pre-existing `AppkitTemplateTest#test_deleted_template_files_are_gone`, which is out of scope. `test/template_syntax_test.rb` passes under `LANG=C LC_ALL=C`. RuboCop reports no offenses on the three changed files. A per-file `ruby -c` over `template.rb` and `template/*.rb` reports no failure.
- The manual `rails new` evidence from plan step 6 is still not on the branch; it belongs in the coordinator's account or the pull request body.

Totals: 0 Important, 1 Nit.

## Round 6 — 2026-10-08T12:00Z — 02686b4 (codex)

`codex review --base origin/main`: no findings. The conflict markers are removed, the admin step points to the dashboard, and both new test files pass; the only suite failure is the pre-existing `AppkitTemplateTest#test_deleted_template_files_are_gone`.

Totals: 0 Important, 0 Nit.
