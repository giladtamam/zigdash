import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/history/history_service.dart';
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/pro/pro_trial.dart';
import 'package:zigdash/features/pro/pro_trial_card.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

class _Sink implements AnalyticsSink {
  final sent = <String>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add('$name $props');
}

class _Clock {
  _Clock(this.now);
  DateTime now;
}

class _Rig {
  _Rig(this.container, this.sink, this.clock, this.file);
  final ProviderContainer container;
  final _Sink sink;
  final _Clock clock;
  final List<String?> file;
  ProTrialController get trial => container.read(proTrialProvider.notifier);
  bool get access => container.read(proAccessProvider);
}

Future<_Rig> _rig({
  String? stored,
  bool offered = true,
  ProStatus status = ProStatus.locked,
}) async {
  SharedPreferences.setMockInitialValues({'analytics_consent': true});
  final p = await SharedPreferences.getInstance();
  final sink = _Sink();
  final clock = _Clock(DateTime(2026, 12, 1, 9));
  final file = <String?>[stored];
  final c = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      analyticsAvailableProvider.overrideWithValue(true),
      analyticsSinkProvider.overrideWithValue(sink),
      proTrialOfferedProvider.overrideWithValue(offered),
      proStatusProvider.overrideWithValue(status),
      proTrialNowProvider.overrideWithValue(() => clock.now),
      proTrialInstallWeekProvider.overrideWith((_) async => '2026-W48'),
      proTrialStoreProvider.overrideWithValue(
        ProTrialStore(
          read: () async => file.last,
          write: (s) async => file.add(s),
        ),
      ),
    ],
  );
  c.read(proTrialProvider);
  await Future<void>.delayed(Duration.zero);
  return _Rig(c, sink, clock, file);
}

// 3.6: the 14-day Pro trial, docs/design/pro-trial-360.md §3.
void main() {
  group('ProTrial', () {
    final start = DateTime(2026, 12, 1);
    test('runs for 14 days from its start', () {
      final t = ProTrial(loaded: true, start: start);
      expect(t.runningAt(start.add(const Duration(days: 13))), isTrue);
      expect(t.runningAt(start.add(const Duration(days: 14))), isFalse);
    });

    test('setting the clock back does not extend it', () {
      final t = ProTrial(
        loaded: true,
        start: start,
        seenMax: start.add(const Duration(days: 15)),
      );
      expect(t.runningAt(start.add(const Duration(days: 2))), isFalse);
    });

    test('a start in the future is not running', () {
      final t = ProTrial(loaded: true, start: start);
      expect(t.runningAt(start.subtract(const Duration(days: 1))), isFalse);
    });

    test('survives the file round trip', () {
      final t = ProTrial(
        loaded: true,
        start: start,
        seenMax: start,
        pendingFrom: ProTrialFrom.card,
        used: const {ProTrialUse.history},
      );
      final back = ProTrial.fromJson(t.toJson());
      expect(back.start, start);
      expect(back.pendingFrom, ProTrialFrom.card);
      expect(back.used, {ProTrialUse.history});
      expect(ProTrial.fromJson('not json').start, isNull);
    });

    test('only the Play build with Pro on sale offers it', () {
      expect(proTrialOfferedFor('play', live: true), isTrue);
      expect(proTrialOfferedFor('play', live: false), isFalse);
      expect(proTrialOfferedFor('foss', live: true), isFalse);
      expect(proTrialOfferedFor('appstore', live: true), isFalse);
    });
  });

  test(
    'starts when History first records after this install turned it on',
    () async {
      final r = await _rig();
      await r.trial.recorderOnline(ConnectionTransport.mqtt);
      expect(r.container.read(proTrialProvider).start, isNull);
      expect(r.access, isFalse);

      await r.trial.markOwnAction(ProTrialFrom.finish);
      await r.trial.recorderOnline(ConnectionTransport.homeAssistant);
      expect(r.container.read(proTrialProvider).start, r.clock.now);
      expect(r.access, isTrue);
      expect(r.sink.sent, [
        'pro_trial {step: started, from: finish, hub: home_assistant, week: 2026-W48}',
      ]);
      // A second Home recording later starts nothing new.
      await r.trial.recorderOnline(ConnectionTransport.mqtt);
      expect(r.sink.sent, hasLength(1));
    },
  );

  test('ends after 14 days, then the gates close', () async {
    final r = await _rig();
    await r.trial.markOwnAction(ProTrialFrom.card);
    await r.trial.recorderOnline(ConnectionTransport.mqtt);
    r.clock.now = r.clock.now.add(const Duration(days: 14, minutes: 1));
    r.container.invalidate(proAccessProvider);
    expect(r.access, isFalse);
    await r.trial.endedIfDue();
    await r.trial.endedIfDue();
    expect(
      r.sink.sent.where((e) => e.startsWith('pro_trial {step: ended')),
      hasLength(1),
    );
  });

  test('never in the foss build, nor once Pro is bought', () async {
    final foss = await _rig(offered: false);
    await foss.trial.markOwnAction(ProTrialFrom.card);
    await foss.trial.recorderOnline(ConnectionTransport.mqtt);
    expect(foss.container.read(proTrialProvider).start, isNull);

    final bought = await _rig(status: ProStatus.unlocked);
    await bought.trial.markOwnAction(ProTrialFrom.card);
    await bought.trial.recorderOnline(ConnectionTransport.mqtt);
    expect(bought.container.read(proTrialProvider).start, isNull);
    expect(bought.access, isTrue);
  });

  test('the offer to a Home that already recorded', () async {
    final r = await _rig();
    await r.trial.startFromOffer(ConnectionTransport.mqtt);
    final t = r.container.read(proTrialProvider);
    expect(t.start, isNotNull);
    expect(t.offerAnswered, isTrue);
    expect(r.sink.sent.single, contains('from: offer'));
  });

  test('a feature used counts once, only while it runs', () async {
    final r = await _rig();
    await r.trial.used(ProTrialUse.history);
    expect(r.sink.sent, isEmpty);
    await r.trial.startFromOffer(ConnectionTransport.mqtt);
    await r.trial.used(ProTrialUse.history);
    await r.trial.used(ProTrialUse.history);
    expect(r.sink.sent.where((e) => e.contains('step: used')).toList(), [
      'pro_trial {step: used, what: history}',
    ]);
  });

  test('the file is kept between launches', () async {
    final first = await _rig();
    await first.trial.startFromOffer(ConnectionTransport.mqtt);
    final again = await _rig(stored: first.file.last);
    expect(again.container.read(proTrialProvider).start, first.clock.now);
    expect(again.access, isTrue);
  });

  test('pro events carry the trial', () {
    final t = ProTrial(loaded: true, start: DateTime(2026, 12, 1));
    expect(
      proTrialWire(const ProTrial(loaded: true), DateTime(2026, 12, 2)),
      'none',
    );
    expect(proTrialWire(t, DateTime(2026, 12, 2)), 'running');
    expect(proTrialWire(t, DateTime(2026, 12, 20)), 'ended');
    expect(
      const ProEvent(ProStep.unlocked, trial: 'ended').props['trial'],
      'ended',
    );
  });

  group('card', () {
    Connection home() => Connection(
      transport: ConnectionTransport.mqtt,
      id: 'c1',
      name: 'Home',
      host: '192.168.1.2',
      port: 1883,
      protocol: MqttProtocol.tcp,
      keepAliveSeconds: 60,
      autoConnect: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    Future<(_Sink, List<String?>)> pump(
      WidgetTester tester, {
      String? stored,
      bool online = true,
      DateTime? now,
    }) async {
      SharedPreferences.setMockInitialValues({'analytics_consent': true});
      final p = await SharedPreferences.getInstance();
      final sink = _Sink();
      final file = <String?>[stored];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(p),
            analyticsAvailableProvider.overrideWithValue(true),
            analyticsSinkProvider.overrideWithValue(sink),
            proTrialOfferedProvider.overrideWithValue(true),
            proStatusProvider.overrideWithValue(ProStatus.locked),
            proPriceProvider.overrideWith((_) async => '€7.99'),
            proTrialNowProvider.overrideWithValue(
              () => now ?? DateTime(2026, 12, 1, 9),
            ),
            proTrialInstallWeekProvider.overrideWith((_) async => null),
            proTrialStoreProvider.overrideWithValue(
              ProTrialStore(
                read: () async => file.last,
                write: (s) async => file.add(s),
              ),
            ),
            connectionByIdProvider.overrideWith((_, _) async => home()),
            historyRecorderOnlineProvider.overrideWith(
              (_, _) => Stream.value(online),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: ProTrialCard(connectionId: 'c1')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (sink, file);
    }

    testWidgets('a Home that already records is offered the trial', (
      tester,
    ) async {
      final (sink, _) = await pump(tester);
      expect(find.text('Try ZigDash Pro free for 14 days'), findsOneWidget);
      expect(find.textContaining('nothing renews'), findsOneWidget);
      await tester.tap(find.byKey(const Key('pro-trial-start')));
      await tester.pumpAndSettle();
      expect(sink.sent.single, contains('step: started, from: offer'));
      expect(find.byKey(const Key('pro-trial-card')), findsNothing);
    });

    testWidgets('no offer without a recorder', (tester) async {
      await pump(tester, online: false);
      expect(find.byKey(const Key('pro-trial-card')), findsNothing);
    });

    testWidgets('after starting on its own, says so once', (tester) async {
      final started = ProTrial(
        loaded: true,
        start: DateTime(2026, 12, 1, 8),
        offerAnswered: true,
      ).toJson();
      await pump(tester, stored: started);
      expect(find.text('Pro is on for 14 days'), findsOneWidget);
      await tester.tap(find.byKey(const Key('pro-trial-ok')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pro-trial-card')), findsNothing);
    });

    testWidgets('two days before the end: what was used, and Keep Pro', (
      tester,
    ) async {
      final started = ProTrial(
        loaded: true,
        start: DateTime(2026, 12, 1, 8),
        startNoticeSeen: true,
        used: const {ProTrialUse.history},
      ).toJson();
      final (sink, _) = await pump(
        tester,
        stored: started,
        now: DateTime(2026, 12, 13, 9),
      );
      expect(find.text('Your Pro trial ends in 2 days'), findsOneWidget);
      expect(find.textContaining('the week and month History'), findsOneWidget);
      expect(find.text('Keep Pro · €7.99'), findsOneWidget);
      expect(sink.sent, contains('pro_trial {step: ending_shown}'));
    });
  });
}
