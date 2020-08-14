# frozen_string_literal: true

require "bundler/visualize"

Bundler::Plugin::API.command("visualize", Bundler::Visualize::Command)

# For compatibility with the old `bundle viz` command.
Bundler::Plugin::API.command("viz", Bundler::Visualize::Command)
