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
