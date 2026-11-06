require "minitest/autorun"
require "json"

TEMPLATE_ROOT = File.expand_path("..", __dir__) unless defined?(TEMPLATE_ROOT)

class LintToolchainRecorder
  attr_reader :files, :appended, :commands

  def initialize
    @files = {}
    @appended = {}
    @commands = []
  end

  def app_name
    "demo_app"
  end

  def say(*); end

  def create_file(path, content = nil, **options)
    @files[path] = { content: content, options: options }
  end

  def append_to_file(path, content)
    @appended[path] = content
  end

  def run(command, **options)
    @commands << { command: command, options: options }
  end

  def apply(path)
    instance_eval(File.read(path, encoding: "UTF-8"), path)
  end
end

class LintToolchainTemplateTest < Minitest::Test
  PACKAGES = %w[eslint @eslint/js globals stylelint stylelint-config-standard].freeze

  def test_package_json_is_a_private_module_named_after_the_app
    expected = { "name" => "demo_app", "private" => true, "type" => "module" }

    assert_equal expected, JSON.parse(file("package.json"))
  end

  def test_npm_install_adds_exactly_the_five_approved_dev_dependencies
    assert_equal "npm install --save-dev #{PACKAGES.join(' ')}", install[:command]
  end

  def test_npm_install_aborts_generation_on_failure
    assert_equal true, install[:options][:abort_on_failure]
  end

  def test_eslint_config_uses_the_recommended_rules
    assert_includes file("eslint.config.js"), 'import js from "@eslint/js"'
    assert_includes file("eslint.config.js"), "js.configs.recommended"
  end

  def test_eslint_config_declares_the_browser_globals
    assert_includes file("eslint.config.js"), 'import globals from "globals"'
    assert_includes file("eslint.config.js"), "globals: globals.browser"
  end

  def test_eslint_config_ignores_vendor_public_and_tmp
    assert_includes file("eslint.config.js"), 'ignores: ["vendor/**", "public/**", "tmp/**"]'
  end

  def test_stylelint_config_extends_standard_and_ignores_vendor_public_and_tmp
    expected = {
      "extends" => [ "stylelint-config-standard" ],
      "ignoreFiles" => [ "vendor/**", "public/**", "tmp/**" ]
    }

    assert_equal expected, JSON.parse(file(".stylelintrc.json"))
  end

  def test_gitignore_ignores_node_modules
    assert_includes recorder.appended.fetch(".gitignore").lines.map(&:chomp), "/node_modules"
  end

  def test_lint_toolchain_runs_after_config_and_before_finish
    applied = File.read("template.rb").scan(%r{template/(\w+)\.rb}).flatten

    assert_operator applied.index("config"), :<, applied.index("lint_toolchain")
    assert_operator applied.index("lint_toolchain"), :<, applied.index("finish")
  end

  private

  def file(path)
    recorder.files.fetch(path)[:content]
  end

  def install
    recorder.commands.find { |entry| entry[:command].start_with?("npm install") }
  end

  def recorder
    @recorder ||= LintToolchainRecorder.new.tap { |recorder| recorder.apply("template/lint_toolchain.rb") }
  end
end
