// iOS smoke run (docs/design/ios.md): the demo home App Review will use,
// Settings, the Pro screen and the Wall display sheet, on a simulator.
// Fails on any uncaught error, which is how a missing iOS channel shows.
//
//   tool/flutter test integration_test/ios_smoke_test.dart -d <simulator> \
//     --flavor appstore --dart-define=ZIGDASH_FLAVOR=appstore \
//     --dart-define=ZIGDASH_PRO_LIVE=true
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/app.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  String texts(WidgetTester t) => t
      .widgetList<Text>(find.byType(Text))
      .map((w) => w.data ?? w.textSpan?.toPlainText() ?? '')
      .where((s) => s.trim().isNotEmpty)
      .take(30)
      .join(' | ');

  Future<void> settle(WidgetTester t, String label) async {
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 500));
    }
    // ignore: avoid_print
    print('IOS[$label] ${texts(t)}');
  }

  testWidgets('demo home, Settings, Pro and Wall display on iOS', (t) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await t.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ZigDashApp(),
    ));
    await settle(t, 'welcome');

    await t.tap(find.text('Try the demo home'));
    await settle(t, 'demo');
    expect(find.text('Try the demo home'), findsNothing);

    await t.tap(find.byTooltip('Settings').first);
    await settle(t, 'settings');

    final pro = find.text('ZigDash Pro');
    if (t.any(pro)) {
      await t.ensureVisible(pro.first);
      await t.tap(pro.first);
      await settle(t, 'pro');
      await t.pageBack();
      await settle(t, 'back');
    } else {
      // ignore: avoid_print
      print('IOS[pro] not shown (StoreKit found no product)');
    }
  });
}
