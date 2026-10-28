import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/nfc/nfc_tag_store.dart';
import 'package:zigdash/features/nfc/nfc_tags.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart'
    show sharedPreferencesProvider;
import 'package:zigdash/l10n/app_localizations.dart';

class _FakeBridge extends NfcBridge {
  _FakeBridge(this.nfc);

  final NfcState nfc;
  final writes = <String>[];
  Completer<({NfcWriteOutcome outcome, String? serial})> next = Completer();
  int cancels = 0;

  @override
  Future<NfcState> state() async => nfc;

  @override
  Future<({NfcWriteOutcome outcome, String? serial})> write(String uri) {
    writes.add(uri);
    return next.future;
  }

  @override
  Future<void> cancel() async => cancels++;
}

late SharedPreferences _prefs;

Future<_FakeBridge> _pump(WidgetTester tester, NfcState nfc) async {
  SharedPreferences.setMockInitialValues({});
  _prefs = await SharedPreferences.getInstance();
  final bridge = _FakeBridge(nfc);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        nfcBridgeProvider.overrideWithValue(bridge),
        sharedPreferencesProvider.overrideWithValue(_prefs),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: WriteNfcTagSheet(
            connectionId: 'c1',
            action: NfcTagAction.scene,
            target: 's1',
            label: 'Good night',
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return bridge;
}

void main() {
  group('nfcTagUri', () {
    test('carries the Home, the action, the target and a short label', () {
      final uri = Uri.parse(
        nfcTagUri(
          connectionId: 'c1',
          action: NfcTagAction.toggle,
          target: '0xc4d7fdbbfeba0000',
          label: 'Office light',
        ),
      );
      expect(uri.scheme, 'zigdash');
      expect(uri.host, 'tag');
      expect(uri.queryParameters, {
        'h': 'c1',
        'a': 'toggle',
        't': '0xc4d7fdbbfeba0000',
        'n': 'Office light',
      });
    });

    test('a long label is cut to fit a small tag; Hebrew survives', () {
      final uri = Uri.parse(
        nfcTagUri(
          connectionId: 'c1',
          action: NfcTagAction.scene,
          target: 's1',
          label: 'אור משרד ותריסים בחדר השינה',
        ),
      );
      expect(uri.queryParameters['n']!.characters.length, nfcTagLabelMax);
      expect(uri.queryParameters['n'], startsWith('אור משרד'));
    });

    test('no label, no n', () {
      final uri = Uri.parse(
        nfcTagUri(
          connectionId: 'c1',
          action: NfcTagAction.scene,
          target: 's1',
          label: '',
        ),
      );
      expect(uri.queryParameters.containsKey('n'), isFalse);
    });
  });

  group('the write sheet', () {
    testWidgets('waits for a tag, then says it is ready', (tester) async {
      final bridge = await _pump(tester, NfcState.on);
      expect(bridge.writes, ['zigdash://tag?h=c1&a=scene&t=s1&n=Good+night']);
      expect(find.text('Hold a tag to your phone'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      bridge.next.complete((
        outcome: NfcWriteOutcome.written,
        serial: '04a1b2',
      ));
      await tester.pump();
      expect(find.text('Tag ready'), findsOneWidget);
      expect(find.textContaining('Good night'), findsOneWidget);
      expect(find.byKey(const Key('nfc-again')), findsOneWidget);
      final saved = NfcTagStore(_prefs).all().single;
      expect(saved.serial, '04a1b2');
      expect(saved.label, 'Good night');
      expect(saved.action, NfcTagAction.scene);
    });

    testWidgets('a tag too small says so and offers to try again', (
      tester,
    ) async {
      final bridge = await _pump(tester, NfcState.on);
      bridge.next.complete((outcome: NfcWriteOutcome.tooSmall, serial: null));
      await tester.pump();
      expect(find.textContaining('NTAG213'), findsOneWidget);
      bridge.next = Completer();
      await tester.tap(find.byKey(const Key('nfc-again')));
      await tester.pump();
      expect(bridge.writes, hasLength(2));
    });

    testWidgets('NFC off: no waiting, says how to turn it on', (tester) async {
      final bridge = await _pump(tester, NfcState.off);
      expect(bridge.writes, isEmpty);
      expect(find.text('NFC is off'), findsOneWidget);
    });

    testWidgets('closing stops the phone reading tags', (tester) async {
      final bridge = await _pump(tester, NfcState.on);
      await tester.pumpWidget(const SizedBox());
      expect(bridge.cancels, 1);
    });
  });

  group('the list of tags', () {
    NfcTagRecord tag(String serial, {String home = 'c1'}) => NfcTagRecord(
      serial: serial,
      connectionId: home,
      action: NfcTagAction.toggle,
      target: '0x1',
      label: 'Desk',
      writtenAt: DateTime(2026, 10, 28),
    );

    test('a tag written again keeps one entry, newest first', () async {
      SharedPreferences.setMockInitialValues({});
      final store = NfcTagStore(await SharedPreferences.getInstance());
      await store.written(tag('aa'));
      await store.written(tag('bb'));
      await store.written(tag('aa'));
      expect(store.all().map((t) => t.serial), ['aa', 'bb']);
    });

    test('off, forget, per Home, and the tap Android records', () async {
      SharedPreferences.setMockInitialValues({
        nfcTapKey('aa'): '1793216718889',
      });
      final prefs = await SharedPreferences.getInstance();
      final store = NfcTagStore(prefs);
      await store.written(tag('aa'));
      await store.written(tag('cc', home: 'c2'));
      await store.setOff('aa', true);
      expect(store.ofHome('c1').single.off, isTrue);
      expect(
        store.lastTap('aa'),
        DateTime.fromMillisecondsSinceEpoch(1793216718889),
      );
      expect(store.lastTap('cc'), isNull);
      await store.forget('aa');
      expect(store.ofHome('c1'), isEmpty);
      expect(prefs.getString(nfcTapKey('aa')), isNull);
      expect(store.all().single.serial, 'cc');
    });
  });
}
