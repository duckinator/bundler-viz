# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "open3"

class VisualizeTest < Minitest::Test
  def setup
    @original_wd = Dir.pwd
    appdir = File.expand_path("../tmp/app", __dir__)
    FileUtils.rm_rf(appdir)
    FileUtils.mkdir_p(appdir)
    Dir.chdir(appdir)
  end

  def teardown
    Dir.chdir(@original_wd)
  end

  def test_visualizes_gems_from_gemfile
    install_gemfile <<~G
      source "https://rubygems.org"
      gem "rack"
      gem "rack-obama"
    G
    install_plugin

    out = run_bundler_command("bundler visualize")
    assert_includes out, "gem_graph.png"
    assert File.exist?("gem_graph.png")

    out = run_bundler_command("bundle visualize --format debug")
    assert_includes out, <<~DOT
      digraph Gemfile {
      concentrate = "true";
      normalize = "true";
      nodesep = "0.55";
      edge[ weight  =  "2"];
      node[ fontname  =  "Arial, Helvetica, SansSerif"];
      edge[ fontname  =  "Arial, Helvetica, SansSerif" , fontsize  =  "12"];
      default [style = "filled", fillcolor = "#B9B9D5", shape = "box3d", fontsize = "16", label = "default"];
      rack [style = "filled", fillcolor = "#B9B9D5", label = "rack"];
        default -> rack [constraint = "false"];
      "rack-obama" [style = "filled", fillcolor = "#B9B9D5", label = "rack-obama"];
        default -> "rack-obama" [constraint = "false"];
        "rack-obama" -> rack;
      }
      debugging bundle viz...
    DOT
  end

  def test_skips_gems_from_single_group
    install_gemfile <<-G
      source "https://rubygems.org"
      gem "activesupport"

      group :model do
        gem "activemodel"
      end
    G
    install_plugin

    out = run_bundler_command("bundle visualize --format debug --without model")
    assert_includes out, "activesupport"
    refute_includes out, "activemodel"
  end

  def test_skips_gems_from_multiple_groups
    install_gemfile <<-G
      source "https://rubygems.org"
      gem "activesupport"

      group :model do
        gem "activemodel"
      end

      group :record do
        gem "activerecord"
      end
    G
    install_plugin

    out = run_bundler_command("bundle visualize --format debug --without model,record")
    assert_includes out, "activesupport"
    refute_includes out, "activemodel"
    refute_includes out, "activerecord"
  end

  def test_visualizes_to_custom_file_and_format
    install_gemfile <<~G
      source "https://rubygems.org"
      gem "rack"
    G
    install_plugin

    run_bundler_command("bundle visualize --format jpg --file my_gem_graph")
    assert File.exist?("my_gem_graph.jpg")
  end

  def test_visualizes_gem_versions
    install_gemfile <<~G
      source "https://rubygems.org"
      gem "rack", "1.6.0"
      gem "activesupport", "4.2.0"
    G
    install_plugin

    out = run_bundler_command("bundle visualize --format debug --version")
    assert_includes out, "rack\\n1.6.0"
    assert_includes out, "activesupport\\n4.2.0"
  end

  def test_visualizes_gem_dependencies_versions
    install_gemfile <<~G
      source "https://rubygems.org"
      gem "activesupport" # depends on i18n
    G
    install_plugin

    out = run_bundler_command("bundle visualize --format debug --requirements")
    assert_match(/activesupport -> i18n \[label =/, out)
  end

  private

  def install_gemfile(content)
    File.open("Gemfile", "w") do |f|
      f.write(content)
    end
    run_bundler_command("bundle install")
  end

  def install_plugin
    run_bundler_command("bundle plugin install bundler-visualize --git #{PLUGIN_ROOT} --branch #{PLUGIN_BRANCH}")
  end

  def run_bundler_command(command)
    output = nil
    Bundler.with_clean_env do
      output, status = Open3.capture2e(command)

      raise StandardError, "#{command} failed: #{output}" unless status.success?
    end
    output
  end
end
