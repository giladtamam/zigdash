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
      FailureKind.unknown => 'unknown',
    };
