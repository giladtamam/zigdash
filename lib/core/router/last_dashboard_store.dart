import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/connection_repo.dart';
import '../../features/settings/providers/settings_controller.dart';
import 'routes.dart';

/// Remembers the home (connection) the user used last, and the last dashboard
/// in each home, so the app opens there instead of on the connections list.
/// Local only: connection and dashboard ids in SharedPreferences.
class LastDashboardStore {
  LastDashboardStore(this._prefs);

  static const _key = 'last_dashboard_connection';
  static String _dashboardKey(String connectionId) =>
      'last_dashboard_of_$connectionId';
  final SharedPreferences _prefs;

  /// Where the app opens: the remembered home's dashboards, or the list.
  String get startLocation {
    final id = _prefs.getString(_key);
    return id == null ? Routes.start : Routes.homeDashboards(id);
  }

  /// The home the app opens on (the one used last), if any.
  String? get lastConnectionId => _prefs.getString(_key);

  Future<void> remember(String connectionId) async {
    if (_prefs.getString(_key) == connectionId) return;
    await _prefs.setString(_key, connectionId);
  }

  /// Remembers [dashboardId] as the one to reopen in [connectionId], and
  /// that home as the one the app opens.
  Future<void> rememberDashboard(String connectionId, String dashboardId) async {
    await remember(connectionId);
    final key = _dashboardKey(connectionId);
    if (_prefs.getString(key) == dashboardId) return;
    await _prefs.setString(key, dashboardId);
  }

  /// The dashboard last used in [connectionId], if any.
  String? lastDashboardOf(String connectionId) =>
      _prefs.getString(_dashboardKey(connectionId));

  /// Call when a connection is deleted or found missing.
  Future<void> forget(String connectionId) async {
    await _prefs.remove(_dashboardKey(connectionId));
    if (_prefs.getString(_key) != connectionId) return;
    await _prefs.remove(_key);
  }
}

final lastDashboardStoreProvider = Provider<LastDashboardStore>(
  (ref) => LastDashboardStore(ref.watch(sharedPreferencesProvider)),
);

/// Invisible marker placed on a home's dashboards screen: opening it makes
/// that home the one the app opens next time. A remembered home that no
/// longer exists is forgotten and the app falls back to the connections list.
class RememberHome extends ConsumerStatefulWidget {
  const RememberHome({super.key, required this.connectionId});
  final String connectionId;

  @override
  ConsumerState<RememberHome> createState() => _RememberHomeState();
}

class _RememberHomeState extends ConsumerState<RememberHome> {
  @override
  void initState() {
    super.initState();
    _check(widget.connectionId);
  }

  @override
  void didUpdateWidget(RememberHome old) {
    super.didUpdateWidget(old);
    if (old.connectionId != widget.connectionId) _check(widget.connectionId);
  }

  Future<void> _check(String id) async {
    final store = ref.read(lastDashboardStoreProvider);
    try {
      final connection = await ref.read(connectionByIdProvider(id).future);
      if (connection != null) {
        await store.remember(id);
        return;
      }
      await store.forget(id);
      if (mounted) context.go(Routes.start);
    } catch (_) {
      // Remembering the home is a convenience; never break the screen.
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
