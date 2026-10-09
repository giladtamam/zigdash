import 'package:flutter/widgets.dart';

export 'symbols.g.dart';

/// Draws an app icon from [Symbols], filled when [active] (the second "on"
/// cue beside the amber fill, tokens.md) and outlined otherwise.
class SignalIcon extends StatelessWidget {
  const SignalIcon(
    this.icon, {
    super.key,
    this.active = false,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final bool active;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Icon(
        icon,
        fill: active ? 1 : 0,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
}
