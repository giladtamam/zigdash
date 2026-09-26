import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';

class PanelReliabilityFrame extends StatelessWidget {
  const PanelReliabilityFrame({
    super.key,
    required this.stale,
    required this.controlsEnabled,
    required this.child,
    this.valueLabel,
  });

  final bool stale;
  final bool controlsEnabled;
  final Widget child;
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semanticsLabel = [
      if (stale) l10n.reliabilityLastKnown,
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
              duration: const Duration(milliseconds: 180),
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
                      l10n.reliabilityLastKnown,
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
