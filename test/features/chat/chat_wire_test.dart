import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/chat/chat_wire.dart';

// Vectors computed with tool/zigdash-chat/wire.mjs (and node's crypto with
// the same IV) on feat/chat-telegram, 2026-11-15.
final _key = Uint8List.fromList(List<int>.generate(32, (i) => i));
final _iv = Uint8List.fromList(List<int>.generate(12, (i) => 0xa0 + i));
const _body = {
  'id': 'req-0001-abcdef',
  'at': 1763200000000,
  'token': 'tok_ABC-123',
  'tool': 'audit',
  'args': {'limit': 50},
};
const _sealedFixed =
    'oKGio6SlpqeoqaqrnToVSWfxIM0HFKrjN0rx8xHOOnT30WBAvm9SpEWaQjfhRHfPnxJjDW+sKOp9FeicKTl8aha/cSEAHEhzlUK2kpie8QBfycba1oOKfOa67pbvatnDtuOjAcwZV/fY7m+uurRW1imr4056QqtkQRVwVXXYp2w=';
const _sealedAnswer =
    '0d3Y7MbX30AwxxAIK1TAVCg+yoboVkqx8CsAoD4WbRhhPaqwidn25oNoxkfm9aDpF/9WugUwYLhCc1+Rv+UZWuzgQ1NCZhOgnlqqDBFYRoarCDqXpTKAYRg1yeCWDLvr17hQMarb7XSjFMisPF4K/JjHRyHiPq8OFFeNJNWZ3/xl39/kWVCUC9Yf/YVSvG8q0n+KTSCDGPhsPUcbIM6yee08J2kdXJRM2zneYukacUcbFCp3P+NQronf28rABqN3U9k8/LlLW76msozs4+2mSW+HmyZ6lIRI8LCjpg5yX4jE3nz4evsJyFGjtZkWPkyoCsLp';

void main() {
  test('seals byte for byte as wire.mjs with the same IV', () {
    expect(ChatWire.seal(_key, _body, iv: _iv), _sealedFixed);
  });

  test('opens what wire.mjs sealed, and nothing sealed with another key', () {
    expect(ChatWire.unseal(_key, _sealedFixed), _body);
    final answer = ChatWire.unseal(_key, _sealedAnswer)!;
    expect(answer['ok'], true);
    expect(answer['at'], 1763200001234);
    final entries = (answer['result'] as Map)['entries'] as List;
    expect(entries.single, {
      'at': '2026-11-15T10:00:00.000Z',
      'client': 'tg-a1b2c3',
      'tool': 'set_device',
      'device': 'Office shutter',
      'result': 'sent {"state":"CLOSE"}',
    });
    final other = Uint8List.fromList(List<int>.filled(32, 7));
    expect(ChatWire.unseal(other, _sealedFixed), isNull);
    expect(ChatWire.unseal(_key, 'not base64 at all'), isNull);
    expect(ChatWire.unseal(_key, '{"error":"not_linked"}'), isNull);
  });

  test('a random-IV seal round-trips', () {
    final a = ChatWire.seal(_key, {'x': 'שלום'});
    final b = ChatWire.seal(_key, {'x': 'שלום'});
    expect(a, isNot(b));
    expect(ChatWire.unseal(_key, a), {'x': 'שלום'});
  });

  test('topics on the broker and opaque ids on the relay match wire.mjs', () {
    expect(ChatWire.requestTopic('tg-a1b2c3'), 'zigdash/chat/req/tg-a1b2c3');
    expect(ChatWire.answerTopic('tg-a1b2c3'), 'zigdash/chat/res/tg-a1b2c3');
    final t = ChatWire.relayTopics('h0me1d', 'tg-a1b2c3', _key);
    expect(t.req, 'homes/h0me1d/x/b0f41371b1e84315ee06c3a5');
    expect(t.res, 'homes/h0me1d/x/66d027757b81561478053ec9');
  });

  test('sha256 of a token matches wire.mjs', () {
    expect(ChatWire.sha256('tok_ABC-123'), '3fd4899d9e920ce4607345b2188c88e6e7e1edf8af02b9339d4de11f8d132358');
  });

  test('new ids, tokens and keys have the shapes the Engine accepts', () {
    final id = ChatWire.newClientId();
    expect(id, matches(RegExp(r'^tg-[0-9a-f]{6}$')));
    expect(ChatWire.newRequestId(), matches(RegExp(r'^[A-Za-z0-9_-]{8,64}$')));
    expect(ChatWire.newToken(), matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(ChatWire.newKey(), hasLength(32));
  });

  test('the client config is what chatParseClient takes', () {
    final c = jsonDecode(ChatWire.clientConfig(
      name: 'Telegram',
      token: 'tok_ABC-123',
      key: _key,
      scope: 'control',
      controls: ['0x00158d0001a2b3c4'],
    )) as Map;
    expect(c, {
      'v': 1,
      'name': 'Telegram',
      'hash': '3fd4899d9e920ce4607345b2188c88e6e7e1edf8af02b9339d4de11f8d132358',
      'key': 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=',
      'scope': 'control',
      'controls': ['0x00158d0001a2b3c4'],
    });
    expect(ChatWire.clientTopic('tg-a1b2c3'), 'zigdash/chat/clients/tg-a1b2c3');
  });
}
