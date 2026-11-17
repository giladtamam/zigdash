import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/database.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/ha_import/ha_import_screen.dart';
import 'package:zigdash/mqtt/ha_address.dart';

Connection _home(String host, {ConnectionTransport? transport}) => Connection(
  transport: transport,
  id: 'c1',
  name: 'Home',
  host: host,
  port: 1883,
  protocol: MqttProtocol.tcp,
  keepAliveSeconds: 60,
  autoConnect: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  // 3.8.1: a home reached through Home Assistant keeps its full address; the
  // import appended :8123 to it and never found Home Assistant.
  group('a home reached through Home Assistant', () {
    for (final (stored, base) in [
      ('http://192.168.1.20:8123', Uri.parse('http://192.168.1.20:8123')),
      ('http://192.168.1.20', Uri.parse('http://192.168.1.20')),
      ('https://abc.ui.nabu.casa', Uri.parse('https://abc.ui.nabu.casa')),
    ]) {
      test('$stored is used as it is', () {
        final home = _home(
          stored,
          transport: ConnectionTransport.homeAssistant,
        );
        final address = haImportAddressOf(home);
        expect(address, stored);
        expect(haBaseCandidates(address), [base]);
      });
    }
  });

  test('a broker home: Home Assistant on the same machine, 8123', () {
    for (final transport in [null, ConnectionTransport.mqtt]) {
      final address = haImportAddressOf(
        _home('192.168.1.20', transport: transport),
      );
      expect(address, '192.168.1.20:8123');
      expect(haBaseUri(address), Uri.parse('http://192.168.1.20:8123'));
    }
  });
}
