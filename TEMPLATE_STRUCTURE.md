# Template Structure Explanation

## What "Split into Modules" Means

The template is now organized into separate Ruby files instead of one monolithic `template.rb`. Each file handles a specific concern (authentication, email, CSS, etc.).

This is **NOT** an interactive template - it still runs automatically like a standard Rails template. The difference is organizational: instead of 500+ lines in one file, we have smaller focused modules.

## File Structure

```
my-rails-template/
├── template.rb                    # Main orchestrator (20 lines)
├── template/                      # Module directory
│   ├── gems.rb                   # Gem dependencies
│   ├── solid.rb                  # Solid Queue/Cache/Cable installation
│   ├── current.rb                # Current attributes setup
│   ├── authentication.rb         # Authentication concern
│   ├── authorization.rb          # Authorization concern
│   ├── models.rb                 # User & Session models
│   ├── sessions.rb               # Sessions controller & views
│   ├── admin.rb                  # Admin panel
│   ├── routes.rb                 # Route configuration
│   ├── home.rb                   # Home controller & view
│   ├── email.rb                  # Email system
│   ├── css.rb                    # CSS setup
│   ├── config.rb                 # Config files (RuboCop, Lefthook, etc.)
│   ├── deployment.rb             # Kamal setup
│   ├── seeds.rb                  # Database seeds
│   └── finish.rb                 # Final steps & success message
├── agents.md -> ~/Developer/dotfiles/AGENTS.md  # Symlink
├── README.md                      # Documentation
└── DEPLOYMENT.md                  # Deployment guide
```

## How Rails Template Loading Works

Rails templates support the `apply` method to load other Ruby files:

```ruby
# template.rb
apply "template/gems.rb"

after_bundle do
  apply "template/authentication.rb"
  apply "template/email.rb"
end
```

When you run `rails new myapp -m template.rb`, Rails:

1. Executes `template.rb`
2. When it hits `apply "template/gems.rb"`, it loads and executes that file
3. After bundle install, it executes all modules in the `after_bundle` block
4. Everything runs sequentially and automatically

## Benefits of Modular Structure

### Maintainability

- Each file is ~50-200 lines instead of 500+ in one file
- Easy to locate and update specific features
- Clear separation of concerns

### Customization

Want to skip email setup? Comment out one line:

```ruby
# apply "template/email.rb"  # Skip this
```

Want different CSS? Edit just `template/css.rb`.

### Readability

The main `template.rb` acts as a table of contents:

```ruby
apply "template/gems.rb"
apply "template/authentication.rb"
apply "template/email.rb"
```

You immediately see all features included.

### Collaboration

Multiple people can work on different modules without conflicts.

## Usage

### Standard Usage

```bash
rails new myapp -m template.rb
```

The template automatically loads all modules in sequence.

### Custom Usage

Fork the template and modify `template.rb` to skip or reorder modules:

```ruby
apply "template/gems.rb"

after_bundle do
  apply "template/solid.rb"
  apply "template/authentication.rb"
  # apply "template/email.rb"     # Skip email
  # apply "template/admin.rb"     # Skip admin panel
  apply "template/css.rb"
  apply "template/finish.rb"
end
```

## Module Descriptions

| Module              | Purpose                             | Lines |
| ------------------- | ----------------------------------- | ----- |
| `gems.rb`           | Adds all gem dependencies           | ~40   |
| `solid.rb`          | Installs Solid Queue/Cache/Cable    | ~15   |
| `current.rb`        | Creates Current attributes class    | ~10   |
| `authentication.rb` | Session-based authentication logic  | ~70   |
| `authorization.rb`  | Role-based authorization            | ~20   |
| `models.rb`         | User & Session model setup          | ~50   |
| `sessions.rb`       | Sign in/out functionality           | ~60   |
| `admin.rb`          | Admin panel for user management     | ~150  |
| `routes.rb`         | Configure routes                    | ~5    |
| `home.rb`           | Home page & layout                  | ~40   |
| `email.rb`          | Complete email system               | ~200  |
| `css.rb`            | MVP.css + SMACSS structure          | ~150  |
| `config.rb`         | RuboCop, Lefthook, .env, Procfile   | ~100  |
| `deployment.rb`     | Kamal deployment setup              | ~180  |
| `seeds.rb`          | Default user accounts               | ~20   |
| `finish.rb`         | Migrations, seeds, git, success msg | ~50   |

Total: ~1,160 lines spread across 16 focused files instead of one 1,160-line file.

## Comparison: Before vs After

### Before (Monolithic)

```
template.rb          [1,160 lines - hard to navigate]
```

### After (Modular)

```
template.rb          [20 lines - table of contents]
template/
  ├── gems.rb        [40 lines - just gems]
  ├── email.rb       [200 lines - just email]
  ├── css.rb         [150 lines - just CSS]
  └── ... etc
```

## Non-Interactive Nature

Important: This is still a **standard Rails template**, not an interactive one.

**What happens:**

1. User runs: `rails new myapp -m template.rb`
2. Everything runs automatically
3. No prompts or user input required
4. New app is ready to use

**What does NOT happen:**

- No interactive prompts asking "Do you want email? (y/n)"
- No configuration wizard
- No CLI menus

The template applies all features automatically in sequence. Users customize by editing the template files before running it, not during execution.

## agents.md Symlink

The `agents.md` file is now a symlink to `~/Developer/dotfiles/AGENTS.md`:

```bash
agents.md -> /Users/etienne.vandelden/Developer/dotfiles/AGENTS.md
```

This means:

- Changes to `~/Developer/dotfiles/AGENTS.md` automatically appear here
- Single source of truth for AI agent instructions
- No duplication or sync issues
- Part of your dotfiles management system

The symlink is created in the repository but will work correctly on your system since it points to your dotfiles location.
