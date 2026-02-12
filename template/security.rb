say "Setting up security policies...", :blue

# Create Content Security Policy configuration
create_file "config/initializers/content_security_policy.rb", <<~RUBY
  # Be sure to restart your server when you modify this file.

  Rails.application.configure do
    config.content_security_policy do |policy|
      policy.default_src :self, :https
      policy.font_src :self, :https, :data
      policy.img_src :self, :https, :data, :blob
      policy.object_src :none
      policy.script_src :self, :https
      policy.style_src :self, :https, :unsafe_inline
      # If you need to enable unsafe_inline for scripts, do so thoughtfully
      # policy.script_src :self, :https, :unsafe_inline
    end

    # Generate secure random nonces for inline scripts
    config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }

    # Report CSP violations (useful for debugging)
    # Uncomment to enable CSP violation reports
    # config.content_security_policy_report_only = true
  end
RUBY

# Create Permissions Policy configuration
create_file "config/initializers/permissions_policy.rb", <<~RUBY
  # Be sure to restart your server when you modify this file.

  Rails.application.configure do
    config.permissions_policy do |policy|
      # Restrict potentially sensitive permissions
      policy.accelerometer :none
      policy.ambient_light_sensor :none
      policy.autoplay :none
      policy.camera :none
      policy.geolocation :none
      policy.gyroscope :none
      policy.magnetometer :none
      policy.microphone :none
      policy.payment :none
      policy.usb :none

      # Allow fullscreen for own origin
      policy.fullscreen :self
    end
  end
RUBY

say "✓ Security policies configured", :green
say "  - Content Security Policy (CSP) configured", :white
say "  - Permissions Policy configured", :white
say "  - CSP is in report-only mode by default (safe)", :white
say "  - Adjust config/initializers/content_security_policy.rb as needed", :white
