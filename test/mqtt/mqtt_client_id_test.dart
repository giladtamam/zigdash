import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/mqtt_manager.dart';

void main() {
  const config = BrokerConfig(
    id: '3f2a9c1e-7b4d-4e8a-9c0f-1a2b3c4d5e6f',
    host: '192.168.1.20',
    port: 1883,
    protocol: MqttProtocol.tcp,
  );

  group('MQTT client id', () {
    test('fits MQTT 3.1 and keeps the zd- prefix and connection tail', () {
      final m = MqttManager(config: config, password: '');
      addTearDown(m.dispose);
      expect(m.clientId.length, lessThanOrEqualTo(23));
      expect(m.clientId, matches(RegExp(r'^zd-[0-9a-f]{18}$')));
      expect(m.clientId.substring(3, 13), '1a2b3c4d5e6f'.substring(2));
    });

    // Regression: two installs holding the same connection row (Android Auto
    // Backup restored on a second device, or two web tabs) sent the same id,
    // so the broker kept dropping one for the other in an endless loop.
    test('differs between two managers for the same connection', () {
      final ids = <String>{};
      for (var i = 0; i < 20; i++) {
        final m = MqttManager(config: config, password: '');
        ids.add(m.clientId);
        m.dispose();
      }
      expect(ids, hasLength(20));
    });

    test('override still wins', () {
      final m = MqttManager(
        config: config,
        password: '',
        clientIdOverride: 'fixed-id',
      );
      addTearDown(m.dispose);
      expect(m.clientId, 'fixed-id');
    });
  });
}
