# Rails Application Template

A comprehensive Rails 8.1+ application template with authentication, authorization, admin panel, background jobs, and deployment configuration.

## Features

### Authentication, PWA & Authorization

- **[appkit](https://github.com/eirvandelden/appkit)** - Shared Rails engine for session auth, first-run bootstrap, session
  transfer/QR handoff, PWA installability with web push, and theme/preferences - see `template/appkit.rb`
- **Role-based Authorization** - User and Admin roles with access control (stays app-side, not engine functionality)
- **Admin Panel** - User management interface for administrators

### CSS Framework

- **[MVPA.css](https://github.com/eirvandelden/MVPA.css)** - Classless CSS framework with SMACSS architecture and theme switching

### Infrastructure

- **Email System** - Transactional emails with Letter Opener (development)
- **Background Jobs** - Solid Queue for async processing
- **Mission Control** - Job monitoring dashboard

### Code Quality

- **Code Quality** - RuboCop (Omakase), Brakeman, Bundler Audit
- **Git Hooks** - Lefthook for automated checks
- **Deployment Ready** - Kamal configuration for self-hosted deployment

## Quick Start

### For New Applications

Create a new Rails application using this template:

```bash
# With a local copy
rails new myapp -m /path/to/my-rails-template/template.rb

# Or from GitHub (once published)
rails new myapp -m https://raw.githubusercontent.com/YOUR_USERNAME/my-rails-template/main/template.rb
```

**Note**: The template takes 5-10 minutes to complete as it:

- Installs gems (including Solid Queue, Mission Control, etc.)
- Generates models, controllers, and views
- Sets up authentication, admin panel, and email
- Configures CSS, deployment, and git hooks
- Runs database migrations and seeds

### For Existing Applications

For versioned upgrades to an existing Rails app, see [UPGRADING.md](UPGRADING.md).

## Template Structure

The template is organized into modular files for maintainability:

```
template.rb              # Main orchestrator (loads all modules)
template/
  ├── gems.rb           # Gem dependencies
  ├── solid.rb          # Solid Queue/Cache/Cable setup
  ├── current.rb        # Current context class
  ├── authorization.rb  # Authorization concern (role-based, app-side)
  ├── models.rb         # User and Session models
  ├── admin.rb          # Admin panel
  ├── routes.rb         # Route configuration
  ├── home.rb           # Home page
  ├── email.rb          # Email system setup
  ├── css.rb            # CSS structure (MVPA.css framework)
  ├── appkit.rb         # appkit engine wiring (auth, PWA/push, theme/preferences)
  ├── config.rb         # Configuration files (.env, RuboCop, etc.)
  ├── deployment.rb     # Kamal deployment setup
  ├── seeds.rb          # Database seeds
  └── finish.rb         # Final steps and success message
```

### How It Works

The main `template.rb` file is a thin orchestrator that loads each module using Rails' `apply` method:

```ruby
apply "template/gems.rb"

after_bundle do
  apply "template/solid.rb"
  apply "template/models.rb"
  apply "template/appkit.rb"
  # ... etc
end
```

This approach:

- Keeps each concern separated and focused
- Makes the template easier to maintain and customize
- Allows you to skip or modify individual modules
- Still works as a standard Rails template (not interactive)

### Customizing

To customize the template, simply edit the relevant module files:

- **Add/remove gems**: Edit `template/gems.rb`
- **Modify authentication, PWA/push, or theme/preferences wiring**: Edit `template/appkit.rb` - the auth/theme
  logic itself lives in the [appkit](https://github.com/eirvandelden/appkit) gem, not this repo, so engine fixes
  arrive via `bundle update appkit` in generated apps without a template change
- **Change CSS setup**: Edit `template/css.rb`
- **Skip features**: Comment out `apply` calls in `template.rb`

## Development

After creating your app, start the development server:

```bash
foreman start -f Procfile.dev
```

This starts:

- Web server (with Thruster)
- Solid Queue worker
- Solid Cable server

## Default Accounts

The template creates two default users:

- **Admin**: admin@example.com / password
- **User**: user@example.com / password

**Important**: Change these passwords before deploying to production!

## Documentation

- [CSS_GUIDE.md](CSS_GUIDE.md) - Complete CSS system guide with Selenized themes
- [UPGRADING.md](UPGRADING.md) - Versioned template upgrades
- [TEMPLATE_STRUCTURE.md](TEMPLATE_STRUCTURE.md) - Explanation of modular structure
- [DEPLOYMENT.md](DEPLOYMENT.md) - Deployment with Kamal (auto-created in new apps)
- [agents.md](agents.md) - Instructions for AI coding assistants

## Technology Stack

**Backend:**

- Ruby on Rails 8.1+
- SQLite (development/test)
- Solid Queue (background jobs)
- Solid Cache (caching)
- Solid Cable (WebSockets)

**Frontend:**

- Hotwire (Turbo + Stimulus)
- MVPA.css (classless CSS framework)
- Importmap (no Node.js bundler)
- Propshaft (asset pipeline)

**Tools:**

- RuboCop (Omakase style)
- Brakeman (security scanning)
- Lefthook (git hooks)
- Letter Opener (email preview)
- Mission Control (job monitoring)

**Deployment:**

- Kamal (self-hosted)
- Docker

## Architecture

### Authentication

- Provided by the [appkit](https://github.com/eirvandelden/appkit) engine: session-based with signed cookies,
  first-run bootstrap, session transfer/QR handoff
- `Current` class for thread-safe context (`user`, `session`)
- `Appkit::Authentication` concern in controllers, `Appkit::Authenticatable`/`Appkit::SessionBehavior` on the
  User/Session models
- Sessions track user_agent, ip_address, and last_active_at

### Authorization

- Role-based with enum (user, admin)
- `Authorization` concern with `ensure_admin`
- Admin namespace protected by role checks

### Background Jobs

- Solid Queue for async processing
- Welcome emails sent via job
- Mission Control for monitoring at `/jobs`

### Email

- HTML and text templates
- Letter Opener in development
- SMTP in production
- Environment variable configuration

## Useful Commands

```bash
# Start development server
foreman start -f Procfile.dev

# Run tests
bin/rails test

# Code quality checks
bundle exec rubocop
bundle exec brakeman
bundle exec bundle-audit

# Database
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset

# Console
bin/rails console

# View emails (development)
# Opens automatically in browser via Letter Opener

# Monitor jobs
# Visit http://localhost:3000/jobs
```

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions using Kamal.

Quick deployment:

```bash
# First time setup
cp .env.template .env
# Edit .env with your values
kamal setup

# Deploy
kamal deploy
```

## Security

- Passwords hashed with bcrypt
- Signed session cookies
- CSRF protection enabled
- Brakeman security scanning
- Regular dependency audits with bundler-audit

## License

This template is free to use for any purpose.

## Contributing

This is a personal template, but feel free to fork and customize for your own needs.
