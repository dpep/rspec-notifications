rspec-notifications
======
![Gem](https://img.shields.io/gem/dt/rspec-notifications?style=plastic)
[![codecov](https://codecov.io/gh/dpep/rspec-notifications/branch/main/graph/badge.svg)](https://codecov.io/gh/dpep/rspec-notifications)


RSpec matchers for [`ActiveSupport::Notifications`](https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html)

```ruby
require "rspec/notifications"

expect {
  service.call
}.to emit_notification("user.created").with(user_id: user.id).once
```

The matcher subscribes to `ActiveSupport::Notifications` before running the
block and unsubscribes afterward, so there is nothing to set up or tear down.


## Payloads

Match the payload with `.with`. A hash matches partially — only the keys you
name are checked, so extra payload keys are ignored.

```ruby
expect {
  service.call
}.to emit_notification("user.created").with(user_id: user.id)
```

Values can be embedded RSpec matchers. Nested hashes match exactly; use
`a_hash_including` for a nested subset:

```ruby
expect {
  service.call
}.to emit_notification("user.created").with(user_id: kind_of(Integer))

expect {
  service.call
}.to emit_notification("user.created").with(user: a_hash_including(role: "admin"))
```

Pass anything other than a hash — a matcher or a plain value — and it's
matched against the whole payload:

```ruby
expect {
  service.call
}.to emit_notification("user.created").with(a_hash_including(user_id: 1))
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
once. Counts apply to events matching both the name and the payload, and must
be non-negative Integers.


## Names

```ruby
emit_notification("user.created")  # exact
emit_notification(:"user.created") # Symbol, same as the String
emit_notification("user.*")        # wildcard
emit_notification(/user\./)        # regexp
```

`*` matches any characters, dots included, so `"user.*"` also matches
`"user.created.v2"`. Use a `Regexp` when you need tighter control. Any other
name type raises `ArgumentError`.


## Negation

```ruby
expect { service.call }.not_to emit_notification("user.created")
expect { service.call }.not_to emit_notification("user.created").with(role: "admin")
```

Like rspec-mocks, `not_to` refuses a count: `not_to ... .once` raises
`ArgumentError`, since it's unclear whether you mean "never" or "any number
but one". Say the count you expect instead:

```ruby
expect { service.call }.to emit_notification("user.created").twice
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
  are captured too.
- **Mutated payloads** — the payload is captured as a shallow copy. Replacing a
  top-level key after emitting doesn't affect matching, but mutating a nested
  object does (e.g. `instrument("user.updated", user: user)` followed by
  `user.update(...)` in the same block).
- **Two-argument `publish`** — `publish(name, payload)` doesn't follow the
  `(name, started, finished, id, payload)` convention, so the payload isn't
  seen. `instrument`, five-argument `publish`, and `publish_event` all work.


----
## Contributing

Yes please  :)

1. Fork it
1. Create your feature branch (`git checkout -b my-feature`)
1. Ensure the tests pass (`bundle exec rspec`)
1. Commit your changes (`git commit -am 'awesome new feature'`)
1. Push your branch (`git push origin my-feature`)
1. Create a Pull Request
