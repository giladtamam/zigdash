/// True only in builds made by tool/store/capture.sh for Play Store
/// screenshots (`--dart-define=ZIGDASH_STORE_CAPTURE=true`). The listing
/// shows the demo home as a real home would look, without the demo bar.
/// Never set in release builds.
const storeCapture = bool.fromEnvironment('ZIGDASH_STORE_CAPTURE');
