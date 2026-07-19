# Applying Template to Existing Rails Applications

This guide explains how to retroactively apply this template to an existing Rails application.

## Important Warning

**This process will modify your existing application.** Always:
1. Commit all current changes
2. Create a new branch: `git checkout -b add-template`
3. Review all changes carefully before merging
4. Test thoroughly in development before deploying

## Method 1: Manual Application (Recommended)

The safest approach is to manually apply template modules one at a time, reviewing each change.

### Step 1: Review Your Current Setup

Check what you already have:
```bash
# Do you have authentication?
grep -r "has_secure_password\|devise" app/models/

# Do you have Solid Queue?
grep "solid_queue" Gemfile

# What's your current CSS setup?
ls app/assets/stylesheets/
```

### Step 2: Apply Modules Selectively

Use Rails' `apply` method to run individual modules:

```bash
cd /path/to/your/existing/app

# Apply gems (review Gemfile changes after)
rails app:template LOCATION=/path/to/template/gems.rb

# Run bundle
bundle install

# Apply the appkit engine wiring (skip if you already have auth/theme set up)
rails app:template LOCATION=/path/to/template/models.rb
rails app:template LOCATION=/path/to/template/appkit.rb

# Apply other modules as needed
rails app:template LOCATION=/path/to/template/email.rb
rails app:template LOCATION=/path/to/template/css.rb
rails app:template LOCATION=/path/to/template/config.rb
```

### Step 3: Resolve Conflicts

The template assumes a fresh Rails app, so you may need to:

**If you already have a User model:**
```bash
# Don't apply template/models.rb
# Instead, manually add what you need:
# - Role enum: enum :role, { user: 0, admin: 1 }
# - Sessions association: has_many :sessions, dependent: :destroy
```

**If you already have authentication:**
```bash
# Skip template/appkit.rb, or review its diff and merge the include Appkit::*
# lines into your existing User/Session models and ApplicationController
```

**If you already have CSS:**
```bash
# Backup your existing CSS first
cp -r app/assets/stylesheets app/assets/stylesheets.backup

# Then apply template/css.rb or merge manually
```

### Step 4: Run Migrations

```bash
rails db:migrate
```

### Step 5: Test Thoroughly

```bash
# Run tests
rails test

# Start server and manually test
rails server

# Check for missing routes
rails routes | grep -i session
rails routes | grep -i admin
```

## Method 2: Automated Script (Use with Caution)

For a more automated approach, you can apply all non-conflicting modules at once.

Create `apply_template.rb` in your existing app:

```ruby
# apply_template.rb
# Apply template modules to existing app

TEMPLATE_PATH = ENV.fetch("TEMPLATE_PATH", "~/Developer/my-rails-template")

# Safe modules that usually don't conflict
safe_modules = %w[
  config
  deployment
]

# Modules that may conflict - review carefully
review_modules = %w[
  gems
  solid
  appkit
  authorization
  models
  email
  css
]

# Apply safe modules
safe_modules.each do |mod|
  say "Applying #{mod}...", :blue
  apply "#{TEMPLATE_PATH}/template/#{mod}.rb"
end

say "Safe modules applied!", :green
say "Review these modules manually before applying:", :yellow
review_modules.each { |m| say "  - #{m}", :white }
```

Run it:
```bash
TEMPLATE_PATH=/path/to/my-rails-template rails app:template LOCATION=apply_template.rb
```

## Module-by-Module Guide

### gems.rb
**What it does**: Adds gems to Gemfile
**Conflicts**: Will add duplicate gems if you already have them
**Resolution**: Review `Gemfile.lock` after bundle, remove duplicates manually

### solid.rb
**What it does**: Installs Solid Queue/Cache/Cable
**Conflicts**: If you already have these, skip this module
**Resolution**: Check `config/queue.yml`, `config/cache.yml` before applying

### models.rb
**What it does**: Creates User and Session models
**Conflicts**: Very high - likely conflicts with existing User model
**Resolution**:
- If no User model: Apply as-is
- If User model exists: Skip this, manually add `enum :role` and sessions

### appkit.rb
**What it does**: Wires the app onto the [appkit](https://github.com/eirvandelden/appkit) engine - mounts
session auth/PWA/theme routes, adds `Appkit::Authenticatable`/`Appkit::UserTheming`/`Appkit::SessionBehavior`
to the User/Session models, adds the initializer, JS controller registrations, and CSS imports
**Conflicts**: High - if you have existing auth (Devise, custom, etc.) or theme system
**Resolution**: Skip if you have auth, or review the diff and merge the `include Appkit::*` lines manually

### email.rb
**What it does**: Sets up mailer system, templates, test helpers
**Conflicts**: Medium - may conflict with existing mailers
**Resolution**: Review mailer config in `config/environments/` before applying

### css.rb
**What it does**: Creates MVP.css + SMACSS structure
**Conflicts**: High - overwrites CSS structure
**Resolution**: Backup existing CSS first, merge manually

### config.rb
**What it does**: Creates RuboCop, Lefthook, .env.template, agents.md symlink
**Conflicts**: Low - usually safe to apply
**Resolution**: Review generated configs, merge with existing if needed

### admin.rb
**What it does**: Creates admin panel for user management
**Conflicts**: Medium - if you have existing admin
**Resolution**: Skip if admin exists, or rename to avoid conflicts

### deployment.rb
**What it does**: Sets up Kamal, creates DEPLOYMENT.md
**Conflicts**: Low - unless you already use Kamal
**Resolution**: Review `config/deploy.yml` if it exists

## Common Scenarios

### Scenario 1: Existing App, No Authentication
```bash
rails app:template LOCATION=template/gems.rb
bundle install
rails app:template LOCATION=template/solid.rb
rails app:template LOCATION=template/current.rb
rails app:template LOCATION=template/authorization.rb
rails app:template LOCATION=template/models.rb
rails app:template LOCATION=template/appkit.rb
rails app:template LOCATION=template/admin.rb
rails app:template LOCATION=template/routes.rb
rails app:template LOCATION=template/config.rb
rails db:migrate
```

### Scenario 2: Existing App with Authentication
```bash
# Skip appkit/models/admin
# Just add supporting infrastructure
rails app:template LOCATION=template/gems.rb
bundle install
rails app:template LOCATION=template/solid.rb
rails app:template LOCATION=template/email.rb
rails app:template LOCATION=template/css.rb
rails app:template LOCATION=template/config.rb
rails app:template LOCATION=template/deployment.rb
```

### Scenario 3: Just Want CSS/Config
```bash
rails app:template LOCATION=template/css.rb
rails app:template LOCATION=template/config.rb
```

## Rollback Strategy

If something goes wrong:

```bash
# Rollback to before template application
git checkout main
git branch -D add-template

# Or rollback specific files
git checkout HEAD -- app/assets/stylesheets/
git checkout HEAD -- Gemfile
bundle install
```

## Post-Application Checklist

After applying the template:

- [ ] Review all generated files for conflicts
- [ ] Update `config/database.yml` if needed
- [ ] Update `config/routes.rb` - check for route conflicts
- [ ] Run `rails db:migrate`
- [ ] Run `rails test` - fix any broken tests
- [ ] Update existing tests to work with new structure
- [ ] Test authentication flow manually
- [ ] Test admin panel access controls
- [ ] Review email configuration
- [ ] Update seeds.rb with your data
- [ ] Review and merge CSS with existing styles
- [ ] Update `.env` with production credentials
- [ ] Test deployment configuration

## Getting Help

If you encounter issues:

1. **Check git diff**: See exactly what changed
   ```bash
   git diff main..add-template
   ```

2. **Review specific files**: Look at generated vs existing
   ```bash
   git diff main..add-template app/models/user.rb
   ```

3. **Rails console**: Test models and methods
   ```bash
   rails console
   > User.new
   > Current.user
   ```

4. **Check logs**: Look for errors
   ```bash
   tail -f log/development.log
   ```

## Best Practices

1. **One module at a time**: Apply and test each module individually
2. **Read the code**: Review what each module does before applying
3. **Commit frequently**: Commit after each successful module application
4. **Test between modules**: Ensure app still works after each module
5. **Keep backup**: Maintain a clean branch you can return to
6. **Document changes**: Note what you applied and what you skipped

## Alternative: Cherry-Pick Features

Instead of applying whole modules, you can copy specific code:

```bash
# Just want the appkit engine wiring?
cp template/appkit.rb /tmp/
# Review /tmp/appkit.rb
# Manually copy the parts you want into your app

# Just want the RuboCop config?
cp template/config.rb /tmp/
# Extract just the RuboCop section
```

This gives you maximum control and minimum conflicts.
