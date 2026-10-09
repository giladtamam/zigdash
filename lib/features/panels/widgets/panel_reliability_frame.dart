import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/motion.dart';

class PanelReliabilityFrame extends StatelessWidget {
  const PanelReliabilityFrame({
    super.key,
    required this.stale,
    required this.controlsEnabled,
    required this.child,
    this.valueLabel,
    this.receivedAt,
    this.now,
  });

  final bool stale;
  final bool controlsEnabled;
  final Widget child;
  final String? valueLabel;

  /// When the shown value arrived; a stale tile shows its age.
  final DateTime? receivedAt;

  /// Clock for the age (tests).
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final at = receivedAt;
    final chip = at == null
        ? l10n.reliabilityLastKnown
        : formatValueAge(context, at, (now ?? DateTime.now)());
    final semanticsLabel = [
      if (stale) l10n.reliabilityLastKnown,
      if (stale && at != null) chip,
      if (stale && valueLabel != null) valueLabel!,
      if (!controlsEnabled) l10n.reliabilityControlsUnavailable,
    ].join(', ');

    // Not a container: the stale/unavailable note merges into the tile's
    // node (see PanelTile) so it is read together with the name and value.
    return Semantics(
      label: semanticsLabel.isEmpty ? null : semanticsLabel,
      // Passthrough so a grid row's height reaches the card: tiles in a row
      // share the tallest tile's height.
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          AbsorbPointer(
            absorbing: !controlsEnabled,
            child: AnimatedOpacity(
              opacity: stale ? 0.62 : 1,
              duration: SignalMotion.of(context, const Duration(milliseconds: 180)),
              child: child,
            ),
          ),
          if (stale)
            PositionedDirectional(
              top: 6,
              end: 6,
              child: ExcludeSemantics(
                child: IgnorePointer(
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    label: Text(
                      chip,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A value's age for a stale tile: "Just now", "12 min ago", "2 h ago", or
/// the date once it is a day old.
String formatValueAge(BuildContext context, DateTime at, DateTime now) {
  final l10n = context.l10n;
  final age = now.difference(at);
  if (age.inMinutes < 1) return l10n.ageJustNow;
  if (age.inHours < 1) return l10n.ageMinutes(age.inMinutes);
  if (age.inDays < 1) return l10n.ageHours(age.inHours);
  return MaterialLocalizations.of(context).formatShortMonthDay(at);
}
