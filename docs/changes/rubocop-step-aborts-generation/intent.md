# Intent: New apps get their RuboCop rules from the shared standard

Author: Etienne van Delden de la Haije. Status: accepted. Type: bugfix. Delivery: autonomous.

## Problem

Generating a new app aborts in the finish step. `bundle exec rubocop -A` fails with `cannot load such file -- rubocop-yard`, so the "next steps" summary never prints. The template copies the dotfiles `.rubocop.yml` into the new app. That file gained the `rubocop-yard` plugin on 2026-07-14, but the template's gem list never followed. Any plugin the shared rules add breaks generation the same way. The copy also goes against the `new-repo-setup` standard: RuboCop rules come from the `rubocop-eirvandelden` gem and are never copied into a repository.

## Proposed outcome

A new app gets its RuboCop rules from the `rubocop-eirvandelden` gem, like every other personal repository. It holds no copy of the rules. Generation runs to the end, and the fresh app passes its own RuboCop rules with no offenses. Apps generated earlier have an upgrade path to the same setup.

## Affected users and systems

- The repo owner, who bootstraps new personal Rails apps with this template.
- Apps generated earlier that carry a copied `.rubocop.yml`. Copies made after 2026-07-14 name `rubocop-yard` without the gem.
- The template modules that write the generated `Gemfile` and `.rubocop.yml`, and any module whose generated source fails the stricter rules.
- `UPGRADING.md`.

## Constraints

- The gem comes from GitHub, as `new-repo-setup` prescribes: `gem "rubocop-eirvandelden", github: "eirvandelden/rubocop-eirvandelden", require: false` in the development group.
- A generated app uses Minitest and Capybara system tests, so its `.rubocop.yml` names the layers `config/default.yml`, `config/rails.yml` and `config/capybara.yml`. The gem does not depend on `rubocop-capybara`, so the app keeps that gem.
- On this machine, `bundle exec lefthook install` refuses the global `core.hooksPath` and stops generation earlier. That stays as is (decided 2026-10-08). A manual generation check needs a temporary global git config without `core.hooksPath`.
- A manual generation check needs network access for bundling.
- Approved permissions (rule 11): in the generated `Gemfile`, add `rubocop-eirvandelden` and remove `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging` and `rubocop-rspec`. Any other dependency change stops to ask.

## In scope

- New apps take their RuboCop rules from `rubocop-eirvandelden`. The template copies no RuboCop rules.
- The generated `Gemfile` adds `rubocop-eirvandelden` and drops the plugin gems it already brings: `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging` and `rubocop-rspec`. `rubocop-capybara` stays.
- Generated source that the stricter rules flag, and autocorrect cannot fix, is fixed in the template until a fresh app has no offenses.
- A new `UPGRADING.md` chapter takes an existing app from the copied `.rubocop.yml` to the gem.

## Out of scope

- The lefthook files and the `lefthook install` step.
- This repository's own `.rubocop.yml` symlink, which lints the template code itself.
- Changes to the `rubocop-eirvandelden` gem.
- Other gems in the generated `Gemfile`.
- The pre-existing failure `AppkitTemplateTest#test_deleted_template_files_are_gone`.

## Acceptance criteria

- Generating a new app runs to the end and prints "🎊 Happy coding!".
- A fresh app's `bundle exec rubocop` reports no offenses.
- A fresh app's `.rubocop.yml` inherits `config/default.yml`, `config/rails.yml` and `config/capybara.yml` from `rubocop-eirvandelden`, and holds no copied rules.
- A fresh app's `Gemfile` names `rubocop-eirvandelden` and `rubocop-capybara`, and not `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging` or `rubocop-rspec`.
- An app generated before this change, with a copied `.rubocop.yml` that names `rubocop-yard`, runs `bundle exec rubocop` without a load error after its owner follows the new `UPGRADING.md` chapter.

## Open questions

None.
