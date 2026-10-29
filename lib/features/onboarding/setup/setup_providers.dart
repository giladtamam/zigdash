import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../data/database/daos/device_registry_dao.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/repositories/section_repo.dart';
import '../../settings/providers/settings_controller.dart';
import '../../connections/diagnostics/connect_diagnostics_provider.dart';
import '../../connections/discovery/address_checker.dart';
import '../../connections/discovery/broker_scan_providers.dart';
import '../../connections/discovery/hub_probe.dart';
import '../../connections/discovery/z2m_frontend.dart';
import '../../connections/discovery/z2m_frontend_fetch.dart';
import '../../discovery/models/z2m_device.dart' show parseBridgeDevices;
import '../../connections/discovery/network_info.dart';
import '../../support/support_details.dart';
import '../../support/support_log.dart';
import '../first_run.dart';
import '../../ha_import/ha_import_offer.dart';
import 'setup_analytics.dart';
import 'setup_coordinator.dart';
import 'setup_creator.dart';
import 'z2m_probe.dart';

/// The setup coordinator, wired to the real platform services. The screen
/// owns the instance lifecycle: created on entry, disposed on leave, so a
/// reopened setup always begins from a safe initial state.
final setupCoordinatorProvider = Provider.autoDispose<SetupCoordinator>((ref) {
  final scanner = ref.watch(brokerScanServiceProvider);
  final fetcher = Z2mProbeFetcher();
  final support = ref.read(supportLogProvider);
  // Read now: `ref.read` is not allowed once the provider is disposing.
  final analytics = ref.read(analyticsProvider);
  // The interface the scan runs on, kept only as a kind (Wi-Fi, Ethernet).
  String? network;
  late final SetupCoordinator coordinator;
  coordinator = SetupCoordinator(
    scan: (ip, hubs) => scanner.run(
      ip,
      hubs: hubs,
      widen: coordinator.widen,
      onDone: (st) => support.recordScan(
        ScanSummary(
          widened: st.widened,
          hostsTried: st.hostsTried,
          brokersFound: st.brokersFound,
          network: network,
        ),
      ),
    ),
    deviceIp: () async {
      final home = await homeIpv4();
      network = networkOfInterface(home?.name);
      return home?.ip;
    },
    networkFacts: () async => (kind: network, vpn: await vpnActive()),
    noNetwork: noNetworkReason,
    identifyHub: (host) => identifyHost(scanner.hubProber, host),
    askZ2m: (host, port) async => z2mBrokerSetting(
      await fetchZ2mMqttConfig(host, port),
      frontendHost: host,
    ),
    // 3.2: a page that answers (bridge/info) without a token.
    pagePresent: (host, port) async {
      try {
        return await fetchZ2mMqttConfig(host, port) != null;
      } on Z2mPageLocked {
        return false;
      }
    },
    // The page's usual port; the Home Assistant add-on's sits behind
    // ingress, where only the Home Assistant route reaches it.
    pageDevices: (host) async {
      final list = await fetchZ2mDeviceList(host, 8080);
      return list == null ? null : parseBridgeDevices(list);
    },
    probeBroker: scanner.prober.probe,
    checkAddress: createAddressChecker(
      prober: scanner.prober,
      hubProber: scanner.hubProber,
    ),
    diagnostics: ref.watch(connectDiagnosticsProvider),
    fetchDevices: fetcher.fetch,
    creator: SetupCreator(
      connections: ref.watch(connectionRepoProvider),
      dashboards: ref.watch(dashboardRepoProvider),
      sections: ref.watch(sectionRepoProvider),
      panels: ref.watch(panelRepoProvider),
      registry: DeviceRegistryDao(ref.watch(appDatabaseProvider)),
      l10n: appL10n(ref.read(settingsControllerProvider).locale),
    ),
    onCreated: (result) async {
      await ref.read(firstRunProvider).finish(result.connectionId);
      // Home Assistant nearby: the new dashboard offers its names and rooms.
      if (await coordinator.homeAssistantSeen()) {
        await ref
            .read(haImportOfferProvider.notifier)
            .offer(result.connectionId);
      }
    },
  );
  final failures = coordinator.states.listen((s) {
    if (s is SetupFailed) support.recordFailure(failureKindFromSetup(s.kind));
    if (s is SetupNeedsAuth) {
      support.recordFailure(
        s.rejected ? FailureKind.loginRejected : FailureKind.loginRequired,
      );
    }
  });
  ref.onDispose(failures.cancel);
  // 2.10.2: back out of setup while the list is up (to a demo home, say)
  // is the other way to leave the review without a dashboard.
  ref.onDispose(() {
    final s = coordinator.state;
    if (s is SetupReview) analytics.track(reviewLeftStep(s, coordinator));
  });
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// The coordinator's state stream as a Riverpod stream, for `ref.watch`.
final setupStateProvider = StreamProvider.autoDispose<SetupState>((ref) async* {
  final coordinator = ref.watch(setupCoordinatorProvider);
  // Emit the current state first so the UI never renders a blank frame.
  yield coordinator.state;
  yield* coordinator.states;
});
