import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/features/panels/models/panel_config.dart';
import 'package:zigdash/data/database/tables/panels.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';

class _FakeSink implements AnalyticsSink {
  bool running = false;
  int starts = 0;
  int stops = 0;
  final sent = <(String, Map<String, String>)>[];

  @override
  Future<void> start() async {
    running = true;
    starts++;
  }

  @override
  Future<void> stop() async {
    running = false;
    stops++;
    sent.clear(); // the real sink deletes its unsent queue
  }

  @override
  void send(String name, Map<String, String> props) {
    if (running) sent.add((name, props));
  }
}

Future<(ProviderContainer, _FakeSink)> _container(
    {Map<String, Object> prefs = const {}, bool available = true}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final sink = _FakeSink();
  final c = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(p),
    analyticsSinkProvider.overrideWithValue(sink),
    analyticsAvailableProvider.overrideWithValue(available),
  ]);
  addTearDown(c.dispose);
  return (c, sink);
}

const _setupStarted = SetupStep(SetupStepKind.started);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('consent (ADR 0006)', () {
    test('never asked: nothing starts and nothing is sent', () async {
      final (c, sink) = await _container();
      expect(c.read(analyticsConsentProvider), AnalyticsConsent.unasked);
      c.read(analyticsProvider).track(_setupStarted);
      expect(sink.starts, 0);
      expect(sink.sent, isEmpty);
    });

    test('declined: nothing starts and nothing is sent', () async {
      final (c, sink) = await _container(prefs: {'analytics_consent': false});
      c.read(analyticsProvider).track(_setupStarted);
      expect(sink.starts, 0);
      expect(sink.sent, isEmpty);
    });

    test('opting in starts sending; opting out stops it and drops the queue',
        () async {
      final (c, sink) = await _container();
      await c.read(analyticsConsentProvider.notifier).set(true);
      c.read(analyticsProvider).track(_setupStarted);
      expect(sink.running, isTrue);
      expect(sink.sent.single.$1, 'setup_step');

      await c.read(analyticsConsentProvider.notifier).set(false);
      final analytics = c.read(analyticsProvider);
      expect(sink.running, isFalse);
      expect(sink.sent, isEmpty);
      analytics.track(_setupStarted);
      expect(sink.sent, isEmpty);
      expect(
          (await SharedPreferences.getInstance()).getBool('analytics_consent'),
          isFalse);
    });

    test('a build without a key sends nothing even with consent', () async {
      final (c, sink) = await _container(
          prefs: {'analytics_consent': true}, available: false);
      c.read(analyticsProvider).track(_setupStarted);
      expect(sink.starts, 0);
      expect(sink.sent, isEmpty);
    });

    test('a release build without --dart-define has no key', () {
      expect(analyticsKey, isEmpty);
    });
  });

  group('events carry only enum names and buckets', () {
    test('app_started', () {
      const e = AppStarted(
          form: FormFactor.tablet,
          theme: ThemeChoice.dark,
          materialYou: false,
          homes: 3,
          tiles: 14,
          demo: false);
      expect(e.props, {
        'form': 'tablet',
        'theme': 'dark',
        'material_you': 'off',
        'homes': '2+',
        'tiles': '11-30',
        'demo': 'no',
      });
    });

    test('setup_step with an error and a device count', () {
      expect(
          const SetupStep(SetupStepKind.failed,
                  error: SetupErrorKind.notZigbee2Mqtt)
              .props,
          {'step': 'failed', 'error': 'not_zigbee2_mqtt'});
      expect(const SetupStep(SetupStepKind.review, devices: 7).props,
          {'step': 'review', 'devices': '6-20'});
      expect(const SetupStep(SetupStepKind.scanEmpty).props,
          {'step': 'scan_empty'});
    });

    test('feature_used once per session, except tiles added', () async {
      final (c, sink) = await _container(prefs: {'analytics_consent': true});
      final a = c.read(analyticsProvider);
      a.track(const FeatureUsed(Feature.devicesTab));
      a.track(const FeatureUsed(Feature.devicesTab));
      a.track(const FeatureUsed(Feature.tileAdded, tile: PanelType.toggle));
      a.track(const FeatureUsed(Feature.tileAdded, tile: PanelType.device));
      expect(sink.sent.map((e) => e.$2), [
        {'feature': 'devices_tab'},
        {'feature': 'tile_added', 'tile': 'toggle'},
        {'feature': 'tile_added', 'tile': 'device'},
      ]);
    });

    test('help_opened and support_contact', () {
      expect(const HelpOpened(HelpFrom.noConnection).props,
          {'from': 'no_connection'});
      expect(const HelpOpened(HelpFrom.deviceListMissing).name, 'help_opened');
      expect(
          const SupportContact(HelpFrom.setupError, ContactVia.copy).props,
          {'from': 'setup_error', 'via': 'copy'});
      expect(const SupportContact(HelpFrom.demo, ContactVia.email).name,
          'support_contact');
    });

    test('buckets', () {
      expect(bucket(0, const [0], ranges: const [(1, 10)], top: '11+'), '0');
      expect(bucket(10, const [0], ranges: const [(1, 10)], top: '11+'), '1-10');
      expect(bucket(11, const [0], ranges: const [(1, 10)], top: '11+'), '11+');
    });
  });
}
