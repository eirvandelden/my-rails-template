require "minitest/autorun"

class ModelsTemplateTest < Minitest::Test
  def test_user_defaults_callback_declares_no_condition
    refute_match(/after_initialize :set_defaults, if:/, source)
  end

  def test_user_defaults_are_only_set_on_new_records
    assert_includes source, "def set_defaults\n      return unless new_record?\n"
  end

  private

  def source
    @source ||= File.read("template/models.rb", encoding: "UTF-8")
  end
end
