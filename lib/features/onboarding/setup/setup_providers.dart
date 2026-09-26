import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/daos/device_registry_dao.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/connection_repo.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../../data/repositories/section_repo.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/providers/settings_controller.dart';
import '../../connections/diagnostics/connect_diagnostics_provider.dart';
import '../../connections/discovery/broker_scan_providers.dart';
import '../../connections/discovery/network_info.dart';
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
  final coordinator = SetupCoordinator(
    scan: scanner.scan,
    deviceIp: wifiIpv4,
    diagnostics: ref.watch(connectDiagnosticsProvider),
    fetchDevices: fetcher.fetch,
    creator: SetupCreator(
      connections: ref.watch(connectionRepoProvider),
      dashboards: ref.watch(dashboardRepoProvider),
      sections: ref.watch(sectionRepoProvider),
      panels: ref.watch(panelRepoProvider),
      registry: DeviceRegistryDao(ref.watch(appDatabaseProvider)),
      l10n: _appL10n(ref.read(settingsControllerProvider).locale),
    ),
    onCreated: (result) =>
        ref.read(firstRunProvider).finish(result.connectionId),
  );
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

/// The app's strings in the chosen language, else the phone's, else English
/// — for names setup writes into the database (home, sections).
AppLocalizations _appL10n(Locale? chosen) {
  final code = (chosen ?? PlatformDispatcher.instance.locale).languageCode;
  final supported =
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code);
  return lookupAppLocalizations(Locale(supported ? code : 'en'));
}
