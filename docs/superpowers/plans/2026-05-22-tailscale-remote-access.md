# Local-first Remote Access via Tailscale — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a connection fall back from its LAN host to an optional Tailscale "remote host" automatically, so the smart home is controllable both at home (direct LAN) and away.

**Architecture:** Add one nullable `remoteHost` per connection. A pure `endpointCandidates()` helper turns a `BrokerConfig` into an ordered list `[local(short timeout), remote(standard timeout)]`. `MqttManager.connect()` loops the candidates, keeping the first that connects, and exposes which endpoint won so the UI can show "Connected · Remote".

**Tech Stack:** Flutter + Riverpod, Drift (sqlite), `mqtt_client`, `flutter gen-l10n`. Commands run in WSL: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && <cmd>"`. Edit/read via `\\wsl.localhost\Ubuntu\home\gilad\projects\zigdash\...`. Work on branch `feat/tailscale-remote`.

Spec: `docs/superpowers/specs/2026-05-22-tailscale-remote-access-design.md`

---

## File structure

**New:**
- `lib/mqtt/endpoint.dart` — `MqttEndpoint` enum + `endpointCandidates()` (pure).
- `test/mqtt/endpoint_test.dart` — unit tests for the candidate builder.
- `test/data/connection_repo_remote_host_test.dart` — repo round-trip for `remoteHost`.
- `test/features/connections/status_badge_test.dart` — badge label per endpoint.
- `docs/tailscale-remote.md` — SMHUB + phone Tailscale setup guide.

**Modified:**
- `lib/mqtt/broker_config.dart` — add `remoteHost`.
- `lib/data/database/tables/connections.dart` — add `remoteHost` column.
- `lib/data/database/database.dart` — schemaVersion 3→4 + migration.
- `lib/data/repositories/connection_repo.dart` — `remoteHost` on create/update.
- `lib/mqtt/client_factory.dart`, `client_factory_io.dart`, `client_factory_web.dart` — optional `host` override.
- `lib/mqtt/mqtt_manager.dart` — candidate-loop connect + `endpoint$`.
- `lib/mqtt/providers/mqtt_manager_provider.dart` — map `remoteHost`; add `connectionEndpointProvider`.
- `lib/features/connections/widgets/status_badge.dart` — optional `endpoint`, "· Remote" label.
- `lib/features/connections/widgets/connection_tile.dart` — pass endpoint to badge.
- `lib/features/connections/screens/connection_form_screen.dart` — "Local host" relabel + "Remote host" field.
- `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb` — new keys.

---

## Task 1: `BrokerConfig.remoteHost` + endpoint candidate builder (pure, TDD)

**Files:**
- Modify: `lib/mqtt/broker_config.dart`
- Create: `lib/mqtt/endpoint.dart`
- Test: `test/mqtt/endpoint_test.dart`

- [ ] **Step 1: Add `remoteHost` to `BrokerConfig`.** In `lib/mqtt/broker_config.dart`, add the constructor param and field:

```dart
  const BrokerConfig({
    required this.id,
    required this.host,
    required this.port,
    required this.protocol,
    this.username,
    this.keepAliveSeconds = 60,
    this.remoteHost,
  });

  final String id;
  final String host;
  final int port;
  final MqttProtocol protocol;
  final String? username;
  final int keepAliveSeconds;

  /// Optional fallback address (e.g. a Tailscale MagicDNS name) tried after
  /// [host] is unreachable. Reuses [port], [protocol], and credentials.
  final String? remoteHost;
```

- [ ] **Step 2: Write the failing test.** Create `test/mqtt/endpoint_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/endpoint.dart';

BrokerConfig _cfg({String? remoteHost}) => BrokerConfig(
      id: 'x',
      host: '192.168.7.210',
      port: 1883,
      protocol: MqttProtocol.tcp,
      remoteHost: remoteHost,
    );

void main() {
  test('no remote host -> single local candidate with standard timeout', () {
    final c = endpointCandidates(_cfg());
    expect(c.length, 1);
    expect(c[0].kind, MqttEndpoint.local);
    expect(c[0].host, '192.168.7.210');
    expect(c[0].timeoutMs, standardConnectTimeoutMs);
  });

  test('remote host -> local first (short timeout) then remote (standard)', () {
    final c = endpointCandidates(_cfg(remoteHost: 'smhub.tailnet.ts.net'));
    expect(c.map((e) => e.kind).toList(), [MqttEndpoint.local, MqttEndpoint.remote]);
    expect(c[0].host, '192.168.7.210');
    expect(c[0].timeoutMs, localProbeTimeoutMs);
    expect(c[1].host, 'smhub.tailnet.ts.net');
    expect(c[1].timeoutMs, standardConnectTimeoutMs);
  });

  test('whitespace-only remote host is treated as none', () {
    final c = endpointCandidates(_cfg(remoteHost: '   '));
    expect(c.length, 1);
    expect(c[0].kind, MqttEndpoint.local);
  });
}
```

- [ ] **Step 3: Run it — expect FAIL** (undefined `endpoint.dart`):
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/mqtt/endpoint_test.dart"`
Expected: compile error / FAIL (endpointCandidates not defined).

- [ ] **Step 4: Create `lib/mqtt/endpoint.dart`:**

```dart
import 'broker_config.dart';

/// Which address a live MQTT connection is using.
enum MqttEndpoint { local, remote }

/// One ordered connect attempt: a host and the timeout to give it.
typedef MqttCandidate = ({MqttEndpoint kind, String host, int timeoutMs});

/// Short probe for the LAN host when a remote fallback exists — fail fast so we
/// can try the remote address quickly when away from home.
const int localProbeTimeoutMs = 3000;

/// Normal connect timeout (matches the previous single-host behavior).
const int standardConnectTimeoutMs = 5000;

/// Local-first ordered candidates for [config]. With a remote host set, the LAN
/// host is tried first with a short timeout, then the remote host. Without one,
/// a single local candidate with the standard timeout (unchanged behavior).
List<MqttCandidate> endpointCandidates(BrokerConfig config) {
  final remote = config.remoteHost?.trim();
  if (remote == null || remote.isEmpty) {
    return [
      (kind: MqttEndpoint.local, host: config.host, timeoutMs: standardConnectTimeoutMs),
    ];
  }
  return [
    (kind: MqttEndpoint.local, host: config.host, timeoutMs: localProbeTimeoutMs),
    (kind: MqttEndpoint.remote, host: remote, timeoutMs: standardConnectTimeoutMs),
  ];
}
```

- [ ] **Step 5: Run it — expect PASS (3 tests).**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/mqtt/endpoint_test.dart"`

- [ ] **Step 6: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(mqtt): BrokerConfig.remoteHost + endpointCandidates (local-first)'"
```

---

## Task 2: Drift `remoteHost` column + migration (schema v4)

**Files:**
- Modify: `lib/data/database/tables/connections.dart`
- Modify: `lib/data/database/database.dart`

- [ ] **Step 1: Add the column.** In `lib/data/database/tables/connections.dart`, add after the `homeDashboardId` line:

```dart
  TextColumn get homeDashboardId => text().nullable()();
  TextColumn get remoteHost => text().nullable()();
```

- [ ] **Step 2: Bump schema + migration.** In `lib/data/database/database.dart`, change `schemaVersion` to `4` and add a `from < 4` clause:

```dart
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(dashboards);
            await m.createTable(panels);
          }
          if (from < 3) {
            await m.addColumn(panels, panels.topicPrefixOverride);
          }
          if (from < 4) {
            await m.addColumn(connections, connections.remoteHost);
          }
        },
      );
```

- [ ] **Step 3: Regenerate Drift code.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -3"`
Expected: "Succeeded" with `database.g.dart` regenerated (now has `remoteHost`).

- [ ] **Step 4: Analyze.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter analyze 2>&1 | tail -2"`
Expected: No issues found.

- [ ] **Step 5: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(db): add Connections.remoteHost column (schema v4 + migration)'"
```

---

## Task 3: Thread `remoteHost` through repo + manager provider (TDD round-trip)

**Files:**
- Modify: `lib/data/repositories/connection_repo.dart`
- Modify: `lib/mqtt/providers/mqtt_manager_provider.dart`
- Test: `test/data/connection_repo_remote_host_test.dart`

- [ ] **Step 1: Write the failing test.** Create `test/data/connection_repo_remote_host_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/storage/secure_storage.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';

/// In-memory SecureStore stub (no platform channel in unit tests).
class _MemSecure implements SecureStore {
  final _m = <String, String>{};
  @override
  Future<void> writePassword(String id, String pw) async => _m[id] = pw;
  @override
  Future<String?> readPassword(String id) async => _m[id];
  @override
  Future<void> deletePassword(String id) async => _m.remove(id);
}

void main() {
  test('create + read back persists remoteHost', () async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ConnectionRepo(ConnectionDao(db), _MemSecure());

    final id = await repo.create(
      name: 'home',
      host: '192.168.7.210',
      port: 1883,
      protocol: MqttProtocol.tcp,
      remoteHost: 'smhub.tailnet.ts.net',
    );

    final row = await repo.getById(id);
    expect(row!.remoteHost, 'smhub.tailnet.ts.net');
  });

  test('null remoteHost stays null', () async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ConnectionRepo(ConnectionDao(db), _MemSecure());

    final id = await repo.create(
      name: 'home',
      host: '192.168.7.210',
      port: 1883,
      protocol: MqttProtocol.tcp,
    );
    final row = await repo.getById(id);
    expect(row!.remoteHost, isNull);
  });
}
```

> NOTE: If `SecureStore` has more members than the three above, the analyzer will flag the stub — add the missing members as no-ops. Confirm the interface first: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && sed -n '1,60p' lib/core/storage/secure_storage.dart"`.

- [ ] **Step 2: Run it — expect FAIL** (`remoteHost` not a named param of `create`).
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/data/connection_repo_remote_host_test.dart"`

- [ ] **Step 3: Add `remoteHost` to `create`.** In `lib/data/repositories/connection_repo.dart`, add the param and companion value:

```dart
  Future<String> create({
    required String name,
    required String host,
    required int port,
    required MqttProtocol protocol,
    String? username,
    String? password,
    int keepAliveSeconds = 60,
    bool autoConnect = false,
    String? remoteHost,
  }) async {
    final id = newId();
    final now = DateTime.now();
    await _dao.insertRow(ConnectionsCompanion.insert(
      id: id,
      name: name,
      host: host,
      port: port,
      protocol: protocol,
      username: Value(username),
      keepAliveSeconds: Value(keepAliveSeconds),
      autoConnect: Value(autoConnect),
      remoteHost: Value(remoteHost),
      createdAt: now,
      updatedAt: now,
    ));
    if (password != null && password.isNotEmpty) {
      await _secure.writePassword(id, password);
    }
    return id;
  }
```

- [ ] **Step 4: Add `remoteHost` to `update`.** Same file, add the param and companion value:

```dart
  Future<void> update({
    required String id,
    required String name,
    required String host,
    required int port,
    required MqttProtocol protocol,
    String? username,
    String? password,
    int keepAliveSeconds = 60,
    bool autoConnect = false,
    String? remoteHost,
  }) async {
    await _dao.updateById(
      id,
      ConnectionsCompanion(
        name: Value(name),
        host: Value(host),
        port: Value(port),
        protocol: Value(protocol),
        username: Value(username),
        keepAliveSeconds: Value(keepAliveSeconds),
        autoConnect: Value(autoConnect),
        remoteHost: Value(remoteHost),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (password != null) {
      if (password.isEmpty) {
        await _secure.deletePassword(id);
      } else {
        await _secure.writePassword(id, password);
      }
    }
  }
```

- [ ] **Step 5: Map `remoteHost` into `BrokerConfig`.** In `lib/mqtt/providers/mqtt_manager_provider.dart`, add the field in the `BrokerConfig(...)` constructor:

```dart
    config: BrokerConfig(
      id: conn.id,
      host: conn.host,
      port: conn.port,
      protocol: conn.protocol,
      username: conn.username,
      keepAliveSeconds: conn.keepAliveSeconds,
      remoteHost: conn.remoteHost,
    ),
```

- [ ] **Step 6: Run the test — expect PASS (2 tests) — then analyze.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/data/connection_repo_remote_host_test.dart && flutter analyze 2>&1 | tail -2"`

- [ ] **Step 7: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(connections): persist + map remoteHost through repo and manager'"
```

---

## Task 4: Host override in the client factory

**Files:**
- Modify: `lib/mqtt/client_factory.dart`
- Modify: `lib/mqtt/client_factory_io.dart`
- Modify: `lib/mqtt/client_factory_web.dart`

- [ ] **Step 1: Add optional `host` to the public factory.** In `lib/mqtt/client_factory.dart`, change `buildMqttClient`:

```dart
mc.MqttClient buildMqttClient(BrokerConfig config, String clientId, {String? host}) {
  return impl.buildPlatformClient(config, clientId, host: host);
}
```

- [ ] **Step 2: Use it in the IO impl.** In `lib/mqtt/client_factory_io.dart`:

```dart
mc.MqttClient buildPlatformClient(BrokerConfig config, String clientId, {String? host}) {
  final client = MqttServerClient.withPort(host ?? config.host, clientId, config.port);
  client.secure = isSecureProtocol(config.protocol);
  if (isWebSocketProtocol(config.protocol)) {
    client.useWebSocket = true;
    client.websocketProtocols = ['mqtt'];
  }
  return client;
}
```

- [ ] **Step 3: Use it in the web impl.** In `lib/mqtt/client_factory_web.dart`:

```dart
mc.MqttClient buildPlatformClient(BrokerConfig config, String clientId, {String? host}) {
  if (!isWebSocketProtocol(config.protocol)) {
    throw UnsupportedError(
      'Browsers cannot open raw TCP. Choose WS or WSS protocol for web targets. '
      'Got: ${config.protocol.name} on ${config.host}:${config.port}.',
    );
  }
  final scheme = config.protocol == MqttProtocol.wss ? 'wss' : 'ws';
  final client = MqttBrowserClient.withPort(
    '$scheme://${host ?? config.host}',
    clientId,
    config.port,
  );
  client.websocketProtocols = ['mqtt'];
  return client;
}
```

- [ ] **Step 4: Analyze + commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter analyze 2>&1 | tail -2 && git add -A && git commit -m 'feat(mqtt): optional host override in client factory'"
```

---

## Task 5: `MqttManager` candidate-loop connect + `endpoint$`

**Files:**
- Modify: `lib/mqtt/mqtt_manager.dart`

- [ ] **Step 1: Import endpoint + add endpoint state.** At the top of `lib/mqtt/mqtt_manager.dart` add the import next to the others:

```dart
import 'endpoint.dart';
```

Then, just after the `_status` declaration (around line 59-60), add:

```dart
  final _endpoint = BehaviorSubject<MqttEndpoint?>.seeded(null);
  Stream<MqttEndpoint?> get endpoint$ => _endpoint.stream;
  MqttEndpoint? get activeEndpoint => _endpoint.valueOrNull;

  void _emitEndpoint(MqttEndpoint? e) {
    if (_disposed || _endpoint.isClosed) return;
    _endpoint.add(e);
  }
```

- [ ] **Step 2: Replace `connect()` with the candidate loop.** Replace the entire existing `Future<void> connect() async { ... }` method (lines ~80-133) with:

```dart
  Future<void> connect() async {
    if (_disposed) return;
    _userInitiatedDisconnect = false;
    if (_status.value == MqttStatus.connecting || _status.value == MqttStatus.connected) return;
    _emit(MqttStatus.connecting);
    _emitEndpoint(null);

    for (final cand in endpointCandidates(config)) {
      final mc.MqttClient client;
      try {
        client = _buildClient(cand.host, cand.timeoutMs);
      } on UnsupportedError {
        // Configuration mismatch (e.g. TCP requested in a browser) — not
        // transient, and the fallback host shares the same protocol, so abort
        // entirely without scheduling a reconnect.
        _emit(MqttStatus.error);
        return;
      } catch (_) {
        continue; // transient build failure — try the next candidate
      }
      if (_disposed) {
        client.disconnect();
        return;
      }
      _client = client;

      try {
        await client.connect(config.username, password);
      } on Exception {
        client.disconnect();
        continue; // unreachable / refused — try the next candidate
      }
      if (_disposed) {
        client.disconnect();
        return;
      }
      if (client.connectionStatus?.state != mc.MqttConnectionState.connected) {
        client.disconnect();
        continue;
      }

      // Connected on this candidate.
      _emitEndpoint(cand.kind);
      _backoffMs = _initialBackoffMs;
      await _updatesSub?.cancel();
      _updatesSub = client.updates?.listen(_onUpdates);
      for (final pattern in _subs.keys) {
        client.subscribe(pattern, mc.MqttQos.atLeastOnce);
      }
      _emit(MqttStatus.connected);
      return;
    }

    // All candidates failed.
    _emit(MqttStatus.error);
    _scheduleReconnect();
  }
```

- [ ] **Step 3: Make `_buildClient` take host + timeout.** Replace the existing `mc.MqttClient _buildClient() { ... }` (lines ~219-234) with:

```dart
  mc.MqttClient _buildClient(String host, int timeoutMs) {
    final client = buildMqttClient(config, _clientId, host: host);
    client.logging(on: false);
    // Stay on mqtt_client's default protocol (MQTT 3.1, ProtocolName=MQIsdp).
    // The Mosquitto build on SMLIGHT SMHUB silently disconnects 3.1.1
    // CONNECT packets with "protocol error" — even though they're spec-valid.
    client.keepAlivePeriod = config.keepAliveSeconds;
    client.connectTimeoutPeriod = timeoutMs; // ms; per-candidate (LAN probe vs standard)
    client.autoReconnect = false; // we manage reconnects ourselves
    client.onDisconnected = _onDisconnected;
    client.connectionMessage = mc.MqttConnectMessage()
        .withClientIdentifier(_clientId)
        .startClean()
        .withWillQos(mc.MqttQos.atLeastOnce);
    return client;
  }
```

- [ ] **Step 4: Clear endpoint on user disconnect + close the subject in dispose.** In `disconnect()` add `_emitEndpoint(null);` just before `_emit(MqttStatus.disconnected);`:

```dart
    _client = null;
    _emitEndpoint(null);
    _emit(MqttStatus.disconnected);
  }
```

In `dispose()`, close the new subject — change the tail of `dispose()` to:

```dart
    _subs.clear();
    await _endpoint.close();
    await _status.close();
  }
```

> NOTE: `_onDisconnected` already routes unexpected drops to `reconnecting` → `_scheduleReconnect()` → `connect()`, which re-runs `endpointCandidates` from the LAN host first. No change needed there.

- [ ] **Step 5: Analyze + run the existing MQTT/unit suite (no regressions).**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter analyze 2>&1 | tail -2 && flutter test test/mqtt/ test/features/panels/ 2>&1 | tail -2"`
Expected: No issues; all tests pass.

- [ ] **Step 6: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(mqtt): local-first fallback connect + endpoint\$ stream'"
```

---

## Task 6: Endpoint provider + StatusBadge "· Remote" (TDD widget test)

**Files:**
- Modify: `lib/mqtt/providers/mqtt_manager_provider.dart`
- Modify: `lib/features/connections/widgets/status_badge.dart`
- Modify: `lib/features/connections/widgets/connection_tile.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb`
- Test: `test/features/connections/status_badge_test.dart`

- [ ] **Step 1: Add ARB key (EN).** In `lib/l10n/app_en.arb`, after the existing `"statusError": "Error"` entry (add a comma to it), insert:

```json
  "statusError": "Error",
  "statusConnectedRemote": "Connected · Remote"
```

- [ ] **Step 2: Add ARB key (HE).** In `lib/l10n/app_he.arb`, after `"statusError": "שגיאה"` (add a comma):

```json
  "statusError": "שגיאה",
  "statusConnectedRemote": "מחובר · מרחוק"
```

- [ ] **Step 3: gen-l10n.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter gen-l10n 2>&1 | tail -2"`

- [ ] **Step 4: Write the failing widget test.** Create `test/features/connections/status_badge_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/connections/widgets/status_badge.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/endpoint.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('connected via remote shows "Connected · Remote"', (tester) async {
    await tester.pumpWidget(_wrap(
      const StatusBadge(status: MqttStatus.connected, endpoint: MqttEndpoint.remote),
    ));
    expect(find.text('Connected · Remote'), findsOneWidget);
  });

  testWidgets('connected via local shows plain "Connected"', (tester) async {
    await tester.pumpWidget(_wrap(
      const StatusBadge(status: MqttStatus.connected, endpoint: MqttEndpoint.local),
    ));
    expect(find.text('Connected'), findsOneWidget);
  });

  testWidgets('disconnected ignores endpoint', (tester) async {
    await tester.pumpWidget(_wrap(
      const StatusBadge(status: MqttStatus.disconnected, endpoint: MqttEndpoint.remote),
    ));
    expect(find.text('Disconnected'), findsOneWidget);
  });
}
```

- [ ] **Step 5: Run it — expect FAIL** (`endpoint` not a param of `StatusBadge`).
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/features/connections/status_badge_test.dart"`

- [ ] **Step 6: Add `endpoint` to `StatusBadge`.** In `lib/features/connections/widgets/status_badge.dart`, add the import, the field, and a connected-remote branch. Update the constructor and `_label`:

```dart
import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../mqtt/endpoint.dart';
import '../../../mqtt/mqtt_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.endpoint});
  final MqttStatus status;
  final MqttEndpoint? endpoint;
```

Then in `_label(BuildContext context)`, change the `connected` case to honor the endpoint:

```dart
      case MqttStatus.connected:
        return endpoint == MqttEndpoint.remote
            ? l10n.statusConnectedRemote
            : l10n.statusConnected;
```

- [ ] **Step 7: Run the test — expect PASS (3 tests).**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/features/connections/status_badge_test.dart"`

- [ ] **Step 8: Add `connectionEndpointProvider`.** In `lib/mqtt/providers/mqtt_manager_provider.dart`, add the import at the top:

```dart
import '../endpoint.dart';
```

and append after `connectionStatusProvider`:

```dart
/// Live active-endpoint stream for a connection (null until connected).
final connectionEndpointProvider =
    StreamProvider.family<MqttEndpoint?, String>((ref, connectionId) async* {
  final managerAsync = ref.watch(mqttManagerProvider(connectionId));
  yield* managerAsync.when(
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
    data: (mgr) => mgr.endpoint$,
  );
});
```

- [ ] **Step 9: Pass endpoint into the badge.** In `lib/features/connections/widgets/connection_tile.dart`, just before the `return` of `build` (after the existing `status` computation, near line 26-33), add:

```dart
    final endpoint = connection.autoConnect
        ? ref.watch(connectionEndpointProvider(connection.id)).maybeWhen(
              data: (e) => e,
              orElse: () => null,
            )
        : null;
```

and change the badge usage (line ~62):

```dart
            StatusBadge(status: status, endpoint: endpoint),
```

- [ ] **Step 10: gen-l10n, analyze, run the badge test + suite.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter gen-l10n && flutter analyze 2>&1 | tail -2 && flutter test test/features/connections/ 2>&1 | tail -2"`

- [ ] **Step 11: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(connections): show Connected · Remote when on the fallback endpoint'"
```

---

## Task 7: Connection form — "Local host" relabel + "Remote host" field

**Files:**
- Modify: `lib/features/connections/screens/connection_form_screen.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb`

- [ ] **Step 1: Add ARB keys (EN).** In `lib/l10n/app_en.arb`, after `"connHostHint": "192.168.1.10",` add:

```json
  "connLocalHost": "Local host",
  "connRemoteHost": "Remote host (Tailscale)",
  "connRemoteHostHint": "Used when the local host can't be reached, e.g. smhub.tailnet.ts.net"
```

- [ ] **Step 2: Add ARB keys (HE).** In `lib/l10n/app_he.arb`, after the matching `connHostHint` line add:

```json
  "connLocalHost": "מארח מקומי",
  "connRemoteHost": "מארח מרוחק (Tailscale)",
  "connRemoteHostHint": "בשימוש כשהמארח המקומי אינו זמין, למשל smhub.tailnet.ts.net"
```

- [ ] **Step 3: gen-l10n.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter gen-l10n 2>&1 | tail -2"`

- [ ] **Step 4: Add the controller + load it.** In `connection_form_screen.dart`:
  - Near the other controllers (line ~23) add: `final _remoteHost = TextEditingController();`
  - In the load block where `_host.text = c.host;` is set (line ~54) add: `_remoteHost.text = c.remoteHost ?? '';`
  - In `dispose()` (after `_host.dispose();`) add: `_remoteHost.dispose();`

- [ ] **Step 5: Relabel the local host field.** Change line ~157 from:

```dart
                    decoration: InputDecoration(labelText: context.l10n.connHost, hintText: context.l10n.connHostHint),
```
to:
```dart
                    decoration: InputDecoration(labelText: context.l10n.connLocalHost, hintText: context.l10n.connHostHint),
```

- [ ] **Step 6: Add the Remote host field under Advanced.** In the `ExpansionTile` (`children:` starts ~line 200), add this as the FIRST child, before the keep-alive `TextFormField`:

```dart
              children: [
                TextFormField(
                  controller: _remoteHost,
                  decoration: InputDecoration(
                    labelText: context.l10n.connRemoteHost,
                    hintText: context.l10n.connRemoteHostHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _keepAlive,
```

- [ ] **Step 7: Pass remoteHost on save.** In `_save()`, add `remoteHost:` to BOTH the `repo.update(...)` and `repo.create(...)` calls (after the `autoConnect:` line in each):

```dart
          autoConnect: _autoConnect,
          remoteHost: _remoteHost.text.trim().isEmpty ? null : _remoteHost.text.trim(),
```

- [ ] **Step 8: Analyze + run full suite.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter gen-l10n && flutter analyze 2>&1 | tail -2 && flutter test 2>&1 | tail -2"`
Expected: No issues; all tests pass.

- [ ] **Step 9: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(connections): Local host relabel + optional Remote host (Tailscale) field'"
```

---

## Task 8: Tailscale setup guide (SMHUB + phone)

**Files:**
- Create: `docs/tailscale-remote.md`

- [ ] **Step 1: Write the guide.** Create `docs/tailscale-remote.md`:

```markdown
# Remote access with Tailscale

ZigDash connects to your MQTT broker over the LAN. To control your home while
away, add a **Tailscale** address as the connection's *Remote host* — ZigDash
uses the LAN address at home and falls back to the Tailscale address when away.

## 1. Install Tailscale on the broker host (SMHUB / Linux)

    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up

Sign in with your account. Then in the Tailscale admin console
(https://login.tailscale.com/admin/machines):
- Enable **MagicDNS** (DNS tab) so the host gets a name.
- Note the machine's name → e.g. `smhub.tailnet-xxxx.ts.net`.

The Mosquitto broker already listens on `0.0.0.0:1883`, so no broker change is
needed — it's reachable on the Tailscale IP/name automatically.

## 2. Install Tailscale on the phone

Install the Tailscale app, sign into the **same** account/tailnet, and leave it
running (it sits idle until needed).

## 3. Configure ZigDash

Edit the connection → **Advanced** → **Remote host (Tailscale)** → enter the
MagicDNS name (e.g. `smhub.tailnet-xxxx.ts.net`). Leave Local host as your LAN
address (e.g. `192.168.7.210`). Port, protocol, and credentials are shared.

Now ZigDash tries the LAN first (instant at home) and falls back to Tailscale
when you're away. The status chip shows **Connected · Remote** when on the
fallback.

## Security note

The LAN leg is plain MQTT on your home network (unchanged). The remote leg is
encrypted end-to-end by Tailscale (WireGuard), so no broker TLS/auth change is
required.

## Optional: lock it down

Use Tailscale ACLs/tags so only your own devices can reach the broker host.
```

- [ ] **Step 2: Commit.**
```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'docs: Tailscale remote-access setup guide'"
```

---

## Task 9: Final verification (analyze, full test, on-device)

- [ ] **Step 1: Analyze + full test suite.**
`wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter gen-l10n && flutter analyze 2>&1 | tail -2 && flutter test 2>&1 | tail -3"`
Expected: "No issues found!" and "All tests passed!" (prior suite + the 3 new test files).

- [ ] **Step 2: On-device verification (REQUIRED SUB-SKILL: superpowers:verification-before-completion).**
  1. `tool/build_release.sh apk` (or `flutter build apk --debug`), install on the device.
  2. Edit the `home` connection → Advanced → set **Remote host** to the SMHUB MagicDNS name. Save.
  3. **At home (same Wi-Fi):** open it — connects, status shows plain **Connected** (LAN). Toggle a real device to confirm control.
  4. **Away (Wi-Fi off / cellular, Tailscale on):** open it — after the ~3s LAN probe it falls back; status shows **Connected · Remote**. Toggle a real device to confirm remote control end-to-end.
  5. Switch back to Wi-Fi and reconnect → returns to plain **Connected** (LAN-first).

- [ ] **Step 3: Finish the branch (REQUIRED SUB-SKILL: superpowers:finishing-a-development-branch).**

---

## Self-review notes (author)

- **Spec coverage:** data model (T2), `BrokerConfig`+candidates (T1), repo/provider threading (T3), client-factory host override (T4), local-first fallback connect + `endpoint$` (T5), "Connected · Remote" UI (T6), form Local/Remote host (T7), Tailscale infra doc (T8), tests + device verification (T1/T3/T6/T9). All spec sections map to a task.
- **Type consistency:** `MqttEndpoint{local,remote}`, `endpointCandidates()` returning `({kind,host,timeoutMs})`, `MqttManager.endpoint$`/`activeEndpoint`, `connectionEndpointProvider`, `BrokerConfig.remoteHost`, `Connections.remoteHost`, `repo.create/update(remoteHost:)`, ARB keys `statusConnectedRemote`/`connLocalHost`/`connRemoteHost`/`connRemoteHostHint` are used identically across tasks.
- **Known assumptions:** `SecureStore` interface has exactly the 3 members stubbed in T3 — Step 1's NOTE tells the implementer to verify and extend if not. The `connection_tile` only watches the endpoint when `autoConnect` is true (matches how it watches status today).
- **Translations** are first-pass; gilad (native Hebrew) should review the new ARB keys.
```
