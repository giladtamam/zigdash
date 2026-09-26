import 'dart:math' as math;

import 'device_profile.dart';

/// A device's latest state payload read through its [DeviceProfile]. Every
/// getter returns null while the key has not arrived yet ("waiting for first
/// report"); a tile never infers state from the exposes.
class DeviceState {
  const DeviceState(this.profile, this.values);

  final DeviceProfile profile;

  /// The decoded state payload (`<base>/<friendly name>`), or empty.
  final Map<String, Object?> values;

  bool get hasReported => values.isNotEmpty;

  /// Whether [f] (a binary feature) is on, or null when unknown.
  bool? isOn(DeviceFeature f) {
    final v = values[f.property];
    if (v == null) return null;
    return _same(v, f.valueOn ?? true);
  }

  /// Brightness 0–100, or null.
  int? get brightnessPercent {
    final f = profile.brightness;
    final v = f == null ? null : values[f.property];
    if (v is! num) return null;
    final max = (f!.max ?? 254).toDouble();
    final min = (f.min ?? 0).toDouble();
    if (max <= min) return null;
    return ((v - min) / (max - min) * 100).round().clamp(0, 100);
  }

  /// Cover position 0–100, when the device reports one.
  int? get position {
    final f = profile.position;
    if (f == null || !f.readable) return null;
    final v = values[f.property];
    return v is num ? v.round().clamp(0, 100) : null;
  }

  /// The alarm/contact/occupancy value; for contact, true means closed.
  bool? get alarm {
    final f = profile.alarm;
    return f == null ? null : isOn(f);
  }

  num? reading(DeviceFeature f) {
    final v = values[f.property];
    return v is num ? v : null;
  }

  int? get battery {
    final f = profile.battery;
    final v = f == null ? null : values[f.property];
    return v is num ? v.round() : null;
  }

  /// Low at 20% or below, or when the device says so.
  bool get batteryLow {
    final low = values['battery_low'];
    if (low == true) return true;
    final b = battery;
    return b != null && b <= 20;
  }

  /// The colour a light shows, as 0xRRGGBB, drawn from whichever mode the
  /// bulb reports (`color_mode`), falling back to the keys present.
  int? get lightColor {
    final mode = values['color_mode'];
    final color = values['color'];
    final mired = values['color_temp'];
    if (mode == 'color_temp' && mired is num) return miredToRgb(mired);
    if (color is Map) {
      final x = color['x'], y = color['y'];
      final hue = color['hue'], sat = color['saturation'];
      if (mode == 'xy' && x is num && y is num) return xyToRgb(x, y);
      if (mode == 'hs' && hue is num && sat is num) return hsToRgb(hue, sat);
      if (x is num && y is num) return xyToRgb(x, y);
      if (hue is num && sat is num) return hsToRgb(hue, sat);
    }
    if (mired is num) return miredToRgb(mired);
    return null;
  }

  /// Colour temperature in kelvin, when the bulb is in white mode.
  int? get kelvin {
    final mired = values['color_temp'];
    if (mired is! num || mired <= 0) return null;
    if (values['color_mode'] != null && values['color_mode'] != 'color_temp') {
      return null;
    }
    return (1e6 / mired).round();
  }

  static bool _same(Object a, Object b) =>
      a == b || a.toString().toLowerCase() == b.toString().toLowerCase();
}

/// `/set` payloads for device tiles, all keyed by the expose's `property`.
abstract final class DeviceCommand {
  /// Toggle [f]: `value_toggle` when the device has one, otherwise the
  /// opposite of [currentlyOn]; unknown state sends on.
  static Map<String, Object?> toggle(DeviceFeature f, bool? currentlyOn) {
    final Object value = f.valueToggle ??
        (currentlyOn == true ? (f.valueOff ?? false) : (f.valueOn ?? true));
    return {f.property: value};
  }

  static Map<String, Object?> brightnessPercent(DeviceFeature f, int percent) {
    final min = f.min ?? 0, max = f.max ?? 254;
    return {f.property: (min + (max - min) * percent.clamp(0, 100) / 100).round()};
  }

  static Map<String, Object?> kelvin(DeviceFeature f, int kelvin) {
    var mired = (1e6 / kelvin).round();
    if (f.min != null) mired = math.max(mired, f.min!.toInt());
    if (f.max != null) mired = math.min(mired, f.max!.toInt());
    return {f.property: mired};
  }

  /// Colours are sent as hex, which every Zigbee2MQTT colour light accepts.
  static Map<String, Object?> color(int rgb) => {
        'color': {'hex': '#${(rgb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'},
      };

  static Map<String, Object?> cover(String action) => {'state': action};

  static Map<String, Object?> position(DeviceFeature f, int percent) =>
      {f.property: percent.clamp(0, 100)};

  /// A `/get` request for the readable-and-gettable features, used once per
  /// connection to fill tiles that have no value yet.
  static Map<String, Object?>? refresh(DeviceProfile profile) {
    final props = {
      for (final f in profile.features)
        if (f.gettable && f.readable && f.normal) f.property: '',
    };
    return props.isEmpty ? null : props;
  }
}

/// Approximate colour of black-body light at [mired] (Tanner Helland's fit).
int miredToRgb(num mired) {
  final t = (1e6 / mired) / 100;
  double r, g, b;
  if (t <= 66) {
    r = 255;
    g = 99.4708025861 * math.log(t) - 161.1195681661;
    b = t <= 19 ? 0 : 138.5177312231 * math.log(t - 10) - 305.0447927307;
  } else {
    r = 329.698727446 * math.pow(t - 60, -0.1332047592);
    g = 288.1221695283 * math.pow(t - 60, -0.0755148492);
    b = 255;
  }
  return _rgb(r, g, b);
}

/// CIE xy at full brightness to sRGB.
int xyToRgb(num x, num y) {
  if (y <= 0) return 0xFFFFFF;
  final z = 1 - x - y;
  final bigY = 1.0, bigX = bigY / y * x, bigZ = bigY / y * z;
  var r = bigX * 1.656492 - bigY * 0.354851 - bigZ * 0.255038;
  var g = -bigX * 0.707196 + bigY * 1.655397 + bigZ * 0.036152;
  var b = bigX * 0.051713 - bigY * 0.121364 + bigZ * 1.011530;
  final m = [r, g, b].reduce(math.max);
  if (m > 1) {
    r /= m;
    g /= m;
    b /= m;
  }
  double gamma(double c) => c <= 0.0031308
      ? 12.92 * c
      : 1.055 * math.pow(c, 1 / 2.4).toDouble() - 0.055;
  return _rgb(gamma(r) * 255, gamma(g) * 255, gamma(b) * 255);
}

/// Hue 0–360, saturation 0–100, at full value.
int hsToRgb(num hue, num saturation) {
  final h = (hue % 360) / 60, s = saturation.clamp(0, 100) / 100;
  final c = s, x = c * (1 - ((h % 2) - 1).abs()), m = 1 - c;
  final (r, g, b) = switch (h.floor()) {
    0 => (c, x, 0.0),
    1 => (x, c, 0.0),
    2 => (0.0, c, x),
    3 => (0.0, x, c),
    4 => (x, 0.0, c),
    _ => (c, 0.0, x),
  };
  return _rgb((r + m) * 255, (g + m) * 255, (b + m) * 255);
}

int _rgb(num r, num g, num b) {
  int c(num v) => v.isNaN ? 0 : v.round().clamp(0, 255);
  return (c(r) << 16) | (c(g) << 8) | c(b);
}
