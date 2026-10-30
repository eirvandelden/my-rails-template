# Intent: New apps get their RuboCop rules from the shared standard

Author: Etienne van Delden de la Haije. Status: accepted. Type: bugfix. Delivery: autonomous. Codex review: no.

Amended 2026-10-17: the scope now also covers the git hooks of a fresh app and its failing mailer tests. Amended 2026-10-30: the fresh app gets its own ESLint and Stylelint setup, so the global `eslint` and `stylelint` hooks pass. The first version was accepted on 2026-10-13.

## Problem

Generating a new app aborts in the finish step. `bundle exec rubocop -A` fails with `cannot load such file -- rubocop-yard`, so the "next steps" summary never prints. The template copies the dotfiles `.rubocop.yml` into the new app. That file gained the `rubocop-yard` plugin on 2026-07-14 and `rubocop-rbs_inline` on 2026-10-13, but the template's gem list never followed. Any plugin the shared rules add breaks generation the same way. The copy also goes against the `new-repo-setup` standard: RuboCop rules come from the `rubocop-eirvandelden` gem and are never copied into a repository.

Past that step, generation still cannot finish. The template copies the dotfiles `lefthook.yml` and runs `bundle exec lefthook install`. On a machine with a global `core.hooksPath`, `lefthook install` refuses and stops generation. Where it installs, the pre-commit hooks fail the template's initial `git commit`: `yamllint` rejects the generated `.github/dependabot.yml`, `no-hardwrap` rejects the generated `README.md` and `DEPLOYMENT.md`, and the `eslint` and `stylelint` hooks fail on the staged `.js` and `.css` files. Those hooks run `npx --no eslint` and `npx --no stylelint`. In an app without them, ESLint exits 2 because no `eslint.config.js` exists, and npx exits 1 because the `stylelint` package is missing (checked 2026-10-30). `new-repo-setup` says a new repository needs no lefthook files and never runs `lefthook install`.

A fresh app also starts with a red test suite: `bin/rails test` gives 2 errors, in `UserMailerTest#test_welcome` and `#test_password_reset`, which call the mailer without the arguments it takes.

## Proposed outcome

A new app gets its RuboCop rules from the `rubocop-eirvandelden` gem and its git hooks from the global hooks, like every other personal repository. It holds no copy of either. Generation runs to the end on this machine and makes its initial commit through the global hooks. The fresh app passes its own RuboCop rules with no offenses, and its test suite is green. Apps generated earlier have an upgrade path to the same RuboCop setup.

## Affected users and systems

- The repo owner, who bootstraps new personal Rails apps with this template.
- Apps generated earlier that carry a copied `.rubocop.yml`.
- The template modules that write the generated `Gemfile`, `.rubocop.yml`, lefthook setup, `README.md`, `DEPLOYMENT.md`, `.github/dependabot.yml` and mailer tests, and any module whose generated source fails the stricter rules.
- `UPGRADING.md`.
- New template output: `package.json`, `eslint.config.js`, a Stylelint config, and the `npm install` step.
- Generated JS and CSS that the recommended rule sets flag.

## Constraints

- The gem comes from GitHub, as `new-repo-setup` prescribes: `gem "rubocop-eirvandelden", github: "eirvandelden/rubocop-eirvandelden", require: false` in the development group.
- A generated app uses Minitest and Capybara system tests, so its `.rubocop.yml` names the layers `config/default.yml`, `config/rails.yml` and `config/capybara.yml`. The gem does not depend on `rubocop-capybara`, so the app keeps that gem.
- The initial commit runs through the global hooks and never skips them (no `--no-verify`, no `LEFTHOOK=0`).
- The global `eslint` and `stylelint` hooks stay as they are. The fresh app carries what they need: a `package.json` with the dev dependencies, an `eslint.config.js` and a Stylelint config (decided 2026-10-30).
- The configs use the recommended rule sets: `@eslint/js` recommended for ESLint and `stylelint-config-standard` for Stylelint. `eslint.config.js` declares the browser globals with `globals.browser`, like the other personal apps (decided 2026-10-30). Generated JS and CSS that they flag is fixed in the template, never silenced by a rule change or a disable comment. Third-party code the app does not own, such as `vendor/`, is not linted.
- Generation installs the npm packages with `npm install`, so it needs Node and npm on the machine. The template does not install them.
- If the initial commit still fails a hook after these changes, the coordinator stops and asks Etienne.
- `rubocop-eirvandelden` requires Ruby 3.4 or later. The template generates on Ruby 4 only and declares no Ruby minimum (decided 2026-10-16).
- A manual generation check needs network access for bundling.
- Approved permissions (rule 11): in the generated `Gemfile`, add `rubocop-eirvandelden` and remove `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging` and `rubocop-rspec`. The `lefthook` gem stays. In the generated `package.json`, add the npm dev dependencies `eslint`, `@eslint/js`, `globals`, `stylelint` and `stylelint-config-standard` (approved 2026-10-30). Any other dependency change stops to ask.

## In scope

- New apps take their RuboCop rules from `rubocop-eirvandelden`. The template copies no RuboCop rules.
- The generated `Gemfile` adds `rubocop-eirvandelden` and drops the plugin gems it already brings: `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging` and `rubocop-rspec`. `rubocop-capybara` stays.
- Generated source that the stricter rules flag, and autocorrect cannot fix, is fixed in the template until a fresh app has no offenses.
- New apps get no `lefthook.yml`, and the template runs no `lefthook install`.
- New apps get a `package.json` with the five npm dev dependencies, an `eslint.config.js`, a Stylelint config, and `node_modules` in `.gitignore`. Generation runs `npm install` before the initial commit.
- Generated files that fail the global hooks on the initial commit are fixed in the template: `.github/dependabot.yml`, `README.md`, `DEPLOYMENT.md` and any other file the hooks reject.
- The generated mailer tests call the mailer the way it is defined, so a fresh app's test suite is green.
- New apps get no `password_reset` mail: no method, views, preview or generator argument. It links to an `edit_password_reset_url` route that neither the template nor appkit defines, so it can never render (decided 2026-10-30).
- A new `UPGRADING.md` chapter takes an existing app from the copied `.rubocop.yml` to the gem. It covers copies that name `rubocop-yard` or `rubocop-rbs_inline`.

## Out of scope

- Changes to the global hooks in the dotfiles `lefthook.yml`.
- Installing Node or npm.
- The `lefthook` gem in the generated `Gemfile`.
- Removing lefthook files from apps generated earlier.
- Ruby versions below 3.4.
- This repository's own `.rubocop.yml` and `lefthook.yml` symlinks.
- Changes to the `rubocop-eirvandelden` gem.
- Other gems in the generated `Gemfile`.
- The pre-existing failure `AppkitTemplateTest#test_deleted_template_files_are_gone`.

## Acceptance criteria

- On this machine, with its global `core.hooksPath`, generating a new app makes the initial commit through the global hooks and prints "🎊 Happy coding!".
- A fresh app has no `lefthook.yml`.
- In a fresh app, `npx --no eslint .` and `npx --no stylelint "**/*.css"` report no problems.
- A fresh app's `bundle exec rubocop` reports no offenses.
- A fresh app's `bin/rails test` passes with no failures or errors.
- A fresh app's `.rubocop.yml` inherits `config/default.yml`, `config/rails.yml` and `config/capybara.yml` from `rubocop-eirvandelden`, and holds no copied rules.
- A fresh app's `Gemfile` names `rubocop-eirvandelden` and `rubocop-capybara`, and not `rubocop-minitest`, `rubocop-obsession`, `rubocop-packaging` or `rubocop-rspec`.
- An app generated before this change, with a copied `.rubocop.yml` that names `rubocop-yard` or `rubocop-rbs_inline`, runs `bundle exec rubocop` without a load error after its owner follows the new `UPGRADING.md` chapter.

## Flagged concerns

- An importmap app now carries a Node toolchain for linting only. Side chosen: lint JS and CSS in every app, rather than make the global hooks skip apps without configs (decided 2026-10-30).

## Open questions

None.
