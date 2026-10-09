import 'dart:convert';

import 'package:zigdash/features/discovery/models/z2m_device.dart';

/// Battery at or below this percentage counts as low.
const lowBatteryPercent = 20;

/// Link quality below this reads as "Weak". Shown, never counted as
/// attention: it is the last hop of the last message and fluctuates.
const weakLinkQuality = 30;

/// Whether a state payload says the battery is low: `battery_low` true or
/// `battery` ≤ [lowBatteryPercent], either one enough. Null when the payload
/// carries neither field, so a message without battery data (say, only
/// `linkquality`) never reads as "battery fine".
bool? batteryLowIn(Map<String, dynamic> state) {
  final flag = state['battery_low'];
  final pct = state['battery'];
  if (flag is! bool && pct is! num) return null;
  return flag == true || (pct is num && pct <= lowBatteryPercent);
}

/// One device's health, from what Zigbee2MQTT actually reports
/// (docs/design/devices-tablet-1.13.md §2).
class DeviceHealth {
  const DeviceHealth({
    required this.device,
    this.state,
    this.lastHeard,
    this.online,
    this.notResponding = false,
    this.stale = false,
  });

  final Z2mDevice device;

  /// The last state payload, live or last-known; null before any report.
  final Map<String, dynamic>? state;

  /// When [state] arrived (survives restarts through the last-known store).
  final DateTime? lastHeard;

  /// From availability, and only for devices whose availability the bridge
  /// tracks; null otherwise. Never inferred.
  final bool? online;

  /// A state request went unanswered while there is still no state.
  final bool notResponding;

  /// [state] is from before this connection (last known, not fresh).
  final bool stale;

  String get friendlyName => device.friendlyName;

  int? get battery => switch (state?['battery']) {
        final num b => b.round(),
        _ => null,
      };

  num? get linkQuality => switch (state?['linkquality']) {
        final num q => q,
        _ => null,
      };

  bool get lowBattery => state != null && batteryLowIn(state!) == true;

  bool get weakLink => (linkQuality ?? weakLinkQuality) < weakLinkQuality;

  bool get offline => online == false;

  bool get unsupported => !device.supported;

  /// Low battery, offline (when tracked), not responding, a failed
  /// interview or an unsupported device.
  bool get needsAttention =>
      lowBattery ||
      offline ||
      notResponding ||
      device.interviewFailed ||
      unsupported;
}

/// Parses an availability payload: Zigbee2MQTT 2.x JSON `{"state": …}` or a
/// 1.x plain string. Null when unreadable.
bool? parseAvailability(String payload) {
  if (payload == 'online') return true;
  if (payload == 'offline') return false;
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map) {
      final s = decoded['state'];
      if (s == 'online') return true;
      if (s == 'offline') return false;
    }
  } catch (_) {}
  return null;
}

/// A state payload as a map, or null when it is not a JSON object.
Map<String, dynamic>? parseState(String payload) {
  try {
    final decoded = jsonDecode(payload);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

/// Builds one [DeviceHealth] per device, in order. Never throws.
///
/// [states] and [availability] are keyed by friendly name. [tracked] says
/// whether the bridge tracks a device's availability (by IEEE); untracked
/// devices get no online/offline, whatever the broker retained.
/// [notResponding] names devices whose state request timed out.
List<DeviceHealth> deviceHealthFrom(
  List<Z2mDevice> devices, {
  Map<String, ({String payload, DateTime at})> states = const {},
  Map<String, String> availability = const {},
  bool Function(String? ieee) tracked = _never,
  Set<String> notResponding = const {},
  Set<String> stale = const {},
}) =>
    [
      for (final d in devices)
        () {
          final s = states[d.friendlyName];
          final state = s == null ? null : parseState(s.payload);
          final av = availability[d.friendlyName];
          return DeviceHealth(
            device: d,
            state: state,
            lastHeard: s?.at,
            online: av != null && tracked(d.ieeeAddress)
                ? parseAvailability(av)
                : null,
            notResponding:
                state == null && notResponding.contains(d.friendlyName),
            stale: state != null && stale.contains(d.friendlyName),
          );
        }(),
    ];

bool _never(String? _) => false;

/// Needs attention first, then by name.
int compareHealth(DeviceHealth a, DeviceHealth b) {
  if (a.needsAttention != b.needsAttention) return a.needsAttention ? -1 : 1;
  return a.friendlyName.toLowerCase().compareTo(b.friendlyName.toLowerCase());
}
