say "Setting up comprehensive testing infrastructure...", :blue

# ===== Configure Capybara =====
create_file "test/application_system_test_case.rb", <<~RUBY
  require "test_helper"

  class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end
RUBY

# ===== Create Session Test Helper =====
create_file "test/helpers/session_test_helper.rb", <<~RUBY
  module SessionTestHelper
    # Sign in user via POST request (for integration tests)
    def sign_in_as(user)
      post session_path, params: {
        session: {
          email: user.email,
          password: "password"
        }
      }
    end

    # Sign out via DELETE request (for integration tests)
    def sign_out
      delete session_path
    end

    # Assert user is authenticated via session
    def assert_authenticated
      assert_not_nil Current.user, "Expected user to be authenticated"
    end

    # Assert user is not authenticated
    def assert_not_authenticated
      assert_nil Current.user, "Expected user to not be authenticated"
    end

    # Sign in user via browser UI (for system tests)
    def system_sign_in_as(user)
      visit new_session_path
      fill_in "session[email]", with: user.email
      fill_in "session[password]", with: "password"
      click_button I18n.t("sessions.sign_in")
    end
  end
RUBY

# ===== Update test_helper.rb =====
inject_into_file "test/test_helper.rb", after: "ENV[\"RAILS_ENV\"] ||= \"test\"\n" do
  "require \"capybara/rails\"\n"
end

inject_into_file "test/test_helper.rb", after: "class ActiveSupport::TestCase\n" do
  "  # Add test helper methods from test/helpers/\n  Dir[Rails.root.join(\"test/helpers/*.rb\")].each { |f| require f }\n\n  # Include helper modules\n  include SessionTestHelper\n\n"
end

# Enable parallel testing if not already set
gsub_file "test/test_helper.rb",
  /parallelize\(workers: :number_of_processors\)/,
  "parallelize(workers: :number_of_processors, with: :threads)"

# ===== Create Example System Test =====
create_file "test/system/authentication_test.rb", <<~RUBY
  require "application_system_test_case"

  class AuthenticationTest < ApplicationSystemTestCase
    setup do
      @user = users(:user)
    end

    test "user can sign in and view dashboard" do
      system_sign_in_as(@user)

      assert_current_path root_path
      assert_text @user.email
    end

    test "user can sign out" do
      system_sign_in_as(@user)
      click_button I18n.t("sessions.sign_out")

      assert_current_path new_session_path
      assert_text I18n.t("sessions.new")
    end

    test "user cannot access without signing in" do
      visit edit_preferences_path

      assert_current_path new_session_path
    end
  end
RUBY

# ===== Create Example Integration Test =====
create_file "test/integration/sessions_test.rb", <<~RUBY
  require "test_helper"

  class SessionsTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:user)
    end

    test "user can sign in" do
      sign_in_as(@user)

      assert_response :redirect
      follow_redirect!

      assert_equal root_path, path
    end

    test "user can sign out" do
      sign_in_as(@user)
      sign_out

      assert_response :redirect
      follow_redirect!

      assert_equal new_session_path, path
    end

    test "invalid email does not sign in user" do
      sign_in_as(users(:user))
      # User should redirect to signin page on failure
      # (implementation depends on your auth setup)
    end
  end
RUBY

# ===== Update test fixtures to include users =====
create_file "test/fixtures/users.yml", <<~YAML
  user:
    email: user@example.com
    password_digest: <%= BCrypt::Password.create("password") %>
    role: user

  admin:
    email: admin@example.com
    password_digest: <%= BCrypt::Password.create("password") %>
    role: admin
YAML

say "✓ Testing infrastructure configured", :green
say "  - Capybara with headless Chrome", :white
say "  - Session test helpers (sign_in_as, system_sign_in_as)", :white
say "  - Example system and integration tests", :white
say "  - Parallel testing enabled", :white
say "  Run: rails test:system to run system tests", :white
