import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/data/repositories/backup_files.dart';
import 'package:zigdash/data/repositories/backup_service.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/data/repositories/dashboard_repo.dart';
import 'package:zigdash/features/dashboards/screens/dashboards_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/mqtt/mqtt_status.dart';
import 'package:zigdash/mqtt/providers/mqtt_manager_provider.dart';

/// Backup to and from a .json file (asked for in a Play review), through a
/// fake file picker.
class _FakeFiles implements BackupFiles {
  final saved = <String, String>{};
  String? toOpen;
  bool unreadable = false;

  @override
  Future<bool> save(String fileName, String json) async {
    saved[fileName] = json;
    return true;
  }

  @override
  Future<String?> open() async {
    if (unreadable) throw const FormatException('not UTF-8');
    return toOpen;
  }
}

class _FakeBackup implements BackupService {
  String? imported;

  @override
  Future<String> exportConnection(String connectionId) async =>
      '{"format":3,"dashboards":[]}';

  @override
  Future<int> importToConnection(String connectionId, String raw) async {
    imported = raw;
    return 2;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _home = Connection(
  id: 'c1',
  name: 'My Flat',
  host: 'h',
  port: 1883,
  protocol: MqttProtocol.tcp,
  keepAliveSeconds: 60,
  autoConnect: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Future<void> _pump(WidgetTester tester, _FakeFiles files, _FakeBackup backup) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      connectionByIdProvider.overrideWith((ref, id) async => _home),
      connectionsStreamProvider.overrideWith((ref) => Stream.value([_home])),
      dashboardsForConnectionProvider.overrideWith((ref, id) => Stream.value([])),
      connectionStatusProvider
          .overrideWith((ref, id) => Stream.value(MqttStatus.connected)),
      backupFilesProvider.overrideWithValue(files),
      backupServiceProvider.overrideWithValue(backup),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DashboardsScreen(connectionId: 'c1'),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _menu(WidgetTester tester, String item) async {
  await tester.tap(find.byType(PopupMenuButton<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}

void main() {
  test('backup file names are file-safe and dated', () {
    expect(backupFileName('My Flat', DateTime(2026, 10, 6)),
        'zigdash-my-flat-2026-10-06.json');
    expect(backupFileName('בית', DateTime(2026, 1, 2)),
        'zigdash-home-2026-01-02.json');
  });

  testWidgets('export saves the backup as a .json file', (tester) async {
    final files = _FakeFiles();
    await _pump(tester, files, _FakeBackup());
    await _menu(tester, 'Export dashboards');

    await tester.tap(find.text('Save file'));
    await tester.pumpAndSettle();

    expect(files.saved.keys.single, startsWith('zigdash-my-flat-'));
    expect(files.saved.values.single, '{"format":3,"dashboards":[]}');
    expect(find.text('Backup saved'), findsOneWidget);
  });

  testWidgets('import reads a chosen .json file', (tester) async {
    final files = _FakeFiles()..toOpen = '{"format":3,"dashboards":[]}';
    final backup = _FakeBackup();
    await _pump(tester, files, backup);
    await _menu(tester, 'Import dashboards');

    await tester.tap(find.text('Choose file'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(backup.imported, '{"format":3,"dashboards":[]}');
    expect(find.text('Imported 2 dashboards'), findsOneWidget);
  });

  testWidgets('an unreadable file says so and imports nothing', (tester) async {
    final files = _FakeFiles()..unreadable = true;
    final backup = _FakeBackup();
    await _pump(tester, files, backup);
    await _menu(tester, 'Import dashboards');

    await tester.tap(find.text('Choose file'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't read that file"), findsOneWidget);
    expect(backup.imported, isNull);
  });
}
