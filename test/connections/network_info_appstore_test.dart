// Run with --dart-define=ZIGDASH_FLAVOR=appstore (the App Store build); the
// usual run checks only that nothing changed elsewhere.
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/connections/discovery/network_info_io.dart';

const _apple = String.fromEnvironment('ZIGDASH_FLAVOR') == 'appstore';

void main() {
  // Build 97: App Review read the tunnel-interface check as VPN
  // functionality, so the App Store build never lists tunnels.
  test('App Store build: no VPN check, only en* is home', () async {
    expect(await vpnActive(), isFalse);
    final picked = pickHomeAddress([
      (name: 'utun3', ip: '10.8.0.2'),
      (name: 'pdp_ip0', ip: '10.20.30.40'),
      (name: 'en0', ip: '192.168.1.23'),
    ]);
    expect(picked?.name, 'en0');
    expect(
      pickHomeAddress([(name: 'pdp_ip0', ip: '10.20.30.40')]),
      isNull,
    );
  }, skip: !_apple);
}
