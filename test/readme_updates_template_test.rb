require "minitest/autorun"
require "pathname"
require "tmpdir"

RAILS_README = <<~MD
  # README

  This README would normally document whatever steps are necessary to get the
  application up and running.

  Things you may want to cover:

  * Ruby version

  * Configuration

  * ...
MD

class ReadmeUpdatesRecorder
  attr_reader :destination_root

  def initialize(destination_root)
    @destination_root = destination_root
  end

  def say(*); end

  def apply(path)
    instance_eval(File.read(path, encoding: "UTF-8"), path)
  end
end

class ReadmeUpdatesTemplateTest < Minitest::Test
  def test_readme_intro_is_one_line
    intro = readme.lines.grep(/This README would normally document/)

    assert_equal 1, intro.size
    assert_match(/up and running\.$/, intro.first)
  end

  def test_readme_sqlite_bullets_are_one_line_each
    section = readme[/### SQLite\n.*?(?=\n### )/m]
    wrapped = section.lines.each_cons(2).select { |line, following| line.start_with?("- ") && following.start_with?("  ") }

    assert_empty wrapped
  end

  private

  def readme
    @readme ||= Dir.mktmpdir do |directory|
      File.write(File.join(directory, "README.md"), RAILS_README)
      ReadmeUpdatesRecorder.new(directory).apply("template/readme_updates.rb")
      File.read(File.join(directory, "README.md"))
    end
  end
end
