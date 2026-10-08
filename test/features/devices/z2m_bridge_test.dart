import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/devices/z2m_bridge.dart';

void main() {
  const base = 'zigbee2mqtt';

  group('permitJoinRequest', () {
    test('enable=true produces correct topic', () {
      final req = permitJoinRequest(base, enable: true);
      expect(req.topic, equals('zigbee2mqtt/bridge/request/permit_join'));
    });

    test('enable=true payload has value:true and time:254', () {
      final req = permitJoinRequest(base, enable: true);
      final payload = jsonDecode(req.payload) as Map<String, dynamic>;
      expect(payload['value'], isTrue);
      expect(payload['time'], equals(254));
    });

    test('enable=true with custom time uses that time', () {
      final req = permitJoinRequest(base, enable: true, time: 60);
      final payload = jsonDecode(req.payload) as Map<String, dynamic>;
      expect(payload['time'], equals(60));
    });

    test('enable=false produces correct topic', () {
      final req = permitJoinRequest(base, enable: false);
      expect(req.topic, equals('zigbee2mqtt/bridge/request/permit_join'));
    });

    test('enable=false sends time:0, which Zigbee2MQTT 2.x requires', () {
      final req = permitJoinRequest(base, enable: false);
      final payload = jsonDecode(req.payload) as Map<String, dynamic>;
      expect(payload['value'], isFalse);
      expect(payload['time'], equals(0));
    });
  });

  group('restartRequest', () {
    test('targets bridge/request/restart under the base topic', () {
      final req = restartRequest(base);
      expect(req.topic, equals('zigbee2mqtt/bridge/request/restart'));
      expect(jsonDecode(req.payload), isA<Map<String, dynamic>>());
    });
  });

  group('renameRequest', () {
    test('produces correct topic', () {
      final req = renameRequest(base, 'old_name', 'new_name');
      expect(req.topic, equals('zigbee2mqtt/bridge/request/device/rename'));
    });

    test('payload has from and to keys with correct values', () {
      final req = renameRequest(base, 'old_name', 'new_name');
      final payload = jsonDecode(req.payload) as Map<String, dynamic>;
      expect(payload['from'], equals('old_name'));
      expect(payload['to'], equals('new_name'));
    });
  });

  group('removeRequest', () {
    test('produces correct topic', () {
      final req = removeRequest(base, 'my_device');
      expect(req.topic, equals('zigbee2mqtt/bridge/request/device/remove'));
    });

    test('payload has id and force:false by default', () {
      final req = removeRequest(base, 'my_device');
      final payload = jsonDecode(req.payload) as Map<String, dynamic>;
      expect(payload['id'], equals('my_device'));
      expect(payload['force'], isFalse);
    });

    test('payload has force:true when specified', () {
      final req = removeRequest(base, 'my_device', force: true);
      final payload = jsonDecode(req.payload) as Map<String, dynamic>;
      expect(payload['force'], isTrue);
    });
  });

  // ---------- bridge event parser ----------

  group('parseBridgeEvent - device_joined', () {
    test('type is deviceJoined', () {
      const raw =
          '{"type":"device_joined","data":{"friendly_name":"0x00158d0001","ieee_address":"0x00158d0001"}}';
      final event = parseBridgeEvent(raw);
      expect(event.type, equals(BridgeEventType.deviceJoined));
    });

    test('friendlyName is extracted', () {
      const raw =
          '{"type":"device_joined","data":{"friendly_name":"0x00158d0001","ieee_address":"0x00158d0001"}}';
      final event = parseBridgeEvent(raw);
      expect(event.friendlyName, equals('0x00158d0001'));
    });

    test('interviewStatus is null for device_joined', () {
      const raw =
          '{"type":"device_joined","data":{"friendly_name":"0x00158d0001","ieee_address":"0x00158d0001"}}';
      final event = parseBridgeEvent(raw);
      expect(event.interviewStatus, isNull);
    });
  });

  group('parseBridgeEvent - device_interview', () {
    test('type is deviceInterview', () {
      const raw =
          '{"type":"device_interview","data":{"friendly_name":"my_sensor","status":"successful"}}';
      final event = parseBridgeEvent(raw);
      expect(event.type, equals(BridgeEventType.deviceInterview));
    });

    test('interviewStatus is successful', () {
      const raw =
          '{"type":"device_interview","data":{"friendly_name":"my_sensor","status":"successful"}}';
      final event = parseBridgeEvent(raw);
      expect(event.interviewStatus, equals('successful'));
    });

    test('interviewStatus is started', () {
      const raw =
          '{"type":"device_interview","data":{"friendly_name":"my_sensor","status":"started"}}';
      final event = parseBridgeEvent(raw);
      expect(event.interviewStatus, equals('started'));
    });

    test('interviewStatus is failed', () {
      const raw =
          '{"type":"device_interview","data":{"friendly_name":"my_sensor","status":"failed"}}';
      final event = parseBridgeEvent(raw);
      expect(event.interviewStatus, equals('failed'));
    });
  });

  group('parseBridgeEvent - device_leave', () {
    test('type is deviceLeave', () {
      const raw =
          '{"type":"device_leave","data":{"friendly_name":"my_sensor"}}';
      final event = parseBridgeEvent(raw);
      expect(event.type, equals(BridgeEventType.deviceLeave));
    });

    test('friendlyName extracted for device_leave', () {
      const raw =
          '{"type":"device_leave","data":{"friendly_name":"my_sensor"}}';
      final event = parseBridgeEvent(raw);
      expect(event.friendlyName, equals('my_sensor'));
    });
  });

  group('parseBridgeEvent - device_announce', () {
    test('type is deviceAnnounce', () {
      const raw =
          '{"type":"device_announce","data":{"friendly_name":"lamp_1"}}';
      final event = parseBridgeEvent(raw);
      expect(event.type, equals(BridgeEventType.deviceAnnounce));
    });
  });

  group('parseBridgeEvent - malformed / unknown', () {
    test('malformed JSON returns unknown type', () {
      final event = parseBridgeEvent('{not valid json}');
      expect(event.type, equals(BridgeEventType.unknown));
    });

    test('malformed JSON friendlyName is null', () {
      final event = parseBridgeEvent('{not valid json}');
      expect(event.friendlyName, isNull);
    });

    test('unknown type string returns unknown', () {
      const raw = '{"type":"something_new","data":{"friendly_name":"x"}}';
      final event = parseBridgeEvent(raw);
      expect(event.type, equals(BridgeEventType.unknown));
    });
  });
}
