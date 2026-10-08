require "minitest/autorun"
require "open3"
require "rbconfig"
require "tempfile"

class TemplateSyntaxTest < Minitest::Test
  CONFLICT_MARKER = /\A(?:<{7}|\|{7}|={7}|>{7})(?: |\z)/

  def test_conflict_marker_detection_flags_every_marker_line
    sample = [
      "<<<<<<< ours",
      "|||||||",
      "=======",
      "======= ",
      ">>>>>>> theirs",
      "x <<<<<<< y",
      "========",
      "<<<<<<<<"
    ].join("\n")

    assert_equal [ 1, 2, 3, 4, 5 ], conflict_marker_lines(sample)
  end

  def test_syntax_check_rejects_invalid_ruby
    refute_nil syntax_error_in_source('say "a" <<<')
    assert_nil syntax_error_in_source('say "a", :cyan')
  end

  def test_template_files_cover_the_orchestrator_and_every_module
    assert_includes template_files, "template.rb"
    assert_includes template_files, "template/finish.rb"
    assert_operator template_files.size, :>, 2
  end

  def test_every_template_module_is_free_of_conflict_markers
    offenses = template_files.flat_map do |path|
      conflict_marker_lines(File.read(path, encoding: "UTF-8")).map { |line| "#{path}:#{line}" }
    end

    assert_empty offenses, "Conflict markers found"
  end

  def test_every_template_module_is_valid_ruby
    offenses = template_files.filter_map do |path|
      error = syntax_error(path)
      "#{path}: #{error}" if error
    end

    assert_empty offenses, "Ruby syntax errors found"
  end

  private

  def template_files
    [ "template.rb", *Dir["template/*.rb"].sort ]
  end

  def conflict_marker_lines(source)
    source.lines.each_with_index.filter_map do |line, index|
      index + 1 if line.chomp.match?(CONFLICT_MARKER)
    end
  end

  def syntax_error(path)
    _output, error, status = Open3.capture3(RbConfig.ruby, "-c", path)
    error.lines.first.to_s.chomp unless status.success?
  end

  def syntax_error_in_source(source)
    Tempfile.create([ "sample", ".rb" ]) do |file|
      file.write(source)
      file.flush
      syntax_error(file.path)
    end
  end
end
