import 'dart:async';
import 'dart:convert';

import '../features/devices/device_profile.dart';
import '../features/devices/device_state.dart';
import '../features/panels/widgets/device_tile_panel.dart'
    show decodeDeviceState, deviceStateLine;
import '../features/scenes/models/scene.dart';
import '../l10n/app_localizations.dart';
import '../mqtt/mqtt_manager.dart';

/// A device a shortcut controls, resolved from its dashboard tile (which
/// follows renames), so the command matches the tile's quick action.
class ShortcutDevice {
  const ShortcutDevice({
    required this.ieee,
    required this.name,
    required this.publishTopic,
    required this.subscribeTopic,
    required this.profile,
  });

  final String ieee;
  final String name;
  final String publishTopic;
  final String subscribeTopic;
  final DeviceProfile profile;

  /// Lights, plugs, switches and covers; sensors only show a reading.
  bool get controllable =>
      profile.deviceClass == DeviceClass.cover || profile.switches.isNotEmpty;
}

/// What happened to a shortcut tap (docs/design/roadmap-post-2.0.md, 2.1 §2).
enum ShortcutOutcome {
  /// The device reported its new state.
  confirmed,

  /// Sent, but no state came back in time ("Not responding").
  unconfirmed,

  /// The broker couldn't be reached ("Can't reach home").
  unreachable,

  /// A scene: every action was published.
  sent,
}

class ShortcutResult {
  const ShortcutResult({
    required this.outcome,
    required this.line,
    this.payload,
    this.on,
    this.at,
  });

  final ShortcutOutcome outcome;

  /// The state line to show (the tile's own words), from the new state when
  /// confirmed, otherwise from the last-known one.
  final String line;

  /// The state payload the line was made from, kept for the next tap.
  final String? payload;

  /// Whether the device reads as on (amber), when it has an on/off state.
  final bool? on;

  /// When [payload] was received.
  final DateTime? at;

  Map<String, Object?> toJson() => {
        'outcome': outcome.name,
        'line': line,
        if (payload != null) 'payload': payload,
        if (on != null) 'on': on,
        if (at != null) 'at': at!.millisecondsSinceEpoch,
      };
}

/// Runs shortcut commands on ZigDash's own [MqttManager]: connect without
/// waiting on what came before, send the tile's command, and wait for the
/// device to confirm.
class ShortcutCommander {
  ShortcutCommander({
    required this.l10n,
    this.connectWithin = const Duration(seconds: 8),
    this.confirmWithin = const Duration(seconds: 5),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppLocalizations l10n;
  final Duration connectWithin;
  final Duration confirmWithin;
  final DateTime Function() _now;

  /// The command a tap sends: covers open or close, everything else toggles
  /// its first switch, from the last-known state.
  static Map<String, Object?> commandFor(ShortcutDevice d, String? lastPayload) {
    final state = DeviceState(d.profile, decodeDeviceState(lastPayload));
    if (d.profile.deviceClass == DeviceClass.cover) {
      final s = state.values['state'];
      final open = (s is String && s.toUpperCase() == 'OPEN') ||
          ((state.position ?? 0) > 0);
      return DeviceCommand.cover(open ? 'CLOSE' : 'OPEN');
    }
    final f = d.profile.switches.first;
    return DeviceCommand.toggle(f, state.isOn(f));
  }

  bool? _onOf(ShortcutDevice d, Map<String, Object?> values) {
    final state = DeviceState(d.profile, values);
    if (d.profile.deviceClass == DeviceClass.cover) {
      final s = values['state'];
      if (s is String) return s.toUpperCase() == 'OPEN';
      final p = state.position;
      return p == null ? null : p > 0;
    }
    final f = d.profile.switches.firstOrNull;
    return f == null ? null : state.isOn(f);
  }

  ShortcutResult _result(ShortcutOutcome outcome, ShortcutDevice d,
      String? payload, DateTime? at) {
    final values = decodeDeviceState(payload);
    return ShortcutResult(
      outcome: outcome,
      line: deviceStateLine(DeviceState(d.profile, values), l10n,
          notResponding: outcome == ShortcutOutcome.unconfirmed &&
              values.isEmpty),
      payload: payload,
      on: _onOf(d, values),
      at: at,
    );
  }

  /// Toggles [d]; [lastPayload] is the state the shortcut last showed.
  Future<ShortcutResult> toggle(
    MqttManager mgr,
    ShortcutDevice d, {
    String? lastPayload,
    DateTime? lastAt,
  }) async {
    if (!await mgr.ensureConnected(timeout: connectWithin)) {
      return _result(ShortcutOutcome.unreachable, d, lastPayload, lastAt);
    }
    final reply = Completer<String>();
    var sent = false;
    final sub = mgr.subscribe(d.subscribeTopic).listen((m) {
      // The subscription replays the newest value first; only a state that
      // arrives after the command is the device's answer.
      if (sent && m.payload.isNotEmpty && !reply.isCompleted) {
        reply.complete(m.payload);
      }
    });
    try {
      mgr.publish(
          d.publishTopic, jsonEncode(commandFor(d, lastPayload)), '');
      sent = true;
      final payload = await reply.future.timeout(confirmWithin);
      return _result(ShortcutOutcome.confirmed, d, payload, _now());
    } on TimeoutException {
      return _result(ShortcutOutcome.unconfirmed, d, lastPayload, lastAt);
    } finally {
      // Not awaited: nothing depends on it, and the subject's cancel can
      // complete in a later turn.
      unawaited(sub.cancel());
      mgr.unsubscribe(d.subscribeTopic);
    }
  }

  /// Runs a scene's actions, as the app's scene tile does.
  Future<ShortcutOutcome> runScene(
      MqttManager mgr, List<SceneAction> actions) async {
    if (!await mgr.ensureConnected(timeout: connectWithin)) {
      return ShortcutOutcome.unreachable;
    }
    for (final a in actions) {
      mgr.publish(a.setTopic, a.payload, '');
    }
    return ShortcutOutcome.sent;
  }
}
