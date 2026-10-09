import 'package:alchemist/alchemist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/onboarding/setup/recommendation_policy.dart';
import 'package:zigdash/features/onboarding/setup/setup_candidate.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/features/onboarding/setup/setup_providers.dart';
import 'package:zigdash/features/onboarding/setup/setup_screen.dart';
import 'package:zigdash/mqtt/broker_config.dart';

import 'golden_harness.dart';

// Phase 1 exit criterion (docs/design/phasing.md): goldens for every
// first-run outcome, in the interim look.

const _hub = SetupCandidate(
    host: '192.168.68.55', port: 1883, protocol: MqttProtocol.tcp);
const _other = SetupCandidate(
    host: '192.168.1.20', port: 1883, protocol: MqttProtocol.tcp);

final _review = SetupReview(
  _hub,
  recommendDevices(const [
    Z2mDevice(
      friendlyName: 'Living room bulb',
      type: 'Router',
      vendor: 'Tuya',
      model: 'CK-BL702-AL-01',
      exposes: [Z2mExpose(type: 'light')],
    ),
    Z2mDevice(
      friendlyName: 'Kitchen switch',
      type: 'Router',
      vendor: 'SONOFF',
      model: 'MINI-ZBD',
      exposes: [Z2mExpose(type: 'switch')],
    ),
    Z2mDevice(
      friendlyName: 'Hallway sensor',
      type: 'EndDevice',
      vendor: 'Aqara',
      model: 'WSDCGQ11LM',
      exposes: [Z2mExpose(type: 'numeric', property: 'temperature')],
    ),
    Z2mDevice(friendlyName: 'Mystery box', type: 'EndDevice', supported: false),
  ]),
);

final _outcomes = <String, SetupState>{
  'welcome': const SetupIdle(),
  'several_found': const SetupScanning([_hub, _other], done: true),
  'nothing_found': const SetupScanEmpty(),
  'needs_login': const SetupNeedsAuth(_hub),
  'no_zigbee2mqtt':
      const SetupFailed(SetupErrorKind.notZigbee2Mqtt, candidate: _hub),
  'review': _review,
  'saving': SetupCreating(_review),
};

/// Four cells per outcome: light, dark, Hebrew, and 2x text.
final _matrix = [
  phoneMatrix[0], // light en
  phoneMatrix[1], // dark en
  phoneMatrix[2], // light he
  phoneMatrix[4], // light en 2x
];

class _NoDiagnostics extends ConnectDiagnostics {
  @override
  Future<DiagnosticsReport> run({
    required BrokerConfig config,
    required String password,
    String base = 'zigbee2mqtt',
  }) =>
      throw UnimplementedError();
}

class _NoStore implements SetupStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

List<Override> Function() _overridesFor(SetupState state) => () => [
      setupStateProvider.overrideWith((ref) => Stream.value(state)),
      setupCoordinatorProvider.overrideWith(
        (ref) => SetupCoordinator(
          scan: (_) => const Stream.empty(),
          deviceIp: () async => null,
          diagnostics: _NoDiagnostics(),
          fetchDevices: (_, __, ___) async =>
              const Z2mFetchResult(detected: false, devices: []),
          creator: _NoStore(),
        ),
      ),
    ];

void main() {
  group('first run', () {
    for (final entry in _outcomes.entries) {
      goldenTest(
        entry.key,
        fileName: 'first_run_${entry.key}',
        // The saving spinner never settles; a fixed pump is deterministic.
        pumpBeforeTest: pumpNTimes(6, const Duration(milliseconds: 50)),
        builder: () => goldenMatrix(
          variants: _matrix,
          overrides: _overridesFor(entry.value),
          screen: () => const SetupScreen(),
        ),
      );
    }
  });
}
