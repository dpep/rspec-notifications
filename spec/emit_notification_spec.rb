describe "emit_notification" do
  def emit(name, payload = {})
    ActiveSupport::Notifications.instrument(name, payload) {}
  end

  it "matches an emitted notification" do
    expect {
      emit("user.created")
    }.to emit_notification("user.created")
  end

  it "does not match when nothing is emitted" do
    expect {
      # nothing
    }.not_to emit_notification("user.created")
  end

  it "does not match a different notification" do
    expect {
      emit("user.updated")
    }.not_to emit_notification("user.created")
  end

  it "matches regardless of payload when none is expected" do
    expect {
      emit("user.created", user_id: 1, extra: "data")
    }.to emit_notification("user.created")
  end

  it "captures notifications emitted from other threads" do
    expect {
      Thread.new { emit("user.created") }.join
    }.to emit_notification("user.created")
  end

  describe "failure messages" do
    it "explains when nothing matched" do
      expect {
        expect { emit("user.updated") }.to emit_notification("user.created")
      }.to fail_including('emit "user.created" notification')
    end

    it "lists emitted notifications" do
      expect {
        expect {
          emit("user.created", user_id: 2)
        }.to emit_notification("user.created").with(user_id: 1)
      }.to fail_including("emitted notifications:", "user_id")
    end

    it "explains a negated failure" do
      expect {
        expect { emit("user.created") }.not_to emit_notification("user.created")
      }.to fail_including('not to emit "user.created" notification')
    end
  end

  describe ".with" do
    it "matches an exact payload value" do
      expect {
        emit("user.created", user_id: 42)
      }.to emit_notification("user.created").with(user_id: 42)
    end

    it "matches a subset of the payload" do
      expect {
        emit("user.created", user_id: 42, name: "Ada", source: "api")
      }.to emit_notification("user.created").with(user_id: 42)
    end

    it "does not match a differing value" do
      expect {
        emit("user.created", user_id: 42)
      }.not_to emit_notification("user.created").with(user_id: 1)
    end

    it "does not match a missing key" do
      expect {
        emit("user.created", name: "Ada")
      }.not_to emit_notification("user.created").with(user_id: 42)
    end

    it "supports embedded RSpec matchers" do
      expect {
        emit("user.created", user_id: 42)
      }.to emit_notification("user.created").with(user_id: kind_of(Integer))
    end

    it "supports nested hashes" do
      expect {
        emit("user.created", user: { id: 42, role: "admin" })
      }.to emit_notification("user.created").with(user: { id: 42, role: "admin" })
    end

    it "supports matchers nested within a payload" do
      expect {
        emit("user.created", user: { id: 42, role: "admin" })
      }.to emit_notification("user.created").with(user: a_hash_including(id: 42))
    end
  end

  describe "count assertions" do
    it "matches .once" do
      expect {
        emit("user.created")
      }.to emit_notification("user.created").once
    end

    it "fails .once when emitted twice" do
      expect {
        emit("user.created")
        emit("user.created")
      }.not_to emit_notification("user.created").once
    end

    it "matches .twice" do
      expect {
        2.times { emit("user.created") }
      }.to emit_notification("user.created").twice
    end

    it "matches .exactly(n).times" do
      expect {
        3.times { emit("user.created") }
      }.to emit_notification("user.created").exactly(3).times
    end

    it "matches .at_least(n).times" do
      expect {
        3.times { emit("user.created") }
      }.to emit_notification("user.created").at_least(2).times
    end

    it "fails .at_least(n).times when too few" do
      expect {
        emit("user.created")
      }.not_to emit_notification("user.created").at_least(2).times
    end

    it "matches .at_most(n).times" do
      expect {
        emit("user.created")
      }.to emit_notification("user.created").at_most(2).times
    end

    it "fails .at_most(n).times when too many" do
      expect {
        3.times { emit("user.created") }
      }.not_to emit_notification("user.created").at_most(2).times
    end

    it "counts only payload-matching events" do
      expect {
        emit("user.created", user_id: 1)
        emit("user.created", user_id: 2)
      }.to emit_notification("user.created").with(user_id: 1).once
    end
  end

  describe "wildcard names" do
    it "matches a trailing wildcard" do
      expect {
        emit("user.created")
      }.to emit_notification("user.*")
    end

    it "matches any of several names under a wildcard" do
      expect {
        emit("user.created")
        emit("user.updated")
      }.to emit_notification("user.*").twice
    end

    it "does not match outside the wildcard" do
      expect {
        emit("order.created")
      }.not_to emit_notification("user.*")
    end

    it "matches a Regexp" do
      expect {
        emit("user.created")
      }.to emit_notification(/user\./)
    end

    it "treats a plain dot as literal, not a wildcard" do
      expect {
        emit("userXcreated")
      }.not_to emit_notification("user.created")
    end
  end

  describe "captured event data" do
    it "exposes name, payload, timestamps, and transaction id" do
      events = RSpec::Notifications::Subscriber.capture("user.created") do
        emit("user.created", user_id: 7)
      end

      event = events.first
      expect(event.name).to eq "user.created"
      expect(event.payload).to include(user_id: 7)
      expect(event.started).to be_a(Time).or be_a(Float)
      expect(event.finished).to be_a(Time).or be_a(Float)
      expect(event.transaction_id).to be_a(String)
      expect(event.duration).to be >= 0
    end
  end

  describe "aliases" do
    it "supports instrument_notification" do
      expect {
        emit("user.created")
      }.to instrument_notification("user.created")
    end
  end

  describe "edge cases" do
    it "unsubscribes after the block, even on success" do
      before = ActiveSupport::Notifications.notifier.listeners_for("user.created").size

      expect { emit("user.created") }.to emit_notification("user.created")

      after = ActiveSupport::Notifications.notifier.listeners_for("user.created").size
      expect(after).to eq before
    end

    it "unsubscribes when the block raises" do
      before = ActiveSupport::Notifications.notifier.listeners_for("user.created").size

      expect {
        expect { raise "boom" }.to emit_notification("user.created")
      }.to raise_error("boom")

      after = ActiveSupport::Notifications.notifier.listeners_for("user.created").size
      expect(after).to eq before
    end

    it "captures nested notifications independently" do
      expect {
        ActiveSupport::Notifications.instrument("user.created") do
          emit("email.sent")
        end
      }.to emit_notification("email.sent").and emit_notification("user.created")
    end

    it "captures the exception payload when instrumentation fails" do
      events = RSpec::Notifications::Subscriber.capture("user.created") do
        begin
          ActiveSupport::Notifications.instrument("user.created") { raise "boom" }
        rescue RuntimeError
          # swallowed for the assertion below
        end
      end

      expect(events.first.payload).to include(:exception)
    end
  end

  it "is composable with other matchers" do
    expect {
      emit("user.created")
      emit("order.placed")
    }.to emit_notification("user.created").and emit_notification("order.placed")
  end
end
