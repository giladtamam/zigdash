import 'dart:async';
import 'dart:io';

/// Why a connection attempt failed, as a fixed kind. Support details and
/// analytics use this instead of the error text, which carries the broker's
/// host and port (docs/design/support.md §4).
enum FailureKind {
  unreachable,
  timedOut,
  refused,
  hostNotFound,
  loginRequired,
  loginRejected,
  notMqtt,
  noZigbee2mqtt,
  noDevices,
  noLocalNetwork,
  saveFailed,

  /// The broker's TLS certificate isn't trusted by the phone: self-signed,
  /// expired, or made for another name (3.8.5).
  tlsUntrusted,

  /// The TLS handshake failed for another reason, such as a broker that
  /// wants a client certificate (3.8.5).
  tlsFailed,
  unknown,
}

/// The kind of a connect error, keeping nothing of its message.
FailureKind failureKindFromError(Object error) {
  if (error is TimeoutException) return FailureKind.timedOut;
  if (error is SocketException) {
    return error.message.contains('host lookup') ||
            (error.osError?.message.contains('host lookup') ?? false)
        ? FailureKind.hostNotFound
        : FailureKind.refused;
  }
  return FailureKind.unknown;
}

/// Whether a connect error is a failed TLS handshake (3.8.5): the
/// HandshakeException mqtt_client passes on as it is, or, should it wrap
/// one, its own exception saying so. Only the kind is kept.
bool isTlsFailure(Object? error) {
  if (error is TlsException) return true;
  if (error is! Exception) return false;
  final m = error.toString().toLowerCase();
  return m.contains('handshake exception') || m.contains('tls exception');
}

/// The kind of a connect error from its message, for errors a client
/// library wraps (mqtt_client puts the socket error inside its own
/// NoConnectionException). Only the kind survives, never the text.
FailureKind failureKindFromMessage(String message) {
  final m = message.toLowerCase();
  if (m.contains('host lookup')) return FailureKind.hostNotFound;
  if (m.contains('refused')) return FailureKind.refused;
  if (m.contains('timed out')) return FailureKind.timedOut;
  if (m.contains('acknowledgement') || m.contains('return code')) {
    return FailureKind.notMqtt;
  }
  if (m.contains('could not be made') ||
      m.contains('unreachable') ||
      m.contains('no route')) {
    return FailureKind.unreachable;
  }
  return FailureKind.unknown;
}

/// Short English label for Support details.
String failureKindLabel(FailureKind kind) => switch (kind) {
      FailureKind.unreachable => "can't reach the address",
      FailureKind.timedOut => 'timed out',
      FailureKind.refused => 'nothing answers on the port',
      FailureKind.hostNotFound => 'host name not found',
      FailureKind.loginRequired => 'login required',
      FailureKind.loginRejected => 'login rejected',
      FailureKind.notMqtt => 'not an MQTT broker',
      FailureKind.noZigbee2mqtt => 'no Zigbee2MQTT on this broker',
      FailureKind.noDevices => 'no devices received',
      FailureKind.noLocalNetwork => 'no local network',
      FailureKind.saveFailed => "couldn't save",
      FailureKind.tlsUntrusted => 'certificate not trusted',
      FailureKind.tlsFailed => 'encrypted connection failed',
      FailureKind.unknown => 'unknown',
    };
