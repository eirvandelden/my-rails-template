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

  def append_to_file(*); end

  def empty_directory(*); end

  def generate(*); end

  def gsub_file(*); end

  def inject_into_class(*); end

  def inject_into_file(*); end

  def rails_command(*); end

  def remove_file(*); end

  def run(*); end

  def say(*); end

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
    MODULES.map { |name| recorded_files("template/#{name}.rb") }.reduce({}, :merge).select { |path, _| path.match?(%r{\A(app|test/mailers/previews)/.*\.rb\z}) }
  end

  def recorded_files(path)
    AnnotationRecorder.new.tap { |recorder| recorder.apply(path) }.files
  end
end
