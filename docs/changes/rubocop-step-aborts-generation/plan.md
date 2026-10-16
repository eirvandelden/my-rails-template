# Plan: New apps get their RuboCop rules from the shared standard

From `intent.md` (2026-10-16). Status: accepted.

## Context

`template/config.rb` copies this repository's `.rubocop.yml` into every new app. That file is a symlink to `~/Developer/dotfiles/rubocop/.rubocop.yml`. Its `plugins:` list names gems the generated `Gemfile` lacks: `rubocop-yard` from 2026-07-14 (dotfiles `ec98f54c`) to 2026-10-13 (`4b684ce9`), and `rubocop-rbs_inline` since 2026-10-13. `template/finish.rb` then runs `bundle exec rubocop -A`, which fails with `cannot load such file -- <plugin>`, so generation stops before the summary.

The `rubocop-eirvandelden` gem (github.com/eirvandelden/rubocop-eirvandelden) holds the shared rules as stackable layers: `config/default.yml`, `config/rails.yml`, `config/rspec.yml`, `config/capybara.yml`. Its gemspec depends on `rubocop`, `rubocop-rails-omakase`, `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging`, `rubocop-performance`, `rubocop-rails`, `rubocop-rspec` and `rubocop-yard`. It does not depend on `rubocop-capybara`. It needs Ruby 3.4 or later.

## Design decisions

- `template/config.rb` writes `.rubocop.yml` from an inline heredoc instead of reading `TEMPLATE_ROOT/.rubocop.yml`. The heredoc holds only the `inherit_gem` block with the three layers `config/default.yml`, `config/rails.yml` and `config/capybara.yml`. `config/rspec.yml` is left out: generated apps use Minitest.
- The write uses `create_file ".rubocop.yml", <<~YAML, force: true`. `rails new` already generates a `.rubocop.yml` (the omakase one). Without `force: true`, Thor asks interactively whether to overwrite it. The template means to replace it, so it says so.
- The `rubocop-eirvandelden` line goes in the existing `gem_group :development` block of `template/gems.rb`, exactly as `intent.md` and `new-repo-setup` prescribe: `gem "rubocop-eirvandelden", github: "eirvandelden/rubocop-eirvandelden", require: false`. `rubocop-capybara` stays where it is, in `gem_group :development, :test`.
- The lefthook copy block in `template/config.rb` stays unchanged (out of scope).
- Offense fixes for generated source go into the `template/*.rb` module that writes that source. Each fix is its own commit. No `.rubocop_todo.yml`, no disable comments, no exclusions added to the generated `.rubocop.yml`.
- The `UPGRADING.md` chapter is headed with the SHA of the commit that changes `template/gems.rb` and `template/config.rb`, matching the existing `## <sha> — <title>` style. Recent pull requests merge with a merge commit, so branch SHAs survive on `main`.
- The chapter tells the owner to edit the `Gemfile` by hand rather than use `bundle add`/`bundle remove`. `bundle add` writes its own version constraint and group syntax; a hand edit gives exactly the line `new-repo-setup` prescribes.

## Integration points

- Rails' `rails new` app generator and Thor actions (`gem`, `gem_group`, `create_file`, `run`).
- The `rubocop-eirvandelden` gem's `config/*.yml` layers and its gem dependencies, fetched from GitHub during bundling.
- The `gem.coop` gem source that `template/gems.rb` sets for the generated app.
- Dotfiles history (`git -C ~/Developer/dotfiles show ec98f54c:rubocop/.rubocop.yml`) as the sample of an old copied config naming `rubocop-yard`, for the upgrade check.

## Files that change

- `test/gems_template_test.rb` — new. Applies `template/gems.rb` to a recorder that captures every `gem` call with its options and enclosing groups.
- `template/gems.rb` — add `rubocop-eirvandelden` to the `:development` group; remove `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging` and `rubocop-rspec`.
- `test/config_template_test.rb` — new. Applies `template/config.rb` to a recorder that captures `create_file` paths, contents and options.
- `template/config.rb` — replace the "Copy RuboCop configuration from template" block with the inline `create_file ... force: true`.
- `template/<module>.rb` — only the modules whose generated source a fresh app's `bundle exec rubocop` flags after `-A`. The set is unknown until the first generation run (Order of work step 6).
- `test/<module>_template_test.rb` — a string-level test per offense fix, where the fix is a template string a test can pin.
- `UPGRADING.md` — new chapter after `## 1ef40f9 — Expire stale sessions`, before `## After every chapter`.

## Order of work

1. Write `test/gems_template_test.rb` with the Gemfile acceptance test. Run `ruby test/gems_template_test.rb`. Watch it fail on the missing `rubocop-eirvandelden` and the present plugin gems.
2. Change `template/gems.rb`. Run the test until it is green.
3. Write `test/config_template_test.rb`. Run it. Watch it fail: today the content is the dotfiles copy, not the `inherit_gem` block, and `force` is not set.
4. Change `template/config.rb`. Run the test until it is green.
5. Run every test file, stopping at the first failure, with only the known pre-existing failure excluded: `set -e; for f in test/*_test.rb; do if [ "$f" = test/appkit_template_test.rb ]; then ruby "$f" --exclude test_deleted_template_files_are_gone; else ruby "$f"; fi; done`. Minitest 6's `--exclude` was checked to drop exactly that test (15 runs, 0 failures). Run `rubocop` on every changed `.rb` file. Commit steps 1–4 as one commit: the Gemfile and the `.rubocop.yml` change are one logical change.
6. Manual generation run, outside the repository:
   - `tmp=$(mktemp -d)`. Create `$tmp/gitconfig` with only `user.name` and `user.email` (`git config --file "$tmp/gitconfig" user.name "…"`, same for email, values from `git config user.name`/`user.email`). Without these the finish step's `git commit` fails.
   - `GIT_CONFIG_GLOBAL="$tmp/gitconfig" rails new "$tmp/rubocop_check" -m "$PWD/template.rb"`. This needs network access for bundling; run it outside the sandbox if the sandbox blocks the network.
   - Expect the output to end with "🎊 Happy coding!" and to show no "Overwrite .rubocop.yml?" prompt.
   - In `$tmp/rubocop_check`: `bundle exec rubocop` must print "no offenses detected". `cat .rubocop.yml` must show only the `inherit_gem` block. `grep -n rubocop Gemfile` must show `rubocop-eirvandelden` and `rubocop-capybara` and none of the four removed gems.
   - If offenses remain, list them. For each cop and file, find the `template/*.rb` module that writes that source. Write a failing string test first where the fix is pinnable, fix the template, commit. Delete `$tmp/rubocop_check` and regenerate. Repeat until the run is clean.
7. Write the `UPGRADING.md` chapter, headed `## <sha> — Take RuboCop rules from rubocop-eirvandelden`, `<sha>` being the short SHA of the step 5 commit. Content:
   - Applies to apps whose `.rubocop.yml` was copied from the template (any app generated before this change).
   - In the `Gemfile`, delete the `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging` and `rubocop-rspec` lines. Keep `rubocop-capybara`. Add `gem "rubocop-eirvandelden", github: "eirvandelden/rubocop-eirvandelden", require: false` inside `group :development do`. Run `bundle install`.
   - Replace `.rubocop.yml` with the three-layer `inherit_gem` block, verbatim from `template/config.rb`. Keep any rule the app added itself below that block.
   - Verify: `bundle exec rubocop` runs without a `cannot load such file` error. Then `bundle exec rubocop -A`; fix what remains by hand, or move pre-existing offenses into `.rubocop_todo.yml` as `new-repo-setup` allows.
   - Commit the chapter on its own.
8. Manual upgrade check, in the `$tmp/rubocop_check` app from step 6:
   - Simulate an old app: `git -C ~/Developer/dotfiles show ec98f54c:rubocop/.rubocop.yml > .rubocop.yml`. In the `Gemfile`, remove the `rubocop-eirvandelden` line and put back the four plugin gem lines in the `group :development, :test do` block. Install with `bi` (the playbook's install command). Run `bundle exec rubocop` and confirm `cannot load such file -- rubocop-yard`.
   - Follow the new chapter word for word. Run `bundle exec rubocop`. Confirm no load error.
   - Fix the chapter for any step that did not work as written, and amend the chapter commit.
9. Re-run every test file the step 5 way and `rubocop` on every changed `.rb` file. Re-read the full branch diff against `main`.
10. After any rebase onto `main`, check that the chapter heading SHA still names the commit that changes `template/config.rb`, and fix it if not.

## Risks

- Stricter rules flag generated source that `-A` cannot fix. `run "bundle exec rubocop -A"` then exits non-zero, and generation stops in the same place as today. Step 6 finds and fixes these until the run is clean. The amount of work is unknown before the first run.
- Autocorrect with `-A` includes unsafe corrections. A correction could change generated behaviour silently. Mitigation: after a clean step 6 run, run the generated app's own `bin/rails test` and note the result in the evidence. A failure caused by an autocorrection is fixed in the template, not in the app.
- The gem's default branch on GitHub changes after this plan. A new plugin in the gem is a gem dependency, so it no longer breaks generation. A new cop can still flag generated source; that is the price of sharing rules, accepted by the intent.
- The gem needs Ruby 3.4 or later. An app generated on an older Ruby fails to bundle. This machine runs Ruby 4.0.7, so the check passes here.
- On this machine, `bundle exec lefthook install` refuses the global `core.hooksPath` and stops generation earlier (out of scope). The `GIT_CONFIG_GLOBAL` override in step 6 sidesteps it for the check only.
- A rebase before delivery rewrites branch SHAs, and the `UPGRADING.md` heading would point at a commit that is not on `main`. Step 11 guards against that.
- Rejected: keeping the copy and adding the missing plugin gems. It fixes today's failure but the next plugin added in dotfiles breaks generation again, and it violates `new-repo-setup`.
- Rejected: `config/rspec.yml` in the generated `.rubocop.yml`. Generated apps use Minitest.
- Rejected: `bundle add`/`bundle remove` in the chapter. They write their own version constraint and group syntax, not the exact line `new-repo-setup` prescribes.

## Out of scope

- The lefthook files and the `bundle exec lefthook install` step in `template/config.rb`.
- This repository's own `.rubocop.yml` symlink.
- Changes to the `rubocop-eirvandelden` gem.
- Other gems in the generated `Gemfile`.
- `AppkitTemplateTest#test_deleted_template_files_are_gone` and `template/theme_system.rb`.
- `README.md` lines 26 and 163, which call the generated RuboCop setup "Omakase". `intent.md` does not name the README; the wording fix is a follow-up.
- `TEMPLATE_STRUCTURE.md`: its "RuboCop, Lefthook, .env, Procfile" description of `config.rb` stays accurate.

## Proof

- Generating a new app runs to the end and prints "🎊 Happy coding!" → check: Order of work step 6, `rails new` output ends with "🎊 Happy coding!" and no overwrite prompt. `test/finish_template_test.rb` `test_finish_step_runs_to_the_end_of_the_summary` keeps covering the summary text.
- A fresh app's `bundle exec rubocop` reports no offenses → check: step 6, `bundle exec rubocop` in the generated app prints "no offenses detected".
- A fresh app's `.rubocop.yml` inherits the three layers from `rubocop-eirvandelden` and holds no copied rules → `test/config_template_test.rb` `test_rubocop_config_inherits_the_three_layers_from_rubocop_eirvandelden`, plus check: step 6, `cat .rubocop.yml`.
- A fresh app's `Gemfile` names `rubocop-eirvandelden` and `rubocop-capybara`, and none of the four plugin gems → `test/gems_template_test.rb` `test_gemfile_takes_rubocop_rules_from_rubocop_eirvandelden`, plus check: step 6, `grep -n rubocop Gemfile`.
- An app with a copied `.rubocop.yml` naming `rubocop-yard` runs `bundle exec rubocop` without a load error after the new chapter → check: Order of work step 8.

Per changed file, the unit tests expected:
- `test/gems_template_test.rb`: `test_gemfile_takes_rubocop_rules_from_rubocop_eirvandelden` (the gem is present with `github: "eirvandelden/rubocop-eirvandelden"`, `require: false`, in group `[:development]`), `test_gemfile_keeps_rubocop_capybara`, `test_gemfile_drops_plugin_gems_rubocop_eirvandelden_brings` (none of `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging`, `rubocop-rspec`).
- `test/config_template_test.rb`: `test_rubocop_config_inherits_the_three_layers_from_rubocop_eirvandelden` (YAML-parsed content equals `{"inherit_gem" => {"rubocop-eirvandelden" => ["config/default.yml", "config/rails.yml", "config/capybara.yml"]}}`, so no other keys), `test_rubocop_config_overwrites_the_rails_generated_file` (`force: true`), `test_rubocop_config_does_not_read_the_template_copy` (the module source no longer references `TEMPLATE_ROOT, ".rubocop.yml"`).
- `test/<module>_template_test.rb`: one test per offense fix from step 6, named after the behaviour it pins.

Test setup: plain Minitest scripts, as in `test/finish_template_test.rb`. Each new test defines a recorder class that `instance_eval`s the module source. The `gems.rb` recorder stubs `gsub_file`, records `gem(name, **options)` with the current group stack, and implements `gem_group(*groups) { ... }` by pushing the groups and yielding. The `config.rb` recorder defines `TEMPLATE_ROOT` (the repository root), stubs `say`, `run` and `append_to_file`, and records `create_file(path, content = nil, **options)`. No network, no Rails, no bundling in the automated tests.

---
Domain skills applied: dependencies (gem from GitHub, `require: false`, approved removals only), rails-testing (Minitest, recorder-style tests matching the repo), new-repo-setup (`.rubocop.yml` layer form, `.rubocop_todo.yml` rule for upgraded apps).

## Critique

### Round 1 (codex exec -p terra)

- Step 5's test loop masks real regressions with `|| echo`, so it can pass after a new failure → fixed (step 5 now runs with `set -e` and excludes only `test_deleted_template_files_are_gone` through Minitest's `--exclude`, checked locally; step 9 reuses it)
- The README edit expands scope beyond the accepted intent → fixed (README change removed from Files that change and Order of work; listed under Out of scope as a follow-up)
