import 'dart:async';

import '../alerts/alert_push.dart';
import '../alerts/alerts_service.dart';
import 'dart:convert';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics/analytics.dart';
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
import 'shortcut_usage.dart';

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
  StreamSubscription<Object?>? _dashboardChanges;
  Timer? _resync;

  StreamSubscription<Object?>? _alertTaps;
  StreamSubscription<Object?>? _alertEndpoints;
  StreamSubscription<Object?>? _alertConfigs;
  final _alertFollows = <String, StreamSubscription<Object?>?>{};

  @override
  void dispose() {
    _dashboardChanges?.cancel();
    _resync?.cancel();
    _alertTaps?.cancel();
    _alertEndpoints?.cancel();
    _alertConfigs?.cancel();
    for (final s in _alertFollows.values) {
      s?.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    appChannel.setMethodCallHandler((call) async {
      if (call.method == 'action') _handle(call.arguments);
      return null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = ref.read(shortcutServiceProvider);
      unawaited(service
          .syncWidgets()
          .then((_) => service.resyncTiles())
          .then((_) => refreshShortcutTiles()));
      unawaited(service.resyncControls());
      unawaited(service.resyncScenes());
      unawaited(service.resyncGroups());
      // Uses noted by tiles and Device Controls while the app was closed.
      unawaited(reportShortcutUsage(
          ref.read(sharedPreferencesProvider), ref.read(analyticsProvider)));
      // Device Controls and tiles show what's on the dashboards: follow
      // changes.
      final db = ref.read(appDatabaseProvider);
      _dashboardChanges = db
          .tableUpdates(TableUpdateQuery.onAllTables(
              [db.panels, db.dashboards, db.connections, db.shortcuts,
                db.scenes, db.sections]))
          .listen((_) {
        _resync?.cancel();
        _resync = Timer(const Duration(seconds: 1), () async {
          await service.resyncControls();
          await service.resyncScenes();
          await service.resyncGroups();
          // Tiles follow renames and deleted Homes without a restart.
          await service.resyncTiles();
          await refreshShortcutTiles();
        });
      });
      try {
        _handle(await appChannel.invokeMethod<Object?>('takeAction'));
      } on MissingPluginException {
        // Not Android.
      }
      // Alerts (alerts-2.3.md): a tap on a notification opens the device;
      // a push registration lands in the Home's config; the broker's copy
      // of each Home's config is followed while connected.
      final alerts = ref.read(alertsServiceProvider);
      final launched = await AlertPush.takeLaunchTap();
      if (launched != null) _openFromAlert(launched);
      _alertTaps = AlertPush.taps.stream.listen(_openFromAlert);
      _alertEndpoints = AlertPush.endpoints.stream
          .listen((e) => alerts.onEndpoint(e.$1, e.$2));
      _alertConfigs = db.select(db.alertConfigs).watch().listen((rows) async {
        final wanted = {for (final r in rows) r.connectionId};
        for (final id in _alertFollows.keys.toList()) {
          if (!wanted.contains(id)) await _alertFollows.remove(id)?.cancel();
        }
        for (final id in wanted) {
          if (_alertFollows.containsKey(id)) continue;
          _alertFollows[id] = null;
          final sub = await alerts.followRetained(id);
          if (_alertFollows.containsKey(id)) _alertFollows[id] = sub;
        }
      });
    });
  }

  void _openFromAlert((String, String?) tap) {
    final (home, ieee) = tap;
    if (ieee != null) {
      ref.read(routerProvider).push(Routes.homeDevice(home, ieee));
    }
  }

  void _handle(Object? args) {
    if (args is! Map) return;
    if (args['action'] == 'assignTile') {
      final slot = args['slot'] as int? ?? 1;
      ref.read(routerProvider).push(Routes.shortcutTile(slot));
    } else if (args['action'] == 'openDevice') {
      // A long-press on a Device Controls card.
      final home = args['connectionId'] as String?;
      final ieee = args['ieee'] as String?;
      if (home != null && ieee != null) {
        ref.read(routerProvider).push(Routes.homeDevice(home, ieee));
      }
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
          debugPrint('shortcut live: ${device.name} on=${r.on} ${r.line}');
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
