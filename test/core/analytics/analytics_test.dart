import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/ha_import/ha_client.dart' show HaReadError;
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
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

Future<(ProviderContainer, _FakeSink)> _container({
  Map<String, Object> prefs = const {},
  bool available = true,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  final sink = _FakeSink();
  final c = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      analyticsSinkProvider.overrideWithValue(sink),
      analyticsAvailableProvider.overrideWithValue(available),
    ],
  );
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

    test(
      'opting in starts sending; opting out stops it and drops the queue',
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
          isFalse,
        );
      },
    );

    test('a build without a key sends nothing even with consent', () async {
      final (c, sink) = await _container(
        prefs: {'analytics_consent': true},
        available: false,
      );
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
        demo: false,
      );
      expect(e.props, {
        'form': 'tablet',
        'theme': 'dark',
        'material_you': 'off',
        'homes': '2+',
        'tiles': '11-30',
        'demo': 'no',
        'installed': 'unknown',
        'automations': '0',
        'scenes': '0',
        'shortcuts': '0',
      });
    });

    test('app_started: what the homes have set up, as ranges', () {
      Map<String, String> props(int n) => AppStarted(
        form: FormFactor.phone,
        theme: ThemeChoice.system,
        materialYou: true,
        homes: 1,
        tiles: 0,
        demo: false,
        automations: n,
        scenes: n,
        shortcuts: n,
      ).props;
      expect([for (final n in [0, 1, 3, 4, 40]) props(n)['automations']], ['0', '1-3', '1-3', '4+', '4+']);
      expect([for (final n in [0, 1, 12]) props(n)['scenes']], ['0', '1+', '1+']);
      expect([for (final n in [0, 1, 12]) props(n)['shortcuts']], ['0', '1+', '1+']);
    });

    test('app_started: days since install, as a range', () {
      String installed(int? days) => AppStarted(
        form: FormFactor.phone,
        theme: ThemeChoice.system,
        materialYou: true,
        homes: 1,
        tiles: 0,
        demo: false,
        daysInstalled: days,
      ).props['installed']!;
      expect(
        [
          for (final d in [0, 1, 2, 7, 8, 30, 31, 400, null]) installed(d),
        ],
        ['0', '1', '2-7', '2-7', '8-30', '8-30', '31+', '31+', 'unknown'],
      );
    });

    test('kiosk started: feature_used with the chosen options', () {
      const off = {
        'idle_show': 'dim',
        'motion': 'no',
        'night': 'no',
        'alarms': 'no',
      };
      expect(
        const KioskStarted(pin: true, osPinning: false, dimMinutes: 5).props,
        {
          'feature': 'kiosk',
          'lock': 'pin',
          'os_pin': 'no',
          'dim': '5m',
          ...off,
        },
      );
      expect(
        const KioskStarted(pin: false, osPinning: true, dimMinutes: 0).props,
        {
          'feature': 'kiosk',
          'lock': 'none',
          'os_pin': 'yes',
          'dim': 'off',
          ...off,
        },
      );
      expect(
        const KioskStarted(
          pin: false,
          osPinning: false,
          dimMinutes: 1,
          idleShow: 'readings',
          motion: true,
          night: true,
          alarms: true,
        ).props,
        containsPair('idle_show', 'readings'),
      );
    });

    test('alarm_shown: only the kind', () {
      expect(const AlarmShown('leak').name, 'alarm_shown');
      expect(const AlarmShown('leak').props, {'kind': 'leak'});
    });

    test('setup_step with an error and a device count', () {
      expect(
        const SetupStep(
          SetupStepKind.failed,
          error: SetupErrorKind.notZigbee2Mqtt,
        ).props,
        {'step': 'failed', 'error': 'not_zigbee2_mqtt'},
      );
      expect(const SetupStep(SetupStepKind.review, devices: 7).props, {
        'step': 'review',
        'devices': '6-20',
      });
      expect(const SetupStep(SetupStepKind.scanEmpty).props, {
        'step': 'scan_empty',
        'hub': 'none',
      });
    });

    // 2.10.4: the class of the port typed on the broker form, never the port.
    test('manual_test carries the port class', () {
      expect(portClassOf(1883), '1883');
      expect(portClassOf(8883), '8883');
      expect(portClassOf(8080), 'web');
      expect(portClassOf(8123), 'web');
      expect(portClassOf(1884), 'other');
      expect(
        const SetupStep(
          SetupStepKind.manualTest,
          result: ManualTestResult.z2mBrokerElsewhere,
          portClass: 'web',
        ).props,
        {
          'step': 'manual_test',
          'result': 'z2m_broker_elsewhere',
          'port': 'web',
        },
      );
    });

    // 2.10.2: the review's preselection, and leaving it without a dashboard.
    test('setup_step review carries how many were ticked', () {
      expect(
        const SetupStep(SetupStepKind.review, devices: 3, selected: 0).props,
        {'step': 'review', 'devices': '1-5', 'selected': '0'},
      );
      expect(
        const SetupStep(
          SetupStepKind.reviewLeft,
          devices: 3,
          selected: 2,
        ).props,
        {'step': 'review_left', 'devices': '1-5', 'selected': '1-5'},
      );
    });

    // 2.8: the import from Home Assistant, counts only.
    test('ha_import: the sign-in, by method and outcome', () {
      expect(
        const HaImportEvent(
          HaImportStep.signIn,
          method: HaSignInMethod.page,
          outcome: HaSignInOutcome.refused,
        ).props,
        {'step': 'sign_in', 'method': 'page', 'outcome': 'refused'},
      );
    });

    test('ha_import: steps with bucketed counts', () {
      expect(
        const HaImportEvent(
          HaImportStep.preview,
          devices: 3,
          rooms: 3,
          zhaOnly: false,
        ).props,
        {'step': 'preview', 'devices': '1-5', 'rooms': '1-5', 'zha_only': 'no'},
      );
      expect(
        const HaImportEvent(
          HaImportStep.failed,
          error: HaReadError.badToken,
        ).props,
        {'step': 'failed', 'error': 'bad_token'},
      );
      expect(
        const HaImportEvent(
          HaImportStep.imported,
          renamed: 0,
          dashboards: 2,
          devices: 25,
        ).props,
        {
          'step': 'imported',
          'renamed': '0',
          'dashboards': '1-5',
          'devices': '21+',
        },
      );
    });

    // 2.7.2: the broker form's Test & connect, without the address.
    test('setup_step manual_test: the outcome, devices and tidied', () {
      expect(
        const SetupStep(
          SetupStepKind.manualTest,
          result: ManualTestResult.auth,
          tidied: false,
        ).props,
        {'step': 'manual_test', 'result': 'auth', 'tidied': 'no'},
      );
      expect(
        const SetupStep(
          SetupStepKind.manualTest,
          result: ManualTestResult.connected,
          devices: 3,
          tidied: true,
        ).props,
        {
          'step': 'manual_test',
          'result': 'connected',
          'devices': '1-5',
          'tidied': 'yes',
        },
      );
    });

    // 2.9.6: which way out of the empty result was tapped.
    test('setup_step empty_choice: the choice', () {
      expect(
        const SetupStep(
          SetupStepKind.emptyChoice,
          choice: ScanEmptyChoice.otherNetwork,
        ).props,
        {'step': 'empty_choice', 'choice': 'other_network'},
      );
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
      expect(const HelpOpened(HelpFrom.noConnection).props, {
        'from': 'no_connection',
      });
      expect(const HelpOpened(HelpFrom.deviceListMissing).name, 'help_opened');
      expect(const SupportContact(HelpFrom.setupError, ContactVia.copy).props, {
        'from': 'setup_error',
        'via': 'copy',
      });
      expect(
        const SupportContact(HelpFrom.demo, ContactVia.email).name,
        'support_contact',
      );
      expect(const CommunityOpened(HelpFrom.settings).name, 'community_opened');
      expect(const CommunityOpened(HelpFrom.homeUnreachable).props, {
        'from': 'home_unreachable',
      });
    });

    test('buckets', () {
      expect(bucket(0, const [0], ranges: const [(1, 10)], top: '11+'), '0');
      expect(
        bucket(10, const [0], ranges: const [(1, 10)], top: '11+'),
        '1-10',
      );
      expect(bucket(11, const [0], ranges: const [(1, 10)], top: '11+'), '11+');
    });
  });
}
