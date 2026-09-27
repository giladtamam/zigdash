import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/dashboards/wall_display.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

class _Wake extends ScreenWake {
  final calls = <bool>[];
  @override
  Future<void> keepOn(bool on) async => calls.add(on);
}

void main() {
  late SharedPreferences prefs;
  late _Wake wake;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'wall_display_d1': true});
    prefs = await SharedPreferences.getInstance();
    wake = _Wake();
  });

  Widget app({bool active = true, String id = 'd1'}) => ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          screenWakeProvider.overrideWithValue(wake),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => WallDisplayScope(
              dashboardId: id,
              active: active,
              child: Scaffold(
                body: Center(
                  child: Text(ref.watch(wallChromeHiddenProvider)
                      ? 'hidden'
                      : 'shown'),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('keeps the screen on and hides the chrome after 10 s',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    expect(wake.calls, [true]);
    expect(find.text('shown'), findsOneWidget);

    await tester.pump(wallChromeDelay + const Duration(milliseconds: 1));
    expect(find.text('hidden'), findsOneWidget);

    await tester.tap(find.text('hidden'));
    await tester.pump();
    expect(find.text('shown'), findsOneWidget, reason: 'a touch brings it back');

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(wake.calls.last, isFalse, reason: 'leaving lets the screen sleep');
  });

  testWidgets('off by default, and never in Edit mode', (tester) async {
    await tester.pumpWidget(app(id: 'other'));
    await tester.pump(wallChromeDelay * 2);
    expect(find.text('shown'), findsOneWidget);
    expect(wake.calls, isEmpty);

    await tester.pumpWidget(app(active: false));
    await tester.pump(wallChromeDelay * 2);
    expect(find.text('shown'), findsOneWidget);
    expect(wake.calls, isEmpty);
  });
}
