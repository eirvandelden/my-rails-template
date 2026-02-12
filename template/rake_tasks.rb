say "Setting up custom rake tasks directory...", :blue

# Create lib/tasks directory
empty_directory "lib/tasks"
create_file "lib/tasks/.gitkeep"

# Create README for lib/tasks
create_file "lib/tasks/README.md", <<~MD
  # Custom Rake Tasks

  This directory contains custom rake tasks for your application.

  ## Purpose

  Use this directory for maintenance and utility tasks such as:
  - Data cleanup and corrections
  - Batch processing
  - Scheduled maintenance
  - Administrative utilities

  ## Creating Tasks

  Create files with `.rake` extension:

  ```bash
  touch lib/tasks/my_task.rake
  ```

  ## Example Task

  Create `lib/tasks/example.rake`:

  ```ruby
  namespace :example do
    desc "This is an example task"
    task hello: :environment do
      puts "Hello, World!"
      # You have access to ActiveRecord models and Rails environment
      User.count
    end
  end
  ```

  Run with:
  ```bash
  rails example:hello
  ```

  ## Common Patterns

  ### Task with Environment Access
  ```ruby
  task my_task: :environment do
    User.all.each { |user| ... }
  end
  ```

  ### Namespaced Tasks
  ```ruby
  namespace :maintenance do
    desc "Clean up old records"
    task cleanup: :environment do
      # ...
    end
  end
  ```

  ### Task with Arguments
  ```ruby
  task :send_email, [:email] => :environment do |t, args|
    puts "Sending email to #{args.email}"
  end
  ```

  Run: `rails send_email[user@example.com]`

  ## Built-in Tasks

  Common Rails tasks available:
  - `rake db:migrate` - Run pending migrations
  - `rake db:seed` - Load seed data
  - `rake db:reset` - Drop, create, and migrate database
  - `rake test` - Run test suite
  - `rake routes` - Show routing table
MD

say "✓ Custom rake tasks directory created", :green
say "  Add .rake files to lib/tasks/ for custom maintenance tasks", :white
