import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/storage/secure_storage.dart';
import 'package:zigdash/data/database/daos/connection_dao.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/repositories/connection_repo.dart';
import 'package:zigdash/features/connections/screens/connection_form_screen.dart';
import 'package:zigdash/l10n/app_localizations.dart';

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

List<Override> _overrides(AppDatabase db) => [
      appDatabaseProvider.overrideWithValue(db),
      secureStorageProvider.overrideWithValue(_MemSecure()),
      connectionRepoProvider.overrideWith(
        (ref) => ConnectionRepo(
          ConnectionDao(ref.read(appDatabaseProvider)),
          ref.read(secureStorageProvider),
        ),
      ),
    ];

Widget _wrap(AppDatabase db) => ProviderScope(
      overrides: _overrides(db),
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

void main() {
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
}
