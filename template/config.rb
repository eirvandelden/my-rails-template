# Configuration files

# Create symlink to agents.md from dotfiles
say "Creating agents.md symlink...", :blue
run "ln -sf ~/Developer/dotfiles/AGENTS.md agents.md"

# Copy RuboCop configuration from template
rubocop_source = File.join(TEMPLATE_ROOT, ".rubocop.yml")
if File.exist?(rubocop_source)
  # Read the actual file content (follows symlink)
  create_file ".rubocop.yml", File.read(rubocop_source)
  say "  ✓ Created .rubocop.yml", :green
else
  say "  ✗ Warning: .rubocop.yml not found in template", :yellow
end

# Copy lefthook configuration from template
lefthook_source = File.join(TEMPLATE_ROOT, "lefthook.yml")
if File.exist?(lefthook_source)
  # Read the actual file content (follows symlink)
  create_file "lefthook.yml", File.read(lefthook_source)
  say "  ✓ Created lefthook.yml", :green
else
  say "  ✗ Warning: lefthook.yml not found in template", :yellow
end

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
