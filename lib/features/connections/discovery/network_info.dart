// Platform-conditional access to the device's Wi-Fi IPv4 address.
// `dart:io` on mobile/desktop; a null-returning stub on web.
export 'network_info_stub.dart' if (dart.library.io) 'network_info_io.dart';
