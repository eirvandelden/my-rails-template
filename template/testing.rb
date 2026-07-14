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
  # Test helpers for user authentication in integration and system tests.
  module SessionTestHelper
    # Signs in a user via POST request (for integration tests).
    #
    # @param user [User] the user to sign in
    # @return [void]
    # @example
    #   sign_in_as(users(:admin))
    #   get dashboard_path
    #   assert_response :success
    def sign_in_as(user)
      post session_path, params: {
        email: user.email,
        password: "password"
      }
    end

    # Signs out the current user via DELETE request (for integration tests).
    #
    # @return [void]
    # @example
    #   sign_out
    #   get dashboard_path
    #   assert_redirected_to new_session_path
    def sign_out
      delete session_path
    end

    # Asserts that a user is currently authenticated.
    #
    # @return [void]
    # @raise [Minitest::Assertion] if no user is authenticated
    # @example
    #   sign_in_as(@user)
    #   assert_authenticated
    def assert_authenticated
      assert_not_nil Current.user, "Expected user to be authenticated"
    end

    # Asserts that no user is currently authenticated.
    #
    # @return [void]
    # @raise [Minitest::Assertion] if a user is authenticated
    # @example
    #   assert_not_authenticated
    #   get dashboard_path
    #   assert_redirected_to new_session_path
    def assert_not_authenticated
      assert_nil Current.user, "Expected user to not be authenticated"
    end

    # Signs in a user via browser UI (for system tests).
    #
    # @param user [User] the user to sign in
    # @return [void]
    # @example
    #   system_sign_in_as(users(:admin))
    #   assert_text "Dashboard"
    def system_sign_in_as(user)
      visit new_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "password"
      click_button I18n.t("sessions.sign_in")
    end
  end
RUBY

# ===== Update test_helper.rb =====
inject_into_file "test/test_helper.rb", after: "require \"rails/test_help\"\n" do
  "require \"capybara/rails\"\n"
end

inject_into_file "test/test_helper.rb", after: "class TestCase\n" do
  "    # Add test helper methods from test/helpers/\n    Dir[Rails.root.join(\"test/helpers/*.rb\")].each { |f| require f }\n\n    # Include helper modules\n    include SessionTestHelper\n\n"
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

    test "login sets a long-lived session cookie" do
      sign_in_as(@user)

      set_cookie = response.headers["Set-Cookie"]
      expires_match = set_cookie.match(/expires=([^;]+)/i)
      assert expires_match, "Expected Set-Cookie to include expires="
      cookie_expiry = Time.parse(expires_match[1])
      assert cookie_expiry > 11.months.from_now, "Expected cookie to expire more than 11 months from now, got #{cookie_expiry}"
    end

    test "resuming a session renews the cookie expiration" do
      sign_in_as(@user)
      follow_redirect!

      get root_path

      set_cookie = response.headers["Set-Cookie"]
      expires_match = set_cookie.match(/expires=([^;]+)/i)
      assert expires_match, "Expected Set-Cookie header on second request to include expires="
      cookie_expiry = Time.parse(expires_match[1])
      assert cookie_expiry > 10.years.from_now, "Expected renewed cookie to expire more than 10 years from now, got #{cookie_expiry}"
    end

    test "user can sign out" do
      sign_in_as(@user)
      sign_out

      assert_response :redirect
      follow_redirect!

      assert_equal new_session_path, path
    end
  end
RUBY

create_file "test/integration/admin/dashboard_test.rb", <<~RUBY
  require "test_helper"

  class Admin::DashboardTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @user = users(:user)
    end

    test "non-admin user is redirected away" do
      sign_in_as(@user)
      get admin_root_path

      assert_redirected_to root_path
    end

    test "admin can access dashboard and sees user table" do
      sign_in_as(@admin)
      get admin_root_path

      assert_response :success
      assert_select "table"
      assert_select "td", text: @admin.email
    end

    test "dashboard shows user counts" do
      sign_in_as(@admin)
      get admin_root_path

      assert_response :success
      assert_select "dd", text: User.count.to_s
      assert_select "dd", text: User.admin.count.to_s
    end
  end
RUBY

create_file "test/integration/admin/users_test.rb", <<~RUBY
  require "test_helper"

  class Admin::UsersTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @user = users(:user)
    end

    test "admin can list users" do
      sign_in_as(@admin)
      get admin_users_path

      assert_response :success
      assert_select "td", text: @user.email
    end

    test "admin can view a user" do
      sign_in_as(@admin)
      get admin_user_path(@user)

      assert_response :success
      assert_select "dd", text: @user.email
    end

    test "admin can reach new user form" do
      sign_in_as(@admin)
      get new_admin_user_path

      assert_response :success
      assert_select "form"
    end

    test "admin can create a user" do
      sign_in_as(@admin)

      assert_difference("User.count", 1) do
        post admin_users_path, params: {
          user: {
            name: "Created User",
            email: "created@example.com",
            role: "user",
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      created_user = User.find_by!(email: "created@example.com")
      assert_redirected_to admin_user_path(created_user)
    end

    test "admin can edit a user" do
      sign_in_as(@admin)
      get edit_admin_user_path(@user)

      assert_response :success
      assert_select "form"
    end

    test "admin can update a user" do
      sign_in_as(@admin)
      patch admin_user_path(@user), params: { user: { name: "Updated Name", role: "admin" } }

      assert_redirected_to admin_user_path(@user)
      assert_equal "Updated Name", @user.reload.name
      assert_equal "admin", @user.role
    end

    test "admin cannot delete themselves" do
      sign_in_as(@admin)

      assert_no_difference("User.count") do
        delete admin_user_path(@admin)
      end

      assert_redirected_to admin_users_path
    end

    test "non-admin user is redirected for all actions" do
      sign_in_as(@user)

      get admin_users_path
      assert_redirected_to root_path

      get admin_user_path(@admin)
      assert_redirected_to root_path

      get new_admin_user_path
      assert_redirected_to root_path

      post admin_users_path, params: {
        user: {
          name: "Blocked User",
          email: "blocked@example.com",
          role: "user",
          password: "password",
          password_confirmation: "password"
        }
      }
      assert_redirected_to root_path

      get edit_admin_user_path(@admin)
      assert_redirected_to root_path

      patch admin_user_path(@admin), params: { user: { name: "Should Not Work" } }
      assert_redirected_to root_path

      delete admin_user_path(@admin)
      assert_redirected_to root_path
    end
  end
RUBY

# ===== Update test fixtures to include users =====
create_file "test/fixtures/users.yml", <<~YAML
  user:
    name: Regular User
    email: user@example.com
    password_digest: <%= BCrypt::Password.create("password") %>
    role: user
    last_login_at: <%= 2.hours.ago %>

  admin:
    name: Admin User
    email: admin@example.com
    password_digest: <%= BCrypt::Password.create("password") %>
    role: admin
    last_login_at: <%= 1.hour.ago %>
YAML

create_file "test/fixtures/sessions.yml", <<~YAML
  user_session:
    user: user
    token: user_token_123
    ip_address: 127.0.0.1
    user_agent: Test Browser

  admin_session:
    user: admin
    token: admin_token_456
    ip_address: 127.0.0.1
    user_agent: Test Browser
YAML

say "✓ Testing infrastructure configured", :green
say "  - Capybara with headless Chrome", :white
say "  - Session test helpers (sign_in_as, system_sign_in_as)", :white
say "  - Example system and integration tests", :white
say "  - Parallel testing enabled", :white
say "  Run: rails test:system to run system tests", :white
