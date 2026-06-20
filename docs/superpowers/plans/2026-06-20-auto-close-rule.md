# Auto-Close Rule v1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a new "Auto-close rule" panel type to ZigDash that publishes a retained MQTT config describing "device X publishes its close payload N seconds after it turns on", executed by a generic Node-RED flow on the always-on SMHUB.

**Architecture:** Mirrors the existing scheduled-shutter pattern (PR shipped 2026-05-21). ZigDash holds no timers — it only writes a retained config and reads a retained state topic. The Node-RED flow holds in-memory rule state per `panelId`, watches each rule's `triggerTopic`, fires only on OFF→ON edges (filtering Z2M's duplicate state-on-linkquality reports), and locks the timer (first edge wins) until it expires or the rule is disabled.

**Tech Stack:** Flutter (Riverpod, Drift, mqtt_client, gen-l10n), Node-RED 4.x (core nodes only), Mosquitto on SMLIGHT SMHUB Nano 24.

**Spec:** `docs/superpowers/specs/2026-06-20-auto-close-rule-design.md` (committed at `bf68c27`).

---

## File Structure

**Created:**
- `lib/features/panels/services/auto_close_config_publisher.dart` — MQTT retained-config publisher; sibling of `AutomationConfigPublisher`. Topic builders + `publishConfig`/`clearConfig`. Pure logic, no widget code.
- `lib/features/panels/widgets/auto_close_panel.dart` — dashboard tile. Name + enable switch + status line (`Idle` / `Closing in 47s` / `Disabled` / `Offline`). Subscribes to the state + bridge-heartbeat topics via `panelValueProvider`.
- `node-red/auto-close-flow.json` — generic multi-rule executor for the SMHUB. Subscribes to `zigdash/automation/autoclose/+/config`, subscribes to `zigbee2mqtt/#` for triggers, runs the edge-detection state machine, publishes `closePayload` to `target` after the delay, publishes per-rule state.
- `node-red/AUTO_CLOSE_README.md` — install + MQTT contract + manual test cases.
- `test/features/panels/auto_close_config_test.dart` — JSON round-trip + bounds clamping.
- `test/features/panels/auto_close_config_publisher_test.dart` — topic + payload + tombstone.
- `test/features/panels/auto_close_panel_test.dart` — widget tests for the 4 status states.

**Modified:**
- `lib/data/database/tables/panels.dart` — append `autoClose` to `PanelType` enum.
- `lib/features/panels/models/panel_config.dart` — add `AutoCloseConfig` class; wire into `PanelConfig.decode` and `PanelConfig.defaultFor`.
- `lib/features/panels/widgets/panel_tile.dart` — add `case PanelType.autoClose` to dispatcher; clear config on panel delete.
- `lib/features/panels/screens/panel_form_screen.dart` — controllers/defaults/dispose/`_buildConfig`/`_isWriteOnly`/`_seedDefaultsForType`/`_loadExistingPanel`/`_save` (publish on save).
- `lib/features/panels/screens/panel_form_screen.fields.dart` — type-aware section for `autoClose`.
- `lib/features/dashboards/screens/dashboards_screen.dart` — picker entry under "Control".
- `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb` — new keys (picker, type label, form fields, status line, snackbar).

---

## Task 1: `AutoCloseConfig` model + unit tests

**Files:**
- Create: `test/features/panels/auto_close_config_test.dart`
- Modify: `lib/features/panels/models/panel_config.dart` (append new class at end, before `SceneConfig` is OK too)

- [ ] **Step 1: Write the failing test**

Create `test/features/panels/auto_close_config_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';

void main() {
  group('AutoCloseConfig', () {
    test('defaults match the spec', () {
      const c = AutoCloseConfig();
      expect(c.triggerPath, 'state');
      expect(c.triggerValue, 'ON');
      expect(c.closePayload, '{"state":"OFF"}');
      expect(c.delaySeconds, 60);
      expect(c.enabled, isTrue);
    });

    test('toJson/fromJson round-trips', () {
      const c = AutoCloseConfig(
        triggerPath: 'state',
        triggerValue: 'UNLOCK',
        closePayload: '{"state":"LOCK"}',
        delaySeconds: 30,
        enabled: false,
      );
      final back = AutoCloseConfig.fromJson(c.toJson());
      expect(back.triggerValue, 'UNLOCK');
      expect(back.closePayload, '{"state":"LOCK"}');
      expect(back.delaySeconds, 30);
      expect(back.enabled, isFalse);
    });

    test('fromJson tolerates missing keys (falls back to defaults)', () {
      final c = AutoCloseConfig.fromJson(<String, dynamic>{});
      expect(c.triggerPath, 'state');
      expect(c.triggerValue, 'ON');
      expect(c.delaySeconds, 60);
      expect(c.enabled, isTrue);
    });

    test('clamps delaySeconds into [1, 3600]', () {
      expect(const AutoCloseConfig(delaySeconds: 0).delaySeconds, 1);
      expect(const AutoCloseConfig(delaySeconds: -5).delaySeconds, 1);
      expect(const AutoCloseConfig(delaySeconds: 10000).delaySeconds, 3600);
      expect(const AutoCloseConfig(delaySeconds: 60).delaySeconds, 60);
    });

    test('copyWith flips only enabled', () {
      const c = AutoCloseConfig(delaySeconds: 45);
      final off = c.copyWith(enabled: false);
      expect(off.enabled, isFalse);
      expect(off.delaySeconds, 45);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd ~/projects/zigdash
flutter test test/features/panels/auto_close_config_test.dart
```

Expected: compile errors — `AutoCloseConfig` is not defined.

- [ ] **Step 3: Add `AutoCloseConfig` class**

In `lib/features/panels/models/panel_config.dart`, append after `SceneConfig`:

```dart
/// Configures a server-side "close device N seconds after it turns on" rule
/// executed by the Node-RED auto-close flow on the SMHUB. ZigDash publishes
/// this (plus the composed target topic) as retained MQTT config — it never
/// runs the timer itself. Delay is in seconds, clamped to [1, 3600].
class AutoCloseConfig extends PanelConfig {
  AutoCloseConfig({
    this.triggerPath = 'state',
    this.triggerValue = 'ON',
    this.closePayload = '{"state":"OFF"}',
    int delaySeconds = 60,
    this.enabled = true,
  }) : delaySeconds = delaySeconds.clamp(1, 3600);

  final String triggerPath;
  final String triggerValue;
  final String closePayload;
  final int delaySeconds;
  final bool enabled;

  AutoCloseConfig copyWith({bool? enabled}) => AutoCloseConfig(
        triggerPath: triggerPath,
        triggerValue: triggerValue,
        closePayload: closePayload,
        delaySeconds: delaySeconds,
        enabled: enabled ?? this.enabled,
      );

  @override
  Map<String, dynamic> toJson() => {
        'triggerPath': triggerPath,
        'triggerValue': triggerValue,
        'closePayload': closePayload,
        'delaySeconds': delaySeconds,
        'enabled': enabled,
      };

  static AutoCloseConfig fromJson(Map<String, dynamic> j) => AutoCloseConfig(
        triggerPath: j['triggerPath'] as String? ?? 'state',
        triggerValue: j['triggerValue'] as String? ?? 'ON',
        closePayload: j['closePayload'] as String? ?? '{"state":"OFF"}',
        delaySeconds: (j['delaySeconds'] as num?)?.toInt() ?? 60,
        enabled: j['enabled'] as bool? ?? true,
      );
}
```

(`AutoCloseConfig` is intentionally NOT `const` — the constructor body runs `clamp`, which can't be const.)

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/panels/auto_close_config_test.dart
```

Expected: all 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/panels/models/panel_config.dart \
        test/features/panels/auto_close_config_test.dart
git commit -m "feat(panels): add AutoCloseConfig model with bounds clamping

Pure data class (toJson/fromJson + copyWith) for the v1 auto-close
rule panel type. Delay seconds is clamped to [1, 3600] at construction.

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 2: Add `PanelType.autoClose` enum value + wire dispatcher

**Files:**
- Modify: `lib/data/database/tables/panels.dart`
- Modify: `lib/features/panels/models/panel_config.dart` (the `PanelConfig.decode` + `PanelConfig.defaultFor` switches)

- [ ] **Step 1: Write the failing test**

Append to `test/features/panels/auto_close_config_test.dart` inside the same file (add a new top-level `group` or extend `main()` with another group):

```dart
  group('PanelConfig dispatcher (autoClose)', () {
    test('decode routes autoClose payload to AutoCloseConfig', () {
      const raw =
          '{"triggerPath":"state","triggerValue":"ON","closePayload":"{\\"state\\":\\"OFF\\"}","delaySeconds":45,"enabled":true}';
      final cfg = PanelConfig.decode(PanelType.autoClose, raw);
      expect(cfg, isA<AutoCloseConfig>());
      expect((cfg as AutoCloseConfig).delaySeconds, 45);
    });

    test('defaultFor(autoClose) returns AutoCloseConfig with spec defaults', () {
      final cfg = PanelConfig.defaultFor(PanelType.autoClose);
      expect(cfg, isA<AutoCloseConfig>());
      final a = cfg as AutoCloseConfig;
      expect(a.delaySeconds, 60);
      expect(a.triggerValue, 'ON');
    });
  });
```

Note: also requires importing `import 'package:zigdash/data/database/tables/panels.dart';` at the top of the test file if not already present.

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/panels/auto_close_config_test.dart
```

Expected: compile error — `PanelType.autoClose` is not defined.

- [ ] **Step 3: Add the enum value**

In `lib/data/database/tables/panels.dart`, extend the enum:

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
  scene,
  autoClose,
}
```

Run `flutter analyze` — it will now flag the two exhaustive `switch` expressions in `panel_config.dart` (`decode` and `defaultFor`) as non-exhaustive. That's the next step.

- [ ] **Step 4: Wire `PanelConfig.decode` and `PanelConfig.defaultFor`**

In `lib/features/panels/models/panel_config.dart`, update the two switches:

```dart
  static PanelConfig decode(PanelType type, String raw) {
    final j = json.decode(raw) as Map<String, dynamic>;
    return switch (type) {
      PanelType.button => ButtonConfig.fromJson(j),
      PanelType.toggle => ToggleConfig.fromJson(j),
      PanelType.slider => SliderConfig.fromJson(j),
      PanelType.led => LedConfig.fromJson(j),
      PanelType.nodeStatus => NodeStatusConfig.fromJson(j),
      PanelType.progress => ProgressConfig.fromJson(j),
      PanelType.multiState ||
      PanelType.combo ||
      PanelType.radio =>
        OptionsConfig.fromJson(j),
      PanelType.cover => CoverConfig.fromJson(j),
      PanelType.textInput => TextInputConfig.fromJson(j),
      PanelType.textLog => TextLogConfig.fromJson(j),
      PanelType.schedule => ScheduleConfig.fromJson(j),
      PanelType.scene => SceneConfig.fromJson(j),
      PanelType.autoClose => AutoCloseConfig.fromJson(j),
    };
  }

  static PanelConfig defaultFor(PanelType type) => switch (type) {
        PanelType.button => const ButtonConfig(payload: 'PRESS'),
        PanelType.toggle => const ToggleConfig(),
        PanelType.slider => const SliderConfig(),
        PanelType.led => const LedConfig(),
        PanelType.nodeStatus => const NodeStatusConfig(),
        PanelType.progress => const ProgressConfig(),
        PanelType.multiState ||
        PanelType.combo ||
        PanelType.radio =>
          OptionsConfig.coverDefault(),
        PanelType.cover => const CoverConfig(),
        PanelType.textInput => const TextInputConfig(),
        PanelType.textLog => const TextLogConfig(),
        PanelType.schedule => const ScheduleConfig(),
        PanelType.scene => const SceneConfig(),
        PanelType.autoClose => AutoCloseConfig(),
      };
```

(The `autoClose` line in `defaultFor` is intentionally not `const` — `AutoCloseConfig`'s constructor is non-const.)

- [ ] **Step 5: Run tests to verify they pass**

```bash
flutter test test/features/panels/auto_close_config_test.dart
flutter analyze
```

Expected: all tests pass, `flutter analyze` reports 0 issues from these files. Other files that exhaustively switch on `PanelType` (e.g., `panel_tile.dart`, `panel_form_screen.dart`, `dashboards_screen.dart`) will now ALSO be flagged as non-exhaustive — that's intentional and is addressed in subsequent tasks. Confirm those are the only `analyze` warnings before committing.

- [ ] **Step 6: Commit**

```bash
git add lib/data/database/tables/panels.dart \
        lib/features/panels/models/panel_config.dart \
        test/features/panels/auto_close_config_test.dart
git commit -m "feat(panels): add PanelType.autoClose + PanelConfig dispatcher wiring

15th PanelType value; purely additive (textEnum, no Drift migration).
decode() and defaultFor() now route to AutoCloseConfig.

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 3: `AutoCloseConfigPublisher` service + unit tests

**Files:**
- Create: `lib/features/panels/services/auto_close_config_publisher.dart`
- Create: `test/features/panels/auto_close_config_publisher_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/panels/auto_close_config_publisher_test.dart`:

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/services/auto_close_config_publisher.dart';
import 'package:zigdash/features/panels/services/automation_config_publisher.dart';

void main() {
  group('AutoCloseConfigPublisher builders', () {
    test('config/state topics are keyed by panel id under autoclose namespace',
        () {
      expect(AutoCloseConfigPublisher.configTopic('abc'),
          'zigdash/automation/autoclose/abc/config');
      expect(AutoCloseConfigPublisher.stateTopic('abc'),
          'zigdash/automation/autoclose/abc/state');
    });

    test('reuses the scheduler-flow heartbeat topic (no duplicate string)', () {
      expect(AutoCloseConfigPublisher.bridgeStateTopic,
          AutomationConfigPublisher.bridgeStateTopic);
    });

    test('buildPayload emits the wire contract', () {
      final cfg = AutoCloseConfig(
        triggerPath: 'state',
        triggerValue: 'ON',
        closePayload: '{"state":"OFF"}',
        delaySeconds: 60,
      );
      final raw = AutoCloseConfigPublisher.buildPayload(
        name: 'Front door auto-close',
        triggerTopic: 'zigbee2mqtt/door',
        target: 'zigbee2mqtt/door/set',
        config: cfg,
      );
      final j = json.decode(raw) as Map<String, dynamic>;
      expect(j['name'], 'Front door auto-close');
      expect(j['triggerTopic'], 'zigbee2mqtt/door');
      expect(j['triggerPath'], 'state');
      expect(j['triggerValue'], 'ON');
      expect(j['target'], 'zigbee2mqtt/door/set');
      expect(j['closePayload'], '{"state":"OFF"}');
      expect(j['delaySeconds'], 60);
      expect(j['enabled'], true);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/panels/auto_close_config_publisher_test.dart
```

Expected: compile error — `AutoCloseConfigPublisher` is not defined.

- [ ] **Step 3: Create the publisher**

Create `lib/features/panels/services/auto_close_config_publisher.dart`:

```dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;

import '../../../mqtt/providers/mqtt_manager_provider.dart';
import '../models/panel_config.dart';
import 'automation_config_publisher.dart';

/// Owns the ZigDash<->Node-RED MQTT contract for auto-close rules. Sibling of
/// [AutomationConfigPublisher] (which owns the daily-schedule contract). The
/// bridge heartbeat is published by the scheduler flow — this publisher only
/// reuses its topic constant for reads.
class AutoCloseConfigPublisher {
  AutoCloseConfigPublisher(this._ref);
  final Ref _ref;

  static String configTopic(String panelId) =>
      'zigdash/automation/autoclose/$panelId/config';

  static String stateTopic(String panelId) =>
      'zigdash/automation/autoclose/$panelId/state';

  static const String bridgeStateTopic =
      AutomationConfigPublisher.bridgeStateTopic;

  /// The retained JSON the Node-RED flow expects.
  static String buildPayload({
    required String name,
    required String triggerTopic,
    required String target,
    required AutoCloseConfig config,
  }) =>
      json.encode({
        'name': name,
        'triggerTopic': triggerTopic,
        'triggerPath': config.triggerPath,
        'triggerValue': config.triggerValue,
        'target': target,
        'closePayload': config.closePayload,
        'delaySeconds': config.delaySeconds,
        'enabled': config.enabled,
      });

  /// Publishes the retained config. Returns false if the broker isn't
  /// connected (caller can surface a hint via snackbar). The bridge heartbeat
  /// chip on the panel is the real "is it running" safety net.
  Future<bool> publishConfig({
    required String connectionId,
    required String panelId,
    required String name,
    required String triggerTopic,
    required String target,
    required AutoCloseConfig config,
  }) async {
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (!mgr.isConnected) return false;
    mgr.publish(
      configTopic(panelId),
      buildPayload(
        name: name,
        triggerTopic: triggerTopic,
        target: target,
        config: config,
      ),
      '',
      qos: mc.MqttQos.atLeastOnce,
      retain: true,
    );
    return true;
  }

  /// Tombstone: clears the retained config so the Node-RED flow drops the rule
  /// and cancels any pending timer. Best-effort if disconnected.
  Future<void> clearConfig({
    required String connectionId,
    required String panelId,
  }) async {
    final mgr = await _ref.read(mqttManagerProvider(connectionId).future);
    if (!mgr.isConnected) return;
    mgr.publish(configTopic(panelId), '', '', retain: true);
  }
}

final autoCloseConfigPublisherProvider = Provider<AutoCloseConfigPublisher>(
  (ref) => AutoCloseConfigPublisher(ref),
);
```

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/features/panels/auto_close_config_publisher_test.dart
```

Expected: all 3 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/panels/services/auto_close_config_publisher.dart \
        test/features/panels/auto_close_config_publisher_test.dart
git commit -m "feat(panels): add AutoCloseConfigPublisher service

Sibling of AutomationConfigPublisher, sharing the bridge/state heartbeat
topic constant but owning its own zigdash/automation/autoclose/<id>
namespace. publishConfig + clearConfig (tombstone) over retained MQTT.

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 4: Form-screen state plumbing for `autoClose`

**Files:**
- Modify: `lib/features/panels/screens/panel_form_screen.dart` (controllers, defaults, `_isWriteOnly`, `_seedDefaultsForType`, `_loadExistingPanel`, `_buildConfig`, `_save`, `dispose`, type-label switch)

This is mostly mechanical wiring — match the existing `schedule` handling exactly.

- [ ] **Step 1: Add controller fields + default state**

In `lib/features/panels/screens/panel_form_screen.dart`, near the existing schedule fields (after line ~126), add:

```dart
  // Auto-close fields
  final _autoCloseTriggerPath = TextEditingController(text: 'state');
  final _autoCloseTriggerValue = TextEditingController(text: 'ON');
  final _autoCloseClosePayload =
      TextEditingController(text: '{"state":"OFF"}');
  final _autoCloseDelaySeconds = TextEditingController(text: '60');
  bool _autoCloseEnabled = true;
```

- [ ] **Step 2: Extend `_isWriteOnly` (auto-close has no subscribe topic from the user's POV)**

Auto-close rules have no in-app subscribe topic — the Node-RED flow subscribes on their behalf. Treat them like schedule for form purposes. Update `_isWriteOnly`:

```dart
  bool get _isWriteOnly =>
      _type == PanelType.button ||
      _type == PanelType.textInput ||
      _type == PanelType.schedule ||
      _type == PanelType.scene ||
      _type == PanelType.autoClose;
```

(Leave `_isReadOnly` and `_currentJsonPath` alone — `autoClose` falls through to the default empty case for json-path lookups.)

- [ ] **Step 3: Extend `_seedDefaultsForType`**

Add a new case to the switch in `_seedDefaultsForType`. Auto-close mirrors the schedule pattern (panel's `topic` = device's command leaf, dashboard prefix composes to the full target):

```dart
      case PanelType.autoClose:
        _topic.text = 'set';
        break;
```

- [ ] **Step 4: Extend `_loadExistingPanel` (the `if (cfg is …)` chain)**

After the existing `cfg is ScheduleConfig` block (around line 336), add:

```dart
    } else if (cfg is AutoCloseConfig) {
      _autoCloseTriggerPath.text = cfg.triggerPath;
      _autoCloseTriggerValue.text = cfg.triggerValue;
      _autoCloseClosePayload.text = cfg.closePayload;
      _autoCloseDelaySeconds.text = cfg.delaySeconds.toString();
      _autoCloseEnabled = cfg.enabled;
```

- [ ] **Step 5: Extend `_buildConfig`**

In the switch returning `PanelConfig`, add:

```dart
      PanelType.autoClose => AutoCloseConfig(
          triggerPath: _autoCloseTriggerPath.text.trim().isEmpty
              ? 'state'
              : _autoCloseTriggerPath.text.trim(),
          triggerValue: _autoCloseTriggerValue.text,
          closePayload: _autoCloseClosePayload.text,
          delaySeconds: int.tryParse(_autoCloseDelaySeconds.text) ?? 60,
          enabled: _autoCloseEnabled,
        ),
```

- [ ] **Step 6: Extend the type-label switch in `build()`**

Find the existing switch around line ~603 (`final typeLabel = switch (_type) {…}`) and add a case (kept alphabetically near `autoClose`'s position in the enum or at the end — match the existing file's ordering style):

```dart
      PanelType.autoClose => l10n.panelTypeAutoClose,
```

(The l10n key `panelTypeAutoClose` is added in Task 9.)

- [ ] **Step 7: Extend `dispose()` to release the new controllers**

Add the four new `TextEditingController`s to the list literal in `dispose()` (around line 563–578):

```dart
      _scheduleOpenTime, _scheduleCloseTime,
      _scheduleOpenPayload, _scheduleClosePayload,
      _autoCloseTriggerPath, _autoCloseTriggerValue,
      _autoCloseClosePayload, _autoCloseDelaySeconds,
```

- [ ] **Step 8: Extend `_save()` — publish the retained config after persisting**

After the existing `if (_type == PanelType.schedule) { … }` block (around line 538), add a sibling block:

```dart
      if (_type == PanelType.autoClose) {
        final effectivePrefix = prefixOverride ?? _topicPrefixHint;
        final triggerTopic =
            composeTopic(effectivePrefix, _topic.text);
        // Default target = triggerTopic + '/set' (Z2M convention). The form
        // does not (yet) expose a target override; the wire contract supports
        // it but the v1 UX assumes the Z2M target convention.
        final target = '$triggerTopic/set';
        final cfg = _buildConfig() as AutoCloseConfig;
        final ok =
            await ref.read(autoCloseConfigPublisherProvider).publishConfig(
                  connectionId: widget.connectionId,
                  panelId: panelId,
                  name: _name.text.trim(),
                  triggerTopic: triggerTopic,
                  target: target,
                  config: cfg,
                );
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.panelAutoCloseSavedOffline),
          ));
        }
      }
```

Required imports at the top of the file:

```dart
import '../services/auto_close_config_publisher.dart';
```

(The l10n key `panelAutoCloseSavedOffline` is added in Task 9.)

- [ ] **Step 9: Verify analyze is clean (modulo the panel_tile + dashboards_screen + fields.dart still-pending changes)**

```bash
cd ~/projects/zigdash
flutter analyze lib/features/panels/screens/panel_form_screen.dart
```

Expected: 0 issues in `panel_form_screen.dart` itself. Other files still flagged as non-exhaustive — addressed in later tasks.

- [ ] **Step 10: Commit**

```bash
git add lib/features/panels/screens/panel_form_screen.dart
git commit -m "feat(panels): wire AutoClose into panel form (state, build, save)

Adds controllers, _isWriteOnly handling, defaults seeding, existing-panel
loading, _buildConfig, and the publish-on-save call to
AutoCloseConfigPublisher. Mirrors the schedule integration.

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 5: Form fields UI for `autoClose`

**Files:**
- Modify: `lib/features/panels/screens/panel_form_screen.fields.dart`

- [ ] **Step 1: Add the `autoClose` case in the type-aware fields switch**

Find the existing `case PanelType.schedule:` block (around line 366). Add a new sibling case after `case PanelType.scene:` (which is the last `case` before the switch closes):

```dart
      case PanelType.autoClose:
        return [
          Text(
            l10n.panelAutoCloseDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _autoCloseTriggerPath,
            decoration: InputDecoration(
              labelText: l10n.panelAutoCloseTriggerPath,
              helperText: l10n.panelAutoCloseTriggerPathHelper,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _autoCloseTriggerValue,
            decoration: InputDecoration(
              labelText: l10n.panelAutoCloseTriggerValue,
              helperText: l10n.panelAutoCloseTriggerValueHelper,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _autoCloseClosePayload,
            decoration: InputDecoration(
              labelText: l10n.panelAutoCloseClosePayload,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _autoCloseDelaySeconds,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.panelAutoCloseDelaySeconds,
              helperText: l10n.panelAutoCloseDelaySecondsHelper,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.panelAutoCloseEnabled),
            value: _autoCloseEnabled,
            onChanged: (v) => setState(() => _autoCloseEnabled = v), // ignore: invalid_use_of_protected_member
          ),
        ];
```

(All `panelAutoClose*` l10n keys are added in Task 9. The v1 form intentionally does NOT include a device-type preset dropdown — Switch defaults already cover the common case, and Lock/Cover users can edit the fields directly. A preset dropdown is a clean future extension.)

- [ ] **Step 2: Verify analyze**

```bash
flutter analyze lib/features/panels/screens/panel_form_screen.fields.dart
```

Expected: 0 issues from `fields.dart` itself (l10n keys will error until Task 9 — defer running this verification until after Task 9 if it blocks).

- [ ] **Step 3: Commit**

```bash
git add lib/features/panels/screens/panel_form_screen.fields.dart
git commit -m "feat(panels): auto-close form fields UI

Trigger path / trigger value / close payload / delay-seconds / enabled
switch. v1 omits the device-type preset dropdown; field defaults cover
the relay case (the door use case).

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 6: PanelTile dispatcher + tombstone-on-delete

**Files:**
- Modify: `lib/features/panels/widgets/panel_tile.dart`

- [ ] **Step 1: Add the dispatcher case**

Find the `switch (panel.type)` in `build()` (line ~147). Append after `PanelType.scene =>`:

```dart
      PanelType.autoClose => AutoClosePanel(
          connectionId: connectionId,
          triggerTopic: subscribeTopic,
          target: publishTopic,
          panel: panel,
          config: config as AutoCloseConfig,
        ),
```

Note on topics: the auto-close widget does NOT itself subscribe to the trigger topic (Node-RED does that). The `triggerTopic`/`target` are passed through ONLY so the panel can re-publish the retained config from the enable-switch handler. The panel's own MQTT subscription is to `zigdash/automation/autoclose/<panelId>/state` (set inside the widget, not derived here).

Required imports at the top of `panel_tile.dart`:

```dart
import 'auto_close_panel.dart';
```

And the corresponding `import` for `AutoCloseConfig` is already available via `panel_config.dart` (existing import).

- [ ] **Step 2: Wire tombstone-on-delete**

Find the delete `ListTile` (around line 120–132) which already calls `clearConfig` for `schedule`. Extend it to handle `autoClose`:

```dart
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.panelTileDelete),
              onTap: () async {
                Navigator.pop(sheetCtx);
                if (panel.type == PanelType.schedule) {
                  await ref
                      .read(automationConfigPublisherProvider)
                      .clearConfig(connectionId: connectionId, panelId: panel.id);
                } else if (panel.type == PanelType.autoClose) {
                  await ref
                      .read(autoCloseConfigPublisherProvider)
                      .clearConfig(connectionId: connectionId, panelId: panel.id);
                }
                await repo.delete(panel.id);
              },
            ),
```

Required additional import:

```dart
import '../services/auto_close_config_publisher.dart';
```

- [ ] **Step 3: Verify analyze**

```bash
flutter analyze lib/features/panels/widgets/panel_tile.dart
```

Expected: 0 issues (modulo `AutoClosePanel` not existing yet — that's Task 8; the file will compile-fail until then).

- [ ] **Step 4: Commit (after Task 8 lands; for now stage and continue)**

The widget reference will not compile until `AutoClosePanel` exists. Either:
- (a) Land Task 8 first, then circle back to commit both panel_tile + the widget together, OR
- (b) Use a placeholder `Card(child: Text('Auto-close (pending)'))` here temporarily, commit, then replace it in Task 8.

Recommended: **(a)** — combine the panel_tile commit with the widget commit in Task 8.

---

## Task 7: Picker entry under "Control"

**Files:**
- Modify: `lib/features/dashboards/screens/dashboards_screen.dart`

- [ ] **Step 1: Add the picker `ListTile`**

In `_openPanelPicker` (or whatever the function is called), find the existing "Schedule" `ListTile` (around line 248–253). Add a sibling immediately after it:

```dart
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(sheetCtx.l10n.panelPickerAutoCloseTitle),
              subtitle: Text(sheetCtx.l10n.panelPickerAutoCloseSubtitle),
              onTap: () => Navigator.pop(sheetCtx, 'autoClose'),
            ),
```

The token `'autoClose'` matches `PanelType.autoClose.name` (Dart enum `.name` returns the camelCase identifier). The downstream route handler maps the token via `PanelType.values.byName(t)` — verify this works by reading the existing handler if uncertain (search for `byName` in this file).

- [ ] **Step 2: Verify analyze**

```bash
flutter analyze lib/features/dashboards/screens/dashboards_screen.dart
```

Expected: 0 issues from this file (l10n keys will fail until Task 9).

- [ ] **Step 3: Commit**

```bash
git add lib/features/dashboards/screens/dashboards_screen.dart
git commit -m "feat(panels): picker entry for Auto-close rule under Control

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 8: `AutoClosePanel` widget + widget tests

**Files:**
- Create: `lib/features/panels/widgets/auto_close_panel.dart`
- Create: `test/features/panels/auto_close_panel_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create `test/features/panels/auto_close_panel_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/features/panels/providers/panel_value_provider.dart';
import 'package:zigdash/features/panels/services/auto_close_config_publisher.dart';
import 'package:zigdash/features/panels/widgets/auto_close_panel.dart';
import 'package:zigdash/l10n/app_localizations.dart';

Panel _panel({String name = 'Door auto-close'}) => Panel(
      id: 'p1',
      dashboardId: 'd1',
      name: name,
      type: PanelType.autoClose,
      topic: 'door',
      subscribeTopic: null,
      topicPrefixOverride: null,
      qos: 1,
      retain: false,
      width: PanelWidth.full,
      sortOrder: 0,
      config: '{}',
      mergeFlags: 0,
      createdAt: DateTime(2026, 6, 20),
      updatedAt: DateTime(2026, 6, 20),
    );

Widget _wrap(Widget child, {required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AutoClosePanel status line', () {
    testWidgets('renders Idle when state.status = idle and bridge online',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AutoClosePanel(
          connectionId: 'c1',
          triggerTopic: 'zigbee2mqtt/door',
          target: 'zigbee2mqtt/door/set',
          panel: _panel(),
          config: AutoCloseConfig(),
        ),
        overrides: [
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.stateTopic('p1'),
            jsonPath: null,
          )).overrideWith((_) =>
              Stream.value('{"status":"idle","enabled":true}')),
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.bridgeStateTopic,
            jsonPath: null,
          )).overrideWith((_) => Stream.value('online')),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('Idle'), findsOneWidget);
    });

    testWidgets('renders Disabled when state.status = disabled',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AutoClosePanel(
          connectionId: 'c1',
          triggerTopic: 'zigbee2mqtt/door',
          target: 'zigbee2mqtt/door/set',
          panel: _panel(),
          config: AutoCloseConfig(enabled: false),
        ),
        overrides: [
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.stateTopic('p1'),
            jsonPath: null,
          )).overrideWith((_) =>
              Stream.value('{"status":"disabled","enabled":false}')),
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.bridgeStateTopic,
            jsonPath: null,
          )).overrideWith((_) => Stream.value('online')),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('Disabled'), findsOneWidget);
    });

    testWidgets('renders Offline when bridge heartbeat != "online"',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AutoClosePanel(
          connectionId: 'c1',
          triggerTopic: 'zigbee2mqtt/door',
          target: 'zigbee2mqtt/door/set',
          panel: _panel(),
          config: AutoCloseConfig(),
        ),
        overrides: [
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.stateTopic('p1'),
            jsonPath: null,
          )).overrideWith((_) =>
              Stream.value('{"status":"idle","enabled":true}')),
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.bridgeStateTopic,
            jsonPath: null,
          )).overrideWith((_) => Stream.value('offline')),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('shows a countdown for status = pending', (tester) async {
      final future = DateTime.now()
          .toUtc()
          .add(const Duration(seconds: 45))
          .toIso8601String();
      await tester.pumpWidget(_wrap(
        AutoClosePanel(
          connectionId: 'c1',
          triggerTopic: 'zigbee2mqtt/door',
          target: 'zigbee2mqtt/door/set',
          panel: _panel(),
          config: AutoCloseConfig(),
        ),
        overrides: [
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.stateTopic('p1'),
            jsonPath: null,
          )).overrideWith((_) => Stream.value(
              '{"status":"pending","enabled":true,"pendingCloseAt":"$future"}')),
          panelValueProvider(PanelStreamKey(
            connectionId: 'c1',
            topic: AutoCloseConfigPublisher.bridgeStateTopic,
            jsonPath: null,
          )).overrideWith((_) => Stream.value('online')),
        ],
      ));
      await tester.pumpAndSettle();
      // The exact remaining seconds depends on test-runner timing; assert that
      // SOME positive whole-seconds countdown text is shown.
      expect(find.textContaining(RegExp(r'\b\d+s\b')), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
flutter test test/features/panels/auto_close_panel_test.dart
```

Expected: compile error — `AutoClosePanel` is not defined. (Also `panel_localizations` access for tests — make sure `flutter gen-l10n` has been run if you've added keys; for v1 we can skip exact-text assertions and use icon assertions instead if needed.)

- [ ] **Step 3: Create the widget**

Create `lib/features/panels/widgets/auto_close_panel.dart`:

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import '../services/auto_close_config_publisher.dart';

/// Dashboard tile for a server-side auto-close rule. Shows an enable switch
/// and a single status line driven by the Node-RED flow's published state
/// topic. The countdown text is recomputed locally every second from the
/// `pendingCloseAt` timestamp — no provider rebuild loop.
class AutoClosePanel extends ConsumerStatefulWidget {
  const AutoClosePanel({
    super.key,
    required this.connectionId,
    required this.triggerTopic,
    required this.target,
    required this.panel,
    required this.config,
  });

  final String connectionId;
  final String triggerTopic; // device's state topic (full, composed)
  final String target;       // device's command topic (full, composed)
  final Panel panel;
  final AutoCloseConfig config;

  @override
  ConsumerState<AutoClosePanel> createState() => _AutoClosePanelState();
}

class _AutoClosePanelState extends ConsumerState<AutoClosePanel> {
  bool _busy = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _toggleEnabled(bool v) async {
    if (_busy) return;
    setState(() => _busy = true);
    final panel = widget.panel;
    final next = widget.config.copyWith(enabled: v);
    try {
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
          await ref.read(autoCloseConfigPublisherProvider).publishConfig(
                connectionId: widget.connectionId,
                panelId: panel.id,
                name: panel.name,
                triggerTopic: widget.triggerTopic,
                target: widget.target,
                config: next,
              );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.panelAutoCloseSavedOffline),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final panel = widget.panel;
    final config = widget.config;

    final stateAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: widget.connectionId,
      topic: AutoCloseConfigPublisher.stateTopic(panel.id),
      jsonPath: null,
    )));
    final bridgeAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: widget.connectionId,
      topic: AutoCloseConfigPublisher.bridgeStateTopic,
      jsonPath: null,
    )));

    final offline = bridgeAsync.maybeWhen(
      data: (v) => v?.toString() != 'online',
      orElse: () => true,
    );

    String? status;
    DateTime? pendingCloseAt;
    stateAsync.whenData((raw) {
      if (raw == null) return;
      try {
        final j = json.decode(raw.toString()) as Map<String, dynamic>;
        status = j['status'] as String?;
        final s = j['pendingCloseAt'] as String?;
        if (s != null) pendingCloseAt = DateTime.tryParse(s);
      } catch (_) {
        // Ignore malformed payloads; UI falls back to "Idle" below.
      }
    });

    String statusLine;
    if (offline) {
      statusLine = context.l10n.panelAutoCloseOffline;
    } else if (status == 'disabled' || !config.enabled) {
      statusLine = context.l10n.panelAutoCloseDisabled;
    } else if (status == 'pending' && pendingCloseAt != null) {
      final secs = pendingCloseAt!.difference(DateTime.now().toUtc()).inSeconds;
      statusLine = secs > 0
          ? context.l10n.panelAutoCloseClosingIn(secs)
          : context.l10n.panelAutoCloseClosingNow;
    } else {
      statusLine = context.l10n.panelAutoCloseIdle;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(Icons.timer_outlined, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(panel.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Switch(
                value: config.enabled,
                onChanged: _busy ? null : _toggleEnabled,
              ),
            ]),
            const SizedBox(height: 4),
            if (offline)
              Row(children: [
                Icon(Icons.cloud_off, size: 16, color: scheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(statusLine,
                      style: TextStyle(color: scheme.error, fontSize: 12)),
                ),
              ])
            else
              Text(statusLine,
                  style: TextStyle(color: scheme.outline, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the widget test**

```bash
flutter test test/features/panels/auto_close_panel_test.dart
```

Expected: all 4 widget tests pass. (The Idle and Disabled assertions rely on the EN locale text rendering; if `gen-l10n` hasn't been run yet, these will fail. Run `flutter gen-l10n` first — it's idempotent — or land Task 9 before this verification.)

- [ ] **Step 5: Verify analyze on the full project**

```bash
flutter analyze
```

Expected: 0 issues (now that the dispatcher in `panel_tile.dart` from Task 6 has its widget).

- [ ] **Step 6: Commit (bundles Task 6's pending changes)**

```bash
git add lib/features/panels/widgets/auto_close_panel.dart \
        lib/features/panels/widgets/panel_tile.dart \
        test/features/panels/auto_close_panel_test.dart
git commit -m "feat(panels): AutoClosePanel widget + PanelTile wiring + tombstone

Widget renders name, enable switch, and a single status line driven by
the retained state topic. Pending countdown is recomputed locally every
1s from pendingCloseAt. PanelTile dispatcher + tombstone-on-delete
mirror the schedule pattern.

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 9: l10n keys (EN + HE)

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_he.arb`

- [ ] **Step 1: Add EN keys**

In `lib/l10n/app_en.arb`, add (preserve JSON key ordering loosely — group near existing `panelSchedule*` keys):

```json
  "panelPickerAutoCloseTitle": "Auto-close rule",
  "panelPickerAutoCloseSubtitle": "Close a device automatically N seconds after it turns on, run on the hub (Node-RED)",
  "panelTypeAutoClose": "Auto-close",
  "panelAutoCloseDescription": "Runs on the SMHUB via Node-RED — fires even when this phone is off. The Publish topic above is the device's command target (e.g. door).",
  "panelAutoCloseTriggerPath": "Trigger JSON path",
  "panelAutoCloseTriggerPathHelper": "Field in the device's state JSON to watch (default: state)",
  "panelAutoCloseTriggerValue": "Trigger value",
  "panelAutoCloseTriggerValueHelper": "Fire the timer when the trigger field equals this value (default: ON)",
  "panelAutoCloseClosePayload": "Close payload",
  "panelAutoCloseDelaySeconds": "Delay (seconds)",
  "panelAutoCloseDelaySecondsHelper": "1-3600. Time to wait after the device turns on before publishing the close payload.",
  "panelAutoCloseEnabled": "Enabled",
  "panelAutoCloseSavedOffline": "Saved — not connected; rule will sync when online.",
  "panelAutoCloseIdle": "Idle",
  "panelAutoCloseDisabled": "Disabled",
  "panelAutoCloseOffline": "Automation offline — rule won't run",
  "panelAutoCloseClosingIn": "Closing in {seconds}s",
  "@panelAutoCloseClosingIn": { "placeholders": { "seconds": { "type": "int" } } },
  "panelAutoCloseClosingNow": "Closing now…",
```

- [ ] **Step 2: Add HE keys (parity)**

In `lib/l10n/app_he.arb`, add the exact same keys with Hebrew translations. Suggested first-pass translations (gilad should review on-device):

```json
  "panelPickerAutoCloseTitle": "סגירה אוטומטית",
  "panelPickerAutoCloseSubtitle": "סגירת מכשיר אוטומטית N שניות אחרי הפעלה, רץ בהאב (Node-RED)",
  "panelTypeAutoClose": "סגירה אוטומטית",
  "panelAutoCloseDescription": "רץ על ה-SMHUB דרך Node-RED — פועל גם כשהטלפון כבוי. נושא הפרסום למעלה הוא נושא הפקודה של המכשיר (למשל door).",
  "panelAutoCloseTriggerPath": "נתיב JSON לטריגר",
  "panelAutoCloseTriggerPathHelper": "השדה ב-JSON של המכשיר שצריך לעקוב (ברירת מחדל: state)",
  "panelAutoCloseTriggerValue": "ערך טריגר",
  "panelAutoCloseTriggerValueHelper": "הפעל טיימר כששדה הטריגר שווה לערך הזה (ברירת מחדל: ON)",
  "panelAutoCloseClosePayload": "מטען סגירה",
  "panelAutoCloseDelaySeconds": "השהיה (שניות)",
  "panelAutoCloseDelaySecondsHelper": "1-3600. זמן להמתין אחרי הפעלת המכשיר לפני פרסום מטען הסגירה.",
  "panelAutoCloseEnabled": "מופעל",
  "panelAutoCloseSavedOffline": "נשמר — אין חיבור; החוק יסונכרן ברגע שתחזור החיבור.",
  "panelAutoCloseIdle": "במנוחה",
  "panelAutoCloseDisabled": "מושבת",
  "panelAutoCloseOffline": "אוטומציה לא מחוברת — החוק לא ירוץ",
  "panelAutoCloseClosingIn": "סוגר בעוד {seconds} שניות",
  "@panelAutoCloseClosingIn": { "placeholders": { "seconds": { "type": "int" } } },
  "panelAutoCloseClosingNow": "סוגר עכשיו…",
```

- [ ] **Step 3: Generate localizations**

```bash
cd ~/projects/zigdash
flutter gen-l10n
```

Expected: no errors; `lib/l10n/app_localizations*.dart` regenerated. The tool enforces EN/HE parity — missing or extra keys fail the build.

- [ ] **Step 4: Run full test suite + analyze**

```bash
flutter analyze
flutter test
```

Expected: all tests pass (Drift native tests may need `LD_LIBRARY_PATH="$HOME/.local/lib" flutter test` per the documented WSL workaround in [`zigdash_project.md`]). Analyze reports 0 issues.

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/app_en.arb lib/l10n/app_he.arb lib/l10n/app_localizations*.dart
git commit -m "i18n(panels): add EN+HE strings for Auto-close rule

Picker title/subtitle, type label, form helpers, status line variants
(Idle/Pending countdown/Disabled/Offline), saved-offline snackbar. HE
translations are first-pass; review on-device for tone before release.

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 10: Node-RED auto-close flow

**Files:**
- Create: `node-red/auto-close-flow.json`

- [ ] **Step 1: Create the flow file**

Create `node-red/auto-close-flow.json`:

```json
[
  {
    "id": "zigdash_ac_tab",
    "type": "tab",
    "label": "ZigDash Auto-close",
    "disabled": false,
    "info": "Generic auto-close executor for ZigDash. Reads retained configs from zigdash/automation/autoclose/+/config, watches each rule's triggerTopic, fires the close payload <delaySeconds> after a true OFF->ON edge. Lock semantics: while a timer is pending, further matching messages are ignored. Heartbeat (bridge/state) is owned by the scheduler flow — this flow does NOT republish it. Core nodes only."
  },
  {
    "id": "zigdash_ac_broker",
    "type": "mqtt-broker",
    "name": "SMHUB Mosquitto",
    "broker": "10.0.0.57",
    "port": "1883",
    "clientid": "zigdash-autoclose",
    "autoConnect": true,
    "usetls": false,
    "protocolVersion": "3",
    "keepalive": "60",
    "cleansession": true,
    "birthTopic": "",
    "birthQos": "0",
    "birthPayload": "",
    "closeTopic": "",
    "closeQos": "0",
    "closePayload": "",
    "willTopic": "",
    "willQos": "0",
    "willRetain": "false",
    "willPayload": ""
  },
  {
    "id": "zigdash_ac_mqtt_in_config",
    "type": "mqtt in",
    "z": "zigdash_ac_tab",
    "name": "autoclose config in",
    "topic": "zigdash/automation/autoclose/+/config",
    "qos": "1",
    "datatype": "auto",
    "broker": "zigdash_ac_broker",
    "x": 180,
    "y": 80,
    "wires": [["zigdash_ac_fn_ingest"]]
  },
  {
    "id": "zigdash_ac_fn_ingest",
    "type": "function",
    "z": "zigdash_ac_tab",
    "name": "ingest config",
    "func": "// topic: zigdash/automation/autoclose/<id>/config\nconst parts = msg.topic.split('/');\nconst id = parts[3];\nconst rules = flow.get('rules') || {};\nconst timers = flow.get('timers') || {};\nconst raw = msg.payload;\nconst empty = raw === undefined || raw === null ||\n    (typeof raw === 'string' && raw.trim() === '') ||\n    (Buffer.isBuffer(raw) && raw.length === 0);\nconst stateTopic = `zigdash/automation/autoclose/${id}/state`;\n\nfunction clearTimerFor(id) {\n    if (timers[id]) { clearTimeout(timers[id]); delete timers[id]; }\n}\n\nif (empty) {\n    clearTimerFor(id);\n    delete rules[id];\n    flow.set('rules', rules);\n    flow.set('timers', timers);\n    // Clear retained state topic too (no litter for deleted rules).\n    return { topic: stateTopic, payload: '', retain: true };\n}\n\nconst cfg = (typeof raw === 'object' && !Buffer.isBuffer(raw))\n    ? raw\n    : JSON.parse(raw.toString());\n\n// A new/updated config cancels any in-flight timer for safety.\nclearTimerFor(id);\nrules[id] = cfg;\nflow.set('rules', rules);\nflow.set('timers', timers);\n\nconst status = cfg.enabled ? 'idle' : 'disabled';\nreturn { topic: stateTopic, retain: true,\n         payload: JSON.stringify({ enabled: !!cfg.enabled, status: status }) };",
    "outputs": 1,
    "noerr": 0,
    "x": 440,
    "y": 80,
    "wires": [["zigdash_ac_mqtt_out"]]
  },
  {
    "id": "zigdash_ac_mqtt_in_trigger",
    "type": "mqtt in",
    "z": "zigdash_ac_tab",
    "name": "trigger watcher (zigbee2mqtt/#)",
    "topic": "zigbee2mqtt/#",
    "qos": "0",
    "datatype": "auto",
    "broker": "zigdash_ac_broker",
    "x": 220,
    "y": 200,
    "wires": [["zigdash_ac_fn_edge"]]
  },
  {
    "id": "zigdash_ac_fn_edge",
    "type": "function",
    "z": "zigdash_ac_tab",
    "name": "edge detect + arm timer",
    "func": "const rules = flow.get('rules') || {};\nconst timers = flow.get('timers') || {};\nconst lastValues = flow.get('lastValues') || {};\nconst topic = msg.topic;\nlet payload = msg.payload;\nif (Buffer.isBuffer(payload)) payload = payload.toString();\n\nlet j;\ntry {\n    j = (typeof payload === 'object') ? payload : JSON.parse(payload);\n} catch (e) {\n    return null; // ignore non-JSON\n}\n\nconst out = [];\n\nfor (const id of Object.keys(rules)) {\n    const cfg = rules[id];\n    if (cfg.triggerTopic !== topic) continue;\n    const path = cfg.triggerPath || 'state';\n    const current = j != null ? j[path] : undefined;\n    if (current === undefined) continue;\n    const key = `${id}:${cfg.triggerTopic}`;\n    const prev = lastValues[key];\n    lastValues[key] = current;\n    // Edge: prev != trigger, current == trigger.\n    if (current !== cfg.triggerValue) continue;\n    if (prev === cfg.triggerValue) continue;        // duplicate ON -> ignore\n    if (!cfg.enabled) continue;\n    if (timers[id]) continue;                       // Lock: first edge wins\n\n    const stateTopic = `zigdash/automation/autoclose/${id}/state`;\n    const delaySec = Math.max(1, Math.min(3600, Number(cfg.delaySeconds) || 60));\n    const fireAt = new Date(Date.now() + delaySec * 1000).toISOString();\n\n    // Publish 'pending' state.\n    out.push({ topic: stateTopic, retain: true,\n               payload: JSON.stringify({ enabled: true, status: 'pending',\n                                          pendingCloseAt: fireAt }) });\n\n    timers[id] = setTimeout(() => {\n        // Re-read latest rule snapshot — config may have changed mid-flight.\n        const rulesNow = flow.get('rules') || {};\n        const cfgNow = rulesNow[id];\n        delete timers[id];\n        flow.set('timers', timers);\n        if (!cfgNow || !cfgNow.enabled) return;\n        const firedAt = new Date().toISOString();\n        node.send([\n            { topic: cfgNow.target, retain: false, payload: cfgNow.closePayload },\n            { topic: stateTopic, retain: true,\n              payload: JSON.stringify({ enabled: true, status: 'idle',\n                                         lastFiredAt: firedAt }) }\n        ]);\n    }, delaySec * 1000);\n}\n\nflow.set('lastValues', lastValues);\nflow.set('timers', timers);\nreturn [out];",
    "outputs": 1,
    "noerr": 0,
    "x": 480,
    "y": 200,
    "wires": [["zigdash_ac_mqtt_out"]]
  },
  {
    "id": "zigdash_ac_mqtt_out",
    "type": "mqtt out",
    "z": "zigdash_ac_tab",
    "name": "publish (msg.topic / msg.retain)",
    "topic": "",
    "qos": "1",
    "retain": "",
    "broker": "zigdash_ac_broker",
    "x": 800,
    "y": 200,
    "wires": []
  }
]
```

Notes on the flow:
- Subscribes to `zigbee2mqtt/#` (covers the v1 Z2M-only use case). For non-Z2M trigger topics, the user can add additional `mqtt in` nodes wired to the same `zigdash_ac_fn_edge` function. Documented as a v1 simplification in the README.
- The edge-detection function emits per-rule "pending" state immediately, then arms a `setTimeout`. When the timer fires it uses `node.send` directly (not `return`) because by then the original message has already been handled.
- A config change for an existing rule clears the in-flight timer (safety — the new config may have a different target/payload). Lost time is fine for v1; the user re-triggers if they want immediate behavior.
- A tombstone (empty payload) clears the timer + state + rule entry.

- [ ] **Step 2: Commit**

```bash
git add node-red/auto-close-flow.json
git commit -m "feat(node-red): auto-close executor flow (multi-rule)

Generic Node-RED flow: subscribes to zigdash/automation/autoclose/+/config,
watches zigbee2mqtt/# for triggers, fires close payload after delaySeconds
on true OFF->ON edges. Lock semantics (first edge wins). Core nodes only.
Heartbeat is owned by the scheduler flow.

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 11: Node-RED README + manual test cases

**Files:**
- Create: `node-red/AUTO_CLOSE_README.md`

- [ ] **Step 1: Create the README**

Create `node-red/AUTO_CLOSE_README.md`:

````markdown
# Auto-close Node-RED flow

Generic auto-close executor for ZigDash, running on the always-on SMHUB
(SMLIGHT SMHUB Nano 24). ZigDash publishes retained config over MQTT; this
flow watches each rule's `triggerTopic`, detects true OFF→ON edges (ignoring
Z2M's duplicate state messages), and fires the close payload `<delaySeconds>`
later. Core Node-RED nodes only.

> ⚠️ **Not yet verified on hardware.** Import on the SMHUB, deploy, and run
> the manual test cases below before relying on it.

This flow does NOT publish the `bridge/state` heartbeat — that's owned by the
`scheduled-shutter-flow.json` scheduler. Deploy BOTH flows on the same hub
for the "automation offline" chip in the app to work correctly.

## One-time install

1. Open Node-RED on the SMHUB (via the embedded "nodered" app in the SMHUB
   web UI, or `http://10.0.0.57:1880` if reachable on the LAN).
2. Menu (☰) → **Import** → paste the contents of `auto-close-flow.json` →
   **Import**.
3. The import includes an `mqtt-broker` config node ("SMHUB Mosquitto")
   pointed at `10.0.0.57:1883`, no credentials. If your broker differs,
   double-click the imported MQTT nodes and select the correct broker.
4. Click **Deploy**.
5. If `scheduled-shutter-flow.json` was deployed pre-IP-change, re-import
   it too (its broker config still references the old IP `192.168.7.210`).

## What it does (the MQTT contract)

- **Subscribes:** `zigdash/automation/autoclose/+/config` (retained config from ZigDash):
  ```json
  { "name": "...", "triggerTopic": "zigbee2mqtt/door", "triggerPath": "state",
    "triggerValue": "ON", "target": "zigbee2mqtt/door/set",
    "closePayload": "{\"state\":\"OFF\"}", "delaySeconds": 60, "enabled": true }
  ```
- **Watches:** `zigbee2mqtt/#`. For non-Z2M trigger topics, add additional
  `mqtt in` nodes wired to the same `edge detect + arm timer` function node.
- **Fires:** on a true OFF→ON edge per `triggerPath`/`triggerValue`, arms a
  `delaySeconds` timer. When it expires, publishes `closePayload` to `target`.
- **Reports:** retained `zigdash/automation/autoclose/<id>/state`:
  - `{"enabled":true,"status":"idle"}` (or `"disabled"`)
  - `{"enabled":true,"status":"pending","pendingCloseAt":"<UTC ISO-8601>"}`
  - After firing: `{"enabled":true,"status":"idle","lastFiredAt":"<UTC ISO-8601>"}`

### Edge-detection semantics (the central correctness requirement)

Z2M republishes state messages on every `linkquality` change, including
when `state` itself didn't change. A level-triggered design fires forever
on these. This flow holds `lastValues[panelId:triggerTopic]` and fires
only when the previous extracted value differed from the current one
(true OFF→ON edge). While a timer is pending for a rule, further matching
messages are ignored (**Lock semantics**).

## Manual test cases (run after deploy)

From WSL on the dev machine:
```bash
cd ~/projects/zigdash
dart run bin/smoke.dart --host 10.0.0.57 --port 1883 \
  --sub 'zigdash/automation/autoclose/#' --seconds 10
```

1. **Edge fires once.** Publish a rule with `triggerTopic` =
   `zigbee2mqtt/door`, `delaySeconds` = 10 (use a short delay for testing).
   Toggle the door OFF→ON. Exactly one close command must publish to
   `zigbee2mqtt/door/set` 10 seconds later. The state topic must transition
   `idle` → `pending` → `idle` with a populated `lastFiredAt`.
2. **Duplicate ON ignored.** While the timer is pending, manually publish
   another `{"state":"ON"}` message to `zigbee2mqtt/door` via mosquitto_pub.
   The timer must NOT extend (close fires at the original `pendingCloseAt`,
   not 10s later).
3. **Disabled cancels pending.** While a timer is pending, publish an
   updated config with `enabled:false`. The pending timer must be
   cancelled and the state topic must show `{"enabled":false,"status":"disabled"}`.
4. **Tombstone removes rule.** Publish an empty retained payload to the
   `…/config` topic. The state topic must clear (empty retained), any
   pending timer must be cancelled, and the rule must be removed from the
   in-memory map (re-publishing matching trigger messages no longer fires).

Use Test #1 as the regression check after any flow edit; #2 is the
correctness check that proves edge detection works.

## Editing the flow

Adjust node coordinates/IDs freely — they don't affect behavior. The
function-node JavaScript is the meaningful logic; if you change it,
re-run all four manual test cases.
````

- [ ] **Step 2: Commit**

```bash
git add node-red/AUTO_CLOSE_README.md
git commit -m "docs(node-red): auto-close flow install + MQTT contract + tests

Includes the four manual test cases (edge fires once, duplicate ON
ignored, disabled cancels pending, tombstone removes rule). Also notes
that the scheduler flow must be re-imported with the new SMHUB IP
(10.0.0.57) to keep the shared heartbeat working.

Part of: docs/superpowers/specs/2026-06-20-auto-close-rule-design.md"
```

---

## Task 12: End-to-end verification on the real device

This is the final gate. No "done" claim before this passes.

**Pre-reqs:**
- The auto-close flow is imported and deployed on the SMHUB.
- The scheduler flow is also deployed (for the shared heartbeat).
- The `door` Z2M device is online and reachable.
- Latest debug APK installed on the phone (or `flutter run -d <device>`).

- [ ] **Step 1: Build and sideload**

```bash
cd ~/projects/zigdash
flutter build apk --debug
adb -s R5CY247QZGF install -r -d build/app/outputs/flutter-apk/app-debug.apk
```

- [ ] **Step 2: Smoke-test the heartbeat**

```bash
dart run bin/smoke.dart --host 10.0.0.57 --port 1883 \
  --sub 'zigdash/automation/bridge/state' --seconds 5
```

Expected: retained `online` payload prints. If `offline` or no message, the
scheduler flow isn't running — fix that before proceeding (re-import with
the correct broker IP if needed).

- [ ] **Step 3: Create the Auto-close panel in ZigDash**

In the app: pick the dashboard hosting your `door` device → "+" → **Control
→ Auto-close rule** → set:
- Name: `Door auto-close`
- Publish topic: `door`
- Trigger path: `state` (default)
- Trigger value: `ON` (default)
- Close payload: `{"state":"OFF"}` (default)
- Delay (seconds): `60`
- Enabled: ON

Save.

- [ ] **Step 4: Confirm the retained config landed**

```bash
dart run bin/smoke.dart --host 10.0.0.57 --port 1883 \
  --sub 'zigdash/automation/autoclose/#' --seconds 5
```

Expected: one retained `…/config` message with the JSON above, and one
retained `…/state` message with `{"enabled":true,"status":"idle"}`.

- [ ] **Step 5: Trigger the edge**

Turn `door` ON via its regular toggle panel (or physically). Within ~1
second the auto-close tile must show `Closing in 60s` and the `…/state`
retained topic must flip to `status: "pending"` with a `pendingCloseAt`
roughly 60s in the future.

- [ ] **Step 6: Wait 60s — confirm the close fires once**

In a separate terminal, subscribe to the set topic before triggering:
```bash
mosquitto_sub -h 10.0.0.57 -t 'zigbee2mqtt/door/set' -v
```

Expected: exactly one `{"state":"OFF"}` published ~60s after the ON.
The relay must physically click off. The `…/state` topic must flip back
to `status: "idle"` with `lastFiredAt` populated.

- [ ] **Step 7: Test Lock semantics — duplicate ON during pending**

Turn `door` ON. Within 20 seconds, turn it OFF then back ON manually.
Expected: OFF still fires roughly 60s after the FIRST ON (not 60s after
the second ON). The tile's countdown should NOT reset when you re-toggle.

- [ ] **Step 8: Test disable mid-pending**

Turn `door` ON. While the countdown is running, flip the Auto-close
panel's enable switch OFF. Expected: the `…/state` topic flips to
`disabled`, the tile shows `Disabled`, and the close does NOT fire even
after 60s elapses.

- [ ] **Step 9: Test tombstone (panel delete)**

Long-press the panel tile → Delete. Expected: the `…/config` topic
clears (empty retained payload) and any pending timer is cancelled.
Re-triggering the device must NOT fire a close.

- [ ] **Step 10: Commit a verification note (optional)**

If anything required tweaking, commit the fix; otherwise no commit needed.
Record what was verified in the next session's working notes.

---

## Self-Review

**Spec coverage check (against `docs/superpowers/specs/2026-06-20-auto-close-rule-design.md`):**

- §Goal — covered by all UI/flow tasks.
- §Architecture & MQTT contract — Task 3 (publisher topics/payload), Task 10 (Node-RED flow consumes the same wire format), Task 8 (widget reads state).
- §Edge-detection semantics — Task 10's function-node code implements the lastValues map + first-edge-wins Lock semantics.
- §No Drift migration — Task 2 adds the enum value to a `textEnum` field.
- §AutoCloseConfig fields/defaults/bounds — Task 1.
- §AutoCloseConfigPublisher sibling — Task 3 (does NOT modify `automation_config_publisher.dart`).
- §AutoClosePanel widget (4 status states) — Task 8 widget tests cover Idle/Disabled/Offline + Pending countdown.
- §Form fields with defaults — Task 4 + Task 5.
- §Picker entry — Task 7.
- §panel_tile dispatcher + tombstone — Task 6 (committed in Task 8 alongside the widget).
- §l10n keys (EN + HE parity) — Task 9.
- §Node-RED flow + README — Tasks 10 + 11.
- §Error handling (heartbeat stale, publish-while-disconnected, JSON parse failure, missing path) — Task 3 (publish returns false), Task 8 (`offline` flag + snackbar), Task 10 (try/catch around JSON parse + skip-if-undefined).
- §Verification — Task 12.
- §Out of scope (Extend mode, manual cancel, fire-now button, multi-trigger, non-JSON, >1h delay) — Form intentionally omits these; flow accepts `triggerValue`/`closePayload`/`delaySeconds` only.

**Type consistency check:**
- `AutoCloseConfig` field names match across the model (Task 1), the publisher (Task 3 `buildPayload`), the form save (Task 4 Step 8), and the widget (Task 8). ✅
- `AutoCloseConfigPublisher.configTopic`/`stateTopic`/`bridgeStateTopic`/`buildPayload`/`publishConfig`/`clearConfig` — same names in test (Task 3 Step 1), service (Step 3), widget (Task 8 Step 3), panel_tile (Task 6 Step 2), form (Task 4 Step 8). ✅
- Wire-format keys (`triggerTopic`, `triggerPath`, `triggerValue`, `target`, `closePayload`, `delaySeconds`, `enabled`) match between publisher `buildPayload` (Task 3) and Node-RED function reads (Task 10). ✅
- State-payload keys (`status`, `enabled`, `pendingCloseAt`, `lastFiredAt`) match between widget reads (Task 8) and Node-RED writes (Task 10). ✅

**Placeholder scan:** No "TBD" / "TODO" / "similar to Task N" placeholders. Each code block contains the actual code an engineer needs.

Plan ready for execution.
