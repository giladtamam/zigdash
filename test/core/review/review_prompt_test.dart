import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/review/review_prompt.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

class _FakeRequester implements ReviewRequester {
  _FakeRequester({this.available = true});

  final bool available;
  int availabilityChecks = 0;
  int requests = 0;

  @override
  Future<bool> isAvailable() async {
    availabilityChecks++;
    return available;
  }

  @override
  Future<void> requestReview() async {
    requests++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  final day0 = DateTime.utc(2026, 1, 1, 12);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  // Each gate stands for one app launch: the gate acts at most once per
  // launch, so a new instance is how a test models the next launch.
  ReviewPromptGate launchAt(DateTime when, _FakeRequester requester) =>
      ReviewPromptGate(prefs: prefs, requester: requester, now: () => when);

  test('first success moment only records state, never prompts', () async {
    final requester = _FakeRequester();

    expect(await launchAt(day0, requester).onSuccessMoment(), isFalse);

    expect(requester.requests, 0);
    expect(requester.availabilityChecks, 0,
        reason: 'must not touch the Play API before the gates pass');
    expect(prefs.getInt('review_first_seen_ms'), day0.millisecondsSinceEpoch);
    expect(prefs.getInt('review_success_count'), 1);
  });

  test('stays silent until the success count is reached', () async {
    final requester = _FakeRequester();
    // Far enough out that only the success count can be holding it back.
    final late = day0.add(const Duration(days: reviewMinAgeDays + 10));

    await launchAt(day0, requester).onSuccessMoment();
    for (var i = 2; i < reviewMinSuccesses; i++) {
      expect(await launchAt(late, requester).onSuccessMoment(), isFalse);
    }
    expect(requester.requests, 0);

    expect(await launchAt(late, requester).onSuccessMoment(), isTrue);
    expect(requester.requests, 1);
  });

  test('stays silent until the app is old enough, however many successes',
      () async {
    final requester = _FakeRequester();
    final sameDay = day0.add(const Duration(hours: 2));

    await launchAt(day0, requester).onSuccessMoment();
    for (var i = 0; i < reviewMinSuccesses + 5; i++) {
      expect(await launchAt(sameDay, requester).onSuccessMoment(), isFalse);
    }
    expect(requester.requests, 0);

    final ripe = day0.add(const Duration(days: reviewMinAgeDays));
    expect(await launchAt(ripe, requester).onSuccessMoment(), isTrue);
  });

  test('prompts once, then honours the cooldown', () async {
    final requester = _FakeRequester();
    final ripe = day0.add(const Duration(days: reviewMinAgeDays + 1));

    await launchAt(day0, requester).onSuccessMoment();
    for (var i = 2; i < reviewMinSuccesses; i++) {
      await launchAt(ripe, requester).onSuccessMoment();
    }
    expect(await launchAt(ripe, requester).onSuccessMoment(), isTrue);
    expect(requester.requests, 1);

    // Still inside the cooldown.
    final soon = ripe.add(const Duration(days: reviewCooldownDays - 1));
    expect(await launchAt(soon, requester).onSuccessMoment(), isFalse);
    expect(requester.requests, 1);

    // Cooldown elapsed.
    final later = ripe.add(const Duration(days: reviewCooldownDays));
    expect(await launchAt(later, requester).onSuccessMoment(), isTrue);
    expect(requester.requests, 2);
  });

  test('records the cooldown even though Play may drop the request', () async {
    final requester = _FakeRequester();
    final ripe = day0.add(const Duration(days: reviewMinAgeDays + 1));

    await launchAt(day0, requester).onSuccessMoment();
    for (var i = 2; i < reviewMinSuccesses; i++) {
      await launchAt(ripe, requester).onSuccessMoment();
    }
    await launchAt(ripe, requester).onSuccessMoment();

    expect(prefs.getInt('review_last_prompt_ms'), ripe.millisecondsSinceEpoch);
  });

  test('never prompts where Play review is unavailable', () async {
    final requester = _FakeRequester(available: false);
    final ripe = day0.add(const Duration(days: reviewMinAgeDays + 1));

    await launchAt(day0, requester).onSuccessMoment();
    for (var i = 0; i < reviewMinSuccesses + 5; i++) {
      expect(await launchAt(ripe, requester).onSuccessMoment(), isFalse);
    }
    expect(requester.requests, 0);
    expect(prefs.getInt('review_last_prompt_ms'), isNull,
        reason: 'an unavailable flow must not burn the cooldown');
  });

  test('acts at most once per launch however often it is called', () async {
    final requester = _FakeRequester();
    final gate = launchAt(day0, requester);

    await gate.onSuccessMoment();
    await gate.onSuccessMoment();
    await gate.onSuccessMoment();

    expect(prefs.getInt('review_success_count'), 1,
        reason: 'a rebuilding widget must not inflate the success count');
  });

  group('ReviewPromptTrigger', () {
    Widget host({required bool active, List<Override> overrides = const []}) =>
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            home: ReviewPromptTrigger(
              active: active,
              child: const Text('dashboard'),
            ),
          ),
        );

    testWidgets('reports a success moment while active', (tester) async {
      final requester = _FakeRequester();
      await tester.pumpWidget(host(active: true, overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        reviewRequesterProvider.overrideWithValue(requester),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('dashboard'), findsOneWidget);
      expect(prefs.getInt('review_success_count'), 1);
    });

    testWidgets('reports nothing while inactive', (tester) async {
      final requester = _FakeRequester();
      await tester.pumpWidget(host(active: false, overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        reviewRequesterProvider.overrideWithValue(requester),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('dashboard'), findsOneWidget);
      expect(prefs.getInt('review_success_count'), isNull);
    });

    testWidgets('still renders when the gate cannot run', (tester) async {
      // No sharedPreferencesProvider override: reading the gate throws.
      await tester.pumpWidget(host(active: true));
      await tester.pumpAndSettle();

      expect(find.text('dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
