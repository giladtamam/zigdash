import '../../discovery/models/device_panel_suggestion.dart';
import '../../discovery/models/z2m_device.dart';

/// Where a device lands in the review step.
enum ReviewGroup {
  /// Useful controls (lights, covers, switches, buttons, meaningful
  /// sensors) — preselected for the first dashboard.
  recommended,

  /// Coordinator/router diagnostics and duplicate technical entities —
  /// selectable but not preselected.
  other,

  /// Z2M has no converter for the device. Shown explicitly, not selectable.
  unsupported,
}

/// A device row in the review step: the parsed device, its suggested panel,
/// its group, and the user's current selection.
class ReviewRow {
  const ReviewRow({
    required this.device,
    required this.suggestion,
    required this.group,
    required this.selected,
  });

  final Z2mDevice device;
  final PanelSuggestion suggestion;
  final ReviewGroup group;
  final bool selected;

  /// Unsupported devices render but can't be selected.
  bool get selectable => group != ReviewGroup.unsupported;

  ReviewRow copyWith({bool? selected}) => ReviewRow(
        device: device,
        suggestion: suggestion,
        group: group,
        selected: selected ?? this.selected,
      );
}

/// Panel types considered useful first-dashboard controls.
const _recommendedTypes = {
  'light',
  'cover',
  'switch',
  'climate',
};

/// Binary properties that make a sensor "meaningful" (presence/safety).
const _meaningfulBinary = {
  'contact',
  'occupancy',
  'presence',
  'water_leak',
  'vibration',
  'smoke',
  'gas',
  'tamper',
};

/// Builds the review rows from discovered devices: groups them, preselects
/// the recommended ones, and orders recommended → other → unsupported
/// (stable within a group).
///
/// Pure policy: no I/O, no widgets — the UI renders and toggles the result.
List<ReviewRow> recommendDevices(List<Z2mDevice> devices,
    {String base = 'zigbee2mqtt'}) {
  final rows = <ReviewRow>[];
  for (final device in devices) {
    final suggestion = suggestPanel(device, base: base);
    final group = _groupFor(device);
    rows.add(ReviewRow(
      device: device,
      suggestion: suggestion,
      group: group,
      selected: group == ReviewGroup.recommended,
    ));
  }
  rows.sort((a, b) => a.group.index.compareTo(b.group.index));
  return rows;
}

ReviewGroup _groupFor(Z2mDevice device) {
  if (!device.supported) return ReviewGroup.unsupported;
  final e = device.exposes;
  if (e.any((x) => _recommendedTypes.contains(x.type))) {
    return ReviewGroup.recommended;
  }
  // Button-like devices expose an action enum.
  if (e.any((x) => x.type == 'enum' && x.property == 'action')) {
    return ReviewGroup.recommended;
  }
  // Meaningful presence/safety sensors (not plain battery/linkquality).
  if (e.any((x) =>
      x.type == 'binary' &&
      x.property != null &&
      _meaningfulBinary.contains(x.property))) {
    return ReviewGroup.recommended;
  }
  return ReviewGroup.other;
}
