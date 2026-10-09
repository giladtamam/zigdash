import 'dart:convert';

/// A bridge request ready to publish over MQTT.
class BridgeRequest {
  final String topic;
  final String payload; // JSON string

  const BridgeRequest({required this.topic, required this.payload});
}

// ---------------------------------------------------------------------------
// Request builders
// ---------------------------------------------------------------------------

/// Build a permit_join request.
///
/// [enable] = true → starts pairing for [time] seconds (default 254).
/// [enable] = false → stops pairing with `time: 0`.
///
/// Zigbee2MQTT 2.x reads only `time` and rejects a payload without it
/// ("Invalid payload"), so stopping must send `time: 0`. 1.x reads `value`,
/// so both keys are sent.
BridgeRequest permitJoinRequest(
  String base, {
  required bool enable,
  int time = 254,
}) {
  final body = <String, dynamic>{'value': enable, 'time': enable ? time : 0};
  return BridgeRequest(
    topic: '$base/bridge/request/permit_join',
    payload: jsonEncode(body),
  );
}

/// Build a request that restarts Zigbee2MQTT. On start it publishes its
/// retained `bridge/devices` list again, which a broker restart can lose.
BridgeRequest restartRequest(String base) =>
    BridgeRequest(topic: '$base/bridge/request/restart', payload: '{}');

/// Build a device rename request.
BridgeRequest renameRequest(String base, String from, String to) {
  return BridgeRequest(
    topic: '$base/bridge/request/device/rename',
    payload: jsonEncode({'from': from, 'to': to}),
  );
}

/// Build a device remove request.
BridgeRequest removeRequest(String base, String id, {bool force = false}) {
  return BridgeRequest(
    topic: '$base/bridge/request/device/remove',
    payload: jsonEncode({'id': id, 'force': force}),
  );
}

// ---------------------------------------------------------------------------
// Bridge event parser
// ---------------------------------------------------------------------------

enum BridgeEventType {
  deviceJoined,
  deviceInterview,
  deviceAnnounce,
  deviceLeave,
  unknown,
}

class BridgeEvent {
  final BridgeEventType type;
  final String? friendlyName;
  final String? interviewStatus;

  const BridgeEvent({
    required this.type,
    this.friendlyName,
    this.interviewStatus,
  });
}

/// Parse a `<base>/bridge/event` payload tolerantly.
///
/// Returns a [BridgeEvent] with [BridgeEventType.unknown] on bad JSON or
/// unrecognised event type — never throws.
BridgeEvent parseBridgeEvent(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const BridgeEvent(type: BridgeEventType.unknown);
    }

    final typeStr = decoded['type'] as String?;
    final data = decoded['data'] as Map<String, dynamic>?;
    final friendlyName = data?['friendly_name'] as String?;
    final interviewStatus = data?['status'] as String?;

    final eventType = switch (typeStr) {
      'device_joined' => BridgeEventType.deviceJoined,
      'device_interview' => BridgeEventType.deviceInterview,
      'device_announce' => BridgeEventType.deviceAnnounce,
      'device_leave' => BridgeEventType.deviceLeave,
      _ => BridgeEventType.unknown,
    };

    return BridgeEvent(
      type: eventType,
      friendlyName: friendlyName,
      interviewStatus:
          eventType == BridgeEventType.deviceInterview ? interviewStatus : null,
    );
  } catch (_) {
    return const BridgeEvent(type: BridgeEventType.unknown);
  }
}

/// Whether Zigbee2MQTT tracks availability, from the retained `bridge/info`
/// `config`: the global `availability.enabled` switch (a bare `true` on
/// older bridges) and per-device `devices.<ieee>.availability` overrides.
/// Availability messages count only for devices this says are tracked, so a
/// retained message left from before availability was turned off is ignored.
class AvailabilityConfig {
  const AvailabilityConfig({this.enabled = false, this.perDevice = const {}});

  /// Nothing known yet: availability is not counted.
  static const unknown = AvailabilityConfig();

  final bool enabled;

  /// IEEE address → tracked, for devices with their own setting.
  final Map<String, bool> perDevice;

  bool tracks(String? ieee) => perDevice[ieee] ?? enabled;

  /// True when any device is tracked.
  bool get any => enabled || perDevice.values.any((v) => v);
}

AvailabilityConfig parseAvailabilityConfig(String bridgeInfo) {
  try {
    final info = jsonDecode(bridgeInfo);
    final config = info is Map ? info['config'] : null;
    if (config is! Map) return AvailabilityConfig.unknown;
    final a = config['availability'];
    final enabled = a == true || (a is Map && a['enabled'] == true);
    final perDevice = <String, bool>{};
    final devices = config['devices'];
    if (devices is Map) {
      devices.forEach((ieee, options) {
        final v = options is Map ? options['availability'] : null;
        if (v == null) return;
        perDevice[ieee as String] = v != false;
      });
    }
    return AvailabilityConfig(enabled: enabled, perDevice: perDevice);
  } catch (_) {
    return AvailabilityConfig.unknown;
  }
}
