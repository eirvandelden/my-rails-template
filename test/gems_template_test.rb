require "minitest/autorun"

class GemsRecorder
  Entry = Struct.new(:name, :options, :groups)

  attr_reader :entries

  def initialize
    @entries = []
    @groups = []
  end

  def gsub_file(*); end

  def gem(name, **options)
    @entries << Entry.new(name, options, @groups.dup)
  end

  def gem_group(*groups)
    @groups.push(groups)
    yield
  ensure
    @groups.pop
  end

  def apply(path)
    instance_eval(File.read(path, encoding: "UTF-8"), path)
  end

  def find(name)
    entries.find { |entry| entry.name == name }
  end
end

class GemsTemplateTest < Minitest::Test
  def test_gemfile_takes_rubocop_rules_from_rubocop_eirvandelden
    entry = recorder.find("rubocop-eirvandelden")

    refute_nil entry
    assert_equal "eirvandelden/rubocop-eirvandelden", entry.options[:github]
    assert_equal false, entry.options[:require]
    assert_equal [ [ :development ] ], entry.groups
  end

  def test_gemfile_keeps_rubocop_capybara
    refute_nil recorder.find("rubocop-capybara")
  end

  def test_gemfile_drops_plugin_gems_rubocop_eirvandelden_brings
    %w[rubocop-minitest rubocop-obsession rubocop-packaging rubocop-rspec].each do |name|
      assert_nil recorder.find(name), "#{name} should not be in the generated Gemfile"
    end
  end

  private

  def recorder
    @recorder ||= GemsRecorder.new.tap { |recorder| recorder.apply("template/gems.rb") }
  end
end
