import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/review/command_confirmations.dart';
import 'package:zigdash/core/review/review_launcher.dart';
import 'package:zigdash/core/review/review_prompt_controller.dart';
import 'package:zigdash/core/review/review_prompt_trigger.dart';
import 'package:zigdash/features/onboarding/setup/setup_completed_at.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

class _FakeLauncher implements ReviewLauncher {
  int requests = 0;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<void> requestReview() async => requests++;
}

class _FakeSink implements AnalyticsSink {
  final sent = <(String, Map<String, String>)>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

/// Prefs seeded so that one more session today satisfies the default policy
/// on the command path. [sessions] 3 keeps the passive path (needs 7) shut.
Map<String, Object> _eligiblePrefs({int sessions = 3}) => {
  ReviewPromptController.kSessions: sessions,
  ReviewPromptController.kFirstSessionDay: '2020-01-01',
  ReviewPromptController.kLastSessionDay: '2020-01-03',
};

/// Just short of, and just past, the 1.5-second delay.
const _almost = Duration(milliseconds: 1400);
const _rest = Duration(milliseconds: 200);

class _Harness {
  _Harness(this.launcher, this.sink, this.status, this.confirmed, this.reported);
  final _FakeLauncher launcher;
  final _FakeSink sink;
  final StreamController<MqttStatus> status;
  final StreamController<DateTime> confirmed;
  final StreamController<DateTime> reported;

  Future<void> close() async {
    await status.close();
    await confirmed.close();
    await reported.close();
  }
}

Future<_Harness> _pump(
  WidgetTester tester, {
  required Map<String, Object> prefsValues,
}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final launcher = _FakeLauncher();
  final sink = _FakeSink();
  final status = StreamController<MqttStatus>.broadcast();
  final confirmed = StreamController<DateTime>.broadcast();
  final reported = StreamController<DateTime>.broadcast();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        reviewLauncherProvider.overrideWithValue(launcher),
        analyticsProvider.overrideWithValue(Analytics(sink, enabled: true)),
        connectionStatusProvider.overrideWith((ref, id) => status.stream),
        commandConfirmedProvider.overrideWith((ref, id) => confirmed.stream),
        deviceReportedProvider.overrideWith((ref, id) => reported.stream),
      ],
      child: const Center(child: ReviewPromptTrigger(connectionId: 'c1')),
    ),
  );
  return _Harness(launcher, sink, status, confirmed, reported);
}

/// One confirmed command, delivered to the widget.
Future<void> _command(WidgetTester tester, _Harness h) async {
  h.confirmed.add(DateTime.now());
  await tester.pump();
  await tester.pump();
}

void main() {
  // First-run decision: a successful session is a calendar day on which the
  // user sent a command and received a confirming state update.
  testWidgets('being connected alone is not a session', (tester) async {
    final h = await _pump(tester, prefsValues: _eligiblePrefs());
    h.status.add(MqttStatus.connected);
    await tester.pump();
    await tester.pump(kReviewDelay);
    expect(h.launcher.requests, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(ReviewPromptController.kSessions), 3);
    await h.close();
  });

  testWidgets('every confirmed command counts the day and marks the install;'
      ' only the third asks, after the delay', (tester) async {
    final h = await _pump(tester, prefsValues: _eligiblePrefs());
    final prefs = await SharedPreferences.getInstance();

    await _command(tester, h);
    expect(prefs.getInt(ReviewPromptController.kSessions), 4);
    expect(prefs.getBool(ReviewPromptController.kCommandEver), isTrue);
    await tester.pump(kReviewDelay);
    expect(h.launcher.requests, 0, reason: 'first command');

    await _command(tester, h);
    await tester.pump(kReviewDelay);
    expect(h.launcher.requests, 0, reason: 'second command');

    await _command(tester, h);
    await tester.pump(_almost);
    expect(h.launcher.requests, 0, reason: 'third, but the delay is not up');
    await tester.pump(_rest);
    await tester.pump();
    expect(h.launcher.requests, 1, reason: 'third command, 1.5 s later');
    expect(h.sink.sent.single.$1, 'review_prompt');
    expect(h.sink.sent.single.$2, {
      'result': 'requested',
      'trigger': 'command',
      'nth': '3',
    });

    // More confirmed commands the same day must not re-ask.
    await _command(tester, h);
    await _command(tester, h);
    await tester.pump(kReviewDelay);
    expect(h.launcher.requests, 1);
    expect(prefs.getInt(ReviewPromptController.kSessions), 4);
    await h.close();
  });

  testWidgets('the in-session count resets with the widget', (tester) async {
    final h = await _pump(tester, prefsValues: _eligiblePrefs());
    await _command(tester, h);
    await _command(tester, h);
    await tester.pump(kReviewDelay);

    // The dashboard goes away and comes back: two more commands are the
    // first and second of the new session, not the third and fourth.
    await tester.pumpWidget(const SizedBox());
    await h.close();
    final h2 = await _pump(tester, prefsValues: _eligiblePrefs());
    await _command(tester, h2);
    await _command(tester, h2);
    await tester.pump(kReviewDelay);
    expect(h2.launcher.requests, 0);
    await _command(tester, h2);
    await tester.pump(kReviewDelay);
    await tester.pump();
    expect(h2.launcher.requests, 1);
    await h2.close();
  });

  testWidgets('no ask when the dashboard is gone before the delay is up', (
    tester,
  ) async {
    final h = await _pump(tester, prefsValues: _eligiblePrefs());
    await _command(tester, h);
    await _command(tester, h);
    await _command(tester, h);
    await tester.pump(_almost);
    // The user leaves the dashboard (another route, the app closes).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(_rest);
    await tester.pump(kReviewDelay);
    expect(h.launcher.requests, 0);
    await h.close();
  });

  testWidgets('does nothing while the policy is not met', (tester) async {
    final h = await _pump(tester, prefsValues: {});
    await _command(tester, h);
    await _command(tester, h);
    await _command(tester, h);
    await tester.pump(kReviewDelay);
    await tester.pump();
    expect(h.launcher.requests, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(ReviewPromptController.kSessions), 1);
    await h.close();
  });

  testWidgets('never within 10 minutes of setup', (tester) async {
    final h = await _pump(
      tester,
      prefsValues: {
        ..._eligiblePrefs(),
        kSetupCompletedAtMs: DateTime.now().millisecondsSinceEpoch,
      },
    );
    await _command(tester, h);
    await _command(tester, h);
    await _command(tester, h);
    await tester.pump(kReviewDelay);
    await tester.pump();
    expect(h.launcher.requests, 0);
    await h.close();
  });

  testWidgets('renders nothing visible', (tester) async {
    final h = await _pump(tester, prefsValues: {});
    expect(find.byType(SizedBox), findsOneWidget);
    expect(tester.getSize(find.byType(SizedBox)), Size.zero);
    await h.close();
  });

  group('passive device reports (2.8.1, sensor-only homes)', () {
    testWidgets('count the day but do not ask once a command was ever '
        'confirmed', (tester) async {
      final h = await _pump(
        tester,
        prefsValues: {
          ..._eligiblePrefs(sessions: 9),
          ReviewPromptController.kCommandEver: true,
        },
      );
      h.reported.add(DateTime.now());
      await tester.pump();
      await tester.pump(kReviewDelay);
      await tester.pump();
      expect(h.launcher.requests, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(ReviewPromptController.kSessions), 10);
      expect(h.sink.sent, isEmpty);
      await h.close();
    });

    testWidgets('ask on an install that never confirmed a command, after '
        'seven counted days and the delay', (tester) async {
      // Six days before; today's report is the seventh.
      final h = await _pump(tester, prefsValues: _eligiblePrefs(sessions: 6));
      h.reported.add(DateTime.now());
      await tester.pump();
      await tester.pump(_almost);
      expect(h.launcher.requests, 0, reason: 'delay not up');
      await tester.pump(_rest);
      await tester.pump();
      expect(h.launcher.requests, 1);
      expect(h.sink.sent.single.$2, {
        'result': 'requested',
        'trigger': 'report',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(ReviewPromptController.kCommandEver), isNull);
      await h.close();
    });

    testWidgets('do not ask before seven counted days', (tester) async {
      final h = await _pump(tester, prefsValues: _eligiblePrefs(sessions: 5));
      h.reported.add(DateTime.now());
      await tester.pump();
      await tester.pump(kReviewDelay);
      await tester.pump();
      expect(h.launcher.requests, 0);
      await h.close();
    });
  });
}
