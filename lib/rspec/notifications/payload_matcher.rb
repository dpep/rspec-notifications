require "rspec/support/fuzzy_matcher"

module RSpec
  module Notifications
    # Matches an expected payload against an actual notification payload.
    #
    # Matching is partial at the top level: only the keys named in +expected+
    # are checked, so unrelated payload keys are ignored. Values are compared
    # with RSpec's fuzzy matching, which supports embedded matchers (e.g.
    # +kind_of(Integer)+), regexps, ranges, and nested structures. Nested
    # hashes are compared exactly -- use +a_hash_including(...)+ for a nested
    # partial match.
    module PayloadMatcher
      module_function

      def matches?(expected, actual)
        return true if expected.nil?
        return false unless actual.is_a?(Hash)

        expected.all? do |key, value|
          actual.key?(key) &&
            RSpec::Support::FuzzyMatcher.values_match?(value, actual.fetch(key))
        end
      end
    end
  end
end
