# typed: strict
# frozen_string_literal: true

require "download_strategy"

# Downloads a jobsearch release with the tester's download key.
# Curl reads the key header from the key file and follows no redirect; Homebrew redacts the key in curl's output.
class JobsearchKeyDownloadStrategy < NoUnzipCurlDownloadStrategy
  KEY_LINE = /\AX-Jobsearch-Key: [A-Za-z0-9_-]{32}\n?\z/
  NO_KEY = "No download key. Ask Rowena for your key, then run: brew jobsearch-key"
  REFUSED = "Your download key was refused. Ask Rowena for a new key."
  MISSING = "Your download key is good, but the server has no file for this version. Tell Rowena."

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
      # The edge answers a bad key with 401; S3 answers a missing file with 403 (no s3:ListBucket) or 404.
      raise CurlDownloadStrategyError.new(url, REFUSED) if e.message.match?(/returned error: 401\b/)
      raise CurlDownloadStrategyError.new(url, MISSING) if e.message.match?(/returned error: 40[34]\b/)

      raise
    end
  end

  sig { returns(T::Array[String]) }
  def _curl_args = [*super, "--max-redirs", "0", "--header", "@#{self.class.key_file}"]

  sig { override.params(args: String, options: T.untyped).returns(SystemCommand::Result) }
  def curl_output(*args, **options)
    super(*args, **options, secrets: secrets_with_key(options))
  end

  sig {
    override.params(args: String, print_stdout: T.any(T::Boolean, Symbol), options: T.untyped)
            .returns(SystemCommand::Result)
  }
  def curl(*args, print_stdout: true, **options)
    super(*args, print_stdout:, **options, secrets: secrets_with_key(options))
  end

  private

  # The secrets of the curl call plus the saved key (for example, `HOMEBREW_CURL_VERBOSE` prints the request headers).
  sig { params(options: T::Hash[Symbol, T.untyped]).returns(T::Array[String]) }
  def secrets_with_key(options)
    key = self.class.key_file.read[/\AX-Jobsearch-Key: (\S+)/, 1]
    [*options[:secrets], *key]
  rescue SystemCallError
    Array(options[:secrets])
  end
end
