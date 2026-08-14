# Reconnect Reliability and Stale-State UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve and clearly mark last-known MQTT values during disconnects, disable unsafe controls, and provide one immediate reconnect action without duplicate clients or subscriptions.

**Architecture:** `MqttManager` tags every received message with a local timestamp and connection generation. A new snapshot provider combines retained per-topic messages with connection status, while `DashboardsScreen` and `PanelTile` provide the shared banner, stale presentation, semantics, and interaction gating.

**Tech Stack:** Flutter, Dart, Riverpod, RxDart, mqtt_client, flutter_test, package:test.

---

## File structure

- Modify `lib/mqtt/mqtt_manager.dart`: connection generation, clock injection, message metadata, captured-generation update listener.
- Modify `test/mqtt/mqtt_manager_connect_test.dart`: generation, receive metadata, immediate reconnect, and resubscription regression tests.
- Modify `lib/features/panels/providers/panel_value_provider.dart`: `PanelValueSnapshot`, freshness derivation, and backwards-compatible value selection.
- Create `test/features/panels/panel_value_snapshot_test.dart`: provider-level fresh/stale/fresh transitions.
- Create `lib/features/dashboards/widgets/connection_status_banner.dart`: the single dashboard connection surface.
- Modify `lib/features/dashboards/screens/dashboards_screen.dart`: render the banner above dashboard content.
- Create `test/features/dashboards/connection_status_banner_test.dart`: banner states and reconnect action.
- Create `lib/features/panels/widgets/panel_reliability_frame.dart`: shared stale marker, semantics, opacity, and control gating.
- Modify `lib/features/panels/widgets/panel_tile.dart`: derive subscribed/publish-only behavior and wrap concrete panels.
- Create `test/features/panels/panel_reliability_frame_test.dart`: stale presentation and interaction behavior.
- Modify `lib/l10n/app_en.arb`, `app_he.arb`, `app_de.arb`, `app_nl.arb`, `app_sv.arb`, `app_nb.arb`, and `app_es.arb`: reliability strings.
- Regenerate `lib/l10n/app_localizations*.dart` with Flutter localization generation.
- Modify `integration_test/setup_flow_test.dart`: real-broker reconnect/resubscribe scenario where the harness can stop/restart its broker.

### Task 1: Timestamp and generation-tag MQTT messages

**Files:**
- Modify: `lib/mqtt/mqtt_manager.dart`
- Modify: `test/mqtt/mqtt_manager_connect_test.dart`

- [x] **Step 1: Write failing metadata and generation tests**

Add focused tests that inject a fixed clock, complete a successful fake connection,
deliver one publish event, and assert the desired API:

```dart
final fixedNow = DateTime.utc(2026, 8, 14, 10);
final manager = MqttManager(
  config: config,
  password: '',
  clientFactory: factory.call,
  now: () => fixedNow,
);

expect(manager.connectionGeneration, 0);
await manager.connect();
expect(manager.connectionGeneration, 1);

final messageFuture = manager.subscribe('zigbee2mqtt/light').first;
client.emitPublish('zigbee2mqtt/light', '{"state":"ON"}');
final message = await messageFuture;

expect(message.receivedAt, fixedNow);
expect(message.connectionGeneration, 1);
```

Add a second test: fail one candidate before succeeding and assert generation is
still `1`, then reconnect successfully and assert `2`. Add a third test that
calls `reconnectNow()` twice while connecting and asserts the factory created
only one new client.

- [x] **Step 2: Run the tests and verify RED**

Run:

```bash
flutter test test/mqtt/mqtt_manager_connect_test.dart
```

Expected: compilation fails because `now`, `connectionGeneration`, `receivedAt`,
and `MqttRxMessage.connectionGeneration` do not exist.

- [x] **Step 3: Implement minimal metadata and generation support**

Change the message and manager APIs to:

```dart
typedef Now = DateTime Function();

class MqttRxMessage {
  const MqttRxMessage({
    required this.topic,
    required this.payload,
    required this.receivedAt,
    required this.connectionGeneration,
  });

  final String topic;
  final String payload;
  final DateTime receivedAt;
  final int connectionGeneration;
}
```

Add `Now? now` to `MqttManager`, default it to `DateTime.now`, and expose:

```dart
final Now _now;
int _connectionGeneration = 0;
int get connectionGeneration => _connectionGeneration;
```

After a client connects successfully, increment generation before subscribing,
capture it in the update listener, and tag fan-out messages:

```dart
final generation = ++_connectionGeneration;
await _updatesSub?.cancel();
_updatesSub = client.updates?.listen(
  (events) => _onUpdates(events, generation),
);
```

```dart
void _onUpdates(
  List<mc.MqttReceivedMessage<mc.MqttMessage>> events,
  int generation,
) {
  for (final event in events) {
    final pub = event.payload;
    if (pub is! mc.MqttPublishMessage) continue;
    final payload = mc.MqttPublishPayload.bytesToStringAsString(
      pub.payload.message,
    );
    _fanOut(MqttRxMessage(
      topic: event.topic,
      payload: payload,
      receivedAt: _now(),
      connectionGeneration: generation,
    ));
  }
}
```

Update `_fanOut` to accept the message object and use `message.topic` for
matching. Preserve the existing reconnect guards.

- [x] **Step 4: Run focused tests and verify GREEN**

Run:

```bash
flutter test test/mqtt/mqtt_manager_connect_test.dart
```

Expected: all MQTT manager connection tests pass.

- [x] **Step 5: Run static analysis on changed files**

Run:

```bash
dart analyze lib/mqtt/mqtt_manager.dart test/mqtt/mqtt_manager_connect_test.dart
```

Expected: no errors or warnings.

### Task 2: Introduce panel value freshness snapshots

**Files:**
- Modify: `lib/features/panels/providers/panel_value_provider.dart`
- Create: `test/features/panels/panel_value_snapshot_test.dart`

- [x] **Step 1: Write failing freshness-model tests**

Define the wished-for pure model first:

```dart
test('current-generation value is fresh only while connected', () {
  final message = MqttRxMessage(
    topic: 'z2m/light',
    payload: '{"state":"ON"}',
    receivedAt: DateTime.utc(2026, 8, 14),
    connectionGeneration: 2,
  );

  expect(
    PanelValueSnapshot.fromMessage(
      message: message,
      value: 'ON',
      status: MqttStatus.connected,
      currentGeneration: 2,
    ).freshness,
    PanelFreshness.fresh,
  );
  expect(
    PanelValueSnapshot.fromMessage(
      message: message,
      value: 'ON',
      status: MqttStatus.reconnecting,
      currentGeneration: 2,
    ).freshness,
    PanelFreshness.stale,
  );
  expect(
    PanelValueSnapshot.fromMessage(
      message: message,
      value: 'ON',
      status: MqttStatus.connected,
      currentGeneration: 3,
    ).freshness,
    PanelFreshness.stale,
  );
});
```

Add provider tests using a fake manager stream for
`unknown -> fresh -> stale -> stale after reconnect -> fresh after new message`.

- [x] **Step 2: Run snapshot tests and verify RED**

Run:

```bash
flutter test test/features/panels/panel_value_snapshot_test.dart
```

Expected: compilation fails because `PanelValueSnapshot`, `PanelFreshness`, and
`panelValueSnapshotProvider` do not exist.

- [x] **Step 3: Implement the snapshot model and provider**

Add:

```dart
enum PanelFreshness { fresh, stale }

class PanelValueSnapshot {
  const PanelValueSnapshot({
    required this.value,
    required this.receivedAt,
    required this.connectionGeneration,
    required this.freshness,
  });

  final Object? value;
  final DateTime receivedAt;
  final int connectionGeneration;
  final PanelFreshness freshness;

  factory PanelValueSnapshot.fromMessage({
    required MqttRxMessage message,
    required Object? value,
    required MqttStatus status,
    required int currentGeneration,
  }) => PanelValueSnapshot(
    value: value,
    receivedAt: message.receivedAt,
    connectionGeneration: message.connectionGeneration,
    freshness: status == MqttStatus.connected &&
            message.connectionGeneration == currentGeneration
        ? PanelFreshness.fresh
        : PanelFreshness.stale,
  );
}
```

Build `panelValueSnapshotProvider` by combining the manager's retained
subscription stream with `status$` via `Rx.combineLatest2`. Extract JSON once in
the mapper. Keep `panelValueProvider` as a compatibility projection:

```dart
final panelValueProvider = Provider.autoDispose
    .family<AsyncValue<Object?>, PanelStreamKey>((ref, key) {
  return ref.watch(panelValueSnapshotProvider(key)).whenData((s) => s.value);
});
```

- [x] **Step 4: Run snapshot and existing panel tests**

Run:

```bash
flutter test test/features/panels/panel_value_snapshot_test.dart test/features/panels
```

Expected: all panel provider/widget tests pass.

- [x] **Step 5: Run static analysis on the provider**

Run:

```bash
dart analyze lib/features/panels/providers/panel_value_provider.dart test/features/panels/panel_value_snapshot_test.dart
```

Expected: no errors or warnings.

### Task 3: Add the single dashboard connection banner

**Files:**
- Create: `lib/features/dashboards/widgets/connection_status_banner.dart`
- Modify: `lib/features/dashboards/screens/dashboards_screen.dart`
- Create: `test/features/dashboards/connection_status_banner_test.dart`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_he.arb`
- Modify: `lib/l10n/app_de.arb`
- Modify: `lib/l10n/app_nl.arb`
- Modify: `lib/l10n/app_sv.arb`
- Modify: `lib/l10n/app_nb.arb`
- Modify: `lib/l10n/app_es.arb`

- [x] **Step 1: Write failing banner widget tests**

Test these cases with injected status and reconnect callback:

```dart
testWidgets('reconnecting shows last-known copy and reconnect action',
    (tester) async {
  var reconnects = 0;
  await tester.pumpWidget(testApp(ConnectionStatusBanner(
    status: MqttStatus.reconnecting,
    onReconnect: () => reconnects++,
  )));

  expect(find.text('Reconnecting…'), findsOneWidget);
  expect(find.text('Showing last known values'), findsOneWidget);
  await tester.tap(find.text('Reconnect now'));
  expect(reconnects, 1);
});
```

Also assert: `connected` renders no banner; `connecting` has no button; `error`
states automatic retries continue; semantics use a live region.

- [x] **Step 2: Run banner tests and verify RED**

Run:

```bash
flutter test test/features/dashboards/connection_status_banner_test.dart
```

Expected: compilation fails because `ConnectionStatusBanner` does not exist.

- [x] **Step 3: Implement banner and dashboard wiring**

Create a stateless banner with this public API:

```dart
class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({
    super.key,
    required this.status,
    required this.onReconnect,
  });

  final MqttStatus status;
  final VoidCallback onReconnect;
}
```

Return `SizedBox.shrink()` for `connected` and `disconnected` (an explicit user
disconnect remains represented by the existing status badge). Use one
`Semantics(liveRegion: true)` Material banner/card for connecting, reconnecting,
and error. In `DashboardsScreen`, watch `connectionStatusProvider(connectionId)`
once, place the banner above the tab content, and call:

```dart
final manager = await ref.read(mqttManagerProvider(connectionId).future);
manager.reconnectNow();
```

Add localized keys: `reliabilityConnecting`, `reliabilityReconnecting`,
`reliabilityLastKnownSubtitle`, `reliabilityConnectionFailed`,
`reliabilityAutomaticRetry`, and `reliabilityReconnectNow` in all seven ARBs.

- [x] **Step 4: Generate localization code**

Run:

```bash
flutter gen-l10n
```

Expected: generated localization classes contain all six reliability getters.

- [x] **Step 5: Run banner and dashboard tests**

Run:

```bash
flutter test test/features/dashboards/connection_status_banner_test.dart test/features/dashboards
```

Expected: all tests pass.

### Task 4: Apply shared stale presentation and control gating

**Files:**
- Create: `lib/features/panels/widgets/panel_reliability_frame.dart`
- Modify: `lib/features/panels/widgets/panel_tile.dart`
- Create: `test/features/panels/panel_reliability_frame_test.dart`
- Modify: `lib/l10n/app_en.arb`
- Modify: the other six locale ARBs listed in Task 3

- [x] **Step 1: Write failing reliability-frame tests**

Use a child button and an outer options callback:

```dart
testWidgets('stale frame blocks control but preserves options gesture',
    (tester) async {
  var controls = 0;
  var options = 0;
  await tester.pumpWidget(testApp(GestureDetector(
    onLongPress: () => options++,
    child: PanelReliabilityFrame(
      stale: true,
      valueLabel: 'Closed',
      child: FilledButton(
        onPressed: () => controls++,
        child: const Text('Open'),
      ),
    ),
  )));

  await tester.tap(find.text('Open'));
  expect(controls, 0);
  await tester.longPress(find.byType(PanelReliabilityFrame));
  expect(options, 1);
  expect(find.text('Last known'), findsOneWidget);
});
```

Also test fresh presentation, read-only stale values, and semantics containing
“last known” and “controls unavailable.” Add a Hebrew `Directionality.rtl`
case asserting the stale chip remains in the logical trailing corner.

- [x] **Step 2: Run frame tests and verify RED**

Run:

```bash
flutter test test/features/panels/panel_reliability_frame_test.dart
```

Expected: compilation fails because `PanelReliabilityFrame` does not exist.

- [x] **Step 3: Implement the frame and panel classification**

Create:

```dart
class PanelReliabilityFrame extends StatelessWidget {
  const PanelReliabilityFrame({
    super.key,
    required this.stale,
    required this.controlsEnabled,
    required this.child,
    this.valueLabel,
  });

  final bool stale;
  final bool controlsEnabled;
  final String? valueLabel;
  final Widget child;
}
```

Render a `Stack` with the child inside `AbsorbPointer(absorbing:
!controlsEnabled)` and `AnimatedOpacity`; place a compact **Last known** chip in
the top trailing corner when stale. Put the frame inside `PanelTile`'s existing
outer long-press `GestureDetector`, preserving local options.

In `PanelTile`, classify:

```dart
const subscribedInteractive = {
  PanelType.toggle,
  PanelType.slider,
  PanelType.multiState,
  PanelType.combo,
  PanelType.radio,
  PanelType.cover,
};
const publishOnly = {
  PanelType.button,
  PanelType.textInput,
  PanelType.scene,
  PanelType.schedule,
};
```

Read-only subscribed panels show stale state without an interaction gate.
Subscribed interactive panels enable only for a fresh snapshot. Publish-only
panels enable whenever status is connected. `autoClose` remains locally
editable but its broker-publish action follows connected status.

Add localized keys `reliabilityLastKnown` and
`reliabilityControlsUnavailable` in all locale ARBs and regenerate l10n.

- [x] **Step 4: Run frame and panel tests**

Run:

```bash
flutter test test/features/panels/panel_reliability_frame_test.dart test/features/panels
```

Expected: all tests pass, including existing panel behavior.

Confirm these UI-only providers depend solely on local MQTT/Riverpod state;
they must not introduce HTTP, analytics, telemetry, or logging dependencies.

- [x] **Step 5: Run static analysis for UI changes**

Run:

```bash
dart analyze lib/features/dashboards lib/features/panels test/features/dashboards test/features/panels
```

Expected: no errors or warnings.

### Task 5: Verify lifecycle and real-broker recovery

**Files:**
- Modify: `test/core/app_lifecycle_reconnector_test.dart`
- Modify: `bin/smoke.dart`
- Verify unchanged: `integration_test/setup_flow_test.dart`

- [x] **Step 1: Add failing lifecycle idempotence test**

Add a test that resumes while the manager status is `connecting` and asserts the
fake manager's client factory count does not increase.

- [x] **Step 2: Run lifecycle test and verify its result**

Run:

```bash
flutter test test/core/app_lifecycle_reconnector_test.dart
```

Expected before any needed fix: the new test either fails on an observed
duplicate attempt or passes because the existing `reconnectNow()` guard already
satisfies the requirement. If it passes immediately, keep it as characterization
coverage and make no production change.

- [x] **Step 3: Extend the real-broker integration scenario**

After the setup creates a dashboard, drive a harness-controlled broker outage:

```dart
await broker.stop();
await pumpUntil(tester, find.text('Reconnecting…'));
expect(find.text('Last known'), findsWidgets);

await broker.start();
await pumpUntilGone(tester, find.text('Reconnecting…'));
broker.publishRetained('zigbee2mqtt/test_light', '{"state":"OFF"}');
await pumpUntilGone(tester, find.text('Last known'));
```

The current device test uses an external broker and has no process-control API.
Keep its happy-path test unchanged. Add the outage/restart sequence to
`bin/smoke.dart`, where the developer can stop and restart the external broker
between printed checkpoints, and retain the exact device matrix in the design
document. Do not add process-control hooks to production app code.

- [x] **Step 4: Run all unit/widget tests**

Run:

```bash
flutter test
```

Expected: all tests pass.

- [x] **Step 5: Run full static analysis**

Run:

```bash
flutter analyze
```

Expected: no errors. The two existing `avoid_print` info findings in
`bin/proto_probe.dart` may remain unless this work removes them in a separate
mechanical cleanup.

- [ ] **Step 6: Run the real-broker test when the harness is available** — Not
  run: no controllable broker/device was available.

Run:

```bash
flutter test integration_test/setup_flow_test.dart -d DEVICE
```

Expected: setup succeeds, outage shows stale state, restart reconnects once,
and a new retained message restores freshness without duplicate deliveries.

### Task 6: Release metadata, review, and commit

**Files:**
- Modify: `pubspec.yaml`
- Modify: `docs/superpowers/plans/2026-08-14-reconnect-reliability.md`

- [ ] **Step 1: Bump the patch version**

Change:

```yaml
version: 1.9.1+20
```

- [ ] **Step 2: Re-run verification after the version change**

Run:

```bash
flutter test
flutter analyze
git diff --check
```

Expected: tests pass, analysis has no errors, and diff check is clean.

- [ ] **Step 3: Perform code review**

Use the repository code-review skill against commit `9cb6173`, checking both
the design spec and repository standards. Fix every confirmed issue and rerun
the affected tests.

- [ ] **Step 4: Commit the implementation**

```bash
git add docs/superpowers/plans/2026-08-14-reconnect-reliability.md \
  lib test integration_test pubspec.yaml
git commit -m "feat: add reconnect reliability UX"
```

- [ ] **Step 5: Verify the committed tree**

Run:

```bash
git status --short
git show --stat --oneline HEAD
```

Expected: clean worktree and a commit containing only v1.9.1 reliability work.
