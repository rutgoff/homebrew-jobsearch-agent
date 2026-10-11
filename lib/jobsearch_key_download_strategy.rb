# typed: strict
# frozen_string_literal: true

require "download_strategy"

# Downloads a jobsearch release with the tester's download key.
# The key file holds the header line, so curl reads the key from the file:
# the key is never in a command line or in Homebrew's output.
class JobsearchKeyDownloadStrategy < NoUnzipCurlDownloadStrategy
  KEY_LINE = /\AX-Jobsearch-Key: [A-Za-z0-9_-]{32}\n?\z/
  NO_KEY = "No download key. Ask Rowena for your key, then run: brew jobsearch-key"
  REFUSED = "Your download key was refused. Ask Rowena for a new key."

  sig { returns(Pathname) }
  def self.key_file = Pathname(Dir.home)/".config/jobsearch/download-key"

  sig { returns(T::Boolean) }
  def self.key_saved?
    key_file.file? && KEY_LINE.match?(key_file.read)
  rescue SystemCallError
    false
  end

  sig { override.params(timeout: T.nilable(T.any(Float, Integer))).void }
  def fetch(timeout: nil)
    raise CurlDownloadStrategyError.new(url, NO_KEY) unless self.class.key_saved?

    begin
      super
    rescue CurlDownloadStrategyError => e
      raise CurlDownloadStrategyError.new(url, REFUSED) if e.message.match?(/returned error: 403\b/)

      raise
    end
  end

  sig { returns(T::Array[String]) }
  def _curl_args = [*super, "--header", "@#{self.class.key_file}"]
end
