import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/features/support/support_details.dart';

void main() {
  group('addressShape', () {
    test('private ranges', () {
      expect(addressShape('192.168.1.20'), AddressShape.private192);
      expect(addressShape('10.0.0.5'), AddressShape.private10);
      expect(addressShape('172.16.0.1'), AddressShape.private172);
      expect(addressShape('172.31.255.1'), AddressShape.private172);
    });

    test('public addresses, including 172 outside 16–31', () {
      expect(addressShape('8.8.8.8'), AddressShape.publicAddress);
      expect(addressShape('172.32.0.1'), AddressShape.publicAddress);
      expect(addressShape('100.101.102.103'), AddressShape.publicAddress);
    });

    test('.local names and host names', () {
      expect(addressShape('smhub.local'), AddressShape.dotLocal);
      expect(addressShape('SMHUB.LOCAL'), AddressShape.dotLocal);
      expect(addressShape('homeassistant'), AddressShape.hostName);
      expect(addressShape('mqtt.example.com'), AddressShape.hostName);
      expect(addressShape(' 192.168.0.9 '), AddressShape.private192);
    });

    test('labels never contain the address', () {
      for (final s in AddressShape.values) {
        expect(addressShapeLabel(s), isNot(contains('192.168.1')));
      }
      expect(addressShapeLabel(AddressShape.private192),
          'private address in 192.168.x');
    });
  });

  group('failure kinds', () {
    test('from setup errors', () {
      expect(failureKindFromSetup(SetupErrorKind.hostUnreachable),
          FailureKind.unreachable);
      expect(failureKindFromSetup(SetupErrorKind.authRequired),
          FailureKind.loginRequired);
      expect(failureKindFromSetup(SetupErrorKind.noDevices),
          FailureKind.noDevices);
      for (final k in SetupErrorKind.values) {
        expect(() => failureKindFromSetup(k), returnsNormally);
      }
    });

    test('from the diagnostics ladder, by the first failed step', () {
      DiagnosticsReport report(String key) => DiagnosticsReport(
            steps: [
              const StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
              StepResult(
                  step: DiagnosticStep.tcp,
                  status: StepStatus.fail,
                  detailKey: key),
            ],
            connected: false,
            candidatesTried: 1,
          );
      expect(failureKindFromLadder(report('diagResolveFail')),
          FailureKind.hostNotFound);
      expect(failureKindFromLadder(report('diagTcpTimeout')),
          FailureKind.timedOut);
      expect(failureKindFromLadder(report('diagTcpFail')), FailureKind.refused);
      expect(
          failureKindFromLadder(report('diagConnackFail')), FailureKind.notMqtt);
      expect(failureKindFromLadder(report('diagAuthRejected')),
          FailureKind.loginRejected);
      expect(failureKindFromLadder(report('somethingNew')), FailureKind.unknown);
    });

    test('from connect exceptions, never keeping their text', () {
      expect(failureKindFromError(TimeoutException('x')), FailureKind.timedOut);
      expect(
          failureKindFromError(
              const SocketException('Failed host lookup: smhub.local')),
          FailureKind.hostNotFound);
      expect(
          failureKindFromError(const SocketException('Connection refused')),
          FailureKind.refused);
      expect(failureKindFromError(StateError('?')), FailureKind.unknown);
    });

    test('names round-trip for storage', () {
      for (final k in FailureKind.values) {
        expect(FailureKind.values.byName(k.name), k);
        expect(failureKindLabel(k), isNotEmpty);
      }
    });
  });

  group('ScanSummary', () {
    test('json round-trip', () {
      const s = ScanSummary(
          widened: true, hostsTried: 1018, brokersFound: 0, network: 'Wi-Fi');
      expect(ScanSummary.fromJson(s.toJson()), s);
    });

    test('label', () {
      const s = ScanSummary(
          widened: true, hostsTried: 1018, brokersFound: 0, network: 'Wi-Fi');
      expect(s.label, '/24 then /22 · 1,018 hosts tried · 0 brokers · Wi-Fi');
      const t = ScanSummary(widened: false, hostsTried: 254, brokersFound: 1);
      expect(t.label, '/24 · 254 hosts tried · 1 broker');
    });
  });

  group('networkOfInterface', () {
    test('maps interface names to a kind, never the name itself', () {
      expect(networkOfInterface('wlan0'), 'Wi-Fi');
      expect(networkOfInterface('eth0'), 'Ethernet');
      expect(networkOfInterface('en0'), 'Ethernet');
      expect(networkOfInterface('weird9'), 'other');
      expect(networkOfInterface(null), isNull);
    });
  });

  group('SupportDetails.format', () {
    test('full snapshot', () {
      const d = SupportDetails(
        appVersion: '2.0.1',
        build: '31',
        android: '15',
        phone: 'Samsung SM-S721B',
        openedFrom: 'Setup › No connection found',
        connection: ConnectionFacts(
            remote: false,
            protocol: 'TCP',
            port: 1883,
            shape: AddressShape.private192),
        z2m: Z2mFacts(version: '2.6.1', online: true, devices: 14),
        lastFailure: FailureKind.timedOut,
        lastScan: ScanSummary(
            widened: true, hostsTried: 1018, brokersFound: 0, network: 'Wi-Fi'),
      );
      expect(d.format(), '''
ZigDash 2.0.1 (31) · Android 15 · Samsung SM-S721B
Opened from: Setup › No connection found
Connection: local · TCP · port 1883 · private address in 192.168.x
Zigbee2MQTT: 2.6.1 · bridge online · 14 devices
Last error: timed out
Last scan: /24 then /22 · 1,018 hosts tried · 0 brokers · Wi-Fi''');
    });

    test('missing facts read as none or not found', () {
      const d = SupportDetails(
        appVersion: '2.0.1',
        build: '31',
        openedFrom: 'Settings',
      );
      expect(d.format(), '''
ZigDash 2.0.1 (31)
Opened from: Settings
Connection: none
Zigbee2MQTT: not found
Last error: none
Last scan: none''');
    });
  });
}
