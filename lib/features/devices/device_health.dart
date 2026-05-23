import 'dart:convert';

import 'package:zigdash/features/discovery/models/z2m_device.dart';

/// Per-device health snapshot derived from MQTT state + availability topics.
class DeviceHealth {
  final String friendlyName;
  final int? battery; // 0-100; null if not reported
  final num? linkQuality; // 0-255; null if not reported
  final String? lastSeen; // raw string (ISO or epoch) if present
  final bool? online; // from availability topic; null if unknown

  const DeviceHealth({
    required this.friendlyName,
    this.battery,
    this.linkQuality,
    this.lastSeen,
    this.online,
  });
}

/// Build health rows for [devices].
///
/// [stateByName]        — friendlyName → last state JSON payload.
/// [availabilityByName] — friendlyName → last availability payload.
///
/// Always returns one [DeviceHealth] per entry in [devices] (same order),
/// even when state/availability are missing or malformed — never throws.
List<DeviceHealth> deviceHealthFrom(
  List<Z2mDevice> devices,
  Map<String, String> stateByName,
  Map<String, String> availabilityByName,
) {
  return devices.map((dev) {
    final name = dev.friendlyName;

    // ---------- parse state JSON ----------
    int? battery;
    num? linkQuality;
    String? lastSeen;

    final stateRaw = stateByName[name];
    if (stateRaw != null) {
      try {
        final state = jsonDecode(stateRaw);
        if (state is Map<String, dynamic>) {
          final batRaw = state['battery'];
          if (batRaw is num) battery = batRaw.round();

          final lqRaw = state['linkquality'];
          if (lqRaw is num) linkQuality = lqRaw;

          final lsRaw = state['last_seen'];
          if (lsRaw != null) lastSeen = lsRaw.toString();
        }
      } catch (_) {
        // malformed JSON → leave fields null
      }
    }

    // ---------- parse availability ----------
    bool? online;
    final avRaw = availabilityByName[name];
    if (avRaw != null) {
      if (avRaw == 'online') {
        online = true;
      } else if (avRaw == 'offline') {
        online = false;
      } else {
        // Try JSON {"state":"online"/"offline"}
        try {
          final decoded = jsonDecode(avRaw);
          if (decoded is Map<String, dynamic>) {
            final state = decoded['state'] as String?;
            if (state == 'online') online = true;
            if (state == 'offline') online = false;
          }
        } catch (_) {
          // unrecognised format → online stays null
        }
      }
    }

    return DeviceHealth(
      friendlyName: name,
      battery: battery,
      linkQuality: linkQuality,
      lastSeen: lastSeen,
      online: online,
    );
  }).toList();
}
