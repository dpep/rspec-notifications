## Unreleased
- `.with` accepts a matcher (e.g. `a_hash_including`) or a non-hash value, matched against the whole payload, instead of raising `NoMethodError`

## 0.1.0
- initial release
- `emit_notification` matcher for `ActiveSupport::Notifications`
- payload matching via `.with` (partial, nested, embedded matchers)
- count assertions: `.once`, `.twice`, `.exactly`, `.at_least`, `.at_most`
- wildcard and regexp notification names
- `instrument_notification` alias
