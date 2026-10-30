require "minitest/autorun"
require "yaml"

TEMPLATE_ROOT = File.expand_path("..", __dir__) unless defined?(TEMPLATE_ROOT)

class I18nRecorder
  attr_reader :files

  def initialize
    @files = {}
  end

  def say(*); end

  def gsub_file(*); end

  def remove_file(*); end

  def create_file(path, content = nil, **)
    @files[path] = content
  end

  def apply(path)
    instance_eval(File.read(path, encoding: "UTF-8"), path)
  end
end

class I18nTemplateTest < Minitest::Test
  LOCALES = %w[en nl it].freeze

  def test_locale_files_have_no_duplicate_keys
    LOCALES.each do |locale|
      duplicates = duplicate_keys(Psych.parse(locale_file(locale)).root)

      assert_empty duplicates, "#{locale}.yml repeats keys"
    end
  end

  def test_admin_user_edit_keeps_its_title_and_submit
    LOCALES.each do |locale|
      edit = YAML.safe_load(locale_file(locale)).dig(locale, "admin", "users", "edit")

      assert_equal %w[title submit], edit.keys, "#{locale}.yml admin.users.edit"
    end
  end

  private

  def duplicate_keys(node, path = [])
    return [] unless node.is_a?(Psych::Nodes::Mapping) || node.is_a?(Psych::Nodes::Sequence)

    return node.children.flat_map { |child| duplicate_keys(child, path) } if node.is_a?(Psych::Nodes::Sequence)

    pairs = node.children.each_slice(2).to_a
    keys = pairs.map { |key, _| key.value }
    repeated = keys.tally.select { |_, count| count > 1 }.keys.map { |key| (path + [ key ]).join(".") }
    repeated + pairs.flat_map { |key, value| duplicate_keys(value, path + [ key.value ]) }
  end

  def locale_file(locale)
    recorder.files.fetch("config/locales/#{locale}.yml")
  end

  def recorder
    @recorder ||= I18nRecorder.new.tap { |recorder| recorder.apply("template/i18n.rb") }
  end
end
