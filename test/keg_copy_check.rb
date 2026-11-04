# typed: strict
# frozen_string_literal: true

# Run with `brew ruby test/keg_copy_check.rb <copy of the formula>`: prints "preserve_rpath true" or the load error.
# Homebrew reads preserve_rpath from the formula copy in the keg (`<keg>/.brew/jobsearch.rb`), not from the tap.
require "formula"

path = Pathname(ARGV.fetch(0))
begin
  formula = Formulary.respond_to?(:from_path) ? Formulary.from_path(path) : Formulary.factory(path)
  puts "preserve_rpath #{formula.preserve_rpath?}"
rescue FormulaUnavailableError => e
  puts e.message
end
