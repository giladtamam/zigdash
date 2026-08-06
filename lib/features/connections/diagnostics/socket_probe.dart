import 'socket_probe_io.dart'
    if (dart.library.html) 'socket_probe_stub.dart' as impl;

/// Resolves [host] to one or more addresses; throws when it cannot.
///
/// Default implementation is dart:io DNS; on web (no raw sockets) it passes
/// through — the ws/wss MQTT client resolves the host itself.
Future<List<String>> defaultHostLookup(String host) => impl.hostLookup(host);

/// Opens (and closes) a TCP connection to [host]:[port]; throws when it cannot
/// within [timeout]. On web this is unsupported and throws [UnsupportedError],
/// which the ladder reports as a skipped step.
Future<void> defaultTcpProbe(String host, int port, Duration timeout) =>
    impl.tcpProbe(host, port, timeout);
