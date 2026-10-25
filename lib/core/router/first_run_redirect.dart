import 'routes.dart';

/// Screens a first-run user may be on: the setup flow, its manual entry,
/// help and Get help, and joining a home another phone shared (3.1.7: a
/// new phone is exactly who scans that code). Everything else waits until
/// there is a home or the demo.
const _firstRunLocations = {
  Routes.setup,
  Routes.joinHome,
  Routes.guidedConnect,
  // 3.1.8: Home Assistant's sign-in, opened from setup and from manual
  // entry; without it every button to it led back to setup.
  Routes.haConnect,
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
