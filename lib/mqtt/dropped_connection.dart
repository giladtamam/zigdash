import 'package:flutter/foundation.dart' show debugPrint;

// The check needs dart:io, which the web build doesn't have.
import 'dropped_connection_io.dart'
    if (dart.library.js_interop) 'dropped_connection_web.dart' as platform;

/// Whether an uncaught [error] is the broker connection's socket dying.
///
/// When Android cuts a backgrounded app's network (or Wi-Fi drops), a write
/// to the dead socket fails on the socket's `done` future, which mqtt_client
/// never listens to, so the error surfaces as uncaught. MqttManager already
/// notices the lost connection and reconnects; nothing else needs doing.
bool isDroppedConnection(Object error) => platform.isDroppedConnection(error);

/// Swallows dropped-connection errors that escaped mqtt_client, and lets
/// every other uncaught error through ([PlatformDispatcher.onError]).
bool ignoreDroppedConnection(Object error, StackTrace stack) {
  if (!isDroppedConnection(error)) return false;
  debugPrint('broker connection dropped: $error');
  return true;
}
