# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "bundler/visualize/version"

Gem::Specification.new do |spec|
  spec.name     = "bundler-viz"
  spec.authors  = ["Ellen Dash"]
  spec.email    = ["me@duckie.co"]

  spec.summary      = "Generate a visual representation of your gem dependencies"
  spec.description  = "A bundler plugin that generates a visual representation of your gem dependencies."
  spec.homepage     = "https://github.com/rubygems/bundler-viz"
  spec.license      = "MIT"

  spec.version = Bundler::Visualize::VERSION
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/rubygems/bundler-viz/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = ["bundler-visualize"]
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 2.0"
  spec.add_dependency "ruby-graphviz", "~> 1.2"

  spec.add_development_dependency "minitest", "~> 5.13"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 0.76"
end
