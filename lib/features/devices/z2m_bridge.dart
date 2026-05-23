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
/// [enable] = false → stops pairing; [time] is omitted from the payload.
BridgeRequest permitJoinRequest(
  String base, {
  required bool enable,
  int time = 254,
}) {
  final Map<String, dynamic> body = {'value': enable};
  if (enable) body['time'] = time;
  return BridgeRequest(
    topic: '$base/bridge/request/permit_join',
    payload: jsonEncode(body),
  );
}

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
