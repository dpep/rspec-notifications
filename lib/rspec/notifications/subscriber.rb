module RSpec
  module Notifications
    # Subscribes to ActiveSupport::Notifications for the duration of a block,
    # capturing every matching event, then unsubscribes.
    #
    # Thread-safe: notifications may be delivered from threads other than the
    # one running the block, so appends are guarded by a mutex.
    class Subscriber
      Event = Struct.new(
        :name,
        :payload,
        :started,
        :finished,
        :transaction_id,
        keyword_init: true,
      ) do
        # Duration in milliseconds, when both timestamps are available.
        def duration
          return unless started && finished

          (finished - started) * 1_000.0
        end
      end

      # Subscribe to +pattern+, run +block+, and return the captured events.
      def self.capture(pattern, &block)
        new(pattern).capture(&block)
      end

      def initialize(pattern)
        @pattern = pattern
        @events = []
        @mutex = Mutex.new
      end

      def capture
        subscription = subscribe
        yield
        @mutex.synchronize { @events.dup }
      ensure
        ActiveSupport::Notifications.unsubscribe(subscription) if subscription
      end

      private

      def subscribe
        # A 5-arity block opts into the "timed" subscriber, which yields the
        # start and finish times along with the transaction id and payload.
        ActiveSupport::Notifications.subscribe(@pattern) do |name, started, finished, id, payload|
          event = Event.new(
            name: name,
            payload: payload.dup,
            started: started,
            finished: finished,
            transaction_id: id,
          )

          @mutex.synchronize { @events << event }
        end
      end
    end
  end
end
