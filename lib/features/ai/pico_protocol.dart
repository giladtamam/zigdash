import 'dart:convert';

/// Encodes a user message as a JSON text frame for the Pico Channel.
String encodeUserMessage(String content) {
  return jsonEncode({
    'type': 'message.send',
    'payload': {
      'content': content,
      'kind': 'text',
    },
  });
}

enum PicoEventType {
  assistantMessage,
  error,
  typingStart,
  typingStop,
  pong,
  unknown,
}

class PicoEvent {
  final PicoEventType type;
  final String? id;
  final String? content;
  final String? errorMessage;

  const PicoEvent({
    required this.type,
    this.id,
    this.content,
    this.errorMessage,
  });

  @override
  String toString() =>
      'PicoEvent(type: $type, id: $id, content: $content, errorMessage: $errorMessage)';
}

/// Decodes a raw JSON string from the Pico Channel WebSocket.
/// Returns [PicoEvent] with type [PicoEventType.unknown] for any malformed input.
PicoEvent decodePicoFrame(String raw) {
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final type = map['type'] as String? ?? '';
    final id = map['id'] as String?;
    final payload = map['payload'] as Map<String, dynamic>?;

    switch (type) {
      case 'message.create':
      case 'message.update':
        final content = payload?['content'] as String?;
        return PicoEvent(
          type: PicoEventType.assistantMessage,
          id: id,
          content: content,
        );
      case 'error':
        final message = payload?['message'] as String?;
        return PicoEvent(
          type: PicoEventType.error,
          errorMessage: message,
        );
      case 'typing.start':
        return const PicoEvent(type: PicoEventType.typingStart);
      case 'typing.stop':
        return const PicoEvent(type: PicoEventType.typingStop);
      case 'pong':
        return const PicoEvent(type: PicoEventType.pong);
      default:
        return const PicoEvent(type: PicoEventType.unknown);
    }
  } catch (_) {
    return const PicoEvent(type: PicoEventType.unknown);
  }
}
