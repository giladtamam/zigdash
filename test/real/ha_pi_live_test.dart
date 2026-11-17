// The setup side of connecting through Home Assistant, against a real one.
// Runs only when ~/.ha_pi_token exists (a long-lived token or
// refresh:<token> for the Home Assistant at HA_PI_URL, default the Pi);
// the token is read and never printed.
//
//   flutter test test/real/ha_pi_live_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/onboarding/setup/ha_connect.dart';
import 'package:zigdash/features/onboarding/setup/z2m_probe.dart';
import 'package:zigdash/mqtt/broker_config.dart';
import 'package:zigdash/mqtt/ha_address.dart';

void main() {
  final tokenFile = File('${Platform.environment['HOME']}/.ha_pi_token');
  final url = Platform.environment['HA_PI_URL'] ?? 'http://192.168.68.52:8123';

  test(
    'the connect check passes and devices are read through Home Assistant',
    () async {
      HttpOverrides.global = null;
      final base = haBaseUri(url)!;
      final stored = tokenFile.readAsStringSync().trim();
      final sw = Stopwatch()..start();
      final (:problem, facts: _) = await probeHomeAssistant(base, stored);
      // ignore: avoid_print
      print('probe: ${problem ?? 'usable'} in ${sw.elapsedMilliseconds} ms');
      expect(problem, isNull);

      sw.reset();
      final fetch = await Z2mProbeFetcher().fetch(
        BrokerConfig(
          id: 'check',
          host: haAddressText(base),
          port: base.port,
          protocol: base.scheme == 'https' ? MqttProtocol.wss : MqttProtocol.ws,
          transport: ConnectionTransport.homeAssistant,
        ),
        stored,
        'zigbee2mqtt',
      );
      // ignore: avoid_print
      print(
        'devices: detected ${fetch.detected}, ${fetch.devices.length} '
        'devices, other bases ${fetch.otherBases} in ${sw.elapsedMilliseconds} ms',
      );
      expect(fetch.detected, isTrue);
    },
    skip: tokenFile.existsSync() ? false : 'no ~/.ha_pi_token',
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
