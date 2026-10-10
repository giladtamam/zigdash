import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n_ext.dart';
import '../core/router/app_router.dart';
import '../core/router/routes.dart';
import '../data/database/daos/shortcut_dao.dart';
import '../data/database/database.dart';
import '../features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import '../l10n/app_localizations.dart';
import '../mqtt/providers/mqtt_manager_provider.dart';
import 'shortcut_commander.dart';
import 'shortcut_service.dart';
import 'shortcut_store.dart';

/// Connects the running app to its shortcuts: opens the tile picker when an
/// unassigned tile is tapped, writes the native side's words in the app's
/// language, and keeps shortcuts current while the app is open.
class ShortcutAppBridge extends ConsumerStatefulWidget {
  const ShortcutAppBridge({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShortcutAppBridge> createState() => _ShortcutAppBridgeState();
}

class _ShortcutAppBridgeState extends ConsumerState<ShortcutAppBridge> {
  String? _wordsFor;

  @override
  void initState() {
    super.initState();
    appChannel.setMethodCallHandler((call) async {
      if (call.method == 'action') _handle(call.arguments);
      return null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _handle(await appChannel.invokeMethod<Object?>('takeAction'));
      } on MissingPluginException {
        // Not Android.
      }
    });
  }

  void _handle(Object? args) {
    if (args is! Map) return;
    if (args['action'] == 'assignTile') {
      final slot = args['slot'] as int? ?? 1;
      ref.read(routerProvider).push(Routes.shortcutTile(slot));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    if (_wordsFor != locale) {
      _wordsFor = locale;
      unawaited(ref.read(shortcutServiceProvider).writeStrings(l10n));
    }
    ref.watch(shortcutLiveStateProvider(l10n));
    return widget.child;
  }
}

/// While the app runs, every tile shortcut's device is followed on the app's
/// own connection and its state written for the native side, so a tile shows
/// the current state, not the one from its last tap.
final shortcutLiveStateProvider =
    Provider.autoDispose.family<void, AppLocalizations>((ref, l10n) {
  final db = ref.watch(appDatabaseProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final commander = ShortcutCommander(l10n: l10n);
  // The devices currently followed; replaced whenever the shortcuts change.
  var following = <StreamSubscription<Object?>>[];
  var release = <void Function()>[];
  var generation = 0;
  Timer? redraw;

  void stopFollowing() {
    for (final s in following) {
      s.cancel();
    }
    for (final r in release) {
      r();
    }
    following = [];
    release = [];
  }

  Future<void> follow(List<Shortcut> rows) async {
    final mine = ++generation;
    stopFollowing();
    final seen = <String>{};
    for (final row in rows) {
      for (final ieee in shortcutTargets(row)) {
        if (!seen.add('${row.connectionId}/$ieee')) continue;
        final device = await resolveShortcutDevice(db, row.connectionId, ieee);
        if (device == null) continue;
        final mgr =
            await ref.read(mqttManagerProvider(row.connectionId).future);
        if (mine != generation) return; // shortcuts changed meanwhile
        following.add(mgr.subscribe(device.subscribeTopic).listen((m) {
          if (m.payload.isEmpty) return;
          final r = commander.describe(device, m.payload, m.receivedAt);
          prefs.setString(shortcutStateKey(row.connectionId, ieee),
              jsonEncode(r.toJson()));
          redraw?.cancel();
          redraw = Timer(const Duration(milliseconds: 300), refreshShortcutTiles);
        }));
        release.add(() => mgr.unsubscribe(device.subscribeTopic));
      }
    }
  }

  final rows = ShortcutDao(db).watchAll().listen(follow);
  ref.onDispose(() {
    generation++;
    rows.cancel();
    redraw?.cancel();
    stopFollowing();
  });
});
