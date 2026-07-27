# ZigDash

Material 3 MQTT dashboard for Android, built for Zigbee2MQTT smart homes.
ZigDash discovers your Zigbee devices automatically — no manual topic wiring —
and controls lights, shutters, switches, and sensors from your phone or a
wall-mounted tablet. No cloud, no ads, no account. Free and open source.

## Features

- **Zigbee2MQTT auto-discovery** — scan your Z2M bridge and create a panel for
  every device with a single tap. JSON-path extraction on every panel.
- **16 panel types** — toggle, button, slider, cover (open/stop/close with
  presets), multi-state, combo, radio, LED indicator, node status, progress,
  text input, text log, scene, schedule, auto-close rule, Z2M discovery.
- **Hub-side automation** — schedules and auto-close rules run as retained MQTT
  config executed by Node-RED on your always-on hub (SMLIGHT, Raspberry Pi, …).
  Your phone can be off; the automation still runs. Bundled Node-RED flows in
  `node-red/`.
- **Any MQTT broker** — TCP, SSL/TLS, WebSocket, WSS. Broker auto-scan on the
  LAN, username/password in hardware-backed secure storage, automatic
  exponential-backoff reconnect, multiple brokers with instant switching.
- **Tailscale support** — secure remote access over your WireGuard mesh, no
  port forwarding.
- **Polished** — Material 3 with Material You dynamic color (Android 12+),
  phone and tablet in both orientations, English and Hebrew (עברית) with full
  RTL, responsive panel grid, dashboard lock, JSON backup/restore.
- **100% private** — no ads, no analytics, no account, no developer server.
  Data lives on your device and your broker.

## Install

- [Google Play](https://play.google.com/store/apps/details?id=com.giladtamam.zigdash)
- F-Droid / IzzyOnDroid / Obtainium: in progress — see `wayfinder/` tickets 08–10.

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
GitLab release pipeline, which attaches signed per-ABI APKs to the release.

## Repository layout

- `lib/` — Flutter app (Riverpod, go_router, Drift, Material 3)
- `node-red/` — bundled Node-RED flows for hub-side automation
- `store/` — Play Store listing copy, screenshots, graphics
- `fastlane/` — supply metadata (F-Droid / IzzyOnDroid read this)
- `wayfinder/` — growth-effort planning map and tickets

## License

[MIT](LICENSE) © 2026 Gilad Tamam
