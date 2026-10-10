import 'routes.dart';

/// Screens a first-run user may be on: the setup flow, its manual entry,
/// help and Get help. Everything else waits until there is a home or the demo.
const _firstRunLocations = {
  Routes.setup,
  Routes.guidedConnect,
  Routes.help,
  Routes.getHelp,
};

/// Router redirect for first run: one door, no carousel.
///
/// While [needsSetup] (no home yet and not in demo), every other location
/// goes to setup. Afterwards, the retired onboarding address opens
/// [startLocation], the last-used dashboard or the start screen (which
/// opens a home, or setup when there is none).
String? firstRunRedirect({
  required bool needsSetup,
  required String location,
  required String startLocation,
}) {
  if (needsSetup) {
    return _firstRunLocations.contains(location) ? null : Routes.setup;
  }
  if (location == Routes.onboarding) return startLocation;
  return null;
}
