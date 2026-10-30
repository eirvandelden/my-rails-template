require "minitest/autorun"

TEMPLATE_ROOT = File.expand_path("..", __dir__) unless defined?(TEMPLATE_ROOT)

class EmailRecorder
  attr_reader :files, :generated

  def initialize
    @files = {}
    @generated = []
  end

  def say(*); end

  def generate(*arguments)
    @generated << arguments
  end

  def remove_file(*); end

  def gsub_file(*); end

  def inject_into_file(*); end

  def create_file(path, content = nil, **options)
    @files[path] = { content: content, options: options }
  end

  def apply(path)
    instance_eval(File.read(path, encoding: "UTF-8"), path)
  end
end

class EmailTemplateTest < Minitest::Test
  def test_mailer_generator_makes_only_the_welcome_action
    assert_equal [ [ :mailer, "User", "welcome" ] ], recorder.generated
  end

  def test_user_mailer_has_no_password_reset
    refute_includes file("app/mailers/user_mailer.rb")[:content], "password_reset"
  end

  def test_no_password_reset_views_are_written
    assert_empty recorder.files.keys.grep(/password_reset/)
  end

  def test_mailer_test_calls_welcome_with_the_user_fixture
    content = file("test/mailers/user_mailer_test.rb")[:content]

    assert_includes content, "user = users(:user)"
    assert_includes content, "UserMailer.welcome(user)"
    refute_includes content, "password_reset"
  end

  def test_mailer_test_overwrites_the_generated_file
    assert_equal true, file("test/mailers/user_mailer_test.rb")[:options][:force]
  end

  def test_mailer_preview_calls_welcome_with_a_user
    content = file("test/mailers/previews/user_mailer_preview.rb")[:content]

    assert_includes content, "UserMailer.welcome(User.first)"
    refute_includes content, "password_reset"
  end

  def test_mailer_preview_overwrites_the_generated_file
    assert_equal true, file("test/mailers/previews/user_mailer_preview.rb")[:options][:force]
  end

  private

  def file(path)
    recorder.files.fetch(path)
  end

  def recorder
    @recorder ||= EmailRecorder.new.tap { |recorder| recorder.apply("template/email.rb") }
  end
end
