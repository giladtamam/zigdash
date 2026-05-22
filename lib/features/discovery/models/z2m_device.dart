import 'dart:convert';

/// A single expose entry — either a top-level (non-composite) expose or a
/// flattened feature from inside a composite expose (light/switch/cover).
///
/// [type]     — "binary" | "numeric" | "enum" | "light" | "switch" | "cover" | ...
/// [property] — MQTT JSON key (e.g. "state", "brightness", "contact").
/// [unit]     — optional unit string (e.g. "%").
/// [valueOn]  — for binary exposes, the "on" value serialised as a string
///              (e.g. "ON" or "true").
class Z2mExpose {
  final String type;
  final String? property;
  final String? unit;
  final String? valueOn;

  const Z2mExpose({
    required this.type,
    this.property,
    this.unit,
    this.valueOn,
  });

  factory Z2mExpose._fromMap(Map<String, dynamic> map) {
    final rawValueOn = map['value_on'];
    final String? valueOn;
    if (rawValueOn == null) {
      valueOn = null;
    } else if (rawValueOn is bool) {
      valueOn = rawValueOn.toString(); // true → "true"
    } else {
      valueOn = rawValueOn.toString();
    }

    return Z2mExpose(
      type: (map['type'] as String?) ?? 'unknown',
      property: map['property'] as String?,
      unit: map['unit'] as String?,
      valueOn: valueOn,
    );
  }
}

/// A Zigbee2MQTT device parsed from the `bridge/devices` payload.
///
/// [exposes] is a *flattened* list: composite exposes (light/switch/cover)
/// include the parent entry **and** each of its features, so callers can
/// match both the composite type ("light") and individual properties
/// ("brightness").
class Z2mDevice {
  final String friendlyName;
  final String type; // "Router" | "EndDevice" | "Coordinator"
  final String? vendor;
  final String? model;
  final List<Z2mExpose> exposes;

  const Z2mDevice({
    required this.friendlyName,
    required this.type,
    this.vendor,
    this.model,
    this.exposes = const [],
  });
}

/// Parses the `zigbee2mqtt/bridge/devices` retained JSON payload.
///
/// Returns an empty list on malformed JSON rather than throwing.
/// Coordinators are excluded from the result.
List<Z2mDevice> parseBridgeDevices(String jsonString) {
  try {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) return [];

    final result = <Z2mDevice>[];

    for (final item in decoded) {
      final map = item as Map<String, dynamic>?;
      if (map == null) continue;

      final deviceType = (map['type'] as String?) ?? '';
      if (deviceType == 'Coordinator') continue;

      final friendlyName = (map['friendly_name'] as String?) ?? '';

      final definition = map['definition'] as Map<String, dynamic>?;
      final vendor = definition?['vendor'] as String?;
      final model = definition?['model'] as String?;

      final rawExposes = definition?['exposes'] as List<dynamic>? ?? [];
      final exposes = _flattenExposes(rawExposes);

      result.add(Z2mDevice(
        friendlyName: friendlyName,
        type: deviceType,
        vendor: vendor,
        model: model,
        exposes: exposes,
      ));
    }

    return result;
  } catch (_) {
    return [];
  }
}

/// Flattens the `exposes` array from a device definition.
///
/// Composite exposes (those with a `features` list, e.g. light/switch/cover)
/// produce the parent entry *plus* each flattened feature.  Top-level
/// (non-composite) exposes produce a single entry each.
List<Z2mExpose> _flattenExposes(List<dynamic> rawExposes) {
  final result = <Z2mExpose>[];

  for (final raw in rawExposes) {
    final map = raw as Map<String, dynamic>?;
    if (map == null) continue;

    final features = map['features'] as List<dynamic>?;

    if (features != null && features.isNotEmpty) {
      // Composite expose: add the parent (so we can match on e.g. "light")
      result.add(Z2mExpose._fromMap(map));
      // Then add each child feature
      for (final feat in features) {
        final featMap = feat as Map<String, dynamic>?;
        if (featMap != null) {
          result.add(Z2mExpose._fromMap(featMap));
        }
      }
    } else {
      // Top-level (non-composite) expose
      result.add(Z2mExpose._fromMap(map));
    }
  }

  return result;
}
