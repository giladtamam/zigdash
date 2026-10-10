import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n_ext.dart';
import '../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'shortcut_service.dart';
import 'shortcut_store.dart';
import 'dart:convert';

/// "Add to Quick Settings" for one device (2.1 §5): assigns a free tile slot
/// (or one the user chooses to replace), then asks Android to add the tile,
/// or explains how on Android 12 and older.
class AddTileButton extends ConsumerWidget {
  const AddTileButton({
    super.key,
    required this.connectionId,
    required this.ieee,
    required this.name,
  });

  final String connectionId;
  final String ieee;
  final String name;

  static bool get available => !kIsWeb && Platform.isAndroid;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        icon: const Icon(Icons.dashboard_customize_outlined),
        tooltip: context.l10n.shortcutAddTile,
        onPressed: () => _add(context, ref),
      );

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final service = ref.read(shortcutServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final existing = await service.tileSlotOf(connectionId, ieee);
    if (existing != null) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.shortcutTileAlready(name, existing))));
      return;
    }
    var slot = await service.freeTileSlot();
    if (slot == null) {
      if (!context.mounted) return;
      slot = await _chooseSlotToReplace(context, ref);
      if (slot == null) return;
    }
    await service.assignTile(slot,
        connectionId: connectionId, ieee: ieee, name: name);
    await refreshShortcutTiles();
    final r = await service.requestAddTile(slot, name);
    if (r == AddTileResult.added || r == AddTileResult.already) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.shortcutTileReady(name, slot))));
    } else if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.shortcutTileHowToTitle),
          content: Text(l10n.shortcutTileHowTo(slot!)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(MaterialLocalizations.of(ctx).okButtonLabel)),
          ],
        ),
      );
    }
  }

  Future<int?> _chooseSlotToReplace(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.read(sharedPreferencesProvider);
    String nameIn(int slot) {
      final raw = prefs.getString(shortcutTileKey(slot));
      if (raw == null) return l10n.shortcutSlotEmpty;
      try {
        return (jsonDecode(raw) as Map)['name'] as String? ?? '';
      } catch (_) {
        return '';
      }
    }

    return showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.shortcutSlotsFull),
        children: [
          for (var s = 1; s <= shortcutTileSlots; s++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, s),
              child: ListTile(
                title: Text(l10n.shortcutSlotLabel(s)),
                subtitle: Text(nameIn(s)),
              ),
            ),
        ],
      ),
    );
  }
}
