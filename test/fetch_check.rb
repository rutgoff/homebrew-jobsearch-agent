# typed: strict
# frozen_string_literal: true

# Run with `brew ruby test/fetch_check.rb <url>`: prints "OK <file name>" or the error message.
require_relative "../lib/jobsearch_key_download_strategy"

strategy = JobsearchKeyDownloadStrategy.new(ARGV.fetch(0), "jobsearch", Version.new("1.2.0"))
begin
  strategy.fetch
  puts "OK #{strategy.basename}"
rescue CurlDownloadStrategyError => e
  puts e.message
end
