import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/theme/motion.dart';
import '../../../core/theme/signal_colors.dart';
import '../../../core/theme/signal_icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/window_class.dart';

// The Signal tile (signal-2.0.md §4), shared by device tiles and custom
// toggles (3.8.7, own-switch-look-387.md §1): moved out of
// device_tile_panel.dart unchanged.

/// The colours drawn on a Signal tile: [fg] for the name, [fgVariant] for
/// the icon and the state line.
({Color fg, Color fgVariant}) signalTileForeground(
  BuildContext context, {
  required bool on,
  bool alarming = false,
}) {
  final roles = SignalColors.of(context);
  final fg = alarming
      ? roles.onAttention
      : on
      ? roles.onActive
      : Theme.of(context).colorScheme.onSurface;
  return (
    fg: fg,
    fgVariant: alarming || on
        ? fg
        : Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

/// A Signal tile's card: amber and borderless when [on], the attention
/// container while [alarming] (pulsing slowly), the idle tile with its
/// hairline otherwise. The fill cross-fades on a state change (M3 standard
/// timing), instantly when the system asks for no animations
/// (signal-2.0.md §6). [onTap] covers the whole tile; [semanticsActions]
/// are added to its node.
class SignalTileCard extends StatelessWidget {
  const SignalTileCard({
    super.key,
    required this.on,
    this.alarming = false,
    required this.child,
    this.onTap,
    this.semanticsActions,
  });

  final bool on;
  final bool alarming;
  final Widget child;
  final VoidCallback? onTap;
  final Map<CustomSemanticsAction, VoidCallback>? semanticsActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roles = SignalColors.of(context);
    final filled = alarming || on;
    const shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadiusDirectional.all(
        Radius.circular(SignalRadii.tile),
      ),
    );
    final idleColor = theme.cardTheme.color ?? roles.idle;
    final Widget ink = InkWell(
      customBorder: shape,
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        end: alarming
            ? roles.attention
            : on
            ? roles.active
            : idleColor,
      ),
      duration: SignalMotion.of(context, SignalMotion.stateChange),
      curve: Curves.easeInOutCubicEmphasized,
      builder: (context, fill, child) => alarming
          ? _AlarmPulse(
              from: fill!,
              to: roles.attentionPulse,
              builder: (pulse) =>
                  Card(color: pulse, shape: shape, child: child),
            )
          : Card(color: fill, shape: filled ? shape : null, child: child),
      child: semanticsActions == null
          ? ink
          : Semantics(customSemanticsActions: semanticsActions, child: ink),
    );
  }
}

/// A leak or smoke alarm's fill, pulsing slowly between [from] and [to]
/// (2 s, signal-2.0.md §6). Steady at [from] when the system turns
/// animations off. Nothing else in the app loops.
class _AlarmPulse extends StatefulWidget {
  const _AlarmPulse({
    required this.from,
    required this.to,
    required this.builder,
  });

  final Color from;
  final Color to;
  final Widget Function(Color fill) builder;

  @override
  State<_AlarmPulse> createState() => _AlarmPulseState();
}

class _AlarmPulseState extends State<_AlarmPulse>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final half = SignalMotion.of(context, SignalMotion.alarmPulseHalf);
    if (half == Duration.zero) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller
        ..duration = half
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => widget.builder(
      Color.lerp(
        widget.from,
        widget.to,
        Curves.easeInOutSine.transform(_controller.value),
      )!,
    ),
  );
}

/// The quick-action chip in a Signal tile's corner. With [onPressed] it is
/// its own target (toggled state, tooltip, tap); without, it is drawn the
/// same and decorative: the card is the target (3.8.7).
class QuickActionChip extends StatelessWidget {
  const QuickActionChip({
    super.key,
    required this.icon,
    required this.on,
    this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final bool? on;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // A squircle, ink with an amber icon when on and raised with an ink
    // icon otherwise (signal-2.0.md §4). Unknown state still switches: the
    // command toggles (or turns on) without knowing the current state.
    final roles = SignalColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isOn = on == true;
    final size = SignalSpacing.quickAction[WindowClass.of(context).index];
    final face = SizedBox.square(
      dimension: size,
      child: Center(
        child: SignalIcon(
          icon,
          active: isOn,
          size: size * 0.5,
          color: isOn ? roles.active : scheme.onSurface,
        ),
      ),
    );
    final material = Material(
      color: isOn ? roles.onActive : roles.raised,
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadiusDirectional.all(
          Radius.circular(SignalRadii.quickAction),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: onPressed == null ? face : InkWell(onTap: onPressed, child: face),
    );
    if (onPressed == null) return ExcludeSemantics(child: material);
    return Semantics(
      toggled: on ?? false,
      child: Tooltip(message: tooltip ?? '', child: material),
    );
  }
}
