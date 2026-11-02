import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/update/app_update.dart';
import 'package:zigdash/core/update/update_banner.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'package:zigdash/l10n/app_localizations.dart';

class _Fixed extends AppUpdateController {
  _Fixed(this.initial);

  final AppUpdateState initial;
  int updates = 0;
  int restarts = 0;

  @override
  AppUpdateState build() => initial;

  @override
  Future<void> update() async {
    updates++;
    state = AppUpdateState(AppUpdatePhase.downloading, behind: state.behind);
  }

  @override
  Future<void> restart() async => restarts++;
}

final _now = DateTime(2026, 10, 28, 9);

Future<(_Fixed, SharedPreferences)> _pump(
  WidgetTester tester,
  AppUpdateState state, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final fixed = _Fixed(state);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(p),
        appUpdateProvider.overrideWith(() => fixed),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: UpdateBanner(now: () => _now)),
      ),
    ),
  );
  await tester.pump();
  return (fixed, p);
}

void main() {
  testWidgets('nothing when Play has no update', (tester) async {
    await _pump(tester, AppUpdateState.none);
    expect(find.byKey(const Key('update-banner')), findsNothing);
  });

  testWidgets('an update: Update starts the download and shows it', (
    tester,
  ) async {
    final (fixed, _) = await _pump(
      tester,
      const AppUpdateState(AppUpdatePhase.available, behind: 1),
    );
    expect(find.text('A new version of ZigDash is ready'), findsOneWidget);
    await tester.tap(find.byKey(const Key('update-start')));
    await tester.pump();
    expect(fixed.updates, 1);
    expect(find.text('Downloading the update…'), findsOneWidget);
    expect(find.byKey(const Key('update-start')), findsNothing);
  });

  testWidgets('downloaded: Restart installs it', (tester) async {
    final (fixed, _) = await _pump(
      tester,
      const AppUpdateState(AppUpdatePhase.ready),
    );
    await tester.tap(find.byKey(const Key('update-restart')));
    await tester.pump();
    expect(fixed.restarts, 1);
  });

  testWidgets('Not now hides it for the day', (tester) async {
    final (_, p) = await _pump(
      tester,
      const AppUpdateState(AppUpdatePhase.available, behind: 1),
    );
    await tester.tap(find.byKey(const Key('update-not-now')));
    await tester.pump();
    expect(find.byKey(const Key('update-banner')), findsNothing);
    expect(p.getString(updateDismissedOnKey), '2026-10-28');
  });

  testWidgets('dismissed today: hidden', (tester) async {
    await _pump(
      tester,
      const AppUpdateState(AppUpdatePhase.available, behind: 1),
      prefs: {updateDismissedOnKey: '2026-10-28'},
    );
    expect(find.byKey(const Key('update-banner')), findsNothing);
  });

  testWidgets('dismissed today but far behind: shown anyway', (tester) async {
    await _pump(
      tester,
      const AppUpdateState(
        AppUpdatePhase.available,
        behind: updateInsistBehind,
      ),
      prefs: {updateDismissedOnKey: '2026-10-28'},
    );
    expect(find.byKey(const Key('update-banner')), findsOneWidget);
  });

  testWidgets('dismissed yesterday: shown again', (tester) async {
    await _pump(
      tester,
      const AppUpdateState(AppUpdatePhase.available, behind: 1),
      prefs: {updateDismissedOnKey: '2026-10-27'},
    );
    expect(find.byKey(const Key('update-banner')), findsOneWidget);
  });
}
