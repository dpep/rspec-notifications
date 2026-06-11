rspec-notifications
======
![Gem](https://img.shields.io/gem/dt/rspec-notifications?style=plastic)
[![codecov](https://codecov.io/gh/dpep/rspec-notifications/branch/main/graph/badge.svg)](https://codecov.io/gh/dpep/rspec-notifications)


RSpec matchers for testing `ActiveSupport::Notifications`.

```ruby
require "rspec/notifications"

expect {
  service.call
}.to emit_notification("user.created")
```

The matcher subscribes to `ActiveSupport::Notifications` before running the
block and unsubscribes afterward, so there is nothing to set up or tear down.


## Payloads

Match the payload with `.with`. Matching is partial — only the keys you name
are checked, so extra payload keys are ignored.

```ruby
expect {
  service.call
}.to emit_notification("user.created").with(user_id: user.id)
```

Values support embedded RSpec matchers, nested hashes, and any composable
matcher:

```ruby
expect {
  service.call
}.to emit_notification("user.created").with(user_id: kind_of(Integer))

# nested hashes match exactly; use a_hash_including for a nested subset
expect {
  service.call
}.to emit_notification("user.created").with(user: a_hash_including(role: "admin"))
```


## Counts

```ruby
expect { service.call }.to emit_notification("user.created").once
expect { service.call }.to emit_notification("user.created").twice
expect { service.call }.to emit_notification("user.created").exactly(3).times
expect { service.call }.to emit_notification("user.created").at_least(2).times
expect { service.call }.to emit_notification("user.created").at_most(2).times
```

Without a count, the matcher passes when the notification is emitted at least
once. Counts apply to events matching both the name and the payload.


## Names

Names can be matched exactly, with a `*` wildcard, or with a `Regexp`:

```ruby
emit_notification("user.created")  # exact
emit_notification("user.*")        # wildcard
emit_notification(/user\./)        # regexp
```


## Negation

```ruby
expect { service.call }.not_to emit_notification("user.created")
```


## Aliases

`instrument_notification` is an alias for `emit_notification`.


## Edge cases

- **Nested notifications** — each instrumented event is captured independently,
  including notifications instrumented within the block of another.
- **Exceptions** — if the block raises, the exception propagates (the matcher
  still unsubscribes). When `ActiveSupport::Notifications.instrument` re-raises,
  it adds `:exception` / `:exception_object` to the payload, which you can match
  on with `.with`.
- **Concurrency** — notifications delivered from other threads during the block
  are captured too; appends are guarded by a mutex.


----
## Contributing

Yes please  :)

1. Fork it
1. Create your feature branch (`git checkout -b my-feature`)
1. Ensure the tests pass (`bundle exec rspec`)
1. Commit your changes (`git commit -am 'awesome new feature'`)
1. Push your branch (`git push origin my-feature`)
1. Create a Pull Request
