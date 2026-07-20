require "minitest/autorun"

class AppkitTemplateTest < Minitest::Test
  def test_template_applies_appkit_module_instead_of_the_deleted_modules
    assert_match(/apply "#\{TEMPLATE_ROOT\}\/template\/appkit\.rb"/, template_rb)

    %w[authentication.rb sessions.rb preferences.rb theme_system.rb].each do |deleted|
      assert_nil(template_rb[/template\/#{Regexp.escape(deleted)}"/],
                 "expected template.rb to no longer apply #{deleted}")
    end
  end

  def test_appkit_module_runs_after_models_and_routes_are_generated
    apply_order = template_rb.scan(/apply "#\{TEMPLATE_ROOT\}\/template\/(\w+)\.rb"/).flatten

    assert_operator apply_order.index("models"), :<, apply_order.index("appkit")
    assert_operator apply_order.index("routes"), :<, apply_order.index("appkit")
    assert_operator apply_order.index("home"), :<, apply_order.index("appkit")
    assert_operator apply_order.index("css"), :<, apply_order.index("appkit")
  end

  def test_deleted_template_files_are_gone
    %w[authentication.rb sessions.rb preferences.rb theme_system.rb].each do |deleted|
      refute_path_exists "template/#{deleted}"
    end
  end

  def test_gemfile_gets_the_appkit_gem
    assert_match(/gem "appkit", github: "eirvandelden\/appkit"/, File.read("template/gems.rb"))
  end

  # Regression test: forgetting this import left the login page completely
  # unstyled in all four apps that adopted this engine before the template
  # caught up.
  def test_application_css_imports_both_the_brand_accent_and_appkits_login_css
    assert_match(/themes\/brand\.css/, appkit_rb)
    assert_match(/appkit\/login\.css/, appkit_rb)
  end

  # Regression test: skipping the auto-submit controller's registration left
  # the session-transfer (magic-link) flow silently stuck on the intermediate
  # page - the fix landed on appkit's main, but a template consuming an older
  # engine SHA (or a future edit to appkit.rb) could still drop it.
  def test_all_three_appkit_js_controllers_are_registered
    %w[push_controller theme_controller auto_submit_controller].each do |controller|
      assert_match(/appkit\/controllers\/#{controller}/, appkit_rb)
    end
  end

  def test_user_and_session_models_include_the_appkit_concerns
    assert_match(/include Appkit::Authenticatable/, appkit_rb)
    assert_match(/include Appkit::UserTheming/, appkit_rb)
    assert_match(/include Appkit::SessionBehavior/, appkit_rb)
  end

  def test_routes_mount_the_engine
    assert_match(/mount Appkit::Engine/, appkit_rb)
  end

  def test_application_controller_includes_appkit_authentication
    assert_match(/include Appkit::Authentication/, appkit_rb)
  end

  def test_authorization_module_no_longer_references_the_deleted_authentication_concern
    authorization_rb = File.read("template/authorization.rb")

    assert_nil(authorization_rb[/include Authentication\b/])
    assert_match(/include Authorization/, authorization_rb)
  end

  def test_appkit_initializer_configures_first_run_for_the_templates_role_enum
    assert_match(/config\.first_run/, appkit_rb)
  end

  # Regression test: Appkit::Authentication restores Current.user but
  # deliberately leaves I18n.locale/Time.zone untouched (host-app state, not
  # auth state) - every one of the four apps built on this engine sets it in
  # their own ApplicationController the same way. Without it, a signed-in
  # user's locale/timezone preference has no effect on anything.
  def test_application_controller_sets_locale_and_time_zone_from_current_user
    assert_match(/before_action :set_locale/, appkit_rb)
    assert_match(/around_action :set_time_zone/, appkit_rb)
    assert_match(/I18n\.locale = Current\.user&\.locale/, appkit_rb)
    assert_match(/Time\.use_zone\(Current\.user\.time_zone/, appkit_rb)
  end

  # Regression test: the engine's SessionBehavior only tracks
  # sessions.last_active_at, not a user-level last_login_at - the admin
  # dashboard this template generates sorts users by and displays
  # last_login_at, so it needs to be touched somewhere. A new Session row is
  # created on every sign-in, so that's the natural hook.
  def test_session_model_touches_user_last_login_at_on_create
    assert_match(/after_create.*user\.touch\(:last_login_at\)/, appkit_rb)
  end

  private

  def template_rb
    @template_rb ||= File.read("template.rb")
  end

  def appkit_rb
    @appkit_rb ||= File.read("template/appkit.rb")
  end
end
