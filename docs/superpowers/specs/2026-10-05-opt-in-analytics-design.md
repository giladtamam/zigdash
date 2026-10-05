# Opt-in anonymous analytics: design

## Goal

Learn where first-run setup fails and which features get used, without breaking the reason people pick ZigDash: nothing leaves the phone unless they say so. Ships with 2.0. The rules are in [ADR 0006](../../adr/0006-opt-in-anonymous-analytics.md).

## Product decisions

1. **Off by default.** Nothing is started, queued or sent until the user opts in.
2. **Asked once, in the right place.**
   - New installs: an unticked checkbox on the first setup screen, "Share anonymous usage data to help improve setup", with a "What's shared" link. It is asked there because people whose setup fails never reach a dashboard, and setup failure is the first question. Leaving the screen with the box unticked counts as "no", and no later prompt appears.
   - Upgraders (first run already done, never asked): one card at the top of their dashboard, "Help improve ZigDash?", with No thanks and Share buttons and a What's shared link. Shown once. Never on the demo home or in store-capture builds.
   - Settings › About: a "Share anonymous usage data" switch, always available.
3. **Opting out is immediate.** Unsent events are deleted, and nothing more is recorded or sent.
4. **No key, no analytics.** The Aptabase key comes from `--dart-define=ZIGDASH_ANALYTICS_KEY`. Without it (F-Droid and local builds), the SDK is never started and the checkbox, card and switch are hidden.
5. **Aptabase, EU region.** Open source, no device identifiers, data stays in the EU.

## What is sent

Every event carries Aptabase's system properties: OS name and version, locale, app version and build number, a debug flag, and a random session ID that resets after an hour idle. The server also sees the IP address and does not store it (see ADR 0006).

ZigDash sends only these events. Every property value comes from an enum or a bucket, never from text the user typed or a broker sent.

| Event | When | Properties |
|---|---|---|
| `app_started` | Once per launch, after consent | `form`: phone, tablet · `theme`: system, light, dark · `material_you`: on, off · `homes`: 0, 1, 2+ · `tiles`: 0, 1–10, 11–30, 31+ · `demo`: yes, no |
| `setup_step` | Each first-run setup step | `step`: started, scan_found, scan_empty, needs_login, login_rejected, failed, review, complete, manual, demo · `error`: the setup error kind (when failed) · `devices`: 0, 1–5, 6–20, 21+ (at review and complete) |
| `feature_used` | First use of a feature in a session | `feature`: devices_tab, device_page, scenes, edit_mode, wall_display, tile_added · `tile`: the tile's device class or panel type (when tile_added) |

Never sent: broker hosts, ports or credentials, topics, device names, IEEE addresses, home and dashboard names, MQTT payloads, error messages, or last-known values (ADR 0004).

The first-run events are recorded only if the box is ticked before Find my setup is tapped. Events from before consent are dropped, never kept for later.

## Architecture

- `lib/core/analytics/`
  - `analytics_consent.dart`: consent in SharedPreferences (`analytics_consent`: absent means never asked, otherwise true or false), as a Riverpod notifier.
  - `analytics_events.dart`: the event and property enums and buckets above. The only API takes these types, so a free-form string cannot be sent.
  - `analytics.dart`: an `Analytics` interface with `track(AnalyticsEvent)`; `AptabaseAnalytics`, used only when a key is set and consent is on; `NoopAnalytics` otherwise. The provider switches between them when consent changes.
  - `consent_storage.dart`: an Aptabase `StorageManager` that ZigDash owns. On opt-out it deletes every queued event and refuses new ones, because the SDK has no off switch once started.
- The SDK starts lazily, on the first opt-in, with `Aptabase.init(key)`. It is never started for someone who never opts in.
- **Where events come from:** a listener on the setup coordinator's state (`setup_step`), the router and Edit mode for `feature_used`, and the app root for `app_started`.

## Text that changes when this ships (2.0)

- The privacy policy (docs/privacy.md, store/PRIVACY.md), which lists the table above.
- The store description in eight languages: "No ads. No account. Anonymous usage data only if you opt in."
- The Settings privacy subtitle, the README and USER_GUIDE.md.
- **Play Console Data safety (you):** collected, "App interactions" and "Other app performance data", optional, not shared, encrypted in transit, not deletable on request (no identifier to find it by).
- **F-Droid:** built without the key, so no analytics and no tracking anti-feature.

## Tests

- No consent, or no key: the SDK is never started and `track` sends nothing.
- Opt-in starts the SDK. Opting out deletes the queue and blocks new events.
- Leaving the setup welcome screen unticked records "no", and no card appears later.
- The upgrader card shows once. It never shows on the demo home or in store-capture builds.
- Each setup state maps to the right `setup_step`. No event property carries user or broker text: the payload is checked against the enums.
- The checkbox, card and switch are hidden in a build without a key.

## Out of scope

Crash reporting, A/B tests, user IDs, remote config, and analytics on iOS (no iOS release yet).
