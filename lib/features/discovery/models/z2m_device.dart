import 'dart:convert';

/// A single expose entry — either a top-level (non-composite) expose or a
/// flattened feature from inside a composite expose (light/switch/cover).
///
/// [type]     — "binary" | "numeric" | "enum" | "light" | "switch" | "cover" | ...
/// [property] — MQTT JSON key (e.g. "state", "brightness", "contact").
/// [unit]     — optional unit string (e.g. "%").
/// [valueOn]  — for binary exposes, the "on" value serialised as a string
///              (e.g. "ON" or "true").
/// [access]   — Z2M access bitmask: bit 0 (1) published in state, bit 1 (2)
///              settable via `<device>/set`, bit 2 (4) gettable. Defaults to 0
///              when absent (e.g. composite parents carry no access of their own).
class Z2mExpose {
  /// Z2M access bit: the property can be written via `<device>/set`.
  static const int accessSet = 0x02;

  final String type;
  final String? property;
  final String? unit;
  final String? valueOn;
  final int access;

  const Z2mExpose({
    required this.type,
    this.property,
    this.unit,
    this.valueOn,
    this.access = 0,
  });

  /// True when this property can be written via `<device>/set`.
  bool get isSettable => property != null && (access & accessSet) != 0;

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

    final rawAccess = map['access'];
    final access = rawAccess is int
        ? rawAccess
        : (rawAccess is num ? rawAccess.toInt() : 0);

    return Z2mExpose(
      type: (map['type'] as String?) ?? 'unknown',
      property: map['property'] as String?,
      unit: map['unit'] as String?,
      valueOn: valueOn,
      access: access,
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

  /// False when Z2M has no converter for the device. Defaults to true: older
  /// payloads and hand-built fixtures omit the flag and mean "works fine".
  final bool supported;

  /// The device's IEEE address, its stable identity across renames. Null
  /// only in hand-built fixtures.
  final String? ieeeAddress;

  /// `definition.exposes` as received, for device-tile classification
  /// (keeps categories, endpoints and nesting that [exposes] flattens away).
  final List<Object?> rawExposes;

  const Z2mDevice({
    required this.friendlyName,
    required this.type,
    this.vendor,
    this.model,
    this.exposes = const [],
    this.supported = true,
    this.ieeeAddress,
    this.rawExposes = const [],
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
      final supported = map['supported'] != false;

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
        supported: supported,
        ieeeAddress: map['ieee_address'] as String?,
        rawExposes: rawExposes,
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
