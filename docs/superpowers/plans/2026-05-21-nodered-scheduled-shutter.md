# Node-RED Scheduled Shutter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "Schedule" panel type to ZigDash that configures a daily open/close shutter automation executed on the always-on SMHUB by a generic Node-RED flow, communicated entirely over retained MQTT.

**Architecture:** ZigDash publishes a *retained* JSON config to `zigdash/automation/schedule/<panelId>/config`. A generic Node-RED flow (core nodes only, 60s tick) subscribes, fires the shutter `target` topic at the configured times, and publishes status to `…/state` plus an online heartbeat to `zigdash/automation/bridge/state`. The new panel type is additive — `PanelType` is a `textEnum`, so no Drift migration is needed; schedule settings live in the existing `config` JSON column and the shutter target reuses the existing `topic` + dashboard-prefix mechanism.

**Tech Stack:** Flutter + Riverpod + Drift + `mqtt_client` (Dart); Node-RED (core nodes) on the SMHUB; Mosquitto broker at `192.168.7.210:1883`.

Spec: `docs/superpowers/specs/2026-05-21-nodered-scheduled-automation-design.md`

---

## File structure

**New files:**
- `lib/features/panels/services/automation_config_publisher.dart` — builds the config/state/bridge topics + retained payload; publishes via `MqttManager`. Single responsibility: ZigDash↔Node-RED MQTT contract.
- `lib/features/panels/widgets/schedule_panel.dart` — dashboard tile: open/close times, enable switch, next-action + offline chip.
- `node-red/scheduled-shutter-flow.json` — importable generic scheduler flow.
- `node-red/README.md` — one-time import instructions.
- `test/features/panels/schedule_config_test.dart` — `ScheduleConfig` round-trip.
- `test/features/panels/automation_config_publisher_test.dart` — topic + payload builders.

**Modified files:**
- `lib/data/database/tables/panels.dart` — add `PanelType.schedule`.
- `lib/features/panels/models/panel_config.dart` — `ScheduleConfig` + `decode`/`defaultFor`.
- `lib/mqtt/mqtt_manager.dart` — add `isConnected` getter.
- `lib/features/panels/widgets/panel_tile.dart` — dispatcher case → `SchedulePanel`.
- `lib/features/panels/screens/panel_form_screen.dart` — schedule fields, save-time config publish.
- `lib/features/dashboards/screens/dashboards_screen.dart` — picker entry; delete tombstone.

---

## Task 1: `ScheduleConfig` model

**Files:**
- Modify: `lib/features/panels/models/panel_config.dart`
- Test: `test/features/panels/schedule_config_test.dart`

This task does NOT add the `PanelType.schedule` enum value yet (that breaks exhaustive switches across the app — handled in Task 4). The test constructs `ScheduleConfig` directly, so it compiles and passes in isolation.

- [ ] **Step 1: Write the failing test**

Create `test/features/panels/schedule_config_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

void main() {
  group('ScheduleConfig', () {
    test('defaults match the spec', () {
      const c = ScheduleConfig();
      expect(c.openTime, '07:00');
      expect(c.closeTime, '19:00');
      expect(c.openPayload, '{"state":"OPEN"}');
      expect(c.closePayload, '{"state":"CLOSE"}');
      expect(c.enabled, isTrue);
    });

    test('toJson/fromJson round-trips', () {
      const c = ScheduleConfig(
        openTime: '06:30',
        closeTime: '21:15',
        openPayload: '{"state":"OPEN"}',
        closePayload: '{"state":"CLOSE"}',
        enabled: false,
      );
      final back = ScheduleConfig.fromJson(c.toJson());
      expect(back.openTime, '06:30');
      expect(back.closeTime, '21:15');
      expect(back.enabled, isFalse);
    });

    test('fromJson tolerates missing keys', () {
      final c = ScheduleConfig.fromJson(<String, dynamic>{});
      expect(c.openTime, '07:00');
      expect(c.enabled, isTrue);
    });

    test('copyWith flips only enabled', () {
      const c = ScheduleConfig(openTime: '08:00');
      final off = c.copyWith(enabled: false);
      expect(off.enabled, isFalse);
      expect(off.openTime, '08:00');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/features/panels/schedule_config_test.dart"`
Expected: FAIL — `ScheduleConfig` is not defined.

- [ ] **Step 3: Add `ScheduleConfig` to `panel_config.dart`**

Append this class to `lib/features/panels/models/panel_config.dart` (after `TextLogConfig`):

```dart
/// Configures a server-side daily open/close schedule executed by the
/// Node-RED scheduler flow on the SMHUB. ZigDash publishes this (plus the
/// composed target topic) as retained MQTT config — it never runs the
/// schedule itself. Times are "HH:mm" in the SMHUB's local time.
class ScheduleConfig extends PanelConfig {
  const ScheduleConfig({
    this.openTime = '07:00',
    this.closeTime = '19:00',
    this.openPayload = '{"state":"OPEN"}',
    this.closePayload = '{"state":"CLOSE"}',
    this.enabled = true,
  });

  final String openTime;
  final String closeTime;
  final String openPayload;
  final String closePayload;
  final bool enabled;

  ScheduleConfig copyWith({bool? enabled}) => ScheduleConfig(
        openTime: openTime,
        closeTime: closeTime,
        openPayload: openPayload,
        closePayload: closePayload,
        enabled: enabled ?? this.enabled,
      );

  @override
  Map<String, dynamic> toJson() => {
        'openTime': openTime,
        'closeTime': closeTime,
        'openPayload': openPayload,
        'closePayload': closePayload,
        'enabled': enabled,
      };

  static ScheduleConfig fromJson(Map<String, dynamic> j) => ScheduleConfig(
        openTime: j['openTime'] as String? ?? '07:00',
        closeTime: j['closeTime'] as String? ?? '19:00',
        openPayload: j['openPayload'] as String? ?? '{"state":"OPEN"}',
        closePayload: j['closePayload'] as String? ?? '{"state":"CLOSE"}',
        enabled: j['enabled'] as bool? ?? true,
      );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/features/panels/schedule_config_test.dart"`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add lib/features/panels/models/panel_config.dart test/features/panels/schedule_config_test.dart && git commit -m 'feat(schedule): add ScheduleConfig model'"
```

---

## Task 2: `AutomationConfigPublisher` + `MqttManager.isConnected`

**Files:**
- Create: `lib/features/panels/services/automation_config_publisher.dart`
- Modify: `lib/mqtt/mqtt_manager.dart`
- Test: `test/features/panels/automation_config_publisher_test.dart`

The publisher's topic/payload builders are static + pure → unit-tested without MQTT. The publish/clear methods need a live manager and are exercised in Task 7 (device).

- [ ] **Step 1: Write the failing test**

Create `test/features/panels/automation_config_publisher_test.dart`:

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/services/automation_config_publisher.dart';

void main() {
  group('AutomationConfigPublisher builders', () {
    test('config/state topics are keyed by panel id', () {
      expect(AutomationConfigPublisher.configTopic('abc'),
          'zigdash/automation/schedule/abc/config');
      expect(AutomationConfigPublisher.stateTopic('abc'),
          'zigdash/automation/schedule/abc/state');
      expect(AutomationConfigPublisher.bridgeStateTopic,
          'zigdash/automation/bridge/state');
    });

    test('buildPayload emits the wire contract', () {
      const cfg = ScheduleConfig(openTime: '06:30', closeTime: '20:00');
      final raw = AutomationConfigPublisher.buildPayload(
        name: 'Living-room shutter',
        target: 'zigbee2mqtt/living_shutter/set',
        config: cfg,
      );
      final j = json.decode(raw) as Map<String, dynamic>;
      expect(j['name'], 'Living-room shutter');
      expect(j['target'], 'zigbee2mqtt/living_shutter/set');
      expect(j['openTime'], '06:30');
      expect(j['closeTime'], '20:00');
      expect(j['openPayload'], '{"state":"OPEN"}');
      expect(j['enabled'], true);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/features/panels/automation_config_publisher_test.dart"`
Expected: FAIL — `AutomationConfigPublisher` not defined.

- [ ] **Step 3: Add `isConnected` to `MqttManager`**

In `lib/mqtt/mqtt_manager.dart`, immediately after the existing `Stream<MqttStatus> get status$ => _status.stream;` line, add:

```dart
  /// True only when the underlying client has a live connection — used by
  /// callers (e.g. AutomationConfigPublisher) that need to know whether a
  /// retained publish will actually reach the broker right now.
  bool get isConnected =>
      _client?.connectionStatus?.state == mc.MqttConnectionState.connected;
```

(`_client` and the `mc` import already exist in this file.)

- [ ] **Step 4: Create the publisher**

Create `lib/features/panels/services/automation_config_publisher.dart`:

```dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/panel_config.dart';

/// Owns the ZigDash<->Node-RED MQTT contract for scheduled automations.
/// ZigDash writes a retained config the always-on Node-RED flow consumes;
/// it never executes the schedule itself.
class AutomationConfigPublisher {
  AutomationConfigPublisher(this._ref);
  final Ref _ref;

  static String configTopic(String panelId) =>
      'zigdash/automation/schedule/$panelId/config';

  static String stateTopic(String panelId) =>
      'zigdash/automation/schedule/$panelId/state';

  static const String bridgeStateTopic = 'zigdash/automation/bridge/state';

  /// The retained JSON the Node-RED flow expects.
  static String buildPayload({
    required String name,
    required String target,
    required ScheduleConfig config,
  }) =>
      json.encode({
        'name': name,
        'target': target,
        'openTime': config.openTime,
        'closeTime': config.closeTime,
        'openPayload': config.openPayload,
        'closePayload': config.closePayload,
        'enabled': config.enabled,
      });

  /// Publishes the retained config. Returns false if the broker isn't
  /// connected (caller can surface a hint). The heartbeat chip on the
  /// panel is the real "is it running" safety net.
  Future<bool> publishConfig({
    required String connectionId,
    required String panelId,
    required String name,
    required String target,
    required ScheduleConfig config,
  }) async {
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (!mgr.isConnected) return false;
    mgr.publish(
      configTopic(panelId),
      buildPayload(name: name, target: target, config: config),
      '',
      qos: mc.MqttQos.atLeastOnce,
      retain: true,
    );
    return true;
  }

  /// Tombstone: clears the retained config so the flow drops the schedule.
  Future<void> clearConfig({
    required String connectionId,
    required String panelId,
  }) async {
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (!mgr.isConnected) return;
    mgr.publish(configTopic(panelId), '', '', retain: true);
  }
}

final automationConfigPublisherProvider = Provider<AutomationConfigPublisher>(
  (ref) => AutomationConfigPublisher(ref),
);
```

- [ ] **Step 5: Run test + analyze**

Run: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter test test/features/panels/automation_config_publisher_test.dart && flutter analyze"`
Expected: tests PASS (2); analyze: No issues found.

- [ ] **Step 6: Commit**

```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add lib/features/panels/services/automation_config_publisher.dart lib/mqtt/mqtt_manager.dart test/features/panels/automation_config_publisher_test.dart && git commit -m 'feat(schedule): AutomationConfigPublisher + MqttManager.isConnected'"
```

---

## Task 3: `SchedulePanel` widget

**Files:**
- Create: `lib/features/panels/widgets/schedule_panel.dart`

No test step — it's a Riverpod widget verified on-device in Task 7. It compiles standalone (unused until Task 4 wires the dispatcher).

- [ ] **Step 1: Create the widget**

Create `lib/features/panels/widgets/schedule_panel.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import '../services/automation_config_publisher.dart';

/// Dashboard tile for a server-side daily schedule. Shows the open/close
/// times and an enable switch; reflects the Node-RED flow's reported
/// next-action and warns when the scheduler is offline. The actual clock
/// lives in Node-RED — this widget only writes config + reads status.
class SchedulePanel extends ConsumerWidget {
  const SchedulePanel({
    super.key,
    required this.connectionId,
    required this.target,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String target; // composed shutter command topic (publish topic)
  final Panel panel;
  final ScheduleConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final nextActionAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: connectionId,
      topic: AutomationConfigPublisher.stateTopic(panel.id),
      jsonPath: 'nextAction',
    )));
    final nextAtAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: connectionId,
      topic: AutomationConfigPublisher.stateTopic(panel.id),
      jsonPath: 'nextAt',
    )));
    final bridgeAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: connectionId,
      topic: AutomationConfigPublisher.bridgeStateTopic,
      jsonPath: null,
    )));

    final offline = bridgeAsync.maybeWhen(
      data: (v) => v?.toString() != 'online',
      orElse: () => true,
    );
    final nextAction = nextActionAsync.asData?.value?.toString();
    final nextAt = nextAtAsync.asData?.value?.toString();

    Future<void> toggleEnabled(bool v) async {
      final next = config.copyWith(enabled: v);
      await ref.read(panelRepoProvider).update(
            id: panel.id,
            name: panel.name,
            topic: panel.topic,
            subscribeTopic: panel.subscribeTopic,
            topicPrefixOverride: panel.topicPrefixOverride,
            qos: panel.qos,
            retain: panel.retain,
            width: panel.width,
            config: next,
          );
      final ok =
          await ref.read(automationConfigPublisherProvider).publishConfig(
                connectionId: connectionId,
                panelId: panel.id,
                name: panel.name,
                target: target,
                config: next,
              );
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Not connected — saved; will sync when online.'),
        ));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(Icons.schedule, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(panel.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Switch(value: config.enabled, onChanged: toggleEnabled),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.wb_sunny_outlined, size: 18),
              const SizedBox(width: 6),
              Text('Opens ${config.openTime}'),
              const SizedBox(width: 16),
              const Icon(Icons.nightlight_outlined, size: 18),
              const SizedBox(width: 6),
              Text('Closes ${config.closeTime}'),
            ]),
            const SizedBox(height: 8),
            if (offline)
              Row(children: [
                Icon(Icons.cloud_off, size: 16, color: scheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text("Scheduler offline — won't run",
                      style: TextStyle(color: scheme.error, fontSize: 12)),
                ),
              ])
            else if (config.enabled && nextAction != null && nextAt != null)
              Text('Next: $nextAction at $nextAt',
                  style: TextStyle(color: scheme.outline, fontSize: 12))
            else if (!config.enabled)
              Text('Disabled',
                  style: TextStyle(color: scheme.outline, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter analyze"`
Expected: No issues found. (The file is unused but valid.)

- [ ] **Step 3: Commit**

```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add lib/features/panels/widgets/schedule_panel.dart && git commit -m 'feat(schedule): SchedulePanel tile widget'"
```

---

## Task 4: Wire `PanelType.schedule` through the app

Adding the enum value breaks every exhaustive `switch (PanelType)` until each is handled. This task adds the value and fixes them all in one pass so the project compiles green at the end.

**Files:**
- Modify: `lib/data/database/tables/panels.dart`
- Modify: `lib/features/panels/models/panel_config.dart`
- Modify: `lib/features/panels/widgets/panel_tile.dart`
- Modify: `lib/features/panels/screens/panel_form_screen.dart`
- Modify: `lib/features/dashboards/screens/dashboards_screen.dart`

- [ ] **Step 1: Add the enum value**

In `lib/data/database/tables/panels.dart`, add `schedule` as the last entry of the `PanelType` enum:

```dart
enum PanelType {
  button,
  toggle,
  slider,
  led,
  nodeStatus,
  progress,
  multiState,
  combo,
  radio,
  cover,
  textInput,
  textLog,
  schedule,
}
```

- [ ] **Step 2: Handle it in `PanelConfig.decode` and `defaultFor`**

In `lib/features/panels/models/panel_config.dart`, add to the `decode` switch:

```dart
      PanelType.schedule => ScheduleConfig.fromJson(j),
```

and to the `defaultFor` switch:

```dart
        PanelType.schedule => const ScheduleConfig(),
```

- [ ] **Step 3: Add the dispatcher case in `panel_tile.dart`**

Add the import alongside the other panel widgets:

```dart
import 'schedule_panel.dart';
```

Add this case to the `switch (panel.type)` in `build` (after `PanelType.textLog`):

```dart
      PanelType.schedule => SchedulePanel(
          connectionId: connectionId,
          target: publishTopic,
          panel: panel,
          config: config as ScheduleConfig,
        ),
```

- [ ] **Step 4: Add schedule fields to the form**

In `lib/features/panels/screens/panel_form_screen.dart`:

(a) Add the `composeTopic` import (used at save time):

```dart
import '../providers/panel_value_provider.dart';
```

Also add:

```dart
import '../services/automation_config_publisher.dart';
```

(b) Add controllers/state near the other field declarations (after the Cover fields):

```dart
  // Schedule fields
  final _scheduleOpenTime = TextEditingController(text: '07:00');
  final _scheduleCloseTime = TextEditingController(text: '19:00');
  final _scheduleOpenPayload = TextEditingController(text: '{"state":"OPEN"}');
  final _scheduleClosePayload = TextEditingController(text: '{"state":"CLOSE"}');
  bool _scheduleEnabled = true;
```

(c) Extend `_isWriteOnly` so the device-subscribe field is hidden (the schedule subscribes to its automation state internally, not a user topic):

```dart
  bool get _isWriteOnly =>
      _type == PanelType.button ||
      _type == PanelType.textInput ||
      _type == PanelType.schedule;
```

(d) In `_seedDefaultsForType`, add a case:

```dart
      case PanelType.schedule:
        _topic.text = 'set';
        break;
```

(e) In `_loadPanel`, add to the `if (cfg is …)` chain:

```dart
    } else if (cfg is ScheduleConfig) {
      _scheduleOpenTime.text = cfg.openTime;
      _scheduleCloseTime.text = cfg.closeTime;
      _scheduleOpenPayload.text = cfg.openPayload;
      _scheduleClosePayload.text = cfg.closePayload;
      _scheduleEnabled = cfg.enabled;
    }
```

(f) In `_buildConfig`, add the case:

```dart
      PanelType.schedule => ScheduleConfig(
          openTime: _scheduleOpenTime.text.trim(),
          closeTime: _scheduleCloseTime.text.trim(),
          openPayload: _scheduleOpenPayload.text,
          closePayload: _scheduleClosePayload.text,
          enabled: _scheduleEnabled,
        ),
```

(g) In the `typeLabel` switch (inside `build`), add:

```dart
      PanelType.schedule => 'Schedule',
```

(h) Add a `_pickTime` helper method to the `_State` class:

```dart
  Future<void> _pickTime(TextEditingController c) async {
    final parts = c.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '7') ?? 7,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() => c.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }
```

(i) In `_typeSpecificFields`, add the case (before the closing `}` of the switch):

```dart
      case PanelType.schedule:
        return [
          Text(
            'Runs on the SMHUB via Node-RED — fires even when this phone is '
            'off. The Publish topic above is the shutter command target.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _scheduleOpenTime,
                readOnly: true,
                onTap: () => _pickTime(_scheduleOpenTime),
                decoration: const InputDecoration(
                  labelText: 'Open time',
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _scheduleCloseTime,
                readOnly: true,
                onTap: () => _pickTime(_scheduleCloseTime),
                decoration: const InputDecoration(
                  labelText: 'Close time',
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _scheduleOpenPayload,
            decoration: const InputDecoration(labelText: 'Open payload'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _scheduleClosePayload,
            decoration: const InputDecoration(labelText: 'Close payload'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enabled'),
            value: _scheduleEnabled,
            onChanged: (v) => setState(() => _scheduleEnabled = v),
          ),
        ];
```

(j) Add the new controllers to the `dispose` list:

```dart
      _scheduleOpenTime, _scheduleCloseTime,
      _scheduleOpenPayload, _scheduleClosePayload,
```

- [ ] **Step 5: Add the picker entry**

In `lib/features/dashboards/screens/dashboards_screen.dart`, inside `_openPanelPicker`, add this `ListTile` in the **Control** group (e.g. right after the "Cover" tile):

```dart
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule'),
              subtitle: const Text('Daily open/close times, run on the hub (Node-RED)'),
              onTap: () => Navigator.pop(sheetCtx, 'schedule'),
            ),
```

- [ ] **Step 6: Analyze + full test suite**

Run: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter analyze && flutter test"`
Expected: analyze: No issues found. All tests pass (existing + the 2 new files).

- [ ] **Step 7: Commit**

```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(schedule): wire PanelType.schedule through tile, form, picker'"
```

---

## Task 5: Publish config on save + tombstone on delete

The schedule panel is now editable and stored in Drift, but nothing tells Node-RED yet. Hook the publisher into save and delete.

**Files:**
- Modify: `lib/features/panels/screens/panel_form_screen.dart`
- Modify: `lib/features/dashboards/screens/dashboards_screen.dart` (delete handler in `panel_tile.dart`)

Note: the enable-toggle publish already lives in `SchedulePanel` (Task 3).

- [ ] **Step 1: Publish config after save**

In `panel_form_screen.dart` `_save`, replace the create/update block so it captures the panel id and, for schedule panels, publishes the retained config. The effective prefix mirrors `panel_tile`'s logic (`topicPrefixOverride ?? dashboard prefix`):

```dart
    try {
      String panelId;
      if (_isEdit) {
        await repo.update(
          id: widget.panelId!,
          name: _name.text.trim(),
          topic: _topic.text,
          subscribeTopic: subTopic,
          topicPrefixOverride: prefixOverride,
          qos: _qos,
          retain: _retain,
          width: _width,
          config: _buildConfig(),
        );
        panelId = widget.panelId!;
      } else {
        panelId = await repo.create(
          dashboardId: widget.dashboardId,
          name: _name.text.trim(),
          type: _type,
          topic: _topic.text,
          subscribeTopic: subTopic,
          topicPrefixOverride: prefixOverride,
          qos: _qos,
          retain: _retain,
          width: _width,
          config: _buildConfig(),
        );
      }
      if (_type == PanelType.schedule) {
        final effectivePrefix = prefixOverride ?? _topicPrefixHint;
        final target = composeTopic(effectivePrefix, _topic.text);
        final ok =
            await ref.read(automationConfigPublisherProvider).publishConfig(
                  connectionId: widget.connectionId,
                  panelId: panelId,
                  name: _name.text.trim(),
                  target: target,
                  config: _buildConfig() as ScheduleConfig,
                );
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Saved — not connected; schedule will sync when online.'),
          ));
        }
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
```

- [ ] **Step 2: Tombstone on delete**

In `lib/features/panels/widgets/panel_tile.dart`, add the import:

```dart
import '../services/automation_config_publisher.dart';
```

In `_openOptions`, change the "Delete panel" `onTap` so a schedule panel also clears its retained config:

```dart
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete panel'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                if (panel.type == PanelType.schedule) {
                  await ref
                      .read(automationConfigPublisherProvider)
                      .clearConfig(connectionId: connectionId, panelId: panel.id);
                }
                await repo.delete(panel.id);
              },
            ),
```

- [ ] **Step 3: Analyze + tests**

Run: `wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter analyze && flutter test"`
Expected: No issues; all tests pass.

- [ ] **Step 4: Commit**

```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'feat(schedule): publish retained config on save, tombstone on delete'"
```

---

## Task 6: Node-RED scheduler flow

**Files:**
- Create: `node-red/scheduled-shutter-flow.json`
- Create: `node-red/README.md`

Core nodes only (no BigTimer/cron-plus install). One generic flow handles any number of schedules read from `zigdash/automation/schedule/+/config`.

**Function-node logic (reference — embedded in the flow JSON below):**

*Ingest config* (input: `mqtt in` on `zigdash/automation/schedule/+/config`):
```javascript
// topic: zigdash/automation/schedule/<id>/config
const parts = msg.topic.split('/');
const id = parts[3];
const map = flow.get('schedules') || {};
if (!msg.payload || (typeof msg.payload === 'string' && msg.payload.trim() === '')) {
    delete map[id];                       // tombstone -> drop schedule
} else {
    const cfg = (typeof msg.payload === 'object') ? msg.payload : JSON.parse(msg.payload);
    map[id] = cfg;
}
flow.set('schedules', map);
return null;
```

*Tick* (input: `inject` every 60s + once at startup):
```javascript
const map = flow.get('schedules') || {};
const now = new Date();
const hhmm = now.toTimeString().slice(0, 5);          // "HH:mm" local time
const fired = flow.get('firedMinute') || {};          // de-dupe within a minute
const out = [];

function nextOf(cfg) {
    // returns {action, at} for the next event after now (today or tomorrow)
    return hhmm < cfg.openTime
        ? { action: 'open', at: cfg.openTime }
        : hhmm < cfg.closeTime
            ? { action: 'close', at: cfg.closeTime }
            : { action: 'open', at: cfg.openTime };
}

for (const id of Object.keys(map)) {
    const cfg = map[id];
    const stateTopic = `zigdash/automation/schedule/${id}/state`;
    if (!cfg.enabled) {
        out.push({ topic: stateTopic, retain: true,
                   payload: JSON.stringify({ enabled: false }) });
        continue;
    }
    let lastAction = null;
    for (const action of ['open', 'close']) {
        const at = action === 'open' ? cfg.openTime : cfg.closeTime;
        const key = `${id}:${action}:${hhmm}`;
        if (hhmm === at && !fired[key]) {
            fired[key] = true;                         // don't fire twice this minute
            out.push({ topic: cfg.target, retain: false,
                       payload: action === 'open' ? cfg.openPayload : cfg.closePayload });
            lastAction = action;
        }
    }
    const nxt = nextOf(cfg);
    const state = { enabled: true, nextAction: nxt.action, nextAt: nxt.at };
    if (lastAction) { state.lastAction = lastAction; state.lastAt = hhmm; }
    out.push({ topic: stateTopic, retain: true, payload: JSON.stringify(state) });
}

// keep firedMinute small: drop keys not for the current minute
const pruned = {};
for (const k of Object.keys(fired)) if (k.endsWith(`:${hhmm}`)) pruned[k] = true;
flow.set('firedMinute', pruned);

return [out];     // single output wired to an mqtt-out node (uses msg.topic / msg.retain)
```

*Heartbeat* (input: `inject` once at startup + every 30s):
```javascript
return { topic: 'zigdash/automation/bridge/state', payload: 'online', retain: true };
```

- [ ] **Step 1: Create the flow JSON**

Create `node-red/scheduled-shutter-flow.json`. Build it in the Node-RED editor (it auto-assigns node IDs and the mqtt-broker config node) by creating: an `mqtt in` (`zigdash/automation/schedule/+/config`, output "a parsed JSON object") → the *Ingest config* function; an `inject` (repeat 60s, plus "inject once after 0.1s") → the *Tick* function → an `mqtt out` (leave topic blank so it uses `msg.topic`, set retain from `msg.retain`); an `inject` (repeat 30s + once at start) → the *Heartbeat* function → `mqtt out` (`zigdash/automation/bridge/state`, retain on). Point the mqtt-broker config node at `192.168.7.210:1883`, no credentials, keepalive 60, MQTT 3.1.1 is fine for Node-RED's client (the SMHUB Mosquitto accepts Node-RED's CONNECT — the 3.1-only quirk is specific to the Dart `mqtt_client`). Then **Export → all flows → Download** and save the JSON to this path.

- [ ] **Step 2: Write the import README**

Create `node-red/README.md`:

```markdown
# Scheduled-shutter Node-RED flow

One-time install on the SMHUB (SMLIGHT SMHUB Nano 24).

1. Open Node-RED on the hub (default `http://smhub.local:1880`).
2. Menu (☰) → Import → paste the contents of `scheduled-shutter-flow.json` → Import.
3. If the imported `mqtt-broker` config node is not already pointed at the
   local Mosquitto, double-click it and set Server `192.168.7.210`, Port `1883`,
   no credentials.
4. Click **Deploy**.

The flow reads retained configs from `zigdash/automation/schedule/+/config`
(published by ZigDash), fires shutter commands at the configured times, and
publishes status + an `online` heartbeat back. No extra Node-RED nodes need to
be installed — it uses core nodes only.

## Manual test cases
- Publish a config with `openTime` set to the current minute → the `target`
  receives `openPayload` once (not repeatedly within the minute).
- Set `enabled:false` → no commands fire; the `…/state` topic shows
  `{"enabled":false}`.
- Publish an empty retained payload to a `…/config` topic → that schedule is
  dropped from the in-memory map.
```

- [ ] **Step 3: Commit**

```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add node-red && git commit -m 'feat(schedule): generic Node-RED scheduler flow + import docs'"
```

---

## Task 7: End-to-end verification

**REQUIRED SUB-SKILL:** Use superpowers:verification-before-completion. Do not claim this feature works until the real shutter physically moves on schedule.

- [ ] **Step 1: Build + install the APK** (requires the Galaxy S24 connected)

```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && flutter build apk --debug"
```
Then: `adb -s R5CY247QZGF install -r -d build/app/outputs/flutter-apk/app-debug.apk`
Expected: `Success`.

- [ ] **Step 2: Import + deploy the Node-RED flow** per `node-red/README.md`.

- [ ] **Step 3: Confirm the heartbeat is live**

```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && dart run bin/smoke.dart --host 192.168.7.210 --port 1883 --sub 'zigdash/automation/#' --seconds 6"
```
Expected: a retained `zigdash/automation/bridge/state = online` message.

- [ ] **Step 4: Add a Schedule panel** on the Living Room dashboard — Publish topic = the shutter `set` suffix (so `target` resolves to the real shutter command topic), open/close times, enabled. In ZigDash, confirm the tile does NOT show "Scheduler offline".

- [ ] **Step 5: Confirm the retained config landed**

Re-run the smoke command from Step 3. Expected: a retained `…/<panelId>/config` with the JSON you entered, and a `…/<panelId>/state` showing `nextAction`/`nextAt`.

- [ ] **Step 6: Fire it for real**

Edit the panel, set Open time to the next minute. Within ~60s, watch the physical shutter open. Repeat with Close time. Confirm the tile's "Next:" line updates.

- [ ] **Step 7: Disable + delete**

Toggle the panel's enable switch off → confirm `…/state` shows `{"enabled":false}` and no commands fire at the times. Delete the panel → confirm the retained `…/config` is cleared (empty payload) via the smoke command.

- [ ] **Step 8: Final commit (if any verification fixes were needed)**

```bash
wsl.exe -d Ubuntu -- bash -lc "cd ~/projects/zigdash && git add -A && git commit -m 'fix(schedule): verification adjustments'"
```

---

## Self-review notes (author)

- **Spec coverage:** config/state/heartbeat topics (Task 2/6), retained config + tombstone (Task 2/5), schedule panel UI + offline chip + next-action (Task 3), no Drift migration / additive enum (Task 4), daily fixed times (Task 1/6), SMHUB-local-time semantics (Task 6 tick), pure-Dart tests + device verification (Task 1/2/7) — all mapped.
- **Type consistency:** `ScheduleConfig` (openTime/closeTime/openPayload/closePayload/enabled, `copyWith({bool? enabled})`), `AutomationConfigPublisher.{configTopic,stateTopic,bridgeStateTopic,buildPayload,publishConfig,clearConfig}`, `MqttManager.isConnected`, `SchedulePanel({connectionId,target,panel,config})` are used identically across tasks.
- **Known v1 limitations:** duplicating a schedule panel does not re-publish config until it's saved/toggled (acceptable); times are SMHUB-local with no timezone field (documented in spec).
```
