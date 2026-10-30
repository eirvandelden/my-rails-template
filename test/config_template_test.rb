require "minitest/autorun"
require "yaml"

TEMPLATE_ROOT = File.expand_path("..", __dir__) unless defined?(TEMPLATE_ROOT)

class ConfigRecorder
  attr_reader :files, :commands

  def initialize
    @files = {}
    @commands = []
  end

  def say(*); end

  def run(command, **)
    @commands << command
  end

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

  def test_config_writes_no_lefthook_file
    refute recorder.files.key?("lefthook.yml")
  end

  def test_config_runs_no_lefthook_install
    refute recorder.commands.any? { |command| command.include?("lefthook") }
  end

  def test_dependabot_covers_bundler_npm_and_github_actions_weekly_with_a_seven_day_cooldown
    updates = %w[bundler npm github-actions].map do |ecosystem|
      {
        "package-ecosystem" => ecosystem,
        "directory" => "/",
        "schedule" => { "interval" => "weekly" },
        "cooldown" => { "default-days" => 7 }
      }
    end

    assert_equal({ "version" => 2, "updates" => updates }, YAML.safe_load(dependabot_file[:content]))
  end

  def test_dependabot_indents_sequences_and_starts_with_a_document_marker
    assert dependabot_file[:content].start_with?("---\n")
    assert_includes dependabot_file[:content], "\n  - package-ecosystem: bundler\n"
  end

  def test_dependabot_overwrites_the_rails_generated_file
    assert_equal true, dependabot_file[:options][:force]
  end

  private

  def dependabot_file
    recorder.files.fetch(".github/dependabot.yml")
  end

  def rubocop_file
    recorder.files.fetch(".rubocop.yml")
  end

  def recorder
    @recorder ||= ConfigRecorder.new.tap { |recorder| recorder.apply("template/config.rb") }
  end
end
