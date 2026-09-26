import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/router/last_dashboard_store.dart';
import 'package:zigdash/core/router/routes.dart';

void main() {
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // First-run decision: home after first run is the last-used dashboard.
  test('with no remembered home the app opens on the connections list', () {
    expect(LastDashboardStore(prefs).startLocation, Routes.connections);
  });

  test('a remembered home opens its dashboards, across restarts', () async {
    await LastDashboardStore(prefs).remember('c1');
    expect(LastDashboardStore(prefs).startLocation, '/connections/c1/dashboards');
  });

  test('forgetting the remembered home falls back to the list', () async {
    final store = LastDashboardStore(prefs);
    await store.remember('c1');
    await store.forget('c2');
    expect(store.startLocation, '/connections/c1/dashboards');
    await store.forget('c1');
    expect(store.startLocation, Routes.connections);
  });

  test('the last dashboard of each home is remembered', () async {
    final store = LastDashboardStore(prefs);
    await store.rememberDashboard('c1', 'd2');
    await store.rememberDashboard('c2', 'd9');

    final reopened = LastDashboardStore(prefs);
    expect(reopened.lastDashboardOf('c1'), 'd2');
    expect(reopened.lastDashboardOf('c2'), 'd9');
    expect(reopened.lastDashboardOf('c3'), isNull);
    expect(reopened.startLocation, '/connections/c2/dashboards',
        reason: 'the most recent home opens');
  });

  test('forgetting a home forgets its last dashboard', () async {
    final store = LastDashboardStore(prefs);
    await store.rememberDashboard('c1', 'd2');
    await store.forget('c1');
    expect(store.lastDashboardOf('c1'), isNull);
  });
}
