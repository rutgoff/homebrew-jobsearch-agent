# typed: strict
# frozen_string_literal: true

# Run with `brew ruby test/key_command_check.rb`: runs `brew jobsearch-key` without a tap install.
require_relative "../cmd/jobsearch-key"

Homebrew::Cmd::JobsearchKey.new([]).run
