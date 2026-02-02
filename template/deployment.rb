# Deployment configuration

# Initialize Kamal for deployment
say "Setting up Kamal deployment...", :blue
run "bundle exec kamal init"

# Update DEPLOYMENT.md
create_file "DEPLOYMENT.md", <<~MD
  # Deployment with Kamal

  This application is configured for self-hosted deployment using Kamal.

  ## Prerequisites

  1. A server with Docker installed (your self-hosted infrastructure)
  2. SSH access to your server
  3. Docker registry account (Docker Hub, GitHub Container Registry, or self-hosted registry)
  4. Domain name pointing to your server

  ## Setup

  1. Copy `.env.template` to `.env` and fill in your values:
     \`\`\`bash
     cp .env.template .env
     \`\`\`

  2. Update `config/deploy.yml` with your server details:
     - Service name
     - Server IP address
     - Registry details
     - Environment variables

  3. Generate your Rails master key:
     \`\`\`bash
     rails credentials:edit
     \`\`\`

  ## First Deployment

  \`\`\`bash
  # Setup the server (one time only)
  kamal setup

  # Deploy the application
  kamal deploy
  \`\`\`

  ## Subsequent Deployments

  \`\`\`bash
  kamal deploy
  \`\`\`

  ## Useful Commands

  \`\`\`bash
  # Check application status
  kamal app details

  # View logs
  kamal app logs

  # Connect to Rails console on server
  kamal app exec -i --reuse "bin/rails console"

  # Run database migrations
  kamal app exec "bin/rails db:migrate"

  # Restart the application
  kamal app restart

  # Stop the application
  kamal app stop

  # Remove the application from server
  kamal app remove
  \`\`\`

  ## Background Jobs (Solid Queue)

  Solid Queue runs alongside your web server in the same container. Configuration is in `config/deploy.yml`.

  ### Monitoring Jobs

  Visit `/jobs` (Mission Control) to monitor background jobs. Make sure to protect this endpoint in production.

  ## Email Configuration

  Required environment variables for email:

  - `MAILER_FROM_ADDRESS` - Default sender email
  - `SMTP_ADDRESS` - Your SMTP server
  - `SMTP_PORT` - SMTP port (usually 587 for TLS)
  - `SMTP_DOMAIN` - Your domain
  - `SMTP_USERNAME` - SMTP authentication username
  - `SMTP_PASSWORD` - SMTP authentication password
  - `SMTP_AUTHENTICATION` - Authentication method (usually `plain`)
  - `SMTP_TLS` - Enable TLS (true/false)

  ## Database

  The template uses SQLite for development/test. For production self-hosting:

  **Option 1: Continue with SQLite**
  - Simple, no additional setup needed
  - Works well for single-server deployments
  - Kamal handles SQLite files via volumes

  **Option 2: PostgreSQL**
  - Better for multi-server deployments
  - Install PostgreSQL on your server or use managed service
  - Update `Gemfile` and `config/database.yml`
  - Set `DATABASE_URL` environment variable

  ## Redis (Optional)

  While Solid Queue/Cache/Cable work with SQLite, Redis is recommended for production:

  1. Install Redis on your server: `apt install redis-server`
  2. Or use a managed Redis service
  3. Set `REDIS_URL` environment variable
  4. Update production config to use Redis for cache/cable

  ## SSL/HTTPS

  Kamal can automatically provision SSL certificates using Let's Encrypt.
  Configure this in `config/deploy.yml` under the `traefik` section.

  Example:
  \`\`\`yaml
  traefik:
    options:
      publish:
        - 443:443
      volume:
        - /letsencrypt/acme.json:/letsencrypt/acme.json
    args:
      certificatesResolvers.letsencrypt.acme.email: your@email.com
      certificatesResolvers.letsencrypt.acme.storage: /letsencrypt/acme.json
      certificatesResolvers.letsencrypt.acme.httpchallenge: true
      certificatesResolvers.letsencrypt.acme.httpchallenge.entrypoint: web
  \`\`\`

  ## Environment Variables

  All required environment variables are listed in `.env.template`.

  Set them in Kamal via `config/deploy.yml`:

  \`\`\`yaml
  env:
    secret:
      - RAILS_MASTER_KEY
      - SMTP_PASSWORD
    clear:
      - MAILER_FROM_ADDRESS
      - SMTP_ADDRESS
      - BASE_URL
  \`\`\`

  ## Backup Strategy

  For self-hosted deployments, ensure you have backups:

  1. **Database**: Regular SQLite/PostgreSQL backups
  2. **Uploaded files**: Backup ActiveStorage files
  3. **Environment variables**: Keep `.env` secure and backed up
  4. **Credentials**: Backup `config/master.key`

  ## Monitoring

  - Mission Control Jobs: `/jobs` - Background job monitoring
  - Application logs: `kamal app logs`
  - Server logs: SSH into server and check Docker logs

  ## Troubleshooting

  **Deployment fails:**
  \`\`\`bash
  kamal app logs  # Check application logs
  kamal traefik logs  # Check proxy logs
  \`\`\`

  **Jobs not running:**
  - Check Solid Queue is configured in `config/deploy.yml`
  - Verify worker processes are running: `kamal app exec "ps aux"`

  **Email not sending:**
  - Verify SMTP credentials in environment variables
  - Check application logs for SMTP errors
  - Test with: `kamal app exec -i "bin/rails runner 'UserMailer.test_email.deliver_now'"`

  ## Security Checklist

  Before deploying to production:

  - [ ] Change default admin password
  - [ ] Set strong `RAILS_MASTER_KEY`
  - [ ] Configure SSL/HTTPS
  - [ ] Set secure SMTP credentials
  - [ ] Enable firewall on server (allow only 80, 443, SSH)
  - [ ] Regular security updates on server
  - [ ] Protect Mission Control endpoint (add authentication)
  - [ ] Regular backups configured
  - [ ] Monitor logs for suspicious activity
MD
