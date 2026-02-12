say "Setting up Rails extensions directory...", :blue

# Create rails extensions directory
empty_directory "lib/rails_ext"
create_file "lib/rails_ext/.gitkeep"

# Create example inflections file
create_file "lib/rails_ext/inflections.rb", <<~RUBY
  # Custom inflections for your models
  # Examples:
  #   ActiveSupport::Inflector.inflections(:en) do |inflect|
  #     inflect.plural 'media', 'media'
  #     inflect.singular 'media', 'media'
  #     inflect.irregular 'person', 'people'
  #     inflect.uncountable %w(equipment)
  #   end
RUBY

# Create initializer to auto-load rails extensions
create_file "config/initializers/rails_extensions.rb", <<~RUBY
  # Auto-load Rails extensions from lib/rails_ext/
  Rails.application.config.to_prepare do
    Dir.glob(Rails.root.join("lib/rails_ext/**/*.rb")).each do |file|
      require file
    end
  end
RUBY

# Create README for the directory
create_file "lib/rails_ext/README.md", <<~MD
  # Rails Extensions

  This directory contains framework-level customizations and extensions.

  ## Purpose

  Use this directory for:
  - Custom inflections (pluralization rules)
  - ActiveRecord extensions
  - ActionController enhancements
  - Module mixins and concerns that extend Rails itself

  ## Pattern

  Each file in this directory is automatically required by the initializer at `config/initializers/rails_extensions.rb`.

  ## Example: Custom Inflections

  Create `lib/rails_ext/inflections.rb`:

  ```ruby
  ActiveSupport::Inflector.inflections(:en) do |inflect|
    inflect.plural 'media', 'media'
    inflect.singular 'media', 'media'
    inflect.irregular 'person', 'people'
    inflect.uncountable %w(equipment)
  end
  ```

  ## Not for App Code

  This is NOT for application-level concerns. Use instead:
  - `app/models/` for models and model concerns
  - `app/controllers/` for controllers and controller concerns
  - `lib/` for utility classes and helper modules
MD

say "✓ Rails extensions directory created", :green
say "  Files in lib/rails_ext/ will auto-load via config/initializers/rails_extensions.rb", :white
