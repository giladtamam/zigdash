import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/devices/device_profile.dart';
import 'package:zigdash/shortcuts/ios_widgets.dart';

final _lamp = classifyExposes([
  {
    'type': 'light',
    'features': [
      {
        'type': 'binary', 'name': 'state', 'property': 'state',
        'value_on': 'ON', 'value_off': 'OFF', 'value_toggle': 'TOGGLE',
        'access': 7
      },
    ]
  }
]);

final _shutter = classifyExposes([
  {
    'type': 'cover',
    'features': [
      {
        'type': 'enum', 'name': 'state', 'property': 'state',
        'values': ['OPEN', 'CLOSE', 'STOP'], 'access': 7
      },
      {'type': 'numeric', 'name': 'position', 'property': 'position', 'access': 7},
    ]
  }
]);

Map<String, Object?> _device(DeviceProfile p) => iosWidgetDevice(
      connectionId: 'home',
      home: 'My Home',
      ieee: '0x1',
      name: 'Lamp',
      publishTopic: 'zigbee2mqtt/Lamp/set',
      subscribeTopic: 'zigbee2mqtt/Lamp',
      profile: p,
    );

Connection _conn({MqttProtocol protocol = MqttProtocol.tcp, ConnectionTransport? transport}) =>
    Connection(
      id: 'home',
      name: 'My Home',
      host: '192.168.68.64',
      port: 1883,
      protocol: protocol,
      keepAliveSeconds: 60,
      autoConnect: true,
      transport: transport,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  test('a light carries the payloads a tap sends', () {
    final d = _device(_lamp);
    expect(d['kind'], 'switch');
    expect(d['pub'], 'zigbee2mqtt/Lamp/set');
    expect(d['on'], {'state': 'ON'});
    expect(d['off'], {'state': 'OFF'});
    expect(d['toggle'], {'state': 'TOGGLE'});
    expect(d['onValue'], 'ON');
    // Swift decodes it back as plain JSON.
    expect(jsonDecode(jsonEncode(d)), isA<Map<String, Object?>>());
  });

  test('a shutter carries open, stop, close and its position', () {
    final d = _device(_shutter);
    expect(d['kind'], 'cover');
    expect(d['open'], {'state': 'OPEN'});
    expect(d['stop'], {'state': 'STOP'});
    expect(d['close'], {'state': 'CLOSE'});
    expect(d['positionProperty'], 'position');
    expect(d.containsKey('toggle'), isFalse);
  });

  test('only plain MQTT Homes are reached from a widget', () {
    final mqtt = iosWidgetHome(_conn());
    expect(mqtt['direct'], isTrue);
    expect(mqtt['host'], '192.168.68.64');
    expect(mqtt['tls'], isFalse);
    expect(iosWidgetHome(_conn(protocol: MqttProtocol.tcpSsl))['tls'], isTrue);
    expect(iosWidgetHome(_conn(protocol: MqttProtocol.wss))['direct'], isFalse);
    final ha = iosWidgetHome(_conn(transport: ConnectionTransport.homeAssistant));
    expect(ha['direct'], isFalse);
    expect(ha.containsKey('host'), isFalse);
  });
}
