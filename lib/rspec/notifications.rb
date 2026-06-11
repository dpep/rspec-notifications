require "active_support/isolated_execution_state"
require "active_support/notifications"
require "rspec/expectations"

require_relative "notifications/version"
require_relative "notifications/subscriber"
require_relative "notifications/payload_matcher"
require_relative "notifications/matcher"

module RSpec
  module Matchers
    # Asserts that the block emits a matching ActiveSupport::Notifications event.
    #
    #   expect { service.call }.to emit_notification("user.created")
    #   expect { service.call }.to emit_notification("user.created").with(user_id: 1)
    #   expect { service.call }.to emit_notification("user.created").twice
    #   expect { service.call }.to emit_notification("user.*")
    #   expect { service.call }.to emit_notification(/user\./)
    #
    # +pattern+ may be an exact String, a String with "*" wildcards, or a Regexp.
    def emit_notification(pattern)
      RSpec::Notifications::Matcher.new(pattern)
    end

    alias_method :instrument_notification, :emit_notification
  end
end
