import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics_events.dart';
import 'package:zigdash/engine/engine_status.dart';
import 'package:zigdash/features/chat/chat_api.dart';
import 'package:zigdash/features/chat/chat_hub.dart';
import 'package:zigdash/features/chat/chat_linker.dart';
import 'package:zigdash/features/chat/chat_store.dart';
import 'package:zigdash/features/chat/chat_wire.dart';
import 'package:zigdash/features/pro/pro.dart';

import 'chat_fakes.dart';

/// The Engine's side of one client, as hub/src/chat.js answers: opens with
/// the key, checks the token hash, answers sealed with its own time.
class EnginePipe implements ChatPipe {
  EnginePipe({required this.key, required this.hash, this.clockAhead = Duration.zero, this.linked = true});
  final Uint8List key;
  final String hash;
  final Duration clockAhead;
  final bool linked;
  final _out = StreamController<String>.broadcast();
  final requests = <Map<String, Object?>>[];
  bool closed = false;

  @override
  Stream<String> listen(String topic) => _out.stream;

  @override
  void publish(String topic, String payload) {
    scheduleMicrotask(() {
      if (!linked) return _out.add('{"error":"not_linked"}');
      final msg = ChatWire.unseal(key, payload);
      if (msg == null || ChatWire.sha256('${msg['token']}') != hash) return;
      requests.add(msg);
      final now = DateTime.now().add(clockAhead).millisecondsSinceEpoch;
      if (((msg['at'] as num) - now).abs() > 120000) {
        _out.add(ChatWire.seal(key, {'id': msg['id'], 'at': now, 'ok': false, 'error': 'stale'}));
        return;
      }
      _out.add(ChatWire.seal(key, {
        'id': msg['id'],
        'at': now,
        'ok': true,
        'result': {
          'entries': [
            {'at': '2026-11-15T10:00:00.000Z', 'client': 'tg-a1b2c3', 'tool': 'set_device', 'device': 'Office shutter', 'result': 'sent'},
          ],
        },
      }));
    });
  }

  @override
  Future<void> close() async => closed = true;
}

void main() {
  late List<String> log;
  late FakeChatApi api;
  late FakeChatHub hub;
  late MemoryChatStore store;
  late DateTime now;
  late ChatLinker linker;

  setUp(() {
    log = [];
    api = FakeChatApi(log);
    hub = FakeChatHub(log);
    store = MemoryChatStore();
    now = DateTime(2026, 11, 15, 12);
    linker = ChatLinker(api, hub, store, (_) async => relayLogin, now: () => now);
  });

  test('the row: Play build, Pro owned (not the trial), remote on, Engine seen; else why', () {
    ChatRowState of({
      bool offered = true,
      bool fits = true,
      ProStatus pro = ProStatus.unlocked,
      bool remoteOn = true,
      bool engine = true,
    }) =>
        chatRowStateOf(offered: offered, fits: fits, pro: pro, remoteOn: remoteOn, engineInstalled: engine);
    expect(of(), ChatRowState.ready);
    expect(of(remoteOn: false), ChatRowState.noRemote);
    expect(of(engine: false), ChatRowState.noEngine);
    // The trial gives Pro access but not a purchase the relay can check.
    expect(of(pro: ProStatus.locked), ChatRowState.noPro);
    expect(of(pro: ProStatus.locked, remoteOn: false), ChatRowState.noPro);
    // GitHub, F-Droid and App Store builds: no row at all.
    expect(of(offered: false), ChatRowState.hidden);
    expect(of(pro: ProStatus.unavailable), ChatRowState.hidden);
    // Home Assistant or Zigbee2MQTT's page: the relay can't serve it.
    expect(of(fits: false), ChatRowState.hidden);
  });

  test('only an Engine with Chat (3.7.0 or the 9.0.0-chat build) takes a client', () {
    EngineReport r(String v) =>
        EngineReport(version: v, runningOn: 'hub', rulesLoaded: 0, rulesUnknown: const [], stoppedSelf: false, at: null);
    expect(engineHasChat(r('3.7.0')), isTrue);
    expect(engineHasChat(r('9.0.0-chat')), isTrue);
    expect(engineHasChat(r('3.6.2')), isFalse);
    expect(engineHasChat(null), isFalse);
  });

  test('linking: ticket, keys kept, hub client over the LAN, link code; then the back-code', () async {
    final p = await linker.start('c1', scope: 'control', controls: ['0x01'], atHome: true, engineReady: true);
    final id = p.client.clientId;
    expect(log, ['ticket $id', 'hub create $id', 'link control']);
    expect(p.code, 'LK7Q2F9');
    expect(p.telegram.toString(), 'https://t.me/ZigDashHomeBot?start=LK7Q2F9');
    // The ticket names the client and its relay topics, made with its own key.
    final t = ChatWire.relayTopics('h0me1d', id, p.client.key);
    expect(api.tickets.single, {'client_id': id, 'request_topic': t.req, 'answer_topic': t.res});
    // The hub gets what chatParseClient takes; the service the same token and key.
    final config = hub.configs[id]!;
    expect(config['hash'], ChatWire.sha256(p.client.token));
    expect(config['key'], base64.encode(p.client.key));
    expect(config['scope'], 'control');
    expect(config['controls'], ['0x01']);
    expect(api.linked.values.single, {'token': p.client.token, 'key': base64.encode(p.client.key), 'scope': 'control'});
    expect((await store.read('c1')).clients.single.confirmed, isFalse);

    await expectLater(linker.confirm('c1', p, '0000'), throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.wrongCode)));
    await linker.confirm('c1', p, ' 4821 ');
    expect((await store.read('c1')).clients.single.confirmed, isTrue);
  });

  test('Read sends no control list, even if devices were switched on', () async {
    final p = await linker.start('c1', scope: 'read', controls: ['0x01'], atHome: true, engineReady: true);
    expect(hub.configs[p.client.clientId]!['controls'], isEmpty);
    expect(hub.configs[p.client.clientId]!['scope'], 'read');
  });

  test('away, or with an older Engine, nothing is asked or written', () async {
    await expectLater(linker.start('c1', scope: 'read', controls: const [], atHome: false, engineReady: true),
        throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.notAtHome)));
    await expectLater(linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: false),
        throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.engineOld)));
    expect(log, isEmpty);
    expect((await store.read('c1')).clients, isEmpty);
  });

  test('a refused purchase writes nothing to the hub; a failed link takes the hub client back', () async {
    api.ticketFails = ChatFail.purchase;
    await expectLater(linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true),
        throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.purchase)));
    expect(hub.configs, isEmpty);
    api.ticketFails = null;
    api.linkFails = ChatFail.tooMany;
    await expectLater(linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true),
        throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.tooMany)));
    expect(hub.configs, isEmpty);
    expect(log.last, startsWith('hub revoke '));
    expect((await store.read('c1')).clients, isEmpty);
  });

  test('confirming after 8 minutes asks for a fresh ticket for the same client', () async {
    final p = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    now = now.add(const Duration(minutes: 9));
    log.clear();
    await linker.confirm('c1', p, '4821');
    expect(log, ['ticket ${p.client.clientId}', 'confirm 4821']);
  });

  test('remove: the service first, then the hub; away, the hub waits for home', () async {
    final a = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    await linker.confirm('c1', a, '4821');
    final b = await linker.start('c1', scope: 'control', controls: const [], atHome: true, engineReady: true);
    await linker.confirm('c1', b, '4821');
    expect((await linker.links('c1')).map((l) => l.clientId), [a.client.clientId, b.client.clientId]);

    log.clear();
    expect(await linker.remove('c1', a.client.clientId), isTrue);
    expect(log, ['ticket ${a.client.clientId}', 'service unlink ${a.client.clientId}', 'hub revoke ${a.client.clientId}']);

    hub.atHome = false;
    log.clear();
    expect(await linker.remove('c1', b.client.clientId), isFalse);
    expect(log, ['ticket ${b.client.clientId}', 'service unlink ${b.client.clientId}']);
    var record = await store.read('c1');
    expect(record.clients, isEmpty);
    expect(record.revokeOnHub, {b.client.clientId});

    // Back home: the hub deletion owed is done.
    hub.atHome = true;
    await linker.tidy('c1', listed: const []);
    expect(log.last, 'hub revoke ${b.client.clientId}');
    record = await store.read('c1');
    expect(record.revokeOnHub, isEmpty);
  });

  test('a service that refuses the removal leaves everything as it was', () async {
    final a = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    await linker.confirm('c1', a, '4821');
    api.unlinkFails = ChatFail.unreachable;
    await expectLater(linker.remove('c1', a.client.clientId), throwsA(isA<ChatException>()));
    expect(hub.configs.keys, [a.client.clientId]);
    expect((await store.read('c1')).clients, hasLength(1));
  });

  test('a link never confirmed is tidied from the hub after 15 minutes', () async {
    final p = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    await linker.tidy('c1', listed: const []);
    expect(hub.configs.keys, [p.client.clientId], reason: 'still within its 10 minutes');
    now = now.add(const Duration(minutes: 16));
    await linker.tidy('c1', listed: null);
    expect(hub.configs.keys, [p.client.clientId], reason: "the service's list is unknown");
    await linker.tidy('c1', listed: const []);
    expect(hub.configs, isEmpty);
    expect((await store.read('c1')).clients, isEmpty);
  });

  test('a ticket that ran out at confirm is asked for again once; the code still works', () async {
    final p = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    api.confirmFails.add(const ChatException(ChatFail.ticket));
    log.clear();
    final info = await linker.confirm('c1', p, '4821');
    expect(log, ['confirm 4821', 'ticket ${p.client.clientId}', 'confirm 4821']);
    expect(info!.telegramName, 'Dana');
    expect((await store.read('c1')).clients.single.confirmed, isTrue);
  });

  test('not claimed, try again and a wrong code keep the link waiting; only wrong_code is a wrong code', () async {
    final p = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    api.confirmFails.addAll([const ChatException(ChatFail.notClaimed), const ChatException(ChatFail.unreachable)]);
    await expectLater(linker.confirm('c1', p, '4821'), throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.notClaimed)));
    await expectLater(linker.confirm('c1', p, '4821'), throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.unreachable)));
    await expectLater(linker.confirm('c1', p, '1111'),
        throwsA(isA<ChatException>().having((e) => e.triesLeft, 'triesLeft', 2)));
    expect(hub.configs.keys, [p.client.clientId]);
    await linker.confirm('c1', p, '4821');
  });

  test('a client unlinked from the chat (/unlink): deleted on the hub at home, queued while away', () async {
    final a = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    await linker.confirm('c1', a, '4821');
    final b = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    await linker.confirm('c1', b, '4821');
    // Both unlinked in Telegram; the phone is away.
    api.listed = [];
    hub.atHome = false;
    await linker.tidy('c1', listed: await linker.links('c1'));
    var record = await store.read('c1');
    expect(record.clients, isEmpty);
    expect(record.revokeOnHub, {a.client.clientId, b.client.clientId});
    expect(hub.configs, hasLength(2));
    // Home again.
    hub.atHome = true;
    await linker.tidy('c1', listed: await linker.links('c1'));
    record = await store.read('c1');
    expect(record.revokeOnHub, isEmpty);
    expect(hub.configs, isEmpty);
  });

  test('a confirmed client the service still lists is kept', () async {
    final a = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    await linker.confirm('c1', a, '4821');
    now = now.add(const Duration(days: 30));
    await linker.tidy('c1', listed: await linker.links('c1'));
    expect((await store.read('c1')).clients, hasLength(1));
    expect(hub.configs, hasLength(1));
  });

  test('What Chat did: one sealed audit request per linked client, newest first', () async {
    final a = await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    await linker.confirm('c1', a, '4821');
    // One that never finished is not asked.
    await linker.start('c1', scope: 'read', controls: const [], atHome: true, engineReady: true);
    hub.audits = [
      ChatAuditEntry(at: DateTime.utc(2026, 11, 15, 9), client: a.client.clientId, tool: 'get_device', result: 'ok'),
      ChatAuditEntry(at: DateTime.utc(2026, 11, 15, 11), client: a.client.clientId, tool: 'set_device', result: 'sent'),
    ];
    log.clear();
    final entries = await linker.audit('c1');
    expect(log, ['audit ${a.client.clientId}']);
    expect(entries!.map((e) => e.tool), ['set_device', 'get_device']);
    hub.audits = null;
    expect(await linker.audit('c1'), isNull);
  });

  group('a sealed request, as link.mjs sends it', () {
    final key = Uint8List.fromList(List<int>.generate(32, (i) => i));
    const token = 'tok_ABC-123';

    Future<Map<String, Object?>?> ask(EnginePipe pipe) => chatRequest(pipe,
        requestTopic: 'zigdash/chat/req/tg-a1b2c3',
        answerTopic: 'zigdash/chat/res/tg-a1b2c3',
        token: token,
        key: key,
        tool: 'audit',
        args: {'limit': 50},
        timeout: const Duration(seconds: 2));

    test('carries the token, a fresh id and the time; the answer opens', () async {
      final pipe = EnginePipe(key: key, hash: ChatWire.sha256(token));
      final answer = await ask(pipe);
      expect(answer!['ok'], true);
      final req = pipe.requests.single;
      expect(req['tool'], 'audit');
      expect(req['args'], {'limit': 50});
      expect(req['id'], matches(RegExp(r'^[A-Za-z0-9_-]{8,64}$')));
    });

    test('a hub clock 5 minutes ahead answers stale once; the retry carries its time', () async {
      final pipe = EnginePipe(key: key, hash: ChatWire.sha256(token), clockAhead: const Duration(minutes: 5));
      final answer = await ask(pipe);
      expect(answer!['ok'], true);
      expect(pipe.requests, hasLength(2));
      expect(pipe.requests[0]['id'], isNot(pipe.requests[1]['id']));
    });

    test('a client the Engine no longer has is refused', () async {
      final pipe = EnginePipe(key: key, hash: ChatWire.sha256(token), linked: false);
      await expectLater(ask(pipe), throwsA(isA<ChatException>()));
    });

    test('a wrong token gets no answer', () async {
      final pipe = EnginePipe(key: key, hash: ChatWire.sha256('other'));
      expect(await ask(pipe), isNull);
    });
  });

  test('the chat_link event counts steps only', () {
    expect(const ChatLinkEvent(ChatLinkStep.intro).props, {'step': 'intro'});
    expect(ChatLinkEvent(ChatLinkStep.failed, why: ChatFail.wrongCode.wire).props, {'step': 'failed', 'why': 'wrong_code'});
    expect(const ChatLinkEvent(ChatLinkStep.linked).name, 'chat_link');
  });

  test("the service's list: last used in ms or ISO; a row without an id is dropped", () {
    expect(ChatLinkInfo.fromJson({'client_id': 'tg-1', 'telegram_name': 'Dana', 'scope': 'control', 'last_used': 1763200000000})!.lastUsed,
        DateTime.fromMillisecondsSinceEpoch(1763200000000));
    expect(ChatLinkInfo.fromJson({'client_id': 'tg-1', 'last_used': '2026-11-15T10:00:00Z'})!.lastUsed, DateTime.utc(2026, 11, 15, 10));
    expect(ChatLinkInfo.fromJson({'telegram_name': 'no id'}), isNull);
  });
}
