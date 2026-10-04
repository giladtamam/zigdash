import 'package:flutter/widgets.dart';

/// Signal motion (signal-2.0.md §6): Material 3 durations, and an instant
/// change wherever the system asks for no animations.
abstract final class SignalMotion {
  /// A tile's fill or a value swapping on a state change.
  static const stateChange = Duration(milliseconds: 200);

  /// Standard M3 duration for small transitions.
  static const standard = Duration(milliseconds: 300);

  /// Emphasized M3 duration for containers.
  static const emphasized = Duration(milliseconds: 500);

  /// [duration], or zero when animations are off (TalkBack users, "Remove
  /// animations" in Android accessibility settings).
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
          ? Duration.zero
          : duration;
}
