import 'dart:async';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'pico_protocol.dart';

/// Connection state for [PicoClient].
enum PicoConnectionState { disconnected, connecting, connected, error }

/// A WebSocket client for the PicoClaw "Pico Channel".
///
/// Usage:
/// ```dart
/// final client = PicoClient(host: '...', port: 18790, path: '/pico/ws', token: '...');
/// client.connect();
/// client.events.listen((event) { ... });
/// client.send('Hello!');
/// client.dispose();
/// ```
class PicoClient {
  PicoClient({
    required this.host,
    required this.port,
    required this.path,
    required this.token,
  });

  final String host;
  final int port;
  final String path;
  final String token;

  final _eventController = StreamController<PicoEvent>.broadcast();
  final _stateController = StreamController<PicoConnectionState>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  /// Broadcast stream of decoded [PicoEvent]s from the server.
  Stream<PicoEvent> get events => _eventController.stream;

  /// Broadcast stream of connection state changes.
  Stream<PicoConnectionState> get connectionState$ => _stateController.stream;

  PicoConnectionState _state = PicoConnectionState.disconnected;
  PicoConnectionState get state => _state;

  void _setState(PicoConnectionState s) {
    _state = s;
    if (!_stateController.isClosed) _stateController.add(s);
  }

  /// Connects to the Pico Channel WebSocket with Bearer token auth.
  void connect() {
    if (_state == PicoConnectionState.connected ||
        _state == PicoConnectionState.connecting) {
      return;
    }
    _setState(PicoConnectionState.connecting);

    try {
      final uri = Uri.parse('ws://$host:$port$path');
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      _subscription = _channel!.stream.listen(
        (raw) {
          if (_state != PicoConnectionState.connected) {
            _setState(PicoConnectionState.connected);
          }
          if (_eventController.isClosed) return;
          if (raw is String) {
            final event = decodePicoFrame(raw);
            _eventController.add(event);
          }
        },
        onError: (Object err) {
          _setState(PicoConnectionState.error);
          if (!_eventController.isClosed) {
            _eventController.add(PicoEvent(
              type: PicoEventType.error,
              errorMessage: err.toString(),
            ));
          }
        },
        onDone: () {
          if (_state != PicoConnectionState.error) {
            _setState(PicoConnectionState.disconnected);
          }
          if (!_eventController.isClosed) {
            _eventController.add(const PicoEvent(
              type: PicoEventType.error,
              errorMessage: 'Connection closed',
            ));
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      _setState(PicoConnectionState.error);
      if (!_eventController.isClosed) {
        _eventController.add(PicoEvent(
          type: PicoEventType.error,
          errorMessage: 'Failed to connect: $e',
        ));
      }
    }
  }

  /// Sends a user message to the Pico Channel.
  void send(String content) {
    _channel?.sink.add(encodeUserMessage(content));
  }

  /// Closes the connection and releases resources.
  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    _stateController.close();
    _eventController.close();
  }
}
