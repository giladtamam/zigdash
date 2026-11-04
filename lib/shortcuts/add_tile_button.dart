import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics/analytics.dart';

import '../core/l10n/l10n_ext.dart';
import '../features/nfc/nfc_tags.dart';
import '../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'shortcut_service.dart';
import 'shortcut_store.dart';
import 'dart:convert';

/// "Add shortcut" on a device's page (docs/design/roadmap-post-2.0.md,
/// adding shortcuts): a home-screen widget, or a Quick Settings tile for a
/// device that switches or moves ([canTile]).
class AddShortcutButton extends ConsumerWidget {
  const AddShortcutButton({
    super.key,
    required this.connectionId,
    required this.ieee,
    required this.name,
    required this.canTile,
  });

  final String connectionId;
  final String ieee;
  final String name;
  final bool canTile;

  /// Whether shortcuts can be added: Android only. [debugAvailable] stands
  /// in for the platform in tests.
  static bool get available => debugAvailable ?? (!kIsWeb && Platform.isAndroid);
  @visibleForTesting
  static bool? debugAvailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        icon: const Icon(Icons.add_to_home_screen),
        tooltip: context.l10n.shortcutAddShortcut,
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheetCtx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.widgets_outlined),
                  title: Text(context.l10n.shortcutAddToHome),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    addHomeScreenWidget(context, ref.read(shortcutServiceProvider),
                        kind: 'device',
                        connectionId: connectionId,
                        target: ieee,
                        name: name,
                        from: ShortcutFrom.devicePage);
                  },
                ),
                if (canTile &&
                    ref.read(nfcStateProvider).valueOrNull != NfcState.none)
                  ListTile(
                    key: const Key('device-write-nfc'),
                    leading: const Icon(Icons.nfc),
                    title: Text(context.l10n.nfcWriteTag),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      showWriteNfcTag(context,
                          connectionId: connectionId,
                          action: NfcTagAction.toggle,
                          target: ieee,
                          label: name);
                    },
                  ),
                if (canTile)
                  ListTile(
                    leading: const Icon(Icons.dashboard_customize_outlined),
                    title: Text(context.l10n.shortcutAddTile),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      AddTileButton.add(context, ref.read,
                          connectionId: connectionId,
                          ieee: ieee,
                          name: name,
                          from: ShortcutFrom.devicePage);
                    },
                  ),
              ],
            ),
          ),
        ),
      );
}

/// Asks the launcher to pin a widget for a device or scene; explains how to
/// add one by hand when the launcher can't.
Future<void> addHomeScreenWidget(BuildContext context, ShortcutService service,
    {required String kind,
    required String connectionId,
    required String target,
    required String name,
    required ShortcutFrom from}) async {
  final l10n = context.l10n;
  final r = await service.requestPinWidget(
      kind: kind,
      connectionId: connectionId,
      target: target,
      name: name,
      from: from);
  if (r == PinWidgetResult.requested || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.shortcutWidgetHowToTitle),
      content: Text(l10n.shortcutWidgetHowTo),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel)),
      ],
    ),
  );
}

/// Reads a provider: a [WidgetRef]'s or a [ProviderContainer]'s `read`, for
/// callers whose widget may be gone by the time the action runs.
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

/// "Add to Quick Settings" for one device (2.1 §5): assigns a free tile slot
/// (or one the user chooses to replace), then asks Android to add the tile,
/// or explains how on Android 12 and older.
abstract final class AddTileButton {
  static Future<void> add(BuildContext context, ProviderReader read,
      {required String connectionId,
      required String ieee,
      required String name,
      required ShortcutFrom from}) async {
    final l10n = context.l10n;
    final service = read(shortcutServiceProvider);
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
      slot = await _chooseSlotToReplace(context, read);
      if (slot == null) return;
    }
    await service.assignTile(slot,
        connectionId: connectionId, ieee: ieee, name: name);
    read(analyticsProvider).track(ShortcutAdded(ShortcutEventKind.tile, from: from));
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

  static Future<int?> _chooseSlotToReplace(
      BuildContext context, ProviderReader read) {
    final l10n = context.l10n;
    final prefs = read(sharedPreferencesProvider);
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
