import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:zigdash/features/chat/chat_api.dart';
import 'package:zigdash/features/chat/chat_hub.dart';
import 'package:zigdash/features/chat/chat_wire.dart';
import 'package:zigdash/mqtt/endpoint.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/remote/remote_home.dart';
import 'package:zigdash/remote/remote_setup.dart';

/// The chat service's answers (tool/zigdash-chat/README.md on
/// feat/chat-backend), one per path and method.
typedef Answer = (int, Object?);

class _Mgr implements MqttManager {
  _Mgr({required this.home});
  final bool home;
  final published = <(String, String, bool)>[];

  @override
  bool get isConnected => true;

  @override
  MqttEndpoint? get activeEndpoint => home ? MqttEndpoint.local : MqttEndpoint.relay;

  @override
  void publish(String topic, String template, Object value, {mc.MqttQos qos = mc.MqttQos.atLeastOnce, bool retain = false}) =>
      published.add((topic, template, retain));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late HttpServer server;
  late Map<String, Answer> answers;
  late List<String> seen;
  late HttpChatApi api;

  // A real loopback server: the test binding's fake HttpClient is set aside.
  setUpAll(() => HttpOverrides.global = null);

  setUp(() async {
    answers = {};
    seen = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final body = await utf8.decoder.bind(req).join();
      seen.add('${req.method} ${req.uri.path} ${req.headers.value('X-Chat-Ticket') ?? ''} $body'.trim());
      final (status, json) = answers['${req.method} ${req.uri.path}'] ?? (500, null);
      req.response.statusCode = status;
      req.response.headers.contentType = ContentType.json;
      req.response.write(jsonEncode(json));
      await req.response.close();
    });
    final remote = RemoteSetup(RemoteHomeStore(const FlutterSecureStorage()), (_) => throw UnimplementedError());
    api = HttpChatApi(remote, base: 'http://127.0.0.1:${server.port}');
  });

  tearDown(() => server.close(force: true));

  Future<ChatFail> failOf(Future<Object?> call) async {
    try {
      await call;
    } on ChatException catch (e) {
      return e.why;
    }
    fail('no error');
  }

  test('link: the code, and the Telegram url the service gives (only a t.me one)', () async {
    answers['POST /v1/link'] = (200, {'code': 'LK7Q2F9', 'expires_in': 600, 'bot': 'ZigDashHomeBot', 'url': 'https://t.me/ZigDashHomeBot?start=LK7Q2F9'});
    final l = await api.link(ticket: 't', token: 'tok', key: 'k', scope: 'read');
    expect(l.code, 'LK7Q2F9');
    expect(l.url.toString(), 'https://t.me/ZigDashHomeBot?start=LK7Q2F9');
    expect(jsonDecode(seen.single.substring('POST /v1/link '.length)), {'ticket': 't', 'token': 'tok', 'key': 'k', 'scope': 'read'});
    answers['POST /v1/link'] = (200, {'code': 'LK7Q2F9', 'url': 'https://evil.example/x'});
    expect((await api.link(ticket: 't', token: 'tok', key: 'k', scope: 'read')).url, isNull);
    answers['POST /v1/link'] = (401, {'error': 'ticket_expired'});
    expect(await failOf(api.link(ticket: 't', token: 'tok', key: 'k', scope: 'read')), ChatFail.expired);
    answers['POST /v1/link'] = (429, {'error': 'too_many'});
    expect(await failOf(api.link(ticket: 't', token: 'tok', key: 'k', scope: 'read')), ChatFail.tooMany);
  });

  test('confirm: only wrong_code is a wrong code; not claimed and try again are not', () async {
    answers['POST /v1/link/confirm'] = (200, {'linked': true, 'client_id': 'tg-a1b2c3', 'telegram_name': 'Dana', 'scope': 'control'});
    final info = await api.confirm(ticket: 't', codeBack: '4821');
    expect([info!.clientId, info.telegramName, info.scope], ['tg-a1b2c3', 'Dana', 'control']);

    answers['POST /v1/link/confirm'] = (409, {'error': 'not_claimed'});
    expect(await failOf(api.confirm(ticket: 't', codeBack: '4821')), ChatFail.notClaimed);
    answers['POST /v1/link/confirm'] = (503, {'error': 'try_again'});
    expect(await failOf(api.confirm(ticket: 't', codeBack: '4821')), ChatFail.unreachable);
    answers['POST /v1/link/confirm'] = (400, {'error': 'wrong_code', 'tries_left': 2});
    try {
      await api.confirm(ticket: 't', codeBack: '1111');
      fail('no error');
    } on ChatException catch (e) {
      expect([e.why, e.triesLeft], [ChatFail.wrongCode, 2]);
    }
    answers['POST /v1/link/confirm'] = (410, {'error': 'cancelled'});
    expect(await failOf(api.confirm(ticket: 't', codeBack: '1111')), ChatFail.expired);
    answers['POST /v1/link/confirm'] = (404, {'error': 'unknown_code'});
    expect(await failOf(api.confirm(ticket: 't', codeBack: '1111')), ChatFail.expired);
    answers['POST /v1/link/confirm'] = (401, {'error': 'ticket_expired'});
    expect(await failOf(api.confirm(ticket: 't', codeBack: '1111')), ChatFail.ticket);
    answers['POST /v1/link/confirm'] = (409, {'error': 'already_linked'});
    expect(await api.confirm(ticket: 't', codeBack: '4821'), isNull);
  });

  test('remove: 404 not_linked counts as removed; 403 wrong_client does not', () async {
    answers['DELETE /v1/link/tg-a1b2c3'] = (200, {'removed': true});
    await api.unlink(ticket: 'tk', clientId: 'tg-a1b2c3');
    expect(seen.single, 'DELETE /v1/link/tg-a1b2c3 tk');
    answers['DELETE /v1/link/tg-a1b2c3'] = (404, {'error': 'not_linked'});
    await api.unlink(ticket: 'tk', clientId: 'tg-a1b2c3');
    answers['DELETE /v1/link/tg-a1b2c3'] = (403, {'error': 'wrong_client'});
    expect(await failOf(api.unlink(ticket: 'tk', clientId: 'tg-a1b2c3')), ChatFail.refused);
  });

  test('links: {links: [...]} with the ticket in its header', () async {
    answers['GET /v1/links'] = (200, {
      'links': [
        {'client_id': 'tg-a1b2c3', 'telegram_name': 'Dana', 'scope': 'read', 'last_used': null, 'linked_at': 1763200000000},
      ],
    });
    final links = await api.links(ticket: 'tk');
    expect(links.single.clientId, 'tg-a1b2c3');
    expect(links.single.lastUsed, isNull);
    expect(seen.single, 'GET /v1/links tk');
  });

  test('the hub: deleting a client is {"v":1,"delete":true}, retained; never through the relay', () async {
    final home = _Mgr(home: true);
    expect(await MqttChatHub((_) async => home).revokeClient('c1', 'tg-a1b2c3'), isTrue);
    expect(home.published.single, ('zigdash/chat/clients/tg-a1b2c3', '{"v":1,"delete":true}', true));
    expect(jsonDecode(ChatWire.deleteConfig), {'v': 1, 'delete': true});

    final away = _Mgr(home: false);
    expect(await MqttChatHub((_) async => away).revokeClient('c1', 'tg-a1b2c3'), isFalse);
    await expectLater(MqttChatHub((_) async => away).createClient('c1', 'tg-a1b2c3', '{}'),
        throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.notAtHome)));
    expect(away.published, isEmpty);
  });
}
