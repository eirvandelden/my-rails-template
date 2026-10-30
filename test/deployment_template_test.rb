require "minitest/autorun"

class DeploymentRecorder
  attr_reader :files

  def initialize
    @files = {}
  end

  def say(*); end

  def run(*); end

  def create_file(path, content = nil, **)
    @files[path] = content
  end

  def method_missing(*) = nil

  def respond_to_missing?(*) = true

  def apply(path)
    instance_eval(File.read(path, encoding: "UTF-8"), path)
  end
end

class DeploymentTemplateTest < Minitest::Test
  def test_deployment_ssl_paragraph_is_one_line
    paragraph = deployment_md[/## SSL\/HTTPS\n\n(.*?)\n\n/m, 1]

    refute_includes paragraph, "\n"
    assert_includes paragraph, "Let's Encrypt."
    assert_includes paragraph, "under the `traefik` section."
  end

  private

  def deployment_md
    DeploymentRecorder.new.tap { |recorder| recorder.apply("template/deployment.rb") }.files.fetch("DEPLOYMENT.md")
  end
end
