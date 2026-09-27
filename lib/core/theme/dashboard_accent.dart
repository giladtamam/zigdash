import 'package:flutter/material.dart';

/// A dashboard's own colour, as an accent only (signal-2.0.md §1): section
/// labels and the tab indicator. It no longer re-seeds the scheme or the
/// active fill. Toned for the brightness so it stays readable on the ground.
@immutable
class DashboardAccent extends ThemeExtension<DashboardAccent> {
  const DashboardAccent(this.color);

  final Color color;

  /// The accent for a stored dashboard [seed] colour in [brightness].
  factory DashboardAccent.fromSeed(int seed, Brightness brightness) =>
      DashboardAccent(
          ColorScheme.fromSeed(seedColor: Color(seed), brightness: brightness)
              .primary);

  /// The current dashboard's accent, or the scheme's secondary text colour
  /// outside a dashboard.
  static Color of(BuildContext context) =>
      Theme.of(context).extension<DashboardAccent>()?.color ??
      Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  DashboardAccent copyWith({Color? color}) => DashboardAccent(color ?? this.color);

  @override
  DashboardAccent lerp(DashboardAccent? other, double t) =>
      other == null ? this : DashboardAccent(Color.lerp(color, other.color, t)!);
}
