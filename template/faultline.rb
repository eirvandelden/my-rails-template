say "Setting up Faultline exception tracking...", :blue

# Run the faultline installer (generates initializer + migrations)
rails_command "generate faultline:install"
rails_command "db:migrate"

# Overwrite the generated initializer to use the template's custom auth
create_file "config/initializers/faultline.rb", force: true do
  <<~RUBY
    Faultline.configure do |config|
      # Restrict the /faultline dashboard to admin users only.
      # Uses the template's existing session cookie + admin role check,
      # matching the pattern in app/controllers/concerns/authentication.rb.
      config.authenticate_with = lambda { |request|
        session_token = request.cookie_jar.signed[:session_token]
        session = session_token && Session.find_by(token: session_token)
        session&.user&.admin?
      }
    end
  RUBY
end

say "✓ Faultline exception tracking configured", :green
say "  - Dashboard available at /faultline (admin only)", :white
say "  - Exceptions captured automatically via Rack middleware", :white
say "  - Add notifiers in config/initializers/faultline.rb as needed", :white
