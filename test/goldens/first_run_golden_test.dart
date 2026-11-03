import 'package:alchemist/alchemist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/connections/discovery/broker_scan_service.dart';
import 'package:zigdash/features/connections/discovery/hub_probe.dart';
import 'package:zigdash/features/onboarding/setup/recommendation_policy.dart';
import 'package:zigdash/features/onboarding/setup/setup_candidate.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/features/onboarding/setup/setup_providers.dart';
import 'package:zigdash/core/analytics/analytics_events.dart';
import 'package:zigdash/features/onboarding/setup/setup_screen.dart';
import 'package:zigdash/mqtt/broker_config.dart';

import 'golden_harness.dart';

// Phase 1 exit criterion (docs/design/phasing.md): goldens for every
// first-run outcome, in the interim look.

const _haHub = HubFound(
  kind: HubKind.homeAssistant,
  host: '192.168.1.20',
  port: 8123,
);
const _z2mHub = HubFound(
  kind: HubKind.zigbee2mqtt,
  host: '192.168.1.30',
  port: 8080,
);
const _hub = SetupCandidate(
  host: '192.168.68.55',
  port: 1883,
  protocol: MqttProtocol.tcp,
);
const _other = SetupCandidate(
  host: '192.168.1.20',
  port: 1883,
  protocol: MqttProtocol.tcp,
);

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
  // 2.7.1: the cards say what their machine is when the scan could tell.
  'several_found': const SetupScanning(
    [_hub, _other],
    done: true,
    kinds: {'192.168.68.55': HubKind.homeAssistant},
  ),
  // 2.5: progress, the platform question and a hub seen while scanning.
  'scanning': const SetupScanning(
    [],
    progress: (checked: 400, total: 1526),
    platform: SetupPlatform.homeAssistant,
    hubs: [_haHub],
  ),
  'nothing_found': const SetupScanEmpty(),
  // 2.8.1: almost nothing answered: a guest Wi-Fi or client isolation.
  'nothing_found_isolated': const SetupScanEmpty(
    tried: (widened: true, hostsTried: 1018, aliveHosts: 3, lateHosts: 0),
  ),
  // 2.5: Home Assistant answered but no broker did.
  'hub_no_broker': const SetupScanEmpty(hubs: [_haHub]),
  // 2.7.2: Zigbee2MQTT said where its broker is, and it listens only there.
  'z2m_local_only': const SetupScanEmpty(
    hubs: [_z2mHub],
    z2m: (status: Z2mAnswerStatus.localOnly, server: 'mqtt://localhost:1883'),
  ),
  // 3.3.2: the empty result as a guide, by answer.
  'guide_pi': const SetupScanEmpty(
    platform: SetupPlatform.piOrDocker,
    tried: (widened: false, hostsTried: 254, aliveHosts: 24, lateHosts: 0),
  ),
  'guide_ha': const SetupScanEmpty(platform: SetupPlatform.homeAssistant),
  'guide_help': const SetupScanEmpty(platform: SetupPlatform.homeAssistant),
  'needs_login': const SetupNeedsAuth(_hub),
  // 2.7.1: after a rejected login, where a working login surely is.
  'login_rejected': const SetupNeedsAuth(
    _hub,
    rejected: true,
    platform: SetupPlatform.homeAssistant,
  ),
  'no_zigbee2mqtt': const SetupFailed(
    SetupErrorKind.notZigbee2Mqtt,
    candidate: _hub,
  ),
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
  }) => throw UnimplementedError();
}

class _NoStore implements SetupStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// The guide's progress for outcomes that show a later step (3.3.2).
final _guide = <String, GuideProgress>{
  'guide_help': const GuideProgress(
    passed: {GuideRung.homeAssistant, GuideRung.address},
  ),
};

List<Override> Function() _overridesFor(String name, SetupState state) =>
    () => [
      if (_guide[name] case final g?)
        setupGuideProvider.overrideWith((ref) => g),
      setupStateProvider.overrideWith((ref) => Stream.value(state)),
      setupCoordinatorProvider.overrideWith(
        (ref) => SetupCoordinator(
          scan: (_, __) =>
              ScanRun(events: const Stream.empty(), addHub: (_) {}),
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
          overrides: _overridesFor(entry.key, entry.value),
          screen: () => const SetupScreen(),
        ),
      );
    }
  });
}
