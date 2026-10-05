import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/onboarding/first_run.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/connections/discovery/broker_probe.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/onboarding/setup/recommendation_policy.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/onboarding/setup/setup_providers.dart';
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
  _FakeDiagnostics(this.reports);
  final List<DiagnosticsReport> reports;

  @override
  Future<DiagnosticsReport> run({
    required BrokerConfig config,
    required String password,
    String base = 'zigbee2mqtt',
  }) async =>
      reports.removeAt(0);
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
            detailKey: 'diagAuthRejected'),
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
    String dashboardName = 'Home',
    int dashboardColor = 0,
    int dashboardIcon = 0,
    required List<ReviewRow> selected,
    List<ReviewRow> notSelected = const [],
  }) async =>
      SetupResult(
          connectionId: 'c1', dashboardId: 'd1', panelCount: selected.length);
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

/// Pumps the setup screen with a coordinator built on fakes.
Future<SetupCoordinator> _pump(
  WidgetTester tester, {
  List<DiagnosticsReport>? reports,
  Stream<ProbeResult> Function(String ip)? scan,
  Z2mFetchResult fetch =
      const Z2mFetchResult(detected: true, devices: [_lamp]),
  Z2mFetchResult Function(String base)? fetchFor,
  Locale? locale,
  _FakeFirstRun? firstRun,
  List<Override> extra = const [],
}) async {
  final coordinator = SetupCoordinator(
    scan: scan ??
        (ip) => Stream.fromIterable(
            [const ProbeResult(host: '192.168.1.10', port: 1883)]),
    deviceIp: () async => '192.168.1.5',
    diagnostics: _FakeDiagnostics(reports ?? [_ok()]),
    fetchDevices: (config, password, base) async =>
        fetchFor?.call(base) ?? fetch,
    creator: _FakeStore(),
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
              builder: (_, __) => const Text('manual entry'),
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
  testWidgets('welcome offers Find my setup and manual entry', (tester) async {
    await _pump(tester);
    expect(find.text('Find my setup'), findsOneWidget);
    expect(find.text('Enter details manually'), findsOneWidget);
  });

  testWidgets('scanning shows progressive candidates; tapping one verifies',
      (tester) async {
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

  testWidgets('no candidates shows tailored guidance and actions',
      (tester) async {
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

  testWidgets('anonymous rejection prompts for credentials, preserving host',
      (tester) async {
    await _pump(tester, reports: [_authFail(), _ok()]);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    // The single broker found is verified without a tap.
    await tester.pump();
    await tester.pump();

    expect(find.text('This broker needs a login'), findsOneWidget);
    expect(find.textContaining('192.168.1.10'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Username (optional)').first, 'user');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password (optional)').first, 'secret');
    await tester.tap(find.text('Enter login'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Your devices'), findsNothing); // subtitle, not title
    expect(find.textContaining('devices found'), findsOneWidget);
  });

  testWidgets('rejected credentials show the rejected explanation',
      (tester) async {
    await _pump(tester, reports: [_authFail(), _authFail(), _ok()]);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    // The single broker found is verified without a tap.
    await tester.pump();
    await tester.pump();
    await tester.enterText(
        find.widgetWithText(TextField, 'Username (optional)').first, 'user');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password (optional)').first, 'wrong');
    await tester.tap(find.text('Enter login'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('rejected'), findsWidgets);
  });

  testWidgets('review groups devices, preselects recommended, counts selection',
      (tester) async {
    await _pump(tester,
        fetch: const Z2mFetchResult(
            detected: true, devices: [_lamp, _batterySensor, _mystery]));
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
  });

  // First-run decision: no "Creating…" or "ready" screens; selecting
  // devices lands directly on the generated dashboard.
  testWidgets('creating the dashboard opens it directly', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Create dashboard with 1'));
    await tester.pumpAndSettle();

    expect(find.text('dashboards of c1'), findsOneWidget);
    expect(find.text('Your dashboard is ready'), findsNothing);
  });

  testWidgets('no Zigbee2MQTT: own outcome with base-topic retry and demo',
      (tester) async {
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

    expect(find.text("Your broker works, but Zigbee2MQTT isn't publishing here"),
        findsOneWidget);
    expect(find.text('Set up Zigbee2MQTT'), findsOneWidget);
    expect(find.textContaining('SMLIGHT'), findsWidgets);
    expect(find.text('Try the demo meanwhile'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Zigbee2MQTT base topic'), 'z2m');
    await tester.tap(find.text('Retry'));
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }
    expect(coordinator.state, isA<SetupReview>());
    expect(coordinator.base, 'z2m');
  });

  testWidgets('the demo is offered where setup cannot finish, and opens it',
      (tester) async {
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

  testWidgets('the welcome screen does not offer the demo', (tester) async {
    await _pump(tester);
    expect(find.text('Try demo'), findsNothing);
  });

  testWidgets('renders in RTL for Hebrew', (tester) async {
    await _pump(tester, locale: const Locale('he'));

    final title = find.text('ברוכים הבאים ל-ZigDash');
    expect(title, findsOneWidget);
    expect(find.text('מצאו את ההתקנה שלי'), findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
  });

  testWidgets('status changes are announced via live regions',
      (tester) async {
    final controller = StreamController<ProbeResult>();
    addTearDown(controller.close);
    await _pump(tester, scan: (_) => controller.stream);

    await tester.tap(find.text('Find my setup'));
    await tester.pump();

    final node =
        tester.getSemantics(find.bySemanticsLabel('Looking for a connection…'));
    expect(node.flagsCollection.isLiveRegion, isTrue);
  });

  testWidgets('device rows expose selected/disabled state to assistive tech',
      (tester) async {
    await _pump(tester,
        fetch: const Z2mFetchResult(
            detected: true, devices: [_lamp, _mystery]));
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    // The single broker found is verified without a tap.
    await tester.pump();
    await tester.pump();

    // CheckboxListTile derives its semantics (checked state, label,
    // enabled/disabled) from these properties.
    final lamp = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'lamp'));
    expect(lamp.value, isTrue);
    expect(lamp.onChanged, isNotNull);

    final mystery = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'mystery_box'));
    expect(mystery.value, isFalse);
    expect(mystery.onChanged, isNull); // disabled for screen readers
  });

  group('usage data consent on the first screen (ADR 0006)', () {
    Future<(SharedPreferences, _SinkSpy)> analyticsOverrides(
        List<Override> out, {bool available = true}) async {
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

    testWidgets('an unticked box is a no, and nothing is sent',
        (tester) async {
      final extra = <Override>[];
      final (prefs, sink) = await analyticsOverrides(extra);
      await _pump(tester, extra: extra);
      expect(find.text('Share anonymous usage data to help improve setup'),
          findsOneWidget);
      expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isFalse);

      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      await tester.pump();
      expect(prefs.getBool('analytics_consent'), isFalse);
      expect(sink.sent, isEmpty);
    });

    testWidgets('ticking it shares the setup steps from the first one',
        (tester) async {
      final extra = <Override>[];
      final (prefs, sink) = await analyticsOverrides(extra);
      await _pump(tester, extra: extra);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.text('Find my setup'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(prefs.getBool('analytics_consent'), isTrue);
      expect(sink.sent.map((e) => e['step']),
          containsAllInOrder(['started', 'scan_found', 'review']));
    });

    testWidgets('a build without a key asks nothing', (tester) async {
      final extra = <Override>[];
      await analyticsOverrides(extra, available: false);
      await _pump(tester, extra: extra);
      expect(find.byType(CheckboxListTile), findsNothing);
    });
  });
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
