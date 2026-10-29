import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/core/analytics/analytics_events.dart' show SetupVia;
import 'package:zigdash/data/database/tables/connections.dart';
import 'package:zigdash/features/connections/diagnostics/connect_diagnostics.dart';
import 'package:zigdash/features/connections/discovery/address_check.dart';
import 'package:zigdash/features/connections/discovery/broker_probe.dart';
import 'package:zigdash/features/connections/discovery/broker_scan_service.dart';
import 'package:zigdash/features/connections/discovery/hub_probe.dart';
import 'package:zigdash/features/connections/discovery/no_network.dart';
import 'package:zigdash/features/connections/discovery/z2m_frontend.dart';
import 'package:zigdash/features/discovery/models/z2m_device.dart';
import 'package:zigdash/features/onboarding/setup/recommendation_policy.dart';
import 'package:zigdash/features/onboarding/setup/setup_candidate.dart';
import 'package:zigdash/features/onboarding/setup/setup_coordinator.dart';
import 'package:zigdash/features/onboarding/setup/setup_creator.dart';
import 'package:zigdash/features/onboarding/setup/setup_error_guidance.dart';
import 'package:zigdash/mqtt/broker_config.dart';

const _lamp = Z2mDevice(
  friendlyName: 'lamp',
  type: 'EndDevice',
  exposes: [Z2mExpose(type: 'light')],
);
const _plug = Z2mDevice(
  friendlyName: 'plug',
  type: 'EndDevice',
  exposes: [Z2mExpose(type: 'switch')],
);

class _FakeDiagnostics extends ConnectDiagnostics {
  _FakeDiagnostics(this.reports);
  final List<DiagnosticsReport> reports;
  final calls = <({String? username, String password})>[];

  @override
  Future<DiagnosticsReport> run({
    required BrokerConfig config,
    required String password,
    String base = 'zigbee2mqtt',
  }) async {
    calls.add((username: config.username, password: password));
    return reports.removeAt(0);
  }
}

DiagnosticsReport ok() => const DiagnosticsReport(
  steps: [
    StepResult(step: DiagnosticStep.resolve, status: StepStatus.pass),
    StepResult(step: DiagnosticStep.tcp, status: StepStatus.pass),
    StepResult(step: DiagnosticStep.connack, status: StepStatus.pass),
    StepResult(step: DiagnosticStep.auth, status: StepStatus.pass),
    StepResult(step: DiagnosticStep.devices, status: StepStatus.pass),
  ],
  connected: true,
  candidatesTried: 1,
  deviceNames: ['lamp'],
);

DiagnosticsReport failAt(DiagnosticStep step, String key) => DiagnosticsReport(
  steps: [StepResult(step: step, status: StepStatus.fail, detailKey: key)],
  connected: false,
  candidatesTried: 1,
);

class _FakeCreator implements SetupStore {
  var calls = 0;
  Object? error;
  String? lastBase;
  String? lastHost;
  String? lastPassword;
  ConnectionTransport? lastTransport;
  @override
  Future<SetupResult> create({
    required String host,
    required int port,
    required MqttProtocol protocol,
    String? username,
    String? password,
    String base = 'zigbee2mqtt',
    String? dashboardName,
    int dashboardColor = 0,
    int dashboardIcon = 0,
    required List<ReviewRow> selected,
    List<ReviewRow> notSelected = const [],
    ConnectionTransport transport = ConnectionTransport.mqtt,
  }) async {
    calls++;
    lastBase = base;
    lastHost = host;
    lastPassword = password;
    lastTransport = transport;
    if (error != null) throw error!;
    return SetupResult(
      connectionId: 'c1',
      dashboardId: 'd1',
      panelCount: selected.length,
    );
  }
}

/// A scan run that only ever reports brokers, for the fakes below.
ScanRun brokersOnly(Stream<ProbeResult> brokers) =>
    ScanRun(events: brokers.map(BrokerFound.new), addHub: (_) {});

class _Harness {
  _Harness({
    List<DiagnosticsReport>? reports,
    Stream<ProbeResult> Function(String ip)? scan,
    ScanRunFactory? run,
    Z2mFetchResult fetch = const Z2mFetchResult(
      detected: true,
      devices: [_lamp, _plug],
    ),
    Z2mFetchResult Function(String base)? fetchFor,
    Future<void> Function(SetupResult result)? onCreated,
    String? ip = '192.168.1.5',
    AddressChecker? checkAddress,
    HubIdentifier? identifyHub,
    Z2mBrokerLookup? askZ2m,
    Z2mPageDevices? pageDevices,
    Z2mPagePresent? pagePresent,
    BrokerPortProbe? probeBroker,
    NetworkFactsProvider? networkFacts,
    DeviceIpProvider? deviceIp,
    NoNetworkProvider? noNetwork,
    Duration networkRecheck = const Duration(seconds: 2),
  }) : diagnostics = _FakeDiagnostics(reports ?? [ok()]),
       creator = _FakeCreator() {
    coordinator = SetupCoordinator(
      scan:
          run ??
          (ip, hubs) => brokersOnly(
            (scan ??
                (ip) => Stream.fromIterable([
                  const ProbeResult(host: '192.168.1.10', port: 1883),
                ]))(ip),
          ),
      deviceIp: deviceIp ?? () async => ip,
      noNetwork: noNetwork,
      networkRecheck: networkRecheck,
      diagnostics: diagnostics,
      fetchDevices: (config, password, base) async {
        fetchedBases.add(base);
        return fetchFor?.call(base) ?? fetch;
      },
      creator: creator,
      onCreated: onCreated,
      checkAddress: checkAddress,
      identifyHub: identifyHub,
      askZ2m: askZ2m,
      pageDevices: pageDevices,
      pagePresent: pagePresent,
      probeBroker: probeBroker,
      networkFacts: networkFacts,
    );
  }

  final fetchedBases = <String>[];

  late final SetupCoordinator coordinator;
  final _FakeDiagnostics diagnostics;
  final _FakeCreator creator;
}

void main() {
  test('starts idle', () {
    expect(_Harness().coordinator.state, isA<SetupIdle>());
  });

  group('scanning', () {
    test('emits candidates progressively and finishes', () async {
      final controller = StreamController<ProbeResult>();
      final h = _Harness(scan: (_) => controller.stream);
      final states = <SetupState>[];
      h.coordinator.states.listen(states.add);

      unawaited(h.coordinator.startScan());
      controller.add(const ProbeResult(host: '192.168.1.10', port: 1883));
      await Future<void>.delayed(Duration.zero);
      controller.add(const ProbeResult(host: '192.168.1.11', port: 1883));
      await Future<void>.delayed(Duration.zero);
      await controller.close();
      await Future<void>.delayed(Duration.zero);

      final scanning = states.whereType<SetupScanning>().toList();
      expect(scanning.first.candidates, isEmpty);
      expect(scanning[1].candidates, hasLength(1));
      expect(scanning[2].candidates, hasLength(2));
      expect(h.coordinator.state, isA<SetupScanning>());
      expect((h.coordinator.state as SetupScanning).done, isTrue);
    });

    test('several brokers: each card learns what its machine is', () async {
      final asked = <String>[];
      final h = _Harness(
        scan: (_) => Stream.fromIterable([
          const ProbeResult(host: '192.168.1.10', port: 1883),
          const ProbeResult(host: '192.168.1.11', port: 1883),
          const ProbeResult(host: '192.168.1.12', port: 1883),
        ]),
        identifyHub: (host) async {
          asked.add(host);
          return switch (host) {
            '192.168.1.10' => HubKind.homeAssistant,
            '192.168.1.11' => HubKind.smlight,
            _ => null,
          };
        },
      );
      await h.coordinator.startScan();
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      final s = h.coordinator.state as SetupScanning;
      expect(s.done, isTrue);
      expect(
        asked,
        unorderedEquals(['192.168.1.10', '192.168.1.11', '192.168.1.12']),
      );
      expect(s.kinds, {
        '192.168.1.10': HubKind.homeAssistant,
        '192.168.1.11': HubKind.smlight,
      });

      // The answer survives the platform question...
      h.coordinator.setPlatform(SetupPlatform.piOrDocker);
      expect((h.coordinator.state as SetupScanning).kinds, hasLength(2));
      h.coordinator.setPlatform(null);

      // ...and picking the Home Assistant card answers it for the login hint.
      await h.coordinator.selectCandidate(s.candidates.first);
      expect(h.coordinator.platform, SetupPlatform.homeAssistant);
    });

    // First-run decision: one broker found → continue without a tap.
    test('exactly one broker found → continues to review on its own', () async {
      final h = _Harness();
      await h.coordinator.startScan();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(h.coordinator.state, isA<SetupReview>());
      expect(h.diagnostics.calls, hasLength(1));
    });

    test('no candidates found → SetupScanEmpty', () async {
      final h = _Harness(scan: (_) => const Stream.empty());
      await h.coordinator.startScan();
      await Future<void>.delayed(Duration.zero); // let onDone land
      expect(h.coordinator.state, isA<SetupScanEmpty>());
    });

    test('no local IP → SetupFailed(scanFailed)', () async {
      final h = _Harness(ip: null);
      await h.coordinator.startScan();
      final s = h.coordinator.state;
      expect(s, isA<SetupFailed>());
      expect((s as SetupFailed).kind, SetupErrorKind.scanFailed);
      expect(s.noNetwork, NoNetwork.unknown);
      await h.coordinator.dispose();
    });

    test('no local IP says why: mobile data', () async {
      final h = _Harness(ip: null, noNetwork: () async => NoNetwork.mobileData);
      await h.coordinator.startScan();
      expect(
        (h.coordinator.state as SetupFailed).noNetwork,
        NoNetwork.mobileData,
      );
      await h.coordinator.dispose();
    });

    test('a failing reason lookup is unknown, never mobile data', () async {
      final h = _Harness(ip: null, noNetwork: () => throw Exception('no'));
      await h.coordinator.startScan();
      expect((h.coordinator.state as SetupFailed).noNetwork, NoNetwork.unknown);
      await h.coordinator.dispose();
    });

    test('scans by itself once Wi-Fi is back, quietly until then', () {
      fakeAsync((async) {
        String? ip;
        final h = _Harness(
          deviceIp: () async => ip,
          noNetwork: () async => NoNetwork.mobileData,
        );
        final states = <SetupState>[];
        h.coordinator.states.listen(states.add);
        h.coordinator.startScan();
        async.flushMicrotasks();
        expect(h.coordinator.state, isA<SetupFailed>());
        final before = states.length;
        async.elapse(const Duration(seconds: 7));
        expect(states.length, before, reason: 'no new states without Wi-Fi');
        ip = '192.168.1.5';
        async.elapse(const Duration(seconds: 2));
        expect(states.skip(before).first, isA<SetupScanning>());
        h.coordinator.dispose();
        async.flushMicrotasks();
      });
    });

    test('leaving setup stops looking for Wi-Fi', () {
      fakeAsync((async) {
        String? ip;
        var asked = 0;
        final h = _Harness(
          deviceIp: () async {
            asked++;
            return ip;
          },
        );
        h.coordinator.startScan();
        async.flushMicrotasks();
        h.coordinator.cancel();
        async.flushMicrotasks();
        final after = asked;
        ip = '192.168.1.5';
        async.elapse(const Duration(seconds: 10));
        expect(asked, after);
        expect(h.coordinator.state, isA<SetupIdle>());
        h.coordinator.dispose();
        async.flushMicrotasks();
      });
    });

    test('retry from empty scan rescans', () async {
      var n = 0;
      final h = _Harness(
        scan: (_) {
          n++;
          return n == 1
              ? const Stream.empty()
              : Stream.value(const ProbeResult(host: '10.0.0.1', port: 1883));
        },
      );
      await h.coordinator.startScan();
      await Future<void>.delayed(Duration.zero);
      expect(h.coordinator.state, isA<SetupScanEmpty>());
      await h.coordinator.retry();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      // The rescan found the one broker and continued with it.
      expect(n, 2);
      expect(h.coordinator.state, isA<SetupReview>());
    });

    // 2.5: the platform answer, hubs seen and progress ride on the states.
    test('hubs, progress and the platform answer reach the states', () async {
      final controller = StreamController<ScanEvent>();
      final added = <HubKind>[];
      final h = _Harness(
        run: (_, hubs) => ScanRun(events: controller.stream, addHub: added.add),
      );
      unawaited(h.coordinator.startScan());
      await Future<void>.delayed(Duration.zero);

      controller.add(const ScanProgress(16, 1526));
      await Future<void>.delayed(Duration.zero);
      var s = h.coordinator.state as SetupScanning;
      expect(s.progress, (checked: 16, total: 1526));

      h.coordinator.setPlatform(SetupPlatform.smlight);
      expect(added, [HubKind.smlight], reason: 'the SMLIGHT pass is added');
      expect(
        (h.coordinator.state as SetupScanning).platform,
        SetupPlatform.smlight,
      );

      const ha = HubFound(
        kind: HubKind.homeAssistant,
        host: '192.168.1.20',
        port: 8123,
      );
      controller.add(const HubSeen(ha));
      await Future<void>.delayed(Duration.zero);
      s = h.coordinator.state as SetupScanning;
      expect(s.hubs, [ha]);

      controller.add(
        const ScanTriedEvent(widened: true, hostsTried: 1018, aliveHosts: 3),
      );
      await controller.close();
      await Future<void>.delayed(Duration.zero);
      final empty = h.coordinator.state as SetupScanEmpty;
      expect(empty.hubs, [ha]);
      expect(empty.hub, ha);
      expect(empty.platform, SetupPlatform.smlight);
      expect(empty.tried, (
        widened: true,
        hostsTried: 1018,
        aliveHosts: 3,
        lateHosts: 0,
      ));
      expect(empty.deviceIp, '192.168.1.5');

      // On the empty result the answer retags; Try again scans with it.
      h.coordinator.setPlatform(SetupPlatform.homeAssistant);
      expect(
        (h.coordinator.state as SetupScanEmpty).platform,
        SetupPlatform.homeAssistant,
      );
      expect((h.coordinator.state as SetupScanEmpty).hubs, [ha]);
    });

    test(
      'the SMLIGHT answer is part of the next scan; cancel forgets it',
      () async {
        final asked = <Set<HubKind>>[];
        final h = _Harness(
          run: (_, hubs) {
            asked.add(hubs);
            return ScanRun(events: const Stream.empty(), addHub: (_) {});
          },
        );
        await h.coordinator.startScan();
        await Future<void>.delayed(Duration.zero);
        h.coordinator.setPlatform(SetupPlatform.smlight);
        await h.coordinator.retry();
        await Future<void>.delayed(Duration.zero);
        expect(asked, [
          {HubKind.homeAssistant, HubKind.zigbee2mqtt},
          {HubKind.homeAssistant, HubKind.zigbee2mqtt, HubKind.smlight},
        ]);
        await h.coordinator.cancel();
        expect(h.coordinator.platform, isNull);
      },
    );

    test('the hub the result speaks about: Home Assistant first', () {
      const z2m = HubFound(kind: HubKind.zigbee2mqtt, host: 'a', port: 8080);
      const ha = HubFound(kind: HubKind.homeAssistant, host: 'b', port: 8123);
      expect(const SetupScanEmpty(hubs: [z2m, ha]).hub, ha);
      expect(const SetupScanEmpty(hubs: [z2m]).hub, z2m);
      expect(const SetupScanEmpty().hub, isNull);
    });

    test('cancel during scan returns to idle and stops the scan', () async {
      final controller = StreamController<ProbeResult>();
      final h = _Harness(scan: (_) => controller.stream);
      unawaited(h.coordinator.startScan());
      await Future<void>.delayed(Duration.zero);
      await h.coordinator.cancel();
      expect(h.coordinator.state, isA<SetupIdle>());
      expect(controller.hasListener, isFalse);
    });
  });

  group('verification', () {
    const candidate = SetupCandidate(
      host: '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
    );

    test('connected with devices → review with preselected rows', () async {
      final h = _Harness();
      await h.coordinator.selectCandidate(candidate);
      final s = h.coordinator.state;
      expect(s, isA<SetupReview>());
      final rows = (s as SetupReview).rows;
      expect(rows, hasLength(2));
      expect(rows.every((r) => r.selected), isTrue);
    });

    test('anonymous rejected → needsAuth, preserving the candidate', () async {
      final h = _Harness(
        reports: [failAt(DiagnosticStep.auth, 'diagAuthRejected'), ok()],
      );
      await h.coordinator.selectCandidate(candidate);
      final s = h.coordinator.state;
      expect(s, isA<SetupNeedsAuth>());
      expect((s as SetupNeedsAuth).rejected, isFalse);
      expect(s.candidate, candidate);
    });

    test('candidate flagged needsAuth asks before verifying', () async {
      final h = _Harness();
      await h.coordinator.selectCandidate(
        const SetupCandidate(
          host: 'h',
          port: 1883,
          protocol: MqttProtocol.tcp,
          needsAuth: true,
        ),
      );
      expect(h.coordinator.state, isA<SetupNeedsAuth>());
      expect(h.diagnostics.calls, isEmpty);
    });

    test(
      'submitting credentials verifies with them and reaches review',
      () async {
        final h = _Harness(
          reports: [failAt(DiagnosticStep.auth, 'diagAuthRejected'), ok()],
        );
        await h.coordinator.selectCandidate(candidate);
        await h.coordinator.submitCredentials('user', 'secret');
        expect(h.coordinator.state, isA<SetupReview>());
        expect(h.diagnostics.calls.last.username, 'user');
        expect(h.diagnostics.calls.last.password, 'secret');
      },
    );

    test('rejected credentials → needsAuth(rejected: true)', () async {
      final h = _Harness(
        reports: [
          failAt(DiagnosticStep.auth, 'diagAuthRejected'),
          failAt(DiagnosticStep.auth, 'diagAuthRejected'),
        ],
      );
      await h.coordinator.selectCandidate(candidate);
      await h.coordinator.submitCredentials('user', 'wrong');
      final s = h.coordinator.state;
      expect(s, isA<SetupNeedsAuth>());
      expect((s as SetupNeedsAuth).rejected, isTrue);
    });

    test(
      'tcp failure → SetupFailed(hostUnreachable-ish), retry re-verifies',
      () async {
        final h = _Harness(
          reports: [failAt(DiagnosticStep.tcp, 'diagTcpFail'), ok()],
        );
        await h.coordinator.selectCandidate(candidate);
        var s = h.coordinator.state;
        expect(s, isA<SetupFailed>());
        expect((s as SetupFailed).kind, SetupErrorKind.portClosed);

        await h.coordinator.retry();
        expect(h.coordinator.state, isA<SetupReview>());
        expect(h.diagnostics.calls, hasLength(2));
      },
    );

    test('MQTT without Zigbee2MQTT topics → notZigbee2Mqtt', () async {
      final h = _Harness(
        fetch: const Z2mFetchResult(detected: false, devices: []),
      );
      await h.coordinator.selectCandidate(candidate);
      expect(
        (h.coordinator.state as SetupFailed).kind,
        SetupErrorKind.notZigbee2Mqtt,
      );
    });

    // First-run decision: "Your broker works, but Zigbee2MQTT isn't
    // publishing here" offers a base-topic check with a one-tap retry.
    test(
      'no Zigbee2MQTT → retry with another base topic reaches review',
      () async {
        final h = _Harness(
          reports: [ok(), ok()],
          fetchFor: (base) => base == 'z2m'
              ? const Z2mFetchResult(detected: true, devices: [_lamp])
              : const Z2mFetchResult(detected: false, devices: []),
        );
        await h.coordinator.startScan();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(
          (h.coordinator.state as SetupFailed).kind,
          SetupErrorKind.notZigbee2Mqtt,
        );

        await h.coordinator.retryWithBase(' z2m ');

        expect(h.fetchedBases, ['zigbee2mqtt', 'z2m']);
        expect(h.coordinator.state, isA<SetupReview>());
        await h.coordinator.createDashboard();
        expect(h.creator.lastBase, 'z2m');
      },
    );

    test(
      'Zigbee2MQTT under its own base topic is found by itself (2.9.2)',
      () async {
        final h = _Harness(
          reports: [ok(), ok()],
          fetchFor: (base) => base == 'home/z2m'
              ? const Z2mFetchResult(detected: true, devices: [_lamp])
              : const Z2mFetchResult(
                  detected: false,
                  devices: [],
                  otherBases: ['home/z2m'],
                ),
        );
        await h.coordinator.selectCandidate(candidate);
        expect(h.fetchedBases, ['zigbee2mqtt', 'home/z2m']);
        expect(h.coordinator.state, isA<SetupReview>());
        await h.coordinator.createDashboard();
        expect(h.creator.lastBase, 'home/z2m');
      },
    );

    test('a base topic that also fails stops after one switch', () async {
      final h = _Harness(
        reports: [ok(), ok(), ok()],
        fetch: const Z2mFetchResult(
          detected: false,
          devices: [],
          otherBases: ['a', 'b'],
        ),
      );
      await h.coordinator.selectCandidate(candidate);
      expect(h.fetchedBases, ['zigbee2mqtt', 'a']);
      expect(
        (h.coordinator.state as SetupFailed).kind,
        SetupErrorKind.notZigbee2Mqtt,
      );
    });

    group('3.1.13: the device list never came', () {
      const missing = Z2mFetchResult(
        detected: true,
        devices: [],
        devicesMissing: true,
      );

      test("Zigbee2MQTT's web page has it: on to the review", () async {
        final asked = <String>[];
        final h = _Harness(
          fetch: missing,
          pageDevices: (host) async {
            asked.add(host);
            return const [_lamp, _plug];
          },
        );
        await h.coordinator.selectCandidate(candidate);
        expect(asked, ['192.168.1.10']);
        expect(h.coordinator.state, isA<SetupReview>());
      });

      test('the page has nothing: says the list is missing', () async {
        final h = _Harness(fetch: missing, pageDevices: (_) async => null);
        await h.coordinator.selectCandidate(candidate);
        expect(
          (h.coordinator.state as SetupFailed).kind,
          SetupErrorKind.devicesListMissing,
        );
      });

      test('a list that came empty is still no devices', () async {
        var asked = false;
        final h = _Harness(
          fetch: const Z2mFetchResult(detected: true, devices: []),
          pageDevices: (_) async {
            asked = true;
            return null;
          },
        );
        await h.coordinator.selectCandidate(candidate);
        expect(asked, isFalse);
        expect(
          (h.coordinator.state as SetupFailed).kind,
          SetupErrorKind.noDevices,
        );
      });
    });

    test('Zigbee2MQTT detected but no devices → noDevices', () async {
      final h = _Harness(
        fetch: const Z2mFetchResult(detected: true, devices: []),
      );
      await h.coordinator.selectCandidate(candidate);
      expect(
        (h.coordinator.state as SetupFailed).kind,
        SetupErrorKind.noDevices,
      );
    });
  });

  group('review and creation', () {
    const candidate = SetupCandidate(
      host: '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
    );

    Future<_Harness> inReview() async {
      final h = _Harness();
      await h.coordinator.selectCandidate(candidate);
      return h;
    }

    test('toggle flips selection', () async {
      final h = await inReview();
      h.coordinator.toggleDevice('lamp');
      final s = h.coordinator.state as SetupReview;
      expect(
        s.rows.firstWhere((r) => r.device.friendlyName == 'lamp').selected,
        isFalse,
      );
      expect(s.selectedCount, 1);
    });

    test('createDashboard → complete with the selected panels only', () async {
      final h = await inReview();
      h.coordinator.toggleDevice('lamp');
      await h.coordinator.createDashboard();
      final s = h.coordinator.state;
      expect(s, isA<SetupComplete>());
      expect((s as SetupComplete).result.panelCount, 1);
    });

    // First-run decision: no separate "Creating…" screen; the review list
    // stays on screen while saving.
    test('saving keeps the reviewed devices in the state', () async {
      final h = _Harness();
      final states = <SetupState>[];
      h.coordinator.states.listen(states.add);
      await h.coordinator.startScan();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await h.coordinator.createDashboard();

      final creating = states.whereType<SetupCreating>().single;
      expect(
        creating.review.rows.map((r) => r.device.friendlyName),
        containsAll(['lamp', 'plug']),
      );
    });

    test('a successful setup runs the completion hook once', () async {
      final seen = <SetupResult>[];
      final h = _Harness(onCreated: (r) async => seen.add(r));
      await h.coordinator.startScan();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await h.coordinator.createDashboard();

      expect(h.coordinator.state, isA<SetupComplete>());
      expect(seen.single.dashboardId, 'd1');
    });

    test(
      'a failing completion hook does not undo a successful setup',
      () async {
        final h = _Harness(onCreated: (_) async => throw StateError('prefs'));
        await h.coordinator.startScan();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await h.coordinator.createDashboard();

        expect(h.coordinator.state, isA<SetupComplete>());
      },
    );

    test(
      'save failure → SetupFailed(saveFailed), retry resumes at creation',
      () async {
        final h = await inReview();
        h.creator.error = StateError('disk full');
        await h.coordinator.createDashboard();
        expect(
          (h.coordinator.state as SetupFailed).kind,
          SetupErrorKind.saveFailed,
        );

        h.creator.error = null;
        await h.coordinator.retry();
        expect(h.coordinator.state, isA<SetupComplete>());
        // The retry went straight to creation — no extra ladder run.
        expect(h.diagnostics.calls, hasLength(1));
      },
    );

    test('credentials entered during setup reach the creator', () async {
      final h = _Harness(
        reports: [failAt(DiagnosticStep.auth, 'diagAuthRejected'), ok()],
      );
      await h.coordinator.selectCandidate(candidate);
      await h.coordinator.submitCredentials('user', 'secret');
      await h.coordinator.createDashboard();
      expect(h.creator.calls, 1);
    });
  });

  // 2.6.2: the address check on the empty result.
  group('checkAddress', () {
    const broker = ProbeResult(host: '192.168.1.20', port: 1883);
    const ha = HubFound(
      kind: HubKind.homeAssistant,
      host: '192.168.1.20',
      port: 8123,
    );

    Future<_Harness> empty({
      AddressChecker? checkAddress,
      NetworkFactsProvider? networkFacts,
    }) async {
      final h = _Harness(
        scan: (_) => const Stream.empty(),
        checkAddress: checkAddress,
        networkFacts: networkFacts,
      );
      await h.coordinator.startScan();
      await Future<void>.delayed(Duration.zero);
      expect(h.coordinator.state, isA<SetupScanEmpty>());
      return h;
    }

    test('a broker at the address is verified like a scanned one', () async {
      final asked = <(String, int?)>[];
      final h = await empty(
        checkAddress: (host, port) async {
          asked.add((host, port));
          return const AddressCheckResult(
            AddressOutcome.broker,
            broker: broker,
          );
        },
      );
      final states = <SetupState>[];
      final sub = h.coordinator.states.listen(states.add);
      await h.coordinator.checkAddress(
        ' http://HomeAssistant.local:8123/lovelace ',
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      // The typed text is reduced to a host and the port it came with.
      expect(asked, [('homeassistant.local', 8123)]);
      expect(
        states.first,
        isA<SetupScanEmpty>().having((s) => s.address, 'address', (
          status: AddressCheckStatus.checking,
          host: 'homeassistant.local',
        )),
      );
      expect(states, contains(isA<SetupVerifying>()));
      expect(h.coordinator.state, isA<SetupReview>());
    });

    test('a broker that wants a login goes to the login step', () async {
      final h = await empty(
        checkAddress: (host, port) async => const AddressCheckResult(
          AddressOutcome.broker,
          broker: ProbeResult(
            host: '192.168.1.20',
            port: 1883,
            needsAuth: true,
          ),
        ),
      );
      h.coordinator.setPlatform(SetupPlatform.homeAssistant);
      final states = <SetupState>[];
      final sub = h.coordinator.states.listen(states.add);
      await h.coordinator.checkAddress('192.168.1.20');
      await Future<void>.delayed(Duration.zero); // let the last event land
      await sub.cancel();
      // Through a verifying state, so the check counts as found first.
      expect(states.map((s) => s.runtimeType).toList(), [
        SetupScanEmpty,
        SetupVerifying,
        SetupNeedsAuth,
      ]);
      final s = h.coordinator.state as SetupNeedsAuth;
      expect(s.candidate.host, '192.168.1.20');
      expect(s.platform, SetupPlatform.homeAssistant);
    });

    test('a hub page without a broker becomes the hub result', () async {
      final h = await empty(
        checkAddress: (host, port) async =>
            const AddressCheckResult(AddressOutcome.hub, hub: ha),
      );
      h.coordinator.setPlatform(SetupPlatform.homeAssistant);
      await h.coordinator.checkAddress('192.168.1.20');
      final s = h.coordinator.state as SetupScanEmpty;
      expect(s.hub, ha);
      expect(s.platform, SetupPlatform.homeAssistant);
      expect(s.address, (status: AddressCheckStatus.hub, host: '192.168.1.20'));
    });

    test('nothing, not resolved and not local stay on the field', () async {
      for (final (outcome, status) in [
        (AddressOutcome.nothing, AddressCheckStatus.nothing),
        (AddressOutcome.notResolved, AddressCheckStatus.notResolved),
        (AddressOutcome.notLocal, AddressCheckStatus.notLocal),
      ]) {
        final h = await empty(
          checkAddress: (host, port) async => AddressCheckResult(outcome),
        );
        await h.coordinator.checkAddress('hub.example');
        final s = h.coordinator.state as SetupScanEmpty;
        expect(s.hubs, isEmpty);
        expect(s.address, (status: status, host: 'hub.example'));
      }
    });

    test('blank input is invalid without asking the checker', () async {
      var calls = 0;
      final h = await empty(
        checkAddress: (host, port) async {
          calls++;
          return const AddressCheckResult.nothing();
        },
      );
      await h.coordinator.checkAddress('   ');
      expect(calls, 0);
      expect((h.coordinator.state as SetupScanEmpty).address, (
        status: AddressCheckStatus.invalid,
        host: '',
      ));
    });

    test('a checker that throws, or none at all, reports nothing', () async {
      final h = await empty(checkAddress: (host, port) async => throw 'boom');
      await h.coordinator.checkAddress('192.168.1.2');
      expect(
        (h.coordinator.state as SetupScanEmpty).address?.status,
        AddressCheckStatus.nothing,
      );
      final web = await empty();
      await web.coordinator.checkAddress('192.168.1.2');
      expect(
        (web.coordinator.state as SetupScanEmpty).address?.status,
        AddressCheckStatus.nothing,
      );
    });

    test('Try again clears the check; the chips keep it', () async {
      final h = await empty(
        checkAddress: (host, port) async => const AddressCheckResult.nothing(),
      );
      await h.coordinator.checkAddress('192.168.1.2');
      h.coordinator.setPlatform(SetupPlatform.smlight);
      expect(
        (h.coordinator.state as SetupScanEmpty).address?.status,
        AddressCheckStatus.nothing,
      );
      await h.coordinator.retry();
      await Future<void>.delayed(Duration.zero);
      expect((h.coordinator.state as SetupScanEmpty).address, isNull);
    });

    test('the network facts ride on the empty result', () async {
      final h = await empty(
        networkFacts: () async => (kind: 'Wi-Fi', vpn: true),
      );
      expect((h.coordinator.state as SetupScanEmpty).network, (
        kind: 'Wi-Fi',
        vpn: true,
      ));
      // Facts that fail to load never stop the scan.
      final h2 = await empty(networkFacts: () async => throw 'no');
      expect((h2.coordinator.state as SetupScanEmpty).network, isNull);
    });
  });

  // 2.7.2: the scan saw Zigbee2MQTT's web page but no broker, so setup asks
  // the page where its broker is.
  group('asking Zigbee2MQTT', () {
    const z2mPage = HubFound(
      kind: HubKind.zigbee2mqtt,
      host: '192.168.1.30',
      port: 8080,
    );

    Future<_Harness> emptyScanWith(
      List<HubFound> hubs, {
      Z2mBrokerSetting? Function(String host, int port)? answer,
      Map<String, ProbeResult> brokers = const {},
      List<String>? asked,
      List<String>? probed,
    }) async {
      final h = _Harness(
        run: (_, _) => ScanRun(
          events: Stream.fromIterable([for (final hub in hubs) HubSeen(hub)]),
          addHub: (_) {},
        ),
        askZ2m: (host, port) async {
          asked?.add('$host:$port');
          return answer?.call(host, port);
        },
        probeBroker: (host, port) async {
          probed?.add('$host:$port');
          return brokers['$host:$port'];
        },
      );
      await h.coordinator.startScan();
      for (var i = 0; i < 8; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      return h;
    }

    Z2mBrokerSetting setting(String server, {String? user}) => z2mBrokerSetting(
      {'server': server, 'user': ?user},
      frontendHost: '192.168.1.30',
    )!;

    test('a broker where Zigbee2MQTT says: verified, its user ready', () async {
      final asked = <String>[];
      final h = await emptyScanWith(
        [z2mPage],
        asked: asked,
        answer: (_, _) => setting('mqtt://localhost:1884', user: 'zigbee'),
        brokers: {
          '192.168.1.30:1884': const ProbeResult(
            host: '192.168.1.30',
            port: 1884,
            needsAuth: true,
          ),
        },
      );
      expect(asked, ['192.168.1.30:8080']);
      final auth = h.coordinator.state as SetupNeedsAuth;
      expect(auth.candidate.port, 1884);
      expect(auth.suggestedUser, 'zigbee');
    });

    test(
      'nothing answers on the same machine: it listens only there',
      () async {
        final h = await emptyScanWith([
          z2mPage,
        ], answer: (_, _) => setting('mqtt://localhost:1883'));
        final empty = h.coordinator.state as SetupScanEmpty;
        expect(empty.z2m, (
          status: Z2mAnswerStatus.localOnly,
          server: 'mqtt://localhost:1883',
        ));
      },
    );

    test('another address that does not answer is named', () async {
      final probed = <String>[];
      final h = await emptyScanWith(
        [z2mPage],
        probed: probed,
        answer: (_, _) => setting('mqtt://192.168.1.20:1883'),
      );
      expect(probed, ['192.168.1.20:1883']);
      expect((h.coordinator.state as SetupScanEmpty).z2m, (
        status: Z2mAnswerStatus.unreachable,
        server: 'mqtt://192.168.1.20:1883',
      ));
    });

    // 2.10.4: a Docker service or hostname only Zigbee2MQTT's machine knows.
    test('a name the phone cannot use is said, with its port', () async {
      final h = await emptyScanWith([
        z2mPage,
      ], answer: (_, _) => setting('mqtt://mosquitto:1884'));
      expect((h.coordinator.state as SetupScanEmpty).z2m, (
        status: Z2mAnswerStatus.nameOnly,
        server: 'mqtt://mosquitto:1884',
      ));
    });

    test('a page protected by a token is said, not silent', () async {
      final h = await emptyScanWith([
        z2mPage,
      ], answer: (_, _) => throw const Z2mPageLocked());
      expect((h.coordinator.state as SetupScanEmpty).z2m, (
        status: Z2mAnswerStatus.tokenRequired,
        server: '',
      ));
    });

    test('the page does not answer: the result stays as it was', () async {
      final h = await emptyScanWith([z2mPage]);
      expect((h.coordinator.state as SetupScanEmpty).z2m, (
        status: Z2mAnswerStatus.noAnswer,
        server: '',
      ));
    });

    test('an SMLIGHT hub is asked on the Zigbee2MQTT port', () async {
      final asked = <String>[];
      await emptyScanWith([
        const HubFound(kind: HubKind.smlight, host: '192.168.1.40', port: 80),
      ], asked: asked);
      expect(asked, ['192.168.1.40:8080']);
    });

    test('Home Assistant alone is not asked', () async {
      final asked = <String>[];
      final h = await emptyScanWith([
        const HubFound(
          kind: HubKind.homeAssistant,
          host: '192.168.1.50',
          port: 8123,
        ),
      ], asked: asked);
      expect(asked, isEmpty);
      expect((h.coordinator.state as SetupScanEmpty).z2m, isNull);
    });
  });

  // ha-import: setup offers the import when this home has Home Assistant.
  group('homeAssistantSeen', () {
    Future<_Harness> doneWith({
      HubKind? onBrokerHost,
      List<String>? asked,
    }) async {
      final h = _Harness(
        identifyHub: (host) async {
          asked?.add(host);
          return onBrokerHost;
        },
      );
      await h.coordinator.startScan();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await h.coordinator.createDashboard();
      return h;
    }

    test('Home Assistant on the broker\'s machine: offered', () async {
      final asked = <String>[];
      final h = await doneWith(
        onBrokerHost: HubKind.homeAssistant,
        asked: asked,
      );
      expect(await h.coordinator.homeAssistantSeen(), isTrue);
      expect(asked, ['192.168.1.10']);
    });

    test('nothing there: not offered', () async {
      final h = await doneWith(onBrokerHost: HubKind.zigbee2mqtt);
      expect(await h.coordinator.homeAssistantSeen(), isFalse);
    });

    test('the user said Home Assistant: offered without asking', () async {
      final asked = <String>[];
      final h = _Harness(
        identifyHub: (host) async {
          asked.add(host);
          return null;
        },
      );
      h.coordinator.setPlatform(SetupPlatform.homeAssistant);
      expect(await h.coordinator.homeAssistantSeen(), isTrue);
      expect(asked, isEmpty);
    });

    test('a scan card named Home Assistant: offered', () async {
      final h = _Harness(
        scan: (_) => Stream.fromIterable([
          const ProbeResult(host: '192.168.1.10', port: 1883),
          const ProbeResult(host: '192.168.1.11', port: 1883),
        ]),
        identifyHub: (host) async =>
            host == '192.168.1.10' ? HubKind.homeAssistant : null,
      );
      await h.coordinator.startScan();
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(await h.coordinator.homeAssistantSeen(), isTrue);
    });
  });

  group('through Home Assistant (2.10)', () {
    test(
      'skips the broker ladder, reads devices, saves the transport',
      () async {
        final h = _Harness();
        await h.coordinator.adoptHomeAssistant(
          address: Uri.parse('https://abc.ui.nabu.casa'),
          signIn: 'refresh:r1',
        );
        expect(h.diagnostics.calls, isEmpty);
        expect(h.fetchedBases, ['zigbee2mqtt']);
        final review = h.coordinator.state as SetupReview;
        expect(review.candidate.transport, ConnectionTransport.homeAssistant);
        expect(review.candidate.host, 'https://abc.ui.nabu.casa');
        expect(review.candidate.protocol, MqttProtocol.wss);
        expect(review.candidate.port, 443);

        await h.coordinator.createDashboard();
        expect(h.coordinator.state, isA<SetupComplete>());
        expect(h.creator.lastTransport, ConnectionTransport.homeAssistant);
        expect(h.creator.lastHost, 'https://abc.ui.nabu.casa');
        expect(h.creator.lastPassword, 'refresh:r1');
      },
    );

    test('a plain address keeps its port and scheme', () async {
      final h = _Harness();
      await h.coordinator.adoptHomeAssistant(
        address: Uri.parse('http://192.168.68.52:8123'),
        signIn: 'eyJ.long.lived',
      );
      final review = h.coordinator.state as SetupReview;
      expect(review.candidate.host, 'http://192.168.68.52:8123');
      expect(review.candidate.port, 8123);
      expect(review.candidate.protocol, MqttProtocol.ws);
    });

    test(
      'no Zigbee2MQTT through Home Assistant is the usual outcome',
      () async {
        final h = _Harness(
          fetch: const Z2mFetchResult(detected: false, devices: []),
        );
        await h.coordinator.adoptHomeAssistant(
          address: Uri.parse('http://192.168.68.52:8123'),
          signIn: 'eyJ.long.lived',
        );
        final failed = h.coordinator.state as SetupFailed;
        // 3.1.13: its own kind: there is no other broker to pick.
        expect(failed.kind, SetupErrorKind.haNoZigbee2Mqtt);
        expect(failed.candidate?.transport, ConnectionTransport.homeAssistant);
      },
    );
  });

  group('3.2: the Zigbee2MQTT page instead of a broker login', () {
    const locked = SetupCandidate(
      host: '192.168.1.10',
      port: 1883,
      protocol: MqttProtocol.tcp,
      needsAuth: true,
    );

    test('a page on the same machine: no login, on to the review', () async {
      final asked = <String>[];
      final h = _Harness(
        pagePresent: (host, port) async {
          asked.add('$host:$port');
          return true;
        },
      );
      await h.coordinator.selectCandidate(locked);
      expect(asked, ['192.168.1.10:8080']);
      final review = h.coordinator.state as SetupReview;
      expect(review.candidate.transport, ConnectionTransport.z2mPage);
      expect(review.candidate.port, 8080);
      expect(h.diagnostics.calls, isEmpty, reason: 'no broker ladder for the page');
      await h.coordinator.createDashboard();
      expect((h.coordinator.state as SetupComplete).via, SetupVia.z2mPage);
    });

    test('no page: the login prompt as before', () async {
      final h = _Harness(pagePresent: (_, __) async => false);
      await h.coordinator.selectCandidate(locked);
      expect(h.coordinator.state, isA<SetupNeedsAuth>());
    });

    test('a login given and refused stays a refusal, the page is not tried again', () async {
      var asked = 0;
      final h = _Harness(
        reports: [failAt(DiagnosticStep.auth, 'diagAuthRejected')],
        pagePresent: (_, __) async {
          asked++;
          return false;
        },
      );
      await h.coordinator.selectCandidate(locked);
      await h.coordinator.submitCredentials('u', 'p');
      expect(h.coordinator.state, isA<SetupNeedsAuth>());
      expect(asked, 1);
    });
  });

  test("3.2: the phone's own /24 first; wider on request, and a retry keeps it", () async {
    final h = _Harness(scan: (_) => const Stream.empty());
    await h.coordinator.startScan();
    expect(h.coordinator.widen, isFalse);
    await h.coordinator.startScan(widen: true);
    expect(h.coordinator.widen, isTrue);
    await Future<void>.delayed(Duration.zero);
    await h.coordinator.retry();
    expect(h.coordinator.widen, isTrue);
  });

  test('3.2: a page that does not answer gets its own failure, not the broker one', () async {
    final h = _Harness(fetch: const Z2mFetchResult(detected: false, devices: []));
    await h.coordinator.adoptZ2mPage(host: '192.168.1.30');
    expect((h.coordinator.state as SetupFailed).kind, SetupErrorKind.pageNoAnswer);
  });
}

