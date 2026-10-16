require "minitest/autorun"
require "yaml"

TEMPLATE_ROOT = File.expand_path("..", __dir__) unless defined?(TEMPLATE_ROOT)

class ConfigRecorder
  attr_reader :files

  def initialize
    @files = {}
  end

  def say(*); end

  def run(*); end

  def append_to_file(*); end

  def create_file(path, content = nil, **options)
    @files[path] = { content: content, options: options }
  end

  def apply(path)
    instance_eval(File.read(path, encoding: "UTF-8"), path)
  end
end

class ConfigTemplateTest < Minitest::Test
  def test_rubocop_config_inherits_the_three_layers_from_rubocop_eirvandelden
    expected = {
      "inherit_gem" => {
        "rubocop-eirvandelden" => %w[config/default.yml config/rails.yml config/capybara.yml]
      }
    }

    assert_equal expected, YAML.safe_load(rubocop_file[:content])
  end

  def test_rubocop_config_overwrites_the_rails_generated_file
    assert_equal true, rubocop_file[:options][:force]
  end

  def test_rubocop_config_does_not_read_the_template_copy
    refute_includes File.read("template/config.rb"), 'File.join(TEMPLATE_ROOT, ".rubocop.yml")'
  end

  private

  def rubocop_file
    recorder.files.fetch(".rubocop.yml")
  end

  def recorder
    @recorder ||= ConfigRecorder.new.tap { |recorder| recorder.apply("template/config.rb") }
  end
end
