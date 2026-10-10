import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../../data/database/daos/device_registry_dao.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/repositories/section_repo.dart';
import '../../settings/providers/settings_controller.dart';
import '../../connections/diagnostics/connect_diagnostics_provider.dart';
import '../../connections/discovery/broker_scan_providers.dart';
import '../../connections/discovery/network_info.dart';
import '../../support/support_details.dart';
import '../../support/support_log.dart';
import '../first_run.dart';
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
  // The interface the scan runs on, kept only as a kind (Wi-Fi, Ethernet).
  String? network;
  final coordinator = SetupCoordinator(
    scan: (ip) => scanner.scan(ip,
        onDone: (st) => support.recordScan(ScanSummary(
              widened: st.widened,
              hostsTried: st.hostsTried,
              brokersFound: st.brokersFound,
              network: network,
            ))),
    deviceIp: () async {
      final home = await homeIpv4();
      network = networkOfInterface(home?.name);
      return home?.ip;
    },
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
    onCreated: (result) =>
        ref.read(firstRunProvider).finish(result.connectionId),
  );
  final failures = coordinator.states.listen((s) {
    if (s is SetupFailed) support.recordFailure(failureKindFromSetup(s.kind));
  });
  ref.onDispose(failures.cancel);
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
