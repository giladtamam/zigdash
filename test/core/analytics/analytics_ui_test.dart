import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/connections/discovery/no_network.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/core/analytics/analytics_tracker.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/dashboards/widgets/analytics_consent_card.dart';
import 'package:zigdash/features/onboarding/demo_service.dart';
import 'package:zigdash/features/onboarding/setup/ai_help.dart';
import 'package:zigdash/features/onboarding/setup/setup_analytics.dart';
import 'package:zigdash/features/onboarding/setup/setup_candidate.dart';
import 'package:zigdash/features/connections/discovery/hub_probe.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';

Connection _home(String host) => Connection(
  transport: ConnectionTransport.mqtt,
  id: 'c1',
  name: 'Home',
  host: host,
  port: 1883,
  protocol: MqttProtocol.tcp,
  keepAliveSeconds: 60,
  autoConnect: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Future<SharedPreferences> _card(
  WidgetTester tester, {
  required String host,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(p),
        analyticsAvailableProvider.overrideWithValue(true),
        analyticsSinkProvider.overrideWithValue(_NullSink()),
        connectionByIdProvider.overrideWith((ref, _) async => _home(host)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AnalyticsConsentCard(connectionId: 'c1')),
      ),
    ),
  );
  await tester.pump();
  return p;
}

class _NullSink implements AnalyticsSink {
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) {}
}

void main() {
  group("the upgraders' card", () {
    testWidgets('asks once on a real home and records the answer', (
      tester,
    ) async {
      final prefs = await _card(tester, host: '192.168.1.2');
      expect(find.text('Help improve ZigDash?'), findsOneWidget);
      await tester.tap(find.text('Share'));
      await tester.pump();
      expect(prefs.getBool('analytics_consent'), isTrue);
      expect(find.text('Help improve ZigDash?'), findsNothing);
    });

    testWidgets('No thanks is remembered', (tester) async {
      final prefs = await _card(tester, host: '192.168.1.2');
      await tester.tap(find.text('No thanks'));
      await tester.pump();
      expect(prefs.getBool('analytics_consent'), isFalse);
      expect(find.text('Help improve ZigDash?'), findsNothing);
    });

    testWidgets('never on the demo home', (tester) async {
      await _card(tester, host: demoHost);
      expect(find.text('Help improve ZigDash?'), findsNothing);
    });

    testWidgets('never once answered', (tester) async {
      await _card(
        tester,
        host: '192.168.1.2',
        prefs: {'analytics_consent': false},
      );
      expect(find.text('Help improve ZigDash?'), findsNothing);
    });
  });

  group('setup steps', () {
    const scanning = SetupScanning([]);
    test('the funnel', () {
      expect(setupStepFor(const SetupIdle(), scanning)?.props, {
        'step': 'started',
      });
      expect(
        setupStepFor(scanning, const SetupScanning([], done: true)),
        isNull,
        reason: 'more scan results are not a step',
      );
      expect(setupStepFor(scanning, const SetupScanEmpty())?.props, {
        'step': 'scan_empty',
        'hub': 'none',
      });

      // 2.7.2: asking Zigbee2MQTT where its broker is counts once, with the
      // outcome; the asking state itself is not a step.
      const asking = SetupScanEmpty(
        z2m: (status: Z2mAnswerStatus.asking, server: ''),
      );
      expect(setupStepFor(const SetupScanEmpty(), asking), isNull);
      expect(
        setupStepFor(
          asking,
          const SetupScanEmpty(
            z2m: (
              status: Z2mAnswerStatus.localOnly,
              server: 'mqtt://localhost:1883',
            ),
          ),
        )?.props,
        {'step': 'z2m_asked', 'result': 'local_only'},
      );
      expect(
        setupStepFor(
          asking,
          const SetupVerifying(
            SetupCandidate(
              host: '192.168.1.30',
              port: 1884,
              protocol: MqttProtocol.tcp,
            ),
          ),
        )?.props,
        {'step': 'z2m_asked', 'result': 'broker'},
      );
      expect(
        setupStepFor(
          null,
          const SetupFailed(SetupErrorKind.authRequired),
        )?.props,
        {'step': 'failed', 'error': 'auth_required'},
      );
      expect(
        setupStepFor(
          null,
          const SetupFailed(
            SetupErrorKind.scanFailed,
            noNetwork: NoNetwork.mobileData,
          ),
        )?.props,
        {'step': 'failed', 'error': 'scan_failed', 'why': 'mobile_data'},
      );
      expect(
        setupStepFor(
          null,
          const SetupComplete(
            SetupResult(connectionId: 'c', dashboardId: 'd', panelCount: 12),
          ),
        )?.props,
        {'step': 'complete', 'devices': '6-20', 'via': 'scan', 'ai': 'no'},
      );
      // 3.1.3: how setup succeeded rides on complete.
      expect(
        setupStepFor(
          null,
          const SetupComplete(
            SetupResult(connectionId: 'c', dashboardId: 'd', panelCount: 3),
            via: SetupVia.homeAssistant,
          ),
        )?.props,
        {
          'step': 'complete',
          'devices': '1-5',
          'via': 'home_assistant',
          'ai': 'no',
        },
      );
      // 3.1.5: whether "Ask your AI" came first rides on complete too.
      expect(
        setupStepFor(
          null,
          const SetupComplete(
            SetupResult(connectionId: 'c', dashboardId: 'd', panelCount: 3),
          ),
          aiHelped: true,
        )?.props['ai'],
        'yes',
      );
      expect(
        const SetupStep(
          SetupStepKind.aiHelp,
          choice: AiHelpFrom.haConnect,
          result: AiHelpAction.shared,
        ).props,
        {'step': 'ai_help', 'result': 'shared', 'choice': 'ha_connect'},
      );
      expect(
        const SetupStep(
          SetupStepKind.complete,
          devices: 4,
          via: SetupVia.brokerForm,
        ).props,
        {'step': 'complete', 'devices': '1-5', 'via': 'broker_form'},
      );
    });

    // 2.5: an empty scan says what it saw, in kinds and buckets only.
    test('an empty scan reports the platform answer and what it found', () {
      const empty = SetupScanEmpty(
        hubs: [
          HubFound(kind: HubKind.zigbee2mqtt, host: '192.168.1.30', port: 8080),
          HubFound(
            kind: HubKind.homeAssistant,
            host: '192.168.1.20',
            port: 8123,
          ),
        ],
        platform: SetupPlatform.homeAssistant,
        tried: (widened: true, hostsTried: 1018, aliveHosts: 7, lateHosts: 2),
        deviceIp: '192.168.1.37',
        network: (kind: 'Wi-Fi', vpn: true),
      );
      final props = setupStepFor(scanning, empty)!.props;
      expect(props, {
        'step': 'scan_empty',
        'platform': 'home_assistant',
        'hub': 'home_assistant',
        'hosts': '254-1020',
        'widened': 'yes',
        'subnet': '192.168',
        'alive': '6-20',
        'late': '1-5',
        'vpn': 'yes',
        'net': 'wifi',
      });
      expect(
        props.values.any((v) => v.contains('192.168.1')),
        isFalse,
        reason: 'never an address',
      );
      // The answer given during the scan also tags the steps after it.
      expect(
        setupStepFor(
          scanning,
          const SetupScanEmpty(),
          platform: SetupPlatform.notSure,
        )!.props['platform'],
        'not_sure',
      );
      expect(subnetShape('10.0.0.5'), '10');
      expect(subnetShape('172.20.1.1'), '172.16');
      expect(subnetShape('8.8.8.8'), 'other');
      expect(subnetShape(null), isNull);
    });

    // 2.9.3: whether the scan's second look found the broker.
    test('scan_found says how many hosts answered only late', () {
      const candidate = SetupCandidate(
        host: '192.168.1.30',
        port: 1883,
        protocol: MqttProtocol.tcp,
      );
      expect(
        setupStepFor(
          const SetupScanning([]),
          const SetupVerifying(candidate, lateHosts: 1),
        )!.props,
        {'step': 'scan_found', 'late': '1-5'},
      );
      expect(
        setupStepFor(
          const SetupScanning([]),
          const SetupVerifying(candidate),
        )!.props,
        {'step': 'scan_found'},
      );
    });

    // 2.6.3: the empty result is counted once; chip taps re-emit it but
    // don't re-send it (they tripled the 2.6.2 diagnostics).
    test('a chip tap on the empty result does not re-send scan_empty', () {
      const scanning = SetupScanning([]);
      const empty = SetupScanEmpty(
        tried: (widened: true, hostsTried: 1018, aliveHosts: 2, lateHosts: 0),
        deviceIp: '192.168.1.37',
      );
      expect(setupStepFor(scanning, empty)!.props['step'], 'scan_empty');
      expect(
        setupStepFor(
          empty,
          const SetupScanEmpty(
            platform: SetupPlatform.homeAssistant,
            tried: (
              widened: true,
              hostsTried: 1018,
              aliveHosts: 2,
              lateHosts: 0,
            ),
            deviceIp: '192.168.1.37',
          ),
        ),
        isNull,
      );
      // A rescan ends in a fresh empty result, counted again.
      expect(setupStepFor(scanning, empty)!.props['step'], 'scan_empty');
    });

    // 2.6.2: the address check reports its outcome, never the address.
    test('the address check reports only its outcome', () {
      const empty = SetupScanEmpty(platform: SetupPlatform.homeAssistant);
      expect(
        setupStepFor(
          empty,
          const SetupScanEmpty(
            platform: SetupPlatform.homeAssistant,
            address: (status: AddressCheckStatus.checking, host: 'ha.local'),
          ),
        ),
        isNull,
        reason: 'still running',
      );
      final notResolved = setupStepFor(
        empty,
        const SetupScanEmpty(
          platform: SetupPlatform.homeAssistant,
          address: (status: AddressCheckStatus.notResolved, host: 'ha.local'),
        ),
      )!;
      expect(notResolved.props, {
        'step': 'address',
        'result': 'not_resolved',
        'platform': 'home_assistant',
      });
      expect(
        notResolved.props.values.any((v) => v.contains('ha.local')),
        isFalse,
      );
      const hub = SetupCandidate(
        host: '192.168.1.20',
        port: 1883,
        protocol: MqttProtocol.tcp,
      );
      expect(setupStepFor(empty, const SetupVerifying(hub))!.props, {
        'step': 'address',
        'result': 'broker',
      });
      // A broker that wants a login: found, then the login step.
      expect(
        setupStepFor(
          const SetupVerifying(hub),
          const SetupNeedsAuth(hub),
        )!.props['step'],
        'needs_login',
      );
      // A chip tap re-emits the same check: counted once.
      const nothing = SetupScanEmpty(
        address: (status: AddressCheckStatus.nothing, host: 'ha.local'),
      );
      expect(setupStepFor(empty, nothing)!.props['result'], 'nothing');
      expect(
        setupStepFor(
          nothing,
          const SetupScanEmpty(
            platform: SetupPlatform.smlight,
            address: (status: AddressCheckStatus.nothing, host: 'ha.local'),
          ),
        ),
        isNull,
      );
      expect(
        setupStepFor(
          empty,
          const SetupScanEmpty(
            hubs: [
              HubFound(
                kind: HubKind.homeAssistant,
                host: '192.168.1.20',
                port: 8123,
              ),
            ],
            address: (status: AddressCheckStatus.hub, host: '192.168.1.20'),
          ),
        )!.props,
        {'step': 'address', 'result': 'hub'},
      );
    });

    // 2.6.1: a login prompt carries the platform answer, so a user who
    // leaves there can be read against the hint they were shown.
    test('the login steps report the platform answer', () {
      const hub = SetupCandidate(
        host: '192.168.1.10',
        port: 1883,
        protocol: MqttProtocol.tcp,
      );
      expect(
        setupStepFor(
          null,
          const SetupNeedsAuth(hub, platform: SetupPlatform.homeAssistant),
        )!.props,
        {'step': 'needs_login', 'platform': 'home_assistant'},
      );
      expect(
        setupStepFor(
          null,
          const SetupNeedsAuth(hub, rejected: true),
          platform: SetupPlatform.piOrDocker,
        )!.props,
        {'step': 'login_rejected', 'platform': 'pi_or_docker'},
      );
      expect(setupStepFor(null, const SetupNeedsAuth(hub))!.props, {
        'step': 'needs_login',
      });
    });
  });

  test('routes that count as features', () {
    expect(featureForPath('/connections/c1/devices'), Feature.devicesTab);
    expect(featureForPath('/connections/c1/devices/0x1'), Feature.devicePage);
    expect(featureForPath('/connections/c1/scenes'), Feature.scenes);
    expect(featureForPath('/connections/c1/dashboards'), isNull);
    expect(featureForPath('/settings'), isNull);
  });
}
