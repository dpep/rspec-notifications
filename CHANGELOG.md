## Unreleased
- **breaking:** `not_to` with a count (`.once`, `.exactly(n)`, `.at_least(n)`, ...) now raises `ArgumentError`, as in rspec-mocks. It used to mean "not exactly once", so it passed when the notification fired repeatedly. Rewrite these as `to` with the count you expect.
- `.with` accepts a matcher (e.g. `a_hash_including`) or a non-hash value, matched against the whole payload, instead of raising `NoMethodError`
- notification names may be Symbols; any other type (including `nil`, which used to match every event) raises `ArgumentError`
- counts must be non-negative Integers; `exactly("2")` and the like raise `ArgumentError` instead of silently never matching
- using the matcher without a block (`expect(value).to emit_notification(...)`) is reported as unsupported
- fix failure message grammar for a single matching notification
- `.with(nil)` and `.with(false)` are checked against the payload instead of being ignored

## 0.1.0
- initial release
- `emit_notification` matcher for `ActiveSupport::Notifications`
- payload matching via `.with` (partial, nested, embedded matchers)
- count assertions: `.once`, `.twice`, `.exactly`, `.at_least`, `.at_most`
- wildcard and regexp notification names
- `instrument_notification` alias
