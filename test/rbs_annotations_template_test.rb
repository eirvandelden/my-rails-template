require "minitest/autorun"

TEMPLATE_ROOT = File.expand_path("..", __dir__) unless defined?(TEMPLATE_ROOT)

class AnnotationRecorder
  attr_reader :files

  def initialize
    @files = {}
  end

  def create_file(path, content = nil, **)
    @files[path] = content
  end

  def method_missing(*) = nil

  def respond_to_missing?(*) = true

  def apply(path)
    instance_eval(File.read(path, encoding: "UTF-8"), path)
  end
end

class RbsAnnotationsTemplateTest < Minitest::Test
  MODULES = %w[admin home models email validators appkit].freeze

  def test_public_methods_in_generated_app_code_carry_rbs_annotations
    unannotated = app_ruby_files.flat_map { |path, content| unannotated_methods(path, content) }

    assert_empty unannotated
  end

  private

  def unannotated_methods(path, content)
    public_part = content.split(/^\s*private\s*$/).first
    lines = public_part.lines
    lines.each_index.select { |index| lines[index].match?(/^\s*def /) && !lines[index - 1].match?(/^\s*#:/) }
         .map { |index| "#{path}: #{lines[index].strip}" }
  end

  def app_ruby_files
    MODULES.map { |name| recorded_files("template/#{name}.rb") }.reduce({}, :merge).select { |path, _| path.match?(%r{\Aapp/.*\.rb\z}) }
  end

  def recorded_files(path)
    AnnotationRecorder.new.tap { |recorder| recorder.apply(path) }.files
  end
end
