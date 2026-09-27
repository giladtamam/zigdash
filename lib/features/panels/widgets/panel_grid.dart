import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/dashboard_accent.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/repositories/section_repo.dart';
import '../../dashboards/edit_mode.dart';
import '../models/grid_layout.dart';
import 'edit_grid.dart';
import 'panel_tile.dart';

/// Renders a dashboard's tiles on a column grid (2 / 3 / 4 columns by window
/// width). A tile's [Panel.width] is its size: Small spans one column, Wide
/// two, Full the row. Rows take their tallest tile's height. Tiles with no
/// section come first, then each section under its header.
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
    final editing = ref.watch(editModeProvider) == dashboard.id;

    return panelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(context.l10n.dashLoadFailed(e.toString()))),
      data: (rows) {
        if (rows.isEmpty && !editing) {
          final theme = Theme.of(context);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.widgets_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.panelGridEmpty,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        final sections = ref.watch(sectionsForDashboardProvider(dashboard.id))
                .value ??
            const <Section>[];
        final grid = LayoutBuilder(
          builder: (ctx, constraints) {
            final width = constraints.maxWidth;
            // The window decides the columns, not the space the rail leaves:
            // a 600 dp window keeps its 3 columns when the rail appears.
            final window = MediaQuery.sizeOf(ctx).width;
            final columns = gridColumns(
              window,
              textScale: MediaQuery.textScalerOf(ctx).scale(1),
            );
            final minHeight = minTileHeight(window);
            final columnWidth =
                (width - 16 - (columns - 1) * _GridRow.gap) / columns;
            Widget tile(Panel p) {
              final t = PanelTile(
                connectionId: connectionId,
                dashboardId: dashboard.id,
                topicPrefix: dashboard.topicPrefix,
                panel: p,
                locked: dashboard.locked,
              );
              return editing
                  ? EditableTile(
                      key: ValueKey(p.id),
                      connectionId: connectionId,
                      panel: p,
                      child: t,
                    )
                  : t;
            }

            final children = <Widget>[
              if (editing)
                UnassignedDevicesCard(
                  connectionId: connectionId,
                  dashboardId: dashboard.id,
                ),
            ];
            void addTiles(List<Panel> tiles) {
              for (final row in packRows(tiles, (p) => p.width, columns)) {
                children.add(_GridRow(
                  columnWidth: columnWidth,
                  minHeight: minHeight,
                  cells: [for (final c in row) (child: tile(c.tile), span: c.span)],
                ));
              }
            }

            final known = {for (final s in sections) s.id};
            addTiles([
              for (final p in rows)
                if (!known.contains(p.sectionId)) p,
            ]);
            for (final section in sections) {
              final tiles = [
                for (final p in rows)
                  if (p.sectionId == section.id) p,
              ];
              children.add(editing
                  ? EditableSectionHeader(
                      key: ValueKey(section.id),
                      section: section,
                      sections: sections,
                    )
                  : _SectionHeader(name: section.name));
              addTiles(tiles);
            }
            return SingleChildScrollView(
              // Room below the last row for the Edit-mode bar and the FAB.
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            );
          },
        );
        return grid;
      },
    );
  }
}

/// One grid row: cells share the row's height (the tallest cell's, never
/// below [minHeight]); an unfilled end stays empty.
class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.columnWidth,
    required this.minHeight,
    required this.cells,
  });

  static const gap = 8.0;

  final double columnWidth;
  final double minHeight;
  final List<({Widget child, int span})> cells;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: gap),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: [
            for (final c in cells)
              SizedBox(
                width: c.span * columnWidth + (c.span - 1) * gap,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: c.child,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
      child: Semantics(
        header: true,
        child: Text(sectionLabelText(context, name),
            style: sectionLabelStyle(context)
                .copyWith(color: DashboardAccent.of(context))),
      ),
    );
  }
}
