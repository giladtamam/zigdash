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
import 'package:zigdash/features/guided_connect/guided_connect_screen.dart';
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

GoRouter _router() => GoRouter(
      initialLocation: Routes.guidedConnect,
      routes: [
        GoRoute(
          path: Routes.guidedConnect,
          builder: (_, __) => const GuidedConnectScreen(),
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
  testWidgets('preset pre-fills host, port and base topic', (tester) async {
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
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_successReport()]);

    await tester.pumpWidget(_wrap(db: db, diagnostics: fake));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Local host'), '');
    await tester.tap(find.text('Test & connect'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsWidgets);
    expect(fake.calls, 0);
  });

  testWidgets('failed ladder shows the failing step, detail and actions',
      (tester) async {
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

  testWidgets('retry re-runs the ladder and can reach success',
      (tester) async {
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

  testWidgets('success saves the connection and shows device names',
      (tester) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_successReport()]);

    await tester.pumpWidget(_wrap(db: db, diagnostics: fake));
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
  });

  testWidgets('zero devices flags the state and offers pairing',
      (tester) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics([_successReport(count: 0)]);
    final stubManager = _StubManager();
    final overrides = <Override>[
      mqttManagerProvider.overrideWith(
        (ref, id) async => stubManager,
      ),
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
    expect(find.text('Pairing is enabled. Press the pairing button on your device to join it.'), findsOneWidget);
  });
}
