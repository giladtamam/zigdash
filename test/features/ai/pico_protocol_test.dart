import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/ai/pico_protocol.dart';

void main() {
  group('encodeUserMessage', () {
    test('produces correct JSON with type, content, and kind', () {
      final raw = encodeUserMessage('hi');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      expect(map['type'], equals('message.send'));
      final payload = map['payload'] as Map<String, dynamic>;
      expect(payload['content'], equals('hi'));
      expect(payload['kind'], equals('text'));
    });

    test('handles special characters', () {
      final raw = encodeUserMessage('hello "world"');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final payload = map['payload'] as Map<String, dynamic>;
      expect(payload['content'], equals('hello "world"'));
    });
  });

  group('decodePicoFrame', () {
    test('parses message.create with id and content', () {
      final raw = jsonEncode({
        'type': 'message.create',
        'id': 'msg-001',
        'payload': {'content': 'Hello from AI'},
      });
      final event = decodePicoFrame(raw);
      expect(event.type, equals(PicoEventType.assistantMessage));
      expect(event.id, equals('msg-001'));
      expect(event.content, equals('Hello from AI'));
    });

    test('parses message.update with id and content', () {
      final raw = jsonEncode({
        'type': 'message.update',
        'id': 'msg-001',
        'payload': {'content': 'Hello from AI, updated'},
      });
      final event = decodePicoFrame(raw);
      expect(event.type, equals(PicoEventType.assistantMessage));
      expect(event.id, equals('msg-001'));
      expect(event.content, equals('Hello from AI, updated'));
    });

    test('parses error with errorMessage from payload.message', () {
      final raw = jsonEncode({
        'type': 'error',
        'id': null,
        'payload': {'code': 'AUTH_FAILED', 'message': 'Token invalid'},
      });
      final event = decodePicoFrame(raw);
      expect(event.type, equals(PicoEventType.error));
      expect(event.errorMessage, equals('Token invalid'));
    });

    test('parses pong', () {
      final raw = jsonEncode({'type': 'pong'});
      final event = decodePicoFrame(raw);
      expect(event.type, equals(PicoEventType.pong));
    });

    test('parses typing.start', () {
      final raw = jsonEncode({'type': 'typing.start'});
      final event = decodePicoFrame(raw);
      expect(event.type, equals(PicoEventType.typingStart));
    });

    test('parses typing.stop', () {
      final raw = jsonEncode({'type': 'typing.stop'});
      final event = decodePicoFrame(raw);
      expect(event.type, equals(PicoEventType.typingStop));
    });

    test('returns unknown for malformed JSON', () {
      final event = decodePicoFrame('not valid json {{{}}}');
      expect(event.type, equals(PicoEventType.unknown));
    });

    test('returns unknown for empty string', () {
      final event = decodePicoFrame('');
      expect(event.type, equals(PicoEventType.unknown));
    });

    test('returns unknown for unknown type', () {
      final raw = jsonEncode({'type': 'some.unknown.type'});
      final event = decodePicoFrame(raw);
      expect(event.type, equals(PicoEventType.unknown));
    });
  });
}
