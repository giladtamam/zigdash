import 'no_network.dart';

export 'no_network.dart';

/// Web fallback: no LAN IP introspection in the browser.
Future<String?> wifiIpv4() async => null;

Future<({String name, String ip})?> homeIpv4() async => null;

Future<bool> vpnActive() async => false;

enum LocalNetworkAccess { granted, denied, unknown }

Future<LocalNetworkAccess> localNetworkAccess({
  Duration timeout = const Duration(seconds: 60),
}) async => LocalNetworkAccess.granted;

Future<NoNetwork> noNetworkReason() async => NoNetwork.unknown;
