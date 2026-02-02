# Configuration files

# Create symlink to agents.md from dotfiles
say "Creating agents.md symlink...", :blue
run "ln -sf ~/Developer/dotfiles/AGENTS.md agents.md"

# Create RuboCop configuration
create_file ".rubocop.yml", <<~YAML
  # Omakase Ruby styling for Rails
  inherit_gem:
    rubocop-rails-omakase: rubocop.yml

  inherit_from:
    - .rubocop_todo.yml
    - ~/.rubocop.yml

  AllCops:
    Exclude:
      - 'db/migrate/**/*'
      - 'db/schema.rb'
      - 'db/queue_schema.rb'
      - 'node_modules/**/*'
      - 'vendor/**/*'
      - 'bin/**/*'

  Metrics/BlockLength:
    Exclude:
      - 'config/environments/*'
      - 'config/routes.rb'
      - 'lib/tasks/**/*'
      - 'test/**/*'
YAML

# Create lefthook configuration
create_file ".lefthook.yml", <<~YAML
  # Git hooks managed by lefthook
  # Install: lefthook install

  pre-commit:
    commands:
      rubocop:
        glob: "*.rb"
        run: bundle exec rubocop {staged_files}

      trailing-whitespace:
        run: git diff --check

  pre-push:
    commands:
      tests:
        run: bin/rails test

      security:
        run: bundle exec brakeman -q -z
YAML

# Install lefthook
run "bundle exec lefthook install"

# Create .env.template for environment variables
create_file ".env.template", <<~ENV
  # Rails
  RAILS_MASTER_KEY=

  # Database
  DATABASE_URL=

  # Redis (for Solid Queue/Cache/Cable in production)
  REDIS_URL=

  # Email
  MAILER_FROM_ADDRESS=noreply@example.com
  SMTP_ADDRESS=
  SMTP_PORT=587
  SMTP_DOMAIN=
  SMTP_USERNAME=
  SMTP_PASSWORD=
  SMTP_AUTHENTICATION=plain
  SMTP_TLS=true

  # Web
  RAILS_MAX_THREADS=5
  WEB_CONCURRENCY=2
  BASE_URL=

  # Deployment
  KAMAL_REGISTRY_USERNAME=
  KAMAL_REGISTRY_PASSWORD=
ENV

# Update .gitignore
append_to_file ".gitignore", <<~GITIGNORE

  # Environment variables
  .env
  .env.local
  .env.*.local

  # Lefthook
  .lefthook-local.yml

  # Letter opener emails
  tmp/letter_opener/
GITIGNORE

# Create Procfile for local development
create_file "Procfile.dev", <<~PROCFILE
  web: bundle exec thrust bin/rails server
  queue: bundle exec rake solid_queue:start
  cable: bundle exec rake solid_cable:start
PROCFILE
