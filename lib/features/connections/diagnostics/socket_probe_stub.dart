// Web has no raw sockets or DNS — the ws/wss MQTT client handles resolution
// itself. Resolve passes through; the tcp step reports skipped (the ladder
// then relies on the client factory's connack step to judge reachability).

Future<List<String>> hostLookup(String host) async => [host];

Future<void> tcpProbe(String host, int port, Duration timeout) async {
  throw UnsupportedError('raw TCP probing is unavailable on web');
}
