import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../discovery/hub_probe.dart';
import '../discovery/hub_prober.dart';
import '../discovery/z2m_frontend.dart';
import '../discovery/z2m_frontend_fetch.dart';
import 'connect_diagnostics.dart';

/// Provider the guided-connect wizard and the connection form read; tests
/// override it with a [ConnectDiagnostics] built on fakes. Lives in its own
/// file so [ConnectDiagnostics] itself stays Flutter-free (the `bin/` smoke
/// harness runs it on the pure Dart VM).
final connectDiagnosticsProvider = Provider<ConnectDiagnostics>(
  (ref) => ConnectDiagnostics(
    identify: (host) => identifyHost(createHubProber(), host),
    askZ2m: (host, port) async => z2mBrokerSetting(
      await fetchZ2mMqttConfig(host, port),
      frontendHost: host,
    ),
  ),
);

/// Reads the `mqtt` settings from Zigbee2MQTT's web page (3.8.6): the
/// connection form pre-fills a page Home's broker from them. Tests
/// override it.
typedef Z2mPageConfigFetch =
    Future<Map<String, dynamic>?> Function(
      String host,
      int port, {
      String? token,
    });

final z2mPageConfigProvider = Provider<Z2mPageConfigFetch>(
  (ref) =>
      (host, port, {token}) => fetchZ2mMqttConfig(host, port, token: token),
);
