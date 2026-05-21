import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../data/database/tables/panels.dart';
import '../../../data/repositories/panel_repo.dart';
import 'panel_tile.dart';

/// Renders all panels for a dashboard in a responsive grid. Each panel's
/// [Panel.width] (full/half/third) chooses how much horizontal space it
/// takes within the available row.
class PanelGrid extends ConsumerWidget {
  const PanelGrid({
    super.key,
    required this.connectionId,
    required this.dashboard,
  });

  final String connectionId;
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelsAsync = ref.watch(panelsForDashboardProvider(dashboard.id));

    return panelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.dashLoadFailed(e.toString()))),
      data: (rows) {
        if (rows.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                context.l10n.panelGridEmpty,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return LayoutBuilder(
          builder: (ctx, constraints) {
            final maxW = constraints.maxWidth;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rows.map((p) {
                  final width = switch (p.width) {
                    PanelWidth.full => maxW - 16,
                    PanelWidth.half => (maxW - 24) / 2,
                    PanelWidth.third => (maxW - 32) / 3,
                  };
                  return SizedBox(
                    width: width,
                    child: PanelTile(
                      connectionId: connectionId,
                      dashboardId: dashboard.id,
                      topicPrefix: dashboard.topicPrefix,
                      panel: p,
                      locked: dashboard.locked,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
