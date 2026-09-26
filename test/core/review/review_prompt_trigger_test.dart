import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/review/review_launcher.dart';
import 'package:zigdash/core/review/review_prompt_controller.dart';
import 'package:zigdash/core/review/command_confirmations.dart';
import 'package:zigdash/core/review/review_prompt_trigger.dart';
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

/// Prefs seeded so that one more session today satisfies the default policy.
Map<String, Object> _eligiblePrefs() => {
      ReviewPromptController.kSessions: 3,
      ReviewPromptController.kFirstSessionDay: '2020-01-01',
      ReviewPromptController.kLastSessionDay: '2020-01-03',
    };

Future<(_FakeLauncher, StreamController<MqttStatus>, StreamController<DateTime>)>
    _pump(
  WidgetTester tester, {
  required Map<String, Object> prefsValues,
}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  final prefs = await SharedPreferences.getInstance();
  final launcher = _FakeLauncher();
  final status = StreamController<MqttStatus>.broadcast();
  final confirmed = StreamController<DateTime>.broadcast();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        reviewLauncherProvider.overrideWithValue(launcher),
        connectionStatusProvider.overrideWith((ref, id) => status.stream),
        commandConfirmedProvider.overrideWith((ref, id) => confirmed.stream),
      ],
      child: const Center(child: ReviewPromptTrigger(connectionId: 'c1')),
    ),
  );
  return (launcher, status, confirmed);
}

void main() {
  // First-run decision: a successful session is a calendar day on which the
  // user sent a command and received a confirming state update.
  testWidgets('being connected alone is not a session', (tester) async {
    final (launcher, status, confirmed) =
        await _pump(tester, prefsValues: _eligiblePrefs());
    status.add(MqttStatus.connected);
    await tester.pump();
    await tester.pump();
    expect(launcher.requests, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(ReviewPromptController.kSessions), 3);
    await status.close();
    await confirmed.close();
  });

  testWidgets('a confirmed command records a session and can prompt',
      (tester) async {
    final (launcher, status, confirmed) =
        await _pump(tester, prefsValues: _eligiblePrefs());

    confirmed.add(DateTime.now());
    await tester.pump();
    await tester.pump();
    expect(launcher.requests, 1);

    // More confirmed commands the same day must not re-prompt.
    confirmed.add(DateTime.now());
    await tester.pump();
    await tester.pump();
    expect(launcher.requests, 1);
    await status.close();
    await confirmed.close();
  });

  testWidgets('does nothing while the policy is not met', (tester) async {
    final (launcher, status, confirmed) = await _pump(tester, prefsValues: {});
    confirmed.add(DateTime.now());
    await tester.pump();
    await tester.pump();
    expect(launcher.requests, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(ReviewPromptController.kSessions), 1);
    await status.close();
    await confirmed.close();
  });

  testWidgets('renders nothing visible', (tester) async {
    final (_, status, confirmed) = await _pump(tester, prefsValues: {});
    expect(find.byType(SizedBox), findsOneWidget);
    expect(tester.getSize(find.byType(SizedBox)), Size.zero);
    await status.close();
    await confirmed.close();
  });
}
