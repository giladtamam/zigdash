# ZigDash

**The MQTT dashboard built for Zigbee2MQTT — your smart home dashboard builds itself.**

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-blue.svg)](https://play.google.com/store/apps/details?id=com.giladtamam.zigdash)
[![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B.svg)](https://flutter.dev)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-db61a2.svg)](https://github.com/sponsors/giladtamam)
[![Telegram](https://img.shields.io/badge/Telegram-Join%20the%20community-26A5E4.svg?logo=telegram&logoColor=white)](https://t.me/zigdash_app)
[![Website](https://img.shields.io/badge/Website-zigdash.app-006a6a.svg)](https://zigdash.app)

ZigDash discovers your Zigbee devices automatically — no manual topic wiring —
and controls lights, shutters, switches, and sensors from your phone or a
wall-mounted tablet. No cloud needed, no ads, no account. Free and open source.

Runs great on lean setups (SMLIGHT SMHUB, Raspberry Pi, any MQTT broker) —
no Home Assistant required, though it works alongside it happily: it's just
MQTT.

<p align="center">
  <img src="store/screenshots/01-dashboard.png" width="220" alt="Dashboard">
  <img src="store/screenshots/02-device-controls.png" width="220" alt="Light controls">
  <img src="store/screenshots/03-alerts.png" width="220" alt="Alerts">
  <img src="store/screenshots/04-widgets.png" width="220" alt="Home-screen widgets">
</p>

## Features

- **Zigbee2MQTT auto-discovery** — scan your Z2M bridge and create a panel for
  every device with a single tap. JSON-path extraction on every panel.
- **16 panel types** — toggle, button, slider, cover (open/stop/close with
  presets), multi-state, combo, radio, LED indicator, node status, progress,
  text input, text log, scene, schedule, auto-close rule, Z2M discovery.
- **Readings and gauges** — any sensor value as a tile, as a large number or
  as a half-arc gauge with a min, max and colour bands for good and attention.
- **All shutters at once** — Close, Open and Stop all shutters are ready-made
  scenes in every Home: tap them in the Scenes tab, put one on a dashboard or
  the home screen, and untick a garage door under Which shutters.
- **Alerts** — a leak, smoke, a door opened at night or a low battery: ZigDash
  Engine on your hub watches, ZigDash sets it up in one tap, and the notification
  reaches your phone through Google's push, encrypted end to end — no account,
  no second app, nothing running on the phone. Share a Home's alerts with the
  household through ntfy.
- **Automations** — when a door opens, motion is seen, a button is pressed or a
  time comes (sunrise and sunset too), switch lights, plugs and shutters or run
  a scene, and turn them off again after a while. ZigDash Engine runs them
  inside Zigbee2MQTT on your hub, installed from the app in one tap, so they
  work with your phone off and the internet down. Three per home free,
  unlimited with Pro.
- **Remote control** — with Pro, reach your home from anywhere through
  ZigDash's relay. Your hub and your phones encrypt everything end to end, so
  the relay can't read your devices or what they do. Add the household's
  phones with a QR code. No port forwarding, no VPN, no account.
- **Shortcuts** — Quick Settings tiles switch a light or plug in one tap, or
  open a slider for a shutter; Android's Device Controls show every dashboard
  device as a card with brightness and position sliders; home-screen widgets
  show one device, run a scene, or hold a group of up to five devices and
  three scenes.
- **A first run that helps** — while ZigDash scans, say where Zigbee2MQTT runs
  (Home Assistant, SMLIGHT hub, Pi or Docker). If no broker answers, the scan
  looks for Home Assistant or the Zigbee2MQTT page, names what it found, says
  the one step that is missing and fills in the address for you.
- **Any MQTT broker** — TCP, SSL/TLS, WebSocket, WSS. Broker auto-scan on the
  LAN, username/password in hardware-backed secure storage, automatic
  exponential-backoff reconnect, multiple brokers with instant switching.
- **Tailscale support** — secure remote access over your WireGuard mesh, no
  port forwarding.
- **Polished** — Material 3 with Material You dynamic color (Android 12+),
  phone and tablet in both orientations, eleven languages (English, French,
  German, Spanish, Dutch, Swedish, Norwegian, Russian, Polish, Portuguese,
  Hebrew) with full RTL, responsive panel
  grid, dashboard lock, JSON backup/restore.
- **Kiosk mode** — a tablet on the wall: keep the screen on, hide the bars,
  go fullscreen, and a Kiosk lock with a PIN that keeps guests on the
  dashboards. Optional Android screen pinning on top. When no one touches
  it, the screen dims, shows a big clock, or goes black.
- **Wall tablet extras** — readings under the clock, waking the screen when
  a Zigbee motion sensor sees someone, a night schedule, and alarms that
  fill the screen with a sound on a leak, smoke, gas or CO report. Part of
  ZigDash Pro on Google Play (a one-time purchase, with 7- and 30-day
  history); the GitHub and F-Droid builds have everything.
- **Private** — no ads, no account. Anonymous usage data you can turn off at
  any time; builds without an analytics key (F-Droid, your own) send nothing at all.
  Data lives on your device and your broker; with Remote control, the relay
  only ever holds it encrypted.

## Install

- [Google Play](https://play.google.com/store/apps/details?id=com.giladtamam.zigdash): the way to get ZigDash, with automatic updates.
- Phones without Google Play: APKs on [GitHub Releases](https://github.com/giladtamam/zigdash/releases), published less often.
- F-Droid / IzzyOnDroid / Obtainium: in progress.

## Getting help

Stuck setting up, or something doesn't work? In the app, open **Get help**
(Settings › Help & support, or the link on any setup error). It shows tips
for where you are, then lets you email support with the app's Support
details (no passwords, addresses or device names), or write to
giladtamam1@gmail.com. I usually reply within 3 days, in English or Hebrew.
I'll never ask for your passwords or for remote access.

**Community:** the ZigDash Telegram group, https://t.me/zigdash_app, for questions,
ideas and release news. **Join the ZigDash community** in Settings opens it.

Feature requests, bug reports, and ideas are welcome too — open a
[GitHub issue](https://github.com/giladtamam/zigdash/issues).
Built by a Zigbee2MQTT user, for the Zigbee2MQTT community.

## Sponsor

ZigDash is free, with no ads, and stays that way. If it's useful to you,
you can [sponsor it on GitHub](https://github.com/sponsors/giladtamam). A
[Google Play review](https://play.google.com/store/apps/details?id=com.giladtamam.zigdash)
helps too.

## Build & test

Requires the Flutter SDK (stable channel).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Release APKs (per-ABI):

```bash
flutter build apk --release --split-per-abi
```

Signing uses `android/key.properties` (gitignored). Tags (`vX.Y.Z`) drive the
CI release pipeline, which attaches signed per-ABI APKs to the release.

## Repository layout

- `lib/` — Flutter app (Riverpod, go_router, Drift, Material 3)
- `hub/` — ZigDash Engine, the Zigbee2MQTT extension that runs automations,
  alerts and history on the hub
- `node-red/` — legacy flows, replaced by ZigDash Engine in 3.0
- `store/` — Play Store listing copy, screenshots, graphics
- `fastlane/` — supply metadata (F-Droid / IzzyOnDroid read this)

## License

[MIT](LICENSE) © 2026 Gilad Tamam
