## Unreleased
- `.with` accepts a matcher (e.g. `a_hash_including`) or a non-hash value, matched against the whole payload, instead of raising `NoMethodError`
- notification names may be Symbols; any other type (including `nil`, which used to match every event) raises `ArgumentError`
- counts must be non-negative Integers; `exactly("2")` and the like raise `ArgumentError` instead of silently never matching
- using the matcher without a block (`expect(value).to emit_notification(...)`) is reported as unsupported

## 0.1.0
- initial release
- `emit_notification` matcher for `ActiveSupport::Notifications`
- payload matching via `.with` (partial, nested, embedded matchers)
- count assertions: `.once`, `.twice`, `.exactly`, `.at_least`, `.at_most`
- wildcard and regexp notification names
- `instrument_notification` alias
