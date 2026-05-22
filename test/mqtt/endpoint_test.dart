import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/endpoint.dart';

BrokerConfig _cfg({String? remoteHost}) => BrokerConfig(
      id: 'x',
      host: '192.168.7.210',
      port: 1883,
      protocol: MqttProtocol.tcp,
      remoteHost: remoteHost,
    );

void main() {
  test('no remote host -> single local candidate with standard timeout', () {
    final c = endpointCandidates(_cfg());
    expect(c.length, 1);
    expect(c[0].kind, MqttEndpoint.local);
    expect(c[0].host, '192.168.7.210');
    expect(c[0].timeoutMs, standardConnectTimeoutMs);
  });

  test('remote host -> local first (short timeout) then remote (standard)', () {
    final c = endpointCandidates(_cfg(remoteHost: 'smhub.tailnet.ts.net'));
    expect(c.map((e) => e.kind).toList(), [MqttEndpoint.local, MqttEndpoint.remote]);
    expect(c[0].host, '192.168.7.210');
    expect(c[0].timeoutMs, localProbeTimeoutMs);
    expect(c[1].host, 'smhub.tailnet.ts.net');
    expect(c[1].timeoutMs, standardConnectTimeoutMs);
  });

  test('whitespace-only remote host is treated as none', () {
    final c = endpointCandidates(_cfg(remoteHost: '   '));
    expect(c.length, 1);
    expect(c[0].kind, MqttEndpoint.local);
  });
}
