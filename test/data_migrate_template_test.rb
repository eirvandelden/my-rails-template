require "minitest/autorun"

class DataMigrateTemplateTest < Minitest::Test
  def test_help_text_is_defined_outside_the_rake_block
    assert_match(/^  help = <<~HELP$/, source)
    assert_includes source, "task migrate_help: :environment do\n      puts help\n"
  end

  private

  def source
    File.read("template/data_migrate.rb", encoding: "UTF-8")
  end
end
