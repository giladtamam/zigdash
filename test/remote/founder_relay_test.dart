import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart' as mc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zigdash/features/chat/chat_api.dart';
import 'package:zigdash/mqtt/endpoint.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';
import 'package:zigdash/remote/founder.dart';
import 'package:zigdash/remote/remote_home.dart';
import 'package:zigdash/remote/remote_setup.dart';

/// The relay's founder routes (founders-pass.md, the wire contract), on a
/// loopback server.
typedef Answer = (int, Object?);

class _Mgr implements MqttManager {
  bool home = true;
  final published = <(String, String)>[];

  @override
  bool get isConnected => true;

  @override
  MqttEndpoint? get activeEndpoint => home ? MqttEndpoint.local : MqttEndpoint.relay;

  @override
  void publish(String topic, String template, Object value, {mc.MqttQos qos = mc.MqttQos.atLeastOnce, bool retain = false}) =>
      published.add((topic, template));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _login = RemoteHome(
  homeId: 'h0me1d',
  url: 'wss://relay.example/mqtt',
  username: 'phone-h0me1d-ff',
  password: 'pw',
  key: Uint8List(32),
);

final _now = DateTime.utc(2026, 11, 16, 12);
final _end = DateTime.utc(2027, 2, 14, 12);

Map<String, Object?> _admitted() => {
      'homeId': 'h0me1d',
      'hub': {'url': 'wss://relay.example/mqtt', 'username': 'hub-h0me1d', 'password': 'hubpw'},
      'phone': {'url': 'wss://relay.example/mqtt', 'username': 'phone-h0me1d-01', 'password': 'phonepw'},
      'kind': 'founder',
      'expires_at': _end.millisecondsSinceEpoch,
    };

void main() {
  late HttpServer server;
  late Map<String, List<Answer>> answers;
  late List<(String, String, Map<String, Object?>?)> seen;
  late RemoteHomeStore store;
  late _Mgr mgr;
  late String? purchase;
  late int nonces;
  late RemoteSetup setup;

  // A real loopback server: the test binding's fake HttpClient is set aside.
  setUpAll(() => HttpOverrides.global = null);

  setUp(() async {
    answers = {};
    seen = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final text = await utf8.decoder.bind(req).join();
      final key = '${req.method} ${req.uri.path}';
      seen.add((key, req.headers.value('authorization') ?? '', text.isEmpty ? null : jsonDecode(text) as Map<String, Object?>));
      final queue = answers[key];
      final (status, json) = queue == null || queue.isEmpty ? (500, null) : (queue.length > 1 ? queue.removeAt(0) : queue.first);
      if (status == 0) {
        // A lost answer: the connection drops after the relay acted.
        await req.response.detachSocket().then((s) => s.destroy());
        return;
      }
      req.response.statusCode = status;
      req.response.headers.contentType = ContentType.json;
      req.response.write(jsonEncode(json));
      await req.response.close();
    });
    FlutterSecureStorage.setMockInitialValues({});
    store = RemoteHomeStore(const FlutterSecureStorage());
    mgr = _Mgr();
    purchase = null;
    nonces = 0;
    setup = RemoteSetup(
      store,
      (_) async => mgr,
      api: 'http://127.0.0.1:${server.port}',
      purchaseToken: () async => purchase,
      nonce: () => 'nonce-${++nonces}-abcdefghijkl',
      now: () => _now,
    );
  });

  tearDown(() => server.close(force: true));

  test('the code is read as the relay hashes it: case, spaces and dashes ignored, I L O as 1 1 0', () {
    expect(normaliseFounderCode(' zd-7k3m-q9ab-x2 '), 'ZD7K3MQ9ABX2');
    expect(normaliseFounderCode('ZD 7K3M Q9AB X2'), 'ZD7K3MQ9ABX2');
    expect(normaliseFounderCode('zd-1lio-0000-oo'), 'ZD1110000000');
    expect(normaliseFounderCode('ZD–7K3M—Q9AB-X2'), 'ZD7K3MQ9ABX2');
    final n = newRedeemNonce();
    expect(n, matches(RegExp(r'^[A-Za-z0-9_-]{16,64}$')));
    expect(newRedeemNonce(), isNot(n));
  });

  test('redeem: founder store, the code and a nonce; the hub gets its login, this phone keeps its own and the pass', () async {
    answers['POST /v1/homes'] = [(200, _admitted())];
    expect(await setup.redeem('c1', 'zd-7k3m-q9ab-x2'), (FounderRedeemResult.ready, _end.toLocal()));
    final (path, auth, body) = seen.single;
    expect(path, 'POST /v1/homes');
    expect(auth, isEmpty);
    expect(body, {'store': 'founder', 'purchaseToken': 'ZD7K3MQ9ABX2', 'redeem_nonce': 'nonce-1-abcdefghijkl'});
    final (topic, payload) = mgr.published.single;
    expect(topic, engineRemoteTopic);
    expect((jsonDecode(payload) as Map)..remove('key'),
        {'url': 'wss://relay.example/mqtt', 'homeId': 'h0me1d', 'username': 'hub-h0me1d', 'password': 'hubpw'});
    final login = (await store.read('c1'))!;
    expect([login.homeId, login.username, login.password], ['h0me1d', 'phone-h0me1d-01', 'phonepw']);
    final pass = (await store.readFounder('c1'))!;
    expect([pass.founder, pass.expiresAt, pass.ended], [true, _end.toLocal(), false]);
    expect(pass.activeAt(_now), isTrue);
    // The code itself is never kept, and the nonce goes with success.
    expect(await store.readRedeemNonce('c1'), isNull);
  });

  test('a lost answer: the retry sends the same nonce, a new redeem after success a new one', () async {
    answers['POST /v1/homes'] = [(0, null), (200, _admitted())];
    expect((await setup.redeem('c1', 'ZD-7K3M-Q9AB-X2')).$1, FounderRedeemResult.unreachable);
    expect(await store.read('c1'), isNull);
    expect(mgr.published, isEmpty);
    expect((await setup.redeem('c1', 'ZD-7K3M-Q9AB-X2')).$1, FounderRedeemResult.ready);
    expect([for (final s in seen) s.$3!['redeem_nonce']], ['nonce-1-abcdefghijkl', 'nonce-1-abcdefghijkl']);
    expect(nonces, 1);

    await store.delete('c1');
    answers['POST /v1/homes'] = [(409, {'error': 'code_used'})];
    await setup.redeem('c1', 'ZD-7K3M-Q9AB-X2');
    expect(seen.last.$3!['redeem_nonce'], 'nonce-2-abcdefghijkl');
  });

  test('a refused code keeps the nonce until success', () async {
    answers['POST /v1/homes'] = [(402, {'error': 'no_pass'})];
    await setup.redeem('c1', 'ZD-7K3M-Q9AB-X3');
    expect(await store.readRedeemNonce('c1'), 'nonce-1-abcdefghijkl');
  });

  test('each refusal has its own answer, and nothing is written', () async {
    Future<FounderRedeemResult> with_(int status, [String? error]) async {
      answers['POST /v1/homes'] = [(status, {'error': ?error})];
      return (await setup.redeem('c1', 'ZD-7K3M-Q9AB-X2')).$1;
    }

    expect(await with_(402, 'no_pass'), FounderRedeemResult.wrongCode);
    expect(await with_(402, 'deadline'), FounderRedeemResult.deadline);
    expect(await with_(402, 'revoked'), FounderRedeemResult.revoked);
    expect(await with_(409, 'code_used'), FounderRedeemResult.used);
    expect(await with_(429), FounderRedeemResult.tooMany);
    expect(await with_(400, 'bad_request'), FounderRedeemResult.refused);
    expect(await store.read('c1'), isNull);
    expect(await store.readFounder('c1'), isNull);
    expect(mgr.published, isEmpty);

    // Away: the hub's login travels over the home network only.
    mgr.home = false;
    final before = seen.length;
    expect((await setup.redeem('c1', 'ZD-7K3M-Q9AB-X2')).$1, FounderRedeemResult.notAtHome);
    expect(seen, hasLength(before));
  });

  test('the status: founder or not, its end, and 410 is a deleted Home', () async {
    expect(await setup.founderStatus('c1'), isNull, reason: 'no login, nothing asked');
    expect(seen, isEmpty);
    await store.write('c1', _login);

    answers['GET /v1/homes/h0me1d'] = [(200, {'kind': 'founder', 'expires_at': _end.millisecondsSinceEpoch, 'ended': false})];
    final s = (await setup.founderStatus('c1'))!;
    expect(seen.single.$2, 'Basic ${base64.encode(utf8.encode('phone-h0me1d-ff:pw'))}');
    expect([s.founder, s.expiresAt, s.endsSoonAt(_now)], [true, _end.toLocal(), false]);
    expect(s.endsSoonAt(_end.subtract(const Duration(days: 6))), isTrue);
    expect(s.activeAt(_end), isFalse);
    expect((await store.readFounder('c1'))!.fetchedAt, _now.toLocal());

    answers['GET /v1/homes/h0me1d'] = [(200, {'kind': 'founder', 'expires_at': _end.millisecondsSinceEpoch, 'ended': true})];
    expect((await setup.founderStatus('c1'))!.endedAt(_now), isTrue);

    answers['GET /v1/homes/h0me1d'] = [(200, {'kind': null, 'expires_at': null, 'ended': false})];
    final pro = (await setup.founderStatus('c1'))!;
    expect([pro.founder, pro.activeAt(_now), pro.endedAt(_now)], [false, false, false]);

    // No answer: the stored status stands.
    answers['GET /v1/homes/h0me1d'] = [(503, null)];
    expect(await setup.founderStatus('c1'), isNull);
    expect((await store.readFounder('c1'))!.founder, isFalse);

    answers['GET /v1/homes/h0me1d'] = [(410, {'error': 'deleted'})];
    expect((await setup.founderStatus('c1'))!.deleted, isTrue);
    expect((await store.readFounder('c1'))!.deleted, isTrue);

    // Turning remote control off forgets the status with the login.
    await setup.turnOff('c1', everywhere: false);
    expect(await store.readFounder('c1'), isNull);
  });

  test('402 pass_ended from the hub, phones or ticket routes is kept as the end', () async {
    await store.write('c1', _login);
    await store.writeFounder('c1', FounderStatus(kind: 'founder', expiresAt: _end, fetchedAt: _now));
    answers['POST /v1/homes/h0me1d/hub'] = [(402, {'error': 'pass_ended'})];
    expect(await setup.reconnectHub('c1'), RemoteSetupResult.refused);
    expect((await store.readFounder('c1'))!.endedAt(_now), isTrue);

    await store.writeFounder('c1', FounderStatus(kind: 'founder', expiresAt: _end, fetchedAt: _now));
    answers['POST /v1/homes/h0me1d/phones'] = [(402, {'error': 'pass_ended'})];
    expect(await setup.newPhone('c1'), isNull);
    expect((await store.readFounder('c1'))!.endedAt(_now), isTrue);

    answers['GET /v1/homes/h0me1d/phones'] = [(410, {'error': 'deleted'})];
    expect(await setup.phones('c1'), isNull);
    expect((await store.readFounder('c1'))!.deleted, isTrue);
  });

  test("a founder's Chat ticket uses the phone's login only; pass_ended reaches the app", () async {
    await store.write('c1', _login);
    await store.writeFounder('c1', FounderStatus(kind: 'founder', expiresAt: _end, fetchedAt: _now));
    answers['POST /v1/homes/h0me1d/chat-ticket'] = [(200, {'ticket': 'tk'})];
    final api = HttpChatApi(setup, base: 'http://127.0.0.1:${server.port}');
    expect(await api.ticket('c1'), 'tk');
    expect(seen.single.$3, isEmpty, reason: 'no purchase token for a founder Home');
    expect(seen.single.$2, startsWith('Basic '));

    answers['POST /v1/homes/h0me1d/chat-ticket'] = [(402, {'error': 'pass_ended'})];
    await expectLater(api.ticket('c1', clientId: 'tg-a', requestTopic: 'r', answerTopic: 'a'),
        throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.passEnded)));
    expect((await store.readFounder('c1'))!.endedAt(_now), isTrue);
    expect(seen.last.$3, {'client_id': 'tg-a', 'request_topic': 'r', 'answer_topic': 'a'});

    // A Pro Home sends its purchase, and a 402 without pass_ended is the purchase.
    await store.writeFounder('c1', FounderStatus(fetchedAt: _now));
    purchase = 'play-token';
    answers['POST /v1/homes/h0me1d/chat-ticket'] = [(402, {'error': 'no_purchase'})];
    await expectLater(api.ticket('c1'), throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.purchase)));
    expect(seen.last.$3, {'purchase_token': 'play-token'});
  });

  test('pass_ended from the chat service on confirm is final', () async {
    answers['POST /v1/link/confirm'] = [(402, {'error': 'pass_ended'})];
    final api = HttpChatApi(setup, base: 'http://127.0.0.1:${server.port}');
    await expectLater(api.confirm(ticket: 't', codeBack: '4821'),
        throwsA(isA<ChatException>().having((e) => e.why, 'why', ChatFail.passEnded)));
  });

  group('upgrade', () {
    late SharedPreferences prefs;
    late FounderUpgrader upgrader;

    setUp(() async {
      await store.write('c1', _login);
      await store.writeFounder('c1', FounderStatus(kind: 'founder', expiresAt: _end, ended: true, fetchedAt: _now));
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      upgrader = FounderUpgrader(setup, prefs, delay: (_) => Duration.zero);
      purchase = 'play-token';
    });

    test('the purchase moves the Home: same login, no longer a pass', () async {
      await upgrader.remember('c1');
      answers['POST /v1/homes/h0me1d/upgrade'] = [(200, {'kind': null})];
      expect(await upgrader.run('c1'), FounderUpgradeResult.done);
      final (path, auth, body) = seen.single;
      expect(path, 'POST /v1/homes/h0me1d/upgrade');
      expect(auth, startsWith('Basic '));
      expect(body, {'purchaseToken': 'play-token', 'store': 'play'});
      final s = (await store.readFounder('c1'))!;
      expect([s.founder, s.endedAt(_now)], [false, false]);
      expect((await store.read('c1'))!.username, _login.username);
      expect(upgrader.wanted('c1'), isFalse);
    });

    test('retried on network errors only, and still wanted after', () async {
      await upgrader.remember('c1');
      answers['POST /v1/homes/h0me1d/upgrade'] = [(0, null)];
      expect(await upgrader.run('c1'), FounderUpgradeResult.unreachable);
      expect(seen, hasLength(FounderUpgrader.attempts));
      expect(upgrader.wanted('c1'), isTrue);

      seen.clear();
      answers['POST /v1/homes/h0me1d/upgrade'] = [(503, null), (200, {'kind': null})];
      expect(await upgrader.run('c1'), FounderUpgradeResult.done);
      expect(seen, hasLength(2));
    });

    for (final (status, error, result) in [
      (409, 'purchase_has_home', FounderUpgradeResult.taken),
      (401, 'unauthorized', FounderUpgradeResult.login),
      (404, 'unknown', FounderUpgradeResult.notFound),
      (410, 'deleted', FounderUpgradeResult.deleted),
      (402, 'no_purchase', FounderUpgradeResult.noPurchase),
    ]) {
      test('$status stops at once', () async {
        await upgrader.remember('c1');
        answers['POST /v1/homes/h0me1d/upgrade'] = [(status, {'error': error})];
        expect(await upgrader.run('c1'), result);
        expect(seen, hasLength(1));
        expect(upgrader.wanted('c1'), isFalse);
        if (status == 410) expect((await store.readFounder('c1'))!.deleted, isTrue);
      });
    }

    test('without a purchase on this phone nothing is sent', () async {
      purchase = null;
      expect(await upgrader.run('c1'), FounderUpgradeResult.noPurchase);
      expect(seen, isEmpty);
    });
  });
}
