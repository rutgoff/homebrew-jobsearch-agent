# typed: strict
# frozen_string_literal: true

require "abstract_command"
require "io/console"

module Homebrew
  module Cmd
    # `brew jobsearch-key`: save the tester's download key for `brew install jobsearch`.
    class JobsearchKey < AbstractCommand
      KEY = /\A[A-Za-z0-9_-]{32}\z/

      cmd_args do
        description <<~EOS
          Save your jobsearch download key. The input stays hidden. The key goes into
          `~/.config/jobsearch/download-key` (mode 600), and `brew install jobsearch` reads it.
        EOS
        named_args :none
      end

      sig { override.void }
      def run
        key = read_key
        unless KEY.match?(key)
          odie "That is not a download key. A key has 32 letters, digits, - or _. " \
               "Ask Rowena for your key."
        end

        file = Pathname(Dir.home)/".config/jobsearch/download-key"
        file.dirname.mkpath
        file.open(File::WRONLY | File::CREAT | File::TRUNC, 0600) { |f| f.write("X-Jobsearch-Key: #{key}\n") }
        file.chmod(0600)
        puts "Saved your download key. Next: brew install jobsearch"
      end

      private

      sig { returns(String) }
      def read_key
        line = if $stdin.tty?
          IO.console&.getpass("Paste your download key (the input stays hidden): ")
        else
          $stdin.gets
        end
        line.to_s.strip
      end
    end
  end
end
