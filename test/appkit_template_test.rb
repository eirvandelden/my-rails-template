require "minitest/autorun"

class AppkitTemplateTest < Minitest::Test
  def test_template_applies_appkit_module_instead_of_the_deleted_modules
    assert_match(/apply "#\{TEMPLATE_ROOT\}\/template\/appkit\.rb"/, template_rb)

    %w[authentication.rb sessions.rb preferences.rb theme_system.rb].each do |deleted|
      assert_no_match(/template\/#{Regexp.escape(deleted)}"/, template_rb, "expected template.rb to no longer apply #{deleted}")
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

    assert_no_match(/include Authentication\b/, authorization_rb)
    assert_match(/include Authorization/, authorization_rb)
  end

  def test_appkit_initializer_configures_first_run_for_the_templates_role_enum
    assert_match(/config\.first_run/, appkit_rb)
  end

  private

  def template_rb
    @template_rb ||= File.read("template.rb")
  end

  def appkit_rb
    @appkit_rb ||= File.read("template/appkit.rb")
  end
end
