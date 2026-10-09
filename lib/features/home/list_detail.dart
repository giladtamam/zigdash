import 'package:flutter/material.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/utils/window_class.dart';
import '../devices/screens/device_page.dart';
import '../devices/screens/devices_screen.dart';
import '../scenes/screens/scene_form_screen.dart';
import '../scenes/screens/scenes_screen.dart';

/// Devices at every width: the list alone, or at expanded width the list
/// beside the selected device's page (devices-tablet-1.13.md §7).
class DevicesDestination extends StatefulWidget {
  const DevicesDestination({
    super.key,
    required this.connectionId,
    this.initialIeee,
  });

  final String connectionId;

  /// The device selected at first (expanded width only).
  final String? initialIeee;

  @override
  State<DevicesDestination> createState() => _DevicesDestinationState();
}

class _DevicesDestinationState extends State<DevicesDestination> {
  late String? _selected = widget.initialIeee;

  @override
  Widget build(BuildContext context) {
    if (WindowClass.of(context) != WindowClass.expanded) {
      return DevicesScreen(connectionId: widget.connectionId);
    }
    final selected = _selected;
    return _ListDetail(
      list: DevicesScreen(
        connectionId: widget.connectionId,
        selectedIeee: selected,
        onSelect: (ieee) => setState(() => _selected = ieee),
      ),
      detail: selected == null
          ? _Empty(context.l10n.devicesSelect)
          : DevicePage(
              key: ValueKey(selected),
              connectionId: widget.connectionId,
              ieee: selected,
              embedded: true,
            ),
      onBack: selected == null ? null : () => setState(() => _selected = null),
    );
  }
}

/// Scenes at every width: at expanded width the list beside the scene
/// being edited or created. Tapping a scene still activates it.
class ScenesDestination extends StatefulWidget {
  const ScenesDestination({super.key, required this.connectionId});

  final String connectionId;

  @override
  State<ScenesDestination> createState() => _ScenesDestinationState();
}

class _ScenesDestinationState extends State<ScenesDestination> {
  /// Null: nothing open. `(id: null)`: a new scene.
  ({String? id})? _editing;

  @override
  Widget build(BuildContext context) {
    if (WindowClass.of(context) != WindowClass.expanded) {
      return ScenesScreen(connectionId: widget.connectionId);
    }
    final editing = _editing;
    void close() => setState(() => _editing = null);
    return _ListDetail(
      list: ScenesScreen(
        connectionId: widget.connectionId,
        selectedId: editing?.id,
        onEdit: (id) => setState(() => _editing = (id: id)),
      ),
      detail: editing == null
          ? _Empty(context.l10n.scenesSelect)
          : SceneFormScreen(
              key: ValueKey(editing.id ?? '__new__'),
              connectionId: widget.connectionId,
              sceneId: editing.id,
              onDone: close,
            ),
      onBack: editing == null ? null : close,
    );
  }
}

class _ListDetail extends StatelessWidget {
  const _ListDetail({required this.list, required this.detail, this.onBack});

  final Widget list;
  final Widget detail;

  /// Clears the selection; system back does this first.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: onBack == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) onBack?.call();
        },
        child: Row(
          children: [
            SizedBox(width: 360, child: list),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: SafeArea(left: false, child: detail),
              ),
            ),
          ],
        ),
      );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
