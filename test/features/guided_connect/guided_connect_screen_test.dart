import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/core/router/routes.dart';
import 'package:zigdash/core/storage/secure_storage.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics_provider.dart';
import 'package:zigdash/features/connections/discovery/broker_scan_providers.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/features/guided_connect/guided_connect_screen.dart';
import 'package:zigdash/features/onboarding/first_run.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart' show Z2mFetchResult;
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

class _MemSecure implements SecureStore {
  final _m = <String, String>{};

  @override
  Future<void> writePassword(String id, String pw) async => _m[id] = pw;

  @override
  Future<String?> readPassword(String id) async => _m[id];

  @override
  Future<void> deletePassword(String id) async => _m.remove(id);
}

/// Fake diagnostics that replays a queue of reports (last one repeats).
class _FakeDiagnostics extends ConnectDiagnostics {
  _FakeDiagnostics(this.results);

  final List<DiagnosticsReport> results;
  int calls = 0;

  @override
  Future<DiagnosticsReport> run({
    required BrokerConfig config,
    required String password,
    String base = 'zigbee2mqtt',
  }) async {
    final i = calls < results.length ? calls : results.length - 1;
    calls++;
    return results[i];
  }
}

class _StubManager extends MqttManager {
  _StubManager()
    : super(
        config: const BrokerConfig(
          id: 'x',
          host: 'h',
          port: 1883,
          protocol: MqttProtocol.tcp,
        ),
        password: '',
      );

  final publishedTopics = <String>[];

  @override
  void publish(
    String topic,
    String template,
    Object value, {
    mc.MqttQos qos = mc.MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    publishedTopics.add(topic);
  }
}

DiagnosticsReport _failedReport() => const DiagnosticsReport(
  steps: [
    StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
    StepResult(step: DiagnosticStep.tcp, status: StepStatus.pass),
    StepResult(
      step: DiagnosticStep.connack,
      status: StepStatus.fail,
      detailKey: 'diagConnackFail',
    ),
  ],
  connected: false,
  candidatesTried: 1,
);

/// The two devices behind [_successReport], as Zigbee2MQTT publishes them
/// on `bridge/devices`, parsed by the app's own parser.
final _devicesOverride = discoveredDevicesProvider.overrideWith(
  (ref, args) async => parseBridgeDevices(
    jsonEncode([
      for (final (name, ieee) in [('office_light', '0x01'), ('lamp', '0x02')])
        {
          'friendly_name': name,
          'ieee_address': ieee,
          'type': 'Router',
          'supported': true,
          'definition': {
            'model': 'LED1545G12',
            'vendor': 'IKEA',
            'exposes': [
              {
                'type': 'light',
                'features': [
                  {
                    'type': 'binary',
                    'name': 'state',
                    'property': 'state',
                    'access': 7,
                    'value_on': 'ON',
                    'value_off': 'OFF',
                  },
                ],
              },
            ],
          },
        },
    ]),
  ),
);

DiagnosticsReport _successReport({int count = 2}) => DiagnosticsReport(
  steps: [
    for (final s in DiagnosticStep.values)
      StepResult(
        step: s,
        status: StepStatus.pass,
        deviceCount: s == DiagnosticStep.devices ? count : null,
      ),
  ],
  connected: true,
  candidatesTried: 1,
  deviceNames: count > 0 ? ['office_light', 'lamp'] : const [],
);

class _RecordingFirstRun implements FirstRun {
  final finished = <String>[];
  @override
  Future<void> finish(String connectionId) async => finished.add(connectionId);
  @override
  Future<String> startDemo() async => 'demo';
}

var _firstRun = _RecordingFirstRun();

/// The form grew in 2.5 (hints, Get help); a tall view keeps every control
/// built and tappable.
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

GoRouter _router() => GoRouter(
  initialLocation: Routes.guidedConnect,
  routes: [
    GoRoute(
      path: Routes.guidedConnect,
      // The ladder tests run against a filled-in host (2.5: the form
      // itself starts empty; see 'starts empty, with hints').
      builder: (_, __) => const GuidedConnectScreen(initialHost: 'localhost'),
    ),
    GoRoute(
      path: '/connections/:id/dashboards',
      builder: (_, __) => const Scaffold(body: Text('STUB_DASHBOARDS')),
    ),
  ],
);

Widget _wrap({
  required AppDatabase db,
  required ConnectDiagnostics diagnostics,
  Map<dynamic, dynamic> extraOverrides = const {},
}) {
  final overrides = <Override>[
    appDatabaseProvider.overrideWithValue(db),
    secureStorageProvider.overrideWithValue(_MemSecure()),
    connectionRepoProvider.overrideWith(
      (ref) => ConnectionRepo(
        ConnectionDao(ref.read(appDatabaseProvider)),
        ref.read(secureStorageProvider),
      ),
    ),
    connectDiagnosticsProvider.overrideWithValue(diagnostics),
    firstRunProvider.overrideWithValue(_firstRun),
    deviceIpProvider.overrideWith((ref) async => '192.168.1.37'),
    // Zigbee2MQTT there with nothing paired, unless a test says otherwise.
    guidedZ2mCheckProvider.overrideWithValue(
      (_, __, ___) async => const Z2mFetchResult(detected: true, devices: []),
    ),
    guidedPageDevicesProvider.overrideWithValue((_) async => null),
    ...extraOverrides.values,
  ];
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: _router(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  setUp(() => _firstRun = _RecordingFirstRun());

  // 2.5: an empty host, with where to find it, instead of "localhost".
  testWidgets('starts empty, with hints on where the address is', (
    tester,
  ) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          deviceIpProvider.overrideWith((ref) async => '192.168.1.37'),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GuidedConnectScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('localhost'), findsNothing);
    expect(
      find.text(
        'Your phone is 192.168.1.37, so the hub usually starts with 192.168.1.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Using Home Assistant? The host'), findsOneWidget);
    expect(find.text('Still stuck? Get help'), findsOneWidget);

    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);
  });

  testWidgets('a hub the scan found arrives filled in', (tester) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GuidedConnectScreen(
            initialHost: '192.168.1.20',
            initialPort: 1883,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('192.168.1.20'), findsOneWidget);
    expect(find.text('1883'), findsOneWidget);
  });

  testWidgets('preset pre-fills host, port and base topic', (tester) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_successReport()]);

    await tester.pumpWidget(_wrap(db: db, diagnostics: fake));
    await tester.pumpAndSettle();

    expect(find.text('localhost'), findsOneWidget);
    expect(find.text('1883'), findsOneWidget);
    // Value and hint both read "zigbee2mqtt" — accept either.
    expect(find.text('zigbee2mqtt'), findsWidgets);
    expect(find.text('Test & connect'), findsOneWidget);
    expect(fake.calls, 0);
  });

  testWidgets('empty host blocks the run and shows validation', (tester) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_successReport()]);

    await tester.pumpWidget(_wrap(db: db, diagnostics: fake));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Local host'),
      '',
    );
    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsWidgets);
    expect(fake.calls, 0);
  });

  testWidgets('failed ladder shows the failing step, detail and actions', (
    tester,
  ) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_failedReport()]);

    await tester.pumpWidget(_wrap(db: db, diagnostics: fake));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();

    expect(find.text('MQTT handshake'), findsOneWidget);
    expect(
      find.textContaining("didn't complete the MQTT handshake"),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Edit settings'), findsOneWidget);

    // Back to the form keeps the entered values.
    await tester.tap(find.text('Edit settings'));
    await tester.pumpAndSettle();
    expect(find.text('localhost'), findsOneWidget);
  });

  testWidgets('after two failed checks a person is offered (2.9.2)', (
    tester,
  ) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_failedReport(), _failedReport()]);

    await tester.pumpWidget(_wrap(db: db, diagnostics: fake));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();
    expect(find.text('Stuck? Ask a person'), findsNothing, reason: 'one try');

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Stuck? Ask a person'), findsOneWidget);
    expect(find.text('Ask in Telegram'), findsOneWidget);
    expect(find.text('Tips and email'), findsOneWidget);
  });

  testWidgets('retry re-runs the ladder and can reach success', (tester) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_failedReport(), _successReport()]);

    await tester.pumpWidget(_wrap(db: db, diagnostics: fake));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();
    expect(find.text('MQTT handshake'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Found 2 devices'), findsOneWidget);
    expect(fake.calls, 2);
  });

  testWidgets('success saves the connection and shows device names', (
    tester,
  ) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_successReport()]);

    await tester.pumpWidget(
      _wrap(
        db: db,
        diagnostics: fake,
        extraOverrides: {'devices': _devicesOverride},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();

    expect(find.text('Found 2 devices'), findsOneWidget);
    expect(find.text('office_light'), findsOneWidget);
    expect(find.text('lamp'), findsOneWidget);
    expect(find.text('Continue to dashboard'), findsOneWidget);

    // Continue navigates to the saved connection's dashboards (proving the
    // auto-save persisted a row the router can resolve).
    await tester.tap(find.text('Continue to dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('STUB_DASHBOARDS'), findsOneWidget);
    // Manual entry also finishes first run with the saved home.
    expect(_firstRun.finished, hasLength(1));

    // …and builds the first dashboard from the devices, as setup does,
    // instead of opening an empty home.
    final dashboards = await db.select(db.dashboards).get();
    expect(dashboards, hasLength(1));
    final tiles = await db.select(db.panels).get();
    expect(tiles, hasLength(2));
    // Unmount here so drift's stream-close timer runs inside the test.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('continue still opens the home when devices cannot be read', (
    tester,
  ) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_successReport()]);

    await tester.pumpWidget(
      _wrap(
        db: db,
        diagnostics: fake,
        extraOverrides: {
          'devices': discoveredDevicesProvider.overrideWith(
            (ref, args) async => throw StateError('offline'),
          ),
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('STUB_DASHBOARDS'), findsOneWidget);
    expect(await db.select(db.dashboards).get(), isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('zero devices flags the state and offers pairing', (
    tester,
  ) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_successReport(count: 0)]);
    final stubManager = _StubManager();
    final overrides = <Override>[
      mqttManagerProvider.overrideWith((ref, id) async => stubManager),
      connectionStatusProvider.overrideWith(
        (ref, id) => Stream.value(MqttStatus.connected),
      ),
    ];

    await tester.pumpWidget(
      _wrap(
        db: db,
        diagnostics: fake,
        extraOverrides: {'mgr': overrides[0], 'status': overrides[1]},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();

    expect(find.text('Connected — no devices found yet'), findsOneWidget);
    expect(find.text('Start pairing'), findsOneWidget);

    await tester.tap(find.text('Start pairing'));
    await tester.pumpAndSettle();

    expect(
      stubManager.publishedTopics,
      contains('zigbee2mqtt/bridge/request/permit_join'),
    );
    expect(
      find.text(
        'Pairing is enabled. Press the pairing button on your device to join it.',
      ),
      findsOneWidget,
    );
  });

  // 3.2.1: an empty broker is checked for Zigbee2MQTT before a home is saved.
  Future<AppDatabase> runEmpty(
    WidgetTester tester, {
    required Future<Z2mFetchResult> Function(BrokerConfig, String, String) check,
    Future<List<Z2mDevice>?> Function(String)? page,
  }) async {
    _tall(tester);
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      _wrap(
        db: db,
        diagnostics: _FakeDiagnostics([_successReport(count: 0)]),
        extraOverrides: {
          'check': guidedZ2mCheckProvider.overrideWithValue(check),
          if (page != null) 'page': guidedPageDevicesProvider.overrideWithValue(page),
          'devices': _devicesOverride,
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();
    return db;
  }

  testWidgets('no Zigbee2MQTT on the broker: says so and saves no home', (
    tester,
  ) async {
    final db = await runEmpty(
      tester,
      check: (_, __, ___) async => const Z2mFetchResult(detected: false, devices: []),
    );
    expect(find.byKey(const Key('guided-empty-broker')), findsOneWidget);
    expect(find.text('No Zigbee2MQTT here'), findsOneWidget);
    expect(find.textContaining('ZHA'), findsOneWidget);
    expect(await db.select(db.connections).get(), isEmpty);
    expect(_firstRun.finished, isEmpty);
  });

  testWidgets('Zigbee2MQTT under another base topic is checked again with it', (
    tester,
  ) async {
    final bases = <String>[];
    final db = await runEmpty(
      tester,
      check: (_, __, base) async {
        bases.add(base);
        return base == 'z2m'
            ? const Z2mFetchResult(detected: true, devices: [])
            : const Z2mFetchResult(detected: false, devices: [], otherBases: ['z2m']);
      },
    );
    expect(bases, ['zigbee2mqtt', 'z2m']);
    expect(find.text('Connected — no devices found yet'), findsOneWidget);
    final homes = await db.select(db.connections).get();
    expect(homes.single.z2mBaseTopic, 'z2m');
  });

  testWidgets('device list missing: says so when the page has none either', (
    tester,
  ) async {
    final db = await runEmpty(
      tester,
      check: (_, __, ___) async =>
          const Z2mFetchResult(detected: true, devices: [], devicesMissing: true),
    );
    expect(find.text("Zigbee2MQTT didn't send its device list"), findsOneWidget);
    expect(await db.select(db.connections).get(), isEmpty);
  });

  testWidgets('device list missing: the page has it, so the home is made', (
    tester,
  ) async {
    final db = await runEmpty(
      tester,
      check: (_, __, ___) async =>
          const Z2mFetchResult(detected: true, devices: [], devicesMissing: true),
      page: (_) async => parseBridgeDevices(
        jsonEncode([
          {'friendly_name': 'lamp', 'ieee_address': '0x02', 'type': 'Router', 'supported': true},
        ]),
      ),
    );
    expect(find.text('Found 1 device'), findsOneWidget);
    expect(find.text('lamp'), findsOneWidget);
    expect(await db.select(db.connections).get(), hasLength(1));
  });
}
