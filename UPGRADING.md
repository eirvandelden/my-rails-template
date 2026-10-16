# UPGRADING

Apply only chapters newer than your app's template version. Work on a branch and commit before each chapter.

```bash
git checkout -b upgrade-template
```

## 5d4f16c — Use appkit

Applies to apps using this template's old local authentication, preferences, sessions, and theme code.

1. Review the migration before applying it. `template/appkit.rb` rewrites models, layouts, routes, JavaScript, and CSS.

   ```bash
   git show 5d4f16c -- template/appkit.rb template.rb template/gems.rb
   ```

2. Add appkit and run its installer.

   ```bash
   bundle add appkit --github=eirvandelden/appkit
   bin/rails generate appkit:install
   bin/rails db:migrate
   ```

3. Port the host-app wiring from `template/appkit.rb`: `Appkit::Authenticatable` and `Appkit::UserTheming` on `User`, `Appkit::SessionBehavior` on `Session`, the engine mount, initializer, controller registrations, and CSS imports. Remove the replaced local auth/theme code only after equivalent behavior works.

Verify:

```bash
bin/rails routes | rg 'first_run|session|preferences|service-worker'
bin/rails test
```

## 71d332e — Restore locale, timezone, and login history

Applies to apps upgraded to appkit by 5d4f16c. Add the `set_locale` and `set_time_zone` callbacks from `template/appkit.rb` to `ApplicationController`, plus `after_create -> { user.touch(:last_login_at) }` to `Session`.

Verify: sign in with a user whose locale and timezone differ from the defaults. UI and time formatting must use those preferences; `last_login_at` must change.

```bash
bin/rails test
```

## 1ef40f9 — Expire stale sessions

Applies to apps upgraded to appkit. Add this under `production:` in `config/recurring.yml`:

```yaml
appkit_session_expiry:
  class: Appkit::SessionExpiryJob
  schedule: every day at midnight
```

Verify:

```bash
bin/rails runner 'puts YAML.load_file("config/recurring.yml").dig("production", "appkit_session_expiry", "class")'
```

Expected output: `Appkit::SessionExpiryJob`.

## 31e6664 — Take RuboCop rules from rubocop-eirvandelden

Applies to apps whose `.rubocop.yml` was copied from the template, which is every app generated before this change. Copies made after 2026-07-14 name `rubocop-yard` without the gem and fail with `cannot load such file -- rubocop-yard`.

In the `Gemfile`, delete these lines:

```ruby
gem "rubocop-minitest", require: false
gem "rubocop-obsession", require: false
gem "rubocop-packaging", require: false
gem "rubocop-rspec", require: false
```

Keep `gem "rubocop-capybara", require: false`. Add this line inside `group :development do`:

```ruby
gem "rubocop-eirvandelden", github: "eirvandelden/rubocop-eirvandelden", require: false
```

Then run `bi`.

Replace `.rubocop.yml` with the block below. Keep any rule the app added itself under that block.

```yaml
inherit_gem:
  rubocop-eirvandelden:
    - config/default.yml
    - config/rails.yml
    - config/capybara.yml
```

Verify:

```bash
bundle exec rubocop
```

Expected: no `cannot load such file` error. Then run `bundle exec rubocop -A` and fix what remains by hand. Pre-existing offenses may go into `.rubocop_todo.yml`.

## After every chapter

```bash
bin/rails test
git diff --check
git diff
```

Deploy only after reviewing the diff and confirming the relevant flow in development.
