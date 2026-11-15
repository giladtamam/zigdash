import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/review/review_launcher.dart';
import 'package:zigdash/core/review/review_prompt_controller.dart';
import 'package:zigdash/core/review/review_prompt_trigger.dart'
    show kReviewDelay;
import 'package:zigdash/features/history/history_chart.dart';
import 'package:zigdash/features/history/history_record.dart';
import 'package:zigdash/features/history/history_service.dart';
import 'package:zigdash/features/history/history_sheet.dart';
import 'package:zigdash/features/kiosk/kiosk.dart';
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

final _now = DateTime(2026, 10, 15, 12);

const _recordingThis =
    '{"readings":[{"ieee":"0xa1","attr":"temperature","topic":"z/x","path":"temperature"}]}';

class _KioskOn extends KioskController {
  @override
  KioskState build() => const KioskState(connectionId: 'c1', dashboardId: 'd1');
}

Widget _app({
  required bool? online,
  Map<String, List<HistoryPoint>> days = const {},
  ProStatus pro = ProStatus.unlocked,
  bool kiosk = false,
  String retained = _recordingThis,
  VoidCallback? onRangeDataSeen,
}) => ProviderScope(
  overrides: [
    if (kiosk) kioskProvider.overrideWith(_KioskOn.new),
    proStatusProvider.overrideWithValue(pro),
    historyRecorderOnlineProvider.overrideWith(
      (ref, _) => online == null ? const Stream.empty() : Stream.value(online),
    ),
    historyDaysProvider.overrideWith((ref, _) => Stream.value(days)),
    historyRetainedConfigProvider.overrideWith(
      (ref, _) => Stream.value(retained),
    ),
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: HistorySheet(
        connectionId: 'c1',
        ieee: '0xa1',
        path: 'temperature',
        title: 'Living room',
        unit: '°C',
        now: () => _now,
        onRangeDataSeen: onRangeDataSeen,
      ),
    ),
  ),
);

final _today = {
  '2026-10-15': [
    HistoryPoint(DateTime(2026, 10, 15, 10), 21, 20, 22),
    HistoryPoint(DateTime(2026, 10, 15, 10, 15), 22, 21, 23),
  ],
};

final _twoDays = {
  '2026-10-14': [HistoryPoint(DateTime(2026, 10, 14, 18), 20, 19, 21)],
  ..._today,
};

/// Yesterday and today on the real clock: [showHistorySheet] has no test
/// clock.
Map<String, List<HistoryPoint>> _recentDays() {
  final now = DateTime.now();
  String key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  return {
    key(yesterday): [
      HistoryPoint(yesterday.add(const Duration(hours: 12)), 20, 19, 21),
    ],
    key(today): [HistoryPoint(today, 21, 20, 22)],
  };
}

class _FakeLauncher implements ReviewLauncher {
  int requests = 0;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<void> requestReview() async => requests++;
}

/// A dashboard-like screen with a button that opens [showHistorySheet], and a
/// review controller whose policy is already met.
Future<_FakeLauncher> _pumpOpener(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    ReviewPromptController.kSessions: 9,
    ReviewPromptController.kFirstSessionDay: '2026-01-01',
    ReviewPromptController.kLastSessionDay: '2026-10-14',
  });
  final prefs = await SharedPreferences.getInstance();
  final launcher = _FakeLauncher();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        reviewPromptControllerProvider.overrideWithValue(
          ReviewPromptController(prefs: prefs, launcher: launcher),
        ),
        proStatusProvider.overrideWithValue(ProStatus.unlocked),
        historyRecorderOnlineProvider.overrideWith(
          (ref, _) => Stream.value(true),
        ),
        historyDaysProvider.overrideWith(
          (ref, _) => Stream.value(_recentDays()),
        ),
        historyRetainedConfigProvider.overrideWith(
          (ref, _) => Stream.value(_recordingThis),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showHistorySheet(
                context,
                connectionId: 'c1',
                ieee: '0xa1',
                path: 'temperature',
                title: 'Living room',
                unit: '°C',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  return launcher;
}

void main() {
  group('review ask after History (3.6.1)', () {
    testWidgets('a week chart with two days of points counts, once', (
      tester,
    ) async {
      var seen = 0;
      await tester.pumpWidget(
        _app(online: true, days: _twoDays, onRangeDataSeen: () => seen++),
      );
      await tester.pump();
      expect(seen, 0, reason: '24 hours is not the moment');
      await tester.tap(find.text('7 days'));
      await tester.pump();
      await tester.pump();
      expect(seen, 1);
    });

    testWidgets('today only: not a moment', (tester) async {
      var seen = 0;
      await tester.pumpWidget(
        _app(online: true, days: _today, onRangeDataSeen: () => seen++),
      );
      await tester.pump();
      await tester.tap(find.text('7 days'));
      await tester.pump();
      expect(seen, 0);
    });

    testWidgets('locked: not a moment', (tester) async {
      var seen = 0;
      await tester.pumpWidget(
        _app(
          online: true,
          days: _twoDays,
          pro: ProStatus.locked,
          onRangeDataSeen: () => seen++,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('7 days'));
      await tester.pump();
      expect(seen, 0);
    });

    testWidgets('asks after the sheet closes, never while it is open', (
      tester,
    ) async {
      final launcher = await _pumpOpener(tester);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('7 days'));
      await tester.pump();
      await tester.pump(kReviewDelay * 2);
      expect(launcher.requests, 0, reason: 'the chart is being read');

      Navigator.of(tester.element(find.byType(HistorySheet))).pop();
      await tester.pumpAndSettle();
      await tester.pump(kReviewDelay);
      await tester.pump();
      expect(launcher.requests, 1);
    });

    testWidgets('no ask when only 24 hours was looked at', (tester) async {
      final launcher = await _pumpOpener(tester);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(HistorySheet))).pop();
      await tester.pumpAndSettle();
      await tester.pump(kReviewDelay);
      expect(launcher.requests, 0);
    });

    testWidgets('no ask when another screen covers it before the delay', (
      tester,
    ) async {
      final launcher = await _pumpOpener(tester);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('7 days'));
      await tester.pump();
      final nav = Navigator.of(tester.element(find.byType(HistorySheet)));
      nav.pop();
      await tester.pumpAndSettle();
      nav.push(MaterialPageRoute<void>(builder: (_) => const Text('other')));
      await tester.pumpAndSettle();
      await tester.pump(kReviewDelay);
      expect(launcher.requests, 0);
    });
  });

  testWidgets('no recorder and no data: the set-up card', (tester) async {
    await tester.pumpWidget(_app(online: null));
    await tester.pump();
    expect(find.text('Record history on your hub'), findsOneWidget);
    expect(find.text('Set up on the hub'), findsOneWidget);
    expect(find.byType(HistoryChart), findsNothing);
  });

  testWidgets('a running recorder with no values yet says so', (tester) async {
    await tester.pumpWidget(_app(online: true));
    await tester.pump();
    expect(find.textContaining('No values yet'), findsOneWidget);
  });

  testWidgets('data: the graph, the latest value and since when', (
    tester,
  ) async {
    await tester.pumpWidget(_app(online: true, days: _today));
    await tester.pump();
    expect(find.byType(HistoryChart), findsOneWidget);
    expect(find.text('\u206622°C\u2069'), findsOneWidget);
    expect(find.textContaining('Recording since'), findsOneWidget);
    expect(find.text('7 days'), findsOneWidget, reason: 'outside Play');
  });

  testWidgets('an offline recorder is named under the graph', (tester) async {
    await tester.pumpWidget(_app(online: false, days: _today));
    await tester.pump();
    expect(find.textContaining("isn't answering"), findsOneWidget);
  });

  testWidgets('Pro not offered yet: only 24 hours', (tester) async {
    await tester.pumpWidget(
      _app(online: true, days: _today, pro: ProStatus.unavailable),
    );
    await tester.pump();
    expect(find.text('7 days'), findsNothing);
    expect(find.byType(SegmentedButton<HistoryRange>), findsNothing);
  });

  testWidgets('Pro locked: 7 days shows the sample and Unlock', (tester) async {
    await tester.pumpWidget(
      _app(online: true, days: _today, pro: ProStatus.locked),
    );
    await tester.pump();
    await tester.tap(find.text('7 days'));
    await tester.pump();
    expect(find.textContaining('ZigDash Pro'), findsOneWidget);
    expect(find.text('Unlock'), findsOneWidget);
  });

  testWidgets('kiosk guests see the locked sample but no Unlock', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(online: true, days: _today, pro: ProStatus.locked, kiosk: true),
    );
    await tester.pump();
    await tester.tap(find.text('7 days'));
    await tester.pump();
    expect(find.textContaining('ZigDash Pro'), findsOneWidget);
    expect(find.text('Unlock'), findsNothing);
  });

  testWidgets('a reading the recorder skips says how to record it', (
    tester,
  ) async {
    await tester.pumpWidget(_app(online: true, retained: '{"readings":[]}'));
    await tester.pump();
    expect(
      find.textContaining('Only numbers shown on a dashboard'),
      findsOneWidget,
    );
    expect(find.textContaining('No values yet'), findsNothing);
  });

  testWidgets('installed but never online: points to the Engine on the hub', (
    tester,
  ) async {
    await tester.pumpWidget(_app(online: null));
    await tester.pump();
    expect(
      find.textContaining("The recorder isn't reporting"),
      findsOneWidget,
    );
    expect(find.textContaining('persistence true'), findsOneWidget);
  });

  testWidgets('nothing installed: the plain set-up card', (tester) async {
    await tester.pumpWidget(_app(online: null, retained: ''));
    await tester.pump();
    expect(find.textContaining('ZigDash has no server'), findsOneWidget);
    expect(find.textContaining("isn't reporting"), findsNothing);
  });

  testWidgets('no recorder on the hub: record on this device instead', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: _app(online: null, retained: ''),
      ),
    );
    await tester.pump();
    expect(find.textContaining('ZigDash can record on a phone or tablet'), findsOneWidget);
    await tester.ensureVisible(find.text('Record on this device'));
    await tester.tap(find.text('Record on this device'));
    await tester.pump();
    expect(prefs.getBool('history_record_here_c1'), isTrue);
    expect(find.textContaining('This device records history'), findsOneWidget);
  });
}
