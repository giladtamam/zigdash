import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/onboarding/first_run.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/connections/discovery/address_check.dart';
import 'package:zigdash/features/connections/discovery/broker_probe.dart';
import 'package:zigdash/features/connections/discovery/broker_scan_service.dart';
import 'package:zigdash/features/connections/discovery/hub_probe.dart';
import 'package:zigdash/features/connections/discovery/no_network.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/onboarding/setup/recommendation_policy.dart';
import 'package:zigdash/features/connections/discovery/z2m_frontend.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/onboarding/setup/setup_providers.dart';
import 'package:zigdash/features/onboarding/setup/setup_reminder.dart';
import 'package:zigdash/features/onboarding/setup/setup_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';

const _lamp = Z2mDevice(
  friendlyName: 'lamp',
  type: 'EndDevice',
  exposes: [Z2mExpose(type: 'light')],
);
const _batterySensor = Z2mDevice(
  friendlyName: 'battery_sensor',
  type: 'EndDevice',
  exposes: [Z2mExpose(type: 'numeric', property: 'battery')],
);
const _mystery = Z2mDevice(
  friendlyName: 'mystery_box',
  type: 'EndDevice',
  supported: false,
);

class _FakeDiagnostics extends ConnectDiagnostics {
  _FakeDiagnostics(this.reports, {this.hold});
  final List<DiagnosticsReport> reports;

  /// Keeps the check running until it completes.
  final Future<void>? hold;

  @override
  Future<DiagnosticsReport> run({
    required BrokerConfig config,
    required String password,
    String base = 'zigbee2mqtt',
  }) async {
    await hold;
    return reports.removeAt(0);
  }
}

DiagnosticsReport _ok() => const DiagnosticsReport(
  steps: [],
  connected: true,
  candidatesTried: 1,
  deviceNames: ['lamp'],
);

DiagnosticsReport _authFail() => const DiagnosticsReport(
  steps: [
    StepResult(
      step: DiagnosticStep.auth,
      status: StepStatus.fail,
      detailKey: 'diagAuthRejected',
    ),
  ],
  connected: false,
  candidatesTried: 1,
);

class _FakeStore implements SetupStore {
  @override
  Future<SetupResult> create({
    required String host,
    required int port,
    required MqttProtocol protocol,
    String? username,
    String? password,
    String base = 'zigbee2mqtt',
    String? dashboardName,
    int dashboardColor = 0,
    int dashboardIcon = 0,
    required List<ReviewRow> selected,
    List<ReviewRow> notSelected = const [],
    ConnectionTransport transport = ConnectionTransport.mqtt,
  }) async => SetupResult(
    connectionId: 'c1',
    dashboardId: 'd1',
    panelCount: selected.length,
  );
}

class _FakeFirstRun implements FirstRun {
  var demoStarted = 0;

  @override
  Future<String> startDemo() async {
    demoStarted++;
    return 'demo1';
  }

  @override
  Future<void> finish(String connectionId) async {}
}

class _RecordingSink implements AnalyticsSink {
  _RecordingSink(this.sent);
  final List<(String, Map<String, String>)> sent;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  void send(String name, Map<String, String> props) => sent.add((name, props));
}

/// Pumps the setup screen with a coordinator built on fakes.
Future<SetupCoordinator> _pump(
  WidgetTester tester, {
  List<DiagnosticsReport>? reports,
  Stream<ProbeResult> Function(String ip)? scan,
  ScanRunFactory? run,
  Z2mFetchResult fetch = const Z2mFetchResult(detected: true, devices: [_lamp]),
  Z2mFetchResult Function(String base)? fetchFor,
  Locale? locale,
  _FakeFirstRun? firstRun,
  List<Override> extra = const [],
  AddressChecker? checkAddress,
  bool vpn = false,
  NoNetwork? noNetwork,
  _FakeReminder? reminder,
  Z2mBrokerLookup? askZ2m,
  Future<void>? holdDiagnostics,
}) async {
  // The setup screens are lists that grew in 2.5 (progress, the platform
  // question); a tall view keeps every action built and tappable.
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final coordinator = SetupCoordinator(
    scan:
        run ??
        (ip, hubs) => ScanRun(
          events:
              (scan ??
                      (ip) => Stream.fromIterable([
                        const ProbeResult(host: '192.168.1.10', port: 1883),
                      ]))(ip)
                  .map(BrokerFound.new),
          addHub: (_) {},
        ),
    deviceIp: () async => noNetwork == null ? '192.168.1.5' : null,
    noNetwork: () async => noNetwork ?? NoNetwork.unknown,
    diagnostics: _FakeDiagnostics(reports ?? [_ok()], hold: holdDiagnostics),
    fetchDevices: (config, password, base) async =>
        fetchFor?.call(base) ?? fetch,
    creator: _FakeStore(),
    checkAddress: checkAddress,
    networkFacts: () async => (kind: 'wifi', vpn: vpn),
    askZ2m: askZ2m,
    probeBroker: askZ2m == null ? null : (host, port) async => null,
  );
  addTearDown(coordinator.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        setupCoordinatorProvider.overrideWith((ref) {
          ref.onDispose(() {}); // test owns the lifecycle
          return coordinator;
        }),
        firstRunProvider.overrideWithValue(firstRun ?? _FakeFirstRun()),
        setupReminderProvider.overrideWithValue(reminder ?? _FakeReminder()),
        ...extra,
      ],
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/setup',
          routes: [
            GoRoute(path: '/setup', builder: (_, __) => const SetupScreen()),
            GoRoute(
              path: '/setup/manual',
              builder: (_, state) => Text(
                state.uri.hasQuery
                    ? 'manual entry ${state.uri.query}'
                    : 'manual entry',
              ),
            ),
            GoRoute(
              path: '/connections/:id/dashboards',
              builder: (_, state) =>
                  Text('dashboards of ${state.pathParameters['id']}'),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  return coordinator;
}

void main() {
  group('3.1.4: a way out of setup', () {
    // A scan still running, with one broker found to tap.
    Future<SetupCoordinator> found(
      WidgetTester tester, {
      Future<void>? hold,
    }) async {
      final scan = StreamController<ProbeResult>();
      addTearDown(scan.close);
      final coordinator = await _pump(
        tester,
        scan: (_) => scan.stream,
        holdDiagnostics: hold,
      );
      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      scan.add(const ProbeResult(host: '192.168.1.10', port: 1883));
      await tester.pump();
      await tester.tap(find.text('Possible connection found'));
      await tester.pump();
      await tester.pump();
      return coordinator;
    }

    testWidgets('back in the middle of setup starts it over', (tester) async {
      final coordinator = await found(tester);
      expect(coordinator.state, isA<SetupReview>());
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(coordinator.state, isA<SetupIdle>());
      expect(find.text('Find my setup'), findsOneWidget);
    });

    testWidgets('a long check says so and can be cancelled', (tester) async {
      final hold = Completer<void>();
      final coordinator = await found(tester, hold: hold.future);
      expect(coordinator.state, isA<SetupVerifying>());
      expect(find.textContaining('up to 30 seconds'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
      expect(find.textContaining('up to 30 seconds'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(find.text('Find my setup'), findsOneWidget);
      hold.complete();
      await tester.pump();
      await tester.pump();
      expect(coordinator.state, isA<SetupIdle>());
    });
  });

  testWidgets('welcome offers Find my setup and manual entry', (tester) async {
    await _pump(tester);
    expect(find.text('Find my setup'), findsOneWidget);
    expect(find.text('Enter details manually'), findsOneWidget);
  });

  testWidgets('scanning shows progressive candidates; tapping one verifies', (
    tester,
  ) async {
    final controller = StreamController<ProbeResult>();
    addTearDown(controller.close);
    final coordinator = await _pump(tester, scan: (_) => controller.stream);

    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    expect(find.text('Looking for a connection…'), findsOneWidget);

    controller.add(const ProbeResult(host: '192.168.1.10', port: 1883));
    await tester.pump();
    expect(find.text('Possible connection found'), findsOneWidget);
    expect(find.textContaining('192.168.1.10:1883'), findsOneWidget);

    await tester.tap(find.text('Possible connection found'));
    await tester.pump();
    await tester.pump();
    expect(coordinator.state, isA<SetupReview>());
  });

  // 2.5: the platform question during the scan, and a hub-aware empty result.
  testWidgets('the platform chips reach the coordinator while scanning', (
    tester,
  ) async {
    final controller = StreamController<ScanEvent>();
    addTearDown(controller.close);
    final added = <HubKind>[];
    final coordinator = await _pump(
      tester,
      run: (_, __) => ScanRun(events: controller.stream, addHub: added.add),
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();

    expect(
      find.text('While we look: where does Zigbee2MQTT run?'),
      findsOneWidget,
    );
    controller.add(const ScanProgress(400, 1526));
    await tester.pump();
    expect(find.text('Checked 400 of 1526 addresses'), findsOneWidget);

    await tester.tap(find.text('SMLIGHT hub'));
    await tester.pump();
    expect(coordinator.platform, SetupPlatform.smlight);
    expect(added, [HubKind.smlight]);
    expect(find.text('Looking for your SMLIGHT hub…'), findsOneWidget);

    controller.add(
      const HubSeen(
        HubFound(kind: HubKind.homeAssistant, host: '192.168.1.20', port: 8123),
      ),
    );
    await tester.pump();
    expect(find.text('Found Home Assistant at 192.168.1.20'), findsOneWidget);
  });

  testWidgets('a hub without a broker: the specific fix and a filled-in form', (
    tester,
  ) async {
    const ha = HubFound(
      kind: HubKind.homeAssistant,
      host: '192.168.1.20',
      port: 8123,
    );
    await _pump(
      tester,
      run: (_, __) => ScanRun(
        events: Stream.fromIterable(const [HubSeen(ha)]),
        addHub: (_) {},
      ),
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Found Home Assistant, but no MQTT broker'),
      findsOneWidget,
    );
    expect(find.textContaining('Mosquitto broker add-on'), findsOneWidget);
    // 2.6.6: ZHA users are told why, and the demo is a button.
    expect(find.textContaining('(ZHA)'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Try demo'), findsOneWidget);
    // Only Home Assistant's guide; no platform question any more.
    expect(find.textContaining('SMLIGHT'), findsNothing);
    // Nothing answers on 1883, so Try again leads, not Connect to.
    // 3.1.2: Home Assistant's sign-in leads; Try again follows.
    expect(
      find.widgetWithText(FilledButton, 'Connect through Home Assistant'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Try again'), findsOneWidget);
    expect(
      find.widgetWithText(TextButton, 'Connect to 192.168.1.20'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Connect to 192.168.1.20'));
    await tester.tap(find.text('Connect to 192.168.1.20'));
    await tester.pumpAndSettle();
    expect(
      find.text('manual entry host=192.168.1.20&port=1883'),
      findsOneWidget,
    );
  });

  testWidgets('no candidates with an answer: that platform only', (
    tester,
  ) async {
    final coordinator = await _pump(tester, scan: (_) => const Stream.empty());
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    expect(find.text('No connection found'), findsOneWidget);

    await tester.tap(find.text('Raspberry Pi or Docker'));
    await tester.pump();
    expect(coordinator.platform, SetupPlatform.piOrDocker);
    expect(
      find.textContaining('No MQTT broker found on this network'),
      findsOneWidget,
    );
    expect(find.textContaining('Raspberry Pi / Linux: check'), findsOneWidget);
    expect(find.textContaining('SMLIGHT / SMHUB: open'), findsNothing);
  });

  // 2.6.2: the address check. The scanner guesses subnets; the user knows
  // the address, so the empty result asks for it.
  testWidgets('the empty result asks for the address, by platform', (
    tester,
  ) async {
    await _pump(tester, scan: (_) => const Stream.empty());
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    expect(
      find.text(
        'What is the address of your hub, or of the machine running Zigbee2MQTT?',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Home Assistant').first);
    await tester.pump();
    expect(find.text('Where do you open Home Assistant?'), findsOneWidget);
    expect(find.textContaining('enter it below'), findsOneWidget);
    expect(find.text('Check this address'), findsOneWidget);
  });

  testWidgets('a broker at the typed address goes on to the devices', (
    tester,
  ) async {
    final asked = <String>[];
    final coordinator = await _pump(
      tester,
      scan: (_) => const Stream.empty(),
      checkAddress: (host, port) async {
        asked.add(host);
        return const AddressCheckResult(
          AddressOutcome.broker,
          broker: ProbeResult(host: '192.168.1.20', port: 1883),
        );
      },
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'homeassistant.local');
    await tester.pump();
    await tester.tap(find.text('Check this address'));
    // Check, verify, fetch: a few turns of the event loop.
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }
    expect(asked, ['homeassistant.local']);
    expect(coordinator.state, isA<SetupReview>());
    expect(find.text('Create dashboard with 1'), findsOneWidget);
  });

  testWidgets('nothing at the typed address is said on the field', (
    tester,
  ) async {
    await _pump(
      tester,
      scan: (_) => const Stream.empty(),
      checkAddress: (host, port) async =>
          const AddressCheckResult(AddressOutcome.notResolved),
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'homeassistant.local');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump();
    expect(
      find.textContaining('homeassistant.local could not be looked up'),
      findsOneWidget,
    );
    // The field and the rest of the result are still there.
    expect(find.text('Check this address'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('a hub page at the typed address: the hub result', (
    tester,
  ) async {
    await _pump(
      tester,
      scan: (_) => const Stream.empty(),
      checkAddress: (host, port) async => const AddressCheckResult(
        AddressOutcome.hub,
        hub: HubFound(
          kind: HubKind.homeAssistant,
          host: '192.168.1.20',
          port: 8123,
        ),
      ),
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.enterText(find.byType(TextField), '192.168.1.20');
    await tester.pump();
    await tester.tap(find.text('Check this address'));
    await tester.pump();
    await tester.pump();
    expect(
      find.text('Found Home Assistant, but no MQTT broker'),
      findsOneWidget,
    );
    expect(find.text('Connect to 192.168.1.20'), findsOneWidget);
    expect(find.text('Check this address'), findsNothing);
  });

  // 2.6.4: the address question leads the empty result; Check is primary.
  testWidgets('the empty result leads with the address check', (tester) async {
    await _pump(tester, scan: (_) => const Stream.empty());
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    final check = find.widgetWithText(FilledButton, 'Check this address');
    final retry = find.widgetWithText(OutlinedButton, 'Try again');
    expect(check, findsOneWidget);
    expect(retry, findsOneWidget);
    // Above the chips, above Try again.
    final question = tester.getTopLeft(
      find.text(
        'What is the address of your hub, or of the machine running Zigbee2MQTT?',
      ),
    );
    expect(question.dy, lessThan(tester.getTopLeft(find.text('Not sure')).dy));
    expect(tester.getTopLeft(check).dy, lessThan(tester.getTopLeft(retry).dy));
  });

  // 2.6.7: a VPN hides the home network from the scan; say so on the
  // empty result, and only then.
  testWidgets('the empty result names a VPN when one is on', (tester) async {
    await _pump(tester, scan: (_) => const Stream.empty(), vpn: true);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('A VPN is on'), findsOneWidget);
  });

  testWidgets('no VPN, no VPN note', (tester) async {
    await _pump(tester, scan: (_) => const Stream.empty());
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('A VPN is on'), findsNothing);
  });

  // 2.8.1: almost nothing answered on the network: a guest Wi-Fi or a
  // router keeping devices apart. Said only then.
  for (final (alive, shown) in [(3, true), (40, false)]) {
    testWidgets(
      '$alive devices answered: isolation hint ${shown ? 'shown' : 'not shown'}',
      (tester) async {
        await _pump(
          tester,
          run: (_, _) => ScanRun(
            events: Stream.fromIterable([
              ScanTriedEvent(
                widened: true,
                hostsTried: 1018,
                aliveHosts: alive,
              ),
            ]),
            addHub: (_) {},
          ),
        );
        await tester.tap(find.text('Find my setup'));
        await tester.pump();
        await tester.pump();
        await tester.pump();
        expect(
          find.textContaining('guest network'),
          shown ? findsOneWidget : findsNothing,
        );
      },
    );
  }

  // 2.9.6: the empty result with no hub found offers three ways out.
  group('the empty result\'s choices', () {
    late List<(String, Map<String, String>)> sent;
    late List<Override> analytics;
    setUp(() {
      sent = [];
      analytics = [
        analyticsProvider.overrideWithValue(
          Analytics(_RecordingSink(sent), enabled: true),
        ),
      ];
    });
    List<String?> choices() => [
      for (final (name, props) in sent)
        if (name == 'setup_step' && props['step'] == 'empty_choice')
          props['choice'],
    ];

    testWidgets('no hub yet opens the Hubs page', (tester) async {
      Uri? opened;
      final original = openSetupLink;
      addTearDown(() => openSetupLink = original);
      openSetupLink = (url) async {
        opened = url;
        return true;
      };
      await _pump(tester, scan: (_) => const Stream.empty(), extra: analytics);
      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Which of these fits you?'), findsOneWidget);
      await tester.tap(find.text("I don't have a hub yet"));
      await tester.pump();
      expect(opened, hubsPageUrl);
      expect(opened.toString(), 'https://zigdash.app/hubs/');
      expect(choices(), ['no_hub']);
    });

    testWidgets('Home Assistant checks homeassistant.local', (tester) async {
      final asked = <String>[];
      final coordinator = await _pump(
        tester,
        scan: (_) => const Stream.empty(),
        extra: analytics,
        checkAddress: (host, port) async {
          asked.add(host);
          return const AddressCheckResult(AddressOutcome.notResolved);
        },
      );
      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('I use Home Assistant'));
      await tester.pump();
      await tester.pump();
      expect(asked, ['homeassistant.local']);
      expect(coordinator.platform, SetupPlatform.homeAssistant);
      expect(find.textContaining('Mosquitto broker add-on'), findsOneWidget);
      // The field shows the address the choice checked, and its outcome.
      expect(
        find.widgetWithText(TextField, 'homeassistant.local'),
        findsOneWidget,
      );
      // 3.1.3: a Home Assistant user is sent to its sign-in, above.
      expect(
        find.textContaining("homeassistant.local can't be found"),
        findsOneWidget,
      );
      expect(
        find.textContaining('Tap Connect through Home Assistant above'),
        findsOneWidget,
      );
      expect(choices(), ['home_assistant']);

      // Which way into the sign-in is counted (3.1.3).
      await tester.ensureVisible(find.byKey(const Key('setup-ha-shortcut')));
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('setup-ha-shortcut')),
          matching: find.text('Connect through Home Assistant'),
        ),
      );
      await tester.pump();
      expect(
        [
          for (final (name, props) in sent)
            if (name == 'setup_step' && props['step'] == 'ha_opened')
              props['choice'],
        ],
        ['empty_card'],
      );
    });

    testWidgets('another network explains, and checks a usual name', (
      tester,
    ) async {
      final asked = <String>[];
      await _pump(
        tester,
        scan: (_) => const Stream.empty(),
        extra: analytics,
        checkAddress: (host, port) async {
          asked.add(host);
          return const AddressCheckResult.nothing();
        },
      );
      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('smhub.local'), findsNothing);
      await tester.tap(find.text('My hub is on another network'));
      await tester.pump();
      expect(
        find.textContaining('A guest Wi-Fi, or a second router'),
        findsOneWidget,
      );
      await tester.tap(find.textContaining('smhub.local'));
      await tester.pump();
      await tester.pump();
      expect(asked, ['smhub.local']);
      expect(
        find.textContaining('Nothing answered at smhub.local'),
        findsOneWidget,
      );
      expect(choices(), ['other_network']);
    });

    testWidgets('a hub found: no choices', (tester) async {
      await _pump(
        tester,
        run: (_, _) => ScanRun(
          events: Stream.fromIterable(const [
            HubSeen(
              HubFound(
                kind: HubKind.homeAssistant,
                host: '192.168.1.20',
                port: 8123,
              ),
            ),
          ]),
          addHub: (_) {},
        ),
      );
      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(
        find.text('Found Home Assistant, but no MQTT broker'),
        findsOneWidget,
      );
      expect(find.text('Which of these fits you?'), findsNothing);
    });
  });

  // 2.6.6: every address-field user tapped Check on an empty field first, so
  // Check waits for text, like the login button waits for a username.
  testWidgets('Check is disabled until an address is typed', (tester) async {
    await _pump(tester, scan: (_) => const Stream.empty());
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    FilledButton check() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Check this address'),
    );
    expect(check().onPressed, isNull);
    await tester.enterText(find.byType(TextField).first, '   ');
    await tester.pump();
    expect(check().onPressed, isNull, reason: 'spaces are not an address');
    await tester.enterText(find.byType(TextField).first, 'homeassistant.local');
    await tester.pump();
    expect(check().onPressed, isNotNull);
  });

  // 2.6.4: Enter login waits for a username; the broker refused anonymous
  // access, so an empty one would only show the prompt again.
  testWidgets('the login prompt waits for a username', (tester) async {
    await _pump(
      tester,
      scan: (_) => Stream.value(
        const ProbeResult(host: '192.168.1.10', port: 1883, needsAuth: true),
      ),
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Username (optional)'), findsNothing);
    final button = find.widgetWithText(FilledButton, 'Enter login');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'mqtt');
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  // 2.8.1: people left the login step without typing. It says where the
  // login goes, links the policy and offers the demo.
  testWidgets('the login prompt says the login stays on the phone', (
    tester,
  ) async {
    await _pump(
      tester,
      scan: (_) => Stream.value(
        const ProbeResult(host: '192.168.1.10', port: 1883, needsAuth: true),
      ),
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('stays on this phone'), findsOneWidget);
    expect(find.text('What ZigDash keeps'), findsOneWidget);
    expect(find.text('Try the demo first'), findsOneWidget);
  });

  testWidgets('no candidates shows tailored guidance and actions', (
    tester,
  ) async {
    await _pump(tester, scan: (_) => const Stream.empty());
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();

    expect(find.text('No connection found'), findsOneWidget);
    expect(find.text('Where does Zigbee2MQTT run?'), findsOneWidget);
    expect(find.textContaining('Home Assistant'), findsWidgets);
    expect(find.textContaining('SMLIGHT'), findsWidgets);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Enter details manually'), findsOneWidget);
  });

  testWidgets('anonymous rejection prompts for credentials, preserving host', (
    tester,
  ) async {
    await _pump(tester, reports: [_authFail(), _ok()]);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    // The single broker found is verified without a tap.
    await tester.pump();
    await tester.pump();

    expect(find.text('This broker needs a login'), findsOneWidget);
    expect(find.textContaining('192.168.1.10'), findsOneWidget);
    // No platform answer: which login it is, and where each platform keeps it.
    expect(find.textContaining('not the password of your hub'), findsOneWidget);
    expect(find.textContaining('Home Assistant: use a'), findsOneWidget);
    expect(
      find.textContaining('Raspberry Pi or Docker: the user'),
      findsOneWidget,
    );
    expect(find.textContaining('SMLIGHT: the login'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Username').first,
      'user',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password (optional)').first,
      'secret',
    );
    await tester.tap(find.text('Enter login'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Your devices'), findsNothing); // subtitle, not title
    expect(find.textContaining('1 device found.'), findsOneWidget);
  });

  testWidgets('the login prompt names only the platform the user chose', (
    tester,
  ) async {
    final coordinator = await _pump(tester, reports: [_authFail(), _ok()]);
    coordinator.setPlatform(SetupPlatform.homeAssistant);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('This broker needs a login'), findsOneWidget);
    expect(find.textContaining('not the password of your hub'), findsOneWidget);
    expect(find.textContaining('Home Assistant: use a'), findsOneWidget);
    expect(find.textContaining('Raspberry Pi or Docker'), findsNothing);
    expect(find.textContaining('SMLIGHT: the login'), findsNothing);
  });

  testWidgets('Home Assistant users are offered its sign-in (3.1.2)', (
    tester,
  ) async {
    final controller = StreamController<ScanEvent>();
    addTearDown(controller.close);
    await _pump(
      tester,
      run: (_, __) => ScanRun(events: controller.stream, addHub: (_) {}),
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    expect(find.byKey(const Key('setup-ha-shortcut')), findsNothing);

    await tester.tap(find.text('Home Assistant').first);
    await tester.pump();
    expect(find.byKey(const Key('setup-ha-shortcut')), findsOneWidget);
    expect(find.text('Connect through Home Assistant'), findsOneWidget);
  });

  testWidgets(
    'a ZHA answer is counted and says ZigDash cannot see ZHA (3.1.3)',
    (tester) async {
      final sent = <(String, Map<String, String>)>[];
      final controller = StreamController<ScanEvent>();
      addTearDown(controller.close);
      await _pump(
        tester,
        run: (_, __) => ScanRun(events: controller.stream, addHub: (_) {}),
        extra: [
          analyticsProvider.overrideWithValue(
            Analytics(_RecordingSink(sent), enabled: true),
          ),
        ],
      );
      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      expect(find.byKey(const Key('setup-zha-note')), findsNothing);

      await tester.tap(find.text('ZHA, no Zigbee2MQTT'));
      await tester.pump();
      expect(find.byKey(const Key('setup-zha-note')), findsOneWidget);
      expect(find.textContaining("can't see devices in ZHA"), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('setup-zha-note')),
          matching: find.text('Try demo'),
        ),
        findsOneWidget,
      );
      expect(
        [
          for (final (name, props) in sent)
            if (name == 'setup_step' && props['step'] == 'platform_chosen')
              props['platform'],
        ],
        ['zha'],
      );
    },
  );

  testWidgets('the login prompt offers Home Assistant sign-in to its users', (
    tester,
  ) async {
    final coordinator = await _pump(tester, reports: [_authFail(), _ok()]);
    coordinator.setPlatform(SetupPlatform.homeAssistant);
    await tester.tap(find.text('Find my setup'));
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }
    expect(find.text('This broker needs a login'), findsOneWidget);
    expect(find.byKey(const Key('setup-ha-shortcut')), findsOneWidget);
  });

  testWidgets('rejected credentials show the rejected explanation', (
    tester,
  ) async {
    await _pump(tester, reports: [_authFail(), _authFail(), _ok()]);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    // The single broker found is verified without a tap.
    await tester.pump();
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextField, 'Username').first,
      'user',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password (optional)').first,
      'wrong',
    );
    await tester.tap(find.text('Enter login'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('rejected'), findsWidgets);
  });

  testWidgets('a login the broker never answers says so, not "unknown"', (
    tester,
  ) async {
    const noAnswer = DiagnosticsReport(
      steps: [
        StepResult(
          step: DiagnosticStep.connack,
          status: StepStatus.fail,
          detailKey: 'diagLoginNoAnswer',
        ),
      ],
      connected: false,
      candidatesTried: 1,
    );
    await _pump(tester, reports: [_authFail(), noAnswer, _ok()]);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextField, 'Username').first,
      'user',
    );
    await tester.ensureVisible(find.text('Enter login'));
    await tester.pump();
    await tester.tap(find.text('Enter login'));
    await tester.pump();
    await tester.pump();

    expect(find.text("The broker didn't answer the login"), findsOneWidget);
    expect(find.textContaining('Mosquitto add-on'), findsOneWidget);
    expect(find.text('Something went wrong'), findsNothing);

    // Try again re-checks the same login.
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('1 device found.'), findsOneWidget);
  });

  testWidgets('on mobile data: says so, opens Wi-Fi, no Try again', (
    tester,
  ) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('zigdash/app'),
      (call) async {
        calls.add(call.method);
        return true;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('zigdash/app'),
        null,
      ),
    );
    final c = await _pump(tester, noNetwork: NoNetwork.mobileData);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();

    expect(find.text("Your phone isn't on Wi-Fi"), findsOneWidget);
    expect(find.textContaining('mobile data'), findsOneWidget);
    expect(find.text('Waiting for Wi-Fi…'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.text('Enter details manually'), findsOneWidget);

    await tester.tap(find.text('Open Wi-Fi settings'));
    await tester.pump();
    expect(calls, ['openWifiSettings']);
    await c.cancel();
  });

  testWidgets('no reason known: never claims mobile data', (tester) async {
    final c = await _pump(tester, noNetwork: NoNetwork.unknown);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();

    expect(find.text('No local network'), findsOneWidget);
    expect(find.textContaining('mobile data'), findsNothing);
    expect(find.text('Open Wi-Fi settings'), findsOneWidget);
    await c.cancel();
  });

  testWidgets('the unknown error has its own title and text', (tester) async {
    const odd = DiagnosticsReport(
      steps: [],
      connected: false,
      candidatesTried: 1,
    );
    await _pump(tester, reports: [odd]);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('An unexpected error occurred.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets(
    'review groups devices, preselects recommended, counts selection',
    (tester) async {
      await _pump(
        tester,
        fetch: const Z2mFetchResult(
          detected: true,
          devices: [_lamp, _batterySensor, _mystery],
        ),
      );
      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      await tester.pump();
      // The single broker found is verified without a tap.
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('3 devices found'), findsOneWidget);
      expect(find.text('lamp'), findsOneWidget);
      expect(find.text('Other devices'), findsOneWidget);
      expect(find.text('Unsupported devices'), findsOneWidget);
      expect(find.text('Create dashboard with 1'), findsOneWidget);

      // Unsupported rows are not toggleable.
      await tester.tap(find.text('mystery_box'));
      await tester.pump();
      expect(find.text('Create dashboard with 1'), findsOneWidget);

      // Toggling the battery sensor adds it to the selection.
      await tester.tap(find.text('battery_sensor'));
      await tester.pump();
      expect(find.text('Create dashboard with 2'), findsOneWidget);
    },
  );

  // 2.10.4: Zigbee2MQTT names its broker by a name only its machine knows.
  testWidgets('a broker name the phone cannot use: card, manual entry with '
      'the port', (tester) async {
    await _pump(
      tester,
      run: (ip, hubs) => ScanRun(
        events: Stream.fromIterable([
          const HubSeen(
            HubFound(
              kind: HubKind.zigbee2mqtt,
              host: '192.168.1.30',
              port: 8080,
            ),
          ),
        ]),
        addHub: (_) {},
      ),
      askZ2m: (host, port) async => z2mBrokerSetting({
        'server': 'mqtt://mosquitto:1884',
      }, frontendHost: host),
    );
    await tester.tap(find.text('Find my setup'));
    for (var i = 0; i < 8; i++) {
      await tester.pump();
    }
    expect(find.textContaining("a name your phone can't use"), findsOneWidget);
    // The name is wrapped in direction marks; match around it.
    expect(find.textContaining('is a name only Zigbee2MQTT'), findsOneWidget);
    expect(find.textContaining('with port 1884'), findsOneWidget);
    // The card's own button, not the general manual-entry one below it.
    final card = find
        .ancestor(
          of: find.textContaining('is a name only Zigbee2MQTT'),
          matching: find.byType(Column),
        )
        .first;
    await tester.tap(
      find.descendant(of: card, matching: find.text('Enter details manually')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('manual entry'), findsOneWidget);
    expect(find.textContaining('port=1884'), findsOneWidget);
  });

  // 2.10.2: a list with nothing preselected (only "other" or unsupported
  // devices) says so and still creates the home, with an empty dashboard.
  testWidgets('nothing preselected: says so, creates an empty dashboard', (
    tester,
  ) async {
    final sent = <(String, Map<String, String>)>[];
    await _pump(
      tester,
      fetch: const Z2mFetchResult(
        detected: true,
        devices: [_batterySensor, _mystery],
      ),
      extra: [
        analyticsProvider.overrideWithValue(
          Analytics(_RecordingSink(sent), enabled: true),
        ),
      ],
    );
    await tester.tap(find.text('Find my setup'));
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }
    expect(find.textContaining('Nothing is ticked yet'), findsOneWidget);
    expect(find.text('Create an empty dashboard'), findsOneWidget);
    expect(
      sent.where((e) => e.$2['step'] == 'review').single.$2['selected'],
      '0',
    );
    await tester.tap(find.text('Create an empty dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('dashboards of c1'), findsOneWidget);
    expect(sent.where((e) => e.$2['step'] == 'review_left'), isEmpty);
  });

  testWidgets('leaving the review without a dashboard is counted', (
    tester,
  ) async {
    final sent = <(String, Map<String, String>)>[];
    final coordinator = await _pump(
      tester,
      extra: [
        analyticsProvider.overrideWithValue(
          Analytics(_RecordingSink(sent), enabled: true),
        ),
      ],
    );
    await tester.tap(find.text('Find my setup'));
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }
    expect(find.text('Create dashboard with 1'), findsOneWidget);
    // Setup starts over while the list is up.
    unawaited(coordinator.startScan());
    await tester.pump();
    final steps = [for (final e in sent) e.$2['step']];
    final at = steps.indexOf('review');
    expect(steps.sublist(at, at + 3), ['review', 'review_left', 'started']);
    final left = sent.firstWhere((e) => e.$2['step'] == 'review_left').$2;
    expect(left['devices'], '1-5');
    expect(left['selected'], '1-5');
  });

  // First-run decision: no "Creating…" or "ready" screens; selecting
  // devices lands directly on the generated dashboard.
  // 2.9.7: where setup stops, a reminder a day later; gone once it works.
  testWidgets('Remind me tomorrow on an empty result schedules one', (
    tester,
  ) async {
    final reminder = _FakeReminder();
    await _pump(tester, scan: (_) => const Stream.empty(), reminder: reminder);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Remind me tomorrow'));
    await tester.pump();
    expect(reminder.scheduled, 1);
    expect(
      find.text("We'll remind you tomorrow, on this phone."),
      findsOneWidget,
    );
    expect(find.text('Remind me tomorrow'), findsNothing);
  });

  testWidgets('notifications off: says so, no reminder', (tester) async {
    await _pump(
      tester,
      scan: (_) => const Stream.empty(),
      reminder: _FakeReminder(allowed: false),
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Remind me tomorrow'));
    await tester.pump();
    expect(find.textContaining('Notifications are off'), findsOneWidget);
  });

  testWidgets('creating the dashboard opens it directly', (tester) async {
    final reminder = _FakeReminder();
    await _pump(tester, reminder: reminder);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Create dashboard with 1'));
    await tester.pumpAndSettle();

    expect(find.text('dashboards of c1'), findsOneWidget);
    expect(find.text('Your dashboard is ready'), findsNothing);
    expect(reminder.cancelled, 1, reason: 'a set-up phone needs no reminder');
  });

  testWidgets('no Zigbee2MQTT: own outcome with base-topic retry and demo', (
    tester,
  ) async {
    final firstRun = _FakeFirstRun();
    final coordinator = await _pump(
      tester,
      reports: [_ok(), _ok()],
      firstRun: firstRun,
      fetchFor: (base) => base == 'z2m'
          ? const Z2mFetchResult(detected: true, devices: [_lamp])
          : const Z2mFetchResult(detected: false, devices: []),
    );
    await tester.tap(find.text('Find my setup'));
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }

    expect(
      find.text("Your broker works, but Zigbee2MQTT isn't publishing here"),
      findsOneWidget,
    );
    expect(find.text('Set up Zigbee2MQTT'), findsOneWidget);
    expect(find.textContaining('SMLIGHT'), findsWidgets);
    // Further down the list, below the new Get help link.
    expect(
      find.text('Try the demo meanwhile', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Still stuck? Get help'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Zigbee2MQTT base topic'),
      'z2m',
    );
    await tester.tap(find.text('Retry'));
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }
    expect(coordinator.state, isA<SetupReview>());
    expect(coordinator.base, 'z2m');
  });

  testWidgets('the demo is offered where setup cannot finish, and opens it', (
    tester,
  ) async {
    final firstRun = _FakeFirstRun();
    await _pump(tester, scan: (_) => const Stream.empty(), firstRun: firstRun);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Try demo'));
    await tester.pumpAndSettle();
    expect(firstRun.demoStarted, 1);
    expect(find.text('dashboards of demo1'), findsOneWidget);
  });

  // 2.9.7: without Zigbee2MQTT there is nothing to scan for, so the
  // welcome screen offers the demo and the hubs page under its own heading;
  // Find my setup stays the one main button.
  group('welcome: no Zigbee2MQTT yet', () {
    late List<(String, Map<String, String>)> sent;
    late List<Override> analytics;
    setUp(() {
      sent = [];
      analytics = [
        analyticsProvider.overrideWithValue(
          Analytics(_RecordingSink(sent), enabled: true),
        ),
      ];
    });
    List<String?> steps() => [
      for (final (name, props) in sent)
        if (name == 'setup_step') props['step'],
    ];

    testWidgets('Find my setup is still the only main button', (tester) async {
      await _pump(tester);
      expect(find.text('No Zigbee2MQTT yet?'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Find my setup'),
        findsOneWidget,
      );
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Try demo'), findsNothing);
    });

    testWidgets('the demo home opens without a scan', (tester) async {
      final firstRun = _FakeFirstRun();
      final coordinator = await _pump(
        tester,
        firstRun: firstRun,
        extra: analytics,
      );
      await tester.tap(find.text('Try the demo home'));
      await tester.pumpAndSettle();
      expect(firstRun.demoStarted, 1);
      expect(find.text('dashboards of demo1'), findsOneWidget);
      expect(coordinator.state, isA<SetupIdle>());
      expect(steps(), ['welcome_demo']);
    });

    testWidgets('which hub to get opens the Hubs page', (tester) async {
      Uri? opened;
      final original = openSetupLink;
      addTearDown(() => openSetupLink = original);
      openSetupLink = (url) async {
        opened = url;
        return true;
      };
      await _pump(tester, extra: analytics);
      await tester.tap(find.text('Which hub to get'));
      await tester.pump();
      expect(opened, hubsPageUrl);
      expect(steps(), ['welcome_hubs']);
    });
  });

  testWidgets('renders in RTL for Hebrew', (tester) async {
    await _pump(tester, locale: const Locale('he'));

    final title = find.text('ברוכים הבאים ל-ZigDash');
    expect(title, findsOneWidget);
    expect(find.text('מצאו את ההתקנה שלי'), findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
  });

  testWidgets('status changes are announced via live regions', (tester) async {
    final controller = StreamController<ProbeResult>();
    addTearDown(controller.close);
    await _pump(tester, scan: (_) => controller.stream);

    await tester.tap(find.text('Find my setup'));
    await tester.pump();

    final node = tester.getSemantics(
      find.bySemanticsLabel('Looking for a connection…'),
    );
    expect(node.flagsCollection.isLiveRegion, isTrue);
  });

  testWidgets('device rows expose selected/disabled state to assistive tech', (
    tester,
  ) async {
    await _pump(
      tester,
      fetch: const Z2mFetchResult(detected: true, devices: [_lamp, _mystery]),
    );
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    // The single broker found is verified without a tap.
    await tester.pump();
    await tester.pump();

    // CheckboxListTile derives its semantics (checked state, label,
    // enabled/disabled) from these properties.
    final lamp = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'lamp'),
    );
    expect(lamp.value, isTrue);
    expect(lamp.onChanged, isNotNull);

    final mystery = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'mystery_box'),
    );
    expect(mystery.value, isFalse);
    expect(mystery.onChanged, isNull); // disabled for screen readers
  });

  group('usage data on the first screen (ADR 0007)', () {
    Future<(SharedPreferences, _SinkSpy)> analyticsOverrides(
      List<Override> out, {
      bool available = true,
    }) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final sink = _SinkSpy();
      out.addAll([
        sharedPreferencesProvider.overrideWithValue(prefs),
        analyticsSinkProvider.overrideWithValue(sink),
        analyticsAvailableProvider.overrideWithValue(available),
      ]);
      return (prefs, sink);
    }

    testWidgets('the box is ticked by default and moving on shares the '
        'setup steps from the first one', (tester) async {
      final extra = <Override>[];
      final (prefs, sink) = await analyticsOverrides(extra);
      await _pump(tester, extra: extra);
      expect(
        find.text('Share anonymous usage data to help improve setup'),
        findsOneWidget,
      );
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isTrue,
      );
      expect(sink.sent, isEmpty, reason: 'nothing before the user moves on');

      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(prefs.getBool('analytics_consent'), isTrue);
      expect(
        sink.sent.map((e) => e['step']),
        containsAllInOrder(['started', 'scan_found', 'review']),
      );
    });

    testWidgets('unticking it is a no, and nothing is sent', (tester) async {
      final extra = <Override>[];
      final (prefs, sink) = await analyticsOverrides(extra);
      await _pump(tester, extra: extra);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      await tester.pump();
      expect(prefs.getBool('analytics_consent'), isFalse);
      expect(sink.sent, isEmpty);
    });

    testWidgets('a build without a key asks nothing', (tester) async {
      final extra = <Override>[];
      await analyticsOverrides(extra, available: false);
      await _pump(tester, extra: extra);
      expect(find.byType(CheckboxListTile), findsNothing);
    });
  });
}

class _FakeReminder implements SetupReminder {
  _FakeReminder({this.allowed = true});
  final bool allowed;
  int scheduled = 0;
  int cancelled = 0;

  @override
  Future<bool> schedule(Locale locale) async {
    scheduled++;
    return allowed;
  }

  @override
  Future<void> cancel() async => cancelled++;

  @override
  Future<bool> openedFromReminder() async => false;
}

class _SinkSpy implements AnalyticsSink {
  bool running = false;
  final sent = <Map<String, String>>[];

  @override
  Future<void> start() async => running = true;

  @override
  Future<void> stop() async {
    running = false;
    sent.clear();
  }

  @override
  void send(String name, Map<String, String> props) {
    if (running) sent.add(props);
  }
}
