# Email system configuration

say "Setting up email system...", :blue

# Create ApplicationMailer
gsub_file "app/mailers/application_mailer.rb", /class ApplicationMailer.*end\nend/m do
  <<~RUBY
    class ApplicationMailer < ActionMailer::Base
      default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@example.com")
      layout "mailer"
    end
  RUBY
end

# Generate UserMailer
generate :mailer, "User", "welcome", "password_reset"

# Completely rewrite UserMailer to avoid leftover code
remove_file "app/mailers/user_mailer.rb"
create_file "app/mailers/user_mailer.rb", <<~RUBY
  class UserMailer < ApplicationMailer
    def welcome(user)
      @user = user
      mail(to: @user.email, subject: "Welcome to \#{Rails.application.class.module_parent_name}!")
    end

    def password_reset(user, token)
      @user = user
      @token = token
      mail(to: @user.email, subject: "Password Reset Instructions")
    end
  end
RUBY

# Create email templates
create_file "app/views/user_mailer/welcome.html.erb", <<~ERB
  <h1>Welcome, <%= @user.email %>!</h1>

  <p>Thank you for signing up. We're excited to have you on board.</p>

  <p>
    Your account has been created with the role: <strong><%= @user.role.titleize %></strong>
  </p>

  <p>
    <%= link_to "Get Started", root_url %>
  </p>
ERB

create_file "app/views/user_mailer/welcome.text.erb", <<~TEXT
  Welcome, <%= @user.email %>!

  Thank you for signing up. We're excited to have you on board.

  Your account has been created with the role: <%= @user.role.titleize %>

  Get started: <%= root_url %>
TEXT

create_file "app/views/user_mailer/password_reset.html.erb", <<~ERB
  <h1>Password Reset</h1>

  <p>Hi <%= @user.email %>,</p>

  <p>You requested a password reset. Click the link below to reset your password:</p>

  <p>
    <%= link_to "Reset Password", edit_password_reset_url(@token) %>
  </p>

  <p>This link will expire in 2 hours.</p>

  <p>If you didn't request this, please ignore this email.</p>
ERB

create_file "app/views/user_mailer/password_reset.text.erb", <<~TEXT
  Password Reset

  Hi <%= @user.email %>,

  You requested a password reset. Visit this link to reset your password:

  <%= edit_password_reset_url(@token) %>

  This link will expire in 2 hours.

  If you didn't request this, please ignore this email.
TEXT

# Update mailer layouts with proper styling
gsub_file "app/views/layouts/mailer.html.erb", /.*/m, <<~ERB
  <!DOCTYPE html>
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <style>
        body {
          font-family: system-ui, -apple-system, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
        }

        h1 {
          color: #0066cc;
          font-size: 24px;
        }

        a {
          color: #0066cc;
          text-decoration: none;
        }

        a:hover {
          text-decoration: underline;
        }

        .btn {
          display: inline-block;
          padding: 12px 24px;
          background: #0066cc;
          color: white;
          border-radius: 4px;
          text-decoration: none;
          margin: 16px 0;
        }
      </style>
    </head>
    <body>
      <%= yield %>
    </body>
  </html>
ERB

gsub_file "app/views/layouts/mailer.text.erb", /.*/m, <<~TEXT
  <%= yield %>
TEXT

# Create Welcome email job
create_file "app/jobs/send_welcome_email_job.rb", <<~RUBY
  class SendWelcomeEmailJob < ApplicationJob
    queue_as :default

    def perform(user)
      UserMailer.welcome(user).deliver_now
    end
  end
RUBY

# Configure email in development
inject_into_file "config/environments/development.rb", after: "config.action_mailer.raise_delivery_errors = false\n" do
  <<~RUBY

    # Use letter_opener for email preview
    config.action_mailer.delivery_method = :letter_opener
    config.action_mailer.perform_deliveries = true
    config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  RUBY
end

# Configure email in test
inject_into_file "config/environments/test.rb", after: "Rails.application.configure do\n" do
  <<~RUBY

    # Email configuration
    config.action_mailer.delivery_method = :test
    config.action_mailer.default_url_options = { host: "example.com" }
  RUBY
end

# Configure email in production
inject_into_file "config/environments/production.rb", after: "Rails.application.configure do\n" do
  <<~RUBY

    # Email configuration - use SMTP
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS", "localhost"),
      port: ENV.fetch("SMTP_PORT", 587),
      domain: ENV.fetch("SMTP_DOMAIN", "example.com"),
      user_name: ENV.fetch("SMTP_USERNAME", nil),
      password: ENV.fetch("SMTP_PASSWORD", nil),
      authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain"),
      enable_starttls_auto: ENV.fetch("SMTP_TLS", "true") == "true"
    }
    config.action_mailer.default_url_options = { host: ENV.fetch("BASE_URL", "example.com") }
  RUBY
end

# Create email test helpers
create_file "test/helpers/email_test_helper.rb", <<~RUBY
  module EmailTestHelper
    def assert_email_sent(to:, subject: nil)
      email = ActionMailer::Base.deliveries.last
      assert email, "No email was sent"
      assert_equal to, email.to.first
      assert_match subject, email.subject if subject
    end

    def assert_email_body_includes(text)
      email = ActionMailer::Base.deliveries.last
      assert email, "No email was sent"
      assert_includes email.body.to_s, text
    end

    def clear_emails
      ActionMailer::Base.deliveries.clear
    end
  end
RUBY

# Add email test helper to test_helper
inject_into_file "test/test_helper.rb", after: "class ActiveSupport::TestCase\n" do
  <<~RUBY
    include EmailTestHelper

  RUBY
end
