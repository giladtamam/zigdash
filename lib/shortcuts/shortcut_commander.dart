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
    this.level,
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

  /// A shutter's position or a light's brightness, 0–100 (Device Controls
  /// draw it as a slider).
  final int? level;

  Map<String, Object?> toJson() => {
        'outcome': outcome.name,
        'line': line,
        if (payload != null) 'payload': payload,
        if (on != null) 'on': on,
        if (at != null) 'at': at!.millisecondsSinceEpoch,
        if (level != null) 'level': level,
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
    this.maxSilence = const Duration(seconds: 3),
    this.knownStateWithin = const Duration(milliseconds: 300),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppLocalizations l10n;
  final Duration connectWithin;
  final Duration confirmWithin;

  /// A connection quiet for longer is replaced before sending: between taps
  /// Android freezes the app and its socket dies unnoticed (measured).
  final Duration maxSilence;

  /// How long a first tap waits for the device's current state.
  final Duration knownStateWithin;
  final DateTime Function() _now;

  /// The command a tap sends: covers open or close, everything else switches
  /// its first switch. With the state known it sends the target value (ON or
  /// OFF), never TOGGLE, so only a reply holding that value confirms the
  /// tap; TOGGLE is left for a device whose state is unknown.
  static Map<String, Object?> commandFor(ShortcutDevice d, String? lastPayload) {
    final state = DeviceState(d.profile, decodeDeviceState(lastPayload));
    if (d.profile.deviceClass == DeviceClass.cover) {
      final s = state.values['state'];
      final open = (s is String && s.toUpperCase() == 'OPEN') ||
          ((state.position ?? 0) > 0);
      return DeviceCommand.cover(open ? 'CLOSE' : 'OPEN');
    }
    final f = d.profile.switches.first;
    final on = state.isOn(f);
    if (on == null) return DeviceCommand.toggle(f, null);
    return {f.property: on ? (f.valueOff ?? false) : (f.valueOn ?? true)};
  }

  /// Device Controls' on or off: the switch's own value (a shutter opens or
  /// closes).
  static Map<String, Object?> switchTo(ShortcutDevice d, {required bool on}) {
    if (d.profile.deviceClass == DeviceClass.cover) {
      return DeviceCommand.cover(on ? 'OPEN' : 'CLOSE');
    }
    final f = d.profile.switches.first;
    return {f.property: on ? (f.valueOn ?? true) : (f.valueOff ?? false)};
  }

  /// Device Controls' slider: a shutter's position or a light's brightness,
  /// [percent] 0–100; null when the device has neither.
  static Map<String, Object?>? levelTo(ShortcutDevice d, int percent) {
    final position = d.profile.position;
    if (d.profile.deviceClass == DeviceClass.cover && position != null) {
      return DeviceCommand.position(position, percent);
    }
    final brightness = d.profile.brightness;
    return brightness == null
        ? null
        : DeviceCommand.brightnessPercent(brightness, percent);
  }

  /// The `/get` request that fills a shortcut: only what it shows (on/off,
  /// brightness, position). Null for a device that isn't asked: a sensor,
  /// often asleep on batteries, reports by itself. Kept small because a
  /// burst of requests can overwhelm a hub's Zigbee radio (seen on an SMHUB
  /// with EmberZNet 7.4.2: the adapter crashed and Zigbee2MQTT restarted).
  static Map<String, Object?>? stateRequest(ShortcutDevice d) {
    final p = d.profile;
    final features = p.deviceClass == DeviceClass.cover
        ? [p.position ?? p.feature('state')]
        : p.switches.isEmpty
            ? const <DeviceFeature?>[]
            : [p.switches.first, p.brightness];
    final props = {
      for (final f in features)
        if (f != null && f.gettable) f.property: '',
    };
    return props.isEmpty ? null : props;
  }

  /// Whether a state the device reported answers [command]: every commanded
  /// key now holds the commanded value ("CLOSE" and "CLOSED" alike), or, for
  /// TOGGLE, a value different from [before]. A stale copy (the broker's
  /// retained state, or another client's older message) doesn't count.
  static bool confirms(Map<String, Object?> command, Map<String, Object?> state,
      Map<String, Object?> before) {
    String norm(Object? v) {
      final s = '$v'.toUpperCase();
      return s == 'CLOSED' ? 'CLOSE' : s;
    }

    // STOP: any report after it (the motor has stopped, or says so) answers.
    if (command['state'] is String && norm(command['state']) == 'STOP') {
      return true;
    }
    // A position: the motor starting, the position changing, or arriving.
    final wanted = command['position'];
    if (wanted != null) {
      final motor = state['motor_run_status'];
      final pos = state['position'], was = before['position'];
      return (motor is String && norm(motor) != 'STOP') ||
          (pos != null && (pos == wanted || (was != null && pos != was)));
    }
    // A shutter takes several seconds to travel and only reports its final
    // state at the end, so the motor starting (or the position changing) is
    // the confirmation. Measured on a SONOFF MINI-ZBRBS: it reports
    // motor_run_status every 5 s while moving.
    final target = command['state'];
    if (target is String &&
        (norm(target) == 'OPEN' || norm(target) == 'CLOSE') &&
        state['state'] != null &&
        norm(state['state']) != norm(target)) {
      final motor = state['motor_run_status'];
      final pos = state['position'], was = before['position'];
      if ((motor is String && norm(motor) != 'STOP') ||
          (pos != null && was != null && pos != was)) {
        return true;
      }
    }
    for (final MapEntry(:key, :value) in command.entries) {
      final now = state[key];
      if (now == null) {
        // Same as above, for a shutter that leaves "state" out.
        if (key == 'state' && state['motor_run_status'] is String) {
          return norm(state['motor_run_status']) != 'STOP';
        }
        return false;
      }
      if (norm(value) == 'TOGGLE') {
        final was = before[key];
        if (was != null && norm(was) == norm(now)) return false;
        continue;
      }
      if (norm(now) != norm(value)) return false;
    }
    return true;
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
    final state = DeviceState(d.profile, values);
    return ShortcutResult(
      outcome: outcome,
      line: deviceStateLine(DeviceState(d.profile, values), l10n,
          notResponding: outcome == ShortcutOutcome.unconfirmed &&
              values.isEmpty),
      payload: payload,
      on: _onOf(d, values),
      at: at,
      level: d.profile.deviceClass == DeviceClass.cover
          ? state.position
          : state.brightnessPercent,
    );
  }

  bool _unknown(ShortcutDevice d, Map<String, Object?> before) {
    if (d.profile.deviceClass == DeviceClass.cover) {
      return before['state'] == null && before['position'] == null;
    }
    final f = d.profile.switches.firstOrNull;
    return f == null || before[f.property] == null;
  }

  /// What a shortcut shows for [payload] (received at [at]), without a tap:
  /// used while the app runs to keep shortcuts current.
  ShortcutResult describe(ShortcutDevice d, String payload, DateTime at) =>
      _result(ShortcutOutcome.confirmed, d, payload, at);

  /// Toggles [d]; [lastPayload] is the state the shortcut last showed.
  /// Toggles [d], or sends [command] instead (a shutter's OPEN, STOP,
  /// CLOSE or position from the slider pop-up).
  Future<ShortcutResult> toggle(
    MqttManager mgr,
    ShortcutDevice d, {
    String? lastPayload,
    DateTime? lastAt,
    Map<String, Object?>? command,
  }) async {
    final fixed = command;
    return _send(mgr, d, fixed, lastPayload, lastAt);
  }

  Future<ShortcutResult> _send(MqttManager mgr, ShortcutDevice d,
      Map<String, Object?>? fixed, String? lastPayload, DateTime? lastAt) async {
    if (!await mgr.ensureConnected(
        timeout: connectWithin, maxSilence: maxSilence)) {
      return _result(ShortcutOutcome.unreachable, d, lastPayload, lastAt);
    }
    final reply = Completer<String>();
    final current = Completer<String>();
    var command = fixed ?? commandFor(d, lastPayload);
    var before = decodeDeviceState(lastPayload);
    var sent = false;
    DateTime? sentAt;
    final sub = mgr.subscribe(d.subscribeTopic).listen((m) {
      if (m.payload.isEmpty) return;
      if (!sent) {
        if (!current.isCompleted) current.complete(m.payload);
        return;
      }
      // Only a state matching the command is the device's answer: the
      // broker's old copy can still arrive after sending.
      // The subscription replays the last value it holds, received before
      // the send: never an answer, however well it matches.
      if (!reply.isCompleted &&
          !m.receivedAt.isBefore(sentAt!) &&
          confirms(command, decodeDeviceState(m.payload), before)) {
        reply.complete(m.payload);
      }
    });
    try {
      // State unknown (a first tap): take the device's current state if it
      // arrives quickly, so the command can name its target value.
      if (fixed == null && _unknown(d, before)) {
        final now = await current.future
            .timeout(knownStateWithin, onTimeout: () => '');
        if (now.isNotEmpty) {
          lastPayload = now;
          before = decodeDeviceState(now);
          command = commandFor(d, now);
        }
      }
      sentAt = DateTime.now();
      mgr.publish(d.publishTopic, jsonEncode(command), '');
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
    if (!await mgr.ensureConnected(
        timeout: connectWithin, maxSilence: maxSilence)) {
      return ShortcutOutcome.unreachable;
    }
    for (final a in actions) {
      mgr.publish(a.setTopic, a.payload, '');
    }
    return ShortcutOutcome.sent;
  }
}
