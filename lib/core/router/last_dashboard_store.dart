import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/providers/settings_controller.dart';
import 'routes.dart';

/// Remembers the home (connection) whose dashboards the user used last, so
/// the app opens there instead of on the connections list. Local only: one
/// connection id in SharedPreferences.
class LastDashboardStore {
  LastDashboardStore(this._prefs);

  static const _key = 'last_dashboard_connection';
  final SharedPreferences _prefs;

  /// Where the app opens: the remembered home's dashboards, or the list.
  String get startLocation {
    final id = _prefs.getString(_key);
    return id == null ? Routes.connections : '/connections/$id/dashboards';
  }

  Future<void> remember(String connectionId) async {
    if (_prefs.getString(_key) == connectionId) return;
    await _prefs.setString(_key, connectionId);
  }

  /// Call when a connection is deleted; a no-op for any other id.
  Future<void> forget(String connectionId) async {
    if (_prefs.getString(_key) != connectionId) return;
    await _prefs.remove(_key);
  }
}

final lastDashboardStoreProvider = Provider<LastDashboardStore>(
  (ref) => LastDashboardStore(ref.watch(sharedPreferencesProvider)),
);

/// Invisible marker placed on a home's dashboards screen: opening it makes
/// that home the one the app opens next time.
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
    ref.read(lastDashboardStoreProvider).remember(widget.connectionId);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
