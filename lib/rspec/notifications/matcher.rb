module RSpec
  module Notifications
    # RSpec matcher asserting that a block emits an ActiveSupport::Notifications
    # event. See RSpec::Matchers#emit_notification for the public entry point.
    class Matcher
      include RSpec::Matchers::Composable

      def initialize(pattern)
        @pattern = pattern
        @expected_payload = nil
        @count_type = nil
        @count = nil
      end

      # --- chained expectations ------------------------------------------

      def with(payload)
        @expected_payload = payload
        self
      end

      def once
        exactly(1)
      end

      def twice
        exactly(2)
      end

      def exactly(count)
        set_count(:exactly, count)
      end

      def at_least(count)
        set_count(:at_least, count)
      end

      def at_most(count)
        set_count(:at_most, count)
      end

      # syntactic sugar: exactly(n).times
      def times
        self
      end

      # --- matcher protocol ----------------------------------------------

      def matches?(block)
        @events = Subscriber.capture(subscribe_pattern, &block)
        @matching_events = @events.select do |event|
          PayloadMatcher.matches?(@expected_payload, event.payload)
        end

        count_satisfied?(@matching_events.size)
      end

      def does_not_match?(block)
        !matches?(block)
      end

      def supports_block_expectations?
        true
      end

      def description
        desc = "emit #{@pattern.inspect} notification"
        desc += " with payload #{description_of(@expected_payload)}" if @expected_payload
        desc += " #{count_description}" if @count_type
        desc
      end

      def failure_message
        "expected block to #{description}, but #{observed_summary}#{emitted_breakdown}"
      end

      def failure_message_when_negated
        "expected block not to #{description}, but #{observed_summary}#{emitted_breakdown}"
      end

      private

      def set_count(type, count)
        @count_type = type
        @count = count
        self
      end

      # ActiveSupport::Notifications.subscribe natively matches a String exactly
      # or a Regexp via ===. A String containing "*" is treated as a wildcard
      # and converted to an anchored Regexp.
      def subscribe_pattern
        return @pattern unless @pattern.is_a?(String) && @pattern.include?("*")

        segments = @pattern.split("*", -1).map { |segment| Regexp.escape(segment) }
        Regexp.new("\\A#{segments.join(".*")}\\z")
      end

      def count_satisfied?(count)
        case @count_type
        when :exactly  then count == @count
        when :at_least then count >= @count
        when :at_most  then count <= @count
        else count >= 1
        end
      end

      def count_description
        "#{@count_type.to_s.tr("_", " ")} #{pluralize(@count, "time")}"
      end

      def observed_summary
        matched = @matching_events.size

        if @expected_payload && @events.any?
          "#{pluralize(matched, "matching notification")} were emitted " \
            "(#{pluralize(@events.size, "notification")} matched the name)"
        elsif matched.zero?
          "no matching notifications were emitted"
        else
          "it was emitted #{pluralize(matched, "time")}"
        end
      end

      def emitted_breakdown
        return "" if @events.empty?

        lines = @events.map do |event|
          "  - #{event.name.inspect} #{event.payload.inspect}"
        end

        "\nemitted notifications:\n#{lines.join("\n")}"
      end

      def pluralize(count, noun)
        "#{count} #{noun}#{"s" unless count == 1}"
      end
    end
  end
end
