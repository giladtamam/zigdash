import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  }) async =>
      SetupResult(
          connectionId: 'c1', dashboardId: 'd1', panelCount: selected.length);
}

/// Pumps the setup screen with a coordinator built on fakes.
Future<SetupCoordinator> _pump(
  WidgetTester tester, {
  List<DiagnosticsReport>? reports,
  Stream<ProbeResult> Function(String ip)? scan,
  Z2mFetchResult fetch =
      const Z2mFetchResult(detected: true, devices: [_lamp]),
}) async {
  final coordinator = SetupCoordinator(
    scan: scan ??
        (ip) => Stream.fromIterable(
            [const ProbeResult(host: '192.168.1.10', port: 1883)]),
    deviceIp: () async => '192.168.1.5',
    diagnostics: _FakeDiagnostics(reports ?? [_ok()]),
    fetchDevices: (config, password, base) async => fetch,
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
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SetupScreen(),
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
    await tester.tap(find.text('Possible connection found'));
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
    await tester.tap(find.text('Possible connection found'));
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
    await tester.tap(find.text('Possible connection found'));
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

  testWidgets('create completes with the ready screen', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Find my setup'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Possible connection found'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Create dashboard with 1'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Your dashboard is ready'), findsOneWidget);
    expect(find.text('1 controls created.'), findsOneWidget);
    expect(find.text('Open dashboard'), findsOneWidget);
  });
}
