import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/features/onboarding/first_run.dart';
import 'package:zigdash/core/storage/secure_storage.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics_provider.dart';
import 'package:zigdash/features/connections/discovery/z2m_frontend.dart';
import 'package:zigdash/features/connections/screens/connection_form_screen.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';

// ---------------------------------------------------------------------------
// In-memory SecureStore stub (avoids platform-channel calls in tests).
// ---------------------------------------------------------------------------

class _MemSecure implements SecureStore {
  final _m = <String, String>{};

  @override
  Future<void> writePassword(String id, String pw) async => _m[id] = pw;

  @override
  Future<String?> readPassword(String id) async => _m[id];

  @override
  Future<void> deletePassword(String id) async => _m.remove(id);
}

// ---------------------------------------------------------------------------
// Helper — builds the complete override tree so we never touch platform channels.
// ---------------------------------------------------------------------------

/// Replays a canned ladder report so the form's Test connection button can be
/// exercised without a broker.
class _FakeDiagnostics extends ConnectDiagnostics {
  _FakeDiagnostics(this.report);

  final DiagnosticsReport report;

  @override
  Future<DiagnosticsReport> run({
    required BrokerConfig config,
    required String password,
    String base = 'zigbee2mqtt',
  }) async => report;
}

/// Records each run; answers with [report], or waits for [answer] when
/// one is given (3.8.6).
class _RecordingDiagnostics extends ConnectDiagnostics {
  _RecordingDiagnostics(this.report, {this.answer});

  final DiagnosticsReport report;
  final Completer<DiagnosticsReport>? answer;
  final runs = <({BrokerConfig config, String base})>[];

  @override
  Future<DiagnosticsReport> run({
    required BrokerConfig config,
    required String password,
    String base = 'zigbee2mqtt',
  }) {
    runs.add((config: config, base: base));
    return answer?.future ?? Future.value(report);
  }
}

DiagnosticsReport _connected(int devices) => DiagnosticsReport(
  steps: const [
    StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
    StepResult(step: DiagnosticStep.tcp, status: StepStatus.pass),
    StepResult(step: DiagnosticStep.connack, status: StepStatus.pass),
    StepResult(step: DiagnosticStep.auth, status: StepStatus.pass),
  ],
  connected: true,
  candidatesTried: 1,
  deviceNames: [for (var i = 0; i < devices; i++) 'd$i'],
);

const _refused = DiagnosticsReport(
  steps: [
    StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
    StepResult(
      step: DiagnosticStep.tcp,
      status: StepStatus.fail,
      detailKey: 'diagTcpFail',
    ),
  ],
  connected: false,
  candidatesTried: 1,
);

/// Zigbee2MQTT's page settings, as the form asks for them (3.8.6).
class _FakePageConfig {
  _FakePageConfig({this.mqtt, this.answer, this.locked = false});
  final Map<String, dynamic>? mqtt;
  final Completer<Map<String, dynamic>?>? answer;
  final bool locked;
  final calls = <(String, int, String?)>[];

  Future<Map<String, dynamic>?> call(String host, int port, {String? token}) {
    calls.add((host, port, token));
    if (locked) return Future.error(const Z2mPageLocked());
    return answer?.future ?? Future.value(mqtt);
  }
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

List<Override> _overrides(
  AppDatabase db, {
  ConnectDiagnostics? diagnostics,
  List<Override> extra = const [],
  SecureStore? secure,
}) => [
  ...extra,
  appDatabaseProvider.overrideWithValue(db),
  secureStorageProvider.overrideWithValue(secure ?? _MemSecure()),
  connectionRepoProvider.overrideWith(
    (ref) => ConnectionRepo(
      ConnectionDao(ref.read(appDatabaseProvider)),
      ref.read(secureStorageProvider),
    ),
  ),
  if (diagnostics != null)
    connectDiagnosticsProvider.overrideWithValue(diagnostics),
];

Widget _wrap(
  AppDatabase db, {
  ConnectDiagnostics? diagnostics,
  List<Override> extra = const [],
}) => ProviderScope(
  overrides: _overrides(db, diagnostics: diagnostics, extra: extra),
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    // Navigator wrapping so context.pop() inside the form doesn't crash.
    home: const ConnectionFormScreen(),
  ),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

class _RecordingFirstRun implements FirstRun {
  final finished = <String>[];
  @override
  Future<void> finish(String connectionId) async => finished.add(connectionId);
  @override
  Future<String> startDemo() async => 'demo';
}

void main() {
  // First-run decision: completing real setup deletes the demo connection.
  // Saving a new home through this form counts as real setup too.
  testWidgets('saving a new home finishes first run with it', (tester) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final firstRun = _RecordingFirstRun();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Text('list')),
        GoRoute(
          path: '/form',
          builder: (_, __) => const ConnectionFormScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(db),
          firstRunProvider.overrideWithValue(firstRun),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.push('/form');
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Home');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Local host'),
      '192.168.1.20',
    );
    await tester.tap(find.text('Save'));
    // The save writes to a real (in-memory) database, which only completes
    // on the real clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();

    final saved = await tester.runAsync(
      () => ConnectionDao(db).watchAll().first,
    );
    expect(firstRun.finished, [saved!.single.id]);
    expect(find.text('list'), findsOneWidget, reason: 'the form closed');
  });

  testWidgets('new form renders Name, Local host, Port and Test connection', (
    tester,
  ) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    // Core form fields
    expect(find.text('Name'), findsWidgets);
    expect(find.text('Local host'), findsWidgets);
    expect(find.text('Port'), findsWidgets);

    // The "Test connection" button (l10n key connTestButton)
    expect(find.text('Test connection'), findsOneWidget);
  });

  testWidgets('save with empty Name and Host shows Required errors', (
    tester,
  ) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    // Clear Port so it is valid (it has a default of 1883).
    // Name and Host are empty by default — tap Save.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // l10n key fieldRequired → "Required"
    // Both Name and Host fail validation, so we get at least two "Required" errors.
    expect(find.text('Required'), findsWidgets);
  });

  testWidgets('Test connection shows the diagnostic ladder sheet', (
    tester,
  ) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics(
      const DiagnosticsReport(
        steps: [
          StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
          StepResult(
            step: DiagnosticStep.connack,
            status: StepStatus.fail,
            detailKey: 'diagConnackFail',
          ),
        ],
        connected: false,
        candidatesTried: 1,
      ),
    );

    await tester.pumpWidget(_wrap(db, diagnostics: fake));
    await tester.pumpAndSettle();

    // Name and Host are empty by default — the form validates before running.
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Z2M');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Local host'),
      'localhost',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();

    // The ladder sheet replaces the old binary snackbar.
    expect(find.text('MQTT handshake'), findsOneWidget);
    expect(
      find.textContaining("didn't complete the MQTT handshake"),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  // 3.8.5: the form's Test is counted like the guided one, with from: form,
  // and an untrusted certificate says so instead of "no answer".
  testWidgets('Test connection counts manual_test from the form', (
    tester,
  ) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final sent = <(String, Map<String, String>)>[];
    final fake = _FakeDiagnostics(
      const DiagnosticsReport(
        steps: [
          StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
          StepResult(step: DiagnosticStep.tcp, status: StepStatus.pass),
          StepResult(
            step: DiagnosticStep.connack,
            status: StepStatus.fail,
            detailKey: 'diagTlsUntrusted',
          ),
        ],
        connected: false,
        candidatesTried: 1,
      ),
    );
    await tester.pumpWidget(
      _wrap(
        db,
        diagnostics: fake,
        extra: [
          analyticsProvider.overrideWithValue(
            Analytics(_RecordingSink(sent), enabled: true),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Z2M');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Local host'),
      '192.168.1.30',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Port'), '8883');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();

    expect(find.textContaining('self-signed, expired'), findsOneWidget);
    expect(sent.single.$1, 'setup_step');
    expect(sent.single.$2, {
      'step': 'manual_test',
      'result': 'tls_untrusted',
      'port': '8883',
      'from': 'form',
    });
  });

  // 2.10: a home connected through Home Assistant shows where, not broker
  // fields, and saving the form keeps how it connects.
  testWidgets('a Home Assistant home: address read-only, transport kept', (
    tester,
  ) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now();
    await ConnectionDao(db).insertRow(
      ConnectionsCompanion.insert(
        id: 'ha1',
        name: 'Casa',
        host: 'https://abc.ui.nabu.casa',
        port: 443,
        protocol: MqttProtocol.wss,
        transport: const Value(ConnectionTransport.homeAssistant),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Text('list')),
        GoRoute(
          path: '/form',
          builder: (_, __) => const ConnectionFormScreen(connectionId: 'ha1'),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(db),
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.push('/form');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connected through Home Assistant'), findsOneWidget);
    expect(find.text('https://abc.ui.nabu.casa'), findsOneWidget);
    expect(find.text('Local host'), findsNothing);
    expect(find.text('Test connection'), findsNothing);
    expect(find.text('Sign in again'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Casa 2',
    );
    await tester.tap(find.text('Save'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    final saved = await tester.runAsync(() => ConnectionDao(db).getById('ha1'));
    expect(saved!.name, 'Casa 2');
    expect(saved.host, 'https://abc.ui.nabu.casa');
    expect(saved.transport, ConnectionTransport.homeAssistant);
  });

  // ---------------------------------------------------------------------
  // 3.8.6: a page Home's broker (broker-no-devices-386.md)
  // ---------------------------------------------------------------------

  Future<void> addPageHome(
    AppDatabase db,
    _MemSecure secure, {
    String? base,
    String? remoteHost,
  }) async {
    final now = DateTime.now();
    await ConnectionDao(db).insertRow(
      ConnectionsCompanion.insert(
        id: 'p1',
        name: 'Hub',
        host: '192.168.1.64',
        port: 8080,
        protocol: MqttProtocol.ws,
        transport: const Value(ConnectionTransport.z2mPage),
        z2mBaseTopic: Value(base),
        remoteHost: Value(remoteHost),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await secure.writePassword('p1', 'page-token');
  }

  /// Opens the form on the page Home 'p1'; returns the provider container.
  Future<ProviderContainer> openPageForm(
    WidgetTester tester,
    AppDatabase db,
    _MemSecure secure, {
    required ConnectDiagnostics diagnostics,
    required _FakePageConfig page,
    List<(String, Map<String, String>)>? sent,
    List<Override> extra = const [],
    void Function(ProviderContainer)? beforeOpen,
  }) async {
    // Tall enough that Test connection is built below the page note.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Text('list')),
        GoRoute(
          path: '/form',
          builder: (_, __) => const ConnectionFormScreen(connectionId: 'p1'),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(
          db,
          diagnostics: diagnostics,
          secure: secure,
          extra: [
            ...extra,
            z2mPageConfigProvider.overrideWithValue(page.call),
            if (sent != null)
              analyticsProvider.overrideWithValue(
                Analytics(_RecordingSink(sent), enabled: true),
              ),
          ],
        ),
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.text('list')),
    );
    beforeOpen?.call(container);
    router.push('/form');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await tester.pump();
    return container;
  }

  String fieldText(WidgetTester tester, String label) => tester
      .widget<TextFormField>(find.widgetWithText(TextFormField, label))
      .controller!
      .text;

  Future<ConnectionTransport> transportOfP1(
    WidgetTester tester,
    AppDatabase db,
  ) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    final row = await tester.runAsync(() => ConnectionDao(db).getById('p1'));
    return row!.transport!;
  }

  List<Map<String, String>> pageBroker(
    List<(String, Map<String, String>)> sent,
  ) => [
    for (final (name, props) in sent)
      if (name == 'page_broker') props,
  ];

  group('formBaseTopic', () {
    test('stored, then dashboard prefix, then the page, then default', () {
      expect(
        formBaseTopic(
          stored: 'mine',
          firstDashboardPrefix: 'dash',
          pageBase: 'page',
        ),
        'mine',
      );
      expect(
        formBaseTopic(firstDashboardPrefix: 'dash', pageBase: 'page'),
        'dash',
      );
      expect(
        formBaseTopic(stored: ' ', firstDashboardPrefix: '', pageBase: 'page'),
        'page',
      );
      expect(formBaseTopic(), 'zigbee2mqtt');
    });
  });

  testWidgets('page Home: Test passes the resolved base', (tester) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final secure = _MemSecure();
    await tester.runAsync(() => addPageHome(db, secure, base: 'myz2m'));
    final diag = _RecordingDiagnostics(_connected(3));
    await openPageForm(
      tester,
      db,
      secure,
      diagnostics: diag,
      page: _FakePageConfig(),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();
    expect(diag.runs.single.base, 'myz2m');
  });

  testWidgets('page Home: the page base topic counts when none is set', (
    tester,
  ) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final secure = _MemSecure();
    await tester.runAsync(() => addPageHome(db, secure));
    final diag = _RecordingDiagnostics(_connected(3));
    final page = _FakePageConfig(
      mqtt: {'server': 'mqtt://localhost:1883', 'base_topic': 'house'},
    );
    await openPageForm(tester, db, secure, diagnostics: diag, page: page);
    await tester.pumpAndSettle();
    // The page was asked on its own port, with its token.
    expect(page.calls.single, ('192.168.1.64', 8080, 'page-token'));
    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();
    expect(diag.runs.single.base, 'house');
  });

  group('page Home prefill', () {
    testWidgets('a broker elsewhere fills host, port, TCP and the user', (
      tester,
    ) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      await tester.runAsync(() => addPageHome(db, secure));
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_connected(3)),
        page: _FakePageConfig(
          mqtt: {'server': 'mqtt://192.168.1.5:1883', 'user': 'z2m'},
        ),
      );
      await tester.pumpAndSettle();
      expect(fieldText(tester, 'Local host'), '192.168.1.5');
      expect(fieldText(tester, 'Port'), '1883');
      expect(fieldText(tester, 'Username (optional)'), 'z2m');
      expect(find.text('Zigbee2MQTT uses mqtt://192.168.1.5:1883'), findsOne);
    });

    testWidgets('mqtts:// fills port 8883 with TLS', (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      await tester.runAsync(() => addPageHome(db, secure));
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_connected(3)),
        page: _FakePageConfig(mqtt: {'server': 'mqtts://192.168.1.5'}),
      );
      await tester.pumpAndSettle();
      expect(fieldText(tester, 'Port'), '8883');
      // The dropdown shows the TLS choice.
      expect(
        tester
            .widget<DropdownButtonFormField<MqttProtocol>>(
              find.byType(DropdownButtonFormField<MqttProtocol>),
            )
            .initialValue,
        MqttProtocol.tcpSsl,
      );
    });

    testWidgets('mqtt://localhost keeps the page host', (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      await tester.runAsync(() => addPageHome(db, secure));
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_connected(3)),
        page: _FakePageConfig(mqtt: {'server': 'mqtt://localhost'}),
      );
      await tester.pumpAndSettle();
      expect(fieldText(tester, 'Local host'), '192.168.1.64');
      expect(fieldText(tester, 'Port'), '1883');
    });

    testWidgets("a locked page or no answer keeps today's pre-fill", (
      tester,
    ) async {
      for (final page in [_FakePageConfig(locked: true), _FakePageConfig()]) {
        final db = AppDatabase.test(NativeDatabase.memory());
        final secure = _MemSecure();
        await tester.runAsync(() => addPageHome(db, secure));
        await openPageForm(
          tester,
          db,
          secure,
          diagnostics: _RecordingDiagnostics(_connected(3)),
          page: page,
        );
        await tester.pumpAndSettle();
        expect(fieldText(tester, 'Local host'), '192.168.1.64');
        expect(fieldText(tester, 'Port'), '1883');
        expect(find.textContaining('Zigbee2MQTT uses'), findsNothing);
        expect(find.text("Reading Zigbee2MQTT's settings…"), findsNothing);
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(db.close);
      }
    });

    testWidgets('fields changed before the answer are kept', (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      await tester.runAsync(() => addPageHome(db, secure));
      final answer = Completer<Map<String, dynamic>?>();
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_connected(3)),
        page: _FakePageConfig(answer: answer),
      );
      expect(find.text("Reading Zigbee2MQTT's settings…"), findsOne);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Local host'),
        '10.0.0.9',
      );
      // The protocol dropdown: WebSocket.
      await tester.tap(find.byType(DropdownButtonFormField<MqttProtocol>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('WebSocket').last);
      await tester.pumpAndSettle();
      final portAfterPick = fieldText(tester, 'Port');
      answer.complete({'server': 'mqtts://192.168.1.5:8884', 'user': 'z2m'});
      await tester.pumpAndSettle();
      expect(fieldText(tester, 'Local host'), '10.0.0.9');
      expect(fieldText(tester, 'Port'), portAfterPick);
      expect(
        tester
            .widget<DropdownButtonFormField<MqttProtocol>>(
              find.byType(DropdownButtonFormField<MqttProtocol>),
            )
            .initialValue,
        MqttProtocol.ws,
      );
      // The username was not touched: filled.
      expect(fieldText(tester, 'Username (optional)'), 'z2m');
    });

    testWidgets('a manager still loading is not awaited: the page is asked', (
      tester,
    ) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      await tester.runAsync(() => addPageHome(db, secure));
      final page = _FakePageConfig(mqtt: {'server': 'mqtt://192.168.1.5'});
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_connected(3)),
        page: page,
        extra: [
          mqttManagerProvider.overrideWith(
            (ref, id) => Completer<MqttManager>().future,
          ),
        ],
        beforeOpen: (c) => c.read(mqttManagerProvider('p1')),
      );
      await tester.pumpAndSettle();
      expect(page.calls, hasLength(1));
      expect(fieldText(tester, 'Local host'), '192.168.1.5');
    });
  });

  testWidgets('page Home: Test connected with 0 devices warns, no tick', (
    tester,
  ) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final secure = _MemSecure();
    await tester.runAsync(() => addPageHome(db, secure));
    await openPageForm(
      tester,
      db,
      secure,
      diagnostics: _RecordingDiagnostics(_connected(0)),
      page: _FakePageConfig(mqtt: {'server': 'mqtt://localhost:1883'}),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('conn-no-devices')), findsOne);
    expect(
      find.textContaining('this broker has none of your devices'),
      findsOne,
    );
    expect(find.text('Connection successful'), findsNothing);
    expect(find.text('Close'), findsOne);
    expect(find.text('Retry'), findsOne);
  });

  group('page Home Save guard', () {
    Future<void> fill(WidgetTester tester) async {
      await tester.pumpAndSettle();
    }

    testWidgets('0 devices: dialog, page kept, kept_page', (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      final sent = <(String, Map<String, String>)>[];
      await tester.runAsync(
        () => addPageHome(db, secure, remoteHost: 'far.example.com'),
      );
      final diag = _RecordingDiagnostics(_connected(0));
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: diag,
        page: _FakePageConfig(),
        sent: sent,
      );
      await fill(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Keep using the Zigbee2MQTT page?'), findsOne);
      expect(find.textContaining('none of your devices'), findsOne);
      // The local candidate only, and no manual_test.
      expect(diag.runs.single.config.remoteHost, isNull);
      expect(diag.runs.single.config.relay, isNull);
      expect(sent.where((e) => e.$1 == 'setup_step'), isEmpty);
      await tester.tap(find.text('Keep the Zigbee2MQTT page'));
      await tester.pumpAndSettle();
      expect(find.text('Keep using the Zigbee2MQTT page?'), findsNothing);
      expect(find.text('Test connection'), findsOne, reason: 'form open');
      expect(await transportOfP1(tester, db), ConnectionTransport.z2mPage);
      expect(pageBroker(sent), [
        {'result': 'kept_page', 'answered': 'yes', 'devices': '0'},
      ]);
    });

    testWidgets('Save anyway switches to the broker', (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      final sent = <(String, Map<String, String>)>[];
      await tester.runAsync(() => addPageHome(db, secure));
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_connected(0)),
        page: _FakePageConfig(),
        sent: sent,
      );
      await fill(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save anyway'));
      await tester.pump();
      expect(await transportOfP1(tester, db), ConnectionTransport.mqtt);
      expect(pageBroker(sent), [
        {'result': 'saved_anyway', 'answered': 'yes', 'devices': '0'},
      ]);
    });

    testWidgets('devices found: saved with no dialog', (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      final sent = <(String, Map<String, String>)>[];
      await tester.runAsync(() => addPageHome(db, secure));
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_connected(8)),
        page: _FakePageConfig(),
        sent: sent,
      );
      await fill(tester);
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Keep using the Zigbee2MQTT page?'), findsNothing);
      expect(await transportOfP1(tester, db), ConnectionTransport.mqtt);
      expect(pageBroker(sent), [
        {'result': 'saved', 'answered': 'yes', 'devices': '6-20'},
      ]);
      expect(sent.where((e) => e.$1 == 'setup_step'), isEmpty);
    });

    testWidgets('not connected: the no-answer dialog with the reason', (
      tester,
    ) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      final sent = <(String, Map<String, String>)>[];
      await tester.runAsync(() => addPageHome(db, secure));
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_refused),
        page: _FakePageConfig(),
        sent: sent,
      );
      await fill(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.textContaining("The broker didn't answer"), findsOne);
      await tester.tap(find.text('Keep the Zigbee2MQTT page'));
      await tester.pumpAndSettle();
      expect(await transportOfP1(tester, db), ConnectionTransport.z2mPage);
      expect(pageBroker(sent), [
        {'result': 'kept_page', 'answered': 'no'},
      ]);
    });

    testWidgets('Cancel: nothing saved, even when the answer comes later', (
      tester,
    ) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      final sent = <(String, Map<String, String>)>[];
      await tester.runAsync(() => addPageHome(db, secure));
      final answer = Completer<DiagnosticsReport>();
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_connected(5), answer: answer),
        page: _FakePageConfig(),
        sent: sent,
      );
      await fill(tester);
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Checking the broker…'), findsOne);
      await tester.tap(find.byKey(const Key('conn-guard-cancel')));
      await tester.pump();
      expect(find.text('Checking the broker…'), findsNothing);
      expect(find.text('Save'), findsOne);
      // The broker answers after Cancel: ignored.
      answer.complete(_connected(5));
      await tester.pumpAndSettle();
      expect(find.text('Keep using the Zigbee2MQTT page?'), findsNothing);
      expect(await transportOfP1(tester, db), ConnectionTransport.z2mPage);
      expect(pageBroker(sent), [
        {'result': 'cancelled'},
      ]);
    });

    testWidgets('a check slower than 15 s: the no-answer dialog', (
      tester,
    ) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);
      final secure = _MemSecure();
      final sent = <(String, Map<String, String>)>[];
      await tester.runAsync(() => addPageHome(db, secure));
      final answer = Completer<DiagnosticsReport>();
      await openPageForm(
        tester,
        db,
        secure,
        diagnostics: _RecordingDiagnostics(_connected(5), answer: answer),
        page: _FakePageConfig(),
        sent: sent,
      );
      await fill(tester);
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 14));
      expect(find.text('Keep using the Zigbee2MQTT page?'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining("The broker didn't answer"), findsOne);
      // A late answer changes nothing.
      answer.complete(_connected(5));
      await tester.tap(find.text('Keep the Zigbee2MQTT page'));
      await tester.pumpAndSettle();
      expect(await transportOfP1(tester, db), ConnectionTransport.z2mPage);
      expect(pageBroker(sent), [
        {'result': 'kept_page', 'answered': 'timeout'},
      ]);
    });
  });
}
