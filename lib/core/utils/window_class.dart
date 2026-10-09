import 'package:flutter/widgets.dart';

/// Material 3 window size classes by width (devices-tablet-1.13.md §7):
/// compact < 600 dp (bottom bar), medium < 840 (navigation rail), expanded
/// (rail and list-detail).
enum WindowClass {
  compact,
  medium,
  expanded;

  static WindowClass of(BuildContext context) =>
      forWidth(MediaQuery.sizeOf(context).width);

  static WindowClass forWidth(double width) => width < 600
      ? WindowClass.compact
      : width < 840
          ? WindowClass.medium
          : WindowClass.expanded;

  bool get hasRail => this != WindowClass.compact;
}
