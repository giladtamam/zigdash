import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/dashboard_accent.dart';import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/repositories/section_repo.dart';
import '../../devices/device_registry.dart';
import 'tile_actions_sheet.dart';
import '../../../shortcuts/add_tile_button.dart';
import '../../../shortcuts/shortcut_service.dart';

// Edit mode on the dashboard grid (docs/design/dashboard-1.12.md §7).
// Drag rules from the spike: one LongPressDraggable per tile with the
// pointer as anchor, one DragTarget per tile and per section header; a drop
// on a tile's leading half goes before it, on the trailing half after it
// (flipped right-to-left); a drop on a section header goes last in that
// section. The list is reordered and the grid repacks — nothing is placed
// by coordinates.

/// A section being dragged by its grip (tiles are dragged by their id).
class _SectionDrag {
  const _SectionDrag(this.sectionId);
  final String sectionId;
}

/// Scrolls the dashboard while a drag nears its top or bottom edge;
/// Draggable does not do this on its own.
mixin _EdgeScroll<T extends StatefulWidget> on State<T> {
  EdgeDraggingAutoScroller? _scroller;

  void edgeScroll(Offset global) {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;
    _scroller ??= EdgeDraggingAutoScroller(scrollable, velocityScalar: 20);
    _scroller!.startAutoScrollIfNecessary(
        Rect.fromCenter(center: global, width: 48, height: 48));
  }

  void stopEdgeScroll() => _scroller?.stopAutoScroll();
}

/// A tile in Edit mode: dashed outline, grip, ⋯ badge; its controls are
/// inert; long-press drags it.
class EditableTile extends ConsumerStatefulWidget {
  const EditableTile({
    super.key,
    required this.connectionId,
    required this.panel,
    required this.child,
  });

  final String connectionId;
  final Panel panel;
  final Widget child;

  @override
  ConsumerState<EditableTile> createState() => _EditableTileState();
}

class _EditableTileState extends ConsumerState<EditableTile>
    with _EdgeScroll {
  void _options() => showTileActions(context, ref,
      connectionId: widget.connectionId, panel: widget.panel);

  void _dropTile(String id, Offset global) {
    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(global);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final leading =
        rtl ? local.dx > box.size.width / 2 : local.dx < box.size.width / 2;
    final p = widget.panel;
    ref.read(panelRepoProvider).moveTile(
          p.dashboardId,
          id,
          sectionId: p.sectionId,
          beforeId: leading ? p.id : null,
          afterId: leading ? null : p.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final p = widget.panel;

    Widget frame({bool highlight = false}) => CustomPaint(
          foregroundPainter: _DashedOutline(
            color: highlight ? scheme.primary : scheme.outline,
            width: highlight ? 2.5 : 1.5,
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              IgnorePointer(child: widget.child),
              PositionedDirectional(
                top: 8,
                start: 8,
                child: Icon(Icons.drag_indicator,
                    size: 18, color: scheme.onSurfaceVariant),
              ),
              PositionedDirectional(
                top: 2,
                end: 2,
                child: IconButton.filledTonal(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.editTileActions,
                  icon: const Icon(Icons.more_horiz),
                  onPressed: _options,
                ),
              ),
            ],
          ),
        );

    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.editMoveEarlier): () => ref
            .read(panelRepoProvider)
            .moveWithinSection(p.dashboardId, p.id, -1),
        CustomSemanticsAction(label: l10n.editMoveLater): () => ref
            .read(panelRepoProvider)
            .moveWithinSection(p.dashboardId, p.id, 1),
      },
      child: DragTarget<String>(
        onWillAcceptWithDetails: (d) => d.data != p.id,
        onAcceptWithDetails: (d) => _dropTile(d.data, d.offset),
        // No LayoutBuilder here: grid rows size tiles by intrinsic height,
        // which LayoutBuilder cannot report. The preview is a fixed card.
        builder: (context, candidates, _) => LongPressDraggable<String>(
            data: p.id,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragUpdate: (d) => edgeScroll(d.globalPosition),
            onDragEnd: (_) => stopEdgeScroll(),
            onDraggableCanceled: (_, _) => stopEdgeScroll(),
            feedback: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                color: scheme.surfaceContainerHigh,
                child: SizedBox(
                  width: 160,
                  height: 72,
                  child: Center(
                    child: Text(p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                ),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: frame()),
            child: frame(highlight: candidates.isNotEmpty),
          ),
      ),
    );
  }
}

/// A section header in Edit mode: grip to reorder sections, rename, delete.
/// Dropping a tile here puts it last in the section.
class EditableSectionHeader extends ConsumerStatefulWidget {
  const EditableSectionHeader({
    super.key,
    required this.connectionId,
    required this.section,
    required this.sections,
  });

  final String connectionId;
  final Section section;
  final List<Section> sections;

  @override
  ConsumerState<EditableSectionHeader> createState() =>
      _EditableSectionHeaderState();
}

class _EditableSectionHeaderState extends ConsumerState<EditableSectionHeader>
    with _EdgeScroll {
  Future<void> _moveSection(String id, int delta) async {
    final ids = [for (final s in widget.sections) s.id];
    final i = ids.indexOf(id);
    final j = i + delta;
    if (i < 0 || j < 0 || j >= ids.length) return;
    ids.insert(j, ids.removeAt(i));
    await ref.read(sectionRepoProvider).reorder(ids);
  }

  Future<void> _dropSectionBefore(String id) async {
    final ids = [for (final s in widget.sections) s.id]..remove(id);
    ids.insert(ids.indexOf(widget.section.id), id);
    await ref.read(sectionRepoProvider).reorder(ids);
  }

  Future<void> _rename() async {
    final name = await askSectionName(context, initial: widget.section.name);
    if (name != null) {
      await ref.read(sectionRepoProvider).rename(widget.section.id, name);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final deleteTiles = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editDeleteSection),
        content: Text(l10n.editDeleteSectionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.editCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.editDeleteTiles),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.editKeepTiles),
          ),
        ],
      ),
    );
    if (deleteTiles == null) return;
    await ref
        .read(sectionRepoProvider)
        .delete(widget.section.id, deleteTiles: deleteTiles);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final s = widget.section;
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      child: Row(
        children: [
          LongPressDraggable<_SectionDrag>(
            data: _SectionDrag(s.id),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragUpdate: (d) => edgeScroll(d.globalPosition),
            onDragEnd: (_) => stopEdgeScroll(),
            onDraggableCanceled: (_, _) => stopEdgeScroll(),
            feedback: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(s.name, style: theme.textTheme.titleSmall),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_indicator),
            ),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(sectionLabelText(context, s.name),
                  style: sectionLabelStyle(context)
                      .copyWith(color: DashboardAccent.of(context))),
            ),
          ),
          // The section as a group widget on the home screen.
          if (AddShortcutButton.available)
            IconButton(
              tooltip: l10n.shortcutAddToHome,
              icon: const Icon(Icons.add_to_home_screen),
              onPressed: () => addHomeScreenWidget(
                  context, ref.read(shortcutServiceProvider),
                  kind: 'group',
                  connectionId: widget.connectionId,
                  target: s.id,
                  name: s.name),
            ),
          IconButton(
            tooltip: l10n.editRenameSection,
            icon: const Icon(Icons.edit_outlined),
            onPressed: _rename,
          ),
          IconButton(
            tooltip: l10n.editDeleteSection,
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
    );
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.editMoveEarlier): () =>
            _moveSection(s.id, -1),
        CustomSemanticsAction(label: l10n.editMoveLater): () =>
            _moveSection(s.id, 1),
      },
      child: DragTarget<Object>(
        onWillAcceptWithDetails: (d) =>
            d.data is String ||
            (d.data is _SectionDrag &&
                (d.data as _SectionDrag).sectionId != s.id),
        onAcceptWithDetails: (d) {
          final data = d.data;
          if (data is String) {
            ref
                .read(panelRepoProvider)
                .moveTile(s.dashboardId, data, sectionId: s.id);
          } else if (data is _SectionDrag) {
            _dropSectionBefore(data.sectionId);
          }
        },
        builder: (context, candidates, _) => DecoratedBox(
          decoration: BoxDecoration(
            color: candidates.isEmpty
                ? null
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: header,
        ),
      ),
    );
  }
}

/// Asks for a section name; null when cancelled or blank.
Future<String?> askSectionName(BuildContext context, {String initial = ''}) async {
  final l10n = context.l10n;
  final controller = TextEditingController(text: initial);
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(initial.isEmpty ? l10n.editAddSection : l10n.editRenameSection),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 64,
        decoration: InputDecoration(labelText: l10n.editSectionName),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.editCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: Text(l10n.editSave),
        ),
      ],
    ),
  );
  controller.dispose();
  final trimmed = name?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// "N devices aren't on any dashboard" with Add (Add tile, which lists
/// them first) and ✕ (dismiss them). Only in Edit mode; devices are never
/// added automatically.
class UnassignedDevicesCard extends ConsumerWidget {
  const UnassignedDevicesCard({
    super.key,
    required this.connectionId,
    required this.dashboardId,
  });

  final String connectionId;
  final String dashboardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final devices =
        ref.watch(unassignedDevicesProvider(connectionId)).valueOrNull ??
            const [];
    if (devices.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 4, 4),
        child: Row(
          children: [
            const Icon(Icons.new_releases_outlined),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.editUnassigned(devices.length))),
            FilledButton.tonal(
              onPressed: () => context.push(
                  '/connections/$connectionId/dashboards/$dashboardId/add'),
              child: Text(l10n.addTileAdd),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(Icons.close),
              onPressed: () => dismissDevices(ref, connectionId, devices),
            ),
          ],
        ),
      ),
    );
  }
}

/// A rounded dashed outline around an editable tile.
class _DashedOutline extends CustomPainter {
  const _DashedOutline({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2 + 4),
      const Radius.circular(12),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (final metric in (Path()..addRRect(rect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutline old) =>
      old.color != color || old.width != width;
}
