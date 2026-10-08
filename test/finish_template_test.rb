require "minitest/autorun"

class FinishRecorder
  attr_reader :messages

  def initialize
    @messages = []
  end

  def say(message = "", _color = nil)
    @messages << message
  end

  def rails_command(*); end

  def run(*); end

  def git(*); end

  def apply(path)
    instance_eval(File.read(path, encoding: "UTF-8"), path)
  end
end

class FinishTemplateTest < Minitest::Test
  def test_finish_step_runs_to_the_end_of_the_summary
    assert_equal "🎊 Happy coding!", summary.reject(&:empty?).last
  end

  def test_summary_shows_the_admin_panel_as_step_six
    index = summary.index("6️⃣  Admin panel:")

    refute_nil index
    assert_equal "   http://localhost:3000/admin (admin only)", summary[index + 1]
  end

  private

  def summary
    @summary ||= FinishRecorder.new.tap { |recorder| recorder.apply("template/finish.rb") }.messages
  end
end
