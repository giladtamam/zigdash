import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/alerts/node_red_installer.dart';

void main() {
  final flow = File('node-red/alerts-flow.json').readAsStringSync();

  test("the tab for Node-RED's API carries the Home's broker and base topic",
      () {
    final tab = NodeRedInstaller.tabFor(flow,
        brokerHost: '192.168.1.9',
        brokerPort: 1884,
        username: 'zig',
        baseTopic: 'z2m');
    expect(tab['label'], NodeRedInstaller.tabLabel);
    final configs = (tab['configs'] as List).cast<Map>();
    expect(configs.single['type'], 'mqtt-broker');
    expect(configs.single['broker'], '192.168.1.9');
    expect(configs.single['port'], '1884');
    expect(configs.single['credentials'], {'user': 'zig'});
    expect(configs.single.containsKey('password'), isFalse);
    final nodes = (tab['nodes'] as List).cast<Map>();
    expect(nodes.any((n) => n['type'] == 'tab'), isFalse);
    expect(nodes.every((n) => !n.containsKey('z')), isTrue);
    final devices = nodes.singleWhere((n) => n['name'] == 'devices');
    expect(devices['topic'], 'z2m/#');
    expect(nodes.where((n) => n['type'] == 'function').length, 7);
  });

  test('no username: no credentials on the broker node', () {
    final tab = NodeRedInstaller.tabFor(flow,
        brokerHost: 'h', brokerPort: 1883, baseTopic: 'zigbee2mqtt');
    expect((tab['configs'] as List).cast<Map>().single.containsKey('credentials'), isFalse);
  });

  test('nothing on port 1880 means Node-RED is not installed', () async {
    final r = await NodeRedInstaller(host: '127.0.0.1', port: 1, flowJson: () async => flow)
        .install(brokerHost: 'h', brokerPort: 1883, baseTopic: 'zigbee2mqtt');
    expect(r, NodeRedInstall.notInstalled);
  });
}
