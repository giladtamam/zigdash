/// Classifies a Zigbee2MQTT device from its `definition.exposes` into one of
/// the device-tile classes, and keeps the exposes a device tile needs so it
/// can render offline. Rules: docs/design/research/device-classes.md.
library;

enum DeviceClass {
  colorLight,
  light,
  switchPlug,
  cover,
  leakSmoke,
  contact,
  motion,
  climate,
  generic,
}

/// Z2M access bits.
const int accessState = 0x01;
const int accessSet = 0x02;
const int accessGet = 0x04;

/// One expose, flattened out of its composite, keeping what the tile needs.
class DeviceFeature {
  const DeviceFeature({
    required this.type,
    required this.property,
    this.name,
    this.access = 0,
    this.category,
    this.parent,
    this.endpoint,
    this.unit,
    this.valueOn,
    this.valueOff,
    this.valueToggle,
    this.min,
    this.max,
    this.values,
  });

  /// binary | numeric | enum | text | composite | list
  final String type;

  /// The key in state payloads and `/set` commands (carries the endpoint
  /// suffix, e.g. `state_l1`). Always read and write this, never [name].
  final String property;
  final String? name;
  final int access;

  /// `config` | `diagnostic` | null (normal use).
  final String? category;

  /// Type of the specific composite this feature came from: light, switch,
  /// cover, climate… Null for top-level exposes.
  final String? parent;
  final String? endpoint;
  final String? unit;
  final Object? valueOn;
  final Object? valueOff;
  final Object? valueToggle;
  final num? min;
  final num? max;
  final List<String>? values;

  bool get readable => access & accessState != 0;
  bool get settable => access & accessSet != 0;
  bool get gettable => access & accessGet != 0;
  bool get normal => category == null;

  Map<String, Object?> toJson() => {
        'type': type,
        'property': property,
        if (name != null && name != property) 'name': name,
        'access': access,
        if (category != null) 'category': category,
        if (parent != null) 'parent': parent,
        if (endpoint != null) 'endpoint': endpoint,
        if (unit != null) 'unit': unit,
        if (valueOn != null) 'value_on': valueOn,
        if (valueOff != null) 'value_off': valueOff,
        if (valueToggle != null) 'value_toggle': valueToggle,
        if (min != null) 'value_min': min,
        if (max != null) 'value_max': max,
        if (values != null) 'values': values,
      };

  static DeviceFeature? fromJson(Object? json, {String? parent, String? endpoint}) {
    if (json is! Map) return null;
    final property = json['property'];
    if (property is! String || property.isEmpty) return null;
    final rawAccess = json['access'];
    final values = json['values'];
    return DeviceFeature(
      type: json['type'] as String? ?? 'unknown',
      property: property,
      name: json['name'] as String? ?? property,
      access: rawAccess is num ? rawAccess.toInt() : 0,
      category: json['category'] as String?,
      parent: json['parent'] as String? ?? parent,
      endpoint: json['endpoint'] as String? ?? endpoint,
      unit: json['unit'] as String?,
      valueOn: json['value_on'],
      valueOff: json['value_off'],
      valueToggle: json['value_toggle'],
      min: json['value_min'] as num?,
      max: json['value_max'] as num?,
      values: values is List ? [for (final v in values) v.toString()] : null,
    );
  }
}

/// A device's class and the exposes its tile uses, cached in the tile's
/// config so it renders with the broker unreachable.
class DeviceProfile {
  const DeviceProfile({required this.deviceClass, required this.features});

  final DeviceClass deviceClass;
  final List<DeviceFeature> features;

  /// Normal (no category) features only, as the tile shows them.
  Iterable<DeviceFeature> get normal => features.where((f) => f.normal);

  DeviceFeature? feature(String property) {
    for (final f in features) {
      if (f.property == property) return f;
    }
    return null;
  }

  /// The on/off features of a light or switch, one per endpoint, in expose
  /// order. Only settable ones: a read-only state is not a control.
  List<DeviceFeature> get switches => [
        for (final f in features)
          if (f.type == 'binary' &&
              f.name == 'state' &&
              f.settable &&
              (f.parent == 'light' ||
                  f.parent == 'switch' ||
                  (f.parent == null && f.normal)))
            f,
      ];

  /// The light's brightness feature, if it can be set.
  DeviceFeature? get brightness => _settable('brightness', 'light');
  DeviceFeature? get colorTemp => _settable('color_temp', 'light');
  DeviceFeature? get position => _inParent('position', 'cover');

  /// The primary sensor property: leak/smoke/gas, contact or occupancy.
  DeviceFeature? get alarm => switch (deviceClass) {
        DeviceClass.leakSmoke =>
          _firstBinary(const ['water_leak', 'smoke', 'gas']),
        DeviceClass.contact => _firstBinary(const ['contact']),
        DeviceClass.motion => _firstBinary(const ['occupancy', 'presence']),
        _ => null,
      };

  /// Readable numeric values worth a line on the tile, primary first.
  List<DeviceFeature> get readings {
    const order = [
      'temperature',
      'humidity',
      'power',
      'energy',
      'pressure',
      'illuminance',
      'voltage',
      'current',
    ];
    final found = [
      for (final f in features)
        if (f.type == 'numeric' &&
            f.readable &&
            f.normal &&
            f.parent == null &&
            f.property != 'battery' &&
            f.property != 'linkquality')
          f,
    ];
    int rank(DeviceFeature f) {
      final i = order.indexOf(f.property);
      return i < 0 ? order.length : i;
    }

    found.sort((a, b) => rank(a).compareTo(rank(b)));
    return found;
  }

  DeviceFeature? get battery {
    final f = feature('battery');
    return f != null && f.readable ? f : null;
  }

  DeviceFeature? _settable(String name, String parent) {
    for (final f in features) {
      if (f.name == name && f.parent == parent && f.settable) return f;
    }
    return null;
  }

  DeviceFeature? _inParent(String name, String parent) {
    for (final f in features) {
      if (f.name == name && f.parent == parent) return f;
    }
    return null;
  }

  DeviceFeature? _firstBinary(List<String> properties) {
    for (final p in properties) {
      for (final f in features) {
        if (f.property == p && f.type == 'binary' && f.parent == null) {
          return f;
        }
      }
    }
    return null;
  }

  Map<String, Object?> toJson() => {
        'class': deviceClass.name,
        'features': [for (final f in features) f.toJson()],
      };

  static DeviceProfile fromJson(Object? json) {
    if (json is! Map) {
      return const DeviceProfile(deviceClass: DeviceClass.generic, features: []);
    }
    final name = json['class'];
    final raw = json['features'];
    return DeviceProfile(
      deviceClass: DeviceClass.values.firstWhere(
        (c) => c.name == name,
        orElse: () => DeviceClass.generic,
      ),
      features: [
        if (raw is List)
          for (final f in raw) ?DeviceFeature.fromJson(f),
      ],
    );
  }
}

const _specific = {'light', 'switch', 'cover', 'climate', 'lock', 'fan'};

/// Flattens [exposes] one level into their specific composites (light,
/// switch, cover…), keeping nested composites such as `color_xy` as a single
/// feature named after the composite.
List<DeviceFeature> flattenExposes(List<Object?> exposes) {
  final out = <DeviceFeature>[];
  for (final raw in exposes) {
    if (raw is! Map) continue;
    final type = raw['type'];
    final features = raw['features'];
    if (_specific.contains(type) && features is List) {
      final endpoint = raw['endpoint'] as String?;
      for (final child in features) {
        final f = DeviceFeature.fromJson(
          child,
          parent: type as String,
          endpoint: endpoint,
        );
        if (f != null) out.add(f);
      }
      continue;
    }
    final f = DeviceFeature.fromJson(raw);
    if (f != null) out.add(f);
  }
  return out;
}

/// Classifies a device from its raw `definition.exposes`. Composite kind
/// wins (color light > light > cover > switch), then the most urgent sensor
/// (leak/smoke/gas > contact > motion), then climate; else generic. Only
/// exposes with no `category` decide the class.
DeviceProfile classifyExposes(List<Object?> exposes) {
  final features = flattenExposes(exposes);
  bool hasParent(String p) => features.any((f) => f.parent == p && f.normal);
  bool topBinary(Set<String> props) => features.any((f) =>
      f.parent == null &&
      f.normal &&
      f.type == 'binary' &&
      props.contains(f.property));
  bool topNumeric(Set<String> props) => features.any((f) =>
      f.parent == null &&
      f.normal &&
      f.type == 'numeric' &&
      props.contains(f.property));

  final DeviceClass deviceClass;
  if (hasParent('light')) {
    deviceClass = features.any((f) =>
            f.parent == 'light' &&
            f.type == 'composite' &&
            (f.name == 'color_xy' || f.name == 'color_hs'))
        ? DeviceClass.colorLight
        : DeviceClass.light;
  } else if (hasParent('cover')) {
    deviceClass = DeviceClass.cover;
  } else if (hasParent('switch') ||
      features.any((f) =>
          f.parent == null &&
          f.normal &&
          f.type == 'binary' &&
          f.property == 'state' &&
          f.settable)) {
    deviceClass = DeviceClass.switchPlug;
  } else if (topBinary(const {'water_leak', 'smoke', 'gas'})) {
    deviceClass = DeviceClass.leakSmoke;
  } else if (topBinary(const {'contact'})) {
    deviceClass = DeviceClass.contact;
  } else if (topBinary(const {'occupancy', 'presence'})) {
    deviceClass = DeviceClass.motion;
  } else if (!hasParent('climate') &&
      topNumeric(const {'temperature', 'humidity'})) {
    deviceClass = DeviceClass.climate;
  } else {
    deviceClass = DeviceClass.generic;
  }
  return DeviceProfile(deviceClass: deviceClass, features: features);
}
