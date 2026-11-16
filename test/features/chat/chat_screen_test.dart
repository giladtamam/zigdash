import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/core/analytics/analytics.dart';
import 'package:zigdash/engine/engine_providers.dart';
import 'package:zigdash/engine/engine_status.dart';
import 'package:zigdash/features/chat/chat_api.dart';
import 'package:zigdash/features/chat/chat_linker.dart';
import 'package:zigdash/features/chat/chat_hub.dart' show ChatAuditEntry;
import 'package:zigdash/features/chat/chat_screen.dart';
import 'package:zigdash/features/chat/chat_store.dart';
import 'package:zigdash/features/devices/device_registry.dart';
import 'package:zigdash/features/devices/devices_providers.dart';
import 'package:zigdash/features/discovery/providers/discovery_provider.dart';
import 'package:zigdash/features/pro/pro.dart';
import 'package:zigdash/features/settings/providers/settings_controller.dart';
import 'package:zigdash/l10n/app_localizations.dart';
import 'package:zigdash/remote/founder.dart';
import 'package:zigdash/remote/remote_setup.dart';

import 'chat_controls_test.dart' as fx;
import 'chat_fakes.dart';

class _Sink implements AnalyticsSink {
  final sent = <String>[];
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void send(String name, Map<String, String> props) => sent.add('$name $props');
}

final _now = DateTime(2026, 11, 16, 12);

/// The Home's Chat row, changed by a test as a late founder status would.
final _row = StateProvider<ChatRowState>((ref) => ChatRowState.ready);
final _end = DateTime(2027, 2, 14, 12);

class _Page {
  _Page(this.sink, this.api, this.hub, this.store, this.launched, this.log, [this.refreshed = const []]);
  /// Founder status asks of the relay.
  final List<String> refreshed;
  final _Sink sink;
  final FakeChatApi api;
  final FakeChatHub hub;
  final MemoryChatStore store;
  final List<Uri> launched;
  final List<String> log;
}

final _devices = [
  fx.dev('Hall light', '0x01', fx.light),
  fx.dev('Office shutter', '0x03', fx.cover),
  fx.dev('Shutter 2', '0x04', fx.cover),
  fx.dev('Kettle plug', '0x05', fx.plug),
  fx.dev('Bedroom thermostat', '0x07', fx.thermostat),
  fx.dev('Front lock', '0x08', fx.lock),
  fx.dev('Water main', '0x09', fx.valveSwitch, description: 'Zigbee water valve'),
  fx.dev('Siren', '0x0a', fx.siren),
  fx.dev('Garagentor', '0x0c', fx.cover),
];

EngineView _engine(String version) => EngineView(
      phase: HubEnginePhase.running,
      report: EngineReport(
          version: version, runningOn: 'hub', rulesLoaded: 0, rulesUnknown: const [], stoppedSelf: false, at: null),
    );

Future<_Page> _open(
  WidgetTester tester, {
  ChatRowState state = ChatRowState.ready,
  bool atHome = true,
  String engine = '3.7.0',
  List<ChatLinkInfo> listed = const [],
  ChatFail? ticketFails,
  Widget? child,
  _Page? reuse,
  FounderStatus? founder,
  ProStatus pro = ProStatus.locked,
}) async {
  tester.view.physicalSize = const Size(1080, 6000);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'analytics_consent': true});
  final p = await SharedPreferences.getInstance();
  final log = reuse?.log ?? <String>[];
  final api = reuse?.api ?? (FakeChatApi(log)
    ..listed = [...listed]
    ..ticketFails = ticketFails);
  final hub = reuse?.hub ?? FakeChatHub(log);
  final store = reuse?.store ?? MemoryChatStore();
  final launched = reuse?.launched ?? <Uri>[];
  final sink = reuse?.sink ?? _Sink();
  final refreshed = <String>[];
  final router = GoRouter(
    initialLocation: '/chat',
    routes: [
      GoRoute(path: '/chat', builder: (_, _) => child ?? const ChatScreen(connectionId: 'c1')),
      GoRoute(path: '/settings/home/:id/remote', builder: (_, _) => const Text('remote page')),
      GoRoute(path: '/settings/home/:id/chat', builder: (_, _) => const Text('chat page')),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      analyticsAvailableProvider.overrideWithValue(true),
      analyticsSinkProvider.overrideWithValue(sink),
      _row.overrideWith((ref) => state),
      chatRowStateProvider.overrideWith((ref, _) => ref.watch(_row)),
      founderStatusProvider.overrideWith((ref, _) async => founder),
      founderRefreshProvider.overrideWithValue((id) async => refreshed.add(id)),
      founderNowProvider.overrideWithValue(() => _now),
      proStatusProvider.overrideWithValue(pro),
      proPurchaseProvider.overrideWithValue(() {}),
      atHomeProvider.overrideWith((ref, _) => atHome),
      engineViewProvider.overrideWith((ref, _) => Stream.value(_engine(engine))),
      homeBaseTopicProvider.overrideWith((ref, _) => 'zigbee2mqtt'),
      bridgeDevicesStreamProvider.overrideWith((ref, _) => Stream.value(_devices)),
      linkedIeeesProvider.overrideWith((ref, _) => Stream.value({'0x01', '0x03', '0x04', '0x05', '0x07', '0x08', '0x0c'})),
      // Shutter 2 sits on the "Garage" dashboard.
      chatTileTagsProvider.overrideWith((ref, _) => Stream.value({
            '0x04': ['Shutter 2', 'Garage'],
          })),
      chatLinkerProvider.overrideWithValue(ChatLinker(api, hub, store, (_) async => relayLogin)),
      chatLaunchProvider.overrideWithValue((uri) async {
        launched.add(uri);
        return true;
      }),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  ));
  await tester.pumpAndSettle();
  return _Page(sink, api, hub, store, launched, log, refreshed);
}

/// The Chat screen opened again later, with the same service, hub and phone.
Future<_Page> _reopen(WidgetTester tester, _Page page) => _open(tester, reuse: page);

bool _on(WidgetTester tester, String ieee) =>
    tester.widget<SwitchListTile>(find.byKey(Key('chat-control-$ieee'))).value;

Future<void> _code(WidgetTester tester, String code) async {
  await tester.enterText(find.byKey(const Key('chat-code')), code);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  _auditLines();
  testWidgets('the intro says what it does, never does, costs and who reads it; Read is pre-selected', (tester) async {
    final page = await _open(tester);
    expect(find.text('Talk to your home from Telegram'), findsOneWidget);
    expect(find.textContaining('never opens, closes or changes locks, valves or sirens'), findsOneWidget);
    expect(find.textContaining('300 messages a month'), findsOneWidget);
    expect(find.textContaining('Telegram, which carries them; our server in the EU'), findsOneWidget);
    expect(find.textContaining('Anthropic (Claude)'), findsOneWidget);
    expect(find.byKey(const Key('chat-age')), findsOneWidget);
    expect(find.textContaining('must be 16 or older'), findsOneWidget);
    expect(find.textContaining('Anyone using a linked Telegram account'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('chat-policy')));
    expect(page.launched.single.fragment, 'zigdash-chat-beta');
    // Read: no control list.
    expect(tester.widget<RadioGroup<String>>(find.byType(RadioGroup<String>)).groupValue, 'read');
    expect(find.byKey(const Key('chat-control-0x01')), findsNothing);
    expect(find.byKey(const Key('chat-links-none')), findsOneWidget);
    expect(page.sink.sent, ['chat_link {step: intro}']);
  });

  testWidgets('the control list: lights and covers on tiles on, gates, plugs and thermostats off, locks valves sirens never',
      (tester) async {
    await _open(tester);
    await _tap(tester, find.byKey(const Key('chat-scope-control')));
    expect(_on(tester, '0x01'), isTrue, reason: 'light on a tile');
    expect(_on(tester, '0x03'), isTrue, reason: 'cover on a tile');
    expect(_on(tester, '0x04'), isFalse, reason: 'on the Garage dashboard');
    expect(_on(tester, '0x0c'), isFalse, reason: 'Garagentor');
    expect(_on(tester, '0x05'), isFalse, reason: 'plug');
    expect(_on(tester, '0x07'), isFalse, reason: 'thermostat');
    for (final never in ['0x08', '0x09', '0x0a']) {
      expect(find.byKey(Key('chat-control-$never')), findsNothing);
    }
    expect(find.text('Front lock'), findsNothing);
    expect(find.text('Water main'), findsNothing);
  });

  testWidgets('linking at home: the hub client, Telegram with the code, the back-code, then the list', (tester) async {
    final page = await _open(tester);
    await _tap(tester, find.byKey(const Key('chat-scope-control')));
    // The kettle is turned on by hand, the office shutter off.
    await _tap(tester, find.byKey(const Key('chat-control-0x05')));
    await _tap(tester, find.byKey(const Key('chat-control-0x03')));
    await _tap(tester, find.byKey(const Key('chat-link')));

    final id = page.hub.configs.keys.single;
    expect(page.hub.configs[id]!['scope'], 'control');
    expect(page.hub.configs[id]!['controls'], ['0x01', '0x05']);
    expect(page.launched.single.toString(), 'https://t.me/ZigDashHomeBot?start=LK7Q2F9');
    expect(find.byKey(const Key('chat-finish')), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('chat-confirm'))).onPressed, isNull);

    await _code(tester, '1111');
    await _tap(tester, find.byKey(const Key('chat-confirm')));
    expect(find.text("That isn't the code the bot sent. Tries left: 2."), findsOneWidget);
    expect(page.sink.sent.last, 'chat_link {step: failed, why: wrong_code}');

    await _code(tester, '4821');
    await _tap(tester, find.byKey(const Key('chat-confirm')));
    expect(find.byKey(const Key('chat-finish')), findsNothing);
    expect(find.byKey(Key('chat-link-$id')), findsOneWidget);
    expect(find.text('Dana'), findsOneWidget);
    expect(find.text('Read and control · not used yet'), findsOneWidget);
    expect(find.text('Link another Telegram account'), findsOneWidget);
    expect(page.sink.sent, contains('chat_link {step: linked}'));
    expect((await page.store.read('c1')).clients.single.confirmed, isTrue);
    // The linked client stays on the hub.
    expect(page.hub.configs.keys, [id]);
  });

  testWidgets('away: the button says to link at home, and nothing is asked', (tester) async {
    final page = await _open(tester, atHome: false);
    final button = tester.widget<FilledButton>(find.byKey(const Key('chat-link')));
    expect(button.onPressed, isNull);
    expect(find.text('Link at home: ZigDash sets this up on your hub over your home network.'), findsOneWidget);
    expect(page.log, ['ticket', 'links']);
  });

  testWidgets('an Engine without Chat: it updates itself first', (tester) async {
    await _open(tester, engine: '3.6.2');
    expect(find.byKey(const Key('chat-engine-old')), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('chat-link'))).onPressed, isNull);
  });

  testWidgets('linked accounts that do not load say why: the relay login is not the internet', (tester) async {
    await _open(tester, ticketFails: ChatFail.login);
    final failed = find.byKey(const Key('chat-links-failed'));
    expect(find.descendant(of: failed, matching: find.textContaining("didn't accept this phone's remote login")), findsOneWidget);
    await _open(tester, ticketFails: ChatFail.unreachable);
    expect(find.descendant(of: failed, matching: find.textContaining('Check the internet connection')), findsOneWidget);
  });

  test('a phone that never heard the Engine asks the hub before saying it is missing', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    Future<ChatRowState> row(HubEnginePhase phase) async {
      final box = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(p),
        chatOfferedProvider.overrideWithValue(true),
        remoteFitsProvider.overrideWith((ref, _) => true),
        proStatusProvider.overrideWithValue(ProStatus.unlocked),
        remoteHomeProvider.overrideWith((ref, _) async => relayLogin),
        engineViewProvider.overrideWith((ref, _) => Stream.value(EngineView(phase: phase))),
      ]);
      addTearDown(box.dispose);
      box.listen(chatRowStateProvider('c1'), (_, _) {});
      await box.read(remoteHomeProvider('c1').future);
      await box.read(engineViewProvider('c1').future);
      return box.read(chatRowStateProvider('c1'));
    }

    expect(await row(HubEnginePhase.running), ChatRowState.ready);
    expect(await row(HubEnginePhase.notInstalled), ChatRowState.noEngine);
  });

  test("the row from a founder's status: running is ready, ended is manage-only, deleted leads to Remote", () async {
    SharedPreferences.setMockInitialValues({'engine.installed.c1': true});
    final p = await SharedPreferences.getInstance();
    Future<ChatRowState> row(FounderStatus status, {ProStatus pro = ProStatus.unavailable}) async {
      final box = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(p),
        chatOfferedProvider.overrideWithValue(true),
        remoteFitsProvider.overrideWith((ref, _) => true),
        // By default Play billing isn't available on this phone.
        proStatusProvider.overrideWithValue(pro),
        remoteHomeProvider.overrideWith((ref, _) async => relayLogin),
        founderStatusProvider.overrideWith((ref, _) async => status),
        founderNowProvider.overrideWithValue(() => _now),
      ]);
      addTearDown(box.dispose);
      box.listen(chatRowStateProvider('c1'), (_, _) {});
      await box.read(remoteHomeProvider('c1').future);
      await box.read(founderStatusProvider('c1').future);
      return box.read(chatRowStateProvider('c1'));
    }

    FounderStatus pass({bool ended = false, bool deleted = false}) =>
        FounderStatus(kind: 'founder', expiresAt: _end, ended: ended, deleted: deleted, fetchedAt: _now);
    expect(await row(pass()), ChatRowState.ready);
    expect(await row(pass(ended: true)), ChatRowState.passEnded);
    // Deleted: no Chat to manage; with Pro, the row leads to the Remote
    // page (which says the Home was removed); without, to Pro.
    expect(await row(pass(ended: true, deleted: true), pro: ProStatus.unlocked), ChatRowState.noRemote);
    expect(await row(pass(ended: true, deleted: true), pro: ProStatus.locked), ChatRowState.noPro);
    expect(await row(pass(ended: true, deleted: true)), ChatRowState.hidden);
  });

  testWidgets('cancel while waiting takes the hub client back', (tester) async {
    final page = await _open(tester);
    await _tap(tester, find.byKey(const Key('chat-link')));
    expect(page.hub.configs, hasLength(1));
    await _tap(tester, find.byKey(const Key('chat-cancel')));
    expect(page.hub.configs, isEmpty);
    expect(find.byKey(const Key('chat-link')), findsOneWidget);
  });

  testWidgets('family: each person listed with their own scope; Remove goes to the service, then the hub',
      (tester) async {
    final page = await _open(tester, listed: [
      ChatLinkInfo(clientId: 'tg-aaaaaa', telegramName: 'Dana', scope: 'control', lastUsed: DateTime(2026, 11, 14, 18, 5)),
      const ChatLinkInfo(clientId: 'tg-bbbbbb', telegramName: 'Noa', scope: 'read'),
    ]);
    expect(find.text('Dana'), findsOneWidget);
    expect(find.text('Noa'), findsOneWidget);
    expect(find.text('Read and control · last used Nov 14 18:05'), findsOneWidget);
    expect(find.text('Read · not used yet'), findsOneWidget);
    expect(find.text('Link another Telegram account'), findsOneWidget);
    // The hub has Noa's client (linked from another phone of this Home).
    page.hub.configs['tg-bbbbbb'] = {'v': 1};

    await _tap(tester, find.byKey(const Key('chat-remove-tg-bbbbbb')));
    expect(find.text('Remove Noa?'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('chat-remove-ok')));
    expect(page.log.skip(2), ['ticket tg-bbbbbb', 'service unlink tg-bbbbbb', 'hub revoke tg-bbbbbb']);
    expect(find.text('Noa'), findsNothing);
    expect(find.text('Dana'), findsOneWidget);
    expect(page.hub.configs, isEmpty);
    expect(page.sink.sent.last, 'chat_link {step: removed}');
  });

  testWidgets('back from Telegram (an /unlink there): the list is read again', (tester) async {
    final page = await _open(tester, listed: [
      const ChatLinkInfo(clientId: 'tg-bbbbbb', telegramName: 'Noa', scope: 'read'),
    ]);
    expect(find.text('Noa'), findsOneWidget);
    page.api.listed = [];
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Noa'), findsNothing);
  });

  testWidgets('removed while away: the hub forgets it at home', (tester) async {
    final page = await _open(tester, atHome: false, listed: [
      const ChatLinkInfo(clientId: 'tg-bbbbbb', telegramName: 'Noa', scope: 'read'),
    ]);
    page.hub.atHome = false;
    await _tap(tester, find.byKey(const Key('chat-remove-tg-bbbbbb')));
    await _tap(tester, find.byKey(const Key('chat-remove-ok')));
    expect(find.text('Removed. Your hub forgets it the next time ZigDash is open at home.'), findsOneWidget);
    expect((await page.store.read('c1')).revokeOnHub, {'tg-bbbbbb'});
  });

  testWidgets('What Chat did, from the hub', (tester) async {
    final page = await _open(tester);
    await _tap(tester, find.byKey(const Key('chat-link')));
    await _code(tester, '4821');
    await _tap(tester, find.byKey(const Key('chat-confirm')));
    final id = page.hub.configs.keys.single;
    page.hub.audits = [];
    await _tap(tester, find.descendant(of: find.byKey(const Key('chat-audit')), matching: find.byType(TextButton)));
    expect(page.log.last, 'audit $id');
    expect(find.text('Nothing yet.'), findsOneWidget);
    page.hub.audits = null;
    await _tap(tester, find.descendant(of: find.byKey(const Key('chat-audit')), matching: find.byType(TextButton)));
    expect(find.byKey(const Key('chat-audit-failed')), findsOneWidget);
  });

  testWidgets('not claimed yet or try again: never a wrong code, and the same link waits', (tester) async {
    final page = await _open(tester);
    page.api.linkUrl = Uri.parse('https://t.me/ZigDashHomeDevBot?start=LK7Q2F9');
    await _tap(tester, find.byKey(const Key('chat-link')));
    // The service's own t.me link is the one opened.
    expect(page.launched.single.host, 't.me');
    expect(page.launched.single.path, '/ZigDashHomeDevBot');
    page.api.confirmFails.addAll([
      const ChatException(ChatFail.notClaimed),
      const ChatException(ChatFail.unreachable),
    ]);
    await _code(tester, '4821');
    await _tap(tester, find.byKey(const Key('chat-confirm')));
    expect(find.textContaining("The bot hasn't got the code yet"), findsOneWidget);
    expect(find.textContaining("isn't the code"), findsNothing);
    expect(find.byKey(const Key('chat-finish')), findsOneWidget);
    await _tap(tester, find.byKey(const Key('chat-confirm')));
    expect(find.textContaining("Couldn't reach ZigDash's servers"), findsOneWidget);
    expect(find.byKey(const Key('chat-finish')), findsOneWidget);
    // The same code works again.
    await _tap(tester, find.byKey(const Key('chat-confirm')));
    expect(find.byKey(const Key('chat-finish')), findsNothing);
    expect(find.text('Dana'), findsOneWidget);
    expect(page.hub.configs, hasLength(1));
  });

  testWidgets('a client unlinked from the chat (/unlink) is deleted on the hub at home and forgotten', (tester) async {
    final page = await _open(tester);
    await _tap(tester, find.byKey(const Key('chat-link')));
    await _code(tester, '4821');
    await _tap(tester, find.byKey(const Key('chat-confirm')));
    final id = page.hub.configs.keys.single;
    // /unlink in Telegram: the service forgets it; the app opens again.
    page.api.listed = [];
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    final again = await _reopen(tester, page);
    expect(again.log.last, 'hub revoke $id');
    expect(again.hub.configs, isEmpty);
    expect((await again.store.read('c1')).clients, isEmpty);
    expect(find.byKey(const Key('chat-links-none')), findsOneWidget);
  });

  testWidgets('a Home that is not ready says why, and remote off leads to Remote control', (tester) async {
    await _open(tester, state: ChatRowState.noRemote);
    expect(find.text('Turn on remote control first'), findsOneWidget);
    expect(find.byKey(const Key('chat-link')), findsNothing);
    await _tap(tester, find.byKey(const Key('chat-not-ready')));
    expect(find.text('remote page'), findsOneWidget);
  });

  group('Home settings › Chat', () {
    Widget row() => Scaffold(body: ListView(children: const [ChatSettingsRow(connectionId: 'c1')]));

    testWidgets('hidden outside the Play build or where Pro is not sold', (tester) async {
      await _open(tester, state: ChatRowState.hidden, child: row());
      expect(find.byKey(const Key('home-chat')), findsNothing);
    });

    testWidgets('ready opens the Chat screen', (tester) async {
      await _open(tester, child: row());
      expect(find.text('Chat (beta)'), findsOneWidget);
      expect(find.text('Talk to your home from Telegram'), findsOneWidget);
      await _tap(tester, find.byKey(const Key('home-chat')));
      expect(find.text('chat page'), findsOneWidget);
    });

    testWidgets("a founder's Home after the pass opens the Chat screen to manage links", (tester) async {
      await _open(tester, state: ChatRowState.passEnded, child: row());
      expect(find.text('Founder\'s pass ended: links can still be removed'), findsOneWidget);
      await _tap(tester, find.byKey(const Key('home-chat')));
      expect(find.text('chat page'), findsOneWidget);
    });

    for (final (state, text) in [
      (ChatRowState.noRemote, 'Turn on remote control first'),
      (ChatRowState.noPro, 'Part of ZigDash Pro (not included in the trial)'),
      (ChatRowState.noEngine, 'Needs ZigDash Engine on your hub'),
    ]) {
      testWidgets('${state.name} says why', (tester) async {
        await _open(tester, state: state, child: row());
        expect(find.text(text), findsOneWidget);
      });
    }
  });

  group("founder's pass", () {
    FounderStatus pass({DateTime? ends, bool ended = false}) =>
        FounderStatus(kind: 'founder', expiresAt: ends ?? _end, ended: ended, fetchedAt: _now);

    testWidgets('after the end: links listed and removable, Link replaced by the Pro line', (tester) async {
      final page = await _open(
        tester,
        state: ChatRowState.passEnded,
        founder: pass(ended: true),
        listed: [const ChatLinkInfo(clientId: 'tg-bbbbbb', telegramName: 'Noa', scope: 'read')],
      );
      expect(find.text('Noa'), findsOneWidget);
      expect(find.byKey(const Key('chat-link')), findsNothing);
      expect(find.byKey(const Key('chat-scope-read')), findsNothing);
      expect(find.text("Your founder's pass ended on Feb 14, 2027. ZigDash Pro brings remote control and Chat back, "
          'with nothing to set up again.'), findsOneWidget);
      expect(find.byKey(const Key('founder-get-pro')), findsOneWidget);
      // No intro count for a Home that can't link.
      expect(page.sink.sent, isEmpty);
      expect(page.refreshed, ['c1']);

      page.hub.configs['tg-bbbbbb'] = {'v': 1};
      await _tap(tester, find.byKey(const Key('chat-remove-tg-bbbbbb')));
      await _tap(tester, find.byKey(const Key('chat-remove-ok')));
      expect(page.log.skip(2), ['ticket tg-bbbbbb', 'service unlink tg-bbbbbb', 'hub revoke tg-bbbbbb']);
      expect(find.text('Noa'), findsNothing);
    });

    testWidgets('after the end with Pro bought elsewhere: asked first, not moved', (tester) async {
      await _open(tester, state: ChatRowState.passEnded, founder: pass(ended: true), pro: ProStatus.unlocked);
      expect(find.byKey(const Key('founder-use-pro')), findsOneWidget);
      expect(find.byKey(const Key('founder-get-pro')), findsNothing);
    });

    testWidgets('the pass ending on confirm is final: the link is dropped and the screen asks the relay', (tester) async {
      final page = await _open(tester, founder: pass());
      await _tap(tester, find.byKey(const Key('chat-link')));
      expect(page.hub.configs, hasLength(1));
      page.api.confirmFails.add(const ChatException(ChatFail.passEnded));
      await _code(tester, '4821');
      await _tap(tester, find.byKey(const Key('chat-confirm')));
      expect(find.byKey(const Key('chat-finish')), findsNothing);
      expect(page.hub.configs, isEmpty);
      expect(page.log.last, startsWith('hub revoke'));
      expect(find.text("This Home's founder's pass ended, so no new Telegram account can be linked."), findsOneWidget);
      // Counted as the purchase gate: no new analytics value.
      expect(page.sink.sent.last, 'chat_link {step: failed, why: purchase}');
      expect(page.refreshed, ['c1', 'c1']);
    });

    testWidgets("a refused ticket on a founder's Home speaks of the pass, not of Google Play", (tester) async {
      final page = await _open(tester, founder: pass());
      page.api.ticketFails = ChatFail.purchase;
      await _tap(tester, find.byKey(const Key('chat-link')));
      expect(find.text("This Home's founder's pass ended, so no new Telegram account can be linked."), findsOneWidget);
      expect(find.textContaining('Google Play'), findsNothing);
      expect(page.hub.configs, isEmpty);
    });

    testWidgets('the last 7 days: the date and Get Pro above Link', (tester) async {
      await _open(tester, founder: pass(ends: _now.add(const Duration(days: 3))));
      expect(find.textContaining("Your founder's pass ends on Nov 19, 2026."), findsOneWidget);
      expect(find.byKey(const Key('founder-get-pro')), findsOneWidget);
      expect(find.byKey(const Key('chat-link')), findsOneWidget);
    });

    testWidgets('a status that arrives after the screen opened: the list loads then', (tester) async {
      final page = await _open(tester, state: ChatRowState.noPro, founder: pass());
      expect(page.log, isEmpty);
      final container = ProviderScope.containerOf(tester.element(find.byType(ChatScreen)));
      container.read(_row.notifier).state = ChatRowState.ready;
      await tester.pumpAndSettle();
      expect(page.log, ['ticket', 'links']);
      expect(find.byKey(const Key('chat-links-none')), findsOneWidget);
    });

    testWidgets('earlier in the pass: Chat as usual', (tester) async {
      await _open(tester, founder: pass());
      expect(find.byKey(const Key('founder-pro-line')), findsNothing);
      expect(find.byKey(const Key('chat-link')), findsOneWidget);
    });
  });
}

void _auditLines() {
  test('What Chat did reads like words, not the Engine\'s JSON', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    ChatAuditEntry e(String result, {String? device = 'Office shutter'}) =>
        ChatAuditEntry(at: DateTime.utc(2026, 11, 16), client: 'tg-a', tool: 'set_device', device: device, result: result);
    expect(auditLine(l10n, e('sent {"position":50}')), 'Office shutter: set position 50');
    expect(auditLine(l10n, e('sent {"state":"ON","brightness":120}')), 'Office shutter: set state ON, brightness 120');
    expect(auditLine(l10n, e('sent {"occupied_heating_setpoint":21}')), 'Office shutter: set occupied heating setpoint 21');
    expect(auditLine(l10n, e('failed')), "Office shutter: couldn't send");
    expect(auditLine(l10n, e('refused: read only: not on the control list')), 'Office shutter: refused: read only: not on the control list');
    expect(auditLine(l10n, e('refused: not linked', device: null)), 'set_device: refused: not linked');
  });
}
