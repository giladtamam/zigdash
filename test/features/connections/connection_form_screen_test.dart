import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zigdash/features/onboarding/first_run.dart';
import 'package:zigdash/core/storage/secure_storage.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics_provider.dart';
import 'package:zigdash/features/connections/screens/connection_form_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';
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
  }) async =>
      report;
}

List<Override> _overrides(AppDatabase db, {ConnectDiagnostics? diagnostics}) => [
      appDatabaseProvider.overrideWithValue(db),
      secureStorageProvider.overrideWithValue(_MemSecure()),
      connectionRepoProvider.overrideWith(
        (ref) => ConnectionRepo(
          ConnectionDao(ref.read(appDatabaseProvider)),
          ref.read(secureStorageProvider),
        ),
      ),
      if (diagnostics != null)
        connectDiagnosticsProvider.overrideWithValue(diagnostics),
    ];

Widget _wrap(AppDatabase db, {ConnectDiagnostics? diagnostics}) => ProviderScope(
      overrides: _overrides(db, diagnostics: diagnostics),
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
    await tester.pumpWidget(ProviderScope(
      overrides: [
        ..._overrides(db),
        firstRunProvider.overrideWithValue(firstRun),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ));
    router.push('/form');
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Home');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Local host'), '192.168.1.20');
    await tester.tap(find.text('Save'));
    // The save writes to a real (in-memory) database, which only completes
    // on the real clock.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();

    final saved = await tester.runAsync(
        () => ConnectionDao(db).watchAll().first);
    expect(firstRun.finished, [saved!.single.id]);
    expect(find.text('list'), findsOneWidget, reason: 'the form closed');
  });

  testWidgets('new form renders Name, Local host, Port and Test connection',
      (tester) async {
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

  testWidgets('save with empty Name and Host shows Required errors',
      (tester) async {
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

  testWidgets('Test connection shows the diagnostic ladder sheet',
      (tester) async {
    final db = AppDatabase.test(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeDiagnostics(const DiagnosticsReport(
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
    ));

    await tester.pumpWidget(_wrap(db, diagnostics: fake));
    await tester.pumpAndSettle();

    // Name and Host are empty by default — the form validates before running.
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Z2M');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Local host'), 'localhost');
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
}
