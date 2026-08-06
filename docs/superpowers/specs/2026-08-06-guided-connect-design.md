# Guided Connect Flow — Design (v1.9)

**Status**: spec (ready for implementation)
**Date**: 2026-08-06
**Source**: wayfinder ticket `11-decide-v19-feature-roadmap` (decision: v1.9 = Activation slice), [Product growth levers research](../wayfinder/research/product-growth-levers.md) §2.

## Problem Statement

Connecting ZigDash to a Zigbee2MQTT broker is the make-or-break moment for new users (NNGroup:
connection setup is the make-or-break moment for smart-device apps; the silent killer is
"connection OK but 0 devices"). Today the connection form offers a single binary test — a snackbar
saying "connected" or "failed" with no indication of *where* it failed. Users must know the Z2M
defaults (host, port, base topic) by heart, and when a connection fails they get no path to fix it.
The community launch (wayfinder ticket 07) is about to drive first-time users here — this flow is
what converts them.

## Solution

A guided connect wizard that walks a user from zero to "my devices are visible":

1. **Z2M default preset** — one tap pre-fills the standard Zigbee2MQTT setup (host `localhost`,
   port `1883`, protocol `tcp`, base topic `zigbee2mqtt`, no credentials); editable, with the
   existing LAN broker-scan offered for brokers on other machines (Pi/SMLIGHT).
2. **Per-step diagnostic ladder** — the connection attempt is broken into visible steps —
   **resolve → TCP → MQTT CONNACK → auth → devices** — each reporting pass/fail with a
   plain-language, localized fix suggestion. A hung broker times out per-step instead of wedging.
3. **Post-discovery success moment** — on connect, the app counts discovered devices and shows
   "Found N devices" (with a taste of device names). Zero devices is *not* a silent pass: it is
   flagged explicitly, with a "start pairing" (`permit_join`) action.

On success the connection saves automatically (autoConnect on) and the user lands on their
dashboard. On failure the failing step is shown inline with a retry.

## User Stories

1. As a new user with Zigbee2MQTT on the same machine, I want to connect by accepting a preset
   (`localhost:1883`, base `zigbee2mqtt`), so that I don't need to know broker details by heart.
2. As a new user with Zigbee2MQTT on another device (Pi/SMLIGHT), I want the LAN broker scan from
   the wizard, so that I don't type an IP address.
3. As a user, I want every connection attempt to show each step — resolve, TCP, MQTT handshake,
   auth, devices — with pass/fail states, so that I know exactly where a failure happens.
4. As a user, when a step fails, I want a plain-language fix for that step (e.g. "is
   Zigbee2MQTT running?", "check the hostname", "wrong username or password"), so that I can fix
   it myself without forum help.
5. As a user with a successful connection, I want a "Found N devices" screen, so that I know my
   devices are actually visible to the app.
6. As a user with a successful connection but zero devices found, I want the app to say so
   explicitly and offer to start pairing, so that a "connected but empty" state never looks like
   success.
7. As a user, I want the wizard to save the connection and land me on my dashboard when it
   succeeds, so that I'm immediately productive.
8. As a returning user, I want to reach the wizard from the connections list, so that I can set up
   additional brokers the same way.
9. As a user who already uses the manual connection form, I want it to keep working and gain the
   same diagnostic ladder, so that nothing regresses and I get better failure detail too.
10. As a user, I want each step to have its own timeout, so that a hung or black-holed broker
    doesn't wedge the wizard.
11. As a user with credentials, I want "auth rejected" distinguished from "server unreachable",
    so that I know whether to fix credentials or networking.
12. As a user with a non-default Z2M setup, I want the preset pre-filled but fully editable
    (host, port, protocol, base topic, credentials), so that non-standard installs still work.
13. As a user with a remote broker via Tailscale, I want the remote-host fallback exercised and
    reported by the ladder, so that the fallback path isn't a mystery.
14. As a user, I want to retry the ladder after a failure, so that transient failures are
    recoverable without re-entering the form.
15. As a user, I want to cancel or skip the wizard at any point, so that I can fall back to the
    manual form.
16. As a user, when the broker connects but device discovery is slow, I want "connected — still
    discovering devices" rather than a hard failure, so that slow bridges don't look broken.
17. As a user of any supported locale, I want every new string translated in all six locales
    (en, he, de, nl, sv, nb, es), so that the flow doesn't break localization.
18. As a developer, I want each ladder step to be unit-testable with a fake MQTT client, so that
    every failure path is covered without real sockets.

## Implementation Decisions

- **New module: guided-connect wizard** — screens + provider, reached from the connections list;
  the onboarding flow's final page gains a "connect your broker" CTA but keeps its existing
  demo/skip paths unchanged.
- **New `ConnectDiagnostics` service** — drives the ladder **resolve → tcp → connack → auth →
  devices** through the existing injectable client factory (`buildMqttClient`); `MqttManager`
  itself is untouched. Each step emits a status (pass / fail / timeout) and a localized detail
  key. `auth` maps to the MQTT CONNACK return code (0 vs 4/5). The `devices` step subscribes to
  `$base/#` for a bounded window and counts distinct device topics.
- **Z2M preset** — pre-fills host `localhost`, port `1883`, protocol `tcp`, base `zigbee2mqtt`,
  empty credentials; all fields editable. Off-box brokers get the existing broker-scan sheet.
- **Success screen consumes the existing `devicesProvider`** (`connectionId`, `base`) — no new
  seam; zero-device case renders a "no devices found" state with a `permit_join` pairing CTA
  (existing `z2m_bridge.dart` request builder). Device count comes from the same stream the
  devices screen already uses.
- **On success**: persist the connection via the connection repository with `autoConnect` on, then
  navigate to the dashboard. On failure: inline step states with retry; never a bare snackbar.
- **Base topic stays a flow parameter** (default `zigbee2mqtt`), consistent with the existing
  scenes/discovery screens; **no schema change** to the connections table.
- **Localization**: all new strings added to every locale ARB (l10n is the established convention;
  the v1.8 i18n batch set the quality bar — metadata blocks mirrored, `gen-l10n` must pass).

## Testing Decisions

- **What makes a good test here**: external behavior only — the ladder's reported steps and the
  wizard's rendered states — driven through a fake MQTT client; never real sockets, never
  implementation details of the ladder.
- **Modules under test**:
  - `ConnectDiagnostics` unit tests — fake client that fails at each step in turn (resolve, TCP,
    CONNACK, auth-reject codes 4/5, timeout), asserting the reported step, status, and detail key.
  - Wizard widget tests — preset pre-fill and editability, step progression rendering, success
    screen device count, zero-device CTA, error + retry, cancel/skip, remote-host fallback path.
  - Connection-form regression tests — the manual form keeps its existing behavior with the
    ladder integrated.
- **Prior art**: `test/mqtt/mqtt_manager_connect_test.dart` (fake client via `buildMqttClient`
  injection), `test/features/connections/connection_form_screen_test.dart`,
  `test/features/onboarding/onboarding_screen_test.dart`. Integration coverage via the existing
  `integration_test/` harness for the happy path only.

## Out of Scope

- Home-screen widgets and quick-settings tiles (v1.10 — wayfinder ticket 11 decision).
- Kiosk / wall-tablet mode and room groups (v1.11).
- Generic non-Z2M broker onboarding — existing manual form remains the path.
- Live-Z2M browser/web connect (CORS — explicitly ruled out in research).
- Cloud sync, push notifications, monetization.
- Native-speaker translation pass (mechanical l10n addition only).
- Connection-health dashboard visuals.

## Further Notes

- **Activation metric**: guided-connect completion is the "activated" signal; the Play Console
  cohort baseline (D1/D7/D30) is established as a standing practice before the community launch
  (ticket 11) — this flow is what the launch traffic converts through.
- The zero-device case is the highest-value state in this feature: NNGroup's silent killer is
  "connection OK but 0 devices", and a visible "pair your first device" call-to-action directly
  answers it.
- The existing onboarding demo mode is unaffected; the wizard is additive.
