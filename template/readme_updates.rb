say "Updating README with new features...", :blue

# Read existing README
readme_path = Pathname.new(destination_root).join("README.md")
if File.exist?(readme_path)
  readme = File.read(readme_path)

  # Update Features section
  features_update = <<~FEATURES
    ## Features

    - **Authentication**: Secure session-based authentication with has_secure_password
    - **Authorization**: Role-based access control (admin, user)
    - **Data Migrations**: Separate data migrations from schema migrations using data_migrate gem
    - **Rails Extensions**: Organized framework extensions in `lib/rails_ext/`
    - **Testing**: Comprehensive system and integration tests with Capybara
    - **Session Test Helpers**: Built-in helpers for signing in/out in tests
    - **Custom Validators**: Reusable email and URL validators
    - **Pagination**: 37signals' geared_pagination solution
    - **Content Security Policy**: Security policies for resource loading
    - **Permissions Policy**: Browser feature restrictions
    - **User Timezone Support**: Multi-timezone support with user preferences
    - **Private Seeds**: Optional `db/seeds_private.rb` for local development data
    - **Custom Rake Tasks**: Directory structure for custom maintenance tasks
    - **Internationalization**: Multi-language support (nl, en, it)
    - **Theme System**: Light/dark theme support with user preferences
    - **Email Support**: ActionMailer configured with example welcome email
    - **Background Jobs**: Solid Queue for asynchronous job processing
  FEATURES

  readme.sub!(/## Features\n\n.*?(?=\n## |\z)/m, "## Features\n\n" + features_update.strip)

  # Update Stack section
  stack_update = <<~STACK
    ## Stack

    **Core Framework**: Rails 8+

    **Data & Storage**:
    - SQLite (production-ready with `storage/db/`)
    - Solid Cache
    - Solid Queue
    - Solid Cable

    **Authentication & Authorization**:
    - bcrypt (password hashing)
    - has_secure_password

    **Testing**:
    - Capybara + Selenium (system tests)
    - Minitest (unit/integration tests)

    **Pagination**:
    - geared_pagination (37signals solution)

    **Data Migrations**:
    - data_migrate

    **Development**:
    - dotenv-rails (environment variables)
    - i18n-tasks (translation management)
    - faker (test data generation)
    - bundler-audit (security audits)
    - Lefthook (git hooks)

    **CSS**:
    - CSS with theme system (light/dark mode)
    - View transitions for smooth navigation

    **Email**:
    - ActionMailer with SMTP support
    - Letter Opener for development preview
  STACK

  readme.sub!(/## Stack\n\n.*?(?=\n## |\z)/m, "## Stack\n\n" + stack_update.strip)

  # Update Testing section if it exists
  testing_update = <<~TESTING
    ## Testing

    The template includes comprehensive testing infrastructure:

    ### System Tests

    System tests run with Capybara using headless Chrome:

    ```bash
    rails test:system
    ```

    Example: `test/system/authentication_test.rb`

    ### Integration Tests

    Integration tests test the full request/response cycle:

    ```bash
    rails test
    ```

    Example: `test/integration/sessions_test.rb`

    ### Session Test Helpers

    Use helpers for easy authentication in tests:

    ```ruby
    class MyTest < ActionDispatch::IntegrationTest
      def setup
        @user = users(:user)
      end

      test "user can view profile" do
        sign_in_as(@user)
        get user_path(@user)
        assert_response :success
      end
    end
    ```

    Available helpers:
    - `sign_in_as(user)` - Sign in via POST
    - `sign_out` - Sign out
    - `system_sign_in_as(user)` - Sign in via browser UI (system tests)
    - `assert_authenticated` - Assert user is logged in
    - `assert_not_authenticated` - Assert user is not logged in

    ### Parallel Testing

    Tests run in parallel by default. Adjust workers in `test/test_helper.rb`:

    ```ruby
    parallelize(workers: :number_of_processors, with: :threads)
    ```
  TESTING

  if readme.include?("## Testing")
    readme.sub!(/## Testing\n\n.*?(?=\n## |\z)/m, "## Testing\n\n" + testing_update.strip)
  else
    # Add Testing section before Configuration if it doesn't exist
    readme.sub!(/(\n## [^T])/m, "\n## Testing\n\n" + testing_update.strip + "\n\\1")
  end

  # Add or update Structure section
  structure_update = <<~STRUCTURE
    ## Directory Structure

    ```
    app/
      controllers/
        concerns/
          - authentication.rb      (session management)
          - authorization.rb       (role-based access control)
      models/
        - user.rb                  (with timezone support)
        - session.rb
      validators/                  (NEW: custom validators)
        - email_validator.rb
        - url_validator.rb
      views/
        layouts/
          - application.html.erb   (with view transitions)

    config/
      initializers/
        - rails_extensions.rb      (NEW: auto-load lib/rails_ext/)
        - content_security_policy.rb (NEW)
        - permissions_policy.rb    (NEW)

    db/
      data/                        (NEW: data migrations)
      migrate/
        - schema migrations here

    lib/
      rails_ext/                   (NEW: framework extensions)
        - inflections.rb
      tasks/                       (NEW: custom rake tasks)

    storage/
      db/                          (NEW: SQLite databases)

    test/
      helpers/
        - session_test_helper.rb   (NEW: test authentication)
      system/
        - authentication_test.rb   (NEW: example system test)
      integration/
        - sessions_test.rb         (NEW: example integration test)

    .env                           (NEW: development configuration)
    .env.template                  (NEW: configuration template)
    db/seeds_private.rb.example    (NEW: private seeds example)
  STRUCTURE

  if readme.include?("## Directory Structure") || readme.include?("## Structure")
    readme.sub!(/## (?:Directory )?Structure\n\n.*?(?=\n## |\z)/m, "## Directory Structure\n\n" + structure_update.strip)
  else
    # Add Structure section
    readme.sub!(/(\n## [A-Z])/m, "\n## Directory Structure\n\n" + structure_update.strip + "\n\\1")
  end

  # Add Configuration section
  config_update = <<~CONFIG
    ## Configuration

    ### Environment Variables

    Copy `.env.template` to `.env` and fill in your values:

    ```bash
    cp .env.template .env
    ```

    ### Rails Extensions

    Add framework-level customizations to `lib/rails_ext/`:

    ```ruby
    # lib/rails_ext/my_extension.rb
    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.plural 'media', 'media'
    end
    ```

    Files are auto-loaded by `config/initializers/rails_extensions.rb`.

    ### Data Migrations

    Use data migrations for data changes (separate from schema):

    ```bash
    rails generate data_migration AddInitialCategories
    ```

    Run with: `rails data:migrate`

    ### Timezone Support

    Users can set their timezone in preferences. The app automatically uses their timezone:

    ```ruby
    @user.timezone       # => "America/New_York"
    @user.time_zone     # => ActiveSupport::TimeZone object
    Time.current         # Uses user's timezone in controllers
    ```

    ### Private Seeds

    For local-only seed data, create `db/seeds_private.rb`:

    ```ruby
    # db/seeds_private.rb (gitignored)
    User.create!(email: "local@example.com", password: "secure")
    ```

    Reference: `db/seeds_private.rb.example`

    ### SQLite

    `config/database.yml` tunes SQLite for concurrent access in every environment:
    - `journal_mode: wal` lets readers and a writer proceed at the same time instead of blocking each other.
    - `timeout` (the Ruby-side busy handler) and the `busy_timeout` pragma are always set to the *same* value — a mismatch between the two is a common cause of sporadic "database is locked" errors.
    - `test` relaxes durability (`synchronous: "OFF"`, no WAL auto-checkpointing) and raises the timeout, since tests run multi-threaded (see Parallel Testing above) against one shared file and don't need crash durability.
    - `production` splits `primary`/`cache`/`queue`/`cable` into separate database files under `storage/db/` so Solid Queue/Cache/Cable don't contend with application writes on the same file.

    When writing a background job that iterates and writes to the same table, prefer plucking IDs over `find_each`:

    ```ruby
    # Avoid: find_each keeps a read cursor open while writing, holding up other writers
    Vehicle.where(stale: true).find_each { |v| v.update!(checked_at: Time.current) }

    # Prefer: pluck IDs to close the cursor immediately, then write in small batches
    Vehicle.where(stale: true).pluck(:id).each_slice(50) do |batch_ids|
      Vehicle.where(id: batch_ids).each { |v| v.update!(checked_at: Time.current) }
    end
    ```

    ### Security

    **Content Security Policy**: Configured in `config/initializers/content_security_policy.rb`
    - Report-only mode by default (safe for development)
    - Adjust policies as needed for your assets

    **Permissions Policy**: Configured in `config/initializers/permissions_policy.rb`
    - Disables camera, microphone, geolocation, etc.
    - Allows fullscreen for same-origin
  CONFIG

  if readme.include?("## Configuration")
    readme.sub!(/## Configuration\n\n.*?(?=\n## |\z)/m, "## Configuration\n\n" + config_update.strip)
  else
    readme.concat("\n## Configuration\n\n" + config_update.strip)
  end

  # Write updated README
  File.write(readme_path, readme)
  say "✓ README updated with new features", :green
else
  say "✗ README.md not found", :red
end
