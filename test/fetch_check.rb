# typed: strict
# frozen_string_literal: true

# Run with `brew ruby test/fetch_check.rb <url> [verbose-debug]`: prints "OK <file name>" or the error message.
require_relative "../lib/jobsearch_key_download_strategy"

# verbose-debug: run as `brew install --verbose --debug` does, so that the curl command lines print.
# (An argument, not a variable: `brew` removes unknown variables from the environment.)
Context.current = Context::ContextStruct.new(verbose: true, debug: true) if ARGV[1] == "verbose-debug"

strategy = JobsearchKeyDownloadStrategy.new(ARGV.fetch(0), "jobsearch", Version.new("1.2.0"))
begin
  strategy.fetch
  puts "OK #{strategy.basename}"
rescue CurlDownloadStrategyError => e
  puts e.message
end
