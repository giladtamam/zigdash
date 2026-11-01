import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/endpoint.dart';
import 'package:zigdash/remote/remote_home.dart';
import 'package:zigdash/remote/remote_seal.dart';

/// Runs [js] with ZigDash Engine's helpers as `H` and returns its stdout.
Future<String> node(String js) async {
  final r = await Process.run('node', ['-e', 'const H = require("./hub/zigdash-engine.js").helpers; $js']);
  if (r.exitCode != 0) throw StateError('${r.stderr}');
  return (r.stdout as String).trim();
}

final hasNode = Process.runSync('which', ['node']).exitCode == 0;

void main() {
  final key = RemoteSeal.newKey();
  final keyB64 = base64.encode(key);

  test('a seal round-trips and a wrong key opens nothing', () {
    final sealed = RemoteSeal.seal(key, {'topic': 'zigbee2mqtt/מנורה', 'payload': '{"state":"ON"}', 'at': 1});
    expect(RemoteSeal.unseal(key, sealed)!['topic'], 'zigbee2mqtt/מנורה');
    expect(RemoteSeal.unseal(RemoteSeal.newKey(), sealed), isNull);
    expect(RemoteSeal.unseal(key, Uint8List.fromList(utf8.encode('{"topic":"x"}'))), isNull);
  });

  test('the phone opens what ZigDash Engine sealed', () async {
    final b64 = await node(
        'process.stdout.write(H.seal(Buffer.from("$keyB64","base64"), {topic:"zigbee2mqtt/Kitchen lamp", payload:"{\\"state\\":\\"ON\\"}", at: 5}).toString("base64"))');
    final inner = RemoteSeal.unseal(key, base64.decode(b64));
    expect(inner, {'topic': 'zigbee2mqtt/Kitchen lamp', 'payload': '{"state":"ON"}', 'at': 5});
  }, skip: hasNode ? false : 'node not installed');

  test('ZigDash Engine opens what the phone sealed, and both compute the same opaque id', () async {
    final sealed = base64.encode(RemoteSeal.seal(key, {'topic': 'zigbee2mqtt/תריס משרד/set', 'payload': '{"state":"CLOSE"}', 'at': 7}));
    final out = await node(
        'const k=Buffer.from("$keyB64","base64"); process.stdout.write(JSON.stringify([H.unseal(k, Buffer.from("$sealed","base64")), H.opaqueId(k, "zigbee2mqtt/Kitchen lamp")]))');
    final j = jsonDecode(out) as List;
    expect(j[0], {'topic': 'zigbee2mqtt/תריס משרד/set', 'payload': '{"state":"CLOSE"}', 'at': 7});
    expect(j[1], RemoteSeal.opaqueId(key, 'zigbee2mqtt/Kitchen lamp'));
  }, skip: hasNode ? false : 'node not installed');

  test('the relay is the last endpoint, after the broker\'s own addresses', () {
    final relay = RemoteHome(homeId: 'h1', url: 'wss://relay.example/mqtt', username: 'u', password: 'p', key: key);
    final plain = endpointCandidates(const BrokerConfig(id: 'c', host: '192.168.1.5', port: 1883, protocol: MqttProtocol.tcp));
    expect(plain.map((c) => c.kind), [MqttEndpoint.local]);
    final withRelay = endpointCandidates(BrokerConfig(id: 'c', host: '192.168.1.5', port: 1883, protocol: MqttProtocol.tcp, relay: relay));
    expect(withRelay.map((c) => c.kind), [MqttEndpoint.local, MqttEndpoint.relay]);
    expect(withRelay.first.timeoutMs, standardConnectTimeoutMs, reason: 'at home the broker keeps its full budget');
    final loginRelay = endpointCandidates(BrokerConfig(id: 'c', host: '192.168.1.5', port: 1883, protocol: MqttProtocol.tcp, username: 'mqtt', relay: relay));
    expect(loginRelay.first.timeoutMs, standardConnectTimeoutMs, reason: 'away, a login does not hold up the relay');
    expect(withRelay.last.host, relayCandidateHost);
    final both = endpointCandidates(BrokerConfig(id: 'c', host: 'a', port: 1883, protocol: MqttProtocol.tcp, remoteHost: 'b', relay: relay));
    expect(both.map((c) => c.kind), [MqttEndpoint.local, MqttEndpoint.remote, MqttEndpoint.relay]);
  });
}
