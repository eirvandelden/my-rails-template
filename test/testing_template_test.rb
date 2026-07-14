require "minitest/autorun"

class TestingTemplateTest < Minitest::Test
  def test_session_cookie_expiry_assertions_escape_generated_interpolation
    cookie_expiry_assertions.each do |assertion|
      assert_match(/got \\#\{cookie_expiry\}/, assertion)
      assert_equal false, assertion.include?('got #{cookie_expiry}"')
    end
  end

  def test_generated_session_cookie_tests_handle_multiple_set_cookie_headers
    assert_includes testing_template, 'Array(response.headers["Set-Cookie"])'
  end

  private

  def cookie_expiry_assertions
    testing_template.lines.grep(/cookie_expiry > .*got/)
  end

  def testing_template
    File.read("template/testing.rb")
  end
end
