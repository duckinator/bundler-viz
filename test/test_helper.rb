# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bundler/visualize"

require "minitest/autorun"

PLUGIN_ROOT = File.expand_path("..", __dir__)
PLUGIN_BRANCH = `git rev-parse --abbrev-ref HEAD`.strip
