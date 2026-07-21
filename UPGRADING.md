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

## After every chapter

```bash
bin/rails test
git diff --check
git diff
```

Deploy only after reviewing the diff and confirming the relevant flow in development.
