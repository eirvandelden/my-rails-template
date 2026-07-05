require "erb"
require "minitest/autorun"
require "yaml"

class DatabaseSetupTest < Minitest::Test
  def test_pragmas_do_not_override_sqlite_timeout_handler
    assert_empty database_config.fetch("default").fetch("pragmas").keys.grep("busy_timeout")
    assert_empty database_config.fetch("test").fetch("pragmas").keys.grep("busy_timeout")
  end

  def test_timeout_is_configured_for_lock_waits
    assert_equal 5_000, database_config.fetch("default").fetch("timeout")
    assert_equal 20_000, database_config.fetch("test").fetch("timeout")
  end

  private

  def database_config
    @database_config ||= YAML.safe_load(database_yml, aliases: true)
  end

  def database_yml
    ERB.new(database_yml_template).result
  end

  def database_yml_template
    File.read("template/database_setup.rb").match(/<<~YAML, force: true\n(.*?)^YAML/m)[1]
  end
end
