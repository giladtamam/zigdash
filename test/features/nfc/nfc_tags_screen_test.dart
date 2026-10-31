import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/nfc/nfc_tag_store.dart';
import 'package:zigdash/features/nfc/nfc_tags.dart';
import 'package:zigdash/features/nfc/nfc_tags_screen.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'package:zigdash/l10n/app_localizations.dart';

Future<SharedPreferences> _pump(
  WidgetTester tester,
  Map<String, Object> values,
) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NfcTagsScreen(connectionId: 'c1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return prefs;
}

final _tag = NfcTagRecord(
  serial: 'aa',
  connectionId: 'c1',
  action: NfcTagAction.toggle,
  target: '0x1',
  label: 'Office light',
  writtenAt: DateTime(2026, 10, 28, 22, 40),
);

void main() {
  testWidgets('no tags: says how to make one', (tester) async {
    await _pump(tester, {});
    expect(find.byKey(const Key('nfc-tags-empty')), findsOneWidget);
  });

  testWidgets(
    'a tag: what it does, never tapped, and the switch turns it off',
    (tester) async {
      final prefs = await _pump(tester, {
        nfcTagsKey: jsonEncode([_tag.toJson()]),
      });
      expect(find.text('Office light'), findsOneWidget);
      expect(find.textContaining('Switches on and off'), findsOneWidget);
      expect(find.textContaining('not tapped yet'), findsOneWidget);
      await tester.tap(find.byKey(const Key('nfc-tag-on-aa')));
      await tester.pumpAndSettle();
      expect(NfcTagStore(prefs).all().single.off, isTrue);
      expect(find.textContaining('Off ·'), findsOneWidget);
    },
  );

  testWidgets("another Home's tags aren't listed", (tester) async {
    final other = NfcTagRecord(
      serial: 'bb',
      connectionId: 'c2',
      action: NfcTagAction.scene,
      target: 's1',
      label: 'Good night',
      writtenAt: DateTime(2026, 10, 28),
    );
    await _pump(tester, {
      nfcTagsKey: jsonEncode([other.toJson()]),
    });
    expect(find.text('Good night'), findsNothing);
    expect(find.byKey(const Key('nfc-tags-empty')), findsOneWidget);
  });
}
