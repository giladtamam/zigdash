# ZigDash

Material 3 mobile MQTT dashboard, optimised for Zigbee2MQTT control. Per the
[public artifact spec](https://claude.ai/public/artifacts/ca51124e-8311-4b7c-8840-fcd1665f80d0).

## Status

Phases 1–3 of the implementation plan are complete:

- **Phase 1 — Foundation**: M3 theme with dynamic colour (Android 12+), go_router
  shell with three tabs (Brokers / Dashboards / Settings), Drift database
  scaffold, build_runner codegen pipeline.
- **Phase 2 — Connections**: Drift `Connections` table with a `MqttProtocol` enum
  column; CRUD via `ConnectionDao` and `ConnectionRepo`; add/edit form with
  validation and an advanced section; passwords stored in
  `flutter_secure_storage`, never in SQLite.
- **Phase 3 — MQTT Manager**: `MqttManager` with full lifecycle, exponential
  backoff reconnect (1s → 2min cap), ref-counted topic subscriptions multiplexed
  over a single wire subscription per pattern, `{value}`-template publish,
  `topicMatches` for `+` / `#` wildcards. Riverpod providers expose one
  auto-disposed manager per `connectionId` and a status stream that drives the
  connection-list badge.

Phases 4+ (dashboards, panel widgets, JSON-path, backup/restore, etc.) are not
implemented. See `~/.claude/plans/glistening-bouncing-wigderson.md` for the full
plan.

## Project layout

```
lib/
├── app.dart                         MaterialApp.router + DynamicColorBuilder
├── main.dart                        runApp(ProviderScope(child: ZigDashApp()))
├── core/
│   ├── router/{routes,app_router}.dart
│   ├── theme/app_theme.dart
│   ├── storage/secure_storage.dart  flutter_secure_storage wrapper + provider
│   └── utils/uuid.dart              Uuid().v7() helper
├── data/
│   ├── database/
│   │   ├── database.dart            @DriftDatabase(tables: [Connections])
│   │   ├── tables/connections.dart  schema
│   │   └── daos/connection_dao.dart watch / get / upsert / delete
│   └── repositories/connection_repo.dart
├── mqtt/
│   ├── topic_matcher.dart           pure-Dart wildcard matcher
│   ├── mqtt_status.dart             enum
│   ├── mqtt_manager.dart            manager + ref-counted subs + auto-reconnect
│   └── providers/mqtt_manager_provider.dart
└── features/
    ├── connections/
    │   ├── screens/
    │   │   ├── connections_list_screen.dart
    │   │   └── connection_form_screen.dart
    │   └── widgets/{connection_tile,status_badge,protocol_dropdown}.dart
    ├── dashboards/screens/dashboards_placeholder.dart
    └── settings/screens/settings_placeholder.dart

test/mqtt/topic_matcher_test.dart    11 unit tests, all passing
```

## Build & test

Requires the Flutter SDK installed natively in WSL Ubuntu (see Setup below; not
the Windows-side Flutter — it has CRLF wrappers that fail under WSL bash and its
pub deps no longer resolve).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze          # passes clean
flutter test             # 11/11 pass
```

Keep codegen running in a side terminal while editing:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Setup notes

If you're cloning this fresh into WSL:

```bash
# Apt prereqs (unzip is required by `flutter precache`; libsecret only matters
# if you ever target Linux desktop — we explicitly disable it).
sudo apt install -y unzip xz-utils zip libglu1-mesa

# Flutter SDK on the stable channel.
mkdir -p ~/development && cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
echo 'if [ -d "$HOME/development/flutter/bin" ]; then PATH="$HOME/development/flutter/bin:$PATH"; fi' >> ~/.profile
source ~/.profile
flutter --disable-analytics
flutter config --no-enable-linux-desktop --no-enable-web --no-enable-windows-desktop

# inotify limit — required for build_runner watch under WSL.
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

## Running the app

The app targets Android and iOS only — Linux/web/Windows desktop are disabled by
design (`flutter_secure_storage` v10 needs `libsecret` + a keyring daemon, which
headless WSL doesn't have).

**Recommended dev path:** install Android Studio on the **Windows** side, run an
AVD emulator there, then `adb connect <windows-ip>:5555` from WSL. The WSL
Flutter only needs `platform-tools` + `cmdline-tools`. Alternatively pass a
physical device over USB with `usbipd`.

```bash
flutter devices          # confirm a device is visible
flutter run              # or `flutter run --release` for the optimised build
```

## End-to-end verification recipe

Phase 3 is "code complete" — runtime verification needs a broker and a device.
Once both are available:

```bash
# Local broker exposed on all interfaces so an emulator/device can reach it
mkdir -p /tmp/mosq && cat > /tmp/mosq/mosquitto.conf <<'EOF'
listener 1883 0.0.0.0
allow_anonymous true
listener 9001 0.0.0.0
protocol websockets
EOF
docker run --rm -d --name mosq -p 1883:1883 -p 9001:9001 \
  -v /tmp/mosq/mosquitto.conf:/mosquitto/config/mosquitto.conf \
  eclipse-mosquitto:2

ip -4 addr show eth0 | awk '/inet /{print $2}' | cut -d/ -f1   # WSL IP
```

1. Launch the app, add a connection with `host = <WSL IP>`, `port = 1883`,
   protocol TCP, no credentials, `autoConnect = on`.
2. The tile badge should go grey → amber → green within ~1s. Toggle airplane
   mode; badge goes amber, exponential backoff visible, returns to green.
3. `docker exec mosq mosquitto_sub -t '$SYS/broker/clientsConnected' -v` should
   show a live client count of 1.

## Architectural notes

- **Codegen:** Drift, freezed, and json_serializable all run through
  build_runner. Riverpod codegen is **not** used — the package graph has a hard
  conflict between `analyzer 7.x` (required by build_runner) and
  `analyzer_plugin 0.12.0` (required transitively by `riverpod_generator` via
  `custom_lint_core`). Manual `Provider` / `StreamProvider` syntax is just as
  ergonomic at this scope and avoids the conflict.

- **Reconnect strategy:** `MqttManager` owns auto-reconnect itself
  (`autoReconnect = false` on the underlying `MqttServerClient`). Backoff
  doubles from 1s up to a 2-minute cap and resets on a successful CONNACK.
  Re-subscribes to all known patterns after reconnect.

- **Subscription multiplexing:** every `subscribe(pattern)` call increments a
  ref-count and returns a broadcast stream filtered by `topicMatches`. The wire
  SUBSCRIBE only goes out on first watcher per pattern; UNSUBSCRIBE only fires
  when the last watcher releases. Single fan-out listener on
  `client.updates` matches each received topic against every known pattern.

- **Status badge:** the connection tile only watches the live status stream
  when `autoConnect = true` (otherwise listing 100 brokers would dial all 100).
  Manual "connect now" affordance lands with Phase 4 dashboards.
